import gbf/internal/ascii
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
///
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

/// Returns the accumulated output string from the virtual machine.
///
pub fn output(vm: VirtualMachine) -> String {
  vm.output
}

/// Gets the value of the cell at the specified pointer.
/// Returns an error if the pointer is out of bounds.
///
/// ```gleam
/// get_cell(vm, 0)  // Ok(0)
/// get_cell(vm, -1) // Error(PointerRanOffTape)
/// ```
pub fn get_cell(vm: VirtualMachine, pointer: Index) -> Result(Index, Error) {
  use pointer <- result.try(validate_tape_size(pointer))

  case dict.get(vm.cells, pointer) {
    Ok(value) -> Ok(value)
    Error(_) -> Ok(0)
  }
}

/// Sets the value of the cell at the specified pointer.
///
/// Returns an updated virtual machine if successful, or an error if:
/// - The pointer is out of bounds (< 0 or > 30,000)
/// - The value is out of bounds (< 0 or > 255)
///
/// ```gleam
/// set_cell(vm, 0, 65)  // Ok(...)
/// set_cell(vm, 0, 256) // Error(IntegerOverflow)
/// ```
pub fn set_cell(
  vm: VirtualMachine,
  pointer: Index,
  value: Int,
) -> Result(VirtualMachine, Error) {
  use pointer <- result.try(validate_tape_size(pointer))
  use value <- result.try(validate_cell_size(value))
  let cells = dict.insert(vm.cells, pointer, value)

  VirtualMachine(..vm, cells:)
  |> Ok
}

/// Moves the data pointer to the specified position.
/// Returns error if pointer is out of bounds.
///
/// ```gleam
/// set_pointer(vm, 100) // Ok(...)
/// set_pointer(vm, -1)  // Error(PointerRanOffTape)
/// ```
pub fn set_pointer(
  vm: VirtualMachine,
  pointer: Index,
) -> Result(VirtualMachine, Error) {
  use pointer <- result.try(validate_tape_size(pointer))

  VirtualMachine(..vm, pointer:)
  |> Ok
}

/// Reads a byte from the input stream and stores it in the current cell.
///
/// Consumes the first byte from the input list and writes it to the cell
/// at the current pointer position.
/// Returns an error if the input is empty.
///
/// ```gleam
/// input_byte(vm)       // Ok(...)
/// input_byte(empty_vm) // Error(EmptyInput)
/// ```
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

/// Reads the value from the current cell and appends it to the output as a character.
///
/// Converts the cell value to an ASCII character and adds it to the output string.
/// Returns an error if the cell value is not a valid ASCII code point.
///
pub fn output_byte(vm: VirtualMachine) -> Result(VirtualMachine, Error) {
  use cell_value <- result.try(get_cell(vm, vm.pointer))

  case ascii.from_code(cell_value) {
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
