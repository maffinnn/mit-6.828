#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
	// cprintf("[%08x] called wait for child %08x\n", thisenv->env_id, envid);
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
		sys_yield();
}
