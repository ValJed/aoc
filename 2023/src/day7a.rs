use std::{cmp::Ordering, collections::HashMap, fs, vec};

#[derive(Debug)]
struct Hand {
    val: String,
    bid: usize,
    strength: usize,
}

impl Hand {
    fn new(val: String, bid: usize) -> Self {
        let mut explored: Vec<char> = vec![];
        let mut map: HashMap<String, usize> = HashMap::from_iter(vec![
            ("has_two".into(), 0),
            ("has_three".into(), 0),
            ("has_four".into(), 0),
            ("has_five".into(), 0),
        ]);

        for char in val.chars() {
            if explored.contains(&char) {
                continue;
            }
            let matches: usize = val.matches(char).count();
            let value = match matches {
                2 => "has_two",
                3 => "has_three",
                4 => "has_four",
                5 => "has_five",
                _ => "",
            };

            if value.len() == 0 {
                explored.push(char);
                continue;
            }
            let cur_val = *map.get(&value.to_string()).unwrap();
            map.insert(value.to_string(), cur_val + 1);
            explored.push(char);
        }

        let strength: usize;
        if *map.get("has_five").unwrap() == 1 {
            strength = 7;
        } else if *map.get("has_four").unwrap() == 1 {
            strength = 6;
        } else if *map.get("has_three").unwrap() == 1 && *map.get("has_two").unwrap() == 1 {
            strength = 5;
        } else if *map.get("has_three").unwrap() == 1 {
            strength = 4;
        } else if *map.get("has_two").unwrap() == 2 {
            strength = 3;
        } else if *map.get("has_two").unwrap() == 1 {
            strength = 2;
        } else {
            strength = 1
        }

        Self { val, bid, strength }
    }
}

fn main() {
    let data = fs::read_to_string("data/day7").unwrap();
    let map: HashMap<char, usize> = HashMap::from_iter(vec![
        ('A', 13),
        ('K', 12),
        ('Q', 11),
        ('J', 10),
        ('T', 9),
        ('9', 8),
        ('8', 7),
        ('7', 6),
        ('6', 5),
        ('5', 4),
        ('4', 3),
        ('3', 2),
        ('2', 1),
    ]);
    let mut result: usize = 0;
    let mut hands = parse(data);
    hands.sort_by(|a, b| compare_hands(a, b, &map));

    for (i, hand) in hands.iter().enumerate() {
        result += hand.bid * (i + 1);
    }

    println!("result: {:?}", result);
}

fn compare_hands(a: &Hand, b: &Hand, map: &HashMap<char, usize>) -> Ordering {
    if a.strength > b.strength {
        return Ordering::Greater;
    }
    if b.strength > a.strength {
        return Ordering::Less;
    }

    for (i, a_val) in a.val.chars().enumerate() {
        let b_val = b.val.chars().nth(i).unwrap();
        if a_val == b_val {
            continue;
        }
        let a_strength = map.get(&a_val).unwrap();
        let b_strength = map.get(&b_val).unwrap();
        let comp = a_strength.cmp(&b_strength);
        return comp;
    }

    return Ordering::Equal;
}

fn parse(data: String) -> Vec<Hand> {
    let lines: Vec<&str> = data.split("\n").filter(|x| x.len() > 0).collect();

    lines
        .iter()
        .map(|line| {
            let (val, bid) = line.split_once(" ").unwrap();

            Hand::new(val.into(), bid.parse().unwrap())
        })
        .collect()
}
