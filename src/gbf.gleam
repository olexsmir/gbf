import char
import gbf/eval
import gbf/lexer
import gbf/parser
import gbf/vm
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  let input =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

  let vm =
    input
    |> string.split(on: "")
    |> list.map(char.to_code)
    |> vm.new

  let ast = input |> lexer.new() |> lexer.lex |> parser.parse()
  case ast {
    Error(_) -> panic as "not yay failed"
    Ok(ast) -> {
      use res <- result.try(eval.eval(vm, ast))
      io.println("input: " <> input)
      io.println("input: " <> res.output)

      Ok("")
    }
  }
}
