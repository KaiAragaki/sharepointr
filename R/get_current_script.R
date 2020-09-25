#' Get path of script where function is called
#'
#' @return
#' @keywords internal
#' @noRd
#'
get_current_script <- function() {

        this_file <- rstudioapi::getSourceEditorContext()$path
        here <- here::here()

        # Matches .../you/are/here
        # with    and/you/are/here/but/this/is/your/script.R
        # to give            /here/but/this/is/your/script.R
        here_last_ind  <- regexpr("(?<=/).[^/]*$", here, perl = T)
        here_last      <- regmatches(here, here_last_ind)
        this_first_ind <- regexpr(paste0(here_last, ".*$"), this_file)
        this_file      <- regmatches(this_file, this_first_ind)
}
