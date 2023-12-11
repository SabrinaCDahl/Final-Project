#ST558 final project Sabrina Dahl
library(ggplot2)
library(shinyWidgets)
library(shinydashboard)

shinyUI(fluidPage(
mainPanel(
  tabsetPanel(id="tabset",
    #tab for describing the app
    tabPanel(title="About", h3("purpose of the app"),
             h3("describe the data- providing the link"),
             h3("purpose of each tab"),
             h3("include a picture")),
    #tab for developing graphs and summaries from dataset
    tabPanel(title="Data Exploration",
             fluidRow(column(4,
                 radioButtons("plot", "Select the variable to plot vs proportion.hypertension", choices = list("Blood Pressure"="point", "Total Activity"="point2", "Age"="point3"), selected = "point")
               ),
             column(8,
               plotOutput("barPlot")
             ))
             ),
    #tab for developing models from dataset
    tabPanel(title="Modeling", uiOutput("Modeling"))
  )
)))