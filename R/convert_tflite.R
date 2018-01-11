#' Convert to TensorFlow Lite
#'
#' Converts a model to TensorFlow Lite.
#'
#' @inheritParams convert_savedmodel
#'
#' @param inference_type: Currently must be \code{"FLOAT"} or
#' \code{"QUANTIZED_UINT8"}.
#'
#' @param quantized_input_stats For each member of input_tensors the mean and
#' std deviation of training data. Only needed \code{inference_type} is
#' \code{"QUANTIZED_UINT8"}.
#'
#' @param drop_control_dependency: Drops control dependencies silently. This is
#' due to tf lite not supporting control dependencies.
#'
#' @export
convert_savedmodel.tflite_conversion <- function(
  model_dir = NULL,
  target = "savedmodel.tflite",
  signature_name = "serving_default",
  inference_type = "FLOAT",
  quantized_input_stats = NULL,
  drop_control_dependency = TRUE,
  ...
) {

  if (!identical(tools::file_ext(target), "tflite"))
    stop("Use 'tflite' extensions to convert to TensorFlow light.")

  if (tf$VERSION < "1.5.0")
    stop("TensorFlow Lite requires TensorFlow 1.5 or later.")

  if (identical(inference_type, "QUANTIZED_UINT8"))
    inference_type <- tf$contrib$lite$QUANTIZED_UINT8
  else if (identical(inference_type, "FLOAT"))
    inference_type <- tf$contrib$lite$FLOAT
  else
    stop("Expecting 'inference_type' to be 'FLOAT' or 'QUANTIZED_UINT8'.")

  # Workaround for https://github.com/tensorflow/tensorflow/pull/15890
  py_tempfile <- reticulate::import("tempfile")
  py_subprocess <- reticulate::import("subprocess")
  tf$contrib$lite$tempfile <- py_tempfile
  tf$contrib$lite$subprocess <- py_subprocess

  with_new_session(function(sess) {
    graph <- load_savedmodel(sess, model_dir)

    tensor_boundaries <- tensor_get_boundaries(sess$graph, graph$signature_def, signature_name)

    tensor_inputs <- tensor_boundaries$tensors$inputs
    tensor_outputs <- tensor_boundaries$tensors$outputs

    tflite_model <- tf$contrib$lite$toco_convert(
      graph$graph_def,
      unlist(tensor_inputs, use.names = FALSE),
      unlist(tensor_outputs, use.names = FALSE),
      inference_type = inference_type,
      quantized_input_stats = quantized_input_stats,
      drop_control_dependency = drop_control_dependency
    )

    py <- reticulate::import_builtins()

    with(py$open(target, "wb") %as% file, {
      file$write(tflite_model)
      file$flush()
    })
  })
}
