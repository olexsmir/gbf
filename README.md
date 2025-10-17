# gbf

I was bored and made this :star: gleaming brainfuck interpreter.

## How to use?
### As library
```gleam
pub fn main() -> Nil {
  let input =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

  let assert Ok(virtual_machine) = gbf.run(input)

  virtual_machine
  |> vm.output
  |> io.println
}
```

### As CLI tool

TODO: yet to be implemented
