// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Escrow {
    address public owner;
    address public arbiter;

    constructor(address _arbiter) {
        arbiter = _arbiter;
        owner = msg.sender;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call");
        _;
    }

    modifier onlyBuyer(uint _id) {
        require(msg.sender == pairs[_id].buyer, "Only buyer can call");
        _;
    }

    struct Deal {
        address buyer;
        address seller;
        uint amount;
        bool funded;
        bool released;
    }

    Deal[] public pairs;

    /// @notice Arbiter creates a new buyer-seller pair
    function setPair(address _buyer, address _seller) public onlyArbiter {
        pairs.push(Deal({
            buyer: _buyer,
            seller: _seller,
            amount: 0,
            funded: false,
            released: false
        }));
    }

    /// @notice Buyer deposits ETH into escrow
    function buy(uint _id) public payable onlyBuyer(_id) {
        Deal storage deal = pairs[_id];
        require(!deal.funded, "Already funded");
        require(msg.value > 0, "Must send ETH");

        deal.amount = msg.value;
        deal.funded = true;
    }

    /// @notice Buyer confirms delivery -> release to seller
    function confirmDelivery(uint _id) public onlyBuyer(_id) {
        Deal storage deal = pairs[_id];
        require(deal.funded, "Not funded");
        require(!deal.released, "Already released");

        deal.released = true;
        payable(deal.seller).transfer(deal.amount);
    }

    /// @notice Arbiter resolves dispute -> release funds to seller
    function arbiterRelease(uint _id) public onlyArbiter {
        Deal storage deal = pairs[_id];
        require(deal.funded, "Not funded");
        require(!deal.released, "Already released");

        deal.released = true;
        payable(deal.seller).transfer(deal.amount);
    }

    /// @notice Arbiter refunds buyer if delivery fails
    function arbiterRefund(uint _id) public onlyArbiter {
        Deal storage deal = pairs[_id];
        require(deal.funded, "Not funded");
        require(!deal.released, "Already released");

        deal.released = true;
        payable(deal.buyer).transfer(deal.amount);
    }

    /// @notice Get number of deals
    function getDealCount() public view returns (uint) {
        return pairs.length;
    }
}
