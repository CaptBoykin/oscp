# oscp
Scripts and things that I have created when I was doing OSCP.  I tried to prevent spoilers and other informations pertaining to specific hosts.  

### 1518_auto_setup.sh
A script that automates the implementation of "MySQL 4.x/5.0 (Linux) - User-Defined Function (UDF) Dynamic Library (2)", in addition adds a root account to the underlying system and a bunch of other stuff.
https://www.exploit-db.com/exploits/1518

### waf_x-forwarded-for_cmd.sh
A script that facilitates WAF evasion using the "X-Forwarded-For" GET request parameter, while also supplying commands to an underlying API.
https://portswigger.net/bappstore/ae2611da3bbc4687953a1f4ba6a4e04c

### 9623_acs_cmd.sh
A script that facilitates exploiting "Advanced Comment System 1.0 - Multiple Remote File Inclusions" in a vulnerable web application. 
https://www.exploit-db.com/exploits/9623

### 39161_privesc.py
A modification of the "HttpFileServer 2.3.x Remote Command Execution" by  Avinash Kumar Thapa aka "-Acid", which simply lets the user specify where on the host a user defined script should be ran (instead of nc by default).  Edited so spoilers hopefully wouldn't be revealed.  The original script itself requires tweaking to work in the PWK labs anyways.
https://www.exploit-db.com/exploits/39161
