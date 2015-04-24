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

test(appLeadtime) <- function() {
  out <- split( sue , f = sue$applicationId )
  leadtimes <- sapply( out , function(x) appLeadtime( x ) )
  print(leadtimes)
  checkEqualsNumeric(leadtimes["100"], 2)
  checkEqualsNumeric(leadtimes["101"], 3)
}
(runTest(appLeadtime))

source("../analysis/utils2.R")
test(isApplicationOK) <- function() {
  checkEquals(isApplicationOk(getApplicationEvents(sue, 100)), T)
  checkEquals(isApplicationOk(getApplicationEvents(sue, 101)), F)
}
(runTest(isApplicationOK))

test(getApplicationEvents) <- function() {
  aue <- getApplicationEvents(sue, 100)
  checkEquals(nrow(aue), 8, "the amount of events for the application is known")

  aue <- getApplicationEvents(sue, 101)
  checkEqualsNumeric(nrow(aue), 10, "the amount of events for the application is known")
}
(runTest(getApplicationEvents))

test(isWorkflowOK) <- function() {
  checkEquals(isWorkflowOK(getApplicationEvents(sue, 100)), F))
  checkEquals(isWorkflowOK(getApplicationEvents(sue, 101)), F))
  checkEquals(isWorkflowOK(getApplicationEvents(sue, 102)), T))
}
(runTest(isWorkflowOK))

print("###################################### Summary #########################################")
errorLog()
