#' Upload file to SharePoint
#'
#' @param file path to file to be uploaded
#' @param file_name desired file name (with extension). Will be checked for uniqueness if overwrite = F
#' @param dest_path path to folder on SharePoint where file is to be uploaded
#' @param token AzureGraph token - see `sharepoint_token`
#' @param overwrite should the file overwrite that of one with a similar (see Details) name if it exists?
#'
#' @importFrom rlang .data
#'
#' @return an http response
#' @export
#'
#' @details
#' SharePoint API does not care about upper versus lower case.
#' As a matter of good practice, names should be distinct beyond just capitalization.
#
#' See the 'working-with-sharepoint-files.Rmd vignette for more details

sharepoint_put <- function(file, dest_path, token, overwrite = F, file_name = NULL) {

        base_url <- "https://graph.microsoft.com/v1.0/sites/"

        # Get file extension
        ext_file_ind <- regexpr("\\..[^\\.]*$", file, perl = T)
        ext_file     <- regmatches(file, ext_file_ind)

        if (!is.null(file_name)) {
                # Get file_name extension
                ext_file_name_ind <- regexpr("\\..[^\\.]*$", file_name, perl = T)
                ext_file_name     <- regmatches(file_name, ext_file_name_ind)


                # If extensions do not match, warn
                if (ext_file != ext_file_name) {
                        warning("\nExtensions do not match. \n file:      ", ext_file, "\n file_name: ", ext_file_name)
                }
        }

        else {
                file_name_ind <- regexpr("[^/]*\\..[^\\.]*$", file, perl = T)
                file_name     <- regmatches(file, file_name_ind)
                ext_file_name <- ext_file
        }

        # Parse destination filepath
        parsed <- parse_path(dest_path)


        # Get SharePoint ID
        url    <- paste0(base_url, parsed$host, ":/sites/", parsed$site)
        sp     <- AzureGraph::call_graph_url(token, url, http_verb = "GET")
        sp_id  <- sp$id


        # Get destination folder ID
        url       <- paste0(base_url, sp_id, "/drive/root:/", parsed$rest)
        folder    <- AzureGraph::call_graph_url(token, url, http_verb = "GET")
        folder_id <- folder$id


        # Check if file of similar name exists
        if (!overwrite) {
                url <- paste0(base_url, sp_id, "/drive/items/", folder_id,"/children")
                response <-
                        AzureGraph::call_graph_url(token,
                                                   url,
                                                   http_verb = "GET") %>%
                        dplyr::as_tibble() %>%
                        tidyr::unnest_wider(col = .data$value)
                if("name" %in% colnames(response)) {
                        response <- response %>%
                                dplyr::mutate(name  = tolower(.data$name)) %>%
                                dplyr::filter(.data$name == tolower(file_name))
                        if (nrow(response) > 0) stop("\nFile already exists in destination. \nChange filename (case-INsensitive) or set overwrite to TRUE")
                }
        }

        # Upload file
        if(file.size(file) <= 3900000) {
                url <- paste0(base_url, sp_id, "/drive/items/", folder_id,":/", file_name, ":/content")
                res <- AzureGraph::call_graph_url(token,
                                                  url,
                                                  body      = httr::upload_file(file),
                                                  encode    = mime::guess_type(ext_file_name),
                                                  http_verb = "PUT")
        } else if (file.size(file) < 62500000) {
                url <- paste0(base_url, sp_id, "/drive/items/", folder_id, ":/", file_name, ":/createUploadSession")
                res <- AzureGraph::call_graph_url(token,
                                                  url = url,
                                                  http_verb = "POST")
                res <- AzureGraph::call_graph_url(token,
                                                  url = res$uploadUrl,
                                                  config = httr::add_headers(.headers = c(`Content-Range` = paste0("bytes 0-",file.size(file)-1,"/",file.size(file)))),
                                                  body      = httr::upload_file(file),
                                                  encode    = mime::guess_type(ext_file_name),
                                                  http_verb = "PUT")
        } else {
                stop("sharepoint_put (currently) only supports up to 60MB files")
        }


        # Upload the filename which it was called from into source_code column
        # If no such column exists, do nothing

        url  <- paste0("https://graph.microsoft.com/v1.0/drives/", res$parentReference$driveId, "/list/columns")
        if (check_for_source_col(url, token)) {
                script <- get_current_script()
                if (identical(script, character(0))) {
                        message("Couldn't find the script name.\nIs the file 'untitled'?")
                } else {
                        url  <- paste0("https://graph.microsoft.com/v1.0/drives/", res$parentReference$driveId, "/items/", res$id, "/listitem/fields")
                        body <- jsonlite::toJSON(list(source_code = script), pretty = T, auto_unbox = T)
                        res <- AzureGraph::call_graph_url(token = token,
                                                          url = url,
                                                          body = body,
                                                          encode = "raw",
                                                          http_verb = "PATCH")
                }
        }
}
