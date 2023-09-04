Tests prefetcher behaviour when branching to nearby addresses and what happens when the prefetcher is full.
Interesting behaviour is noted when prefetcher is full. It appears that the prefetch unit pauses until the buffer is empty and then starts up again with non-sequential timing.
