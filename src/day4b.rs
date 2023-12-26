use std::fs;

fn main() {
    let data = fs::read_to_string("data/day4").unwrap();
    let splitted: Vec<&str> = data.split("\n").filter(|x| x.len() > 0).collect();
    let mut multiplier = vec![1usize; splitted.len()];

    for (i, line) in splitted.iter().enumerate() {
        let (_, numbers) = line.split_once(":").unwrap();
        let (wins, games) = numbers.split_once("|").unwrap();
        let winners: Vec<u32> = parse_numbers(wins);
        let persos = parse_numbers(games);

        let game_num = i + 1;
        let copies_won = get_games_copies(&winners, &persos);
        let slice = game_num..game_num + copies_won as usize;

        for idx in slice {
            multiplier[idx] += multiplier[i];
        }
    }

    let total: usize = multiplier.iter().sum();

    println!("total: {:?}", total);
}

fn get_games_copies(winners: &Vec<u32>, persos: &Vec<u32>) -> u32 {
    let filtered: Vec<u32> = persos
        .iter()
        .copied()
        .filter(|num| winners.contains(num))
        .collect();

    filtered.len() as u32
}

fn parse_numbers(nums: &str) -> Vec<u32> {
    nums.trim()
        .split(" ")
        .filter_map(|num| {
            let parsed = num.parse();

            if parsed.is_ok() {
                return Some(parsed.unwrap());
            }

            None
        })
        .collect()
}
