# E-Commerce Funnel Analysis with BigQuery

## Project Overview
Deep-dive analysis of customer drop-off patterns across marketing channels using Google Analytics sample data to identify conversion bottlenecks and optimization opportunities.

## Business Problem
Marketing teams need to understand:
- Where customers abandon the purchase process
- Which channels drive efficient conversions vs. just traffic
- How to prioritize optimization efforts for maximum ROI

## Technical Approach

### 1. Data Exploration
Discovered nested data structure in Google Analytics BigQuery dataset:
```sql
-- Understanding the nested hits array
SELECT 
  hit.eCommerceAction.action_type,
  COUNT(*) as action_count
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
UNNEST(hits) AS hit
WHERE hit.eCommerceAction.action_type IS NOT NULL
GROUP BY hit.eCommerceAction.action_type
