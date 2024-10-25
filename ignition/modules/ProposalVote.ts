import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ProposalVoteModule = buildModule("ProposalModule", (m) => {

  const ProposalVoteFactory = m.contract("ProposalVoteFactory");

  return { ProposalVoteFactory };

});

export default ProposalVoteModule;