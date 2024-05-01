// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Crowdfunding
 * @dev A smart contract for crowdfunding campaigns.
 */
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

    /**
     * @dev Contract constructor.
     * @param goalInEther The fundraising goal in Ether.
     * @param fundingDurationInMinutes The duration of the fundraising campaign in days
     */
    constructor(uint goalInEther, uint fundingDurationInDays) payable {
        duration = fundingDurationInDays * 1 days;
        expiredAt = block.timestamp + duration;
        owner = msg.sender;
        goal = goalInEther * 1 ether;
    }

    /**
     * @dev Allows a participant to contribute funds to the crowdfunding campaign.
     */
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

    /**
     * @dev Allows the contract owner to withdraw the raised funds to their address.
     */
    function withdrawFunds() external onlyOwner fundingOpen {
        uint contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
        emit FundTransfer(owner, contractBalance, false);
    }

    /**
     * @dev Closes the fundraising campaign.
     */
    function closeContract() external onlyOwner {
        require(block.timestamp > expiredAt, "Funding is not yet expired");
        isClosed = true;
    }

    /**
     * @dev Refunds a participant's contribution if the fundraising goal is not reached.
     */
    function refund() external fundingOpen {
        require(block.timestamp > expiredAt, "Funding is not yet expired");
        uint amountToRefund = contributors[msg.sender];
        require(amountToRefund > 0, "No contribution to refund");
        contributors[msg.sender] = 0;
        raisedAmount = raisedAmount - amountToRefund;
        payable(msg.sender).transfer(amountToRefund);
        emit FundTransfer(msg.sender, amountToRefund, false);
    }

    /**
     * @dev Retrieves the contract balance.
     * @return The balance of the contract in wei.
     */
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    /**
     * @dev Retrieves the total amount raised in the campaign.
     * @return The total amount raised in wei.
     */
    function getTotalRaisedAmount() external view returns (uint) {
        return raisedAmount;
    }

    /**
     * @dev Retrieves a participant's contribution amount.
     * @return The contribution amount of the caller in wei.
     */
    function getContribution() external view returns (uint) {
        return contributors[msg.sender];
    }

    /**
     * @dev Retrieves the duration of the fundraising campaign.
     * @return The duration of the campaign in seconds.
     */
    function getDuration() external view returns (uint) {
        return duration;
    }

    /**
     * @dev Checks if the fundraising campaign is closed.
     * @return A boolean indicating whether the campaign is closed.
     */
    function isFundingClosed() external view returns (bool) {
        return isClosed;
    }
}
