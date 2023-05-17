# ERC-3643:

## RAPTOR: An Educational Approach to the T-REX Standard

## Introduction

Welcome to the **Raptor Version of ERC-3643** 🦖! This project is a respectful nod to the [**T-Rex (ERC-3643) standard**](https://github.com/TokenySolutions/T-REX/), developed by @TokenySolutions.

I had the privilege of contributing to the original ERC-3643 standard. Inspired by that work, I've created a simpler version. This isn't about competition with T-Rex, it's about sharing knowledge and making it easier for everyone to understand this great piece of technology.

This ERC-3643-Raptor project is **not audited** and **not meant for production use**. It's my personal take on the T-Rex standard and it's made for learning purposes. If you want to implement the ERC-3643 in a real-world scenario, I strongly recommend getting in touch with [@TokenySolutions](https://github.com/TokenySolutions/T-REX).

<p align="center">
<img alt="T-Rex Raptor" src="./docs/img/raptor-philo.png" height=350px>
</p>

## Why Raptor?

A Raptor is a smaller dinosaur, like this project. I've tried to make this version of the T-Rex standard lighter and easier to understand.

## What's Different?

![Instagram Influencer GIF by Social Nomads](https://media2.giphy.com/media/irIRA0HQCQiTiIMMNm/giphy.gif?cid=ecf05e47qqzltc3e4038f3cguk4d2n8bo2fso7jpequhj6o9&ep=v1_gifs_search&rid=giphy.gif&ct=g)

Raptor is a simplified take on the T-Rex standard. It's stripped back to make it easier to understand. Some functions have been removed or optimized to make things clearer.

- No Proxy Implementation: The proxy contract included in the original T-Rex standard has been removed in Raptor. The proxy contract is typically used for upgradability, but it can add complexity, especially for those new to smart contract development.

- Reduced Compliance Features: While T-REX includes a detailed compliance layer for regulated tokens, Raptor has simplified these mechanisms. This change was made to focus on core functionalities and improve understandability.

- Streamlined Functionality: Some features from the original T-Rex, such as setName, setSymbol, and setDecimals functions, have been removed in Raptor to align more closely with the standard ERC20 token where these properties are typically immutable.

- Role Management Update: Role management in Raptor now uses OpenZeppelin's AccessControl instead of AgentRole, making it easier to manage access rights.

- Simplified Pausable Mechanism: The custom Pausable mechanism in the T-Rex has been replaced with OpenZeppelin's Pausable in Raptor. This update provides better compatibility with other contracts and libraries.

- Batch Transfer Feature: Raptor includes a batchTransferFrom function, making it possible to make multiple transfers in a single transaction, potentially saving on gas costs.

- Updated Documentation: The inline documentation has been expanded and updated in Raptor, making it easier for developers to understand the contract's functionalities.

These changes are not an attempt to improve or critique the T-Rex standard. They were made to provide a simplified, more accessible version of the ERC-3643 standard for **educational purposes**. If you're interested in a comprehensive and production-ready implementation, I recommend exploring the original T-Rex standard by [@TokenySolutions](https://github.com/TokenySolutions/T-REX).

For a detailed look at the changes, check out the project's [Change Log](./CHANGELOG.md)

## Thanks

Many thanks to my former colleagues at @TokenySolutions for their exceptional work in developing the original T-Rex standard. My Raptor project is a personal endeavor, a way for me to revisit this impressive work, simplify it, and make it more accessible for everyone

## Keywords

ERC3643, ERC-3643, Security tokens, regulated tokens, T-Rex Standard, Raptor

## Conclusion

Raptor is my personal, educational take on the T-Rex (ERC-3643) standard. It's here to help make the world of security tokens more accessible. Take a look, learn something, and remember to get in touch with @TokenySolutions if you want to use the ERC-3643 in production.
