import gleam/dict.{type Dict, get, insert}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Matrix =
  Dict(#(Int, Int), String)

const xmas = ["M", "A", "S"]

const directions = [
  #(-1, -1), #(0, -1), #(1, -1), #(1, 0), #(1, 1), #(0, 1), #(-1, 1), #(-1, 0),
]

pub fn main() {
  let filepath = "./data/day4"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let result =
    filecontent
    |> create_matrix
    |> parse_matrix

  io.println("Result: ")
  io.debug(result)
}

fn parse_matrix(matrix: Matrix) -> Int {
  dict.fold(matrix, 0, fn(acc, pos, char) {
    let #(x, y) = pos

    case char {
      "X" -> {
        acc + count_words(matrix, x, y)
      }
      _ -> {
        acc
      }
    }
  })
}

fn count_words(matrix: Matrix, x: Int, y: Int) -> Int {
  list.fold(directions, 0, fn(total, direction) {
    let #(dir_x, dir_y) = direction
    let #(_, _, success) =
      list.fold(xmas, #(x + dir_x, y + dir_y, True), fn(acc, char) {
        let #(pos_x, pos_y, cur_success) = acc

        case cur_success {
          True -> {
            let found_char = result.unwrap(get(matrix, #(pos_x, pos_y)), "")
            case found_char == char {
              True -> #(pos_x + dir_x, pos_y + dir_y, True)
              False -> #(0, 0, False)
            }
          }
          False -> acc
        }
      })

    case success {
      True -> total + 1
      False -> total
    }
  })
}

fn create_matrix(file: String) -> Matrix {
  file
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(matrix, line, y) {
    string.to_graphemes(line)
    |> list.index_fold(matrix, fn(matrix, char, x) {
      insert(matrix, #(x, y), char)
    })
  })
}
