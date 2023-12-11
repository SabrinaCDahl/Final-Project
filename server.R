#ST558 final project Sabrina Dahl
library(shiny)
library(tidyverse)
library(dplyr)

shinyServer(function(input, output, session) {
  #dataset
  hypertension <- read_csv("Hipertension_Arterial_Mexico.csv")
  
  #creating subtabs within the Modeling tab
  output$Modeling <- renderUI({
    tabsetPanel(id="subTabPanel",
                #subtab describing the two model approaches
                tabPanel("Modeling Info", 
                         h3("model one and drawback"),
                         h3("model two and drawback")),
                #subtab where user can change pieces of the model
                tabPanel("Model Fitting"),
                #subtab where user can choose values of the predictors
                tabPanel("Prediction")
                )
  })
  
  #create the dataset that will be used in plots on data exploration tab
  bloodPressure.sum <- hypertension %>% 
    subset(select= -FOLIO_I) %>%
    group_by(tension_arterial) %>% 
    dplyr::summarise(proportion.hypertension = mean(riesgo_hipertension), n = n())
  
  activity.sum <- hypertension %>% 
    subset(select= -FOLIO_I) %>%
    group_by(actividad_total) %>% 
    dplyr::summarise(proportion.hypertension = mean(riesgo_hipertension), n = n())
  
  age.sum <- hypertension %>% 
    subset(select= -FOLIO_I) %>%
    group_by(edad) %>% 
    dplyr::summarise(proportion.hypertension = mean(riesgo_hipertension), n = n())
  
  #create plots for data exploration tab based on variable chosen from "plot" radioButton
  output$barPlot <- renderPlot({
    
    if(input$plot == "point"){
      ggplot(bloodPressure.sum, aes(x= tension_arterial, y = proportion.hypertension, size = n)) + geom_point()
    } 
    else if(input$plot == "point2") {
      ggplot(activity.sum, aes(x= actividad_total, y = proportion.hypertension, size = n)) + geom_point()
    }
    else if(input$plot == "point3") {
      ggplot(age.sum, aes(x= edad, y = proportion.hypertension, size = n)) + geom_point()
    }
  })
}
)