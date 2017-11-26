# Mysql 基本用法
```sql
-- OX S 下启动／停止／重启mysql
-- sudo /usr/local/mysql/support-files/mysql.server start
-- sudo /usr/local/mysql/support-files/mysql.server stop
-- sudo /usr/local/mysql/support-files/mysql.server restart

-- Linux 下启动／停止／重启mysql
-- service mysql start
-- service mysql stop
-- service mysql restart
-- or
-- /etc/init.d/mysql start
-- /etc/init.d/mysql stop
-- /etc/init.d/mysql restart

-- 连接mysql
-- mysql -u root -p

-- 创建数据库
CREATE DATABASE RUNOOB;

-- 选择数据库
USE RUNOOB;

-- 删除数据库
-- DROP DATABASE RUNOOB;


-- 创建数据表
CREATE TABLE runoob_tbl(
    runoob_id INT NOT NULL AUTO_INCREMENT, -- AUTO_INCREMENT定义列为自增的属性，一般用于主键，数值会自动加1
    runoob_title VARCHAR(100) NOT NULL, -- 如果不想字段为 NULL 可以设置字段的属性为 NOT NULL， 在操作数据库时如果输入该字段的数据为NULL ，就会报错
    runoob_author VARCHAR(10) NOT NULL,
    submission_date DATE,
    PRIMARY KEY (runoob_id) -- PRIMARY KEY关键字用于定义列为主键。 可以使用多列来定义主键，列间以逗号分隔
);


-- 删除数据表
-- DROP TABLE runoob_tbl;

-- 插入数据
-- INSERT INTO table_name ( field1, field2,...fieldN )
--                        VALUES
--                        ( value1, value2,...valueN );
INSERT INTO runoob_tbl
    (runoob_title, runoob_author, submission_date)
    VALUES
    ("LEARN MYSQL", "DBB", NOW());

INSERT INTO runoob_tbl
    (runoob_title, runoob_author, submission_date)
    VALUES
    ("LEARN JAVA", "DBB", NOW());

INSERT INTO runoob_tbl
    (runoob_title, runoob_author, submission_date)
    VALUES
    ("LEARN PYTHON", "DBB", NOW());

-- 数据库描述
-- DESCRIBE table_name
DESCRIBE runoob_tbl;
-- +-----------------+--------------+------+-----+---------+----------------+
-- | Field           | Type         | Null | Key | Default | Extra          |
-- +-----------------+--------------+------+-----+---------+----------------+
-- | runoob_id       | int(11)      | NO   | PRI | NULL    | auto_increment |
-- | runoob_title    | varchar(100) | NO   |     | NULL    |                |
-- | runoob_author   | varchar(10)  | NO   |     | NULL    |                |
-- | submission_date | date         | YES  |     | NULL    |                |
-- +-----------------+--------------+------+-----+---------+----------------+
-- 4 rows in set (0.00 sec)



-- 查询数据
-- SELECT column_name,column_name FROM table_name [WHERE Clause] [OFFSET M ][LIMIT N];
-- 查询 runoob_tbl 所有数据
SELECT * FROM runoob_tbl;
-- +-----------+--------------+---------------+-----------------+
-- | runoob_id | runoob_title | runoob_author | submission_date |
-- +-----------+--------------+---------------+-----------------+
-- |         1 | LEARN MYSQL  | DBB           | 2016-09-27      |
-- |         2 | LEARN JAVA   | DBB           | 2016-09-27      |
-- |         3 | LEARN PYTHON | DBB           | 2016-09-27      |
-- +-----------+--------------+---------------+-----------------+
-- 3 rows in set (0.00 sec)


-- WHERE 子句
-- SELECT field1, field2,...fieldN FROM table_name1, table_name2... [WHERE condition1 [AND [OR]] condition2.....
SELECT * from runoob_tbl WHERE runoob_author="DBB";
SELECT runoob_author FROM runoob_tbl  WHERE runoob_title="LEARN MYSQL";


-- UPDATE 查询
-- UPDATE table_name SET field1=new-value1, field2=new-value2 [WHERE Clause]
UPDATE runoob_tbl SET runoob_title="LEARN MYSQL & PHP" WHERE runoob_id=1;
SELECT * FROM runoob_tbl;
-- +-----------+-------------------+---------------+-----------------+
-- | runoob_id | runoob_title      | runoob_author | submission_date |
-- +-----------+-------------------+---------------+-----------------+
-- |         1 | LEARN MYSQL & PHP | DBB           | 2016-09-27      |
-- |         2 | LEARN JAVA        | DBB           | 2016-09-27      |
-- |         3 | LEARN PYTHON      | DBB           | 2016-09-27      |
-- +-----------+-------------------+---------------+-----------------+
-- 3 rows in set (0.00 sec)


-- DELETE 语句
-- DELETE FROM table_name [WHERE Clause]
INSERT INTO runoob_tbl (runoob_title, runoob_author, submission_date) VALUES ("LEARN SOMETING", "DBB", NOW());
SELECT * FROM runoob_tbl;
DELETE FROM runoob_tbl WHERE runoob_title="LEARN SOMETING";


-- LIKE 子句
-- SELECT field1, field2,...fieldN table_name1, table_name2... WHERE field1 LIKE condition1 [AND [OR]] filed2 = 'somevalue'
SELECT * FROM runoob_tbl WHERE runoob_title LIKE "%JAVA";


-- 排序 ORDER BY 子句
-- SELECT field1, field2,...fieldN table_name1, table_name2... ORDER BY field1, [field2...] [ASC [DESC]]
SELECT * FROM runoob_tbl ORDER BY runoob_id ASC;
-- +-----------+-------------------+---------------+-----------------+
-- | runoob_id | runoob_title      | runoob_author | submission_date |
-- +-----------+-------------------+---------------+-----------------+
-- |         1 | LEARN MYSQL & PHP | DBB           | 2016-09-27      |
-- |         2 | LEARN JAVA        | DBB           | 2016-09-27      |
-- |         3 | LEARN PYTHON      | DBB           | 2016-09-27      |
-- +-----------+-------------------+---------------+-----------------+
-- SELECT * FROM runoob_tbl ORDER BY runoob_id DESC;
-- +-----------+-------------------+---------------+-----------------+
-- | runoob_id | runoob_title      | runoob_author | submission_date |
-- +-----------+-------------------+---------------+-----------------+
-- |         3 | LEARN PYTHON      | DBB           | 2016-09-27      |
-- |         2 | LEARN JAVA        | DBB           | 2016-09-27      |
-- |         1 | LEARN MYSQL & PHP | DBB           | 2016-09-27      |
-- +-----------+-------------------+---------------+-----------------+


-- 分组 GROUP BY 语句
-- SELECT column_name, function(column_name) FROM table_name WHERE column_name operator value GROUP BY column_name;
SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `employee_tbl`
-- ----------------------------
DROP TABLE IF EXISTS `employee_tbl`;
CREATE TABLE `employee_tbl` (
  `id` int(11) NOT NULL,
  `name` char(10) NOT NULL DEFAULT '',
  `date` datetime NOT NULL,
  `signin` tinyint(4) NOT NULL DEFAULT '0' COMMENT '登录次数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Records of `employee_tbl`
-- ----------------------------
BEGIN;
INSERT INTO `employee_tbl` VALUES ('1', '小明', '2016-04-22 15:25:33', '1'), ('2', '小王', '2016-04-20 15:25:47', '3'), ('3', '小丽', '2016-04-19 15:26:02', '2'), ('4', '小王', '2016-04-07 15:26:14', '4'), ('5', '小明', '2016-04-11 15:26:40', '4'), ('6', '小明', '2016-04-04 15:26:54', '2');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;

SELECT * FROM employee_tbl;
-- +----+--------+---------------------+--------+
-- | id | name   | date                | signin |
-- +----+--------+---------------------+--------+
-- |  1 | 小明   | 2016-04-22 15:25:33 |      1 |
-- |  2 | 小王   | 2016-04-20 15:25:47 |      3 |
-- |  3 | 小丽   | 2016-04-19 15:26:02 |      2 |
-- |  4 | 小王   | 2016-04-07 15:26:14 |      4 |
-- |  5 | 小明   | 2016-04-11 15:26:40 |      4 |
-- |  6 | 小明   | 2016-04-04 15:26:54 |      2 |
-- +----+--------+---------------------+--------+
-- 6 rows in set (0.00 sec)

SELECT name, COUNT(*) FROM employee_tbl GROUP BY name;
-- +--------+----------+
-- | name   | COUNT(*) |
-- +--------+----------+
-- | 小丽   |        1 |
-- | 小明   |        3 |
-- | 小王   |        2 |
-- +--------+----------+
-- 3 rows in set (0.00 sec)

SELECT name, SUM(signin) as signin_count FROM  employee_tbl GROUP BY name WITH ROLLUP; -- WITH ROLLUP 可以实现在分组统计数据基础上再进行相同的统计（SUM,AVG,COUNT…）。
-- +--------+--------------+
-- | name   | signin_count |
-- +--------+--------------+
-- | 小丽   |            2 |
-- | 小明   |            7 |
-- | 小王   |            7 |
-- | NULL   |           16 |
-- +--------+--------------+
-- 4 rows in set (0.00 sec)

-- 可以使用 coalesce 来设置一个可以取代 NUll 的名称，coalesce 语法：
-- select coalesce(a,b,c);
SELECT coalesce(name, '总数'), SUM(signin) as signin_count FROM  employee_tbl GROUP BY name WITH ROLLUP;
-- +--------------------------+--------------+
-- | coalesce(name, '总数')   | signin_count |
-- +--------------------------+--------------+
-- | 小丽                     |            2 |
-- | 小明                     |            7 |
-- | 小王                     |            7 |
-- | 总数                     |           16 |
-- +--------------------------+--------------+
-- 4 rows in set (0.00 sec)
```