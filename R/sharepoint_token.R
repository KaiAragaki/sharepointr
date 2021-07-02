#' Get SharePoint token
#'
#' @description A token is required whenever using the `sharepoint_get` or `sharepoint_put` function
#'
#' @return a sharepoint token
#' @export
#'
#' @examples
#' \dontrun{
#' token <- sharepoint_token()
#' }
sharepoint_token <- function() {
        gr <- AzureGraph::create_graph_login()
        gr$get_user()$token
}
