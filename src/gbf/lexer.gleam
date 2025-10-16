import gbf/token.{type Token}
import string
import gleam/list

pub opaque type Lexer {
  Lexer(source: String, offset: Int)
}

pub type Position {
  Position(offset: Int)
}

pub fn new(source) {
  Lexer(source:, offset: 0)
}

pub fn lex(lexer: Lexer) -> List(#(Token, Position)) {
  do_lex(lexer, [])
  |> list.reverse
}

fn do_lex(lexer: Lexer, tokens: List(#(Token, Position))) {
  todo
  // case next(lexer) {}
}

fn next(lexer: Lexer) {
  case lexer.source {
    ">" <> source -> token(lexer, token.IncPointer)
    "<" <> source -> token(lexer, token.DecPointer)
    "+" <> source -> token(lexer, token.IncByte)
    "-" <> source -> token(lexer, token.DecByte)
    "." <> source -> token(lexer, token.OutputByte)
    "," <> source -> token(lexer, token.InputByte)
    "[" <> source -> token(lexer, token.StartBlock)
    "]" <> source -> token(lexer, token.EndBlock)
    _ -> case string {
    }
  }
}

fn advance(lexer, source, offset) {
  Lexer(..lexer, source:, offset: lexer.offset + offset)
}

fn advanced(
  token: #(Token, Position),
  lexer: Lexer,
  source: String,
  offset: Int,
) -> #(Lexer, #(Token, Position)) {
  #(advance(lexer, source, offset), token)
}

fn token(lexer: Lexer, token: Token, source, offset) {
  #(token, Position(offset: lexer.offset))
  |> advanced(lexer, source, offset)
}
