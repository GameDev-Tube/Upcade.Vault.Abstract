// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @dev Library with events used in 'UpcadeVault' contract.
library UpcadeVaultEvents {
    /**
     * @dev Event emitted in deposit functions.
     * @param from Sender address
     * @param token Token address (address(0) for native)
     * @param amount Amount of sent tokens
     * @param accountId Upcade Bets account id
     * @param walletId Upcade Bets wallet id
     */
    event Deposited(
        address indexed from,
        address token,
        uint256 amount,
        string accountId,
        string walletId
    );

    /**
     * @dev Emitted when user pay fee.
     * @param from Sender address
     * @param amount Amount of fee sent
     * @param transactionId Upcade Bets transaction id
     */
    event FeePaid(address indexed from, uint256 amount, string transactionId);

    /**
     * @dev Emitted when rewards were send to the user.
     * @param rewarded Recipient address
     * @param token Reward token address (address(0) for native)
     * @param amount Amount of reward tokens
     * @param transactionId Upcade Bets transaction id
     */
    event Rewarded(
        address indexed rewarded,
        address token,
        uint256 amount,
        string transactionId
    );

    /**
     * @dev Emitted when new fee recipient was set.
     * @param newFeeRecipient Address of the new fee recipient
     */
    event FeeRecipientSet(address newFeeRecipient);

    /**
     * @dev Emitted when new token was whitelisted or removed from whitelist
     * @param token Address of the token
     * @param isWhitelisted Bool value - true if whitelisted, false if not whitelisted
     */
    event TokenConfigured(address token, bool isWhitelisted);
}
