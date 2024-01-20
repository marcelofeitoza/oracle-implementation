// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console } from "forge-std/Test.sol";
import {Oracle} from "../src/Oracle.sol";

contract OracleTest is Test {
    Oracle public oracle;
    address private unauthorized = address(0x1);

    function setUp() public {
        // The Oracle contract now assigns the deployer as the oracle, which in this case is this test contract.
        oracle = new Oracle();
    }

    function testOracleInitialization() public {
        assertTrue(oracle.is_oracle(address(this)), "Deployer should be an oracle on initialization");
    }

    function testOnlyOracleCanUpdatePrices() public {
        uint256 usdPrice = 2500 * 10 ** 18;
        uint256 eurPrice = 2300 * 10 ** 18;
        uint256 btcPrice = 0.06 * 10 ** 18;

        // This should work because the deployer of the Oracle is this test contract itself
        oracle.update_prices(usdPrice, eurPrice, btcPrice);

        // Now we'll try to update prices from an unauthorized address and expect it to fail
        vm.startPrank(unauthorized);
        vm.expectRevert("You are not the oracle.");
        oracle.update_prices(usdPrice, eurPrice, btcPrice);
        vm.stopPrank();
    }

    function testUpdatePrices() public {
        uint256 usdPrice = 2500 * 10 ** 18;
        uint256 eurPrice = 2300 * 10 ** 18;
        uint256 btcPrice = 0.06 * 10 ** 18;

        oracle.update_prices(usdPrice, eurPrice, btcPrice);

        assertEq(oracle.eth_usd_price(), usdPrice, "USD price did not update correctly");
        assertEq(oracle.eth_eur_price(), eurPrice, "EUR price did not update correctly");
        assertEq(oracle.eth_btc_price(), btcPrice, "BTC price did not update correctly");
    }

    function testAddOracle() public {
        address newOracle = address(0x2);
        oracle.add_oracle(newOracle);
        assertTrue(oracle.is_oracle(newOracle), "New oracle should be added");
    }

    function testRemoveOracle() public {
        address newOracle = address(0x2);
        oracle.add_oracle(newOracle);
        oracle.remove_oracle(newOracle);
        assertFalse(oracle.is_oracle(newOracle), "Oracle should be removed");
    }

    function testNonOracleCannotAddOrRemoveOracle() public {
        address newOracle = address(0x3);

        // Try adding an oracle from an unauthorized address
        vm.startPrank(unauthorized);
        vm.expectRevert("You are not the oracle.");
        oracle.add_oracle(newOracle);

        // Try removing an oracle from an unauthorized address
        vm.expectRevert("You are not the oracle.");
        oracle.remove_oracle(address(this));
        vm.stopPrank();
    }
}
