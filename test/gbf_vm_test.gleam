import char
import gbf/vm.{type VirtualMachine}
import gleam/result
import gleeunit/should

fn setup(input) -> VirtualMachine {
  vm.new(input)
}

pub fn get_cell_test() {
  let vm = setup([])

  vm.get_cell(vm, 3)
  |> should.equal(Ok(0))
}

pub fn get_cell_out_of_tape_test() {
  let vm = setup([])

  vm.get_cell(vm, vm.tape_size + 1)
  |> should.equal(Error(vm.PointerRanOffTape))
}

pub fn set_cell_test() {
  let vm = setup([])

  vm.set_cell(vm, 2, 22)
  |> should.be_ok
}

pub fn set_cell_errors_test() {
  let vm = setup([])

  vm.set_cell(vm, vm.tape_size + 1, 22)
  |> should.be_error

  vm.set_cell(vm, 2, vm.cell_size + 1)
  |> should.be_error
}

pub fn set_pointer_test() {
  let vm = setup([])

  vm.set_pointer(vm, 2)
  |> should.be_ok
}

pub fn output_byte_empty_test() {
  let vm = setup([])

  vm.output_byte(vm)
  |> should.equal(Error(vm.InvalidChar(0)))
}

pub fn output_byte_test() {
  let vm = setup([char.to_code("a")])
  use vm <- result.try(vm.output_byte(vm))

  should.equal(vm.output, "a")
  Ok("")
}

pub fn input_byte_empty_test() {
  let vm = setup([])

  vm.input_byte(vm)
  |> should.equal(Error(vm.EmptyInput))
}

pub fn input_byte_test() {
  let vm = setup([char.to_code("a"), char.to_code("b")])
  use vm <- result.try(vm.input_byte(vm))

  should.equal(vm.input, [char.to_code("b")])
  Ok("")
}
