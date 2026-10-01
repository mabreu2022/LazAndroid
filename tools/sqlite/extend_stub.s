.text
.global __extenddftf2
.type __extenddftf2, %function
__extenddftf2:
    fmov x0, d0
    lsr x1, x0, #63
    ubfx x2, x0, #52, #11
    lsl x3, x0, #12
    lsr x3, x3, #12

    cbz x2, .Lzero
    cmp x2, #0x7ff
    beq .Linf

    mov x5, #0x3c00
    add x2, x2, x5
    b .Lpack

.Linf:
    mov x2, #0x7fff
    b .Lpack

.Lzero:
    cbz x3, .Lpack
    mov x5, #0x3c00
    add x2, x2, x5

.Lpack:
    lsl x1, x1, #63
    lsl x2, x2, #48
    orr x1, x1, x2
    lsr x4, x3, #4
    orr x1, x1, x4
    lsl x0, x3, #60

    fmov d0, x0
    mov v0.d[1], x1
    ret
