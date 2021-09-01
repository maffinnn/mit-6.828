
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003d:	68 06 03 80 00       	push   $0x800306
  800042:	6a 00                	push   $0x0
  800044:	e8 e0 01 00 00       	call   800229 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800049:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 
}
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	f3 0f 1e fb          	endbr32 
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800067:	e8 bd 00 00 00       	call   800129 <sys_getenvid>
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 db                	test   %ebx,%ebx
  800080:	7e 07                	jle    800089 <libmain+0x31>
		binaryname = argv[0];
  800082:	8b 06                	mov    (%esi),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	56                   	push   %esi
  80008d:	53                   	push   %ebx
  80008e:	e8 a0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800093:	e8 0a 00 00 00       	call   8000a2 <exit>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5e                   	pop    %esi
  8000a0:	5d                   	pop    %ebp
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	f3 0f 1e fb          	endbr32 
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000ac:	e8 6d 04 00 00       	call   80051e <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 4a 00 00 00       	call   800105 <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	f3 0f 1e fb          	endbr32 
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	f3 0f 1e fb          	endbr32 
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	89 d6                	mov    %edx,%esi
  8000fe:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800105:	f3 0f 1e fb          	endbr32 
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	57                   	push   %edi
  80010d:	56                   	push   %esi
  80010e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80010f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	89 cb                	mov    %ecx,%ebx
  80011e:	89 cf                	mov    %ecx,%edi
  800120:	89 ce                	mov    %ecx,%esi
  800122:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5f                   	pop    %edi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800129:	f3 0f 1e fb          	endbr32 
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	57                   	push   %edi
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
	asm volatile("int %1\n"
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 02 00 00 00       	mov    $0x2,%eax
  80013d:	89 d1                	mov    %edx,%ecx
  80013f:	89 d3                	mov    %edx,%ebx
  800141:	89 d7                	mov    %edx,%edi
  800143:	89 d6                	mov    %edx,%esi
  800145:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_yield>:

void
sys_yield(void)
{
  80014c:	f3 0f 1e fb          	endbr32 
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	asm volatile("int %1\n"
  800156:	ba 00 00 00 00       	mov    $0x0,%edx
  80015b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800160:	89 d1                	mov    %edx,%ecx
  800162:	89 d3                	mov    %edx,%ebx
  800164:	89 d7                	mov    %edx,%edi
  800166:	89 d6                	mov    %edx,%esi
  800168:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016f:	f3 0f 1e fb          	endbr32 
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	57                   	push   %edi
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800184:	b8 04 00 00 00       	mov    $0x4,%eax
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	f3 0f 1e fb          	endbr32 
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80019f:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ad:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b3:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b5:	5b                   	pop    %ebx
  8001b6:	5e                   	pop    %esi
  8001b7:	5f                   	pop    %edi
  8001b8:	5d                   	pop    %ebp
  8001b9:	c3                   	ret    

008001ba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ba:	f3 0f 1e fb          	endbr32 
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	57                   	push   %edi
  8001c2:	56                   	push   %esi
  8001c3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8001d4:	89 df                	mov    %ebx,%edi
  8001d6:	89 de                	mov    %ebx,%esi
  8001d8:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001df:	f3 0f 1e fb          	endbr32 
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800204:	f3 0f 1e fb          	endbr32 
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80020e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800213:	8b 55 08             	mov    0x8(%ebp),%edx
  800216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800219:	b8 09 00 00 00       	mov    $0x9,%eax
  80021e:	89 df                	mov    %ebx,%edi
  800220:	89 de                	mov    %ebx,%esi
  800222:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800229:	f3 0f 1e fb          	endbr32 
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80024e:	f3 0f 1e fb          	endbr32 
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
	asm volatile("int %1\n"
  800258:	8b 55 08             	mov    0x8(%ebp),%edx
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800263:	be 00 00 00 00       	mov    $0x0,%esi
  800268:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80026b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80026e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800275:	f3 0f 1e fb          	endbr32 
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80027f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800284:	8b 55 08             	mov    0x8(%ebp),%edx
  800287:	b8 0d 00 00 00       	mov    $0xd,%eax
  80028c:	89 cb                	mov    %ecx,%ebx
  80028e:	89 cf                	mov    %ecx,%edi
  800290:	89 ce                	mov    %ecx,%esi
  800292:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800299:	f3 0f 1e fb          	endbr32 
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002ad:	89 d1                	mov    %edx,%ecx
  8002af:	89 d3                	mov    %edx,%ebx
  8002b1:	89 d7                	mov    %edx,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8002bc:	f3 0f 1e fb          	endbr32 
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002d6:	89 df                	mov    %ebx,%edi
  8002d8:	89 de                	mov    %ebx,%esi
  8002da:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002e1:	f3 0f 1e fb          	endbr32 
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8002fb:	89 df                	mov    %ebx,%edi
  8002fd:	89 de                	mov    %ebx,%esi
  8002ff:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800306:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800307:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  80030c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80030e:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  800311:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  800315:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  80031a:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  80031e:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  800320:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  800323:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  800324:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  800327:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  800328:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  800329:	c3                   	ret    

0080032a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80032a:	f3 0f 1e fb          	endbr32 
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	05 00 00 00 30       	add    $0x30000000,%eax
  800339:	c1 e8 0c             	shr    $0xc,%eax
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80033e:	f3 0f 1e fb          	endbr32 
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80034d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800352:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800359:	f3 0f 1e fb          	endbr32 
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800365:	89 c2                	mov    %eax,%edx
  800367:	c1 ea 16             	shr    $0x16,%edx
  80036a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800371:	f6 c2 01             	test   $0x1,%dl
  800374:	74 2d                	je     8003a3 <fd_alloc+0x4a>
  800376:	89 c2                	mov    %eax,%edx
  800378:	c1 ea 0c             	shr    $0xc,%edx
  80037b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800382:	f6 c2 01             	test   $0x1,%dl
  800385:	74 1c                	je     8003a3 <fd_alloc+0x4a>
  800387:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80038c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800391:	75 d2                	jne    800365 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80039c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003a1:	eb 0a                	jmp    8003ad <fd_alloc+0x54>
			*fd_store = fd;
  8003a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003af:	f3 0f 1e fb          	endbr32 
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003b9:	83 f8 1f             	cmp    $0x1f,%eax
  8003bc:	77 30                	ja     8003ee <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003be:	c1 e0 0c             	shl    $0xc,%eax
  8003c1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003c6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003cc:	f6 c2 01             	test   $0x1,%dl
  8003cf:	74 24                	je     8003f5 <fd_lookup+0x46>
  8003d1:	89 c2                	mov    %eax,%edx
  8003d3:	c1 ea 0c             	shr    $0xc,%edx
  8003d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003dd:	f6 c2 01             	test   $0x1,%dl
  8003e0:	74 1a                	je     8003fc <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    
		return -E_INVAL;
  8003ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003f3:	eb f7                	jmp    8003ec <fd_lookup+0x3d>
		return -E_INVAL;
  8003f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003fa:	eb f0                	jmp    8003ec <fd_lookup+0x3d>
  8003fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800401:	eb e9                	jmp    8003ec <fd_lookup+0x3d>

00800403 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800403:	f3 0f 1e fb          	endbr32 
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800410:	ba 00 00 00 00       	mov    $0x0,%edx
  800415:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  80041a:	39 08                	cmp    %ecx,(%eax)
  80041c:	74 38                	je     800456 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80041e:	83 c2 01             	add    $0x1,%edx
  800421:	8b 04 95 88 24 80 00 	mov    0x802488(,%edx,4),%eax
  800428:	85 c0                	test   %eax,%eax
  80042a:	75 ee                	jne    80041a <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80042c:	a1 08 40 80 00       	mov    0x804008,%eax
  800431:	8b 40 48             	mov    0x48(%eax),%eax
  800434:	83 ec 04             	sub    $0x4,%esp
  800437:	51                   	push   %ecx
  800438:	50                   	push   %eax
  800439:	68 0c 24 80 00       	push   $0x80240c
  80043e:	e8 d6 11 00 00       	call   801619 <cprintf>
	*dev = 0;
  800443:	8b 45 0c             	mov    0xc(%ebp),%eax
  800446:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800454:	c9                   	leave  
  800455:	c3                   	ret    
			*dev = devtab[i];
  800456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800459:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	eb f2                	jmp    800454 <dev_lookup+0x51>

00800462 <fd_close>:
{
  800462:	f3 0f 1e fb          	endbr32 
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	57                   	push   %edi
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
  80046c:	83 ec 24             	sub    $0x24,%esp
  80046f:	8b 75 08             	mov    0x8(%ebp),%esi
  800472:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800475:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800478:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800479:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800482:	50                   	push   %eax
  800483:	e8 27 ff ff ff       	call   8003af <fd_lookup>
  800488:	89 c3                	mov    %eax,%ebx
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	85 c0                	test   %eax,%eax
  80048f:	78 05                	js     800496 <fd_close+0x34>
	    || fd != fd2)
  800491:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800494:	74 16                	je     8004ac <fd_close+0x4a>
		return (must_exist ? r : 0);
  800496:	89 f8                	mov    %edi,%eax
  800498:	84 c0                	test   %al,%al
  80049a:	b8 00 00 00 00       	mov    $0x0,%eax
  80049f:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a2:	89 d8                	mov    %ebx,%eax
  8004a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a7:	5b                   	pop    %ebx
  8004a8:	5e                   	pop    %esi
  8004a9:	5f                   	pop    %edi
  8004aa:	5d                   	pop    %ebp
  8004ab:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 49 ff ff ff       	call   800403 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x7b>
		if (dev->dev_close)
  8004c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 d2 fc ff ff       	call   8001ba <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	eb b5                	jmp    8004a2 <fd_close+0x40>

008004ed <close>:

int
close(int fdnum)
{
  8004ed:	f3 0f 1e fb          	endbr32 
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fa:	50                   	push   %eax
  8004fb:	ff 75 08             	pushl  0x8(%ebp)
  8004fe:	e8 ac fe ff ff       	call   8003af <fd_lookup>
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 c0                	test   %eax,%eax
  800508:	79 02                	jns    80050c <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    
		return fd_close(fd, 1);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	6a 01                	push   $0x1
  800511:	ff 75 f4             	pushl  -0xc(%ebp)
  800514:	e8 49 ff ff ff       	call   800462 <fd_close>
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb ec                	jmp    80050a <close+0x1d>

0080051e <close_all>:

void
close_all(void)
{
  80051e:	f3 0f 1e fb          	endbr32 
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 b6 ff ff ff       	call   8004ed <close>
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0x10>
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	f3 0f 1e fb          	endbr32 
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800554:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800557:	50                   	push   %eax
  800558:	ff 75 08             	pushl  0x8(%ebp)
  80055b:	e8 4f fe ff ff       	call   8003af <fd_lookup>
  800560:	89 c3                	mov    %eax,%ebx
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	85 c0                	test   %eax,%eax
  800567:	0f 88 81 00 00 00    	js     8005ee <dup+0xa7>
		return r;
	close(newfdnum);
  80056d:	83 ec 0c             	sub    $0xc,%esp
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	e8 75 ff ff ff       	call   8004ed <close>

	newfd = INDEX2FD(newfdnum);
  800578:	8b 75 0c             	mov    0xc(%ebp),%esi
  80057b:	c1 e6 0c             	shl    $0xc,%esi
  80057e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800584:	83 c4 04             	add    $0x4,%esp
  800587:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058a:	e8 af fd ff ff       	call   80033e <fd2data>
  80058f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800591:	89 34 24             	mov    %esi,(%esp)
  800594:	e8 a5 fd ff ff       	call   80033e <fd2data>
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059e:	89 d8                	mov    %ebx,%eax
  8005a0:	c1 e8 16             	shr    $0x16,%eax
  8005a3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005aa:	a8 01                	test   $0x1,%al
  8005ac:	74 11                	je     8005bf <dup+0x78>
  8005ae:	89 d8                	mov    %ebx,%eax
  8005b0:	c1 e8 0c             	shr    $0xc,%eax
  8005b3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ba:	f6 c2 01             	test   $0x1,%dl
  8005bd:	75 39                	jne    8005f8 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c2:	89 d0                	mov    %edx,%eax
  8005c4:	c1 e8 0c             	shr    $0xc,%eax
  8005c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ce:	83 ec 0c             	sub    $0xc,%esp
  8005d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d6:	50                   	push   %eax
  8005d7:	56                   	push   %esi
  8005d8:	6a 00                	push   $0x0
  8005da:	52                   	push   %edx
  8005db:	6a 00                	push   $0x0
  8005dd:	e8 b3 fb ff ff       	call   800195 <sys_page_map>
  8005e2:	89 c3                	mov    %eax,%ebx
  8005e4:	83 c4 20             	add    $0x20,%esp
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	78 31                	js     80061c <dup+0xd5>
		goto err;

	return newfdnum;
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ee:	89 d8                	mov    %ebx,%eax
  8005f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f3:	5b                   	pop    %ebx
  8005f4:	5e                   	pop    %esi
  8005f5:	5f                   	pop    %edi
  8005f6:	5d                   	pop    %ebp
  8005f7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	25 07 0e 00 00       	and    $0xe07,%eax
  800607:	50                   	push   %eax
  800608:	57                   	push   %edi
  800609:	6a 00                	push   $0x0
  80060b:	53                   	push   %ebx
  80060c:	6a 00                	push   $0x0
  80060e:	e8 82 fb ff ff       	call   800195 <sys_page_map>
  800613:	89 c3                	mov    %eax,%ebx
  800615:	83 c4 20             	add    $0x20,%esp
  800618:	85 c0                	test   %eax,%eax
  80061a:	79 a3                	jns    8005bf <dup+0x78>
	sys_page_unmap(0, newfd);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	56                   	push   %esi
  800620:	6a 00                	push   $0x0
  800622:	e8 93 fb ff ff       	call   8001ba <sys_page_unmap>
	sys_page_unmap(0, nva);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	6a 00                	push   $0x0
  80062d:	e8 88 fb ff ff       	call   8001ba <sys_page_unmap>
	return r;
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb b7                	jmp    8005ee <dup+0xa7>

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	f3 0f 1e fb          	endbr32 
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	53                   	push   %ebx
  80063f:	83 ec 1c             	sub    $0x1c,%esp
  800642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	53                   	push   %ebx
  80064a:	e8 60 fd ff ff       	call   8003af <fd_lookup>
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	85 c0                	test   %eax,%eax
  800654:	78 3f                	js     800695 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800660:	ff 30                	pushl  (%eax)
  800662:	e8 9c fd ff ff       	call   800403 <dev_lookup>
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	85 c0                	test   %eax,%eax
  80066c:	78 27                	js     800695 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800671:	8b 42 08             	mov    0x8(%edx),%eax
  800674:	83 e0 03             	and    $0x3,%eax
  800677:	83 f8 01             	cmp    $0x1,%eax
  80067a:	74 1e                	je     80069a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80067c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067f:	8b 40 08             	mov    0x8(%eax),%eax
  800682:	85 c0                	test   %eax,%eax
  800684:	74 35                	je     8006bb <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800686:	83 ec 04             	sub    $0x4,%esp
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	52                   	push   %edx
  800690:	ff d0                	call   *%eax
  800692:	83 c4 10             	add    $0x10,%esp
}
  800695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800698:	c9                   	leave  
  800699:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069a:	a1 08 40 80 00       	mov    0x804008,%eax
  80069f:	8b 40 48             	mov    0x48(%eax),%eax
  8006a2:	83 ec 04             	sub    $0x4,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	50                   	push   %eax
  8006a7:	68 4d 24 80 00       	push   $0x80244d
  8006ac:	e8 68 0f 00 00       	call   801619 <cprintf>
		return -E_INVAL;
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b9:	eb da                	jmp    800695 <read+0x5e>
		return -E_NOT_SUPP;
  8006bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c0:	eb d3                	jmp    800695 <read+0x5e>

008006c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c2:	f3 0f 1e fb          	endbr32 
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	57                   	push   %edi
  8006ca:	56                   	push   %esi
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 0c             	sub    $0xc,%esp
  8006cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006da:	eb 02                	jmp    8006de <readn+0x1c>
  8006dc:	01 c3                	add    %eax,%ebx
  8006de:	39 f3                	cmp    %esi,%ebx
  8006e0:	73 21                	jae    800703 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e2:	83 ec 04             	sub    $0x4,%esp
  8006e5:	89 f0                	mov    %esi,%eax
  8006e7:	29 d8                	sub    %ebx,%eax
  8006e9:	50                   	push   %eax
  8006ea:	89 d8                	mov    %ebx,%eax
  8006ec:	03 45 0c             	add    0xc(%ebp),%eax
  8006ef:	50                   	push   %eax
  8006f0:	57                   	push   %edi
  8006f1:	e8 41 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	78 04                	js     800701 <readn+0x3f>
			return m;
		if (m == 0)
  8006fd:	75 dd                	jne    8006dc <readn+0x1a>
  8006ff:	eb 02                	jmp    800703 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800701:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800703:	89 d8                	mov    %ebx,%eax
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	f3 0f 1e fb          	endbr32 
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 1c             	sub    $0x1c,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 8a fc ff ff       	call   8003af <fd_lookup>
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	85 c0                	test   %eax,%eax
  80072a:	78 3a                	js     800766 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800732:	50                   	push   %eax
  800733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800736:	ff 30                	pushl  (%eax)
  800738:	e8 c6 fc ff ff       	call   800403 <dev_lookup>
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	85 c0                	test   %eax,%eax
  800742:	78 22                	js     800766 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800744:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800747:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074b:	74 1e                	je     80076b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80074d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800750:	8b 52 0c             	mov    0xc(%edx),%edx
  800753:	85 d2                	test   %edx,%edx
  800755:	74 35                	je     80078c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	50                   	push   %eax
  800761:	ff d2                	call   *%edx
  800763:	83 c4 10             	add    $0x10,%esp
}
  800766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076b:	a1 08 40 80 00       	mov    0x804008,%eax
  800770:	8b 40 48             	mov    0x48(%eax),%eax
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	53                   	push   %ebx
  800777:	50                   	push   %eax
  800778:	68 69 24 80 00       	push   $0x802469
  80077d:	e8 97 0e 00 00       	call   801619 <cprintf>
		return -E_INVAL;
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078a:	eb da                	jmp    800766 <write+0x59>
		return -E_NOT_SUPP;
  80078c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800791:	eb d3                	jmp    800766 <write+0x59>

00800793 <seek>:

int
seek(int fdnum, off_t offset)
{
  800793:	f3 0f 1e fb          	endbr32 
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a0:	50                   	push   %eax
  8007a1:	ff 75 08             	pushl  0x8(%ebp)
  8007a4:	e8 06 fc ff ff       	call   8003af <fd_lookup>
  8007a9:	83 c4 10             	add    $0x10,%esp
  8007ac:	85 c0                	test   %eax,%eax
  8007ae:	78 0e                	js     8007be <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c0:	f3 0f 1e fb          	endbr32 
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	83 ec 1c             	sub    $0x1c,%esp
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d1:	50                   	push   %eax
  8007d2:	53                   	push   %ebx
  8007d3:	e8 d7 fb ff ff       	call   8003af <fd_lookup>
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 37                	js     800816 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 13 fc ff ff       	call   800403 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 1f                	js     800816 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	74 1b                	je     80081b <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800800:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800803:	8b 52 18             	mov    0x18(%edx),%edx
  800806:	85 d2                	test   %edx,%edx
  800808:	74 32                	je     80083c <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	ff 75 0c             	pushl  0xc(%ebp)
  800810:	50                   	push   %eax
  800811:	ff d2                	call   *%edx
  800813:	83 c4 10             	add    $0x10,%esp
}
  800816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800819:	c9                   	leave  
  80081a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80081b:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 2c 24 80 00       	push   $0x80242c
  80082d:	e8 e7 0d 00 00       	call   801619 <cprintf>
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083a:	eb da                	jmp    800816 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80083c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800841:	eb d3                	jmp    800816 <ftruncate+0x56>

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	f3 0f 1e fb          	endbr32 
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	83 ec 1c             	sub    $0x1c,%esp
  80084e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800851:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800854:	50                   	push   %eax
  800855:	ff 75 08             	pushl  0x8(%ebp)
  800858:	e8 52 fb ff ff       	call   8003af <fd_lookup>
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	85 c0                	test   %eax,%eax
  800862:	78 4b                	js     8008af <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086a:	50                   	push   %eax
  80086b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086e:	ff 30                	pushl  (%eax)
  800870:	e8 8e fb ff ff       	call   800403 <dev_lookup>
  800875:	83 c4 10             	add    $0x10,%esp
  800878:	85 c0                	test   %eax,%eax
  80087a:	78 33                	js     8008af <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80087c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800883:	74 2f                	je     8008b4 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800885:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800888:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088f:	00 00 00 
	stat->st_isdir = 0;
  800892:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800899:	00 00 00 
	stat->st_dev = dev;
  80089c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a2:	83 ec 08             	sub    $0x8,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a9:	ff 50 14             	call   *0x14(%eax)
  8008ac:	83 c4 10             	add    $0x10,%esp
}
  8008af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    
		return -E_NOT_SUPP;
  8008b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008b9:	eb f4                	jmp    8008af <fstat+0x6c>

008008bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bb:	f3 0f 1e fb          	endbr32 
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	6a 00                	push   $0x0
  8008c9:	ff 75 08             	pushl  0x8(%ebp)
  8008cc:	e8 01 02 00 00       	call   800ad2 <open>
  8008d1:	89 c3                	mov    %eax,%ebx
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	78 1b                	js     8008f5 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008da:	83 ec 08             	sub    $0x8,%esp
  8008dd:	ff 75 0c             	pushl  0xc(%ebp)
  8008e0:	50                   	push   %eax
  8008e1:	e8 5d ff ff ff       	call   800843 <fstat>
  8008e6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e8:	89 1c 24             	mov    %ebx,(%esp)
  8008eb:	e8 fd fb ff ff       	call   8004ed <close>
	return r;
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	89 f3                	mov    %esi,%ebx
}
  8008f5:	89 d8                	mov    %ebx,%eax
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	74 27                	je     800937 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800910:	6a 07                	push   $0x7
  800912:	68 00 50 80 00       	push   $0x805000
  800917:	56                   	push   %esi
  800918:	ff 35 00 40 80 00    	pushl  0x804000
  80091e:	e8 9a 17 00 00       	call   8020bd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800923:	83 c4 0c             	add    $0xc,%esp
  800926:	6a 00                	push   $0x0
  800928:	53                   	push   %ebx
  800929:	6a 00                	push   $0x0
  80092b:	e8 20 17 00 00       	call   802050 <ipc_recv>
}
  800930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	6a 01                	push   $0x1
  80093c:	e8 d4 17 00 00       	call   802115 <ipc_find_env>
  800941:	a3 00 40 80 00       	mov    %eax,0x804000
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	eb c5                	jmp    800910 <fsipc+0x12>

0080094b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094b:	f3 0f 1e fb          	endbr32 
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 40 0c             	mov    0xc(%eax),%eax
  80095b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800960:	8b 45 0c             	mov    0xc(%ebp),%eax
  800963:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800968:	ba 00 00 00 00       	mov    $0x0,%edx
  80096d:	b8 02 00 00 00       	mov    $0x2,%eax
  800972:	e8 87 ff ff ff       	call   8008fe <fsipc>
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <devfile_flush>:
{
  800979:	f3 0f 1e fb          	endbr32 
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 40 0c             	mov    0xc(%eax),%eax
  800989:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098e:	ba 00 00 00 00       	mov    $0x0,%edx
  800993:	b8 06 00 00 00       	mov    $0x6,%eax
  800998:	e8 61 ff ff ff       	call   8008fe <fsipc>
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <devfile_stat>:
{
  80099f:	f3 0f 1e fb          	endbr32 
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	53                   	push   %ebx
  8009a7:	83 ec 04             	sub    $0x4,%esp
  8009aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c2:	e8 37 ff ff ff       	call   8008fe <fsipc>
  8009c7:	85 c0                	test   %eax,%eax
  8009c9:	78 2c                	js     8009f7 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009cb:	83 ec 08             	sub    $0x8,%esp
  8009ce:	68 00 50 80 00       	push   $0x805000
  8009d3:	53                   	push   %ebx
  8009d4:	e8 4a 12 00 00       	call   801c23 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ef:	83 c4 10             	add    $0x10,%esp
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <devfile_write>:
{
  8009fc:	f3 0f 1e fb          	endbr32 
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 0c             	sub    $0xc,%esp
  800a06:	8b 45 10             	mov    0x10(%ebp),%eax
  800a09:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a0e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a13:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a16:	8b 55 08             	mov    0x8(%ebp),%edx
  800a19:	8b 52 0c             	mov    0xc(%edx),%edx
  800a1c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a22:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a27:	50                   	push   %eax
  800a28:	ff 75 0c             	pushl  0xc(%ebp)
  800a2b:	68 08 50 80 00       	push   $0x805008
  800a30:	e8 ec 13 00 00       	call   801e21 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3f:	e8 ba fe ff ff       	call   8008fe <fsipc>
}
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <devfile_read>:
{
  800a46:	f3 0f 1e fb          	endbr32 
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 40 0c             	mov    0xc(%eax),%eax
  800a58:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a5d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6d:	e8 8c fe ff ff       	call   8008fe <fsipc>
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	85 c0                	test   %eax,%eax
  800a76:	78 1f                	js     800a97 <devfile_read+0x51>
	assert(r <= n);
  800a78:	39 f0                	cmp    %esi,%eax
  800a7a:	77 24                	ja     800aa0 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a81:	7f 36                	jg     800ab9 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a83:	83 ec 04             	sub    $0x4,%esp
  800a86:	50                   	push   %eax
  800a87:	68 00 50 80 00       	push   $0x805000
  800a8c:	ff 75 0c             	pushl  0xc(%ebp)
  800a8f:	e8 8d 13 00 00       	call   801e21 <memmove>
	return r;
  800a94:	83 c4 10             	add    $0x10,%esp
}
  800a97:	89 d8                	mov    %ebx,%eax
  800a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    
	assert(r <= n);
  800aa0:	68 9c 24 80 00       	push   $0x80249c
  800aa5:	68 a3 24 80 00       	push   $0x8024a3
  800aaa:	68 8c 00 00 00       	push   $0x8c
  800aaf:	68 b8 24 80 00       	push   $0x8024b8
  800ab4:	e8 79 0a 00 00       	call   801532 <_panic>
	assert(r <= PGSIZE);
  800ab9:	68 c3 24 80 00       	push   $0x8024c3
  800abe:	68 a3 24 80 00       	push   $0x8024a3
  800ac3:	68 8d 00 00 00       	push   $0x8d
  800ac8:	68 b8 24 80 00       	push   $0x8024b8
  800acd:	e8 60 0a 00 00       	call   801532 <_panic>

00800ad2 <open>:
{
  800ad2:	f3 0f 1e fb          	endbr32 
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	83 ec 1c             	sub    $0x1c,%esp
  800ade:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ae1:	56                   	push   %esi
  800ae2:	e8 f9 10 00 00       	call   801be0 <strlen>
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aef:	7f 6c                	jg     800b5d <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af7:	50                   	push   %eax
  800af8:	e8 5c f8 ff ff       	call   800359 <fd_alloc>
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	83 c4 10             	add    $0x10,%esp
  800b02:	85 c0                	test   %eax,%eax
  800b04:	78 3c                	js     800b42 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b06:	83 ec 08             	sub    $0x8,%esp
  800b09:	56                   	push   %esi
  800b0a:	68 00 50 80 00       	push   $0x805000
  800b0f:	e8 0f 11 00 00       	call   801c23 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b17:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b24:	e8 d5 fd ff ff       	call   8008fe <fsipc>
  800b29:	89 c3                	mov    %eax,%ebx
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 19                	js     800b4b <open+0x79>
	return fd2num(fd);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 f4             	pushl  -0xc(%ebp)
  800b38:	e8 ed f7 ff ff       	call   80032a <fd2num>
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	83 c4 10             	add    $0x10,%esp
}
  800b42:	89 d8                	mov    %ebx,%eax
  800b44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    
		fd_close(fd, 0);
  800b4b:	83 ec 08             	sub    $0x8,%esp
  800b4e:	6a 00                	push   $0x0
  800b50:	ff 75 f4             	pushl  -0xc(%ebp)
  800b53:	e8 0a f9 ff ff       	call   800462 <fd_close>
		return r;
  800b58:	83 c4 10             	add    $0x10,%esp
  800b5b:	eb e5                	jmp    800b42 <open+0x70>
		return -E_BAD_PATH;
  800b5d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b62:	eb de                	jmp    800b42 <open+0x70>

00800b64 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b64:	f3 0f 1e fb          	endbr32 
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 08 00 00 00       	mov    $0x8,%eax
  800b78:	e8 81 fd ff ff       	call   8008fe <fsipc>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b7f:	f3 0f 1e fb          	endbr32 
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b89:	68 2f 25 80 00       	push   $0x80252f
  800b8e:	ff 75 0c             	pushl  0xc(%ebp)
  800b91:	e8 8d 10 00 00       	call   801c23 <strcpy>
	return 0;
}
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <devsock_close>:
{
  800b9d:	f3 0f 1e fb          	endbr32 
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 10             	sub    $0x10,%esp
  800ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bab:	53                   	push   %ebx
  800bac:	e8 a1 15 00 00       	call   802152 <pageref>
  800bb1:	89 c2                	mov    %eax,%edx
  800bb3:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bbb:	83 fa 01             	cmp    $0x1,%edx
  800bbe:	74 05                	je     800bc5 <devsock_close+0x28>
}
  800bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	ff 73 0c             	pushl  0xc(%ebx)
  800bcb:	e8 e3 02 00 00       	call   800eb3 <nsipc_close>
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	eb eb                	jmp    800bc0 <devsock_close+0x23>

00800bd5 <devsock_write>:
{
  800bd5:	f3 0f 1e fb          	endbr32 
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	ff 75 10             	pushl  0x10(%ebp)
  800be4:	ff 75 0c             	pushl  0xc(%ebp)
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	ff 70 0c             	pushl  0xc(%eax)
  800bed:	e8 b5 03 00 00       	call   800fa7 <nsipc_send>
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <devsock_read>:
{
  800bf4:	f3 0f 1e fb          	endbr32 
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bfe:	6a 00                	push   $0x0
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	ff 70 0c             	pushl  0xc(%eax)
  800c0c:	e8 1f 03 00 00       	call   800f30 <nsipc_recv>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <fd2sockid>:
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c19:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c1c:	52                   	push   %edx
  800c1d:	50                   	push   %eax
  800c1e:	e8 8c f7 ff ff       	call   8003af <fd_lookup>
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	85 c0                	test   %eax,%eax
  800c28:	78 10                	js     800c3a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2d:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800c33:	39 08                	cmp    %ecx,(%eax)
  800c35:	75 05                	jne    800c3c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c37:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    
		return -E_NOT_SUPP;
  800c3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c41:	eb f7                	jmp    800c3a <fd2sockid+0x27>

00800c43 <alloc_sockfd>:
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 1c             	sub    $0x1c,%esp
  800c4b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c50:	50                   	push   %eax
  800c51:	e8 03 f7 ff ff       	call   800359 <fd_alloc>
  800c56:	89 c3                	mov    %eax,%ebx
  800c58:	83 c4 10             	add    $0x10,%esp
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	78 43                	js     800ca2 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c5f:	83 ec 04             	sub    $0x4,%esp
  800c62:	68 07 04 00 00       	push   $0x407
  800c67:	ff 75 f4             	pushl  -0xc(%ebp)
  800c6a:	6a 00                	push   $0x0
  800c6c:	e8 fe f4 ff ff       	call   80016f <sys_page_alloc>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	85 c0                	test   %eax,%eax
  800c78:	78 28                	js     800ca2 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7d:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c83:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c8f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	e8 8f f6 ff ff       	call   80032a <fd2num>
  800c9b:	89 c3                	mov    %eax,%ebx
  800c9d:	83 c4 10             	add    $0x10,%esp
  800ca0:	eb 0c                	jmp    800cae <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	56                   	push   %esi
  800ca6:	e8 08 02 00 00       	call   800eb3 <nsipc_close>
		return r;
  800cab:	83 c4 10             	add    $0x10,%esp
}
  800cae:	89 d8                	mov    %ebx,%eax
  800cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <accept>:
{
  800cb7:	f3 0f 1e fb          	endbr32 
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc4:	e8 4a ff ff ff       	call   800c13 <fd2sockid>
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	78 1b                	js     800ce8 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ccd:	83 ec 04             	sub    $0x4,%esp
  800cd0:	ff 75 10             	pushl  0x10(%ebp)
  800cd3:	ff 75 0c             	pushl  0xc(%ebp)
  800cd6:	50                   	push   %eax
  800cd7:	e8 22 01 00 00       	call   800dfe <nsipc_accept>
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	78 05                	js     800ce8 <accept+0x31>
	return alloc_sockfd(r);
  800ce3:	e8 5b ff ff ff       	call   800c43 <alloc_sockfd>
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    

00800cea <bind>:
{
  800cea:	f3 0f 1e fb          	endbr32 
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	e8 17 ff ff ff       	call   800c13 <fd2sockid>
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	78 12                	js     800d12 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	ff 75 10             	pushl  0x10(%ebp)
  800d06:	ff 75 0c             	pushl  0xc(%ebp)
  800d09:	50                   	push   %eax
  800d0a:	e8 45 01 00 00       	call   800e54 <nsipc_bind>
  800d0f:	83 c4 10             	add    $0x10,%esp
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <shutdown>:
{
  800d14:	f3 0f 1e fb          	endbr32 
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	e8 ed fe ff ff       	call   800c13 <fd2sockid>
  800d26:	85 c0                	test   %eax,%eax
  800d28:	78 0f                	js     800d39 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800d2a:	83 ec 08             	sub    $0x8,%esp
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	50                   	push   %eax
  800d31:	e8 57 01 00 00       	call   800e8d <nsipc_shutdown>
  800d36:	83 c4 10             	add    $0x10,%esp
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <connect>:
{
  800d3b:	f3 0f 1e fb          	endbr32 
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	e8 c6 fe ff ff       	call   800c13 <fd2sockid>
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	78 12                	js     800d63 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	ff 75 10             	pushl  0x10(%ebp)
  800d57:	ff 75 0c             	pushl  0xc(%ebp)
  800d5a:	50                   	push   %eax
  800d5b:	e8 71 01 00 00       	call   800ed1 <nsipc_connect>
  800d60:	83 c4 10             	add    $0x10,%esp
}
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    

00800d65 <listen>:
{
  800d65:	f3 0f 1e fb          	endbr32 
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	e8 9c fe ff ff       	call   800c13 <fd2sockid>
  800d77:	85 c0                	test   %eax,%eax
  800d79:	78 0f                	js     800d8a <listen+0x25>
	return nsipc_listen(r, backlog);
  800d7b:	83 ec 08             	sub    $0x8,%esp
  800d7e:	ff 75 0c             	pushl  0xc(%ebp)
  800d81:	50                   	push   %eax
  800d82:	e8 83 01 00 00       	call   800f0a <nsipc_listen>
  800d87:	83 c4 10             	add    $0x10,%esp
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <socket>:

int
socket(int domain, int type, int protocol)
{
  800d8c:	f3 0f 1e fb          	endbr32 
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d96:	ff 75 10             	pushl  0x10(%ebp)
  800d99:	ff 75 0c             	pushl  0xc(%ebp)
  800d9c:	ff 75 08             	pushl  0x8(%ebp)
  800d9f:	e8 65 02 00 00       	call   801009 <nsipc_socket>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 05                	js     800db0 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800dab:	e8 93 fe ff ff       	call   800c43 <alloc_sockfd>
}
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	53                   	push   %ebx
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc2:	74 26                	je     800dea <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dc4:	6a 07                	push   $0x7
  800dc6:	68 00 60 80 00       	push   $0x806000
  800dcb:	53                   	push   %ebx
  800dcc:	ff 35 04 40 80 00    	pushl  0x804004
  800dd2:	e8 e6 12 00 00       	call   8020bd <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd7:	83 c4 0c             	add    $0xc,%esp
  800dda:	6a 00                	push   $0x0
  800ddc:	6a 00                	push   $0x0
  800dde:	6a 00                	push   $0x0
  800de0:	e8 6b 12 00 00       	call   802050 <ipc_recv>
}
  800de5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	6a 02                	push   $0x2
  800def:	e8 21 13 00 00       	call   802115 <ipc_find_env>
  800df4:	a3 04 40 80 00       	mov    %eax,0x804004
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	eb c6                	jmp    800dc4 <nsipc+0x12>

00800dfe <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e12:	8b 06                	mov    (%esi),%eax
  800e14:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e19:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1e:	e8 8f ff ff ff       	call   800db2 <nsipc>
  800e23:	89 c3                	mov    %eax,%ebx
  800e25:	85 c0                	test   %eax,%eax
  800e27:	79 09                	jns    800e32 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	ff 35 10 60 80 00    	pushl  0x806010
  800e3b:	68 00 60 80 00       	push   $0x806000
  800e40:	ff 75 0c             	pushl  0xc(%ebp)
  800e43:	e8 d9 0f 00 00       	call   801e21 <memmove>
		*addrlen = ret->ret_addrlen;
  800e48:	a1 10 60 80 00       	mov    0x806010,%eax
  800e4d:	89 06                	mov    %eax,(%esi)
  800e4f:	83 c4 10             	add    $0x10,%esp
	return r;
  800e52:	eb d5                	jmp    800e29 <nsipc_accept+0x2b>

00800e54 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e54:	f3 0f 1e fb          	endbr32 
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e6a:	53                   	push   %ebx
  800e6b:	ff 75 0c             	pushl  0xc(%ebp)
  800e6e:	68 04 60 80 00       	push   $0x806004
  800e73:	e8 a9 0f 00 00       	call   801e21 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e78:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e83:	e8 2a ff ff ff       	call   800db2 <nsipc>
}
  800e88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    

00800e8d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e8d:	f3 0f 1e fb          	endbr32 
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ea7:	b8 03 00 00 00       	mov    $0x3,%eax
  800eac:	e8 01 ff ff ff       	call   800db2 <nsipc>
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <nsipc_close>:

int
nsipc_close(int s)
{
  800eb3:	f3 0f 1e fb          	endbr32 
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ec5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eca:	e8 e3 fe ff ff       	call   800db2 <nsipc>
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ed1:	f3 0f 1e fb          	endbr32 
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ee7:	53                   	push   %ebx
  800ee8:	ff 75 0c             	pushl  0xc(%ebp)
  800eeb:	68 04 60 80 00       	push   $0x806004
  800ef0:	e8 2c 0f 00 00       	call   801e21 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ef5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800efb:	b8 05 00 00 00       	mov    $0x5,%eax
  800f00:	e8 ad fe ff ff       	call   800db2 <nsipc>
}
  800f05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f0a:	f3 0f 1e fb          	endbr32 
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
  800f17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f24:	b8 06 00 00 00       	mov    $0x6,%eax
  800f29:	e8 84 fe ff ff       	call   800db2 <nsipc>
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f30:	f3 0f 1e fb          	endbr32 
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f44:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f4d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f52:	b8 07 00 00 00       	mov    $0x7,%eax
  800f57:	e8 56 fe ff ff       	call   800db2 <nsipc>
  800f5c:	89 c3                	mov    %eax,%ebx
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 26                	js     800f88 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f62:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f68:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f6d:	0f 4e c6             	cmovle %esi,%eax
  800f70:	39 c3                	cmp    %eax,%ebx
  800f72:	7f 1d                	jg     800f91 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	53                   	push   %ebx
  800f78:	68 00 60 80 00       	push   $0x806000
  800f7d:	ff 75 0c             	pushl  0xc(%ebp)
  800f80:	e8 9c 0e 00 00       	call   801e21 <memmove>
  800f85:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f91:	68 3b 25 80 00       	push   $0x80253b
  800f96:	68 a3 24 80 00       	push   $0x8024a3
  800f9b:	6a 62                	push   $0x62
  800f9d:	68 50 25 80 00       	push   $0x802550
  800fa2:	e8 8b 05 00 00       	call   801532 <_panic>

00800fa7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fa7:	f3 0f 1e fb          	endbr32 
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	53                   	push   %ebx
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fbd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fc3:	7f 2e                	jg     800ff3 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fc5:	83 ec 04             	sub    $0x4,%esp
  800fc8:	53                   	push   %ebx
  800fc9:	ff 75 0c             	pushl  0xc(%ebp)
  800fcc:	68 0c 60 80 00       	push   $0x80600c
  800fd1:	e8 4b 0e 00 00       	call   801e21 <memmove>
	nsipcbuf.send.req_size = size;
  800fd6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fdf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fe4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe9:	e8 c4 fd ff ff       	call   800db2 <nsipc>
}
  800fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    
	assert(size < 1600);
  800ff3:	68 5c 25 80 00       	push   $0x80255c
  800ff8:	68 a3 24 80 00       	push   $0x8024a3
  800ffd:	6a 6d                	push   $0x6d
  800fff:	68 50 25 80 00       	push   $0x802550
  801004:	e8 29 05 00 00       	call   801532 <_panic>

00801009 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801009:	f3 0f 1e fb          	endbr32 
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80101b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801023:	8b 45 10             	mov    0x10(%ebp),%eax
  801026:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80102b:	b8 09 00 00 00       	mov    $0x9,%eax
  801030:	e8 7d fd ff ff       	call   800db2 <nsipc>
}
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801037:	f3 0f 1e fb          	endbr32 
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 08             	pushl  0x8(%ebp)
  801049:	e8 f0 f2 ff ff       	call   80033e <fd2data>
  80104e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	68 68 25 80 00       	push   $0x802568
  801058:	53                   	push   %ebx
  801059:	e8 c5 0b 00 00       	call   801c23 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80105e:	8b 46 04             	mov    0x4(%esi),%eax
  801061:	2b 06                	sub    (%esi),%eax
  801063:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801069:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801070:	00 00 00 
	stat->st_dev = &devpipe;
  801073:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  80107a:	30 80 00 
	return 0;
}
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801089:	f3 0f 1e fb          	endbr32 
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	53                   	push   %ebx
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801097:	53                   	push   %ebx
  801098:	6a 00                	push   $0x0
  80109a:	e8 1b f1 ff ff       	call   8001ba <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80109f:	89 1c 24             	mov    %ebx,(%esp)
  8010a2:	e8 97 f2 ff ff       	call   80033e <fd2data>
  8010a7:	83 c4 08             	add    $0x8,%esp
  8010aa:	50                   	push   %eax
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 08 f1 ff ff       	call   8001ba <sys_page_unmap>
}
  8010b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <_pipeisclosed>:
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 1c             	sub    $0x1c,%esp
  8010c0:	89 c7                	mov    %eax,%edi
  8010c2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8010c4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010cc:	83 ec 0c             	sub    $0xc,%esp
  8010cf:	57                   	push   %edi
  8010d0:	e8 7d 10 00 00       	call   802152 <pageref>
  8010d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010d8:	89 34 24             	mov    %esi,(%esp)
  8010db:	e8 72 10 00 00       	call   802152 <pageref>
		nn = thisenv->env_runs;
  8010e0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010e6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	39 cb                	cmp    %ecx,%ebx
  8010ee:	74 1b                	je     80110b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010f0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010f3:	75 cf                	jne    8010c4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010f5:	8b 42 58             	mov    0x58(%edx),%eax
  8010f8:	6a 01                	push   $0x1
  8010fa:	50                   	push   %eax
  8010fb:	53                   	push   %ebx
  8010fc:	68 6f 25 80 00       	push   $0x80256f
  801101:	e8 13 05 00 00       	call   801619 <cprintf>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	eb b9                	jmp    8010c4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80110b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80110e:	0f 94 c0             	sete   %al
  801111:	0f b6 c0             	movzbl %al,%eax
}
  801114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <devpipe_write>:
{
  80111c:	f3 0f 1e fb          	endbr32 
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	53                   	push   %ebx
  801126:	83 ec 28             	sub    $0x28,%esp
  801129:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80112c:	56                   	push   %esi
  80112d:	e8 0c f2 ff ff       	call   80033e <fd2data>
  801132:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	bf 00 00 00 00       	mov    $0x0,%edi
  80113c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80113f:	74 4f                	je     801190 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801141:	8b 43 04             	mov    0x4(%ebx),%eax
  801144:	8b 0b                	mov    (%ebx),%ecx
  801146:	8d 51 20             	lea    0x20(%ecx),%edx
  801149:	39 d0                	cmp    %edx,%eax
  80114b:	72 14                	jb     801161 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80114d:	89 da                	mov    %ebx,%edx
  80114f:	89 f0                	mov    %esi,%eax
  801151:	e8 61 ff ff ff       	call   8010b7 <_pipeisclosed>
  801156:	85 c0                	test   %eax,%eax
  801158:	75 3b                	jne    801195 <devpipe_write+0x79>
			sys_yield();
  80115a:	e8 ed ef ff ff       	call   80014c <sys_yield>
  80115f:	eb e0                	jmp    801141 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801164:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801168:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	c1 fa 1f             	sar    $0x1f,%edx
  801170:	89 d1                	mov    %edx,%ecx
  801172:	c1 e9 1b             	shr    $0x1b,%ecx
  801175:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801178:	83 e2 1f             	and    $0x1f,%edx
  80117b:	29 ca                	sub    %ecx,%edx
  80117d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801185:	83 c0 01             	add    $0x1,%eax
  801188:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80118b:	83 c7 01             	add    $0x1,%edi
  80118e:	eb ac                	jmp    80113c <devpipe_write+0x20>
	return i;
  801190:	8b 45 10             	mov    0x10(%ebp),%eax
  801193:	eb 05                	jmp    80119a <devpipe_write+0x7e>
				return 0;
  801195:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <devpipe_read>:
{
  8011a2:	f3 0f 1e fb          	endbr32 
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	57                   	push   %edi
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 18             	sub    $0x18,%esp
  8011af:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8011b2:	57                   	push   %edi
  8011b3:	e8 86 f1 ff ff       	call   80033e <fd2data>
  8011b8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	be 00 00 00 00       	mov    $0x0,%esi
  8011c2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8011c5:	75 14                	jne    8011db <devpipe_read+0x39>
	return i;
  8011c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ca:	eb 02                	jmp    8011ce <devpipe_read+0x2c>
				return i;
  8011cc:	89 f0                	mov    %esi,%eax
}
  8011ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    
			sys_yield();
  8011d6:	e8 71 ef ff ff       	call   80014c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011db:	8b 03                	mov    (%ebx),%eax
  8011dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011e0:	75 18                	jne    8011fa <devpipe_read+0x58>
			if (i > 0)
  8011e2:	85 f6                	test   %esi,%esi
  8011e4:	75 e6                	jne    8011cc <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011e6:	89 da                	mov    %ebx,%edx
  8011e8:	89 f8                	mov    %edi,%eax
  8011ea:	e8 c8 fe ff ff       	call   8010b7 <_pipeisclosed>
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	74 e3                	je     8011d6 <devpipe_read+0x34>
				return 0;
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f8:	eb d4                	jmp    8011ce <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011fa:	99                   	cltd   
  8011fb:	c1 ea 1b             	shr    $0x1b,%edx
  8011fe:	01 d0                	add    %edx,%eax
  801200:	83 e0 1f             	and    $0x1f,%eax
  801203:	29 d0                	sub    %edx,%eax
  801205:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80120a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801210:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801213:	83 c6 01             	add    $0x1,%esi
  801216:	eb aa                	jmp    8011c2 <devpipe_read+0x20>

00801218 <pipe>:
{
  801218:	f3 0f 1e fb          	endbr32 
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801224:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	e8 2c f1 ff ff       	call   800359 <fd_alloc>
  80122d:	89 c3                	mov    %eax,%ebx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	0f 88 23 01 00 00    	js     80135d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	68 07 04 00 00       	push   $0x407
  801242:	ff 75 f4             	pushl  -0xc(%ebp)
  801245:	6a 00                	push   $0x0
  801247:	e8 23 ef ff ff       	call   80016f <sys_page_alloc>
  80124c:	89 c3                	mov    %eax,%ebx
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	0f 88 04 01 00 00    	js     80135d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801259:	83 ec 0c             	sub    $0xc,%esp
  80125c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	e8 f4 f0 ff ff       	call   800359 <fd_alloc>
  801265:	89 c3                	mov    %eax,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	0f 88 db 00 00 00    	js     80134d <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	68 07 04 00 00       	push   $0x407
  80127a:	ff 75 f0             	pushl  -0x10(%ebp)
  80127d:	6a 00                	push   $0x0
  80127f:	e8 eb ee ff ff       	call   80016f <sys_page_alloc>
  801284:	89 c3                	mov    %eax,%ebx
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	0f 88 bc 00 00 00    	js     80134d <pipe+0x135>
	va = fd2data(fd0);
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	ff 75 f4             	pushl  -0xc(%ebp)
  801297:	e8 a2 f0 ff ff       	call   80033e <fd2data>
  80129c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80129e:	83 c4 0c             	add    $0xc,%esp
  8012a1:	68 07 04 00 00       	push   $0x407
  8012a6:	50                   	push   %eax
  8012a7:	6a 00                	push   $0x0
  8012a9:	e8 c1 ee ff ff       	call   80016f <sys_page_alloc>
  8012ae:	89 c3                	mov    %eax,%ebx
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	0f 88 82 00 00 00    	js     80133d <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c1:	e8 78 f0 ff ff       	call   80033e <fd2data>
  8012c6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012cd:	50                   	push   %eax
  8012ce:	6a 00                	push   $0x0
  8012d0:	56                   	push   %esi
  8012d1:	6a 00                	push   $0x0
  8012d3:	e8 bd ee ff ff       	call   800195 <sys_page_map>
  8012d8:	89 c3                	mov    %eax,%ebx
  8012da:	83 c4 20             	add    $0x20,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 4e                	js     80132f <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8012e1:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ee:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012f8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	ff 75 f4             	pushl  -0xc(%ebp)
  80130a:	e8 1b f0 ff ff       	call   80032a <fd2num>
  80130f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801312:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801314:	83 c4 04             	add    $0x4,%esp
  801317:	ff 75 f0             	pushl  -0x10(%ebp)
  80131a:	e8 0b f0 ff ff       	call   80032a <fd2num>
  80131f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801322:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132d:	eb 2e                	jmp    80135d <pipe+0x145>
	sys_page_unmap(0, va);
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	56                   	push   %esi
  801333:	6a 00                	push   $0x0
  801335:	e8 80 ee ff ff       	call   8001ba <sys_page_unmap>
  80133a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80133d:	83 ec 08             	sub    $0x8,%esp
  801340:	ff 75 f0             	pushl  -0x10(%ebp)
  801343:	6a 00                	push   $0x0
  801345:	e8 70 ee ff ff       	call   8001ba <sys_page_unmap>
  80134a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	ff 75 f4             	pushl  -0xc(%ebp)
  801353:	6a 00                	push   $0x0
  801355:	e8 60 ee ff ff       	call   8001ba <sys_page_unmap>
  80135a:	83 c4 10             	add    $0x10,%esp
}
  80135d:	89 d8                	mov    %ebx,%eax
  80135f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <pipeisclosed>:
{
  801366:	f3 0f 1e fb          	endbr32 
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	ff 75 08             	pushl  0x8(%ebp)
  801377:	e8 33 f0 ff ff       	call   8003af <fd_lookup>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 18                	js     80139b <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	ff 75 f4             	pushl  -0xc(%ebp)
  801389:	e8 b0 ef ff ff       	call   80033e <fd2data>
  80138e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801393:	e8 1f fd ff ff       	call   8010b7 <_pipeisclosed>
  801398:	83 c4 10             	add    $0x10,%esp
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80139d:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8013a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a6:	c3                   	ret    

008013a7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013a7:	f3 0f 1e fb          	endbr32 
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013b1:	68 87 25 80 00       	push   $0x802587
  8013b6:	ff 75 0c             	pushl  0xc(%ebp)
  8013b9:	e8 65 08 00 00       	call   801c23 <strcpy>
	return 0;
}
  8013be:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <devcons_write>:
{
  8013c5:	f3 0f 1e fb          	endbr32 
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	57                   	push   %edi
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8013d5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013da:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013e0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013e3:	73 31                	jae    801416 <devcons_write+0x51>
		m = n - tot;
  8013e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e8:	29 f3                	sub    %esi,%ebx
  8013ea:	83 fb 7f             	cmp    $0x7f,%ebx
  8013ed:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013f2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013f5:	83 ec 04             	sub    $0x4,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	89 f0                	mov    %esi,%eax
  8013fb:	03 45 0c             	add    0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	57                   	push   %edi
  801400:	e8 1c 0a 00 00       	call   801e21 <memmove>
		sys_cputs(buf, m);
  801405:	83 c4 08             	add    $0x8,%esp
  801408:	53                   	push   %ebx
  801409:	57                   	push   %edi
  80140a:	e8 b1 ec ff ff       	call   8000c0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80140f:	01 de                	add    %ebx,%esi
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	eb ca                	jmp    8013e0 <devcons_write+0x1b>
}
  801416:	89 f0                	mov    %esi,%eax
  801418:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <devcons_read>:
{
  801420:	f3 0f 1e fb          	endbr32 
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80142f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801433:	74 21                	je     801456 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801435:	e8 a8 ec ff ff       	call   8000e2 <sys_cgetc>
  80143a:	85 c0                	test   %eax,%eax
  80143c:	75 07                	jne    801445 <devcons_read+0x25>
		sys_yield();
  80143e:	e8 09 ed ff ff       	call   80014c <sys_yield>
  801443:	eb f0                	jmp    801435 <devcons_read+0x15>
	if (c < 0)
  801445:	78 0f                	js     801456 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801447:	83 f8 04             	cmp    $0x4,%eax
  80144a:	74 0c                	je     801458 <devcons_read+0x38>
	*(char*)vbuf = c;
  80144c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144f:	88 02                	mov    %al,(%edx)
	return 1;
  801451:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801456:	c9                   	leave  
  801457:	c3                   	ret    
		return 0;
  801458:	b8 00 00 00 00       	mov    $0x0,%eax
  80145d:	eb f7                	jmp    801456 <devcons_read+0x36>

0080145f <cputchar>:
{
  80145f:	f3 0f 1e fb          	endbr32 
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80146f:	6a 01                	push   $0x1
  801471:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801474:	50                   	push   %eax
  801475:	e8 46 ec ff ff       	call   8000c0 <sys_cputs>
}
  80147a:	83 c4 10             	add    $0x10,%esp
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <getchar>:
{
  80147f:	f3 0f 1e fb          	endbr32 
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801489:	6a 01                	push   $0x1
  80148b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	6a 00                	push   $0x0
  801491:	e8 a1 f1 ff ff       	call   800637 <read>
	if (r < 0)
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 06                	js     8014a3 <getchar+0x24>
	if (r < 1)
  80149d:	74 06                	je     8014a5 <getchar+0x26>
	return c;
  80149f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    
		return -E_EOF;
  8014a5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8014aa:	eb f7                	jmp    8014a3 <getchar+0x24>

008014ac <iscons>:
{
  8014ac:	f3 0f 1e fb          	endbr32 
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	ff 75 08             	pushl  0x8(%ebp)
  8014bd:	e8 ed ee ff ff       	call   8003af <fd_lookup>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 11                	js     8014da <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8014c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cc:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014d2:	39 10                	cmp    %edx,(%eax)
  8014d4:	0f 94 c0             	sete   %al
  8014d7:	0f b6 c0             	movzbl %al,%eax
}
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <opencons>:
{
  8014dc:	f3 0f 1e fb          	endbr32 
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	e8 6a ee ff ff       	call   800359 <fd_alloc>
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 3a                	js     801530 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	68 07 04 00 00       	push   $0x407
  8014fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801501:	6a 00                	push   $0x0
  801503:	e8 67 ec ff ff       	call   80016f <sys_page_alloc>
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 21                	js     801530 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80150f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801512:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801518:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	50                   	push   %eax
  801528:	e8 fd ed ff ff       	call   80032a <fd2num>
  80152d:	83 c4 10             	add    $0x10,%esp
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801532:	f3 0f 1e fb          	endbr32 
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80153b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80153e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801544:	e8 e0 eb ff ff       	call   800129 <sys_getenvid>
  801549:	83 ec 0c             	sub    $0xc,%esp
  80154c:	ff 75 0c             	pushl  0xc(%ebp)
  80154f:	ff 75 08             	pushl  0x8(%ebp)
  801552:	56                   	push   %esi
  801553:	50                   	push   %eax
  801554:	68 94 25 80 00       	push   $0x802594
  801559:	e8 bb 00 00 00       	call   801619 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80155e:	83 c4 18             	add    $0x18,%esp
  801561:	53                   	push   %ebx
  801562:	ff 75 10             	pushl  0x10(%ebp)
  801565:	e8 5a 00 00 00       	call   8015c4 <vcprintf>
	cprintf("\n");
  80156a:	c7 04 24 80 25 80 00 	movl   $0x802580,(%esp)
  801571:	e8 a3 00 00 00       	call   801619 <cprintf>
  801576:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801579:	cc                   	int3   
  80157a:	eb fd                	jmp    801579 <_panic+0x47>

0080157c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80157c:	f3 0f 1e fb          	endbr32 
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	53                   	push   %ebx
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80158a:	8b 13                	mov    (%ebx),%edx
  80158c:	8d 42 01             	lea    0x1(%edx),%eax
  80158f:	89 03                	mov    %eax,(%ebx)
  801591:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801594:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801598:	3d ff 00 00 00       	cmp    $0xff,%eax
  80159d:	74 09                	je     8015a8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80159f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	68 ff 00 00 00       	push   $0xff
  8015b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8015b3:	50                   	push   %eax
  8015b4:	e8 07 eb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  8015b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	eb db                	jmp    80159f <putch+0x23>

008015c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015c4:	f3 0f 1e fb          	endbr32 
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015d8:	00 00 00 
	b.cnt = 0;
  8015db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015e5:	ff 75 0c             	pushl  0xc(%ebp)
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	68 7c 15 80 00       	push   $0x80157c
  8015f7:	e8 20 01 00 00       	call   80171c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801605:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	e8 af ea ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  801611:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801619:	f3 0f 1e fb          	endbr32 
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801623:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801626:	50                   	push   %eax
  801627:	ff 75 08             	pushl  0x8(%ebp)
  80162a:	e8 95 ff ff ff       	call   8015c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	57                   	push   %edi
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	83 ec 1c             	sub    $0x1c,%esp
  80163a:	89 c7                	mov    %eax,%edi
  80163c:	89 d6                	mov    %edx,%esi
  80163e:	8b 45 08             	mov    0x8(%ebp),%eax
  801641:	8b 55 0c             	mov    0xc(%ebp),%edx
  801644:	89 d1                	mov    %edx,%ecx
  801646:	89 c2                	mov    %eax,%edx
  801648:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80164b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80164e:	8b 45 10             	mov    0x10(%ebp),%eax
  801651:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801654:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801657:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80165e:	39 c2                	cmp    %eax,%edx
  801660:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801663:	72 3e                	jb     8016a3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	ff 75 18             	pushl  0x18(%ebp)
  80166b:	83 eb 01             	sub    $0x1,%ebx
  80166e:	53                   	push   %ebx
  80166f:	50                   	push   %eax
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	ff 75 e4             	pushl  -0x1c(%ebp)
  801676:	ff 75 e0             	pushl  -0x20(%ebp)
  801679:	ff 75 dc             	pushl  -0x24(%ebp)
  80167c:	ff 75 d8             	pushl  -0x28(%ebp)
  80167f:	e8 1c 0b 00 00       	call   8021a0 <__udivdi3>
  801684:	83 c4 18             	add    $0x18,%esp
  801687:	52                   	push   %edx
  801688:	50                   	push   %eax
  801689:	89 f2                	mov    %esi,%edx
  80168b:	89 f8                	mov    %edi,%eax
  80168d:	e8 9f ff ff ff       	call   801631 <printnum>
  801692:	83 c4 20             	add    $0x20,%esp
  801695:	eb 13                	jmp    8016aa <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	56                   	push   %esi
  80169b:	ff 75 18             	pushl  0x18(%ebp)
  80169e:	ff d7                	call   *%edi
  8016a0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8016a3:	83 eb 01             	sub    $0x1,%ebx
  8016a6:	85 db                	test   %ebx,%ebx
  8016a8:	7f ed                	jg     801697 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	56                   	push   %esi
  8016ae:	83 ec 04             	sub    $0x4,%esp
  8016b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8016b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8016bd:	e8 ee 0b 00 00       	call   8022b0 <__umoddi3>
  8016c2:	83 c4 14             	add    $0x14,%esp
  8016c5:	0f be 80 b7 25 80 00 	movsbl 0x8025b7(%eax),%eax
  8016cc:	50                   	push   %eax
  8016cd:	ff d7                	call   *%edi
}
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d5:	5b                   	pop    %ebx
  8016d6:	5e                   	pop    %esi
  8016d7:	5f                   	pop    %edi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016da:	f3 0f 1e fb          	endbr32 
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016e8:	8b 10                	mov    (%eax),%edx
  8016ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8016ed:	73 0a                	jae    8016f9 <sprintputch+0x1f>
		*b->buf++ = ch;
  8016ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016f2:	89 08                	mov    %ecx,(%eax)
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	88 02                	mov    %al,(%edx)
}
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <printfmt>:
{
  8016fb:	f3 0f 1e fb          	endbr32 
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801705:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801708:	50                   	push   %eax
  801709:	ff 75 10             	pushl  0x10(%ebp)
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	ff 75 08             	pushl  0x8(%ebp)
  801712:	e8 05 00 00 00       	call   80171c <vprintfmt>
}
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <vprintfmt>:
{
  80171c:	f3 0f 1e fb          	endbr32 
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	57                   	push   %edi
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	83 ec 3c             	sub    $0x3c,%esp
  801729:	8b 75 08             	mov    0x8(%ebp),%esi
  80172c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80172f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801732:	e9 8e 03 00 00       	jmp    801ac5 <vprintfmt+0x3a9>
		padc = ' ';
  801737:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80173b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801742:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801749:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801750:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801755:	8d 47 01             	lea    0x1(%edi),%eax
  801758:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80175b:	0f b6 17             	movzbl (%edi),%edx
  80175e:	8d 42 dd             	lea    -0x23(%edx),%eax
  801761:	3c 55                	cmp    $0x55,%al
  801763:	0f 87 df 03 00 00    	ja     801b48 <vprintfmt+0x42c>
  801769:	0f b6 c0             	movzbl %al,%eax
  80176c:	3e ff 24 85 00 27 80 	notrack jmp *0x802700(,%eax,4)
  801773:	00 
  801774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801777:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80177b:	eb d8                	jmp    801755 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80177d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801780:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801784:	eb cf                	jmp    801755 <vprintfmt+0x39>
  801786:	0f b6 d2             	movzbl %dl,%edx
  801789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
  801791:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801794:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801797:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80179b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80179e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8017a1:	83 f9 09             	cmp    $0x9,%ecx
  8017a4:	77 55                	ja     8017fb <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8017a6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8017a9:	eb e9                	jmp    801794 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8017ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ae:	8b 00                	mov    (%eax),%eax
  8017b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b6:	8d 40 04             	lea    0x4(%eax),%eax
  8017b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8017bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017c3:	79 90                	jns    801755 <vprintfmt+0x39>
				width = precision, precision = -1;
  8017c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8017c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017cb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8017d2:	eb 81                	jmp    801755 <vprintfmt+0x39>
  8017d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017de:	0f 49 d0             	cmovns %eax,%edx
  8017e1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017e7:	e9 69 ff ff ff       	jmp    801755 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017ef:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017f6:	e9 5a ff ff ff       	jmp    801755 <vprintfmt+0x39>
  8017fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801801:	eb bc                	jmp    8017bf <vprintfmt+0xa3>
			lflag++;
  801803:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801806:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801809:	e9 47 ff ff ff       	jmp    801755 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80180e:	8b 45 14             	mov    0x14(%ebp),%eax
  801811:	8d 78 04             	lea    0x4(%eax),%edi
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	53                   	push   %ebx
  801818:	ff 30                	pushl  (%eax)
  80181a:	ff d6                	call   *%esi
			break;
  80181c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80181f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801822:	e9 9b 02 00 00       	jmp    801ac2 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  801827:	8b 45 14             	mov    0x14(%ebp),%eax
  80182a:	8d 78 04             	lea    0x4(%eax),%edi
  80182d:	8b 00                	mov    (%eax),%eax
  80182f:	99                   	cltd   
  801830:	31 d0                	xor    %edx,%eax
  801832:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801834:	83 f8 0f             	cmp    $0xf,%eax
  801837:	7f 23                	jg     80185c <vprintfmt+0x140>
  801839:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  801840:	85 d2                	test   %edx,%edx
  801842:	74 18                	je     80185c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801844:	52                   	push   %edx
  801845:	68 b5 24 80 00       	push   $0x8024b5
  80184a:	53                   	push   %ebx
  80184b:	56                   	push   %esi
  80184c:	e8 aa fe ff ff       	call   8016fb <printfmt>
  801851:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801854:	89 7d 14             	mov    %edi,0x14(%ebp)
  801857:	e9 66 02 00 00       	jmp    801ac2 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80185c:	50                   	push   %eax
  80185d:	68 cf 25 80 00       	push   $0x8025cf
  801862:	53                   	push   %ebx
  801863:	56                   	push   %esi
  801864:	e8 92 fe ff ff       	call   8016fb <printfmt>
  801869:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80186c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80186f:	e9 4e 02 00 00       	jmp    801ac2 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801874:	8b 45 14             	mov    0x14(%ebp),%eax
  801877:	83 c0 04             	add    $0x4,%eax
  80187a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80187d:	8b 45 14             	mov    0x14(%ebp),%eax
  801880:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801882:	85 d2                	test   %edx,%edx
  801884:	b8 c8 25 80 00       	mov    $0x8025c8,%eax
  801889:	0f 45 c2             	cmovne %edx,%eax
  80188c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80188f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801893:	7e 06                	jle    80189b <vprintfmt+0x17f>
  801895:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801899:	75 0d                	jne    8018a8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80189b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80189e:	89 c7                	mov    %eax,%edi
  8018a0:	03 45 e0             	add    -0x20(%ebp),%eax
  8018a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018a6:	eb 55                	jmp    8018fd <vprintfmt+0x1e1>
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8018ae:	ff 75 cc             	pushl  -0x34(%ebp)
  8018b1:	e8 46 03 00 00       	call   801bfc <strnlen>
  8018b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018b9:	29 c2                	sub    %eax,%edx
  8018bb:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8018c3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8018c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ca:	85 ff                	test   %edi,%edi
  8018cc:	7e 11                	jle    8018df <vprintfmt+0x1c3>
					putch(padc, putdat);
  8018ce:	83 ec 08             	sub    $0x8,%esp
  8018d1:	53                   	push   %ebx
  8018d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d7:	83 ef 01             	sub    $0x1,%edi
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	eb eb                	jmp    8018ca <vprintfmt+0x1ae>
  8018df:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018e2:	85 d2                	test   %edx,%edx
  8018e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e9:	0f 49 c2             	cmovns %edx,%eax
  8018ec:	29 c2                	sub    %eax,%edx
  8018ee:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018f1:	eb a8                	jmp    80189b <vprintfmt+0x17f>
					putch(ch, putdat);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	52                   	push   %edx
  8018f8:	ff d6                	call   *%esi
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801900:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801902:	83 c7 01             	add    $0x1,%edi
  801905:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801909:	0f be d0             	movsbl %al,%edx
  80190c:	85 d2                	test   %edx,%edx
  80190e:	74 4b                	je     80195b <vprintfmt+0x23f>
  801910:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801914:	78 06                	js     80191c <vprintfmt+0x200>
  801916:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80191a:	78 1e                	js     80193a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80191c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801920:	74 d1                	je     8018f3 <vprintfmt+0x1d7>
  801922:	0f be c0             	movsbl %al,%eax
  801925:	83 e8 20             	sub    $0x20,%eax
  801928:	83 f8 5e             	cmp    $0x5e,%eax
  80192b:	76 c6                	jbe    8018f3 <vprintfmt+0x1d7>
					putch('?', putdat);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	53                   	push   %ebx
  801931:	6a 3f                	push   $0x3f
  801933:	ff d6                	call   *%esi
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	eb c3                	jmp    8018fd <vprintfmt+0x1e1>
  80193a:	89 cf                	mov    %ecx,%edi
  80193c:	eb 0e                	jmp    80194c <vprintfmt+0x230>
				putch(' ', putdat);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	53                   	push   %ebx
  801942:	6a 20                	push   $0x20
  801944:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801946:	83 ef 01             	sub    $0x1,%edi
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 ff                	test   %edi,%edi
  80194e:	7f ee                	jg     80193e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801950:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801953:	89 45 14             	mov    %eax,0x14(%ebp)
  801956:	e9 67 01 00 00       	jmp    801ac2 <vprintfmt+0x3a6>
  80195b:	89 cf                	mov    %ecx,%edi
  80195d:	eb ed                	jmp    80194c <vprintfmt+0x230>
	if (lflag >= 2)
  80195f:	83 f9 01             	cmp    $0x1,%ecx
  801962:	7f 1b                	jg     80197f <vprintfmt+0x263>
	else if (lflag)
  801964:	85 c9                	test   %ecx,%ecx
  801966:	74 63                	je     8019cb <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801968:	8b 45 14             	mov    0x14(%ebp),%eax
  80196b:	8b 00                	mov    (%eax),%eax
  80196d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801970:	99                   	cltd   
  801971:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801974:	8b 45 14             	mov    0x14(%ebp),%eax
  801977:	8d 40 04             	lea    0x4(%eax),%eax
  80197a:	89 45 14             	mov    %eax,0x14(%ebp)
  80197d:	eb 17                	jmp    801996 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80197f:	8b 45 14             	mov    0x14(%ebp),%eax
  801982:	8b 50 04             	mov    0x4(%eax),%edx
  801985:	8b 00                	mov    (%eax),%eax
  801987:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80198a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8d 40 08             	lea    0x8(%eax),%eax
  801993:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801996:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801999:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80199c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8019a1:	85 c9                	test   %ecx,%ecx
  8019a3:	0f 89 ff 00 00 00    	jns    801aa8 <vprintfmt+0x38c>
				putch('-', putdat);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	6a 2d                	push   $0x2d
  8019af:	ff d6                	call   *%esi
				num = -(long long) num;
  8019b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019b7:	f7 da                	neg    %edx
  8019b9:	83 d1 00             	adc    $0x0,%ecx
  8019bc:	f7 d9                	neg    %ecx
  8019be:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8019c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019c6:	e9 dd 00 00 00       	jmp    801aa8 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8019cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ce:	8b 00                	mov    (%eax),%eax
  8019d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d3:	99                   	cltd   
  8019d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019da:	8d 40 04             	lea    0x4(%eax),%eax
  8019dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8019e0:	eb b4                	jmp    801996 <vprintfmt+0x27a>
	if (lflag >= 2)
  8019e2:	83 f9 01             	cmp    $0x1,%ecx
  8019e5:	7f 1e                	jg     801a05 <vprintfmt+0x2e9>
	else if (lflag)
  8019e7:	85 c9                	test   %ecx,%ecx
  8019e9:	74 32                	je     801a1d <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ee:	8b 10                	mov    (%eax),%edx
  8019f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f5:	8d 40 04             	lea    0x4(%eax),%eax
  8019f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019fb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  801a00:	e9 a3 00 00 00       	jmp    801aa8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8b 10                	mov    (%eax),%edx
  801a0a:	8b 48 04             	mov    0x4(%eax),%ecx
  801a0d:	8d 40 08             	lea    0x8(%eax),%eax
  801a10:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801a13:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  801a18:	e9 8b 00 00 00       	jmp    801aa8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a20:	8b 10                	mov    (%eax),%edx
  801a22:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a27:	8d 40 04             	lea    0x4(%eax),%eax
  801a2a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801a2d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801a32:	eb 74                	jmp    801aa8 <vprintfmt+0x38c>
	if (lflag >= 2)
  801a34:	83 f9 01             	cmp    $0x1,%ecx
  801a37:	7f 1b                	jg     801a54 <vprintfmt+0x338>
	else if (lflag)
  801a39:	85 c9                	test   %ecx,%ecx
  801a3b:	74 2c                	je     801a69 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801a3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a40:	8b 10                	mov    (%eax),%edx
  801a42:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a47:	8d 40 04             	lea    0x4(%eax),%eax
  801a4a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a4d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a52:	eb 54                	jmp    801aa8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a54:	8b 45 14             	mov    0x14(%ebp),%eax
  801a57:	8b 10                	mov    (%eax),%edx
  801a59:	8b 48 04             	mov    0x4(%eax),%ecx
  801a5c:	8d 40 08             	lea    0x8(%eax),%eax
  801a5f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a62:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a67:	eb 3f                	jmp    801aa8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a69:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6c:	8b 10                	mov    (%eax),%edx
  801a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a73:	8d 40 04             	lea    0x4(%eax),%eax
  801a76:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a79:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a7e:	eb 28                	jmp    801aa8 <vprintfmt+0x38c>
			putch('0', putdat);
  801a80:	83 ec 08             	sub    $0x8,%esp
  801a83:	53                   	push   %ebx
  801a84:	6a 30                	push   $0x30
  801a86:	ff d6                	call   *%esi
			putch('x', putdat);
  801a88:	83 c4 08             	add    $0x8,%esp
  801a8b:	53                   	push   %ebx
  801a8c:	6a 78                	push   $0x78
  801a8e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a90:	8b 45 14             	mov    0x14(%ebp),%eax
  801a93:	8b 10                	mov    (%eax),%edx
  801a95:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a9a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a9d:	8d 40 04             	lea    0x4(%eax),%eax
  801aa0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aa3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801aaf:	57                   	push   %edi
  801ab0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab3:	50                   	push   %eax
  801ab4:	51                   	push   %ecx
  801ab5:	52                   	push   %edx
  801ab6:	89 da                	mov    %ebx,%edx
  801ab8:	89 f0                	mov    %esi,%eax
  801aba:	e8 72 fb ff ff       	call   801631 <printnum>
			break;
  801abf:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801ac2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801ac5:	83 c7 01             	add    $0x1,%edi
  801ac8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801acc:	83 f8 25             	cmp    $0x25,%eax
  801acf:	0f 84 62 fc ff ff    	je     801737 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	0f 84 8b 00 00 00    	je     801b68 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801add:	83 ec 08             	sub    $0x8,%esp
  801ae0:	53                   	push   %ebx
  801ae1:	50                   	push   %eax
  801ae2:	ff d6                	call   *%esi
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	eb dc                	jmp    801ac5 <vprintfmt+0x3a9>
	if (lflag >= 2)
  801ae9:	83 f9 01             	cmp    $0x1,%ecx
  801aec:	7f 1b                	jg     801b09 <vprintfmt+0x3ed>
	else if (lflag)
  801aee:	85 c9                	test   %ecx,%ecx
  801af0:	74 2c                	je     801b1e <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801af2:	8b 45 14             	mov    0x14(%ebp),%eax
  801af5:	8b 10                	mov    (%eax),%edx
  801af7:	b9 00 00 00 00       	mov    $0x0,%ecx
  801afc:	8d 40 04             	lea    0x4(%eax),%eax
  801aff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b02:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801b07:	eb 9f                	jmp    801aa8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801b09:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0c:	8b 10                	mov    (%eax),%edx
  801b0e:	8b 48 04             	mov    0x4(%eax),%ecx
  801b11:	8d 40 08             	lea    0x8(%eax),%eax
  801b14:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b17:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801b1c:	eb 8a                	jmp    801aa8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801b1e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b21:	8b 10                	mov    (%eax),%edx
  801b23:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b28:	8d 40 04             	lea    0x4(%eax),%eax
  801b2b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b2e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801b33:	e9 70 ff ff ff       	jmp    801aa8 <vprintfmt+0x38c>
			putch(ch, putdat);
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	53                   	push   %ebx
  801b3c:	6a 25                	push   $0x25
  801b3e:	ff d6                	call   *%esi
			break;
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	e9 7a ff ff ff       	jmp    801ac2 <vprintfmt+0x3a6>
			putch('%', putdat);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	53                   	push   %ebx
  801b4c:	6a 25                	push   $0x25
  801b4e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	89 f8                	mov    %edi,%eax
  801b55:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b59:	74 05                	je     801b60 <vprintfmt+0x444>
  801b5b:	83 e8 01             	sub    $0x1,%eax
  801b5e:	eb f5                	jmp    801b55 <vprintfmt+0x439>
  801b60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b63:	e9 5a ff ff ff       	jmp    801ac2 <vprintfmt+0x3a6>
}
  801b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6b:	5b                   	pop    %ebx
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b70:	f3 0f 1e fb          	endbr32 
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	83 ec 18             	sub    $0x18,%esp
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b80:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b83:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b87:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b91:	85 c0                	test   %eax,%eax
  801b93:	74 26                	je     801bbb <vsnprintf+0x4b>
  801b95:	85 d2                	test   %edx,%edx
  801b97:	7e 22                	jle    801bbb <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b99:	ff 75 14             	pushl  0x14(%ebp)
  801b9c:	ff 75 10             	pushl  0x10(%ebp)
  801b9f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ba2:	50                   	push   %eax
  801ba3:	68 da 16 80 00       	push   $0x8016da
  801ba8:	e8 6f fb ff ff       	call   80171c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bb0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb6:	83 c4 10             	add    $0x10,%esp
}
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    
		return -E_INVAL;
  801bbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bc0:	eb f7                	jmp    801bb9 <vsnprintf+0x49>

00801bc2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bc2:	f3 0f 1e fb          	endbr32 
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801bcc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bcf:	50                   	push   %eax
  801bd0:	ff 75 10             	pushl  0x10(%ebp)
  801bd3:	ff 75 0c             	pushl  0xc(%ebp)
  801bd6:	ff 75 08             	pushl  0x8(%ebp)
  801bd9:	e8 92 ff ff ff       	call   801b70 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801be0:	f3 0f 1e fb          	endbr32 
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bea:	b8 00 00 00 00       	mov    $0x0,%eax
  801bef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bf3:	74 05                	je     801bfa <strlen+0x1a>
		n++;
  801bf5:	83 c0 01             	add    $0x1,%eax
  801bf8:	eb f5                	jmp    801bef <strlen+0xf>
	return n;
}
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bfc:	f3 0f 1e fb          	endbr32 
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c06:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0e:	39 d0                	cmp    %edx,%eax
  801c10:	74 0d                	je     801c1f <strnlen+0x23>
  801c12:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801c16:	74 05                	je     801c1d <strnlen+0x21>
		n++;
  801c18:	83 c0 01             	add    $0x1,%eax
  801c1b:	eb f1                	jmp    801c0e <strnlen+0x12>
  801c1d:	89 c2                	mov    %eax,%edx
	return n;
}
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c23:	f3 0f 1e fb          	endbr32 
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	53                   	push   %ebx
  801c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
  801c36:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801c3a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801c3d:	83 c0 01             	add    $0x1,%eax
  801c40:	84 d2                	test   %dl,%dl
  801c42:	75 f2                	jne    801c36 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c44:	89 c8                	mov    %ecx,%eax
  801c46:	5b                   	pop    %ebx
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c49:	f3 0f 1e fb          	endbr32 
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	53                   	push   %ebx
  801c51:	83 ec 10             	sub    $0x10,%esp
  801c54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c57:	53                   	push   %ebx
  801c58:	e8 83 ff ff ff       	call   801be0 <strlen>
  801c5d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c60:	ff 75 0c             	pushl  0xc(%ebp)
  801c63:	01 d8                	add    %ebx,%eax
  801c65:	50                   	push   %eax
  801c66:	e8 b8 ff ff ff       	call   801c23 <strcpy>
	return dst;
}
  801c6b:	89 d8                	mov    %ebx,%eax
  801c6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c72:	f3 0f 1e fb          	endbr32 
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c81:	89 f3                	mov    %esi,%ebx
  801c83:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c86:	89 f0                	mov    %esi,%eax
  801c88:	39 d8                	cmp    %ebx,%eax
  801c8a:	74 11                	je     801c9d <strncpy+0x2b>
		*dst++ = *src;
  801c8c:	83 c0 01             	add    $0x1,%eax
  801c8f:	0f b6 0a             	movzbl (%edx),%ecx
  801c92:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c95:	80 f9 01             	cmp    $0x1,%cl
  801c98:	83 da ff             	sbb    $0xffffffff,%edx
  801c9b:	eb eb                	jmp    801c88 <strncpy+0x16>
	}
	return ret;
}
  801c9d:	89 f0                	mov    %esi,%eax
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ca3:	f3 0f 1e fb          	endbr32 
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	56                   	push   %esi
  801cab:	53                   	push   %ebx
  801cac:	8b 75 08             	mov    0x8(%ebp),%esi
  801caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb2:	8b 55 10             	mov    0x10(%ebp),%edx
  801cb5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cb7:	85 d2                	test   %edx,%edx
  801cb9:	74 21                	je     801cdc <strlcpy+0x39>
  801cbb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cbf:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801cc1:	39 c2                	cmp    %eax,%edx
  801cc3:	74 14                	je     801cd9 <strlcpy+0x36>
  801cc5:	0f b6 19             	movzbl (%ecx),%ebx
  801cc8:	84 db                	test   %bl,%bl
  801cca:	74 0b                	je     801cd7 <strlcpy+0x34>
			*dst++ = *src++;
  801ccc:	83 c1 01             	add    $0x1,%ecx
  801ccf:	83 c2 01             	add    $0x1,%edx
  801cd2:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cd5:	eb ea                	jmp    801cc1 <strlcpy+0x1e>
  801cd7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801cd9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cdc:	29 f0                	sub    %esi,%eax
}
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ce2:	f3 0f 1e fb          	endbr32 
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cef:	0f b6 01             	movzbl (%ecx),%eax
  801cf2:	84 c0                	test   %al,%al
  801cf4:	74 0c                	je     801d02 <strcmp+0x20>
  801cf6:	3a 02                	cmp    (%edx),%al
  801cf8:	75 08                	jne    801d02 <strcmp+0x20>
		p++, q++;
  801cfa:	83 c1 01             	add    $0x1,%ecx
  801cfd:	83 c2 01             	add    $0x1,%edx
  801d00:	eb ed                	jmp    801cef <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d02:	0f b6 c0             	movzbl %al,%eax
  801d05:	0f b6 12             	movzbl (%edx),%edx
  801d08:	29 d0                	sub    %edx,%eax
}
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d0c:	f3 0f 1e fb          	endbr32 
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	53                   	push   %ebx
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d1f:	eb 06                	jmp    801d27 <strncmp+0x1b>
		n--, p++, q++;
  801d21:	83 c0 01             	add    $0x1,%eax
  801d24:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801d27:	39 d8                	cmp    %ebx,%eax
  801d29:	74 16                	je     801d41 <strncmp+0x35>
  801d2b:	0f b6 08             	movzbl (%eax),%ecx
  801d2e:	84 c9                	test   %cl,%cl
  801d30:	74 04                	je     801d36 <strncmp+0x2a>
  801d32:	3a 0a                	cmp    (%edx),%cl
  801d34:	74 eb                	je     801d21 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d36:	0f b6 00             	movzbl (%eax),%eax
  801d39:	0f b6 12             	movzbl (%edx),%edx
  801d3c:	29 d0                	sub    %edx,%eax
}
  801d3e:	5b                   	pop    %ebx
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    
		return 0;
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
  801d46:	eb f6                	jmp    801d3e <strncmp+0x32>

00801d48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d48:	f3 0f 1e fb          	endbr32 
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d56:	0f b6 10             	movzbl (%eax),%edx
  801d59:	84 d2                	test   %dl,%dl
  801d5b:	74 09                	je     801d66 <strchr+0x1e>
		if (*s == c)
  801d5d:	38 ca                	cmp    %cl,%dl
  801d5f:	74 0a                	je     801d6b <strchr+0x23>
	for (; *s; s++)
  801d61:	83 c0 01             	add    $0x1,%eax
  801d64:	eb f0                	jmp    801d56 <strchr+0xe>
			return (char *) s;
	return 0;
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d6d:	f3 0f 1e fb          	endbr32 
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d77:	6a 78                	push   $0x78
  801d79:	ff 75 08             	pushl  0x8(%ebp)
  801d7c:	e8 c7 ff ff ff       	call   801d48 <strchr>
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d8c:	eb 0d                	jmp    801d9b <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d8e:	c1 e0 04             	shl    $0x4,%eax
  801d91:	0f be d2             	movsbl %dl,%edx
  801d94:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d98:	83 c1 01             	add    $0x1,%ecx
  801d9b:	0f b6 11             	movzbl (%ecx),%edx
  801d9e:	84 d2                	test   %dl,%dl
  801da0:	74 11                	je     801db3 <atox+0x46>
		if (*p>='a'){
  801da2:	80 fa 60             	cmp    $0x60,%dl
  801da5:	7e e7                	jle    801d8e <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801da7:	c1 e0 04             	shl    $0x4,%eax
  801daa:	0f be d2             	movsbl %dl,%edx
  801dad:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801db1:	eb e5                	jmp    801d98 <atox+0x2b>
	}

	return v;

}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801db5:	f3 0f 1e fb          	endbr32 
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dc3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801dc6:	38 ca                	cmp    %cl,%dl
  801dc8:	74 09                	je     801dd3 <strfind+0x1e>
  801dca:	84 d2                	test   %dl,%dl
  801dcc:	74 05                	je     801dd3 <strfind+0x1e>
	for (; *s; s++)
  801dce:	83 c0 01             	add    $0x1,%eax
  801dd1:	eb f0                	jmp    801dc3 <strfind+0xe>
			break;
	return (char *) s;
}
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801dd5:	f3 0f 1e fb          	endbr32 
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	57                   	push   %edi
  801ddd:	56                   	push   %esi
  801dde:	53                   	push   %ebx
  801ddf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801de2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801de5:	85 c9                	test   %ecx,%ecx
  801de7:	74 31                	je     801e1a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801de9:	89 f8                	mov    %edi,%eax
  801deb:	09 c8                	or     %ecx,%eax
  801ded:	a8 03                	test   $0x3,%al
  801def:	75 23                	jne    801e14 <memset+0x3f>
		c &= 0xFF;
  801df1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801df5:	89 d3                	mov    %edx,%ebx
  801df7:	c1 e3 08             	shl    $0x8,%ebx
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	c1 e0 18             	shl    $0x18,%eax
  801dff:	89 d6                	mov    %edx,%esi
  801e01:	c1 e6 10             	shl    $0x10,%esi
  801e04:	09 f0                	or     %esi,%eax
  801e06:	09 c2                	or     %eax,%edx
  801e08:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801e0a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801e0d:	89 d0                	mov    %edx,%eax
  801e0f:	fc                   	cld    
  801e10:	f3 ab                	rep stos %eax,%es:(%edi)
  801e12:	eb 06                	jmp    801e1a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e17:	fc                   	cld    
  801e18:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e1a:	89 f8                	mov    %edi,%eax
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e21:	f3 0f 1e fb          	endbr32 
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	57                   	push   %edi
  801e29:	56                   	push   %esi
  801e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e33:	39 c6                	cmp    %eax,%esi
  801e35:	73 32                	jae    801e69 <memmove+0x48>
  801e37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e3a:	39 c2                	cmp    %eax,%edx
  801e3c:	76 2b                	jbe    801e69 <memmove+0x48>
		s += n;
		d += n;
  801e3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e41:	89 fe                	mov    %edi,%esi
  801e43:	09 ce                	or     %ecx,%esi
  801e45:	09 d6                	or     %edx,%esi
  801e47:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e4d:	75 0e                	jne    801e5d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e4f:	83 ef 04             	sub    $0x4,%edi
  801e52:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e55:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e58:	fd                   	std    
  801e59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e5b:	eb 09                	jmp    801e66 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e5d:	83 ef 01             	sub    $0x1,%edi
  801e60:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e63:	fd                   	std    
  801e64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e66:	fc                   	cld    
  801e67:	eb 1a                	jmp    801e83 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e69:	89 c2                	mov    %eax,%edx
  801e6b:	09 ca                	or     %ecx,%edx
  801e6d:	09 f2                	or     %esi,%edx
  801e6f:	f6 c2 03             	test   $0x3,%dl
  801e72:	75 0a                	jne    801e7e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e74:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e77:	89 c7                	mov    %eax,%edi
  801e79:	fc                   	cld    
  801e7a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e7c:	eb 05                	jmp    801e83 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e7e:	89 c7                	mov    %eax,%edi
  801e80:	fc                   	cld    
  801e81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e83:	5e                   	pop    %esi
  801e84:	5f                   	pop    %edi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e87:	f3 0f 1e fb          	endbr32 
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e91:	ff 75 10             	pushl  0x10(%ebp)
  801e94:	ff 75 0c             	pushl  0xc(%ebp)
  801e97:	ff 75 08             	pushl  0x8(%ebp)
  801e9a:	e8 82 ff ff ff       	call   801e21 <memmove>
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ea1:	f3 0f 1e fb          	endbr32 
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	56                   	push   %esi
  801ea9:	53                   	push   %ebx
  801eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ead:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb0:	89 c6                	mov    %eax,%esi
  801eb2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801eb5:	39 f0                	cmp    %esi,%eax
  801eb7:	74 1c                	je     801ed5 <memcmp+0x34>
		if (*s1 != *s2)
  801eb9:	0f b6 08             	movzbl (%eax),%ecx
  801ebc:	0f b6 1a             	movzbl (%edx),%ebx
  801ebf:	38 d9                	cmp    %bl,%cl
  801ec1:	75 08                	jne    801ecb <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801ec3:	83 c0 01             	add    $0x1,%eax
  801ec6:	83 c2 01             	add    $0x1,%edx
  801ec9:	eb ea                	jmp    801eb5 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801ecb:	0f b6 c1             	movzbl %cl,%eax
  801ece:	0f b6 db             	movzbl %bl,%ebx
  801ed1:	29 d8                	sub    %ebx,%eax
  801ed3:	eb 05                	jmp    801eda <memcmp+0x39>
	}

	return 0;
  801ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eda:	5b                   	pop    %ebx
  801edb:	5e                   	pop    %esi
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ede:	f3 0f 1e fb          	endbr32 
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801eeb:	89 c2                	mov    %eax,%edx
  801eed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ef0:	39 d0                	cmp    %edx,%eax
  801ef2:	73 09                	jae    801efd <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ef4:	38 08                	cmp    %cl,(%eax)
  801ef6:	74 05                	je     801efd <memfind+0x1f>
	for (; s < ends; s++)
  801ef8:	83 c0 01             	add    $0x1,%eax
  801efb:	eb f3                	jmp    801ef0 <memfind+0x12>
			break;
	return (void *) s;
}
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801eff:	f3 0f 1e fb          	endbr32 
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	57                   	push   %edi
  801f07:	56                   	push   %esi
  801f08:	53                   	push   %ebx
  801f09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f0f:	eb 03                	jmp    801f14 <strtol+0x15>
		s++;
  801f11:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801f14:	0f b6 01             	movzbl (%ecx),%eax
  801f17:	3c 20                	cmp    $0x20,%al
  801f19:	74 f6                	je     801f11 <strtol+0x12>
  801f1b:	3c 09                	cmp    $0x9,%al
  801f1d:	74 f2                	je     801f11 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801f1f:	3c 2b                	cmp    $0x2b,%al
  801f21:	74 2a                	je     801f4d <strtol+0x4e>
	int neg = 0;
  801f23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801f28:	3c 2d                	cmp    $0x2d,%al
  801f2a:	74 2b                	je     801f57 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f32:	75 0f                	jne    801f43 <strtol+0x44>
  801f34:	80 39 30             	cmpb   $0x30,(%ecx)
  801f37:	74 28                	je     801f61 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f39:	85 db                	test   %ebx,%ebx
  801f3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f40:	0f 44 d8             	cmove  %eax,%ebx
  801f43:	b8 00 00 00 00       	mov    $0x0,%eax
  801f48:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f4b:	eb 46                	jmp    801f93 <strtol+0x94>
		s++;
  801f4d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f50:	bf 00 00 00 00       	mov    $0x0,%edi
  801f55:	eb d5                	jmp    801f2c <strtol+0x2d>
		s++, neg = 1;
  801f57:	83 c1 01             	add    $0x1,%ecx
  801f5a:	bf 01 00 00 00       	mov    $0x1,%edi
  801f5f:	eb cb                	jmp    801f2c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f61:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f65:	74 0e                	je     801f75 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f67:	85 db                	test   %ebx,%ebx
  801f69:	75 d8                	jne    801f43 <strtol+0x44>
		s++, base = 8;
  801f6b:	83 c1 01             	add    $0x1,%ecx
  801f6e:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f73:	eb ce                	jmp    801f43 <strtol+0x44>
		s += 2, base = 16;
  801f75:	83 c1 02             	add    $0x2,%ecx
  801f78:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f7d:	eb c4                	jmp    801f43 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f7f:	0f be d2             	movsbl %dl,%edx
  801f82:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f85:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f88:	7d 3a                	jge    801fc4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f8a:	83 c1 01             	add    $0x1,%ecx
  801f8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f91:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f93:	0f b6 11             	movzbl (%ecx),%edx
  801f96:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f99:	89 f3                	mov    %esi,%ebx
  801f9b:	80 fb 09             	cmp    $0x9,%bl
  801f9e:	76 df                	jbe    801f7f <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801fa0:	8d 72 9f             	lea    -0x61(%edx),%esi
  801fa3:	89 f3                	mov    %esi,%ebx
  801fa5:	80 fb 19             	cmp    $0x19,%bl
  801fa8:	77 08                	ja     801fb2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801faa:	0f be d2             	movsbl %dl,%edx
  801fad:	83 ea 57             	sub    $0x57,%edx
  801fb0:	eb d3                	jmp    801f85 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801fb2:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fb5:	89 f3                	mov    %esi,%ebx
  801fb7:	80 fb 19             	cmp    $0x19,%bl
  801fba:	77 08                	ja     801fc4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801fbc:	0f be d2             	movsbl %dl,%edx
  801fbf:	83 ea 37             	sub    $0x37,%edx
  801fc2:	eb c1                	jmp    801f85 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801fc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fc8:	74 05                	je     801fcf <strtol+0xd0>
		*endptr = (char *) s;
  801fca:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fcd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801fcf:	89 c2                	mov    %eax,%edx
  801fd1:	f7 da                	neg    %edx
  801fd3:	85 ff                	test   %edi,%edi
  801fd5:	0f 45 c2             	cmovne %edx,%eax
}
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fdd:	f3 0f 1e fb          	endbr32 
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fe7:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801fee:	74 0a                	je     801ffa <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff3:	a3 00 70 80 00       	mov    %eax,0x807000

}
  801ff8:	c9                   	leave  
  801ff9:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  801ffa:	83 ec 04             	sub    $0x4,%esp
  801ffd:	6a 07                	push   $0x7
  801fff:	68 00 f0 bf ee       	push   $0xeebff000
  802004:	6a 00                	push   $0x0
  802006:	e8 64 e1 ff ff       	call   80016f <sys_page_alloc>
  80200b:	83 c4 10             	add    $0x10,%esp
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 2a                	js     80203c <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802012:	83 ec 08             	sub    $0x8,%esp
  802015:	68 06 03 80 00       	push   $0x800306
  80201a:	6a 00                	push   $0x0
  80201c:	e8 08 e2 ff ff       	call   800229 <sys_env_set_pgfault_upcall>
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	85 c0                	test   %eax,%eax
  802026:	79 c8                	jns    801ff0 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802028:	83 ec 04             	sub    $0x4,%esp
  80202b:	68 ec 28 80 00       	push   $0x8028ec
  802030:	6a 2c                	push   $0x2c
  802032:	68 22 29 80 00       	push   $0x802922
  802037:	e8 f6 f4 ff ff       	call   801532 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  80203c:	83 ec 04             	sub    $0x4,%esp
  80203f:	68 c0 28 80 00       	push   $0x8028c0
  802044:	6a 22                	push   $0x22
  802046:	68 22 29 80 00       	push   $0x802922
  80204b:	e8 e2 f4 ff ff       	call   801532 <_panic>

00802050 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802050:	f3 0f 1e fb          	endbr32 
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	56                   	push   %esi
  802058:	53                   	push   %ebx
  802059:	8b 75 08             	mov    0x8(%ebp),%esi
  80205c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802062:	85 c0                	test   %eax,%eax
  802064:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802069:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80206c:	83 ec 0c             	sub    $0xc,%esp
  80206f:	50                   	push   %eax
  802070:	e8 00 e2 ff ff       	call   800275 <sys_ipc_recv>
  802075:	83 c4 10             	add    $0x10,%esp
  802078:	85 c0                	test   %eax,%eax
  80207a:	75 2b                	jne    8020a7 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80207c:	85 f6                	test   %esi,%esi
  80207e:	74 0a                	je     80208a <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802080:	a1 08 40 80 00       	mov    0x804008,%eax
  802085:	8b 40 74             	mov    0x74(%eax),%eax
  802088:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80208a:	85 db                	test   %ebx,%ebx
  80208c:	74 0a                	je     802098 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80208e:	a1 08 40 80 00       	mov    0x804008,%eax
  802093:	8b 40 78             	mov    0x78(%eax),%eax
  802096:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802098:	a1 08 40 80 00       	mov    0x804008,%eax
  80209d:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	74 06                	je     8020b1 <ipc_recv+0x61>
  8020ab:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020b1:	85 db                	test   %ebx,%ebx
  8020b3:	74 eb                	je     8020a0 <ipc_recv+0x50>
  8020b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020bb:	eb e3                	jmp    8020a0 <ipc_recv+0x50>

008020bd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020bd:	f3 0f 1e fb          	endbr32 
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
  8020c4:	57                   	push   %edi
  8020c5:	56                   	push   %esi
  8020c6:	53                   	push   %ebx
  8020c7:	83 ec 0c             	sub    $0xc,%esp
  8020ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8020d3:	85 db                	test   %ebx,%ebx
  8020d5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020da:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020dd:	ff 75 14             	pushl  0x14(%ebp)
  8020e0:	53                   	push   %ebx
  8020e1:	56                   	push   %esi
  8020e2:	57                   	push   %edi
  8020e3:	e8 66 e1 ff ff       	call   80024e <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ee:	75 07                	jne    8020f7 <ipc_send+0x3a>
			sys_yield();
  8020f0:	e8 57 e0 ff ff       	call   80014c <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020f5:	eb e6                	jmp    8020dd <ipc_send+0x20>
		}
		else if (ret == 0)
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	75 08                	jne    802103 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8020fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fe:	5b                   	pop    %ebx
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802103:	50                   	push   %eax
  802104:	68 30 29 80 00       	push   $0x802930
  802109:	6a 48                	push   $0x48
  80210b:	68 3e 29 80 00       	push   $0x80293e
  802110:	e8 1d f4 ff ff       	call   801532 <_panic>

00802115 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802115:	f3 0f 1e fb          	endbr32 
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802124:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802127:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80212d:	8b 52 50             	mov    0x50(%edx),%edx
  802130:	39 ca                	cmp    %ecx,%edx
  802132:	74 11                	je     802145 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802134:	83 c0 01             	add    $0x1,%eax
  802137:	3d 00 04 00 00       	cmp    $0x400,%eax
  80213c:	75 e6                	jne    802124 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80213e:	b8 00 00 00 00       	mov    $0x0,%eax
  802143:	eb 0b                	jmp    802150 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802145:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802148:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80214d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    

00802152 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802152:	f3 0f 1e fb          	endbr32 
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215c:	89 c2                	mov    %eax,%edx
  80215e:	c1 ea 16             	shr    $0x16,%edx
  802161:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802168:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80216d:	f6 c1 01             	test   $0x1,%cl
  802170:	74 1c                	je     80218e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802172:	c1 e8 0c             	shr    $0xc,%eax
  802175:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80217c:	a8 01                	test   $0x1,%al
  80217e:	74 0e                	je     80218e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802180:	c1 e8 0c             	shr    $0xc,%eax
  802183:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80218a:	ef 
  80218b:	0f b7 d2             	movzwl %dx,%edx
}
  80218e:	89 d0                	mov    %edx,%eax
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__udivdi3>:
  8021a0:	f3 0f 1e fb          	endbr32 
  8021a4:	55                   	push   %ebp
  8021a5:	57                   	push   %edi
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 1c             	sub    $0x1c,%esp
  8021ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021bb:	85 d2                	test   %edx,%edx
  8021bd:	75 19                	jne    8021d8 <__udivdi3+0x38>
  8021bf:	39 f3                	cmp    %esi,%ebx
  8021c1:	76 4d                	jbe    802210 <__udivdi3+0x70>
  8021c3:	31 ff                	xor    %edi,%edi
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	89 f2                	mov    %esi,%edx
  8021c9:	f7 f3                	div    %ebx
  8021cb:	89 fa                	mov    %edi,%edx
  8021cd:	83 c4 1c             	add    $0x1c,%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	76 14                	jbe    8021f0 <__udivdi3+0x50>
  8021dc:	31 ff                	xor    %edi,%edi
  8021de:	31 c0                	xor    %eax,%eax
  8021e0:	89 fa                	mov    %edi,%edx
  8021e2:	83 c4 1c             	add    $0x1c,%esp
  8021e5:	5b                   	pop    %ebx
  8021e6:	5e                   	pop    %esi
  8021e7:	5f                   	pop    %edi
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    
  8021ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f0:	0f bd fa             	bsr    %edx,%edi
  8021f3:	83 f7 1f             	xor    $0x1f,%edi
  8021f6:	75 48                	jne    802240 <__udivdi3+0xa0>
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	72 06                	jb     802202 <__udivdi3+0x62>
  8021fc:	31 c0                	xor    %eax,%eax
  8021fe:	39 eb                	cmp    %ebp,%ebx
  802200:	77 de                	ja     8021e0 <__udivdi3+0x40>
  802202:	b8 01 00 00 00       	mov    $0x1,%eax
  802207:	eb d7                	jmp    8021e0 <__udivdi3+0x40>
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d9                	mov    %ebx,%ecx
  802212:	85 db                	test   %ebx,%ebx
  802214:	75 0b                	jne    802221 <__udivdi3+0x81>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f3                	div    %ebx
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	31 d2                	xor    %edx,%edx
  802223:	89 f0                	mov    %esi,%eax
  802225:	f7 f1                	div    %ecx
  802227:	89 c6                	mov    %eax,%esi
  802229:	89 e8                	mov    %ebp,%eax
  80222b:	89 f7                	mov    %esi,%edi
  80222d:	f7 f1                	div    %ecx
  80222f:	89 fa                	mov    %edi,%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 f9                	mov    %edi,%ecx
  802242:	b8 20 00 00 00       	mov    $0x20,%eax
  802247:	29 f8                	sub    %edi,%eax
  802249:	d3 e2                	shl    %cl,%edx
  80224b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	89 da                	mov    %ebx,%edx
  802253:	d3 ea                	shr    %cl,%edx
  802255:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802259:	09 d1                	or     %edx,%ecx
  80225b:	89 f2                	mov    %esi,%edx
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e3                	shl    %cl,%ebx
  802265:	89 c1                	mov    %eax,%ecx
  802267:	d3 ea                	shr    %cl,%edx
  802269:	89 f9                	mov    %edi,%ecx
  80226b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80226f:	89 eb                	mov    %ebp,%ebx
  802271:	d3 e6                	shl    %cl,%esi
  802273:	89 c1                	mov    %eax,%ecx
  802275:	d3 eb                	shr    %cl,%ebx
  802277:	09 de                	or     %ebx,%esi
  802279:	89 f0                	mov    %esi,%eax
  80227b:	f7 74 24 08          	divl   0x8(%esp)
  80227f:	89 d6                	mov    %edx,%esi
  802281:	89 c3                	mov    %eax,%ebx
  802283:	f7 64 24 0c          	mull   0xc(%esp)
  802287:	39 d6                	cmp    %edx,%esi
  802289:	72 15                	jb     8022a0 <__udivdi3+0x100>
  80228b:	89 f9                	mov    %edi,%ecx
  80228d:	d3 e5                	shl    %cl,%ebp
  80228f:	39 c5                	cmp    %eax,%ebp
  802291:	73 04                	jae    802297 <__udivdi3+0xf7>
  802293:	39 d6                	cmp    %edx,%esi
  802295:	74 09                	je     8022a0 <__udivdi3+0x100>
  802297:	89 d8                	mov    %ebx,%eax
  802299:	31 ff                	xor    %edi,%edi
  80229b:	e9 40 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022a3:	31 ff                	xor    %edi,%edi
  8022a5:	e9 36 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	f3 0f 1e fb          	endbr32 
  8022b4:	55                   	push   %ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	83 ec 1c             	sub    $0x1c,%esp
  8022bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	75 19                	jne    8022e8 <__umoddi3+0x38>
  8022cf:	39 df                	cmp    %ebx,%edi
  8022d1:	76 5d                	jbe    802330 <__umoddi3+0x80>
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	89 da                	mov    %ebx,%edx
  8022d7:	f7 f7                	div    %edi
  8022d9:	89 d0                	mov    %edx,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	83 c4 1c             	add    $0x1c,%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
  8022e8:	89 f2                	mov    %esi,%edx
  8022ea:	39 d8                	cmp    %ebx,%eax
  8022ec:	76 12                	jbe    802300 <__umoddi3+0x50>
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	89 da                	mov    %ebx,%edx
  8022f2:	83 c4 1c             	add    $0x1c,%esp
  8022f5:	5b                   	pop    %ebx
  8022f6:	5e                   	pop    %esi
  8022f7:	5f                   	pop    %edi
  8022f8:	5d                   	pop    %ebp
  8022f9:	c3                   	ret    
  8022fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802300:	0f bd e8             	bsr    %eax,%ebp
  802303:	83 f5 1f             	xor    $0x1f,%ebp
  802306:	75 50                	jne    802358 <__umoddi3+0xa8>
  802308:	39 d8                	cmp    %ebx,%eax
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	89 d9                	mov    %ebx,%ecx
  802312:	39 f7                	cmp    %esi,%edi
  802314:	0f 86 d6 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	89 ca                	mov    %ecx,%edx
  80231e:	83 c4 1c             	add    $0x1c,%esp
  802321:	5b                   	pop    %ebx
  802322:	5e                   	pop    %esi
  802323:	5f                   	pop    %edi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	89 fd                	mov    %edi,%ebp
  802332:	85 ff                	test   %edi,%edi
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 d8                	mov    %ebx,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 f0                	mov    %esi,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	31 d2                	xor    %edx,%edx
  80234f:	eb 8c                	jmp    8022dd <__umoddi3+0x2d>
  802351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	ba 20 00 00 00       	mov    $0x20,%edx
  80235f:	29 ea                	sub    %ebp,%edx
  802361:	d3 e0                	shl    %cl,%eax
  802363:	89 44 24 08          	mov    %eax,0x8(%esp)
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 f8                	mov    %edi,%eax
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802371:	89 54 24 04          	mov    %edx,0x4(%esp)
  802375:	8b 54 24 04          	mov    0x4(%esp),%edx
  802379:	09 c1                	or     %eax,%ecx
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 e9                	mov    %ebp,%ecx
  802383:	d3 e7                	shl    %cl,%edi
  802385:	89 d1                	mov    %edx,%ecx
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80238f:	d3 e3                	shl    %cl,%ebx
  802391:	89 c7                	mov    %eax,%edi
  802393:	89 d1                	mov    %edx,%ecx
  802395:	89 f0                	mov    %esi,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	89 fa                	mov    %edi,%edx
  80239d:	d3 e6                	shl    %cl,%esi
  80239f:	09 d8                	or     %ebx,%eax
  8023a1:	f7 74 24 08          	divl   0x8(%esp)
  8023a5:	89 d1                	mov    %edx,%ecx
  8023a7:	89 f3                	mov    %esi,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	89 c6                	mov    %eax,%esi
  8023af:	89 d7                	mov    %edx,%edi
  8023b1:	39 d1                	cmp    %edx,%ecx
  8023b3:	72 06                	jb     8023bb <__umoddi3+0x10b>
  8023b5:	75 10                	jne    8023c7 <__umoddi3+0x117>
  8023b7:	39 c3                	cmp    %eax,%ebx
  8023b9:	73 0c                	jae    8023c7 <__umoddi3+0x117>
  8023bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023c3:	89 d7                	mov    %edx,%edi
  8023c5:	89 c6                	mov    %eax,%esi
  8023c7:	89 ca                	mov    %ecx,%edx
  8023c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023ce:	29 f3                	sub    %esi,%ebx
  8023d0:	19 fa                	sbb    %edi,%edx
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	d3 e0                	shl    %cl,%eax
  8023d6:	89 e9                	mov    %ebp,%ecx
  8023d8:	d3 eb                	shr    %cl,%ebx
  8023da:	d3 ea                	shr    %cl,%edx
  8023dc:	09 d8                	or     %ebx,%eax
  8023de:	83 c4 1c             	add    $0x1c,%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
  8023e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 fe                	sub    %edi,%esi
  8023f2:	19 c3                	sbb    %eax,%ebx
  8023f4:	89 f2                	mov    %esi,%edx
  8023f6:	89 d9                	mov    %ebx,%ecx
  8023f8:	e9 1d ff ff ff       	jmp    80231a <__umoddi3+0x6a>
