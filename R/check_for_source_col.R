#' Get field names for a given library
#'
#' @param url
#'
#' @return
#' @keywords internal
#' @noRd
#'
check_for_source_col <- function (url, token){
        res <- AzureGraph::call_graph_url(token = token,
                                          url = url,
                                          http_verb = "GET") %>%
                dplyr::as_tibble() %>%
                tidyr::unnest_wider(.data$value)
        if ("source_code" %in% colnames(res)) {
                if ("read_only" %in% colnames(res)){
                        res <- dplyr::filter(name == "source_code",
                                             read_only == F)
                        if (nrow(res) >= 1) {
                                res <- T
                        } else {
                                res <- F
                        }
                } else {
                        res <- T
                }
        } else {
                res <- F
        }
        res
}
