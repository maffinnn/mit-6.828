// User-level page fault handler support.
// Rather than register the C page fault handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in pfentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>


// Assembly language pgfault entrypoint defined in lib/pfentry.S.
extern void _pgfault_upcall(void);

// Pointer to currently installed C-language pgfault handler.
void (*_pgfault_handler)(struct UTrapframe *utf);

//
// Set the page fault handler function.
// If there isn't one yet, _pgfault_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		// 当前env的envid是0
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
			panic("set_pgfault_handler: sys_page_alloc fail\n");
		}
		/*
		* 注意！！！
		* _pgfault_upcall 和 _pgfault_handler的入口地址是完全不同的
		* 这里set_pgfault_upcall set的是_pgfault_upcall的入口地址而非handler的地址
		* 否则会找不到handler的地址会page fault 然后recursive page fault直到overflow
		* (事实上要stack overflow 需要很久...) 
		*/
		cprintf("pgfault_upcall: %08x\n", _pgfault_upcall);
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;

}
