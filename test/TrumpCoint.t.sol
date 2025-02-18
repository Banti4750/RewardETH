// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/TrumpCoin.sol";

contract TrumpCoinTest is Test {
    TrumpCoin c;

    function setUp() public {
        c = new TrumpCoin(address(this));
    }

    function testInitialSupply() public view {
        assert(c.totalSupply() == 0);
    }

    function testMint() public {
        c.mint(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9, 10);
        assert(c.balanceOf(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9) == 10);
    }

    function testFail() public {
        vm.startPrank(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9);
        c.mint(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9, 10);
    }

    function testChangeStakingContract() public {
        c.updateStakingContract(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9);
        vm.startPrank(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9);
        c.mint(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9, 10);
        assert(c.balanceOf(0xfF1D73Ea47222386fE482BAadb1f3d5755ea55c9) == 10);
    }
}
