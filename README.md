# RouterOS configuration script
Little script to configure Mikrotik router with CloudFlare IPs. This script fetch the CloudFlare IPs.

## Requirements
- Bash
- Jinja2-cli
- jq

## How to execute
First step, copy `data.template.json` file, rename it to `data.json` and fill it with your credentials and needs.  
Next step, run command `bash generate.sh`. It will generate a new file `router.rsc`.  
Finally, put the file content in `System / Scripts` menu in RouterOS and run it.
