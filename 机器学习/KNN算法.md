# KNN算法

KNN算法 (K Nearest Neighbor algorithms)

* 适用条件：
> 存在一个训练样本集，样本集中每个数据都有一个对应的标签（即知道样本季中每一数据与所属分类的对应关系

* 基本思路：
> * 输入没有标签的新数据，计算新数据与训练数据集中每个数据的“距离”（和计算两点间距离类似）
> * 将距离从小到大排序
> * 取前k个距离对应的数据（即选择k个最相似的数据）
> * 选择k个最相似数据中出现次数最多的分类，作为新数据的分类

核心代码实现：
```python
# -*- coding: utf-8 -*-
from numpy import *
import operator

def KNN(inX, dataSet, labels, k):
    '''
    :param inX: 用于分类的输入向量
    :param dataSet: 训练样本集
    :param labels: 标签向量
    :param k: 最近邻近的数目
    :return:
    '''
    dataSetSize = dataSet.shape[0] # 样本集中样本的数量
    diffMatrix = tile(inX, (dataSetSize, 1)) - dataSet
    sqDiffMatrix = diffMatrix ** 2
    sqDistances = sqDiffMatrix.sum(axis=1)
    distances = sqDistances ** 0.5 # 平方和开方，即待测点到样本集中每一点的距离构成的数组
    sortedDistIndicies = distances.argsort() # 距离排序
    classCount = {}
    for i in range(k):
        voteIlabel = labels[sortedDistIndicies[i]] # 第k个对应的类
        classCount[voteIlabel] = classCount.get(voteIlabel, 0) + 1 # 类对应的dict加一
    sortedClassCount = sorted(classCount.items(), key=operator.itemgetter(1), reverse=True)
    return sortedClassCount[0][0]
```

《机器学习·实战》中的测试：
```python
# -*- coding: utf-8 -*-
from numpy import *
import KNN


# ===================test1===================
def createDataSet():
    group = array([[1.0,1.1],[1.0,1.0],[0,0],[0,0.1]])
    labels = ['A','A','B','B']
    return group, labels

group, labels = createDataSet()
print(KNN.KNN([0, 0], group, labels, 3))


# ===================test2===================
# 使用k-邻近算法改进约会网站的配对效果
def file2matrix(filename):
    fr = open(filename)
    arrayOLines = fr.readlines()
    numberOfLines = len(arrayOLines)
    returnMat = zeros((numberOfLines, 3))
    classLabelVector = []
    index = 0
    for line in arrayOLines:
        line = line.strip()
        listFromLine = line.split('\t')
        returnMat[index,:] = listFromLine[0:3]
        classLabelVector.append(listFromLine[-1])
        index += 1
    return returnMat, classLabelVector

# 从txt文件读入数据
datingDataSet, datingLabels = file2matrix('./datas/datingTestSet2.txt')

# 绘制散点图
import matplotlib
import matplotlib.pyplot as plt
fig = plt.figure()
ax = fig.add_subplot(111)
ax.scatter(datingDataSet[:,1], datingDataSet[0:,2])
# ax.scatter(datingDataSet[:,1], datingDataSet[0:,2], 15.0 * array(datingLabels), 15.0 * array(datingLabels))
ax.axis([-2, 25, -0.2, 2.0])
plt.xlabel('Percentage of Time Spent Playing Video Games')
plt.ylabel('Liters of Ice Cream Consumed Per Week')
plt.show()

# 归一化特征值
def autoNorm(dataSet):
    minVals = dataSet.min(0)
    maxVals = dataSet.max(0)
    ranges = maxVals - minVals
    normDataSet = zeros(shape(dataSet))
    m = dataSet.shape[0]
    normDataSet = dataSet - tile(minVals, (m, 1))
    normDataSet = normDataSet / tile(ranges, (m, 1))
    return normDataSet, ranges, minVals

def datingClassTest():
    hoRatio = 0.10
    datingDataMat, datingLabels = file2matrix('./datas/datingTestSet2.txt')
    normMat, ranges, minVals = autoNorm(datingDataMat)
    m = normMat.shape[0]
    numTestVecs = int(m * hoRatio) # 测试数据集的长度
    errorCount = 0.0
    # 第i个为待测样本，从numTestVecs到m为已知数据集，进行训练
    for i in range(numTestVecs):
        classifierResult = KNN.KNN(normMat[i,:], normMat[numTestVecs:m,:], datingLabels[numTestVecs:m], 3)
        print("the classifier came back with: %d, the real answer is: %d" % (int(classifierResult), int(datingLabels[i])))
        if (classifierResult != datingLabels[i]):
            errorCount += 1.0
    print("the total error rate is: %f" % (errorCount/float(numTestVecs)))
    print(errorCount)

datingClassTest()


# ===================test3===================
# 手写识别系统
# 图像转换为向量
def img2vector(filename):
    returnVect = zeros((1,1024)) # 图片是 32 * 32 大小的
    fr = open(filename)
    for i in range(32):
        lineStr = fr.readline()
        for j in range(32):
            returnVect[0,32*i+j] = int(lineStr[j])
    return returnVect

from os import listdir
def handwritingClassTest():
    hwLabels = []
    trainingFileList = listdir('./datas/trainingDigits') # 训练数据集所在目录
    m = len(trainingFileList) # 训练数据集长度，即手写数字的个数
    trainingMat = zeros((m, 1024))
    for i in range(m):
        fileNameStr = trainingFileList[i]
        fileStr = fileNameStr.split('.')[0] # 文件名去点后缀
        classNumStr = int(fileStr.split('_')[0]) # 对应的真实数字
        hwLabels.append(classNumStr)
        trainingMat[i,:] = img2vector('./datas/trainingDigits/%s' % fileNameStr)
    testFileList = listdir('./datas/testDigits') # 测试数据集所在目录
    errorCount = 0.0
    mTest = len(testFileList)
    for i in range(mTest): # 处理测试数据集同处理训练数据集
        fileNameStr = testFileList[i]
        fileStr = fileNameStr.split('.')[0]
        classNumStr = int(fileStr.split('_')[0])
        vectorUnderTest = img2vector('./datas/testDigits/%s' % fileNameStr)
        classifierResult = KNN.KNN(vectorUnderTest, trainingMat, hwLabels, 3)
        print("the classifier came back with: %d, the real answer is: %d" % (classifierResult, classNumStr))
        if (classifierResult != classNumStr):
            errorCount += 1.0
    print("\nthe total number of errors is: %d" % errorCount)
    print("\nthe total error rate is: %f" % (errorCount / float(mTest)))

handwritingClassTest()
```