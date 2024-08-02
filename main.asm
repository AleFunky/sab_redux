             
             .db $4e, $45, $53, $1a                        ;  magic signature
             .db $10                                       ;  PRG ROM size in 16384 byte units
             .db $20                                       ;  CHR
             if BATTERY
             ;.db $4a                                       ;  mirroring type and mapper number lower nibble + battery
             .db $4a
             else
             .db $4a                                       ;  mirroring type and mapper number lower nibble
             endif
             .db $00                                       ;  mapper number upper nibble
             
             .db $00, $00, $00, $00, $00, $00, $00, $00
             
             ; We start at a weird address here because
             ; we're adding on to all this defined stuff.
             ; Needs cleanup.
             ;.base $07cb
             ;.base $0000
             
             include code\settings.default.asm               ; default settings
             include code\settings.asm                       ; local settings
             include code\macros.asm                         ; macros
             include code\zeropage.asm
             include code\constants.asm                      ; other constants
             include code\banks.asm                          ; Bank asignments
             
             
             include code\reset.asm
             include code\nmi.asm
             
VRAM_AddrTable_Low:
             .db <VRAM_Buffer1, <WaterPaletteData, <GroundPaletteData
             .db <UndergroundPaletteData, <CastlePaletteData, <VRAM_Buffer1_Offset
             .db <VRAM_Buffer2, <VRAM_Buffer2, <BowserPaletteData
             .db <DaySnowPaletteData, <NightSnowPaletteData, <MushroomPaletteData
             .db <MarioThanksMessage, <LuigiThanksMessage, <MushroomRetainerSaved
             .db <PrincessSaved1, <PrincessSaved2, <WorldSelectMessage1
             .db <WorldSelectMessage2, <MushRoomRetainerGlitchWorld
             
VRAM_AddrTable_High:
             .db >VRAM_Buffer1, >WaterPaletteData, >GroundPaletteData
             .db >UndergroundPaletteData, >CastlePaletteData, >VRAM_Buffer1_Offset
             .db >VRAM_Buffer2, >VRAM_Buffer2, >BowserPaletteData
             .db >DaySnowPaletteData, >NightSnowPaletteData, >MushroomPaletteData
             .db >MarioThanksMessage, >LuigiThanksMessage, >MushroomRetainerSaved
             .db >PrincessSaved1, >PrincessSaved2, >WorldSelectMessage1
             .db >WorldSelectMessage2, >MushRoomRetainerGlitchWorld
             
VRAM_Buffer_Offset:
             .db <VRAM_Buffer1_Offset, <VRAM_Buffer2_Offset
             
EnemiesAndLoopsCore:
             lda Enemy_Flag,x         ;check data here for MSB set
             bmi ChkBowserF           ;if MSB set in enemy flag, branch ahead of jumps
             beq ChkAreaTsk           ;if data zero, branch
             jmp RunEnemyObjectsCore  ;otherwise, jump to run enemy subroutines
ChkAreaTsk: lda AreaParserTaskNum    ;check number of tasks to perform
             and #$07
             cmp #$07                 ;if at a specific task, jump and leave
             beq ExitELCore
             jmp ProcLoopCommand1      ;otherwise, jump to process loop command/load enemies
ChkBowserF: and #%00001111           ;mask out high nybble
             tay
             lda Enemy_Flag,y         ;use as pointer and load same place with different offset
             bne ExitELCore
             sta Enemy_Flag,x         ;if second enemy flag not set, also clear first one
ExitELCore: rts
             
             
ChangeSizeOffsetAdder:
             .db $00, $01, $00, $01, $00, $01, $02, $00, $01, $02
             .db $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
             
             
             ;      .db $3f, $08, $04, $ff, $ff, $ff, $ff, $00
             
             ;     .db $0f, $30, $22, $0f 
             ;    .db $0f, $30, $21, $0f 
             ;   .db $0f, $30, $21, $0c
             ;   .db $0f, $30, $16, $2d
             
             ;rts
             ;beq ExitColorRot
             ;ldx VRAM_Buffer1_Offset  ;check vram buffer offset
             ;cpx #$31
             ;bcs ExitColorRot         ;if offset over 48 bytes, branch to leave
             ;ldy #$00
             ;sta VRAM_Buffer1,x       ;store it in the vram buffer
             ;inx                      ;increment offsets
             ;iny
             ;cpy #$08
             ;bcc GetBlankPal          ;do this until all bytes are copied
             ;ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
             ;lda #$03
             ;sta $00                  ;set counter here
             ;lda AreaType             ;get area type
             ;asl                      ;multiply by 4 to get proper offset
             ;asl
             ;tay                      ;save as offset here
;GetAreaPal:   ;lda Palette3Data,y       ;fetch palette to be written based on area type
             ;sta VRAM_Buffer1+3,x     ;store it to overwrite blank palette in vram buffer
             ;iny
             ; inx
             ; dec $00                  ;decrement counter
             ; bpl GetAreaPal           ;do this until the palette is all copied
             ; ldx VRAM_Buffer1_Offset  ;get current vram buffer offset
             ; ldy timerupthing          ;get color cycling offset
             ; lda ColorRotatePalette,y
             ; sta VRAM_Buffer1+4,x     ;get and store current color in second slot of palette
             ; lda VRAM_Buffer1_Offset
             ; clc                      ;add seven bytes to vram buffer offset
             ; adc #$07
             ; sta VRAM_Buffer1_Offset
             
RunEnemyObjectsCore:
+:       ldx ObjectOffset  ;get offset for enemy object buffer
             lda #$00          ;load value 0 for jump engine by default
             ldy Enemy_ID,x
             cpy #$15          ;if enemy object < $15, use default value
             bcc JmpEO
             tya               ;otherwise subtract $14 from the value and use
             sbc #$14          ;as value for jump engine
JmpEO: cmp #LastEnemyID+1-$14
             bcs NoRunCode
             jsr JumpEngine
             
             .dw RunNormalEnemies  ;for objects $00-$14
             
             .dw RunBowserFlame    ;15 for objects $15-$1f
             .dw RunFireworks        ;16
             .dw NoRunCode         ;17
             .dw NoRunCode         ;18
             .dw RunNormalEnemies  ;19
             .dw NoRunCode         ;1a
             .dw RunFirebarObj     ;1b
             .dw RunFirebarObj     ;1c
             .dw RunFirebarObj     ;1d
             .dw RunFirebarObj     ;1e
             .dw RunFirebarObj     ;1f
             
             .dw RunNormalEnemies  ;20 for objects $20-$2f
             .dw RunNormalEnemies  ;21
             .dw RunNormalEnemies  ;22
             .dw NoRunCode         ;23
             .dw RunLargePlatform  ;24
             .dw RunLargePlatform  ;25
             .dw RunLargePlatform  ;26
             .dw RunLargePlatform  ;27
             .dw RunLargePlatform  ;28
             .dw RunLargePlatform  ;29
             .dw RunLargePlatform  ;2a
             .dw RunSmallPlatform  ;2b
             .dw RunSmallPlatform  ;2c
             .dw RunBowser         ;2d
             .dw PowerUpObjHandler ;2e
             .dw VineObjectHandler ;2f
             
             .dw NoRunCode        ;30 for objects $30-$35
             .dw RunStarFlagObj   ;31
             .dw JumpspringHandler;32
             .dw NoRunCode        ;33
             .dw WarpZoneObject   ;34
             .dw RunRetainerObj   ;35
             .dw NoRunCode        ;36
             .dw NoRunCode        ;37
             .dw NoRunCode        ;38
             .dw NoRunCode           ;39
             .dw NoRunCode           ;3a
             .dw NoRunCode           ;3b
             .dw NoRunCode           ;3c
             .dw NoRunCode           ;3d
             .dw NoRunCode           ;3e
             .dw NoRunCode           ;3f
             .dw SignDo           ;40
             .dw NoRunCode           ;41
             .dw NoRunCode           ;42
             .dw NoRunCode           ;43
NoRunCode: rts
SignDo:
             jsr RunRetainerObj
             jsr GetEnemyBoundBox
             jsr OffscreenBoundsCheck
             jmp PlayerEnemyCollision
             
RunRetainerObj:
             jsr GetEnemyOffscreenBits
             jsr RelativeEnemyPosition
             jmp EnemyGfxHandler
             
             
RunNormalEnemies:
             lda #$00                  ;init sprite attributes
             sta Enemy_SprAttrib,x
             lda #$01                 ;set A to add 1 byte in order to get enemy offset
             tay                 ;set Y to put offscreen bits in Enemy_OffscreenBits
             stx $00
             clc           ;add contents of X to A to get
             adc $00       ;appropriate offset, then give back to X
             tax
             tya                         ;save offscreen bits offset to stack for now
             pha
             jsr GetXOffscreenBits  ;do subroutine here
             tay
             lda MSBtoLSB,y
             sta $00                ;store here
             jsr GetYOffscreenBits
             tay
             lda LSBtoMSB,y
             ora $00                     ;mask together with previously saved low nybble
             sta $00                     ;store both here
             pla                         ;get offscreen bits offset from stack
             tay
             lda $00                     ;get value here and store elsewhere
             sta SprObject_OffscrBits,y
             ldx ObjectOffset
             lda #$01                     ;get coordinates of enemy object 
             tay                     ;relative to the screen
             stx $00                     ;store value to add to A here
             clc
             adc $00                     ;add A to value stored
             tax                         ;use as enemy offset
             lda SprObject_Y_Position,x  ;load vertical coordinate low
             sta SprObject_Rel_YPos,y    ;store here
             lda SprObject_X_Position,x  ;load horizontal coordinate
             sec                         ;subtract left edge coordinate
             sbc ScreenLeft_X_Pos
             sta SprObject_Rel_XPos,y    ;store result here
             ldx ObjectOffset 
             jsr EnemyGfxHandler
             ldy #$48                 ;store bitmask here for now
             sty $00
             ldy #$44                 ;store another bitmask here for now and jump
             lda Enemy_X_Position,x      ;get enemy object position relative
             sec                         ;to the left side of the screen
             sbc ScreenLeft_X_Pos
             sta $01                     ;store here
             lda Enemy_PageLoc,x         ;subtract borrow from current page location
             sbc ScreenLeft_PageLoc      ;of left side
             bmi CMBit1                  ;if enemy object is beyond left edge, branch
             ora $01
             beq CMBit1                  ;if precisely at the left edge, branch
             ldy $00                     ;if to the right of left edge, use value in $00 for A
CMBit1:   tya                         ;otherwise use contents of Y
             and Enemy_OffscreenBits     ;preserve bitwise whatever's in here
             sta EnemyOffscrBitsMasked,x ;save masked offscreen bits here
             bne MoveBoundBoxOffscreen1   ;if anything set here, branch
             jsr SetupEOffsetFBBox       ;otherwise, do something else
             jmp +
MoveBoundBoxOffscreen1:
             txa                            ;multiply offset by 4
             asl
             asl
             tay                            ;use as offset here
             lda #$ff
             sta EnemyBoundingBoxCoord,y    ;load value into four locations here and leave
             sta EnemyBoundingBoxCoord+1,y
             sta EnemyBoundingBoxCoord+2,y
             sta EnemyBoundingBoxCoord+3,y
+:        lda Enemy_State,x
             and #%00100000
             bne +
             jsr EnemyToBGCollisionDet
             lda FrameCounter            ;check counter for d0 set
             lsr
             bcc ++
             jsr EnemiesCollision
             jmp +
             
++:       jsr PlayerEnemyCollision
+:        ldy TimerControl          ;if master timer control set, skip to last routine
             bne SkipMove
             jsr EnemyMovementSubs
             ldx ObjectOffset
SkipMove: jmp OffscreenBoundsCheck
MovePiranhaPlant1:
             jmp MovePiranhaPlant
MoveUpsideDownPiranhaP1:
             jmp MoveUpsideDownPiranhaP
EnemyMovementSubs:
             ldx ObjectOffset
             lda Enemy_ID,x
             cmp #LastEnemyID+1-$14
             bcs NoMoveCode
             jsr JumpEngine
             
             .dw MoveNormalEnemy                  ;00 only objects $00-$14 use this table
             .dw MoveNormalEnemy                ;01
             .dw MoveNormalEnemy               ;02
             .dw MoveNormalEnemy               ;03
             .dw MoveNormalEnemy               ;04
             .dw ProcHammerBro                 ;05
             .dw MoveNormalEnemy               ;06
             .dw MoveBloober                   ;07
             .dw MoveBulletBill                ;08
             .dw MoveNormalEnemy               ;09
             .dw MoveSwimmingCheepCheep        ;0a
             .dw MoveSwimmingCheepCheep        ;0b
             .dw MovePodoboo                   ;0c
             .dw MovePiranhaPlant              ;0d
             .dw MoveJumpingEnemy              ;0e
             .dw ProcMoveRedPTroopa            ;0f
             .dw MoveFlyGreenPTroopa           ;10
             .dw MoveLakitu                    ;11
             .dw MoveNormalEnemy               ;12
             .dw MoveJumpingEnemy   ;dummy     ;13
             .dw MoveFlyingCheepCheep          ;14
             .dw NoMoveCode                    ;15
             .dw NoMoveCode                    ;16
             .dw NoMoveCode                    ;17
             .dw NoMoveCode                    ;18
             .dw MoveNormalEnemy               ;19
             .dw MoveUpsideDownPiranhaP        ;1a
             .dw MoveUpsideDownPiranhaP        ;1b
             .dw NoMoveCode                    ;1c
             .dw NoMoveCode                    ;1d
             .dw NoMoveCode                    ;1e
             .dw NoMoveCode                    ;1f
             .dw MovePiranhaPlant1                ;20
             .dw MoveUpsideDownPiranhaP1        ;21
             .dw MoveUpsideDownPiranhaP1        ;22
             
             
             
NoMoveCode:
             rts
             
             
RunBowserFlame:
             jsr ProcBowserFlame
             jsr GetEnemyOffscreenBits
             jsr RelativeEnemyPosition
             jsr GetEnemyBoundBox
             jsr PlayerEnemyCollision
             jmp OffscreenBoundsCheck
             
             
RunFirebarObj:
             jsr ProcFirebar
             jmp OffscreenBoundsCheck
             
             
RunSmallPlatform:
             jsr GetEnemyOffscreenBits
             jsr RelativeEnemyPosition
             jsr SmallPlatformBoundBox
             jsr SmallPlatformCollision
             jsr RelativeEnemyPosition
             ldy Enemy_SprDataOffset,x   ;get OAM data offset
             lda #$eb                    ;load tile number for small platforms
             iny                         ;increment offset for tile numbers
             sta Sprite_Data+20,y      ;dump A contents
             sta Sprite_Data+16,y      ;into third row sprites
             sta Sprite_Data+12,y      ;into second row sprites
             sta Sprite_Data+8,y
             sta Sprite_Data+4,y       ;and into first row sprites
             sta Sprite_Data,y               ;dump tile number into all six sprites
             iny                         ;increment offset for attributes
             lda #$02                    ;load palette controls
             sta Sprite_Data+20,y      ;dump A contents
             sta Sprite_Data+16,y      ;into third row sprites
             sta Sprite_Data+12,y      ;into second row sprites
             sta Sprite_Data+8,y
             sta Sprite_Data+4,y       ;and into first row sprites
             sta Sprite_Data,y                ;dump attributes into all six sprites
             dey                         ;decrement for original offset
             dey
             lda Enemy_Rel_XPos          ;get relative horizontal coordinate
             sta Sprite_X_Position,y
             sta Sprite_X_Position+12,y  ;dump as X coordinate into first and fourth sprites
             clc
             adc #$08                    ;add eight pixels
             sta Sprite_X_Position+4,y   ;dump into second and fifth sprites
             sta Sprite_X_Position+16,y
             clc
             adc #$08                    ;add eight more pixels
             sta Sprite_X_Position+8,y   ;dump into third and sixth sprites
             sta Sprite_X_Position+20,y
             lda Enemy_Y_Position,x      ;get vertical coordinate
             tax
             pha                         ;save to stack
             cpx #$20                    ;if vertical coordinate below status bar,
             bcs TopSP                   ;do not mess with it
             lda #$f8                    ;otherwise move first three sprites offscreen
TopSP: sta Sprite_Data+8,y
             sta Sprite_Data+4,y       ;and into first row sprites
             sta Sprite_Data,y              ;dump vertical coordinate into Y coordinates
             pla                         ;pull from stack
             clc
             adc #$80                    ;add 128 pixels
             tax
             cpx #$20                    ;if below status bar (taking wrap into account)
             bcs BotSP                   ;then do not change altered coordinate
             lda #$f8                    ;otherwise move last three sprites offscreen
BotSP: sta Sprite_Y_Position+12,y  ;dump vertical coordinate + 128 pixels
             sta Sprite_Y_Position+16,y  ;into Y coordinates
             sta Sprite_Y_Position+20,y
             lda Enemy_OffscreenBits     ;get offscreen bits
             pha                         ;save to stack
             and #%00001000              ;check d3
             beq SOfs
             lda #$f8                    ;if d3 was set, move first and
             sta Sprite_Y_Position,y     ;fourth sprites offscreen
             sta Sprite_Y_Position+12,y
SOfs:  pla                         ;move out and back into stack
             pha
             and #%00000100              ;check d2
             beq SOfs2
             lda #$f8                    ;if d2 was set, move second and
             sta Sprite_Y_Position+4,y   ;fifth sprites offscreen
             sta Sprite_Y_Position+16,y
SOfs2: pla                         ;get from stack
             and #%00000010              ;check d1
             beq ExSPl
             lda #$f8                    ;if d1 was set, move third and
             sta Sprite_Y_Position+8,y   ;sixth sprites offscreen
             sta Sprite_Y_Position+20,y
ExSPl: ldx ObjectOffset            ;get enemy object offset and leave
             jsr MoveSmallPlatform
             jmp OffscreenBoundsCheck
             
             
RunLargePlatform:
             jsr GetEnemyOffscreenBits
             jsr RelativeEnemyPosition
             jsr LargePlatformBoundBox
             jsr LargePlatformCollision
             lda TimerControl             ;if master timer control set,
             bne SkipPT                   ;skip subroutine tree
             jsr LargePlatformSubroutines
SkipPT: jsr RelativeEnemyPosition
             jsr DrawLargePlatform
             jmp OffscreenBoundsCheck
             
             
LargePlatformSubroutines:
             ldx ObjectOffset
             lda Enemy_ID,x  ;subtract $24 to get proper offset for jump table
             sec
             sbc #$24
             jsr JumpEngine
             
             .dw BalancePlatform   ;table used by objects $24-$2a
             .dw YMovingPlatform
             .dw MoveLargeLiftPlat
             .dw MoveLargeLiftPlat
             .dw XMovingPlatform
             .dw DropPlatform
             .dw RightPlatform
             
             
EraseEnemyObject:
             lda #$00                 ;clear all enemy object variables
             sta Enemy_Flag,x
             sta Enemy_ID,x
             sta Enemy_State,x
             ;sta FloateyNum_Control,x
             sta EnemyIntervalTimer,x
             sta ShellChainCounter,x
             sta Enemy_SprAttrib,x
             sta EnemyFrameTimer,x
             cpx GrabID
             bne +
             sta GrabDown
             sta GrabUp
+:    rts
             
             
MovePodoboo:
             lda Enemy_State,x
             cmp #$22
             beq PdbM
             lda EnemyIntervalTimer,x   ;check enemy timer
             bne PdbM                   ;branch to move enemy if not expired
             jsr InitPodoboo2            ;otherwise set up podoboo again
             lda PseudoRandomBitReg+1,x ;get part of LSFR
             ora #%10000000             ;set d7
             sta Enemy_Y_MoveForce,x    ;store as movement force
             and #%00001111             ;mask out high nybble
             ora #$06                   ;set for at least six intervals
             sta EnemyIntervalTimer,x   ;store as new enemy timer
             lda #$f9
             sta Enemy_Y_Speed,x        ;set vertical speed to move podoboo upwards
PdbM: jmp MoveJ_EnemyVertically  ;branch to impose gravity on podoboo
             
             
ProcHammerBro:
             lda Enemy_State,x          ;check hammer bro's enemy state for d5 set
             and #%00100000
             beq ChkJH                  ;if not set, go ahead with code
             jmp MoveDefeatedEnemy      ;otherwise jump to something else
ChkJH: lda HammerBroJumpTimer,x   ;check jump timer
             beq HammerBroJumpCode      ;if expired, branch to jump
             dec HammerBroJumpTimer,x   ;otherwise decrement jump timer
             lda Enemy_OffscreenBits
             and #%00001100             ;check offscreen bits
             bne MoveHammerBroXDir      ;if hammer bro a little offscreen, skip to movement code
             lda HammerThrowingTimer,x  ;check hammer throwing timer
             bne DecHT                  ;if not expired, skip ahead, do not throw hammer
             ldy HardModeFlag           ;otherwise get secondary hard mode flag
             lda HammerThrowTmrData,y   ;get timer data using flag as offset
             sta HammerThrowingTimer,x  ;set as new timer
             jsr SpawnHammerObj         ;do a sub here to spawn hammer object
             bcc DecHT                  ;if carry clear, hammer not spawned, skip to decrement timer
             lda Enemy_State,x
             ora #%00001000             ;set d3 in enemy state for hammer throw
             sta Enemy_State,x
             jmp MoveHammerBroXDir      ;jump to move hammer bro
DecHT: dec HammerThrowingTimer,x  ;decrement timer
             jmp MoveHammerBroXDir      ;jump to move hammer bro
             
HammerBroJumpLData:
             .db $20, $37
             
HammerBroJumpCode:
             lda Enemy_State,x           ;get hammer bro's enemy state
             and #%00000111              ;mask out all but 3 LSB
             cmp #$01                    ;check for d0 set (for jumping)
             beq MoveHammerBroXDir       ;if set, branch ahead to moving code
             lda #$00                    ;load default value here
             sta $00                     ;save into temp variable for now
             ldy #$fa                    ;set default vertical speed
             lda Enemy_Y_Position,x      ;check hammer bro's vertical coordinate
             bmi SetHJ                   ;if on the bottom half of the screen, use current speed
             ldy #$fd                    ;otherwise set alternate vertical speed
             cmp #$70                    ;check to see if hammer bro is above the middle of screen
             inc $00                     ;increment preset value to $01
             bcc SetHJ                   ;if above the middle of the screen, use current speed and $01
             dec $00                     ;otherwise return value to $00
             lda PseudoRandomBitReg+1,x  ;get part of LSFR, mask out all but LSB
             and #$01
             bne SetHJ                   ;if d0 of LSFR set, branch and use current speed and $00
             ldy #$fa                    ;otherwise reset to default vertical speed
SetHJ: sty Enemy_Y_Speed,x         ;set vertical speed for jumping
             lda Enemy_State,x           ;set d0 in enemy state for jumping
             ora #$01
             sta Enemy_State,x
             lda $00                     ;load preset value here to use as bitmask
             and PseudoRandomBitReg+2,x  ;and do bit-wise comparison with part of LSFR
             tay                         ;then use as offset
             lda SecondaryHardMode       ;check secondary hard mode flag
             bne HJump
             tay                         ;if secondary hard mode flag clear, set offset to 0
HJump: lda HammerBroJumpLData,y    ;get jump length timer data using offset from before
             sta EnemyFrameTimer,x       ;save in enemy timer
             lda PseudoRandomBitReg+1,x
             ora #%11000000              ;get contents of part of LSFR, set d7 and d6, then
             sta HammerBroJumpTimer,x    ;store in jump timer
             
MoveHammerBroXDir:
             ldy #$fc                  ;move hammer bro a little to the left
             lda FrameCounter
             and #%01000000            ;change hammer bro's direction every 64 frames
             bne Shimmy
             ldy #$04                  ;if d6 set in counter, move him a little to the right
Shimmy:  sty Enemy_X_Speed,x       ;store horizontal speed
             ldy #$01                  ;set to face right by default
             jsr PlayerEnemyDiff       ;get horizontal difference between player and hammer bro
             bmi SetShim               ;if enemy to the left of player, skip this part
             iny                       ;set to face left
             lda EnemyIntervalTimer,x  ;check walking timer
             bne SetShim               ;if not yet expired, skip to set moving direction
             lda #$f8
             sta Enemy_X_Speed,x       ;otherwise, make the hammer bro walk left towards player
SetShim: sty Enemy_MovingDir,x     ;set moving direction
             
MoveNormalEnemy:
             ldy #$00                   ;init Y to leave horizontal movement as-is 
             lda Enemy_State,x
             and #%01000000             ;check enemy state for d6 set, if set skip
             bne FallE                  ;to move enemy vertically, then horizontally if necessary
             lda Enemy_State,x
             bmi SteadM                 ;if set, branch to move enemy horizontally
             lda Enemy_State,x
             and #%00100000             ;check enemy state for d5 set
             beq +
             jmp MoveDefeatedEnemy      ;if set, branch to move defeated enemy object
+:     lda Enemy_State,x
             and #%00000111             ;check d2-d0 of enemy state for any set bits
             beq SteadM                 ;if enemy in normal state, branch to move enemy horizontally
             cmp #$05
             beq FallE                  ;if enemy in state used by spiny's egg, go ahead here
             cmp #$03
             bcs ReviveStunned          ;if enemy in states $03 or $04, skip ahead to yet another part
FallE: ldy #$3d           ;set quick movement amount downwards
             lda Enemy_State,x  ;then check enemy state
             cmp #$05           ;if not set to unique state for spiny's egg, go ahead
             bne +      ;and use, otherwise set different movement amount, continue on
             ldy #$20       ;set movement amount
+:     lda #$03                ;set maximum speed in A
             sty $00                 ;set movement amount here
             inx                     ;increment X for enemy offset
             sta $02            ;set maximum speed here
             lda #$00           ;set value to move downwards
             jsr ImposeGravity  ;jump to the code that actually moves it
             ldx ObjectOffset        ;get enemy object buffer offset and leave
             ldy #$00
             lda Enemy_State,x          ;check for enemy state $02
             cmp #$02
             beq MEHor                  ;if found, branch to move enemy horizontally
             and #%01000000             ;check for d6 set
             beq SteadM                 ;if not set, branch to something else
             lda Enemy_ID,x
             cmp #PowerUpObject         ;check for power-up object
             beq SteadM
             bne SlowM                  ;if any other object where d6 set, jump to set Y
MEHor: inx                         ;increment offset for enemy offset
             jmp MoveObjectHorizontally  ;position object horizontally according to
             ;ldx ObjectOffset            ;counters, return with saved value in A,
             ;rts
             
SlowM:  ldy #$01
SteadM: lda Enemy_X_Speed,x       ;get current horizontal speed
             pha                       ;save to stack
             bpl AddHS                 ;if not moving or moving right, skip, leave Y alone    
             iny
             iny
AddHS:  clc
             adc XSpeedAdderData,y          ;add value here to slow enemy down if necessary
             sta Enemy_X_Speed,x       ;save as horizontal speed temporarily
             inx                         ;increment offset for enemy offset
             jsr MoveObjectHorizontally  ;position object horizontally according to
             ldx ObjectOffset            ;counters, return with saved value in A, ;then do a sub to move horizontally
             pla
             sta Enemy_X_Speed,x       ;get old horizontal speed from stack and return to
             rts                       ;original memory location, then leave
             
PlayerEnemyDiff:
             lda Enemy_X_Position,x  ;get distance between enemy object's
             sec                     ;horizontal coordinate and the player's
             sbc Player_X_Position   ;horizontal coordinate
             sta $00                 ;and store here
             lda Enemy_PageLoc,x
             sbc Player_PageLoc      ;subtract borrow, then leave
             rts
ReviveStunned:
             lda Enemy_ID,x
             cmp #KoopaShell
             beq ChkKillGoomba
             cmp #RedKoopaShell
             beq ChkKillGoomba
             lda EnemyIntervalTimer,x  ;if enemy timer not expired yet,
             bne ChkKillGoomba         ;skip ahead to something else
             sta Enemy_State,x         ;otherwise initialize enemy state to normal
             lda FrameCounter
             and #$01                  ;get d0 of frame counter
             tay                       ;use as Y and increment for movement direction
             iny
             sty Enemy_MovingDir,x     ;store as pseudorandom movement direction
             dey                       ;decrement for use as pointer
             lda HardModeFlag          ;check primary hard mode flag
             beq SetRSpd               ;if not set, use pointer as-is
             iny
             iny                       ;otherwise increment 2 bytes to next data
SetRSpd: lda RevivedXSpeed,y       ;load and store new horizontal speed
             sta Enemy_X_Speed,x       ;and leave
             rts
             
MoveDefeatedEnemy:
             ldy #$3d           ;set quick movement amount downwards
             lda Enemy_State,x  ;then check enemy state
             cmp #$05           ;if not set to unique state for spiny's egg, go ahead
             bne +              ;and use, otherwise set different movement amount, continue on
             ldy #$20            ;set movement amount
+:    lda #$03                ;set maximum speed in A
             sty $00                 ;set movement amount here
             inx                     ;increment X for enemy offset
             sta $02            ;set maximum speed here
             lda #$00           ;set value to move downwards
             jsr ImposeGravity  ;jump to the code that actually moves it
             ldx ObjectOffset        ;get enemy object buffer offset and leave
             inx                         ;increment offset for enemy offset
             jsr MoveObjectHorizontally  ;position object horizontally according to
             ldx ObjectOffset            ;counters, return with saved value in A,rai
             rts
             
ChkKillGoomba:
             cmp #$0e              ;check to see if enemy timer has reached
             bne NKGmba            ;a certain point, and branch to leave if not
             lda Enemy_ID,x
             cmp #Goomba           ;check for goomba object
             beq +
             cmp #FastGoomba
+:      bne NKGmba            ;branch if not found
             lda #$00                 ;clear all enemy object variables
             sta Enemy_Flag,x
             sta Enemy_ID,x
             sta Enemy_State,x
             sta FloateyNum_Control,x
             sta EnemyIntervalTimer,x
             sta ShellChainCounter,x
             sta Enemy_SprAttrib,x
             sta EnemyFrameTimer,x
             ldy SavedOffset,x
             lda #$02
             sta Saved_isDefeated,y
NKGmba: rts                   ;leave!
             
             
             
ProcMoveRedPTroopa:
             lda Enemy_Y_Speed,x
             ora Enemy_Y_MoveForce,x     ;check for any vertical force or speed
             bne MoveRedPTUpOrDown       ;branch if any found
             sta Enemy_YMF_Dummy,x       ;initialize something here
             lda Enemy_Y_Position,x      ;check current vs. original vertical coordinate
             cmp RedPTroopaOrigXPos,x
             bcs MoveRedPTUpOrDown       ;if current => original, skip ahead to more code
             lda FrameCounter            ;get frame counter
             and #%00000111              ;mask out all but 3 LSB
             bne NoIncPT                 ;if any bits set, branch to leave
             inc Enemy_Y_Position,x      ;otherwise increment red paratroopa's vertical position
NoIncPT:  rts                         ;leave
             
MoveRedPTUpOrDown:
             lda Enemy_Y_Position,x      ;check current vs. central vertical coordinate
             cmp RedPTroopaCenterYPos,x
             bcc MovPTDwn                ;if current < central, jump to move downwards
             jmp MoveRedPTroopaUp        ;otherwise jump to move upwards
MovPTDwn: jmp MoveRedPTroopaDown      ;move downwards
             
             
MoveFlyGreenPTroopa:
             jsr XMoveCntr_GreenPTroopa ;do sub to increment primary and secondary counters
             jsr MoveWithXMCntrs        ;do sub to move green paratroopa accordingly, and horizontally
             ldy #$01                   ;set Y to move green paratroopa down
             lda FrameCounter
             and #%00000011             ;check frame counter 2 LSB for any bits set
             bne NoMGPT                 ;branch to leave if set to move up/down every fourth frame
             lda FrameCounter
             and #%01000000             ;check frame counter for d6 set
             bne YSway                  ;branch to move green paratroopa down if set
             ldy #$ff                   ;otherwise set Y to move green paratroopa up
YSway:  sty $00                    ;store adder here
             lda Enemy_Y_Position,x
             clc                        ;add or subtract from vertical position
             adc $00                    ;to give green paratroopa a wavy flight
             sta Enemy_Y_Position,x
NoMGPT: rts                        ;leave!
             
XMoveCntr_GreenPTroopa:
             lda #$13                    ;load preset maximum value for secondary counter
             
XMoveCntr_Platform:
             sta $01                     ;store value here
             lda FrameCounter
             and #%00000011              ;branch to leave if not on
             bne NoIncXM                 ;every fourth frame
             ldy XMoveSecondaryCounter,x ;get secondary counter
             lda XMovePrimaryCounter,x   ;get primary counter
             lsr
             bcs DecSeXM                 ;if d0 of primary counter set, branch elsewhere
             cpy $01                     ;compare secondary counter to preset maximum value
             beq IncPXM                  ;if equal, branch ahead of this part
             inc XMoveSecondaryCounter,x ;increment secondary counter and leave
NoIncXM: rts
IncPXM:  inc XMovePrimaryCounter,x   ;increment primary counter and leave
             rts
DecSeXM: tya                         ;put secondary counter in A
             beq IncPXM                  ;if secondary counter at zero, branch back
             dec XMoveSecondaryCounter,x ;otherwise decrement secondary counter and leave
             rts
             
MoveWithXMCntrs:
             lda XMoveSecondaryCounter,x  ;save secondary counter to stack
             pha
             ldy #$01                     ;set value here by default
             lda XMovePrimaryCounter,x
             and #%00000010               ;if d1 of primary counter is
             bne XMRight                  ;set, branch ahead of this part here
             lda XMoveSecondaryCounter,x
             eor #$ff                     ;otherwise change secondary
             clc                          ;counter to two's compliment
             adc #$01
             sta XMoveSecondaryCounter,x
             ldy #$02                     ;load alternate value here
XMRight: sty Enemy_MovingDir,x        ;store as moving direction
             inx                         ;increment offset for enemy offset
             jsr MoveObjectHorizontally  ;position object horizontally according to
             ldx ObjectOffset            ;counters, return with saved value in A,
             sta $00                      ;save value obtained from sub here
             pla                          ;get secondary counter from stack
             sta XMoveSecondaryCounter,x  ;and return to original place
             rts
             
             
BlooberBitmasks:
             .db %00111111, %00000011
             
MoveBloober:
             lda Enemy_State,x
             and #%00100000             ;check enemy state for d5 set
             bne MoveDefeatedBloober    ;branch if set to move defeated bloober
             ldy SecondaryHardMode      ;use secondary hard mode flag as offset
             lda PseudoRandomBitReg+1,x ;get LSFR
             and BlooberBitmasks,y      ;mask out bits in LSFR using bitmask loaded with offset
             bne BlooberSwim            ;if any bits set, skip ahead to make swim
             txa
             lsr                        ;check to see if on second or fourth slot (1 or 3)
             bcc FBLeft                 ;if not, branch to figure out moving direction
             ldy Player_MovingDir       ;otherwise, load player's moving direction and
             bcs SBMDir                 ;do an unconditional branch to set
FBLeft: ldy #$02                   ;set left moving direction by default
             jsr PlayerEnemyDiff        ;get horizontal difference between player and bloober
             bpl SBMDir                 ;if enemy to the right of player, keep left
             dey                        ;otherwise decrement to set right moving direction
SBMDir: sty Enemy_MovingDir,x      ;set moving direction of bloober, then continue on here
             
BlooberSwim:
             jsr ProcSwimmingB        ;execute sub to make bloober swim characteristically
             lda Enemy_Y_Position,x   ;get vertical coordinate
             sec
             sbc Enemy_Y_MoveForce,x  ;subtract movement force
             cmp #$20                 ;check to see if position is above edge of status bar
             bcc SwimX                ;if so, don't do it
             sta Enemy_Y_Position,x   ;otherwise, set new vertical position, make bloober swim
SwimX: ldy Enemy_MovingDir,x    ;check moving direction
             dey
             bne LeftSwim             ;if moving to the left, branch to second part
             lda Enemy_X_Position,x
             clc                      ;add movement speed to horizontal coordinate
             adc BlooperMoveSpeed,x
             sta Enemy_X_Position,x   ;store result as new horizontal coordinate
             lda Enemy_PageLoc,x
             adc #$00                 ;add carry to page location
             sta Enemy_PageLoc,x      ;store as new page location and leave
             rts
             
LeftSwim:
             lda Enemy_X_Position,x
             sec                      ;subtract movement speed from horizontal coordinate
             sbc BlooperMoveSpeed,x
             sta Enemy_X_Position,x   ;store result as new horizontal coordinate
             lda Enemy_PageLoc,x
             sbc #$00                 ;subtract borrow from page location
             sta Enemy_PageLoc,x      ;store as new page location and leave
             rts
             
MoveDefeatedBloober:
             jmp MoveEnemySlowVert    ;jump to move defeated bloober downwards
             
ProcSwimmingB:
             lda BlooperMoveCounter,x  ;get enemy's movement counter
             and #%00000010            ;check for d1 set
             bne ChkForFloatdown       ;branch if set
             lda FrameCounter
             and #%00000111            ;get 3 LSB of frame counter
             pha                       ;and save it to the stack
             lda BlooperMoveCounter,x  ;get enemy's movement counter
             lsr                       ;check for d0 set
             bcs SlowSwim              ;branch if set
             pla                       ;pull 3 LSB of frame counter from the stack
             bne BSwimE                ;branch to leave, execute code only every eighth frame
             lda Enemy_Y_MoveForce,x
             clc                       ;add to movement force to speed up swim
             adc #$01
             sta Enemy_Y_MoveForce,x   ;set movement force
             sta BlooperMoveSpeed,x    ;set as movement speed
             cmp #$02
             bne BSwimE                ;if certain horizontal speed, branch to leave
             inc BlooperMoveCounter,x  ;otherwise increment movement counter
BSwimE: rts
             
SlowSwim:
             pla                      ;pull 3 LSB of frame counter from the stack
             bne NoSSw                ;branch to leave, execute code only every eighth frame
             lda Enemy_Y_MoveForce,x
             sec                      ;subtract from movement force to slow swim
             sbc #$01
             sta Enemy_Y_MoveForce,x  ;set movement force
             sta BlooperMoveSpeed,x   ;set as movement speed
             bne NoSSw                ;if any speed, branch to leave
             inc BlooperMoveCounter,x ;otherwise increment movement counter
             lda #$02
             sta EnemyIntervalTimer,x ;set enemy's timer
NoSSw: rts                      ;leave
             
ChkForFloatdown:
             lda EnemyIntervalTimer,x ;get enemy timer
             beq ChkNearPlayer        ;branch if expired
             
Floatdown:
             lda FrameCounter        ;get frame counter
             lsr                     ;check for d0 set
             bcs NoFD                ;branch to leave on every other frame
             inc Enemy_Y_Position,x  ;otherwise increment vertical coordinate
NoFD: rts                     ;leave
             
ChkNearPlayer:
             lda Enemy_Y_Position,x    ;get vertical coordinate
             adc #BLOOPER_DISTANCE     ;add sixteen pixels (NTSC) or twelve pixels (PAL).
             cmp Player_Y_Position     ;compare result with player's vertical coordinate
             bcc Floatdown             ;if modified vertical less than player's, branch
             lda #$00
             sta BlooperMoveCounter,x  ;otherwise nullify movement counter
             rts
             
             
SwimCCXMoveData:
             .db $40, $80
             ;.db $04, $04 ;residual data, not used
             
MoveSwimmingCheepCheep:
             lda Enemy_State,x         ;check cheep-cheep's enemy object state
             and #%00100000            ;for d5 set
             beq CCSwim                ;if not set, continue with movement code
             jmp MoveEnemySlowVert     ;otherwise jump to move defeated cheep-cheep downwards
CCSwim: sta $03                   ;save enemy state in $03
             lda Enemy_ID,x            ;get enemy identifier
             sec
             sbc #$0a                  ;subtract ten for cheep-cheep identifiers
             tay                       ;use as offset
             lda SwimCCXMoveData,y     ;load value here
             sta $02
             lda Enemy_MovingDir,x
             cmp #$01
             beq +
             lda Enemy_X_MoveForce,x   ;load horizontal force
             sec
             sbc $02                   ;subtract preset value from horizontal force
             sta Enemy_X_MoveForce,x   ;store as new horizontal force
             lda Enemy_X_Position,x    ;get horizontal coordinate
             sbc #$00                  ;subtract borrow (thus moving it slowly)
             sta Enemy_X_Position,x    ;and save as new horizontal coordinate
             lda Enemy_PageLoc,x
             sbc #$00                  ;subtract borrow again, this time from the
             sta Enemy_PageLoc,x       ;page location, then save
             jmp ++
+:        lda Enemy_X_MoveForce,x   ;load horizontal force
             clc
             adc $02                   ;subtract preset value from horizontal force
             sta Enemy_X_MoveForce,x   ;store as new horizontal force
             lda Enemy_X_Position,x    ;get horizontal coordinate
             adc #$00                  ;subtract borrow (thus moving it slowly)
             sta Enemy_X_Position,x    ;and save as new horizontal coordinate
             lda Enemy_PageLoc,x
             adc #$00                  ;subtract borrow again, this time from the
             sta Enemy_PageLoc,x       ;page location, then save
++:     lda #$20
             sta $02                   ;save new value here
             cpx #$02                  ;check enemy object offset
             bcc ExSwCC                ;if in first or second slot, branch to leave
             lda CheepCheepMoveMFlag,x ;check movement flag
             cmp #$10                  ;if movement speed set to $00,
             bcc CCSwimUpwards         ;branch to move upwards
             lda Enemy_YMF_Dummy,x
             clc
             adc $02                   ;add preset value to dummy variable to get carry
             sta Enemy_YMF_Dummy,x     ;and save dummy
             lda Enemy_Y_Position,x    ;get vertical coordinate
             adc $03                   ;add carry to it plus enemy state to slowly move it downwards
             sta Enemy_Y_Position,x    ;save as new vertical coordinate
             lda Enemy_Y_HighPos,x
             adc #$00                  ;add carry to page location and
             jmp ChkSwimYPos           ;jump to end of movement code
             
CCSwimUpwards:
             lda Enemy_YMF_Dummy,x
             sec
             sbc $02                   ;subtract preset value to dummy variable to get borrow
             sta Enemy_YMF_Dummy,x     ;and save dummy
             lda Enemy_Y_Position,x    ;get vertical coordinate
             sbc $03                   ;subtract borrow to it plus enemy state to slowly move it upwards
             sta Enemy_Y_Position,x    ;save as new vertical coordinate
             lda Enemy_Y_HighPos,x
             sbc #$00                  ;subtract borrow from page location
             
ChkSwimYPos:
             sta Enemy_Y_HighPos,x     ;save new page location here
             ldy #$00                  ;load movement speed to upwards by default
             lda Enemy_Y_Position,x    ;get vertical coordinate
             sec
             sbc CheepCheepOrigYPos,x  ;subtract original coordinate from current
             bpl YPDiff                ;if result positive, skip to next part
             ldy #$10                  ;otherwise load movement speed to downwards
             eor #$ff
             clc                       ;get two's compliment of result
             adc #$01                  ;to obtain total difference of original vs. current
YPDiff: cmp #$0f                  ;if difference between original vs. current vertical
             bcc ExSwCC                ;coordinates < 15 pixels, leave movement speed alone
             tya
             sta CheepCheepMoveMFlag,x ;otherwise change movement speed
ExSwCC: rts                       ;leave
             
             
SkipFBar1: rts
ProcFirebar:
             lda #$01                      ;set A to add 1 byte in order to get enemy offset
             tay                           ;set Y to put offscreen bits in Enemy_OffscreenBits
             stx $00
             clc                               ;add contents of X to A to get
             adc $00                     ;appropriate offset, then give back to X
             tax
             tya                         ;save offscreen bits offset to stack for now
             pha
             jsr GetXOffscreenBits       ;do subroutine here
             tay
             lda MSBtoLSB,y
             sta $00                        ;store here
             jsr GetYOffscreenBits
             tay
             lda LSBtoMSB,y
             ora $00                     ;mask together with previously saved low nybble
             sta $00                     ;store both here
             pla                         ;get offscreen bits offset from stack
             tay
             lda $00                     ;get value here and store elsewhere
             sta SprObject_OffscrBits,y
             ldx ObjectOffset
             lda Enemy_OffscreenBits     ;check for d3 set
             and #%00001000              ;if so, branch to leave
             bne SkipFBar1
             lda TimerControl            ;if master timer control set, branch
             bne SusFbar                 ;ahead of this part
             lda FirebarSpinSpeed,x      ;load spinning speed of firebar
             sta $07                     ;save spinning speed here
             lda FirebarSpinDirection,x  ;check spinning direction
             bne +                          ;if moving counter-clockwise, branch to other part
             lda FirebarSpinState_Low,x
             clc                         ;add spinning speed to what would normally be
             adc $07                     ;the horizontal speed
             sta FirebarSpinState_Low,x
             lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
             adc #$00
             jmp ++
+:          lda FirebarSpinState_Low,x
             sec                         ;subtract spinning speed to what would normally be
             sbc $07                     ;the horizontal speed
             sta FirebarSpinState_Low,x
             lda FirebarSpinState_High,x ;add carry to what would normally be the vertical speed
             sbc #$00
++:          and #%00011111              ;mask out all but 5 LSB
             sta FirebarSpinState_High,x ;and store as new high byte of spinstate
SusFbar:  lda FirebarSpinState_High,x ;get high byte of spinstate
             ldy Enemy_ID,x              ;check enemy identifier
             cpy #$1f
             bcc SetupGFB                ;if < $1f (long firebar), branch
             cmp #$08                    ;check high byte of spinstate
             beq SkpFSte                 ;if eight, branch to change
             cmp #$18
             bne SetupGFB                ;if not at twenty-four branch to not change
SkpFSte:  sec
             sbc #$01                    ;add one to spinning thing to avoid horizontal state
             sta FirebarSpinState_High,x
SetupGFB: sta temp4                   ;save high byte of spinning thing, modified or otherwise
             lda #$01                    ;get coordinates of enemy object 
             tay                          ;relative to the screen
             stx $00                     ;store value to add to A here
             clc
             adc $00                     ;add A to value stored
             tax                         ;use as enemy offset
             lda SprObject_Y_Position,x  ;load vertical coordinate low
             sta SprObject_Rel_YPos,y    ;store here
             lda SprObject_X_Position,x  ;load horizontal coordinate
             sec                         ;subtract left edge coordinate
             sbc ScreenLeft_X_Pos
             sta SprObject_Rel_XPos,y    ;store result here
             ldx ObjectOffset            ;reload old object offset and leave
             ;jsr GetFirebarPosition     ;do a sub here (residual, too early to be used now)
             ldy Enemy_SprDataOffset,x   ;get OAM data offset
             lda Enemy_Rel_YPos          ;get relative vertical coordinate
             sta Sprite_Y_Position,y     ;store as Y in OAM data
             sta $07                     ;also save here
             lda Enemy_Rel_XPos          ;get relative horizontal coordinate
             sta Sprite_X_Position,y     ;store as X in OAM data
             sta $06                     ;also save here
             ;lda #$01
             ;sta $00                     ;set $01 value here (not necessary)
             jsr FirebarCollision        ;draw fireball part and do collision detection
             ldy #$05                    ;load value for short firebars by default
             lda Enemy_ID,x
             cmp #$1f                    ;are we doing a long firebar?
             bcc SetMFbar                ;no, branch then
             ldy #$0b                    ;otherwise load value for long firebars
SetMFbar: sty temp3                   ;store maximum value for length of firebars
             lda #$00
             sta $00                     ;initialize counter here
DrawFbar: lda temp4                   ;load high byte of spinstate
             pha                         ;save high byte of spinstate to the stack
             and #%00001111              ;mask out low nybble
             cmp #$09
             bcc +                       ;if lower than $09, branch ahead
             eor #%00001111              ;otherwise get two's compliment to oscillate
             clc
             adc #$01
+:        sta $01                     ;store result, modified or not, here
             ldy $00                     ;load number of firebar ball where we're at
             lda FirebarTblOffsets,y     ;load offset to firebar position data
             clc
             adc $01                     ;add oscillated high byte of spinstate
             tay                         ;to offset here and use as new offset
             lda FirebarPosLookupTbl,y   ;get data here and store as horizontal adder
             sta $01
             pla                         ;pull whatever was in A from the stack
             pha                         ;save it again because we still need it
             clc
             adc #$08                    ;add eight this time, to get vertical adder
             and #%00001111              ;mask out high nybble
             cmp #$09                    ;if lower than $09, branch ahead
             bcc ++
             eor #%00001111              ;otherwise get two's compliment
             clc
             adc #$01
++:       sta $02                     ;store result here
             ldy $00
             lda FirebarTblOffsets,y     ;load offset to firebar position data again
             clc
             adc $02                     ;this time add value in $02 to offset here and use as offset
             tay
             lda FirebarPosLookupTbl,y   ;get data here and store as vertica adder
             sta $02
             pla                         ;pull out whatever was in A one last time
             lsr                         ;divide by eight or shift three to the right
             lsr
             lsr
             tay                         ;use as offset
             lda FirebarMirrorData,y     ;load mirroring data here
             sta $03      
             jsr DrawFirebar_Collision   ;position it properly, draw it and do collision detection
             lda $00                     ;check which firebar part
             cmp #$04
             bne NextFbar
             ldy DuplicateObj_Offset     ;if we arrive at fifth firebar part,
             lda Enemy_SprDataOffset,y   ;get offset from long firebar and load OAM data offset
             sta $06                     ;using long firebar offset, then store as new one here
NextFbar: inc $00                     ;move onto the next firebar part
             lda $00
             cmp temp3                   ;if we end up at the maximum part, go on and leave
             bcc DrawFbar                ;otherwise go back and do another
SkipFBar: rts
             
DrawFirebar_Collision:
             lda $03                  ;store mirror data elsewhere
             sta $05          
             ldy $06                  ;load OAM data offset for firebar
             lda $01                  ;load horizontal adder we got from position loader
             lsr $05                  ;shift LSB of mirror data
             bcs AddHA                ;if carry was set, skip this part
             eor #$ff
             adc #$01                 ;otherwise get two's compliment of horizontal adder
AddHA:   clc                      ;add horizontal coordinate relative to screen to
             adc Enemy_Rel_XPos       ;horizontal adder, modified or otherwise
             sta Sprite_X_Position,y  ;store as X coordinate here
             sta $06                  ;store here for now, note offset is saved in Y still
             cmp Enemy_Rel_XPos       ;compare X coordinate of sprite to original X of firebar
             bcs SubtR1               ;if sprite coordinate => original coordinate, branch
             lda Enemy_Rel_XPos
             sec                      ;otherwise subtract sprite X from the
             sbc $06                  ;original one and skip this part
             jmp ChkFOfs
NoColFB1: jmp NoColFB
SubtR1:  sec                      ;subtract original X from the
             sbc Enemy_Rel_XPos       ;current sprite X
ChkFOfs: cmp #$59                 ;if difference of coordinates within a certain range,
             bcc VAHandl              ;continue by handling vertical adder
             lda #$f8                 ;otherwise, load offscreen Y coordinate
             bne SetVFbr              ;and unconditionally branch to move sprite offscreen
VAHandl: lda Enemy_Rel_YPos       ;if vertical relative coordinate offscreen,
             cmp #$f8                 ;skip ahead of this part and write into sprite Y coordinate
             beq SetVFbr
             lda $02                  ;load vertical adder we got from position loader
             lsr $05                  ;shift LSB of mirror data one more time
             bcs AddVA                ;if carry was set, skip this part
             eor #$ff
             adc #$01                 ;otherwise get two's compliment of second part
AddVA:   clc                      ;add vertical coordinate relative to screen to 
             adc Enemy_Rel_YPos       ;the second data, modified or otherwise
SetVFbr: sta Sprite_Y_Position,y  ;store as Y coordinate here
             sta $07                  ;also store here for now
             
FirebarCollision:
             lda FrameCounter         ;get frame counter
             lsr                      ;divide by four
             lsr
             pha                      ;save result to stack
             and #$01                 ;mask out all but last bit
             eor #$64                 ;set either tile $64 or $65 as fireball tile
             sta Sprite_Tilenumber,y  ;thus tile changes every four frames
             pla                      ;get from stack
             lsr                      ;divide by four again
             lsr
             lda #$02                 ;load value $02 to set palette in attrib byte
             bcc +                    ;if last bit shifted out was not set, skip this
             ora #%11000000           ;otherwise flip both ways every eight frames
+:         sta Sprite_Attributes,y  ;store attribute byte and leave
             tya                      ;return OAM data offset and save
             pha                      ;to the stack for now
             lda GameEngineSubroutine
             cmp #$08
             bne NoColFB1
             lda GrabFlag
             beq +
             cpx GrabID
             beq NoColFB
+:       
             lda SwimmingFlag
             bne +
             lda StarInvincibleTimer  ;if star mario invincibility timer
             bne NoColFB
+:       lda TimerControl         ;or master timer controls set
             bne NoColFB              ;then skip all of this
             sta $05                  ;otherwise initialize counter
             ldy Player_Y_HighPos
             dey                      ;if player's vertical high byte offscreen,
             bne NoColFB              ;skip all of this
             ldy Player_Y_Position    ;get player's vertical position
             lda PlayerSize           ;get player's size
             bne AdjSm                ;if player small, branch to alter variables
             lda CrouchingFlag
             beq BigJp                ;if player big and not crouching, jump ahead
AdjSm:   inc $05                  ;if small or big but crouching, execute this part
             inc $05                  ;first increment our counter twice (setting $02 as flag)
             tya
             clc                      ;then add 24 pixels to the player's
             adc #$18                 ;vertical coordinate
             tay
BigJp:   tya                      ;get vertical coordinate, altered or otherwise, from Y
FBCLoop: sec                      ;subtract vertical position of firebar
             sbc $07                  ;from the vertical coordinate of the player
             bpl ChkVFBD              ;if player lower on the screen than firebar, 
             eor #$ff                 ;skip two's compliment part
             clc                      ;otherwise get two's compliment
             adc #$01
ChkVFBD: cmp #$08                 ;if difference => 8 pixels, skip ahead of this part
             bcs Chk2Ofs
             lda $06                  ;if firebar on far right on the screen, skip this,
             cmp #$f0                 ;because, really, what's the point?
             bcs Chk2Ofs
             lda Sprite_X_Position+4  ;get OAM X coordinate for sprite #1
             sec
             sbc #$03                 ;add four pixels
             sta $04                  ;store here
             sec                      ;subtract horizontal coordinate of firebar
             sbc $06                  ;from the X coordinate of player's sprite 1
             bpl ChkFBCl              ;if modded X coordinate to the right of firebar
             eor #$ff                 ;skip two's compliment part
             clc                      ;otherwise get two's compliment
             adc #$01
ChkFBCl: cmp #$08                 ;if difference < 8 pixels, collision, thus branch
             bcc ChgSDir              ;to process
Chk2Ofs: lda $05                  ;if value of $02 was set earlier for whatever reason,
             cmp #$02                 ;branch to increment OAM offset and leave, no collision
             beq NoColFB
             ldy $05                  ;otherwise get temp here and use as offset
             lda Player_Y_Position
             clc
             adc FirebarYPos,y        ;add value loaded with offset to player's vertical coordinate
             inc $05                  ;then increment temp and jump back
             jmp FBCLoop
ChgSDir: ;ldx #$01                 ;set movement direction by default
             ;lda $04                  ;if OAM X coordinate of player's sprite 1
             ;cmp $06                  ;is greater than horizontal coordinate of firebar
             ;bcs SetSDir              ;then do not alter movement direction
             ;inx                      ;otherwise increment it
SetSDir: ;stx Enemy_MovingDir      ;store movement direction here
             ldx #$00
             lda $00                  ;save value written to $00 to stack
             pha
             jsr InjurePlayer         ;perform sub to hurt or kill player
             pla
             sta $00                  ;get value of $00 from stack
NoColFB: pla                      ;get OAM data offset
             clc                      ;add four to it and save
             adc #$04
             sta $06
             ldx ObjectOffset         ;get enemy object buffer offset and leave
             rts
             
PRandomSubtracter:
             .db $f8, $a0, $70, $bd, $00
             
FlyCCBPriority:
             .db $20, $20, $20, $00, $00
             
SetLSpd2: jmp SetLSpd
MoveLakitu:
             lda Enemy_State,x          ;check lakitu's enemy state
             and #%00100000             ;for d5 set
             beq ChkLS                  ;if not set, continue with code
             jmp MoveD_EnemyVertically  ;otherwise jump to move defeated lakitu downwards
ChkLS:   lda Enemy_State,x          ;if lakitu's enemy state not set at all,
             beq Fr12S                  ;go ahead and continue with code
             lda #$00
             sta LakituMoveDirection,x  ;otherwise initialize moving direction to move to left
             sta EnemyFrenzyBuffer      ;initialize frenzy buffer
             lda #$10
             bne SetLSpd2                ;load horizontal speed and do unconditional branch
Fr12S:   lda #Spiny
             sta EnemyFrenzyBuffer      ;set spiny identifier in frenzy buffer
             ldy #$02
LdLDa:   lda LakituDiffAdj,y        ;load values
             sta $0001,y                ;store in zero page
             dey
             bpl LdLDa                  ;do this until all values are stired
             jsr PlayerLakituDiff       ;execute sub to set speed and create spinys
             ldy Player_X_Speed
             beq SetLSpd
             ldy ScrollAmount
             beq SetLSpd
             bmi ++
             ldy pspeed
             cpy #$07
             bne +
             lda Enemy_X_Position,x
             sec
             sbc ScreenLeft_X_Pos
             cmp #$d0
             bcc +++
             cmp #$e0
             bcs ++++++
             lda #$30
             jmp +
++:         lda #$01
             sta LakituMoveDirection,x
             ldy pspeed
             cpy #$07
             bne +++++
             lda Enemy_X_Position,x
             sec
             sbc ScreenLeft_X_Pos
             cmp #$20
             bcs ++
             lda ScrollAmount
             jmp SetLSpd
+++++:   lda Enemy_X_Position,x
             sec
             sbc ScreenLeft_X_Pos
             cmp #$20
             bcs ++++
             lda ScrollAmount
             jmp SetLSpd
+++:     lda #$3f
             bne SetLSpd
++:      lda #$c1
             bne SetLSpd
++++++:  lda #$20
             bne SetLSpd
++++:     lda Player_X_Speed
             cmp #$e8
             bcc ++
             lda #$e0
             bne SetLSpd
++:         lda Enemy_X_Position,x
             sec
             sbc ScreenLeft_X_Pos
             sbc #$20
             cmp #$40
             bcc ++
             lda #$3f
++:         eor #$ff
             jmp SetLSpd
+:       ldy #$01
             sty LakituMoveDirection,x
SetLSpd: sta LakituMoveSpeed,x      ;set movement speed returned from sub
             ldy #$01                   ;set moving direction to right by default
             lda LakituMoveDirection,x
             and #$01                   ;get LSB of moving direction
             bne SetLMov                ;if set, branch to the end to use moving direction
             lda LakituMoveSpeed,x
             eor #$ff                   ;get two's compliment of moving speed
             clc
             adc #$01
             sta LakituMoveSpeed,x      ;store as new moving speed
             iny                        ;increment moving direction to left
SetLMov: sty Enemy_MovingDir,x      ;store moving direction
             jmp MoveEnemyHorizontally  ;move lakitu horizontally
             
PlayerLakituDiff:
             ldy #$00                   ;set Y for default value
             jsr PlayerEnemyDiff        ;get horizontal difference between enemy and player
             bpl ChkLakDif              ;branch if enemy is to the right of the player
             ldy #$01                   ;increment Y for left of player
             lda $00
             eor #$ff                   ;get two's compliment of low byte of horizontal difference
             clc
             adc #$01                   ;store two's compliment as horizontal difference
             sta $00
ChkLakDif: lda $00                    ;get low byte of horizontal difference
             cmp #$3c                   ;if within a certain distance of player, branch
             bcc ChkPSpeed
             lda #$3c                   ;otherwise set maximum distance
             sta $00
             lda Enemy_ID,x             ;check if lakitu is in our current enemy slot
             cmp #Lakitu
             bne ChkPSpeed              ;if not, branch elsewhere
             tya                        ;compare contents of Y, now in A
             cmp LakituMoveDirection,x  ;to what is being used as horizontal movement direction
             beq ChkPSpeed              ;if moving toward the player, branch, do not alter
             lda LakituMoveDirection,x  ;if moving to the left beyond maximum distance,
             beq SetLMovD               ;branch and alter without delay
             dec LakituMoveSpeed,x
             lda Player_X_Speed
             bne +
             sta LakituMoveSpeed,x
+:         lda LakituMoveSpeed,x      ;if horizontal speed not yet at zero, branch to leave
             bne ExMoveLak
SetLMovD:  tya                        ;set horizontal direction depending on horizontal
             sta LakituMoveDirection,x  ;difference between enemy and player if necessary
ChkPSpeed: lda $00
             and #%00111100             ;mask out all but four bits in the middle
             lsr                        ;divide masked difference by four
             lsr
             sta $00                    ;store as new value
             ldy #$00                   ;init offset
             lda Player_X_Speed
             beq SubDifAdj              ;if player not moving horizontally, branch
             lda ScrollAmount
             beq SubDifAdj              ;if scroll speed not set, branch to same place
             iny                        ;otherwise increment offset
             lda Player_X_Speed
             cmp #$19                   ;if player not running, branch
             bcc ChkSpinyO
             lda ScrollAmount
             cmp #$02                   ;if scroll speed below a certain amount, branch
             bcc ChkSpinyO              ;to same place
             iny                        ;otherwise increment once more
ChkSpinyO: lda Enemy_ID,x             ;check for spiny object
             cmp #Spiny
             bne ChkEmySpd              ;branch if not found
             lda Player_X_Speed         ;if player not moving, skip this part
             bne SubDifAdj
ChkEmySpd: lda Enemy_Y_Speed,x        ;check vertical speed
             bne SubDifAdj              ;branch if nonzero
             ldy #$00                   ;otherwise reinit offset
SubDifAdj: lda $0001,y                ;get one of three saved values from earlier
             ldy $00                    ;get saved horizontal difference
SPixelLak: sec                        ;subtract one for each pixel of horizontal difference
             sbc #$01                   ;from one of three saved values
             dey
             bpl SPixelLak              ;branch until all pixels are subtracted, to adjust difference
ExMoveLak: rts                        ;leave!!!
             
             
             
             
BridgeCollapse:
             ldx BowserFront_Offset    ;get enemy offset for bowser
             lda Enemy_ID,x            ;check enemy object identifier for bowser
             cmp #Bowser               ;if not found, branch ahead,
             bne SetM2                 ;metatile removal not necessary
             stx ObjectOffset          ;store as enemy offset here
             lda Enemy_State,x         ;if bowser in normal state, skip all of this
             beq RemoveBridge
             and #%01000000            ;if bowser's state has d6 clear, skip to silence music
             beq SetM2
             lda Enemy_Y_Position,x    ;check bowser's vertical coordinate
             cmp #$e0                  ;if bowser not yet low enough, skip this part ahead
             bcc MoveD_Bowser
SetM2: lda #Silence              ;silence music
             sta EventMusicQueue
             inc OperMode_Task         ;move onto next secondary mode in autoctrl mode
             jmp KillAllEnemies        ;jump to empty all enemy slots and then leave  
             
MoveD_Bowser:
             jsr MoveEnemySlowVert     ;do a sub to move bowser downwards
             jmp BowserGfxHandler      ;jump to draw bowser's front and rear, then leave
             
RemoveBridge:
             dec BowserFeetCounter     ;decrement timer to control bowser's feet
             bne NoBFall               ;if not expired, skip all of this
             lda #$04
             sta BowserFeetCounter     ;otherwise, set timer now
             lda BowserBodyControls
             eor #$01                  ;invert bit to control bowser's feet
             sta BowserBodyControls
             lda #$22                  ;put high byte of name table address here for now
             sta $05
             ldy BridgeCollapseOffset  ;get bridge collapse offset here
             lda BridgeCollapseData,y  ;load low byte of name table address and store here
             sta $04
             ldy VRAM_Buffer1_Offset   ;increment vram buffer offset
             iny
             ldx #$0c                  ;set offset for tile data for sub to draw blank metatile
             jsr RemBridge             ;do sub here to remove bowser's bridge metatiles
             ldx ObjectOffset          ;get enemy offset
             jsr MoveVOffset           ;set new vram buffer offset
             lda #Sfx_Blast            ;load the fireworks/gunfire sound into the square 2 sfx
             sta Square2SoundQueue     ;queue while at the same time loading the brick
             lda #Sfx_BrickShatter     ;shatter sound into the noise sfx queue thus
             sta NoiseSoundQueue       ;producing the unique sound of the bridge collapsing 
             inc BridgeCollapseOffset  ;increment bridge collapse offset
             lda BridgeCollapseOffset
             cmp #$0e                  ;if bridge collapse offset has not yet reached
             bne NoBFall               ;the end, go ahead and skip this part
             lda #$00                    ;initialize vertical speed
             sta Enemy_Y_Speed,x         ;and movement force
             sta Enemy_Y_MoveForce,x              ;initialize whatever vertical speed bowser has
             lda #%01000000
             sta Enemy_State,x         ;set bowser's state to one of defeated states (d6 set)
             lda #Sfx_BowserFall
             sta Square2SoundQueue     ;play bowser defeat sound
NoBFall: jmp BowserGfxHandler      ;jump to code that draws bowser
             
             
PRandomRange:
             .db $21, $41, $11, $31
             
RunBowser:
             lda Enemy_State,x       ;if d5 in enemy state is not set
             and #%00100000          ;then branch elsewhere to run bowser
             beq BowserControl
             lda Enemy_Y_Position,x  ;otherwise check vertical position
             cmp #$e0                ;if above a certain point, branch to move defeated bowser
             bcc MoveD_Bowser        ;otherwise proceed to KillAllEnemies
             
KillAllEnemies:
             ldx #$05              ;start with last enemy slot
KillLoop: lda GrabFlag
             beq +
             cpx GrabID
             beq ++
+:          jsr EraseEnemyObject  ;branch to kill enemy objects
++:       dex                   ;move onto next enemy slot
             bpl KillLoop          ;do this until all slots are emptied
             sta EnemyFrenzyBuffer ;empty frenzy buffer
             ldx ObjectOffset      ;get enemy object offset and leave
             rts
KillAllEnemiesNoFlag:
             ldx #$05              ;start with last enemy slot
-:           lda Enemy_ID,x
             cmp #FlagpoleFlagObject
             beq +
             jsr EraseEnemyObject  ;branch to kill enemy objects
+:        dex                   ;move onto next enemy slot
             bpl -                 ;do this until all slots are emptied
             sta EnemyFrenzyBuffer ;empty frenzy buffer
             ldx ObjectOffset      ;get enemy object offset and leave
             rts
BowserControl:
             lda #$00
             sta EnemyFrenzyBuffer      ;empty frenzy buffer
             lda TimerControl           ;if master timer control not set,
             beq ChkMouth               ;skip jump and execute code here
             jmp SkipToFB               ;otherwise, jump over a bunch of code
ChkMouth:  lda BowserBodyControls     ;check bowser's mouth
             bpl FeetTmr                ;if bit clear, go ahead with code here
             jmp HammerChk              ;otherwise skip a whole section starting here
FeetTmr:   dec BowserFeetCounter      ;decrement timer to control bowser's feet
             bne ResetMDr               ;if not expired, skip this part
             lda #$20                   ;otherwise, reset timer
             sta BowserFeetCounter        
             lda BowserBodyControls     ;and invert bit used
             eor #%00000001             ;to control bowser's feet
             sta BowserBodyControls
ResetMDr:  lda FrameCounter           ;check frame counter
             and #%00001111             ;if not on every sixteenth frame, skip
             bne B_FaceP                ;ahead to continue code
             lda #$02                   ;otherwise reset moving/facing direction every
             sta Enemy_MovingDir,x      ;sixteen frames
B_FaceP:   lda EnemyFrameTimer,x      ;if timer set here expired,
             beq GetPRCmp               ;branch to next section
             lda Enemy_X_Position,x     ;get distance between enemy object's
             sec                        ;horizontal coordinate and the player's
             sbc Player_X_Position      ;horizontal coordinate
             sta $00                    ;and store here
             lda Enemy_PageLoc,x
             sbc Player_PageLoc         ;subtract borrow, then leave
             bpl GetPRCmp               ;and branch if bowser to the right of the player
             lda #$01
             sta Enemy_MovingDir,x      ;set bowser to move and face to the right
             lda #$02
             sta BowserMovementSpeed    ;set movement speed
             lda #$20
             sta EnemyFrameTimer,x      ;set timer here
             sta BowserFireBreathTimer  ;set timer used for bowser's flame
             lda Enemy_X_Position,x        
             cmp #$c8                   ;if bowser to the right past a certain point,
             bcs HammerChk              ;skip ahead to some other section
GetPRCmp:  lda FrameCounter           ;get frame counter
             and #%00000011
             bne HammerChk              ;execute this code every fourth frame, otherwise branch
             lda Enemy_X_Position,x
             cmp BowserOrigXPos         ;if bowser not at original horizontal position,
             bne GetDToO                ;branch to skip this part
             lda PseudoRandomBitReg,x
             and #%00000011             ;get pseudorandom offset
             tay
             lda PRandomRange,y         ;load value using pseudorandom offset
             sta MaxRangeFromOrigin     ;and store here
GetDToO:     ;ldy #$16
             ;jsr BlockBufferChk_Enemy
             lda Enemy_X_Position,x
             clc                        ;add movement speed to bowser's horizontal
             adc BowserMovementSpeed    ;coordinate and save as new horizontal position
             sta Enemy_X_Position,x
             ldy Enemy_MovingDir,x
             cpy #$01                   ;if bowser moving and facing to the right, skip ahead
             beq HammerChk
             ldy #$ff                   ;set default movement speed here (move left)
             sec                        ;get difference of current vs. original
             sbc BowserOrigXPos         ;horizontal position
             bpl CompDToO               ;if current position to the right of original, skip ahead
             eor #$ff
             clc                        ;get two's compliment
             adc #$01
             ldy #$01                   ;set alternate movement speed here (move right)
CompDToO:  cmp MaxRangeFromOrigin     ;compare difference with pseudorandom value
             bcc HammerChk              ;if difference < pseudorandom value, leave speed alone
             sty BowserMovementSpeed    ;otherwise change bowser's movement speed
HammerChk: lda EnemyFrameTimer,x      ;if timer set here not expired yet, skip ahead to
             bne MakeBJump              ;some other section of code
             jsr MoveEnemySlowVert      ;otherwise start by moving bowser downwards
             lda WorldNumber            ;check world number
             cmp #World6
             bcc SetHmrTmr              ;if world 1-5, skip this part (not time to throw hammers yet)
             lda FrameCounter
             and #%00001111             ;check to see if it's time to execute sub
             bne SetHmrTmr              ;if not, skip sub, otherwise
             jsr SpawnHammerObj         ;execute sub on every fourth frame to spawn misc object (hammer)
SetHmrTmr:   
			 lda Enemy_Y_Speed,x
			 bmi ChkFireB
			 ldy #$22
             jsr BlockBufferChk_Enemy
             beq ChkFireB               ;then skip to world number check for flames
             cmp #$5f
             beq ChkFireB
             cmp #$91
             beq ChkFireB
             cmp #$c2
             beq ChkFireB
             cmp #$60
             beq ChkFireB
             lda Enemy_Y_Position,x
			 and #%11110000
             ;ora #%00000001
             sta Enemy_Y_Position,x
             lda PseudoRandomBitReg,x
             and #%00000011             ;get pseudorandom offset
             tay
             lda PRandomRange,y         ;get value using pseudorandom offset
             sta EnemyFrameTimer,x      ;set for timer here
SkipToFB:  jmp ChkFireB               ;jump to execute flames code
MakeBJump: cmp #$01                   ;if timer not yet about to expire,
             bne ChkFireB               ;skip ahead to next part
             dec Enemy_Y_Position,x     ;otherwise decrement vertical coordinate
             lda #$00                   ;initialize vertical speed
             sta Enemy_Y_Speed,x        ;and movement force
             sta Enemy_Y_MoveForce,x    ;initialize movement amount
             lda #$fe
             sta Enemy_Y_Speed,x        ;set vertical speed to move bowser upwards
ChkFireB:  lda WorldNumber            ;check world number here
             cmp #FinalWorld            ;world 8?
             beq SpawnFBr               ;if so, execute this part here
			 cmp #World9
			 beq SpawnFBr
             cmp #World6                ;world 6-7?
             bcs BowserGfxHandler       ;if so, skip this part here
SpawnFBr:  lda BowserFireBreathTimer  ;check timer here
             bne BowserGfxHandler       ;if not expired yet, skip all of this
             lda #$20
             sta BowserFireBreathTimer  ;set timer here
             lda BowserBodyControls
             eor #%10000000             ;invert bowser's mouth bit to open
             sta BowserBodyControls     ;and close bowser's mouth
             bmi ChkFireB               ;if bowser's mouth open, loop back
             jsr SetFlameTimer          ;get timing for bowser's flame
             ldy SecondaryHardMode
             beq SetFBTmr               ;if secondary hard mode flag not set, skip this
             sec
             sbc #$10                   ;otherwise subtract from value in A
SetFBTmr:  sta BowserFireBreathTimer  ;set value as timer here
             lda #BowserFlame           ;put bowser's flame identifier
             sta EnemyFrenzyBuffer      ;in enemy frenzy buffer
             
             
BowserGfxHandler:
             jsr ProcessBowserHalf    ;do a sub here to process bowser's front
             ldy #$10                 ;load default value here to position bowser's rear
             lda Enemy_MovingDir,x    ;check moving direction
             lsr
             bcc CopyFToR             ;if moving left, use default
             ldy #$f0                 ;otherwise load alternate positioning value here
CopyFToR: tya                      ;move bowser's rear object position value to A
             clc
             adc Enemy_X_Position,x   ;add to bowser's front object horizontal coordinate
             ldy DuplicateObj_Offset
             sta Enemy_X_Position,y   ;store A as bowser's rear horizontal coordinate
			 lda Enemy_PageLoc,x
			 sta Enemy_PageLoc,y
             lda Enemy_Y_Position,x
             clc                      ;add eight pixels to bowser's front object
             adc #$08                 ;vertical coordinate and store as vertical coordinate
             sta Enemy_Y_Position,y   ;for bowser's rear
             lda Enemy_State,x
             sta Enemy_State,y        ;copy enemy state directly from front to rear
             lda Enemy_MovingDir,x
             sta Enemy_MovingDir,y    ;copy moving direction also
             lda ObjectOffset         ;save enemy object offset of front to stack
             pha
             ldx DuplicateObj_Offset  ;put enemy object offset of rear as current
             stx ObjectOffset
             lda #Bowser              ;set bowser's enemy identifier
             sta Enemy_ID,x           ;store in bowser's rear object
             jsr ProcessBowserHalf    ;do a sub here to process bowser's rear
             pla
             sta ObjectOffset         ;get original enemy object offset
             tax
             lda #$00                 ;nullify bowser's front/rear graphics flag
             sta BowserGfxFlag
ExBGfxH:  rts                      ;leave!
             
ProcessBowserHalf:
             inc BowserGfxFlag         ;increment bowser's graphics flag, then run subroutines
             jsr RunRetainerObj        ;to get offscreen bits, relative position and draw bowser (finally!)
             lda Enemy_State,x
             bne ExBGfxH               ;if either enemy object not in normal state, branch to leave
             lda #$0a
             sta Enemy_BoundBoxCtrl,x  ;set bounding box size control
             jsr GetEnemyBoundBox      ;get bounding box coordinates
             jmp PlayerEnemyCollision  ;do player-to-enemy collision detection
             
             
FlameTimerData:
             .db $bf, $40, $bf, $bf, $bf, $40, $40, $bf
             
SetFlameTimer:
             ldy BowserFlameTimerCtrl  ;load counter as offset
             inc BowserFlameTimerCtrl  ;increment
             lda BowserFlameTimerCtrl  ;mask out all but 3 LSB
             and #%00000111            ;to keep in range of 0-7
             sta BowserFlameTimerCtrl
             lda FlameTimerData,y      ;load value to be used then leave
ExFl: rts
FlameYPosData1:
             .db $90, $80, $70, $90
ProcBowserFlame:
             lda TimerControl            ;if master timer control flag set,
             bne SetGfxF                 ;skip all of this
             lda #$40                    ;load default movement force
             ldy SecondaryHardMode
             beq SFlmX                   ;if secondary hard mode flag not set, use default
             lda #$60                    ;otherwise load alternate movement force to go faster
SFlmX:   sta $00                     ;store value here
             lda Enemy_X_MoveForce,x
             sec                         ;subtract value from movement force
             sbc $00
             sta Enemy_X_MoveForce,x     ;save new value
             lda Enemy_X_Position,x
             sbc #$01                    ;subtract one from horizontal position to move
             sta Enemy_X_Position,x      ;to the left
             lda Enemy_PageLoc,x
             sbc #$00                    ;subtract borrow from page location
             sta Enemy_PageLoc,x
             ldy BowserFlamePRandomOfs,x ;get some value here and use as offset
             lda Enemy_Y_Position,x      ;load vertical coordinate
             cmp FlameYPosData1,y         ;compare against coordinate data using $0417,x as offset
             beq SetGfxF                 ;if equal, branch and do not modify coordinate
             clc
             adc Enemy_Y_MoveForce,x     ;otherwise add value here to coordinate and store
             sta Enemy_Y_Position,x      ;as new vertical coordinate
SetGfxF: jsr RelativeEnemyPosition   ;get new relative coordinates
             lda Enemy_State,x           ;if bowser's flame not in normal state,
             bne ExFl                    ;branch to leave
             lda #$51                    ;otherwise, continue
             sta $00                     ;write first tile number
             ldy #$02                    ;load attributes without vertical flip by default
             lda FrameCounter
             and #%00000010              ;invert vertical flip bit every 2 frames
             beq FlmeAt                  ;if d1 not set, write default value
             ldy #$82                    ;otherwise write value with vertical flip bit set
FlmeAt:  sty $01                     ;set bowser's flame sprite attributes here
             ldy Enemy_SprDataOffset,x   ;get OAM data offset
             ldx #$00
             
DrawFlameLoop:
             lda Enemy_Rel_YPos         ;get Y relative coordinate of current enemy object
             sta Sprite_Y_Position,y    ;write into Y coordinate of OAM data
             lda $00
             sta Sprite_Tilenumber,y    ;write current tile number into OAM data
             inc $00                    ;increment tile number to draw more bowser's flame
             lda $01
             sta Sprite_Attributes,y    ;write saved attributes into OAM data
             lda Enemy_Rel_XPos
             sta Sprite_X_Position,y    ;write X relative coordinate of current enemy object
             clc
             adc #$08
             sta Enemy_Rel_XPos         ;then add eight to it and store
             iny
             iny
             iny
             iny                        ;increment Y four times to move onto the next OAM
             inx                        ;move onto the next OAM, and branch if three
             cpx #$03                   ;have not yet been done
             bcc DrawFlameLoop
             ldx ObjectOffset           ;reload original enemy offset
             jsr GetEnemyOffscreenBits  ;get offscreen information
             ldy Enemy_SprDataOffset,x  ;get OAM data offset
             lda Enemy_OffscreenBits    ;get enemy object offscreen bits
             lsr                        ;move d0 to carry and result to stack
             pha
             bcc M3FOfs                 ;branch if carry not set
             lda #$f8                   ;otherwise move sprite offscreen, this part likely
             sta Sprite_Y_Position+12,y ;residual since flame is only made of three sprites
M3FOfs:  pla                        ;get bits from stack
             lsr                        ;move d1 to carry and move bits back to stack
             pha
             bcc M2FOfs                 ;branch if carry not set again
             lda #$f8                   ;otherwise move third sprite offscreen
             sta Sprite_Y_Position+8,y
M2FOfs:  pla                        ;get bits from stack again
             lsr                        ;move d2 to carry and move bits back to stack again
             pha
             bcc M1FOfs                 ;branch if carry not set yet again
             lda #$f8                   ;otherwise move second sprite offscreen
             sta Sprite_Y_Position+4,y
M1FOfs:  pla                        ;get bits from stack one last time
             lsr                        ;move d3 to carry
             bcc ExFlmeD                ;branch if carry not set one last time
             lda #$f8
             sta Sprite_Y_Position,y    ;otherwise move first sprite offscreen
ExFlmeD: rts                        ;leave
             
             
RunFireworks:
             dec ExplosionTimerCounter,x ;decrement explosion timing counter here
             bne SetupExpl               ;if not expired, skip this part
             lda #$08
             sta ExplosionTimerCounter,x ;reset counter
             inc ExplosionGfxCounter,x   ;increment explosion graphics counter
             lda ExplosionGfxCounter,x
             cmp #$03                    ;check explosion graphics counter
             bcs FireworksSoundScore     ;if at a certain point, branch to kill this object
SetupExpl: jsr RelativeEnemyPosition   ;get relative coordinates of explosion
             lda Enemy_Rel_YPos          ;copy relative coordinates
             sta Fireball_Rel_YPos       ;from the enemy object to the fireball object
             lda Enemy_Rel_XPos          ;first vertical, then horizontal
             sta Fireball_Rel_XPos
             ldy Enemy_SprDataOffset,x   ;get OAM data offset
             lda ExplosionGfxCounter,x   ;get explosion graphics counter
             jmp DrawExplosion_Fireworks ;do a sub to draw the explosion then leave
             
FireworksSoundScore:
             lda #$00               ;disable enemy buffer flag
             sta Enemy_Flag,x
             lda #Sfx_Blast         ;play fireworks/gunfire sound
             sta Square2SoundQueue
             lda #$05               ;set part of score modifier for 500 points
             sta DigitModifier+4
             jmp EndAreaPoints     ;jump to award points accordingly then leave
             
             
StarFlagYPosAdder:
             .db $00, $00, $08, $08
             
StarFlagXPosAdder:
             .db $00, $08, $00, $08
             
StarFlagTileData:
             .db $54, $55, $56, $57
             
RunStarFlagObj:
             lda #$00                 ;initialize enemy frenzy buffer
             sta EnemyFrenzyBuffer
             lda StarFlagTaskControl  ;check star flag object task number here
             cmp #$05                 ;if greater than 5, branch to exit
             bcs StarFlagExit
             jsr JumpEngine           ;otherwise jump to appropriate sub
             
             .dw StarFlagExit
             .dw GameTimerFireworks
             if CHEATS && CHEAT_REMOVE_TIMER
             .dw DelayToAreaEnd     ; This works pretty well to remove timer points count down
             else
             .dw AwardGameTimerPoints
             endif
             .dw RaiseFlagSetoffFWorks
             .dw DelayToAreaEnd
             
GameTimerFireworks:
             ldy #$05               ;set default state for star flag object
             lda GameTimerDisplay+2 ;get game timer's last digit
             cmp #$01 
             beq SetFWC             ;if last digit of game timer set to 1, skip ahead
             ldy #$03               ;otherwise load new value for state
             cmp #$03
             beq SetFWC             ;if last digit of game timer set to 3, skip ahead
             ldy #$00               ;otherwise load one more potential value for state
             cmp #$06
             beq SetFWC             ;if last digit of game timer set to 6, skip ahead
             lda #$ff               ;otherwise set value for no fireworks
SetFWC: sta FireworksCounter   ;set fireworks counter here
             sty Enemy_State,x      ;set whatever state we have in star flag object
             
IncrementSFTask1:
             inc StarFlagTaskControl  ;increment star flag object task number
             lda #$78
             sta EndTimer
             lda #$00
             sta OldSquare1SoundBuffer
             ;jmp KillAllEnemiesNoFlag
StarFlagExit:
             rts                      ;leave
Toyota2: lda #$30
             sta SelectTimer        ;set select timer (used for world 8 ending only)
             lda #$06
             sta WorldEndTimer      ;another short delay, then on to the next task
             inc OperMode_Task
             rts
AwardGameTimerPoints2:
             ldx #$00
             lda GameTimerDisplay   ;check all game timer digits for any intervals left
             ora GameTimerDisplay+1
             bne AwardTimerCastle
             inx
             lda GameTimerDisplay+2
             beq Toyota2              ;if no time left on game timer at all, branch to next task
             jmp AwardTimerCastle
AwardGameTimerPoints:
             ldx #$00
             lda GameTimerDisplay   ;check all game timer digits for any intervals left
             ora GameTimerDisplay+1
             bne AwardTimerCastle
             inx
             lda GameTimerDisplay+2
             beq IncrementSFTask1   ;if no time left on game timer at all, branch to next task
AwardTimerCastle:
             lda FrameCounter
             and #%00000100         ;check frame counter for d2 set (skip ahead
             beq NoTTick            ;for four frames every four frames) branch if not set
             lda #$00
             sta tickid
             lda #Sfx_TimerTick
             sta Square2SoundQueue  ;load timer tick sound
NoTTick: ldy #$23               ;set offset here to subtract from game timer's last digit
             lda #$ff               ;set adder here to $ff, or -1, to subtract one
             sta DigitModifier+4,x  ;from the last digit of the game timer
             txa
             pha
             jsr DigitsMathRoutine  ;subtract digit
             pla
             tax
             lda #$01               ;set now to add 50 points
             cpx #$01
             bne +
             sta DigitModifier+5   ;per game timer interval subtracted
             jmp ++
+:         sta DigitModifier+4
++:         ldx ObjectOffset
             
EndAreaPoints:
             ldy #$0b               ;load offset for mario's score by default
ELPGive: jsr DigitsMathRoutine  ;award 50 points per game timer interval
             lda #%00000100         ;add four to set nybble for game timer
             jmp RealUpdateNumber       ;jump to print the new score and game timer
             
RaiseFlagSetoffFWorks:
             ;lda Enemy_Y_Position,x  ;check star flag's vertical position
             ;cmp #$72                ;against preset value
             ;bcc SetoffF             ;if star flag higher vertically, branch to other code
             ;dec Enemy_Y_Position,x  ;otherwise, raise star flag by one pixel
             ;jmp DrawStarFlag        ;and skip this part here
SetoffF: lda FireworksCounter    ;check fireworks counter
             beq DrawFlagSetTimer    ;if no fireworks left to go off, skip this part
             bmi DrawFlagSetTimer    ;if no fireworks set to go off, skip this part
             lda #Fireworks
             sta EnemyFrenzyBuffer   ;otherwise set fireworks object in frenzy queue
             
DrawStarFlag:
             rts
             ;jsr RelativeEnemyPosition  ;get relative coordinates of star flag
             ;ldy Enemy_SprDataOffset,x  ;get OAM data offset
             ;ldx #$03                   ;do four sprites
DSFLoop: ;lda Enemy_Rel_YPos         ;get relative vertical coordinate
             ;clc
             ;adc StarFlagYPosAdder,x    ;add Y coordinate adder data
             ;sta Sprite_Y_Position,y    ;store as Y coordinate
             ;lda StarFlagTileData,x     ;get tile number
             ;sta Sprite_Tilenumber,y    ;store as tile number
             ;lda #$22                   ;set palette and background priority bits
             ;sta Sprite_Attributes,y    ;store as attributes
             ;lda Enemy_Rel_XPos         ;get relative horizontal coordinate
             ;clc
             ;adc StarFlagXPosAdder,x    ;add X coordinate adder data
             ;sta Sprite_X_Position,y    ;store as X coordinate
             ;iny
             ;iny                        ;increment OAM data offset four bytes
             ;iny                        ;for next sprite
             ;iny
             ;dex                        ;move onto next sprite
             ;bpl DSFLoop                ;do this until all sprites are done
             ;ldx ObjectOffset           ;get enemy object offset and leave
             ;rts
             
DrawFlagSetTimer:
             ;jsr DrawStarFlag          ;do sub to draw star flag
             ldx ObjectOffset
             lda #$04
             sta EnemyIntervalTimer,x  ;set interval timer here
             
IncrementSFTask2:
             inc StarFlagTaskControl   ;move onto next task
             rts
             
DelayToAreaEnd:
             ;jsr DrawStarFlag          ;do sub to draw star flag
             lda EnemyIntervalTimer,x  ;if interval timer set in previous task
             bne StarFlagExit2         ;not yet expired, branch to leave
             lda SettingsBits
             beq +
             lda EndTimer
             beq IncrementSFTask2
             rts
+:    lda EndTimer              ;if event music buffer empty,
             ora EventMusicBuffer
             beq IncrementSFTask2
             ;jmp IncrementSFTask2      ;branch to increment task
             
StarFlagExit2:
             rts                       ;otherwise leave
             
Player_Difference:
             .db $21, $10
MovePiranhaPlant:
             lda Enemy_State,x           ;check enemy state
             bne PutinPipe               ;if set at all, branch to leave
             lda EnemyFrameTimer,x       ;check enemy's timer here
             bne PutinPipe               ;branch to end if not yet expired
             lda PiranhaPlant_MoveFlag,x ;check movement flag
             bne SetupToMovePPlant       ;if moving, skip to part ahead
             lda PiranhaPlant_Y_Speed,x  ;if currently rising, branch 
             bmi ReversePlantSpeed       ;to move enemy upwards out of pipe
             lda Enemy_X_Position,x      ;get distance between enemy object's
             sec                         ;horizontal coordinate and the player's
             sbc Player_X_Position       ;horizontal coordinate
             sta $00                     ;and store here
             lda Enemy_PageLoc,x
             sbc Player_PageLoc          ;subtract borrow, then leave
             bpl ChkPlayerNearPipe       ;piranha plant, and branch if enemy to right of player
             lda $00                     ;otherwise get saved horizontal difference
             eor #$ff
             clc                         ;and change to two's compliment
             adc #$01
             sta $00                     ;save as new horizontal difference
             
ChkPlayerNearPipe:
             lda Enemy_ID,x
             cmp #RedPiranhaPlant
             bne +
             ldy #$01
             jmp ++
+:    ldy HardModeFlag
++:      lda $00                     ;get saved horizontal difference
             cmp Player_Difference,y
             bcc PutinPipe               ;if player within a certain distance, branch to leave
             
ReversePlantSpeed:
             lda PiranhaPlant_Y_Speed,x  ;get vertical speed
             eor #$ff
             clc                         ;change to two's compliment
             adc #$01
             sta PiranhaPlant_Y_Speed,x  ;save as new vertical speed
             inc PiranhaPlant_MoveFlag,x ;increment to set movement flag
             
SetupToMovePPlant:
             lda PiranhaPlantDownYPos,x  ;get original vertical coordinate (lowest point)
             ldy PiranhaPlant_Y_Speed,x  ;get vertical speed
             bpl RiseFallPiranhaPlant    ;branch if moving downwards
             lda PiranhaPlantUpYPos,x    ;otherwise get other vertical coordinate (highest point)
             
RiseFallPiranhaPlant:
             sta $00                     ;save vertical coordinate here
             lda HardModeFlag
             bne +
             lda Enemy_ID,x
             cmp #RedPiranhaPlant
             beq +
             lda FrameCounter            ;get frame counter
             lsr
             bcc PutinPipe               ;branch to leave if d0 set (execute code every other frame)
+:    lda TimerControl            ;get master timer control
             bne PutinPipe               ;branch to leave if set (likely not necessary)
             lda Enemy_Y_Position,x      ;get current vertical coordinate
             clc
             adc PiranhaPlant_Y_Speed,x  ;add vertical speed to move up or down
             sta Enemy_Y_Position,x      ;save as new vertical coordinate
             cmp $00                     ;compare against low or high coordinate
             bne PutinPipe               ;branch to leave if not yet reached
             lda #$00
             sta PiranhaPlant_MoveFlag,x ;otherwise clear movement flag
             lda #$40
             sta EnemyFrameTimer,x       ;set timer to delay piranha plant movement
             
PutinPipe:
             rts                         ;then leave
             
             
BalancePlatform:
             lda Enemy_Y_HighPos,x       ;check high byte of vertical position
             cmp #$03
             bne DoBPl
             jmp EraseEnemyObject        ;if far below screen, kill the object
DoBPl: lda Enemy_State,x           ;get object's state (set to $ff or other platform offset)
             bpl CheckBalPlatform        ;if doing other balance platform, branch to leave
             rts
             
CheckBalPlatform:
             tay                         ;save offset from state as Y
             lda PlatformCollisionFlag,x ;get collision flag of platform
             sta $00                     ;store here
             lda Enemy_MovingDir,x       ;get moving direction
             beq ChkForFall
             jmp PlatformFall            ;if set, jump here
             
ChkForFall:
             lda #$2d                    ;check if platform is above a certain point
             cmp Enemy_Y_Position,x
             bcc ChkOtherForFall         ;if not, branch elsewhere
             cpy $00                     ;if collision flag is set to same value as
             beq MakePlatformFall        ;enemy state, branch to make platforms fall
             clc
             adc #$02                    ;otherwise add 2 pixels to vertical position
             sta Enemy_Y_Position,x      ;of current platform and branch elsewhere
             jmp StopPlatforms           ;to make platforms stop
             
MakePlatformFall:
             jmp InitPlatformFall        ;make platforms fall
             
ChkOtherForFall:
             cmp Enemy_Y_Position,y      ;check if other platform is above a certain point
             bcc ChkToMoveBalPlat        ;if not, branch elsewhere
             cpx $00                     ;if collision flag is set to same value as
             beq MakePlatformFall        ;enemy state, branch to make platforms fall
             clc
             adc #$02                    ;otherwise add 2 pixels to vertical position
             sta Enemy_Y_Position,y      ;of other platform and branch elsewhere
             jmp StopPlatforms           ;jump to stop movement and do not return
             
ChkToMoveBalPlat:
             sty temp6
             lda Enemy_Y_Position,x      ;save vertical position to stack
             pha
             lda PlatformCollisionFlag,x ;get collision flag
             bpl ColFlg                  ;branch if collision
             lda Enemy_Y_MoveForce,x
             clc                         ;add $05 to contents of moveforce, whatever they be
             adc #$05
             sta $00                     ;store here
             lda Enemy_Y_Speed,x
             adc #$00                    ;add carry to vertical speed
             bmi PlatDn                  ;branch if moving downwards
             bne PlatUp                  ;branch elsewhere if moving upwards
             lda $00
             cmp #$0b                    ;check if there's still a little force left
             bcc PlatSt                  ;if not enough, branch to stop movement
             bcs PlatUp                  ;otherwise keep branch to move upwards
ColFlg: cmp ObjectOffset            ;if collision flag matches
             beq PlatDn                  ;current enemy object offset, branch
PlatUp: jsr MovePlatformUp          ;do a sub to move upwards
             jmp DoOtherPlatform         ;jump ahead to remaining code
PlatSt: jsr StopPlatforms           ;do a sub to stop movement
             jmp DoOtherPlatform         ;jump ahead to remaining code
PlatDn: jsr MovePlatformDown        ;do a sub to move downwards
             
DoOtherPlatform:
             ldy Enemy_State,x           ;get offset of other platform
             pla                         ;get old vertical coordinate from stack
             sec
             sbc Enemy_Y_Position,x      ;get difference of old vs. new coordinate
             clc
             adc Enemy_Y_Position,y      ;add difference to vertical coordinate of other
             sta Enemy_Y_Position,y      ;platform to move it in the opposite direction
             lda PlatformCollisionFlag,x ;if no collision, skip this part here
             bmi DrawEraseRope
             tax                         ;put offset which collision occurred here
             jsr PositionPlayerOnVPlat   ;and use it to position player accordingly
             
DrawEraseRope:
             ldy ObjectOffset            ;get enemy object offset
             lda Enemy_Y_Speed,y         ;check to see if current platform is
             ora Enemy_Y_MoveForce,y     ;moving at all
             beq ExitRp                  ;if not, skip all of this and branch to leave
             ldx VRAM_Buffer1_Offset     ;get vram buffer offset
             cpx #$20                    ;if offset beyond a certain point, go ahead
             bcs ExitRp                  ;and skip this, branch to leave
             lda Enemy_Y_Speed,y
             pha                         ;save two copies of vertical speed to stack
             pha
             jsr SetupPlatformRope       ;do a sub to figure out where to put new bg tiles
             lda $01                     ;write name table address to vram buffer
             sta VRAM_Buffer1,x          ;first the high byte, then the low
             lda $00
             sta VRAM_Buffer1+1,x
             lda #$02                    ;set length for 2 bytes
             sta VRAM_Buffer1+2,x
             lda Enemy_Y_Speed,y         ;if platform moving upwards, branch 
             bmi EraseR1                 ;to do something else
             lda #$a2
             sta VRAM_Buffer1+3,x        ;otherwise put tile numbers for left
             lda #$a3                    ;and right sides of rope in vram buffer
             sta VRAM_Buffer1+4,x
             jmp OtherRope               ;jump to skip this part
EraseR1: lda #$24                    ;put blank tiles in vram buffer
             sta VRAM_Buffer1+3,x        ;to erase rope
             sta VRAM_Buffer1+4,x
             
OtherRope:
             lda Enemy_State,y           ;get offset of other platform from state
             tay                         ;use as Y here
             pla                         ;pull second copy of vertical speed from stack
             eor #$ff                    ;invert bits to reverse speed
             jsr SetupPlatformRope       ;do sub again to figure out where to put bg tiles  
             lda $01                     ;write name table address to vram buffer
             sta VRAM_Buffer1+5,x        ;this time we're doing putting tiles for
             lda $00                     ;the other platform
             sta VRAM_Buffer1+6,x
             lda #$02
             sta VRAM_Buffer1+7,x        ;set length again for 2 bytes
             pla                         ;pull first copy of vertical speed from stack
             bpl EraseR2                 ;if moving upwards (note inversion earlier), skip this
             lda #$a2
             sta VRAM_Buffer1+8,x        ;otherwise put tile numbers for left
             lda #$a3                    ;and right sides of rope in vram
             sta VRAM_Buffer1+9,x        ;transfer buffer
             jmp EndRp                   ;jump to skip this part
EraseR2: lda #$24                    ;put blank tiles in vram buffer
             sta VRAM_Buffer1+8,x        ;to erase rope
             sta VRAM_Buffer1+9,x
EndRp:   lda #$00                    ;put null terminator at the end
             sta VRAM_Buffer1+10,x
             lda VRAM_Buffer1_Offset     ;add ten bytes to the vram buffer offset
             clc                         ;and store
             adc #10
             sta VRAM_Buffer1_Offset
ExitRp:  ldx ObjectOffset            ;get enemy object buffer offset and leave
             rts
             
SetupPlatformRope:
             pha                     ;save second/third copy to stack
             lda Enemy_X_Position,y  ;get horizontal coordinate
             clc
             adc #$08                ;add eight pixels
             ldx SecondaryHardMode   ;if secondary hard mode flag set,
             bne GetLRp              ;use coordinate as-is
             clc
             adc #$10                ;otherwise add sixteen more pixels
GetLRp: pha                     ;save modified horizontal coordinate to stack
             lda Enemy_PageLoc,y
             adc #$00                ;add carry to page location
             sta $02                 ;and save here
             pla                     ;pull modified horizontal coordinate
             and #%11110000          ;from the stack, mask out low nybble
             lsr                     ;and shift three bits to the right
             lsr
             lsr
             sta $00                 ;store result here as part of name table low byte
             ldx Enemy_Y_Position,y  ;get vertical coordinate
             pla                     ;get second/third copy of vertical speed from stack
             bpl GetHRp              ;skip this part if moving downwards or not at all
             txa
             clc
             adc #$08                ;add eight to vertical coordinate and
             tax                     ;save as X
GetHRp: txa                     ;move vertical coordinate to A
             ldx VRAM_Buffer1_Offset ;get vram buffer offset
             asl
             rol                     ;rotate d7 to d0 and d6 into carry
             pha                     ;save modified vertical coordinate to stack
             rol                     ;rotate carry to d0, thus d7 and d6 are at 2 LSB
             and #%00000011          ;mask out all bits but d7 and d6, then set
             ora #%00100000          ;d5 to get appropriate high byte of name table
             sta $01                 ;address, then store
             lda $02                 ;get saved page location from earlier
             and #$01                ;mask out all but LSB
             asl
             asl                     ;shift twice to the left and save with the
             ora $01                 ;rest of the bits of the high byte, to get
             sta $01                 ;the proper name table and the right place on it
             pla                     ;get modified vertical coordinate from stack
             and #%11100000          ;mask out low nybble and LSB of high nybble
             clc
             adc $00                 ;add to horizontal part saved here
             sta $00                 ;save as name table low byte
             lda Enemy_Y_Position,y
             cmp #$e8                ;if vertical position not below the
             bcc ExPRp               ;bottom of the screen, we're done, branch to leave
             lda $00
             and #%10111111          ;mask out d6 of low byte of name table address
             sta $00
ExPRp:  rts                     ;leave!
             
InitPlatformFall:
             tya                        ;move offset of other platform from Y to X
             tax
             jsr GetEnemyOffscreenBits  ;get offscreen bits
             lda #$05
             jsr SetupFloateyNumber     ;award 1000 points to player
             lda Player_Rel_XPos
             sta FloateyNum_X_Pos,x     ;put floatey number coordinates where player is
             lda Player_Y_Position
             sta FloateyNum_Y_Pos,x
             lda #$01                   ;set moving direction as flag for
             sta Enemy_MovingDir,x      ;falling platforms
             
StopPlatforms:
             lda #$00                    ;initialize vertical speed
             sta Enemy_Y_Speed,x         ;and movement force
             sta Enemy_Y_MoveForce,x     ;initialize vertical speed and low byte
             sta Enemy_Y_Speed,y            ;for both platforms and leave
             sta Enemy_Y_MoveForce,y
             rts
             
PlatformFall:
             tya                         ;save offset for other platform to stack
             pha
             jsr MoveFallingPlatform     ;make current platform fall
             pla
             tax                         ;pull offset from stack and save to X
             jsr MoveFallingPlatform     ;make other platform fall
             ldx ObjectOffset
             lda PlatformCollisionFlag,x ;if player not standing on either platform,
             bmi ExPF                    ;skip this part
             tax                         ;transfer collision flag offset as offset to X
             jsr PositionPlayerOnVPlat   ;and position player appropriately
ExPF: ldx ObjectOffset            ;get enemy object buffer offset and leave
             rts
             
             
YMovingPlatform:
             lda Enemy_Y_Speed,x          ;if platform moving up or down, skip ahead to
             ora Enemy_Y_MoveForce,x      ;check on other position
             bne ChkYCenterPos
             sta Enemy_YMF_Dummy,x        ;initialize dummy variable
             lda Enemy_Y_Position,x
             cmp YPlatformTopYPos,x       ;if current vertical position => top position, branch
             bcs ChkYCenterPos            ;ahead of all this
             lda FrameCounter
             and #%00000111               ;check for every eighth frame
             bne SkipIY
             inc Enemy_Y_Position,x       ;increase vertical position every eighth frame
SkipIY: jmp ChkYPCollision           ;skip ahead to last part
             
ChkYCenterPos:
             lda Enemy_Y_Position,x       ;if current vertical position < central position, branch
             cmp YPlatformCenterYPos,x    ;to slow ascent/move downwards
             bcc YMDown
             jsr MovePlatformUp           ;otherwise start slowing descent/moving upwards
             jmp ChkYPCollision
YMDown: jsr MovePlatformDown         ;start slowing ascent/moving downwards
             
ChkYPCollision:
             lda PlatformCollisionFlag,x  ;if collision flag not set here, branch
             bmi ExYPl                    ;to leave
             jmp PositionPlayerOnVPlat    ;otherwise position player appropriately
ExYPl: rts                          ;leave
             
             
XMovingPlatform:
             lda #$0e                     ;load preset maximum value for secondary counter
             jsr XMoveCntr_Platform       ;do a sub to increment counters for movement
             jsr MoveWithXMCntrs          ;do a sub to move platform accordingly, and return value
             lda PlatformCollisionFlag,x  ;if no collision with player,
             bmi ExXMP                    ;branch ahead to leave
             
PositionPlayerOnHPlat:
             lda #$00
             sta StompChainCounter
             lda Player_CollisionBits
             and #$01
             beq ExXMP
             lda Player_X_Position
             clc                       ;add saved value from second subroutine to
             adc $00                   ;current player's position to position
             sta Player_X_Position     ;player accordingly in horizontal position
             lda Player_PageLoc        ;get player's page location
             ldy $00                   ;check to see if saved value here is positive or negative
             bmi PPHSubt               ;if negative, branch to subtract
             adc #$00                  ;otherwise add carry to page location
             jmp SetPVar               ;jump to skip subtraction
PPHSubt: sbc #$00                  ;subtract borrow from page location
SetPVar: sta Player_PageLoc        ;save result to player's page location
             sty Platform_X_Scroll     ;put saved value from second sub here to be used later
             lda Player_X_Position
             clc
             adc #$01
             cmp ScreenLeft_X_Pos
             bne +
             inc Player_X_Position
+:       jmp PositionPlayerOnVPlat ;position player vertically and appropriately
ExXMP:   rts                       ;and we are done here
             
             
DropPlatform:
             lda PlatformCollisionFlag,x  ;if no collision between platform and player
             bmi ExXMP                    ;occurred, just leave without moving anything
             jsr MoveDropPlatform         ;otherwise do a sub to move platform down very quickly
             jmp PositionPlayerOnVPlat    ;do a sub to position player appropriately
             
             
RightPlatform:
             inx                         ;increment offset for enemy offset
             jsr MoveObjectHorizontally  ;position object horizontally according to
             ldx ObjectOffset            ;counters, return with saved value in A,
             ;sta $00                       ;store saved value here (residual code)
			 lda Enemy_PageLoc,x
			 cmp #$09
			 bne +
			 lda Enemy_X_Position,x
			 cmp #$a0
			 bne +
			 lda #$00
			 sta Enemy_X_Speed,x
			 rts
+:           lda PlatformCollisionFlag,x   ;check collision flag, if no collision between player
             bmi ExXMP                     ;and platform, branch ahead, leave speed unaltered
             lda #$10
             sta Enemy_X_Speed,x           ;otherwise set new speed (gets moving if motionless)
             jmp PositionPlayerOnHPlat     ;use saved value from earlier sub to position player
             
             
MoveLargeLiftPlat:
             jsr MoveLiftPlatforms  ;execute common to all large and small lift platforms
             jmp ChkYPCollision     ;branch to position player correctly
             
MoveSmallPlatform:
             jsr MoveLiftPlatforms      ;execute common to all large and small lift platforms
             jmp ChkSmallPlatCollision  ;branch to position player correctly
             
MoveLiftPlatforms:
             lda TimerControl         ;if master timer control set, skip all of this
             bne ExLiftP              ;and branch to leave
             lda Enemy_YMF_Dummy,x
             clc                      ;add contents of movement amount to whatever's here
             adc Enemy_Y_MoveForce,x
             sta Enemy_YMF_Dummy,x
             lda Enemy_Y_Position,x   ;add whatever vertical speed is set to current
             adc Enemy_Y_Speed,x      ;vertical position plus carry to move up or down
             sta Enemy_Y_Position,x   ;and then leave
             rts
             
ChkSmallPlatCollision:
             lda PlatformCollisionFlag,x ;get bounding box counter saved in collision flag
             beq ExLiftP                 ;if none found, leave player position alone
             jmp PositionPlayerOnS_Plat  ;use to position player correctly
ExLiftP: rts                         ;then leave
             
OffscreenXoffset: .db $30, $80
OffscreenBoundsCheck:
             lda Enemy_ID,x          ;check for cheep-cheep object
             cmp #FlyingCheepCheep   ;branch to leave if found
             beq ExLiftP
             ldy #$00
             cmp #PowerUpObject
             bne +
             iny
+:        
             lda ScreenLeft_X_Pos    ;get horizontal coordinate for left side of screen
             sec
             sbc OffscreenXoffset,y  ;subtract 72 pixels regardless of enemy object
             sta $01                 ;store result here
             lda ScreenLeft_PageLoc
             sbc #$00                ;subtract borrow from page location of left side
             sta $00                 ;store result here
             lda ScreenRight_X_Pos   ;add 72 pixels to the right side horizontal coordinate
             clc
             adc OffscreenXoffset,y
             sta $03                 ;store result here
             lda ScreenRight_PageLoc     
             adc #$00                ;then add the carry to the page location
             sta $02                 ;and store result here
             lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
             cmp $01                 ;to modified horizontal left edge coordinate to get carry
             lda Enemy_PageLoc,x
             sbc $00                 ;then subtract it from the page coordinate of the enemy object
             bmi TooFar              ;if enemy object is too far left, branch to erase it
             lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
             cmp $03                 ;to modified horizontal right edge coordinate to get carry
             lda Enemy_PageLoc,x
             sbc $02                 ;then subtract it from the page coordinate of the enemy object
             bmi ExScrnBd            ;if enemy object is on the screen, leave, do not erase enemy
TooFar:   ldy SavedOffset,x
             lda Saved_isDefeated,y
             cmp #$02
             beq +
             lda #$00
             sta Saved_isDefeated,y
+:          jmp EraseEnemyObject    ;erase object if necessary
ExScrnBd: rts                     ;leave
ExitFBallEnemy2:
             ldx ObjectOffset                 ;get original fireball offset and leave
             rts
             
FireballEnemyCollision:
             lda Fireball_State,x  ;check to see if fireball state is set at all
             beq ExitFBallEnemy2   ;branch to leave if not
             bmi ExitFBallEnemy2    ;branch to leave also if d7 in state is set
             lda #%00010000
             sta tempA
             lda FrameCounter
             lsr                   ;get LSB of frame counter
             bcs ExitFBallEnemy    ;branch to leave if set (do routine every other frame)
             txa
             asl                   ;multiply fireball offset by four
             asl
             clc
             adc #$1c              ;then add $1c or 28 bytes to it
             tay                   ;to use fireball's bounding box coordinates 
             ldx #$05
             
FireballEnemyCDLoop:
             stx $01                     ;store enemy object offset here
             tya
             pha                         ;push fireball offset to the stack
             lda Enemy_State,x
             and #%00100000              ;check to see if d5 is set in enemy state
             bne NoFToECol               ;if so, skip to next enemy slot
             lda Enemy_Flag,x            ;check to see if buffer flag is set
             beq NoFToECol               ;if not, skip to next enemy slot
             lda Enemy_ID,x              ;check enemy identifier
             cmp #Sign
             beq NoFToECol
             cmp #PowerUpObject
             beq NoFToECol
             cmp #$30
             beq NoFToECol
             cmp #$24
             bcc GoombaDie               ;if < $24, branch to check further
             cmp #$26
             beq GoombaDie
             cmp #$2b
             bcc NoFToECol               ;if in range $24-$2a, skip to next enemy slot
GoombaDie: cmp #Goomba                 ;check for goomba identifier
             beq +
             cmp #FastGoomba
             bne NotGoomba               ;if not found, continue with code
+:         lda Enemy_State,x           ;otherwise check for defeated state
             cmp #$02                    ;if stomped or otherwise defeated,
             bcs NoFToECol               ;skip to next enemy slot
NotGoomba: lda EnemyOffscrBitsMasked,x ;if any masked offscreen bits set,
             bne NoFToECol               ;skip to next enemy slot
             txa
             asl                         ;otherwise multiply enemy offset by four
             asl
             clc
             adc #$04                    ;add 4 bytes to it
             tax                         ;to use enemy's bounding box coordinates
             jsr SprObjectCollisionCore  ;do fireball-to-enemy collision detection
             ldx ObjectOffset            ;return fireball's original offset
             bcc NoFToECol               ;if carry clear, no collision, thus do next enemy slot
             lda #%10000000
             sta Fireball_State,x        ;set d7 in enemy state
             ldx $01                     ;get enemy offset
             jsr HandleEnemyFBallCol     ;jump to handle fireball to enemy collision
             lda Enemy_ID,x
             cmp #PiranhaPlant
             beq +
             cmp #RUDPiranhaPlant
             beq +
             cmp #RedPiranhaPlant
             beq +
             cmp #UDPiranhaPlant
             bne NoFToECol
+:           lda #$ff
             sta Enemy_Y_Position,x
             jmp NoFToECol
NoFToECol: ldx $01
             pla                         ;pull fireball offset from stack
             tay                         ;put it in Y
             ldx $01                     ;get enemy object offset
             dex                         ;decrement it
             bpl FireballEnemyCDLoop     ;loop back until collision detection done on all enemies
             
ExitFBallEnemy:
             ldx ObjectOffset                 ;get original fireball offset and leave
testt:
             rts
             
BowserIdentities:
             .db Goomba, GreenKoopa, BuzzyBeetle, Spiny, Lakitu, Bloober, HammerBro, Bowser
ChkOtherEnemies1:
             jmp ChkOtherEnemies
             
HandleEnemyFBallCol:
             lda #$01                     ;get coordinates of enemy object 
             tay
             stx $00                     ;store value to add to A here
             clc
             adc $00                     ;add A to value stored
             tax                         ;use as enemy offset
             lda SprObject_Y_Position,x  ;load vertical coordinate lo
             sta SprObject_Rel_YPos,y    ;store here
             lda SprObject_X_Position,x  ;load horizontal coordinate
             sec                         ;subtract left edge coordinate
             sbc ScreenLeft_X_Pos
             sta SprObject_Rel_XPos,y    ;store result here
             ldx $01                    ;get current enemy object offset
             lda Enemy_Flag,x           ;check buffer flag for d7 set
             bpl ChkBuzzyBeetle         ;branch if not set to continue
             and #%00001111             ;otherwise mask out high nybble and
             tax                        ;use low nybble as enemy offset
             lda Enemy_ID,x
             cmp #Bowser                ;check enemy identifier for bowser
             beq HurtBowser             ;branch if found
             ldx $01                    ;otherwise retrieve current enemy offset
             
ChkBuzzyBeetle:
             lda Enemy_ID,x
             cmp #BuzzyBeetle           ;check for buzzy beetle
             beq testt                  ;branch if found to leave (buzzy beetles fireproof)
             cmp #Bowser                ;check for bowser one more time (necessary if d7 of flag was clear)
             bne ChkOtherEnemies1       ;if not found, branch to check other enemies
             
HurtBowser:
             lda BowserKilled
             bne ExHurtBowser
             lda BowserGotHit
             bne +
             dec BowserHitPoints
             inc BowserGotHit
+:           jsr BowserHPDisplay
             lda BowserHitPoints
             bne ExHurtBowser                ;if bowser still has hit points, branch to leave
             lda #$01
             sta BowserKilled
             lsr                    ;initialize vertical speed
             sta Enemy_Y_Speed,x         ;and movement force
             sta Enemy_Y_MoveForce,x
             sta Enemy_X_Speed,x        ;initialize horizontal speed
             sta EnemyFrenzyBuffer      ;init enemy frenzy buffer
             lda #$fe
             sta Enemy_Y_Speed,x        ;set vertical speed to make defeated bowser jump a little
             lda WorldNumber            ;use world number as offset
             and #%00000111
             tay
             lda BowserIdentities,y     ;get enemy identifier to replace bowser with
             sta Enemy_ID,x             ;set as new enemy identifier
             lda #$20                   ;set A to use starting value for state
             cpy #$03                   ;check to see if using offset of 3 or more
             bcs SetDBSte               ;branch if so
             ora #$03                   ;otherwise add 3 to enemy state
SetDBSte: sta Enemy_State,x          ;set defeated enemy state
             lda #Sfx_BowserFall
             sta Square2SoundQueue      ;load bowser defeat sound
             
             
             
             
             
             ldx $01                    ;get enemy offset
             lda #$0a                   ;award 5000 points to player for defeating bowser
             jmp EnemySmackScore        ;unconditional branch to award points
ExHurtBowser: rts            
ChkOtherEnemies:
             cmp #BulletBill_FrenzyVar
             beq ExHurtBowser                 ;branch to leave if bullet bill (frenzy variant) 
             cmp #Podoboo       
             beq ExHurtBowser                 ;branch to leave if podoboo
             cmp #BlackParatroopa
             beq ExHurtBowser
             cmp #RedKoopaShell
             beq ShellOrBlockDefeat
             cmp #UDPiranhaPlant
             beq ShellOrBlockDefeat
             cmp #RUDPiranhaPlant
             beq ShellOrBlockDefeat
             cmp #RedPiranhaPlant
             beq ShellOrBlockDefeat
             cmp #$15       
             bcc ShellOrBlockDefeat                 ;branch to leave if identifier => $15
ExHCF2:
             rts
ShellOrBlockDefeat:
             lda GrabFlag
             beq +
             cpx GrabID
             bne +
             rts
+:      lda Enemy_ID,x            ;check for piranha plant
             cmp #BlackParatroopa
             beq ExHCF2
			 cmp #Sign
			 beq ExHCF2
             cmp #UDPiranhaPlant
             beq +
             cmp #RUDPiranhaPlant
             beq +
             cmp #RedPiranhaPlant
             beq +
             cmp #PiranhaPlant
             bne StnE                  ;branch if not found
+:    jmp KillPlant
StnE: 
			 ;lda Enemy_ID,x
			 ;cmp #Bowser
			 ;bne +		
			 ;jmp HurtBowser
+:			 
			 jsr ChkToStunEnemies      ;do yet another sub
             lda Enemy_State,x
             and #%00011111            ;mask out 2 MSB of enemy object's state
             ora #%00100000            ;set d5 to defeat enemy and save as new state
             sta Enemy_State,x
             ldy SavedOffset,x
             lda #$02
             sta Saved_isDefeated,y
             lda #$02                  ;award 200 points by default
             ldy Enemy_ID,x            ;check for hammer bro
             cpy #HammerBro
             bne GoombaPoints          ;branch if not found
             lda #$05                  ;award 1000 points for hammer bro
             
GoombaPoints:
             cpy #Lakitu
             beq LakituPoints
             cpy #Goomba               ;check for goomba
             beq +
             cpy #FastGoomba
             bne EnemySmackScore       ;branch if not found
+:    lda #$01                  ;award 100 points for goomba
             jmp EnemySmackScore
LakituPoints:
             lda #$01
             sta LakituRespawning
             lda #$07
EnemySmackScore:
             ldy StarInvincibleTimer
             ;cpy #$00
             beq Her
             jmp StarCollisions
Her:   sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
             lda #Sfx_EnemySmack      ;play smack enemy sound
             ora tempA
             sta Square1SoundQueue
ExHCF: rts                      ;and now let's leave
             
StarCollisions:
             inc StarChainCounter     ;increment chain counter for additional enemies
             lda EnemyDefeatPitch     ;get chain counter for shell
             cmp #$09
             beq +
             inc EnemyDefeatPitch
+:      lda StarChainCounter
             sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
             lda #Sfx_EnemySmack      ;play smack enemy sound
             sta Square1SoundQueue
             lda Enemy_ID,x
             cmp #PiranhaPlant
             beq ++
             cmp #RUDPiranhaPlant
             beq ++
             cmp #RedPiranhaPlant
             beq ++
             cmp #UDPiranhaPlant
             bne +
++:      lda #$ff
             sta Enemy_Y_Position,x
+:      jmp ExHCF
             
PlayerHammerCollision:
             lda FrameCounter          ;get frame counter
             lsr                       ;shift d0 into carry
             bcc ExPHC                 ;branch to leave if d0 not set to execute every other frame
             lda TimerControl          ;if either master timer control
             ora Misc_OffscreenBits    ;or any offscreen bits for hammer are set,
             bne ExPHC                 ;branch to leave
             lda GameEngineSubroutine
             cmp #$08                    ;if not set to run player control routine
             bne ExPHC                 ;on next frame, branch to leave
             txa
             asl                       ;multiply misc object offset by four
             asl
             clc
             adc #$24                  ;add 36 or $24 bytes to get proper offset
             tay                       ;for misc object bounding box coordinates
             jsr PlayerCollisionCore   ;do player-to-hammer collision detection
             ldx ObjectOffset          ;get misc object offset
             bcc ClHCol                ;if no collision, then branch
             lda Misc_Collision_Flag,x ;otherwise read collision flag
             bne ExPHC                 ;if collision flag already set, branch to leave
             lda #$01
             sta Misc_Collision_Flag,x ;otherwise set collision flag now
             lda Misc_X_Speed,x
             eor #$ff                  ;get two's compliment of
             clc                       ;hammer's horizontal speed
             adc #$01
             sta Misc_X_Speed,x        ;set to send hammer flying the opposite direction
             lda StarInvincibleTimer   ;if star mario invincibility timer set,
             bne ExPHC                 ;branch to leave
             jmp InjurePlayer          ;otherwise jump to hurt player, do not return
ClHCol: lda #$00                  ;clear collision flag
             sta Misc_Collision_Flag,x
ExPHC:  rts
             
             
HandlePowerUpCollision:
             lda $7fce,x
             sta PowerUpType
             jsr EraseEnemyObject    ;erase the power-up object
             lda #$05
             jsr SetupFloateyNumber  ;award 1000 points to player by default
             lda PowerUpType
             cmp #$03                  ;if 1-up mushroom, do not play the power-up sound
             beq ++
             ldy #Sfx_PowerUpGrab
             sty Square2SoundQueue   ;play the power-up sound
++:   cmp #$00
             beq Shroom_PUp
             cmp #$01
             beq Flower_PUp          ;if mushroom or fire flower, branch
             cmp #$03
             beq SetFor1Up           ;if 1-up mushroom, branch               
             lda StarInvincibleTimer
             bne +
             lda #$00
             sta StarChainCounter
             sta EnemyDefeatPitch
+:    lda #StarPowerMusic     ;into the area music queue, then leave
             sta AreaMusicQueue
             lda #$23               ;otherwise set star mario invincibility
             sta StarInvincibleTimer ;timer, and load the star mario music
             rts
Shroom_PUp:
             jmp UpToSuper
Flower_PUp:
             lda PlayerStatus
             cmp #$02
             beq NoPUp
             lda #$02            ;set player status to fiery
             sta PlayerStatus
             lda #$00
             sta PlayerSize
             jsr GetPlayerColors ;run sub to change colors of player
             ;ldx ObjectOffset    ;get enemy offset again, and again not necessary
             lda #$0c            ;set value to be used by subroutine tree (fiery)
             jmp UpToFiery       ;jump to set values accordingly
SetFor1Up:
             lda #$09                 ;change 1000 points into 1-up instead
             sta FloateyNum_Control,x ;and then leave
NoPUp: 
             rts
UpToSuper:
             lda PlayerStatus
             bne NoPUp
             lda #$01             ;set player status to super
             sta PlayerStatus
             lda #$09             ;set value to be used by subroutine tree (super)
UpToFiery:
             ldy #$00         ;set value to be used as new player state
             jmp SetPRout     ;set values to stop certain things in motionrts
             
ResidualXSpdData:
             
KickedShellXSpdData:
             .db $38, $c8
             
DemotedKoopaXSpdData:
             .db $08, $f8, $0e, $f1
             
PlayerEnemyCollision:
             lda Player_OffscreenBits    ;if player object is completely offscreen
             cmp #$f0                    ;vertically, leave this routine
             bcs +
             ldy Player_Y_HighPos        ;if player high vertical byte is not
             dey
             bne +
             lda Player_Y_Position        ;if on the screen, check to see how far down
             cmp #$d0                    ;the player is vertically
+:       bcs NoPECol                 ;if down past 224th pixel row, branch to leave
             ;ldx ObjectOffset
             lda EnemyOffscrBitsMasked,x ;if current enemy is offscreen by any amount,
             bne NoPECol                 ;go ahead and branch to leave
             lda GameEngineSubroutine
             cmp #$08                    ;if not set to run player control routine
             bne NoPECol                 ;on next frame, branch to leave
             lda Enemy_State,x
             and #%00100000              ;if enemy state has d5 set, branch to leave
             bne NoPECol
             lda ObjectOffset         ;get enemy object buffer offset
             asl                      ;multiply A by four, then add four
             asl                      ;to skip player's bounding box
             clc
             adc #$04
             tay                      ;send to Y
             lda Enemy_OffscreenBits  ;get offscreen bits for enemy object
             and #%00001111           ;save low nybble
             cmp #%00001111           ;check for all bits set
             jsr PlayerCollisionCore     ;do collision detection on player vs. enemy
             ;ldy $06                      ;otherwise return with carry clear and Y = $0006
             ldx ObjectOffset            ;get enemy object buffer offset
             bcs CheckForPUpCollision    ;if collision, branch past this part here
             lda Enemy_CollisionBits,x
             and #%11111110              ;otherwise, clear d0 of current enemy object's
             sta Enemy_CollisionBits,x   ;collision bit
NoPECol: rts
HandleSignInteraction: jmp SignDoStuff   
CheckForPUpCollision:
             ldy Enemy_ID,x
             cpy #PowerUpObject            ;check for power-up object
             bne EColl                     ;if not found, branch to next part
             jmp HandlePowerUpCollision    ;otherwise, unconditional jump backwards
EColl:       cpy #Sign
             beq HandleSignInteraction
			 lda StarInvincibleTimer       ;if star mario invincibility timer expired,
             beq HandlePECollisions        ;perform task here, otherwise kill enemy like
             lda GrabFlag
             beq +
             cpx GrabID
             bne +
             lda #$00
             sta GrabFlag
             sta GrabUp
             sta GrabDown
+:       jsr ShellOrBlockDefeat        ;hit with a shell, or from beneath
             lda Enemy_ID,x
             cmp #PiranhaPlant
             beq +
             cmp #RUDPiranhaPlant
             beq +
             cmp #RedPiranhaPlant
             beq +
             cmp #UDPiranhaPlant
             bne NoPECol
+:       lda #$ff
             sta Enemy_Y_Position,x
             rts
KickedShellPtsData:
             .db $08, $05, $04
             
ShellUp:
             lda #$01
             sta GrabUp
             ;sta GrabDown
             lda #$f9
             sta Enemy_Y_Speed,x
             sta Enemy_Y_MoveForce,x
             lda Player_X_Speed
             sta Enemy_X_Speed,x
             lda #$15
             sta FballCooldown            ;set fireball cooldown to avoid killing it just after releasing it 
             lda #Sfx_EnemySmackOr        ;play smack enemy sound
             sta Square1SoundQueue
             rts
HandlePECollisions:                    ;branch to leave if either is true
             lda Enemy_ID,x
             cmp #RedKoopaShell
             beq +
             cmp #$05
             bcc +
             lda GrabFlag
             beq +
             cpx GrabID
             bne +
             jmp H
+:       
             lda #$00
             sta StarChainCounter
             cpy #Sign
             beq +
             lda Enemy_CollisionBits,x    ;check enemy collision bits for d0 set
             and #%00000001               ;or for being offscreen at all
             bne H                        ;branch to leave if either is true
             lda #$01
             ora Enemy_CollisionBits,x    ;otherwise set d0 now
             sta Enemy_CollisionBits,x
+:       cpy #Spiny                   ;branch if spiny
             beq ChkForPlayerInjury2
             cpy #BlackParatroopa            ;branch if invincible paratroopa
             beq ChkForPlayerInjury2
             cpy #PiranhaPlant            ;branch if piranha plant
             beq InjurePlayer2
             cpy #UDPiranhaPlant
             beq InjurePlayer2
             cmp #RUDPiranhaPlant
             beq InjurePlayer2
             cmp #RedPiranhaPlant
             beq InjurePlayer2
             cpy #Podoboo                 ;branch if podoboo
             beq InjurePlayer2
             lda SwimmingFlag                ;check if swimming or underwater level
             beq +                    
             cpy #Bloober                    ;branch if bloober
             beq InjurePlayer2
             cpy #GreyCheepCheep            ;branch if grey cheep cheep
             beq InjurePlayer2
             cpy #RedCheepCheep            ;branch if red cheep cheep
             beq InjurePlayer2
+:
             cpy #BulletBill_CannonVar    ;branch if bullet bill
             beq ChkForPlayerInjury2
             cpy #RedKoopaShell
             beq +
             cpy #$15                     ;branch if object => $15
             bcs InjurePlayer2
+:       lda Enemy_State,x            ;branch if d7 of enemy state was set
             bmi ChkForPlayerInjury2
             lda Enemy_State,x            ;mask out all but 3 LSB of enemy state
             and #%00000111
             cmp #$02                     ;branch if enemy is in normal or falling state
             bcc ChkForPlayerInjury2
             lda Enemy_ID,x               ;branch to leave if goomba or fast goomba in defeated state
             cmp #Goomba
             beq H
             cmp #FastGoomba                
             beq H
             cmp #GreyCheepCheep
             beq H
             cmp #RedCheepCheep
             beq H
Grab:  lda A_B_Buttons                ;check if B is pressed
             and #B_Button
             beq ++                        ;branch if not
             lda GrabFlag
             beq +++                        ;branch if grabflag is zero
             cpx GrabID                     
             bne +                        ;compare current enemy offset with the grabbed enemy offset and branch if not equal
+++:   stx GrabID                    ;if grabflag zero and B pressed, set current enemy offset to grabbed offset
             lda #$01
             sta GrabFlag
H:       rts

InjurePlayer2:
             jmp InjurePlayer
ChkForPlayerInjury2:
             jmp ChkForPlayerInjury
++:    sta tempC
             lda GrabFlag
             beq +                        ;branch if grabflag is zero to kick it in the old way
             ;lda Enemy_Y_Position,x
             ;cmp #$11
             ;bcc H
             dec GrabFlag                    ;decrement to set grabflag to zero
             sta tempC
             lda Up_Down_Buttons
             and #Up_Dir
             beq +++
             jmp ShellUp
+++:   lda Up_Down_Buttons            ;check if DOWN is pressed
             and #Down_Dir
             beq +++                        ;if so, put down shell gently
             jmp ShellDown
+++:   ldy PlayerFacingDir          ;get player's facing direction
             dey
             tya
             ldy #$01
             cmp #$00
             beq KickD   
             iny                    
KickD: sty Enemy_MovingDir,x          ;kick shell where player is facing
             dey
             jmp ++++
+:       jsr EnemyFacePlayer
++++:  lda #$00
             sta Enemy_Y_Speed,x            ;nullify enemy Y speed
             lda #$15
             sta FballCooldown            ;set fireball cooldown to avoid killing the sell just after kicking it
             lda KickedShellXSpdData,y    ;load and set horizontal speed data with offset
             sta Enemy_X_Speed,x
             lda Enemy_State,x            ;set d7 in enemy state, thus become moving shell
             and #%11010000
             ora #%10000100
             sta Enemy_State,x
             lda #$00
             sta EnemyDefeatPitch            ;reset smack pitch
             sta GrabUp
             sta ShellChainCounter,x
             lda #Sfx_EnemySmackOr        ;play smack enemy sound
             sta Square1SoundQueue
             lda KickedShellXSpdData,y    ;load and set horizontal speed data with offset
             sta Enemy_X_Speed,x
             lda tempC
             bne ExPEC
             lda #$03                     ;add three to whatever the stomp counter contains
             clc                          ;to give points for kicking the shell
             adc StompChainCounter
             ldy EnemyIntervalTimer,x     ;check shell enemy's timer
             cpy #$03                     ;if above a certain point, branch using the points
             bcs KSPts                    ;data obtained from the stomp counter + 3
             lda KickedShellPtsData,y     ;otherwise, set points based on proximity to timer expiration
KSPts: jmp SetupFloateyNumber       ;set values for floatey number now
ExPEC: rts
             
GSLoop:        
             ldx GrabID                    ;load grab id
             lda #$10                    ;set enemy interval timer to avoid glitches
             sta EnemyIntervalTimer,x
             lda Player_X_Position        ;load player horizontal position
             ldy PlayerFacingDir            ;load player facing dir
             dey
             bne +                        ;branch if not zero
             add #$0b
             sta Enemy_X_Position,x        ;add $0b pixels if right
             lda Player_PageLoc            ;load player page loc
             adc #$00                    ;add 1 if horizontal position overflowed
             sta Enemy_PageLoc,x            ;store in enemy page loc
             jmp ++
+:            sub #$0b                    ;subtract $0b pixels if left
             sta Enemy_X_Position,x
             lda Player_PageLoc            ;load player page loc
             sbc #$00                    ;subtract 1 if horizontal position underflowed
             sta Enemy_PageLoc,x            ;store in enemy page loc
++:            lda Player_MovingDir
             sta Enemy_MovingDir,x        ;store player moving dir here
             lda #$00
             sta Enemy_CollisionBits,x    ;nullify this so enemy can't hurt just after kicking it
             lda Player_Y_Position        ;load player vertical position
             ldy CrouchingFlag            ;load crouching flag
             bne ++                        ;branch if crouching
             ldy PlayerSize                ;load player size
             bne ++                        ;branch if small
             sec
             sbc #$01                    ;subtract 7
             sta Enemy_Y_Position,x
             lda Player_Y_HighPos
             sbc #$00
             sta Enemy_Y_HighPos,X
             jmp +
++:            clc
             adc #$06                    ;add 6
             sta Enemy_Y_Position,x        ;set enemy vertical position
             lda Player_Y_HighPos
             sta Enemy_Y_HighPos,X
+:            cmp #$01
             bne RShell
             lda Enemy_Y_Position,x
             cmp #$e0
             bcc RShell
             lda #$00
             sta GrabFlag
RShell:        
             lda #$00                    
             sta ShellChainCounter,x        ;reset chain counter
             rts
ShellDown:
             lda #$01
             sta GrabDown            ;set this
             lda Player_X_Speed        ;load player horizontal speed
             sta Enemy_X_Speed,x        ;store here
             lda #$00                
             sta Enemy_Y_Speed,x        ;nullify enemy vertical speed
             lda #$15
             sta FballCooldown        ;set fireball cooldown to avoid killing it just after releasing it 
             rts
             
KillPlayer:
             lda #$00               ;nullify grab flag, enemy pitch, was grabbed and old status
             sta GrabFlag
             sta GrabDown
             sta GrabUp
             sta DebugSwim
             sta LakituRespawning
             sta EnemyDefeatPitch
             sta OldStatus
             sta Player_X_Speed   ;halt player's horizontal movement by initializing speed
             inx
             stx EventMusicQueue  ;set event music queue to death music
             lda #$fc
             sta Player_Y_Speed   ;set new vertical speed
             lda #$0b             ;set subroutine to run on next frame
             bne SetKRout         ;branch to set player's state and other things
InjurePlayer:
             lda OperMode
             cmp #$02
             beq ExInjColRoutines
             lda InjuryTimer          ;check again to see if injured invincibility timer is
             bne ExInjColRoutines     ;at zero, and branch to leave if so
ForceInjury:
             ldx PlayerStatus          ;check player's status
             beq KillPlayer            ;branch if small
             lda HardModeFlag
             beq +
             lda #$00
             sta PlayerStatus
             sta OldStatus
             jmp ++
+:          lda PlayerStatus            
             sta OldStatus                ;load player's status and store here
             dec PlayerStatus            ;decrement player's status
++:          lda #$08    
             sta InjuryTimer           ;set injured invincibility timer
             asl                       ;PAL version has lda #$10 here instead (either will work)
             sta Square1SoundQueue     ;play pipedown/injury sound
             jsr GetPlayerColors       ;change player's palette if necessary
             lda #$0a                  ;set subroutine to run on next frame
SetKRout: ldy #$01                  ;set new player state
SetPRout: sta GameEngineSubroutine  ;load new value to run subroutine on next frame
             sty Player_State          ;store new player state
             ldy #$ff
             sty TimerControl          ;set master timer control flag to halt timers
             iny
             sty ScrollAmount          ;initialize scroll speed
             
ExInjColRoutines:
             ldx ObjectOffset              ;get enemy offset and leave
             rts
ChkForPlayerInjury:
             lda Player_Y_Speed     ;check player's vertical speed
             bmi ChkInj             ;perform procedure below if player moving upwards
             bne EnemyStomped       ;or not at all, and branch elsewhere if moving downward
             lda Enemy_Y_Position,x
             sub #$08
             cmp Player_Y_Position
             beq +
             bcc +
             lda Enemy_Y_Speed,x
             beq EnemyStomped
             bpl ChkInj
             bcs EnemyStomped
+:          ;lda Player_State
             ;bne EnemyStomped
ChkInj:   
             if PLAYER_COLLISION_FIX == 1
lda #$14               ;PAL bugfix: Vertical difference deciding whether Mario stomped or got hit depends on the enemy
             ldy Enemy_ID,x         ;branch if enemy object < $07
             cpy #FlyingCheepCheep
             bne ChkInj2
             lda #$07
ChkInj2:  adc Player_Y_Position
             
             else
             lda Enemy_ID,x         ;branch if enemy object < $07
             cmp #GreyCheepCheep
             bcc ChkETmrs
             cmp #RedKoopaShell
             beq ChkETmrs
             cmp #UDPiranhaPlant
             beq ChkETmrs
             cmp #RUDPiranhaPlant
             beq ChkETmrs
             lda Player_Y_Position  ;add 12 pixels to player's vertical position
             clc
             adc #$0c
             endif
             cmp Enemy_Y_Position,x ;compare modified player's position to enemy's position
             bcc EnemyStomped       ;branch if this player's position above (less than) enemy's
ChkETmrs: lda StompTimer         ;check stomp timer
             bne EnemyStomped       ;branch if set
             lda InjuryTimer        ;check to see if injured invincibility timer still
             bne ExInjColRoutines   ;counting down, and branch elsewhere to leave if so
             lda Player_Rel_XPos
             cmp Enemy_Rel_XPos     ;if player's relative position to the left of enemy's
             bcc TInjE              ;relative position, branch here
             jmp ChkEnemyFaceRight  ;otherwise do a jump here
TInjE:    lda Enemy_MovingDir,x  ;if enemy moving towards the left,
             cmp #$01               ;branch, otherwise do a jump here
             bne InjurePlayer3       ;to turn the enemy around
             jmp LInj
InjurePlayer3:
             jmp InjurePlayer
StompedEnemyPtsData:
             .db $02, $05, $07, $05
EnemyStomped:
             lda Enemy_ID,x             ;check for spiny, branch to hurt player
             cmp #Spiny                 ;if found
             beq InjurePlayer3
             cmp #BlackParatroopa
             beq InjurePlayer3
             cmp #Lakitu
             bne +
             lda #$01
             sta LakituRespawning
+:    lda #Sfx_EnemyStomp        ;otherwise play stomp/swim sound
             sta Square1SoundQueue
             lda Enemy_ID,x
             ldy #$00                   ;initialize points data offset for stomped enemies
             cmp #FlyingCheepCheep      ;branch for cheep-cheep
             beq NormalPTS
             cmp #RedCheepCheep
             beq NormalPTS
             cmp #GreyCheepCheep
             beq NormalPTS
             cmp #BulletBill_FrenzyVar  ;branch for either bullet bill object
             beq NormalPTS
             cmp #BulletBill_CannonVar
             beq NormalPTS
             cmp #Podoboo               ;branch for podoboo (this branch is logically impossible
             beq EnemyStompedPts        ;for cpu to take due to earlier checking of podoboo)
             iny                        ;increment points data offset
             cmp #HammerBro             ;branch for hammer bro
             beq EnemyStompedPts
             iny                        ;increment points data offset
             cmp #Lakitu                ;branch for lakitu
             beq EnemyStompedPts
             iny                        ;increment points data offset
             cmp #Bloober               ;branch if NOT bloober
             bne ChkForDemoteKoopa
             
EnemyStompedPts:
             lda StompedEnemyPtsData,y  ;load points data using offset in Y
             sta FloateyNum_Control,x   ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x     ;set timer for floatey numbers
             lda Enemy_Y_Position,x 
             sta FloateyNum_Y_Pos,x     ;set vertical coordinate
             lda Enemy_Rel_XPos  
             sta FloateyNum_X_Pos,x     ;set horizontal coordinate and leave
             jmp ++
             
NormalPTS:
             inc StompChainCounter      ;increment the stomp counter
             lda StompChainCounter      ;add whatever is in the stomp counter
             add StompTimer
             sta FloateyNum_Control,x   ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x     ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x     ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x     ;set horizontal coordinate and leave
             inc StompTimer             ;increment stomp timer of some sort
++:   lda Enemy_MovingDir,x
             pha                        ;save enemy movement direction to stack
             jsr SetStun                ;run sub to kill enemy
             pla
             sta Enemy_MovingDir,x      ;return enemy movement direction from stack
             lda #%00100000
             sta Enemy_State,x          ;set d5 in enemy state
             ldy SavedOffset,x
             lda #$02
             sta Saved_isDefeated,y
             lda #$00                   ;initialize vertical speed
             sta Enemy_Y_Speed,x        ;and movement force
             sta Enemy_Y_MoveForce,x    ;nullify vertical speed, physics-related thing,
             sta Enemy_X_Speed,x        ;and horizontal speed
             lda SwimmingFlag
             beq +
             lda #$fd
             sta Player_Y_Speed
+:      jmp SetBounce
             
ChkForDemoteKoopa:
             cmp #$0c                   ;branch elsewhere if enemy object < $0a
             bcc HandleStompedShellE
             cmp #RedKoopaShell
             beq HandleStompedShellE
             cmp #RUDPiranhaPlant
             beq HandleStompedShellE
             cmp #RedPiranhaPlant
             beq HandleStompedShellE
             cmp #UDPiranhaPlant
             beq HandleStompedShellE
             and #%00000001             ;demote koopa paratroopas to ordinary troopas
             sta Enemy_ID,x
             ldy #$00                   ;return enemy to normal state
             lda Enemy_ID,x
             beq ++
             iny
++:   sty Enemy_State,x
             inc StompChainCounter      ;increment the stomp counter
             lda StompChainCounter      ;add whatever is in the stomp counter
             add StompTimer
             sta FloateyNum_Control,x   ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x     ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x     ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x     ;set horizontal coordinate and leave
             inc StompTimer             ;increment stomp timer of some sort
             lda #$00                   ;initialize vertical speed
             sta Enemy_Y_Speed,x        ;and movement force
             sta Enemy_Y_MoveForce,x
             jsr EnemyFacePlayer        ;turn enemy around if necessary
             lda HardModeFlag
             beq +
             iny
             iny
+:        
             lda DemotedKoopaXSpdData,y
             sta Enemy_X_Speed,x        ;set appropriate moving speed based on direction
             jmp SetBounce              ;then move onto something else
             
RevivalRateData:
             .db $10, $0b
             
HandleStompedShellE:
             lda #$04                   ;set defeated state for enemy
             sta Enemy_State,x
             inc StompChainCounter      ;increment the stomp counter
             lda StompChainCounter      ;add whatever is in the stomp counter
             add StompTimer
             sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
             inc StompTimer             ;increment stomp timer of some sort
             ldy PrimaryHardMode        ;check primary hard mode flag
             lda Enemy_X_Speed,x
             cmp #$80
             ror
             sta Enemy_X_Speed,x
             lda Enemy_ID,x
             cmp #KoopaShell
             beq SetBounce
             cmp #RedKoopaShell
             beq SetBounce
             lda RevivalRateData,y      ;load timer setting according to flag
             sta EnemyIntervalTimer,x   ;set as enemy timer to revive stomped enemy
SetBounce: 
             lda #$01
             sta Player_State
             lda A_B_Buttons
             and #A_Button
             beq SmallBonc
             inc SuppressJumpNoise
             jmp InitJS
SmallBonc:
             lda #$fc                   ;set player's vertical speed for bounce
             ldy SwimmingFlag
             beq BnceM
             lda #$fe
BnceM:     sta Player_Y_Speed         ;and then leave!!!
             rts
             
             
             
ChkEnemyFaceRight:
             lda Enemy_MovingDir,x ;check to see if enemy is moving to the right
             cmp #$01
             bne LInj              ;if not, branch
             jmp InjurePlayer      ;otherwise go back to hurt player
LInj:  jsr EnemyTurnAround   ;turn the enemy around, if necessary
             jmp InjurePlayer      ;go back to hurt player
             
             
EnemyFacePlayer:
             ldy #$01               ;set to move right by default
             lda Enemy_X_Position,x  ;get distance between enemy object's
             sec                     ;horizontal coordinate and the player's
             sbc Player_X_Position   ;horizontal coordinate
             sta $00                 ;and store here
             lda Enemy_PageLoc,x
             sbc Player_PageLoc      ;subtract borrow, then leave
             bpl SFcRt              ;if enemy is to the right of player, do not increment
             iny                    ;otherwise, increment to set to move to the left
SFcRt: sty Enemy_MovingDir,x  ;set moving direction here
             dey                    ;then decrement to use as a proper offset
             rts
             
SetupFloateyNumber:
             sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
ExSFN: rts
             
             
SetBitsMask:
             .db %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010
             
ClearBitsMask:
             .db %01111111, %10111111, %11011111, %11101111, %11110111, %11111011, %11111101
ExSFN2:
             ldx ObjectOffset ;get enemy object buffer offset
             rts              ;leave
EnemiesCollision:
             lda GrabFlag
             beq +
             cpx GrabID
             beq ExSFN2
+:        lda Enemy_ID,x
             cmp #RedKoopaShell
             beq +
             cmp #BulletBill_CannonVar
             beq +
             cmp #UDPiranhaPlant
             beq +
             cmp #RUDPiranhaPlant
             beq +
             cmp #RedPiranhaPlant
             beq +
			 ;cmp #Bowser
			 ;beq +
             cmp #$15                    ;if enemy object => $15, branch to leave
             bcs ExSFN2
+:      cmp #Lakitu                 ;if lakitu, branch to leave
             beq ExSFN2
             cmp #Bloober
             beq ExSFN2
             cmp #BlackParatroopa
             beq ExSFN2
             cmp #Spiny
             bne +
             lda Enemy_State,x  ;then check enemy state
             cmp #$05           ;if not set to unique state for spiny's egg, go ahead
             bne +
             rts
+:      lda Enemy_ID,x
             cmp #Goomba
             beq +
             cmp #FastGoomba
             bne ++
+:        lda Enemy_State,x
             and #%00100110           ;check saved enemy state for d5 set
             bne ExSFN2
++:          lda EnemyOffscrBitsMasked,x ;if masked offscreen bits nonzero, branch to leave
             bne ExSFN2
             lda ObjectOffset         ;get enemy object buffer offset
             asl                      ;multiply A by four, then add four
             asl                      ;to skip player's bounding box
             clc
             adc #$04
             tay                      ;send to Y
             lda Enemy_OffscreenBits  ;get offscreen bits for enemy object
             and #%00001111           ;save low nybble
             cmp #%00001111           ;check for all bits set
             dex                         ;first enemy we're going to compare, then decrement for second
             bmi ExSFN2           ;branch to leave if there are no other enemies
ECLoop: stx $01                     ;save enemy object buffer offset for second enemy here
             tya                         ;save first enemy's bounding box offset to stack
             pha
             lda Enemy_Flag,x            ;check enemy object enable flag
             beq ReadyNextEnemy1          ;branch if flag not set
             lda Enemy_ID,x
             cmp #RedKoopaShell
             beq +
             cmp #UDPiranhaPlant
             beq +
             cmp #RUDPiranhaPlant
             beq +
             cmp #RedPiranhaPlant
             beq +
			 ;cmp #Bowser
			 ;beq +
             ;cmp #BulletBill_CannonVar
             ;beq +
             cmp #$15                    ;check for enemy object => $15
             bcs ReadyNextEnemy1          ;branch if true
             jmp ++
ReadyNextEnemy1: jmp ReadyNextEnemy
+:      lda Enemy_ID,x
++:        cmp #Lakitu
             beq ReadyNextEnemy1          ;branch if enemy object is lakitu
             lda EnemyOffscrBitsMasked,x
             bne ReadyNextEnemy1          ;branch if masked offscreen bits set
             txa                         ;get second enemy object's bounding box offset
             asl                         ;multiply by four, then add four
             asl
             clc
             adc #$04
             tax                         ;use as new contents of X
             sty $06      ;save contents of Y here
             lda #$01
             sta $07      ;save value 1 here as counter, compare horizontal coordinates first
CollisionCoreLoop1:
             lda BoundingBox_UL_Corner,y  ;compare left/top coordinates
             cmp BoundingBox_UL_Corner,x  ;of first and second objects' bounding boxes
             bcs FirstBoxGreater1          ;if first left/top => second, branch
             cmp BoundingBox_LR_Corner,x  ;otherwise compare to right/bottom of second
             bcc SecondBoxVerticalChk1     ;if first left/top < second right/bottom, branch elsewhere
             beq CollisionFound1           ;if somehow equal, collision, thus branch
             lda BoundingBox_LR_Corner,y  ;if somehow greater, check to see if bottom of
             cmp BoundingBox_UL_Corner,y  ;first object's bounding box is greater than its top
             bcc CollisionFound1           ;if somehow less, vertical wrap collision, thus branch
             cmp BoundingBox_UL_Corner,x  ;otherwise compare bottom of first bounding box to the top
             bcs CollisionFound1           ;of second box, and if equal or greater, collision, thus branch
             ;ldy $06                      ;otherwise return with carry clear and Y = $0006
             jmp +                         ;note horizontal wrapping never occurs
             
SecondBoxVerticalChk1:
             lda BoundingBox_LR_Corner,x  ;check to see if the vertical bottom of the box
             cmp BoundingBox_UL_Corner,x  ;is greater than the vertical top
             bcc CollisionFound1           ;if somehow less, vertical wrap collision, thus branch
             lda BoundingBox_LR_Corner,y  ;otherwise compare horizontal right or vertical bottom
             cmp BoundingBox_UL_Corner,x  ;of first box with horizontal left or vertical top of second box
             bcs CollisionFound1           ;if equal or greater, collision, thus branch
             ;ldy $06                      ;otherwise return with carry clear and Y = $0006
             jmp +
CollisionFound1:
             inx                    ;increment offsets on both objects to check
             iny                    ;the vertical coordinates
             dec $07                ;decrement counter to reflect this
             bpl CollisionCoreLoop1  ;if counter not expired, branch to loop
             sec                    ;otherwise we already did both sets, therefore collision, so set carry
             jmp +
FirstBoxGreater1:
             cmp BoundingBox_UL_Corner,x  ;compare first and second box horizontal left/vertical top again
             beq CollisionFound1           ;if first coordinate = second, collision, thus branch
             cmp BoundingBox_LR_Corner,x  ;if not, compare with second object right or bottom edge
             bcc CollisionFound1           ;if left/top of first less than or equal to right/bottom of second
             beq CollisionFound1           ;then collision, thus branch
             cmp BoundingBox_LR_Corner,y  ;otherwise check to see if top of first box is greater than bottom
             bcc NoCollisionFound1         ;if less than or equal, no collision, branch to end
             beq NoCollisionFound1
             lda BoundingBox_LR_Corner,y  ;otherwise compare bottom of first to top of second
             cmp BoundingBox_UL_Corner,x  ;if bottom of first is greater than top of second, vertical wrap
             bcs CollisionFound1          ;collision, and branch, otherwise, proceed onwards here
             
NoCollisionFound1:
             clc          ;clear carry, then load value set earlier, then leave
+:      ldy $06      ;like previous ones, if horizontal coordinates do not collide, we do
             ;rts          ;not bother checking vertical ones, because what's the point?
             
             ldx ObjectOffset            ;use first enemy offset for X
             ldy $01                     ;use second enemy offset for Y
             bcc NoEnemyCollision        ;if carry clear, no collision, branch ahead of this
             cpx GrabID
             bne +
             lda GrabUp
             bne YesEC
+:      cpy GrabID
             bne +
             lda GrabUp
             bne YesEC
+:        lda Enemy_State,x
             ora Enemy_State,y           ;check both enemy states for d7 set
             and #%10000000
             bne YesEC                   ;branch if at least one of them is set
             lda Enemy_CollisionBits,y   ;load first enemy's collision-related bits
             and SetBitsMask,x           ;check to see if bit connected to second enemy is
             bne ReadyNextEnemy          ;already set, and move onto next enemy slot if set
             lda Enemy_CollisionBits,y
             ora SetBitsMask,x           ;if the bit is not set, set it now
             sta Enemy_CollisionBits,y
YesEC:  jsr ProcEnemyCollisions     ;react according to the nature of collision
             jmp ReadyNextEnemy          ;move onto next enemy slot
             
NoEnemyCollision:
             lda Enemy_CollisionBits,y     ;load first enemy's collision-related bits
             and ClearBitsMask,x           ;clear bit connected to second enemy
             sta Enemy_CollisionBits,y     ;then move onto next enemy slot
             
ReadyNextEnemy:
             pla              ;get first enemy's bounding box offset from the stack
             tay              ;use as Y again
             ldx $01          ;get and decrement second enemy's object buffer offset
             dex
             bpl ECLoop1       ;loop until all enemy slots have been checked
             
ExitECRoutine:
             ldx ObjectOffset ;get enemy object buffer offset
             rts              ;leave
ECLoop1: jmp ECLoop
ProcSecondEnemyColl2:
             jmp ProcSecondEnemyColl
ProcEnemyCollisions:
             
             lda Enemy_State,y        ;check both enemy states for d5 set
             ora Enemy_State,x
             and #%00100000           ;if d5 is set in either state, or both, branch
             bne ExitECRoutine        ;to leave and do nothing else at this point
             cpx GrabID
             bne +
             lda GrabUp
             bne ++
             
+:    ;lda Enemy_ID,x
             ;cmp #BulletBill_CannonVar
             ;beq ++
             lda Enemy_State,x
             cmp #$06                 ;if second enemy state < $06, branch elsewhere
             bcc ProcSecondEnemyColl2
++:   lda Enemy_ID,x           ;check second enemy identifier for hammer bro
             cmp #HammerBro           ;if hammer bro found in alt state, branch to leave
             beq ProcSecondEnemyColl2
             cmp #BlackParatroopa
             beq ExitECRoutine
             cpy GrabID
             bne +
             lda GrabUp
             bne ++
			 
+:      	 ;lda Enemy_ID,y
		     ;cmp #Bowser
			 ;beq ++
			 lda Enemy_State,y        ;check first enemy state for d7 set
             bpl ShellCollisions      ;branch if d7 is clear
     		 lda #$05
             sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
++:          jsr ShellOrBlockDefeat   ;then kill enemy, then load
             ldx ObjectOffset
             ldy $01                  ;original offset of second enemy
             
ShellCollisions:
             tya                      ;move Y to X
             tax
             lda Enemy_ID,x
             cmp #BlackParatroopa
             beq ExitProcessEColl
			 
             jsr ShellOrBlockDefeat
			 ;lda Enemy_ID,x
		     ;cmp #Bowser
			 ;beq ++
             ldx ObjectOffset
             lda ShellChainCounter,x  ;get chain counter for shell
             clc
             adc #$02                 ;add four to get appropriate point offset
             ldx $01
             cpx GrabID
             beq ExitProcessEColl
             sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
             ldx ObjectOffset         ;load original offset of first enemy
             inc ShellChainCounter,x  ;increment chain counter for additional enemies
             inc EnemyDefeatPitch
++:          ldx $01
             lda Enemy_ID,x
             cmp #PiranhaPlant
             beq +
             cmp #RUDPiranhaPlant
             beq +
             cmp #RedPiranhaPlant
             beq +
             cmp #UDPiranhaPlant
             bne ExitProcessEColl
+:      lda #$ff
             sta Enemy_Y_Position,x
ExitProcessEColl:
             ldx ObjectOffset
             rts                      ;leave!!!
             
ProcSecondEnemyColl:
             lda GrabFlag
             beq +
             cpy GrabID
             bne +
             rts
+:      cpy GrabID
             bne +
             lda GrabUp
             bne ++
+:      ;lda Enemy_ID,y
             ;cmp #BulletBill_CannonVar
             ;beq ++
             lda Enemy_State,y        ;if first enemy state < $06, branch elsewhere
             cmp #$06
             bcc MoveEOfs
             cmp #RedKoopaShell
             beq MoveEOfs
++:   lda Enemy_ID,y           ;check first enemy identifier for hammer bro
             cmp #HammerBro           ;if hammer bro found in alt state, branch to leave
             beq ExitProcessEColl
             cmp #BlackParatroopa
             beq ExitProcessEColl
             jsr ShellOrBlockDefeat   ;otherwise, kill first enemy
             ldy $01
             lda ShellChainCounter,y  ;get chain counter for shell
             clc
             adc #$02                 ;add four to get appropriate point offset
             ldx ObjectOffset
             sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
             lda Enemy_ID,x
             cmp #PiranhaPlant
             beq ++
             cmp #RUDPiranhaPlant
             beq ++
             cmp #RedPiranhaPlant
             beq ++
             cmp #UDPiranhaPlant
             bne +
++:      lda #$ff
             sta Enemy_Y_Position,x
+:   
             ldx $01                  ;load original offset of second enemy
             inc ShellChainCounter,x  ;increment chain counter for additional enemies
             cpx GrabID
             bne +
             lda GrabUp
             bne ++
+:      lda EnemyDefeatPitch
             cmp #$0b
             beq ++
             inc EnemyDefeatPitch
++:   rts                      ;leave!!!
             
MoveEOfs:
             tya                      ;move Y ($01) to X
             tax
             jsr EnemyTurnAround      ;do the sub here using value from $01
             ldx ObjectOffset         ;then do it again using value from $08
             
EnemyTurnAround:
             lda Enemy_ID,x           ;check for specific enemies
             cmp #PiranhaPlant
             beq ExTA                 ;if piranha plant, leave
             cmp #UDPiranhaPlant
             beq ExTA
             cmp #Lakitu
             beq ExTA                 ;if lakitu, leave
             cmp #HammerBro
             beq ExTA                 ;if hammer bro, leave
             cmp #Spiny
             beq RXSpd                ;if spiny, turn it around
             cmp #GreenParatroopaJump
             beq RXSpd                ;if green paratroopa, turn it around
             cmp #BlackParatroopa
             beq RXSpd
             cmp #FastGoomba
             beq RXSpd
             cmp #RedKoopaShell
             beq RXSpd
			 cmp #Bowser
			 beq ExitEnemyTurn
             cmp #$07
             bcs ExTA                 ;if any OTHER enemy object => $07, leave
RXSpd: lda Enemy_X_Speed,x      ;load horizontal speed
             eor #$ff                 ;get two's compliment for horizontal speed
             tay
             iny
             sty Enemy_X_Speed,x      ;store as new horizontal speed
             lda Enemy_MovingDir,x
             eor #%00000011           ;invert moving direction and store, then leave
             sta Enemy_MovingDir,x    ;thus effectively turning the enemy around
             lda Enemy_ID,x
             cmp #RedKoopa
             beq +
             cmp #KoopaShell
             beq +
             cmp #GreenKoopa
             beq +
             cmp #RedKoopaShell
             beq +
             cmp #BuzzyBeetle
             beq +
ExTA:  rts                      ;leave!!!
+:       lda Enemy_State,x
             beq ExTA
             bmi ExTA
             lda Enemy_X_Speed,x
             cmp #$80
             ror
             sta Enemy_X_Speed,x
ExitEnemyTurn:
             rts
             
LargePlatformCollision:
             lda #$ff                     ;save value here
             sta PlatformCollisionFlag,x
             lda TimerControl             ;check master timer control
             bne ExLPC                    ;if set, branch to leave
             lda Enemy_State,x            ;if d7 set in object state,
             bmi ExLPC                    ;branch to leave
             lda Enemy_ID,x
             cmp #$24                     ;check enemy object identifier for
             bne ChkForPlayerC_LargeP     ;balance platform, branch if not found
             lda Enemy_State,x
             tax                          ;set state as enemy offset here
             jsr ChkForPlayerC_LargeP     ;perform code with state offset, then original offset, in X
             
ChkForPlayerC_LargeP:
             jsr CheckPlayerVertical      ;figure out if player is below a certain point
             bcs ExLPC                    ;or offscreen, branch to leave if true
             txa
             asl                          ;multiply A by four, then add four
             asl                          ;to skip player's bounding box
             clc
             adc #$04
             tay                          ;send to Y
             lda Enemy_OffscreenBits      ;get offscreen bits for enemy object
             and #%00001111               ;save low nybble
             cmp #%00001111               ;check for all bits set
             lda Enemy_Y_Position,x       ;store vertical coordinate in
             sta $00                      ;temp variable for now
             txa                          ;send offset we're on to the stack
             pha
             jsr PlayerCollisionCore      ;do player-to-platform collision detection
             pla                          ;retrieve offset from the stack
             tax
             bcc ExLPC                    ;if no collision, branch to leave
             jsr ProcLPlatCollisions      ;otherwise collision, perform sub
ExLPC: ldx ObjectOffset             ;get enemy object buffer offset and leave
             rts
             
             
             
ProcLPlatCollisions:
             lda BoundingBox_DR_YPos,y    ;get difference by subtracting the top
             sec                          ;of the player's bounding box from the bottom
             sbc BoundingBox_UL_YPos      ;of the platform's bounding box
             cmp #$04                     ;if difference too large or negative,
             bcs ChkForTopCollision       ;branch, do not alter vertical speed of player
             ;lda Player_Y_Speed           ;check to see if player's vertical speed is moving down
             ;bpl ChkForTopCollision       ;if so, don't mess with it
             ;lda #$01                     ;otherwise, set vertical
             ;sta Player_Y_Speed           ;speed of player to kill jump
             
ChkForTopCollision:
             lda BoundingBox_DR_YPos      ;get difference by subtracting the top
             sec                          ;of the platform's bounding box from the bottom
             sbc BoundingBox_UL_YPos,y    ;of the player's bounding box
             cmp #$06
             bcs PlatformSideCollisions   ;if difference not close enough, skip all of this
             lda Player_Y_Speed
             bmi PlatformSideCollisions   ;if player's vertical speed moving upwards, skip this
             lda $00                      ;get saved bounding box counter from earlier
             ldy Enemy_ID,x
             cpy #$2b                     ;if either of the two small platform objects are found,
             beq SetCollisionFlag         ;regardless of which one, branch to use bounding box counter
             cpy #$2c                     ;as contents of collision flag
             beq SetCollisionFlag
             txa                          ;otherwise use enemy object buffer offset
             
SetCollisionFlag:
             ldx ObjectOffset             ;get enemy object buffer offset
             sta PlatformCollisionFlag,x  ;save either bounding box counter or enemy offset here
             lda #$00
             sta Player_State             ;set player state to normal then leave
             PlatformSideCollisions
             rts
             
PlayerPosSPlatData:
             .db $80, $00
             
PositionPlayerOnS_Plat:
             tay                        ;use bounding box counter saved in collision flag
             lda Enemy_Y_Position,x     ;for offset
             clc                        ;add positioning data using offset to the vertical
             adc PlayerPosSPlatData-1,y ;coordinate
             .db $2c                    ;BIT instruction opcode
             
PositionPlayerOnVPlat:
             lda Enemy_Y_Position,x    ;get vertical coordinate
             ldy GameEngineSubroutine
             cpy #$0b                  ;if certain routine being executed on this frame,
             beq ExPlPos               ;skip all of this
             ldy PlatformTimer
             bne ExPlPos3
             ldy #$01
             sty OnPlatform
             ldy Enemy_Y_Speed,x
             bmi +
             ldy TouchingFloor
             bne ExPlPos
+:       ldy TouchingCeiling
             bne ExPlPos2
             ldy Enemy_Y_HighPos,x
             cpy #$01                  ;if vertical high byte offscreen, skip this
             bne ExPlPos
             sec                       ;subtract 32 pixels from vertical coordinate
             sbc #$20                  ;for the player object's height
             sta Player_Y_Position     ;save as player's new vertical coordinate
             tya
             sbc #$00                  ;subtract borrow and store as player's
             sta Player_Y_HighPos      ;new vertical high byte
             lda #$00
             sta Player_Y_Speed        ;initialize vertical speed and low byte of force
             sta Player_Y_MoveForce    ;and then leave
             sta StompChainCounter
ExPlPos: rts
ExPlPos2:     lda #$07
             sta PlatformTimer
             lda #$01
             sta Player_State
             lda #$00
             sta OnPlatform
             rts
ExPlPos3:   dec PlatformTimer
             lda #$01
             sta Player_State
             lda #$00
             sta OnPlatform
             rts
             
CheckPlayerVertical:
             lda Player_OffscreenBits  ;if player object is completely offscreen
             cmp #$f0                  ;vertically, leave this routine
             bcs ExCPV
             ldy Player_Y_HighPos      ;if player high vertical byte is not
             dey                       ;within the screen, leave this routine
             bne ExCPV
             lda Player_Y_Position     ;if on the screen, check to see how far down
             cmp #$d0                  ;the player is vertically
ExCPV: rts
             
             
PlayerBGUpperExtent:
             .db $20, $0e
             
PlayerBGCollision:
             lda DisableCollisionDet   ;if collision detection disabled flag set,
             bne ExPBGCol              ;branch to leave
             sta SideCollisionAdder
             sta ClimbingSlope
             sta SwimmingFlag
             lda GameEngineSubroutine
             cmp #$0b                  ;if running routine #11 or $0b
             beq ExPBGCol              ;branch to leave
             cmp #$04
             bcc ExPBGCol              ;if running routines $00-$03 branch to leave
             cmp #$0d
             beq ExPBGCol
             lda #$01                  ;load default player state for swimming
			 
             ldy SwimmingFlag          ;if swimming flag set,
             bne SetPSte               ;branch ahead to set default state
             ldy OldSwim
             bne SetPSte
			 ldy AreaPointer
			 cpy #$03
			 beq SetPSte
             lda Player_State          ;if player in normal state,
             beq SetFallS              ;branch to set default state for falling
             cmp #$03
             bne ChkOnScr              ;if in any other state besides climbing, skip to next part
SetFallS: lda #$02                  ;load default player state for falling
SetPSte:  sta Player_State          ;set whatever player state is appropriate
ChkOnScr: lda Player_Y_HighPos
             cmp #$01                  ;check player's vertical high byte for still on the screen
             bne ExPBGCol              ;branch to leave if not
             lda Player_CollisionBits
             sta Player_OldCollisionBits
             lda #$ff
             sta Player_CollisionBits  ;initialize player's collision flag
             lda Player_Y_Position
             cmp #$ff                  ;check player's vertical coordinate
             bcc ChkCollSize           ;if not too close to the bottom of screen, continue
ExPBGCol: rts                       ;otherwise leave
             
DoFootCheck1:
             jmp DoFootCheck
ChkCollSize:
             ldy #$02                    ;load default offset
             lda CrouchingFlag
             bne GBBAdr                  ;if player crouching, skip ahead
             lda PlayerSize
             bne GBBAdr                  ;if player small, skip ahead
             dey                         ;otherwise decrement offset for big player not crouching
             lda SwimmingFlag
             bne GBBAdr                  ;if swimming flag set, skip ahead
             dey                         ;otherwise decrement offset
GBBAdr:  lda BlockBufferAdderData,y  ;get value using offset
             sta temp1                   ;store value here
             tay                         ;put value into Y, as offset for block buffer routine
             ldx PlayerSize              ;get player's size as offset
             lda CrouchingFlag
             beq HeadChk                 ;if player not crouching, branch ahead
             inx                         ;otherwise increment size as offset
HeadChk: lda #$00
             sta bocata
             sta bocata3
             lda Player_Y_Position       ;get player's vertical coordinate
             cmp PlayerBGUpperExtent,x   ;compare with upper extent value based on offset
             bcc DoFootCheck1             ;if player is too high, skip this par
             lda SwimmingFlag
             ora OldSwim
             ora OnPlatform
             bne +
             lda Player_Y_Speed
             ;beq ++
             bpl DoFootCheck1
             jmp +++
+:           ;lda Player_Y_Speed
             ;beq ++
             ;bpl DoFootCheck1
++:         lda Player_State
             cmp #$03
             beq DoFootCheck1
+++:     lda CrouchingFlag2
             beq +
             ldy #$25
             jsr BlockBufferColli_Head

             ldy temp1
             cmp #$00
             jmp ++
+:          lda AreaPointer
             cmp #$03
             bne +
             ldy #$24
             
+:           
			jsr BlockBufferColli_Head
             ;cmp #$00
++:         beq DoFootCheck1             ;player, and branch if nothing above player's head
             cmp #$71
             beq DoFootCheck1
             cmp #$70
             beq DoFootCheck1
             cmp #$26
             beq DoFootCheck1
             sty temp7
             tay
             lda PTimer
             bne NoPuta
             tya
             ldy temp7
             cmp #$72
             beq DoFoCHK
             tay
NoPuta:  tya
             ldy temp7
             cmp #$88
             beq DoFoCHK1
             cmp #$63
             beq DoFoCHK
             cmp #$92
             beq DoFoCHK
             cmp #$2e
             beq CheckForUpPipe
             cmp #$2f
             beq CheckForUpPipe
             cmp #$91
             bne +
++:         ;jmp DoFootCheck
             ldy AreaPointer 
             cpy #$83
             beq +++++
			 ldy WorldNumber
			 cpy #World8
			 beq +++++
			 ldy AreaType
             cpy #$03
             bne ++
             ldy StarInvincibleTimer
             bne ++
+++++
             jmp KillPlayer
++:         ldy #$01
             sty SwimmingFlag
             jmp DoFootCheck
DoFoCHK1: 
DoFoCHK: jmp DoFootCheck
CheckForUpPipe:
             pha
             sty temp7
             ldy #$1c
             lda CrouchingFlag
             bne ++
             lda PlayerSize
             bne ++
             iny
             iny
++:      jsr BlockBufferColli_Head   ;do player-to-bg collision detection on top of
             iny
             sta tempC
             jsr BlockBufferColli_Head   ;do player-to-bg collision detection on top of
             sta tempD
             ldy temp7
             pla
+:         jsr CheckForCoinMTiles      ;check to see if player touched coin with their head
             bcc +
             jsr HandleCoinMetatile      ;if so, branch to some other part of code
             jmp DoFootCh
+:         cmp #$8a
             bne +
             pha
             lda Player_Y_Position
             and #$0f
             cmp #$02
             bcc +++
             lda StarInvincibleTimer
             ora InjuryTimer
             bne ++
             pla
             jmp InjurePlayer
+++:     pla
             jmp DoFoCHK
++:         pla
+:         ldy Player_Y_Speed          ;check player's vertical speed
             beq +
             bpl DoFoCHK             ;if player not moving upwards, branch elsewhere
             jmp ++
+:         ldy Player_State
             cpy #$03
             beq DoFoCHK
++:         cmp #$8d
             bne +
             tax
             lda OnOffBits
             eor #%00000001
             sta OnOffBits
             and #%00000001
             sta OnOffFlag
             txa
+:         ldy OnOffFlag
             beq +
             cmp #$8f
             beq DoFoCHK8
             jmp ++
+:         cmp #$8e
             beq DoFoCHK8
++:         
+:       ldy $04                     ;check lower nybble of vertical coordinate returned
             cpy #$04                    ;from collision detection routine
             bcc DoFoCHK8             ;if low nybble < 4, branch
             ;jsr CheckForSolidMTiles
             cmp #$54
             beq SolidOrClimb
             ldy PTimer
             bne NoPuta2
             cmp #$72
             beq SolidOrClimb
NoPuta2:  
             cmp #$6f
             beq ++
             cmp #$74
             beq ++
             cmp #$27
             beq ++
             cmp #$28
             beq ++
             cmp #$30
             bcc +
             cmp #$36
             bcc ++
             cmp #$73
             beq ++
             cmp #$c6
             beq ++
             cmp #$c7
             beq ++
+:         tay            ;save metatile value into Y
             and #%11000000 ;mask out all but 2 MSB
             asl
             rol            ;shift and rotate d7-d6 to d1-d0
             rol
             tax            ;use as offset for metatile data
             tya            ;get original metatile value back
             cmp SolidMTileUpperExt,x  ;compare current metatile with solid metatiles
             bcs SolidOrClimb            ;if player collided with solid metatile, branch
++:      
TryBump: ldy BlockBounceTimer        ;if block bounce timer not expired,
             bne NYSpd                   ;branch ahead, do not process collision
             jsr PlayerHeadCollision     ;otherwise do a sub to process collision
             lda SwimmingFlag
             ora OldSwim
             beq +
             ;lda #$01
             sta Player_Y_Speed
+:       jmp DoFootCh             ;jump ahead to skip these other parts here
DoFoCHK8: jmp DoFootCheck
DoPlayerSideCheck3:
             jmp DoPlayerSideCheck
Burh1:
             jmp Burh
Che:
             lda #$03
             sta Player_Y_Speed
SolidOrClimb:
             cmp #$26
             beq NYSpd              ;branch ahead and do not play sound
             cmp #$8b
             beq Che
             cmp #$25
             beq DFC
             cmp #$24
             beq DFC
             lda PlayerOnVine
             bne ++
             lda #Sfx_Bump
             sta Square1SoundQueue  ;otherwise load bump sound
             sta TouchingCeiling
             beq +
++:       lda Player_Y_Position
             and #$f0
             clc
             adc #$0c
             sta Player_Y_Position
+:       lda #$04
             jsr BankSwap
             jsr HandleUpPipeEntry
             jsr RestoreBank
NYSpd: 
             if WATER_SPEED_FIX == 1
             ldy #$01               ;set player's vertical speed to nullify
lda AreaType           ;PAL diff: Set vertical speed to 0 in water stages
             bne NYSpd2 ; not water
             lda SwimmingFlag
             beq NYSpd2
             dey
NYSpd2: sty Player_Y_Speed     ;jump or swim
             else
             lda #$01               ;set player's vertical speed to nullify
             sta Player_Y_Speed     ;jump or swim
             endif
             jmp DFC
PutOnSlope4:
             jsr PutOnSlope
             pla
             jmp DoPlayerSideCheck
JmpTo4Mas:
             jmp CargarPTimer
DoFootCheck:
             lda OldSwim
             beq DoFootCh
             lda SwimmingFlag
             bne DoFootCh
             jsr x1
             lda OnWater
             bne DoFootCh
             lda Player_Y_Speed
             bmi DoFootCh
             ldy Player_MovingDir
             dey
             tay
             lda SwimSpeed,y
             sta Player_X_Speed 
             lda #$01
             sta Player_State
             sta Player_Y_Speed
             lda #$00
             sta CrouchingFlag
             sta CrouchingFlag2
             lda #$0a
             sta VerticalForceDown
             inc OnWater
             jmp DoFootCh
DoPlayerSideCheck5: jmp DoPlayerSideCheck
DoFootCh:    
             lda #$00
DFC:  sta TouchingCeiling     
             ;lda #$00
             ;sta DetectedFoot
             ;lda SwimmingFlag
             ;ora OldSwim
             ;bne +
             ;lda Player_Y_Speed
             ;bmi DoPlayerSideCheck5
+:      ldy temp1                  ;get block buffer adder offset
             lda Player_Y_Position
             cmp #$cf                   ;check to see how low player is
             bcs DoPlayerSideCheck5     ;if player is too far down on screen, skip all of this
             pha
             sty temp2a
             ldy #$22
             jsr BlockBufferColli_Feet
             ldy #$00
             cmp #$71
             beq PutOnSlope4
             ldy #$21
             jsr BlockBufferColli_Feet
             ldy #$01
             cmp #$71
             beq PutOnSlope4
+:      ldy temp2a
             pla
             jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom left of player
             ;cmp #$71
             ;beq Burh2
             cmp #$8c
             beq JmpTo4Mas
             jsr CheckForCoinMTiles     ;check to see if player touched coin with their left foot
             bcc +
             lda Player_Y_Position
             and #$0f
             beq +
             jsr HandleCoinMetatile
             ldy temp1
             iny
             jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom right of player
             sta $00                    ;save bottom right metatile here
             jmp Burh
micaracuando:
+:      pha                        ;save bottom left metatile to stack
             jsr BlockBufferColli_Feet  ;do player-to-bg collision detection on bottom right of player
             sta $00                    ;save bottom right metatile here
             pla
             sta $01                    ;pull bottom left metatile and save here
             beq Burh2                        ;if anything here, skip this part
             cmp #$5f                   ;check for hidden coin block
             beq Burh2                      ;branch to leave if found
             cmp #$30
             beq Burh2
             cmp #$60                   ;check for hidden 1-up block
             beq Burh2
             cmp #$74
             beq Burh2
             cmp #$6f                   ;do sub to check for hidden coin or 1-up blocks
             beq Burh2                         ;if either found, branch
             cmp #$73
             beq Burh2
             cmp #$92
             beq Burh2
             cmp #$70
             beq Burh2 
             cmp #$71
             beq Burh2
             cmp #$91
             beq Burh2
             cmp #$8a
             beq Burh2
             jmp +++
             ;ldy SwimmingFlag
             ;bne +
             ;inc OldSwim
             ;inc SwimmingFlag
Burh2:   jmp Burh
PutOnSlope1:
             jmp PutOnSlope
Ostia:   rts
e:          ldy AreaPointer 
             cpy #$83
             beq +++++ 
			ldy WorldNumber
			 cpy #World8
			 beq +++++
             ldy AreaType
             cpy #$03
             bne +
             ldy StarInvincibleTimer
             bne +
+++++        lda Player_Y_Position
             sec
             sbc #$05
             and #%00001111
             cmp #$0b
             bcs x2
             jmp KillPlayer
+:         lda WaterCooldown
             bne x2
             ;lda Player_Y_Speed
             ;bmi x2
++:         lda Player_X_Speed
             beq +
             and #$80 
             rol
             adc #$00
             tay
             lda SwimSpeed,y
             sta Player_X_Speed
+:         lda #$01
             sta Player_Y_Speed
             sta Player_State
             lda #$0a
             sta VerticalForceDown
x2:         rts
x1:         lda A_B_Buttons
             and #A_Button
             beq ++++
             ldx Player_Y_Speed
             bmi Brom
             and PreviousA_B_Buttons
             bne ++++
Brom:     ldx WaterCooldown
             bne x2 
             lda Up_Down_Buttons
             and #Up_Dir
             beq ++++
             lda AreaType
             beq ++++
             ldy #$00
             sty SwimmingFlag
             sty OnWater
             iny
             sty SuppressJumpNoise
             lda WaterCooldown
             bne +
             lda #$09
             sta WaterCooldown
             lda #Sfx_EnemyStomp
             sta Square1SoundQueue
+:         jmp InitJS 
++++:     lda Player_Y_Speed
             bpl ++
             lda WaterCooldown
             bne ++
             lda #$00
             sta Player_Y_Speed
             inc Player_Y_Position
             inc Player_Y_Position
++:         
             tya
             jmp Gay2
+++:         
             ldy OnOffFlag
             beq +++
             cmp #$8f
             beq +
             jmp ++
+++:  cmp #$8e
             beq +
++:
             ldy PTimer
             bne ++
             cmp #$72
             beq +
++:      cmp #$67
             beq ++
             jmp ChkFootMTile2    
++:      ldy Player_Y_Speed
             beq +++
++:      ldy #$00
             sty OldDetectedFoot
             jmp ChkFootMTile
+++:  lda #$00
             sta OldDetectedFoot
             jmp Burh
Gay2: rts
DoPlayerSideCheck4:
             jmp DoPlayerSideCheck
Ostia2:
             jmp Ostia
Burh:
+:    lda $00                    ;otherwise check for anything in bottom right metatile
             beq DoPlayerSideCheck4     ;and skip ahead if not
             cmp #$91
             bne Gay
+:      
             ldy OldSwim
             bne +
             ldy WaterCooldown
             bne +
             pha
             jsr e
             pla
             ldy #$08
             sty WaterCooldown
+:           ldy AreaPointer 
             cpy #$83
             beq +++++
			 ldy WorldNumber
			 cpy #World8
			 beq +++++
             ldy AreaType
             cpy #$03
             bne +
             ldy StarInvincibleTimer
             bne +
+++++        pha
             lda Player_Y_Position
             sec
             sbc #$05
             and #%00001111
             cmp #$0b
             pla
             bcs DoPlayerSideCheckte
+:      ldy #$01
             sty OldSwim
             sty SwimmingFlag
DoPlayerSideCheckte:
             jmp DoPlayerSideCheck
Gay:  
             lda $00
             beq DoPlayerSideCheckte
             cmp #$5f       ;check for hidden coin block
             beq DoPlayerSideCheck1    ;branch to leave if found
             cmp #$30
             beq DoPlayerSideCheck1
             cmp #$70
             beq DoPlayerSideCheck1
             cmp #$60       ;check for hidden 1-up block
             beq DoPlayerSideCheck1
             cmp #$6f    ;do sub to check for hidden coin or 1-up blocks
             beq DoPlayerSideCheck1
             cmp #$73
             beq DoPlayerSideCheck1
             cmp #$74
             beq DoPlayerSideCheck1
             cmp #$91
             beq DoPlayerSideCheck1
             cmp #$8a
             beq DoTheSpike2
             cmp #$71
             beq DoPlayerSideCheck1
             cmp #$67
             beq ChkFootMTile
             ldy OnOffFlag
             beq +++
             cmp #$8f
             beq DoPlayerSideCheck1
             jmp ++
+++:  cmp #$8e
             beq DoPlayerSideCheck1
++:
             ldy PTimer
             bne +++
             cmp #$72
             beq DoPlayerSideCheck1
+++:
             jsr CheckForCoinMTiles     ;check to see if player touched coin with their right foot
             bcc ChkFootMTile2          ;if not, skip unconditional jump and continue code
             jsr HandleCoinMetatile
             jmp DoPlayerSideCheck1
PutOnSlope2:
             pha
             jsr PutOnSlope
             pla
             jmp ChkFootMTile
DoTheSpike2: jmp DoTheSpike
DoPlayerSideCheck2:
             cmp #$24
             bne DoPlayerSideCheck1
             jmp FlagpoleCollision
DoPlayerSideCheck1:
             jmp DoPlayerSideCheck
ChkFootMTile2:
             ldy #$01
             sty DetectedFoot
             sty OldDetectedFoot
             bne +
ChkFootMTile:
             ldy #$00
             sty DetectedFoot
+:        tay            ;save metatile value into Y
             and #%11000000 ;mask out all but 2 MSB
             asl
             rol            ;shift and rotate d7-d6 to d1-d0
             rol
             tax            ;use as offset for metatile data
             tya            ;get original metatile value back
             cmp #$27
             beq +++++
             cmp #$28
             beq +++++
             cmp #$27
             beq +++++
             cmp #$28
             beq +++++
             cmp #$2c
             bcc +
             cmp #$30
             beq +
             cmp #$36
             bcc +++++
+:       
             cmp ClimbMTileUpperExt,x  ;compare current metatile with climbable metatiles
             bcs DoPlayerSideCheck2      ;if so, branch
chorizo:
+++++:    ldy Player_Y_Speed         ;check player's vertical speed
             bmi DoPlayerSideCheck1      ;if player moving upwards, branch
             cmp #$91
             bne +++
++:          ;ldx WaterCooldown
             ;bne DoPlayerSideCheck1
             ldx #$01
             stx SwimmingFlag
             jmp DoPlayerSideCheck
MIERDA2: jmp MIERDA3
-:          jmp MIERDA
ContChk2: jmp ContChk
+++:      cmp #$8b
             beq MIERDA2
             cmp #$8c
             beq CargarPTimer
             cmp #$71
             beq DoPlayerSideCheck1
             tax
             cmp #$23
             bne +++
             lda Player_Y_Speed
             beq ++++
             bpl +++
++++:      ;jmp SmolJmp
+++:      txa
             cmp #$c5
             bne ContChk                ;if player did not touch axe, skip ahead
             jmp HandleAxeMetatile      ;otherwise jump to set modes of operation
             
DoTheSpike:        
             pha
             lda Player_Y_Position
             and #$0f
             cmp #$02
             bcc @g
             lda StarInvincibleTimer
             ora InjuryTimer
             bne @oda
             pla
             jmp InjurePlayer
@g:          pla
             jmp DoPlayerSideCheck
@oda:      pla
             lda Player_Y_Position
             and #$f0
             clc
             adc #$03
             sta Player_Y_Position
             jmp eda
DoPlayerSideCheck6:
             jmp DoPlayerSideCheck
PutOnSlope3:
             jmp PutOnSlope
CargarPTimer:
             lda #$08+1            ; +1 because this decrements before reaching the check for jumping
             sta PCooldown          
             lda PTimer
             bne +++++
             lda OnOffBits
             and #%00000001
             eor #%00000010
             sta OnOffBits
+++++:      lda #$5f
             sta AreaMusicQueue     ;store in queue and leave
             lda #$60
             sta PTimer
             lda #$00
             sta Player_Y_Speed         ;initialize vertical speed and fractional
             sta Player_Y_MoveForce     ;movement force to stop player's vertical movement
             sta StompChainCounter      ;initialize enemy stomp counter
             sta Player_State
			 jmp ErACM
             
MIERDA3:          lda #Sfx_Bump
             sta Square1SoundQueue
             lda A_B_Buttons
             and #A_Button
             beq +++
             lda #$f7
             .db $2c
+++:      
             lda #$fb
             .db $2c
SmolJmp:  lda #$fc
             sta Player_Y_Speed
             rts
ContChk:  
             ;ldy JumpspringAnimCtrl     ;if jumpspring animating right now,
             ;beq +
             ;jmp InitSteP               ;branch ahead
+:        ldy $04                    ;check lower nybble of vertical coordinate returned
             ;ldx FramesMissed
             ;bne +
             cpy #$05
             ;from collision detection routine
             bcc LandPlyr               ;if lower nybble < 5, branch
             cmp #$63
             beq DoPlayerSideCheck
             cmp #$88
             beq DoPlayerSideCheck
             cmp #$91
             bne ++  
+:          ;ldy WaterCooldown
             ;bne DoPlayerSideCheck
             
             ldy #$01
             sty SwimmingFlag
             jmp DoPlayerSideCheck
MIERDA:
++:          cmp #$92
             beq DoPlayerSideCheck
             ldy OnOffFlag
             beq +++
             cmp #$8f
             beq DoPlayerSideCheck
             jmp ++
+++:      cmp #$8e
             beq DoPlayerSideCheck
++:
             ldy PTimer
             bne +
             cmp #$72
             beq DoPlayerSideCheck
+:
             cmp #$71
             beq DoPlayerSideCheck
             ; jmp PutOnSlope
+:          cmp #$23
             bne ++
             lda Player_Y_Speed 
             beq +++
             bpl ++
+++:      ;jmp SmolJmp
++:       tya
             lda Player_MovingDir
             sta $00                    ;use player's moving direction as temp variable
             jmp ImpedePlayerMove       ;jump to impede player's movement in that direction
LandPlyr: ;jsr ChkForLandJumpSpring   ;do sub to check for jumpspring metatiles and deal with it
             lda #$f0
             and Player_Y_Position      ;mask out lower nybble of player's vertical position
             sta Player_Y_Position      ;and store as new vertical position to land player properly
             lda #$00
             sta GroundedTimer
eda:      
             
             lda #$04
             jsr BankSwap
             jsr HandlePipeEntry        ;do sub to process potential pipe entry
             jsr RestoreBank
             
             lda #$01
             sta TouchingFloor
             lsr
             ;sta DetectedFoot
                      ;initialize vertical speed and fractional
             sta Player_Y_MoveForce     ;movement force to stop player's vertical movement
             sta StompChainCounter      ;initialize enemy stomp counter
             ;lda #$00
             sta Player_State           ;set player's state to normal
			 sta Player_Y_Speed
			  jmp +
DoPlayerSideCheck:
             lda GroundedTimer
             cmp #$20
             bcs ++
             inc GroundedTimer
++:      lda #$00
             sta TouchingFloor
+:      ldy temp1     ;get block buffer adder offset
             iny
             iny           ;increment offset 2 bytes to use adders for side collisions
             lda Player_OldCollisionBits
             cmp #$fd
             beq +
+:    lda #$02      ;set value here to be used as counter
             sta $00
             bne SideCheckLoop
             BHalf1
             jmp BHalf
SideChekEx:      rts
SideCheckLoop:
             iny                       ;move onto the next one
             sty temp1        ;store it
             sty $7fbf
             lda Player_Y_Position
             cmp #$19                  ;check player's vertical position
             bcc BHalf1                 ;if player is in status bar area, branch ahead to skip this part
             cmp #$f0
             bcs SideCheckLoop-1                   ;branch to leave if player is too far down
             jsr BlockBufferColli_Side ;do player-to-bg collision detection on one half of player
             beq BHalf1                 ;branch ahead if nothing found
             cmp #$5f       ;check for hidden coin block
             beq BHalf1    ;branch to leave if found
             cmp #$60       ;check for hidden 1-up block
             beq BHalf1
             cmp #$74
             beq BHalf1
             cmp #$73
             beq BHalf1
             cmp #$70
             bne +
             ldx GameEngineSubroutine
             cpx #$05
             bne BHalf1
+:       cmp #$6f    ;do sub to check for hidden coin or 1-up blocks
             beq BHalf1                  ;branch to leave if either found
             cmp #$30
             beq BHalf1
             cmp #$63
             beq BHalf1
             cmp #$88
             beq BHalf1
             cmp #$1c                  ;otherwise check for pipe metatiles
             beq BHalf1                ;if collided with sideways pipe (top), branch ahead
             cmp #$6b
             beq BHalf1                 ;if collided with water pipe (top), branch ahead
             cmp #$71
             beq BHalf1
             cmp #$91
             bne +++
++:          ldy AreaPointer 
             cpy #$83
             beq +++++
             ldy WorldNumber
			 cpy #World8
			 beq +++++
             ldy AreaType
             cpy #$03
             bne ++++
             ldy StarInvincibleTimer
             bne ++++
+++++        jmp KillPlayer
++++:  ;ldy WaterCooldown
             ;bne BHalf
             ldy #$01
             sty SwimmingFlag
             jmp BHalf
CheckSideMTiles1:
             jmp CheckSideMTiles
+++:   ldy OnOffFlag
             beq +++
             cmp #$8f
             beq BHalf
             jmp ++
+++:   cmp #$8e
             beq BHalf
++:       ldy PTimer
             bne +
             cmp #$72
             beq BHalf
+:
             tay            ;save metatile value into Y
             and #%11000000 ;mask out all but 2 MSB
             asl
             rol            ;shift and rotate d7-d6 to d1-d0
             rol
             tax            ;use as offset for metatile data
             tya            ;get original metatile value back
             
             cmp #$27
             beq CheckSideMTiles1
             cmp #$28
             beq CheckSideMTiles1
             cmp #$2c
             bcc +
             cmp #$30
             beq +
             cmp #$36
             bcc CheckSideMTiles1
+:       cmp ClimbMTileUpperExt,x  ;compare current metatile with climbable metatiles
             bcc CheckSideMTiles1
BHalf: ldy temp1                 ;load block adder offset
             iny                       ;increment it
             lda Player_Y_Position     ;get player's vertical position
             cmp #$08
             bcc ExSCH2                 ;if too high, branch to leave
             cmp #$f0
             bcs ExSCH2                 ;if too low, branch to leave
             jsr BlockBufferColli_Side ;do player-to-bg collision detection on other half of player
             beq Ultramas1
             cmp #$5f       ;check for hidden coin block
             beq Ultramas1    ;      branch to leave if found
             cmp #$60       ;check for hidden 1-up block
             beq Ultramas1
             cmp #$74
             beq Ultramas1
             ;ldx #$00
             ;stx OnSlope
             cmp #$30
             beq Ultramas1
             cmp #$6f    ;do sub to check for hidden coin or 1-up blocks
             beq Ultramas1                     ;branch to leave if either found
             cmp #$73
             beq Ultramas1
             cmp #$70
             bne +
             ldx GameEngineSubroutine
             cpx #$05
             bne Ultramas1
+:       
             cmp #$71
             beq Ultramas1
             cmp #$91
             bne +++
++:          ldx AreaPointer 
             cpx #$83
             beq ++++
			 ldx WorldNumber
			 cpx #World8
			 beq ++++
			 ldx AreaType
             cpx #$03
             beq ++++
-:      ; ldx WaterCooldown
             ;bne +
             ldx #$01
             stx SwimmingFlag
             bne +
++++:  ldx StarInvincibleTimer
             bne -
             jmp KillPlayer
+++:   ldx OnOffFlag
             beq +++
             cmp #$8f
             beq +
             jmp ++
ExSCH2: rts
Ultramas1:
             jmp Ultramas
+++:   cmp #$8e
             beq +
++:       
             ldx PTimer
             bne ++
             cmp #$72
             beq +
++:
+++:   cmp #$88
             beq +
             cmp #$63
             beq +
             cmp #$92
             beq +
             tay            ;save metatile value into Y
             and #%11000000 ;mask out all but 2 MSB
             asl
             rol            ;shift and rotate d7-d6 to d1-d0
             rol
             tax            ;use as offset for metatile data
             tya            ;get original metatile value back
             cmp #$27
             beq CheckSideMTiles
             cmp #$28
             beq CheckSideMTiles
             cmp #$2c
             bcc ++
             cmp #$30
             beq ++
             cmp #$36
             bcc CheckSideMTiles
++:       
             cmp #$71
             beq CheckSideMTiles
             cmp ClimbMTileUpperExt,x  ;compare current metatile with climbable metatiles
             beq +
             bne CheckSideMTiles       ;if something found, branch
Ultramas:
+:     dec $00                   ;otherwise decrement counter
             bne SideCheckLoop1        ;run code until both sides of player are checked
ExSCH: rts                       ;leave
SideCheckLoop1:
             jmp SideCheckLoop
CheckSideMTiles:
             cmp #$5f       ;check for hidden coin block
             beq ExSCH    ;branch to leave if found
             cmp #$60       ;check for hidden 1-up block
             beq ExSCH
             cmp #$30
             beq ExSCH
             cmp #$74
             beq ExSCH
             cmp #$70
             bne +
             ldx GameEngineSubroutine
             cpx #$05
             bne ExSCH
+:          cmp #$6f
             beq ExSCH
             cmp #$63
             beq ExSCH ;branch to leave if either found
             cmp #$88
             beq ExSCH
             cmp #$92
             beq ExSCH
+++++:      ldy PTimer
             bne SiPuta
             cmp #$72
             beq ExSCH
SiPuta:
             cmp #$71
             beq ExSCH
             ;lda OnSlope
             ;bne +
             ;dec Player_Y_Position 
+:          ;jmp PutOnSlope
+++:      ldx #$00
             stx OnSlope
             cmp #$8a
             bne ++
             pha
             ;lda Player_Y_Position
             ;and #$0f
             ;cmp #$02
             ;bcc +++
             lda StarInvincibleTimer
             ora InjuryTimer
             bne +
             pla
             jmp InjurePlayer
+++:      pla
             jmp ContSChk
+:          pla
++:       tay            ;save metatile value into Y
             and #%11000000 ;mask out all but 2 MSB
             asl
             rol            ;shift and rotate d7-d6 to d1-d0
             rol
             tax            ;use as offset for metatile data
             tya            ;get original metatile value back
             cmp ClimbMTileUpperExt,x  ;compare current metatile with climbable metatiles
             bcc ContSChk               ;if not found, skip and continue with code
             cmp #$24
             beq +
             cmp #$25
             beq +
             cmp #$26
             beq +
             cmp #$36
             bcc ContSChk
+:        
             jmp HandleClimbing         ;otherwise jump to handle climbing
ContSChk: jsr CheckForCoinMTiles     ;check to see if player touched coin
             bcs HandleCoinMetatile
             cmp #$67
             bne ChkPBtm                ;if not found, branch ahead to continue cude
             ; lda JumpspringAnimCtrl     ;otherwise check jumpspring animation control
             ;bne ExCSM2                 ;branch to leave if set
             jmp StopPlayerMove         ;otherwise jump to impede player's movement
ChkPBtm:  ldy Player_State           ;get player's state
             ;cpy #$00                   ;check for player's state set to normal
             bne StopPlayerMove         ;if not, branch to impede player's movement
             ldy PlayerFacingDir        ;get player's facing direction
             dey
             bne StopPlayerMove         ;if facing left, branch to impede movement
             cmp #$6c                   ;otherwise check for pipe metatiles
             beq PipeDwnS               ;if collided with sideways pipe (bottom), branch
             cmp #$1f                   ;if collided with water pipe (bottom), continue
             bne StopPlayerMove         ;otherwise branch to impede player's movement
PipeDwnS: lda Player_SprAttrib       ;check player's attributes
             bne PlyrPipe               ;if already set, branch, do not play sound again
             ldy #Sfx_PipeDown_Injury
             sty Square1SoundQueue      ;otherwise load pipedown/injury sound
PlyrPipe: ora #%00100000
             sta Player_SprAttrib       ;set background priority bit in player attributes
             lda #$00
             sta DebugSwim
             sta GrabFlag
             sta GrabDown
             sta GrabUp
             sta LakituRespawning
             sta EnemyDefeatPitch
             lda Player_X_Position
             and #%00001111             ;get lower nybble of player's horizontal coordinate
             beq ChkGERtn               ;if at zero, branch ahead to skip this part
             lda #$34
             sta ChangeAreaTimer
             lda #$01
             sta DontDecPT
ChkGERtn: lda GameEngineSubroutine   ;get number of game engine routine running
             cmp #$07
             beq ExCSM2                  ;if running player entrance routine or
             cmp #$08                   ;player control routine, go ahead and branch to leave
             bne ExCSM2
             lda #$02
             sta GameEngineSubroutine   ;otherwise set sideways pipe entry routine to run
ExCSM2:   rts                        ;and leavex
             
             
StopPlayerMove:                     ;leave
             jmp ImpedePlayerMove
             
HandleCoinMetatile:
             lda VRAM_Buffer1_Offset
             cmp #$20
             bcs ExCSM2
             lda #Sfx_CoinGrab
             sta Square2SoundQueue ;load coin grab sound and leave
             jsr ErACM             ;do sub to erase coin metatile from block buffer
             inc CoinTallyFor1Ups  ;increment coin tally used for 1-up blocks
             jmp GiveOneCoin        ;give coin
             
HandleAxeMetatile:
             
             
             
             
             lda #$00
             sta OperMode_Task   ;reset secondary mode
			 sta GrabFlag
             lda #$02
             sta OperMode        ;set primary mode to autoctrl mode
             lda #$18
             sta Player_X_Speed  ;set horizontal speed and continue to erase axe metatile
             lda #$01
             sta scrolldir
             sta olddirscroll
ErACM: 
             ;lda bocata2
             ;bne +
             ;inc bocata2
             ldy $02             ;load vertical high nybble offset for block buffer
             ldx AreaType
             lda blank,x
             sta ($f7),y         ;store to remove old contents from block buffer
             jmp RemoveCoin_Axe  ;update the screen accordingly
+:       rts
             
ClimbXPosAdder:
             .db $f9, $07, $07
             
ClimbPLocAdder:
             .db $ff, $00, $00
             
FlagpoleYPosData:
             .db $18, $22, $50, $68, $90
             
HandleClimbing:
             cmp #$26
             beq VineCollision
             
             ldy $04            ;check low nybble of horizontal coordinate returned from
             cpy #$06           ;collision detection routine against certain values, this
             bcc ExHC           ;makes actual physical part of vine or flagpole thinner
             cpy #$0a           ;than 16 pixels
             bcc ChkForFlagpole
ExHC: rts                ;leave if too far left or too far right
             
ChkForFlagpole:
             cmp #$25
             bne VineCollision      ;branch to alternate code if flagpole shaft not found
             
FlagpoleCollision:
             lda GameEngineSubroutine
             cmp #$05                  ;check for end-of-level routine running
             beq PutPlayerOnVine       ;if running, branch to end of climbing code
             lda #$01
             sta PlayerFacingDir       ;set player's facing direction to right
             inc ScrollLock            ;set scroll lock flag
             lda GameEngineSubroutine
             cmp #$04                  ;check for flagpole slide routine running
             beq RunFR                 ;if running, branch to end of flagpole code here
             lda #BulletBill_CannonVar ;load identifier for bullet bills (cannon variant)
             sta $00           ;store identifier here
             lda #$00
             sta CrouchingFlag2
             lda #$00
             sta pspeed
             lda #Silence
             sta EventMusicQueue       ;silence music
             lsr
             sta FlagpoleSoundQueue    ;load flagpole sound into flagpole sound queue
             sta OldSquare1SoundBuffer
             ldx #$04                  ;start at end of vertical coordinate data
             lda Player_Y_Position
             sta FlagpoleCollisionYPos ;store player's vertical coordinate here to be used later
             
ChkFlagpoleYPosLoop:
             cmp FlagpoleYPosData,x    ;compare with current vertical coordinate data
             bcs MtchF                 ;if player's => current, branch to use current offset
             dex                       ;otherwise decrement offset to use 
             bne ChkFlagpoleYPosLoop   ;do this until all data is checked (use last one if all checked)
MtchF: stx FlagpoleScore         ;store offset here to be used later
RunFR: lda #$04
             sta GameEngineSubroutine  ;set value to run flagpole slide routine
             sta PlayerOnVine
             jmp PutPlayerOnVine       ;jump to end of climbing code
             
VineCollision:
             cmp #$26                  ;check for climbing metatile used on vines
             bne PutPlayerOnVine
             lda PlayerOnVine
             bne +
             lda SavedJoypad1Bits
             and #Up_Dir
             beq ExPVne
+:       
             ;lda Player_Y_Position     ;check player's vertical coordinate
             ;cmp #$20                  ;for being in status bar area
             ;bcs PutPlayerOnVine       ;branch if not that far up
             ;lda #$01
             ;sta GameEngineSubroutine  ;otherwise set to run autoclimb routine next frame
             
PutPlayerOnVine:
             lda PlayerOnVine
             bne +
             lda GrabFlag
             bne ExPVne
             lda SavedJoypad1Bits
             and #Up_Dir
             beq ExPVne
             lda Player_Y_Speed
             bmi ExPVne
+:       lda PlayerFacingDir
             cmp #$03
             bcc +
             lda #$02
             sta PlayerFacingDir
+:         lda #$03                ;set player state to climbing
             sta Player_State
             sta PlayerOnVine
             lda #$00                ;nullify player's horizontal speed
             sta Player_X_Speed      ;and fractional horizontal movement force
             sta Player_X_MoveForce
             sta CrouchingFlag
             sta CrouchingFlag2
             lda Player_X_Position   ;get player's horizontal coordinate
             sec
             sbc ScreenLeft_X_Pos    ;subtract from left side horizontal coordinate
             cmp #$10
             bcs SetVXPl             ;if 16 or more pixels difference, do not alter facing direction
             lda #$02
             sta PlayerFacingDir     ;otherwise force player to face left
SetVXPl: ldy PlayerFacingDir     ;get current facing direction, use as offset
             lda $f7                 ;get low byte of block buffer address
             asl
             asl                     ;move low nybble to high
             asl
             asl
             clc
             adc ClimbXPosAdder-1,y  ;add pixels depending on facing direction
             sta Player_X_Position   ;store as player's horizontal coordinate
             lda $f7                 ;get low byte of block buffer address again
             bne ExPVne              ;if not zero, branch
             lda ScreenRight_PageLoc ;load page location of right side of screen
             clc
             adc ClimbPLocAdder-1,y  ;add depending on facing location
             sta Player_PageLoc      ;store as player's page location
ExPVne:  rts                     ;finally, we're done!
             
             
             
             
             ;cmp #$67                    ;do sub to check if player landed on jumpspring
             ;bne ExCJSp                  ;if carry not set, jumpspring not found, therefore leave
             ;lda DetectedFoot
             ;ora OldDetectedFoot
             ;bne ExCJSp
             ;lda #$70
             ;sta VerticalForce           ;otherwise set vertical movement force for player
             ;lda #$f9
             ;sta JumpspringForce         ;set default jumpspring force
-:        ;lda Enemy_Flag,x
             ;beq ++
             ;lda Enemy_ID,x
             ;cmp #JumpspringObject
             ;beq +
++:        ;dex
             ;bpl -
             ;jmp ExCJSp
+:      ;lda #$03
             ;sta JumpspringTimer         ;set jumpspring timer to be used later
             ;lsr
             ;sta JumpspringAnimCtrl      ;set jumpspring animation control to start animating
ExCJSp: ;rts                         ;and leave
             if MINUS_WORLD_FIX == 1
MinusWorld:
             lda #$23
             sta WorldNumber
             lda #$01
             sta AreaPointer
             jmp FinishPipeEntry
             endif
             
             
ClimbMTileUpperExt:
             ;.db $24, $6d, $8a, $c6
             .db $24, $ff, $ff, $cd
             
             ;leave
ExEBG: rts
DoEnemySideCheck44: jmp DoEnemySideCheck
NoEToBGCollision1: jmp NoEToBGCollision
EnemyBGCStateData:
             .db $01, $01, $02, $02, $02, $05
             
EnemyBGCXSpdData:
             .db $10, $f0, $20, $e0
             
EnemyToBGCollisionDet:
             lda Enemy_State,x        ;check enemy state for d6 set
             and #%00100000
             bne ExEBG                ;if set, branch to leave
             lda Enemy_Y_HighPos,x
             beq NoEToBGCollision1
             lda Enemy_Y_Position,x   ;add 62 pixels to enemy object's
             cmp #$06
             bcc NoEToBGCollision1
             cmp #$df
             bcs ExEBG    ;if enemy vertical coord + 62 < 68, branch to leave
             ldy Enemy_ID,x
             ;cpy #Spiny               ;if enemy object is not spiny, branch elsewhere
             ;bne DoIDCheckBGColl
             ;lda Enemy_Y_Position,x
             ;cmp #$25                 ;if enemy vertical coordinate < 36 branch to leave
             ;bcc NoEToBGCollision1
             
DoIDCheckBGColl:
             cpy #BlackParatroopa
             beq +
             cpy #GreenParatroopaJump ;check for some other enemy object
             bne HBChk                ;branch if not found
+:     jmp EnemyJump            ;otherwise jump elsewhere
HBChk: cpy #HammerBro           ;check for hammer bro
             bne CInvu                ;branch if not found
             jmp HammerBroBGColl      ;otherwise jump elsewhere
CInvu: cpy #Spiny               ;if enemy object is spiny, branch
             beq YesIn
             cpy #PowerUpObject       ;if special power-up object, branch
             beq YesIn
             cpy #FastGoomba
             beq YesIn
             cpy #RedKoopaShell
             beq YesIn
             cpy #$07                 ;if enemy object =>$07, branch to leave
             bcs ExEBG
YesIn: ldy #$26
             inx
             jsr BBChk_E
             cmp #$91
             bne +
             jsr nosesabe3Under
             jmp ++++
+:    lda Enemy_State,x
             bpl +++
             ldy Enemy_MovingDir,x
             iny
             jmp ++
+++:    ldy Enemy_MovingDir,x
             dey
++:        lda Half,y
             cmp Enemy_X_Speed,x
             bne ++++
             asl
             sta Enemy_X_Speed,x
++++:      
             lda Enemy_Y_Speed,x
             bpl +
             jmp DoSide2
+:       lda #$00                  ;set flag in A for save vertical coordinate
             sta EnemyOnSlope,x
             ldy #$15                  ;set Y to check the bottom middle (8,18) of enemy object
             inx
             ;inc PlayerFoot,x
             ;pha                         ;save contents of A to stack
             sty $04                     ;save contents of Y here
             lda BlockBuffer_X_Adder,y   ;add horizontal coordinate
             clc                         ;of object to value obtained using Y as offset
             adc SprObject_X_Position,x
             sta $05                     ;store here
             lda SprObject_PageLoc,x     ;of indirect here
             adc #$66
             sta $f8
             ldy $05
             lda MSBtoLSB,y
             sta $f7                     ;store here and leave
             ldy $04                     ;get old contents of Y
             
             ;jsr TheLagMaker               ;if need to lag the game to an unplayable level, uncomment this
             
             lda SprObject_Y_Position,x  ;get vertical coordinate of object
             clc
             adc BlockBuffer_Y_Adder3,y   ;add it to value obtained using Y as offset
             and #%11110000              ;mask out low nybble
             sta $02                     ;store result here
             tay                         ;use as offset for block buffer
             lda ($f7),y                 ;check current content of block buffer
             sta $03                     ;and store here
             ldy $04                     ;get old contents of Y again
             ;pla                         ;pull A from stack
             ;bne +                       ;if A = 1, branch
             lda SprObject_Y_Position,x  ;if A = 0, load vertical coordinate
             and #%00001111              ;and mask out high nybble
             sta $04                     ;store masked out result here
             ldx $03                     ;get saved content of block buffer                       ;and leave
			 txa
			 tay
             lda MetatileThingy,x
             ldx ObjectOffset            ;get object offset
			 cpy #$99
			 beq +++
             cmp #$00                    ;check to see if object bumped into anything
             ;jmp ++
+:     ;lda SprObject_X_Position,x  ;otherwise load horizontal coordinate
             ;and #%00001111              ;and mask out high nybble
             ;sta $04                     ;store masked out result here
             ;ldx $03                     ;get saved content of block buffer                       ;and leave
             ;lda MetatileThingy,x
             ;ldx ObjectOffset            ;get object offset
             ;cmp #$00                    ;check to see if object bumped into anything
++:    bne +++
             jmp NoEToBGCollision
+++:       cmp #$8b                        ;okputa
             bne hypermas
             lda Enemy_State,x
             beq ++++
             lda Enemy_ID,x
             cmp #RedKoopa
             beq +++
             cmp #KoopaShell
             beq +++
             cmp #RedKoopaShell
             beq +++
             cmp #GreenKoopa
             beq +++
             cmp #DemotedRPTroopa
             beq +++
             cmp #BuzzyBeetle
             beq +++
             lda Enemy_State,x
             and #%00100110
             beq +++ 
             jmp LandEnemyProperly
+++:   cpx GrabID
             bne +
             lda GrabFlag
             bne ++
+:       lda #Sfx_Bump
             sta Square1SoundQueue
++:       lda #$fb
             sta Enemy_Y_Speed,x
             rts
++++:
             lda #$01
             sta Enemy_State,x
             rts
hypermas:
++:
             sty temp6
             ldy PTimer
             beq +    
             cmp #$51
             beq NoEToBGCollision
             cmp #$52
             beq NoEToBGCollision
             cmp #$28
             beq NoEToBGCollision
             cmp #$27
             beq NoEToBGCollision
             ldy temp6
             jmp HandleEToBGCollision
+:       ldy temp6
             cmp #$c2
             beq GetBlockCoin2
             jmp HandleEToBGCollision  ;if block underneath enemy, branch
GetBlockCoin2:
             ldy Enemy_ID,x
             cpy #PowerUpObject
             beq NoEToBGCollision
             tay
             cpx GrabID
             bne ++
             lda GrabUp
             bne +
++:       lda Enemy_State,x      ;if enemy state d7 not set, branch
             bpl NoEToBGCollision
+:        
             tya
             jmp GetBlockCoin
NoEToBGCollision:
             ldx ObjectOffset
             jmp DoSide2       ;otherwise skip and do something else
LandEnemyInitState1:
             lda Enemy_ID,x
             cmp #PowerUpObject
             beq PUPs2
             jmp InvEnemyDir
PUPs2:
             jmp PUPs
LandEnemyProperly1:
             jmp LandEnemyProperly
NoEToBGCollisionAndSlowdown:
             jmp DoSide2
             ;jmp PutEnemyOnSlope
Enemy_PSwitchJmp:
             jmp Enemy_PSwitch
             
HandleEToBGCollision: 
             beq NoEToBGCollision      ;if blank $26, coins, or hidden blocks, jump, enemy falls through
             cmp #$26                  ;blank metatile used for vines?
             beq NoEToBGCollision
             cmp #$c2                  ;regular coin?
             bne +
             ldy PTimer
             bne +
             ldy Enemy_ID,x
             cpy #PowerUpObject
             beq NoEToBGCollision
             jmp GetBlockCoin
+:      ;beq NoEToBGCollision
             cmp #$60       ;hidden 1-up block?
             beq NoEToBGCollision2
             cmp #$6f
             beq NoEToBGCollision2
             cmp #$74
             beq NoEToBGCollision2
             cmp #$73
             beq NoEToBGCollision2
             cmp #$30
             beq NoEToBGCollision2
             cmp #$c5
             beq NoEToBGCollision2
             cmp #$8c
             beq Enemy_PSwitchJmp
++:
             cmp #$5f
             beq NoEToBGCollision2
             cmp #$70
             beq NoEToBGCollision2
             cmp #$25
             beq NoEToBGCollision2
             cmp #$91
             beq NoEToBGCollisionAndSlowdown
             ;pha
             ;ldy #$24
             ;jsr BlockBufferChk_Enemy
             ;cmp #$71
             ;beq PutEnemyOnSlope2
             ;pla
vale: ldy OnOffFlag
             beq +++
             cmp #$8f
             beq NoEToBGCollision2
             jmp ++
+++:  cmp #$8e
             beq NoEToBGCollision2
++:
             ldy PTimer
             bne +++
             cmp #$72
             beq NoEToBGCollision2
+++: 
             ldy PTimer
             beq ++
             
             cmp #$c2
             beq LandEnemyProperly2
             cmp #$72
             beq LandEnemyProperly2
++:      cmp #$23
             bne LandEnemyProperly2     ;check for blank metatile $23 and branch if not found
             ldy $02                   ;get vertical coordinate used to find block
             lda #$54                  ;store default blank metatile in that spot so we won't
             sta ($f7),y               ;trigger this routine accidentally again
             lda Enemy_State,x
             and #%10000000
             beq PUPs
             jmp LandEnemyInitState1
LandEnemyProperly2: jmp LandEnemyProperly
NoEToBGCollision2:    jmp NoEToBGCollision
PUPs: lda Enemy_ID,x
             cmp #RedKoopaShell
             beq GiveOEPoints
             cmp #UDPiranhaPlant
             beq GiveOEPoints
             cmp #RUDPiranhaPlant
             beq GiveOEPoints
             cmp #RedPiranhaPlant
             beq GiveOEPoints
             cmp #$15                  ;if enemy object => $15, branch ahead
             bcs ChkToStunEnemies
             cmp #Goomba               ;if enemy object not goomba, branch ahead of this routine
             beq +
             cmp #FastGoomba
             bne GiveOEPoints
+:    jsr ShellOrBlockDefeat    ;do this sub to kill enemy
             lda #$fc                  ;alter vertical speed of enemy and leave
             sta Enemy_Y_Speed,x
             
GiveOEPoints:
             lda #$01                  ;award 100 points for hitting block beneath enemy
             sta FloateyNum_Control,x ;set number of points control for floatey numbers
             lda #$30
             sta FloateyNum_Timer,x   ;set timer for floatey numbers
             lda Enemy_Y_Position,x
             sta FloateyNum_Y_Pos,x   ;set vertical coordinate
             lda Enemy_Rel_XPos
             sta FloateyNum_X_Pos,x   ;set horizontal coordinate and leave
             
ChkToStunEnemies:
             cmp #PowerUpObject
             bne +
             lda Enemy_State,x          ;load enemy state
             and #%11110000             ;save high nybble
             ora #%00000010
             sta Enemy_State,x          ;set d1 of enemy state
             jmp SetStun+4
+:
             cmp #$0a                   ;perform many comparisons on enemy object identifier
             bcc SetStun
             cmp #RedKoopaShell
             beq SetStun
             cmp #UDPiranhaPlant
             beq SetStun
             cmp #RUDPiranhaPlant
             beq SetStun
             cmp #RedPiranhaPlant
             beq SetStun
             cmp #$11                   ;if the enemy object identifier is equal to the values
             bcs SetStun                ;$09, $0e, $0f or $10, it will be modified, and not
             cmp #$0a                   ;modified if not any of those values, note that piranha plant will
             bcc Demote                 ;always fail this test because A will still have vertical
             cmp #PiranhaPlant          ;coordinate from previous addition, also these comparisons
             bcc SetStun                ;are only necessary if branching from $d7a1
Demote:   and #%00000001             ;erase all but LSB, essentially turning enemy object
             sta Enemy_ID,x             ;into green or red koopa troopa to demote them
SetStun:  lda Enemy_State,x          ;load enemy state
             and #%01110000             ;save high nybble
             ora #%00000010
             sta Enemy_State,x          ;set d1 of enemy state
             dec Enemy_Y_Position,x
             dec Enemy_Y_Position,x     ;subtract two pixels from enemy's vertical position
             lda Enemy_ID,x
             cmp #Bloober               ;check for bloober object
             beq SetWYSpd
             lda #$fd                   ;set default vertical speeds
             ldy SwimmingFlag
             beq SetNotW
SetWYSpd: lda #$ff                   ;change the vertical speed
SetNotW:  sta Enemy_Y_Speed,x        ;set vertical speed now
             ldy #$01
             lda Enemy_X_Position,x     ;get distance between enemy object's
             sec                        ;horizontal coordinate and the player's
             sbc Player_X_Position      ;horizontal coordinate
             sta $00                    ;and store here
             lda Enemy_PageLoc,x
             sbc Player_PageLoc         ;subtract borrow, then leave
             bpl ChkBBill               ;branch if enemy is to the right of player
             iny                        ;increment Y if not
ChkBBill: lda Enemy_ID,x      
             cmp #BulletBill_CannonVar  ;check for bullet bill (cannon variant)
             beq NoCDirF
             cmp #BulletBill_FrenzyVar  ;check for bullet bill (frenzy variant)
             beq NoCDirF                ;branch if either found, direction does not change
             sty Enemy_MovingDir,x      ;store as moving direction
NoCDirF:  dey                        ;decrement and use as offset
             lda EnemyBGCXSpdData,y     ;get proper horizontal speed
             sta Enemy_X_Speed,x        ;and store, then leave
ExEBGChk: rts
LeComparation:
             .db $05, $0e
LandEnemyProperly:
             ldy FramesMissed
             lda $04                 ;check lower nybble of vertical coordinate saved earlier
             sec
             sbc #$08                ;subtract eight pixels
             cmp LeComparation,y
             bcs ChkForRedKoopa1      ;branch if lower nybble in range of $0d-$0f before subtract
             lda Enemy_State,x      
             and #%01000000          ;branch if d6 in enemy state is set
             bne LandEnemyInitState
             lda Enemy_State,x
             bmi SChkA
             jmp ChkLandedEnemyState
SChkA: jmp DoEnemySideCheck                ;if lower nybble < $0d, d7 set but d6 not set, jump here
ChkForRedKoopa1:
             jmp ChkForRedKoopa
             
ProcEnemyDirection:
             lda Enemy_ID,x            ;check enemy identifier for goomba
             cmp #Goomba               ;branch if found
             beq LandEnemyInitState
             cmp #Spiny                ;check for spiny
             bne InvtD                 ;branch if not found
             lda #$01
             sta Enemy_MovingDir,x     ;send enemy moving to the right by default
             lda #$08
             sta Enemy_X_Speed,x       ;set horizontal speed accordingly
             lda FrameCounter
             and #%00000111            ;if timed appropriately, spiny will skip over
             beq LandEnemyInitState    ;trying to face the player
InvtD:   ldy #$01                  ;load 1 for enemy to face the left (inverted here)
             lda Enemy_X_Position,x    ;get distance between enemy object's
             sec                       ;horizontal coordinate and the player's
             sbc Player_X_Position     ;horizontal coordinate
             sta $00                   ;and store here
             lda Enemy_PageLoc,x
             sbc Player_PageLoc        ;subtract borrow, then leave
             bpl CNwCDir               ;if enemy to the right of player, branch
             iny                       ;if to the left, increment by one for enemy to face right (inverted)
CNwCDir: tya
             cmp Enemy_MovingDir,x     ;compare direction in A with current direction in memory
             bne LandEnemyInitState
             lda Enemy_ID,x
             cmp #Spiny
             bne LandEnemyInitState
             jsr ChkForBump_HammerBroJ ;if equal, not facing in correct dir, do sub to turn around
             
LandEnemyInitState:
             lda #$00                    ;initialize vertical speed
             sta Enemy_Y_Speed,x         ;and movement force
             sta Enemy_Y_MoveForce,x     ;do something here to vertical speed and something else
             lda Enemy_Y_Position,x
             and #%11110000          ;save high nybble of vertical coordinate, and
             ora #%00001000          ;set d3, then store, probably used to set enemy object
             sta Enemy_Y_Position,x  ;neatly on whatever it's landing on
             lda Enemy_State,x
             and #%10000000         ;if d7 of enemy state is set, branch
             bne NMovShellFallBit
             lda #$00               ;otherwise initialize enemy state and leave
             sta Enemy_State,x      ;note this will also turn spiny's egg into spiny
             sta EnemyOnSlope,x
             rts
             
NMovShellFallBit:
             lda Enemy_State,x   ;nullify d6 of enemy state, save other bits
             and #%10111111      ;and store, then leave
             sta Enemy_State,x
             rts
             
ChkForRedKoopa:
             lda Enemy_ID,x            ;check for red koopa troopa $03
             cmp #BuzzyBeetle
             beq +
             cmp #DemotedRPTroopa
             beq +
             cmp #RedKoopa
             bne Chk2MSBSt             ;branch if not found
             +            lda Enemy_State,x
             bne Chk2MSBSt 
             jmp ChkForBump_HammerBroJ ;if enemy found and in normal state, branch
Chk2MSBSt:   lda Enemy_State,x         ;save enemy state into Y
             tay
             bpl GetSteFromD           ;branch if not set
             lda Enemy_State,x
             ora #%01000000            ;set d6
             jmp SetD6Ste              ;jump ahead of this part
GetSteFromD: lda EnemyBGCStateData,y   ;load new enemy state with old as offset
SetD6Ste:    sta Enemy_State,x         ;set as new state
             
             
DoEnemySideCheck:
             lda Enemy_Y_HighPos,x
             beq ExESdeC
             lda Enemy_Y_Position,x     ;if enemy within status bar, branch to leave
             cmp #$10                   ;because there's nothing there that impedes movement
             bcc ExESdeC
             ldy #$16                   ;start by finding block to the left of enemy ($00,$14)
             lda #$02                   ;set value here in what is also used as
             sta temp1                  ;OAM data offset
SdeCLoop: lda temp1                  ;check value
             cmp Enemy_MovingDir,x      ;compare value against moving direction
             bne NextSdeC               ;branch if different and do not seek block there
             lda #$01                   ;set flag in A for save horizontal coordinate 
             inx
             jsr BBChk_E
             beq NextSdeC
             sta temp6
             jmp nosesabe
NextSdeC: dec temp1                  ;move to the next direction
             iny
             cpy #$18                   ;increment Y, loop only if Y < $18, thus we check
             bcc SdeCLoop               ;enemy ($00, $14) and ($10, $14) pixel coordinates
ExESdeC:  rts
Half: .db $04, $fc, $18, $e8
nosesabe3Under:
             lda Enemy_Y_Speed,x
             cmp #$fd
             bcs ++
             bpl ++
             lda #$fc
             sta Enemy_Y_Speed,x
             jmp +
++:        lda Enemy_Y_Speed,x
             cmp #$01
             bcc +
             bmi +
             lda #$01
             sta Enemy_Y_Speed,x
+:        lda Enemy_ID,x
             cmp #PowerUpObject
             beq +++
             lda Enemy_State,x
             bpl +++
             ldy Enemy_MovingDir,x
             iny
             jmp ++
+++:    ldy Enemy_MovingDir,x
             dey
++:        lda Half,y
             sta Enemy_X_Speed,x
+:        rts
nosesabe3:
             jmp nosesabe2
GetBlockCoin1:
             jmp GetBlockCoin
nosesabe:
             cmp #$26       ;blank metatile used for vines?
             beq nosesabe3
             cmp #$c2       ;regular coin?
             beq nosesabe3
             cmp #$5f       ;hidden coin block?
             beq nosesabe3
             cmp #$70
             beq nosesabe3
             cmp #$25
             beq nosesabe3
             cmp #$30
             beq nosesabe3
             cmp #$60       ;hidden 1-up block?
             beq nosesabe3
             cmp #$74
             beq nosesabe3
             cmp #$6f
             beq nosesabe3
             cmp #$c5
             beq nosesabe3
             cmp #$73
             beq nosesabe3
             cmp #$91
             beq nosesabe3
cantasmal:
+++:      sty temp6
             ldy EnemyOnSlope,x
             bne ExESdeC
             ldy OnOffFlag
             beq +++
             cmp #$8f
             beq nosesabe3
             jmp ++
+++:      cmp #$8e
             beq nosesabe3
++:
             ldy PTimer
             bne +
             cmp #$72
             beq nosesabe3
+:          
             cmp #$88
             beq nosesabe3
             cmp #$63
             beq nosesabe3
             cmp #$92
             beq nosesabe3
             pha
             ldy PTimer
             beq +
             lda Enemy_ID,x
             cmp #PowerUpObject
             beq ++               ;and if so, branch ahead and do not play sound
             lda Enemy_State,x
             bmi +
++:          pla
             cmp #$52
             beq nosesabe3
             .db $a9 ;lda to skip this pla
+:          pla  
             ldy temp6
ChkForBump_HammerBroJ: 
             lda Enemy_ID,x
             cmp #PowerUpObject
             beq NoBump             ;and if so, branch ahead and do not play sound
             cpx GrabID
             bne ++
             lda GrabUp
             bne +
++:        lda Enemy_State,x      ;if enemy state d7 not set, branch
             bpl NoBump
+:        
             inx
             jsr BBChk_E
             ldy PTimer
             beq +
             cmp #$51
             beq GetBlockCoin3
             cmp #$52
             beq GetBlockCoin3
             cmp #$28
             beq GetBlockCoin3
             cmp #$27
             beq GetBlockCoin3
             cmp #$c2
             bne +
             jsr BreakBlock
             jmp PaTras
+:        cmp #$c2
             beq GetBlockCoin3
             jsr ToBreak                ;if not, check for others blocks
             
NoBump: lda Enemy_ID,x          ;check for hammer bro
             cmp #$05
             bne InvEnemyDir         ;branch if not found
             lda #$00
             sta $00                 ;initialize value here for bitmask  
             ldy #$fa                ;load default vertical speed for jumping
             jmp SetHJ               ;jump to code that makes hammer bro jump
GetBlockCoin3:
             jmp GetBlockCoin
InvEnemyDir:
             jmp RXSpd
BreakBlock2: jsr BreakBlock
             .db $a9
PaLante: rts                    ;if not, turn around
PaTras: jmp RXSpd                
Webos3: jmp Webos2
             
nosesabe2:         
             pha
             cpx GrabID
             bne ++
             lda GrabUp
             beq ++
             pla
             ldy PTimer
             bne +
             cmp #$c2
             beq GetBlockCoin
+:
             pha
             
++:          lda Enemy_State,x      ;if enemy state d7 not set, branch
             bpl rtsp3
             lda Enemy_ID,x
             cmp #PowerUpObject
             beq rtsp3
+:        
             pla
             ldy PTimer
             bne +
             cmp #$c2
             beq GetBlockCoin
+:          cmp #$c2
             beq BreakBlock2
             cmp #$5f
             beq Webos3
             ldy $f6
             sty $609b
             ldy $f7
             sty $609c
             ldy $f8
             sty $609d
             ldy $f9
             sty $609e
             cmp #$30
             beq StarEJmp
             cmp #$6f
             beq MushEJmp
             cmp #$73
             beq StarEJmp
rtsp:
             rts
rtsp2:
             pla
             rts
rtsp3:
             pla
             ldy PTimer
             beq rtsp
             cmp #$c2
             beq InvEnemyDir
             rts
MushEJmp:
             jmp MushE
StarEJmp:
             jmp StarE
GetBlockCoin:
             cpx GrabID
             bne ++
             lda GrabUp
             bne +
++:        lda Enemy_State,x      ;if enemy state d7 not set, branch
             bpl rtsp
+:        lda VRAM_Buffer1_Offset
             cmp #$20
             bcs rtsp
             jsr ErACM
             lda #Sfx_CoinGrab
             sta Square2SoundQueue
             jmp GiveOneCoin
CoinE:
             lda #$c4
             sta temp6
MultiCoin:
             cpx GrabID
             bne ++
             lda GrabUp
             bne +
++:    lda Enemy_State,x      ;if enemy state d7 not set, branch
             bpl rtsp
+:    cpx #$06
             beq rtsp
             lda #Sfx_CoinGrab
             sta Square2SoundQueue
             jsr GetBlockEnemy
             tya
             tax
             jsr FindEmptyMiscSlot  ;set offset for empty or last misc object buffer slot
             lda Block_PageLoc,x   ;get page location saved earlier
             sta Misc_PageLoc,y     ;and save as page location for misc object
             lda Block_X_Position,x                ;get low byte of block buffer offset
             clc
             adc #$05                 ;add five pixels
             sta Misc_X_Position,y  ;save as horizontal coordinate for misc object
             lda Block_Y_Position,x               ;get vertical high nybble offset from earlier
             sec
             sbc #$10               ;remove 16 pixels
             sta Misc_Y_Position,y  ;store as vertical coordinate
             jmp JCoinC
             
brickshatterex:
             ldy $02
             lda #$00
             sta ($f7),y
             rts
             
BreakBlock:
             ldy $02
             lda #$23
             sta ($f7),y
             jsr WriteBlockMetatile
             lda #Sfx_BrickShatter
             sta NoiseSoundQueue
             lda ScreenLeft_X_Pos    ;get horizontal coordinate for left side of screen
             clc
             adc #$10                ;subtract 72 pixels regardless of enemy object
             sta $01                 ;store result here
             lda ScreenLeft_PageLoc
             adc #$00                ;subtract borrow from page location of left side
             sta $00                 ;store result here
             lda ScreenRight_X_Pos   ;add 72 pixels to the right side horizontal coordinate
             sec
             sbc #$10
             sta $03                 ;store result here
             lda ScreenRight_PageLoc     
             sbc #$00                ;then add the carry to the page location
             sta $04                 ;and store result here
             lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
             cmp $01                 ;to modified horizontal left edge coordinate to get carry
             lda Enemy_PageLoc,x
             sbc $00                 ;then subtract it from the page coordinate of the enemy object
             bmi +                      ;if enemy object is too far left, branch to erase it
             lda Enemy_X_Position,x  ;compare horizontal coordinate of the enemy object
             cmp $03                 ;to modified horizontal right edge coordinate to get carry
             lda Enemy_PageLoc,x
             sbc $04                 ;then subtract it from the page coordinate of the enemy object
             bmi ++                    ;if enemy object is on the screen, leave, do not erase enemy
+:        ldy $02
             lda #$00
             sta ($f7),y
             rts
++:        ldy SprDataOffset_Ctrl
             lda BlockBounceTimer
             bne brickshatterex
             lda $02
             clc
             adc #$20
             sta Block_Y_Position,y
             lda GrabUp
             beq ++
             lda Enemy_X_Position,x
             clc
             adc #$08
             and #$f0
             sta Block_X_Position,y
             jmp +
++:    
             lda Enemy_X_Position,x
             and #$f0
             ldy Enemy_MovingDir,x
             dey
             bne ++
             clc
             adc #$10
             jmp +++
++:     and #$f0
             clc
+++:
             ldy SprDataOffset_Ctrl
             sta Block_X_Position,y  ;save as horizontal coordinate for block object
+:    
             lda Enemy_PageLoc,x
             adc #$00                ;add carry to page location of player
             sta Block_PageLoc,y    ;save as page location of block object
             lda Enemy_Y_HighPos,x
             sta Block_Y_HighPos,y   ;save vertical high byte of player into
             lda $f7                  ;get low byte of block buffer address used in same routine
             sta Block_BBuf_Low,y
             lda $f8
             sta Block_BBuf_High,y
             lda $02
             sta Block_Orig_YPos,y
             lda #$12
             sta Block_State,y
             lda #$00
             sta Block_Metatile,y
             tya
             tax
             jsr BrickShatter
             lda SprDataOffset_Ctrl
             eor #$01
             sta SprDataOffset_Ctrl
             ldx ObjectOffset
             rts
             
             
             
ShellBumpTable:
             .db $c0, $5f, $29 ;02 coin block
             .db $5d, $58, $29, $34 ;06 multicoins brick
             .db $5a, $55, $29, $2a, $31, $6f, $30, $c1, $c1 ;0f power-up
             .db $33, $33, $57, $73, $c6, $5c, $30 ;16 star
             .db $c7, $35, $35, $5e, $59 ;1b 1up
             .db $5b, $74 ;1c vine
             
ToBreak:
             lda Enemy_State,x
             bpl rp
             lda GrabFlag
             beq +
             cpx GrabID
             bne +
             rts
GetBlockCoin4:
             jmp GetBlockCoin
BreakBlock1:
             jmp BreakBlock
+:    
             lda $03
Webos2:
             cmp #$c2                ;coin?
             beq GetBlockCoin4
             
             cmp #$51                ;brick
             beq BreakBlock1
             cmp #$52                ;brick with line
             beq BreakBlock1
             cmp #$28                ;brick
             beq BreakBlock1
             cmp #$27                ;brick with line
             beq BreakBlock1
             
             ldy #Sfx_Bump           ;if not, play bump sound
             sty Square1SoundQueue
             
             cmp #$8d
             beq OnOffSetE
             sta temp9
             ldy #$1d
ShellBumpLoop:
             cmp ShellBumpTable,y
             beq +
             dey
             bpl ShellBumpLoop
             rts
+:    cmp #$74
             beq NothingBlock
             lda #$00
             cpy #$1c
             bcs +
             lda #$01
             cpy #$17
             bcs +
             lda #$02
             cpy #$10
             bcs +
             lda #$03
             cpy #$07
             bcs +
             lda #$04
             cpy #$03
             bcs +
             lda #$05
+:    jsr JumpEngineOthersTemp
             
             .dw VineE
             .dw P1upE
             .dw StarE
             .dw MushE
             .dw MultiCoinE
             .dw CoinE
             
rp:    rts
NothingBlock:
             sta temp6
             jsr GetBlockEnemy
             rts
OnOffSetE:
             lda OnOffBits
             eor #%00000001
             sta OnOffBits
             and #%00000001
             sta OnOffFlag
             rts
CoinE2:
             lda #$00                 ;initialize multi-coin timer flag
             sta BrickCoinTimerFlag
             lda #$10
             sta BrickCoinTimer       ;if not set, set brick coin timer
             jmp CoinE                 
MultiCoinE:
             lda BrickCoinTimerFlag   ;check brick coin timer flag
             bne +                    ;if set, timer expired or counting down, thus branch
             lda #$10
             sta BrickCoinTimer       ;if not set, set brick coin timer
             inc BrickCoinTimerFlag   ;and set flag linked to it
+:  dec BrickCoinTimer
             lda BrickCoinTimer
             beq CoinE2
             lda temp9
             sta temp6
             jmp MultiCoin
MushE:
             cpx GrabID
             bne ++
             lda GrabUp
             bne +
++:    lda Enemy_State,x      ;if enemy state d7 not set, branch
             bpl rp
+:    
             lda #$00
             .db $2c
StarE:
             lda #$02
             .db $2c
P1upE:
             lda #$03
BlockPower:
sta PowerUpType            ;fun fact: set block state to 1 to make it bump
             lda #$c4
             sta temp6
             jsr GetBlockEnemy
             tya
             tax
             lda #$00
             jmp SetupPowerUp
VineE:
             lda #$c4
             sta temp6
             jsr GetBlockEnemy
             jsr jmpidk
             bcs +
             stx $7fcd
             ldy SprDataOffset_Ctrl  ;get control bit
             jmp Setup_Vine1
+:    rts
GetBlockEnemy:
             lda $609b
             sta $f6
             lda $609c
             sta $f7
             lda $609d
             sta $f8
             lda $609e
             sta $f9
             ldy SprDataOffset_Ctrl
             lda #$01
             sta BlockUsed,y
             lda Block_State,y
             ora #$00000001
             sta Block_State,y
             lda #$07
             sta BlockBounceTimer     ;set block bounce timer
             sty temp9
             ldy $02
             lda #$23
             sta ($f7),y
             jsr WriteBlockMetatile
             ldy temp9
             lda #$fe
             sta Block_Y_Speed,y
             lda temp6
             sta Block_Metatile,y
             lda $02
             clc
             adc #$20
             sta Block_Y_Position,y
             lda GrabUp
             beq ++
             lda Enemy_X_Position,x
             add #$08
             and #$f0
             sta Block_X_Position,y
             jmp +
++:    
             lda Enemy_X_Position,x
             and #$f0
             ldy Enemy_MovingDir,x
             dey
             bne ++
             clc
             adc #$10
             jmp +++
++: and #$f0
             clc
+++:
             ldy temp9
             sta Block_X_Position,y  ;save as horizontal coordinate for block object
+:    
             lda Enemy_PageLoc,x
             adc #$00
             sta Block_PageLoc,y
             lda $f7                  ;get low byte of block buffer address used in same routine
             sta Block_BBuf_Low,y
             lda $f8
             sta Block_BBuf_High,y
             lda $02
             sta Block_Orig_YPos,y
             lda SprDataOffset_Ctrl
             eor #$01
             sta SprDataOffset_Ctrl
FY2:
             rts
             
             
DoSide1:
             jmp DoSide
Enemy_PSwitchJmp2:
             jmp Enemy_PSwitch
EnemyJump:
             lda Enemy_Y_Position,x  ;add 62 pixels to enemy object's
             cmp #$0c                ;compare against a certain range     ;do a sub here
             bcc DoSide1              ;if enemy vertical coord + 62 < 68, branch to leave
             cmp #$d5
             bcs DoSide1
             lda Enemy_Y_HighPos,x
             beq DoSide1
             lda Enemy_Y_Speed,x
             bmi DoSide1 
             lda #$00                  ;set flag in A for save vertical coordinate
             ldy #$15                  ;set Y to check the bottom middle (8,18) of enemy object
             inx
             jsr BBChk_E 
			 ldy $03
			 cpy #$99
			 bne +
			 jmp MakePKoopaJump
+:			 cmp #$00
             beq DoSide1            ;standing on anything, then branch to same place if not
             cmp #$8c
             beq Enemy_PSwitchJmp2
             ldy PTimer
             beq +
             cmp #$51
             beq DoSide1
             cmp #$52
             beq DoSide1
             cmp #$28
             beq DoSide1
             cmp #$27
             beq DoSide1
             cmp #$91
             beq DoSide1
             cmp #$c2
             beq ++
             ldy PTimer
             bne +
             cmp #$72
             beq MakePKoopaJump
+:      ldy OnOffFlag
             beq ++++
             cmp #$8f
             beq FY2
             jmp +++
++++:     cmp #$8e
             beq FY2
+++:
             cmp #$26       ;blank metatile used for vines?
             beq FY2
             cmp #$c2       ;regular coin?
             beq FY2
             cmp #$5f       ;hidden coin block?
             beq FY2
             cmp #$60       ;hidden 1-up block?
             beq FY3            ;branch if found
             cmp #$71
             beq FY3
             cmp #$74
             beq FY3
             cmp #$6f
             beq FY3
             cmp #$25
             beq FY3
             cmp #$30
             beq FY3
             cmp #$70
             beq FY3
             cmp #$c5
             beq FY3
             cmp #$25
             beq FY3
             pha
             cmp #$88            ;hiweputa
             beq bruh
             cmp #$c3
             bne bruh
             lda Enemy_Y_Position,x
             and #$0f
             cmp #$08
             bcs bruh
bru:    pla
             rts
bruh:    pla
             cmp #$72
             beq FY3
             cmp #$91
             beq FY3
MakePKoopaJump:
++:     lda #$00                    ;initialize vertical speed
             sta Enemy_Y_Speed,x         ;and movement force
             sta Enemy_Y_MoveForce,x            ;do something here to vertical speed and something else
             lda Enemy_Y_Position,x
             and #%11110000          ;save high nybble of vertical coordinate, and
             ora #%00001000          ;set d3, then store, probably used to set enemy object
             sta Enemy_Y_Position,x  ;neatly on whatever it's landing on
             lda #$fd
             sta Enemy_Y_Speed,x   ;make the paratroopa jump again
DoSid2:    jmp DoEnemySideCheck
FY3:    rts
DoSide: lda Enemy_Y_Speed,x
             bpl DoSid2
             lda Enemy_Y_Position,x
             cmp #$1f
             bcc DoSid2
             lda Enemy_Y_HighPos,x
             beq DoSid2
             jsr ChkAboveEnemy
             beq DoSid2
             cmp #$91
             beq DoSid2
             ldy PTimer
             beq NoPe
             cmp #$51
             beq DoSid2
             cmp #$29
             beq DoSid2
             cmp #$2a
             beq +
             cmp #$2b
             beq +
             cmp #$30
             beq +
             cmp #$52
             beq +
             cmp #$28
             beq +
             cmp #$27
             beq +
             
             cmp #$c2
             beq Boi
             ldy PTimer
             bne +
             cmp #$72
             beq Boi
NoPe:   cmp #$26       ;blank metatile used for vines?
             beq FY3
             cmp #$c2       ;regular coin?
             beq FY3
             cmp #$5f       ;hidden coin block?
             beq FY3
             cmp #$71
             beq FY3
             cmp #$60
             beq FY3
             cmp #$74
             beq FY3
             cmp #$6f
             beq FY3
             cmp #$25
             beq FY3
             cmp #$70
             beq FY3
             cmp #$63
             beq FY3
             cmp #$c5
             beq FY3
             cmp #$73
             beq FY4
             cmp #$88
             beq FY4
             ldy OnOffFlag
             beq Oetu
             cmp #$8f
             beq FY4
             jmp XD2
Oetu:     cmp #$8e
             beq FY
XD2:
Boi:    lda #$02
             sta Enemy_Y_Speed,x
             sta Enemy_Y_MoveForce,x
+:       jmp DoEnemySideCheck  ;check for horizontal blockage, then leave
FY4:    rts
NoUnderHammerBro2:
             jmp NoUnderHammerBro
HammerBroBGColl:
             lda #$00                  ;set flag in A for save vertical coordinate
             ldy #$15                  ;set Y to check the bottom middle (8,18) of enemy object
             inx
             jsr BBChk_E
             beq NoUnderHammerBro2    
             cmp #$5f
             beq NoUnderHammerBro
             cmp #$60
             beq NoUnderHammerBro
             cmp #$70
             beq NoUnderHammerBro
             cmp #$6f
             beq NoUnderHammerBro
             cmp #$30
             beq NoUnderHammerBro
             cmp #$25
             beq NoUnderHammerBro
             cmp #$c5
             beq NoUnderHammerBro
             cmp #$74
             beq NoUnderHammerBro
             cmp #$91
             beq NoUnderHammerBro
             cmp #$73
             beq NoUnderHammerBro
             ldy OnOffFlag
             beq +++
             cmp #$8f
             beq NoUnderHammerBro
             jmp ++
+++:  cmp #$8e
             beq NoUnderHammerBro
++:      ldy PTimer
             bne ++
             cmp #$72
             beq NoUnderHammerBro
             cmp #$c2       ;regular coin?
             beq NoUnderHammerBro
             jmp +
++:   cmp #$52
             beq NoUnderHammerBro
             cmp #$51
             beq NoUnderHammerBro
+:    cmp #$23             ;check for blank metatile $23 and branch if not found
             bne UnderHammerBro
             
KillEnemyAboveBlock:
             lda Enemy_State,x ;tu puta madre
             and #%01111111
             sta Enemy_State,x
             jsr ShellOrBlockDefeat  ;do this sub to kill enemy
             lda #$fc                ;alter vertical speed of enemy and leave
             sta Enemy_Y_Speed,x
FY:   rts
             
UnderHammerBro:
             lda EnemyFrameTimer,x ;check timer used by hammer bro
             bne NoUnderHammerBro  ;branch if not expired
             lda Enemy_State,x
             and #%10001000        ;save d7 and d3 from enemy state, nullify other bits
             sta Enemy_State,x     ;and store
             lda #$00                    ;initialize vertical speed
             sta Enemy_Y_Speed,x         ;and movement force
             sta Enemy_Y_MoveForce,x            ;do something here to vertical speed and something else
             lda Enemy_Y_Position,x
             and #%11110000          ;save high nybble of vertical coordinate, and
             ora #%00001000          ;set d3, then store, probably used to set enemy object
             sta Enemy_Y_Position,x  ;neatly on whatever it's landing on
             jmp DoEnemySideCheck  ;then check for horizontal blockage and leave
             
NoUnderHammerBro:
             lda Enemy_State,x  ;if hammer bro is not standing on anything, set d0
             ora #$01           ;in the enemy state to indicate jumping or falling, then leave
             sta Enemy_State,x
             rts
             
ChkAboveEnemy:
             lda #$00
             ldy #$21
             inx
             jmp BBChk_E
ClearBounceFlag2:
             lda #$00
             sta FireballBouncingFlag,x  ;clear bouncing flag by default
             rts
FireballBGCollision:
             lda Fireball_Y_Position,x   ;check fireball's vertical coordinate
             cmp #$18
             bcc ClearBounceFlag2         ;if within the status bar area of the screen, branch ahead
             ldy #$1a                      ;set offset for block buffer adder data
             txa
             clc
             adc #$07                  ;add seven bytes to use
             tax
             lda #$00                  ;set A to return vertical coordinate
             pha                         ;save contents of A to stack
             sty $04                     ;save contents of Y here
             lda BlockBuffer_X_Adder,y   ;add horizontal coordinate
             clc                         ;of object to value obtained using Y as offset
             adc SprObject_X_Position,x
             sta $05                     ;store here
             lda SprObject_PageLoc,x     ;of indirect here
             adc #$66
             sta $f8
             ldy $05
             lda MSBtoLSB,y
             sta $f7                     ;store here and leave
             ldy $04                     ;get old contents of Y
             
             ;jsr TheLagMaker               ;if need to lag the game to an unplayable level, uncomment this
             
             lda SprObject_Y_Position,x  ;get vertical coordinate of object
             clc
             adc BlockBuffer_Y_Adder3,y   ;add it to value obtained using Y as offset
             and #%11110000              ;mask out low nybble
             sta $02                     ;store result here
             tay                         ;use as offset for block buffer
             lda ($f7),y                 ;check current content of block buffer
             sta $03                     ;and store here
             ldy $04                     ;get old contents of Y again
             pla                         ;pull A from stack
             bne xc1                      ;if A = 1, branch
             lda SprObject_Y_Position,x  ;if A = 0, load vertical coordinate
             and #%00001111              ;and mask out high nybble
             sta $04                     ;store masked out result here
             ldx $03
             lda MetatileThingy,x
             ldx ObjectOffset          ;get object offset
             cmp #$00                  ;check to see if object bumped into anything
             jmp +
FY5:  jmp ClearBounceFlag
ClearBounceFlag3: jmp ClearBounceFlag
xc1:  lda SprObject_X_Position,x  ;otherwise load horizontal coordinate
             and #%00001111              ;and mask out high nybble
             sta $04                     ;store masked out result here
             
             
             ldx $03
             lda MetatileThingy,x          ;and leave
             ldx ObjectOffset          ;get object offset
             cmp #$00                  ;check to see if object bumped into anything
+:    beq ClearBounceFlag3         ;if nothing underneath fireball, branch
             cmp #$26       ;blank metatile used for vines?
             beq FY5
             cmp #$5f       ;hidden coin block?
             beq FY5
             cmp #$6f
             beq FY5
             cmp #$70
             beq ClearBounceFlag
             cmp #$73
             beq ClearBounceFlag
             cmp #$30
             beq ClearBounceFlag
             cmp #$c5
             beq ClearBounceFlag
             cmp #$91
             beq ClearBounceFlag
             ldy OnOffFlag
             beq +++
             cmp #$8f
             beq ClearBounceFlag
             jmp ++
+++:  cmp #$8e
             beq ClearBounceFlag
++:
             ldy PTimer
             bne ++
             cmp #$72
             beq ClearBounceFlag
             cmp #$c2       ;regular coin?
             beq ClearBounceFlag
             jmp +
++:   cmp #$52
             beq ClearBounceFlag
+:    cmp #$60       ;hidden 1-up block?
             beq ClearBounceFlag         ;branch if any found
             cmp #$74
             beq ClearBounceFlag         ;branch if any found
             cmp #$25
             beq ClearBounceFlag
             cmp #$63
             beq ++
             cmp #$88
             bne +
++:      lda Fireball_Y_Position,x
             and #$0f
             cmp #$0d
             bcs +++
             cmp #$08
             bcs ++
+++:  jmp ClearBounceFlag
+:      
             lda Fireball_Y_Position,x
             cmp #$e0
             bcs ClearBounceFlag
             lda Fireball_Y_Speed,x      ;if fireball's vertical speed set to move upwards,
             bmi InitFireballExplode     ;branch to set exploding bit in fireball's state
             lda FireballBouncingFlag,x  ;if bouncing flag already set,
             bne InitFireballExplode     ;branch to set exploding bit in fireball's state
             jmp +
++:   lda Fireball_Y_Position,x
             cmp #$e0
             bcs ClearBounceFlag
+:      lda #$fd
             sta Fireball_Y_Speed,x      ;otherwise set vertical speed to move upwards (give it bounce)
             lda #$01
             sta FireballBouncingFlag,x  ;set bouncing flag
             lda Fireball_Y_Position,x
             and #$f8                    ;modify vertical coordinate to land it properly
             sta Fireball_Y_Position,x   ;store as new vertical coordinate
NSFn: rts
             ;leave
             
ClearBounceFlag:
             lda #$00
             sta FireballBouncingFlag,x  ;clear bouncing flag by default
             rts                         ;leave
             
InitFireballExplode:
             lda #$80
             sta Fireball_State,x        ;set exploding flag in fireball's state
             lda #Sfx_Bump
             sta Square1SoundQueue       ;load bump sound
             rts                         ;leave
             
BlockBufferChk_Enemy:
             inx
             ;inc PlayerFoot,x
             jmp BBChk_E
             
             
BlockBufferChk_FBall:
             ldy #$1a                  ;set offset for block buffer adder data
             txa
             clc
             adc #$07                  ;add seven bytes to use
             tax
ResJmpM: lda #$00                  ;set A to return vertical coordinate
BBChk_E: pha                         ;save contents of A to stack
             sty $04                     ;save contents of Y here
             lda BlockBuffer_X_Adder,y   ;add horizontal coordinate
             clc                         ;of object to value obtained using Y as offset
             adc SprObject_X_Position,x
             sta $05                     ;store here
             lda SprObject_PageLoc,x     ;of indirect here
             adc #$66
             sta $f8
             ldy $05
             lda MSBtoLSB,y
             sta $f7                     ;store here and leave
             ldy $04                     ;get old contents of Y
             
             ;jsr TheLagMaker               ;if need to lag the game to an unplayable level, uncomment this
             
             lda SprObject_Y_Position,x  ;get vertical coordinate of object
             clc
             adc BlockBuffer_Y_Adder3,y   ;add it to value obtained using Y as offset
             and #%11110000              ;mask out low nybble                  ;subtract 32 pixels for the status bar
             sta $02                     ;store result here
             tay                         ;use as offset for block buffer
             lda ($f7),y                 ;check current content of block buffer
             sta $03                     ;and store here
             ldy $04                     ;get old contents of Y again
             pla                         ;pull A from stack
             bne xc                      ;if A = 1, branch
             lda SprObject_Y_Position,x  ;if A = 0, load vertical coordinate
             and #%00001111              ;and mask out high nybble
             sta $04                     ;store masked out result here
             ldx $03                     ;get saved content of block buffer                       ;and leave
			 ;txa
			 ;tay
             lda MetatileThingy,x
             ldx ObjectOffset            ;get object offset
             cmp #$00
             rts
xc:    lda SprObject_X_Position,x  ;otherwise load horizontal coordinate
             and #%00001111              ;and mask out high nybble
             sta $04                     ;store masked out result here
             ldx $03                     ;get saved content of block buffer                       ;and leave
			 ;txa
			 ;tay
             lda MetatileThingy,x
             ldx ObjectOffset            ;get object offset
             cmp #$00
             rts
             
VineYPosAdder:
             .db $00, $30
             
DrawVine:
             sty $00                    ;save offset here
             lda Enemy_Rel_YPos         ;get relative vertical coordinate
             clc
             adc VineYPosAdder,y        ;add value using offset in Y to get value
             ldx VineObjOffset,y        ;get offset to vine
             ldy Enemy_SprDataOffset,x  ;get sprite data offset
             sty $02                    ;store sprite data offset here
             jsr SixSpriteStacker       ;stack six sprites on top of each other vertically
             lda Enemy_Rel_XPos         ;get relative horizontal coordinate
             sta Sprite_X_Position,y    ;store in first, third and fifth sprites
             sta Sprite_X_Position+8,y
             sta Sprite_X_Position+16,y
             clc
             adc #$06                   ;add six pixels to second, fourth and sixth sprites
             sta Sprite_X_Position+4,y  ;to give characteristic staggered vine shape to
             sta Sprite_X_Position+12,y ;our vertical stack of sprites
             sta Sprite_X_Position+20,y
             lda #%00100001             ;set bg priority and palette attribute bits
             sta Sprite_Attributes,y    ;set in first, third and fifth sprites
             sta Sprite_Attributes+8,y
             sta Sprite_Attributes+16,y
             ora #%01000000             ;additionally, set horizontal flip bit
             sta Sprite_Attributes+4,y  ;for second, fourth and sixth sprites
             sta Sprite_Attributes+12,y
             sta Sprite_Attributes+20,y
             ldx #$05                   ;set tiles for six sprites
VineTL:  lda #$e1                   ;set tile number for sprite
             sta Sprite_Tilenumber,y
             iny                        ;move offset to next sprite data
             iny
             iny
             iny
             dex                        ;move onto next sprite
             bpl VineTL                 ;loop until all sprites are done
             ldy $02                    ;get original offset
             lda $00                    ;get offset to vine adding data
             bne SkpVTop                ;if offset not zero, skip this part
             lda #$e0
             sta Sprite_Tilenumber,y    ;set other tile number for top of vine
SkpVTop: ldx #$00                   ;start with the first sprite again
ChkFTop: lda VineStart_Y_Position   ;get original starting vertical coordinate
             sec
             sbc Sprite_Y_Position,y    ;subtract top-most sprite's Y coordinate
             cmp #$64                   ;if two coordinates are less than 100/$64 pixels
             bcc NextVSp                ;apart, skip this to leave sprite alone
             lda #$f8
             sta Sprite_Y_Position,y    ;otherwise move sprite offscreen
NextVSp: iny                        ;move offset to next OAM data
             iny
             iny
             iny
             inx                        ;move onto next sprite
             cpx #$06                   ;do this until all sprites are checked
             bne ChkFTop
             ldy $00                    ;return offset set earlier
             rts
             
             
DrawHammer:
             ldy Misc_SprDataOffset,x    ;get misc object OAM data offset
             lda TimerControl
             bne ForceHPose              ;if master timer control set, skip this part
             lda Misc_State,x            ;otherwise get hammer's state
             and #%01111111              ;mask out d7
             cmp #$01                    ;check to see if set to 1 yet
             beq GetHPose                ;if so, branch
ForceHPose: ldx #$00                    ;reset offset here
             beq RenderH                 ;do unconditional branch to rendering part
GetHPose:   lda FrameCounter            ;get frame counter
             lsr                         ;move d3-d2 to d1-d0
             lsr
             and #%00000011              ;mask out all but d1-d0 (changes every four frames)
             tax                         ;use as timing offset
RenderH:    lda Misc_Rel_YPos           ;get relative vertical coordinate
             clc
             adc FirstSprYPos,x          ;add first sprite vertical adder based on offset
             sta Sprite_Y_Position,y     ;store as sprite Y coordinate for first sprite
             clc
             adc SecondSprYPos,x         ;add second sprite vertical adder based on offset
             sta Sprite_Y_Position+4,y   ;store as sprite Y coordinate for second sprite
             lda Misc_Rel_XPos           ;get relative horizontal coordinate
             clc
             adc FirstSprXPos,x          ;add first sprite horizontal adder based on offset
             sta Sprite_X_Position,y     ;store as sprite X coordinate for first sprite
             clc
             adc SecondSprXPos,x         ;add second sprite horizontal adder based on offset
             sta Sprite_X_Position+4,y   ;store as sprite X coordinate for second sprite
             lda FirstSprTilenum,x
             sta Sprite_Tilenumber,y     ;get and store tile number of first sprite
             lda SecondSprTilenum,x
             sta Sprite_Tilenumber+4,y   ;get and store tile number of second sprite
             lda HammerSprAttrib,x
             sta Sprite_Attributes,y     ;get and store attribute bytes for both
             sta Sprite_Attributes+4,y   ;note in this case they use the same data
             ldx ObjectOffset            ;get misc object offset
             lda Misc_OffscreenBits
             and #%11111100              ;check offscreen bits
             beq NoHOffscr               ;if all bits clear, leave object alone
             lda #$00
             sta Misc_State,x            ;otherwise nullify misc object state
             lda #$f8
             sta Sprite_Data+4,y         ;and into first row sprites
             sta Sprite_Data,y
NoHOffscr:  rts                         ;leave
             
             
             
FlagpoleGfxHandler:
             ldy Enemy_SprDataOffset,x      ;get sprite data offset for flagpole flag
             lda Enemy_Rel_XPos             ;get relative horizontal coordinate
             sta Sprite_X_Position,y        ;store as X coordinate for first sprite
             clc
             adc #$08                       ;add eight pixels and store
             sta Sprite_X_Position+4,y      ;as X coordinate for second and third sprites
             sta Sprite_X_Position+8,y
             clc
             adc #$0c                       ;add twelve more pixels and
             sta $05                        ;store here to be used later by floatey number
             lda Enemy_Y_Position,x         ;get vertical coordinate
             sta Sprite_Data+4,y            ;and into first row sprites
             sta Sprite_Data,y              ;and do sub to dump into first and second sprites
             adc #$08                       ;add eight pixels
             sta Sprite_Y_Position+8,y      ;and store into third sprite
             lda FlagpoleFNum_Y_Pos         ;get vertical coordinate for floatey number
             sta $02                        ;store it here
             lda #$01
             sta $03                        ;set value for flip which will not be used, and
             sta $04                        ;attribute byte for floatey number
             sta Sprite_Attributes,y        ;set attribute bytes for all three sprites
             sta Sprite_Attributes+4,y
             sta Sprite_Attributes+8,y
             lda #$7e
             sta Sprite_Tilenumber,y        ;put triangle shaped tile
             sta Sprite_Tilenumber+8,y      ;into first and third sprites
             lda #$7f
             sta Sprite_Tilenumber+4,y      ;put skull tile into second sprite
             lda FlagpoleCollisionYPos      ;get vertical coordinate at time of collision
             beq ChkFlagOffscreen           ;if zero, branch ahead
             tya
             clc                            ;add 12 bytes to sprite data offset
             adc #$0c
             tay                            ;put back in Y
             lda FlagpoleScore              ;get offset used to award points for touching flagpole
             asl                            ;multiply by 2 to get proper offset here
             tax
             lda FlagpoleScoreNumTiles,x    ;get appropriate tile data
             sta $00
             lda FlagpoleScoreNumTiles+1,x
             jsr DrawOneSpriteRow           ;use it to render floatey number
             
ChkFlagOffscreen:
             ldx ObjectOffset               ;get object offset for flag
             ldy Enemy_SprDataOffset,x      ;get OAM data offset
             lda Enemy_OffscreenBits        ;get offscreen bits
             and #%00001110                 ;mask out all but d3-d1
             beq ExitDumpSpr                ;if none of these bits set, branch to leave
             
             
MoveSixSpritesOffscreen:
             lda #$f8                  ;set offscreen coordinate if jumping here
             
DumpSixSpr:
             sta Sprite_Data+20,y      ;dump A contents
             sta Sprite_Data+16,y      ;into third row sprites
             
DumpFourSpr:
             sta Sprite_Data+12,y      ;into second row sprites
             
DumpThreeSpr:
             sta Sprite_Data+8,y
             
DumpTwoSpr:
             sta Sprite_Data+4,y       ;and into first row sprites
             sta Sprite_Data,y
             
ExitDumpSpr:
             rts
             
             
DrawLargePlatform:
             ldy Enemy_SprDataOffset,x   ;get OAM data offset
             sty $02                     ;store here
             iny                         ;add 3 to it for offset
             iny                         ;to X coordinate
             iny
             lda Enemy_Rel_XPos          ;get horizontal relative coordinate
             jsr SixSpriteStacker        ;store X coordinates using A as base, stack horizontally
             ldx ObjectOffset
             lda Enemy_Y_Position,x      ;get vertical coordinate
             jsr DumpFourSpr             ;dump into first four sprites as Y coordinate
             ldy AreaType
             cpy #$03                    ;check for castle-type level
             beq ShrinkPlatform
             ldy SecondaryHardMode       ;check for secondary hard mode flag set
             beq SetLast2Platform        ;branch if not set elsewhere
             
ShrinkPlatform:
             lda #$f8                    ;load offscreen coordinate if flag set or castle-type level
             
SetLast2Platform:
             ldy Enemy_SprDataOffset,x   ;get OAM data offset
             sta Sprite_Y_Position+16,y  ;store vertical coordinate or offscreen
             sta Sprite_Y_Position+20,y  ;coordinate into last two sprites as Y coordinate
             lda #$eb                    ;load default tile for platform (girder)
             ldx CloudTypeOverride
             beq SetPlatformTilenum      ;if cloud level override flag not set, use
             lda #$eb                    ;otherwise load other tile for platform (puff)
             
SetPlatformTilenum:
             ldx ObjectOffset            ;get enemy object buffer offset
             iny                         ;increment Y for tile offset
             jsr DumpSixSpr              ;dump tile number into all six sprites
             lda #$02                    ;set palette controls
             iny                         ;increment Y for sprite attributes
             jsr DumpSixSpr              ;dump attributes into all six sprites
             inx                         ;increment X for enemy objects
             jsr GetXOffscreenBits       ;get offscreen bits again
             dex
             ldy Enemy_SprDataOffset,x   ;get OAM data offset
             asl                         ;rotate d7 into carry, save remaining
             pha                         ;bits to the stack
             bcc SChk2
             lda #$f8                    ;if d7 was set, move first sprite offscreen
             sta Sprite_Y_Position,y
SChk2:  pla                         ;get bits from stack
             asl                         ;rotate d6 into carry
             pha                         ;save to stack
             bcc SChk3
             lda #$f8                    ;if d6 was set, move second sprite offscreen
             sta Sprite_Y_Position+4,y
SChk3:  pla                         ;get bits from stack
             asl                         ;rotate d5 into carry
             pha                         ;save to stack
             bcc SChk4
             lda #$f8                    ;if d5 was set, move third sprite offscreen
             sta Sprite_Y_Position+8,y
SChk4:  pla                         ;get bits from stack
             asl                         ;rotate d4 into carry
             pha                         ;save to stack
             bcc SChk5
             lda #$f8                    ;if d4 was set, move fourth sprite offscreen
             sta Sprite_Y_Position+12,y
SChk5:  pla                         ;get bits from stack
             asl                         ;rotate d3 into carry
             pha                         ;save to stack
             bcc SChk6
             lda #$f8                    ;if d3 was set, move fifth sprite offscreen
             sta Sprite_Y_Position+16,y
SChk6:  pla                         ;get bits from stack
             asl                         ;rotate d2 into carry
             bcc SLChk                   ;save to stack
             lda #$f8
             sta Sprite_Y_Position+20,y  ;if d2 was set, move sixth sprite offscreen
SLChk:  lda Enemy_OffscreenBits     ;check d7 of offscreen bits
             asl                         ;and if d7 is not set, skip sub
             bcc ExDLPl
             jmp MoveSixSpritesOffscreen ;otherwise branch to move all sprites offscreen
ExDLPl: rts
             
             
             
             
             ;leave
             
MovePlayerVertically:
             ldx #$00                ;set X for player offset
             lda TimerControl
             bne NoJSChk             ;if master timer control set, branch ahead
             ;lda JumpspringAnimCtrl  ;otherwise check to see if jumpspring is animating
             ;bne +                   ;branch to leave if so
NoJSChk: lda VerticalForce       ;dump vertical force 
             sta $00
             lda #$04                ;set maximum vertical speed here
             jmp ImposeGravitySprObj ;then jump to move player vertically
MoveEnemyHorizontally:
             inx                         ;increment offset for enemy offset
             jmp MoveObjectHorizontally1  ;position object horizontally according to
             
SignDoStuff:
             lda SavedJoypad1Bits
             and #Up_Dir
             beq +
             lda PreviousUp_Down_Buttons
             and #Up_Dir
             ora Player_Y_Speed
             ora ClearRemainings
             bne +
             lda $7fce,x
             sta TextboxID
             inc clearVRAM
+:      rts
             
             
             
InitBlock_XY_Pos:
             lda Player_X_Position   ;get player's horizontal coordinate
             clc
             adc #$08                ;add eight pixels
             and #$f0                ;mask out low nybble to give 16-pixel correspondence
             sta Block_X_Position,x  ;save as horizontal coordinate for block object
             lda Player_PageLoc
             adc #$00                ;add carry to page location of player
             sta Block_PageLoc,x     ;save as page location of block object
             sta Block_PageLoc2,x    ;save elsewhere to be used later
             lda Player_Y_HighPos
             sta Block_Y_HighPos,x   ;save vertical high byte of player into
             rts                     ;vertical high byte of block object and leave
DrawEnemyObjRow:
             lda EnemyGraphicsTable,x    ;load two tiles of enemy graphics
             sta $00
             lda EnemyGraphicsTable+1,x
             
DrawOneSpriteRow:
             sta $01
             if BLANK_SPRITE_MOD
             jsr DrawSpriteObject        ;draw them
             
             lda $00
             cmp #$fc                    ; first sprite is not blank, branch
             bne +
             cmp $01                     ; second sprite is not blank, branch
             bne +
             
             cpy #$00
             beq +
             
             lda #$f8                    ; move the (blank) sprites offscreen
             sta Sprite_Data+4-8,y
             sta Sprite_Data-8,y
             +
             else
             jmp DrawSpriteObject        ;draw them
             endif
             rts
DrawSpriteObject:
             lda $03                    ;get saved flip control bits
             lsr
             lsr                        ;move d1 into carry
             lda $00
             bcc NoHFlip                ;if d1 not set, branch
             sta Sprite_Tilenumber+4,y  ;store first tile into second sprite
             lda $01                    ;and second into first sprite
             sta Sprite_Tilenumber,y
             lda #$40                   ;activate horizontal flip OAM attribute
             bne SetHFAt                ;and unconditionally branch
NoHFlip: sta Sprite_Tilenumber,y    ;store first tile into first sprite
             lda $01                    ;and second into second sprite
             sta Sprite_Tilenumber+4,y
             lda #$00                   ;clear bit for horizontal flip
SetHFAt: ora $04                    ;add other OAM attributes if necessary
             sta Sprite_Attributes,y    ;store sprite attributes
             sta Sprite_Attributes+4,y
             lda $02                    ;now the y coordinates
             sta Sprite_Y_Position,y    ;note because they are
             sta Sprite_Y_Position+4,y  ;side by side, they are the same
             lda $05       
             sta Sprite_X_Position,y    ;store x coordinate, then
             clc                        ;add 8 pixels and store another to
             adc #$08                   ;put them side by side
             sta Sprite_X_Position+4,y
             lda $02                    ;add eight pixels to the next y
             clc                        ;coordinate
             adc #$08
             sta $02
             tya                        ;add eight to the offset in Y to
             clc                        ;move to the next two sprites
             adc #$08
             tay
             inx                        ;increment offset to return it to the
             inx                        ;routine that called this subroutine
             rts
DefaultBlockObjTiles:
             .db $85, $85, $86, $86, $6e             ;brick w/ line (these are sprite tiles, not BG!)
             
DrawBlock:
             lda Block_Rel_YPos            ;get relative vertical coordinate of block object
             sta $02                       ;store here
             lda Block_Rel_XPos            ;get relative horizontal coordinate of block object
             sta $05                       ;store here
             lda #$03
             sta $04                       ;set attribute byte here
             lsr
             sta $03                       ;set horizontal flip bit here (will not be used)
             ldy Block_SprDataOffset,x     ;get sprite data offset
             ldx #$00                      ;reset X for use as offset to tile data
DBlkLoop:  lda DefaultBlockObjTiles,x    ;get left tile number
             sta $00                       ;set here
             lda DefaultBlockObjTiles+1,x  ;get right tile number
             jsr DrawOneSpriteRow          ;do sub to write tile numbers to first row of sprites
             cpx #$04                      ;check incremented offset
             bne DBlkLoop                  ;and loop back until all four sprites are done
             ldx ObjectOffset              ;get block object offset
             ldy Block_SprDataOffset,x     ;get sprite data offset
             lda AreaType
             cmp #$01                      ;check for ground level type area
             beq ChkRep                    ;if found, branch to next part
             lda #$86
             sta Sprite_Tilenumber,y       ;otherwise remove brick tiles with lines
             sta Sprite_Tilenumber+4,y     ;and replace then with lineless brick tiles
ChkRep:    ;lda Cbolla,x
             ;bne +
             lda Block_Metatile,x          ;check replacement metatile
             cmp #$74
             beq +
             cmp #$c4                      ;if not used block metatile, then
             bne BlkOffscr                 ;branch ahead to use current graphics
+:         lda #$87                      ;set A for used block tile
             iny                           ;increment Y to write to tile bytes
             sta Sprite_Data+12,y          ;into second row sprites
             sta Sprite_Data+8,y
             sta Sprite_Data+4,y           ;and into first row sprites
             sta Sprite_Data,y
             dey                           ;return Y to original offset
             lda #$03                      ;set palette bits
             ldx AreaType
             dex                           ;check for ground level type area again
             beq SetBFlip                  ;if found, use current palette bits
             lsr                           ;otherwise set to $01
SetBFlip:  ldx ObjectOffset              ;put block object offset back in X
             sta Sprite_Attributes,y       ;store attribute byte as-is in first sprite
             ora #%01000000
             sta Sprite_Attributes+4,y     ;set horizontal flip bit for second sprite
             ora #%10000000
             sta Sprite_Attributes+12,y    ;set both flip bits for fourth sprite
             and #%10000011
             sta Sprite_Attributes+8,y     ;set vertical flip bit for third sprite
BlkOffscr: lda Block_OffscreenBits       ;get offscreen bits for block object
             pha                           ;save to stack
             and #%00000100                ;check to see if d2 in offscreen bits are set
             beq PullOfsB                  ;if not set, branch, otherwise move sprites offscreen
             lda #$f8                      ;move offscreen two OAMs
             sta Sprite_Y_Position+4,y     ;on the right side
             sta Sprite_Y_Position+12,y
PullOfsB:  pla                           ;pull offscreen bits from stack
ChkLeftCo: and #%00001000                ;check to see if d3 in offscreen bits are set
             beq ExDBlk                    ;if not set, branch, otherwise move sprites offscreen
             
MoveColOffscreen:
             lda #$f8                   ;move offscreen two OAMs
             sta Sprite_Y_Position,y    ;on the left side (or two rows of enemy on either side
             sta Sprite_Y_Position+8,y  ;if branched here from enemy graphics handler)
ExDBlk: rts
             
             
             
             
Parallax:
             .db %000001100, %000001100, %000001100, %000010100, %000010100, %000010100, %000011100, %000011100, %000011100, %000100100, %000100100, %000100100    ;underground
             .db %000101100, %000101100, %000101100, %000110100, %000110100, %000110100, %000111100, %000111100, %000111100, %001001100, %001001100, %001001100    ;castle
ResetOffsetParallax:
             lda #$00
             sta ParallaxOffset        ;reset parallax and continue
MakeParallax:
             lda ParallaxOffset
             cmp #$18
             bcs ResetOffsetParallax
             tax
             lda WorldNumber
             cmp #$04
             bne +
             lda AreaNumber
             cmp #$03
             bne +
             lda #$01
             bne ++
             
+:               
             lda AreaType
             cmp #$02    
             bcc ++                    ;branch if AreaType not underground or castle
             tay
             lda Parallax,x
             cpy #$03
             bne +++
             ora #%10000000        
             clc
             adc #%00001000            ;do parallax
+++:    tay
             lda #$82
             sta Old8000
             sta $8000
             tya
             
             sta $8001
             rts
++:        tay
             lda OperMode_Task
             cmp #$01
             bne +
             tay
+:        lda #$82                ;set no-parallax CHR
             sta Old8000
             sta $8000
             lda AreaParallax,y
             sta $8001
             
             lda #$83
             sta Old8000
             sta $8000
             lda LastCHR3
             sta $8001
             
             rts
             
SprObjectOffscrChk:
             ldx ObjectOffset          ;get enemy buffer offset
             lda Enemy_OffscreenBits   ;check offscreen information
             lsr
             lsr                       ;shift three times to the right
             lsr                       ;which puts d2 into carry
             pha                       ;save to stack
             bcc LcChk                 ;branch if not set
             lda #$04                  ;set for right column sprites
             clc                         ;add A to enemy object OAM data offset
             adc Enemy_SprDataOffset,x
             tay                         ;use as offset
             lda #$f8                   ;move offscreen two OAMs
             sta Sprite_Y_Position,y    ;on the left side (or two rows of enemy on either side
             sta Sprite_Y_Position+8,y  ;if branched here from enemy graphics handler)
             sta Sprite_Data+16,y        ;move third row sprite in column offscreen
LcChk:   pla                       ;get from stack
             lsr                       ;move d3 to carry
             pha                       ;save to stack
             bcc Row3C                 ;branch if not set
             lda #$00                  ;set for left column sprites,
             clc                         ;add A to enemy object OAM data offset
             adc Enemy_SprDataOffset,x
             tay                         ;use as offset
             lda #$f8                   ;move offscreen two OAMs
             sta Sprite_Y_Position,y    ;on the left side (or two rows of enemy on either side
             sta Sprite_Y_Position+8,y  ;if branched here from enemy graphics handler)
             sta Sprite_Data+16,y        ;move third row sprite in column offscreen
Row3C:   pla                       ;get from stack again
             lsr                       ;move d5 to carry this time
             lsr
             pha                       ;save to stack again
             bcc Row23C                ;branch if carry not set
             lda #$10                  ;set for third row of sprites
             clc                         ;add A to enemy object OAM data offset
             adc Enemy_SprDataOffset,x
             tay                         ;use as offset
             lda #$f8
             sta Sprite_Data+4,y       ;and into first row sprites
             sta Sprite_Data,y
Row23C:  pla                       ;get from stack
             lsr                       ;move d6 into carry
             pha                       ;save to stack
             bcc AllRowC
             lda #$08                  ;set for second and third rows
             clc                         ;add A to enemy object OAM data offset
             adc Enemy_SprDataOffset,x
             tay                         ;use as offset
             lda #$f8
             sta Sprite_Data+4,y       ;and into first row sprites
             sta Sprite_Data,y
AllRowC: pla                       ;get from stack once more
             lsr                       ;move d7 into carry
             bcc ExEGHandler
             clc                         ;add A to enemy object OAM data offset
             adc Enemy_SprDataOffset,x
             tay                         ;use as offset
             lda #$f8
             sta Sprite_Data+4,y       ;and into first row sprites
             sta Sprite_Data,y
             lda Enemy_ID,x
             cmp #Podoboo              ;check enemy identifier for podoboo
             bne +           ;skip this part if found, we do not want to erase podoboo!
             lda Enemy_State,x
             cmp #$22
             bne ExEGHandler
+:       lda Enemy_Y_HighPos,x     ;check high byte of vertical position
             cmp #$02                  ;if not yet past the bottom of the screen, branch
             bne ExEGHandler
             ldy SavedOffset,x
             lda Saved_isDefeated,y
             cmp #$02
             beq +
             lda #$00
             sta Saved_isDefeated,y
             +        jmp EraseEnemyObject      ;what it says
ExEGHandler:
             rts
             
AreaParallax:
             .db %11011100, %00000100 
             
WorldPaletteLUT:
             .db $00, $00, $00, $01, $00, $02, $03, $04, $00, $ff
             
             
CheckForCoinMTiles:
             ldx PTimer
             cpx #$00
             bne +
             cmp #$c2              ;check for regular coin
             beq CoinSd            ;branch if found
             clc                   ;otherwise clear carry and leave
CoinSd:  rts
+:
             cmp #$51
             beq CoinSd
             cmp #$52
             beq CoinSd
             cmp #$28
             beq CoinSd
             cmp #$27
             beq CoinSd
             clc
             
             rts      
             
             
             
SmallPlatformCollision:
             lda TimerControl             ;if master timer control set,
             bne ExSPC                    ;branch to leave
             sta PlatformCollisionFlag,x  ;otherwise initialize collision flag
             jsr CheckPlayerVertical      ;do a sub to see if player is below a certain point
             bcs ExSPC                    ;or entirely offscreen, and branch to leave if true
             lda #$02
             sta $00                      ;load counter here for 2 bounding boxes
             
ChkSmallPlatLoop:
             ldx ObjectOffset           ;get enemy object offset
             lda ObjectOffset         ;get enemy object buffer offset
             asl                          ;multiply A by four, then add four
             asl                          ;to skip player's bounding box
             clc
             adc #$04
             tay                          ;send to Y
             lda Enemy_OffscreenBits      ;get offscreen bits for enemy object
             and #%00001111               ;save low nybble
             cmp #%00001111               ;check for all bits set
             and #%00000010             ;if d1 of offscreen lower nybble bits was set
             bne ExSPC                  ;then branch to leave
             lda BoundingBox_UL_YPos,y  ;check top of platform's bounding box for being
             cmp #$20                   ;above a specific point
             bcc MoveBoundBox           ;if so, branch, don't do collision detection
             jsr PlayerCollisionCore    ;otherwise, perform player-to-platform collision detection
             bcs ProcSPlatCollisions    ;skip ahead if collision
             
MoveBoundBox:
             lda BoundingBox_UL_YPos,y  ;move bounding box vertical coordinates
             clc                        ;128 pixels downwards
             adc #$80
             sta BoundingBox_UL_YPos,y
             lda BoundingBox_DR_YPos,y
             clc
             adc #$80
             sta BoundingBox_DR_YPos,y
             dec $00                    ;decrement counter we set earlier
             bne ChkSmallPlatLoop       ;loop back until both bounding boxes are checked
ExSPC: ldx ObjectOffset           ;get enemy object buffer offset, then leave
             rts
             
             
ProcSPlatCollisions:
             ldx ObjectOffset             ;return enemy object buffer offset to X, then continue
             jmp ProcLPlatCollisions
             
             
                          
FirebarMirrorData:
             .db $01, $03, $02, $00
             
FirebarTblOffsets:
             .db $00, $09, $12, $1b, $24, $2d
             .db $36, $3f, $48, $51, $5a, $63
             
FirebarYPos:
             .db $0c, $18
             
BowserHPDisplay:
			stx temp7
             ldx VRAM_Buffer1_Offset
             lda #$22
             sta VRAM_Buffer1,x
             lda #$c0
             sta VRAM_Buffer1+1,x
             lda #$05
             sta VRAM_Buffer1+2,x
             lda #$11
             sta VRAM_Buffer1+3,x
             lda #$19
             sta VRAM_Buffer1+4,x
             lda #$28
             sta VRAM_Buffer1+5,x
             lda #$00
             sta VRAM_Buffer1+6,x
             lda BowserHitPoints       ;otherwise, check number of pts
             tay
             +
             cmp #10                   ;more than 9 pts?
             bcc ++
             sbc #10                   ;if so, subtract 10 and add one to the 10s digit
             tay
             lda #$01                  ;instead of showing 100 pts, A0 will show, etc.
             sta VRAM_Buffer1+6,x
             tya
             -
             cmp #10
             bcc ++
             sbc #10
             inc VRAM_Buffer1+6,x
             jmp -
             tay
             sta VRAM_Buffer1+6,x
             tya
++:          
             sta VRAM_Buffer1+7,x
             lda #$00
             sta VRAM_Buffer1+8,x
             txa
             clc
             adc #$08
             sta VRAM_Buffer1_Offset
             ldx temp7
			 rts
             
             
             
JumpEngineOthersTemp:
             ldy $f6
             sty $609b
             ldy $f7
             sty $609c
             ldy $f8
             sty $609d
             ldy $f9
             sty $609e
             asl          ;shift bit from contents of A
             tay
             pla          ;pull saved return address from stack
             sta $f6      ;save to indirect
             pla
             sta $f7
             iny
             lda ($f6),y  ;load pointer from indirect
             sta $f8      ;note that if an RTS is performed in next routine
             iny          ;it will return to the execution before the sub
             lda ($f6),y  ;that called this routine
             sta $f9
             jmp ($f8)    ;jump to the address we loaded
             
JumpEngine:
             asl          ;shift bit from contents of A
             tay
             pla          ;pull saved return address from stack
             sta $04      ;save to indirect
             pla
             sta $05
             iny
             lda ($04),y  ;load pointer from indirect
             sta $06      ;note that if an RTS is performed in next routine
             iny          ;it will return to the execution before the sub
             lda ($04),y  ;that called this routine
             sta $07
             jmp ($06)    ;jump to the address we loaded
Reset:
             ; $FFFC-$FFFD reset vector new location, & bankswap to $4058 to load MMC3's setups
             sei
             cld
             lda #$01
             jsr BankSwap
             jsr MMC3Setup
             
             jsr RestoreBank
             jmp Start
RunPauseMenu:
             lda #$01
             jsr BankSwap
             jsr PauseMenu
             jmp RestoreBank
RunStuff:
             lda #$01
             jsr BankSwap
             jsr ChangeBankRunner
             jmp RestoreBank
             
MoveSpritesOffscreen:
             lda #$01
             jsr BankSwap
             jsr MoveSpritesOffscreen1
             jmp RestoreBank
_GetAreaMusic:
             jsr RestoreBank
             jsr GetAreaMusic
             lda #$01
             jmp BankSwap
             
             
LoadAreaPointer:
             lda #$04
             jsr BankSwap
             jsr LoadAreaPointerR
             jmp RestoreBank
             
InitPodoboo2:
             lda #$04
             jsr BankSwap
             jsr InitPodoboo
             jmp RestoreBank
             
GetAreaDataAddrs:
             lda #$04
             jsr BankSwap
             jsr GetAreaDataAddrsR
             jmp RestoreBank
             
AreaParserTaskHandler1:
             lda #$04
             jsr BankSwap
             jsr AreaParserTaskHandler
             jmp RestoreBank
             
ProcLoopCommand1:
             lda #$04
             jsr BankSwap
             jsr ProcLoopCommand
             jmp RestoreBank
             
InitEnemyRoutines1:
             lda #$04
             jsr BankSwap
             lda Enemy_ID,x
             jsr InitEnemyRoutines
             lda #$01
             jmp BankSwap
             
SetupTextbox1:
             lda #$01
             jsr BankSwap
             jsr SetupTextbox
             jmp RestoreBank    
             
EnemyGfxHandler:
             lda #$01
             jsr BankSwap
             jsr EnemyGfxHandler1
             jmp RestoreBank    
             
             
GameOverMenu1:
             lda #$01
             jsr BankSwap
             jsr GameOverMenu
             jmp RestoreBank
             
RestoreBank:
             ; restores $10-$4000 rom, back to $8000-$BFFF ram (4CAAF2)
             lda #$00
             jmp BankSwap
             
             
             RestoreBank1
             ; restores $10-$4000 rom, back to $8000-$BFFF ram (4CAAF2)
             lda #$00
             jsr BankSwap
             ldx $03                     ;get saved content of block buffer
             lda MetatileThingy,x
             rts
             
BankSwapCore:
             lda #BANK_CORE
             ; continue to BankSwap
             
BankSwap:
             ;bankswap routine (A9## 20B0F2)
             sta currentBank
Ostia3:    pha
             asl
             pha
             lda #$86
             sta Old8000
             sta $8000
             pla
             
             sta $8001
             ora #$01
             cmp #$09
             bne +
             lda LevelBank
             clc
             adc #FirstLevelBank
+:      pha
             lda #$87
             sta Old8000
             sta $8000
             pla
             
             sta $8001
             pla
             rts
             
             
StatusBarData:
             .db $f0, $06 ; top score display on title screen
             .db $63, $06 ; player score
             .db $63, $06
             .db $6d, $04 ; coin tally
             .db $6d, $04
             .db $7a, $03 ; game timer
             .db $4f, $02
             
StatusBarOffset:
             .db $06, $0c, $12, $18, $1e, $24, $26
             
             
InitializeMemory:
             jmp _InitializeMemory
             
ReadJoypads:
             jsr BankSwapCore
             jsr _ReadJoypads
             jmp RestoreBank
             
InitializeNameTables:
             jsr BankSwapCore
             jsr _InitializeNameTables
             jmp RestoreBank
             
             ;       jsr BankSwapCore
             ;       jsr _DemoEngine
             ;       jmp RestoreBank
             
             
LoadPlayerData:
             ;jsr BankSwapCore
             ;jsr _LoadPlayerData
             ;jmp RestoreBank
SavePlayerData:
             ;jsr BankSwapCore
             ;jsr _SavePlayerData
             ;jmp RestoreBank
WipePlayerData:
             ;jsr BankSwapCore
             ;jsr _WipePlayerData
             ;jmp RestoreBank
             
CopyToAllPlayers:
             rts
             ;tay
             ;jsr BankSwapCore
             ;jsr _CopyToAllPlayers
             ;jmp RestoreBank
             ;jsr BankSwapCore
             ;       jmp _ProcessWhirlpools
             ;rts
             ;jmp RestoreBank
             ;jmp ImposeGravity           ;jump to put whirlpool effect on player vertically, do not return
             
             
handleSound:
             lda #BANK_SOUND
             jsr Ostia3
             jsr SoundEngine
             lda currentBank
             jmp BankSwap
             
             
RNG:
             ldx #$00
             ldy #$07
             lda PseudoRandomBitReg    ;get first memory location of LSFR bytes
             and #%00000010            ;mask out all but d1
             sta $00                   ;save here
             lda PseudoRandomBitReg+1  ;get second memory location
             and #%00000010            ;mask out all but d1
             eor $00                   ;perform exclusive-OR on d1 from first and second bytes
             clc                       ;if neither or both are set, carry will be clear
             beq RotPRandomBit
             sec                       ;if one or the other is set, carry will be set
RotPRandomBit: ror PseudoRandomBitReg,x  ;rotate carry into d7, and rotate last bit into carry
             lda SavedJoypadBits
             beq +
             ror PseudoRandomBitReg,x
+:        
             inx                       ;increment to next byte
             dey                       ;decrement for loop
             bne RotPRandomBit
             rts
             
             
RNG_call:
             lda seed+1
             tay             ;store copy of high byte
             ; compute seed+1 ($39>>1 = %11100)
             lsr             ;shift to consume zeroes on left...
             lsr
             lsr
             sta seed+1         ;now recreate the remaining bits in reverse order... %111
             lsr
             eor seed+1
             lsr
             eor seed+1
             eor seed+0         ;recombine with original low byte
             sta seed+1
             ; compute seed+0 ($39 = %111001)
             tya             ;original high byte
             sta seed+0
             asl
             eor seed+0
             asl
             eor seed+0
             asl
             asl
             asl
             eor seed+0
             sta seed+0
             rts
NoHeadColl:
		.db $29, $2a, $2b, $30, $38, $39, $3a, $3b, $5f, $60, $6f, $73, $92, $88, $91, $26, $63, $25
CheckBlockWhenCrouching:
			 lda GameEngineSubroutine
			 cmp #$08
			 bne ExitBlockhead
			 lda PlayerSize
			 ora Player_State
			 bne ExitBlockhead 
			 ldy #$27
			 jsr BlockBufferColli_Head ;do player-to-bg collision detection on other half of player
			 beq ExitBlockhead
			 ldy #CheckBlockWhenCrouching-NoHeadColl
-:			 cmp NoHeadColl,y
			 beq ExitBlockhead
			 dey
			 bne -
			 
			 ldy PTimer
			 beq +
			 cmp #$52
			 beq ExitBlockhead
			 bne ++
+:			 cmp #$c2
			 beq ExitBlockhead
			 cmp #$72
			 beq ExitBlockhead
++:			 
			 ldy OnOffFlag
			 beq +
			 cmp #$8f
			 beq ExitBlockhead
			 bne ++
+:			 cmp #$8e
			 beq ExitBlockhead
++:			 
			 lda #$01
			 sta CrouchingFlag
			 lsr 
			 ldy Left_Right_Buttons
			 beq +
			 sty PlayerFacingDir
+:			 sta Left_Right_Buttons

			 lda SavedJoypadBits
			 and #A_Button
			 beq +
			 lda Player_X_Speed
			 cmp #CrouchJumpSpd
			 bcc ++
			 cmp #CrouchJumpSpd+1
			 bcc +
++			 ldy PlayerFacingDir
			 dey
			 lda CrouchJumpSpd,y
			 sta Player_X_Speed
		     
+:		     lda SavedJoypadBits
			 and #%11111100
			 sta SavedJoypadBits				
ExitBlockhead:			 
			 rts
			 
SaveGame:
			 ldy #$06
-:           lda PlayerScoreDisplay,y
             sta ContinueScore,y
             dey
             bpl -
             
             ldy #$03
-:           lda PlayerCoinDisplay,y
             sta ContinueCoins,y
             dey
             bpl -
             lda PlayerStatus
             sta ContinuePwrup
             lda CoinTally
             sta ContinueCoinTally
			 rts
			 
FirebarPosLookupTbl:
             .db $00, $01, $03, $04, $05, $06, $07, $07, $08
             .db $00, $03, $06, $09, $0b, $0d, $0e, $0f, $10
             .db $00, $04, $09, $0d, $10, $13, $16, $17, $18
             .db $00, $06, $0c, $12, $16, $1a, $1d, $1f, $20
             .db $00, $07, $0f, $16, $1c, $21, $25, $27, $28
             .db $00, $09, $12, $1b, $21, $27, $2c, $2f, $30
             .db $00, $0b, $15, $1f, $27, $2e, $33, $37, $38
             .db $00, $0c, $18, $24, $2d, $35, $3b, $3e, $40
             .db $00, $0e, $1b, $28, $32, $3b, $42, $46, $48
             .db $00, $0f, $1f, $2d, $38, $42, $4a, $4e, $50
             .db $00, $11, $22, $31, $3e, $49, $51, $56, $58
CrouchJumpSpd:
		   .db $04, $fc
             
FlagpoleScoreNumTiles:
             .db $fd, $fe
             .db $f7, $50
             .db $fa, $fb
             .db $f8, $fb
             .db $f6, $fb
             
ExplosionTiles:
             .db $68, $67, $66
             
             
PlayerStarting_X_Pos:
             .db $28, $18
             .db $38, $28
             
AltYPosOffset:
             .db $08, $00
             
PlayerStarting_Y_Pos:
             .db $00, $20, $b0, $50, $00, $00, $b0, $b0
             .db $f0
             
PlayerBGPriorityData:
             .db $00, $20, $00, $00, $00, $00, $00, $00
             

             .db $20 ;dummy byte, used as part of bg priority data
GameTimerData:
             .db $09, $03, $03, $02
GameTimerSec:
             .db $00, $05, $00, $05
ForceThing:
             .db $0a, $70, $70, $70        
             
LevelSelectAreasOffsets:
             .db $00, $02, $03, $04
             .db $00, $02, $03, $04
             .db $00, $01, $02, $03
             .db $00, $01, $02, $03
             .db $00, $01, $02, $03
             .db $00, $01, $02, $03
             .db $00, $02, $03, $04
             .db $00, $01, $02, $03
             .db $00, $01, $02, $03
			 .db $00, $01, $02, $03
             include code\irq.asm
             include code\writebuffer.asm
             
             .dw Vectors-$ ; This is just here to show how much free space is in this spot in the list file.
             .pad $fffa, $ff
Vectors:
             .dw NonMaskableInterrupt
             .dw Reset
             .dw IRQ
             ;.dw $fff0  ;unused
             ;.dw Reset
             
             .incbin "data\smb_new.chr"                 ;%00000100
             .incbin "data\smb_new2.chr"                ;%00001100
             .incbin "data\smb_new3.chr"                ;%00010100
             .incbin "data\smb_new4.chr"                ;%00011100
             
             .incbin "data\smb_new5.chr"                ;%00100100
             .incbin "data\smb_new6.chr"                ;%00101100
             .incbin "data\smb_new7.chr"                ;%00110100
             .incbin "data\smb_new8.chr"                ;%00111100
             
             
             .incbin "data\smb_new9.chr"                ;%01000100
             .incbin "data\smb_newA.chr"                ;%01001100
             .incbin "data\smb_newB.chr"                ;%01010100
             .incbin "data\smb_newC.chr"                ;%01011100
             
             .incbin "data\smb_newD.chr"                ;%01100100
             .incbin "data\smb_newE.chr"                ;%01101100
             .incbin "data\smb_newF.chr"                ;%01110100
             .incbin "data\smb_newG.chr"                ;%01111100
             
             
             .incbin "data\smb_newPSwitch.chr"        ;%10000100
             .incbin "data\titleScreen.chr"            ;%10001100
             .incbin "data\castlepar1.chr"            ;%10010100
             .incbin "data\castlepar2.chr"            ;%10011100
             
             .incbin "data\castlepar3.chr"             ;%10100100
             .incbin "data\castlepar4.chr"             ;%10101100
             .incbin "data\castlepar5.chr"             ;%10110100
             .incbin "data\castlepar6.chr"             ;%10111100
             
             
             .incbin "data\castlepar7.chr"             ;%11000100
             .incbin "data\smb_newPSwitchonblock.chr";%11001100
             .incbin "data\castlepar8.chr"             ;%11010100
             .incbin "data\smb_new9a.chr"             ;%11011100
             
             
             .incbin "data\castlepar7.chr"             ;%11000100
             .incbin "data\smb_newPSwitchonblock.chr";%11001100
             .incbin "data\castlepar8.chr"             ;%11010100
             .incbin "data\smb_new9a.chr"             ;%11011100
             
