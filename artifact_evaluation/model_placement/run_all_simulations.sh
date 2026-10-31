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

echo "Running simulation for petals"
python setup2_distributed.py petals
echo "--------------------------------------------------------------------"
echo " "
sleep 5