package dev.syncclient.pling.lexer;

public enum Token {
    COMMENT, // //Comment - skip
    STRING, // `String` (ignore \escape)
    NUMBER, // 123 or 0x123 or 12.3, nothing negative yet
    ASSIGN, // =
    REFERENCE, // #
    OPEN, // [
    CLOSE, // ]
    COMMA, // ,
    DOT, // .
    END, // ;
    IDENTIFIER; // Identifier

    @Override
    public String toString() {
        return name().toLowerCase();
    }

    public AbstractToken createToken(String value) {
        // TODO

        return new AbstractToken(value) {
            @Override
            public Token getType() {
                return Token.this;
            }
        };
    }

    public static abstract class AbstractToken {
        private String value;

        public AbstractToken(String value) {
            this.value = value;
        }

        public abstract Token getType();

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }
    }
}
