// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Backtrace the kernel stack", mon_backtrace },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	/*            
				STACK
	  +--   +~~~~~~~~~~~~~~~+
	  |	    |          		|
	  |		|           	|
	Caller	+---------------+		
	Frame	|  Arguments	|
	  |		+---------------+		
	  |		|Return Address | <-- saved %eip value (the instruction right after call instruction in the caller)
	  +--   +---------------+
			|	Old %ebp	| <-- %ebp
			+---------------+
			|				|
			|Saved Registers|
			|		+		|   
			|Local Variables|
			|				| 
			+---------------+		
			|Argument Build	|
			+~~~~~~~~~~~~~~~+ <-- %esp
	*/
	uint32_t* ebp = (uint32_t*) read_ebp();

	cprintf("Stack backtrace:\n");
	// while loop的返回条件：
	// 		在entry.S中， 
	//				movl  $0x0,%ebp  # nuke frame pointer
	while(ebp)
	{	
		uint32_t eip = *(ebp+1);
		struct Eipdebuginfo info; 
		debuginfo_eip(eip, &info);
		
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",ebp, eip,
			*(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6));
		
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip-info.eip_fn_addr);
		
		// *ebp 取%ebp指向的old ebp值是一个地址 再强转成指针而类型
		ebp = (uint32_t*)*ebp; 
	}
	
	return 0;
}

// Test the stack backtrace function (lab 1 only)
void 
test_backtrace(int x)
{
	cprintf("entering test_backtrace %d\n", x);

	if (x>0)
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);

	cprintf("leaving test_backtrace %d\n", x);

}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");
	// 一开始不清楚要怎样测试required的代码 还在printf.c里写了main函数但是编译器报错找不到头文件
	// 参考了clann24/jos/lab1的implementation
	// 可以将要测试的cprintf的代码放在这里运行(GREAT IDEA!!学习了!!)
	// int x =1, y =3, z = 4; // inserted
	// cprintf("x %d, y %x, z %d\n", x, y, z); // inserted
	// unsigned int i = 0x00646c72; // inserted
	// cprintf("H%x Wo%s\n", 57616, &i); // inserted
	// cprintf("x=%d y=%d\n", 3); // inserted

	// 测试
	// mon_backtrace(0, 0, 0);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
