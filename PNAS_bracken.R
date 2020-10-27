setwd("/Users/chengguo/Desktop/Project/VIH/PNAS_Relman/")

library("phyloseq")
library("scatterplot3d")
library("ggplot2")
library("ggrepel")

map = "VIH.mapping.keemei.txt"
category1= "kraken_CST_final"
otu= "All.merged.OTU.100.ConsensusLiniage.txt"

gpt = import_qiime(otufilename=otu,mapfilename=map)

ps<-gpt
tt <- data.frame(tax_table(gpt))
ps <- transform_sample_counts(ps, function(OTU) OTU/sum(OTU))

braydist <- phyloseq::distance(ps, method="bray")
ord = ordinate(ps, method = "MDS", distance = braydist)
plot_scree(ord) + xlim(as.character(seq(1,12))) + ggtitle("MDS-bray ordination eigenvalues")
evs <- ord$value$Eigenvalues
print(evs[1:20])
print(tail(evs))

h_sub5 <- hist(evs[6:length(evs)], 100)
plot(h_sub5$mids, h_sub5$count, log="y", type='h', lwd=10, lend=2)

NDIM <- 7
x <- ord$vectors[,1:NDIM]  # rows=sample, cols=MDS axes, entries = value
pamPCoA = function(x, k) {
  list(cluster = pam(x[,1:2], k, cluster.only = TRUE))
}
gs = clusGap(x, FUN = pamPCoA, K.max = 12, B = 50)
plot_clusgap(gs) + scale_x_continuous(breaks=c(seq(0, 12, 2)))

K <- 5
x <- ord$vectors[,1:NDIM]
clust <- as.factor(pam(x, k=K, cluster.only=T))
# SWAPPING THE ASSIGNMENT OF 2 AND 3 TO MATCH RAVEL CST ENUMERATION
clust[clust==2] <- NA
clust[clust==3] <- 2
clust[is.na(clust)] <- 3
sample_data(ps)$CST <- clust
CSTs <- as.character(seq(K))

CSTColors <- brewer.pal(6,"Paired")[c(1,3,2,5,4,6)] # Length 6 for consistency with pre-revision CST+ coloration
names(CSTColors) <- CSTs
CSTColorScale <- scale_colour_manual(name = "CST", values = CSTColors[1:5])
CSTFillScale <- scale_fill_manual(name = "CST", values = CSTColors[1:5])
grid.arrange(plot_ordination(ps, ord, color="CST") + CSTColorScale,
             plot_ordination(ps, ord, axes=c(3,4), color="CST") + CSTColorScale, top="Ordination by Cluster")
plot_ordination(ps, ordinate(ps, method="NMDS", distance=braydist), color="CST") + CSTColorScale + ggtitle("NMDS -- bray -- By Cluster")

taxa.order <- names(sort(taxa_sums(ps)))
for(CST in CSTs) {
  pshm <- prune_taxa(names(sort(taxa_sums(ps), T))[1:25], ps)
  pshm <- prune_samples(sample_data(pshm)$CST == CST, pshm)
  print(plot_heatmap(pshm, taxa.label="Species", taxa.order=taxa.order) + ggtitle(paste("CST:", CST)))
}