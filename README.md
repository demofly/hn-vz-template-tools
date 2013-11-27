hn-vz-template-tools
====================

# What is it?

A very small pack of script allows me to automate often updates of a clean Debian OpenVZ template from Proxmox VE container for my PVE HNs.

## `vz-template-targets.conf` content format:
```
one-more-hn1.my.domain:/var/lib/vz/template/cache/
one-more-hn2.my.domain:/my/path/to/VirtualImages/OpenVZ/
```

If you don't want to clone a generated tamplate, just leave `vz-template-targets.conf` empty.
