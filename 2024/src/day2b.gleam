import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type State {
  Up
  Down
  None
  Start
  Fail
}

pub type Store =
  #(State, Int)

pub fn main() {
  let filepath = "./data/day2"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let safe_reports =
    filecontent
    |> string.split("\n")
    |> list.filter_map(format)
    |> list.map(check_dampener)
    |> count_safe()

  io.print("Safe Reports: \n")
  io.debug(safe_reports)
}

fn format(line: String) -> Result(List(Int), String) {
  let collec =
    line
    |> string.split(" ")
    |> list.map(fn(str) { int.parse(str) |> result.unwrap(0) })

  case list.length(collec) > 1 {
    True -> Ok(collec)
    False -> Error("")
  }
}

fn count_safe(reports: List(Bool)) -> Int {
  list.fold(reports, 0, fn(acc, cur) {
    case cur {
      True -> acc + 1
      _ -> acc
    }
  })
}

fn check_dampener(report: List(Int)) -> Bool {
  let checked = check_report(report)
  case checked {
    True -> True
    False -> {
      test_dampener([], report)
    }
  }
}

fn test_dampener(prev: List(Int), cur: List(Int)) -> Bool {
  case cur {
    [] -> False
    [first, ..rest] -> {
      let new_list = list.append(prev, rest)
      let good = check_report(new_list)

      case good {
        True -> True
        False -> {
          test_dampener(list.append(prev, [first]), rest)
        }
      }
    }
  }
}

fn check_report(report: List(Int)) -> Bool {
  let report =
    list.fold(report, #(Start, 0), fn(acc, num) {
      let state = acc.0
      let previous = acc.1

      case state {
        Start -> #(None, num)
        None -> {
          case num < previous {
            True -> validate_down(num, previous)
            False -> validate_up(num, previous)
          }
        }
        Up -> validate_up(num, previous)
        Down -> validate_down(num, previous)
        Fail -> #(Fail, num)
      }
    })

  case report.0 {
    Up | Down -> True
    _ -> False
  }
}

fn validate_up(num: Int, previous: Int) -> Store {
  let diff = num - previous
  case diff > 0 && diff < 4 {
    True -> #(Up, num)
    False -> #(Fail, num)
  }
}

fn validate_down(num: Int, previous: Int) -> Store {
  let diff = previous - num
  case diff > 0 && diff < 4 {
    True -> #(Down, num)
    False -> #(Fail, num)
  }
}
