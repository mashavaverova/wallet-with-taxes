// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "src/Marketplace/Marketplace.sol";
import "src/FeeDistributor/FeeDistributor.sol";
import "src/Wallet/GenesisWalletFactory.sol";
import "src/Tax/TaxProcessor.sol";
import "src/Token/TRI.sol";
import "src/Collectibles/Collectibles.sol";
import "src/SAFU/SAFU.sol";

contract POCTests is Test {
    TRI tri;
    Collectibles collectibles;
    FeeDistributor distributor;
    SAFU safu;
    Marketplace marketplace;
    GenesisWalletFactory walletFactory;
    TaxProcessor taxProcessor;

    address deployer = address(this);
    address dev = address(0x1);
    address triolith = address(0x2);
    address staking = address(0x3);
    address alice = address(0x4);
    address bob = address(0x5);

    function setUp() public {
        tri = new TRI();
        collectibles = new Collectibles("ipfs://base/");
        safu = new SAFU(address(tri));
        distributor = new FeeDistributor(address(tri), dev, triolith, staking, address(safu));
        marketplace = new Marketplace(address(tri), address(distributor));
        walletFactory = new GenesisWalletFactory(address(0)); // skip wallet logic for now
        taxProcessor = new TaxProcessor();

        tri.mint(alice, 1000 ether);
        tri.mint(bob, 1000 ether);

        collectibles.grantRole(collectibles.GAME_DEV_ROLE(), alice);

        vm.startPrank(alice);
        collectibles.mint(alice, 1, 10, "");
        collectibles.setApprovalForAll(address(marketplace), true);
        vm.stopPrank();

    }

function test_MarketplaceBuyAndDistributeFees() public {
    vm.startPrank(alice);
    marketplace.list(address(collectibles), 1, 2, 100 ether);
    vm.stopPrank();

    vm.startPrank(bob);
    tri.approve(address(marketplace), 1000 ether);
    marketplace.buy(0, 1);
    vm.stopPrank();

    // Alice received 95 TRI (100 - 5 fee)
    assertEq(tri.balanceOf(alice), 1095 ether);

    // Fee already distributed — distributor balance should be 0
    assertEq(tri.balanceOf(address(distributor)), 0);

    // Final expected distributions from 5 TRI fee:
    assertEq(tri.balanceOf(dev), 3 ether);                 // 60%
    assertEq(tri.balanceOf(triolith), 1.425 ether);        // 95% of 30%
    assertEq(tri.balanceOf(staking), 0.5 ether);           // 10%
    assertEq(tri.balanceOf(address(safu)), 0.075 ether);   // 5% of triolith's 1.5
}



    function test_LogTaxEvent() public {
        vm.prank(deployer);
        taxProcessor.logTaxEvent(alice, 120, "Sold NFT for 300 TRI");

        TaxProcessor.TaxEvent memory event0 = taxProcessor.getEvent(0);
        assertEq(event0.user, alice);
        assertEq(event0.gainOrLossSEK, 120);
    }
} 
