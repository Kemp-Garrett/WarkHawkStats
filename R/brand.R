# Brand settings -------------------------------------------------------------
# Change the name here and it updates everywhere in the app.

app_name     <- "WarhawkStats"
app_subtitle <- "AUM Baseball Analytics"
app_footer   <- "#WeAreAUM"

talon_colors <- list(
  orange   = "#F26522",  # Warhawk Orange: accents, buttons
  black    = "#121212",  # Flight Black: navbar, headers
  charcoal = "#2B2D31",  # Hangar Charcoal: briefing card
  aluminum = "#8A9099",  # Aluminum: secondary text
  bone     = "#F5F1E8"   # Bone: page background
)

talon_theme <- bslib::bs_theme(
  version      = 5,
  bg           = talon_colors$bone,
  fg           = talon_colors$black,
  primary      = talon_colors$orange,
  secondary    = talon_colors$charcoal,
  base_font    = bslib::font_collection(
    bslib::font_google("Inter", local = FALSE),
    "system-ui", "-apple-system", "Segoe UI", "Arial", "sans-serif"),
  heading_font = bslib::font_collection(
    bslib::font_google("Oswald", local = FALSE),
    "Arial Narrow", "Arial", "sans-serif"),
  code_font    = bslib::font_collection(
    bslib::font_google("Roboto Mono", local = FALSE),
    "Consolas", "Menlo", "monospace"),
  "border-radius" = "0.5rem"
)
