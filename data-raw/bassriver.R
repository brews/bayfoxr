# Read and write Bass River package example data.

require("devtools")

bassriver <- read.csv("bassriver.csv")

devtools::use_data(bassriver, overwrite = TRUE)