library(shiny)
library(shinydashboard)
library(highcharter)
library(DT)
library(leaflet)

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