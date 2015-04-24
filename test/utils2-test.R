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

  checkEqualsNumeric(as.numeric(leadtimes["100"]), 2)
  checkEqualsNumeric(as.numeric(leadtimes["101"]), 3)
}
(runTest(appLeadtime))

test(isApplicationOK) <- function() {
  checkEquals(isApplicationOk(sue[sue$applicationId == 100,]), T)
  checkEquals(isApplicationOk(sue[sue$applicationId == 101,]), F)
}
(runTest(isApplicationOK))

test(findApplicationsWithOkWorkflow) <- function() {
  okApps <- findApplicationsWithOkWorkflow(sue)
  
  checkEquals(length(okApps), 3)
  checkEquals(100 %in% okApps, T)
  checkEquals(101 %in% okApps, T)
  checkEquals(102 %in% okApps, T)
  checkEquals(103 %in% okApps, F) #no submit-application
  checkEquals(104 %in% okApps, F) #no publish-verdict
}
(runTest(findApplicationsWithOkWorkflow))

test(getApplicationEventsBeforeSubmission) <- function() {
  checkEquals(nrow(getApplicationEventsBeforeSubmission(sue[sue$applicationId == 100,])), 3)
  checkEquals(nrow(getApplicationEventsBeforeSubmission(sue[sue$applicationId == 101,])), 4)
}
(runTest(getApplicationEventsBeforeSubmission))

print("###################################### Summary #########################################")
errorLog()
