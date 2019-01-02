context("Testing predict_d18oc()")


fake_draw_dispenser <- function(a, b, tau) {
    out <- function(foram=NULL, seasonal_seatemp=FALSE){
                    data.frame(alpha = a, beta = b, tau = tau)
    }
    out
}


seeded_predict <- function(...) {
    set.seed(123)
    predict_d18oc(...)[["ensemble"]]
}


fake_draw_get_pooledannual <- fake_draw_dispenser(a=c(1), b=c(2), tau=c(3))
fake_draw_get_hierseasonal <- fake_draw_dispenser(a=c(1, 2), b=c(2, 2), tau=c(3, 3))


test_that("Basic tests for predict_d18oc()", {
    expect_equal(seeded_predict(seatemp = 15.0, d18osw = 0.0, drawsfun = fake_draw_get_pooledannual), 
                 matrix(29.04857, ncol = 1, nrow = 1), tolerance=1e-5, check.attributes = FALSE)
    expect_equal(seeded_predict(seatemp = 15.0, d18osw = 0.0, drawsfun = fake_draw_get_hierseasonal), 
                 matrix(c(29.04857, 31.03947), ncol = 2, nrow = 1), tolerance=1e-5, check.attributes = FALSE)
    expect_equal(seeded_predict(seatemp = c(15.0, 0), d18osw = 0.0, drawsfun = fake_draw_get_hierseasonal), 
                 matrix(c(29.04857306, 0.03946753, 36.406125, 1.941525), ncol = 2, nrow = 2), 
                 tolerance=1e-5, check.attributes = FALSE)
    expect_equal(seeded_predict(seatemp = c(15.0, 0), d18osw = c(0.0, 1.0), drawsfun = fake_draw_get_hierseasonal), 
                 matrix(c(29.048573, 1.039468, 36.406125, 2.941525), ncol = 2, nrow = 2), 
                 tolerance=1e-5, check.attributes = FALSE)
})
