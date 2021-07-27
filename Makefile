.PHONY: all mods help log

CC = gcc
SHELL = /bin/bash
SUBDIRS =  misc-modules
MODULES = misc-modules
STATICS = main
MODULES = vb
URL_KERNEL_GIT=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
URL_KERNEL_HTTPS=https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
URL_KERNEL_GSOURCE=https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git

help: 
		cat Makefile

static-lib:
		$(CC) -Wall main.c -o main 
		objdump -d main > main.elf

subdirs:
		for n in $(SUBDIRS); do $(MAKE) -C $$n || exit 1; done

clean:
		for n in $(SUBDIRS); do $(MAKE) -C $$n clean; done
		$(MAKE) syslog-empty
		rm -rf *.elf main *.trace

del-ca:
		./CA/clean.sh &>/dev/null

new-ca:
		./CA/init.sh  &>/dev/null

deps:
		./auto.sh

remove:
		rmmod misc-modules/*.ko

insert:
		for kmod in $(MODULES); do \
			./misc-modules/insert $$kmod; \
		done;

kernel-latest:
	mkdir -p linux && cd linux
	if ! [ -d ".git" ]; then git init; fi
	git remote add --mirror=fetch upstream $(URL_KERNEL_GSOURCE)
	git fetch upstream master
	

syslog:
		tail /var/log/syslog

syslog-empty:
		truncate -s 0 /var/log/syslog &> /dev/null

ring-keys:
		cat /proc/keys > .info.ring

sign-link: 
		rm -rf /bin/sign-file && ln -s "/lib/modules/$(shell uname -r)/build/scripts/sign-file" /bin/sign-file

sign: sign-link
		sign-file sha512 CA/certs/signing_key.priv CA/certs/signing_key.pem misc-modules/*.ko 

kdir:
		echo /lib/modules/$(shell uname -r)

# -g to trace single functions
# -F will _follow_ all but filter output on only one x | ie; -F ./main
trace-mount:
		mount -t tracefs nodev /sys/kernel/tracing
		echo 1 > /sys/kernel/tracing/tracing_on
		echo 1 > /proc/sys/kernel/stack_tracer_enabled
		echo function > /sys/kernel/tracing/current_tracer
		cat /sys/kernel/tracing/enabled_functions

trace-total:
		cat /sys/kernel/debug/tracing/available_filter_functions | wc -l

trace-endless:
		cat /sys/kernel/tracing/trace

trace-sys:
		trace-cmd record -p function_graph -g __x64_sys_read ./main
		trace-cmd report

trace-all:
		trace-cmd record -e all ./main
		trace-cmd report

trace-formats:
		cat /sys/kernel/tracing/printk_formats > formats.trace
		cat formats.trace

trace-event:
		trace-cmd record -e sched_wakeup -e sched_switch -e sys_enter_write ./main
		trace-cmd report

trace-prctl:
		trace-cmd record -p function_graph -g __x64_sys_arch_prctl --max-graph-depth 2 -e syscalls -F ./main
		trace-cmd report

trace-report:
		trace-cmd record -p function_graph --max-graph-depth 2 -e syscalls -F ./main
		trace-cmd report

# ------- USAGE ----------

# Run on your first install
install: deps new-ca build sign

# Build everything
build: subdirs

# Build & insert all modules
all: build insert

# Mounts the tracer; see other targets with format trace-*
trace: trace-mount

# Grabs syslog, (see syslog-empty)
log: syslog
