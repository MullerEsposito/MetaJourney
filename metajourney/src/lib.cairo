use starknet::ContractAddress;
use meta_journey_game::Player;
use meta_journey_game::Achievement;


#[starknet::interface]
trait PlayerTrait<T> {
    fn create_new_player(ref self: T, player_address: ContractAddress);
    fn get_player(self: @T, player_address: ContractAddress) -> Player;
    fn get_player_achievements(self: @T, player_address: ContractAddress) -> LegacyMap::<u32::Achievement>;
    fn set_player_achievement(ref self: T, player_address: ContractAddress, achievement: Achievement);
    fn check_player_achievement(self: @T, player_address: ContractAddress, achievement_id: u32) -> bool;
}

// #[starknet::interface]
// trait AchievementTrait<T> {
//     fn get_achievement(self: @T, achievement_id: u32) -> Achievement;
//     fn set_achievement(ref self: T, achievement_id: u32, description: felt252, xp_quantity: u8);
// }

#[starknet::contract]
pub mod meta_journey_game {
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        players: LegacyMap::<ContractAddress::Player>,
        achievements: LegacyMap::<u32::Achievement>
    }

    #[constructor]
    fn constructor(ref self: ContractState) {

    }

    #[derive(Drop, Serde)]
    pub struct Player {
        player_address: ContractAddress,
        achievements: LegacyMap::<u32::Achievement>
    }

    #[derive(Drop, Serde)]
    pub struct Achievement {
        id: u32,
        description: felt252,
        xp_quantity: u8
    }

    #[abi(embed_v0)]
    impl PlayerImpl of super::PlayerTrait<ContractState> {
        fn create_new_player(ref self: ContractState, player_address: ContractAddress) {
            let created_player = Player { player_address: player_address, achievements: Default::default() };
            self.players.write(player_address, created_player);
        }

        fn get_player(self: @ContractState, player_address: ContractAddress) -> Player {
            self.players.read(player_address)
        }

        fn get_player_achievements(self: @ContractState, player_address: ContractAddress) -> LegacyMap<u32::Achievement> {
            let player_found = self.get_player(player_address);
            player_found.achievements
        }

        fn set_player_achievement(ref self: ContractState, player_address: ContractAddress, achievement: Achievement) {
            let mut player_found = self.get_player(player_address);
            player_found.achievements.write(achievement.id , achievement);
        }

        fn check_player_achievement(self: @ContractState, player_address: ContractAddress, achievement_id: u32) -> bool {
            let player_found = self.get_player(player_address);
            let isAchievementChecked = if player_found.achievements.read(achievement_id) { true } else { false };
            isAchievementChecked
        }
    }

    // #[abi(embed_v0)]
    // impl AchievementImpl of super::AchievementTrait<ContractState> {
    //     fn get_achievement(self: @T, achievement_id: u32) -> Achievement {
    //         self.achievements.read(achievement_id)
    //     }

    //     fn set_achievement(ref self: T, achievement_id: u32, description: felt252, xp_quantity: u8) {
    //         let _achievement: Achievement = Achievement { id: achievement_id, description: description, xp_quantity: xp_quantity };
    //         self.achievements.write(achievement_id, _achievement);
    //     }
    // }
}