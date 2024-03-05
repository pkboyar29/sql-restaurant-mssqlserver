USE RestaurantDB

-- триггер, реализующий процедурные ОЦ в таблице TakeawayOrders
CREATE TRIGGER CheckConstraintsTakeawayOrders 
ON TakeawayOrders
AFTER INSERT, UPDATE
AS
BEGIN
	-- проверка уникальности сочетания NameClient, PhoneClient и DateReceipt
    IF (SELECT COUNT(*) FROM TakeawayOrders t
        WHERE EXISTS (
            SELECT 1 FROM inserted i
            WHERE t.TakeawayOrderId <> i.TakeawayOrderId
            AND t.NameClient = i.NameClient
            AND t.PhoneClient = i.PhoneClient
            AND t.DateReceipt = i.DateReceipt
        )) > 0
    BEGIN
        RAISERROR ('Комбинация NameClient, PhoneClient и DataReceipt должна быть уникальной в таблице TakeawayOrders.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

	--если статус = 'подтверждено' и ReceiptOption = 'доставка', но нет курьера или стоимости доставки, откатываем транзакцию
    IF (EXISTS (SELECT 1 FROM inserted i
				WHERE i.Status = 'подтверждено' AND i.ReceiptOption = 'доставка'
                AND (i.Courier IS NULL OR i.DeliveryCost IS NULL)))
    BEGIN
		RAISERROR ('Для подтвержденных заказов с доставкой обязательны курьер и стоимость доставки.', 16, 1);
        ROLLBACK TRANSACTION
		RETURN
    END

	--если ReceiptOption = 'самовывоз', то курьер/стоимость доставки/адрес доставки должны отсутствовать
	IF (EXISTS (SELECT 1 FROM inserted i
        WHERE i.ReceiptOption = 'самовывоз'
        AND (i.DeliveryAddress IS NOT NULL OR i.DeliveryCost IS NOT NULL OR i.Courier IS NOT NULL)))
	BEGIN
		RAISERROR ('Для самовывоза не должны быть указаны адрес доставки, стоимость доставки или курьер.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END



	IF (SELECT COUNT(*) FROM deleted) <> 0
	BEGIN

		DECLARE @deliverycostDeleted INT
		DECLARE @deliverycostInserted INT
		SELECT @deliverycostDeleted = DeliveryCost FROM deleted
		SELECT @deliverycostInserted = DeliveryCost FROM inserted
		--если стоимость доставки изменилась, то изменяем общую стоимость заказа на вынос
		IF @deliverycostInserted <> @deliverycostDeleted
		BEGIN
			DECLARE @cost2 INT
			--изменить стоимость заказа на вынос
			UPDATE t
			SET 
			@cost2 = (SELECT SUM(cto.TotalPrice) FROM CompositionTakeawayOrder cto WHERE cto.TakeawayOrderId = t.TakeawayOrderId)
			+ ISNULL((SELECT Cost FROM DeliveryCosts WHERE DeliveryCostId = t.DeliveryCost), 0),
			Cost = @cost2,
			DiscountedCost = 
			CASE 
				WHEN i.Username IS NOT NULL 
				THEN @cost2 - (@cost2 * od.Percentage / 100)
				WHEN i.Username IS NULL
				THEN @cost2 -- Если нет пользователя, оставить такое же значение
				END
			FROM TakeawayOrders t
			INNER JOIN inserted i ON t.TakeawayOrderId = i.TakeawayOrderId
			LEFT JOIN Clients c ON i.Username = c.Username
			LEFT JOIN OrderDiscounts od ON c.OrderDiscount = od.OrderDiscountId;
		END
	END

	--если курьер не NULL, то проверить что он курьер и он не уволен
	DECLARE @courier INT
	SELECT @courier = Courier FROM inserted
	IF @courier IS NOT NULL
	BEGIN
			IF EXISTS (SELECT 1 FROM inserted i 
			   JOIN Employees e ON i.Courier=e.EmployeeId
			   JOIN Positions p ON e.Position=p.PositionId
			   WHERE p.Name <> 'курьер' OR e.DateTermination IS NOT NULL)
			BEGIN
				RAISERROR('Неверная должность сотрудника или сотрудник уволен.', 16, 1)
				ROLLBACK TRANSACTION
				RETURN
			END
	END

	--При добавлении записи с заполнением этого логина клиента а также указанием, что заказ завершен, у самого клиента количество заказов увеличивается на 1
	IF (SELECT COUNT(*) FROM deleted) <> 0
	BEGIN
		DECLARE @statusDeleted NVARCHAR(20)
		DECLARE @statusInserted NVARCHAR(20)
		SELECT @statusDeleted = Status FROM deleted
		SELECT @statusInserted = Status FROM inserted

		IF @statusDeleted = 'обрабатывается' AND @statusInserted = 'подтверждено'
		BEGIN
			DECLARE @username NVARCHAR(20)
			SELECT @username = Username FROM inserted
			IF EXISTS (SELECT 1 FROM inserted i WHERE i.Username IS NOT NULL)
				UPDATE Clients SET NumberOrders=NumberOrders+1 WHERE Username = @username
		END
	END
END





--триггер при добавлении записи в CompositionTakeawayOrder
CREATE TRIGGER CheckConstraintsCompositionsOfTakeawayOrder
ON CompositionTakeawayOrder
AFTER INSERT
AS
BEGIN
    -- Проверка уникальности комбинации MenuPositionId и TakeawayOrderId для каждой строки вставки
    IF (SELECT COUNT(*) 
		FROM inserted i 
		INNER JOIN CompositionTakeawayOrder c ON i.MenuPositionId = c.MenuPositionId AND i.TakeawayOrderId = c.TakeawayOrderId
		) > 1
    BEGIN
        RAISERROR ('Сочетание MenuPositionId и TakeawayOrderId должно быть уникальным в таблице CompositionTakeawayOrder.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

	-- Проверка доступности позиции меню в данный момент
	IF EXISTS (
		SELECT 1
		FROM inserted i
		INNER JOIN MenuPositions m ON i.MenuPositionId = m.MenuPositionId
		WHERE m.Availability = 0
	)
	BEGIN
		RAISERROR ('Нельзя добавить позицию меню, которая недоступна в данный момент.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

    -- обновление суммарной цены
    UPDATE c
    SET TotalPrice = m.Price * i.Quantity
    FROM CompositionTakeawayOrder c
    INNER JOIN inserted i ON c.MenuPositionId = i.MenuPositionId
    INNER JOIN MenuPositions m ON c.MenuPositionId = m.MenuPositionId
	WHERE c.TakeawayOrderId IN (SELECT TakeawayOrderId FROM inserted)

	DECLARE @cost2 INT

    -- автоматическое вычисление стоимости в заказе на вынос с нуля
    UPDATE t
    SET 
	@cost2 = (SELECT SUM(cto.TotalPrice) FROM CompositionTakeawayOrder cto WHERE cto.TakeawayOrderId = t.TakeawayOrderId)
	+ ISNULL((SELECT Cost FROM DeliveryCosts WHERE DeliveryCostId = t.DeliveryCost), 0),
	Cost = @cost2,
	DiscountedCost = 
	CASE WHEN t.Username IS NOT NULL
		THEN @cost2 - (@cost2 * od.Percentage / 100)
		WHEN t.Username IS NULL
		THEN @cost2
		END
    FROM TakeawayOrders t
    INNER JOIN inserted i ON t.TakeawayOrderId = i.TakeawayOrderId
	LEFT JOIN Clients c ON t.Username = c.Username
	LEFT JOIN OrderDiscounts od ON c.OrderDiscount = od.OrderDiscountId
END





-- триггер, реализующий процедурные ОЦ в таблице Reservations
CREATE TRIGGER CheckConstraintsReservations
ON Reservations
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @table_number INT
	DECLARE @status NVARCHAR(20)
	SELECT @table_number = TableNumber, @status = Status FROM inserted
	IF @table_number IS NOT NULL
	BEGIN
		--Количество гостей должно быть меньше или равно количеству мест в столике
		IF EXISTS (SELECT 1 FROM inserted i INNER JOIN Tabless t ON i.TableNumber = t.TableNumber WHERE i.NumberGuests > t.NumberSeats)
		BEGIN
			RAISERROR('Количество гостей превышает количество мест в столике.', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END
	
		--Если столик в данный момент времени не доступен, то мы не можем привязать его к бронированию
		IF EXISTS (SELECT 1
				   FROM inserted i
				   JOIN Tabless t ON i.TableNumber = t.TableNumber
				   WHERE t.Availability = 0)
		BEGIN
			RAISERROR('Столик в данный момент времени не доступен.', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END
	END

    -- Если статус = 'подтверждено', то сделать обязательным поле TableNumber
    IF @status = 'подтверждено' AND @table_number IS NULL
    BEGIN
        RAISERROR('Поле TableNumber обязательно для статуса ''подтверждено''.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

	--должность сотрудника должна быть “оператор бронирования", а также сотрудник не должен быть уволен
	IF EXISTS (SELECT 1 FROM inserted i 
			   JOIN Employees e ON i.BookingOperator=e.EmployeeId
			   JOIN Positions p ON e.Position=p.PositionId
			   WHERE p.Name <> 'оператор бронирования' OR e.DateTermination IS NOT NULL)
	BEGIN
		RAISERROR('Неверная должность сотрудника или сотрудник уволен.', 16, 1)
	    ROLLBACK TRANSACTION
	    RETURN
	END
END
