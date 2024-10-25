// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract ProposalVote {

    enum PropsStatus{ None, Created, Pending, Accepted, Rejected }

    struct Proposal {
        string title;
        string description;
        uint16 voteCount;
        address[] voters;
        uint16 quorum;
        PropsStatus status;
    }

    mapping (address voter => mapping (uint8 indexOfProps => bool)) hasVoted;
    Proposal[] public proposals;

    // events
    event ProposalCreated(string indexed title, uint16 quorum);
    event ProposalVoted(string indexed title, address indexed voter);
    event ProposalActive(string indexed title, uint16 voteCount);
    event ProposalApproved(string indexed title, uint16 voteCount);
    event ProposalRejected(string indexed title, uint16 voteCount);

    // Modifier to check if sender is a valid address
    modifier validAddress() {
        require(msg.sender != address(0), "Zero address is not allowed");
        _;
    }

    function createProposal(string memory _title, string memory _desc, uint16 _quorum) external validAddress {
        require(bytes(_title).length > 0, "Proposal must have a title");
        require(_quorum > 0, "Quorum must be greater than zero");

        Proposal memory newProposal;
        newProposal.title = _title;
        newProposal.description = _desc;
        newProposal.quorum = _quorum;
        newProposal.status = PropsStatus.Created;

        proposals.push(newProposal);

        emit ProposalCreated(_title, _quorum);
    }

    function voteOnProposal(uint8 _index) external validAddress {
        require(_index < proposals.length, "Out of bound!");
        require(!hasVoted[msg.sender][_index], "You've already voted");

        Proposal storage currentProposal = proposals[_index];

        require(currentProposal.status != PropsStatus.Accepted, "This proposal has already been accepted");
        require(currentProposal.status != PropsStatus.Rejected, "This proposal has already been rejected");

        currentProposal.voteCount += 1;
        currentProposal.voters.push(msg.sender);
        hasVoted[msg.sender][_index] = true;

        emit ProposalVoted(currentProposal.title, msg.sender);

        if (currentProposal.voteCount >= currentProposal.quorum) {
            currentProposal.status = PropsStatus.Accepted;
            emit ProposalApproved(currentProposal.title, currentProposal.voteCount);
        } else {
            currentProposal.status = PropsStatus.Pending;
            emit ProposalActive(currentProposal.title, currentProposal.voteCount);
        }
    }

    function getAllProposals () external view returns (Proposal[] memory) {
        return proposals;
    }

    function getProposal(uint8 _index) external view validAddress returns (
        string memory title_, string memory desc_, uint16 voteCount_, address[] memory voters_, uint16 quorum_, PropsStatus status_
    ) {
        require(_index < proposals.length, "Out of bound!");

        Proposal memory currentProposal = proposals[_index];

        return (
            currentProposal.title,
            currentProposal.description,
            currentProposal.voteCount,
            currentProposal.voters,
            currentProposal.quorum,
            currentProposal.status
        );
    }

    // Optional: function to reject a proposal if not enough votes
    function rejectProposal(uint8 _index) external validAddress {
        require(_index < proposals.length, "Out of bound!");
        Proposal storage currentProposal = proposals[_index];

        require(currentProposal.status != PropsStatus.Accepted, "Proposal already accepted");
        require(currentProposal.status != PropsStatus.Rejected, "Proposal already rejected");

        if (currentProposal.voteCount < currentProposal.quorum) {
            currentProposal.status = PropsStatus.Rejected;
            emit ProposalRejected(currentProposal.title, currentProposal.voteCount);
        }
    }
}
