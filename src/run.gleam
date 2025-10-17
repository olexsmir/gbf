import gbf
import gbf/vm
import gleam/io

pub fn main() -> Nil {
  let input =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

  let assert Ok(virtual_machine) = gbf.run(input)

  virtual_machine
  |> vm.output
  |> io.println
}
