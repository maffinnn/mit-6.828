
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 38 00 00 00       	call   800069 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003d:	6a 07                	push   $0x7
  80003f:	68 00 f0 bf ee       	push   $0xeebff000
  800044:	6a 00                	push   $0x0
  800046:	e8 35 01 00 00       	call   800180 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 ef be ad de       	push   $0xdeadbeef
  800053:	6a 00                	push   $0x0
  800055:	e8 e0 01 00 00       	call   80023a <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80005a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800061:	00 00 00 
}
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	c9                   	leave  
  800068:	c3                   	ret    

00800069 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800069:	f3 0f 1e fb          	endbr32 
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800078:	e8 bd 00 00 00       	call   80013a <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x31>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	f3 0f 1e fb          	endbr32 
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000bd:	e8 49 04 00 00       	call   80050b <close_all>
	sys_env_destroy(0);
  8000c2:	83 ec 0c             	sub    $0xc,%esp
  8000c5:	6a 00                	push   $0x0
  8000c7:	e8 4a 00 00 00       	call   800116 <sys_env_destroy>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d1:	f3 0f 1e fb          	endbr32 
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000db:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e6:	89 c3                	mov    %eax,%ebx
  8000e8:	89 c7                	mov    %eax,%edi
  8000ea:	89 c6                	mov    %eax,%esi
  8000ec:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f3:	f3 0f 1e fb          	endbr32 
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800102:	b8 01 00 00 00       	mov    $0x1,%eax
  800107:	89 d1                	mov    %edx,%ecx
  800109:	89 d3                	mov    %edx,%ebx
  80010b:	89 d7                	mov    %edx,%edi
  80010d:	89 d6                	mov    %edx,%esi
  80010f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800116:	f3 0f 1e fb          	endbr32 
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	57                   	push   %edi
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800120:	b9 00 00 00 00       	mov    $0x0,%ecx
  800125:	8b 55 08             	mov    0x8(%ebp),%edx
  800128:	b8 03 00 00 00       	mov    $0x3,%eax
  80012d:	89 cb                	mov    %ecx,%ebx
  80012f:	89 cf                	mov    %ecx,%edi
  800131:	89 ce                	mov    %ecx,%esi
  800133:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	f3 0f 1e fb          	endbr32 
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	57                   	push   %edi
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	asm volatile("int %1\n"
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 02 00 00 00       	mov    $0x2,%eax
  80014e:	89 d1                	mov    %edx,%ecx
  800150:	89 d3                	mov    %edx,%ebx
  800152:	89 d7                	mov    %edx,%edi
  800154:	89 d6                	mov    %edx,%esi
  800156:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800158:	5b                   	pop    %ebx
  800159:	5e                   	pop    %esi
  80015a:	5f                   	pop    %edi
  80015b:	5d                   	pop    %ebp
  80015c:	c3                   	ret    

0080015d <sys_yield>:

void
sys_yield(void)
{
  80015d:	f3 0f 1e fb          	endbr32 
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	57                   	push   %edi
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
	asm volatile("int %1\n"
  800167:	ba 00 00 00 00       	mov    $0x0,%edx
  80016c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800171:	89 d1                	mov    %edx,%ecx
  800173:	89 d3                	mov    %edx,%ebx
  800175:	89 d7                	mov    %edx,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800180:	f3 0f 1e fb          	endbr32 
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	f3 0f 1e fb          	endbr32 
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001be:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c4:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5f                   	pop    %edi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001cb:	f3 0f 1e fb          	endbr32 
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001da:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e5:	89 df                	mov    %ebx,%edi
  8001e7:	89 de                	mov    %ebx,%esi
  8001e9:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001eb:	5b                   	pop    %ebx
  8001ec:	5e                   	pop    %esi
  8001ed:	5f                   	pop    %edi
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    

008001f0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001f0:	f3 0f 1e fb          	endbr32 
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	57                   	push   %edi
  8001f8:	56                   	push   %esi
  8001f9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	b8 08 00 00 00       	mov    $0x8,%eax
  80020a:	89 df                	mov    %ebx,%edi
  80020c:	89 de                	mov    %ebx,%esi
  80020e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800215:	f3 0f 1e fb          	endbr32 
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80021f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	b8 09 00 00 00       	mov    $0x9,%eax
  80022f:	89 df                	mov    %ebx,%edi
  800231:	89 de                	mov    %ebx,%esi
  800233:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5f                   	pop    %edi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80023a:	f3 0f 1e fb          	endbr32 
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	57                   	push   %edi
  800242:	56                   	push   %esi
  800243:	53                   	push   %ebx
	asm volatile("int %1\n"
  800244:	bb 00 00 00 00       	mov    $0x0,%ebx
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800254:	89 df                	mov    %ebx,%edi
  800256:	89 de                	mov    %ebx,%esi
  800258:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80025f:	f3 0f 1e fb          	endbr32 
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
	asm volatile("int %1\n"
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800274:	be 00 00 00 00       	mov    $0x0,%esi
  800279:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80027f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800286:	f3 0f 1e fb          	endbr32 
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800290:	b9 00 00 00 00       	mov    $0x0,%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	b8 0d 00 00 00       	mov    $0xd,%eax
  80029d:	89 cb                	mov    %ecx,%ebx
  80029f:	89 cf                	mov    %ecx,%edi
  8002a1:	89 ce                	mov    %ecx,%esi
  8002a3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002a5:	5b                   	pop    %ebx
  8002a6:	5e                   	pop    %esi
  8002a7:	5f                   	pop    %edi
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8002aa:	f3 0f 1e fb          	endbr32 
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002be:	89 d1                	mov    %edx,%ecx
  8002c0:	89 d3                	mov    %edx,%ebx
  8002c2:	89 d7                	mov    %edx,%edi
  8002c4:	89 d6                	mov    %edx,%esi
  8002c6:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8002cd:	f3 0f 1e fb          	endbr32 
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002e7:	89 df                	mov    %ebx,%edi
  8002e9:	89 de                	mov    %ebx,%esi
  8002eb:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002ed:	5b                   	pop    %ebx
  8002ee:	5e                   	pop    %esi
  8002ef:	5f                   	pop    %edi
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002f2:	f3 0f 1e fb          	endbr32 
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	b8 10 00 00 00       	mov    $0x10,%eax
  80030c:	89 df                	mov    %ebx,%edi
  80030e:	89 de                	mov    %ebx,%esi
  800310:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800317:	f3 0f 1e fb          	endbr32 
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	05 00 00 00 30       	add    $0x30000000,%eax
  800326:	c1 e8 0c             	shr    $0xc,%eax
}
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80032b:	f3 0f 1e fb          	endbr32 
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80033a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80033f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800346:	f3 0f 1e fb          	endbr32 
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800352:	89 c2                	mov    %eax,%edx
  800354:	c1 ea 16             	shr    $0x16,%edx
  800357:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80035e:	f6 c2 01             	test   $0x1,%dl
  800361:	74 2d                	je     800390 <fd_alloc+0x4a>
  800363:	89 c2                	mov    %eax,%edx
  800365:	c1 ea 0c             	shr    $0xc,%edx
  800368:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80036f:	f6 c2 01             	test   $0x1,%dl
  800372:	74 1c                	je     800390 <fd_alloc+0x4a>
  800374:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800379:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80037e:	75 d2                	jne    800352 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800389:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80038e:	eb 0a                	jmp    80039a <fd_alloc+0x54>
			*fd_store = fd;
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	89 01                	mov    %eax,(%ecx)
			return 0;
  800395:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80039c:	f3 0f 1e fb          	endbr32 
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003a6:	83 f8 1f             	cmp    $0x1f,%eax
  8003a9:	77 30                	ja     8003db <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ab:	c1 e0 0c             	shl    $0xc,%eax
  8003ae:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003b3:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003b9:	f6 c2 01             	test   $0x1,%dl
  8003bc:	74 24                	je     8003e2 <fd_lookup+0x46>
  8003be:	89 c2                	mov    %eax,%edx
  8003c0:	c1 ea 0c             	shr    $0xc,%edx
  8003c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ca:	f6 c2 01             	test   $0x1,%dl
  8003cd:	74 1a                	je     8003e9 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d2:	89 02                	mov    %eax,(%edx)
	return 0;
  8003d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    
		return -E_INVAL;
  8003db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e0:	eb f7                	jmp    8003d9 <fd_lookup+0x3d>
		return -E_INVAL;
  8003e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e7:	eb f0                	jmp    8003d9 <fd_lookup+0x3d>
  8003e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003ee:	eb e9                	jmp    8003d9 <fd_lookup+0x3d>

008003f0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003f0:	f3 0f 1e fb          	endbr32 
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800402:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800407:	39 08                	cmp    %ecx,(%eax)
  800409:	74 38                	je     800443 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80040b:	83 c2 01             	add    $0x1,%edx
  80040e:	8b 04 95 08 24 80 00 	mov    0x802408(,%edx,4),%eax
  800415:	85 c0                	test   %eax,%eax
  800417:	75 ee                	jne    800407 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800419:	a1 08 40 80 00       	mov    0x804008,%eax
  80041e:	8b 40 48             	mov    0x48(%eax),%eax
  800421:	83 ec 04             	sub    $0x4,%esp
  800424:	51                   	push   %ecx
  800425:	50                   	push   %eax
  800426:	68 8c 23 80 00       	push   $0x80238c
  80042b:	e8 d6 11 00 00       	call   801606 <cprintf>
	*dev = 0;
  800430:	8b 45 0c             	mov    0xc(%ebp),%eax
  800433:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800439:	83 c4 10             	add    $0x10,%esp
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800441:	c9                   	leave  
  800442:	c3                   	ret    
			*dev = devtab[i];
  800443:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800446:	89 01                	mov    %eax,(%ecx)
			return 0;
  800448:	b8 00 00 00 00       	mov    $0x0,%eax
  80044d:	eb f2                	jmp    800441 <dev_lookup+0x51>

0080044f <fd_close>:
{
  80044f:	f3 0f 1e fb          	endbr32 
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	57                   	push   %edi
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 24             	sub    $0x24,%esp
  80045c:	8b 75 08             	mov    0x8(%ebp),%esi
  80045f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800462:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800465:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800466:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80046c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80046f:	50                   	push   %eax
  800470:	e8 27 ff ff ff       	call   80039c <fd_lookup>
  800475:	89 c3                	mov    %eax,%ebx
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	85 c0                	test   %eax,%eax
  80047c:	78 05                	js     800483 <fd_close+0x34>
	    || fd != fd2)
  80047e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800481:	74 16                	je     800499 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800483:	89 f8                	mov    %edi,%eax
  800485:	84 c0                	test   %al,%al
  800487:	b8 00 00 00 00       	mov    $0x0,%eax
  80048c:	0f 44 d8             	cmove  %eax,%ebx
}
  80048f:	89 d8                	mov    %ebx,%eax
  800491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800494:	5b                   	pop    %ebx
  800495:	5e                   	pop    %esi
  800496:	5f                   	pop    %edi
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80049f:	50                   	push   %eax
  8004a0:	ff 36                	pushl  (%esi)
  8004a2:	e8 49 ff ff ff       	call   8003f0 <dev_lookup>
  8004a7:	89 c3                	mov    %eax,%ebx
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	78 1a                	js     8004ca <fd_close+0x7b>
		if (dev->dev_close)
  8004b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	74 0b                	je     8004ca <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004bf:	83 ec 0c             	sub    $0xc,%esp
  8004c2:	56                   	push   %esi
  8004c3:	ff d0                	call   *%eax
  8004c5:	89 c3                	mov    %eax,%ebx
  8004c7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	56                   	push   %esi
  8004ce:	6a 00                	push   $0x0
  8004d0:	e8 f6 fc ff ff       	call   8001cb <sys_page_unmap>
	return r;
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	eb b5                	jmp    80048f <fd_close+0x40>

008004da <close>:

int
close(int fdnum)
{
  8004da:	f3 0f 1e fb          	endbr32 
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e7:	50                   	push   %eax
  8004e8:	ff 75 08             	pushl  0x8(%ebp)
  8004eb:	e8 ac fe ff ff       	call   80039c <fd_lookup>
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	79 02                	jns    8004f9 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004f7:	c9                   	leave  
  8004f8:	c3                   	ret    
		return fd_close(fd, 1);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	6a 01                	push   $0x1
  8004fe:	ff 75 f4             	pushl  -0xc(%ebp)
  800501:	e8 49 ff ff ff       	call   80044f <fd_close>
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	eb ec                	jmp    8004f7 <close+0x1d>

0080050b <close_all>:

void
close_all(void)
{
  80050b:	f3 0f 1e fb          	endbr32 
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	53                   	push   %ebx
  800513:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800516:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051b:	83 ec 0c             	sub    $0xc,%esp
  80051e:	53                   	push   %ebx
  80051f:	e8 b6 ff ff ff       	call   8004da <close>
	for (i = 0; i < MAXFD; i++)
  800524:	83 c3 01             	add    $0x1,%ebx
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	83 fb 20             	cmp    $0x20,%ebx
  80052d:	75 ec                	jne    80051b <close_all+0x10>
}
  80052f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800534:	f3 0f 1e fb          	endbr32 
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	57                   	push   %edi
  80053c:	56                   	push   %esi
  80053d:	53                   	push   %ebx
  80053e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800541:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	ff 75 08             	pushl  0x8(%ebp)
  800548:	e8 4f fe ff ff       	call   80039c <fd_lookup>
  80054d:	89 c3                	mov    %eax,%ebx
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 81 00 00 00    	js     8005db <dup+0xa7>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	ff 75 0c             	pushl  0xc(%ebp)
  800560:	e8 75 ff ff ff       	call   8004da <close>

	newfd = INDEX2FD(newfdnum);
  800565:	8b 75 0c             	mov    0xc(%ebp),%esi
  800568:	c1 e6 0c             	shl    $0xc,%esi
  80056b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800571:	83 c4 04             	add    $0x4,%esp
  800574:	ff 75 e4             	pushl  -0x1c(%ebp)
  800577:	e8 af fd ff ff       	call   80032b <fd2data>
  80057c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80057e:	89 34 24             	mov    %esi,(%esp)
  800581:	e8 a5 fd ff ff       	call   80032b <fd2data>
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058b:	89 d8                	mov    %ebx,%eax
  80058d:	c1 e8 16             	shr    $0x16,%eax
  800590:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800597:	a8 01                	test   $0x1,%al
  800599:	74 11                	je     8005ac <dup+0x78>
  80059b:	89 d8                	mov    %ebx,%eax
  80059d:	c1 e8 0c             	shr    $0xc,%eax
  8005a0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a7:	f6 c2 01             	test   $0x1,%dl
  8005aa:	75 39                	jne    8005e5 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005af:	89 d0                	mov    %edx,%eax
  8005b1:	c1 e8 0c             	shr    $0xc,%eax
  8005b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005bb:	83 ec 0c             	sub    $0xc,%esp
  8005be:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c3:	50                   	push   %eax
  8005c4:	56                   	push   %esi
  8005c5:	6a 00                	push   $0x0
  8005c7:	52                   	push   %edx
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d7 fb ff ff       	call   8001a6 <sys_page_map>
  8005cf:	89 c3                	mov    %eax,%ebx
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 31                	js     800609 <dup+0xd5>
		goto err;

	return newfdnum;
  8005d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005db:	89 d8                	mov    %ebx,%eax
  8005dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e0:	5b                   	pop    %ebx
  8005e1:	5e                   	pop    %esi
  8005e2:	5f                   	pop    %edi
  8005e3:	5d                   	pop    %ebp
  8005e4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	57                   	push   %edi
  8005f6:	6a 00                	push   $0x0
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c3                	mov    %eax,%ebx
  800602:	83 c4 20             	add    $0x20,%esp
  800605:	85 c0                	test   %eax,%eax
  800607:	79 a3                	jns    8005ac <dup+0x78>
	sys_page_unmap(0, newfd);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	56                   	push   %esi
  80060d:	6a 00                	push   $0x0
  80060f:	e8 b7 fb ff ff       	call   8001cb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800614:	83 c4 08             	add    $0x8,%esp
  800617:	57                   	push   %edi
  800618:	6a 00                	push   $0x0
  80061a:	e8 ac fb ff ff       	call   8001cb <sys_page_unmap>
	return r;
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	eb b7                	jmp    8005db <dup+0xa7>

00800624 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800624:	f3 0f 1e fb          	endbr32 
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	53                   	push   %ebx
  80062c:	83 ec 1c             	sub    $0x1c,%esp
  80062f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800632:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800635:	50                   	push   %eax
  800636:	53                   	push   %ebx
  800637:	e8 60 fd ff ff       	call   80039c <fd_lookup>
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	85 c0                	test   %eax,%eax
  800641:	78 3f                	js     800682 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800649:	50                   	push   %eax
  80064a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064d:	ff 30                	pushl  (%eax)
  80064f:	e8 9c fd ff ff       	call   8003f0 <dev_lookup>
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	85 c0                	test   %eax,%eax
  800659:	78 27                	js     800682 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065e:	8b 42 08             	mov    0x8(%edx),%eax
  800661:	83 e0 03             	and    $0x3,%eax
  800664:	83 f8 01             	cmp    $0x1,%eax
  800667:	74 1e                	je     800687 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800669:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80066c:	8b 40 08             	mov    0x8(%eax),%eax
  80066f:	85 c0                	test   %eax,%eax
  800671:	74 35                	je     8006a8 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800673:	83 ec 04             	sub    $0x4,%esp
  800676:	ff 75 10             	pushl  0x10(%ebp)
  800679:	ff 75 0c             	pushl  0xc(%ebp)
  80067c:	52                   	push   %edx
  80067d:	ff d0                	call   *%eax
  80067f:	83 c4 10             	add    $0x10,%esp
}
  800682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800685:	c9                   	leave  
  800686:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800687:	a1 08 40 80 00       	mov    0x804008,%eax
  80068c:	8b 40 48             	mov    0x48(%eax),%eax
  80068f:	83 ec 04             	sub    $0x4,%esp
  800692:	53                   	push   %ebx
  800693:	50                   	push   %eax
  800694:	68 cd 23 80 00       	push   $0x8023cd
  800699:	e8 68 0f 00 00       	call   801606 <cprintf>
		return -E_INVAL;
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a6:	eb da                	jmp    800682 <read+0x5e>
		return -E_NOT_SUPP;
  8006a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006ad:	eb d3                	jmp    800682 <read+0x5e>

008006af <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006af:	f3 0f 1e fb          	endbr32 
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	57                   	push   %edi
  8006b7:	56                   	push   %esi
  8006b8:	53                   	push   %ebx
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c7:	eb 02                	jmp    8006cb <readn+0x1c>
  8006c9:	01 c3                	add    %eax,%ebx
  8006cb:	39 f3                	cmp    %esi,%ebx
  8006cd:	73 21                	jae    8006f0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	89 f0                	mov    %esi,%eax
  8006d4:	29 d8                	sub    %ebx,%eax
  8006d6:	50                   	push   %eax
  8006d7:	89 d8                	mov    %ebx,%eax
  8006d9:	03 45 0c             	add    0xc(%ebp),%eax
  8006dc:	50                   	push   %eax
  8006dd:	57                   	push   %edi
  8006de:	e8 41 ff ff ff       	call   800624 <read>
		if (m < 0)
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	78 04                	js     8006ee <readn+0x3f>
			return m;
		if (m == 0)
  8006ea:	75 dd                	jne    8006c9 <readn+0x1a>
  8006ec:	eb 02                	jmp    8006f0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ee:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f0:	89 d8                	mov    %ebx,%eax
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fa:	f3 0f 1e fb          	endbr32 
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	53                   	push   %ebx
  800702:	83 ec 1c             	sub    $0x1c,%esp
  800705:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800708:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070b:	50                   	push   %eax
  80070c:	53                   	push   %ebx
  80070d:	e8 8a fc ff ff       	call   80039c <fd_lookup>
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	85 c0                	test   %eax,%eax
  800717:	78 3a                	js     800753 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800723:	ff 30                	pushl  (%eax)
  800725:	e8 c6 fc ff ff       	call   8003f0 <dev_lookup>
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 22                	js     800753 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800738:	74 1e                	je     800758 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80073a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073d:	8b 52 0c             	mov    0xc(%edx),%edx
  800740:	85 d2                	test   %edx,%edx
  800742:	74 35                	je     800779 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800744:	83 ec 04             	sub    $0x4,%esp
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	50                   	push   %eax
  80074e:	ff d2                	call   *%edx
  800750:	83 c4 10             	add    $0x10,%esp
}
  800753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800756:	c9                   	leave  
  800757:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800758:	a1 08 40 80 00       	mov    0x804008,%eax
  80075d:	8b 40 48             	mov    0x48(%eax),%eax
  800760:	83 ec 04             	sub    $0x4,%esp
  800763:	53                   	push   %ebx
  800764:	50                   	push   %eax
  800765:	68 e9 23 80 00       	push   $0x8023e9
  80076a:	e8 97 0e 00 00       	call   801606 <cprintf>
		return -E_INVAL;
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800777:	eb da                	jmp    800753 <write+0x59>
		return -E_NOT_SUPP;
  800779:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077e:	eb d3                	jmp    800753 <write+0x59>

00800780 <seek>:

int
seek(int fdnum, off_t offset)
{
  800780:	f3 0f 1e fb          	endbr32 
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078d:	50                   	push   %eax
  80078e:	ff 75 08             	pushl  0x8(%ebp)
  800791:	e8 06 fc ff ff       	call   80039c <fd_lookup>
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	85 c0                	test   %eax,%eax
  80079b:	78 0e                	js     8007ab <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ad:	f3 0f 1e fb          	endbr32 
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 1c             	sub    $0x1c,%esp
  8007b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	53                   	push   %ebx
  8007c0:	e8 d7 fb ff ff       	call   80039c <fd_lookup>
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	85 c0                	test   %eax,%eax
  8007ca:	78 37                	js     800803 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d6:	ff 30                	pushl  (%eax)
  8007d8:	e8 13 fc ff ff       	call   8003f0 <dev_lookup>
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	85 c0                	test   %eax,%eax
  8007e2:	78 1f                	js     800803 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007eb:	74 1b                	je     800808 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f0:	8b 52 18             	mov    0x18(%edx),%edx
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	74 32                	je     800829 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	ff 75 0c             	pushl  0xc(%ebp)
  8007fd:	50                   	push   %eax
  8007fe:	ff d2                	call   *%edx
  800800:	83 c4 10             	add    $0x10,%esp
}
  800803:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800806:	c9                   	leave  
  800807:	c3                   	ret    
			thisenv->env_id, fdnum);
  800808:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80080d:	8b 40 48             	mov    0x48(%eax),%eax
  800810:	83 ec 04             	sub    $0x4,%esp
  800813:	53                   	push   %ebx
  800814:	50                   	push   %eax
  800815:	68 ac 23 80 00       	push   $0x8023ac
  80081a:	e8 e7 0d 00 00       	call   801606 <cprintf>
		return -E_INVAL;
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800827:	eb da                	jmp    800803 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800829:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80082e:	eb d3                	jmp    800803 <ftruncate+0x56>

00800830 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800830:	f3 0f 1e fb          	endbr32 
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 1c             	sub    $0x1c,%esp
  80083b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800841:	50                   	push   %eax
  800842:	ff 75 08             	pushl  0x8(%ebp)
  800845:	e8 52 fb ff ff       	call   80039c <fd_lookup>
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	85 c0                	test   %eax,%eax
  80084f:	78 4b                	js     80089c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800857:	50                   	push   %eax
  800858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085b:	ff 30                	pushl  (%eax)
  80085d:	e8 8e fb ff ff       	call   8003f0 <dev_lookup>
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	85 c0                	test   %eax,%eax
  800867:	78 33                	js     80089c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800870:	74 2f                	je     8008a1 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800872:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800875:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087c:	00 00 00 
	stat->st_isdir = 0;
  80087f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800886:	00 00 00 
	stat->st_dev = dev;
  800889:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	53                   	push   %ebx
  800893:	ff 75 f0             	pushl  -0x10(%ebp)
  800896:	ff 50 14             	call   *0x14(%eax)
  800899:	83 c4 10             	add    $0x10,%esp
}
  80089c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a6:	eb f4                	jmp    80089c <fstat+0x6c>

008008a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008a8:	f3 0f 1e fb          	endbr32 
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	56                   	push   %esi
  8008b0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	6a 00                	push   $0x0
  8008b6:	ff 75 08             	pushl  0x8(%ebp)
  8008b9:	e8 01 02 00 00       	call   800abf <open>
  8008be:	89 c3                	mov    %eax,%ebx
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	78 1b                	js     8008e2 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	ff 75 0c             	pushl  0xc(%ebp)
  8008cd:	50                   	push   %eax
  8008ce:	e8 5d ff ff ff       	call   800830 <fstat>
  8008d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d5:	89 1c 24             	mov    %ebx,(%esp)
  8008d8:	e8 fd fb ff ff       	call   8004da <close>
	return r;
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	89 f3                	mov    %esi,%ebx
}
  8008e2:	89 d8                	mov    %ebx,%eax
  8008e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e7:	5b                   	pop    %ebx
  8008e8:	5e                   	pop    %esi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	89 c6                	mov    %eax,%esi
  8008f2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008fb:	74 27                	je     800924 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008fd:	6a 07                	push   $0x7
  8008ff:	68 00 50 80 00       	push   $0x805000
  800904:	56                   	push   %esi
  800905:	ff 35 00 40 80 00    	pushl  0x804000
  80090b:	e8 27 17 00 00       	call   802037 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800910:	83 c4 0c             	add    $0xc,%esp
  800913:	6a 00                	push   $0x0
  800915:	53                   	push   %ebx
  800916:	6a 00                	push   $0x0
  800918:	e8 ad 16 00 00       	call   801fca <ipc_recv>
}
  80091d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800924:	83 ec 0c             	sub    $0xc,%esp
  800927:	6a 01                	push   $0x1
  800929:	e8 61 17 00 00       	call   80208f <ipc_find_env>
  80092e:	a3 00 40 80 00       	mov    %eax,0x804000
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	eb c5                	jmp    8008fd <fsipc+0x12>

00800938 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800938:	f3 0f 1e fb          	endbr32 
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 40 0c             	mov    0xc(%eax),%eax
  800948:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80094d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800950:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800955:	ba 00 00 00 00       	mov    $0x0,%edx
  80095a:	b8 02 00 00 00       	mov    $0x2,%eax
  80095f:	e8 87 ff ff ff       	call   8008eb <fsipc>
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <devfile_flush>:
{
  800966:	f3 0f 1e fb          	endbr32 
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 40 0c             	mov    0xc(%eax),%eax
  800976:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	b8 06 00 00 00       	mov    $0x6,%eax
  800985:	e8 61 ff ff ff       	call   8008eb <fsipc>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <devfile_stat>:
{
  80098c:	f3 0f 1e fb          	endbr32 
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	83 ec 04             	sub    $0x4,%esp
  800997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8009af:	e8 37 ff ff ff       	call   8008eb <fsipc>
  8009b4:	85 c0                	test   %eax,%eax
  8009b6:	78 2c                	js     8009e4 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b8:	83 ec 08             	sub    $0x8,%esp
  8009bb:	68 00 50 80 00       	push   $0x805000
  8009c0:	53                   	push   %ebx
  8009c1:	e8 4a 12 00 00       	call   801c10 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dc:	83 c4 10             	add    $0x10,%esp
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <devfile_write>:
{
  8009e9:	f3 0f 1e fb          	endbr32 
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	83 ec 0c             	sub    $0xc,%esp
  8009f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009fb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a00:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
  800a06:	8b 52 0c             	mov    0xc(%edx),%edx
  800a09:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a0f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a14:	50                   	push   %eax
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	68 08 50 80 00       	push   $0x805008
  800a1d:	e8 ec 13 00 00       	call   801e0e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2c:	e8 ba fe ff ff       	call   8008eb <fsipc>
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <devfile_read>:
{
  800a33:	f3 0f 1e fb          	endbr32 
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 40 0c             	mov    0xc(%eax),%eax
  800a45:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5a:	e8 8c fe ff ff       	call   8008eb <fsipc>
  800a5f:	89 c3                	mov    %eax,%ebx
  800a61:	85 c0                	test   %eax,%eax
  800a63:	78 1f                	js     800a84 <devfile_read+0x51>
	assert(r <= n);
  800a65:	39 f0                	cmp    %esi,%eax
  800a67:	77 24                	ja     800a8d <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a69:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a6e:	7f 36                	jg     800aa6 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a70:	83 ec 04             	sub    $0x4,%esp
  800a73:	50                   	push   %eax
  800a74:	68 00 50 80 00       	push   $0x805000
  800a79:	ff 75 0c             	pushl  0xc(%ebp)
  800a7c:	e8 8d 13 00 00       	call   801e0e <memmove>
	return r;
  800a81:	83 c4 10             	add    $0x10,%esp
}
  800a84:	89 d8                	mov    %ebx,%eax
  800a86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    
	assert(r <= n);
  800a8d:	68 1c 24 80 00       	push   $0x80241c
  800a92:	68 23 24 80 00       	push   $0x802423
  800a97:	68 8c 00 00 00       	push   $0x8c
  800a9c:	68 38 24 80 00       	push   $0x802438
  800aa1:	e8 79 0a 00 00       	call   80151f <_panic>
	assert(r <= PGSIZE);
  800aa6:	68 43 24 80 00       	push   $0x802443
  800aab:	68 23 24 80 00       	push   $0x802423
  800ab0:	68 8d 00 00 00       	push   $0x8d
  800ab5:	68 38 24 80 00       	push   $0x802438
  800aba:	e8 60 0a 00 00       	call   80151f <_panic>

00800abf <open>:
{
  800abf:	f3 0f 1e fb          	endbr32 
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	83 ec 1c             	sub    $0x1c,%esp
  800acb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ace:	56                   	push   %esi
  800acf:	e8 f9 10 00 00       	call   801bcd <strlen>
  800ad4:	83 c4 10             	add    $0x10,%esp
  800ad7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800adc:	7f 6c                	jg     800b4a <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae4:	50                   	push   %eax
  800ae5:	e8 5c f8 ff ff       	call   800346 <fd_alloc>
  800aea:	89 c3                	mov    %eax,%ebx
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	85 c0                	test   %eax,%eax
  800af1:	78 3c                	js     800b2f <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	56                   	push   %esi
  800af7:	68 00 50 80 00       	push   $0x805000
  800afc:	e8 0f 11 00 00       	call   801c10 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b11:	e8 d5 fd ff ff       	call   8008eb <fsipc>
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	78 19                	js     800b38 <open+0x79>
	return fd2num(fd);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	ff 75 f4             	pushl  -0xc(%ebp)
  800b25:	e8 ed f7 ff ff       	call   800317 <fd2num>
  800b2a:	89 c3                	mov    %eax,%ebx
  800b2c:	83 c4 10             	add    $0x10,%esp
}
  800b2f:	89 d8                	mov    %ebx,%eax
  800b31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    
		fd_close(fd, 0);
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	6a 00                	push   $0x0
  800b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b40:	e8 0a f9 ff ff       	call   80044f <fd_close>
		return r;
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	eb e5                	jmp    800b2f <open+0x70>
		return -E_BAD_PATH;
  800b4a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b4f:	eb de                	jmp    800b2f <open+0x70>

00800b51 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b51:	f3 0f 1e fb          	endbr32 
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b60:	b8 08 00 00 00       	mov    $0x8,%eax
  800b65:	e8 81 fd ff ff       	call   8008eb <fsipc>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b6c:	f3 0f 1e fb          	endbr32 
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b76:	68 af 24 80 00       	push   $0x8024af
  800b7b:	ff 75 0c             	pushl  0xc(%ebp)
  800b7e:	e8 8d 10 00 00       	call   801c10 <strcpy>
	return 0;
}
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    

00800b8a <devsock_close>:
{
  800b8a:	f3 0f 1e fb          	endbr32 
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	53                   	push   %ebx
  800b92:	83 ec 10             	sub    $0x10,%esp
  800b95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b98:	53                   	push   %ebx
  800b99:	e8 2e 15 00 00       	call   8020cc <pageref>
  800b9e:	89 c2                	mov    %eax,%edx
  800ba0:	83 c4 10             	add    $0x10,%esp
		return 0;
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800ba8:	83 fa 01             	cmp    $0x1,%edx
  800bab:	74 05                	je     800bb2 <devsock_close+0x28>
}
  800bad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	ff 73 0c             	pushl  0xc(%ebx)
  800bb8:	e8 e3 02 00 00       	call   800ea0 <nsipc_close>
  800bbd:	83 c4 10             	add    $0x10,%esp
  800bc0:	eb eb                	jmp    800bad <devsock_close+0x23>

00800bc2 <devsock_write>:
{
  800bc2:	f3 0f 1e fb          	endbr32 
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bcc:	6a 00                	push   $0x0
  800bce:	ff 75 10             	pushl  0x10(%ebp)
  800bd1:	ff 75 0c             	pushl  0xc(%ebp)
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	ff 70 0c             	pushl  0xc(%eax)
  800bda:	e8 b5 03 00 00       	call   800f94 <nsipc_send>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <devsock_read>:
{
  800be1:	f3 0f 1e fb          	endbr32 
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800beb:	6a 00                	push   $0x0
  800bed:	ff 75 10             	pushl  0x10(%ebp)
  800bf0:	ff 75 0c             	pushl  0xc(%ebp)
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf6:	ff 70 0c             	pushl  0xc(%eax)
  800bf9:	e8 1f 03 00 00       	call   800f1d <nsipc_recv>
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <fd2sockid>:
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c06:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c09:	52                   	push   %edx
  800c0a:	50                   	push   %eax
  800c0b:	e8 8c f7 ff ff       	call   80039c <fd_lookup>
  800c10:	83 c4 10             	add    $0x10,%esp
  800c13:	85 c0                	test   %eax,%eax
  800c15:	78 10                	js     800c27 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1a:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800c20:	39 08                	cmp    %ecx,(%eax)
  800c22:	75 05                	jne    800c29 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c24:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    
		return -E_NOT_SUPP;
  800c29:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c2e:	eb f7                	jmp    800c27 <fd2sockid+0x27>

00800c30 <alloc_sockfd>:
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 1c             	sub    $0x1c,%esp
  800c38:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c3d:	50                   	push   %eax
  800c3e:	e8 03 f7 ff ff       	call   800346 <fd_alloc>
  800c43:	89 c3                	mov    %eax,%ebx
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	78 43                	js     800c8f <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c4c:	83 ec 04             	sub    $0x4,%esp
  800c4f:	68 07 04 00 00       	push   $0x407
  800c54:	ff 75 f4             	pushl  -0xc(%ebp)
  800c57:	6a 00                	push   $0x0
  800c59:	e8 22 f5 ff ff       	call   800180 <sys_page_alloc>
  800c5e:	89 c3                	mov    %eax,%ebx
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	85 c0                	test   %eax,%eax
  800c65:	78 28                	js     800c8f <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6a:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c70:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c75:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c7c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	e8 8f f6 ff ff       	call   800317 <fd2num>
  800c88:	89 c3                	mov    %eax,%ebx
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	eb 0c                	jmp    800c9b <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	56                   	push   %esi
  800c93:	e8 08 02 00 00       	call   800ea0 <nsipc_close>
		return r;
  800c98:	83 c4 10             	add    $0x10,%esp
}
  800c9b:	89 d8                	mov    %ebx,%eax
  800c9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <accept>:
{
  800ca4:	f3 0f 1e fb          	endbr32 
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	e8 4a ff ff ff       	call   800c00 <fd2sockid>
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	78 1b                	js     800cd5 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cba:	83 ec 04             	sub    $0x4,%esp
  800cbd:	ff 75 10             	pushl  0x10(%ebp)
  800cc0:	ff 75 0c             	pushl  0xc(%ebp)
  800cc3:	50                   	push   %eax
  800cc4:	e8 22 01 00 00       	call   800deb <nsipc_accept>
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	78 05                	js     800cd5 <accept+0x31>
	return alloc_sockfd(r);
  800cd0:	e8 5b ff ff ff       	call   800c30 <alloc_sockfd>
}
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <bind>:
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce4:	e8 17 ff ff ff       	call   800c00 <fd2sockid>
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	78 12                	js     800cff <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800ced:	83 ec 04             	sub    $0x4,%esp
  800cf0:	ff 75 10             	pushl  0x10(%ebp)
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	50                   	push   %eax
  800cf7:	e8 45 01 00 00       	call   800e41 <nsipc_bind>
  800cfc:	83 c4 10             	add    $0x10,%esp
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <shutdown>:
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	e8 ed fe ff ff       	call   800c00 <fd2sockid>
  800d13:	85 c0                	test   %eax,%eax
  800d15:	78 0f                	js     800d26 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800d17:	83 ec 08             	sub    $0x8,%esp
  800d1a:	ff 75 0c             	pushl  0xc(%ebp)
  800d1d:	50                   	push   %eax
  800d1e:	e8 57 01 00 00       	call   800e7a <nsipc_shutdown>
  800d23:	83 c4 10             	add    $0x10,%esp
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <connect>:
{
  800d28:	f3 0f 1e fb          	endbr32 
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	e8 c6 fe ff ff       	call   800c00 <fd2sockid>
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	78 12                	js     800d50 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d3e:	83 ec 04             	sub    $0x4,%esp
  800d41:	ff 75 10             	pushl  0x10(%ebp)
  800d44:	ff 75 0c             	pushl  0xc(%ebp)
  800d47:	50                   	push   %eax
  800d48:	e8 71 01 00 00       	call   800ebe <nsipc_connect>
  800d4d:	83 c4 10             	add    $0x10,%esp
}
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <listen>:
{
  800d52:	f3 0f 1e fb          	endbr32 
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	e8 9c fe ff ff       	call   800c00 <fd2sockid>
  800d64:	85 c0                	test   %eax,%eax
  800d66:	78 0f                	js     800d77 <listen+0x25>
	return nsipc_listen(r, backlog);
  800d68:	83 ec 08             	sub    $0x8,%esp
  800d6b:	ff 75 0c             	pushl  0xc(%ebp)
  800d6e:	50                   	push   %eax
  800d6f:	e8 83 01 00 00       	call   800ef7 <nsipc_listen>
  800d74:	83 c4 10             	add    $0x10,%esp
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d79:	f3 0f 1e fb          	endbr32 
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d83:	ff 75 10             	pushl  0x10(%ebp)
  800d86:	ff 75 0c             	pushl  0xc(%ebp)
  800d89:	ff 75 08             	pushl  0x8(%ebp)
  800d8c:	e8 65 02 00 00       	call   800ff6 <nsipc_socket>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 05                	js     800d9d <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d98:	e8 93 fe ff ff       	call   800c30 <alloc_sockfd>
}
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    

00800d9f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	53                   	push   %ebx
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800daf:	74 26                	je     800dd7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800db1:	6a 07                	push   $0x7
  800db3:	68 00 60 80 00       	push   $0x806000
  800db8:	53                   	push   %ebx
  800db9:	ff 35 04 40 80 00    	pushl  0x804004
  800dbf:	e8 73 12 00 00       	call   802037 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dc4:	83 c4 0c             	add    $0xc,%esp
  800dc7:	6a 00                	push   $0x0
  800dc9:	6a 00                	push   $0x0
  800dcb:	6a 00                	push   $0x0
  800dcd:	e8 f8 11 00 00       	call   801fca <ipc_recv>
}
  800dd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	6a 02                	push   $0x2
  800ddc:	e8 ae 12 00 00       	call   80208f <ipc_find_env>
  800de1:	a3 04 40 80 00       	mov    %eax,0x804004
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	eb c6                	jmp    800db1 <nsipc+0x12>

00800deb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800deb:	f3 0f 1e fb          	endbr32 
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dff:	8b 06                	mov    (%esi),%eax
  800e01:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e06:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0b:	e8 8f ff ff ff       	call   800d9f <nsipc>
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	85 c0                	test   %eax,%eax
  800e14:	79 09                	jns    800e1f <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e16:	89 d8                	mov    %ebx,%eax
  800e18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	ff 35 10 60 80 00    	pushl  0x806010
  800e28:	68 00 60 80 00       	push   $0x806000
  800e2d:	ff 75 0c             	pushl  0xc(%ebp)
  800e30:	e8 d9 0f 00 00       	call   801e0e <memmove>
		*addrlen = ret->ret_addrlen;
  800e35:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3a:	89 06                	mov    %eax,(%esi)
  800e3c:	83 c4 10             	add    $0x10,%esp
	return r;
  800e3f:	eb d5                	jmp    800e16 <nsipc_accept+0x2b>

00800e41 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e41:	f3 0f 1e fb          	endbr32 
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	53                   	push   %ebx
  800e49:	83 ec 08             	sub    $0x8,%esp
  800e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e57:	53                   	push   %ebx
  800e58:	ff 75 0c             	pushl  0xc(%ebp)
  800e5b:	68 04 60 80 00       	push   $0x806004
  800e60:	e8 a9 0f 00 00       	call   801e0e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e65:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e70:	e8 2a ff ff ff       	call   800d9f <nsipc>
}
  800e75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e78:	c9                   	leave  
  800e79:	c3                   	ret    

00800e7a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e7a:	f3 0f 1e fb          	endbr32 
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e94:	b8 03 00 00 00       	mov    $0x3,%eax
  800e99:	e8 01 ff ff ff       	call   800d9f <nsipc>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea0:	f3 0f 1e fb          	endbr32 
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb7:	e8 e3 fe ff ff       	call   800d9f <nsipc>
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebe:	f3 0f 1e fb          	endbr32 
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 08             	sub    $0x8,%esp
  800ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed4:	53                   	push   %ebx
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	68 04 60 80 00       	push   $0x806004
  800edd:	e8 2c 0f 00 00       	call   801e0e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee8:	b8 05 00 00 00       	mov    $0x5,%eax
  800eed:	e8 ad fe ff ff       	call   800d9f <nsipc>
}
  800ef2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef7:	f3 0f 1e fb          	endbr32 
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f11:	b8 06 00 00 00       	mov    $0x6,%eax
  800f16:	e8 84 fe ff ff       	call   800d9f <nsipc>
}
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f1d:	f3 0f 1e fb          	endbr32 
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f31:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f37:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f3f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f44:	e8 56 fe ff ff       	call   800d9f <nsipc>
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 26                	js     800f75 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f4f:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f55:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f5a:	0f 4e c6             	cmovle %esi,%eax
  800f5d:	39 c3                	cmp    %eax,%ebx
  800f5f:	7f 1d                	jg     800f7e <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	53                   	push   %ebx
  800f65:	68 00 60 80 00       	push   $0x806000
  800f6a:	ff 75 0c             	pushl  0xc(%ebp)
  800f6d:	e8 9c 0e 00 00       	call   801e0e <memmove>
  800f72:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f75:	89 d8                	mov    %ebx,%eax
  800f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f7e:	68 bb 24 80 00       	push   $0x8024bb
  800f83:	68 23 24 80 00       	push   $0x802423
  800f88:	6a 62                	push   $0x62
  800f8a:	68 d0 24 80 00       	push   $0x8024d0
  800f8f:	e8 8b 05 00 00       	call   80151f <_panic>

00800f94 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f94:	f3 0f 1e fb          	endbr32 
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800faa:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fb0:	7f 2e                	jg     800fe0 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	53                   	push   %ebx
  800fb6:	ff 75 0c             	pushl  0xc(%ebp)
  800fb9:	68 0c 60 80 00       	push   $0x80600c
  800fbe:	e8 4b 0e 00 00       	call   801e0e <memmove>
	nsipcbuf.send.req_size = size;
  800fc3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd6:	e8 c4 fd ff ff       	call   800d9f <nsipc>
}
  800fdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    
	assert(size < 1600);
  800fe0:	68 dc 24 80 00       	push   $0x8024dc
  800fe5:	68 23 24 80 00       	push   $0x802423
  800fea:	6a 6d                	push   $0x6d
  800fec:	68 d0 24 80 00       	push   $0x8024d0
  800ff1:	e8 29 05 00 00       	call   80151f <_panic>

00800ff6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ff6:	f3 0f 1e fb          	endbr32 
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801000:	8b 45 08             	mov    0x8(%ebp),%eax
  801003:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801008:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801010:	8b 45 10             	mov    0x10(%ebp),%eax
  801013:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801018:	b8 09 00 00 00       	mov    $0x9,%eax
  80101d:	e8 7d fd ff ff       	call   800d9f <nsipc>
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801024:	f3 0f 1e fb          	endbr32 
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	ff 75 08             	pushl  0x8(%ebp)
  801036:	e8 f0 f2 ff ff       	call   80032b <fd2data>
  80103b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80103d:	83 c4 08             	add    $0x8,%esp
  801040:	68 e8 24 80 00       	push   $0x8024e8
  801045:	53                   	push   %ebx
  801046:	e8 c5 0b 00 00       	call   801c10 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80104b:	8b 46 04             	mov    0x4(%esi),%eax
  80104e:	2b 06                	sub    (%esi),%eax
  801050:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801056:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80105d:	00 00 00 
	stat->st_dev = &devpipe;
  801060:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801067:	30 80 00 
	return 0;
}
  80106a:	b8 00 00 00 00       	mov    $0x0,%eax
  80106f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801076:	f3 0f 1e fb          	endbr32 
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801084:	53                   	push   %ebx
  801085:	6a 00                	push   $0x0
  801087:	e8 3f f1 ff ff       	call   8001cb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80108c:	89 1c 24             	mov    %ebx,(%esp)
  80108f:	e8 97 f2 ff ff       	call   80032b <fd2data>
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	50                   	push   %eax
  801098:	6a 00                	push   $0x0
  80109a:	e8 2c f1 ff ff       	call   8001cb <sys_page_unmap>
}
  80109f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <_pipeisclosed>:
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 1c             	sub    $0x1c,%esp
  8010ad:	89 c7                	mov    %eax,%edi
  8010af:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8010b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	57                   	push   %edi
  8010bd:	e8 0a 10 00 00       	call   8020cc <pageref>
  8010c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c5:	89 34 24             	mov    %esi,(%esp)
  8010c8:	e8 ff 0f 00 00       	call   8020cc <pageref>
		nn = thisenv->env_runs;
  8010cd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010d3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	39 cb                	cmp    %ecx,%ebx
  8010db:	74 1b                	je     8010f8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010dd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010e0:	75 cf                	jne    8010b1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010e2:	8b 42 58             	mov    0x58(%edx),%eax
  8010e5:	6a 01                	push   $0x1
  8010e7:	50                   	push   %eax
  8010e8:	53                   	push   %ebx
  8010e9:	68 ef 24 80 00       	push   $0x8024ef
  8010ee:	e8 13 05 00 00       	call   801606 <cprintf>
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	eb b9                	jmp    8010b1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010f8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010fb:	0f 94 c0             	sete   %al
  8010fe:	0f b6 c0             	movzbl %al,%eax
}
  801101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <devpipe_write>:
{
  801109:	f3 0f 1e fb          	endbr32 
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 28             	sub    $0x28,%esp
  801116:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801119:	56                   	push   %esi
  80111a:	e8 0c f2 ff ff       	call   80032b <fd2data>
  80111f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	bf 00 00 00 00       	mov    $0x0,%edi
  801129:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80112c:	74 4f                	je     80117d <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80112e:	8b 43 04             	mov    0x4(%ebx),%eax
  801131:	8b 0b                	mov    (%ebx),%ecx
  801133:	8d 51 20             	lea    0x20(%ecx),%edx
  801136:	39 d0                	cmp    %edx,%eax
  801138:	72 14                	jb     80114e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80113a:	89 da                	mov    %ebx,%edx
  80113c:	89 f0                	mov    %esi,%eax
  80113e:	e8 61 ff ff ff       	call   8010a4 <_pipeisclosed>
  801143:	85 c0                	test   %eax,%eax
  801145:	75 3b                	jne    801182 <devpipe_write+0x79>
			sys_yield();
  801147:	e8 11 f0 ff ff       	call   80015d <sys_yield>
  80114c:	eb e0                	jmp    80112e <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80114e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801151:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801155:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801158:	89 c2                	mov    %eax,%edx
  80115a:	c1 fa 1f             	sar    $0x1f,%edx
  80115d:	89 d1                	mov    %edx,%ecx
  80115f:	c1 e9 1b             	shr    $0x1b,%ecx
  801162:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801165:	83 e2 1f             	and    $0x1f,%edx
  801168:	29 ca                	sub    %ecx,%edx
  80116a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80116e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801172:	83 c0 01             	add    $0x1,%eax
  801175:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801178:	83 c7 01             	add    $0x1,%edi
  80117b:	eb ac                	jmp    801129 <devpipe_write+0x20>
	return i;
  80117d:	8b 45 10             	mov    0x10(%ebp),%eax
  801180:	eb 05                	jmp    801187 <devpipe_write+0x7e>
				return 0;
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118a:	5b                   	pop    %ebx
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <devpipe_read>:
{
  80118f:	f3 0f 1e fb          	endbr32 
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 18             	sub    $0x18,%esp
  80119c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80119f:	57                   	push   %edi
  8011a0:	e8 86 f1 ff ff       	call   80032b <fd2data>
  8011a5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	be 00 00 00 00       	mov    $0x0,%esi
  8011af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8011b2:	75 14                	jne    8011c8 <devpipe_read+0x39>
	return i;
  8011b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b7:	eb 02                	jmp    8011bb <devpipe_read+0x2c>
				return i;
  8011b9:	89 f0                	mov    %esi,%eax
}
  8011bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5f                   	pop    %edi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    
			sys_yield();
  8011c3:	e8 95 ef ff ff       	call   80015d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011c8:	8b 03                	mov    (%ebx),%eax
  8011ca:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011cd:	75 18                	jne    8011e7 <devpipe_read+0x58>
			if (i > 0)
  8011cf:	85 f6                	test   %esi,%esi
  8011d1:	75 e6                	jne    8011b9 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011d3:	89 da                	mov    %ebx,%edx
  8011d5:	89 f8                	mov    %edi,%eax
  8011d7:	e8 c8 fe ff ff       	call   8010a4 <_pipeisclosed>
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	74 e3                	je     8011c3 <devpipe_read+0x34>
				return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e5:	eb d4                	jmp    8011bb <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011e7:	99                   	cltd   
  8011e8:	c1 ea 1b             	shr    $0x1b,%edx
  8011eb:	01 d0                	add    %edx,%eax
  8011ed:	83 e0 1f             	and    $0x1f,%eax
  8011f0:	29 d0                	sub    %edx,%eax
  8011f2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011fd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801200:	83 c6 01             	add    $0x1,%esi
  801203:	eb aa                	jmp    8011af <devpipe_read+0x20>

00801205 <pipe>:
{
  801205:	f3 0f 1e fb          	endbr32 
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	e8 2c f1 ff ff       	call   800346 <fd_alloc>
  80121a:	89 c3                	mov    %eax,%ebx
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	0f 88 23 01 00 00    	js     80134a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	68 07 04 00 00       	push   $0x407
  80122f:	ff 75 f4             	pushl  -0xc(%ebp)
  801232:	6a 00                	push   $0x0
  801234:	e8 47 ef ff ff       	call   800180 <sys_page_alloc>
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	0f 88 04 01 00 00    	js     80134a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	e8 f4 f0 ff ff       	call   800346 <fd_alloc>
  801252:	89 c3                	mov    %eax,%ebx
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	0f 88 db 00 00 00    	js     80133a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	68 07 04 00 00       	push   $0x407
  801267:	ff 75 f0             	pushl  -0x10(%ebp)
  80126a:	6a 00                	push   $0x0
  80126c:	e8 0f ef ff ff       	call   800180 <sys_page_alloc>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	0f 88 bc 00 00 00    	js     80133a <pipe+0x135>
	va = fd2data(fd0);
  80127e:	83 ec 0c             	sub    $0xc,%esp
  801281:	ff 75 f4             	pushl  -0xc(%ebp)
  801284:	e8 a2 f0 ff ff       	call   80032b <fd2data>
  801289:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128b:	83 c4 0c             	add    $0xc,%esp
  80128e:	68 07 04 00 00       	push   $0x407
  801293:	50                   	push   %eax
  801294:	6a 00                	push   $0x0
  801296:	e8 e5 ee ff ff       	call   800180 <sys_page_alloc>
  80129b:	89 c3                	mov    %eax,%ebx
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	0f 88 82 00 00 00    	js     80132a <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ae:	e8 78 f0 ff ff       	call   80032b <fd2data>
  8012b3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012ba:	50                   	push   %eax
  8012bb:	6a 00                	push   $0x0
  8012bd:	56                   	push   %esi
  8012be:	6a 00                	push   $0x0
  8012c0:	e8 e1 ee ff ff       	call   8001a6 <sys_page_map>
  8012c5:	89 c3                	mov    %eax,%ebx
  8012c7:	83 c4 20             	add    $0x20,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 4e                	js     80131c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8012ce:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012db:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012e5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012f1:	83 ec 0c             	sub    $0xc,%esp
  8012f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f7:	e8 1b f0 ff ff       	call   800317 <fd2num>
  8012fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ff:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801301:	83 c4 04             	add    $0x4,%esp
  801304:	ff 75 f0             	pushl  -0x10(%ebp)
  801307:	e8 0b f0 ff ff       	call   800317 <fd2num>
  80130c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	bb 00 00 00 00       	mov    $0x0,%ebx
  80131a:	eb 2e                	jmp    80134a <pipe+0x145>
	sys_page_unmap(0, va);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	56                   	push   %esi
  801320:	6a 00                	push   $0x0
  801322:	e8 a4 ee ff ff       	call   8001cb <sys_page_unmap>
  801327:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	ff 75 f0             	pushl  -0x10(%ebp)
  801330:	6a 00                	push   $0x0
  801332:	e8 94 ee ff ff       	call   8001cb <sys_page_unmap>
  801337:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	ff 75 f4             	pushl  -0xc(%ebp)
  801340:	6a 00                	push   $0x0
  801342:	e8 84 ee ff ff       	call   8001cb <sys_page_unmap>
  801347:	83 c4 10             	add    $0x10,%esp
}
  80134a:	89 d8                	mov    %ebx,%eax
  80134c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134f:	5b                   	pop    %ebx
  801350:	5e                   	pop    %esi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <pipeisclosed>:
{
  801353:	f3 0f 1e fb          	endbr32 
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	ff 75 08             	pushl  0x8(%ebp)
  801364:	e8 33 f0 ff ff       	call   80039c <fd_lookup>
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 18                	js     801388 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	ff 75 f4             	pushl  -0xc(%ebp)
  801376:	e8 b0 ef ff ff       	call   80032b <fd2data>
  80137b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801380:	e8 1f fd ff ff       	call   8010a4 <_pipeisclosed>
  801385:	83 c4 10             	add    $0x10,%esp
}
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80138a:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	c3                   	ret    

00801394 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801394:	f3 0f 1e fb          	endbr32 
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80139e:	68 07 25 80 00       	push   $0x802507
  8013a3:	ff 75 0c             	pushl  0xc(%ebp)
  8013a6:	e8 65 08 00 00       	call   801c10 <strcpy>
	return 0;
}
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <devcons_write>:
{
  8013b2:	f3 0f 1e fb          	endbr32 
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	57                   	push   %edi
  8013ba:	56                   	push   %esi
  8013bb:	53                   	push   %ebx
  8013bc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8013c2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013cd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d0:	73 31                	jae    801403 <devcons_write+0x51>
		m = n - tot;
  8013d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d5:	29 f3                	sub    %esi,%ebx
  8013d7:	83 fb 7f             	cmp    $0x7f,%ebx
  8013da:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013df:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013e2:	83 ec 04             	sub    $0x4,%esp
  8013e5:	53                   	push   %ebx
  8013e6:	89 f0                	mov    %esi,%eax
  8013e8:	03 45 0c             	add    0xc(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	57                   	push   %edi
  8013ed:	e8 1c 0a 00 00       	call   801e0e <memmove>
		sys_cputs(buf, m);
  8013f2:	83 c4 08             	add    $0x8,%esp
  8013f5:	53                   	push   %ebx
  8013f6:	57                   	push   %edi
  8013f7:	e8 d5 ec ff ff       	call   8000d1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013fc:	01 de                	add    %ebx,%esi
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	eb ca                	jmp    8013cd <devcons_write+0x1b>
}
  801403:	89 f0                	mov    %esi,%eax
  801405:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5f                   	pop    %edi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <devcons_read>:
{
  80140d:	f3 0f 1e fb          	endbr32 
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80141c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801420:	74 21                	je     801443 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801422:	e8 cc ec ff ff       	call   8000f3 <sys_cgetc>
  801427:	85 c0                	test   %eax,%eax
  801429:	75 07                	jne    801432 <devcons_read+0x25>
		sys_yield();
  80142b:	e8 2d ed ff ff       	call   80015d <sys_yield>
  801430:	eb f0                	jmp    801422 <devcons_read+0x15>
	if (c < 0)
  801432:	78 0f                	js     801443 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801434:	83 f8 04             	cmp    $0x4,%eax
  801437:	74 0c                	je     801445 <devcons_read+0x38>
	*(char*)vbuf = c;
  801439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143c:	88 02                	mov    %al,(%edx)
	return 1;
  80143e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    
		return 0;
  801445:	b8 00 00 00 00       	mov    $0x0,%eax
  80144a:	eb f7                	jmp    801443 <devcons_read+0x36>

0080144c <cputchar>:
{
  80144c:	f3 0f 1e fb          	endbr32 
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80145c:	6a 01                	push   $0x1
  80145e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	e8 6a ec ff ff       	call   8000d1 <sys_cputs>
}
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <getchar>:
{
  80146c:	f3 0f 1e fb          	endbr32 
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801476:	6a 01                	push   $0x1
  801478:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	6a 00                	push   $0x0
  80147e:	e8 a1 f1 ff ff       	call   800624 <read>
	if (r < 0)
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 06                	js     801490 <getchar+0x24>
	if (r < 1)
  80148a:	74 06                	je     801492 <getchar+0x26>
	return c;
  80148c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    
		return -E_EOF;
  801492:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801497:	eb f7                	jmp    801490 <getchar+0x24>

00801499 <iscons>:
{
  801499:	f3 0f 1e fb          	endbr32 
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a6:	50                   	push   %eax
  8014a7:	ff 75 08             	pushl  0x8(%ebp)
  8014aa:	e8 ed ee ff ff       	call   80039c <fd_lookup>
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 11                	js     8014c7 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8014b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b9:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014bf:	39 10                	cmp    %edx,(%eax)
  8014c1:	0f 94 c0             	sete   %al
  8014c4:	0f b6 c0             	movzbl %al,%eax
}
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <opencons>:
{
  8014c9:	f3 0f 1e fb          	endbr32 
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	e8 6a ee ff ff       	call   800346 <fd_alloc>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 3a                	js     80151d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	68 07 04 00 00       	push   $0x407
  8014eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ee:	6a 00                	push   $0x0
  8014f0:	e8 8b ec ff ff       	call   800180 <sys_page_alloc>
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 21                	js     80151d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ff:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801505:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801511:	83 ec 0c             	sub    $0xc,%esp
  801514:	50                   	push   %eax
  801515:	e8 fd ed ff ff       	call   800317 <fd2num>
  80151a:	83 c4 10             	add    $0x10,%esp
}
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80151f:	f3 0f 1e fb          	endbr32 
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801528:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80152b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801531:	e8 04 ec ff ff       	call   80013a <sys_getenvid>
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	ff 75 0c             	pushl  0xc(%ebp)
  80153c:	ff 75 08             	pushl  0x8(%ebp)
  80153f:	56                   	push   %esi
  801540:	50                   	push   %eax
  801541:	68 14 25 80 00       	push   $0x802514
  801546:	e8 bb 00 00 00       	call   801606 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80154b:	83 c4 18             	add    $0x18,%esp
  80154e:	53                   	push   %ebx
  80154f:	ff 75 10             	pushl  0x10(%ebp)
  801552:	e8 5a 00 00 00       	call   8015b1 <vcprintf>
	cprintf("\n");
  801557:	c7 04 24 00 25 80 00 	movl   $0x802500,(%esp)
  80155e:	e8 a3 00 00 00       	call   801606 <cprintf>
  801563:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801566:	cc                   	int3   
  801567:	eb fd                	jmp    801566 <_panic+0x47>

00801569 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801569:	f3 0f 1e fb          	endbr32 
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	53                   	push   %ebx
  801571:	83 ec 04             	sub    $0x4,%esp
  801574:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801577:	8b 13                	mov    (%ebx),%edx
  801579:	8d 42 01             	lea    0x1(%edx),%eax
  80157c:	89 03                	mov    %eax,(%ebx)
  80157e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801581:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801585:	3d ff 00 00 00       	cmp    $0xff,%eax
  80158a:	74 09                	je     801595 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80158c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801593:	c9                   	leave  
  801594:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	68 ff 00 00 00       	push   $0xff
  80159d:	8d 43 08             	lea    0x8(%ebx),%eax
  8015a0:	50                   	push   %eax
  8015a1:	e8 2b eb ff ff       	call   8000d1 <sys_cputs>
		b->idx = 0;
  8015a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb db                	jmp    80158c <putch+0x23>

008015b1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015b1:	f3 0f 1e fb          	endbr32 
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015c5:	00 00 00 
	b.cnt = 0;
  8015c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015d2:	ff 75 0c             	pushl  0xc(%ebp)
  8015d5:	ff 75 08             	pushl  0x8(%ebp)
  8015d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	68 69 15 80 00       	push   $0x801569
  8015e4:	e8 20 01 00 00       	call   801709 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015e9:	83 c4 08             	add    $0x8,%esp
  8015ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	e8 d3 ea ff ff       	call   8000d1 <sys_cputs>

	return b.cnt;
}
  8015fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801606:	f3 0f 1e fb          	endbr32 
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801610:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801613:	50                   	push   %eax
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 95 ff ff ff       	call   8015b1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	57                   	push   %edi
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 1c             	sub    $0x1c,%esp
  801627:	89 c7                	mov    %eax,%edi
  801629:	89 d6                	mov    %edx,%esi
  80162b:	8b 45 08             	mov    0x8(%ebp),%eax
  80162e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801631:	89 d1                	mov    %edx,%ecx
  801633:	89 c2                	mov    %eax,%edx
  801635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801638:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80163b:	8b 45 10             	mov    0x10(%ebp),%eax
  80163e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801641:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801644:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80164b:	39 c2                	cmp    %eax,%edx
  80164d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801650:	72 3e                	jb     801690 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801652:	83 ec 0c             	sub    $0xc,%esp
  801655:	ff 75 18             	pushl  0x18(%ebp)
  801658:	83 eb 01             	sub    $0x1,%ebx
  80165b:	53                   	push   %ebx
  80165c:	50                   	push   %eax
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	ff 75 e4             	pushl  -0x1c(%ebp)
  801663:	ff 75 e0             	pushl  -0x20(%ebp)
  801666:	ff 75 dc             	pushl  -0x24(%ebp)
  801669:	ff 75 d8             	pushl  -0x28(%ebp)
  80166c:	e8 9f 0a 00 00       	call   802110 <__udivdi3>
  801671:	83 c4 18             	add    $0x18,%esp
  801674:	52                   	push   %edx
  801675:	50                   	push   %eax
  801676:	89 f2                	mov    %esi,%edx
  801678:	89 f8                	mov    %edi,%eax
  80167a:	e8 9f ff ff ff       	call   80161e <printnum>
  80167f:	83 c4 20             	add    $0x20,%esp
  801682:	eb 13                	jmp    801697 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801684:	83 ec 08             	sub    $0x8,%esp
  801687:	56                   	push   %esi
  801688:	ff 75 18             	pushl  0x18(%ebp)
  80168b:	ff d7                	call   *%edi
  80168d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801690:	83 eb 01             	sub    $0x1,%ebx
  801693:	85 db                	test   %ebx,%ebx
  801695:	7f ed                	jg     801684 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	56                   	push   %esi
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a4:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a7:	ff 75 d8             	pushl  -0x28(%ebp)
  8016aa:	e8 71 0b 00 00       	call   802220 <__umoddi3>
  8016af:	83 c4 14             	add    $0x14,%esp
  8016b2:	0f be 80 37 25 80 00 	movsbl 0x802537(%eax),%eax
  8016b9:	50                   	push   %eax
  8016ba:	ff d7                	call   *%edi
}
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c2:	5b                   	pop    %ebx
  8016c3:	5e                   	pop    %esi
  8016c4:	5f                   	pop    %edi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c7:	f3 0f 1e fb          	endbr32 
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016d1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016d5:	8b 10                	mov    (%eax),%edx
  8016d7:	3b 50 04             	cmp    0x4(%eax),%edx
  8016da:	73 0a                	jae    8016e6 <sprintputch+0x1f>
		*b->buf++ = ch;
  8016dc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016df:	89 08                	mov    %ecx,(%eax)
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	88 02                	mov    %al,(%edx)
}
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <printfmt>:
{
  8016e8:	f3 0f 1e fb          	endbr32 
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016f5:	50                   	push   %eax
  8016f6:	ff 75 10             	pushl  0x10(%ebp)
  8016f9:	ff 75 0c             	pushl  0xc(%ebp)
  8016fc:	ff 75 08             	pushl  0x8(%ebp)
  8016ff:	e8 05 00 00 00       	call   801709 <vprintfmt>
}
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <vprintfmt>:
{
  801709:	f3 0f 1e fb          	endbr32 
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	57                   	push   %edi
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
  801713:	83 ec 3c             	sub    $0x3c,%esp
  801716:	8b 75 08             	mov    0x8(%ebp),%esi
  801719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80171f:	e9 8e 03 00 00       	jmp    801ab2 <vprintfmt+0x3a9>
		padc = ' ';
  801724:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801728:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80172f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801736:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80173d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801742:	8d 47 01             	lea    0x1(%edi),%eax
  801745:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801748:	0f b6 17             	movzbl (%edi),%edx
  80174b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80174e:	3c 55                	cmp    $0x55,%al
  801750:	0f 87 df 03 00 00    	ja     801b35 <vprintfmt+0x42c>
  801756:	0f b6 c0             	movzbl %al,%eax
  801759:	3e ff 24 85 80 26 80 	notrack jmp *0x802680(,%eax,4)
  801760:	00 
  801761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801764:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801768:	eb d8                	jmp    801742 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80176a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80176d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801771:	eb cf                	jmp    801742 <vprintfmt+0x39>
  801773:	0f b6 d2             	movzbl %dl,%edx
  801776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
  80177e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801781:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801784:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801788:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80178b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80178e:	83 f9 09             	cmp    $0x9,%ecx
  801791:	77 55                	ja     8017e8 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801793:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801796:	eb e9                	jmp    801781 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801798:	8b 45 14             	mov    0x14(%ebp),%eax
  80179b:	8b 00                	mov    (%eax),%eax
  80179d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a3:	8d 40 04             	lea    0x4(%eax),%eax
  8017a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8017ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017b0:	79 90                	jns    801742 <vprintfmt+0x39>
				width = precision, precision = -1;
  8017b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8017b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8017bf:	eb 81                	jmp    801742 <vprintfmt+0x39>
  8017c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cb:	0f 49 d0             	cmovns %eax,%edx
  8017ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017d4:	e9 69 ff ff ff       	jmp    801742 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017dc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017e3:	e9 5a ff ff ff       	jmp    801742 <vprintfmt+0x39>
  8017e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017ee:	eb bc                	jmp    8017ac <vprintfmt+0xa3>
			lflag++;
  8017f0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017f6:	e9 47 ff ff ff       	jmp    801742 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fe:	8d 78 04             	lea    0x4(%eax),%edi
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	53                   	push   %ebx
  801805:	ff 30                	pushl  (%eax)
  801807:	ff d6                	call   *%esi
			break;
  801809:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80180c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80180f:	e9 9b 02 00 00       	jmp    801aaf <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  801814:	8b 45 14             	mov    0x14(%ebp),%eax
  801817:	8d 78 04             	lea    0x4(%eax),%edi
  80181a:	8b 00                	mov    (%eax),%eax
  80181c:	99                   	cltd   
  80181d:	31 d0                	xor    %edx,%eax
  80181f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801821:	83 f8 0f             	cmp    $0xf,%eax
  801824:	7f 23                	jg     801849 <vprintfmt+0x140>
  801826:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  80182d:	85 d2                	test   %edx,%edx
  80182f:	74 18                	je     801849 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801831:	52                   	push   %edx
  801832:	68 35 24 80 00       	push   $0x802435
  801837:	53                   	push   %ebx
  801838:	56                   	push   %esi
  801839:	e8 aa fe ff ff       	call   8016e8 <printfmt>
  80183e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801841:	89 7d 14             	mov    %edi,0x14(%ebp)
  801844:	e9 66 02 00 00       	jmp    801aaf <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  801849:	50                   	push   %eax
  80184a:	68 4f 25 80 00       	push   $0x80254f
  80184f:	53                   	push   %ebx
  801850:	56                   	push   %esi
  801851:	e8 92 fe ff ff       	call   8016e8 <printfmt>
  801856:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801859:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80185c:	e9 4e 02 00 00       	jmp    801aaf <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801861:	8b 45 14             	mov    0x14(%ebp),%eax
  801864:	83 c0 04             	add    $0x4,%eax
  801867:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80186a:	8b 45 14             	mov    0x14(%ebp),%eax
  80186d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80186f:	85 d2                	test   %edx,%edx
  801871:	b8 48 25 80 00       	mov    $0x802548,%eax
  801876:	0f 45 c2             	cmovne %edx,%eax
  801879:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80187c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801880:	7e 06                	jle    801888 <vprintfmt+0x17f>
  801882:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801886:	75 0d                	jne    801895 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801888:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80188b:	89 c7                	mov    %eax,%edi
  80188d:	03 45 e0             	add    -0x20(%ebp),%eax
  801890:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801893:	eb 55                	jmp    8018ea <vprintfmt+0x1e1>
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	ff 75 d8             	pushl  -0x28(%ebp)
  80189b:	ff 75 cc             	pushl  -0x34(%ebp)
  80189e:	e8 46 03 00 00       	call   801be9 <strnlen>
  8018a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018a6:	29 c2                	sub    %eax,%edx
  8018a8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8018b0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8018b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b7:	85 ff                	test   %edi,%edi
  8018b9:	7e 11                	jle    8018cc <vprintfmt+0x1c3>
					putch(padc, putdat);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	53                   	push   %ebx
  8018bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c4:	83 ef 01             	sub    $0x1,%edi
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb eb                	jmp    8018b7 <vprintfmt+0x1ae>
  8018cc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018cf:	85 d2                	test   %edx,%edx
  8018d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d6:	0f 49 c2             	cmovns %edx,%eax
  8018d9:	29 c2                	sub    %eax,%edx
  8018db:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018de:	eb a8                	jmp    801888 <vprintfmt+0x17f>
					putch(ch, putdat);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	53                   	push   %ebx
  8018e4:	52                   	push   %edx
  8018e5:	ff d6                	call   *%esi
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018ed:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ef:	83 c7 01             	add    $0x1,%edi
  8018f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018f6:	0f be d0             	movsbl %al,%edx
  8018f9:	85 d2                	test   %edx,%edx
  8018fb:	74 4b                	je     801948 <vprintfmt+0x23f>
  8018fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801901:	78 06                	js     801909 <vprintfmt+0x200>
  801903:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801907:	78 1e                	js     801927 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  801909:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80190d:	74 d1                	je     8018e0 <vprintfmt+0x1d7>
  80190f:	0f be c0             	movsbl %al,%eax
  801912:	83 e8 20             	sub    $0x20,%eax
  801915:	83 f8 5e             	cmp    $0x5e,%eax
  801918:	76 c6                	jbe    8018e0 <vprintfmt+0x1d7>
					putch('?', putdat);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	53                   	push   %ebx
  80191e:	6a 3f                	push   $0x3f
  801920:	ff d6                	call   *%esi
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	eb c3                	jmp    8018ea <vprintfmt+0x1e1>
  801927:	89 cf                	mov    %ecx,%edi
  801929:	eb 0e                	jmp    801939 <vprintfmt+0x230>
				putch(' ', putdat);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	53                   	push   %ebx
  80192f:	6a 20                	push   $0x20
  801931:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801933:	83 ef 01             	sub    $0x1,%edi
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	85 ff                	test   %edi,%edi
  80193b:	7f ee                	jg     80192b <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80193d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801940:	89 45 14             	mov    %eax,0x14(%ebp)
  801943:	e9 67 01 00 00       	jmp    801aaf <vprintfmt+0x3a6>
  801948:	89 cf                	mov    %ecx,%edi
  80194a:	eb ed                	jmp    801939 <vprintfmt+0x230>
	if (lflag >= 2)
  80194c:	83 f9 01             	cmp    $0x1,%ecx
  80194f:	7f 1b                	jg     80196c <vprintfmt+0x263>
	else if (lflag)
  801951:	85 c9                	test   %ecx,%ecx
  801953:	74 63                	je     8019b8 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801955:	8b 45 14             	mov    0x14(%ebp),%eax
  801958:	8b 00                	mov    (%eax),%eax
  80195a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195d:	99                   	cltd   
  80195e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801961:	8b 45 14             	mov    0x14(%ebp),%eax
  801964:	8d 40 04             	lea    0x4(%eax),%eax
  801967:	89 45 14             	mov    %eax,0x14(%ebp)
  80196a:	eb 17                	jmp    801983 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80196c:	8b 45 14             	mov    0x14(%ebp),%eax
  80196f:	8b 50 04             	mov    0x4(%eax),%edx
  801972:	8b 00                	mov    (%eax),%eax
  801974:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801977:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80197a:	8b 45 14             	mov    0x14(%ebp),%eax
  80197d:	8d 40 08             	lea    0x8(%eax),%eax
  801980:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801983:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801986:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801989:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80198e:	85 c9                	test   %ecx,%ecx
  801990:	0f 89 ff 00 00 00    	jns    801a95 <vprintfmt+0x38c>
				putch('-', putdat);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	53                   	push   %ebx
  80199a:	6a 2d                	push   $0x2d
  80199c:	ff d6                	call   *%esi
				num = -(long long) num;
  80199e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019a4:	f7 da                	neg    %edx
  8019a6:	83 d1 00             	adc    $0x0,%ecx
  8019a9:	f7 d9                	neg    %ecx
  8019ab:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8019ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019b3:	e9 dd 00 00 00       	jmp    801a95 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8019b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bb:	8b 00                	mov    (%eax),%eax
  8019bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c0:	99                   	cltd   
  8019c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c7:	8d 40 04             	lea    0x4(%eax),%eax
  8019ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8019cd:	eb b4                	jmp    801983 <vprintfmt+0x27a>
	if (lflag >= 2)
  8019cf:	83 f9 01             	cmp    $0x1,%ecx
  8019d2:	7f 1e                	jg     8019f2 <vprintfmt+0x2e9>
	else if (lflag)
  8019d4:	85 c9                	test   %ecx,%ecx
  8019d6:	74 32                	je     801a0a <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019db:	8b 10                	mov    (%eax),%edx
  8019dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e2:	8d 40 04             	lea    0x4(%eax),%eax
  8019e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019e8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019ed:	e9 a3 00 00 00       	jmp    801a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f5:	8b 10                	mov    (%eax),%edx
  8019f7:	8b 48 04             	mov    0x4(%eax),%ecx
  8019fa:	8d 40 08             	lea    0x8(%eax),%eax
  8019fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801a00:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  801a05:	e9 8b 00 00 00       	jmp    801a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0d:	8b 10                	mov    (%eax),%edx
  801a0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a14:	8d 40 04             	lea    0x4(%eax),%eax
  801a17:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801a1a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801a1f:	eb 74                	jmp    801a95 <vprintfmt+0x38c>
	if (lflag >= 2)
  801a21:	83 f9 01             	cmp    $0x1,%ecx
  801a24:	7f 1b                	jg     801a41 <vprintfmt+0x338>
	else if (lflag)
  801a26:	85 c9                	test   %ecx,%ecx
  801a28:	74 2c                	je     801a56 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2d:	8b 10                	mov    (%eax),%edx
  801a2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a34:	8d 40 04             	lea    0x4(%eax),%eax
  801a37:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a3a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a3f:	eb 54                	jmp    801a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a41:	8b 45 14             	mov    0x14(%ebp),%eax
  801a44:	8b 10                	mov    (%eax),%edx
  801a46:	8b 48 04             	mov    0x4(%eax),%ecx
  801a49:	8d 40 08             	lea    0x8(%eax),%eax
  801a4c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a4f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a54:	eb 3f                	jmp    801a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a56:	8b 45 14             	mov    0x14(%ebp),%eax
  801a59:	8b 10                	mov    (%eax),%edx
  801a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a60:	8d 40 04             	lea    0x4(%eax),%eax
  801a63:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a66:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a6b:	eb 28                	jmp    801a95 <vprintfmt+0x38c>
			putch('0', putdat);
  801a6d:	83 ec 08             	sub    $0x8,%esp
  801a70:	53                   	push   %ebx
  801a71:	6a 30                	push   $0x30
  801a73:	ff d6                	call   *%esi
			putch('x', putdat);
  801a75:	83 c4 08             	add    $0x8,%esp
  801a78:	53                   	push   %ebx
  801a79:	6a 78                	push   $0x78
  801a7b:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a7d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a80:	8b 10                	mov    (%eax),%edx
  801a82:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a87:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a8a:	8d 40 04             	lea    0x4(%eax),%eax
  801a8d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a90:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a9c:	57                   	push   %edi
  801a9d:	ff 75 e0             	pushl  -0x20(%ebp)
  801aa0:	50                   	push   %eax
  801aa1:	51                   	push   %ecx
  801aa2:	52                   	push   %edx
  801aa3:	89 da                	mov    %ebx,%edx
  801aa5:	89 f0                	mov    %esi,%eax
  801aa7:	e8 72 fb ff ff       	call   80161e <printnum>
			break;
  801aac:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801aaf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801ab2:	83 c7 01             	add    $0x1,%edi
  801ab5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ab9:	83 f8 25             	cmp    $0x25,%eax
  801abc:	0f 84 62 fc ff ff    	je     801724 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	0f 84 8b 00 00 00    	je     801b55 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	53                   	push   %ebx
  801ace:	50                   	push   %eax
  801acf:	ff d6                	call   *%esi
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	eb dc                	jmp    801ab2 <vprintfmt+0x3a9>
	if (lflag >= 2)
  801ad6:	83 f9 01             	cmp    $0x1,%ecx
  801ad9:	7f 1b                	jg     801af6 <vprintfmt+0x3ed>
	else if (lflag)
  801adb:	85 c9                	test   %ecx,%ecx
  801add:	74 2c                	je     801b0b <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801adf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae2:	8b 10                	mov    (%eax),%edx
  801ae4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ae9:	8d 40 04             	lea    0x4(%eax),%eax
  801aec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aef:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801af4:	eb 9f                	jmp    801a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801af6:	8b 45 14             	mov    0x14(%ebp),%eax
  801af9:	8b 10                	mov    (%eax),%edx
  801afb:	8b 48 04             	mov    0x4(%eax),%ecx
  801afe:	8d 40 08             	lea    0x8(%eax),%eax
  801b01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b04:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801b09:	eb 8a                	jmp    801a95 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801b0b:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0e:	8b 10                	mov    (%eax),%edx
  801b10:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b15:	8d 40 04             	lea    0x4(%eax),%eax
  801b18:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b1b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801b20:	e9 70 ff ff ff       	jmp    801a95 <vprintfmt+0x38c>
			putch(ch, putdat);
  801b25:	83 ec 08             	sub    $0x8,%esp
  801b28:	53                   	push   %ebx
  801b29:	6a 25                	push   $0x25
  801b2b:	ff d6                	call   *%esi
			break;
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	e9 7a ff ff ff       	jmp    801aaf <vprintfmt+0x3a6>
			putch('%', putdat);
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	53                   	push   %ebx
  801b39:	6a 25                	push   $0x25
  801b3b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	89 f8                	mov    %edi,%eax
  801b42:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b46:	74 05                	je     801b4d <vprintfmt+0x444>
  801b48:	83 e8 01             	sub    $0x1,%eax
  801b4b:	eb f5                	jmp    801b42 <vprintfmt+0x439>
  801b4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b50:	e9 5a ff ff ff       	jmp    801aaf <vprintfmt+0x3a6>
}
  801b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5e                   	pop    %esi
  801b5a:	5f                   	pop    %edi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b5d:	f3 0f 1e fb          	endbr32 
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	83 ec 18             	sub    $0x18,%esp
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b70:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b74:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	74 26                	je     801ba8 <vsnprintf+0x4b>
  801b82:	85 d2                	test   %edx,%edx
  801b84:	7e 22                	jle    801ba8 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b86:	ff 75 14             	pushl  0x14(%ebp)
  801b89:	ff 75 10             	pushl  0x10(%ebp)
  801b8c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	68 c7 16 80 00       	push   $0x8016c7
  801b95:	e8 6f fb ff ff       	call   801709 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b9d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba3:	83 c4 10             	add    $0x10,%esp
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    
		return -E_INVAL;
  801ba8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bad:	eb f7                	jmp    801ba6 <vsnprintf+0x49>

00801baf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801baf:	f3 0f 1e fb          	endbr32 
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801bb9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bbc:	50                   	push   %eax
  801bbd:	ff 75 10             	pushl  0x10(%ebp)
  801bc0:	ff 75 0c             	pushl  0xc(%ebp)
  801bc3:	ff 75 08             	pushl  0x8(%ebp)
  801bc6:	e8 92 ff ff ff       	call   801b5d <vsnprintf>
	va_end(ap);

	return rc;
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bcd:	f3 0f 1e fb          	endbr32 
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801be0:	74 05                	je     801be7 <strlen+0x1a>
		n++;
  801be2:	83 c0 01             	add    $0x1,%eax
  801be5:	eb f5                	jmp    801bdc <strlen+0xf>
	return n;
}
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801be9:	f3 0f 1e fb          	endbr32 
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfb:	39 d0                	cmp    %edx,%eax
  801bfd:	74 0d                	je     801c0c <strnlen+0x23>
  801bff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801c03:	74 05                	je     801c0a <strnlen+0x21>
		n++;
  801c05:	83 c0 01             	add    $0x1,%eax
  801c08:	eb f1                	jmp    801bfb <strnlen+0x12>
  801c0a:	89 c2                	mov    %eax,%edx
	return n;
}
  801c0c:	89 d0                	mov    %edx,%eax
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c10:	f3 0f 1e fb          	endbr32 
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	53                   	push   %ebx
  801c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c23:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801c27:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	84 d2                	test   %dl,%dl
  801c2f:	75 f2                	jne    801c23 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c31:	89 c8                	mov    %ecx,%eax
  801c33:	5b                   	pop    %ebx
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c36:	f3 0f 1e fb          	endbr32 
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 10             	sub    $0x10,%esp
  801c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c44:	53                   	push   %ebx
  801c45:	e8 83 ff ff ff       	call   801bcd <strlen>
  801c4a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c4d:	ff 75 0c             	pushl  0xc(%ebp)
  801c50:	01 d8                	add    %ebx,%eax
  801c52:	50                   	push   %eax
  801c53:	e8 b8 ff ff ff       	call   801c10 <strcpy>
	return dst;
}
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c5f:	f3 0f 1e fb          	endbr32 
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6e:	89 f3                	mov    %esi,%ebx
  801c70:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c73:	89 f0                	mov    %esi,%eax
  801c75:	39 d8                	cmp    %ebx,%eax
  801c77:	74 11                	je     801c8a <strncpy+0x2b>
		*dst++ = *src;
  801c79:	83 c0 01             	add    $0x1,%eax
  801c7c:	0f b6 0a             	movzbl (%edx),%ecx
  801c7f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c82:	80 f9 01             	cmp    $0x1,%cl
  801c85:	83 da ff             	sbb    $0xffffffff,%edx
  801c88:	eb eb                	jmp    801c75 <strncpy+0x16>
	}
	return ret;
}
  801c8a:	89 f0                	mov    %esi,%eax
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c90:	f3 0f 1e fb          	endbr32 
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9f:	8b 55 10             	mov    0x10(%ebp),%edx
  801ca2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ca4:	85 d2                	test   %edx,%edx
  801ca6:	74 21                	je     801cc9 <strlcpy+0x39>
  801ca8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cac:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801cae:	39 c2                	cmp    %eax,%edx
  801cb0:	74 14                	je     801cc6 <strlcpy+0x36>
  801cb2:	0f b6 19             	movzbl (%ecx),%ebx
  801cb5:	84 db                	test   %bl,%bl
  801cb7:	74 0b                	je     801cc4 <strlcpy+0x34>
			*dst++ = *src++;
  801cb9:	83 c1 01             	add    $0x1,%ecx
  801cbc:	83 c2 01             	add    $0x1,%edx
  801cbf:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cc2:	eb ea                	jmp    801cae <strlcpy+0x1e>
  801cc4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801cc6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cc9:	29 f0                	sub    %esi,%eax
}
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ccf:	f3 0f 1e fb          	endbr32 
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cdc:	0f b6 01             	movzbl (%ecx),%eax
  801cdf:	84 c0                	test   %al,%al
  801ce1:	74 0c                	je     801cef <strcmp+0x20>
  801ce3:	3a 02                	cmp    (%edx),%al
  801ce5:	75 08                	jne    801cef <strcmp+0x20>
		p++, q++;
  801ce7:	83 c1 01             	add    $0x1,%ecx
  801cea:	83 c2 01             	add    $0x1,%edx
  801ced:	eb ed                	jmp    801cdc <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cef:	0f b6 c0             	movzbl %al,%eax
  801cf2:	0f b6 12             	movzbl (%edx),%edx
  801cf5:	29 d0                	sub    %edx,%eax
}
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cf9:	f3 0f 1e fb          	endbr32 
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	53                   	push   %ebx
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d0c:	eb 06                	jmp    801d14 <strncmp+0x1b>
		n--, p++, q++;
  801d0e:	83 c0 01             	add    $0x1,%eax
  801d11:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801d14:	39 d8                	cmp    %ebx,%eax
  801d16:	74 16                	je     801d2e <strncmp+0x35>
  801d18:	0f b6 08             	movzbl (%eax),%ecx
  801d1b:	84 c9                	test   %cl,%cl
  801d1d:	74 04                	je     801d23 <strncmp+0x2a>
  801d1f:	3a 0a                	cmp    (%edx),%cl
  801d21:	74 eb                	je     801d0e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d23:	0f b6 00             	movzbl (%eax),%eax
  801d26:	0f b6 12             	movzbl (%edx),%edx
  801d29:	29 d0                	sub    %edx,%eax
}
  801d2b:	5b                   	pop    %ebx
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    
		return 0;
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d33:	eb f6                	jmp    801d2b <strncmp+0x32>

00801d35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d35:	f3 0f 1e fb          	endbr32 
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d43:	0f b6 10             	movzbl (%eax),%edx
  801d46:	84 d2                	test   %dl,%dl
  801d48:	74 09                	je     801d53 <strchr+0x1e>
		if (*s == c)
  801d4a:	38 ca                	cmp    %cl,%dl
  801d4c:	74 0a                	je     801d58 <strchr+0x23>
	for (; *s; s++)
  801d4e:	83 c0 01             	add    $0x1,%eax
  801d51:	eb f0                	jmp    801d43 <strchr+0xe>
			return (char *) s;
	return 0;
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d5a:	f3 0f 1e fb          	endbr32 
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d64:	6a 78                	push   $0x78
  801d66:	ff 75 08             	pushl  0x8(%ebp)
  801d69:	e8 c7 ff ff ff       	call   801d35 <strchr>
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d74:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d79:	eb 0d                	jmp    801d88 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d7b:	c1 e0 04             	shl    $0x4,%eax
  801d7e:	0f be d2             	movsbl %dl,%edx
  801d81:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d85:	83 c1 01             	add    $0x1,%ecx
  801d88:	0f b6 11             	movzbl (%ecx),%edx
  801d8b:	84 d2                	test   %dl,%dl
  801d8d:	74 11                	je     801da0 <atox+0x46>
		if (*p>='a'){
  801d8f:	80 fa 60             	cmp    $0x60,%dl
  801d92:	7e e7                	jle    801d7b <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d94:	c1 e0 04             	shl    $0x4,%eax
  801d97:	0f be d2             	movsbl %dl,%edx
  801d9a:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d9e:	eb e5                	jmp    801d85 <atox+0x2b>
	}

	return v;

}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801da2:	f3 0f 1e fb          	endbr32 
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801db0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801db3:	38 ca                	cmp    %cl,%dl
  801db5:	74 09                	je     801dc0 <strfind+0x1e>
  801db7:	84 d2                	test   %dl,%dl
  801db9:	74 05                	je     801dc0 <strfind+0x1e>
	for (; *s; s++)
  801dbb:	83 c0 01             	add    $0x1,%eax
  801dbe:	eb f0                	jmp    801db0 <strfind+0xe>
			break;
	return (char *) s;
}
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801dc2:	f3 0f 1e fb          	endbr32 
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	57                   	push   %edi
  801dca:	56                   	push   %esi
  801dcb:	53                   	push   %ebx
  801dcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801dd2:	85 c9                	test   %ecx,%ecx
  801dd4:	74 31                	je     801e07 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801dd6:	89 f8                	mov    %edi,%eax
  801dd8:	09 c8                	or     %ecx,%eax
  801dda:	a8 03                	test   $0x3,%al
  801ddc:	75 23                	jne    801e01 <memset+0x3f>
		c &= 0xFF;
  801dde:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801de2:	89 d3                	mov    %edx,%ebx
  801de4:	c1 e3 08             	shl    $0x8,%ebx
  801de7:	89 d0                	mov    %edx,%eax
  801de9:	c1 e0 18             	shl    $0x18,%eax
  801dec:	89 d6                	mov    %edx,%esi
  801dee:	c1 e6 10             	shl    $0x10,%esi
  801df1:	09 f0                	or     %esi,%eax
  801df3:	09 c2                	or     %eax,%edx
  801df5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801df7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	fc                   	cld    
  801dfd:	f3 ab                	rep stos %eax,%es:(%edi)
  801dff:	eb 06                	jmp    801e07 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e04:	fc                   	cld    
  801e05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e07:	89 f8                	mov    %edi,%eax
  801e09:	5b                   	pop    %ebx
  801e0a:	5e                   	pop    %esi
  801e0b:	5f                   	pop    %edi
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e0e:	f3 0f 1e fb          	endbr32 
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e20:	39 c6                	cmp    %eax,%esi
  801e22:	73 32                	jae    801e56 <memmove+0x48>
  801e24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e27:	39 c2                	cmp    %eax,%edx
  801e29:	76 2b                	jbe    801e56 <memmove+0x48>
		s += n;
		d += n;
  801e2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e2e:	89 fe                	mov    %edi,%esi
  801e30:	09 ce                	or     %ecx,%esi
  801e32:	09 d6                	or     %edx,%esi
  801e34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e3a:	75 0e                	jne    801e4a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e3c:	83 ef 04             	sub    $0x4,%edi
  801e3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e42:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e45:	fd                   	std    
  801e46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e48:	eb 09                	jmp    801e53 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e4a:	83 ef 01             	sub    $0x1,%edi
  801e4d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e50:	fd                   	std    
  801e51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e53:	fc                   	cld    
  801e54:	eb 1a                	jmp    801e70 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e56:	89 c2                	mov    %eax,%edx
  801e58:	09 ca                	or     %ecx,%edx
  801e5a:	09 f2                	or     %esi,%edx
  801e5c:	f6 c2 03             	test   $0x3,%dl
  801e5f:	75 0a                	jne    801e6b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e64:	89 c7                	mov    %eax,%edi
  801e66:	fc                   	cld    
  801e67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e69:	eb 05                	jmp    801e70 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e6b:	89 c7                	mov    %eax,%edi
  801e6d:	fc                   	cld    
  801e6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e70:	5e                   	pop    %esi
  801e71:	5f                   	pop    %edi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    

00801e74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e74:	f3 0f 1e fb          	endbr32 
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e7e:	ff 75 10             	pushl  0x10(%ebp)
  801e81:	ff 75 0c             	pushl  0xc(%ebp)
  801e84:	ff 75 08             	pushl  0x8(%ebp)
  801e87:	e8 82 ff ff ff       	call   801e0e <memmove>
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e8e:	f3 0f 1e fb          	endbr32 
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9d:	89 c6                	mov    %eax,%esi
  801e9f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ea2:	39 f0                	cmp    %esi,%eax
  801ea4:	74 1c                	je     801ec2 <memcmp+0x34>
		if (*s1 != *s2)
  801ea6:	0f b6 08             	movzbl (%eax),%ecx
  801ea9:	0f b6 1a             	movzbl (%edx),%ebx
  801eac:	38 d9                	cmp    %bl,%cl
  801eae:	75 08                	jne    801eb8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801eb0:	83 c0 01             	add    $0x1,%eax
  801eb3:	83 c2 01             	add    $0x1,%edx
  801eb6:	eb ea                	jmp    801ea2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801eb8:	0f b6 c1             	movzbl %cl,%eax
  801ebb:	0f b6 db             	movzbl %bl,%ebx
  801ebe:	29 d8                	sub    %ebx,%eax
  801ec0:	eb 05                	jmp    801ec7 <memcmp+0x39>
	}

	return 0;
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ec7:	5b                   	pop    %ebx
  801ec8:	5e                   	pop    %esi
  801ec9:	5d                   	pop    %ebp
  801eca:	c3                   	ret    

00801ecb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ecb:	f3 0f 1e fb          	endbr32 
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ed8:	89 c2                	mov    %eax,%edx
  801eda:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801edd:	39 d0                	cmp    %edx,%eax
  801edf:	73 09                	jae    801eea <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ee1:	38 08                	cmp    %cl,(%eax)
  801ee3:	74 05                	je     801eea <memfind+0x1f>
	for (; s < ends; s++)
  801ee5:	83 c0 01             	add    $0x1,%eax
  801ee8:	eb f3                	jmp    801edd <memfind+0x12>
			break;
	return (void *) s;
}
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801eec:	f3 0f 1e fb          	endbr32 
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	57                   	push   %edi
  801ef4:	56                   	push   %esi
  801ef5:	53                   	push   %ebx
  801ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801efc:	eb 03                	jmp    801f01 <strtol+0x15>
		s++;
  801efe:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801f01:	0f b6 01             	movzbl (%ecx),%eax
  801f04:	3c 20                	cmp    $0x20,%al
  801f06:	74 f6                	je     801efe <strtol+0x12>
  801f08:	3c 09                	cmp    $0x9,%al
  801f0a:	74 f2                	je     801efe <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801f0c:	3c 2b                	cmp    $0x2b,%al
  801f0e:	74 2a                	je     801f3a <strtol+0x4e>
	int neg = 0;
  801f10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801f15:	3c 2d                	cmp    $0x2d,%al
  801f17:	74 2b                	je     801f44 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f1f:	75 0f                	jne    801f30 <strtol+0x44>
  801f21:	80 39 30             	cmpb   $0x30,(%ecx)
  801f24:	74 28                	je     801f4e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f26:	85 db                	test   %ebx,%ebx
  801f28:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f2d:	0f 44 d8             	cmove  %eax,%ebx
  801f30:	b8 00 00 00 00       	mov    $0x0,%eax
  801f35:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f38:	eb 46                	jmp    801f80 <strtol+0x94>
		s++;
  801f3a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f3d:	bf 00 00 00 00       	mov    $0x0,%edi
  801f42:	eb d5                	jmp    801f19 <strtol+0x2d>
		s++, neg = 1;
  801f44:	83 c1 01             	add    $0x1,%ecx
  801f47:	bf 01 00 00 00       	mov    $0x1,%edi
  801f4c:	eb cb                	jmp    801f19 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f52:	74 0e                	je     801f62 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f54:	85 db                	test   %ebx,%ebx
  801f56:	75 d8                	jne    801f30 <strtol+0x44>
		s++, base = 8;
  801f58:	83 c1 01             	add    $0x1,%ecx
  801f5b:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f60:	eb ce                	jmp    801f30 <strtol+0x44>
		s += 2, base = 16;
  801f62:	83 c1 02             	add    $0x2,%ecx
  801f65:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f6a:	eb c4                	jmp    801f30 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f6c:	0f be d2             	movsbl %dl,%edx
  801f6f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f72:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f75:	7d 3a                	jge    801fb1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f77:	83 c1 01             	add    $0x1,%ecx
  801f7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f80:	0f b6 11             	movzbl (%ecx),%edx
  801f83:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f86:	89 f3                	mov    %esi,%ebx
  801f88:	80 fb 09             	cmp    $0x9,%bl
  801f8b:	76 df                	jbe    801f6c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f90:	89 f3                	mov    %esi,%ebx
  801f92:	80 fb 19             	cmp    $0x19,%bl
  801f95:	77 08                	ja     801f9f <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f97:	0f be d2             	movsbl %dl,%edx
  801f9a:	83 ea 57             	sub    $0x57,%edx
  801f9d:	eb d3                	jmp    801f72 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fa2:	89 f3                	mov    %esi,%ebx
  801fa4:	80 fb 19             	cmp    $0x19,%bl
  801fa7:	77 08                	ja     801fb1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801fa9:	0f be d2             	movsbl %dl,%edx
  801fac:	83 ea 37             	sub    $0x37,%edx
  801faf:	eb c1                	jmp    801f72 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801fb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fb5:	74 05                	je     801fbc <strtol+0xd0>
		*endptr = (char *) s;
  801fb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fba:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801fbc:	89 c2                	mov    %eax,%edx
  801fbe:	f7 da                	neg    %edx
  801fc0:	85 ff                	test   %edi,%edi
  801fc2:	0f 45 c2             	cmovne %edx,%eax
}
  801fc5:	5b                   	pop    %ebx
  801fc6:	5e                   	pop    %esi
  801fc7:	5f                   	pop    %edi
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fca:	f3 0f 1e fb          	endbr32 
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fe3:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	50                   	push   %eax
  801fea:	e8 97 e2 ff ff       	call   800286 <sys_ipc_recv>
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	75 2b                	jne    802021 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801ff6:	85 f6                	test   %esi,%esi
  801ff8:	74 0a                	je     802004 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801ffa:	a1 08 40 80 00       	mov    0x804008,%eax
  801fff:	8b 40 74             	mov    0x74(%eax),%eax
  802002:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802004:	85 db                	test   %ebx,%ebx
  802006:	74 0a                	je     802012 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802008:	a1 08 40 80 00       	mov    0x804008,%eax
  80200d:	8b 40 78             	mov    0x78(%eax),%eax
  802010:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802012:	a1 08 40 80 00       	mov    0x804008,%eax
  802017:	8b 40 70             	mov    0x70(%eax),%eax
}
  80201a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802021:	85 f6                	test   %esi,%esi
  802023:	74 06                	je     80202b <ipc_recv+0x61>
  802025:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80202b:	85 db                	test   %ebx,%ebx
  80202d:	74 eb                	je     80201a <ipc_recv+0x50>
  80202f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802035:	eb e3                	jmp    80201a <ipc_recv+0x50>

00802037 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802037:	f3 0f 1e fb          	endbr32 
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	57                   	push   %edi
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	83 ec 0c             	sub    $0xc,%esp
  802044:	8b 7d 08             	mov    0x8(%ebp),%edi
  802047:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80204d:	85 db                	test   %ebx,%ebx
  80204f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802054:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802057:	ff 75 14             	pushl  0x14(%ebp)
  80205a:	53                   	push   %ebx
  80205b:	56                   	push   %esi
  80205c:	57                   	push   %edi
  80205d:	e8 fd e1 ff ff       	call   80025f <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802068:	75 07                	jne    802071 <ipc_send+0x3a>
			sys_yield();
  80206a:	e8 ee e0 ff ff       	call   80015d <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80206f:	eb e6                	jmp    802057 <ipc_send+0x20>
		}
		else if (ret == 0)
  802071:	85 c0                	test   %eax,%eax
  802073:	75 08                	jne    80207d <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802075:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802078:	5b                   	pop    %ebx
  802079:	5e                   	pop    %esi
  80207a:	5f                   	pop    %edi
  80207b:	5d                   	pop    %ebp
  80207c:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80207d:	50                   	push   %eax
  80207e:	68 3f 28 80 00       	push   $0x80283f
  802083:	6a 48                	push   $0x48
  802085:	68 4d 28 80 00       	push   $0x80284d
  80208a:	e8 90 f4 ff ff       	call   80151f <_panic>

0080208f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80208f:	f3 0f 1e fb          	endbr32 
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802099:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80209e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a7:	8b 52 50             	mov    0x50(%edx),%edx
  8020aa:	39 ca                	cmp    %ecx,%edx
  8020ac:	74 11                	je     8020bf <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8020ae:	83 c0 01             	add    $0x1,%eax
  8020b1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b6:	75 e6                	jne    80209e <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020bd:	eb 0b                	jmp    8020ca <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c7:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020ca:	5d                   	pop    %ebp
  8020cb:	c3                   	ret    

008020cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020cc:	f3 0f 1e fb          	endbr32 
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d6:	89 c2                	mov    %eax,%edx
  8020d8:	c1 ea 16             	shr    $0x16,%edx
  8020db:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020e2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020e7:	f6 c1 01             	test   $0x1,%cl
  8020ea:	74 1c                	je     802108 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020ec:	c1 e8 0c             	shr    $0xc,%eax
  8020ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020f6:	a8 01                	test   $0x1,%al
  8020f8:	74 0e                	je     802108 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020fa:	c1 e8 0c             	shr    $0xc,%eax
  8020fd:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802104:	ef 
  802105:	0f b7 d2             	movzwl %dx,%edx
}
  802108:	89 d0                	mov    %edx,%eax
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802123:	8b 74 24 34          	mov    0x34(%esp),%esi
  802127:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80212b:	85 d2                	test   %edx,%edx
  80212d:	75 19                	jne    802148 <__udivdi3+0x38>
  80212f:	39 f3                	cmp    %esi,%ebx
  802131:	76 4d                	jbe    802180 <__udivdi3+0x70>
  802133:	31 ff                	xor    %edi,%edi
  802135:	89 e8                	mov    %ebp,%eax
  802137:	89 f2                	mov    %esi,%edx
  802139:	f7 f3                	div    %ebx
  80213b:	89 fa                	mov    %edi,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	76 14                	jbe    802160 <__udivdi3+0x50>
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	31 c0                	xor    %eax,%eax
  802150:	89 fa                	mov    %edi,%edx
  802152:	83 c4 1c             	add    $0x1c,%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	0f bd fa             	bsr    %edx,%edi
  802163:	83 f7 1f             	xor    $0x1f,%edi
  802166:	75 48                	jne    8021b0 <__udivdi3+0xa0>
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	72 06                	jb     802172 <__udivdi3+0x62>
  80216c:	31 c0                	xor    %eax,%eax
  80216e:	39 eb                	cmp    %ebp,%ebx
  802170:	77 de                	ja     802150 <__udivdi3+0x40>
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb d7                	jmp    802150 <__udivdi3+0x40>
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d9                	mov    %ebx,%ecx
  802182:	85 db                	test   %ebx,%ebx
  802184:	75 0b                	jne    802191 <__udivdi3+0x81>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f3                	div    %ebx
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	31 d2                	xor    %edx,%edx
  802193:	89 f0                	mov    %esi,%eax
  802195:	f7 f1                	div    %ecx
  802197:	89 c6                	mov    %eax,%esi
  802199:	89 e8                	mov    %ebp,%eax
  80219b:	89 f7                	mov    %esi,%edi
  80219d:	f7 f1                	div    %ecx
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 f9                	mov    %edi,%ecx
  8021b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021b7:	29 f8                	sub    %edi,%eax
  8021b9:	d3 e2                	shl    %cl,%edx
  8021bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	89 da                	mov    %ebx,%edx
  8021c3:	d3 ea                	shr    %cl,%edx
  8021c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021c9:	09 d1                	or     %edx,%ecx
  8021cb:	89 f2                	mov    %esi,%edx
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	d3 e3                	shl    %cl,%ebx
  8021d5:	89 c1                	mov    %eax,%ecx
  8021d7:	d3 ea                	shr    %cl,%edx
  8021d9:	89 f9                	mov    %edi,%ecx
  8021db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021df:	89 eb                	mov    %ebp,%ebx
  8021e1:	d3 e6                	shl    %cl,%esi
  8021e3:	89 c1                	mov    %eax,%ecx
  8021e5:	d3 eb                	shr    %cl,%ebx
  8021e7:	09 de                	or     %ebx,%esi
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	f7 74 24 08          	divl   0x8(%esp)
  8021ef:	89 d6                	mov    %edx,%esi
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	f7 64 24 0c          	mull   0xc(%esp)
  8021f7:	39 d6                	cmp    %edx,%esi
  8021f9:	72 15                	jb     802210 <__udivdi3+0x100>
  8021fb:	89 f9                	mov    %edi,%ecx
  8021fd:	d3 e5                	shl    %cl,%ebp
  8021ff:	39 c5                	cmp    %eax,%ebp
  802201:	73 04                	jae    802207 <__udivdi3+0xf7>
  802203:	39 d6                	cmp    %edx,%esi
  802205:	74 09                	je     802210 <__udivdi3+0x100>
  802207:	89 d8                	mov    %ebx,%eax
  802209:	31 ff                	xor    %edi,%edi
  80220b:	e9 40 ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802210:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802213:	31 ff                	xor    %edi,%edi
  802215:	e9 36 ff ff ff       	jmp    802150 <__udivdi3+0x40>
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	f3 0f 1e fb          	endbr32 
  802224:	55                   	push   %ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	83 ec 1c             	sub    $0x1c,%esp
  80222b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80222f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802233:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802237:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80223b:	85 c0                	test   %eax,%eax
  80223d:	75 19                	jne    802258 <__umoddi3+0x38>
  80223f:	39 df                	cmp    %ebx,%edi
  802241:	76 5d                	jbe    8022a0 <__umoddi3+0x80>
  802243:	89 f0                	mov    %esi,%eax
  802245:	89 da                	mov    %ebx,%edx
  802247:	f7 f7                	div    %edi
  802249:	89 d0                	mov    %edx,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	83 c4 1c             	add    $0x1c,%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	89 f2                	mov    %esi,%edx
  80225a:	39 d8                	cmp    %ebx,%eax
  80225c:	76 12                	jbe    802270 <__umoddi3+0x50>
  80225e:	89 f0                	mov    %esi,%eax
  802260:	89 da                	mov    %ebx,%edx
  802262:	83 c4 1c             	add    $0x1c,%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5f                   	pop    %edi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    
  80226a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802270:	0f bd e8             	bsr    %eax,%ebp
  802273:	83 f5 1f             	xor    $0x1f,%ebp
  802276:	75 50                	jne    8022c8 <__umoddi3+0xa8>
  802278:	39 d8                	cmp    %ebx,%eax
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	89 d9                	mov    %ebx,%ecx
  802282:	39 f7                	cmp    %esi,%edi
  802284:	0f 86 d6 00 00 00    	jbe    802360 <__umoddi3+0x140>
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	89 ca                	mov    %ecx,%edx
  80228e:	83 c4 1c             	add    $0x1c,%esp
  802291:	5b                   	pop    %ebx
  802292:	5e                   	pop    %esi
  802293:	5f                   	pop    %edi
  802294:	5d                   	pop    %ebp
  802295:	c3                   	ret    
  802296:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	89 fd                	mov    %edi,%ebp
  8022a2:	85 ff                	test   %edi,%edi
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 d8                	mov    %ebx,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 f0                	mov    %esi,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	eb 8c                	jmp    80224d <__umoddi3+0x2d>
  8022c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8022cf:	29 ea                	sub    %ebp,%edx
  8022d1:	d3 e0                	shl    %cl,%eax
  8022d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 f8                	mov    %edi,%eax
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022e9:	09 c1                	or     %eax,%ecx
  8022eb:	89 d8                	mov    %ebx,%eax
  8022ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f1:	89 e9                	mov    %ebp,%ecx
  8022f3:	d3 e7                	shl    %cl,%edi
  8022f5:	89 d1                	mov    %edx,%ecx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022ff:	d3 e3                	shl    %cl,%ebx
  802301:	89 c7                	mov    %eax,%edi
  802303:	89 d1                	mov    %edx,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	89 fa                	mov    %edi,%edx
  80230d:	d3 e6                	shl    %cl,%esi
  80230f:	09 d8                	or     %ebx,%eax
  802311:	f7 74 24 08          	divl   0x8(%esp)
  802315:	89 d1                	mov    %edx,%ecx
  802317:	89 f3                	mov    %esi,%ebx
  802319:	f7 64 24 0c          	mull   0xc(%esp)
  80231d:	89 c6                	mov    %eax,%esi
  80231f:	89 d7                	mov    %edx,%edi
  802321:	39 d1                	cmp    %edx,%ecx
  802323:	72 06                	jb     80232b <__umoddi3+0x10b>
  802325:	75 10                	jne    802337 <__umoddi3+0x117>
  802327:	39 c3                	cmp    %eax,%ebx
  802329:	73 0c                	jae    802337 <__umoddi3+0x117>
  80232b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80232f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802333:	89 d7                	mov    %edx,%edi
  802335:	89 c6                	mov    %eax,%esi
  802337:	89 ca                	mov    %ecx,%edx
  802339:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80233e:	29 f3                	sub    %esi,%ebx
  802340:	19 fa                	sbb    %edi,%edx
  802342:	89 d0                	mov    %edx,%eax
  802344:	d3 e0                	shl    %cl,%eax
  802346:	89 e9                	mov    %ebp,%ecx
  802348:	d3 eb                	shr    %cl,%ebx
  80234a:	d3 ea                	shr    %cl,%edx
  80234c:	09 d8                	or     %ebx,%eax
  80234e:	83 c4 1c             	add    $0x1c,%esp
  802351:	5b                   	pop    %ebx
  802352:	5e                   	pop    %esi
  802353:	5f                   	pop    %edi
  802354:	5d                   	pop    %ebp
  802355:	c3                   	ret    
  802356:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 fe                	sub    %edi,%esi
  802362:	19 c3                	sbb    %eax,%ebx
  802364:	89 f2                	mov    %esi,%edx
  802366:	89 d9                	mov    %ebx,%ecx
  802368:	e9 1d ff ff ff       	jmp    80228a <__umoddi3+0x6a>
