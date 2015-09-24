# doco-downloader
I wrote this powershell script, inspired by xtravirt's document downloader (http://xtravirt.com/product-information/document-downloader-for-vmware) , to grab a copy of VMware Technical documentation (from "https://www.vmware.com/support/pubs/) and make them available offline. You may choose to specifiy one or more URL. The script scan a target URL(s) for HTML links, then follows those links to grab specific files of your chosen types (examples: PDF, EPUB, MOBI). There is no reason why it cannot be adapted to other sites. It does not currently enable you to authenticate to the site. I am working on it.

Ce script powershell, permet the telecharger des documents techniques du site VMware (https://www.vmware.com/support/pubs/) pour les avoirs offline. Inspirer par ce script http://xtravirt.com/product-information/document-downloader-for-vmware, j'ai essayer de le simplifier et ecrire en powershell.

Examples:
.\VMware vSphere Replication Documentation\<everything for this topic>.pdf
.\VMware Virtual SAN Documentation\<everything for this topic>.pdf
.\vSphere Update Manager Documentation\<everything for this topic>.pdf
.\VMware ESX Server 2.x Documentation\<everything for this topic>.pdf
...


Bref, je vais continuer a le modifier et l'adapter a d'autre site comme Nutanix et Veeam car cet sites demande s'authentifier 
