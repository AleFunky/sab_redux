             
             include code\handlePlayerData.asm   ; handle management of player data
             
             
_ReadJoypads: 
             lda OperMode
             beq +
             lda SavedJoypad1Bits
             sta OldSavedJoypadBits
+:              lda #$01               ;reset and clear strobe of joypad ports
             sta JOYPAD_PORT
             lsr
             tax                    ;start with joypad 1's port
             sta JOYPAD_PORT
             ;jsr ReadPortBits
             ;inx                   ;increment for joypad 2's port
ReadPortBits: ldy #$08
PortLoop:     pha                    ;push previous bit onto stack
             lda JOYPAD_PORT,x      ;read current bit on joypad port
             sta $00                ;check d1 and d0 of port output
             lsr                    ;this is necessary on the old
             ora $00                ;famicom systems in japan
             lsr
             pla                    ;read bits from stack
             rol                    ;rotate bit from carry flag
             dey
             bne PortLoop           ;count down bits left
             sta SavedJoypadBits,x  ;save controller status here always
             sta JoypadBitMask,x    ;save with all bits in another place and leave
             rts
             
             
D7_Attributes:
             .db $67, $65, $74, $20, $74
             .db $72, $6F, $6C, $6C, $65
             .db $64, $20, $62, $79, $20
             .db $20, $73, $74, $75, $64
             .db $73, $58, $ff, $ff, $ff
             
_InitializeNameTables:
             lda PPU_STATUS            ;reset flip-flop
             lda Mirror_PPU_CTRL_REG1  ;load mirror of ppu reg $2000
             ora #%00001000            ;set sprites for first 4k and background for second 4k
             and #%11101000            ;clear rest of lower nybble, leave higher alone
             sta PPU_CTRL_REG1         ;write contents of A to PPU register 1
             sta Mirror_PPU_CTRL_REG1  ;and its mirror
             lda #$24                  ;set vram address to start of name table 1
             jsr WriteNTAddr
             lda #$28                  ;set vram address to start of name table 2
             jsr WriteNTAddr
             lda #$2c
             jsr WriteNTAddr
             lda #$20                  ;and then set it to name table 0
WriteNTAddr:  sta PPU_ADDRESS
             lda #$00
             sta PPU_ADDRESS
             ldx #$04                  ;clear name table with blank tile #24
             ldy #$c0
             lda #$24
InitNTLoop:   sta PPU_DATA              ;count out exactly 768 tiles
             dey
             bne InitNTLoop
             dex
             bne InitNTLoop
             ldy #64                   ;now to clear the attribute table (with zero this time)
             txa
             sta VRAM_Buffer1_Offset   ;init vram buffer 1 offset
             sta VRAM_Buffer1          ;init vram buffer 1
             lda #%10101010
InitATLoop:   sta PPU_DATA
             dey
             bne InitATLoop
             lda #$00
             sta HorizontalScroll      ;reset scroll variables
             sta VerticalScroll
             jmp InitScroll            ;initialize scroll registers to zero
             
             
DemoActionData:
             .db $01, $80, $02, $81, $41, $80, $01
             .db $42, $c2, $02, $80, $41, $c1, $41, $c1
             .db $01, $c1, $01, $02, $80, $00
             
DemoTimingData:
             .db $9b, $10, $18, $05, $2c, $20, $24
             .db $15, $5a, $10, $20, $28, $30, $20, $10
             .db $80, $20, $30, $30, $01, $ff, $00
             
_DemoEngine:
             ldx DemoAction         ;load current demo action
             lda DemoActionTimer    ;load current action timer
             bne DoAction           ;if timer still counting down, skip
             inx
             inc DemoAction         ;if expired, increment action, X, and
             sec                    ;set carry by default for demo over
             lda DemoTimingData-1,x ;get next timer
             sta DemoActionTimer    ;store as current timer
             beq DemoOver           ;if timer already at zero, skip
DoAction: lda DemoActionData-1,x ;get and perform action (current or next)
             sta SavedJoypad1Bits
             if TEST_LUIGI
             sta SavedJoypad2Bits
             endif
             dec DemoActionTimer    ;decrement action timer
             clc                    ;clear carry if demo still going
DemoOver: rts
             
             
