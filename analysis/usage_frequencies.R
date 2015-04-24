source("../analysis/utils2.R")

# Import usage evenets data into "ue" in RStudio or.. do the following
#setwd("\\\\intra.tut.fi/home/suonsyrj/My Documents/Publications/2015_ICIS/usage/analysis")
#setwd("C:/Users/timole/Documents/Solita/N4S/Lupapiste-usage/usage/analysis")
ue <- read.csv("../data/lupapiste-usage-events-all-20150414.tsv", sep = "\t", row.names = NULL)
ue <- fixAndSortUsageEventData(ue)

#----Count the lead times of each application----------------------------------
out <- split( ue , f = ue$applicationId )
leadtimes <- sapply( out , function(x) appLeadtime( x ) )
# TODO: Nyt läpimenoajat ovat listassa. Voisi muuttaa matriisiin tai data
# frameen, jotta saadaan yhdistettyä hakemuksittain myöhemmin.
#------------------------------------------------------------------------------

#----Check which applications have been "good ones"----------------------------
#source("Documents/R/usage/analysis/utils2.R")
# EI TOIMI OIKEIN
#appGoodness <- sapply( out, function(x) isApplicationOK( x ))
# SAMA TODO
#------------------------------------------------------------------------------


# Create a "usage frequency" datatable for storing applicationIDs as rows,
# Actions as columns, and the number of times used as cells.
library(data.table)
ueAppIdVsAction <- data.table(ue$applicationId, ue$Action )
setnames(ueAppIdVsAction, 1:2, c("applicationId", "Action"))
library(plyr)
uf <- count(ueAppIdVsAction, c("applicationId","Action"))
uf <- reshape(uf, v.names="freq", idvar="applicationId",timevar="Action",direction="wide")
