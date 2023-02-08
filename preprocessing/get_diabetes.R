## This script is used to isolate diabetes patients from UKB participants
## This study is attempting to predict diabetes development in UKB participants. Only those with repeat visits will be included
## Diabetes is defined here as "Diabetes diagnosed by doctor" UKB FieldID 2443

rm(list=ls())

# Defining variables
lib_loc = "/projects/sunlab/R.lib"
ukb_loc = "/projects/sunlab/UKB/Data_clean/ukb_core_data_669473.rda"
meta_loc = "/projects/sunlab/Students_Work/Amonae_work/scripts/UKB_Data_Dictionary.csv"  # This is a file with UKB FieldID > Field conversions
Field = c("Diabetes1", "Diabetes2", "Diabetes_imaging1", "Diabetes_imaging2")
FieldID = c("f.2443.0.0","f.2443.1.0","f.2443.2.0","f.2443.3.0") # These are the entries for UKB FieldID 2443

# Loading packages
suppressPackageStartupMessages(library(data.table,lib.loc=lib_loc))
suppressPackageStartupMessages(library(crayon,lib.loc=lib_loc))
suppressPackageStartupMessages(library(dplyr,lib.loc=lib_loc))
suppressPackageStartupMessages(library(cli,lib.loc=lib_loc))
suppressPackageStartupMessages(library(tidyr,lib.loc=lib_loc))


# Loading UKB data. This is a giant file
load(ukb_loc) # this file will be named 'bd'
dim(bd) # 502402  15935
bd_classes = unlist(sapply(bd, class)) # viewing class types of columns
table(bd_classes) 
# character      Date   integer integer64   logical   numeric   POSIXct    POSIXt
#     1440        52      9804        45      1000      3445       149       149


## Going to rbind later, and need to fix these column formats. 
# All columns of class POSIXct are also class POSIXt. sapply added either a 1 or 2 after the column name and created 2 entries
Date_cols = names(bd_classes[bd_classes == "Date"])
POS_cols = names(bd_classes[bd_classes %in% c( "POSIXt")])
POS_cols = gsub('.{1}$', '', POS_cols) # removing last digit from colnames so they match bd colnames
bd[,c(Date_cols,POS_cols)] = lapply(bd[,c(Date_cols,POS_cols)], as.character) # converting dates to character

# Renaming a few columns
names(bd)[grepl("eid", names(bd))] = "IID"   # renaming individual ID column
setnames(bd, old = FieldID, new = Field)  # renaming Field columns 

# Organizing metadata 
meta = fread(meta_loc)
dim(meta) #8751 17
names(meta)
colIDs = gsub('f.', '', names(bd)) # This is setting up to isolate the FieldID from the column names
colIDs = gsub("\\..*","",colIDs)
head(colIDs)
colFields = meta$Field[match(colIDs, meta$FieldID)]

# Dataframes with only diabetes data
doctor = bd %>% drop_na(Diabetes2) # Non imaging diagnosis. Only want to include patients that have had a repeat visit
dim(doctor) #  20334 15935

imaging = bd %>% drop_na(Diabetes_imaging2) # Imaging diagnosis. Only want to include patients that have had a repeat visit
dim(imaging) # 5274 15935

# Adding metadata to rows in doctor and imaging dfs
doctor = rbind(colIDs, colFields, doctor)
imaging = rbind(colIDs, colFields, imaging)

# Removing columns with >40% missingness
doctor = doctor[,!sapply(doctor, function(x) mean(is.na(x)))>0.4] # new dim 20336 1941
imaging = imaging[,!sapply(imaging, function(x) mean(is.na(x)))>0.4] # new dim 5276 3825

# Saving files
write.table(doctor, file = "doctor_DM.txt", row.names = F, quote = F)
write.table(imaging, file = "imaging_DM.txt", row.names = F, quote = F)

