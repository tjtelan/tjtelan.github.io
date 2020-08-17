+++
title = "Deploy Postfix Gmail relay with Ansible on Raspberry Pi"
date = 2018-11-27
draft = false
description = "A walkthrough for configuring a Raspberry Pi Postfix relay from VCenter Server Appliance to gmail"
[taxonomies]
tags = ["ansible", "postfix", "raspberry pi", "vmware"]
categories = ["how-to", "devops"]
+++
## Why would we want to do this?
The virtualization servers at work are running VMWare ESXi, with Vcenter Server Applicance (VCSA) as our bridge to using cool, free tools like Packer, and Terraform to automate my interactions with virtual resources.

A downside we discovered is VCSA's lack of support for SMTP that requires auth, which Google requires when you send mail through them.

Postfix can handle the anonymous request from VCSA, and send it out to gmail with provided creds.

## How do I get started?
Since we wanted to get an email whenever there as an issue with the virtualization servers, it made sense to hostthis service on its own hardware.

I am going to be hosting this service using a Raspberry Pi 3 model B running Raspbian Stretch, and configuring it from my host using Ansible. This detail is not critical for following this guide. Any Debian-derived OS (like Ubuntu) that Ansible supports will work for hosting.

You just need to make sure SSH is turned on, and that you have the IP address. (The default username/pass on RasPis is `pi`/`raspberry`)

At minimum, you need the following tools installed on your host:
* Python 3
* Ansible 2.7

Download this helpful role for installing Postfix. At the time of this writing, it was the best public Postfix Ansible role, because its documentation had examples of how to configure the deployment as a gmail relay. Very straight forward.

[https://github.com/Oefenweb/ansible-postfix](https://github.com/Oefenweb/ansible-postfix)

If you install this role in your Ansible client's `role_path`,  then you can use the example playbook I slightly modified, (and annotated) from the ansible-postfix README.

### Example ansible playbook
```yaml
---
name: Setup basic raspberry pi host as SMTP relay (Rasbian)
hosts:
    mailproxy
vars:
    postfix_mynetworks:
        # This is the IPv4 localhost loopback subnet
        - '127.0.0.0/8'             
        # This is the IPv4 mapped IPv6 localhost loopback subnet
        - '[::ffff:127.0.0.0]/104'  
        # This is the IPv6 localhost loopback address
        - '[::1]/128'               
        # This is the local private network subnet, like the IPv4 address space from your home router
        # This addition allows other hosts on the network to send mail through this relay!
        - '192.168.0.0/24'          
    postfix_smtpd_relay_restrictions:
        #  This says to permit requests if the client is in the $mynetworks whitelist
        #  http://www.postfix.org/postconf.5.html#permit_mynetworks
        - permit_mynetworks
        #  This says relay the request if client is authenticated to the smtp server
        #  http://www.postfix.org/postconf.5.html#permit_sasl_authenticated
        - permit_sasl_authenticated
        #  This says to reject the request unless it knows about the destination (the domain)
        #  http://www.postfix.org/postconf.5.html#reject_unauth_destination
        - reject_unauth_destination

        ## Lastly, I believe the order of these restrictions matter, so this last one must catch the rest of the garbage requests

    postfix_relayhost: smtp.gmail.com
    postfix_smtp_tls_cafile: /etc/ssl/certs/ca-certificates.crt
    postfix_relaytls: true
    postfix_sasl_user: 'username@gmail.com'
    postfix_sasl_password: 'apppasswordgeneratedgarbage'
roles:
    ansible-postfix
```

#### Some additional notes
* To configure vCenter, I followed this guide. It might be helpful to note that I only found these instructions to work with the Flash-based client, not the HTML5-based client. But it would be really great if the settings could be configured over the command line with VMWare's vSphere CLI tool, [govc](https://github.com/vmware/govmomi/tree/master/govc)
  * [VMWare Docs - Configure Mail Sender Settings - VSphere 6.5](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vcenterhost.doc/GUID-467DA288-7844-48F5-BB44-99DE6F6160A4.html)
* Without the `postfix_mynetworks` addition of my local network, I was unable to successfully see email alerts from VCSA being sent from Postfix
* This also differs from the Oefenweb/ansible-postfix example, in that I am not setting any `postfix_aliases`, since it was my experience that it didn't ever work. Email was always from whoever was configured as `postfix_sasl_user`

### Test the configuration
Here is how to send a test email, from the Raspberry Pi, using `mail`

```bash
pi@raspberrypi:~ $ echo "Hello world, it's ya boi, RaspberryPi" | mail -s "[SMTP proxy] Hello World" your.email@domain.com
```
