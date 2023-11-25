#/bin/sh
if ! command -v speedtest &> /dev/null
then
    echo "speedtest could not be found"
    sudo apt-get install curl
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    sudo apt-get install speedtest
fi

DNS="\"$(cat /etc/resolv.conf | grep "192" | awk '{print $2}')\""
CURRENT_DNS=$(cat config.yaml | grep "dns_server" | awk '{print $2}')
sed -i "s/$CURRENT_DNS/$DNS/g" ./config.yaml
sudo sysctl -w net.ipv4.ping_group_range="0 2147483647"
./smartcpe-test-tools
