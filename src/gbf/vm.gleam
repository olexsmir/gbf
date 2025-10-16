import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}

pub const tape_size = 30_000

pub const cell_size = 255

/// Machine Model
/// The machine model we are going to use for this interpreter is very simple:
///   - Our memory consists of 30,000 cells (1000 rows * 30 columns).
///   - There's a data pointer which points to a specific cell and is initialized at
///     the leftmost cell, an error will be reported if the pointer runs off the
///     tape at either end.
///     pointer = 0
///   - A data cell is 8 bits, and an error will be reported if the program tries
///     to perform under- or overflow, i.e. decrement 0 or increment 255.
///   - Two streams of bytes for input and output using the ASCII character
///     encoding.
pub type VirtualMachine {
  VirtualMachine(pointer: Index, cells: Cells, output: String, input: List(Int))
}

pub type Cells =
  Dict(Int, Int)

pub type Index =
  Int

pub fn new(input: List(Int)) -> VirtualMachine {
  VirtualMachine(input:, pointer: 0, cells: dict.new(), output: "")
}

pub fn get_cell(pointer: Index, vm: VirtualMachine) -> Option(Int) {
  case dict.get(vm.cells, pointer) {
    Ok(value) -> Some(value)
    Error(_) -> None
  }
}

pub fn set_cell(
  pointer: Index,
  value: Int,
  vm: VirtualMachine,
) -> VirtualMachine {
  let new_cells = dict.insert(vm.cells, pointer, value)
  VirtualMachine(..vm, cells: new_cells)
}
