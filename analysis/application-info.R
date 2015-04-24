source("../analysis/utils2.R")

#setwd("\\\\intra.tut.fi/home/suonsyrj/My Documents/Publications/2015_ICIS/usage/analysis")
#setwd("C:/Users/timole/Documents/Solita/N4S/Lupapiste-usage/usage/analysis")
ue <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)
ue <- fixAndSortUsageEventData(ue)

apps <- as.data.frame(findApplicationsWithOkWorkflow(ue))

apps <- cbind(apps, apply(apps, 1, function(applicationId) {
  print(applicationId)
  isApplicationOk(ue, applicationId)
}))
colnames(apps) <- c("applicationId", "isOk")
