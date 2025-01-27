// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @dev Library with errors used in 'UpcadeVault' contract.
library UpcadeVaultErrors {
    /// @dev Used when no funds are transferred in function.
    error NoFundsTransferred();

    /**
     * @dev Used when transfer of native tokens failed in each function with native transfer.
     * @param to Recipient address
     * @param amount Amount of native tokens to send
     */
    error NativeTransferFailed(address to, uint256 amount);

    /**
     * @dev Used in deposit functions when token is not whitelisted.
     * @param token Invalid token address
     */
    error TokenNotWhitelisted(address token);
}
