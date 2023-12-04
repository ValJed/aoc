use std::error::Error;
use std::fs;

fn main() -> Result<(), Box<dyn Error>> {
    let data = fs::read_to_string("data/day1").unwrap();
    let splitted: Vec<&str> = data.split("\n").collect();
    let mut total = 0;

    for line in splitted {
        let mut first: Option<u32> = None;
        let mut last: Option<u32> = None;

        for char in line.chars().into_iter() {
            if char.is_digit(10) {
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

    println!("total: {:?}", total);

    Ok(())
}
