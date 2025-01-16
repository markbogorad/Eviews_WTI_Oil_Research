
---

# **WTI Oil Forecasting Project**

![EViews](https://img.shields.io/badge/EViews-13-blue)  
![License Required](https://img.shields.io/badge/License-Paid%20Required-orange)  
![Dataset](https://img.shields.io/badge/Data-Bloomberg-green)  

This repository contains the files and methodology used to forecast WTI crude oil returns and volatility on a 15–20-day horizon using advanced econometric techniques. The project focuses on understanding the dynamic relationships in the oil market and building predictive models for better decision-making.

---

## **Overview**

This project investigates oil market dynamics and leverages time series models written in **EViews' internal programming language** to predict WTI crude oil returns and volatility. Key objectives include:

- Identifying the correlation between WTI and diesel returns.
- Modeling WTI returns using a **SETAR model** with diesel returns as a threshold variable.
- Evaluating model performance against ARMA and Markov switching benchmarks using the **Diebold-Mariano test**.
- Forecasting volatility using **FIGARCHX**, outperforming GARCH(1,1) and custom asymmetric FIGARCH models.

---

## **Files**

- **`data.xls`**: Original dataset containing WTI and diesel price series, sourced from Bloomberg.
- **`200029804.if3103.prg`**: EViews program file written in **EViews' internal language** for running the analysis and generating forecasts.
- **`README.md`**: Documentation for reproducing the project.

---

## **Requirements**

- **EViews 13**:  
  This project requires the **paid version** of EViews software (version 13) to run the `.prg` file and reproduce the results.  
  > *A valid license is necessary to access all functionalities of the software.*  

---

## **Methodology**

### **1. Data Import and Preprocessing**
- Import the dataset from `data.xls` into EViews.
- Analyze and clean the time series data for consistency.

### **2. Modeling**
- **SETAR Model**: Threshold variable defined using diesel returns to improve return predictions.
- **Volatility Modeling**: FIGARCHX used for volatility forecasting, capturing long memory effects and external variables.

### **3. Evaluation**
- Benchmark models include ARMA, Markov switching models, and GARCH(1,1).
- The **Diebold-Mariano test** validates the predictive accuracy of the proposed models.

### **4. Results**
- The SETAR model with diesel returns as the threshold variable demonstrated superior performance in return forecasting.
- FIGARCHX outperformed standard GARCH(1,1) and custom asymmetric FIGARCH models in volatility prediction.

---

## **How to Run**

1. Open **EViews 13**.
2. Import `data.xls` using **File > Open > Foreign Data as Workfile**.
3. Run the `.prg` file using **File > Run Program** to replicate the analysis.

---

## **Key Insights**

- Diesel returns are a significant threshold variable for WTI returns, enhancing forecasting accuracy.
- FIGARCHX models capture the complexity of volatility better than traditional methods, making them ideal for short-horizon forecasting.

---

## **Future Work**

- Extend analysis to include macroeconomic variables (e.g., interest rates, geopolitical factors).
- Test models on additional datasets to assess robustness under different market conditions.
- Incorporate machine learning techniques for further improvements in forecasting accuracy.

---
