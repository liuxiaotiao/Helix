echo "Parsing real system evaluation results for helix:"
python setup1_parse_results.py helix
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for swarm:"
python setup1_parse_results.py swarm
echo "--------------------------------------------------------------------"

echo "Parsing real system evaluation results for random:"
python setup1_parse_results.py random
echo "--------------------------------------------------------------------"