# Data-Analyticss-Portfolio
Melvin's Data Analytics Portfolio

Hi there! 👋 Welcome to my consolidated analytics portfolio. This repository brings together several key projects, showcasing my skills across a range of BI and web technologies, from Tableau and Power BI to custom web dashboards with D3.js.

My goal is to turn raw data into clear, actionable insights. Below, you'll find a summary of each project, including live links, key insights, and links to the project files.

🚀 Portfolio Quick Links

Procurement Dashboard (Tableau)

Speeding Fines Interactive Dashboard (D3.js)

HR Attrition Dashboard (Power BI)

Contoso Sales Dashboard (Power BI)

1. Procurement Dashboard (Tableau)
This dashboard provides a strategic analysis of procurement data for 'Velocipede Cycles', an expanding Australian retail chain. Faced with shrinking profit margins despite growing sales, the project dives into two years of purchasing data to identify cost-saving opportunities, mitigate supply chain risks, and enhance supplier management. The visualizations are designed for a senior management audience, translating complex data into clear, actionable insights.

**View Live Dashboard:** [Click here to view on Tableau Public](https://public.tableau.com/views/Velocipede_Cycles_Procurement_Analytics_Dashboard/KPIMonitoringDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### Dashboard Snapshots
### 📍 KPI Monitoring Dashboard
<img src="./Tableau-Procurement-Dashboard/images/KPI_Monitoring_Dashboard.png" alt="KPI Monitoring Dashboard">

### 📍 Supplier Performance Dashboard
<img src="./Tableau-Procurement-Dashboard/images/Supplier_Performance_Dashboard.png" alt="Supplier Performance Dashboard">

### 📍 Cost Saving Analysis Dashboard
<img src="./Tableau-Procurement-Dashboard/images/Cost_Saving_Analysis_Dashboard.png" alt="Cost Saving Analysis Dashboard">

### 📍 Data Modelling
<img src="./Tableau-Procurement-Dashboard/images/Data_Modelling.png" alt="Data Modelling">

### 💡 Key Insights

- ✅ **High-Risk Supplier Concentration:** Spend grew 10% year-on-year to $11.5M, but remains concentrated on just 10 suppliers. The top four vendors account for 54% of total spend, creating significant supply chain vulnerability.
- ✅ **Strategic Components Drive Budget:** Nearly half (49%) of the entire procurement budget is spent on just three categories—frames, displays, and batteries. Optimizing costs in these areas offers the highest potential financial impact.
- ✅ **Untapped Savings in Price Variance:** Significant price gaps exist for identical items between suppliers (e.g., a $260 difference per carbon frame), highlighting clear opportunities for cost reduction through strategic sourcing.
- ✅ **Evidence of Successful Past Optimizations:** A 26% decrease in overall potential savings from 2023 indicates that prior cost-cutting initiatives were effective, particularly in core component categories.
- ✅ **Predictable Seasonal Spending Patterns:** Procurement activity follows a clear seasonal cycle with peaks in March–April and June–October, offering strategic windows for contract negotiations during quieter periods.

### 📈 Recommendations for Business Growth

- 📌 **Diversify the Supplier Base:** Actively onboard alternative suppliers for critical components like frames and electronics to mitigate the risk of over-reliance on a few key vendors.
- 📌 **Renegotiate High-Value Contracts:** Leverage the high spend volume in top categories (frames, displays, batteries) to renegotiate pricing and terms for better margins.
- 📌 **Consolidate Purchasing with Cost-Effective Suppliers:** Shift purchasing volume for items with high price variance to consistently lower-priced suppliers to realize immediate cost savings.
- 📌 **Focus on Next-Generation Cost Initiatives:** With initial "easy wins" realized, pivot to more advanced cost-saving strategies like supplier innovation, component standardization, and design optimization.
- 📌 **Align Negotiation Cycles with Off-Peak Seasons:** Schedule major contract reviews and supplier negotiations during quieter procurement months (e.g., Jan-Mar) to gain a strategic advantage.

### 🛠️ Tech Stack
- **Tableau Desktop & Tableau Prep Builder** – Data cleaning, transformation, modeling, and creation of interactive dashboards.
- **Data Modeling** – Developed a logical data model to structure procurement data for analysis.
- **Interactive Visuals** – Designed intuitive and compelling visualizations to support executive decision-making.

### Project Files
- 📄 **[`final_dashboard.twbx`](./Tableau-Procurement-Dashboard/final_dashboard.twbx)** – The complete Tableau workbook package containing all dashboards, data sources, and formatting.
- 📊 **[`Cleaned_Data_Velocipede_Cycles.xlsx`](./Tableau-Procurement-Dashboard/dataset/Cleaned_Data_Velocipede_Cycles.xlsx)** – The cleaned and prepared dataset used for the analysis.

2. Interactive Speeding Fines Dashboard (D3.js)
This project addresses a brief from the Bureau of Infrastructure and Transport Research Economics (BITRE) to visualize newly detailed road safety enforcement data from 2023. The result is a fully interactive, custom-built web dashboard using D3.js to visualize data on speeding fines across Australia. It allows users to explore when, where, and how Australians were fined, telling a data-driven story about traffic enforcement patterns. The design process is documented in a detailed design book.

**View Live Dashboard:** [Click here to view the live dashboard](https://web-dashboard-speeding-fines-2023-australia.s3.ap-southeast-2.amazonaws.com/index.html)

### Dashboard Snapshots
### 📍 Home Page – Project Introduction
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/homepage.png" alt="Home Page">

### 📍 Monthly Trends & Detection Methods
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/dashboard-part1.png" alt="Detection Method and KPI Summary">

### 📍 Age Group & Jurisdiction Breakdown
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/dashboard-part2.png" alt="Demographics and Jurisdiction Charts">

### 💡 Key Insights
- ✅ **Seasonal Spikes in Fines**: The data reveals significant monthly variations in speeding fines, with notable peaks typically occurring around public holidays and summer months, suggesting a correlation between increased travel and enforcement activity.
- ✅ **Camera vs. Officer Discrepancy**: Speed cameras account for a substantially higher number of fines compared to police-issued tickets, highlighting the critical role of automated enforcement in road safety.
- ✅ **Youth Demographic Overrepresentation**: Younger drivers, particularly those in the 20-29 age bracket, are disproportionately represented in speeding infringements across most Australian states.
- ✅ **Jurisdictional Hotspots**: Populous states like New South Wales and Victoria emerge as hotspots with the highest volume of fines, which corresponds to their larger road networks and extensive camera systems.

### 📈 Policy & Public Safety Recommendations
- 📌 **Targeted Safety Campaigns**: Develop and launch road safety campaigns aimed at the 20-29 age demographic, emphasizing the risks and consequences of speeding.
- 📌 **Increased Transparency**: Enhance public awareness regarding the locations and operational times of speed cameras to act as a deterrent and encourage compliance.
- 📌 **Optimized Patrol Deployment**: Use the insights on fine hotspots to inform the strategic deployment of police patrols, focusing on areas and times with higher instances of speeding.

###  ETL Process - KNIME Workflow
The raw data from various jurisdictions required significant cleaning and transformation. KNIME was used to create a robust ETL pipeline that standardized formats, handled missing values, and aggregated the data for visualization.
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-output-pipeline.png" alt="KNIME Final Export">

<details>
<summary>Click to view individual state workflows</summary>

### QLD Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-qld.png" alt="KNIME Workflow for QLD">

### ACT Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-act.png" alt="KNIME Workflow for ACT">

### NSW Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-nsw.png" alt="KNIME Workflow for NSW">

### NT Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-nt.png" alt="KNIME Workflow for NT">

### SA Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-sa.png" alt="KNIME Workflow for SA">

### TAS Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-tas.png" alt="KNIME Workflow for TAS">

### VIC Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-vic.png" alt="KNIME Workflow for VIC">

### WA Workflow
<img src="./Website-Dashboard-Speeding-Fines-2023-Australia/images/knime-wa.png" alt="KNIME Workflow for WA">

</details>

### 🛠️ Tech Stack
- **Visualizations**: D3.js v7
- **Front-End**: HTML5, CSS3, JavaScript (ES6+)
- **ETL & Cleaning**: KNIME Analytics Platform
- **Hosting**: Amazon S3 (static website)

### Project Files
- 📁 **[`Project Folder`](./Website-Dashboard-Speeding-Fines-2023-Australia/)** – Contains all project files including `index.html`, `js/`, `css/`, and `data/`.

3. HR Attrition Dashboard (Power BI)
Mr. Ryan, the Head of HR, wanted a comprehensive and interactive dashboard to analyze the company’s employees. The goal was to answer key HR questions about employee demographics, workforce size, attrition rates, hiring trends, performance ratings, and satisfaction scores. This dashboard allows executives to filter by department, gender, age group, and year to get both a high-level overview and detailed insights for better decision-making.

**View Live Dashboard:** [Click here to view on Power BI Service](https://app.powerbi.com/view?r=eyJrIjoiY2M0N2U2NGQtM2E5NC00ODc3LThkMTAtODAxMjFiZDBlNGE5IiwidCI6ImRmN2Y3NTc5LTNlOWMtNGE3ZS1iODQ0LTQyMDI4MGY1Mzg1OSIsImMiOjEwfQ%3D%3D&pageName=23985c93ca4941285647)

### Dashboard Snapshots
### 📍 Employee Overview
<img src="./PowerBI-HR-Dashboard/images/Employee_Overview.png" alt="Employee Overview">

### 📍 Demographics
<img src="./PowerBI-HR-Dashboard/images/Demographics.png" alt="Demographics">

### 📍 Attrition Analysis
<img src="./PowerBI-HR-Dashboard/images/Attrition.png" alt="Attrition Analysis">

### 📍 Performance Tracking
<img src="./PowerBI-HR-Dashboard/images/Performance_Tracking.png" alt="Performance Tracking">

### 📍 Data Modeling (Star Schema)
<img src="./PowerBI-HR-Dashboard/images/Data_Modelling.png" alt="Data Modeling">

### 💡 Key Insights
- ✅ **Total Employees**: 1,470
- ✅ **Attrition Rate**: 16.12% (highest in Sales – 20.63%)
- ✅ **Demographic Trends**: The majority of employees are 20–29 years old, and this group also has the highest resignation rate.
- ✅ **Retention Factors**: Employees without stock options are more likely to leave.

### 📈 Recommendations to Reduce Attrition
- 📌 **Introduce stock options or bonuses** to improve retention, as higher attrition is seen among employees without them.
- 📌 **Enhance career growth for younger employees** with mentorship and training programs.
- 📌 **Focus on Sales & HR departments**, as these teams have the highest attrition rates.
- 📌 **Monitor job satisfaction closely**, as self-ratings and job satisfaction show downward trends.

### 🛠️ Tech Stack
- **Power BI Desktop & Power Query**: For data cleaning, transformation, and modeling.
- **DAX**: Used for creating KPIs and custom calculations.
- **Data Modeling (Star Schema)**: Implemented to optimize the data structure for reporting.

### Project Files
- 📄 **[`HR Attrition Dashboard.pbix`](./PowerBI-HR-Dashboard/HR%20Attrition%20Dashboard.pbix)**: The Power BI dashboard file.
- 📁 **[`dataset/`](./PowerBI-HR-Dashboard/dataset/)**: The complete dataset used for the analysis.

4. Contoso Sales Dashboard (Power BI)
The CEO of the Contoso e-commerce business needs a single interactive dashboard to understand the company’s sales performance and customer service efficiency. This dashboard helps them track revenue trends, see which products and campaigns bring in the most sales, and check if KPIs are being met. It also shows how well the customer service team is performing, who the top revenue clients are, and which open cases need attention so the company can improve client retention and satisfaction.

**View Live Dashboard:** [Click here to view on Power BI Service](https://app.powerbi.com/view?r=eyJrIjoiZTk1ZjhiMWItOTVhYS00NjhlLWIyMDAtYjU1N2M4NTdmN2M2IiwidCI6ImRmN2Y3NTc5LTNlOWMtNGE3ZS1iODQ0LTQyMDI4MGY1Mzg1OSIsImMiOjEwfQ%3D%3D&pageName=ReportSection909ea50e7939156807d6)

### Dashboard Snapshots
### 📍 Sales Overview
<img src="./PowerBI-Sales-Dashboard/images/Sales_Overview.png" alt="Sales Overview">

### 📍 Customer Service Analysis
<img src="./PowerBI-Sales-Dashboard/images/Customer_Service_Analysis.png" alt="Customer Service Analysis">

### 📍 Key Factors Driving Won vs Lost Deals
<img src="./PowerBI-Sales-Dashboard/images/Key_Influencers_Won_vs_Lost_Deals.png" alt="Key Factors Driving Won vs Lost Deals">

### 📍 Revenue Analysis – Performance & Contributors
<img src="./PowerBI-Sales-Dashboard/images/Revenue_Analysis.png" alt="Revenue Analysis">

### 📍 Data Modeling (Snowflake Schema)
<img src="./PowerBI-Sales-Dashboard/images/Data_Modelling.png" alt="Data Modeling">

### 💡 Key Insights
- ✅ **Close Rate**: 64.5% with 12,346 total opportunities.
- ✅ **Revenue Trend**: The highest revenue months were July 2020 ($1.6M) and Jan 2021 ($1.6M).
- ✅ **Top Revenue Products**: Design App ($6.1M), Stand-up Desk ($4.5M), and Tablets ($4.1M).
- ✅ **Top Campaign Type**: Email campaigns generated the greatest potential sales value ($3.3M).
- ✅ **Top Clients**: Abbott Inc. and Abercathy & Sons are high-revenue contributors worth a retention focus.
- ✅ **Customer Service KPIs**: Average customer satisfaction is 4.27, with a 16% escalation rate and 76% SLA compliance.

### 📈 Recommendations for Business Growth
- 📌 **Focus on High-Revenue Products**: The Design App, Stand-up Desk, and Tablets have the highest returns.
- 📌 **Expand Email Marketing Campaigns**, as email generates the highest potential sales value.
- 📌 **Reward Top Clients** like Abbott Inc. and Abercathy & Sons with loyalty programs.
- 📌 **Improve Customer Service Efficiency** by reducing resolution times and escalation rates.

### 🛠️ Tech Stack
- **Power BI Desktop & Power Query**: For data cleaning and transformation.
- **DAX Measures**: For calculating KPIs for revenue, close rate, and customer satisfaction.
- **Data Modeling (Snowflake Schema)**: Implemented to optimize data for sales and customer service reporting.

### Project Files
- 📄 **[`ContosoDashboardFinal.pbix`](./PowerBI-Sales-Dashboard/ContosoDashboardFinal.pbix)**: The Power BI dashboard file.
- 📁 **[`dataset/`](./PowerBI-Sales-Dashboard/dataset/)**: The complete dataset used for the analysis.

📫 Connect With Me

Thank you for reviewing my portfolio. I'm passionate about data storytelling and always open to new opportunities and collaborations.

LinkedIn: https://www.linkedin.com/in/melvin-nguyen/
