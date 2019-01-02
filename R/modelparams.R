#' Parse trace dataframe column names to get vector of available forams.
#'
#' @param d Data frame containing MCMC trace draws. Column names are model 
#'parameters with foram group name separated from model parameters name by "__"
#'
#' @return Character vector of available foram names.
#'
get_available_forams <- function(d) {
    out = c()
    for (cname in names(d)) {
        if (grepl("__", cname)) {
            # Second member should be species name.
            foram <- strsplit(cname, "__")[[1]][-1]
            out <- unique(c(out, foram))
        }
    }
    out
}


#' Get MCMC trace draws.
#' 
#' @param foram Optional. String or \code{NULL}. String indicating the foram 
#'species/subspecies to infer for hierarchical models. String must be one of 
#'"G. bulloides", "G. ruber white", "G. ruber pink", "G. sacculifer", 
#'"N. incompta", or "N. pachyderma sinistral". \code{NULL} indicates that a 
#'pooled model is desired.
#' @param seasonal_seatemp Optional boolean indicating whether to use the seasonal 
#'sea-surface temperature calibrations. Default is \code{FALSE}, i.e. using 
#'annual SST calibrations.
#'
#' @details Four calibration models are available: an "annual pooled" model, a 
#' "seasonal pooled" model, an "annual hierarchical" model, and a 
#' "seasonal hierarchical" model. This function uses magic to determine which 
# calibration model you want based on the function arguments. By default, a 
#'"pooled annual" model is used. Which is the simplest case with potential use 
#'for Deep Time reconstructions of nonexant foram species. Giving a valid string 
#'for \code{foram} will use a hierarchical model, which has foram-specific 
#'variability in calibration model parameters. Passing \code{TRUE} for 
#'\code{seasonal_seatemp} will use a model trained on season sea-surface 
#'temperatures. See reference paper for further details.
#'
#' @return Data frame with columns "alpha", "beta", "tau". Which are equal-length 
#'vectors of model parameter draws.
#'
#' @export
get_draws <- function(foram=NULL, seasonal_seatemp=FALSE) {
    # Parse internal `traces` list to get the draws we want

    # This is kinda clunky. Maybe have traces as their own S3 class with generic method to get draws.
    draw_name <- NA

    time_half <- "annual"
    foram_half <- "hierarchical"
    if (is.null(foram))
        foram_half <- "pooled"
    if (seasonal_seatemp)
        time_half <- "seasonal"
    draw_name <- paste(time_half, foram_half, sep = "_")
    
    # We're drawing from `traces` which is internal package data.
    out <- data.frame(alpha=NA, beta=NA, tau=NA)
    if (is.null(foram)) {  # Pooled
        out <- data.frame(alpha = traces[[draw_name]][["a"]],
                          beta = traces[[draw_name]][["b"]],
                          tau = traces[[draw_name]][["tau"]])
    } else {  # Hierarchical
        # Check if foram name exists and give helpful error if it doesn't.
        available_foram_names <- get_available_forams(traces[[draw_name]])
        if (foram %in% available_foram_names) {
            out <- data.frame(alpha = traces[[draw_name]][[paste("a", foram, sep = "__")]],
                              beta = traces[[draw_name]][[paste("b", foram, sep = "__")]],
                              tau = traces[[draw_name]][[paste("tau", foram, sep = "__")]])
        } else {
            stop(paste0("Bad `foram`: ", foram, "\nAvailable forams are: ", 
                        toString(available_foram_names)))
        }
    }
    out
}
