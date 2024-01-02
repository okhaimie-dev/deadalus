use starknet::ContractAddress;

#[starknet::interface]
trait IDAO<TContractState> {

}

#[starknet::interface]
trait ISIP4824<TContractState> {
    /// Returns a distinct Uniform Resource Identifier (URI) to a JSON object. This JSON file splits into four URIs: membersURI, proposalsURI, activityLogURI, and governanceURI. The governanceURI should point to a flatfile, normatively a .md file. Each of the JSON files named above can be statically hosted or dynamically-generated.
    fn daoURI(ref self: TContractState) -> felt252;
}