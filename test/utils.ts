import { Wallet } from "ethers";

export const AGENT_ROLE: string =
  "0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709";
export const OWNER_ROLE: string =
  "0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e";

// keccak256(ADMIN_ROLE)
export const ADMIN_ROLE =
  "0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775";

// keccak256(TOKEN_ROLE)
export const TOKEN_ROLE =
  "0xa7197c38d9c4c7450c7f2cd20d0a17cbe7c344190d6c82a6b49a146e62439ae4";

export const accessControlRevert = (
  address: SignerWithAddress,
  role: string
) => {
  return `AccessControl: account ${address.address.toLowerCase()} is missing role ${role}`;
};
