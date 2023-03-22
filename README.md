# one-click-deploy

This is a Foundry script that aims to deploy a full-fledged testing round along with projects, applications, votes and payouts in one command.

The idea is to take everything in here: https://github.com/allo-protocol/contracts/tree/main/scripts
and translate it to Solidity/Forge using this https://github.com/Allo-Protocol/contracts/blob/main/docs/DEPLOY_STEPS.md
Forge deploy scripts reference: https://book.getfoundry.sh/tutorials/solidity-scripting

# Features
- One-command deploy - fill out .env, run deploy script and everything is taken care of
- Supports all chains natively - change the RPC URL to any EVM chain
- Non-interactive - doesn't require confirmations
- Does real interaction - creates projects, applies to rounds, rejects some applications and approves others, casts various votes, does a payout.
- Designed to be used with a local Anvil node, but can be used on any chain given enough gas in mnemonic accounts.
