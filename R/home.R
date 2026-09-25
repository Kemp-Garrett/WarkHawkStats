# App sections ---------------------------------------------------------------
# One row per tab. The home page tiles and the navbar are both built from this,
# so adding a section here adds it in both places.

app_sections <- data.frame(
  id    = c("hangar", 
            "recon", 
            "radar", 
            "flightlog", 
            "briefing", 
            "qvlowe",
            "playerhealth"),
  title = c("Player Profiles", 
            "Scouting", 
            "Pitch Radar", 
            "Game Log", 
            "Game Reports", 
            "Field",
            "Player Health"),
  blurb = c("Roster and player profiles", 
            "Opponent scouting",
            "Pitch data", 
            "Game logs and trends",
            "Pre-game report", 
            "Spray charts and home splits",
            "Arm care and fatigue reports"),
  icon  = c("users", 
            "binoculars", 
            "crosshairs", 
            "book-open",
            "clipboard-list", 
            "baseball",
            "notes-medical"),
  roles = c("coach,player", 
            "coach", 
            "coach,player", 
            "coach,player",
            "coach", 
            "coach,player",
            "coach"),
  stringsAsFactors = FALSE
)

# Home page UI ---------------------------------------------------------------

home_ui <- function(id) {
  ns <- NS(id)

  div(
    class = "talon-home",
    uiOutput(ns("briefing")),

    h2(class = "talon-section-title", "Season at a glance"),
    uiOutput(ns("stats")),

    h2(class = "talon-section-title", "Sections"),
    uiOutput(ns("tiles"))
  )
}

# Home page server -----------------------------------------------------------
# parent_session is the app's top-level session, needed to switch navbar tabs
# from inside this module.

home_server <- function(id, parent_session, user_role, nav_id = "main_nav") {
  moduleServer(id, function(input, output, session) {

    go_to <- function(tab_id) {
      if (!can_access(user_role(), tab_id)) return()
      bslib::nav_select(nav_id, selected = tab_id, session = parent_session)
    }

    # Wire up every tile to its tab
    lapply(app_sections$id, function(tab_id) {
      observeEvent(input[[paste0("go_", tab_id)]], go_to(tab_id))
    })
    observeEvent(input$open_report, go_to("briefing"))
    observeEvent(input$open_recon,  go_to("recon"))

    next_game <- reactive(load_next_game())
    summary   <- reactive(load_team_summary())
    
    # Section tiles, filtered to what this user can open
    output$tiles <- renderUI({
      role <- user_role()
      visible <- app_sections[vapply(app_sections$id, can_access, logical(1),
                                     role = role), ]
      tiles <- lapply(seq_len(nrow(visible)), function(i) {
        s <- visible[i, ]
        actionLink(
          session$ns(paste0("go_", s$id)),
          class = "talon-tile",
          label = tagList(
            span(class = "talon-tile-icon", icon(s$icon)),
            span(class = "talon-tile-text",
                 span(class = "talon-tile-title", s$title),
                 span(class = "talon-tile-blurb", s$blurb))
          )
        )
      })
      div(class = "talon-grid talon-tiles", tiles)
    })

    output$briefing <- renderUI({
      g <- next_game()
      role <- user_role()
      day <- format(g$game_date, "%a, %b %e")
      div(
        class = "talon-briefing",
        p(class = "talon-briefing-label", "Next game"),
        h1(class = "talon-briefing-title", paste(g$home_away, g$opponent)),
        p(class = "talon-briefing-meta",
          paste0(day, ", ", g$game_time, " at ", g$venue)),
        p(class = "talon-briefing-meta",
          paste("Probable starter:", g$probable_sp)),
        div(
          class = "talon-briefing-actions",
          if (can_access(role, "briefing"))
          actionButton(session$ns("open_report"), "Open pre-game report",
                       class = "btn-talon-primary"),
          if (can_access(role, "recon"))
          actionButton(session$ns("open_recon"), paste("Scout", g$opp_short),
                       class = "btn-talon-ghost")
        )
      )
    })

    output$stats <- renderUI({
      s <- summary()
      stat <- function(label, value, extra = NULL) {
        div(class = "talon-stat",
            span(class = "talon-stat-label", label),
            span(class = "talon-stat-value", value,
                 if (!is.null(extra)) span(class = "talon-stat-extra", extra)))
      }
      div(
        class = "talon-grid",
        stat("Overall record", paste0(s$wins, "-", s$losses),
             paste0(s$conf_wins, "-", s$conf_losses, " GSC")),
        stat("Team OPS", fmt_rate(s$team_ops)),
        stat("Team ERA", fmt_num(s$team_era)),
        stat("Staff K/BB", fmt_num(s$staff_k / s$staff_bb))
      )
    })

    # Expose the data date so the footer can use it
    reactive(summary()$data_through)
  })
}
