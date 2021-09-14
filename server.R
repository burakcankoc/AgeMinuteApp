########### Age-Minute App ###########
## server.R ##

df <- read.csv("teamlist.csv")


## Define server
server <- function(input, output, session) {
  output$Team = renderUI({
    data_available = df[df$League == req(input$League),]
    
    selectInput(
      inputId = "Team",
      label = "Select Team",
      choices = c(unique(data_available$Team)),
      selected = "Galatasaray"
    )
  })
  
  ########### -------- Data for Plotting -------- ############
  
  dfplot <- eventReactive(input$make_chart,
                          {
                            url <- df %>%
                              filter(Team == input$Team) %>%
                              select(TeamURL) %>%
                              as.character()
                            
                            dfplot <- read_html(url) %>%
                              html_table() %>%
                              pluck(1) %>%
                              row_to_names(row_number = 1) %>%
                              select(1:10) %>%
                              mutate(
                                Team = gsub(
                                  basename(url),
                                  pattern = "-",
                                  replacement = " "
                                ),
                                Team = gsub(Team, pattern = " Stats", replacement = ""),
                                Age = stringr::str_extract(Age, "^.{2}"),
                                Pos = stringr::str_extract(Pos, "^.{2}")
                              ) %>%
                              retype() %>%
                              filter(row_number() <= n() - 2)
                          })
  
  output$myImage <- renderImage({
    width  <- max(session$clientData$output_myImage_width, 1200)
    height <- width * 0.75
    
    check <- input$make_chart
    
    isolate({
      dat <- na.omit(dfplot())
      weighAvg <- round(weighted.mean(dat$Age, dat$Min), 2)
      
      SelectedTeam = input$Team
      
      title_lab = paste0("Age-Minute Distribution of\n", SelectedTeam)
      subtitle_lab = paste0("Minutes Weighted Avg. Age: ", weighAvg)
      caption_lab1 = paste0("graph: @burakcankoc\nsource: football-reference.com")
      caption_lab2 = paste0("League Games Only\nChart created on ",
                            format(Sys.Date(), "%B %d, %Y"))
      
      x_lab = "Age"
      y_lab = "Minutes Played"
      
      maxMin <- max(dat$Min)
      minMin <- 0
      
      maxAge <- max(dat$Age)
      minAge <- min(dat$Age)
      
      
      Plot <- dat %>%
        ggplot(aes(x = Age, y = Min)) +
        geom_rect(aes(
          xmin = 23,
          xmax = 30,
          ymin = -Inf,
          ymax = Inf
        ),
        alpha = 0.01,
        fill = 'grey') +
        geom_point(aes(col = Pos), size = 3) +
        geom_text_repel(
          box.padding = 0.3,
          min.segment.length = unit(0.05, "lines"),
          aes(label = Player),
          colour = "#F7F7F7",
          size = 2
        ) +
        scale_color_brewer(palette = "Spectral",
                           breaks = c("GK", "DF", "MF", "FW"))  +
        scale_x_continuous(breaks = seq(minAge, maxAge, 1)) +
        scale_y_continuous(breaks = seq(0, maxMin, 90)) +
        theme_minimal_grid(line_size = 0.1) +
        theme(
          panel.grid.major = element_line(size = 0.1),
          axis.ticks = element_blank(),
          panel.background = element_rect(fill = "#222831"),
          plot.background = element_rect(fill = "#222831"),
          legend.title = element_text(
            size = 9,
            face = "bold",
            colour = "#F7F7F7",
            hjust = 0.5,
            family = "Ubuntu"
          ),
          legend.text = element_text(
            size = 8,
            face = "bold",
            colour = "#F7F7F7",
            family = "Ubuntu"
          ),
          axis.title.x = element_text(
            size = 10,
            face = "bold",
            colour = "#F7F7F7",
            family = "Ubuntu"
          ),
          axis.title.y = element_text(
            size = 11,
            face = "bold",
            colour = "#F7F7F7",
            family = "Ubuntu"
          ),
          axis.text.x = element_text(
            size = 8,
            face = "bold",
            colour = "#F7F7F7",
            family = "Ubuntu"
          ),
          axis.text.y = element_text(
            size = 8,
            face = "bold",
            colour = "#F7F7F7",
            family = "Ubuntu"
          ),
          plot.title = element_text(
            size = 12,
            hjust = 0.5,
            face = "bold",
            colour = "#F7F7F7",
            family = "Ubuntu"
          ),
          plot.subtitle = element_text(
            size = 7,
            face = "bold",
            hjust = 0.5,
            colour = "#F7F7F7",
            family = "Ubuntu"
          ),
          plot.caption = element_text(
            hjust = c(1, 0),
            size = 6,
            colour = "#F7F7F7",
            family = "Ubuntu"
          )
        ) +
        labs(
          title = title_lab,
          subtitle = subtitle_lab,
          x = x_lab,
          y = y_lab,
          caption = c(caption_lab1, caption_lab2)
        )
      
      # A temp file to save the output.
      # This file will be removed later by renderImage
      outfile <- tempfile(fileext = '.png')
      
      # Generate the PNG
      png(
        outfile,
        width = width * 1,
        height = height * 1,
        res = 96 * 2
      )
      print(Plot)
      dev.off()
      
      # Return a list containing the filename
      list(
        src = outfile,
        width = width,
        height = height,
        alt = "AgeMin"
      )
      
    })
  }, deleteFile = TRUE)
  
}