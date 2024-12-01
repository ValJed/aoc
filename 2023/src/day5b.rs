use std::{collections::HashSet, fs, ops::Range, vec};

#[derive(Debug, Clone)]
struct Map {
    range: Range<i64>,
    delta: i64,
}

#[derive(Debug, Clone)]
struct Seed {
    range: Range<i64>,
}

fn main() {
    let data = fs::read_to_string("data/day5").unwrap();

    let (seeds, maps) = parse(data);

    let mut result = None;
    let mut location = 1_i64;
    loop {
        if result.is_some() {
            break;
        }
        let mut cur = location;
        for map in maps.iter().rev() {
            cur = reverse_lookup(cur, &map);
        }

        for sr in &seeds {
            if sr.range.contains(&cur) {
                result = Some(location);
            }
        }
        location += 1;
    }

    match result {
        Some(res) => println!("result: {:?}", res),
        None => println!("No Result found"),
    }
}

fn reverse_lookup(val: i64, maps: &Vec<Map>) -> i64 {
    for map in maps {
        let rev = val - map.delta;
        if map.range.contains(&rev) {
            return rev;
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

fn apply_map(val: i64, maps: &Vec<Map>) -> i64 {
    for map in maps {
        if map.range.contains(&val) {
            return val + map.delta;
        }
    }

    val
}

fn range_overlap(a: Range<i64>, b: Range<i64>) -> bool {
    if b.start <= a.end && b.end >= a.start {
        return true;
    }

    false
}

fn parse(data: String) -> (Vec<Seed>, Vec<Vec<Map>>) {
    let splitted: Vec<&str> = data.split("\n\n").collect();

    splitted
        .iter()
        .fold((vec![], vec![]), |(mut seeds, mut maps), section| {
            if section.len() == 0 {
                return (seeds, maps);
            }

            if section.starts_with("seeds:") {
                let (_, nums) = section.split_once(": ").unwrap();
                seeds = nums.split_whitespace().fold(vec![], |mut acc, cur| {
                    let num: i64 = cur.parse().unwrap();
                    if acc.len() == 0 {
                        acc.push(Seed {
                            range: Range { start: num, end: 0 },
                        });
                        return acc;
                    }

                    let index = acc.len() - 1;
                    if acc[index].range.end == 0 {
                        acc[index].range.end = acc[index].range.start + num;
                        // - 1
                        return acc;
                    }

                    acc.push(Seed {
                        range: Range { start: num, end: 0 },
                    });

                    acc
                });

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
        })
}
