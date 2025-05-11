branches:
        ; Tests for branch operations

t050:
        ; ARM 1: Branch with exchange
        mov     r12, 50
        adr     r0, t051 + 1
        bx      r0

code16
align 2
t051:
        ; THUMB 5: Branch with exchange
        mov     r0, 51
        mov     r12, r0
        adr     r0, t052
        bx      r0

code32
align 4
t052:
        ; ARM 1: Branch without exchange
        mov     r12, 52
        adr     r0, t053
        bx      r0

t053:
        ; ARM 2: Branch forward
        mov     r12, 53
        b       t054

t055:
        ; ARM 2: Branch forward
        mov     r12, 55
        b       t056

t054:
        ; ARM 2: Branch backward
        mov     r12, 54
        b       t055

t057:
        ; ARM 2: Test link
        mov     r12, 57
        mov     pc, lr

t056:
        ; ARM 2: Branch with link
        mov     r12, 56
        bl      t057

t058:
        ; undocumented BX encoding - bit 5 of bx can be set
        mov     r12, 58
        adr     r0, t059
        dw      0xE12FFF30  ; bx r0

t059:
        ; undocumented BX encoding - bit 6 of bx can be set
        mov     r12, 59
        adr     r0, t060
        dw      0xE12FFF50  ; bx r0

t060:
        ; test that BX can write to registers apart from R15 with bits 12-15 acting as destination register field
        mov     r12, 60
        mov     r1, 42
        adr     r0, f060
        ; note: I had to come up with my own syntax for this operation,
        ; and decided to use the mnemonic "mvx rd, rm",
        ; with "mvx" standing for "move and exchange"
        dw      0xE12F1F10  ; mvx r1, r0
        cmp     r1, r0
        beq     t061
f060:
        m_exit  60

t061:
        ; test whether MVX can switch into Thumb mode
        mov     r12, 61
        mov     r1, 42
        adr     r0, t061a + 1
        adr     r2, t062
        dw      0xE12F1F10  ; mvx r1, r0  ; switches to Thumb mode
        nop     ; will be executed in ARM mode, since mode is checked at decode stage
code16
align 2
t061a:
        bx r2  ; recover to ARM mode
code32
align 4
f061:
        ; catch any code that accidentally reaches this point
        m_exit  61

code32
align 4
t062:
        ; check value in r1 after MVX with mode switch
        mov     r12, 62
        cmp     r1, r0
        beq     t063
        m_exit  62

t063:
        ; BX with mask field = 0b1001
        mov     r12, 63
        adr     r0, t064
        dw      0xE129FF10  ; bx r0
        m_exit  63

t064:
        ; BX with mask field = 0b0000
        mov     r12, 64
        adr     r0, t065
        dw      0xE120FF10  ; bx r0
        m_exit  64

t065:
        ; BX with mask field = 0b1000
        ; todo: test exchange operation
        mov     r12, 65
        adr     r0, t066
        dw      0xE128FF10  ; bx r0
        m_exit  65
t066:
        ; check PSR flags after BX with mask field = 0b1000
        mov     r12, 66
        mrs     r1, cpsr
        mov     r2, r15
        lsr     r1, 28
        lsr     r2, 28
        cmp     r1, r2
        beq     t067
        m_exit  66

t067:
        ; BX with mask field = 0b1001 with exchange operation
        mov     r12, 67
        adr     r0, t067a + 1
        adr     r1, t068
        dw      0xE129FF10  ; bx r0
        m_exit  67
code16
align 2
t067a:
        bx r1  ; recover to ARM mode
code32
align 4
        ; catch any code that accidentally reaches this point
        m_exit  67

t068:
        ; BX with mask field = 0b0000 cannot modify Thumb bit
        mov     r12, 68
        adr     r0, t068a + 1
        adr     r1, f068a
        dw      0xE120FF10  ; bx r0
t068a:
code16
        bl      f068  ; condition code ensures this is a NOP in ARM mode
code32        
align 4
        b       t069
code16
f068:
        bx      r1
code32
align 4
f068a:
        m_exit  68

t069:
        ; BX with mask field = 0b1000 cannot modify Thumb bit
        mov     r12, 69
        adr     r0, t069a + 1
        adr     r1, f069a
        dw      0xE128FF10  ; bx r0
t069a:
code16
        bl      f069  ; condition code ensures this is a NOP in ARM mode
code32        
align 4
        b       t070
code16
f069:
        bx      r1
code32
align 4
f069a:
        m_exit  69
t070:
        ; check PSR flags
        mov     r12, 70
        mrs     r1, cpsr
        mov     r2, r15
        lsr     r1, 28
        lsr     r2, 28
        cmp     r1, r2
        beq     t071
        m_exit  70

align 256
t071:
        ; BX with mask field = 0b0001 with exchange operation
        mov     r12, 71
        adr     r0, t071a + 1  ; will switch CPU into FIQ mode upon bx r0
        adr     r1, t072
        nop
        dw      0xE121FF10  ; bx r0
        m_exit  71
code16
align 2
t071a:
        bx r1  ; recover to ARM mode
code32
align 4
        ; catch any code that accidentally reaches this point
        msr     cpsr_c, MODE_SYS
        m_exit  71
t072:
        ; check what PSR mode the CPU is now in (expected FIQ)
        mov     r12, 72
        mrs     r2, cpsr
        msr     cpsr_c, MODE_SYS
        lsl     r2, 27
        lsr     r2, 27
        cmp     r2, 0x11
        beq     t073
        m_exit  72

align 256
t073:
        ; BX with mask field = 0b0001, but put the CPU in a different mode
        mov     r12, 73
        adr     r0, t073a + 1  ; will switch CPU into FIQ mode upon bx r0
        adr     r1, f073
        nop
        nop
        nop
        nop     ; extra NOPs prevents Thumb mode swap due to mask field
        nop
        nop
        nop
        nop
        dw      0xE121FF10  ; bx r0
f073:
        msr     cpsr_c, MODE_SYS
        m_exit  73
code16
t073a:
        bl      f073a  ; condition code ensures this is a NOP in ARM mode
code32
align 4
t074:
        ; check what PSR mode the CPU is now in (expected FIQ)
        mov     r12, 74
        mrs     r2, cpsr
        msr     cpsr_c, MODE_SYS
        lsl     r2, 27
        lsr     r2, 27
        cmp     r2, 0x11
        beq     branches_passed
        m_exit  74
code16
align 2
f073a:
        bx      r1

code32
align 4
branches_passed:
        mov     r12, 0
