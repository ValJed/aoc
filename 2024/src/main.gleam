import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub type Disk =
  List(Int)

pub fn main() {
  let filepath = "./data/test"
  let filecontent = result.unwrap(simplifile.read(filepath), "")
  let disk = filecontent |> parse
  io.debug(disk)
}

fn parse(file: String) -> Disk {
  file
  |> string.split("\n")
  |> list.first()
  |> result.unwrap("")
  |> string.to_graphemes()
  |> list.filter_map(fn(char) { int.parse(char) })
}
