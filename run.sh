#!/usr/bin/env bash
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
#parse_yaml config.yml

eval $(parse_yaml config.yml)

echo "Starting tunnel..."
if $tunnel_serveo
then
	echo "	Using serveo..."
	tmux new-session -d -s tunnel  "ssh -o ServerAliveInterval=60 -R ${tunnel_serveo_port}:localhost:25565 serveo.net"
	tcpaddress=${tunnel_serveo_hostname}:${tunnel_serveo_port}
	echo "	tcpaddress: ${tcpaddress}"
fi

if $tunnel_connect
then
	echo "	Using connect plugin..."
	tcpaddress=${tunnel_connect_endpoint}.${tunnel_connect_hostname}:${server_port}
	echo "	tcpaddress: ${tcpaddress}"

	mkdir -p server/plugins/connect
	> server/plugins/connect/config.yml cat <<< "endpoint: ${tunnel_connect_endpoint}"
	if [ "${tunnel_connect_token}" != "<TOKEN>" ]
	then
		echo "		Using existing token with endpoint ${tunnel_connect_endpoint}"
		> server/plugins/connect/token.json cat <<< "{\"token\":\"${tunnel_connect_token}\"}"
	fi
fi

echo "Starting server..."
cd server
tmux new-session -d -s server "tmux set-option mouse on && java -Xmx${server_memory} -Xms${server_memory} -jar server.jar nogui"
cd ..

echo "Updating ip in dns..."

tcpsplit=(${tcpaddress//:/ })
address=${tcpsplit[0]}"."  
port=${tcpsplit[1]}  

#curl \
#    -H "Authorization: Bearer TOKEN" \
#    -H "Accept: application/json" \
#    https://dynv6.com/api/v2/zones
if $dns_dynv6
then
	echo "	Using dynv6..."
	echo "		updating dns..."
	
	payload=$(jq -n --argjson port $port --arg data "$address" --arg type "SRV" '{port:$port,data:$data,type:$type}')
	echo $payload
	
	zoneid_apirequest="https://dynv6.com/api/v2/zones/by-name/${dns_dynv6_zones}"
	echo "Getting zone_id from $zoneid_apirequest"
	zone_id=$(curl --silent --show-error -H "Authorization: Bearer $dns_dynv6_token" -H "Accept: application/json" $zoneid_apirequest | sed -nE 's/.*id":([^,]*).*/\1/p')
	echo "Receive zone_id: $zone_id for zone:$dns_dynv6_zones"

	#curl \
	#   -H "Authorization: Bearer $dns_dynv6_token" \
	#   -H "Accept: application/json" \
	#   $zoneid_apirequest
	
	recordsid_apirequest="https://dynv6.com/api/v2/zones/${zone_id}/records"
	echo "Getting records_id from $recordsid_apirequest"
	records_id=$(curl --silent --show-error -H "Authorization: Bearer $dns_dynv6_token" -H "Accept: application/json" $recordsid_apirequest | sed -nE 's/.*id":([^,]*).*/\1/p')
	echo "Receive records_id: $records_id for SRV record on zone:$dns_dynv6_zones"
	   
	#curl \
	#   -H "Authorization: Bearer $dns_dynv6_token" \
	#   -H "Accept: application/json" \
	#   $recordsid_apirequest
	
	patchrecord_apirequest="https://dynv6.com/api/v2/zones/${zone_id}/records/${records_id}"
	echo "Updating current SRV records to with port:$port and hostname:$address"
	curl \
		-H "Authorization: Bearer $dns_dynv6_token" \
		-H "Content-Type: application/json" \
		-X PATCH "${patchrecord_apirequest}" \
		-d "${payload}"
fi

