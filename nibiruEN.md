<h1 align="center">Nibiru Chain Incentivized Testnet Node Installation Guide

## We will be participating in Nibiru Chain's INCENTIVIZED testnet. Don't forget to fill out the form below. Also, let's not forget to star and fork from the top right. Sorularınız için: [LossNode Chat](https://t.me/LossNode)


## FORM: https://gleam.io/yW6Ho/nibiru-incentivized-testnet-registration

![image](https://user-images.githubusercontent.com/101462877/221288917-1b9412b4-b6bf-4c22-8378-965d1f04b65a.png)


## System requirements:
NODE TYPE | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 200  |

## Important links for Nibiru:
- [Website](https://nibiru.fi/)
- [Explorer](https://nibiru.explorers.guru)
- [Twitter](https://twitter.com/NibiruChain)
- [Discord](https://discord.gg/nibiru)


# 1a) Installation with script.

```bash
wget -O nibiru.sh https://raw.githubusercontent.com/thisislexar/Nibiru-Chain-Testnet/main/nibiru.sh && chmod +x nibiru.sh && ./nibiru.sh
```

# 1b) Manual installation.

You can also install it [manually](https://github.com/thisislexar/Nibiru-Chain-Testnet/blob/main/nibiru_manualEN.md).

# 2) Continue. 

```bash
cp /root/go/bin/nibid /usr/local/bin
systemctl restart nibid
``` 

## To check sync status:

```bash
nibid status 2>&1 | jq .SyncInfo
``` 

## You can also use snapshot to sync faster and for the node to take up less space.
```bash
sudo systemctl stop nibid
cp $HOME/.nibid/data/priv_validator_state.json $HOME/.nibid/priv_validator_state.json.backup
rm -rf $HOME/.nibid/data
``` 

```bash
curl -L https://snapshots.kjnodes.com/nibiru-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nibid
mv $HOME/.nibid/priv_validator_state.json.backup $HOME/.nibid/data/priv_validator_state.json
``` 

```bash
sudo systemctl restart nibid && sudo journalctl -fu nibid -o cat
``` 

![image](https://user-images.githubusercontent.com/101462877/222057641-07a7cc1a-93d7-4b87-bdfa-d36dc979907f.png)

If you get an output which says `false` like the above image, continue.

## Create your wallet.
```bash
nibid keys add <WALLETNAME>
``` 
You can also use an existing wallet:

```bash
nibid keys add <WALLETNAME> --recover
``` 

## For test tokens, go to [Discord](https://discord.gg/nibiru) Faucet channel.

<img width="1132" alt="Ekran Resmi 2023-02-25 00 54 03" src="https://user-images.githubusercontent.com/101462877/221300510-33d94d1e-509a-4e3c-a36c-a1804292d2c1.png">


## Create your validator.


```bash
nibid tx staking create-validator \
  --amount 1000000unibi \
  --from <WALLETNAME> \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey $(nibid tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id nibiru-itn-1 \
  --website="https://lossnode.info" \
  --details="Testing the Nibiru"
```



# Install pricefeeder.


```bash
curl -s https://get.nibiru.fi/pricefeeder! | bash
```
## Set the variables.
```bash
export CHAIN_ID="nibiru-itn-1"
export GRPC_ENDPOINT="localhost:9090"
export WEBSOCKET_ENDPOINT="ws://localhost:26657/websocket"
export EXCHANGE_SYMBOLS_MAP='{ "bitfinex": { "ubtc:uusd": "tBTCUSD", "ueth:uusd": "tETHUSD", "uusdt:uusd": "tUSTUSD" }, "binance": { "ubtc:uusd": "BTCUSD", "ueth:uusd": "ETHUSD", "uusdt:uusd": "USDTUSD", "uusdc:uusd": "USDCUSD", "uatom:uusd": "ATOMUSD", "ubnb:uusd": "BNBUSD", "uavax:uusd": "AVAXUSD", "usol:uusd": "SOLUSD", "uada:uusd": "ADAUSD", "ubtc:unusd": "BTCUSD", "ueth:unusd": "ETHUSD", "uusdt:unusd": "USDTUSD", "uusdc:unusd": "USDCUSD", "uatom:unusd": "ATOMUSD", "ubnb:unusd": "BNBUSD", "uavax:unusd": "AVAXUSD", "usol:unusd": "SOLUSD", "uada:unusd": "ADAUSD" } }'
export FEEDER_MNEMONIC="<MNEMONICCUZDANKELİMELERİNİZ>"
export VALIDATOR_ADDRESS="<VALİDATORUNUZUNNIBIVALOPERADRESİ>"
```
## Create service file.
```bash
sudo tee /etc/systemd/system/pricefeeder.service<<EOF
[Unit]
Description=Nibiru Pricefeeder
Requires=network-online.target
After=network-online.target

[Service]
Type=exec
User=root
ExecStart=/usr/local/bin/pricefeeder
Restart=on-failure
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
PermissionsStartOnly=true
LimitNOFILE=65535
Environment=CHAIN_ID=$CHAIN_ID'
Environment=GRPC_ENDPOINT='$GRPC_ENDPOINT'
Environment=WEBSOCKET_ENDPOINT='$WEBSOCKET_ENDPOINT'
Environment=EXCHANGE_SYMBOLS_MAP='$EXCHANGE_SYMBOLS_MAP'
Environment=FEEDER_MNEMONIC='$FEEDER_MNEMONIC'

[Install]
WantedBy=multi-user.target
EOF
```

## Start the service.

```bash
sudo systemctl daemon-reload && \
systemctl restart systemd-journald.service && \
sudo systemctl enable pricefeeder && \
sudo systemctl start pricefeeder
```
## Controlling logs for pricefeeder.
```bash
sudo journalctl -fu pricefeeder -o cat
```



# Some commands:

Controlling logs

```bash
sudo journalctl -fu nibid -o cat
```


Stop service

```bash
sudo systemctl stop nibid
```

Restart service

```bash
sudo systemctl restart nibid
```

Delegate token to yourself

```bash
nibid tx staking delegate $(nibid keys show wallet --bech val -a) 1000000unibi --from <WALLETNAME> --chain-id nibiru-itn-1 --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
```

Editing validator

```bash
nibid tx staking edit-validator \
  --moniker=$NODENAME \
  --identity="<YOURKEYBASEID>" \
  --website="<YOURWEBSITE>" \
  --details="DESCRIPTION" \
  --chain-id=nibiru-itn-1 \
  --from=<WALLETNAME>
``` 


# Deleting the node:

```bash
sudo systemctl stop nibid && \
sudo systemctl disable nibid && \
rm /etc/systemd/system/nibid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .nibid && \
rm -rf nibiru && \
rm -rf $(which nibid)
```
