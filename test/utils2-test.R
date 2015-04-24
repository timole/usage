library("svUnit")
library("plyr")

source("../analysis/utils2.R")

clearLog()

# sample data: 
#   application 100 is ok and approved
#   application 101 fails and then approved
sue <- read.csv("../test/sampleUsageEvents.tsv", sep = ";", row.names = NULL)
sue <- fixAndSortUsageEventData(sue)

print(sprintf("There are %d applications in the sample data", length(unique(sue$applicationId))))
print(sue)

source("../analysis/utils2.R")
test(appLeadtime) <- function() {
  out <- split( sue , f = sue$applicationId )
  leadtimes <- sapply( out , function(x) appLeadtime( x ) )

  checkEqualsNumeric(as.numeric(leadtimes["100"]), 2)
  checkEqualsNumeric(as.numeric(leadtimes["101"]), 3)
}
(runTest(appLeadtime))

test(isApplicationOK) <- function() {
  checkEquals(isApplicationOk(sue[sue$applicationId == 100,]), T)
  checkEquals(isApplicationOk(sue[sue$applicationId == 101,]), F)
}
(runTest(isApplicationOK))

print("###################################### Summary #########################################")
errorLog()
