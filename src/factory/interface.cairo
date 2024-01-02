use starknet::ContractAddress;

#[starknet::interface]
trait IFactory<TState> {
    /// Creates a new Property contract with the given parameters.
    fn create_property(ref self: TState) -> u256;
}