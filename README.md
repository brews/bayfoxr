# bayfoxr

[![Travis-CI Build Status](https://travis-ci.org/brews/bayfoxr.svg?branch=master)](https://travis-ci.org/brews/bayfoxr)
[![Coverage Status](https://coveralls.io/repos/github/brews/bayfoxr/badge.svg?branch=master)](https://coveralls.io/github/brews/bayfoxr?branch=master)

A Bayesian, global planktic foraminifera core top calibration to sea-surface temperature (SST), for R.

## What is bayfoxr?

bayfoxr is a suite of linear Bayesian calibration models for planktic core top foraminiferal δ18O (δ18Oc) and SSTs. These calibrations are especially useful because they capture the uncertainty in the relationship between modern SSTs and core top δ18Oc. This package is a companion to a paper currently under preparation for the journal "Paleoceanography and Paleoclimatology".

## A quick example

```R
library(bayfoxr)

data(bassriver)
```

The `bassriver` is example data that comes with the package. It is marine core samples from [John et al. (2008)](https://doi.org/10.1029/2007PA001465). The data.frame has two columns: "depth", giving down-core depth in meters, and "d18o", foraminifera (*Morozovella spp.*) calcite d18O samples (‰ VPDB). The core samples cover the [Paleocene-Eocene thermal maximum (PETM)](https://en.wikipedia.org/wiki/Paleocene%E2%80%93Eocene_Thermal_Maximum).

Let's run this data through our annual pooled calibration model to make inferences about past SST. *Morozovella spp.* is a nonexant species so, we're using modern planktic foraminifera as an analog with this pooled calibration.

```R
sst <- predict_seatemp(bassriver$d18o, d18osw = 0.0, 
                       prior_mean = 30.0, prior_std = 20.0)
```

The predict function then spits out a `prediction` object. Note that we need to specify d18O for seawater (`d18osw`), and a prior mean and standard deviation for our SST inference. See `help(predict_seatemp)` for more details, or `help(predict_d18oc)` for the reversed, "forward" model. 

The `sst` variable contains an ensemble rather than single prediction points because the calibration is a Bayesian regression model. This ensemble is in `sst[['ensemble']]`. Here we get median and 90% interval for the prediction:

```R
quantile(sst, probs = c(0.05, 0.50, 0.95))
```

We can also make a quick and dirty plot to visualize the inference:

```R
predictplot(x = bassriver$depth, y = sst, ylim = c(20, 40), 
            ylab = "SST (°C)", xlab = "Depth (m)")
```

## Citing bayfoxr in your research

Please cite our work if you use bayfoxr in your research. We have a paper currently in preparation and I'll be sure to update this section with the citation as soon as the paper is out.

To cite the code repository directly use:

*Malevich, Steven B., 2019. bayfoxr. \<https://github.com/brews/bayfoxr \>.*

Alternatively, you can cite the package in R's CRAN repository. You can see this information by running `citation("bayfoxr")` in an R session.

## Installation

### From CRAN

The package is not yet available on CRAN.

### From devtools

Bleeding edge and development versions of the package can be installed with [`devtools`](https://github.com/r-lib/devtools). Assuming you have `devtools` installed in R, you can install `bayfoxr` with:

```R
devtools::install_github("brews/bayfoxr")
```

## Support

Documentation is included in the code and can be viewed in R. Please file issues and requests in the [bug tracker](https://github.com/brews/bayfoxr/issues).

## Development
Want to contribute? We're following [Hadley's packaging workflow](http://r-pkgs.had.co.nz/) and [code style](http://adv-r.had.co.nz/Style.html). Please fork away and get in touch if you have a feature or bug fix.
