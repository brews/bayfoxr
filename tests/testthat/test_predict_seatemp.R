context("Testing predict_seatemp()")


fake_draw_dispenser <- function(a, b, tau) {
    out <- function(foram=NULL, seasonal_seatemp=FALSE){
        list(alpha = a, beta = b, tau = tau)
    }
    out
}


seeded_predict <- function(...) {
    set.seed(123)
    predict_seatemp(prior_mean = 15, prior_std = 20, ...)[["ensemble"]]
}


fake_draw_get_pooledannual <- fake_draw_dispenser(a=c(1), b=c(2), tau=c(3))
fake_draw_get_hierseasonal <- fake_draw_dispenser(a=c(1, 2), b=c(2, 2), tau=c(3, 3))


test_that("Basic tests for predict_seatemp()", {
    expect_equal(seeded_predict(d18oc = -3.75, d18osw = 0.0, drawsfun = fake_draw_get_pooledannual), 
                 matrix(-2.981926, ncol = 1, nrow = 1), tolerance=1e-5, check.attributes = FALSE)
    expect_equal(seeded_predict(d18oc = -3.75, d18osw = 0.0, drawsfun = fake_draw_get_hierseasonal), 
                 matrix(c(-2.981926, -2.98507), ncol = 2, nrow = 1), tolerance=1e-5, check.attributes = FALSE)
    expect_equal(seeded_predict(d18oc = c(-3.75, 0), d18osw = 0.0, drawsfun = fake_draw_get_hierseasonal), 
                 matrix(c(-2.9819263, -0.6233546, -0.3092564, -0.6707922), ncol = 2, nrow = 2), 
                 tolerance=1e-5, check.attributes = FALSE)
    expect_equal(seeded_predict(d18oc = c(-3.75, 0), d18osw = c(0.0, 1.0), drawsfun = fake_draw_get_hierseasonal), 
                 matrix(c(-2.981926, -1.120558, -0.3092564, -1.1679954), ncol = 2, nrow = 2), 
                 tolerance=1e-5, check.attributes = FALSE)
})
