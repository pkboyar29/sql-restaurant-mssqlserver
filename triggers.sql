USE RestaurantDB

-- �������, ����������� ����������� �� � ������� TakeawayOrders
CREATE TRIGGER CheckConstraintsTakeawayOrders 
ON TakeawayOrders
AFTER INSERT, UPDATE
AS
BEGIN
	-- �������� ������������ ��������� NameClient, PhoneClient � DateReceipt
    IF (SELECT COUNT(*) FROM TakeawayOrders t
        WHERE EXISTS (
            SELECT 1 FROM inserted i
            WHERE t.TakeawayOrderId <> i.TakeawayOrderId
            AND t.NameClient = i.NameClient
            AND t.PhoneClient = i.PhoneClient
            AND t.DateReceipt = i.DateReceipt
        )) > 0
    BEGIN
        RAISERROR ('���������� NameClient, PhoneClient � DataReceipt ������ ���� ���������� � ������� TakeawayOrders.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

	--���� ������ = '������������' � ReceiptOption = '��������', �� ��� ������� ��� ��������� ��������, ���������� ����������
    IF (EXISTS (SELECT 1 FROM inserted i
				WHERE i.Status = '������������' AND i.ReceiptOption = '��������'
                AND (i.Courier IS NULL OR i.DeliveryCost IS NULL)))
    BEGIN
		RAISERROR ('��� �������������� ������� � ��������� ����������� ������ � ��������� ��������.', 16, 1);
        ROLLBACK TRANSACTION
		RETURN
    END

	--���� ReceiptOption = '���������', �� ������/��������� ��������/����� �������� ������ �������������
	IF (EXISTS (SELECT 1 FROM inserted i
        WHERE i.ReceiptOption = '���������'
        AND (i.DeliveryAddress IS NOT NULL OR i.DeliveryCost IS NOT NULL OR i.Courier IS NOT NULL)))
	BEGIN
		RAISERROR ('��� ���������� �� ������ ���� ������� ����� ��������, ��������� �������� ��� ������.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END



	IF (SELECT COUNT(*) FROM deleted) <> 0
	BEGIN

		DECLARE @deliverycostDeleted INT
		DECLARE @deliverycostInserted INT
		SELECT @deliverycostDeleted = DeliveryCost FROM deleted
		SELECT @deliverycostInserted = DeliveryCost FROM inserted
		--���� ��������� �������� ����������, �� �������� ����� ��������� ������ �� �����
		IF @deliverycostInserted <> @deliverycostDeleted
		BEGIN
			DECLARE @cost2 INT
			--�������� ��������� ������ �� �����
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
				THEN @cost2 -- ���� ��� ������������, �������� ����� �� ��������
				END
			FROM TakeawayOrders t
			INNER JOIN inserted i ON t.TakeawayOrderId = i.TakeawayOrderId
			LEFT JOIN Clients c ON i.Username = c.Username
			LEFT JOIN OrderDiscounts od ON c.OrderDiscount = od.OrderDiscountId;
		END
	END

	--���� ������ �� NULL, �� ��������� ��� �� ������ � �� �� ������
	DECLARE @courier INT
	SELECT @courier = Courier FROM inserted
	IF @courier IS NOT NULL
	BEGIN
			IF EXISTS (SELECT 1 FROM inserted i 
			   JOIN Employees e ON i.Courier=e.EmployeeId
			   JOIN Positions p ON e.Position=p.PositionId
			   WHERE p.Name <> '������' OR e.DateTermination IS NOT NULL)
			BEGIN
				RAISERROR('�������� ��������� ���������� ��� ��������� ������.', 16, 1)
				ROLLBACK TRANSACTION
				RETURN
			END
	END

	--��� ���������� ������ � ����������� ����� ������ ������� � ����� ���������, ��� ����� ��������, � ������ ������� ���������� ������� ������������� �� 1
	IF (SELECT COUNT(*) FROM deleted) <> 0
	BEGIN
		DECLARE @statusDeleted NVARCHAR(20)
		DECLARE @statusInserted NVARCHAR(20)
		SELECT @statusDeleted = Status FROM deleted
		SELECT @statusInserted = Status FROM inserted

		IF @statusDeleted = '��������������' AND @statusInserted = '������������'
		BEGIN
			DECLARE @username NVARCHAR(20)
			SELECT @username = Username FROM inserted
			IF EXISTS (SELECT 1 FROM inserted i WHERE i.Username IS NOT NULL)
				UPDATE Clients SET NumberOrders=NumberOrders+1 WHERE Username = @username
		END
	END
END





--������� ��� ���������� ������ � CompositionTakeawayOrder
CREATE TRIGGER CheckConstraintsCompositionsOfTakeawayOrder
ON CompositionTakeawayOrder
AFTER INSERT
AS
BEGIN
    -- �������� ������������ ���������� MenuPositionId � TakeawayOrderId ��� ������ ������ �������
    IF (SELECT COUNT(*) 
		FROM inserted i 
		INNER JOIN CompositionTakeawayOrder c ON i.MenuPositionId = c.MenuPositionId AND i.TakeawayOrderId = c.TakeawayOrderId
		) > 1
    BEGIN
        RAISERROR ('��������� MenuPositionId � TakeawayOrderId ������ ���� ���������� � ������� CompositionTakeawayOrder.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

	-- �������� ����������� ������� ���� � ������ ������
	IF EXISTS (
		SELECT 1
		FROM inserted i
		INNER JOIN MenuPositions m ON i.MenuPositionId = m.MenuPositionId
		WHERE m.Availability = 0
	)
	BEGIN
		RAISERROR ('������ �������� ������� ����, ������� ���������� � ������ ������.', 16, 1)
		ROLLBACK TRANSACTION
		RETURN
	END

    -- ���������� ��������� ����
    UPDATE c
    SET TotalPrice = m.Price * i.Quantity
    FROM CompositionTakeawayOrder c
    INNER JOIN inserted i ON c.MenuPositionId = i.MenuPositionId
    INNER JOIN MenuPositions m ON c.MenuPositionId = m.MenuPositionId
	WHERE c.TakeawayOrderId IN (SELECT TakeawayOrderId FROM inserted)

	DECLARE @cost2 INT

    -- �������������� ���������� ��������� � ������ �� ����� � ����
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





-- �������, ����������� ����������� �� � ������� Reservations
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
		--���������� ������ ������ ���� ������ ��� ����� ���������� ���� � �������
		IF EXISTS (SELECT 1 FROM inserted i INNER JOIN Tabless t ON i.TableNumber = t.TableNumber WHERE i.NumberGuests > t.NumberSeats)
		BEGIN
			RAISERROR('���������� ������ ��������� ���������� ���� � �������.', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END
	
		--���� ������ � ������ ������ ������� �� ��������, �� �� �� ����� ��������� ��� � ������������
		IF EXISTS (SELECT 1
				   FROM inserted i
				   JOIN Tabless t ON i.TableNumber = t.TableNumber
				   WHERE t.Availability = 0)
		BEGIN
			RAISERROR('������ � ������ ������ ������� �� ��������.', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END
	END

    -- ���� ������ = '������������', �� ������� ������������ ���� TableNumber
    IF @status = '������������' AND @table_number IS NULL
    BEGIN
        RAISERROR('���� TableNumber ����������� ��� ������� ''������������''.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END

	--��������� ���������� ������ ���� ��������� ������������", � ����� ��������� �� ������ ���� ������
	IF EXISTS (SELECT 1 FROM inserted i 
			   JOIN Employees e ON i.BookingOperator=e.EmployeeId
			   JOIN Positions p ON e.Position=p.PositionId
			   WHERE p.Name <> '�������� ������������' OR e.DateTermination IS NOT NULL)
	BEGIN
		RAISERROR('�������� ��������� ���������� ��� ��������� ������.', 16, 1)
	    ROLLBACK TRANSACTION
	    RETURN
	END
END
