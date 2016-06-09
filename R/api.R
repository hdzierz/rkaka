#' Automatically loading/installing biocinductor packages if necessary
#'
#' @param A package name
#'
#' @return Nothing
#'
#' @examples
#' pkgBio('deseq2')


pkgBio <- function(x)
{
    if (!require(x,character.only = TRUE))
    {
        source("http://bioconductor.org/biocLite.R")
        biocLite(x)
        if(!require(x,character.only = TRUE)) stop("Package not found")
    }
}

kaka.config.port='80'
kaka.config.host='web'

#' Querying Kaka using json (helper for kaka.qry)
#'
#' @param realm A data realm
#' @param qry A pql query
#' @param host Web host to talk to (default web)
#' @param port Port to web host (default 80, but often 8001)
#'
#' @return data_frame
#'
#' @examples
#' pkgBio('deseq2')

kaka.qry_json <- function(realm, qry, host=kaka.config.host, port=kaka.config.port){
    qry = URLencode(qry)
    qry_str <- paste("http://",host,":",port,"/qry/",realm,"/?qry=",qry,sep="")
    print(qry_str)
    dat <- read.csv(curl(qry_str), stringsAsFactors=FALSE)
    dat
}

#' Querying Kaka
#'
#' @param realm A data realm
#' @param expr A pql query expression
#' @param host Web host to talk to (default web)
#' @param port Port to web host (default 80, but often 8001)
#'
#' @return data_frame
#'
#' @examples
#' dat <- kaka.qry('genotype', experiment=='Gene Expression')

kaka.qry <- function(realm, expr, host=kaka.config.host, port=kaka.config.port, columns=NULL){
    tt <- grep("[a-zA-Z0-9\\s\'\"]=[a-zA-Z0-9\\s\'\"]", expr)
    if(length(tt)>0){
        print("ERROR: You seem to have a single = in your expression. If it is a comparison operator use ==.")
        return(0)
    }
    qry <- paste(expr,"&infmt=python",sep="")
    dat <- kaka.qry_json(realm, qry, host, port)
    if(is.null(columns)){
        return(dat)
    }
    else{
        return(dat[columns])
    }
}

#' Getting configuration for an experiment and data_source
#'
#' @param realm A data realm
#' @param experiment A name of an experiment
#' @param data_source A name of a data source
#' @param host Web host to talk to (default web)
#' @param port Port to web host (default 80, but often 8001)
#'
#' @return data_frame
#'
#' @examples
#' dat <- kaka.get_config('genotype', experiment=='Gene Expression', data_source='')


kaka.get_config <-function(realm, experiment, data_source, host=kaka.config.host, port=kaka.config.port){
        url <- paste('http://', host, ':', port, '/config?experiment=', experiment, '&data_source=', data_source, sep='')
        print(url)
        cfg <- fromJSON(url)
        cfg
}


kaka.init_config <- function(realm, experiment="", data_source=""){
        config = list(
            "DataSource"=list(
                "Format"= "python_dict",
                "IdColumn"= "" ,
                "Name"= data_source,
                "Source" = '',
                "Group"= "",
                "Type"= "",
                "Creator"= "",
                "Mode"= "Override",
                "Contact"= ""
            ),
            "Experiment"=list(
                "Name" =experiment,
                "Code"= "",
                "Date"= "",
                "Description"= "",
                "Realm"= realm,
                "Password"= "",
                "Pi"= "",
                "Species"= "",
                "Contact"= ""
            )
        )
        config
}


#' Sending data to Kaka
#'
#' @param data A data frame
#' @param config A confiuguration dict (see examples)
#' @param host Web host to talk to (default web)
#' @param port Port to web host (default 80, but often 8001)
#'
#' @return data_frame
#'
#' @examples
#' dat <- kaka.get_config('genotype', experiment=='Gene Expression', data_source='')

kaka.send <- function(data, config, host=kaka.config.host, port=kaka.config.port){
    ser <- toJSON(data)
    config <- toJSON(config)

    data<-list("dat"=ser,"config"=config)

    postToHost(host=host,path='/send',data.to.send=data,port=port)
}

#    @staticmethod
#    def send_destroy(realm, experiment, key, cfg=cfg):
#        url = 'http://' + cfg['web_host']  + ':' + cfg['web_port']  + '/destroy?realm=' + realm  + '&experiment=' + experiment + '&password=' + key + '&mode=Destroy'
#        print(url)
#        req = urll.urlopen(url)
#        print(req.read())

    #@staticmethod
    #def send_clean(realm, experiment, key, cfg=cfg):
    #    url = 'http://' + cfg['web_host']  + ':' + cfg['web_port']  + '/destroy?realm=' + realm  + '&experiment=' + experiment + '&password=' + key + '&mode=Clean'
    #    print(url)
    #    req = urll.urlopen(url)
    #    print(req.read())

    #@staticmethod
    #def send_passwd(realm, experiment, key, cfg=cfg):
    #    url = 'http://' + cfg['web_host']  + ':' + cfg['web_port']  + '/destroy?realm=' + realm  + '&experiment=' + experiment + '&password=' + key + '&mode=Resetpwd'
    #    print(url)
    #    req = urll.urlopen(url)
    #    print(req.read())

kaka.deseq2 <- function(experiment="gene_expression", host=kaka.config.host, port=kaka.config.port){
    pkgBio("DESeq2")
    # Get design for exeriment

    dat.tgt <- kaka.qry("design", paste("experiment=='",experiment,"'", sep=""), host, port)
    rownames(dat.tgt) <- dat.tgt$phenotype
    dat.tgt$phenotype <- NULL
    print(head(dat.tgt))

    # Load Data

    dat.kaka <- kaka.qry("genotype", paste("experiment=='",experiment,"'", sep=""), host, port)
    rownames(dat.kaka) <- dat.kaka$name
    print(head(dat.kaka))

    # Reduce data

    dat.kaka <- dat.kaka[rownames(dat.tgt)]
    print(head(dat.kaka))


    # Generate DESeq dataset

    dds <- DESeqDataSetFromMatrix(countData = dat.kaka, colData = dat.tgt, design = ~ condition)

    dds[ rowSums(counts(dds)) > 1, ]
    dds <- dds[ rowSums(counts(dds)) > 1, ]
    dds$condition <- factor(dds$condition, levels=c("untreated","treated"))

    print(head(dds))

    # Run the analysis

    dds <- DESeq(dds)
    res <- results(dds)
    print(summary(res))

    # PlotMA

    plotMA(res, main="DESeq2")

    # plot Counts
    d<-plotCounts(dds, gene=which.min(res$padj), intgroup="condition")

    # csv output

    resOrdered <- res[order(res$padj),]
    write.csv(as.data.frame(resOrdered),
    file="condition_treated_results.csv")

    res
}


kaka.pathview <- function(res, col=2, pathway.id="00941", gene.idtype="TAIR", species="ath", out.suffix="what"){
    pkgBio("pathview")
    res$gene <- sub("\\.[0-9]","",rownames(res))
    res.pw <- res[!duplicated(res$gene), ]
    rownames(res.pw) <- res.pw$gene
    print(head(res.pw))

    res.pwana <- res.pw[,col]
    names(res.pwana) <- res.pw$gene
    print(pathway.id)

    pv.out <- pathview(gene.data = res.pwana,
                       pathway.id=pathway.id,
                       gene.idtype=gene.idtype,
                       species=species,
                       out.suffix=out.suffix)
}


