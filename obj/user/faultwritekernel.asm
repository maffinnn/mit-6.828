
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800051:	e8 bd 00 00 00       	call   800113 <sys_getenvid>
  800056:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800063:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x31>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 0a 00 00 00       	call   80008c <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	f3 0f 1e fb          	endbr32 
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800096:	e8 49 04 00 00       	call   8004e4 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 4a 00 00 00       	call   8000ef <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	f3 0f 1e fb          	endbr32 
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	f3 0f 1e fb          	endbr32 
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	57                   	push   %edi
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000db:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e0:	89 d1                	mov    %edx,%ecx
  8000e2:	89 d3                	mov    %edx,%ebx
  8000e4:	89 d7                	mov    %edx,%edi
  8000e6:	89 d6                	mov    %edx,%esi
  8000e8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5f                   	pop    %edi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800113:	f3 0f 1e fb          	endbr32 
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	f3 0f 1e fb          	endbr32 
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016e:	b8 04 00 00 00       	mov    $0x4,%eax
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017a:	5b                   	pop    %ebx
  80017b:	5e                   	pop    %esi
  80017c:	5f                   	pop    %edi
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80017f:	f3 0f 1e fb          	endbr32 
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
	asm volatile("int %1\n"
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	b8 05 00 00 00       	mov    $0x5,%eax
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 7d 14             	mov    0x14(%ebp),%edi
  80019a:	8b 75 18             	mov    0x18(%ebp),%esi
  80019d:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5f                   	pop    %edi
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001a4:	f3 0f 1e fb          	endbr32 
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001be:	89 df                	mov    %ebx,%edi
  8001c0:	89 de                	mov    %ebx,%esi
  8001c2:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001c9:	f3 0f 1e fb          	endbr32 
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001de:	b8 08 00 00 00       	mov    $0x8,%eax
  8001e3:	89 df                	mov    %ebx,%edi
  8001e5:	89 de                	mov    %ebx,%esi
  8001e7:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5f                   	pop    %edi
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001ee:	f3 0f 1e fb          	endbr32 
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	57                   	push   %edi
  8001f6:	56                   	push   %esi
  8001f7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	b8 09 00 00 00       	mov    $0x9,%eax
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800213:	f3 0f 1e fb          	endbr32 
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	8b 55 08             	mov    0x8(%ebp),%edx
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800228:	b8 0a 00 00 00       	mov    $0xa,%eax
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800238:	f3 0f 1e fb          	endbr32 
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
	asm volatile("int %1\n"
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800248:	b8 0c 00 00 00       	mov    $0xc,%eax
  80024d:	be 00 00 00 00       	mov    $0x0,%esi
  800252:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800255:	8b 7d 14             	mov    0x14(%ebp),%edi
  800258:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80025f:	f3 0f 1e fb          	endbr32 
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
	asm volatile("int %1\n"
  800269:	b9 00 00 00 00       	mov    $0x0,%ecx
  80026e:	8b 55 08             	mov    0x8(%ebp),%edx
  800271:	b8 0d 00 00 00       	mov    $0xd,%eax
  800276:	89 cb                	mov    %ecx,%ebx
  800278:	89 cf                	mov    %ecx,%edi
  80027a:	89 ce                	mov    %ecx,%esi
  80027c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800283:	f3 0f 1e fb          	endbr32 
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
  800292:	b8 0e 00 00 00       	mov    $0xe,%eax
  800297:	89 d1                	mov    %edx,%ecx
  800299:	89 d3                	mov    %edx,%ebx
  80029b:	89 d7                	mov    %edx,%edi
  80029d:	89 d6                	mov    %edx,%esi
  80029f:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8002a6:	f3 0f 1e fb          	endbr32 
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002c0:	89 df                	mov    %ebx,%edi
  8002c2:	89 de                	mov    %ebx,%esi
  8002c4:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002cb:	f3 0f 1e fb          	endbr32 
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8002ff:	c1 e8 0c             	shr    $0xc,%eax
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800304:	f3 0f 1e fb          	endbr32 
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800313:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800318:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80031f:	f3 0f 1e fb          	endbr32 
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80032b:	89 c2                	mov    %eax,%edx
  80032d:	c1 ea 16             	shr    $0x16,%edx
  800330:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800337:	f6 c2 01             	test   $0x1,%dl
  80033a:	74 2d                	je     800369 <fd_alloc+0x4a>
  80033c:	89 c2                	mov    %eax,%edx
  80033e:	c1 ea 0c             	shr    $0xc,%edx
  800341:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800348:	f6 c2 01             	test   $0x1,%dl
  80034b:	74 1c                	je     800369 <fd_alloc+0x4a>
  80034d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800352:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800357:	75 d2                	jne    80032b <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800362:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800367:	eb 0a                	jmp    800373 <fd_alloc+0x54>
			*fd_store = fd;
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800375:	f3 0f 1e fb          	endbr32 
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80037f:	83 f8 1f             	cmp    $0x1f,%eax
  800382:	77 30                	ja     8003b4 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800384:	c1 e0 0c             	shl    $0xc,%eax
  800387:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80038c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 24                	je     8003bb <fd_lookup+0x46>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 1a                	je     8003c2 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    
		return -E_INVAL;
  8003b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003b9:	eb f7                	jmp    8003b2 <fd_lookup+0x3d>
		return -E_INVAL;
  8003bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c0:	eb f0                	jmp    8003b2 <fd_lookup+0x3d>
  8003c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c7:	eb e9                	jmp    8003b2 <fd_lookup+0x3d>

008003c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003c9:	f3 0f 1e fb          	endbr32 
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	83 ec 08             	sub    $0x8,%esp
  8003d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003db:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003e0:	39 08                	cmp    %ecx,(%eax)
  8003e2:	74 38                	je     80041c <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8003e4:	83 c2 01             	add    $0x1,%edx
  8003e7:	8b 04 95 e8 23 80 00 	mov    0x8023e8(,%edx,4),%eax
  8003ee:	85 c0                	test   %eax,%eax
  8003f0:	75 ee                	jne    8003e0 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8003f7:	8b 40 48             	mov    0x48(%eax),%eax
  8003fa:	83 ec 04             	sub    $0x4,%esp
  8003fd:	51                   	push   %ecx
  8003fe:	50                   	push   %eax
  8003ff:	68 6c 23 80 00       	push   $0x80236c
  800404:	e8 d6 11 00 00       	call   8015df <cprintf>
	*dev = 0;
  800409:	8b 45 0c             	mov    0xc(%ebp),%eax
  80040c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    
			*dev = devtab[i];
  80041c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800421:	b8 00 00 00 00       	mov    $0x0,%eax
  800426:	eb f2                	jmp    80041a <dev_lookup+0x51>

00800428 <fd_close>:
{
  800428:	f3 0f 1e fb          	endbr32 
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 24             	sub    $0x24,%esp
  800435:	8b 75 08             	mov    0x8(%ebp),%esi
  800438:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80043b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80043e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80043f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800445:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800448:	50                   	push   %eax
  800449:	e8 27 ff ff ff       	call   800375 <fd_lookup>
  80044e:	89 c3                	mov    %eax,%ebx
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	85 c0                	test   %eax,%eax
  800455:	78 05                	js     80045c <fd_close+0x34>
	    || fd != fd2)
  800457:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80045a:	74 16                	je     800472 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80045c:	89 f8                	mov    %edi,%eax
  80045e:	84 c0                	test   %al,%al
  800460:	b8 00 00 00 00       	mov    $0x0,%eax
  800465:	0f 44 d8             	cmove  %eax,%ebx
}
  800468:	89 d8                	mov    %ebx,%eax
  80046a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80046d:	5b                   	pop    %ebx
  80046e:	5e                   	pop    %esi
  80046f:	5f                   	pop    %edi
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800478:	50                   	push   %eax
  800479:	ff 36                	pushl  (%esi)
  80047b:	e8 49 ff ff ff       	call   8003c9 <dev_lookup>
  800480:	89 c3                	mov    %eax,%ebx
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	85 c0                	test   %eax,%eax
  800487:	78 1a                	js     8004a3 <fd_close+0x7b>
		if (dev->dev_close)
  800489:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80048f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800494:	85 c0                	test   %eax,%eax
  800496:	74 0b                	je     8004a3 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800498:	83 ec 0c             	sub    $0xc,%esp
  80049b:	56                   	push   %esi
  80049c:	ff d0                	call   *%eax
  80049e:	89 c3                	mov    %eax,%ebx
  8004a0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	56                   	push   %esi
  8004a7:	6a 00                	push   $0x0
  8004a9:	e8 f6 fc ff ff       	call   8001a4 <sys_page_unmap>
	return r;
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	eb b5                	jmp    800468 <fd_close+0x40>

008004b3 <close>:

int
close(int fdnum)
{
  8004b3:	f3 0f 1e fb          	endbr32 
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c0:	50                   	push   %eax
  8004c1:	ff 75 08             	pushl  0x8(%ebp)
  8004c4:	e8 ac fe ff ff       	call   800375 <fd_lookup>
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	79 02                	jns    8004d2 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    
		return fd_close(fd, 1);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	6a 01                	push   $0x1
  8004d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8004da:	e8 49 ff ff ff       	call   800428 <fd_close>
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb ec                	jmp    8004d0 <close+0x1d>

008004e4 <close_all>:

void
close_all(void)
{
  8004e4:	f3 0f 1e fb          	endbr32 
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	53                   	push   %ebx
  8004ec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004f4:	83 ec 0c             	sub    $0xc,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	e8 b6 ff ff ff       	call   8004b3 <close>
	for (i = 0; i < MAXFD; i++)
  8004fd:	83 c3 01             	add    $0x1,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	83 fb 20             	cmp    $0x20,%ebx
  800506:	75 ec                	jne    8004f4 <close_all+0x10>
}
  800508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80050d:	f3 0f 1e fb          	endbr32 
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	57                   	push   %edi
  800515:	56                   	push   %esi
  800516:	53                   	push   %ebx
  800517:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80051a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80051d:	50                   	push   %eax
  80051e:	ff 75 08             	pushl  0x8(%ebp)
  800521:	e8 4f fe ff ff       	call   800375 <fd_lookup>
  800526:	89 c3                	mov    %eax,%ebx
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	85 c0                	test   %eax,%eax
  80052d:	0f 88 81 00 00 00    	js     8005b4 <dup+0xa7>
		return r;
	close(newfdnum);
  800533:	83 ec 0c             	sub    $0xc,%esp
  800536:	ff 75 0c             	pushl  0xc(%ebp)
  800539:	e8 75 ff ff ff       	call   8004b3 <close>

	newfd = INDEX2FD(newfdnum);
  80053e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800541:	c1 e6 0c             	shl    $0xc,%esi
  800544:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80054a:	83 c4 04             	add    $0x4,%esp
  80054d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800550:	e8 af fd ff ff       	call   800304 <fd2data>
  800555:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800557:	89 34 24             	mov    %esi,(%esp)
  80055a:	e8 a5 fd ff ff       	call   800304 <fd2data>
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800564:	89 d8                	mov    %ebx,%eax
  800566:	c1 e8 16             	shr    $0x16,%eax
  800569:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800570:	a8 01                	test   $0x1,%al
  800572:	74 11                	je     800585 <dup+0x78>
  800574:	89 d8                	mov    %ebx,%eax
  800576:	c1 e8 0c             	shr    $0xc,%eax
  800579:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800580:	f6 c2 01             	test   $0x1,%dl
  800583:	75 39                	jne    8005be <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800585:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800588:	89 d0                	mov    %edx,%eax
  80058a:	c1 e8 0c             	shr    $0xc,%eax
  80058d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800594:	83 ec 0c             	sub    $0xc,%esp
  800597:	25 07 0e 00 00       	and    $0xe07,%eax
  80059c:	50                   	push   %eax
  80059d:	56                   	push   %esi
  80059e:	6a 00                	push   $0x0
  8005a0:	52                   	push   %edx
  8005a1:	6a 00                	push   $0x0
  8005a3:	e8 d7 fb ff ff       	call   80017f <sys_page_map>
  8005a8:	89 c3                	mov    %eax,%ebx
  8005aa:	83 c4 20             	add    $0x20,%esp
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	78 31                	js     8005e2 <dup+0xd5>
		goto err;

	return newfdnum;
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005b4:	89 d8                	mov    %ebx,%eax
  8005b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b9:	5b                   	pop    %ebx
  8005ba:	5e                   	pop    %esi
  8005bb:	5f                   	pop    %edi
  8005bc:	5d                   	pop    %ebp
  8005bd:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	57                   	push   %edi
  8005cf:	6a 00                	push   $0x0
  8005d1:	53                   	push   %ebx
  8005d2:	6a 00                	push   $0x0
  8005d4:	e8 a6 fb ff ff       	call   80017f <sys_page_map>
  8005d9:	89 c3                	mov    %eax,%ebx
  8005db:	83 c4 20             	add    $0x20,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	79 a3                	jns    800585 <dup+0x78>
	sys_page_unmap(0, newfd);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	56                   	push   %esi
  8005e6:	6a 00                	push   $0x0
  8005e8:	e8 b7 fb ff ff       	call   8001a4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005ed:	83 c4 08             	add    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	6a 00                	push   $0x0
  8005f3:	e8 ac fb ff ff       	call   8001a4 <sys_page_unmap>
	return r;
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	eb b7                	jmp    8005b4 <dup+0xa7>

008005fd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8005fd:	f3 0f 1e fb          	endbr32 
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	53                   	push   %ebx
  800605:	83 ec 1c             	sub    $0x1c,%esp
  800608:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80060b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80060e:	50                   	push   %eax
  80060f:	53                   	push   %ebx
  800610:	e8 60 fd ff ff       	call   800375 <fd_lookup>
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	85 c0                	test   %eax,%eax
  80061a:	78 3f                	js     80065b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800622:	50                   	push   %eax
  800623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800626:	ff 30                	pushl  (%eax)
  800628:	e8 9c fd ff ff       	call   8003c9 <dev_lookup>
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	85 c0                	test   %eax,%eax
  800632:	78 27                	js     80065b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800634:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800637:	8b 42 08             	mov    0x8(%edx),%eax
  80063a:	83 e0 03             	and    $0x3,%eax
  80063d:	83 f8 01             	cmp    $0x1,%eax
  800640:	74 1e                	je     800660 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800645:	8b 40 08             	mov    0x8(%eax),%eax
  800648:	85 c0                	test   %eax,%eax
  80064a:	74 35                	je     800681 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80064c:	83 ec 04             	sub    $0x4,%esp
  80064f:	ff 75 10             	pushl  0x10(%ebp)
  800652:	ff 75 0c             	pushl  0xc(%ebp)
  800655:	52                   	push   %edx
  800656:	ff d0                	call   *%eax
  800658:	83 c4 10             	add    $0x10,%esp
}
  80065b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80065e:	c9                   	leave  
  80065f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800660:	a1 08 40 80 00       	mov    0x804008,%eax
  800665:	8b 40 48             	mov    0x48(%eax),%eax
  800668:	83 ec 04             	sub    $0x4,%esp
  80066b:	53                   	push   %ebx
  80066c:	50                   	push   %eax
  80066d:	68 ad 23 80 00       	push   $0x8023ad
  800672:	e8 68 0f 00 00       	call   8015df <cprintf>
		return -E_INVAL;
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80067f:	eb da                	jmp    80065b <read+0x5e>
		return -E_NOT_SUPP;
  800681:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800686:	eb d3                	jmp    80065b <read+0x5e>

00800688 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800688:	f3 0f 1e fb          	endbr32 
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	57                   	push   %edi
  800690:	56                   	push   %esi
  800691:	53                   	push   %ebx
  800692:	83 ec 0c             	sub    $0xc,%esp
  800695:	8b 7d 08             	mov    0x8(%ebp),%edi
  800698:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80069b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a0:	eb 02                	jmp    8006a4 <readn+0x1c>
  8006a2:	01 c3                	add    %eax,%ebx
  8006a4:	39 f3                	cmp    %esi,%ebx
  8006a6:	73 21                	jae    8006c9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006a8:	83 ec 04             	sub    $0x4,%esp
  8006ab:	89 f0                	mov    %esi,%eax
  8006ad:	29 d8                	sub    %ebx,%eax
  8006af:	50                   	push   %eax
  8006b0:	89 d8                	mov    %ebx,%eax
  8006b2:	03 45 0c             	add    0xc(%ebp),%eax
  8006b5:	50                   	push   %eax
  8006b6:	57                   	push   %edi
  8006b7:	e8 41 ff ff ff       	call   8005fd <read>
		if (m < 0)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	78 04                	js     8006c7 <readn+0x3f>
			return m;
		if (m == 0)
  8006c3:	75 dd                	jne    8006a2 <readn+0x1a>
  8006c5:	eb 02                	jmp    8006c9 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006c9:	89 d8                	mov    %ebx,%eax
  8006cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5f                   	pop    %edi
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006d3:	f3 0f 1e fb          	endbr32 
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	53                   	push   %ebx
  8006db:	83 ec 1c             	sub    $0x1c,%esp
  8006de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	53                   	push   %ebx
  8006e6:	e8 8a fc ff ff       	call   800375 <fd_lookup>
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 3a                	js     80072c <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f8:	50                   	push   %eax
  8006f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fc:	ff 30                	pushl  (%eax)
  8006fe:	e8 c6 fc ff ff       	call   8003c9 <dev_lookup>
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	85 c0                	test   %eax,%eax
  800708:	78 22                	js     80072c <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80070a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800711:	74 1e                	je     800731 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800713:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800716:	8b 52 0c             	mov    0xc(%edx),%edx
  800719:	85 d2                	test   %edx,%edx
  80071b:	74 35                	je     800752 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80071d:	83 ec 04             	sub    $0x4,%esp
  800720:	ff 75 10             	pushl  0x10(%ebp)
  800723:	ff 75 0c             	pushl  0xc(%ebp)
  800726:	50                   	push   %eax
  800727:	ff d2                	call   *%edx
  800729:	83 c4 10             	add    $0x10,%esp
}
  80072c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072f:	c9                   	leave  
  800730:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800731:	a1 08 40 80 00       	mov    0x804008,%eax
  800736:	8b 40 48             	mov    0x48(%eax),%eax
  800739:	83 ec 04             	sub    $0x4,%esp
  80073c:	53                   	push   %ebx
  80073d:	50                   	push   %eax
  80073e:	68 c9 23 80 00       	push   $0x8023c9
  800743:	e8 97 0e 00 00       	call   8015df <cprintf>
		return -E_INVAL;
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800750:	eb da                	jmp    80072c <write+0x59>
		return -E_NOT_SUPP;
  800752:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800757:	eb d3                	jmp    80072c <write+0x59>

00800759 <seek>:

int
seek(int fdnum, off_t offset)
{
  800759:	f3 0f 1e fb          	endbr32 
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800763:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800766:	50                   	push   %eax
  800767:	ff 75 08             	pushl  0x8(%ebp)
  80076a:	e8 06 fc ff ff       	call   800375 <fd_lookup>
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	85 c0                	test   %eax,%eax
  800774:	78 0e                	js     800784 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
  800779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800786:	f3 0f 1e fb          	endbr32 
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	53                   	push   %ebx
  80078e:	83 ec 1c             	sub    $0x1c,%esp
  800791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800794:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800797:	50                   	push   %eax
  800798:	53                   	push   %ebx
  800799:	e8 d7 fb ff ff       	call   800375 <fd_lookup>
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	78 37                	js     8007dc <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007af:	ff 30                	pushl  (%eax)
  8007b1:	e8 13 fc ff ff       	call   8003c9 <dev_lookup>
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	78 1f                	js     8007dc <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c4:	74 1b                	je     8007e1 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c9:	8b 52 18             	mov    0x18(%edx),%edx
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 32                	je     800802 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	50                   	push   %eax
  8007d7:	ff d2                	call   *%edx
  8007d9:	83 c4 10             	add    $0x10,%esp
}
  8007dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007e1:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007e6:	8b 40 48             	mov    0x48(%eax),%eax
  8007e9:	83 ec 04             	sub    $0x4,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	50                   	push   %eax
  8007ee:	68 8c 23 80 00       	push   $0x80238c
  8007f3:	e8 e7 0d 00 00       	call   8015df <cprintf>
		return -E_INVAL;
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800800:	eb da                	jmp    8007dc <ftruncate+0x56>
		return -E_NOT_SUPP;
  800802:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800807:	eb d3                	jmp    8007dc <ftruncate+0x56>

00800809 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800809:	f3 0f 1e fb          	endbr32 
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	53                   	push   %ebx
  800811:	83 ec 1c             	sub    $0x1c,%esp
  800814:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800817:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081a:	50                   	push   %eax
  80081b:	ff 75 08             	pushl  0x8(%ebp)
  80081e:	e8 52 fb ff ff       	call   800375 <fd_lookup>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	78 4b                	js     800875 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800830:	50                   	push   %eax
  800831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800834:	ff 30                	pushl  (%eax)
  800836:	e8 8e fb ff ff       	call   8003c9 <dev_lookup>
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 33                	js     800875 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800845:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800849:	74 2f                	je     80087a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80084b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80084e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800855:	00 00 00 
	stat->st_isdir = 0;
  800858:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80085f:	00 00 00 
	stat->st_dev = dev;
  800862:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	ff 75 f0             	pushl  -0x10(%ebp)
  80086f:	ff 50 14             	call   *0x14(%eax)
  800872:	83 c4 10             	add    $0x10,%esp
}
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    
		return -E_NOT_SUPP;
  80087a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80087f:	eb f4                	jmp    800875 <fstat+0x6c>

00800881 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80088a:	83 ec 08             	sub    $0x8,%esp
  80088d:	6a 00                	push   $0x0
  80088f:	ff 75 08             	pushl  0x8(%ebp)
  800892:	e8 01 02 00 00       	call   800a98 <open>
  800897:	89 c3                	mov    %eax,%ebx
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	85 c0                	test   %eax,%eax
  80089e:	78 1b                	js     8008bb <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	ff 75 0c             	pushl  0xc(%ebp)
  8008a6:	50                   	push   %eax
  8008a7:	e8 5d ff ff ff       	call   800809 <fstat>
  8008ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ae:	89 1c 24             	mov    %ebx,(%esp)
  8008b1:	e8 fd fb ff ff       	call   8004b3 <close>
	return r;
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	89 f3                	mov    %esi,%ebx
}
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	89 c6                	mov    %eax,%esi
  8008cb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008d4:	74 27                	je     8008fd <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008d6:	6a 07                	push   $0x7
  8008d8:	68 00 50 80 00       	push   $0x805000
  8008dd:	56                   	push   %esi
  8008de:	ff 35 00 40 80 00    	pushl  0x804000
  8008e4:	e8 27 17 00 00       	call   802010 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008e9:	83 c4 0c             	add    $0xc,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	53                   	push   %ebx
  8008ef:	6a 00                	push   $0x0
  8008f1:	e8 ad 16 00 00       	call   801fa3 <ipc_recv>
}
  8008f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008fd:	83 ec 0c             	sub    $0xc,%esp
  800900:	6a 01                	push   $0x1
  800902:	e8 61 17 00 00       	call   802068 <ipc_find_env>
  800907:	a3 00 40 80 00       	mov    %eax,0x804000
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	eb c5                	jmp    8008d6 <fsipc+0x12>

00800911 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800911:	f3 0f 1e fb          	endbr32 
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 40 0c             	mov    0xc(%eax),%eax
  800921:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800926:	8b 45 0c             	mov    0xc(%ebp),%eax
  800929:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80092e:	ba 00 00 00 00       	mov    $0x0,%edx
  800933:	b8 02 00 00 00       	mov    $0x2,%eax
  800938:	e8 87 ff ff ff       	call   8008c4 <fsipc>
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <devfile_flush>:
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 40 0c             	mov    0xc(%eax),%eax
  80094f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
  800959:	b8 06 00 00 00       	mov    $0x6,%eax
  80095e:	e8 61 ff ff ff       	call   8008c4 <fsipc>
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <devfile_stat>:
{
  800965:	f3 0f 1e fb          	endbr32 
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	83 ec 04             	sub    $0x4,%esp
  800970:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 40 0c             	mov    0xc(%eax),%eax
  800979:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80097e:	ba 00 00 00 00       	mov    $0x0,%edx
  800983:	b8 05 00 00 00       	mov    $0x5,%eax
  800988:	e8 37 ff ff ff       	call   8008c4 <fsipc>
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 2c                	js     8009bd <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800991:	83 ec 08             	sub    $0x8,%esp
  800994:	68 00 50 80 00       	push   $0x805000
  800999:	53                   	push   %ebx
  80099a:	e8 4a 12 00 00       	call   801be9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80099f:	a1 80 50 80 00       	mov    0x805080,%eax
  8009a4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009aa:	a1 84 50 80 00       	mov    0x805084,%eax
  8009af:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <devfile_write>:
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009d4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009d9:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009df:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009ed:	50                   	push   %eax
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	68 08 50 80 00       	push   $0x805008
  8009f6:	e8 ec 13 00 00       	call   801de7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8009fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800a00:	b8 04 00 00 00       	mov    $0x4,%eax
  800a05:	e8 ba fe ff ff       	call   8008c4 <fsipc>
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <devfile_read>:
{
  800a0c:	f3 0f 1e fb          	endbr32 
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a23:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a33:	e8 8c fe ff ff       	call   8008c4 <fsipc>
  800a38:	89 c3                	mov    %eax,%ebx
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 1f                	js     800a5d <devfile_read+0x51>
	assert(r <= n);
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	77 24                	ja     800a66 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a47:	7f 36                	jg     800a7f <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a49:	83 ec 04             	sub    $0x4,%esp
  800a4c:	50                   	push   %eax
  800a4d:	68 00 50 80 00       	push   $0x805000
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	e8 8d 13 00 00       	call   801de7 <memmove>
	return r;
  800a5a:	83 c4 10             	add    $0x10,%esp
}
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    
	assert(r <= n);
  800a66:	68 fc 23 80 00       	push   $0x8023fc
  800a6b:	68 03 24 80 00       	push   $0x802403
  800a70:	68 8c 00 00 00       	push   $0x8c
  800a75:	68 18 24 80 00       	push   $0x802418
  800a7a:	e8 79 0a 00 00       	call   8014f8 <_panic>
	assert(r <= PGSIZE);
  800a7f:	68 23 24 80 00       	push   $0x802423
  800a84:	68 03 24 80 00       	push   $0x802403
  800a89:	68 8d 00 00 00       	push   $0x8d
  800a8e:	68 18 24 80 00       	push   $0x802418
  800a93:	e8 60 0a 00 00       	call   8014f8 <_panic>

00800a98 <open>:
{
  800a98:	f3 0f 1e fb          	endbr32 
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	83 ec 1c             	sub    $0x1c,%esp
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa7:	56                   	push   %esi
  800aa8:	e8 f9 10 00 00       	call   801ba6 <strlen>
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab5:	7f 6c                	jg     800b23 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800abd:	50                   	push   %eax
  800abe:	e8 5c f8 ff ff       	call   80031f <fd_alloc>
  800ac3:	89 c3                	mov    %eax,%ebx
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	78 3c                	js     800b08 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800acc:	83 ec 08             	sub    $0x8,%esp
  800acf:	56                   	push   %esi
  800ad0:	68 00 50 80 00       	push   $0x805000
  800ad5:	e8 0f 11 00 00       	call   801be9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aea:	e8 d5 fd ff ff       	call   8008c4 <fsipc>
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	83 c4 10             	add    $0x10,%esp
  800af4:	85 c0                	test   %eax,%eax
  800af6:	78 19                	js     800b11 <open+0x79>
	return fd2num(fd);
  800af8:	83 ec 0c             	sub    $0xc,%esp
  800afb:	ff 75 f4             	pushl  -0xc(%ebp)
  800afe:	e8 ed f7 ff ff       	call   8002f0 <fd2num>
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	83 c4 10             	add    $0x10,%esp
}
  800b08:	89 d8                	mov    %ebx,%eax
  800b0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    
		fd_close(fd, 0);
  800b11:	83 ec 08             	sub    $0x8,%esp
  800b14:	6a 00                	push   $0x0
  800b16:	ff 75 f4             	pushl  -0xc(%ebp)
  800b19:	e8 0a f9 ff ff       	call   800428 <fd_close>
		return r;
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	eb e5                	jmp    800b08 <open+0x70>
		return -E_BAD_PATH;
  800b23:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b28:	eb de                	jmp    800b08 <open+0x70>

00800b2a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b2a:	f3 0f 1e fb          	endbr32 
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 08 00 00 00       	mov    $0x8,%eax
  800b3e:	e8 81 fd ff ff       	call   8008c4 <fsipc>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b45:	f3 0f 1e fb          	endbr32 
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b4f:	68 8f 24 80 00       	push   $0x80248f
  800b54:	ff 75 0c             	pushl  0xc(%ebp)
  800b57:	e8 8d 10 00 00       	call   801be9 <strcpy>
	return 0;
}
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <devsock_close>:
{
  800b63:	f3 0f 1e fb          	endbr32 
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 10             	sub    $0x10,%esp
  800b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b71:	53                   	push   %ebx
  800b72:	e8 2e 15 00 00       	call   8020a5 <pageref>
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	83 c4 10             	add    $0x10,%esp
		return 0;
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800b81:	83 fa 01             	cmp    $0x1,%edx
  800b84:	74 05                	je     800b8b <devsock_close+0x28>
}
  800b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	ff 73 0c             	pushl  0xc(%ebx)
  800b91:	e8 e3 02 00 00       	call   800e79 <nsipc_close>
  800b96:	83 c4 10             	add    $0x10,%esp
  800b99:	eb eb                	jmp    800b86 <devsock_close+0x23>

00800b9b <devsock_write>:
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800ba5:	6a 00                	push   $0x0
  800ba7:	ff 75 10             	pushl  0x10(%ebp)
  800baa:	ff 75 0c             	pushl  0xc(%ebp)
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	ff 70 0c             	pushl  0xc(%eax)
  800bb3:	e8 b5 03 00 00       	call   800f6d <nsipc_send>
}
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <devsock_read>:
{
  800bba:	f3 0f 1e fb          	endbr32 
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bc4:	6a 00                	push   $0x0
  800bc6:	ff 75 10             	pushl  0x10(%ebp)
  800bc9:	ff 75 0c             	pushl  0xc(%ebp)
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	ff 70 0c             	pushl  0xc(%eax)
  800bd2:	e8 1f 03 00 00       	call   800ef6 <nsipc_recv>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <fd2sockid>:
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bdf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800be2:	52                   	push   %edx
  800be3:	50                   	push   %eax
  800be4:	e8 8c f7 ff ff       	call   800375 <fd_lookup>
  800be9:	83 c4 10             	add    $0x10,%esp
  800bec:	85 c0                	test   %eax,%eax
  800bee:	78 10                	js     800c00 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf3:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800bf9:	39 08                	cmp    %ecx,(%eax)
  800bfb:	75 05                	jne    800c02 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800bfd:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    
		return -E_NOT_SUPP;
  800c02:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c07:	eb f7                	jmp    800c00 <fd2sockid+0x27>

00800c09 <alloc_sockfd>:
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 1c             	sub    $0x1c,%esp
  800c11:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c16:	50                   	push   %eax
  800c17:	e8 03 f7 ff ff       	call   80031f <fd_alloc>
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	83 c4 10             	add    $0x10,%esp
  800c21:	85 c0                	test   %eax,%eax
  800c23:	78 43                	js     800c68 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c25:	83 ec 04             	sub    $0x4,%esp
  800c28:	68 07 04 00 00       	push   $0x407
  800c2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800c30:	6a 00                	push   $0x0
  800c32:	e8 22 f5 ff ff       	call   800159 <sys_page_alloc>
  800c37:	89 c3                	mov    %eax,%ebx
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	78 28                	js     800c68 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c43:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c49:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c55:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	e8 8f f6 ff ff       	call   8002f0 <fd2num>
  800c61:	89 c3                	mov    %eax,%ebx
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	eb 0c                	jmp    800c74 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	56                   	push   %esi
  800c6c:	e8 08 02 00 00       	call   800e79 <nsipc_close>
		return r;
  800c71:	83 c4 10             	add    $0x10,%esp
}
  800c74:	89 d8                	mov    %ebx,%eax
  800c76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <accept>:
{
  800c7d:	f3 0f 1e fb          	endbr32 
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8a:	e8 4a ff ff ff       	call   800bd9 <fd2sockid>
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	78 1b                	js     800cae <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800c93:	83 ec 04             	sub    $0x4,%esp
  800c96:	ff 75 10             	pushl  0x10(%ebp)
  800c99:	ff 75 0c             	pushl  0xc(%ebp)
  800c9c:	50                   	push   %eax
  800c9d:	e8 22 01 00 00       	call   800dc4 <nsipc_accept>
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	78 05                	js     800cae <accept+0x31>
	return alloc_sockfd(r);
  800ca9:	e8 5b ff ff ff       	call   800c09 <alloc_sockfd>
}
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <bind>:
{
  800cb0:	f3 0f 1e fb          	endbr32 
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	e8 17 ff ff ff       	call   800bd9 <fd2sockid>
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	78 12                	js     800cd8 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800cc6:	83 ec 04             	sub    $0x4,%esp
  800cc9:	ff 75 10             	pushl  0x10(%ebp)
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	50                   	push   %eax
  800cd0:	e8 45 01 00 00       	call   800e1a <nsipc_bind>
  800cd5:	83 c4 10             	add    $0x10,%esp
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <shutdown>:
{
  800cda:	f3 0f 1e fb          	endbr32 
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	e8 ed fe ff ff       	call   800bd9 <fd2sockid>
  800cec:	85 c0                	test   %eax,%eax
  800cee:	78 0f                	js     800cff <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800cf0:	83 ec 08             	sub    $0x8,%esp
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	50                   	push   %eax
  800cf7:	e8 57 01 00 00       	call   800e53 <nsipc_shutdown>
  800cfc:	83 c4 10             	add    $0x10,%esp
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <connect>:
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	e8 c6 fe ff ff       	call   800bd9 <fd2sockid>
  800d13:	85 c0                	test   %eax,%eax
  800d15:	78 12                	js     800d29 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d17:	83 ec 04             	sub    $0x4,%esp
  800d1a:	ff 75 10             	pushl  0x10(%ebp)
  800d1d:	ff 75 0c             	pushl  0xc(%ebp)
  800d20:	50                   	push   %eax
  800d21:	e8 71 01 00 00       	call   800e97 <nsipc_connect>
  800d26:	83 c4 10             	add    $0x10,%esp
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <listen>:
{
  800d2b:	f3 0f 1e fb          	endbr32 
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	e8 9c fe ff ff       	call   800bd9 <fd2sockid>
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	78 0f                	js     800d50 <listen+0x25>
	return nsipc_listen(r, backlog);
  800d41:	83 ec 08             	sub    $0x8,%esp
  800d44:	ff 75 0c             	pushl  0xc(%ebp)
  800d47:	50                   	push   %eax
  800d48:	e8 83 01 00 00       	call   800ed0 <nsipc_listen>
  800d4d:	83 c4 10             	add    $0x10,%esp
}
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d52:	f3 0f 1e fb          	endbr32 
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d5c:	ff 75 10             	pushl  0x10(%ebp)
  800d5f:	ff 75 0c             	pushl  0xc(%ebp)
  800d62:	ff 75 08             	pushl  0x8(%ebp)
  800d65:	e8 65 02 00 00       	call   800fcf <nsipc_socket>
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	78 05                	js     800d76 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d71:	e8 93 fe ff ff       	call   800c09 <alloc_sockfd>
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	53                   	push   %ebx
  800d7c:	83 ec 04             	sub    $0x4,%esp
  800d7f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d81:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d88:	74 26                	je     800db0 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d8a:	6a 07                	push   $0x7
  800d8c:	68 00 60 80 00       	push   $0x806000
  800d91:	53                   	push   %ebx
  800d92:	ff 35 04 40 80 00    	pushl  0x804004
  800d98:	e8 73 12 00 00       	call   802010 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800d9d:	83 c4 0c             	add    $0xc,%esp
  800da0:	6a 00                	push   $0x0
  800da2:	6a 00                	push   $0x0
  800da4:	6a 00                	push   $0x0
  800da6:	e8 f8 11 00 00       	call   801fa3 <ipc_recv>
}
  800dab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	6a 02                	push   $0x2
  800db5:	e8 ae 12 00 00       	call   802068 <ipc_find_env>
  800dba:	a3 04 40 80 00       	mov    %eax,0x804004
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	eb c6                	jmp    800d8a <nsipc+0x12>

00800dc4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dc4:	f3 0f 1e fb          	endbr32 
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
  800dcd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dd8:	8b 06                	mov    (%esi),%eax
  800dda:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ddf:	b8 01 00 00 00       	mov    $0x1,%eax
  800de4:	e8 8f ff ff ff       	call   800d78 <nsipc>
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	85 c0                	test   %eax,%eax
  800ded:	79 09                	jns    800df8 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800def:	89 d8                	mov    %ebx,%eax
  800df1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	ff 35 10 60 80 00    	pushl  0x806010
  800e01:	68 00 60 80 00       	push   $0x806000
  800e06:	ff 75 0c             	pushl  0xc(%ebp)
  800e09:	e8 d9 0f 00 00       	call   801de7 <memmove>
		*addrlen = ret->ret_addrlen;
  800e0e:	a1 10 60 80 00       	mov    0x806010,%eax
  800e13:	89 06                	mov    %eax,(%esi)
  800e15:	83 c4 10             	add    $0x10,%esp
	return r;
  800e18:	eb d5                	jmp    800def <nsipc_accept+0x2b>

00800e1a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e1a:	f3 0f 1e fb          	endbr32 
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	53                   	push   %ebx
  800e22:	83 ec 08             	sub    $0x8,%esp
  800e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e30:	53                   	push   %ebx
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	68 04 60 80 00       	push   $0x806004
  800e39:	e8 a9 0f 00 00       	call   801de7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e3e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e44:	b8 02 00 00 00       	mov    $0x2,%eax
  800e49:	e8 2a ff ff ff       	call   800d78 <nsipc>
}
  800e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e53:	f3 0f 1e fb          	endbr32 
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e6d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e72:	e8 01 ff ff ff       	call   800d78 <nsipc>
}
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <nsipc_close>:

int
nsipc_close(int s)
{
  800e79:	f3 0f 1e fb          	endbr32 
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
  800e86:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e90:	e8 e3 fe ff ff       	call   800d78 <nsipc>
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e97:	f3 0f 1e fb          	endbr32 
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ead:	53                   	push   %ebx
  800eae:	ff 75 0c             	pushl  0xc(%ebp)
  800eb1:	68 04 60 80 00       	push   $0x806004
  800eb6:	e8 2c 0f 00 00       	call   801de7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ebb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ec1:	b8 05 00 00 00       	mov    $0x5,%eax
  800ec6:	e8 ad fe ff ff       	call   800d78 <nsipc>
}
  800ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ed0:	f3 0f 1e fb          	endbr32 
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800eea:	b8 06 00 00 00       	mov    $0x6,%eax
  800eef:	e8 84 fe ff ff       	call   800d78 <nsipc>
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800ef6:	f3 0f 1e fb          	endbr32 
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f0a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f10:	8b 45 14             	mov    0x14(%ebp),%eax
  800f13:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f18:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1d:	e8 56 fe ff ff       	call   800d78 <nsipc>
  800f22:	89 c3                	mov    %eax,%ebx
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 26                	js     800f4e <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f28:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f2e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f33:	0f 4e c6             	cmovle %esi,%eax
  800f36:	39 c3                	cmp    %eax,%ebx
  800f38:	7f 1d                	jg     800f57 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f3a:	83 ec 04             	sub    $0x4,%esp
  800f3d:	53                   	push   %ebx
  800f3e:	68 00 60 80 00       	push   $0x806000
  800f43:	ff 75 0c             	pushl  0xc(%ebp)
  800f46:	e8 9c 0e 00 00       	call   801de7 <memmove>
  800f4b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f4e:	89 d8                	mov    %ebx,%eax
  800f50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f57:	68 9b 24 80 00       	push   $0x80249b
  800f5c:	68 03 24 80 00       	push   $0x802403
  800f61:	6a 62                	push   $0x62
  800f63:	68 b0 24 80 00       	push   $0x8024b0
  800f68:	e8 8b 05 00 00       	call   8014f8 <_panic>

00800f6d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f6d:	f3 0f 1e fb          	endbr32 
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	53                   	push   %ebx
  800f75:	83 ec 04             	sub    $0x4,%esp
  800f78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f83:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f89:	7f 2e                	jg     800fb9 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f8b:	83 ec 04             	sub    $0x4,%esp
  800f8e:	53                   	push   %ebx
  800f8f:	ff 75 0c             	pushl  0xc(%ebp)
  800f92:	68 0c 60 80 00       	push   $0x80600c
  800f97:	e8 4b 0e 00 00       	call   801de7 <memmove>
	nsipcbuf.send.req_size = size;
  800f9c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800faa:	b8 08 00 00 00       	mov    $0x8,%eax
  800faf:	e8 c4 fd ff ff       	call   800d78 <nsipc>
}
  800fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    
	assert(size < 1600);
  800fb9:	68 bc 24 80 00       	push   $0x8024bc
  800fbe:	68 03 24 80 00       	push   $0x802403
  800fc3:	6a 6d                	push   $0x6d
  800fc5:	68 b0 24 80 00       	push   $0x8024b0
  800fca:	e8 29 05 00 00       	call   8014f8 <_panic>

00800fcf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fcf:	f3 0f 1e fb          	endbr32 
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ff1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff6:	e8 7d fd ff ff       	call   800d78 <nsipc>
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ffd:	f3 0f 1e fb          	endbr32 
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	ff 75 08             	pushl  0x8(%ebp)
  80100f:	e8 f0 f2 ff ff       	call   800304 <fd2data>
  801014:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	68 c8 24 80 00       	push   $0x8024c8
  80101e:	53                   	push   %ebx
  80101f:	e8 c5 0b 00 00       	call   801be9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801024:	8b 46 04             	mov    0x4(%esi),%eax
  801027:	2b 06                	sub    (%esi),%eax
  801029:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801036:	00 00 00 
	stat->st_dev = &devpipe;
  801039:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801040:	30 80 00 
	return 0;
}
  801043:	b8 00 00 00 00       	mov    $0x0,%eax
  801048:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104f:	f3 0f 1e fb          	endbr32 
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80105d:	53                   	push   %ebx
  80105e:	6a 00                	push   $0x0
  801060:	e8 3f f1 ff ff       	call   8001a4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 97 f2 ff ff       	call   800304 <fd2data>
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	50                   	push   %eax
  801071:	6a 00                	push   $0x0
  801073:	e8 2c f1 ff ff       	call   8001a4 <sys_page_unmap>
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <_pipeisclosed>:
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 1c             	sub    $0x1c,%esp
  801086:	89 c7                	mov    %eax,%edi
  801088:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80108a:	a1 08 40 80 00       	mov    0x804008,%eax
  80108f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	57                   	push   %edi
  801096:	e8 0a 10 00 00       	call   8020a5 <pageref>
  80109b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80109e:	89 34 24             	mov    %esi,(%esp)
  8010a1:	e8 ff 0f 00 00       	call   8020a5 <pageref>
		nn = thisenv->env_runs;
  8010a6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ac:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	39 cb                	cmp    %ecx,%ebx
  8010b4:	74 1b                	je     8010d1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010b6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010b9:	75 cf                	jne    80108a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010bb:	8b 42 58             	mov    0x58(%edx),%eax
  8010be:	6a 01                	push   $0x1
  8010c0:	50                   	push   %eax
  8010c1:	53                   	push   %ebx
  8010c2:	68 cf 24 80 00       	push   $0x8024cf
  8010c7:	e8 13 05 00 00       	call   8015df <cprintf>
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	eb b9                	jmp    80108a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010d1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010d4:	0f 94 c0             	sete   %al
  8010d7:	0f b6 c0             	movzbl %al,%eax
}
  8010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <devpipe_write>:
{
  8010e2:	f3 0f 1e fb          	endbr32 
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	57                   	push   %edi
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 28             	sub    $0x28,%esp
  8010ef:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010f2:	56                   	push   %esi
  8010f3:	e8 0c f2 ff ff       	call   800304 <fd2data>
  8010f8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	bf 00 00 00 00       	mov    $0x0,%edi
  801102:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801105:	74 4f                	je     801156 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801107:	8b 43 04             	mov    0x4(%ebx),%eax
  80110a:	8b 0b                	mov    (%ebx),%ecx
  80110c:	8d 51 20             	lea    0x20(%ecx),%edx
  80110f:	39 d0                	cmp    %edx,%eax
  801111:	72 14                	jb     801127 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801113:	89 da                	mov    %ebx,%edx
  801115:	89 f0                	mov    %esi,%eax
  801117:	e8 61 ff ff ff       	call   80107d <_pipeisclosed>
  80111c:	85 c0                	test   %eax,%eax
  80111e:	75 3b                	jne    80115b <devpipe_write+0x79>
			sys_yield();
  801120:	e8 11 f0 ff ff       	call   800136 <sys_yield>
  801125:	eb e0                	jmp    801107 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 fa 1f             	sar    $0x1f,%edx
  801136:	89 d1                	mov    %edx,%ecx
  801138:	c1 e9 1b             	shr    $0x1b,%ecx
  80113b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113e:	83 e2 1f             	and    $0x1f,%edx
  801141:	29 ca                	sub    %ecx,%edx
  801143:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801147:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114b:	83 c0 01             	add    $0x1,%eax
  80114e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801151:	83 c7 01             	add    $0x1,%edi
  801154:	eb ac                	jmp    801102 <devpipe_write+0x20>
	return i;
  801156:	8b 45 10             	mov    0x10(%ebp),%eax
  801159:	eb 05                	jmp    801160 <devpipe_write+0x7e>
				return 0;
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <devpipe_read>:
{
  801168:	f3 0f 1e fb          	endbr32 
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	57                   	push   %edi
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 18             	sub    $0x18,%esp
  801175:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801178:	57                   	push   %edi
  801179:	e8 86 f1 ff ff       	call   800304 <fd2data>
  80117e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	be 00 00 00 00       	mov    $0x0,%esi
  801188:	3b 75 10             	cmp    0x10(%ebp),%esi
  80118b:	75 14                	jne    8011a1 <devpipe_read+0x39>
	return i;
  80118d:	8b 45 10             	mov    0x10(%ebp),%eax
  801190:	eb 02                	jmp    801194 <devpipe_read+0x2c>
				return i;
  801192:	89 f0                	mov    %esi,%eax
}
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    
			sys_yield();
  80119c:	e8 95 ef ff ff       	call   800136 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011a1:	8b 03                	mov    (%ebx),%eax
  8011a3:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011a6:	75 18                	jne    8011c0 <devpipe_read+0x58>
			if (i > 0)
  8011a8:	85 f6                	test   %esi,%esi
  8011aa:	75 e6                	jne    801192 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011ac:	89 da                	mov    %ebx,%edx
  8011ae:	89 f8                	mov    %edi,%eax
  8011b0:	e8 c8 fe ff ff       	call   80107d <_pipeisclosed>
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	74 e3                	je     80119c <devpipe_read+0x34>
				return 0;
  8011b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011be:	eb d4                	jmp    801194 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011c0:	99                   	cltd   
  8011c1:	c1 ea 1b             	shr    $0x1b,%edx
  8011c4:	01 d0                	add    %edx,%eax
  8011c6:	83 e0 1f             	and    $0x1f,%eax
  8011c9:	29 d0                	sub    %edx,%eax
  8011cb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011d6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d9:	83 c6 01             	add    $0x1,%esi
  8011dc:	eb aa                	jmp    801188 <devpipe_read+0x20>

008011de <pipe>:
{
  8011de:	f3 0f 1e fb          	endbr32 
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	e8 2c f1 ff ff       	call   80031f <fd_alloc>
  8011f3:	89 c3                	mov    %eax,%ebx
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	0f 88 23 01 00 00    	js     801323 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	68 07 04 00 00       	push   $0x407
  801208:	ff 75 f4             	pushl  -0xc(%ebp)
  80120b:	6a 00                	push   $0x0
  80120d:	e8 47 ef ff ff       	call   800159 <sys_page_alloc>
  801212:	89 c3                	mov    %eax,%ebx
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	85 c0                	test   %eax,%eax
  801219:	0f 88 04 01 00 00    	js     801323 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	e8 f4 f0 ff ff       	call   80031f <fd_alloc>
  80122b:	89 c3                	mov    %eax,%ebx
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	0f 88 db 00 00 00    	js     801313 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	68 07 04 00 00       	push   $0x407
  801240:	ff 75 f0             	pushl  -0x10(%ebp)
  801243:	6a 00                	push   $0x0
  801245:	e8 0f ef ff ff       	call   800159 <sys_page_alloc>
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	0f 88 bc 00 00 00    	js     801313 <pipe+0x135>
	va = fd2data(fd0);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	ff 75 f4             	pushl  -0xc(%ebp)
  80125d:	e8 a2 f0 ff ff       	call   800304 <fd2data>
  801262:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801264:	83 c4 0c             	add    $0xc,%esp
  801267:	68 07 04 00 00       	push   $0x407
  80126c:	50                   	push   %eax
  80126d:	6a 00                	push   $0x0
  80126f:	e8 e5 ee ff ff       	call   800159 <sys_page_alloc>
  801274:	89 c3                	mov    %eax,%ebx
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	0f 88 82 00 00 00    	js     801303 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	ff 75 f0             	pushl  -0x10(%ebp)
  801287:	e8 78 f0 ff ff       	call   800304 <fd2data>
  80128c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801293:	50                   	push   %eax
  801294:	6a 00                	push   $0x0
  801296:	56                   	push   %esi
  801297:	6a 00                	push   $0x0
  801299:	e8 e1 ee ff ff       	call   80017f <sys_page_map>
  80129e:	89 c3                	mov    %eax,%ebx
  8012a0:	83 c4 20             	add    $0x20,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 4e                	js     8012f5 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8012a7:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012af:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012be:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d0:	e8 1b f0 ff ff       	call   8002f0 <fd2num>
  8012d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012da:	83 c4 04             	add    $0x4,%esp
  8012dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e0:	e8 0b f0 ff ff       	call   8002f0 <fd2num>
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f3:	eb 2e                	jmp    801323 <pipe+0x145>
	sys_page_unmap(0, va);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	56                   	push   %esi
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 a4 ee ff ff       	call   8001a4 <sys_page_unmap>
  801300:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 f0             	pushl  -0x10(%ebp)
  801309:	6a 00                	push   $0x0
  80130b:	e8 94 ee ff ff       	call   8001a4 <sys_page_unmap>
  801310:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 f4             	pushl  -0xc(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 84 ee ff ff       	call   8001a4 <sys_page_unmap>
  801320:	83 c4 10             	add    $0x10,%esp
}
  801323:	89 d8                	mov    %ebx,%eax
  801325:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <pipeisclosed>:
{
  80132c:	f3 0f 1e fb          	endbr32 
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	ff 75 08             	pushl  0x8(%ebp)
  80133d:	e8 33 f0 ff ff       	call   800375 <fd_lookup>
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 18                	js     801361 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	ff 75 f4             	pushl  -0xc(%ebp)
  80134f:	e8 b0 ef ff ff       	call   800304 <fd2data>
  801354:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801356:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801359:	e8 1f fd ff ff       	call   80107d <_pipeisclosed>
  80135e:	83 c4 10             	add    $0x10,%esp
}
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801363:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801367:	b8 00 00 00 00       	mov    $0x0,%eax
  80136c:	c3                   	ret    

0080136d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136d:	f3 0f 1e fb          	endbr32 
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801377:	68 e7 24 80 00       	push   $0x8024e7
  80137c:	ff 75 0c             	pushl  0xc(%ebp)
  80137f:	e8 65 08 00 00       	call   801be9 <strcpy>
	return 0;
}
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <devcons_write>:
{
  80138b:	f3 0f 1e fb          	endbr32 
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	57                   	push   %edi
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80139b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013a0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013a6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a9:	73 31                	jae    8013dc <devcons_write+0x51>
		m = n - tot;
  8013ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ae:	29 f3                	sub    %esi,%ebx
  8013b0:	83 fb 7f             	cmp    $0x7f,%ebx
  8013b3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013b8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013bb:	83 ec 04             	sub    $0x4,%esp
  8013be:	53                   	push   %ebx
  8013bf:	89 f0                	mov    %esi,%eax
  8013c1:	03 45 0c             	add    0xc(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	57                   	push   %edi
  8013c6:	e8 1c 0a 00 00       	call   801de7 <memmove>
		sys_cputs(buf, m);
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	53                   	push   %ebx
  8013cf:	57                   	push   %edi
  8013d0:	e8 d5 ec ff ff       	call   8000aa <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013d5:	01 de                	add    %ebx,%esi
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	eb ca                	jmp    8013a6 <devcons_write+0x1b>
}
  8013dc:	89 f0                	mov    %esi,%eax
  8013de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <devcons_read>:
{
  8013e6:	f3 0f 1e fb          	endbr32 
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f9:	74 21                	je     80141c <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8013fb:	e8 cc ec ff ff       	call   8000cc <sys_cgetc>
  801400:	85 c0                	test   %eax,%eax
  801402:	75 07                	jne    80140b <devcons_read+0x25>
		sys_yield();
  801404:	e8 2d ed ff ff       	call   800136 <sys_yield>
  801409:	eb f0                	jmp    8013fb <devcons_read+0x15>
	if (c < 0)
  80140b:	78 0f                	js     80141c <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80140d:	83 f8 04             	cmp    $0x4,%eax
  801410:	74 0c                	je     80141e <devcons_read+0x38>
	*(char*)vbuf = c;
  801412:	8b 55 0c             	mov    0xc(%ebp),%edx
  801415:	88 02                	mov    %al,(%edx)
	return 1;
  801417:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    
		return 0;
  80141e:	b8 00 00 00 00       	mov    $0x0,%eax
  801423:	eb f7                	jmp    80141c <devcons_read+0x36>

00801425 <cputchar>:
{
  801425:	f3 0f 1e fb          	endbr32 
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801435:	6a 01                	push   $0x1
  801437:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	e8 6a ec ff ff       	call   8000aa <sys_cputs>
}
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <getchar>:
{
  801445:	f3 0f 1e fb          	endbr32 
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80144f:	6a 01                	push   $0x1
  801451:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	6a 00                	push   $0x0
  801457:	e8 a1 f1 ff ff       	call   8005fd <read>
	if (r < 0)
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	85 c0                	test   %eax,%eax
  801461:	78 06                	js     801469 <getchar+0x24>
	if (r < 1)
  801463:	74 06                	je     80146b <getchar+0x26>
	return c;
  801465:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    
		return -E_EOF;
  80146b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801470:	eb f7                	jmp    801469 <getchar+0x24>

00801472 <iscons>:
{
  801472:	f3 0f 1e fb          	endbr32 
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	ff 75 08             	pushl  0x8(%ebp)
  801483:	e8 ed ee ff ff       	call   800375 <fd_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 11                	js     8014a0 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80148f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801492:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801498:	39 10                	cmp    %edx,(%eax)
  80149a:	0f 94 c0             	sete   %al
  80149d:	0f b6 c0             	movzbl %al,%eax
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <opencons>:
{
  8014a2:	f3 0f 1e fb          	endbr32 
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	e8 6a ee ff ff       	call   80031f <fd_alloc>
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 3a                	js     8014f6 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	68 07 04 00 00       	push   $0x407
  8014c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c7:	6a 00                	push   $0x0
  8014c9:	e8 8b ec ff ff       	call   800159 <sys_page_alloc>
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 21                	js     8014f6 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d8:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014de:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	50                   	push   %eax
  8014ee:	e8 fd ed ff ff       	call   8002f0 <fd2num>
  8014f3:	83 c4 10             	add    $0x10,%esp
}
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f8:	f3 0f 1e fb          	endbr32 
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801501:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801504:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80150a:	e8 04 ec ff ff       	call   800113 <sys_getenvid>
  80150f:	83 ec 0c             	sub    $0xc,%esp
  801512:	ff 75 0c             	pushl  0xc(%ebp)
  801515:	ff 75 08             	pushl  0x8(%ebp)
  801518:	56                   	push   %esi
  801519:	50                   	push   %eax
  80151a:	68 f4 24 80 00       	push   $0x8024f4
  80151f:	e8 bb 00 00 00       	call   8015df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801524:	83 c4 18             	add    $0x18,%esp
  801527:	53                   	push   %ebx
  801528:	ff 75 10             	pushl  0x10(%ebp)
  80152b:	e8 5a 00 00 00       	call   80158a <vcprintf>
	cprintf("\n");
  801530:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  801537:	e8 a3 00 00 00       	call   8015df <cprintf>
  80153c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80153f:	cc                   	int3   
  801540:	eb fd                	jmp    80153f <_panic+0x47>

00801542 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801542:	f3 0f 1e fb          	endbr32 
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	53                   	push   %ebx
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801550:	8b 13                	mov    (%ebx),%edx
  801552:	8d 42 01             	lea    0x1(%edx),%eax
  801555:	89 03                	mov    %eax,(%ebx)
  801557:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80155e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801563:	74 09                	je     80156e <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801565:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	68 ff 00 00 00       	push   $0xff
  801576:	8d 43 08             	lea    0x8(%ebx),%eax
  801579:	50                   	push   %eax
  80157a:	e8 2b eb ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  80157f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	eb db                	jmp    801565 <putch+0x23>

0080158a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80158a:	f3 0f 1e fb          	endbr32 
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801597:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80159e:	00 00 00 
	b.cnt = 0;
  8015a1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015a8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015ab:	ff 75 0c             	pushl  0xc(%ebp)
  8015ae:	ff 75 08             	pushl  0x8(%ebp)
  8015b1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	68 42 15 80 00       	push   $0x801542
  8015bd:	e8 20 01 00 00       	call   8016e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015cb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	e8 d3 ea ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8015d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015df:	f3 0f 1e fb          	endbr32 
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ec:	50                   	push   %eax
  8015ed:	ff 75 08             	pushl  0x8(%ebp)
  8015f0:	e8 95 ff ff ff       	call   80158a <vcprintf>
	va_end(ap);

	return cnt;
}
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	57                   	push   %edi
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 1c             	sub    $0x1c,%esp
  801600:	89 c7                	mov    %eax,%edi
  801602:	89 d6                	mov    %edx,%esi
  801604:	8b 45 08             	mov    0x8(%ebp),%eax
  801607:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160a:	89 d1                	mov    %edx,%ecx
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801611:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801614:	8b 45 10             	mov    0x10(%ebp),%eax
  801617:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80161a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80161d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801624:	39 c2                	cmp    %eax,%edx
  801626:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801629:	72 3e                	jb     801669 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80162b:	83 ec 0c             	sub    $0xc,%esp
  80162e:	ff 75 18             	pushl  0x18(%ebp)
  801631:	83 eb 01             	sub    $0x1,%ebx
  801634:	53                   	push   %ebx
  801635:	50                   	push   %eax
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	ff 75 e4             	pushl  -0x1c(%ebp)
  80163c:	ff 75 e0             	pushl  -0x20(%ebp)
  80163f:	ff 75 dc             	pushl  -0x24(%ebp)
  801642:	ff 75 d8             	pushl  -0x28(%ebp)
  801645:	e8 a6 0a 00 00       	call   8020f0 <__udivdi3>
  80164a:	83 c4 18             	add    $0x18,%esp
  80164d:	52                   	push   %edx
  80164e:	50                   	push   %eax
  80164f:	89 f2                	mov    %esi,%edx
  801651:	89 f8                	mov    %edi,%eax
  801653:	e8 9f ff ff ff       	call   8015f7 <printnum>
  801658:	83 c4 20             	add    $0x20,%esp
  80165b:	eb 13                	jmp    801670 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	56                   	push   %esi
  801661:	ff 75 18             	pushl  0x18(%ebp)
  801664:	ff d7                	call   *%edi
  801666:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801669:	83 eb 01             	sub    $0x1,%ebx
  80166c:	85 db                	test   %ebx,%ebx
  80166e:	7f ed                	jg     80165d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	56                   	push   %esi
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167a:	ff 75 e0             	pushl  -0x20(%ebp)
  80167d:	ff 75 dc             	pushl  -0x24(%ebp)
  801680:	ff 75 d8             	pushl  -0x28(%ebp)
  801683:	e8 78 0b 00 00       	call   802200 <__umoddi3>
  801688:	83 c4 14             	add    $0x14,%esp
  80168b:	0f be 80 17 25 80 00 	movsbl 0x802517(%eax),%eax
  801692:	50                   	push   %eax
  801693:	ff d7                	call   *%edi
}
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5f                   	pop    %edi
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016a0:	f3 0f 1e fb          	endbr32 
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016aa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016ae:	8b 10                	mov    (%eax),%edx
  8016b0:	3b 50 04             	cmp    0x4(%eax),%edx
  8016b3:	73 0a                	jae    8016bf <sprintputch+0x1f>
		*b->buf++ = ch;
  8016b5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016b8:	89 08                	mov    %ecx,(%eax)
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	88 02                	mov    %al,(%edx)
}
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <printfmt>:
{
  8016c1:	f3 0f 1e fb          	endbr32 
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016cb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 10             	pushl  0x10(%ebp)
  8016d2:	ff 75 0c             	pushl  0xc(%ebp)
  8016d5:	ff 75 08             	pushl  0x8(%ebp)
  8016d8:	e8 05 00 00 00       	call   8016e2 <vprintfmt>
}
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <vprintfmt>:
{
  8016e2:	f3 0f 1e fb          	endbr32 
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	57                   	push   %edi
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 3c             	sub    $0x3c,%esp
  8016ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016f5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016f8:	e9 8e 03 00 00       	jmp    801a8b <vprintfmt+0x3a9>
		padc = ' ';
  8016fd:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801701:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801708:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80170f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801716:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80171b:	8d 47 01             	lea    0x1(%edi),%eax
  80171e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801721:	0f b6 17             	movzbl (%edi),%edx
  801724:	8d 42 dd             	lea    -0x23(%edx),%eax
  801727:	3c 55                	cmp    $0x55,%al
  801729:	0f 87 df 03 00 00    	ja     801b0e <vprintfmt+0x42c>
  80172f:	0f b6 c0             	movzbl %al,%eax
  801732:	3e ff 24 85 60 26 80 	notrack jmp *0x802660(,%eax,4)
  801739:	00 
  80173a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80173d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801741:	eb d8                	jmp    80171b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801746:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80174a:	eb cf                	jmp    80171b <vprintfmt+0x39>
  80174c:	0f b6 d2             	movzbl %dl,%edx
  80174f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801752:	b8 00 00 00 00       	mov    $0x0,%eax
  801757:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80175a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80175d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801761:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801764:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801767:	83 f9 09             	cmp    $0x9,%ecx
  80176a:	77 55                	ja     8017c1 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80176c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80176f:	eb e9                	jmp    80175a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801771:	8b 45 14             	mov    0x14(%ebp),%eax
  801774:	8b 00                	mov    (%eax),%eax
  801776:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801779:	8b 45 14             	mov    0x14(%ebp),%eax
  80177c:	8d 40 04             	lea    0x4(%eax),%eax
  80177f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801785:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801789:	79 90                	jns    80171b <vprintfmt+0x39>
				width = precision, precision = -1;
  80178b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80178e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801791:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801798:	eb 81                	jmp    80171b <vprintfmt+0x39>
  80179a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80179d:	85 c0                	test   %eax,%eax
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	0f 49 d0             	cmovns %eax,%edx
  8017a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017ad:	e9 69 ff ff ff       	jmp    80171b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017b5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017bc:	e9 5a ff ff ff       	jmp    80171b <vprintfmt+0x39>
  8017c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017c7:	eb bc                	jmp    801785 <vprintfmt+0xa3>
			lflag++;
  8017c9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017cf:	e9 47 ff ff ff       	jmp    80171b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d7:	8d 78 04             	lea    0x4(%eax),%edi
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	53                   	push   %ebx
  8017de:	ff 30                	pushl  (%eax)
  8017e0:	ff d6                	call   *%esi
			break;
  8017e2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017e5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017e8:	e9 9b 02 00 00       	jmp    801a88 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8017ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f0:	8d 78 04             	lea    0x4(%eax),%edi
  8017f3:	8b 00                	mov    (%eax),%eax
  8017f5:	99                   	cltd   
  8017f6:	31 d0                	xor    %edx,%eax
  8017f8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017fa:	83 f8 0f             	cmp    $0xf,%eax
  8017fd:	7f 23                	jg     801822 <vprintfmt+0x140>
  8017ff:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  801806:	85 d2                	test   %edx,%edx
  801808:	74 18                	je     801822 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80180a:	52                   	push   %edx
  80180b:	68 15 24 80 00       	push   $0x802415
  801810:	53                   	push   %ebx
  801811:	56                   	push   %esi
  801812:	e8 aa fe ff ff       	call   8016c1 <printfmt>
  801817:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80181a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80181d:	e9 66 02 00 00       	jmp    801a88 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  801822:	50                   	push   %eax
  801823:	68 2f 25 80 00       	push   $0x80252f
  801828:	53                   	push   %ebx
  801829:	56                   	push   %esi
  80182a:	e8 92 fe ff ff       	call   8016c1 <printfmt>
  80182f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801832:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801835:	e9 4e 02 00 00       	jmp    801a88 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80183a:	8b 45 14             	mov    0x14(%ebp),%eax
  80183d:	83 c0 04             	add    $0x4,%eax
  801840:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801843:	8b 45 14             	mov    0x14(%ebp),%eax
  801846:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801848:	85 d2                	test   %edx,%edx
  80184a:	b8 28 25 80 00       	mov    $0x802528,%eax
  80184f:	0f 45 c2             	cmovne %edx,%eax
  801852:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801855:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801859:	7e 06                	jle    801861 <vprintfmt+0x17f>
  80185b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80185f:	75 0d                	jne    80186e <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801861:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801864:	89 c7                	mov    %eax,%edi
  801866:	03 45 e0             	add    -0x20(%ebp),%eax
  801869:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80186c:	eb 55                	jmp    8018c3 <vprintfmt+0x1e1>
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	ff 75 d8             	pushl  -0x28(%ebp)
  801874:	ff 75 cc             	pushl  -0x34(%ebp)
  801877:	e8 46 03 00 00       	call   801bc2 <strnlen>
  80187c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80187f:	29 c2                	sub    %eax,%edx
  801881:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801889:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80188d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801890:	85 ff                	test   %edi,%edi
  801892:	7e 11                	jle    8018a5 <vprintfmt+0x1c3>
					putch(padc, putdat);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	53                   	push   %ebx
  801898:	ff 75 e0             	pushl  -0x20(%ebp)
  80189b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80189d:	83 ef 01             	sub    $0x1,%edi
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	eb eb                	jmp    801890 <vprintfmt+0x1ae>
  8018a5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018a8:	85 d2                	test   %edx,%edx
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8018af:	0f 49 c2             	cmovns %edx,%eax
  8018b2:	29 c2                	sub    %eax,%edx
  8018b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018b7:	eb a8                	jmp    801861 <vprintfmt+0x17f>
					putch(ch, putdat);
  8018b9:	83 ec 08             	sub    $0x8,%esp
  8018bc:	53                   	push   %ebx
  8018bd:	52                   	push   %edx
  8018be:	ff d6                	call   *%esi
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018c6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018c8:	83 c7 01             	add    $0x1,%edi
  8018cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018cf:	0f be d0             	movsbl %al,%edx
  8018d2:	85 d2                	test   %edx,%edx
  8018d4:	74 4b                	je     801921 <vprintfmt+0x23f>
  8018d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018da:	78 06                	js     8018e2 <vprintfmt+0x200>
  8018dc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018e0:	78 1e                	js     801900 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8018e2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018e6:	74 d1                	je     8018b9 <vprintfmt+0x1d7>
  8018e8:	0f be c0             	movsbl %al,%eax
  8018eb:	83 e8 20             	sub    $0x20,%eax
  8018ee:	83 f8 5e             	cmp    $0x5e,%eax
  8018f1:	76 c6                	jbe    8018b9 <vprintfmt+0x1d7>
					putch('?', putdat);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	6a 3f                	push   $0x3f
  8018f9:	ff d6                	call   *%esi
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	eb c3                	jmp    8018c3 <vprintfmt+0x1e1>
  801900:	89 cf                	mov    %ecx,%edi
  801902:	eb 0e                	jmp    801912 <vprintfmt+0x230>
				putch(' ', putdat);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	53                   	push   %ebx
  801908:	6a 20                	push   $0x20
  80190a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80190c:	83 ef 01             	sub    $0x1,%edi
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 ff                	test   %edi,%edi
  801914:	7f ee                	jg     801904 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801916:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801919:	89 45 14             	mov    %eax,0x14(%ebp)
  80191c:	e9 67 01 00 00       	jmp    801a88 <vprintfmt+0x3a6>
  801921:	89 cf                	mov    %ecx,%edi
  801923:	eb ed                	jmp    801912 <vprintfmt+0x230>
	if (lflag >= 2)
  801925:	83 f9 01             	cmp    $0x1,%ecx
  801928:	7f 1b                	jg     801945 <vprintfmt+0x263>
	else if (lflag)
  80192a:	85 c9                	test   %ecx,%ecx
  80192c:	74 63                	je     801991 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80192e:	8b 45 14             	mov    0x14(%ebp),%eax
  801931:	8b 00                	mov    (%eax),%eax
  801933:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801936:	99                   	cltd   
  801937:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80193a:	8b 45 14             	mov    0x14(%ebp),%eax
  80193d:	8d 40 04             	lea    0x4(%eax),%eax
  801940:	89 45 14             	mov    %eax,0x14(%ebp)
  801943:	eb 17                	jmp    80195c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801945:	8b 45 14             	mov    0x14(%ebp),%eax
  801948:	8b 50 04             	mov    0x4(%eax),%edx
  80194b:	8b 00                	mov    (%eax),%eax
  80194d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801950:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801953:	8b 45 14             	mov    0x14(%ebp),%eax
  801956:	8d 40 08             	lea    0x8(%eax),%eax
  801959:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80195c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80195f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801962:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801967:	85 c9                	test   %ecx,%ecx
  801969:	0f 89 ff 00 00 00    	jns    801a6e <vprintfmt+0x38c>
				putch('-', putdat);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	53                   	push   %ebx
  801973:	6a 2d                	push   $0x2d
  801975:	ff d6                	call   *%esi
				num = -(long long) num;
  801977:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80197a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80197d:	f7 da                	neg    %edx
  80197f:	83 d1 00             	adc    $0x0,%ecx
  801982:	f7 d9                	neg    %ecx
  801984:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801987:	b8 0a 00 00 00       	mov    $0xa,%eax
  80198c:	e9 dd 00 00 00       	jmp    801a6e <vprintfmt+0x38c>
		return va_arg(*ap, int);
  801991:	8b 45 14             	mov    0x14(%ebp),%eax
  801994:	8b 00                	mov    (%eax),%eax
  801996:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801999:	99                   	cltd   
  80199a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80199d:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a0:	8d 40 04             	lea    0x4(%eax),%eax
  8019a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8019a6:	eb b4                	jmp    80195c <vprintfmt+0x27a>
	if (lflag >= 2)
  8019a8:	83 f9 01             	cmp    $0x1,%ecx
  8019ab:	7f 1e                	jg     8019cb <vprintfmt+0x2e9>
	else if (lflag)
  8019ad:	85 c9                	test   %ecx,%ecx
  8019af:	74 32                	je     8019e3 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b4:	8b 10                	mov    (%eax),%edx
  8019b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019bb:	8d 40 04             	lea    0x4(%eax),%eax
  8019be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019c6:	e9 a3 00 00 00       	jmp    801a6e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ce:	8b 10                	mov    (%eax),%edx
  8019d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8019d3:	8d 40 08             	lea    0x8(%eax),%eax
  8019d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019d9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8019de:	e9 8b 00 00 00       	jmp    801a6e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8019e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e6:	8b 10                	mov    (%eax),%edx
  8019e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ed:	8d 40 04             	lea    0x4(%eax),%eax
  8019f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019f3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8019f8:	eb 74                	jmp    801a6e <vprintfmt+0x38c>
	if (lflag >= 2)
  8019fa:	83 f9 01             	cmp    $0x1,%ecx
  8019fd:	7f 1b                	jg     801a1a <vprintfmt+0x338>
	else if (lflag)
  8019ff:	85 c9                	test   %ecx,%ecx
  801a01:	74 2c                	je     801a2f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801a03:	8b 45 14             	mov    0x14(%ebp),%eax
  801a06:	8b 10                	mov    (%eax),%edx
  801a08:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0d:	8d 40 04             	lea    0x4(%eax),%eax
  801a10:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a13:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a18:	eb 54                	jmp    801a6e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1d:	8b 10                	mov    (%eax),%edx
  801a1f:	8b 48 04             	mov    0x4(%eax),%ecx
  801a22:	8d 40 08             	lea    0x8(%eax),%eax
  801a25:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a28:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a2d:	eb 3f                	jmp    801a6e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a32:	8b 10                	mov    (%eax),%edx
  801a34:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a39:	8d 40 04             	lea    0x4(%eax),%eax
  801a3c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a3f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a44:	eb 28                	jmp    801a6e <vprintfmt+0x38c>
			putch('0', putdat);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	53                   	push   %ebx
  801a4a:	6a 30                	push   $0x30
  801a4c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a4e:	83 c4 08             	add    $0x8,%esp
  801a51:	53                   	push   %ebx
  801a52:	6a 78                	push   $0x78
  801a54:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a56:	8b 45 14             	mov    0x14(%ebp),%eax
  801a59:	8b 10                	mov    (%eax),%edx
  801a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a60:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a63:	8d 40 04             	lea    0x4(%eax),%eax
  801a66:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a69:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a75:	57                   	push   %edi
  801a76:	ff 75 e0             	pushl  -0x20(%ebp)
  801a79:	50                   	push   %eax
  801a7a:	51                   	push   %ecx
  801a7b:	52                   	push   %edx
  801a7c:	89 da                	mov    %ebx,%edx
  801a7e:	89 f0                	mov    %esi,%eax
  801a80:	e8 72 fb ff ff       	call   8015f7 <printnum>
			break;
  801a85:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801a88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801a8b:	83 c7 01             	add    $0x1,%edi
  801a8e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a92:	83 f8 25             	cmp    $0x25,%eax
  801a95:	0f 84 62 fc ff ff    	je     8016fd <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	0f 84 8b 00 00 00    	je     801b2e <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	53                   	push   %ebx
  801aa7:	50                   	push   %eax
  801aa8:	ff d6                	call   *%esi
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	eb dc                	jmp    801a8b <vprintfmt+0x3a9>
	if (lflag >= 2)
  801aaf:	83 f9 01             	cmp    $0x1,%ecx
  801ab2:	7f 1b                	jg     801acf <vprintfmt+0x3ed>
	else if (lflag)
  801ab4:	85 c9                	test   %ecx,%ecx
  801ab6:	74 2c                	je     801ae4 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  801abb:	8b 10                	mov    (%eax),%edx
  801abd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ac2:	8d 40 04             	lea    0x4(%eax),%eax
  801ac5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ac8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801acd:	eb 9f                	jmp    801a6e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801acf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad2:	8b 10                	mov    (%eax),%edx
  801ad4:	8b 48 04             	mov    0x4(%eax),%ecx
  801ad7:	8d 40 08             	lea    0x8(%eax),%eax
  801ada:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801add:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801ae2:	eb 8a                	jmp    801a6e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801ae4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae7:	8b 10                	mov    (%eax),%edx
  801ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aee:	8d 40 04             	lea    0x4(%eax),%eax
  801af1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801af4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801af9:	e9 70 ff ff ff       	jmp    801a6e <vprintfmt+0x38c>
			putch(ch, putdat);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	53                   	push   %ebx
  801b02:	6a 25                	push   $0x25
  801b04:	ff d6                	call   *%esi
			break;
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	e9 7a ff ff ff       	jmp    801a88 <vprintfmt+0x3a6>
			putch('%', putdat);
  801b0e:	83 ec 08             	sub    $0x8,%esp
  801b11:	53                   	push   %ebx
  801b12:	6a 25                	push   $0x25
  801b14:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	89 f8                	mov    %edi,%eax
  801b1b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b1f:	74 05                	je     801b26 <vprintfmt+0x444>
  801b21:	83 e8 01             	sub    $0x1,%eax
  801b24:	eb f5                	jmp    801b1b <vprintfmt+0x439>
  801b26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b29:	e9 5a ff ff ff       	jmp    801a88 <vprintfmt+0x3a6>
}
  801b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b36:	f3 0f 1e fb          	endbr32 
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	83 ec 18             	sub    $0x18,%esp
  801b40:	8b 45 08             	mov    0x8(%ebp),%eax
  801b43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b57:	85 c0                	test   %eax,%eax
  801b59:	74 26                	je     801b81 <vsnprintf+0x4b>
  801b5b:	85 d2                	test   %edx,%edx
  801b5d:	7e 22                	jle    801b81 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b5f:	ff 75 14             	pushl  0x14(%ebp)
  801b62:	ff 75 10             	pushl  0x10(%ebp)
  801b65:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b68:	50                   	push   %eax
  801b69:	68 a0 16 80 00       	push   $0x8016a0
  801b6e:	e8 6f fb ff ff       	call   8016e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b76:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	83 c4 10             	add    $0x10,%esp
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    
		return -E_INVAL;
  801b81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b86:	eb f7                	jmp    801b7f <vsnprintf+0x49>

00801b88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b88:	f3 0f 1e fb          	endbr32 
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801b92:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b95:	50                   	push   %eax
  801b96:	ff 75 10             	pushl  0x10(%ebp)
  801b99:	ff 75 0c             	pushl  0xc(%ebp)
  801b9c:	ff 75 08             	pushl  0x8(%ebp)
  801b9f:	e8 92 ff ff ff       	call   801b36 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ba6:	f3 0f 1e fb          	endbr32 
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bb9:	74 05                	je     801bc0 <strlen+0x1a>
		n++;
  801bbb:	83 c0 01             	add    $0x1,%eax
  801bbe:	eb f5                	jmp    801bb5 <strlen+0xf>
	return n;
}
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bc2:	f3 0f 1e fb          	endbr32 
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd4:	39 d0                	cmp    %edx,%eax
  801bd6:	74 0d                	je     801be5 <strnlen+0x23>
  801bd8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801bdc:	74 05                	je     801be3 <strnlen+0x21>
		n++;
  801bde:	83 c0 01             	add    $0x1,%eax
  801be1:	eb f1                	jmp    801bd4 <strnlen+0x12>
  801be3:	89 c2                	mov    %eax,%edx
	return n;
}
  801be5:	89 d0                	mov    %edx,%eax
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801be9:	f3 0f 1e fb          	endbr32 
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	53                   	push   %ebx
  801bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801c00:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801c03:	83 c0 01             	add    $0x1,%eax
  801c06:	84 d2                	test   %dl,%dl
  801c08:	75 f2                	jne    801bfc <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c0a:	89 c8                	mov    %ecx,%eax
  801c0c:	5b                   	pop    %ebx
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c0f:	f3 0f 1e fb          	endbr32 
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	53                   	push   %ebx
  801c17:	83 ec 10             	sub    $0x10,%esp
  801c1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c1d:	53                   	push   %ebx
  801c1e:	e8 83 ff ff ff       	call   801ba6 <strlen>
  801c23:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c26:	ff 75 0c             	pushl  0xc(%ebp)
  801c29:	01 d8                	add    %ebx,%eax
  801c2b:	50                   	push   %eax
  801c2c:	e8 b8 ff ff ff       	call   801be9 <strcpy>
	return dst;
}
  801c31:	89 d8                	mov    %ebx,%eax
  801c33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c38:	f3 0f 1e fb          	endbr32 
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	56                   	push   %esi
  801c40:	53                   	push   %ebx
  801c41:	8b 75 08             	mov    0x8(%ebp),%esi
  801c44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c47:	89 f3                	mov    %esi,%ebx
  801c49:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c4c:	89 f0                	mov    %esi,%eax
  801c4e:	39 d8                	cmp    %ebx,%eax
  801c50:	74 11                	je     801c63 <strncpy+0x2b>
		*dst++ = *src;
  801c52:	83 c0 01             	add    $0x1,%eax
  801c55:	0f b6 0a             	movzbl (%edx),%ecx
  801c58:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c5b:	80 f9 01             	cmp    $0x1,%cl
  801c5e:	83 da ff             	sbb    $0xffffffff,%edx
  801c61:	eb eb                	jmp    801c4e <strncpy+0x16>
	}
	return ret;
}
  801c63:	89 f0                	mov    %esi,%eax
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c69:	f3 0f 1e fb          	endbr32 
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	8b 75 08             	mov    0x8(%ebp),%esi
  801c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c78:	8b 55 10             	mov    0x10(%ebp),%edx
  801c7b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c7d:	85 d2                	test   %edx,%edx
  801c7f:	74 21                	je     801ca2 <strlcpy+0x39>
  801c81:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c85:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801c87:	39 c2                	cmp    %eax,%edx
  801c89:	74 14                	je     801c9f <strlcpy+0x36>
  801c8b:	0f b6 19             	movzbl (%ecx),%ebx
  801c8e:	84 db                	test   %bl,%bl
  801c90:	74 0b                	je     801c9d <strlcpy+0x34>
			*dst++ = *src++;
  801c92:	83 c1 01             	add    $0x1,%ecx
  801c95:	83 c2 01             	add    $0x1,%edx
  801c98:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c9b:	eb ea                	jmp    801c87 <strlcpy+0x1e>
  801c9d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c9f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ca2:	29 f0                	sub    %esi,%eax
}
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ca8:	f3 0f 1e fb          	endbr32 
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cb5:	0f b6 01             	movzbl (%ecx),%eax
  801cb8:	84 c0                	test   %al,%al
  801cba:	74 0c                	je     801cc8 <strcmp+0x20>
  801cbc:	3a 02                	cmp    (%edx),%al
  801cbe:	75 08                	jne    801cc8 <strcmp+0x20>
		p++, q++;
  801cc0:	83 c1 01             	add    $0x1,%ecx
  801cc3:	83 c2 01             	add    $0x1,%edx
  801cc6:	eb ed                	jmp    801cb5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc8:	0f b6 c0             	movzbl %al,%eax
  801ccb:	0f b6 12             	movzbl (%edx),%edx
  801cce:	29 d0                	sub    %edx,%eax
}
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cd2:	f3 0f 1e fb          	endbr32 
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	53                   	push   %ebx
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce0:	89 c3                	mov    %eax,%ebx
  801ce2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ce5:	eb 06                	jmp    801ced <strncmp+0x1b>
		n--, p++, q++;
  801ce7:	83 c0 01             	add    $0x1,%eax
  801cea:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801ced:	39 d8                	cmp    %ebx,%eax
  801cef:	74 16                	je     801d07 <strncmp+0x35>
  801cf1:	0f b6 08             	movzbl (%eax),%ecx
  801cf4:	84 c9                	test   %cl,%cl
  801cf6:	74 04                	je     801cfc <strncmp+0x2a>
  801cf8:	3a 0a                	cmp    (%edx),%cl
  801cfa:	74 eb                	je     801ce7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cfc:	0f b6 00             	movzbl (%eax),%eax
  801cff:	0f b6 12             	movzbl (%edx),%edx
  801d02:	29 d0                	sub    %edx,%eax
}
  801d04:	5b                   	pop    %ebx
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    
		return 0;
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0c:	eb f6                	jmp    801d04 <strncmp+0x32>

00801d0e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d0e:	f3 0f 1e fb          	endbr32 
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d1c:	0f b6 10             	movzbl (%eax),%edx
  801d1f:	84 d2                	test   %dl,%dl
  801d21:	74 09                	je     801d2c <strchr+0x1e>
		if (*s == c)
  801d23:	38 ca                	cmp    %cl,%dl
  801d25:	74 0a                	je     801d31 <strchr+0x23>
	for (; *s; s++)
  801d27:	83 c0 01             	add    $0x1,%eax
  801d2a:	eb f0                	jmp    801d1c <strchr+0xe>
			return (char *) s;
	return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d33:	f3 0f 1e fb          	endbr32 
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d3d:	6a 78                	push   $0x78
  801d3f:	ff 75 08             	pushl  0x8(%ebp)
  801d42:	e8 c7 ff ff ff       	call   801d0e <strchr>
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d52:	eb 0d                	jmp    801d61 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d54:	c1 e0 04             	shl    $0x4,%eax
  801d57:	0f be d2             	movsbl %dl,%edx
  801d5a:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d5e:	83 c1 01             	add    $0x1,%ecx
  801d61:	0f b6 11             	movzbl (%ecx),%edx
  801d64:	84 d2                	test   %dl,%dl
  801d66:	74 11                	je     801d79 <atox+0x46>
		if (*p>='a'){
  801d68:	80 fa 60             	cmp    $0x60,%dl
  801d6b:	7e e7                	jle    801d54 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d6d:	c1 e0 04             	shl    $0x4,%eax
  801d70:	0f be d2             	movsbl %dl,%edx
  801d73:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d77:	eb e5                	jmp    801d5e <atox+0x2b>
	}

	return v;

}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    

00801d7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d7b:	f3 0f 1e fb          	endbr32 
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	8b 45 08             	mov    0x8(%ebp),%eax
  801d85:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d89:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d8c:	38 ca                	cmp    %cl,%dl
  801d8e:	74 09                	je     801d99 <strfind+0x1e>
  801d90:	84 d2                	test   %dl,%dl
  801d92:	74 05                	je     801d99 <strfind+0x1e>
	for (; *s; s++)
  801d94:	83 c0 01             	add    $0x1,%eax
  801d97:	eb f0                	jmp    801d89 <strfind+0xe>
			break;
	return (char *) s;
}
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d9b:	f3 0f 1e fb          	endbr32 
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	57                   	push   %edi
  801da3:	56                   	push   %esi
  801da4:	53                   	push   %ebx
  801da5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801da8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801dab:	85 c9                	test   %ecx,%ecx
  801dad:	74 31                	je     801de0 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	09 c8                	or     %ecx,%eax
  801db3:	a8 03                	test   $0x3,%al
  801db5:	75 23                	jne    801dda <memset+0x3f>
		c &= 0xFF;
  801db7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801dbb:	89 d3                	mov    %edx,%ebx
  801dbd:	c1 e3 08             	shl    $0x8,%ebx
  801dc0:	89 d0                	mov    %edx,%eax
  801dc2:	c1 e0 18             	shl    $0x18,%eax
  801dc5:	89 d6                	mov    %edx,%esi
  801dc7:	c1 e6 10             	shl    $0x10,%esi
  801dca:	09 f0                	or     %esi,%eax
  801dcc:	09 c2                	or     %eax,%edx
  801dce:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801dd0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801dd3:	89 d0                	mov    %edx,%eax
  801dd5:	fc                   	cld    
  801dd6:	f3 ab                	rep stos %eax,%es:(%edi)
  801dd8:	eb 06                	jmp    801de0 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddd:	fc                   	cld    
  801dde:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801de0:	89 f8                	mov    %edi,%eax
  801de2:	5b                   	pop    %ebx
  801de3:	5e                   	pop    %esi
  801de4:	5f                   	pop    %edi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801de7:	f3 0f 1e fb          	endbr32 
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	8b 45 08             	mov    0x8(%ebp),%eax
  801df3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801df6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801df9:	39 c6                	cmp    %eax,%esi
  801dfb:	73 32                	jae    801e2f <memmove+0x48>
  801dfd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e00:	39 c2                	cmp    %eax,%edx
  801e02:	76 2b                	jbe    801e2f <memmove+0x48>
		s += n;
		d += n;
  801e04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e07:	89 fe                	mov    %edi,%esi
  801e09:	09 ce                	or     %ecx,%esi
  801e0b:	09 d6                	or     %edx,%esi
  801e0d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e13:	75 0e                	jne    801e23 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e15:	83 ef 04             	sub    $0x4,%edi
  801e18:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e1e:	fd                   	std    
  801e1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e21:	eb 09                	jmp    801e2c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e23:	83 ef 01             	sub    $0x1,%edi
  801e26:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e29:	fd                   	std    
  801e2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e2c:	fc                   	cld    
  801e2d:	eb 1a                	jmp    801e49 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e2f:	89 c2                	mov    %eax,%edx
  801e31:	09 ca                	or     %ecx,%edx
  801e33:	09 f2                	or     %esi,%edx
  801e35:	f6 c2 03             	test   $0x3,%dl
  801e38:	75 0a                	jne    801e44 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e3a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e3d:	89 c7                	mov    %eax,%edi
  801e3f:	fc                   	cld    
  801e40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e42:	eb 05                	jmp    801e49 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e44:	89 c7                	mov    %eax,%edi
  801e46:	fc                   	cld    
  801e47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e49:	5e                   	pop    %esi
  801e4a:	5f                   	pop    %edi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    

00801e4d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e4d:	f3 0f 1e fb          	endbr32 
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e57:	ff 75 10             	pushl  0x10(%ebp)
  801e5a:	ff 75 0c             	pushl  0xc(%ebp)
  801e5d:	ff 75 08             	pushl  0x8(%ebp)
  801e60:	e8 82 ff ff ff       	call   801de7 <memmove>
}
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e67:	f3 0f 1e fb          	endbr32 
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	56                   	push   %esi
  801e6f:	53                   	push   %ebx
  801e70:	8b 45 08             	mov    0x8(%ebp),%eax
  801e73:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e76:	89 c6                	mov    %eax,%esi
  801e78:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e7b:	39 f0                	cmp    %esi,%eax
  801e7d:	74 1c                	je     801e9b <memcmp+0x34>
		if (*s1 != *s2)
  801e7f:	0f b6 08             	movzbl (%eax),%ecx
  801e82:	0f b6 1a             	movzbl (%edx),%ebx
  801e85:	38 d9                	cmp    %bl,%cl
  801e87:	75 08                	jne    801e91 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801e89:	83 c0 01             	add    $0x1,%eax
  801e8c:	83 c2 01             	add    $0x1,%edx
  801e8f:	eb ea                	jmp    801e7b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801e91:	0f b6 c1             	movzbl %cl,%eax
  801e94:	0f b6 db             	movzbl %bl,%ebx
  801e97:	29 d8                	sub    %ebx,%eax
  801e99:	eb 05                	jmp    801ea0 <memcmp+0x39>
	}

	return 0;
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea0:	5b                   	pop    %ebx
  801ea1:	5e                   	pop    %esi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ea4:	f3 0f 1e fb          	endbr32 
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801eb1:	89 c2                	mov    %eax,%edx
  801eb3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801eb6:	39 d0                	cmp    %edx,%eax
  801eb8:	73 09                	jae    801ec3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801eba:	38 08                	cmp    %cl,(%eax)
  801ebc:	74 05                	je     801ec3 <memfind+0x1f>
	for (; s < ends; s++)
  801ebe:	83 c0 01             	add    $0x1,%eax
  801ec1:	eb f3                	jmp    801eb6 <memfind+0x12>
			break;
	return (void *) s;
}
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    

00801ec5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ec5:	f3 0f 1e fb          	endbr32 
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	57                   	push   %edi
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
  801ecf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ed5:	eb 03                	jmp    801eda <strtol+0x15>
		s++;
  801ed7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801eda:	0f b6 01             	movzbl (%ecx),%eax
  801edd:	3c 20                	cmp    $0x20,%al
  801edf:	74 f6                	je     801ed7 <strtol+0x12>
  801ee1:	3c 09                	cmp    $0x9,%al
  801ee3:	74 f2                	je     801ed7 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801ee5:	3c 2b                	cmp    $0x2b,%al
  801ee7:	74 2a                	je     801f13 <strtol+0x4e>
	int neg = 0;
  801ee9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801eee:	3c 2d                	cmp    $0x2d,%al
  801ef0:	74 2b                	je     801f1d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ef2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ef8:	75 0f                	jne    801f09 <strtol+0x44>
  801efa:	80 39 30             	cmpb   $0x30,(%ecx)
  801efd:	74 28                	je     801f27 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801eff:	85 db                	test   %ebx,%ebx
  801f01:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f06:	0f 44 d8             	cmove  %eax,%ebx
  801f09:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f11:	eb 46                	jmp    801f59 <strtol+0x94>
		s++;
  801f13:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f16:	bf 00 00 00 00       	mov    $0x0,%edi
  801f1b:	eb d5                	jmp    801ef2 <strtol+0x2d>
		s++, neg = 1;
  801f1d:	83 c1 01             	add    $0x1,%ecx
  801f20:	bf 01 00 00 00       	mov    $0x1,%edi
  801f25:	eb cb                	jmp    801ef2 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f2b:	74 0e                	je     801f3b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f2d:	85 db                	test   %ebx,%ebx
  801f2f:	75 d8                	jne    801f09 <strtol+0x44>
		s++, base = 8;
  801f31:	83 c1 01             	add    $0x1,%ecx
  801f34:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f39:	eb ce                	jmp    801f09 <strtol+0x44>
		s += 2, base = 16;
  801f3b:	83 c1 02             	add    $0x2,%ecx
  801f3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f43:	eb c4                	jmp    801f09 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f45:	0f be d2             	movsbl %dl,%edx
  801f48:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f4e:	7d 3a                	jge    801f8a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f50:	83 c1 01             	add    $0x1,%ecx
  801f53:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f57:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f59:	0f b6 11             	movzbl (%ecx),%edx
  801f5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f5f:	89 f3                	mov    %esi,%ebx
  801f61:	80 fb 09             	cmp    $0x9,%bl
  801f64:	76 df                	jbe    801f45 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f66:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f69:	89 f3                	mov    %esi,%ebx
  801f6b:	80 fb 19             	cmp    $0x19,%bl
  801f6e:	77 08                	ja     801f78 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f70:	0f be d2             	movsbl %dl,%edx
  801f73:	83 ea 57             	sub    $0x57,%edx
  801f76:	eb d3                	jmp    801f4b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f78:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f7b:	89 f3                	mov    %esi,%ebx
  801f7d:	80 fb 19             	cmp    $0x19,%bl
  801f80:	77 08                	ja     801f8a <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f82:	0f be d2             	movsbl %dl,%edx
  801f85:	83 ea 37             	sub    $0x37,%edx
  801f88:	eb c1                	jmp    801f4b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801f8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f8e:	74 05                	je     801f95 <strtol+0xd0>
		*endptr = (char *) s;
  801f90:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f93:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801f95:	89 c2                	mov    %eax,%edx
  801f97:	f7 da                	neg    %edx
  801f99:	85 ff                	test   %edi,%edi
  801f9b:	0f 45 c2             	cmovne %edx,%eax
}
  801f9e:	5b                   	pop    %ebx
  801f9f:	5e                   	pop    %esi
  801fa0:	5f                   	pop    %edi
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    

00801fa3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fa3:	f3 0f 1e fb          	endbr32 
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	56                   	push   %esi
  801fab:	53                   	push   %ebx
  801fac:	8b 75 08             	mov    0x8(%ebp),%esi
  801faf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fbc:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fbf:	83 ec 0c             	sub    $0xc,%esp
  801fc2:	50                   	push   %eax
  801fc3:	e8 97 e2 ff ff       	call   80025f <sys_ipc_recv>
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	75 2b                	jne    801ffa <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fcf:	85 f6                	test   %esi,%esi
  801fd1:	74 0a                	je     801fdd <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fd3:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd8:	8b 40 74             	mov    0x74(%eax),%eax
  801fdb:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fdd:	85 db                	test   %ebx,%ebx
  801fdf:	74 0a                	je     801feb <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801fe1:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe6:	8b 40 78             	mov    0x78(%eax),%eax
  801fe9:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801feb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ff3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff6:	5b                   	pop    %ebx
  801ff7:	5e                   	pop    %esi
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  801ffa:	85 f6                	test   %esi,%esi
  801ffc:	74 06                	je     802004 <ipc_recv+0x61>
  801ffe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802004:	85 db                	test   %ebx,%ebx
  802006:	74 eb                	je     801ff3 <ipc_recv+0x50>
  802008:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80200e:	eb e3                	jmp    801ff3 <ipc_recv+0x50>

00802010 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	57                   	push   %edi
  802018:	56                   	push   %esi
  802019:	53                   	push   %ebx
  80201a:	83 ec 0c             	sub    $0xc,%esp
  80201d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802020:	8b 75 0c             	mov    0xc(%ebp),%esi
  802023:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802026:	85 db                	test   %ebx,%ebx
  802028:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80202d:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802030:	ff 75 14             	pushl  0x14(%ebp)
  802033:	53                   	push   %ebx
  802034:	56                   	push   %esi
  802035:	57                   	push   %edi
  802036:	e8 fd e1 ff ff       	call   800238 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80203b:	83 c4 10             	add    $0x10,%esp
  80203e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802041:	75 07                	jne    80204a <ipc_send+0x3a>
			sys_yield();
  802043:	e8 ee e0 ff ff       	call   800136 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802048:	eb e6                	jmp    802030 <ipc_send+0x20>
		}
		else if (ret == 0)
  80204a:	85 c0                	test   %eax,%eax
  80204c:	75 08                	jne    802056 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80204e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802051:	5b                   	pop    %ebx
  802052:	5e                   	pop    %esi
  802053:	5f                   	pop    %edi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802056:	50                   	push   %eax
  802057:	68 1f 28 80 00       	push   $0x80281f
  80205c:	6a 48                	push   $0x48
  80205e:	68 2d 28 80 00       	push   $0x80282d
  802063:	e8 90 f4 ff ff       	call   8014f8 <_panic>

00802068 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802068:	f3 0f 1e fb          	endbr32 
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802072:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802077:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80207a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802080:	8b 52 50             	mov    0x50(%edx),%edx
  802083:	39 ca                	cmp    %ecx,%edx
  802085:	74 11                	je     802098 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802087:	83 c0 01             	add    $0x1,%eax
  80208a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208f:	75 e6                	jne    802077 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802091:	b8 00 00 00 00       	mov    $0x0,%eax
  802096:	eb 0b                	jmp    8020a3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802098:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80209b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020a0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020a3:	5d                   	pop    %ebp
  8020a4:	c3                   	ret    

008020a5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a5:	f3 0f 1e fb          	endbr32 
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020af:	89 c2                	mov    %eax,%edx
  8020b1:	c1 ea 16             	shr    $0x16,%edx
  8020b4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020bb:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020c0:	f6 c1 01             	test   $0x1,%cl
  8020c3:	74 1c                	je     8020e1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020c5:	c1 e8 0c             	shr    $0xc,%eax
  8020c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020cf:	a8 01                	test   $0x1,%al
  8020d1:	74 0e                	je     8020e1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d3:	c1 e8 0c             	shr    $0xc,%eax
  8020d6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020dd:	ef 
  8020de:	0f b7 d2             	movzwl %dx,%edx
}
  8020e1:	89 d0                	mov    %edx,%eax
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    
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
