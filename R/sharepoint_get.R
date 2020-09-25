#' Download file from SharePoint
#'
#' @param path a character vector. Obtained by going online to SharePoint, right clicking on file, clicking 'details', clicking 'more details' in the resultant side pane, then clicking the 'copy' button right next to the "Path" header.
#' @param token a token from `sharepoint_token`
#'
#' @return a tempfile path pointing to the location of the file downloaded
#' @export

sharepoint_get <- function(path, token) {

        tmp    <- tempfile()
        parsed <- parse_path(path)
        url    <- paste0("https://graph.microsoft.com/v1.0/sites/", parsed$host, ":/sites/", parsed$site)
        sp_dat <- AzureGraph::call_graph_url(token, url, http_verb = "GET")
        sp_id  <- sp_dat$id
        url <- paste0("https://graph.microsoft.com/v1.0/sites/", sp_id, "/drive/root:/", parsed$rest, ":/content")
        file <- AzureGraph::call_graph_url(token, url,
                                           httr::write_disk(tmp, overwrite = T),
                                           http_verb = "GET")
        tmp
}
