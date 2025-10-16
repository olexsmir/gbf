import gbf/lexer.{Position}
import gbf/parser.{Block, Leaf, Node}
import gbf/token.{IncrementByte, IncrementPointer}
import gleeunit/should

pub fn should_parse_test() {
  "+[>++]>"
  |> lexer.new
  |> lexer.lex
  |> parser.parse
  |> should.equal(
    Ok(
      Node(
        Block(position: Position(0), children: [
          Leaf(#(IncrementByte, Position(0))),
          Node(
            Block(position: Position(1), children: [
              Leaf(#(IncrementPointer, Position(2))),
              Leaf(#(IncrementByte, Position(3))),
              Leaf(#(IncrementByte, Position(4))),
            ]),
          ),
          Leaf(#(IncrementPointer, Position(6))),
        ]),
      ),
    ),
  )
}
