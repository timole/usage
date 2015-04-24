MODIFICATION_ACTIONS <- c("update-doc", "upload-attachment")

fixAndSortUsageEventData <- function(ue) {
  ue$datetime <- as.POSIXct(ue$datetime)
  ue <- ue[!is.na(ue$applicationId ),]
  ue <- ue[with(ue, order(applicationId, datetime)), ]
}

applicantHasNotModifiedAfterSubmission <- function(ue, applicationId) {
  aue <- ue[ue$applicationId == applicationId,]

  # Submission time
  submissionEvent <- head(aue[aue$action == "submit-application" & aue$role == "applicant",], 1)
  if(nrow(submissionEvent) == 0) {
    return(F)
  }
  lastModificationEvent <- tail(aue[aue$role == "applicant" & (aue$action %in% MODIFICATION_ACTIONS),], 1)
  if(nrow(lastModificationEvent) == 0) {
    return(F)
  }

  if(lastModificationEvent$datetime < submissionEvent$datetime) {
    return(T)
  } else {
    return(F)
  }
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
  return(applicantHasNotModifiedAfterSubmission(ue, applicationId))
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
