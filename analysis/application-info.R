source("../analysis/utils2.R")

#setwd("\\\\intra.tut.fi/home/suonsyrj/My Documents/Publications/2015_ICIS/usage/analysis")
#setwd("C:/Users/timole/Documents/Solita/N4S/Lupapiste-usage/usage/analysis")
ue <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)
ue <- fixAndSortUsageEventData(ue)

okIds <- findApplicationsWithOkWorkflow(ue)

apps <- as.data.frame(okIds)

apps$isOk <- apply(apps, 1, function(applicationId) {
  print(sprintf("Application %d", applicationId))
  flush.console()
  isApplicationOk(ue, applicationId)
})

colnames(apps) <- c("applicationId", "isOk")
