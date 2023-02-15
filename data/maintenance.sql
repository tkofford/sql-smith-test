SELECT f.monthly_snapshot_date_wid
       ,d.per_name_month
       ,v.vin
       ,v.vehicle_id
       ,q.unit_number
       ,q.quote_number
       ,mt.maint_type_abbrev
       ,mt.maint_type_descr
       ,o.group_id
       ,o.branch_id
       ,coalesce(c.company_name,c.customer_name) customer_name
       ,c.edge_customer_number
       ,c.master_company_name
       ,c.master_customer_number
       ,cdh.ancestor_customer_number as search_customer_number
       ,cdh.distance as search_distance
       ,v.fleet_status
       ,q.months_in_service
       ,q.remaining_months_in_service
       ,q.quote_status_code
       ,q.status_short_descr
       ,f.mos_on_maint
       ,f.mos_on_maint_product
       ,f.mileage_at_maint_product_start
       ,f.miles_on_maint
       ,f.monthly_mileage
       ,f.avg_mo_mileage_3mo
       ,f.projected_current_mileage
       ,f.last_maint_miles
       ,f.last_maint_dt_wid
       ,f.last_oil_chg_dt_wid
       ,f.last_oil_chg_miles
       ,f.last_brake_rep_dt_wid
       ,f.last_brake_rep_miles
       ,f.ltd_unit_brake_count
       ,f.brake_set_qty
       ,f.remaining_brake_set_qty
       ,f.last_tire_dt_wid
       ,f.last_tire_miles
       ,f.ltd_unit_tire_count
       ,f.tire_qty
       ,f.remaining_tire_qty
       ,f.ltd_maint_spend
       ,f.ltd_maint_fee
       ,f.ltd_avg_mo_spend_fee
  FROM legacy.maint_cust_veh_month_snp_f f
  join legacy.date_d d on (f.monthly_snapshot_date_wid=d.row_wid)
  join legacy.as_is_quote_d q on (f.quote_wid=q.quote_wid)
  join legacy.vehicle_d v on (f.vehicle_wid=v.vehicle_wid)
  join legacy.maint_type_d mt on (f.maint_type_wid=mt.maint_type_wid)
  join legacy.customer_d c on (f.customer_wid=c.customer_wid)
  join legacy.as_is_customer_dh_mv cdh on (f.customer_wid=cdh.customer_wid)
  join legacy.org_d o on (f.org_wid=o.org_wid)
  where 1 = 1
