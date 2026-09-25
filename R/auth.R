# Logins and roles -----------------------------------------------------------
# Each account's password lives in a secret variable, never in this file.
# Locally, put them in a .Renviron file in the app folder (see README).
# On your host, add them as secret or environment variables.

talon_accounts <- data.frame(
  user     = c("coach",  "player"),
  role     = c("coach",  "player"),
  password_var = c("TALON_COACH_PW", "TALON_PLAYER_PW"),
  admin    = c(FALSE, FALSE),
  stringsAsFactors = FALSE
)

# Builds the credentials table shinymanager expects.
# Accounts whose secret variable isn't set are skipped, so a missing
# password can never become an empty password.
load_users <- function() {
  pw <- vapply(talon_accounts$password_var, Sys.getenv, character(1), unset = "")
  users <- talon_accounts[nzchar(pw), c("user", "role", "admin")]
  users$password <- pw[nzchar(pw)]
  if (nrow(users) == 0) {
    stop("No TALON passwords are set. Add them to .Renviron or your host's secret variables.")
  }
  users
}

# TRUE if this role may open this section
can_access <- function(role, section_id) {
  if (is.null(role) || !nzchar(role)) return(FALSE)
  allowed <- app_sections$roles[app_sections$id == section_id]
  if (length(allowed) == 0) return(FALSE)
  role %in% trimws(strsplit(allowed, ",")[[1]])
}

# Use at the top of every section's server code, before loading any data:
#   require_access(user_role, "recon")
require_access <- function(user_role, section_id) {
  req(can_access(user_role(), section_id))
}

# Branded login screen --------------------------------------------------------

login_top <- function() tags$div(
  class = "talon-login-brand",
  tags$img(src = "WH_Logo.png", class = "talon-logo", alt = "AUM Warhawks"),
  tags$div(
    tags$div(class = "talon-name", app_name),
    tags$div(class = "talon-subtitle", app_subtitle)
  )
)

login_bottom <- function() tags$p(
  class = "talon-login-note",
  "For AUM baseball staff and players. Ask a coach if you need an account."
)