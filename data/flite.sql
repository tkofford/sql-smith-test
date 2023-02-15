SELECT
cd.edge_customer_Number
, cpd.cust_policy_id
, cpd.ins_carrier_num
, CASE WHEN cpd.policy_type_num=1 THEN 'Liability' ELSE 'Physical Damage' END AS Policy_type
, cpd.policy_number
, cpd.cust_policy_descr
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_loss_amt ELSE 0 END) AS Curr_PY_Losses
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-1-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_loss_amt ELSE 0 END) AS Curr_PY_minus1_Losses
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-2-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_loss_amt ELSE 0 END) AS Curr_PY_minus2_Losses
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-3-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_loss_amt ELSE 0 END) AS Curr_PY_minus3_Losses
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_premium_amt ELSE 0 END) AS Curr_PY_Premiums
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-1-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_premium_amt ELSE 0 END) AS Curr_PY_minus1_Premiums
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-2-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_premium_amt ELSE 0 END) AS Curr_PY_minus2_Premiums
, sum(CASE WHEN psd.cal_year=curr_date.cal_year-3-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_premium_amt ELSE 0 END) AS Curr_PY_minus3_Premiums
, sum(CASE WHEN psd.cal_year>=curr_date.cal_year-3-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_loss_amt ELSE 0 END) 
  / NULLIF(sum(CASE WHEN psd.cal_year>=curr_date.cal_year-3-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END THEN cpya.ltd_premium_amt ELSE 0 END),0) 
  * 100 AS Loss_Ratio
FROM
legacylooker.customer_policy_year_a cpya
JOIN legacylooker.customer_policy_d cpd ON cpd.customer_policy_wid=cpya.customer_policy_wid
JOIN legacylooker.customer_d cd ON cd.customer_wid=cpya.customer_wid 
JOIN legacylooker.date_d psd ON psd.row_wid=cpya.policy_year_start_date_wid
LEFT JOIN legacylooker.date_d curr_date ON curr_date.dw_current_flag=1
WHERE 
psd.cal_year>=curr_date.cal_year-3-CASE WHEN psd.cal_month>curr_date.cal_month THEN 1 ELSE CASE WHEN psd.cal_month=curr_date.cal_month AND psd.day_of_month<curr_date.day_of_month THEN 1 ELSE 0 END END
GROUP BY cd.edge_customer_Number, cpd.cust_policy_id, cpd.ins_carrier_num, CASE WHEN cpd.policy_type_num=1 THEN 'Liability' ELSE 'Physical Damage' END, cpd.policy_number, cpd.cust_policy_descr