\ Model 2024-11-07_16-54-08
\ LP format - for model browsing. Use MPS format to capture full model detail.
Maximize
  flow_source_0 + flow_source_1 + flow_source_2 + flow_source_3
   + flow_source_4 + flow_source_5 + flow_source_6 + flow_source_7
   + flow_source_8 + flow_source_9 + flow_source_10 + flow_source_11
Subject To
 hold_constraint_0: hold_0_1 + hold_0_2 + hold_0_3 + hold_0_4 + hold_0_5
   + hold_0_6 + hold_0_7 = 1
 end_constraint_0: start_0 + hold_0_1 + 2 hold_0_2 + 3 hold_0_3
   + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7 <= 60
 hold_constraint_1: hold_1_1 + hold_1_2 + hold_1_3 + hold_1_4 + hold_1_5
   + hold_1_6 + hold_1_7 = 1
 end_constraint_1: start_1 + hold_1_1 + 2 hold_1_2 + 3 hold_1_3
   + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7 <= 60
 hold_constraint_2: hold_2_1 + hold_2_2 + hold_2_3 + hold_2_4 + hold_2_5
   + hold_2_6 + hold_2_7 = 1
 end_constraint_2: start_2 + hold_2_1 + 2 hold_2_2 + 3 hold_2_3
   + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7 <= 60
 hold_constraint_3: hold_3_1 + hold_3_2 + hold_3_3 + hold_3_4 + hold_3_5
   + hold_3_6 + hold_3_7 = 1
 end_constraint_3: start_3 + hold_3_1 + 2 hold_3_2 + 3 hold_3_3
   + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7 <= 60
 hold_constraint_4: hold_4_1 + hold_4_2 + hold_4_3 + hold_4_4 + hold_4_5
   + hold_4_6 + hold_4_7 = 1
 end_constraint_4: start_4 + hold_4_1 + 2 hold_4_2 + 3 hold_4_3
   + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7 <= 60
 hold_constraint_5: hold_5_1 + hold_5_2 + hold_5_3 + hold_5_4 + hold_5_5
   + hold_5_6 + hold_5_7 = 1
 end_constraint_5: start_5 + hold_5_1 + 2 hold_5_2 + 3 hold_5_3
   + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7 <= 60
 hold_constraint_6: hold_6_1 + hold_6_2 + hold_6_3 + hold_6_4 + hold_6_5
   + hold_6_6 + hold_6_7 = 1
 end_constraint_6: start_6 + hold_6_1 + 2 hold_6_2 + 3 hold_6_3
   + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7 <= 60
 hold_constraint_7: hold_7_1 + hold_7_2 + hold_7_3 + hold_7_4 + hold_7_5
   + hold_7_6 + hold_7_7 = 1
 end_constraint_7: start_7 + hold_7_1 + 2 hold_7_2 + 3 hold_7_3
   + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7 <= 60
 hold_constraint_8: hold_8_1 + hold_8_2 + hold_8_3 + hold_8_4 + hold_8_5
   + hold_8_6 + hold_8_7 = 1
 end_constraint_8: start_8 + hold_8_1 + 2 hold_8_2 + 3 hold_8_3
   + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7 <= 60
 hold_constraint_9: hold_9_1 + hold_9_2 + hold_9_3 + hold_9_4 + hold_9_5
   + hold_9_6 + hold_9_7 = 1
 end_constraint_9: start_9 + hold_9_1 + 2 hold_9_2 + 3 hold_9_3
   + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7 <= 60
 hold_constraint_10: hold_10_1 + hold_10_2 + hold_10_3 + hold_10_4
   + hold_10_5 + hold_10_6 + hold_10_7 = 1
 end_constraint_10: start_10 + hold_10_1 + 2 hold_10_2 + 3 hold_10_3
   + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7 <= 60
 hold_constraint_11: hold_11_1 + hold_11_2 + hold_11_3 + hold_11_4
   + hold_11_5 + hold_11_6 + hold_11_7 = 1
 end_constraint_11: start_11 + hold_11_1 + 2 hold_11_2 + 3 hold_11_3
   + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7 <= 60
 node_flow_constraint_0: flow_source_0 - flow_0_sink - flow_0_1 + flow_1_0
   - flow_0_2 + flow_2_0 - flow_0_3 + flow_3_0 - flow_0_4 + flow_4_0
   - flow_0_5 + flow_5_0 - flow_0_6 + flow_6_0 - flow_0_7 + flow_7_0
   - flow_0_8 + flow_8_0 - flow_0_9 + flow_9_0 - flow_0_10 + flow_10_0
   - flow_0_11 + flow_11_0 = 0
 node_flow_constraint_1: flow_source_1 - flow_1_sink + flow_0_1 - flow_1_0
   - flow_1_2 + flow_2_1 - flow_1_3 + flow_3_1 - flow_1_4 + flow_4_1
   - flow_1_5 + flow_5_1 - flow_1_6 + flow_6_1 - flow_1_7 + flow_7_1
   - flow_1_8 + flow_8_1 - flow_1_9 + flow_9_1 - flow_1_10 + flow_10_1
   - flow_1_11 + flow_11_1 = 0
 node_flow_constraint_2: flow_source_2 - flow_2_sink + flow_0_2 - flow_2_0
   + flow_1_2 - flow_2_1 - flow_2_3 + flow_3_2 - flow_2_4 + flow_4_2
   - flow_2_5 + flow_5_2 - flow_2_6 + flow_6_2 - flow_2_7 + flow_7_2
   - flow_2_8 + flow_8_2 - flow_2_9 + flow_9_2 - flow_2_10 + flow_10_2
   - flow_2_11 + flow_11_2 = 0
 node_flow_constraint_3: flow_source_3 - flow_3_sink + flow_0_3 - flow_3_0
   + flow_1_3 - flow_3_1 + flow_2_3 - flow_3_2 - flow_3_4 + flow_4_3
   - flow_3_5 + flow_5_3 - flow_3_6 + flow_6_3 - flow_3_7 + flow_7_3
   - flow_3_8 + flow_8_3 - flow_3_9 + flow_9_3 - flow_3_10 + flow_10_3
   - flow_3_11 + flow_11_3 = 0
 node_flow_constraint_4: flow_source_4 - flow_4_sink + flow_0_4 - flow_4_0
   + flow_1_4 - flow_4_1 + flow_2_4 - flow_4_2 + flow_3_4 - flow_4_3
   - flow_4_5 + flow_5_4 - flow_4_6 + flow_6_4 - flow_4_7 + flow_7_4
   - flow_4_8 + flow_8_4 - flow_4_9 + flow_9_4 - flow_4_10 + flow_10_4
   - flow_4_11 + flow_11_4 = 0
 node_flow_constraint_5: flow_source_5 - flow_5_sink + flow_0_5 - flow_5_0
   + flow_1_5 - flow_5_1 + flow_2_5 - flow_5_2 + flow_3_5 - flow_5_3
   + flow_4_5 - flow_5_4 - flow_5_6 + flow_6_5 - flow_5_7 + flow_7_5
   - flow_5_8 + flow_8_5 - flow_5_9 + flow_9_5 - flow_5_10 + flow_10_5
   - flow_5_11 + flow_11_5 = 0
 node_flow_constraint_6: flow_source_6 - flow_6_sink + flow_0_6 - flow_6_0
   + flow_1_6 - flow_6_1 + flow_2_6 - flow_6_2 + flow_3_6 - flow_6_3
   + flow_4_6 - flow_6_4 + flow_5_6 - flow_6_5 - flow_6_7 + flow_7_6
   - flow_6_8 + flow_8_6 - flow_6_9 + flow_9_6 - flow_6_10 + flow_10_6
   - flow_6_11 + flow_11_6 = 0
 node_flow_constraint_7: flow_source_7 - flow_7_sink + flow_0_7 - flow_7_0
   + flow_1_7 - flow_7_1 + flow_2_7 - flow_7_2 + flow_3_7 - flow_7_3
   + flow_4_7 - flow_7_4 + flow_5_7 - flow_7_5 + flow_6_7 - flow_7_6
   - flow_7_8 + flow_8_7 - flow_7_9 + flow_9_7 - flow_7_10 + flow_10_7
   - flow_7_11 + flow_11_7 = 0
 node_flow_constraint_8: flow_source_8 - flow_8_sink + flow_0_8 - flow_8_0
   + flow_1_8 - flow_8_1 + flow_2_8 - flow_8_2 + flow_3_8 - flow_8_3
   + flow_4_8 - flow_8_4 + flow_5_8 - flow_8_5 + flow_6_8 - flow_8_6
   + flow_7_8 - flow_8_7 - flow_8_9 + flow_9_8 - flow_8_10 + flow_10_8
   - flow_8_11 + flow_11_8 = 0
 node_flow_constraint_9: flow_source_9 - flow_9_sink + flow_0_9 - flow_9_0
   + flow_1_9 - flow_9_1 + flow_2_9 - flow_9_2 + flow_3_9 - flow_9_3
   + flow_4_9 - flow_9_4 + flow_5_9 - flow_9_5 + flow_6_9 - flow_9_6
   + flow_7_9 - flow_9_7 + flow_8_9 - flow_9_8 - flow_9_10 + flow_10_9
   - flow_9_11 + flow_11_9 = 0
 node_flow_constraint_10: flow_source_10 - flow_10_sink + flow_0_10
   - flow_10_0 + flow_1_10 - flow_10_1 + flow_2_10 - flow_10_2 + flow_3_10
   - flow_10_3 + flow_4_10 - flow_10_4 + flow_5_10 - flow_10_5 + flow_6_10
   - flow_10_6 + flow_7_10 - flow_10_7 + flow_8_10 - flow_10_8 + flow_9_10
   - flow_10_9 - flow_10_11 + flow_11_10 = 0
 node_flow_constraint_11: flow_source_11 - flow_11_sink + flow_0_11
   - flow_11_0 + flow_1_11 - flow_11_1 + flow_2_11 - flow_11_2 + flow_3_11
   - flow_11_3 + flow_4_11 - flow_11_4 + flow_5_11 - flow_11_5 + flow_6_11
   - flow_11_6 + flow_7_11 - flow_11_7 + flow_8_11 - flow_11_8 + flow_9_11
   - flow_11_9 + flow_10_11 - flow_11_10 = 0
 node_throughput_constraint_0: - 1803.997621271998 hold_0_1
   - 808.4988909790768 hold_0_2 - 539.0154802625716 hold_0_3
   - 356.6720490577613 hold_0_4 - 397.6850640835783 hold_0_5
   - 331.373421327816 hold_0_6 - 230.9919127164781 hold_0_7 + flow_source_0
   + flow_1_0 + flow_2_0 + flow_3_0 + flow_4_0 + flow_5_0 + flow_6_0
   + flow_7_0 + flow_8_0 + flow_9_0 + flow_10_0 + flow_11_0 <= 0
 node_throughput_constraint_1: - 1803.997621271998 hold_1_1
   - 808.4988909790768 hold_1_2 - 539.0154802625716 hold_1_3
   - 356.6720490577613 hold_1_4 - 397.6850640835783 hold_1_5
   - 331.373421327816 hold_1_6 - 230.9919127164781 hold_1_7 + flow_source_1
   + flow_0_1 + flow_2_1 + flow_3_1 + flow_4_1 + flow_5_1 + flow_6_1
   + flow_7_1 + flow_8_1 + flow_9_1 + flow_10_1 + flow_11_1 <= 0
 node_throughput_constraint_2: - 1803.997621271998 hold_2_1
   - 808.4988909790768 hold_2_2 - 539.0154802625716 hold_2_3
   - 356.6720490577613 hold_2_4 - 397.6850640835783 hold_2_5
   - 331.373421327816 hold_2_6 - 230.9919127164781 hold_2_7 + flow_source_2
   + flow_0_2 + flow_1_2 + flow_3_2 + flow_4_2 + flow_5_2 + flow_6_2
   + flow_7_2 + flow_8_2 + flow_9_2 + flow_10_2 + flow_11_2 <= 0
 node_throughput_constraint_3: - 1803.997621271998 hold_3_1
   - 808.4988909790768 hold_3_2 - 539.0154802625716 hold_3_3
   - 356.6720490577613 hold_3_4 - 397.6850640835783 hold_3_5
   - 331.373421327816 hold_3_6 - 230.9919127164781 hold_3_7 + flow_source_3
   + flow_0_3 + flow_1_3 + flow_2_3 + flow_4_3 + flow_5_3 + flow_6_3
   + flow_7_3 + flow_8_3 + flow_9_3 + flow_10_3 + flow_11_3 <= 0
 node_throughput_constraint_4: - 1803.997621271998 hold_4_1
   - 808.4988909790768 hold_4_2 - 539.0154802625716 hold_4_3
   - 356.6720490577613 hold_4_4 - 397.6850640835783 hold_4_5
   - 331.373421327816 hold_4_6 - 230.9919127164781 hold_4_7 + flow_source_4
   + flow_0_4 + flow_1_4 + flow_2_4 + flow_3_4 + flow_5_4 + flow_6_4
   + flow_7_4 + flow_8_4 + flow_9_4 + flow_10_4 + flow_11_4 <= 0
 node_throughput_constraint_5: - 1803.997621271998 hold_5_1
   - 808.4988909790768 hold_5_2 - 539.0154802625716 hold_5_3
   - 356.6720490577613 hold_5_4 - 397.6850640835783 hold_5_5
   - 331.373421327816 hold_5_6 - 230.9919127164781 hold_5_7 + flow_source_5
   + flow_0_5 + flow_1_5 + flow_2_5 + flow_3_5 + flow_4_5 + flow_6_5
   + flow_7_5 + flow_8_5 + flow_9_5 + flow_10_5 + flow_11_5 <= 0
 node_throughput_constraint_6: - 1803.997621271998 hold_6_1
   - 808.4988909790768 hold_6_2 - 539.0154802625716 hold_6_3
   - 356.6720490577613 hold_6_4 - 397.6850640835783 hold_6_5
   - 331.373421327816 hold_6_6 - 230.9919127164781 hold_6_7 + flow_source_6
   + flow_0_6 + flow_1_6 + flow_2_6 + flow_3_6 + flow_4_6 + flow_5_6
   + flow_7_6 + flow_8_6 + flow_9_6 + flow_10_6 + flow_11_6 <= 0
 node_throughput_constraint_7: - 1803.997621271998 hold_7_1
   - 808.4988909790768 hold_7_2 - 539.0154802625716 hold_7_3
   - 356.6720490577613 hold_7_4 - 397.6850640835783 hold_7_5
   - 331.373421327816 hold_7_6 - 230.9919127164781 hold_7_7 + flow_source_7
   + flow_0_7 + flow_1_7 + flow_2_7 + flow_3_7 + flow_4_7 + flow_5_7
   + flow_6_7 + flow_8_7 + flow_9_7 + flow_10_7 + flow_11_7 <= 0
 node_throughput_constraint_8: - 1803.997621271998 hold_8_1
   - 808.4988909790768 hold_8_2 - 539.0154802625716 hold_8_3
   - 356.6720490577613 hold_8_4 - 397.6850640835783 hold_8_5
   - 331.373421327816 hold_8_6 - 230.9919127164781 hold_8_7 + flow_source_8
   + flow_0_8 + flow_1_8 + flow_2_8 + flow_3_8 + flow_4_8 + flow_5_8
   + flow_6_8 + flow_7_8 + flow_9_8 + flow_10_8 + flow_11_8 <= 0
 node_throughput_constraint_9: - 1803.997621271998 hold_9_1
   - 808.4988909790768 hold_9_2 - 539.0154802625716 hold_9_3
   - 356.6720490577613 hold_9_4 - 397.6850640835783 hold_9_5
   - 331.373421327816 hold_9_6 - 230.9919127164781 hold_9_7 + flow_source_9
   + flow_0_9 + flow_1_9 + flow_2_9 + flow_3_9 + flow_4_9 + flow_5_9
   + flow_6_9 + flow_7_9 + flow_8_9 + flow_10_9 + flow_11_9 <= 0
 node_throughput_constraint_10: - 1803.997621271998 hold_10_1
   - 808.4988909790768 hold_10_2 - 539.0154802625716 hold_10_3
   - 356.6720490577613 hold_10_4 - 397.6850640835783 hold_10_5
   - 331.373421327816 hold_10_6 - 230.9919127164781 hold_10_7
   + flow_source_10 + flow_0_10 + flow_1_10 + flow_2_10 + flow_3_10
   + flow_4_10 + flow_5_10 + flow_6_10 + flow_7_10 + flow_8_10 + flow_9_10
   + flow_11_10 <= 0
 node_throughput_constraint_11: - 1803.997621271998 hold_11_1
   - 808.4988909790768 hold_11_2 - 539.0154802625716 hold_11_3
   - 356.6720490577613 hold_11_4 - 397.6850640835783 hold_11_5
   - 331.373421327816 hold_11_6 - 230.9919127164781 hold_11_7
   + flow_source_11 + flow_0_11 + flow_1_11 + flow_2_11 + flow_3_11
   + flow_4_11 + flow_5_11 + flow_6_11 + flow_7_11 + flow_8_11 + flow_9_11
   + flow_10_11 <= 0
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
 edge_enable_constr_source_8: start_8 + switch_source_8 >= 1
 edge_disable_constr_source_8: start_8 + 60 switch_source_8 <= 60
 edge_enable_constr_source_9: start_9 + switch_source_9 >= 1
 edge_disable_constr_source_9: start_9 + 60 switch_source_9 <= 60
 edge_enable_constr_source_10: start_10 + switch_source_10 >= 1
 edge_disable_constr_source_10: start_10 + 60 switch_source_10 <= 60
 edge_enable_constr_source_11: start_11 + switch_source_11 >= 1
 edge_disable_constr_source_11: start_11 + 60 switch_source_11 <= 60
 edge_enable_constr_0_sink: - start_0 - hold_0_1 - 2 hold_0_2 - 3 hold_0_3
   - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7 + 59 switch_0_sink
   >= -59
 edge_disable_constr_0_sink: - start_0 - hold_0_1 - 2 hold_0_2 - 3 hold_0_3
   - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7 + 60 switch_0_sink
   <= 0
 edge_enable_constr_1_sink: - start_1 - hold_1_1 - 2 hold_1_2 - 3 hold_1_3
   - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7 + 59 switch_1_sink
   >= -59
 edge_disable_constr_1_sink: - start_1 - hold_1_1 - 2 hold_1_2 - 3 hold_1_3
   - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7 + 60 switch_1_sink
   <= 0
 edge_enable_constr_2_sink: - start_2 - hold_2_1 - 2 hold_2_2 - 3 hold_2_3
   - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7 + 59 switch_2_sink
   >= -59
 edge_disable_constr_2_sink: - start_2 - hold_2_1 - 2 hold_2_2 - 3 hold_2_3
   - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7 + 60 switch_2_sink
   <= 0
 edge_enable_constr_3_sink: - start_3 - hold_3_1 - 2 hold_3_2 - 3 hold_3_3
   - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7 + 59 switch_3_sink
   >= -59
 edge_disable_constr_3_sink: - start_3 - hold_3_1 - 2 hold_3_2 - 3 hold_3_3
   - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7 + 60 switch_3_sink
   <= 0
 edge_enable_constr_4_sink: - start_4 - hold_4_1 - 2 hold_4_2 - 3 hold_4_3
   - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7 + 59 switch_4_sink
   >= -59
 edge_disable_constr_4_sink: - start_4 - hold_4_1 - 2 hold_4_2 - 3 hold_4_3
   - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7 + 60 switch_4_sink
   <= 0
 edge_enable_constr_5_sink: - start_5 - hold_5_1 - 2 hold_5_2 - 3 hold_5_3
   - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7 + 59 switch_5_sink
   >= -59
 edge_disable_constr_5_sink: - start_5 - hold_5_1 - 2 hold_5_2 - 3 hold_5_3
   - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7 + 60 switch_5_sink
   <= 0
 edge_enable_constr_6_sink: - start_6 - hold_6_1 - 2 hold_6_2 - 3 hold_6_3
   - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7 + 59 switch_6_sink
   >= -59
 edge_disable_constr_6_sink: - start_6 - hold_6_1 - 2 hold_6_2 - 3 hold_6_3
   - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7 + 60 switch_6_sink
   <= 0
 edge_enable_constr_7_sink: - start_7 - hold_7_1 - 2 hold_7_2 - 3 hold_7_3
   - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7 + 59 switch_7_sink
   >= -59
 edge_disable_constr_7_sink: - start_7 - hold_7_1 - 2 hold_7_2 - 3 hold_7_3
   - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7 + 60 switch_7_sink
   <= 0
 edge_enable_constr_8_sink: - start_8 - hold_8_1 - 2 hold_8_2 - 3 hold_8_3
   - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7 + 59 switch_8_sink
   >= -59
 edge_disable_constr_8_sink: - start_8 - hold_8_1 - 2 hold_8_2 - 3 hold_8_3
   - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7 + 60 switch_8_sink
   <= 0
 edge_enable_constr_9_sink: - start_9 - hold_9_1 - 2 hold_9_2 - 3 hold_9_3
   - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7 + 59 switch_9_sink
   >= -59
 edge_disable_constr_9_sink: - start_9 - hold_9_1 - 2 hold_9_2 - 3 hold_9_3
   - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7 + 60 switch_9_sink
   <= 0
 edge_enable_constr_10_sink: - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 59 switch_10_sink >= -59
 edge_disable_constr_10_sink: - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_sink <= 0
 edge_enable_constr_11_sink: - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 59 switch_11_sink >= -59
 edge_disable_constr_11_sink: - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_sink <= 0
 edge_disable_constr1_0_1: start_0 - start_1 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_1 <= 60
 edge_disable_constr2_0_1: - start_0 + start_1 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_1 <= 60
 edge_disable_constr1_1_0: - start_0 + start_1 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_0 <= 60
 edge_disable_constr2_1_0: start_0 - start_1 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_0 <= 60
 edge_disable_constr1_0_2: start_0 - start_2 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_2 <= 60
 edge_disable_constr2_0_2: - start_0 + start_2 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_2 <= 60
 edge_disable_constr1_2_0: - start_0 + start_2 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_0 <= 60
 edge_disable_constr2_2_0: start_0 - start_2 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_0 <= 60
 edge_disable_constr1_0_3: start_0 - start_3 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_3 <= 60
 edge_disable_constr2_0_3: - start_0 + start_3 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_3 <= 60
 edge_disable_constr1_3_0: - start_0 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_0 <= 60
 edge_disable_constr2_3_0: start_0 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_0 <= 60
 edge_disable_constr1_0_4: start_0 - start_4 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_4 <= 60
 edge_disable_constr2_0_4: - start_0 + start_4 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_4 <= 60
 edge_disable_constr1_4_0: - start_0 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_0 <= 60
 edge_disable_constr2_4_0: start_0 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_0 <= 60
 edge_disable_constr1_0_5: start_0 - start_5 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_5 <= 60
 edge_disable_constr2_0_5: - start_0 + start_5 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_5 <= 60
 edge_disable_constr1_5_0: - start_0 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_0 <= 60
 edge_disable_constr2_5_0: start_0 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_0 <= 60
 edge_disable_constr1_0_6: start_0 - start_6 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_6 <= 60
 edge_disable_constr2_0_6: - start_0 + start_6 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_6 <= 60
 edge_disable_constr1_6_0: - start_0 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_0 <= 60
 edge_disable_constr2_6_0: start_0 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_0 <= 60
 edge_disable_constr1_0_7: start_0 - start_7 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_7 <= 60
 edge_disable_constr2_0_7: - start_0 + start_7 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_7 <= 60
 edge_disable_constr1_7_0: - start_0 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_0 <= 60
 edge_disable_constr2_7_0: start_0 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_0 <= 60
 edge_disable_constr1_0_8: start_0 - start_8 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_8 <= 60
 edge_disable_constr2_0_8: - start_0 + start_8 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_8 <= 60
 edge_disable_constr1_8_0: - start_0 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_0 <= 60
 edge_disable_constr2_8_0: start_0 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_0 <= 60
 edge_disable_constr1_0_9: start_0 - start_9 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_9 <= 60
 edge_disable_constr2_0_9: - start_0 + start_9 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_9 <= 60
 edge_disable_constr1_9_0: - start_0 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_0 <= 60
 edge_disable_constr2_9_0: start_0 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_0 <= 60
 edge_disable_constr1_0_10: start_0 - start_10 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_10 <= 60
 edge_disable_constr2_0_10: - start_0 + start_10 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_10 <= 60
 edge_disable_constr1_10_0: - start_0 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_0 <= 60
 edge_disable_constr2_10_0: start_0 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_0 <= 60
 edge_disable_constr1_0_11: start_0 - start_11 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_11 <= 60
 edge_disable_constr2_0_11: - start_0 + start_11 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_11 <= 60
 edge_disable_constr1_11_0: - start_0 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_0 <= 60
 edge_disable_constr2_11_0: start_0 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_0 <= 60
 edge_disable_constr1_1_2: start_1 - start_2 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_2 <= 60
 edge_disable_constr2_1_2: - start_1 + start_2 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_2 <= 60
 edge_disable_constr1_2_1: - start_1 + start_2 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_1 <= 60
 edge_disable_constr2_2_1: start_1 - start_2 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_1 <= 60
 edge_disable_constr1_1_3: start_1 - start_3 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_3 <= 60
 edge_disable_constr2_1_3: - start_1 + start_3 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_3 <= 60
 edge_disable_constr1_3_1: - start_1 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_1 <= 60
 edge_disable_constr2_3_1: start_1 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_1 <= 60
 edge_disable_constr1_1_4: start_1 - start_4 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_4 <= 60
 edge_disable_constr2_1_4: - start_1 + start_4 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_4 <= 60
 edge_disable_constr1_4_1: - start_1 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_1 <= 60
 edge_disable_constr2_4_1: start_1 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_1 <= 60
 edge_disable_constr1_1_5: start_1 - start_5 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_5 <= 60
 edge_disable_constr2_1_5: - start_1 + start_5 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_5 <= 60
 edge_disable_constr1_5_1: - start_1 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_1 <= 60
 edge_disable_constr2_5_1: start_1 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_1 <= 60
 edge_disable_constr1_1_6: start_1 - start_6 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_6 <= 60
 edge_disable_constr2_1_6: - start_1 + start_6 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_6 <= 60
 edge_disable_constr1_6_1: - start_1 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_1 <= 60
 edge_disable_constr2_6_1: start_1 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_1 <= 60
 edge_disable_constr1_1_7: start_1 - start_7 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_7 <= 60
 edge_disable_constr2_1_7: - start_1 + start_7 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_7 <= 60
 edge_disable_constr1_7_1: - start_1 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_1 <= 60
 edge_disable_constr2_7_1: start_1 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_1 <= 60
 edge_disable_constr1_1_8: start_1 - start_8 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_8 <= 60
 edge_disable_constr2_1_8: - start_1 + start_8 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_8 <= 60
 edge_disable_constr1_8_1: - start_1 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_1 <= 60
 edge_disable_constr2_8_1: start_1 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_1 <= 60
 edge_disable_constr1_1_9: start_1 - start_9 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_9 <= 60
 edge_disable_constr2_1_9: - start_1 + start_9 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_9 <= 60
 edge_disable_constr1_9_1: - start_1 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_1 <= 60
 edge_disable_constr2_9_1: start_1 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_1 <= 60
 edge_disable_constr1_1_10: start_1 - start_10 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_10 <= 60
 edge_disable_constr2_1_10: - start_1 + start_10 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_10 <= 60
 edge_disable_constr1_10_1: - start_1 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_1 <= 60
 edge_disable_constr2_10_1: start_1 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_1 <= 60
 edge_disable_constr1_1_11: start_1 - start_11 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 60 switch_1_11 <= 60
 edge_disable_constr2_1_11: - start_1 + start_11 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   + 60 switch_1_11 <= 60
 edge_disable_constr1_11_1: - start_1 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_1 <= 60
 edge_disable_constr2_11_1: start_1 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_1 <= 60
 edge_disable_constr1_2_3: start_2 - start_3 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_3 <= 60
 edge_disable_constr2_2_3: - start_2 + start_3 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_3 <= 60
 edge_disable_constr1_3_2: - start_2 + start_3 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_2 <= 60
 edge_disable_constr2_3_2: start_2 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_2 <= 60
 edge_disable_constr1_2_4: start_2 - start_4 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_4 <= 60
 edge_disable_constr2_2_4: - start_2 + start_4 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_4 <= 60
 edge_disable_constr1_4_2: - start_2 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_2 <= 60
 edge_disable_constr2_4_2: start_2 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_2 <= 60
 edge_disable_constr1_2_5: start_2 - start_5 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_5 <= 60
 edge_disable_constr2_2_5: - start_2 + start_5 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_5 <= 60
 edge_disable_constr1_5_2: - start_2 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_2 <= 60
 edge_disable_constr2_5_2: start_2 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_2 <= 60
 edge_disable_constr1_2_6: start_2 - start_6 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_6 <= 60
 edge_disable_constr2_2_6: - start_2 + start_6 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_6 <= 60
 edge_disable_constr1_6_2: - start_2 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_2 <= 60
 edge_disable_constr2_6_2: start_2 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_2 <= 60
 edge_disable_constr1_2_7: start_2 - start_7 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_7 <= 60
 edge_disable_constr2_2_7: - start_2 + start_7 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_7 <= 60
 edge_disable_constr1_7_2: - start_2 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_2 <= 60
 edge_disable_constr2_7_2: start_2 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_2 <= 60
 edge_disable_constr1_2_8: start_2 - start_8 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_8 <= 60
 edge_disable_constr2_2_8: - start_2 + start_8 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_8 <= 60
 edge_disable_constr1_8_2: - start_2 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_2 <= 60
 edge_disable_constr2_8_2: start_2 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_2 <= 60
 edge_disable_constr1_2_9: start_2 - start_9 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_9 <= 60
 edge_disable_constr2_2_9: - start_2 + start_9 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_9 <= 60
 edge_disable_constr1_9_2: - start_2 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_2 <= 60
 edge_disable_constr2_9_2: start_2 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_2 <= 60
 edge_disable_constr1_2_10: start_2 - start_10 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_10 <= 60
 edge_disable_constr2_2_10: - start_2 + start_10 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_10 <= 60
 edge_disable_constr1_10_2: - start_2 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_2 <= 60
 edge_disable_constr2_10_2: start_2 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_2 <= 60
 edge_disable_constr1_2_11: start_2 - start_11 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_11 <= 60
 edge_disable_constr2_2_11: - start_2 + start_11 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_11 <= 60
 edge_disable_constr1_11_2: - start_2 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_2 <= 60
 edge_disable_constr2_11_2: start_2 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_2 <= 60
 edge_disable_constr1_3_4: start_3 - start_4 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_4 <= 60
 edge_disable_constr2_3_4: - start_3 + start_4 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_4 <= 60
 edge_disable_constr1_4_3: - start_3 + start_4 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_3 <= 60
 edge_disable_constr2_4_3: start_3 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_3 <= 60
 edge_disable_constr1_3_5: start_3 - start_5 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_5 <= 60
 edge_disable_constr2_3_5: - start_3 + start_5 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_5 <= 60
 edge_disable_constr1_5_3: - start_3 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_3 <= 60
 edge_disable_constr2_5_3: start_3 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_3 <= 60
 edge_disable_constr1_3_6: start_3 - start_6 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_6 <= 60
 edge_disable_constr2_3_6: - start_3 + start_6 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_6 <= 60
 edge_disable_constr1_6_3: - start_3 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_3 <= 60
 edge_disable_constr2_6_3: start_3 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_3 <= 60
 edge_disable_constr1_3_7: start_3 - start_7 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_7 <= 60
 edge_disable_constr2_3_7: - start_3 + start_7 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_7 <= 60
 edge_disable_constr1_7_3: - start_3 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_3 <= 60
 edge_disable_constr2_7_3: start_3 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_3 <= 60
 edge_disable_constr1_3_8: start_3 - start_8 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_8 <= 60
 edge_disable_constr2_3_8: - start_3 + start_8 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_8 <= 60
 edge_disable_constr1_8_3: - start_3 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_3 <= 60
 edge_disable_constr2_8_3: start_3 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_3 <= 60
 edge_disable_constr1_3_9: start_3 - start_9 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_9 <= 60
 edge_disable_constr2_3_9: - start_3 + start_9 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_9 <= 60
 edge_disable_constr1_9_3: - start_3 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_3 <= 60
 edge_disable_constr2_9_3: start_3 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_3 <= 60
 edge_disable_constr1_3_10: start_3 - start_10 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_10 <= 60
 edge_disable_constr2_3_10: - start_3 + start_10 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_10 <= 60
 edge_disable_constr1_10_3: - start_3 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_3 <= 60
 edge_disable_constr2_10_3: start_3 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_3 <= 60
 edge_disable_constr1_3_11: start_3 - start_11 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_11 <= 60
 edge_disable_constr2_3_11: - start_3 + start_11 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_11 <= 60
 edge_disable_constr1_11_3: - start_3 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_3 <= 60
 edge_disable_constr2_11_3: start_3 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_3 <= 60
 edge_disable_constr1_4_5: start_4 - start_5 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_5 <= 60
 edge_disable_constr2_4_5: - start_4 + start_5 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_5 <= 60
 edge_disable_constr1_5_4: - start_4 + start_5 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_4 <= 60
 edge_disable_constr2_5_4: start_4 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_4 <= 60
 edge_disable_constr1_4_6: start_4 - start_6 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_6 <= 60
 edge_disable_constr2_4_6: - start_4 + start_6 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_6 <= 60
 edge_disable_constr1_6_4: - start_4 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_4 <= 60
 edge_disable_constr2_6_4: start_4 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_4 <= 60
 edge_disable_constr1_4_7: start_4 - start_7 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_7 <= 60
 edge_disable_constr2_4_7: - start_4 + start_7 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_7 <= 60
 edge_disable_constr1_7_4: - start_4 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_4 <= 60
 edge_disable_constr2_7_4: start_4 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_4 <= 60
 edge_disable_constr1_4_8: start_4 - start_8 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_8 <= 60
 edge_disable_constr2_4_8: - start_4 + start_8 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_8 <= 60
 edge_disable_constr1_8_4: - start_4 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_4 <= 60
 edge_disable_constr2_8_4: start_4 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_4 <= 60
 edge_disable_constr1_4_9: start_4 - start_9 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_9 <= 60
 edge_disable_constr2_4_9: - start_4 + start_9 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_9 <= 60
 edge_disable_constr1_9_4: - start_4 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_4 <= 60
 edge_disable_constr2_9_4: start_4 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_4 <= 60
 edge_disable_constr1_4_10: start_4 - start_10 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_10 <= 60
 edge_disable_constr2_4_10: - start_4 + start_10 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_10 <= 60
 edge_disable_constr1_10_4: - start_4 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_4 <= 60
 edge_disable_constr2_10_4: start_4 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_4 <= 60
 edge_disable_constr1_4_11: start_4 - start_11 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 60 switch_4_11 <= 60
 edge_disable_constr2_4_11: - start_4 + start_11 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   + 60 switch_4_11 <= 60
 edge_disable_constr1_11_4: - start_4 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_4 <= 60
 edge_disable_constr2_11_4: start_4 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_4 <= 60
 edge_disable_constr1_5_6: start_5 - start_6 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_6 <= 60
 edge_disable_constr2_5_6: - start_5 + start_6 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_6 <= 60
 edge_disable_constr1_6_5: - start_5 + start_6 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_5 <= 60
 edge_disable_constr2_6_5: start_5 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_5 <= 60
 edge_disable_constr1_5_7: start_5 - start_7 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_7 <= 60
 edge_disable_constr2_5_7: - start_5 + start_7 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_7 <= 60
 edge_disable_constr1_7_5: - start_5 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_5 <= 60
 edge_disable_constr2_7_5: start_5 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_5 <= 60
 edge_disable_constr1_5_8: start_5 - start_8 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_8 <= 60
 edge_disable_constr2_5_8: - start_5 + start_8 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_8 <= 60
 edge_disable_constr1_8_5: - start_5 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_5 <= 60
 edge_disable_constr2_8_5: start_5 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_5 <= 60
 edge_disable_constr1_5_9: start_5 - start_9 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_9 <= 60
 edge_disable_constr2_5_9: - start_5 + start_9 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_9 <= 60
 edge_disable_constr1_9_5: - start_5 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_5 <= 60
 edge_disable_constr2_9_5: start_5 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_5 <= 60
 edge_disable_constr1_5_10: start_5 - start_10 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_10 <= 60
 edge_disable_constr2_5_10: - start_5 + start_10 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_10 <= 60
 edge_disable_constr1_10_5: - start_5 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_5 <= 60
 edge_disable_constr2_10_5: start_5 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_5 <= 60
 edge_disable_constr1_5_11: start_5 - start_11 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_11 <= 60
 edge_disable_constr2_5_11: - start_5 + start_11 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_11 <= 60
 edge_disable_constr1_11_5: - start_5 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_5 <= 60
 edge_disable_constr2_11_5: start_5 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_5 <= 60
 edge_disable_constr1_6_7: start_6 - start_7 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_7 <= 60
 edge_disable_constr2_6_7: - start_6 + start_7 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_7 <= 60
 edge_disable_constr1_7_6: - start_6 + start_7 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_6 <= 60
 edge_disable_constr2_7_6: start_6 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_6 <= 60
 edge_disable_constr1_6_8: start_6 - start_8 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_8 <= 60
 edge_disable_constr2_6_8: - start_6 + start_8 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_8 <= 60
 edge_disable_constr1_8_6: - start_6 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_6 <= 60
 edge_disable_constr2_8_6: start_6 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_6 <= 60
 edge_disable_constr1_6_9: start_6 - start_9 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_9 <= 60
 edge_disable_constr2_6_9: - start_6 + start_9 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_9 <= 60
 edge_disable_constr1_9_6: - start_6 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_6 <= 60
 edge_disable_constr2_9_6: start_6 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_6 <= 60
 edge_disable_constr1_6_10: start_6 - start_10 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_10 <= 60
 edge_disable_constr2_6_10: - start_6 + start_10 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_10 <= 60
 edge_disable_constr1_10_6: - start_6 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_6 <= 60
 edge_disable_constr2_10_6: start_6 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_6 <= 60
 edge_disable_constr1_6_11: start_6 - start_11 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_11 <= 60
 edge_disable_constr2_6_11: - start_6 + start_11 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_11 <= 60
 edge_disable_constr1_11_6: - start_6 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_6 <= 60
 edge_disable_constr2_11_6: start_6 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_6 <= 60
 edge_disable_constr1_7_8: start_7 - start_8 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_8 <= 60
 edge_disable_constr2_7_8: - start_7 + start_8 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_8 <= 60
 edge_disable_constr1_8_7: - start_7 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_7 <= 60
 edge_disable_constr2_8_7: start_7 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_7 <= 60
 edge_disable_constr1_7_9: start_7 - start_9 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_9 <= 60
 edge_disable_constr2_7_9: - start_7 + start_9 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_9 <= 60
 edge_disable_constr1_9_7: - start_7 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_7 <= 60
 edge_disable_constr2_9_7: start_7 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_7 <= 60
 edge_disable_constr1_7_10: start_7 - start_10 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_10 <= 60
 edge_disable_constr2_7_10: - start_7 + start_10 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_10 <= 60
 edge_disable_constr1_10_7: - start_7 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_7 <= 60
 edge_disable_constr2_10_7: start_7 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_7 <= 60
 edge_disable_constr1_7_11: start_7 - start_11 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_11 <= 60
 edge_disable_constr2_7_11: - start_7 + start_11 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_11 <= 60
 edge_disable_constr1_11_7: - start_7 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_7 <= 60
 edge_disable_constr2_11_7: start_7 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_7 <= 60
 edge_disable_constr1_8_9: start_8 - start_9 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_9 <= 60
 edge_disable_constr2_8_9: - start_8 + start_9 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_9 <= 60
 edge_disable_constr1_9_8: - start_8 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_8 <= 60
 edge_disable_constr2_9_8: start_8 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_8 <= 60
 edge_disable_constr1_8_10: start_8 - start_10 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_10 <= 60
 edge_disable_constr2_8_10: - start_8 + start_10 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_10 <= 60
 edge_disable_constr1_10_8: - start_8 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_8 <= 60
 edge_disable_constr2_10_8: start_8 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_8 <= 60
 edge_disable_constr1_8_11: start_8 - start_11 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 60 switch_8_11 <= 60
 edge_disable_constr2_8_11: - start_8 + start_11 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   + 60 switch_8_11 <= 60
 edge_disable_constr1_11_8: - start_8 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_8 <= 60
 edge_disable_constr2_11_8: start_8 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_8 <= 60
 edge_disable_constr1_9_10: start_9 - start_10 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_10 <= 60
 edge_disable_constr2_9_10: - start_9 + start_10 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_10 <= 60
 edge_disable_constr1_10_9: - start_9 + start_10 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_9 <= 60
 edge_disable_constr2_10_9: start_9 - start_10 - hold_10_1 - 2 hold_10_2
   - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6 - 7 hold_10_7
   + 60 switch_10_9 <= 60
 edge_disable_constr1_9_11: start_9 - start_11 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 60 switch_9_11 <= 60
 edge_disable_constr2_9_11: - start_9 + start_11 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   + 60 switch_9_11 <= 60
 edge_disable_constr1_11_9: - start_9 + start_11 + hold_11_1 + 2 hold_11_2
   + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6 + 7 hold_11_7
   + 60 switch_11_9 <= 60
 edge_disable_constr2_11_9: start_9 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_9 <= 60
 edge_disable_constr1_10_11: start_10 - start_11 + hold_10_1 + 2 hold_10_2
   + 3 hold_10_3 + 4 hold_10_4 + 5 hold_10_5 + 6 hold_10_6 + 7 hold_10_7
   + 60 switch_10_11 <= 60
 edge_disable_constr2_10_11: - start_10 + start_11 - hold_10_1
   - 2 hold_10_2 - 3 hold_10_3 - 4 hold_10_4 - 5 hold_10_5 - 6 hold_10_6
   - 7 hold_10_7 + 60 switch_10_11 <= 60
 edge_disable_constr1_11_10: - start_10 + start_11 + hold_11_1
   + 2 hold_11_2 + 3 hold_11_3 + 4 hold_11_4 + 5 hold_11_5 + 6 hold_11_6
   + 7 hold_11_7 + 60 switch_11_10 <= 60
 edge_disable_constr2_11_10: start_10 - start_11 - hold_11_1 - 2 hold_11_2
   - 3 hold_11_3 - 4 hold_11_4 - 5 hold_11_5 - 6 hold_11_6 - 7 hold_11_7
   + 60 switch_11_10 <= 60
 edge_flow_constr_source_0: flow_source_0 - 5.7e+06 switch_source_0 <= 0
 edge_flow_constr_source_1: flow_source_1 - 6.55e+06 switch_source_1 <= 0
 edge_flow_constr_source_2: flow_source_2 - 7.25e+06 switch_source_2 <= 0
 edge_flow_constr_source_3: flow_source_3 - 7.05e+06 switch_source_3 <= 0
 edge_flow_constr_source_4: flow_source_4 - 5.8e+06 switch_source_4 <= 0
 edge_flow_constr_source_5: flow_source_5 - 7.25e+06 switch_source_5 <= 0
 edge_flow_constr_source_6: flow_source_6 - 6.2e+06 switch_source_6 <= 0
 edge_flow_constr_source_7: flow_source_7 - 6.1e+06 switch_source_7 <= 0
 edge_flow_constr_source_8: flow_source_8 - 5e+06 switch_source_8 <= 0
 edge_flow_constr_source_9: flow_source_9 - 7.15e+06 switch_source_9 <= 0
 edge_flow_constr_source_10: flow_source_10 - 5.8e+06 switch_source_10
   <= 0
 edge_flow_constr_source_11: flow_source_11 - 5.5e+06 switch_source_11
   <= 0
 edge_flow_constr_0_sink: flow_0_sink - 7.05e+06 switch_0_sink <= 0
 edge_flow_constr_1_sink: flow_1_sink - 7.4e+06 switch_1_sink <= 0
 edge_flow_constr_2_sink: flow_2_sink - 6.45e+06 switch_2_sink <= 0
 edge_flow_constr_3_sink: flow_3_sink - 6.5e+06 switch_3_sink <= 0
 edge_flow_constr_4_sink: flow_4_sink - 6.45e+06 switch_4_sink <= 0
 edge_flow_constr_5_sink: flow_5_sink - 5.45e+06 switch_5_sink <= 0
 edge_flow_constr_6_sink: flow_6_sink - 6.55e+06 switch_6_sink <= 0
 edge_flow_constr_7_sink: flow_7_sink - 6.2e+06 switch_7_sink <= 0
 edge_flow_constr_8_sink: flow_8_sink - 7.25e+06 switch_8_sink <= 0
 edge_flow_constr_9_sink: flow_9_sink - 7.35e+06 switch_9_sink <= 0
 edge_flow_constr_10_sink: flow_10_sink - 6.15e+06 switch_10_sink <= 0
 edge_flow_constr_11_sink: flow_11_sink - 7.5e+06 switch_11_sink <= 0
 edge_flow_constr_0_1: flow_0_1 - 102914.6634615385 switch_0_1 <= 0
 edge_flow_constr_1_0: flow_1_0 - 102914.6634615385 switch_1_0 <= 0
 edge_flow_constr_0_2: flow_0_2 - 92097.35576923077 switch_0_2 <= 0
 edge_flow_constr_2_0: flow_2_0 - 92097.35576923077 switch_2_0 <= 0
 edge_flow_constr_0_3: flow_0_3 - 100961.5384615385 switch_0_3 <= 0
 edge_flow_constr_3_0: flow_3_0 - 100961.5384615385 switch_3_0 <= 0
 edge_flow_constr_0_4: flow_0_4 - 101712.7403846154 switch_0_4 <= 0
 edge_flow_constr_4_0: flow_4_0 - 101712.7403846154 switch_4_0 <= 0
 edge_flow_constr_0_5: flow_0_5 - 93825.12019230769 switch_0_5 <= 0
 edge_flow_constr_5_0: flow_5_0 - 93825.12019230769 switch_5_0 <= 0
 edge_flow_constr_0_6: flow_0_6 - 97055.28846153847 switch_0_6 <= 0
 edge_flow_constr_6_0: flow_6_0 - 97055.28846153847 switch_6_0 <= 0
 edge_flow_constr_0_7: flow_0_7 - 95928.48557692308 switch_0_7 <= 0
 edge_flow_constr_7_0: flow_7_0 - 95928.48557692308 switch_7_0 <= 0
 edge_flow_constr_0_8: flow_0_8 - 773.7379807692307 switch_0_8 <= 0
 edge_flow_constr_8_0: flow_8_0 - 773.7379807692307 switch_8_0 <= 0
 edge_flow_constr_0_9: flow_0_9 - 1074.21875 switch_0_9 <= 0
 edge_flow_constr_9_0: flow_9_0 - 1074.21875 switch_9_0 <= 0
 edge_flow_constr_0_10: flow_0_10 - 833.8341346153846 switch_0_10 <= 0
 edge_flow_constr_10_0: flow_10_0 - 833.8341346153846 switch_10_0 <= 0
 edge_flow_constr_0_11: flow_0_11 - 758.7139423076923 switch_0_11 <= 0
 edge_flow_constr_11_0: flow_11_0 - 758.7139423076923 switch_11_0 <= 0
 edge_flow_constr_1_2: flow_1_2 - 90670.07211538461 switch_1_2 <= 0
 edge_flow_constr_2_1: flow_2_1 - 90670.07211538461 switch_2_1 <= 0
 edge_flow_constr_1_3: flow_1_3 - 87289.66346153847 switch_1_3 <= 0
 edge_flow_constr_3_1: flow_3_1 - 87289.66346153847 switch_3_1 <= 0
 edge_flow_constr_1_4: flow_1_4 - 102689.3028846154 switch_1_4 <= 0
 edge_flow_constr_4_1: flow_4_1 - 102689.3028846154 switch_4_1 <= 0
 edge_flow_constr_1_5: flow_1_5 - 101412.2596153846 switch_1_5 <= 0
 edge_flow_constr_5_1: flow_5_1 - 101412.2596153846 switch_5_1 <= 0
 edge_flow_constr_1_6: flow_1_6 - 95252.40384615384 switch_1_6 <= 0
 edge_flow_constr_6_1: flow_6_1 - 95252.40384615384 switch_6_1 <= 0
 edge_flow_constr_1_7: flow_1_7 - 99609.375 switch_1_7 <= 0
 edge_flow_constr_7_1: flow_7_1 - 99609.375 switch_7_1 <= 0
 edge_flow_constr_1_8: flow_1_8 - 1051.682692307692 switch_1_8 <= 0
 edge_flow_constr_8_1: flow_8_1 - 1051.682692307692 switch_8_1 <= 0
 edge_flow_constr_1_9: flow_1_9 - 751.2019230769231 switch_1_9 <= 0
 edge_flow_constr_9_1: flow_9_1 - 751.2019230769231 switch_9_1 <= 0
 edge_flow_constr_1_10: flow_1_10 - 939.0024038461538 switch_1_10 <= 0
 edge_flow_constr_10_1: flow_10_1 - 939.0024038461538 switch_10_1 <= 0
 edge_flow_constr_1_11: flow_1_11 - 773.7379807692307 switch_1_11 <= 0
 edge_flow_constr_11_1: flow_11_1 - 773.7379807692307 switch_11_1 <= 0
 edge_flow_constr_2_3: flow_2_3 - 102163.4615384615 switch_2_3 <= 0
 edge_flow_constr_3_2: flow_3_2 - 102163.4615384615 switch_3_2 <= 0
 edge_flow_constr_2_4: flow_2_4 - 92172.47596153847 switch_2_4 <= 0
 edge_flow_constr_4_2: flow_4_2 - 92172.47596153847 switch_4_2 <= 0
 edge_flow_constr_2_5: flow_2_5 - 85637.01923076923 switch_2_5 <= 0
 edge_flow_constr_5_2: flow_5_2 - 85637.01923076923 switch_5_2 <= 0
 edge_flow_constr_2_6: flow_2_6 - 86838.94230769231 switch_2_6 <= 0
 edge_flow_constr_6_2: flow_6_2 - 86838.94230769231 switch_6_2 <= 0
 edge_flow_constr_2_7: flow_2_7 - 100060.0961538462 switch_2_7 <= 0
 edge_flow_constr_7_2: flow_7_2 - 100060.0961538462 switch_7_2 <= 0
 edge_flow_constr_2_8: flow_2_8 - 931.4903846153846 switch_2_8 <= 0
 edge_flow_constr_8_2: flow_8_2 - 931.4903846153846 switch_8_2 <= 0
 edge_flow_constr_2_9: flow_2_9 - 766.2259615384615 switch_2_9 <= 0
 edge_flow_constr_9_2: flow_9_2 - 766.2259615384615 switch_9_2 <= 0
 edge_flow_constr_2_10: flow_2_10 - 984.0745192307693 switch_2_10 <= 0
 edge_flow_constr_10_2: flow_10_2 - 984.0745192307693 switch_10_2 <= 0
 edge_flow_constr_2_11: flow_2_11 - 954.0264423076923 switch_2_11 <= 0
 edge_flow_constr_11_2: flow_11_2 - 954.0264423076923 switch_11_2 <= 0
 edge_flow_constr_3_4: flow_3_4 - 91646.63461538461 switch_3_4 <= 0
 edge_flow_constr_4_3: flow_4_3 - 91646.63461538461 switch_4_3 <= 0
 edge_flow_constr_3_5: flow_3_5 - 93674.87980769231 switch_3_5 <= 0
 edge_flow_constr_5_3: flow_5_3 - 93674.87980769231 switch_5_3 <= 0
 edge_flow_constr_3_6: flow_3_6 - 95928.48557692308 switch_3_6 <= 0
 edge_flow_constr_6_3: flow_6_3 - 95928.48557692308 switch_6_3 <= 0
 edge_flow_constr_3_7: flow_3_7 - 96379.20673076923 switch_3_7 <= 0
 edge_flow_constr_7_3: flow_7_3 - 96379.20673076923 switch_7_3 <= 0
 edge_flow_constr_3_8: flow_3_8 - 1044.170673076923 switch_3_8 <= 0
 edge_flow_constr_8_3: flow_8_3 - 1044.170673076923 switch_8_3 <= 0
 edge_flow_constr_3_9: flow_3_9 - 1044.170673076923 switch_3_9 <= 0
 edge_flow_constr_9_3: flow_9_3 - 1044.170673076923 switch_9_3 <= 0
 edge_flow_constr_3_10: flow_3_10 - 1036.658653846154 switch_3_10 <= 0
 edge_flow_constr_10_3: flow_10_3 - 1036.658653846154 switch_10_3 <= 0
 edge_flow_constr_3_11: flow_3_11 - 1044.170673076923 switch_3_11 <= 0
 edge_flow_constr_11_3: flow_11_3 - 1044.170673076923 switch_11_3 <= 0
 edge_flow_constr_4_5: flow_4_5 - 85336.53846153847 switch_4_5 <= 0
 edge_flow_constr_5_4: flow_5_4 - 85336.53846153847 switch_5_4 <= 0
 edge_flow_constr_4_6: flow_4_6 - 93599.75961538461 switch_4_6 <= 0
 edge_flow_constr_6_4: flow_6_4 - 93599.75961538461 switch_6_4 <= 0
 edge_flow_constr_4_7: flow_4_7 - 102238.5817307692 switch_4_7 <= 0
 edge_flow_constr_7_4: flow_7_4 - 102238.5817307692 switch_7_4 <= 0
 edge_flow_constr_4_8: flow_4_8 - 1096.754807692308 switch_4_8 <= 0
 edge_flow_constr_8_4: flow_8_4 - 1096.754807692308 switch_8_4 <= 0
 edge_flow_constr_4_9: flow_4_9 - 908.9543269230769 switch_4_9 <= 0
 edge_flow_constr_9_4: flow_9_4 - 908.9543269230769 switch_9_4 <= 0
 edge_flow_constr_4_10: flow_4_10 - 1044.170673076923 switch_4_10 <= 0
 edge_flow_constr_10_4: flow_10_4 - 1044.170673076923 switch_10_4 <= 0
 edge_flow_constr_4_11: flow_4_11 - 766.2259615384615 switch_4_11 <= 0
 edge_flow_constr_11_4: flow_11_4 - 766.2259615384615 switch_11_4 <= 0
 edge_flow_constr_5_6: flow_5_6 - 97355.76923076923 switch_5_6 <= 0
 edge_flow_constr_6_5: flow_6_5 - 97355.76923076923 switch_6_5 <= 0
 edge_flow_constr_5_7: flow_5_7 - 101712.7403846154 switch_5_7 <= 0
 edge_flow_constr_7_5: flow_7_5 - 101712.7403846154 switch_7_5 <= 0
 edge_flow_constr_5_8: flow_5_8 - 826.3221153846154 switch_5_8 <= 0
 edge_flow_constr_8_5: flow_8_5 - 826.3221153846154 switch_8_5 <= 0
 edge_flow_constr_5_9: flow_5_9 - 1104.266826923077 switch_5_9 <= 0
 edge_flow_constr_9_5: flow_9_5 - 1104.266826923077 switch_9_5 <= 0
 edge_flow_constr_5_10: flow_5_10 - 751.2019230769231 switch_5_10 <= 0
 edge_flow_constr_10_5: flow_10_5 - 751.2019230769231 switch_10_5 <= 0
 edge_flow_constr_5_11: flow_5_11 - 758.7139423076923 switch_5_11 <= 0
 edge_flow_constr_11_5: flow_11_5 - 758.7139423076923 switch_11_5 <= 0
 edge_flow_constr_6_7: flow_6_7 - 100585.9375 switch_6_7 <= 0
 edge_flow_constr_7_6: flow_7_6 - 100585.9375 switch_7_6 <= 0
 edge_flow_constr_6_8: flow_6_8 - 1126.802884615385 switch_6_8 <= 0
 edge_flow_constr_8_6: flow_8_6 - 1126.802884615385 switch_8_6 <= 0
 edge_flow_constr_6_9: flow_6_9 - 969.0504807692307 switch_6_9 <= 0
 edge_flow_constr_9_6: flow_9_6 - 969.0504807692307 switch_9_6 <= 0
 edge_flow_constr_6_10: flow_6_10 - 1089.242788461539 switch_6_10 <= 0
 edge_flow_constr_10_6: flow_10_6 - 1089.242788461539 switch_10_6 <= 0
 edge_flow_constr_6_11: flow_6_11 - 1051.682692307692 switch_6_11 <= 0
 edge_flow_constr_11_6: flow_11_6 - 1051.682692307692 switch_11_6 <= 0
 edge_flow_constr_7_8: flow_7_8 - 803.7860576923077 switch_7_8 <= 0
 edge_flow_constr_8_7: flow_8_7 - 803.7860576923077 switch_8_7 <= 0
 edge_flow_constr_7_9: flow_7_9 - 991.5865384615385 switch_7_9 <= 0
 edge_flow_constr_9_7: flow_9_7 - 991.5865384615385 switch_9_7 <= 0
 edge_flow_constr_7_10: flow_7_10 - 916.4663461538462 switch_7_10 <= 0
 edge_flow_constr_10_7: flow_10_7 - 916.4663461538462 switch_10_7 <= 0
 edge_flow_constr_7_11: flow_7_11 - 1104.266826923077 switch_7_11 <= 0
 edge_flow_constr_11_7: flow_11_7 - 1104.266826923077 switch_11_7 <= 0
 edge_flow_constr_8_9: flow_8_9 - 97581.12980769231 switch_8_9 <= 0
 edge_flow_constr_9_8: flow_9_8 - 97581.12980769231 switch_9_8 <= 0
 edge_flow_constr_8_10: flow_8_10 - 95552.88461538461 switch_8_10 <= 0
 edge_flow_constr_10_8: flow_10_8 - 95552.88461538461 switch_10_8 <= 0
 edge_flow_constr_8_11: flow_8_11 - 97055.28846153847 switch_8_11 <= 0
 edge_flow_constr_11_8: flow_11_8 - 97055.28846153847 switch_11_8 <= 0
 edge_flow_constr_9_10: flow_9_10 - 93374.39903846153 switch_9_10 <= 0
 edge_flow_constr_10_9: flow_10_9 - 93374.39903846153 switch_10_9 <= 0
 edge_flow_constr_9_11: flow_9_11 - 93449.51923076923 switch_9_11 <= 0
 edge_flow_constr_11_9: flow_11_9 - 93449.51923076923 switch_11_9 <= 0
 edge_flow_constr_10_11: flow_10_11 - 90444.71153846153 switch_10_11 <= 0
 edge_flow_constr_11_10: flow_11_10 - 90444.71153846153 switch_11_10 <= 0
Bounds
 start_0 <= 59
 start_1 <= 59
 start_2 <= 59
 start_3 <= 59
 start_4 <= 59
 start_5 <= 59
 start_6 <= 59
 start_7 <= 59
 start_8 <= 59
 start_9 <= 59
 start_10 <= 59
 start_11 <= 59
Binaries
 hold_0_1 hold_0_2 hold_0_3 hold_0_4 hold_0_5 hold_0_6 hold_0_7 hold_1_1
 hold_1_2 hold_1_3 hold_1_4 hold_1_5 hold_1_6 hold_1_7 hold_2_1 hold_2_2
 hold_2_3 hold_2_4 hold_2_5 hold_2_6 hold_2_7 hold_3_1 hold_3_2 hold_3_3
 hold_3_4 hold_3_5 hold_3_6 hold_3_7 hold_4_1 hold_4_2 hold_4_3 hold_4_4
 hold_4_5 hold_4_6 hold_4_7 hold_5_1 hold_5_2 hold_5_3 hold_5_4 hold_5_5
 hold_5_6 hold_5_7 hold_6_1 hold_6_2 hold_6_3 hold_6_4 hold_6_5 hold_6_6
 hold_6_7 hold_7_1 hold_7_2 hold_7_3 hold_7_4 hold_7_5 hold_7_6 hold_7_7
 hold_8_1 hold_8_2 hold_8_3 hold_8_4 hold_8_5 hold_8_6 hold_8_7 hold_9_1
 hold_9_2 hold_9_3 hold_9_4 hold_9_5 hold_9_6 hold_9_7 hold_10_1 hold_10_2
 hold_10_3 hold_10_4 hold_10_5 hold_10_6 hold_10_7 hold_11_1 hold_11_2
 hold_11_3 hold_11_4 hold_11_5 hold_11_6 hold_11_7 switch_source_0
 switch_source_1 switch_source_2 switch_source_3 switch_source_4
 switch_source_5 switch_source_6 switch_source_7 switch_source_8
 switch_source_9 switch_source_10 switch_source_11 switch_0_sink
 switch_1_sink switch_2_sink switch_3_sink switch_4_sink switch_5_sink
 switch_6_sink switch_7_sink switch_8_sink switch_9_sink switch_10_sink
 switch_11_sink switch_0_1 switch_1_0 switch_0_2 switch_2_0 switch_0_3
 switch_3_0 switch_0_4 switch_4_0 switch_0_5 switch_5_0 switch_0_6
 switch_6_0 switch_0_7 switch_7_0 switch_0_8 switch_8_0 switch_0_9
 switch_9_0 switch_0_10 switch_10_0 switch_0_11 switch_11_0 switch_1_2
 switch_2_1 switch_1_3 switch_3_1 switch_1_4 switch_4_1 switch_1_5
 switch_5_1 switch_1_6 switch_6_1 switch_1_7 switch_7_1 switch_1_8
 switch_8_1 switch_1_9 switch_9_1 switch_1_10 switch_10_1 switch_1_11
 switch_11_1 switch_2_3 switch_3_2 switch_2_4 switch_4_2 switch_2_5
 switch_5_2 switch_2_6 switch_6_2 switch_2_7 switch_7_2 switch_2_8
 switch_8_2 switch_2_9 switch_9_2 switch_2_10 switch_10_2 switch_2_11
 switch_11_2 switch_3_4 switch_4_3 switch_3_5 switch_5_3 switch_3_6
 switch_6_3 switch_3_7 switch_7_3 switch_3_8 switch_8_3 switch_3_9
 switch_9_3 switch_3_10 switch_10_3 switch_3_11 switch_11_3 switch_4_5
 switch_5_4 switch_4_6 switch_6_4 switch_4_7 switch_7_4 switch_4_8
 switch_8_4 switch_4_9 switch_9_4 switch_4_10 switch_10_4 switch_4_11
 switch_11_4 switch_5_6 switch_6_5 switch_5_7 switch_7_5 switch_5_8
 switch_8_5 switch_5_9 switch_9_5 switch_5_10 switch_10_5 switch_5_11
 switch_11_5 switch_6_7 switch_7_6 switch_6_8 switch_8_6 switch_6_9
 switch_9_6 switch_6_10 switch_10_6 switch_6_11 switch_11_6 switch_7_8
 switch_8_7 switch_7_9 switch_9_7 switch_7_10 switch_10_7 switch_7_11
 switch_11_7 switch_8_9 switch_9_8 switch_8_10 switch_10_8 switch_8_11
 switch_11_8 switch_9_10 switch_10_9 switch_9_11 switch_11_9 switch_10_11
 switch_11_10
Generals
 start_0 start_1 start_2 start_3 start_4 start_5 start_6 start_7 start_8
 start_9 start_10 start_11
End
