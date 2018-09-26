# DDNS on Cloudflare

**NOTE: THIS SOFTWARE IS NOT PART OF CLOUDFLARE. IT ONLY USES THE PUBLIC API PROVIDED BY CLOUDFLARE FOR UPDATING PUBLIC IP OF THE HOST**

## How it works?

1. Initialize the Cloudflare API module
2. Find Public IP.
3. Check new ip with previous ip
4. Continues if not matching. Otherwise wait for 60 second and goes to step 2.
3. Find Zone ID of the Zone given.
4. Find Record ID of "ddns.YOUR.DOMAIN" where YOUR.DOMAIN is the zone name.
5. If no matching records are found in this zone, it create the record and store its record id.
6. Updates this record and repeat step 2.

## Setup

**Dependancies:**
- Python 2.7
- Pip
- Git
- Python Packages:
	- Requests
    - CloudFlare v4 API

```
sudo su
cd /opt
git clone https://github.com/nikhiljohn10/ddns-on-cloudflare.git
cd ddns-on-cloudflare
./setup.sh
```

Visit [CloudFlare API](https://api.cloudflare.com/) for more details
