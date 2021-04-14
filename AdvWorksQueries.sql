USE [AdventureWorks2019]
GO
;

-- ##### Profit Analysis #####
-- StdCost of each product at a given time with NULLS removed
SELECT ProductID
	, StartDate
	, CASE WHEN EndDate IS NULL THEN GETDATE() ELSE EndDate END as EndDate
	, StandardCost
	, ModifiedDate
FROM Production.ProductCostHistory

-- Order Detail Table with Calculated Profit by LineItem
SELECT SalesOrderID
	, a.ProductID
	, c.Name
	, OrderQty
	, UnitPrice
	, b.StandardCost
	, a.ModifiedDate
	, UnitPrice - b.StandardCost as UnitProfit
	, OrderQty*(UnitPrice - b.StandardCost) as LineTotalProfit 
FROM Sales.SalesOrderDetail as a
JOIN (SELECT ProductID
		, StartDate
	,CASE
		WHEN EndDate IS NULL THEN GETDATE()
		ELSE EndDate
	END as EndDate
		, StandardCost
		, ModifiedDate
	FROM Production.ProductCostHistory)b
ON a.ProductID = b.ProductID
AND a.ModifiedDate >= StartDate
AND a.ModifiedDate < EndDate
JOIN Production.Product as c
ON a.ProductID = c.ProductID
WHERE SpecialOfferID = 1
ORDER BY SalesOrderID
;

-- Profit By Territory
SELECT a.TerritoryID
	, b.NAME
	, SUM(c.OrderTotalProfit)
FROM Sales.SalesOrderHeader AS a
JOIN Sales.SalesTerritory as b
ON a.TerritoryID = b.TerritoryID
INNER JOIN (
	SELECT SUM(LineTotalProfit) as OrderTotalProfit
		, SalesOrderID
	FROM dbo.vw_OrderProfitDetails
	GROUP BY SalesOrderID)c
ON a.SalesOrderID = c.SalesOrderID
WHERE a.OnlineOrderFlag = 0
GROUP BY a.TerritoryID, Name
ORDER BY SUM(c.OrderTotalProfit) DESC


