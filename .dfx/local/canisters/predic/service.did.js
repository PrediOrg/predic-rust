export const idlFactory = ({ IDL }) => {
  const LogoResult = IDL.Record({ 'data' : IDL.Text, 'logo_type' : IDL.Text });
  const InitArgs = IDL.Record({
    'buy_prices' : IDL.Vec(IDL.Nat64),
    'logo' : IDL.Opt(LogoResult),
    'name' : IDL.Text,
    'custodians' : IDL.Opt(IDL.Vec(IDL.Principal)),
    'ledger' : IDL.Principal,
    'remaing' : IDL.Vec(IDL.Nat64),
    'symbol' : IDL.Text,
  });
  const Error = IDL.Variant({
    'ZeroAddress' : IDL.Null,
    'TransferFailure' : IDL.Null,
    'InvalidTokenId' : IDL.Null,
    'Insufficientremaining' : IDL.Null,
    'Unauthorized' : IDL.Null,
    'BalanceLow' : IDL.Null,
    'Other' : IDL.Null,
    'InvalidLevel' : IDL.Null,
  });
  const Result = IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : Error });
  const MintResult = IDL.Record({
    'id' : IDL.Nat,
    'token_id' : IDL.Nat64,
    'level' : IDL.Nat8,
  });
  const Result_1 = IDL.Variant({ 'Ok' : MintResult, 'Err' : Error });
  const Result_2 = IDL.Variant({ 'Ok' : IDL.Principal, 'Err' : Error });
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(IDL.Tuple(IDL.Text, IDL.Text)),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(IDL.Tuple(IDL.Text, IDL.Text)),
    'status_code' : IDL.Nat16,
  });
  const Result_3 = IDL.Variant({ 'Ok' : IDL.Vec(IDL.Nat64), 'Err' : Error });
  const Result_4 = IDL.Variant({ 'Ok' : IDL.Null, 'Err' : Error });
  const InterfaceId = IDL.Variant({
    'Burn' : IDL.Null,
    'Mint' : IDL.Null,
    'Approval' : IDL.Null,
    'TransactionHistory' : IDL.Null,
    'TransferNotification' : IDL.Null,
  });
  return IDL.Service({
    'approveDip721' : IDL.Func([IDL.Principal, IDL.Nat64], [Result], []),
    'balanceOfDip721' : IDL.Func([IDL.Principal], [IDL.Nat64], ['query']),
    'burnDip721' : IDL.Func([IDL.Nat64], [Result], []),
    'buy' : IDL.Func([IDL.Nat8], [Result_1], []),
    'getApprovedDip721' : IDL.Func([IDL.Nat64], [Result_2], ['query']),
    'getDepositAddress' : IDL.Func([], [IDL.Vec(IDL.Nat8)], ['query']),
    'getPrices' : IDL.Func([], [IDL.Vec(IDL.Nat64)], ['query']),
    'getRemaing' : IDL.Func([], [IDL.Vec(IDL.Nat64)], ['query']),
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'isApprovedForAllDip721' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'isCustodian' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'nameDip721' : IDL.Func([], [IDL.Text], ['query']),
    'ownerNfs' : IDL.Func([IDL.Principal], [Result_3], ['query']),
    'ownerOfDip721' : IDL.Func([IDL.Nat64], [Result_2], ['query']),
    'safeTransferFromDip721' : IDL.Func(
        [IDL.Principal, IDL.Principal, IDL.Nat64],
        [Result],
        [],
      ),
    'safeTransferFromNotifyDip721' : IDL.Func(
        [IDL.Principal, IDL.Principal, IDL.Nat64, IDL.Vec(IDL.Nat8)],
        [Result],
        [],
      ),
    'setApprovalForAllDip721' : IDL.Func(
        [IDL.Principal, IDL.Bool],
        [Result],
        [],
      ),
    'setBuyPrice' : IDL.Func([IDL.Vec(IDL.Nat64)], [Result_4], []),
    'setCustodian' : IDL.Func([IDL.Principal, IDL.Bool], [Result_4], []),
    'setLogo' : IDL.Func([IDL.Opt(LogoResult)], [Result_4], []),
    'setName' : IDL.Func([IDL.Text], [Result_4], []),
    'setRemaing' : IDL.Func([IDL.Vec(IDL.Nat64)], [Result_4], []),
    'setSymbol' : IDL.Func([IDL.Text], [Result_4], []),
    'supportedInterfacesDip721' : IDL.Func(
        [],
        [IDL.Vec(InterfaceId)],
        ['query'],
      ),
    'symbolDip721' : IDL.Func([], [IDL.Text], ['query']),
    'totalSupplyDip721' : IDL.Func([], [IDL.Nat64], ['query']),
    'transferFromDip721' : IDL.Func(
        [IDL.Principal, IDL.Principal, IDL.Nat64],
        [Result],
        [],
      ),
    'transferFromNotifyDip721' : IDL.Func(
        [IDL.Principal, IDL.Principal, IDL.Nat64, IDL.Vec(IDL.Nat8)],
        [Result],
        [],
      ),
  });
};
export const init = ({ IDL }) => {
  const LogoResult = IDL.Record({ 'data' : IDL.Text, 'logo_type' : IDL.Text });
  const InitArgs = IDL.Record({
    'buy_prices' : IDL.Vec(IDL.Nat64),
    'logo' : IDL.Opt(LogoResult),
    'name' : IDL.Text,
    'custodians' : IDL.Opt(IDL.Vec(IDL.Principal)),
    'ledger' : IDL.Principal,
    'remaing' : IDL.Vec(IDL.Nat64),
    'symbol' : IDL.Text,
  });
  return [InitArgs];
};
