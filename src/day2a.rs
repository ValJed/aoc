use std::fs;

#[derive(Debug)]
struct Mapping {
    red: usize,
    green: usize,
    blue: usize,
}

fn main() {
    let max: Mapping = Mapping {
        red: 12,
        green: 13,
        blue: 14,
    };

    let data = fs::read_to_string("data/day2").unwrap();
    let splitted: Vec<&str> = data.split("\n").filter(|x| x.len() > 0).collect();
    let mut total = 0;

    for line in splitted {
        let game_number = get_game_number(&line).parse::<usize>().unwrap();
        let sets = get_game_sets(&line);
        let is_invalid = is_game_invalid(sets, &max);

        if !is_invalid {
            total += game_number;
        }
    }

    println!("total: {:?}", total);
}

fn get_game_number(line: &str) -> String {
    let start_index = line.find(" ").unwrap();
    let end_index = line.find(":").unwrap();
    let number = &line[start_index + 1..end_index];

    number.to_string()
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

fn is_game_invalid(game: Vec<Vec<(usize, &str)>>, max: &Mapping) -> bool {
    game.iter().any(|sets| {
        sets.iter().any(|(number, color)| match *color {
            "red" => *number > max.red,
            "green" => *number > max.green,
            "blue" => *number > max.blue,
            _ => false,
        })
    })
}
