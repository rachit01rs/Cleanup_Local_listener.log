--The monitoring logs and warning logs for Oracle 11g are all in the/opt/oracle/app/diag/tnslsnr/machine name/listener directory
--Where the warning log is in the alert directory, the listening log is under the trace directory. The log files generated under the Listener directory are larger and are the main objects of cleanup. In the Listener directory, the listening log is a file named Listener.log, and the warning log log.xml, the log every 11M or so will be divided into a log_xxxx.xml log, gradually accumulate.

--Is there no need to truncate the listening log files for maintenance? The answer is in the negative. Of course, the Listening log files (Listener.log) are cleaned regularly, and if you do not clean up regularly, you will encounter some of the following problems:

--1. The Listening log file (Listener.log) is getting bigger and larger, taking up additional storage space. (Of course, now store the price of cabbage, not bad for that few grams of space.) But we still have to be in the spirit of craftsmen, excellence.

--2. Listening log file (Listener.log) has become too general to bring some problems: the LISTENER.LOG log size cannot exceed 2GB, exceeding causes the listener listener to be unable to process the new connection.

--3, the Listening log file (Listener.log) becomes too large, to write, see some performance problems, trouble.

--First, a single instance:
--$ find $ORACLE _base-name Listener.log
--/opt/oracle/app/diag/tnslsnr/testdb/listener/trace/listener.log


[oracle@myserver ~]$ lsnrctl
/*
LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 07-APR-2023 10:46:57

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Welcome to LSNRCTL, type "help" for information.
*/
LSNRCTL> show
/*
The following operations are available after show
An asterisk (*) denotes a modifier or extended command:

rawmode                              displaymode
rules                                trc_file
trc_directory                        trc_level
log_file                             log_directory
log_status                           current_listener
inbound_connect_timeout              startup_waittime
snmp_visible                         save_config_on_stop
dynamic_registration                 enable_global_dynamic_endpoint
oracle_home                          pid
connection_rate_limit                valid_node_checking_registration
registration_invited_nodes           registration_excluded_nodes
remote_registration_address
*/

LSNRCTL> show log_file
/*
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=myserver.com.np)(PORT=1521)))
LISTENER parameter "log_file" set to /u01/app/oracle/diag/tnslsnr/myserver/listener/alert/log.xml
The command completed successfully
*/

LSNRCTL> show log_status
/*
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=myserver.com.np)(PORT=1521)))
LISTENER parameter "log_status" set to ON

*/
LSNRCTL> show log_directory
/*
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=myserver.com.np)(PORT=1521)))
LISTENER parameter "log_directory" set to /u01/app/oracle/diag/tnslsnr/myserver/listener/alert
The command completed successfully

*/

LSNRCTL> exit

[oracle@myserver ~]$ du -sh /u01/app/oracle/diag/tnslsnr/myserver/listener/alert
/*
140K    /u01/app/oracle/diag/tnslsnr/myserver/listener/alert
*/
[oracle@myserver ~]$ du -sh /u01/app/oracle/diag/tnslsnr/myserver/listener/trace/
/*
56K     /u01/app/oracle/diag/tnslsnr/myserver/listener/trace/
*/


--Monitoring is currently in a normal state, the log function is also open, and then a thought, the original log file size is full

Processing:

1: Stop the log first

LSNRCTL> set log_status off
/*
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=myserver.com.np)(PORT=1521)))
LISTENER parameter "log_status" set to OFF
The command completed successfully

*/

LSNRCTL> exit

2, to the directory cd /u01/app/oracle/diag/tnslsnr/myserver/listener/trace/
 mv listener.log listener.log.bkp

3. Open log



LSNRCTL> set log_status on
/*
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=myserver.com.np)(PORT=1521)))
LISTENER parameter "log_status" set to ON
The command completed successfully

*/


. Reload the Listener



LSNRCTL> reload
/*
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=myserver.com.np)(PORT=1521)))
The command completed successfully
*/

LSNRCTL> exit
LSNRCTL> show log_status
/* 
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=myserver.com.np)(PORT=1521)))
LISTENER parameter "log_status" set to ON
The command completed successfully
*/
5. Regenerate new log in directory, compress save
[oracle@myserver trace]$ tar czvf listener.log.bkp.gz listener.log.bkp
/*
listener.log.bkp
*/

[oracle@myserver trace]$ ls -lrt
/*
-rw-r-----. 1 oracle oinstall 29076 Apr  7 10:51 listener.log.bkp
-rw-r-----. 1 oracle oinstall  1166 Apr  7 10:59 listener.log
-rw-r--r--. 1 oracle oinstall  4087 Apr  7 11:01 listener.log.bkp.gz
*/

6, delete the original log:
rm -rf listener.log.bkp





Third, by using crontab to regularly clean:
Using a timer to clean up the listening log file is actually similar to the above, with the following script:



$listener_log.sh
#!/bin/bash

date_name='date +'%d%m''

cd /u01/app/oracle/diag/tnslsnr/myserver/listener/trace
lsnrctl set log_status off
mv listener.log /tmp/listener.log.$data_name
lsnrctl set log_status on
lsnrctl reload


Make crontab tasks:
0 1 * * * /home/oracle/listener_log.sh &gt; /home/oracle/listener_log.log 2&gt;&1

Execution time and retention policy can be self-made, through the crontab can get rid of manual operation, through the system to perform maintenance operations automatically.

ORACLE11G Listener log Listener.log file too much processing
