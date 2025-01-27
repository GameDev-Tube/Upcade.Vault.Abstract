// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// OpenZeppelin imports
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// Local imports - Libraries
import {UpcadeVaultErrors} from "./errors/UpcadeVaultErrors.sol";
import {UpcadeVaultEvents} from "./events/UpcadeVaultEvents.sol";
import {LibUpcadeVaultStorage} from "./storage/LibUpcadeVaultStorage.sol";

/// Local imports - Contracts
import {Withdrawable} from "./utils/Withdrawable.sol";

/// @dev UpcadeVault contract
contract UpcadeVault is
    Ownable2StepUpgradeable,
    AccessControlUpgradeable,
    Withdrawable,
    UUPSUpgradeable
{
    using SafeERC20 for IERC20;

    /// @dev Manager role constant
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    // -----------------------------------------------------------------------
    //                             Initializer
    // -----------------------------------------------------------------------

    /**
     * @dev One time initializer function.
     * @param _feeRecipient Address of the fee recipient
     *
     * @dev Emits :
     * - 'OwnershipTransferred'
     * - 'RoleGranted' 2 times
     * - 'FeeRecipientSet'
     */
    function initialize(address _feeRecipient) external initializer {
        // Transfer ownership
        _transferOwnership(msg.sender);

        // Grant DEFAULT_ADMIN_ROLE to msg.sender
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // Grant MANAGER_ROLE to msg.sender
        _grantRole(MANAGER_ROLE, msg.sender);

        // Set fee recipient in storage
        LibUpcadeVaultStorage.setFeeRecipient(_feeRecipient);

        // Emit event
        emit UpcadeVaultEvents.FeeRecipientSet(_feeRecipient);
    }

    // -----------------------------------------------------------------------
    //                         Configuration Functions
    // -----------------------------------------------------------------------

    /**
     * @dev Function used to set new fee recipient.
     * @param _feeRecipient Address of the new fee recipient
     *
     * @dev Validations :
     * - Only contract owner can perform this function
     *
     * @dev Emits :
     * - 'FeeRecipientSet'
     */
    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        // Set fee recipient in storage
        LibUpcadeVaultStorage.setFeeRecipient(_feeRecipient);

        // Emit event
        emit UpcadeVaultEvents.FeeRecipientSet(_feeRecipient);
    }

    /**
     * @dev Function used to set token as whitelisted or not.
     * @param token Address of the token
     * @param isWhitelisted Bool value - true if whitelisted, false if not whitelisted
     *
     * @dev Validations :
     * - Only contract owner can perform this function
     *
     * @dev Emits :
     * - 'TokenConfigured'
     */
    function setWhitelistedToken(
        address token,
        bool isWhitelisted
    ) external onlyOwner {
        // Set whitelisted token in storage
        LibUpcadeVaultStorage.setWhitelistedToken(token, isWhitelisted);

        // Emit event
        emit UpcadeVaultEvents.TokenConfigured(token, isWhitelisted);
    }

    // -----------------------------------------------------------------------
    //                           Deposit Functions
    // -----------------------------------------------------------------------

    /**
     * @dev Function which allows to deposit ERC-20 token.
     * @param token Token address
     * @param amount Amount of tokens to deposit
     * @param accountId Upcade Bets account id
     * @param walletId Upcade Bets wallet id
     *
     * @dev Validations :
     * - Amount of transferred funds cannot be equal 0
     * - Transferred token must be whitelisted
     * - Token must be correctly sent from user to Vault
     *
     * @dev Emits :
     * - 'Deposited'
     */
    function depositERC20(
        address token,
        uint256 amount,
        string calldata accountId,
        string calldata walletId
    ) external {
        // Validate if amount is not equal 0
        if (amount == 0) revert UpcadeVaultErrors.NoFundsTransferred();

        // Verify if token is whitelisted
        if (LibUpcadeVaultStorage.getIsTokenWhitelisted(token) == false)
            revert UpcadeVaultErrors.TokenNotWhitelisted(token);

        // Transfer token from user to address(this)
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Emit event
        emit UpcadeVaultEvents.Deposited(
            msg.sender,
            token,
            amount,
            accountId,
            walletId
        );
    }

    /**
     * @dev Function which allows to deposit native token.
     * @param accountId Upcade Bets account id
     * @param walletId Upcade Bets wallet id
     *
     * @dev Validations :
     * - Amount of transferred funds cannot be equal 0
     * - Transferred token must be whitelisted
     *
     * @dev Emits :
     * - 'Deposited'
     */
    function depositNative(
        string calldata accountId,
        string calldata walletId
    ) external payable {
        // Validate if sent native are not equal 0
        if (msg.value == 0) revert UpcadeVaultErrors.NoFundsTransferred();

        // Verify if native is whitelisted
        if (LibUpcadeVaultStorage.getIsTokenWhitelisted(address(0)) == false)
            revert UpcadeVaultErrors.TokenNotWhitelisted(address(0));

        // Emit event
        emit UpcadeVaultEvents.Deposited(
            msg.sender,
            address(0),
            msg.value,
            accountId,
            walletId
        );
    }

    // -----------------------------------------------------------------------
    //                          Pay Fee Function
    // -----------------------------------------------------------------------

    /**
     * @dev Function which allows to pay fee for reward function which be called in next step.
     * @param transactionId Upcade Bets transaction id
     *
     * @dev Validations :
     * - Amount of transffered funds cannot be equal 0
     * - Native tokens must be correctly send to fee recipient
     *
     * @dev Emits :
     * - 'FeePaid'
     */
    function payFee(string calldata transactionId) external payable {
        // Validate if sent native are not equal 0
        if (msg.value == 0) revert UpcadeVaultErrors.NoFundsTransferred();

        // Fee recipient address
        address feeRecipient_ = LibUpcadeVaultStorage.getFeeRecipient();

        // Send native to fee recipient
        (bool sent, ) = payable(feeRecipient_).call{value: msg.value}("");

        // Validate if transfer to fee recipient was performed correctly
        if (!sent)
            revert UpcadeVaultErrors.NativeTransferFailed(
                feeRecipient_,
                msg.value
            );

        // Emit event
        emit UpcadeVaultEvents.FeePaid(msg.sender, msg.value, transactionId);
    }

    // -----------------------------------------------------------------------
    //                          Reward Functions
    // -----------------------------------------------------------------------

    /**
     * @dev Function which allows to send ERC-20 token reward to user.
     * @param to Reward recipient address
     * @param token Token address
     * @param amount Amount of tokens to send
     * @param transactionId Upcade Bets transaction id
     *
     * @dev Validations :
     * - Only account with manager role can perform this function
     *
     * @dev Emits :
     * - 'Rewarded'
     */
    function rewardERC20(
        address to,
        address token,
        uint256 amount,
        string calldata transactionId
    ) external onlyRole(MANAGER_ROLE) {
        // Send tokens to user
        IERC20(token).safeTransfer(to, amount);

        // Emit event
        emit UpcadeVaultEvents.Rewarded(to, token, amount, transactionId);
    }

    /**
     * @dev Function which allows to send native token reward to user.
     * @param to Reward recipient address
     * @param amount Amount of tokens to send
     * @param transactionId Upcade Bets transaction id
     *
     * @dev Validations :
     * - Only account with manager role can perform this function
     * - Native must be transferred to user correctly
     *
     * @dev Emits :
     * - 'Rewarded'
     */
    function rewardNative(
        address to,
        uint256 amount,
        string calldata transactionId
    ) external payable onlyRole(MANAGER_ROLE) {
        // Send native to user
        (bool sent, ) = payable(to).call{value: amount}("");

        // Validate if native was send correctly
        if (!sent) revert UpcadeVaultErrors.NativeTransferFailed(to, amount);

        // Emit event
        emit UpcadeVaultEvents.Rewarded(to, address(0), amount, transactionId);
    }

    // -----------------------------------------------------------------------
    //                        External View Functions
    // -----------------------------------------------------------------------

    /**
     * @dev Function to fetch fee recipient address.
     * @return Address of the fee recipient
     */
    function feeRecipient() external view returns (address) {
        return LibUpcadeVaultStorage.getFeeRecipient();
    }

    /**
     * @dev Function to fetch if given tokens is whitelisted.
     * @param token Address of the token to verify
     * @return Boolean value with information if token is whitelisted or not
     */
    function isTokenWhitelisted(address token) external view returns (bool) {
        return LibUpcadeVaultStorage.getIsTokenWhitelisted(token);
    }

    // -----------------------------------------------------------------------
    //                          Internal Functions
    // -----------------------------------------------------------------------

    /**
     * @dev Internal function which is called during proxy upgrade.
     * @param newImplementation Address of the new implementation
     *
     * @dev Validations :
     * - Only contract owner can perform this function
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
