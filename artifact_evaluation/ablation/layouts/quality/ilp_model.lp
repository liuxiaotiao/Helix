\ Model 2024-10-26_19-46-55
\ LP format - for model browsing. Use MPS format to capture full model detail.
Maximize
  flow_source_0 + flow_source_1 + flow_source_2 + flow_source_3
   + flow_source_4 + flow_source_5 + flow_source_6 + flow_source_7
   + flow_source_8 + flow_source_9
Subject To
 hold_constraint_0: hold_0_1 + hold_0_2 + hold_0_3 + hold_0_4 + hold_0_5
   + hold_0_6 + hold_0_7 = 1
 end_constraint_0: start_0 + hold_0_1 + 2 hold_0_2 + 3 hold_0_3
   + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7 <= 60
 hold_constraint_1: hold_1_1 + hold_1_2 + hold_1_3 + hold_1_4 + hold_1_5
   + hold_1_6 + hold_1_7 + hold_1_8 + hold_1_9 + hold_1_10 + hold_1_11 = 1
 end_constraint_1: start_1 + hold_1_1 + 2 hold_1_2 + 3 hold_1_3
   + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7 + 8 hold_1_8
   + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 <= 60
 hold_constraint_2: hold_2_1 + hold_2_2 + hold_2_3 + hold_2_4 + hold_2_5
   + hold_2_6 + hold_2_7 = 1
 end_constraint_2: start_2 + hold_2_1 + 2 hold_2_2 + 3 hold_2_3
   + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7 <= 60
 hold_constraint_3: hold_3_1 + hold_3_2 + hold_3_3 + hold_3_4 + hold_3_5
   + hold_3_6 + hold_3_7 = 1
 end_constraint_3: start_3 + hold_3_1 + 2 hold_3_2 + 3 hold_3_3
   + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7 <= 60
 hold_constraint_4: hold_4_1 + hold_4_2 + hold_4_3 + hold_4_4 + hold_4_5
   + hold_4_6 + hold_4_7 + hold_4_8 + hold_4_9 + hold_4_10 + hold_4_11 = 1
 end_constraint_4: start_4 + hold_4_1 + 2 hold_4_2 + 3 hold_4_3
   + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7 + 8 hold_4_8
   + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 <= 60
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
   + hold_8_6 + hold_8_7 + hold_8_8 + hold_8_9 + hold_8_10 + hold_8_11 = 1
 end_constraint_8: start_8 + hold_8_1 + 2 hold_8_2 + 3 hold_8_3
   + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7 + 8 hold_8_8
   + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 <= 60
 hold_constraint_9: hold_9_1 + hold_9_2 + hold_9_3 + hold_9_4 + hold_9_5
   + hold_9_6 + hold_9_7 + hold_9_8 + hold_9_9 + hold_9_10 + hold_9_11 = 1
 end_constraint_9: start_9 + hold_9_1 + 2 hold_9_2 + 3 hold_9_3
   + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7 + 8 hold_9_8
   + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 <= 60
 node_flow_constraint_0: flow_source_0 - flow_0_sink - flow_0_1 + flow_1_0
   - flow_0_2 + flow_2_0 - flow_0_3 + flow_3_0 - flow_0_4 + flow_4_0
   - flow_0_5 + flow_5_0 - flow_0_6 + flow_6_0 - flow_0_7 + flow_7_0
   - flow_0_8 + flow_8_0 - flow_0_9 + flow_9_0 = 0
 node_flow_constraint_1: flow_source_1 - flow_1_sink + flow_0_1 - flow_1_0
   - flow_1_2 + flow_2_1 - flow_1_3 + flow_3_1 - flow_1_4 + flow_4_1
   - flow_1_5 + flow_5_1 - flow_1_6 + flow_6_1 - flow_1_7 + flow_7_1
   - flow_1_8 + flow_8_1 - flow_1_9 + flow_9_1 = 0
 node_flow_constraint_2: flow_source_2 - flow_2_sink + flow_0_2 - flow_2_0
   + flow_1_2 - flow_2_1 - flow_2_3 + flow_3_2 - flow_2_4 + flow_4_2
   - flow_2_5 + flow_5_2 - flow_2_6 + flow_6_2 - flow_2_7 + flow_7_2
   - flow_2_8 + flow_8_2 - flow_2_9 + flow_9_2 = 0
 node_flow_constraint_3: flow_source_3 - flow_3_sink + flow_0_3 - flow_3_0
   + flow_1_3 - flow_3_1 + flow_2_3 - flow_3_2 - flow_3_4 + flow_4_3
   - flow_3_5 + flow_5_3 - flow_3_6 + flow_6_3 - flow_3_7 + flow_7_3
   - flow_3_8 + flow_8_3 - flow_3_9 + flow_9_3 = 0
 node_flow_constraint_4: flow_source_4 - flow_4_sink + flow_0_4 - flow_4_0
   + flow_1_4 - flow_4_1 + flow_2_4 - flow_4_2 + flow_3_4 - flow_4_3
   - flow_4_5 + flow_5_4 - flow_4_6 + flow_6_4 - flow_4_7 + flow_7_4
   - flow_4_8 + flow_8_4 - flow_4_9 + flow_9_4 = 0
 node_flow_constraint_5: flow_source_5 - flow_5_sink + flow_0_5 - flow_5_0
   + flow_1_5 - flow_5_1 + flow_2_5 - flow_5_2 + flow_3_5 - flow_5_3
   + flow_4_5 - flow_5_4 - flow_5_6 + flow_6_5 - flow_5_7 + flow_7_5
   - flow_5_8 + flow_8_5 - flow_5_9 + flow_9_5 = 0
 node_flow_constraint_6: flow_source_6 - flow_6_sink + flow_0_6 - flow_6_0
   + flow_1_6 - flow_6_1 + flow_2_6 - flow_6_2 + flow_3_6 - flow_6_3
   + flow_4_6 - flow_6_4 + flow_5_6 - flow_6_5 - flow_6_7 + flow_7_6
   - flow_6_8 + flow_8_6 - flow_6_9 + flow_9_6 = 0
 node_flow_constraint_7: flow_source_7 - flow_7_sink + flow_0_7 - flow_7_0
   + flow_1_7 - flow_7_1 + flow_2_7 - flow_7_2 + flow_3_7 - flow_7_3
   + flow_4_7 - flow_7_4 + flow_5_7 - flow_7_5 + flow_6_7 - flow_7_6
   - flow_7_8 + flow_8_7 - flow_7_9 + flow_9_7 = 0
 node_flow_constraint_8: flow_source_8 - flow_8_sink + flow_0_8 - flow_8_0
   + flow_1_8 - flow_8_1 + flow_2_8 - flow_8_2 + flow_3_8 - flow_8_3
   + flow_4_8 - flow_8_4 + flow_5_8 - flow_8_5 + flow_6_8 - flow_8_6
   + flow_7_8 - flow_8_7 - flow_8_9 + flow_9_8 = 0
 node_flow_constraint_9: flow_source_9 - flow_9_sink + flow_0_9 - flow_9_0
   + flow_1_9 - flow_9_1 + flow_2_9 - flow_9_2 + flow_3_9 - flow_9_3
   + flow_4_9 - flow_9_4 + flow_5_9 - flow_9_5 + flow_6_9 - flow_9_6
   + flow_7_9 - flow_9_7 + flow_8_9 - flow_9_8 = 0
 node_throughput_constraint_0: - 1987.96933583407 hold_0_1
   - 901.9376894944129 hold_0_2 - 539.0387352860497 hold_0_3
   - 404.2621425031171 hold_0_4 - 285.3446689050558 hold_0_5
   - 331.3431275280855 hold_0_6 - 231.0619074422882 hold_0_7
   + flow_source_0 + flow_1_0 + flow_2_0 + flow_3_0 + flow_4_0 + flow_5_0
   + flow_6_0 + flow_7_0 + flow_8_0 + flow_9_0 <= 0
 node_throughput_constraint_1: - 2485.538093984443 hold_1_1
   - 1145.043877646622 hold_1_2 - 763.5176797357898 hold_1_3
   - 480.9921941878029 hold_1_4 - 384.9009498403431 hold_1_5
   - 286.5874097546421 hold_1_6 - 245.7346965865289 hold_1_7
   - 189.1084291640167 hold_1_8 - 168.1672159813898 hold_1_9
   - 212.6372855671968 hold_1_10 - 193.4964086035588 hold_1_11
   + flow_source_1 + flow_0_1 + flow_2_1 + flow_3_1 + flow_4_1 + flow_5_1
   + flow_6_1 + flow_7_1 + flow_8_1 + flow_9_1 <= 0
 node_throughput_constraint_2: - 1987.96933583407 hold_2_1
   - 901.9376894944129 hold_2_2 - 539.0387352860497 hold_2_3
   - 404.2621425031171 hold_2_4 - 285.3446689050558 hold_2_5
   - 331.3431275280855 hold_2_6 - 231.0619074422882 hold_2_7
   + flow_source_2 + flow_0_2 + flow_1_2 + flow_3_2 + flow_4_2 + flow_5_2
   + flow_6_2 + flow_7_2 + flow_8_2 + flow_9_2 <= 0
 node_throughput_constraint_3: - 1987.96933583407 hold_3_1
   - 901.9376894944129 hold_3_2 - 539.0387352860497 hold_3_3
   - 404.2621425031171 hold_3_4 - 285.3446689050558 hold_3_5
   - 331.3431275280855 hold_3_6 - 231.0619074422882 hold_3_7
   + flow_source_3 + flow_0_3 + flow_1_3 + flow_2_3 + flow_4_3 + flow_5_3
   + flow_6_3 + flow_7_3 + flow_8_3 + flow_9_3 <= 0
 node_throughput_constraint_4: - 2485.538093984443 hold_4_1
   - 1145.043877646622 hold_4_2 - 763.5176797357898 hold_4_3
   - 480.9921941878029 hold_4_4 - 384.9009498403431 hold_4_5
   - 286.5874097546421 hold_4_6 - 245.7346965865289 hold_4_7
   - 189.1084291640167 hold_4_8 - 168.1672159813898 hold_4_9
   - 212.6372855671968 hold_4_10 - 193.4964086035588 hold_4_11
   + flow_source_4 + flow_0_4 + flow_1_4 + flow_2_4 + flow_3_4 + flow_5_4
   + flow_6_4 + flow_7_4 + flow_8_4 + flow_9_4 <= 0
 node_throughput_constraint_5: - 1987.96933583407 hold_5_1
   - 901.9376894944129 hold_5_2 - 539.0387352860497 hold_5_3
   - 404.2621425031171 hold_5_4 - 285.3446689050558 hold_5_5
   - 331.3431275280855 hold_5_6 - 231.0619074422882 hold_5_7
   + flow_source_5 + flow_0_5 + flow_1_5 + flow_2_5 + flow_3_5 + flow_4_5
   + flow_6_5 + flow_7_5 + flow_8_5 + flow_9_5 <= 0
 node_throughput_constraint_6: - 1987.96933583407 hold_6_1
   - 901.9376894944129 hold_6_2 - 539.0387352860497 hold_6_3
   - 404.2621425031171 hold_6_4 - 285.3446689050558 hold_6_5
   - 331.3431275280855 hold_6_6 - 231.0619074422882 hold_6_7
   + flow_source_6 + flow_0_6 + flow_1_6 + flow_2_6 + flow_3_6 + flow_4_6
   + flow_5_6 + flow_7_6 + flow_8_6 + flow_9_6 <= 0
 node_throughput_constraint_7: - 1987.96933583407 hold_7_1
   - 901.9376894944129 hold_7_2 - 539.0387352860497 hold_7_3
   - 404.2621425031171 hold_7_4 - 285.3446689050558 hold_7_5
   - 331.3431275280855 hold_7_6 - 231.0619074422882 hold_7_7
   + flow_source_7 + flow_0_7 + flow_1_7 + flow_2_7 + flow_3_7 + flow_4_7
   + flow_5_7 + flow_6_7 + flow_8_7 + flow_9_7 <= 0
 node_throughput_constraint_8: - 2485.538093984443 hold_8_1
   - 1145.043877646622 hold_8_2 - 763.5176797357898 hold_8_3
   - 480.9921941878029 hold_8_4 - 384.9009498403431 hold_8_5
   - 286.5874097546421 hold_8_6 - 245.7346965865289 hold_8_7
   - 189.1084291640167 hold_8_8 - 168.1672159813898 hold_8_9
   - 212.6372855671968 hold_8_10 - 193.4964086035588 hold_8_11
   + flow_source_8 + flow_0_8 + flow_1_8 + flow_2_8 + flow_3_8 + flow_4_8
   + flow_5_8 + flow_6_8 + flow_7_8 + flow_9_8 <= 0
 node_throughput_constraint_9: - 2485.538093984443 hold_9_1
   - 1145.043877646622 hold_9_2 - 763.5176797357898 hold_9_3
   - 480.9921941878029 hold_9_4 - 384.9009498403431 hold_9_5
   - 286.5874097546421 hold_9_6 - 245.7346965865289 hold_9_7
   - 189.1084291640167 hold_9_8 - 168.1672159813898 hold_9_9
   - 212.6372855671968 hold_9_10 - 193.4964086035588 hold_9_11
   + flow_source_9 + flow_0_9 + flow_1_9 + flow_2_9 + flow_3_9 + flow_4_9
   + flow_5_9 + flow_6_9 + flow_7_9 + flow_8_9 <= 0
 edge_disable_constr_source_0: start_0 + 60 switch_source_0 <= 60
 edge_disable_constr_source_1: start_1 + 60 switch_source_1 <= 60
 edge_disable_constr_source_2: start_2 + 60 switch_source_2 <= 60
 edge_disable_constr_source_3: start_3 + 60 switch_source_3 <= 60
 edge_disable_constr_source_4: start_4 + 60 switch_source_4 <= 60
 edge_disable_constr_source_5: start_5 + 60 switch_source_5 <= 60
 edge_disable_constr_source_6: start_6 + 60 switch_source_6 <= 60
 edge_disable_constr_source_7: start_7 + 60 switch_source_7 <= 60
 edge_disable_constr_source_8: start_8 + 60 switch_source_8 <= 60
 edge_disable_constr_source_9: start_9 + 60 switch_source_9 <= 60
 edge_disable_constr_0_sink: - start_0 - hold_0_1 - 2 hold_0_2 - 3 hold_0_3
   - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7 + 60 switch_0_sink
   <= 0
 edge_disable_constr_1_sink: - start_1 - hold_1_1 - 2 hold_1_2 - 3 hold_1_3
   - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7 - 8 hold_1_8
   - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_sink <= 0
 edge_disable_constr_2_sink: - start_2 - hold_2_1 - 2 hold_2_2 - 3 hold_2_3
   - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7 + 60 switch_2_sink
   <= 0
 edge_disable_constr_3_sink: - start_3 - hold_3_1 - 2 hold_3_2 - 3 hold_3_3
   - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7 + 60 switch_3_sink
   <= 0
 edge_disable_constr_4_sink: - start_4 - hold_4_1 - 2 hold_4_2 - 3 hold_4_3
   - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7 - 8 hold_4_8
   - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_sink <= 0
 edge_disable_constr_5_sink: - start_5 - hold_5_1 - 2 hold_5_2 - 3 hold_5_3
   - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7 + 60 switch_5_sink
   <= 0
 edge_disable_constr_6_sink: - start_6 - hold_6_1 - 2 hold_6_2 - 3 hold_6_3
   - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7 + 60 switch_6_sink
   <= 0
 edge_disable_constr_7_sink: - start_7 - hold_7_1 - 2 hold_7_2 - 3 hold_7_3
   - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7 + 60 switch_7_sink
   <= 0
 edge_disable_constr_8_sink: - start_8 - hold_8_1 - 2 hold_8_2 - 3 hold_8_3
   - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7 - 8 hold_8_8
   - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_sink <= 0
 edge_disable_constr_9_sink: - start_9 - hold_9_1 - 2 hold_9_2 - 3 hold_9_3
   - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7 - 8 hold_9_8
   - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_sink <= 0
 edge_disable_constr1_0_1: start_0 - start_1 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_1 <= 60
 edge_disable_constr2_0_1: - start_0 + start_1 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_1 <= 60
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
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_0
   <= 60
 edge_disable_constr2_4_0: start_0 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_0
   <= 60
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
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_0
   <= 60
 edge_disable_constr2_8_0: start_0 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_0
   <= 60
 edge_disable_constr1_0_9: start_0 - start_9 + hold_0_1 + 2 hold_0_2
   + 3 hold_0_3 + 4 hold_0_4 + 5 hold_0_5 + 6 hold_0_6 + 7 hold_0_7
   + 60 switch_0_9 <= 60
 edge_disable_constr2_0_9: - start_0 + start_9 - hold_0_1 - 2 hold_0_2
   - 3 hold_0_3 - 4 hold_0_4 - 5 hold_0_5 - 6 hold_0_6 - 7 hold_0_7
   + 60 switch_0_9 <= 60
 edge_disable_constr1_9_0: - start_0 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_0
   <= 60
 edge_disable_constr2_9_0: start_0 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_0
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
   + 60 switch_2_1 <= 60
 edge_disable_constr2_2_1: start_1 - start_2 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_1 <= 60
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
   + 60 switch_3_1 <= 60
 edge_disable_constr2_3_1: start_1 - start_3 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_1 <= 60
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
   + 60 switch_5_1 <= 60
 edge_disable_constr2_5_1: start_1 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_1 <= 60
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
   + 60 switch_6_1 <= 60
 edge_disable_constr2_6_1: start_1 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_1 <= 60
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
   + 60 switch_7_1 <= 60
 edge_disable_constr2_7_1: start_1 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_1 <= 60
 edge_disable_constr1_1_8: start_1 - start_8 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_8
   <= 60
 edge_disable_constr2_1_8: - start_1 + start_8 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_8
   <= 60
 edge_disable_constr1_8_1: - start_1 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_1
   <= 60
 edge_disable_constr2_8_1: start_1 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_1
   <= 60
 edge_disable_constr1_1_9: start_1 - start_9 + hold_1_1 + 2 hold_1_2
   + 3 hold_1_3 + 4 hold_1_4 + 5 hold_1_5 + 6 hold_1_6 + 7 hold_1_7
   + 8 hold_1_8 + 9 hold_1_9 + 10 hold_1_10 + 11 hold_1_11 + 60 switch_1_9
   <= 60
 edge_disable_constr2_1_9: - start_1 + start_9 - hold_1_1 - 2 hold_1_2
   - 3 hold_1_3 - 4 hold_1_4 - 5 hold_1_5 - 6 hold_1_6 - 7 hold_1_7
   - 8 hold_1_8 - 9 hold_1_9 - 10 hold_1_10 - 11 hold_1_11 + 60 switch_1_9
   <= 60
 edge_disable_constr1_9_1: - start_1 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_1
   <= 60
 edge_disable_constr2_9_1: start_1 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_1
   <= 60
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
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_2
   <= 60
 edge_disable_constr2_4_2: start_2 - start_4 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_2
   <= 60
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
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_2
   <= 60
 edge_disable_constr2_8_2: start_2 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_2
   <= 60
 edge_disable_constr1_2_9: start_2 - start_9 + hold_2_1 + 2 hold_2_2
   + 3 hold_2_3 + 4 hold_2_4 + 5 hold_2_5 + 6 hold_2_6 + 7 hold_2_7
   + 60 switch_2_9 <= 60
 edge_disable_constr2_2_9: - start_2 + start_9 - hold_2_1 - 2 hold_2_2
   - 3 hold_2_3 - 4 hold_2_4 - 5 hold_2_5 - 6 hold_2_6 - 7 hold_2_7
   + 60 switch_2_9 <= 60
 edge_disable_constr1_9_2: - start_2 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_2
   <= 60
 edge_disable_constr2_9_2: start_2 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_2
   <= 60
 edge_disable_constr1_3_4: start_3 - start_4 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_4 <= 60
 edge_disable_constr2_3_4: - start_3 + start_4 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_4 <= 60
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
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_3
   <= 60
 edge_disable_constr2_8_3: start_3 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_3
   <= 60
 edge_disable_constr1_3_9: start_3 - start_9 + hold_3_1 + 2 hold_3_2
   + 3 hold_3_3 + 4 hold_3_4 + 5 hold_3_5 + 6 hold_3_6 + 7 hold_3_7
   + 60 switch_3_9 <= 60
 edge_disable_constr2_3_9: - start_3 + start_9 - hold_3_1 - 2 hold_3_2
   - 3 hold_3_3 - 4 hold_3_4 - 5 hold_3_5 - 6 hold_3_6 - 7 hold_3_7
   + 60 switch_3_9 <= 60
 edge_disable_constr1_9_3: - start_3 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_3
   <= 60
 edge_disable_constr2_9_3: start_3 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_3
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
   + 60 switch_5_4 <= 60
 edge_disable_constr2_5_4: start_4 - start_5 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_4 <= 60
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
   + 60 switch_6_4 <= 60
 edge_disable_constr2_6_4: start_4 - start_6 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_4 <= 60
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
   + 60 switch_7_4 <= 60
 edge_disable_constr2_7_4: start_4 - start_7 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_4 <= 60
 edge_disable_constr1_4_8: start_4 - start_8 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_8
   <= 60
 edge_disable_constr2_4_8: - start_4 + start_8 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_8
   <= 60
 edge_disable_constr1_8_4: - start_4 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_4
   <= 60
 edge_disable_constr2_8_4: start_4 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_4
   <= 60
 edge_disable_constr1_4_9: start_4 - start_9 + hold_4_1 + 2 hold_4_2
   + 3 hold_4_3 + 4 hold_4_4 + 5 hold_4_5 + 6 hold_4_6 + 7 hold_4_7
   + 8 hold_4_8 + 9 hold_4_9 + 10 hold_4_10 + 11 hold_4_11 + 60 switch_4_9
   <= 60
 edge_disable_constr2_4_9: - start_4 + start_9 - hold_4_1 - 2 hold_4_2
   - 3 hold_4_3 - 4 hold_4_4 - 5 hold_4_5 - 6 hold_4_6 - 7 hold_4_7
   - 8 hold_4_8 - 9 hold_4_9 - 10 hold_4_10 - 11 hold_4_11 + 60 switch_4_9
   <= 60
 edge_disable_constr1_9_4: - start_4 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_4
   <= 60
 edge_disable_constr2_9_4: start_4 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_4
   <= 60
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
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_5
   <= 60
 edge_disable_constr2_8_5: start_5 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_5
   <= 60
 edge_disable_constr1_5_9: start_5 - start_9 + hold_5_1 + 2 hold_5_2
   + 3 hold_5_3 + 4 hold_5_4 + 5 hold_5_5 + 6 hold_5_6 + 7 hold_5_7
   + 60 switch_5_9 <= 60
 edge_disable_constr2_5_9: - start_5 + start_9 - hold_5_1 - 2 hold_5_2
   - 3 hold_5_3 - 4 hold_5_4 - 5 hold_5_5 - 6 hold_5_6 - 7 hold_5_7
   + 60 switch_5_9 <= 60
 edge_disable_constr1_9_5: - start_5 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_5
   <= 60
 edge_disable_constr2_9_5: start_5 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_5
   <= 60
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
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_6
   <= 60
 edge_disable_constr2_8_6: start_6 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_6
   <= 60
 edge_disable_constr1_6_9: start_6 - start_9 + hold_6_1 + 2 hold_6_2
   + 3 hold_6_3 + 4 hold_6_4 + 5 hold_6_5 + 6 hold_6_6 + 7 hold_6_7
   + 60 switch_6_9 <= 60
 edge_disable_constr2_6_9: - start_6 + start_9 - hold_6_1 - 2 hold_6_2
   - 3 hold_6_3 - 4 hold_6_4 - 5 hold_6_5 - 6 hold_6_6 - 7 hold_6_7
   + 60 switch_6_9 <= 60
 edge_disable_constr1_9_6: - start_6 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_6
   <= 60
 edge_disable_constr2_9_6: start_6 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_6
   <= 60
 edge_disable_constr1_7_8: start_7 - start_8 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_8 <= 60
 edge_disable_constr2_7_8: - start_7 + start_8 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_8 <= 60
 edge_disable_constr1_8_7: - start_7 + start_8 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_7
   <= 60
 edge_disable_constr2_8_7: start_7 - start_8 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_7
   <= 60
 edge_disable_constr1_7_9: start_7 - start_9 + hold_7_1 + 2 hold_7_2
   + 3 hold_7_3 + 4 hold_7_4 + 5 hold_7_5 + 6 hold_7_6 + 7 hold_7_7
   + 60 switch_7_9 <= 60
 edge_disable_constr2_7_9: - start_7 + start_9 - hold_7_1 - 2 hold_7_2
   - 3 hold_7_3 - 4 hold_7_4 - 5 hold_7_5 - 6 hold_7_6 - 7 hold_7_7
   + 60 switch_7_9 <= 60
 edge_disable_constr1_9_7: - start_7 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_7
   <= 60
 edge_disable_constr2_9_7: start_7 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_7
   <= 60
 edge_disable_constr1_8_9: start_8 - start_9 + hold_8_1 + 2 hold_8_2
   + 3 hold_8_3 + 4 hold_8_4 + 5 hold_8_5 + 6 hold_8_6 + 7 hold_8_7
   + 8 hold_8_8 + 9 hold_8_9 + 10 hold_8_10 + 11 hold_8_11 + 60 switch_8_9
   <= 60
 edge_disable_constr2_8_9: - start_8 + start_9 - hold_8_1 - 2 hold_8_2
   - 3 hold_8_3 - 4 hold_8_4 - 5 hold_8_5 - 6 hold_8_6 - 7 hold_8_7
   - 8 hold_8_8 - 9 hold_8_9 - 10 hold_8_10 - 11 hold_8_11 + 60 switch_8_9
   <= 60
 edge_disable_constr1_9_8: - start_8 + start_9 + hold_9_1 + 2 hold_9_2
   + 3 hold_9_3 + 4 hold_9_4 + 5 hold_9_5 + 6 hold_9_6 + 7 hold_9_7
   + 8 hold_9_8 + 9 hold_9_9 + 10 hold_9_10 + 11 hold_9_11 + 60 switch_9_8
   <= 60
 edge_disable_constr2_9_8: start_8 - start_9 - hold_9_1 - 2 hold_9_2
   - 3 hold_9_3 - 4 hold_9_4 - 5 hold_9_5 - 6 hold_9_6 - 7 hold_9_7
   - 8 hold_9_8 - 9 hold_9_9 - 10 hold_9_10 - 11 hold_9_11 + 60 switch_9_8
   <= 60
 edge_flow_constr_source_0: flow_source_0 - 5e+08 switch_source_0 <= 0
 edge_flow_constr_source_1: flow_source_1 - 5e+08 switch_source_1 <= 0
 edge_flow_constr_source_2: flow_source_2 - 5e+08 switch_source_2 <= 0
 edge_flow_constr_source_3: flow_source_3 - 5e+08 switch_source_3 <= 0
 edge_flow_constr_source_4: flow_source_4 - 5e+08 switch_source_4 <= 0
 edge_flow_constr_source_5: flow_source_5 - 5e+08 switch_source_5 <= 0
 edge_flow_constr_source_6: flow_source_6 - 5e+08 switch_source_6 <= 0
 edge_flow_constr_source_7: flow_source_7 - 5e+08 switch_source_7 <= 0
 edge_flow_constr_source_8: flow_source_8 - 5e+08 switch_source_8 <= 0
 edge_flow_constr_source_9: flow_source_9 - 5e+08 switch_source_9 <= 0
 edge_flow_constr_0_sink: flow_0_sink - 5e+08 switch_0_sink <= 0
 edge_flow_constr_1_sink: flow_1_sink - 5e+08 switch_1_sink <= 0
 edge_flow_constr_2_sink: flow_2_sink - 5e+08 switch_2_sink <= 0
 edge_flow_constr_3_sink: flow_3_sink - 5e+08 switch_3_sink <= 0
 edge_flow_constr_4_sink: flow_4_sink - 5e+08 switch_4_sink <= 0
 edge_flow_constr_5_sink: flow_5_sink - 5e+08 switch_5_sink <= 0
 edge_flow_constr_6_sink: flow_6_sink - 5e+08 switch_6_sink <= 0
 edge_flow_constr_7_sink: flow_7_sink - 5e+08 switch_7_sink <= 0
 edge_flow_constr_8_sink: flow_8_sink - 5e+08 switch_8_sink <= 0
 edge_flow_constr_9_sink: flow_9_sink - 5e+08 switch_9_sink <= 0
 edge_flow_constr_0_1: flow_0_1 - 75120.19230769231 switch_0_1 <= 0
 edge_flow_constr_1_0: flow_1_0 - 75120.19230769231 switch_1_0 <= 0
 edge_flow_constr_0_2: flow_0_2 - 75120.19230769231 switch_0_2 <= 0
 edge_flow_constr_2_0: flow_2_0 - 75120.19230769231 switch_2_0 <= 0
 edge_flow_constr_0_3: flow_0_3 - 75120.19230769231 switch_0_3 <= 0
 edge_flow_constr_3_0: flow_3_0 - 75120.19230769231 switch_3_0 <= 0
 edge_flow_constr_0_4: flow_0_4 - 75120.19230769231 switch_0_4 <= 0
 edge_flow_constr_4_0: flow_4_0 - 75120.19230769231 switch_4_0 <= 0
 edge_flow_constr_0_5: flow_0_5 - 75120.19230769231 switch_0_5 <= 0
 edge_flow_constr_5_0: flow_5_0 - 75120.19230769231 switch_5_0 <= 0
 edge_flow_constr_0_6: flow_0_6 - 75120.19230769231 switch_0_6 <= 0
 edge_flow_constr_6_0: flow_6_0 - 75120.19230769231 switch_6_0 <= 0
 edge_flow_constr_0_7: flow_0_7 - 75120.19230769231 switch_0_7 <= 0
 edge_flow_constr_7_0: flow_7_0 - 75120.19230769231 switch_7_0 <= 0
 edge_flow_constr_0_8: flow_0_8 - 75120.19230769231 switch_0_8 <= 0
 edge_flow_constr_8_0: flow_8_0 - 75120.19230769231 switch_8_0 <= 0
 edge_flow_constr_0_9: flow_0_9 - 75120.19230769231 switch_0_9 <= 0
 edge_flow_constr_9_0: flow_9_0 - 75120.19230769231 switch_9_0 <= 0
 edge_flow_constr_1_2: flow_1_2 - 75120.19230769231 switch_1_2 <= 0
 edge_flow_constr_2_1: flow_2_1 - 75120.19230769231 switch_2_1 <= 0
 edge_flow_constr_1_3: flow_1_3 - 75120.19230769231 switch_1_3 <= 0
 edge_flow_constr_3_1: flow_3_1 - 75120.19230769231 switch_3_1 <= 0
 edge_flow_constr_1_4: flow_1_4 - 75120.19230769231 switch_1_4 <= 0
 edge_flow_constr_4_1: flow_4_1 - 75120.19230769231 switch_4_1 <= 0
 edge_flow_constr_1_5: flow_1_5 - 75120.19230769231 switch_1_5 <= 0
 edge_flow_constr_5_1: flow_5_1 - 75120.19230769231 switch_5_1 <= 0
 edge_flow_constr_1_6: flow_1_6 - 75120.19230769231 switch_1_6 <= 0
 edge_flow_constr_6_1: flow_6_1 - 75120.19230769231 switch_6_1 <= 0
 edge_flow_constr_1_7: flow_1_7 - 75120.19230769231 switch_1_7 <= 0
 edge_flow_constr_7_1: flow_7_1 - 75120.19230769231 switch_7_1 <= 0
 edge_flow_constr_1_8: flow_1_8 - 75120.19230769231 switch_1_8 <= 0
 edge_flow_constr_8_1: flow_8_1 - 75120.19230769231 switch_8_1 <= 0
 edge_flow_constr_1_9: flow_1_9 - 75120.19230769231 switch_1_9 <= 0
 edge_flow_constr_9_1: flow_9_1 - 75120.19230769231 switch_9_1 <= 0
 edge_flow_constr_2_3: flow_2_3 - 75120.19230769231 switch_2_3 <= 0
 edge_flow_constr_3_2: flow_3_2 - 75120.19230769231 switch_3_2 <= 0
 edge_flow_constr_2_4: flow_2_4 - 75120.19230769231 switch_2_4 <= 0
 edge_flow_constr_4_2: flow_4_2 - 75120.19230769231 switch_4_2 <= 0
 edge_flow_constr_2_5: flow_2_5 - 75120.19230769231 switch_2_5 <= 0
 edge_flow_constr_5_2: flow_5_2 - 75120.19230769231 switch_5_2 <= 0
 edge_flow_constr_2_6: flow_2_6 - 75120.19230769231 switch_2_6 <= 0
 edge_flow_constr_6_2: flow_6_2 - 75120.19230769231 switch_6_2 <= 0
 edge_flow_constr_2_7: flow_2_7 - 75120.19230769231 switch_2_7 <= 0
 edge_flow_constr_7_2: flow_7_2 - 75120.19230769231 switch_7_2 <= 0
 edge_flow_constr_2_8: flow_2_8 - 75120.19230769231 switch_2_8 <= 0
 edge_flow_constr_8_2: flow_8_2 - 75120.19230769231 switch_8_2 <= 0
 edge_flow_constr_2_9: flow_2_9 - 75120.19230769231 switch_2_9 <= 0
 edge_flow_constr_9_2: flow_9_2 - 75120.19230769231 switch_9_2 <= 0
 edge_flow_constr_3_4: flow_3_4 - 75120.19230769231 switch_3_4 <= 0
 edge_flow_constr_4_3: flow_4_3 - 75120.19230769231 switch_4_3 <= 0
 edge_flow_constr_3_5: flow_3_5 - 75120.19230769231 switch_3_5 <= 0
 edge_flow_constr_5_3: flow_5_3 - 75120.19230769231 switch_5_3 <= 0
 edge_flow_constr_3_6: flow_3_6 - 75120.19230769231 switch_3_6 <= 0
 edge_flow_constr_6_3: flow_6_3 - 75120.19230769231 switch_6_3 <= 0
 edge_flow_constr_3_7: flow_3_7 - 75120.19230769231 switch_3_7 <= 0
 edge_flow_constr_7_3: flow_7_3 - 75120.19230769231 switch_7_3 <= 0
 edge_flow_constr_3_8: flow_3_8 - 75120.19230769231 switch_3_8 <= 0
 edge_flow_constr_8_3: flow_8_3 - 75120.19230769231 switch_8_3 <= 0
 edge_flow_constr_3_9: flow_3_9 - 75120.19230769231 switch_3_9 <= 0
 edge_flow_constr_9_3: flow_9_3 - 75120.19230769231 switch_9_3 <= 0
 edge_flow_constr_4_5: flow_4_5 - 75120.19230769231 switch_4_5 <= 0
 edge_flow_constr_5_4: flow_5_4 - 75120.19230769231 switch_5_4 <= 0
 edge_flow_constr_4_6: flow_4_6 - 75120.19230769231 switch_4_6 <= 0
 edge_flow_constr_6_4: flow_6_4 - 75120.19230769231 switch_6_4 <= 0
 edge_flow_constr_4_7: flow_4_7 - 75120.19230769231 switch_4_7 <= 0
 edge_flow_constr_7_4: flow_7_4 - 75120.19230769231 switch_7_4 <= 0
 edge_flow_constr_4_8: flow_4_8 - 75120.19230769231 switch_4_8 <= 0
 edge_flow_constr_8_4: flow_8_4 - 75120.19230769231 switch_8_4 <= 0
 edge_flow_constr_4_9: flow_4_9 - 75120.19230769231 switch_4_9 <= 0
 edge_flow_constr_9_4: flow_9_4 - 75120.19230769231 switch_9_4 <= 0
 edge_flow_constr_5_6: flow_5_6 - 75120.19230769231 switch_5_6 <= 0
 edge_flow_constr_6_5: flow_6_5 - 75120.19230769231 switch_6_5 <= 0
 edge_flow_constr_5_7: flow_5_7 - 75120.19230769231 switch_5_7 <= 0
 edge_flow_constr_7_5: flow_7_5 - 75120.19230769231 switch_7_5 <= 0
 edge_flow_constr_5_8: flow_5_8 - 75120.19230769231 switch_5_8 <= 0
 edge_flow_constr_8_5: flow_8_5 - 75120.19230769231 switch_8_5 <= 0
 edge_flow_constr_5_9: flow_5_9 - 75120.19230769231 switch_5_9 <= 0
 edge_flow_constr_9_5: flow_9_5 - 75120.19230769231 switch_9_5 <= 0
 edge_flow_constr_6_7: flow_6_7 - 75120.19230769231 switch_6_7 <= 0
 edge_flow_constr_7_6: flow_7_6 - 75120.19230769231 switch_7_6 <= 0
 edge_flow_constr_6_8: flow_6_8 - 75120.19230769231 switch_6_8 <= 0
 edge_flow_constr_8_6: flow_8_6 - 75120.19230769231 switch_8_6 <= 0
 edge_flow_constr_6_9: flow_6_9 - 75120.19230769231 switch_6_9 <= 0
 edge_flow_constr_9_6: flow_9_6 - 75120.19230769231 switch_9_6 <= 0
 edge_flow_constr_7_8: flow_7_8 - 75120.19230769231 switch_7_8 <= 0
 edge_flow_constr_8_7: flow_8_7 - 75120.19230769231 switch_8_7 <= 0
 edge_flow_constr_7_9: flow_7_9 - 75120.19230769231 switch_7_9 <= 0
 edge_flow_constr_9_7: flow_9_7 - 75120.19230769231 switch_9_7 <= 0
 edge_flow_constr_8_9: flow_8_9 - 75120.19230769231 switch_8_9 <= 0
 edge_flow_constr_9_8: flow_9_8 - 75120.19230769231 switch_9_8 <= 0
Bounds
Binaries
 hold_0_1 hold_0_2 hold_0_3 hold_0_4 hold_0_5 hold_0_6 hold_0_7 hold_1_1
 hold_1_2 hold_1_3 hold_1_4 hold_1_5 hold_1_6 hold_1_7 hold_1_8 hold_1_9
 hold_1_10 hold_1_11 hold_2_1 hold_2_2 hold_2_3 hold_2_4 hold_2_5 hold_2_6
 hold_2_7 hold_3_1 hold_3_2 hold_3_3 hold_3_4 hold_3_5 hold_3_6 hold_3_7
 hold_4_1 hold_4_2 hold_4_3 hold_4_4 hold_4_5 hold_4_6 hold_4_7 hold_4_8
 hold_4_9 hold_4_10 hold_4_11 hold_5_1 hold_5_2 hold_5_3 hold_5_4 hold_5_5
 hold_5_6 hold_5_7 hold_6_1 hold_6_2 hold_6_3 hold_6_4 hold_6_5 hold_6_6
 hold_6_7 hold_7_1 hold_7_2 hold_7_3 hold_7_4 hold_7_5 hold_7_6 hold_7_7
 hold_8_1 hold_8_2 hold_8_3 hold_8_4 hold_8_5 hold_8_6 hold_8_7 hold_8_8
 hold_8_9 hold_8_10 hold_8_11 hold_9_1 hold_9_2 hold_9_3 hold_9_4 hold_9_5
 hold_9_6 hold_9_7 hold_9_8 hold_9_9 hold_9_10 hold_9_11 switch_source_0
 switch_source_1 switch_source_2 switch_source_3 switch_source_4
 switch_source_5 switch_source_6 switch_source_7 switch_source_8
 switch_source_9 switch_0_sink switch_1_sink switch_2_sink switch_3_sink
 switch_4_sink switch_5_sink switch_6_sink switch_7_sink switch_8_sink
 switch_9_sink switch_0_1 switch_1_0 switch_0_2 switch_2_0 switch_0_3
 switch_3_0 switch_0_4 switch_4_0 switch_0_5 switch_5_0 switch_0_6
 switch_6_0 switch_0_7 switch_7_0 switch_0_8 switch_8_0 switch_0_9
 switch_9_0 switch_1_2 switch_2_1 switch_1_3 switch_3_1 switch_1_4
 switch_4_1 switch_1_5 switch_5_1 switch_1_6 switch_6_1 switch_1_7
 switch_7_1 switch_1_8 switch_8_1 switch_1_9 switch_9_1 switch_2_3
 switch_3_2 switch_2_4 switch_4_2 switch_2_5 switch_5_2 switch_2_6
 switch_6_2 switch_2_7 switch_7_2 switch_2_8 switch_8_2 switch_2_9
 switch_9_2 switch_3_4 switch_4_3 switch_3_5 switch_5_3 switch_3_6
 switch_6_3 switch_3_7 switch_7_3 switch_3_8 switch_8_3 switch_3_9
 switch_9_3 switch_4_5 switch_5_4 switch_4_6 switch_6_4 switch_4_7
 switch_7_4 switch_4_8 switch_8_4 switch_4_9 switch_9_4 switch_5_6
 switch_6_5 switch_5_7 switch_7_5 switch_5_8 switch_8_5 switch_5_9
 switch_9_5 switch_6_7 switch_7_6 switch_6_8 switch_8_6 switch_6_9
 switch_9_6 switch_7_8 switch_8_7 switch_7_9 switch_9_7 switch_8_9
 switch_9_8
Generals
 start_0 start_1 start_2 start_3 start_4 start_5 start_6 start_7 start_8
 start_9
End
