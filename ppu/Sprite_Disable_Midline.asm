format binary as 'gba'

include '../lib/constants.inc'
include '../lib/macros.inc'

header:
        include '../lib/header.asm'

main:
        m_test_init
        ; Reset test register
        mov     r12, 0

        ; turn off sound
        mov     r3, MEM_IO
        mov     r5, MEM_IO
        add     r5, 0x200
        add     r5, 0x2

        mov     r6, MEM_GAMEPAK0
        mov     r0, 0
        str     r0, [r3, REG_TIM0CNT]
        str     r0, [r3, REG_SNDCNT]
        str     r0, [r3, REG_SNDCNTX]
        str     r0, [r3, REG_IE]
        str     r0, [r3, REG_IME]

        ; enable LYC IRQ flag for halt
        mov     r0, 4
        str     r0, [r3, REG_IE]
        add     r3, 0x200
        add     r3, 2
        strh    r0, [r3]
        mov     r3, MEM_IO
        mov     r0, 0x20
        strh    r0, [r3, 4]

        ;wait for vblank
        mov     r7, 0x1
        mov     r5, MEM_IO
        add     r5, 4

 vb11:
        ldrh    r0, [r5]
        and     r0, r7
        cmp     r0, 1
        bne     vb11


        ; enable sprites at scanline 0
        ; will renderone scanline earlier
        ldrh    r0, [r3]
        mov     r1, 1
        lsl     r1, 12
        orr     r0, r1
        mov     r8, r0
        mov     r0, 0
        strh    r0, [r3]

        mov     r6, MEM_OAM
        mov     r0, 0
        mov     r1, 0xB
        mov     r2, 0x3
        mov     r3, 0x200
        lsl     r2, 14
        mov     r4, 1
        lsl     r4, 13
        add     r1, r4

load_oam1:
        strh    r1, [r6]
        add     r6, 2
        strh    r2, [r6]
        add     r6, 2
        strh    r3, [r6]
        add     r6, 2
        add     r6, 2
        add     r0, 1
        cmp     r0, 19
        bne     load_oam1

        add    r2, 64

load_oam2:
        strh    r1, [r6]
        add     r6, 2
        strh    r2, [r6]
        add     r6, 2
        strh    r3, [r6]
        add     r6, 2
        add     r6, 2
        add     r1, 1
        add     r2, 1
        add     r0, 1
        cmp     r0, 20
        bne     load_oam2

        add     r1, 60
        add     r2, 11
        add     r2, 0x100
        add     r2, 0x80

load_oam3:
        strh    r1, [r6]
        add     r6, 2
        strh    r2, [r6]
        add     r6, 2
        strh    r3, [r6]
        add     r6, 2
        add     r6, 2
        add     r0, 1
        cmp     r0, 128
        bne     load_oam3


        mov     r6, MEM_VRAM
        mov     r0, 0x14
        lsl     r0, 12
        add     r6, r0
        mov     r0, 0
        mov     r1, 1
        add     r1, 0x10
        add     r1, 0x100
        add     r1, 0x1000
        mov     r2, r1
        lsl     r1, 16
        add     r1, r2
        mov     r2, 0x1000

load_vram:
        str     r1, [r6]
        add     r0, 1
        add     r6, 4
        cmp     r0, r2
        bne     load_vram

        ;wait for vblank
        mov     r7, 0x1
        mov     r5, MEM_IO
        add     r5, 4

vb12:
        ldrh    r0, [r5]
        and     r0, r7
        cmp     r0, 1
        bne     vb12

        mov     r3, MEM_IO
        strh    r8, [r3]

        ; wait for scanline 66
        mov     r5, MEM_IO
        add     r5, 6
        mov     r1, 0x42

ly1:
        ldrb    r0, [r5]
        cmp     r0, r1
        bne     ly1

        ; set waitstate
        mov     r3, MEM_IO
        mov     r6, MEM_GAMEPAK0
        mov     r4, r6
        adr     r4, .wait_data
        ldr     r0, [r4]
        str     r0, [r3, REG_WAITCNT]

        ; we disable sprites mid rendering later
        ldrh    r4, [r3]
        mov     r2, r4
        mov     r1, 1
        lsl     r1, 16
        sub     r1, 1
        mov     r0, 1
        lsl     r0, 12
        sub     r1, r0
        and     r4, r1

        mov     r6, MEM_IO
        add     r6, 5
        mov     r7, r3
        add     r7, 0x200
        add     r7, 2

        mov     r0, 0
        adr     r0, t001 + 1
        bx      r0

align 4

.wait_data:
        dw      0x00000014

code16
align 2

t001:
        ; tests if last vram read cycle actually
        ; displays sprite pixels
        mov     r1, 0x48
        strb    r1, [r6]
        swi     2

        mov     r0, 0x4
        strh    r0, [r7]

        strh    r2, [r3]
        mov     r1, 0x47
        strb    r1, [r6]
        swi     2

        mov     r0, 0x4
        strh    r0, [r7]

        ; check cycle reading on last available vram cycle
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0
        mov     r0, r0

        strh    r4, [r3]


        b       t001

test_end:
        mov     r0, 0
        adr     r0, eval
        bx      r0

code32
align 4
eval:
        mov     r12, r2
        m_vsync
        m_test_eval r12

idle:
        b       idle

include '../lib/text.asm'

main_end:
