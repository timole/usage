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

test(isApplicationOk) <- function() {
  checkEquals(isApplicationOk(sue, 100), T)
  checkEquals(isApplicationOk(sue, 101), F)
}
(runTest(isApplicationOk))

test(applicantHasModifiedAfterSubmission) <- function() {
  checkEquals(applicantHasModifiedAfterSubmission(sue, 100), F)
  checkEquals(applicantHasModifiedAfterSubmission(sue, 101), T)
}
(runTest(applicantHasModifiedAfterSubmission))


source("../analysis/utils2.R")
test(getApplicantModificationsAfterSubmission) <- function() {
  am <- getApplicantModificationsAfterSubmission(sue, 101)
  checkEquals(nrow(am), 1)
  checkTrue(am$action == "update-doc")
  checkTrue(am$target == "osoite.katu")
}
(runTest(getApplicantModificationsAfterSubmission))

test(findApplicationsWithOkWorkflow) <- function() {
  okApps <- findApplicationsWithOkWorkflow(sue)
  
  checkEquals(length(okApps), 4)
  checkEquals(100 %in% okApps, T)
  checkEquals(101 %in% okApps, T)
  checkEquals(102 %in% okApps, T)
  checkEquals(103 %in% okApps, F) #no submit-application
  checkEquals(104 %in% okApps, F) #no publish-verdict
  checkEquals(105 %in% okApps, T)
}
(runTest(findApplicationsWithOkWorkflow))

test(getApplicationEventsBeforeSubmission) <- function() {
  checkEquals(nrow(getApplicationEventsBeforeSubmission(sue[sue$applicationId == 100,])), 3)
  checkEquals(nrow(getApplicationEventsBeforeSubmission(sue[sue$applicationId == 101,])), 4)
}
(runTest(getApplicationEventsBeforeSubmission))

test(findApplicationOkState) <- function() {
  apps <- findApplicationOkState(sue)
  checkEquals(nrow(apps), 4)
  checkTrue(c(100, 101, 102, 105) %in% apps$applicationId)
  checkEquals(apps[apps$applicationId == 100,]$isOk, T)
  checkEquals(apps[apps$applicationId == 101,]$isOk, F)
  checkEquals(apps[apps$applicationId == 102,]$isOk, F)
  checkEquals(apps[apps$applicationId == 105,]$isOk, F)
}
(runTest(findApplicationOkState))

source("../analysis/utils2.R")
test(getSubmissionFaults) <- function() {
  apps <- findApplicationOkState(sue)
  failing <- apps[apps$isOk == F,]
  faults <- getSubmissionFaults(sue, failing$applicationId)
  print("faults")
  print(faults)
}
(runTest(getSubmissionFaults))


print("###################################### Summary #########################################")
errorLog()
