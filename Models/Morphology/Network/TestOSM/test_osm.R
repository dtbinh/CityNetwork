
library(osmar)
library(igraph)

setwd(paste0(Sys.getenv('CN_HOME'),'/Models/Morphology/Network/TestOSM'))

#
api <- osmsource_api()
# quite slow for large areas ; use localconnexion to osm file ?
# -> using osmosis
#osmosis <- osmsource_osmosis(file = paste0(Sys.getenv('CN_HOME'),'Data//OSM/'))europe-latest.osm.pbf
osmosis <- osmsource_osmosis(file = '/Volumes//Data/ComplexSystems//CityNetworkProv//Data//OSM//Europe',
                             osmosis="osmosis --read-pbf")

# invoke directly osmosis with system call
#   -- slow on Europe file -- -> split into countries eg ?
system("osmosis --read-pbf /Volumes/Data/ComplexSystems/CityNetworkProv/Data/OSM/Europe/europe-latest.osm.pbf --bounding-box top=48.8275 left=2.3815 bottom=48.8270 right=2.3820 --write-xml data/temp.osm")


# OLG : (2.3815,48.8265)
# height,width of box are in meters ; coordinates as decimal geographical
area <- center_bbox(2.3815,48.8265,200,200)

data <- get_osm(area,source = api)
#data <- get_osm(area,source=osmsource_file(file="data/temp.osm"))
plot_ways(data,col="red")

# request
hways <- find(data, way(tags(k == "highway")))

names(data$ways$attrs)
# -> use dataframe to get objects

#data_ways = data$ways$attrs[sapply(hways,function(x){which(data_ways$id == x)}),]
#as_osmar(data_ways)
# does not work this way

hways <- find(data, way(tags(k == "highway")))
data_ways = subset(data,way_ids=hways)
ids = find(data_ways,way(tags(k == "name")))
ids = find_down(data,way(ids))
data_ways = subset(data,ids=ids)

names(data_ways$nodes$attrs)
names(data_ways$ways$attrs)
data_ways$nodes$attrs$id

library(dplyr)

unique(data_ways$nodes$attrs$uid)
x = data_ways$nodes$attrs$lon
y = data_ways$nodes$attrs$lat
plot(data_ways)
points(x,y,col='red')
coords = tbl_df(data.frame(id=unique(data_ways$nodes$attrs$id),x=unique(x),y=unique(y)))

graph = as_igraph(data_ways)
V(graph)$name
# ok, vertices are in order compared to osm object ; can dirtily get coordinates to put in igraph object
#V(graph)$x=x
#set_vertex_attr(graph,"x",value=x)

names(edge.attributes(graph))
names(vertex.attributes(graph))


# merge tbldf to have ids
gids=as.tbl(data.frame(indexes=1:length(V(graph)),id=as.numeric(V(graph)$name)))
m=inner_join(coords,gids,by="id")

V(graph)$x=m$x[m$indexes]
V(graph)$y=m$y[m$indexes]
plot(graph,layout=as.matrix(data.frame(V(graph)$x,V(graph)$y)),vertex.label=NULL);points(x,y,col='red')

g=graph
clust = clusters(g);cmax = which(clust$csize==max(clust$csize))
ggiant = induced.subgraph(g,which(clust$membership==cmax))

distances(g) # distance ok
# -> eucl distance matrix to get relative speed
# idem mean path length : mean(distances) / spatial extent
mean(distances(ggiant))

# nw density ? 
2 * length(E(g))/(length(V(g))*(length(V(g))-1))

# centrality
centr_betw(ggiant)

# as_igraph DOES NOT WORK --
# use directly edgeList
#graph = graph.edgelist(as.matrix(data_ways$ways$refs))
# NO

# refs : way -> node ? or node -> way
# clarify that shit


# tests
clusters(graph)
bigcomponent = decompose.graph(graph)[[1]]
hist(betweenness(bigcomponent),breaks=500)


plot(degree.distribution(bigcomponent),type="l")


# measures
betweenness(bigcomponent)
mean(betweenness(bigcomponent))
radius(bigcomponent)


# communities
leading.eigenvector.community(bigcomponent)

com <- membership(edge.betweenness.community(bigcomponent))

lay<-layout.fruchterman.reingold(bigcomponent)
# try a plot
plot.igraph(bigcomponent,layout=layout.auto,vertex.color=com,vertex.label=NA)

#
library(rgexf)
igraph.to.gexf(bigcomponent)



