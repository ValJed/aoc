use std::collections::HashMap;
use std::fs;

fn main() {
    let data = fs::read_to_string("data/day2").unwrap();
    let splitted: Vec<&str> = data.split("\n").filter(|x| x.len() > 0).collect();
    let mut total = 0;

    for line in splitted {
        let sets = get_game_sets(&line);
        let set_power = get_set_power(sets);

        if set_power.is_some() {
            total += set_power.unwrap();
        }
    }

    println!("total: {:?}", total);
}

fn get_set_power(game: Vec<Vec<(usize, &str)>>) -> Option<usize> {
    let maxs = game
        .iter()
        .fold(HashMap::new(), |mut acc: HashMap<&str, usize>, sets| {
            for (number, color) in sets {
                let max = acc.entry(color).or_insert(*number);

                if number > max {
                    acc.insert(&color, *number);
                }
            }

            acc
        });

    let power = maxs.values().cloned().reduce(|acc, x| acc * x);

    power
}

fn get_game_sets(line: &str) -> Vec<Vec<(usize, &str)>> {
    let start_index = line.find(":").unwrap();
    let sets_str = &line[start_index + 2..line.len()];
    let sets: Vec<Vec<(usize, &str)>> = sets_str.split(";").map(|s| get_subset(&s)).collect();

    sets
}

fn get_subset(set: &str) -> Vec<(usize, &str)> {
    set.split(",")
        .map(|x| {
            let result: Vec<&str> = x.trim().split(" ").collect();
            let (number, color) = (result[0].parse::<usize>().unwrap(), result[1]);

            (number, color)
        })
        .collect()
}
