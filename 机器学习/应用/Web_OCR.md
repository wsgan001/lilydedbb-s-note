# Web 应用：神经网络实现手写字符识别系统

**神经网络**

```python
# -*- coding: UTF-8 -*-
import csv
import numpy as np
from numpy import matrix
from math import pow
from collections import namedtuple
import math
import random
import os
import json

class OCRNeuralNetwork:
    LEARNING_RATE = 0.1
    WIDTH_IN_PIXELS = 20
    # 保存神经网络的文件路径
    NN_FILE_PATH = 'nn.json'

    def __init__(self, num_hidden_nodes, data_matrix, data_labels, training_indices, use_file=True):
        self.sigmoid = np.vectorize(self._sigmoid_scalar) # 使用numpy的vectorize能得到标量函数的向量化版本
        self.sigmoid_prime = np.vectorize(self._sigmoid_scalar_prime)
        self._use_file = use_file # 决定要不要导入nn.json
        # 数据集
        self.data_matrix = data_matrix
        self.data_labels = data_labels

        if (not os.path.isfile(self.NN_FILE_PATH) or not use_file):
            self.theta1 = self._rand_initialize_weights(num_hidden_nodes, 400)
            self.theta2 = self._rand_initialize_weights(10, num_hidden_nodes)
            self.input_layer_bias = self._rand_initialize_weights(num_hidden_nodes, 1)
            self.hidden_layer_bias = self._rand_initialize_weights(10, 1)
            TrainData = namedtuple('TrainData', ['y0', 'label'])
            self.train([TrainData(self.data_matrix[i], int(self.data_labels[i])) for i in training_indices])
            self.save()
        else:
            self._load()

    def _sigmoid_scalar(self, z):
        """sigmoid 的标量函数"""
        return 1 / (1 + math.e ** -z)

    def _sigmoid_scalar_prime(self, z):
        """sigmoid 的导函数"""
        return self.sigmoid(z) * (1 - self.sigmoid(z))

    def _rand_initialize_weights(self, shape1, shape2):
        return [(x * 0.12 - 0.06) for x in np.random.rand(shape1, shape2)]

    def train(self, training_data_array):
        for data in training_data_array:
            # 前向传播
            y1 = np.dot(np.mat(self.theta1), np.mat(data.y0).T)
            sum1 = y1 + np.mat(self.input_layer_bias)
            y1 = self.sigmoid(sum1)
            y2 = np.dot(np.array(self.theta2), y1)
            y2 = np.add(y2, self.hidden_layer_bias)
            y2 = self.sigmoid(y2)
            # 反向传播
            actual_vals = [0] * 10
            actual_vals[data.label] = 1
            output_errors = np.mat(actual_vals).T - np.mat(y2)
            hidden_errors = np.multiply(np.dot(np.mat(self.theta2).T, output_errors), self.sigmoid_prime(sum1))
            self.theta1 += self.LEARNING_RATE * np.dot(np.mat(hidden_errors), np.mat(data.y0))
            self.theta2 += self.LEARNING_RATE * np.dot(np.mat(output_errors), np.mat(y1).T)
            self.hidden_layer_bias += self.LEARNING_RATE * output_errors
            self.input_layer_bias += self.LEARNING_RATE * hidden_errors

    def predict(self, test):
        y1 = np.dot(np.mat(self.theta1), np.mat(test).T)
        y1 = y1 + np.mat(self.input_layer_bias)  # Add the bias
        y1 = self.sigmoid(y1)

        y2 = np.dot(np.array(self.theta2), y1)
        y2 = np.add(y2, self.hidden_layer_bias)  # Add the bias
        y2 = self.sigmoid(y2)

        results = y2.T.tolist()[0]
        return results.index(max(results))

    def save(self):
        if not self._use_file:
            return

        json_neural_network = {
            "theta1": [np_mat.tolist()[0] for np_mat in self.theta1],
            "theta2": [np_mat.tolist()[0] for np_mat in self.theta2],
            "b1": self.input_layer_bias[0].tolist()[0],
            "b2": self.hidden_layer_bias[0].tolist()[0]
        }
        with open(OCRNeuralNetwork.NN_FILE_PATH, 'w') as nnFile:
            json.dump(json_neural_network, nnFile)

    def _load(self):
        if not self._use_file:
            return

        with open(self.NN_FILE_PATH) as nnFile:
            nn = json.load(nnFile)
        self.theta1 = [np.array(li) for li in nn['theta1']]
        self.theta2 = [np.array(li) for li in nn['theta2']]
        self.input_layer_bias = [np.array(nn['b1'][0])]
        self.hidden_layer_bias = [np.array(nn['b2'][0])]
```

探索隐含层为多少个节点，性能最好：

（数据集来源：

```
$ wget http://labfile.oss.aliyuncs.com/courses/593/data.csv
$ wget http://labfile.oss.aliyuncs.com/courses/593/dataLabels.csv
```

)

```python
# 神经网络设计脚本
import numpy as np

from ocr import OCRNeuralNetwork
from sklearn.cross_validation import train_test_split

def test(data_matrix, data_labels, test_indices, nn):
    correct = 0
    for i in test_indices:
        test = data_matrix[i]
        prediction = nn.predict(test)
        if data_labels[i] == prediction:
            correct += 1
    return correct / float(len(test_indices))

data_matrix = np.loadtxt(open('data.csv', 'rb'), delimiter=',').tolist()
data_labels = np.loadtxt(open('dataLabels.csv', 'rb')).tolist()
train_indices, test_indices = train_test_split(list(range(5000)))

for i in range(5, 50):
    nn = OCRNeuralNetwork(i, data_matrix, data_labels, train_indices, False)
    performance = str(test(data_matrix, data_labels, test_indices, nn))
    print ("{i} Hidden Nodes' Performance: {val}".format(i=i, val=performance))
```

一次运行结果如下：

```
5 Hidden Nodes' Performance: 0.756
6 Hidden Nodes' Performance: 0.8216
7 Hidden Nodes' Performance: 0.8472
8 Hidden Nodes' Performance: 0.8096
9 Hidden Nodes' Performance: 0.8184
10 Hidden Nodes' Performance: 0.8432
11 Hidden Nodes' Performance: 0.8736
12 Hidden Nodes' Performance: 0.8488
13 Hidden Nodes' Performance: 0.8856
14 Hidden Nodes' Performance: 0.8856
15 Hidden Nodes' Performance: 0.8872
16 Hidden Nodes' Performance: 0.88
17 Hidden Nodes' Performance: 0.8896
18 Hidden Nodes' Performance: 0.8912
19 Hidden Nodes' Performance: 0.8904
20 Hidden Nodes' Performance: 0.8864
21 Hidden Nodes' Performance: 0.8936
22 Hidden Nodes' Performance: 0.8952
23 Hidden Nodes' Performance: 0.8896
24 Hidden Nodes' Performance: 0.8944
25 Hidden Nodes' Performance: 0.8944
26 Hidden Nodes' Performance: 0.8936
27 Hidden Nodes' Performance: 0.9016
28 Hidden Nodes' Performance: 0.8936
29 Hidden Nodes' Performance: 0.8928
30 Hidden Nodes' Performance: 0.8944
31 Hidden Nodes' Performance: 0.8856
32 Hidden Nodes' Performance: 0.8968
33 Hidden Nodes' Performance: 0.892
34 Hidden Nodes' Performance: 0.8896
35 Hidden Nodes' Performance: 0.8912
36 Hidden Nodes' Performance: 0.8968
37 Hidden Nodes' Performance: 0.8928
38 Hidden Nodes' Performance: 0.8992
39 Hidden Nodes' Performance: 0.8984
40 Hidden Nodes' Performance: 0.8952
41 Hidden Nodes' Performance: 0.8976
42 Hidden Nodes' Performance: 0.8944
43 Hidden Nodes' Performance: 0.8976
44 Hidden Nodes' Performance: 0.9016
45 Hidden Nodes' Performance: 0.8928
46 Hidden Nodes' Performance: 0.892
47 Hidden Nodes' Performance: 0.9
48 Hidden Nodes' Performance: 0.8928
49 Hidden Nodes' Performance: 0.8928
```

服务器端和客户端文件：

**server.py**

```python
# -*- coding: UTF-8 -*-
import BaseHTTPServer
import json
import numpy as np
import random
from ocr import OCRNeuralNetwork

HOST_NAME = 'localhost'
PORT_NUMBER = 9000
HIDDEN_NODE_COUNT = 20

data_matrix = np.loadtxt(open('data.csv', 'rb'), delimiter = ',').tolist()
data_labels = np.loadtxt(open('dataLabels.csv', 'rb')).tolist()

train_indices = range(5000)
random.shuffle(train_indices)

nn = OCRNeuralNetwork(HIDDEN_NODE_COUNT, data_matrix, data_labels, train_indices)

class JSONHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_POST(self):
        response_code = 200
        response = ""
        var_len = int(self.headers.get('Content-Length'))
        content = self.rfile.read(var_len)
        payload = json.loads(content)

        # 如果是训练请求，训练然后保存训练完的神经网络
        if payload.get('train'):
            nn.train(payload['trainArray'])
            nn.save()
        # 如果是预测请求，返回预测值
        elif payload.get('predict'):
            try:
                print(nn.predict(data_matrix[0]))
                response = {"type": "test", "result": str(nn.predict(payload['image']))}
            except:
                response_code = 500
        else:
            response_code = 400

        self.send_response(response_code)
        self.send_header("Content-type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        if response:
            self.wfile.write(json.dumps(response))
        return

if __name__ == '__main__':
    server_class = BaseHTTPServer.HTTPServer
    httpd = server_class((HOST_NAME, PORT_NUMBER), JSONHandler)

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    else:
        print("Unexpected server exception occurred.")
    finally:
        httpd.server_close()
```

**ocr.js & ocr.html**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>OCR Demo</title>
    <script type="text/javascript" src="./ocr.js"></script>
</head>
<body onload="ocr.onLoadFunction()">
    <div id="container" style="text-align: center;">
        <h1>ORC Demo</h1>
        <canvas id="canvas" width="200" height="200"></canvas>
        <form name="input">
            <p>Digit: <input id="digit" type="text"> </p>
            <input type="button" value="Train" onclick="ocr.train()">
            <input type="button" value="Test" onclick="ocr.test()">
            <input type="button" value="Reset" onclick="ocr.resetCanvas();"/>
        </form>
    </div>
</body>
</html>
```

```js
/**
 * Created by dbb on 2017/7/14.
 */
var ocr = {
    CANVAS_WIDTH: 200,
    TRANSLATED_WIDTH: 20,
    PIXEL_WIDTH: 10, // TRANSLATED_WIDTH = CANVAS_WIDTH / PIXEL_WIDTH
    BATCH_SIZE: 1,
    PORT: 9000,
    HOST: "http://localhost",
    // 颜色
    BLACK: "#000000",
    BLUE: "#0000ff",
    WHITE: "#ffffff",
    trainArray: [],
    trainingRequestCount: 0,
    onLoadFunction: function () {
        this.resetCanvas();
    },
    resetCanvas: function () {
        var canvas = document.getElementById('canvas');
        var ctx = canvas.getContext('2d');
        this.data = [];
        ctx.fillStyle = this.BLACK;
        ctx.fillRect(0, 0, this.CANVAS_WIDTH, this.CANVAS_WIDTH);
        var matrixSize = 400;
        while (matrixSize--) this.data.push(0);
        this.drawGrid(ctx);

        canvas.onmousemove = function (e) {
            this.onMouseMove(e, ctx, canvas);
        }.bind(this);
        canvas.onmousedown = function (e) {
            this.onMouseDown(e, ctx, canvas);
        }.bind(this);
        canvas.onmouseup = function (e) {
            this.onMouseUp(e);
        }.bind(this);
    },
    // 在canvas上加上网格辅助输入和查看
    drawGrid: function (ctx) {
        for (var x = this.PIXEL_WIDTH, y = this.PIXEL_WIDTH;
            x < this.CANVAS_WIDTH && y < this.CANVAS_WIDTH;
             x += this.PIXEL_WIDTH, y += this.PIXEL_WIDTH) {
            ctx.strokeStyle = this.BLUE;
            ctx.beginPath();
            ctx.moveTo(x, 0);
            ctx.lineTo(x, this.CANVAS_WIDTH);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(this.CANVAS_WIDTH, y);
            ctx.stroke();
        }
    },
    onMouseMove: function (e, ctx, canvas) {
        if (!canvas.isDrawing) return;
        this.fillSquare(ctx, e.clientX - canvas.offsetLeft, e.clientY - canvas.offsetTop);
    },
    onMouseDown: function (e, ctx, canvas) {
        canvas.isDrawing = true;
        this.fillSquare(ctx, e.clientX - canvas.offsetLeft, e.clientY - canvas.offsetTop);
    },
    onMouseUp: function (e) {
        canvas.isDrawing = false;
    },
    fillSquare: function (ctx, x, y) {
        var xPixel = Math.floor(x / this.PIXEL_WIDTH);
        var yPixel = Math.floor(y / this.PIXEL_WIDTH);
        this.data[(xPixel) * this.PIXEL_WIDTH + yPixel] = 1;
        ctx.fillStyle = this.WHITE;
        ctx.fillRect(xPixel * this.PIXEL_WIDTH, yPixel * this.PIXEL_WIDTH,
            this.PIXEL_WIDTH, this.PIXEL_WIDTH);
    },
    train: function () {
        var digitVal = document.getElementById('digit').value;
        if (!digitVal || this.data.indexOf(1) < 0) {
            alert("Please type and draw a digit value in order to train the network");
            return;
        }
        this.trainArray.push({ "y0": this.data, "label": parseInt(digitVal) });
        this.trainingRequestCount++;
        if (this.trainingRequestCount == this.BATCH_SIZE) {
            alert("Sending training data to server...");
            var json = {
                trainArray: this.trainArray,
                train: true
            };
            this.sendData(json);
            this.trainingRequestCount = 0;
            this.trainArray = [];
        }
    },
    test: function () {
        if (this.data.indexOf(1) < 0) {
            alert("Please draw a digit in order to test the network");
            return;
        }
        var json = {
            image: this.data,
            predict: true
        };
        this.sendData(json);
    },
    receiveResponse: function (xmlHttp) {
        if (xmlHttp.status != 200) {
            alert("Server returned status " + xmlHttp.status);
            return;
        }
        var responseJSON = JSON.parse(xmlHttp.responseText);
        if (xmlHttp.responseText && responseJSON.type == "test") {
            alert("The neural network predicts you wrote a \'"
                   + responseJSON.result + '\'');
        }
    },
    onError: function (e) {
        alert("Error occurred while connecting to server: " + e.target.statusText);
    },
    sendData: function (json) {
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.open('POST', this.HOST + ':' + this.PORT, false);
        xmlHttp.onload = function () {
            this.receiveResponse(xmlHttp);
        }.bind(this);
        xmlHttp.onerror = function (e) {
            this.onError(e);
        }.bind(this);
        var msg = JSON.stringify(json);
        xmlHttp.setRequestHeader('Content-length', msg.length);
        xmlHttp.setRequestHeader("Connection", "close");
        xmlHttp.send(msg);
    }
}
```