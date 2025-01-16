
---

# WTI Oil Returns and Volatility Modeling Project

This repository contains an advanced time series analysis project focused on forecasting WTI crude oil returns and volatility. The project employs **EViews 13's internal programming language** to implement a wide range of econometric models for forecasting and performance evaluation.

> **Disclaimer:** Running the EViews programs requires a **paid version of EViews 13**.

---

## Key Features
- **Variable of Interest:** Daily changes in the WTI crude oil spot price (in levels).
- **Mean Modeling:** Comparison of ARMA, SETAR, TAR, and Markov Switching models.
- **Volatility Modeling:** FIGARCHX with Brentd as a variance regressor, benchmarked against GARCH(1,1).
- **Model Validation:** Post-estimation diagnostic tests and performance metrics, including MSE, MAE, RMSE, and Theil inequality coefficients.
- **Rolling Window Forecasting:** 15-day and 20-day rolling forecasts for the mean and volatility, respectively.

---

## Methodology

### Data Preparation
- **Unit Root Testing:** Applied Breakpoint Unit Root and ADF tests to ensure stationarity.
- **Differencing:** Converted all series to first differences to address unit root issues.
- **Break Detection:** Identified structural breaks due to COVID-19 (April 2020) and excluded pre-break data to improve model robustness.

### Mean Models
- **SETAR (Chosen Model):** Demonstrated the best forecasting performance and passed all post-estimation diagnostic tests.
- **ARMA:** Used as a baseline candidate model, with AR(3) identified as the best configuration.
- **Markov Switching:** Explored regime-switching dynamics with significant transition parameters.
- **TAR:** Included lag-based threshold variables for comparison.

### Volatility Models
- **FIGARCHX (Chosen Model):** Outperformed GARCH(1,1) by capturing long memory effects and including Brentd as a variance regressor.
- **GARCH(1,1):** Served as a benchmark, showing robust but comparatively weaker performance.

---

## Key Results
- **Mean Modeling:** The SETAR model excelled in forecasting WTI returns, outperforming ETS-smoothed benchmarks across all loss functions.
- **Volatility Modeling:** FIGARCHX demonstrated superior accuracy in forecasting volatility, accounting for long memory and Brentd's variance effects.

---

## Future Work
- Incorporating intraday data (e.g., hourly observations of the S&P Energy Index) and applying MIDAS techniques to improve both mean and volatility models.
- Expanding the dataset by merging similar subsets post-structural break to increase sample size and model robustness.

---

## Running the Code
1. **Import Data:**
   - Load `data.xls` into EViews as a workfile:  
     `File -> Open -> Foreign Data as Workfile`.
2. **Run Program:**
   - Execute `.prg` files to replicate the models:  
     `File -> Open -> Programs`.
3. **Requirements:**
   - **EViews 13 (Paid Version):** Necessary to run the code.
   - Knowledge of EViews’ internal programming language.

---

## Files
- `data.xls`: Raw dataset for the project.
- `200029804.if3103.prg`: EViews program implementing the econometric models.
- `README.md`: Project documentation.

---

## Model Specifications
- **Mean Model (SETAR):**
  ```
  wtid c brentd propaned nygasd ladieseld @thresh wtid
  ```
- **Volatility Model (FIGARCHX):**
  ```
  wtid c @ brentd
  ```

---

## Contributions and Acknowledgments
This project was conducted to explore advanced forecasting techniques for financial time series, specifically within the context of crude oil markets. Suggestions for improvements and further development are welcome.

---
