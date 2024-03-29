#[starknet::contract]
mod Factory {
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait;
    use openzeppelin::token::erc20::interface::{
        IERC20, ERC20ABIDispatcher, ERC20ABIDispatcherTrait
    };
    use poseidon::poseidon_hash_span;
    use starknet::SyscallResultTrait;
    use starknet::syscalls::deploy_syscall;
    use starknet::{
        ContractAddress, ClassHash, get_caller_address, get_contract_address, contract_address_const
    };
    use deadalus::factory::IFactory;

    // Components.
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PropertyCreated: PropertyCreated,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[derive(Drop, starknet::Event)]
    struct PropertyCreated {
        owner: ContractAddress,
        name: felt252,
        property_address: ContractAddress,
        property_id: u32,
    }

    #[storage]
    struct Storage {
        property_class_hash: ClassHash,
        deployed_properties: LegacyMap<ContractAddress, bool>,
        // Components.
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress
    ) {
        // Initialize the owner.
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl DeadalusPropertyFactoryImpl of IFactory<ContractState> {
        fn create_property(ref self: ContractState) -> u256 {
            let property_address = 52;

            property_address
        }
    }
}