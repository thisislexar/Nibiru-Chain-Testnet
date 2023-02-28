#!/bin/bash
echo -e "\033[0;35m"
echo "  _     ___  ____ ____  _   _  ___  ____  _____ ";
echo " | |   / _ \/ ___/ ___|| \ | |/ _ \|  _ \| ____|";
echo " | |  | | | \___ \___ \|  \| | | | | | | |  _|  ";
echo " | |__| |_| |___) |__) | |\  | |_| | |_| | |___ ";
echo " |_____\___/|____/____/|_| \_|\___/|____/|_____|";
echo -e "\e[0m"

sleep 3

if [ ! $NODENAME ]; then
	read -p "Node adinizi girin: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi

echo "export NIBIRU_CHAIN_ID=nibiru-itn-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo -e "\e[1m\e[32m1. Sunucu guncellemesi yapiliyor.. \e[0m"
echo "======================================================"
sleep 1

sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Gerekli kurulumlar yapiliyor.. \e[0m"
echo "======================================================"
sleep 1
sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential bsdmainutils git make ncdu htop screen unzip bc fail2ban htop -y

sudo apt install lz4 -y

echo -e "\e[1m\e[32m2. Go Yukleniyor.. \e[0m"
echo "======================================================"
sleep 1

if ! [ -x "$(command -v go)" ]; then
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version
fi


echo -e "\e[1m\e[32m3. Binary dosyalari yukleniyor.. \e[0m"
echo "======================================================"
sleep 1


cd $HOME
git clone https://github.com/NibiruChain/nibiru
cd nibiru
git checkout v0.19.2
make install

nibid config chain-id $NIBIRU_CHAIN_ID

nibid init $NODENAME --chain-id $NIBIRU_CHAIN_ID


echo -e "\e[1m\e[32m3. Genesis dosyasi indiriliyor, seed/peer ayari yapiliyor.. \e[0m"
echo "======================================================"
sleep 1

curl -s https://networks.itn.nibiru.fi/nibiru-itn-1/genesis > $HOME/.nibid/config/genesis.json
wget -O $HOME/.nibid/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/Nibiru/addrbook.json"


pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="10" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" ~/.nibid/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" ~/.nibid/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" ~/.nibid/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" ~/.nibid/config/app.toml

indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.nibid/config/config.toml

sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0unibi\"/;" ~/.nibid/config/app.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.nibid/config/config.toml
external_address=$(wget -qO- eth0.me) 
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.nibid/config/config.toml
peers="d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:39656,68874e60acc2b864959ab97e651ff767db47a2ea@65.108.140.220:26656,769b35816998e91918569c3bbebb6e016ddd74b5@35.243.210.205:26656,e2b8b9f3106d669fe6f3b49e0eee0c5de818917e@213.239.217.52:32656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.nibid/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.nibid/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.nibid/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.nibid/config/config.toml
CONFIG_TOML="$HOME/.nibid/config/config.toml"
 sed -i 's/timeout_propose =.*/timeout_propose = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_propose_delta =.*/timeout_propose_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote_delta =.*/timeout_prevote_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit_delta =.*/timeout_precommit_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_commit =.*/timeout_commit = "1s"/g' $CONFIG_TOML
 sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_TOML



echo -e "\e[1m\e[32m4. Servis dosyasi olusturuluyor.. \e[0m"
echo "======================================================"
sleep 1


sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibiru
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[1m\e[32m4. Servis baslatiliyor.. \e[0m"
echo "======================================================"
sleep 1

sudo systemctl daemon-reload
systemctl restart systemd-journald.service
sudo systemctl enable nibid
sudo systemctl restart nibid
source $HOME/.bash_profile
