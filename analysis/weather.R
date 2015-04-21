library("kohonen")
setwd("C:/Users/timole/Dropbox/Timo/projektit/weatherscraper")
source("utils.R")

weather <- read.csv("weather.csv",sep=",", encoding = "UTF-8")

m <- as.matrix(weather[,2:6])
rownames(m) <- weather[,1]
m

set.seed(8)
kohmap <- som(data = m, grid = somgrid(4, 3, "hexagonal"), rlen = 100)
plot(kohmap)

infovisData <- list(somMap = somToDataMap(kohmap))
jsonData <- RJSONIO::toJSON(infovisData)


write(jsonData, file = "somData.json")
df <- as.data.frame(kohmap$data)
df$id <- rownames(df)
write.csv(df, "items.csv", row.names = F)

