---
title: "An example Knitr/R Markdown document"
author: "Riva Tropp"
output: html_document
---
library('yaml')  
library('knitr')

setwd("~/subway")

source("join_gtfs.R")
kable(head(trips))
