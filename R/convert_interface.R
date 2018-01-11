#' Converts a SavedModel
#'
#' Converts a TensorFlow SavedModel into other model formats.
#'
#' @param model_dir The path to the exported model, as a string.
#'
#' @param format The target format for the converted model. Currently only
#'   \code{tflite}.
#'
#' @param target The target path for the converted model.
#'
#' @param signature_name The named entry point to use in the model for prediction.
#'
#' @param ... Additional arguments. See \code{?convert_savedmodel.tflite_conversion}
#'   for additional options.
#'
#' @export
convert_savedmodel <- function(
  model_dir = NULL,
  format = c("tflite"),
  target = paste("savedmodel", format, sep = "."),
  signature_name = "serving_default",
  ...
) {
  class(model_dir) <- paste0(format, "_conversion")
  UseMethod("convert_savedmodel", model_dir)
}

#' Converts a HDF5 Model
#'
#' Converts a HDF5 model into other model formats.
#'
#' @param model_name The path to the HDF5 exported model, as a string.
#'
#' @param format The target format for the converted model. Currently only
#'   \code{kerasjs}.
#'
#' @param target The target path for the converted model.
#'
#' @export
convert_hdf5model <- function(
  model_name = NULL,
  format = c("kerasjs"),
  target = NULL,
  ...
) {
  class(model_name) <- paste0(format, "_conversion")
  UseMethod("convert_hdf5model", model_name)
}

