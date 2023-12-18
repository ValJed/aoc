use std::{fs, str::Chars};

#[derive(Debug)]
struct Number {
    num: u32,
    start: usize,
    end: usize,
}

fn main() {
    let data = fs::read_to_string("data/day3").unwrap();
    let splitted: Vec<&str> = data.split("\n").filter(|x| x.len() > 0).collect();
    let mut total = 0;

    for (i, line) in splitted.iter().enumerate() {
        let numbers = get_numbers(line);
        let filtered = filter_numbers(numbers, &splitted, i);
    }

    // println!("total: {:?}", total);
}

fn filter_numbers(numbers: Vec<Number>, file: &Vec<&str>, line_index: usize) -> Vec<u32> {
    let line: Vec<_> = file[line_index].chars().collect();
    let prev = if line_index > 0 {
        file[line_index - 1].chars().collect()
    } else {
        vec![]
    };

    let next = if line_index < file.len() {
        file[line_index + 1].chars().collect()
    } else {
        vec![]
    };

    numbers
        .into_iter()
        .filter(|Number { num, start, end }| {
            let mut adjacents = vec![line.get(start - 1), line.get(end + 1)];

            for i in start - 1..end + 1 {
                adjacents.push(prev.get(i));
                adjacents.push(next.get(i));
            }

            let symbol_found = adjacents.iter().find(|adjacent| {
                if adjacent.is_none() {
                    return false;
                }

                if adjacent.unwrap().to_string() != "." {
                    return true;
                }

                false
            });

            if symbol_found.is_some() {
                true
            } else {
                false
            }
        })
        .map(
            |Number {
                 num,
                 start: _start,
                 end: _end,
             }| num,
        )
        .collect()
}

fn get_numbers(line: &str) -> Vec<Number> {
    let mut numbers: Vec<Number> = vec![];
    let mut current = String::new();
    let mut start_index = None;

    for (index, char) in line.char_indices() {
        if char.is_digit(10) {
            current.push(char);
            if start_index.is_none() {
                start_index = Some(index);
            }
            continue;
        }

        let size = current.chars().count();
        if size > 0 {
            let num: u32 = current.parse().unwrap();
            let start = start_index.unwrap();
            let end = start + size;
            let number = Number { num, start, end };

            numbers.push(number);
            start_index = None;
            current = String::new();
        }
    }

    numbers
}
