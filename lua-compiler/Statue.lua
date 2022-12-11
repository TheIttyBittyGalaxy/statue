-- Stores reference information about the Statue language that is used throughout the compiler.

return {

    -- A table mapping token types to the string pattern that can be used to find them.
    -- Patterns are ordered by precedence. In situtations where multiple patterns match,
    -- the pattern further up the list will be considered the correct match.
    --
    -- The END_OF_FILE, STRING_LITERAL, and NUMBER_LITERAL tokens are all
    -- special cases handled by FileTokeniser
    --
    -- For more about string patterns in lua, see the reference manual:
    -- http://www.lua.org/manual/5.4/manual.html#6.4.1

    token_pattern = {

        -- Symbols
        { "ARROW", "%->" },

        { "ADD", "%+" },
        { "SUB", "%-" },
        { "MUL", "%*" },
        { "DIV", "%/" },
        { "POW", "%^" },

        { "ASSIGN", "%=" },
        { "COLON", "%:" },
        { "COMMA", "%," },
        { "DOT", "%." },

        { "TRIANGLE_R", "%>" },
        { "TRIANGLE_L", "%<" },
        { "BRACKET_L", "%(" },
        { "BRACKET_R", "%)" },
        { "SQUARE_L", "%[" },
        { "SQUARE_R", "%]" },

        -- Keywords
        { "KEY_STRUCT", "struct" },
        { "KEY_FUNCT", "funct" },
        { "KEY_DEF", "def" },
        { "KEY_END", "end" },
        { "KEY_LET", "let" },
        { "KEY_IF", "if" },
        { "KEY_DO", "do" },

        -- Identities
        { "IDENTITY", "%a[%w_]*" },
    }
}
