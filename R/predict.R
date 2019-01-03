#' Constructor for S3 prediction class.
#'
#' @param ensemble A matrix (m x n) of the prediciton posteriors. Where m is the 
#'number of values inferred and n is the number of trace draws.
#'
#' @return A \code{prediction} object.
#'
#' @export
prediction <- function(ensemble) {
    out <- structure(list(), class = "prediction")
    out[["ensemble"]] <- as.matrix(ensemble)
    out
}


#' Quantiles for a \code{prediction}.
#'
#' @param x A \code{prediction} object.
#' @param ... Arguments to be passed on to \code{quantile}.
#'
#' @importFrom stats quantile
#' @export
quantile.prediction <- function(x, ...) {
    t(apply(X=x[["ensemble"]], MARGIN=1, FUN=quantile, ...))
}


#' Predict d18O of foram calcite given seawater temperature and seawater d18O.
#'
#' @param seatemp Numeric or vector of observed sea-surface temperatures (°C).
#' @param d18osw Numeric or vector of observed seawater d18O (‰ VSMOW). 
#' @param foram Optional. String or \code{NULL}. String indicating the foram 
#'species/subspecies to infer for hierarchical models. String must be one of 
#'"G. bulloides", "G. ruber", "T. sacculifer", "N. incompta", or 
#'"N. pachyderma". \code{NULL} indicates that a pooled model is desired.
#' @param seasonal_seatemp Optional boolean indicating whether to use the seasonal 
#'sea-surface temperature calibrations. Default is \code{FALSE}, i.e. using 
#'annual SST calibrations.
#' @param drawsfun Optional function used to get get model parameter draws. Must 
#'take arguments for "foram" and "seasonal_seatemp" and return a list with 
#'members "alpha", "beta", "tau". This is for debugging and testing. See 
#'\code{\link{get_draws}}.
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
#' @return A \code{prediction} instance for inferred foraminiferal calcite 
#'d18O (‰ VPDB).
#'
#' @seealso \code{\link{predict_seatemp}}, \code{\link{predictplot}}
#'
#' @examples
#' # Infer d18Oc for a G. bulloides core top sample using annual hierarchical model.
#' # The true, d18Oc for this sample is -2.16 (‰ VPDB).
#' delo_ann <- predict_d18oc(seatemp=28.6, d18osw=0.48, foram="G. bulloides")
#' head(quantile(delo_ann, probs=c(0.159, 0.5, 0.841)))  # ± 1 standard deviation
#'
#' # Now using seasonal hierarchical model:
#' delo_sea <- predict_d18oc(seatemp=28.6, d18osw=0.48, foram="G. bulloides",
#'                           seasonal_seatemp = TRUE)
#' head(quantile(delo_sea, probs=c(0.159, 0.5, 0.841)))  # ± 1 standard deviation
#'
#' @export
predict_d18oc <- function(seatemp, d18osw, foram=NULL, seasonal_seatemp=FALSE, 
                          drawsfun=get_draws) {
    params <- drawsfun(foram = foram, seasonal_seatemp = seasonal_seatemp)
    alpha <- params[["alpha"]]
    beta <- params[["beta"]]
    tau <- params[["tau"]]

    nd <- length(seatemp)
    n_draws = length(tau)

    # Unit adjustment
    d18osw_adj <- d18osw - 0.27

    # TODO(brews): Vectorize the loop below.
    y <- matrix(nrow = length(seatemp), ncol = n_draws)
    for (i in seq(n_draws)) {
        y[, i] = stats::rnorm(n = nd, 
                              mean = alpha[i] + seatemp * beta[i] + d18osw_adj, 
                              sd = tau[i])
    }

    prediction(ensemble = y)
}


#' Predict sea-surface temperature given d18O of foram calcite and seawater d18O.
#'
#' @param d18oc Numeric or vector of observed foram calcite d18O (‰ VPDB).
#' @param d18osw Numeric or vector of observed seawater d18O (‰ VSMOW).
#' @param prior_mean Numeric indicating prior mean for sea-surface temperature (°C).
#' @param prior_std Numeric indicating prior standard deviation for sea-surface 
#'temperature (°C).
#' @param foram Optional. String or \code{NULL}. String indicating the foram 
#'species/subspecies to infer for hierarchical models. String must be one of 
#'"G. bulloides", "G. ruber", "T. sacculifer", "N. incompta", or 
#'"N. pachyderma". \code{NULL} indicates that a pooled model is desired.
#' @param seasonal_seatemp Optional boolean indicating whether to use the seasonal 
#'sea-surface temperature calibrations. Default is \code{FALSE}, i.e. using 
#'annual SST calibrations.
#' @param drawsfun Optional function used to get get model parameter draws. Must 
#'take arguments for "foram" and "seasonal_seatemp" and return a list with 
#'members "alpha", "beta", "tau". This is for debugging and testing.
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
#' @return A \code{prediction} instance for inferred sea-surface temperature (°C).
#'
#' @seealso \code{\link{predict_d18oc}}
#'
#' @examples
#' data(bassriver)
#' 
#' # Using the "pooled annual" calibration model:
#' sst <- predict_seatemp(bassriver$d18o, d18osw=0.0, 
#'                        prior_mean=30.0, prior_std=20.0)
#' head(quantile(sst))  # Show only the top few values
#' 
#' predictplot(x=bassriver$depth, y=sst, ylim=c(20, 40), 
#'             ylab="SST (°C)", xlab="Depth (m)")
#'
#' @export
predict_seatemp <- function(d18oc, d18osw, prior_mean, prior_std, foram=NULL, 
                            seasonal_seatemp=FALSE, drawsfun=get_draws) {
    params <- drawsfun(foram = foram, seasonal_seatemp = seasonal_seatemp)
    alpha <- params[["alpha"]]
    beta <- params[["beta"]]
    tau <- params[["tau"]]

    nd <- length(d18oc)
    n_draws <- length(tau)

    # Unit adjustment
    d18osw_adj <- d18osw - 0.27

    # Prior mean and inverse covariance matrix
    pmu <- matrix(prior_mean, nrow = nd)
    pinv_cov <- diag(prior_std ^ (-2), nrow = nd)

    # TODO(brews): Vectorize the loop below.
    y <- matrix(nrow = length(d18oc), ncol = n_draws)
    for (i in seq(n_draws)) {
        y[, i] <- target_timeseries_pred(d18osw_now=d18osw_adj, 
                                         alpha_now=alpha[i],
                                         beta_now=beta[i], tau_now=tau[i],
                                         proxy_ts=d18oc, prior_mu=pmu,
                                         prior_inv_cov=pinv_cov)
    }

    prediction(ensemble = y)
}


#' Internal function for `predict_seatemp()`.
#'
#' @param d18osw_now Numeric or vector giving seawater d18O. Note, should be in 
#' units (‰ VPDB).
#' @param alpha_now Numeric, alpha model parameter.
#' @param beta_now Numeric, beta model parameter.
#' @param tau_now Numeric, tau model parameter.
#' @param proxy_ts Numeric or vector of proxy time series (foram d18O).
#' @param prior_mu Matrix (n X 1) giving prior mean.
#' @param prior_inv_cov Matrix (n X x) giving prior inverse covariance matrix.
#'
#' @return Sample of time time series vector conditional on the other args
#'
target_timeseries_pred <- function(d18osw_now, alpha_now, beta_now, tau_now, 
                                   proxy_ts, prior_mu, prior_inv_cov) {
    n_ts = length(proxy_ts)

    # Inverse posterior covariance matrix
    precision <- tau_now ^ (-2)
    post_inv_cov <- prior_inv_cov + precision * beta_now ^ 2 * diag(1, n_ts)

    post_cov <- solve(post_inv_cov)   # Inverse.

    # Get first factor for the mean
    mean_first_factor <- (prior_inv_cov %*% prior_mu + precision * beta_now 
                          * (proxy_ts - alpha_now - d18osw_now))
    mean_full <- t(mean_first_factor) %*% post_cov

    stats::rnorm(n = n_ts, mean = mean_full, sd = sqrt(diag(post_cov)))
}
