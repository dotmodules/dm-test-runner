#=======================================================================================
# MAKE SETTINGS

.DEFAULT_GOAL := help
NAME := dm.test


#=======================================================================================
# HELP COMMAND

.PHONY: help
help:
	@echo ""
	@echo "-------------------------------------------------------------------"
	@echo "  $(NAME) make interface "
	@echo "-------------------------------------------------------------------"
	@echo ""
	@echo "   help              Prints out this help message."
	@echo "   test              Runs the included example test suite."
	@echo ""


#=======================================================================================
# EXAMPLE COMMAND
#
.PHONY: test
test:
	@./example/run.sh
