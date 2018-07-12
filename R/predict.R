#' Constructor for S3 prediction class.
#'
#' @param ensemble A data.frame of the prediciton posterior.
#'
#' @return A \code{prediction} instance.
#'
#' @export
prediction <- function(ensemble) {
    structure(list("ensemble" = ensemble), class = "prediction")
}


#' Quantiles for a prediction.
#'
#' @export
quantile.fhx <- function(x, ...) {
    stop("Function not implemented.")
}


#' Predict δ18O of foram calcite given seawater temperature and seawater δ18O.
#'
#' @return A \code{prediction} instance.
#'
#' @export
predict_d18oc <- function(seatemp, d18osw, foram, seasonal_seatemp, drawsfun) {
    stop("Function not implemented.")
}


#' Predict sea-surface temperature given δ18O of calcite and seawater δ18O.
#'
#' @return A \code{prediction} instance.
#'
#' @export
predict_seatemp <- function(d18oc, d18osw, prior_mean, prior_std, foram, seasonal_seatemp, drawsfun) {
    stop("Function not implemented.")
}
