package dev.syncclient.pling.debugger;

import dev.syncclient.pling.executor.StateTree;
import dev.syncclient.pling.lexer.Token;
import dev.syncclient.pling.parser.AbstractSyntaxTree;
import dev.syncclient.pling.utils.StringUtils;

import java.io.*;
import java.net.BindException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.concurrent.Semaphore;

public class PlingDebugger extends Thread {
    public static class IPC {
        long threadID = -1;
        int port = -1;
        public Semaphore run = new Semaphore(0);

        public AbstractSyntaxTree ast = null;
        public List<Token.WithData> tokens = null;
        public Queue<String> messages = new PriorityQueue<>();
    }

    public PlingDebugger.IPC debuggerIPC = new PlingDebugger.IPC();
    int port = -1;

    public static PlingDebugger instance = null;

    public PlingDebugger() {
        super("Pling Debugger");
        instance = this;
    }

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

            System.out.println("Started debug socket, address: '127.0.0.1:" + port + "', transport: 'socket'");

            while (true) {
                Socket s = socket.accept();
                new Thread(() -> {
                    System.out.println("Debugger connected, address: '" + s.getInetAddress().getHostAddress() + ":" + s.getPort() + "'");

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
                                        s.close();
                                        return;
                                    }
                                    case "clear", "cls" -> shell.print("\033[H\033[2J");
                                    case "help", "h" -> {
                                        shell.println("Available commands:");
                                        shell.println("  run     Run the program");
                                        shell.println("  kill    Kill the program");
                                        shell.println("  exit    Exit the debugger");
                                        shell.println("  clear   Clear the screen");
                                        shell.println("  help    Display this help message");
                                        shell.println("  info    Display information about the interpreter");
                                        shell.println("  vars    Display all variables");
                                        shell.println("  tree    Display the state tree");
                                        shell.println("  tokens  Display the tokens");
                                        shell.println("  ast     Display the abstract syntax tree");
                                        shell.println("  msg     Display compiler messages");
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
                                        // Get all variables
                                        shell.println("Variables:");

                                        StateTree st = StateTree.getInstance();
                                        st.fetchAllVariables().forEach((variable) -> shell.println("  " + variable.name() + " = " + variable.getValue()));
                                    }
                                    case "run" -> debuggerIPC.run.release();
                                    case "kill" -> System.exit(255);
                                    case "tokens" -> {
                                        shell.println("Tokens:");

                                        for (Token.WithData token : debuggerIPC.tokens) {
                                            shell.println(StringUtils.ljust(token.getType().toString(), 10) + ": " + token.getValue());
                                        }
                                    }
                                    case "ast" -> {
                                        shell.println("Abstract Syntax Tree:");
                                        debuggerIPC.ast.getRoot().print(0, shell::print);
                                    }
                                    case "msg" -> {
                                        shell.println("Compiler messages:");

                                        for (String message : debuggerIPC.messages) {
                                            shell.println("  - " + message);
                                        }

                                        debuggerIPC.messages.clear();
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
