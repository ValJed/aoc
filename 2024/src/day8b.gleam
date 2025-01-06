import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub type Coord =
  #(Int, Int)

type Map =
  Dict(String, List(Coord))

pub type Antinodes =
  Set(Coord)

pub fn main() {
  let filepath = "./data/day8"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let #(map, boundaries) = filecontent |> parse

  let result =
    map
    |> dict.fold(set.new(), fn(acc, _, antennas) {
      check_antinodes(antennas, [], acc, boundaries)
    })
    |> set.size()

  io.debug(result)
}

fn check_antinodes(
  antennas: List(Coord),
  done: List(Coord),
  antinodes: Antinodes,
  boundaries: Coord,
) -> Antinodes {
  case antennas {
    [] -> antinodes
    [first, ..rest] -> {
      let new_antinodes =
        compare_antennas(first, list.append(done, rest), antinodes, boundaries)
      let anti =
        check_antinodes(
          rest,
          list.append(done, [first]),
          new_antinodes,
          boundaries,
        )
      anti
    }
  }
}

fn compare_antennas(
  antenna: Coord,
  antennas: List(Coord),
  antinodes: Antinodes,
  boundaries: Coord,
) -> Antinodes {
  antennas
  |> list.fold(antinodes, fn(acc, cur) {
    get_antinodes(antenna, cur, acc, boundaries)
  })
}

fn get_antinodes(
  a: Coord,
  b: Coord,
  antinodes: Antinodes,
  boundaries: Coord,
) -> Antinodes {
  let x_diff = int.absolute_value(a.0 - b.0)
  let y_diff = int.absolute_value(a.1 - b.1)

  let #(forward, backward) = case a.0 >= b.0 {
    True -> #(a, b)
    False -> #(b, a)
  }

  let forward_x = x_diff
  let backward_x = -x_diff

  let #(forward_y, backward_y) = case forward.1 > backward.1 {
    True -> #(y_diff, -y_diff)
    False -> #(-y_diff, y_diff)
  }

  antinodes
  |> set.insert(a)
  |> set.insert(b)
  |> resonate(forward, #(forward_x, forward_y), boundaries)
  |> resonate(backward, #(backward_x, backward_y), boundaries)
}

fn resonate(
  antinodes: Antinodes,
  pos: Coord,
  dir: Coord,
  boundaries: #(Int, Int),
) -> Antinodes {
  let new_antinode = #(pos.0 + dir.0, pos.1 + dir.1)
  let #(x, y) = new_antinode

  case x >= 0 && x <= boundaries.0 && y >= 0 && y <= boundaries.1 {
    True -> {
      antinodes
      |> set.insert(new_antinode)
      |> resonate(new_antinode, dir, boundaries)
    }
    False -> antinodes
  }
}

fn parse(file: String) -> #(Map, Coord) {
  file
  |> string.split("\n")
  |> list.index_fold(#(dict.new(), #(0, 0)), fn(data, line, y) {
    string.to_graphemes(line)
    |> list.index_fold(data, fn(acc, char, x) {
      let #(map, _) = acc
      case char {
        "." -> #(map, #(x, y))
        _ -> {
          let new_map =
            map
            |> dict.upsert(char, fn(val) {
              case val {
                Some(others) -> [#(x, y), ..others]
                None -> [#(x, y)]
              }
            })

          #(new_map, #(x, y))
        }
      }
    })
  })
}
