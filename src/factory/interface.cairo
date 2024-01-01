use openzeppelin::token::erc20::interface::ERC20ABIDispatcher;
use starknet::ContractAddress;

#[starknet::interface]
trait IFactory<TContractState> {
    /// Creates a new Property contract with the given parameters.
    fn create_property(ref self: TContractState) -> u256;
}