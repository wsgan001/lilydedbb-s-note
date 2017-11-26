# SQL 高级查询语句


## JOIN 关键字

### INNER JOIN
```sql
SELECT column_name(s)
FROM table_name1
INNER JOIN table_name2
ON table_name1.column_name=table_name2.column_name
```
**`INNER JOIN` 与 `JOIN` 相同**

**`INNER JOIN` 关键字在表中存在至少一个匹配时返回行，如果 `table_name1` 中的行在 `table_name2` 中没有匹配，就不会列出这些行**

### LEFT JOIN
```sql
SELECT column_name(s)
FROM table_name1
LEFT JOIN table_name2
ON table_name1.column_name=table_name2.column_name
```
在某些数据库中， `LEFT JOIN` 称为 `LEFT OUTER JOIN`

**`LEFT JOIN` 关键字会从左表 (`table_name1`) 那里返回所有的行，即使在右表 (`table_name2`) 中没有匹配的行**

### RIGHT JOIN
```sql
SELECT column_name(s)
FROM table_name1
RIGHT JOIN table_name2
ON table_name1.column_name=table_name2.column_name
```
在某些数据库中， `RIGHT JOIN` 称为 `RIGHT OUTER JOIN`

**`RIGHT JOIN` 关键字会右表 (`table_name2`) 那里返回所有的行，即使在左表 (`table_name1`) 中没有匹配的行**

### FULL JOIN
```sql
SELECT column_name(s)
FROM table_name1
FULL JOIN table_name2
ON table_name1.column_name=table_name2.column_name
```
在某些数据库中， `FULL JOIN` 称为 `FULL OUTER JOIN`

**只要其中某个表存在匹配，`FULL JOIN` 关键字就会返回行**


## UNION 操作符

`UNION` 操作符用于合并两个或多个 `SELECT` 语句的结果集

**`UNION` 内部的 `SELECT` 语句必须拥有相同数量的列，列也必须拥有相似的数据类型；同时，每条 `SELECT` 语句中的列的顺序必须相同**

**另外，`UNION` 结果集中的列名总是等于 `UNION` 中第一个 `SELECT` 语句中的列名**

### SQL UNION 语法
```sql
SELECT column_name(s) FROM table_name1
UNION
SELECT column_name(s) FROM table_name2
```
**默认地，`UNION` 操作符选取不同的值。如果允许重复的值，请使用 `UNION ALL`**

### SQL UNION ALL
```sql
SELECT column_name(s) FROM table_name1
UNION ALL
SELECT column_name(s) FROM table_name2
```


## KEY 约束

### PRIMARY KEY

- `PRIMARY KEY` 约束唯一标识数据库表中的每条记录
- 主键必须包含唯一的值
- 主键列不能包含 `NULL` 值
- 每个表都应该有一个主键，并且每个表只能有一个主键

下面的 SQL 在一个名为 "Persons" 表创建时在 "Id_P" 列创建 `PRIMARY KEY` 约束：
```sql
CREATE TABLE Persons
(
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    PRIMARY KEY (Id_P)
)
```
```sql
CREATE TABLE Persons
(
    Id_P int NOT NULL PRIMARY KEY,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
)
```

如果需要命名 `PRIMARY KEY` 约束，以及为多个列定义 `PRIMARY KEY` 约束：
```sql
CREATE TABLE Persons
(
    Id_P int NOT NULL,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
    CONSTRAINT pk_PersonID PRIMARY KEY (Id_P,LastName)
)
```

如果在表已存在的情况下为 "Id_P" 列创建 `PRIMARY KEY` 约束：
```sql
ALTER TABLE Persons
ADD PRIMARY KEY (Id_P)
```
```sql
ALTER TABLE Persons
ADD CONSTRAINT pk_PersonID PRIMARY KEY (Id_P,LastName)
```

撤销 `PRIMARY KEY` 约束：
```sql
ALTER TABLE Persons
DROP PRIMARY KEY
```
```sql
ALTER TABLE Persons
DROP CONSTRAINT pk_PersonID
```

### FOREIGN KEY
```sql
MySQL:
CREATE TABLE Orders
(
    Id_O int NOT NULL,
    OrderNo int NOT NULL,
    Id_P int,
    PRIMARY KEY (Id_O),
    FOREIGN KEY (Id_P) REFERENCES Persons(Id_P)
)
```
```sql
CREATE TABLE Orders
(
    Id_O int NOT NULL PRIMARY KEY,
    OrderNo int NOT NULL,
    Id_P int FOREIGN KEY REFERENCES Persons(Id_P)
)
```
如果需要命名 `FOREIGN KEY` 约束，以及为多个列定义 `FOREIGN KEY` 约束：
```sql
CREATE TABLE Orders
(
    Id_O int NOT NULL,
    OrderNo int NOT NULL,
    Id_P int,
    PRIMARY KEY (Id_O),
    CONSTRAINT fk_PerOrders FOREIGN KEY (Id_P)
    REFERENCES Persons(Id_P)
)
```

如果在 "Orders" 表已存在的情况下为 "Id_P" 列创建 `FOREIGN` 约束：
```sql
ADD FOREIGN KEY (Id_P)
REFERENCES Persons(Id_P)
```
如果需要命名 `FOREIGN KEY` 约束，以及为多个列定义 `FOREIGN KEY` 约束：
```sql
ALTER TABLE Orders
ADD CONSTRAINT fk_PerOrders
FOREIGN KEY (Id_P)
REFERENCES Persons(Id_P)
```
撤销 `FOREIGN KEY` 约束：
```sql
ALTER TABLE Orders
DROP FOREIGN KEY fk_PerOrders
```
```sql
ALTER TABLE Orders
DROP CONSTRAINT fk_PerOrders
```


## Alias 操作符

通过使用 SQL，可以为列名称和表名称指定别名（`Alias`）

表的 SQL Alias 语法：
```sql
SELECT column_name(s)
FROM table_name
AS alias_name
```
列的 SQL Alias 语法：
```
SELECT column_name AS alias_name
FROM table_name
```


## IN 操作符

`IN` 操作符允许我们在 `WHERE` 子句中规定多个值
```sql
SELECT column_name(s)
FROM table_name
WHERE column_name IN (value1,value2,...)
```


## BETWEEN 操作符

操作符 `BETWEEN ... AND` 会选取介于两个值之间的数据范围。这些值可以是数值、文本或者日期
```sql
SELECT column_name(s)
FROM table_name
WHERE column_name
BETWEEN value1 AND value2
```