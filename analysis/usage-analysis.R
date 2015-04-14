#setwd("C:/Users/timole/Documents/Solita/N4S/Lupapiste/usage/analysis")
setwd("D:/user/terhoh/workspace/lupis/analysis")
ue <- read.csv("../data/lupapiste-usage-events-3months-small.tsv", sep = "\t", row.names = NULL)
ue$datetime <- strftime(ue$datetime, "%Y-%m-%d %H:%M:%OS3")
ue <- ue[with(ue, order(applicationId, datetime)), ]

#ids <- read.csv("../data/lupapiste-usage-events-3months-application-ids.tsv", sep = "\t", row.names = NULL)
#ue <- merge(ue, ids, by = "applicationId")
#ue <- ue[with(ue, order(applicationId, datetime)), ]
# write.table(ueSmall, file = "../samples/lupapiste-usage-events-3months-small.tsv", sep = "\t")
# ues <- read.csv("../samples/lupapiste-usage-events-3months-small.tsv", sep = "\t", row.names = NULL)
