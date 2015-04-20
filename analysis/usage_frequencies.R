#install the plyr which contains the handy count function
#install.packages("plyr")
library(plyr)

# Import data into "ue" in RStudio or.. do the following
#ue <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)

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
uf <- count(ueAppIdVsAction, c("applicationId","Action"))
uf <- reshape(uf, v.names="freq", idvar="applicationId",timevar="Action",direction="wide")
