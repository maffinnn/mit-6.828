
obj/user/badsegment.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us(the user environment) running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 bd 00 00 00       	call   80010f <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x31>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800092:	e8 49 04 00 00       	call   8004e0 <close_all>
	sys_env_destroy(0);
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	e8 4a 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	f3 0f 1e fb          	endbr32 
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	f3 0f 1e fb          	endbr32 
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	f3 0f 1e fb          	endbr32 
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	b8 03 00 00 00       	mov    $0x3,%eax
  800102:	89 cb                	mov    %ecx,%ebx
  800104:	89 cf                	mov    %ecx,%edi
  800106:	89 ce                	mov    %ecx,%esi
  800108:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	f3 0f 1e fb          	endbr32 
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
	asm volatile("int %1\n"
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 02 00 00 00       	mov    $0x2,%eax
  800123:	89 d1                	mov    %edx,%ecx
  800125:	89 d3                	mov    %edx,%ebx
  800127:	89 d7                	mov    %edx,%edi
  800129:	89 d6                	mov    %edx,%esi
  80012b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_yield>:

void
sys_yield(void)
{
  800132:	f3 0f 1e fb          	endbr32 
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016a:	b8 04 00 00 00       	mov    $0x4,%eax
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5f                   	pop    %edi
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80017b:	f3 0f 1e fb          	endbr32 
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
	asm volatile("int %1\n"
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018b:	b8 05 00 00 00       	mov    $0x5,%eax
  800190:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800193:	8b 7d 14             	mov    0x14(%ebp),%edi
  800196:	8b 75 18             	mov    0x18(%ebp),%esi
  800199:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5f                   	pop    %edi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001a0:	f3 0f 1e fb          	endbr32 
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ba:	89 df                	mov    %ebx,%edi
  8001bc:	89 de                	mov    %ebx,%esi
  8001be:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001c0:	5b                   	pop    %ebx
  8001c1:	5e                   	pop    %esi
  8001c2:	5f                   	pop    %edi
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    

008001c5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001c5:	f3 0f 1e fb          	endbr32 
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001da:	b8 08 00 00 00       	mov    $0x8,%eax
  8001df:	89 df                	mov    %ebx,%edi
  8001e1:	89 de                	mov    %ebx,%esi
  8001e3:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5f                   	pop    %edi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001ea:	f3 0f 1e fb          	endbr32 
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	57                   	push   %edi
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	b8 09 00 00 00       	mov    $0x9,%eax
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80020f:	f3 0f 1e fb          	endbr32 
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	57                   	push   %edi
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
	asm volatile("int %1\n"
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	8b 55 08             	mov    0x8(%ebp),%edx
  800221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800224:	b8 0a 00 00 00       	mov    $0xa,%eax
  800229:	89 df                	mov    %ebx,%edi
  80022b:	89 de                	mov    %ebx,%esi
  80022d:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800234:	f3 0f 1e fb          	endbr32 
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	b8 0c 00 00 00       	mov    $0xc,%eax
  800249:	be 00 00 00 00       	mov    $0x0,%esi
  80024e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800251:	8b 7d 14             	mov    0x14(%ebp),%edi
  800254:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80025b:	f3 0f 1e fb          	endbr32 
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
	asm volatile("int %1\n"
  800265:	b9 00 00 00 00       	mov    $0x0,%ecx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800272:	89 cb                	mov    %ecx,%ebx
  800274:	89 cf                	mov    %ecx,%edi
  800276:	89 ce                	mov    %ecx,%esi
  800278:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80027f:	f3 0f 1e fb          	endbr32 
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
	asm volatile("int %1\n"
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
  80028e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800293:	89 d1                	mov    %edx,%ecx
  800295:	89 d3                	mov    %edx,%ebx
  800297:	89 d7                	mov    %edx,%edi
  800299:	89 d6                	mov    %edx,%esi
  80029b:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80029d:	5b                   	pop    %ebx
  80029e:	5e                   	pop    %esi
  80029f:	5f                   	pop    %edi
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8002a2:	f3 0f 1e fb          	endbr32 
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002bc:	89 df                	mov    %ebx,%edi
  8002be:	89 de                	mov    %ebx,%esi
  8002c0:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002c2:	5b                   	pop    %ebx
  8002c3:	5e                   	pop    %esi
  8002c4:	5f                   	pop    %edi
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002c7:	f3 0f 1e fb          	endbr32 
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8002e1:	89 df                	mov    %ebx,%edi
  8002e3:	89 de                	mov    %ebx,%esi
  8002e5:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002ec:	f3 0f 1e fb          	endbr32 
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8002fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800300:	f3 0f 1e fb          	endbr32 
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80030f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800314:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80031b:	f3 0f 1e fb          	endbr32 
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800327:	89 c2                	mov    %eax,%edx
  800329:	c1 ea 16             	shr    $0x16,%edx
  80032c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800333:	f6 c2 01             	test   $0x1,%dl
  800336:	74 2d                	je     800365 <fd_alloc+0x4a>
  800338:	89 c2                	mov    %eax,%edx
  80033a:	c1 ea 0c             	shr    $0xc,%edx
  80033d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800344:	f6 c2 01             	test   $0x1,%dl
  800347:	74 1c                	je     800365 <fd_alloc+0x4a>
  800349:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80034e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800353:	75 d2                	jne    800327 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80035e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800363:	eb 0a                	jmp    80036f <fd_alloc+0x54>
			*fd_store = fd;
  800365:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800368:	89 01                	mov    %eax,(%ecx)
			return 0;
  80036a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800371:	f3 0f 1e fb          	endbr32 
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80037b:	83 f8 1f             	cmp    $0x1f,%eax
  80037e:	77 30                	ja     8003b0 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800380:	c1 e0 0c             	shl    $0xc,%eax
  800383:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800388:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80038e:	f6 c2 01             	test   $0x1,%dl
  800391:	74 24                	je     8003b7 <fd_lookup+0x46>
  800393:	89 c2                	mov    %eax,%edx
  800395:	c1 ea 0c             	shr    $0xc,%edx
  800398:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039f:	f6 c2 01             	test   $0x1,%dl
  8003a2:	74 1a                	je     8003be <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	89 02                	mov    %eax,(%edx)
	return 0;
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    
		return -E_INVAL;
  8003b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003b5:	eb f7                	jmp    8003ae <fd_lookup+0x3d>
		return -E_INVAL;
  8003b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003bc:	eb f0                	jmp    8003ae <fd_lookup+0x3d>
  8003be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c3:	eb e9                	jmp    8003ae <fd_lookup+0x3d>

008003c5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003c5:	f3 0f 1e fb          	endbr32 
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003dc:	39 08                	cmp    %ecx,(%eax)
  8003de:	74 38                	je     800418 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8003e0:	83 c2 01             	add    $0x1,%edx
  8003e3:	8b 04 95 e8 23 80 00 	mov    0x8023e8(,%edx,4),%eax
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	75 ee                	jne    8003dc <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8003f3:	8b 40 48             	mov    0x48(%eax),%eax
  8003f6:	83 ec 04             	sub    $0x4,%esp
  8003f9:	51                   	push   %ecx
  8003fa:	50                   	push   %eax
  8003fb:	68 6c 23 80 00       	push   $0x80236c
  800400:	e8 d6 11 00 00       	call   8015db <cprintf>
	*dev = 0;
  800405:	8b 45 0c             	mov    0xc(%ebp),%eax
  800408:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800416:	c9                   	leave  
  800417:	c3                   	ret    
			*dev = devtab[i];
  800418:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
  800422:	eb f2                	jmp    800416 <dev_lookup+0x51>

00800424 <fd_close>:
{
  800424:	f3 0f 1e fb          	endbr32 
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 24             	sub    $0x24,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800437:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80043a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80043b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800441:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800444:	50                   	push   %eax
  800445:	e8 27 ff ff ff       	call   800371 <fd_lookup>
  80044a:	89 c3                	mov    %eax,%ebx
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	85 c0                	test   %eax,%eax
  800451:	78 05                	js     800458 <fd_close+0x34>
	    || fd != fd2)
  800453:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800456:	74 16                	je     80046e <fd_close+0x4a>
		return (must_exist ? r : 0);
  800458:	89 f8                	mov    %edi,%eax
  80045a:	84 c0                	test   %al,%al
  80045c:	b8 00 00 00 00       	mov    $0x0,%eax
  800461:	0f 44 d8             	cmove  %eax,%ebx
}
  800464:	89 d8                	mov    %ebx,%eax
  800466:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800469:	5b                   	pop    %ebx
  80046a:	5e                   	pop    %esi
  80046b:	5f                   	pop    %edi
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800474:	50                   	push   %eax
  800475:	ff 36                	pushl  (%esi)
  800477:	e8 49 ff ff ff       	call   8003c5 <dev_lookup>
  80047c:	89 c3                	mov    %eax,%ebx
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	85 c0                	test   %eax,%eax
  800483:	78 1a                	js     80049f <fd_close+0x7b>
		if (dev->dev_close)
  800485:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800488:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80048b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800490:	85 c0                	test   %eax,%eax
  800492:	74 0b                	je     80049f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800494:	83 ec 0c             	sub    $0xc,%esp
  800497:	56                   	push   %esi
  800498:	ff d0                	call   *%eax
  80049a:	89 c3                	mov    %eax,%ebx
  80049c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	56                   	push   %esi
  8004a3:	6a 00                	push   $0x0
  8004a5:	e8 f6 fc ff ff       	call   8001a0 <sys_page_unmap>
	return r;
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	eb b5                	jmp    800464 <fd_close+0x40>

008004af <close>:

int
close(int fdnum)
{
  8004af:	f3 0f 1e fb          	endbr32 
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004bc:	50                   	push   %eax
  8004bd:	ff 75 08             	pushl  0x8(%ebp)
  8004c0:	e8 ac fe ff ff       	call   800371 <fd_lookup>
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 02                	jns    8004ce <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    
		return fd_close(fd, 1);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	6a 01                	push   $0x1
  8004d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8004d6:	e8 49 ff ff ff       	call   800424 <fd_close>
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	eb ec                	jmp    8004cc <close+0x1d>

008004e0 <close_all>:

void
close_all(void)
{
  8004e0:	f3 0f 1e fb          	endbr32 
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	53                   	push   %ebx
  8004e8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	e8 b6 ff ff ff       	call   8004af <close>
	for (i = 0; i < MAXFD; i++)
  8004f9:	83 c3 01             	add    $0x1,%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	83 fb 20             	cmp    $0x20,%ebx
  800502:	75 ec                	jne    8004f0 <close_all+0x10>
}
  800504:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800507:	c9                   	leave  
  800508:	c3                   	ret    

00800509 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800509:	f3 0f 1e fb          	endbr32 
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	53                   	push   %ebx
  800513:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800516:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800519:	50                   	push   %eax
  80051a:	ff 75 08             	pushl  0x8(%ebp)
  80051d:	e8 4f fe ff ff       	call   800371 <fd_lookup>
  800522:	89 c3                	mov    %eax,%ebx
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	0f 88 81 00 00 00    	js     8005b0 <dup+0xa7>
		return r;
	close(newfdnum);
  80052f:	83 ec 0c             	sub    $0xc,%esp
  800532:	ff 75 0c             	pushl  0xc(%ebp)
  800535:	e8 75 ff ff ff       	call   8004af <close>

	newfd = INDEX2FD(newfdnum);
  80053a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80053d:	c1 e6 0c             	shl    $0xc,%esi
  800540:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800546:	83 c4 04             	add    $0x4,%esp
  800549:	ff 75 e4             	pushl  -0x1c(%ebp)
  80054c:	e8 af fd ff ff       	call   800300 <fd2data>
  800551:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800553:	89 34 24             	mov    %esi,(%esp)
  800556:	e8 a5 fd ff ff       	call   800300 <fd2data>
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800560:	89 d8                	mov    %ebx,%eax
  800562:	c1 e8 16             	shr    $0x16,%eax
  800565:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80056c:	a8 01                	test   $0x1,%al
  80056e:	74 11                	je     800581 <dup+0x78>
  800570:	89 d8                	mov    %ebx,%eax
  800572:	c1 e8 0c             	shr    $0xc,%eax
  800575:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80057c:	f6 c2 01             	test   $0x1,%dl
  80057f:	75 39                	jne    8005ba <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 d0                	mov    %edx,%eax
  800586:	c1 e8 0c             	shr    $0xc,%eax
  800589:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800590:	83 ec 0c             	sub    $0xc,%esp
  800593:	25 07 0e 00 00       	and    $0xe07,%eax
  800598:	50                   	push   %eax
  800599:	56                   	push   %esi
  80059a:	6a 00                	push   $0x0
  80059c:	52                   	push   %edx
  80059d:	6a 00                	push   $0x0
  80059f:	e8 d7 fb ff ff       	call   80017b <sys_page_map>
  8005a4:	89 c3                	mov    %eax,%ebx
  8005a6:	83 c4 20             	add    $0x20,%esp
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	78 31                	js     8005de <dup+0xd5>
		goto err;

	return newfdnum;
  8005ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005b0:	89 d8                	mov    %ebx,%eax
  8005b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b5:	5b                   	pop    %ebx
  8005b6:	5e                   	pop    %esi
  8005b7:	5f                   	pop    %edi
  8005b8:	5d                   	pop    %ebp
  8005b9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	57                   	push   %edi
  8005cb:	6a 00                	push   $0x0
  8005cd:	53                   	push   %ebx
  8005ce:	6a 00                	push   $0x0
  8005d0:	e8 a6 fb ff ff       	call   80017b <sys_page_map>
  8005d5:	89 c3                	mov    %eax,%ebx
  8005d7:	83 c4 20             	add    $0x20,%esp
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	79 a3                	jns    800581 <dup+0x78>
	sys_page_unmap(0, newfd);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	56                   	push   %esi
  8005e2:	6a 00                	push   $0x0
  8005e4:	e8 b7 fb ff ff       	call   8001a0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005e9:	83 c4 08             	add    $0x8,%esp
  8005ec:	57                   	push   %edi
  8005ed:	6a 00                	push   $0x0
  8005ef:	e8 ac fb ff ff       	call   8001a0 <sys_page_unmap>
	return r;
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	eb b7                	jmp    8005b0 <dup+0xa7>

008005f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8005f9:	f3 0f 1e fb          	endbr32 
  8005fd:	55                   	push   %ebp
  8005fe:	89 e5                	mov    %esp,%ebp
  800600:	53                   	push   %ebx
  800601:	83 ec 1c             	sub    $0x1c,%esp
  800604:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800607:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80060a:	50                   	push   %eax
  80060b:	53                   	push   %ebx
  80060c:	e8 60 fd ff ff       	call   800371 <fd_lookup>
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	85 c0                	test   %eax,%eax
  800616:	78 3f                	js     800657 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80061e:	50                   	push   %eax
  80061f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800622:	ff 30                	pushl  (%eax)
  800624:	e8 9c fd ff ff       	call   8003c5 <dev_lookup>
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	85 c0                	test   %eax,%eax
  80062e:	78 27                	js     800657 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800630:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800633:	8b 42 08             	mov    0x8(%edx),%eax
  800636:	83 e0 03             	and    $0x3,%eax
  800639:	83 f8 01             	cmp    $0x1,%eax
  80063c:	74 1e                	je     80065c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80063e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800641:	8b 40 08             	mov    0x8(%eax),%eax
  800644:	85 c0                	test   %eax,%eax
  800646:	74 35                	je     80067d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800648:	83 ec 04             	sub    $0x4,%esp
  80064b:	ff 75 10             	pushl  0x10(%ebp)
  80064e:	ff 75 0c             	pushl  0xc(%ebp)
  800651:	52                   	push   %edx
  800652:	ff d0                	call   *%eax
  800654:	83 c4 10             	add    $0x10,%esp
}
  800657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80065a:	c9                   	leave  
  80065b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80065c:	a1 08 40 80 00       	mov    0x804008,%eax
  800661:	8b 40 48             	mov    0x48(%eax),%eax
  800664:	83 ec 04             	sub    $0x4,%esp
  800667:	53                   	push   %ebx
  800668:	50                   	push   %eax
  800669:	68 ad 23 80 00       	push   $0x8023ad
  80066e:	e8 68 0f 00 00       	call   8015db <cprintf>
		return -E_INVAL;
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80067b:	eb da                	jmp    800657 <read+0x5e>
		return -E_NOT_SUPP;
  80067d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800682:	eb d3                	jmp    800657 <read+0x5e>

00800684 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800684:	f3 0f 1e fb          	endbr32 
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	57                   	push   %edi
  80068c:	56                   	push   %esi
  80068d:	53                   	push   %ebx
  80068e:	83 ec 0c             	sub    $0xc,%esp
  800691:	8b 7d 08             	mov    0x8(%ebp),%edi
  800694:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800697:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069c:	eb 02                	jmp    8006a0 <readn+0x1c>
  80069e:	01 c3                	add    %eax,%ebx
  8006a0:	39 f3                	cmp    %esi,%ebx
  8006a2:	73 21                	jae    8006c5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006a4:	83 ec 04             	sub    $0x4,%esp
  8006a7:	89 f0                	mov    %esi,%eax
  8006a9:	29 d8                	sub    %ebx,%eax
  8006ab:	50                   	push   %eax
  8006ac:	89 d8                	mov    %ebx,%eax
  8006ae:	03 45 0c             	add    0xc(%ebp),%eax
  8006b1:	50                   	push   %eax
  8006b2:	57                   	push   %edi
  8006b3:	e8 41 ff ff ff       	call   8005f9 <read>
		if (m < 0)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	78 04                	js     8006c3 <readn+0x3f>
			return m;
		if (m == 0)
  8006bf:	75 dd                	jne    80069e <readn+0x1a>
  8006c1:	eb 02                	jmp    8006c5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006c5:	89 d8                	mov    %ebx,%eax
  8006c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5f                   	pop    %edi
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006cf:	f3 0f 1e fb          	endbr32 
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	53                   	push   %ebx
  8006d7:	83 ec 1c             	sub    $0x1c,%esp
  8006da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e0:	50                   	push   %eax
  8006e1:	53                   	push   %ebx
  8006e2:	e8 8a fc ff ff       	call   800371 <fd_lookup>
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	78 3a                	js     800728 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f4:	50                   	push   %eax
  8006f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f8:	ff 30                	pushl  (%eax)
  8006fa:	e8 c6 fc ff ff       	call   8003c5 <dev_lookup>
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 c0                	test   %eax,%eax
  800704:	78 22                	js     800728 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800706:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800709:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80070d:	74 1e                	je     80072d <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80070f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800712:	8b 52 0c             	mov    0xc(%edx),%edx
  800715:	85 d2                	test   %edx,%edx
  800717:	74 35                	je     80074e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800719:	83 ec 04             	sub    $0x4,%esp
  80071c:	ff 75 10             	pushl  0x10(%ebp)
  80071f:	ff 75 0c             	pushl  0xc(%ebp)
  800722:	50                   	push   %eax
  800723:	ff d2                	call   *%edx
  800725:	83 c4 10             	add    $0x10,%esp
}
  800728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80072d:	a1 08 40 80 00       	mov    0x804008,%eax
  800732:	8b 40 48             	mov    0x48(%eax),%eax
  800735:	83 ec 04             	sub    $0x4,%esp
  800738:	53                   	push   %ebx
  800739:	50                   	push   %eax
  80073a:	68 c9 23 80 00       	push   $0x8023c9
  80073f:	e8 97 0e 00 00       	call   8015db <cprintf>
		return -E_INVAL;
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074c:	eb da                	jmp    800728 <write+0x59>
		return -E_NOT_SUPP;
  80074e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800753:	eb d3                	jmp    800728 <write+0x59>

00800755 <seek>:

int
seek(int fdnum, off_t offset)
{
  800755:	f3 0f 1e fb          	endbr32 
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80075f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	ff 75 08             	pushl  0x8(%ebp)
  800766:	e8 06 fc ff ff       	call   800371 <fd_lookup>
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 0e                	js     800780 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
  800775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800778:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800782:	f3 0f 1e fb          	endbr32 
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	53                   	push   %ebx
  80078a:	83 ec 1c             	sub    $0x1c,%esp
  80078d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800790:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800793:	50                   	push   %eax
  800794:	53                   	push   %ebx
  800795:	e8 d7 fb ff ff       	call   800371 <fd_lookup>
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	78 37                	js     8007d8 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ab:	ff 30                	pushl  (%eax)
  8007ad:	e8 13 fc ff ff       	call   8003c5 <dev_lookup>
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	78 1f                	js     8007d8 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c0:	74 1b                	je     8007dd <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c5:	8b 52 18             	mov    0x18(%edx),%edx
  8007c8:	85 d2                	test   %edx,%edx
  8007ca:	74 32                	je     8007fe <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	50                   	push   %eax
  8007d3:	ff d2                	call   *%edx
  8007d5:	83 c4 10             	add    $0x10,%esp
}
  8007d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007dd:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007e2:	8b 40 48             	mov    0x48(%eax),%eax
  8007e5:	83 ec 04             	sub    $0x4,%esp
  8007e8:	53                   	push   %ebx
  8007e9:	50                   	push   %eax
  8007ea:	68 8c 23 80 00       	push   $0x80238c
  8007ef:	e8 e7 0d 00 00       	call   8015db <cprintf>
		return -E_INVAL;
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fc:	eb da                	jmp    8007d8 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8007fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800803:	eb d3                	jmp    8007d8 <ftruncate+0x56>

00800805 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800805:	f3 0f 1e fb          	endbr32 
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	83 ec 1c             	sub    $0x1c,%esp
  800810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800813:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800816:	50                   	push   %eax
  800817:	ff 75 08             	pushl  0x8(%ebp)
  80081a:	e8 52 fb ff ff       	call   800371 <fd_lookup>
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	85 c0                	test   %eax,%eax
  800824:	78 4b                	js     800871 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082c:	50                   	push   %eax
  80082d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800830:	ff 30                	pushl  (%eax)
  800832:	e8 8e fb ff ff       	call   8003c5 <dev_lookup>
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	85 c0                	test   %eax,%eax
  80083c:	78 33                	js     800871 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80083e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800841:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800845:	74 2f                	je     800876 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800847:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80084a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800851:	00 00 00 
	stat->st_isdir = 0;
  800854:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80085b:	00 00 00 
	stat->st_dev = dev;
  80085e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	ff 75 f0             	pushl  -0x10(%ebp)
  80086b:	ff 50 14             	call   *0x14(%eax)
  80086e:	83 c4 10             	add    $0x10,%esp
}
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    
		return -E_NOT_SUPP;
  800876:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80087b:	eb f4                	jmp    800871 <fstat+0x6c>

0080087d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80087d:	f3 0f 1e fb          	endbr32 
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	6a 00                	push   $0x0
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 01 02 00 00       	call   800a94 <open>
  800893:	89 c3                	mov    %eax,%ebx
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	85 c0                	test   %eax,%eax
  80089a:	78 1b                	js     8008b7 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	ff 75 0c             	pushl  0xc(%ebp)
  8008a2:	50                   	push   %eax
  8008a3:	e8 5d ff ff ff       	call   800805 <fstat>
  8008a8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008aa:	89 1c 24             	mov    %ebx,(%esp)
  8008ad:	e8 fd fb ff ff       	call   8004af <close>
	return r;
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	89 f3                	mov    %esi,%ebx
}
  8008b7:	89 d8                	mov    %ebx,%eax
  8008b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	89 c6                	mov    %eax,%esi
  8008c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008d0:	74 27                	je     8008f9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008d2:	6a 07                	push   $0x7
  8008d4:	68 00 50 80 00       	push   $0x805000
  8008d9:	56                   	push   %esi
  8008da:	ff 35 00 40 80 00    	pushl  0x804000
  8008e0:	e8 27 17 00 00       	call   80200c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008e5:	83 c4 0c             	add    $0xc,%esp
  8008e8:	6a 00                	push   $0x0
  8008ea:	53                   	push   %ebx
  8008eb:	6a 00                	push   $0x0
  8008ed:	e8 ad 16 00 00       	call   801f9f <ipc_recv>
}
  8008f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008f9:	83 ec 0c             	sub    $0xc,%esp
  8008fc:	6a 01                	push   $0x1
  8008fe:	e8 61 17 00 00       	call   802064 <ipc_find_env>
  800903:	a3 00 40 80 00       	mov    %eax,0x804000
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	eb c5                	jmp    8008d2 <fsipc+0x12>

0080090d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80090d:	f3 0f 1e fb          	endbr32 
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 40 0c             	mov    0xc(%eax),%eax
  80091d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80092a:	ba 00 00 00 00       	mov    $0x0,%edx
  80092f:	b8 02 00 00 00       	mov    $0x2,%eax
  800934:	e8 87 ff ff ff       	call   8008c0 <fsipc>
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <devfile_flush>:
{
  80093b:	f3 0f 1e fb          	endbr32 
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 40 0c             	mov    0xc(%eax),%eax
  80094b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800950:	ba 00 00 00 00       	mov    $0x0,%edx
  800955:	b8 06 00 00 00       	mov    $0x6,%eax
  80095a:	e8 61 ff ff ff       	call   8008c0 <fsipc>
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <devfile_stat>:
{
  800961:	f3 0f 1e fb          	endbr32 
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	53                   	push   %ebx
  800969:	83 ec 04             	sub    $0x4,%esp
  80096c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 40 0c             	mov    0xc(%eax),%eax
  800975:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80097a:	ba 00 00 00 00       	mov    $0x0,%edx
  80097f:	b8 05 00 00 00       	mov    $0x5,%eax
  800984:	e8 37 ff ff ff       	call   8008c0 <fsipc>
  800989:	85 c0                	test   %eax,%eax
  80098b:	78 2c                	js     8009b9 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80098d:	83 ec 08             	sub    $0x8,%esp
  800990:	68 00 50 80 00       	push   $0x805000
  800995:	53                   	push   %ebx
  800996:	e8 4a 12 00 00       	call   801be5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80099b:	a1 80 50 80 00       	mov    0x805080,%eax
  8009a0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ab:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009b1:	83 c4 10             	add    $0x10,%esp
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <devfile_write>:
{
  8009be:	f3 0f 1e fb          	endbr32 
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 0c             	sub    $0xc,%esp
  8009c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009d0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009d5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009db:	8b 52 0c             	mov    0xc(%edx),%edx
  8009de:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e9:	50                   	push   %eax
  8009ea:	ff 75 0c             	pushl  0xc(%ebp)
  8009ed:	68 08 50 80 00       	push   $0x805008
  8009f2:	e8 ec 13 00 00       	call   801de3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8009f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fc:	b8 04 00 00 00       	mov    $0x4,%eax
  800a01:	e8 ba fe ff ff       	call   8008c0 <fsipc>
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <devfile_read>:
{
  800a08:	f3 0f 1e fb          	endbr32 
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a1f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2f:	e8 8c fe ff ff       	call   8008c0 <fsipc>
  800a34:	89 c3                	mov    %eax,%ebx
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 1f                	js     800a59 <devfile_read+0x51>
	assert(r <= n);
  800a3a:	39 f0                	cmp    %esi,%eax
  800a3c:	77 24                	ja     800a62 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a3e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a43:	7f 36                	jg     800a7b <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a45:	83 ec 04             	sub    $0x4,%esp
  800a48:	50                   	push   %eax
  800a49:	68 00 50 80 00       	push   $0x805000
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	e8 8d 13 00 00       	call   801de3 <memmove>
	return r;
  800a56:	83 c4 10             	add    $0x10,%esp
}
  800a59:	89 d8                	mov    %ebx,%eax
  800a5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    
	assert(r <= n);
  800a62:	68 fc 23 80 00       	push   $0x8023fc
  800a67:	68 03 24 80 00       	push   $0x802403
  800a6c:	68 8c 00 00 00       	push   $0x8c
  800a71:	68 18 24 80 00       	push   $0x802418
  800a76:	e8 79 0a 00 00       	call   8014f4 <_panic>
	assert(r <= PGSIZE);
  800a7b:	68 23 24 80 00       	push   $0x802423
  800a80:	68 03 24 80 00       	push   $0x802403
  800a85:	68 8d 00 00 00       	push   $0x8d
  800a8a:	68 18 24 80 00       	push   $0x802418
  800a8f:	e8 60 0a 00 00       	call   8014f4 <_panic>

00800a94 <open>:
{
  800a94:	f3 0f 1e fb          	endbr32 
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	83 ec 1c             	sub    $0x1c,%esp
  800aa0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa3:	56                   	push   %esi
  800aa4:	e8 f9 10 00 00       	call   801ba2 <strlen>
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab1:	7f 6c                	jg     800b1f <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ab3:	83 ec 0c             	sub    $0xc,%esp
  800ab6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab9:	50                   	push   %eax
  800aba:	e8 5c f8 ff ff       	call   80031b <fd_alloc>
  800abf:	89 c3                	mov    %eax,%ebx
  800ac1:	83 c4 10             	add    $0x10,%esp
  800ac4:	85 c0                	test   %eax,%eax
  800ac6:	78 3c                	js     800b04 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ac8:	83 ec 08             	sub    $0x8,%esp
  800acb:	56                   	push   %esi
  800acc:	68 00 50 80 00       	push   $0x805000
  800ad1:	e8 0f 11 00 00       	call   801be5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad9:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ade:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae6:	e8 d5 fd ff ff       	call   8008c0 <fsipc>
  800aeb:	89 c3                	mov    %eax,%ebx
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	85 c0                	test   %eax,%eax
  800af2:	78 19                	js     800b0d <open+0x79>
	return fd2num(fd);
  800af4:	83 ec 0c             	sub    $0xc,%esp
  800af7:	ff 75 f4             	pushl  -0xc(%ebp)
  800afa:	e8 ed f7 ff ff       	call   8002ec <fd2num>
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	83 c4 10             	add    $0x10,%esp
}
  800b04:	89 d8                	mov    %ebx,%eax
  800b06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
		fd_close(fd, 0);
  800b0d:	83 ec 08             	sub    $0x8,%esp
  800b10:	6a 00                	push   $0x0
  800b12:	ff 75 f4             	pushl  -0xc(%ebp)
  800b15:	e8 0a f9 ff ff       	call   800424 <fd_close>
		return r;
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	eb e5                	jmp    800b04 <open+0x70>
		return -E_BAD_PATH;
  800b1f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b24:	eb de                	jmp    800b04 <open+0x70>

00800b26 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b26:	f3 0f 1e fb          	endbr32 
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b30:	ba 00 00 00 00       	mov    $0x0,%edx
  800b35:	b8 08 00 00 00       	mov    $0x8,%eax
  800b3a:	e8 81 fd ff ff       	call   8008c0 <fsipc>
}
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b41:	f3 0f 1e fb          	endbr32 
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b4b:	68 8f 24 80 00       	push   $0x80248f
  800b50:	ff 75 0c             	pushl  0xc(%ebp)
  800b53:	e8 8d 10 00 00       	call   801be5 <strcpy>
	return 0;
}
  800b58:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <devsock_close>:
{
  800b5f:	f3 0f 1e fb          	endbr32 
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	53                   	push   %ebx
  800b67:	83 ec 10             	sub    $0x10,%esp
  800b6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b6d:	53                   	push   %ebx
  800b6e:	e8 2e 15 00 00       	call   8020a1 <pageref>
  800b73:	89 c2                	mov    %eax,%edx
  800b75:	83 c4 10             	add    $0x10,%esp
		return 0;
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800b7d:	83 fa 01             	cmp    $0x1,%edx
  800b80:	74 05                	je     800b87 <devsock_close+0x28>
}
  800b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	ff 73 0c             	pushl  0xc(%ebx)
  800b8d:	e8 e3 02 00 00       	call   800e75 <nsipc_close>
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	eb eb                	jmp    800b82 <devsock_close+0x23>

00800b97 <devsock_write>:
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800ba1:	6a 00                	push   $0x0
  800ba3:	ff 75 10             	pushl  0x10(%ebp)
  800ba6:	ff 75 0c             	pushl  0xc(%ebp)
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	ff 70 0c             	pushl  0xc(%eax)
  800baf:	e8 b5 03 00 00       	call   800f69 <nsipc_send>
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <devsock_read>:
{
  800bb6:	f3 0f 1e fb          	endbr32 
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 10             	pushl  0x10(%ebp)
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	ff 70 0c             	pushl  0xc(%eax)
  800bce:	e8 1f 03 00 00       	call   800ef2 <nsipc_recv>
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <fd2sockid>:
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bdb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bde:	52                   	push   %edx
  800bdf:	50                   	push   %eax
  800be0:	e8 8c f7 ff ff       	call   800371 <fd_lookup>
  800be5:	83 c4 10             	add    $0x10,%esp
  800be8:	85 c0                	test   %eax,%eax
  800bea:	78 10                	js     800bfc <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bef:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800bf5:	39 08                	cmp    %ecx,(%eax)
  800bf7:	75 05                	jne    800bfe <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800bf9:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    
		return -E_NOT_SUPP;
  800bfe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c03:	eb f7                	jmp    800bfc <fd2sockid+0x27>

00800c05 <alloc_sockfd>:
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 1c             	sub    $0x1c,%esp
  800c0d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c12:	50                   	push   %eax
  800c13:	e8 03 f7 ff ff       	call   80031b <fd_alloc>
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	83 c4 10             	add    $0x10,%esp
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	78 43                	js     800c64 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c21:	83 ec 04             	sub    $0x4,%esp
  800c24:	68 07 04 00 00       	push   $0x407
  800c29:	ff 75 f4             	pushl  -0xc(%ebp)
  800c2c:	6a 00                	push   $0x0
  800c2e:	e8 22 f5 ff ff       	call   800155 <sys_page_alloc>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	83 c4 10             	add    $0x10,%esp
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	78 28                	js     800c64 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3f:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c45:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c51:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	e8 8f f6 ff ff       	call   8002ec <fd2num>
  800c5d:	89 c3                	mov    %eax,%ebx
  800c5f:	83 c4 10             	add    $0x10,%esp
  800c62:	eb 0c                	jmp    800c70 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	56                   	push   %esi
  800c68:	e8 08 02 00 00       	call   800e75 <nsipc_close>
		return r;
  800c6d:	83 c4 10             	add    $0x10,%esp
}
  800c70:	89 d8                	mov    %ebx,%eax
  800c72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <accept>:
{
  800c79:	f3 0f 1e fb          	endbr32 
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	e8 4a ff ff ff       	call   800bd5 <fd2sockid>
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	78 1b                	js     800caa <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800c8f:	83 ec 04             	sub    $0x4,%esp
  800c92:	ff 75 10             	pushl  0x10(%ebp)
  800c95:	ff 75 0c             	pushl  0xc(%ebp)
  800c98:	50                   	push   %eax
  800c99:	e8 22 01 00 00       	call   800dc0 <nsipc_accept>
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	78 05                	js     800caa <accept+0x31>
	return alloc_sockfd(r);
  800ca5:	e8 5b ff ff ff       	call   800c05 <alloc_sockfd>
}
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    

00800cac <bind>:
{
  800cac:	f3 0f 1e fb          	endbr32 
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	e8 17 ff ff ff       	call   800bd5 <fd2sockid>
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	78 12                	js     800cd4 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800cc2:	83 ec 04             	sub    $0x4,%esp
  800cc5:	ff 75 10             	pushl  0x10(%ebp)
  800cc8:	ff 75 0c             	pushl  0xc(%ebp)
  800ccb:	50                   	push   %eax
  800ccc:	e8 45 01 00 00       	call   800e16 <nsipc_bind>
  800cd1:	83 c4 10             	add    $0x10,%esp
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <shutdown>:
{
  800cd6:	f3 0f 1e fb          	endbr32 
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	e8 ed fe ff ff       	call   800bd5 <fd2sockid>
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	78 0f                	js     800cfb <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800cec:	83 ec 08             	sub    $0x8,%esp
  800cef:	ff 75 0c             	pushl  0xc(%ebp)
  800cf2:	50                   	push   %eax
  800cf3:	e8 57 01 00 00       	call   800e4f <nsipc_shutdown>
  800cf8:	83 c4 10             	add    $0x10,%esp
}
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    

00800cfd <connect>:
{
  800cfd:	f3 0f 1e fb          	endbr32 
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	e8 c6 fe ff ff       	call   800bd5 <fd2sockid>
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	78 12                	js     800d25 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d13:	83 ec 04             	sub    $0x4,%esp
  800d16:	ff 75 10             	pushl  0x10(%ebp)
  800d19:	ff 75 0c             	pushl  0xc(%ebp)
  800d1c:	50                   	push   %eax
  800d1d:	e8 71 01 00 00       	call   800e93 <nsipc_connect>
  800d22:	83 c4 10             	add    $0x10,%esp
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <listen>:
{
  800d27:	f3 0f 1e fb          	endbr32 
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	e8 9c fe ff ff       	call   800bd5 <fd2sockid>
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	78 0f                	js     800d4c <listen+0x25>
	return nsipc_listen(r, backlog);
  800d3d:	83 ec 08             	sub    $0x8,%esp
  800d40:	ff 75 0c             	pushl  0xc(%ebp)
  800d43:	50                   	push   %eax
  800d44:	e8 83 01 00 00       	call   800ecc <nsipc_listen>
  800d49:	83 c4 10             	add    $0x10,%esp
}
  800d4c:	c9                   	leave  
  800d4d:	c3                   	ret    

00800d4e <socket>:

int
socket(int domain, int type, int protocol)
{
  800d4e:	f3 0f 1e fb          	endbr32 
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d58:	ff 75 10             	pushl  0x10(%ebp)
  800d5b:	ff 75 0c             	pushl  0xc(%ebp)
  800d5e:	ff 75 08             	pushl  0x8(%ebp)
  800d61:	e8 65 02 00 00       	call   800fcb <nsipc_socket>
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	78 05                	js     800d72 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d6d:	e8 93 fe ff ff       	call   800c05 <alloc_sockfd>
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	53                   	push   %ebx
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d7d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d84:	74 26                	je     800dac <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d86:	6a 07                	push   $0x7
  800d88:	68 00 60 80 00       	push   $0x806000
  800d8d:	53                   	push   %ebx
  800d8e:	ff 35 04 40 80 00    	pushl  0x804004
  800d94:	e8 73 12 00 00       	call   80200c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800d99:	83 c4 0c             	add    $0xc,%esp
  800d9c:	6a 00                	push   $0x0
  800d9e:	6a 00                	push   $0x0
  800da0:	6a 00                	push   $0x0
  800da2:	e8 f8 11 00 00       	call   801f9f <ipc_recv>
}
  800da7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800daa:	c9                   	leave  
  800dab:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	6a 02                	push   $0x2
  800db1:	e8 ae 12 00 00       	call   802064 <ipc_find_env>
  800db6:	a3 04 40 80 00       	mov    %eax,0x804004
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	eb c6                	jmp    800d86 <nsipc+0x12>

00800dc0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dd4:	8b 06                	mov    (%esi),%eax
  800dd6:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ddb:	b8 01 00 00 00       	mov    $0x1,%eax
  800de0:	e8 8f ff ff ff       	call   800d74 <nsipc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	85 c0                	test   %eax,%eax
  800de9:	79 09                	jns    800df4 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800deb:	89 d8                	mov    %ebx,%eax
  800ded:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	ff 35 10 60 80 00    	pushl  0x806010
  800dfd:	68 00 60 80 00       	push   $0x806000
  800e02:	ff 75 0c             	pushl  0xc(%ebp)
  800e05:	e8 d9 0f 00 00       	call   801de3 <memmove>
		*addrlen = ret->ret_addrlen;
  800e0a:	a1 10 60 80 00       	mov    0x806010,%eax
  800e0f:	89 06                	mov    %eax,(%esi)
  800e11:	83 c4 10             	add    $0x10,%esp
	return r;
  800e14:	eb d5                	jmp    800deb <nsipc_accept+0x2b>

00800e16 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e16:	f3 0f 1e fb          	endbr32 
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 08             	sub    $0x8,%esp
  800e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e2c:	53                   	push   %ebx
  800e2d:	ff 75 0c             	pushl  0xc(%ebp)
  800e30:	68 04 60 80 00       	push   $0x806004
  800e35:	e8 a9 0f 00 00       	call   801de3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e3a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e40:	b8 02 00 00 00       	mov    $0x2,%eax
  800e45:	e8 2a ff ff ff       	call   800d74 <nsipc>
}
  800e4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4d:	c9                   	leave  
  800e4e:	c3                   	ret    

00800e4f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e4f:	f3 0f 1e fb          	endbr32 
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e64:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e69:	b8 03 00 00 00       	mov    $0x3,%eax
  800e6e:	e8 01 ff ff ff       	call   800d74 <nsipc>
}
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <nsipc_close>:

int
nsipc_close(int s)
{
  800e75:	f3 0f 1e fb          	endbr32 
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e87:	b8 04 00 00 00       	mov    $0x4,%eax
  800e8c:	e8 e3 fe ff ff       	call   800d74 <nsipc>
}
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e93:	f3 0f 1e fb          	endbr32 
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ea9:	53                   	push   %ebx
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	68 04 60 80 00       	push   $0x806004
  800eb2:	e8 2c 0f 00 00       	call   801de3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eb7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ebd:	b8 05 00 00 00       	mov    $0x5,%eax
  800ec2:	e8 ad fe ff ff       	call   800d74 <nsipc>
}
  800ec7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ecc:	f3 0f 1e fb          	endbr32 
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ee6:	b8 06 00 00 00       	mov    $0x6,%eax
  800eeb:	e8 84 fe ff ff       	call   800d74 <nsipc>
}
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800ef2:	f3 0f 1e fb          	endbr32 
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f06:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f14:	b8 07 00 00 00       	mov    $0x7,%eax
  800f19:	e8 56 fe ff ff       	call   800d74 <nsipc>
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 26                	js     800f4a <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f24:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f2a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f2f:	0f 4e c6             	cmovle %esi,%eax
  800f32:	39 c3                	cmp    %eax,%ebx
  800f34:	7f 1d                	jg     800f53 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	53                   	push   %ebx
  800f3a:	68 00 60 80 00       	push   $0x806000
  800f3f:	ff 75 0c             	pushl  0xc(%ebp)
  800f42:	e8 9c 0e 00 00       	call   801de3 <memmove>
  800f47:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f4a:	89 d8                	mov    %ebx,%eax
  800f4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5e                   	pop    %esi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f53:	68 9b 24 80 00       	push   $0x80249b
  800f58:	68 03 24 80 00       	push   $0x802403
  800f5d:	6a 62                	push   $0x62
  800f5f:	68 b0 24 80 00       	push   $0x8024b0
  800f64:	e8 8b 05 00 00       	call   8014f4 <_panic>

00800f69 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f69:	f3 0f 1e fb          	endbr32 
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	53                   	push   %ebx
  800f71:	83 ec 04             	sub    $0x4,%esp
  800f74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f7f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f85:	7f 2e                	jg     800fb5 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	53                   	push   %ebx
  800f8b:	ff 75 0c             	pushl  0xc(%ebp)
  800f8e:	68 0c 60 80 00       	push   $0x80600c
  800f93:	e8 4b 0e 00 00       	call   801de3 <memmove>
	nsipcbuf.send.req_size = size;
  800f98:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800f9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fa6:	b8 08 00 00 00       	mov    $0x8,%eax
  800fab:	e8 c4 fd ff ff       	call   800d74 <nsipc>
}
  800fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    
	assert(size < 1600);
  800fb5:	68 bc 24 80 00       	push   $0x8024bc
  800fba:	68 03 24 80 00       	push   $0x802403
  800fbf:	6a 6d                	push   $0x6d
  800fc1:	68 b0 24 80 00       	push   $0x8024b0
  800fc6:	e8 29 05 00 00       	call   8014f4 <_panic>

00800fcb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fcb:	f3 0f 1e fb          	endbr32 
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe5:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fed:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff2:	e8 7d fd ff ff       	call   800d74 <nsipc>
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff9:	f3 0f 1e fb          	endbr32 
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	ff 75 08             	pushl  0x8(%ebp)
  80100b:	e8 f0 f2 ff ff       	call   800300 <fd2data>
  801010:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801012:	83 c4 08             	add    $0x8,%esp
  801015:	68 c8 24 80 00       	push   $0x8024c8
  80101a:	53                   	push   %ebx
  80101b:	e8 c5 0b 00 00       	call   801be5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801020:	8b 46 04             	mov    0x4(%esi),%eax
  801023:	2b 06                	sub    (%esi),%eax
  801025:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801032:	00 00 00 
	stat->st_dev = &devpipe;
  801035:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  80103c:	30 80 00 
	return 0;
}
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
  801044:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104b:	f3 0f 1e fb          	endbr32 
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801059:	53                   	push   %ebx
  80105a:	6a 00                	push   $0x0
  80105c:	e8 3f f1 ff ff       	call   8001a0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801061:	89 1c 24             	mov    %ebx,(%esp)
  801064:	e8 97 f2 ff ff       	call   800300 <fd2data>
  801069:	83 c4 08             	add    $0x8,%esp
  80106c:	50                   	push   %eax
  80106d:	6a 00                	push   $0x0
  80106f:	e8 2c f1 ff ff       	call   8001a0 <sys_page_unmap>
}
  801074:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <_pipeisclosed>:
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 1c             	sub    $0x1c,%esp
  801082:	89 c7                	mov    %eax,%edi
  801084:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801086:	a1 08 40 80 00       	mov    0x804008,%eax
  80108b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	57                   	push   %edi
  801092:	e8 0a 10 00 00       	call   8020a1 <pageref>
  801097:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80109a:	89 34 24             	mov    %esi,(%esp)
  80109d:	e8 ff 0f 00 00       	call   8020a1 <pageref>
		nn = thisenv->env_runs;
  8010a2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010a8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	39 cb                	cmp    %ecx,%ebx
  8010b0:	74 1b                	je     8010cd <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010b2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010b5:	75 cf                	jne    801086 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b7:	8b 42 58             	mov    0x58(%edx),%eax
  8010ba:	6a 01                	push   $0x1
  8010bc:	50                   	push   %eax
  8010bd:	53                   	push   %ebx
  8010be:	68 cf 24 80 00       	push   $0x8024cf
  8010c3:	e8 13 05 00 00       	call   8015db <cprintf>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	eb b9                	jmp    801086 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010cd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010d0:	0f 94 c0             	sete   %al
  8010d3:	0f b6 c0             	movzbl %al,%eax
}
  8010d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5e                   	pop    %esi
  8010db:	5f                   	pop    %edi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <devpipe_write>:
{
  8010de:	f3 0f 1e fb          	endbr32 
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 28             	sub    $0x28,%esp
  8010eb:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010ee:	56                   	push   %esi
  8010ef:	e8 0c f2 ff ff       	call   800300 <fd2data>
  8010f4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8010fe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801101:	74 4f                	je     801152 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801103:	8b 43 04             	mov    0x4(%ebx),%eax
  801106:	8b 0b                	mov    (%ebx),%ecx
  801108:	8d 51 20             	lea    0x20(%ecx),%edx
  80110b:	39 d0                	cmp    %edx,%eax
  80110d:	72 14                	jb     801123 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80110f:	89 da                	mov    %ebx,%edx
  801111:	89 f0                	mov    %esi,%eax
  801113:	e8 61 ff ff ff       	call   801079 <_pipeisclosed>
  801118:	85 c0                	test   %eax,%eax
  80111a:	75 3b                	jne    801157 <devpipe_write+0x79>
			sys_yield();
  80111c:	e8 11 f0 ff ff       	call   800132 <sys_yield>
  801121:	eb e0                	jmp    801103 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801123:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801126:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	c1 fa 1f             	sar    $0x1f,%edx
  801132:	89 d1                	mov    %edx,%ecx
  801134:	c1 e9 1b             	shr    $0x1b,%ecx
  801137:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113a:	83 e2 1f             	and    $0x1f,%edx
  80113d:	29 ca                	sub    %ecx,%edx
  80113f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801143:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801147:	83 c0 01             	add    $0x1,%eax
  80114a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80114d:	83 c7 01             	add    $0x1,%edi
  801150:	eb ac                	jmp    8010fe <devpipe_write+0x20>
	return i;
  801152:	8b 45 10             	mov    0x10(%ebp),%eax
  801155:	eb 05                	jmp    80115c <devpipe_write+0x7e>
				return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <devpipe_read>:
{
  801164:	f3 0f 1e fb          	endbr32 
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 18             	sub    $0x18,%esp
  801171:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801174:	57                   	push   %edi
  801175:	e8 86 f1 ff ff       	call   800300 <fd2data>
  80117a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	be 00 00 00 00       	mov    $0x0,%esi
  801184:	3b 75 10             	cmp    0x10(%ebp),%esi
  801187:	75 14                	jne    80119d <devpipe_read+0x39>
	return i;
  801189:	8b 45 10             	mov    0x10(%ebp),%eax
  80118c:	eb 02                	jmp    801190 <devpipe_read+0x2c>
				return i;
  80118e:	89 f0                	mov    %esi,%eax
}
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
			sys_yield();
  801198:	e8 95 ef ff ff       	call   800132 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80119d:	8b 03                	mov    (%ebx),%eax
  80119f:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011a2:	75 18                	jne    8011bc <devpipe_read+0x58>
			if (i > 0)
  8011a4:	85 f6                	test   %esi,%esi
  8011a6:	75 e6                	jne    80118e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011a8:	89 da                	mov    %ebx,%edx
  8011aa:	89 f8                	mov    %edi,%eax
  8011ac:	e8 c8 fe ff ff       	call   801079 <_pipeisclosed>
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	74 e3                	je     801198 <devpipe_read+0x34>
				return 0;
  8011b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ba:	eb d4                	jmp    801190 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011bc:	99                   	cltd   
  8011bd:	c1 ea 1b             	shr    $0x1b,%edx
  8011c0:	01 d0                	add    %edx,%eax
  8011c2:	83 e0 1f             	and    $0x1f,%eax
  8011c5:	29 d0                	sub    %edx,%eax
  8011c7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011d2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d5:	83 c6 01             	add    $0x1,%esi
  8011d8:	eb aa                	jmp    801184 <devpipe_read+0x20>

008011da <pipe>:
{
  8011da:	f3 0f 1e fb          	endbr32 
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	e8 2c f1 ff ff       	call   80031b <fd_alloc>
  8011ef:	89 c3                	mov    %eax,%ebx
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	0f 88 23 01 00 00    	js     80131f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	68 07 04 00 00       	push   $0x407
  801204:	ff 75 f4             	pushl  -0xc(%ebp)
  801207:	6a 00                	push   $0x0
  801209:	e8 47 ef ff ff       	call   800155 <sys_page_alloc>
  80120e:	89 c3                	mov    %eax,%ebx
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	0f 88 04 01 00 00    	js     80131f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80121b:	83 ec 0c             	sub    $0xc,%esp
  80121e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	e8 f4 f0 ff ff       	call   80031b <fd_alloc>
  801227:	89 c3                	mov    %eax,%ebx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	0f 88 db 00 00 00    	js     80130f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	68 07 04 00 00       	push   $0x407
  80123c:	ff 75 f0             	pushl  -0x10(%ebp)
  80123f:	6a 00                	push   $0x0
  801241:	e8 0f ef ff ff       	call   800155 <sys_page_alloc>
  801246:	89 c3                	mov    %eax,%ebx
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	0f 88 bc 00 00 00    	js     80130f <pipe+0x135>
	va = fd2data(fd0);
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	ff 75 f4             	pushl  -0xc(%ebp)
  801259:	e8 a2 f0 ff ff       	call   800300 <fd2data>
  80125e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801260:	83 c4 0c             	add    $0xc,%esp
  801263:	68 07 04 00 00       	push   $0x407
  801268:	50                   	push   %eax
  801269:	6a 00                	push   $0x0
  80126b:	e8 e5 ee ff ff       	call   800155 <sys_page_alloc>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	0f 88 82 00 00 00    	js     8012ff <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	ff 75 f0             	pushl  -0x10(%ebp)
  801283:	e8 78 f0 ff ff       	call   800300 <fd2data>
  801288:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128f:	50                   	push   %eax
  801290:	6a 00                	push   $0x0
  801292:	56                   	push   %esi
  801293:	6a 00                	push   $0x0
  801295:	e8 e1 ee ff ff       	call   80017b <sys_page_map>
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 20             	add    $0x20,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 4e                	js     8012f1 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8012a3:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b0:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ba:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cc:	e8 1b f0 ff ff       	call   8002ec <fd2num>
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d6:	83 c4 04             	add    $0x4,%esp
  8012d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012dc:	e8 0b f0 ff ff       	call   8002ec <fd2num>
  8012e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ef:	eb 2e                	jmp    80131f <pipe+0x145>
	sys_page_unmap(0, va);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	56                   	push   %esi
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 a4 ee ff ff       	call   8001a0 <sys_page_unmap>
  8012fc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	ff 75 f0             	pushl  -0x10(%ebp)
  801305:	6a 00                	push   $0x0
  801307:	e8 94 ee ff ff       	call   8001a0 <sys_page_unmap>
  80130c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	ff 75 f4             	pushl  -0xc(%ebp)
  801315:	6a 00                	push   $0x0
  801317:	e8 84 ee ff ff       	call   8001a0 <sys_page_unmap>
  80131c:	83 c4 10             	add    $0x10,%esp
}
  80131f:	89 d8                	mov    %ebx,%eax
  801321:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <pipeisclosed>:
{
  801328:	f3 0f 1e fb          	endbr32 
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 75 08             	pushl  0x8(%ebp)
  801339:	e8 33 f0 ff ff       	call   800371 <fd_lookup>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 18                	js     80135d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	ff 75 f4             	pushl  -0xc(%ebp)
  80134b:	e8 b0 ef ff ff       	call   800300 <fd2data>
  801350:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801355:	e8 1f fd ff ff       	call   801079 <_pipeisclosed>
  80135a:	83 c4 10             	add    $0x10,%esp
}
  80135d:	c9                   	leave  
  80135e:	c3                   	ret    

0080135f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80135f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	c3                   	ret    

00801369 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801369:	f3 0f 1e fb          	endbr32 
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801373:	68 e7 24 80 00       	push   $0x8024e7
  801378:	ff 75 0c             	pushl  0xc(%ebp)
  80137b:	e8 65 08 00 00       	call   801be5 <strcpy>
	return 0;
}
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <devcons_write>:
{
  801387:	f3 0f 1e fb          	endbr32 
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	57                   	push   %edi
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801397:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80139c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013a2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a5:	73 31                	jae    8013d8 <devcons_write+0x51>
		m = n - tot;
  8013a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013aa:	29 f3                	sub    %esi,%ebx
  8013ac:	83 fb 7f             	cmp    $0x7f,%ebx
  8013af:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013b4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	89 f0                	mov    %esi,%eax
  8013bd:	03 45 0c             	add    0xc(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	57                   	push   %edi
  8013c2:	e8 1c 0a 00 00       	call   801de3 <memmove>
		sys_cputs(buf, m);
  8013c7:	83 c4 08             	add    $0x8,%esp
  8013ca:	53                   	push   %ebx
  8013cb:	57                   	push   %edi
  8013cc:	e8 d5 ec ff ff       	call   8000a6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013d1:	01 de                	add    %ebx,%esi
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	eb ca                	jmp    8013a2 <devcons_write+0x1b>
}
  8013d8:	89 f0                	mov    %esi,%eax
  8013da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013dd:	5b                   	pop    %ebx
  8013de:	5e                   	pop    %esi
  8013df:	5f                   	pop    %edi
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <devcons_read>:
{
  8013e2:	f3 0f 1e fb          	endbr32 
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f5:	74 21                	je     801418 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8013f7:	e8 cc ec ff ff       	call   8000c8 <sys_cgetc>
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	75 07                	jne    801407 <devcons_read+0x25>
		sys_yield();
  801400:	e8 2d ed ff ff       	call   800132 <sys_yield>
  801405:	eb f0                	jmp    8013f7 <devcons_read+0x15>
	if (c < 0)
  801407:	78 0f                	js     801418 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801409:	83 f8 04             	cmp    $0x4,%eax
  80140c:	74 0c                	je     80141a <devcons_read+0x38>
	*(char*)vbuf = c;
  80140e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801411:	88 02                	mov    %al,(%edx)
	return 1;
  801413:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    
		return 0;
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
  80141f:	eb f7                	jmp    801418 <devcons_read+0x36>

00801421 <cputchar>:
{
  801421:	f3 0f 1e fb          	endbr32 
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80142b:	8b 45 08             	mov    0x8(%ebp),%eax
  80142e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801431:	6a 01                	push   $0x1
  801433:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	e8 6a ec ff ff       	call   8000a6 <sys_cputs>
}
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <getchar>:
{
  801441:	f3 0f 1e fb          	endbr32 
  801445:	55                   	push   %ebp
  801446:	89 e5                	mov    %esp,%ebp
  801448:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80144b:	6a 01                	push   $0x1
  80144d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	6a 00                	push   $0x0
  801453:	e8 a1 f1 ff ff       	call   8005f9 <read>
	if (r < 0)
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 06                	js     801465 <getchar+0x24>
	if (r < 1)
  80145f:	74 06                	je     801467 <getchar+0x26>
	return c;
  801461:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801465:	c9                   	leave  
  801466:	c3                   	ret    
		return -E_EOF;
  801467:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80146c:	eb f7                	jmp    801465 <getchar+0x24>

0080146e <iscons>:
{
  80146e:	f3 0f 1e fb          	endbr32 
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	ff 75 08             	pushl  0x8(%ebp)
  80147f:	e8 ed ee ff ff       	call   800371 <fd_lookup>
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 11                	js     80149c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80148b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148e:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801494:	39 10                	cmp    %edx,(%eax)
  801496:	0f 94 c0             	sete   %al
  801499:	0f b6 c0             	movzbl %al,%eax
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <opencons>:
{
  80149e:	f3 0f 1e fb          	endbr32 
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	e8 6a ee ff ff       	call   80031b <fd_alloc>
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 3a                	js     8014f2 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	68 07 04 00 00       	push   $0x407
  8014c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c3:	6a 00                	push   $0x0
  8014c5:	e8 8b ec ff ff       	call   800155 <sys_page_alloc>
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 21                	js     8014f2 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d4:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014da:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014df:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e6:	83 ec 0c             	sub    $0xc,%esp
  8014e9:	50                   	push   %eax
  8014ea:	e8 fd ed ff ff       	call   8002ec <fd2num>
  8014ef:	83 c4 10             	add    $0x10,%esp
}
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f4:	f3 0f 1e fb          	endbr32 
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	56                   	push   %esi
  8014fc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014fd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801500:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801506:	e8 04 ec ff ff       	call   80010f <sys_getenvid>
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	ff 75 0c             	pushl  0xc(%ebp)
  801511:	ff 75 08             	pushl  0x8(%ebp)
  801514:	56                   	push   %esi
  801515:	50                   	push   %eax
  801516:	68 f4 24 80 00       	push   $0x8024f4
  80151b:	e8 bb 00 00 00       	call   8015db <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801520:	83 c4 18             	add    $0x18,%esp
  801523:	53                   	push   %ebx
  801524:	ff 75 10             	pushl  0x10(%ebp)
  801527:	e8 5a 00 00 00       	call   801586 <vcprintf>
	cprintf("\n");
  80152c:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  801533:	e8 a3 00 00 00       	call   8015db <cprintf>
  801538:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80153b:	cc                   	int3   
  80153c:	eb fd                	jmp    80153b <_panic+0x47>

0080153e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153e:	f3 0f 1e fb          	endbr32 
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	53                   	push   %ebx
  801546:	83 ec 04             	sub    $0x4,%esp
  801549:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80154c:	8b 13                	mov    (%ebx),%edx
  80154e:	8d 42 01             	lea    0x1(%edx),%eax
  801551:	89 03                	mov    %eax,(%ebx)
  801553:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801556:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80155a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80155f:	74 09                	je     80156a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801561:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	68 ff 00 00 00       	push   $0xff
  801572:	8d 43 08             	lea    0x8(%ebx),%eax
  801575:	50                   	push   %eax
  801576:	e8 2b eb ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  80157b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	eb db                	jmp    801561 <putch+0x23>

00801586 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801586:	f3 0f 1e fb          	endbr32 
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801593:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80159a:	00 00 00 
	b.cnt = 0;
  80159d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a7:	ff 75 0c             	pushl  0xc(%ebp)
  8015aa:	ff 75 08             	pushl  0x8(%ebp)
  8015ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	68 3e 15 80 00       	push   $0x80153e
  8015b9:	e8 20 01 00 00       	call   8016de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015be:	83 c4 08             	add    $0x8,%esp
  8015c1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	e8 d3 ea ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8015d3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015db:	f3 0f 1e fb          	endbr32 
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015e8:	50                   	push   %eax
  8015e9:	ff 75 08             	pushl  0x8(%ebp)
  8015ec:	e8 95 ff ff ff       	call   801586 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	57                   	push   %edi
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 1c             	sub    $0x1c,%esp
  8015fc:	89 c7                	mov    %eax,%edi
  8015fe:	89 d6                	mov    %edx,%esi
  801600:	8b 45 08             	mov    0x8(%ebp),%eax
  801603:	8b 55 0c             	mov    0xc(%ebp),%edx
  801606:	89 d1                	mov    %edx,%ecx
  801608:	89 c2                	mov    %eax,%edx
  80160a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80160d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801610:	8b 45 10             	mov    0x10(%ebp),%eax
  801613:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801616:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801619:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801620:	39 c2                	cmp    %eax,%edx
  801622:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801625:	72 3e                	jb     801665 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801627:	83 ec 0c             	sub    $0xc,%esp
  80162a:	ff 75 18             	pushl  0x18(%ebp)
  80162d:	83 eb 01             	sub    $0x1,%ebx
  801630:	53                   	push   %ebx
  801631:	50                   	push   %eax
  801632:	83 ec 08             	sub    $0x8,%esp
  801635:	ff 75 e4             	pushl  -0x1c(%ebp)
  801638:	ff 75 e0             	pushl  -0x20(%ebp)
  80163b:	ff 75 dc             	pushl  -0x24(%ebp)
  80163e:	ff 75 d8             	pushl  -0x28(%ebp)
  801641:	e8 aa 0a 00 00       	call   8020f0 <__udivdi3>
  801646:	83 c4 18             	add    $0x18,%esp
  801649:	52                   	push   %edx
  80164a:	50                   	push   %eax
  80164b:	89 f2                	mov    %esi,%edx
  80164d:	89 f8                	mov    %edi,%eax
  80164f:	e8 9f ff ff ff       	call   8015f3 <printnum>
  801654:	83 c4 20             	add    $0x20,%esp
  801657:	eb 13                	jmp    80166c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	56                   	push   %esi
  80165d:	ff 75 18             	pushl  0x18(%ebp)
  801660:	ff d7                	call   *%edi
  801662:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801665:	83 eb 01             	sub    $0x1,%ebx
  801668:	85 db                	test   %ebx,%ebx
  80166a:	7f ed                	jg     801659 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	56                   	push   %esi
  801670:	83 ec 04             	sub    $0x4,%esp
  801673:	ff 75 e4             	pushl  -0x1c(%ebp)
  801676:	ff 75 e0             	pushl  -0x20(%ebp)
  801679:	ff 75 dc             	pushl  -0x24(%ebp)
  80167c:	ff 75 d8             	pushl  -0x28(%ebp)
  80167f:	e8 7c 0b 00 00       	call   802200 <__umoddi3>
  801684:	83 c4 14             	add    $0x14,%esp
  801687:	0f be 80 17 25 80 00 	movsbl 0x802517(%eax),%eax
  80168e:	50                   	push   %eax
  80168f:	ff d7                	call   *%edi
}
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801697:	5b                   	pop    %ebx
  801698:	5e                   	pop    %esi
  801699:	5f                   	pop    %edi
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80169c:	f3 0f 1e fb          	endbr32 
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016aa:	8b 10                	mov    (%eax),%edx
  8016ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8016af:	73 0a                	jae    8016bb <sprintputch+0x1f>
		*b->buf++ = ch;
  8016b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016b4:	89 08                	mov    %ecx,(%eax)
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	88 02                	mov    %al,(%edx)
}
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <printfmt>:
{
  8016bd:	f3 0f 1e fb          	endbr32 
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ca:	50                   	push   %eax
  8016cb:	ff 75 10             	pushl  0x10(%ebp)
  8016ce:	ff 75 0c             	pushl  0xc(%ebp)
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 05 00 00 00       	call   8016de <vprintfmt>
}
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <vprintfmt>:
{
  8016de:	f3 0f 1e fb          	endbr32 
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	57                   	push   %edi
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 3c             	sub    $0x3c,%esp
  8016eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016f1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016f4:	e9 8e 03 00 00       	jmp    801a87 <vprintfmt+0x3a9>
		padc = ' ';
  8016f9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016fd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801704:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80170b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801712:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801717:	8d 47 01             	lea    0x1(%edi),%eax
  80171a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80171d:	0f b6 17             	movzbl (%edi),%edx
  801720:	8d 42 dd             	lea    -0x23(%edx),%eax
  801723:	3c 55                	cmp    $0x55,%al
  801725:	0f 87 df 03 00 00    	ja     801b0a <vprintfmt+0x42c>
  80172b:	0f b6 c0             	movzbl %al,%eax
  80172e:	3e ff 24 85 60 26 80 	notrack jmp *0x802660(,%eax,4)
  801735:	00 
  801736:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801739:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80173d:	eb d8                	jmp    801717 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80173f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801742:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801746:	eb cf                	jmp    801717 <vprintfmt+0x39>
  801748:	0f b6 d2             	movzbl %dl,%edx
  80174b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80174e:	b8 00 00 00 00       	mov    $0x0,%eax
  801753:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801756:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801759:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80175d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801760:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801763:	83 f9 09             	cmp    $0x9,%ecx
  801766:	77 55                	ja     8017bd <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801768:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80176b:	eb e9                	jmp    801756 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80176d:	8b 45 14             	mov    0x14(%ebp),%eax
  801770:	8b 00                	mov    (%eax),%eax
  801772:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801775:	8b 45 14             	mov    0x14(%ebp),%eax
  801778:	8d 40 04             	lea    0x4(%eax),%eax
  80177b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80177e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801781:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801785:	79 90                	jns    801717 <vprintfmt+0x39>
				width = precision, precision = -1;
  801787:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80178a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80178d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801794:	eb 81                	jmp    801717 <vprintfmt+0x39>
  801796:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801799:	85 c0                	test   %eax,%eax
  80179b:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a0:	0f 49 d0             	cmovns %eax,%edx
  8017a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017a9:	e9 69 ff ff ff       	jmp    801717 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017b1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017b8:	e9 5a ff ff ff       	jmp    801717 <vprintfmt+0x39>
  8017bd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017c3:	eb bc                	jmp    801781 <vprintfmt+0xa3>
			lflag++;
  8017c5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017cb:	e9 47 ff ff ff       	jmp    801717 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d3:	8d 78 04             	lea    0x4(%eax),%edi
  8017d6:	83 ec 08             	sub    $0x8,%esp
  8017d9:	53                   	push   %ebx
  8017da:	ff 30                	pushl  (%eax)
  8017dc:	ff d6                	call   *%esi
			break;
  8017de:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017e1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017e4:	e9 9b 02 00 00       	jmp    801a84 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8017e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ec:	8d 78 04             	lea    0x4(%eax),%edi
  8017ef:	8b 00                	mov    (%eax),%eax
  8017f1:	99                   	cltd   
  8017f2:	31 d0                	xor    %edx,%eax
  8017f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f6:	83 f8 0f             	cmp    $0xf,%eax
  8017f9:	7f 23                	jg     80181e <vprintfmt+0x140>
  8017fb:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  801802:	85 d2                	test   %edx,%edx
  801804:	74 18                	je     80181e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801806:	52                   	push   %edx
  801807:	68 15 24 80 00       	push   $0x802415
  80180c:	53                   	push   %ebx
  80180d:	56                   	push   %esi
  80180e:	e8 aa fe ff ff       	call   8016bd <printfmt>
  801813:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801816:	89 7d 14             	mov    %edi,0x14(%ebp)
  801819:	e9 66 02 00 00       	jmp    801a84 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80181e:	50                   	push   %eax
  80181f:	68 2f 25 80 00       	push   $0x80252f
  801824:	53                   	push   %ebx
  801825:	56                   	push   %esi
  801826:	e8 92 fe ff ff       	call   8016bd <printfmt>
  80182b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80182e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801831:	e9 4e 02 00 00       	jmp    801a84 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801836:	8b 45 14             	mov    0x14(%ebp),%eax
  801839:	83 c0 04             	add    $0x4,%eax
  80183c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80183f:	8b 45 14             	mov    0x14(%ebp),%eax
  801842:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801844:	85 d2                	test   %edx,%edx
  801846:	b8 28 25 80 00       	mov    $0x802528,%eax
  80184b:	0f 45 c2             	cmovne %edx,%eax
  80184e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801851:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801855:	7e 06                	jle    80185d <vprintfmt+0x17f>
  801857:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80185b:	75 0d                	jne    80186a <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80185d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801860:	89 c7                	mov    %eax,%edi
  801862:	03 45 e0             	add    -0x20(%ebp),%eax
  801865:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801868:	eb 55                	jmp    8018bf <vprintfmt+0x1e1>
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	ff 75 d8             	pushl  -0x28(%ebp)
  801870:	ff 75 cc             	pushl  -0x34(%ebp)
  801873:	e8 46 03 00 00       	call   801bbe <strnlen>
  801878:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80187b:	29 c2                	sub    %eax,%edx
  80187d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801885:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801889:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80188c:	85 ff                	test   %edi,%edi
  80188e:	7e 11                	jle    8018a1 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	53                   	push   %ebx
  801894:	ff 75 e0             	pushl  -0x20(%ebp)
  801897:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801899:	83 ef 01             	sub    $0x1,%edi
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	eb eb                	jmp    80188c <vprintfmt+0x1ae>
  8018a1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018a4:	85 d2                	test   %edx,%edx
  8018a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ab:	0f 49 c2             	cmovns %edx,%eax
  8018ae:	29 c2                	sub    %eax,%edx
  8018b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018b3:	eb a8                	jmp    80185d <vprintfmt+0x17f>
					putch(ch, putdat);
  8018b5:	83 ec 08             	sub    $0x8,%esp
  8018b8:	53                   	push   %ebx
  8018b9:	52                   	push   %edx
  8018ba:	ff d6                	call   *%esi
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018c2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018c4:	83 c7 01             	add    $0x1,%edi
  8018c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018cb:	0f be d0             	movsbl %al,%edx
  8018ce:	85 d2                	test   %edx,%edx
  8018d0:	74 4b                	je     80191d <vprintfmt+0x23f>
  8018d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018d6:	78 06                	js     8018de <vprintfmt+0x200>
  8018d8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018dc:	78 1e                	js     8018fc <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8018de:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018e2:	74 d1                	je     8018b5 <vprintfmt+0x1d7>
  8018e4:	0f be c0             	movsbl %al,%eax
  8018e7:	83 e8 20             	sub    $0x20,%eax
  8018ea:	83 f8 5e             	cmp    $0x5e,%eax
  8018ed:	76 c6                	jbe    8018b5 <vprintfmt+0x1d7>
					putch('?', putdat);
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	53                   	push   %ebx
  8018f3:	6a 3f                	push   $0x3f
  8018f5:	ff d6                	call   *%esi
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	eb c3                	jmp    8018bf <vprintfmt+0x1e1>
  8018fc:	89 cf                	mov    %ecx,%edi
  8018fe:	eb 0e                	jmp    80190e <vprintfmt+0x230>
				putch(' ', putdat);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	53                   	push   %ebx
  801904:	6a 20                	push   $0x20
  801906:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801908:	83 ef 01             	sub    $0x1,%edi
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	85 ff                	test   %edi,%edi
  801910:	7f ee                	jg     801900 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801912:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801915:	89 45 14             	mov    %eax,0x14(%ebp)
  801918:	e9 67 01 00 00       	jmp    801a84 <vprintfmt+0x3a6>
  80191d:	89 cf                	mov    %ecx,%edi
  80191f:	eb ed                	jmp    80190e <vprintfmt+0x230>
	if (lflag >= 2)
  801921:	83 f9 01             	cmp    $0x1,%ecx
  801924:	7f 1b                	jg     801941 <vprintfmt+0x263>
	else if (lflag)
  801926:	85 c9                	test   %ecx,%ecx
  801928:	74 63                	je     80198d <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80192a:	8b 45 14             	mov    0x14(%ebp),%eax
  80192d:	8b 00                	mov    (%eax),%eax
  80192f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801932:	99                   	cltd   
  801933:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801936:	8b 45 14             	mov    0x14(%ebp),%eax
  801939:	8d 40 04             	lea    0x4(%eax),%eax
  80193c:	89 45 14             	mov    %eax,0x14(%ebp)
  80193f:	eb 17                	jmp    801958 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801941:	8b 45 14             	mov    0x14(%ebp),%eax
  801944:	8b 50 04             	mov    0x4(%eax),%edx
  801947:	8b 00                	mov    (%eax),%eax
  801949:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80194c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80194f:	8b 45 14             	mov    0x14(%ebp),%eax
  801952:	8d 40 08             	lea    0x8(%eax),%eax
  801955:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801958:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80195b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80195e:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801963:	85 c9                	test   %ecx,%ecx
  801965:	0f 89 ff 00 00 00    	jns    801a6a <vprintfmt+0x38c>
				putch('-', putdat);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	53                   	push   %ebx
  80196f:	6a 2d                	push   $0x2d
  801971:	ff d6                	call   *%esi
				num = -(long long) num;
  801973:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801976:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801979:	f7 da                	neg    %edx
  80197b:	83 d1 00             	adc    $0x0,%ecx
  80197e:	f7 d9                	neg    %ecx
  801980:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801983:	b8 0a 00 00 00       	mov    $0xa,%eax
  801988:	e9 dd 00 00 00       	jmp    801a6a <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8b 00                	mov    (%eax),%eax
  801992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801995:	99                   	cltd   
  801996:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801999:	8b 45 14             	mov    0x14(%ebp),%eax
  80199c:	8d 40 04             	lea    0x4(%eax),%eax
  80199f:	89 45 14             	mov    %eax,0x14(%ebp)
  8019a2:	eb b4                	jmp    801958 <vprintfmt+0x27a>
	if (lflag >= 2)
  8019a4:	83 f9 01             	cmp    $0x1,%ecx
  8019a7:	7f 1e                	jg     8019c7 <vprintfmt+0x2e9>
	else if (lflag)
  8019a9:	85 c9                	test   %ecx,%ecx
  8019ab:	74 32                	je     8019df <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b0:	8b 10                	mov    (%eax),%edx
  8019b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019b7:	8d 40 04             	lea    0x4(%eax),%eax
  8019ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019bd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019c2:	e9 a3 00 00 00       	jmp    801a6a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ca:	8b 10                	mov    (%eax),%edx
  8019cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8019cf:	8d 40 08             	lea    0x8(%eax),%eax
  8019d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019d5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8019da:	e9 8b 00 00 00       	jmp    801a6a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8019df:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e2:	8b 10                	mov    (%eax),%edx
  8019e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e9:	8d 40 04             	lea    0x4(%eax),%eax
  8019ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019ef:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8019f4:	eb 74                	jmp    801a6a <vprintfmt+0x38c>
	if (lflag >= 2)
  8019f6:	83 f9 01             	cmp    $0x1,%ecx
  8019f9:	7f 1b                	jg     801a16 <vprintfmt+0x338>
	else if (lflag)
  8019fb:	85 c9                	test   %ecx,%ecx
  8019fd:	74 2c                	je     801a2b <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8019ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801a02:	8b 10                	mov    (%eax),%edx
  801a04:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a09:	8d 40 04             	lea    0x4(%eax),%eax
  801a0c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a0f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a14:	eb 54                	jmp    801a6a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a16:	8b 45 14             	mov    0x14(%ebp),%eax
  801a19:	8b 10                	mov    (%eax),%edx
  801a1b:	8b 48 04             	mov    0x4(%eax),%ecx
  801a1e:	8d 40 08             	lea    0x8(%eax),%eax
  801a21:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a24:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a29:	eb 3f                	jmp    801a6a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2e:	8b 10                	mov    (%eax),%edx
  801a30:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a35:	8d 40 04             	lea    0x4(%eax),%eax
  801a38:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a3b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a40:	eb 28                	jmp    801a6a <vprintfmt+0x38c>
			putch('0', putdat);
  801a42:	83 ec 08             	sub    $0x8,%esp
  801a45:	53                   	push   %ebx
  801a46:	6a 30                	push   $0x30
  801a48:	ff d6                	call   *%esi
			putch('x', putdat);
  801a4a:	83 c4 08             	add    $0x8,%esp
  801a4d:	53                   	push   %ebx
  801a4e:	6a 78                	push   $0x78
  801a50:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a52:	8b 45 14             	mov    0x14(%ebp),%eax
  801a55:	8b 10                	mov    (%eax),%edx
  801a57:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a5c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a5f:	8d 40 04             	lea    0x4(%eax),%eax
  801a62:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a65:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a71:	57                   	push   %edi
  801a72:	ff 75 e0             	pushl  -0x20(%ebp)
  801a75:	50                   	push   %eax
  801a76:	51                   	push   %ecx
  801a77:	52                   	push   %edx
  801a78:	89 da                	mov    %ebx,%edx
  801a7a:	89 f0                	mov    %esi,%eax
  801a7c:	e8 72 fb ff ff       	call   8015f3 <printnum>
			break;
  801a81:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801a84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801a87:	83 c7 01             	add    $0x1,%edi
  801a8a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a8e:	83 f8 25             	cmp    $0x25,%eax
  801a91:	0f 84 62 fc ff ff    	je     8016f9 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801a97:	85 c0                	test   %eax,%eax
  801a99:	0f 84 8b 00 00 00    	je     801b2a <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801a9f:	83 ec 08             	sub    $0x8,%esp
  801aa2:	53                   	push   %ebx
  801aa3:	50                   	push   %eax
  801aa4:	ff d6                	call   *%esi
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	eb dc                	jmp    801a87 <vprintfmt+0x3a9>
	if (lflag >= 2)
  801aab:	83 f9 01             	cmp    $0x1,%ecx
  801aae:	7f 1b                	jg     801acb <vprintfmt+0x3ed>
	else if (lflag)
  801ab0:	85 c9                	test   %ecx,%ecx
  801ab2:	74 2c                	je     801ae0 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab7:	8b 10                	mov    (%eax),%edx
  801ab9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801abe:	8d 40 04             	lea    0x4(%eax),%eax
  801ac1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ac4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801ac9:	eb 9f                	jmp    801a6a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801acb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ace:	8b 10                	mov    (%eax),%edx
  801ad0:	8b 48 04             	mov    0x4(%eax),%ecx
  801ad3:	8d 40 08             	lea    0x8(%eax),%eax
  801ad6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ad9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801ade:	eb 8a                	jmp    801a6a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801ae0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae3:	8b 10                	mov    (%eax),%edx
  801ae5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aea:	8d 40 04             	lea    0x4(%eax),%eax
  801aed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801af0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801af5:	e9 70 ff ff ff       	jmp    801a6a <vprintfmt+0x38c>
			putch(ch, putdat);
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	53                   	push   %ebx
  801afe:	6a 25                	push   $0x25
  801b00:	ff d6                	call   *%esi
			break;
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	e9 7a ff ff ff       	jmp    801a84 <vprintfmt+0x3a6>
			putch('%', putdat);
  801b0a:	83 ec 08             	sub    $0x8,%esp
  801b0d:	53                   	push   %ebx
  801b0e:	6a 25                	push   $0x25
  801b10:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	89 f8                	mov    %edi,%eax
  801b17:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b1b:	74 05                	je     801b22 <vprintfmt+0x444>
  801b1d:	83 e8 01             	sub    $0x1,%eax
  801b20:	eb f5                	jmp    801b17 <vprintfmt+0x439>
  801b22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b25:	e9 5a ff ff ff       	jmp    801a84 <vprintfmt+0x3a6>
}
  801b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5f                   	pop    %edi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b32:	f3 0f 1e fb          	endbr32 
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 18             	sub    $0x18,%esp
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b45:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b49:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b53:	85 c0                	test   %eax,%eax
  801b55:	74 26                	je     801b7d <vsnprintf+0x4b>
  801b57:	85 d2                	test   %edx,%edx
  801b59:	7e 22                	jle    801b7d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b5b:	ff 75 14             	pushl  0x14(%ebp)
  801b5e:	ff 75 10             	pushl  0x10(%ebp)
  801b61:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b64:	50                   	push   %eax
  801b65:	68 9c 16 80 00       	push   $0x80169c
  801b6a:	e8 6f fb ff ff       	call   8016de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b72:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b78:	83 c4 10             	add    $0x10,%esp
}
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    
		return -E_INVAL;
  801b7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b82:	eb f7                	jmp    801b7b <vsnprintf+0x49>

00801b84 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b84:	f3 0f 1e fb          	endbr32 
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801b8e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b91:	50                   	push   %eax
  801b92:	ff 75 10             	pushl  0x10(%ebp)
  801b95:	ff 75 0c             	pushl  0xc(%ebp)
  801b98:	ff 75 08             	pushl  0x8(%ebp)
  801b9b:	e8 92 ff ff ff       	call   801b32 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ba2:	f3 0f 1e fb          	endbr32 
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bb5:	74 05                	je     801bbc <strlen+0x1a>
		n++;
  801bb7:	83 c0 01             	add    $0x1,%eax
  801bba:	eb f5                	jmp    801bb1 <strlen+0xf>
	return n;
}
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bbe:	f3 0f 1e fb          	endbr32 
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd0:	39 d0                	cmp    %edx,%eax
  801bd2:	74 0d                	je     801be1 <strnlen+0x23>
  801bd4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801bd8:	74 05                	je     801bdf <strnlen+0x21>
		n++;
  801bda:	83 c0 01             	add    $0x1,%eax
  801bdd:	eb f1                	jmp    801bd0 <strnlen+0x12>
  801bdf:	89 c2                	mov    %eax,%edx
	return n;
}
  801be1:	89 d0                	mov    %edx,%eax
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801be5:	f3 0f 1e fb          	endbr32 
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	53                   	push   %ebx
  801bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801bfc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801bff:	83 c0 01             	add    $0x1,%eax
  801c02:	84 d2                	test   %dl,%dl
  801c04:	75 f2                	jne    801bf8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c06:	89 c8                	mov    %ecx,%eax
  801c08:	5b                   	pop    %ebx
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c0b:	f3 0f 1e fb          	endbr32 
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	53                   	push   %ebx
  801c13:	83 ec 10             	sub    $0x10,%esp
  801c16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c19:	53                   	push   %ebx
  801c1a:	e8 83 ff ff ff       	call   801ba2 <strlen>
  801c1f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c22:	ff 75 0c             	pushl  0xc(%ebp)
  801c25:	01 d8                	add    %ebx,%eax
  801c27:	50                   	push   %eax
  801c28:	e8 b8 ff ff ff       	call   801be5 <strcpy>
	return dst;
}
  801c2d:	89 d8                	mov    %ebx,%eax
  801c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c34:	f3 0f 1e fb          	endbr32 
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c40:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c43:	89 f3                	mov    %esi,%ebx
  801c45:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c48:	89 f0                	mov    %esi,%eax
  801c4a:	39 d8                	cmp    %ebx,%eax
  801c4c:	74 11                	je     801c5f <strncpy+0x2b>
		*dst++ = *src;
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	0f b6 0a             	movzbl (%edx),%ecx
  801c54:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c57:	80 f9 01             	cmp    $0x1,%cl
  801c5a:	83 da ff             	sbb    $0xffffffff,%edx
  801c5d:	eb eb                	jmp    801c4a <strncpy+0x16>
	}
	return ret;
}
  801c5f:	89 f0                	mov    %esi,%eax
  801c61:	5b                   	pop    %ebx
  801c62:	5e                   	pop    %esi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c65:	f3 0f 1e fb          	endbr32 
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c74:	8b 55 10             	mov    0x10(%ebp),%edx
  801c77:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c79:	85 d2                	test   %edx,%edx
  801c7b:	74 21                	je     801c9e <strlcpy+0x39>
  801c7d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c81:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801c83:	39 c2                	cmp    %eax,%edx
  801c85:	74 14                	je     801c9b <strlcpy+0x36>
  801c87:	0f b6 19             	movzbl (%ecx),%ebx
  801c8a:	84 db                	test   %bl,%bl
  801c8c:	74 0b                	je     801c99 <strlcpy+0x34>
			*dst++ = *src++;
  801c8e:	83 c1 01             	add    $0x1,%ecx
  801c91:	83 c2 01             	add    $0x1,%edx
  801c94:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c97:	eb ea                	jmp    801c83 <strlcpy+0x1e>
  801c99:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c9b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c9e:	29 f0                	sub    %esi,%eax
}
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ca4:	f3 0f 1e fb          	endbr32 
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cae:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cb1:	0f b6 01             	movzbl (%ecx),%eax
  801cb4:	84 c0                	test   %al,%al
  801cb6:	74 0c                	je     801cc4 <strcmp+0x20>
  801cb8:	3a 02                	cmp    (%edx),%al
  801cba:	75 08                	jne    801cc4 <strcmp+0x20>
		p++, q++;
  801cbc:	83 c1 01             	add    $0x1,%ecx
  801cbf:	83 c2 01             	add    $0x1,%edx
  801cc2:	eb ed                	jmp    801cb1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc4:	0f b6 c0             	movzbl %al,%eax
  801cc7:	0f b6 12             	movzbl (%edx),%edx
  801cca:	29 d0                	sub    %edx,%eax
}
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cce:	f3 0f 1e fb          	endbr32 
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	53                   	push   %ebx
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdc:	89 c3                	mov    %eax,%ebx
  801cde:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ce1:	eb 06                	jmp    801ce9 <strncmp+0x1b>
		n--, p++, q++;
  801ce3:	83 c0 01             	add    $0x1,%eax
  801ce6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801ce9:	39 d8                	cmp    %ebx,%eax
  801ceb:	74 16                	je     801d03 <strncmp+0x35>
  801ced:	0f b6 08             	movzbl (%eax),%ecx
  801cf0:	84 c9                	test   %cl,%cl
  801cf2:	74 04                	je     801cf8 <strncmp+0x2a>
  801cf4:	3a 0a                	cmp    (%edx),%cl
  801cf6:	74 eb                	je     801ce3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cf8:	0f b6 00             	movzbl (%eax),%eax
  801cfb:	0f b6 12             	movzbl (%edx),%edx
  801cfe:	29 d0                	sub    %edx,%eax
}
  801d00:	5b                   	pop    %ebx
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
		return 0;
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
  801d08:	eb f6                	jmp    801d00 <strncmp+0x32>

00801d0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d0a:	f3 0f 1e fb          	endbr32 
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	8b 45 08             	mov    0x8(%ebp),%eax
  801d14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d18:	0f b6 10             	movzbl (%eax),%edx
  801d1b:	84 d2                	test   %dl,%dl
  801d1d:	74 09                	je     801d28 <strchr+0x1e>
		if (*s == c)
  801d1f:	38 ca                	cmp    %cl,%dl
  801d21:	74 0a                	je     801d2d <strchr+0x23>
	for (; *s; s++)
  801d23:	83 c0 01             	add    $0x1,%eax
  801d26:	eb f0                	jmp    801d18 <strchr+0xe>
			return (char *) s;
	return 0;
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d2f:	f3 0f 1e fb          	endbr32 
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d39:	6a 78                	push   $0x78
  801d3b:	ff 75 08             	pushl  0x8(%ebp)
  801d3e:	e8 c7 ff ff ff       	call   801d0a <strchr>
  801d43:	83 c4 10             	add    $0x10,%esp
  801d46:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d4e:	eb 0d                	jmp    801d5d <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d50:	c1 e0 04             	shl    $0x4,%eax
  801d53:	0f be d2             	movsbl %dl,%edx
  801d56:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d5a:	83 c1 01             	add    $0x1,%ecx
  801d5d:	0f b6 11             	movzbl (%ecx),%edx
  801d60:	84 d2                	test   %dl,%dl
  801d62:	74 11                	je     801d75 <atox+0x46>
		if (*p>='a'){
  801d64:	80 fa 60             	cmp    $0x60,%dl
  801d67:	7e e7                	jle    801d50 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d69:	c1 e0 04             	shl    $0x4,%eax
  801d6c:	0f be d2             	movsbl %dl,%edx
  801d6f:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d73:	eb e5                	jmp    801d5a <atox+0x2b>
	}

	return v;

}
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d77:	f3 0f 1e fb          	endbr32 
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d85:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d88:	38 ca                	cmp    %cl,%dl
  801d8a:	74 09                	je     801d95 <strfind+0x1e>
  801d8c:	84 d2                	test   %dl,%dl
  801d8e:	74 05                	je     801d95 <strfind+0x1e>
	for (; *s; s++)
  801d90:	83 c0 01             	add    $0x1,%eax
  801d93:	eb f0                	jmp    801d85 <strfind+0xe>
			break;
	return (char *) s;
}
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d97:	f3 0f 1e fb          	endbr32 
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	57                   	push   %edi
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801da4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801da7:	85 c9                	test   %ecx,%ecx
  801da9:	74 31                	je     801ddc <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801dab:	89 f8                	mov    %edi,%eax
  801dad:	09 c8                	or     %ecx,%eax
  801daf:	a8 03                	test   $0x3,%al
  801db1:	75 23                	jne    801dd6 <memset+0x3f>
		c &= 0xFF;
  801db3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801db7:	89 d3                	mov    %edx,%ebx
  801db9:	c1 e3 08             	shl    $0x8,%ebx
  801dbc:	89 d0                	mov    %edx,%eax
  801dbe:	c1 e0 18             	shl    $0x18,%eax
  801dc1:	89 d6                	mov    %edx,%esi
  801dc3:	c1 e6 10             	shl    $0x10,%esi
  801dc6:	09 f0                	or     %esi,%eax
  801dc8:	09 c2                	or     %eax,%edx
  801dca:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801dcc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801dcf:	89 d0                	mov    %edx,%eax
  801dd1:	fc                   	cld    
  801dd2:	f3 ab                	rep stos %eax,%es:(%edi)
  801dd4:	eb 06                	jmp    801ddc <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd9:	fc                   	cld    
  801dda:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ddc:	89 f8                	mov    %edi,%eax
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801de3:	f3 0f 1e fb          	endbr32 
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	57                   	push   %edi
  801deb:	56                   	push   %esi
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	8b 75 0c             	mov    0xc(%ebp),%esi
  801df2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801df5:	39 c6                	cmp    %eax,%esi
  801df7:	73 32                	jae    801e2b <memmove+0x48>
  801df9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dfc:	39 c2                	cmp    %eax,%edx
  801dfe:	76 2b                	jbe    801e2b <memmove+0x48>
		s += n;
		d += n;
  801e00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e03:	89 fe                	mov    %edi,%esi
  801e05:	09 ce                	or     %ecx,%esi
  801e07:	09 d6                	or     %edx,%esi
  801e09:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e0f:	75 0e                	jne    801e1f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e11:	83 ef 04             	sub    $0x4,%edi
  801e14:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e1a:	fd                   	std    
  801e1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e1d:	eb 09                	jmp    801e28 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e1f:	83 ef 01             	sub    $0x1,%edi
  801e22:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e25:	fd                   	std    
  801e26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e28:	fc                   	cld    
  801e29:	eb 1a                	jmp    801e45 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e2b:	89 c2                	mov    %eax,%edx
  801e2d:	09 ca                	or     %ecx,%edx
  801e2f:	09 f2                	or     %esi,%edx
  801e31:	f6 c2 03             	test   $0x3,%dl
  801e34:	75 0a                	jne    801e40 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e36:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e39:	89 c7                	mov    %eax,%edi
  801e3b:	fc                   	cld    
  801e3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e3e:	eb 05                	jmp    801e45 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e40:	89 c7                	mov    %eax,%edi
  801e42:	fc                   	cld    
  801e43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e49:	f3 0f 1e fb          	endbr32 
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e53:	ff 75 10             	pushl  0x10(%ebp)
  801e56:	ff 75 0c             	pushl  0xc(%ebp)
  801e59:	ff 75 08             	pushl  0x8(%ebp)
  801e5c:	e8 82 ff ff ff       	call   801de3 <memmove>
}
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e63:	f3 0f 1e fb          	endbr32 
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	56                   	push   %esi
  801e6b:	53                   	push   %ebx
  801e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e72:	89 c6                	mov    %eax,%esi
  801e74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e77:	39 f0                	cmp    %esi,%eax
  801e79:	74 1c                	je     801e97 <memcmp+0x34>
		if (*s1 != *s2)
  801e7b:	0f b6 08             	movzbl (%eax),%ecx
  801e7e:	0f b6 1a             	movzbl (%edx),%ebx
  801e81:	38 d9                	cmp    %bl,%cl
  801e83:	75 08                	jne    801e8d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801e85:	83 c0 01             	add    $0x1,%eax
  801e88:	83 c2 01             	add    $0x1,%edx
  801e8b:	eb ea                	jmp    801e77 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801e8d:	0f b6 c1             	movzbl %cl,%eax
  801e90:	0f b6 db             	movzbl %bl,%ebx
  801e93:	29 d8                	sub    %ebx,%eax
  801e95:	eb 05                	jmp    801e9c <memcmp+0x39>
	}

	return 0;
  801e97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5d                   	pop    %ebp
  801e9f:	c3                   	ret    

00801ea0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ea0:	f3 0f 1e fb          	endbr32 
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ead:	89 c2                	mov    %eax,%edx
  801eaf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801eb2:	39 d0                	cmp    %edx,%eax
  801eb4:	73 09                	jae    801ebf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801eb6:	38 08                	cmp    %cl,(%eax)
  801eb8:	74 05                	je     801ebf <memfind+0x1f>
	for (; s < ends; s++)
  801eba:	83 c0 01             	add    $0x1,%eax
  801ebd:	eb f3                	jmp    801eb2 <memfind+0x12>
			break;
	return (void *) s;
}
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ec1:	f3 0f 1e fb          	endbr32 
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	57                   	push   %edi
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ece:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ed1:	eb 03                	jmp    801ed6 <strtol+0x15>
		s++;
  801ed3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801ed6:	0f b6 01             	movzbl (%ecx),%eax
  801ed9:	3c 20                	cmp    $0x20,%al
  801edb:	74 f6                	je     801ed3 <strtol+0x12>
  801edd:	3c 09                	cmp    $0x9,%al
  801edf:	74 f2                	je     801ed3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801ee1:	3c 2b                	cmp    $0x2b,%al
  801ee3:	74 2a                	je     801f0f <strtol+0x4e>
	int neg = 0;
  801ee5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801eea:	3c 2d                	cmp    $0x2d,%al
  801eec:	74 2b                	je     801f19 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801eee:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ef4:	75 0f                	jne    801f05 <strtol+0x44>
  801ef6:	80 39 30             	cmpb   $0x30,(%ecx)
  801ef9:	74 28                	je     801f23 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f02:	0f 44 d8             	cmove  %eax,%ebx
  801f05:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f0d:	eb 46                	jmp    801f55 <strtol+0x94>
		s++;
  801f0f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f12:	bf 00 00 00 00       	mov    $0x0,%edi
  801f17:	eb d5                	jmp    801eee <strtol+0x2d>
		s++, neg = 1;
  801f19:	83 c1 01             	add    $0x1,%ecx
  801f1c:	bf 01 00 00 00       	mov    $0x1,%edi
  801f21:	eb cb                	jmp    801eee <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f23:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f27:	74 0e                	je     801f37 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f29:	85 db                	test   %ebx,%ebx
  801f2b:	75 d8                	jne    801f05 <strtol+0x44>
		s++, base = 8;
  801f2d:	83 c1 01             	add    $0x1,%ecx
  801f30:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f35:	eb ce                	jmp    801f05 <strtol+0x44>
		s += 2, base = 16;
  801f37:	83 c1 02             	add    $0x2,%ecx
  801f3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f3f:	eb c4                	jmp    801f05 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f41:	0f be d2             	movsbl %dl,%edx
  801f44:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f47:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f4a:	7d 3a                	jge    801f86 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f4c:	83 c1 01             	add    $0x1,%ecx
  801f4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f53:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f55:	0f b6 11             	movzbl (%ecx),%edx
  801f58:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f5b:	89 f3                	mov    %esi,%ebx
  801f5d:	80 fb 09             	cmp    $0x9,%bl
  801f60:	76 df                	jbe    801f41 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f62:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f65:	89 f3                	mov    %esi,%ebx
  801f67:	80 fb 19             	cmp    $0x19,%bl
  801f6a:	77 08                	ja     801f74 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f6c:	0f be d2             	movsbl %dl,%edx
  801f6f:	83 ea 57             	sub    $0x57,%edx
  801f72:	eb d3                	jmp    801f47 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f74:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f77:	89 f3                	mov    %esi,%ebx
  801f79:	80 fb 19             	cmp    $0x19,%bl
  801f7c:	77 08                	ja     801f86 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f7e:	0f be d2             	movsbl %dl,%edx
  801f81:	83 ea 37             	sub    $0x37,%edx
  801f84:	eb c1                	jmp    801f47 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801f86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f8a:	74 05                	je     801f91 <strtol+0xd0>
		*endptr = (char *) s;
  801f8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801f91:	89 c2                	mov    %eax,%edx
  801f93:	f7 da                	neg    %edx
  801f95:	85 ff                	test   %edi,%edi
  801f97:	0f 45 c2             	cmovne %edx,%eax
}
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f9f:	f3 0f 1e fb          	endbr32 
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	8b 75 08             	mov    0x8(%ebp),%esi
  801fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fb8:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fbb:	83 ec 0c             	sub    $0xc,%esp
  801fbe:	50                   	push   %eax
  801fbf:	e8 97 e2 ff ff       	call   80025b <sys_ipc_recv>
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	75 2b                	jne    801ff6 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fcb:	85 f6                	test   %esi,%esi
  801fcd:	74 0a                	je     801fd9 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fcf:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd4:	8b 40 74             	mov    0x74(%eax),%eax
  801fd7:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fd9:	85 db                	test   %ebx,%ebx
  801fdb:	74 0a                	je     801fe7 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801fdd:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe2:	8b 40 78             	mov    0x78(%eax),%eax
  801fe5:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801fe7:	a1 08 40 80 00       	mov    0x804008,%eax
  801fec:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff2:	5b                   	pop    %ebx
  801ff3:	5e                   	pop    %esi
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  801ff6:	85 f6                	test   %esi,%esi
  801ff8:	74 06                	je     802000 <ipc_recv+0x61>
  801ffa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802000:	85 db                	test   %ebx,%ebx
  802002:	74 eb                	je     801fef <ipc_recv+0x50>
  802004:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80200a:	eb e3                	jmp    801fef <ipc_recv+0x50>

0080200c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80200c:	f3 0f 1e fb          	endbr32 
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	57                   	push   %edi
  802014:	56                   	push   %esi
  802015:	53                   	push   %ebx
  802016:	83 ec 0c             	sub    $0xc,%esp
  802019:	8b 7d 08             	mov    0x8(%ebp),%edi
  80201c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802022:	85 db                	test   %ebx,%ebx
  802024:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802029:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80202c:	ff 75 14             	pushl  0x14(%ebp)
  80202f:	53                   	push   %ebx
  802030:	56                   	push   %esi
  802031:	57                   	push   %edi
  802032:	e8 fd e1 ff ff       	call   800234 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80203d:	75 07                	jne    802046 <ipc_send+0x3a>
			sys_yield();
  80203f:	e8 ee e0 ff ff       	call   800132 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802044:	eb e6                	jmp    80202c <ipc_send+0x20>
		}
		else if (ret == 0)
  802046:	85 c0                	test   %eax,%eax
  802048:	75 08                	jne    802052 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80204a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802052:	50                   	push   %eax
  802053:	68 1f 28 80 00       	push   $0x80281f
  802058:	6a 48                	push   $0x48
  80205a:	68 2d 28 80 00       	push   $0x80282d
  80205f:	e8 90 f4 ff ff       	call   8014f4 <_panic>

00802064 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802064:	f3 0f 1e fb          	endbr32 
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802073:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802076:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80207c:	8b 52 50             	mov    0x50(%edx),%edx
  80207f:	39 ca                	cmp    %ecx,%edx
  802081:	74 11                	je     802094 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802083:	83 c0 01             	add    $0x1,%eax
  802086:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208b:	75 e6                	jne    802073 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80208d:	b8 00 00 00 00       	mov    $0x0,%eax
  802092:	eb 0b                	jmp    80209f <ipc_find_env+0x3b>
			return envs[i].env_id;
  802094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80209c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    

008020a1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a1:	f3 0f 1e fb          	endbr32 
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ab:	89 c2                	mov    %eax,%edx
  8020ad:	c1 ea 16             	shr    $0x16,%edx
  8020b0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020b7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020bc:	f6 c1 01             	test   $0x1,%cl
  8020bf:	74 1c                	je     8020dd <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020c1:	c1 e8 0c             	shr    $0xc,%eax
  8020c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020cb:	a8 01                	test   $0x1,%al
  8020cd:	74 0e                	je     8020dd <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020cf:	c1 e8 0c             	shr    $0xc,%eax
  8020d2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020d9:	ef 
  8020da:	0f b7 d2             	movzwl %dx,%edx
}
  8020dd:	89 d0                	mov    %edx,%eax
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    
  8020e1:	66 90                	xchg   %ax,%ax
  8020e3:	66 90                	xchg   %ax,%ax
  8020e5:	66 90                	xchg   %ax,%ax
  8020e7:	66 90                	xchg   %ax,%ax
  8020e9:	66 90                	xchg   %ax,%ax
  8020eb:	66 90                	xchg   %ax,%ax
  8020ed:	66 90                	xchg   %ax,%ax
  8020ef:	90                   	nop

008020f0 <__udivdi3>:
  8020f0:	f3 0f 1e fb          	endbr32 
  8020f4:	55                   	push   %ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 1c             	sub    $0x1c,%esp
  8020fb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802103:	8b 74 24 34          	mov    0x34(%esp),%esi
  802107:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80210b:	85 d2                	test   %edx,%edx
  80210d:	75 19                	jne    802128 <__udivdi3+0x38>
  80210f:	39 f3                	cmp    %esi,%ebx
  802111:	76 4d                	jbe    802160 <__udivdi3+0x70>
  802113:	31 ff                	xor    %edi,%edi
  802115:	89 e8                	mov    %ebp,%eax
  802117:	89 f2                	mov    %esi,%edx
  802119:	f7 f3                	div    %ebx
  80211b:	89 fa                	mov    %edi,%edx
  80211d:	83 c4 1c             	add    $0x1c,%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi
  802128:	39 f2                	cmp    %esi,%edx
  80212a:	76 14                	jbe    802140 <__udivdi3+0x50>
  80212c:	31 ff                	xor    %edi,%edi
  80212e:	31 c0                	xor    %eax,%eax
  802130:	89 fa                	mov    %edi,%edx
  802132:	83 c4 1c             	add    $0x1c,%esp
  802135:	5b                   	pop    %ebx
  802136:	5e                   	pop    %esi
  802137:	5f                   	pop    %edi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    
  80213a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802140:	0f bd fa             	bsr    %edx,%edi
  802143:	83 f7 1f             	xor    $0x1f,%edi
  802146:	75 48                	jne    802190 <__udivdi3+0xa0>
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	72 06                	jb     802152 <__udivdi3+0x62>
  80214c:	31 c0                	xor    %eax,%eax
  80214e:	39 eb                	cmp    %ebp,%ebx
  802150:	77 de                	ja     802130 <__udivdi3+0x40>
  802152:	b8 01 00 00 00       	mov    $0x1,%eax
  802157:	eb d7                	jmp    802130 <__udivdi3+0x40>
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d9                	mov    %ebx,%ecx
  802162:	85 db                	test   %ebx,%ebx
  802164:	75 0b                	jne    802171 <__udivdi3+0x81>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f3                	div    %ebx
  80216f:	89 c1                	mov    %eax,%ecx
  802171:	31 d2                	xor    %edx,%edx
  802173:	89 f0                	mov    %esi,%eax
  802175:	f7 f1                	div    %ecx
  802177:	89 c6                	mov    %eax,%esi
  802179:	89 e8                	mov    %ebp,%eax
  80217b:	89 f7                	mov    %esi,%edi
  80217d:	f7 f1                	div    %ecx
  80217f:	89 fa                	mov    %edi,%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 f9                	mov    %edi,%ecx
  802192:	b8 20 00 00 00       	mov    $0x20,%eax
  802197:	29 f8                	sub    %edi,%eax
  802199:	d3 e2                	shl    %cl,%edx
  80219b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	89 da                	mov    %ebx,%edx
  8021a3:	d3 ea                	shr    %cl,%edx
  8021a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021a9:	09 d1                	or     %edx,%ecx
  8021ab:	89 f2                	mov    %esi,%edx
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	d3 e3                	shl    %cl,%ebx
  8021b5:	89 c1                	mov    %eax,%ecx
  8021b7:	d3 ea                	shr    %cl,%edx
  8021b9:	89 f9                	mov    %edi,%ecx
  8021bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021bf:	89 eb                	mov    %ebp,%ebx
  8021c1:	d3 e6                	shl    %cl,%esi
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	d3 eb                	shr    %cl,%ebx
  8021c7:	09 de                	or     %ebx,%esi
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	f7 74 24 08          	divl   0x8(%esp)
  8021cf:	89 d6                	mov    %edx,%esi
  8021d1:	89 c3                	mov    %eax,%ebx
  8021d3:	f7 64 24 0c          	mull   0xc(%esp)
  8021d7:	39 d6                	cmp    %edx,%esi
  8021d9:	72 15                	jb     8021f0 <__udivdi3+0x100>
  8021db:	89 f9                	mov    %edi,%ecx
  8021dd:	d3 e5                	shl    %cl,%ebp
  8021df:	39 c5                	cmp    %eax,%ebp
  8021e1:	73 04                	jae    8021e7 <__udivdi3+0xf7>
  8021e3:	39 d6                	cmp    %edx,%esi
  8021e5:	74 09                	je     8021f0 <__udivdi3+0x100>
  8021e7:	89 d8                	mov    %ebx,%eax
  8021e9:	31 ff                	xor    %edi,%edi
  8021eb:	e9 40 ff ff ff       	jmp    802130 <__udivdi3+0x40>
  8021f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021f3:	31 ff                	xor    %edi,%edi
  8021f5:	e9 36 ff ff ff       	jmp    802130 <__udivdi3+0x40>
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	f3 0f 1e fb          	endbr32 
  802204:	55                   	push   %ebp
  802205:	57                   	push   %edi
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	83 ec 1c             	sub    $0x1c,%esp
  80220b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80220f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802213:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802217:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80221b:	85 c0                	test   %eax,%eax
  80221d:	75 19                	jne    802238 <__umoddi3+0x38>
  80221f:	39 df                	cmp    %ebx,%edi
  802221:	76 5d                	jbe    802280 <__umoddi3+0x80>
  802223:	89 f0                	mov    %esi,%eax
  802225:	89 da                	mov    %ebx,%edx
  802227:	f7 f7                	div    %edi
  802229:	89 d0                	mov    %edx,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	83 c4 1c             	add    $0x1c,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	8d 76 00             	lea    0x0(%esi),%esi
  802238:	89 f2                	mov    %esi,%edx
  80223a:	39 d8                	cmp    %ebx,%eax
  80223c:	76 12                	jbe    802250 <__umoddi3+0x50>
  80223e:	89 f0                	mov    %esi,%eax
  802240:	89 da                	mov    %ebx,%edx
  802242:	83 c4 1c             	add    $0x1c,%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5f                   	pop    %edi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    
  80224a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802250:	0f bd e8             	bsr    %eax,%ebp
  802253:	83 f5 1f             	xor    $0x1f,%ebp
  802256:	75 50                	jne    8022a8 <__umoddi3+0xa8>
  802258:	39 d8                	cmp    %ebx,%eax
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	89 d9                	mov    %ebx,%ecx
  802262:	39 f7                	cmp    %esi,%edi
  802264:	0f 86 d6 00 00 00    	jbe    802340 <__umoddi3+0x140>
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	89 ca                	mov    %ecx,%edx
  80226e:	83 c4 1c             	add    $0x1c,%esp
  802271:	5b                   	pop    %ebx
  802272:	5e                   	pop    %esi
  802273:	5f                   	pop    %edi
  802274:	5d                   	pop    %ebp
  802275:	c3                   	ret    
  802276:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80227d:	8d 76 00             	lea    0x0(%esi),%esi
  802280:	89 fd                	mov    %edi,%ebp
  802282:	85 ff                	test   %edi,%edi
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 d8                	mov    %ebx,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 f0                	mov    %esi,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	31 d2                	xor    %edx,%edx
  80229f:	eb 8c                	jmp    80222d <__umoddi3+0x2d>
  8022a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	89 e9                	mov    %ebp,%ecx
  8022aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8022af:	29 ea                	sub    %ebp,%edx
  8022b1:	d3 e0                	shl    %cl,%eax
  8022b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 f8                	mov    %edi,%eax
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c9:	09 c1                	or     %eax,%ecx
  8022cb:	89 d8                	mov    %ebx,%eax
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 e9                	mov    %ebp,%ecx
  8022d3:	d3 e7                	shl    %cl,%edi
  8022d5:	89 d1                	mov    %edx,%ecx
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022df:	d3 e3                	shl    %cl,%ebx
  8022e1:	89 c7                	mov    %eax,%edi
  8022e3:	89 d1                	mov    %edx,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	89 fa                	mov    %edi,%edx
  8022ed:	d3 e6                	shl    %cl,%esi
  8022ef:	09 d8                	or     %ebx,%eax
  8022f1:	f7 74 24 08          	divl   0x8(%esp)
  8022f5:	89 d1                	mov    %edx,%ecx
  8022f7:	89 f3                	mov    %esi,%ebx
  8022f9:	f7 64 24 0c          	mull   0xc(%esp)
  8022fd:	89 c6                	mov    %eax,%esi
  8022ff:	89 d7                	mov    %edx,%edi
  802301:	39 d1                	cmp    %edx,%ecx
  802303:	72 06                	jb     80230b <__umoddi3+0x10b>
  802305:	75 10                	jne    802317 <__umoddi3+0x117>
  802307:	39 c3                	cmp    %eax,%ebx
  802309:	73 0c                	jae    802317 <__umoddi3+0x117>
  80230b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80230f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802313:	89 d7                	mov    %edx,%edi
  802315:	89 c6                	mov    %eax,%esi
  802317:	89 ca                	mov    %ecx,%edx
  802319:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80231e:	29 f3                	sub    %esi,%ebx
  802320:	19 fa                	sbb    %edi,%edx
  802322:	89 d0                	mov    %edx,%eax
  802324:	d3 e0                	shl    %cl,%eax
  802326:	89 e9                	mov    %ebp,%ecx
  802328:	d3 eb                	shr    %cl,%ebx
  80232a:	d3 ea                	shr    %cl,%edx
  80232c:	09 d8                	or     %ebx,%eax
  80232e:	83 c4 1c             	add    $0x1c,%esp
  802331:	5b                   	pop    %ebx
  802332:	5e                   	pop    %esi
  802333:	5f                   	pop    %edi
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    
  802336:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 fe                	sub    %edi,%esi
  802342:	19 c3                	sbb    %eax,%ebx
  802344:	89 f2                	mov    %esi,%edx
  802346:	89 d9                	mov    %ebx,%ecx
  802348:	e9 1d ff ff ff       	jmp    80226a <__umoddi3+0x6a>
