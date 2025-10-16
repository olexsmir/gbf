import gbf/lexer
import gbf/token
import gleeunit/should

pub fn can_lex_test() {
  "><+-.,[]"
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.IncPointer, lexer.Position(0)),
    #(token.DecPointer, lexer.Position(1)),
    #(token.IncByte, lexer.Position(2)),
    #(token.DecByte, lexer.Position(3)),
    #(token.OutputByte, lexer.Position(4)),
    #(token.InputByte, lexer.Position(5)),
    #(token.StartBlock, lexer.Position(6)),
    #(token.EndBlock, lexer.Position(7)),
  ])
}

pub fn can_lex_with_comments_test() {
  "><+-.,[] this is comment"
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.IncPointer, lexer.Position(0)),
    #(token.DecPointer, lexer.Position(1)),
    #(token.IncByte, lexer.Position(2)),
    #(token.DecByte, lexer.Position(3)),
    #(token.OutputByte, lexer.Position(4)),
    #(token.InputByte, lexer.Position(5)),
    #(token.StartBlock, lexer.Position(6)),
    #(token.EndBlock, lexer.Position(7)),
    #(token.Comment("this is a comment"), lexer.Position(9)),
  ])
}
