// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// OpenZeppelin imports
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// ToDo
contract MockERC20 is ERC20 {
    uint8 internal immutable __decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 _decimals
    ) ERC20(name, symbol) {
        __decimals = _decimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return __decimals;
    }
}
