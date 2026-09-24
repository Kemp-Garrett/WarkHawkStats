# Data loaders ---------------------------------------------------------------
# These return sample data for now. Replace the bodies with your real sources
# (CSV exports, a database query, TrackMan files, etc.) and keep the same
# column names so the home page keeps working.

load_next_game <- function() {
  data.frame(
    game_date   = as.Date("2027-02-06"),
    game_time   = "2:00 PM",
    opponent    = "Young Harris",
    opp_short   = "YH",
    home_away   = "vs.",            # "vs." for home, "at" for away
    venue       = "AUM Baseball Stadium",
    probable_sp = "RHP #22",
    stringsAsFactors = FALSE
  )
}

load_team_summary <- function() {
  data.frame(
    wins = 24, losses = 11,
    conf_wins = 12, conf_losses = 6,
    team_ops = 0.812,
    team_era = 4.37,
    staff_k  = 298, staff_bb = 113,
    data_through = as.Date("2027-02-01"),
    stringsAsFactors = FALSE
  )
}

# Formatting helpers ----------------------------------------------------------

# Baseball style rate stats: .812 instead of 0.812
fmt_rate <- function(x, digits = 3) {
  out <- formatC(x, format = "f", digits = digits)
  sub("^0\\.", ".", out)
}

fmt_num <- function(x, digits = 2) formatC(x, format = "f", digits = digits)
