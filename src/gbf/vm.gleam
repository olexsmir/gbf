import char
import gleam/dict.{type Dict}
import gleam/list
import gleam/result

pub const tape_size = 30_000

pub const cell_size = 255

pub type Error {
  PointerRanOffTape
  IntegerOverflow
  IntegerUnderflow
  EmptyInput
  InvalidChar(Int)
}

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

pub fn output(vm: VirtualMachine) -> String {
  vm.output
}

pub fn get_cell(vm: VirtualMachine, pointer: Index) -> Result(Index, Error) {
  use pointer <- result.try(validate_tape_size(pointer))

  case dict.get(vm.cells, pointer) {
    Ok(value) -> Ok(value)
    Error(_) -> Ok(0)
  }
}

pub fn set_cell(
  vm: VirtualMachine,
  pointer: Index,
  value: Int,
) -> Result(VirtualMachine, Error) {
  use pointer <- result.try(validate_tape_size(pointer))
  use value <- result.try(validate_cell_size(value))

  let new_cells = dict.insert(vm.cells, pointer, value)
  VirtualMachine(..vm, cells: new_cells)
  |> Ok
}

pub fn set_pointer(
  vm: VirtualMachine,
  pointer: Index,
) -> Result(VirtualMachine, Error) {
  use pointer <- result.try(validate_tape_size(pointer))

  VirtualMachine(..vm, pointer:)
  |> Ok
}

pub fn input_byte(vm: VirtualMachine) -> Result(VirtualMachine, Error) {
  case vm.input {
    [] -> Error(EmptyInput)
    [first, ..] -> {
      use vm <- result.try(set_cell(vm, vm.pointer, first))

      VirtualMachine(..vm, input: list.drop(vm.input, 1))
      |> Ok
    }
  }
}

pub fn output_byte(vm: VirtualMachine) -> Result(VirtualMachine, Error) {
  use cell_value <- result.try(get_cell(vm, vm.pointer))

  case char.from_code(cell_value) {
    "" -> Error(InvalidChar(cell_value))
    c ->
      VirtualMachine(..vm, output: vm.output <> c)
      |> Ok
  }
}

fn validate_tape_size(pointer: Index) {
  case pointer {
    p if p > tape_size -> Error(PointerRanOffTape)
    p if p < 0 -> Error(PointerRanOffTape)
    _ -> Ok(pointer)
  }
}

fn validate_cell_size(value: Int) {
  case value {
    v if v > cell_size -> Error(IntegerOverflow)
    v if v < 0 -> Error(IntegerUnderflow)
    _ -> Ok(value)
  }
}
