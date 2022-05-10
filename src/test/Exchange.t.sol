// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import "../Token.sol";
import "../Exchange.sol";

contract ExchangeTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Token public token;
    Exchange public exchange;

    // users
    address public alice;
    address public bob;

    function setUp() public {
        token = new Token("Test Token", "Test", 100000 * 10**18);
        exchange = new Exchange(address(token));

        // give Alice 100 ETH and 1000 TEST
        alice = address(0xaaa);
        vm.deal(alice, 100 ether);
        token.transfer(alice, 1000 * 10**18);

        // give Bob 100 ETH and 1000 TEST
        bob = address(0xbbb);
        vm.deal(bob, 100 ether);
        token.transfer(bob, 1000 * 10**18);
    }

    function testAddLiquidity() public {
        uint256 amount = 100;
        uint256 tokenReserveBefore = exchange.getReserve();
        uint256 ethReserveBefore = address(exchange).balance;

        // provide liquidity
        vm.startPrank(alice);
        token.approve(address(exchange), amount);
        exchange.addLiquidity{value: 1 ether}(amount);

        // check contract balance of ETH and token
        uint256 tokenReserveAfter = exchange.getReserve();
        assertTrue(tokenReserveAfter - tokenReserveBefore == amount);

        uint256 ethReserveAfter = address(exchange).balance;
        assertTrue(ethReserveAfter - ethReserveBefore == 1 ether);
    }

    function testGetPrice() public {
        uint256 tokenAmount = 20 * 10**18;

        vm.startPrank(alice);
        token.approve(address(exchange), tokenAmount);
        exchange.addLiquidity{value: 10 ether}(tokenAmount);

        uint256 tokenReserve = exchange.getReserve();
        uint256 etherReserve = address(exchange).balance;

        uint256 tokenToEther = exchange.getPrice(tokenReserve, etherReserve);
        assertTrue(tokenToEther == (2000));

        uint256 etherToToken = exchange.getPrice(etherReserve, tokenReserve);
        assertTrue(etherToToken == (500));
    }

    function testGetEthAmount() public {
        uint256 initialTokenLiquidity = 20 * 10**18;
        uint256 initialEtherLiquidity = 10 ether;

        vm.startPrank(alice);
        token.approve(address(exchange), initialTokenLiquidity);
        exchange.addLiquidity{value: initialEtherLiquidity}(
            initialTokenLiquidity
        );

        uint256 tokenSold = 5 * 10**18;
        uint256 ethAmount = exchange.getEthAmount(tokenSold);
        assertTrue(ethAmount == 2 ether);
    }

    function testGetTokenAmount() public {
        uint256 initialTokenLiquidity = 20 * 10**18;
        uint256 initialEtherLiquidity = 10 ether;

        vm.startPrank(alice);
        token.approve(address(exchange), initialTokenLiquidity);
        exchange.addLiquidity{value: initialEtherLiquidity}(
            initialTokenLiquidity
        );

        uint256 ethSold = 10 ether;
        uint256 tokenAmount = exchange.getTokenAmount(ethSold);
        assertTrue(tokenAmount == 10 * 10**18);
    }
}
