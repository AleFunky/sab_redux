;File: 'test.t.asm
;Map Type: Multi Page [width: 256,height: 13] 
;Exported: Using Tiled(Assembly 6502) plugin by Haseeb Mir

.org $8000

test.t_page0
.db #00,#00,#00,#69,#69,#69,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#70,#71,#72,#00,#00,#00,#00,#128,#129,#129,#129,#130,#00
.db #00,#00,#69,#73,#73,#73,#69,#00,#00,#00,#131,#132,#132,#132,#133,#00
.db #00,#00,#71,#71,#74,#71,#71,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#71,#71,#75,#112,#71,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #69,#69,#73,#73,#73,#73,#73,#69,#69,#00,#00,#00,#00,#00,#00,#00
.db #71,#71,#71,#74,#71,#74,#71,#71,#71,#00,#00,#00,#00,#00,#00,#00
.db #71,#71,#71,#75,#71,#75,#71,#71,#71,#00,#00,#00,#00,#00,#00,#00
.db #71,#71,#71,#71,#71,#71,#71,#71,#71,#00,#00,#00,#00,#00,#00,#00
.db #71,#71,#74,#71,#74,#71,#74,#71,#71,#00,#00,#00,#00,#00,#00,#97
.db #71,#71,#75,#112,#75,#71,#75,#71,#71,#00,#00,#77,#77,#77,#97,#97
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214

test.t_page1
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#129
.db #00,#00,#00,#00,#128,#129,#129,#129,#130,#217,#218,#219,#00,#131,#132,#132
.db #00,#00,#00,#00,#131,#132,#132,#132,#133,#00,#78,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#194,#194,#00,#00,#00,#78,#00,#194,#194,#00,#00
.db #00,#00,#00,#00,#194,#00,#00,#194,#00,#00,#78,#00,#00,#00,#194,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#78,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#214,#214,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#214,#214,#214,#00,#00,#00,#00,#00
.db #204,#205,#214,#214,#00,#00,#00,#00,#214,#214,#214,#00,#00,#00,#00,#00
.db #206,#215,#214,#214,#00,#00,#00,#00,#214,#214,#214,#00,#00,#00,#00,#00
.db #214,#214,#214,#214,#144,#144,#144,#144,#214,#214,#214,#144,#144,#144,#144,#144
.db #214,#214,#214,#214,#145,#145,#145,#145,#214,#214,#214,#145,#145,#145,#214,#214

test.t_page2
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#130,#00
.db #130,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#131,#132,#133,#00
.db #133,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#128,#129,#130,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#217,#218,#219,#131,#132,#133,#00,#00,#00,#00,#00,#81,#81
.db #00,#00,#00,#00,#78,#00,#00,#00,#00,#00,#204,#205,#00,#00,#00,#00
.db #00,#00,#00,#00,#78,#00,#00,#00,#00,#00,#206,#215,#00,#00,#00,#00
.db #00,#00,#00,#00,#78,#00,#204,#205,#00,#00,#206,#215,#77,#77,#00,#00
.db #00,#00,#00,#00,#78,#00,#206,#215,#00,#00,#214,#214,#214,#214,#214,#214
.db #00,#77,#77,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214

test.t_page3
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #192,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#130
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#131,#132,#133
.db #00,#00,#00,#00,#00,#128,#129,#129,#129,#130,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#131,#132,#132,#132,#133,#00,#00,#00,#192,#192,#00
.db #193,#81,#81,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#194,#194,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11,#11,#11,#11
.db #00,#00,#00,#77,#00,#00,#00,#00,#00,#00,#00,#00,#99,#99,#99,#99
.db #214,#214,#214,#214,#214,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#144,#144,#144,#144,#144,#144,#144
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#145,#145,#145,#145,#145,#145,#145
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#145,#145,#145,#145,#145,#145

test.t_page4
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#129,#129,#129,#130
.db #00,#00,#194,#00,#00,#00,#192,#192,#192,#00,#131,#132,#132,#132,#132,#133
.db #00,#194,#00,#194,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#11,#11,#11,#11,#11,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#99,#99,#99,#99,#99,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#77
.db #144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#214,#214
.db #145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#214,#214,#214,#214
.db #145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#214,#214,#214,#214,#214

test.t_page5
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#129,#129,#130,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#131,#132,#132,#132,#133,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#194,#194,#00,#00,#194,#194,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#194,#00,#00,#00,#00,#00,#00,#194,#00,#00,#00,#00,#00,#00
.db #217,#218,#219,#00,#00,#204,#205,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#78,#00,#00,#00,#206,#215,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#78,#00,#77,#77,#206,#215,#00,#00,#00,#00,#100,#00,#00,#00,#00
.db #00,#78,#214,#214,#214,#214,#214,#214,#214,#214,#00,#101,#00,#00,#00,#00
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#144,#144,#144,#144
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#145,#145,#145
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#145,#145
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#145

test.t_page6
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#128,#129,#130,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#131,#132,#133,#00,#00,#00,#00,#00,#00,#00,#00,#194,#194
.db #00,#00,#194,#00,#192,#192,#192,#00,#194,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11,#11,#11
.db #00,#11,#11,#11,#11,#11,#11,#11,#11,#11,#00,#00,#00,#99,#99,#99
.db #00,#99,#99,#99,#99,#99,#99,#99,#99,#99,#00,#00,#00,#00,#00,#00
.db #144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144
.db #145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145
.db #145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145
.db #145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145

test.t_page7
.db #00,#128,#129,#129,#130,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#131,#132,#132,#133,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #194,#194,#194,#194,#00,#00,#00,#00,#00,#128,#129,#129,#130,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#131,#132,#132,#133,#00,#204,#205
.db #00,#00,#00,#00,#00,#00,#00,#00,#100,#00,#00,#00,#00,#00,#206,#215
.db #11,#11,#11,#11,#11,#00,#00,#00,#101,#00,#00,#00,#214,#214,#214,#214
.db #99,#99,#99,#99,#99,#00,#00,#00,#102,#77,#77,#214,#214,#214,#214,#214
.db #00,#00,#00,#00,#00,#00,#00,#00,#102,#214,#214,#214,#214,#214,#214,#214
.db #144,#144,#144,#144,#144,#144,#144,#144,#214,#214,#214,#214,#214,#214,#214,#214
.db #145,#145,#145,#145,#145,#145,#145,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #145,#145,#145,#145,#145,#145,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #145,#145,#145,#145,#145,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214

test.t_page8
.db #128,#129,#130,#00,#00,#00,#00,#00,#00,#00,#00,#192,#00,#00,#00,#00
.db #131,#132,#133,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#129,#129
.db #00,#00,#00,#217,#218,#219,#00,#00,#00,#00,#00,#00,#131,#132,#132,#132
.db #00,#00,#192,#00,#78,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#78,#00,#00,#00,#00,#81,#192,#81,#193,#81,#00,#00
.db #00,#00,#00,#00,#78,#204,#205,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#78,#206,#215,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #214,#214,#214,#214,#214,#206,#215,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #214,#214,#214,#214,#214,#214,#214,#00,#77,#77,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214

test.t_page9
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #130,#00,#217,#218,#219,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #133,#00,#00,#78,#194,#194,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#78,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#78,#00,#00,#00,#00,#204,#205,#00,#00,#128,#129,#130,#00
.db #204,#205,#00,#78,#00,#00,#77,#77,#206,#215,#00,#00,#131,#132,#133,#00
.db #206,#215,#214,#214,#214,#214,#214,#214,#206,#215,#00,#00,#00,#00,#00,#00
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#77,#00,#00,#00,#00,#00
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#204,#205,#00,#00
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#206,#215,#00,#00
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#144,#144
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214

test.t_page10
.db #00,#00,#00,#128,#129,#129,#130,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#131,#132,#132,#133,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#193,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129
.db #00,#00,#00,#00,#194,#194,#00,#00,#00,#00,#00,#00,#00,#00,#131,#132
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#11,#11,#11,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#99,#99,#99,#00,#00
.db #00,#00,#00,#11,#11,#11,#11,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#99,#99,#99,#99,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144
.db #214,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145
.db #214,#214,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145

test.t_page11
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#129,#129,#130,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#131,#132,#132,#132,#133,#00
.db #129,#129,#130,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #132,#132,#133,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#217,#218
.db #00,#00,#00,#194,#194,#194,#194,#194,#00,#00,#00,#00,#00,#00,#00,#78
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#78
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#204,#205,#00,#78
.db #00,#00,#11,#11,#11,#11,#11,#11,#11,#00,#00,#77,#206,#215,#00,#78
.db #00,#00,#99,#99,#99,#99,#99,#99,#99,#214,#214,#214,#214,#214,#214,#214
.db #144,#144,#144,#144,#144,#144,#144,#144,#214,#214,#214,#214,#214,#214,#214,#214
.db #145,#145,#145,#145,#145,#145,#145,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #145,#145,#145,#145,#145,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214

test.t_page12
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #219,#00,#00,#00,#00,#128,#129,#130,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#131,#132,#133,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#204,#205,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#204,#205,#00,#00,#206,#215,#00,#00,#00
.db #77,#77,#00,#11,#11,#11,#11,#206,#215,#11,#11,#206,#215,#11,#11,#11
.db #214,#214,#214,#99,#99,#99,#99,#99,#99,#99,#99,#99,#99,#99,#99,#99
.db #214,#214,#214,#214,#214,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144
.db #214,#214,#214,#214,#214,#214,#214,#145,#145,#145,#145,#145,#145,#145,#145,#145

test.t_page13
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#128,#129,#129,#130,#00,#00,#00,#97,#97,#00,#00,#00,#128,#129,#129
.db #00,#131,#132,#132,#133,#00,#00,#97,#97,#97,#00,#00,#00,#131,#132,#132
.db #00,#00,#00,#00,#00,#00,#97,#97,#97,#97,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#97,#97,#97,#97,#97,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#97,#97,#97,#97,#97,#97,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#97,#97,#97,#97,#97,#97,#97,#00,#00,#00,#00,#00,#00
.db #00,#00,#97,#97,#97,#97,#97,#97,#97,#97,#00,#00,#00,#00,#00,#00
.db #11,#97,#97,#97,#97,#97,#97,#97,#97,#97,#00,#00,#00,#00,#00,#00
.db #99,#99,#99,#99,#99,#99,#99,#99,#99,#99,#00,#00,#00,#00,#00,#00
.db #144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144
.db #145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145

test.t_page14
.db #00,#00,#36,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#37,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #130,#00,#37,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #133,#00,#37,#00,#00,#128,#129,#129,#130,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#37,#00,#00,#131,#132,#132,#133,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#37,#00,#00,#69,#69,#69,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#37,#00,#00,#70,#71,#72,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#37,#00,#69,#73,#73,#73,#69,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#37,#00,#71,#71,#74,#71,#71,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#37,#11,#71,#71,#75,#112,#71,#11,#00,#00,#00,#00,#00,#00
.db #00,#00,#97,#99,#99,#99,#99,#99,#99,#99,#97,#00,#00,#00,#00,#00
.db #144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144,#144
.db #145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145,#145

test.t_page15
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #128,#129,#129,#129,#129,#130,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #131,#132,#132,#132,#132,#133,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#128,#129,#129,#130,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#131,#132,#132,#133,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#199,#199,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00,#00
.db #00,#00,#00,#00,#00,#00,#00,#00,#00,#77,#77,#77,#77,#00,#00,#214
.db #00,#00,#00,#00,#00,#00,#00,#00,#214,#214,#214,#214,#214,#214,#214,#214
.db #00,#00,#00,#00,#00,#00,#00,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #144,#144,#144,#144,#144,#144,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214
.db #145,#145,#145,#145,#145,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214,#214

IF 1 = 0
 .db PageSkip, #1

 .db #2 * $10 + 9, #64 + $80, $00

 .db #1 * $10 + 11, #3 + $80
 .db #6 * $10 + 9, #13
 .db #10 * $10 + 7, #13

 .db #1 * $10 + 9, #0 + $80
 .db #4 * $10 + 9, #0
 .db #14 * $10 + 8, #3

 .db #9 * $10 + 7, #0 + $80

 .db #4 * $10 + 8, #6 + $80
 .db #5 * $10 + 6, #32
 .db #11 * $10 + 8, #66

 .db #8 * $10 + 8, #6 + $80

 .db #2 * $10 + 7, #6 + $80
 .db #8 * $10 + 6, #66

 .db #2 * $10 + 7, #6 + $80
 .db #5 * $10 + 6, #32
 .db #13 * $10 + 8, #6

 .db #0 * $10 + 6, #32 + $80
 .db #5 * $10 + 6, #6
 .db #8 * $10 + 5, #13
 .db #12 * $10 + 9, #13

 .db #6 * $10 + 8, #3 + $80
 .db #13 * $10 + 6, #3

 .db #6 * $10 + 9, #0 + $80
 .db #9 * $10 + 9, #0
 .db #12 * $10 + 8, #13

 .db #4 * $10 + 10, #6 + $80
 .db #7 * $10 + 9, #32
 .db #11 * $10 + 8, #32

 .db #6 * $10 + 4, #0 + $80
 .db #7 * $10 + 3, #0

 .db #2 * $10 + 2, #48 + $80
 .db PageSkip, #16
ENDIF