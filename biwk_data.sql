drop table if exists tmp_biweekly;

SELECT

ordfabfr.rowid as id_row,
ordfabfr.docser,
ordfabfr.tercer,
ordfabfr.codart,
ordfabfr.artsal,
ordfabfr.etiqueta,
ordfabfr.etiant,
ordfabfr.numser,
ordfabfr.status,
ordfabfr.wed,
ordfabfr.fecent,
ordfabfr.fecent - TRUNC(o1.fecfin) AS d_out,
ordfabfr.out,
ordfabfr.revlev_in,
ordfab.fecfin,
month(ordfab.fecfin) as repair_month,
year(ordfab.fecfin) as repair_year,
"" as repair_week,
case
  when left(ordfabfr.etiant, 1) = "T" then "RR"
  else "FT"
 end as FT_RR,
 "" as commodity,
 "" as pn_description,
 case
   when tbl_qc_data_hist.categ = "OBF" then tbl_qc_data_hist.categ
   when ordfabfr.out <=180 and ordfabfr.out is not null then "ELF"
   when ordfabfr.out > 180 and ordfabfr.out <= 365 then "W365"
   else "DEF"
end as category,
tbl_qc_data_hist.no_report_failure_found,
tbl_qc_data_hist.frequency_1,
tbl_qc_data_hist.frequency_2,
tbl_qc_data_hist.valid,
date(entradal_oem.recep_date) AS ob_date

FROM ordfabfr 
  INNER JOIN ordfab 
    ON ordfab.cabid = ordfabfr.cabid
  INNER JOIN garticul 
    ON garticul.codigo = ordfabfr.artsal
  LEFT OUTER JOIN ordfabfr AS of1
    ON of1.etiqueta = ordfabfr.etiant
    AND of1.fecent >= '01-01-2008'
  INNER JOIN ordfab o1
    ON o1.cabid = of1.cabid
  LEFT OUTER JOIN tbl_qc_data_hist 
    ON ordfabfr.docser = tbl_qc_data_hist.batch
  LEFT OUTER JOIN entradal_oem 
    ON ordfabfr.revlev_in = entradal_oem.serial_num

WHERE ordfabfr.tercer IN ('T-00603', 'T-00696', 'T-00695', 'T-01175')
  AND ordfab.delega = 'US0102'
  AND ordfab.fecfin >= TO_DATE ('2017-10-31 00:00:00', '%Y-%m-%d %H:%M:%S')


INTO TEMP tmp_biweekly with no log;


select 

tmp_biweekly.id_row,
tmp_biweekly.docser,
tmp_biweekly.tercer,
tmp_biweekly.codart,
tmp_biweekly.artsal,
tmp_biweekly.etiqueta,
tmp_biweekly.etiant,
tmp_biweekly.numser,
tmp_biweekly.status,
tmp_biweekly.wed,
tmp_biweekly.fecent,
tmp_biweekly.out,
tmp_biweekly.revlev_in,
tmp_biweekly.fecfin,
tmp_biweekly.repair_month,
tmp_biweekly.repair_year,
tmp_biweekly.repair_week,
tmp_biweekly.FT_RR,
tmp_biweekly.commodity,
tmp_biweekly.pn_description,
tmp_biweekly.category,
tmp_biweekly.no_report_failure_found,
tmp_biweekly.frequency_1,
tmp_biweekly.frequency_2,
tmp_biweekly.valid,
tmp_biweekly.ob_date,
case
  when tmp_biweekly.ob_date is null and tmp_biweekly.FT_RR = "RR" then tmp_biweekly.out
  when tmp_biweekly.FT_RR = "RR" and tmp_biweekly.ob_date is not null then tmp_biweekly.ob_date - (tmp_biweekly.fecent - tmp_biweekly.out)
end as ob_mtbr,
case 
  when tmp_biweekly.FT_RR = "RR" then tmp_biweekly.fecent - tmp_biweekly.out
end as cj_prev_rep,
iso8601_weeknum(tmp_biweekly.fecfin) as week


from tmp_biweekly;
