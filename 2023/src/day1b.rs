use std::error::Error;
use std::fs;

fn main() -> Result<(), Box<dyn Error>> {
    let data = fs::read_to_string("data/day1").unwrap();
    let splitted: Vec<&str> = data.split("\n").collect();
    let mut total = 0;
    let num_letters = [
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    ];
    let letters = [1, 2, 3, 4, 5, 6, 7, 8, 9];

    for line in splitted {
        let mut first: Option<u32> = None;
        let mut last: Option<u32> = None;
        let mut cur_word: String = String::new();

        for char in line.chars().into_iter() {
            if char.is_digit(10) {
                cur_word = "".to_string();
                if first.is_none() {
                    first = char.to_digit(10);
                } else {
                    last = char.to_digit(10);
                }
            } else {
                cur_word = format!("{}{}", cur_word, char);
                let farthest_occurence = num_letters
                    .iter()
                    .filter_map(|&x| {
                        let pos = cur_word.rfind(x);
                        match pos {
                            Some(p) => Some((x, p)),
                            None => return None,
                        }
                    })
                    .reduce(|acc, cur| if cur.1 > acc.1 { cur } else { acc });

                if farthest_occurence.is_none() {
                    continue;
                }
                let occurence = farthest_occurence.unwrap().0;
                let index_num = num_letters.iter().position(|&x| x == occurence);
                if index_num.is_some() {
                    let index = index_num.unwrap();

                    if first.is_none() {
                        first = Some(letters[index]);
                    } else {
                        last = Some(letters[index]);
                    }
                }
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
