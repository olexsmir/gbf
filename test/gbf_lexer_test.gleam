import gbf/lexer.{Position}
import gbf/token
import gleeunit/should

pub fn can_lex_test() {
  "><+-.,[]"
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.IncPointer, Position(0)),
    #(token.DecPointer, Position(1)),
    #(token.IncByte, Position(2)),
    #(token.DecByte, Position(3)),
    #(token.OutputByte, Position(4)),
    #(token.InputByte, Position(5)),
    #(token.StartBlock, Position(6)),
    #(token.EndBlock, Position(7)),
  ])
}

pub fn can_lex_with_comments_test() {
  "><+-.,[] this is a comment"
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.IncPointer, Position(0)),
    #(token.DecPointer, Position(1)),
    #(token.IncByte, Position(2)),
    #(token.DecByte, Position(3)),
    #(token.OutputByte, Position(4)),
    #(token.InputByte, Position(5)),
    #(token.StartBlock, Position(6)),
    #(token.EndBlock, Position(7)),
    #(token.Comment("this is a comment"), Position(9)),
  ])
}

pub fn can_lex_multiline_test() {
  "this is a comment
  "
  |> lexer.new
  |> lexer.lex
  |> should.equal([
    #(token.Comment("this is a comment"), Position(0)),
  ])
}
