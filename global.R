#Data Loading
dataset = readRDS(file = "police_data.rds")

#Noise added to coordinates for better visualisation on the map
dataset$Latitude = jitter(dataset$Latitude)
dataset$Longitude = jitter(dataset$Longitude)

#Crimes Total Tables Loading
west_midlands_table = readRDS(file = "west_midlands_table.rds")
greater_manchester_table = readRDS(file = "greater_manchester_table.rds")
metropolitan_table = readRDS(file = "metropolitan_table.rds")

#Crime Outcomes Tables loading 
west_midlands_outcomes = readRDS(file = "west_midlands_outcomes.rds")
greater_manchester_outcomes = readRDS(file = "greater_manchester_outcomes.rds")
metropolitan_outcomes = readRDS(file = "metropolitan_outcomes.rds")

#Lists for dropdown menus, row/column names & chart legends
tables <- c("Greater Manchester Police" = "greater_manchester_table", "Metropolitan Police Service" = "metropolitan_table", "West Midlands Police" = "west_midlands_table" )
month = c("Jan 2016", "Feb 2016", "Mar 2016", "Apr 2016", "May 2016", "Jun 2016", "Jul 2016", "Aug 2016", "Sep 2016", "Oct 2016", "Nov 2016", "Dec 2016")
crimes <- c(
  "--Please select--",  "Anti-social behaviour", "Bicycle theft", "Burglary", "Criminal damage and arson", "Drugs", "Other crime", "Other theft",
  "Possession of weapons", "Public order", "Robbery", "Shoplifting", "Theft from the person" , "Vehicle crime", "Violence and sexual offences"
)
crimes_table <- c(
  "Anti-social behaviour", "Bicycle theft", "Burglary", "Criminal damage and arson", "Drugs", "Other crime", "Other theft",
  "Possession of weapons", "Public order", "Robbery", "Shoplifting", "Theft from the person" , "Vehicle crime", "Violence and sexual offences"
)
crimes_table2 <- c(
  "Anti-social <br/> behaviour", "Bicycle theft", "Burglary", "Criminal damage <br/> and arson", "Drugs", "Other crime", "Other theft",
  "Possession of <br/> weapons", "Public order", "Robbery", "Shoplifting", "Theft from <br/> the person" , "Vehicle crime", "Violence and <br/> sexual offences"
)

tables2 <- c("Greater Manchester Police" = "greater_manchester_table", "Metropolitan Police Service" = "metropolitan_table", "West Midlands Police" = "west_midlands_table" )
tables3 <- list("Greater Manchester Police" = c("greater_manchester_table", "Greater Manchester Police"),
                "Metropolitan Police Service" = c("metropolitan_table", "Metropolitan Police Service"),
                "West Midlands Police" = c("west_midlands_table", "West Midlands Police"))

#Map Tiles URLs
maps <- c(
  "Mapbox Streets" = "https://api.mapbox.com/styles/v1/mapbox/streets-v10/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic2tvbnRhcmFraXMiLCJhIjoiY2oyczc2ZnY5MDAyNDMzbzRrNWJkaDh5ZiJ9.nnCAMZlKcIomHwxFKiIGPQ",
  "Mapbox Satelite" = "https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v10/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic2tvbnRhcmFraXMiLCJhIjoiY2oyczc2ZnY5MDAyNDMzbzRrNWJkaDh5ZiJ9.nnCAMZlKcIomHwxFKiIGPQ",
  "Mapbox Outdoors" = "https://api.mapbox.com/styles/v1/mapbox/outdoors-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoic2tvbnRhcmFraXMiLCJhIjoiY2oyczc2ZnY5MDAyNDMzbzRrNWJkaDh5ZiJ9.nnCAMZlKcIomHwxFKiIGPQ",
  "Mapbox Dark" = "https://api.mapbox.com/styles/v1/mapbox/dark-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoic2tvbnRhcmFraXMiLCJhIjoiY2oyczc2ZnY5MDAyNDMzbzRrNWJkaDh5ZiJ9.nnCAMZlKcIomHwxFKiIGPQ",
  "Mapbox Light" = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoic2tvbnRhcmFraXMiLCJhIjoiY2oyczc2ZnY5MDAyNDMzbzRrNWJkaDh5ZiJ9.nnCAMZlKcIomHwxFKiIGPQ",
  "Mapbox V1" = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png"
)
