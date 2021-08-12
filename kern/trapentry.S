/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(int_divide, T_DIVIDE)
TRAPHANDLER_NOEC(int_debug, T_DEBUG)
TRAPHANDLER_NOEC(int_nmi, T_NMI)
TRAPHANDLER_NOEC(int_brkpt, T_BRKPT)
TRAPHANDLER_NOEC(int_oflow, T_OFLOW)
TRAPHANDLER_NOEC(int_bound, T_BOUND)
TRAPHANDLER_NOEC(int_illop, T_ILLOP)
TRAPHANDLER_NOEC(int_device, T_DEVICE)
TRAPHANDLER(int_dblflt, T_DBLFLT)
TRAPHANDLER(int_tss, T_TSS)
TRAPHANDLER(int_segnp, T_SEGNP)
TRAPHANDLER(int_stack, T_STACK)
TRAPHANDLER(int_gpflt, T_GPFLT)
TRAPHANDLER(int_pgflt, T_PGFLT)
TRAPHANDLER_NOEC(int_fperr, T_FPERR)

TRAPHANDLER_NOEC(int_syscall, T_SYSCALL)

TRAPHANDLER_NOEC(int_timer, IRQ_OFFSET+IRQ_TIMER)
TRAPHANDLER_NOEC(int_kbd, IRQ_OFFSET+IRQ_KBD)
TRAPHANDLER_NOEC(int_serial, IRQ_OFFSET+IRQ_SERIAL)
TRAPHANDLER_NOEC(int_spurious, IRQ_OFFSET+IRQ_SPURIOUS)
TRAPHANDLER_NOEC(int_ide, IRQ_OFFSET+IRQ_IDE)
TRAPHANDLER_NOEC(int_error, IRQ_OFFSET+IRQ_ERROR)





/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	// push values to make the stack look like a struct TrapFrame
	pushl	%ds;
	pushl	%es;
	pushal;
	// load GD_KD into %ds and %es
	movl	$GD_KD, %eax;
	movw	%ax, %ds;
	movw	%ax, %es;
	// pass a pointer to the Trapframe as an argument to trap
	pushl 	%esp;
	call	trap; 



	