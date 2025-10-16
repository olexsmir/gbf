import gbf/lexer
import gbf/parser.{type AST, type Block, type Command}
import gbf/token
import gbf/vm.{type VirtualMachine}
import gleam/list
import gleam/option.{type Option, None, Some}
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

  case to_char(cell_value) {
    None -> InvalidChar(cell_value) |> Error
    Some(char) -> {
      let new_output = vm.output <> char
      Ok(vm.VirtualMachine(..vm, output: new_output))
    }
  }
}

fn to_char(code: Int) -> Option(String) {
  case code {
    0x0A -> Some("\n")
    0x20 -> Some(" ")
    0x21 -> Some("!")
    0x22 -> Some("\"")
    0x23 -> Some("#")
    0x24 -> Some("$")
    0x25 -> Some("%")
    0x26 -> Some("&")
    0x27 -> Some("'")
    0x28 -> Some("(")
    0x29 -> Some(")")
    0x2A -> Some("*")
    0x2B -> Some("+")
    0x2C -> Some(",")
    0x2D -> Some("-")
    0x2E -> Some(".")
    0x2F -> Some("/")
    0x30 -> Some("0")
    0x31 -> Some("1")
    0x32 -> Some("2")
    0x33 -> Some("3")
    0x34 -> Some("4")
    0x35 -> Some("5")
    0x36 -> Some("6")
    0x37 -> Some("7")
    0x38 -> Some("8")
    0x39 -> Some("9")
    0x3A -> Some(":")
    0x3B -> Some(";")
    0x3C -> Some("<")
    0x3D -> Some("=")
    0x3E -> Some(">")
    0x3F -> Some("?")
    0x40 -> Some("@")
    0x41 -> Some("A")
    0x42 -> Some("B")
    0x43 -> Some("C")
    0x44 -> Some("D")
    0x45 -> Some("E")
    0x46 -> Some("F")
    0x47 -> Some("G")
    0x48 -> Some("H")
    0x49 -> Some("I")
    0x4A -> Some("J")
    0x4B -> Some("K")
    0x4C -> Some("L")
    0x4D -> Some("M")
    0x4E -> Some("N")
    0x4F -> Some("O")
    0x50 -> Some("P")
    0x51 -> Some("Q")
    0x52 -> Some("R")
    0x53 -> Some("S")
    0x54 -> Some("T")
    0x55 -> Some("U")
    0x56 -> Some("V")
    0x57 -> Some("W")
    0x58 -> Some("X")
    0x59 -> Some("Y")
    0x5A -> Some("Z")
    0x5B -> Some("[")
    0x5C -> Some("\\")
    0x5D -> Some("]")
    0x5E -> Some("^")
    0x5F -> Some("_")
    0x60 -> Some("`")
    0x61 -> Some("a")
    0x62 -> Some("b")
    0x63 -> Some("c")
    0x64 -> Some("d")
    0x65 -> Some("e")
    0x66 -> Some("f")
    0x67 -> Some("g")
    0x68 -> Some("h")
    0x69 -> Some("i")
    0x6A -> Some("j")
    0x6B -> Some("k")
    0x6C -> Some("l")
    0x6D -> Some("m")
    0x6E -> Some("n")
    0x6F -> Some("o")
    0x70 -> Some("p")
    0x71 -> Some("q")
    0x72 -> Some("r")
    0x73 -> Some("s")
    0x74 -> Some("t")
    0x75 -> Some("u")
    0x76 -> Some("v")
    0x77 -> Some("w")
    0x78 -> Some("x")
    0x79 -> Some("y")
    0x7A -> Some("z")
    0x7B -> Some("{")
    0x7C -> Some("|")
    0x7D -> Some("}")
    0x7E -> Some("~")
    _ -> None
  }
}
