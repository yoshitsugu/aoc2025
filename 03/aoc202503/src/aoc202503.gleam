// import gleam/io

import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

const target_digits_count = 12

pub type ParseError {
  InvalidDigit(String)
  EmptyRating
}

fn pick_max_digit_with_index(digits: List(Int)) -> #(Int, Int) {
  list.index_fold(digits, from: #(0, 0), with: fn(acc, digit, index) {
    case acc {
      #(max_digit, _) if digit > max_digit -> #(digit, index)
      _ -> acc
    }
  })
}

fn find_max_digits(digits: List(Int), remaining: Int) -> List(Int) {
  case remaining {
    0 -> []
    _ -> {
      case list.take(digits, list.length(digits) - remaining + 1) {
        [] -> []
        selectable_digits -> {
          let #(max_digit, max_digit_index) =
            pick_max_digit_with_index(selectable_digits)
          [
            max_digit,
            ..find_max_digits(
              list.drop(digits, max_digit_index + 1),
              remaining - 1,
            ),
          ]
        }
      }
    }
  }
}

fn parse_digit(digit_text: String) -> Result(Int, ParseError) {
  case int.parse(digit_text) {
    Ok(digit) -> Ok(digit)
    Error(_) -> Error(InvalidDigit(digit_text))
  }
}

fn rating_to_max_joltage(rating: String) -> Result(Int, ParseError) {
  case rating {
    "" -> Error(EmptyRating)
    _ -> {
      let digits_result =
        string.to_graphemes(rating)
        |> list.map(parse_digit)
        |> result.all

      result.map(digits_result, fn(digits) {
        list.fold(
          find_max_digits(digits, target_digits_count),
          from: 0,
          with: fn(acc, digit) { acc * 10 + digit },
        )
      })
    }
  }
}

fn parse_input(content: String) -> List(String) {
  string.split(content, on: "\n")
  |> list.map(string.trim)
  |> list.filter(fn(line) { line != "" })
}

pub fn solve(ratings: List(String)) -> Result(Int, ParseError) {
  ratings
  |> list.map(rating_to_max_joltage)
  |> result.all
  |> result.map(int.sum)
}

pub fn solve_content(content: String) -> Result(Int, ParseError) {
  content
  |> parse_input
  |> solve
}

fn parse_error_to_string(error: ParseError) -> String {
  case error {
    InvalidDigit(digit) -> "invalid digit: " <> digit
    EmptyRating -> "empty rating line"
  }
}

pub fn main() -> Nil {
  case simplifile.read(from: "data/input") {
    Ok(content) -> {
      case solve_content(content) {
        Ok(total) -> {
          let _ = echo total
          Nil
        }
        Error(error) -> {
          let _ = echo parse_error_to_string(error)
          Nil
        }
      }
    }
    Error(_) -> {
      let _ = echo "failed to read input file"
      Nil
    }
  }
}
