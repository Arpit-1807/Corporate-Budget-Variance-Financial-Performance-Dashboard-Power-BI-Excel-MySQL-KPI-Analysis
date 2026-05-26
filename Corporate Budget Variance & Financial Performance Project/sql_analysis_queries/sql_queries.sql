Select * From finance_sample_data;

# Query 1. - Compute gross profit margin by segment
Select
	Segment, 
    Round(Sum(Profit)/Sum(Gross_Sales),2) AS Gross_Profit_Margin
From
	finance_sample_data
Group By 
	Segment
Order By 
	Gross_Profit_Margin DESC;
# Business Insight: Helps identify healthy business areas.

# Query 2. - Calculate month-over-month revenue growth
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(Date, '%Y-%m') AS month,
        SUM(Sales) AS revenue
    FROM finance_sample_data
    GROUP BY month
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / 
        NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 
    2) AS mom_growth_pct
FROM MonthlyRevenue
ORDER BY month;
# Business Insight: Helps Analyze or Identify Month over Month Growth Performance

# Query 3. - Identify top 3 cost-driving segments.
Select
	Segment, COGS
From
	finance_sample_data
Order By
	COGS DESC
Limit
	3;
    
# Query 4. - Which segment generates the highest profit contribution?
Select
	Segment, 
    Sum(Profit) AS Profit
From
	finance_sample_data
Group By
	Segment
Order By
	 Profit DESC;
# Business Insight: Helps management identify the most profitable customer/business segment.

# Query 5. - Which products have the highest and lowest profitability?
Select
	Product,
    Sum(Profit) AS Profit,
    Sum(Sales) AS Revenue,
    Round(Sum(Profit/Sales),2) AS Profit_Margin
From
	finance_sample_data
Group BY
	Product
Order By
	Profit_Margin DESC;
# Business Insight: Identifies star products vs underperforming products.

# Query 6. - Which countries contribute most to total revenue and profit?
Select
	Country,
    Sum(Sales) AS Total_Revenue,
    Sum(Profit) AS Total_Profit
From
	finance_sample_data
Group By
	Country
Order By
	Total_Profit DESC;
# Business Insight: Important for geographic expansion and resource allocation.
	
# Query 7. - Which month had the highest revenue and profit?
Select
	DATE_FORMAT(Date, '%Y-%m') AS Month,
    Sum(Sales) AS Total_Revenue,
    Sum(Profit) AS Total_Profit
From
	finance_sample_data
Group By 
	Month
Order By
	Total_Profit DESC;
# Business Insight: Detects seasonal business peaks.

# Query 8. - Analyze discount impact on profitability
Select
	Discount_Band,
    Round(Avg(Discounts),2) AS Avg_Disc_Perc,
    Round(Sum(Profit/Sales),2) AS Profit_Margin
From
	finance_sample_data
Group By
	Discount_Band
Order By
	Profit_Margin DESC
Limit 3;
    
# Query 9. - Calculate operating efficiency by segment
Select
	Segment,
    Round(Sum(Profit/COGS),2) AS Operating_Efficiency
From
	finance_sample_data
Group By
	Segment
Order By
	Operating_Efficiency DESC;
# Business Insight: Shows how efficiently segments generate profit from operational cost.
	
# Query 10. - Which products have declining profitability over time?
WITH MonthlyProfit AS (
    SELECT 
        Product,
        DATE_FORMAT(Date, '%Y-%m') AS Sales_Month,
        SUM(Profit) AS Total_Profit
    FROM finance_sample_data
    GROUP BY 
        Product, 
        DATE_FORMAT(Date, '%Y-%m')
),
ProfitComparison AS (
    SELECT 
        Product,
        Sales_Month,
        Total_Profit,
        -- Get the profit of the previous month for the same product
        LAG(Total_Profit, 1) OVER (
            PARTITION BY Product 
            ORDER BY Sales_Month
        ) AS Previous_Month_Profit
    FROM MonthlyProfit
)
-- Filter for products whose profit is lower than the previous month
SELECT 
    Product,
    Sales_Month,
    Total_Profit AS Current_Profit,
    Previous_Month_Profit,
    (Total_Profit - Previous_Month_Profit) AS Profit_Decline_Amount
FROM ProfitComparison
WHERE Total_Profit < Previous_Month_Profit
ORDER BY 
    Product, 
    Sales_Month;
# Business Insight: Identifies risky products before losses increase.

# Query 11. - Average selling price analysis
-- Which products sell at premium pricing?
-- Which segments rely on volume sales
Select
	Segment,
    Product,
    Round(Avg(Sale_Price),2) AS Avg_Sale_Price
From
	finance_sample_data
Group By
	Segment,
    Product
Order By
	Avg_Sale_Price DESC;
    