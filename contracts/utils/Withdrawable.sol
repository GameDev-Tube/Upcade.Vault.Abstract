// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// OpenZeppelin imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

// Local imports - Errors
import {UpcadeVaultErrors} from "../errors/UpcadeVaultErrors.sol";

/// @dev Abstract contract with withdraw functions for contract owner
abstract contract Withdrawable is Ownable2StepUpgradeable {
    using SafeERC20 for IERC20;

    /**
     * @dev Function which allows to withdraw ERC-20 token from contract.
     * @param to Recipient address
     * @param token Token address
     * @param amount Amount of tokens to send
     *
     * @dev Validations :
     * - Only contract owner can perform this function
     */
    function withdrawToken(
        address to,
        address token,
        uint256 amount
    ) external onlyOwner {
        // Send native
        IERC20(token).safeTransfer(to, amount);
    }

    /**
     * @dev Function which allows to withdraw native token from contract.
     * @param to Recipient address
     * @param amount Amount of native to send
     *
     * @dev Validations :
     * - Only contract owner can perform this function
     */
    function withdrawNative(
        address to,
        uint256 amount
    ) external payable onlyOwner {
        // Send native
        (bool sent, ) = payable(to).call{value: amount}("");

        // Validate if transfer to fee recipient was performed correctly
        if (!sent) revert UpcadeVaultErrors.NativeTransferFailed(to, amount);
    }
}
