# Voltify customer analysis

Data analysis project using BigQuery to uncover patterns in new vs. returning customer behavior for a small tech retailer. Includes cohort segmentation, product mix evolution, time-to-repeat-purchase analysis, return rate insights, and actionable growth hypotheses.

<p align="center"><img width="600" alt="image" src="https://github.com/user-attachments/assets/6015ca94-1b50-42db-862c-e55031e249eb"></p>
                     
## Analysis Objectives
The goal of this analysis is to help Customer Insights & Retention Team to examine differences in purchasing behavior between new and returning customers, identify factors that influence customer retention, and uncover opportunities to increase lifetime value. Secondary beneficiaries are Marketing (targeted acquisition) and Product Management (offer structure, installment programs).

#### Key objectives
• Compare product mix and price points between customer segments.<br>
• Understand timing patterns for first and repeat purchases.<br>
• Assess operational performance metrics (delivery & shipping times).<br>
• Analyze return rates by customer type and product category.<br>

#### Key dimensions analyzed
• Customer type: new vs. returning.<br>
• Purchase stage: first (ond only) purchase of a one-time customer, first purchase and subsequent purchases of returning users.<br>
• Product category: top-value items vs. all others.<br>
• Order dates & intervals: registration to first purchase, first to second purchase.<br>
• Operational KPIs: delivery time, shipping time.<br>

## Summary of Insights

### Revenue Contribution by Customer Type: returning users are small, but valuable cohort

Although returning customers represent only 5% of the total customer base, they account for 11% of all orders (and items purchased) and contribute 15% of total revenue.
This disproportionate impact highlights the high value and profitability of the returning customer cohort. Even a small increase in their share could translate into a significant boost in overall revenue, making it essential to understand their behavior, motivations, and retention drivers.

<img width="800" alt="image" src="https://github.com/user-attachments/assets/f5dc07b9-cd2d-4f60-9372-85a1fbc9db37">

Historical data shows that Voltify's returning customers generate nearly three times more revenue per customer compared to new customers ($833 vs. $291).
This difference is driven not only by the higher number of orders (returning customers place on average 2 orders per user) but also by a significantly higher AOV — about 40% higher for returning customers.
The number of items per order remains almost identical between cohorts, suggesting that the revenue gap is primarily due to higher spend per item and repeat purchases, not larger baskets.

<img width="800" alt="image" src="https://github.com/user-attachments/assets/b86f0683-8679-4a0e-b21b-6a4c88af5b5d">

### Product Choice Evolution: lower-priced preferences of one-time customers vs. higher-priced trends in returning customers

Users who become returning customers tend to start with slightly higher-priced purchases, and their spending increases over time. The top four most expensive products account for 50% of returning customer purchases compared to 25% for new customers. Moreover, returning customers are not a homogeneous cohort: while their first order already contains more high-value items than those typically chosen by one-time buyers (almost 30% share for the top four items vs. 25% for new users), once they become loyal, the share of high-value products in their second and subsequent orders jumps to 70%.

<img width="1000" alt="image" src="https://github.com/user-attachments/assets/2d6233a9-7c54-4b54-8682-848411b1bcf5" />

#### <ins>Key recommendations</ins>:
• **Premium-First Acquisition Strategy**: invest in targeted marketing highlighting premium offerings to attract high-value first-time buyers. While their initial premium adoption (29%) is only 13% higher than average buyers, these users show **3X greater premium spending acceleration** in subsequent purchases - driving 71% of loyalist spending to premium products. <br><br>
• **Tiered Premium Loyalty Program**: implement tiered rewards for premium purchases to amplify the observed 70% premium share in later purchases. For exampple: free shipping ($400+ orders) → complimentary tech support (2+ premium items) → annual upgrade credits (3+ premium items)<br>

### Operational Performance Metrics: long decision cycles create remarketing opportunity; delivery speed is not a churn driver

#### Registration to purchase
We observe a notable delay between registration and the first purchase - 75 days for new users and 82 days for those who eventually become returning customers. This suggests that purchases may carry significant weight for our customers, who take time to evaluate their decision. It could also indicate strong brand awareness: users register without buying immediately but intend to purchase from us later.

#### First to second purchase
For returning customers, the average time between the first and second purchase is 222 days, though 30% make their second purchase within 45 days and 50% within 110 days. This points to a clear opportunity for targeted marketing: focusing on first-time purchasers within the first 45–110 days could accelerate repeat buying, especially by promoting complementary or upgraded products.

#### First to any subsequential purchase
While our initial analysis focused specifically on the time to second purchase (avg 222 days), the cohort retention heatmap below reveals broader patterns in long-term customer engagement. It tracks what percentage of customers acquired in each quarter made at least one purchase in subsequent quarters, providing a complete view of loyalty development beyond just the first repeat transaction.

<img width="1000" alt="image_2025-08-15_15-29-19" src="https://github.com/user-attachments/assets/751a34d7-bb52-4f76-8fa0-794da7852e5f" /><br>

While Voltify’s loyalists (top 5% by purchase frequency) already generate 21% of cohort revenue - 2.3X more than average customers - this analysis reveals significant headroom. Mature electronics retailers achieve 30–40% revenue share from their loyalists, suggesting Voltify still has room to improve. In our initial findings, returning users place an average of 2 orders. Encouraging customers to increase this to 2.5 orders per returning customer would lift cohort revenue and raise LTV for returning customers to as much as $1,000.

#### Delivery & shipping time
Delivery and shipping performance is consistent across cohorts. The average delivery time is 7.5 days for both new and returning customers, while shipping is slightly faster for returning customers (1.99 vs. 2.06 days). This suggests that delivery experience is unlikely to be the main factor preventing one-time customers from becoming repeat buyers.

#### <ins>Key recommendations</ins>:
• **Points-for-Orders Loyalty Program**: introduce a simple program where every purchase earns redeemable points. Bonus multipliers on the 2nd and 3rd orders encourage customers to return, driving the average order count beyond 2.5 per returning user.<br><br>
• **110-Day Loyalty Acceleration Program**: trigger personalized complementary product offers (e.g., "Macbook stand for your new laptop") between days 45-110 post-first-purchase.<br><br>
• **First-Purchase Activation Program**: engage registered users who have not yet purchased with tailored product education, limited-time offers, and surveys to uncover purchase barriers. This reduces the 75–82 day lag to first order, accelerates revenue capture, and provides insights to refine onboarding and product positioning.<br>

### Return Rate Analysis: loyal customers are less likely to return purchased products

The return rate differs notably between new and returning customers - 5.2% vs. 3.5%, respectively. This could indicate either dissatisfaction with product quality or post-purchase regret, particularly for higher-priced items. To pinpoint the root causes, further analysis is needed (e.g., examining customer-stated return reasons).

<img width="1000" alt="image" src="https://github.com/user-attachments/assets/34111262-6a3f-4850-922e-8fbed4ed0ce6">

Our data shows that high-priced products tend to have higher return rates across both cohorts. For example, MacBook Air shows ~11% returns in both cohorts, ThinkPad Laptop declines from 12% (new) to 7% (returning). A notable exception is iPhone, which rises from 7% (new) to 11% (returning). Interestingly, returning customers exhibit lower return rates than new customers for nearly all categories, with two exceptions: Apple iPhone and Samsung Charging Cable Pack, where their rates slightly exceed those of new buyers.

The primary working hypothesis is that expensive purchases trigger regret in some customers, prompting returns. One potential countermeasure is offering an installment payment program, which could reduce perceived financial risk and lower return rates for high-ticket items.

Our main focus should be on reducing the return rate among new customers, because, as we see, most of the cost of returns corresponds to this cohort (due to higher order volumes and, in some cases, higher return rates). Specifically, we should focus on MacBook Air laptops and gaming monitors.

#### <ins>Key recommendations</ins>:
• **Laptop Return Reduction**: for both laptops (highest return categories) offer pre-purchase comparison guides, live demos, and extended trial options to better align expectations with product experience.<br><br>
• **Proactive Onboarding for High-Value Orders**: flag large first-time purchases and trigger customer service outreach to confirm expectations and resolve concerns early.<br><br>
• **Installment Payment Program**: provide flexible financing options to reduce upfront cost pressure and minimize returns linked to buyer’s remorse.<br>

## Growth opportunities

#### Hypothesis 1 — Predictive targeting
Use first-purchase product mix to identify potential high-value customers early and offer tailored upsell campaigns.
Expected impact: If just 10% of high-potential new customers convert to returning buyers, revenue could increase significantly due to their higher lifetime value.

#### Hypothesis 2 — Return rate reduction
Investigate reasons behind high return rates for specific categories and address them through product improvements, better pre-purchase information, or offering an installment payment program.
Expected impact: Reducing first-purchase returns could meaningfully increase repeat purchase rates, as customers with a positive initial experience are more likely to buy again.

#### Hypothesis 3 — Purchase timing strategies
Segment customers by time between purchases to tailor follow-up offers.
Fast returners (<45 days): Promote accessory bundles and complementary products to build basket size.
Slow returners (>109 days): Offer premium product deals or installment payment plans to encourage higher-value purchases.
Additionally, proactively reach out to new customers with high-value orders to confirm expectations and address concerns early, reducing the likelihood of returns.
Expected impact: Optimizing offer timing could increase purchase frequency and average order value across both new and returning customer segments.
