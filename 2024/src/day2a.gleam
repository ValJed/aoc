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

pub type Store = #(State, Int)
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
  let rep = list.fold(report, #(Start, 0), fn(acc, num) {
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

  rep
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
