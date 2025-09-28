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
```

### 2. Funnel Stage Mapping
Based on Universal Analytics Enhanced Ecommerce documentation:

- Action Type 1: Product views/clicks
- Action Type 2: Add to cart
- Action Type 3: Remove from cart
- Action Type 4: Checkout initiation (rarely used)
- Action Type 5: Checkout steps (payment, shipping)
- Action Type 6: Purchase completion



### 3. Complete Funnel Analysis Query
```sql
WITH funnel_data AS (
  SELECT 
    channelGrouping,
    SUM(CASE WHEN hit.eCommerceAction.action_type = '1' THEN 1 ELSE 0 END) as product_views,
    SUM(CASE WHEN hit.eCommerceAction.action_type = '2' THEN 1 ELSE 0 END) as add_to_cart,
    SUM(CASE WHEN hit.eCommerceAction.action_type = '3' THEN 1 ELSE 0 END) as remove_from_cart,
    SUM(CASE WHEN hit.eCommerceAction.action_type = '4' THEN 1 ELSE 0 END) as checkout_start,
    SUM(CASE WHEN hit.eCommerceAction.action_type = '5' THEN 1 ELSE 0 END) as checkout_steps,
    SUM(CASE WHEN hit.eCommerceAction.action_type = '6' THEN 1 ELSE 0 END) as purchases
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
  UNNEST(hits) AS hit
  WHERE hit.eCommerceAction.action_type IS NOT NULL
  GROUP BY channelGrouping
)
SELECT 
  channelGrouping,
  product_views,
  add_to_cart,
  checkout_steps,
  purchases,
  -- Conversion metrics
  ROUND(100.0 * add_to_cart / NULLIF(product_views, 0), 1) as view_to_cart_rate,
  ROUND(100.0 * checkout_steps / NULLIF(add_to_cart, 0), 1) as cart_to_checkout_rate,
  ROUND(100.0 * purchases / NULLIF(checkout_steps, 0), 1) as checkout_completion_rate,
  ROUND(100.0 * purchases / NULLIF(product_views, 0), 1) as overall_conversion_rate,
  -- Drop-off analysis
  (add_to_cart - checkout_steps) as lost_before_checkout,
  (checkout_steps - purchases) as lost_during_checkout
FROM funnel_data
WHERE product_views > 0
ORDER BY overall_conversion_rate DESC
```
### Key Findings
Funnel Performance by Channel
| Channel | View→Cart | Cart→Checkout | Checkout→Purchase | Overall Conversion |
|---------|-----------|---------------|-------------------|-------------------|
| **Display** | 76.5% | 38.5% | 40.0% | 11.8% |
| **Referral** | 72.7% | 54.2% | 28.7% | 11.3% |
| **Direct** | 82.6% | 16.0% | 40.0% | 5.3% |
| **Paid Search** | 73.5% | 8.0% | 33.3% | 2.0% |
| **Organic Search** | 73.4% | 14.8% | 16.9% | 1.8% |

ChannelView→CartCart→CheckoutCheckout→PurchaseOverall ConversionDisplay76.5%38.5%40.0%11.8%Referral72.7%54.2%28.7%11.3%Direct82.6%16.0%40.0%5.3%Paid Search73.5%8.0%33.3%2.0%Organic Search73.4%14.8%16.9%1.8%
Critical Discovery: Universal Cart-to-Checkout Bottleneck
ALL channels show "Cart to Checkout" as the biggest drop-off point:

Organic Search: Lost 410 users (85% drop-off)
Direct: Lost 236 users (84% drop-off)
Referral: Lost 171 users (46% drop-off)
Paid Search: Lost 69 users (92% drop-off)

Channel-Specific Insights

Referral Traffic

Best at moving users from cart to checkout (54.2%)
High cart abandonment rate (66.8% remove items)
Lower checkout completion (28.7%) suggests price sensitivity


Direct Traffic

Highest view-to-cart conversion (82.6%)
Massive cart-to-checkout drop (84% lost)
Strong checkout completion (40%) for those who start


Organic Search

Highest volume but lowest quality
85% abandon before checkout
Lowest checkout completion (16.9%)



Recommendations
Priority 1: Fix Cart-to-Checkout Transition (Immediate)
The universal drop-off pattern indicates a site-wide barrier. Investigate:

Forced account creation - Implement guest checkout
Hidden shipping costs - Show shipping calculator in cart
Trust issues - Add security badges, return policy visibility
Technical issues - Test checkout button functionality across devices

Priority 2: Channel-Specific Optimizations
For Referral (High-value traffic):

Implement cart abandonment email campaigns
Test free shipping thresholds
Add urgency messaging for users with items in cart

For Direct (Brand-loyal traffic):

Simplify checkout initiation
Add express checkout options (Apple Pay, PayPal)
These users trust you but face friction

For Paid Channels:

Reassess targeting - 2% conversion doesn't justify spend
Reallocate budget to referral partnerships

Expected Impact
Improving cart-to-checkout conversion by just 10% would yield:

Referral: +17 purchases (29% increase)
Direct: +24 purchases (133% increase)
Organic: +41 purchases (342% increase)

Technical Skills Demonstrated

SQL: Complex queries with CTEs, CASE statements, UNNEST operations
Data Analysis: Funnel metrics, conversion rate optimization
Problem-Solving: Identified hidden bottlenecks in customer journey
Business Acumen: Translated data insights into actionable recommendations

How to Use This Analysis

Clone this repository
Replace the BigQuery dataset with your own Google Analytics data
Adjust action_type mappings based on your implementation
Run the analysis to identify your specific bottlenecks
Implement recommendations and measure impact

Next Steps

Temporal analysis: Track funnel improvements over time
Segmentation: Analyze by device type, new vs. returning users
Revenue impact: Calculate lost revenue at each drop-off point
A/B testing: Measure impact of checkout optimizations


This analysis demonstrates how funnel analysis can reveal hidden conversion barriers and prioritize optimization efforts for maximum business impact.

