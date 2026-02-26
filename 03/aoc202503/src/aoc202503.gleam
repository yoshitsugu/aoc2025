// import gleam/io

import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

const digit_length = 12

fn find_max_joltage(digits: List(Int), rest_length: Int) -> List(Int) {
  case rest_length {
    0 -> []
    _ -> {
      case list.take(digits, list.length(digits) - rest_length + 1) {
        [] -> []
        target_digits -> {
          let #(max_digit, max_digit_index) =
            list.index_fold(target_digits, from: #(0, 0), with: fn(acc, d, i) {
              case acc {
                #(acc_d, _) if d > acc_d -> #(d, i)
                _ -> acc
              }
            })
          list.append(
            [max_digit],
            find_max_joltage(
              list.drop(digits, max_digit_index + 1),
              rest_length - 1,
            ),
          )
        }
      }
    }
  }
}

fn max_joltage(rating: String) -> Int {
  let digits =
    string.to_graphemes(rating)
    |> list.map(fn(r) { result.unwrap(int.parse(r), 0) })
  list.fold(
    find_max_joltage(digits, digit_length),
    from: 0,
    with: fn(acc, digit) { acc * 10 + digit },
  )
}

pub fn main() -> Nil {
  let filepath = "data/input"
  case simplifile.read(from: filepath) {
    Ok(content) -> {
      let ratings = string.split(content, on: "\n")
      let joltages = list.map(ratings, max_joltage)
      echo int.sum(joltages)
      Nil
    }
    Error(_) -> Nil
  }
}
