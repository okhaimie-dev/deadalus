const THREAD_CREATOR: felt252 = selector!("THREAD_CREATOR");
const DONOR: felt252 = selector!("DONOR");
const VALIDATOR: felt252 = selector!("VALIDATOR");

// Campaign struct for crowdfunding.
#[derive(Drop, Serde, Copy, starknet::Store)]
struct Campaign {
    creator: ContractAddress,
    target: u128,
    // Total amount pledged.
    pledged: u128,
    start: felt252,
    deadline: u128,
    claimed: bool
}

#[starknet::contract]
mod Crowdfund {
    use openzeppelin::access::accesscontrol::AccessControlComponent;
    use openzeppelin::access::accesscontrol::DEFAULT_ADMIN_ROLE;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc20::ERC20Component;
    use starknet::ContractAddress;
    use super::{THREAD_CREATOR, DONOR, VALIDATOR, Campaign};

    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    // AccessControl
    #[abi(embed_v0)]
    impl AccessControlImpl =
        AccessControlComponent::AccessControlImpl<ContractState>;
    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    // ERC20
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Launch: Launch,
        Cancel: Cancel,
        Pledge: Pledge,
        Unpledge: Unpledge,
        Claim: Claim,
        Refund: Refund,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    // Emitted for Launch event.
    #[derive(Drop, starknet::Event)]
    struct Launch {
        id: u128,
        creator: ContractAddress,
        target: u128,
        start: felt252,
        deadline: u128,
    }

    // Emitted for Cancel event.
    #[derive(Drop, starknet::Event)]
    struct Cancel {
        id: u128
    }

    // Emitted for Pledge event.
    #[derive(Drop, starknet::Event)]
    struct Pledge {
        id: u128,
        caller: ContractAddress,
        amount: u128
    }

    // Emitted for Unpledge event.
    #[derive(Drop, starknet::Event)]
    struct Unpledge {
        id: u128,
        caller: ContractAddress,
        amount: u128
    }

    // Emitted for Claim event.
    #[derive(Drop, starknet::Event)]
    struct Claim {
        id: u128
    }

    // Emitted for Refund event.
    #[derive(Drop, starknet::Event)]
    struct Refund {
        id: u128,
        caller: ContractAddress,
        amount: u128
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        admin: ContractAddress
    ) {
        // ERC20-related initialization
        self.erc20.initializer(name, symbol);

        // AccessControl-related initialization
        self.accesscontrol.initializer();
        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, admin);
    }

    /// This function can only be called by a minter.
    #[external(v0)]
    fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
        self.accesscontrol.assert_only_role(MINTER_ROLE);
        self.erc20._mint(recipient, amount);
    }
}