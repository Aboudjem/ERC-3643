/**
 * ERC-3643 Raptor — TypeScript type declarations for the published artifacts.
 */

export interface ContractArtifact {
  readonly _format: string;
  readonly contractName: string;
  readonly sourceName: string;
  readonly abi: ReadonlyArray<Record<string, unknown>>;
  readonly bytecode: string;
  readonly deployedBytecode: string;
  readonly linkReferences: Record<string, unknown>;
  readonly deployedLinkReferences: Record<string, unknown>;
}

export interface InterfaceArtifact {
  readonly _format: string;
  readonly contractName: string;
  readonly sourceName: string;
  readonly abi: ReadonlyArray<Record<string, unknown>>;
}

export interface Contracts {
  Token?: ContractArtifact;
  IdentityRegistry?: ContractArtifact;
  IdentityRegistryStorage?: ContractArtifact;
  ClaimTopicsRegistry?: ContractArtifact;
  ClaimIssuersRegistry?: ContractArtifact;
  BasicCompliance?: ContractArtifact;
}

export interface Interfaces {
  IToken?: InterfaceArtifact;
  IIdentityRegistry?: InterfaceArtifact;
  IIdentityRegistryStorage?: InterfaceArtifact;
  IClaimTopicsRegistry?: InterfaceArtifact;
  IClaimIssuersRegistry?: InterfaceArtifact;
  ICompliance?: InterfaceArtifact;
}

export declare const contracts: Contracts;
export declare const interfaces: Interfaces;

declare const _default: {
  contracts: Contracts;
  interfaces: Interfaces;
};

export default _default;
