#!/bin/bash
# add 2018-06-25 by Pascal Withopf, released under ASL 2.0
. ${srcdir:=.}/diag.sh init
generate_conf
add_conf '
module(load="../plugins/imudp/.libs/imudp")
input(type="imudp" port="'$TCPFLOOD_PORT'")

template(name="outfmt" type="string" string="%timestamp:::date-rfc3339%\n")

:syslogtag, contains, "su" action(type="omfile" file="'$RSYSLOG_OUT_LOG'"
				  template="outfmt")

'
startup
tcpflood -m1 -T "udp" -M "\"<34>1 2003-11-11T22:14:15.003Z mymachine.example.com su - ID47 - MSG\""
tcpflood -m1 -T "udp" -M "\"<34>1 2003-01-11T22:14:15.003Z mymachine.example.com su - ID47 - MSG\""
tcpflood -m1 -T "udp" -M "\"<34>1 2003-11-01T22:04:15.003Z mymachine.example.com su - ID47 - MSG\""
tcpflood -m1 -T "udp" -M "\"<34>1 2003-11-11T02:14:15.003Z mymachine.example.com su - ID47 - MSG\""
tcpflood -m1 -T "udp" -M "\"<34>1 2003-11-11T22:04:05.003Z mymachine.example.com su - ID47 - MSG\""
tcpflood -m1 -T "udp" -M "\"<34>1 2003-11-11T22:04:05.003+02:00 mymachine.example.com su - ID47 - MSG\""
tcpflood -m1 -T "udp" -M "\"<34>1 2003-11-11T22:04:05.003+01:30 mymachine.example.com su - ID47 - MSG\""
tcpflood -m1 -T "udp" -M "\"<34>1 2003-11-11T22:04:05.123456+01:30 mymachine.example.com su - ID47 - MSG\""
wait_file_exists $RSYSLOG_OUT_LOG
shutdown_when_empty
wait_shutdown

export EXPECTED='2003-11-11T22:14:15.003Z
2003-01-11T22:14:15.003Z
2003-11-01T22:04:15.003Z
2003-11-11T02:14:15.003Z
2003-11-11T22:04:05.003Z
2003-11-11T22:04:05.003+02:00
2003-11-11T22:04:05.003+01:30
2003-11-11T22:04:05.123456+01:30'
cmp_exact

exit_test
