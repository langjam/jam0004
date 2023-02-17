package dev.syncclient.pling;

public enum Flag {
    DEBUG("debug"),
    HELP("help"),
    VERSION("version");

    private final String flag;

    Flag(final String flag) {
        this.flag = flag;
    }

    public String getFlag() {
        return flag;
    }

    public static Flag getFlag(final String flag) {
        for (final Flag f : Flag.values()) {
            if (f.getFlag().equals(flag)) {
                return f;
            }
        }

        return null;
    }
}