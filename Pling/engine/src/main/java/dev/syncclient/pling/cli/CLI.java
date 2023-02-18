package dev.syncclient.pling.cli;

import dev.syncclient.pling.Main;
import dev.syncclient.pling.audio.ALInfo;

import java.util.HashMap;

public class CLI {
    public static final HashMap<Flag, String> flags = new HashMap<>();

    public static void handle(final String[] args) {
        Flag currentFlag = null;

        for (final String arg : args) {
            if (arg.startsWith("--")) {
                currentFlag = Flag.getFlag(arg.substring(2));
                flags.put(currentFlag, null);
            } else if (currentFlag != null && !arg.startsWith("--")) {
                flags.put(currentFlag, arg);
                currentFlag = null;
            }
        }

        if (flags.containsKey(Flag.HELP)) {
            System.out.println("Usage: pling [file] [options]");
            System.out.println("Options:");
            System.out.println("  --help          Display this help message");
            System.out.println("  --version       Display the version of Pling");
            System.out.println("  --debug         Launch the debugger");
            System.out.println();
            System.out.println("~ Pling Lang by Team Sync");
            System.exit(0);
        }

        if (flags.containsKey(Flag.VERSION)) {
            System.out.println("Pling Lang v0.0.1, OpenAL: ");
            ALInfo.showAlInfo();
            System.exit(0);
        }

        if (flags.containsKey(Flag.DEBUG)) {
            Flag.debug = true;
            Main.debugger.start();
        }
    }
}
