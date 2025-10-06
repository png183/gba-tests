memcnt:
        ; Tests for MEMCNT register

t100:
        ; check MEMCNT existence and initial state
        mov     r0, MEM_IO
        m_word  r1, 0x0d000020
        ldr     r2, [r0, 0x0800]
        cmp     r1, r2
        bne     f100
        b       t101

f100:
        m_exit  100

t101:
        ; mirroring should only occur every 0x10000 bytes
        add     r0, 0x8000
        ldr     r2, [r0, 0x0800]
        cmp     r1, r2
        beq     f101
        add     r0, 0x8000
        ldr     r2, [r0, 0x0800]
        cmp     r1, r2
        bne     f101
        add     r0, 0x00fe0000
        ldr     r2, [r0, 0x0800]
        cmp     r1, r2
        bne     f101
        b       t102

f101:
        m_exit  101

t102:
        ; try reading separate halfs
        mov     r0, MEM_IO
        add     r0, 0x0800
        mov     r3, r1
        lsl     r3, 16
        lsr     r3, 16
        ldrh    r2, [r0, 0x00]  ; lower half
        cmp     r2, r3
        bne     f102
        mov     r3, r1
        lsr     r3, 16
        ldrh    r2, [r0, 0x02]  ; upper half
        cmp     r2, r3
        bne     f102
        b       t103

f102:
        m_exit  102

t103:
        ; try reading separate bytes
        mov     r3, r1
        lsl     r3, 24
        lsr     r3, 24
        ldrb    r2, [r0, 0x00]
        cmp     r2, r3
        bne     f103
        mov     r3, r1
        lsr     r3, 8
        lsl     r3, 24
        lsr     r3, 24
        ldrb    r2, [r0, 0x01]
        cmp     r2, r3
        bne     f103
        mov     r3, r1
        lsr     r3, 16
        lsl     r3, 24
        lsr     r3, 24
        ldrb    r2, [r0, 0x02]
        cmp     r2, r3
        bne     f103
        mov     r3, r1
        lsr     r3, 24
        ldrb    r2, [r0, 0x03]
        cmp     r2, r3
        bne     f103
        b       t104

f103:
        m_exit  103

t104:
        ; test that disabling EWRAM causes IWRAM to be read instead
        m_word  r0, 0x01234567
        m_word  r1, 0x89abcdef
        mov     r2, MEM_EWRAM
        mov     r3, MEM_IWRAM
        mov     r4, MEM_IO
        ; store values to EWRAM and IWRAM
        str     r0, [r2]
        str     r1, [r3]
        ; disable EWRAM in MEMCNT
        m_word  r5, 0x0d000000
        str     r5, [r4, 0x0800]
        ; read values from IWRAM and disabled EWRAM
        ldr     r6, [r2]
        ldr     r7, [r3]
        ; restore EWRAM in MEMCNT
        m_word  r5, 0x0d000020
        str     r5, [r4, 0x0800]
        ; compare values read
        cmp     r6, r1
        bne     f104
        cmp     r7, r1
        bne     f104
        b       t105

f104:
        m_exit  104

t105:
        ; test reading from restored EWRAM
        ldr     r6, [r2]
        ldr     r7, [r3]
        cmp     r6, r0
        bne     f105
        cmp     r7, r1
        bne     f105
        b       t106

f105:
        m_exit  105

t106:
        ; test EWRAM access timings when disabled
        mov     r5, 0
        mov     r6, 0x00800000
        ; init timer
        str     r5, [r4, REG_TIM0CNT]
        str     r6, [r4, REG_TIM0CNT]
        ; perform read and write in IWRAM region
        swp     r7, r8, [r3]  ; values in r7 and r8 are irrelevant
        ; read timer value into r0
        ldr     r0, [r4, REG_TIM0CNT]
        str     r5, [r4, REG_TIM0CNT]
        ; disable EWRAM
        m_word  r9, 0x0d000000
        str     r9, [r4, 0x0800]
        nop  ; ensure sequentiality is consistent between runs
        ; init timer
        str     r5, [r4, REG_TIM0CNT]
        str     r6, [r4, REG_TIM0CNT]
        ; perform read and write in disabled EWRAM region
        swp     r7, r8, [r2]  ; values in r7 and r8 are irrelevant
        ; read timer value into r1
        ldr     r1, [r4, REG_TIM0CNT]
        str     r5, [r4, REG_TIM0CNT]
        ; restore EWRAM
        m_word  r9, 0x0d000020
        str     r9, [r4, 0x0800]
        ; check that timings matched
        cmp     r0, r1
        bne     f106
        b       t107

f106:
        m_exit  106

t107:
        ; test BIOS mapped at 0x02000000 is still read-protected
        mov     r6, 0x02000000
        mov     r5, 0
        ldr     r4, [r5]  ; read from unswapped BIOS
        mov     r0, MEM_IO
        m_word  r1, 0x0d000021
        str     r1, [r0, 0x0800]  ; swap BIOS with RAM
        ldr     r5, [r6]  ; read from swapped BIOS
        sub     r1, 1
        str     r1, [r0, 0x0800]  ; restore MEMCNT
        cmp     r4, r5  ; check that protection was used in both
        bne     f107
        b       t108

f107:
        m_exit  107

t108_iwram:
        ; code to run from RAM
        ; r0: address to perform read
        ; r1: return value
        ; r14: return address
        ldr     r1, [r0]
        mov     r15, r14

t108:
        ; test BIOS read protection when executing from IWRAM just before BIOS
        mov     r5, MEM_IO
        m_word  r4, 0x0d000021
        str     r4, [r5, 0x0800]  ; swap BIOS with RAM
        ; install test code in IWRAM
        adr     r0, t108_iwram
        m_word  r2, 0x01fffff8  ; destination address
        mov     r1, r2
        ldr     r3, [r0], 4
        str     r3, [r1], 4
        ldr     r3, [r0], 4
        str     r3, [r1], 4
        ; test that the same result occurs when reading BIOS from ROM and from IWRAM
        mov     r0, 0x02000000
        mov     r1, 0
        ldr     r3, [r0]
        mov     r14, r15  ; save PC in LR
        mov     r15, r2  ; jump to IWRAM code
        sub     r4, 1
        str     r4, [r5, 0x0800]  ; restore MEMCNT
        cmp     r1, r3
        beq     f108
        b       t109

f108:
        m_exit  108

t109:
        ; todo - test the following:
        ; IWRAM open bus when accessing disabled EWRAM
        ; SWI with BIOS swap
        ; EWRAM timing modification
        ; Overclocking EWRAM accesses to 1 cycle?

memcnt_passed:
