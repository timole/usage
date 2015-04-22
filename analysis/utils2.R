fixAndSortUsageEventData <- function(ue) {
  ue$datetime <- as.POSIXct(ue$datetime)
  ue <- ue[!is.na(ue$applicationId),]
  ue <- ue[with(ue, order(applicationId, datetime)), ]

  # Merge action and target columns into one Action column
  ue$Action <- paste(ue$action, ue$target)
  ue[, "Action"] <- ue$Action
  ue <- subset(ue, select = -c(action,target) )
}

# Usage events of one application as a parameter.
# Returns TRUE if there are no events by the role "applicant" after "submit-application"
isApplicationOK <- function(data){
  
  # Flag for checking if "submit-application" has occurred.
  appSubmitDone <- FALSE
  
  # Submission time
  submissionTime <- as.POSIXct("1970-01-01")
  
  # Flag for checking if an event by the role "applicant" has occurred.
  applicantEvent <- FALSE
  
  # Order events by time.
  ue <- ue[with(ue, order(datetime)), ]
  
  # Check all events
  apply(data, 1, function(row) {
    role <- row["role"]
    action <- row["Action"]
    
    
    # Mark as submitted if this event is the submitting one.
    # TODO Nyt ei oteta huomioon tilanteita, joissa submit tehdään uudestaan!
    if( action == "submit-application " ){
      appSubmitDone <- TRUE
      submissionTime <- row["datetime"]
    }
    else if (role == "applicant" && difftime( row["datetime"], submissionTime) > 0){
      
      # Applicant has usage event after submission. Therefore, the application
      # can't be an ideal one.
      applicantEvent <- TRUE
    }
  })
  return(!applicantEvent)
}


#------------------------------------------------------------------------------
# Usage events of one application as a parameter.
# Returns the lead time of the application
appLeadtime <- function(data){

  data$datetime <- as.POSIXct(data$datetime)
  
  # Order events by time.
  data <- data[with(data, order(datetime)), ]
  
  # Store the time of the first usage event.
  firstEvent <- data[1,"datetime"]
  
  # Find the row which has the approval event.
  lastEvent <- data[which(data$Action == "publish-verdict " | data$Action == "approve-application "), "datetime"]
  
  # If there was no verdict published, return with NA.
  # TODO
  
  # Return leadtime
  leadTime <- difftime(lastEvent, firstEvent)
}
