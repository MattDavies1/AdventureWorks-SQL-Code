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



-- ##########################
-- ##### SALES ANALYSIS #####
-- ##########################

-- Find what Item Each SalesPerson Sells the most of
SELECT MaxItems.SalesPersonID
	, MaxItems.MostSold
	, SalesAgg.ProductID
	, c.Name
FROM (
	SELECT SalesPersonID
	, MAX(TotalSold) as MostSold
FROM (
	SELECT b.SalesPersonID
		, ProductID
		, SUM(OrderQty) as TotalSold
	FROM Sales.SalesOrderDetail as a
	JOIN Sales.SalesOrderHeader as b
	ON a.SalesOrderId = b.SalesOrderID
	WHERE SalesPersonID is NOT NULL
	GROUP BY b.SalesPersonID, ProductID
)ItemTotals
GROUP BY SalesPersonID
)MaxItems
JOIN (
	SELECT b.SalesPersonID
		, ProductID
		, SUM(OrderQty) as TotalSold
	FROM Sales.SalesOrderDetail as a
	JOIN Sales.SalesOrderHeader as b
	ON a.SalesOrderId = b.SalesOrderID
	WHERE SalesPersonID is NOT NULL
	GROUP BY b.SalesPersonID, ProductID
)SalesAgg
ON SalesAgg.SalesPersonID = MaxItems.SalesPersonID
AND SalesAgg.TotalSold = MaxItems.MostSold
JOIN Production.Product as c
ON c.ProductID = SalesAgg.ProductID

--Find the top ten items by profit generation in the history of the DB
-- Order Detail Table with Calculated Profit by LineItem
SELECT TOP 10 ProductID
	, Name
	, SUM(LineTotalProfit) as HistoricalProfit
From (
	SELECT a.ProductID as ProductID
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
)ProfitTable
GROUP BY ProductId, Name
ORDER BY HistoricalProfit DESC

--Bottom Ten
SELECT TOP 10 ProductID
	, Name
	, SUM(LineTotalProfit) as HistoricalProfit
From (
	SELECT a.ProductID as ProductID
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
)ProfitTable
GROUP BY ProductId, Name
ORDER BY HistoricalProfit ASC
;