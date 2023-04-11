// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error NotOwner();
error InvalidNumberOfRecipients();
error NotEnoughBalance();

contract MultiSender {
    address private owner;
    uint public totalValueLocked;

    event OwnerChanged(address indexed newOwner, address indexed oldOwner);
    event AccountRecharged(uint256 rechargeValue);

    modifier isOwner() {
        require(msg.sender == owner, "NotOwner");
        _;
    }

    constructor() payable {
        owner = msg.sender;
        totalValueLocked = msg.value;
    }

    function changeOwner(address newOwner) public isOwner {
        emit OwnerChanged(newOwner, owner);
        owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function recharge() public payable isOwner {
        totalValueLocked += msg.value;
        emit AccountRecharged(msg.value);
    }

    function sendToMany(address payable[] memory recipients, uint[] memory amounts) public payable isOwner {
        totalValueLocked += msg.value;

        require(recipients.length == amounts.length, "InvalidNumberOfRecipients");

        uint totalAmountToSend = 0;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmountToSend += amounts[i];
        }

        require(totalAmountToSend <= totalValueLocked, "NotEnoughBalance");

        // Now send to multiple recipients
        for (uint i = 0; i < recipients.length; i++) {
            totalValueLocked -= amounts[i];
            recipients[i].transfer(amounts[i]);
        }
    }
}
