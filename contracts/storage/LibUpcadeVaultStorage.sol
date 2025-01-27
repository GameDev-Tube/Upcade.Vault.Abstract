// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @dev Library with storage used in 'UpcadeVault' contract.
library LibUpcadeVaultStorage {
    /// @dev keccak256(abi.encode(uint256(keccak256("upcade.vault")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant UPCADE_VAULT_STORAGE_POSITION =
        0xb17541c7ea11b54cfd18c447a71ce8eb22608163a6e67cb2e6d9aad704c54f00;

    /// @dev UpcadeVault struct storage.
    struct UpcadeVaultStorage {
        /// @dev Fee recipient address
        address feeRecipient;
        /// @dev Mapping of whitelisted tokens
        mapping(address => bool) isTokenWhitelisted;
    }

    /// @dev Function for get storage.
    function upcadeVaultStorage()
        internal
        pure
        returns (UpcadeVaultStorage storage uvs)
    {
        assembly {
            uvs.slot := UPCADE_VAULT_STORAGE_POSITION
        }
    }

    // -----------------------------------------------------------------------
    //                                Getters
    // -----------------------------------------------------------------------

    /**
     * @dev Function to fetch fee recipient address.
     * @return Address of the fee recipient
     */
    function getFeeRecipient() internal view returns (address) {
        return upcadeVaultStorage().feeRecipient;
    }

    /**
     * @dev Function to fetch if given tokens is whitelisted.
     * @param token Address of the token to verify
     * @return Boolean value with information if token is whitelisted or not
     */
    function getIsTokenWhitelisted(address token) internal view returns (bool) {
        return upcadeVaultStorage().isTokenWhitelisted[token];
    }

    // -----------------------------------------------------------------------
    //                                Setters
    // -----------------------------------------------------------------------

    /**
     * @dev Function to set fee recipient address.
     * @param newFeeRecipient Address of the new fee recipient
     */
    function setFeeRecipient(address newFeeRecipient) internal {
        upcadeVaultStorage().feeRecipient = newFeeRecipient;
    }

    /**
     * @dev Function to set whitelisted token.
     * @param token Address of the token
     * @param isWhitelisted Boolean value with information if token should be whitelisted or not
     */
    function setWhitelistedToken(address token, bool isWhitelisted) internal {
        upcadeVaultStorage().isTokenWhitelisted[token] = isWhitelisted;
    }
}
