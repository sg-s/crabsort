# convolutional neural network to sort
# spikes using tensorflow 
# lightly adapted from the MNIST tutorial 
# Srinivas Gorur-Shandilya

# imports
import numpy as np
import tensorflow as tf
import h5py 
import params as p


def cnn_model_fn(features, labels, mode):
  """Model function for CNN."""

  # Input Layer
  input_layer = tf.reshape(features["x"], [-1, p.tf_snippet_dim, 1])

  # Convolutional Layer #1
  # uses a bunch of neurons to perform 1D convolutions on the 
  # data 
  # Input Tensor Shape: [batch_size, p.tf_snippet_dim, 1]
  # Output Tensor Shape: [batch_size, p.tf_snippet_dim, p.conv1_N]
  conv1 = tf.layers.conv1d(
      inputs = input_layer,
      filters = p.tf_conv1_N,
      kernel_size = p.tf_conv1_K,
      padding = "same",
      activation = tf.nn.relu)

  # Pooling Layer #1
  # First max pooling layer with a 2x2 filter and stride of 2
  # Input Tensor Shape: [batch_size, 28, 28, 32]
  # Output Tensor Shape: [batch_size, 14, 14, 32]
  pool1 = tf.layers.max_pooling1d(inputs = conv1, pool_size = p.tf_pool1_N, strides = p.tf_pool1_S)

  # Convolutional Layer #2
  # Computes 64 features using a 5x5 filter.
  # Padding is added to preserve width and height.
  # Input Tensor Shape: [batch_size, 14, 14, 32]
  # Output Tensor Shape: [batch_size, 14, 14, 64]
  # conv2 = tf.layers.conv2d(
  #     inputs=pool1,
  #     filters=64,
  #     kernel_size=[5, 5],
  #     padding="same",
  #     activation=tf.nn.relu)

  # # Pooling Layer #2
  # # Second max pooling layer with a 2x2 filter and stride of 2
  # # Input Tensor Shape: [batch_size, 14, 14, 64]
  # # Output Tensor Shape: [batch_size, 7, 7, 64]
  # pool2 = tf.layers.max_pooling2d(inputs=conv2, pool_size=[2, 2], strides=2)

  # Flatten tensor into a batch of vectors
  # Input Tensor Shape: [batch_size, 7, 7, 64]
  # Output Tensor Shape: [batch_size, 7 * 7 * 64]
  #pool2_flat = tf.reshape(pool2, [-1, 7 * 7 * 64])
  pflat_size = np.int32(np.floor(p.tf_snippet_dim/p.tf_pool1_N))
  pool2_flat = tf.reshape(pool1, [-1, pflat_size * p.tf_conv1_N])

  # Dense Layer
  # Densely connected layer with 1024 neurons
  # Input Tensor Shape: [batch_size, 7 * 7 * 64]
  # Output Tensor Shape: [batch_size, 1024]
  dense = tf.layers.dense(inputs = pool2_flat, units = p.tf_dense_N, activation = tf.nn.relu)

  # Add dropout operation; 0.6 probability that element will be kept
  dropout = tf.layers.dropout(
      inputs = dense, rate = p.tf_dropout_rate, training = mode == tf.estimator.ModeKeys.TRAIN)

  # Logits layer (the output layer)
  # Input Tensor Shape: [batch_size, 1024]
  # Output Tensor Shape: [batch_size, 10]
  logits = tf.layers.dense(inputs = dropout, units = p.tf_N_classes)

  predictions = {
      # Generate predictions (for PREDICT and EVAL mode)
      "classes": tf.argmax(input=logits, axis=1),
      # Add `softmax_tensor` to the graph. It is used for PREDICT and by the
      # `logging_hook`.
      "probabilities": tf.nn.softmax(logits, name="softmax_tensor")
  }
  if mode == tf.estimator.ModeKeys.PREDICT:
    return tf.estimator.EstimatorSpec(mode=mode, predictions=predictions)

  # Calculate Loss (for both TRAIN and EVAL modes)
  loss = tf.losses.sparse_softmax_cross_entropy(labels=labels, logits=logits)

  # Configure the Training Op (for TRAIN mode)
  if mode == tf.estimator.ModeKeys.TRAIN:
    optimizer = tf.train.GradientDescentOptimizer(learning_rate=0.001)
    train_op = optimizer.minimize(
        loss=loss,
        global_step=tf.train.get_global_step())
    return tf.estimator.EstimatorSpec(mode=mode, loss=loss, train_op=train_op)

  # Add evaluation metrics (for EVAL mode)
  eval_metric_ops = {
      "accuracy": tf.metrics.accuracy(
          labels=labels, predictions=predictions["classes"])}
  return tf.estimator.EstimatorSpec(
      mode=mode, loss=loss, eval_metric_ops=eval_metric_ops)


def train():
  # Load training and eval data
  hf = h5py.File('spike_data.mat','r')
  X = np.array(hf.get('X_test'));
  Y = np.array(hf.get('Y_test'));

  eval_data = X.astype(np.float32, copy=False)
  eval_labels = Y.astype(np.int32, copy=False)

  X = np.array(hf.get('X_train'));
  Y = np.array(hf.get('Y_train'));

  train_data = X.astype(np.float32, copy=False)
  train_labels = Y.astype(np.int32, copy=False)


  # convert to 0-indexing & flatten to 1D
  train_labels = train_labels.flatten() - 1
  eval_labels = eval_labels.flatten() - 1


  # Create the Estimator
  mnist_classifier = tf.estimator.Estimator(
      model_fn=cnn_model_fn, model_dir=p.tf_model_dir)


  # Train the model
  train_input_fn = tf.estimator.inputs.numpy_input_fn(
      x={"x": train_data},
      y=train_labels,
      batch_size=100,
      num_epochs=None,
      shuffle=True)
  mnist_classifier.train(
      input_fn=train_input_fn,
      steps=p.tf_nsteps)

  # Evaluate the model and print results
  eval_input_fn = tf.estimator.inputs.numpy_input_fn(
      x={"x": eval_data},
      y=eval_labels,
      num_epochs=1,
      shuffle=False)
  eval_results = mnist_classifier.evaluate(input_fn=eval_input_fn)
  print(eval_results)



def predict():

  # Load data
  hf = h5py.File('spike_data.mat','r')
  X = np.array(hf.get('X_test'));
  Y = np.array(hf.get('Y_test'));

  eval_data = X.astype(np.float32, copy=False)
  eval_labels = Y.astype(np.int32, copy=False)

  eval_data = eval_data

  # convert to 0-indexing & flatten to 1D
  eval_labels = eval_labels.flatten() - 1


  # Create the Estimator
  mnist_classifier = tf.estimator.Estimator(
      model_fn=cnn_model_fn, model_dir=p.tf_model_dir)


  # Evaluate the model and print results
  eval_input_fn = tf.estimator.inputs.numpy_input_fn(
      x={"x": eval_data},
      y=eval_labels,
      num_epochs=1,
      shuffle=False)
  eval_results = mnist_classifier.evaluate(input_fn=eval_input_fn)
  print(eval_results)

  # make predictions 
  eval_results = mnist_classifier.predict(input_fn=eval_input_fn)

  s = eval_data.shape
  predictions = np.zeros(s[0])

  c = 0
  eval_results = mnist_classifier.predict(input_fn=eval_input_fn)
  for result in eval_results:
    predictions[c] = result['classes']
    c = c + 1

  # convert back to matlab indexing 
  predictions = predictions + 1

  # need to save predictions to disk 
  with h5py.File('data.h5', 'w') as hf:
    hf.create_dataset('predictions', data=predictions)




if __name__ == "__main__":
  tf.app.run()