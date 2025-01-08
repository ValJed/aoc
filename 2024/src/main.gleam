import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub type Disk =
  List(Int)

pub fn main() {
  let filepath = "./data/day9"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let disk = filecontent |> parse

  let result =
    []
    |> compress(disk, 0)
    |> list.reduce(fn(acc, cur) { acc + cur })

  io.debug(result)
}

fn remove_last(disk: List(Int)) -> #(Int, List(Int)) {
  let reversed = disk |> list.reverse()
  let #(last, new_list) =
    reversed
    |> list.fold_until(#(-1, reversed), fn(acc, cur) {
      case cur, acc.1 {
        -1, [_last, ..rest] -> {
          Continue(#(acc.0, rest))
        }
        _, [last, ..rest] -> {
          Stop(#(last, rest))
        }
        _, _ -> {
          Stop(acc)
        }
      }
    })

  #(last, list.reverse(new_list))
}

fn compress(checksum: List(Int), disk: List(Int), index: Int) -> List(Int) {
  case disk {
    [first, ..rest] -> {
      case first == -1 {
        True -> {
          let #(last, new_list) = remove_last(rest)

          let add = index * last
          [add, ..checksum] |> compress(new_list, index + 1)
        }
        False -> {
          let add = index * first
          [add, ..checksum]
          |> compress(rest, index + 1)
        }
      }
    }
    _ -> {
      checksum
    }
  }
}

fn parse(file: String) -> Disk {
  file
  |> string.split("\n")
  |> list.first()
  |> result.unwrap("")
  |> string.to_graphemes()
  |> list.filter_map(fn(char) { int.parse(char) })
  |> list.index_fold([], fn(acc, cur, i) {
    case int.is_even(i) {
      True -> {
        acc |> list.append(list.repeat(i / 2, cur))
      }
      False -> {
        acc |> list.append(list.repeat(-1, cur))
      }
    }
  })
}
