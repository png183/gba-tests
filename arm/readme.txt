This version of arm.gba has been modified significantly from jsmolka's original version.

Changes:
- Many new tests have been added for R15 offsets on LDR/STR
- Added tests for future LDRD/STRD opcode space
- branches.asm, data_swap.asm, and multiply.asm are no longer included in arm.asm, and are instead assembled separately. This was done because they test encodings that are listed as undefined, which may cause the tests to crash if handled incorrectly.

branches.asm and branches.gba:
- Added tests for bits 5 and 6 of BX (listed as zero in ARM docs, but aren't checked on real hardware)
- Added tests for BX destination register field in bits 12-15. These tests also require Thumb mode to be checked during the decode stage, because the tests enter Thumb mode without a pipeline flush.
- Added tests for BX CPSR mask field in bits 16-19. These tests also rely on condition code 0xF being handled properly (always evaluates to false)

data_swap.asm and data_swap.gba:
- Added tests for R15 offsets
- Added tests for SWP bits 20, 21, and 23, which should all be ignored when decoding. Effect on execution is unknown, if any.

multiply.asm and multiply.gba:
- Added tests for R15 offsets
- Added tests for R15 as destination register (writing to R15 should fail)
- Added tests for bit 22 of instruction, which appears to be ignored by decode and execute stages

TODO:
- Make halfword_transfer.asm standalone because of undefined encodings
