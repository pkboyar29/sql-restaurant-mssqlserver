USE RestaurantDB

--индексы

--для таблицы Reservations

CREATE NONCLUSTERED INDEX IX_Reservations_DateTimeStart 
ON Reservations(DateTimeStart);

CREATE NONCLUSTERED INDEX IX_Reservations_Status_DateTimeStart
ON Reservations (ReservationId)
INCLUDE (Status, DateTimeStart)

--для таблицы TakeawayOrders

CREATE NONCLUSTERED INDEX IX_TakeawayOrders_Status_DateReceipt_Username
ON TakeawayOrders (Username, Status, DateReceipt);

CREATE NONCLUSTERED INDEX IX_TakeawayOrders_Status_DateReceipt_ReceiptOption
ON TakeawayOrders (ReceiptOption, Status, DateReceipt);

CREATE NONCLUSTERED INDEX IX_TakeawayOrders_Username
ON TakeawayOrders (Username);

--для таблицы CompositionTakeawayOrder
CREATE NONCLUSTERED INDEX IX_CompositionTakeawayOrder_TakeawayOrderId
ON CompositionTakeawayOrder (TakeawayOrderId) INCLUDE (MenuPositionId, Quantity);

--для таблицы Clients
CREATE NONCLUSTERED INDEX IX_Clients_Username
ON Clients (Username) INCLUDE (NumberOrders);

--для таблицы Employees
CREATE NONCLUSTERED INDEX IX_Employees_Position_DateTermination
ON Employees (EmployeeId) INCLUDE (Position, DateTermination);

--DROP INDEX IX_Reservations_Status_DateTimeStart ON Reservations

--EXEC ShowReservationCountByDay '2023-12'
