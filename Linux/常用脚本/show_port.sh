echo "Please select:"
echo "1: show all ports"
echo "2: show specified port"
read select
if [ 1 -eq $select ] ;then
	netstat -tunpl	
	exit 0;
fi
echo "whitch port?"
read port
netstat -tunpl |grep $port
