# Self Signed Certificates

> Generate self signed ssl certificates with your own root CA / intermediate certificate

This project provides some scripts to setup a root CA (and intermediate cert) to sign single domain or multi-domain (wildcard) certificates.

- `root_ca.sh` : creates root CA certificate
- `intermediate.sh` : creates intermediate certificate
- `site.sh` : creates single-domain certificate
- `star.sh` : creates multi-domain certificate
- `crl.sh` : updates the certificate revocation lists

## Table of Contents

<!-- !toc (minlevel=2 omit="Table of Contents") -->

* [Requires](#requires)
* [Howto](#howto)
  * [root CA](#root-ca)
  * [intermediate certificate](#intermediate-certificate)
  * [single domain](#single-domain)
  * [multi domain (wildcard)](#multi-domain-wildcard)
* [Folders](#folders)
* [Testing](#testing)
* [Security Considerations](#security-considerations)
* [Known Issues](#known-issues)
* [License](#license)

<!-- toc! -->

## Requires

- OpenSSL 1.0.2g   1 Mar 2016
- OpenSSL 1.1.1f  31 Mar 2020 (Last used)

## Howto

1. Download scripts as [zip file](https://github.com/commenthol/self-signed-certs/archive/refs/heads/master.zip) 
2. unzip master.zip

### root CA

1. Edit `[req_distinguished_name]` in `root_ca.sh` to match your needs. Check `man req` for information on fields.
2. Run `./root_ca.sh`

### intermediate certificate

If an intermediate certificate is desired:

1. `[req_distinguished_name]` in `root_ca.sh` to match your needs. Check `man req` for information on fields.
2. Run `./intermediate.sh`

In case that the intermediate certificate is not present then single sites or wildcard certs are signed with the root certificate.

### single domain

1. Edit `[req_distinguished_name]` in `site.sh` to match your needs. Check `man req` for information on fields.
2. Change domain in `site.ini`. You need to change `CN = <host>` as well as entry in `subjectAltName = DNS:<host>`
3. Run `./site.sh` <br>
   For a different domain run `./site.sh <domain>` <br>
     e.g. `./site.sh www.aa.aa`

### multi domain (wildcard)

1. Edit `[req_distinguished_name]` in `star.sh` to match your needs. Check `man req` for information on fields.
2. Change domain in `star.sh`. You need to change `CN = <host>` as well as entries in `[alt_names]` to match your sub-domains.
3. Run `./star.sh`
   For a different altnames run `./star.sh <stardomain> <domain>` <br>
     e.g. `./star.sh *.aa.aa aa.aa localhost`

## Folders

```sh
├── certs                   # the generated certificates
│   ├── intermediate.crt    # intermediate
│   ├── root_ca.crt         # root
│   ├── site.crt            # site certificate
│   ├── site.key            # site private key
│   ├── site.crt.key        # combined certificate & key e.g. for HaProxy
│   ├── site.pfx            # PKCS12
│   ├── site.pfx.pass       # Password for PKCS12
│   └── site.tgz            # all site certificate files compressed
├── crl
│   ├── intermediate.crl    # certifcate revocation list for intermediate cert
│   ├── intermediate.index.txt # intermediate revocation database
│   ├── root_ca.crl         # certificate revocation list for root crt
│   └── root_ca.index.txt   # root revocation database
├── csr                     # directory for signing requests
├── private                 # directory for all private files
│   ├── intermediate.ini    # config for intermediate CA
│   ├── intermediate.key    
│   ├── intermediate.pass
│   ├── root_ca.ini         # config for root CA
│   ├── root_ca.key
│   └── root_ca.pass
├── root_ca.sh              # the scripts to run the CA
├── intermediate.sh
├── site.sh
├── star.sh
└── crl.sh
```


## Testing

1. Import `root_ca.crt` in Browser and/or OS:
   - _Chrome_ : Type in Url "chrome://settings/certificates" > Tab:Authorities > Button:Import > Select `root_ca.crt` > Trust this cert for indent. websites
     Use "chrome://flags/#show-cert-link" to see certificate details from Url-Pane.
   - _Firefox_ : Type in Url "about:preferences#privacy" > Section:Certificates > Button:View Certificates > Tab:Authorities > Button:Import... > Select `root_ca.crt` > Trust this cert for indent. websites
   - _macOS_ : Double click on `root_ca.crt` > Keychain opens > Choose Keychain: **System** > Button:Add
     Select in Tab:Keychains **System** and double-click on `AA Certification` cert. Fold:Trust > Change:When using this certificate:**Always Trust**.
   - _Ubunutu_ :
     ```
     sudo cp root_ca.crt /usr/local/share/ca-certificates
     sudo update-ca-certificates
     ```

2. Add some entries in your `/etc/hosts` file. E.g.:
   ````
   127.0.0.1    aa.aa
   127.0.0.2    one.aa.aa
   127.0.0.3    two.test.aa
   ````

3. Get [`node`](https://nodejs.org).
4. Start HTTPS server with:
   1. `node test/https.js site` for single site
   2. Browse <https://aa.aa:8443>
   3. `node test/https.js star` for multi domain
   4. Browse <https://aa.aa:8443>
   5. Browse <https://one.aa.aa:8443>
   6. Browse <https://two.test.aa:8443>
   7. Browse <https://localhost:8443>


## Security Considerations

Make sure to never ever commit your root_ca key and password within your code.
Otherwise don't feel frightened if someone provides you with certificates from any domain, even those from the big five.

Read more about [Root Certs and MITM Attacks here](https://www.bleepingcomputer.com/news/security/sennheiser-headset-software-could-allow-man-in-the-middle-ssl-attacks/).


## Known Issues

On macOS, `openssl` does not seam to be compatible with Google Chrome or MS Edge Browsers. 
If you experience problems with these browser showing a page with:

>  This site can’t provide a secure connection  
> 
>  aa.aa.de doesn't adhere to security standards.  
>  ERR_SSL_SERVER_CERT_BAD_FORMAT  

it is recommended to use Linux to generate some accepted certificates:

```sh
# brew install colima docker
colima start 
# or with docker desktop
open /Application/Docker.app

sh docker/alpine.sh
# inside the container change to the `/work` directory. Then generate the cert(s) as describe above
cd /work
```

Then open Keychain Access app
```
open /System/Applications/Utilities/Keychain\ Access.app
```
Select Tab "System" and drag-n-drop the `root_ca.crt`  
Double-click on the "untrusted" Certificate, 
then set "Trust" to "Always Trust" and confirm with your password.



## License

- Unlicense https://unlicense.org
