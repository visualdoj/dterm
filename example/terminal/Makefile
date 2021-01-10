default : build run;
help :
	@echo Usage:
	@echo make build: builds the program
	@echo make run: run program
	@echo make clean: delete all generated files

ifeq (,$(wildcard ../../Makefile.node))
  UNITS_DIR:=../..
else
  UNITS_DIR:=../../..
endif

PROGNAME := terminal
FPC := fpc
FPC_OPTIONS := -O3 -Oodfa -Sew -g -gl -al -an -ar -at -vq -Xm -CX -XX -Xs

ifeq ($(OS),Windows_NT)
EXE_NAME := $(PROGNAME).exe
RUN_CMD := $(EXE_NAME)
clean :
	del *.map *.ppu *.o *.s *.out $(EXE_NAME)
else
EXE_NAME := $(PROGNAME)
RUN_CMD := ./$(EXE_NAME)
clean :
	rm *.map *.ppu *.o *.s *.out $(EXE_NAME)
endif

$(EXE_NAME) : $(PROGNAME).pas $(UNITS_DIR)/dterm.pas  $(UNITS_DIR)/dterminal.pas
	$(FPC) $(FPC_OPTIONS) -FU. -Fu$(UNITS_DIR) $(PROGNAME).pas
build : $(EXE_NAME);

run : build
	@$(RUN_CMD)
