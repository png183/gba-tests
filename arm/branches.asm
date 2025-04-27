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
        nop  ; will be executed in ARM mode, since mode is checked at decode stage
code16
align 2
t061a:
        bx r2  ; recover to ARM mode

code32
align 4
t062:
        ; check value in r1 after MVX with mode switch
        mov     r12, 62
        cmp     r1, r0
        beq     branches_passed
        m_exit  62

branches_passed:
        mov     r12, 0
