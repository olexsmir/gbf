import gbf/lexer
import gbf/parser

pub fn main() {
  "+.[<>]"
  |> lexer.new
  |> lexer.lex
  |> parser.parse
  |> echo
}
