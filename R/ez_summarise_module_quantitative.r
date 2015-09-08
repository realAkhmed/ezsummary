#' Simple Summary for Quantitative/binary variables
#'
#' @description Function ez_summarise_quantitative provides simple summary (Mean and
#' standard deviation with/without N) for quantitative data while function ez_summarise_binary
#' provides simple summary (freq and percentage with/without total counts) for binary data.
#' These two function are simply wrappers outside of a summarise_each function. If
#' we just want to know the most basic statistical summary, this function can save us some
#' typing time. It also provide the option to include number of subjects inside the analyses.
#'
#' @param tbl The input matrix of data you would like to analyze.
#' @param n n is a True/False switch that controls whether counts(N) should be included in
#' the output
#' @param round.N Rounding Number
#'
#' @return It will return in the same format as a summarise_each function does
#'
#' @examples
#' mtcars %>% group_by(am) %>% select(mpg, wt, qsec) %>% ez_summarise_quantitative()
#'
#' @export
ez_summarise_quantitative <- function(tbl, n = FALSE, mean = TRUE, sd = TRUE, sem = FALSE, median = FALSE, quantile = FALSE, round.N=3){
  # If the input tbl is a vector, convert it to a 1-D data.frame and set it as a 'tbl' (dplyr).
  if(is.vector(tbl)){
    tbl <- as.tbl(as.data.frame(tbl))
    attributes(tbl)$names <- "unknown"
    warning("ezsummary cannot detect the naming information from an atomic vector. Please try to use something like 'select(mtcars, gear)' to replace mtcars$gear in your code.")
  }

  # Try to obtain grouping and variable information from the input tbl
  group.name <- attributes(tbl)$vars
  var.name <- attributes(tbl)$names
  if (!is.null(group.name)){
    group.name <- as.character(group.name)
    var.name <- var.name[!var.name %in% group.name]
    }
  n.group <- length(group.name)
  n.var <- length(var.name)

  # Set up the summarise_each formula based on the input.
  options <- c("N = length(na.omit(.))", "mean = round(mean(na.omit(.)), round.N)", "sd = round(sd(na.omit(.)), round.N)", "sem = round(sd(na.omit(.)) / sqrt(length(na.omit(.))), round.N)", "median = median(na.omit(.))", "q0 = quantile(.,names = F)[1], q25 = quantile(.,names = F)[2], q50 = quantile(.,names = F)[3], q75 = quantile(.,names = F)[4], q100 = quantile(.,names = F)[5]")
  option_names <- c("N", "mean", "sd", "sem", "median", "q0", "q25", "q50", "q75", "q100")
  option_switches <- c(n, mean, sd, sem, median, quantile)
  option_name_switches <- c(n, mean, sd, sem, median, quantile, quantile, quantile, quantile, quantile)
  calculation_formula <- paste0("summarise_each(tbl, funs(",
                                paste0(options[option_switches],collapse = ", "),
                                "))")

  # Perform the summarise_each calculation and pass the results to table_raw
  table_raw <- eval(parse(text=calculation_formula))

  # Standardize names when either n.var or the number of statistical analyses is small
    # When there is only one analysis (except(quantile))
    if (sum(option_name_switches) == 1){names(table_raw)[(n.group+1):ncol(table_raw)] <- paste(names(table_raw)[(n.group+1):ncol(table_raw)], option_names[option_name_switches], sep="_")}
    # When there is only one variable but the number of analyses is not 1
    if (n.var == 1 & sum(option_name_switches) != 1){names(table_raw)[(n.group+1):ncol(table_raw)] <- paste(var.name, names(table_raw)[(n.group+1):ncol(table_raw)], sep="_")}

  # Transform the raw table to a organized tabular output
  table_export <- melt(table_raw, id.vars = group.name) %>%
    separate(variable, into = c("variable", "statistics"), sep="_(?=[^_]*$)")
  # I have to stop in the middle and provide sort information to 'statistics' as
  # the dplyr::dcast function will automaticall sort all the values
  table_export$statistics <- factor(table_export$statistics, levels = c("N", "mean", "sd", "sem", "median", "q0", "q25", "q50", "q75", "q100"))

  # Use dplyr::dcast to reformat the table
  dcast_formula <- as.formula(paste0(c(group.name, "variable ~ statistics"), collapse = " + "))
  table_export <- table_export %>% dcast(dcast_formula)

  # Fix the sorting of variable
  table_export$variable <- factor(table_export$variable, levels = var.name)
  table_export <- arrange(table_export, variable)

#   if(n.group == 0){
#     table_export <- data.frame(x = rep(names(tbl)[(n.group + 1):(n.group + n.var)], rep(1, n.var)))
#   }else{
#     tbl_order <- 1:(n.group + n.var)
#     tbl_order <- c(which(names(tbl) %in% attributes(tbl)$vars), tbl_order[!tbl_order %in% which(names(tbl) %in% attributes(tbl)$vars)])
#     tbl <- tbl[,tbl_order]
#     table_export <- data.frame(x = rep(names(tbl)[(n.group + 1):(n.group + n.var)], rep((length(attributes(tbl)$group_sizes)), n.var)))}
#   # generate table_raw from summarise_each based on switches; Apply round.N
#   if (n == F) {table_raw <- summarise_each(tbl, funs(mean = round(mean(na.omit(.)), round.N), sd = round(sd(na.omit(.)), round.N)))
#   }else{
#     table_raw <- summarise_each(tbl, funs(N = length(na.omit(.)), mean = round(mean(na.omit(.)), round.N), sd = round(sd(na.omit(.)), round.N)))
#     for(i in 1:(n.var * (nrow(table_raw)))){table_export$N[i] = table_raw[(i - nrow(table_raw) * (ceiling(i/nrow(table_raw))-1)),(n.group + ceiling(i/nrow(table_raw)))]}
#   }
#   # Fix the default naming when n.var == 1
#   # if (n.var == 1) {names(table_raw)[(n.group + 1):ncol(table_raw)] <- paste(names(tbl)[(n.group + 1)], names(table_raw)[(n.group + 1):ncol(table_raw)], sep = "_")}
#   for(i in 1:(n.var * (nrow(table_raw)))){table_export$mean[i] = table_raw[(i - nrow(table_raw) * (ceiling(i/nrow(table_raw))-1)), (n.group + ceiling(i/nrow(table_raw)) + n.var * n)]}
#   for(i in 1:(n.var * (nrow(table_raw)))){table_export$sd[i] = table_raw[(i - nrow(table_raw) * (ceiling(i/nrow(table_raw))-1)), (n.group + ceiling(i/nrow(table_raw)) + n.var * n + n.var)]}
#
#   if(n.group != 0) {table_export <- cbind(table_raw[rep(1:nrow(table_raw), times = n.var),1:n.group], table_export)}
  attributes(table_export)$vars <- group.name
  attributes(table_export)$n.group <- n.group
  attributes(table_export)$n.var <- n.var
  return(table_export)
}

