#' Parse a SharePoint Path
#' @description An internal function used to parse SharePoint paths into its constitutive parts
#'
#' @param path SharePoint path copied and pasted from the icon next to the 'path' header from the file details menu in SharePoint
#'
#' @return a named list, including `host`, `site`, and `drive`
#' @keywords internal
#' @noRd
#' @examples
#' path <- "https://mycompany.sharepoint.com/sites/mysite/mydrive/path/to/my/file.xls"
#' parse_path(path)
parse_path <- function(path) {

        host_ind  <- regexpr("(?<=^https://)[^/]*", path, perl = T)
        host      <- regmatches(path, host_ind)

        site_ind  <- regexpr("(?<=/sites/)[^/]*", path, perl = T)
        site      <- regmatches(path, site_ind)

        drive_ind <- regexpr(paste0("(?<=", site, "/)", "[^/]*"), path, perl = T)
        drive     <- regmatches(path, drive_ind)

        rest_ind  <- regexpr(paste0("(?<=", drive, "/)", ".*$"), path, perl = T)
        rest      <- regmatches(path, rest_ind)

        list(host = host, site = site, drive = drive, rest = rest)

}

