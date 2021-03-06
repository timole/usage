#---PRE-REQs FOR R------------------------------------------
.libPaths("C:/Users/suonsyrj/Local/Programs/R")
setwd("\\\\intra.tut.fi/home/suonsyrj/My Documents/Publications/2015_ICIS/usage/analysis")
#setwd("C:/Users/timole/Documents/Solita/N4S/Lupapiste-usage/usage/analysis")
source("../analysis/utils.R")
source("../analysis/utils2.R")

#---DATA LOAD AND PREPROCESS---------------------------------
#ue <- read.csv("../data/lupapiste-usage-events-all-20150505.tsv", sep = "\t", row.names = NULL)
ue <- read.csv("../data/lupapiste-usage-events-all-20150428.tsv", sep = "\t", row.names = NULL)
ue <- fixAndSortUsageEventData(ue)

#library(lubridate)
#date1 <- as.POSIXct("2015-01-01 00:00:00")
#date2 <- as.POSIXct("2015-04-30 00:00:00")
#int <- new_interval(date1, date2)
#ue <- ue[ue$datetime %within% int,]


#---FAILING APPS---------------------------------------------
#apps <- findApplicationOkState(ue)
#failingAppIds <- apps[apps$isOk == F,]$applicationId
#faults <- getSubmissionFaults(ue, failingAppIds)

#print("reasons why applications with ok workflows fail")
#print(faults)

#---RESHAPE AS USAGE ATTRIBUTES / APP------------------------
date()
applicationInfo <- getApplicationInfo(ue)
date()

m  <- as.matrix(applicationInfo[,2:(ncol(applicationInfo) - 2)])
rownames(m) <- paste(ifelse(applicationInfo$isOk, "OK", "FAIL"), applicationInfo$applicationId, sep = "-")

#----SOM-----------------------------------------------------
library("kohonen")
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

#----Preprocessing to remove unnecessary columns-------------
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

#Remove unnecessary columns with correlations to eachother
apps.df <- applicationInfo[ -highlyCorrelated ]

#---FIRST DECISION TREE METHOD: Rpart------------------------
#install.packages('rattle')
#install.packages('rpart.plot')
#install.packages('RColorBrewer')
library(rattle)
library(rpart.plot)
library(RColorBrewer)
fit <- rpart(isOk ~ .-isOk, data=apps.df, method="class", control=rpart.control(minsplit=20, cp=0.001))
fancyRpartPlot(fit)

#---RANDOM FOREST--------------------------------------------
apps.rf <- randomForest(isOk ~ .-isOk, data=apps.df, importance=TRUE, proximity=TRUE)
print(apps.rf)

set.seed(17)
apps.urf <- randomForest(apps.df[, -194])
MDSplot(apps.urf, apps.df$isOk)

