#! /bin/bash

echo "Downloading splunk zip file"
sudo wget https://pwc-splunkfiles.s3.ap-south-1.amazonaws.com/Linux+files/splunklinux.zip

echo "Move the file to /tmp"
sudo mv splunklinux.zip  /tmp

cd /tmp

echo "unzip the file"
sudo unzip /tmp/splunklinux.zip

cd /tmp/splunklinux

echo "Change the execute attribute of the script Splunk_Install_Linux_UF.sh"
sudo chmod +x /tmp/splunklinux/Splunk_Install_Linux_UF.sh

echo "perform the UF installation"

sudo sh /tmp/splunklinux/Splunk_Install_Linux_UF.sh -c cent -v 7.3.4 -s no

sudo -u splunker /opt/splunkforwarder/bin/splunk stop


echo "Delete the directory /opt/splunkforwarder/etc/apps/pwc_deployment_ta_cent"

sudo rm -r /opt/splunkforwarder/etc/apps/pwc_deployment_ta_cent


echo "Extract the directory pwc_deployment_ta_unmanaged from pwc_deployment_ta_unmanaged.zip to /opt/splunkforwarder/etc/apps/"

cd /opt/splunkforwarder/etc/apps

sudo unzip /tmp/splunklinux/pwc_deployment_ta_unmanaged.zip

sudo chown -R splunker:splunker pwc_deployment_ta_unmanaged



echo "Create the file inside  /opt/splunkforwarder/etc/apps/pwc_deployment_ta_unmanaged "

cd /opt/splunkforwarder/etc/apps/pwc_deployment_ta_unmanaged/local

sudo touch  inputs.conf

sudo chmod 600 inputs.conf

echo "Adding content in inputs.conf file"
sudo cat <<EOF >inputs.conf
[default]
_meta = pwc_acl::in_asp2.other
EOF


echo "Add clientName parameter in [deployment-client] file"

current_host =$(hostname)

echo "clientName = $current_host.asp2.in.other" | tee -a  deploymentclient.conf


echo "Delete sslPassword line  in /opt/splunkforwarder/etc/system/local/server.conf"

sudo grep -v "sslPassword" /opt/splunkforwarder/etc/system/local/server.conf > tmp

sudo rm -f /opt/splunkforwarder/etc/system/local/server.conf

sudo mv /opt/splunkforwarder/etc/system/local/tmp  /opt/splunkforwarder/etc/system/local/server.conf


echo "change ownsership in /opt/splunkforwarder/etc/apps/pwc_deployment_ta_unmanaged/locals"

sudo chown -R splunker:splunker /opt/splunkforwarder/etc/apps/pwc_deployment_ta_unmanaged/local


echo "Start Splunk Universal forwarder"


sudo systemctl start splunk




