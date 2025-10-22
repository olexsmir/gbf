import gbf
import gbf/internal/vm
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
  |> vm.output
  |> should.equal("Hello World!\n")
}
