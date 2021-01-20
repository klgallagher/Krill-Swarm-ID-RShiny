library(lubridate)
library(ggplot2)
library(zoo)
require(class)
require(fields)
library(shiny)

#colscatter <- function(data, no.colors, minval, maxval){
#  o <- seq(maxval, minval, length = no.colors+1)
#  o1 <- (o + (o[2]-o[1])/2)[1:(length(o)-1)]
#  c <- rev(tim.colors(no.colors))
##  na_ind <- is.na(data)
#  test <- as.matrix(data)
#  test_no_na <- test[na_ind==FALSE,]
#  train <- as.matrix(o1)
#  cl <- as.matrix(1:no.colors)
#  colind <- knn(as.matrix(train), as.matrix(test_no_na), cl)
#  v = NULL
#  v$ind <- c[colind]
#  test[na_ind==FALSE] <- v$ind
#  v$ind <- test
#  v$ind <- replace(v$ind, v$ind=="NaN", NA)
#  v$bar <- c
#  return(v)
#}###

# Define UI ----
ui <- fluidPage(
  titlePanel("Project SWARM: Krill Ball Annotation"),
  
  sidebarLayout(
    sidebarPanel(
        selectInput('glider', label = 'Select Glider:', choices = list("UD", "UAF"), selected = 'UD'),
        
        numericInput("depth", label = "Select Max Depth\nUD max: -300\nUAF max: -1100", value = "-100", min = '0', max = '-1100'),
        
        numericInput("imaginex_threshold", label = "Select db Threshold", value = "-100", min = '-30', max = '-90'),
       
        #date range of the entire dataset
        #sliderInput("datetime", "Start Date & Time:", min=as.POSIXlt("2020-01-09 00:00:00", "GMT"), max=as.POSIXlt("2020-03-11 23:59:59", "GMT"), value=as.POSIXlt("2010-01-01 00:00:00", "GMT"), timezone = "GMT", step = 60*60),
        
        #date range covered by the subset
        sliderInput("datetime", "Start Date & Time:", min=as.POSIXlt("2020-01-20 05:00:00", "GMT"), max=as.POSIXlt("2020-01-21 01:00:00", "GMT"), value=as.POSIXlt("2010-01-20 05:00:00", "GMT"), timezone = "GMT", step = 60*60),
        
        sliderInput("lag", label = "Hours Since Start to Plot:", min = 0, max = 10, value = 2),
        
        sliderInput('bin_threshold', label = "Imaginex Bin Threshold:", min = 0, max = 200, value = 8, step = 1),
        
        actionButton("go", "Plot"),
        
        downloadButton("downloadData", "Save Selected Data to CSV")
        
        #actionButton('clear', "Clear")
    ), #end sidebarPanel,
    
    mainPanel(plotOutput('plot1', brush = "plot_brush"), verbatimTextOutput("info"))
  ) #end sidebarLayout
)#end fluidpage

# Define server logic ----
server <- function(input, output) {
  
  g <- eventReactive(input$go, {
    date <- as.Date(input$datetime) 
          
          id <- showNotification("Subsetting Glider Data...", duration = NULL, closeButton = F)
          #due to the size of the data, in order to work with it locally, 
          #the data needed to be subsetted by date. 
          #If you have better computing power, 
          #these if statements will not be necessary and 
          #the data can just be loaded in and saved as glider_data
          if(input$glider == 'UD'){
            #glider_data <- subset(all_data, all_data$glider == 'UD')
            #if(date >= '2020-01-09' & date < '2020-01-30'){
              #load('/path/to/UD1.RData')
              load('/INSERT/PATH/TO/UDswarms_example.RData')
              glider_data <- UD_example
            #}
            #if(date >= '2020-01-30' & date < '2020-02-20'){
            #  load('/path/to/UD2.RData')
            #  glider_data <- UD2
            #}
            #if(date >= '2020-02-20' & date < '2020-03-12'){
            #  load('/path/to/UD3.RData')
            #  glider_data <- UD3
            #}
            #further subset data by start time inputs and number of hours to include in plot
            ind <- which(glider_data$timeGL >= input$datetime & glider_data$timeGL <= (input$datetime) + (input$lag * 60 * 60))
             glider_data <- glider_data[ind,]
             
             #remove top X bins as determined by threshold slider
             bin.ind <- which(glider_data$Bin <= input$bin_threshold)
             glider_data <- glider_data[-bin.ind, ]
             
             #Remove data below a dB threshold
             thres.ind <- which(glider_data$value >= input$imaginex_threshold)
             glider_data <- glider_data[thres.ind,]
             
             }
          
          #the same code is repeated but for the other glider platform
          if(input$glider == 'UAF'){
           # if(date >= '2020-01-09' & date < '2020-01-30'){
              #load('/path/to/UAF1.RData')
              load('/INSERT/PATH/TO/UAFswarms_example.RData')
              glider_data <- UAF_example
           # }
           #if(date >= '2020-01-30' & date < '2020-02-20'){
           #   load('/path/to/UAF2.RData')
           #   glider_data <- UAF2
           # }
           # if(date >= '2020-02-20' & date < '2020-03-12'){
           #   load('/path/to/UAF3.RData')
           #   glider_data <- UAF3
           # }
            
            ind <- which(glider_data$timeGL >= input$datetime & glider_data$timeGL <= (input$datetime) + (input$lag * 60 * 60))
            glider_data <- glider_data[ind,]
            
            bin.ind <- which(glider_data$Bin <= input$bin_threshold)
            glider_data <- glider_data[-bin.ind, ]
            
            thres.ind <- which(glider_data$value >= input$imaginex_threshold)
            glider_data <- glider_data[thres.ind,]
            
          }

          on.exit(removeNotification(id), add = TRUE)
          return(glider_data)
  }) #end g
  
  r <- reactiveValues(col.range = NULL, col.bar = NULL)
  #the dB ranges are slightly different between the two platforms, 
  #so the below changes the color bar, and pulls the appropriate color bar object
  #depending on the platform selected
  observeEvent(input$go, {
      if(input$glider == 'UD'){
          r$col.range <- c(-97, -37) 
      } else {
          r$col.range <- c(-106, -47)
      }
  })
  
  observeEvent(input$go, {
      if(input$glider == 'UD'){
          load('/INSERT/PATH/TO/colorbar_for_Shiny_UD.RData')
          r$col.bar <- col.bar
      } else {
          load('/INSERT/PATH/TO/colorbar_for_Shiny_UAF.RData')
          r$col.bar <- col.bar
      }
  })
    
  #generate plot and colorbar from subsetted data
  output$plot1 <- renderPlot({
    par(mar=c(5, 4, 4, 6))
    plot(ping_depth ~ timeGL, data = g(), t = 'p', xlab = "Time", ylab = "Depth (m)", ylim = c(input$depth, 0), col= g()$ping.col, pch = 20, main = paste(input$glider, input$datetime, '-', (input$datetime) + (input$lag * 60 * 60), sep = ' '))
    image.plot(legend.only = T, zlim = range(r$col.range), col = rev(r$col.bar), legend.line = 3, horizontal = F)
  }) #end plot1
  
  #brushedPoints allows swarms to be highlighted in the plots
  output$info <- renderPrint({
    # With base graphics, need to tell it what the x and y variables are.
    swarm <- brushedPoints(g(), input$plot_brush, xvar = "timeGL", yvar = "ping_depth")
    swarm
  })
  
  #define filenames for download of selected data
  #NOTE: data by default went to the downloads folder on a mac
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$glider, "_annotatedswarms_", as.numeric(Sys.time()), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(brushedPoints(g(), input$plot_brush, xvar = "timeGL", yvar = "ping_depth"), file, row.names = FALSE)
    }
  )
  
} #end server

# Run the app ----
shinyApp(ui = ui, server = server)

