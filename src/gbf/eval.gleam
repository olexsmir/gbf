import char
import gbf/lexer
import gbf/parser.{type AST, type Block, type Command}
import gbf/token
import gbf/vm.{type VirtualMachine}
import gleam/list
import gleam/option
import gleam/result

pub type Error {
  VmError(reason: vm.Error)
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
    #(token.IncrementPointer, _) -> {
      vm.set_pointer(vm, vm.pointer + 1)
      |> result.map_error(VmError)
    }
    #(token.DecrementPointer, _) -> {
      vm.set_pointer(vm, vm.pointer - 1)
      |> result.map_error(VmError)
    }

    #(token.IncrementByte, _) -> increment_byte(vm)
    #(token.DecrementByte, _) -> decrement_byte(vm)

    #(token.InputByte, _) -> vm.input_byte(vm) |> result.map_error(VmError)
    #(token.OutputByte, _) -> vm.output_byte(vm) |> result.map_error(VmError)

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

fn increment_byte(vm: VirtualMachine) {
  let cell_value =
    vm.get_cell(vm, vm.pointer)
    |> option.unwrap(0)

  let cell_value = cell_value + 1
  vm.set_cell(vm, vm.pointer, cell_value)
  |> result.map_error(VmError)
}

fn decrement_byte(vm: VirtualMachine) {
  let cell_value =
    vm.get_cell(vm, vm.pointer)
    |> option.unwrap(0)

  let cell_value = cell_value - 1
  vm.set_cell(vm, vm.pointer, cell_value)
  |> result.map_error(VmError)
}
