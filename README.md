# CitiBike_Predictor
Widget that will predict and map Citi Bike usage based on weather conditions
http://grievebr.shinyapps.io/citibike

Citi Bike is a bike-sharing program launched in 2013 in New York City. It allows anyone to rent a bike off any of the 750+ racks throughout the city, ride to their destination, and leave the bike on any nearby Citi rack, providing a convenient form of transportation for citizens and tourists alike. However, this can occasionally lead to an imbalance of bikes overflowing in some locations and scarce in another. As a result, bikes need to be redistributed periodically. Being better able to predict demand will help both Citi Bike and consumers determine where bikes may be available. 

This app helps solve that problem by predicting the daily rides at each station in the city based on weather conditions. I used a subset of the available ride data (September-November 2017) and matched it to weather conditions on each day of the dataset. Ridership was modeled to max temperature, mean wind speed, total precipitation, and a weekend boolean using a generalized additive model for each station. Ridership can then be predicted by the user with this R Shiny app. 

Model results varied by station. Mean R2 value was 0.42 with a standard deviation of 0.17 (N = 5.1 million). Predictions were sensitive to changing conditions, showing that the model went beyond reflecting temporal trends. The app is useful for both Citi Bike and its consumers, especially when combined with live data Citi possesses. Continued model improvements include using more training data, explicitly accounting for temporal trends, and adding more weather features. 
