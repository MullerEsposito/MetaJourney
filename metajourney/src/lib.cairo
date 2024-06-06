use starknet::ContractAddress;
use meta_journey_game::Player;
use meta_journey_game::Achievement;
use core::dict::Felt252DictEntryTrait;
use alexandria_storage::list::{List, ListTrait};



#[starknet::interface]
trait PlayerTrait<T> {
    fn create_new_player(ref self: T, player_address: ContractAddress, player_name: felt252);
    fn get_player(self: @T, player_address: ContractAddress) -> Player;
    fn get_player_achievements(self: @T, player_address: ContractAddress) -> Array<Achievement>;
    fn set_player_achievement(ref self: T, player_address: ContractAddress, achievement: Achievement);
    fn check_player_achievement(self: @T, player_address: ContractAddress, achievement_id: u32) -> bool;
}

#[starknet::interface]
trait AchievementTrait<T> {
    fn get_achievement(self: @T, achievement_id: u32) -> Achievement;
    fn set_achievement(ref self: T, achievement_id: u32, description: felt252, xp_quantity: u8);
}

#[starknet::contract]
pub mod meta_journey_game {
    use core::result::ResultTrait;
use starknet::ContractAddress;
    use alexandria_storage::list::{List, ListTrait};


    #[storage]
    struct Storage {
        players: LegacyMap::<ContractAddress, Player>,
        achievement_per_player: LegacyMap::<ContractAddress, u32>,
        achievements: List<Achievement>,
        achievements_map: LegacyMap::<u32, Achievement>,
        achievements_per_player: LegacyMap::<ContractAddress, List<Achievement>>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct Player {
        player_address: ContractAddress,
        player_name: felt252
    }

    #[derive(Drop, Serde, Copy, starknet::Store)]
    pub struct Achievement {
        id: u32,
        description: felt252,
        xp_quantity: u8
    }

    #[abi(embed_v0)]
    impl PlayerImpl of super::PlayerTrait<ContractState> {
        fn create_new_player(ref self: ContractState, player_address: ContractAddress, player_name: felt252) {
            let created_player = Player { player_address: player_address, player_name: player_name };
            self.players.write(player_address, created_player);
        }

        fn get_player(self: @ContractState, player_address: ContractAddress) -> Player {
            self.players.read(player_address)
        }

        fn get_player_achievements(self: @ContractState, player_address: ContractAddress) -> Array<Achievement> {
            self.achievements_per_player.read(player_address).array().unwrap()
        }

        fn set_player_achievement(ref self: ContractState, player_address: ContractAddress, achievement: Achievement) {
            let mut achievements_of_player = self.achievements_per_player.read(player_address);
            self.achievement_per_player.write(player_address, achievement.id);
            
            achievements_of_player.append(achievement);
            self.achievements_per_player.write(player_address, achievements_of_player);
        }

        fn check_player_achievement(self: @ContractState, player_address: ContractAddress, achievement_id: u32) -> bool {
            let isAchievementChecked = if self.achievement_per_player.read(player_address) != 0 { true } else { false };
            isAchievementChecked
        }
    }

    #[abi(embed_v0)]
    impl AchievementImpl of super::AchievementTrait<ContractState> {
        fn set_achievement(ref self: ContractState, achievement_id: u32, description: felt252, xp_quantity: u8) {
            let _achievement: Achievement = Achievement { id: achievement_id, description: description, xp_quantity: xp_quantity };
            self.achievements_map.write(achievement_id, _achievement);

            let mut achievements = self.achievements.read();
            achievements.append(_achievement);
            
            self.achievements.write(achievements);
        }

        fn get_achievement(self: @ContractState, achievement_id: u32) -> Achievement {
            self.achievements_map.read(achievement_id)
        }

    }
}