use candid::{CandidType, Nat, Principal};

pub type OrderId = u32;

#[allow(non_snake_case)]
#[derive(CandidType, Clone)]
pub struct Order {
    pub id: OrderId,
    pub owner: Principal,
    pub from: Principal,
    pub fromAmount: Nat,
    pub to: Principal,
    pub toAmount: Nat,
}

#[derive(CandidType)]
pub struct Balance {
    pub owner: Principal,
    pub token: Principal,
    pub amount: Nat,
}

#[derive(CandidType, Deserialize)]
pub enum Error {
    Unauthorized,
    InvalidTokenId,
<<<<<<< HEAD
=======
    Insufficientremaining,
>>>>>>> 59f4afe84ac90981aa99e16d80cb0a6c0e6921a8
    InvalidLevel,
    ZeroAddress,
    Other,
    BalanceLow,
    TransferFailure,
}

#[derive(CandidType, Deserialize)]
pub enum InterfaceId {
    Approval,
    TransactionHistory,
    Mint,
    Burn,
    TransferNotification,
}
