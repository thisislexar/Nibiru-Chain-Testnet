<h1 align="center">Nibiru Chain Testneti Kurulum Rehberi

## Selams, bugün Nibiru Chain'in testnetine katılıyor olacağız. Şuan için ödülsüz, ancak ödüllüsü yakında başlayacak. Aşağıdaki formu doldurmayı unutmayın. Sağ üstten yıldızlayıp forklamayı unutmayalım. Sorularınız için: [LossNode Chat](https://t.me/LossNode)


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

```
wget -O nibiru.sh https://raw.githubusercontent.com/thisislexar/Nibiru-Chain-Testnet/main/nibiru.sh && chmod +x nibiru.sh && ./nibiru.sh
```

# 1b) Manuel kurulum.

Node bilginizi geliştirmek adına dilerseniz [Manuel Kurulum](https://github.com/thisislexar/Nibiru-Chain-Testnet/blob/main/nibiru_manual.md) da yapabilirsiniz.

# 2) Devam edelim. 

## Sync durumunu kontrol etmek için:

```
nibid status 2>&1 | jq .SyncInfo
``` 

## Cüzdan oluşturalım.
```
nibid keys add <CÜZDANADI>
``` 
Var olan bir cüzdanı kullanmak isterseniz:

```
nibid keys add <CÜZDANADI> --recover
``` 

## Test token almak için [Discord](https://discord.gg/nibiru) Faucet kanalına gidiyoruz.

<img width="1132" alt="Ekran Resmi 2023-02-25 00 54 03" src="https://user-images.githubusercontent.com/101462877/221300510-33d94d1e-509a-4e3c-a36c-a1804292d2c1.png">


## Validator oluşturalım.


```
nibid tx staking create-validator \
  --amount 1000000unibi \
  --from <CÜZDANADI> \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey $(nibid tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id nibiru-testnet-2 \
  --website="https://lossnode.info" \
  --details="Testing the Nibiru"
```


# Bazı komutlar:

Log kontrolü

```
sudo journalctl -fu nibid -o cat
```


Servisi durdurma

```
sudo systemctl stop nibid
```

Servisi tekrar başlatma

```
sudo systemctl restart nibid
```

Token delege etme

```
nibid tx staking delegate $(nibid keys show wallet --bech val -a) 1000000unibi --from <CÜZDANADI> --chain-id nibiru-testnet-2 --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
```

Validator düzenleme

```
nibid tx staking edit-validator \
  --moniker=$NODENAME \
  --identity="<KEYBASE ID'NİZ>" \
  --website="<WEBSİTE LİNKİ>" \
  --details="AÇIKLAMA" \
  --chain-id=nibiru-testnet-2 \
  --from=<CÜZDANADI>
``` 


# Node silmek için:

```
sudo systemctl stop nibid && \
sudo systemctl disable nibid && \
rm /etc/systemd/system/nibid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .nibid && \
rm -rf nibiru && \
rm -rf $(which nibid)
```
