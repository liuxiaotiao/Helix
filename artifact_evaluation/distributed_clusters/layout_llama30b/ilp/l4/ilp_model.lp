\ Model 2024-11-07_16-54-07
\ LP format - for model browsing. Use MPS format to capture full model detail.
Maximize
  flow_source_0 + flow_source_1 + flow_source_2 + flow_source_3
   + flow_source_4 + flow_source_5 + flow_source_6 + flow_source_7
Subject To
 hold_constraint_0: hold_0_1 + hold_0_2 + hold_0_3 + hold_0_4 + hold_0_5
   + hold_0_6 + hold_0_7 + hold_0_8 + hold_0_9 + hold_0_10 + hold_0_11 = 1
 end_constraint_0: start_0 + hold_0_1 + 2 hold_0_2 + 3 hold_0_3
   + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7 + 8 hold_0_8
   + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 <= 60
 hold_constraint_1: hold_1_1 + hold_1_2 + hold_1_3 + hold_1_4 + hold_1_5
   + hold_1_6 + hold_1_7 + hold_1_8 + hold_1_9 + hold_1_10 + hold_1_11 = 1
 end_constraint_1: start_1 + hold_1_1 + 2 hold_1_2 + 3 hold_1_3
   + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7 + 8 hold_1_8
   + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 <= 60
 hold_constraint_2: hold_2_1 + hold_2_2 + hold_2_3 + hold_2_4 + hold_2_5
   + hold_2_6 + hold_2_7 + hold_2_8 + hold_2_9 + hold_2_10 + hold_2_11 = 1
 end_constraint_2: start_2 + hold_2_1 + 2 hold_2_2 + 3 hold_2_3
   + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7 + 8 hold_2_8
   + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 <= 60
 hold_constraint_3: hold_3_1 + hold_3_2 + hold_3_3 + hold_3_4 + hold_3_5
   + hold_3_6 + hold_3_7 + hold_3_8 + hold_3_9 + hold_3_10 + hold_3_11 = 1
 end_constraint_3: start_3 + hold_3_1 + 2 hold_3_2 + 3 hold_3_3
   + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7 + 8 hold_3_8
   + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 <= 60
 hold_constraint_4: hold_4_1 + hold_4_2 + hold_4_3 + hold_4_4 + hold_4_5
   + hold_4_6 + hold_4_7 + hold_4_8 + hold_4_9 + hold_4_10 + hold_4_11 = 1
 end_constraint_4: start_4 + hold_4_1 + 2 hold_4_2 + 3 hold_4_3
   + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7 + 8 hold_4_8
   + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 <= 60
 hold_constraint_5: hold_5_1 + hold_5_2 + hold_5_3 + hold_5_4 + hold_5_5
   + hold_5_6 + hold_5_7 + hold_5_8 + hold_5_9 + hold_5_10 + hold_5_11 = 1
 end_constraint_5: start_5 + hold_5_1 + 2 hold_5_2 + 3 hold_5_3
   + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7 + 8 hold_5_8
   + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 <= 60
 hold_constraint_6: hold_6_1 + hold_6_2 + hold_6_3 + hold_6_4 + hold_6_5
   + hold_6_6 + hold_6_7 + hold_6_8 + hold_6_9 + hold_6_10 + hold_6_11 = 1
 end_constraint_6: start_6 + hold_6_1 + 2 hold_6_2 + 3 hold_6_3
   + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7 + 8 hold_6_8
   + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 <= 60
 hold_constraint_7: hold_7_1 + hold_7_2 + hold_7_3 + hold_7_4 + hold_7_5
   + hold_7_6 + hold_7_7 + hold_7_8 + hold_7_9 + hold_7_10 + hold_7_11 = 1
 end_constraint_7: start_7 + hold_7_1 + 2 hold_7_2 + 3 hold_7_3
   + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7 + 8 hold_7_8
   + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 <= 60
 node_flow_constraint_0: flow_source_0 - flow_0_sink - flow_0_1 + flow_1_0
   - flow_0_2 + flow_2_0 - flow_0_3 + flow_3_0 - flow_0_4 + flow_4_0
   - flow_0_5 + flow_5_0 - flow_0_6 + flow_6_0 - flow_0_7 + flow_7_0 = 0
 node_flow_constraint_1: flow_source_1 - flow_1_sink + flow_0_1 - flow_1_0
   - flow_1_2 + flow_2_1 - flow_1_3 + flow_3_1 - flow_1_4 + flow_4_1
   - flow_1_5 + flow_5_1 - flow_1_6 + flow_6_1 - flow_1_7 + flow_7_1 = 0
 node_flow_constraint_2: flow_source_2 - flow_2_sink + flow_0_2 - flow_2_0
   + flow_1_2 - flow_2_1 - flow_2_3 + flow_3_2 - flow_2_4 + flow_4_2
   - flow_2_5 + flow_5_2 - flow_2_6 + flow_6_2 - flow_2_7 + flow_7_2 = 0
 node_flow_constraint_3: flow_source_3 - flow_3_sink + flow_0_3 - flow_3_0
   + flow_1_3 - flow_3_1 + flow_2_3 - flow_3_2 - flow_3_4 + flow_4_3
   - flow_3_5 + flow_5_3 - flow_3_6 + flow_6_3 - flow_3_7 + flow_7_3 = 0
 node_flow_constraint_4: flow_source_4 - flow_4_sink + flow_0_4 - flow_4_0
   + flow_1_4 - flow_4_1 + flow_2_4 - flow_4_2 + flow_3_4 - flow_4_3
   - flow_4_5 + flow_5_4 - flow_4_6 + flow_6_4 - flow_4_7 + flow_7_4 = 0
 node_flow_constraint_5: flow_source_5 - flow_5_sink + flow_0_5 - flow_5_0
   + flow_1_5 - flow_5_1 + flow_2_5 - flow_5_2 + flow_3_5 - flow_5_3
   + flow_4_5 - flow_5_4 - flow_5_6 + flow_6_5 - flow_5_7 + flow_7_5 = 0
 node_flow_constraint_6: flow_source_6 - flow_6_sink + flow_0_6 - flow_6_0
   + flow_1_6 - flow_6_1 + flow_2_6 - flow_6_2 + flow_3_6 - flow_6_3
   + flow_4_6 - flow_6_4 + flow_5_6 - flow_6_5 - flow_6_7 + flow_7_6 = 0
 node_flow_constraint_7: flow_source_7 - flow_7_sink + flow_0_7 - flow_7_0
   + flow_1_7 - flow_7_1 + flow_2_7 - flow_7_2 + flow_3_7 - flow_7_3
   + flow_4_7 - flow_7_4 + flow_5_7 - flow_7_5 + flow_6_7 - flow_7_6 = 0
 node_throughput_constraint_0: - 2678.282126139081 hold_0_1
   - 1339.634117297906 hold_0_2 - 828.4919555104841 hold_0_3
   - 572.5386746737784 hold_0_4 - 458.1705102169342 hold_0_5
   - 320.6809401419605 hold_0_6 - 275.0183041964401 hold_0_7
   - 214.9814019613291 hold_0_8 - 168.0950165944492 hold_0_9
   - 252.6498460282083 hold_0_10 - 193.3135120572725 hold_0_11
   + flow_source_0 + flow_1_0 + flow_2_0 + flow_3_0 + flow_4_0 + flow_5_0
   + flow_6_0 + flow_7_0 <= 0
 node_throughput_constraint_1: - 2678.282126139081 hold_1_1
   - 1339.634117297906 hold_1_2 - 828.4919555104841 hold_1_3
   - 572.5386746737784 hold_1_4 - 458.1705102169342 hold_1_5
   - 320.6809401419605 hold_1_6 - 275.0183041964401 hold_1_7
   - 214.9814019613291 hold_1_8 - 168.0950165944492 hold_1_9
   - 252.6498460282083 hold_1_10 - 193.3135120572725 hold_1_11
   + flow_source_1 + flow_0_1 + flow_2_1 + flow_3_1 + flow_4_1 + flow_5_1
   + flow_6_1 + flow_7_1 <= 0
 node_throughput_constraint_2: - 2678.282126139081 hold_2_1
   - 1339.634117297906 hold_2_2 - 828.4919555104841 hold_2_3
   - 572.5386746737784 hold_2_4 - 458.1705102169342 hold_2_5
   - 320.6809401419605 hold_2_6 - 275.0183041964401 hold_2_7
   - 214.9814019613291 hold_2_8 - 168.0950165944492 hold_2_9
   - 252.6498460282083 hold_2_10 - 193.3135120572725 hold_2_11
   + flow_source_2 + flow_0_2 + flow_1_2 + flow_3_2 + flow_4_2 + flow_5_2
   + flow_6_2 + flow_7_2 <= 0
 node_throughput_constraint_3: - 2678.282126139081 hold_3_1
   - 1339.634117297906 hold_3_2 - 828.4919555104841 hold_3_3
   - 572.5386746737784 hold_3_4 - 458.1705102169342 hold_3_5
   - 320.6809401419605 hold_3_6 - 275.0183041964401 hold_3_7
   - 214.9814019613291 hold_3_8 - 168.0950165944492 hold_3_9
   - 252.6498460282083 hold_3_10 - 193.3135120572725 hold_3_11
   + flow_source_3 + flow_0_3 + flow_1_3 + flow_2_3 + flow_4_3 + flow_5_3
   + flow_6_3 + flow_7_3 <= 0
 node_throughput_constraint_4: - 2678.282126139081 hold_4_1
   - 1339.634117297906 hold_4_2 - 828.4919555104841 hold_4_3
   - 572.5386746737784 hold_4_4 - 458.1705102169342 hold_4_5
   - 320.6809401419605 hold_4_6 - 275.0183041964401 hold_4_7
   - 214.9814019613291 hold_4_8 - 168.0950165944492 hold_4_9
   - 252.6498460282083 hold_4_10 - 193.3135120572725 hold_4_11
   + flow_source_4 + flow_0_4 + flow_1_4 + flow_2_4 + flow_3_4 + flow_5_4
   + flow_6_4 + flow_7_4 <= 0
 node_throughput_constraint_5: - 2678.282126139081 hold_5_1
   - 1339.634117297906 hold_5_2 - 828.4919555104841 hold_5_3
   - 572.5386746737784 hold_5_4 - 458.1705102169342 hold_5_5
   - 320.6809401419605 hold_5_6 - 275.0183041964401 hold_5_7
   - 214.9814019613291 hold_5_8 - 168.0950165944492 hold_5_9
   - 252.6498460282083 hold_5_10 - 193.3135120572725 hold_5_11
   + flow_source_5 + flow_0_5 + flow_1_5 + flow_2_5 + flow_3_5 + flow_4_5
   + flow_6_5 + flow_7_5 <= 0
 node_throughput_constraint_6: - 2678.282126139081 hold_6_1
   - 1339.634117297906 hold_6_2 - 828.4919555104841 hold_6_3
   - 572.5386746737784 hold_6_4 - 458.1705102169342 hold_6_5
   - 320.6809401419605 hold_6_6 - 275.0183041964401 hold_6_7
   - 214.9814019613291 hold_6_8 - 168.0950165944492 hold_6_9
   - 252.6498460282083 hold_6_10 - 193.3135120572725 hold_6_11
   + flow_source_6 + flow_0_6 + flow_1_6 + flow_2_6 + flow_3_6 + flow_4_6
   + flow_5_6 + flow_7_6 <= 0
 node_throughput_constraint_7: - 2678.282126139081 hold_7_1
   - 1339.634117297906 hold_7_2 - 828.4919555104841 hold_7_3
   - 572.5386746737784 hold_7_4 - 458.1705102169342 hold_7_5
   - 320.6809401419605 hold_7_6 - 275.0183041964401 hold_7_7
   - 214.9814019613291 hold_7_8 - 168.0950165944492 hold_7_9
   - 252.6498460282083 hold_7_10 - 193.3135120572725 hold_7_11
   + flow_source_7 + flow_0_7 + flow_1_7 + flow_2_7 + flow_3_7 + flow_4_7
   + flow_5_7 + flow_6_7 <= 0
 edge_enable_constr_source_0: start_0 + switch_source_0 >= 1
 edge_disable_constr_source_0: start_0 + 60 switch_source_0 <= 60
 edge_enable_constr_source_1: start_1 + switch_source_1 >= 1
 edge_disable_constr_source_1: start_1 + 60 switch_source_1 <= 60
 edge_enable_constr_source_2: start_2 + switch_source_2 >= 1
 edge_disable_constr_source_2: start_2 + 60 switch_source_2 <= 60
 edge_enable_constr_source_3: start_3 + switch_source_3 >= 1
 edge_disable_constr_source_3: start_3 + 60 switch_source_3 <= 60
 edge_enable_constr_source_4: start_4 + switch_source_4 >= 1
 edge_disable_constr_source_4: start_4 + 60 switch_source_4 <= 60
 edge_enable_constr_source_5: start_5 + switch_source_5 >= 1
 edge_disable_constr_source_5: start_5 + 60 switch_source_5 <= 60
 edge_enable_constr_source_6: start_6 + switch_source_6 >= 1
 edge_disable_constr_source_6: start_6 + 60 switch_source_6 <= 60
 edge_enable_constr_source_7: start_7 + switch_source_7 >= 1
 edge_disable_constr_source_7: start_7 + 60 switch_source_7 <= 60
 edge_enable_constr_0_sink: - start_0 - hold_0_1 - 2 hold_0_2 - 3 hold_0_3
   - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7 - 8 hold_0_8
   - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 59 switch_0_sink >= -59
 edge_disable_constr_0_sink: - start_0 - hold_0_1 - 2 hold_0_2 - 3 hold_0_3
   - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7 - 8 hold_0_8
   - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_sink <= 0
 edge_enable_constr_1_sink: - start_1 - hold_1_1 - 2 hold_1_2 - 3 hold_1_3
   - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7 - 8 hold_1_8
   - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 59 switch_1_sink >= -59
 edge_disable_constr_1_sink: - start_1 - hold_1_1 - 2 hold_1_2 - 3 hold_1_3
   - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7 - 8 hold_1_8
   - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_sink <= 0
 edge_enable_constr_2_sink: - start_2 - hold_2_1 - 2 hold_2_2 - 3 hold_2_3
   - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7 - 8 hold_2_8
   - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 59 switch_2_sink >= -59
 edge_disable_constr_2_sink: - start_2 - hold_2_1 - 2 hold_2_2 - 3 hold_2_3
   - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7 - 8 hold_2_8
   - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_sink <= 0
 edge_enable_constr_3_sink: - start_3 - hold_3_1 - 2 hold_3_2 - 3 hold_3_3
   - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7 - 8 hold_3_8
   - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 59 switch_3_sink >= -59
 edge_disable_constr_3_sink: - start_3 - hold_3_1 - 2 hold_3_2 - 3 hold_3_3
   - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7 - 8 hold_3_8
   - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_sink <= 0
 edge_enable_constr_4_sink: - start_4 - hold_4_1 - 2 hold_4_2 - 3 hold_4_3
   - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7 - 8 hold_4_8
   - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 59 switch_4_sink >= -59
 edge_disable_constr_4_sink: - start_4 - hold_4_1 - 2 hold_4_2 - 3 hold_4_3
   - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7 - 8 hold_4_8
   - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_sink <= 0
 edge_enable_constr_5_sink: - start_5 - hold_5_1 - 2 hold_5_2 - 3 hold_5_3
   - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7 - 8 hold_5_8
   - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 59 switch_5_sink >= -59
 edge_disable_constr_5_sink: - start_5 - hold_5_1 - 2 hold_5_2 - 3 hold_5_3
   - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7 - 8 hold_5_8
   - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_sink <= 0
 edge_enable_constr_6_sink: - start_6 - hold_6_1 - 2 hold_6_2 - 3 hold_6_3
   - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7 - 8 hold_6_8
   - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 59 switch_6_sink >= -59
 edge_disable_constr_6_sink: - start_6 - hold_6_1 - 2 hold_6_2 - 3 hold_6_3
   - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7 - 8 hold_6_8
   - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_sink <= 0
 edge_enable_constr_7_sink: - start_7 - hold_7_1 - 2 hold_7_2 - 3 hold_7_3
   - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7 - 8 hold_7_8
   - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 59 switch_7_sink >= -59
 edge_disable_constr_7_sink: - start_7 - hold_7_1 - 2 hold_7_2 - 3 hold_7_3
   - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7 - 8 hold_7_8
   - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_sink <= 0
 edge_disable_constr1_0_1: start_0 - start_1 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 60 switch_0_1
   <= 60
 edge_disable_constr2_0_1: - start_0 + start_1 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_1
   <= 60
 edge_disable_constr1_1_0: - start_0 + start_1 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_0
   <= 60
 edge_disable_constr2_1_0: start_0 - start_1 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_0
   <= 60
 edge_disable_constr1_0_2: start_0 - start_2 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 60 switch_0_2
   <= 60
 edge_disable_constr2_0_2: - start_0 + start_2 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_2
   <= 60
 edge_disable_constr1_2_0: - start_0 + start_2 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 60 switch_2_0
   <= 60
 edge_disable_constr2_2_0: start_0 - start_2 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_0
   <= 60
 edge_disable_constr1_0_3: start_0 - start_3 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 60 switch_0_3
   <= 60
 edge_disable_constr2_0_3: - start_0 + start_3 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_3
   <= 60
 edge_disable_constr1_3_0: - start_0 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 60 switch_3_0
   <= 60
 edge_disable_constr2_3_0: start_0 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_0
   <= 60
 edge_disable_constr1_0_4: start_0 - start_4 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 60 switch_0_4
   <= 60
 edge_disable_constr2_0_4: - start_0 + start_4 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_4
   <= 60
 edge_disable_constr1_4_0: - start_0 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_0
   <= 60
 edge_disable_constr2_4_0: start_0 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_0
   <= 60
 edge_disable_constr1_0_5: start_0 - start_5 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 60 switch_0_5
   <= 60
 edge_disable_constr2_0_5: - start_0 + start_5 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_5
   <= 60
 edge_disable_constr1_5_0: - start_0 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 8 hold_5_8 + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 + 60 switch_5_0
   <= 60
 edge_disable_constr2_5_0: start_0 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   - 8 hold_5_8 - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_0
   <= 60
 edge_disable_constr1_0_6: start_0 - start_6 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 60 switch_0_6
   <= 60
 edge_disable_constr2_0_6: - start_0 + start_6 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_6
   <= 60
 edge_disable_constr1_6_0: - start_0 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 8 hold_6_8 + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 + 60 switch_6_0
   <= 60
 edge_disable_constr2_6_0: start_0 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   - 8 hold_6_8 - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_0
   <= 60
 edge_disable_constr1_0_7: start_0 - start_7 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 8 hold_0_8 + 9 hold_0_9 + 10 hold_0_10 + 11 hold_0_11 + 60 switch_0_7
   <= 60
 edge_disable_constr2_0_7: - start_0 + start_7 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   - 8 hold_0_8 - 9 hold_0_9 - 10 hold_0_10 - 11 hold_0_11 + 60 switch_0_7
   <= 60
 edge_disable_constr1_7_0: - start_0 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 8 hold_7_8 + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 + 60 switch_7_0
   <= 60
 edge_disable_constr2_7_0: start_0 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   - 8 hold_7_8 - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_0
   <= 60
 edge_disable_constr1_1_2: start_1 - start_2 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_2
   <= 60
 edge_disable_constr2_1_2: - start_1 + start_2 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_2
   <= 60
 edge_disable_constr1_2_1: - start_1 + start_2 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 60 switch_2_1
   <= 60
 edge_disable_constr2_2_1: start_1 - start_2 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_1
   <= 60
 edge_disable_constr1_1_3: start_1 - start_3 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_3
   <= 60
 edge_disable_constr2_1_3: - start_1 + start_3 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_3
   <= 60
 edge_disable_constr1_3_1: - start_1 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 60 switch_3_1
   <= 60
 edge_disable_constr2_3_1: start_1 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_1
   <= 60
 edge_disable_constr1_1_4: start_1 - start_4 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_4
   <= 60
 edge_disable_constr2_1_4: - start_1 + start_4 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_4
   <= 60
 edge_disable_constr1_4_1: - start_1 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_1
   <= 60
 edge_disable_constr2_4_1: start_1 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_1
   <= 60
 edge_disable_constr1_1_5: start_1 - start_5 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_5
   <= 60
 edge_disable_constr2_1_5: - start_1 + start_5 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_5
   <= 60
 edge_disable_constr1_5_1: - start_1 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 8 hold_5_8 + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 + 60 switch_5_1
   <= 60
 edge_disable_constr2_5_1: start_1 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   - 8 hold_5_8 - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_1
   <= 60
 edge_disable_constr1_1_6: start_1 - start_6 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_6
   <= 60
 edge_disable_constr2_1_6: - start_1 + start_6 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_6
   <= 60
 edge_disable_constr1_6_1: - start_1 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 8 hold_6_8 + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 + 60 switch_6_1
   <= 60
 edge_disable_constr2_6_1: start_1 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   - 8 hold_6_8 - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_1
   <= 60
 edge_disable_constr1_1_7: start_1 - start_7 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_7
   <= 60
 edge_disable_constr2_1_7: - start_1 + start_7 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_7
   <= 60
 edge_disable_constr1_7_1: - start_1 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 8 hold_7_8 + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 + 60 switch_7_1
   <= 60
 edge_disable_constr2_7_1: start_1 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   - 8 hold_7_8 - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_1
   <= 60
 edge_disable_constr1_2_3: start_2 - start_3 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 60 switch_2_3
   <= 60
 edge_disable_constr2_2_3: - start_2 + start_3 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_3
   <= 60
 edge_disable_constr1_3_2: - start_2 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 60 switch_3_2
   <= 60
 edge_disable_constr2_3_2: start_2 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_2
   <= 60
 edge_disable_constr1_2_4: start_2 - start_4 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 60 switch_2_4
   <= 60
 edge_disable_constr2_2_4: - start_2 + start_4 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_4
   <= 60
 edge_disable_constr1_4_2: - start_2 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_2
   <= 60
 edge_disable_constr2_4_2: start_2 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_2
   <= 60
 edge_disable_constr1_2_5: start_2 - start_5 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 60 switch_2_5
   <= 60
 edge_disable_constr2_2_5: - start_2 + start_5 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_5
   <= 60
 edge_disable_constr1_5_2: - start_2 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 8 hold_5_8 + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 + 60 switch_5_2
   <= 60
 edge_disable_constr2_5_2: start_2 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   - 8 hold_5_8 - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_2
   <= 60
 edge_disable_constr1_2_6: start_2 - start_6 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 60 switch_2_6
   <= 60
 edge_disable_constr2_2_6: - start_2 + start_6 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_6
   <= 60
 edge_disable_constr1_6_2: - start_2 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 8 hold_6_8 + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 + 60 switch_6_2
   <= 60
 edge_disable_constr2_6_2: start_2 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   - 8 hold_6_8 - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_2
   <= 60
 edge_disable_constr1_2_7: start_2 - start_7 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 8 hold_2_8 + 9 hold_2_9 + 10 hold_2_10 + 11 hold_2_11 + 60 switch_2_7
   <= 60
 edge_disable_constr2_2_7: - start_2 + start_7 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   - 8 hold_2_8 - 9 hold_2_9 - 10 hold_2_10 - 11 hold_2_11 + 60 switch_2_7
   <= 60
 edge_disable_constr1_7_2: - start_2 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 8 hold_7_8 + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 + 60 switch_7_2
   <= 60
 edge_disable_constr2_7_2: start_2 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   - 8 hold_7_8 - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_2
   <= 60
 edge_disable_constr1_3_4: start_3 - start_4 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 60 switch_3_4
   <= 60
 edge_disable_constr2_3_4: - start_3 + start_4 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_4
   <= 60
 edge_disable_constr1_4_3: - start_3 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_3
   <= 60
 edge_disable_constr2_4_3: start_3 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_3
   <= 60
 edge_disable_constr1_3_5: start_3 - start_5 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 60 switch_3_5
   <= 60
 edge_disable_constr2_3_5: - start_3 + start_5 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_5
   <= 60
 edge_disable_constr1_5_3: - start_3 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 8 hold_5_8 + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 + 60 switch_5_3
   <= 60
 edge_disable_constr2_5_3: start_3 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   - 8 hold_5_8 - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_3
   <= 60
 edge_disable_constr1_3_6: start_3 - start_6 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 60 switch_3_6
   <= 60
 edge_disable_constr2_3_6: - start_3 + start_6 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_6
   <= 60
 edge_disable_constr1_6_3: - start_3 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 8 hold_6_8 + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 + 60 switch_6_3
   <= 60
 edge_disable_constr2_6_3: start_3 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   - 8 hold_6_8 - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_3
   <= 60
 edge_disable_constr1_3_7: start_3 - start_7 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 8 hold_3_8 + 9 hold_3_9 + 10 hold_3_10 + 11 hold_3_11 + 60 switch_3_7
   <= 60
 edge_disable_constr2_3_7: - start_3 + start_7 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   - 8 hold_3_8 - 9 hold_3_9 - 10 hold_3_10 - 11 hold_3_11 + 60 switch_3_7
   <= 60
 edge_disable_constr1_7_3: - start_3 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 8 hold_7_8 + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 + 60 switch_7_3
   <= 60
 edge_disable_constr2_7_3: start_3 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   - 8 hold_7_8 - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_3
   <= 60
 edge_disable_constr1_4_5: start_4 - start_5 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_5
   <= 60
 edge_disable_constr2_4_5: - start_4 + start_5 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_5
   <= 60
 edge_disable_constr1_5_4: - start_4 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 8 hold_5_8 + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 + 60 switch_5_4
   <= 60
 edge_disable_constr2_5_4: start_4 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   - 8 hold_5_8 - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_4
   <= 60
 edge_disable_constr1_4_6: start_4 - start_6 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_6
   <= 60
 edge_disable_constr2_4_6: - start_4 + start_6 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_6
   <= 60
 edge_disable_constr1_6_4: - start_4 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 8 hold_6_8 + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 + 60 switch_6_4
   <= 60
 edge_disable_constr2_6_4: start_4 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   - 8 hold_6_8 - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_4
   <= 60
 edge_disable_constr1_4_7: start_4 - start_7 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_7
   <= 60
 edge_disable_constr2_4_7: - start_4 + start_7 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_7
   <= 60
 edge_disable_constr1_7_4: - start_4 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 8 hold_7_8 + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 + 60 switch_7_4
   <= 60
 edge_disable_constr2_7_4: start_4 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   - 8 hold_7_8 - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_4
   <= 60
 edge_disable_constr1_5_6: start_5 - start_6 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 8 hold_5_8 + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 + 60 switch_5_6
   <= 60
 edge_disable_constr2_5_6: - start_5 + start_6 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   - 8 hold_5_8 - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_6
   <= 60
 edge_disable_constr1_6_5: - start_5 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 8 hold_6_8 + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 + 60 switch_6_5
   <= 60
 edge_disable_constr2_6_5: start_5 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   - 8 hold_6_8 - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_5
   <= 60
 edge_disable_constr1_5_7: start_5 - start_7 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 8 hold_5_8 + 9 hold_5_9 + 10 hold_5_10 + 11 hold_5_11 + 60 switch_5_7
   <= 60
 edge_disable_constr2_5_7: - start_5 + start_7 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   - 8 hold_5_8 - 9 hold_5_9 - 10 hold_5_10 - 11 hold_5_11 + 60 switch_5_7
   <= 60
 edge_disable_constr1_7_5: - start_5 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 8 hold_7_8 + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 + 60 switch_7_5
   <= 60
 edge_disable_constr2_7_5: start_5 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   - 8 hold_7_8 - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_5
   <= 60
 edge_disable_constr1_6_7: start_6 - start_7 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 8 hold_6_8 + 9 hold_6_9 + 10 hold_6_10 + 11 hold_6_11 + 60 switch_6_7
   <= 60
 edge_disable_constr2_6_7: - start_6 + start_7 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   - 8 hold_6_8 - 9 hold_6_9 - 10 hold_6_10 - 11 hold_6_11 + 60 switch_6_7
   <= 60
 edge_disable_constr1_7_6: - start_6 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 8 hold_7_8 + 9 hold_7_9 + 10 hold_7_10 + 11 hold_7_11 + 60 switch_7_6
   <= 60
 edge_disable_constr2_7_6: start_6 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   - 8 hold_7_8 - 9 hold_7_9 - 10 hold_7_10 - 11 hold_7_11 + 60 switch_7_6
   <= 60
 edge_flow_constr_source_0: flow_source_0 - 6.2e+06 switch_source_0 <= 0
 edge_flow_constr_source_1: flow_source_1 - 7.25e+06 switch_source_1 <= 0
 edge_flow_constr_source_2: flow_source_2 - 7.3e+06 switch_source_2 <= 0
 edge_flow_constr_source_3: flow_source_3 - 6.2e+06 switch_source_3 <= 0
 edge_flow_constr_source_4: flow_source_4 - 5.65e+06 switch_source_4 <= 0
 edge_flow_constr_source_5: flow_source_5 - 6.35e+06 switch_source_5 <= 0
 edge_flow_constr_source_6: flow_source_6 - 6.8e+06 switch_source_6 <= 0
 edge_flow_constr_source_7: flow_source_7 - 7.05e+06 switch_source_7 <= 0
 edge_flow_constr_0_sink: flow_0_sink - 5.25e+06 switch_0_sink <= 0
 edge_flow_constr_1_sink: flow_1_sink - 6.75e+06 switch_1_sink <= 0
 edge_flow_constr_2_sink: flow_2_sink - 6.9e+06 switch_2_sink <= 0
 edge_flow_constr_3_sink: flow_3_sink - 7.3e+06 switch_3_sink <= 0
 edge_flow_constr_4_sink: flow_4_sink - 7.25e+06 switch_4_sink <= 0
 edge_flow_constr_5_sink: flow_5_sink - 6.35e+06 switch_5_sink <= 0
 edge_flow_constr_6_sink: flow_6_sink - 6.75e+06 switch_6_sink <= 0
 edge_flow_constr_7_sink: flow_7_sink - 7.05e+06 switch_7_sink <= 0
 edge_flow_constr_0_1: flow_0_1 - 90745.19230769231 switch_0_1 <= 0
 edge_flow_constr_1_0: flow_1_0 - 90745.19230769231 switch_1_0 <= 0
 edge_flow_constr_0_2: flow_0_2 - 901.4423076923077 switch_0_2 <= 0
 edge_flow_constr_2_0: flow_2_0 - 901.4423076923077 switch_2_0 <= 0
 edge_flow_constr_0_3: flow_0_3 - 908.9543269230769 switch_0_3 <= 0
 edge_flow_constr_3_0: flow_3_0 - 908.9543269230769 switch_3_0 <= 0
 edge_flow_constr_0_4: flow_0_4 - 1089.242788461539 switch_0_4 <= 0
 edge_flow_constr_4_0: flow_4_0 - 1089.242788461539 switch_4_0 <= 0
 edge_flow_constr_0_5: flow_0_5 - 1066.706730769231 switch_0_5 <= 0
 edge_flow_constr_5_0: flow_5_0 - 1066.706730769231 switch_5_0 <= 0
 edge_flow_constr_0_6: flow_0_6 - 878.90625 switch_0_6 <= 0
 edge_flow_constr_6_0: flow_6_0 - 878.90625 switch_6_0 <= 0
 edge_flow_constr_0_7: flow_0_7 - 1014.122596153846 switch_0_7 <= 0
 edge_flow_constr_7_0: flow_7_0 - 1014.122596153846 switch_7_0 <= 0
 edge_flow_constr_1_2: flow_1_2 - 916.4663461538462 switch_1_2 <= 0
 edge_flow_constr_2_1: flow_2_1 - 916.4663461538462 switch_2_1 <= 0
 edge_flow_constr_1_3: flow_1_3 - 773.7379807692307 switch_1_3 <= 0
 edge_flow_constr_3_1: flow_3_1 - 773.7379807692307 switch_3_1 <= 0
 edge_flow_constr_1_4: flow_1_4 - 1014.122596153846 switch_1_4 <= 0
 edge_flow_constr_4_1: flow_4_1 - 1014.122596153846 switch_4_1 <= 0
 edge_flow_constr_1_5: flow_1_5 - 923.9783653846154 switch_1_5 <= 0
 edge_flow_constr_5_1: flow_5_1 - 923.9783653846154 switch_5_1 <= 0
 edge_flow_constr_1_6: flow_1_6 - 796.2740384615385 switch_1_6 <= 0
 edge_flow_constr_6_1: flow_6_1 - 796.2740384615385 switch_6_1 <= 0
 edge_flow_constr_1_7: flow_1_7 - 826.3221153846154 switch_1_7 <= 0
 edge_flow_constr_7_1: flow_7_1 - 826.3221153846154 switch_7_1 <= 0
 edge_flow_constr_2_3: flow_2_3 - 92172.47596153847 switch_2_3 <= 0
 edge_flow_constr_3_2: flow_3_2 - 92172.47596153847 switch_3_2 <= 0
 edge_flow_constr_2_4: flow_2_4 - 98182.09134615384 switch_2_4 <= 0
 edge_flow_constr_4_2: flow_4_2 - 98182.09134615384 switch_4_2 <= 0
 edge_flow_constr_2_5: flow_2_5 - 88266.22596153847 switch_2_5 <= 0
 edge_flow_constr_5_2: flow_5_2 - 88266.22596153847 switch_5_2 <= 0
 edge_flow_constr_2_6: flow_2_6 - 93299.27884615384 switch_2_6 <= 0
 edge_flow_constr_6_2: flow_6_2 - 93299.27884615384 switch_6_2 <= 0
 edge_flow_constr_2_7: flow_2_7 - 99459.13461538461 switch_2_7 <= 0
 edge_flow_constr_7_2: flow_7_2 - 99459.13461538461 switch_7_2 <= 0
 edge_flow_constr_3_4: flow_3_4 - 92998.79807692308 switch_3_4 <= 0
 edge_flow_constr_4_3: flow_4_3 - 92998.79807692308 switch_4_3 <= 0
 edge_flow_constr_3_5: flow_3_5 - 87139.42307692308 switch_3_5 <= 0
 edge_flow_constr_5_3: flow_5_3 - 87139.42307692308 switch_5_3 <= 0
 edge_flow_constr_3_6: flow_3_6 - 96454.32692307692 switch_3_6 <= 0
 edge_flow_constr_6_3: flow_6_3 - 96454.32692307692 switch_6_3 <= 0
 edge_flow_constr_3_7: flow_3_7 - 88266.22596153847 switch_3_7 <= 0
 edge_flow_constr_7_3: flow_7_3 - 88266.22596153847 switch_7_3 <= 0
 edge_flow_constr_4_5: flow_4_5 - 97731.37019230769 switch_4_5 <= 0
 edge_flow_constr_5_4: flow_5_4 - 97731.37019230769 switch_5_4 <= 0
 edge_flow_constr_4_6: flow_4_6 - 97205.52884615384 switch_4_6 <= 0
 edge_flow_constr_6_4: flow_6_4 - 97205.52884615384 switch_6_4 <= 0
 edge_flow_constr_4_7: flow_4_7 - 88867.1875 switch_4_7 <= 0
 edge_flow_constr_7_4: flow_7_4 - 88867.1875 switch_7_4 <= 0
 edge_flow_constr_5_6: flow_5_6 - 91947.11538461539 switch_5_6 <= 0
 edge_flow_constr_6_5: flow_6_5 - 91947.11538461539 switch_6_5 <= 0
 edge_flow_constr_5_7: flow_5_7 - 89242.78846153847 switch_5_7 <= 0
 edge_flow_constr_7_5: flow_7_5 - 89242.78846153847 switch_7_5 <= 0
 edge_flow_constr_6_7: flow_6_7 - 89167.66826923077 switch_6_7 <= 0
 edge_flow_constr_7_6: flow_7_6 - 89167.66826923077 switch_7_6 <= 0
Bounds
 start_0 <= 59
 start_1 <= 59
 start_2 <= 59
 start_3 <= 59
 start_4 <= 59
 start_5 <= 59
 start_6 <= 59
 start_7 <= 59
Binaries
 hold_0_1 hold_0_2 hold_0_3 hold_0_4 hold_0_5 hold_0_6 hold_0_7 hold_0_8
 hold_0_9 hold_0_10 hold_0_11 hold_1_1 hold_1_2 hold_1_3 hold_1_4 hold_1_5
 hold_1_6 hold_1_7 hold_1_8 hold_1_9 hold_1_10 hold_1_11 hold_2_1 hold_2_2
 hold_2_3 hold_2_4 hold_2_5 hold_2_6 hold_2_7 hold_2_8 hold_2_9 hold_2_10
 hold_2_11 hold_3_1 hold_3_2 hold_3_3 hold_3_4 hold_3_5 hold_3_6 hold_3_7
 hold_3_8 hold_3_9 hold_3_10 hold_3_11 hold_4_1 hold_4_2 hold_4_3 hold_4_4
 hold_4_5 hold_4_6 hold_4_7 hold_4_8 hold_4_9 hold_4_10 hold_4_11 hold_5_1
 hold_5_2 hold_5_3 hold_5_4 hold_5_5 hold_5_6 hold_5_7 hold_5_8 hold_5_9
 hold_5_10 hold_5_11 hold_6_1 hold_6_2 hold_6_3 hold_6_4 hold_6_5 hold_6_6
 hold_6_7 hold_6_8 hold_6_9 hold_6_10 hold_6_11 hold_7_1 hold_7_2 hold_7_3
 hold_7_4 hold_7_5 hold_7_6 hold_7_7 hold_7_8 hold_7_9 hold_7_10 hold_7_11
 switch_source_0 switch_source_1 switch_source_2 switch_source_3
 switch_source_4 switch_source_5 switch_source_6 switch_source_7
 switch_0_sink switch_1_sink switch_2_sink switch_3_sink switch_4_sink
 switch_5_sink switch_6_sink switch_7_sink switch_0_1 switch_1_0 switch_0_2
 switch_2_0 switch_0_3 switch_3_0 switch_0_4 switch_4_0 switch_0_5
 switch_5_0 switch_0_6 switch_6_0 switch_0_7 switch_7_0 switch_1_2
 switch_2_1 switch_1_3 switch_3_1 switch_1_4 switch_4_1 switch_1_5
 switch_5_1 switch_1_6 switch_6_1 switch_1_7 switch_7_1 switch_2_3
 switch_3_2 switch_2_4 switch_4_2 switch_2_5 switch_5_2 switch_2_6
 switch_6_2 switch_2_7 switch_7_2 switch_3_4 switch_4_3 switch_3_5
 switch_5_3 switch_3_6 switch_6_3 switch_3_7 switch_7_3 switch_4_5
 switch_5_4 switch_4_6 switch_6_4 switch_4_7 switch_7_4 switch_5_6
 switch_6_5 switch_5_7 switch_7_5 switch_6_7 switch_7_6
Generals
 start_0 start_1 start_2 start_3 start_4 start_5 start_6 start_7
End
