# Update one source atomically; a failed or incomplete response keeps its values.
refresh_metric_source <- function(metrics, source, fetch, today = as.character(Sys.Date())) {
  fields <- switch(source,
    scholar = c("h_index", "i10_index", "citations_total"),
    scopus = c("h_index", "citations", "papers"),
    stop("Unknown metrics source: ", source)
  )
  metrics[[source]]$last_attempt <- today
  values <- tryCatch({
    result <- fetch()
    valid <- vapply(fields, function(field) {
      x <- result[[field]]
      is.numeric(x) && length(x) == 1L && is.finite(x) &&
        x >= 0 && x == floor(x)
    }, logical(1))
    if (!all(valid)) stop("Missing or invalid fields: ", paste(fields[!valid], collapse = ", "))
    result[fields]
  }, error = function(e) {
    message(source, " refresh failed; keeping previous values: ", conditionMessage(e))
    NULL
  })
  if (!is.null(values)) {
    metrics[[source]][fields] <- values
    metrics[[source]]$last_success <- today
  }
  metrics
}

metric_success_date <- function(metrics, source) {
  date <- metrics[[source]]$last_success
  if (is.null(date) || length(date) != 1L || is.na(date) || !nzchar(date))
    "not recorded" else as.character(date)
}
