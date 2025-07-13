
## Technical Spec
<!-- Here you should list your DAO specification. You have some flexibility on how you want your DAO's voting system to work and Proposals should be stored, and you need to document that here so that your staff micro-auditor knows what spec to compare your implementation to.  -->

- Write a governance smart contract for a decentralized autonomous organization (Collector DAO) whose aim is buying valuable NFTs.

### Membership

- Allows anyone to buy a membership for 1 ETH.
- The membership fee should strictly be 1 ETH.
- Membership can't be purchased more than once. 
- Voting power of newly created member is `1`.

### Proposal Creation

- Only members can create governance proposals.
- Proposals include series of arbitrary function calls to execute.
- Proposals contains target addresses, value of ETH to send to those addresses and calldatas for that addresses.
- Name of function to be called is included in calldata.
- The minimum length of function to be executed in proposal should be 1.
- All the length of array should be equal.
- It is also possible to propose with similar set of targets, values and calldatas.
- So, I have used auto incrementing ID (`proposalCounterId` in code) to generate unique hash for each proposal.
- The time for voting on proposal starts from the same block on which proposal is proposed.
- Members can vote on proposal till 7 days(included) after the proposal is proposed.
- Proposal struct notes the member at time of proposal creation to maintain correct calculation in quorum.
- It should be possible to create proposal with identical set of proposed functions.
- The proposal's data should not be stored in the contract's storage. Instead, only a hash of the data should be stored on-chain.


### Proposal Voting

- Only members can vote on proposal.
- Member should not be able to vote on invalid proposal id. 
- Voting window is for 7 days(inclusive) after the project gets created.
- Member who has already voted can not vote again on the proposal.
- Members who have joined after the proposal is created can't vote on proposal.
- Members can't vote on executed proposal.
- Member can vote "yes" or "no" to the proposal.

### Proposal Passing

- Proposal is considered passed if voting period is over, `25%` quorum has reached and there are more yes votes than no votes.
- Quorum considers both the member who votes "yes" and "no".
- `25%` quorum is inclusive and it should strictly be more than or equal to `25%`.

### Execution of Proposal

- Anyone can execute the proposal if it is passed.
- If any of the proposed function fails during execution of proposal, entire transaction should be reverted.
- DAO incentivizes the address which executes the proposals rapidly by successfully offering 0.01 ETH if execution is successful.
- If DAO's balance is less than `5 ETH`, executor is not rewarded.
- The DAO's balance is checked after all the proposed function calls are completed.
- If proposal is successfully executed before, it should not be executed before.
- If proposal is successfully executed, voting power of creator increases by `1`. 

### EIP-712 Voting through Signatures

- A function should exist that allows any address to submit a DAO member's vote using off-chain generated EIP-712 signatures should exist on the contract.
- All the rules that apply to general voting function should apply to signer who signs the transaction.
- Another function should exist that enables bulk submission and processing of many EIP-712 signature votes, from several DAO members, across multiple proposals, to be processed in a single function call.
- If any one of the signature failed to verify, then the function should revert. It should also emit an event telling which vote failed to verify.

### Implementation details

- A standardized NFT-buying function called `buyNFTFromMarketplace` should exist on the DAO contract so that DAO members can include it as one of the proposed arbitrary function calls on routine NFT purchase proposals.
- Even though this DAO has one main purpose (collecting NFTs), the proposal system should support proposing the execution of any arbitrarily defined functions on any contract.
- Only source of funds for DAO is membership fees. So, there is not any `receive` function in the contract.



## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
