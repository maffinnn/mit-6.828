// test user-level fault handler -- alloc pages to fix faults

#include <inc/lib.h>
#include <inc/x86.h>
void
handler(struct UTrapframe *utf)
{
	int r;
	void *addr = (void*)utf->utf_fault_va;

	cprintf("fault %x\n", addr);
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e\n", addr, r);
	char* ptr = addr;
	*ptr = 'H';
	cprintf("ptr = %c \n", *ptr);
	snprintf((char*) addr, 100, "this string was faulted in at %x\n", addr);
}


void
umain(int argc, char **argv)
{
	set_pgfault_handler(handler);
	cprintf("%s\n", (char*)0xDeadBeef);
	cprintf("%s\n", (char*)0xCafeBffe);
}
