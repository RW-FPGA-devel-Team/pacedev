#ifndef __KL_DAT_H__
#define __KL_DAT_H__

#include "osd_types.h"

typedef enum
{
  GFX_NOTDEFINED,
  GFX_CPC,
  GFX_ZX,
  GFX_ZX_MICK_FARROW
  
} GFX_E;

extern GFX_E gfx;
#define IS_ZX(g)  ((g==GFX_ZX)|(g==GFX_ZX_MICK_FARROW))

// ZX Spectrum attributes
#define ATTR_BLACK          0
#define ATTR_BLUE           1
#define ATTR_RED            2
#define ATTR_MAGENTA        3
#define ATTR_GREEN          4
#define ATTR_CYAN           5
#define ATTR_YELLOW         6
#define ATTR_WHITE          7

#define BRIGHT(a)           (0x40|(a))

// CPC attributes
#define ROOM_ATTR(n)        (128+n)
#define IS_ROOM_ATTR(n)     (((n)&128) != 0)

typedef struct
{
  uint8_t   x;
  uint8_t   y;
  uint8_t   z;
  
} ROOM_SIZE_T, *PROOM_SIZE_T;
  
typedef struct
{
  uint8_t   graphic_no;
  uint8_t   start_x;
  uint8_t   start_y;
  uint8_t   start_z;
  uint8_t   start_scrn;
  uint8_t   curr_x;
  uint8_t   curr_y;
  uint8_t   curr_z;
  uint8_t   curr_scrn;

} SPECOBJ, *PSPECOBJ;

typedef struct
{
  uint8_t   graphic_no;
  uint8_t   flags7;
  uint16_t  ptr_obj_tbl_entry;
  
} INVENTORY, *PINVENTORY;

typedef struct
{
  uint8_t   graphic_no;
  uint8_t   x;
  uint8_t   y;
  uint8_t   z;
  uint8_t   width;
  uint8_t   depth;
  uint8_t   height;
  uint8_t   flags7;
  uint8_t   scrn;
  int8_t    d_x;
  int8_t    d_y;
  int8_t    d_z;
  uint8_t   flags12;
  uint8_t   flags13;
  uint8_t   d_x_adj;
  uint8_t   d_y_adj;
  // originally a pointer, now an index
  union
  {
    uint16_t  ptr_obj_tbl_entry;
    uint16_t  plyr_graphic_no;
  } u;  
  int8_t    pixel_x_adj;
  int8_t    pixel_y_adj;
  uint8_t   unused[2];
  
  // added for C implementation (was unused[4])
  uint8_t   index;
  uint8_t   hw_sprite;
  
  uint8_t   data_width_bytes;
  uint8_t   data_height_lines;
  uint8_t   pixel_x;
  uint8_t   pixel_y;
  // used for wiping the sprite
  uint8_t   old_data_width_bytes;
  uint8_t   old_data_height_lines;
  uint8_t   old_pixel_x;
  uint8_t   old_pixel_y;

} OBJ32, *POBJ32;

typedef struct
{
  uint8_t   attr;
  char      text[32];
  
} RATING, *PRATING;

extern const uint8_t kl_font[][8];
extern const ROOM_SIZE_T room_size_tbl[];
extern const uint8_t location_tbl[];
extern uint8_t const *block_type_tbl[];
//extern uint8_t const *background_type_tbl[];
extern SPECOBJ special_objs_tbl_rom[];
//extern const uint8_t *sprite_tbl[];
extern const uint8_t start_game_tune[];
extern const uint8_t game_over_tune[];
extern const uint8_t game_complete_tune[];
extern const uint8_t menu_tune[];
extern const uint8_t cauldron_bubbles[];
extern const uint8_t complete_colours[];
extern const uint8_t complete_xy[];
extern const char *complete_text[];
extern const uint8_t gameover_colours[];
extern const uint8_t gameover_xy[];
extern char const *gameover_text[];
extern const uint8_t object_attributes[];
extern const RATING rating_tbl[];
extern const uint8_t day_txt[];
//extern const uint8_t days_font[][8];
#define day_font kl_font
extern const uint8_t menu_colours[];
extern const uint8_t menu_xy[];
extern char const *menu_text[];
extern uint8_t objects_required_rom[];
extern const uint8_t sun_moon_yoff[];
extern const uint8_t plyr_spr_init_data[];
extern const uint8_t start_locations[];
//extern const uint8_t panel_data[];
//extern const uint8_t border_data[][4];

#include "cpc_dat.h"
#include "mf_dat.h"
#include "zx_dat.h"

#endif // __KL_DAT_H__
