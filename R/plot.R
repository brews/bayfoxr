
#' Simple plot of \code{prediction} with intervals.
#'
#' @param y A \code{prediction} object to plot.
#' @param x Optional vector or NULL, indicating were \code{prediction} 
#'inferences fall along x-axis. Must be the same length as the inferred values 
#' in \code{y}.
#' @param probs Optional 3-member Vector of numerics indicating low, middle, and 
#'high probability intervals to plot. All must be <= 1.
#' @param poly_col Optional color for interval polygon.
#' @param ... Additional arguments passed to \code{plot}.
#'
#' @examples
#' data(bassriver)
#' 
#' # Using the "pooled annual" calibration model:
#' sst <- predict_seatemp(bassriver$d18o, d18osw=0.0, 
#'                        prior_mean=30.0, prior_std=20.0)
#' 
#' predictplot(x=bassriver$depth, y=sst, ylim=c(20, 40), 
#'             ylab="SST (°C)", xlab="Depth (m)")
#'
#' @export
predictplot <- function(y, x = NULL, probs = c(0.05, 0.50, 0.95), 
                        poly_col = grDevices::rgb(0, 0, 0, 0.1), ...) {
    if (length(probs) != 3) {
        stop("Length of `probs` must be 3")
    }
    if (max(probs) > 1) {
        stop("`probs` must all be <= 1")
    }

    probs <- sort(probs)
    quants <- quantile(y, probs=probs)
    y_low <- quants[, 1]
    y_mid <- quants[, 2]
    y_high <- quants[, 3]

    if (is.null(x)) {
        n_row <- nrow(y$ensemble)
        x <- seq(1, n_row)
    }
    
    graphics::plot(x = x, y = y_mid, type='b', ...)
    graphics::polygon(c(x, rev(x)), c(y_low, rev(y_high)), col = poly_col, 
                        border = NA)
}


#' Plot a \code{prediction} object.
#'
#' @param ... Arguments passed on to \code{predictplot}.
#'
#' @seealso \code{\link{predictplot}}
#'
#' @examples
#' data(bassriver)
#' 
#' # Using the "pooled annual" calibration model:
#' sst <- predict_seatemp(bassriver$d18o, d18osw=0.0, 
#'                        prior_mean=30.0, prior_std=20.0)
#' 
#' predictplot(x=bassriver$depth, y=sst, ylim=c(20, 40), 
#'             ylab="SST (°C)", xlab="Depth (m)")
#'
#' @export
plot.prediction <- function(...) {
    predictplot(...)
}
