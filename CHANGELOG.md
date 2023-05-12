# 🚀 ERC-3643 - Change Log

This log documents all notable changes to the ERC-3643 Lite project. The project is a simplified version of the T-REX (ERC-3643), tailored for accessibility, ease of understanding, optimized gas cost, increased flexibility, and lighter contract weight.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 📦 Unreleased

## [1.0.0] - 2023-05-12

### 🧹 Simplified

- 🚀 Compliance mechanism has been streamlined. The customized compliance logic has been removed, and the compliance now always returns true. This allows developers to create their own compliance rules that fit within the provided interface.

### 🔄 Replaced

- 🔄 Replaced AgentRole contracts with OpenZeppelin's AccessControl for role management, enhancing the project's flexibility and ease of integration.
- 🔄 Replaced the custom pause mechanism with OpenZeppelin's Pausable. This change allows for greater flexibility and compatibility with other contracts and libraries.

### ❌ Removed

- 🗑️ Proxies have been removed from the project for simplicity and to reduce gas cost.
- 🗑️ Storage contracts have been removed due to the absence of proxies.
- 🗑️ Removed the `pause()` function from the deployment process. Contracts are now active upon deployment.
- 🗑️ Removed `setName` and `setSymbol` functions. This change aligns the contract more closely with the ERC20 standard, where token names and symbols are typically immutable.
- 🗑️ The `_beforeTokenTransfer` function has been removed.

---

As you continue developing and modifying the ERC-3643 Lite project, remember to update the changelog accordingly. This document serves as a valuable resource for other developers and users, helping them to understand the evolution of your project.
