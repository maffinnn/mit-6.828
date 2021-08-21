
#include <inc/lib.h>

void
exit(void)
{
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
	sys_env_destroy(0);
}

