# Create polyline for grabbing points
# Polyline for east --> west and west --> east

#### SETUP
key <- api_keys$Key[api_keys$Account == "robmarty3@gmail.com" & api_keys$Service == "Google Directions API"]

point_east <- "30.043905,47.918274"
point_west <- "33.434243, 38.907902"

# East --> West ----------------------------------------------------------------
url <- paste0("https://maps.googleapis.com/maps/api/directions/xml?origin=",
              point_east,"&destination=",point_west,
              "&traffic_model=best_guess&departure_time=now&alternatives=F&key=",
              key)
url <- utils::URLencode(url)
out <- xml2::read_xml(url)
status <- out %>% xml_find_all(sprintf("/DirectionsResponse/status")) %>% xml_text
route_east_west <- mp_get_routes(out)



leaflet() %>%
  addTiles() %>%
  addPolylines(data=route_east_west)




