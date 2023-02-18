CC := gcc

SRC_DIRECTORY = src
OBJ_DIRECTORY = obj
BIN_DIRECTORY = bin

CREATE_DIRS = mkdir -p $(@D)

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

EXECUTABLE := $(BIN_DIRECTORY)/catch23

all: $(EXECUTABLE)

run: all
	$(BIN_DIRECTORY)/catch23

$(EXECUTABLE): $(OBJECTS)
	@$(CREATE_DIRS)
	@echo "LD $@"
	@$(CC) $(OBJECTS) -o $@ $(LFLAGS)

$(OBJ_DIRECTORY)/%.o: $(SRC_DIRECTORY)/%.c $(HEADERS)
	@$(CREATE_DIRS)
	@echo "CC $@"
	@$(CC) -c $< -o $@ $(CFLAGS)

clean:
	@rm -rf $(OBJ_DIRECTORY)
	@rm -rf $(BIN_DIRECTORY)
