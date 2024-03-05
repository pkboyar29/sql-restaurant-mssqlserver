USE RestaurantDB



--�������� �����

CREATE ROLE Restorator
CREATE ROLE BookingOperator
CREATE ROLE OrderOperator

--������ � ���� "����������" �������� �� (�������� ��������)

GRANT EXECUTE ON ShowReservationCountByTable TO Restorator
GRANT EXECUTE ON ShowReservationCountByDay TO Restorator
GRANT EXECUTE ON ShowMostPopularDaysOfWeekForTakeawayOrders TO Restorator
GRANT EXECUTE ON CalculateTakeawayRevenueByYear TO Restorator
GRANT EXECUTE ON CompareTakeawayOrdersByAccount TO Restorator
GRANT EXECUTE ON CompareTakeawayOrdersByReceiptOption TO Restorator
GRANT EXECUTE ON GetUserRole TO Restorator

--������ � ���� "�������� ������������" �������� �� (�������� ��������)

GRANT EXECUTE ON AddReservation TO BookingOperator
GRANT EXECUTE ON UpdateReservation TO BookingOperator
GRANT EXECUTE ON ShowReservations TO BookingOperator
GRANT EXECUTE ON ShowTableNumbers TO BookingOperator
GRANT EXECUTE ON GetUserRole TO BookingOperator

--������ � ���� "�������� ��������� �������" �������� �� (�������� ��������)

GRANT EXECUTE ON AddTakeawayOrder TO OrderOperator
GRANT EXECUTE ON UpdateTakeawayOrder TO OrderOperator
GRANT EXECUTE ON AddPositionOfTakeawayOrder TO OrderOperator
GRANT EXECUTE ON GetUserRole TO OrderOperator



--�������� ������� ��� ����� �� ������ (��� ������� �� ������ �������, ������� ������ ��������� ��� ������� �� ����)
CREATE LOGIN sashka WITH PASSWORD = '12345'
CREATE LOGIN kursachUser WITH PASSWORD = '123'
CREATE LOGIN restAdmin WITH PASSWORD = '123abc'

--�������� ������������� ���������� �� � �������� � ��� �������

CREATE USER sashka FOR LOGIN sashka
CREATE USER kursachUser FOR LOGIN kursachUser
CREATE USER restAdmin FOR LOGIN restAdmin

--�������� ����� ���������� ������������� ��

ALTER ROLE BookingOperator ADD MEMBER sashka
ALTER ROLE BookingOperator ADD MEMBER kursachUser
ALTER ROLE Restorator ADD MEMBER restAdmin


--���������� ������ ����� � ������������ �� (�������� ��������)
SELECT name, type_desc
FROM sys.database_principals
WHERE type IN ('R', 'G');



--���������� ���� ������������� �� ���������� ���� (�������� ��������)
SELECT 
    p.name AS UserName,
    r.name AS RoleName
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals p ON rm.member_principal_id = p.principal_id
WHERE r.name = 'BookingOperator'; -- �������� �� ��� ����� ����




--���������� ������ ������� �� ������� ms sql server
USE master;
SELECT name, type_desc, is_disabled FROM sys.sql_logins;
