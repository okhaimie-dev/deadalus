use starknet::ContractAddress;

const THREAD_CREATOR: felt252 = selector!("THREAD_CREATOR");
const DONOR: felt252 = selector!("DONOR");
const VALIDATOR: felt252 = selector!("VALIDATOR");

// Campaign struct for crowdfunding.
#[derive(Drop, Serde, Copy, starknet::Store)]
struct Campaign {
    campaign_id: u256,
    creator: ContractAddress,
    target: u256,
    // Total amount pledged.
    pledged: u256,
    claimed: bool
}

#[starknet::contract]
mod Crowdfund {
    use openzeppelin::access::accesscontrol::AccessControlComponent;
    use openzeppelin::access::accesscontrol::DEFAULT_ADMIN_ROLE;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use super::{THREAD_CREATOR, DONOR, VALIDATOR, Campaign};
    use deadalus::crowdfund::ICrowdfund;

    component!(path: AccessControlComponent, storage: accesscontrol, event: AccessControlEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // AccessControl
    #[abi(embed_v0)]
    impl AccessControlImpl =
        AccessControlComponent::AccessControlImpl<ContractState>;
    impl AccessControlInternalImpl = AccessControlComponent::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        token: IERC20Dispatcher,
        last_campaign_id: u256,
        campaigns: LegacyMap<u256, Campaign>,
        pledged_amount: LegacyMap<(u256, ContractAddress), u256>,
        #[substorage(v0)]
        accesscontrol: AccessControlComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Launch: Launch,
        Pledge: Pledge,
        Unpledge: Unpledge,
        Claim: Claim,
        #[flat]
        AccessControlEvent: AccessControlComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    // Emitted for Launch event.
    #[derive(Drop, starknet::Event)]
    struct Launch {
        campaign_id: u256,
        creator: ContractAddress,
        target: u256
    }

    // Emitted for Pledge event.
    #[derive(Drop, starknet::Event)]
    struct Pledge {
        campaign_id: u256,
        caller: ContractAddress,
        amount: u256
    }

    // Emitted for Unpledge event.
    #[derive(Drop, starknet::Event)]
    struct Unpledge {
        campaign_id: u256,
        caller: ContractAddress,
        amount: u256
    }

    // Emitted for Claim event.
    #[derive(Drop, starknet::Event)]
    struct Claim {
        campaign_id: u256,
        creator: ContractAddress,
        amount: u256
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        token: ContractAddress,
        admin: ContractAddress
    ) {
        // Crowdfund token initialization
        self.token.write(IERC20Dispatcher { contract_address: token });

        // AccessControl-related initialization
        self.accesscontrol.initializer();
        self.accesscontrol._grant_role(DEFAULT_ADMIN_ROLE, admin);
    }

    #[abi(embed_v0)]
    impl Crowdfund of ICrowdfund<ContractState> {
        fn launch(ref self: ContractState, target:u256) {
            let new_campaign_id: u256 = self.last_campaign_id.read() + 1;
            let caller = get_caller_address();
            let new_campaign = Campaign {
                campaign_id: new_campaign_id, target: target, creator: caller, claimed: false, pledged: 0
            };
            self.campaigns.write(new_campaign_id, new_campaign);
            self.last_campaign_id.write(new_campaign_id);
            self.emit(Launch { campaign_id: new_campaign_id, target: target, creator: caller });
        }

        fn pledge(ref self: ContractState, campaign_id: u256, amount: u256) {
            let caller = get_caller_address();
            let this = get_contract_address();

            assert(self.last_campaign_id.read() <= campaign_id, 'no campaign_id found');

            let mut current_campaign = self.campaigns.read(campaign_id);
            assert(current_campaign.claimed == false, 'already claimed');

            let token: IERC20Dispatcher = self.token.read();

            current_campaign.pledged += amount;
            let current_pledged_amount = self.pledged_amount.read((campaign_id, caller));
            self.pledged_amount.write((campaign_id, caller), amount + current_pledged_amount);
            self.campaigns.write(campaign_id, current_campaign);
            token.transfer_from(caller, this, amount);

            self.emit(Pledge { campaign_id: campaign_id, caller: caller, amount: amount });
        }

        fn unpledge(ref self: ContractState, campaign_id: u256, amount: u256) {
            let caller = get_caller_address();
            let this = get_contract_address();

            assert(self.last_campaign_id.read() <= campaign_id, 'no campaign_id found');

            let mut current_campaign = self.campaigns.read(campaign_id);
            assert(self.last_campaign_id.read() <= campaign_id, 'no campaign_id found');
            assert(current_campaign.claimed == false, 'already claimed');

            let current_pledged_amount = self.pledged_amount.read((campaign_id, caller));
            assert(current_pledged_amount >= amount, 'pledged amount not enough');

            let token: IERC20Dispatcher = self.token.read();

            current_campaign.pledged -= amount;
            self.pledged_amount.write((campaign_id, caller), current_pledged_amount - amount);
            self.campaigns.write(campaign_id, current_campaign);
            token.transfer(caller, amount);

            self.emit(Unpledge { campaign_id: campaign_id, caller: caller, amount: amount });
        }

        fn claim(ref self: ContractState, campaign_id: u256) {
            let caller = get_caller_address();
            let this = get_contract_address();

            assert(self.last_campaign_id.read() <= campaign_id, 'no campaign_id found');

            let mut current_campaign = self.campaigns.read(campaign_id);
            assert(current_campaign.creator == caller, 'only owner allowed');
            assert(current_campaign.claimed == false, 'already claimed');

            let token: IERC20Dispatcher = self.token.read();

            current_campaign.claimed = true;
            self.campaigns.write(campaign_id, current_campaign);
            token.transfer(caller, current_campaign.pledged);

            self.emit(Claim { campaign_id: campaign_id, creator: caller, amount: current_campaign.pledged });
        }
    }
}