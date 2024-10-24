# Copyright (C) 2023 Grinn sp. z o.o.
#
# These computer program listings and specifications, are the property of
# Grinn sp. z o.o. and shall not be reproduced or copied or used in
# whole or in part without written permission from Grinn sp. z o.o.


PWD ?= $(shell pwd)

ifeq ($(V),1)
Q :=
else
Q ?= @
endif

GCC = clang++-18
FORMATTER = clang-format

PROJECT_DIR := ${PWD}
SOURCES_DIR := ${PROJECT_DIR}
TEST_DIR=./test_src

FIND_CMD = find ${SOURCES_DIR} \( -iname *.h -o -iname *.cpp -o -iname *.cppm \) -and ! -path "*/libs/*"

TARGET_NAME := app
prof: TARGET_NAME := prof_app

GTEST_DIR=./libs/googletest/googletest
CPPFLAGS_PROD := 
prof: CPPFLAGS_PROD += -pg
CPPFLAGS_PROD += -g 
# CPPFLAGS_PROD += -isystem 
CPPFLAGS_PROD += -Wall 
CPPFLAGS_PROD += -pedantic
# CPPFLAGS_PROD += -pthread 
# CPPFLAGS_PROD += -lpthread 
CPPFLAGS_PROD += -std=c++20
CPPFLAGS_PROD += -fpermissive
CPPFLAGS_PROD += -ferror-limit=1
CPPFLAGS_PROD += -fmodules
CPPFLAGS_PROD += -fprebuilt-module-path=.
# CPPFLAGS_PROD += -v
# CPPFLAGS_PROD += -E

CXXFLAGS := -g -Wall -Wextra -pthread
CPPFLAGS_TEST := -g -Wall -Wextra -pthread -isystem $(GTEST_DIR)/include

SOURCES_C := 

SOURCES_CPP := 
SOURCES_CPP += libs/logger/logger.cpp
# SOURCES_CPP += scheduler.cppm
SOURCES_CPP += main.cpp

OBJS := 
OBJS += $(SOURCES_C:%.c=%.o)
OBJS += $(SOURCES_CPP:%.cpp=%.o)

SOURCES_CPPM += scheduler.cppm

PCM_CPPM += $(SOURCES_CPPM:%.cppm=%.pcm)

OBJS_CPPM += $(PCM_CPPM:%.pcm=%.o)

TEST_SOURCES_C :=
TEST_SOURCES_CPP := test_logger.cpp
TEST_SOURCES_CPP +=logger.cpp

TEST_OBJS :=
TEST_OBJS += $(TEST_SOURCES_CPP:%.cpp=%.o)
TEST_OBJS += $(TEST_SOURCES_C:%.c=%.o)

GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)

INCLUDES :=
INCLUDES += libs/logger/.

test: INCLUDES += libs/googletest/googletest/include/gtest/internal/
test: INCLUDES += libs/googletest/googletest/include/

INCLUDES += .
INCLUDES_PARAMS=$(foreach d, $(INCLUDES), -I"${PWD}/$d")

INCLUDES_PARAMS += -I"/usr/include/clang/18/"
INCLUDES_PARAMS += -I"/usr/include/x86_64-linux-gnu/c++/11/"
INCLUDES_PARAMS += -I"/usr/include/c++/11/"


GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h

.setup:
	$(Q) wget https://apt.llvm.org/llvm.sh
	$(Q) chmod 777 llvm.sh
	$(Q) ./llvm.sh
	$(Q) rm llvm.sh*

gtest-all.o : $(GTEST_SRCS_)
	@echo 'Build file: $< -> $@'
	$(Q)$(GCC) $(CPPFLAGS_TEST) -I$(GTEST_DIR) $(CXXFLAGS) -c $(GTEST_DIR)/src/gtest-all.cc

gtest_main.o : $(GTEST_SRCS_)
	@echo 'Build file: $< -> $@'
	$(Q)$(GCC) $(CPPFLAGS_TEST) -I$(GTEST_DIR) $(CXXFLAGS) -c $(GTEST_DIR)/src/gtest_main.cc

clean:
	@echo 'Clean'
	${Q}rm -rf test_exe
	${Q}rm -rf prof_app
	${Q}rm -rf *.txt
	${Q}rm -rf $(TARGET_NAME)
	${Q}rm -rf gmon.out
	${Q}find . -name "*.o" | xargs -r rm 
	${Q}find . -name "*.pcm" | xargs -r rm 

%.pcm : %.cppm
	@echo 'Build object file: $< -> $@'
	$(Q)$(GCC) $(CPPFLAGS_PROD) $(INCLUDES_PARAMS) --precompile -o "$@" "$<"

%.o : %.pcm
	@echo 'Build object file: $< -> $@'
	$(Q)$(GCC) $(CPPFLAGS_PROD) -c "$<" -o "$@" 

%.o : %.cpp
	@echo 'Build object file: $< -> $@'
	$(Q)$(GCC) $(CPPFLAGS_PROD) $(INCLUDES_PARAMS) -c -o "$@" "$<"

%.o: %.c
	@echo 'Build file: $< -> $@'
	$(Q)$(GCC) $(CPPFLAGS_PROD) $(INCLUDES_PARAMS) -c "$<" -o "$@" 
	
test_filter: $(TEST_OBJS) gtest-all.o gtest_main.o 
	@echo 'Build file: test_main'
	$(Q)$(GCC) $(CPPFLAGS_PROD) $(INCLUDES_PARAMS) $^ -o test_exe
	./test_exe --gtest_filter=$(FILTER)void
	$(Q)$(GCC) $(CPPFLAGS_PROD) $(INCLUDES_PARAMS) $^ -o test_exe 
	./test_exe --gtest_catch_exceptions=0

build: clean $(PCM_CPPM) $(OBJS_CPPM) $(OBJS) 
	@echo 'Build executable file: $(TARGET_NAME)'
	$(Q)$(GCC) $(CPPFLAGS_PROD) $(OBJS) $(OBJS_CPPM) -o $(TARGET_NAME) 

run: build
	@echo 'Exe file: $(TARGET_NAME)'
	$(Q)./$(TARGET_NAME)

prof: build
	@echo "Prof: $(TARGET_NAME)"
	$(Q)./$(TARGET_NAME) 
	$(Q)gprof ./$(TARGET_NAME) gmon.out > analysis.txt

format-check:
	${Q}$(FIND_CMD) | xargs $(FORMATTER) --Werror --dry-run --verbose

format:
	${Q}$(FIND_CMD) | xargs $(FORMATTER) --Werror -i --verbose

valgrind: build
	@echo "Valgrind: $(TARGET_NAME)"
	$(Q) valgrind --tool=massif ./$(TARGET_NAME)

all: test_exe app
	$(Q)./test_exe --gtest_output=xml
