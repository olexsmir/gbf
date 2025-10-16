# gbf

I was bored and made this :star: gleaming brainfuck interpreter.

## How to use?
### As library
```gleam
import gbf
import gleam/io

pub fn main() -> Nil {
  let input =
    "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

  let assert Ok(vm) = gbf.run(input)

  vm
  |> gbf.output
  |> io.println
// > "Hello World!"
}
```

### As CLI tool

TODO: yet to be implemented
