#*************************************************#
#   ______            _            _____ _____    #
#   | ___ \          | |          |  _  /  ___|   #
#   | |_/ /___  _   _| |_ ___ _ __| | | \ `--.    #
#   |    // _ \| | | | __/ _ \ '__| | | |`--. \   #
#   | |\ \ (_) | |_| | ||  __/ |  \ \_/ /\__/ /   #
#   \_| \_\___/ \__,_|\__\___|_|   \___/\____/    #
#                                                 #
#*************************************************#

{%- if users %}

# ********** Users **********
# Create users
{%- for user in users %}
/user add name="{{ user.name }}" password="{{ user.password }}" groups="{{ user.groups }}"
{%- endfor %}

# Remove admin
/user remove name="admin"
{%- endif %}

# ********** PPPoE **********
# Remove entry
/interface pppoe-client remove [/interface pppoe-client find name="{{ PPPoE.name }}"]
# Add PPPoE client
/interface pppoe-client add name="{{ PPPoE.name }}" user="{{ PPPoE.user }}" password="{{ PPPoE.password }}" interface="{{ PPPoE.interface | default("ether1", true) }}" disabled=no add-default-route=yes
/interface list member set [/interface list member find list="WAN"] interface="{{ PPPoE.name }}"

# ********** SERVICES **********
{%- for service in disableServices %}
/ip service disable [/ip service find name="{{ service }}"]
{%- endfor %}

# ********** STATIC DEVICES **********
{%- for device in staticDevices %}
# {{ device.name }}
/ip dhcp-server lease make-static [/ip dhcp-server lease find mac-address="{{ device.macAddress }}"]
/ip dhcp-server lease set [/ip dhcp-server lease find mac-address="{{ device.macAddress }}"] address={{ device.ipAddress }} comment="{{ device.name }}"
{%- endfor %}

# ********** DNS **********
# ----- STATIC DNS ENTRIES -----
# Remove all entries
/ip dns static remove [/ip dns static find]

# Local entries
{%- for site in DNS.local %}
/ip dns static add address={{ site.address }} {% if site.includeSubdomains and site.includeSubdomains == true %}match-subdomain=yes {% endif -%} name="{{ site.name }}" comment="Local Entries" allow-remote-requests=yes # TODO: connect the param allow-remote-requests with use VPN local dns param
{%- endfor %}

# Blocked websites
{%- for site in DNS.blockedSites %}
/ip dns static add address=127.0.0.1 match-subdomain=yes name="{{ site }}" comment="Blocked websites"
{%- endfor %}

# ----- DNS DoH CONFIGURATION -----
# Configure DNS entry
/ip dns set servers={{ DNS.server }}

# Flush cache DNS to reset all
/ip dns cache flush

# ********** FIREWALL **********
# ----- ADDRESS LIST -----
# Remove all entries
/ip firewall address-list remove [/ip firewall address-list find list="Cloudflare IPs"]
/ipv6 firewall address-list remove [/ipv6 firewall address-list find list="Cloudflare IPs"]
{%- for rule in firewall.NATRules %}
/ip firewall nat remove [/ip firewall nat find comment="{{ rule.comment }}"]
{%- endfor %}

# IPv4 Address Lists
{%- for list in firewall.addressLists.IP %}
{%- for address in list.addressList %}
/ip firewall address-list add list="{{ list.name }}" address="{{ address }}"
{%- endfor %}
{%- endfor %}

# IPv6 Address Lists
{%- for list in firewall.addressLists.IPv6 %}
{%- for address in list.addressList %}
/ipv6 firewall address-list add list="{{ list.name }}" address="{{ address }}"
{%- endfor %}
{%- endfor %}

# ----- FIREWALL RULES -----
{%- for rule in firewall.NATRules %}
/ip firewall nat add comment="{{ rule.comment }}" chain=dstnat action=dst-nat to-addresses={{ rule.address }} to-ports={{ rule.port }} protocol=tcp {%- if rule.srcAddressList and rule.srcAddressList != "" %} src-address-list="{{ rule.srcAddressList }}"{% endif %} in-interface-list=WAN dst-port={{ rule.port }} log=no
{%- endfor %}

{% if VPN and VPN.wireguard -%}
# ********** WIREGUARD **********
# Remove all entries
/interface wireguard peers remove [/interface wireguard peers find]
/ip firewall filter remove [/ip firewall filter find in-interface="{{ VPN.wireguard.name | default("wireguard", true) }}"]
/ip firewall filter remove [/ip firewall filter find dst-port="{{ VPN.wireguard.port }}"]
/ip address remove [/ip address find interface="{{ VPN.wireguard.name | default("wireguard", true) }}"]
/interface wireguard remove [/interface wireguard find name="{{ VPN.wireguard.name | default("wireguard", true) }}"]

# Configure Wireguard server
/interface wireguard add listen-port={{ VPN.wireguard.port }} mtu={{ VPN.wireguard.mtu }} name="{{ VPN.wireguard.name | default("wireguard", true) }}"
/ip address add address={{ VPN.wireguard.network }}1/24 interface="{{ VPN.wireguard.name | default("wireguard", true) }}" network={{ VPN.wireguard.network }}0
/ip firewall filter add action=accept chain=input dst-port={{ VPN.wireguard.port }} protocol=udp comment="WireGuard" place-before=1
/ip firewall filter add action=accept chain=forward in-interface={{ VPN.wireguard.name | default("wireguard", true) }} comment="WireGuard forward" place-before=1
/ip firewall filter add action=accept chain=input in-interface={{ VPN.wireguard.name | default("wireguard", true) }} protocol=udp dst-port=53 comment="DNS depuis WireGuard UDP" place-before=1
/ip firewall filter add action=accept chain=input in-interface={{ VPN.wireguard.name | default("wireguard", true) }} protocol=tcp dst-port=53 comment="DNS depuis WireGuard TCP" place-before=1

# Peers
{%- for peer in VPN.wireguard.peers %}
/interface wireguard peers add allowed-address={{ VPN.wireguard.network }}{{ loop.index + 1 }}/32 interface="{{ VPN.wireguard.name | default("wireguard", true) }}" name="{{ peer }}" private-key="auto" client-listen-port={{ VPN.wireguard.port }} client-endpoint={{ VPN.wireguard.endpoint }} client-address={{ VPN.wireguard.network }}{{ loop.index + 1 }} client-dns=192.168.88.1
{%- endfor %}
{%- endif %}
