import gbf/internal/lexer
import gbf/internal/token
import gleeunit/should

pub fn can_lex_test() {
  "><+-.,[] this is a comment"
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.IncrementPointer, lexer.Position(0)),
    #(token.DecrementPointer, lexer.Position(1)),
    #(token.IncrementByte, lexer.Position(2)),
    #(token.DecrementByte, lexer.Position(3)),
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
    #(token.IncrementByte, lexer.Position(18)),
    #(token.IncrementByte, lexer.Position(19)),
    #(token.IncrementByte, lexer.Position(20)),
    #(token.DecrementPointer, lexer.Position(22)),
    #(token.OutputByte, lexer.Position(23)),
  ])
}
