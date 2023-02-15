select cd.master_customer_number
         ,cd.master_company_name
         ,cd.edge_customer_number
         ,nvl(cd.company_name, cd.customer_name) customer_name
         ,to_date(rcf.activation_date_wid::string,'yyyymmdd') campaign_activation_date
         ,rcd.campaign_id
         ,trim(rcd.campaign_descr) campaign_descr
		 ,rcf.fix_date_wid
         ,qd.unit_number
         ,aivdm.vin
         ,aivdm.model_year
         ,aivdm.make_descr
         ,aivdm.model_descr
         ,aivdm.series_descr
         ,aiq.driver_name
         ,qd.customer_vehicle_id
         ,aiq.lease_term
         ,aiq.months_in_service
         ,aiq.remaining_months_in_service
         ,aiq.last_known_mileage
         ,aiq.last_known_mileage_date::date last_known_mileage_date
         ,aiq.lease_expiration_dt::date lease_expiration_dt
    from dev_dataservices_db.legacylooker.recall_campaign_f rcf
    join dev_dataservices_db.legacylooker.recall_campaign_d rcd on (rcf.campaign_wid=rcd.campaign_wid)
    join dev_dataservices_db.legacylooker.date_d dd_act on (rcf.activation_date_wid=dd_act.row_wid)
    join dev_dataservices_db.legacylooker.customer_d cd on (rcf.customer_wid=cd.customer_wid)
    join dev_dataservices_db.legacylooker.quote_d qd on (rcf.quote_wid=qd.quote_wid)
    join dev_dataservices_db.legacylooker.as_is_quote_d aiq on (rcf.quote_wid=aiq.quote_wid)
    join dev_dataservices_db.legacylooker.as_is_vehicle_d_mv aivdm on (rcf.vehicle_wid=aivdm.vehicle_wid)
    join dev_dataservices_db.legacylooker.as_is_customer_dh_mv cdh on (rcf.customer_wid=cdh.customer_wid)
   where
     rcf.activation_date_wid > 0
     and coalesce(rcd.campaign_status,'') <> 'Inactive'
     and coalesce(rcd.hold_status,'') <> 'HARD'
     and coalesce(qd.purch_flt_del_desc,'') <> 'Total Loss'
     and coalesce(qd.possn_flt_del_desc,'') <> 'Total Loss'
     and rcd.campaign_id is not null
     and aiq.status_short_descr in ('Activated', 'Active-Rev', 'Extend-Rev', 'Extended')
