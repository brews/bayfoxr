% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modelparams.R
\name{get_available_forams}
\alias{get_available_forams}
\title{Parse trace dataframe column names to get vector of available forams.}
\usage{
get_available_forams(d)
}
\arguments{
\item{d}{Data frame containing MCMC trace draws. Column names are model 
parameters with foram group name separated from model parameters name by "__"}
}
\value{
Character vector of available foram names.
}
\description{
Parse trace dataframe column names to get vector of available forams.
}
