library('optparse')
option_list <- list(
	make_option(c("-i", "--feature-table-without-comment"),metavar="path", dest="data",help="Specify the abundance table you want to debatch, you should not contain any comment in the file, taxonomy or otuid must in the firsr as well as last column",default=NULL),
	make_option(c('-f',"--feature-table-with-comment"),metavar="path", dest="otu",help="Specify the otu table you want to debatch with comment at first row, if --input is supplied, this one will be ignored.",default=NULL),
  make_option(c("-m", "--map"),metavar="path",dest="map", help="Specify the path of mapping file",default=NULL),
  make_option(c("-c", "--category"),metavar="string",dest="group", help="Specify category name in mapping file, the effect of which will be eliminated. If not passed, no batch effect will be corrected. You can specify more than one category, use commas as delimeter",default=NULL),
	make_option(c("-e", "--exclude"),metavar="string",dest="ex", help="Specify the numeric variables excluded from batch effect correcting. Use commas as delimiter",default="none"),
	make_option(c("--min-samples"),metavar="int or float",dest="sample", help="Pass this to filter your otu table before debatch",default=NULL),
  make_option(c("--min-frequency"),metavar="int or float",dest="frequency", help="Pass this to filter your otu table before debatch",default=NULL),
  make_option(c("--only-mean"),metavar='logical',dest="onlymean", help="If TRUE, only mean will be corrected, otherwise both variance and mean will be corrected",default=TRUE),
	make_option(c("-o", "--output"),metavar="directory",dest="out", help="Specify the directory where the debatched abundance file will be placed",default="./")  
	)

opt <- parse_args(OptionParser(option_list=option_list))

library(stringr)

if(!dir.exists(opt$out)){dir.create(opt$out,recursive = T)}

if(!is.null(opt$data)){
  data<- read.table(opt$data,quote='',comment.char="",check.names=F,stringsAsFactors=F, header = TRUE, sep = "\t",na.strings='')
}else{
  data<- read.table(opt$otu,quote='',skip = 1,comment.char="",check.names=F,stringsAsFactors=F, header = TRUE, sep = "\t",na.strings='')
}


backdata<-data[,c(1,length(data))]
colname_backdata<-colnames(backdata)
data<-data[,-c(1,length(data))]

if(!is.null(opt$sample)){
  ifelse(as.numeric(opt$sample)>=1,sel<-apply(data, 1, function(x){return(sum(x>0)>=as.numeric(opt$sample))}),
         sel<-apply(data, 1, function(x){return(sum(x>0)>=(as.numeric(opt$sample)*ncol(data)))}))
  data<-data[sel,]
  backdata<-backdata[sel,]
}

if(!is.null(opt$frequency)){
  sel<-(colSums(t(data))>=as.numeric(opt$frequency))
  data<-data[sel,]
  backdata<-backdata[sel,]
}

if (!is.null(opt$group)){
  library(sva)
  map<-read.table(opt$map,comment.char="",check.names=F,stringsAsFactors=F, header = TRUE, sep = "\t",na.strings='')
  map<-map[,-ncol(map)]
  #map<-map[match(colnames(data),map[,1]),]
  pos<-match(map[,1],colnames(data))
  data<-data[,pos]
#  data<-apply(data,2,function(x){x/sum(x)})


  notstr=c()
  for(i in 1:ncol(map)){
    notstr[i]=!is.character(map[,i])
  }
  #ex<-str_split(opt$ex,",")[[1]]
  #if(ex[1]!="none"){notstr<-(notstr&(!colnames(map)%in%ex))}
  #N<-sum(notstr)
  #batch_map<-t(data.frame(map[,notstr],check.names = F))
  #colnames(batch_map)<-map[,1]
  map<-map[,!notstr]

  for (group in str_split(opt$group,',')[[1]]) {
    batch <- as.factor(map[group][,1])
    modcombat = model.matrix(~1, data=map)
    data <- ComBat(dat=data, batch=batch, mod=modcombat, par.prior=F, prior.plots=F,mean.only = as.logical(opt$onlymean))
    #if(N>0){batch_map <- ComBat(dat=batch_map, batch=batch, mod=modcombat, par.prior=F, prior.plots=F,mean.only = as.logical(opt$onlymean))}
  }
  #batch_map<-t(batch_map)
}



data<-data.frame(backdata[,1],data,backdata[,2],check.names = F)
colnames(data)[c(1,ncol(data))]<-colname_backdata
if(!is.null(opt$data)){
  write.table(data,paste(opt$out,'/','Filtered_or_corrected_feature_table.txt',sep = ''),sep = '\t',quote = F,row.names = F)
}else{
  cm<-"# Feature table filterd or batch effects corrected"
  write.table(cm,paste(opt$out,'/','Filtered_or_corrected_feature_table.txt',sep = ''),sep = '\t',quote = F,row.names = F,col.names=F,append = F)
  suppressWarnings(write.table(data,paste(opt$out,'/','Filtered_or_corrected_feature_table.txt',sep = ''),sep = '\t',quote = F,row.names = F,append = T))
}


N<-0
if (!is.null(opt$group)){
  #library(sva)
  map<-read.table(opt$map,comment.char="",check.names=F,stringsAsFactors=F, header = TRUE, sep = "\t",na.strings='')
  #map<-na.omit(map)
  map<-map[,-ncol(map)]
  #map<-map[match(colnames(data),map[,1]),]
  notstr=c()
  for(i in 1:ncol(map)){
    notstr[i]=!is.character(map[,i])
  }
  ex<-str_split(opt$ex,",")[[1]]
  if(ex[1]!="none"){notstr<-(notstr&(!colnames(map)%in%ex))}
  N<-sum(notstr)
  batch_map<-t(data.frame(map[,notstr],check.names = F))
  pr<-ncol(batch_map)
  colnames(batch_map)<-map[,1]
  map<-map[,!notstr]
  #print(is.na(batch_map))
  sel2<-(colSums(is.na(batch_map))==0)
  batch_map<-batch_map[,sel2]
  map<-map[sel2,]
  print(sprintf("%d is filtered from map during the correcting of batch effects of mapping file as NA occurred", pr-nrow(map)))
  for (group in str_split(opt$group,',')[[1]]) {
    batch <- as.factor(map[group][,1])
    modcombat = model.matrix(~1, data=map)
    #data <- ComBat(dat=data, batch=batch, mod=modcombat, par.prior=F, prior.plots=F,mean.only = as.logical(opt$onlymean))
    if(N>0){batch_map <- ComBat(dat=batch_map, batch=batch, mod=modcombat, par.prior=F, prior.plots=F,mean.only = as.logical(opt$onlymean))}
  }
  batch_map<-t(batch_map)
}

if (!is.null(opt$group)&N>0){
  write.table(data.frame(map,batch_map,Description=map[,1],check.names = F,check.rows = F),paste(opt$out,'/','Batch_corrected_map.txt',sep = ''),sep = '\t',quote = F,row.names = F,na ="")
  }

