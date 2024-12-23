import gleam/dict.{type Dict, insert}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Matrix =
  Dict(#(Int, Int), String)

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
      "A" -> {
        acc + count_words(matrix, x, y)
      }
      _ -> {
        acc
      }
    }
  })
}

fn count_words(matrix: Matrix, x: Int, y: Int) -> Int {
  let diag_left = get_diag_words(matrix, #(x - 1, y - 1), #(x + 1, y + 1))
  let diag_right = get_diag_words(matrix, #(x + 1, y - 1), #(x - 1, y + 1))

  let left_ok =
    [diag_left, string.reverse(diag_left)]
    |> list.contains("MAS")

  let right_ok =
    [diag_right, string.reverse(diag_right)]
    |> list.contains("MAS")

  case left_ok, right_ok {
    True, True -> 1
    _, _ -> 0
  }
}

fn get_diag_words(
  matrix: Matrix,
  pos1: #(Int, Int),
  pos2: #(Int, Int),
) -> String {
  let char1 = result.unwrap(dict.get(matrix, pos1), "")
  let char2 = result.unwrap(dict.get(matrix, pos2), "")

  char1 <> "A" <> char2
}

fn create_matrix(file: String) -> Matrix {
  file
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(matrix, line, y) {
    string.to_graphemes(line)
    |> list.index_fold(matrix, fn(acc, char, x) { insert(acc, #(x, y), char) })
  })
}
