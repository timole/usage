#install the plyr which contains the handy count function
#install.packages("plyr")
#install.packages('data.table')

# Import data into "ue" in RStudio or.. do the following
#setwd("\\\\intra.tut.fi/home/suonsyrj/My Documents/Publications/2015_ICIS/usage/analysis")
ue <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)

#convert date to POSIX format
ue$datetime <- strftime(ue$datetime, "%Y-%m-%d %H:%M:%OS3")
#order list
ue <- ue[with(ue, order(applicationId, datetime)), ]

# Merge action and target columns into one Action column
ue$Action <- paste(ue$action, ue$target)
ue[, "Action"] <- ue$Action
ue <- subset(ue, select = -c(action,target) )

# Create a "usage frequency" datatable for storing applicationIDs as rows,
# Actions as columns, and the number of times used as cells.
library(data.table)
ueAppIdVsAction <- data.table(ue$applicationId, ue$Action )
setnames(ueAppIdVsAction, 1:2, c("applicationId", "Action"))
library(plyr)
uf <- count(ueAppIdVsAction, c("applicationId","Action"))
uf <- reshape(uf, v.names="freq", idvar="applicationId",timevar="Action",direction="wide")

# Check the original data by applicationIDs and mark if they are ok.
	# Choose events by appIds and send them in those chunks to "isApplicationOK"-func (in utils.R)
	# Save these returned booleans by appIds
