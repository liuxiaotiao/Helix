echo "Running simulation for helix"
python setup2_distributed.py helix
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for swarm"
python setup2_distributed.py swarm
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for random"
python setup2_distributed.py random
echo "--------------------------------------------------------------------"
echo " "
sleep 5

echo "Running simulation for shortest_queue"
python setup2_distributed.py shortest_queue
echo "--------------------------------------------------------------------"
echo " "
sleep 5