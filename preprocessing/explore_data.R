## This script is used to explore the data generated in get_diabetes.R
## This study is attempting to predict diabetes development in UKB participants. Only those with repeat visits will be included
## Diabetes is defined here as "Diabetes diagnosed by doctor" UKB FieldID 2443

rm(list=ls())

# Defining variables
lib_loc = "/projects/sunlab/R.lib"

# Loading packages
suppressPackageStartupMessages(library(data.table,lib.loc=lib_loc))
suppressPackageStartupMessages(library(crayon,lib.loc=lib_loc))
suppressPackageStartupMessages(library(dplyr,lib.loc=lib_loc))
suppressPackageStartupMessages(library(cli,lib.loc=lib_loc))
suppressPackageStartupMessages(library(tidyr,lib.loc=lib_loc))

# Loading data
doctor = fread("data/doctor_DM.txt")
imaging = fread("data/imaging_DM.txt")
