# BEFORE RUN: working directory must be set to the highest level of the repository and ensure that packages loaded below are installed

# clean the environment
rm(list = ls())

# load required packages
library(tidyverse)
library(janitor)
library(readxl)
library(haven)
library(labelled)

# load the data
df <- read_csv(file.path("data", "TXF_July 24.csv"), guess_max = 25000) %>%
  
  # set "" in character columns to NA
  mutate_if(is.character, ~ if_else(.x == "", NA_character_, .x))


# load the OCI data
df_oci <- read_dta(file.path("data", "OCI_July_2024.dta"))

# we merge based on year in df_oci, so need to ensure they overlap
summary(df_oci$year)
df_oci$year[!df_oci$year %in% df$year] %>% unique()
df$year[!df$year %in% df_oci$year] %>% unique()
# -> all years exist in both datasets

# repeat the same for ecacountry
df_oci$ecacountry[!df_oci$ecacountry %in% df$ecacountry] %>% unique() %>% sort()
# -> only Turkey in OCI but not in TXF
df$ecacountry[!df$ecacountry %in% df_oci$ecacountry] %>% unique() %>% sort()
# -> a lot of countries not in OCI but in TXF (as expected)

# convert energy_source from labelled integer to character
df_oci$energy_source <- labelled::to_character(df_oci$energy_source)
# if we have zero values, set them to NA
df_oci$energy_source[df_oci$energy_source == "0"] <- NA_character_

# check overlap for energy_source
df_oci$energy_source[!df_oci$energy_source %in% df$energy_source] %>% unique() %>% sort()
df$energy_source[!df$energy_source %in% df_oci$energy_source] %>% unique() %>% sort()
# -> perfect overlap in categories except for Hydro (which is not part of energy_source in TXF data)

# add Hydro as a category
df %>% count(tech)
df %>% filter(tech == "Hydro") %>% count(energy_source)
df$energy_source[df$tech == "Hydro"] <- "Hydro"

# convert v_c (value chain stage) from labelled integer to a character
df_oci$v_c <- labelled::to_character(df_oci$v_c)

# check overlap
df_oci$v_c[!df_oci$v_c %in% df$v_c] %>% unique() %>% sort()
# -> only unclear/mixed not overlapping
df$v_c[!df$v_c %in% df_oci$v_c] %>% unique() %>% sort()
# -> only Electricity infrastructure

# check value chain info in TXF data for grid projects
df %>% filter(energy_source == "Grid") %>% count(v_c)
# -> always Electricity infrastructure

# for the OCI data, we overwrite missing value chain info for grid projects w "Electricity infrastructure"
df_oci$v_c[df_oci$v_c == "0" & df_oci$energy_source == "Grid"] <- "Electricity infrastructure"

# ensure that flags for direct lending (dl), guarantees (g) and other instruments (o_i) in OCI data are mutually exclusive
df_oci %>% count(dl, gua, o_i)
df %>% count(direct_lending, guarantees)
# -> they are

# ensure that rows (!= deals) in TXF data that are not marked neither as direct lending nor guarantees have zero ECA
# commitments across the board
df %>% filter(direct_lending + guarantees == 0) %>% summarise(sum(v))

# code the flags into one character column
df_oci <- df_oci %>% mutate(eca_commitment_type = case_when(dl == 1 ~ "Direct lending",
                                                            gua == 1 ~ "Guarantee",
                                                            o_i == 1 ~ "Other instrument",
                                                            T ~ NA_character_))

# inspect
df_oci %>% count(eca_commitment_type)
df_oci %>% count(mechanism, eca_commitment_type)
# there is one observation with 'mechanism' as "Insurance" - add this to the 'Other instrument' category
df_oci$eca_commitment_type[df_oci$mechanism == "Insurance"] <- "Other instrument"

# repeat for df
df <- df %>% mutate(eca_commitment_type = case_when(direct_lending == 1 ~ "Direct lending",
                                                    guarantees == 1 ~ "Guarantee",
                                                    T ~ NA_character_))

# inspect
df %>% count(eca_commitment_type)

# inspect overlap in these categories
df$eca_commitment_type[!df$eca_commitment_type %in% df_oci$eca_commitment_type] %>% unique()
df_oci$eca_commitment_type[!df_oci$eca_commitment_type %in% df$eca_commitment_type] %>% unique()
# -> only NA and Other instrument (as expected)

### host country

# rename countries in df_oci
df_oci <- df_oci %>% mutate(country = case_when(country == "Viet Nam" ~ "Vietnam",
                                      country == "Slovakia" ~ "Slovak Republic",
                                      country == "Russia" ~ "Russian Federation",
                                      country == "Congo,the Democratic Republic of the" ~ "Congo, Democratic Republic of the",
                                      country == "Cote d'Ivoire" ~ "Cote D'Ivoire (Ivory Coast)",
                                      country == "Lao People's Democratic Republic"  ~ "Laos",
                                      country == "South Korea" ~ "Korea",
                                      T ~ country))
                                      
# check for overlap
df_oci$country[!df_oci$country %in% df$dealcountry] %>% unique() %>% sort()
df$dealcountry[!df$dealcountry %in% df_oci$country] %>% unique() %>% sort()
# -> OCI has several regional entries: ""Asia,regional", "Global",  "Latin America & Caribbean, regional", "Multiple Countries",
#    "North America, regional", "Sub-Saharan Africa, regional"

# load ISO3-ISO2 codes and clean up column names
df_iso3_iso2 <- read_excel(file.path("data", "240801 ISO3-ISO2-codes.xlsx"),
                           sheet = "iso3iso2") %>%
  clean_names() %>%
  rename(iso3 = "alpha_3_code", iso2 = "alpha_2_code")

# load iso3 code for country names in TXF data
df_dealcountry_iso3_matched <- read_csv(file.path("data", "txf_countrynames_iso3_matched.csv"))

# merge into df for deal country and ECA country
df <- df %>%
  
  # merge in ISO3 for deal countries
  left_join(df_dealcountry_iso3_matched %>% select(dealcountry = "txf_country_name",
                                                   dealcountry_iso3 = "iso3"),
            by = "dealcountry") %>%
  
  # merge in ISO3 for ECA countries
  left_join(df_dealcountry_iso3_matched %>% select(ecacountry = "txf_country_name",
                                                   ecacountry_iso3 = "iso3"),
            by = "ecacountry")


# check for missing ISO3 codes
if((df %>% filter(is.na(dealcountry_iso3)) %>% nrow()) != 0) stop("Data contains rows with no matching dealcountry ISO3 code. Please inspect")
# check for missing ISO3 codes
if((df %>% filter(!is.na(ecacountry) & is.na(ecacountry_iso3)) %>% nrow()) != 0) stop("Data contains rows with no matching ecacountry ISO3 code. Please inspect")

# check if any countries in df have an iso3 not featured in 
if(length(df$dealcountry_iso3[!df$dealcountry_iso3 %in% df_iso3_iso2$iso3] %>% unique()) != 0) stop("Not all countries covered")

# merge in iso2 codes
df <- df %>%
  
  left_join(df_iso3_iso2 %>% select(iso3, iso2), by = c("dealcountry_iso3" = "iso3")) %>%
  
  rename(dealcountry_iso2 = iso2)

# rename the deal country ISO2 code in the OCI data
df_oci <- df_oci %>% rename(dealcountry_iso2 = "CC")

# check overlap
df$dealcountry_iso2[!df$dealcountry_iso2 %in% df_oci$dealcountry_iso2] %>% unique() %>% sort()
df$dealcountry[!df$dealcountry %in% df_oci$country] %>% unique() %>% sort()

df_oci$dealcountry_iso2[!df_oci$dealcountry_iso2 %in% df$dealcountry_iso2] %>% unique() %>% sort()
df_oci$country[!df_oci$country %in% df$dealcountry] %>% unique() %>% sort()
# -> OCI uses Israel's ISO2 for Palestine. We keep this as double counting is VERY likely otherwise

df_oci %>% filter(dealcountry_iso2 == "GL") %>% select(country, everything())
# -> OCI wrongly uses ISO2 "GL" for Global while this is the code for Greenland

# set the ISO2 code to NA if the dealcountry is global
df_oci <- df_oci %>% mutate(dealcountry_iso2 = case_when(dealcountry_iso2 == "GL" & country == "Global" ~ NA_character_,
                                                T ~ dealcountry_iso2))
 
# OCI wrongly uses ISO2 "UK" for the United Kingdom which in fact has ISO2 code GB
df_oci <- df_oci %>% mutate(dealcountry_iso2 = case_when(country == "United Kingdom" ~ "GB",
                                                         T ~ dealcountry_iso2))


################################################################################
####################### TECH x YEAR x ECA COUNTRY x INSTRUMENT #################
################################################################################

### a) create the combined data set

# collapse the TXF data
df_tech_year_ecacountry_instr <- df %>%
  
  # remove rows (!= deals) that are not ECA commitments
  filter(!is.na(eca_commitment_type)) %>%
  
  # group by technology, year, ECA country and instrument
  group_by(energy_source, year, ecacountry, eca_commitment_type) %>%
  
  # summarize the number of deals and the total commitment volume and ungroup
  # NOTE: we have to count unique deal IDs because in the TXF data, one row does NOT correspond to one deal
  summarise(n_deals = length(unique(tmddealid)),
            v_bn = sum(v_bn, na.rm = T),
            .groups = "drop")

# collapse the OCI data
df_oci_tech_year_ecacountry_instr <- df_oci %>%
  
  # drop deals that cannot be attributed to a specific technology
  filter(energy_source != 0) %>%
  
  # drop deals that cannot be attributed to a specific instrument
  filter(!is.na(eca_commitment_type)) %>%
  
  # group, collapse and ungroup
  group_by(energy_source, year, ecacountry, eca_commitment_type) %>%
  summarise(n_deals = n(),
            v_bn = sum(v_bn, na.rm = T),
            .groups = "drop")

# join the two data sets via full_join
df_combined_tech_year_ecacountry_fintype <- full_join(df_tech_year_ecacountry_instr, df_oci_tech_year_ecacountry_instr,
                                                      by = c("energy_source", "year", "ecacountry", "eca_commitment_type"),
                                                      suffix = c("_txf", "_oci")) %>%
  
  # sort by the grouping variables and reorder columns
  arrange(ecacountry, year, energy_source, eca_commitment_type) %>%
  select(ecacountry, year, energy_source, eca_commitment_type, everything()) %>%
  
  # replace any remaining NA values (= pairing of grouping variable values does not exist in either OCI or TXF) w/ 0
  mutate_at(vars(v_bn_txf, v_bn_oci), ~replace_na(., 0)) %>%
  
  # take the larger of the two
  mutate(v_bn_larger = if_else(v_bn_txf > v_bn_oci, v_bn_txf, v_bn_oci)) %>%
  
  # add the periods
  mutate(period = case_when(year %in% 2013:2015 ~ "P1",
                              year %in% 2016:2019 ~ "P2",
                              year %in% 2020:2021 ~ "P3",
                              year %in% 2022:2023 ~ "P4",
                              T ~ NA_character_)) %>%
  
  # add a dummy indicating if the ECA country is part of E3F
  mutate(e3f = ecacountry %in% c("Belgium", "Denmark", "Finland", "France", "Germany",
                                   "Italy", "Netherlands", "Spain", "Sweden", "United Kingdom")) %>%
  
  # add whether a deal is fossil, RE or grid
  mutate(re_ff_grid = factor(case_when(energy_source %in% c("Wind", "Solar", "Other RETs", "Hydro") ~ "Renewables",
                                  energy_source %in% c("Coal", "Oil", "Gas", "Other fossil") ~ "Fossil",
                                  energy_source == "Grid" ~ "Grid",
                                  T ~ NA_character_),
                               levels = c("Grid", "Renewables", "Fossil")))



################################################################################
####################### TECH x YEAR x ECA COUNTRY x VALUE CHAIN STAGE ##########
################################################################################

### a) create the combined dataset

# collapse TXF following the steps above
df_tech_year_ecacountry_vc <- df %>%
  
  group_by(energy_source, year, ecacountry, v_c) %>%
  
  summarise(n_deals = length(unique(tmddealid )),
            v_bn = sum(v_bn, na.rm = T),
            .groups = "drop")

# collapse OCI following the steps above
df_oci_tech_year_ecacountry_vc <- df_oci %>%
  
  filter(energy_source != 0) %>%
  
  group_by(energy_source, year, ecacountry, v_c) %>%
  
  summarise(n_deals = n(),
            v_bn = sum(v_bn, na.rm = T),
            .groups = "drop")

# combine using full_join following the steps above
df_combined_tech_year_ecacountry_vc <- full_join(df_tech_year_ecacountry_vc, df_oci_tech_year_ecacountry_vc,
                                                 by = c("energy_source", "year", "ecacountry", "v_c"),
                                                 suffix = c("_txf", "_oci")) %>%
  
  mutate(re_ff_grid = factor(case_when(energy_source %in% c("Wind", "Solar", "Other RETs", "Hydro") ~ "Renewables",
                                       energy_source %in% c("Coal", "Oil", "Gas", "Other fossil") ~ "Fossil",
                                       energy_source == "Grid" ~ "Grid",
                                       T ~ NA_character_),
                             levels = c("Grid", "Renewables", "Fossil"))) %>%
  
  # subset to RET and fossil (since only these are displayed in the chart about value chain stages)
  filter(re_ff_grid %in% c("Renewables", "Fossil")) %>%
  
  arrange(ecacountry, year, energy_source, v_c) %>%
  select(ecacountry, year, energy_source, v_c, everything()) %>%
  
  mutate_at(vars(v_bn_txf, v_bn_oci), ~ replace_na(., 0)) %>%
  
  mutate(v_bn_larger = if_else(v_bn_txf > v_bn_oci, v_bn_txf, v_bn_oci)) %>%
  
  mutate(period = case_when(year %in% 2013:2015 ~ "P1",
                            year %in% 2016:2019 ~ "P2",
                            year %in% 2020:2021 ~ "P3",
                            year %in% 2022:2023 ~ "P4",
                            T ~ NA_character_))



################################################################################
####################### TECH x YEAR x ECA COUNTRY x HOST COUNTRY ###############
################################################################################

### a) create the combined data set

# collapse TXF following the steps above
df_tech_year_ecacountry_dealcountry <- df %>%
  
  filter(!is.na(ecacountry)) %>% 
  
  group_by(energy_source, year, ecacountry, dealcountry_iso2) %>%
  
  summarise(n_deals = length(unique(tmddealid )),
            v_bn = sum(v_bn, na.rm = T),
            .groups = "drop")


# collapse OCI following the steps above
df_oci_tech_year_ecacountry_dealcountry <- df_oci %>%
  
  filter(energy_source != 0) %>%
  
  # discard empty ISO2 (= regional aggregates) and multicountry values
  filter(str_detect(dealcountry_iso2, "^[A-Z][A-Z]$")) %>%
  
  group_by(energy_source, year, ecacountry, dealcountry_iso2) %>%
  summarise(n_deals = n(),
            v_bn = sum(v_bn, na.rm = T),
            .groups = "drop")


# combine using full_join following the steps above
df_combined_tech_year_ecacountry_dealcountry <- full_join(df_tech_year_ecacountry_dealcountry, df_oci_tech_year_ecacountry_dealcountry,
                                                          by = c("energy_source", "year", "ecacountry", "dealcountry_iso2"),
                                                          suffix = c("_txf", "_oci")) %>%
  
  mutate(re_ff_grid = factor(case_when(energy_source %in% c("Wind", "Solar", "Hydro", "Other RETs") ~ "Renewables",
                                       energy_source %in% c("Coal", "Oil", "Gas", "Other fossil") ~ "Fossil",
                                       energy_source == "Grid" ~ "Grid",
                                       T ~ NA_character_),
                             levels = c("Grid", "Renewables", "Fossil"))) %>%
  
  arrange(ecacountry, year, energy_source, dealcountry_iso2) %>%
  select(ecacountry, year, energy_source, dealcountry_iso2, everything()) %>%
  
  mutate_at(vars(v_bn_txf, v_bn_oci), ~ replace_na(., 0)) %>%
  
  mutate(v_bn_larger = if_else(v_bn_txf > v_bn_oci, v_bn_txf, v_bn_oci)) %>%
  
  mutate(period = case_when(year %in% 2013:2015 ~ "P1",
                            year %in% 2016:2019 ~ "P2",
                            year %in% 2020:2021 ~ "P3",
                            year %in% 2022:2023 ~ "P4",
                            T ~ NA_character_))



################################################################################
################# EXPORT THE DATA FILES ########################################
################################################################################

# export the data files
write_csv(df_combined_tech_year_ecacountry_dealcountry,
          file.path("data", "filled_up_txf_oci", "df_combined_tech_year_ecacountry_dealcountry.csv"))

write_csv(df_combined_tech_year_ecacountry_fintype,
          file.path("data", "filled_up_txf_oci", "df_combined_tech_year_ecacountry_fintype.csv"))

write_csv(df_combined_tech_year_ecacountry_vc,
          file.path("data", "filled_up_txf_oci", "df_combined_tech_year_ecacountry_vc.csv"))
