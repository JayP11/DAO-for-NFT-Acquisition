// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Dao {
    string public constant name = "Dao Governance";
    uint256 public constant MEMBERSHIP_FEE = 1 ether;
    uint256 public currentMember;

    mapping(address => bool) isMember;
    mapping(address => uint256) joinedAt;
    mapping(address => uint256) votingPower;
    mapping(uint256 => Proposal) proposals;
    uint256 public proposalCounterId;
    uint256 public VOTING_WINDOW = 7 days;

    mapping(address => mapping(uint256 => bool)) public hasVoted;

    struct Proposal {
        uint256 nonce;
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 totalMembersAtTimeOfCreation;
        address creator;
        bool executed;
    }

    event MemberCreated(address member);
    event ProposalCreated(uint256 proposalId, uint256 nonce);

    function buyMembership() public payable {
        if (msg.value != MEMBERSHIP_FEE) {
            revert InvalidFee();
        }
        if (isMember[msg.sender]) {
            revert AlreadyMember();
        }
        isMember[msg.sender] = true;
        joinedAt[msg.sender] = block.timestamp;
        votingPower[msg.sender] = 1;
        currentMember++;

        emit MemberCreated(msg.sender);
    }

    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory callData,
        uint256 nonce
    ) private pure returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, callData, nonce)));
    }

    function createProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory callData
    ) external returns (uint256, uint256) {
        if (!isMember[msg.sender]) {
            revert NotAMember();
        }
        if (targets.length == 0) {
            revert InvalidArguments("zero length");
        }
        if (targets.length != values.length) {
            revert InvalidArguments("array length mismatch");
        }
        if (values.length != callData.length) {
            revert InvalidArguments("array length mismatch");
        }
        if (targets.length != callData.length) {
            revert InvalidArguments("array length mismatch");
        }

        uint256 proposalId = hashProposal(
            targets,
            values,
            callData,
            proposalCounterId
        );

        Proposal storage proposal = proposals[proposalId];
        proposal.nonce = proposalCounterId++;
        proposal.startTime = block.timestamp;
        proposal.endTime = block.timestamp + VOTING_WINDOW;
        proposal.yesVotes = 0;
        proposal.noVotes = 0;
        proposal.totalMembersAtTimeOfCreation = currentMember;
        proposal.creator = msg.sender;
        proposal.executed = false;

        emit ProposalCreated(proposalId, proposalCounterId);

        return (proposalId, proposalCounterId);
    }

    function vote(uint256 proposalId, bool support) external {
        if (isMember[msg.sender]) {
            revert NotAMember();
        }

        Proposal storage proposal = proposals[proposalId];
        if (proposal.nonce == 0) {
            revert InvalidProposal("Proposal does not exists");
        }

        if (
            block.timestamp < proposal.startTime ||
            block.timestamp > proposal.endTime
        ) {
            revert InvalidProposal("Voting period closed");
        }

        if (hasVoted[msg.sender][proposalId]) {
            revert InvalidProposal("Already voted");
        }

        if (joinedAt[msg.sender] > proposal.startTime) {
            revert InvalidProposal("Joined after Proposal creation");
        }
        if (proposal.executed) {
            revert InvalidProposal("Proposal already executed");
        }
        hasVoted[msg.sender][proposalId] = true;

        uint256 power = votingPower[msg.sender];
        if (support) {
            proposal.yesVotes += power;
        } else {
            proposal.noVotes += power;
        }
    }

    function isProposalPassed(uint256 proposalId) private view returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        if (block.timestamp <= proposal.endTime) {
            return false;
        }
        uint256 totalVotes = proposal.yesVotes + proposal.noVotes;
        uint256 quorum = (proposal.totalMembersAtTimeOfCreation * 25) / 100;

        if (totalVotes < quorum) {
            return false;
        }
        return proposal.yesVotes > proposal.noVotes;
    }

    function executeProposal(
        uint256 proposalId,
        address[] memory targets, 
        uint256[] memory values,
        bytes[] memory callData
    ) external {
        Proposal storage proposal = proposals[proposalId];

        uint256 expectedProposalId = hashProposal(
            targets,
            values,
            callData,
            proposal.nonce
        );

        if (proposal.executed) {
            revert InvalidProposal("Already executed");
        }
        if (!isProposalPassed(proposalId)) {
            revert InvalidProposal("Proposal is not passed");
        }
        if (proposalId != expectedProposalId) {
            revert InvalidProposal("Proposal contents mismatch");
        }

        proposal.executed = true;
        votingPower[proposal.creator]++;

        for (uint i = 0; i < targets.length; i++) {
            (bool success, ) = targets[i].call{value: values[i]}(callData[i]);
            if (!success) {
                revert("Execution failed");
            }
        }
        if(address(this).balance >= 5 ether){
            (bool success, ) = msg.sender.call{value: 0.01 ether}("");
            if(!success){
                revert ExternalCallFailed();
            }
        }
    }

    error InvalidFee();
    error AlreadyMember();
    error NotAMember();
    error InvalidArguments(string reason);
    error InvalidProposal(string reason);
    error ExternalCallFailed();    
}

