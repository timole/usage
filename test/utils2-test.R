library("svUnit")
library("plyr")

source("../analysis/utils2.R")

clearLog()

# sample data: 
#   application 100 is ok and approved
#   application 101 fails and then approved
sue <- read.csv("../test/sampleUsageEvents.tsv", sep = ";", row.names = NULL)
sue <- fixAndSortUsageEventData(sue)
sue

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
  DEACTIVATED()
  checkEqualsNumeric(123, 99999999)
}
(runTest(isApplicationOK))

test(getApplicationEvents) <- function() {
  ae <- getApplicationEvents(sue, 100)
  checkEquals(nrow(ae), 9, "the amount of events for the application is known")

  ae <- getApplicationEvents(sue, 101)
  checkEqualsNumeric(nrow(ae), 11, "the amount of events for the application is known")
}
(runTest(getApplicationEvents))


print("###################################### Summary #########################################")
errorLog()
