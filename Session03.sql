
/* 
-- 1.Cac khai niem can luu y 
	- Thuc the (Entity): Student, Book, class, employee, product,...
	- Thuoc tinh: ma sinh vien, ten sinh vien, lop, so dien thoai, email,...
	- Moi quan he: 1-1, 1-N, N-N
Vd: San pham vs Khach hang (N-N), San pham va hoa don (N-N), San pham va hoa don chi tiet 
Book va Doc gia (N-N) => bang trung gian borrow_book 
	- Khai niem bang: Table (Thuc the), Cot (Thuoc tinh), Dong (ban ghi)
	- Khoa chinh (Primary Key): Duy nhat va khong null (Unique va not null) 
	- Khoa ngoai (Foreign Key): 


-- 2. ERM (Entity Relationship  Model)
	- VD: Muon xay mot ngoi nha 
	- Thiet ke truu tuong (Chi chua cac khai niem hoac quan he cac thuc the)
	- Thiet ke vat ly (Cac khai niem se duoc cung cap day du thong tin)
	- Thiet ke logic (Cac khai niem se duoc cung cap them cac thong tin chi tiet)
    
-- 3 ERD (Entity Relationship Diagram)
	VD Quan ly cua hang cafe   |  Quan ly truong dai hoc
    De thiet ke ERD 6 buoc
    Buoc 1: Xac dinh muc tieu va pham vi 
    VD1: Quan ly doanh thu - don hang, nhan vien, san pham, ...
    VD2: Quan ly chat luong sinh vien - sinh vien, giao vien, mon hoc, diem so,....
    Buoc 2: Thu thap thong tin (Quan ly van de gi cua thuc the)
	VD1: Don hang - quan ly so luong, quan ly san pham o cac don hang, 	quan ly gia tri 1 don hang,...
    VD2: Sinh vien - Diem so, Chuyen can, ty le pass mon, ....
    Buoc 3: Liet ke cac thuoc tinh va sap xep thong tin 
	VD1: Don hang: Ma don hang, Ten san pham, Tien, Trang thai don hang 
    VD2: Sinh vien: ma sinh vien , ten sinh vien , so dien thoai ,....
    Buoc 4: Moi quan he cac thuc the (1-1/1-N/N-N) 
    VD1: Nhan vien va San pham (N-N), San pham va Hoa don(N-N), Khach hang va hoa don(1-N), Danh muc va san pham (1-N)
    VD2: Sinh vien va Mon hoc (N-N) , Sinh vien va Lop hoc(1-N), Giang vien va mon hoc(N-N), Sinh vien va giang vien (N-N)
    Buoc 5: Chuan hoa co so du lieu (1NF, 2NF, 3NF, BCNF - ACID)
	- Tranh du thua du lieu 
    - Dam bao tinh nhat quan du lieu 
    - Chuan hoa 1 NF: moi bang phai co 1 khoa chinh (Primary key)
    Buoc 6: Ap dung cac rang buoc neu co
    - VD1: nhan vien - ten nhan vien varchar(255) not null
    - VD2: Mon hoc - ten mon hoc, so luong buoi hoc not null,...
*/

-- Co so du lieu 
/* 1 Tao moi co so du lieu 
 Syntax: CREATE DATABASE database_name 
 2. Xoa co so du lieu 
 Syntax: DROP DATABASE database_name
 3. Su dung co so du lieu 
 USE database_name
*/
CREATE DATABASE brse260727;
USE brse260727;
-- DROP DATABASE brse260727

/* 2. Sau khi tao CSDL thi se tao bang va cac thao tac lam viec voi bang 
- Tao bang 
Syntax: CREATE TABLE table_name(
	column_name_1 datatype constraint 
    column_name_2 datatype constraint 
)
- Xoa bang 
Syntax: DROP TABLE table_name

- Sua bang 
Syntax: ALTER TABLE table_name 
			ADD COLUMN column_name_n datatype constraint
            DROP COLUMNN column_name 
            RENAME column_name  to new_column_name
            ALTER CONSTRAINTS
            MODIFY
*/

/*
	Tao bang Category, Product, Order
*/
CREATE TABLE categories (
	category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    category_status BIT DEFAULT(0)
);

-- Category quan he 1-N Product (vet chan chim o bang product)
-- De the hien moi quan he 1-N tren CSDL thi khoa ngoai cua bang product se tham chieu den khoa chinh cua bang category
DROP TABLE products;
CREATE TABLE products (
	product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL UNIQUE,
	product_price DECIMAL(10,2) NOT NULL CHECK (product_price > 0),
    product_quantity INT NOT NULL CHECK (product_quantity > 0),
    categories_id INT,
    FOREIGN KEY (categories_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_total_amount DECIMAL(10,2) NOT NULL CHECK (order_total_amount >= 0),
    order_created date
);

-- order va product la moi quan N-N 
-- Moi quan he nhieu nhieu khong bieu dien noi truc tiep 2 thuc the voi nhau 
-- Can tao bang trung gian bien moi quan N-N thanh 2 moi quan 1-N 
-- Composite Key (Khoa tong hop) 
/* VD: Order
Order id       Product       Create_At   	Total_Amount 
1	           Iphone 18      19/10     	   15tr 
1               Airpod 	      19/10			   5tr	 (chua co order_detail)
2


Order_detail 
order_detail_id     Order_id       Customer_id(bo qua)		Product_id			Quantity(so luong mua)  	   Price 			Subtotal
1						1			1(Loan)					Iphone 18               2							5tr					10tr
2						1			1(Loan) 				Airpod 					2							2.5tr				5tr

*/
DROP TABLE order_detail;
CREATE TABLE order_detail (
	order_id INT,
    FOREIGN KEY (order_id) REFERENCES orders (order_id),
    product_id INT, 
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    PRIMARY KEY (order_id,product_id),
    order_detail_quantity INT NOT NULL, 
    order_subtotal FLOAT
);

