COMPILE_OPTS := --binary -j 0 -Wall -Wno-fatal
export ROOT_DIR := ../..

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
