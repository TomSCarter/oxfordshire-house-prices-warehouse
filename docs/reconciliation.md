# Report from Land Registry pipeline generating v3 processed data 
 - match_table at row 14
 
```
                               step     rows  unique_sales  col_count  expired  floor_height_nulls  tenure_nulls  number_heated_rooms_nulls  built_form_nulls  imputed_count
0              load.read_price_paid   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
1                     load.read_epc   338323           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
2     load.filter_local_authorities   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
3   epc: normalise.strip_whitespace   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
4      epc: normalise.remove_commas   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
5      epc: normalise.build_address   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
6       epc: normalise.build_tokens   338318           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
7    pp: normalise.strip_whitespace   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
8       pp: normalise.remove_commas   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
9       pp: normalise.build_address   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
10       pp: normalise.build_tokens   135557           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
11          match.merge_on_postcode  4272749           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
12      match.filter_subset_matches   171240      119532.0        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
13       match.select_match_columns   171240           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
14                 save.match_table   171240           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
15     match.drop_ambiguous_matches   164823      118222.0        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
16         match.select_presale_epc   114490           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
17       match.select_final_columns   114490           NaN       36.0      NaN                 NaN           NaN                        NaN               NaN            NaN
18        features.add_epc_age_band   114490           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
19        features.add_expired_flag   114490           NaN        NaN   1151.0                 NaN           NaN                        NaN               NaN            NaN
20   features.add_calendar_features   114490           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
21     clean.nullify_invalid_values   114490           NaN        NaN      NaN              2575.0       35004.0                    32426.0            2507.0            NaN
22           clean.apply_exclusions   114424           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
23        clean.impute_floor_height   114424           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN         2516.0
24                save.save_parquet   114424           NaN        NaN      NaN                 NaN           NaN                        NaN               NaN            NaN
```
