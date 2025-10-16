import char
import gbf/lexer
import gbf/parser.{type AST, type Block, type Command}
import gbf/token
import gbf/vm.{type VirtualMachine}
import gleam/list
import gleam/option
import gleam/result

pub type Error {
  PointerRanOffTape
  IntegerOverflow
  IntegerUnderflow
  EmptyInput
  InvalidChar(Int)
  UnexpectedCommand(pos: lexer.Position)
}

pub fn eval(vm: VirtualMachine, node: AST) -> Result(VirtualMachine, Error) {
  case node {
    parser.Leaf(command) -> eval_command(command, vm)
    parser.Node(block) -> eval_block(vm, block)
  }
}

fn eval_command(
  command: Command,
  vm: VirtualMachine,
) -> Result(VirtualMachine, Error) {
  case command {
    #(token.IncrementPointer, _) -> increment_pointer(vm)
    #(token.DecrementPointer, _) -> decrement_pointer(vm)
    #(token.IncrementByte, _) -> increment_byte(vm)
    #(token.DecrementByte, _) -> decrement_byte(vm)
    #(token.OutputByte, _) -> output_byte(vm)
    #(token.InputByte, _) -> input_byte(vm)

    #(token.StartBlock, pos) -> Error(UnexpectedCommand(pos))
    #(token.EndBlock, pos) -> Error(UnexpectedCommand(pos))
    #(_, pos) -> Error(UnexpectedCommand(pos))
  }
}

fn eval_block(vm: VirtualMachine, block: Block) -> Result(VirtualMachine, Error) {
  use acc_vm, child <- list.fold(block.children, Ok(vm))
  case child {
    parser.Leaf(command) -> result.try(acc_vm, eval_command(command, _))
    parser.Node(child_block) ->
      result.try(acc_vm, eval_child_block(_, child_block))
  }
}

fn eval_child_block(vm: VirtualMachine, child_block: Block) {
  let cell_value =
    vm.get_cell(vm, vm.pointer)
    |> option.unwrap(0)

  case cell_value > 0 {
    False -> Ok(vm)
    True -> {
      let new_acc = eval_block(vm, child_block)
      result.try(new_acc, eval_child_block(_, child_block))
    }
  }
}

fn increment_pointer(vm: VirtualMachine) {
  let pointer = vm.pointer + 1
  case pointer > vm.tape_size {
    True -> PointerRanOffTape |> Error
    False -> Ok(vm.VirtualMachine(..vm, pointer: pointer))
  }
}

fn decrement_pointer(vm: VirtualMachine) {
  let pointer = vm.pointer - 1
  case pointer < 0 {
    True -> PointerRanOffTape |> Error
    False -> Ok(vm.VirtualMachine(..vm, pointer: pointer))
  }
}

fn increment_byte(vm: VirtualMachine) {
  let cell_value =
    vm.get_cell(vm, vm.pointer)
    |> option.unwrap(0)

  let new_cell_value = cell_value + 1
  case new_cell_value > vm.cell_size {
    True -> IntegerOverflow |> Error
    False -> vm.set_cell(vm, vm.pointer, new_cell_value) |> Ok
  }
}

fn decrement_byte(vm: VirtualMachine) {
  let cell_value =
    vm.get_cell(vm, vm.pointer)
    |> option.unwrap(0)

  let new_cell_value = cell_value - 1
  case new_cell_value < 0 {
    True -> IntegerUnderflow |> Error
    False -> vm.set_cell(vm, vm.pointer, new_cell_value) |> Ok
  }
}

fn input_byte(vm: VirtualMachine) {
  case vm.input {
    [] -> EmptyInput |> Error
    [first, ..] -> {
      let new_input = list.drop(vm.input, 1)
      let vm = vm.set_cell(vm, vm.pointer, first)
      Ok(vm.VirtualMachine(..vm, input: new_input))
    }
  }
}

fn output_byte(vm: VirtualMachine) {
  let cell_value =
    vm.get_cell(vm, vm.pointer)
    |> option.unwrap(0)

  case char.from_code(cell_value) {
    "" -> Error(InvalidChar(cell_value))
    c ->
      vm.VirtualMachine(..vm, output: vm.output <> c)
      |> Ok
  }
}
