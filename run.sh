#!/usr/bin/env bash
echo "Starting tunnel..."
cd ngrok
tmux new-session -d -s tunnel  './ngrok tcp 25565'

cd ..

echo "Starting server..."
cd server
tmux new-session -d -s server 'java -Xmx8162M -Xms8162M -jar server.jar nogui'

cd ..

echo "Updating ip in dns..."

tcpaddress=$(curl --silent --show-error localhost:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p')
echo $tcpaddress

tcpsplit=(${tcpaddress//:/ })

address=${tcpsplit[0]}"."  

port=${tcpsplit[1]}  

payload=$(jq -n \
                  --arg port "$port" \
                  --arg data "$address" \
                  --arg type "SRV")

#curl \
#    -H "Authorization: Bearer TOKEN" \
#    -H "Accept: application/json" \
#    https://dynv6.com/api/v2/zones

curl \
    -H "Authorization: Bearer TOKEN" \
    -H "Content-Type: application/json" \
    -X PATCH https://dynv6.com/api/v2/zones/ID/records/ID\
    -d "${payload}"