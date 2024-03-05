DROP DATABASE RestaurantDB

CREATE DATABASE RestaurantDB

USE RestaurantDB

CREATE TABLE Restaurant (
	RestaurantId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	Town NVARCHAR(30) NOT NULL,
	Street NVARCHAR(50) NOT NULL,
	House NVARCHAR(10) NOT NULL,
	GeneralPhone NVARCHAR(12) CHECK (LEN(GeneralPhone) = 11) NOT NULL,
	ReservationPhone NVARCHAR(12) CHECK (LEN(ReservationPhone) = 11) NOT NULL,
	OrderPhone NVARCHAR(12) CHECK (LEN(OrderPhone) = 11) NOT NULL
)

INSERT INTO Restaurant (Name, Town, Street, House, GeneralPhone, ReservationPhone, OrderPhone)
VALUES ('�������� ���������', '�����', '�����', '���', '11122223344', '55566667777', '99988887777');

CREATE TABLE Positions (
	PositionId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(30) NOT NULL,
	Descr NVARCHAR(100) NULL,
	Salary INT NULL
)

CREATE TABLE OrderDiscounts (
	OrderDiscountId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	RequiredNumberOrders NVARCHAR(3) NOT NULL,
	Percentage INT NOT NULL
)

CREATE TABLE Employees (
	EmployeeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(30) NOT NULL,
	Surname NVARCHAR(30) NOT NULL,
	Patronymic NVARCHAR(30) NULL,
	Gender NCHAR(3) NOT NULL CHECK (Gender IN ('���', '���')),
	Phone NVARCHAR(12) NOT NULL UNIQUE CHECK (LEN(Phone) = 11),
	Email NVARCHAR(60) NULL UNIQUE CHECK (Email LIKE '%_@__%.__%'),
	DateHire DATE NOT NULL,
	DateTermination DATE NULL,
	Position INT NOT NULL,
	CONSTRAINT CHK_DateHire CHECK (DateHire > '2000-01-01'),
	CONSTRAINT CHK_DateTermination CHECK (DateTermination IS NULL OR DateTermination > DateHire),
	CONSTRAINT FK_Position FOREIGN KEY (Position) REFERENCES Positions(PositionId)
)

CREATE TABLE EmployeesUsers(
	EmployeeId INT NOT NULL,
	UserId INT NOT NULL,
	CONSTRAINT FK_EmplUser FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
)

CREATE TABLE Clients (
	Username NVARCHAR(20) NOT NULL PRIMARY KEY, 
	Name NVARCHAR(30) NOT NULL,
	Surname NVARCHAR(30) NOT NULL,
	Patronymic NVARCHAR(30) NULL,
	Gender NCHAR(3) NOT NULL CHECK (Gender IN ('���', '���')),
	Phone NVARCHAR(12) NOT NULL UNIQUE CHECK (LEN(Phone) = 11),
	Email NVARCHAR(60) NULL UNIQUE CHECK (Email LIKE '%_@__%.__%'),
	Password NVARCHAR(20) NOT NULL,
	DateLastLogin DATETIME NULL,
	NumberOrders INT DEFAULT 0 NOT NULL,
	OrderDiscount INT NOT NULL,
	CONSTRAINT FK_OrderDiscount FOREIGN KEY (OrderDiscount) REFERENCES OrderDiscounts(OrderDiscountId)
)

CREATE TABLE Tabless (
	TableNumber INT NOT NULL PRIMARY KEY,
	Descr NVARCHAR(100) NULL,
	NumberSeats INT NOT NULL CHECK (NumberSeats > 0 AND NumberSeats < 13),
	Availability BIT NOT NULL DEFAULT 1,
	RestaurantId INT NOT NULL DEFAULT 1,
	CONSTRAINT FK_RestaurantIdTabless FOREIGN KEY (RestaurantId) REFERENCES Restaurant(RestaurantId)
)

CREATE TABLE WaitersTables (
	WaiterId INT NOT NULL,
	TableNumber INT NOT NULL,
	CONSTRAINT FK_WaiterId FOREIGN KEY (WaiterId) REFERENCES Employees(EmployeeId),
	CONSTRAINT FK_TableNumberr FOREIGN KEY (TableNumber) REFERENCES Tabless(TableNumber)
)

CREATE TABLE Reservations (
	ReservationId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	DateTimeStart DATETIME NOT NULL CHECK (DateTimeStart >= '2000-01-01'),
	NameClient NVARCHAR(30) NOT NULL,
	PhoneClient NVARCHAR(12) NOT NULL CHECK (LEN(PhoneClient) = 11),
	Comment NVARCHAR(100) NULL,
	NumberGuests INT NOT NULL CHECK (NumberGuests > 0 AND NumberGuests < 13),
	Status NVARCHAR(20) NOT NULL CHECK (Status IN ('������������', '��������������', '��������')),
	TableNumber INT NULL,
	BookingOperator INT NOT NULL,
	CONSTRAINT FK_TableNumbe FOREIGN KEY (TableNumber) REFERENCES Tabless(TableNumber),
	CONSTRAINT FK_BookingOperator FOREIGN KEY (BookingOperator) REFERENCES Employees(EmployeeId)
)


CREATE TABLE Units(
	UnitName NVARCHAR(15) NOT NULL PRIMARY KEY
)


CREATE TABLE MenuSections (
	MenuSectionId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(100) NOT NULL,
	Descr NVARCHAR(400) NULL
)

CREATE TABLE MenuPositions(
	MenuPositionId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(100) NOT NULL,
	Descr NVARCHAR(400) NULL,
	Availability BIT NOT NULL DEFAULT 1,
	DateEnteredInMenu DATE NOT NULL DEFAULT GETDATE(),
	Price INT NOT NULL,
	Portion INT NOT NULL,
	PortionUnit NVARCHAR(15) NOT NULL,
	MenuSection INT NOT NULL,
	CONSTRAINT FK_QuantityUnit FOREIGN KEY (PortionUnit) REFERENCES Units(UnitName),
	CONSTRAINT FK_MenuSection FOREIGN KEY (MenuSection) REFERENCES MenuSections(MenuSectionID)
)


CREATE TABLE DeliveryCosts (
	DeliveryCostId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Distance NVARCHAR(15) NOT NULL,
	Cost INT NOT NULL CHECK (Cost >= 0)
)

CREATE TABLE TakeawayOrders (
	TakeawayOrderId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	NameClient NVARCHAR(30) NOT NULL,
	PhoneClient NVARCHAR(12) NOT NULL CHECK (LEN(PhoneClient) = 11),
	Username NVARCHAR(20) NULL DEFAULT NULL,
	Requirements NVARCHAR(100) NULL,
	Cost INT NOT NULL DEFAULT 0 CHECK (Cost >= 0),
	DiscountedCost INT NOT NULL DEFAULT 0 CHECK (DiscountedCost >= 0),
	PaymentMethod NVARCHAR(20) NOT NULL CHECK (PaymentMethod IN ('����������� ������', '�������� ������')),
	DateOrder DATETIME NOT NULL DEFAULT GETDATE() CHECK (DateOrder > '2000-01-01'),
	DateReceipt DATETIME NOT NULL,
	Status NVARCHAR(20) NOT NULL CHECK (Status IN ('������������', '��������������', '��������')),
	ReceiptOption NVARCHAR(10) NOT NULL CHECK (ReceiptOption IN ('��������', '���������')),
	DeliveryAddress NVARCHAR(50) NULL,
	DeliveryCost INT NULL,
	Courier INT NULL,
	CONSTRAINT CHK_DateReceipt CHECK(DateReceipt > DateOrder),
	CONSTRAINT FK_Courier FOREIGN KEY (Courier) REFERENCES Employees(EmployeeId),
	CONSTRAINT FK_Username FOREIGN KEY (Username) REFERENCES Clients(Username),
	CONSTRAINT FK_DeliveryCost FOREIGN KEY(DeliveryCost) REFERENCES DeliveryCosts(DeliveryCostId)
)

CREATE TABLE RestaurantOrders (
	RestaurantOrderId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	DateTimeReception DATETIME NOT NULL DEFAULT GETDATE() CHECK (DateTimeReception > '2000-01-01'),
	DateTimeServingDishes DATETIME NULL,
	Cost INT NOT NULL DEFAULT 0 CHECK (Cost >= 0),
	PaymentMethod NVARCHAR(20) NOT NULL CHECK (PaymentMethod IN ('����������� ������', '�������� ������')),
	TableNumber INT NOT NULL,
	Waiter INT NOT NULL,
	CONSTRAINT CHK_DateTimeServingDishes CHECK (DateTimeServingDishes > DateTimeReception),
	CONSTRAINT FK_Waiter FOREIGN KEY (Waiter) REFERENCES Employees(EmployeeId),
	CONSTRAINT FK_TableNumberrr FOREIGN KEY (TableNumber) REFERENCES Tabless(TableNumber),
)

--INSERT INTO RestaurantOrders (DateTimeReception, Cost, PaymentMethod, TableNumber, Waiter) VALUES
--('2023-05-12T14:15:00', 800, '�������� ������', 1, 5)

CREATE TABLE CompositionOfRestaurantOrder (
	MenuPositionId INT NOT NULL,
	Quantity INT NOT NULL CHECK (Quantity > 0),
	TotalPrice INT NOT NULL DEFAULT 0,
	RestaurantOrderId INT NOT NULL,
	CONSTRAINT FK_MenuPositonId FOREIGN KEY (MenuPositionId) REFERENCES MenuPositions(MenuPositionId),
	CONSTRAINT FK_RestaurantOrderId FOREIGN KEY (RestaurantOrderId) REFERENCES RestaurantOrders(RestaurantOrderId)
)

CREATE TABLE CompositionTakeawayOrder (
	MenuPositionId INT NOT NULL,
	Quantity INT NOT NULL CHECK (Quantity > 0),
	TotalPrice INT NOT NULL DEFAULT 0,
	TakeawayOrderId INT NOT NULL,
	CONSTRAINT FK_MenuPositionI FOREIGN KEY (MenuPositionId) REFERENCES MenuPositions(MenuPositionId),
	CONSTRAINT FK_TakeawayOrderId FOREIGN KEY (TakeawayOrderId) REFERENCES TakeawayOrders(TakeawayOrderId)
)


CREATE TABLE Ingredients (
	IngredientId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(40) NOT NULL,
	Descr NVARCHAR(100) NULL,
	TotalQuantity INT NOT NULL CHECK (TotalQuantity > 0),
	TotalQuantityUnit NVARCHAR(15) NOT NULL,
	CONSTRAINT FK_TotalQuantityUnit FOREIGN KEY (TotalQuantityUnit) REFERENCES Units(UnitName),
)

CREATE TABLE CompositionOfMenuPosition (
	MenuPositionId INT NOT NULL,
	IngredientId INT NOT NULL,
	Quantity INT NOT NULL,
	CONSTRAINT FK_MnuPositionId FOREIGN KEY (MenuPositionId) REFERENCES MenuPositions(MenuPositionId),
	CONSTRAINT FK_IngredientId FOREIGN KEY (IngredientId) REFERENCES Ingredients(IngredientId),
)

CREATE TABLE Suppliers (
	SupplierId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Organization NVARCHAR(50) NOT NULL,
	ContactPerson NVARCHAR(30) NOT NULL,
	Address NVARCHAR(50) NOT NULL,
	Phone NVARCHAR(12) NOT NULL CHECK (LEN(Phone) = 11),
	Email NVARCHAR(60) NOT NULL UNIQUE CHECK (Email LIKE '%_@__%.__%'),
)

CREATE TABLE Supplies (
	SupplyId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	DateSupply DATE NOT NULL CHECK (DateSupply > '2000-01-01'),
	CostSupply INT NOT NULL,
	Supplier INT NOT NULL,
	CONSTRAINT FK_Supplier FOREIGN KEY (Supplier) REFERENCES Suppliers(SupplierId)
)

CREATE TABLE SupplyRange (
	SupplyId INT NOT NULL,
	IngredientId INT NOT NULL,
	SupplyScope INT NOT NULL,
	SupplyScopeCost INT NOT NULL,
	CONSTRAINT FK_SupplyId FOREIGN KEY (SupplyId) REFERENCES Supplies(SupplyId),
	CONSTRAINT FK_IngredentId FOREIGN KEY (IngredientId) REFERENCES Ingredients(IngredientId)
)

--���������� ������� � �������

--������� ���������
INSERT INTO Units VALUES('����'), ('����������'), ('���������'), ('�����'), ('�����'), ('���������')

--������� �����������
INSERT INTO Positions (Name, Descr, Salary)
VALUES ('������������� ����', '�������� �� ����������� ������ ����, ������������ ����������� � ���������� ����������.', 50000),
('������', '������������ � ��������� �����������, �������� �� ������������ ������.', 35000),
('��������', '����������� �����������, ��������� ������ � ������������ ������� ��������.', 40000),
('�����', '������� ����� �������� ���� � ��������, ������ �� ��������� �������������.', 60000),
('�������� ������', '��������� ������ ������ � ������������� ���� � ���������� ������������.', 45000),
('��-���', '�������� �� ����������� �����, �������� �� �������������� ���� � ����.', 70000),
('���-�����', '������������� ����, ������������ ����� � ������������ ������� �������� ����.', 80000),
('������', '������� �������, ����������� ������ ����, ������� ����� ��������.', 45000),
('����������', '�������� �� ����� ���������� ���������� � ����������� �������� ������ ������������.', 75000),
('�������� �� ���������', '���������� �������, ��������� � ����������� ����������.', 55000),
('�������� �� ���������', '�������� �� �������������� � ������������ � ���������� ��������.', 60000),
('�������� ������������', '��������� � ������������ ������������ ������ �� �����������.', 40000),
('�������� ��������� �������', '������������ ������ �� �������� � ���������� ������ � ���������.', 42000),
('������', '���������� ������ �������� � ��������� �����.', 35000),
('�������', '�������� �� ������� � ������� � ���������.', 30000);

--���� �� ��������
INSERT INTO DeliveryCosts VALUES('0-3��', 250), ('3-6��', 275), ('6-9��', 300), ('9-12��', 325),('12-15��', 350),('15-18��', 375), ('18-21��', 400)

--������ �� ������
INSERT INTO OrderDiscounts VALUES('<10', '0'), ('<20', '10'), ('<30', '20'), ('<40', '30'), ('<60', '40')

--�����������
INSERT INTO Ingredients  VALUES
('���', NULL, 10, '���������'),
('������', NULL, 10, '���������'),
('�������', NULL, 10, '���������'),
('��������', NULL, 10, '���������'),
('�������', NULL, 10, '���������'),
('������', NULL, 10, '���������'),
('�����', NULL, 10, '���������'),
('������', NULL, 10, '���������'),
('����', NULL, 4000, '�����'),
('�����', NULL, 7000, '�����'),
('�����', NULL, 60, '�����'),
('�������', NULL, 7000, '�����'),
('��������', NULL, 12000, '�����'),
('��������', NULL, 4000, '�����'),
('������ ������', NULL, 11000, '�����'),
('����', NULL, 120, '�����'),
('������', NULL, 40, '���������'),
('��� ���������', NULL, 650, '�����'),
('��������', NULL, 40, '���������'),('������', NULL, 40, '���������'),('�����', NULL, 40, '���������'),('�������', NULL, 40, '�����'),('��� ��������', NULL, 700, '�����'),
('��������', NULL, 980, '�����'),('���', NULL, 1240, '�����'),('��������� �����', NULL, 2000, '�����'),('������', NULL, 160, '�����'),('��������', NULL, 980, '�����'),
('����', NULL, 45, '�����'),('�����', NULL, 980, '�����'),('������', NULL, 9000, '�����'),('���� �������', NULL, 31, '����'),('���� �����', NULL, 31, '����'),('������ ����', NULL, 50, '����'),
('��������� ������', NULL, 31, '����'),('������ ���', NULL, 10000, '�����'),('����(�������)', NULL, 10000, '�����'),('�������', NULL, 30, '����'), ('���� ������', NULL, 5, '����'), 
('����', NULL, 200, '�����'), ('������� ������', NULL, 300, '�����'), ('����� �������', NULL, 150, '�����')

--�������
INSERT INTO Tabless (TableNumber, Descr, NumberSeats) 
VALUES (1, '������ � ����', 6),
(2, '������� ������', 4),
(3, '������� ������', 4),
(4, '�������� ������', 5),
(5, '������ ��� ��������', 6),
(6, '��������� ���� �1', 12),
(7, '��������� ���� �2', 12),
(8, '������� ������', 4),
(9, '��������� ���� �3', 12),
(10, '��������� ���� �4', 12),
(11, '��������� ���� �5', 12),
(12, '������� ��������� ����', 10),
(13, '������ ��� ��������� ��������', 10),
(14, '������ ��� ��������� ��������', 10),
(15, '������ ��� ����', 7),
(16, '������ ��� ������', 5),
(17, '������ ��� ��������', 8),
(18, '������ ��� ��������', 8),
(19, '������� ������', 4),
(20, '������� ������', 4);
UPDATE Tabless SET Availability=0 WHERE TableNumber=14

--������� ����
INSERT INTO MenuSections VALUES
('�������','������ � ���������� �����, ��������� ��� ������ ������ ����. �������� � ���� ����� �����, ���� � ������������ ��������'),
('���� � �������','������ � ���������� ����� ��� ���, ��� ������������ ������ ���� ��� ���� � ����-�� ��������. �������� � ���� ������������� ���� � �������'),
('������','������ � ���������� �����, ���������� ������ �����, ������� ������ � ������������� �������. �������� ����� ��� ���, ��� ������ �� ���������'),
('�������� ����� �� ����','���������� ����� �� ����, �������������� ���������� ���������. �������� � ���� ������, ������, ����� � ������ ��������'),
('�������� ����� �� ���� � �������������','������������� ����� �� ������ ���� � �������������. �������� ��� ��������� ������ � ����������� ����.'),
('����� � �������','����������� ����������� �����, ������� ������������� ���� ����� � ������� � ���������� ��������� � �������.'),
('�����','���������� ����������� ����� � �������������� ������� � ���������. �������� ����� ��� ���������� � ��������.'),
('�������������� ����','������� � ������������� ���� ��� �������������, ������� ����� � �������������� ������ ������, ����� � ������.'),
('������� � ��������','��������� ��� ��������� ��������. �������� � ���� �����, ������, ��������� � ������ �������.'),
('�������','��������� �������, ������� ����������� � ��������������. ������ �����, ��������, ��� � ����.')

--������� ����
INSERT INTO MenuPositions (Name, Descr, Price, Portion, PortionUnit, MenuSection) VALUES 
('������ � ������� � �������','������ ����� ������ � ��������� ������ ������� ������, �������� ���������� ��������, ������� �������, ���������������� � ���������� ����� ������ � ����������� ��������� ������ �����. ������� � ������������ ������ ������', 390, 25, '�����',3),
('��������� ����� � �������� � �����','������������ ��������� ����� � �������� ���������� ����, �������� ����������, ��������, ������� �����, �������� � ������� �������� �������. �������� � �������� ��������� ������.',350,200,'�����',3),
('������������ ������� ������','������ ������� ������, �������������� �� ��������� ���� � �������������� ��������� ���� ��� � ��������� ����. �������� � ������ � ������� �����.',250,300,'�����',2),
('�������� ����-��� � ���������','���������� ����-���, �������������� �� ������ ��������� � ����������� ������� �������� �� ������� ��������. �������� � ���������� ��������.',280,350,'�����',2),
('��������� ���-��� � ������������','���������� ��������� ��� � ��������� ������� ������, ��������� ������������, ��������� ������� � �������� �������.',320,400,'�����',2),
('��������','������������ ����������� ������, ��������� �� ����� ������ ���������, ����������� ���� � ��������, � ������������� ����������-�����, ���������� �����-��������.',350,150,'�����',9),
('���������� ������','��������� ��������� ��������� ������� �������� � �������, �������� ����������� ����������� �����. �������� � ������� ���������� ����������.',450,200,'�����',9),
('��������� �������','������ ������� � ����������� �������� (��������, ��������, ����) �� �������. ������ �����, ����-��� � ������ ������ ������� ����������� ����.',380,180,'�����',9),
('�������� �������','������������ �������� � ������� ��������, ������ � �������� �������. ��������� ��������� ������� ���� � ������������ ��������.',400,150,'���������',10),
('�����-������ ����','���������� �������� � ������������ ������������ ������� � ������� �����. ������ �������� � ��������� �������� ������� ��������� ������.',350,200,'���������',10)
UPDATE MenuPositions SET Availability = 0 WHERE MenuPositionId = 10

--����������
INSERT INTO Employees (Name, Surname, Patronymic, Gender, Phone, Email, DateHire, Position) VALUES
--��������� ������������
('����', '������', '���������', '���', '89991234567', 'ivan.petrov@example.com', '2023-01-15', 12),
('����', '�������', '�������������', '���', '89997654321','anna.ivanova@example.com','2023-02-03',12),
--��������� ��������� �������
('�������', '������', '�����������', '���', '89991234576', 'tatiana.popova@example.com', '2023-01-23', 13),
('�����', '�������', '���������', '���', '89991234575', 'igor.romanov@example.com', '2023-01-22', 13),
('��������', '��������', '����������', '���', '89991234574', 'angelina.morozova@example.com', '2023-01-21', 13),
--����������
('�������', '�������', '��������', '���', '89991234545', 'alexey.sidorov@example.com', '2023-01-15',9),
--���������
('������', '�������', '�������������', '���', '89999991245', 'mikhail.smirnov@example.com', '2023-01-15', 3),
('�����', '�������', '���������','���', '89997776655', 'elena.kozlova@example.com', '2023-02-07',3),
('�����', '�������', '���������', '���', '89991234572', 'olga.pavlova@example.com', '2023-01-19', 3),
('�������', '�������', '��������', '���', '89991234573', 'dmitry.fedorov@example.com', '2023-01-20', 3),
('�����', '�����', '�����������', '���', '89991234577', 'artem.belov@example.com', '2023-01-24', 3),
--�������
('���������', '������', '��������', '���', '89212345678', 'alexander.petrov@example.com', '2023-02-15', 14),
('�����', '������', '��������', '���', '89991234570', 'artem.kozlov@example.com', '2023-01-17', 14),
('������', '�������', '����������', '���', '89991234571', 'sergey.morozov@example.com', '2023-01-18', 14),
('�������', '�������', '�������������', '���', '89991234569', 'dmitry.smirnov@example.com', '2023-01-16', 14)





INSERT INTO EmployeesUsers VALUES
(1, USER_ID('sashka')),
(2, USER_ID('kursachUser')),
(6, USER_ID('restAdmin'))



--������������
INSERT INTO Reservations (DateTimeStart, NameClient, PhoneClient, Comment, NumberGuests, Status, TableNumber, BookingOperator) VALUES
('2023-01-15T12:30:00', '�����', '89991243531', NULL, 10, '��������������', 10, 1),
('2023-02-20T18:45:00', '�����', '89991243531', '����������� 2', 8, '��������������', 17, 1),
('2023-03-10T20:00:00', '�������', '89991243532', '����������� 3', 12, '��������������', 11, 1),
('2023-04-05T15:30:00', '���������', '89991243533', '����������� 4', 4, '��������������', 2, 1),
('2023-05-12T14:15:00', '�������', '89991243534', '����������� 5', 6, '��������������', 5, 1),
('2023-06-18T19:00:00', '����', '89991243531', '����������� 6', 10, '��������������', 12, 1),
('2023-07-25T17:45:00', '�����', '89991243532', '����������� 7', 3, '��������������', 19, 1),
('2023-08-30T21:30:00', '�����', '89991243533', '����������� 8', 7, '��������������', 15, 1),
('2023-09-05T16:00:00', '�������', '89991243534', '����������� 9', 9, '��������������', 12, 1),
('2023-10-10T12:15:00', '���������', '89991243531', '����������� 10', 11, '��������������', 11, 1),
('2023-11-15T14:30:00', '�������', '89991243532', '����������� 11', 2, '��������������', 8, 1),
('2023-12-20T22:00:00', '����', '89991243533', '����������� 12', 1, '��������������', 8, 1),
('2024-01-25T19:45:00', '�����', '89991243531', '����������� 13', 8, '��������������', 17, 1),
('2024-02-29T18:30:00', '�����', '89991243532', '����������� 14', 10, '��������������', 13, 1),
('2024-03-05T16:15:00', '�������', '89991243533', '����������� 15', 6, '��������������', 15, 1),
('2024-04-10T14:00:00', '���������', '89991243534', '����������� 16', 3, '��������������', 19, 1),
('2024-05-15T20:45:00', '�������', '89991243531', '����������� 17', 7, '��������������', 15, 1),
('2024-06-20T19:30:00', '����', '89991243532', '����������� 18', 12, '��������������', 9, 1),
('2024-07-25T18:00:00', '�����', '89991243533', '����������� 19', 5, '��������������', 5, 1),
('2024-08-30T17:15:00', '�����', '89991243534', '����������� 20', 11, '��������������', 11, 1),
('2023-12-20T22:00:00', '����', '89991243533', '����������� 12', 1, '��������������', 8, 1),
('2023-12-04T10:00:00', '���������', '89991243531', '����������� 12', 11, '������������', 11, 1),
('2023-12-04T22:00:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-05T22:00:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-06T22:00:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-07T22:45:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-08T22:00:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-10T22:00:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-14T22:00:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-16T22:30:00', '����', '89991243533', '����������� 12', 1, '������������', 8, 1),
('2023-12-23T22:20:00', '�����', '89991243532', '����������� 14', 10, '������������', 13, 1),
('2023-12-26T22:15:00', '�����', '89991243532', '����������� 14', 10, '������������', 13, 1),
('2023-12-30T21:30:00', '�����', '89991243532', '����������� 14', 10, '������������', 13, 1),
('2023-12-30T10:30:00', '����', '89991243533', NULL, 9, '������������', 13, 1)

--������� - ���������
INSERT INTO WaitersTables VALUES
(4,2),(4,3),(4,4),(5,1),(5,2),(5,14),(5,15)


--�������
INSERT INTO Clients (Username, Name, Surname, Patronymic, Gender, Phone, Email, Password, NumberOrders, OrderDiscount) VALUES 
('user1', '����', '������', '���������', '���', '89991237567', 'ivan.petov@example.com', 'password1', 5, 1),
('user2', '����', '�������', '���������', '���', '89991234568', 'anna.ivanova@example.com', 'password2', 15, 2),
('user3', '����', '�������', '�������������', '���', '89991234569', 'petr.sidorov@example.com', 'password3', 25, 3),
('user4', '�����', '���������', '��������', '���', '89991234570', 'elena.kuznetsova@example.com', 'password4', 35, 4),
('user5', '���������', '�������', '��������', '���', '89991234571', 'alexander.fedorov@example.com', 'password5', 45, 5)



--������ ������� ����

INSERT INTO CompositionOfMenuPosition (MenuPositionId, IngredientId, Quantity)
VALUES
(1, 42, 50), -- ����� �������
(1, 41, 180), -- ������� ������
(1, 22, 2), -- �������
(1, 40, 180), -- ����
(1, 39, 0.5), -- ���� ������
(1, 18, 250); -- ��� ���������


--������ �� ����� � �� ��������� (����� ����� �������� ��������)
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user1', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-30T17:15:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,4,1
EXEC AddPositionOfTakeawayOrder 2,2,1
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user1', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-20T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 1, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,2
EXEC AddPositionOfTakeawayOrder 2,3,2
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '12345678910', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-20T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,3
EXEC AddPositionOfTakeawayOrder 2,3,3
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-20T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,4
EXEC AddPositionOfTakeawayOrder 2,3,4
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-20T17:15:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,5
EXEC AddPositionOfTakeawayOrder 2,3,5
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-03-20T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,6
EXEC AddPositionOfTakeawayOrder 2,3,6
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-20T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,7
EXEC AddPositionOfTakeawayOrder 2,3,7
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-10T17:15:00', 
							@Status = '��������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 13
EXEC AddPositionOfTakeawayOrder 1,2,8
EXEC AddPositionOfTakeawayOrder 2,3,8
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-09T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,9
EXEC AddPositionOfTakeawayOrder 2,3,9
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-10T17:20:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,10
EXEC AddPositionOfTakeawayOrder 2,1,10
EXEC AddPositionOfTakeawayOrder 3,1,10
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-10T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,11
EXEC AddPositionOfTakeawayOrder 2,1,11
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,12
EXEC AddPositionOfTakeawayOrder 2,1,12
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-14T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,13
EXEC AddPositionOfTakeawayOrder 2,1,13
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-15T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 3,2,14
EXEC AddPositionOfTakeawayOrder 4,1,14
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-13T11:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 2,2,15
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T17:15:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 4, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,16
EXEC AddPositionOfTakeawayOrder 2,1,16
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-18T14:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 4, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,17
EXEC AddPositionOfTakeawayOrder 3,4,17
EXEC AddPositionOfTakeawayOrder 5,2,17
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-20T16:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,18
EXEC AddPositionOfTakeawayOrder 6,1,18
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-21T16:00:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,19
EXEC AddPositionOfTakeawayOrder 6,1,19
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-25T16:00:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,20
EXEC AddPositionOfTakeawayOrder 6,1,20
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-15T16:00:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,21
EXEC AddPositionOfTakeawayOrder 6,1,21
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user2', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T12:00:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,22
EXEC AddPositionOfTakeawayOrder 6,1,22
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user2', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-03T12:00:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,23
EXEC AddPositionOfTakeawayOrder 6,1,23
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user2', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-04T12:00:00', 
							@Status = '������������', @ReceiptOption = '���������', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,24
EXEC AddPositionOfTakeawayOrder 6,1,24
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '�������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-06T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,25
EXEC AddPositionOfTakeawayOrder 6,1,25
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-08T13:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,26
EXEC AddPositionOfTakeawayOrder 2,1,26
EXEC AddPositionOfTakeawayOrder 4,1,26
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T13:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,27
EXEC AddPositionOfTakeawayOrder 2,2,27
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-15T13:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,28
EXEC AddPositionOfTakeawayOrder 2,2,28
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-25T21:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,29
EXEC AddPositionOfTakeawayOrder 2,2,29
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,30
EXEC AddPositionOfTakeawayOrder 2,2,30
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-04-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,31
EXEC AddPositionOfTakeawayOrder 2,2,31
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-05-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,32
EXEC AddPositionOfTakeawayOrder 2,2,32
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-06-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,33
EXEC AddPositionOfTakeawayOrder 2,2,33
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-07-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,34
EXEC AddPositionOfTakeawayOrder 2,2,34
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,35
EXEC AddPositionOfTakeawayOrder 2,2,35
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-09-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,36
EXEC AddPositionOfTakeawayOrder 2,2,36
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-10-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,37
EXEC AddPositionOfTakeawayOrder 2,2,37
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-11-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,38
EXEC AddPositionOfTakeawayOrder 2,2,38
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-12-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,39
EXEC AddPositionOfTakeawayOrder 2,2,39
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-03-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,40
EXEC AddPositionOfTakeawayOrder 2,2,40
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-04-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,41
EXEC AddPositionOfTakeawayOrder 2,2,41

EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-04-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,42
EXEC AddPositionOfTakeawayOrder 2,2,42
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-05-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,43
EXEC AddPositionOfTakeawayOrder 2,2,43
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-06-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,44
EXEC AddPositionOfTakeawayOrder 2,2,44
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-07-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,45
EXEC AddPositionOfTakeawayOrder 2,2,45
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2025-08-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,46
EXEC AddPositionOfTakeawayOrder 2,2,46
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2025-09-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,47
EXEC AddPositionOfTakeawayOrder 2,2,47
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2025-10-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,48
EXEC AddPositionOfTakeawayOrder 2,2,48
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2022-11-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,49
EXEC AddPositionOfTakeawayOrder 2,2,49
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-12-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,50
EXEC AddPositionOfTakeawayOrder 2,2,50
EXEC AddTakeawayOrder @NameClient = '����', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-03-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,51
EXEC AddPositionOfTakeawayOrder 2,2,51
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-04-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,52
EXEC AddPositionOfTakeawayOrder 2,2,52

EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user5', @Requirements = NULL, @PaymentMethod = '����������� ������', @DateOrder = '2005-01-01T17:16:00', 
						@DateReceipt = '2023-04-26T12:00:00', 
							@Status = '������������', @ReceiptOption = '��������', @DeliveryAddress = '����� ����������� 5', @DeliveryCost = 4, @Courier = 15

						
--�������� �������� ������� ����
--�������� ������ � ��������� � ������� ������� � ���������
--�������� ��������, �����������

-- �������� ���������� � ������� ����� INFORMATION_SHEMA
USE RestaurantDB
SELECT *
FROM information_schema.ROUTINES;
