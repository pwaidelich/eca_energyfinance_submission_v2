# BEFORE RUN: working directory must be set to the highest level of the repository and ensure that packages loaded below are installed

# clean the environment
rm(list = ls())

# load required packages
library(tidyverse)
library(janitor)
library(ggpubr)
library(sf)
library(readxl)
library(rnaturalearth)
library(patchwork)

# load the data
df <- read_csv(file.path("data", "TXF_July 24.csv"), guess_max = 20000) %>%

  # consolidate the flags indicating fossils, RETs, and other energy into one character column
  mutate(ff_re_other = case_when(ff == 1 ~ "Fossil",
                                 re == 1 ~ "Renewables",
                                 TRUE ~ "Other energy")) %>%

  # discard ECA finance by Canda (out of scope)
  filter(ecacountry != "Canada")

# set ggplot2 theme
theme_set(theme_classic())


################################################################################
################ FIGURE ON GEOGRAPHIC IMPLICATIONS #############################
################################################################################

# define color scales for the maps and bar charts (taken from IPCC style guides)
palette_ipcc_highcontrast_4col <-  c(rgb(237, 248, 251, maxColorValue = 255),
                                     rgb(179, 205, 227, maxColorValue = 255),
                                     rgb(140, 150, 198, maxColorValue = 255),
                                     rgb(136, 65, 157, maxColorValue = 255))

palette_ipcc_temp_4col <- c(rgb(  244, 165, 130, maxColorValue = 255),
                            rgb( 253, 219, 199, maxColorValue = 255),
                            rgb(  209, 229, 240 , maxColorValue = 255),
                            rgb(  146, 197, 222 , maxColorValue = 255))


# set overall figure font size
fontsize_general <- 6

# load iso3 code for country names in TXF data
df_dealcountry_iso3_matched <- read_csv("data/txf_countrynames_iso3_matched.csv")

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

# NOTE: for ecacountry, not every row (= one per tranche/lender) has an ECA, so the check needs to subset only to rows where ecacountry is non-empty
if((df %>% filter(!is.na(ecacountry) & is.na(ecacountry_iso3)) %>% nrow()) != 0) stop("Data contains rows with no matching ecacountry ISO3 code. Please inspect")

# load WB classification
df_wbcountrygroups <- read_excel("data/240219 WB Country and Lending Groups.xlsx", sheet = "List of economies")

# drop the TXF country groups by income level (which are outdated for a few countries)
df <- df %>% select(-wbcountryclassification)

# check coverage of dealcountry ISO3 codes in the World Bank data
df$dealcountry_iso3[!df$dealcountry_iso3 %in% df_wbcountrygroups$Code] %>% unique()
# -> only Jersey (JEY) is not covered, which is high-income

# merge in the most recent WB classification
df <- df %>% left_join(df_wbcountrygroups %>% rename(wbcountryclassification_udpated = "Income group"),
                       by = c("dealcountry_iso3" = "Code"))

# collapse cumulative ECA commitment by country and FF/RE
df_map <- df %>% 
  
  # subset to FF or RE
  filter(ff_re_other %in% c("Fossil", "Renewables")) %>%
  
  # collapse ECA commitments by country and FF/RE
  group_by(ff_re_other, dealcountry_iso3, dealcountry) %>%
  summarise(v = sum(v), .groups = "drop") %>%
  
  # calculate recipient shares by FF/RE
  group_by(ff_re_other) %>%
  mutate(share = v/sum(v, na.rm = T)) %>% ungroup()

# load country-level shapefiles for the world from the `rnaturalearth` package
world <- rnaturalearth::ne_countries(scale = 50, returnclass = "sf")
  
# rename the ISO3 column to match the column name in the TXF data
# NOTE: the 'adm0_a3' column is not 100% identical to ISO3 conventions but countries where the two differ (e.g., Kosovo or Palestine)
# are not included in our data. By contrast, the 'iso_a3' variable has NAs for some major countries like France
names(world)[names(world) == "adm0_a3"] <- "iso3"

# ensure that we have all relevant countries in the world shapefile
if(mean(df$dealcountry_iso3 %in% world$iso3) != 1) stop("Some ISO3 codes in the dealcountry_iso3 column in df are not part of the world shapefile")

# in the map below, the highest category of recipient country shares goes up to 15% - ensure that the in-data maximum is not higher
if(max(df_map$share) > 0.15) stop("Maximum recipient country share in df_map's 'share' column exceeds 15%. Adjust the map's group definitions")
                                                        
# write a function to create the map of recipient country shares in ECA financing
make_ecashare_map <- function(data = NULL, # the data to be plotted
                              fossil_or_renewables = "Fossil", # set to 'Fossil' or 'Renewables'
                              use_iso3 = T # determine which ISO to use for matching
) {
  
  # discard Antarctica from the shapefile for visual reasons
  df_plot <- world %>% filter(!str_detect(admin, "Antarctica"))
    
  # merge in the actual data with ECA commitments and filter to Fossil/Renewables based on fossil_or_renewables
  # NOTE: we use either ISO3 or ISO2 codes here
  if(use_iso3) {
    
    df_plot <- df_plot %>% left_join(data %>% filter(ff_re_other == fossil_or_renewables), by = c("iso3" = "dealcountry_iso3"))
  } else {
    
    df_plot <- df_plot %>% left_join(data %>% filter(ff_re_other == fossil_or_renewables), by = c("iso2" = "dealcountry_iso2"))
  }
  
  
  df_plot %>%
    
    # create a binning variable for the continuous share variable
    mutate(share_group = case_when(is.na(share) ~ NA_character_,
                                   share < 0.01 ~ "(0%, 1%)",
                                   share < 0.025 ~ "[1%, 2.5%)",
                                   share < 0.05 ~ "[2.5%, 5%)",
                                   TRUE ~ "[5%, 15%]"
    )) %>%
    
    # plot the map with all countries in grey
    ggplot() + geom_sf(fill = "grey") +
    
    # plot another map on top with the fill color based on the binned share variable (= overlays the grey for all non-NA countries)
    geom_sf(aes(fill = share_group)) +
    
    # set the fill color scale
    scale_fill_manual(values = c(palette_ipcc_highcontrast_4col),
                      na.translate = F,
                      na.value = "grey") +
    
    # set labels
    labs(fill = "Recipient share in 2013-2023\nECA commitments (all instruments)") +
    
    # create a facet for Fossil/Renewables (NOTE: the data contains only one of them, so this simply adds a facet-style title)
    facet_wrap(~ ifelse(fossil_or_renewables == "Fossil", "Fossil", "Renewables")) +
    
    # stretch the fill legend over two rows and suppress the color in its visual elements
    guides(fill = guide_legend(nrow = 2, override.aes = list(color = NA))) +
    
    # set the color for the facet title and other axes/legend elements
    theme(strip.background = element_rect(fill = ifelse(fossil_or_renewables == "Fossil",
                                                        "lightgrey",
                                                        "#b8d3be"),
                                          color = NA),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "bottom",
          strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt")),
          legend.text = element_text(size = fontsize_general),
          legend.title = element_text(size = fontsize_general),
          legend.margin = margin(0, 0, 0, 0, "pt"),
          legend.key.size = unit(10,"pt"))
}

# create map for fossil and renewable projects
panel1 <- ggarrange(make_ecashare_map(df_map, "Fossil"),
                    make_ecashare_map(df_map, "Renewables"),
                    align = "hv",
                    common.legend = T, legend = "bottom",
                    ncol = 2,
                    labels = c("A:", ""),
                    font.label = list(size = fontsize_general + 2, color = "black", face = "bold")
)

# inspect
panel1

# ensure that the 'ecaregion' column is non-NA for all rows with non-zero ECA commitments (which could produce errors below)
if(sum(is.na(df$ecaregion[df$v > 0])) > 0) stop("For some rows with non-zero ECA commitments, the ecaregion column is NA")

# collapse commitments by ECA country by domestic/same region/other region and FF/RE
df_countryfigure <- df %>%
  
  # label activities as domestic, same-region of other region
  mutate(domestic_activity = case_when(dealcountry == ecacountry ~ "Same country",
                                       dealregion == ecaregion ~ "Same region",
                                       TRUE ~ "Other region")) %>%
  
  # collapse by ECA country, domestic/same region/other region and FF/RE
  group_by(ecacountry, domestic_activity, ff_re_other) %>% summarise(y_var = sum(v), .groups = "drop") %>%
  
  # calculate total for each ECA country and FF/RE
  group_by(ecacountry, ff_re_other) %>% mutate(total = sum(y_var)) %>% ungroup()

## identify top 10 countries for FF and RE
# FF
top10_ecacountry_ff <- df_countryfigure %>% filter(ff_re_other == "Fossil") %>% select(ff_re_other, ecacountry, total) %>% distinct() %>%
  slice_max(total, n = 10) %>%
  arrange(desc(total)) %>% mutate(rank_ff = 1:n())
# RE
top10_ecacountry_re <- df_countryfigure %>% filter(ff_re_other == "Renewables") %>% select(ff_re_other, ecacountry, total) %>% distinct() %>%
  slice_max(total, n = 10) %>%
  arrange(desc(total)) %>% mutate(rank_re = 1:n())

# merge in top10 status and collapse countries that are not in top 10 into "Other countries"
df_countryfigure_final <- df_countryfigure %>%
  
  # subset to fossil/RE deals
  filter(ff_re_other %in% c("Fossil", "Renewables")) %>%
  
  # join in top-10 status for FF
  left_join(top10_ecacountry_ff %>% select(ff_re_other, ecacountry, rank_ff), 
            by = c("ff_re_other", "ecacountry")) %>%
  
  # and for RE
  left_join(top10_ecacountry_re %>% select(ff_re_other, ecacountry, rank_re), 
            by = c("ff_re_other", "ecacountry")) %>%
  
  # create a rank variable (if not in top 10, rank = 11)
  mutate(rank = case_when(!is.na(rank_ff) ~ rank_ff,
                          !is.na(rank_re) ~ rank_re,
                          TRUE ~ 11)) %>%
  
  # collapse the commitments for countries not in the top 10
  mutate(ecacountry_grouped = if_else(rank < 11, ecacountry, "Other countries")) %>%
  group_by(ecacountry_grouped, domestic_activity, ff_re_other, rank) %>%
  summarise(y_var = sum(y_var), .groups = "drop") %>%
  
  # set the order of factor levels for the 'domestic_activity' variable
  mutate(domestic_activity = factor(domestic_activity, 
                                    levels = c("Same country", "Same region", "Other region")))

# create the panel for FF
ff_panel <- df_countryfigure_final %>% filter(ff_re_other == "Fossil") %>%
  
  # order countries by rank and convert commitments from million to billion USD
  ggplot(aes(reorder(ecacountry_grouped, -rank), y_var/10^3)) +
  
  # bar chart with stacked bars for domestic/same region/other region
  geom_col(aes(fill = domestic_activity), alpha = 0.7) +
  
  # label axes and fill legend manually
  labs(x = "ECA country",
       y = "2013-2023 commitment\n(All instruments, USD2020 billion)", fill = "Deals located in ...") +
  
  # create a facet for fossil and renewable projects (NOTE: we have subsetted to fossil projects here, so this merely creates a facet title)
  facet_wrap(~ff_re_other, scales = "free") +
  
  # set theme elements manually
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05,
          face = "bold", size = fontsize_general),
        strip.background = element_rect(fill = "lightgrey",
                                        color = NA),
        axis.title.x = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        legend.key.size = unit(10,"pt"),
        strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt"))) +
  
  # flip axes and set y-axis lower limit to zero
  coord_flip(ylim = c(0, NA)) +
  
  # set style of fill legend manually
  guides(fill = guide_legend(nrow = 1, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# make the same panel for RE 
re_panel <- df_countryfigure_final %>% filter(ff_re_other == "Renewables") %>%
  
  ggplot(aes(reorder(ecacountry_grouped, -rank), y_var/10^3)) +
  
  geom_col(aes(fill = domestic_activity), alpha = 0.7) +
  
  labs(x = "ECA country",
       y = "2013-2023 commitment\n(All instruments, USD2020 billion)", fill = "Deals located in...") +
  
  facet_wrap(~ff_re_other, scales = "free") +
  
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05,
          face = "bold", size = fontsize_general),
        strip.background = element_rect(fill = "#b8d3be",
                                        color = NA),
        axis.title.x = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt")),
        legend.key.size = unit(10,"pt"),
        legend.margin= margin(0, 0, 0, 0, "pt")) +
  
  coord_flip() +
  
  guides(fill = guide_legend(nrow = 1, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# summary stats for Denmark
df_countryfigure_final %>% filter(ff_re_other == "Renewables", ecacountry_grouped == "Denmark") %>%
  mutate(share = y_var/sum(y_var))

# calculate commitment shares by income group of recipient country and by period
df_highincomepanel <- df %>%
  
  # impute high-income country status for JERSEY (JEY) as group is NA in WB raw data
  mutate(wbcountryclassification_clean = case_when(dealcountry == "Jersey" ~ "High income",
                                                   TRUE ~ wbcountryclassification_udpated )) %>%
  
  # convert wbcountryclassification_clean into a factor variable
  mutate(wbcountryclassification_clean = factor(wbcountryclassification_clean,
                                                levels = c("Low income",
                                                           "Lower middle income",
                                                           "Upper middle income",
                                                           "High income"))) %>%
  
  # add the phases as a factor variable
  mutate(closingyear_phase = factor(case_when(year %in% 2013:2015 ~ "P1",
                                              year %in% 2016:2019 ~ "P2",
                                              year %in% 2020:2021 ~ "P3",
                                              year %in% 2022:2023 ~ "P4",
                                              TRUE ~ "INSPECT XXX"))
  ) %>%
  
  # collapse ECA commitments by recipient country income group and phase
  group_by(wbcountryclassification_clean, closingyear_phase) %>%
  summarize(v = sum(v)) %>% ungroup() %>%
  
  # calculate the share of commitments by phase and income group
  group_by(closingyear_phase) %>% mutate(share = v/sum(v)) %>% ungroup()

# create the figure
highincome_panel <- df_highincomepanel %>% 
  
  # make a stacked bar chart with the phase on the x-axis and the share of commitments on the y-axis
  ggplot(aes(closingyear_phase, share)) +
  geom_col(aes(fill = wbcountryclassification_clean)) +
  
  # add (rounded) value labels for the share of commitments if share is > 0
  geom_label(aes(fill = wbcountryclassification_clean,
                 label = ifelse(100*round(share, 2) > 0, paste0(100*round(share, 2), "%"), NA_character_)),
             position = position_stack(vjust = 0.5, reverse = F),
             size = 6/.pt,
             label.padding = unit(0.1, "lines"),
             show.legend = F) +
  
  # set the y-axis to percentage scale
  scale_y_continuous(labels = scales::percent) +
  
  # set the fill colors manually
  scale_fill_manual(values = palette_ipcc_temp_4col) +
  
  # add labels to the x-axis and y-axis and the fill legend
  labs(fill = "Recipient country group", y = "Share in ECA commitments\n(all instruments)",
       x = NULL) +
  
  # set the theme elements manually
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05, hjust = 1, 
          face = "bold",
          size = fontsize_general),
        axis.title.x = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        legend.key.size = unit(10,"pt"),
        legend.margin= margin(0, 0, 0, 0, "pt")) +
  
  # set the style of the fill legend manually
  guides(fill = guide_legend(nrow = 2, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# combine the charts into the lower panel of Figure 5 using the patchwork package
panel2 <- ff_panel + re_panel + highincome_panel +
  plot_layout(nrow = 1, widths = c(1, 1, 1.2), tag_level = "new") +
  plot_annotation(tag_levels = list(c("B:",
                                      "",
                                      "C:")))

# combine map and lower panel
ggarrange(panel1, panel2, nrow = 2, ncol = 1, align = "hv",
          heights = c(1, 1))

# save out as vector graph (300dpi, 18cm width)
ggsave(file.path("graphs",
                 paste0(Sys.Date(), " figure_geographic_implications.pdf")),
       width = 19, height = 14, dpi = 300, units = "cm")

# manual steps to do in Adobe Illustrator:
# - Add & reformat full panel titles
# - Drop one of the two legends in Panel B and center the other
# - Adjust the spacing


### export the source data with renamed columns

# a) Figure 5A
write_csv(df_map %>% rename(ecacommitment_USDm = "v"),
          file.path("data", paste0(Sys.Date(), " source_data_figure5a.csv")))

# b) Figure 5B
write_csv(df_countryfigure_final %>% select(ff_re_other, ecacountry = "ecacountry_grouped",
                                            recipient_country_is = "domestic_activity",
                                            ecacommitment_USDm = "y_var") %>%
            arrange(ff_re_other, ecacountry),
          file.path("data", paste0(Sys.Date(), " source_data_figure5b.csv")))

# b) Figure 5C
write_csv(df_highincomepanel %>% rename(income_group = "wbcountryclassification_clean",
                                        ecacommitment_USDm = "v"),
          file.path("data", paste0(Sys.Date(), " source_data_figure5c.csv")))

# clean up the environment
rm(panel1, panel2, re_panel, ff_panel, top10_ecacountry_re, top10_ecacountry_ff,
   highincome_panel, df_highincomepanel, df_countryfigure, df_countryfigure_final, df_map)

################################################################################
################ SI VERSION COMBINING TXF AND OCI DATA #########################
################################################################################

# load the combined TXF-OCI data
df_combined_tech_year_ecacountry_dealcountry <- read_csv("data/filled_up_txf_oci/df_combined_tech_year_ecacountry_dealcountry.csv") %>%
  
  # ensure consistent variable naming
  rename(ff_re_other = "re_ff_grid") %>%
  
  # discard Canadian ECA finance (out of scope)
  filter(ecacountry != "Canada") %>%

  # discard 2023 deals (since OCI is near-empty for 2023 deals)
  filter(year != 2023)
  
# extract all name-ISO3 combinations in the TXF data
# NOTE: we need this because the combined data set features ECA countries only as names, not in ISO3 format (which we need for merging further data)
df_name_iso3 <- bind_rows(df %>% select(country = "dealcountry", iso3 = "dealcountry_iso3"),
          df %>% select(country = "ecacountry", iso3 = "ecacountry_iso3") %>% filter(!is.na(country))) %>%
  distinct()

# ensure that each ISO3 code has only one name
if(nrow(df_name_iso3 %>% count(iso3) %>% filter(n > 1)) > 0) stop("There are multiple names for at least one ISO3 code")

# merge into df_combined
df_combined_tech_year_ecacountry_dealcountry <- df_combined_tech_year_ecacountry_dealcountry %>%
  left_join(df_name_iso3 %>% rename(ecacountry = "country", ecacountry_iso3 = "iso3"), by = "ecacountry")

# load ISO3-ISO2 codes
df_iso3_iso2 <- read_excel("data/240801 ISO3-ISO2-codes.xlsx",
                           sheet = "iso3iso2") %>%
  clean_names() %>%
  rename(iso3 = "alpha_3_code", iso2 = "alpha_2_code") %>%
  # add the Kosovo which is missing in the data but features as a deal location in the combined data set
  bind_rows(tibble(country = "Kosovo", iso2 = "XK", iso3 = "XKX", numeric = NA))

# check coverage
if(sum(!df_combined_tech_year_ecacountry_dealcountry$dealcountry_iso2 %in% df_iso3_iso2$iso2) > 0) stop("There are non-covered deal country ISO2 codes")
if(sum(!df_combined_tech_year_ecacountry_dealcountry$ecacountry_iso3 %in% df_iso3_iso2$iso3) > 0) stop("There are non-covered ECA country ISO3 codes")

# add ISO3 codes for dealcountry and ecacountry
df_combined_tech_year_ecacountry_dealcountry <- df_combined_tech_year_ecacountry_dealcountry %>%
  left_join(df_iso3_iso2 %>% select(dealcountry_iso2 = "iso2", dealcountry_iso3 = "iso3"), by = "dealcountry_iso2")

# overwrite the ISO3 codes in the shapefile for Kosovo and South Sudan with their proper values
world <- world %>% mutate(iso3 = case_when(sovereignt == "South Sudan" & iso3 == "SDS" ~ "SSD",
                                  sovereignt == "Kosovo" & iso3 == "KOS" ~ "XKX",
                                  TRUE ~ iso3))

# ensure that all deal countries are in the world shapefile
if(sum(!df_combined_tech_year_ecacountry_dealcountry$dealcountry_iso3 %in% world$iso3) > 0) stop("Some deal countries are missing in the world shapefile")

# ensure that all deal country ISO3 values feature in the matching file
if(mean(df_combined_tech_year_ecacountry_dealcountry$dealcountry_iso3 %in% df_iso3_iso2$iso3) != 1) stop("Some deal country ISO3 values in the combined data are not in the matching file")

# collapse cumulative ECA commitment by country and FF/RE
df_map_combined <- df_combined_tech_year_ecacountry_dealcountry %>% 
  
  # subset to FF or RE
  filter(ff_re_other %in% c("Fossil", "Renewables")) %>%
  
  # merge in the country name from df_iso3_iso2
  left_join(df_iso3_iso2 %>% select(dealcountry_iso3 = "iso3", dealcountry = "country"),
            by = "dealcountry_iso3") %>%
  
  # collapse ECA commitments by country and FF/RE
  group_by(ff_re_other, dealcountry_iso3, dealcountry) %>%
  summarise(v = sum(v_bn_larger), .groups = "drop") %>%
  
  # calculate recipient shares by FF/RE
  group_by(ff_re_other) %>%
  mutate(share = v/sum(v, na.rm = T)) %>% ungroup()

# ensure that the 'share' variable still remains below 15%
if(max(df_map_combined$share) > 0.15) stop("The share variable in df_map_combined exceeds 15%")

# create the map
panel1_combined <- ggarrange(make_ecashare_map(df_map_combined, "Fossil"),
                               make_ecashare_map(df_map_combined, "Renewables"),
                               nrow = 1, align = "hv", common.legend = T, legend = "bottom")

# ensure we have no NA iso2 code
if(sum(is.na(df_combined_tech_year_ecacountry_dealcountry$dealcountry_iso3)) > 0) stop("There are NA ISO3 dealcountry codes in the combined data")

# merge in income group and region (of deal country and ECA country) from WB data
df_combined_tech_year_ecacountry_dealcountry <- df_combined_tech_year_ecacountry_dealcountry %>%
  left_join(df_wbcountrygroups %>% select(iso3 = "Code", income_group = "Income group", dealregion = "Region"),
            by = c("dealcountry_iso3" = "iso3")) %>%
  left_join(df_wbcountrygroups %>% select(iso3 = "Code", ecaregion = "Region"),
            by = c("ecacountry_iso3" = "iso3"))

# collapse commitments by ECA country by domestic/same region/other region and FF/RE
df_countryfigure_combined <- df_combined_tech_year_ecacountry_dealcountry %>%
  
  # label activities as domestic, same-region of other region
  mutate(domestic_activity = case_when(dealcountry_iso3 == ecacountry_iso3 ~ "Same country",
                                       dealregion == ecaregion ~ "Same region",
                                       TRUE ~ "Other region")) %>%
  
  # collapse by ECA country, domestic/same region/other region and FF/RE
  group_by(ecacountry, domestic_activity, ff_re_other) %>% summarise(y_var = sum(v_bn_larger), .groups = "drop") %>%
  
  # calculate total for each ECA country and FF/RE
  group_by(ecacountry, ff_re_other) %>% mutate(total = sum(y_var)) %>% ungroup()

## identify top 10 countries for FF and RE
# FF
top10_ecacountry_ff_combined <- df_countryfigure_combined %>% filter(ff_re_other == "Fossil") %>%
  select(ff_re_other, ecacountry, total) %>% distinct() %>%
  slice_max(total, n = 10) %>%
  arrange(desc(total)) %>% mutate(rank_ff = 1:n())
# RE
top10_ecacountry_re_combined <- df_countryfigure_combined %>% filter(ff_re_other == "Renewables") %>%
  select(ff_re_other, ecacountry, total) %>% distinct() %>%
  slice_max(total, n = 10) %>%
  arrange(desc(total)) %>% mutate(rank_re = 1:n())

# merge in top10 status and collapse countries that are not in top 10 into "Other countries"
df_countryfigure_final_combined <- df_countryfigure_combined %>%
  
  # subset to fossil/RE deals
  filter(ff_re_other %in% c("Fossil", "Renewables")) %>%
  
  # join in top-10 status for FF
  left_join(top10_ecacountry_ff_combined %>% select(ff_re_other, ecacountry, rank_ff), 
            by = c("ff_re_other", "ecacountry")) %>%
  
  # and for RE
  left_join(top10_ecacountry_re_combined %>% select(ff_re_other, ecacountry, rank_re), 
            by = c("ff_re_other", "ecacountry")) %>%
  
  # create a rank variable (if not in top 10, rank = 11)
  mutate(rank = case_when(!is.na(rank_ff) ~ rank_ff,
                          !is.na(rank_re) ~ rank_re,
                          TRUE ~ 11)) %>%
  
  # collapse the commitments for countries not in the top 10
  mutate(ecacountry_grouped = if_else(rank < 11, ecacountry, "Other countries")) %>%
  group_by(ecacountry_grouped, domestic_activity, ff_re_other, rank) %>%
  summarise(y_var = sum(y_var), .groups = "drop") %>%
  
  # set the order of factor levels for the 'domestic_activity' variable
  mutate(domestic_activity = factor(domestic_activity, 
                                    levels = c("Same country", "Same region", "Other region")))

# create the panel for FF
ff_panel_combined <- df_countryfigure_final_combined %>% filter(ff_re_other == "Fossil") %>%
  
  # order countries by rank (NOTE: unit is already in USD billion)
  ggplot(aes(reorder(ecacountry_grouped, -rank), y_var)) +
  
  # bar chart with stacked bars for domestic/same region/other region
  geom_col(aes(fill = domestic_activity), alpha = 0.7) +
  
  # label axes and fill legend manually
  labs(x = "ECA country",
       y = "2013-2022 commitment\n(All instruments, USD2020 billion)", fill = "Deals located in ...") +
  
  # create a facet for fossil and renewable projects (NOTE: we have subsetted to fossil projects here, so this merely creates a facet title)
  facet_wrap(~ff_re_other, scales = "free") +
  
  # set theme elements manually
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05,
          face = "bold", size = fontsize_general),
        strip.background = element_rect(fill = "lightgrey",
                                        color = NA),
        axis.title.x = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        legend.key.size = unit(10,"pt"),
        strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt"))) +
  
  # flip axes and set y-axis lower limit to zero
  coord_flip(ylim = c(0, NA)) +
  
  # set style of fill legend manually
  guides(fill = guide_legend(nrow = 1, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# make the same panel for RE 
re_panel_combined <- df_countryfigure_final_combined %>% filter(ff_re_other == "Renewables") %>%
  
  ggplot(aes(reorder(ecacountry_grouped, -rank), y_var)) +
  
  geom_col(aes(fill = domestic_activity), alpha = 0.7) +
  
  labs(x = "ECA country",
       y = "2013-2022 commitment\n(All instruments, USD2020 billion)", fill = "Deals located in...") +
  
  facet_wrap(~ff_re_other, scales = "free") +
  
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05,
          face = "bold", size = fontsize_general),
        strip.background = element_rect(fill = "#b8d3be",
                                        color = NA),
        axis.title.x = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt")),
        legend.key.size = unit(10,"pt"),
        legend.margin= margin(0, 0, 0, 0, "pt")) +
  
  coord_flip() +
  
  guides(fill = guide_legend(nrow = 1, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))


# calculate commitment shares by income group of recipient country and by period
df_highincomepanel_combined <- df_combined_tech_year_ecacountry_dealcountry %>%
  
  # impute high-income country status for JERSEY (JE) and VENEZUELA (VE) as data points are NA in WB raw data
  mutate(wbcountryclassification_clean = case_when(dealcountry_iso2 == "JE" ~ "High income",
                                                   dealcountry_iso2 == "VE" ~ "Lower middle income",
                                                   TRUE ~ income_group)) %>% 
  
  # convert wbcountryclassification_clean into a factor variable
  mutate(wbcountryclassification_clean = factor(wbcountryclassification_clean,
                                                levels = c("Low income",
                                                           "Lower middle income",
                                                           "Upper middle income",
                                                           "High income"))) %>%
  
  # collapse ECA commitments by recipient country income group and phase
  group_by(wbcountryclassification_clean, period) %>%
  summarize(v = sum(v_bn_larger)) %>% ungroup() %>%
  
  # calculate the share of commitments by phase and income group
  group_by(period) %>% mutate(share = v/sum(v)) %>% ungroup()

# create the figure
highincome_panel_combined <- df_highincomepanel_combined %>% 
  
  # make a stacked bar chart with the phase on the x-axis and the share of commitments on the y-axis
  ggplot(aes(period, share)) +
  geom_col(aes(fill = wbcountryclassification_clean)) +
  
  # add (rounded) value labels for the share of commitments if share is > 0
  geom_label(aes(fill = wbcountryclassification_clean,
                 label = ifelse(100*round(share, 2) > 0, paste0(100*round(share, 2), "%"), NA_character_)),
             position = position_stack(vjust = 0.5, reverse = F),
             size = 6/.pt,
             label.padding = unit(0.1, "lines"),
             show.legend = F) +
  
  # set the y-axis to percentage scale
  scale_y_continuous(labels = scales::percent) +
  
  # set the fill colors manually
  scale_fill_manual(values = palette_ipcc_temp_4col) +
  
  # add labels to the x-axis and y-axis and the fill legend
  labs(fill = "Recipient country group", y = "Share in ECA commitments\n(all instruments)",
       x = NULL) +
  
  # set the theme elements manually
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05, hjust = 1, 
          face = "bold",
          size = fontsize_general),
        axis.title.x = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        legend.key.size = unit(10,"pt"),
        legend.margin= margin(0, 0, 0, 0, "pt")) +
  
  # set the style of the fill legend manually
  guides(fill = guide_legend(nrow = 2, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# combine the charts into the lower panel of Figure 5 using the patchwork package
panel2_combined <- ff_panel_combined + re_panel_combined + highincome_panel_combined +
  plot_layout(nrow = 1, widths = c(1, 1, 1.2), tag_level = "new")

# combine map and lower panel
ggarrange(panel1_combined, panel2_combined, nrow = 2, ncol = 1, align = "hv",
          heights = c(1, 1))

# save out as vector graph (300dpi, 18cm width)
ggsave(file.path("graphs",
                 paste0(Sys.Date(), " figure_geographic_implications_OCITXFcombined.pdf")),
       width = 19.5, height = 14, dpi = 300, units = "cm")

### export the source data
# a) Figure 5A
write_csv(df_map_combined %>% rename(ecacommitment_USDbn = "v"),
          file.path("data", paste0(Sys.Date(), " source_data_figure5a_OCITXFcombined.csv")))

# b) Figure 5B
write_csv(df_countryfigure_final_combined %>% select(ff_re_other, ecacountry = "ecacountry_grouped",
                                            recipient_country_is = "domestic_activity",
                                            ecacommitment_USDbn = "y_var") %>%
            arrange(ff_re_other, ecacountry),
          file.path("data", paste0(Sys.Date(), " source_data_figure5b_OCITXFcombined.csv")))

# b) Figure 5C
write_csv(df_highincomepanel_combined %>% rename(income_group = "wbcountryclassification_clean",
                                        ecacommitment_USDbn = "v"),
          file.path("data", paste0(Sys.Date(), " source_data_figure5c_OCITXFcombined.csv")))
