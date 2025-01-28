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
        mov     r0, 0
        str     r0, [r3, REG_SNDCNT]
        str     r0, [r3, REG_SNDCNTX]
        str     r0, [r3, REG_IE]
        str     r0, [r3, REG_IME]
        mov     r1, MEM_EWRAM

        ; start out in ABT mode
        mov     r2, 0x17
        msr     cpsr_c, r2

t001:
        ; test that bit 4 of CPSR mode is forced to 1,
        ; even if that mode value is nonsense
        mov     r2, 0x0c
        msr     cpsr_c, r2
        mrs     r1, cpsr
        and     r1, 0xFF
        cmp     r1, 0x1c
        bne     f001

        ; re-enter ABT mode
        mov     r2, 0x17
        msr     cpsr_c, r2

t002:
        ; test whether bit 4 of SPSR mode is forced to 1
        mov     r2, 0x03
        dw      0xE161F002  ; msr     spsr_c, r2
        mrs     r1, spsr
        and     r1, 0xFF
        cmp     r1, 0x13
        bne     f002

        ; enter SYS mode
        mov     r1, 0x1F
        msr     cpsr_c, r1

        bl      eval

f001:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 1
        bl      eval

f002:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 2
        bl      eval

eval:
        m_vsync
        m_test_eval r12

idle:
        b       idle

include '../lib/text.asm'

main_end:
