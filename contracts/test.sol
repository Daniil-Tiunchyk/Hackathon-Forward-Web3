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

    // Duration of fundraising (in seconds)
    uint public duration;

    // Timestamp of fundraising end
    uint public immutable expiredAt;

    // Name of the campaign
    string public name;

    // Description of the campaign
    string public description;

    // Category of the campaign
    string public category;

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
        require(block.timestamp < expiredAt, "Funding is not yet expired");
        _;
    }

    // Modifier allowing function execution only when fundraising is closed
    modifier fundingClosed() {
        require(block.timestamp > expiredAt, "Funding is not yet expired");
        _;
    }

    constructor(
        string memory _name,
        string memory _description,
        string memory _category,
        uint goalInEther,
        uint fundingDurationInDays
    ) {
        name = _name;
        description = _description;
        category = _category;
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
        contributionAmount += msg.value;

        // Update the value of raisedAmount
        raisedAmount += msg.value;

        // Update the value of contributors[msg.sender]
        contributors[msg.sender] = contributionAmount;

        emit FundTransfer(msg.sender, msg.value, true);
    }

    /**
     * @dev Allows the contract owner to withdraw the raised funds to their address.
     */
    function withdrawFunds() external onlyOwner fundingClosed {
        uint contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
        emit FundTransfer(owner, contractBalance, false);
    }

    /**
     * @dev Refunds a participant's contribution if the fundraising goal is not reached.
     */
    function refund() external fundingOpen {
        uint amountToRefund = contributors[msg.sender];
        require(amountToRefund > 0, "No contribution to refund");
        contributors[msg.sender] = 0;
        raisedAmount -= amountToRefund;
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
        return block.timestamp > expiredAt;
    }
}

contract CrowdfundingFactory {
    Crowdfunding[] public crowdfundingContracts;
    event CrowdfundingCreated(Crowdfunding crowdfunding);

    address private factoryOwner;
    address public factoryAddress;

    constructor() {
        factoryOwner = msg.sender;
        factoryAddress = address(this); // Set the factory address
    }

    function createCrowdfunding(
        string memory name,
        string memory description,
        string memory category,
        uint goalInEther,
        uint fundingDurationInDays
    ) external {
        // Check if factory contract is already created
        if (factoryAddress != address(0)) {
            // Factory contract already exists, no need to create a new one
            Crowdfunding crowdfunding = new Crowdfunding(
                name,
                description,
                category,
                goalInEther,
                fundingDurationInDays
            );
            crowdfundingContracts.push(crowdfunding);
            emit CrowdfundingCreated(crowdfunding);
        } else {
            // Factory contract doesn't exist, create a new one
            factoryAddress = address(this);
            Crowdfunding crowdfunding = new Crowdfunding(
                name,
                description,
                category,
                goalInEther,
                fundingDurationInDays
            );
            crowdfundingContracts.push(crowdfunding);
            emit CrowdfundingCreated(crowdfunding);
        }
    }

    function getCrowdfundingContracts()
        external
        view
        returns (Crowdfunding[] memory)
    {
        return crowdfundingContracts;
    }
}
