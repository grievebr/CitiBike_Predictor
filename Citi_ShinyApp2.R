library(shiny); library(nlme); library(mgcv); library(leaflet); 
#setwd('C:/Users/griev/Documents/TDI/citibike/publish')
#load('publishdata.RData')

projectdescription = 'Citi Bike is a bike-sharing program launched in 2013 in New York City. It allows anyone to rent a bike off any of the 750+ racks throughout the city, ride to their destination, and leave the bike on any nearby Citi rack, providing a convenient form of transportation for citizens and tourists alike. However, this can occasionally lead to an imbalance of bikes overflowing in some locations and scarce in another. As a result, bikes need to be redistributed periodically. Being better able to predict demand will help both Citi Bike and consumers determine where bikes may be available. 

This app helps solve that problem by predicting the daily rides at each station in the city based on weather conditions. I trained the model on the 2017 ride data (16.3 million rides, .5 GB) and matched it to weather conditions on each day of the dataset. Ridership was modeled to max temperature, mean wind speed, total precipitation, and a weekend boolean using a generalized additive model for each station. Ridership can then be predicted by the user with this R Shiny app. 

Model results varied by station. Mean R2 value was 0.42 with a standard deviation of 0.17. Predictions were sensitive to changing conditions, showing that the model went beyond reflecting temporal trends. The app is useful for both Citi Bike and its consumers, especially when combined with live data Citi possesses. Continued model improvements include using more training data, explicitly accounting for temporal trends, and adding more weather features.'


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
      submitButton('Update Map')

  ),
    
  # Sidebar for text
  #sidebarLayout(
  #  mainPanel('information!'),
    #position = 'right'
  #),
  
  
  # Show a map of the stations
  mainPanel(
    tabsetPanel(
      tabPanel('Map',leafletOutput("nycmap", width = 1000, height = 1000)),
      tabPanel('Description',projectdescription)
    )),
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
      addLegend(pal = pal, values = preds$init, opacity = 1) # Add legend
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
      addCircleMarkers(lng= preds$Start.Station.Longitude ,lat= preds$Start.Station.Latitude, color = pal(preds$rides), opacity = 1,radius = 1)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
