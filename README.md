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

  let assert Ok(virtual_machine) = gbf.run(input)

  virtual_machine
  |> gbf.output
  |> io.println
//>  Hello World!
}
```

### As CLI tool
```bash
gleam run -m run ./examples/helloworld.bf
#> Hello World!
```
