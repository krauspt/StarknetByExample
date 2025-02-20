// ANCHOR: contract
#[starknet::contract]
mod SwitchContract {
    use components::switchable::switchable_component;

    component!(path: switchable_component, storage: switch, event: SwitchableEvent);

    #[abi(embed_v0)]
    impl SwitchableImpl = switchable_component::Switchable<ContractState>;
    impl SwitchableInternalImpl = switchable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        switch: switchable_component::Storage,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.switch._off();
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        SwitchableEvent: switchable_component::Event,
    }
}
// ANCHOR_END: contract

#[cfg(test)]
mod tests {
    use components::switchable::switchable_component::InternalTrait;
    use components::switchable::ISwitchable;

    use core::starknet::storage::StorageMemberAccessTrait;
    use super::SwitchContract;

    fn STATE() -> SwitchContract::ContractState {
        SwitchContract::contract_state_for_testing()
    }

    #[test]
    #[available_gas(2000000)]
    fn test_init() {
        let state = STATE();
        assert(state.value() == false, 'The switch should be off');
    }

    #[test]
    #[available_gas(2000000)]
    fn test_switch() {
        let mut state = STATE();

        state.switch();
        assert(state.value() == true, 'The switch should be on');

        state.switch();
        assert(state.value() == false, 'The switch should be off');
    }

    #[test]
    #[available_gas(2000000)]
    fn test_value() {
        let mut state = STATE();
        assert(state.value() == state.switch.switchable_value.read(), 'Wrong value');

        state.switch.switch();
        assert(state.value() == state.switch.switchable_value.read(), 'Wrong value');
    }

    #[test]
    #[available_gas(2000000)]
    fn test_internal_off() {
        let mut state = STATE();

        state.switch._off();
        assert(state.value() == false, 'The switch should be off');

        state.switch();
        state.switch._off();
        assert(state.value() == false, 'The switch should be off');
    }
}
