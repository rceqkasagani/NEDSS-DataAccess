DECLARE @date_value date = {{Enter_Date}};
DECLARE @jurisdiction_value NVARCHAR(MAX) = {{Jurisdiction}};

-- #todo (Upasana): Update commented column selection when new data about the report is available. 
--Jurisdiction 
SELECT
    I.JURISDICTION_NM AS Jurisdiction,
    COUNT(*) AS '#Cases',
    -- (COUNT(CASE WHEN INVCTE.CC_CLOSED_DT IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% LTF', #todo
    (COUNT(CASE WHEN P.PATIENT_DOB IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% DOB',
    (COUNT(CASE WHEN P.PATIENT_RACE_ALL IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '%Race',
    (COUNT(CASE WHEN P.PATIENT_ZIP IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% ZIP',
    (COUNT(CASE WHEN C.CONDITION_DESC IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Diagnosis',
    (COUNT(CASE WHEN I.ILLNESS_ONSET_DT IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Onset',
    (COUNT(CASE WHEN I.HSPTLIZD_IND IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Hosp',
    (COUNT(CASE WHEN DIH.HIV_REFER_FOR_900_TEST IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% HIV Test Referred',
    -- (COUNT(CASE WHEN INVCTE.CA_PATIENT_INTV_STATUS IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Interviewed', #todo
    (COUNT(CASE WHEN I.PATIENT_PREGNANT_IND IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Preg Ans',
    -- (COUNT(CASE WHEN INVCTE.TREATMENT_NM IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Treated', #todo
    AVG(CASE WHEN ISNUMERIC(C.CONDITION_DESC) = 1 THEN CONVERT (NUMERIC,C.CONDITION_DESC) END) AS 'Ave Diagnosis to Treat',
    AVG(DATEDIFF(DAY, I.DIAGNOSIS_DT, I.EARLIEST_RPT_TO_PHD_DT)) AS 'Ave Diagnosis to Local Days',
    AVG(DATEDIFF(DAY, I.EARLIEST_RPT_TO_PHD_DT, I.EARLIEST_RPT_TO_STATE_DT)) AS 'Ave Local to State Days'
FROM
    F_PAGE_CASE FPC
    JOIN D_PATIENT P ON P.PATIENT_KEY = FPC.PATIENT_KEY
    JOIN INVESTIGATION I ON I.INVESTIGATION_KEY = FPC.INVESTIGATION_KEY
    JOIN CONDITION C ON C.CONDITION_KEY = FPC.CONDITION_KEY
    JOIN D_INV_HIV DIH ON DIH.D_INV_HIV_KEY = FPC.D_INV_HIV_KEY
    JOIN D_INV_RISK_FACTOR DIRF ON DIRF.D_INV_RISK_FACTOR_KEY = FPC.D_INV_RISK_FACTOR_KEY 
    JOIN D_INV_TREATMENT DIT ON DIT.D_INV_TREATMENT_KEY = FPC.D_INV_TREATMENT_KEY
WHERE 
    I.CASE_RPT_MMWR_YR = YEAR(@date_value) 
    AND I.CASE_RPT_MMWR_WK = DATEPART(WK, @date_value)
    AND I.JURISDICTION_NM = @jurisdiction_value
GROUP BY
    I.JURISDICTION_NM

UNION ALL

--State
SELECT
    'Statewide' AS Jurisdiction,
    COUNT(*) AS '#Cases',
    -- (COUNT(CASE WHEN INVCTE.CC_CLOSED_DT IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% LTF',
    (COUNT(CASE WHEN P.PATIENT_DOB IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% DOB',
    (COUNT(CASE WHEN P.PATIENT_RACE_ALL IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '%Race',
    (COUNT(CASE WHEN P.PATIENT_ZIP IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% ZIP',
    (COUNT(CASE WHEN C.CONDITION_DESC IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Diagnosis',
    (COUNT(CASE WHEN I.ILLNESS_ONSET_DT IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Onset',
    (COUNT(CASE WHEN I.HSPTLIZD_IND IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Hosp',
    (COUNT(CASE WHEN DIH.HIV_REFER_FOR_900_TEST IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% HIV Test Referred',
    -- (COUNT(CASE WHEN INVCTE.CA_PATIENT_INTV_STATUS IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Interviewed',
    (COUNT(CASE WHEN I.PATIENT_PREGNANT_IND IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Preg Ans',
    -- (COUNT(CASE WHEN INVCTE.TREATMENT_NM IS NOT NULL THEN 1 END) * 100.0)/COUNT(*) AS '% Treated',
    AVG(CASE WHEN ISNUMERIC(C.CONDITION_DESC) = 1 THEN CONVERT (NUMERIC,C.CONDITION_DESC) END) AS 'Ave Diagnosis to Treat',
    AVG(DATEDIFF(DAY, I.DIAGNOSIS_DT, I.EARLIEST_RPT_TO_PHD_DT)) AS 'Ave Diagnosis to Local Days',
    AVG(DATEDIFF(DAY, I.EARLIEST_RPT_TO_PHD_DT, I.EARLIEST_RPT_TO_STATE_DT)) AS 'Ave Local to State Days'
FROM
    F_PAGE_CASE FPC
    JOIN D_PATIENT P ON P.PATIENT_KEY = FPC.PATIENT_KEY
    JOIN INVESTIGATION I ON I.INVESTIGATION_KEY = FPC.INVESTIGATION_KEY
    JOIN CONDITION C ON C.CONDITION_KEY = FPC.CONDITION_KEY
    JOIN D_INV_HIV DIH ON DIH.D_INV_HIV_KEY = FPC.D_INV_HIV_KEY
    JOIN D_INV_RISK_FACTOR DIRF ON DIRF.D_INV_RISK_FACTOR_KEY = FPC.D_INV_RISK_FACTOR_KEY 
    JOIN D_INV_TREATMENT DIT ON DIT.D_INV_TREATMENT_KEY = FPC.D_INV_TREATMENT_KEY
WHERE 
    I.CASE_RPT_MMWR_YR = YEAR(@date_value) 
    AND I.CASE_RPT_MMWR_WK = DATEPART(WK, @date_value)
    AND I.JURISDICTION_NM IS NOT NULL