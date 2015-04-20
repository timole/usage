#setwd("c:/Users/timole/Documents/Solita/N4S/Lupapiste-usage/usage/analysis")

library(plyr)

ue <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)
ue$datetime <- strftime(ue$datetime, "%Y-%m-%d %H:%M:%OS3")
ue <- ue[with(ue, order(applicationId, datetime)), ]

#create table from data and count applicationId vs. actions
table1 <- count(ue, c("applicationId","action"))
reshape(table1, v.names="freq", idvar="applicationId",timevar="action",direction="wide")

#amount of uniqueIds
length(unique(ue$applicationId))

uemax <- max(ue$datetime)
uemin <- min(ue$datetime)


# a better way to do it...
ueAppIdVsAction <- table(ue$applicationId, ue$action )

#amount of uniqueIds
ueUniqueIds <- length(unique(ue$applicationId))
