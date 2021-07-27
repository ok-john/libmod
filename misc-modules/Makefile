# To build modules outside of the kernel tree, we run "make"
# in the kernel source tree; the Makefile these then includes this
# Makefile once again.
# This conditional selects whether we are being included from the
# kernel Makefile or not.

LDDINC=$(PWD)/../include
EXTRA_CFLAGS += -I$(LDDINC)

ifeq ($(KERNELRELEASE),)
    # Assume the source tree is where the running kernel was built
    # You should set KERNELDIR in the environment if it's elsewhere
    KERNELDIR ?= /lib/modules/$(shell uname -r)/build
    # The current directory is passed to sub-makes as argument
    PWD := $(shell pwd)

module:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

module_load:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) module_load

module_unload:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules_unload

modules_install:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules_install

module_sign:
	sign-file sha512 CA/certs/signing_key.priv CA/certs/signing_key.pem vb.ko


clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions *.mod modules.order *.symvers *.d .*.*.d

.PHONY: modules modules_install clean

else
    # called from kernel build system 
	# declare the modules you want installed here
	obj-m := vb.o
endif

