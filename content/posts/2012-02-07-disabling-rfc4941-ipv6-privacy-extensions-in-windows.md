---
title: Disabling RFC 4941 IPv6 Privacy Extensions in Windows
author: Ben
tags: [ipv6, networking, windows, sysadmin]
---
[RFC 4941](http://www.ietf.org/rfc/rfc4941.txt) defines a series of Privacy Extensions for Stateless Address Autoconfiguration in IPv6. Typically, hosts using IPv6 SLAAC configure an address using the network prefix advertised by the router in combination with the [EUI-64]() IEEE interface identifier (MAC address) of the physical interface. Because addresses generated using SLAAC contain an embedded interface identifier, which remains constant over time, it becomes possible to correlate seemingly unrelated activity using this identifier. RFC 4941 aims to address this by using short-lived, randomly generated identifiers to form addresses instead.

Normally, when using privacy extensions it's typical to maintain the EUI-64 derived address on an interface for inbound connections while using RFC 4941 temporary addresses when establishing outbound connections. This offers a balance between privacy and the convenience of static addressing and is the default when using RFC 4941 on Linux or OS X.

By default, Windows Vista, Windows 7 and Windows Server 2008 generate random interface IDs for non-temporary autoconfigured IPv6 addresses, including public and link-local addresses, rather than using EUI-64 derived interface IDs.[^1] While these are permanent, so don't change, this leads to potential confusion when a host's expected EUI-64 derived address is unreachable!

Thankfully it's trivial to disable this behaviour, fire up cmd.exe and issue the following.

<pre>
netsh interface ipv6 set global randomizeidentifiers=disabled store=active
netsh interface ipv6 set global randomizeidentifiers=disabled store=persistent
</pre>

In addition to this, the RFC states that the use of temporary addresses should be disabled by default.

> The use of temporary addresses may cause unexpected difficulties with
> some applications. [snip]
> Consequently, the use of temporary addresses SHOULD be disabled by
> default in order to minimize potential disruptions.  Individual
> applications, which have specific knowledge about the normal duration
> of connections, MAY override this as appropriate.

Windows Vista and Windows 7 ignore the advice of the RFC and also configure temporary global or unique local addresses as per RFC 4941 (OS X also does this since 10.7). This behaviour is disabled by default on Windows Server 2008.

To disable privacy extensions entirely, fire up cmd.exe and issue the following.

<pre>
netsh interface ipv6 set privacy state=disabled store=active
netsh interface ipv6 set privacy state=disabled store=persistent
</pre>

The changes will take immediate effect without needing to reboot, they'll also persist after a reboot.

*[SLAAC]: Stateless Address Autoconfiguration

[^1]: [The Cable Guy: IPv6 Autoconfiguration in Windows Vista](http://technet.microsoft.com/en-us/magazine/2007.08.cableguy.aspx)