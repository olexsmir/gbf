import gbf
import gleam/io

pub fn main() -> Nil {
  let assert Ok(vm) =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
    |> gbf.run

  vm
  |> gbf.output
  |> io.println
}
