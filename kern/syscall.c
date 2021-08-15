/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
	return;
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env* childenv; int ret;
	if ((ret = env_alloc(&childenv, curenv->env_id))<0){
		panic("sys_exofork: env_alloc failed due to %e\n", ret);
		return ret;
	}

	childenv->env_status = ENV_NOT_RUNNABLE;
	/*
	 *	childenv->env_tf.tf_eip会在load_icode的时候设置成了当前childenv的entry point
	 *  childenv需要复制parent env的所有状态(saved registers, 即trapframe)
	 * 	因为在childenv中sys_exofork()函数拿到的是当前environment id, 所以=0
	 *  而reg_eax就是pass return value的register(定义在lib/syscall.从中) 因此需要将它置为0
	*/
	childenv->env_tf = curenv->env_tf;
	childenv->env_tf.tf_regs.reg_eax = 0; // childenv的返回值
	return childenv->env_id;

}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env* e; int ret;
	if ((ret = envid2env(envid, &e, 1))<0){
		return ret;
	}

	if (status != ENV_RUNNABLE&&status!=ENV_NOT_RUNNABLE)
		return -E_INVAL;

	e->env_status = status;
	return 0;

}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env* e; 
	if (envid2env(envid, &e, 1)<0)
		return -E_BAD_ENV;
	
	e->env_pgfault_upcall = func;

	return 0;
	
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect. --> this is doen in page_insert()
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.

static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env* e; int ret;
	if ((ret = envid2env(envid, &e, 1))<0){
		return ret;
	}

	if ((uintptr_t)va>=UTOP||(uintptr_t)va%PGSIZE) 
		return -E_INVAL;
	
	if (perm&~(PTE_P|PTE_U|PTE_W|PTE_AVAIL)) return -E_INVAL;
	if ((perm&(PTE_U|PTE_P))!=(PTE_U|PTE_P)){
		 return -E_INVAL;
	}

	struct PageInfo* pp = page_alloc(ALLOC_ZERO);
	if (!pp) return -E_NO_MEM;

	if ((ret = page_insert(e->env_pgdir, pp, va, perm))<0){
		page_free(pp);
		return ret;
	}
	// cprintf("sys_page_alloc at addr: %08x\n", va);
	return 0;
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	// LAB 4: Your code here.
	struct Env* srcenv, * dstenv;
	int ret;
	pte_t* pg_tbl_entry;
	if (envid2env(srcenvid, &srcenv, 1)<0||envid2env(dstenvid, &dstenv, 1)<0){
		return -E_BAD_ENV;
	}

	if ((uintptr_t)srcva>=UTOP||(uintptr_t)dstva>=UTOP||(uintptr_t)srcva%PGSIZE||(uintptr_t)dstva%PGSIZE){
		return -E_INVAL;
	}	
	// check permissions
	if (perm&~(PTE_P|PTE_U|PTE_W|PTE_AVAIL)){
		 return -E_INVAL;
	}
	if ((perm&(PTE_U|PTE_P))!=(PTE_U|PTE_P)){
		return -E_INVAL;
	}

	struct PageInfo* pp = page_lookup(srcenv->env_pgdir, srcva, &pg_tbl_entry);
	// src physical page is not found at src env
	if (!pp) return -E_INVAL;
	// 在srcenv中存在一个要找的物理页面
	if ((perm&PTE_W)&&(!(*pg_tbl_entry&PTE_W))){
		return -E_INVAL;
	}

	if((ret = page_insert(dstenv->env_pgdir, pp, dstva, perm))<0){
		return -E_NO_MEM;
	}

	return 0;
	
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env* e;
	if(envid2env(envid, &e, 1)<0) return -E_BAD_ENV;

	if ((uintptr_t)va>=UTOP||(uintptr_t)va%PGSIZE) 
		return -E_INVAL;

	page_remove(e->env_pgdir, va);
	
	return 0;
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env* e;
	struct PageInfo* pp; pte_t* pte; int ret;
	if ((envid2env(envid, &e, 0)<0))// checkperm = 0 means allowed to send IPC messages to any other env
		return -E_BAD_ENV;

	e->env_ipc_perm = 0;

	if (e->env_ipc_recving==0){ 
		// env_ipc_recving = 0  means that env has not prepared receving
		// the receiver is not blocked at sys_ipc_recv or other environment managed to send first
		return -E_IPC_NOT_RECV;
	} 

	do {
		if (e->env_ipc_dstva == (void*)-1) break; // receiver didnot ask for a page
		// 存在dstva 但srcva not provided
		if (srcva == (void*)-1) return -E_INVAL;
		if (srcva<(void*)UTOP && srcva>=(void*)0){
			if ((uintptr_t)srcva%PGSIZE) return -E_INVAL; // not aligned
			 // not allowable permission
			if (perm&~(PTE_P|PTE_U|PTE_W|PTE_AVAIL)) return -E_INVAL;
			if ((perm&(PTE_U|PTE_P))!=(PTE_U|PTE_P)) return -E_INVAL;

			pp = page_lookup(curenv->env_pgdir,srcva, &pte);
			// send page currently mapped at srcva
			if (!pte||!pp) return -E_INVAL;
			if ((perm&PTE_W)&&(!(*pte&PTE_W))) return -E_INVAL;
			
			if ((ret = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)<0))	
				return ret;
			
		}
	}while(0);

	// mapping succeeded
	e->env_ipc_recving = 0; // to block future sends
	e->env_ipc_from = curenv->env_id;
	e->env_ipc_value = value;
	e->env_ipc_perm = perm;
	e->env_status = ENV_RUNNABLE;
	/*
	 * 给e这个进程的返回值
	*/
	e->env_tf.tf_regs.reg_eax = 0;

	return 0;
	
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((dstva<(void*)UTOP && dstva >= (void*)0)|| dstva == (void*)-1){
		if ((dstva != (void*)-1) &&((uintptr_t)dstva%PGSIZE))
			return -E_INVAL; // not page aligned
		curenv->env_ipc_recving = 1;
		curenv->env_ipc_dstva = dstva;
		// 所谓blocking就是不允许当前进程继续向下执行
		curenv->env_status = ENV_NOT_RUNNABLE;
		sched_yield();
		return 0;
	}
	return -E_INVAL;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
	case SYS_cputs: 
		// cprintf("SYS_cputs\n");
		sys_cputs((const char*)a1,(size_t)a2);
		return 0;
	case SYS_cgetc:
		// cprintf("SYS_cgetc\n");
		return sys_cgetc();
	case SYS_getenvid:
		// cprintf("SYS_getenvid\n");
		return sys_getenvid();
	case SYS_env_destroy:
		// cprintf("SYS_env_destroy\n");
		return sys_env_destroy((envid_t)a1);
	case SYS_yield:
		// cprintf("SYS_yield\n");
		sys_yield();
		return 0;
	case SYS_page_alloc:
		// cprintf("SYS_page_alloc\n");
		return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
	case SYS_page_map:
		// cprintf("SYS_page_map\n");
		return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3, (void*)a4, (int)a5);
	case SYS_page_unmap:
		// cprintf("SYS_page_unmap\n");
		return sys_page_unmap((envid_t)a1,(void*)a2);
	case SYS_exofork:
		// cprintf("SYS_exofork\n");
		return sys_exofork();
	case SYS_env_set_status:
		// cprintf("SYS_env_set_status\n");
		return sys_env_set_status((envid_t)a1,(int)a2);
	case SYS_env_set_pgfault_upcall:
		// cprintf("SYS_env_set_pgfault_upcall\n");
		return sys_env_set_pgfault_upcall((envid_t)a1, (void*)a2);
	case SYS_ipc_try_send:
		// cprintf("SYS_ipc_try_send\n");
		return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void*)a3, (unsigned int)a4);
	case SYS_ipc_recv:
		// cprintf("SYS_ipc_recv\n");
		return sys_ipc_recv((void*)a1);
	default:
		// cprintf("invalid syscall\n");
		return -E_INVAL;
	}

}

