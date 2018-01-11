library(tensorflow)

# define output folder
model_dir <- tempfile()

# define simple +1 tensor operations
sess <- tf$Session()
input <- tf$placeholder(tf$float32, shape = c(3))
output <- tf$add(input, 1)

unlink("tensorflow-lite", recursive = TRUE)
export_savedmodel(
  sess,
  "tensorflow-lite",
  inputs = list(input = input),
  outputs = list(output = output)
)
