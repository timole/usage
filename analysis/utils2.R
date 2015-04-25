MODIFICATION_ACTIONS <- c("update-doc", "upload-attachment")

fixAndSortUsageEventData <- function(ue) {
  ue$datetime <- as.POSIXct(ue$datetime)
  ue <- ue[!is.na(ue$applicationId ),]
  ue <- ue[with(ue, order(applicationId, datetime)), ]
}

applicantHasModifiedAfterSubmission <- function(ue, applicationId) {
  modifications <- getApplicantModificationsAfterSubmission(ue, applicationId)
  return(nrow(modifications) > 0)
}

getApplicantModificationsAfterSubmission <- function(ue, applicationId) {
  aue <- ue[ue$applicationId == applicationId,]

  submissionEvent <- head(aue[aue$action == "submit-application" & aue$role == "applicant",], 1)
  if(nrow(submissionEvent) == 0) {
    return(NA)
  }

  events <- aue[aue$role == "applicant" & aue$action %in% (MODIFICATION_ACTIONS) & aue$datetime > submissionEvent$datetime,]
  eventActionsAndTargets <- unique(events[,c("action", "target")])
  return(eventActionsAndTargets)
}

# Returns TRUE if there are no events by the role "applicant" after "submit-application"
isApplicationOk <- function(ue, applicationId){
  return(! applicantHasModifiedAfterSubmission(ue, applicationId))
}

# return applicationIds of applications that follow the "normal" workflow
findApplicationsWithOkWorkflow <- function(ue) {
  haveSubmitApplication <- ue[ue$role == "applicant" & ue$action == "submit-application",]$applicationId
  havePublishVerdict <- ue[ue$role == "authority" & ue$action == "publish-verdict",]$applicationId
  return(intersect(haveSubmitApplication, havePublishVerdict))
}

getApplicationEventsBeforeSubmission <- function(aue) {
  submitEvent <- aue[aue$action == "submit-application",]
  before <- aue[aue$datetime < submitEvent$datetime,]
  return(before)
}

findApplicationOkState <- function(ue) {
  okIds <- findApplicationsWithOkWorkflow(ue)
  apps <- as.data.frame(okIds)
  apps$isOk <- apply(apps, 1, function(applicationId) {
    print(sprintf("Application %d", applicationId))
    flush.console()
    isApplicationOk(ue, applicationId)
  })
  colnames(apps) <- c("applicationId", "isOk")
  return(apps)
}

getSubmissionFaults <- function(ue, applicationIds) {
  faults <- ue[0:0,]
  for(applicationId in applicationIds) {
    f <- getApplicantModificationsAfterSubmission(ue, applicationId)
    f$applicationId <- applicationId
    f <- f[c("applicationId", "action", "target")]
    faults <- rbind(faults, f)
    flush.console()
  }
  return(faults)
}

#------------------------------------------------------------------------------
# Usage events of one application as a parameter.
# Returns the lead time of the application
appLeadtime <- function(data){
  # Order events by time.
  data <- data[with(data, order(datetime)), ]

  # Store the time of the first usage event.
  firstEvent <- data[1,"datetime"]
  
  # Find the row which has the approval event.
  lastEvent <- data[which(data$action == "publish-verdict"), "datetime"]
  
  # Return leadtime
  leadTime <- difftime(lastEvent, firstEvent)
}
