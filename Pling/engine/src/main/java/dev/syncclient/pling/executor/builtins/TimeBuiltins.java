package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.BuiltinExplorer;

import java.util.Date;
import java.util.TimeZone;

public class TimeBuiltins extends BuiltinExplorer {

    @Override
    public String description() {
        return "Time builtins";
    }

    @BuiltinExplorerInfo(name = "time.date", description = "Returns the current date", usage = "#time.date -> [result]")
    public String currentDate() {
        return new Date().toString();
    }

    @BuiltinExplorerInfo(name = "time.current", description = "Returns the current time in milliseconds", usage = "#time.current -> [result]")
    public long currentTime() {
        return System.currentTimeMillis();
    }

    @BuiltinExplorerInfo(name = "time.timezone", description = "Returns the current timezone", usage = "#time.timezone -> [result]")
    public String currentTimeZone() {
        return TimeZone.getDefault().getDisplayName();
    }

    @BuiltinExplorerInfo(name = "time.timezone.id", description = "Returns the current timezone id", usage = "#time.timezone.id -> [result]")
    public String currentTimeZoneId() {
        return TimeZone.getDefault().getID();
    }

    @BuiltinExplorerInfo(name = "time.format", description = "Formats the time to days hours minutes seconds", usage = "#time.format [time] -> [result]")
    public String formatTime(long time) {
        long days = time / 86400000;
        long hours = (time % 86400000) / 3600000;
        long minutes = ((time % 86400000) % 3600000) / 60000;
        long seconds = (((time % 86400000) % 3600000) % 60000) / 1000;
        return days + " days " + hours + " hours " + minutes + " minutes " + seconds + " seconds";
    }

    @BuiltinExplorerInfo(name = "time.format.short", description = "Formats the time to days hours minutes seconds", usage = "#time.format.short [time] -> [result]")
    public String formatTimeShort(long time) {
        long days = time / 86400000;
        long hours = (time % 86400000) / 3600000;
        long minutes = ((time % 86400000) % 3600000) / 60000;
        long seconds = (((time % 86400000) % 3600000) % 60000) / 1000;
        return days + "d " + hours + "h " + minutes + "m " + seconds + "s";
    }
}
