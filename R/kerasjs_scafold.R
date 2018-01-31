file_replace <- function(path, pattern, replacement) {
  lines  <- readLines(path)
  changed  <- gsub(pattern = pattern, replacement = replacement, x = lines)
  writeLines(changed, con = path)
}

kerasjs_input_examples <- function(hdf5_model) {
  list(
    input = rep(0, 784)
  )
}

#' @importFrom servr httd
#' @importFrom jsonlite toJSON
#' @export
kerasjs_scafold <- function(hdf5_model, kerasjs_model, path = "scafold", browse = interactive()) {
  unlink(path, recursive = TRUE)
  dir.create(path)

  file.copy(
    file.path(system.file("scafold", package = "tfconvert"), "."),
    path,
    recursive = TRUE
  )

  index_path <- file.path(path, "index.html")

  models_abs_path <- file.path(path, "models")
  models_abs_file <- file.path(models_abs_path, basename(kerasjs_model))
  dir.create(models_abs_path)
  file.copy(
    kerasjs_model,
    models_abs_file
  )

  models_rel_file <- file.path("models", basename(kerasjs_model))
  file_replace(index_path, "\\%KERAJS_MODEL\\%", models_rel_file)
  file_replace(index_path, "\\%KERAJS_EXAMPLE\\%", toJSON(kerasjs_input_examples(hdf5_model)))

  if (browse) {
    message("Launching scafold with: servr::httd(\"", path, "\")")
    httd(path)
  }
}
