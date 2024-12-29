import gleam/int.{add, multiply}
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string
import simplifile

type Equation =
  #(Int, List(Int))

pub type EqResult {
  Solvable
  Unsolvable
}

pub fn main() {
  let filepath = "./data/day7"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let equations = filecontent |> parse

  let result =
    equations
    |> list.fold(0, fn(acc, cur) {
      let #(value, nums) = cur

      case compute_equation(value, nums, [add, multiply, concat_nums]) {
        Solvable -> acc + value
        Unsolvable -> acc
      }
    })

  io.debug(result)
}

fn concat_nums(a: Int, b: Int) -> Int {
  string.concat([int.to_string(a), int.to_string(b)])
  |> int.parse()
  |> result.unwrap(0)
}

fn compute_equation(
  value: Int,
  nums: List(Int),
  operators: List(fn(Int, Int) -> Int),
) -> EqResult {
  case nums {
    [a] if a == value -> Solvable
    [_] -> Unsolvable
    [a, b, ..rest] -> {
      list.fold_until(operators, Unsolvable, fn(solvable, op) {
        let res = op(a, b)
        // io.debug(res)
        case compute_equation(value, [res, ..rest], operators) {
          Solvable -> Stop(Solvable)
          Unsolvable -> Continue(solvable)
        }
      })
    }
    _ -> Unsolvable
  }
}

fn parse(file: String) -> List(Equation) {
  file
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    case string.split(line, ":") {
      [left, right, ..] -> {
        let value = int.parse(left) |> result.unwrap(0)
        let nums =
          right
          |> string.split(" ")
          |> list.filter_map(fn(num) {
            case num {
              "" -> Error(Nil)
              _ -> int.parse(num)
            }
          })

        Ok(#(value, nums))
      }
      _ -> Error("")
    }
  })
}
