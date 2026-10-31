\ Model 2024-11-06_02-28-52
\ LP format - for model browsing. Use MPS format to capture full model detail.
Maximize
  flow_source_0 + flow_source_1 + flow_source_2 + flow_source_3
Subject To
 hold_constraint_0: hold_0_1 + hold_0_2 + hold_0_3 + hold_0_4 + hold_0_5
   + hold_0_6 + hold_0_7 + hold_0_8 + hold_0_9 + hold_0_10 + hold_0_11
   + hold_0_12 + hold_0_13 + hold_0_14 + hold_0_15 + hold_0_16 + hold_0_17
   + hold_0_18 = 1
 end_constraint_0: start_0 + hold_0_1 + 2 hold_0_2 + 3 hold_0_3
   + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7 + 8 hold_0_8
   + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 12 hold_0_12 + 13 hold_0_13
   + 14 hold_0_14 + 15 hold_0_15 + 16 hold_0_16 + 17 hold_0_17
   + 18 hold_0_18 <= 60
 hold_constraint_1: hold_1_1 + hold_1_2 + hold_1_3 + hold_1_4 + hold_1_5
   + hold_1_6 + hold_1_7 + hold_1_8 + hold_1_9 + hold_1_10 + hold_1_11
   + hold_1_12 + hold_1_13 + hold_1_14 + hold_1_15 + hold_1_16 + hold_1_17
   + hold_1_18 = 1
 end_constraint_1: start_1 + hold_1_1 + 2 hold_1_2 + 3 hold_1_3
   + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7 + 8 hold_1_8
   + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 12 hold_1_12 + 13 hold_1_13
   + 14 hold_1_14 + 15 hold_1_15 + 16 hold_1_16 + 17 hold_1_17
   + 18 hold_1_18 <= 60
 hold_constraint_2: hold_2_1 + hold_2_2 + hold_2_3 + hold_2_4 + hold_2_5
   + hold_2_6 + hold_2_7 + hold_2_8 + hold_2_9 + hold_2_10 + hold_2_11
   + hold_2_12 + hold_2_13 + hold_2_14 + hold_2_15 + hold_2_16 + hold_2_17
   + hold_2_18 = 1
 end_constraint_2: start_2 + hold_2_1 + 2 hold_2_2 + 3 hold_2_3
   + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7 + 8 hold_2_8
   + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 12 hold_2_12 + 13 hold_2_13
   + 14 hold_2_14 + 15 hold_2_15 + 16 hold_2_16 + 17 hold_2_17
   + 18 hold_2_18 <= 60
 hold_constraint_3: hold_3_1 + hold_3_2 + hold_3_3 + hold_3_4 + hold_3_5
   + hold_3_6 + hold_3_7 + hold_3_8 + hold_3_9 + hold_3_10 + hold_3_11
   + hold_3_12 + hold_3_13 + hold_3_14 + hold_3_15 + hold_3_16 + hold_3_17
   + hold_3_18 = 1
 end_constraint_3: start_3 + hold_3_1 + 2 hold_3_2 + 3 hold_3_3
   + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7 + 8 hold_3_8
   + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 12 hold_3_12 + 13 hold_3_13
   + 14 hold_3_14 + 15 hold_3_15 + 16 hold_3_16 + 17 hold_3_17
   + 18 hold_3_18 <= 60
 node_flow_constraint_0: flow_source_0 - flow_0_sink - flow_0_1 + flow_1_0
   - flow_0_2 + flow_2_0 - flow_0_3 + flow_3_0 = 0
 node_flow_constraint_1: flow_source_1 - flow_1_sink + flow_0_1 - flow_1_0
   - flow_1_2 + flow_2_1 - flow_1_3 + flow_3_1 = 0
 node_flow_constraint_2: flow_source_2 - flow_2_sink + flow_0_2 - flow_2_0
   + flow_1_2 - flow_2_1 - flow_2_3 + flow_3_2 = 0
 node_flow_constraint_3: flow_source_3 - flow_3_sink + flow_0_3 - flow_3_0
   + flow_1_3 - flow_3_1 + flow_2_3 - flow_3_2 = 0
 node_throughput_constraint_0: - 24422.68313024132 hold_0_1
   - 11751.67055226967 hold_0_2 - 7569.127326043289 hold_0_3
   - 5481.216997173115 hold_0_4 - 4380.946286549032 hold_0_5
   - 3525.198937755591 hold_0_6 - 3021.840332969844 hold_0_7
   - 2535.881991547678 hold_0_8 - 2158.990705603894 hold_0_9
   - 1942.714881742995 hold_0_10 - 1678.975410437803 hold_0_11
   - 1462.934405463458 hold_0_12 - 1349.650080962921 hold_0_13
   - 1185.805024502931 hold_0_14 - 1044.533345056491 hold_0_15
   - 912.9871513241026 hold_0_16 - 802.5639739024219 hold_0_17
   - 758.1085541470287 hold_0_18 + flow_source_0 + flow_1_0 + flow_2_0
   + flow_3_0 <= 0
 node_throughput_constraint_1: - 24422.68313024132 hold_1_1
   - 11751.67055226967 hold_1_2 - 7569.127326043289 hold_1_3
   - 5481.216997173115 hold_1_4 - 4380.946286549032 hold_1_5
   - 3525.198937755591 hold_1_6 - 3021.840332969844 hold_1_7
   - 2535.881991547678 hold_1_8 - 2158.990705603894 hold_1_9
   - 1942.714881742995 hold_1_10 - 1678.975410437803 hold_1_11
   - 1462.934405463458 hold_1_12 - 1349.650080962921 hold_1_13
   - 1185.805024502931 hold_1_14 - 1044.533345056491 hold_1_15
   - 912.9871513241026 hold_1_16 - 802.5639739024219 hold_1_17
   - 758.1085541470287 hold_1_18 + flow_source_1 + flow_0_1 + flow_2_1
   + flow_3_1 <= 0
 node_throughput_constraint_2: - 24422.68313024132 hold_2_1
   - 11751.67055226967 hold_2_2 - 7569.127326043289 hold_2_3
   - 5481.216997173115 hold_2_4 - 4380.946286549032 hold_2_5
   - 3525.198937755591 hold_2_6 - 3021.840332969844 hold_2_7
   - 2535.881991547678 hold_2_8 - 2158.990705603894 hold_2_9
   - 1942.714881742995 hold_2_10 - 1678.975410437803 hold_2_11
   - 1462.934405463458 hold_2_12 - 1349.650080962921 hold_2_13
   - 1185.805024502931 hold_2_14 - 1044.533345056491 hold_2_15
   - 912.9871513241026 hold_2_16 - 802.5639739024219 hold_2_17
   - 758.1085541470287 hold_2_18 + flow_source_2 + flow_0_2 + flow_1_2
   + flow_3_2 <= 0
 node_throughput_constraint_3: - 24422.68313024132 hold_3_1
   - 11751.67055226967 hold_3_2 - 7569.127326043289 hold_3_3
   - 5481.216997173115 hold_3_4 - 4380.946286549032 hold_3_5
   - 3525.198937755591 hold_3_6 - 3021.840332969844 hold_3_7
   - 2535.881991547678 hold_3_8 - 2158.990705603894 hold_3_9
   - 1942.714881742995 hold_3_10 - 1678.975410437803 hold_3_11
   - 1462.934405463458 hold_3_12 - 1349.650080962921 hold_3_13
   - 1185.805024502931 hold_3_14 - 1044.533345056491 hold_3_15
   - 912.9871513241026 hold_3_16 - 802.5639739024219 hold_3_17
   - 758.1085541470287 hold_3_18 + flow_source_3 + flow_0_3 + flow_1_3
   + flow_2_3 <= 0
 edge_enable_constr_source_0: start_0 + switch_source_0 >= 1
 edge_disable_constr_source_0: start_0 + 60 switch_source_0 <= 60
 edge_enable_constr_source_1: start_1 + switch_source_1 >= 1
 edge_disable_constr_source_1: start_1 + 60 switch_source_1 <= 60
 edge_enable_constr_source_2: start_2 + switch_source_2 >= 1
 edge_disable_constr_source_2: start_2 + 60 switch_source_2 <= 60
 edge_enable_constr_source_3: start_3 + switch_source_3 >= 1
 edge_disable_constr_source_3: start_3 + 60 switch_source_3 <= 60
 edge_enable_constr_0_sink: - start_0 - hold_0_1 - 2 hold_0_2 - 3 hold_0_3
   - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7 - 8 hold_0_8
   - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 - 12 hold_0_12 - 13 hold_0_13
   - 14 hold_0_14 - 15 hold_0_15 - 16 hold_0_16 - 17 hold_0_17
   - 18 hold_0_18 + 59 switch_0_sink >= -59
 edge_disable_constr_0_sink: - start_0 - hold_0_1 - 2 hold_0_2 - 3 hold_0_3
   - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7 - 8 hold_0_8
   - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 - 12 hold_0_12 - 13 hold_0_13
   - 14 hold_0_14 - 15 hold_0_15 - 16 hold_0_16 - 17 hold_0_17
   - 18 hold_0_18 + 60 switch_0_sink <= 0
 edge_enable_constr_1_sink: - start_1 - hold_1_1 - 2 hold_1_2 - 3 hold_1_3
   - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7 - 8 hold_1_8
   - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 - 12 hold_1_12 - 13 hold_1_13
   - 14 hold_1_14 - 15 hold_1_15 - 16 hold_1_16 - 17 hold_1_17
   - 18 hold_1_18 + 59 switch_1_sink >= -59
 edge_disable_constr_1_sink: - start_1 - hold_1_1 - 2 hold_1_2 - 3 hold_1_3
   - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7 - 8 hold_1_8
   - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 - 12 hold_1_12 - 13 hold_1_13
   - 14 hold_1_14 - 15 hold_1_15 - 16 hold_1_16 - 17 hold_1_17
   - 18 hold_1_18 + 60 switch_1_sink <= 0
 edge_enable_constr_2_sink: - start_2 - hold_2_1 - 2 hold_2_2 - 3 hold_2_3
   - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7 - 8 hold_2_8
   - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 - 12 hold_2_12 - 13 hold_2_13
   - 14 hold_2_14 - 15 hold_2_15 - 16 hold_2_16 - 17 hold_2_17
   - 18 hold_2_18 + 59 switch_2_sink >= -59
 edge_disable_constr_2_sink: - start_2 - hold_2_1 - 2 hold_2_2 - 3 hold_2_3
   - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7 - 8 hold_2_8
   - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 - 12 hold_2_12 - 13 hold_2_13
   - 14 hold_2_14 - 15 hold_2_15 - 16 hold_2_16 - 17 hold_2_17
   - 18 hold_2_18 + 60 switch_2_sink <= 0
 edge_enable_constr_3_sink: - start_3 - hold_3_1 - 2 hold_3_2 - 3 hold_3_3
   - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7 - 8 hold_3_8
   - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 - 12 hold_3_12 - 13 hold_3_13
   - 14 hold_3_14 - 15 hold_3_15 - 16 hold_3_16 - 17 hold_3_17
   - 18 hold_3_18 + 59 switch_3_sink >= -59
 edge_disable_constr_3_sink: - start_3 - hold_3_1 - 2 hold_3_2 - 3 hold_3_3
   - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7 - 8 hold_3_8
   - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 - 12 hold_3_12 - 13 hold_3_13
   - 14 hold_3_14 - 15 hold_3_15 - 16 hold_3_16 - 17 hold_3_17
   - 18 hold_3_18 + 60 switch_3_sink <= 0
 edge_disable_constr1_0_1: start_0 - start_1 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 12 hold_0_12
   + 13 hold_0_13 + 14 hold_0_14 + 15 hold_0_15 + 16 hold_0_16
   + 17 hold_0_17 + 18 hold_0_18 + 60 switch_0_1 <= 60
 edge_disable_constr2_0_1: - start_0 + start_1 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 - 12 hold_0_12
   - 13 hold_0_13 - 14 hold_0_14 - 15 hold_0_15 - 16 hold_0_16
   - 17 hold_0_17 - 18 hold_0_18 + 60 switch_0_1 <= 60
 edge_disable_constr1_1_0: - start_0 + start_1 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 12 hold_1_12
   + 13 hold_1_13 + 14 hold_1_14 + 15 hold_1_15 + 16 hold_1_16
   + 17 hold_1_17 + 18 hold_1_18 + 60 switch_1_0 <= 60
 edge_disable_constr2_1_0: start_0 - start_1 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 - 12 hold_1_12
   - 13 hold_1_13 - 14 hold_1_14 - 15 hold_1_15 - 16 hold_1_16
   - 17 hold_1_17 - 18 hold_1_18 + 60 switch_1_0 <= 60
 edge_disable_constr1_0_2: start_0 - start_2 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 12 hold_0_12
   + 13 hold_0_13 + 14 hold_0_14 + 15 hold_0_15 + 16 hold_0_16
   + 17 hold_0_17 + 18 hold_0_18 + 60 switch_0_2 <= 60
 edge_disable_constr2_0_2: - start_0 + start_2 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 - 12 hold_0_12
   - 13 hold_0_13 - 14 hold_0_14 - 15 hold_0_15 - 16 hold_0_16
   - 17 hold_0_17 - 18 hold_0_18 + 60 switch_0_2 <= 60
 edge_disable_constr1_2_0: - start_0 + start_2 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 12 hold_2_12
   + 13 hold_2_13 + 14 hold_2_14 + 15 hold_2_15 + 16 hold_2_16
   + 17 hold_2_17 + 18 hold_2_18 + 60 switch_2_0 <= 60
 edge_disable_constr2_2_0: start_0 - start_2 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 - 12 hold_2_12
   - 13 hold_2_13 - 14 hold_2_14 - 15 hold_2_15 - 16 hold_2_16
   - 17 hold_2_17 - 18 hold_2_18 + 60 switch_2_0 <= 60
 edge_disable_constr1_0_3: start_0 - start_3 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 12 hold_0_12
   + 13 hold_0_13 + 14 hold_0_14 + 15 hold_0_15 + 16 hold_0_16
   + 17 hold_0_17 + 18 hold_0_18 + 60 switch_0_3 <= 60
 edge_disable_constr2_0_3: - start_0 + start_3 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 - 12 hold_0_12
   - 13 hold_0_13 - 14 hold_0_14 - 15 hold_0_15 - 16 hold_0_16
   - 17 hold_0_17 - 18 hold_0_18 + 60 switch_0_3 <= 60
 edge_disable_constr1_3_0: - start_0 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 12 hold_3_12
   + 13 hold_3_13 + 14 hold_3_14 + 15 hold_3_15 + 16 hold_3_16
   + 17 hold_3_17 + 18 hold_3_18 + 60 switch_3_0 <= 60
 edge_disable_constr2_3_0: start_0 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 - 12 hold_3_12
   - 13 hold_3_13 - 14 hold_3_14 - 15 hold_3_15 - 16 hold_3_16
   - 17 hold_3_17 - 18 hold_3_18 + 60 switch_3_0 <= 60
 edge_disable_constr1_1_2: start_1 - start_2 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 12 hold_1_12
   + 13 hold_1_13 + 14 hold_1_14 + 15 hold_1_15 + 16 hold_1_16
   + 17 hold_1_17 + 18 hold_1_18 + 60 switch_1_2 <= 60
 edge_disable_constr2_1_2: - start_1 + start_2 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 - 12 hold_1_12
   - 13 hold_1_13 - 14 hold_1_14 - 15 hold_1_15 - 16 hold_1_16
   - 17 hold_1_17 - 18 hold_1_18 + 60 switch_1_2 <= 60
 edge_disable_constr1_2_1: - start_1 + start_2 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 12 hold_2_12
   + 13 hold_2_13 + 14 hold_2_14 + 15 hold_2_15 + 16 hold_2_16
   + 17 hold_2_17 + 18 hold_2_18 + 60 switch_2_1 <= 60
 edge_disable_constr2_2_1: start_1 - start_2 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 - 12 hold_2_12
   - 13 hold_2_13 - 14 hold_2_14 - 15 hold_2_15 - 16 hold_2_16
   - 17 hold_2_17 - 18 hold_2_18 + 60 switch_2_1 <= 60
 edge_disable_constr1_1_3: start_1 - start_3 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 12 hold_1_12
   + 13 hold_1_13 + 14 hold_1_14 + 15 hold_1_15 + 16 hold_1_16
   + 17 hold_1_17 + 18 hold_1_18 + 60 switch_1_3 <= 60
 edge_disable_constr2_1_3: - start_1 + start_3 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 - 12 hold_1_12
   - 13 hold_1_13 - 14 hold_1_14 - 15 hold_1_15 - 16 hold_1_16
   - 17 hold_1_17 - 18 hold_1_18 + 60 switch_1_3 <= 60
 edge_disable_constr1_3_1: - start_1 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 12 hold_3_12
   + 13 hold_3_13 + 14 hold_3_14 + 15 hold_3_15 + 16 hold_3_16
   + 17 hold_3_17 + 18 hold_3_18 + 60 switch_3_1 <= 60
 edge_disable_constr2_3_1: start_1 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 - 12 hold_3_12
   - 13 hold_3_13 - 14 hold_3_14 - 15 hold_3_15 - 16 hold_3_16
   - 17 hold_3_17 - 18 hold_3_18 + 60 switch_3_1 <= 60
 edge_disable_constr1_2_3: start_2 - start_3 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 12 hold_2_12
   + 13 hold_2_13 + 14 hold_2_14 + 15 hold_2_15 + 16 hold_2_16
   + 17 hold_2_17 + 18 hold_2_18 + 60 switch_2_3 <= 60
 edge_disable_constr2_2_3: - start_2 + start_3 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 - 12 hold_2_12
   - 13 hold_2_13 - 14 hold_2_14 - 15 hold_2_15 - 16 hold_2_16
   - 17 hold_2_17 - 18 hold_2_18 + 60 switch_2_3 <= 60
 edge_disable_constr1_3_2: - start_2 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 12 hold_3_12
   + 13 hold_3_13 + 14 hold_3_14 + 15 hold_3_15 + 16 hold_3_16
   + 17 hold_3_17 + 18 hold_3_18 + 60 switch_3_2 <= 60
 edge_disable_constr2_3_2: start_2 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 - 12 hold_3_12
   - 13 hold_3_13 - 14 hold_3_14 - 15 hold_3_15 - 16 hold_3_16
   - 17 hold_3_17 - 18 hold_3_18 + 60 switch_3_2 <= 60
 edge_flow_constr_source_0: flow_source_0 - 5e+08 switch_source_0 <= 0
 edge_flow_constr_source_1: flow_source_1 - 5e+08 switch_source_1 <= 0
 edge_flow_constr_source_2: flow_source_2 - 5e+08 switch_source_2 <= 0
 edge_flow_constr_source_3: flow_source_3 - 5e+08 switch_source_3 <= 0
 edge_flow_constr_0_sink: flow_0_sink - 5e+08 switch_0_sink <= 0
 edge_flow_constr_1_sink: flow_1_sink - 5e+08 switch_1_sink <= 0
 edge_flow_constr_2_sink: flow_2_sink - 5e+08 switch_2_sink <= 0
 edge_flow_constr_3_sink: flow_3_sink - 5e+08 switch_3_sink <= 0
 edge_flow_constr_0_1: flow_0_1 - 75120.19230769231 switch_0_1 <= 0
 edge_flow_constr_1_0: flow_1_0 - 75120.19230769231 switch_1_0 <= 0
 edge_flow_constr_0_2: flow_0_2 - 75120.19230769231 switch_0_2 <= 0
 edge_flow_constr_2_0: flow_2_0 - 75120.19230769231 switch_2_0 <= 0
 edge_flow_constr_0_3: flow_0_3 - 75120.19230769231 switch_0_3 <= 0
 edge_flow_constr_3_0: flow_3_0 - 75120.19230769231 switch_3_0 <= 0
 edge_flow_constr_1_2: flow_1_2 - 75120.19230769231 switch_1_2 <= 0
 edge_flow_constr_2_1: flow_2_1 - 75120.19230769231 switch_2_1 <= 0
 edge_flow_constr_1_3: flow_1_3 - 75120.19230769231 switch_1_3 <= 0
 edge_flow_constr_3_1: flow_3_1 - 75120.19230769231 switch_3_1 <= 0
 edge_flow_constr_2_3: flow_2_3 - 75120.19230769231 switch_2_3 <= 0
 edge_flow_constr_3_2: flow_3_2 - 75120.19230769231 switch_3_2 <= 0
Bounds
 start_0 <= 59
 start_1 <= 59
 start_2 <= 59
 start_3 <= 59
Binaries
 hold_0_1 hold_0_2 hold_0_3 hold_0_4 hold_0_5 hold_0_6 hold_0_7 hold_0_8
 hold_0_9 hold_0_10 hold_0_11 hold_0_12 hold_0_13 hold_0_14 hold_0_15
 hold_0_16 hold_0_17 hold_0_18 hold_1_1 hold_1_2 hold_1_3 hold_1_4 hold_1_5
 hold_1_6 hold_1_7 hold_1_8 hold_1_9 hold_1_10 hold_1_11 hold_1_12
 hold_1_13 hold_1_14 hold_1_15 hold_1_16 hold_1_17 hold_1_18 hold_2_1
 hold_2_2 hold_2_3 hold_2_4 hold_2_5 hold_2_6 hold_2_7 hold_2_8 hold_2_9
 hold_2_10 hold_2_11 hold_2_12 hold_2_13 hold_2_14 hold_2_15 hold_2_16
 hold_2_17 hold_2_18 hold_3_1 hold_3_2 hold_3_3 hold_3_4 hold_3_5 hold_3_6
 hold_3_7 hold_3_8 hold_3_9 hold_3_10 hold_3_11 hold_3_12 hold_3_13
 hold_3_14 hold_3_15 hold_3_16 hold_3_17 hold_3_18 switch_source_0
 switch_source_1 switch_source_2 switch_source_3 switch_0_sink
 switch_1_sink switch_2_sink switch_3_sink switch_0_1 switch_1_0 switch_0_2
 switch_2_0 switch_0_3 switch_3_0 switch_1_2 switch_2_1 switch_1_3
 switch_3_1 switch_2_3 switch_3_2
Generals
 start_0 start_1 start_2 start_3
End
