# AUM Warhawks baseball analytics
# Files in R/ are loaded automatically by Shiny. Styles live in www/talon.css.

library(shiny)
library(bslib)

# Placeholder page for sections that haven't been built yet
section_placeholder <- function(title, blurb) {
  div(
    class = "talon-placeholder",
    h1(title),
    p(blurb),
    p(class = "talon-muted", "This section is next on the build list.")
  )
}

section_panels <- lapply(seq_len(nrow(app_sections)), function(i) {
  s <- app_sections[i, ]
  nav_panel(title = s$title, value = s$id, icon = icon(s$icon),
            section_placeholder(s$title, s$blurb))
})

ui <- do.call(page_navbar, c(
  list(
    id     = "main_nav",
    title  = tags$span(
      class = "talon-brand",
      tags$img(src = "WH_Logo.png", class = "talon-logo", alt = "AUM Warhawks"),
      tags$span(
        class = "talon-brand-text",
        tags$span(class = "talon-name", app_name),
        tags$span(class = "talon-subtitle", app_subtitle)
      )
    ),
    window_title = paste(app_name, "|", app_subtitle),
    theme  = talon_theme,
    fillable = FALSE,
    header = tags$head(
      tags$meta(name = "viewport",
                content = "width=device-width, initial-scale=1"),
      tags$link(rel = "stylesheet", href = "talon.css")
    ),
    footer = div(
      class = "talon-footer",
      textOutput("data_through", inline = TRUE),
      span(class = "talon-footer-tag", app_footer)
    ),
    nav_panel(title = "Home", value = "home", icon = icon("house"),
              home_ui("home"))
  ),
  section_panels
))

server <- function(input, output, session) {
  data_through <- home_server("home", parent_session = session)

  output$data_through <- renderText({
    paste("Data through", format(data_through(), "%b %e, %Y"))
  })
}

shinyApp(ui, server)
