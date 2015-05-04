source("../analysis/utils.R")
source("../analysis/utils2.R")

library("kohonen")

#setwd("\\\\intra.tut.fi/home/suonsyrj/My Documents/Publications/2015_ICIS/usage/analysis")
#setwd("C:/Users/timole/Documents/Solita/N4S/Lupapiste-usage/usage/analysis")
ue <- read.csv("../data/lupapiste-usage-events-all-20150428.tsv", sep = "\t", row.names = NULL)
ue <- fixAndSortUsageEventData(ue)

apps <- findApplicationOkState(ue)
failingAppIds <- apps[apps$isOk == F,]$applicationId
faults <- getSubmissionFaults(ue, failingAppIds)

print("reasons why applications with ok workflows fail")
print(faults)

date()
applicationInfo <- getApplicationInfo(ue)
date()


m  <- as.matrix(applicationInfo[,2:(ncol(applicationInfo) - 2)])
rownames(m) <- paste(ifelse(applicationInfo$isOk, "OK", "FAIL"), applicationInfo$applicationId, sep = "-")

#----SOM------------------------------------
set.seed(7)
kohmap <- som(data = m, grid = somgrid(6, 4, "hexagonal"), rlen = 100)
par(mfrow=c(2,2))
plot(kohmap, type="changes")
plot(kohmap)
kohmap <- som(data = m, grid = somgrid(12, 8, "hexagonal"), rlen = 100)
plot(kohmap, type="changes")
plot(kohmap)

infovisData <- list(somMap = somToDataMap(kohmap))
jsonData <- RJSONIO::toJSON(infovisData)

write(jsonData, file = "somData.json")
df <- as.data.frame(kohmap$data)
df$id <- rownames(df)
write.csv(df, "items.csv", row.names = F)

#----Preprocessing for RF-------------------
#install.packages("caret", dependencies = c("Depends", "Suggests"))
library(mlbench)
library(caret)

# Application IDs relocated from first column to rownames.
rownames(applicationInfo) <- applicationInfo[,1]
applicationInfo[,1] <- NULL

# calculate correlation matrix
correlationMatrix <- cor(applicationInfo)
# summarize the correlation matrix
print(correlationMatrix)
# find attributes that are highly corrected (ideally >0.75)
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.5)
# print indexes of highly correlated attributes
print(highlyCorrelated)

#Remove columns with correlations to eachother!?
apps.df <- applicationInfo[ -highlyCorrelated ]

#----RandomForest---------------------------
#apps.rf <- randomForest(isOk ~ ., data=apps.df, importance=TRUE, proximity=TRUE)
#print(apps.rf)

set.seed(17)
apps.urf <- randomForest(apps.df[, -194])
MDSplot(apps.urf, apps.df$isOk)
