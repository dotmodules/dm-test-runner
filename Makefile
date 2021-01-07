#=======================================================================================
# MAKE SETTINGS

.DEFAULT_GOAL := help
NAME := dm.test


#=======================================================================================
# HELP TARGET

.PHONY: help
help:
	@echo ""
	@echo "-------------------------------------------------------------------"
	@echo "  $(NAME) make interface "
	@echo "-------------------------------------------------------------------"
	@echo ""
	@echo "   help              Prints out this help message."
	@echo "   test              Runs the included example test suite."
	@echo "   tools             Collects all used command line tools."
	@echo ""


#=======================================================================================
# EXAMPLE TEST SUITES TARGET
#
.PHONY: test
test:
	@./example/run.sh

#=======================================================================================
# TOOLS COLLECTION TARGET
#
.PHONY: tools
tools:
	@./utils/collect_tools.sh > requirements.txt
	@ cat requirements.txt
