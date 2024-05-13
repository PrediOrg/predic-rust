import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type Error = { 'ZeroAddress' : null } |
  { 'TransferFailure' : null } |
  { 'InvalidTokenId' : null } |
<<<<<<< HEAD
=======
  { 'Insufficientremaining' : null } |
>>>>>>> 59f4afe84ac90981aa99e16d80cb0a6c0e6921a8
  { 'Unauthorized' : null } |
  { 'BalanceLow' : null } |
  { 'Other' : null } |
  { 'InvalidLevel' : null };
export interface InitArgs {
  'buy_prices' : BigUint64Array | bigint[],
  'logo' : [] | [LogoResult],
  'name' : string,
  'custodians' : [] | [Array<Principal>],
  'ledger' : Principal,
<<<<<<< HEAD
=======
  'remaing' : BigUint64Array | bigint[],
>>>>>>> 59f4afe84ac90981aa99e16d80cb0a6c0e6921a8
  'symbol' : string,
}
export type InterfaceId = { 'Burn' : null } |
  { 'Mint' : null } |
  { 'Approval' : null } |
  { 'TransactionHistory' : null } |
  { 'TransferNotification' : null };
export interface LogoResult { 'data' : string, 'logo_type' : string }
export interface MintResult {
  'id' : bigint,
  'token_id' : bigint,
  'level' : number,
}
export type Result = { 'Ok' : bigint } |
  { 'Err' : Error };
export type Result_1 = { 'Ok' : MintResult } |
  { 'Err' : Error };
export type Result_2 = { 'Ok' : Principal } |
  { 'Err' : Error };
export type Result_3 = { 'Ok' : BigUint64Array | bigint[] } |
  { 'Err' : Error };
export type Result_4 = { 'Ok' : null } |
  { 'Err' : Error };
export interface _SERVICE {
  'approveDip721' : ActorMethod<[Principal, bigint], Result>,
  'balanceOfDip721' : ActorMethod<[Principal], bigint>,
  'burnDip721' : ActorMethod<[bigint], Result>,
  'buy' : ActorMethod<[number], Result_1>,
  'getApprovedDip721' : ActorMethod<[bigint], Result_2>,
  'getDepositAddress' : ActorMethod<[], Uint8Array | number[]>,
<<<<<<< HEAD
  'getDepositeBalance' : ActorMethod<[Principal], bigint>,
  'getPrices' : ActorMethod<[], BigUint64Array | bigint[]>,
=======
  'getPrices' : ActorMethod<[], BigUint64Array | bigint[]>,
  'getRemaing' : ActorMethod<[], BigUint64Array | bigint[]>,
>>>>>>> 59f4afe84ac90981aa99e16d80cb0a6c0e6921a8
  'isApprovedForAllDip721' : ActorMethod<[Principal], boolean>,
  'isCustodian' : ActorMethod<[Principal], boolean>,
  'nameDip721' : ActorMethod<[], string>,
  'ownerNfs' : ActorMethod<[Principal], Result_3>,
  'ownerOfDip721' : ActorMethod<[bigint], Result_2>,
  'safeTransferFromDip721' : ActorMethod<
    [Principal, Principal, bigint],
    Result
  >,
  'safeTransferFromNotifyDip721' : ActorMethod<
    [Principal, Principal, bigint, Uint8Array | number[]],
    Result
  >,
  'setApprovalForAllDip721' : ActorMethod<[Principal, boolean], Result>,
  'setBuyPrice' : ActorMethod<[BigUint64Array | bigint[]], Result_4>,
  'setCustodian' : ActorMethod<[Principal, boolean], Result_4>,
  'setLogo' : ActorMethod<[[] | [LogoResult]], Result_4>,
  'setName' : ActorMethod<[string], Result_4>,
<<<<<<< HEAD
=======
  'setRemaing' : ActorMethod<[BigUint64Array | bigint[]], Result_4>,
>>>>>>> 59f4afe84ac90981aa99e16d80cb0a6c0e6921a8
  'setSymbol' : ActorMethod<[string], Result_4>,
  'supportedInterfacesDip721' : ActorMethod<[], Array<InterfaceId>>,
  'symbolDip721' : ActorMethod<[], string>,
  'totalSupplyDip721' : ActorMethod<[], bigint>,
  'transferFromDip721' : ActorMethod<[Principal, Principal, bigint], Result>,
  'transferFromNotifyDip721' : ActorMethod<
    [Principal, Principal, bigint, Uint8Array | number[]],
    Result
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
