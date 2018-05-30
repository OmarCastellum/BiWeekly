-----overall_by_period
WITH overall AS (SELECT

rep_yr, 
month, 
SUM(CASE WHEN ft_rr = 'FT' THEN 1 ELSE 0 END) AS ft, 
SUM(CASE WHEN ft_rr = 'RR' THEN 1 ELSE 0 END) AS rr,
SUM(CASE WHEN categ = 'OBF' THEN 1 ELSE 0 END) AS obf,
SUM(CASE WHEN categ = 'OBF' AND VALID = 'YES' THEN 1 ELSE 0 END) AS vobf,
SUM(CASE WHEN categ = 'ELF' AND LOWER(frequency_1) NOT LIKE 'nff%' 
    AND LOWER(frequency_1) NOT LIKE 'no failure%'
    AND LOWER(frequency_1) NOT LIKE 'no func%'
    AND LOWER(frequency_1) NOT LIKE 'first%'
    AND LOWER(frequency_1) NOT LIKE 'pass%'
    AND frequency_1 IS NOT NULL
    THEN 1 ELSE 0 END) AS velf,
SUM(CASE WHEN LOWER(frequency_1) LIKE 'nff%' 
    OR LOWER(frequency_1) LIKE 'no failure%'
    OR LOWER(frequency_1) LIKE 'no func%'
    THEN 1 ELSE 0 END) AS NFF,
SUM(CASE WHEN status = 'S' THEN 1 ELSE 0 END) AS scrap,
ROUND(AVG(ob_mtbr),0) AS mtbr,
SUM(CASE WHEN categ = 'ELF' AND VALID = 'YES' THEN 1 ELSE 0 END) AS valid_elf
FROM biwk
GROUP BY 1, 2)

SELECT 

    rep_yr, month,
    ft+rr AS vol,
    ft, rr, obf,
    vobf, velf, nff, valid_elf,
    scrap, mtbr

FROM overall

ORDER BY 1 ASC, 2 ASC
----------------overall by area (data_o_area)
WITH overall_area AS (
SELECT

commodity,
SUM(CASE WHEN ft_rr = 'FT' THEN 1 ELSE 0 END) AS ft, 
SUM(CASE WHEN ft_rr = 'RR' THEN 1 ELSE 0 END) AS rr,
SUM(CASE WHEN categ = 'OBF' THEN 1 ELSE 0 END) AS obf,
SUM(CASE WHEN categ = 'OBF' AND VALID = 'YES' THEN 1 ELSE 0 END) AS vobf,
SUM(CASE WHEN categ = 'ELF' AND LOWER(frequency_1) NOT LIKE 'nff%' 
    AND LOWER(frequency_1) NOT LIKE 'no failure%'
    AND LOWER(frequency_1) NOT LIKE 'no func%'
    AND LOWER(frequency_1) NOT LIKE 'first%'
    AND LOWER(frequency_1) NOT LIKE 'pass%'
    AND frequency_1 IS NOT NULL
    THEN 1 ELSE 0 END) AS velf,
SUM(CASE WHEN LOWER(frequency_1) LIKE 'nff%' 
    OR LOWER(frequency_1) LIKE 'no failure%'
    OR LOWER(frequency_1) LIKE 'no func%'
    THEN 1 ELSE 0 END) AS NFF,
SUM(CASE WHEN status = 'S' THEN 1 ELSE 0 END) AS scrap,
SUM(CASE WHEN categ = 'ELF' AND VALID = 'YES' THEN 1 ELSE 0 END) AS valid_elf,
ROUND(AVG(ob_mtbr),0) AS mtbr
FROM biwk
WHERE finish_process BETWEEN '2017-05-01 00:00:00' AND '2018-04-30 23:59:59'
AND commodity IN ('SDM1',
'Presenter',
'Dispenser Pick Module',
'Glory BNA',
'Check Acceptor SCPM',
'SDM2',
'Electronic Module',
'Thermal Printers',
'S2',
'Card Reader',
'Spray Module',
'CPM2')
GROUP BY 1)
SELECT 
    commodity, ft+rr AS vol,
    ft, rr, obf, vobf, velf,
    nff, scrap, valid_elf, mtbr
FROM overall_area
----------data_p_Sum
WITH overall AS (SELECT

commodity,
rep_yr, 
month, 
SUM(CASE WHEN ft_rr = 'FT' THEN 1 ELSE 0 END) AS ft, 
SUM(CASE WHEN ft_rr = 'RR' THEN 1 ELSE 0 END) AS rr,
SUM(CASE WHEN categ = 'OBF' THEN 1 ELSE 0 END) AS obf,
SUM(CASE WHEN categ = 'OBF' AND VALID = 'YES' THEN 1 ELSE 0 END) AS vobf,
SUM(CASE WHEN categ = 'ELF' AND LOWER(frequency_1) NOT LIKE 'nff%' 
    AND LOWER(frequency_1) NOT LIKE 'no failure%'
    AND LOWER(frequency_1) NOT LIKE 'no func%'
    AND LOWER(frequency_1) NOT LIKE 'first%'
    AND LOWER(frequency_1) NOT LIKE 'pass%'
    AND frequency_1 IS NOT NULL
    THEN 1 ELSE 0 END) AS velf,
SUM(CASE WHEN LOWER(frequency_1) LIKE 'nff%' 
    OR LOWER(frequency_1) LIKE 'no failure%'
    OR LOWER(frequency_1) LIKE 'no func%'
    THEN 1 ELSE 0 END) AS NFF,
SUM(CASE WHEN status = 'S' THEN 1 ELSE 0 END) AS scrap,
ROUND(AVG(ob_mtbr),0) AS mtbr
FROM biwk
GROUP BY 1, 2, 3)

SELECT 
	commodity,
	rep_yr, month,
	ft+rr AS vol,
	ft, rr, obf,
	vobf, velf, nff,
	scrap, mtbr

FROM overall

ORDER BY 1 ASC, 2 ASC, 3 ASC
---------------
SELECT
    commodity, 
    frequency_1,
    COUNT(*) AS qty
FROM biwk 
WHERE frequency_1 IS NOT NULL
AND finish_process BETWEEN '2018-04-04 00:00:00' AND '2018-04-18 23:59:59'
AND categ IN ('OBF','ELF','W365')
GROUP BY 1, 2
ORDER BY 1 ASC, 3 DESC
--------------
WITH filtro AS (WITH cte AS (SELECT
	commodity, 
	frequency_2,
	COUNT(*) AS qty
FROM biwk 
WHERE frequency_2 IS NOT NULL
AND finish_process BETWEEN '2018-04-04 00:00:00' AND '2018-04-18 23:59:59'
AND categ IN ('OBF','ELF','W365')
GROUP BY 1, 2)

SELECT 
*, 
SUM(qty) OVER (PARTITION BY commodity) AS tot,
ROW_NUMBER() OVER (PARTITION BY commodity ORDER BY qty DESC) AS row_num 
FROM cte)

SELECT 
* 
FROM filtro WHERE row_num <= 5
----total