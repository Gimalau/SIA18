BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled => TRUE,
    p_schema => 'FDBO',
    p_object => 'VW_CONS_PRICE_BAND_360',
    p_object_type => 'VIEW',
    p_object_alias => 'price_band_360',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
 
BEGIN
  ORDS.ENABLE_OBJECT(
    p_enabled => TRUE,
    p_schema => 'FDBO',
    p_object => 'AV_PRICE_BAND_STATS_V',
    p_object_type => 'VIEW',
    p_object_alias => 'price_band_stats',
    p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
