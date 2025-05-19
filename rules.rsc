# ********** PPPoE **********


# ********** DNS **********
# ----- STATIC DNS ENTRIES -----
# Remove all entries
/ip dns static remove [/ip dns static find]

# Local entries
/ip dns static add address=192.168.88.1 name=router.lan comment="Local Entries"
/ip dns static add address=192.168.88.175 name=daisi.lan comment="Local Entries"

# DNS DoH - CloudFlare
/ip dns static add address=1.1.1.1 name=one.one.one.one comment="DNS DoH"

# Blocked websites
/ip dns static add address=127.0.0.1 match-subdomain=yes name=cokain.fr comment="Blocked websites"
/ip dns static add address=127.0.0.1 match-subdomain=yes name=gamaniak.com comment="Blocked websites"
/ip dns static add address=127.0.0.1 match-subdomain=yes name=tiktok.com comment="Blocked websites"
/ip dns static add address=127.0.0.1 match-subdomain=yes name=webchoc.com comment="Blocked websites"

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
/ip firewall address-list remove [/ip firewall address-list find]

# Cloudflare IPv4
/ip firewall address-list add list="Cloudflare IPs" address=173.245.48.0/20
/ip firewall address-list add list="Cloudflare IPs" address=103.21.244.0/22
/ip firewall address-list add list="Cloudflare IPs" address=103.22.200.0/22
/ip firewall address-list add list="Cloudflare IPs" address=103.31.4.0/22
/ip firewall address-list add list="Cloudflare IPs" address=141.101.64.0/18
/ip firewall address-list add list="Cloudflare IPs" address=108.162.192.0/18
/ip firewall address-list add list="Cloudflare IPs" address=190.93.240.0/20
/ip firewall address-list add list="Cloudflare IPs" address=188.114.96.0/20
/ip firewall address-list add list="Cloudflare IPs" address=197.234.240.0/22
/ip firewall address-list add list="Cloudflare IPs" address=198.41.128.0/17
/ip firewall address-list add list="Cloudflare IPs" address=162.158.0.0/15
/ip firewall address-list add list="Cloudflare IPs" address=104.16.0.0/13
/ip firewall address-list add list="Cloudflare IPs" address=104.24.0.0/14
/ip firewall address-list add list="Cloudflare IPs" address=172.64.0.0/13
/ip firewall address-list add list="Cloudflare IPs" address=131.0.72.0/22

# Cloudflare IPv6
/ipv6 firewall address-list add list="Cloudflare IPs" address=2400:cb00::/32
/ipv6 firewall address-list add list="Cloudflare IPs" address=2606:4700::/32
/ipv6 firewall address-list add list="Cloudflare IPs" address=2803:f800::/32
/ipv6 firewall address-list add list="Cloudflare IPs" address=2405:b500::/32
/ipv6 firewall address-list add list="Cloudflare IPs" address=2405:8100::/32
/ipv6 firewall address-list add list="Cloudflare IPs" address=2a06:98c0::/29
/ipv6 firewall address-list add list="Cloudflare IPs" address=2c0f:f248::/32

# ----- FIREWALL RULES -----


# ********** WIREGUARD **********
