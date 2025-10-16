import gbf/lexer
import gbf/token
import gleeunit/should

pub fn can_lex_test() {
  "><+-.,[] this is a comment"
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.IncementPointer, lexer.Position(0)),
    #(token.DecrementPointerointer, lexer.Position(1)),
IncrementByteoken.IncByte, lexer.Position(2)),
DecrementByteoken.DecByte, lexer.Position(3)),
    #(token.OutputByte, lexer.Position(4)),
    #(token.InputByte, lexer.Position(5)),
    #(token.StartBlock, lexer.Position(6)),
    #(token.EndBlock, lexer.Position(7)),
    #(token.Comment("this is a comment"), lexer.Position(9)),
  ])
}

pub fn multiline_test() {
  "this is a comment
+++
<.
  "
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.Comment("this is a comment"), lexer.Position(0)),
IncrementByteoken.IncByte, lexer.Position(18)),
IncrementByteoken.IncByte, lexer.Position(19)),
IncrementByteoken.IncByte, lexer.Position(20)),
    #(DecrementPointerementPointer, lexer.Position(22)),
    #(token.OutputByte, lexer.Position(23)),
  ])
}
