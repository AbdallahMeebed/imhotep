COMPILE_OPTS := --binary -j 0 -Wall -Wno-fatal -Wno-TIMESCALEMOD -Werror-WIDTHEXPAND
export ROOT_DIR := ../..

BLOCKS = alu

all: $(foreach block,${BLOCKS},${block}_sim)

# Testing Makefile variables
# %_echo:
# 	@echo "$*"
#
# %_test: %_echo
# 	@echo "Done"

%_compile:
	verilator ${COMPILE_OPTS} --Mdir $*_simdir -f $*_file.list --top $*_tb

%_sim: %_compile
	$*_simdir/V$*_tb

clean:
	rm -rf *_simdir
