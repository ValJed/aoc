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
  let regex = regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")
  case regex {
    Ok(re) -> {
      regexp.scan(re, file)
      |> parse_matches
    }
    Error(_) -> {
      io.println("Bad Regex")
      []
    }
  }
}

fn parse_matches(matches: List(Match)) -> List(Int) {
  let parsed =
    list.fold(matches, #(True, []), fn(acc, match) {
      case match.content {
        "do()" -> {
          #(True, acc.1)
        }
        "don't()" -> {
          #(False, acc.1)
        }
        _ -> {
          case acc.0 {
            True -> {
              case try_multiply(match.submatches) {
                Ok(val) -> {
                  #(True, list.append(acc.1, [val]))
                }
                _ -> #(True, acc.1)
              }
            }
            False -> {
              #(False, acc.1)
            }
          }
        }
      }
    })

  parsed.1
}

fn try_multiply(submatches) -> Result(Int, String) {
  case submatches {
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
