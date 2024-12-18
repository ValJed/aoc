import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match}
import gleam/result
import gleam/string
import simplifile

pub type Matrix =
  List(List(String))

pub fn main() {
  let filepath = "./data/test"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let result =
    filecontent
    |> create_matrix
    |> get_lines
    |> compute
}

fn get_lines(matrix: Matrix) -> Matrix {
  let x_lines = matrix
  let y_lines = build_y_lines(matrix, []) |> list.reverse
  let diag_lines = build_diag_lines(matrix, [])
  // TODO

  x_lines
}

fn build_diag_lines(matrix: Matrix, lines: Matrix) -> Matrix {
  todo
}

fn build_y_lines(matrix: Matrix, lines: Matrix) -> Matrix {
  let #(line, rev_matrix) =
    list.fold(matrix, #([], []), fn(acc, line) {
      case line {
        [first, ..rest] -> {
          #(list.append(acc.0, [first]), [rest, ..acc.1])
        }
        [] -> acc
      }
    })

  case line {
    [] -> lines
    _ -> {
      let new_matrix = list.reverse(rev_matrix)
      build_y_lines(new_matrix, [line, ..lines])
    }
  }
}

fn compute(matrix: Matrix) {
  todo
  // let first_line = check_line(list.at(0))
}

fn check_line(line: List(String)) -> Int {
  list.fold(line, #(0, ""), fn(acc, char) {
    let word = acc.1
    case char {
      "X" -> #(acc.0, "X")
      "M" -> {
        case word {
          "X" -> #(acc.0, "XM")
          _ -> #(acc.0, "")
        }
      }
      "A" -> {
        case word {
          "XM" -> #(acc.0, "XMA")
          _ -> #(acc.0, "")
        }
      }
      "S" -> {
        case word {
          "XMA" -> #(acc.0 + 1, "")
          _ -> #(acc.0, "")
        }
      }
      _ -> #(acc.0, "")
    }
  }).0
}

fn create_matrix(file: String) -> Matrix {
  file
  |> string.split("\n")
  |> list.filter_map(fn(line) {
    let chars =
      list.filter_map(string.split(line, ""), fn(char) {
        case string.is_empty(char) {
          True -> Error("")
          False -> Ok(char)
        }
      })
    case list.is_empty(chars) {
      True -> Error("")
      False -> Ok(chars)
    }
  })
}
