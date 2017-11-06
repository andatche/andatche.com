---
title: Fixing SSL CA certificates with OpenSSL from MacPorts
author: Ben
tags: [os x, sysadmin, ssl]
---

If you've installed OpenSSL from [MacPorts](http://www.macports.org/) (or anything that depends on it), you've probably come across issues with verifying SSL certificates in applications built against it.

<pre>ben@spud:~$ lftp acc-xxxxx@ftp.library.gb1.brightbox.com
Fatal error: SSL_connect: unable to get local issuer certificate</pre>

<pre>
ben@spud:~$ openssl s_client -connect ftp.library.gb1.brightbox.com:21 -starttls ftp -CApath /opt/local/etc/openssl/
CONNECTED(00000003)
depth=2 C = US, O = GeoTrust Inc., CN = GeoTrust Global CA
verify error:num=20:unable to get local issuer certificate
verify return:0
</pre>

That's because MacPorts doesn't provide a CA root certificate bundle package (such as the ``ca-certificates`` Ubuntu package) and in its default configuration the ``openssl`` package can't talk to the OS X keychain, where the system CA certificates are kept.

Helpfully, the [cURL](http://curl.haxx.se/) project provides it's own CA cert bundle we can use, generated from the [mozilla root certificates](http://mxr.mozilla.org/mozilla/source/security/nss/lib/ckfw/builtins/certdata.txt?raw=1), which is available in macports.

Simply install ``curl-ca-bundle``

<pre>
sudo port install curl-ca-bundle
</pre>

Then symlink the bundle into ``/opt/local/etc/openssl``, the default CApath for MacPorts-installed OpenSSL.

<pre>
sudo ln -s /opt/local/share/curl/curl-ca-bundle.crt /opt/local/etc/openssl/cert.pem
</pre>

**EDIT:** The above step is no longer necessary. MacPorts' ``curl-ca-bundle @7.24.0`` now creates the symlink during installation.

Voilà, working CA cert verification!

<pre>ben@spud:~$ openssl s_client -connect ftp.library.gb1.brightbox.com:21 -starttls ftp -CApath /opt/local/etc/openssl/
CONNECTED(00000003)
depth=3 C = US, O = Equifax, OU = Equifax Secure Certificate Authority
verify return:1
depth=2 C = US, O = GeoTrust Inc., CN = GeoTrust Global CA
verify return:1
depth=1 C = US, O = "GeoTrust, Inc.", CN = RapidSSL CA
verify return:1
depth=0 serialNumber = FIUwKm3apULSSy7J9sGT8i0NxIprVlhV, C = GB, O = ftp.library.gb1.brightbox.com, OU = GT02477604, OU = See www.rapidssl.com/resources/cps (c)11, OU = Domain Control Validated - RapidSSL(R), CN = ftp.library.gb1.brightbox.com
verify return:1</pre>
