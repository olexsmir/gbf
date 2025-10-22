import gbf/internal/token.{type Token}
import gleam/list
import gleam/string
import splitter

pub opaque type Lexer {
  Lexer(source: String, offset: Int, newlines: splitter.Splitter)
}

pub type Position {
  /// A token position in a wile, represented as offset of bytes
  Position(offset: Int)
}

pub fn new(source) {
  Lexer(source:, offset: 0, newlines: splitter.new(["\r\n", "\n"]))
}

pub fn lex(lexer: Lexer) -> List(#(Token, Position)) {
  do_lex(lexer, [])
  |> list.reverse
}

fn do_lex(lexer: Lexer, tokens: List(#(Token, Position))) {
  case next(lexer) {
    #(_, #(token.EndOfFile, _)) -> tokens
    #(lexer, token) -> do_lex(lexer, [token, ..tokens])
  }
}

fn next(lexer: Lexer) {
  case lexer.source {
    " " <> source | "\n" <> source | "\r" <> source | "\t" <> source ->
      advance(lexer, source, 1) |> next

    ">" <> source -> token(lexer, token.IncrementPointer, source, 1)
    "<" <> source -> token(lexer, token.DecrementPointer, source, 1)
    "+" <> source -> token(lexer, token.IncrementByte, source, 1)
    "-" <> source -> token(lexer, token.DecrementByte, source, 1)
    "." <> source -> token(lexer, token.OutputByte, source, 1)
    "," <> source -> token(lexer, token.InputByte, source, 1)
    "[" <> source -> token(lexer, token.StartBlock, source, 1)
    "]" <> source -> token(lexer, token.EndBlock, source, 1)

    _ ->
      case string.pop_grapheme(lexer.source) {
        Error(_) -> #(lexer, #(token.EndOfFile, Position(lexer.offset)))
        Ok(_) -> comment(lexer, lexer.offset)
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

fn token(
  lexer: Lexer,
  token: Token,
  source: String,
  offset: Int,
) -> #(Lexer, #(Token, Position)) {
  #(token, Position(offset: lexer.offset))
  |> advanced(lexer, source, offset)
}

fn comment(lexer: Lexer, start: Int) -> #(Lexer, #(Token, Position)) {
  let #(prefix, suffix) = splitter.split_before(lexer.newlines, lexer.source)
  let eaten = string.byte_size(prefix)
  let lexer = advance(lexer, suffix, eaten)

  #(lexer, #(token.Comment(prefix), Position(start)))
}
