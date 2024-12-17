import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match}
import gleam/result
import simplifile

pub fn main() {
  let filepath = "./data/day3"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let result =
    filecontent
    |> get_occurences
    |> list.reduce(fn(acc, cur) { acc + cur })
    |> result.unwrap(0)

  io.debug(result)
}

fn get_occurences(file: String) -> List(Int) {
  let regex = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  case regex {
    Ok(re) -> {
      regexp.scan(re, file)
      |> list.filter_map(try_multiply)
    }
    Error(_) -> {
      io.println("Bad Regex")
      []
    }
  }
}

fn try_multiply(match: Match) -> Result(Int, String) {
  case match.submatches {
    [Some(str1), Some(str2)] -> {
      case int.parse(str1), int.parse(str2) {
        Ok(num1), Ok(num2) -> {
          Ok(num1 * num2)
        }
        _, _ -> Error("")
      }
    }
    _ -> Error("")
  }
}
