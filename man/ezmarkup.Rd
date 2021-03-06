% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/ezmarkup.R
\name{ezmarkup}
\alias{ezmarkup}
\title{Easy way to "markup" a table before it is sent to be displayed}
\usage{
ezmarkup(tbl, pattern)
}
\arguments{
\item{tbl}{The input table}

\item{pattern}{The grouping pattern. Each dot "." represent one column. If
two or more columns need to be combined in some certain formats, they should
be put together inside a pair of brackets "[ ]". You can add any special
characters, such as "(" and "~", inside the pair of brackets but please
don't leave those special characters outside the brackets. If you want to
add a dot as a special character. Please use "^.^" for every single dot
you would like to add.}
}
\description{
The final step of an analysis is to export the tables generated
through analytical scripts to the desired platform, such as a pdf, a rmarkdown
document or even a Shiny page. Sometimes, a lot of people wants to reorganize
the data in a more human readable format. For example, people like to put the
standard deviation inside a pair of parentheses after the mean. People also
like to put the low and high ends of confidence interval inside a pair of
parenthese, separated by " ~ ", after the estimated average. However, as far
as I know, so far there isn't a straight forward function to deal with this
need. This function is built to address this issue.
}
\examples{
library(dplyr)
dt <- mtcars \%>\% group_by(cyl) \%>\% select(gear, carb) \%>\% ezsummary_categorical(n=TRUE)

ezmarkup(dt, "...[.(.)]")
ezmarkup(dt, "..[. (. ~ .)]")
}

