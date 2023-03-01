<h1 align="center">Nibiru Chain Ödüllü Testneti Kurulum Rehberi

## Selams, bugün Nibiru Chain'in ÖDÜLLÜ testnetine katılıyor olacağız. Aşağıdaki formu doldurmayı unutmayın. Sağ üstten yıldızlayıp forklamayı unutmayalım. Sorularınız için: [LossNode Chat](https://t.me/LossNode)


## FORM: https://gleam.io/yW6Ho/nibiru-incentivized-testnet-registration

![image](https://user-images.githubusercontent.com/101462877/221288917-1b9412b4-b6bf-4c22-8378-965d1f04b65a.png)


## Sistem gereksinimleri:
NODE TİPİ | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 200  |

## Nibiru için önemli linkler:
- [Website](https://nibiru.fi/)
- [Explorer](https://nibiru.explorers.guru)
- [Twitter](https://twitter.com/NibiruChain)
- [Discord](https://discord.gg/nibiru)


# 1a) Script ile kurulum.

```bash
wget -O nibiru.sh https://raw.githubusercontent.com/thisislexar/Nibiru-Chain-Testnet/main/nibiru.sh && chmod +x nibiru.sh && ./nibiru.sh
```

# 1b) Manuel kurulum.

Node bilginizi geliştirmek adına dilerseniz [Manuel Kurulum](https://github.com/thisislexar/Nibiru-Chain-Testnet/blob/main/nibiru_manual.md) da yapabilirsiniz.

# 2) Devam edelim. 

```bash
cp /root/go/bin/nibid /usr/local/bin
systemctl restart nibid
``` 

## Sync durumunu kontrol etmek için:

```bash
nibid status 2>&1 | jq .SyncInfo
``` 

## Daha hızlı sync olmak ve node'un daha az yer kaplaması için snapshot atabilirsiniz.
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

Yukarıdaki gibi false çıktısı aldıktan sonra devam.

## Cüzdan oluşturalım.
```bash
nibid keys add <CÜZDANADI>
``` 
Var olan bir cüzdanı kullanmak isterseniz:

```bash
nibid keys add <CÜZDANADI> --recover
``` 

## Test token almak için [Discord](https://discord.gg/nibiru) Faucet kanalına gidiyoruz.

<img width="1132" alt="Ekran Resmi 2023-02-25 00 54 03" src="https://user-images.githubusercontent.com/101462877/221300510-33d94d1e-509a-4e3c-a36c-a1804292d2c1.png">


## Validator oluşturalım.


```bash
nibid tx staking create-validator \
  --amount 1000000unibi \
  --from <CÜZDANADI> \
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



# Pricefeeder kuralım.


```bash
curl -s https://get.nibiru.fi/pricefeeder! | bash
```
## Değişkenleri ayarlayın.
```bash
export CHAIN_ID="nibiru-itn-1"
export GRPC_ENDPOINT="localhost:9090"
export WEBSOCKET_ENDPOINT="ws://localhost:26657/websocket"
export EXCHANGE_SYMBOLS_MAP='{ "bitfinex": { "ubtc:uusd": "tBTCUSD", "ueth:uusd": "tETHUSD", "uusdt:uusd": "tUSTUSD" }, "binance": { "ubtc:uusd": "BTCUSD", "ueth:uusd": "ETHUSD", "uusdt:uusd": "USDTUSD", "uusdc:uusd": "USDCUSD", "uatom:uusd": "ATOMUSD", "ubnb:uusd": "BNBUSD", "uavax:uusd": "AVAXUSD", "usol:uusd": "SOLUSD", "uada:uusd": "ADAUSD", "ubtc:unusd": "BTCUSD", "ueth:unusd": "ETHUSD", "uusdt:unusd": "USDTUSD", "uusdc:unusd": "USDCUSD", "uatom:unusd": "ATOMUSD", "ubnb:unusd": "BNBUSD", "uavax:unusd": "AVAXUSD", "usol:unusd": "SOLUSD", "uada:unusd": "ADAUSD" } }'
export FEEDER_MNEMONIC="<MNEMONICCUZDANKELİMELERİNİZ>"
export VALIDATOR_ADDRESS="<VALİDATORUNUZUNNIBIVALOPERADRESİ>"
```
## Servis dosyası kurun.
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

## Servisi başlatın.

```bash
sudo systemctl daemon-reload && \
systemctl restart systemd-journald.service && \
sudo systemctl enable pricefeeder && \
sudo systemctl start pricefeeder
```
## Pricefeeder için log kontrolü.
```bash
sudo journalctl -fu pricefeeder -o cat
```



# Bazı komutlar:

Log kontrolü

```bash
sudo journalctl -fu nibid -o cat
```


Servisi durdurma

```bash
sudo systemctl stop nibid
```

Servisi tekrar başlatma

```bash
sudo systemctl restart nibid
```

Token delege etme

```bash
nibid tx staking delegate $(nibid keys show wallet --bech val -a) 1000000unibi --from <CÜZDANADI> --chain-id nibiru-itn-1 --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
```

Validator düzenleme

```bash
nibid tx staking edit-validator \
  --moniker=$NODENAME \
  --identity="<KEYBASE ID'NİZ>" \
  --website="<WEBSİTE LİNKİ>" \
  --details="AÇIKLAMA" \
  --chain-id=nibiru-itn-1 \
  --from=<CÜZDANADI>
``` 


# Node silmek için:

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
