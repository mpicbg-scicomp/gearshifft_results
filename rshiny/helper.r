library(ggplot2)
library(readr)
library(plyr)
library(dplyr)
library(scales)

'%!in%' <- Negate('%in%')

## header with meta information about results
headers<-list()

create_key_value_list <- function(keys, values) {
    keys <- as.vector(keys)
    values <- as.vector(values)
    if(!is.null(dim(keys)) && dim(keys)[2]>1)
        keys <- t(keys)
    if(!is.null(dim(values)) && dim(values)[2]>1)
        values <- t(values)
    result <- trimws(gsub(";","",values))
    names(result) <- trimws(gsub(";","",keys))
    result <- as.list(result);
    return(result)

}

key_value_list_to_table <- function( input ) {
    result <- as.matrix( cbind(names(input), unlist(input)) )
    colnames(result) <- c("Key", "Value")
    return(result)
}

## cuda: 1 dev, 2|3, 4|5, ..
## fftw: 1|2, ..
## clfft: 2|3, 4|5, ..
get_gearshifft_header <- function(fname) {
    con <- file(fname,"r")
    first_line <- readLines(con,n=1)
    close(con)
    h <- read.csv(fname, sep=",", header=F, nrows=3)
    hidx <- 2*(1:(length( h[1,] )/2))

    if( grepl("ClFFT", first_line) ) {
        table1 <- create_key_value_list(h[1, hidx],
                                        h[1, hidx+1])
        table1$.library <- "clfft"
        if(grepl("CPU", table1$Device)) {
            table1$.arch <- "cpu"
        } else {
            table1$.arch <- "gpu" # assume GPU (todo: more meta data in results)
        }

    } else if( grepl("PlanRigor", first_line) ) {
        table1 <- create_key_value_list(cbind(V1="Device",h[1, hidx-1]),
                                        cbind(V1="CPU", h[1, hidx]))
        table1$.library <- "fftw"
        table1$.arch <- "cpu"
        if( grepl("taurusi", table1$Hostname) ) {
            ## identify device by hostname on taurus
            taurusi_no <- as.numeric(regmatches(table1$Hostname, regexpr("[0-9]+", table1$Hostname)))
            ## https://doc.zih.tu-dresden.de/hpc-wiki/bin/view/Compendium/SystemTaurus
            if(!is.null(taurusi_no) && taurusi_no>4000 && taurusi_no<=6612)
                table1$Device <- "Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz"
        }

    } else if( grepl("CUDA", first_line) ) {
        table1 <- create_key_value_list(cbind(V1="Device",h[1, hidx]),
                                        h[1, c(1,hidx+1)])
        table1$.library <- "cufft"
        table1$.arch <- "gpu"

    }
    else
        stop("Could not detect which FFT library is used.")

    table2 <- create_key_value_list(h[2:3,1], h[2:3,2])
    header <- list(table1=table1, table2=table2)
    return(header)
}

open_gearshifft_csv <- function (i,fnames,flabels){
    fname<-fnames[i]

    ## extracting header
    header <- get_gearshifft_header(fname)
    arch <- header$table1$.arch
    device <- header$table1$Device
    library <- header$table1$.library

    hardware <- device # paste0(device, " (", library, ")")
    if( arch=="cpu" && library=="clfft" )
        hardware <- paste0(device, " ", header$table1$UsedComputeUnits, "x (", library, ")")
    if( library=="fftw" ) {
        flags <- header$table1$PlanRigor
        hardware <- paste0(device, " ", header$table1$UsedThreads, "x (", library, " ", flags,")")
    }

    ## extracting measurements
    local_frame <- read_csv(fname,skip=3,col_names=TRUE)
    colnames(local_frame) <- gsub(' ','_',colnames(local_frame))
    local_frame$.file_id <- i

    ## assign header information to global variable
    headers[[i]] <<- header
    if("float16" %in% local_frame$precision) {
        headers[[i]]$float16 <<- T
    } else {
        headers[[i]]$float16 <<- F
    }

    local_frame = local_frame %>%
        mutate( n_elements = ifelse(dim==1,nx, ifelse(dim==2,nx*ny, nx*ny*nz)) )
    ## do not use %in% for ifelse here, otherwise mapping fails and nbytes are wrong due to "float16"
    local_frame = local_frame %>% mutate(
        nbytes = ifelse(complex=="Complex",2,1)*ifelse(precision=="float16",2,ifelse(precision=="double",8,4))*n_elements,
        hardware = hardware,
        architecture = arch)

    local_frame = local_frame %>% mutate( library = tolower(library))

    if(nchar(flabels[i])>0)
        local_frame$library <- flabels[i]
    else
        local_frame$library <- paste0(local_frame$library," (Data ",i,")")
    return(local_frame)
}

## this binds the data frames together
get_gearshifft_data <- function(fnames,flabels) {
    result <- ldply(seq_along(fnames), .fun=open_gearshifft_csv, fnames=fnames, flabels=flabels)
    return(result)
}

get_args_default <- function() {
    args <- list()
    args$inplace <- "Inplace"
    args$precision <- "float"
    args$complex <- "Real"
    args$kind <- "powerof2"
    args$dim <- "1"
    args$xmetric <- "nbytes"
    args$ymetric <-"Time_Total"
    args$xlabel <- "Signal_Size_[bytes]"
    args$ylabel <- ""
    args$notitle <- F
    args$speedup <- F
    return(args)
}

get_gearshifft_tables <- function(gearshifft_data, args) {
    filter_mode <- ""
    filter_prec <- ""
    filter_type <- ""
    filter_kind <- ""
    filter_dim  <- 0

    if(nchar(args$run)>0 && args$run == "-")
        filter_run <- c("Warmup", "Success")
    else
        filter_run <- args$run


    filtered_by <- c("success")

    if(nchar(args$inplace)>1){
        filter_mode <- args$inplace
    }

    if(nchar(args$precision)>1){
        filter_prec <- args$precision
    }

    if(nchar(args$complex)>1){
        filter_type <- args$complex
    }

    if(nchar(args$kind)>1){
        filter_kind <- args$kind
    }

    if(nchar(args$dim)>0 && args$dim!='-') {
        filter_dim <- as.integer(args$dim)
    }

    if(args$xmetric=='id')
        xlabel <- 'id'
    else if(args$xmetric=="nbytes")
        xlabel <- "Signal_Size_[bytes]"
    else if(args$xmetric=="n_elements")
        xlabel <- "Number_Elements"
    else
        xlabel <- args$xmetric

    if(grepl("Time", args$xmetric))
        xlabel <- paste0(args$xmetric,"_[ms]")

    if(grepl("/", args$ymetric))
        ylabel <- paste0(args$ymetric,"_[%]")
    else if(grepl("Time", args$ymetric))
        ylabel <- paste0(args$ymetric,"_[ms]")
    else if(grepl("Size", args$ymetric))
        ylabel <- paste0(args$ymetric,"_[bytes]")
    else if(grepl("Error", args$ymetric))
        ylabel <- args$ymetric
    if(args$speedup)
        ylabel <- paste("Speedup of", args$ymetric)

    succeeded <- gearshifft_data %>% filter(success == filter_run)

    if ( nchar(filter_mode) > 0){
        succeeded <- succeeded %>% filter(inplace == filter_mode)
        cat("filtered for inplace == ",filter_mode,": \t",nrow(succeeded),"\n")
        filtered_by <- c(filtered_by, filter_mode)
    }

    if ( nchar(filter_type) > 0 ){
        succeeded <- succeeded %>% filter(complex == filter_type)
        cat("filtered for complex == ",filter_type,": \t",nrow(succeeded),"\n")
        filtered_by <- c(filtered_by, filter_type)
    }

    if ( nchar(filter_prec) > 0){
        succeeded <- succeeded %>% filter(precision == filter_prec)
        cat("filtered for precision == ",filter_prec,": \t",nrow(succeeded),"\n")
        filtered_by <- c(filtered_by, filter_prec)
    }

    if (nchar(filter_kind) > 0 && "all" %!in% filter_kind){
        succeeded <- succeeded %>% filter(kind == filter_kind)
        cat("filtered for kind == ",filter_kind,": \t",nrow(succeeded),"\n")
        filtered_by <- c(filtered_by, filter_kind)
    }

    if ( filter_dim > 0){
        succeeded <- succeeded %>% filter(dim == filter_dim)
        cat("filtered for ndims == ",filter_dim,": \t",nrow(succeeded),"\n")
        filtered_by <- c(filtered_by, paste(filter_dim,"D",sep=""))
    }
    if( args$speedup && nchar(filter_prec)==0
       && length(headers)==2 && !any(headers[[1]]$float16, headers[[2]]$float16)) {
        succeeded <- succeeded %>% filter(precision != "float16")

    }
##############################################################################
    data_colnames = colnames(succeeded)

                                        # extracting ymetric expression
    ymetric_keywords = trimws(unlist(strsplit(args$ymetric,"[-|+|/|*|)|(]")))
    ymetric_expression = args$ymetric

                                        # creating expression
    for(i in 1:length(ymetric_keywords)) {

        indices = grep(ymetric_keywords[i],data_colnames)
        if( length(indices) > 0 && !is.null(ymetric_keywords[i]) && nchar(ymetric_keywords[i]) > 1){
            to_replace = paste("succeeded[,",indices[1],"]",sep="")
            cat(i,ymetric_keywords[i],"->",to_replace,"in",ymetric_expression,"\n")
            ymetric_expression = gsub(ymetric_keywords[i],to_replace,
                                      ymetric_expression)
        }
    }


                                        # creating metric of interest (moi)
    new_values = as.data.frame(eval(parse(text=ymetric_expression)))
    colnames(new_values) <- c("ymoi")

    name_of_ymetric = args$ymetric

    if( length(ymetric_keywords) == 1  ){
        name_of_ymetric = data_colnames[grep(ymetric_keywords[1], data_colnames)[1]]
    }

    if(!is.null(ylabel)) {

        if( nchar(ylabel) > 1){
            name_of_ymetric = gsub("_"," ",ylabel)
        }
    }
    cat("[ylabel] using ylabel: ",name_of_ymetric,"\n")

    succeeded_ymetric_of_interest  = new_values
################################################################################

##############################################################################
                                        # extracting xmetric expression
    if(!any(grepl(paste0("^",args$xmetric),data_colnames))){

        stop(paste(args$xmetric, "for x not found in available columns \n",data_colnames,"\n"))
    }


    succeeded_xmetric_of_interest  <- succeeded[grepl(paste0("^",args$xmetric),data_colnames)]
    name_of_xmetric <- colnames(succeeded_xmetric_of_interest)[1]
    if(!is.null(xlabel)) {

        if( nchar(xlabel) > 1){
            name_of_xmetric = xlabel
        }
    }
    colnames(succeeded_xmetric_of_interest) <- c("xmoi")
    succeeded_factors <- succeeded %>% select(-ends_with("]"))

    succeeded_reduced <- bind_cols(succeeded_factors,
                                   succeeded_xmetric_of_interest,
                                   succeeded_ymetric_of_interest)

    if( grepl("bytes",name_of_xmetric)  ) {
        succeeded_reduced$xmoi <- succeeded_reduced$xmoi / (1024.*1024.)
        name_of_xmetric <- gsub("bytes","MiB",name_of_xmetric)
    }

    if( grepl("bytes",name_of_ymetric) ){
        succeeded_reduced$ymoi <- succeeded_reduced$ymoi / (1024*1024)
        name_of_ymetric <- gsub("bytes","MiB",name_of_ymetric)
    }


    cols_to_consider <- Filter(function(i){ !(i %in% filtered_by || i == "id" || i == "run") },c(colnames(succeeded_factors),"xmoi"))
    cols_to_grp_by <- lapply(c(cols_to_consider,"id"), as.symbol)

    data_for_plotting <- succeeded_reduced %>%
        group_by_(.dots = cols_to_grp_by) %>%
        ##group_by(library, hardware, id, nx, ny, nz, xmoi) %>%
        summarize( moi_mean = mean(ymoi),
                  moi_median = median(ymoi),
                  moi_stddev = sd(ymoi),
                  moi_quantile25 = quantile(ymoi,.25),
                  moi_quantile75 = quantile(ymoi,.75)
                  )

#### data2$y(x)/data1$y(x)
    if(args$speedup) {
        d1 <- filter(data_for_plotting, .file_id==1)
        d2 <- filter(data_for_plotting, .file_id==2)
        if(nrow(d2)>0) {
            x <- as.vector(intersect( d1$xmoi, d2$xmoi ))
            d1 <- d1[ d1$xmoi %in% x, ]
            d2 <- d2[ d2$xmoi %in% x, ]
            dfp <- d1
            dfp$moi_mean <- d2$moi_mean / dfp$moi_mean
            dfp$moi_median <- d2$moi_median / dfp$moi_median
            dfp$moi_stddev <- 0
            dfp$moi_quantile25 <- 0
            dfp$moi_quantile75 <- 0
            d2$moi_mean <- 1
            d2$moi_median <- 1
            d2$moi_stddev <- 0
            d2$moi_quantile25 <- 0
            d2$moi_quantile75 <- 0
            data_for_plotting <- bind_rows(dfp,d2) %>% na.omit()
        }
    }

    tables <- list()
    tables$raw <- succeeded_reduced
    tables$reduced <- data_for_plotting
    tables$name_of_xmetric <- name_of_xmetric
    tables$name_of_ymetric <- name_of_ymetric
    if(!args$notitle) {
        tables$hardware <- succeeded_reduced %>% distinct(hardware) %>% pull()
        tables$hardware <- paste0(tables$hardware, collapse=" vs. ")

        tables$title <- paste("Filtered by:",paste(filtered_by,collapse=", "))
        tables$title <- paste(tables$hardware, "|", tables$title)
    } else {
        tables$title <- ""
    }

#    tables <- data_for_plotting[c('id','xmoi','moi_mean','moi_median','moi_stddev')]
    return(tables)
}

plot_gearshifft <- function(tables,
                            aesthetics="hardware,kind,library",
                            usepoints=T,
                            visualization="median+quartiles",
                            nolegend=F,
                            usepointsraw=F,
                            freqpoly=F,
                            bins=200,
                            xlimit="",
                            ylimit="",
                            logx="-",
                            logy="-",
                            speedup=F
                            ) {
    succeeded_reduced <- tables$raw
    data_for_plotting <- tables$reduced
    name_of_xmetric <- tables$name_of_xmetric
    name_of_ymetric <- tables$name_of_ymetric
    vis_median <- grepl("median",visualization)
    vis_bars <- grepl("\\+",visualization) && !freqpoly && !usepointsraw && !speedup
    moi_vis <- ifelse(vis_median,"moi_median","moi_mean")
    tables$title <- paste(tables$title, "|", visualization)

    my_theme <-  theme_bw() + theme(axis.title.x = element_text(size=18),
                                    axis.title.y = element_text(size=18),
                                    axis.text.x = element_text(size=14),
                                    axis.text.y = element_text(size=14)#,
                                        #axis.text.x  = element_text()
                                   ,plot.margin = unit(c(8,10,1,1), "pt") # required otherwise labels are clipped in pdf output
                                    )
    my_theme <- my_theme + theme(legend.title = element_blank(),#legend.title = element_text(size=16, face="bold"),
                                 legend.text = element_text( size = 16),
                                 legend.position="bottom",
                                 legend.direction="vertical",
                                 legend.box ="horizontal",
                                 legend.box.just ="bottom",
                                 legend.background = element_rect(colour = 'white', fill = 'white', size = 0., linetype='dashed'),
                                 legend.key = element_rect(colour = 'white', fill = 'white', size = 0., linetype='dashed'),
                                 legend.key.width = unit(1.1, "cm")
                                 )

    ## if(nchar(tables$label)>0)
    ##     aesthetics <- sub("library", "label", aesthetics)
##    cat(aesthetics)
    aesthetics_from_cli <- strsplit(aesthetics,",")[[1]]

    aesthetics_keys   <- c("colour","linetype","shape")
    aesthetics_to_use <- aes(x=xmoi)
    aesthetics_length <- length(aesthetics_from_cli)
    n_items_per_aesthetics = c()
    counter = 1

    for(i in 1:length(aesthetics_keys)) {

        if( i <= aesthetics_length ){
            ## current_levels = eval(parse(text=paste("levels(as.factor(data_for_plotting$",
            ##                                 aesthetics_from_cli[i],"))",
            ##                                 sep="")))
            data_for_plotting[[ aesthetics_from_cli[i] ]] <- as.factor(data_for_plotting[[ aesthetics_from_cli[i] ]])
            succeeded_reduced[[ aesthetics_from_cli[i] ]] <- as.factor(succeeded_reduced[[ aesthetics_from_cli[i] ]])

            current_levels <- levels(data_for_plotting[[ aesthetics_from_cli[i] ]])

            n_items_per_aesthetics[counter] = length(current_levels)
            counter = counter + 1
            aesthetics_to_use[[aesthetics_keys[i]]] <- as.symbol(aesthetics_from_cli[i])
        }
    }

    if(freqpoly) {
        moi_plot <- ggplot(succeeded_reduced, aesthetics_to_use)
        moi_plot <- moi_plot + geom_freqpoly(bins=bins,size=1)
        name_of_ymetric <- "Frequency"
    } else if ( usepointsraw ) {
        ## cols_to_consider <- Filter(function(i){ !(i %in% filtered_by || i == "id" || i == "run") },c(colnames(succeeded_factors)))
        ## cols_to_grp_by <- lapply(c(cols_to_consider,"library"), as.symbol)
        ## cfs <- succeeded_reduced %>%
        ##     group_by_(.dots = cols_to_grp_by) %>%
        ##     summarize(moi_cf_a = t.test(ymoi)$conf.int[1],
        ##               moi_cf_b = t.test(ymoi)$conf.int[2]
        ##               )
        ## glimpse(cfs)
        ##    moi_plot <- ggplot(data_for_plotting, aesthetics_to_use)
        ##    moi_plot <- moi_plot + geom_point(aes(y=moi_mean),size=0.3,alpha=0.4)
        moi_plot <- ggplot(succeeded_reduced, aesthetics_to_use)
        ## moi_plot <- moi_plot + geom_hline(data=cfs,aes(yintercept=moi_cf_a,colour=library),alpha=1)
        ## moi_plot <- moi_plot + geom_hline(data=cfs,aes(yintercept=moi_cf_b,colour=library),alpha=1)
        moi_plot <- moi_plot + geom_point(aes(y=ymoi),size=0.5,alpha=1)
        ##    moi_plot <- moi_plot + geom_line(aes(y=moi_mean),size=.8)
        moi_plot <- moi_plot + scale_linetype_manual(values = c("solid","dotted","longdash")) + theme_bw()
    } else {
        aesthetics_to_use
        moi_plot <- ggplot(data_for_plotting, ## aes(x=xmoi,
                           ##     #y=mean_elapsed_sec,
                           ##     color=library,
                           ##     linetype=hardware)
                           aesthetics_to_use
                           )
        moi_plot <- moi_plot + geom_line(aes_string(y=moi_vis),size=1)
        if( usepoints ) {
            moi_plot <- moi_plot + geom_point(aes_string(y=moi_vis),size=3)
        }
        if( vis_bars && vis_median ) {
            moi_plot <- moi_plot + geom_errorbar(aes(ymin = moi_quantile25,
                                                     ymax = moi_quantile75),
                                                 width=0.25, linetype =1)
        } else if(vis_bars && !vis_median) {
            moi_plot <- moi_plot + geom_errorbar(aes(ymin = moi_mean - moi_stddev,
                                                     ymax = moi_mean + moi_stddev),
                                                 width=0.25, linetype =1)
        }
        moi_plot <- moi_plot + scale_linetype_manual(values = c("solid","dotted","longdash")) #2,3,5,4,22,33,55,44))
    }

    ##

    moi_plot <- moi_plot + ylab(gsub("_"," ",name_of_ymetric)) + xlab(gsub("_"," ",name_of_xmetric))
    moi_plot <- moi_plot + my_theme

    if(nchar(tables$title)>1)
        moi_plot <- moi_plot + ggtitle(tables$title)

    str_to_numeric = function( string, sep ) {

        splitted = unlist(strsplit(string,sep))
        vec = sapply(splitted, function(x) as.numeric(x))
        return(vec)
    }

    ## ylimit_splitted = unlist(strsplit(opts[["ylimit"]],","))
    ## ylimit_pair = sapply(ylimit_splitted, function(x) as.numeric(x))
    ylimit_pair = str_to_numeric(ylimit, ",")
    xlimit_pair = str_to_numeric(xlimit, ",")

    if( length(ylimit_pair) == 2 ) {
        if(ylimit_pair[1] != 0 || ylimit_pair[2]!=0){
            cat("[ylimit] setting to ",paste(ylimit_pair),"\n")
            moi_plot <- moi_plot + ylim(ylimit_pair[1],ylimit_pair[2])
        }
    }

    if( length(xlimit_pair) == 2 ) {
        if(xlimit_pair[1] != 0 || xlimit_pair[2]!=0){
            cat("[xlimit] setting to ",paste(xlimit_pair),"\n")
            moi_plot <- moi_plot + xlim(xlimit_pair[1],xlimit_pair[2])
        }
    }


    if(nolegend){
        moi_plot <- moi_plot + theme(legend.position="none")
    }

    logx_value <- 1
    logy_value <- 1
    if(logx!="-")
        logx_value <- as.integer(logx)
    if(logy!="-")
        logy_value <- as.integer(logy)

    xmin <- min(data_for_plotting$xmoi)
    xmax <- max(data_for_plotting$xmoi)

    ymin <- min(data_for_plotting[[moi_vis]])
    ymax <- max(data_for_plotting[[moi_vis]])


    if(logy_value > 1) {

        breaks_y = function(x) logy_value^x
        format_expr_y = eval(parse(text=paste("math_format(",logy_value,"^.x)",sep="")))

        if(length(ylimit_pair) == 2 && (ylimit_pair[1] != 0 && ylimit_pair[2]!=0)){
            scale_structure = scale_y_continuous(
                limits = ylimit_pair,
                trans = log_trans(base=logy_value),
                breaks = trans_breaks(paste("log",logy_value,sep=""), breaks_y),
                labels = trans_format(paste("log",logy_value,sep=""), format_expr_y))
        } else {
            scale_structure = scale_y_continuous(
                trans = log_trans(base=logy_value),
                breaks = trans_breaks(paste("log",logy_value,sep=""), breaks_y),
                labels = trans_format(paste("log",logy_value,sep=""), format_expr_y))

        }

        moi_plot <- moi_plot + scale_structure
    }



    if(logx_value > 1) {

        breaks_x = function(x) logx_value^x
        format_expr_x = eval(parse(text=paste("math_format(",logx_value,"^.x)",sep="")))
        if(length(xlimit_pair) == 2 && (xlimit_pair[1] != 0 && xlimit_pair[2]!=0)){
            scale_x_structure = scale_x_continuous(
                limits = xlimit_pair,
                trans = log_trans(base=logx_value),
                breaks = trans_breaks(paste("log",logx_value,sep=""), breaks_x),
                labels = trans_format(paste("log",logx_value,sep=""), format_expr_x)
            )
        } else {
            scale_x_structure = scale_x_continuous(
                trans = log_trans(base=logx_value),
                breaks = trans_breaks(paste("log",logx_value,sep=""), breaks_x),
                labels = trans_format(paste("log",logx_value,sep=""), format_expr_x)
            )

        }

        moi_plot <- moi_plot + scale_x_structure
    }


    return(moi_plot)
}
