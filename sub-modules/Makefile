CC = gcc
SHELL = /bin/bash
MODULES = utils
COMMANDS = clean modules modules_install
ifeq ($(KERNELRELEASE),)
	KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD=$(shell pwd)
PATHS=$(addprefix $(PWD)/, $(MODULES))
KOBJS=$(join $(addsuffix /, $(PATHS)), $(addsuffix .ko, $(MODULES)))


default:
		for p in $(PATHS); do $(MAKE) -C $(KERNELDIR) M=$$p || exit 1; done

clean:
		for p in $(PATHS); do $(MAKE) -C $(KERNELDIR) M=$$p clean || exit 1; done

insert:
		for m in $(MODULES); do echo $(join $$PWD/$$m/, $$m.ko); done


endif
