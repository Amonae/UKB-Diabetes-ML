## This script is used to isolate diabetes patients from UKB participants
## This study is attempting to predict diabetes development in UKB participants. Only those with repeat visits will be included
## Diabetes is defined here as "Diabetes diagnosed by doctor" UKB FieldID 2443


# Defining variables
lib_loc = "/projects/sunlab/R.lib"
ukb_loc = "/projects/sunlab/UKB/Data_clean/ukb_core_data_669473.rda"
meta = "/projects/sunlab/Students_Work/Amonae_work/scripts/UKB_Data_Dictionary.csv"  # This is a file with UKB FieldID > Field conversions
Field = c("Diabetes1", "Diabetes2", "Diabetes_imaging1", "Diabetes_imaging2")
FieldID = c("f.2443.0.0","f.2443.1.0","f.2443.2.0","f.2443.3.0") # These are the entries for UKB FieldID 2443

# Loading packages
rm(list=ls())
suppressPackageStartupMessages(library(data.table,lib.loc=lib_loc))
suppressPackageStartupMessages(library(crayon,lib.loc=lib_loc))
suppressPackageStartupMessages(library(dplyr,lib.loc=lib_loc))
suppressPackageStartupMessages(library(cli,lib.loc=lib_loc))
suppressPackageStartupMessages(library(tidyr,lib.loc=lib_loc))

# Loading UKB data. This is a giant file
load(ukb_loc) # this file will be named 'bd'
dim(bd)
names(bd)[grepl("eid", names(bd))] = "IID"   # renaming individual ID column
names(bd)[names(bd)== FieldID] = Field  # renaming Field columns 

# Adding 2 rows  with metadata 
dim(meta)
names(meta)
colIDs = gsub('f.', '', names(bd)) # This is setting up to isolate the FieldID from the column names
colIDs = gsub("\\..*","",colIDs)
head(colIDs)
colFields = meta$Field[match(colIDs, meta$FieldID)]

# Dataframe with only diabetes data
diabetes = bd[,c("IID", Field)]

doctor = diabetes[,c("Diabetes1", "Diabetes2")] # Non imaging diagnosis
doctor = doctor %>% drop_na(Diabetes2) # Only want to include patients that have had a repeat visit
dim(doctor)

imaging = diabetes[,c("Diabetes3", "Diabetes4")] # Imaging diagnosis
imaging = imaging %>% drop_na(Diabetes4) # Only want to include patients that have had a repeat visit
dim(imaging)

