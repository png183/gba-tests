Some audio fifo DMA tests with unusual results

Test 2 requires writing to fifo manually while audio is off to not add samples to the fifo
This test also requires DMA from fixed source in ROM to use non-sequential acceses.

Test 4 is the same as test 2 except with a few added nops, but gives different results. The second FIFO-DMA should be all sequential cycles for the numbers to work out.
This is the case even if the nops are removed. I don't understand this behavior.


