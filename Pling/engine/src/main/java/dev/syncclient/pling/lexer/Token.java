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
    IDENTIFIER, // Identifier
    ANY, // internal use only
    EOF; // internal use only

    @Override
    public String toString() {
        return name().toLowerCase();
    }

    public WithData createToken(String value) {
        return new WithData(value) {
            @Override
            public Token getType() {
                return Token.this;
            }
        };
    }

    public static abstract class WithData {
        private String value;

        public WithData(String value) {
            this.value = value;
        }

        public abstract Token getType();

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }

        @Override
        public String toString() {
            return getType() + ": " + getValue();
        }
    }
}
