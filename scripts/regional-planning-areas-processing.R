library(dplyr)
library(datapkg)
library(readxl)

##################################################################
#
# Processing Script for Regional Planning Areas
# Created by Jenna Daly
# On 07/18/2017
#
##################################################################

#Setup environment
sub_folders <- list.files()
data_location <- grep("raw", sub_folders, value=T)
path_to_raw_data <- (paste0(getwd(), "/", data_location))
raw_RPA <- dir(path_to_raw_data, recursive=T, pattern = "region") 

#Read in raw file
raw_RPA_xl <- (read_excel(paste0(path_to_raw_data, "/", raw_RPA), sheet=1, skip=0)) 

raw_RPA_xl <- raw_RPA_xl[,1:2]

raw_RPA_xl$`Planning Region`[which(raw_RPA_xl$`Planning Region` == "Capitol")] <- "Capitol Region"
raw_RPA_xl$`Planning Region`[which(raw_RPA_xl$`Planning Region` == "Greater Bridgeport")] <- "Metropolitan"
raw_RPA_xl$`Planning Region`[which(raw_RPA_xl$`Planning Region` == "Northeast CT")] <- "Northeastern"
raw_RPA_xl$`Planning Region`[which(raw_RPA_xl$`Planning Region` == "Southeastern CT")] <- "Southeastern"
raw_RPA_xl$`Planning Region`[which(raw_RPA_xl$`Planning Region` == "Western CT")] <- "Western"

raw_RPA_xl <- raw_RPA_xl[!is.na(raw_RPA_xl$TOWN),]

raw_RPA_xl$`Planning Region` <- sub("$", " Planning Area", raw_RPA_xl$`Planning Region`)

raw_RPA_xl$Organization <- "Regional Planning Area"

#Merge in FIPS
town_fips_dp_URL <- 'https://raw.githubusercontent.com/CT-Data-Collaborative/ct-town-list/master/datapackage.json'
town_fips_dp <- datapkg_read(path = town_fips_dp_URL)
fips <- (town_fips_dp$data[[1]])

RPA_fips <- merge(raw_RPA_xl, fips, by.x = "TOWN", by.y = "Town", all=T)

#remove CT
RPA_fips <- RPA_fips[RPA_fips$TOWN != "Connecticut",]

RPA_fips <- RPA_fips %>% 
  select(TOWN, FIPS, Organization, `Planning Region`) %>% 
  rename(Value = `Planning Region`, 
         Town = TOWN) %>% 
  arrange(Town)

# Write to File
write.table(
  RPA_fips,
  file.path(getwd(), "data", "regional_planning_areas_2017.csv"),
  sep = ",",
  row.names = F
)

