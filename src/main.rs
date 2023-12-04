use std::error::Error;
use std::fs;

struct letter_numbers {
    one: u16,
    two: u16,
    three: u16,
    four: u16,
    five: u16,
    six: u16,
    seven: u16,
    eight: u16,
    nine: u16,
}

impl letter_numbers {
    pub fn new() -> Self {
        Self {
            one: 1,
            two: 2,
            three: 3,
            four: 4,
            five: 5,
            six: 6,
            seven: 7,
            eight: 8,
            nine: 9,
        }
    }
}

fn main() -> Result<u32, Box<dyn Error>> {
    let data = fs::read_to_string("data/day1").unwrap();
    let splitted: Vec<&str> = data.split("\n").collect();
    let mut total = 0;
    let letters = letter_numbers::new();

    for line in splitted {
        let mut first: Option<u32> = None;
        let mut last: Option<u32> = None;
        let mut word: Option<&str> = None;

        for char in line.chars().into_iter() {
            if char.is_digit(10) {
                word = None;
                if first.is_none() {
                    first = char.to_digit(10);
                } else {
                    last = char.to_digit(10);
                }
            } else {
            }
        }
        if first.is_none() {
            continue;
        }
        let number_str = first.unwrap().to_string() + &last.unwrap_or(first.unwrap()).to_string();
        let number: u32 = number_str.parse().unwrap();
        total += number;
    }

    Ok(total)
}
