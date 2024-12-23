import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile

pub type Rules =
  Dict(Int, List(Int))

pub type Pages =
  List(List(Int))

pub fn main() {
  let filepath = "./data/day5"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let result =
    filecontent
    |> parse
    |> find_ordered
    |> add_middle_nums

  io.debug(result)
}

fn find_ordered(data: #(Rules, Pages)) -> Pages {
  let #(rules, pages) = data
  list.filter(pages, fn(page) { check_valid(page, rules, True) })
}

fn add_middle_nums(pages: Pages) -> Int {
  list.fold(pages, 0, fn(acc, page) {
    let middle_index =
      int.floor_divide(list.length(page), 2) |> result.unwrap(0)
    let middle =
      list.index_fold(page, 0, fn(middle, cur, index) {
        case index == middle_index {
          True -> cur
          False -> middle
        }
      })

    acc + middle
  })
}

fn check_valid(page: List(Int), rules: Rules, is_valid: Bool) -> Bool {
  case is_valid {
    False -> False
    True -> {
      case page {
        [first, ..rest] -> {
          case dict.get(rules, first) {
            Ok(nums) -> {
              let found = list.find(rest, fn(num) { list.contains(nums, num) })
              case found {
                Ok(_) -> False
                Error(_) -> check_valid(rest, rules, True)
              }
            }
            Error(_) -> check_valid(rest, rules, True)
          }
        }
        [] -> is_valid
      }
    }
  }
}

fn parse(file: String) -> #(Rules, Pages) {
  let #(final_rules, pages) =
    file
    |> string.split("\n")
    |> list.fold(#(dict.new(), []), fn(acc, line) {
      let #(rules, pages) = acc

      case string.contains(line, "|"), string.contains(line, ",") {
        True, False -> {
          case string.split(line, "|") {
            [before, after] -> {
              let bef = int.parse(before) |> result.unwrap(0)
              let aft = int.parse(after) |> result.unwrap(0)

              let new_rules =
                dict.upsert(rules, aft, fn(val) {
                  case val {
                    Some(v) -> [bef, ..v]
                    None -> [bef]
                  }
                })

              #(new_rules, pages)
            }
            _ -> acc
          }
        }
        False, True -> {
          let nums =
            string.split(line, ",")
            |> list.map(fn(num) { result.unwrap(int.parse(num), 0) })
          #(rules, [nums, ..pages])
        }
        _, _ -> acc
      }
    })

  #(final_rules, list.reverse(pages))
}
