// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "./IToken.sol";
import "@onchain-id/solidity/contracts/interface/IIdentity.sol";

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "../compliance/interface/ICompliance.sol";

/// @title ERC-3643 - T-Rex Token (Version RAPTOR-5.0.0)
/// @notice An ERC-3643 compliant token with onchain validators and compliance checks.
contract Token is IToken, AccessControl, Pausable {
    /// @dev ERC20 basic variables
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /// @dev Variables of freeze and pause functions
    mapping(address => bool) private _frozen;
    mapping(address => uint256) private _frozenAmounts;

    uint256 private _totalSupply;

    /// @dev Token information
    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;
    address private _onchainID;
    string private constant _TOKEN_VERSION = "RAPTOR-5.0.0";

    // keccak256(AGENT_ROLE)
    bytes32 public constant AGENT_ROLE =
        0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709;

    // keccak256(OWNER_ROLE)
    bytes32 public constant OWNER_ROLE =
        0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e;

    /// @dev Identity Registry contract used by the onchain validator system
    IIdentityRegistry private _identityRegistry;

    /// @dev Compliance contract linked to the onchain validator system
    ICompliance private _compliance;

    /// @dev the constructor initiates the token contract
    /// _msgSender() is set automatically as the owner of the smart contract
    /// @param identityRegistry_ the address of the Identity registry linked to the token
    /// @param compliance_ the address of the compliance contract linked to the token
    /// @param name_ the name of the token
    /// @param symbol_ the symbol of the token
    /// @param decimals_ the decimals of the token
    /// @param onchainID_ the address of the onchainID of the token
    /// emits an `UpdatedTokenInformation` event
    /// emits an `IdentityRegistryAdded` event
    /// emits a `ComplianceAdded` event
    constructor(
        address identityRegistry_,
        address compliance_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address onchainID_
    ) {
        require(
            identityRegistry_ != address(0) && compliance_ != address(0),
            "ERC-3643: Invalid zero address"
        );

        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _onchainID = onchainID_;

        _grantRole(bytes32(0), _msgSender());
        _grantRole(OWNER_ROLE, _msgSender());
        _grantRole(AGENT_ROLE, _msgSender());

        _identityRegistry = IIdentityRegistry(identityRegistry_);
        _compliance = ICompliance(compliance_);
        _compliance.bindToken(address(this));

        emit IdentityRegistryAdded(identityRegistry_);
        emit ComplianceAdded(compliance_);
        emit UpdatedOnchainID(_onchainID);
    }

    /// @notice Approve `amount` tokens to be spent by `spender`
    /// @param spender The address of the account allowed to spend the tokens
    /// @param amount The number of tokens to be spent
    /// @return A boolean that indicates if the operation was successful.
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /// @notice ERC-20 overridden function that include logic to check for trade validity.
    /// @dev Transfer tokens to another address. Requires that the _msgSender()
    /// and to addresses are not frozen and that the value should not exceed available balance.
    /// @param to The address of the receiver.
    /// @param amount The number of tokens to transfer.
    /// @return true if the transfer is successful.
    function transfer(
        address to,
        uint256 amount
    ) external whenNotPaused returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    /// @dev ERC-20 overridden function that include logic to check for trade validity
    /// @dev Transfer tokens from one address to another. Requires that the `from` and `to` addresses are not frozen
    /// and that the value should not exceed available balance.
    /// @param from The address of the sender.
    /// @param to The address of the receiver.
    /// @param amount The number of tokens to transfer.
    /// @return true if the transfer is successful.
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external whenNotPaused returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, to, amount);

        return true;
    }

    /// @notice Increase the allowance provided to `spender` by the caller
    /// @param spender The address of the account allowed to spend the tokens
    /// @param _addedValue The increase in allowance
    /// @return A boolean that indicates if the operation was successful.
    function increaseAllowance(
        address spender,
        uint256 _addedValue
    ) external returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + (_addedValue)
        );
        return true;
    }

    /// @notice Decrease the allowance provided to `spender` by the caller
    /// @param spender The address of the account allowed to spend the tokens
    /// @param _subtractedValue The decrease in allowance
    /// @return A boolean that indicates if the operation was successful.
    function decreaseAllowance(
        address spender,
        uint256 _subtractedValue
    ) external returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - _subtractedValue
        );
        return true;
    }

    /// @dev Set the onchainID of a token. Can only be called by an owner of the contract.
    /// @param onchainID_ The address of the onchainID.
    /// @notice Emits an UpdatedOnchainID event.
    function setOnchainID(address onchainID_) external onlyRole(OWNER_ROLE) {
        _onchainID = onchainID_;
        emit UpdatedOnchainID(onchainID_);
    }

    /// @notice Pause all token operations
    /// @dev Can only be called by an agent of the contract
    function pause() external onlyRole(AGENT_ROLE) {
        _pause();
    }

    /// @notice Unpause all token operations
    /// @dev Can only be called by an agent of the contract
    function unpause() external onlyRole(AGENT_ROLE) {
        _unpause();
    }

    // @dev Perform a batch transfer of tokens.
    /// @param toList An array of receiver addresses.
    /// @param amounts An array of amounts to transfer.
    function batchTransfer(
        address[] calldata toList,
        uint256[] calldata amounts
    ) external whenNotPaused {
        uint length = toList.length;
        require(length == amounts.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _transfer(_msgSender(), toList[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform a batch forced transfer of tokens.
    /// @param fromList An array of sender addresses.
    /// @param toList An array of receiver addresses.
    /// @param amounts An array of amounts to transfer.
    function batchTransferFrom(
        address[] calldata fromList,
        address[] calldata toList,
        uint256[] calldata amounts
    ) external whenNotPaused {
        uint length = fromList.length;
        require(length == toList.length, "ERC-3643: Array size mismatch");
        require(length == amounts.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _spendAllowance(fromList[i], _msgSender(), amounts[i]);
            _transfer(fromList[i], toList[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform a batch forced transfer of tokens.
    /// @param fromList An array of sender addresses.
    /// @param toList An array of receiver addresses.
    /// @param amounts An array of amounts to transfer.
    function batchForcedTransfer(
        address[] calldata fromList,
        address[] calldata toList,
        uint256[] calldata amounts
    ) external onlyRole(AGENT_ROLE) {
        uint length = fromList.length;
        require(length == toList.length, "ERC-3643: Array size mismatch");
        require(length == amounts.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _forcedTransfer(fromList[i], toList[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform a batch minting of tokens.
    /// @param toList An array of receiver addresses.
    /// @param amounts An array of amounts to mint.
    function batchMint(
        address[] calldata toList,
        uint256[] calldata amounts
    ) external onlyRole(AGENT_ROLE) {
        uint length = toList.length;
        require(length == amounts.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _mint(toList[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform a batch burn of tokens.
    /// @param accounts An array of addresses from which to burn tokens.
    /// @param amounts An array of amounts to burn.
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external onlyRole(AGENT_ROLE) {
        uint length = accounts.length;
        require(length == amounts.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _burn(accounts[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform a batch freezing / unfreezing of addresses.
    /// @param accounts An array of addresses to freeze.
    /// @param freeze An array of boolean values indicating whether to freeze the corresponding address.
    function batchSetAddressFrozen(
        address[] calldata accounts,
        bool[] calldata freeze
    ) external onlyRole(AGENT_ROLE) {
        uint length = accounts.length;
        require(length == freeze.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _setAddressFrozen(accounts[i], freeze[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform a batch freezing of partial tokens from multiple addresses.
    /// @param accounts An array of addresses from which to freeze tokens.
    /// @param amounts An array of amounts to freeze.
    function batchFreezePartialTokens(
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external onlyRole(AGENT_ROLE) {
        uint length = accounts.length;
        require(length == amounts.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _freezePartialTokens(accounts[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform a batch unfreezing of partial tokens from multiple addresses.
    /// @param accounts An array of addresses from which to unfreeze tokens.
    /// @param amounts An array of amounts to unfreeze.
    function batchUnfreezePartialTokens(
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external onlyRole(AGENT_ROLE) {
        uint length = accounts.length;
        require(length == amounts.length, "ERC-3643: Array size mismatch");

        for (uint256 i = 0; i < length; ) {
            _unfreezePartialTokens(accounts[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Recover tokens from a lost wallet and transfer them to a new wallet. Can only be called by an agent of the contract.
    /// @param lostWallet The address of the lost wallet.
    /// @param newWallet The address of the new wallet.
    /// @param investorOnchainID The onchainID of the investor.
    /// @return true if the recovery is successful.
    function recoveryAddress(
        address lostWallet,
        address newWallet,
        address investorOnchainID
    ) external onlyRole(AGENT_ROLE) returns (bool) {
        uint256 investorBalance = _balances[lostWallet];
        require(investorBalance != 0, "ERC-3643: No tokens to recover");

        IIdentity identity = IIdentity(investorOnchainID);

        bool isLostWalletFrozen = _frozen[lostWallet];
        bytes32 _key = keccak256(abi.encode(newWallet));
        require(
            identity.keyHasPurpose(_key, 1),
            "ERC-3643: Recovery not possible"
        );
        uint256 frozenTokens = _frozenAmounts[lostWallet];

        _identityRegistry.registerIdentity(
            newWallet,
            identity,
            _identityRegistry.investorCountry(lostWallet)
        );

        if (isLostWalletFrozen) _frozen[lostWallet] = false;

        _forcedTransfer(lostWallet, newWallet, investorBalance);

        if (frozenTokens != 0) {
            _freezePartialTokens(newWallet, frozenTokens);
        }
        if (isLostWalletFrozen == true) {
            _setAddressFrozen(newWallet, true);
        }
        _identityRegistry.deleteIdentity(lostWallet);

        emit RecoverySuccess(lostWallet, newWallet, investorOnchainID);

        return true;
    }

    /// @notice Executes a forced transfer of tokens from one address to another
    /// @param from The address from which the tokens will be transferred
    /// @param to The address to which the tokens will be transferred
    /// @param amount The number of tokens to be transferred
    /// @return Returns true if the transfer was successful, otherwise false
    function forcedTransfer(
        address from,
        address to,
        uint256 amount
    ) external onlyRole(AGENT_ROLE) returns (bool) {
        return _forcedTransfer(from, to, amount);
    }

    /// @notice Mints new tokens and assigns them to a specified address
    /// @param _to The address that will receive the minted tokens
    /// @param amount The number of tokens to be minted
    function mint(address _to, uint256 amount) external onlyRole(AGENT_ROLE) {
        _mint(_to, amount);
    }

    /// @notice Burns tokens from a specified address
    /// @param account The address from which the tokens will be burned
    /// @param amount The number of tokens to be burned
    function burn(
        address account,
        uint256 amount
    ) external onlyRole(AGENT_ROLE) {
        _burn(account, amount);
    }

    /// @notice Freezes or unfreezes a specified address
    /// @param account The address to be frozen or unfrozen
    /// @param freeze The boolean value indicating whether to freeze (true) or unfreeze (false) the account
    function setAddressFrozen(
        address account,
        bool freeze
    ) external onlyRole(AGENT_ROLE) {
        _frozen[account] = freeze;

        emit AddressFrozen(account, freeze, _msgSender());
    }

    /// @notice Freezes a specified amount of tokens in a specified account
    /// @param account The account in which the tokens will be frozen
    /// @param amount The amount of tokens to be frozen
    function freezePartialTokens(
        address account,
        uint256 amount
    ) external onlyRole(AGENT_ROLE) {
        _freezePartialTokens(account, amount);
    }

    /// @notice Unfreezes a specified amount of tokens in a specified account
    /// @param account The account from which the tokens will be unfrozen
    /// @param amount The amount of tokens to be unfrozen
    function unfreezePartialTokens(
        address account,
        uint256 amount
    ) external onlyRole(AGENT_ROLE) {
        _unfreezePartialTokens(account, amount);
    }

    /// @notice Sets the Identity Registry contract address
    /// @param newIdentityRegistry The address of the new Identity Registry contract
    function setIdentityRegistry(
        address newIdentityRegistry
    ) external onlyRole(OWNER_ROLE) {
        _identityRegistry = IIdentityRegistry(newIdentityRegistry);
        emit IdentityRegistryAdded(newIdentityRegistry);
    }

    /// @notice Sets the Compliance contract address
    /// @param newCompliance The address of the new Compliance contract
    function setCompliance(
        address newCompliance
    ) external onlyRole(OWNER_ROLE) {
        require(newCompliance != address(0), "ERC-3643: Invalid zero address");

        _compliance.unbindToken(address(this));
        _compliance = ICompliance(newCompliance);
        _compliance.bindToken(address(this));
        emit ComplianceAdded(newCompliance);
    }

    /// @dev Returns the name of the token.
    function name() external view returns (string memory) {
        return _name;
    }

    /// @dev Returns the symbol of the token.
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /// @dev Returns the number of decimals the token uses.
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /// @dev Returns the onchainID of the token.
    function onchainID() external view returns (address) {
        return _onchainID;
    }

    /// @notice Get the balance of a specified account.
    /// @param account The address of the account.
    /// @return uint256 The balance of the specified account.
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /// @dev Returns the total supply of the token.
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @dev Returns the allowance of tokens that an owner has allowed a spender to spend.
    /// @param owner The address of the owner.
    /// @param spender The address of the spender.
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /// @dev Returns whether an address is frozen.
    /// @param account The address to check.
    function isFrozen(address account) external view returns (bool) {
        return _frozen[account];
    }

    /// @dev Returns the number of frozen tokens of an address.
    /// @param account The address to check.
    function getFrozenTokens(address account) external view returns (uint256) {
        return _frozenAmounts[account];
    }

    /// @dev Returns the current Compliance contract linked to the token.
    function compliance() external view returns (address) {
        return address(_compliance);
    }

    /// @dev Returns the current Identity Registry contract linked to the token.
    function identityRegistry() external view returns (IIdentityRegistry) {
        return _identityRegistry;
    }

    /// @dev Returns the version of the token.
    function version() external pure returns (string memory) {
        return _TOKEN_VERSION;
    }

    /// @notice ERC-20 overridden function that include logic to check for trade validity.
    /// Require that the `from` and `to` addresses are not frozen.
    /// Require that the `amount` should not exceed available balance .
    /// Require that the `to` address is a verified address
    /// @param from The address of the sender
    /// @param to The address of the receiver
    /// @param amount The number of tokens to transfer
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC-3643: transfer from zero address");
        require(to != address(0), "ERC-3643: transfer to zero address");

        require(!_frozen[to] && !_frozen[from], "ERC-3643: Wallet frozen");
        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC-3643: amount exceeds balance");
        require(
            amount <= fromBalance - (_frozenAmounts[from]),
            "ERC-3643: Freezed balance"
        );

        require(
            _identityRegistry.isVerified(to),
            "ERC-3643: Unverified identity"
        );
        require(
            _compliance.canTransfer(from, to, amount),
            "ERC-3643: Compliance failure"
        );

        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
        _compliance.transferred(_msgSender(), to, amount);
    }

    /// @dev Mints the amount of tokens to the `account`
    /// @param account The address of the receiver
    /// @param amount The number of tokens to mint
    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC-3643: mint to zero address");
        require(
            _identityRegistry.isVerified(account),
            "ERC-3643: Unverified identity"
        );
        require(
            _compliance.canTransfer(address(0), account, amount),
            "ERC-3643: Compliance failure"
        );

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
        _compliance.created(account, amount);
    }

    /// @dev Burns the amount of tokens from the sender's account
    /// @param account The address of the sender
    /// @param amount The number of tokens to burn
    function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC-3643: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC-3643: burn exceeds balance");

        uint256 freeBalance = accountBalance - _frozenAmounts[account];
        if (amount > freeBalance) {
            uint256 tokensToUnfreeze = amount - (freeBalance);
            _frozenAmounts[account] =
                _frozenAmounts[account] -
                (tokensToUnfreeze);
            emit TokensUnfrozen(account, tokensToUnfreeze);
        }
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
        _compliance.destroyed(account, amount);
    }

    /// @notice Approve a specified amount for a spender.
    /// @dev private function that approves a specified amount for a spender.
    /// Emits an Approval event.
    /// @param owner The address of the owner.
    /// @param spender The address of the spender.
    /// @param amount The amount to approve.
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC-3643: approve from zero address");
        require(spender != address(0), "ERC-3643: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /// @notice Forced transfer of a specified amount from one address to another.
    /// @dev Private function to transfer tokens from one address to another.
    /// Requires that the `from` address has enough balance. Adjusts frozen tokens if necessary.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param amount The amount to transfer.
    /// @return true if the forced transfer is successful.
    function _forcedTransfer(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        uint fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC-3643: Sender low balance");
        uint256 freeBalance = fromBalance - (_frozenAmounts[from]);
        if (amount > freeBalance) {
            uint256 tokensToUnfreeze = amount - (freeBalance);
            _frozenAmounts[from] = _frozenAmounts[from] - (tokensToUnfreeze);
            emit TokensUnfrozen(from, tokensToUnfreeze);
        }
        _transfer(from, to, amount);
        return true;
    }

    /// @dev Decreases the allowance of the spender for the sender's tokens
    /// @param owner The address of the sender
    /// @param spender The address of the spender
    /// @param amount The number of tokens to decrease the allowance by
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) private {
        uint256 currentAllowance = _allowances[owner][spender];

        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC3643: Insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /// @dev Freezes or unfreezes the account
    /// @param account The address of the account
    /// @param freeze The boolean value of whether to freeze or unfreeze the account
    function _setAddressFrozen(address account, bool freeze) private {
        _frozen[account] = freeze;

        emit AddressFrozen(account, freeze, _msgSender());
    }

    /// @dev Freezes the amount of tokens in the account
    /// @param account The address of the account
    /// @param amount The number of tokens to freeze
    function _freezePartialTokens(address account, uint256 amount) private {
        uint256 balance = _balances[account];
        require(
            balance >= _frozenAmounts[account] + amount,
            "Amount exceeds available balance"
        );
        _frozenAmounts[account] = _frozenAmounts[account] + (amount);
        emit TokensFrozen(account, amount);
    }

    /// @dev Unfreezes the amount of tokens in the account
    /// @param account The address of the account
    /// @param amount The number of tokens to unfreeze
    function _unfreezePartialTokens(address account, uint256 amount) private {
        require(
            _frozenAmounts[account] >= amount,
            "Amount should be less than or equal to frozen tokens"
        );
        _frozenAmounts[account] = _frozenAmounts[account] - (amount);
        emit TokensUnfrozen(account, amount);
    }
}
