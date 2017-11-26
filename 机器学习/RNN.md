# RNN

```python
import copy, numpy as np
np.random.seed(0)

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def sigmoid_ouput_to_derivative(output):
    return output * (1 - output)

int2binary = {}
binary_dim = 8
largest_number = pow(2, binary_dim)
binary = np.unpackbits(
    np.array([range(largest_number)], dtype=np.uint8).T, axis=1)
# binary =
# [[0 0 0 ..., 0 0 0]
#  [0 0 0 ..., 0 0 1]
#  [0 0 0 ..., 0 1 0]
#  ...,
#  [1 1 1 ..., 1 0 1]
#  [1 1 1 ..., 1 1 0]
#  [1 1 1 ..., 1 1 1]]
for i in range(largest_number):
    int2binary[i] = binary[i]

alpha = 0.1
input_dim = 2
hidden_dim = 16
output_dim = 1

# 初始化神经网络的权重
synapse_0 = 2 * np.random.random((input_dim, hidden_dim)) - 1
synapse_1 = 2 * np.random.random((hidden_dim, output_dim)) - 1
synapse_h = 2 * np.random.random((hidden_dim, hidden_dim)) - 1

synapse_0_update = np.zeros_like(synapse_0)
synapse_1_update = np.zeros_like(synapse_1)
synapse_h_update = np.zeros_like(synapse_h)

for j in range(10000):

    # generate a simple addition problem (a + b = c)
    a_int = np.random.randint(largest_number / 2)
    a = int2binary[a_int]
    b_int = np.random.randint(largest_number / 2)
    b = int2binary[b_int]

    c_int = a_int + b_int
    c = int2binary[c_int]

    d = np.zeros_like(c)
    overallError = 0

    layer_2_deltas = list()
    layer_1_values = list()
    layer_1_values.append(np.zeros(hidden_dim))

    for position in range(binary_dim):

        X = np.array([[a[binary_dim - position - 1], b[binary_dim - position - 1]]])
        y = np.array([c[binary_dim - position - 1]]).T

        layer_1 = sigmoid(np.dot(X, synapse_0) + np.dot(layer_1_values[-1], synapse_h))
        layer_2 = sigmoid(np.dot(layer_1, synapse_1))

        layer_2_error = y - layer_2

        layer_2_deltas.append((layer_2_error) * sigmoid_ouput_to_derivative(layer_2))
        overallError += np.abs(layer_2_error[0])

        d[binary_dim - position - 1] = np.round(layer_2[0][0])

        layer_1_values.append(copy.deepcopy(layer_1))

    future_layer_1_delta = np.zeros(hidden_dim)

    for position in range(binary_dim):

        X = np.array([[a[position], b[position]]])
        layer_1 = layer_1_values[-position - 1]
        prev_layer_1 = layer_1_values[-position - 2]

        # error at output layer
        layer_2_delta = layer_2_deltas[-position - 1]
        # error at hidden layer
        layer_1_delta = (future_layer_1_delta.dot(synapse_h.T) + layer_2_delta.dot(synapse_1.T)) * sigmoid_ouput_to_derivative(layer_1)

        synapse_1_update += np.atleast_2d(layer_1).T.dot(layer_2_delta)
        synapse_h_update += np.atleast_2d(prev_layer_1).T.dot(layer_1_delta)
        synapse_0_update += X.T.dot(layer_1_delta)

        future_layer_1_delta = layer_1_delta

    synapse_0 += synapse_0_update * alpha
    synapse_1 += synapse_1_update * alpha
    synapse_h += synapse_h_update * alpha

    synapse_0_update *= 0
    synapse_1_update *= 0
    synapse_h_update *= 0

    if (j % 100 == 0):
        print("Error: " + str(overallError))
        print("Predict: " + str(d))
        print("Standard: " + str(c))
        out = 0
        for index, x in enumerate(reversed(d)):
            out += x * pow(2, index)
        print(str(a_int) + " + " + str(b_int) + " = " + str(out))
        print("---------------------------------")
```