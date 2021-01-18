library(lubridate)
library(ggplot2)
library(zoo)
require(class)
require(fields)

load('~/Documents/UD/SWARM/Gliders/ForShiny/imaginex_plot_colorbar.RData')

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
        
        numericInput("imaginex_threshold", label = "Select db Threshold", value = "-70", min = '-30', max = '-90'),
        
        sliderInput("datetime", "Start Date & Time:", min=as.POSIXlt("2020-01-09 00:00:00", "GMT"), max=as.POSIXlt("2020-03-09 23:59:59", "GMT"), value=as.POSIXlt("2010-01-01 00:00:00", "GMT"), timezone = "GMT", step = 60*60),
        
        sliderInput("lag", label = "Hours Since Start to Plot:", min = 0, max = 10, value = 2),
        
        sliderInput('bin_threshold', label = "Imaginex Bin Threshold:", min = 0, max = 200, value = 8, step = 1),
        
        actionButton("go", "Plot"),
        
        downloadButton("downloadData", "Save Selected Data to CSV")
        
        #actionButton('clear', "Clear")
    ), #end sidebarPanel,
    
    mainPanel(plotOutput('plot1', brush = "plot_brush"), verbatimTextOutput("info"))
  ), #end sidebarLayout
)#end fluidpage

# Define server logic ----
server <- function(input, output) {
  
  g <- eventReactive(input$go, {
    date <- as.Date(input$datetime) 
          
          id <- showNotification("Subsetting Glider Data...", duration = NULL, closeButton = F)
          if(input$glider == 'UD'){
            #glider_data <- subset(all_data, all_data$glider == 'UD')
            if(date >= '2020-01-09' & date < '2020-01-30'){
              load('~/Documents/UD/SWARM/Gliders/ForShiny/UDswarms1.RData')
              glider_data <- UD1
            }
            if(date >= '2020-01-30' & date < '2020-02-20'){
              load('~/Documents/UD/SWARM/Gliders/ForShiny/UDswarms2.RData')
              glider_data <- UD2
            }
            if(date >= '2020-02-20' & date < '2020-03-12'){
              load('~/Documents/UD/SWARM/Gliders/ForShiny/UDswarms3.RData')
              glider_data <- UD3
            }
            ind <- which(glider_data$timeGL >= input$datetime & glider_data$timeGL <= (input$datetime) + (input$lag * 60 * 60))
             glider_data <- glider_data[ind,]
             
             bin.ind <- which(glider_data$Bin <= input$bin_threshold)
             glider_data <- glider_data[-bin.ind, ]
             
             thres.ind <- which(glider_data$value >= input$imaginex_threshold)
             glider_data <- glider_data[thres.ind,]
             
             load('~/Documents/UD/SWARM/Gliders/NewData_forShiny/colorbar_for_Shiny_UD.RData')
             col.range <- c(-97, -37)
             
             }
          
          if(input$glider == 'UAF'){
            #glider_data <- subset(all_data, all_data$glider == 'UAF')
            if(date >= '2020-01-09' & date < '2020-01-30'){
              load('~/Documents/UD/SWARM/Gliders/ForShiny/UAFswarms1.RData')
              glider_data <- UAF1
            }
            if(date >= '2020-01-30' & date < '2020-02-20'){
              load('~/Documents/UD/SWARM/Gliders/ForShiny/UAFswarms2.RData')
              glider_data <- UAF2
            }
            if(date >= '2020-02-20' & date < '2020-03-12'){
              load('~/Documents/UD/SWARM/Gliders/ForShiny/UAFswarms3.RData')
              glider_data <- UAF3
            }
            
            ind <- which(glider_data$timeGL >= input$datetime & glider_data$timeGL <= (input$datetime) + (input$lag * 60 * 60))
            glider_data <- glider_data[ind,]
            
            bin.ind <- which(glider_data$Bin <= input$bin_threshold)
            glider_data <- glider_data[-bin.ind, ]
            
            thres.ind <- which(glider_data$value >= input$imaginex_threshold)
            glider_data <- glider_data[thres.ind,]
            
            load('~/Documents/UD/SWARM/Gliders/NewData_forShiny/colorbar_for_Shiny_UAF.RData')
            col.range <- c(-106, -47)
            
          }
    
          #return(glider_data)
          on.exit(removeNotification(id), add = TRUE)
          return(list(glider_data, col.bar, col.range)
  })
    
  output$plot1 <- renderPlot({
   #plot(m_gps_lon.lon ~ m_gps_lat.lat, data = g())
    #plot(sci_water_pressure.bar*-10 ~ as.numeric(m_present_time.timestamp), data = g(), t = 'b', pch = 20, xlab = "Time", ylab = "Depth (m)", cex = 2, ylim = c(-300, 0))
    par(mar=c(5, 4, 4, 6))
    #plot(sci_water_pressure.bar*-10 ~ timeGL, data = g(), t = 'p', xlab = "Time", ylab = "Depth (m)", ylim = c(input$depth, 0), col = 'gray95')
    #C.ping = colscatter(g()$value, 64, -90, -34)
    plot(ping_depth ~ timeGL, data = g()$glider_data, t = 'p', xlab = "Time", ylab = "Depth (m)", ylim = c(input$depth, 0), col= g()$glider_data$ping.col, pch = 20, main = paste(input$glider, input$datetime, '-', (input$datetime) + (input$lag * 60 * 60), sep = ' '))
  
  image.plot(legend.only = T, zlim = range(g()$col.range), col = rev(g()$col.bar), legend.line = 3, horizontal = F)
    
  }) #end plot1
  
  output$info <- renderPrint({
    # With base graphics, need to tell it what the x and y variables are.
    swarm <- brushedPoints(g()$glider_data, input$plot_brush, xvar = "timeGL", yvar = "ping_depth")
    swarm
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("~/Documents/UD/SWARM/Gliders/", input$glider, "_annotatedswarms_", as.numeric(Sys.time()), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(brushedPoints(g()$glider_data, input$plot_brush, xvar = "timeGL", yvar = "ping_depth"), file, row.names = FALSE)
    }
  )
  
  #eventReactive(input$clear, {
  #   rm(list=ls())
  #})
  
} #end server

# Run the app ----
shinyApp(ui = ui, server = server)
