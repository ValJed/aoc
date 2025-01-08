import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub type Disk =
  List(Int)

pub fn main() {
  let filepath = "./data/test"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let disk = filecontent |> parse
  let reversed = disk |> list.filter(fn(num) { num != -1 }) |> list.reverse()

  let result = 0 |> compress(disk, reversed, 0)

  io.debug(result)
}

fn compress(checksum: Int, disk: List(Int), rev: List(Int), index: Int) -> Int {
  io.debug(checksum)
  case disk, rev {
    [first, ..rest], [last, ..rest_rev] -> {
      case first == -1 {
        True -> {
          let add = index * last
          io.debug(add)
          checksum + add |> compress(rest, rest_rev, index + 1)
        }
        False -> {
          let add = index * first
          io.debug(add)
          checksum + add
          |> compress(rest, list.append([last], rest_rev), index + 1)
        }
      }
    }
    // [first, ..rest], [] -> {
    //   io.println("NO MORE LAST")
    //   case first == -1 {
    //     True -> {
    //       checksum
    //     }
    //     False -> {
    //       checksum + index * first
    //       |> compress(rest, [], index + 1)
    //     }
    //   }
    // }
    _, _ -> checksum
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
