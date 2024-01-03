#[starknet::interface]
trait ICrowdfund<TState> {
    fn launch(ref self: TState, target: u256);
    fn pledge(ref self: TState, campaign_id: u256, amount: u256);
    fn unpledge(ref self: TState, campaign_id: u256, amount: u256);
    fn claim(ref self: TState, campaign_id: u256);
}