import gleam/io
import gleam/result
import gleam/string
import gleam/list
import gleam/int
import simplifile

pub type State {
  Up
  Down
  None
  Start
  Fail
}

pub type Store = #(State, Int, Int)
// pub type Store {
//   Data(state: State, previous: Int)
// }

pub fn main() {
  let filepath = "./data/day2"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let reports = filecontent 
    |> string.split("\n")
    |> list.map(format)
    |> list.map(check_report)
    |> count_safe()

  io.debug(reports)
}

fn format(line: String) -> List(Int) {
  line
    |> string.split(" ")
    |> list.map(fn(str) {
      int.parse(str) |> result.unwrap(0)
    })
}

fn count_safe(reports: List(Store)) -> Int {
  list.fold(reports, 0, fn(acc, cur) {
    case cur.0 {
      Up | Down -> acc + 1
      _ -> acc
    }
  })
}

fn check_report(report: List(Int)) -> Store {
  let rep = list.fold(report, #(Start, 0, 0), fn(acc, num) {
    let state = acc.0
    let previous = acc.1
    let errors = acc.2

    case errors > 1 {
      True -> #(Fail, num, errors)
      _ -> {
        case state {
          Start -> #(None, num, errors)
          None -> {
            case num < previous {
              True -> validate_down(num, previous, errors, state)
              False -> validate_up(num, previous, errors, state)
            }
          }
          Up -> validate_up(num, previous, errors, state)
          Down -> validate_down(num, previous, errors, state)
          Fail -> #(Fail, num, errors)
        }
      }
    }

  })

  io.debug(rep)
  rep
}

fn validate_up( num: Int, previous: Int, errors: Int, state: State) -> Store {
  let diff = num - previous

  io.debug(state)
  case diff > 0 && diff < 4 {
    True -> #(Up, num, errors)
    False -> {
      case errors == 0 {
        True -> #(state, previous, 1)
        False -> #(Fail, num, errors)
      }
    }
  }
}

fn validate_down(num: Int, previous: Int, errors: Int, state: State) -> Store {
  let diff = previous - num
  case diff > 0 && diff < 4 {
    True -> #(Down, num, errors)
    False -> {
      case errors == 0 {
        True -> #(state, previous, 1)
        False -> #(Fail, num, errors)
      }
    }
  }
}
