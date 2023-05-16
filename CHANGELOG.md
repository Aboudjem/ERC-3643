# 🚀 ERC-3643 - Change Log

This log documents all notable changes to the ERC-3643 project. The project is a simplified version of the T-REX (ERC-3643), tailored for accessibility, ease of understanding, optimized gas cost, increased flexibility, and lighter contract weight.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Here is the updated change log:

## [5.0.0] - 2023-05-16 - ERC-3643 - Raptor-5.0.0

### 🎛️ Optimized

- The `isVerified` function has been simplified and optimized.
- Simplified functions and added inline returns to improve performance.
- Multiple instances of type casting have been eliminated by changing the types of function parameters directly to their expected types.
- Removed unnecessary checks and logic, improving gas usage.
- Optimized conditions in the contract to further reduce gas consumption.
- Changed to use the `_msgSender()` function from OpenZeppelin's `Context` contract to consistently obtain the message sender's address in a meta-transaction context.

### ⚙️ Updated

- Replaced `AgentRole` with OpenZeppelin's `AccessControl` for role management.
- Replaced the custom `Pausable` mechanism with OpenZeppelin's `Pausable`. This change allows for greater flexibility and compatibility with other contracts and libraries.
- Updated the event `ClaimTopicsRegistrySet`, `IdentityStorageSet`, and `ClaimIssuersRegistrySet` with the respective interface types for their parameters.
- Updated the `setIdentityRegistryStorage`, `setClaimTopicsRegistry`, and `setClaimIssuersRegistry` functions to use interface types for their parameters.
- Added a check for array mismatches to improve robustness.
- Removed limitations on the `decimals` function, as it's a common knowledge that decimals should be between 0 and 18.
- Added the `batchTransferFrom` function to allow multiple transfers from a single function call, which can save gas when multiple transfers are needed.
- The logic of checks is now consolidated within the `_transfer` function, preventing repetition and improving readability and performance.
- Removed a requirement from the token constructor that was causing unnecessary gas usage.

### 📝 Documentation

- Many improvements and additions have been made to the inline documentation.

### ❌ Removed

- Removed `UpdatedTokenInformation` event.
- Removed `setName`, `setSymbol`, and `setDecimals` functions. These changes bring the contract closer to the ERC20 standard, where these properties are typically immutable.
- Removed the `pause` function from the token constructor.
- Removed redundant and expensive checks for empty strings in the `_name` and `_symbol` parameters.

### ➕ Added

- Added the `UpdatedOnchainID` event.
- Added several internal and private functions to optimize gas cost and improve code clarity.

### 🧪 Tests

- Tests have been updated to match the updated contract logic.

Please ensure the dates and version numbers are accurate as I made an educated guess based on the information provided. The Semantic Versioning you are following typically dictates that major changes (such as removal of functions and events) should increment the major version number, as I have shown above.

## [0.1.1] - 2023-05-13 - Claim Issuers Registry

### 🔄 Renamed

- 💼 All references to Trusted Issuers have been renamed to Claim Issuers, to avoid any confusion and standardize terminology.

### 🎛️ Optimized

- 🚀 The code has been optimized for gas usage.
- 🔒 Internal state variables are now private for enhanced security.

### Gas Optimization

- Optimized gas usage in the `ClaimIssuersRegistry` contract.
- Reduced gas consumption in key functions:
  - `addClaimIssuer`: Gas usage decreased from 139,371 to 126,599 (a reduction of approximately 9.2%).
  - `removeClaimIssuer`: Gas usage decreased from 58,125 to 47,259 (a reduction of approximately 19%).
  - `updateIssuerClaimTopics`: Gas usage decreased from 165,093 to 67,181 (a reduction of approximately 59.3%).
- Improved overall gas efficiency in the contract's deployment.
  - Gas consumption reduced from 1,176,500 to 969,939 (a reduction of approximately 17.6%).

### 📝 Documentation

- 📚 Added NatSpec comments for better inline documentation and code readability.

### ⚙️ Updated

- 🧰 Removed specific requirements from the `addClaimIssuer` function:
  - The requirement for `_claimTopics.length` to be less than or equal to 15 was removed, as there is no specific reason to have this limitation and it is not likely to happen.
  - The requirement for `_claimIssuers.length` to be less than 50 was removed for the same reasons.
- 🧹 Removed a redundant check from `removeClaimIssuer` function. A requirement that the address of `_claimIssuer` must not be zero was removed, since the zero address cannot be added as a ClaimIssuer and this case is also verified with the next requirement: `claimIssuerTopicsLength != 0`.
- 🎛️ Added inner functions to reduce code size, improve visibility and clarity.
- 🧩 The requirement on `updateIssuerClaimTopics` function for `_claimTopics.length` to be less than or equal to 15 was removed.
- 🧹 The check in `updateIssuerClaimTopics` function for the `_claimIssuer` address to be non-zero was removed, as this requirement is unnecessary because the zero address cannot be added as a ClaimIssuer.
- 🎨 Changed the signature of `isClaimIssuer` and `hasClaimTopic` functions. The `address` type was replaced by `IClaimIssuer` type, to increase readability of the code and reduce the number of type castings.
- 🔧 Added Gas Reporter for better tracking of the gas consumption during tests.

### 🧪 Tests

- 🧪 Updated the tests to match the updated contract logic.

### ❌ Removed

- 🎨 Removed the large ASCII art from the comments for cleaner and leaner code presentation.

## 📦 Unreleased

## [0.1.0] - 2023-05-12

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
