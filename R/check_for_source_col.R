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
        if ("source_code" %in% res$name) {
                if ("readOnly" %in% colnames(res)){
                        res <- dplyr::filter(res, .data$name == "source_code",
                                             .data$readOnly == F)
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
