
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 30 80 00    	pushl  0x803000
  800048:	e8 6d 00 00 00       	call   8000ba <sys_cputs>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800061:	e8 bd 00 00 00       	call   800123 <sys_getenvid>
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x31>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	f3 0f 1e fb          	endbr32 
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000a6:	e8 49 04 00 00       	call   8004f4 <close_all>
	sys_env_destroy(0);
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 4a 00 00 00       	call   8000ff <sys_env_destroy>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ba:	f3 0f 1e fb          	endbr32 
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cf:	89 c3                	mov    %eax,%ebx
  8000d1:	89 c7                	mov    %eax,%edi
  8000d3:	89 c6                	mov    %eax,%esi
  8000d5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dc:	f3 0f 1e fb          	endbr32 
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	f3 0f 1e fb          	endbr32 
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	57                   	push   %edi
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
	asm volatile("int %1\n"
  800109:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010e:	8b 55 08             	mov    0x8(%ebp),%edx
  800111:	b8 03 00 00 00       	mov    $0x3,%eax
  800116:	89 cb                	mov    %ecx,%ebx
  800118:	89 cf                	mov    %ecx,%edi
  80011a:	89 ce                	mov    %ecx,%esi
  80011c:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800123:	f3 0f 1e fb          	endbr32 
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <sys_yield>:

void
sys_yield(void)
{
  800146:	f3 0f 1e fb          	endbr32 
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800150:	ba 00 00 00 00       	mov    $0x0,%edx
  800155:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015a:	89 d1                	mov    %edx,%ecx
  80015c:	89 d3                	mov    %edx,%ebx
  80015e:	89 d7                	mov    %edx,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800169:	f3 0f 1e fb          	endbr32 
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018a:	5b                   	pop    %ebx
  80018b:	5e                   	pop    %esi
  80018c:	5f                   	pop    %edi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80018f:	f3 0f 1e fb          	endbr32 
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	57                   	push   %edi
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	asm volatile("int %1\n"
  800199:	8b 55 08             	mov    0x8(%ebp),%edx
  80019c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019f:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5f                   	pop    %edi
  8001b2:	5d                   	pop    %ebp
  8001b3:	c3                   	ret    

008001b4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001b4:	f3 0f 1e fb          	endbr32 
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ce:	89 df                	mov    %ebx,%edi
  8001d0:	89 de                	mov    %ebx,%esi
  8001d2:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001d9:	f3 0f 1e fb          	endbr32 
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001fe:	f3 0f 1e fb          	endbr32 
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
	asm volatile("int %1\n"
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	8b 55 08             	mov    0x8(%ebp),%edx
  800210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800213:	b8 09 00 00 00       	mov    $0x9,%eax
  800218:	89 df                	mov    %ebx,%edi
  80021a:	89 de                	mov    %ebx,%esi
  80021c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800223:	f3 0f 1e fb          	endbr32 
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	b8 0a 00 00 00       	mov    $0xa,%eax
  80023d:	89 df                	mov    %ebx,%edi
  80023f:	89 de                	mov    %ebx,%esi
  800241:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800248:	f3 0f 1e fb          	endbr32 
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
	asm volatile("int %1\n"
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800258:	b8 0c 00 00 00       	mov    $0xc,%eax
  80025d:	be 00 00 00 00       	mov    $0x0,%esi
  800262:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800265:	8b 7d 14             	mov    0x14(%ebp),%edi
  800268:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80026f:	f3 0f 1e fb          	endbr32 
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
	asm volatile("int %1\n"
  800279:	b9 00 00 00 00       	mov    $0x0,%ecx
  80027e:	8b 55 08             	mov    0x8(%ebp),%edx
  800281:	b8 0d 00 00 00       	mov    $0xd,%eax
  800286:	89 cb                	mov    %ecx,%ebx
  800288:	89 cf                	mov    %ecx,%edi
  80028a:	89 ce                	mov    %ecx,%esi
  80028c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800293:	f3 0f 1e fb          	endbr32 
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002a7:	89 d1                	mov    %edx,%ecx
  8002a9:	89 d3                	mov    %edx,%ebx
  8002ab:	89 d7                	mov    %edx,%edi
  8002ad:	89 d6                	mov    %edx,%esi
  8002af:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8002b6:	f3 0f 1e fb          	endbr32 
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002d0:	89 df                	mov    %ebx,%edi
  8002d2:	89 de                	mov    %ebx,%esi
  8002d4:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002db:	f3 0f 1e fb          	endbr32 
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8002f5:	89 df                	mov    %ebx,%edi
  8002f7:	89 de                	mov    %ebx,%esi
  8002f9:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800300:	f3 0f 1e fb          	endbr32 
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	05 00 00 00 30       	add    $0x30000000,%eax
  80030f:	c1 e8 0c             	shr    $0xc,%eax
}
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800314:	f3 0f 1e fb          	endbr32 
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800323:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800328:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80032f:	f3 0f 1e fb          	endbr32 
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80033b:	89 c2                	mov    %eax,%edx
  80033d:	c1 ea 16             	shr    $0x16,%edx
  800340:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800347:	f6 c2 01             	test   $0x1,%dl
  80034a:	74 2d                	je     800379 <fd_alloc+0x4a>
  80034c:	89 c2                	mov    %eax,%edx
  80034e:	c1 ea 0c             	shr    $0xc,%edx
  800351:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800358:	f6 c2 01             	test   $0x1,%dl
  80035b:	74 1c                	je     800379 <fd_alloc+0x4a>
  80035d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800362:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800367:	75 d2                	jne    80033b <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800372:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800377:	eb 0a                	jmp    800383 <fd_alloc+0x54>
			*fd_store = fd;
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80037e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800385:	f3 0f 1e fb          	endbr32 
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80038f:	83 f8 1f             	cmp    $0x1f,%eax
  800392:	77 30                	ja     8003c4 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800394:	c1 e0 0c             	shl    $0xc,%eax
  800397:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80039c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003a2:	f6 c2 01             	test   $0x1,%dl
  8003a5:	74 24                	je     8003cb <fd_lookup+0x46>
  8003a7:	89 c2                	mov    %eax,%edx
  8003a9:	c1 ea 0c             	shr    $0xc,%edx
  8003ac:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b3:	f6 c2 01             	test   $0x1,%dl
  8003b6:	74 1a                	je     8003d2 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bb:	89 02                	mov    %eax,(%edx)
	return 0;
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c2:	5d                   	pop    %ebp
  8003c3:	c3                   	ret    
		return -E_INVAL;
  8003c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c9:	eb f7                	jmp    8003c2 <fd_lookup+0x3d>
		return -E_INVAL;
  8003cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d0:	eb f0                	jmp    8003c2 <fd_lookup+0x3d>
  8003d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d7:	eb e9                	jmp    8003c2 <fd_lookup+0x3d>

008003d9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d9:	f3 0f 1e fb          	endbr32 
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003eb:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003f0:	39 08                	cmp    %ecx,(%eax)
  8003f2:	74 38                	je     80042c <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8003f4:	83 c2 01             	add    $0x1,%edx
  8003f7:	8b 04 95 f4 23 80 00 	mov    0x8023f4(,%edx,4),%eax
  8003fe:	85 c0                	test   %eax,%eax
  800400:	75 ee                	jne    8003f0 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800402:	a1 08 40 80 00       	mov    0x804008,%eax
  800407:	8b 40 48             	mov    0x48(%eax),%eax
  80040a:	83 ec 04             	sub    $0x4,%esp
  80040d:	51                   	push   %ecx
  80040e:	50                   	push   %eax
  80040f:	68 78 23 80 00       	push   $0x802378
  800414:	e8 d6 11 00 00       	call   8015ef <cprintf>
	*dev = 0;
  800419:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    
			*dev = devtab[i];
  80042c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800431:	b8 00 00 00 00       	mov    $0x0,%eax
  800436:	eb f2                	jmp    80042a <dev_lookup+0x51>

00800438 <fd_close>:
{
  800438:	f3 0f 1e fb          	endbr32 
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
  800442:	83 ec 24             	sub    $0x24,%esp
  800445:	8b 75 08             	mov    0x8(%ebp),%esi
  800448:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80044b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80044e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80044f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800455:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800458:	50                   	push   %eax
  800459:	e8 27 ff ff ff       	call   800385 <fd_lookup>
  80045e:	89 c3                	mov    %eax,%ebx
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	85 c0                	test   %eax,%eax
  800465:	78 05                	js     80046c <fd_close+0x34>
	    || fd != fd2)
  800467:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80046a:	74 16                	je     800482 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	84 c0                	test   %al,%al
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
  800475:	0f 44 d8             	cmove  %eax,%ebx
}
  800478:	89 d8                	mov    %ebx,%eax
  80047a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80047d:	5b                   	pop    %ebx
  80047e:	5e                   	pop    %esi
  80047f:	5f                   	pop    %edi
  800480:	5d                   	pop    %ebp
  800481:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800488:	50                   	push   %eax
  800489:	ff 36                	pushl  (%esi)
  80048b:	e8 49 ff ff ff       	call   8003d9 <dev_lookup>
  800490:	89 c3                	mov    %eax,%ebx
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	85 c0                	test   %eax,%eax
  800497:	78 1a                	js     8004b3 <fd_close+0x7b>
		if (dev->dev_close)
  800499:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80049f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	74 0b                	je     8004b3 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004a8:	83 ec 0c             	sub    $0xc,%esp
  8004ab:	56                   	push   %esi
  8004ac:	ff d0                	call   *%eax
  8004ae:	89 c3                	mov    %eax,%ebx
  8004b0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	56                   	push   %esi
  8004b7:	6a 00                	push   $0x0
  8004b9:	e8 f6 fc ff ff       	call   8001b4 <sys_page_unmap>
	return r;
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	eb b5                	jmp    800478 <fd_close+0x40>

008004c3 <close>:

int
close(int fdnum)
{
  8004c3:	f3 0f 1e fb          	endbr32 
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 75 08             	pushl  0x8(%ebp)
  8004d4:	e8 ac fe ff ff       	call   800385 <fd_lookup>
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	85 c0                	test   %eax,%eax
  8004de:	79 02                	jns    8004e2 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    
		return fd_close(fd, 1);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	6a 01                	push   $0x1
  8004e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8004ea:	e8 49 ff ff ff       	call   800438 <fd_close>
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	eb ec                	jmp    8004e0 <close+0x1d>

008004f4 <close_all>:

void
close_all(void)
{
  8004f4:	f3 0f 1e fb          	endbr32 
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	53                   	push   %ebx
  8004fc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800504:	83 ec 0c             	sub    $0xc,%esp
  800507:	53                   	push   %ebx
  800508:	e8 b6 ff ff ff       	call   8004c3 <close>
	for (i = 0; i < MAXFD; i++)
  80050d:	83 c3 01             	add    $0x1,%ebx
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	83 fb 20             	cmp    $0x20,%ebx
  800516:	75 ec                	jne    800504 <close_all+0x10>
}
  800518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80051d:	f3 0f 1e fb          	endbr32 
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80052a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80052d:	50                   	push   %eax
  80052e:	ff 75 08             	pushl  0x8(%ebp)
  800531:	e8 4f fe ff ff       	call   800385 <fd_lookup>
  800536:	89 c3                	mov    %eax,%ebx
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 c0                	test   %eax,%eax
  80053d:	0f 88 81 00 00 00    	js     8005c4 <dup+0xa7>
		return r;
	close(newfdnum);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	ff 75 0c             	pushl  0xc(%ebp)
  800549:	e8 75 ff ff ff       	call   8004c3 <close>

	newfd = INDEX2FD(newfdnum);
  80054e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800551:	c1 e6 0c             	shl    $0xc,%esi
  800554:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80055a:	83 c4 04             	add    $0x4,%esp
  80055d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800560:	e8 af fd ff ff       	call   800314 <fd2data>
  800565:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800567:	89 34 24             	mov    %esi,(%esp)
  80056a:	e8 a5 fd ff ff       	call   800314 <fd2data>
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800574:	89 d8                	mov    %ebx,%eax
  800576:	c1 e8 16             	shr    $0x16,%eax
  800579:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800580:	a8 01                	test   $0x1,%al
  800582:	74 11                	je     800595 <dup+0x78>
  800584:	89 d8                	mov    %ebx,%eax
  800586:	c1 e8 0c             	shr    $0xc,%eax
  800589:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800590:	f6 c2 01             	test   $0x1,%dl
  800593:	75 39                	jne    8005ce <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800595:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800598:	89 d0                	mov    %edx,%eax
  80059a:	c1 e8 0c             	shr    $0xc,%eax
  80059d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ac:	50                   	push   %eax
  8005ad:	56                   	push   %esi
  8005ae:	6a 00                	push   $0x0
  8005b0:	52                   	push   %edx
  8005b1:	6a 00                	push   $0x0
  8005b3:	e8 d7 fb ff ff       	call   80018f <sys_page_map>
  8005b8:	89 c3                	mov    %eax,%ebx
  8005ba:	83 c4 20             	add    $0x20,%esp
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	78 31                	js     8005f2 <dup+0xd5>
		goto err;

	return newfdnum;
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005c4:	89 d8                	mov    %ebx,%eax
  8005c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c9:	5b                   	pop    %ebx
  8005ca:	5e                   	pop    %esi
  8005cb:	5f                   	pop    %edi
  8005cc:	5d                   	pop    %ebp
  8005cd:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005dd:	50                   	push   %eax
  8005de:	57                   	push   %edi
  8005df:	6a 00                	push   $0x0
  8005e1:	53                   	push   %ebx
  8005e2:	6a 00                	push   $0x0
  8005e4:	e8 a6 fb ff ff       	call   80018f <sys_page_map>
  8005e9:	89 c3                	mov    %eax,%ebx
  8005eb:	83 c4 20             	add    $0x20,%esp
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	79 a3                	jns    800595 <dup+0x78>
	sys_page_unmap(0, newfd);
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	56                   	push   %esi
  8005f6:	6a 00                	push   $0x0
  8005f8:	e8 b7 fb ff ff       	call   8001b4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005fd:	83 c4 08             	add    $0x8,%esp
  800600:	57                   	push   %edi
  800601:	6a 00                	push   $0x0
  800603:	e8 ac fb ff ff       	call   8001b4 <sys_page_unmap>
	return r;
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	eb b7                	jmp    8005c4 <dup+0xa7>

0080060d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80060d:	f3 0f 1e fb          	endbr32 
  800611:	55                   	push   %ebp
  800612:	89 e5                	mov    %esp,%ebp
  800614:	53                   	push   %ebx
  800615:	83 ec 1c             	sub    $0x1c,%esp
  800618:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80061b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80061e:	50                   	push   %eax
  80061f:	53                   	push   %ebx
  800620:	e8 60 fd ff ff       	call   800385 <fd_lookup>
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	85 c0                	test   %eax,%eax
  80062a:	78 3f                	js     80066b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800632:	50                   	push   %eax
  800633:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800636:	ff 30                	pushl  (%eax)
  800638:	e8 9c fd ff ff       	call   8003d9 <dev_lookup>
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	85 c0                	test   %eax,%eax
  800642:	78 27                	js     80066b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800644:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800647:	8b 42 08             	mov    0x8(%edx),%eax
  80064a:	83 e0 03             	and    $0x3,%eax
  80064d:	83 f8 01             	cmp    $0x1,%eax
  800650:	74 1e                	je     800670 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800652:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800655:	8b 40 08             	mov    0x8(%eax),%eax
  800658:	85 c0                	test   %eax,%eax
  80065a:	74 35                	je     800691 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80065c:	83 ec 04             	sub    $0x4,%esp
  80065f:	ff 75 10             	pushl  0x10(%ebp)
  800662:	ff 75 0c             	pushl  0xc(%ebp)
  800665:	52                   	push   %edx
  800666:	ff d0                	call   *%eax
  800668:	83 c4 10             	add    $0x10,%esp
}
  80066b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80066e:	c9                   	leave  
  80066f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800670:	a1 08 40 80 00       	mov    0x804008,%eax
  800675:	8b 40 48             	mov    0x48(%eax),%eax
  800678:	83 ec 04             	sub    $0x4,%esp
  80067b:	53                   	push   %ebx
  80067c:	50                   	push   %eax
  80067d:	68 b9 23 80 00       	push   $0x8023b9
  800682:	e8 68 0f 00 00       	call   8015ef <cprintf>
		return -E_INVAL;
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068f:	eb da                	jmp    80066b <read+0x5e>
		return -E_NOT_SUPP;
  800691:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800696:	eb d3                	jmp    80066b <read+0x5e>

00800698 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800698:	f3 0f 1e fb          	endbr32 
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	57                   	push   %edi
  8006a0:	56                   	push   %esi
  8006a1:	53                   	push   %ebx
  8006a2:	83 ec 0c             	sub    $0xc,%esp
  8006a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b0:	eb 02                	jmp    8006b4 <readn+0x1c>
  8006b2:	01 c3                	add    %eax,%ebx
  8006b4:	39 f3                	cmp    %esi,%ebx
  8006b6:	73 21                	jae    8006d9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	89 f0                	mov    %esi,%eax
  8006bd:	29 d8                	sub    %ebx,%eax
  8006bf:	50                   	push   %eax
  8006c0:	89 d8                	mov    %ebx,%eax
  8006c2:	03 45 0c             	add    0xc(%ebp),%eax
  8006c5:	50                   	push   %eax
  8006c6:	57                   	push   %edi
  8006c7:	e8 41 ff ff ff       	call   80060d <read>
		if (m < 0)
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	78 04                	js     8006d7 <readn+0x3f>
			return m;
		if (m == 0)
  8006d3:	75 dd                	jne    8006b2 <readn+0x1a>
  8006d5:	eb 02                	jmp    8006d9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006d9:	89 d8                	mov    %ebx,%eax
  8006db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006de:	5b                   	pop    %ebx
  8006df:	5e                   	pop    %esi
  8006e0:	5f                   	pop    %edi
  8006e1:	5d                   	pop    %ebp
  8006e2:	c3                   	ret    

008006e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006e3:	f3 0f 1e fb          	endbr32 
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	53                   	push   %ebx
  8006eb:	83 ec 1c             	sub    $0x1c,%esp
  8006ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f4:	50                   	push   %eax
  8006f5:	53                   	push   %ebx
  8006f6:	e8 8a fc ff ff       	call   800385 <fd_lookup>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c0                	test   %eax,%eax
  800700:	78 3a                	js     80073c <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070c:	ff 30                	pushl  (%eax)
  80070e:	e8 c6 fc ff ff       	call   8003d9 <dev_lookup>
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	85 c0                	test   %eax,%eax
  800718:	78 22                	js     80073c <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80071a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800721:	74 1e                	je     800741 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800723:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800726:	8b 52 0c             	mov    0xc(%edx),%edx
  800729:	85 d2                	test   %edx,%edx
  80072b:	74 35                	je     800762 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80072d:	83 ec 04             	sub    $0x4,%esp
  800730:	ff 75 10             	pushl  0x10(%ebp)
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	50                   	push   %eax
  800737:	ff d2                	call   *%edx
  800739:	83 c4 10             	add    $0x10,%esp
}
  80073c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073f:	c9                   	leave  
  800740:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800741:	a1 08 40 80 00       	mov    0x804008,%eax
  800746:	8b 40 48             	mov    0x48(%eax),%eax
  800749:	83 ec 04             	sub    $0x4,%esp
  80074c:	53                   	push   %ebx
  80074d:	50                   	push   %eax
  80074e:	68 d5 23 80 00       	push   $0x8023d5
  800753:	e8 97 0e 00 00       	call   8015ef <cprintf>
		return -E_INVAL;
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800760:	eb da                	jmp    80073c <write+0x59>
		return -E_NOT_SUPP;
  800762:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800767:	eb d3                	jmp    80073c <write+0x59>

00800769 <seek>:

int
seek(int fdnum, off_t offset)
{
  800769:	f3 0f 1e fb          	endbr32 
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800773:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	ff 75 08             	pushl  0x8(%ebp)
  80077a:	e8 06 fc ff ff       	call   800385 <fd_lookup>
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	85 c0                	test   %eax,%eax
  800784:	78 0e                	js     800794 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800796:	f3 0f 1e fb          	endbr32 
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	83 ec 1c             	sub    $0x1c,%esp
  8007a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	53                   	push   %ebx
  8007a9:	e8 d7 fb ff ff       	call   800385 <fd_lookup>
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	78 37                	js     8007ec <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bb:	50                   	push   %eax
  8007bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bf:	ff 30                	pushl  (%eax)
  8007c1:	e8 13 fc ff ff       	call   8003d9 <dev_lookup>
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 1f                	js     8007ec <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d4:	74 1b                	je     8007f1 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d9:	8b 52 18             	mov    0x18(%edx),%edx
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 32                	je     800812 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	ff 75 0c             	pushl  0xc(%ebp)
  8007e6:	50                   	push   %eax
  8007e7:	ff d2                	call   *%edx
  8007e9:	83 c4 10             	add    $0x10,%esp
}
  8007ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007f1:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f6:	8b 40 48             	mov    0x48(%eax),%eax
  8007f9:	83 ec 04             	sub    $0x4,%esp
  8007fc:	53                   	push   %ebx
  8007fd:	50                   	push   %eax
  8007fe:	68 98 23 80 00       	push   $0x802398
  800803:	e8 e7 0d 00 00       	call   8015ef <cprintf>
		return -E_INVAL;
  800808:	83 c4 10             	add    $0x10,%esp
  80080b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800810:	eb da                	jmp    8007ec <ftruncate+0x56>
		return -E_NOT_SUPP;
  800812:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800817:	eb d3                	jmp    8007ec <ftruncate+0x56>

00800819 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800819:	f3 0f 1e fb          	endbr32 
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	83 ec 1c             	sub    $0x1c,%esp
  800824:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800827:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082a:	50                   	push   %eax
  80082b:	ff 75 08             	pushl  0x8(%ebp)
  80082e:	e8 52 fb ff ff       	call   800385 <fd_lookup>
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	85 c0                	test   %eax,%eax
  800838:	78 4b                	js     800885 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800844:	ff 30                	pushl  (%eax)
  800846:	e8 8e fb ff ff       	call   8003d9 <dev_lookup>
  80084b:	83 c4 10             	add    $0x10,%esp
  80084e:	85 c0                	test   %eax,%eax
  800850:	78 33                	js     800885 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800852:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800855:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800859:	74 2f                	je     80088a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80085b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80085e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800865:	00 00 00 
	stat->st_isdir = 0;
  800868:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80086f:	00 00 00 
	stat->st_dev = dev;
  800872:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	ff 75 f0             	pushl  -0x10(%ebp)
  80087f:	ff 50 14             	call   *0x14(%eax)
  800882:	83 c4 10             	add    $0x10,%esp
}
  800885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800888:	c9                   	leave  
  800889:	c3                   	ret    
		return -E_NOT_SUPP;
  80088a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80088f:	eb f4                	jmp    800885 <fstat+0x6c>

00800891 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	6a 00                	push   $0x0
  80089f:	ff 75 08             	pushl  0x8(%ebp)
  8008a2:	e8 01 02 00 00       	call   800aa8 <open>
  8008a7:	89 c3                	mov    %eax,%ebx
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 1b                	js     8008cb <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008b0:	83 ec 08             	sub    $0x8,%esp
  8008b3:	ff 75 0c             	pushl  0xc(%ebp)
  8008b6:	50                   	push   %eax
  8008b7:	e8 5d ff ff ff       	call   800819 <fstat>
  8008bc:	89 c6                	mov    %eax,%esi
	close(fd);
  8008be:	89 1c 24             	mov    %ebx,(%esp)
  8008c1:	e8 fd fb ff ff       	call   8004c3 <close>
	return r;
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	89 f3                	mov    %esi,%ebx
}
  8008cb:	89 d8                	mov    %ebx,%eax
  8008cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	89 c6                	mov    %eax,%esi
  8008db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e4:	74 27                	je     80090d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e6:	6a 07                	push   $0x7
  8008e8:	68 00 50 80 00       	push   $0x805000
  8008ed:	56                   	push   %esi
  8008ee:	ff 35 00 40 80 00    	pushl  0x804000
  8008f4:	e8 27 17 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f9:	83 c4 0c             	add    $0xc,%esp
  8008fc:	6a 00                	push   $0x0
  8008fe:	53                   	push   %ebx
  8008ff:	6a 00                	push   $0x0
  800901:	e8 ad 16 00 00       	call   801fb3 <ipc_recv>
}
  800906:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090d:	83 ec 0c             	sub    $0xc,%esp
  800910:	6a 01                	push   $0x1
  800912:	e8 61 17 00 00       	call   802078 <ipc_find_env>
  800917:	a3 00 40 80 00       	mov    %eax,0x804000
  80091c:	83 c4 10             	add    $0x10,%esp
  80091f:	eb c5                	jmp    8008e6 <fsipc+0x12>

00800921 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800921:	f3 0f 1e fb          	endbr32 
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 40 0c             	mov    0xc(%eax),%eax
  800931:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
  800943:	b8 02 00 00 00       	mov    $0x2,%eax
  800948:	e8 87 ff ff ff       	call   8008d4 <fsipc>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <devfile_flush>:
{
  80094f:	f3 0f 1e fb          	endbr32 
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 40 0c             	mov    0xc(%eax),%eax
  80095f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
  800969:	b8 06 00 00 00       	mov    $0x6,%eax
  80096e:	e8 61 ff ff ff       	call   8008d4 <fsipc>
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <devfile_stat>:
{
  800975:	f3 0f 1e fb          	endbr32 
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	53                   	push   %ebx
  80097d:	83 ec 04             	sub    $0x4,%esp
  800980:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 40 0c             	mov    0xc(%eax),%eax
  800989:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098e:	ba 00 00 00 00       	mov    $0x0,%edx
  800993:	b8 05 00 00 00       	mov    $0x5,%eax
  800998:	e8 37 ff ff ff       	call   8008d4 <fsipc>
  80099d:	85 c0                	test   %eax,%eax
  80099f:	78 2c                	js     8009cd <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a1:	83 ec 08             	sub    $0x8,%esp
  8009a4:	68 00 50 80 00       	push   $0x805000
  8009a9:	53                   	push   %ebx
  8009aa:	e8 4a 12 00 00       	call   801bf9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009af:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ba:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bf:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c5:	83 c4 10             	add    $0x10,%esp
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <devfile_write>:
{
  8009d2:	f3 0f 1e fb          	endbr32 
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009df:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009e9:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ef:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009f8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009fd:	50                   	push   %eax
  8009fe:	ff 75 0c             	pushl  0xc(%ebp)
  800a01:	68 08 50 80 00       	push   $0x805008
  800a06:	e8 ec 13 00 00       	call   801df7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a10:	b8 04 00 00 00       	mov    $0x4,%eax
  800a15:	e8 ba fe ff ff       	call   8008d4 <fsipc>
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <devfile_read>:
{
  800a1c:	f3 0f 1e fb          	endbr32 
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a33:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a43:	e8 8c fe ff ff       	call   8008d4 <fsipc>
  800a48:	89 c3                	mov    %eax,%ebx
  800a4a:	85 c0                	test   %eax,%eax
  800a4c:	78 1f                	js     800a6d <devfile_read+0x51>
	assert(r <= n);
  800a4e:	39 f0                	cmp    %esi,%eax
  800a50:	77 24                	ja     800a76 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a52:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a57:	7f 36                	jg     800a8f <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a59:	83 ec 04             	sub    $0x4,%esp
  800a5c:	50                   	push   %eax
  800a5d:	68 00 50 80 00       	push   $0x805000
  800a62:	ff 75 0c             	pushl  0xc(%ebp)
  800a65:	e8 8d 13 00 00       	call   801df7 <memmove>
	return r;
  800a6a:	83 c4 10             	add    $0x10,%esp
}
  800a6d:	89 d8                	mov    %ebx,%eax
  800a6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    
	assert(r <= n);
  800a76:	68 08 24 80 00       	push   $0x802408
  800a7b:	68 0f 24 80 00       	push   $0x80240f
  800a80:	68 8c 00 00 00       	push   $0x8c
  800a85:	68 24 24 80 00       	push   $0x802424
  800a8a:	e8 79 0a 00 00       	call   801508 <_panic>
	assert(r <= PGSIZE);
  800a8f:	68 2f 24 80 00       	push   $0x80242f
  800a94:	68 0f 24 80 00       	push   $0x80240f
  800a99:	68 8d 00 00 00       	push   $0x8d
  800a9e:	68 24 24 80 00       	push   $0x802424
  800aa3:	e8 60 0a 00 00       	call   801508 <_panic>

00800aa8 <open>:
{
  800aa8:	f3 0f 1e fb          	endbr32 
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 1c             	sub    $0x1c,%esp
  800ab4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ab7:	56                   	push   %esi
  800ab8:	e8 f9 10 00 00       	call   801bb6 <strlen>
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac5:	7f 6c                	jg     800b33 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acd:	50                   	push   %eax
  800ace:	e8 5c f8 ff ff       	call   80032f <fd_alloc>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	78 3c                	js     800b18 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800adc:	83 ec 08             	sub    $0x8,%esp
  800adf:	56                   	push   %esi
  800ae0:	68 00 50 80 00       	push   $0x805000
  800ae5:	e8 0f 11 00 00       	call   801bf9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af5:	b8 01 00 00 00       	mov    $0x1,%eax
  800afa:	e8 d5 fd ff ff       	call   8008d4 <fsipc>
  800aff:	89 c3                	mov    %eax,%ebx
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	85 c0                	test   %eax,%eax
  800b06:	78 19                	js     800b21 <open+0x79>
	return fd2num(fd);
  800b08:	83 ec 0c             	sub    $0xc,%esp
  800b0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0e:	e8 ed f7 ff ff       	call   800300 <fd2num>
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	83 c4 10             	add    $0x10,%esp
}
  800b18:	89 d8                	mov    %ebx,%eax
  800b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    
		fd_close(fd, 0);
  800b21:	83 ec 08             	sub    $0x8,%esp
  800b24:	6a 00                	push   $0x0
  800b26:	ff 75 f4             	pushl  -0xc(%ebp)
  800b29:	e8 0a f9 ff ff       	call   800438 <fd_close>
		return r;
  800b2e:	83 c4 10             	add    $0x10,%esp
  800b31:	eb e5                	jmp    800b18 <open+0x70>
		return -E_BAD_PATH;
  800b33:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b38:	eb de                	jmp    800b18 <open+0x70>

00800b3a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3a:	f3 0f 1e fb          	endbr32 
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4e:	e8 81 fd ff ff       	call   8008d4 <fsipc>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b55:	f3 0f 1e fb          	endbr32 
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b5f:	68 9b 24 80 00       	push   $0x80249b
  800b64:	ff 75 0c             	pushl  0xc(%ebp)
  800b67:	e8 8d 10 00 00       	call   801bf9 <strcpy>
	return 0;
}
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <devsock_close>:
{
  800b73:	f3 0f 1e fb          	endbr32 
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 10             	sub    $0x10,%esp
  800b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b81:	53                   	push   %ebx
  800b82:	e8 2e 15 00 00       	call   8020b5 <pageref>
  800b87:	89 c2                	mov    %eax,%edx
  800b89:	83 c4 10             	add    $0x10,%esp
		return 0;
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800b91:	83 fa 01             	cmp    $0x1,%edx
  800b94:	74 05                	je     800b9b <devsock_close+0x28>
}
  800b96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	ff 73 0c             	pushl  0xc(%ebx)
  800ba1:	e8 e3 02 00 00       	call   800e89 <nsipc_close>
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	eb eb                	jmp    800b96 <devsock_close+0x23>

00800bab <devsock_write>:
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bb5:	6a 00                	push   $0x0
  800bb7:	ff 75 10             	pushl  0x10(%ebp)
  800bba:	ff 75 0c             	pushl  0xc(%ebp)
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	ff 70 0c             	pushl  0xc(%eax)
  800bc3:	e8 b5 03 00 00       	call   800f7d <nsipc_send>
}
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <devsock_read>:
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bd4:	6a 00                	push   $0x0
  800bd6:	ff 75 10             	pushl  0x10(%ebp)
  800bd9:	ff 75 0c             	pushl  0xc(%ebp)
  800bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdf:	ff 70 0c             	pushl  0xc(%eax)
  800be2:	e8 1f 03 00 00       	call   800f06 <nsipc_recv>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <fd2sockid>:
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bef:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bf2:	52                   	push   %edx
  800bf3:	50                   	push   %eax
  800bf4:	e8 8c f7 ff ff       	call   800385 <fd_lookup>
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	78 10                	js     800c10 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c03:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800c09:	39 08                	cmp    %ecx,(%eax)
  800c0b:	75 05                	jne    800c12 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c0d:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    
		return -E_NOT_SUPP;
  800c12:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c17:	eb f7                	jmp    800c10 <fd2sockid+0x27>

00800c19 <alloc_sockfd>:
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 1c             	sub    $0x1c,%esp
  800c21:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c26:	50                   	push   %eax
  800c27:	e8 03 f7 ff ff       	call   80032f <fd_alloc>
  800c2c:	89 c3                	mov    %eax,%ebx
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	85 c0                	test   %eax,%eax
  800c33:	78 43                	js     800c78 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c35:	83 ec 04             	sub    $0x4,%esp
  800c38:	68 07 04 00 00       	push   $0x407
  800c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  800c40:	6a 00                	push   $0x0
  800c42:	e8 22 f5 ff ff       	call   800169 <sys_page_alloc>
  800c47:	89 c3                	mov    %eax,%ebx
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	78 28                	js     800c78 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c53:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c59:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c65:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	e8 8f f6 ff ff       	call   800300 <fd2num>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	eb 0c                	jmp    800c84 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	56                   	push   %esi
  800c7c:	e8 08 02 00 00       	call   800e89 <nsipc_close>
		return r;
  800c81:	83 c4 10             	add    $0x10,%esp
}
  800c84:	89 d8                	mov    %ebx,%eax
  800c86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <accept>:
{
  800c8d:	f3 0f 1e fb          	endbr32 
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	e8 4a ff ff ff       	call   800be9 <fd2sockid>
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	78 1b                	js     800cbe <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ca3:	83 ec 04             	sub    $0x4,%esp
  800ca6:	ff 75 10             	pushl  0x10(%ebp)
  800ca9:	ff 75 0c             	pushl  0xc(%ebp)
  800cac:	50                   	push   %eax
  800cad:	e8 22 01 00 00       	call   800dd4 <nsipc_accept>
  800cb2:	83 c4 10             	add    $0x10,%esp
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	78 05                	js     800cbe <accept+0x31>
	return alloc_sockfd(r);
  800cb9:	e8 5b ff ff ff       	call   800c19 <alloc_sockfd>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <bind>:
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	e8 17 ff ff ff       	call   800be9 <fd2sockid>
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	78 12                	js     800ce8 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800cd6:	83 ec 04             	sub    $0x4,%esp
  800cd9:	ff 75 10             	pushl  0x10(%ebp)
  800cdc:	ff 75 0c             	pushl  0xc(%ebp)
  800cdf:	50                   	push   %eax
  800ce0:	e8 45 01 00 00       	call   800e2a <nsipc_bind>
  800ce5:	83 c4 10             	add    $0x10,%esp
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    

00800cea <shutdown>:
{
  800cea:	f3 0f 1e fb          	endbr32 
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	e8 ed fe ff ff       	call   800be9 <fd2sockid>
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	78 0f                	js     800d0f <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800d00:	83 ec 08             	sub    $0x8,%esp
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	50                   	push   %eax
  800d07:	e8 57 01 00 00       	call   800e63 <nsipc_shutdown>
  800d0c:	83 c4 10             	add    $0x10,%esp
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    

00800d11 <connect>:
{
  800d11:	f3 0f 1e fb          	endbr32 
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	e8 c6 fe ff ff       	call   800be9 <fd2sockid>
  800d23:	85 c0                	test   %eax,%eax
  800d25:	78 12                	js     800d39 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d27:	83 ec 04             	sub    $0x4,%esp
  800d2a:	ff 75 10             	pushl  0x10(%ebp)
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	50                   	push   %eax
  800d31:	e8 71 01 00 00       	call   800ea7 <nsipc_connect>
  800d36:	83 c4 10             	add    $0x10,%esp
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <listen>:
{
  800d3b:	f3 0f 1e fb          	endbr32 
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	e8 9c fe ff ff       	call   800be9 <fd2sockid>
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	78 0f                	js     800d60 <listen+0x25>
	return nsipc_listen(r, backlog);
  800d51:	83 ec 08             	sub    $0x8,%esp
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	50                   	push   %eax
  800d58:	e8 83 01 00 00       	call   800ee0 <nsipc_listen>
  800d5d:	83 c4 10             	add    $0x10,%esp
}
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d62:	f3 0f 1e fb          	endbr32 
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d6c:	ff 75 10             	pushl  0x10(%ebp)
  800d6f:	ff 75 0c             	pushl  0xc(%ebp)
  800d72:	ff 75 08             	pushl  0x8(%ebp)
  800d75:	e8 65 02 00 00       	call   800fdf <nsipc_socket>
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	78 05                	js     800d86 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d81:	e8 93 fe ff ff       	call   800c19 <alloc_sockfd>
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 04             	sub    $0x4,%esp
  800d8f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d91:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d98:	74 26                	je     800dc0 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d9a:	6a 07                	push   $0x7
  800d9c:	68 00 60 80 00       	push   $0x806000
  800da1:	53                   	push   %ebx
  800da2:	ff 35 04 40 80 00    	pushl  0x804004
  800da8:	e8 73 12 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dad:	83 c4 0c             	add    $0xc,%esp
  800db0:	6a 00                	push   $0x0
  800db2:	6a 00                	push   $0x0
  800db4:	6a 00                	push   $0x0
  800db6:	e8 f8 11 00 00       	call   801fb3 <ipc_recv>
}
  800dbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	6a 02                	push   $0x2
  800dc5:	e8 ae 12 00 00       	call   802078 <ipc_find_env>
  800dca:	a3 04 40 80 00       	mov    %eax,0x804004
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	eb c6                	jmp    800d9a <nsipc+0x12>

00800dd4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dd4:	f3 0f 1e fb          	endbr32 
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800de8:	8b 06                	mov    (%esi),%eax
  800dea:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800def:	b8 01 00 00 00       	mov    $0x1,%eax
  800df4:	e8 8f ff ff ff       	call   800d88 <nsipc>
  800df9:	89 c3                	mov    %eax,%ebx
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	79 09                	jns    800e08 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800dff:	89 d8                	mov    %ebx,%eax
  800e01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	ff 35 10 60 80 00    	pushl  0x806010
  800e11:	68 00 60 80 00       	push   $0x806000
  800e16:	ff 75 0c             	pushl  0xc(%ebp)
  800e19:	e8 d9 0f 00 00       	call   801df7 <memmove>
		*addrlen = ret->ret_addrlen;
  800e1e:	a1 10 60 80 00       	mov    0x806010,%eax
  800e23:	89 06                	mov    %eax,(%esi)
  800e25:	83 c4 10             	add    $0x10,%esp
	return r;
  800e28:	eb d5                	jmp    800dff <nsipc_accept+0x2b>

00800e2a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e2a:	f3 0f 1e fb          	endbr32 
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	53                   	push   %ebx
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e40:	53                   	push   %ebx
  800e41:	ff 75 0c             	pushl  0xc(%ebp)
  800e44:	68 04 60 80 00       	push   $0x806004
  800e49:	e8 a9 0f 00 00       	call   801df7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e4e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e54:	b8 02 00 00 00       	mov    $0x2,%eax
  800e59:	e8 2a ff ff ff       	call   800d88 <nsipc>
}
  800e5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e61:	c9                   	leave  
  800e62:	c3                   	ret    

00800e63 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e63:	f3 0f 1e fb          	endbr32 
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e78:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e7d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e82:	e8 01 ff ff ff       	call   800d88 <nsipc>
}
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <nsipc_close>:

int
nsipc_close(int s)
{
  800e89:	f3 0f 1e fb          	endbr32 
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea0:	e8 e3 fe ff ff       	call   800d88 <nsipc>
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea7:	f3 0f 1e fb          	endbr32 
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ebd:	53                   	push   %ebx
  800ebe:	ff 75 0c             	pushl  0xc(%ebp)
  800ec1:	68 04 60 80 00       	push   $0x806004
  800ec6:	e8 2c 0f 00 00       	call   801df7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ecb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ed1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed6:	e8 ad fe ff ff       	call   800d88 <nsipc>
}
  800edb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800eea:	8b 45 08             	mov    0x8(%ebp),%eax
  800eed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800efa:	b8 06 00 00 00       	mov    $0x6,%eax
  800eff:	e8 84 fe ff ff       	call   800d88 <nsipc>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f06:	f3 0f 1e fb          	endbr32 
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f1a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f20:	8b 45 14             	mov    0x14(%ebp),%eax
  800f23:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f28:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2d:	e8 56 fe ff ff       	call   800d88 <nsipc>
  800f32:	89 c3                	mov    %eax,%ebx
  800f34:	85 c0                	test   %eax,%eax
  800f36:	78 26                	js     800f5e <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f38:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f3e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f43:	0f 4e c6             	cmovle %esi,%eax
  800f46:	39 c3                	cmp    %eax,%ebx
  800f48:	7f 1d                	jg     800f67 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f4a:	83 ec 04             	sub    $0x4,%esp
  800f4d:	53                   	push   %ebx
  800f4e:	68 00 60 80 00       	push   $0x806000
  800f53:	ff 75 0c             	pushl  0xc(%ebp)
  800f56:	e8 9c 0e 00 00       	call   801df7 <memmove>
  800f5b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f5e:	89 d8                	mov    %ebx,%eax
  800f60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f67:	68 a7 24 80 00       	push   $0x8024a7
  800f6c:	68 0f 24 80 00       	push   $0x80240f
  800f71:	6a 62                	push   $0x62
  800f73:	68 bc 24 80 00       	push   $0x8024bc
  800f78:	e8 8b 05 00 00       	call   801508 <_panic>

00800f7d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f7d:	f3 0f 1e fb          	endbr32 
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	53                   	push   %ebx
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f93:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f99:	7f 2e                	jg     800fc9 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	53                   	push   %ebx
  800f9f:	ff 75 0c             	pushl  0xc(%ebp)
  800fa2:	68 0c 60 80 00       	push   $0x80600c
  800fa7:	e8 4b 0e 00 00       	call   801df7 <memmove>
	nsipcbuf.send.req_size = size;
  800fac:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fb2:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fba:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbf:	e8 c4 fd ff ff       	call   800d88 <nsipc>
}
  800fc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    
	assert(size < 1600);
  800fc9:	68 c8 24 80 00       	push   $0x8024c8
  800fce:	68 0f 24 80 00       	push   $0x80240f
  800fd3:	6a 6d                	push   $0x6d
  800fd5:	68 bc 24 80 00       	push   $0x8024bc
  800fda:	e8 29 05 00 00       	call   801508 <_panic>

00800fdf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdf:	f3 0f 1e fb          	endbr32 
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801001:	b8 09 00 00 00       	mov    $0x9,%eax
  801006:	e8 7d fd ff ff       	call   800d88 <nsipc>
}
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100d:	f3 0f 1e fb          	endbr32 
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	ff 75 08             	pushl  0x8(%ebp)
  80101f:	e8 f0 f2 ff ff       	call   800314 <fd2data>
  801024:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801026:	83 c4 08             	add    $0x8,%esp
  801029:	68 d4 24 80 00       	push   $0x8024d4
  80102e:	53                   	push   %ebx
  80102f:	e8 c5 0b 00 00       	call   801bf9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801034:	8b 46 04             	mov    0x4(%esi),%eax
  801037:	2b 06                	sub    (%esi),%eax
  801039:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801046:	00 00 00 
	stat->st_dev = &devpipe;
  801049:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801050:	30 80 00 
	return 0;
}
  801053:	b8 00 00 00 00       	mov    $0x0,%eax
  801058:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    

0080105f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105f:	f3 0f 1e fb          	endbr32 
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80106d:	53                   	push   %ebx
  80106e:	6a 00                	push   $0x0
  801070:	e8 3f f1 ff ff       	call   8001b4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801075:	89 1c 24             	mov    %ebx,(%esp)
  801078:	e8 97 f2 ff ff       	call   800314 <fd2data>
  80107d:	83 c4 08             	add    $0x8,%esp
  801080:	50                   	push   %eax
  801081:	6a 00                	push   $0x0
  801083:	e8 2c f1 ff ff       	call   8001b4 <sys_page_unmap>
}
  801088:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <_pipeisclosed>:
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 1c             	sub    $0x1c,%esp
  801096:	89 c7                	mov    %eax,%edi
  801098:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80109a:	a1 08 40 80 00       	mov    0x804008,%eax
  80109f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	57                   	push   %edi
  8010a6:	e8 0a 10 00 00       	call   8020b5 <pageref>
  8010ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010ae:	89 34 24             	mov    %esi,(%esp)
  8010b1:	e8 ff 0f 00 00       	call   8020b5 <pageref>
		nn = thisenv->env_runs;
  8010b6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010bc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	39 cb                	cmp    %ecx,%ebx
  8010c4:	74 1b                	je     8010e1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010c6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c9:	75 cf                	jne    80109a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010cb:	8b 42 58             	mov    0x58(%edx),%eax
  8010ce:	6a 01                	push   $0x1
  8010d0:	50                   	push   %eax
  8010d1:	53                   	push   %ebx
  8010d2:	68 db 24 80 00       	push   $0x8024db
  8010d7:	e8 13 05 00 00       	call   8015ef <cprintf>
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	eb b9                	jmp    80109a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010e1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010e4:	0f 94 c0             	sete   %al
  8010e7:	0f b6 c0             	movzbl %al,%eax
}
  8010ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <devpipe_write>:
{
  8010f2:	f3 0f 1e fb          	endbr32 
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 28             	sub    $0x28,%esp
  8010ff:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801102:	56                   	push   %esi
  801103:	e8 0c f2 ff ff       	call   800314 <fd2data>
  801108:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	bf 00 00 00 00       	mov    $0x0,%edi
  801112:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801115:	74 4f                	je     801166 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801117:	8b 43 04             	mov    0x4(%ebx),%eax
  80111a:	8b 0b                	mov    (%ebx),%ecx
  80111c:	8d 51 20             	lea    0x20(%ecx),%edx
  80111f:	39 d0                	cmp    %edx,%eax
  801121:	72 14                	jb     801137 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801123:	89 da                	mov    %ebx,%edx
  801125:	89 f0                	mov    %esi,%eax
  801127:	e8 61 ff ff ff       	call   80108d <_pipeisclosed>
  80112c:	85 c0                	test   %eax,%eax
  80112e:	75 3b                	jne    80116b <devpipe_write+0x79>
			sys_yield();
  801130:	e8 11 f0 ff ff       	call   800146 <sys_yield>
  801135:	eb e0                	jmp    801117 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801137:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 fa 1f             	sar    $0x1f,%edx
  801146:	89 d1                	mov    %edx,%ecx
  801148:	c1 e9 1b             	shr    $0x1b,%ecx
  80114b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114e:	83 e2 1f             	and    $0x1f,%edx
  801151:	29 ca                	sub    %ecx,%edx
  801153:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801157:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80115b:	83 c0 01             	add    $0x1,%eax
  80115e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801161:	83 c7 01             	add    $0x1,%edi
  801164:	eb ac                	jmp    801112 <devpipe_write+0x20>
	return i;
  801166:	8b 45 10             	mov    0x10(%ebp),%eax
  801169:	eb 05                	jmp    801170 <devpipe_write+0x7e>
				return 0;
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <devpipe_read>:
{
  801178:	f3 0f 1e fb          	endbr32 
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
  801182:	83 ec 18             	sub    $0x18,%esp
  801185:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801188:	57                   	push   %edi
  801189:	e8 86 f1 ff ff       	call   800314 <fd2data>
  80118e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	be 00 00 00 00       	mov    $0x0,%esi
  801198:	3b 75 10             	cmp    0x10(%ebp),%esi
  80119b:	75 14                	jne    8011b1 <devpipe_read+0x39>
	return i;
  80119d:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a0:	eb 02                	jmp    8011a4 <devpipe_read+0x2c>
				return i;
  8011a2:	89 f0                	mov    %esi,%eax
}
  8011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5f                   	pop    %edi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    
			sys_yield();
  8011ac:	e8 95 ef ff ff       	call   800146 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011b1:	8b 03                	mov    (%ebx),%eax
  8011b3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011b6:	75 18                	jne    8011d0 <devpipe_read+0x58>
			if (i > 0)
  8011b8:	85 f6                	test   %esi,%esi
  8011ba:	75 e6                	jne    8011a2 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011bc:	89 da                	mov    %ebx,%edx
  8011be:	89 f8                	mov    %edi,%eax
  8011c0:	e8 c8 fe ff ff       	call   80108d <_pipeisclosed>
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	74 e3                	je     8011ac <devpipe_read+0x34>
				return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ce:	eb d4                	jmp    8011a4 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011d0:	99                   	cltd   
  8011d1:	c1 ea 1b             	shr    $0x1b,%edx
  8011d4:	01 d0                	add    %edx,%eax
  8011d6:	83 e0 1f             	and    $0x1f,%eax
  8011d9:	29 d0                	sub    %edx,%eax
  8011db:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011e6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011e9:	83 c6 01             	add    $0x1,%esi
  8011ec:	eb aa                	jmp    801198 <devpipe_read+0x20>

008011ee <pipe>:
{
  8011ee:	f3 0f 1e fb          	endbr32 
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	e8 2c f1 ff ff       	call   80032f <fd_alloc>
  801203:	89 c3                	mov    %eax,%ebx
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	0f 88 23 01 00 00    	js     801333 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	68 07 04 00 00       	push   $0x407
  801218:	ff 75 f4             	pushl  -0xc(%ebp)
  80121b:	6a 00                	push   $0x0
  80121d:	e8 47 ef ff ff       	call   800169 <sys_page_alloc>
  801222:	89 c3                	mov    %eax,%ebx
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	0f 88 04 01 00 00    	js     801333 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80122f:	83 ec 0c             	sub    $0xc,%esp
  801232:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	e8 f4 f0 ff ff       	call   80032f <fd_alloc>
  80123b:	89 c3                	mov    %eax,%ebx
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	85 c0                	test   %eax,%eax
  801242:	0f 88 db 00 00 00    	js     801323 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	68 07 04 00 00       	push   $0x407
  801250:	ff 75 f0             	pushl  -0x10(%ebp)
  801253:	6a 00                	push   $0x0
  801255:	e8 0f ef ff ff       	call   800169 <sys_page_alloc>
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	0f 88 bc 00 00 00    	js     801323 <pipe+0x135>
	va = fd2data(fd0);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	ff 75 f4             	pushl  -0xc(%ebp)
  80126d:	e8 a2 f0 ff ff       	call   800314 <fd2data>
  801272:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801274:	83 c4 0c             	add    $0xc,%esp
  801277:	68 07 04 00 00       	push   $0x407
  80127c:	50                   	push   %eax
  80127d:	6a 00                	push   $0x0
  80127f:	e8 e5 ee ff ff       	call   800169 <sys_page_alloc>
  801284:	89 c3                	mov    %eax,%ebx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	0f 88 82 00 00 00    	js     801313 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	ff 75 f0             	pushl  -0x10(%ebp)
  801297:	e8 78 f0 ff ff       	call   800314 <fd2data>
  80129c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012a3:	50                   	push   %eax
  8012a4:	6a 00                	push   $0x0
  8012a6:	56                   	push   %esi
  8012a7:	6a 00                	push   $0x0
  8012a9:	e8 e1 ee ff ff       	call   80018f <sys_page_map>
  8012ae:	89 c3                	mov    %eax,%ebx
  8012b0:	83 c4 20             	add    $0x20,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 4e                	js     801305 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8012b7:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bf:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ce:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e0:	e8 1b f0 ff ff       	call   800300 <fd2num>
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012ea:	83 c4 04             	add    $0x4,%esp
  8012ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f0:	e8 0b f0 ff ff       	call   800300 <fd2num>
  8012f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801303:	eb 2e                	jmp    801333 <pipe+0x145>
	sys_page_unmap(0, va);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	56                   	push   %esi
  801309:	6a 00                	push   $0x0
  80130b:	e8 a4 ee ff ff       	call   8001b4 <sys_page_unmap>
  801310:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 f0             	pushl  -0x10(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 94 ee ff ff       	call   8001b4 <sys_page_unmap>
  801320:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	ff 75 f4             	pushl  -0xc(%ebp)
  801329:	6a 00                	push   $0x0
  80132b:	e8 84 ee ff ff       	call   8001b4 <sys_page_unmap>
  801330:	83 c4 10             	add    $0x10,%esp
}
  801333:	89 d8                	mov    %ebx,%eax
  801335:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801338:	5b                   	pop    %ebx
  801339:	5e                   	pop    %esi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <pipeisclosed>:
{
  80133c:	f3 0f 1e fb          	endbr32 
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	ff 75 08             	pushl  0x8(%ebp)
  80134d:	e8 33 f0 ff ff       	call   800385 <fd_lookup>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 18                	js     801371 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	ff 75 f4             	pushl  -0xc(%ebp)
  80135f:	e8 b0 ef ff ff       	call   800314 <fd2data>
  801364:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	e8 1f fd ff ff       	call   80108d <_pipeisclosed>
  80136e:	83 c4 10             	add    $0x10,%esp
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801373:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
  80137c:	c3                   	ret    

0080137d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80137d:	f3 0f 1e fb          	endbr32 
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801387:	68 f3 24 80 00       	push   $0x8024f3
  80138c:	ff 75 0c             	pushl  0xc(%ebp)
  80138f:	e8 65 08 00 00       	call   801bf9 <strcpy>
	return 0;
}
  801394:	b8 00 00 00 00       	mov    $0x0,%eax
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <devcons_write>:
{
  80139b:	f3 0f 1e fb          	endbr32 
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	57                   	push   %edi
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8013ab:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013b0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013b6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b9:	73 31                	jae    8013ec <devcons_write+0x51>
		m = n - tot;
  8013bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013be:	29 f3                	sub    %esi,%ebx
  8013c0:	83 fb 7f             	cmp    $0x7f,%ebx
  8013c3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013c8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	89 f0                	mov    %esi,%eax
  8013d1:	03 45 0c             	add    0xc(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	57                   	push   %edi
  8013d6:	e8 1c 0a 00 00       	call   801df7 <memmove>
		sys_cputs(buf, m);
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	53                   	push   %ebx
  8013df:	57                   	push   %edi
  8013e0:	e8 d5 ec ff ff       	call   8000ba <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013e5:	01 de                	add    %ebx,%esi
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	eb ca                	jmp    8013b6 <devcons_write+0x1b>
}
  8013ec:	89 f0                	mov    %esi,%eax
  8013ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5e                   	pop    %esi
  8013f3:	5f                   	pop    %edi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <devcons_read>:
{
  8013f6:	f3 0f 1e fb          	endbr32 
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 08             	sub    $0x8,%esp
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801405:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801409:	74 21                	je     80142c <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80140b:	e8 cc ec ff ff       	call   8000dc <sys_cgetc>
  801410:	85 c0                	test   %eax,%eax
  801412:	75 07                	jne    80141b <devcons_read+0x25>
		sys_yield();
  801414:	e8 2d ed ff ff       	call   800146 <sys_yield>
  801419:	eb f0                	jmp    80140b <devcons_read+0x15>
	if (c < 0)
  80141b:	78 0f                	js     80142c <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80141d:	83 f8 04             	cmp    $0x4,%eax
  801420:	74 0c                	je     80142e <devcons_read+0x38>
	*(char*)vbuf = c;
  801422:	8b 55 0c             	mov    0xc(%ebp),%edx
  801425:	88 02                	mov    %al,(%edx)
	return 1;
  801427:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    
		return 0;
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
  801433:	eb f7                	jmp    80142c <devcons_read+0x36>

00801435 <cputchar>:
{
  801435:	f3 0f 1e fb          	endbr32 
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80143f:	8b 45 08             	mov    0x8(%ebp),%eax
  801442:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801445:	6a 01                	push   $0x1
  801447:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	e8 6a ec ff ff       	call   8000ba <sys_cputs>
}
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <getchar>:
{
  801455:	f3 0f 1e fb          	endbr32 
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80145f:	6a 01                	push   $0x1
  801461:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	6a 00                	push   $0x0
  801467:	e8 a1 f1 ff ff       	call   80060d <read>
	if (r < 0)
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 06                	js     801479 <getchar+0x24>
	if (r < 1)
  801473:	74 06                	je     80147b <getchar+0x26>
	return c;
  801475:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801479:	c9                   	leave  
  80147a:	c3                   	ret    
		return -E_EOF;
  80147b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801480:	eb f7                	jmp    801479 <getchar+0x24>

00801482 <iscons>:
{
  801482:	f3 0f 1e fb          	endbr32 
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148f:	50                   	push   %eax
  801490:	ff 75 08             	pushl  0x8(%ebp)
  801493:	e8 ed ee ff ff       	call   800385 <fd_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 11                	js     8014b0 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80149f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a2:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014a8:	39 10                	cmp    %edx,(%eax)
  8014aa:	0f 94 c0             	sete   %al
  8014ad:	0f b6 c0             	movzbl %al,%eax
}
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <opencons>:
{
  8014b2:	f3 0f 1e fb          	endbr32 
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	e8 6a ee ff ff       	call   80032f <fd_alloc>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 3a                	js     801506 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	68 07 04 00 00       	push   $0x407
  8014d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d7:	6a 00                	push   $0x0
  8014d9:	e8 8b ec ff ff       	call   800169 <sys_page_alloc>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 21                	js     801506 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e8:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014ee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	50                   	push   %eax
  8014fe:	e8 fd ed ff ff       	call   800300 <fd2num>
  801503:	83 c4 10             	add    $0x10,%esp
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801508:	f3 0f 1e fb          	endbr32 
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801511:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801514:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80151a:	e8 04 ec ff ff       	call   800123 <sys_getenvid>
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	ff 75 0c             	pushl  0xc(%ebp)
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	56                   	push   %esi
  801529:	50                   	push   %eax
  80152a:	68 00 25 80 00       	push   $0x802500
  80152f:	e8 bb 00 00 00       	call   8015ef <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801534:	83 c4 18             	add    $0x18,%esp
  801537:	53                   	push   %ebx
  801538:	ff 75 10             	pushl  0x10(%ebp)
  80153b:	e8 5a 00 00 00       	call   80159a <vcprintf>
	cprintf("\n");
  801540:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  801547:	e8 a3 00 00 00       	call   8015ef <cprintf>
  80154c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80154f:	cc                   	int3   
  801550:	eb fd                	jmp    80154f <_panic+0x47>

00801552 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801552:	f3 0f 1e fb          	endbr32 
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	53                   	push   %ebx
  80155a:	83 ec 04             	sub    $0x4,%esp
  80155d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801560:	8b 13                	mov    (%ebx),%edx
  801562:	8d 42 01             	lea    0x1(%edx),%eax
  801565:	89 03                	mov    %eax,(%ebx)
  801567:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80156e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801573:	74 09                	je     80157e <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801575:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	68 ff 00 00 00       	push   $0xff
  801586:	8d 43 08             	lea    0x8(%ebx),%eax
  801589:	50                   	push   %eax
  80158a:	e8 2b eb ff ff       	call   8000ba <sys_cputs>
		b->idx = 0;
  80158f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	eb db                	jmp    801575 <putch+0x23>

0080159a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80159a:	f3 0f 1e fb          	endbr32 
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015ae:	00 00 00 
	b.cnt = 0;
  8015b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015bb:	ff 75 0c             	pushl  0xc(%ebp)
  8015be:	ff 75 08             	pushl  0x8(%ebp)
  8015c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	68 52 15 80 00       	push   $0x801552
  8015cd:	e8 20 01 00 00       	call   8016f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015db:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015e1:	50                   	push   %eax
  8015e2:	e8 d3 ea ff ff       	call   8000ba <sys_cputs>

	return b.cnt;
}
  8015e7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015ef:	f3 0f 1e fb          	endbr32 
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015fc:	50                   	push   %eax
  8015fd:	ff 75 08             	pushl  0x8(%ebp)
  801600:	e8 95 ff ff ff       	call   80159a <vcprintf>
	va_end(ap);

	return cnt;
}
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	57                   	push   %edi
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 1c             	sub    $0x1c,%esp
  801610:	89 c7                	mov    %eax,%edi
  801612:	89 d6                	mov    %edx,%esi
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161a:	89 d1                	mov    %edx,%ecx
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801621:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801624:	8b 45 10             	mov    0x10(%ebp),%eax
  801627:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80162a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80162d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801634:	39 c2                	cmp    %eax,%edx
  801636:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801639:	72 3e                	jb     801679 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	ff 75 18             	pushl  0x18(%ebp)
  801641:	83 eb 01             	sub    $0x1,%ebx
  801644:	53                   	push   %ebx
  801645:	50                   	push   %eax
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164c:	ff 75 e0             	pushl  -0x20(%ebp)
  80164f:	ff 75 dc             	pushl  -0x24(%ebp)
  801652:	ff 75 d8             	pushl  -0x28(%ebp)
  801655:	e8 a6 0a 00 00       	call   802100 <__udivdi3>
  80165a:	83 c4 18             	add    $0x18,%esp
  80165d:	52                   	push   %edx
  80165e:	50                   	push   %eax
  80165f:	89 f2                	mov    %esi,%edx
  801661:	89 f8                	mov    %edi,%eax
  801663:	e8 9f ff ff ff       	call   801607 <printnum>
  801668:	83 c4 20             	add    $0x20,%esp
  80166b:	eb 13                	jmp    801680 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	56                   	push   %esi
  801671:	ff 75 18             	pushl  0x18(%ebp)
  801674:	ff d7                	call   *%edi
  801676:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801679:	83 eb 01             	sub    $0x1,%ebx
  80167c:	85 db                	test   %ebx,%ebx
  80167e:	7f ed                	jg     80166d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	56                   	push   %esi
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	ff 75 e4             	pushl  -0x1c(%ebp)
  80168a:	ff 75 e0             	pushl  -0x20(%ebp)
  80168d:	ff 75 dc             	pushl  -0x24(%ebp)
  801690:	ff 75 d8             	pushl  -0x28(%ebp)
  801693:	e8 78 0b 00 00       	call   802210 <__umoddi3>
  801698:	83 c4 14             	add    $0x14,%esp
  80169b:	0f be 80 23 25 80 00 	movsbl 0x802523(%eax),%eax
  8016a2:	50                   	push   %eax
  8016a3:	ff d7                	call   *%edi
}
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5f                   	pop    %edi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016b0:	f3 0f 1e fb          	endbr32 
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016be:	8b 10                	mov    (%eax),%edx
  8016c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8016c3:	73 0a                	jae    8016cf <sprintputch+0x1f>
		*b->buf++ = ch;
  8016c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016c8:	89 08                	mov    %ecx,(%eax)
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	88 02                	mov    %al,(%edx)
}
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <printfmt>:
{
  8016d1:	f3 0f 1e fb          	endbr32 
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016de:	50                   	push   %eax
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	ff 75 08             	pushl  0x8(%ebp)
  8016e8:	e8 05 00 00 00       	call   8016f2 <vprintfmt>
}
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <vprintfmt>:
{
  8016f2:	f3 0f 1e fb          	endbr32 
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 3c             	sub    $0x3c,%esp
  8016ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801702:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801705:	8b 7d 10             	mov    0x10(%ebp),%edi
  801708:	e9 8e 03 00 00       	jmp    801a9b <vprintfmt+0x3a9>
		padc = ' ';
  80170d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801711:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801718:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80171f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801726:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80172b:	8d 47 01             	lea    0x1(%edi),%eax
  80172e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801731:	0f b6 17             	movzbl (%edi),%edx
  801734:	8d 42 dd             	lea    -0x23(%edx),%eax
  801737:	3c 55                	cmp    $0x55,%al
  801739:	0f 87 df 03 00 00    	ja     801b1e <vprintfmt+0x42c>
  80173f:	0f b6 c0             	movzbl %al,%eax
  801742:	3e ff 24 85 60 26 80 	notrack jmp *0x802660(,%eax,4)
  801749:	00 
  80174a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80174d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801751:	eb d8                	jmp    80172b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801753:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801756:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80175a:	eb cf                	jmp    80172b <vprintfmt+0x39>
  80175c:	0f b6 d2             	movzbl %dl,%edx
  80175f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801762:	b8 00 00 00 00       	mov    $0x0,%eax
  801767:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80176a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80176d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801771:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801774:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801777:	83 f9 09             	cmp    $0x9,%ecx
  80177a:	77 55                	ja     8017d1 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80177c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80177f:	eb e9                	jmp    80176a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801781:	8b 45 14             	mov    0x14(%ebp),%eax
  801784:	8b 00                	mov    (%eax),%eax
  801786:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801789:	8b 45 14             	mov    0x14(%ebp),%eax
  80178c:	8d 40 04             	lea    0x4(%eax),%eax
  80178f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801792:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801795:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801799:	79 90                	jns    80172b <vprintfmt+0x39>
				width = precision, precision = -1;
  80179b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80179e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8017a8:	eb 81                	jmp    80172b <vprintfmt+0x39>
  8017aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b4:	0f 49 d0             	cmovns %eax,%edx
  8017b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017bd:	e9 69 ff ff ff       	jmp    80172b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017c5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017cc:	e9 5a ff ff ff       	jmp    80172b <vprintfmt+0x39>
  8017d1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017d7:	eb bc                	jmp    801795 <vprintfmt+0xa3>
			lflag++;
  8017d9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017df:	e9 47 ff ff ff       	jmp    80172b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e7:	8d 78 04             	lea    0x4(%eax),%edi
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	53                   	push   %ebx
  8017ee:	ff 30                	pushl  (%eax)
  8017f0:	ff d6                	call   *%esi
			break;
  8017f2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017f5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017f8:	e9 9b 02 00 00       	jmp    801a98 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8017fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801800:	8d 78 04             	lea    0x4(%eax),%edi
  801803:	8b 00                	mov    (%eax),%eax
  801805:	99                   	cltd   
  801806:	31 d0                	xor    %edx,%eax
  801808:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80180a:	83 f8 0f             	cmp    $0xf,%eax
  80180d:	7f 23                	jg     801832 <vprintfmt+0x140>
  80180f:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  801816:	85 d2                	test   %edx,%edx
  801818:	74 18                	je     801832 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80181a:	52                   	push   %edx
  80181b:	68 21 24 80 00       	push   $0x802421
  801820:	53                   	push   %ebx
  801821:	56                   	push   %esi
  801822:	e8 aa fe ff ff       	call   8016d1 <printfmt>
  801827:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80182a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80182d:	e9 66 02 00 00       	jmp    801a98 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  801832:	50                   	push   %eax
  801833:	68 3b 25 80 00       	push   $0x80253b
  801838:	53                   	push   %ebx
  801839:	56                   	push   %esi
  80183a:	e8 92 fe ff ff       	call   8016d1 <printfmt>
  80183f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801842:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801845:	e9 4e 02 00 00       	jmp    801a98 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80184a:	8b 45 14             	mov    0x14(%ebp),%eax
  80184d:	83 c0 04             	add    $0x4,%eax
  801850:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801853:	8b 45 14             	mov    0x14(%ebp),%eax
  801856:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801858:	85 d2                	test   %edx,%edx
  80185a:	b8 34 25 80 00       	mov    $0x802534,%eax
  80185f:	0f 45 c2             	cmovne %edx,%eax
  801862:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801865:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801869:	7e 06                	jle    801871 <vprintfmt+0x17f>
  80186b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80186f:	75 0d                	jne    80187e <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801871:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801874:	89 c7                	mov    %eax,%edi
  801876:	03 45 e0             	add    -0x20(%ebp),%eax
  801879:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80187c:	eb 55                	jmp    8018d3 <vprintfmt+0x1e1>
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	ff 75 d8             	pushl  -0x28(%ebp)
  801884:	ff 75 cc             	pushl  -0x34(%ebp)
  801887:	e8 46 03 00 00       	call   801bd2 <strnlen>
  80188c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80188f:	29 c2                	sub    %eax,%edx
  801891:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801899:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80189d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a0:	85 ff                	test   %edi,%edi
  8018a2:	7e 11                	jle    8018b5 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	53                   	push   %ebx
  8018a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ab:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ad:	83 ef 01             	sub    $0x1,%edi
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	eb eb                	jmp    8018a0 <vprintfmt+0x1ae>
  8018b5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018b8:	85 d2                	test   %edx,%edx
  8018ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bf:	0f 49 c2             	cmovns %edx,%eax
  8018c2:	29 c2                	sub    %eax,%edx
  8018c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018c7:	eb a8                	jmp    801871 <vprintfmt+0x17f>
					putch(ch, putdat);
  8018c9:	83 ec 08             	sub    $0x8,%esp
  8018cc:	53                   	push   %ebx
  8018cd:	52                   	push   %edx
  8018ce:	ff d6                	call   *%esi
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018d6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d8:	83 c7 01             	add    $0x1,%edi
  8018db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018df:	0f be d0             	movsbl %al,%edx
  8018e2:	85 d2                	test   %edx,%edx
  8018e4:	74 4b                	je     801931 <vprintfmt+0x23f>
  8018e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ea:	78 06                	js     8018f2 <vprintfmt+0x200>
  8018ec:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018f0:	78 1e                	js     801910 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8018f2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018f6:	74 d1                	je     8018c9 <vprintfmt+0x1d7>
  8018f8:	0f be c0             	movsbl %al,%eax
  8018fb:	83 e8 20             	sub    $0x20,%eax
  8018fe:	83 f8 5e             	cmp    $0x5e,%eax
  801901:	76 c6                	jbe    8018c9 <vprintfmt+0x1d7>
					putch('?', putdat);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	53                   	push   %ebx
  801907:	6a 3f                	push   $0x3f
  801909:	ff d6                	call   *%esi
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	eb c3                	jmp    8018d3 <vprintfmt+0x1e1>
  801910:	89 cf                	mov    %ecx,%edi
  801912:	eb 0e                	jmp    801922 <vprintfmt+0x230>
				putch(' ', putdat);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	53                   	push   %ebx
  801918:	6a 20                	push   $0x20
  80191a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80191c:	83 ef 01             	sub    $0x1,%edi
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	85 ff                	test   %edi,%edi
  801924:	7f ee                	jg     801914 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801926:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801929:	89 45 14             	mov    %eax,0x14(%ebp)
  80192c:	e9 67 01 00 00       	jmp    801a98 <vprintfmt+0x3a6>
  801931:	89 cf                	mov    %ecx,%edi
  801933:	eb ed                	jmp    801922 <vprintfmt+0x230>
	if (lflag >= 2)
  801935:	83 f9 01             	cmp    $0x1,%ecx
  801938:	7f 1b                	jg     801955 <vprintfmt+0x263>
	else if (lflag)
  80193a:	85 c9                	test   %ecx,%ecx
  80193c:	74 63                	je     8019a1 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80193e:	8b 45 14             	mov    0x14(%ebp),%eax
  801941:	8b 00                	mov    (%eax),%eax
  801943:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801946:	99                   	cltd   
  801947:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80194a:	8b 45 14             	mov    0x14(%ebp),%eax
  80194d:	8d 40 04             	lea    0x4(%eax),%eax
  801950:	89 45 14             	mov    %eax,0x14(%ebp)
  801953:	eb 17                	jmp    80196c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801955:	8b 45 14             	mov    0x14(%ebp),%eax
  801958:	8b 50 04             	mov    0x4(%eax),%edx
  80195b:	8b 00                	mov    (%eax),%eax
  80195d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801960:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801963:	8b 45 14             	mov    0x14(%ebp),%eax
  801966:	8d 40 08             	lea    0x8(%eax),%eax
  801969:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80196c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80196f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801972:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801977:	85 c9                	test   %ecx,%ecx
  801979:	0f 89 ff 00 00 00    	jns    801a7e <vprintfmt+0x38c>
				putch('-', putdat);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	53                   	push   %ebx
  801983:	6a 2d                	push   $0x2d
  801985:	ff d6                	call   *%esi
				num = -(long long) num;
  801987:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80198a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80198d:	f7 da                	neg    %edx
  80198f:	83 d1 00             	adc    $0x0,%ecx
  801992:	f7 d9                	neg    %ecx
  801994:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801997:	b8 0a 00 00 00       	mov    $0xa,%eax
  80199c:	e9 dd 00 00 00       	jmp    801a7e <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8019a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a4:	8b 00                	mov    (%eax),%eax
  8019a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a9:	99                   	cltd   
  8019aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b0:	8d 40 04             	lea    0x4(%eax),%eax
  8019b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8019b6:	eb b4                	jmp    80196c <vprintfmt+0x27a>
	if (lflag >= 2)
  8019b8:	83 f9 01             	cmp    $0x1,%ecx
  8019bb:	7f 1e                	jg     8019db <vprintfmt+0x2e9>
	else if (lflag)
  8019bd:	85 c9                	test   %ecx,%ecx
  8019bf:	74 32                	je     8019f3 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c4:	8b 10                	mov    (%eax),%edx
  8019c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019cb:	8d 40 04             	lea    0x4(%eax),%eax
  8019ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019d1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019d6:	e9 a3 00 00 00       	jmp    801a7e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	8b 10                	mov    (%eax),%edx
  8019e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e3:	8d 40 08             	lea    0x8(%eax),%eax
  8019e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019e9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8019ee:	e9 8b 00 00 00       	jmp    801a7e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8019f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f6:	8b 10                	mov    (%eax),%edx
  8019f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fd:	8d 40 04             	lea    0x4(%eax),%eax
  801a00:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801a03:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801a08:	eb 74                	jmp    801a7e <vprintfmt+0x38c>
	if (lflag >= 2)
  801a0a:	83 f9 01             	cmp    $0x1,%ecx
  801a0d:	7f 1b                	jg     801a2a <vprintfmt+0x338>
	else if (lflag)
  801a0f:	85 c9                	test   %ecx,%ecx
  801a11:	74 2c                	je     801a3f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801a13:	8b 45 14             	mov    0x14(%ebp),%eax
  801a16:	8b 10                	mov    (%eax),%edx
  801a18:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a1d:	8d 40 04             	lea    0x4(%eax),%eax
  801a20:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a23:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a28:	eb 54                	jmp    801a7e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2d:	8b 10                	mov    (%eax),%edx
  801a2f:	8b 48 04             	mov    0x4(%eax),%ecx
  801a32:	8d 40 08             	lea    0x8(%eax),%eax
  801a35:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a38:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a3d:	eb 3f                	jmp    801a7e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a3f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a42:	8b 10                	mov    (%eax),%edx
  801a44:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a49:	8d 40 04             	lea    0x4(%eax),%eax
  801a4c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a4f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a54:	eb 28                	jmp    801a7e <vprintfmt+0x38c>
			putch('0', putdat);
  801a56:	83 ec 08             	sub    $0x8,%esp
  801a59:	53                   	push   %ebx
  801a5a:	6a 30                	push   $0x30
  801a5c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a5e:	83 c4 08             	add    $0x8,%esp
  801a61:	53                   	push   %ebx
  801a62:	6a 78                	push   $0x78
  801a64:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a66:	8b 45 14             	mov    0x14(%ebp),%eax
  801a69:	8b 10                	mov    (%eax),%edx
  801a6b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a70:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a73:	8d 40 04             	lea    0x4(%eax),%eax
  801a76:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a79:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a85:	57                   	push   %edi
  801a86:	ff 75 e0             	pushl  -0x20(%ebp)
  801a89:	50                   	push   %eax
  801a8a:	51                   	push   %ecx
  801a8b:	52                   	push   %edx
  801a8c:	89 da                	mov    %ebx,%edx
  801a8e:	89 f0                	mov    %esi,%eax
  801a90:	e8 72 fb ff ff       	call   801607 <printnum>
			break;
  801a95:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801a98:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801a9b:	83 c7 01             	add    $0x1,%edi
  801a9e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801aa2:	83 f8 25             	cmp    $0x25,%eax
  801aa5:	0f 84 62 fc ff ff    	je     80170d <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801aab:	85 c0                	test   %eax,%eax
  801aad:	0f 84 8b 00 00 00    	je     801b3e <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	53                   	push   %ebx
  801ab7:	50                   	push   %eax
  801ab8:	ff d6                	call   *%esi
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	eb dc                	jmp    801a9b <vprintfmt+0x3a9>
	if (lflag >= 2)
  801abf:	83 f9 01             	cmp    $0x1,%ecx
  801ac2:	7f 1b                	jg     801adf <vprintfmt+0x3ed>
	else if (lflag)
  801ac4:	85 c9                	test   %ecx,%ecx
  801ac6:	74 2c                	je     801af4 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801ac8:	8b 45 14             	mov    0x14(%ebp),%eax
  801acb:	8b 10                	mov    (%eax),%edx
  801acd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ad2:	8d 40 04             	lea    0x4(%eax),%eax
  801ad5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ad8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801add:	eb 9f                	jmp    801a7e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801adf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae2:	8b 10                	mov    (%eax),%edx
  801ae4:	8b 48 04             	mov    0x4(%eax),%ecx
  801ae7:	8d 40 08             	lea    0x8(%eax),%eax
  801aea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aed:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801af2:	eb 8a                	jmp    801a7e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801af4:	8b 45 14             	mov    0x14(%ebp),%eax
  801af7:	8b 10                	mov    (%eax),%edx
  801af9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801afe:	8d 40 04             	lea    0x4(%eax),%eax
  801b01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b04:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801b09:	e9 70 ff ff ff       	jmp    801a7e <vprintfmt+0x38c>
			putch(ch, putdat);
  801b0e:	83 ec 08             	sub    $0x8,%esp
  801b11:	53                   	push   %ebx
  801b12:	6a 25                	push   $0x25
  801b14:	ff d6                	call   *%esi
			break;
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	e9 7a ff ff ff       	jmp    801a98 <vprintfmt+0x3a6>
			putch('%', putdat);
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	53                   	push   %ebx
  801b22:	6a 25                	push   $0x25
  801b24:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	89 f8                	mov    %edi,%eax
  801b2b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b2f:	74 05                	je     801b36 <vprintfmt+0x444>
  801b31:	83 e8 01             	sub    $0x1,%eax
  801b34:	eb f5                	jmp    801b2b <vprintfmt+0x439>
  801b36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b39:	e9 5a ff ff ff       	jmp    801a98 <vprintfmt+0x3a6>
}
  801b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	5f                   	pop    %edi
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b46:	f3 0f 1e fb          	endbr32 
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 18             	sub    $0x18,%esp
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b59:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b5d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b67:	85 c0                	test   %eax,%eax
  801b69:	74 26                	je     801b91 <vsnprintf+0x4b>
  801b6b:	85 d2                	test   %edx,%edx
  801b6d:	7e 22                	jle    801b91 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b6f:	ff 75 14             	pushl  0x14(%ebp)
  801b72:	ff 75 10             	pushl  0x10(%ebp)
  801b75:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	68 b0 16 80 00       	push   $0x8016b0
  801b7e:	e8 6f fb ff ff       	call   8016f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b86:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8c:	83 c4 10             	add    $0x10,%esp
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    
		return -E_INVAL;
  801b91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b96:	eb f7                	jmp    801b8f <vsnprintf+0x49>

00801b98 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b98:	f3 0f 1e fb          	endbr32 
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801ba2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ba5:	50                   	push   %eax
  801ba6:	ff 75 10             	pushl  0x10(%ebp)
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	ff 75 08             	pushl  0x8(%ebp)
  801baf:	e8 92 ff ff ff       	call   801b46 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bb6:	f3 0f 1e fb          	endbr32 
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bc9:	74 05                	je     801bd0 <strlen+0x1a>
		n++;
  801bcb:	83 c0 01             	add    $0x1,%eax
  801bce:	eb f5                	jmp    801bc5 <strlen+0xf>
	return n;
}
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bd2:	f3 0f 1e fb          	endbr32 
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801be4:	39 d0                	cmp    %edx,%eax
  801be6:	74 0d                	je     801bf5 <strnlen+0x23>
  801be8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801bec:	74 05                	je     801bf3 <strnlen+0x21>
		n++;
  801bee:	83 c0 01             	add    $0x1,%eax
  801bf1:	eb f1                	jmp    801be4 <strnlen+0x12>
  801bf3:	89 c2                	mov    %eax,%edx
	return n;
}
  801bf5:	89 d0                	mov    %edx,%eax
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bf9:	f3 0f 1e fb          	endbr32 
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	53                   	push   %ebx
  801c01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801c10:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801c13:	83 c0 01             	add    $0x1,%eax
  801c16:	84 d2                	test   %dl,%dl
  801c18:	75 f2                	jne    801c0c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c1a:	89 c8                	mov    %ecx,%eax
  801c1c:	5b                   	pop    %ebx
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c1f:	f3 0f 1e fb          	endbr32 
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 10             	sub    $0x10,%esp
  801c2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c2d:	53                   	push   %ebx
  801c2e:	e8 83 ff ff ff       	call   801bb6 <strlen>
  801c33:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c36:	ff 75 0c             	pushl  0xc(%ebp)
  801c39:	01 d8                	add    %ebx,%eax
  801c3b:	50                   	push   %eax
  801c3c:	e8 b8 ff ff ff       	call   801bf9 <strcpy>
	return dst;
}
  801c41:	89 d8                	mov    %ebx,%eax
  801c43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c48:	f3 0f 1e fb          	endbr32 
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	8b 75 08             	mov    0x8(%ebp),%esi
  801c54:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c57:	89 f3                	mov    %esi,%ebx
  801c59:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c5c:	89 f0                	mov    %esi,%eax
  801c5e:	39 d8                	cmp    %ebx,%eax
  801c60:	74 11                	je     801c73 <strncpy+0x2b>
		*dst++ = *src;
  801c62:	83 c0 01             	add    $0x1,%eax
  801c65:	0f b6 0a             	movzbl (%edx),%ecx
  801c68:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c6b:	80 f9 01             	cmp    $0x1,%cl
  801c6e:	83 da ff             	sbb    $0xffffffff,%edx
  801c71:	eb eb                	jmp    801c5e <strncpy+0x16>
	}
	return ret;
}
  801c73:	89 f0                	mov    %esi,%eax
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c79:	f3 0f 1e fb          	endbr32 
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	56                   	push   %esi
  801c81:	53                   	push   %ebx
  801c82:	8b 75 08             	mov    0x8(%ebp),%esi
  801c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c88:	8b 55 10             	mov    0x10(%ebp),%edx
  801c8b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c8d:	85 d2                	test   %edx,%edx
  801c8f:	74 21                	je     801cb2 <strlcpy+0x39>
  801c91:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c95:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801c97:	39 c2                	cmp    %eax,%edx
  801c99:	74 14                	je     801caf <strlcpy+0x36>
  801c9b:	0f b6 19             	movzbl (%ecx),%ebx
  801c9e:	84 db                	test   %bl,%bl
  801ca0:	74 0b                	je     801cad <strlcpy+0x34>
			*dst++ = *src++;
  801ca2:	83 c1 01             	add    $0x1,%ecx
  801ca5:	83 c2 01             	add    $0x1,%edx
  801ca8:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cab:	eb ea                	jmp    801c97 <strlcpy+0x1e>
  801cad:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801caf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cb2:	29 f0                	sub    %esi,%eax
}
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    

00801cb8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cb8:	f3 0f 1e fb          	endbr32 
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cc5:	0f b6 01             	movzbl (%ecx),%eax
  801cc8:	84 c0                	test   %al,%al
  801cca:	74 0c                	je     801cd8 <strcmp+0x20>
  801ccc:	3a 02                	cmp    (%edx),%al
  801cce:	75 08                	jne    801cd8 <strcmp+0x20>
		p++, q++;
  801cd0:	83 c1 01             	add    $0x1,%ecx
  801cd3:	83 c2 01             	add    $0x1,%edx
  801cd6:	eb ed                	jmp    801cc5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd8:	0f b6 c0             	movzbl %al,%eax
  801cdb:	0f b6 12             	movzbl (%edx),%edx
  801cde:	29 d0                	sub    %edx,%eax
}
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ce2:	f3 0f 1e fb          	endbr32 
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	53                   	push   %ebx
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf0:	89 c3                	mov    %eax,%ebx
  801cf2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cf5:	eb 06                	jmp    801cfd <strncmp+0x1b>
		n--, p++, q++;
  801cf7:	83 c0 01             	add    $0x1,%eax
  801cfa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801cfd:	39 d8                	cmp    %ebx,%eax
  801cff:	74 16                	je     801d17 <strncmp+0x35>
  801d01:	0f b6 08             	movzbl (%eax),%ecx
  801d04:	84 c9                	test   %cl,%cl
  801d06:	74 04                	je     801d0c <strncmp+0x2a>
  801d08:	3a 0a                	cmp    (%edx),%cl
  801d0a:	74 eb                	je     801cf7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d0c:	0f b6 00             	movzbl (%eax),%eax
  801d0f:	0f b6 12             	movzbl (%edx),%edx
  801d12:	29 d0                	sub    %edx,%eax
}
  801d14:	5b                   	pop    %ebx
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    
		return 0;
  801d17:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1c:	eb f6                	jmp    801d14 <strncmp+0x32>

00801d1e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d1e:	f3 0f 1e fb          	endbr32 
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	8b 45 08             	mov    0x8(%ebp),%eax
  801d28:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d2c:	0f b6 10             	movzbl (%eax),%edx
  801d2f:	84 d2                	test   %dl,%dl
  801d31:	74 09                	je     801d3c <strchr+0x1e>
		if (*s == c)
  801d33:	38 ca                	cmp    %cl,%dl
  801d35:	74 0a                	je     801d41 <strchr+0x23>
	for (; *s; s++)
  801d37:	83 c0 01             	add    $0x1,%eax
  801d3a:	eb f0                	jmp    801d2c <strchr+0xe>
			return (char *) s;
	return 0;
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d43:	f3 0f 1e fb          	endbr32 
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d4d:	6a 78                	push   $0x78
  801d4f:	ff 75 08             	pushl  0x8(%ebp)
  801d52:	e8 c7 ff ff ff       	call   801d1e <strchr>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d5d:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d62:	eb 0d                	jmp    801d71 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d64:	c1 e0 04             	shl    $0x4,%eax
  801d67:	0f be d2             	movsbl %dl,%edx
  801d6a:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d6e:	83 c1 01             	add    $0x1,%ecx
  801d71:	0f b6 11             	movzbl (%ecx),%edx
  801d74:	84 d2                	test   %dl,%dl
  801d76:	74 11                	je     801d89 <atox+0x46>
		if (*p>='a'){
  801d78:	80 fa 60             	cmp    $0x60,%dl
  801d7b:	7e e7                	jle    801d64 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d7d:	c1 e0 04             	shl    $0x4,%eax
  801d80:	0f be d2             	movsbl %dl,%edx
  801d83:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d87:	eb e5                	jmp    801d6e <atox+0x2b>
	}

	return v;

}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    

00801d8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d8b:	f3 0f 1e fb          	endbr32 
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d99:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d9c:	38 ca                	cmp    %cl,%dl
  801d9e:	74 09                	je     801da9 <strfind+0x1e>
  801da0:	84 d2                	test   %dl,%dl
  801da2:	74 05                	je     801da9 <strfind+0x1e>
	for (; *s; s++)
  801da4:	83 c0 01             	add    $0x1,%eax
  801da7:	eb f0                	jmp    801d99 <strfind+0xe>
			break;
	return (char *) s;
}
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801dab:	f3 0f 1e fb          	endbr32 
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	57                   	push   %edi
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801db8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801dbb:	85 c9                	test   %ecx,%ecx
  801dbd:	74 31                	je     801df0 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801dbf:	89 f8                	mov    %edi,%eax
  801dc1:	09 c8                	or     %ecx,%eax
  801dc3:	a8 03                	test   $0x3,%al
  801dc5:	75 23                	jne    801dea <memset+0x3f>
		c &= 0xFF;
  801dc7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801dcb:	89 d3                	mov    %edx,%ebx
  801dcd:	c1 e3 08             	shl    $0x8,%ebx
  801dd0:	89 d0                	mov    %edx,%eax
  801dd2:	c1 e0 18             	shl    $0x18,%eax
  801dd5:	89 d6                	mov    %edx,%esi
  801dd7:	c1 e6 10             	shl    $0x10,%esi
  801dda:	09 f0                	or     %esi,%eax
  801ddc:	09 c2                	or     %eax,%edx
  801dde:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801de0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801de3:	89 d0                	mov    %edx,%eax
  801de5:	fc                   	cld    
  801de6:	f3 ab                	rep stos %eax,%es:(%edi)
  801de8:	eb 06                	jmp    801df0 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dea:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ded:	fc                   	cld    
  801dee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801df0:	89 f8                	mov    %edi,%eax
  801df2:	5b                   	pop    %ebx
  801df3:	5e                   	pop    %esi
  801df4:	5f                   	pop    %edi
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801df7:	f3 0f 1e fb          	endbr32 
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	57                   	push   %edi
  801dff:	56                   	push   %esi
  801e00:	8b 45 08             	mov    0x8(%ebp),%eax
  801e03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e09:	39 c6                	cmp    %eax,%esi
  801e0b:	73 32                	jae    801e3f <memmove+0x48>
  801e0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e10:	39 c2                	cmp    %eax,%edx
  801e12:	76 2b                	jbe    801e3f <memmove+0x48>
		s += n;
		d += n;
  801e14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e17:	89 fe                	mov    %edi,%esi
  801e19:	09 ce                	or     %ecx,%esi
  801e1b:	09 d6                	or     %edx,%esi
  801e1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e23:	75 0e                	jne    801e33 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e25:	83 ef 04             	sub    $0x4,%edi
  801e28:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e2e:	fd                   	std    
  801e2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e31:	eb 09                	jmp    801e3c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e33:	83 ef 01             	sub    $0x1,%edi
  801e36:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e39:	fd                   	std    
  801e3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e3c:	fc                   	cld    
  801e3d:	eb 1a                	jmp    801e59 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e3f:	89 c2                	mov    %eax,%edx
  801e41:	09 ca                	or     %ecx,%edx
  801e43:	09 f2                	or     %esi,%edx
  801e45:	f6 c2 03             	test   $0x3,%dl
  801e48:	75 0a                	jne    801e54 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e4a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e4d:	89 c7                	mov    %eax,%edi
  801e4f:	fc                   	cld    
  801e50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e52:	eb 05                	jmp    801e59 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e54:	89 c7                	mov    %eax,%edi
  801e56:	fc                   	cld    
  801e57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    

00801e5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e5d:	f3 0f 1e fb          	endbr32 
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e67:	ff 75 10             	pushl  0x10(%ebp)
  801e6a:	ff 75 0c             	pushl  0xc(%ebp)
  801e6d:	ff 75 08             	pushl  0x8(%ebp)
  801e70:	e8 82 ff ff ff       	call   801df7 <memmove>
}
  801e75:	c9                   	leave  
  801e76:	c3                   	ret    

00801e77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e77:	f3 0f 1e fb          	endbr32 
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	56                   	push   %esi
  801e7f:	53                   	push   %ebx
  801e80:	8b 45 08             	mov    0x8(%ebp),%eax
  801e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e86:	89 c6                	mov    %eax,%esi
  801e88:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e8b:	39 f0                	cmp    %esi,%eax
  801e8d:	74 1c                	je     801eab <memcmp+0x34>
		if (*s1 != *s2)
  801e8f:	0f b6 08             	movzbl (%eax),%ecx
  801e92:	0f b6 1a             	movzbl (%edx),%ebx
  801e95:	38 d9                	cmp    %bl,%cl
  801e97:	75 08                	jne    801ea1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801e99:	83 c0 01             	add    $0x1,%eax
  801e9c:	83 c2 01             	add    $0x1,%edx
  801e9f:	eb ea                	jmp    801e8b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801ea1:	0f b6 c1             	movzbl %cl,%eax
  801ea4:	0f b6 db             	movzbl %bl,%ebx
  801ea7:	29 d8                	sub    %ebx,%eax
  801ea9:	eb 05                	jmp    801eb0 <memcmp+0x39>
	}

	return 0;
  801eab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb0:	5b                   	pop    %ebx
  801eb1:	5e                   	pop    %esi
  801eb2:	5d                   	pop    %ebp
  801eb3:	c3                   	ret    

00801eb4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801eb4:	f3 0f 1e fb          	endbr32 
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ec1:	89 c2                	mov    %eax,%edx
  801ec3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ec6:	39 d0                	cmp    %edx,%eax
  801ec8:	73 09                	jae    801ed3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801eca:	38 08                	cmp    %cl,(%eax)
  801ecc:	74 05                	je     801ed3 <memfind+0x1f>
	for (; s < ends; s++)
  801ece:	83 c0 01             	add    $0x1,%eax
  801ed1:	eb f3                	jmp    801ec6 <memfind+0x12>
			break;
	return (void *) s;
}
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ed5:	f3 0f 1e fb          	endbr32 
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	57                   	push   %edi
  801edd:	56                   	push   %esi
  801ede:	53                   	push   %ebx
  801edf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ee5:	eb 03                	jmp    801eea <strtol+0x15>
		s++;
  801ee7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801eea:	0f b6 01             	movzbl (%ecx),%eax
  801eed:	3c 20                	cmp    $0x20,%al
  801eef:	74 f6                	je     801ee7 <strtol+0x12>
  801ef1:	3c 09                	cmp    $0x9,%al
  801ef3:	74 f2                	je     801ee7 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801ef5:	3c 2b                	cmp    $0x2b,%al
  801ef7:	74 2a                	je     801f23 <strtol+0x4e>
	int neg = 0;
  801ef9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801efe:	3c 2d                	cmp    $0x2d,%al
  801f00:	74 2b                	je     801f2d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f08:	75 0f                	jne    801f19 <strtol+0x44>
  801f0a:	80 39 30             	cmpb   $0x30,(%ecx)
  801f0d:	74 28                	je     801f37 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f0f:	85 db                	test   %ebx,%ebx
  801f11:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f16:	0f 44 d8             	cmove  %eax,%ebx
  801f19:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f21:	eb 46                	jmp    801f69 <strtol+0x94>
		s++;
  801f23:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f26:	bf 00 00 00 00       	mov    $0x0,%edi
  801f2b:	eb d5                	jmp    801f02 <strtol+0x2d>
		s++, neg = 1;
  801f2d:	83 c1 01             	add    $0x1,%ecx
  801f30:	bf 01 00 00 00       	mov    $0x1,%edi
  801f35:	eb cb                	jmp    801f02 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f3b:	74 0e                	je     801f4b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f3d:	85 db                	test   %ebx,%ebx
  801f3f:	75 d8                	jne    801f19 <strtol+0x44>
		s++, base = 8;
  801f41:	83 c1 01             	add    $0x1,%ecx
  801f44:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f49:	eb ce                	jmp    801f19 <strtol+0x44>
		s += 2, base = 16;
  801f4b:	83 c1 02             	add    $0x2,%ecx
  801f4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f53:	eb c4                	jmp    801f19 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f55:	0f be d2             	movsbl %dl,%edx
  801f58:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f5e:	7d 3a                	jge    801f9a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f60:	83 c1 01             	add    $0x1,%ecx
  801f63:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f67:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f69:	0f b6 11             	movzbl (%ecx),%edx
  801f6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f6f:	89 f3                	mov    %esi,%ebx
  801f71:	80 fb 09             	cmp    $0x9,%bl
  801f74:	76 df                	jbe    801f55 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f76:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f79:	89 f3                	mov    %esi,%ebx
  801f7b:	80 fb 19             	cmp    $0x19,%bl
  801f7e:	77 08                	ja     801f88 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f80:	0f be d2             	movsbl %dl,%edx
  801f83:	83 ea 57             	sub    $0x57,%edx
  801f86:	eb d3                	jmp    801f5b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f88:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f8b:	89 f3                	mov    %esi,%ebx
  801f8d:	80 fb 19             	cmp    $0x19,%bl
  801f90:	77 08                	ja     801f9a <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f92:	0f be d2             	movsbl %dl,%edx
  801f95:	83 ea 37             	sub    $0x37,%edx
  801f98:	eb c1                	jmp    801f5b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801f9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f9e:	74 05                	je     801fa5 <strtol+0xd0>
		*endptr = (char *) s;
  801fa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801fa5:	89 c2                	mov    %eax,%edx
  801fa7:	f7 da                	neg    %edx
  801fa9:	85 ff                	test   %edi,%edi
  801fab:	0f 45 c2             	cmovne %edx,%eax
}
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb3:	f3 0f 1e fb          	endbr32 
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	56                   	push   %esi
  801fbb:	53                   	push   %ebx
  801fbc:	8b 75 08             	mov    0x8(%ebp),%esi
  801fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fcc:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	50                   	push   %eax
  801fd3:	e8 97 e2 ff ff       	call   80026f <sys_ipc_recv>
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	75 2b                	jne    80200a <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fdf:	85 f6                	test   %esi,%esi
  801fe1:	74 0a                	je     801fed <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fe3:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe8:	8b 40 74             	mov    0x74(%eax),%eax
  801feb:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fed:	85 db                	test   %ebx,%ebx
  801fef:	74 0a                	je     801ffb <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801ff1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff6:	8b 40 78             	mov    0x78(%eax),%eax
  801ff9:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801ffb:	a1 08 40 80 00       	mov    0x804008,%eax
  802000:	8b 40 70             	mov    0x70(%eax),%eax
}
  802003:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80200a:	85 f6                	test   %esi,%esi
  80200c:	74 06                	je     802014 <ipc_recv+0x61>
  80200e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802014:	85 db                	test   %ebx,%ebx
  802016:	74 eb                	je     802003 <ipc_recv+0x50>
  802018:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80201e:	eb e3                	jmp    802003 <ipc_recv+0x50>

00802020 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802020:	f3 0f 1e fb          	endbr32 
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	57                   	push   %edi
  802028:	56                   	push   %esi
  802029:	53                   	push   %ebx
  80202a:	83 ec 0c             	sub    $0xc,%esp
  80202d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802030:	8b 75 0c             	mov    0xc(%ebp),%esi
  802033:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802036:	85 db                	test   %ebx,%ebx
  802038:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80203d:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802040:	ff 75 14             	pushl  0x14(%ebp)
  802043:	53                   	push   %ebx
  802044:	56                   	push   %esi
  802045:	57                   	push   %edi
  802046:	e8 fd e1 ff ff       	call   800248 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802051:	75 07                	jne    80205a <ipc_send+0x3a>
			sys_yield();
  802053:	e8 ee e0 ff ff       	call   800146 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802058:	eb e6                	jmp    802040 <ipc_send+0x20>
		}
		else if (ret == 0)
  80205a:	85 c0                	test   %eax,%eax
  80205c:	75 08                	jne    802066 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80205e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802066:	50                   	push   %eax
  802067:	68 1f 28 80 00       	push   $0x80281f
  80206c:	6a 48                	push   $0x48
  80206e:	68 2d 28 80 00       	push   $0x80282d
  802073:	e8 90 f4 ff ff       	call   801508 <_panic>

00802078 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802078:	f3 0f 1e fb          	endbr32 
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802087:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80208a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802090:	8b 52 50             	mov    0x50(%edx),%edx
  802093:	39 ca                	cmp    %ecx,%edx
  802095:	74 11                	je     8020a8 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802097:	83 c0 01             	add    $0x1,%eax
  80209a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209f:	75 e6                	jne    802087 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a6:	eb 0b                	jmp    8020b3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    

008020b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b5:	f3 0f 1e fb          	endbr32 
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020bf:	89 c2                	mov    %eax,%edx
  8020c1:	c1 ea 16             	shr    $0x16,%edx
  8020c4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020cb:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020d0:	f6 c1 01             	test   $0x1,%cl
  8020d3:	74 1c                	je     8020f1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020d5:	c1 e8 0c             	shr    $0xc,%eax
  8020d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020df:	a8 01                	test   $0x1,%al
  8020e1:	74 0e                	je     8020f1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020e3:	c1 e8 0c             	shr    $0xc,%eax
  8020e6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020ed:	ef 
  8020ee:	0f b7 d2             	movzwl %dx,%edx
}
  8020f1:	89 d0                	mov    %edx,%eax
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	66 90                	xchg   %ax,%ax
  8020f7:	66 90                	xchg   %ax,%ax
  8020f9:	66 90                	xchg   %ax,%ax
  8020fb:	66 90                	xchg   %ax,%ax
  8020fd:	66 90                	xchg   %ax,%ax
  8020ff:	90                   	nop

00802100 <__udivdi3>:
  802100:	f3 0f 1e fb          	endbr32 
  802104:	55                   	push   %ebp
  802105:	57                   	push   %edi
  802106:	56                   	push   %esi
  802107:	53                   	push   %ebx
  802108:	83 ec 1c             	sub    $0x1c,%esp
  80210b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802113:	8b 74 24 34          	mov    0x34(%esp),%esi
  802117:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80211b:	85 d2                	test   %edx,%edx
  80211d:	75 19                	jne    802138 <__udivdi3+0x38>
  80211f:	39 f3                	cmp    %esi,%ebx
  802121:	76 4d                	jbe    802170 <__udivdi3+0x70>
  802123:	31 ff                	xor    %edi,%edi
  802125:	89 e8                	mov    %ebp,%eax
  802127:	89 f2                	mov    %esi,%edx
  802129:	f7 f3                	div    %ebx
  80212b:	89 fa                	mov    %edi,%edx
  80212d:	83 c4 1c             	add    $0x1c,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	76 14                	jbe    802150 <__udivdi3+0x50>
  80213c:	31 ff                	xor    %edi,%edi
  80213e:	31 c0                	xor    %eax,%eax
  802140:	89 fa                	mov    %edi,%edx
  802142:	83 c4 1c             	add    $0x1c,%esp
  802145:	5b                   	pop    %ebx
  802146:	5e                   	pop    %esi
  802147:	5f                   	pop    %edi
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    
  80214a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802150:	0f bd fa             	bsr    %edx,%edi
  802153:	83 f7 1f             	xor    $0x1f,%edi
  802156:	75 48                	jne    8021a0 <__udivdi3+0xa0>
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	72 06                	jb     802162 <__udivdi3+0x62>
  80215c:	31 c0                	xor    %eax,%eax
  80215e:	39 eb                	cmp    %ebp,%ebx
  802160:	77 de                	ja     802140 <__udivdi3+0x40>
  802162:	b8 01 00 00 00       	mov    $0x1,%eax
  802167:	eb d7                	jmp    802140 <__udivdi3+0x40>
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d9                	mov    %ebx,%ecx
  802172:	85 db                	test   %ebx,%ebx
  802174:	75 0b                	jne    802181 <__udivdi3+0x81>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f3                	div    %ebx
  80217f:	89 c1                	mov    %eax,%ecx
  802181:	31 d2                	xor    %edx,%edx
  802183:	89 f0                	mov    %esi,%eax
  802185:	f7 f1                	div    %ecx
  802187:	89 c6                	mov    %eax,%esi
  802189:	89 e8                	mov    %ebp,%eax
  80218b:	89 f7                	mov    %esi,%edi
  80218d:	f7 f1                	div    %ecx
  80218f:	89 fa                	mov    %edi,%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 f9                	mov    %edi,%ecx
  8021a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021a7:	29 f8                	sub    %edi,%eax
  8021a9:	d3 e2                	shl    %cl,%edx
  8021ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021af:	89 c1                	mov    %eax,%ecx
  8021b1:	89 da                	mov    %ebx,%edx
  8021b3:	d3 ea                	shr    %cl,%edx
  8021b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021b9:	09 d1                	or     %edx,%ecx
  8021bb:	89 f2                	mov    %esi,%edx
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	d3 e3                	shl    %cl,%ebx
  8021c5:	89 c1                	mov    %eax,%ecx
  8021c7:	d3 ea                	shr    %cl,%edx
  8021c9:	89 f9                	mov    %edi,%ecx
  8021cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021cf:	89 eb                	mov    %ebp,%ebx
  8021d1:	d3 e6                	shl    %cl,%esi
  8021d3:	89 c1                	mov    %eax,%ecx
  8021d5:	d3 eb                	shr    %cl,%ebx
  8021d7:	09 de                	or     %ebx,%esi
  8021d9:	89 f0                	mov    %esi,%eax
  8021db:	f7 74 24 08          	divl   0x8(%esp)
  8021df:	89 d6                	mov    %edx,%esi
  8021e1:	89 c3                	mov    %eax,%ebx
  8021e3:	f7 64 24 0c          	mull   0xc(%esp)
  8021e7:	39 d6                	cmp    %edx,%esi
  8021e9:	72 15                	jb     802200 <__udivdi3+0x100>
  8021eb:	89 f9                	mov    %edi,%ecx
  8021ed:	d3 e5                	shl    %cl,%ebp
  8021ef:	39 c5                	cmp    %eax,%ebp
  8021f1:	73 04                	jae    8021f7 <__udivdi3+0xf7>
  8021f3:	39 d6                	cmp    %edx,%esi
  8021f5:	74 09                	je     802200 <__udivdi3+0x100>
  8021f7:	89 d8                	mov    %ebx,%eax
  8021f9:	31 ff                	xor    %edi,%edi
  8021fb:	e9 40 ff ff ff       	jmp    802140 <__udivdi3+0x40>
  802200:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802203:	31 ff                	xor    %edi,%edi
  802205:	e9 36 ff ff ff       	jmp    802140 <__udivdi3+0x40>
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	f3 0f 1e fb          	endbr32 
  802214:	55                   	push   %ebp
  802215:	57                   	push   %edi
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	83 ec 1c             	sub    $0x1c,%esp
  80221b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80221f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802223:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802227:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80222b:	85 c0                	test   %eax,%eax
  80222d:	75 19                	jne    802248 <__umoddi3+0x38>
  80222f:	39 df                	cmp    %ebx,%edi
  802231:	76 5d                	jbe    802290 <__umoddi3+0x80>
  802233:	89 f0                	mov    %esi,%eax
  802235:	89 da                	mov    %ebx,%edx
  802237:	f7 f7                	div    %edi
  802239:	89 d0                	mov    %edx,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	83 c4 1c             	add    $0x1c,%esp
  802240:	5b                   	pop    %ebx
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    
  802245:	8d 76 00             	lea    0x0(%esi),%esi
  802248:	89 f2                	mov    %esi,%edx
  80224a:	39 d8                	cmp    %ebx,%eax
  80224c:	76 12                	jbe    802260 <__umoddi3+0x50>
  80224e:	89 f0                	mov    %esi,%eax
  802250:	89 da                	mov    %ebx,%edx
  802252:	83 c4 1c             	add    $0x1c,%esp
  802255:	5b                   	pop    %ebx
  802256:	5e                   	pop    %esi
  802257:	5f                   	pop    %edi
  802258:	5d                   	pop    %ebp
  802259:	c3                   	ret    
  80225a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802260:	0f bd e8             	bsr    %eax,%ebp
  802263:	83 f5 1f             	xor    $0x1f,%ebp
  802266:	75 50                	jne    8022b8 <__umoddi3+0xa8>
  802268:	39 d8                	cmp    %ebx,%eax
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	89 d9                	mov    %ebx,%ecx
  802272:	39 f7                	cmp    %esi,%edi
  802274:	0f 86 d6 00 00 00    	jbe    802350 <__umoddi3+0x140>
  80227a:	89 d0                	mov    %edx,%eax
  80227c:	89 ca                	mov    %ecx,%edx
  80227e:	83 c4 1c             	add    $0x1c,%esp
  802281:	5b                   	pop    %ebx
  802282:	5e                   	pop    %esi
  802283:	5f                   	pop    %edi
  802284:	5d                   	pop    %ebp
  802285:	c3                   	ret    
  802286:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80228d:	8d 76 00             	lea    0x0(%esi),%esi
  802290:	89 fd                	mov    %edi,%ebp
  802292:	85 ff                	test   %edi,%edi
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 d8                	mov    %ebx,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 f0                	mov    %esi,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	31 d2                	xor    %edx,%edx
  8022af:	eb 8c                	jmp    80223d <__umoddi3+0x2d>
  8022b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8022bf:	29 ea                	sub    %ebp,%edx
  8022c1:	d3 e0                	shl    %cl,%eax
  8022c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 f8                	mov    %edi,%eax
  8022cb:	d3 e8                	shr    %cl,%eax
  8022cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022d9:	09 c1                	or     %eax,%ecx
  8022db:	89 d8                	mov    %ebx,%eax
  8022dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022e1:	89 e9                	mov    %ebp,%ecx
  8022e3:	d3 e7                	shl    %cl,%edi
  8022e5:	89 d1                	mov    %edx,%ecx
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022ef:	d3 e3                	shl    %cl,%ebx
  8022f1:	89 c7                	mov    %eax,%edi
  8022f3:	89 d1                	mov    %edx,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	89 fa                	mov    %edi,%edx
  8022fd:	d3 e6                	shl    %cl,%esi
  8022ff:	09 d8                	or     %ebx,%eax
  802301:	f7 74 24 08          	divl   0x8(%esp)
  802305:	89 d1                	mov    %edx,%ecx
  802307:	89 f3                	mov    %esi,%ebx
  802309:	f7 64 24 0c          	mull   0xc(%esp)
  80230d:	89 c6                	mov    %eax,%esi
  80230f:	89 d7                	mov    %edx,%edi
  802311:	39 d1                	cmp    %edx,%ecx
  802313:	72 06                	jb     80231b <__umoddi3+0x10b>
  802315:	75 10                	jne    802327 <__umoddi3+0x117>
  802317:	39 c3                	cmp    %eax,%ebx
  802319:	73 0c                	jae    802327 <__umoddi3+0x117>
  80231b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80231f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802323:	89 d7                	mov    %edx,%edi
  802325:	89 c6                	mov    %eax,%esi
  802327:	89 ca                	mov    %ecx,%edx
  802329:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80232e:	29 f3                	sub    %esi,%ebx
  802330:	19 fa                	sbb    %edi,%edx
  802332:	89 d0                	mov    %edx,%eax
  802334:	d3 e0                	shl    %cl,%eax
  802336:	89 e9                	mov    %ebp,%ecx
  802338:	d3 eb                	shr    %cl,%ebx
  80233a:	d3 ea                	shr    %cl,%edx
  80233c:	09 d8                	or     %ebx,%eax
  80233e:	83 c4 1c             	add    $0x1c,%esp
  802341:	5b                   	pop    %ebx
  802342:	5e                   	pop    %esi
  802343:	5f                   	pop    %edi
  802344:	5d                   	pop    %ebp
  802345:	c3                   	ret    
  802346:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 fe                	sub    %edi,%esi
  802352:	19 c3                	sbb    %eax,%ebx
  802354:	89 f2                	mov    %esi,%edx
  802356:	89 d9                	mov    %ebx,%ecx
  802358:	e9 1d ff ff ff       	jmp    80227a <__umoddi3+0x6a>
