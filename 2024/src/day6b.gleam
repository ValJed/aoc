import gleam/dict.{type Dict, insert}
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

type Position =
  #(Int, Int)

type Map =
  Dict(Position, String)

pub type Direction {
  Up
  Right
  Down
  Left
}

type Guard {
  Guard(position: Position, direction: Direction)
}

type Route {
  Exit
  Loop
}

pub fn main() {
  let filepath = "./data/day6"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let #(map, start) = filecontent |> parse

  let result =
    set.new()
    |> walk(map, start)
    |> set.delete(start.position)
    |> test_obstacles(map, start)

  io.debug(result)
}

fn test_obstacles(visited: Set(Position), map: Map, start: Guard) {
  set.fold(visited, 0, fn(count, pos) {
    let with_obstacle = change_pos_char("#", map, pos)

    case test_route(set.new(), with_obstacle, start) {
      Loop -> count + 1
      _ -> count
    }
  })
}

fn test_route(visited: Set(Guard), map: Map, g: Guard) -> Route {
  case move(map, g) {
    Ok(guard) -> {
      case set.contains(visited, guard) {
        True -> Loop
        False -> test_route(set.insert(visited, guard), map, guard)
      }
    }
    _ -> Exit
  }
}

fn walk(visited: Set(Position), map: Map, g: Guard) -> Set(Position) {
  case move(map, g) {
    Ok(guard) -> {
      walk(set.insert(visited, guard.position), map, guard)
    }
    _ -> visited
  }
}

fn move(map: Map, guard: Guard) -> Result(Guard, Nil) {
  let Guard(#(x, y), dir) = guard

  let next_pos = case dir {
    Up -> #(x, y - 1)
    Down -> #(x, y + 1)
    Left -> #(x - 1, y)
    Right -> #(x + 1, y)
  }

  map
  |> dict.get(next_pos)
  |> result.map(fn(space) {
    case space {
      "#" -> rotate(guard)
      _ -> Guard(next_pos, dir)
    }
  })
}

fn rotate(guard: Guard) -> Guard {
  case guard {
    Guard(position, Up) -> Guard(position, Right)
    Guard(position, Right) -> Guard(position, Down)
    Guard(position, Down) -> Guard(position, Left)
    Guard(position, Left) -> Guard(position, Up)
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

fn parse(file: String) -> #(Map, Guard) {
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

  let new_map = change_pos_char(".", map, pos)

  #(new_map, Guard(pos, Up))
}
