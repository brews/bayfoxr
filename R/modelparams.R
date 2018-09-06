#' Get MCMC trace draws.
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
