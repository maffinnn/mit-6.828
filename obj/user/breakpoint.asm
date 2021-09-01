
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	f3 0f 1e fb          	endbr32 
  80003d:	55                   	push   %ebp
  80003e:	89 e5                	mov    %esp,%ebp
  800040:	56                   	push   %esi
  800041:	53                   	push   %ebx
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800048:	e8 bd 00 00 00       	call   80010a <sys_getenvid>
  80004d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800052:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x31>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	f3 0f 1e fb          	endbr32 
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80008d:	e8 49 04 00 00       	call   8004db <close_all>
	sys_env_destroy(0);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	6a 00                	push   $0x0
  800097:	e8 4a 00 00 00       	call   8000e6 <sys_env_destroy>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a1:	f3 0f 1e fb          	endbr32 
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c3:	f3 0f 1e fb          	endbr32 
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e6:	f3 0f 1e fb          	endbr32 
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	5b                   	pop    %ebx
  800106:	5e                   	pop    %esi
  800107:	5f                   	pop    %edi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010a:	f3 0f 1e fb          	endbr32 
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	57                   	push   %edi
  800112:	56                   	push   %esi
  800113:	53                   	push   %ebx
	asm volatile("int %1\n"
  800114:	ba 00 00 00 00       	mov    $0x0,%edx
  800119:	b8 02 00 00 00       	mov    $0x2,%eax
  80011e:	89 d1                	mov    %edx,%ecx
  800120:	89 d3                	mov    %edx,%ebx
  800122:	89 d7                	mov    %edx,%edi
  800124:	89 d6                	mov    %edx,%esi
  800126:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5f                   	pop    %edi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <sys_yield>:

void
sys_yield(void)
{
  80012d:	f3 0f 1e fb          	endbr32 
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	57                   	push   %edi
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	asm volatile("int %1\n"
  800137:	ba 00 00 00 00       	mov    $0x0,%edx
  80013c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800141:	89 d1                	mov    %edx,%ecx
  800143:	89 d3                	mov    %edx,%ebx
  800145:	89 d7                	mov    %edx,%edi
  800147:	89 d6                	mov    %edx,%esi
  800149:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800150:	f3 0f 1e fb          	endbr32 
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015a:	be 00 00 00 00       	mov    $0x0,%esi
  80015f:	8b 55 08             	mov    0x8(%ebp),%edx
  800162:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800165:	b8 04 00 00 00       	mov    $0x4,%eax
  80016a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016d:	89 f7                	mov    %esi,%edi
  80016f:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800176:	f3 0f 1e fb          	endbr32 
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	b8 05 00 00 00       	mov    $0x5,%eax
  80018b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800191:	8b 75 18             	mov    0x18(%ebp),%esi
  800194:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800196:	5b                   	pop    %ebx
  800197:	5e                   	pop    %esi
  800198:	5f                   	pop    %edi
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80019b:	f3 0f 1e fb          	endbr32 
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	57                   	push   %edi
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001b5:	89 df                	mov    %ebx,%edi
  8001b7:	89 de                	mov    %ebx,%esi
  8001b9:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    

008001c0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001c0:	f3 0f 1e fb          	endbr32 
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8001da:	89 df                	mov    %ebx,%edi
  8001dc:	89 de                	mov    %ebx,%esi
  8001de:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001e5:	f3 0f 1e fb          	endbr32 
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	b8 09 00 00 00       	mov    $0x9,%eax
  8001ff:	89 df                	mov    %ebx,%edi
  800201:	89 de                	mov    %ebx,%esi
  800203:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80020a:	f3 0f 1e fb          	endbr32 
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	57                   	push   %edi
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
	asm volatile("int %1\n"
  800214:	bb 00 00 00 00       	mov    $0x0,%ebx
  800219:	8b 55 08             	mov    0x8(%ebp),%edx
  80021c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800224:	89 df                	mov    %ebx,%edi
  800226:	89 de                	mov    %ebx,%esi
  800228:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80022f:	f3 0f 1e fb          	endbr32 
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
	asm volatile("int %1\n"
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800244:	be 00 00 00 00       	mov    $0x0,%esi
  800249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80024f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800256:	f3 0f 1e fb          	endbr32 
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	57                   	push   %edi
  80025e:	56                   	push   %esi
  80025f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800260:	b9 00 00 00 00       	mov    $0x0,%ecx
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	b8 0d 00 00 00       	mov    $0xd,%eax
  80026d:	89 cb                	mov    %ecx,%ebx
  80026f:	89 cf                	mov    %ecx,%edi
  800271:	89 ce                	mov    %ecx,%esi
  800273:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80027a:	f3 0f 1e fb          	endbr32 
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	57                   	push   %edi
  800282:	56                   	push   %esi
  800283:	53                   	push   %ebx
	asm volatile("int %1\n"
  800284:	ba 00 00 00 00       	mov    $0x0,%edx
  800289:	b8 0e 00 00 00       	mov    $0xe,%eax
  80028e:	89 d1                	mov    %edx,%ecx
  800290:	89 d3                	mov    %edx,%ebx
  800292:	89 d7                	mov    %edx,%edi
  800294:	89 d6                	mov    %edx,%esi
  800296:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  80029d:	f3 0f 1e fb          	endbr32 
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002b7:	89 df                	mov    %ebx,%edi
  8002b9:	89 de                	mov    %ebx,%esi
  8002bb:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002c2:	f3 0f 1e fb          	endbr32 
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d7:	b8 10 00 00 00       	mov    $0x10,%eax
  8002dc:	89 df                	mov    %ebx,%edi
  8002de:	89 de                	mov    %ebx,%esi
  8002e0:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002e7:	f3 0f 1e fb          	endbr32 
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	05 00 00 00 30       	add    $0x30000000,%eax
  8002f6:	c1 e8 0c             	shr    $0xc,%eax
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80030a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80030f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800316:	f3 0f 1e fb          	endbr32 
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800322:	89 c2                	mov    %eax,%edx
  800324:	c1 ea 16             	shr    $0x16,%edx
  800327:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80032e:	f6 c2 01             	test   $0x1,%dl
  800331:	74 2d                	je     800360 <fd_alloc+0x4a>
  800333:	89 c2                	mov    %eax,%edx
  800335:	c1 ea 0c             	shr    $0xc,%edx
  800338:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80033f:	f6 c2 01             	test   $0x1,%dl
  800342:	74 1c                	je     800360 <fd_alloc+0x4a>
  800344:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800349:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80034e:	75 d2                	jne    800322 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800350:	8b 45 08             	mov    0x8(%ebp),%eax
  800353:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800359:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80035e:	eb 0a                	jmp    80036a <fd_alloc+0x54>
			*fd_store = fd;
  800360:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800363:	89 01                	mov    %eax,(%ecx)
			return 0;
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80036c:	f3 0f 1e fb          	endbr32 
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800376:	83 f8 1f             	cmp    $0x1f,%eax
  800379:	77 30                	ja     8003ab <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80037b:	c1 e0 0c             	shl    $0xc,%eax
  80037e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800383:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 24                	je     8003b2 <fd_lookup+0x46>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	74 1a                	je     8003b9 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80039f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a2:	89 02                	mov    %eax,(%edx)
	return 0;
  8003a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    
		return -E_INVAL;
  8003ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003b0:	eb f7                	jmp    8003a9 <fd_lookup+0x3d>
		return -E_INVAL;
  8003b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003b7:	eb f0                	jmp    8003a9 <fd_lookup+0x3d>
  8003b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003be:	eb e9                	jmp    8003a9 <fd_lookup+0x3d>

008003c0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003c0:	f3 0f 1e fb          	endbr32 
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	83 ec 08             	sub    $0x8,%esp
  8003ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d2:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003d7:	39 08                	cmp    %ecx,(%eax)
  8003d9:	74 38                	je     800413 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8003db:	83 c2 01             	add    $0x1,%edx
  8003de:	8b 04 95 c8 23 80 00 	mov    0x8023c8(,%edx,4),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	75 ee                	jne    8003d7 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8003ee:	8b 40 48             	mov    0x48(%eax),%eax
  8003f1:	83 ec 04             	sub    $0x4,%esp
  8003f4:	51                   	push   %ecx
  8003f5:	50                   	push   %eax
  8003f6:	68 4c 23 80 00       	push   $0x80234c
  8003fb:	e8 d6 11 00 00       	call   8015d6 <cprintf>
	*dev = 0;
  800400:	8b 45 0c             	mov    0xc(%ebp),%eax
  800403:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800411:	c9                   	leave  
  800412:	c3                   	ret    
			*dev = devtab[i];
  800413:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800416:	89 01                	mov    %eax,(%ecx)
			return 0;
  800418:	b8 00 00 00 00       	mov    $0x0,%eax
  80041d:	eb f2                	jmp    800411 <dev_lookup+0x51>

0080041f <fd_close>:
{
  80041f:	f3 0f 1e fb          	endbr32 
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	57                   	push   %edi
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	83 ec 24             	sub    $0x24,%esp
  80042c:	8b 75 08             	mov    0x8(%ebp),%esi
  80042f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800432:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800435:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800436:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80043c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80043f:	50                   	push   %eax
  800440:	e8 27 ff ff ff       	call   80036c <fd_lookup>
  800445:	89 c3                	mov    %eax,%ebx
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	85 c0                	test   %eax,%eax
  80044c:	78 05                	js     800453 <fd_close+0x34>
	    || fd != fd2)
  80044e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800451:	74 16                	je     800469 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800453:	89 f8                	mov    %edi,%eax
  800455:	84 c0                	test   %al,%al
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	0f 44 d8             	cmove  %eax,%ebx
}
  80045f:	89 d8                	mov    %ebx,%eax
  800461:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800464:	5b                   	pop    %ebx
  800465:	5e                   	pop    %esi
  800466:	5f                   	pop    %edi
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80046f:	50                   	push   %eax
  800470:	ff 36                	pushl  (%esi)
  800472:	e8 49 ff ff ff       	call   8003c0 <dev_lookup>
  800477:	89 c3                	mov    %eax,%ebx
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	85 c0                	test   %eax,%eax
  80047e:	78 1a                	js     80049a <fd_close+0x7b>
		if (dev->dev_close)
  800480:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800483:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800486:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80048b:	85 c0                	test   %eax,%eax
  80048d:	74 0b                	je     80049a <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80048f:	83 ec 0c             	sub    $0xc,%esp
  800492:	56                   	push   %esi
  800493:	ff d0                	call   *%eax
  800495:	89 c3                	mov    %eax,%ebx
  800497:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	56                   	push   %esi
  80049e:	6a 00                	push   $0x0
  8004a0:	e8 f6 fc ff ff       	call   80019b <sys_page_unmap>
	return r;
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	eb b5                	jmp    80045f <fd_close+0x40>

008004aa <close>:

int
close(int fdnum)
{
  8004aa:	f3 0f 1e fb          	endbr32 
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	ff 75 08             	pushl  0x8(%ebp)
  8004bb:	e8 ac fe ff ff       	call   80036c <fd_lookup>
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	79 02                	jns    8004c9 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004c7:	c9                   	leave  
  8004c8:	c3                   	ret    
		return fd_close(fd, 1);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	6a 01                	push   $0x1
  8004ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8004d1:	e8 49 ff ff ff       	call   80041f <fd_close>
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	eb ec                	jmp    8004c7 <close+0x1d>

008004db <close_all>:

void
close_all(void)
{
  8004db:	f3 0f 1e fb          	endbr32 
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	53                   	push   %ebx
  8004e3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004eb:	83 ec 0c             	sub    $0xc,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	e8 b6 ff ff ff       	call   8004aa <close>
	for (i = 0; i < MAXFD; i++)
  8004f4:	83 c3 01             	add    $0x1,%ebx
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	83 fb 20             	cmp    $0x20,%ebx
  8004fd:	75 ec                	jne    8004eb <close_all+0x10>
}
  8004ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800504:	f3 0f 1e fb          	endbr32 
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800511:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800514:	50                   	push   %eax
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 4f fe ff ff       	call   80036c <fd_lookup>
  80051d:	89 c3                	mov    %eax,%ebx
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	85 c0                	test   %eax,%eax
  800524:	0f 88 81 00 00 00    	js     8005ab <dup+0xa7>
		return r;
	close(newfdnum);
  80052a:	83 ec 0c             	sub    $0xc,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	e8 75 ff ff ff       	call   8004aa <close>

	newfd = INDEX2FD(newfdnum);
  800535:	8b 75 0c             	mov    0xc(%ebp),%esi
  800538:	c1 e6 0c             	shl    $0xc,%esi
  80053b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800541:	83 c4 04             	add    $0x4,%esp
  800544:	ff 75 e4             	pushl  -0x1c(%ebp)
  800547:	e8 af fd ff ff       	call   8002fb <fd2data>
  80054c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80054e:	89 34 24             	mov    %esi,(%esp)
  800551:	e8 a5 fd ff ff       	call   8002fb <fd2data>
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80055b:	89 d8                	mov    %ebx,%eax
  80055d:	c1 e8 16             	shr    $0x16,%eax
  800560:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800567:	a8 01                	test   $0x1,%al
  800569:	74 11                	je     80057c <dup+0x78>
  80056b:	89 d8                	mov    %ebx,%eax
  80056d:	c1 e8 0c             	shr    $0xc,%eax
  800570:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800577:	f6 c2 01             	test   $0x1,%dl
  80057a:	75 39                	jne    8005b5 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80057c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80057f:	89 d0                	mov    %edx,%eax
  800581:	c1 e8 0c             	shr    $0xc,%eax
  800584:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80058b:	83 ec 0c             	sub    $0xc,%esp
  80058e:	25 07 0e 00 00       	and    $0xe07,%eax
  800593:	50                   	push   %eax
  800594:	56                   	push   %esi
  800595:	6a 00                	push   $0x0
  800597:	52                   	push   %edx
  800598:	6a 00                	push   $0x0
  80059a:	e8 d7 fb ff ff       	call   800176 <sys_page_map>
  80059f:	89 c3                	mov    %eax,%ebx
  8005a1:	83 c4 20             	add    $0x20,%esp
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	78 31                	js     8005d9 <dup+0xd5>
		goto err;

	return newfdnum;
  8005a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ab:	89 d8                	mov    %ebx,%eax
  8005ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b0:	5b                   	pop    %ebx
  8005b1:	5e                   	pop    %esi
  8005b2:	5f                   	pop    %edi
  8005b3:	5d                   	pop    %ebp
  8005b4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c4:	50                   	push   %eax
  8005c5:	57                   	push   %edi
  8005c6:	6a 00                	push   $0x0
  8005c8:	53                   	push   %ebx
  8005c9:	6a 00                	push   $0x0
  8005cb:	e8 a6 fb ff ff       	call   800176 <sys_page_map>
  8005d0:	89 c3                	mov    %eax,%ebx
  8005d2:	83 c4 20             	add    $0x20,%esp
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	79 a3                	jns    80057c <dup+0x78>
	sys_page_unmap(0, newfd);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	56                   	push   %esi
  8005dd:	6a 00                	push   $0x0
  8005df:	e8 b7 fb ff ff       	call   80019b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005e4:	83 c4 08             	add    $0x8,%esp
  8005e7:	57                   	push   %edi
  8005e8:	6a 00                	push   $0x0
  8005ea:	e8 ac fb ff ff       	call   80019b <sys_page_unmap>
	return r;
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	eb b7                	jmp    8005ab <dup+0xa7>

008005f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8005f4:	f3 0f 1e fb          	endbr32 
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	53                   	push   %ebx
  8005fc:	83 ec 1c             	sub    $0x1c,%esp
  8005ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800605:	50                   	push   %eax
  800606:	53                   	push   %ebx
  800607:	e8 60 fd ff ff       	call   80036c <fd_lookup>
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	78 3f                	js     800652 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800619:	50                   	push   %eax
  80061a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061d:	ff 30                	pushl  (%eax)
  80061f:	e8 9c fd ff ff       	call   8003c0 <dev_lookup>
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	85 c0                	test   %eax,%eax
  800629:	78 27                	js     800652 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80062b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80062e:	8b 42 08             	mov    0x8(%edx),%eax
  800631:	83 e0 03             	and    $0x3,%eax
  800634:	83 f8 01             	cmp    $0x1,%eax
  800637:	74 1e                	je     800657 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800639:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80063c:	8b 40 08             	mov    0x8(%eax),%eax
  80063f:	85 c0                	test   %eax,%eax
  800641:	74 35                	je     800678 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800643:	83 ec 04             	sub    $0x4,%esp
  800646:	ff 75 10             	pushl  0x10(%ebp)
  800649:	ff 75 0c             	pushl  0xc(%ebp)
  80064c:	52                   	push   %edx
  80064d:	ff d0                	call   *%eax
  80064f:	83 c4 10             	add    $0x10,%esp
}
  800652:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800655:	c9                   	leave  
  800656:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800657:	a1 08 40 80 00       	mov    0x804008,%eax
  80065c:	8b 40 48             	mov    0x48(%eax),%eax
  80065f:	83 ec 04             	sub    $0x4,%esp
  800662:	53                   	push   %ebx
  800663:	50                   	push   %eax
  800664:	68 8d 23 80 00       	push   $0x80238d
  800669:	e8 68 0f 00 00       	call   8015d6 <cprintf>
		return -E_INVAL;
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800676:	eb da                	jmp    800652 <read+0x5e>
		return -E_NOT_SUPP;
  800678:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80067d:	eb d3                	jmp    800652 <read+0x5e>

0080067f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80067f:	f3 0f 1e fb          	endbr32 
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	57                   	push   %edi
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80068f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800692:	bb 00 00 00 00       	mov    $0x0,%ebx
  800697:	eb 02                	jmp    80069b <readn+0x1c>
  800699:	01 c3                	add    %eax,%ebx
  80069b:	39 f3                	cmp    %esi,%ebx
  80069d:	73 21                	jae    8006c0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80069f:	83 ec 04             	sub    $0x4,%esp
  8006a2:	89 f0                	mov    %esi,%eax
  8006a4:	29 d8                	sub    %ebx,%eax
  8006a6:	50                   	push   %eax
  8006a7:	89 d8                	mov    %ebx,%eax
  8006a9:	03 45 0c             	add    0xc(%ebp),%eax
  8006ac:	50                   	push   %eax
  8006ad:	57                   	push   %edi
  8006ae:	e8 41 ff ff ff       	call   8005f4 <read>
		if (m < 0)
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	85 c0                	test   %eax,%eax
  8006b8:	78 04                	js     8006be <readn+0x3f>
			return m;
		if (m == 0)
  8006ba:	75 dd                	jne    800699 <readn+0x1a>
  8006bc:	eb 02                	jmp    8006c0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006be:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006c0:	89 d8                	mov    %ebx,%eax
  8006c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c5:	5b                   	pop    %ebx
  8006c6:	5e                   	pop    %esi
  8006c7:	5f                   	pop    %edi
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ca:	f3 0f 1e fb          	endbr32 
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 1c             	sub    $0x1c,%esp
  8006d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	53                   	push   %ebx
  8006dd:	e8 8a fc ff ff       	call   80036c <fd_lookup>
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 3a                	js     800723 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ef:	50                   	push   %eax
  8006f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f3:	ff 30                	pushl  (%eax)
  8006f5:	e8 c6 fc ff ff       	call   8003c0 <dev_lookup>
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	78 22                	js     800723 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800704:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800708:	74 1e                	je     800728 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80070a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80070d:	8b 52 0c             	mov    0xc(%edx),%edx
  800710:	85 d2                	test   %edx,%edx
  800712:	74 35                	je     800749 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	ff 75 10             	pushl  0x10(%ebp)
  80071a:	ff 75 0c             	pushl  0xc(%ebp)
  80071d:	50                   	push   %eax
  80071e:	ff d2                	call   *%edx
  800720:	83 c4 10             	add    $0x10,%esp
}
  800723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800726:	c9                   	leave  
  800727:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800728:	a1 08 40 80 00       	mov    0x804008,%eax
  80072d:	8b 40 48             	mov    0x48(%eax),%eax
  800730:	83 ec 04             	sub    $0x4,%esp
  800733:	53                   	push   %ebx
  800734:	50                   	push   %eax
  800735:	68 a9 23 80 00       	push   $0x8023a9
  80073a:	e8 97 0e 00 00       	call   8015d6 <cprintf>
		return -E_INVAL;
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800747:	eb da                	jmp    800723 <write+0x59>
		return -E_NOT_SUPP;
  800749:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80074e:	eb d3                	jmp    800723 <write+0x59>

00800750 <seek>:

int
seek(int fdnum, off_t offset)
{
  800750:	f3 0f 1e fb          	endbr32 
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80075a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	ff 75 08             	pushl  0x8(%ebp)
  800761:	e8 06 fc ff ff       	call   80036c <fd_lookup>
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	85 c0                	test   %eax,%eax
  80076b:	78 0e                	js     80077b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80076d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800773:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80077d:	f3 0f 1e fb          	endbr32 
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	53                   	push   %ebx
  800785:	83 ec 1c             	sub    $0x1c,%esp
  800788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80078e:	50                   	push   %eax
  80078f:	53                   	push   %ebx
  800790:	e8 d7 fb ff ff       	call   80036c <fd_lookup>
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	85 c0                	test   %eax,%eax
  80079a:	78 37                	js     8007d3 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a6:	ff 30                	pushl  (%eax)
  8007a8:	e8 13 fc ff ff       	call   8003c0 <dev_lookup>
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	85 c0                	test   %eax,%eax
  8007b2:	78 1f                	js     8007d3 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007bb:	74 1b                	je     8007d8 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c0:	8b 52 18             	mov    0x18(%edx),%edx
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 32                	je     8007f9 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	50                   	push   %eax
  8007ce:	ff d2                	call   *%edx
  8007d0:	83 c4 10             	add    $0x10,%esp
}
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007d8:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007dd:	8b 40 48             	mov    0x48(%eax),%eax
  8007e0:	83 ec 04             	sub    $0x4,%esp
  8007e3:	53                   	push   %ebx
  8007e4:	50                   	push   %eax
  8007e5:	68 6c 23 80 00       	push   $0x80236c
  8007ea:	e8 e7 0d 00 00       	call   8015d6 <cprintf>
		return -E_INVAL;
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f7:	eb da                	jmp    8007d3 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8007f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007fe:	eb d3                	jmp    8007d3 <ftruncate+0x56>

00800800 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800800:	f3 0f 1e fb          	endbr32 
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	83 ec 1c             	sub    $0x1c,%esp
  80080b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800811:	50                   	push   %eax
  800812:	ff 75 08             	pushl  0x8(%ebp)
  800815:	e8 52 fb ff ff       	call   80036c <fd_lookup>
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	85 c0                	test   %eax,%eax
  80081f:	78 4b                	js     80086c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800827:	50                   	push   %eax
  800828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082b:	ff 30                	pushl  (%eax)
  80082d:	e8 8e fb ff ff       	call   8003c0 <dev_lookup>
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	85 c0                	test   %eax,%eax
  800837:	78 33                	js     80086c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800840:	74 2f                	je     800871 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800842:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800845:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80084c:	00 00 00 
	stat->st_isdir = 0;
  80084f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800856:	00 00 00 
	stat->st_dev = dev;
  800859:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	ff 75 f0             	pushl  -0x10(%ebp)
  800866:	ff 50 14             	call   *0x14(%eax)
  800869:	83 c4 10             	add    $0x10,%esp
}
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
		return -E_NOT_SUPP;
  800871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800876:	eb f4                	jmp    80086c <fstat+0x6c>

00800878 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800878:	f3 0f 1e fb          	endbr32 
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	6a 00                	push   $0x0
  800886:	ff 75 08             	pushl  0x8(%ebp)
  800889:	e8 01 02 00 00       	call   800a8f <open>
  80088e:	89 c3                	mov    %eax,%ebx
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	85 c0                	test   %eax,%eax
  800895:	78 1b                	js     8008b2 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	ff 75 0c             	pushl  0xc(%ebp)
  80089d:	50                   	push   %eax
  80089e:	e8 5d ff ff ff       	call   800800 <fstat>
  8008a3:	89 c6                	mov    %eax,%esi
	close(fd);
  8008a5:	89 1c 24             	mov    %ebx,(%esp)
  8008a8:	e8 fd fb ff ff       	call   8004aa <close>
	return r;
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	89 f3                	mov    %esi,%ebx
}
  8008b2:	89 d8                	mov    %ebx,%eax
  8008b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	89 c6                	mov    %eax,%esi
  8008c2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008c4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008cb:	74 27                	je     8008f4 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008cd:	6a 07                	push   $0x7
  8008cf:	68 00 50 80 00       	push   $0x805000
  8008d4:	56                   	push   %esi
  8008d5:	ff 35 00 40 80 00    	pushl  0x804000
  8008db:	e8 27 17 00 00       	call   802007 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008e0:	83 c4 0c             	add    $0xc,%esp
  8008e3:	6a 00                	push   $0x0
  8008e5:	53                   	push   %ebx
  8008e6:	6a 00                	push   $0x0
  8008e8:	e8 ad 16 00 00       	call   801f9a <ipc_recv>
}
  8008ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008f4:	83 ec 0c             	sub    $0xc,%esp
  8008f7:	6a 01                	push   $0x1
  8008f9:	e8 61 17 00 00       	call   80205f <ipc_find_env>
  8008fe:	a3 00 40 80 00       	mov    %eax,0x804000
  800903:	83 c4 10             	add    $0x10,%esp
  800906:	eb c5                	jmp    8008cd <fsipc+0x12>

00800908 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800908:	f3 0f 1e fb          	endbr32 
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 40 0c             	mov    0xc(%eax),%eax
  800918:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800925:	ba 00 00 00 00       	mov    $0x0,%edx
  80092a:	b8 02 00 00 00       	mov    $0x2,%eax
  80092f:	e8 87 ff ff ff       	call   8008bb <fsipc>
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <devfile_flush>:
{
  800936:	f3 0f 1e fb          	endbr32 
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 40 0c             	mov    0xc(%eax),%eax
  800946:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80094b:	ba 00 00 00 00       	mov    $0x0,%edx
  800950:	b8 06 00 00 00       	mov    $0x6,%eax
  800955:	e8 61 ff ff ff       	call   8008bb <fsipc>
}
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <devfile_stat>:
{
  80095c:	f3 0f 1e fb          	endbr32 
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	83 ec 04             	sub    $0x4,%esp
  800967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 40 0c             	mov    0xc(%eax),%eax
  800970:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800975:	ba 00 00 00 00       	mov    $0x0,%edx
  80097a:	b8 05 00 00 00       	mov    $0x5,%eax
  80097f:	e8 37 ff ff ff       	call   8008bb <fsipc>
  800984:	85 c0                	test   %eax,%eax
  800986:	78 2c                	js     8009b4 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800988:	83 ec 08             	sub    $0x8,%esp
  80098b:	68 00 50 80 00       	push   $0x805000
  800990:	53                   	push   %ebx
  800991:	e8 4a 12 00 00       	call   801be0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800996:	a1 80 50 80 00       	mov    0x805080,%eax
  80099b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009a6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <devfile_write>:
{
  8009b9:	f3 0f 1e fb          	endbr32 
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 0c             	sub    $0xc,%esp
  8009c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009cb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009d0:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8009d9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009df:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e4:	50                   	push   %eax
  8009e5:	ff 75 0c             	pushl  0xc(%ebp)
  8009e8:	68 08 50 80 00       	push   $0x805008
  8009ed:	e8 ec 13 00 00       	call   801dde <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8009f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8009fc:	e8 ba fe ff ff       	call   8008bb <fsipc>
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <devfile_read>:
{
  800a03:	f3 0f 1e fb          	endbr32 
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 40 0c             	mov    0xc(%eax),%eax
  800a15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a1a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a20:	ba 00 00 00 00       	mov    $0x0,%edx
  800a25:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2a:	e8 8c fe ff ff       	call   8008bb <fsipc>
  800a2f:	89 c3                	mov    %eax,%ebx
  800a31:	85 c0                	test   %eax,%eax
  800a33:	78 1f                	js     800a54 <devfile_read+0x51>
	assert(r <= n);
  800a35:	39 f0                	cmp    %esi,%eax
  800a37:	77 24                	ja     800a5d <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a39:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3e:	7f 36                	jg     800a76 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a40:	83 ec 04             	sub    $0x4,%esp
  800a43:	50                   	push   %eax
  800a44:	68 00 50 80 00       	push   $0x805000
  800a49:	ff 75 0c             	pushl  0xc(%ebp)
  800a4c:	e8 8d 13 00 00       	call   801dde <memmove>
	return r;
  800a51:	83 c4 10             	add    $0x10,%esp
}
  800a54:	89 d8                	mov    %ebx,%eax
  800a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    
	assert(r <= n);
  800a5d:	68 dc 23 80 00       	push   $0x8023dc
  800a62:	68 e3 23 80 00       	push   $0x8023e3
  800a67:	68 8c 00 00 00       	push   $0x8c
  800a6c:	68 f8 23 80 00       	push   $0x8023f8
  800a71:	e8 79 0a 00 00       	call   8014ef <_panic>
	assert(r <= PGSIZE);
  800a76:	68 03 24 80 00       	push   $0x802403
  800a7b:	68 e3 23 80 00       	push   $0x8023e3
  800a80:	68 8d 00 00 00       	push   $0x8d
  800a85:	68 f8 23 80 00       	push   $0x8023f8
  800a8a:	e8 60 0a 00 00       	call   8014ef <_panic>

00800a8f <open>:
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 1c             	sub    $0x1c,%esp
  800a9b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9e:	56                   	push   %esi
  800a9f:	e8 f9 10 00 00       	call   801b9d <strlen>
  800aa4:	83 c4 10             	add    $0x10,%esp
  800aa7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aac:	7f 6c                	jg     800b1a <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab4:	50                   	push   %eax
  800ab5:	e8 5c f8 ff ff       	call   800316 <fd_alloc>
  800aba:	89 c3                	mov    %eax,%ebx
  800abc:	83 c4 10             	add    $0x10,%esp
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	78 3c                	js     800aff <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ac3:	83 ec 08             	sub    $0x8,%esp
  800ac6:	56                   	push   %esi
  800ac7:	68 00 50 80 00       	push   $0x805000
  800acc:	e8 0f 11 00 00       	call   801be0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae1:	e8 d5 fd ff ff       	call   8008bb <fsipc>
  800ae6:	89 c3                	mov    %eax,%ebx
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	78 19                	js     800b08 <open+0x79>
	return fd2num(fd);
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	ff 75 f4             	pushl  -0xc(%ebp)
  800af5:	e8 ed f7 ff ff       	call   8002e7 <fd2num>
  800afa:	89 c3                	mov    %eax,%ebx
  800afc:	83 c4 10             	add    $0x10,%esp
}
  800aff:	89 d8                	mov    %ebx,%eax
  800b01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    
		fd_close(fd, 0);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b10:	e8 0a f9 ff ff       	call   80041f <fd_close>
		return r;
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	eb e5                	jmp    800aff <open+0x70>
		return -E_BAD_PATH;
  800b1a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b1f:	eb de                	jmp    800aff <open+0x70>

00800b21 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b21:	f3 0f 1e fb          	endbr32 
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 08 00 00 00       	mov    $0x8,%eax
  800b35:	e8 81 fd ff ff       	call   8008bb <fsipc>
}
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b46:	68 6f 24 80 00       	push   $0x80246f
  800b4b:	ff 75 0c             	pushl  0xc(%ebp)
  800b4e:	e8 8d 10 00 00       	call   801be0 <strcpy>
	return 0;
}
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <devsock_close>:
{
  800b5a:	f3 0f 1e fb          	endbr32 
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	53                   	push   %ebx
  800b62:	83 ec 10             	sub    $0x10,%esp
  800b65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b68:	53                   	push   %ebx
  800b69:	e8 2e 15 00 00       	call   80209c <pageref>
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	83 c4 10             	add    $0x10,%esp
		return 0;
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800b78:	83 fa 01             	cmp    $0x1,%edx
  800b7b:	74 05                	je     800b82 <devsock_close+0x28>
}
  800b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	ff 73 0c             	pushl  0xc(%ebx)
  800b88:	e8 e3 02 00 00       	call   800e70 <nsipc_close>
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	eb eb                	jmp    800b7d <devsock_close+0x23>

00800b92 <devsock_write>:
{
  800b92:	f3 0f 1e fb          	endbr32 
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800b9c:	6a 00                	push   $0x0
  800b9e:	ff 75 10             	pushl  0x10(%ebp)
  800ba1:	ff 75 0c             	pushl  0xc(%ebp)
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba7:	ff 70 0c             	pushl  0xc(%eax)
  800baa:	e8 b5 03 00 00       	call   800f64 <nsipc_send>
}
  800baf:	c9                   	leave  
  800bb0:	c3                   	ret    

00800bb1 <devsock_read>:
{
  800bb1:	f3 0f 1e fb          	endbr32 
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bbb:	6a 00                	push   $0x0
  800bbd:	ff 75 10             	pushl  0x10(%ebp)
  800bc0:	ff 75 0c             	pushl  0xc(%ebp)
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	ff 70 0c             	pushl  0xc(%eax)
  800bc9:	e8 1f 03 00 00       	call   800eed <nsipc_recv>
}
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <fd2sockid>:
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bd6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bd9:	52                   	push   %edx
  800bda:	50                   	push   %eax
  800bdb:	e8 8c f7 ff ff       	call   80036c <fd_lookup>
  800be0:	83 c4 10             	add    $0x10,%esp
  800be3:	85 c0                	test   %eax,%eax
  800be5:	78 10                	js     800bf7 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bea:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800bf0:	39 08                	cmp    %ecx,(%eax)
  800bf2:	75 05                	jne    800bf9 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800bf4:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    
		return -E_NOT_SUPP;
  800bf9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bfe:	eb f7                	jmp    800bf7 <fd2sockid+0x27>

00800c00 <alloc_sockfd>:
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 1c             	sub    $0x1c,%esp
  800c08:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0d:	50                   	push   %eax
  800c0e:	e8 03 f7 ff ff       	call   800316 <fd_alloc>
  800c13:	89 c3                	mov    %eax,%ebx
  800c15:	83 c4 10             	add    $0x10,%esp
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	78 43                	js     800c5f <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c1c:	83 ec 04             	sub    $0x4,%esp
  800c1f:	68 07 04 00 00       	push   $0x407
  800c24:	ff 75 f4             	pushl  -0xc(%ebp)
  800c27:	6a 00                	push   $0x0
  800c29:	e8 22 f5 ff ff       	call   800150 <sys_page_alloc>
  800c2e:	89 c3                	mov    %eax,%ebx
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	85 c0                	test   %eax,%eax
  800c35:	78 28                	js     800c5f <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3a:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c40:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c45:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c4c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	e8 8f f6 ff ff       	call   8002e7 <fd2num>
  800c58:	89 c3                	mov    %eax,%ebx
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	eb 0c                	jmp    800c6b <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	56                   	push   %esi
  800c63:	e8 08 02 00 00       	call   800e70 <nsipc_close>
		return r;
  800c68:	83 c4 10             	add    $0x10,%esp
}
  800c6b:	89 d8                	mov    %ebx,%eax
  800c6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <accept>:
{
  800c74:	f3 0f 1e fb          	endbr32 
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	e8 4a ff ff ff       	call   800bd0 <fd2sockid>
  800c86:	85 c0                	test   %eax,%eax
  800c88:	78 1b                	js     800ca5 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800c8a:	83 ec 04             	sub    $0x4,%esp
  800c8d:	ff 75 10             	pushl  0x10(%ebp)
  800c90:	ff 75 0c             	pushl  0xc(%ebp)
  800c93:	50                   	push   %eax
  800c94:	e8 22 01 00 00       	call   800dbb <nsipc_accept>
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	78 05                	js     800ca5 <accept+0x31>
	return alloc_sockfd(r);
  800ca0:	e8 5b ff ff ff       	call   800c00 <alloc_sockfd>
}
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <bind>:
{
  800ca7:	f3 0f 1e fb          	endbr32 
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	e8 17 ff ff ff       	call   800bd0 <fd2sockid>
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	78 12                	js     800ccf <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800cbd:	83 ec 04             	sub    $0x4,%esp
  800cc0:	ff 75 10             	pushl  0x10(%ebp)
  800cc3:	ff 75 0c             	pushl  0xc(%ebp)
  800cc6:	50                   	push   %eax
  800cc7:	e8 45 01 00 00       	call   800e11 <nsipc_bind>
  800ccc:	83 c4 10             	add    $0x10,%esp
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <shutdown>:
{
  800cd1:	f3 0f 1e fb          	endbr32 
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	e8 ed fe ff ff       	call   800bd0 <fd2sockid>
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	78 0f                	js     800cf6 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800ce7:	83 ec 08             	sub    $0x8,%esp
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	50                   	push   %eax
  800cee:	e8 57 01 00 00       	call   800e4a <nsipc_shutdown>
  800cf3:	83 c4 10             	add    $0x10,%esp
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <connect>:
{
  800cf8:	f3 0f 1e fb          	endbr32 
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	e8 c6 fe ff ff       	call   800bd0 <fd2sockid>
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	78 12                	js     800d20 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d0e:	83 ec 04             	sub    $0x4,%esp
  800d11:	ff 75 10             	pushl  0x10(%ebp)
  800d14:	ff 75 0c             	pushl  0xc(%ebp)
  800d17:	50                   	push   %eax
  800d18:	e8 71 01 00 00       	call   800e8e <nsipc_connect>
  800d1d:	83 c4 10             	add    $0x10,%esp
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <listen>:
{
  800d22:	f3 0f 1e fb          	endbr32 
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	e8 9c fe ff ff       	call   800bd0 <fd2sockid>
  800d34:	85 c0                	test   %eax,%eax
  800d36:	78 0f                	js     800d47 <listen+0x25>
	return nsipc_listen(r, backlog);
  800d38:	83 ec 08             	sub    $0x8,%esp
  800d3b:	ff 75 0c             	pushl  0xc(%ebp)
  800d3e:	50                   	push   %eax
  800d3f:	e8 83 01 00 00       	call   800ec7 <nsipc_listen>
  800d44:	83 c4 10             	add    $0x10,%esp
}
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d49:	f3 0f 1e fb          	endbr32 
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d53:	ff 75 10             	pushl  0x10(%ebp)
  800d56:	ff 75 0c             	pushl  0xc(%ebp)
  800d59:	ff 75 08             	pushl  0x8(%ebp)
  800d5c:	e8 65 02 00 00       	call   800fc6 <nsipc_socket>
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	85 c0                	test   %eax,%eax
  800d66:	78 05                	js     800d6d <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d68:	e8 93 fe ff ff       	call   800c00 <alloc_sockfd>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	53                   	push   %ebx
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d78:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d7f:	74 26                	je     800da7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d81:	6a 07                	push   $0x7
  800d83:	68 00 60 80 00       	push   $0x806000
  800d88:	53                   	push   %ebx
  800d89:	ff 35 04 40 80 00    	pushl  0x804004
  800d8f:	e8 73 12 00 00       	call   802007 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800d94:	83 c4 0c             	add    $0xc,%esp
  800d97:	6a 00                	push   $0x0
  800d99:	6a 00                	push   $0x0
  800d9b:	6a 00                	push   $0x0
  800d9d:	e8 f8 11 00 00       	call   801f9a <ipc_recv>
}
  800da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	6a 02                	push   $0x2
  800dac:	e8 ae 12 00 00       	call   80205f <ipc_find_env>
  800db1:	a3 04 40 80 00       	mov    %eax,0x804004
  800db6:	83 c4 10             	add    $0x10,%esp
  800db9:	eb c6                	jmp    800d81 <nsipc+0x12>

00800dbb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dbb:	f3 0f 1e fb          	endbr32 
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dcf:	8b 06                	mov    (%esi),%eax
  800dd1:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddb:	e8 8f ff ff ff       	call   800d6f <nsipc>
  800de0:	89 c3                	mov    %eax,%ebx
  800de2:	85 c0                	test   %eax,%eax
  800de4:	79 09                	jns    800def <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	ff 35 10 60 80 00    	pushl  0x806010
  800df8:	68 00 60 80 00       	push   $0x806000
  800dfd:	ff 75 0c             	pushl  0xc(%ebp)
  800e00:	e8 d9 0f 00 00       	call   801dde <memmove>
		*addrlen = ret->ret_addrlen;
  800e05:	a1 10 60 80 00       	mov    0x806010,%eax
  800e0a:	89 06                	mov    %eax,(%esi)
  800e0c:	83 c4 10             	add    $0x10,%esp
	return r;
  800e0f:	eb d5                	jmp    800de6 <nsipc_accept+0x2b>

00800e11 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e11:	f3 0f 1e fb          	endbr32 
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	53                   	push   %ebx
  800e19:	83 ec 08             	sub    $0x8,%esp
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e27:	53                   	push   %ebx
  800e28:	ff 75 0c             	pushl  0xc(%ebp)
  800e2b:	68 04 60 80 00       	push   $0x806004
  800e30:	e8 a9 0f 00 00       	call   801dde <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e35:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e3b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e40:	e8 2a ff ff ff       	call   800d6f <nsipc>
}
  800e45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e4a:	f3 0f 1e fb          	endbr32 
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e64:	b8 03 00 00 00       	mov    $0x3,%eax
  800e69:	e8 01 ff ff ff       	call   800d6f <nsipc>
}
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <nsipc_close>:

int
nsipc_close(int s)
{
  800e70:	f3 0f 1e fb          	endbr32 
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e82:	b8 04 00 00 00       	mov    $0x4,%eax
  800e87:	e8 e3 fe ff ff       	call   800d6f <nsipc>
}
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e8e:	f3 0f 1e fb          	endbr32 
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	53                   	push   %ebx
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ea4:	53                   	push   %ebx
  800ea5:	ff 75 0c             	pushl  0xc(%ebp)
  800ea8:	68 04 60 80 00       	push   $0x806004
  800ead:	e8 2c 0f 00 00       	call   801dde <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eb2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eb8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebd:	e8 ad fe ff ff       	call   800d6f <nsipc>
}
  800ec2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ec7:	f3 0f 1e fb          	endbr32 
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ee1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee6:	e8 84 fe ff ff       	call   800d6f <nsipc>
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800eed:	f3 0f 1e fb          	endbr32 
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f01:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f07:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f0f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f14:	e8 56 fe ff ff       	call   800d6f <nsipc>
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	78 26                	js     800f45 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f1f:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f25:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f2a:	0f 4e c6             	cmovle %esi,%eax
  800f2d:	39 c3                	cmp    %eax,%ebx
  800f2f:	7f 1d                	jg     800f4e <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f31:	83 ec 04             	sub    $0x4,%esp
  800f34:	53                   	push   %ebx
  800f35:	68 00 60 80 00       	push   $0x806000
  800f3a:	ff 75 0c             	pushl  0xc(%ebp)
  800f3d:	e8 9c 0e 00 00       	call   801dde <memmove>
  800f42:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f45:	89 d8                	mov    %ebx,%eax
  800f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f4e:	68 7b 24 80 00       	push   $0x80247b
  800f53:	68 e3 23 80 00       	push   $0x8023e3
  800f58:	6a 62                	push   $0x62
  800f5a:	68 90 24 80 00       	push   $0x802490
  800f5f:	e8 8b 05 00 00       	call   8014ef <_panic>

00800f64 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f64:	f3 0f 1e fb          	endbr32 
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f7a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f80:	7f 2e                	jg     800fb0 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	53                   	push   %ebx
  800f86:	ff 75 0c             	pushl  0xc(%ebp)
  800f89:	68 0c 60 80 00       	push   $0x80600c
  800f8e:	e8 4b 0e 00 00       	call   801dde <memmove>
	nsipcbuf.send.req_size = size;
  800f93:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800f99:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fa1:	b8 08 00 00 00       	mov    $0x8,%eax
  800fa6:	e8 c4 fd ff ff       	call   800d6f <nsipc>
}
  800fab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    
	assert(size < 1600);
  800fb0:	68 9c 24 80 00       	push   $0x80249c
  800fb5:	68 e3 23 80 00       	push   $0x8023e3
  800fba:	6a 6d                	push   $0x6d
  800fbc:	68 90 24 80 00       	push   $0x802490
  800fc1:	e8 29 05 00 00       	call   8014ef <_panic>

00800fc6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fc6:	f3 0f 1e fb          	endbr32 
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdb:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fe8:	b8 09 00 00 00       	mov    $0x9,%eax
  800fed:	e8 7d fd ff ff       	call   800d6f <nsipc>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff4:	f3 0f 1e fb          	endbr32 
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	ff 75 08             	pushl  0x8(%ebp)
  801006:	e8 f0 f2 ff ff       	call   8002fb <fd2data>
  80100b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	68 a8 24 80 00       	push   $0x8024a8
  801015:	53                   	push   %ebx
  801016:	e8 c5 0b 00 00       	call   801be0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101b:	8b 46 04             	mov    0x4(%esi),%eax
  80101e:	2b 06                	sub    (%esi),%eax
  801020:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801026:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102d:	00 00 00 
	stat->st_dev = &devpipe;
  801030:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801037:	30 80 00 
	return 0;
}
  80103a:	b8 00 00 00 00       	mov    $0x0,%eax
  80103f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801046:	f3 0f 1e fb          	endbr32 
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	53                   	push   %ebx
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801054:	53                   	push   %ebx
  801055:	6a 00                	push   $0x0
  801057:	e8 3f f1 ff ff       	call   80019b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80105c:	89 1c 24             	mov    %ebx,(%esp)
  80105f:	e8 97 f2 ff ff       	call   8002fb <fd2data>
  801064:	83 c4 08             	add    $0x8,%esp
  801067:	50                   	push   %eax
  801068:	6a 00                	push   $0x0
  80106a:	e8 2c f1 ff ff       	call   80019b <sys_page_unmap>
}
  80106f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <_pipeisclosed>:
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 1c             	sub    $0x1c,%esp
  80107d:	89 c7                	mov    %eax,%edi
  80107f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801081:	a1 08 40 80 00       	mov    0x804008,%eax
  801086:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	57                   	push   %edi
  80108d:	e8 0a 10 00 00       	call   80209c <pageref>
  801092:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801095:	89 34 24             	mov    %esi,(%esp)
  801098:	e8 ff 0f 00 00       	call   80209c <pageref>
		nn = thisenv->env_runs;
  80109d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010a3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	39 cb                	cmp    %ecx,%ebx
  8010ab:	74 1b                	je     8010c8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010ad:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010b0:	75 cf                	jne    801081 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b2:	8b 42 58             	mov    0x58(%edx),%eax
  8010b5:	6a 01                	push   $0x1
  8010b7:	50                   	push   %eax
  8010b8:	53                   	push   %ebx
  8010b9:	68 af 24 80 00       	push   $0x8024af
  8010be:	e8 13 05 00 00       	call   8015d6 <cprintf>
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	eb b9                	jmp    801081 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010cb:	0f 94 c0             	sete   %al
  8010ce:	0f b6 c0             	movzbl %al,%eax
}
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <devpipe_write>:
{
  8010d9:	f3 0f 1e fb          	endbr32 
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 28             	sub    $0x28,%esp
  8010e6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010e9:	56                   	push   %esi
  8010ea:	e8 0c f2 ff ff       	call   8002fb <fd2data>
  8010ef:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010fc:	74 4f                	je     80114d <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010fe:	8b 43 04             	mov    0x4(%ebx),%eax
  801101:	8b 0b                	mov    (%ebx),%ecx
  801103:	8d 51 20             	lea    0x20(%ecx),%edx
  801106:	39 d0                	cmp    %edx,%eax
  801108:	72 14                	jb     80111e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80110a:	89 da                	mov    %ebx,%edx
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	e8 61 ff ff ff       	call   801074 <_pipeisclosed>
  801113:	85 c0                	test   %eax,%eax
  801115:	75 3b                	jne    801152 <devpipe_write+0x79>
			sys_yield();
  801117:	e8 11 f0 ff ff       	call   80012d <sys_yield>
  80111c:	eb e0                	jmp    8010fe <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80111e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801121:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801125:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801128:	89 c2                	mov    %eax,%edx
  80112a:	c1 fa 1f             	sar    $0x1f,%edx
  80112d:	89 d1                	mov    %edx,%ecx
  80112f:	c1 e9 1b             	shr    $0x1b,%ecx
  801132:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801135:	83 e2 1f             	and    $0x1f,%edx
  801138:	29 ca                	sub    %ecx,%edx
  80113a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80113e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801142:	83 c0 01             	add    $0x1,%eax
  801145:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801148:	83 c7 01             	add    $0x1,%edi
  80114b:	eb ac                	jmp    8010f9 <devpipe_write+0x20>
	return i;
  80114d:	8b 45 10             	mov    0x10(%ebp),%eax
  801150:	eb 05                	jmp    801157 <devpipe_write+0x7e>
				return 0;
  801152:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <devpipe_read>:
{
  80115f:	f3 0f 1e fb          	endbr32 
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	57                   	push   %edi
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 18             	sub    $0x18,%esp
  80116c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80116f:	57                   	push   %edi
  801170:	e8 86 f1 ff ff       	call   8002fb <fd2data>
  801175:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	be 00 00 00 00       	mov    $0x0,%esi
  80117f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801182:	75 14                	jne    801198 <devpipe_read+0x39>
	return i;
  801184:	8b 45 10             	mov    0x10(%ebp),%eax
  801187:	eb 02                	jmp    80118b <devpipe_read+0x2c>
				return i;
  801189:	89 f0                	mov    %esi,%eax
}
  80118b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    
			sys_yield();
  801193:	e8 95 ef ff ff       	call   80012d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801198:	8b 03                	mov    (%ebx),%eax
  80119a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80119d:	75 18                	jne    8011b7 <devpipe_read+0x58>
			if (i > 0)
  80119f:	85 f6                	test   %esi,%esi
  8011a1:	75 e6                	jne    801189 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011a3:	89 da                	mov    %ebx,%edx
  8011a5:	89 f8                	mov    %edi,%eax
  8011a7:	e8 c8 fe ff ff       	call   801074 <_pipeisclosed>
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 e3                	je     801193 <devpipe_read+0x34>
				return 0;
  8011b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b5:	eb d4                	jmp    80118b <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b7:	99                   	cltd   
  8011b8:	c1 ea 1b             	shr    $0x1b,%edx
  8011bb:	01 d0                	add    %edx,%eax
  8011bd:	83 e0 1f             	and    $0x1f,%eax
  8011c0:	29 d0                	sub    %edx,%eax
  8011c2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ca:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011cd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d0:	83 c6 01             	add    $0x1,%esi
  8011d3:	eb aa                	jmp    80117f <devpipe_read+0x20>

008011d5 <pipe>:
{
  8011d5:	f3 0f 1e fb          	endbr32 
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	e8 2c f1 ff ff       	call   800316 <fd_alloc>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	0f 88 23 01 00 00    	js     80131a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	68 07 04 00 00       	push   $0x407
  8011ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801202:	6a 00                	push   $0x0
  801204:	e8 47 ef ff ff       	call   800150 <sys_page_alloc>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	0f 88 04 01 00 00    	js     80131a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	e8 f4 f0 ff ff       	call   800316 <fd_alloc>
  801222:	89 c3                	mov    %eax,%ebx
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	0f 88 db 00 00 00    	js     80130a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	68 07 04 00 00       	push   $0x407
  801237:	ff 75 f0             	pushl  -0x10(%ebp)
  80123a:	6a 00                	push   $0x0
  80123c:	e8 0f ef ff ff       	call   800150 <sys_page_alloc>
  801241:	89 c3                	mov    %eax,%ebx
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	0f 88 bc 00 00 00    	js     80130a <pipe+0x135>
	va = fd2data(fd0);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	ff 75 f4             	pushl  -0xc(%ebp)
  801254:	e8 a2 f0 ff ff       	call   8002fb <fd2data>
  801259:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125b:	83 c4 0c             	add    $0xc,%esp
  80125e:	68 07 04 00 00       	push   $0x407
  801263:	50                   	push   %eax
  801264:	6a 00                	push   $0x0
  801266:	e8 e5 ee ff ff       	call   800150 <sys_page_alloc>
  80126b:	89 c3                	mov    %eax,%ebx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	0f 88 82 00 00 00    	js     8012fa <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801278:	83 ec 0c             	sub    $0xc,%esp
  80127b:	ff 75 f0             	pushl  -0x10(%ebp)
  80127e:	e8 78 f0 ff ff       	call   8002fb <fd2data>
  801283:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128a:	50                   	push   %eax
  80128b:	6a 00                	push   $0x0
  80128d:	56                   	push   %esi
  80128e:	6a 00                	push   $0x0
  801290:	e8 e1 ee ff ff       	call   800176 <sys_page_map>
  801295:	89 c3                	mov    %eax,%ebx
  801297:	83 c4 20             	add    $0x20,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 4e                	js     8012ec <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80129e:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012c1:	83 ec 0c             	sub    $0xc,%esp
  8012c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c7:	e8 1b f0 ff ff       	call   8002e7 <fd2num>
  8012cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d1:	83 c4 04             	add    $0x4,%esp
  8012d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d7:	e8 0b f0 ff ff       	call   8002e7 <fd2num>
  8012dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012df:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ea:	eb 2e                	jmp    80131a <pipe+0x145>
	sys_page_unmap(0, va);
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	56                   	push   %esi
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 a4 ee ff ff       	call   80019b <sys_page_unmap>
  8012f7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801300:	6a 00                	push   $0x0
  801302:	e8 94 ee ff ff       	call   80019b <sys_page_unmap>
  801307:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	ff 75 f4             	pushl  -0xc(%ebp)
  801310:	6a 00                	push   $0x0
  801312:	e8 84 ee ff ff       	call   80019b <sys_page_unmap>
  801317:	83 c4 10             	add    $0x10,%esp
}
  80131a:	89 d8                	mov    %ebx,%eax
  80131c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <pipeisclosed>:
{
  801323:	f3 0f 1e fb          	endbr32 
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 75 08             	pushl  0x8(%ebp)
  801334:	e8 33 f0 ff ff       	call   80036c <fd_lookup>
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 18                	js     801358 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	ff 75 f4             	pushl  -0xc(%ebp)
  801346:	e8 b0 ef ff ff       	call   8002fb <fd2data>
  80134b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801350:	e8 1f fd ff ff       	call   801074 <_pipeisclosed>
  801355:	83 c4 10             	add    $0x10,%esp
}
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80135a:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
  801363:	c3                   	ret    

00801364 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801364:	f3 0f 1e fb          	endbr32 
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80136e:	68 c7 24 80 00       	push   $0x8024c7
  801373:	ff 75 0c             	pushl  0xc(%ebp)
  801376:	e8 65 08 00 00       	call   801be0 <strcpy>
	return 0;
}
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <devcons_write>:
{
  801382:	f3 0f 1e fb          	endbr32 
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801392:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801397:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80139d:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a0:	73 31                	jae    8013d3 <devcons_write+0x51>
		m = n - tot;
  8013a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a5:	29 f3                	sub    %esi,%ebx
  8013a7:	83 fb 7f             	cmp    $0x7f,%ebx
  8013aa:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013af:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	89 f0                	mov    %esi,%eax
  8013b8:	03 45 0c             	add    0xc(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	57                   	push   %edi
  8013bd:	e8 1c 0a 00 00       	call   801dde <memmove>
		sys_cputs(buf, m);
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	53                   	push   %ebx
  8013c6:	57                   	push   %edi
  8013c7:	e8 d5 ec ff ff       	call   8000a1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013cc:	01 de                	add    %ebx,%esi
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	eb ca                	jmp    80139d <devcons_write+0x1b>
}
  8013d3:	89 f0                	mov    %esi,%eax
  8013d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <devcons_read>:
{
  8013dd:	f3 0f 1e fb          	endbr32 
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f0:	74 21                	je     801413 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8013f2:	e8 cc ec ff ff       	call   8000c3 <sys_cgetc>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	75 07                	jne    801402 <devcons_read+0x25>
		sys_yield();
  8013fb:	e8 2d ed ff ff       	call   80012d <sys_yield>
  801400:	eb f0                	jmp    8013f2 <devcons_read+0x15>
	if (c < 0)
  801402:	78 0f                	js     801413 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801404:	83 f8 04             	cmp    $0x4,%eax
  801407:	74 0c                	je     801415 <devcons_read+0x38>
	*(char*)vbuf = c;
  801409:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140c:	88 02                	mov    %al,(%edx)
	return 1;
  80140e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    
		return 0;
  801415:	b8 00 00 00 00       	mov    $0x0,%eax
  80141a:	eb f7                	jmp    801413 <devcons_read+0x36>

0080141c <cputchar>:
{
  80141c:	f3 0f 1e fb          	endbr32 
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80142c:	6a 01                	push   $0x1
  80142e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	e8 6a ec ff ff       	call   8000a1 <sys_cputs>
}
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <getchar>:
{
  80143c:	f3 0f 1e fb          	endbr32 
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801446:	6a 01                	push   $0x1
  801448:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144b:	50                   	push   %eax
  80144c:	6a 00                	push   $0x0
  80144e:	e8 a1 f1 ff ff       	call   8005f4 <read>
	if (r < 0)
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 06                	js     801460 <getchar+0x24>
	if (r < 1)
  80145a:	74 06                	je     801462 <getchar+0x26>
	return c;
  80145c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    
		return -E_EOF;
  801462:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801467:	eb f7                	jmp    801460 <getchar+0x24>

00801469 <iscons>:
{
  801469:	f3 0f 1e fb          	endbr32 
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801473:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	ff 75 08             	pushl  0x8(%ebp)
  80147a:	e8 ed ee ff ff       	call   80036c <fd_lookup>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 11                	js     801497 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801486:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801489:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80148f:	39 10                	cmp    %edx,(%eax)
  801491:	0f 94 c0             	sete   %al
  801494:	0f b6 c0             	movzbl %al,%eax
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <opencons>:
{
  801499:	f3 0f 1e fb          	endbr32 
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	e8 6a ee ff ff       	call   800316 <fd_alloc>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 3a                	js     8014ed <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b3:	83 ec 04             	sub    $0x4,%esp
  8014b6:	68 07 04 00 00       	push   $0x407
  8014bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014be:	6a 00                	push   $0x0
  8014c0:	e8 8b ec ff ff       	call   800150 <sys_page_alloc>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 21                	js     8014ed <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	50                   	push   %eax
  8014e5:	e8 fd ed ff ff       	call   8002e7 <fd2num>
  8014ea:	83 c4 10             	add    $0x10,%esp
}
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ef:	f3 0f 1e fb          	endbr32 
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014fb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801501:	e8 04 ec ff ff       	call   80010a <sys_getenvid>
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	ff 75 0c             	pushl  0xc(%ebp)
  80150c:	ff 75 08             	pushl  0x8(%ebp)
  80150f:	56                   	push   %esi
  801510:	50                   	push   %eax
  801511:	68 d4 24 80 00       	push   $0x8024d4
  801516:	e8 bb 00 00 00       	call   8015d6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80151b:	83 c4 18             	add    $0x18,%esp
  80151e:	53                   	push   %ebx
  80151f:	ff 75 10             	pushl  0x10(%ebp)
  801522:	e8 5a 00 00 00       	call   801581 <vcprintf>
	cprintf("\n");
  801527:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  80152e:	e8 a3 00 00 00       	call   8015d6 <cprintf>
  801533:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801536:	cc                   	int3   
  801537:	eb fd                	jmp    801536 <_panic+0x47>

00801539 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801539:	f3 0f 1e fb          	endbr32 
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 04             	sub    $0x4,%esp
  801544:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801547:	8b 13                	mov    (%ebx),%edx
  801549:	8d 42 01             	lea    0x1(%edx),%eax
  80154c:	89 03                	mov    %eax,(%ebx)
  80154e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801551:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801555:	3d ff 00 00 00       	cmp    $0xff,%eax
  80155a:	74 09                	je     801565 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80155c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801560:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801563:	c9                   	leave  
  801564:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	68 ff 00 00 00       	push   $0xff
  80156d:	8d 43 08             	lea    0x8(%ebx),%eax
  801570:	50                   	push   %eax
  801571:	e8 2b eb ff ff       	call   8000a1 <sys_cputs>
		b->idx = 0;
  801576:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	eb db                	jmp    80155c <putch+0x23>

00801581 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801581:	f3 0f 1e fb          	endbr32 
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80158e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801595:	00 00 00 
	b.cnt = 0;
  801598:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80159f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	ff 75 08             	pushl  0x8(%ebp)
  8015a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	68 39 15 80 00       	push   $0x801539
  8015b4:	e8 20 01 00 00       	call   8016d9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	e8 d3 ea ff ff       	call   8000a1 <sys_cputs>

	return b.cnt;
}
  8015ce:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d6:	f3 0f 1e fb          	endbr32 
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015e3:	50                   	push   %eax
  8015e4:	ff 75 08             	pushl  0x8(%ebp)
  8015e7:	e8 95 ff ff ff       	call   801581 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 1c             	sub    $0x1c,%esp
  8015f7:	89 c7                	mov    %eax,%edi
  8015f9:	89 d6                	mov    %edx,%esi
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801601:	89 d1                	mov    %edx,%ecx
  801603:	89 c2                	mov    %eax,%edx
  801605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80160b:	8b 45 10             	mov    0x10(%ebp),%eax
  80160e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801611:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801614:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80161b:	39 c2                	cmp    %eax,%edx
  80161d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801620:	72 3e                	jb     801660 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	ff 75 18             	pushl  0x18(%ebp)
  801628:	83 eb 01             	sub    $0x1,%ebx
  80162b:	53                   	push   %ebx
  80162c:	50                   	push   %eax
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	ff 75 e4             	pushl  -0x1c(%ebp)
  801633:	ff 75 e0             	pushl  -0x20(%ebp)
  801636:	ff 75 dc             	pushl  -0x24(%ebp)
  801639:	ff 75 d8             	pushl  -0x28(%ebp)
  80163c:	e8 9f 0a 00 00       	call   8020e0 <__udivdi3>
  801641:	83 c4 18             	add    $0x18,%esp
  801644:	52                   	push   %edx
  801645:	50                   	push   %eax
  801646:	89 f2                	mov    %esi,%edx
  801648:	89 f8                	mov    %edi,%eax
  80164a:	e8 9f ff ff ff       	call   8015ee <printnum>
  80164f:	83 c4 20             	add    $0x20,%esp
  801652:	eb 13                	jmp    801667 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	56                   	push   %esi
  801658:	ff 75 18             	pushl  0x18(%ebp)
  80165b:	ff d7                	call   *%edi
  80165d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801660:	83 eb 01             	sub    $0x1,%ebx
  801663:	85 db                	test   %ebx,%ebx
  801665:	7f ed                	jg     801654 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	56                   	push   %esi
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801671:	ff 75 e0             	pushl  -0x20(%ebp)
  801674:	ff 75 dc             	pushl  -0x24(%ebp)
  801677:	ff 75 d8             	pushl  -0x28(%ebp)
  80167a:	e8 71 0b 00 00       	call   8021f0 <__umoddi3>
  80167f:	83 c4 14             	add    $0x14,%esp
  801682:	0f be 80 f7 24 80 00 	movsbl 0x8024f7(%eax),%eax
  801689:	50                   	push   %eax
  80168a:	ff d7                	call   *%edi
}
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5f                   	pop    %edi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801697:	f3 0f 1e fb          	endbr32 
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016a5:	8b 10                	mov    (%eax),%edx
  8016a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8016aa:	73 0a                	jae    8016b6 <sprintputch+0x1f>
		*b->buf++ = ch;
  8016ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016af:	89 08                	mov    %ecx,(%eax)
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	88 02                	mov    %al,(%edx)
}
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <printfmt>:
{
  8016b8:	f3 0f 1e fb          	endbr32 
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016c5:	50                   	push   %eax
  8016c6:	ff 75 10             	pushl  0x10(%ebp)
  8016c9:	ff 75 0c             	pushl  0xc(%ebp)
  8016cc:	ff 75 08             	pushl  0x8(%ebp)
  8016cf:	e8 05 00 00 00       	call   8016d9 <vprintfmt>
}
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <vprintfmt>:
{
  8016d9:	f3 0f 1e fb          	endbr32 
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	57                   	push   %edi
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 3c             	sub    $0x3c,%esp
  8016e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ec:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016ef:	e9 8e 03 00 00       	jmp    801a82 <vprintfmt+0x3a9>
		padc = ' ';
  8016f4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016ff:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801706:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80170d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801712:	8d 47 01             	lea    0x1(%edi),%eax
  801715:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801718:	0f b6 17             	movzbl (%edi),%edx
  80171b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80171e:	3c 55                	cmp    $0x55,%al
  801720:	0f 87 df 03 00 00    	ja     801b05 <vprintfmt+0x42c>
  801726:	0f b6 c0             	movzbl %al,%eax
  801729:	3e ff 24 85 40 26 80 	notrack jmp *0x802640(,%eax,4)
  801730:	00 
  801731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801734:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801738:	eb d8                	jmp    801712 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80173a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80173d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801741:	eb cf                	jmp    801712 <vprintfmt+0x39>
  801743:	0f b6 d2             	movzbl %dl,%edx
  801746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801749:	b8 00 00 00 00       	mov    $0x0,%eax
  80174e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801751:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801754:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801758:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80175b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80175e:	83 f9 09             	cmp    $0x9,%ecx
  801761:	77 55                	ja     8017b8 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801763:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801766:	eb e9                	jmp    801751 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801768:	8b 45 14             	mov    0x14(%ebp),%eax
  80176b:	8b 00                	mov    (%eax),%eax
  80176d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801770:	8b 45 14             	mov    0x14(%ebp),%eax
  801773:	8d 40 04             	lea    0x4(%eax),%eax
  801776:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801779:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80177c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801780:	79 90                	jns    801712 <vprintfmt+0x39>
				width = precision, precision = -1;
  801782:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801785:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801788:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80178f:	eb 81                	jmp    801712 <vprintfmt+0x39>
  801791:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801794:	85 c0                	test   %eax,%eax
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	0f 49 d0             	cmovns %eax,%edx
  80179e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017a4:	e9 69 ff ff ff       	jmp    801712 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017ac:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017b3:	e9 5a ff ff ff       	jmp    801712 <vprintfmt+0x39>
  8017b8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017be:	eb bc                	jmp    80177c <vprintfmt+0xa3>
			lflag++;
  8017c0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017c6:	e9 47 ff ff ff       	jmp    801712 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ce:	8d 78 04             	lea    0x4(%eax),%edi
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	53                   	push   %ebx
  8017d5:	ff 30                	pushl  (%eax)
  8017d7:	ff d6                	call   *%esi
			break;
  8017d9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017dc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017df:	e9 9b 02 00 00       	jmp    801a7f <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8017e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e7:	8d 78 04             	lea    0x4(%eax),%edi
  8017ea:	8b 00                	mov    (%eax),%eax
  8017ec:	99                   	cltd   
  8017ed:	31 d0                	xor    %edx,%eax
  8017ef:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f1:	83 f8 0f             	cmp    $0xf,%eax
  8017f4:	7f 23                	jg     801819 <vprintfmt+0x140>
  8017f6:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  8017fd:	85 d2                	test   %edx,%edx
  8017ff:	74 18                	je     801819 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801801:	52                   	push   %edx
  801802:	68 f5 23 80 00       	push   $0x8023f5
  801807:	53                   	push   %ebx
  801808:	56                   	push   %esi
  801809:	e8 aa fe ff ff       	call   8016b8 <printfmt>
  80180e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801811:	89 7d 14             	mov    %edi,0x14(%ebp)
  801814:	e9 66 02 00 00       	jmp    801a7f <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  801819:	50                   	push   %eax
  80181a:	68 0f 25 80 00       	push   $0x80250f
  80181f:	53                   	push   %ebx
  801820:	56                   	push   %esi
  801821:	e8 92 fe ff ff       	call   8016b8 <printfmt>
  801826:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801829:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80182c:	e9 4e 02 00 00       	jmp    801a7f <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801831:	8b 45 14             	mov    0x14(%ebp),%eax
  801834:	83 c0 04             	add    $0x4,%eax
  801837:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80183a:	8b 45 14             	mov    0x14(%ebp),%eax
  80183d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80183f:	85 d2                	test   %edx,%edx
  801841:	b8 08 25 80 00       	mov    $0x802508,%eax
  801846:	0f 45 c2             	cmovne %edx,%eax
  801849:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80184c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801850:	7e 06                	jle    801858 <vprintfmt+0x17f>
  801852:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801856:	75 0d                	jne    801865 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801858:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80185b:	89 c7                	mov    %eax,%edi
  80185d:	03 45 e0             	add    -0x20(%ebp),%eax
  801860:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801863:	eb 55                	jmp    8018ba <vprintfmt+0x1e1>
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	ff 75 d8             	pushl  -0x28(%ebp)
  80186b:	ff 75 cc             	pushl  -0x34(%ebp)
  80186e:	e8 46 03 00 00       	call   801bb9 <strnlen>
  801873:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801876:	29 c2                	sub    %eax,%edx
  801878:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801880:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801884:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801887:	85 ff                	test   %edi,%edi
  801889:	7e 11                	jle    80189c <vprintfmt+0x1c3>
					putch(padc, putdat);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	53                   	push   %ebx
  80188f:	ff 75 e0             	pushl  -0x20(%ebp)
  801892:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801894:	83 ef 01             	sub    $0x1,%edi
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	eb eb                	jmp    801887 <vprintfmt+0x1ae>
  80189c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80189f:	85 d2                	test   %edx,%edx
  8018a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a6:	0f 49 c2             	cmovns %edx,%eax
  8018a9:	29 c2                	sub    %eax,%edx
  8018ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018ae:	eb a8                	jmp    801858 <vprintfmt+0x17f>
					putch(ch, putdat);
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	53                   	push   %ebx
  8018b4:	52                   	push   %edx
  8018b5:	ff d6                	call   *%esi
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018bd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018bf:	83 c7 01             	add    $0x1,%edi
  8018c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018c6:	0f be d0             	movsbl %al,%edx
  8018c9:	85 d2                	test   %edx,%edx
  8018cb:	74 4b                	je     801918 <vprintfmt+0x23f>
  8018cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018d1:	78 06                	js     8018d9 <vprintfmt+0x200>
  8018d3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018d7:	78 1e                	js     8018f7 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8018d9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018dd:	74 d1                	je     8018b0 <vprintfmt+0x1d7>
  8018df:	0f be c0             	movsbl %al,%eax
  8018e2:	83 e8 20             	sub    $0x20,%eax
  8018e5:	83 f8 5e             	cmp    $0x5e,%eax
  8018e8:	76 c6                	jbe    8018b0 <vprintfmt+0x1d7>
					putch('?', putdat);
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	53                   	push   %ebx
  8018ee:	6a 3f                	push   $0x3f
  8018f0:	ff d6                	call   *%esi
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	eb c3                	jmp    8018ba <vprintfmt+0x1e1>
  8018f7:	89 cf                	mov    %ecx,%edi
  8018f9:	eb 0e                	jmp    801909 <vprintfmt+0x230>
				putch(' ', putdat);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	53                   	push   %ebx
  8018ff:	6a 20                	push   $0x20
  801901:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801903:	83 ef 01             	sub    $0x1,%edi
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	85 ff                	test   %edi,%edi
  80190b:	7f ee                	jg     8018fb <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80190d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801910:	89 45 14             	mov    %eax,0x14(%ebp)
  801913:	e9 67 01 00 00       	jmp    801a7f <vprintfmt+0x3a6>
  801918:	89 cf                	mov    %ecx,%edi
  80191a:	eb ed                	jmp    801909 <vprintfmt+0x230>
	if (lflag >= 2)
  80191c:	83 f9 01             	cmp    $0x1,%ecx
  80191f:	7f 1b                	jg     80193c <vprintfmt+0x263>
	else if (lflag)
  801921:	85 c9                	test   %ecx,%ecx
  801923:	74 63                	je     801988 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801925:	8b 45 14             	mov    0x14(%ebp),%eax
  801928:	8b 00                	mov    (%eax),%eax
  80192a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80192d:	99                   	cltd   
  80192e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801931:	8b 45 14             	mov    0x14(%ebp),%eax
  801934:	8d 40 04             	lea    0x4(%eax),%eax
  801937:	89 45 14             	mov    %eax,0x14(%ebp)
  80193a:	eb 17                	jmp    801953 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80193c:	8b 45 14             	mov    0x14(%ebp),%eax
  80193f:	8b 50 04             	mov    0x4(%eax),%edx
  801942:	8b 00                	mov    (%eax),%eax
  801944:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801947:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80194a:	8b 45 14             	mov    0x14(%ebp),%eax
  80194d:	8d 40 08             	lea    0x8(%eax),%eax
  801950:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801953:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801956:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801959:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80195e:	85 c9                	test   %ecx,%ecx
  801960:	0f 89 ff 00 00 00    	jns    801a65 <vprintfmt+0x38c>
				putch('-', putdat);
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	53                   	push   %ebx
  80196a:	6a 2d                	push   $0x2d
  80196c:	ff d6                	call   *%esi
				num = -(long long) num;
  80196e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801971:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801974:	f7 da                	neg    %edx
  801976:	83 d1 00             	adc    $0x0,%ecx
  801979:	f7 d9                	neg    %ecx
  80197b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80197e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801983:	e9 dd 00 00 00       	jmp    801a65 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  801988:	8b 45 14             	mov    0x14(%ebp),%eax
  80198b:	8b 00                	mov    (%eax),%eax
  80198d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801990:	99                   	cltd   
  801991:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801994:	8b 45 14             	mov    0x14(%ebp),%eax
  801997:	8d 40 04             	lea    0x4(%eax),%eax
  80199a:	89 45 14             	mov    %eax,0x14(%ebp)
  80199d:	eb b4                	jmp    801953 <vprintfmt+0x27a>
	if (lflag >= 2)
  80199f:	83 f9 01             	cmp    $0x1,%ecx
  8019a2:	7f 1e                	jg     8019c2 <vprintfmt+0x2e9>
	else if (lflag)
  8019a4:	85 c9                	test   %ecx,%ecx
  8019a6:	74 32                	je     8019da <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ab:	8b 10                	mov    (%eax),%edx
  8019ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019b2:	8d 40 04             	lea    0x4(%eax),%eax
  8019b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019bd:	e9 a3 00 00 00       	jmp    801a65 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c5:	8b 10                	mov    (%eax),%edx
  8019c7:	8b 48 04             	mov    0x4(%eax),%ecx
  8019ca:	8d 40 08             	lea    0x8(%eax),%eax
  8019cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019d0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8019d5:	e9 8b 00 00 00       	jmp    801a65 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8019da:	8b 45 14             	mov    0x14(%ebp),%eax
  8019dd:	8b 10                	mov    (%eax),%edx
  8019df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e4:	8d 40 04             	lea    0x4(%eax),%eax
  8019e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019ea:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8019ef:	eb 74                	jmp    801a65 <vprintfmt+0x38c>
	if (lflag >= 2)
  8019f1:	83 f9 01             	cmp    $0x1,%ecx
  8019f4:	7f 1b                	jg     801a11 <vprintfmt+0x338>
	else if (lflag)
  8019f6:	85 c9                	test   %ecx,%ecx
  8019f8:	74 2c                	je     801a26 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8019fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fd:	8b 10                	mov    (%eax),%edx
  8019ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a04:	8d 40 04             	lea    0x4(%eax),%eax
  801a07:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a0a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a0f:	eb 54                	jmp    801a65 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a11:	8b 45 14             	mov    0x14(%ebp),%eax
  801a14:	8b 10                	mov    (%eax),%edx
  801a16:	8b 48 04             	mov    0x4(%eax),%ecx
  801a19:	8d 40 08             	lea    0x8(%eax),%eax
  801a1c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a1f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a24:	eb 3f                	jmp    801a65 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a26:	8b 45 14             	mov    0x14(%ebp),%eax
  801a29:	8b 10                	mov    (%eax),%edx
  801a2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a30:	8d 40 04             	lea    0x4(%eax),%eax
  801a33:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a36:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a3b:	eb 28                	jmp    801a65 <vprintfmt+0x38c>
			putch('0', putdat);
  801a3d:	83 ec 08             	sub    $0x8,%esp
  801a40:	53                   	push   %ebx
  801a41:	6a 30                	push   $0x30
  801a43:	ff d6                	call   *%esi
			putch('x', putdat);
  801a45:	83 c4 08             	add    $0x8,%esp
  801a48:	53                   	push   %ebx
  801a49:	6a 78                	push   $0x78
  801a4b:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a4d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a50:	8b 10                	mov    (%eax),%edx
  801a52:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a57:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a5a:	8d 40 04             	lea    0x4(%eax),%eax
  801a5d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a60:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a6c:	57                   	push   %edi
  801a6d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a70:	50                   	push   %eax
  801a71:	51                   	push   %ecx
  801a72:	52                   	push   %edx
  801a73:	89 da                	mov    %ebx,%edx
  801a75:	89 f0                	mov    %esi,%eax
  801a77:	e8 72 fb ff ff       	call   8015ee <printnum>
			break;
  801a7c:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801a7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801a82:	83 c7 01             	add    $0x1,%edi
  801a85:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a89:	83 f8 25             	cmp    $0x25,%eax
  801a8c:	0f 84 62 fc ff ff    	je     8016f4 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801a92:	85 c0                	test   %eax,%eax
  801a94:	0f 84 8b 00 00 00    	je     801b25 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801a9a:	83 ec 08             	sub    $0x8,%esp
  801a9d:	53                   	push   %ebx
  801a9e:	50                   	push   %eax
  801a9f:	ff d6                	call   *%esi
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	eb dc                	jmp    801a82 <vprintfmt+0x3a9>
	if (lflag >= 2)
  801aa6:	83 f9 01             	cmp    $0x1,%ecx
  801aa9:	7f 1b                	jg     801ac6 <vprintfmt+0x3ed>
	else if (lflag)
  801aab:	85 c9                	test   %ecx,%ecx
  801aad:	74 2c                	je     801adb <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab2:	8b 10                	mov    (%eax),%edx
  801ab4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ab9:	8d 40 04             	lea    0x4(%eax),%eax
  801abc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801abf:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801ac4:	eb 9f                	jmp    801a65 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac9:	8b 10                	mov    (%eax),%edx
  801acb:	8b 48 04             	mov    0x4(%eax),%ecx
  801ace:	8d 40 08             	lea    0x8(%eax),%eax
  801ad1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ad4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801ad9:	eb 8a                	jmp    801a65 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801adb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ade:	8b 10                	mov    (%eax),%edx
  801ae0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ae5:	8d 40 04             	lea    0x4(%eax),%eax
  801ae8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aeb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801af0:	e9 70 ff ff ff       	jmp    801a65 <vprintfmt+0x38c>
			putch(ch, putdat);
  801af5:	83 ec 08             	sub    $0x8,%esp
  801af8:	53                   	push   %ebx
  801af9:	6a 25                	push   $0x25
  801afb:	ff d6                	call   *%esi
			break;
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	e9 7a ff ff ff       	jmp    801a7f <vprintfmt+0x3a6>
			putch('%', putdat);
  801b05:	83 ec 08             	sub    $0x8,%esp
  801b08:	53                   	push   %ebx
  801b09:	6a 25                	push   $0x25
  801b0b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	89 f8                	mov    %edi,%eax
  801b12:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b16:	74 05                	je     801b1d <vprintfmt+0x444>
  801b18:	83 e8 01             	sub    $0x1,%eax
  801b1b:	eb f5                	jmp    801b12 <vprintfmt+0x439>
  801b1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b20:	e9 5a ff ff ff       	jmp    801a7f <vprintfmt+0x3a6>
}
  801b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5f                   	pop    %edi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b2d:	f3 0f 1e fb          	endbr32 
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	83 ec 18             	sub    $0x18,%esp
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b40:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b44:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	74 26                	je     801b78 <vsnprintf+0x4b>
  801b52:	85 d2                	test   %edx,%edx
  801b54:	7e 22                	jle    801b78 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b56:	ff 75 14             	pushl  0x14(%ebp)
  801b59:	ff 75 10             	pushl  0x10(%ebp)
  801b5c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b5f:	50                   	push   %eax
  801b60:	68 97 16 80 00       	push   $0x801697
  801b65:	e8 6f fb ff ff       	call   8016d9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b6d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b73:	83 c4 10             	add    $0x10,%esp
}
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    
		return -E_INVAL;
  801b78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b7d:	eb f7                	jmp    801b76 <vsnprintf+0x49>

00801b7f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b7f:	f3 0f 1e fb          	endbr32 
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801b89:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b8c:	50                   	push   %eax
  801b8d:	ff 75 10             	pushl  0x10(%ebp)
  801b90:	ff 75 0c             	pushl  0xc(%ebp)
  801b93:	ff 75 08             	pushl  0x8(%ebp)
  801b96:	e8 92 ff ff ff       	call   801b2d <vsnprintf>
	va_end(ap);

	return rc;
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b9d:	f3 0f 1e fb          	endbr32 
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bb0:	74 05                	je     801bb7 <strlen+0x1a>
		n++;
  801bb2:	83 c0 01             	add    $0x1,%eax
  801bb5:	eb f5                	jmp    801bac <strlen+0xf>
	return n;
}
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    

00801bb9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bb9:	f3 0f 1e fb          	endbr32 
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcb:	39 d0                	cmp    %edx,%eax
  801bcd:	74 0d                	je     801bdc <strnlen+0x23>
  801bcf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801bd3:	74 05                	je     801bda <strnlen+0x21>
		n++;
  801bd5:	83 c0 01             	add    $0x1,%eax
  801bd8:	eb f1                	jmp    801bcb <strnlen+0x12>
  801bda:	89 c2                	mov    %eax,%edx
	return n;
}
  801bdc:	89 d0                	mov    %edx,%eax
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801be0:	f3 0f 1e fb          	endbr32 
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	53                   	push   %ebx
  801be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801beb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf3:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801bf7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801bfa:	83 c0 01             	add    $0x1,%eax
  801bfd:	84 d2                	test   %dl,%dl
  801bff:	75 f2                	jne    801bf3 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c01:	89 c8                	mov    %ecx,%eax
  801c03:	5b                   	pop    %ebx
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c06:	f3 0f 1e fb          	endbr32 
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	53                   	push   %ebx
  801c0e:	83 ec 10             	sub    $0x10,%esp
  801c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c14:	53                   	push   %ebx
  801c15:	e8 83 ff ff ff       	call   801b9d <strlen>
  801c1a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	01 d8                	add    %ebx,%eax
  801c22:	50                   	push   %eax
  801c23:	e8 b8 ff ff ff       	call   801be0 <strcpy>
	return dst;
}
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c2f:	f3 0f 1e fb          	endbr32 
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3e:	89 f3                	mov    %esi,%ebx
  801c40:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c43:	89 f0                	mov    %esi,%eax
  801c45:	39 d8                	cmp    %ebx,%eax
  801c47:	74 11                	je     801c5a <strncpy+0x2b>
		*dst++ = *src;
  801c49:	83 c0 01             	add    $0x1,%eax
  801c4c:	0f b6 0a             	movzbl (%edx),%ecx
  801c4f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c52:	80 f9 01             	cmp    $0x1,%cl
  801c55:	83 da ff             	sbb    $0xffffffff,%edx
  801c58:	eb eb                	jmp    801c45 <strncpy+0x16>
	}
	return ret;
}
  801c5a:	89 f0                	mov    %esi,%eax
  801c5c:	5b                   	pop    %ebx
  801c5d:	5e                   	pop    %esi
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	56                   	push   %esi
  801c68:	53                   	push   %ebx
  801c69:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6f:	8b 55 10             	mov    0x10(%ebp),%edx
  801c72:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c74:	85 d2                	test   %edx,%edx
  801c76:	74 21                	je     801c99 <strlcpy+0x39>
  801c78:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c7c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801c7e:	39 c2                	cmp    %eax,%edx
  801c80:	74 14                	je     801c96 <strlcpy+0x36>
  801c82:	0f b6 19             	movzbl (%ecx),%ebx
  801c85:	84 db                	test   %bl,%bl
  801c87:	74 0b                	je     801c94 <strlcpy+0x34>
			*dst++ = *src++;
  801c89:	83 c1 01             	add    $0x1,%ecx
  801c8c:	83 c2 01             	add    $0x1,%edx
  801c8f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c92:	eb ea                	jmp    801c7e <strlcpy+0x1e>
  801c94:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c96:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c99:	29 f0                	sub    %esi,%eax
}
  801c9b:	5b                   	pop    %ebx
  801c9c:	5e                   	pop    %esi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c9f:	f3 0f 1e fb          	endbr32 
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cac:	0f b6 01             	movzbl (%ecx),%eax
  801caf:	84 c0                	test   %al,%al
  801cb1:	74 0c                	je     801cbf <strcmp+0x20>
  801cb3:	3a 02                	cmp    (%edx),%al
  801cb5:	75 08                	jne    801cbf <strcmp+0x20>
		p++, q++;
  801cb7:	83 c1 01             	add    $0x1,%ecx
  801cba:	83 c2 01             	add    $0x1,%edx
  801cbd:	eb ed                	jmp    801cac <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cbf:	0f b6 c0             	movzbl %al,%eax
  801cc2:	0f b6 12             	movzbl (%edx),%edx
  801cc5:	29 d0                	sub    %edx,%eax
}
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cc9:	f3 0f 1e fb          	endbr32 
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	53                   	push   %ebx
  801cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cdc:	eb 06                	jmp    801ce4 <strncmp+0x1b>
		n--, p++, q++;
  801cde:	83 c0 01             	add    $0x1,%eax
  801ce1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801ce4:	39 d8                	cmp    %ebx,%eax
  801ce6:	74 16                	je     801cfe <strncmp+0x35>
  801ce8:	0f b6 08             	movzbl (%eax),%ecx
  801ceb:	84 c9                	test   %cl,%cl
  801ced:	74 04                	je     801cf3 <strncmp+0x2a>
  801cef:	3a 0a                	cmp    (%edx),%cl
  801cf1:	74 eb                	je     801cde <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cf3:	0f b6 00             	movzbl (%eax),%eax
  801cf6:	0f b6 12             	movzbl (%edx),%edx
  801cf9:	29 d0                	sub    %edx,%eax
}
  801cfb:	5b                   	pop    %ebx
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    
		return 0;
  801cfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801d03:	eb f6                	jmp    801cfb <strncmp+0x32>

00801d05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d05:	f3 0f 1e fb          	endbr32 
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d13:	0f b6 10             	movzbl (%eax),%edx
  801d16:	84 d2                	test   %dl,%dl
  801d18:	74 09                	je     801d23 <strchr+0x1e>
		if (*s == c)
  801d1a:	38 ca                	cmp    %cl,%dl
  801d1c:	74 0a                	je     801d28 <strchr+0x23>
	for (; *s; s++)
  801d1e:	83 c0 01             	add    $0x1,%eax
  801d21:	eb f0                	jmp    801d13 <strchr+0xe>
			return (char *) s;
	return 0;
  801d23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    

00801d2a <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d2a:	f3 0f 1e fb          	endbr32 
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d34:	6a 78                	push   $0x78
  801d36:	ff 75 08             	pushl  0x8(%ebp)
  801d39:	e8 c7 ff ff ff       	call   801d05 <strchr>
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d44:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d49:	eb 0d                	jmp    801d58 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d4b:	c1 e0 04             	shl    $0x4,%eax
  801d4e:	0f be d2             	movsbl %dl,%edx
  801d51:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d55:	83 c1 01             	add    $0x1,%ecx
  801d58:	0f b6 11             	movzbl (%ecx),%edx
  801d5b:	84 d2                	test   %dl,%dl
  801d5d:	74 11                	je     801d70 <atox+0x46>
		if (*p>='a'){
  801d5f:	80 fa 60             	cmp    $0x60,%dl
  801d62:	7e e7                	jle    801d4b <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d64:	c1 e0 04             	shl    $0x4,%eax
  801d67:	0f be d2             	movsbl %dl,%edx
  801d6a:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d6e:	eb e5                	jmp    801d55 <atox+0x2b>
	}

	return v;

}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d72:	f3 0f 1e fb          	endbr32 
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d80:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d83:	38 ca                	cmp    %cl,%dl
  801d85:	74 09                	je     801d90 <strfind+0x1e>
  801d87:	84 d2                	test   %dl,%dl
  801d89:	74 05                	je     801d90 <strfind+0x1e>
	for (; *s; s++)
  801d8b:	83 c0 01             	add    $0x1,%eax
  801d8e:	eb f0                	jmp    801d80 <strfind+0xe>
			break;
	return (char *) s;
}
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d92:	f3 0f 1e fb          	endbr32 
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	57                   	push   %edi
  801d9a:	56                   	push   %esi
  801d9b:	53                   	push   %ebx
  801d9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801da2:	85 c9                	test   %ecx,%ecx
  801da4:	74 31                	je     801dd7 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801da6:	89 f8                	mov    %edi,%eax
  801da8:	09 c8                	or     %ecx,%eax
  801daa:	a8 03                	test   $0x3,%al
  801dac:	75 23                	jne    801dd1 <memset+0x3f>
		c &= 0xFF;
  801dae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801db2:	89 d3                	mov    %edx,%ebx
  801db4:	c1 e3 08             	shl    $0x8,%ebx
  801db7:	89 d0                	mov    %edx,%eax
  801db9:	c1 e0 18             	shl    $0x18,%eax
  801dbc:	89 d6                	mov    %edx,%esi
  801dbe:	c1 e6 10             	shl    $0x10,%esi
  801dc1:	09 f0                	or     %esi,%eax
  801dc3:	09 c2                	or     %eax,%edx
  801dc5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801dc7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	fc                   	cld    
  801dcd:	f3 ab                	rep stos %eax,%es:(%edi)
  801dcf:	eb 06                	jmp    801dd7 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd4:	fc                   	cld    
  801dd5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dd7:	89 f8                	mov    %edi,%eax
  801dd9:	5b                   	pop    %ebx
  801dda:	5e                   	pop    %esi
  801ddb:	5f                   	pop    %edi
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dde:	f3 0f 1e fb          	endbr32 
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	57                   	push   %edi
  801de6:	56                   	push   %esi
  801de7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dea:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ded:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801df0:	39 c6                	cmp    %eax,%esi
  801df2:	73 32                	jae    801e26 <memmove+0x48>
  801df4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801df7:	39 c2                	cmp    %eax,%edx
  801df9:	76 2b                	jbe    801e26 <memmove+0x48>
		s += n;
		d += n;
  801dfb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dfe:	89 fe                	mov    %edi,%esi
  801e00:	09 ce                	or     %ecx,%esi
  801e02:	09 d6                	or     %edx,%esi
  801e04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e0a:	75 0e                	jne    801e1a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e0c:	83 ef 04             	sub    $0x4,%edi
  801e0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e15:	fd                   	std    
  801e16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e18:	eb 09                	jmp    801e23 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e1a:	83 ef 01             	sub    $0x1,%edi
  801e1d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e20:	fd                   	std    
  801e21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e23:	fc                   	cld    
  801e24:	eb 1a                	jmp    801e40 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e26:	89 c2                	mov    %eax,%edx
  801e28:	09 ca                	or     %ecx,%edx
  801e2a:	09 f2                	or     %esi,%edx
  801e2c:	f6 c2 03             	test   $0x3,%dl
  801e2f:	75 0a                	jne    801e3b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e31:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e34:	89 c7                	mov    %eax,%edi
  801e36:	fc                   	cld    
  801e37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e39:	eb 05                	jmp    801e40 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e3b:	89 c7                	mov    %eax,%edi
  801e3d:	fc                   	cld    
  801e3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e44:	f3 0f 1e fb          	endbr32 
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e4e:	ff 75 10             	pushl  0x10(%ebp)
  801e51:	ff 75 0c             	pushl  0xc(%ebp)
  801e54:	ff 75 08             	pushl  0x8(%ebp)
  801e57:	e8 82 ff ff ff       	call   801dde <memmove>
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e5e:	f3 0f 1e fb          	endbr32 
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	56                   	push   %esi
  801e66:	53                   	push   %ebx
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6d:	89 c6                	mov    %eax,%esi
  801e6f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e72:	39 f0                	cmp    %esi,%eax
  801e74:	74 1c                	je     801e92 <memcmp+0x34>
		if (*s1 != *s2)
  801e76:	0f b6 08             	movzbl (%eax),%ecx
  801e79:	0f b6 1a             	movzbl (%edx),%ebx
  801e7c:	38 d9                	cmp    %bl,%cl
  801e7e:	75 08                	jne    801e88 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801e80:	83 c0 01             	add    $0x1,%eax
  801e83:	83 c2 01             	add    $0x1,%edx
  801e86:	eb ea                	jmp    801e72 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801e88:	0f b6 c1             	movzbl %cl,%eax
  801e8b:	0f b6 db             	movzbl %bl,%ebx
  801e8e:	29 d8                	sub    %ebx,%eax
  801e90:	eb 05                	jmp    801e97 <memcmp+0x39>
	}

	return 0;
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e9b:	f3 0f 1e fb          	endbr32 
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ead:	39 d0                	cmp    %edx,%eax
  801eaf:	73 09                	jae    801eba <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801eb1:	38 08                	cmp    %cl,(%eax)
  801eb3:	74 05                	je     801eba <memfind+0x1f>
	for (; s < ends; s++)
  801eb5:	83 c0 01             	add    $0x1,%eax
  801eb8:	eb f3                	jmp    801ead <memfind+0x12>
			break;
	return (void *) s;
}
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    

00801ebc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ebc:	f3 0f 1e fb          	endbr32 
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ecc:	eb 03                	jmp    801ed1 <strtol+0x15>
		s++;
  801ece:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801ed1:	0f b6 01             	movzbl (%ecx),%eax
  801ed4:	3c 20                	cmp    $0x20,%al
  801ed6:	74 f6                	je     801ece <strtol+0x12>
  801ed8:	3c 09                	cmp    $0x9,%al
  801eda:	74 f2                	je     801ece <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801edc:	3c 2b                	cmp    $0x2b,%al
  801ede:	74 2a                	je     801f0a <strtol+0x4e>
	int neg = 0;
  801ee0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801ee5:	3c 2d                	cmp    $0x2d,%al
  801ee7:	74 2b                	je     801f14 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ee9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801eef:	75 0f                	jne    801f00 <strtol+0x44>
  801ef1:	80 39 30             	cmpb   $0x30,(%ecx)
  801ef4:	74 28                	je     801f1e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ef6:	85 db                	test   %ebx,%ebx
  801ef8:	b8 0a 00 00 00       	mov    $0xa,%eax
  801efd:	0f 44 d8             	cmove  %eax,%ebx
  801f00:	b8 00 00 00 00       	mov    $0x0,%eax
  801f05:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f08:	eb 46                	jmp    801f50 <strtol+0x94>
		s++;
  801f0a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f0d:	bf 00 00 00 00       	mov    $0x0,%edi
  801f12:	eb d5                	jmp    801ee9 <strtol+0x2d>
		s++, neg = 1;
  801f14:	83 c1 01             	add    $0x1,%ecx
  801f17:	bf 01 00 00 00       	mov    $0x1,%edi
  801f1c:	eb cb                	jmp    801ee9 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f1e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f22:	74 0e                	je     801f32 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f24:	85 db                	test   %ebx,%ebx
  801f26:	75 d8                	jne    801f00 <strtol+0x44>
		s++, base = 8;
  801f28:	83 c1 01             	add    $0x1,%ecx
  801f2b:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f30:	eb ce                	jmp    801f00 <strtol+0x44>
		s += 2, base = 16;
  801f32:	83 c1 02             	add    $0x2,%ecx
  801f35:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f3a:	eb c4                	jmp    801f00 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f3c:	0f be d2             	movsbl %dl,%edx
  801f3f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f42:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f45:	7d 3a                	jge    801f81 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f47:	83 c1 01             	add    $0x1,%ecx
  801f4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f4e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f50:	0f b6 11             	movzbl (%ecx),%edx
  801f53:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f56:	89 f3                	mov    %esi,%ebx
  801f58:	80 fb 09             	cmp    $0x9,%bl
  801f5b:	76 df                	jbe    801f3c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f5d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f60:	89 f3                	mov    %esi,%ebx
  801f62:	80 fb 19             	cmp    $0x19,%bl
  801f65:	77 08                	ja     801f6f <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f67:	0f be d2             	movsbl %dl,%edx
  801f6a:	83 ea 57             	sub    $0x57,%edx
  801f6d:	eb d3                	jmp    801f42 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f6f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f72:	89 f3                	mov    %esi,%ebx
  801f74:	80 fb 19             	cmp    $0x19,%bl
  801f77:	77 08                	ja     801f81 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f79:	0f be d2             	movsbl %dl,%edx
  801f7c:	83 ea 37             	sub    $0x37,%edx
  801f7f:	eb c1                	jmp    801f42 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801f81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f85:	74 05                	je     801f8c <strtol+0xd0>
		*endptr = (char *) s;
  801f87:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801f8c:	89 c2                	mov    %eax,%edx
  801f8e:	f7 da                	neg    %edx
  801f90:	85 ff                	test   %edi,%edi
  801f92:	0f 45 c2             	cmovne %edx,%eax
}
  801f95:	5b                   	pop    %ebx
  801f96:	5e                   	pop    %esi
  801f97:	5f                   	pop    %edi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f9a:	f3 0f 1e fb          	endbr32 
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fac:	85 c0                	test   %eax,%eax
  801fae:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fb3:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fb6:	83 ec 0c             	sub    $0xc,%esp
  801fb9:	50                   	push   %eax
  801fba:	e8 97 e2 ff ff       	call   800256 <sys_ipc_recv>
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	75 2b                	jne    801ff1 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fc6:	85 f6                	test   %esi,%esi
  801fc8:	74 0a                	je     801fd4 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fca:	a1 08 40 80 00       	mov    0x804008,%eax
  801fcf:	8b 40 74             	mov    0x74(%eax),%eax
  801fd2:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fd4:	85 db                	test   %ebx,%ebx
  801fd6:	74 0a                	je     801fe2 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801fd8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fdd:	8b 40 78             	mov    0x78(%eax),%eax
  801fe0:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801fe2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe7:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  801ff1:	85 f6                	test   %esi,%esi
  801ff3:	74 06                	je     801ffb <ipc_recv+0x61>
  801ff5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801ffb:	85 db                	test   %ebx,%ebx
  801ffd:	74 eb                	je     801fea <ipc_recv+0x50>
  801fff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802005:	eb e3                	jmp    801fea <ipc_recv+0x50>

00802007 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802007:	f3 0f 1e fb          	endbr32 
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	57                   	push   %edi
  80200f:	56                   	push   %esi
  802010:	53                   	push   %ebx
  802011:	83 ec 0c             	sub    $0xc,%esp
  802014:	8b 7d 08             	mov    0x8(%ebp),%edi
  802017:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80201d:	85 db                	test   %ebx,%ebx
  80201f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802024:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802027:	ff 75 14             	pushl  0x14(%ebp)
  80202a:	53                   	push   %ebx
  80202b:	56                   	push   %esi
  80202c:	57                   	push   %edi
  80202d:	e8 fd e1 ff ff       	call   80022f <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802038:	75 07                	jne    802041 <ipc_send+0x3a>
			sys_yield();
  80203a:	e8 ee e0 ff ff       	call   80012d <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80203f:	eb e6                	jmp    802027 <ipc_send+0x20>
		}
		else if (ret == 0)
  802041:	85 c0                	test   %eax,%eax
  802043:	75 08                	jne    80204d <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802045:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80204d:	50                   	push   %eax
  80204e:	68 ff 27 80 00       	push   $0x8027ff
  802053:	6a 48                	push   $0x48
  802055:	68 0d 28 80 00       	push   $0x80280d
  80205a:	e8 90 f4 ff ff       	call   8014ef <_panic>

0080205f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80205f:	f3 0f 1e fb          	endbr32 
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80206e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802071:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802077:	8b 52 50             	mov    0x50(%edx),%edx
  80207a:	39 ca                	cmp    %ecx,%edx
  80207c:	74 11                	je     80208f <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80207e:	83 c0 01             	add    $0x1,%eax
  802081:	3d 00 04 00 00       	cmp    $0x400,%eax
  802086:	75 e6                	jne    80206e <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802088:	b8 00 00 00 00       	mov    $0x0,%eax
  80208d:	eb 0b                	jmp    80209a <ipc_find_env+0x3b>
			return envs[i].env_id;
  80208f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802092:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802097:	8b 40 48             	mov    0x48(%eax),%eax
}
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    

0080209c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80209c:	f3 0f 1e fb          	endbr32 
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a6:	89 c2                	mov    %eax,%edx
  8020a8:	c1 ea 16             	shr    $0x16,%edx
  8020ab:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020b2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020b7:	f6 c1 01             	test   $0x1,%cl
  8020ba:	74 1c                	je     8020d8 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020bc:	c1 e8 0c             	shr    $0xc,%eax
  8020bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020c6:	a8 01                	test   $0x1,%al
  8020c8:	74 0e                	je     8020d8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020ca:	c1 e8 0c             	shr    $0xc,%eax
  8020cd:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020d4:	ef 
  8020d5:	0f b7 d2             	movzwl %dx,%edx
}
  8020d8:	89 d0                	mov    %edx,%eax
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    
  8020dc:	66 90                	xchg   %ax,%ax
  8020de:	66 90                	xchg   %ax,%ax

008020e0 <__udivdi3>:
  8020e0:	f3 0f 1e fb          	endbr32 
  8020e4:	55                   	push   %ebp
  8020e5:	57                   	push   %edi
  8020e6:	56                   	push   %esi
  8020e7:	53                   	push   %ebx
  8020e8:	83 ec 1c             	sub    $0x1c,%esp
  8020eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020fb:	85 d2                	test   %edx,%edx
  8020fd:	75 19                	jne    802118 <__udivdi3+0x38>
  8020ff:	39 f3                	cmp    %esi,%ebx
  802101:	76 4d                	jbe    802150 <__udivdi3+0x70>
  802103:	31 ff                	xor    %edi,%edi
  802105:	89 e8                	mov    %ebp,%eax
  802107:	89 f2                	mov    %esi,%edx
  802109:	f7 f3                	div    %ebx
  80210b:	89 fa                	mov    %edi,%edx
  80210d:	83 c4 1c             	add    $0x1c,%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    
  802115:	8d 76 00             	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	76 14                	jbe    802130 <__udivdi3+0x50>
  80211c:	31 ff                	xor    %edi,%edi
  80211e:	31 c0                	xor    %eax,%eax
  802120:	89 fa                	mov    %edi,%edx
  802122:	83 c4 1c             	add    $0x1c,%esp
  802125:	5b                   	pop    %ebx
  802126:	5e                   	pop    %esi
  802127:	5f                   	pop    %edi
  802128:	5d                   	pop    %ebp
  802129:	c3                   	ret    
  80212a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802130:	0f bd fa             	bsr    %edx,%edi
  802133:	83 f7 1f             	xor    $0x1f,%edi
  802136:	75 48                	jne    802180 <__udivdi3+0xa0>
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	72 06                	jb     802142 <__udivdi3+0x62>
  80213c:	31 c0                	xor    %eax,%eax
  80213e:	39 eb                	cmp    %ebp,%ebx
  802140:	77 de                	ja     802120 <__udivdi3+0x40>
  802142:	b8 01 00 00 00       	mov    $0x1,%eax
  802147:	eb d7                	jmp    802120 <__udivdi3+0x40>
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d9                	mov    %ebx,%ecx
  802152:	85 db                	test   %ebx,%ebx
  802154:	75 0b                	jne    802161 <__udivdi3+0x81>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f3                	div    %ebx
  80215f:	89 c1                	mov    %eax,%ecx
  802161:	31 d2                	xor    %edx,%edx
  802163:	89 f0                	mov    %esi,%eax
  802165:	f7 f1                	div    %ecx
  802167:	89 c6                	mov    %eax,%esi
  802169:	89 e8                	mov    %ebp,%eax
  80216b:	89 f7                	mov    %esi,%edi
  80216d:	f7 f1                	div    %ecx
  80216f:	89 fa                	mov    %edi,%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 f9                	mov    %edi,%ecx
  802182:	b8 20 00 00 00       	mov    $0x20,%eax
  802187:	29 f8                	sub    %edi,%eax
  802189:	d3 e2                	shl    %cl,%edx
  80218b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	89 da                	mov    %ebx,%edx
  802193:	d3 ea                	shr    %cl,%edx
  802195:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802199:	09 d1                	or     %edx,%ecx
  80219b:	89 f2                	mov    %esi,%edx
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e3                	shl    %cl,%ebx
  8021a5:	89 c1                	mov    %eax,%ecx
  8021a7:	d3 ea                	shr    %cl,%edx
  8021a9:	89 f9                	mov    %edi,%ecx
  8021ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021af:	89 eb                	mov    %ebp,%ebx
  8021b1:	d3 e6                	shl    %cl,%esi
  8021b3:	89 c1                	mov    %eax,%ecx
  8021b5:	d3 eb                	shr    %cl,%ebx
  8021b7:	09 de                	or     %ebx,%esi
  8021b9:	89 f0                	mov    %esi,%eax
  8021bb:	f7 74 24 08          	divl   0x8(%esp)
  8021bf:	89 d6                	mov    %edx,%esi
  8021c1:	89 c3                	mov    %eax,%ebx
  8021c3:	f7 64 24 0c          	mull   0xc(%esp)
  8021c7:	39 d6                	cmp    %edx,%esi
  8021c9:	72 15                	jb     8021e0 <__udivdi3+0x100>
  8021cb:	89 f9                	mov    %edi,%ecx
  8021cd:	d3 e5                	shl    %cl,%ebp
  8021cf:	39 c5                	cmp    %eax,%ebp
  8021d1:	73 04                	jae    8021d7 <__udivdi3+0xf7>
  8021d3:	39 d6                	cmp    %edx,%esi
  8021d5:	74 09                	je     8021e0 <__udivdi3+0x100>
  8021d7:	89 d8                	mov    %ebx,%eax
  8021d9:	31 ff                	xor    %edi,%edi
  8021db:	e9 40 ff ff ff       	jmp    802120 <__udivdi3+0x40>
  8021e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021e3:	31 ff                	xor    %edi,%edi
  8021e5:	e9 36 ff ff ff       	jmp    802120 <__udivdi3+0x40>
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	f3 0f 1e fb          	endbr32 
  8021f4:	55                   	push   %ebp
  8021f5:	57                   	push   %edi
  8021f6:	56                   	push   %esi
  8021f7:	53                   	push   %ebx
  8021f8:	83 ec 1c             	sub    $0x1c,%esp
  8021fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021ff:	8b 74 24 30          	mov    0x30(%esp),%esi
  802203:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802207:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80220b:	85 c0                	test   %eax,%eax
  80220d:	75 19                	jne    802228 <__umoddi3+0x38>
  80220f:	39 df                	cmp    %ebx,%edi
  802211:	76 5d                	jbe    802270 <__umoddi3+0x80>
  802213:	89 f0                	mov    %esi,%eax
  802215:	89 da                	mov    %ebx,%edx
  802217:	f7 f7                	div    %edi
  802219:	89 d0                	mov    %edx,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	83 c4 1c             	add    $0x1c,%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    
  802225:	8d 76 00             	lea    0x0(%esi),%esi
  802228:	89 f2                	mov    %esi,%edx
  80222a:	39 d8                	cmp    %ebx,%eax
  80222c:	76 12                	jbe    802240 <__umoddi3+0x50>
  80222e:	89 f0                	mov    %esi,%eax
  802230:	89 da                	mov    %ebx,%edx
  802232:	83 c4 1c             	add    $0x1c,%esp
  802235:	5b                   	pop    %ebx
  802236:	5e                   	pop    %esi
  802237:	5f                   	pop    %edi
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    
  80223a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802240:	0f bd e8             	bsr    %eax,%ebp
  802243:	83 f5 1f             	xor    $0x1f,%ebp
  802246:	75 50                	jne    802298 <__umoddi3+0xa8>
  802248:	39 d8                	cmp    %ebx,%eax
  80224a:	0f 82 e0 00 00 00    	jb     802330 <__umoddi3+0x140>
  802250:	89 d9                	mov    %ebx,%ecx
  802252:	39 f7                	cmp    %esi,%edi
  802254:	0f 86 d6 00 00 00    	jbe    802330 <__umoddi3+0x140>
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	89 ca                	mov    %ecx,%edx
  80225e:	83 c4 1c             	add    $0x1c,%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5f                   	pop    %edi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    
  802266:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80226d:	8d 76 00             	lea    0x0(%esi),%esi
  802270:	89 fd                	mov    %edi,%ebp
  802272:	85 ff                	test   %edi,%edi
  802274:	75 0b                	jne    802281 <__umoddi3+0x91>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f7                	div    %edi
  80227f:	89 c5                	mov    %eax,%ebp
  802281:	89 d8                	mov    %ebx,%eax
  802283:	31 d2                	xor    %edx,%edx
  802285:	f7 f5                	div    %ebp
  802287:	89 f0                	mov    %esi,%eax
  802289:	f7 f5                	div    %ebp
  80228b:	89 d0                	mov    %edx,%eax
  80228d:	31 d2                	xor    %edx,%edx
  80228f:	eb 8c                	jmp    80221d <__umoddi3+0x2d>
  802291:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802298:	89 e9                	mov    %ebp,%ecx
  80229a:	ba 20 00 00 00       	mov    $0x20,%edx
  80229f:	29 ea                	sub    %ebp,%edx
  8022a1:	d3 e0                	shl    %cl,%eax
  8022a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 f8                	mov    %edi,%eax
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b9:	09 c1                	or     %eax,%ecx
  8022bb:	89 d8                	mov    %ebx,%eax
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 e9                	mov    %ebp,%ecx
  8022c3:	d3 e7                	shl    %cl,%edi
  8022c5:	89 d1                	mov    %edx,%ecx
  8022c7:	d3 e8                	shr    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022cf:	d3 e3                	shl    %cl,%ebx
  8022d1:	89 c7                	mov    %eax,%edi
  8022d3:	89 d1                	mov    %edx,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e8                	shr    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	89 fa                	mov    %edi,%edx
  8022dd:	d3 e6                	shl    %cl,%esi
  8022df:	09 d8                	or     %ebx,%eax
  8022e1:	f7 74 24 08          	divl   0x8(%esp)
  8022e5:	89 d1                	mov    %edx,%ecx
  8022e7:	89 f3                	mov    %esi,%ebx
  8022e9:	f7 64 24 0c          	mull   0xc(%esp)
  8022ed:	89 c6                	mov    %eax,%esi
  8022ef:	89 d7                	mov    %edx,%edi
  8022f1:	39 d1                	cmp    %edx,%ecx
  8022f3:	72 06                	jb     8022fb <__umoddi3+0x10b>
  8022f5:	75 10                	jne    802307 <__umoddi3+0x117>
  8022f7:	39 c3                	cmp    %eax,%ebx
  8022f9:	73 0c                	jae    802307 <__umoddi3+0x117>
  8022fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8022ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802303:	89 d7                	mov    %edx,%edi
  802305:	89 c6                	mov    %eax,%esi
  802307:	89 ca                	mov    %ecx,%edx
  802309:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80230e:	29 f3                	sub    %esi,%ebx
  802310:	19 fa                	sbb    %edi,%edx
  802312:	89 d0                	mov    %edx,%eax
  802314:	d3 e0                	shl    %cl,%eax
  802316:	89 e9                	mov    %ebp,%ecx
  802318:	d3 eb                	shr    %cl,%ebx
  80231a:	d3 ea                	shr    %cl,%edx
  80231c:	09 d8                	or     %ebx,%eax
  80231e:	83 c4 1c             	add    $0x1c,%esp
  802321:	5b                   	pop    %ebx
  802322:	5e                   	pop    %esi
  802323:	5f                   	pop    %edi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	29 fe                	sub    %edi,%esi
  802332:	19 c3                	sbb    %eax,%ebx
  802334:	89 f2                	mov    %esi,%edx
  802336:	89 d9                	mov    %ebx,%ecx
  802338:	e9 1d ff ff ff       	jmp    80225a <__umoddi3+0x6a>
