/*****************************************************************************
* 2k C1 Internal ROM for APPLE 2E Initialized ALL 0XFF
******************************************************************************/
  sprom #(
  	.init_file		("../../../../src/platform/appleii-becker/roms/F8.hex"),
  	.numwords_a		(2048),
  	.widthad_a		(11)
  ) RAMB16_S9_F8 (
  	.address			(ADDRESS[10:0]),
  	.clock				(PH_2),
  	.q						(DOA_F8)
  );
