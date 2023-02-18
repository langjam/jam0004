package dev.syncclient.pling.debugger;

import dev.syncclient.pling.executor.StateTree;
import dev.syncclient.pling.parser.AbstractSyntaxTree;

import java.io.*;
import java.net.BindException;
import java.net.ServerSocket;
import java.net.Socket;

public class PlingDebugger extends Thread {
    public static class IPC {
        long threadID = -1;
        int port = -1;

        public AbstractSyntaxTree ast = null;
    }

    public PlingDebugger.IPC debuggerIPC = new PlingDebugger.IPC();
    int port = -1;

    @Override
    public void run() {
        try {
            ServerSocket socket = null;
            try {
                socket = new ServerSocket(Integer.parseInt(System.getenv().getOrDefault("DEBUG", "9876")));
                port = socket.getLocalPort();
            } catch (BindException e) {
                while (socket == null) {
                    try {
                        socket = new ServerSocket((int) (Math.random() * 5000 + 5000));
                        port = socket.getLocalPort();
                    } catch (BindException ignored) {
                        throw new DebuggerExeption("FATAL ERROR: address: '127.0.0.1:" + port + "' is unbindable", e);
                    }
                }
            }

            debuggerIPC.port = port;
            debuggerIPC.threadID = Thread.currentThread().getId();

            System.out.println("Connected to interpreter, address: '127.0.0.1:" + port + "', transport: 'socket'");

            while (true) {
                Socket s = socket.accept();
                new Thread(() -> {
                    try {
                        OutputStream output = s.getOutputStream();
                        PrintStream shell = new PrintStream(output);

                        shell.print("pling@localhost~$ ");

                        BufferedReader reader = new BufferedReader(new InputStreamReader(s.getInputStream()));
                        String line;
                        while ((line = reader.readLine()) != null) {
                            try {
                                switch (line.split(" ")[0]) {
                                    case "exit" -> {
                                        shell.println("Exiting debugger...");
                                        System.exit(255);
                                    }
                                    case "clear", "cls" -> {
                                        shell.print("\033[H\033[2J");
                                    }
                                    case "help", "h" -> {
                                        shell.println("Available commands:");
                                        shell.println("  run     Run the program");
                                        shell.println("  stop    Stop the program");
                                        shell.println("  pause   Pause the program");
                                        shell.println("  resume  Resume the program");
                                        shell.println("  kill    Kill the program");
                                        shell.println("  restart Restart the program");
                                        shell.println("  reload  Reload the program");
                                        shell.println("  reset   Reset the program");
                                        shell.println("  quit    Quit the program");
                                        shell.println("  exit    Exit the debugger");
                                        shell.println("  clear   Clear the screen");
                                        shell.println("  help    Display this help message");
                                        shell.println("  info    Display information about the interpreter");
                                        shell.println("  vars    Display all variables");
                                        shell.println("  stack   Display the stack");
                                        shell.println("  tree    Display the state tree");
                                        shell.println("  tokens  Display the tokens");
                                        shell.println("  ast     Display the abstract syntax tree");
                                    }
                                    case "info" -> {
                                        shell.println("Interpreter information:");
                                        shell.println("  Version: 0.0.1");
                                        shell.println("  Author: Team Sync");
                                        shell.println("  License: MIT");
                                        shell.println("  GitHub: https://github.com/Sync-Private/jam0004/tree/main/Pling");
                                    }
                                    case "tree" -> shell.println(StateTree.getInstance().toString().replace("\n", "\r\n"));
                                    case "vars" -> {
                                        shell.println("Variables{\r\n" +
                                                "    root=\r\n" + StateTree.indent(2, debuggerIPC.ast.getRoot().getChildren().toString()) +
                                                '}');
                                    }
                                }

                                shell.print("pling@localhost~$ ");
                            } catch (Exception e) {
                                e.printStackTrace(new PrintStream(s.getOutputStream()));
                            }
                        }
                    } catch (IOException e) {
                        try {
                            s.close();
                        } catch (IOException ex) {
                            ex.printStackTrace();
                        }
                    }
                }).start();
            }
        } catch (IOException e) {
            throw new DebuggerExeption("Failed to start debugger", e);
        }
    }
}
