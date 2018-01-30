file_replace <- function(path, pattern, replacement) {
  lines  <- readLines(path)
  changed  <- gsub(pattern = pattern, replacement = replacement, x = lines)
  writeLines(changed, con = path)
}

kerasjs_scafold <- function(model, path = "scafold") {
  unlink(path, recursive = TRUE)
  dir.create(path)

  file.copy(
    file.path(system.file("scafold", package = "tfconvert"), "."),
    path,
    recursive = TRUE
  )

  index_path <- file.path(path, "index.html")

  models_path <- file.path(path, "models")
  models_file <- file.path(models_path, basename(model))
  dir.create(models_path)
  file.copy(
    model,
    models_file
  )

  file_replace(index_path, "\\%KERAJS_MODEL\\%", models_file)
}
