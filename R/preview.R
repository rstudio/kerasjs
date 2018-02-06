file_replace <- function(path, pattern, replacement) {
  lines  <- readLines(path)
  changed  <- gsub(pattern = pattern, replacement = replacement, x = lines)
  writeLines(changed, con = path)
}

tensor_build_example <- function(tensor) {
  layer_dims <- tensor$shape$as_list()
  sequence_dim <- Filter(is.integer, layer_dims)
  sequence_elems <- prod(as.numeric(sequence_dim))
  rep(0, sequence_elems)
}

#' @importFrom keras load_model_hdf5
kerasjs_input_examples <- function(model_path) {
  model <- load_model_hdf5(model_path, compile = FALSE)
  if ("keras.models.Sequential" %in% class(model)) {
    list(
      input = tensor_build_example(model$input)
    )
  }
  else {
    example <- lapply(
      model$input_layers,
      function(layer) tensor_build_example(layer$input)
    )

    names(example) <- lapply(
      model$input_layers,
      function(layer) layer$name
    )

    example
  }
}

kerasjs_preview_source <- function(path) {
  source_file <- system.file("scafold/source.html", package = "kerasjs")
  readLines(source_file)
}

#' Previews a KerasJS Model
#'
#' Previews a KerasJS model by launching it's runtime in the browser.
#'
#' @param model_path The path to the exported HDF5 model, as a string.
#'
#' @param kerasjs_model The path to the exported KerasJS model, as a string.
#'
#' @importFrom servr httd
#' @importFrom jsonlite toJSON
#' @export
kerasjs_preview <- function(model_path, kerasjs_model) {
  path <- tempfile()
  dir.create(path)

  file.copy(
    file.path(system.file("scafold", package = "kerasjs"), "."),
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
  file_replace(index_path,
               "\\%KERAJS_EXAMPLE\\%",
               toJSON(kerasjs_input_examples(model_path)))

  httd(path)
}
