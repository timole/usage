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
  # Applications are considered "OK"..
  # *when they don't have usage events by applicant..
  # *after the "submit-application" event AND..
  # *excluding the following usage events:
  #   "mark-seen"
  #   "add-comment"
  #   "fetch-validation-errors"
  #   "invite-with-role"
  #   "approve-invite"
  #   "inform-construction-started"
  #   "inform-construction-ready"
  
  # Applications can be submitted only once. 
  submissionTime <- NULL
  
  # A few events by the applicant are considered ok, even after the submission.
  excludedEvents <- c("mark-seen ", "add-comment ", "fetch-validation-errors ",
  "invite-with-role ", "approve-invite ", "inform-construction-started ",
  "inform-construction-ready")
  
  # Check all events for submissions.
  apply(data, 1, function(row) {
  
    # If this event is the submitting one..
    if( action == "submit-application " ){
	  #..store the time of the submission.
      submissionTime <- row["datetime"]
    }
    
  })
  
  # Check all events for usage by "applicant"..
  apply(data, 1, function(row) {
	
	#..and if they occur after the submission time and if they're not included
	# in our list of "OK-events".
	if (row["role"] == "applicant" &&
	  difftime( row["datetime"], submissionTime) > 0 &&
	  !(is.element(row["Action"], excludedEvents))){
      
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
