import gbf/vm.{type VirtualMachine}
import gleam/dict
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
  use vm <- result.try(vm.set_cell(vm, 2, 22))
}
