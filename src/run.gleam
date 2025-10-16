import gbf
import gleam/io

pub fn main() -> Nil {
  let input =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

  let assert Ok(vm) = gbf.run(input)

  vm
  |> gbf.output
  |> io.println
}
