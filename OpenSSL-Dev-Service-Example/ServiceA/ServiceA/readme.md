## POC of SSL Implicit trust between services with a trusted intermediate
----
- To generate certificates follow instructions in https://riskfirst.visualstudio.com/Developers/_git/OpenSSL-Dev-CA

- To enable host name translation, add:

	```
	127.0.0.1           dev.test.local prod.test.local
	```
   to file:

	```
	C:\Windows\System32\drivers\etc\hosts
	```

