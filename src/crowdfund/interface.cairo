#[starknet::interface]
trait ICrowdfund<TState> {
    fn launch(ref self: TState);
    fn pledge(ref self: TState, campaign_id: u128, amount: u128);
    fn unpledge(ref self: TState, campaign_id: u128, amount: u128);
    fn claim(ref self: TState, campaign_id: u128);
}