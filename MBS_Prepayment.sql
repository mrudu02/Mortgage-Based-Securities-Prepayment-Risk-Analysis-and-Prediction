/* MORTGAGE-BACKED SECURITIES PREPAYMENT RISK
The dataset consists of following variables:
Credit_Score_Range
Credit_Score	
First_Payment_Date	
First_Time_Home_Buyer	
Maturity_Data 	
Mortgage_Insurance_Percentage	
Occupancy	
Debt_to_Income_Range	
Debt_to_Income	
Orig_UnPaid_Balance	
Loan_To_Value_Range	
Loan_To_Value	
Interest_Rate	
Channel		
Property_State	
Property_Type	
Loan_Purpose	
Ever_Delinquent	
Months_In_Repayment	
Expected_Total_Term	
Repay_Range	
Prepayment 

The prepayment and expected total term were calculated in Excel

Objectives: 
1. To determine which factors correlate mostly with prepayment behavior.
2. To gain insights about each factor and their relation.
3. Provide actionable recommendations to minimize prepayment risk.
*/

-- Create table and import data:
CREATE TABLE MBS_Prepayment (
Customer_ID SERIAL PRIMARY KEY,
Credit_Score_Range VARCHAR(100),
Credit_Score INT,
First_Payment_Date DATE,	
First_Time_Home_Buyer VARCHAR(100),
Maturity_Data DATE,
Mortgage_Insurance_Percentage INT,
Occupancy INT,
Debt_to_Income_Range VARCHAR(100),
Debt_to_Income	INT,
Orig_UnPaid_Balance	INT,
Loan_To_Value_Range	VARCHAR(100),
Loan_To_Value INT,	
Interest_Rate DECIMAL(10,2),
Channel	INT,	
Property_State VARCHAR(100),
Property_Type INT,
Loan_Purpose INT,	
Ever_Delinquent	INT,
Months_In_Repayment	INT,
Expected_Total_Term	INT,
Repay_Range	VARCHAR(100),
Prepayment VARCHAR(100)
);

COPY MBS_Prepayment FROM 'D:\Grant Thornton R\SQL\Project\LoanExport_Num.csv' WITH CSV HEADER;

SELECT * FROM MBS_Prepayment;

-- 1. What is the count of total customers?
SELECT COUNT(*) as Total_Customer
FROM MBS_Prepayment;
-- Total customers in the data are 2,91,451.

-- 2. What is the count of first-time loan buyers?
SELECT COUNT(*) First_Time_Home_Buyer
FROM MBS_Prepayment
WHERE First_Time_Home_Buyer = 'Y';
-- The number of customers applying for a loan for the first time is 29,282.

-- 3. What is the loan count by credit score range?
SELECT Credit_Score_Range, COUNT(*)
FROM MBS_Prepayment
GROUP BY Credit_Score_Range;
-- The highest loan lies in the 'Good' credit score range, i.e. 99169.

-- 4. What is the total unpaid balance in the dataset?
SELECT SUM(Orig_UnPaid_Balance) as Unpaid_Balance
FROM MBS_Prepayment;
-- The total Unpaid Balance is 36414001000.

-- 5. What is the average interest rate of the loan?
SELECT AVG(Interest_Rate) as Avg_Interest_Rate
FROM MBS_Prepayment;
-- The average interest rate of the loan is 6.9%

-- 6. How many loans are marked as delinquent?
SELECT Ever_Delinquent, COUNT(*)
FROM MBS_Prepayment
GROUP BY Ever_Delinquent;
-- Delinquent marked loans are 57663.

-- 7. What is the average interest rate for first-time borrowers and non-first-time borrowers?
SELECT First_Time_Home_Buyer, AVG(Interest_Rate) as Average_Interest_Rate
FROM MBS_Prepayment
GROUP BY First_Time_Home_Buyer;
-- There is no difference between the interest rate for both.

-- 8. What is the loan count, Interest Rate and Unpaid Balance by PropertyState?
SELECT Property_State, 
     COUNT(Property_State) AS loan_Count, 
     round(AVG(Interest_Rate),2) AS Average_Interest_Rate , 
     SUM(Orig_UnPaid_balance) as Unpaid_Balance
FROM MBS_Prepayment
GROUP BY Property_State
ORDER BY Loan_Count DESC
LIMIT 5;
-- The top 5 states where the number of loans is high are California, Florida, Michigan, Illinois, and Texas.
-- There is no significant difference between interest rates across the state.
-- The highest loan count state also seems to have the highest unpaid balance.

-- 9. What is the average loan-to-value for each Credit Score Range?
SELECT Credit_Score_Range, round(AVG(Loan_to_Value),2) as Avg_loan_to_Value
FROM MBS_Prepayment
GROUP BY Credit_Score_Range;
-- Average loan to value for credit score range is:
-- Excellent = 71.03, Fair = 80, Good = 77, Poor = 81

-- 10. What is the total unpaid balance for each Debt to Income Range?
SELECT Debt_to_Income_Range, SUM(Orig_UnPaid_Balance) as Unpaid_balance
FROM MBS_Prepayment
GROUP BY Debt_to_Income_Range;
-- The medium debt-to-income range has the highest unpaid loan amount.

-- 11. Is there a relationship between Loan To Value Range and Interest Rate?
SELECT 
    Loan_to_Value_Range, 
    round(AVG(Interest_Rate),2) AS Average_Interest_Rate,
    MIN(Interest_Rate) AS Minimum_Interest_Rate,
    MAX(Interest_Rate) AS Maximum_Interest_Rate
FROM MBS_Prepayment
GROUP BY Loan_to_Value_Range;
-- For the High loan-to-value-range min interest is = 4 and max is 12.
-- For the Low loan-to-value-range min interest is = 5.63 and max is 10.85.
-- For the Medium loan-to-value-range min interest is = 5.13 and max is 9.13.
-- The average interest rate is 6.9 but the interest is varying as we can see the min & max for each range.

-- 12. Is there a relationship between Debt To Income Range and Interest Rate?
SELECT 
    Debt_to_Income_Range, 
    MIN(Interest_Rate) AS Min_Interest_Rate, 
    MAX(Interest_Rate) AS Max_Interest_Rate, 
    round(AVG(Interest_Rate),2) AS Avg_Interest_Rate
FROM MBS_Prepayment
GROUP BY Debt_to_Income_Range;
-- For the Low debt-to-income-range min interest is = 4.75 and max is 12.35.
-- For the High debt-to-income-range min interest is = 5.25 and max is 10.38.
-- For the Medium debt-to-income-range min interest is = 4 and max is 11.50.

-- 13. What is the delinquency rate for each Debt to Income Range?
SELECT 
    Debt_to_Income_Range,
    COUNT(*) AS Total_Loans,
    (COUNT(CASE WHEN Ever_Delinquent = 1 THEN 1 END) * 100.0 / COUNT(*)) AS Delinquency_Rate
FROM MBS_Prepayment
GROUP BY Debt_to_Income_Range
ORDER BY Delinquency_Rate DESC;
-- Customers having a 'High' debt-to-income have the highest delinquency rate i.e. 23.21%.

-- 14. Which combination of Credit Score Range and Debt to Income Range has the highest delinquency rate?
SELECT 
    Credit_Score_Range,
    Debt_to_Income_Range,
    COUNT(CASE WHEN Ever_Delinquent = 1 THEN 1 END) AS Total_Delinquent,
    COUNT(*) AS Total_Loans,
    (COUNT(CASE WHEN Ever_Delinquent = 1 THEN 1 END) * 100.0 / COUNT(*)) AS Delinquency_Rate
FROM MBS_Prepayment
GROUP BY Credit_Score_Range, Debt_to_Income_Range
ORDER BY Delinquency_Rate DESC;
-- LIMIT 1
-- The 'Poor' credit score range and 'High' debt-to-income range have the highest delinquency rate at 42%.
-- The 'Excellent' credit score range and 'Low' debt-to-income range have the lowest delinquency rate at 7.44%.
-- Customers with a poor credit score and high debt to income are likely to be delinquent.

-- 15. For loans with a repayment range, what is LoanPurpose?
SELECT 
    Repay_Range,
    COUNT(CASE WHEN Loan_Purpose = 0 THEN 0 END) AS Cash_IN,
    COUNT(CASE WHEN Loan_Purpose = 2 THEN 2 END) AS Cash_OUT
FROM MBS_Prepayment
GROUP BY Repay_Range
ORDER BY Cash_IN DESC;
-- The Loan purpose for the overall repayment range is cash-in(purchase).

-- 16. Which is the most common repayment range for loans with a Loan To Value greater than 90?
SELECT Repay_Range, COUNT(Loan_to_Value) as Loan_to_value
FROM MBS_Prepayment
WHERE Loan_to_Value > 90
GROUP BY Repay_Range;
--LIMIT 1;
-- The repayment range for the loan-to-value above 90 is 0-4 Years.

-- 17. What is the total number and unpaid balance of loans for customers with a Mortgage Insurance Percentage greater than 25%?
SELECT COUNT(*) AS Total_Loans,
SUM(Orig_UnPaid_Balance) AS Total_Unpaid_Balance
FROM MBS_Prepayment
WHERE Mortgage_Insurance_Percentage > 25;
-- The total count whose mortgage insurance percentage is more than 25 is 44,684.
-- The total unpaid balance is 5,55,49,89,000.

-- 18. What is the count and percentage of prepaid loans?
SELECT Prepayment, COUNT(*)
FROM MBS_Prepayment
GROUP BY Prepayment;
-- The total Prepaid Loan is 577.

-- 19. Is there a correlation between loan-to-value and prepayment risk?
SELECT Loan_to_Value_Range,
COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count,
COUNT(*) AS Total_Count,
round(((COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) * 100.0) / COUNT(*)),2) AS Prepayment_Percentage
FROM MBS_Prepayment
GROUP BY Loan_to_Value_Range;
-- Customers with 'High' loan-to-value are likely to make a prepayment. The payment percentage is 0.199%.

-- 20. How do loans with a higher debt-to-income compare in terms of prepayment risk?
SELECT Debt_to_Income_Range,
    COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count,
    COUNT(*) AS Total_Count,
    round(((COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) * 100.0) / COUNT(*)),2) AS Prepayment_Percentage
FROM MBS_Prepayment
GROUP BY Debt_to_Income_Range
ORDER BY Prepaid_count DESC;
-- Customers with 'Medium' debt-to-income are likely to make prepayment.

-- 21. Are first-time home buyers more or less likely to prepay their loans?
SELECT First_Time_Home_Buyer,
    COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count,
    COUNT(*) AS Total_Count,
    round(((COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) * 100.0) / COUNT(*)),2) AS Prepayment_Percentage
FROM MBS_Prepayment
GROUP BY First_Time_Home_Buyer
ORDER BY First_Time_Home_Buyer;
-- first-time home buyers are less likely to prepay the loan.

-- 22. Are loans with more extended repayment periods more prone to prepayment?
SELECT Repay_Range,
    COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count,
    COUNT(*) AS Total_Count,
    round(((COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) * 100.0) / COUNT(*)),2) AS Prepayment_Percentage
FROM MBS_Prepayment
GROUP BY Repay_Range
ORDER BY Repay_Range;
-- The lower repayment range, i.e. 0 - 4 Years, will likely prepay the loan early.

-- 23. Is there any significant relationship between delinquency and prepayment behavior?
SELECT Ever_Delinquent,
    COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count,
    COUNT(*) AS Total_Count,
    round(((COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) * 100.0) / COUNT(*)),2) AS Prepayment_Percentage
FROM MBS_Prepayment
GROUP BY Ever_Delinquent
ORDER BY Ever_Delinquent;
-- There is no significant relationship between the delinquent and prepayment.

-- 24. Which loan purpose has the highest prepayment risk across the state?
SELECT Loan_Purpose, Property_State,
(SELECT COUNT(*) FROM MBS_Prepayment AS subquery 
  WHERE subquery.Loan_Purpose = MBS_Prepayment.Loan_Purpose 
  AND subquery.Property_State = MBS_Prepayment.Property_State 
  AND subquery.Prepayment = 'Prepaid') AS Prepaid_Count,
  COUNT(*) AS Total_Count,
  round((SELECT COUNT(*) FROM MBS_Prepayment AS subquery 
  WHERE subquery.Loan_Purpose = MBS_Prepayment.Loan_Purpose 
  AND subquery.Property_State = MBS_Prepayment.Property_State 
  AND subquery.Prepayment = 'Prepaid') * 100.0 / COUNT(*),2) AS Prepayment_Percentage
FROM MBS_Prepayment
GROUP BY Loan_Purpose, Property_State
ORDER BY Prepayment_Percentage DESC;
--LIMIT 5;
-- State Wisconsin, ALALABAMA, VERMONT, irrespective of the loan purpose, has a high prepayment risk.
-- Used subquery to get accurate results.

-- 25. How does prepayment risk differ between loans with varying loan purposes?
SELECT Loan_Purpose,
    COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count
FROM MBS_Prepayment
GROUP BY Loan_Purpose
ORDER BY Prepaid_count DESC;
-- Customers with a loan purpose of 'Purchase' are more likely to prepay the loan than others.

-- 26. How does a high interest rate affect prepayment risk?
SELECT 
CASE WHEN Interest_Rate > 7 THEN 'High Interest Rate' 
ELSE 'Low Interest Rate'
END AS Interest_Rate_Category,
COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count
FROM MBS_Prepayment
GROUP BY Interest_Rate_Category;
-- The loans with high interest rates are likely to be prepaid.

-- 27. How do interest rate, debt-to-income, and credit score affect prepayment risk?
SELECT Debt_to_Income_Range, Credit_Score_Range,
CASE 
WHEN Interest_Rate > 7 THEN 'High Interest Rate'
ELSE 'Low Interest Rate' END AS Interest_Rate_Category,
COUNT(CASE WHEN Prepayment = 'Prepaid' THEN 1 END) AS Prepaid_Count
FROM MBS_Prepayment
GROUP BY Interest_Rate_Category, Debt_to_Income_Range, Credit_Score_Range
ORDER BY Prepaid_count DESC;
-- Loans are prepaid, having a 'Medium' Debt-to-income range and 'Good' and 'Excellent' 
-- credit score range, whether the interest rate is high or low.

-- 28. What is the delinquent count by repayment range?
SELECT 
    Repay_Range,
    COUNT(CASE WHEN Ever_Delinquent = 0 THEN 0 END) AS Not_Delinquent,
    COUNT(CASE WHEN Ever_Delinquent = 1 THEN 1 END) AS Delinquent
FROM MBS_Prepayment
GROUP BY Repay_Range
ORDER BY Delinquent DESC;
-- the repayment range of 4 - 8 Years shows more delinquency.

