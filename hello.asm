.segment "HEADER"
.byte "NES"
.byte $1a
.byte $02 ; 2 * 16KB PRG ROM
.byte $01 ; 1 * 8KB CHR ROM
.byte $0 ; mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes
.segment "ZEROPAGE"
RunLRFlag: .res 1
.segment "STARTUP"

Reset:
    SEI
    CLD

    ; Disable sound IRQ
    LDX #$40
    STX $4017

    ; Initialize the stack register
    LDX #$FF
    TXS

    INX 
    ; Zero out the PPU registers
    STX $2000
    STX $2001

    STX $4010

:   
    BIT $2002
    BPL :-

    TXA

ClearMEM:
    STA $0000, X
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FF
    STA $0200, X
    LDA #$00
    INX
    BNE ClearMEM

:
    BIT $2002
    BPL :-

    LDA #$02
    STA $4014
    NOP

    ; Write palette
    ; Use 2006 register tell ppu data addr
    ; Use 2007 register write 1 byte data
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00

LoadPalettes:
    LDA PaletteData, X
    STA $2007 
    INX
    CPX #$20
    BNE LoadPalettes

    LDX #$00
LoadSprites:
    LDA SpriteData, X
    STA $0200, X
    INX
    CPX #$20
    BNE LoadSprites

    CLI

    LDA #%10010000 ; enable NMI change background to use second chr
    STA $2000

    LDA #%00011110 ; enable sprintes background
    STA $2001

    LDA #$01
    STA RunLRFlag

Loop:
    BIT $2002
    BPL Loop

    LDA #$01
    CMP RunLRFlag
    BNE RunLeft

    ; if 0203 == CD run left
    LDA $0203
    CMP #$F0
    BNE RightPP
    DEC RunLRFlag
RightPP:
    ;INC $0200
    INC $0203
    ;INC $0204
    INC $0207
    ;INC $0208
    INC $020B
    ;INC $020C
    INC $020F
    ;INC $0210
    INC $0213
    ;INC $0214
    INC $0217
    ;INC $0218
    INC $021B
    ;INC $021C
    INC $021F
    JMP Loop
RunLeft:

    ;if 0203 == 0 run right
    LDA $0203
    CMP #$00
    BNE LeftDD
    INC RunLRFlag
LeftDD:
    ;INC $0200
    DEC $0203
    ;INC $0204
    DEC $0207
    ;INC $0208
    DEC $020B
    ;INC $020C
    DEC $020F
    ;INC $0210
    DEC $0213
    ;INC $0214
    DEC $0217
    ;INC $0218
    DEC $021B
    ;INC $021C
    DEC$021F
    JMP Loop

NMI:
    LDA #$02
    STA $4014 ; use DMA
    RTI

PaletteData:
  .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
  .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

SpriteData:
  .byte $08, $00, $00, $08
  .byte $08, $01, $00, $10
  .byte $10, $02, $00, $08
  .byte $10, $03, $00, $10
  .byte $18, $04, $00, $08
  .byte $18, $05, $00, $10
  .byte $20, $06, $00, $08
  .byte $20, $07, $00, $10

.segment "VECTORS"
    .word NMI
    .word Reset

.segment "CHARS"
    .incbin "hellomario.chr"