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
  haveSubmitApplication <- unique(ue[ue$role == "applicant" & ue$action == "submit-application",]$applicationId)
  havePublishVerdict <- unique(ue[ue$role == "authority" & ue$action == "publish-verdict",]$applicationId)
  haveCheckForVerdict <- unique(ue[ue$role == "authority" & ue$action == "check-for-verdict",]$applicationId)
  return(intersect(haveSubmitApplication, union(havePublishVerdict, haveCheckForVerdict)))
}

getApplicantModificationsBeforeSubmission <- function(ue, applicationId) {
  aue <- ue[ue$applicationId == applicationId,]

  submitEvent <- head(aue[aue$action == "submit-application",], 1)
  before <- aue[aue$datetime < submitEvent$datetime,]
  modifications <- before[before$action %in% MODIFICATION_ACTIONS,]
  return(modifications)
}

getApplicationsApplicantModificationsBeforeSubmission <- function(ue, applicationIds) {
  appInput <- data.frame()
  for(applicationId in applicationIds) {
    print(sprintf("Get modifications for application %d", applicationId))
    mods <- getApplicantModificationsBeforeSubmission(ue, applicationId)
    appInput <- rbind(appInput, mods)
  }
  return(appInput)
}

getApplicationInfo <- function(ue) {
  apps <- findApplicationOkState(ue)
  applicationIds <- apps$applicationId
  ats <- getApplicationsApplicantModificationsBeforeSubmission(ue, applicationIds)
  ats$actionTarget <- toActionTarget(ats)
  ats <- ats[c("applicationId", "actionTarget")]
  ats <- as.data.frame(table(ats))
  ats <- reshape(ats, v.names="Freq", idvar="applicationId", timevar="actionTarget", direction="wide")

  colnames(ats) <- sub("Freq.", "", colnames(ats))
  ats[is.na(ats)] <- 0  
  ats <- merge(ats, apps, by = "applicationId")
  return(ats)
}

toActionTarget <- function(ue) {
  return(paste(ifelse(ue$action == "update-doc", "d", ifelse(ue$action == "upload-attachment", "a", "UNKNOWN")), ue$target, sep = "-"))
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
