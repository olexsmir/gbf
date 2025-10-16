import gleam/string

pub fn to_code(s: String) {
  case <<s:utf8>> {
    // lowercase a(ansii 97) to z(ansii 122)
    <<char:int>> if char >= 97 -> char - 96

    // uppercase A(ansii 65) to Z(ansii 90), and special symbols
    <<char:int>> -> char - 38

    _ -> 0
  }
}

pub fn from_code(code: Int) {
  case code {
    c if c == 0x0A || c >= 0x20 && c <= 0x7E -> {
      case string.utf_codepoint(code) {
        Ok(codepoint) -> string.from_utf_codepoints([codepoint])
        Error(_) -> ""
      }
    }
    _ -> ""
  }
}
