USE [AdventureWorks2019]
GO
;

-- Find which product each sales person sells the most of


-- ##### Profit Analysis #####

-- StdCost of each product at a given time with NULLS removed
SELECT ProductID
	, StartDate
,CASE
	WHEN EndDate IS NULL THEN GETDATE()
	ELSE EndDate
END as EndDate
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
-- WORKING AREA

SELECT * FROM SalesOrder


-- Profit By Sale
SELECT SalesOrderID
	, SUM(LineTotalProfit)
FROM dbo.vw_OrderProfitDetails
GROUP BY SalesOrderID



