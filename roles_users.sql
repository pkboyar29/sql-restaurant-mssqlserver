USE RestaurantDB



--создание ролей

CREATE ROLE Restorator
CREATE ROLE BookingOperator
CREATE ROLE OrderOperator

--доступ к роли "ресторатор" объектов БД (хранимых процедур)

GRANT EXECUTE ON ShowReservationCountByTable TO Restorator
GRANT EXECUTE ON ShowReservationCountByDay TO Restorator
GRANT EXECUTE ON ShowMostPopularDaysOfWeekForTakeawayOrders TO Restorator
GRANT EXECUTE ON CalculateTakeawayRevenueByYear TO Restorator
GRANT EXECUTE ON CompareTakeawayOrdersByAccount TO Restorator
GRANT EXECUTE ON CompareTakeawayOrdersByReceiptOption TO Restorator
GRANT EXECUTE ON GetUserRole TO Restorator

--доступ к роли "оператор бронирования" объектов БД (хранимых процедур)

GRANT EXECUTE ON AddReservation TO BookingOperator
GRANT EXECUTE ON UpdateReservation TO BookingOperator
GRANT EXECUTE ON ShowReservations TO BookingOperator
GRANT EXECUTE ON ShowTableNumbers TO BookingOperator
GRANT EXECUTE ON GetUserRole TO BookingOperator

--доступ к роли "оператор обработки заказов" объектов БД (хранимых процедур)

GRANT EXECUTE ON AddTakeawayOrder TO OrderOperator
GRANT EXECUTE ON UpdateTakeawayOrder TO OrderOperator
GRANT EXECUTE ON AddPositionOfTakeawayOrder TO OrderOperator
GRANT EXECUTE ON GetUserRole TO OrderOperator



--создание логинов для входа на сервер (они созданы на уровне сервера, поэтому заново запускать эти команды не надо)
CREATE LOGIN sashka WITH PASSWORD = '12345'
CREATE LOGIN kursachUser WITH PASSWORD = '123'
CREATE LOGIN restAdmin WITH PASSWORD = '123abc'

--создание пользователей конкретной БД и привязка к ним логинов

CREATE USER sashka FOR LOGIN sashka
CREATE USER kursachUser FOR LOGIN kursachUser
CREATE USER restAdmin FOR LOGIN restAdmin

--привязка ролей конкретным пользователям БД

ALTER ROLE BookingOperator ADD MEMBER sashka
ALTER ROLE BookingOperator ADD MEMBER kursachUser
ALTER ROLE Restorator ADD MEMBER restAdmin


--посмотреть список ролей в определенной БД (ИЗМЕНИТЬ КОНТЕКСТ)
SELECT name, type_desc
FROM sys.database_principals
WHERE type IN ('R', 'G');



--посмотреть всех пользователей БД конкретной роли (ИЗМЕНИТЬ КОНТЕКСТ)
SELECT 
    p.name AS UserName,
    r.name AS RoleName
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals p ON rm.member_principal_id = p.principal_id
WHERE r.name = 'BookingOperator'; -- Замените на имя вашей роли




--посмотреть список логинов на сервере ms sql server
USE master;
SELECT name, type_desc, is_disabled FROM sys.sql_logins;
