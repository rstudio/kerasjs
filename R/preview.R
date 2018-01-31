file_replace <- function(path, pattern, replacement) {
  lines  <- readLines(path)
  changed  <- gsub(pattern = pattern, replacement = replacement, x = lines)
  writeLines(changed, con = path)
}

tensor_build_example <- function(tensor) {
  layer_dims <- tensor$shape$as_list()
  sequence_dim <- Filter(is.integer, layer_dims)
  rep(0, sequence_dim)
}

#' @importFrom keras load_model_hdf5
kerasjs_input_examples <- function(hdf5_model) {
  model <- load_model_hdf5(hdf5_model, compile = FALSE)
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
  source_file <- system.file("scafold/source.html", package = "tfconvert")
  readLines(source_file)
}

#' @importFrom servr httd
#' @importFrom jsonlite toJSON
#' @export
kerasjs_preview <- function(hdf5_model, kerasjs_model) {
  path <- tempfile()
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

  httd(path)
}
