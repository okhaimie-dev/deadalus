#[starknet::interface]
trait ICrowdfund<TState> {
    // Function that creates a new campaign.
    fn launch(ref self: TState, target: u128, start: u128, end: u128);
    fn cancel(ref self: TState, campaign_id: u128);
    fn pledge(ref self: TState, campaign_id: u128, amount: u128);
    fn unpledge(ref self: TState, campaign_id: u128, amount: u128);
    fn withdraw(ref self: TState, campaign_id: u128);
    fn refund(ref self: TState, campaign_id: u128);
}