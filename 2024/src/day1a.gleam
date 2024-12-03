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
    |> sort_lists()
    |> join_lists()
    |> compute_diffs()
    |> list.reduce(fn(acc, cur) { acc + cur })
    |> result.unwrap(0)

  io.debug(result)
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

fn join_lists(lists: #(List(Int), List(Int))) -> List(#(Int, Int)) {
  list.zip(lists.0, lists.1)
}

fn compute_diffs(lists: List(#(Int, Int))) -> List(Int) {
  list.map(lists, fn(cur) {
    case cur.0 > cur.1 {
      True -> cur.0 - cur.1
      False -> cur.1 - cur.0
    }
  })
}

fn sort_lists(lists: #(List(Int), List(Int))) -> #(List(Int), List(Int)) {
  let left = list.sort(lists.0, int.compare)
  let right = list.sort(lists.1, int.compare)

  #(left, right)
}

