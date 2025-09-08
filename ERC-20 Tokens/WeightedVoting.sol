// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

error TokensClaimed();
error AllTokensClaimed();
error NoTokensHeld();
error QuorumTooHigh(uint256 proposed);
error AlreadyVoted();
error VotingClosed();

contract WeightedVoting is ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant maxSupply = 1_000_000;
    uint256 public constant claimAmount = 100;
    uint256 public mintedSupply;

    mapping(address => bool) public claimed;

    enum Vote {
        AGAINST,
        FOR,
        ABSTAIN
    }

    struct Issue {
        EnumerableSet.AddressSet voters; // must be first per spec
        string issueDesc;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        uint256 totalVotes;
        uint256 quorum;
        bool passed;
        bool closed;
    }

    // A view-friendly struct to return from getIssue (EnumerableSet can't be returned)
    struct IssueView {
        address[] voters;
        string issueDesc;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        uint256 totalVotes;
        uint256 quorum;
        bool passed;
        bool closed;
    }

    // <-- changed to private to avoid the compiler error
    Issue[] private issues;

    constructor() ERC20("WeightedVoting", "WVT") {
        // Burn/occupy zero index: push a default issue and mark it closed
        issues.push();
        Issue storage i0 = issues[0];
        i0.issueDesc = "";
        i0.quorum = 0;
        i0.passed = false;
        i0.closed = true;
        // mintedSupply remains 0; tokens will be minted via claim()
    }

    /// @notice Claim 100 tokens once per address until maxSupply is reached
    function claim() external {
        if (claimed[msg.sender]) revert TokensClaimed();
        if (mintedSupply >= maxSupply) revert AllTokensClaimed();

        // ensure we don't exceed maxSupply
        if (mintedSupply + claimAmount > maxSupply) revert AllTokensClaimed();

        claimed[msg.sender] = true;
        mintedSupply += claimAmount;
        _mint(msg.sender, claimAmount);
    }

    /// @notice Create a new issue. Only token holders (balance > 0) can create issues.
    /// @param _desc description for issue
    /// @param _quorum number of votes required to close the issue
    /// @return index of newly created issue
    function createIssue(string calldata _desc, uint256 _quorum) external returns (uint256) {
        // Per tests: check holder status BEFORE checking quorum bounds
        if (balanceOf(msg.sender) == 0) revert NoTokensHeld();

        // Ensure quorum is not larger than total tokens in supply (current totalSupply)
        uint256 totalTokens = totalSupply();
        if (_quorum > totalTokens) revert QuorumTooHigh(_quorum);

        issues.push();
        uint256 idx = issues.length - 1;
        Issue storage it = issues[idx];
        it.issueDesc = _desc;
        it.quorum = _quorum;
        it.passed = false;
        it.closed = false;
        return idx;
    }

    /// @notice Return data for an issue in a returnable struct (IssueView)
    function getIssue(uint256 _id) external view returns (IssueView memory) {
        require(_id < issues.length, "Invalid issue id");
        Issue storage it = issues[_id];

        uint256 voterCount = it.voters.length();
        address[] memory vs = new address[](voterCount);
        for (uint256 i = 0; i < voterCount; i++) {
            vs[i] = it.voters.at(i);
        }

        return IssueView({
            voters: vs,
            issueDesc: it.issueDesc,
            votesFor: it.votesFor,
            votesAgainst: it.votesAgainst,
            votesAbstain: it.votesAbstain,
            totalVotes: it.totalVotes,
            quorum: it.quorum,
            passed: it.passed,
            closed: it.closed
        });
    }

    /// @notice Vote on an issue. Must vote all tokens (current token balance).
    /// @param _issueId id of the issue
    /// @param _vote choice: AGAINST | FOR | ABSTAIN
    function vote(uint256 _issueId, Vote _vote) public {
        require(_issueId < issues.length, "Invalid issue id");
        Issue storage it = issues[_issueId];

        if (it.closed) revert VotingClosed();

        if (it.voters.contains(msg.sender)) revert AlreadyVoted();

        uint256 voterBalance = balanceOf(msg.sender);
        if (voterBalance == 0) revert NoTokensHeld();

        // add vote weight
        if (_vote == Vote.FOR) {
            it.votesFor += voterBalance;
        } else if (_vote == Vote.AGAINST) {
            it.votesAgainst += voterBalance;
        } else {
            // ABSTAIN
            it.votesAbstain += voterBalance;
        }

        it.totalVotes += voterBalance;
        it.voters.add(msg.sender);

        // Check quorum reached
        if (it.totalVotes >= it.quorum && it.quorum > 0) {
            it.closed = true;
            it.passed = (it.votesFor > it.votesAgainst);
        }
    }

    // Public helper to get number of issues
    function issuesCount() external view returns (uint256) {
        return issues.length;
    }
}

