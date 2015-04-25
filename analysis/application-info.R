source("../analysis/utils2.R")

#setwd("\\\\intra.tut.fi/home/suonsyrj/My Documents/Publications/2015_ICIS/usage/analysis")
#setwd("C:/Users/timole/Documents/Solita/N4S/Lupapiste-usage/usage/analysis")
ue <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)
ue <- fixAndSortUsageEventData(ue)

apps <- findApplicationOkState(ue)
failingAppIds <- apps[apps$isOk == F,]$applicationId
faults <- getSubmissionFaults(ue, failingAppIds)

print("reasons why applications with ok workflows fail")
print(faults)
