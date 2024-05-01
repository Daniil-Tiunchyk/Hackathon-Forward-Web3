// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // Address of the contract creator
    address public owner;

    // Fundraising goal (in wei)
    uint public goal;

    // Amount of funds raised (in wei)
    uint public raisedAmount;

    // Flag indicating whether fundraising is closed
    bool public isClosed;

    // Duration of fundraising (in seconds)
    uint public duration;

    // Timestamp of fundraising end
    uint public immutable expiredAt;

    // Mapping storing contributions of each participant
    mapping(address => uint) public contributors;

    // Event signaling a participant's contribution
    event FundTransfer(address backer, uint amount, bool isContribution);

    // Modifier allowing function execution only by the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Modifier allowing function execution only when fundraising is open
    modifier fundingOpen() {
        require(!isClosed, "Funding is closed");
        _;
    }

    // Contract constructor
    constructor(uint goalInEther, uint fundingDurationInMinutes) payable {
        duration = fundingDurationInMinutes * 1 minutes;
        expiredAt = block.timestamp + duration;
        owner = msg.sender;
        goal = goalInEther * 1 ether;
    }

    function contribute() external payable fundingOpen {
        require(msg.value > 0, "Contribution amount must be greater than 0");

        // Cache the value of contributors[msg.sender]
        uint contributionAmount = contributors[msg.sender];
        // Update the value of contributors[msg.sender]
        contributionAmount = contributionAmount + msg.value;

        // Update the value of raisedAmount
        raisedAmount = raisedAmount + msg.value;

        // Update the value of contributors[msg.sender]
        contributors[msg.sender] = contributionAmount;

        emit FundTransfer(msg.sender, msg.value, true);
    }

    // Function for withdrawing the raised funds to the contract owner's address
    function withdrawFunds() external payable onlyOwner fundingOpen {
        payable(owner).transfer(selfbalance());
        emit FundTransfer(owner, selfbalance(), false);
    }

    // Function for closing the fundraising
    function closeContract() external payable onlyOwner {
        require(block.timestamp > expiredAt, "Funding is not yet expired");
        isClosed = true;
    }

    // Function for refunding contributions if the fundraising goal is not reached
    function refund() external fundingOpen {
        require(block.timestamp > expiredAt, "Funding is not yet expired");
        uint amountToRefund = contributors[msg.sender];
        require(amountToRefund > 0, "No contribution to refund");
        contributors[msg.sender] = 0;
        raisedAmount = raisedAmount - amountToRefund;
        payable(msg.sender).transfer(amountToRefund);
        emit FundTransfer(msg.sender, amountToRefund, false);
    }

    // Function to get the contract balance
    function getContractBalance() external view returns (uint) {
        return selfbalance();
    }

    // Function to get the total raised amount
    function getTotalRaisedAmount() external view returns (uint) {
        return raisedAmount;
    }

    // Function to get a contributor's contribution amount
    function getContribution() external view returns (uint) {
        return contributors[msg.sender];
    }

    // Function to get the fundraising duration
    function getDuration() external view returns (uint) {
        return duration;
    }

    // Function to check if the fundraising is closed
    function isFundingClosed() external view returns (bool) {
        return isClosed;
    }
}
