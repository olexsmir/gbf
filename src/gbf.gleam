import gbf/eval
import gbf/lexer
import gbf/parser
import gbf/vm.{type VirtualMachine}
import gleam/list
import gleam/result
import gleam/string

pub type Error {
  Parser(reason: parser.Error)
  Eval(reason: eval.Error)
}

pub fn run(source: String) -> Result(VirtualMachine, Error) {
  let bvm =
    source
    |> string.split(on: "")
    |> list.map(char.to_code)
    |> vm.new

  use ast <- result.try(parse_ast(source))
  use bvm <- result.try(eval_ast(bvm, ast))

  Ok(bvm)
}

pub fn output(virtual_machine: VirtualMachine) -> String {
  vm.output(virtual_machine)
}

fn parse_ast(source: String) {
  source
  |> lexer.new
  |> lexer.lex
  |> parser.parse
  |> result.map_error(fn(e) { Parser(e) })
}

fn eval_ast(vm, ast) {
  eval.eval(vm, ast)
  |> result.map_error(fn(e) { Eval(e) })
}
