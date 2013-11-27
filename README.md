hn-vz-template-tools
====================

## What is it?

A very small pack of script allows me to automate often updates of a clean Debian OpenVZ template from Proxmox VE container for my PVE HNs.

`vz-template-targets.conf` content format:

If you don't want to clone a generated tamplate, just leave `vz-template-targets.conf` empty.

## How to start to use it?
### Select a CT with a clean actual Debian installation
Deploy a clean CT on you PVE HN (master) node. Let we suppose it has CT ID 100.

### Clone this tool:
```
git clone https://github.com/demofly/hn-vz-template-tools.git
```

### Setup vz-template-targets.conf:
```
one-more-hn1.my.domain:/var/lib/vz/template/cache/
one-more-hn2.my.domain:/my/path/to/VirtualImages/OpenVZ/
```

### Setup CT ID of the empty CT:
```
editor update-vz-template.sh
```
And assign a variable VEID a value 100

### Enjoy!

run from your home dir [root]:
```
hn-vz-template-tools/update-vz-template.sh
```