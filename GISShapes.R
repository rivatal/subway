library(GISTools)

shapes <- read.table("gtfs_data/shapes.txt",header=TRUE, 
                         sep=",",fill=TRUE,quote = "",row.names = NULL,
                         stringsAsFactors = FALSE) 
shapes <- shapes[0:4]
plot(shapes)
data(georgia)

readShapePoly("gtfs_data/shapes.txt")
