# Generate Root CA and Intermediates

## Goal:
Set up a basic Server-Client authentication using mutual trusted intermediates

### Sample SSL Heierarchy Tree:
```
trusted CA    |                 Root
              |              /       \
Intermediates |         Dev            Prod
              |      /      \        /      \  
Certificates  |  Client  Server  Client  Server

```
Where Dev and Prod are environments with services that should not be able to communicate between them.

## Script files:
* `run-all.sh`
    * Sets environments and host name
    * Runs all shell scripts in project
* `mkdir.sh`
    * Creates the necessary folders needed by other scripts
* `clean.sh`
    * Deletes certificates, databases, signing requests, keys, and constructed config files
* `generate-root-ca.sh`
    * Creates root ca config from variables set in `run-all.sh`
    * Generates a key
    * Creates a signing request
    * Generates a root certificate
* `generate-intermediate-ca.sh`
    * For each environment, generates an intermediate certificate so that all certificates under it are trusted but certificates under the other environment intermediates aren't
* `generate-server-certs.sh`
    * Generates singing requests for servers in the specified environent and signs them with the corresponding intermediate
    * These will be used to authenticate the server and prove the client is in the chain of trust
* `generate-client-certs.sh`
    * Generates singing requests for clients in the specified environent and signs them with the corresponding intermediate
    * This proves the client is in the same chain as the server and thus can be trusted


## Instructions:

* Ensure you have bash or [Ubuntu for Windows](https://www.microsoft.com/en-us/store/p/ubuntu/9nblggh4msv6) installed
* Install [Nginx for windows](https://nginx.org/en/download.html) or (my preferred method)
    *  in ubuntu `sudo apt-get install nginx` then comment out default nginx config includes from `/etc/nginx/nginx.conf` and add in reference to our new nginx config
        ```
        #include /etc/nginx/conf.d/*.conf;
        #include /etc/nginx/sites-enabled/*;
        include /mnt/c/WorkSpaces/OpenSSL-Dev-CA/nginx/nginx.conf;
        ``` 
    * /mnt/c/Workspaces will be different on your machine
* run `run-all.sh`
* Installed root ca as trusted root
* Install client certificates to personal store
* Edit hosts file to translate appropriate host names to appropriate urls
    * e.g. in Windows add:

	    ```
	    127.0.0.1           dev.test.local prod.test.local
	    ```
        to file:

	    ```
	    C:\Windows\System32\drivers\etc\hosts
	    ```
* Navigate to the appropriate url e.g. `https:dev.test.local`
* Select the appropriate client certificate e.g. `dev.client`
* See webpage
* * Navigate to the appropriate url e.g. `https:prod.test.local`
* Select the appropriate client certificate e.g. `prod.client`

## Next Steps
    Use the Sample Microservice project to set up a ASPNETCORE microservice authenticated using mutual intermediate trust to provide basic auth

OR 

    Use Nginx to proxy access to microservices using config as used in the previous example

OR

    Configure IIS to handle Client Authorisation