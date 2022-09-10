#' Get Worldwide GIS Codes
#' @description The function pull from the John Hopkins Coronavirus repo a table with most common GIS codes per 
#' country (i.e., uid, iso2, iso3, etc.)
#' @param url The table raw URL


get_gis_codes <- function(url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv"){
  gis_codes <- readr::read_csv(url, 
                               col_types = readr::cols(FIPS = readr::col_number(),
                                                       Admin2 = readr::col_character())
  )
  names(gis_codes) <- tolower(names(gis_codes))
  names(gis_codes)[which(names(gis_codes) == "long_")] <- "long"
  return(gis_codes)
} 


#' Data Transformation
#' @description A transforming function for the coronavirus dataset 
#'
coronavirus_agg <- function(coronavirus_jhu = coronavirus::refresh_coronavirus_jhu(),
                            gis_codes = get_gis_codes()){
  
  df <- coronavirus_jhu %>%
    dplyr::filter(location_type == "country") %>%
    dplyr::left_join(gis_codes %>% 
                       dplyr::filter(is.na(province_state)) %>%
                       dplyr::filter(country_region == combined_key) %>%
                       dplyr::select(location = country_region, population), 
                     by = c("location"))
  
  
  df_agg <- df %>% 
    dplyr::filter(location_type == "country",
                  data_type != "recovered_new") %>%
    # dplyr::filter(location == combined_key ) %>%
    tidyr::pivot_wider(names_from = data_type, values_from = value) %>%
    dplyr::group_by(location) %>%
    dplyr::summarise(confirmed = sum(cases_new),
                     death = sum(deaths_new)) %>%
    dplyr::arrange(- death) %>%
    dplyr::left_join(gis_codes %>% 
                       dplyr::filter(is.na(province_state)) %>%
                       dplyr::select(location = combined_key, population) %>% 
                       dplyr::distinct(),
                     by = "location") %>%
    dplyr::mutate(rate = death / confirmed,
                  rate_pop = death / population,
                  death_per_100k = death / (population / 100000)) %>%
    dplyr::arrange(-death_per_100k) %>%
    dplyr::filter(!is.na(population))
  
  return(df_agg)
}