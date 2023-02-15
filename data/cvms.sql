SELECT f.monthly_snapshot_date_wid
       ,d.per_name_month
       ,o.group_id
       ,o.branch_id
       ,coalesce(c.company_name,c.customer_name) customer_name
       ,c.edge_customer_number
       ,c.master_company_name
       ,c.master_customer_number
       ,cdh.ancestor_customer_number as search_customer_number
       ,cdh.distance as search_distance
       ,c.customer_since_dt
       ,c.customer_type_descr
       ,v.vin
       ,v.vehicle_id
       ,q.unit_number
       ,q.quote_number
       ,lt.lease_prod_number
       ,lt.lease_type_descr
       ,q.vehicle_order_status
       ,q.lease_term
       ,q.starting_mileage
       ,q.contract_mileage
       ,q.alternate_driver_flg
       ,q.driver_contact_id
       ,q.driver_name
       ,q.driver_email
       ,q.driver_cell_phone
       ,q.garage_street_address_1
       ,q.garage_street_address_2
       ,q.garage_street_address_3
       ,q.garage_street_address_4
       ,q.garage_city
       ,q.garage_state_prov
       ,q.garage_county_name
       ,q.garage_postal_code
       ,q.garage_country_code
       ,q.turn_in_unit_number
       ,q.turn_in_vin
       ,aiq.turn_in_unit_active_ind
       ,aiq.has_approved_replacement_ind
       ,aiq.approved_repl_vehicle_vin
       ,aiq.approved_repl_unit_number
       ,NULL as auto_data_code --gap - add to VEHICLE_D
       ,q.maint_veh_size_code
       ,q.maint_category_descr
       ,q.maint_card_cost_code
       ,q.customer_vehicle_id
       ,q.customer_vehicle_category
       ,q.liability_insurance_flg
       ,q.physical_damage_flg
       ,q.telematics_flg
       ,q.maintenance_management_flg
       ,q.custom_maintenance_flg
       ,q.full_maintenance_flg
       ,cvmsd.license_administration_flg
       ,q.ame_flag
       ,q.pool_car_ind
       ,aiq.active_recall_count
       ,pm.purchase_method_num
       ,pm.purchase_method_name
       ,vc.vehicle_class_num
       ,vc.vehicle_class_descr
       ,v.model_year
       ,v.make_number
       ,v.make_descr
       ,v.model_number
       ,v.model_descr
       ,v.series_number
       ,v.series_descr
       ,v.exterior_color
       ,v.interior_color
       ,v.gross_veh_weight
       ,v.gross_veh_weight_ratio_edit as gross_veh_weight_ratio
       ,v.horsepower
       ,v.drive_train
       ,v.style_name
       ,v.num_of_cylinders
       ,v.cylinder_config
       ,v.transmission
       ,v.fuel_type
       ,v.num_of_passengers
       ,v.license_plate_number
       ,v.license_plate_state
       ,v.license_plate_type
       ,v.license_plate_expiration_dt
       ,v.user_entered_exp_annual_miles
       ,v.fleet_status
       ,case v.fleet_status
            when 'NLA' then 'COVP'
            when 'NL' then 'COV'
            else v.fleet_status
         end as reporting_fleet_status
       ,case v.fleet_status
            when 'L'  then 'Leased Vehicle'
            when 'NLA' then 'Client-Owned with Products'
            when 'NVP' then 'Non-Vehicles with Products'
            when 'NL' then 'Client-Owned'
         end as reporting_fleet_status_descr
       ,ae.employee_display_name as ae_employee_display_name
       ,ae.employee_eid as ae_employee_eid
       ,ae.employee_email as ae_employee_email
       ,am.employee_display_name as csm_employee_display_name
       ,am.employee_eid as csm_employee_eid
       ,am.employee_email as csm_employee_email
       ,case when f.eff_apprvd_quote_date_wid = -1 then NULL else to_date(to_char(f.eff_apprvd_quote_date_wid),'yyyymmdd') end eff_apprvd_quote_date
       ,case when f.eff_actvtn_quote_date_wid = -1 then NULL else to_date(to_char(f.eff_actvtn_quote_date_wid),'yyyymmdd') end eff_actvtn_quote_date
       ,to_date(to_char(case f.delivery_quote_date_wid when -1 then null else f.delivery_quote_date_wid end),'yyyymmdd') delivery_quote_date
       ,aiq.lease_expiration_dt
       ,f.months_in_service
       ,to_date(to_char(case f.fmx_start_date_wid when -1 then null else f.fmx_start_date_wid end),'yyyymmdd') fmx_start_date
       ,to_date(to_char(case f.cmx_start_date_wid when -1 then null else f.cmx_start_date_wid end),'yyyymmdd') cmx_start_date
       ,to_date(to_char(case f.mmx_start_date_wid when -1 then null else f.mmx_start_date_wid end),'yyyymmdd') mmx_start_date
       ,NULL as total_ancillaries --gap
       ,f.gross_profit
       ,case when q.lease_type = 'Net Lease' then NULL else f.delivered_price end as delivered_price
       ,f.capitalized_price_reduction
       ,f.tax_on_cpr
       ,f.gain_on_prior
       ,f.tax_gain_on_prior
       ,f.tax_trade_amt
       ,q.contract_mileage / q.lease_term * 12 as annual_business_miles
       ,case when q.lease_type = 'Net Lease' then NULL else q.depreciation_percentage*100 end as depreciation_percentage
       ,case when q.lease_type = 'Net Lease' then NULL else f.mnthly_depreciation_amt end as mnthly_depreciation_amt
       ,f.mnthly_interest_amt
       ,f.mnthly_management_fee
       ,f.mnthly_int_adjstmnt_amt
       ,f.mnthly_interest_amt + f.mnthly_management_fee + f.mnthly_int_adjstmnt_amt as mnthly_lease_charge
       ,f.mnthly_use_tax_amt
       ,f.mnthly_profit_amt
       ,f.total_mnthly_rent
       ,f.accumulated_prop_tax_amt
       ,f.service_charge
       ,f.license_admin_monthly_charge
       ,f.frontend_markup
       ,f.fm_admin_fee
       ,f.fm_service_sub_total
       ,f.fm_markup_down
       ,f.lux_tax_amt
       ,f.lic_fee_amt
       ,case when q.lease_type = 'Net Lease' then NULL else f.current_rbv end as current_rbv
       ,case when q.lease_type = 'Net Lease' then NULL else f.terminal_rbv end as terminal_rbv
       ,f.ame_price
       ,f.ame_price_capped
       ,f.ame_price_billed
       ,f.ame_cost
       ,f.ame_cost_capped
       ,f.ame_cost_billed
       ,q.fact_invoice_amt
       ,f.cust_vehicle_cost
       ,f.erac_vehicle_cost
       ,f.capitalizd_cost
       ,f.capitalizd_sls_tax_amt
       ,f.non_capitalizd_sls_tax_amt
       ,f.capitalizd_lic_fee_amt
       ,f.non_capitalizd_lic_fee_amt
       ,f.capitalizd_regn_fee_amt
       ,f.non_capitalizd_regn_fee_amt
       ,f.capitalizd_cd_fee_amt
       ,f.non_capitalizd_cd_fee_amt
       ,f.capitalizd_othr_fee_amt
       ,f.non_capitalizd_othr_fee_amt
       ,f.capitalizd_ame_cost_amt
       ,f.non_capitalizd_ame_cost_amt
       ,f.interest_rate_prime
       ,f.interest_rate_adj
       ,f.last_known_mileage
       ,f.last_known_mileage_date
       ,f.projected_current_mileage
       ,f.market_value
       ,f.future_12_mo_market_value
       ,f.future_12_mo_mileage
       ,f.future_12_mo_rbv
       ,f.odometer_diff_12mo
       ,f.odometer_diff_yago_12mo
       ,f.maint_amt_12mo
       ,f.cust_maint_amt_12mo
       ,f.ltd_maint_amt
       ,f.ltd_cust_maint_amt
  FROM legacy.cust_veh_month_snp_f f
  join legacy.cust_veh_month_snp_d cvmsd on (f.monthly_snapshot_date_wid=cvmsd.monthly_snapshot_date_wid and f.vehicle_wid=cvmsd.vehicle_wid and f.quote_wid=cvmsd.quote_wid)
  join legacy.date_d d on (f.monthly_snapshot_date_wid=d.row_wid)
  join legacy.customer_d c on (f.customer_wid=c.customer_wid)
  join legacy.vehicle_d v on (f.vehicle_wid=v.vehicle_wid)
  join legacy.quote_d q on (f.quote_wid=q.quote_wid)
  join legacy.as_is_quote_d aiq on (f.quote_wid=aiq.quote_wid)
  join legacy.vehicle_class_d vc on (f.vehicle_class_wid=vc.vehicle_class_wid)
  join legacy.org_d o on (f.org_wid=o.org_wid)
  join legacy.lease_type_d lt on (f.lease_type_wid=lt.lease_type_wid)
  join legacy.purchase_method_d pm on (f.purchase_method_wid=pm.purchase_method_wid)
  join legacy.as_is_customer_dh_mv cdh on (f.customer_wid=cdh.customer_wid)
  join legacy.employee_d ae on (f.ae_employee_wid=ae.employee_wid)
  join legacy.employee_d am on (f.am_employee_wid=am.employee_wid)
