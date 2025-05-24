# ********** PPPoE **********
# Remove entry
/interface pppoe-client remove [/interface pppoe-client find name="{{ PPPoE.name }}"]
# Add PPPoE client
/interface pppoe-client add name="{{ PPPoE.name }}" user="{{ PPPoE.user }}" password="{{ PPPoE.password }}" interface={% if PPPoE.interface and PPPoE.interface != "" %}"PPPoE.interface"{% else %}"ether1"{% endif %} disabled=no add-default-route=yes

# ********** SERVICES **********
{%- for service in disableServices %}
/ip service disable [/ip service find name="{{ service }}"]
{%- endfor %}

# ********** STATIC DEVICES **********
{%- for device in staticDevices %}
# {{ device.name }}
/ip dhcp-server lease set [/ip dhcp-server lease find mac-address="{{ device.macAddress }}"] address={{ device.ipAddress }} comment="{{ device.name }}"
/ip dhcp-server lease make-static [/ip dhcp-server lease find mac-address="{{ device.macAddress }}"]
{%- endfor %}

# ********** DNS **********
# ----- STATIC DNS ENTRIES -----
# Remove all entries
/ip dns static remove [/ip dns static find]

# Local entries
/ip dns static add address=192.168.88.1 name=router.lan comment="Local Entries"
{%- for site in DNS.local %}
/ip dns static add address={{ site.address }} name="{{ site.name }}" comment="Local Entries"
{%- endfor %}

# DNS DoH - CloudFlare
/ip dns static add address=1.1.1.1 name=one.one.one.one comment="DNS DoH"

# Blocked websites
{%- for site in DNS.blockedSites %}
/ip dns static add address=127.0.0.1 match-subdomain=yes name="{{ site }}" comment="Blocked websites"
{%- endfor %}

# ----- DNS DoH CONFIGURATION -----
# Add DNS certification
#/certificate import file-name=CertificateFileName

# Configure DNS entry
/ip dns set use-doh-server=https://one.one.one.one/dns-query verify-doh-cert=yes

# Flush cache DNS to reset all
/ip dns cache flush

# ********** FIREWALL **********
# ----- ADDRESS LIST -----
# Remove all entries
/ip firewall address-list remove [/ip firewall address-list find list="Cloudflare IPs"]
/ipv6 firewall address-list remove [/ip firewall address-list find list="Cloudflare IPs"]
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
/ip firewall nat add comment="{{ rule.comment }}" chain=dstnat action=dst-nat to-addresses={{ rule.address }} to-ports={{ rule.port }} protocol=tcp src-address-list="{{ rule.srcAddressList }}" in-interface-list=WAN dst-port={{ rule.port }} log=no
{%- endfor %}

# ********** WIREGUARD **********


# ********** FINALIZE CONFIGURATION **********
/system check-installation
