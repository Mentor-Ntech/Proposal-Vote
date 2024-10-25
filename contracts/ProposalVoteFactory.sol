// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./ProposalVote.sol"; 

contract ProposalVoteFactory {
    
    ProposalVote[] public proposalVotes;
    
    mapping(address => ProposalVote[]) public ownerToProposals;

    event ProposalVoteCreated(address indexed owner, address indexed proposalVoteAddress);

    // Function to deploy a new instance of ProposalVote contract
    function createProposalVote(string[] memory _proposalTitles, string[] memory _descriptions, uint16[] memory _quorums) external {
        require(_proposalTitles.length == _descriptions.length && _proposalTitles.length == _quorums.length, "Input arrays length mismatch");

        ProposalVote newProposalVote = new ProposalVote();
        
        // Deploy a new instance and pass titles, descriptions, and quorums to ProposalVote constructor
        for (uint8 i = 0; i < _proposalTitles.length; i++) {
            newProposalVote.createProposal(_proposalTitles[i], _descriptions[i], _quorums[i]);
        }

        proposalVotes.push(newProposalVote);
        ownerToProposals[msg.sender].push(newProposalVote);

        emit ProposalVoteCreated(msg.sender, address(newProposalVote));
    }

    // Function to get all deployed ProposalVote instances
    function getDeployedProposalVotes() external view returns (ProposalVote[] memory) {
        return proposalVotes;
    }

    function getMyProposalVotes() external view returns (ProposalVote[] memory) {
        return ownerToProposals[msg.sender];
    }

    // Function to interact with a specific ProposalVote instance (e.g., vote on a proposal)
    function voteOnProposalInstance(uint8 factoryIndex, uint8 proposalIndex) external {
        require(factoryIndex < proposalVotes.length, "Invalid factory index");
        
        ProposalVote proposalVoteInstance = proposalVotes[factoryIndex];
        proposalVoteInstance.voteOnProposal(proposalIndex);
    }
}
