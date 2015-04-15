#ue <- read.csv("../data/lupapiste-usage-events-3months-small.tsv", sep = "\t", row.names = NULL)
#ue$datetime <- strftime(ue$datetime, "%Y-%m-%d %H:%M:%OS3")
#ue <- ue[with(ue, order(applicationId, datetime)), ]

#ue2 <- read.csv("../data/lupapiste-usage-events-3months.tsv", sep = "\t", row.names = NULL)
#ue2$datetime <- strftime(ue$datetime, "%Y-%m-%d %H:%M:%OS3")
#ue2 <- ue2[with(ue2, order(applicationId, datetime)), ]


#install the plyr which contains the handy count function
install.packages("plyr")
library(plyr)

ue3 <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)
#convert date to POSIX format
ue3$datetime <- strftime(ue$datetime, "%Y-%m-%d %H:%M:%OS3")
#order list 
ue3 <- ue3[with(ue3, order(applicationId, datetime)), ]



#create table from data and count applicationId vs. actions
table1 <- count(ue3, c("applicationId","action"))
reshape(table1, v.names="freq", idvar="applicationId",timevar="action",direction="wide")

#amount of uniqueIds
length(unique(ue3$applicationId))


ue3max <- max(ue3$datetime)
ue3min <- min(ue3$datetime)


# a better way to do it...
ue3AppIdVsAction <- table(ue3$applicationId, ue3$action )

#amount of uniqueIds
ue3UniqueIds <- length(unique(ue3$applicationId))
