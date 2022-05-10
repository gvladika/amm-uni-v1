// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    address public token;

    constructor(address _token) {
        require(_token != address(0), "token address can't be zero");
        token = _token;
    }

    function addLiquidity(uint256 _amount) public payable {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
    }

    function getReserve() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getPrice(uint256 inputReserve, uint256 outputReserve)
        public
        pure
        returns (uint256)
    {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        return (1000 * inputReserve) / outputReserve;
    }
}
