use std::fs;

#[derive(Debug)]
struct Race {
    time: usize,
    distance: usize,
}

fn main() {
    let data = fs::read_to_string("data/day6").unwrap();

    let mut values: Vec<usize> = vec![];
    let races = parse(data);

    for race in races {
        let race_result = find_race_value(race);
        values.push(race_result);
    }

    let result = values.into_iter().reduce(|acc, cur| cur * acc).unwrap();

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
    println!("winning: {:?}", winning);

    winning
}

fn parse(data: String) -> Vec<Race> {
    let lines: Vec<&str> = data.split("\n").collect();
    let (_, _times) = lines[0].split_once(":").unwrap();
    let (_, _distances) = lines[1].split_once(":").unwrap();
    let times: Vec<&str> = _times.split_whitespace().collect();
    let distances: Vec<&str> = _distances.split_whitespace().collect();

    (0..times.len())
        .into_iter()
        .map(|i| Race {
            time: times[i].parse().unwrap(),
            distance: distances[i].parse().unwrap(),
        })
        .collect()
}
