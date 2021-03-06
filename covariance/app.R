library(shiny)
library(ggplot2)
library(MASS)

# Define UI for application that plots covariances
ui <- fluidPage(
  
  titlePanel("Visualising Covariance Matrices"),
  
  
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      tags$head(tags$script('$(document).on("shiny:connected", function(e) {
                            Shiny.onInputChange("innerWidth", window.innerWidth);
                            });
                            $(window).resize(function(e) {
                            Shiny.onInputChange("innerWidth", window.innerWidth);
                            });
                            ')),
      
      HTML(
        "Use the sliders to adjust the values of a,b, and c, for the covariance matrix. The resultant output
        is a scatter plot of the datapoints generated from a MVN(0, Sigma) distribution, as well as a visualisation of the linear transformation of the Identity matrix."),
      # Text instructions
      img(src="covariance.png",width="100%"),
      

      # Numeric input for a,b,and c
      sliderInput(inputId = "a",
                   label = "Value of a:",
                   min = 1,
                   max = 5,
                   value = 1,
                   step = 1),
      
      sliderInput(inputId = "b",
                   label = "Value of b:",
                   min = 1,
                   max = 5,
                   value = 1,
                   step = 1),
      
      uiOutput("c")
      
      ),
    
    # Output: Show scatterplot
    mainPanel(
      plotOutput(outputId = "scatterplot")
    )
  )
)





# Server
server <- function(input, output){
  
  #Create conditional input bar for c in order for Sigma to be positive definite
  output$c <- renderUI({
    sliderInput("c", "Value of c:", min = -min(input$a, input$b), max = min(input$a, input$b), value = 0)
  })

  
  # Create scatterplot
  output$scatterplot <- renderPlot({
    mu <- c(0,0)
    
    a <- input$a
    b <- input$b
    c <- input$c
    
    Sigma <- matrix(c(a,c,c,b),nrow=2,ncol=2,byrow = TRUE)
    data <-mvrnorm(n = 2000, mu, Sigma, tol = 1e-6, empirical = FALSE, EISPACK = FALSE)
    data1 <- data.frame(x=data[,1], y=data[,2])
    
    
    coord <- function(M){
      c1 <- c(0,0)
      c2 <- M[1,]
      c3 <- M[2,]
      c4 <- c2+c3
      vals <- data.frame(rbind(c1,c2,c4,c3))
      colnames(vals) <- c("x", "y")
      return(vals)
    }
    
    vals <- coord(Sigma)
    points(x=vals$c1[1], y=vals$c1[2], col="red", cex=2, pch=16)
    points(x=vals$c2[1], y=vals$c2[2], col="purple", cex=2, pch=16)
    points(x=vals$c3[1], y=vals$c3[2], col="purple", cex=2, pch=16)
    points(x=vals$c4[1], y=vals$c4[2], col="red", cex=2, pch=16)
    
    p <- ggplot(data1, aes(x=x,y=y))+geom_point() +coord_cartesian(xlim = c(-10, 10), ylim = c(-10, 10))
    p
    data2 <- coord(Sigma)
    data3 <- coord(diag(2))
    
    p1 <- p+geom_polygon(data=data2, aes(x=x, y=y, fill="Linear Transformation"), alpha=0.6)
    p2 <- p1+geom_polygon(data=data3, aes(x=x, y=y, fill="Identity Matrix"), alpha=0.6)
    p2
  },
  height=reactive(ifelse(!is.null(input$innerWidth),input$innerWidth*3/5,0))
  )
}

  # Create a Shiny app object
  shinyApp(ui = ui, server = server)
  