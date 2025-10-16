import gbf/lexer.{type Position, Position}
import gbf/token.{type Token}
import gleam/list
import gleam/pair
import gleam/result

pub type AST {
  Leaf(Command)
  Node(Block)
}

pub type Command =
  #(Token, Position)

pub type Block {
  Block(children: List(AST), position: Position)
}

pub type Error {
  FinishedTooEarly
  UnexpectedCommand
  UnexpectedBlock
}
pub fn parse(tokens: List(#(Token, Position))) -> Result(AST, Error) {
  let root = Node(children: [], position: Position(0))

  use #(ast, remaining_tokens) <- result.try(parse_tokens(tokens, root))

  case remaining_tokens {
    [] -> Ok(ast)
    _ -> Error(FinishedTooEarly)
  }
}

fn parse_tokens(tokens: List(#(Token, Position)), node: AST) {
  case tokens {
    [] -> Ok(#(node, []))
    [token, ..rest] -> {
      case token {
        #(token.StartBlock, _) -> parse_block(token, rest, node)
        #(token.EndBlock, _) -> parse_block_end(rest, node)
        _ -> parse_command(token, rest, node)
      }
    }
  }
}

fn parse_block_end(tokens: List(#(Token, Position)), node: AST) {
  Ok(#(node, tokens))
}

fn parse_block(token, tokens, node) {
  case node {
    Leaf(_) -> Error(UnexpectedCommand)
    Node(children, position) -> {
      let child_block = Node(children: [], position: pair.second(token))
      use #(parsed_child_block, remaining_tokens) <- result.try(parse_tokens(
        tokens,
        child_block,
      ))

      let new_children = list.append(block.children, [parsed_child_block])
      let new_node =
        Node(Block(children: new_children, position: block.position))

      parse_tokens(remaining_tokens, new_node)
    }
  }
}

fn parse_command(
  token: #(Token, Position),
  tokens: List(#(Token, Position)),
  node: AST,
) {
  case node {
    Leaf(_) -> Error(UnexpectedBlock)
    Node(children, position) -> {
      let command = Leaf(token)
      let node =
        Node(Block(
          children: list.append(block.children, [command]),
          position: block.position,
        ))

      parse_tokens(tokens, node)
    }
  }
}
