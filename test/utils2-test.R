library("svUnit")
library("plyr")

source("../analysis/utils2.R")

# sample data: 
#   application 100 is ok and approved
#   application 101 fails and then approved
sue <- read.csv("../test/sampleUsageEvents.tsv", sep = "\t", row.names = NULL)
sue <- fixAndSortUsageEventData(sue)

print(sprintf("There are %d applications in the sample data", length(unique(sue$applicationId))))
print(sue)

test(appLeadtime) <- function() {
  out <- split( sue , f = sue$applicationId )
  leadtimes <- sapply( out , function(x) appLeadtime( x ) )
  print(leadtimes)
  checkEqualsNumeric(leadtimes["100"], 2)
  checkEqualsNumeric(leadtimes["101"], 3)
}
(runTest(appLeadtime))

# TODO: create a test for function isApplicationOK
test(isApplicationOK) <- function() {
  checkEqualsNumeric(123, 99999999)
}
(runTest(isApplicationOK))
