## 序列化【pickle】

把一个对象序列化并写入文件：
```python
>>> import pickle
>>> d = dict(name='dbb', age=21, score=100)
>>> pickle.dumps(d)
b'\x80\x03}q\x00(X\x05\x00\x00\x00scoreq\x01KdX\x04\x00\x00\x00nameq\x02X\x03\x00\x00\x00dbbq\x03X\x03\x00\x00\x00ageq\x04K\x15u.'
```
其中```pickle.dumps()```方法把任意对象序列化成一个bytes，然后，就可以把这个bytes写入文件。或者用另一个方法```pickle.dump()```直接把对象序列化后写入一个```file-like Object```：
```python
>>> f = open('dump.txt', 'wb')
>>> pickle.dump(d, f)
>>> f.close()
```
把对象从磁盘读到内存时，可以先把内容读到一个```bytes```，然后用```pickle.loads()```方法反序列化出对象，也可以直接用```pickle.load()```方法从一个```file-like Object```中直接反序列化出对象。打开另一个Python命令行来反序列化刚才保存的对象
```python
>>> f = open('dump.txt', 'rb')
>>> d = pickle.load(f)
>>> f.close()
>>> d
```


## JSON
Python内置的```json```模块提供了非常完善的Python对象到JSON格式的转换。
```python
>>> import json
>>> d = dict(name='dbb', age=21, score=100)
>>> json.dumps(d)
'{"score": 100, "name": "dbb", "age": 21}'
```
```python
>>> json_d = '{"score": 100, "name": "dbb", "age": 21}'
>>> json.loads(json_d)
{'score': 100, 'name': 'dbb', 'age': 21}
```

### 把一个实例转化为JSON
```python
import json

class Student(object):

    def __init__(self, name, age, score):
        self.name = name
        self.age = age
        self.score = score

# 需要为Student专门写一个转换函数，再把函数传进去即可
def student2dict(std):
    return {
        'name': std.name,
        'age': std.age,
        'score': std.score
    }

>>> json.dumps(s, default=student2dict)
'{"age": 21, "score": 100, "name": "dbb"}'
```
```python
# 也可以不写student2dict方法，用class实例的__dict__属性
>>> json.dumps(s, default=lambda obj: obj.__dict__)
'{"age": 21, "name": "dbb", "score": 100}'
```
如果需要反序列化，童颜要写一个辅助函数
```python
def dict2student(d):
    return Student(d['name'], d['age'], d['score'])
>>> json.loads(json_str, object_hook=dict2student)
<__main__.Student object at 0x10188e5f8>
```
同样也可以用匿名函数的方法
```python
>>> json.loads(json_str, object_hook=lambda d: Student(d['name'], d['age'], d['score']))
<__main__.Student object at 0x10188e5f8>
```