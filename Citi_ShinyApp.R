library(shiny); library(nlme); library(mgcv); library(leaflet); 
#setwd('C:/Users/griev/Documents/TDI/citibike/publish')
#load('publishdata.RData')

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("CitiBike Usage"),
  
  # Sidebar with a slider input for conditions
  sidebarLayout(
    sidebarPanel(
      sliderInput("TMAX","Maximum Temperature (F)", min = 18, max = 94, value = 60),
      sliderInput("PRCP","Total Precipitation (IN)", min = 0, max = 3, value = 0, step = .5),
      sliderInput("AWND","Average Wind Speed (knots)", min = 2, max = 15, value = 5),
      selectInput('weekend','Is it a weekend?',c(0,1)),

    ),
    
    # Show a map of the stations
    mainPanel(
      leafletOutput("nycmap", width = 1000, height = 1000)
    )
  )
)

# Define server logic required to draw map
server <- function(input, output) {
  # Get station coordinates and initial slider conditions
  new_stid = u_stid; new_stid$rides = NA; 
  initconditions = data.frame(TMAX = 60, PRCP = 0, AWND=5, weekend=0)
  initvec = numeric(length(gamlist))
  for (i in 1:length(gamlist)){
    initvec[i] = predict.gam(gamlist[[i]], newdata=initconditions, type='response')}
  
  # Get new prediction dataframe
  preds = new_stid; 
  preds$init = initvec; 
  preds$rides = NA;
  
  # Set colormap
  pal = colorBin(palette = 'YlOrRd',domain = 0:450, bins = 9)
  
  # Render initial map
  output$nycmap <- renderLeaflet({
    leaflet(data=preds) %>%
      setView(lng = -73.9752, lat = 40.7318, zoom = 12) %>% # Set initial view
      addProviderTiles(providers$CartoDB.Positron) %>% # Add map 
      addLegend(pal = pal, values = preds2$init, opacity = 1) # Add legend
  })

  # Model and map slider input conditions
  observe({
    # Get slider conditions
    newdata = data.frame(TMAX = input$TMAX, PRCP = input$PRCP, AWND=input$AWND, weekend=input$weekend);
    
    # Predict input variables
    nvec = numeric(length(gamlist))
    for (i in 1:length(gamlist)){
      nvec[i] = predict.gam(gamlist[[i]],newdata=newdata,type='response')}
    preds$rides = nvec
    
    # same colormap as initial 
    nvec[nvec>450]=450 
    pal = colorBin(palette = 'YlOrRd',domain = 0:450, bins = 9)
    
    # plot new maps
    leafletProxy('nycmap') %>% clearMarkers() %>%
      addCircleMarkers(lng= preds2$Start.Station.Longitude ,lat= preds2$Start.Station.Latitude, color = pal(preds2$rides), opacity = 1,radius = 1)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
