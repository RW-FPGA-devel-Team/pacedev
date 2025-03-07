/*	$NetBSD: hid.c,v 1.17 2001/11/13 06:24:53 lukem Exp $	*/
/*-
 * Copyright (c) 1998 The NetBSD Foundation, Inc.
 * All rights reserved.
 *
 * This code is derived from software contributed to The NetBSD Foundation
 * by Lennart Augustsson (lennart@augustsson.net) at
 * Carlstedt Research & Technology.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include "usb.h"
#include "usbdi.h"
#include "usbdi_util.h"
#include "usbhid.h"

#define	USB_DEBUG_VAR usb_debug

#include "usb_core.h"
#include "usb_debug.h"
#include "usb_process.h"
#include "usb_device.h"
#include "usb_request.h"

static void hid_clear_local(struct hid_item *);
static uint8_t hid_get_byte(struct hid_data *s, const uint16_t wSize);

#define	MAXUSAGE 64
#define	MAXPUSH 4
#define	MAXID 16

struct hid_pos_data {
	int32_t rid;
	uint32_t pos;
};

struct hid_data {
	const uint8_t *start;
	const uint8_t *end;
	const uint8_t *p;
	struct hid_item cur[MAXPUSH];
	struct hid_pos_data last_pos[MAXID];
	int32_t	usages_min[MAXUSAGE];
	int32_t	usages_max[MAXUSAGE];
	int32_t usage_last;	/* last seen usage */
	uint32_t loc_size;	/* last seen size */
	uint32_t loc_count;	/* last seen count */
	uint8_t	kindset;	/* we have 5 kinds so 8 bits are enough */
	uint8_t	pushlevel;	/* current pushlevel */
	uint8_t	ncount;		/* end usage item count */
	uint8_t icount;		/* current usage item count */
	uint8_t	nusage;		/* end "usages_min/max" index */
	uint8_t	iusage;		/* current "usages_min/max" index */
	uint8_t ousage;		/* current "usages_min/max" offset */
	uint8_t	susage;		/* usage set flags */
};

/*------------------------------------------------------------------------*
 *	hid_clear_local
 *------------------------------------------------------------------------*/
static void
hid_clear_local(struct hid_item *c)
{

	c->loc.count = 0;
	c->loc.size = 0;
	c->usage = 0;
	c->usage_minimum = 0;
	c->usage_maximum = 0;
	c->designator_index = 0;
	c->designator_minimum = 0;
	c->designator_maximum = 0;
	c->string_index = 0;
	c->string_minimum = 0;
	c->string_maximum = 0;
	c->set_delimiter = 0;
}

static void
hid_switch_rid(struct hid_data *s, struct hid_item *c, int32_t next_rID)
{
	uint8_t i;

	/* check for same report ID - optimise */

	if (c->report_ID == next_rID)
		return;

	/* save current position for current rID */

	if (c->report_ID == 0) {
		i = 0;
	} else {
		for (i = 1; i != MAXID; i++) {
			if (s->last_pos[i].rid == c->report_ID)
				break;
			if (s->last_pos[i].rid == 0)
				break;
		}
	}
	if (i != MAXID) {
		s->last_pos[i].rid = c->report_ID;
		s->last_pos[i].pos = c->loc.pos;
	}

	/* store next report ID */

	c->report_ID = next_rID;

	/* lookup last position for next rID */

	if (next_rID == 0) {
		i = 0;
	} else {
		for (i = 1; i != MAXID; i++) {
			if (s->last_pos[i].rid == next_rID)
				break;
			if (s->last_pos[i].rid == 0)
				break;
		}
	}
	if (i != MAXID) {
		s->last_pos[i].rid = next_rID;
		c->loc.pos = s->last_pos[i].pos;
	} else {
		DPRINTF("Out of RID entries, position is set to zero!\n");
		c->loc.pos = 0;
	}
}

/*------------------------------------------------------------------------*
 *	hid_start_parse
 *------------------------------------------------------------------------*/
struct hid_data *
hid_start_parse(const void *d, usb_size_t len, int kindset)
{
	struct hid_data *s;

	if ((kindset-1) & kindset) {
		DPRINTFN(0, "Only one bit can be "
		    "set in the kindset\n");
		return (NULL);
	}

	s = malloc(sizeof *s, M_TEMP, M_WAITOK | M_ZERO);
	s->start = s->p = d;
	s->end = ((const uint8_t *)d) + len;
	s->kindset = kindset;
	return (s);
}

/*------------------------------------------------------------------------*
 *	hid_end_parse
 *------------------------------------------------------------------------*/
void
hid_end_parse(struct hid_data *s)
{
	if (s == NULL)
		return;

	free(s, M_TEMP);
}

/*------------------------------------------------------------------------*
 *	get byte from HID descriptor
 *------------------------------------------------------------------------*/
static uint8_t
hid_get_byte(struct hid_data *s, const uint16_t wSize)
{
	const uint8_t *ptr;
	uint8_t retval;

	ptr = s->p;

	/* check if end is reached */
	if (ptr == s->end)
		return (0);

	/* read out a byte */
	retval = *ptr;

	/* check if data pointer can be advanced by "wSize" bytes */
	if ((s->end - ptr) < wSize)
		ptr = s->end;
	else
		ptr += wSize;

	/* update pointer */
	s->p = ptr;

	return (retval);
}

/*------------------------------------------------------------------------*
 *	hid_get_item
 *------------------------------------------------------------------------*/
int
hid_get_item(struct hid_data *s, struct hid_item *h)
{
	struct hid_item *c;
	unsigned int bTag, bType, bSize;
	uint32_t oldpos;
	int32_t mask;
	int32_t dval;

	if (s == NULL)
		return (0);

	c = &s->cur[s->pushlevel];

 top:
	/* check if there is an array of items */
	if (s->icount < s->ncount) {
		/* get current usage */
		if (s->iusage < s->nusage) {
			dval = s->usages_min[s->iusage] + s->ousage;
			c->usage = dval;
			s->usage_last = dval;
			if (dval == s->usages_max[s->iusage]) {
				s->iusage ++;
				s->ousage = 0;
			} else {
				s->ousage ++;
			}
		} else {
			DPRINTFN(1, "Using last usage\n");
			dval = s->usage_last;
		}
		s->icount ++;
		/* 
		 * Only copy HID item, increment position and return
		 * if correct kindset!
		 */
		if (s->kindset & (1 << c->kind)) {
			*h = *c;
			DPRINTFN(1, "%lu,%lu,%lu\n", h->loc.pos,
			    h->loc.size, h->loc.count);
			c->loc.pos += c->loc.size * c->loc.count;
			return (1);
		}
	}

	/* reset state variables */
	s->icount = 0;
	s->ncount = 0;
	s->iusage = 0;
	s->nusage = 0;
	s->susage = 0;
	s->ousage = 0;
	hid_clear_local(c);

	/* get next item */
	while (s->p != s->end) {

		bSize = hid_get_byte(s, 1);
		if (bSize == 0xfe) {
			/* long item */
			bSize = hid_get_byte(s, 1);
			bSize |= hid_get_byte(s, 1) << 8;
			bTag = hid_get_byte(s, 1);
			bType = 0xff;	/* XXX what should it be */
		} else {
			/* short item */
			bTag = bSize >> 4;
			bType = (bSize >> 2) & 3;
			bSize &= 3;
			if (bSize == 3)
				bSize = 4;
		}
		switch (bSize) {
		case 0:
			dval = 0;
			mask = 0;
			break;
		case 1:
			dval = (int8_t)hid_get_byte(s, 1);
			mask = 0xFF;
			break;
		case 2:
			dval = hid_get_byte(s, 1);
			dval |= hid_get_byte(s, 1) << 8;
			dval = (int16_t)dval;
			mask = 0xFFFF;
			break;
		case 4:
			dval = hid_get_byte(s, 1);
			dval |= hid_get_byte(s, 1) << 8;
			dval |= hid_get_byte(s, 1) << 16;
			dval |= hid_get_byte(s, 1) << 24;
			mask = 0xFFFFFFFF;
			break;
		default:
			dval = hid_get_byte(s, bSize);
			DPRINTFN(0, "bad length %u (data=0x%02lx)\n",
			    bSize, dval);
			continue;
		}

		switch (bType) {
		case 0:		/* Main */
			switch (bTag) {
			case 8:	/* Input */
				c->kind = hid_input;
				c->flags = dval;
		ret:
				c->loc.count = s->loc_count;
				c->loc.size = s->loc_size;

				if (c->flags & HIO_VARIABLE) {
					/* range check usage count */
					if (c->loc.count > 255) {
						DPRINTFN(0, "Number of "
						    "items truncated to 255\n");
						s->ncount = 255;
					} else
						s->ncount = c->loc.count;

					/* 
					 * The "top" loop will return
					 * one and one item:
					 */
					c->loc.count = 1;
				} else {
					s->ncount = 1;
				}
				goto top;

			case 9:	/* Output */
				c->kind = hid_output;
				c->flags = dval;
				goto ret;
			case 10:	/* Collection */
				c->kind = hid_collection;
				c->collection = dval;
				c->collevel++;
				c->usage = s->usage_last;
				*h = *c;
				return (1);
			case 11:	/* Feature */
				c->kind = hid_feature;
				c->flags = dval;
				goto ret;
			case 12:	/* End collection */
				c->kind = hid_endcollection;
				if (c->collevel == 0) {
					DPRINTFN(0, "invalid end collection\n");
					return (0);
				}
				c->collevel--;
				*h = *c;
				return (1);
			default:
				DPRINTFN(0, "Main bTag=%d\n", bTag);
				break;
			}
			break;
		case 1:		/* Global */
			switch (bTag) {
			case 0:
				c->_usage_page = dval << 16;
				break;
			case 1:
				c->logical_minimum = dval;
				break;
			case 2:
				c->logical_maximum = dval;
				break;
			case 3:
				c->physical_minimum = dval;
				break;
			case 4:
				c->physical_maximum = dval;
				break;
			case 5:
				c->unit_exponent = dval;
				break;
			case 6:
				c->unit = dval;
				break;
			case 7:
				/* mask because value is unsigned */
				s->loc_size = dval & mask;
				break;
			case 8:
				hid_switch_rid(s, c, dval);
				break;
			case 9:
				/* mask because value is unsigned */
				s->loc_count = dval & mask;
				break;
			case 10:	/* Push */
				s->pushlevel ++;
				if (s->pushlevel < MAXPUSH) {
					s->cur[s->pushlevel] = *c;
					/* store size and count */
					c->loc.size = s->loc_size;
					c->loc.count = s->loc_count;
					/* update current item pointer */
					c = &s->cur[s->pushlevel];
				} else {
					DPRINTFN(0, "Cannot push "
					    "item @ %d\n", s->pushlevel);
				}
				break;
			case 11:	/* Pop */
				s->pushlevel --;
				if (s->pushlevel < MAXPUSH) {
					/* preserve position */
					oldpos = c->loc.pos;
					c = &s->cur[s->pushlevel];
					/* restore size and count */
					s->loc_size = c->loc.size;
					s->loc_count = c->loc.count;
					/* set default item location */
					c->loc.pos = oldpos;
					c->loc.size = 0;
					c->loc.count = 0;
				} else {
					DPRINTFN(0, "Cannot pop "
					    "item @ %d\n", s->pushlevel);
				}
				break;
			default:
				DPRINTFN(0, "Global bTag=%d\n", bTag);
				break;
			}
			break;
		case 2:		/* Local */
			switch (bTag) {
			case 0:
				if (bSize != 4)
					dval = (dval & mask) | c->_usage_page;

				/* set last usage, in case of a collection */
				s->usage_last = dval;

				if (s->nusage < MAXUSAGE) {
					s->usages_min[s->nusage] = dval;
					s->usages_max[s->nusage] = dval;
					s->nusage ++;
				} else {
					DPRINTFN(0, "max usage reached\n");
				}

				/* clear any pending usage sets */
				s->susage = 0;
				break;
			case 1:
				s->susage |= 1;

				if (bSize != 4)
					dval = (dval & mask) | c->_usage_page;
				c->usage_minimum = dval;

				goto check_set;
			case 2:
				s->susage |= 2;

				if (bSize != 4)
					dval = (dval & mask) | c->_usage_page;
				c->usage_maximum = dval;

			check_set:
				if (s->susage != 3)
					break;

				/* sanity check */
				if ((s->nusage < MAXUSAGE) &&
				    (c->usage_minimum <= c->usage_maximum)) {
					/* add usage range */
					s->usages_min[s->nusage] = 
					    c->usage_minimum;
					s->usages_max[s->nusage] = 
					    c->usage_maximum;
					s->nusage ++;
				} else {
					DPRINTFN(0, "Usage set dropped\n");
				}
				s->susage = 0;
				break;
			case 3:
				c->designator_index = dval;
				break;
			case 4:
				c->designator_minimum = dval;
				break;
			case 5:
				c->designator_maximum = dval;
				break;
			case 7:
				c->string_index = dval;
				break;
			case 8:
				c->string_minimum = dval;
				break;
			case 9:
				c->string_maximum = dval;
				break;
			case 10:
				c->set_delimiter = dval;
				break;
			default:
				DPRINTFN(0, "Local bTag=%d\n", bTag);
				break;
			}
			break;
		default:
			DPRINTFN(0, "default bType=%d\n", bType);
			break;
		}
	}
	return (0);
}

/*------------------------------------------------------------------------*
 *	hid_report_size
 *------------------------------------------------------------------------*/
int
hid_report_size(const void *buf, usb_size_t len, enum hid_kind k, uint8_t *id)
{
	struct hid_data *d;
	struct hid_item h;
	uint32_t temp;
	uint32_t hpos;
	uint32_t lpos;
	uint8_t any_id;

	any_id = 0;
	hpos = 0;
	lpos = 0xFFFFFFFF;

	for (d = hid_start_parse(buf, len, 1 << k); hid_get_item(d, &h);) {
		if (h.kind == k) {
			/* check for ID-byte presense */
			if ((h.report_ID != 0) && !any_id) {
				if (id != NULL)
					*id = h.report_ID;
				any_id = 1;
			}
			/* compute minimum */
			if (lpos > h.loc.pos)
				lpos = h.loc.pos;
			/* compute end position */
			temp = h.loc.pos + (h.loc.size * h.loc.count);
			/* compute maximum */
			if (hpos < temp)
				hpos = temp;
		}
	}
	hid_end_parse(d);

	/* safety check - can happen in case of currupt descriptors */
	if (lpos > hpos)
		temp = 0;
	else
		temp = hpos - lpos;

	/* check for ID byte */
	if (any_id)
		temp += 8;
	else if (id != NULL)
		*id = 0;

	/* return length in bytes rounded up */
	return ((temp + 7) / 8);
}

/*------------------------------------------------------------------------*
 *	hid_locate
 *------------------------------------------------------------------------*/
int
hid_locate(const void *desc, usb_size_t size, uint32_t u, enum hid_kind k,
    uint8_t index, struct hid_location *loc, uint32_t *flags, uint8_t *id)
{
	struct hid_data *d;
	struct hid_item h;

	for (d = hid_start_parse(desc, size, 1 << k); hid_get_item(d, &h);) {
		if (h.kind == k && !(h.flags & HIO_CONST) && h.usage == u) {
			if (index--)
				continue;
			if (loc != NULL)
				*loc = h.loc;
			if (flags != NULL)
				*flags = h.flags;
			if (id != NULL)
				*id = h.report_ID;
			hid_end_parse(d);
			return (1);
		}
	}
	if (loc != NULL)
		loc->size = 0;
	if (flags != NULL)
		*flags = 0;
	if (id != NULL)
		*id = 0;
	hid_end_parse(d);
	return (0);
}

/*------------------------------------------------------------------------*
 *	hid_get_data
 *------------------------------------------------------------------------*/
static uint32_t
hid_get_data_sub(const uint8_t *buf, usb_size_t len, struct hid_location *loc,
    int is_signed)
{
	uint32_t hpos = loc->pos;
	uint32_t hsize = loc->size;
	uint32_t data;
	uint32_t rpos;
	uint8_t n;

	DPRINTFN(11, "hid_get_data: loc %ld/%ld\n", hpos, hsize);

	/* Range check and limit */
	if (hsize == 0)
		return (0);
	if (hsize > 32)
		hsize = 32;

	/* Get data in a safe way */	
	data = 0;
	rpos = (hpos / 8);
	n = (hsize + 7) / 8;
	rpos += n;
	while (n--) {
		rpos--;
		if (rpos < len)
			data |= buf[rpos] << (8 * n);
	}

	/* Correctly shift down data */
	data = (data >> (hpos % 8));
	n = 32 - hsize;

	/* Mask and sign extend in one */
	if (is_signed != 0)
		data = (int32_t)((int32_t)data << n) >> n;
	else
		data = (uint32_t)((uint32_t)data << n) >> n;

	DPRINTFN(11, "hid_get_data: loc %ld/%ld = %lu\n",
	    loc->pos, loc->size, (long)data);
	return (data);
}

int32_t
hid_get_data(const uint8_t *buf, usb_size_t len, struct hid_location *loc)
{
	return (hid_get_data_sub(buf, len, loc, 1));
}

uint32_t
hid_get_data_unsigned(const uint8_t *buf, usb_size_t len, struct hid_location *loc)
{
        return (hid_get_data_sub(buf, len, loc, 0));
}

/*------------------------------------------------------------------------*
 *	hid_is_collection
 *------------------------------------------------------------------------*/
int
hid_is_collection(const void *desc, usb_size_t size, uint32_t usage)
{
	struct hid_data *hd;
	struct hid_item hi;
	int err;

	hd = hid_start_parse(desc, size, hid_input);
	if (hd == NULL)
		return (0);

	while ((err = hid_get_item(hd, &hi))) {
		 if (hi.kind == hid_collection &&
		     hi.usage == usage)
			break;
	}
	hid_end_parse(hd);
	return (err);
}

/*------------------------------------------------------------------------*
 *	hid_get_descriptor_from_usb
 *
 * This function will search for a HID descriptor between two USB
 * interface descriptors.
 *
 * Return values:
 * NULL: No more HID descriptors.
 * Else: Pointer to HID descriptor.
 *------------------------------------------------------------------------*/
struct usb_hid_descriptor *
hid_get_descriptor_from_usb(struct usb_config_descriptor *cd,
    struct usb_interface_descriptor *id)
{
	struct usb_descriptor *desc = (void *)id;

	if (desc == NULL) {
		return (NULL);
	}
	while ((desc = usb_desc_foreach(cd, desc))) {
		if ((desc->bDescriptorType == UDESC_HID) &&
		    (desc->bLength >= USB_HID_DESCRIPTOR_SIZE(0))) {
			return (void *)desc;
		}
		if (desc->bDescriptorType == UDESC_INTERFACE) {
			break;
		}
	}
	return (NULL);
}

/*------------------------------------------------------------------------*
 *	usbd_req_get_hid_desc
 *
 * This function will read out an USB report descriptor from the USB
 * device.
 *
 * Return values:
 * NULL: Failure.
 * Else: Success. The pointer should eventually be passed to free().
 *------------------------------------------------------------------------*/
usb_error_t
usbd_req_get_hid_desc(struct usb_device *udev, struct mtx *mtx,
    void **descp, uint16_t *sizep,
    struct malloc_type *mem, uint8_t iface_index)
{
	struct usb_interface *iface = usbd_get_iface(udev, iface_index);
	struct usb_hid_descriptor *hid;
	usb_error_t err;

	if ((iface == NULL) || (iface->idesc == NULL)) {
		return (USB_ERR_INVAL);
	}
	hid = hid_get_descriptor_from_usb
	    (usbd_get_config_descriptor(udev), iface->idesc);

	if (hid == NULL) {
		return (USB_ERR_IOERROR);
	}
	*sizep = UGETW(hid->descrs[0].wDescriptorLength);
	if (*sizep == 0) {
		return (USB_ERR_IOERROR);
	}
	if (mtx)
		mtx_unlock(mtx);

	*descp = malloc(*sizep, mem, M_ZERO | M_WAITOK);

	if (mtx)
		mtx_lock(mtx);

	if (*descp == NULL) {
		return (USB_ERR_NOMEM);
	}
	err = usbd_req_get_report_descriptor
	    (udev, mtx, *descp, *sizep, iface_index);

	if (err) {
		free(*descp, mem);
		*descp = NULL;
		return (err);
	}
	return (USB_ERR_NORMAL_COMPLETION);
}
