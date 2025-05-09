# ********** DNS **********
# ----- STATIC DNS ENTRIES -----
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
