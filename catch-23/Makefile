CXX := g++
CC := gcc

SRC_DIRECTORY = src
OBJ_DIRECTORY = obj
BIN_DIRECTORY = bin

CREATE_DIRS = mkdir -p $(@D)

CXXFLAGS := \
		-I $(SRC_DIRECTORY) \
		-std=c++17

CFLAGS := \
		-I $(SRC_DIRECTORY) \
		-std=c11

LFLAGS :=

SOURCES := \
		$(wildcard $(SRC_DIRECTORY)/*.c) \
		$(wildcard $(SRC_DIRECTORY)/*/*.c)
HEADERS := \
		$(wildcard $(SRC_DIRECTORY)/*.h) \
		$(wildcard $(SRC_DIRECTORY)/*/*.h)

OBJECTS := $(SOURCES:$(SRC_DIRECTORY)/%.c=$(OBJ_DIRECTORY)/%.o)

EXECUTABLE := $(BIN_DIRECTORY)/catch23.out

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	@$(CREATE_DIRS)
	@echo "linking"
	@$(CC) $(OBJECTS) -o $@ $(LFLAGS)

$(OBJ_DIRECTORY)/%.o: $(SRC_DIRECTORY)/%.c $(HEADERS)
	@$(CREATE_DIRS)
	@echo "$@"
	@$(CC) -c $< -o $@ $(CFLAGS)

clean:
	@rm -rf $(OBJ_DIRECTORY)
	@rm -rf $(BIN_DIRECTORY)
