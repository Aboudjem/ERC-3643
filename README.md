# ERC-3643:

## RAPTOR: Simplified and Optimized T-REX Implementation

## Introduction

<p align="center">
<img alt="T-Rex Raptor" src="./docs/img/raptor.png" height=150px>
</p>
Welcome to **ERC-3643 Raptor Version** 🦖! This project is a fork of the [**T-Rex (ERC-3643) standard**](https://github.com/TokenySolutions/T-REX/), which was originally developed by @TokenySolutions. As one of the authors of the ERC-3643, I have worked on this fork independently with the goal of creating a simplified, optimized, and more accessible version. The Raptor aims to make working with security tokens easier to understand and more user-friendly, without attempting to compete with the original T-Rex implementation.

<p align="center">
<img alt="T-Rex Raptor" src="./docs/img/philosoraptor.png" height=350px>
</p>
## Why Raptor?

![Why?](https://media0.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif)

A Raptor is a smaller, lighter dinosaur — just like this project. Raptor is a leaner, more efficient take on the T-Rex standard. By streamlining the original, we've made it more accessible and easier to grasp for everyone.

## Changes & Updates

![Instagram Influencer GIF by Social Nomads](https://media2.giphy.com/media/irIRA0HQCQiTiIMMNm/giphy.gif?cid=ecf05e47qqzltc3e4038f3cguk4d2n8bo2fso7jpequhj6o9&ep=v1_gifs_search&rid=giphy.gif&ct=g)

Compared to the original T-Rex standard, Raptor has undergone several major changes:

### 🎛️ Optimized

- `isVerified` function is now more streamlined and efficient.
- Type casting instances have been minimized by directly changing the types of function parameters.
- Unnecessary checks and logic have been removed to save gas.
- `_msgSender()` function from OpenZeppelin's `Context` contract is used for consistent message sender's address retrieval in meta-transactions.

### ❌ Removed

- Proxies have been removed from the project, simplifying the structure and reducing gas cost.
- Removed `UpdatedTokenInformation` event
- Removed `setName`, `setSymbol`, and `setDecimals` functions for closer adherence to the ERC20 standard.
- Redundant checks for empty strings in the `_name` and `_symbol` parameters have been removed.

### ➕ Added

- `UpdatedOnchainID` event has been introduced.
- Several internal and private functions have been added to optimize gas cost and enhance code clarity.

### ⚙️ Updated

- Role management now utilizes OpenZeppelin's `AccessControl` instead of `AgentRole`.
- Custom `Pausable` mechanism has been replaced with OpenZeppelin's `Pausable` for better flexibility and compatibility.
- Event parameters have been updated with respective interface types.
- A check for array mismatches has been added for improved robustness.
- The `batchTransferFrom` function is added for efficient multiple transfers.

### 📝 Documentation

- Inline documentation has been substantially improved and expanded.

### 🧪 Tests

- Tests have been updated to reflect the changes in contract logic.

For a detailed list of changes, refer to the project's [Change Log](#).

## Credits

![Credits](https://media2.giphy.com/media/dzaUX7CAG0Ihi/giphy.gif)

A huge shoutout to @TokenySolutions for the original T-Rex standard. Raptor is a humble effort to present their work in a more accessible, streamlined format.

## Keywords

ERC3643, ERC-3643, Security tokens, regulated tokens, T-Rex Standard, Raptor

## Conclusion

Raptor, as a lighter and more optimized version of T-Rex (ERC-3643), is designed to bring the power of security tokens to the community in an accessible and understandable format. Dive
