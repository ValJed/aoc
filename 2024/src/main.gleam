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

  let lists = list.fold(lines, #([], []), fn(acc, cur) -> #(List(Int), List(Int)) {
    case cur {
      "" -> acc
      _ -> {
        let splitted = cur 
          |> string.split("   ") 
          |> list.map(fn(x) {result.unwrap(int.parse(x), 0)})

        case splitted {
          [left, right] -> {
            let #(acc_left, acc_right) = acc 
            // io.print("acc")
            // io.debug(acc_left)
            let new_left = [left, ..acc_left]
            let new_right = [right, ..acc_right]

            #(new_left, new_right)
          }
          _ -> acc
        }
      }
    }
  }) |> sort_lists()

  io.debug(lists.0)
}

fn sort_lists(lists: #(List(Int), List(Int))) -> #(List(Int), List(Int)) {
  let left = list.sort(lists.0, int.compare)
  let right = list.sort(lists.1, int.compare)

  #(left, right)
}

