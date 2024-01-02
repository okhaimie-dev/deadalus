starkli-declare:
	starkli declare $(target) --rpc https://free-rpc.nethermind.io/sepolia-juno/ --account ~/.starkli-wallets/deployer/account.json --keystore ~/.starkli-wallets/deployer/keystore.json

starkli-deploy:
	starkli deploy $(hash) --log-traffic --watch --rpc https://free-rpc.nethermind.io/sepolia-juno/ --account ~/.starkli-wallets/deployer/account.json --keystore ~/.starkli-wallets/deployer/keystore.json
