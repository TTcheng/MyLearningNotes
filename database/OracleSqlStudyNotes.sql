-- 1、Oracle数据类型
-- Char Varchar2 Number(x,y) Date Clob Blob Long

-- 2、DDL
-- 创建表
-- create table all
CREATE TABLE EMPS(
  ID NUMERIC(10,0) NOT NULL
    primary key,
  NAME varchar2(30) NOT NULL ,
  GENDER char DEFAULT 'F'
);
-- create table with name and compete later
CREATE TABLE "EMPS";
ALTER TABLE "EMPS" ADD "ID" NUMERIC(10) PRIMARY KEY ;-- 添加字段
ALTER TABLE "EMPS" ADD "NAME" VARCHAR2(15) NOT NULL ;
ALTER TABLE "EMPS" ADD "GENDER" CHAR DEFAULT NULL ;
-- ALTER table
ALTER TABLE "EMPS" RENAME COLUMN "NAME" TO "LASTNAME";-- 更改字段名
ALTER TABLE "EMPS" SET UNUSED COLUMN "GENDER";-- 删除字段
ALTER TABLE "EMPS" MODIFY "NAME" VARCHAR2(15);-- 更改字段类型
ALTER TABLE "EMPS" MODIFY "NAME" UNIQUE NOT NULL ;-- 非空唯一约束
ALTER TABLE "EMPS" ADD CONSTRAINT "p_key" PRIMARY KEY (ID);-- 主键约束
ALTER TABLE "EMPS" ADD CONSTRAINT "f_key" FOREIGN KEY ("ID","NAME") REFERENCES "TEST"("ID","NAME");-- 外键约束
RENAME "EMPS" TO "EMPLOYEES";-- 表重命名
DROP TABLE "EMPS";-- 删除表

-- 3、DML
-- Select *|列名|表达式 from 表名 where 条件 order by 列名|group by
SELECT * FROM "EMPS" WHERE "ID" > 1 order by "EMPS"."ID" desc;
-- INSERT INTO table_name field_names... VALUES values..
INSERT INTO "EMPS" ("ID", "NAME","GENDER") VALUES ('5','Jesse','M');
-- UPDATE table_name SET column1=value1,column2=value2,...WHERE some_column=some_value;
UPDATE table_name SET "field_name" = 'value' WHERE "field_name" = 'value';
-- Delete From 表名 where 条件;(删除可恢复) TRUNCATE TABLE table_name;(删除不可恢复,删除速度很快)
DELETE FROM TEST_WCC_PERSON where GENDER is null ;

-- 4、操作符
-- 算术运算符+、-、*、/、=、>、<、<> !=、>=、<=
-- 路基运算符and 、or 、in 、not in
-- 字符串连接 ||
SELECT ("NAME"||'的性别是'||"GENDER") FROM TEST_WCC_PERSON;

-- 5、常用函数
-- 数值函数
 SELECTabs(-13) FROM dual;-- 绝对值
SELECT * FROM TEST_WCC_PERSON WHERE ID>MOD(3,2);-- 取余
SELECT power(3,2) FROM dual;-- 平方
SELECT floor(3.1415926) FROM dual;-- 向下取整
SELECT ceil(3.1415926) FROM dual;-- 向上取整
SELECT round(3.1415926,3) FROM dual;-- 四舍五入到指定位数，默认为0
SELECT trunc(3.1415926,5) FROM dual;-- 截断小数点后第n位后面的数字，默认为0
SELECT sign(11.5) FROM dual;-- 正1负-1零0
-- 字符函数
SELECT initcap('hello') FROM dual;-- 首字母大写
SELECT lower('HELLO') FROM dual;-- 转化为小写
SELECT upper('hello') FROM dual;-- 转化为大写
SELECT concat('a','bb') FROM dual;-- 字符串连接
SELECT ltrim('====hello==','=') FROM dual;-- 删除左边的指定字符
SELECT rtrim('====hello==','=') FROM dual;-- 删除右边的指定字符
SELECT rpad('Hello',10,'+=') FROM dual;-- 在给定字符串右侧用给定字符填充到指定长度
SELECT lpad('Hello',7,'=') FROM dual;-- 左侧填充
SELECT NAME,replace(NAME,'abc','aaa'),substr(NAME,3,5) FROM TEST;-- 替换指定内容
SELECT NAME,substr(NAME,1,2) FROM TEST_WCC_PERSON;-- 获取给定区间子串
SELECT length('fasdfasdf') FROM dual;-- 获取字符串的长度
SELECT instr('abcabcabcabc','abc',2,2) FROM dual;-- instr(s1,s2,m,n)返回 s1从第m字符开始s2第n次出现的位置，m及n的缺省值为 1
-- 转换函数
SELECT NAME,GENDER,nvl(GENDER,'M') FROM TEST_WCC_PERSON;-- 空值填充
SELECT to_number('123.5')+to_number('1123') FROM dual;
SELECT to_char(ID) FROM TEST_WCC_PERSON;
SELECT to_char(sysdate,'YYYY-MM-DD HH24:MI;SS') FROM dual;-- 日期转字符串
SELECT to_char(123.26,'L099,9999.99') FROM dual;-- 数值格式化(包含货币格式)
-- 分组函数 groupFunc(ALL/DISTINCT FIELD)
SELECT count(ALL ID) FROM TEST_WCC_PERSON;-- 计数
SELECT avg(ID) FROM TEST_WCC_PERSON;-- 均值
SELECT stddev(DISTINCT ID) FROM TEST_WCC_PERSON;-- 标准差
SELECT variance(ID) FROM TEST_WCC_PERSON;-- 方差
SELECT max(ID) FROM TEST_WCC_PERSON;-- 最大值
SELECT min(ID) FROM TEST_WCC_PERSON;-- 最小值
SELECT sum(All ID) FROM TEST_WCC_PERSON;-- 求和
-- 日期函数
SELECT sysdate FROM dual;-- 系统日期和时间
SELECT last_day(sysdate) FROM dual;-- 给定日期当月的最后一天
SELECT next_day(sysdate,6) FROM dual;-- 给定日期的下个星期几
SELECT add_months(sysdate,-2) from dual;-- 日期加n个月
SELECT months_between(sysdate,add_months(sysdate,2)) from dual;-- 日期 d 与 e 之间的月份数，e 先于 d
SELECT new_time(sysdate,'07:45;36','GMT+1') FROM dual;-- ??????
SELECT greatest(sysdate,add_months(sysdate,2),next_day(sysdate,3)) FROM dual;-- 给定日期列表中最晚的日期
SELECT least(sysdate,add_months(sysdate,2),next_day(sysdate,3)) FROM dual;-- 给定日期列表中最早的日期
SELECT to_char(sysdate,'YYYY-MM-DD HH24:MI;SS') FROM dual;-- 标准日期转指定格式字符串
SELECT to_date('2015 04 01 01:15:01','yyyy mm dd HH12:MI:SS')FROM dual;-- 给出格式的字符串转标准日期
SELECT round(sysdate,'year')FROM dual;-- 日期四舍五入
SELECT trunc(sysdate,'DD')FROM dual;-- 日期截断

-- 6、其他常用语句
-- (1)集合操作 并：UNION UNION ALL 交：INTERSECT 差：MINUS
-- 交并差要求嵌套查询属性具有相同的定义（包括类型和取值范围）
SELECT * FROM TEST_WCC_PERSON WHERE "NAME" = 'Jesse' UNION SELECT * FROM TEST_WCC_PERSON WHERE "GENDER" = 'F';-- UNION
SELECT * FROM TEST_WCC_PERSON WHERE "NAME" = 'Jesse' UNION ALL SELECT * FROM TEST_WCC_PERSON WHERE "GENDER" = 'F';-- UNION ALL效率比UNION高
SELECT * FROM TEST_WCC_PERSON WHERE "ID" > 0 INTERSECT SELECT * FROM TEST_WCC_PERSON WHERE "GENDER" = 'M';-- UNION
SELECT * FROM TEST_WCC_PERSON WHERE "ID" > 0 MINUS SELECT * FROM TEST_WCC_PERSON WHERE "GENDER" = 'M';-- UNION

-- (2)是否存在exists  not exists
SELECT "lastname","title" FROM "s_emp" e WHERE exists(SELECT 'x' --把查询结果定为constant提高效率
                                                      FROM "s_dept" s WHERE s.id=e.dept_id AND s."NAME"='Sales');
-- 等价于
SELECT last_name, title FROM s_emp WHERE dept_id IN (SELECT "id" FROM s_dept WHERE "name"='Sales');
-- (3)with子句，重用查询 with a as (clause),b as (clause) ...clause
WITH a AS (SELECT "id" FROM s_dept WHERE "name"='Sales' ORDER BY  "id")
SELECT last_name,title FROM s_emp WHERE dept_id IN (SELECT * FROM a);--使用 select 查询别名
-- (4)decode函数 类似IF-ELSE
SELECT "NAME","GENDER",decode("GENDER",'F','女','M','男','未知') AS "性别" FROM "TEST_WCC_PERSON";
-- (5)CASE-END 等价于上面的decode的语句
SELECT "NAME","GENDER",(CASE "GENDER"
                        WHEN 'F' THEN '女'
                        WHEN 'M' THEN '男'
                        ELSE '未知' END )
AS "性别" FROM "TEST_WCC_PERSON";
-- (6)rownum --top-N
SELECT * FROM TEST_WCC_PERSON WHERE rownum <= 2;
-- (7)row_number
SELECT "ID","NAME","DATE1",row_number() OVER(partition by ID order by DATE1 desc) as RN FROM T1;

-- 其他
-- 查询最新几条
SELECT * FROM TEST_WCC_PERSON WHERE ROWNUM<100;
-- 多行录入
INSERT INTO TEST_WCC_PERSON("ID","NAME","GENDER") (SELECT "ID"-5,"NAME","GENDER" FROM TEST_WCC_PERSON WHERE "ID">10);
-- 表复制
CREATE TABLE "TEST_WCC_PERSON_TEMP" AS (SELECT * FROM TEST_WCC_PERSON);
SELECT * FROM TEST_WCC_PERSON_TEMP;
