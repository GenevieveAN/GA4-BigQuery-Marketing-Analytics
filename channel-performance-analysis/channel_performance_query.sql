
/*
Marketing Channel Performance Analysis
Purpose: Identify highest performing channels for budget allocation decisions
Data: Google Analytics Sample Data from ga_sessions_20170801 (single day snapshot)
*/


SELECT 
fullVisitorId,
channelGrouping,
trafficSource.source,
trafficSource.medium,
trafficSource.campaign
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
LIMIT 10


-- Including engagement data parameters to understand user engagement by channel --

SELECT 
    channelGrouping,
    COUNT(*) AS total_sessions,
    COUNT(totals.timeOnSite)AS Time_on_page,
    AVG(totals.pageviews) AS Average_Pages_viewed_per_session
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY channelGrouping
ORDER BY total_sessions
LIMIT 5


-- Including revenue counts to understand ROI by channel --

SELECT 
    channelGrouping,
    COUNT(*) AS total_sessions,
    COUNT(totals.timeOnSite)AS Time_on_page,
    AVG(totals.pageviews) AS Average_Pages_viewed_per_session,
    SUM(totals.transactions) AS Total_purchases,
    SUM(totals.totalTransactionRevenue) AS Total_revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY channelGrouping
ORDER BY total_sessions
LIMIT 5

  
-- Revenue in this data set is stored in microdollars. Dividing metric by 1,000,000 to obtain 00.00 values -- 
  
SELECT 
    channelGrouping,
    COUNT(*) AS total_sessions,
    COUNT(totals.timeOnSite)AS Time_on_page,
    AVG(totals.pageviews) AS Average_Pages_viewed_per_session,
    SUM(totals.transactions) AS Total_purchases,
    SUM(totals.totalTransactionRevenue/1000000) AS Total_revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY channelGrouping
ORDER BY total_sessions
LIMIT 5


  
-- Including efficiency metrics to identify the highest quality channels in terms of cost efficiency and conversions --

SELECT 
    channelGrouping,
    COUNT(*) AS total_sessions,
    COUNT(totals.timeOnSite)AS Time_on_page,
    AVG(totals.pageviews) AS Average_Pages_viewed_per_session,

    -- revenue and conversion metrics --
    SUM(totals.transactions) AS Total_purchases,-- conversion volume --
    SUM(totals.totalTransactionRevenue/1000000) AS Total_revenue,  -- Revenue (converted from microdollars)
    SUM(totals.totalTransactionRevenue/1000000)/COUNT(*) AS Revenue_per_session -- Efficiency metric --

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY channelGrouping
ORDER BY total_sessions
LIMIT 10

