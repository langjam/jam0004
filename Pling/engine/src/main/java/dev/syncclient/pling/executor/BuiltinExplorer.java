package dev.syncclient.pling.executor;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

public abstract class BuiltinExplorer implements Builtin{
    @Override
    public void load(StateNode root) {
        // Get all the methods in the class that are annotated with @BuiltinExplorerInfo

        List<Method> methods = Arrays.stream(this.getClass().getDeclaredMethods())
                .filter(method -> method.isAnnotationPresent(BuiltinExplorerInfo.class))
                .toList();

        // Create a new state node for each method
        for (Method method : methods) {
            BuiltinExplorerInfo info = method.getAnnotation(BuiltinExplorerInfo.class);
            StateNode node = new FunctionStateNode(info.name(), info.description(), info.usage(), (args) -> {
                Object[] argsArray = new Object[args.size()];
                for (int i = 0; i < args.size(); i++) {
                    argsArray[i] = args.get(i);
                }

                Object result = null;
                try {
                    result = method.invoke(this, argsArray);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (result instanceof Boolean) {
                    return (Boolean) result ? 1.0 : 0.0;
                }

                return result;
            });
            root.children().add(node);
        }
    }

    @Retention(RetentionPolicy.RUNTIME)
    @Target({ElementType.METHOD})
    public @interface BuiltinExplorerInfo {
        String name();
        String description();
        String usage();
    }
}
