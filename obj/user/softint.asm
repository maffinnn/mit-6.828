
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 bd 00 00 00       	call   80010b <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x31>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	f3 0f 1e fb          	endbr32 
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80008e:	e8 49 04 00 00       	call   8004dc <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 4a 00 00 00       	call   8000e7 <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	f3 0f 1e fb          	endbr32 
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	89 cb                	mov    %ecx,%ebx
  800100:	89 cf                	mov    %ecx,%edi
  800102:	89 ce                	mov    %ecx,%esi
  800104:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010b:	f3 0f 1e fb          	endbr32 
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	f3 0f 1e fb          	endbr32 
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800151:	f3 0f 1e fb          	endbr32 
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800166:	b8 04 00 00 00       	mov    $0x4,%eax
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5f                   	pop    %edi
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800177:	f3 0f 1e fb          	endbr32 
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	57                   	push   %edi
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
	asm volatile("int %1\n"
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800187:	b8 05 00 00 00       	mov    $0x5,%eax
  80018c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800192:	8b 75 18             	mov    0x18(%ebp),%esi
  800195:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800197:	5b                   	pop    %ebx
  800198:	5e                   	pop    %esi
  800199:	5f                   	pop    %edi
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80019c:	f3 0f 1e fb          	endbr32 
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001b6:	89 df                	mov    %ebx,%edi
  8001b8:	89 de                	mov    %ebx,%esi
  8001ba:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001bc:	5b                   	pop    %ebx
  8001bd:	5e                   	pop    %esi
  8001be:	5f                   	pop    %edi
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001c1:	f3 0f 1e fb          	endbr32 
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8001db:	89 df                	mov    %ebx,%edi
  8001dd:	89 de                	mov    %ebx,%esi
  8001df:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5f                   	pop    %edi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001e6:	f3 0f 1e fb          	endbr32 
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	57                   	push   %edi
  8001ee:	56                   	push   %esi
  8001ef:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	b8 09 00 00 00       	mov    $0x9,%eax
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5f                   	pop    %edi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80020b:	f3 0f 1e fb          	endbr32 
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
	asm volatile("int %1\n"
  800215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021a:	8b 55 08             	mov    0x8(%ebp),%edx
  80021d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800220:	b8 0a 00 00 00       	mov    $0xa,%eax
  800225:	89 df                	mov    %ebx,%edi
  800227:	89 de                	mov    %ebx,%esi
  800229:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800230:	f3 0f 1e fb          	endbr32 
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
	asm volatile("int %1\n"
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	b8 0c 00 00 00       	mov    $0xc,%eax
  800245:	be 00 00 00 00       	mov    $0x0,%esi
  80024a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80024d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800250:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800257:	f3 0f 1e fb          	endbr32 
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
	asm volatile("int %1\n"
  800261:	b9 00 00 00 00       	mov    $0x0,%ecx
  800266:	8b 55 08             	mov    0x8(%ebp),%edx
  800269:	b8 0d 00 00 00       	mov    $0xd,%eax
  80026e:	89 cb                	mov    %ecx,%ebx
  800270:	89 cf                	mov    %ecx,%edi
  800272:	89 ce                	mov    %ecx,%esi
  800274:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80027b:	f3 0f 1e fb          	endbr32 
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
	asm volatile("int %1\n"
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
  80028a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80028f:	89 d1                	mov    %edx,%ecx
  800291:	89 d3                	mov    %edx,%ebx
  800293:	89 d7                	mov    %edx,%edi
  800295:	89 d6                	mov    %edx,%esi
  800297:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  80029e:	f3 0f 1e fb          	endbr32 
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002c3:	f3 0f 1e fb          	endbr32 
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	57                   	push   %edi
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8002dd:	89 df                	mov    %ebx,%edi
  8002df:	89 de                	mov    %ebx,%esi
  8002e1:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002e8:	f3 0f 1e fb          	endbr32 
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8002f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8002fc:	f3 0f 1e fb          	endbr32 
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80030b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800310:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800317:	f3 0f 1e fb          	endbr32 
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800323:	89 c2                	mov    %eax,%edx
  800325:	c1 ea 16             	shr    $0x16,%edx
  800328:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80032f:	f6 c2 01             	test   $0x1,%dl
  800332:	74 2d                	je     800361 <fd_alloc+0x4a>
  800334:	89 c2                	mov    %eax,%edx
  800336:	c1 ea 0c             	shr    $0xc,%edx
  800339:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800340:	f6 c2 01             	test   $0x1,%dl
  800343:	74 1c                	je     800361 <fd_alloc+0x4a>
  800345:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80034a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80034f:	75 d2                	jne    800323 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80035a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80035f:	eb 0a                	jmp    80036b <fd_alloc+0x54>
			*fd_store = fd;
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	89 01                	mov    %eax,(%ecx)
			return 0;
  800366:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80036d:	f3 0f 1e fb          	endbr32 
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800377:	83 f8 1f             	cmp    $0x1f,%eax
  80037a:	77 30                	ja     8003ac <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80037c:	c1 e0 0c             	shl    $0xc,%eax
  80037f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800384:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80038a:	f6 c2 01             	test   $0x1,%dl
  80038d:	74 24                	je     8003b3 <fd_lookup+0x46>
  80038f:	89 c2                	mov    %eax,%edx
  800391:	c1 ea 0c             	shr    $0xc,%edx
  800394:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039b:	f6 c2 01             	test   $0x1,%dl
  80039e:	74 1a                	je     8003ba <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a3:	89 02                	mov    %eax,(%edx)
	return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    
		return -E_INVAL;
  8003ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003b1:	eb f7                	jmp    8003aa <fd_lookup+0x3d>
		return -E_INVAL;
  8003b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003b8:	eb f0                	jmp    8003aa <fd_lookup+0x3d>
  8003ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003bf:	eb e9                	jmp    8003aa <fd_lookup+0x3d>

008003c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003c1:	f3 0f 1e fb          	endbr32 
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d3:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003d8:	39 08                	cmp    %ecx,(%eax)
  8003da:	74 38                	je     800414 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8003dc:	83 c2 01             	add    $0x1,%edx
  8003df:	8b 04 95 c8 23 80 00 	mov    0x8023c8(,%edx,4),%eax
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	75 ee                	jne    8003d8 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003ea:	a1 08 40 80 00       	mov    0x804008,%eax
  8003ef:	8b 40 48             	mov    0x48(%eax),%eax
  8003f2:	83 ec 04             	sub    $0x4,%esp
  8003f5:	51                   	push   %ecx
  8003f6:	50                   	push   %eax
  8003f7:	68 4c 23 80 00       	push   $0x80234c
  8003fc:	e8 d6 11 00 00       	call   8015d7 <cprintf>
	*dev = 0;
  800401:	8b 45 0c             	mov    0xc(%ebp),%eax
  800404:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    
			*dev = devtab[i];
  800414:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800417:	89 01                	mov    %eax,(%ecx)
			return 0;
  800419:	b8 00 00 00 00       	mov    $0x0,%eax
  80041e:	eb f2                	jmp    800412 <dev_lookup+0x51>

00800420 <fd_close>:
{
  800420:	f3 0f 1e fb          	endbr32 
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 24             	sub    $0x24,%esp
  80042d:	8b 75 08             	mov    0x8(%ebp),%esi
  800430:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800433:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800436:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800437:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80043d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800440:	50                   	push   %eax
  800441:	e8 27 ff ff ff       	call   80036d <fd_lookup>
  800446:	89 c3                	mov    %eax,%ebx
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	85 c0                	test   %eax,%eax
  80044d:	78 05                	js     800454 <fd_close+0x34>
	    || fd != fd2)
  80044f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800452:	74 16                	je     80046a <fd_close+0x4a>
		return (must_exist ? r : 0);
  800454:	89 f8                	mov    %edi,%eax
  800456:	84 c0                	test   %al,%al
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	0f 44 d8             	cmove  %eax,%ebx
}
  800460:	89 d8                	mov    %ebx,%eax
  800462:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800465:	5b                   	pop    %ebx
  800466:	5e                   	pop    %esi
  800467:	5f                   	pop    %edi
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800470:	50                   	push   %eax
  800471:	ff 36                	pushl  (%esi)
  800473:	e8 49 ff ff ff       	call   8003c1 <dev_lookup>
  800478:	89 c3                	mov    %eax,%ebx
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	85 c0                	test   %eax,%eax
  80047f:	78 1a                	js     80049b <fd_close+0x7b>
		if (dev->dev_close)
  800481:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800484:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800487:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80048c:	85 c0                	test   %eax,%eax
  80048e:	74 0b                	je     80049b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800490:	83 ec 0c             	sub    $0xc,%esp
  800493:	56                   	push   %esi
  800494:	ff d0                	call   *%eax
  800496:	89 c3                	mov    %eax,%ebx
  800498:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	56                   	push   %esi
  80049f:	6a 00                	push   $0x0
  8004a1:	e8 f6 fc ff ff       	call   80019c <sys_page_unmap>
	return r;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	eb b5                	jmp    800460 <fd_close+0x40>

008004ab <close>:

int
close(int fdnum)
{
  8004ab:	f3 0f 1e fb          	endbr32 
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b8:	50                   	push   %eax
  8004b9:	ff 75 08             	pushl  0x8(%ebp)
  8004bc:	e8 ac fe ff ff       	call   80036d <fd_lookup>
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	79 02                	jns    8004ca <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004c8:	c9                   	leave  
  8004c9:	c3                   	ret    
		return fd_close(fd, 1);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	6a 01                	push   $0x1
  8004cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8004d2:	e8 49 ff ff ff       	call   800420 <fd_close>
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	eb ec                	jmp    8004c8 <close+0x1d>

008004dc <close_all>:

void
close_all(void)
{
  8004dc:	f3 0f 1e fb          	endbr32 
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	53                   	push   %ebx
  8004e4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	e8 b6 ff ff ff       	call   8004ab <close>
	for (i = 0; i < MAXFD; i++)
  8004f5:	83 c3 01             	add    $0x1,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	83 fb 20             	cmp    $0x20,%ebx
  8004fe:	75 ec                	jne    8004ec <close_all+0x10>
}
  800500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800503:	c9                   	leave  
  800504:	c3                   	ret    

00800505 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800505:	f3 0f 1e fb          	endbr32 
  800509:	55                   	push   %ebp
  80050a:	89 e5                	mov    %esp,%ebp
  80050c:	57                   	push   %edi
  80050d:	56                   	push   %esi
  80050e:	53                   	push   %ebx
  80050f:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800512:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800515:	50                   	push   %eax
  800516:	ff 75 08             	pushl  0x8(%ebp)
  800519:	e8 4f fe ff ff       	call   80036d <fd_lookup>
  80051e:	89 c3                	mov    %eax,%ebx
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 c0                	test   %eax,%eax
  800525:	0f 88 81 00 00 00    	js     8005ac <dup+0xa7>
		return r;
	close(newfdnum);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	e8 75 ff ff ff       	call   8004ab <close>

	newfd = INDEX2FD(newfdnum);
  800536:	8b 75 0c             	mov    0xc(%ebp),%esi
  800539:	c1 e6 0c             	shl    $0xc,%esi
  80053c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800542:	83 c4 04             	add    $0x4,%esp
  800545:	ff 75 e4             	pushl  -0x1c(%ebp)
  800548:	e8 af fd ff ff       	call   8002fc <fd2data>
  80054d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80054f:	89 34 24             	mov    %esi,(%esp)
  800552:	e8 a5 fd ff ff       	call   8002fc <fd2data>
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80055c:	89 d8                	mov    %ebx,%eax
  80055e:	c1 e8 16             	shr    $0x16,%eax
  800561:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800568:	a8 01                	test   $0x1,%al
  80056a:	74 11                	je     80057d <dup+0x78>
  80056c:	89 d8                	mov    %ebx,%eax
  80056e:	c1 e8 0c             	shr    $0xc,%eax
  800571:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800578:	f6 c2 01             	test   $0x1,%dl
  80057b:	75 39                	jne    8005b6 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80057d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800580:	89 d0                	mov    %edx,%eax
  800582:	c1 e8 0c             	shr    $0xc,%eax
  800585:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	25 07 0e 00 00       	and    $0xe07,%eax
  800594:	50                   	push   %eax
  800595:	56                   	push   %esi
  800596:	6a 00                	push   $0x0
  800598:	52                   	push   %edx
  800599:	6a 00                	push   $0x0
  80059b:	e8 d7 fb ff ff       	call   800177 <sys_page_map>
  8005a0:	89 c3                	mov    %eax,%ebx
  8005a2:	83 c4 20             	add    $0x20,%esp
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	78 31                	js     8005da <dup+0xd5>
		goto err;

	return newfdnum;
  8005a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ac:	89 d8                	mov    %ebx,%eax
  8005ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b1:	5b                   	pop    %ebx
  8005b2:	5e                   	pop    %esi
  8005b3:	5f                   	pop    %edi
  8005b4:	5d                   	pop    %ebp
  8005b5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005bd:	83 ec 0c             	sub    $0xc,%esp
  8005c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c5:	50                   	push   %eax
  8005c6:	57                   	push   %edi
  8005c7:	6a 00                	push   $0x0
  8005c9:	53                   	push   %ebx
  8005ca:	6a 00                	push   $0x0
  8005cc:	e8 a6 fb ff ff       	call   800177 <sys_page_map>
  8005d1:	89 c3                	mov    %eax,%ebx
  8005d3:	83 c4 20             	add    $0x20,%esp
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	79 a3                	jns    80057d <dup+0x78>
	sys_page_unmap(0, newfd);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	56                   	push   %esi
  8005de:	6a 00                	push   $0x0
  8005e0:	e8 b7 fb ff ff       	call   80019c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005e5:	83 c4 08             	add    $0x8,%esp
  8005e8:	57                   	push   %edi
  8005e9:	6a 00                	push   $0x0
  8005eb:	e8 ac fb ff ff       	call   80019c <sys_page_unmap>
	return r;
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb b7                	jmp    8005ac <dup+0xa7>

008005f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8005f5:	f3 0f 1e fb          	endbr32 
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	53                   	push   %ebx
  8005fd:	83 ec 1c             	sub    $0x1c,%esp
  800600:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800603:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800606:	50                   	push   %eax
  800607:	53                   	push   %ebx
  800608:	e8 60 fd ff ff       	call   80036d <fd_lookup>
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	85 c0                	test   %eax,%eax
  800612:	78 3f                	js     800653 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80061a:	50                   	push   %eax
  80061b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061e:	ff 30                	pushl  (%eax)
  800620:	e8 9c fd ff ff       	call   8003c1 <dev_lookup>
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	85 c0                	test   %eax,%eax
  80062a:	78 27                	js     800653 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80062c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80062f:	8b 42 08             	mov    0x8(%edx),%eax
  800632:	83 e0 03             	and    $0x3,%eax
  800635:	83 f8 01             	cmp    $0x1,%eax
  800638:	74 1e                	je     800658 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80063a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80063d:	8b 40 08             	mov    0x8(%eax),%eax
  800640:	85 c0                	test   %eax,%eax
  800642:	74 35                	je     800679 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800644:	83 ec 04             	sub    $0x4,%esp
  800647:	ff 75 10             	pushl  0x10(%ebp)
  80064a:	ff 75 0c             	pushl  0xc(%ebp)
  80064d:	52                   	push   %edx
  80064e:	ff d0                	call   *%eax
  800650:	83 c4 10             	add    $0x10,%esp
}
  800653:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800656:	c9                   	leave  
  800657:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800658:	a1 08 40 80 00       	mov    0x804008,%eax
  80065d:	8b 40 48             	mov    0x48(%eax),%eax
  800660:	83 ec 04             	sub    $0x4,%esp
  800663:	53                   	push   %ebx
  800664:	50                   	push   %eax
  800665:	68 8d 23 80 00       	push   $0x80238d
  80066a:	e8 68 0f 00 00       	call   8015d7 <cprintf>
		return -E_INVAL;
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800677:	eb da                	jmp    800653 <read+0x5e>
		return -E_NOT_SUPP;
  800679:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80067e:	eb d3                	jmp    800653 <read+0x5e>

00800680 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800680:	f3 0f 1e fb          	endbr32 
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	57                   	push   %edi
  800688:	56                   	push   %esi
  800689:	53                   	push   %ebx
  80068a:	83 ec 0c             	sub    $0xc,%esp
  80068d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800690:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800693:	bb 00 00 00 00       	mov    $0x0,%ebx
  800698:	eb 02                	jmp    80069c <readn+0x1c>
  80069a:	01 c3                	add    %eax,%ebx
  80069c:	39 f3                	cmp    %esi,%ebx
  80069e:	73 21                	jae    8006c1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006a0:	83 ec 04             	sub    $0x4,%esp
  8006a3:	89 f0                	mov    %esi,%eax
  8006a5:	29 d8                	sub    %ebx,%eax
  8006a7:	50                   	push   %eax
  8006a8:	89 d8                	mov    %ebx,%eax
  8006aa:	03 45 0c             	add    0xc(%ebp),%eax
  8006ad:	50                   	push   %eax
  8006ae:	57                   	push   %edi
  8006af:	e8 41 ff ff ff       	call   8005f5 <read>
		if (m < 0)
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	78 04                	js     8006bf <readn+0x3f>
			return m;
		if (m == 0)
  8006bb:	75 dd                	jne    80069a <readn+0x1a>
  8006bd:	eb 02                	jmp    8006c1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006bf:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006c1:	89 d8                	mov    %ebx,%eax
  8006c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c6:	5b                   	pop    %ebx
  8006c7:	5e                   	pop    %esi
  8006c8:	5f                   	pop    %edi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006cb:	f3 0f 1e fb          	endbr32 
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	53                   	push   %ebx
  8006d3:	83 ec 1c             	sub    $0x1c,%esp
  8006d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006dc:	50                   	push   %eax
  8006dd:	53                   	push   %ebx
  8006de:	e8 8a fc ff ff       	call   80036d <fd_lookup>
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	78 3a                	js     800724 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f4:	ff 30                	pushl  (%eax)
  8006f6:	e8 c6 fc ff ff       	call   8003c1 <dev_lookup>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c0                	test   %eax,%eax
  800700:	78 22                	js     800724 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800705:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800709:	74 1e                	je     800729 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80070b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80070e:	8b 52 0c             	mov    0xc(%edx),%edx
  800711:	85 d2                	test   %edx,%edx
  800713:	74 35                	je     80074a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800715:	83 ec 04             	sub    $0x4,%esp
  800718:	ff 75 10             	pushl  0x10(%ebp)
  80071b:	ff 75 0c             	pushl  0xc(%ebp)
  80071e:	50                   	push   %eax
  80071f:	ff d2                	call   *%edx
  800721:	83 c4 10             	add    $0x10,%esp
}
  800724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800727:	c9                   	leave  
  800728:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800729:	a1 08 40 80 00       	mov    0x804008,%eax
  80072e:	8b 40 48             	mov    0x48(%eax),%eax
  800731:	83 ec 04             	sub    $0x4,%esp
  800734:	53                   	push   %ebx
  800735:	50                   	push   %eax
  800736:	68 a9 23 80 00       	push   $0x8023a9
  80073b:	e8 97 0e 00 00       	call   8015d7 <cprintf>
		return -E_INVAL;
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800748:	eb da                	jmp    800724 <write+0x59>
		return -E_NOT_SUPP;
  80074a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80074f:	eb d3                	jmp    800724 <write+0x59>

00800751 <seek>:

int
seek(int fdnum, off_t offset)
{
  800751:	f3 0f 1e fb          	endbr32 
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80075b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	ff 75 08             	pushl  0x8(%ebp)
  800762:	e8 06 fc ff ff       	call   80036d <fd_lookup>
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	85 c0                	test   %eax,%eax
  80076c:	78 0e                	js     80077c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800774:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800777:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80077e:	f3 0f 1e fb          	endbr32 
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	83 ec 1c             	sub    $0x1c,%esp
  800789:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	53                   	push   %ebx
  800791:	e8 d7 fb ff ff       	call   80036d <fd_lookup>
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	85 c0                	test   %eax,%eax
  80079b:	78 37                	js     8007d4 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a3:	50                   	push   %eax
  8007a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a7:	ff 30                	pushl  (%eax)
  8007a9:	e8 13 fc ff ff       	call   8003c1 <dev_lookup>
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	78 1f                	js     8007d4 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007bc:	74 1b                	je     8007d9 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c1:	8b 52 18             	mov    0x18(%edx),%edx
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 32                	je     8007fa <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	50                   	push   %eax
  8007cf:	ff d2                	call   *%edx
  8007d1:	83 c4 10             	add    $0x10,%esp
}
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007d9:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007de:	8b 40 48             	mov    0x48(%eax),%eax
  8007e1:	83 ec 04             	sub    $0x4,%esp
  8007e4:	53                   	push   %ebx
  8007e5:	50                   	push   %eax
  8007e6:	68 6c 23 80 00       	push   $0x80236c
  8007eb:	e8 e7 0d 00 00       	call   8015d7 <cprintf>
		return -E_INVAL;
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f8:	eb da                	jmp    8007d4 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8007fa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007ff:	eb d3                	jmp    8007d4 <ftruncate+0x56>

00800801 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800801:	f3 0f 1e fb          	endbr32 
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	83 ec 1c             	sub    $0x1c,%esp
  80080c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800812:	50                   	push   %eax
  800813:	ff 75 08             	pushl  0x8(%ebp)
  800816:	e8 52 fb ff ff       	call   80036d <fd_lookup>
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 4b                	js     80086d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	ff 30                	pushl  (%eax)
  80082e:	e8 8e fb ff ff       	call   8003c1 <dev_lookup>
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	85 c0                	test   %eax,%eax
  800838:	78 33                	js     80086d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80083a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800841:	74 2f                	je     800872 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800843:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800846:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80084d:	00 00 00 
	stat->st_isdir = 0;
  800850:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800857:	00 00 00 
	stat->st_dev = dev;
  80085a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	ff 75 f0             	pushl  -0x10(%ebp)
  800867:	ff 50 14             	call   *0x14(%eax)
  80086a:	83 c4 10             	add    $0x10,%esp
}
  80086d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800870:	c9                   	leave  
  800871:	c3                   	ret    
		return -E_NOT_SUPP;
  800872:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800877:	eb f4                	jmp    80086d <fstat+0x6c>

00800879 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800879:	f3 0f 1e fb          	endbr32 
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	6a 00                	push   $0x0
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 01 02 00 00       	call   800a90 <open>
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	83 c4 10             	add    $0x10,%esp
  800894:	85 c0                	test   %eax,%eax
  800896:	78 1b                	js     8008b3 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	ff 75 0c             	pushl  0xc(%ebp)
  80089e:	50                   	push   %eax
  80089f:	e8 5d ff ff ff       	call   800801 <fstat>
  8008a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008a6:	89 1c 24             	mov    %ebx,(%esp)
  8008a9:	e8 fd fb ff ff       	call   8004ab <close>
	return r;
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	89 f3                	mov    %esi,%ebx
}
  8008b3:	89 d8                	mov    %ebx,%eax
  8008b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	89 c6                	mov    %eax,%esi
  8008c3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008cc:	74 27                	je     8008f5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ce:	6a 07                	push   $0x7
  8008d0:	68 00 50 80 00       	push   $0x805000
  8008d5:	56                   	push   %esi
  8008d6:	ff 35 00 40 80 00    	pushl  0x804000
  8008dc:	e8 27 17 00 00       	call   802008 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008e1:	83 c4 0c             	add    $0xc,%esp
  8008e4:	6a 00                	push   $0x0
  8008e6:	53                   	push   %ebx
  8008e7:	6a 00                	push   $0x0
  8008e9:	e8 ad 16 00 00       	call   801f9b <ipc_recv>
}
  8008ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8008f5:	83 ec 0c             	sub    $0xc,%esp
  8008f8:	6a 01                	push   $0x1
  8008fa:	e8 61 17 00 00       	call   802060 <ipc_find_env>
  8008ff:	a3 00 40 80 00       	mov    %eax,0x804000
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb c5                	jmp    8008ce <fsipc+0x12>

00800909 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800909:	f3 0f 1e fb          	endbr32 
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 40 0c             	mov    0xc(%eax),%eax
  800919:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
  80092b:	b8 02 00 00 00       	mov    $0x2,%eax
  800930:	e8 87 ff ff ff       	call   8008bc <fsipc>
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <devfile_flush>:
{
  800937:	f3 0f 1e fb          	endbr32 
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 40 0c             	mov    0xc(%eax),%eax
  800947:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	b8 06 00 00 00       	mov    $0x6,%eax
  800956:	e8 61 ff ff ff       	call   8008bc <fsipc>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <devfile_stat>:
{
  80095d:	f3 0f 1e fb          	endbr32 
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	83 ec 04             	sub    $0x4,%esp
  800968:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 40 0c             	mov    0xc(%eax),%eax
  800971:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
  80097b:	b8 05 00 00 00       	mov    $0x5,%eax
  800980:	e8 37 ff ff ff       	call   8008bc <fsipc>
  800985:	85 c0                	test   %eax,%eax
  800987:	78 2c                	js     8009b5 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800989:	83 ec 08             	sub    $0x8,%esp
  80098c:	68 00 50 80 00       	push   $0x805000
  800991:	53                   	push   %ebx
  800992:	e8 4a 12 00 00       	call   801be1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800997:	a1 80 50 80 00       	mov    0x805080,%eax
  80099c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ad:	83 c4 10             	add    $0x10,%esp
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <devfile_write>:
{
  8009ba:	f3 0f 1e fb          	endbr32 
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 0c             	sub    $0xc,%esp
  8009c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009cc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009d1:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d7:	8b 52 0c             	mov    0xc(%edx),%edx
  8009da:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e5:	50                   	push   %eax
  8009e6:	ff 75 0c             	pushl  0xc(%ebp)
  8009e9:	68 08 50 80 00       	push   $0x805008
  8009ee:	e8 ec 13 00 00       	call   801ddf <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8009f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f8:	b8 04 00 00 00       	mov    $0x4,%eax
  8009fd:	e8 ba fe ff ff       	call   8008bc <fsipc>
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <devfile_read>:
{
  800a04:	f3 0f 1e fb          	endbr32 
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 40 0c             	mov    0xc(%eax),%eax
  800a16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a1b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2b:	e8 8c fe ff ff       	call   8008bc <fsipc>
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	85 c0                	test   %eax,%eax
  800a34:	78 1f                	js     800a55 <devfile_read+0x51>
	assert(r <= n);
  800a36:	39 f0                	cmp    %esi,%eax
  800a38:	77 24                	ja     800a5e <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a3a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3f:	7f 36                	jg     800a77 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a41:	83 ec 04             	sub    $0x4,%esp
  800a44:	50                   	push   %eax
  800a45:	68 00 50 80 00       	push   $0x805000
  800a4a:	ff 75 0c             	pushl  0xc(%ebp)
  800a4d:	e8 8d 13 00 00       	call   801ddf <memmove>
	return r;
  800a52:	83 c4 10             	add    $0x10,%esp
}
  800a55:	89 d8                	mov    %ebx,%eax
  800a57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    
	assert(r <= n);
  800a5e:	68 dc 23 80 00       	push   $0x8023dc
  800a63:	68 e3 23 80 00       	push   $0x8023e3
  800a68:	68 8c 00 00 00       	push   $0x8c
  800a6d:	68 f8 23 80 00       	push   $0x8023f8
  800a72:	e8 79 0a 00 00       	call   8014f0 <_panic>
	assert(r <= PGSIZE);
  800a77:	68 03 24 80 00       	push   $0x802403
  800a7c:	68 e3 23 80 00       	push   $0x8023e3
  800a81:	68 8d 00 00 00       	push   $0x8d
  800a86:	68 f8 23 80 00       	push   $0x8023f8
  800a8b:	e8 60 0a 00 00       	call   8014f0 <_panic>

00800a90 <open>:
{
  800a90:	f3 0f 1e fb          	endbr32 
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	83 ec 1c             	sub    $0x1c,%esp
  800a9c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9f:	56                   	push   %esi
  800aa0:	e8 f9 10 00 00       	call   801b9e <strlen>
  800aa5:	83 c4 10             	add    $0x10,%esp
  800aa8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aad:	7f 6c                	jg     800b1b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800aaf:	83 ec 0c             	sub    $0xc,%esp
  800ab2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab5:	50                   	push   %eax
  800ab6:	e8 5c f8 ff ff       	call   800317 <fd_alloc>
  800abb:	89 c3                	mov    %eax,%ebx
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	78 3c                	js     800b00 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ac4:	83 ec 08             	sub    $0x8,%esp
  800ac7:	56                   	push   %esi
  800ac8:	68 00 50 80 00       	push   $0x805000
  800acd:	e8 0f 11 00 00       	call   801be1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ada:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800add:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae2:	e8 d5 fd ff ff       	call   8008bc <fsipc>
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	85 c0                	test   %eax,%eax
  800aee:	78 19                	js     800b09 <open+0x79>
	return fd2num(fd);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	ff 75 f4             	pushl  -0xc(%ebp)
  800af6:	e8 ed f7 ff ff       	call   8002e8 <fd2num>
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	83 c4 10             	add    $0x10,%esp
}
  800b00:	89 d8                	mov    %ebx,%eax
  800b02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    
		fd_close(fd, 0);
  800b09:	83 ec 08             	sub    $0x8,%esp
  800b0c:	6a 00                	push   $0x0
  800b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b11:	e8 0a f9 ff ff       	call   800420 <fd_close>
		return r;
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	eb e5                	jmp    800b00 <open+0x70>
		return -E_BAD_PATH;
  800b1b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b20:	eb de                	jmp    800b00 <open+0x70>

00800b22 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b22:	f3 0f 1e fb          	endbr32 
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b31:	b8 08 00 00 00       	mov    $0x8,%eax
  800b36:	e8 81 fd ff ff       	call   8008bc <fsipc>
}
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b3d:	f3 0f 1e fb          	endbr32 
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b47:	68 6f 24 80 00       	push   $0x80246f
  800b4c:	ff 75 0c             	pushl  0xc(%ebp)
  800b4f:	e8 8d 10 00 00       	call   801be1 <strcpy>
	return 0;
}
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	c9                   	leave  
  800b5a:	c3                   	ret    

00800b5b <devsock_close>:
{
  800b5b:	f3 0f 1e fb          	endbr32 
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	53                   	push   %ebx
  800b63:	83 ec 10             	sub    $0x10,%esp
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b69:	53                   	push   %ebx
  800b6a:	e8 2e 15 00 00       	call   80209d <pageref>
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
		return 0;
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800b79:	83 fa 01             	cmp    $0x1,%edx
  800b7c:	74 05                	je     800b83 <devsock_close+0x28>
}
  800b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	ff 73 0c             	pushl  0xc(%ebx)
  800b89:	e8 e3 02 00 00       	call   800e71 <nsipc_close>
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	eb eb                	jmp    800b7e <devsock_close+0x23>

00800b93 <devsock_write>:
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800b9d:	6a 00                	push   $0x0
  800b9f:	ff 75 10             	pushl  0x10(%ebp)
  800ba2:	ff 75 0c             	pushl  0xc(%ebp)
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	ff 70 0c             	pushl  0xc(%eax)
  800bab:	e8 b5 03 00 00       	call   800f65 <nsipc_send>
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <devsock_read>:
{
  800bb2:	f3 0f 1e fb          	endbr32 
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bbc:	6a 00                	push   $0x0
  800bbe:	ff 75 10             	pushl  0x10(%ebp)
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	ff 70 0c             	pushl  0xc(%eax)
  800bca:	e8 1f 03 00 00       	call   800eee <nsipc_recv>
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <fd2sockid>:
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800bd7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bda:	52                   	push   %edx
  800bdb:	50                   	push   %eax
  800bdc:	e8 8c f7 ff ff       	call   80036d <fd_lookup>
  800be1:	83 c4 10             	add    $0x10,%esp
  800be4:	85 c0                	test   %eax,%eax
  800be6:	78 10                	js     800bf8 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800beb:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800bf1:	39 08                	cmp    %ecx,(%eax)
  800bf3:	75 05                	jne    800bfa <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800bf5:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    
		return -E_NOT_SUPP;
  800bfa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bff:	eb f7                	jmp    800bf8 <fd2sockid+0x27>

00800c01 <alloc_sockfd>:
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 1c             	sub    $0x1c,%esp
  800c09:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0e:	50                   	push   %eax
  800c0f:	e8 03 f7 ff ff       	call   800317 <fd_alloc>
  800c14:	89 c3                	mov    %eax,%ebx
  800c16:	83 c4 10             	add    $0x10,%esp
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	78 43                	js     800c60 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c1d:	83 ec 04             	sub    $0x4,%esp
  800c20:	68 07 04 00 00       	push   $0x407
  800c25:	ff 75 f4             	pushl  -0xc(%ebp)
  800c28:	6a 00                	push   $0x0
  800c2a:	e8 22 f5 ff ff       	call   800151 <sys_page_alloc>
  800c2f:	89 c3                	mov    %eax,%ebx
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	85 c0                	test   %eax,%eax
  800c36:	78 28                	js     800c60 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3b:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c41:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c46:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c4d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	e8 8f f6 ff ff       	call   8002e8 <fd2num>
  800c59:	89 c3                	mov    %eax,%ebx
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	eb 0c                	jmp    800c6c <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	56                   	push   %esi
  800c64:	e8 08 02 00 00       	call   800e71 <nsipc_close>
		return r;
  800c69:	83 c4 10             	add    $0x10,%esp
}
  800c6c:	89 d8                	mov    %ebx,%eax
  800c6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <accept>:
{
  800c75:	f3 0f 1e fb          	endbr32 
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	e8 4a ff ff ff       	call   800bd1 <fd2sockid>
  800c87:	85 c0                	test   %eax,%eax
  800c89:	78 1b                	js     800ca6 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800c8b:	83 ec 04             	sub    $0x4,%esp
  800c8e:	ff 75 10             	pushl  0x10(%ebp)
  800c91:	ff 75 0c             	pushl  0xc(%ebp)
  800c94:	50                   	push   %eax
  800c95:	e8 22 01 00 00       	call   800dbc <nsipc_accept>
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	78 05                	js     800ca6 <accept+0x31>
	return alloc_sockfd(r);
  800ca1:	e8 5b ff ff ff       	call   800c01 <alloc_sockfd>
}
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    

00800ca8 <bind>:
{
  800ca8:	f3 0f 1e fb          	endbr32 
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	e8 17 ff ff ff       	call   800bd1 <fd2sockid>
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	78 12                	js     800cd0 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800cbe:	83 ec 04             	sub    $0x4,%esp
  800cc1:	ff 75 10             	pushl  0x10(%ebp)
  800cc4:	ff 75 0c             	pushl  0xc(%ebp)
  800cc7:	50                   	push   %eax
  800cc8:	e8 45 01 00 00       	call   800e12 <nsipc_bind>
  800ccd:	83 c4 10             	add    $0x10,%esp
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    

00800cd2 <shutdown>:
{
  800cd2:	f3 0f 1e fb          	endbr32 
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	e8 ed fe ff ff       	call   800bd1 <fd2sockid>
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	78 0f                	js     800cf7 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800ce8:	83 ec 08             	sub    $0x8,%esp
  800ceb:	ff 75 0c             	pushl  0xc(%ebp)
  800cee:	50                   	push   %eax
  800cef:	e8 57 01 00 00       	call   800e4b <nsipc_shutdown>
  800cf4:	83 c4 10             	add    $0x10,%esp
}
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    

00800cf9 <connect>:
{
  800cf9:	f3 0f 1e fb          	endbr32 
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	e8 c6 fe ff ff       	call   800bd1 <fd2sockid>
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	78 12                	js     800d21 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d0f:	83 ec 04             	sub    $0x4,%esp
  800d12:	ff 75 10             	pushl  0x10(%ebp)
  800d15:	ff 75 0c             	pushl  0xc(%ebp)
  800d18:	50                   	push   %eax
  800d19:	e8 71 01 00 00       	call   800e8f <nsipc_connect>
  800d1e:	83 c4 10             	add    $0x10,%esp
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <listen>:
{
  800d23:	f3 0f 1e fb          	endbr32 
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	e8 9c fe ff ff       	call   800bd1 <fd2sockid>
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 0f                	js     800d48 <listen+0x25>
	return nsipc_listen(r, backlog);
  800d39:	83 ec 08             	sub    $0x8,%esp
  800d3c:	ff 75 0c             	pushl  0xc(%ebp)
  800d3f:	50                   	push   %eax
  800d40:	e8 83 01 00 00       	call   800ec8 <nsipc_listen>
  800d45:	83 c4 10             	add    $0x10,%esp
}
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <socket>:

int
socket(int domain, int type, int protocol)
{
  800d4a:	f3 0f 1e fb          	endbr32 
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d54:	ff 75 10             	pushl  0x10(%ebp)
  800d57:	ff 75 0c             	pushl  0xc(%ebp)
  800d5a:	ff 75 08             	pushl  0x8(%ebp)
  800d5d:	e8 65 02 00 00       	call   800fc7 <nsipc_socket>
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	85 c0                	test   %eax,%eax
  800d67:	78 05                	js     800d6e <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d69:	e8 93 fe ff ff       	call   800c01 <alloc_sockfd>
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	53                   	push   %ebx
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d79:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d80:	74 26                	je     800da8 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d82:	6a 07                	push   $0x7
  800d84:	68 00 60 80 00       	push   $0x806000
  800d89:	53                   	push   %ebx
  800d8a:	ff 35 04 40 80 00    	pushl  0x804004
  800d90:	e8 73 12 00 00       	call   802008 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800d95:	83 c4 0c             	add    $0xc,%esp
  800d98:	6a 00                	push   $0x0
  800d9a:	6a 00                	push   $0x0
  800d9c:	6a 00                	push   $0x0
  800d9e:	e8 f8 11 00 00       	call   801f9b <ipc_recv>
}
  800da3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	6a 02                	push   $0x2
  800dad:	e8 ae 12 00 00       	call   802060 <ipc_find_env>
  800db2:	a3 04 40 80 00       	mov    %eax,0x804004
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	eb c6                	jmp    800d82 <nsipc+0x12>

00800dbc <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dbc:	f3 0f 1e fb          	endbr32 
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dd0:	8b 06                	mov    (%esi),%eax
  800dd2:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddc:	e8 8f ff ff ff       	call   800d70 <nsipc>
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	85 c0                	test   %eax,%eax
  800de5:	79 09                	jns    800df0 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800de7:	89 d8                	mov    %ebx,%eax
  800de9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	ff 35 10 60 80 00    	pushl  0x806010
  800df9:	68 00 60 80 00       	push   $0x806000
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	e8 d9 0f 00 00       	call   801ddf <memmove>
		*addrlen = ret->ret_addrlen;
  800e06:	a1 10 60 80 00       	mov    0x806010,%eax
  800e0b:	89 06                	mov    %eax,(%esi)
  800e0d:	83 c4 10             	add    $0x10,%esp
	return r;
  800e10:	eb d5                	jmp    800de7 <nsipc_accept+0x2b>

00800e12 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e12:	f3 0f 1e fb          	endbr32 
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e28:	53                   	push   %ebx
  800e29:	ff 75 0c             	pushl  0xc(%ebp)
  800e2c:	68 04 60 80 00       	push   $0x806004
  800e31:	e8 a9 0f 00 00       	call   801ddf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e36:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e3c:	b8 02 00 00 00       	mov    $0x2,%eax
  800e41:	e8 2a ff ff ff       	call   800d70 <nsipc>
}
  800e46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e4b:	f3 0f 1e fb          	endbr32 
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e60:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e65:	b8 03 00 00 00       	mov    $0x3,%eax
  800e6a:	e8 01 ff ff ff       	call   800d70 <nsipc>
}
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <nsipc_close>:

int
nsipc_close(int s)
{
  800e71:	f3 0f 1e fb          	endbr32 
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e83:	b8 04 00 00 00       	mov    $0x4,%eax
  800e88:	e8 e3 fe ff ff       	call   800d70 <nsipc>
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e8f:	f3 0f 1e fb          	endbr32 
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	53                   	push   %ebx
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ea5:	53                   	push   %ebx
  800ea6:	ff 75 0c             	pushl  0xc(%ebp)
  800ea9:	68 04 60 80 00       	push   $0x806004
  800eae:	e8 2c 0f 00 00       	call   801ddf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eb3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eb9:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebe:	e8 ad fe ff ff       	call   800d70 <nsipc>
}
  800ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ec8:	f3 0f 1e fb          	endbr32 
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ee2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee7:	e8 84 fe ff ff       	call   800d70 <nsipc>
}
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800eee:	f3 0f 1e fb          	endbr32 
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
  800ef7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
  800efd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f02:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f08:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f10:	b8 07 00 00 00       	mov    $0x7,%eax
  800f15:	e8 56 fe ff ff       	call   800d70 <nsipc>
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 26                	js     800f46 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f20:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f26:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f2b:	0f 4e c6             	cmovle %esi,%eax
  800f2e:	39 c3                	cmp    %eax,%ebx
  800f30:	7f 1d                	jg     800f4f <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f32:	83 ec 04             	sub    $0x4,%esp
  800f35:	53                   	push   %ebx
  800f36:	68 00 60 80 00       	push   $0x806000
  800f3b:	ff 75 0c             	pushl  0xc(%ebp)
  800f3e:	e8 9c 0e 00 00       	call   801ddf <memmove>
  800f43:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f46:	89 d8                	mov    %ebx,%eax
  800f48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f4f:	68 7b 24 80 00       	push   $0x80247b
  800f54:	68 e3 23 80 00       	push   $0x8023e3
  800f59:	6a 62                	push   $0x62
  800f5b:	68 90 24 80 00       	push   $0x802490
  800f60:	e8 8b 05 00 00       	call   8014f0 <_panic>

00800f65 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f65:	f3 0f 1e fb          	endbr32 
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f7b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f81:	7f 2e                	jg     800fb1 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f83:	83 ec 04             	sub    $0x4,%esp
  800f86:	53                   	push   %ebx
  800f87:	ff 75 0c             	pushl  0xc(%ebp)
  800f8a:	68 0c 60 80 00       	push   $0x80600c
  800f8f:	e8 4b 0e 00 00       	call   801ddf <memmove>
	nsipcbuf.send.req_size = size;
  800f94:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800f9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fa2:	b8 08 00 00 00       	mov    $0x8,%eax
  800fa7:	e8 c4 fd ff ff       	call   800d70 <nsipc>
}
  800fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    
	assert(size < 1600);
  800fb1:	68 9c 24 80 00       	push   $0x80249c
  800fb6:	68 e3 23 80 00       	push   $0x8023e3
  800fbb:	6a 6d                	push   $0x6d
  800fbd:	68 90 24 80 00       	push   $0x802490
  800fc2:	e8 29 05 00 00       	call   8014f0 <_panic>

00800fc7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fc7:	f3 0f 1e fb          	endbr32 
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe1:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fe9:	b8 09 00 00 00       	mov    $0x9,%eax
  800fee:	e8 7d fd ff ff       	call   800d70 <nsipc>
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff5:	f3 0f 1e fb          	endbr32 
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	ff 75 08             	pushl  0x8(%ebp)
  801007:	e8 f0 f2 ff ff       	call   8002fc <fd2data>
  80100c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100e:	83 c4 08             	add    $0x8,%esp
  801011:	68 a8 24 80 00       	push   $0x8024a8
  801016:	53                   	push   %ebx
  801017:	e8 c5 0b 00 00       	call   801be1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101c:	8b 46 04             	mov    0x4(%esi),%eax
  80101f:	2b 06                	sub    (%esi),%eax
  801021:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801027:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102e:	00 00 00 
	stat->st_dev = &devpipe;
  801031:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801038:	30 80 00 
	return 0;
}
  80103b:	b8 00 00 00 00       	mov    $0x0,%eax
  801040:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801047:	f3 0f 1e fb          	endbr32 
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	53                   	push   %ebx
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801055:	53                   	push   %ebx
  801056:	6a 00                	push   $0x0
  801058:	e8 3f f1 ff ff       	call   80019c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80105d:	89 1c 24             	mov    %ebx,(%esp)
  801060:	e8 97 f2 ff ff       	call   8002fc <fd2data>
  801065:	83 c4 08             	add    $0x8,%esp
  801068:	50                   	push   %eax
  801069:	6a 00                	push   $0x0
  80106b:	e8 2c f1 ff ff       	call   80019c <sys_page_unmap>
}
  801070:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <_pipeisclosed>:
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	83 ec 1c             	sub    $0x1c,%esp
  80107e:	89 c7                	mov    %eax,%edi
  801080:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801082:	a1 08 40 80 00       	mov    0x804008,%eax
  801087:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	57                   	push   %edi
  80108e:	e8 0a 10 00 00       	call   80209d <pageref>
  801093:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801096:	89 34 24             	mov    %esi,(%esp)
  801099:	e8 ff 0f 00 00       	call   80209d <pageref>
		nn = thisenv->env_runs;
  80109e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010a4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	39 cb                	cmp    %ecx,%ebx
  8010ac:	74 1b                	je     8010c9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010ae:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010b1:	75 cf                	jne    801082 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b3:	8b 42 58             	mov    0x58(%edx),%eax
  8010b6:	6a 01                	push   $0x1
  8010b8:	50                   	push   %eax
  8010b9:	53                   	push   %ebx
  8010ba:	68 af 24 80 00       	push   $0x8024af
  8010bf:	e8 13 05 00 00       	call   8015d7 <cprintf>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	eb b9                	jmp    801082 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010cc:	0f 94 c0             	sete   %al
  8010cf:	0f b6 c0             	movzbl %al,%eax
}
  8010d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <devpipe_write>:
{
  8010da:	f3 0f 1e fb          	endbr32 
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	83 ec 28             	sub    $0x28,%esp
  8010e7:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010ea:	56                   	push   %esi
  8010eb:	e8 0c f2 ff ff       	call   8002fc <fd2data>
  8010f0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	bf 00 00 00 00       	mov    $0x0,%edi
  8010fa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010fd:	74 4f                	je     80114e <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010ff:	8b 43 04             	mov    0x4(%ebx),%eax
  801102:	8b 0b                	mov    (%ebx),%ecx
  801104:	8d 51 20             	lea    0x20(%ecx),%edx
  801107:	39 d0                	cmp    %edx,%eax
  801109:	72 14                	jb     80111f <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80110b:	89 da                	mov    %ebx,%edx
  80110d:	89 f0                	mov    %esi,%eax
  80110f:	e8 61 ff ff ff       	call   801075 <_pipeisclosed>
  801114:	85 c0                	test   %eax,%eax
  801116:	75 3b                	jne    801153 <devpipe_write+0x79>
			sys_yield();
  801118:	e8 11 f0 ff ff       	call   80012e <sys_yield>
  80111d:	eb e0                	jmp    8010ff <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80111f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801122:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801126:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801129:	89 c2                	mov    %eax,%edx
  80112b:	c1 fa 1f             	sar    $0x1f,%edx
  80112e:	89 d1                	mov    %edx,%ecx
  801130:	c1 e9 1b             	shr    $0x1b,%ecx
  801133:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801136:	83 e2 1f             	and    $0x1f,%edx
  801139:	29 ca                	sub    %ecx,%edx
  80113b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80113f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801143:	83 c0 01             	add    $0x1,%eax
  801146:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801149:	83 c7 01             	add    $0x1,%edi
  80114c:	eb ac                	jmp    8010fa <devpipe_write+0x20>
	return i;
  80114e:	8b 45 10             	mov    0x10(%ebp),%eax
  801151:	eb 05                	jmp    801158 <devpipe_write+0x7e>
				return 0;
  801153:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    

00801160 <devpipe_read>:
{
  801160:	f3 0f 1e fb          	endbr32 
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 18             	sub    $0x18,%esp
  80116d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801170:	57                   	push   %edi
  801171:	e8 86 f1 ff ff       	call   8002fc <fd2data>
  801176:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	be 00 00 00 00       	mov    $0x0,%esi
  801180:	3b 75 10             	cmp    0x10(%ebp),%esi
  801183:	75 14                	jne    801199 <devpipe_read+0x39>
	return i;
  801185:	8b 45 10             	mov    0x10(%ebp),%eax
  801188:	eb 02                	jmp    80118c <devpipe_read+0x2c>
				return i;
  80118a:	89 f0                	mov    %esi,%eax
}
  80118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    
			sys_yield();
  801194:	e8 95 ef ff ff       	call   80012e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801199:	8b 03                	mov    (%ebx),%eax
  80119b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80119e:	75 18                	jne    8011b8 <devpipe_read+0x58>
			if (i > 0)
  8011a0:	85 f6                	test   %esi,%esi
  8011a2:	75 e6                	jne    80118a <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011a4:	89 da                	mov    %ebx,%edx
  8011a6:	89 f8                	mov    %edi,%eax
  8011a8:	e8 c8 fe ff ff       	call   801075 <_pipeisclosed>
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	74 e3                	je     801194 <devpipe_read+0x34>
				return 0;
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb d4                	jmp    80118c <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b8:	99                   	cltd   
  8011b9:	c1 ea 1b             	shr    $0x1b,%edx
  8011bc:	01 d0                	add    %edx,%eax
  8011be:	83 e0 1f             	and    $0x1f,%eax
  8011c1:	29 d0                	sub    %edx,%eax
  8011c3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011ce:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d1:	83 c6 01             	add    $0x1,%esi
  8011d4:	eb aa                	jmp    801180 <devpipe_read+0x20>

008011d6 <pipe>:
{
  8011d6:	f3 0f 1e fb          	endbr32 
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	e8 2c f1 ff ff       	call   800317 <fd_alloc>
  8011eb:	89 c3                	mov    %eax,%ebx
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	0f 88 23 01 00 00    	js     80131b <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	68 07 04 00 00       	push   $0x407
  801200:	ff 75 f4             	pushl  -0xc(%ebp)
  801203:	6a 00                	push   $0x0
  801205:	e8 47 ef ff ff       	call   800151 <sys_page_alloc>
  80120a:	89 c3                	mov    %eax,%ebx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	0f 88 04 01 00 00    	js     80131b <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801217:	83 ec 0c             	sub    $0xc,%esp
  80121a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	e8 f4 f0 ff ff       	call   800317 <fd_alloc>
  801223:	89 c3                	mov    %eax,%ebx
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	0f 88 db 00 00 00    	js     80130b <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	68 07 04 00 00       	push   $0x407
  801238:	ff 75 f0             	pushl  -0x10(%ebp)
  80123b:	6a 00                	push   $0x0
  80123d:	e8 0f ef ff ff       	call   800151 <sys_page_alloc>
  801242:	89 c3                	mov    %eax,%ebx
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	85 c0                	test   %eax,%eax
  801249:	0f 88 bc 00 00 00    	js     80130b <pipe+0x135>
	va = fd2data(fd0);
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	ff 75 f4             	pushl  -0xc(%ebp)
  801255:	e8 a2 f0 ff ff       	call   8002fc <fd2data>
  80125a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125c:	83 c4 0c             	add    $0xc,%esp
  80125f:	68 07 04 00 00       	push   $0x407
  801264:	50                   	push   %eax
  801265:	6a 00                	push   $0x0
  801267:	e8 e5 ee ff ff       	call   800151 <sys_page_alloc>
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	85 c0                	test   %eax,%eax
  801273:	0f 88 82 00 00 00    	js     8012fb <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801279:	83 ec 0c             	sub    $0xc,%esp
  80127c:	ff 75 f0             	pushl  -0x10(%ebp)
  80127f:	e8 78 f0 ff ff       	call   8002fc <fd2data>
  801284:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128b:	50                   	push   %eax
  80128c:	6a 00                	push   $0x0
  80128e:	56                   	push   %esi
  80128f:	6a 00                	push   $0x0
  801291:	e8 e1 ee ff ff       	call   800177 <sys_page_map>
  801296:	89 c3                	mov    %eax,%ebx
  801298:	83 c4 20             	add    $0x20,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 4e                	js     8012ed <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80129f:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ac:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c8:	e8 1b f0 ff ff       	call   8002e8 <fd2num>
  8012cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d2:	83 c4 04             	add    $0x4,%esp
  8012d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d8:	e8 0b f0 ff ff       	call   8002e8 <fd2num>
  8012dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012eb:	eb 2e                	jmp    80131b <pipe+0x145>
	sys_page_unmap(0, va);
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	56                   	push   %esi
  8012f1:	6a 00                	push   $0x0
  8012f3:	e8 a4 ee ff ff       	call   80019c <sys_page_unmap>
  8012f8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801301:	6a 00                	push   $0x0
  801303:	e8 94 ee ff ff       	call   80019c <sys_page_unmap>
  801308:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	ff 75 f4             	pushl  -0xc(%ebp)
  801311:	6a 00                	push   $0x0
  801313:	e8 84 ee ff ff       	call   80019c <sys_page_unmap>
  801318:	83 c4 10             	add    $0x10,%esp
}
  80131b:	89 d8                	mov    %ebx,%eax
  80131d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801320:	5b                   	pop    %ebx
  801321:	5e                   	pop    %esi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <pipeisclosed>:
{
  801324:	f3 0f 1e fb          	endbr32 
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 75 08             	pushl  0x8(%ebp)
  801335:	e8 33 f0 ff ff       	call   80036d <fd_lookup>
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 18                	js     801359 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801341:	83 ec 0c             	sub    $0xc,%esp
  801344:	ff 75 f4             	pushl  -0xc(%ebp)
  801347:	e8 b0 ef ff ff       	call   8002fc <fd2data>
  80134c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80134e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801351:	e8 1f fd ff ff       	call   801075 <_pipeisclosed>
  801356:	83 c4 10             	add    $0x10,%esp
}
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80135b:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
  801364:	c3                   	ret    

00801365 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801365:	f3 0f 1e fb          	endbr32 
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80136f:	68 c7 24 80 00       	push   $0x8024c7
  801374:	ff 75 0c             	pushl  0xc(%ebp)
  801377:	e8 65 08 00 00       	call   801be1 <strcpy>
	return 0;
}
  80137c:	b8 00 00 00 00       	mov    $0x0,%eax
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <devcons_write>:
{
  801383:	f3 0f 1e fb          	endbr32 
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801393:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801398:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80139e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a1:	73 31                	jae    8013d4 <devcons_write+0x51>
		m = n - tot;
  8013a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a6:	29 f3                	sub    %esi,%ebx
  8013a8:	83 fb 7f             	cmp    $0x7f,%ebx
  8013ab:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013b0:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013b3:	83 ec 04             	sub    $0x4,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	89 f0                	mov    %esi,%eax
  8013b9:	03 45 0c             	add    0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	57                   	push   %edi
  8013be:	e8 1c 0a 00 00       	call   801ddf <memmove>
		sys_cputs(buf, m);
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	57                   	push   %edi
  8013c8:	e8 d5 ec ff ff       	call   8000a2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013cd:	01 de                	add    %ebx,%esi
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	eb ca                	jmp    80139e <devcons_write+0x1b>
}
  8013d4:	89 f0                	mov    %esi,%eax
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <devcons_read>:
{
  8013de:	f3 0f 1e fb          	endbr32 
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f1:	74 21                	je     801414 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8013f3:	e8 cc ec ff ff       	call   8000c4 <sys_cgetc>
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	75 07                	jne    801403 <devcons_read+0x25>
		sys_yield();
  8013fc:	e8 2d ed ff ff       	call   80012e <sys_yield>
  801401:	eb f0                	jmp    8013f3 <devcons_read+0x15>
	if (c < 0)
  801403:	78 0f                	js     801414 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801405:	83 f8 04             	cmp    $0x4,%eax
  801408:	74 0c                	je     801416 <devcons_read+0x38>
	*(char*)vbuf = c;
  80140a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140d:	88 02                	mov    %al,(%edx)
	return 1;
  80140f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    
		return 0;
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
  80141b:	eb f7                	jmp    801414 <devcons_read+0x36>

0080141d <cputchar>:
{
  80141d:	f3 0f 1e fb          	endbr32 
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80142d:	6a 01                	push   $0x1
  80142f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	e8 6a ec ff ff       	call   8000a2 <sys_cputs>
}
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <getchar>:
{
  80143d:	f3 0f 1e fb          	endbr32 
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801447:	6a 01                	push   $0x1
  801449:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	6a 00                	push   $0x0
  80144f:	e8 a1 f1 ff ff       	call   8005f5 <read>
	if (r < 0)
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 06                	js     801461 <getchar+0x24>
	if (r < 1)
  80145b:	74 06                	je     801463 <getchar+0x26>
	return c;
  80145d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801461:	c9                   	leave  
  801462:	c3                   	ret    
		return -E_EOF;
  801463:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801468:	eb f7                	jmp    801461 <getchar+0x24>

0080146a <iscons>:
{
  80146a:	f3 0f 1e fb          	endbr32 
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	ff 75 08             	pushl  0x8(%ebp)
  80147b:	e8 ed ee ff ff       	call   80036d <fd_lookup>
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 11                	js     801498 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801487:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148a:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801490:	39 10                	cmp    %edx,(%eax)
  801492:	0f 94 c0             	sete   %al
  801495:	0f b6 c0             	movzbl %al,%eax
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <opencons>:
{
  80149a:	f3 0f 1e fb          	endbr32 
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	e8 6a ee ff ff       	call   800317 <fd_alloc>
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 3a                	js     8014ee <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	68 07 04 00 00       	push   $0x407
  8014bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bf:	6a 00                	push   $0x0
  8014c1:	e8 8b ec ff ff       	call   800151 <sys_page_alloc>
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 21                	js     8014ee <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d0:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014d6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	50                   	push   %eax
  8014e6:	e8 fd ed ff ff       	call   8002e8 <fd2num>
  8014eb:	83 c4 10             	add    $0x10,%esp
}
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f0:	f3 0f 1e fb          	endbr32 
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014fc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801502:	e8 04 ec ff ff       	call   80010b <sys_getenvid>
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	ff 75 0c             	pushl  0xc(%ebp)
  80150d:	ff 75 08             	pushl  0x8(%ebp)
  801510:	56                   	push   %esi
  801511:	50                   	push   %eax
  801512:	68 d4 24 80 00       	push   $0x8024d4
  801517:	e8 bb 00 00 00       	call   8015d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80151c:	83 c4 18             	add    $0x18,%esp
  80151f:	53                   	push   %ebx
  801520:	ff 75 10             	pushl  0x10(%ebp)
  801523:	e8 5a 00 00 00       	call   801582 <vcprintf>
	cprintf("\n");
  801528:	c7 04 24 c0 24 80 00 	movl   $0x8024c0,(%esp)
  80152f:	e8 a3 00 00 00       	call   8015d7 <cprintf>
  801534:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801537:	cc                   	int3   
  801538:	eb fd                	jmp    801537 <_panic+0x47>

0080153a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153a:	f3 0f 1e fb          	endbr32 
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	53                   	push   %ebx
  801542:	83 ec 04             	sub    $0x4,%esp
  801545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801548:	8b 13                	mov    (%ebx),%edx
  80154a:	8d 42 01             	lea    0x1(%edx),%eax
  80154d:	89 03                	mov    %eax,(%ebx)
  80154f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801552:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801556:	3d ff 00 00 00       	cmp    $0xff,%eax
  80155b:	74 09                	je     801566 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80155d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801564:	c9                   	leave  
  801565:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	68 ff 00 00 00       	push   $0xff
  80156e:	8d 43 08             	lea    0x8(%ebx),%eax
  801571:	50                   	push   %eax
  801572:	e8 2b eb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  801577:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	eb db                	jmp    80155d <putch+0x23>

00801582 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801582:	f3 0f 1e fb          	endbr32 
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80158f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801596:	00 00 00 
	b.cnt = 0;
  801599:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015a0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a3:	ff 75 0c             	pushl  0xc(%ebp)
  8015a6:	ff 75 08             	pushl  0x8(%ebp)
  8015a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	68 3a 15 80 00       	push   $0x80153a
  8015b5:	e8 20 01 00 00       	call   8016da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	e8 d3 ea ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8015cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d7:	f3 0f 1e fb          	endbr32 
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015e1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015e4:	50                   	push   %eax
  8015e5:	ff 75 08             	pushl  0x8(%ebp)
  8015e8:	e8 95 ff ff ff       	call   801582 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	57                   	push   %edi
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 1c             	sub    $0x1c,%esp
  8015f8:	89 c7                	mov    %eax,%edi
  8015fa:	89 d6                	mov    %edx,%esi
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801602:	89 d1                	mov    %edx,%ecx
  801604:	89 c2                	mov    %eax,%edx
  801606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801609:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80160c:	8b 45 10             	mov    0x10(%ebp),%eax
  80160f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801612:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801615:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80161c:	39 c2                	cmp    %eax,%edx
  80161e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801621:	72 3e                	jb     801661 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	ff 75 18             	pushl  0x18(%ebp)
  801629:	83 eb 01             	sub    $0x1,%ebx
  80162c:	53                   	push   %ebx
  80162d:	50                   	push   %eax
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	ff 75 e4             	pushl  -0x1c(%ebp)
  801634:	ff 75 e0             	pushl  -0x20(%ebp)
  801637:	ff 75 dc             	pushl  -0x24(%ebp)
  80163a:	ff 75 d8             	pushl  -0x28(%ebp)
  80163d:	e8 9e 0a 00 00       	call   8020e0 <__udivdi3>
  801642:	83 c4 18             	add    $0x18,%esp
  801645:	52                   	push   %edx
  801646:	50                   	push   %eax
  801647:	89 f2                	mov    %esi,%edx
  801649:	89 f8                	mov    %edi,%eax
  80164b:	e8 9f ff ff ff       	call   8015ef <printnum>
  801650:	83 c4 20             	add    $0x20,%esp
  801653:	eb 13                	jmp    801668 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	56                   	push   %esi
  801659:	ff 75 18             	pushl  0x18(%ebp)
  80165c:	ff d7                	call   *%edi
  80165e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801661:	83 eb 01             	sub    $0x1,%ebx
  801664:	85 db                	test   %ebx,%ebx
  801666:	7f ed                	jg     801655 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	56                   	push   %esi
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801672:	ff 75 e0             	pushl  -0x20(%ebp)
  801675:	ff 75 dc             	pushl  -0x24(%ebp)
  801678:	ff 75 d8             	pushl  -0x28(%ebp)
  80167b:	e8 70 0b 00 00       	call   8021f0 <__umoddi3>
  801680:	83 c4 14             	add    $0x14,%esp
  801683:	0f be 80 f7 24 80 00 	movsbl 0x8024f7(%eax),%eax
  80168a:	50                   	push   %eax
  80168b:	ff d7                	call   *%edi
}
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5f                   	pop    %edi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801698:	f3 0f 1e fb          	endbr32 
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016a2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016a6:	8b 10                	mov    (%eax),%edx
  8016a8:	3b 50 04             	cmp    0x4(%eax),%edx
  8016ab:	73 0a                	jae    8016b7 <sprintputch+0x1f>
		*b->buf++ = ch;
  8016ad:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016b0:	89 08                	mov    %ecx,(%eax)
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	88 02                	mov    %al,(%edx)
}
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <printfmt>:
{
  8016b9:	f3 0f 1e fb          	endbr32 
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016c6:	50                   	push   %eax
  8016c7:	ff 75 10             	pushl  0x10(%ebp)
  8016ca:	ff 75 0c             	pushl  0xc(%ebp)
  8016cd:	ff 75 08             	pushl  0x8(%ebp)
  8016d0:	e8 05 00 00 00       	call   8016da <vprintfmt>
}
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <vprintfmt>:
{
  8016da:	f3 0f 1e fb          	endbr32 
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	57                   	push   %edi
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 3c             	sub    $0x3c,%esp
  8016e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ed:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016f0:	e9 8e 03 00 00       	jmp    801a83 <vprintfmt+0x3a9>
		padc = ' ';
  8016f5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016f9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801700:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801707:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80170e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801713:	8d 47 01             	lea    0x1(%edi),%eax
  801716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801719:	0f b6 17             	movzbl (%edi),%edx
  80171c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80171f:	3c 55                	cmp    $0x55,%al
  801721:	0f 87 df 03 00 00    	ja     801b06 <vprintfmt+0x42c>
  801727:	0f b6 c0             	movzbl %al,%eax
  80172a:	3e ff 24 85 40 26 80 	notrack jmp *0x802640(,%eax,4)
  801731:	00 
  801732:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801735:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801739:	eb d8                	jmp    801713 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80173b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80173e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801742:	eb cf                	jmp    801713 <vprintfmt+0x39>
  801744:	0f b6 d2             	movzbl %dl,%edx
  801747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80174a:	b8 00 00 00 00       	mov    $0x0,%eax
  80174f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801752:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801755:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801759:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80175c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80175f:	83 f9 09             	cmp    $0x9,%ecx
  801762:	77 55                	ja     8017b9 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801764:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801767:	eb e9                	jmp    801752 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801769:	8b 45 14             	mov    0x14(%ebp),%eax
  80176c:	8b 00                	mov    (%eax),%eax
  80176e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801771:	8b 45 14             	mov    0x14(%ebp),%eax
  801774:	8d 40 04             	lea    0x4(%eax),%eax
  801777:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80177a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80177d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801781:	79 90                	jns    801713 <vprintfmt+0x39>
				width = precision, precision = -1;
  801783:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801786:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801789:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801790:	eb 81                	jmp    801713 <vprintfmt+0x39>
  801792:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801795:	85 c0                	test   %eax,%eax
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	0f 49 d0             	cmovns %eax,%edx
  80179f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017a5:	e9 69 ff ff ff       	jmp    801713 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017ad:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017b4:	e9 5a ff ff ff       	jmp    801713 <vprintfmt+0x39>
  8017b9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017bf:	eb bc                	jmp    80177d <vprintfmt+0xa3>
			lflag++;
  8017c1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017c7:	e9 47 ff ff ff       	jmp    801713 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017cf:	8d 78 04             	lea    0x4(%eax),%edi
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	53                   	push   %ebx
  8017d6:	ff 30                	pushl  (%eax)
  8017d8:	ff d6                	call   *%esi
			break;
  8017da:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017dd:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017e0:	e9 9b 02 00 00       	jmp    801a80 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8017e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e8:	8d 78 04             	lea    0x4(%eax),%edi
  8017eb:	8b 00                	mov    (%eax),%eax
  8017ed:	99                   	cltd   
  8017ee:	31 d0                	xor    %edx,%eax
  8017f0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f2:	83 f8 0f             	cmp    $0xf,%eax
  8017f5:	7f 23                	jg     80181a <vprintfmt+0x140>
  8017f7:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  8017fe:	85 d2                	test   %edx,%edx
  801800:	74 18                	je     80181a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801802:	52                   	push   %edx
  801803:	68 f5 23 80 00       	push   $0x8023f5
  801808:	53                   	push   %ebx
  801809:	56                   	push   %esi
  80180a:	e8 aa fe ff ff       	call   8016b9 <printfmt>
  80180f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801812:	89 7d 14             	mov    %edi,0x14(%ebp)
  801815:	e9 66 02 00 00       	jmp    801a80 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80181a:	50                   	push   %eax
  80181b:	68 0f 25 80 00       	push   $0x80250f
  801820:	53                   	push   %ebx
  801821:	56                   	push   %esi
  801822:	e8 92 fe ff ff       	call   8016b9 <printfmt>
  801827:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80182a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80182d:	e9 4e 02 00 00       	jmp    801a80 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801832:	8b 45 14             	mov    0x14(%ebp),%eax
  801835:	83 c0 04             	add    $0x4,%eax
  801838:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80183b:	8b 45 14             	mov    0x14(%ebp),%eax
  80183e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801840:	85 d2                	test   %edx,%edx
  801842:	b8 08 25 80 00       	mov    $0x802508,%eax
  801847:	0f 45 c2             	cmovne %edx,%eax
  80184a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80184d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801851:	7e 06                	jle    801859 <vprintfmt+0x17f>
  801853:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801857:	75 0d                	jne    801866 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  801859:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80185c:	89 c7                	mov    %eax,%edi
  80185e:	03 45 e0             	add    -0x20(%ebp),%eax
  801861:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801864:	eb 55                	jmp    8018bb <vprintfmt+0x1e1>
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	ff 75 d8             	pushl  -0x28(%ebp)
  80186c:	ff 75 cc             	pushl  -0x34(%ebp)
  80186f:	e8 46 03 00 00       	call   801bba <strnlen>
  801874:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801877:	29 c2                	sub    %eax,%edx
  801879:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801881:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801885:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801888:	85 ff                	test   %edi,%edi
  80188a:	7e 11                	jle    80189d <vprintfmt+0x1c3>
					putch(padc, putdat);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	53                   	push   %ebx
  801890:	ff 75 e0             	pushl  -0x20(%ebp)
  801893:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801895:	83 ef 01             	sub    $0x1,%edi
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	eb eb                	jmp    801888 <vprintfmt+0x1ae>
  80189d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018a0:	85 d2                	test   %edx,%edx
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a7:	0f 49 c2             	cmovns %edx,%eax
  8018aa:	29 c2                	sub    %eax,%edx
  8018ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018af:	eb a8                	jmp    801859 <vprintfmt+0x17f>
					putch(ch, putdat);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	53                   	push   %ebx
  8018b5:	52                   	push   %edx
  8018b6:	ff d6                	call   *%esi
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018be:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018c0:	83 c7 01             	add    $0x1,%edi
  8018c3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018c7:	0f be d0             	movsbl %al,%edx
  8018ca:	85 d2                	test   %edx,%edx
  8018cc:	74 4b                	je     801919 <vprintfmt+0x23f>
  8018ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018d2:	78 06                	js     8018da <vprintfmt+0x200>
  8018d4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018d8:	78 1e                	js     8018f8 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8018da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018de:	74 d1                	je     8018b1 <vprintfmt+0x1d7>
  8018e0:	0f be c0             	movsbl %al,%eax
  8018e3:	83 e8 20             	sub    $0x20,%eax
  8018e6:	83 f8 5e             	cmp    $0x5e,%eax
  8018e9:	76 c6                	jbe    8018b1 <vprintfmt+0x1d7>
					putch('?', putdat);
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	53                   	push   %ebx
  8018ef:	6a 3f                	push   $0x3f
  8018f1:	ff d6                	call   *%esi
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	eb c3                	jmp    8018bb <vprintfmt+0x1e1>
  8018f8:	89 cf                	mov    %ecx,%edi
  8018fa:	eb 0e                	jmp    80190a <vprintfmt+0x230>
				putch(' ', putdat);
  8018fc:	83 ec 08             	sub    $0x8,%esp
  8018ff:	53                   	push   %ebx
  801900:	6a 20                	push   $0x20
  801902:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801904:	83 ef 01             	sub    $0x1,%edi
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	85 ff                	test   %edi,%edi
  80190c:	7f ee                	jg     8018fc <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80190e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801911:	89 45 14             	mov    %eax,0x14(%ebp)
  801914:	e9 67 01 00 00       	jmp    801a80 <vprintfmt+0x3a6>
  801919:	89 cf                	mov    %ecx,%edi
  80191b:	eb ed                	jmp    80190a <vprintfmt+0x230>
	if (lflag >= 2)
  80191d:	83 f9 01             	cmp    $0x1,%ecx
  801920:	7f 1b                	jg     80193d <vprintfmt+0x263>
	else if (lflag)
  801922:	85 c9                	test   %ecx,%ecx
  801924:	74 63                	je     801989 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801926:	8b 45 14             	mov    0x14(%ebp),%eax
  801929:	8b 00                	mov    (%eax),%eax
  80192b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80192e:	99                   	cltd   
  80192f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801932:	8b 45 14             	mov    0x14(%ebp),%eax
  801935:	8d 40 04             	lea    0x4(%eax),%eax
  801938:	89 45 14             	mov    %eax,0x14(%ebp)
  80193b:	eb 17                	jmp    801954 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80193d:	8b 45 14             	mov    0x14(%ebp),%eax
  801940:	8b 50 04             	mov    0x4(%eax),%edx
  801943:	8b 00                	mov    (%eax),%eax
  801945:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801948:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80194b:	8b 45 14             	mov    0x14(%ebp),%eax
  80194e:	8d 40 08             	lea    0x8(%eax),%eax
  801951:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801954:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801957:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80195a:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80195f:	85 c9                	test   %ecx,%ecx
  801961:	0f 89 ff 00 00 00    	jns    801a66 <vprintfmt+0x38c>
				putch('-', putdat);
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	53                   	push   %ebx
  80196b:	6a 2d                	push   $0x2d
  80196d:	ff d6                	call   *%esi
				num = -(long long) num;
  80196f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801972:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801975:	f7 da                	neg    %edx
  801977:	83 d1 00             	adc    $0x0,%ecx
  80197a:	f7 d9                	neg    %ecx
  80197c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80197f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801984:	e9 dd 00 00 00       	jmp    801a66 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  801989:	8b 45 14             	mov    0x14(%ebp),%eax
  80198c:	8b 00                	mov    (%eax),%eax
  80198e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801991:	99                   	cltd   
  801992:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801995:	8b 45 14             	mov    0x14(%ebp),%eax
  801998:	8d 40 04             	lea    0x4(%eax),%eax
  80199b:	89 45 14             	mov    %eax,0x14(%ebp)
  80199e:	eb b4                	jmp    801954 <vprintfmt+0x27a>
	if (lflag >= 2)
  8019a0:	83 f9 01             	cmp    $0x1,%ecx
  8019a3:	7f 1e                	jg     8019c3 <vprintfmt+0x2e9>
	else if (lflag)
  8019a5:	85 c9                	test   %ecx,%ecx
  8019a7:	74 32                	je     8019db <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ac:	8b 10                	mov    (%eax),%edx
  8019ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019b3:	8d 40 04             	lea    0x4(%eax),%eax
  8019b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019be:	e9 a3 00 00 00       	jmp    801a66 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c6:	8b 10                	mov    (%eax),%edx
  8019c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8019cb:	8d 40 08             	lea    0x8(%eax),%eax
  8019ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019d1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8019d6:	e9 8b 00 00 00       	jmp    801a66 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	8b 10                	mov    (%eax),%edx
  8019e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e5:	8d 40 04             	lea    0x4(%eax),%eax
  8019e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019eb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8019f0:	eb 74                	jmp    801a66 <vprintfmt+0x38c>
	if (lflag >= 2)
  8019f2:	83 f9 01             	cmp    $0x1,%ecx
  8019f5:	7f 1b                	jg     801a12 <vprintfmt+0x338>
	else if (lflag)
  8019f7:	85 c9                	test   %ecx,%ecx
  8019f9:	74 2c                	je     801a27 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8019fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fe:	8b 10                	mov    (%eax),%edx
  801a00:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a05:	8d 40 04             	lea    0x4(%eax),%eax
  801a08:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a0b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a10:	eb 54                	jmp    801a66 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a12:	8b 45 14             	mov    0x14(%ebp),%eax
  801a15:	8b 10                	mov    (%eax),%edx
  801a17:	8b 48 04             	mov    0x4(%eax),%ecx
  801a1a:	8d 40 08             	lea    0x8(%eax),%eax
  801a1d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a20:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a25:	eb 3f                	jmp    801a66 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a27:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2a:	8b 10                	mov    (%eax),%edx
  801a2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a31:	8d 40 04             	lea    0x4(%eax),%eax
  801a34:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a37:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a3c:	eb 28                	jmp    801a66 <vprintfmt+0x38c>
			putch('0', putdat);
  801a3e:	83 ec 08             	sub    $0x8,%esp
  801a41:	53                   	push   %ebx
  801a42:	6a 30                	push   $0x30
  801a44:	ff d6                	call   *%esi
			putch('x', putdat);
  801a46:	83 c4 08             	add    $0x8,%esp
  801a49:	53                   	push   %ebx
  801a4a:	6a 78                	push   $0x78
  801a4c:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a4e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a51:	8b 10                	mov    (%eax),%edx
  801a53:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a58:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a5b:	8d 40 04             	lea    0x4(%eax),%eax
  801a5e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a61:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a6d:	57                   	push   %edi
  801a6e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a71:	50                   	push   %eax
  801a72:	51                   	push   %ecx
  801a73:	52                   	push   %edx
  801a74:	89 da                	mov    %ebx,%edx
  801a76:	89 f0                	mov    %esi,%eax
  801a78:	e8 72 fb ff ff       	call   8015ef <printnum>
			break;
  801a7d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801a80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801a83:	83 c7 01             	add    $0x1,%edi
  801a86:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a8a:	83 f8 25             	cmp    $0x25,%eax
  801a8d:	0f 84 62 fc ff ff    	je     8016f5 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801a93:	85 c0                	test   %eax,%eax
  801a95:	0f 84 8b 00 00 00    	je     801b26 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801a9b:	83 ec 08             	sub    $0x8,%esp
  801a9e:	53                   	push   %ebx
  801a9f:	50                   	push   %eax
  801aa0:	ff d6                	call   *%esi
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb dc                	jmp    801a83 <vprintfmt+0x3a9>
	if (lflag >= 2)
  801aa7:	83 f9 01             	cmp    $0x1,%ecx
  801aaa:	7f 1b                	jg     801ac7 <vprintfmt+0x3ed>
	else if (lflag)
  801aac:	85 c9                	test   %ecx,%ecx
  801aae:	74 2c                	je     801adc <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab3:	8b 10                	mov    (%eax),%edx
  801ab5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aba:	8d 40 04             	lea    0x4(%eax),%eax
  801abd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ac0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801ac5:	eb 9f                	jmp    801a66 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801ac7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aca:	8b 10                	mov    (%eax),%edx
  801acc:	8b 48 04             	mov    0x4(%eax),%ecx
  801acf:	8d 40 08             	lea    0x8(%eax),%eax
  801ad2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ad5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801ada:	eb 8a                	jmp    801a66 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801adc:	8b 45 14             	mov    0x14(%ebp),%eax
  801adf:	8b 10                	mov    (%eax),%edx
  801ae1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ae6:	8d 40 04             	lea    0x4(%eax),%eax
  801ae9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aec:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801af1:	e9 70 ff ff ff       	jmp    801a66 <vprintfmt+0x38c>
			putch(ch, putdat);
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	53                   	push   %ebx
  801afa:	6a 25                	push   $0x25
  801afc:	ff d6                	call   *%esi
			break;
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	e9 7a ff ff ff       	jmp    801a80 <vprintfmt+0x3a6>
			putch('%', putdat);
  801b06:	83 ec 08             	sub    $0x8,%esp
  801b09:	53                   	push   %ebx
  801b0a:	6a 25                	push   $0x25
  801b0c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	89 f8                	mov    %edi,%eax
  801b13:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b17:	74 05                	je     801b1e <vprintfmt+0x444>
  801b19:	83 e8 01             	sub    $0x1,%eax
  801b1c:	eb f5                	jmp    801b13 <vprintfmt+0x439>
  801b1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b21:	e9 5a ff ff ff       	jmp    801a80 <vprintfmt+0x3a6>
}
  801b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b2e:	f3 0f 1e fb          	endbr32 
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	83 ec 18             	sub    $0x18,%esp
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b41:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b45:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	74 26                	je     801b79 <vsnprintf+0x4b>
  801b53:	85 d2                	test   %edx,%edx
  801b55:	7e 22                	jle    801b79 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b57:	ff 75 14             	pushl  0x14(%ebp)
  801b5a:	ff 75 10             	pushl  0x10(%ebp)
  801b5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b60:	50                   	push   %eax
  801b61:	68 98 16 80 00       	push   $0x801698
  801b66:	e8 6f fb ff ff       	call   8016da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b6e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b74:	83 c4 10             	add    $0x10,%esp
}
  801b77:	c9                   	leave  
  801b78:	c3                   	ret    
		return -E_INVAL;
  801b79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b7e:	eb f7                	jmp    801b77 <vsnprintf+0x49>

00801b80 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b80:	f3 0f 1e fb          	endbr32 
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801b8a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b8d:	50                   	push   %eax
  801b8e:	ff 75 10             	pushl  0x10(%ebp)
  801b91:	ff 75 0c             	pushl  0xc(%ebp)
  801b94:	ff 75 08             	pushl  0x8(%ebp)
  801b97:	e8 92 ff ff ff       	call   801b2e <vsnprintf>
	va_end(ap);

	return rc;
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b9e:	f3 0f 1e fb          	endbr32 
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bb1:	74 05                	je     801bb8 <strlen+0x1a>
		n++;
  801bb3:	83 c0 01             	add    $0x1,%eax
  801bb6:	eb f5                	jmp    801bad <strlen+0xf>
	return n;
}
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bba:	f3 0f 1e fb          	endbr32 
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcc:	39 d0                	cmp    %edx,%eax
  801bce:	74 0d                	je     801bdd <strnlen+0x23>
  801bd0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801bd4:	74 05                	je     801bdb <strnlen+0x21>
		n++;
  801bd6:	83 c0 01             	add    $0x1,%eax
  801bd9:	eb f1                	jmp    801bcc <strnlen+0x12>
  801bdb:	89 c2                	mov    %eax,%edx
	return n;
}
  801bdd:	89 d0                	mov    %edx,%eax
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801be1:	f3 0f 1e fb          	endbr32 
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	53                   	push   %ebx
  801be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801bf8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801bfb:	83 c0 01             	add    $0x1,%eax
  801bfe:	84 d2                	test   %dl,%dl
  801c00:	75 f2                	jne    801bf4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c02:	89 c8                	mov    %ecx,%eax
  801c04:	5b                   	pop    %ebx
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c07:	f3 0f 1e fb          	endbr32 
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 10             	sub    $0x10,%esp
  801c12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c15:	53                   	push   %ebx
  801c16:	e8 83 ff ff ff       	call   801b9e <strlen>
  801c1b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c1e:	ff 75 0c             	pushl  0xc(%ebp)
  801c21:	01 d8                	add    %ebx,%eax
  801c23:	50                   	push   %eax
  801c24:	e8 b8 ff ff ff       	call   801be1 <strcpy>
	return dst;
}
  801c29:	89 d8                	mov    %ebx,%eax
  801c2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3f:	89 f3                	mov    %esi,%ebx
  801c41:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c44:	89 f0                	mov    %esi,%eax
  801c46:	39 d8                	cmp    %ebx,%eax
  801c48:	74 11                	je     801c5b <strncpy+0x2b>
		*dst++ = *src;
  801c4a:	83 c0 01             	add    $0x1,%eax
  801c4d:	0f b6 0a             	movzbl (%edx),%ecx
  801c50:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c53:	80 f9 01             	cmp    $0x1,%cl
  801c56:	83 da ff             	sbb    $0xffffffff,%edx
  801c59:	eb eb                	jmp    801c46 <strncpy+0x16>
	}
	return ret;
}
  801c5b:	89 f0                	mov    %esi,%eax
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c61:	f3 0f 1e fb          	endbr32 
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c70:	8b 55 10             	mov    0x10(%ebp),%edx
  801c73:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c75:	85 d2                	test   %edx,%edx
  801c77:	74 21                	je     801c9a <strlcpy+0x39>
  801c79:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c7d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801c7f:	39 c2                	cmp    %eax,%edx
  801c81:	74 14                	je     801c97 <strlcpy+0x36>
  801c83:	0f b6 19             	movzbl (%ecx),%ebx
  801c86:	84 db                	test   %bl,%bl
  801c88:	74 0b                	je     801c95 <strlcpy+0x34>
			*dst++ = *src++;
  801c8a:	83 c1 01             	add    $0x1,%ecx
  801c8d:	83 c2 01             	add    $0x1,%edx
  801c90:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c93:	eb ea                	jmp    801c7f <strlcpy+0x1e>
  801c95:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c97:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c9a:	29 f0                	sub    %esi,%eax
}
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801caa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cad:	0f b6 01             	movzbl (%ecx),%eax
  801cb0:	84 c0                	test   %al,%al
  801cb2:	74 0c                	je     801cc0 <strcmp+0x20>
  801cb4:	3a 02                	cmp    (%edx),%al
  801cb6:	75 08                	jne    801cc0 <strcmp+0x20>
		p++, q++;
  801cb8:	83 c1 01             	add    $0x1,%ecx
  801cbb:	83 c2 01             	add    $0x1,%edx
  801cbe:	eb ed                	jmp    801cad <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cc0:	0f b6 c0             	movzbl %al,%eax
  801cc3:	0f b6 12             	movzbl (%edx),%edx
  801cc6:	29 d0                	sub    %edx,%eax
}
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cca:	f3 0f 1e fb          	endbr32 
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	53                   	push   %ebx
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd8:	89 c3                	mov    %eax,%ebx
  801cda:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cdd:	eb 06                	jmp    801ce5 <strncmp+0x1b>
		n--, p++, q++;
  801cdf:	83 c0 01             	add    $0x1,%eax
  801ce2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801ce5:	39 d8                	cmp    %ebx,%eax
  801ce7:	74 16                	je     801cff <strncmp+0x35>
  801ce9:	0f b6 08             	movzbl (%eax),%ecx
  801cec:	84 c9                	test   %cl,%cl
  801cee:	74 04                	je     801cf4 <strncmp+0x2a>
  801cf0:	3a 0a                	cmp    (%edx),%cl
  801cf2:	74 eb                	je     801cdf <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cf4:	0f b6 00             	movzbl (%eax),%eax
  801cf7:	0f b6 12             	movzbl (%edx),%edx
  801cfa:	29 d0                	sub    %edx,%eax
}
  801cfc:	5b                   	pop    %ebx
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    
		return 0;
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
  801d04:	eb f6                	jmp    801cfc <strncmp+0x32>

00801d06 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d06:	f3 0f 1e fb          	endbr32 
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d14:	0f b6 10             	movzbl (%eax),%edx
  801d17:	84 d2                	test   %dl,%dl
  801d19:	74 09                	je     801d24 <strchr+0x1e>
		if (*s == c)
  801d1b:	38 ca                	cmp    %cl,%dl
  801d1d:	74 0a                	je     801d29 <strchr+0x23>
	for (; *s; s++)
  801d1f:	83 c0 01             	add    $0x1,%eax
  801d22:	eb f0                	jmp    801d14 <strchr+0xe>
			return (char *) s;
	return 0;
  801d24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d2b:	f3 0f 1e fb          	endbr32 
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d35:	6a 78                	push   $0x78
  801d37:	ff 75 08             	pushl  0x8(%ebp)
  801d3a:	e8 c7 ff ff ff       	call   801d06 <strchr>
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d4a:	eb 0d                	jmp    801d59 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d4c:	c1 e0 04             	shl    $0x4,%eax
  801d4f:	0f be d2             	movsbl %dl,%edx
  801d52:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d56:	83 c1 01             	add    $0x1,%ecx
  801d59:	0f b6 11             	movzbl (%ecx),%edx
  801d5c:	84 d2                	test   %dl,%dl
  801d5e:	74 11                	je     801d71 <atox+0x46>
		if (*p>='a'){
  801d60:	80 fa 60             	cmp    $0x60,%dl
  801d63:	7e e7                	jle    801d4c <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d65:	c1 e0 04             	shl    $0x4,%eax
  801d68:	0f be d2             	movsbl %dl,%edx
  801d6b:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d6f:	eb e5                	jmp    801d56 <atox+0x2b>
	}

	return v;

}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d73:	f3 0f 1e fb          	endbr32 
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d84:	38 ca                	cmp    %cl,%dl
  801d86:	74 09                	je     801d91 <strfind+0x1e>
  801d88:	84 d2                	test   %dl,%dl
  801d8a:	74 05                	je     801d91 <strfind+0x1e>
	for (; *s; s++)
  801d8c:	83 c0 01             	add    $0x1,%eax
  801d8f:	eb f0                	jmp    801d81 <strfind+0xe>
			break;
	return (char *) s;
}
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d93:	f3 0f 1e fb          	endbr32 
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	57                   	push   %edi
  801d9b:	56                   	push   %esi
  801d9c:	53                   	push   %ebx
  801d9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801da0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801da3:	85 c9                	test   %ecx,%ecx
  801da5:	74 31                	je     801dd8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801da7:	89 f8                	mov    %edi,%eax
  801da9:	09 c8                	or     %ecx,%eax
  801dab:	a8 03                	test   $0x3,%al
  801dad:	75 23                	jne    801dd2 <memset+0x3f>
		c &= 0xFF;
  801daf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801db3:	89 d3                	mov    %edx,%ebx
  801db5:	c1 e3 08             	shl    $0x8,%ebx
  801db8:	89 d0                	mov    %edx,%eax
  801dba:	c1 e0 18             	shl    $0x18,%eax
  801dbd:	89 d6                	mov    %edx,%esi
  801dbf:	c1 e6 10             	shl    $0x10,%esi
  801dc2:	09 f0                	or     %esi,%eax
  801dc4:	09 c2                	or     %eax,%edx
  801dc6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801dc8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801dcb:	89 d0                	mov    %edx,%eax
  801dcd:	fc                   	cld    
  801dce:	f3 ab                	rep stos %eax,%es:(%edi)
  801dd0:	eb 06                	jmp    801dd8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd5:	fc                   	cld    
  801dd6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dd8:	89 f8                	mov    %edi,%eax
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ddf:	f3 0f 1e fb          	endbr32 
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	57                   	push   %edi
  801de7:	56                   	push   %esi
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801df1:	39 c6                	cmp    %eax,%esi
  801df3:	73 32                	jae    801e27 <memmove+0x48>
  801df5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801df8:	39 c2                	cmp    %eax,%edx
  801dfa:	76 2b                	jbe    801e27 <memmove+0x48>
		s += n;
		d += n;
  801dfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dff:	89 fe                	mov    %edi,%esi
  801e01:	09 ce                	or     %ecx,%esi
  801e03:	09 d6                	or     %edx,%esi
  801e05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e0b:	75 0e                	jne    801e1b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e0d:	83 ef 04             	sub    $0x4,%edi
  801e10:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e16:	fd                   	std    
  801e17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e19:	eb 09                	jmp    801e24 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e1b:	83 ef 01             	sub    $0x1,%edi
  801e1e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e21:	fd                   	std    
  801e22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e24:	fc                   	cld    
  801e25:	eb 1a                	jmp    801e41 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e27:	89 c2                	mov    %eax,%edx
  801e29:	09 ca                	or     %ecx,%edx
  801e2b:	09 f2                	or     %esi,%edx
  801e2d:	f6 c2 03             	test   $0x3,%dl
  801e30:	75 0a                	jne    801e3c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e35:	89 c7                	mov    %eax,%edi
  801e37:	fc                   	cld    
  801e38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e3a:	eb 05                	jmp    801e41 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e3c:	89 c7                	mov    %eax,%edi
  801e3e:	fc                   	cld    
  801e3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e45:	f3 0f 1e fb          	endbr32 
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e4f:	ff 75 10             	pushl  0x10(%ebp)
  801e52:	ff 75 0c             	pushl  0xc(%ebp)
  801e55:	ff 75 08             	pushl  0x8(%ebp)
  801e58:	e8 82 ff ff ff       	call   801ddf <memmove>
}
  801e5d:	c9                   	leave  
  801e5e:	c3                   	ret    

00801e5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e5f:	f3 0f 1e fb          	endbr32 
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	56                   	push   %esi
  801e67:	53                   	push   %ebx
  801e68:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6e:	89 c6                	mov    %eax,%esi
  801e70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e73:	39 f0                	cmp    %esi,%eax
  801e75:	74 1c                	je     801e93 <memcmp+0x34>
		if (*s1 != *s2)
  801e77:	0f b6 08             	movzbl (%eax),%ecx
  801e7a:	0f b6 1a             	movzbl (%edx),%ebx
  801e7d:	38 d9                	cmp    %bl,%cl
  801e7f:	75 08                	jne    801e89 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801e81:	83 c0 01             	add    $0x1,%eax
  801e84:	83 c2 01             	add    $0x1,%edx
  801e87:	eb ea                	jmp    801e73 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801e89:	0f b6 c1             	movzbl %cl,%eax
  801e8c:	0f b6 db             	movzbl %bl,%ebx
  801e8f:	29 d8                	sub    %ebx,%eax
  801e91:	eb 05                	jmp    801e98 <memcmp+0x39>
	}

	return 0;
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e9c:	f3 0f 1e fb          	endbr32 
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ea9:	89 c2                	mov    %eax,%edx
  801eab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801eae:	39 d0                	cmp    %edx,%eax
  801eb0:	73 09                	jae    801ebb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801eb2:	38 08                	cmp    %cl,(%eax)
  801eb4:	74 05                	je     801ebb <memfind+0x1f>
	for (; s < ends; s++)
  801eb6:	83 c0 01             	add    $0x1,%eax
  801eb9:	eb f3                	jmp    801eae <memfind+0x12>
			break;
	return (void *) s;
}
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    

00801ebd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ebd:	f3 0f 1e fb          	endbr32 
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	57                   	push   %edi
  801ec5:	56                   	push   %esi
  801ec6:	53                   	push   %ebx
  801ec7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ecd:	eb 03                	jmp    801ed2 <strtol+0x15>
		s++;
  801ecf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801ed2:	0f b6 01             	movzbl (%ecx),%eax
  801ed5:	3c 20                	cmp    $0x20,%al
  801ed7:	74 f6                	je     801ecf <strtol+0x12>
  801ed9:	3c 09                	cmp    $0x9,%al
  801edb:	74 f2                	je     801ecf <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801edd:	3c 2b                	cmp    $0x2b,%al
  801edf:	74 2a                	je     801f0b <strtol+0x4e>
	int neg = 0;
  801ee1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801ee6:	3c 2d                	cmp    $0x2d,%al
  801ee8:	74 2b                	je     801f15 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801eea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ef0:	75 0f                	jne    801f01 <strtol+0x44>
  801ef2:	80 39 30             	cmpb   $0x30,(%ecx)
  801ef5:	74 28                	je     801f1f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ef7:	85 db                	test   %ebx,%ebx
  801ef9:	b8 0a 00 00 00       	mov    $0xa,%eax
  801efe:	0f 44 d8             	cmove  %eax,%ebx
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
  801f06:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f09:	eb 46                	jmp    801f51 <strtol+0x94>
		s++;
  801f0b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f0e:	bf 00 00 00 00       	mov    $0x0,%edi
  801f13:	eb d5                	jmp    801eea <strtol+0x2d>
		s++, neg = 1;
  801f15:	83 c1 01             	add    $0x1,%ecx
  801f18:	bf 01 00 00 00       	mov    $0x1,%edi
  801f1d:	eb cb                	jmp    801eea <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f23:	74 0e                	je     801f33 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f25:	85 db                	test   %ebx,%ebx
  801f27:	75 d8                	jne    801f01 <strtol+0x44>
		s++, base = 8;
  801f29:	83 c1 01             	add    $0x1,%ecx
  801f2c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f31:	eb ce                	jmp    801f01 <strtol+0x44>
		s += 2, base = 16;
  801f33:	83 c1 02             	add    $0x2,%ecx
  801f36:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f3b:	eb c4                	jmp    801f01 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f3d:	0f be d2             	movsbl %dl,%edx
  801f40:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f43:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f46:	7d 3a                	jge    801f82 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f48:	83 c1 01             	add    $0x1,%ecx
  801f4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f4f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f51:	0f b6 11             	movzbl (%ecx),%edx
  801f54:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f57:	89 f3                	mov    %esi,%ebx
  801f59:	80 fb 09             	cmp    $0x9,%bl
  801f5c:	76 df                	jbe    801f3d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f5e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f61:	89 f3                	mov    %esi,%ebx
  801f63:	80 fb 19             	cmp    $0x19,%bl
  801f66:	77 08                	ja     801f70 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f68:	0f be d2             	movsbl %dl,%edx
  801f6b:	83 ea 57             	sub    $0x57,%edx
  801f6e:	eb d3                	jmp    801f43 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f70:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f73:	89 f3                	mov    %esi,%ebx
  801f75:	80 fb 19             	cmp    $0x19,%bl
  801f78:	77 08                	ja     801f82 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f7a:	0f be d2             	movsbl %dl,%edx
  801f7d:	83 ea 37             	sub    $0x37,%edx
  801f80:	eb c1                	jmp    801f43 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801f82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f86:	74 05                	je     801f8d <strtol+0xd0>
		*endptr = (char *) s;
  801f88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801f8d:	89 c2                	mov    %eax,%edx
  801f8f:	f7 da                	neg    %edx
  801f91:	85 ff                	test   %edi,%edi
  801f93:	0f 45 c2             	cmovne %edx,%eax
}
  801f96:	5b                   	pop    %ebx
  801f97:	5e                   	pop    %esi
  801f98:	5f                   	pop    %edi
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    

00801f9b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f9b:	f3 0f 1e fb          	endbr32 
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801faa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fad:	85 c0                	test   %eax,%eax
  801faf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fb4:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	50                   	push   %eax
  801fbb:	e8 97 e2 ff ff       	call   800257 <sys_ipc_recv>
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	75 2b                	jne    801ff2 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fc7:	85 f6                	test   %esi,%esi
  801fc9:	74 0a                	je     801fd5 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fcb:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd0:	8b 40 74             	mov    0x74(%eax),%eax
  801fd3:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fd5:	85 db                	test   %ebx,%ebx
  801fd7:	74 0a                	je     801fe3 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801fd9:	a1 08 40 80 00       	mov    0x804008,%eax
  801fde:	8b 40 78             	mov    0x78(%eax),%eax
  801fe1:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801fe3:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe8:	8b 40 70             	mov    0x70(%eax),%eax
}
  801feb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fee:	5b                   	pop    %ebx
  801fef:	5e                   	pop    %esi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  801ff2:	85 f6                	test   %esi,%esi
  801ff4:	74 06                	je     801ffc <ipc_recv+0x61>
  801ff6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801ffc:	85 db                	test   %ebx,%ebx
  801ffe:	74 eb                	je     801feb <ipc_recv+0x50>
  802000:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802006:	eb e3                	jmp    801feb <ipc_recv+0x50>

00802008 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802008:	f3 0f 1e fb          	endbr32 
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	57                   	push   %edi
  802010:	56                   	push   %esi
  802011:	53                   	push   %ebx
  802012:	83 ec 0c             	sub    $0xc,%esp
  802015:	8b 7d 08             	mov    0x8(%ebp),%edi
  802018:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80201e:	85 db                	test   %ebx,%ebx
  802020:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802025:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802028:	ff 75 14             	pushl  0x14(%ebp)
  80202b:	53                   	push   %ebx
  80202c:	56                   	push   %esi
  80202d:	57                   	push   %edi
  80202e:	e8 fd e1 ff ff       	call   800230 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802039:	75 07                	jne    802042 <ipc_send+0x3a>
			sys_yield();
  80203b:	e8 ee e0 ff ff       	call   80012e <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802040:	eb e6                	jmp    802028 <ipc_send+0x20>
		}
		else if (ret == 0)
  802042:	85 c0                	test   %eax,%eax
  802044:	75 08                	jne    80204e <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802049:	5b                   	pop    %ebx
  80204a:	5e                   	pop    %esi
  80204b:	5f                   	pop    %edi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80204e:	50                   	push   %eax
  80204f:	68 ff 27 80 00       	push   $0x8027ff
  802054:	6a 48                	push   $0x48
  802056:	68 0d 28 80 00       	push   $0x80280d
  80205b:	e8 90 f4 ff ff       	call   8014f0 <_panic>

00802060 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802060:	f3 0f 1e fb          	endbr32 
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80206f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802072:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802078:	8b 52 50             	mov    0x50(%edx),%edx
  80207b:	39 ca                	cmp    %ecx,%edx
  80207d:	74 11                	je     802090 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80207f:	83 c0 01             	add    $0x1,%eax
  802082:	3d 00 04 00 00       	cmp    $0x400,%eax
  802087:	75 e6                	jne    80206f <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802089:	b8 00 00 00 00       	mov    $0x0,%eax
  80208e:	eb 0b                	jmp    80209b <ipc_find_env+0x3b>
			return envs[i].env_id;
  802090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802098:	8b 40 48             	mov    0x48(%eax),%eax
}
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80209d:	f3 0f 1e fb          	endbr32 
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a7:	89 c2                	mov    %eax,%edx
  8020a9:	c1 ea 16             	shr    $0x16,%edx
  8020ac:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020b3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020b8:	f6 c1 01             	test   $0x1,%cl
  8020bb:	74 1c                	je     8020d9 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020bd:	c1 e8 0c             	shr    $0xc,%eax
  8020c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020c7:	a8 01                	test   $0x1,%al
  8020c9:	74 0e                	je     8020d9 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020cb:	c1 e8 0c             	shr    $0xc,%eax
  8020ce:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020d5:	ef 
  8020d6:	0f b7 d2             	movzwl %dx,%edx
}
  8020d9:	89 d0                	mov    %edx,%eax
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    
  8020dd:	66 90                	xchg   %ax,%ax
  8020df:	90                   	nop

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
