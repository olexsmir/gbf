import gbf
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn should_run_hello_world_test() {
  let input =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

  let assert Ok(bvm) = gbf.run(input)

  bvm
  |> gbf.output
  |> should.equal("Hello World!\n")
}
