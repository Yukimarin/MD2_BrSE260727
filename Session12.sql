
CREATE DATABASE IF NOT EXISTS session12_db;
USE session12_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    customer_status ENUM('active', 'inactive', 'locked') DEFAULT 'active'
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    stock_quantity INT NOT NULL DEFAULT 0,
    product_status ENUM('active', 'inactive', 'out_of_stock') DEFAULT 'active'
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    total_amount DECIMAL(15,2) DEFAULT 0.00,
    order_status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    order_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_details (
    detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Luu lich su bien dong so luong trong kho  
CREATE TABLE product_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    old_stock INT,
    new_stock INT,
    log_created DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Dữ liệu mẫu ban đầu cho Products
INSERT INTO products (product_name, price, stock_quantity, product_status) VALUES 
('iPhone 15 Pro', 25000000.00, 10, 'active'),
('MacBook Air M2', 28000000.00, 5, 'active'),
('Tai nghe AirPods 3', 4500000.00, 0, 'out_of_stock');

INSERT INTO customers (customer_name, customer_status) VALUES 
('Nguyễn Văn An (Hợp lệ)', 'active'),    
('Trần Văn Bình (Bị Khóa)', 'locked');    

/* TRIGGER 
- Syntax: 
	DELIMITER$$
		CREATE TRIGGER trigger_name
        [BEFORE-AFTER] [INSERT-UPDATE-DELETE]
        ON table_name
        FOR EACH ROW 
        BEGIN
			expression 
            Co the dung cacs tu khoa NEW (du lieu moi) va OLD (du lieu cu)
        END $$
	DELIMITER;
*/

-- BT1: Kiem tra du lieu dau vao san pham khong am 
-- C1 Dung check 
ALTER TABLE products
ADD CONSTRAINT  check_product_price CHECK (price >= 0);

-- C2: Su dung trigger 
DELIMITER $$
	CREATE TRIGGER tg_before_insert_product_check
    BEFORE INSERT 
    ON products 
    FOR EACH ROW 
    BEGIN 
		IF NEW.price < 0 OR NEW.stock_quantity < 0 THEN 
        SIGNAL SQLSTATE '12345'
        SET MESSAGE_TEXT = "Loi Trigger: Gia va so luong san pham khong duoc nho hon 0";
        END IF;
    END $$
DELIMITER ;

-- Test BT1
INSERT INTO products (product_name, price, stock_quantity, product_status) VALUES 
('Laptop Dell', -25000000.00, 10, 'active')

-- BT1.1 Kiem tra so luong mua khong duoc vuot qua so luong dang co trong kho
-- C1 Khong su dung duoc check 
-- C2 Su dung trigger
DELIMITER $$
	CREATE TRIGGER tg_before_insert_quantity_check
    BEFORE INSERT 
    ON order_details
    FOR EACH ROW 
    BEGIN 
		DECLARE v_stock_quantity INT;
		-- Tra cuu so luong ton kho tu bang product
        SELECT stock_quantity INTO v_stock_quantity
        FROM products
        WHERE product_id = NEW.product_id;
        -- So sanh quantity trong order_detail va stock_quantity trong products
        IF NEW.quantity > v_stock_quantity THEN 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Loi Trigger: So luong mua vuot qua so luong trong kho";
		END IF;
    END $$
DELIMITER ;

-- Test BT1.1 
INSERT INTO order_details (order_id, product_id, quantity, unit_price)
VALUES (1,1,15,25000000.00);

-- BT2 - Chan khach hang khi bi khoa mua hang : customer va order
DELIMITER $$
	CREATE TRIGGER tg_before_insert_order_check_customer
    BEFORE INSERT 
    ON orders
    FOR EACH ROW 
    BEGIN
		DECLARE v_customer_status VARCHAR(20);
		-- Tra cuu so luong ton kho tu bang product
        SELECT customer_status INTO v_customer_status
        FROM customers
        WHERE customer_id = NEW.customer_id;
		
        -- So sanh trang thai customer, neu khoa thi hien thi loi khi mua hang 
		IF v_customer_status = 'locked' THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Loi trigger: Khach hang bi khoa khong the mua hang";
        END IF;
    END $$
DELIMITER ; 

INSERT INTO orders(customer_id,total_amount,order_status,order_date)
VALUES (1, 10,'completed','2026-11-09')
--  BT3: QUY TRINH TU DONG 
-- Khach hang mua 1 san pham - tru di so luong khach hang mua - ghi nhan log khi so luong ton kho trong bang product thay doi 
-- Workflow 
-- Trigger 1: Tu dong tru di so luong ton kho khi khach hang mua hang (product id 1 co 10 sp - khach hang mua sp 1 5 sp con 5 trong product)
DELIMITER $$
	CREATE TRIGGER tg_after_insert_order_details
    AFTER INSERT
    ON order_details
    FOR EACH ROW 
    BEGIN
		-- Cap nhat lai so luong trong product
        UPDATE products
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END $$
DELIMITER ;
-- Trigger 2: Tu dong ghi nhan log khi so luong ton kho trong bang product thay doi 
DELIMITER $$
	CREATE TRIGGER tg_after_update_product_stock_quantity
    AFTER UPDATE 
    ON products
    FOR EACH ROW
	IF OLD.stock_quantity <> NEW.stock_quantity THEN
    -- Them du lieu vao trong bang product_log
	INSERT INTO product_log (product_id,old_stock,new_stock,log_created)
    VALUES(NEW.product_id, OLD.stock_quantity, NEW.stock_quantity, CURRENT_DATE());
    END IF;
    END $$
DELIMITER ; 


INSERT INTO order_details (order_id, product_id, quantity, unit_price)
VALUES (1,1,4,25000000.00);





