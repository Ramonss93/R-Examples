library(orca)
data(petersen)
all(duplicated(count4(petersen))[-1])
all(duplicated(count5(petersen))[-1])
all(duplicated(ecount4(petersen))[-1])
all(duplicated(ecount5(petersen))[-1])
