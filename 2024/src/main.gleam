import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import gleam/string
import simplifile

pub type Rules =
  List(String)

pub type Pages =
  List(List(String))

pub fn main() {
  let filepath = "./data/day5"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let result =
    filecontent
    |> parse
    |> reorder_list
    |> add_middle_nums

  io.debug(result)
}

fn reorder_list(data: #(Pages, fn(String, String) -> Order)) -> Pages {
  let #(pages, order) = data
  list.filter_map(pages, fn(update) {
    let ordered = list.sort(update, order)
    case ordered != update {
      True -> Ok(ordered)
      False -> Error("")
    }
  })
}

fn add_middle_nums(pages: Pages) -> Int {
  list.fold(pages, 0, fn(acc, page) {
    let middle_index =
      int.floor_divide(list.length(page), 2) |> result.unwrap(0)

    let middle =
      list.index_fold(page, 0, fn(middle, cur, index) {
        case index == middle_index {
          True -> int.parse(cur) |> result.unwrap(0)
          False -> middle
        }
      })

    acc + middle
  })
}

fn parse(file: String) -> #(Pages, fn(String, String) -> Order) {
  let #(rules, pages) =
    file
    |> string.split("\n")
    |> list.fold(#([], []), fn(acc, line) {
      let #(rules, pages) = acc

      case string.contains(line, "|"), string.contains(line, ",") {
        True, False -> {
          #([line, ..rules], pages)
        }
        False, True -> {
          let nums = string.split(line, ",")

          #(rules, [nums, ..pages])
        }
        _, _ -> acc
      }
    })

  let final_rules = list.reverse(rules)
  io.debug(final_rules)

  let order = fn(a, b) {
    let lt = list.contains(final_rules, a <> "|" <> b)
    let gt = list.contains(final_rules, b <> "|" <> a)
    case lt, gt {
      True, _ -> Lt
      _, True -> Gt
      _, _ -> Eq
    }
  }

  #(list.reverse(pages), order)
}
