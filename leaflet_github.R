library(shiny)
library(shinydashboard)
library(highcharter)
library(DT)
library(leaflet)

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

#Shiny UI
ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "UK Crime Data"),
  
  #Dashboard tabs
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Interactive Map", tabName = "map", icon = icon("map-o"))
    )
  ),
  
  #Dashboard body and tab content
  dashboardBody(
    
    tabItems(
      
      #Dashboard tab
      tabItem(
        tabName = "dashboard",
        fluidRow(
          box(width = 12, 
              selectInput("PDdashboard", "Select Police Department", tables)
          ),
          box(width = 12, 
              #title = "Crimes per Month", solidHeader = TRUE, 
              highchartOutput("time")
          ),
          box(width = 8, 
              #title = "Types of Crime", solidHeader = TRUE,
              highchartOutput("bar")
          ),
          box( width = 4, 
               #title = "Crime Type Percentages", solidHeader = TRUE,
               highchartOutput("pie")
          ),
          box( width = 12 ,
               DT::dataTableOutput("table")
          )
        )
      ),
      
      #Map tab
      tabItem(
        tabName = "map",
        div(class="outer",
            tags$head(
              # Custom CSS
              includeCSS("styles.css"),
              includeScript("gomap.js")
            ),
            #Leaflet map
            leafletOutput("map", width="100%", height="100%"),
            #Map panel with controls for plotting markers & changing the map tiles
            absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                          draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                          width = 300, height = "auto",
                          h3("Map Controls"),
                          selectInput("crimeTypes", "Type of crime", crimes),
                          selectInput("crimeTypes2", "Second Type", crimes),
                          selectInput("mapTiles", "Select Map Layout", maps, selected = "Mapbox Streets")
                          
            )
        )
      )
      
    )
  )
)

#Shiny server
server <- function(input, output) {
  
  #React function that gets the value selected in the dropdown menu and returns the corresponding table with crime totals for use in the charts
  reactDashboard <- reactive({
    get(input$PDdashboard)
  })
  
  #React function that gets the value selected in the dropdown menu and returns a string for use with the subset functions used
  reactDataTable <- reactive({
    if ( input$PDdashboard == "greater_manchester_table") {
      return("Greater Manchester Police")
    } else if ( input$PDdashboard == "metropolitan_table") {
      return("Metropolitan Police Service")
    } else if ( input$PDdashboard == "west_midlands_table") {
      return("West Midlands Police")
    }
  })
  
  #React function that gets the value selected in the dropdown menu and returns the corresponding table with crime outcomes for use in the column chart
  reactOutcomes <- reactive({
    if ( input$PDdashboard == "greater_manchester_table") {
      get("greater_manchester_outcomes")
    } else if ( input$PDdashboard == "metropolitan_table") {
      get("metropolitan_outcomes")
    } else if ( input$PDdashboard == "west_midlands_table") {
      get("west_midlands_outcomes")
    }
  })
  
  #Highchart Time Series plot
  output$time <- renderHighchart({
    hc <- ts(start = c(2016,1), end = c(2016,12), frequency = 12, data = as.matrix(reactDashboard()))
    highchart(type = "stock") %>% 
      hc_yAxis(title = list(text = "Number of crimes"), opposite = FALSE) %>%
      hc_xAxis(title = list(text = "Months")) %>%
      hc_legend(enabled = TRUE) %>%
      hc_navigator(height = 20) %>%
      hc_scrollbar(enabled = FALSE) %>%
      hc_rangeSelector(allButtonsEnabled = TRUE) %>%
      hc_colors(c('#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#8085e8', '#8d4653', '#91e8e1', '#AFB3F7', '#517664', '#E08DAC', '#BA324F')) %>%
      hc_add_series(hc[,1],  name = crimes_table[1])  %>% hc_add_series(hc[,2],  name = crimes_table[2])  %>% hc_add_series(hc[,3],  name = crimes_table[3]) %>% 
      hc_add_series(hc[,4],  name = crimes_table[4])  %>% hc_add_series(hc[,5],  name = crimes_table[5])  %>% hc_add_series(hc[,6],  name = crimes_table[6]) %>% 
      hc_add_series(hc[,7],  name = crimes_table[7])  %>% hc_add_series(hc[,8],  name = crimes_table[8])  %>% hc_add_series(hc[,9],  name = crimes_table[9]) %>% 
      hc_add_series(hc[,10], name = crimes_table[10]) %>% hc_add_series(hc[,11], name = crimes_table[11]) %>% hc_add_series(hc[,12], name = crimes_table[12]) %>% 
      hc_add_series(hc[,13], name = crimes_table[13]) %>% hc_add_series(hc[,14], name = crimes_table[14]) 
  })
  
  #Highchart Column plot
  output$bar <- renderHighchart({ 
    hc = as.data.frame(rowSums(t(reactDashboard())), row.names = crimes_table2)
    highchart() %>%
      hc_chart(type = "column", spacingLeft = 0) %>%
      hc_xAxis(type = 'category', showEmpty = FALSE ) %>%
      hc_yAxis(title = list(text = "Total crimes")) %>%
      hc_plotOptions(column = list(pointWidth = 30) ) %>%
      hc_legend(enabled = FALSE) %>%
      hc_colors(c('#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#8085e8', '#8d4653', '#91e8e1', '#AFB3F7', '#517664', '#E08DAC', '#BA324F')) %>%
      hc_add_series(name = row.names(hc)[1] , data = list( list(name = row.names(hc)[1],  y = hc[1,1],  drilldown = "drill1" ))) %>% 
      hc_add_series(name = row.names(hc)[2] , data = list( list(name = row.names(hc)[2],  y = hc[2,1],  drilldown = "drill2" ))) %>%
      hc_add_series(name = row.names(hc)[3] , data = list( list(name = row.names(hc)[3],  y = hc[3,1],  drilldown = "drill3" ))) %>%
      hc_add_series(name = row.names(hc)[4] , data = list( list(name = row.names(hc)[4],  y = hc[4,1],  drilldown = "drill4" ))) %>%
      hc_add_series(name = row.names(hc)[5] , data = list( list(name = row.names(hc)[5],  y = hc[5,1],  drilldown = "drill5" ))) %>%
      hc_add_series(name = row.names(hc)[6] , data = list( list(name = row.names(hc)[6],  y = hc[6,1],  drilldown = "drill6" ))) %>%
      hc_add_series(name = row.names(hc)[7] , data = list( list(name = row.names(hc)[7],  y = hc[7,1],  drilldown = "drill7" ))) %>%
      hc_add_series(name = row.names(hc)[8] , data = list( list(name = row.names(hc)[8],  y = hc[8,1],  drilldown = "drill8" ))) %>%
      hc_add_series(name = row.names(hc)[9] , data = list( list(name = row.names(hc)[9],  y = hc[9,1],  drilldown = "drill9" ))) %>%
      hc_add_series(name = row.names(hc)[10], data = list( list(name = row.names(hc)[10], y = hc[10,1], drilldown = "drill10"))) %>%
      hc_add_series(name = row.names(hc)[11], data = list( list(name = row.names(hc)[11], y = hc[11,1], drilldown = "drill11"))) %>%
      hc_add_series(name = row.names(hc)[12], data = list( list(name = row.names(hc)[12], y = hc[12,1], drilldown = "drill12"))) %>%
      hc_add_series(name = row.names(hc)[13], data = list( list(name = row.names(hc)[13], y = hc[13,1], drilldown = "drill13"))) %>%
      hc_add_series(name = row.names(hc)[14], data = list( list(name = row.names(hc)[14], y = hc[14,1], drilldown = "drill14"))) %>%
      hc_drilldown(series = list(list(id  = "drill1",  name = row.names(hc)[1], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,2]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,2]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,2]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,2]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,2]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,2]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,2]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,2]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,2]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,2]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,2]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,2]), 
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,2]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,2]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,2]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,2]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,2]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,2]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,2]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,2]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,2]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,2]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,2]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,2]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,2]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,2]))),
                                 
                                 list(id  = "drill2",  name = row.names(hc)[2], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,3]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,3]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,3]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,3]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,3]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,3]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,3]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,3]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,3]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,3]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,3]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,3]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,3]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,3]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,3]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,3]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,3]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,3]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,3]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,3]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,3]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,3]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,3]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,3]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,3]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,3]))),
                                 
                                 list(id  = "drill3",  name = row.names(hc)[3], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,4]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,4]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,4]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,4]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,4]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,4]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,4]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,4]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,4]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,4]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,4]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,4]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,4]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,4]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,4]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,4]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,4]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,4]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,4]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,4]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,4]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,4]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,4]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,4]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,4]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,4]))),
                                 
                                 list(id  = "drill4",  name = row.names(hc)[4], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,5]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,5]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,5]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,5]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,5]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,5]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,5]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,5]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,5]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,5]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,5]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,5]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,5]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,5]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,5]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,5]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,5]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,5]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,5]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,5]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,5]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,5]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,5]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,5]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,5]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,5]))),
                                 
                                 list(id  = "drill5",  name = row.names(hc)[5], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,6]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,6]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,6]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,6]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,6]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,6]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,6]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,6]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,6]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,6]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,6]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,6]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,6]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,6]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,6]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,6]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,6]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,6]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,6]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,6]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,6]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,6]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,6]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,6]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,6]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,6]))),
                                 
                                 list(id  = "drill6",  name = row.names(hc)[6], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,7]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,7]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,7]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,7]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,7]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,7]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,7]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,7]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,7]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,7]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,7]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,7]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,7]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,7]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,7]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,7]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,7]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,7]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,7]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,7]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,7]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,7]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,7]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,7]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,7]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,7]))),
                                 
                                 list(id  = "drill7",  name = row.names(hc)[7], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,8]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,8]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,8]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,8]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,8]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,8]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,8]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,8]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,8]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,8]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,8]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,8]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,8]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,8]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,8]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,8]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,8]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,8]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,8]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,8]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,8]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,8]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,8]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,8]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,8]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,8]))),
                                                                                             
                                 
                                 list(id  = "drill8",  name = row.names(hc)[8], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,9]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,9]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,9]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,9]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,9]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,9]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,9]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,9]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,9]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,9]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,9]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,9]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,9]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,9]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,9]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,9]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,9]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,9]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,9]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,9]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,9]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,9]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,9]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,9]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,9]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,9]))),
                                 
                                 list(id  = "drill9",  name = row.names(hc)[9], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,10]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,10]),
                                                                                            list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,10]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,10]),
                                                                                            list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,10]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,10]),
                                                                                            list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,10]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,10]),
                                                                                            list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,10]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,10]),
                                                                                            list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,10]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,10]),
                                                                                            list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,10]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,10]),
                                                                                            list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,10]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,10]),
                                                                                            list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,10]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,10]),
                                                                                            list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,10]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,10]),
                                                                                            list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,10]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,10]),
                                                                                            list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,10]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,10]),
                                                                                            list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,10]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,10]))),
                                 
                                 list(id  = "drill10", name = row.names(hc)[10], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,11]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,11]),
                                                                                             list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,11]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,11]),
                                                                                             list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,11]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,11]),
                                                                                             list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,11]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,11]),
                                                                                             list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,11]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,11]),
                                                                                             list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,11]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,11]),
                                                                                             list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,11]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,11]),
                                                                                             list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,11]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,11]),
                                                                                             list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,11]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,11]),
                                                                                             list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,11]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,11]),
                                                                                             list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,11]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,11]),
                                                                                             list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,11]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,11]),
                                                                                             list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,11]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,11]))),
                                 
                                 list(id  = "drill11", name = row.names(hc)[11], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,12]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,12]),
                                                                                             list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,12]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,12]),
                                                                                             list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,12]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,12]),
                                                                                             list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,12]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,12]),
                                                                                             list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,12]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,12]),
                                                                                             list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,12]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,12]),
                                                                                             list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,12]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,12]),
                                                                                             list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,12]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,12]),
                                                                                             list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,12]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,12]),
                                                                                             list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,12]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,12]),
                                                                                             list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,12]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,12]),
                                                                                             list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,12]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,12]),
                                                                                             list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,12]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,12]))),
                                 
                                 list(id  = "drill12", name = row.names(hc)[12], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,13]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,13]),
                                                                                             list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,13]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,13]),
                                                                                             list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,13]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,13]),
                                                                                             list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,13]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,13]),
                                                                                             list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,13]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,13]),
                                                                                             list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,13]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,13]),
                                                                                             list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,13]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,13]),
                                                                                             list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,13]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,13]),
                                                                                             list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,13]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,13]),
                                                                                             list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,13]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,13]),
                                                                                             list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,13]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,13]),
                                                                                             list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,13]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,13]),
                                                                                             list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,13]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,13]))),
                                 
                                 list(id  = "drill13", name = row.names(hc)[13], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,14]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,14]),
                                                                                             list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,14]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,14]),
                                                                                             list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,14]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,14]),
                                                                                             list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,14]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,14]),
                                                                                             list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,14]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,14]),
                                                                                             list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,14]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,14]),
                                                                                             list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,14]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,14]),
                                                                                             list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,14]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,14]),
                                                                                             list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,14]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,14]),
                                                                                             list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,14]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,14]),
                                                                                             list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,14]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,14]),
                                                                                             list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,14]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,14]),
                                                                                             list(name = reactOutcomes()[24,1], y = reactOutcomes()[25,14]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,14]))),
                                 
                                 list(id  = "drill14", name = row.names(hc)[14], data = list(list(name = reactOutcomes()[1 ,1], y = reactOutcomes()[1 ,15]), list(name = reactOutcomes()[2 ,1], y = reactOutcomes()[2 ,15]),
                                                                                             list(name = reactOutcomes()[3 ,1], y = reactOutcomes()[3 ,15]), list(name = reactOutcomes()[4 ,1], y = reactOutcomes()[4 ,15]),
                                                                                             list(name = reactOutcomes()[5 ,1], y = reactOutcomes()[5 ,15]), list(name = reactOutcomes()[6 ,1], y = reactOutcomes()[6 ,15]),
                                                                                             list(name = reactOutcomes()[7 ,1], y = reactOutcomes()[7 ,15]), list(name = reactOutcomes()[8 ,1], y = reactOutcomes()[8 ,15]),
                                                                                             list(name = reactOutcomes()[9 ,1], y = reactOutcomes()[9 ,15]), list(name = reactOutcomes()[10,1], y = reactOutcomes()[10,15]),
                                                                                             list(name = reactOutcomes()[11,1], y = reactOutcomes()[11,15]), list(name = reactOutcomes()[12,1], y = reactOutcomes()[12,15]),
                                                                                             list(name = reactOutcomes()[13,1], y = reactOutcomes()[13,15]), list(name = reactOutcomes()[14,1], y = reactOutcomes()[14,15]),
                                                                                             list(name = reactOutcomes()[15,1], y = reactOutcomes()[15,15]), list(name = reactOutcomes()[16,1], y = reactOutcomes()[16,15]),
                                                                                             list(name = reactOutcomes()[17,1], y = reactOutcomes()[17,15]), list(name = reactOutcomes()[18,1], y = reactOutcomes()[18,15]),
                                                                                             list(name = reactOutcomes()[19,1], y = reactOutcomes()[19,15]), list(name = reactOutcomes()[20,1], y = reactOutcomes()[20,15]),
                                                                                             list(name = reactOutcomes()[21,1], y = reactOutcomes()[21,15]), list(name = reactOutcomes()[22,1], y = reactOutcomes()[22,15]),
                                                                                             list(name = reactOutcomes()[23,1], y = reactOutcomes()[23,15]), list(name = reactOutcomes()[24,1], y = reactOutcomes()[24,15]),
                                                                                             list(name = reactOutcomes()[25,1], y = reactOutcomes()[25,15]), list(name = reactOutcomes()[26,1], y = reactOutcomes()[26,15])))
      ))
  })
  
  #Highchart Pie chart
  output$pie <- renderHighchart({
    hc = round((as.data.frame(rowSums(t(reactDashboard())), row.names = crimes_table2)[,1]/rowSums(t(as.data.frame(rowSums(t(reactDashboard())), row.names = crimes_table2))))*100)
    highchart() %>% 
      hc_chart(type = "pie") %>% 
      hc_plotOptions(pie = list(allowPointSelect = TRUE, options3d = list(enabled = TRUE), dataLabels = list(enabled = TRUE, distance = -30, color = 'white', format = "{point.y}%"),
                                showInLegend = TRUE, cursor = "pointer")) %>%
      hc_legend(enabled = TRUE, title = list(text = "Types of Crime"), align = "right", layout = "vertical", verticalAlign = "middle") %>%
      hc_colors(c('#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#8085e8', '#8d4653', '#91e8e1', '#AFB3F7', '#517664', '#E08DAC', '#BA324F')) %>%
      hc_add_series_labels_values(name = "Total Crime %", crimes_table2, hc )
  })
  
  #DataTable
  output$table <- DT::renderDataTable({
    DT::datatable(data = subset(dataset,dataset$Falls.within==reactDataTable())[c(1,5,6,7)], filter = 'top')
  })
  
  #Leaflet map
  output$map <- renderLeaflet({
    leaflet() %>%
    addTiles(
      urlTemplate = input$mapTiles
      #urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png"
    ) %>%   
    setView(
      lng = -1.46, lat = 52.56, zoom = 7
    ) 
  })
  
  observe({
    leafletProxy("map", data = dataset) %>%
      clearShapes() %>% 
      clearMarkerClusters() %>% 
      addTiles(
        urlTemplate = input$mapTiles
        #urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png"
      ) %>%
      setView(
        lng = -1.46, lat = 52.56, zoom = 7
      ) %>% 
      clearMarkers() %>% 
      addCircleMarkers(
        data = subset(dataset,dataset$Crime.type==input$crimeTypes), 
        lat = ~Latitude, lng = ~Longitude, 
        color = "red", weight = 0.5,
        clusterOptions = markerClusterOptions(disableClusteringAtZoom = 14),
        layerId=~ID, clusterId = 1
      ) %>% 
      addCircleMarkers(
        data = subset(dataset,dataset$Crime.type==input$crimeTypes2), 
        lat = ~Latitude, lng = ~Longitude, 
        color = "blue", weight = 0.5,
        clusterOptions = markerClusterOptions(disableClusteringAtZoom = 14),
        layerId=~ID, clusterId = 2
      )
  })
  
  #Function to show a popup at the given location with information about this crime
  showPopup <- function(selectedPopup, lat, lng) {
    selectedId <- dataset[dataset$ID == selectedPopup,]
    content <- as.character(tagList(
      tags$strong(HTML(sprintf("PD: "))), (HTML(sprintf("%s", selectedId$Falls.within))), tags$br(),
      tags$strong(HTML(sprintf("Month: "))), (HTML(sprintf("%s", selectedId$Month))), tags$br(),
      tags$strong(HTML(sprintf("Location: "))), (HTML(sprintf("%s", selectedId$Location))), tags$br(),
      tags$strong(HTML(sprintf("Crime type: "))), (HTML(sprintf("%s", selectedId$Crime.type))), tags$br(),
      tags$strong(HTML(sprintf("Outcome: "))), (HTML(sprintf("%s", selectedId$Last.outcome.category))), tags$br()
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = selectedPopup)
  }
  
  #When a marker is clicked, get the id, latitude and longitude and show a popup 
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_marker_click
    if (is.null(event))
      return()
    
    isolate({
      showPopup(event$id, event$lat, event$lng)
    })
  })
}

#Shiny app
shinyApp(ui = ui, server = server)
