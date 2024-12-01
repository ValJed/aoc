use std::fs;

#[derive(Debug)]
struct Race {
    time: usize,
    distance: usize,
}

fn main() {
    let data = fs::read_to_string("data/day6").unwrap();
    let race = parse(data);
    let result = find_race_value(race);

    println!("result: {:?}", result);
}

fn find_race_value(race: Race) -> usize {
    let mut winning = 0;

    for hold in 0..race.time {
        let distance_reached = hold * (race.time - hold);
        if distance_reached > race.distance {
            winning += 1;
        }
    }

    winning
}

fn parse(data: String) -> Race {
    let lines: Vec<&str> = data.split("\n").collect();
    let (_, _times) = lines[0].split_once(":").unwrap();
    let (_, _distances) = lines[1].split_once(":").unwrap();
    let time: usize = _times
        .split_whitespace()
        .collect::<Vec<&str>>()
        .join("")
        .parse()
        .unwrap();
    let distance: usize = _distances
        .split_whitespace()
        .collect::<Vec<&str>>()
        .join("")
        .parse()
        .unwrap();

    Race { time, distance }
}
