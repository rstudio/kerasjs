#' Converts HDF5 Model to KerasJS
#'
#' Converts HDF5 model into KerasJS format.
#'
#' @param model_path The path to the exported HDF5 model, as a string.
#'
#' @param target_path The path where the converted model will be saved,
#'   defaults to the current working directory.
#'
#' @param browse Launch browser with model's runtime?
#'
#' @importFrom tools file_path_sans_ext
#' @export
kerasjs_convert <- function(
  model_path,
  target_path = getwd(),
  browse = TRUE
) {
  model_path <- normalizePath(model_path, mustWork = TRUE)
  target_path <- file.path(
    normalizePath(target_path, mustWork = TRUE),
    file_path_sans_ext(basename(model_path))
  )
  target_file <- paste(target_path, "bin", sep = ".")

  py_os <- reticulate::import("os")
  py_getcwd <- py_os$getcwd()
  py_os$chdir(system.file("python", package = "kerasjs"))
  on.exit(py_os$chdir(py_getcwd), add = TRUE)

  py_subprocess <- reticulate::import("subprocess")

  convert_cmds <- c(
    "python",
    "encoder.py",
    "-n",
    target_path,
    model_path
  )

  proc <- py_subprocess$Popen(
    paste(convert_cmds, collapse = " "),
    shell = TRUE,
    stdout = py_subprocess$PIPE,
    stderr = py_subprocess$STDOUT,
    close_fds = TRUE)

  stds <- proc$communicate()

  exitcode <- proc$returncode
  if (exitcode != 0) {
    stop("Conversion failed:\n", stds[[1]], "\n", stds[[2]])
  }

  message(stds[[1]])

  if (browse) {
    kerasjs_preview(model_path, target_file)
  }

  invisible(target_file)
}
