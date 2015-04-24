fixAndSortUsageEventData <- function(ue) {
  ue$datetime <- as.POSIXct(ue$datetime)
  ue <- ue[!is.na(ue$applicationId ),]
  ue <- ue[with(ue, order(applicationId, datetime)), ]
}


applicantHasNotModifiedAfterSubmission <- function(aue) {
  print(aue)
  
  # Submission time
  submissionEvent <- aue[aue$action == "submit-application" & aue$role == "applicant",]
  lastModificationEvent <- tail(aue[aue$role == "applicant" & (aue$action == "update-doc" | aue$action == "upload-attachment"),], 1)
  return(lastModificationEvent$datetime < submissionEvent$datetime)
}


# Usage events of one application as a parameter.
# Returns TRUE if there are no events by the role "applicant" after "submit-application"
isApplicationOk <- function(aue){
  return(applicantHasNotModifiedAfterSubmission(aue))
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
