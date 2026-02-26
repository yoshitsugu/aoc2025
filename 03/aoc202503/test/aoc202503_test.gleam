import aoc202503 as solver
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn solve_content_success_test() {
  let content = "123456789012\n111111111111\n"
  assert solver.solve_content(content) == Ok(234567900123)
}

pub fn solve_content_invalid_digit_test() {
  assert solver.solve_content("123x56789012\n") == Error(solver.InvalidDigit("x"))
}
