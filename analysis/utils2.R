getApplicationEvents <- function(ue, applicationId) {
  ue <- ue[!is.na(ue$applicationId) & ue$applicationId == applicationId,]
}

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

print("submission:")
print(submissionEvent)

print("last:")
print(lastModificationEvent)

  if(lastModificationEvent$datetime > submissionEvent$datetime) {
print("is after")
    return(F)
  } else {
print("not after")
    return(T)
  }
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

print(data)
  
  # Store the time of the first usage event.
  firstEvent <- data[1,"datetime"]
  
  # Find the row which has the approval event.
  lastEvent <- data[which(data$action == "publish-verdict" | data$action == "approve-application"), "datetime"]
  
  # If there was no verdict published, return with NA.
  # TODO

print("le")
print(lastEvent)
print("fe")
print(firstEvent)
  
  # Return leadtime
  leadTime <- difftime(lastEvent, firstEvent)
}
