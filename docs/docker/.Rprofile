options(vsc.plot = FALSE)
if (interactive() && Sys.getenv("RSTUDIO") == "") {
    Sys.setenv(TERM_PROGRAM = "vscode")
    if ("httpgd" %in% .packages(all.available = TRUE)) {
        options(vsc.plot = FALSE)
        options(device = function(...) {
            httpgd::hgd(silent = TRUE)
            .vsc.browser(httpgd::hgd_url(history = FALSE), viewer = "Beside")
            })
            }
            }
