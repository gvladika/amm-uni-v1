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
        token = new Token("Test Token", "Test", 100000);
        exchange = new Exchange(address(token));

        // give Alice 100 ETH and 1000 TEST
        alice = address(0xaaa);
        vm.deal(alice, 100 ether);
        token.transfer(alice, 1000);

        // give Bob 100 ETH and 1000 TEST
        bob = address(0xbbb);
        vm.deal(bob, 100 ether);
        token.transfer(bob, 1000);
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
}
