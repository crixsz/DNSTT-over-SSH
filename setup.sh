## Install necessary packages
apt install git -y 
apt install golang -y
apt install sed -y  

#installation
clear
echo "[DNSTT over SSH Setup]"
echo "" 
echo "Enter your nameserver ?"
echo ""
read nameserver

#allowtcpforwarding on SSH
sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config
systemctl restart ssh

#adding user 
useradd aku -M -s /bin/false
echo "aku:aku" | chpasswd
#install udpgw
echo "Installing UDPGW and service of udpgw.service"
   #!/bin/sh
   OS=`uname -m`;
   wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw" >> /dev/null
   if [ "$OS" == "x86_64" ]; then   
      wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64" >> /dev/null
   fi
   chmod +x /usr/bin/badvpn-udpgw
   # Echo the service file contents
   echo "
   [Unit]
   Description=UDPGW Service
   After=network.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300
   Restart=always

   [Install]
   WantedBy=multi-user.target" >> /etc/systemd/system/udpgw.service 
   systemctl daemon-reload
   systemctl enable udpgw.service
   systemctl restart udpgw.service
   sleep 2

#get git repo and build the golang
git clone https://github.com/Mygod/dnstt.git
cd dnstt
cd dnstt-server
go build

#generate pub key and privkey
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub

#generate service file for dnstt
   echo "
   [Unit]
   Description=DNSTT
   After=network.target

   [Service]
   Type=simple
   WorkingDirectory=/root/dnstt/dnstt-server
   ExecStart=/root/dnstt/dnstt-server/dnstt-server -udp :53 -privkey-file server.key $nameserver 127.0.0.1:22
   Restart=always

   [Install]
   WantedBy=multi-user.target" >> /etc/systemd/system/dnstt.service 

#restart the service and run it
systemctl enable dnstt
systemctl restart dnstt

#echo the public key and ns
clear
publickey=$(cat /root/dnstt/dnstt-server/server.pub)
echo "======================"
echo "Public Key = $publickey"
echo "Nameserver = $nameserver"
echo "======================"
echo "Login Credentials"
echo "Username:aku"
echo "Password:aku"


