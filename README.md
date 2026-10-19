# Retail Demand Forecasting & Pricing Analytics

### An End-to-End Retail Analytics Project Using PostgreSQL, Python, CatBoost & Power BI

An end-to-end retail analytics project focused on understanding demand patterns, building a time-aware demand forecasting model, evaluating forecast performance, and translating the results into business insights through Power BI.

The project combines **PostgreSQL/SQL, Python, CatBoost, and Power BI** to demonstrate a complete analytics workflow from raw retail data to business-facing insights.

---

##  Project Overview

Retail businesses need to understand how much demand to expect across products and stores in order to support inventory planning, operational decisions, and pricing analysis.

This project uses historical retail sales data to:

- Understand sales and demand patterns
- Perform data-quality validation using SQL
- Build an analytical data layer in PostgreSQL
- Explore demand, pricing, stores, and product behavior
- Engineer time-aware forecasting features
- Establish baseline forecasting models
- Train a CatBoost demand forecasting model
- Evaluate predictions using MAE, RMSE, and WAPE
- Analyze demand across different demand bands
- Build an interactive Power BI dashboard
- Translate analytical findings into business recommendations

---

##  Business Objectives

The project addresses four main questions:

1. **How does retail demand vary across products, stores, time, and divisions?**
2. **Can historical demand patterns be used to forecast future demand?**
3. **How well does the forecasting model perform compared with simple baselines?**
4. **What business insights can be derived from demand and pricing patterns?**

---

## 🛠️ Tech Stack

| Area | Tools |
|---|---|
| Database | PostgreSQL |
| SQL Analysis | SQL |
| Data Analysis | Python, Pandas, NumPy |
| Visualization | Matplotlib, Seaborn, Power BI |
| Forecasting | CatBoost |
| Model Evaluation | MAE, RMSE, WAPE |
| Reporting | Power BI |
| Documentation | Markdown |

---

##  Project Workflow


Raw Retail Data
       ↓
PostgreSQL / SQL
       ↓
Data Quality Validation
       ↓
Analytical Data Layer
       ↓
Python EDA
       ↓
Time-Aware Feature Engineering
       ↓
Baseline Forecasting
       ↓
CatBoost Demand Forecasting
       ↓
Model Evaluation
       ↓
Pricing & Demand Analysis
       ↓
Power BI Dashboard
       ↓
Business Insights & Recommendations


---

##  Dataset

The project uses a large retail sales dataset containing approximately **7.43 million sales records**.

### Dataset characteristics

- Date range: **August 28, 2022 – September 26, 2024**
- Approximately **28,182 unique products**
- **4 stores**
- Product, store, sales, quantity, revenue, and pricing information
- Additional source tables for online sales, price history, discounts, markdowns, catalog information, stores, and actual-matrix data

The raw dataset is **not included in this repository**.

---

##  SQL & PostgreSQL

The SQL workflow is organized into four stages:


01_schema_setup.sql
        ↓
02_data_quality_checks.sql
        ↓
03_analytics_layer.sql
        ↓
04_business_analysis.sql


### 01 — Schema Setup

Creates the raw schema and source tables used throughout the project.

### 02 — Data Quality Checks

Performs validation and investigation of:

- Duplicate records
- Missing values
- Product and store matching
- Quantity signs
- Revenue consistency
- Price anomalies
- Source-table relationships
- Outliers and suspicious records

### 03 — Analytics Layer

Creates enriched analytical tables by combining sales data with:

- Product catalog information
- Store information
- Product attributes

### 04 — Business Analysis

Contains business-facing SQL analysis including:

- Store performance
- Store sales contribution
- Store rankings
- Top products by store
- Monthly sales
- Month-over-month changes

---

##  Exploratory Data Analysis

The EDA stage investigates:

- Demand distribution
- Revenue patterns
- Store performance
- Product behavior
- Division-level demand
- Day-of-week patterns
- Pricing characteristics
- Data sparsity and intermittent demand

One important finding was that product-store demand is relatively sparse, which influenced the forecasting population and feature-engineering approach.

---

##  Demand Forecasting

### Forecasting Population

Instead of forecasting every possible product-store combination, the project focuses on product-store pairs with sufficient historical activity.

Selected pairs were required to meet:

- Coverage ratio ≥ **75%**
- At least **180 active days**

This reduced the impact of extremely sparse product-store combinations on the forecasting task.

### Target Treatment

Negative quantities were investigated during data-quality analysis.

For forecasting, negative quantities were excluded from the demand target rather than treating them as positive demand:


demand_quantity = quantity.where(quantity >= 0, NaN)


This separates unusual transaction adjustments from the demand signal being forecast.

---

##  Forecasting Features

The model uses time-aware historical features including:

- Lag 1 demand
- Lag 7 demand
- Lag 28 demand
- 7-day rolling demand
- 28-day rolling demand
- Rolling observation counts
- Day of week
- Month
- Year
- Day of month
- Weekend indicator
- Product
- Store
- Store format
- City
- Division
- Lagged price
- Price change

Features were constructed using historical information to avoid directly using future observations.

---

##  Forecasting Models

Simple baselines were established before training the machine-learning model.

| Model | MAE | RMSE | WAPE |
|---|---:|---:|---:|
| Lag 1 | 4.56 | 11.10 | 39.11% |
| Lag 7 | 4.55 | 9.46 | 38.91% |
| Rolling 7 | 3.72 | 9.53 | 33.52% |
| CatBoost V1 | 3.42 | 8.29 | 30.90% |
| CatBoost V2 | 3.42 | 8.11 | 30.88% |
| CatBoost V3 | ~3.41 | ~8.31 | 30.77% |
| **CatBoost V4** | **3.37** | **8.28** | **30.46%** |

The final CatBoost model was selected based primarily on **MAE and WAPE**, while considering RMSE as an additional performance measure.

> WAPE is used as an evaluation metric and should not be interpreted as model accuracy.

---

##  Final Model

The final model is a **CatBoostRegressor** trained with:

- 500 iterations
- Depth: 8
- Learning rate: 0.05
- RMSE loss
- Random seed: 42

The model uses categorical features for product, store, store format, city, and division.

The trained model is available in:


models/catboost_v4.cbm


The feature configuration is stored in:


models/feature_config.json


---

##  Final Forecast Performance

The selected model achieved:

| Metric | Result |
|---|---:|
| MAE | **3.37** |
| RMSE | **8.28** |
| WAPE | **30.46%** |
| Forecast Coverage | **100%** |

The model performs substantially better than the simple lag and rolling baselines on the selected evaluation metrics.

---

##  Performance by Demand Band

Forecast performance varies considerably depending on the underlying demand level.

| Demand Band | MAE | RMSE | WAPE |
|---|---:|---:|---:|
| Low (≤2) | 2.06 | 3.12 | 146.41% |
| Medium (>2–5) | 1.70 | 2.86 | 44.62% |
| High (>5–10) | 2.63 | 3.92 | 34.78% |
| Very High (>10) | 7.70 | 15.58 | 22.89% |

This highlights an important characteristic of retail forecasting: **percentage-based metrics can behave poorly when actual demand is very low**, while absolute errors can become larger for high-volume products.

---

##  Pricing Analysis

The project also examines the relationship between pricing and observed demand patterns.

Price-related variables were incorporated into the forecasting model, including:

- Lagged price
- Price change

The final model showed that lagged price was an important predictive feature.

However, **predictive importance does not establish a causal relationship between price and demand**.

Therefore, this project does not claim to estimate price elasticity or determine an optimal price.

---

##  Power BI Dashboard

The Power BI dashboard contains three main views.

### 1. Executive Overview

Provides a high-level view of:

- Total demand
- Average demand
- Total forecast
- Average price
- MAE
- WAPE
- Actual vs forecast
- Demand bands
- Store performance
- Division performance

### 2. Demand & Pricing

Explores:

- Demand by weekday
- Top products
- Average price by store format
- Demand by store format
- Pricing and demand patterns

### 3. Forecast Performance

Focuses on:

- MAE
- RMSE
- WAPE
- Forecast coverage
- Actual vs predicted demand
- Error distribution
- Performance by demand band

Dashboard screenshots are available in:


powerbi/


The `.pbix` source file is not included because of its file-size limitation.

---

##  Key Business Insights

### 1. Demand is concentrated across stores

Stores 1 and 4 contribute the majority of observed demand, indicating that store-level differences are important when interpreting overall performance.

### 2. Division 1 dominates demand

Demand is not evenly distributed across divisions, making division-level analysis useful for prioritizing inventory and forecasting efforts.

### 3. Demand varies by weekday

Friday shows the highest average demand, while Sunday shows the lowest average demand in the analyzed data.

### 4. Retail demand is highly heterogeneous

Product-store combinations differ substantially in their demand levels and historical activity. This makes a single naive forecasting rule insufficient for the entire product population.

### 5. Recent demand is highly predictive

Recent lagged demand and rolling demand features are among the strongest predictors in the final model.

### 6. Pricing information adds predictive signal

Lagged price contributes meaningfully to the model, but the analysis does not establish that changing prices will cause demand to change.

---

##  Limitations

Several limitations should be considered when interpreting the results:

- The model uses a single train/test split rather than full walk-forward validation.
- Forecasting focuses on product-store pairs meeting the activity thresholds.
- Sparse and intermittent demand remains challenging.
- Price relationships are predictive/associational rather than causal.
- Promotion effects are not explicitly modeled.
- Stockouts and lost sales are not directly modeled.
- The current analysis does not estimate price elasticity.
- No automated model monitoring or retraining pipeline is implemented.

---

##  Future Improvements

Potential extensions include:

- Walk-forward / rolling time-series validation
- Price elasticity estimation
- Price-demand scenario simulation
- Promotion-aware forecasting
- Stockout-aware demand modeling
- Advanced forecasting models
- Automated model monitoring
- Scheduled model retraining
- More detailed product-level segmentation

---

##  Repository Structure


retail-demand-pricing/
│
├── sql/
│   ├── 01_schema_setup.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_analytics_layer.sql
│   └── 04_business_analysis.sql
│
├── notebooks/
│   └── 01_EDA.ipynb
│
├── models/
│   ├── catboost_v4.cbm
│   └── feature_config.json
│
├── powerbi/
│   ├── executive_overview.png
│   ├── demand_pricing.png
│   └── forecast_performance.png
│
├── report/
│   └── Retail_Demand_Forecasting_Pricing_Analytics.pdf
│
└── README.md


---

## 📄 Project Report

A detailed project report covering the methodology, analysis, forecasting approach, evaluation, dashboard, insights, limitations, and future improvements is available in:


report/


---

##  Author

**Disha Chaudhari**

This project was developed as a portfolio project to demonstrate practical skills in:

**SQL → Data Analysis → Machine Learning → Forecast Evaluation → Business Intelligence**
```
