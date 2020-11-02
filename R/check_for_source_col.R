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
                tidyr::unnest_wider(.data$value) %>%
                dplyr::filter(name == "source_code",
                              read_only == F)
        if (nrow(res) >= 1){
                T
        } else {
                F
        }
}
