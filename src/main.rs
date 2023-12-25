use std::{collections::HashMap, fs};

fn main() {
    let data = fs::read_to_string("data/day4").unwrap();
    let splitted: Vec<&str> = data.split("\n").filter(|x| x.len() > 0).collect();
    let mut total = 0;

    for line in splitted {
        let numbers: Vec<&str> = line.split(":").collect();
        let nums: Vec<&str> = numbers[1].split("|").collect();
        let winners: Vec<u32> = parse_numbers(nums[0]);
        let persos = parse_numbers(nums[1]);
        let points = get_points(&winners, &persos);

        total += points;
    }

    println!("total: {:?}", total);
}

fn get_points(winners: &Vec<u32>, persos: &Vec<u32>) -> u32 {
    let filtered: Vec<u32> = persos
        .iter()
        .copied()
        .filter(|num| winners.contains(num))
        .collect();

    filtered.into_iter().enumerate().fold(0, |acc, (i, _)| {
        if i == 0 {
            return 1;
        }

        acc * 2
    })
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
