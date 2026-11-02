-- Index, View, Procedure
CREATE DATABASE session09_db;
USE session09_db;

CREATE TABLE products(
	pro_id INT PRIMARY KEY AUTO_INCREMENT,
    pro_name VARCHAR(100) NOT NULL UNIQUE, 
    pro_price FLOAT,
    pro_created DATE, 
    pro_status BIT DEFAULT(1)
);

CREATE TABLE orders(
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_created DATE,
    order_status BIT DEFAULT(1)
);

CREATE TABLE order_details(
	order_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    product_id INT,
    FOREIGN KEY (product_id) REFERENCES products(pro_id),
	PRIMARY KEY (order_id, product_id), 
    od_quantity INT
);

/* 1. Index 
	- Tang toc do truy van 
    - Giam toc do thao tac du lieu (INSERT, DELETE, UPDATE)
    - Syntax:
    CREATE INDEX [index_name] ON [table_name] (column_name) 
    DROP INDEX [index_name] ON [table_name]
    SHOW INDEX FROM table_name

	2. PROCEDURE (Thu tuc)
    - Syntax: 
    DELIMITER $$
    CREATE PROCEDURE [procedure_name] (IN params datatype, OUT params datatype)
    BEGIN 
		expression
	END $$
    DELIMITER ;
*/

-- Viet procedure de them 100 du lieu mau vao trong bang products
DELIMITER $$
    CREATE PROCEDURE import_data_product ()
    BEGIN 
		DECLARE i INT DEFAULT 1;
		WHILE i < 100 DO
		INSERT INTO products(pro_name , pro_price, pro_created)
		VALUES (
			CONCAT('PRODUCT_', i),
			FLOOR(500 + RAND()*10000),
			DATE_ADD('2026-11-02', INTERVAL FLOOR(RAND()*1000)DAY)
        );
        SET i = i + 1;
        END WHILE;
	END $$
DELIMITER ;

CALL import_data_product();

-- Viet truy van tim ra san pham co gia la 8638 
EXPLAIN FORMAT = TRADITIONAL SELECT * FROM products WHERE pro_price = 8638;

-- Viet truy van tim ra san pham co gia la 8638 su dung index 
-- B1: Tao index 
CREATE INDEX idx_price ON products (pro_price);
-- B2 Truy van 
SHOW INDEX FROM products;
EXPLAIN FORMAT = TRADITIONAL SELECT * FROM products WHERE pro_price = 8638;

-- Xoa INDEX
DROP INDEX idx_price ON products;

-- VIEW 
/*
	1. VIEW: bang ao, khong duoc thay doi du lieu tren view, muon thay doi thi thay doi du lieu tren bang co so
    2. Syntax:
    CREATE VIEW [table_view] AS SELECT STATEMENT 
    DROP VIEW [view_name]
    3. WITH CHECK OPTION: Khi thay doi du lieu tren view thi can thoa man dieu kien 
*/
-- Them du lieu vao bang order_details va bang order 
INSERT INTO orders(order_created, order_status)
VALUES ('2026-11-02', 1),
	   ('2026-11-01', 0);

INSERT INTO order_details(order_id, product_id, od_quantity)
VALUES (1,1,2),
	   (1,2,3),
	   (1,3,1),
	   (2,1,1);

/*
	Order: order_id  order_created  order_status
			 1			2026-11-02      1
             2			2026-11-01		0	
             
    Order_detail: order_id  product_id  od_quantity
					1			1			2 = 3
                    1			2			3
                    1			3			1
                    2			1			1
*/
-- Tao view de xem danh sach cac san pham da mua (product - order_details)
-- B1: Tao view
CREATE OR REPLACE VIEW vw_product_info AS 
-- B2: Truy van den cac cot cua bang products
SELECT p.pro_id, p.pro_name, p.pro_price, od.od_quantity,od.order_id FROM products p
-- B3: JOIN product voi order_details
JOIN order_details od ON p.pro_id = od.product_id;
-- B4: Truy van VIEW
SELECT * FROM vw_product_info;

-- Tao view co dieu kien WITH CHECK OPTION (od_quantity > 1)
CREATE OR REPLACE VIEW vw_product_info_condition AS
SELECT p.pro_id, p.pro_name, p.pro_price, od.od_quantity, od.order_id FROM products p
JOIN order_details od ON p.pro_id = od.product_id
WHERE od.od_quantity > 1
WITH CHECK OPTION;

SELECT * FROM vw_product_info_condition;

-- Update o vw_product_info_condition od_quantity = 1 order_id =1 va product_id =1
UPDATE vw_product_info_condition
SET od_quantity = 3
WHERE order_id = 1 AND pro_id = 1;

SELECT * FROM vw_product_info_condition;

/* 2. PROCEDURE (Thu tuc)
    - Syntax: 
    DELIMITER $$
    CREATE PROCEDURE [procedure_name] (IN params datatype, OUT params datatype)
    BEGIN 
		expression
	END $$
    DELIMITER ;
*/
-- Viet procedure de them 1 san pham  
DELIMITER $$
    CREATE PROCEDURE create_product (
		pro_name_in VARCHAR(100),
		pro_price_in FLOAT,
		pro_created_in DATE
    )
    BEGIN 
		INSERT INTO products(pro_name, pro_price, pro_created)
        VALUES (pro_name_in,pro_price_in,pro_created_in);
	END $$
DELIMITER ;
CALL create_product("Iphone", 10000, '2026-11-01');
-- Viet procedure de lay thong tin theo ma san pham  
DELIMITER $$
    CREATE PROCEDURE find_product_by_id (product_id_in INT)
    BEGIN 
		SELECT * FROM products WHERE pro_id = product_id_in;
	END $$
DELIMITER ;
CALL find_product_by_id(10);

-- Viet procedure de cap nhat thong tin san pham theo ma san pham 
DELIMITER $$
    CREATE PROCEDURE update_product_by_id (
		p_id_in INT, 
		p_name_in VARCHAR(100), 
		p_price_in FLOAT,
        p_created_in DATE
    )
    BEGIN 
		UPDATE products 
        SET pro_name = p_name_in,
        pro_price = p_price_in,
        pro_created = p_created_in
        WHERE pro_id = p_id_in;
	END $$
DELIMITER ;
CALL update_product_by_id(1, "Phuong", 100000, "2026-11-02");
SELECT * FROM products WHERE pro_id = 1;

-- Viet procedure de lay so luong san pham dang co trong kho 
DELIMITER $$
    CREATE PROCEDURE get_count_product ()
    BEGIN 
		SELECT COUNT(*) AS total_count FROM products;
	END $$
DELIMITER ;
CALL get_count_product();
-- Viet procedure de lay tong so san phanm da mua theo don hang = 1

DELIMITER $$
    CREATE PROCEDURE get_total_product_by_order_id (order_id_in INT, OUT total_product INT)
    BEGIN 
		SELECT SUM(od.od_quantity) INTO total_product
        FROM order_details od 
        WHERE od.order_id = 1;
	END $$
DELIMITER ;
CALL get_total_product_by_order_id(1, @total);
SELECT @total AS total_quantity_order_1;
