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

This dashboard analyzes employee attrition (turnover) to identify key factors driving employees to leave. The goal is to provide actionable insights for the HR department to improve retention.

View Live Dashboard: Click here to view on Power BI Service

Browse Project Files: ./PowerBI-HR-Dashboard/ (Contains the HR Attrition Dashboard.pbix file, dataset, and images)

💡 Key Insights

Insight 1: [e.g., "Employee attrition is highest within the 'Sales' department, specifically among those with 1-2 years of tenure."]

Insight 2: [e.g., "A low 'JobSatisfaction' score combined with 'OverTime' work is the strongest predictor of attrition."]

Insight 3: [e.g., "Employees who travel frequently for work have a 25% higher attrition rate than those who do not."]

🛠️ Tools & Data

Tools: Power BI, DAX, Power Query

Dataset: [e.g., "IBM HR Analytics Employee Attrition & Performance dataset."]

4. Contoso Sales Dashboard (Power BI)

This dashboard tracks key sales KPIs for the fictional company Contoso. It breaks down revenue, profit, and units sold by region, product category, and time.

View Live Dashboard: Click here to view on Power BI Service

Browse Project Files: ./PowerBI-Sales-Dashboard/ (Contains the ContosoDashboardFinal.pbix file, dataset, and images)

💡 Key Insights

Insight 1: [e.g., "While 'Computers' generate the most revenue, the 'Audio' category has the highest profit margin at 48%."]

Insight 2: [e.g., "The 'Online' sales channel is outperforming 'Reseller' by 30% in year-over-year growth."]

🛠️ Tools & Data

Tools: Power BI, DAX

Dataset: [e.g., "Contoso Sales public dataset from Microsoft."]

📫 Connect With Me

Thank you for reviewing my portfolio. I'm passionate about data storytelling and always open to new opportunities and collaborations.

LinkedIn: https://www.linkedin.com/in/yourprofile

My Website: https://www.yourpersonalwebsite.com