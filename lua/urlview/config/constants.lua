local constants = {
  -- SEE: lua pattern matching (https://riptutorial.com/lua/example/20315/lua-pattern-matching)
  -- regex equivalent: [A-Za-z0-9@:%._+~#=/\-?&]*
  pattern = "[%w@:%%._+~#=/%-?&]*",
  http_pattern = "https?://",
  www_pattern = "www%.",
}

return constants
