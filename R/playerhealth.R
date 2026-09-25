playerhealth_ui <- function(id) {
  ns <- NS(id)
  div(
    class = "talon-placeholder",
    h1("Player Health"),
    selectInput(ns("position"), "Position", choices = c("C", "1B", "2B", "SS", "3B", "OF")),
    plotOutput(ns("fielding"))
  )
}

playerhealth_server <- function(id, user_role) {
  moduleServer(id, function(input, output, session) {
    output$fielding <- renderPlot({
      require_access(user_role, "playerhealth")
      # your plot code here, using input$position
    })
  })
}