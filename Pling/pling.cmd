@echo off
echo Bootstrapping pling

echo Checking for java
WHERE java
IF %ERRORLEVEL% NEQ 0 GOTO nojava

echo Checking for built jar
IF EXIST engine\target\engine-1.0-SNAPSHOT.jar GOTO skipbuild

echo Checking for Maven
WHERE mvn
IF %ERRORLEVEL% NEQ 0 GOTO nomaven

echo Building pling
cd engine
mvn clean package
cd ..

:skipbuild

echo Adding Pling as alias
doskey pling=java -jar engine\target\engine-1.0-SNAPSHOT.jar $*

echo Done. You can now run pling from anywhere.

goto end

:nojava
echo Java not found. Please install java and try again.
GOTO end

:nomaven
echo Maven not found. Please install maven and try again.
GOTO end

:end