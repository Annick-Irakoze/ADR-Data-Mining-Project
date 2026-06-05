library(shiny)

ui <- fluidPage(
  titlePanel("Data mining project: Filtering Adverse Drug Reaction Data"),
  h3("Original Data"),
  tableOutput("table_input"),
  actionButton("on_click", "Update & Write CSV"),
  h3("Filtered Data"),
  tableOutput("table_output")
)

server <- function(input, output) {
  
  # Read original data
  df <- read.csv("synthetic_drug_data.csv")
  
  # Show original table
  output$table_input <- renderTable({
    head(df, 10)
  })
  
  # Run when button is clicked
  filtered_data <- eventReactive(input$on_click, {
    df <- read.csv("synthetic_drug_data.csv")
    
    # create simulated patient IDs
    set.seed(123)
    n_patients <- 100
    df$PatientID <- paste0("Patient", sprintf("%03d", sample(1:n_patients, nrow(df), replace = TRUE)))
    df <- df[, c("PatientID", names(df)[names(df) != "PatientID"])]
    
    # Remove unnecessary columns
    df$Dosage <- NULL
    df$DurationDays <- NULL
    df$OnsetDays <- NULL
    df$ReportID <- NULL
    # Keep first 50 rows
    df <- df[1:50, ]
    
    # Write to new CSV file
    write.csv(df, "filtered_drug_data.csv", row.names = FALSE)
    
    df
  })
  
  # Show updated table only after click
  output$table_output <- renderTable({
    req(input$on_click > 0)
    filtered_data()
  })
}

shinyApp(ui, server)