#!/bin/bash
CLOUDFLARE_URL_IPV4=https://www.cloudflare.com/ips-v4/#
CLOUDFLARE_URL_IPV6=https://www.cloudflare.com/ips-v6/#

# Fetch the CloudFlare IPs
IPV4_LIST=$(curl $CLOUDFLARE_URL_IPV4)
IPV6_LIST=$(curl $CLOUDFLARE_URL_IPV6)

# Modification of the data
IPV4_MODIFY="[\"$(echo $IPV4_LIST | sed 's/ /","/g')\"]"
IPV6_MODIFY="[\"$(echo $IPV6_LIST | sed 's/ /","/g')\"]"

# Modify the CloudFlare IPs in data.json
modifyFile=$(jq "(.firewall.addressLists.IP[] | select(.name == \"Cloudflare IPs\")).addressList=$IPV4_MODIFY" data.json)
echo $modifyFile | jq "(.firewall.addressLists.IPv6[] | select(.name == \"Cloudflare IPs\")).addressList=$IPV6_MODIFY" > newData.json
mv newData.json data.json

# Fill the template
cat data.json | jinja2 router.template.rsc -o router.rsc