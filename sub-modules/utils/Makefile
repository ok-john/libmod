LDDINC=$(PWD)/../include
EXTRA_CFLAGS += -I$(LDDINC)
MODULE := utils
MODULE_SOURCES := 
SHELL=/bin/bash

.PHONY: default clean install

ifneq ($(KERNELRELEASE),)
obj-m := $(MODULE).o
$(MODULE)-y := $(addsuffix .o, $(MODULE_SOURCES))
else
KERNELDIR ?= /lib/modules/$(shell uname -r)/build

default:  
		$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
clean:
		$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
install:
		$(MAKE) -C $(KERNELDIR) M=$(PWD) modules_install

endif

