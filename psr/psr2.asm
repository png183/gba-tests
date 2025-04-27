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

        ; enter SYS mode
        mov     r2, 0x1F
        msr     cpsr_c, r2

t001:
        ; test reading/writing extension field (should always be zero)
        mov     r3, 0xff
        lsl     r3, 8
        mov     r2, 0x42
        lsl     r2, 8
        msr     cpsr_x, r2
        mrs     r1, cpsr
        and     r1, r3
        cmp     r1, r2
        beq     f001
t002:
        cmp     r1, 0
        bne     f002

t003:
        ; test reading/writing status field (should always be zero)
        lsl     r2, 8
        lsl     r3, 8
        msr     cpsr_s, r2
        mrs     r1, cpsr
        and     r1, r3
        cmp     r1, r2
        beq     f003
t004:
        cmp     r1, 0
        bne     f004

t005:
        ; test reading/writing undocumented CPSR flag bits (should always be zero)
        lsl     r2, 8
        lsl     r3, 8
        msr     cpsr_f, r2
        mrs     r1, cpsr
        and     r1, r3
        cmp     r1, r2
        beq     f005
t006:
        lsr     r3, 4
        and     r1, r3
        cmp     r1, 0
        bne     f006

t007:
        ; test that bit 4 of CPSR mode is forced to 1,
        ; even if that mode value is nonsense
        mov     r2, 0x0c
        msr     cpsr_c, r2
        mrs     r1, cpsr
        and     r1, 0xFF
        cmp     r1, 0x1c
        bne     f007

        ; enter ABT mode
        mov     r2, 0x17
        msr     cpsr_c, r2

t008:
        ; test whether bit 4 of SPSR mode is forced to 1
        mov     r2, 0x03
        dw      0xE161F002  ; msr     spsr_c, r2
        mrs     r1, spsr
        and     r1, 0xFF
        cmp     r1, 0x13
        bne     f008

        ; re-enter SYS mode
        mov     r2, 0x1F
        msr     cpsr_c, r2

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

f003:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 3
        bl      eval

f004:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 4
        bl      eval

f005:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 5
        bl      eval

f006:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 6
        bl      eval

f007:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 7
        bl      eval

f008:
        mov     r1, 0x1F
        msr     cpsr_c, r1
        mov     r12, 8
        bl      eval

eval:
        m_vsync
        m_test_eval r12

idle:
        b       idle

include '../lib/text.asm'

main_end:
