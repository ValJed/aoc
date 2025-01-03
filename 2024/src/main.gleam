import gleam/dict.{type Dict}
import gleam/int.{add, multiply}
import gleam/io
import gleam/list.{Continue, Stop}
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
  let filepath = "./data/test"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let #(map, boundaries) = filecontent |> parse

  let result =
    map
    |> dict.fold(set.new(), fn(acc, _, antennas) {
      io.debug(acc)
      check_antinodes(antennas, [], acc)
    })
  // |> set.filter(fn(coord) {
  //   let #(x, y) = coord
  //   x <= boundaries.0 && y <= boundaries.1
  // })
  // |> set.size()

  // io.debug(result)
}

fn check_antinodes(
  antennas: List(Coord),
  done: List(Coord),
  antinodes: Antinodes,
) -> Antinodes {
  case antennas {
    [] -> antinodes
    [first, ..rest] -> {
      let new_antinodes =
        compare_antennas(first, list.append(done, rest), antinodes)
      let anti =
        check_antinodes(rest, list.append(done, [first]), new_antinodes)
      anti
    }
  }
}

fn compare_antennas(
  antenna: Coord,
  antennas: List(Coord),
  antinodes: Antinodes,
) -> Antinodes {
  antennas
  |> list.fold(antinodes, fn(acc, cur) {
    let #(low_x, high_x) = get_antinodes_lat(antenna.0, cur.0)
    let #(low_y, high_y) = get_antinodes_lat(antenna.1, cur.1)
    acc |> set.insert(#(low_x, low_y)) |> set.insert(#(high_x, high_y))
    acc
  })
}

fn get_antinodes_lat(a: Int, b: Int) -> Coord {
  case a > b {
    True -> {
      let diff = a - b
      #(a - diff, b + diff)
    }
    False -> {
      let diff = b - a
      #(b - diff, a + diff)
    }
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
