import gleam/dict.{type Dict, insert}
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result.{unwrap}
import gleam/string
import simplifile

type Position =
  #(Int, Int)

type Map =
  Dict(Position, String)

type Directions =
  Dict(String, #(Int, Int))

pub fn main() {
  let filepath = "./data/day6"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let result =
    filecontent
    |> parse
    |> travel
    |> dict.fold(0, fn(acc, _, char) {
      case char {
        "X" -> acc + 1
        _ -> acc
      }
    })

  io.debug(result)
}

fn travel(data: #(Map, Position, Directions)) -> Map {
  let #(map, pos, dirs) = data
  let cur_dir = map |> dict.get(pos) |> unwrap("")
  let new_pos = dirs |> dict.get(cur_dir) |> unwrap(#(0, 0)) |> compute_pos(pos)

  let new_map = change_pos_char("X", map, pos)
  let new_pos_obstacle = dict.get(new_map, new_pos) |> unwrap("")
  case new_pos_obstacle {
    "." | "X" -> {
      let final_map = change_pos_char(cur_dir, new_map, new_pos)
      travel(#(final_map, new_pos, dirs))
    }
    "#" -> {
      let final_map = get_new_dir(cur_dir) |> change_pos_char(new_map, pos)
      travel(#(final_map, pos, dirs))
    }
    _ -> {
      new_map
    }
  }
}

fn get_new_dir(dir: String) -> String {
  case dir {
    "^" -> ">"
    ">" -> "v"
    "v" -> "<"
    _ -> "^"
  }
}

fn change_pos_char(char: String, map: Map, pos: Position) -> Map {
  dict.upsert(map, pos, fn(val) {
    case val {
      Some(_) -> char
      None -> char
    }
  })
}

fn compute_pos(mov: Position, pos: Position) -> Position {
  #(mov.0 + pos.0, mov.1 + pos.1)
}

fn parse(file: String) -> #(Map, Position, Directions) {
  let #(map, pos) =
    file
    |> string.split("\n")
    |> list.index_fold(#(dict.new(), #(0, 0)), fn(acc, line, y) {
      string.to_graphemes(line)
      |> list.index_fold(acc, fn(sub_acc, char, x) {
        let #(map, pos) = sub_acc
        let new_map = insert(map, #(x, y), char)
        case char {
          "^" -> {
            #(new_map, #(x, y))
          }
          _ -> #(new_map, pos)
        }
      })
    })
  let directions =
    dict.from_list([
      #("^", #(0, -1)),
      #(">", #(1, 0)),
      #("v", #(0, 1)),
      #("<", #(-1, 0)),
    ])

  #(map, pos, directions)
}
