import gleam/dict.{type Dict, insert}
import gleam/io
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  let collec = get_collec([30, 40, 50])
  io.debug(collec)
}

pub fn get_collec(nums: List(Int)) -> #(Dict(Int, Int)) {
  list.fold(nums, #(dict.new()), fn(acc, cur) { #(insert(acc.0, cur, cur)) })
}
