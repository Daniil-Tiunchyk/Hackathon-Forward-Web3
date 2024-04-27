// SPDX-License-Ident
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint public goal;
    uint public raisedAmount;
    bool public fundingGoalReached;
    mapping(address => uint) public contributors;
    event FundTransfer(address backer, uint amount, bool isContribution);
    constructor(uint _goal) {
        owner = msg.sender;
        goal = _goal;
    }

    function contribute() public payable {
        require(!fundingGoalReached, "Funding goal already reached");
        require(msg.value > 0, "Contribution amount must be greater than 0");

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        emit FundTransfer(msg.sender, msg.value, true);

        checkGoalReached();
    }

    function checkGoalReached() private {
        if (raisedAmount >= goal) {
            fundingGoalReached = true;
        }
    }

    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(fundingGoalReached, "Funding goal not reached yet");
        require(
            raisedAmount >= (goal * 50) / 100,
            "Less than 50% of the goal has been reached"
        );
        payable(owner).transfer(address(this).balance);
        raisedAmount = 0;
        fundingGoalReached = false;
        emit FundTransfer(owner, address(this).balance, false);
    }

    function refund() public {
        require(contributors[msg.sender] > 0, "No contribution to refund");
        require(!fundingGoalReached, "Funding goal already reached");

        payable(msg.sender).transfer(contributors[msg.sender]);
        raisedAmount -= contributors[msg.sender];
        contributors[msg.sender] = 0;
        emit FundTransfer(msg.sender, contributors[msg.sender], false);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
