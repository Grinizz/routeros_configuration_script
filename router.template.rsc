# ********** PPPoE **********
# Remove entry
/interface pppoe-client remove [/interface pppoe-client find name="{{ PPPoE.name }}"]
# Add PPPoE client
/interface pppoe-client add name="{{ PPPoE.name }}" user="{{ PPPoE.user }}" password="{{ PPPoE.password }}" interface={% if PPPoE.interface and PPPoE.interface != "" %}"PPPoE.interface"{% else %}"ether1"{% endif %} disabled=no add-default-route=yes
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
/ip dns static add address={{ site.address }} {% if site.includeSubdomains and site.includeSubdomains == true %}match-subdomain=yes {% endif -%} name="{{ site.name }}" comment="Local Entries"
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

# ********** WIREGUARD **********
#/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
#/ip address add address=192.168.98.1/24 interface=wireguard1 network=192.168.98.0
#/ip firewall filter add action=accept chain=input dst-port=13231 protocol=udp
#/interface wireguard peers add allowed-address=192.168.98.2/32 interface=wireguard1 public-key="<KEY>"

#/ip firewall filter
#add chain=input protocol=udp dst-port=51820 action=accept place-before=0
#add chain=forward in-interface=wireguard1 action=accept place-before=1
