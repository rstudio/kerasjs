#' Converts HDF5 Model to KerasJS
#'
#' Converts HDF5 model into KerasJS format.
#'
#' @inheritParams convert_hdf5model
#'
#' @importFrom tools file_path_sans_ext
#' @export
convert_hdf5model.kerasjs_conversion <- function(
  model_name = NULL,
  target = file_path_sans_ext(model_name),
  ...
) {
  model_name <- normalizePath(model_name, mustWork = TRUE)

  py_os <- reticulate::import("os")
  py_getcwd <- py_os$getcwd()
  py_os$chdir(system.file("kerasjs", package = "tfconvert"))
  on.exit(py_os$chdir(py_getcwd), add = TRUE)

  py_subprocess <- reticulate::import("subprocess")

  convert_cmds <- c(
    "python",
    "encoder.py",
    "-n",
    target,
    model_name
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
}
