# E-Commerce Growth Analytics: A/B Testing & Customer Persona Segmentation

End-to-end project analyzing **Customer conversion** and **engagement across website experiments**, tracking **user behavior** to measure how different **A/B test variations** impact clicks, add-to-cart actions, and completed purchases. Using SQL, Python, and Power BI, aggregated and cleaned user sessions, orders, and experiment data into a single analysis-ready table, enabling detailed A/B test analysis and actionable insights for improving engagement, purchases, and revenue growth.

**Note:** This project uses a mock dataset designed to simulate realistic performance. Company names and figures are for demonstration purposes only. 


## Key Highlights
- **PostgreSQL Data Aggregation & Cleaning:** Built a clean, analysis-ready table by combining sessions, users, orders, and experiments tables using `CTEs`; handled boolean    event tracking, null values `(COALESCE)`, distinct counts, and filtered counts `(COUNT(*) FILTER)` to accurately capture clicks, add-to-cart actions, completed purchases,    and orders; ensured proper session-level aggregation for A/B test analysis, ready for downstream Python analysis and modeling.


## Tools & Skills
**SQL(PostgreSQL)** | **Python(Cleaning, EDA, Research & Testing/Visulizations)** | **Power BI - Dashboard Tools & DAX** | **Data Modeling** | **ETL** | **Hypothesis Testing** | **Business Analysis** 
 


**Live Dashboard:** [View Power BI Report](your-link-here)  
**Executive Deck:** [View Google Slides](https://docs.google.com/presentation/d/1h2wTZSiAYNN2xwqsaU1r2wTdwOEzAcLZYS8ufUnIp0g/present?slide=id.g3a024b19907_2_96)  
**Full Case Study Below ↓**



# E-Commerce Growth Analytics (Approach & Findings)
A comprehensive Data Analytics Project analyzing website micro-experiments and customer behavior using PostgreSQL and Python, uncovering actionable insights to optimize website conversion, customer targeting, and revenue growth.

---

## Business Context
An e-commerce company aims to increase sales and revenue by understanding how small website changes and different customer types affect purchasing behavior.
By leveraging user clickstream, purchase, and engagement data, the company seeks to uncover which micro website experiments boost conversions and which customer segments respond best to targeted offers.

---

## Business Problem
The challenge is to identify which website changes improve conversion and which customer segments should be targeted for maximum impact.
This project aims to:

- Determine the effect of small website changes (badges, discount labels, product order) on user behavior and conversion.
- Identify high-value or discount-sensitive customer segments for personalized marketing.
- Provide data-driven recommendations to increase purchases and revenue.

---

## Key Challenges

1. **Untested Micro Website Changes** – Small elements like badges, discount labels, or product sorting may affect purchase behavior, but their impact is unknown.
2. **Customers Treated the Same** – All customers currently receive the same offers, leading to wasted marketing efforts and missed revenue opportunities.
3. **Fragmented Data Sources** – Customer behavior and purchase data are spread across multiple tables, requiring cleaning, merging, and accurate aggregation.
4. **Measuring Impact Accurately** – Determining whether changes or campaigns truly improve conversion requires statistical testing.
5. **Actionable Insights** – Translating data analysis into clear, implementable recommendations for the business.

---
