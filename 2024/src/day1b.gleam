import gleam/io
import gleam/result
import gleam/string
import gleam/list
import gleam/int
import simplifile

pub fn main() {
  let filepath = "./data/day1"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let lines = filecontent |> string.split("\n")

  let result = create_lists(lines)
    |> compute_lists()
    |> list.reduce(fn(acc, cur) { acc + cur })
    |> result.unwrap(0)

  io.debug(result)
}

fn compute_lists(lists: #(List(Int), List(Int))) -> List(Int) {
  list.filter_map(lists.0, fn(left) -> Result(Int, _){
    let muliplier = list.fold(lists.1, 0, fn(acc, right) {
      case right == left {
        True -> acc + 1
        False -> acc
      }
    })

    case muliplier == 0 {
      True -> Error("")
      False -> Ok(left * muliplier)
    }
  })
}

fn create_lists(lines: List(String)) -> #(List(Int), List(Int)) {
  list.fold(lines, #([], []), fn(acc, cur) -> #(List(Int), List(Int)) {
    case cur {
      "" -> acc
      _ -> {
        let splitted = cur 
          |> string.split("   ") 
          |> list.map(fn(x) {result.unwrap(int.parse(x), 0)})

        case splitted {
          [left, right] -> {
            let #(acc_left, acc_right) = acc 
            let new_left = [left, ..acc_left]
            let new_right = [right, ..acc_right]

            #(new_left, new_right)
          }
          _ -> acc
        }
      }
    }
  })
}

