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
        adr     r0, branches_passed
        dw      0xE12FFF50  ; bx r0

branches_passed:
        mov     r12, 0
