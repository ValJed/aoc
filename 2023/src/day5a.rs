use std::{collections::HashSet, fs, ops::Range, vec};

#[derive(Debug, Clone)]
struct Map {
    range: Range<i64>,
    delta: i64,
}

fn main() {
    let data = fs::read_to_string("data/day5").unwrap();

    let (seeds, maps) = parse(data);

    let result: i64 = seeds
        .iter()
        .map(|seed| seed_to_location(*seed, &maps))
        .min()
        .unwrap();

    println!("result: {:?}", result);
}

fn apply_map(val: i64, maps: &Vec<Map>) -> i64 {
    for map in maps {
        if map.range.contains(&val) {
            return val + map.delta;
        }
    }

    val
}

fn seed_to_location(seed: i64, maps: &Vec<Vec<Map>>) -> i64 {
    maps.iter().enumerate().fold(0, |acc, (i, section)| {
        if i == 0 {
            return apply_map(seed, &section);
        }

        apply_map(acc, &section)
    })
}

fn parse(data: String) -> (HashSet<i64>, Vec<Vec<Map>>) {
    let splitted: Vec<&str> = data.split("\n\n").collect();

    splitted.iter().fold(
        (HashSet::new(), vec![]),
        |(mut seeds, mut maps), section| {
            if section.starts_with("seeds:") {
                let (_, nums) = section.split_once(": ").unwrap();
                seeds = nums
                    .split_whitespace()
                    .map(|num| num.parse().unwrap())
                    .collect();

                return (seeds, maps);
            }

            let (_, nums) = section.split_once("map:\n").unwrap();
            let section_mapping: Vec<Map> = nums
                .split("\n")
                .filter_map(|line| {
                    if line.len() == 0 {
                        return None;
                    }
                    let mut values = line.split_whitespace();
                    let dest: i64 = values.next().unwrap().parse().unwrap();
                    let source: i64 = values.next().unwrap().parse().unwrap();
                    let length: i64 = values.next().unwrap().parse().unwrap();

                    Some(Map {
                        range: Range {
                            start: source,
                            end: source + length,
                        },
                        delta: dest - source,
                    })
                })
                .collect();

            maps.push(section_mapping);

            (seeds, maps)
        },
    )
}
