# AUM Warhawks baseball analytics
# Files in R/ are loaded automatically by Shiny. Styles live in www/talon.css.

library(shiny)
library(bslib)
library(shinymanager)
library(rsconnect)

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
            uiOutput(paste0("section_", s$id)))
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

set_labels(
  language = "en",
  "Please authenticate" = "Sign in",
  "Username:" = "Username",
  "Password:" = "Password",
  "Login" = "Sign in"
)

dev_role <- Sys.getenv("TALON_DEV_ROLE")

if (!nzchar(dev_role)) ui <- secure_app(
    ui,
    tags_top    = login_top(),
    tags_bottom = login_bottom(),
    head_auth   = tagList(
      tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
      tags$link(rel = "stylesheet", href = "talon.css"),
      tags$style("body { background: #121212 !important; }")
    ),
    enable_admin = FALSE
  )

section_ui_fns <- list(
  playerhealth = playerhealth_ui
)

server <- function(input, output, session) {
  if (nzchar(dev_role)) {
    user_role <- reactive(dev_role)
  } else {
    res_auth <- secure_server(check_credentials = check_credentials(load_users()))
    user_role <- reactive({
      req(res_auth$role)
      res_auth$role
    })
  }
  
  observeEvent(user_role(), {
    for (id in app_sections$id) {
      if (!can_access(user_role(), id)) nav_hide("main_nav", id)
    }
  })
  
  lapply(seq_len(nrow(app_sections)), function(i) {
    s <- app_sections[i, ]
    output[[paste0("section_", s$id)]] <- renderUI({
      require_access(user_role, s$id)
      ui_fn <- section_ui_fns[[s$id]]
      if (is.null(ui_fn)) section_placeholder(s$title, s$blurb)
      else ui_fn(paste0(s$id, "_mod"))
    })
  })
  
  playerhealth_server("playerhealth_mod", user_role)
  
  data_through <- home_server("home", parent_session = session,
                              user_role = user_role)

  output$data_through <- renderText({
    paste("Data through", format(data_through(), "%b %e, %Y"))
  })
}

shinyApp(ui, server)
