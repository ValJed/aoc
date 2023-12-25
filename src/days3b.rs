use std::{collections::HashMap, fs, vec};

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

    let numbers: HashMap<usize, Vec<Number>> =
        splitted
            .iter()
            .enumerate()
            .fold(HashMap::new(), |mut acc, (idx, line)| {
                let nums = get_numbers(line);
                acc.insert(idx, nums);
                acc
            });

    for (i, line) in splitted.iter().enumerate() {
        let gears = get_gears(line, &numbers, i);
        total += gears.iter().sum::<u32>();
    }

    println!("total: {:?}", total);
}

fn get_gears(line: &str, numbers: &HashMap<usize, Vec<Number>>, line_index: usize) -> Vec<u32> {
    let mut gears: Vec<u32> = vec![];

    for (i, char) in line.chars().enumerate() {
        if char == '*' {
            let positions = vec![i, i + 1];
            // We could have need to check three positions
            // if i > 0 {
            //     positions.push(i - 1);
            // }
            let mut adjacent_nums = find_line_nums(&numbers, line_index, &positions);

            adjacent_nums.extend(find_line_nums(&numbers, line_index - 1, &positions));
            adjacent_nums.extend(find_line_nums(&numbers, line_index + 1, &positions));

            if adjacent_nums.len() == 2 {
                gears.push(adjacent_nums[0] * adjacent_nums[1]);
            }
        }
    }

    gears
}

fn find_line_nums(numbers: &HashMap<usize, Vec<Number>>, idx: usize, pos: &Vec<usize>) -> Vec<u32> {
    let num_line = numbers.get(&idx);
    if num_line.is_none() {
        return vec![];
    }
    let nums = num_line.unwrap();
    let mut indexes_found: Vec<usize> = vec![];

    pos.iter().fold(vec![], |mut acc, p| {
        let found_num = nums.iter().enumerate().find(
            |(
                i,
                Number {
                    start,
                    end,
                    num: _num,
                },
            )| {
                if (start <= p) && (end >= p) && !indexes_found.contains(&i) {
                    indexes_found.push(*i);
                    return true;
                }

                false
            },
        );

        if found_num.is_some() {
            let (_, Number { num, .. }) = found_num.unwrap();
            acc.push(*num);
        }

        acc
    })
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
            numbers.push(get_number_info(current, start_index, size));
            start_index = None;
            current = String::new();
        }
    }

    let size = current.chars().count();
    if size > 0 {
        numbers.push(get_number_info(current, start_index, size));
    }

    numbers
}

fn get_number_info(num: String, start_index: Option<usize>, size: usize) -> Number {
    let num: u32 = num.parse().unwrap();
    let start = start_index.unwrap();
    let end = start + size;
    let number = Number { num, start, end };

    number
}
