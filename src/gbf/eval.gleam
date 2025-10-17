import gbf/lexer
import gbf/parser.{type AST, type Block, type Command}
import gbf/token
import gbf/vm.{type VirtualMachine}
import gleam/int
import gleam/list
import gleam/result

pub type Error {
  /// An unexpected command was encountered at the given position.
  UnexpectedCommand(pos: lexer.Position)

  /// An error occurred in the virtual machine
  VmError(reason: vm.Error, pos: lexer.Position)
}

/// Evaluates an AST node against the virtual machine.
///
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
    #(token.IncrementPointer, pos) ->
      vm.set_pointer(vm, vm.pointer + 1) |> wrap_vm_error(pos)
    #(token.DecrementPointer, pos) ->
      vm.set_pointer(vm, vm.pointer - 1) |> wrap_vm_error(pos)

    #(token.IncrementByte, pos) -> mut_byte(vm, int.add) |> wrap_vm_error(pos)
    #(token.DecrementByte, pos) ->
      mut_byte(vm, int.subtract) |> wrap_vm_error(pos)

    #(token.InputByte, pos) -> vm.input_byte(vm) |> wrap_vm_error(pos)
    #(token.OutputByte, pos) -> vm.output_byte(vm) |> wrap_vm_error(pos)

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
  use cell_value <- result.try(
    vm.get_cell(vm, vm.pointer)
    |> result.map_error(VmError(_, child_block.position)),
  )

  case cell_value > 0 {
    False -> Ok(vm)
    True -> {
      let new_acc = eval_block(vm, child_block)
      result.try(new_acc, eval_child_block(_, child_block))
    }
  }
}

fn mut_byte(vm: VirtualMachine, op: fn(Int, Int) -> Int) {
  use cell_value <- result.try(vm.get_cell(vm, vm.pointer))

  let cell_value = op(cell_value, 1)
  vm.set_cell(vm, vm.pointer, cell_value)
}

fn wrap_vm_error(
  r: Result(VirtualMachine, vm.Error),
  pos: lexer.Position,
) -> Result(VirtualMachine, Error) {
  result.map_error(r, VmError(_, pos))
}
