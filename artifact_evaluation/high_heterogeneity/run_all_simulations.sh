echo "Running simulation for helix llama70b offline"
python step3_simulation.py helix offline
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for swarm llama70b offline"
python step3_simulation.py swarm offline
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for separate pipelines llama70b offline"
python step3_simulation.py separate offline
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for separate pipelines PLUS llama70b offline"
python step3_simulation.py sp_plus offline
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for helix llama70b online"
python step3_simulation.py helix online
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for swarm llama70b online"
python step3_simulation.py swarm online
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for separate pipelines llama70b online"
python step3_simulation.py separate online
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for separate pipelines PLUS llama70b online"
python step3_simulation.py sp_plus online
echo "--------------------------------------------------------------------"
echo " "
sleep 5