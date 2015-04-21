library("kohonen")
library("rjson")

classifierToXY <- function(somMap, c) {
  col <- (c - 1) %% somMap$grid$xdim + 1
  row <- somMap$grid$ydim - ( floor( (c - 1) / somMap$grid$xdim))
  return(list(x = col - 1, y = row - 1))
}

getSomItemLocations <- function(somMap) {
  lapply(somMap$unit.classif, function(c) { return(classifierToXY(somMap, c))})
}

somToDataMap <- function(somMap) {
  ids <- rownames(somMap$data)
  datas <- split(somMap$data, row(somMap$data))
  locations <- getSomItemLocations(somMap)

  all <- list()
  for(i in seq(1:length(ids))) {
    item <- list(x = locations[[i]]$x, y = locations[[i]]$y) 
    all[[ids[i]]] <- item
  }
  
  dimensions <- getDimensions(somMap)
  m <- kohmap$data
  m <- cbind(id = rownames(m), m)
  itemDimensionValues = toMapByColumnName(m, "id")
  
  dataMap <- list(xdim = somMap$grid$xdim, ydim = somMap$grid$ydim, items = all, dimensions = dimensions) #itemDimensionValues = itemDimensionValues
  return(dataMap)
}

somToJSON <- function(somMap) {
  dataMap <- somToDataMap(somMap)
  return(rjson::toJSON(dataMap))
}

toMapByColumnName <- function(df, columnName) {
  colIndex <- grep(paste(paste("^", columnName, sep = ""), "$", sep = ""), colnames(df))
  userList <- list()
  dataTypes <- sapply(df, class)
  apply(df, 1, function(d) {
    itemList <- list()
	i <- 1
	lapply(colnames(df), function(colName) {
      item <- d[colName]
	  if(dataTypes[i] != "factor") {
        class(item) <- dataTypes[i]
	  } else {
	  }
      itemList[[colName]] <<- item[[1]]
	  i <<- i + 1
	})
    userList[[ d[colIndex] ]] <<- itemList
  })
  return(userList)
}

getDimensions <- function(somMap) {
  matrices <- list()
  m <- matrix(0, nrow = somMap$grid$ydim, ncol = somMap$grid$xdim)
  vals <- lapply(seq(1, ncol(somMap$data)), function(i) {
    return(aggregate(as.numeric(somMap$data[,i]), by=list(somMap$unit.classif), FUN=mean, simplify=TRUE)[,2])
  })
  d <- 1
  for(dimension in vals) {
    i <- 1
    for(val in dimension) {
      coords <- classifierToXY(somMap, i)
	  col <- coords$x + 1
	  row <- coords$y + 1
	  m[row, col] <- val
	  i <- i + 1
    }
	name <- colnames(somMap$data)[d]
	matrices[[name]] <- t(m)
	d <- d + 1
  }
  return(matrices)
}

# Usage events of one application as a parameter.
# Returns TRUE if there are no events by the role "applicant" after "submit-application"
isApplicationOK <- function(data){
	
	# Flag for checking if "submit-application" has occurred.
	appSubmitDone <- FALSE
	
	# Flag for checking if an event by the role "applicant" has occurred.
	appOK <- TRUE
	
	# Order events by time.
	ue <- ue[with(ue, order(datetime)), ]
	
	# Loop events
	apply(data, 1, function(row) {
		role <- row["role"]
		action <- row["Action"]

		# Mark as submitted if this event is the submitting one.
		if( action == "submit-application" ){
			appSubmitDone <- TRUE
		}
		
		# Check if application has been submitted.
		if(appSubmitDone){
			
			# Check if this event is by applicant.
			if( role == "applicant" ){
				# Mark application as NOT OK.
				appOK <- FALSE
			}
		}
	})
	return(appOK)
}