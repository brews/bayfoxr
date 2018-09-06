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
#' @return List with members "alpha", "beta", "tau". Which are equal-length 
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
    
    traces[[draw_name]]
    out <- list()
    if (is.null(foram)) {  # Pooled
        out["alpha"] <- traces[[draw_name]]["a"]
        out["beta"] <- traces[[draw_name]]["b"]
        out["tau"] <- traces[[draw_name]]["tau"]
    } else {  # Hierarchical
        out["alpha"] <- traces[[draw_name]][paste("a", foram, sep = "__")]
        out["beta"] <- traces[[draw_name]][paste("b", foram, sep = "__")]
        out["tau"] <- traces[[draw_name]][paste("tau", foram, sep = "__")]
    }
    out
}
