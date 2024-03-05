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
VALUES ('Название ресторана', 'Город', 'Улица', 'Дом', '11122223344', '55566667777', '99988887777');

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
	Gender NCHAR(3) NOT NULL CHECK (Gender IN ('муж', 'жен')),
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
	Gender NCHAR(3) NOT NULL CHECK (Gender IN ('муж', 'жен')),
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
	Status NVARCHAR(20) NOT NULL CHECK (Status IN ('подтверждено', 'обрабатывается', 'отменено')),
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
	PaymentMethod NVARCHAR(20) NOT NULL CHECK (PaymentMethod IN ('безналичный расчет', 'наличный расчет')),
	DateOrder DATETIME NOT NULL DEFAULT GETDATE() CHECK (DateOrder > '2000-01-01'),
	DateReceipt DATETIME NOT NULL,
	Status NVARCHAR(20) NOT NULL CHECK (Status IN ('подтверждено', 'обрабатывается', 'отменено')),
	ReceiptOption NVARCHAR(10) NOT NULL CHECK (ReceiptOption IN ('доставка', 'самовывоз')),
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
	PaymentMethod NVARCHAR(20) NOT NULL CHECK (PaymentMethod IN ('безналичный расчет', 'наличный расчет')),
	TableNumber INT NOT NULL,
	Waiter INT NOT NULL,
	CONSTRAINT CHK_DateTimeServingDishes CHECK (DateTimeServingDishes > DateTimeReception),
	CONSTRAINT FK_Waiter FOREIGN KEY (Waiter) REFERENCES Employees(EmployeeId),
	CONSTRAINT FK_TableNumberrr FOREIGN KEY (TableNumber) REFERENCES Tabless(TableNumber),
)

--INSERT INTO RestaurantOrders (DateTimeReception, Cost, PaymentMethod, TableNumber, Waiter) VALUES
--('2023-05-12T14:15:00', 800, 'наличный расчет', 1, 5)

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

--добавление записей в таблицы

--единицы измерения
INSERT INTO Units VALUES('литр'), ('миллиграмм'), ('килограмм'), ('грамм'), ('штука'), ('миллилитр')

--позиции сотрудников
INSERT INTO Positions (Name, Descr, Salary)
VALUES ('администратор зала', 'Отвечает за организацию работы зала, обслуживание посетителей и управление персоналом.', 50000),
('хостес', 'Приветствует и размещает посетителей, отвечает за бронирование столов.', 35000),
('официант', 'Обслуживает посетителей, принимает заказы и обеспечивает комфорт клиентов.', 40000),
('повар', 'Готовит блюда согласно меню и рецептам, следит за качеством приготовления.', 60000),
('помощник повара', 'Оказывает помощь повару в приготовлении блюд и подготовке ингредиентов.', 45000),
('су-шеф', 'Отвечает за организацию кухни, контроль за приготовлением блюд и меню.', 70000),
('шеф-повар', 'Разрабатывает меню, контролирует кухню и обеспечивает высокое качество блюд.', 80000),
('бармен', 'Готовит напитки, обслуживает барную зону, создает новые коктейли.', 45000),
('ресторатор', 'Отвечает за общее управление рестораном и поддержание высокого уровня обслуживания.', 75000),
('менеджер по персоналу', 'Занимается набором, обучением и управлением персоналом.', 55000),
('менеджер по поставкам', 'Отвечает за взаимодействие с поставщиками и управление запасами.', 60000),
('оператор бронирования', 'Принимает и обрабатывает бронирования столов от посетителей.', 40000),
('оператор обработки заказов', 'Обрабатывает заказы на доставку и внутренние заказы в ресторане.', 42000),
('курьер', 'Доставляет заказы клиентам в указанное место.', 35000),
('уборщик', 'Отвечает за чистоту и порядок в ресторане.', 30000);

--цены на доставку
INSERT INTO DeliveryCosts VALUES('0-3км', 250), ('3-6км', 275), ('6-9км', 300), ('9-12км', 325),('12-15км', 350),('15-18км', 375), ('18-21км', 400)

--скидки на заказы
INSERT INTO OrderDiscounts VALUES('<10', '0'), ('<20', '10'), ('<30', '20'), ('<40', '30'), ('<60', '40')

--ингредиенты
INSERT INTO Ingredients  VALUES
('Лук', NULL, 10, 'килограмм'),
('Чеснок', NULL, 10, 'килограмм'),
('Морковь', NULL, 10, 'килограмм'),
('Картошка', NULL, 10, 'килограмм'),
('Помидор', NULL, 10, 'килограмм'),
('Огурцы', NULL, 10, 'килограмм'),
('Перец', NULL, 10, 'килограмм'),
('Шпинат', NULL, 10, 'килограмм'),
('Мука', NULL, 4000, 'грамм'),
('Сахар', NULL, 7000, 'грамм'),
('Лимон', NULL, 60, 'штука'),
('Базилик', NULL, 7000, 'грамм'),
('Петрушка', NULL, 12000, 'грамм'),
('Розмарин', NULL, 4000, 'грамм'),
('Свежий имбирь', NULL, 11000, 'грамм'),
('Яйцо', NULL, 120, 'штука'),
('Курица', NULL, 40, 'килограмм'),
('Сыр моцарелла', NULL, 650, 'грамм'),
('Говядина', NULL, 40, 'килограмм'),('Лосось', NULL, 40, 'килограмм'),('Тунец', NULL, 40, 'килограмм'),('Авокадо', NULL, 40, 'штука'),('Сыр пармезан', NULL, 700, 'грамм'),
('Спагетти', NULL, 980, 'грамм'),('Рис', NULL, 1240, 'грамм'),('Сливочное масло', NULL, 2000, 'грамм'),('Яблоко', NULL, 160, 'штука'),('Кукуруза', NULL, 980, 'штука'),
('Чили', NULL, 45, 'штука'),('Кинза', NULL, 980, 'грамм'),('Кунжут', NULL, 9000, 'грамм'),('Вино красное', NULL, 31, 'литр'),('Вино белое', NULL, 31, 'литр'),('Соевый соус', NULL, 50, 'литр'),
('Кокосовое молоко', NULL, 31, 'литр'),('Черный чай', NULL, 10000, 'грамм'),('Кофе(молотый)', NULL, 10000, 'грамм'),('Майонез', NULL, 30, 'литр'), ('Соус Цезарь', NULL, 5, 'литр'), 
('Хлеб', NULL, 200, 'грамм'), ('Куриная грудка', NULL, 300, 'грамм'), ('Салат Айсберг', NULL, 150, 'грамм')

--столики
INSERT INTO Tabless (TableNumber, Descr, NumberSeats) 
VALUES (1, 'Столик у окна', 6),
(2, 'Угловой столик', 4),
(3, 'Угловой столик', 4),
(4, 'Семейный столик', 5),
(5, 'Столик для компании', 6),
(6, 'Банкетный стол №1', 12),
(7, 'Банкетный стол №2', 12),
(8, 'Угловой столик', 4),
(9, 'Банкетный стол №3', 12),
(10, 'Банкетный стол №4', 12),
(11, 'Банкетный стол №5', 12),
(12, 'Средний банкетный стол', 10),
(13, 'Столик для небольшой компании', 10),
(14, 'Столик для небольшой компании', 10),
(15, 'Столик для пары', 7),
(16, 'Столик для друзей', 5),
(17, 'Столик для компании', 8),
(18, 'Столик для компании', 8),
(19, 'Угловой столик', 4),
(20, 'Угловой столик', 4);
UPDATE Tabless SET Availability=0 WHERE TableNumber=14

--разделы меню
INSERT INTO MenuSections VALUES
('Закуски','Легкие и аппетитные блюда, идеальные для начала приема пищи. Включают в себя сырые овощи, дипы и маринованные продукты'),
('Супы и Бульоны','Теплые и насыщенные блюда для тех, кто предпочитает начать обед или ужин с чего-то горячего. Включают в себя разнообразные супы и бульоны'),
('Салаты','Легкие и освежающие блюда, включающие свежие овощи, зеленые листья и разнообразные добавки. Отличный выбор для тех, кто следит за здоровьем'),
('Основные блюда из мяса','Изысканные блюда из мяса, приготовленные различными способами. Включают в себя стейки, жаркое, гриль и другие варианты'),
('Основные блюда из рыбы и морепродуктов','Разнообразные блюда из свежей рыбы и морепродуктов. Подходит для любителей легких и диетических блюд.'),
('Паста и Ризотто','Автентичные итальянские блюда, включая разнообразные виды пасты и ризотто с различными добавками и соусами.'),
('Пицца','Популярные итальянские блюда с разнообразными тестами и начинками. Отличный выбор для разделения с друзьями.'),
('Вегетарианское меню','Богатое и разнообразное меню для вегетарианцев, включая блюда с использованием свежих овощей, зерен и соусов.'),
('Десерты и сладости','Искушения для любителей сладкого. Включают в себя торты, пироги, мороженое и другие десерты.'),
('Напитки','Различные напитки, включая алкогольные и безалкогольные. Винная карта, коктейли, чай и кофе.')

--позиции меню
INSERT INTO MenuPositions (Name, Descr, Price, Portion, PortionUnit, MenuSection) VALUES 
('Цезарь с курицей и авокадо','Свежий салат Цезарь с кусочками сочной куриной грудки, листьями хрустящего айсберга, ломтями авокадо, подмаринованными в деликатном соусе Цезарь с добавлением хрустящих крошек хлеба. Подаётся с классическим соусом Цезарь', 390, 25, 'грамм',3),
('Греческий салат с оливками и фетой','Классический греческий салат с кубиками ароматного фета, красными помидорами, огурцами, красным луком, оливками и свежими зелеными травами. Подается с лимонным оливковым маслом.',350,200,'грамм',3),
('Классический куриный бульон','Нежный куриный бульон, приготовленный на медленном огне с использованием отборного мяса кур и ароматных трав. Подается с лапшой и зеленым луком.',250,300,'грамм',2),
('Томатный крем-суп с базиликом','Насыщенный крем-суп, приготовленный из спелых помидоров с добавлением нежного коктейля из свежего базилика. Подается с хрустящими гренками.',280,350,'грамм',2),
('Лососевый чау-чау с лимонграссом','Утонченный азиатский суп с кусочками свежего лосося, ароматным лимонграссом, кокосовым молоком и рисовыми лапшами.',320,400,'грамм',2),
('Тирамису','Классический итальянский десерт, состоящий из слоев нежных бисквитов, пропитанных кофе и амаретто, и великолепного маскарпоне-крема, посыпанный какао-порошком.',350,150,'грамм',9),
('Шоколадный Фондан','Идеальное сочетание хрустящей внешней оболочки и мягкого, текучего внутреннего шоколадного кекса. Подается с шариком ванильного мороженого.',450,200,'грамм',9),
('Фруктовый Чизкейк','Легкий чизкейк с освежающими фруктами (клубника, маракуйя, киви) на вершине. Нежное тесто, крем-сыр и сочные фрукты создают гармоничный вкус.',380,180,'грамм',9),
('Эспрессо Мартини','Классический коктейль с крепким эспрессо, водкой и кофейным ликером. Идеальное сочетание энергии кофе и насыщенности коктейля.',400,150,'миллилитр',10),
('Манго-текила смеш','Освежающий коктейль с традиционным мексиканским текилой и сладким манго. Легкая кислинка и фруктовая сладость создают идеальный баланс.',350,200,'миллилитр',10)
UPDATE MenuPositions SET Availability = 0 WHERE MenuPositionId = 10

--сотрудники
INSERT INTO Employees (Name, Surname, Patronymic, Gender, Phone, Email, DateHire, Position) VALUES
--операторы бронирования
('Иван', 'Петров', 'Сергеевич', 'муж', '89991234567', 'ivan.petrov@example.com', '2023-01-15', 12),
('Анна', 'Иванова', 'Александровна', 'жен', '89997654321','anna.ivanova@example.com','2023-02-03',12),
--операторы обработки заказов
('Татьяна', 'Попова', 'Анатольевна', 'жен', '89991234576', 'tatiana.popova@example.com', '2023-01-23', 13),
('Игорь', 'Романов', 'Сергеевич', 'муж', '89991234575', 'igor.romanov@example.com', '2023-01-22', 13),
('Ангелина', 'Морозова', 'Алексеевна', 'жен', '89991234574', 'angelina.morozova@example.com', '2023-01-21', 13),
--ресторатор
('Алексей', 'Сидоров', 'Игоревич', 'муж', '89991234545', 'alexey.sidorov@example.com', '2023-01-15',9),
--официанты
('Михаил', 'Смирнов', 'Александрович', 'муж', '89999991245', 'mikhail.smirnov@example.com', '2023-01-15', 3),
('Елена', 'Козлова', 'Сергеевна','жен', '89997776655', 'elena.kozlova@example.com', '2023-02-07',3),
('Ольга', 'Павлова', 'Андреевна', 'жен', '89991234572', 'olga.pavlova@example.com', '2023-01-19', 3),
('Дмитрий', 'Федоров', 'Игоревич', 'муж', '89991234573', 'dmitry.fedorov@example.com', '2023-01-20', 3),
('Артем', 'Белов', 'Анатольевич', 'муж', '89991234577', 'artem.belov@example.com', '2023-01-24', 3),
--курьеры
('Александр', 'Петров', 'Иванович', 'муж', '89212345678', 'alexander.petrov@example.com', '2023-02-15', 14),
('Артем', 'Козлов', 'Игоревич', 'муж', '89991234570', 'artem.kozlov@example.com', '2023-01-17', 14),
('Сергей', 'Морозов', 'Алексеевич', 'муж', '89991234571', 'sergey.morozov@example.com', '2023-01-18', 14),
('Дмитрий', 'Смирнов', 'Александрович', 'муж', '89991234569', 'dmitry.smirnov@example.com', '2023-01-16', 14)





INSERT INTO EmployeesUsers VALUES
(1, USER_ID('sashka')),
(2, USER_ID('kursachUser')),
(6, USER_ID('restAdmin'))



--бронирования
INSERT INTO Reservations (DateTimeStart, NameClient, PhoneClient, Comment, NumberGuests, Status, TableNumber, BookingOperator) VALUES
('2023-01-15T12:30:00', 'Игорь', '89991243531', NULL, 10, 'обрабатывается', 10, 1),
('2023-02-20T18:45:00', 'Мария', '89991243531', 'Комментарий 2', 8, 'обрабатывается', 17, 1),
('2023-03-10T20:00:00', 'Алексей', '89991243532', 'Комментарий 3', 12, 'обрабатывается', 11, 1),
('2023-04-05T15:30:00', 'Екатерина', '89991243533', 'Комментарий 4', 4, 'обрабатывается', 2, 1),
('2023-05-12T14:15:00', 'Дмитрий', '89991243534', 'Комментарий 5', 6, 'обрабатывается', 5, 1),
('2023-06-18T19:00:00', 'Анна', '89991243531', 'Комментарий 6', 10, 'обрабатывается', 12, 1),
('2023-07-25T17:45:00', 'Игорь', '89991243532', 'Комментарий 7', 3, 'обрабатывается', 19, 1),
('2023-08-30T21:30:00', 'Мария', '89991243533', 'Комментарий 8', 7, 'обрабатывается', 15, 1),
('2023-09-05T16:00:00', 'Алексей', '89991243534', 'Комментарий 9', 9, 'обрабатывается', 12, 1),
('2023-10-10T12:15:00', 'Екатерина', '89991243531', 'Комментарий 10', 11, 'обрабатывается', 11, 1),
('2023-11-15T14:30:00', 'Дмитрий', '89991243532', 'Комментарий 11', 2, 'обрабатывается', 8, 1),
('2023-12-20T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'обрабатывается', 8, 1),
('2024-01-25T19:45:00', 'Игорь', '89991243531', 'Комментарий 13', 8, 'обрабатывается', 17, 1),
('2024-02-29T18:30:00', 'Мария', '89991243532', 'Комментарий 14', 10, 'обрабатывается', 13, 1),
('2024-03-05T16:15:00', 'Алексей', '89991243533', 'Комментарий 15', 6, 'обрабатывается', 15, 1),
('2024-04-10T14:00:00', 'Екатерина', '89991243534', 'Комментарий 16', 3, 'обрабатывается', 19, 1),
('2024-05-15T20:45:00', 'Дмитрий', '89991243531', 'Комментарий 17', 7, 'обрабатывается', 15, 1),
('2024-06-20T19:30:00', 'Анна', '89991243532', 'Комментарий 18', 12, 'обрабатывается', 9, 1),
('2024-07-25T18:00:00', 'Игорь', '89991243533', 'Комментарий 19', 5, 'обрабатывается', 5, 1),
('2024-08-30T17:15:00', 'Мария', '89991243534', 'Комментарий 20', 11, 'обрабатывается', 11, 1),
('2023-12-20T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'обрабатывается', 8, 1),
('2023-12-04T10:00:00', 'Екатерина', '89991243531', 'Комментарий 12', 11, 'подтверждено', 11, 1),
('2023-12-04T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-05T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-06T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-07T22:45:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-08T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-10T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-14T22:00:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-16T22:30:00', 'Анна', '89991243533', 'Комментарий 12', 1, 'подтверждено', 8, 1),
('2023-12-23T22:20:00', 'Мария', '89991243532', 'Комментарий 14', 10, 'подтверждено', 13, 1),
('2023-12-26T22:15:00', 'Мария', '89991243532', 'Комментарий 14', 10, 'подтверждено', 13, 1),
('2023-12-30T21:30:00', 'Мария', '89991243532', 'Комментарий 14', 10, 'подтверждено', 13, 1),
('2023-12-30T10:30:00', 'Анна', '89991243533', NULL, 9, 'подтверждено', 13, 1)

--столики - официанты
INSERT INTO WaitersTables VALUES
(4,2),(4,3),(4,4),(5,1),(5,2),(5,14),(5,15)


--клиенты
INSERT INTO Clients (Username, Name, Surname, Patronymic, Gender, Phone, Email, Password, NumberOrders, OrderDiscount) VALUES 
('user1', 'Иван', 'Петров', 'Сергеевич', 'муж', '89991237567', 'ivan.petov@example.com', 'password1', 5, 1),
('user2', 'Анна', 'Иванова', 'Сергеевна', 'жен', '89991234568', 'anna.ivanova@example.com', 'password2', 15, 2),
('user3', 'Петр', 'Сидоров', 'Александрович', 'муж', '89991234569', 'petr.sidorov@example.com', 'password3', 25, 3),
('user4', 'Елена', 'Кузнецова', 'Игоревна', 'жен', '89991234570', 'elena.kuznetsova@example.com', 'password4', 35, 4),
('user5', 'Александр', 'Федоров', 'Павлович', 'муж', '89991234571', 'alexander.fedorov@example.com', 'password5', 45, 5)



--состав позиций меню

INSERT INTO CompositionOfMenuPosition (MenuPositionId, IngredientId, Quantity)
VALUES
(1, 42, 50), -- Салат Айсберг
(1, 41, 180), -- Куриная грудка
(1, 22, 2), -- Авокадо
(1, 40, 180), -- Хлеб
(1, 39, 0.5), -- Соус Цезарь
(1, 18, 250); -- Сыр моцарелла


--заказы на вынос с их составами (через вызов хранимых процедур)
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user1', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-30T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,4,1
EXEC AddPositionOfTakeawayOrder 2,2,1
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user1', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-20T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 1, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,2
EXEC AddPositionOfTakeawayOrder 2,3,2
EXEC AddTakeawayOrder @NameClient = 'Иван', @PhoneClient = '12345678910', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-20T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,3
EXEC AddPositionOfTakeawayOrder 2,3,3
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-20T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,4
EXEC AddPositionOfTakeawayOrder 2,3,4
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-20T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,5
EXEC AddPositionOfTakeawayOrder 2,3,5
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-03-20T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,6
EXEC AddPositionOfTakeawayOrder 2,3,6
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-20T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,7
EXEC AddPositionOfTakeawayOrder 2,3,7
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-10T17:15:00', 
							@Status = 'обрабатывается', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 13
EXEC AddPositionOfTakeawayOrder 1,2,8
EXEC AddPositionOfTakeawayOrder 2,3,8
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-09T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,9
EXEC AddPositionOfTakeawayOrder 2,3,9
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user3', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-02-10T17:20:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,10
EXEC AddPositionOfTakeawayOrder 2,1,10
EXEC AddPositionOfTakeawayOrder 3,1,10
EXEC AddTakeawayOrder @NameClient = 'Егор', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-10T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,11
EXEC AddPositionOfTakeawayOrder 2,1,11
EXEC AddTakeawayOrder @NameClient = 'Егор', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,12
EXEC AddPositionOfTakeawayOrder 2,1,12
EXEC AddTakeawayOrder @NameClient = 'Егор', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-14T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 1,2,13
EXEC AddPositionOfTakeawayOrder 2,1,13
EXEC AddTakeawayOrder @NameClient = 'Егор', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-15T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 3,2,14
EXEC AddPositionOfTakeawayOrder 4,1,14
EXEC AddTakeawayOrder @NameClient = 'Егор', @PhoneClient = '89132341264', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-13T11:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 14
EXEC AddPositionOfTakeawayOrder 2,2,15
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T17:15:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 4, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,16
EXEC AddPositionOfTakeawayOrder 2,1,16
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-18T14:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 4, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,17
EXEC AddPositionOfTakeawayOrder 3,4,17
EXEC AddPositionOfTakeawayOrder 5,2,17
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-20T16:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = NULL, @DeliveryCost = 2, @Courier = 12
EXEC AddPositionOfTakeawayOrder 1,2,18
EXEC AddPositionOfTakeawayOrder 6,1,18
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-21T16:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,19
EXEC AddPositionOfTakeawayOrder 6,1,19
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-25T16:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,20
EXEC AddPositionOfTakeawayOrder 6,1,20
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-15T16:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,21
EXEC AddPositionOfTakeawayOrder 6,1,21
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user2', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,22
EXEC AddPositionOfTakeawayOrder 6,1,22
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user2', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-03T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,23
EXEC AddPositionOfTakeawayOrder 6,1,23
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user2', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-04T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'самовывоз', @DeliveryAddress = NULL, @DeliveryCost = NULL, @Courier = NULL
EXEC AddPositionOfTakeawayOrder 1,2,24
EXEC AddPositionOfTakeawayOrder 6,1,24
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'наличный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-06T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,25
EXEC AddPositionOfTakeawayOrder 6,1,25
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-08T13:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,2,26
EXEC AddPositionOfTakeawayOrder 2,1,26
EXEC AddPositionOfTakeawayOrder 4,1,26
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-12T13:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,27
EXEC AddPositionOfTakeawayOrder 2,2,27
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-15T13:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,28
EXEC AddPositionOfTakeawayOrder 2,2,28
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-25T21:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,29
EXEC AddPositionOfTakeawayOrder 2,2,29
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-01-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,30
EXEC AddPositionOfTakeawayOrder 2,2,30
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-04-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,31
EXEC AddPositionOfTakeawayOrder 2,2,31
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-05-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,32
EXEC AddPositionOfTakeawayOrder 2,2,32
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-06-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,33
EXEC AddPositionOfTakeawayOrder 2,2,33
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-07-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,34
EXEC AddPositionOfTakeawayOrder 2,2,34
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-08-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,35
EXEC AddPositionOfTakeawayOrder 2,2,35
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-09-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,36
EXEC AddPositionOfTakeawayOrder 2,2,36
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-10-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,37
EXEC AddPositionOfTakeawayOrder 2,2,37
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-11-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,38
EXEC AddPositionOfTakeawayOrder 2,2,38
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-12-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,39
EXEC AddPositionOfTakeawayOrder 2,2,39
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-03-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,40
EXEC AddPositionOfTakeawayOrder 2,2,40
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2024-04-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,41
EXEC AddPositionOfTakeawayOrder 2,2,41

EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-04-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,42
EXEC AddPositionOfTakeawayOrder 2,2,42
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-05-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,43
EXEC AddPositionOfTakeawayOrder 2,2,43
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-06-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,44
EXEC AddPositionOfTakeawayOrder 2,2,44
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-07-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,45
EXEC AddPositionOfTakeawayOrder 2,2,45
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2025-08-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,46
EXEC AddPositionOfTakeawayOrder 2,2,46
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2025-09-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,47
EXEC AddPositionOfTakeawayOrder 2,2,47
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2025-10-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,48
EXEC AddPositionOfTakeawayOrder 2,2,48
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2022-11-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,49
EXEC AddPositionOfTakeawayOrder 2,2,49
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-12-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,50
EXEC AddPositionOfTakeawayOrder 2,2,50
EXEC AddTakeawayOrder @NameClient = 'Петр', @PhoneClient = '89109250504', @Username = NULL, @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-03-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,51
EXEC AddPositionOfTakeawayOrder 2,2,51
EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user4', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', @DateReceipt = '2023-04-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15
EXEC AddPositionOfTakeawayOrder 1,3,52
EXEC AddPositionOfTakeawayOrder 2,2,52

EXEC AddTakeawayOrder @NameClient = NULL, @PhoneClient = NULL, @Username = 'user5', @Requirements = NULL, @PaymentMethod = 'безналичный расчет', @DateOrder = '2005-01-01T17:16:00', 
						@DateReceipt = '2023-04-26T12:00:00', 
							@Status = 'подтверждено', @ReceiptOption = 'доставка', @DeliveryAddress = 'улица коммунарова 5', @DeliveryCost = 4, @Courier = 15

						
--накинуть побольше позиций меню
--накинуть заказы в ресторане и составы заказов в ресторане
--накинуть поставки, поставщиков

-- просмотр метаданных с помощью схемы INFORMATION_SHEMA
USE RestaurantDB
SELECT *
FROM information_schema.ROUTINES;
