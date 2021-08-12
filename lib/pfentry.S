#include <inc/mmu.h>
#include <inc/memlayout.h>

// Page fault upcall entrypoint.

// This is where we ask the kernel to redirect us to whenever we cause
// a page fault in user space (see the call to sys_set_pgfault_handler
// in pgfault.c).
//
// When a page fault actually occurs, the kernel switches our ESP to
// point to the user exception stack if we're not already on the user
// exception stack, and then it pushes a UTrapframe onto our user
// exception stack:
//  (这里有4个bytes的空间用来存放返回地址的值)
//	trap-time esp     <-- 48(%esp)
//	trap-time eflags
//	trap-time eip     <-- 40(%esp)
//	utf_regs.reg_eax  -----+
//	...					   |
//  ...   			 general pupose registers 一共 32 bytes
//	utf_regs.reg_esi	   |
//	utf_regs.reg_edi  -----+
//	utf_err (error code) // 4 bytes
//	utf_fault_va  // 4 bytes       <-- %esp
//
// If this is a recursive fault, the kernel will reserve for us a
// blank word above the trap-time esp for scratch work when we unwind
// the recursive call.
//
// We then have call up to the appropriate page fault handler in C
// code, pointed to by the global variable '_pgfault_handler'.

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
	movl _pgfault_handler, %eax
	call *%eax  
	addl $4, %esp			// pop function argument
	
	// Now the C page fault handler has returned and you must return
	// to the trap time state.
	// Push trap-time %eip onto the trap-time stack.
	/*
	 * Explanation:
	 *   We must prepare the trap-time stack for our eventual return to
	 *   re-execute the instruction that faulted.
	 *   Unfortunately, we can't return directly from the exception stack:
	 *   We can't call 'jmp', since that requires that we load the address
	 *   into a register, and all registers must have their trap-time
	 *   values after the return.
	 *   We can't call 'ret' from the exception stack either, since if we
	 *   did, %esp would have the wrong value.--> 会跳到user normal stack上
	 *   So instead, we push the trap-time %eip onto the *trap-time* stack!
	 *   Below we'll switch to that stack and call 'ret', which will
	 *   restore %eip to its pre-fault value.
	 *
	 *   In the case of a recursive fault on the exception stack,
	 *   note that the word we're pushing now will fit in the
	 *   blank word that the kernel reserved for us.
	*/
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl %esp, %ebx; 	// 临时保存一下当前esp的值
	movl 40(%esp), %eax;	// 获取trap time eip的值并存在%eax中
	movl 48(%esp), %esp; // 将trap time esp的地址放入当前esp中
	pushl %eax; // 将trap time eip的值写入trap time esp所指向的位置的地址 
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	movl %ebx, %esp;	// 还原当前栈的esp值
	subl $4, 48(%esp);  // 手动remove掉4个bytes的scratch space
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp;  // remove掉utf_err和utf_fault_va
	popal;			// pop掉general registers

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp; // remove掉trap time eip 因为我们已经设置好了
	popfl;		 // restore eflags

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
		    // 1. pop off an address pointed by 当前esp
			// 2. jump to that address
