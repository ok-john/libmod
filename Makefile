.PHONY: all mods help log


FETCH_KERNEL_TO    := linux
CC 				   := gcc
SHELL 			   := /bin/bash
SUBDIRS 		   := misc-modules
MODULES 		   := vb
URL_KERNEL_GIT	   := git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
URL_KERNEL_HTTPS   := https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
URL_KERNEL_GSOURCE := https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git

help: 
		cat Makefile

static-lib:
		$(CC) -Wall main.c -o main 
		objdump -d main > main.elf

del-ca:
		misc-modules/CA/clean.sh &>/dev/null

new-ca:
		misc-modules/CA/init.sh  &>/dev/null

deps:
		./auto.sh

subdirs:
		for n in $(SUBDIRS); do $(MAKE) -C $$n || exit 1; done

modules:
		for n in $(SUBDIRS); do $(MAKE) -C $$n module; done

insert:
		for n in $(SUBDIRS); do $(MAKE) -C $$n module_load; done

sign:
		for n in $(SUBDIRS); do $(MAKE) -C $$n module_sign; done

clean:
		for n in $(SUBDIRS); do $(MAKE) -C $$n clean; done
		rm -rf *.elf main *.trace

remove:
		for n in $(SUBDIRS); do $(MAKE) -C $$n module_unload; done


fetch-latest:
		mkdir -p $(FETCH_KERNEL_TO) && cd $(FETCH_KERNEL_TO)
		if ! [ -d ".git" ]; then git init; fi
		git remote add --mirror=fetch upstream master $(URL_KERNEL_GSOURCE)
		git fetch upstream master
		
tiny-kernel:
	 	cd $(FETCH_KERNEL_TO) && $(MAKE) tinyconfig

syslog:
		tail /var/log/syslog

syslog-empty:
		truncate -s 0 /var/log/syslog &> /dev/null

ring-keys:
		cat /proc/keys > .info.ring

sign-link: 
		rm -rf /bin/sign-file && ln -s "/lib/modules/$(shell uname -r)/build/scripts/sign-file" /bin/sign-file

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
install: deps build ins

# Build everything
build: modules new-ca sign

# Build & insert all modules
ins: build insert

# Build & insert all modules
refresh: build remove insert

# Mounts the tracer; see other targets with format trace-*
trace: trace-mount

# Grabs syslog, (see syslog-empty)
log: syslog
