--  GROUP BY, HAVING, Subquery 
-- Nhom cau lenh DDL (Data Definition Languague): CREATE, DROP , ALTER
-- Nhom cau lenh DML (Data Manipulation Languague):  SELECT, INSERT INTO,...
-- 1. Tao CSDL 
CREATE DATABASE IF NOT EXISTS session06_db; 
USE session06_db;
-- 2. Tao 2 thuc the category va product 
-- Cate vs Product la quan he 1-N 
CREATE TABLE IF NOT EXISTS categories (
	category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE, 
	category_status BIT DEFAULT(1)
);

CREATE TABLE IF NOT EXISTS products(
	product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    product_price DECIMAL(10,2) CHECK (product_price >0),
    product_status BIT DEFAULT(1)
);

ALTER TABLE products
	ADD COLUMN category_id INT;
ALTER TABLE products
	ADD FOREIGN KEY (category_id) REFERENCES categories (category_id);
    
-- 3. Them du lieu voi INSERT INTO
/* Syntax: 
	C1: INSERT INTO [table_name](cl1, cl2,...)
    VALUES (vl1, vl2,...)=> Recommend
    C2: INSERT INTO [table_name]
    VALUES (vl1, vl2, ...)=> sai lech cot, sai lech kieu du lieu => loi 
    C3: INSERT INTO [table_name] (cl1, cl2,...)
    VALUE (vl1, vl2,...) => Khong su dung 
*/
-- Them du lieu category va product
INSERT INTO categories(category_name, category_status)
VALUES ('FOOD', 1),
	   ('DRINK',1),
       ('KITCHEN WARE', 0);
       
INSERT INTO products(product_name, product_price, product_status,category_id)
VALUES ('APPLE', 5000 , 1 , 1),
	   ('CHOCOPIE', 10000 , 1 , 1),
       ('COCA COLA', 15000 , 1, 2);
       
-- 4. UPDATE va DELETE 
/* Syntax:
	UPDATE table_name SET column_name
    DELETE FROM table_name WHERE condition 
*/

-- Chuyen product_status cua APPLE ve 0 
-- Tat che do safemode 
SET SQL_SAFE_UPDATES = 0;
UPDATE products SET product_status = 0 WHERE product_name= 'APPLE';
-- Bat lai che do safemode 
SET SQL_SAFE_UPDATES = 1;

-- Xoa APple ra khoi product
DELETE FROM products WHERE product_id = 1;

-- 5. Viet cau lenh truy van 
-- SELECT 
/* Syntax:
	SELECT cl1, cl2,... FROM table_name: truy van theo cot 
    SELECT * FROM table_name: truy van tat ca cac cot 
*/
-- Lay tat ca thong tin cua bang category 
SELECT * FROM categories;
-- ALIAS: bi danh 
SELECT c.category_id, c.category_name, c.category_status FROM categories AS c;

-- 6. Truy van nang cao 
-- AGGREGATE FUNCTION (COUNT,SUM,MIN,MAX, AVG)
/*Syntax:
	SELECT COUNT(*) FROM table_name
    SELECT COUNT(cl1,cl2,...) FROM table_name
    SELECT SUM(cl1) FROM table_name
    SELECT AVG(cl1) FROM table_name
*/
-- Tinh tong gia tien cac san pham dang co trong product va tinh gia tri trung binh 
SELECT SUM(product_price) FROM products;
SELECT AVG(product_price) FROM products;

-- 9. JOIN 
-- JOIN, LEFT JOIN, INNER JOIN, RIGHT JOIN, OUTER JOIN, CROSS JOIN (UNION va UNION ALL)
/*Syntax:
	SELECT * FROM table 1 JOIN table 2 ON (condition) table1.cl1 = table2.cl2 
*/
-- Su dung LEFT JOIN 
SELECT * FROM categories LEFT JOIN products ON categories.category_id = products.category_id;
-- Su dung RIGHT JOIN 
SELECT * FROM categories RIGHT JOIN products ON categories.category_id = products.category_id;
-- Su dung INNER JOIN 
SELECT * FROM categories INNER JOIN products ON categories.category_id = products.category_id;

-- Co bang khach hang va bang don hang. Su dung Inner join va left join ket qua tra ra la gi?

-- 11. BETWEEN va IN 
SELECT * FROM products WHERE product_price BETWEEN 5000 AND 15000; 
SELECT * FROM products WHERE product_price IN(5000,15000,1000);

-- 12. LIKE (=)
/*
	Like dung de so sanh tim kiem chuoi ky tu 
    %A: tim chuoi ket thuc bang chu A
    A%: tim chuoi bat dau bang chu A 
    %A%: tim chuoi chua ky tu A o vi tri bat ky 
    _ _A%: (2 gach lien) tim chuoi co ky tu thu 3 la A
*/
SELECT * FROM products WHERE product_name ='CHOCOPIE';
SELECT * FROM products WHERE product_name LIKE '__A%';

-- 13. ASC, DESC, LIMIT (gioi han lay bao nhieu), OFFSET (bo qua bao nhieu)
-- Lay thong tin san pham voi gia san pham tang dan 
SELECT * FROM products 
ORDER BY product_price; 

-- Lay thong tin san pham voi gia san pham giam dan 
SELECT * FROM products 
ORDER BY product_price DESC; 

-- Lay thong tin 2 san pham voi gia san pham cao nhat 
SELECT * FROM products 
ORDER BY product_price DESC LIMIT 2;

-- Lay thong tin 2 san pham voi voi gia gan lon nhat 
SELECT * FROM products 
ORDER BY product_price DESC LIMIT 3 OFFSET 2;

-- 1 trang co 10 ban ghi, muon hien thi trang thu 2 thi LIMIT 10 OFFSET 10

-- 10. Thu tu thuc thi (SELECT, FROM , WHERE, GROUP BY, HAVING)
-- Khi SQL thuc thi FROM (thuc thi o bang nao) - WHERE (condition) - GROUP BY (gom nhom) - HAVING(loc cac nhom sau khi gom nhom) - SELECT 

-- Thong ke gia trung binh theo tung danh muc 
-- tinh gia trung binh SELECT AVG(cl1) FROM table_name
-- gom danh muc GROUP BY (gom nhom)
SELECT category_id, AVG(product_price) FROM products  GROUP BY category_id;

-- Thong ke cac danh muc co tong tien lon hon 10000
-- Tong tien SELECT SUM(cl1) FROM table_name
-- gom danh muc GROUP BY 
-- So sanh lon 10000 => Loc du lieu lon hon 10000
SELECT category_id, SUM(product_price) FROM products GROUP BY category_id HAVING SUM(product_price) >25000;

-- 14. Subquery - (CTE - Common Table Expression)
-- Lay ra cac san pham co gia tri lon hon hoac bang gia tri trung binh cua cac san pham 
-- 1 Tinh gia tri trung binh cac san pham 
-- SELECT AVG(product_price) FROM products = 11000  = A
-- 2. Lay ra thong tin cac san pham so sanh voi gia tri trung binh da tinh la A 
SELECT * FROM products WHERE product_price >= (SELECT AVG(product_price) AS "AVG_PRICE" FROM products)
-- SELECT * FROM products p WHERE p.product_price >= (SELECT AVG(p.product_price) AS "AVG_PRICE" FROM products p)








