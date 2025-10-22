import argv
import gbf
import gleam/io
import simplifile

pub fn main() -> Nil {
  case argv.load().arguments {
    [filename] -> {
      let assert Ok(source) = simplifile.read(filename)
      let assert Ok(virtual_machine) = gbf.run(source)

      virtual_machine
      |> gbf.output
      |> io.println
    }
    _ -> io.println("usage: ./program filename.bf")
  }
}
