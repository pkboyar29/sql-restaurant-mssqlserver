USE RestaurantDB

--процедуры, используемые на фронте
SELECT * FROM Reservations

SELECT * FROM EmployeesUsers

CREATE PROC GetUserRole
AS
BEGIN
    IF IS_ROLEMEMBER('Restorator') = 1
    BEGIN
        SELECT 'Restorator' AS UserRole;
    END
    ELSE IF IS_ROLEMEMBER('BookingOperator') = 1
    BEGIN
        SELECT 'BookingOperator' AS UserRole;
    END
    ELSE IF IS_ROLEMEMBER('OrderOperator') = 1
    BEGIN
        SELECT 'OrderOperator' AS UserRole;
    END
    ELSE
    BEGIN
        SELECT 'OtherRole' AS UserRole;
    END
END


--EXEC GetUserRole


CREATE PROC ShowReservations 
    @Status NVARCHAR(20),
    @FilterDate DATETIME
AS
BEGIN
    IF @Status <> 'все'
    BEGIN
        IF @FilterDate = '2000-01-01T00:00:00'
            SELECT ReservationId, DateTimeStart, NameClient, PhoneClient, Comment, NumberGuests, Status, TableNumber
			FROM Reservations WHERE Status = @Status
        ELSE
            SELECT ReservationId, DateTimeStart, NameClient, PhoneClient, Comment, NumberGuests, Status, TableNumber 
			FROM Reservations WHERE Status = @Status AND CONVERT(DATE, DateTimeStart) = CONVERT(DATE, @FilterDate)
    END
    ELSE
    BEGIN
        IF @FilterDate = '2000-01-01T00:00:00'
            SELECT ReservationId, DateTimeStart, NameClient, PhoneClient, Comment, NumberGuests, Status, TableNumber 
			FROM Reservations
        ELSE
            SELECT ReservationId, DateTimeStart, NameClient, PhoneClient, Comment, NumberGuests, Status, TableNumber
			FROM Reservations WHERE CONVERT(DATE, DateTimeStart) = CONVERT(DATE, @FilterDate)
    END
END







CREATE PROC ShowTableNumbers
AS
BEGIN
	SELECT TableNumber, NumberSeats FROM Tabless WHERE Availability = 1
END







--процедуры, реализующие аналитические запросы

--Определить количество бронирований каждого столика за указанный месяц
CREATE PROC ShowReservationCountByTable
    @MonthYear NVARCHAR(7) -- формат 'YYYY-MM'
AS
BEGIN
    SELECT
        r.TableNumber,
        COUNT(*) AS ReservationCount
    FROM
        Reservations r
    WHERE
        r.Status = 'подтверждено' AND
        (
            FORMAT(r.DateTimeStart, 'yyyy-MM') = @MonthYear OR
            FORMAT(r.DateTimeStart, 'yyyy-M') = @MonthYear OR -- для однозначных месяцев
            FORMAT(r.DateTimeStart, 'yyyy-M') = '0' + @MonthYear -- еще один вариант для однозначных месяцев
        )
    GROUP BY
        r.TableNumber
    ORDER BY
        ReservationCount DESC;
END

--EXEC ShowReservationCountByTable '2023-1'




--Определить количество бронирований каждый день за указанный месяц
CREATE PROC ShowReservationCountByDay
    @TargetMonth NVARCHAR(7) -- Формат 'YYYY-MM'
AS
BEGIN
    SELECT
        DAY(DateTimeStart) AS ReservationDay,
        COUNT(*) AS ReservationCount
    FROM
        Reservations
    WHERE
        Status = 'подтверждено' AND FORMAT(DateTimeStart, 'yyyy-MM') = @TargetMonth
    GROUP BY
        DAY(DateTimeStart)
    ORDER BY
        ReservationDay;
END

--EXEC ShowReservationCountByDay '2023-12'





--Определить самые популярные дни недели по количеству заказов на вынос за указанный месяц
CREATE PROC ShowMostPopularDaysOfWeekForTakeawayOrders
    @Year INT,
    @Month INT
AS
BEGIN
    SELECT 
        DATENAME(WEEKDAY, DateReceipt) AS Weekday,
        COUNT(*) AS TakeawayOrdersCount
    FROM 
        TakeawayOrders
    WHERE 
        YEAR(DateReceipt) = @Year
        AND MONTH(DateReceipt) = @Month
        AND Status = 'подтверждено'
    GROUP BY 
        DATENAME(WEEKDAY, DateReceipt)
    ORDER BY 
        TakeawayOrdersCount DESC;
END

--EXEC ShowMostPopularDaysOfWeekForTakeawayOrders '2024', '1' 






--Определить выручку от всех заказов на вынос за каждый месяц указанного года
CREATE PROC CalculateTakeawayRevenueByYear
    @Year INT
AS
BEGIN
    SELECT 
        MONTH(DateReceipt) AS Month,
        SUM(DiscountedCost) AS TotalRevenue
    FROM 
        TakeawayOrders
    WHERE 
        Status = 'подтверждено' AND YEAR(DateReceipt) = @Year
    GROUP BY 
        MONTH(DateReceipt)
    ORDER BY 
        MONTH(DateReceipt);
END

--EXEC CalculateTakeawayRevenueByYear '2024'





CREATE PROC CalculateTotalRevenueByYear
    @Year INT
AS
BEGIN
    SELECT 
        MONTH(DateReceipt) AS Month,
        SUM(DiscountedCost) + SUM(Cost) AS TotalRevenue
    FROM 
        (
            SELECT 
                DateReceipt,
                DiscountedCost,
                0 AS Cost
            FROM 
                TakeawayOrders
            WHERE 
                Status = 'подтверждено' AND YEAR(DateReceipt) = @Year

            UNION ALL

            SELECT 
                DateTimeReception AS DateReceipt,
                0 AS DiscountedCost,
                Cost
            FROM 
                RestaurantOrders
            WHERE 
                YEAR(DateTimeReception) = @Year
        ) AS CombinedOrders
    GROUP BY 
        MONTH(DateReceipt)
    ORDER BY 
        MONTH(DateReceipt);
END

--EXEC CalculateTotalRevenueByYear '2024'

--Определить разницу количества заказов на вынос, оформленных пользователями с аккаунтом и без аккаунта за указанный год 
CREATE PROC CompareTakeawayOrdersByAccount
    @Year INT
AS
BEGIN
    DECLARE @OrdersWithAccount INT;
    DECLARE @OrdersWithoutAccount INT;

    -- Подсчет количества заказов с аккаунтом
    SELECT @OrdersWithAccount = COUNT(*)
    FROM TakeawayOrders
    WHERE Status = 'подтверждено'
        AND YEAR(DateReceipt) = @Year
        AND Username IS NOT NULL;

    -- Подсчет количества заказов без аккаунта
    SELECT @OrdersWithoutAccount = COUNT(*)
    FROM TakeawayOrders
    WHERE Status = 'подтверждено'
        AND YEAR(DateReceipt) = @Year
        AND Username IS NULL;

    -- Вывод результатов
    SELECT 
        CountOrdersWithAccount = @OrdersWithAccount,
        CountOrdersWithoutAccount = @OrdersWithoutAccount;
END

--EXEC CompareTakeawayOrdersByAccount '2024'






--Определить разницу количества заказов на вынос, оформленных с доставкой и самовывозом за указанный год 
CREATE PROC CompareTakeawayOrdersByReceiptOption
    @Year INT
AS
BEGIN
    DECLARE @OrdersWithDelivery INT;
    DECLARE @OrdersWithPickup INT;

    -- Подсчет количества заказов с доставкой
    SELECT @OrdersWithDelivery = COUNT(*)
    FROM TakeawayOrders
    WHERE Status = 'подтверждено'
        AND YEAR(DateReceipt) = @Year
        AND ReceiptOption = 'доставка';

    -- Подсчет количества заказов с самовывозом
    SELECT @OrdersWithPickup = COUNT(*)
    FROM TakeawayOrders
    WHERE Status = 'подтверждено'
        AND YEAR(DateReceipt) = @Year
        AND ReceiptOption = 'самовывоз';

    -- Вывод результатов
    SELECT 
        CountOrdersWithDelivery = @OrdersWithDelivery,
        CountOrdersWithPickup = @OrdersWithPickup;
END

--EXEC CompareTakeawayOrdersByReceiptOption '2024'





--хранимые процедуры, осуществляющие модификацию записей в таблицах

-- хранимая процедура, осуществляющая добавление записи в таблицу Reservations
CREATE PROC AddReservation @DateTimeStart DATETIME, @NameClient NVARCHAR(30), @PhoneClient NVARCHAR(12), 
						@Comment NVARCHAR(100), @NumberGuests INT, @Status NVARCHAR(20), @TableNumber INT 
AS
BEGIN

    DECLARE @CurrentUserId INT;
    DECLARE @BookingOperatorId INT;
    -- Получаем идентификатор текущего пользователя
    SET @CurrentUserId = USER_ID();
    -- Ищем сотрудника оператора бронирования по UserId
    SELECT @BookingOperatorId = EmployeeId
    FROM EmployeesUsers
    WHERE UserId = @CurrentUserId;

	INSERT INTO Reservations (DateTimeStart, NameClient, PhoneClient, Comment, NumberGuests, Status, TableNumber, BookingOperator) 
	VALUES(@DateTimeStart, @NameClient, @PhoneClient, @Comment, @NumberGuests, @Status, @TableNumber, @BookingOperatorId)
END





-- хранимая процедура, осуществляющая обновление записи в таблице Reservations
CREATE PROC UpdateReservation @ReservationId INT, 
@DateTimeStart DATETIME, @Comment NVARCHAR(100), @NumberGuests INT, 
@Status NVARCHAR(20), @TableNumber INT 
AS
BEGIN
	
	DECLARE @CurrentUserId INT;
    DECLARE @BookingOperatorId INT;
	-- Получаем идентификатор текущего пользователя
    SET @CurrentUserId = USER_ID();
    -- Ищем сотрудника оператора бронирования по UserId
    SELECT @BookingOperatorId = EmployeeId
    FROM EmployeesUsers
    WHERE UserId = @CurrentUserId;

    UPDATE Reservations
    SET
        DateTimeStart = @DateTimeStart,
        Comment = @Comment,
        NumberGuests = @NumberGuests,
        Status = @Status,
        TableNumber = @TableNumber,
		BookingOperator = @BookingOperatorId
    WHERE ReservationId = @ReservationId;
END

--EXEC UpdateReservation 1, '2023-01-15T12:30:00', 'без комментариев', 10, 'подтверждено', 10





-- хранимая процедура, осуществляющая добавление записи в таблицу TakeawayOrders
CREATE PROC AddTakeawayOrder @NameClient NVARCHAR(30), @PhoneClient NVARCHAR(12), @Username NVARCHAR(20), @Requirements NVARCHAR(100), @PaymentMethod NVARCHAR(20), @DateOrder DATETIME, @DateReceipt DATETIME, 
							@Status NVARCHAR(20), @ReceiptOption NVARCHAR(10), @DeliveryAddress NVARCHAR(50), @DeliveryCost INT, @Courier INT
AS
BEGIN

	--проверить, если имя аккаунта существует, то по нему определить имя и телефон клиента и потом вставить это имя и телефон, ЭТО НАДО ПРОВЕРИТЬ ПЕРЕД INSERT
	DECLARE @ActualName NVARCHAR(30), @ActualPhone NVARCHAR(12);
	IF @Username IS NOT NULL
	BEGIN
		SELECT @ActualName = Name, @ActualPhone = Phone
		FROM Clients
		WHERE Username = @Username;
	END
	ELSE
		SELECT @ActualName = @NameClient, @ActualPhone = @PhoneClient

	INSERT INTO TakeawayOrders (NameClient, PhoneClient, Username, Requirements, PaymentMethod, DateOrder, DateReceipt, Status, ReceiptOption, DeliveryAddress, DeliveryCost, Courier) VALUES
	(@ActualName, @ActualPhone, @Username, @Requirements, @PaymentMethod, @DateOrder, @DateReceipt, @Status, @ReceiptOption, @DeliveryAddress, @DeliveryCost, @Courier)
END





-- хранимая процедура, осуществляющая обновление записи в таблице TakeawayOrders
-- В ОБНОВЛЕНИИ НЕ БУДЕТ USERNAME, PHONECLIENT, NAMECLIENT, ReceiptOption, ОНИ НЕ БУДУТ ОБНОВЛЯТЬСЯ
CREATE PROC UpdateTakeawayOrder @TakeawayOrderId INT, @Requirements NVARCHAR(100), @PaymentMethod NVARCHAR(20), @DateReceipt DATETIME, 
							@Status NVARCHAR(20), @DeliveryCost INT, @Courier INT
AS
BEGIN
	UPDATE TakeawayOrders
	SET Requirements = @Requirements,
		PaymentMethod = @PaymentMethod,
		DateReceipt = @DateReceipt,
		Status = @Status,
		DeliveryCost = @DeliveryCost,
		Courier = @Courier
	WHERE TakeawayOrderId = @TakeawayOrderId
END






CREATE PROC AddPositionOfTakeawayOrder @MenuPositionId INT, @Quantity INT, @TakeawayOrderId INT
AS
BEGIN
	INSERT INTO CompositionTakeawayOrder (MenuPositionId, Quantity, TakeawayOrderId)
	VALUES (@MenuPositionId, @Quantity, @TakeawayOrderId)
END
