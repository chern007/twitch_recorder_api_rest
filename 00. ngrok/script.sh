#!/bin/bash

pwd

./ngrok authtoken XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
./ngrok http -host-header=rewrite localhost:8080 > /dev/null &

sleep 1

# public_ip=$(curl localhost:4040/api/tunnels)
# echo $public_ip

python3 sender.py

echo 'Fin del script!'