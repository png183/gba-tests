This version of arm.gba has been modified significantly from jsmolka's original version.

Changes:
- Many new tests have been added for R15 offsets on SWP, LDR/STR variants, and MUL variants
- Multiplication tests where R15 is the destination register (write fails on hardware)
- Added test for SWP bits 20, 21, and 23 (should be ignored when decoding. Other effects are unknown, if any.)
- branches.asm is no longer included in arm.asm, and is instead assembled separately. This was done because it tests encodings that are listed as undefined, which may cause the tests to crash if handled incorrectly.

branches.asm and branches.gba:
- Added tests for bits 5 and 6 of BX (listed as zero in ARM docs, but aren't checked on real hardware)
- Added tests for BX destination register field in bits 12-15. These tests also require Thumb mode to be checked during the decode stage, because the tests enter Thumb mode without a pipeline flush.
- Added tests for BX CPSR mask field in bits 16-19. These tests also rely on condition code 0xF being handled properly (always evaluates to false)

TODO:
- Make data_swp.asm standalone (same reason as branches.asm)
