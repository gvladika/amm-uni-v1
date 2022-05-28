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
        if (getReserve() == 0) {
            IERC20(token).transferFrom(msg.sender, address(this), _amount);
        } else {
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = getReserve();

            uint256 tokenAmountRequired = (msg.value * tokenReserve) / ethReserve;
            require(_amount >= tokenAmountRequired, "insufficient token amount");

            IERC20(token).transferFrom(msg.sender, address(this), tokenAmountRequired);
        }
    }

    function getReserve() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getPrice(uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        return (1000 * inputReserve) / outputReserve;
    }

    function getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) private pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");

        uint256 outputAmount = (outputReserve * inputAmount) / (inputReserve + inputAmount);
        return outputAmount;
    }

    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "_ethSold must be greater than 0");

        return getAmount(_ethSold, address(this).balance, getReserve());
    }

    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "_tokenSold must be greater than 0");

        return getAmount(_tokenSold, getReserve(), address(this).balance);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
        uint256 _ethSold = msg.value;
        uint256 tokensBought = getAmount(_ethSold, address(this).balance - _ethSold, getReserve());
        require(tokensBought >= _minTokens, "Slippage too high!");

        IERC20(token).transfer(msg.sender, tokensBought);
    }

    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) public {
        uint256 ethBought = getEthAmount(_tokensSold);
        require(ethBought >= _minEth, "Slippage too high!");

        IERC20(token).transferFrom(msg.sender, address(this), _tokensSold);
        payable(msg.sender).transfer(ethBought);
    }
}
