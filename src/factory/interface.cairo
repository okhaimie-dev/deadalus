use openzeppelin::token::erc20::ERC20ABIDispacther;
use starknet::ContractAddress;

#[starknet::interface]
trait IFactory<TContractState> {
    /// Creates a new Property contract with the given parameters.
    fn create_property() -> ContractAddress;
}