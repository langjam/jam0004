package dev.syncclient.pling.executor;

import dev.syncclient.pling.parser.AbstractSyntaxTree;

import java.util.ArrayList;

public class Interpreter {
    private final AbstractSyntaxTree ast;
    private final StateTree stateTree;

    public Interpreter(AbstractSyntaxTree ast, StateTree stateTree) {
        this.ast = ast;
        this.stateTree = stateTree;
    }

    public void start() {
        exec(ast.getRoot());
    }

    public Object exec(AbstractSyntaxTree.Node node) {
        if (node instanceof AbstractSyntaxTree.StatementsNode) {
            for (AbstractSyntaxTree.Node child : node.getChildren()) {
                exec(child);
            }
        } else if (node instanceof AbstractSyntaxTree.Statement.CallNode callNode) {
            return call(callNode);
        } else if (node instanceof AbstractSyntaxTree.Literal.NumberNode) {
            return ((AbstractSyntaxTree.Literal.NumberNode) node).getValue();
        } else if (node instanceof AbstractSyntaxTree.Literal.StringNode) {
            return ((AbstractSyntaxTree.Literal.StringNode) node).getValue();
        } else if (node instanceof AbstractSyntaxTree.Statement.VarDefNode varDefNode) {
            return varDef(varDefNode);
        } else if (node instanceof AbstractSyntaxTree.Statement.VarSetNode varSetNode) {
            return varSet(varSetNode);
        } else if (node instanceof AbstractSyntaxTree.Literal.VariableNode varNode) {
            return stateTree.findVar(varNode.getName()).getValue();
        } else if (node instanceof AbstractSyntaxTree.FuncDefNode funcDefNode) {
            return funcDef(funcDefNode);
        } else if (node instanceof AbstractSyntaxTree.BranchNode branch) {
            return execBranch(branch);
        } else if (node instanceof AbstractSyntaxTree.LoopNode loop) {
            return execLoop(loop);
        } else if (node instanceof AbstractSyntaxTree.ReturnNode returnNode) {
            return execReturn(returnNode);
            
        } else {
            throw new RuntimeException("Unknown node: " + node);
        }

        return null;
    }

    private Object execReturn(AbstractSyntaxTree.ReturnNode returnNode) {
        if (returnNode.getValue() == null) {
            return null;
        }

        Object val =  exec(returnNode.getValue());
        stateTree.pushReturn(val);

        return val;
    }

    private boolean evalCondition(Object conditionResult) {
        if (conditionResult == null) {
            return true;
        } else if (conditionResult instanceof Boolean) {
            return (Boolean) conditionResult;
        } else if (conditionResult instanceof Double) {
            return (Double) conditionResult != 0;
        } else if (conditionResult instanceof String) {
            return  !((String) conditionResult).isEmpty();
        } else {
            throw new InterpreterException("Unknown condition type: " + conditionResult.getClass());
        }
    }

    private Object execBranch(AbstractSyntaxTree.BranchNode branch) {
        Object conditionResult = null;

        if (branch.getCondition() != null)
            conditionResult = exec(branch.getCondition());

        boolean condition = evalCondition(conditionResult);

        if (condition) {
            return exec(branch.getBody());
        } else {
            if (branch.getSubordiante() != null) {
                return exec(branch.getSubordiante());
            }
        }

        return null;
    }

    private Object execLoop(AbstractSyntaxTree.LoopNode loop) {
        Object conditionResult = null;

        if (loop.getCondition() != null)
            conditionResult = exec(loop.getCondition());

        boolean condition = evalCondition(conditionResult);

        while (condition) {
            exec(loop.getBody());

            if (loop.getCondition() != null)
                conditionResult = exec(loop.getCondition());
            condition = evalCondition(conditionResult);
        }

        return null;
    }

    private Object funcDef(AbstractSyntaxTree.FuncDefNode funcDefNode) {
        stateTree.pushFunc(funcDefNode.getName(), funcDefNode);
        return null;
    }

    private Object call(AbstractSyntaxTree.Statement.CallNode callNode) {
        ArrayList<Object> args = new ArrayList<>();

        for (AbstractSyntaxTree.Node arg : callNode.getArgs()) {
            args.add(exec(arg));
        }

        try {
            return stateTree.findFunc(callNode.getName()).getFunction().apply(args);
        } catch (NullPointerException e) {
            throw new RuntimeException("Function " + callNode.getName() + " not found in current scope");
        }
    }


    private Object varDef(AbstractSyntaxTree.Statement.VarDefNode node) {
        stateTree.pushVar(node.getName(), exec(node.getValue()));
        return null;
    }

    private Object varSet(AbstractSyntaxTree.Statement.VarSetNode node) {
        stateTree.findVar(node.getName()).setValue(exec(node.getValue()));
        return null;
    }
}
