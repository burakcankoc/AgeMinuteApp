########### Age-Minute App ###########
## ui.R ##

#### Packages for App ####
library(tidyverse)
library(httr)
library(rvest)
library(janitor)
library(purrr)
library(hablar)
library(ggrepel)
library(worldfootballR)
library(cowplot)
library(shinythemes)
library(shinycssloaders)
library(DT)
library(colorRamps)
library(grDevices)
library(colorspace)
library(lubridate)
library(DescTools)
library(feather)
library(rPref)
library(shinyjs)
library(extrafont)
library(ggbeeswarm)
library(prismatic)
library(rsconnect)
library(shiny)
library(shinydashboard)
library(scales)
library(googlesheets4)
library(shinyscreenshot)
library(shinyWidgets)

Sys.setlocale("LC_TIME", "C")

### Loading Data

df <- read.csv("teamlist.csv")

## Define UI
ui <- fluidPage(
  useShinyjs(),
  tags$style(
    HTML(
      ## Color and Font Settings
      "
      .main-sidebar{
            background-color: #222831;
        }
      @import url('https://fonts.googleapis.com/css2?family=Ubuntu&display=swap');
      body {
        font-family: 'Ubuntu', sans-serif;
        color: #F7F7F7
      }
      body {background-color: #222831;}
      "
    )
  ),
  titlePanel(title = "",
             windowTitle = "Age - Minute Distribution"),
  ## Name displayed on the browser window
  sidebarLayout(
    sidebarPanel(style = "background-color: #222831",
                 fluidRow(column(
                   12,
                   selectInput(
                     inputId = "League",
                     label = "Select League",
                     choices = c(unique(df$League)),
                     selected = "Turkish Super League"
                   )
                 )),
                 fluidRow(
                   column(8,
                          uiOutput("Team")), ## Based on the selected league, defined on server side
                   column(
                     4,
                     br(),
                     actionButton(inputId = "make_chart",
                                  label = "Plot Graph")
                   )
                 )),
    mainPanel(
      ## Only the graph will be displayed in the Main Panel
      plotOutput("myImage", width = "auto") %>% withSpinner(color = "#44a8f3")
    )
  ),
  h4(paste0("Last updated on: September 14, 2021"), style = "color: #F7F7F7"),
  h4(
    "All stats from ",
    style = "color: #F7F7F7",
    id = "FBREF-links",
    tags$a(href = "https://fbref.com/en/comps/26/Super-Lig-Stats", target = "_blank", "Football Reference")
  ),
  h4(
    "Developed by",
    style = "color: #F7F7F7",
    id = "burakcankoc-links",
    tags$a(href = "https://www.twitter.com/burakcankoc", target = "_blank", "@burakcankoc")
  )
)