<img src="./images/logo.svg" alt="Aera by OneFootball Logo" align="right">

# Aera by OneFootball &middot; ![Env](https://img.shields.io/badge/env-testnet-orange?style=flat-square)

> Dapper Wallet transactions of https://aera.onefootball.com/

This repository contains Flow transaction for https://aera.onefootball.com/. This transactions are to be safelistes within the Dapper system so that users can sign these transactions using their Dapper wallet.

Ref: https://github.com/dapperlabs/dapper-supported-transactions

## Developing

These transactions are developed in another repository, a private one.
Therefore we won't detail here the cadence developer environment.

But given that the Dapper Wallet whitelisting process is a quite manual one,
we want however to safeguard against typos and other potentially costly mistakes.

```shell
brew install pre-commit
pre-commit install
pre-commit run -a
```
