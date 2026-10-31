echo "Parsing real system evaluation results for helix llama30b offline:"
echo "Showing each sub-cluster separately"
echo "!![A100 sub-cluster]!!"
python step7_parse_results.py helix_a100 llama30b offline
echo "!![L4 sub-cluster]!!"
python step7_parse_results.py helix_l4 llama30b offline
echo "!![T4 sub-cluster]!!"
python step7_parse_results.py helix_t4 llama30b offline
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for helix llama30b online:"
echo "Showing each sub-cluster separately"
echo "!![A100 sub-cluster]!!"
python step7_parse_results.py helix_a100 llama30b online
echo "!![L4 sub-cluster]!!"
python step7_parse_results.py helix_l4 llama30b online
echo "!![T4 sub-cluster]!!"
python step7_parse_results.py helix_t4 llama30b online
echo "!![Summary of latency]!!"
python step7_parse_results.py helix llama30b online
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for swarm llama30b offline:"
python step7_parse_results.py swarm llama30b offline
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for swarm llama30b online:"
python step7_parse_results.py swarm llama30b online
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for separate pipelines llama30b offline:"
echo "Showing each sub-cluster separately"
echo "!![A100 sub-cluster]!!"
python step7_parse_results.py separate_a100 llama30b offline
echo "!![L4 sub-cluster]!!"
python step7_parse_results.py separate_l4 llama30b offline
echo "!![T4 sub-cluster]!!"
python step7_parse_results.py separate_t4 llama30b offline
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for separate pipelines llama30b online:"
echo "Showing each sub-cluster separately"
echo "!![A100 sub-cluster]!!"
python step7_parse_results.py separate_a100 llama30b online
echo "!![L4 sub-cluster]!!"
python step7_parse_results.py separate_l4 llama30b online
echo "!![T4 sub-cluster]!!"
python step7_parse_results.py separate_t4 llama30b online
echo "!![Summary of latency]!!"
python step7_parse_results.py separate llama30b online
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for helix llama70b offline:"
python step7_parse_results.py helix llama70b offline
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for helix llama70b online:"
python step7_parse_results.py helix llama70b online
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for swarm llama70b offline:"
python step7_parse_results.py swarm llama70b offline
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for swarm llama70b online:"
python step7_parse_results.py swarm llama70b online
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for separate pipelines llama70b offline:"
echo "Showing each sub-cluster separately"
echo "!![A100 sub-cluster]!!"
python step7_parse_results.py separate_a100 llama70b offline
echo "!![L4 sub-cluster]!!"
python step7_parse_results.py separate_l4 llama70b offline
echo "!![T4 sub-cluster]!!"
python step7_parse_results.py separate_t4 llama70b offline
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for separate pipelines llama70b online:"
echo "Showing each sub-cluster separately"
echo "!![A100 sub-cluster]!!"
python step7_parse_results.py separate_a100 llama70b online
echo "!![L4 sub-cluster]!!"
python step7_parse_results.py separate_l4 llama70b online
echo "!![T4 sub-cluster]!!"
python step7_parse_results.py separate_t4 llama70b online
echo "!![Summary of latency]!!"
python step7_parse_results.py separate llama70b online
echo "--------------------------------------------------------------------"
