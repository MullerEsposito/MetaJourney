use starknet::ContractAddress;

#[starknet::interface]
trait PlayerTrait<T> {
    fn get_player(self: @T, player_address: ContractAddress) -> MetaJourneyGame::Player;
    fn get_player_achievements(self: @T, player_address: ContractAddress) -> Felt252Dict<MetaJourneyGame::Achievement>;
    fn set_player_achievement(ref self: T, player_address: ContractAddress, achievement: Achievement);
    fn check_player_achievement(self: @T, player_address: ContractAddress, achievement_id: u32) -> bool;
}

#[starknet::interface]
trait AchievementTrait<T> {
    fn get_achievement(self: @T, achievement_id: u32) -> Achievement;
    fn set_achievement(ref self: T, achievement_id: u32, description: felt252, xp_quantity: u8);
}

#[starknet::contract]
pub mod MetaJourneyGame {

    #[storage]
    struct Storage {
        players: Felt252Dict<Player>,
        achievements: Felt252Dict<Achievement>
    }

    #[constructor]
    fn constructor(ref self: ContractState) {

    }

    #[derive(Drop, starknet::Event)]
    struct Player {
        player_address: ContractAddress,
        achievements: Felt252Dict<Achievement>
    }

    #[derive(Drop, starknet::Event)]
    struct Achievement {
        id: u32,
        description: felt252,
        xp_quantity: u8
    }

    #[abi(embed_v0)]
    impl PlayerImpl of PlayerTrait {
        fn get_player(self: ContractState, player_address: ContractAddress) -> Player {
            self.players.get(player_address)
        }

        fn get_player_achievements(self: ContractState, player_address: ContractAddress) -> Felt252Dict<Achievement> {
            let player_found = get_player(player_address);
            player_found.achievements
        }

        fn set_player_achievement(ref self: ContractState, player_address: ContractAddress, achievement: Achievement) {
            let mut player_found = get_player(player_address);
            player_found.achievements.insert(achievement.id , achievement);
        }

        fn check_player_achievement(self: ContractState, player_address: ContractAddress, achievement_id: u32) -> bool {
            let player_found = get_player(player_address);
            let isAchievementChecked = if player_found.achievements.get(achievement_id) { true } else { false };
            isAchievementChecked
        }
    }

    #[abi(embed_v0)]
    impl AchievementImpl of AchievementTrait {
        fn get_achievement(self: ContractState, achievement_id: u32) -> Achievement {
            self.achievements.get(achievement_id)
        }

        fn set_achievement(ref self: ContractState, achievement_id: u32, description: felt252, xp_quantity: u8) {
            let achievement: Achievement = Achievement { id: achievement_id, description: description, xp_quantity: xp_quantity };
            self.achievements.insert(achievement_id, achievement);
        }
    }
}