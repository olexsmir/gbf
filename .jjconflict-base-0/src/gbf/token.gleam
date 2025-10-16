pub type Token {
  /// Everything that is not one of the tokens below, considered the be a comment
  Comment(String)

  /// Increment the data pointer by one (to point to the next cell to the right).
  /// `>` symbol
  IncrementPointer

  /// Decrement the data pointer by one (to point to the next cell to the left).
  /// `<` symbol
  DecrementPointer

  /// Increment the byte at the data pointer by one.
  /// `+` symbol
  IncrementByte

  /// Decrement the byte at the data pointer by one.
  /// `-` symbol
  DecrementByte

  /// Output the byte at the data pointer.
  /// `.` symbol
  OutputByte

  /// Accept one byte of input, storing its value in the byte at the data pointer.
  /// `,` symbol
  InputByte

  /// If the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command.
  /// `[` symbol
  StartBlock

  /// If the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command.
  /// `]` symbol
  EndBlock

  /// End of file
  EOF
}
