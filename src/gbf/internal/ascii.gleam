import gleam/bit_array
import gleam/string

pub fn to_code(s: String) {
  let bytes = bit_array.from_string(s)
  case bit_array.byte_size(bytes) {
    1 ->
      case bytes {
        <<value>> -> value
        _ -> 0
      }
    _ -> 0
  }
}

pub fn from_code(code: Int) {
  case code {
    c if c >= 1 && c <= 255 -> {
      case string.utf_codepoint(code) {
        Ok(codepoint) -> string.from_utf_codepoints([codepoint])
        Error(_) -> ""
      }
    }
    _ -> ""
  }
}
