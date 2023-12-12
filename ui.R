#ST558 final project Sabrina Dahl
library(ggplot2)
library(shinyWidgets)
library(shinydashboard)

shinyUI(fluidPage(
mainPanel(
  tabsetPanel(id="tabset",
    #tab for describing the app
    tabPanel(title="About", h4("The purpose of this app is to create two models and then compare how well each of those models were able to predict whether an indiviudal will be at risk or not at risk of hypertension."),
             h4("We will be using the data from ", a("kaggle", href="https://www.kaggle.com/datasets/frederickfelix/hipertensin-arterial-mxico"), ". This dataset was collected from the National Health and Nutrition Survey. The dataset includes biometric information about the health of patients in Mexico including Sex, Age, Hemoglobin Concentration, Cholesterol, weight, height, and whether they're risk of developing arterial hypertension."),
             h4("The app has 3 main tabs- About, Data Exploration, and Modeling. You are currently on the About tab describing the purpose of this app. The Data Exploration tab will allow the user to create multiple plots from the dataset to explore any trends and get comfortable with the data. The Modeling tab will develop two different models that will predict an individuals risk factor for developing arterial hypertension."),
             tags$figure(
               class="centerFigure",
               tags$image(
                 src="PAH.png",
                 alt="Pulmonary Arterial Hypertension"
               )
             )),
    #tab for developing graphs and summaries from the dataset
    tabPanel(title="Data Exploration",
             fluidRow(column(4,
                 radioButtons("plot", "Select the variable to plot vs proportion.hypertension", choices = list("Blood Pressure"="point", "Total Activity"="point2", "Age"="point3"), selected = "point")
               ),
             column(8,
               plotOutput("barPlot")
             ))
             ),
    #tab for developing models from the dataset
    tabPanel(title="Modeling", uiOutput("Modeling"))
  )
)))