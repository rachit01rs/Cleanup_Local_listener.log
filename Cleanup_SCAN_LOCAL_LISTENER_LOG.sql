-Login with grid user on RAC environment.
 1. SCAN Listener Log
	1.1 First Terminal
Step 1 (To find the current status of SCAN Listener).
[oracle@RAC1 bin]$ cd /opt/app/11.2.0.3.0/grid/bin
[oracle@RAC1 bin]$ ./crsctl stat res -t
/*
------------------------------------------------------------------------
NAME                     TARGET  STATE        SERVER       STATE_DETAILS   
-------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr    1   ONLINE  ONLINE  rac2
                            
ora.LISTENER_SCAN2.lsnr	   1   ONLINE  ONLINE  rac1
                               
*/

-- Step 2 (To find the running SCAN Listener name)
[oracle@RAC1 bin]$ ps -ef | grep SCAN
/*
grid      5030     1  0 14:12 ?        00:00:00 /opt/app/11.2.0.3.0/grid/bin/tnslsnr LISTENER_SCAN2 -inherit
oracle    7515  7400  0 15:08 pts/1    00:00:00 grep SCAN

*/

[grid@RAC1 bin]$ ps -ef | grep tns
/*
root        36     2  0 09:50 ?        00:00:00 [netns]
grid      5009     1  0 09:52 ?        00:00:00 /opt/app/11.2.0.3.0/grid/bin/tnslsnr LISTENER -inherit
grid      5075     1  0 09:53 ?        00:00:00 /opt/app/11.2.0.3.0/grid/bin/tnslsnr LISTENER_SCAN1 -inherit
grid      6457  5700  0 10:42 pts/1    00:00:00 grep tns
*/


-- Step 3 (To find the Location and status of SCAN Listener)
[grid@RAC1 bin]$ lsnrctl status LISTENER_SCAN1
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 03-APR-2023 10:44:29

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN1
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                03-APR-2023 09:53:50
Uptime                    0 days 0 hr. 50 min. 39 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3.0/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/RAC1/listener_scan1/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.15)(PORT=1521)))
Services Summary...
Service "racdb" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully

*/

-- Step 4 To check listener status
[grid@RAC1 ~]$ lsnrctl

LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 31-MAR-2023 15:09:38

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Welcome to LSNRCTL, type "help" for information.

LSNRCTL> show current_listener
Current Listener is LISTENER
LSNRCTL> set current_listener LISTENER_SCAN2
Current Listener is LISTENER_SCAN2
LSNRCTL> show current_listener
Current Listener is LISTENER_SCAN2
LSNRCTL> set log_status off
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN2)))
LISTENER_SCAN2 parameter "log_status" set to OFF
The command completed successfully
LSNRCTL> show current_listener
Current Listener is LISTENER_SCAN2


--step 5 (Open the new terminal for this step)
[oracle@RAC1 alert]$ su grid
Password:
[grid@RAC1 alert]$ cd
[grid@RAC1 ~]$ cd /opt/app/oracle/diag/tnslsnr/RAC1/listener_scan2/alert/
[grid@RAC2 alert]$ ls -lrt | grep log
/*
-rw-r----- 1 grid oinstall 1219406 Apr  4 10:17 log.xml
*/
[grid@RAC1 alert]$ tar --remove-files -cvf LISTENER_SCAN2.xml.tar.gz log*.xml
log.xml
[grid@RAC1 alert]$ ls -ltr | grep log
[grid@RAC1 alert]$ ls
/*
LISTENER_SCAN2.xml.tar.gz
*/


[grid@RAC1 alert]$ cd ..
[grid@RAC1 listener_scan2]$ cd trace/
[grid@RAC1 trace]$ ls -ltr | grep listener_scan2
-rw-r----- 1 grid oinstall 477621 Mar 31 15:11 listener_scan2.log
[grid@RAC1 trace]$ gzip listener_scan2.log
[grid@RAC1 trace]$ touch listener_scan2.log && chmod -R 640 listener_scan2.log
[grid@RAC1 trace]$ ls -ltr
/*
-rw-r----- 1 grid oinstall 30956 Mar 31 15:11 listener_scan2.log.gz
-rw-r----- 1 grid oinstall     0 Mar 31 15:17 listener_scan2.log
*/
 --STEP 6 (Resume The Task From Terminal one)
 
LSNRCTL> set log_status on
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN2)))
LISTENER_SCAN2 parameter "log_status" set to ON
The command completed successfully
LSNRCTL> show current_listener
Current Listener is LISTENER_SCAN2
LSNRCTL> exit
-- STEP 7 (To verify the Location and status of SCAN Listener)
[grid@RAC1 ~]$ lsnrctl status LISTENER_SCAN2
/*
LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 31-MAR-2023 15:18:11

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN2)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER_SCAN2
Version                   TNSLSNR for Linux: Version 11.2.0.3.0 - Production
Start Date                31-MAR-2023 14:12:01
Uptime                    0 days 1 hr. 6 min. 10 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/app/11.2.0.3.0/grid/network/admin/listener.ora
Listener Log File         /opt/app/oracle/diag/tnslsnr/RAC1/listener_scan2/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER_SCAN2)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.120.16)(PORT=1521)))
Services Summary...
Service "racdb" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
Service "racdbXDB" has 2 instance(s).
  Instance "racdb1", status READY, has 1 handler(s) for this service...
  Instance "racdb2", status READY, has 1 handler(s) for this service...
The command completed successfully
*/

--STEP 8 (To verify the running SCAN Listener name)
[grid@RAC1 ~]$ 
[oracle@RAC1 ~]$  ps -ef | grep SCAN
/*
grid      5030     1  0 14:12 ?        00:00:00 /opt/app/11.2.0.3.0/grid/bin/tnslsnr LISTENER_SCAN2 -inherit
oracle    8285  8249  0 15:18 pts/1    00:00:00 grep SCAN
*/
-- Step 9 (To verify the running status of Listener on Nodes)
[oracle@RAC1 ~]$ srvctl status listener
/*
Listener LISTENER is enabled
Listener LISTENER is running on node(s): rac2,rac1
*/
-- Step 10 (To verify the current status of SCAN Listener)
[oracle@RAC1 ~]$ su root
Password:
[root@RAC1 oracle]# cd /opt/app/11.2.0.3.0/grid/bin/
[root@RAC1 bin]# ./crsctl stat res -t
/*
--------------------------------------------------------------------------------
NAME                    TARGET       STATE             SERVER      STATE_DETAILS
--------------------------------------------------------------------------------

ora.LISTENER_SCAN1.lsnr    1         ONLINE  ONLINE       rac2
ora.LISTENER_SCAN2.lsnr    1         ONLINE  ONLINE       rac1
*/

-- Step 11 (To remove the backup of relevant log files)
[root@RAC1 bin]# su grid

[grid@RAC1 ~]$ cd /opt/app/oracle/diag/tnslsnr/RAC1/listener_scan2/trace/
[grid@RAC1 trace]$ ll
/*
-rw-r----- 1 grid oinstall  1311 Mar 31 15:21 listener_scan2.log
-rw-r----- 1 grid oinstall 30956 Mar 31 15:11 listener_scan2.log.gz
*/
[grid@RAC1 trace]$ rm -rf listener_scan2.log.gz
[grid@RAC1 trace]$ cd ..
[grid@RAC1 listener_scan2]$ cd alert/
[grid@RAC1 alert]$ ls
LISTENER_SCAN2.xml.tar.gz  log.xml
[grid@RAC1 alert]$ rm -rf LISTENER_SCAN2.xml.tar.gz
[grid@RAC1 alert]$
