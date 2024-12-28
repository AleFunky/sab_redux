IRQ:
             ;sei
             pha
             ;lda $00
             ;pha
             txa
             pha
             tya
             pha
             
             lda #$01
             sta $e000
             lda IRQnum
             bne SecondIRQ
             lda SetupPause
             beq +
             
             lda Mirror_PPU_CTRL_REG1
             and #%11101110
             ora #%00000010
             sta Mirror_PPU_CTRL_REG1
             sta PPU_CTRL_REG1
             
             lda PPU_STATUS
             
             lda SetupPause
             cmp #$04
             bcc +
             
             lda #$00
             sta PPU_SCROLL_REG
             sta PPU_SCROLL_REG
             
             jmp Exitante
-:    sta IRQAckFlag
             jmp EndIRQ
ThirdIRQ_:
             jmp ThirdIRQ
             
+:    
             lda Mirror_PPU_CTRL_REG1
             and #%11101100
             ora OldNameTableSelect    
             sta Mirror_PPU_CTRL_REG1
             sta PPU_CTRL_REG1
             
             lda OldTextboxID
             ora TextboxID
             beq +
             lda AreaType
             beq +
             lda #$83
             sta $8000
             lda #$05
             sta $8001
             lda PPU_STATUS
+:
             
             lda OldHorizontalScroll
             sta PPU_SCROLL_REG
             
             lda #$00
Exitante:
             sta PPU_SCROLL_REG         
             
             lda StartedTextBox
             beq -
             lda #$95
             sta $c000
             sta $c001
             sta $e001
             
             inc IRQnum
             jmp EndIRQ
SecondIRQ:
             cmp #$02
             bcs ThirdIRQ_
             
             ldx #15            ;delay HBLANK
             -            
             dex        
             bpl -              ;7 cycles per loop
             
             nop
             nop
             nop
             nop
             nop
             
             
             ldx #13            ;delay HBLANK
             -
             dex
             bpl -
             lda #$00
             sta $2001
             lda #$08
             ldx #$3f
             ldy #$17
             
             
             stx $2006
             sta $2006
             nop
             nop
             nop
             ldx #$0f
             lda #$30
             
             
             Y_Scroll = #$00
             
             ;HBLANK starts here
             bit $2007
             sta $2007
             sty $2007
             stx $2007
             
             lda #%00001100
             and #%00001100
             ldx #Y_Scroll
             sta $2006
             stx $2005
             stx $2005                ;x doesnt matter
             lda #(#Y_Scroll & #$F8) << 2
             sta $2006
             
             lda $0101
             sta $2005
             sta $2005
             lda Mirror_PPU_CTRL_REG1
             and #%11101110
             ora #%00000011
             sta Mirror_PPU_CTRL_REG1
             sta PPU_CTRL_REG1
             
             
             lda #$82
             sta $8000
             lda #%10000100
             sta $8001
             
             lda #$83
             sta $8000
             lda #%10000011
             sta $8001
             lda Old8000 
             sta $8000
             ;lda #%00001010
             ;sta PPU_CTRL_REG2
             ;sta Mirror_PPU_CTRL_REG2
             
             
             
             ;lda #%00001100
             ;sta PPU_ADDRESS
             ;lda #$01
             ;sta PPU_SCROLL_REG
             ;lda #$00
             ;sta PPU_SCROLL_REG
             ;sta PPU_ADDRESS
             
             lda #$03
             sta $c000
             sta $c001
             sta $e001
             lda #$0e
             sta $2001
             
             
             inc IRQnum
             lda IRQAckFlag
+:    sta IRQAckFlag
             jmp EndIRQ
             
ThirdIRQ:
             cmp #$03
             bcs FourthIRQ
             ldx #50
-:
             dex
             bpl -
             lda #%00001100
             sta PPU_ADDRESS
             lda TextBoxYScroll
             clc
             adc #$07
             sta PPU_SCROLL_REG
             lda #$00
             sta PPU_SCROLL_REG
             lda TextBoxYScroll
             clc
             adc #$07
             and #$f8
             asl
             asl
             sta PPU_ADDRESS
             
             lda #$1f
             sta $c000
             sta $c001
             sta $e001
             inc IRQnum
             jmp EndIRQ
             
FourthIRQ:
             ldx #53
-:
             dex
             bpl -
             lda #%00001100
             sta PPU_ADDRESS
             lda #$53
             sta PPU_SCROLL_REG
             lda #$00
             sta PPU_SCROLL_REG
             lda #$40
             sta PPU_ADDRESS
             lda #$00
             sta $e000
             sta IRQAckFlag
             sta IRQnum
EndIRQ:    
             pla
             tay
             pla
             tax
             ;pla
             ;sta $00
             pla
             ;cli
             rti
             
             