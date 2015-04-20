# Data is expected in data.frame format in "uf" variable
install.packages('kohonen')
library(kohonen)

# Change data into matrix format
#uf_matrix <- data.table(uf[1:7,2:163])

#uf_matrix <- as.matrix(uf_matrix[1:7][3:5])

#uf.sc <- scale(uf_matrix)
#set.seed(7)
#uf.som <- som(data = uf.sc)
Sys.time()
uf[is.na(uf)] <- 0
data_train <- uf[,-(1),drop=FALSE]
data_train_matrix <- as.matrix(scale(data_train))
Sys.time()
som_grid <- somgrid(xdim = 20, ydim=20, topo="hexagonal")
Sys.time()
som_model <- som(data_train_matrix, 
                 grid=som_grid, 
                 rlen=100, 
                 alpha=c(0.05,0.01), 
                 keep.data = TRUE,
                 n.hood="circular" )

Sys.time()