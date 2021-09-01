
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
  80003a:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003d:	6a 64                	push   $0x64
  80003f:	68 0c 00 10 f0       	push   $0xf010000c
  800044:	e8 6d 00 00 00       	call   8000b6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005d:	e8 bd 00 00 00       	call   80011f <sys_getenvid>
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x31>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	f3 0f 1e fb          	endbr32 
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000a2:	e8 49 04 00 00       	call   8004f0 <close_all>
	sys_env_destroy(0);
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 4a 00 00 00       	call   8000fb <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b6:	f3 0f 1e fb          	endbr32 
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	89 c3                	mov    %eax,%ebx
  8000cd:	89 c7                	mov    %eax,%edi
  8000cf:	89 c6                	mov    %eax,%esi
  8000d1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d8:	f3 0f 1e fb          	endbr32 
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	89 d6                	mov    %edx,%esi
  8000f4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fb:	f3 0f 1e fb          	endbr32 
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
	asm volatile("int %1\n"
  800105:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	b8 03 00 00 00       	mov    $0x3,%eax
  800112:	89 cb                	mov    %ecx,%ebx
  800114:	89 cf                	mov    %ecx,%edi
  800116:	89 ce                	mov    %ecx,%esi
  800118:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011f:	f3 0f 1e fb          	endbr32 
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	57                   	push   %edi
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
	asm volatile("int %1\n"
  800129:	ba 00 00 00 00       	mov    $0x0,%edx
  80012e:	b8 02 00 00 00       	mov    $0x2,%eax
  800133:	89 d1                	mov    %edx,%ecx
  800135:	89 d3                	mov    %edx,%ebx
  800137:	89 d7                	mov    %edx,%edi
  800139:	89 d6                	mov    %edx,%esi
  80013b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013d:	5b                   	pop    %ebx
  80013e:	5e                   	pop    %esi
  80013f:	5f                   	pop    %edi
  800140:	5d                   	pop    %ebp
  800141:	c3                   	ret    

00800142 <sys_yield>:

void
sys_yield(void)
{
  800142:	f3 0f 1e fb          	endbr32 
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 0b 00 00 00       	mov    $0xb,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800165:	f3 0f 1e fb          	endbr32 
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800186:	5b                   	pop    %ebx
  800187:	5e                   	pop    %esi
  800188:	5f                   	pop    %edi
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    

0080018b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80018b:	f3 0f 1e fb          	endbr32 
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	57                   	push   %edi
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
	asm volatile("int %1\n"
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019b:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001a9:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001b0:	f3 0f 1e fb          	endbr32 
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ca:	89 df                	mov    %ebx,%edi
  8001cc:	89 de                	mov    %ebx,%esi
  8001ce:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001d5:	f3 0f 1e fb          	endbr32 
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8001ef:	89 df                	mov    %ebx,%edi
  8001f1:	89 de                	mov    %ebx,%esi
  8001f3:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001f5:	5b                   	pop    %ebx
  8001f6:	5e                   	pop    %esi
  8001f7:	5f                   	pop    %edi
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    

008001fa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001fa:	f3 0f 1e fb          	endbr32 
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
	asm volatile("int %1\n"
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	8b 55 08             	mov    0x8(%ebp),%edx
  80020c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020f:	b8 09 00 00 00       	mov    $0x9,%eax
  800214:	89 df                	mov    %ebx,%edi
  800216:	89 de                	mov    %ebx,%esi
  800218:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5f                   	pop    %edi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80021f:	f3 0f 1e fb          	endbr32 
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	8b 55 08             	mov    0x8(%ebp),%edx
  800231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800234:	b8 0a 00 00 00       	mov    $0xa,%eax
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800244:	f3 0f 1e fb          	endbr32 
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800254:	b8 0c 00 00 00       	mov    $0xc,%eax
  800259:	be 00 00 00 00       	mov    $0x0,%esi
  80025e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800261:	8b 7d 14             	mov    0x14(%ebp),%edi
  800264:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80026b:	f3 0f 1e fb          	endbr32 
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
	asm volatile("int %1\n"
  800275:	b9 00 00 00 00       	mov    $0x0,%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800282:	89 cb                	mov    %ecx,%ebx
  800284:	89 cf                	mov    %ecx,%edi
  800286:	89 ce                	mov    %ecx,%esi
  800288:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80028f:	f3 0f 1e fb          	endbr32 
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
	asm volatile("int %1\n"
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	89 d3                	mov    %edx,%ebx
  8002a7:	89 d7                	mov    %edx,%edi
  8002a9:	89 d6                	mov    %edx,%esi
  8002ab:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8002b2:	f3 0f 1e fb          	endbr32 
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	57                   	push   %edi
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002cc:	89 df                	mov    %ebx,%edi
  8002ce:	89 de                	mov    %ebx,%esi
  8002d0:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002d7:	f3 0f 1e fb          	endbr32 
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	57                   	push   %edi
  8002df:	56                   	push   %esi
  8002e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8002f1:	89 df                	mov    %ebx,%edi
  8002f3:	89 de                	mov    %ebx,%esi
  8002f5:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002fc:	f3 0f 1e fb          	endbr32 
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	05 00 00 00 30       	add    $0x30000000,%eax
  80030b:	c1 e8 0c             	shr    $0xc,%eax
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800310:	f3 0f 1e fb          	endbr32 
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80031f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800324:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80032b:	f3 0f 1e fb          	endbr32 
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800337:	89 c2                	mov    %eax,%edx
  800339:	c1 ea 16             	shr    $0x16,%edx
  80033c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800343:	f6 c2 01             	test   $0x1,%dl
  800346:	74 2d                	je     800375 <fd_alloc+0x4a>
  800348:	89 c2                	mov    %eax,%edx
  80034a:	c1 ea 0c             	shr    $0xc,%edx
  80034d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800354:	f6 c2 01             	test   $0x1,%dl
  800357:	74 1c                	je     800375 <fd_alloc+0x4a>
  800359:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80035e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800363:	75 d2                	jne    800337 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80036e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800373:	eb 0a                	jmp    80037f <fd_alloc+0x54>
			*fd_store = fd;
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	89 01                	mov    %eax,(%ecx)
			return 0;
  80037a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800381:	f3 0f 1e fb          	endbr32 
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80038b:	83 f8 1f             	cmp    $0x1f,%eax
  80038e:	77 30                	ja     8003c0 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800390:	c1 e0 0c             	shl    $0xc,%eax
  800393:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800398:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	74 24                	je     8003c7 <fd_lookup+0x46>
  8003a3:	89 c2                	mov    %eax,%edx
  8003a5:	c1 ea 0c             	shr    $0xc,%edx
  8003a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003af:	f6 c2 01             	test   $0x1,%dl
  8003b2:	74 1a                	je     8003ce <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b7:	89 02                	mov    %eax,(%edx)
	return 0;
  8003b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003be:	5d                   	pop    %ebp
  8003bf:	c3                   	ret    
		return -E_INVAL;
  8003c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c5:	eb f7                	jmp    8003be <fd_lookup+0x3d>
		return -E_INVAL;
  8003c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cc:	eb f0                	jmp    8003be <fd_lookup+0x3d>
  8003ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d3:	eb e9                	jmp    8003be <fd_lookup+0x3d>

008003d5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d5:	f3 0f 1e fb          	endbr32 
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	83 ec 08             	sub    $0x8,%esp
  8003df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e7:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003ec:	39 08                	cmp    %ecx,(%eax)
  8003ee:	74 38                	je     800428 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8003f0:	83 c2 01             	add    $0x1,%edx
  8003f3:	8b 04 95 e8 23 80 00 	mov    0x8023e8(,%edx,4),%eax
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	75 ee                	jne    8003ec <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003fe:	a1 08 40 80 00       	mov    0x804008,%eax
  800403:	8b 40 48             	mov    0x48(%eax),%eax
  800406:	83 ec 04             	sub    $0x4,%esp
  800409:	51                   	push   %ecx
  80040a:	50                   	push   %eax
  80040b:	68 6c 23 80 00       	push   $0x80236c
  800410:	e8 d6 11 00 00       	call   8015eb <cprintf>
	*dev = 0;
  800415:	8b 45 0c             	mov    0xc(%ebp),%eax
  800418:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80041e:	83 c4 10             	add    $0x10,%esp
  800421:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800426:	c9                   	leave  
  800427:	c3                   	ret    
			*dev = devtab[i];
  800428:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042d:	b8 00 00 00 00       	mov    $0x0,%eax
  800432:	eb f2                	jmp    800426 <dev_lookup+0x51>

00800434 <fd_close>:
{
  800434:	f3 0f 1e fb          	endbr32 
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 24             	sub    $0x24,%esp
  800441:	8b 75 08             	mov    0x8(%ebp),%esi
  800444:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800447:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80044a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80044b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800451:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800454:	50                   	push   %eax
  800455:	e8 27 ff ff ff       	call   800381 <fd_lookup>
  80045a:	89 c3                	mov    %eax,%ebx
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	85 c0                	test   %eax,%eax
  800461:	78 05                	js     800468 <fd_close+0x34>
	    || fd != fd2)
  800463:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800466:	74 16                	je     80047e <fd_close+0x4a>
		return (must_exist ? r : 0);
  800468:	89 f8                	mov    %edi,%eax
  80046a:	84 c0                	test   %al,%al
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	0f 44 d8             	cmove  %eax,%ebx
}
  800474:	89 d8                	mov    %ebx,%eax
  800476:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	ff 36                	pushl  (%esi)
  800487:	e8 49 ff ff ff       	call   8003d5 <dev_lookup>
  80048c:	89 c3                	mov    %eax,%ebx
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	85 c0                	test   %eax,%eax
  800493:	78 1a                	js     8004af <fd_close+0x7b>
		if (dev->dev_close)
  800495:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800498:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80049b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	74 0b                	je     8004af <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	56                   	push   %esi
  8004a8:	ff d0                	call   *%eax
  8004aa:	89 c3                	mov    %eax,%ebx
  8004ac:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	6a 00                	push   $0x0
  8004b5:	e8 f6 fc ff ff       	call   8001b0 <sys_page_unmap>
	return r;
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb b5                	jmp    800474 <fd_close+0x40>

008004bf <close>:

int
close(int fdnum)
{
  8004bf:	f3 0f 1e fb          	endbr32 
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cc:	50                   	push   %eax
  8004cd:	ff 75 08             	pushl  0x8(%ebp)
  8004d0:	e8 ac fe ff ff       	call   800381 <fd_lookup>
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	79 02                	jns    8004de <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    
		return fd_close(fd, 1);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	6a 01                	push   $0x1
  8004e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e6:	e8 49 ff ff ff       	call   800434 <fd_close>
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb ec                	jmp    8004dc <close+0x1d>

008004f0 <close_all>:

void
close_all(void)
{
  8004f0:	f3 0f 1e fb          	endbr32 
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800500:	83 ec 0c             	sub    $0xc,%esp
  800503:	53                   	push   %ebx
  800504:	e8 b6 ff ff ff       	call   8004bf <close>
	for (i = 0; i < MAXFD; i++)
  800509:	83 c3 01             	add    $0x1,%ebx
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	83 fb 20             	cmp    $0x20,%ebx
  800512:	75 ec                	jne    800500 <close_all+0x10>
}
  800514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800517:	c9                   	leave  
  800518:	c3                   	ret    

00800519 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800519:	f3 0f 1e fb          	endbr32 
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800526:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800529:	50                   	push   %eax
  80052a:	ff 75 08             	pushl  0x8(%ebp)
  80052d:	e8 4f fe ff ff       	call   800381 <fd_lookup>
  800532:	89 c3                	mov    %eax,%ebx
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 c0                	test   %eax,%eax
  800539:	0f 88 81 00 00 00    	js     8005c0 <dup+0xa7>
		return r;
	close(newfdnum);
  80053f:	83 ec 0c             	sub    $0xc,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	e8 75 ff ff ff       	call   8004bf <close>

	newfd = INDEX2FD(newfdnum);
  80054a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80054d:	c1 e6 0c             	shl    $0xc,%esi
  800550:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800556:	83 c4 04             	add    $0x4,%esp
  800559:	ff 75 e4             	pushl  -0x1c(%ebp)
  80055c:	e8 af fd ff ff       	call   800310 <fd2data>
  800561:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800563:	89 34 24             	mov    %esi,(%esp)
  800566:	e8 a5 fd ff ff       	call   800310 <fd2data>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800570:	89 d8                	mov    %ebx,%eax
  800572:	c1 e8 16             	shr    $0x16,%eax
  800575:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80057c:	a8 01                	test   $0x1,%al
  80057e:	74 11                	je     800591 <dup+0x78>
  800580:	89 d8                	mov    %ebx,%eax
  800582:	c1 e8 0c             	shr    $0xc,%eax
  800585:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058c:	f6 c2 01             	test   $0x1,%dl
  80058f:	75 39                	jne    8005ca <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800591:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800594:	89 d0                	mov    %edx,%eax
  800596:	c1 e8 0c             	shr    $0xc,%eax
  800599:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a8:	50                   	push   %eax
  8005a9:	56                   	push   %esi
  8005aa:	6a 00                	push   $0x0
  8005ac:	52                   	push   %edx
  8005ad:	6a 00                	push   $0x0
  8005af:	e8 d7 fb ff ff       	call   80018b <sys_page_map>
  8005b4:	89 c3                	mov    %eax,%ebx
  8005b6:	83 c4 20             	add    $0x20,%esp
  8005b9:	85 c0                	test   %eax,%eax
  8005bb:	78 31                	js     8005ee <dup+0xd5>
		goto err;

	return newfdnum;
  8005bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005c0:	89 d8                	mov    %ebx,%eax
  8005c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c5:	5b                   	pop    %ebx
  8005c6:	5e                   	pop    %esi
  8005c7:	5f                   	pop    %edi
  8005c8:	5d                   	pop    %ebp
  8005c9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d1:	83 ec 0c             	sub    $0xc,%esp
  8005d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d9:	50                   	push   %eax
  8005da:	57                   	push   %edi
  8005db:	6a 00                	push   $0x0
  8005dd:	53                   	push   %ebx
  8005de:	6a 00                	push   $0x0
  8005e0:	e8 a6 fb ff ff       	call   80018b <sys_page_map>
  8005e5:	89 c3                	mov    %eax,%ebx
  8005e7:	83 c4 20             	add    $0x20,%esp
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	79 a3                	jns    800591 <dup+0x78>
	sys_page_unmap(0, newfd);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	56                   	push   %esi
  8005f2:	6a 00                	push   $0x0
  8005f4:	e8 b7 fb ff ff       	call   8001b0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f9:	83 c4 08             	add    $0x8,%esp
  8005fc:	57                   	push   %edi
  8005fd:	6a 00                	push   $0x0
  8005ff:	e8 ac fb ff ff       	call   8001b0 <sys_page_unmap>
	return r;
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	eb b7                	jmp    8005c0 <dup+0xa7>

00800609 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800609:	f3 0f 1e fb          	endbr32 
  80060d:	55                   	push   %ebp
  80060e:	89 e5                	mov    %esp,%ebp
  800610:	53                   	push   %ebx
  800611:	83 ec 1c             	sub    $0x1c,%esp
  800614:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800617:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80061a:	50                   	push   %eax
  80061b:	53                   	push   %ebx
  80061c:	e8 60 fd ff ff       	call   800381 <fd_lookup>
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	85 c0                	test   %eax,%eax
  800626:	78 3f                	js     800667 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80062e:	50                   	push   %eax
  80062f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800632:	ff 30                	pushl  (%eax)
  800634:	e8 9c fd ff ff       	call   8003d5 <dev_lookup>
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 27                	js     800667 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800640:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800643:	8b 42 08             	mov    0x8(%edx),%eax
  800646:	83 e0 03             	and    $0x3,%eax
  800649:	83 f8 01             	cmp    $0x1,%eax
  80064c:	74 1e                	je     80066c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80064e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800651:	8b 40 08             	mov    0x8(%eax),%eax
  800654:	85 c0                	test   %eax,%eax
  800656:	74 35                	je     80068d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800658:	83 ec 04             	sub    $0x4,%esp
  80065b:	ff 75 10             	pushl  0x10(%ebp)
  80065e:	ff 75 0c             	pushl  0xc(%ebp)
  800661:	52                   	push   %edx
  800662:	ff d0                	call   *%eax
  800664:	83 c4 10             	add    $0x10,%esp
}
  800667:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80066a:	c9                   	leave  
  80066b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066c:	a1 08 40 80 00       	mov    0x804008,%eax
  800671:	8b 40 48             	mov    0x48(%eax),%eax
  800674:	83 ec 04             	sub    $0x4,%esp
  800677:	53                   	push   %ebx
  800678:	50                   	push   %eax
  800679:	68 ad 23 80 00       	push   $0x8023ad
  80067e:	e8 68 0f 00 00       	call   8015eb <cprintf>
		return -E_INVAL;
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068b:	eb da                	jmp    800667 <read+0x5e>
		return -E_NOT_SUPP;
  80068d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800692:	eb d3                	jmp    800667 <read+0x5e>

00800694 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800694:	f3 0f 1e fb          	endbr32 
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	57                   	push   %edi
  80069c:	56                   	push   %esi
  80069d:	53                   	push   %ebx
  80069e:	83 ec 0c             	sub    $0xc,%esp
  8006a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ac:	eb 02                	jmp    8006b0 <readn+0x1c>
  8006ae:	01 c3                	add    %eax,%ebx
  8006b0:	39 f3                	cmp    %esi,%ebx
  8006b2:	73 21                	jae    8006d5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	89 f0                	mov    %esi,%eax
  8006b9:	29 d8                	sub    %ebx,%eax
  8006bb:	50                   	push   %eax
  8006bc:	89 d8                	mov    %ebx,%eax
  8006be:	03 45 0c             	add    0xc(%ebp),%eax
  8006c1:	50                   	push   %eax
  8006c2:	57                   	push   %edi
  8006c3:	e8 41 ff ff ff       	call   800609 <read>
		if (m < 0)
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	78 04                	js     8006d3 <readn+0x3f>
			return m;
		if (m == 0)
  8006cf:	75 dd                	jne    8006ae <readn+0x1a>
  8006d1:	eb 02                	jmp    8006d5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006d5:	89 d8                	mov    %ebx,%eax
  8006d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006da:	5b                   	pop    %ebx
  8006db:	5e                   	pop    %esi
  8006dc:	5f                   	pop    %edi
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006df:	f3 0f 1e fb          	endbr32 
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	53                   	push   %ebx
  8006e7:	83 ec 1c             	sub    $0x1c,%esp
  8006ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	53                   	push   %ebx
  8006f2:	e8 8a fc ff ff       	call   800381 <fd_lookup>
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	78 3a                	js     800738 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800708:	ff 30                	pushl  (%eax)
  80070a:	e8 c6 fc ff ff       	call   8003d5 <dev_lookup>
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	85 c0                	test   %eax,%eax
  800714:	78 22                	js     800738 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800716:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800719:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80071d:	74 1e                	je     80073d <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80071f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800722:	8b 52 0c             	mov    0xc(%edx),%edx
  800725:	85 d2                	test   %edx,%edx
  800727:	74 35                	je     80075e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800729:	83 ec 04             	sub    $0x4,%esp
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	50                   	push   %eax
  800733:	ff d2                	call   *%edx
  800735:	83 c4 10             	add    $0x10,%esp
}
  800738:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073d:	a1 08 40 80 00       	mov    0x804008,%eax
  800742:	8b 40 48             	mov    0x48(%eax),%eax
  800745:	83 ec 04             	sub    $0x4,%esp
  800748:	53                   	push   %ebx
  800749:	50                   	push   %eax
  80074a:	68 c9 23 80 00       	push   $0x8023c9
  80074f:	e8 97 0e 00 00       	call   8015eb <cprintf>
		return -E_INVAL;
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075c:	eb da                	jmp    800738 <write+0x59>
		return -E_NOT_SUPP;
  80075e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800763:	eb d3                	jmp    800738 <write+0x59>

00800765 <seek>:

int
seek(int fdnum, off_t offset)
{
  800765:	f3 0f 1e fb          	endbr32 
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80076f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800772:	50                   	push   %eax
  800773:	ff 75 08             	pushl  0x8(%ebp)
  800776:	e8 06 fc ff ff       	call   800381 <fd_lookup>
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	85 c0                	test   %eax,%eax
  800780:	78 0e                	js     800790 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
  800785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800788:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800792:	f3 0f 1e fb          	endbr32 
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	83 ec 1c             	sub    $0x1c,%esp
  80079d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a3:	50                   	push   %eax
  8007a4:	53                   	push   %ebx
  8007a5:	e8 d7 fb ff ff       	call   800381 <fd_lookup>
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	78 37                	js     8007e8 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b7:	50                   	push   %eax
  8007b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bb:	ff 30                	pushl  (%eax)
  8007bd:	e8 13 fc ff ff       	call   8003d5 <dev_lookup>
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	78 1f                	js     8007e8 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d0:	74 1b                	je     8007ed <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d5:	8b 52 18             	mov    0x18(%edx),%edx
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 32                	je     80080e <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	50                   	push   %eax
  8007e3:	ff d2                	call   *%edx
  8007e5:	83 c4 10             	add    $0x10,%esp
}
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ed:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f2:	8b 40 48             	mov    0x48(%eax),%eax
  8007f5:	83 ec 04             	sub    $0x4,%esp
  8007f8:	53                   	push   %ebx
  8007f9:	50                   	push   %eax
  8007fa:	68 8c 23 80 00       	push   $0x80238c
  8007ff:	e8 e7 0d 00 00       	call   8015eb <cprintf>
		return -E_INVAL;
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080c:	eb da                	jmp    8007e8 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80080e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800813:	eb d3                	jmp    8007e8 <ftruncate+0x56>

00800815 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800815:	f3 0f 1e fb          	endbr32 
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	83 ec 1c             	sub    $0x1c,%esp
  800820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800823:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	ff 75 08             	pushl  0x8(%ebp)
  80082a:	e8 52 fb ff ff       	call   800381 <fd_lookup>
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	85 c0                	test   %eax,%eax
  800834:	78 4b                	js     800881 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800840:	ff 30                	pushl  (%eax)
  800842:	e8 8e fb ff ff       	call   8003d5 <dev_lookup>
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	85 c0                	test   %eax,%eax
  80084c:	78 33                	js     800881 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80084e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800851:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800855:	74 2f                	je     800886 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800857:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80085a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800861:	00 00 00 
	stat->st_isdir = 0;
  800864:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80086b:	00 00 00 
	stat->st_dev = dev;
  80086e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	53                   	push   %ebx
  800878:	ff 75 f0             	pushl  -0x10(%ebp)
  80087b:	ff 50 14             	call   *0x14(%eax)
  80087e:	83 c4 10             	add    $0x10,%esp
}
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    
		return -E_NOT_SUPP;
  800886:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80088b:	eb f4                	jmp    800881 <fstat+0x6c>

0080088d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800896:	83 ec 08             	sub    $0x8,%esp
  800899:	6a 00                	push   $0x0
  80089b:	ff 75 08             	pushl  0x8(%ebp)
  80089e:	e8 01 02 00 00       	call   800aa4 <open>
  8008a3:	89 c3                	mov    %eax,%ebx
  8008a5:	83 c4 10             	add    $0x10,%esp
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	78 1b                	js     8008c7 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	50                   	push   %eax
  8008b3:	e8 5d ff ff ff       	call   800815 <fstat>
  8008b8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ba:	89 1c 24             	mov    %ebx,(%esp)
  8008bd:	e8 fd fb ff ff       	call   8004bf <close>
	return r;
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	89 f3                	mov    %esi,%ebx
}
  8008c7:	89 d8                	mov    %ebx,%eax
  8008c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	56                   	push   %esi
  8008d4:	53                   	push   %ebx
  8008d5:	89 c6                	mov    %eax,%esi
  8008d7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e0:	74 27                	je     800909 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e2:	6a 07                	push   $0x7
  8008e4:	68 00 50 80 00       	push   $0x805000
  8008e9:	56                   	push   %esi
  8008ea:	ff 35 00 40 80 00    	pushl  0x804000
  8008f0:	e8 27 17 00 00       	call   80201c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f5:	83 c4 0c             	add    $0xc,%esp
  8008f8:	6a 00                	push   $0x0
  8008fa:	53                   	push   %ebx
  8008fb:	6a 00                	push   $0x0
  8008fd:	e8 ad 16 00 00       	call   801faf <ipc_recv>
}
  800902:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800909:	83 ec 0c             	sub    $0xc,%esp
  80090c:	6a 01                	push   $0x1
  80090e:	e8 61 17 00 00       	call   802074 <ipc_find_env>
  800913:	a3 00 40 80 00       	mov    %eax,0x804000
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	eb c5                	jmp    8008e2 <fsipc+0x12>

0080091d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091d:	f3 0f 1e fb          	endbr32 
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 40 0c             	mov    0xc(%eax),%eax
  80092d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800932:	8b 45 0c             	mov    0xc(%ebp),%eax
  800935:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093a:	ba 00 00 00 00       	mov    $0x0,%edx
  80093f:	b8 02 00 00 00       	mov    $0x2,%eax
  800944:	e8 87 ff ff ff       	call   8008d0 <fsipc>
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <devfile_flush>:
{
  80094b:	f3 0f 1e fb          	endbr32 
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 40 0c             	mov    0xc(%eax),%eax
  80095b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
  800965:	b8 06 00 00 00       	mov    $0x6,%eax
  80096a:	e8 61 ff ff ff       	call   8008d0 <fsipc>
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <devfile_stat>:
{
  800971:	f3 0f 1e fb          	endbr32 
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	83 ec 04             	sub    $0x4,%esp
  80097c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 40 0c             	mov    0xc(%eax),%eax
  800985:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098a:	ba 00 00 00 00       	mov    $0x0,%edx
  80098f:	b8 05 00 00 00       	mov    $0x5,%eax
  800994:	e8 37 ff ff ff       	call   8008d0 <fsipc>
  800999:	85 c0                	test   %eax,%eax
  80099b:	78 2c                	js     8009c9 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099d:	83 ec 08             	sub    $0x8,%esp
  8009a0:	68 00 50 80 00       	push   $0x805000
  8009a5:	53                   	push   %ebx
  8009a6:	e8 4a 12 00 00       	call   801bf5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ab:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c1:	83 c4 10             	add    $0x10,%esp
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <devfile_write>:
{
  8009ce:	f3 0f 1e fb          	endbr32 
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 0c             	sub    $0xc,%esp
  8009d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009db:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009e5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8009ee:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009f4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f9:	50                   	push   %eax
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	68 08 50 80 00       	push   $0x805008
  800a02:	e8 ec 13 00 00       	call   801df3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a07:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a11:	e8 ba fe ff ff       	call   8008d0 <fsipc>
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <devfile_read>:
{
  800a18:	f3 0f 1e fb          	endbr32 
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a2f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a3f:	e8 8c fe ff ff       	call   8008d0 <fsipc>
  800a44:	89 c3                	mov    %eax,%ebx
  800a46:	85 c0                	test   %eax,%eax
  800a48:	78 1f                	js     800a69 <devfile_read+0x51>
	assert(r <= n);
  800a4a:	39 f0                	cmp    %esi,%eax
  800a4c:	77 24                	ja     800a72 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a4e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a53:	7f 36                	jg     800a8b <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a55:	83 ec 04             	sub    $0x4,%esp
  800a58:	50                   	push   %eax
  800a59:	68 00 50 80 00       	push   $0x805000
  800a5e:	ff 75 0c             	pushl  0xc(%ebp)
  800a61:	e8 8d 13 00 00       	call   801df3 <memmove>
	return r;
  800a66:	83 c4 10             	add    $0x10,%esp
}
  800a69:	89 d8                	mov    %ebx,%eax
  800a6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    
	assert(r <= n);
  800a72:	68 fc 23 80 00       	push   $0x8023fc
  800a77:	68 03 24 80 00       	push   $0x802403
  800a7c:	68 8c 00 00 00       	push   $0x8c
  800a81:	68 18 24 80 00       	push   $0x802418
  800a86:	e8 79 0a 00 00       	call   801504 <_panic>
	assert(r <= PGSIZE);
  800a8b:	68 23 24 80 00       	push   $0x802423
  800a90:	68 03 24 80 00       	push   $0x802403
  800a95:	68 8d 00 00 00       	push   $0x8d
  800a9a:	68 18 24 80 00       	push   $0x802418
  800a9f:	e8 60 0a 00 00       	call   801504 <_panic>

00800aa4 <open>:
{
  800aa4:	f3 0f 1e fb          	endbr32 
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	83 ec 1c             	sub    $0x1c,%esp
  800ab0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ab3:	56                   	push   %esi
  800ab4:	e8 f9 10 00 00       	call   801bb2 <strlen>
  800ab9:	83 c4 10             	add    $0x10,%esp
  800abc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac1:	7f 6c                	jg     800b2f <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ac3:	83 ec 0c             	sub    $0xc,%esp
  800ac6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac9:	50                   	push   %eax
  800aca:	e8 5c f8 ff ff       	call   80032b <fd_alloc>
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	83 c4 10             	add    $0x10,%esp
  800ad4:	85 c0                	test   %eax,%eax
  800ad6:	78 3c                	js     800b14 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ad8:	83 ec 08             	sub    $0x8,%esp
  800adb:	56                   	push   %esi
  800adc:	68 00 50 80 00       	push   $0x805000
  800ae1:	e8 0f 11 00 00       	call   801bf5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af1:	b8 01 00 00 00       	mov    $0x1,%eax
  800af6:	e8 d5 fd ff ff       	call   8008d0 <fsipc>
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	85 c0                	test   %eax,%eax
  800b02:	78 19                	js     800b1d <open+0x79>
	return fd2num(fd);
  800b04:	83 ec 0c             	sub    $0xc,%esp
  800b07:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0a:	e8 ed f7 ff ff       	call   8002fc <fd2num>
  800b0f:	89 c3                	mov    %eax,%ebx
  800b11:	83 c4 10             	add    $0x10,%esp
}
  800b14:	89 d8                	mov    %ebx,%eax
  800b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    
		fd_close(fd, 0);
  800b1d:	83 ec 08             	sub    $0x8,%esp
  800b20:	6a 00                	push   $0x0
  800b22:	ff 75 f4             	pushl  -0xc(%ebp)
  800b25:	e8 0a f9 ff ff       	call   800434 <fd_close>
		return r;
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	eb e5                	jmp    800b14 <open+0x70>
		return -E_BAD_PATH;
  800b2f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b34:	eb de                	jmp    800b14 <open+0x70>

00800b36 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b36:	f3 0f 1e fb          	endbr32 
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4a:	e8 81 fd ff ff       	call   8008d0 <fsipc>
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b51:	f3 0f 1e fb          	endbr32 
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b5b:	68 8f 24 80 00       	push   $0x80248f
  800b60:	ff 75 0c             	pushl  0xc(%ebp)
  800b63:	e8 8d 10 00 00       	call   801bf5 <strcpy>
	return 0;
}
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <devsock_close>:
{
  800b6f:	f3 0f 1e fb          	endbr32 
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	53                   	push   %ebx
  800b77:	83 ec 10             	sub    $0x10,%esp
  800b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b7d:	53                   	push   %ebx
  800b7e:	e8 2e 15 00 00       	call   8020b1 <pageref>
  800b83:	89 c2                	mov    %eax,%edx
  800b85:	83 c4 10             	add    $0x10,%esp
		return 0;
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800b8d:	83 fa 01             	cmp    $0x1,%edx
  800b90:	74 05                	je     800b97 <devsock_close+0x28>
}
  800b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	ff 73 0c             	pushl  0xc(%ebx)
  800b9d:	e8 e3 02 00 00       	call   800e85 <nsipc_close>
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	eb eb                	jmp    800b92 <devsock_close+0x23>

00800ba7 <devsock_write>:
{
  800ba7:	f3 0f 1e fb          	endbr32 
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bb1:	6a 00                	push   $0x0
  800bb3:	ff 75 10             	pushl  0x10(%ebp)
  800bb6:	ff 75 0c             	pushl  0xc(%ebp)
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	ff 70 0c             	pushl  0xc(%eax)
  800bbf:	e8 b5 03 00 00       	call   800f79 <nsipc_send>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <devsock_read>:
{
  800bc6:	f3 0f 1e fb          	endbr32 
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bd0:	6a 00                	push   $0x0
  800bd2:	ff 75 10             	pushl  0x10(%ebp)
  800bd5:	ff 75 0c             	pushl  0xc(%ebp)
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	ff 70 0c             	pushl  0xc(%eax)
  800bde:	e8 1f 03 00 00       	call   800f02 <nsipc_recv>
}
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <fd2sockid>:
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800beb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800bee:	52                   	push   %edx
  800bef:	50                   	push   %eax
  800bf0:	e8 8c f7 ff ff       	call   800381 <fd_lookup>
  800bf5:	83 c4 10             	add    $0x10,%esp
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	78 10                	js     800c0c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bff:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800c05:	39 08                	cmp    %ecx,(%eax)
  800c07:	75 05                	jne    800c0e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c09:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    
		return -E_NOT_SUPP;
  800c0e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c13:	eb f7                	jmp    800c0c <fd2sockid+0x27>

00800c15 <alloc_sockfd>:
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 1c             	sub    $0x1c,%esp
  800c1d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c22:	50                   	push   %eax
  800c23:	e8 03 f7 ff ff       	call   80032b <fd_alloc>
  800c28:	89 c3                	mov    %eax,%ebx
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	78 43                	js     800c74 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c31:	83 ec 04             	sub    $0x4,%esp
  800c34:	68 07 04 00 00       	push   $0x407
  800c39:	ff 75 f4             	pushl  -0xc(%ebp)
  800c3c:	6a 00                	push   $0x0
  800c3e:	e8 22 f5 ff ff       	call   800165 <sys_page_alloc>
  800c43:	89 c3                	mov    %eax,%ebx
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	78 28                	js     800c74 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4f:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c55:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c61:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	e8 8f f6 ff ff       	call   8002fc <fd2num>
  800c6d:	89 c3                	mov    %eax,%ebx
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	eb 0c                	jmp    800c80 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	56                   	push   %esi
  800c78:	e8 08 02 00 00       	call   800e85 <nsipc_close>
		return r;
  800c7d:	83 c4 10             	add    $0x10,%esp
}
  800c80:	89 d8                	mov    %ebx,%eax
  800c82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <accept>:
{
  800c89:	f3 0f 1e fb          	endbr32 
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	e8 4a ff ff ff       	call   800be5 <fd2sockid>
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	78 1b                	js     800cba <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800c9f:	83 ec 04             	sub    $0x4,%esp
  800ca2:	ff 75 10             	pushl  0x10(%ebp)
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	50                   	push   %eax
  800ca9:	e8 22 01 00 00       	call   800dd0 <nsipc_accept>
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	78 05                	js     800cba <accept+0x31>
	return alloc_sockfd(r);
  800cb5:	e8 5b ff ff ff       	call   800c15 <alloc_sockfd>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <bind>:
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	e8 17 ff ff ff       	call   800be5 <fd2sockid>
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	78 12                	js     800ce4 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800cd2:	83 ec 04             	sub    $0x4,%esp
  800cd5:	ff 75 10             	pushl  0x10(%ebp)
  800cd8:	ff 75 0c             	pushl  0xc(%ebp)
  800cdb:	50                   	push   %eax
  800cdc:	e8 45 01 00 00       	call   800e26 <nsipc_bind>
  800ce1:	83 c4 10             	add    $0x10,%esp
}
  800ce4:	c9                   	leave  
  800ce5:	c3                   	ret    

00800ce6 <shutdown>:
{
  800ce6:	f3 0f 1e fb          	endbr32 
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	e8 ed fe ff ff       	call   800be5 <fd2sockid>
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	78 0f                	js     800d0b <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800cfc:	83 ec 08             	sub    $0x8,%esp
  800cff:	ff 75 0c             	pushl  0xc(%ebp)
  800d02:	50                   	push   %eax
  800d03:	e8 57 01 00 00       	call   800e5f <nsipc_shutdown>
  800d08:	83 c4 10             	add    $0x10,%esp
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <connect>:
{
  800d0d:	f3 0f 1e fb          	endbr32 
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	e8 c6 fe ff ff       	call   800be5 <fd2sockid>
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 12                	js     800d35 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d23:	83 ec 04             	sub    $0x4,%esp
  800d26:	ff 75 10             	pushl  0x10(%ebp)
  800d29:	ff 75 0c             	pushl  0xc(%ebp)
  800d2c:	50                   	push   %eax
  800d2d:	e8 71 01 00 00       	call   800ea3 <nsipc_connect>
  800d32:	83 c4 10             	add    $0x10,%esp
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <listen>:
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	e8 9c fe ff ff       	call   800be5 <fd2sockid>
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	78 0f                	js     800d5c <listen+0x25>
	return nsipc_listen(r, backlog);
  800d4d:	83 ec 08             	sub    $0x8,%esp
  800d50:	ff 75 0c             	pushl  0xc(%ebp)
  800d53:	50                   	push   %eax
  800d54:	e8 83 01 00 00       	call   800edc <nsipc_listen>
  800d59:	83 c4 10             	add    $0x10,%esp
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    

00800d5e <socket>:

int
socket(int domain, int type, int protocol)
{
  800d5e:	f3 0f 1e fb          	endbr32 
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d68:	ff 75 10             	pushl  0x10(%ebp)
  800d6b:	ff 75 0c             	pushl  0xc(%ebp)
  800d6e:	ff 75 08             	pushl  0x8(%ebp)
  800d71:	e8 65 02 00 00       	call   800fdb <nsipc_socket>
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 05                	js     800d82 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d7d:	e8 93 fe ff ff       	call   800c15 <alloc_sockfd>
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	53                   	push   %ebx
  800d88:	83 ec 04             	sub    $0x4,%esp
  800d8b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d8d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d94:	74 26                	je     800dbc <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d96:	6a 07                	push   $0x7
  800d98:	68 00 60 80 00       	push   $0x806000
  800d9d:	53                   	push   %ebx
  800d9e:	ff 35 04 40 80 00    	pushl  0x804004
  800da4:	e8 73 12 00 00       	call   80201c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800da9:	83 c4 0c             	add    $0xc,%esp
  800dac:	6a 00                	push   $0x0
  800dae:	6a 00                	push   $0x0
  800db0:	6a 00                	push   $0x0
  800db2:	e8 f8 11 00 00       	call   801faf <ipc_recv>
}
  800db7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	6a 02                	push   $0x2
  800dc1:	e8 ae 12 00 00       	call   802074 <ipc_find_env>
  800dc6:	a3 04 40 80 00       	mov    %eax,0x804004
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	eb c6                	jmp    800d96 <nsipc+0x12>

00800dd0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800de4:	8b 06                	mov    (%esi),%eax
  800de6:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800deb:	b8 01 00 00 00       	mov    $0x1,%eax
  800df0:	e8 8f ff ff ff       	call   800d84 <nsipc>
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	85 c0                	test   %eax,%eax
  800df9:	79 09                	jns    800e04 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	ff 35 10 60 80 00    	pushl  0x806010
  800e0d:	68 00 60 80 00       	push   $0x806000
  800e12:	ff 75 0c             	pushl  0xc(%ebp)
  800e15:	e8 d9 0f 00 00       	call   801df3 <memmove>
		*addrlen = ret->ret_addrlen;
  800e1a:	a1 10 60 80 00       	mov    0x806010,%eax
  800e1f:	89 06                	mov    %eax,(%esi)
  800e21:	83 c4 10             	add    $0x10,%esp
	return r;
  800e24:	eb d5                	jmp    800dfb <nsipc_accept+0x2b>

00800e26 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e26:	f3 0f 1e fb          	endbr32 
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e3c:	53                   	push   %ebx
  800e3d:	ff 75 0c             	pushl  0xc(%ebp)
  800e40:	68 04 60 80 00       	push   $0x806004
  800e45:	e8 a9 0f 00 00       	call   801df3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e4a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e50:	b8 02 00 00 00       	mov    $0x2,%eax
  800e55:	e8 2a ff ff ff       	call   800d84 <nsipc>
}
  800e5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5d:	c9                   	leave  
  800e5e:	c3                   	ret    

00800e5f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e5f:	f3 0f 1e fb          	endbr32 
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e74:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e79:	b8 03 00 00 00       	mov    $0x3,%eax
  800e7e:	e8 01 ff ff ff       	call   800d84 <nsipc>
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <nsipc_close>:

int
nsipc_close(int s)
{
  800e85:	f3 0f 1e fb          	endbr32 
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e97:	b8 04 00 00 00       	mov    $0x4,%eax
  800e9c:	e8 e3 fe ff ff       	call   800d84 <nsipc>
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea3:	f3 0f 1e fb          	endbr32 
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eb9:	53                   	push   %ebx
  800eba:	ff 75 0c             	pushl  0xc(%ebp)
  800ebd:	68 04 60 80 00       	push   $0x806004
  800ec2:	e8 2c 0f 00 00       	call   801df3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ec7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ecd:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed2:	e8 ad fe ff ff       	call   800d84 <nsipc>
}
  800ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800edc:	f3 0f 1e fb          	endbr32 
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ef6:	b8 06 00 00 00       	mov    $0x6,%eax
  800efb:	e8 84 fe ff ff       	call   800d84 <nsipc>
}
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f02:	f3 0f 1e fb          	endbr32 
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f16:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f24:	b8 07 00 00 00       	mov    $0x7,%eax
  800f29:	e8 56 fe ff ff       	call   800d84 <nsipc>
  800f2e:	89 c3                	mov    %eax,%ebx
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 26                	js     800f5a <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f34:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f3a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f3f:	0f 4e c6             	cmovle %esi,%eax
  800f42:	39 c3                	cmp    %eax,%ebx
  800f44:	7f 1d                	jg     800f63 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	53                   	push   %ebx
  800f4a:	68 00 60 80 00       	push   $0x806000
  800f4f:	ff 75 0c             	pushl  0xc(%ebp)
  800f52:	e8 9c 0e 00 00       	call   801df3 <memmove>
  800f57:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f5a:	89 d8                	mov    %ebx,%eax
  800f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f63:	68 9b 24 80 00       	push   $0x80249b
  800f68:	68 03 24 80 00       	push   $0x802403
  800f6d:	6a 62                	push   $0x62
  800f6f:	68 b0 24 80 00       	push   $0x8024b0
  800f74:	e8 8b 05 00 00       	call   801504 <_panic>

00800f79 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f79:	f3 0f 1e fb          	endbr32 
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	53                   	push   %ebx
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f8f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f95:	7f 2e                	jg     800fc5 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	53                   	push   %ebx
  800f9b:	ff 75 0c             	pushl  0xc(%ebp)
  800f9e:	68 0c 60 80 00       	push   $0x80600c
  800fa3:	e8 4b 0e 00 00       	call   801df3 <memmove>
	nsipcbuf.send.req_size = size;
  800fa8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fae:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fb6:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbb:	e8 c4 fd ff ff       	call   800d84 <nsipc>
}
  800fc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    
	assert(size < 1600);
  800fc5:	68 bc 24 80 00       	push   $0x8024bc
  800fca:	68 03 24 80 00       	push   $0x802403
  800fcf:	6a 6d                	push   $0x6d
  800fd1:	68 b0 24 80 00       	push   $0x8024b0
  800fd6:	e8 29 05 00 00       	call   801504 <_panic>

00800fdb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdb:	f3 0f 1e fb          	endbr32 
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ffd:	b8 09 00 00 00       	mov    $0x9,%eax
  801002:	e8 7d fd ff ff       	call   800d84 <nsipc>
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801009:	f3 0f 1e fb          	endbr32 
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	ff 75 08             	pushl  0x8(%ebp)
  80101b:	e8 f0 f2 ff ff       	call   800310 <fd2data>
  801020:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801022:	83 c4 08             	add    $0x8,%esp
  801025:	68 c8 24 80 00       	push   $0x8024c8
  80102a:	53                   	push   %ebx
  80102b:	e8 c5 0b 00 00       	call   801bf5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801030:	8b 46 04             	mov    0x4(%esi),%eax
  801033:	2b 06                	sub    (%esi),%eax
  801035:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801042:	00 00 00 
	stat->st_dev = &devpipe;
  801045:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  80104c:	30 80 00 
	return 0;
}
  80104f:	b8 00 00 00 00       	mov    $0x0,%eax
  801054:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105b:	f3 0f 1e fb          	endbr32 
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	53                   	push   %ebx
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801069:	53                   	push   %ebx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 3f f1 ff ff       	call   8001b0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801071:	89 1c 24             	mov    %ebx,(%esp)
  801074:	e8 97 f2 ff ff       	call   800310 <fd2data>
  801079:	83 c4 08             	add    $0x8,%esp
  80107c:	50                   	push   %eax
  80107d:	6a 00                	push   $0x0
  80107f:	e8 2c f1 ff ff       	call   8001b0 <sys_page_unmap>
}
  801084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <_pipeisclosed>:
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	57                   	push   %edi
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
  80108f:	83 ec 1c             	sub    $0x1c,%esp
  801092:	89 c7                	mov    %eax,%edi
  801094:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801096:	a1 08 40 80 00       	mov    0x804008,%eax
  80109b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	57                   	push   %edi
  8010a2:	e8 0a 10 00 00       	call   8020b1 <pageref>
  8010a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010aa:	89 34 24             	mov    %esi,(%esp)
  8010ad:	e8 ff 0f 00 00       	call   8020b1 <pageref>
		nn = thisenv->env_runs;
  8010b2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010b8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	39 cb                	cmp    %ecx,%ebx
  8010c0:	74 1b                	je     8010dd <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010c2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c5:	75 cf                	jne    801096 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c7:	8b 42 58             	mov    0x58(%edx),%eax
  8010ca:	6a 01                	push   $0x1
  8010cc:	50                   	push   %eax
  8010cd:	53                   	push   %ebx
  8010ce:	68 cf 24 80 00       	push   $0x8024cf
  8010d3:	e8 13 05 00 00       	call   8015eb <cprintf>
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	eb b9                	jmp    801096 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010dd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010e0:	0f 94 c0             	sete   %al
  8010e3:	0f b6 c0             	movzbl %al,%eax
}
  8010e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5f                   	pop    %edi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <devpipe_write>:
{
  8010ee:	f3 0f 1e fb          	endbr32 
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 28             	sub    $0x28,%esp
  8010fb:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010fe:	56                   	push   %esi
  8010ff:	e8 0c f2 ff ff       	call   800310 <fd2data>
  801104:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	bf 00 00 00 00       	mov    $0x0,%edi
  80110e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801111:	74 4f                	je     801162 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801113:	8b 43 04             	mov    0x4(%ebx),%eax
  801116:	8b 0b                	mov    (%ebx),%ecx
  801118:	8d 51 20             	lea    0x20(%ecx),%edx
  80111b:	39 d0                	cmp    %edx,%eax
  80111d:	72 14                	jb     801133 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80111f:	89 da                	mov    %ebx,%edx
  801121:	89 f0                	mov    %esi,%eax
  801123:	e8 61 ff ff ff       	call   801089 <_pipeisclosed>
  801128:	85 c0                	test   %eax,%eax
  80112a:	75 3b                	jne    801167 <devpipe_write+0x79>
			sys_yield();
  80112c:	e8 11 f0 ff ff       	call   800142 <sys_yield>
  801131:	eb e0                	jmp    801113 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801133:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801136:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	c1 fa 1f             	sar    $0x1f,%edx
  801142:	89 d1                	mov    %edx,%ecx
  801144:	c1 e9 1b             	shr    $0x1b,%ecx
  801147:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114a:	83 e2 1f             	and    $0x1f,%edx
  80114d:	29 ca                	sub    %ecx,%edx
  80114f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801153:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801157:	83 c0 01             	add    $0x1,%eax
  80115a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80115d:	83 c7 01             	add    $0x1,%edi
  801160:	eb ac                	jmp    80110e <devpipe_write+0x20>
	return i;
  801162:	8b 45 10             	mov    0x10(%ebp),%eax
  801165:	eb 05                	jmp    80116c <devpipe_write+0x7e>
				return 0;
  801167:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116f:	5b                   	pop    %ebx
  801170:	5e                   	pop    %esi
  801171:	5f                   	pop    %edi
  801172:	5d                   	pop    %ebp
  801173:	c3                   	ret    

00801174 <devpipe_read>:
{
  801174:	f3 0f 1e fb          	endbr32 
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 18             	sub    $0x18,%esp
  801181:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801184:	57                   	push   %edi
  801185:	e8 86 f1 ff ff       	call   800310 <fd2data>
  80118a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	be 00 00 00 00       	mov    $0x0,%esi
  801194:	3b 75 10             	cmp    0x10(%ebp),%esi
  801197:	75 14                	jne    8011ad <devpipe_read+0x39>
	return i;
  801199:	8b 45 10             	mov    0x10(%ebp),%eax
  80119c:	eb 02                	jmp    8011a0 <devpipe_read+0x2c>
				return i;
  80119e:	89 f0                	mov    %esi,%eax
}
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    
			sys_yield();
  8011a8:	e8 95 ef ff ff       	call   800142 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011ad:	8b 03                	mov    (%ebx),%eax
  8011af:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011b2:	75 18                	jne    8011cc <devpipe_read+0x58>
			if (i > 0)
  8011b4:	85 f6                	test   %esi,%esi
  8011b6:	75 e6                	jne    80119e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011b8:	89 da                	mov    %ebx,%edx
  8011ba:	89 f8                	mov    %edi,%eax
  8011bc:	e8 c8 fe ff ff       	call   801089 <_pipeisclosed>
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	74 e3                	je     8011a8 <devpipe_read+0x34>
				return 0;
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ca:	eb d4                	jmp    8011a0 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011cc:	99                   	cltd   
  8011cd:	c1 ea 1b             	shr    $0x1b,%edx
  8011d0:	01 d0                	add    %edx,%eax
  8011d2:	83 e0 1f             	and    $0x1f,%eax
  8011d5:	29 d0                	sub    %edx,%eax
  8011d7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011df:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011e2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011e5:	83 c6 01             	add    $0x1,%esi
  8011e8:	eb aa                	jmp    801194 <devpipe_read+0x20>

008011ea <pipe>:
{
  8011ea:	f3 0f 1e fb          	endbr32 
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	e8 2c f1 ff ff       	call   80032b <fd_alloc>
  8011ff:	89 c3                	mov    %eax,%ebx
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	0f 88 23 01 00 00    	js     80132f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	68 07 04 00 00       	push   $0x407
  801214:	ff 75 f4             	pushl  -0xc(%ebp)
  801217:	6a 00                	push   $0x0
  801219:	e8 47 ef ff ff       	call   800165 <sys_page_alloc>
  80121e:	89 c3                	mov    %eax,%ebx
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	0f 88 04 01 00 00    	js     80132f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80122b:	83 ec 0c             	sub    $0xc,%esp
  80122e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	e8 f4 f0 ff ff       	call   80032b <fd_alloc>
  801237:	89 c3                	mov    %eax,%ebx
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	0f 88 db 00 00 00    	js     80131f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	68 07 04 00 00       	push   $0x407
  80124c:	ff 75 f0             	pushl  -0x10(%ebp)
  80124f:	6a 00                	push   $0x0
  801251:	e8 0f ef ff ff       	call   800165 <sys_page_alloc>
  801256:	89 c3                	mov    %eax,%ebx
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	0f 88 bc 00 00 00    	js     80131f <pipe+0x135>
	va = fd2data(fd0);
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	ff 75 f4             	pushl  -0xc(%ebp)
  801269:	e8 a2 f0 ff ff       	call   800310 <fd2data>
  80126e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801270:	83 c4 0c             	add    $0xc,%esp
  801273:	68 07 04 00 00       	push   $0x407
  801278:	50                   	push   %eax
  801279:	6a 00                	push   $0x0
  80127b:	e8 e5 ee ff ff       	call   800165 <sys_page_alloc>
  801280:	89 c3                	mov    %eax,%ebx
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	0f 88 82 00 00 00    	js     80130f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	ff 75 f0             	pushl  -0x10(%ebp)
  801293:	e8 78 f0 ff ff       	call   800310 <fd2data>
  801298:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80129f:	50                   	push   %eax
  8012a0:	6a 00                	push   $0x0
  8012a2:	56                   	push   %esi
  8012a3:	6a 00                	push   $0x0
  8012a5:	e8 e1 ee ff ff       	call   80018b <sys_page_map>
  8012aa:	89 c3                	mov    %eax,%ebx
  8012ac:	83 c4 20             	add    $0x20,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 4e                	js     801301 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8012b3:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c0:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ca:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012dc:	e8 1b f0 ff ff       	call   8002fc <fd2num>
  8012e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e6:	83 c4 04             	add    $0x4,%esp
  8012e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ec:	e8 0b f0 ff ff       	call   8002fc <fd2num>
  8012f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ff:	eb 2e                	jmp    80132f <pipe+0x145>
	sys_page_unmap(0, va);
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	56                   	push   %esi
  801305:	6a 00                	push   $0x0
  801307:	e8 a4 ee ff ff       	call   8001b0 <sys_page_unmap>
  80130c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	ff 75 f0             	pushl  -0x10(%ebp)
  801315:	6a 00                	push   $0x0
  801317:	e8 94 ee ff ff       	call   8001b0 <sys_page_unmap>
  80131c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	ff 75 f4             	pushl  -0xc(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	e8 84 ee ff ff       	call   8001b0 <sys_page_unmap>
  80132c:	83 c4 10             	add    $0x10,%esp
}
  80132f:	89 d8                	mov    %ebx,%eax
  801331:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <pipeisclosed>:
{
  801338:	f3 0f 1e fb          	endbr32 
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801342:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	ff 75 08             	pushl  0x8(%ebp)
  801349:	e8 33 f0 ff ff       	call   800381 <fd_lookup>
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	78 18                	js     80136d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	ff 75 f4             	pushl  -0xc(%ebp)
  80135b:	e8 b0 ef ff ff       	call   800310 <fd2data>
  801360:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	e8 1f fd ff ff       	call   801089 <_pipeisclosed>
  80136a:	83 c4 10             	add    $0x10,%esp
}
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80136f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
  801378:	c3                   	ret    

00801379 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801379:	f3 0f 1e fb          	endbr32 
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801383:	68 e7 24 80 00       	push   $0x8024e7
  801388:	ff 75 0c             	pushl  0xc(%ebp)
  80138b:	e8 65 08 00 00       	call   801bf5 <strcpy>
	return 0;
}
  801390:	b8 00 00 00 00       	mov    $0x0,%eax
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <devcons_write>:
{
  801397:	f3 0f 1e fb          	endbr32 
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	57                   	push   %edi
  80139f:	56                   	push   %esi
  8013a0:	53                   	push   %ebx
  8013a1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8013a7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013ac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b5:	73 31                	jae    8013e8 <devcons_write+0x51>
		m = n - tot;
  8013b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ba:	29 f3                	sub    %esi,%ebx
  8013bc:	83 fb 7f             	cmp    $0x7f,%ebx
  8013bf:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013c4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013c7:	83 ec 04             	sub    $0x4,%esp
  8013ca:	53                   	push   %ebx
  8013cb:	89 f0                	mov    %esi,%eax
  8013cd:	03 45 0c             	add    0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	57                   	push   %edi
  8013d2:	e8 1c 0a 00 00       	call   801df3 <memmove>
		sys_cputs(buf, m);
  8013d7:	83 c4 08             	add    $0x8,%esp
  8013da:	53                   	push   %ebx
  8013db:	57                   	push   %edi
  8013dc:	e8 d5 ec ff ff       	call   8000b6 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013e1:	01 de                	add    %ebx,%esi
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	eb ca                	jmp    8013b2 <devcons_write+0x1b>
}
  8013e8:	89 f0                	mov    %esi,%eax
  8013ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5f                   	pop    %edi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    

008013f2 <devcons_read>:
{
  8013f2:	f3 0f 1e fb          	endbr32 
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801401:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801405:	74 21                	je     801428 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801407:	e8 cc ec ff ff       	call   8000d8 <sys_cgetc>
  80140c:	85 c0                	test   %eax,%eax
  80140e:	75 07                	jne    801417 <devcons_read+0x25>
		sys_yield();
  801410:	e8 2d ed ff ff       	call   800142 <sys_yield>
  801415:	eb f0                	jmp    801407 <devcons_read+0x15>
	if (c < 0)
  801417:	78 0f                	js     801428 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801419:	83 f8 04             	cmp    $0x4,%eax
  80141c:	74 0c                	je     80142a <devcons_read+0x38>
	*(char*)vbuf = c;
  80141e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801421:	88 02                	mov    %al,(%edx)
	return 1;
  801423:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801428:	c9                   	leave  
  801429:	c3                   	ret    
		return 0;
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
  80142f:	eb f7                	jmp    801428 <devcons_read+0x36>

00801431 <cputchar>:
{
  801431:	f3 0f 1e fb          	endbr32 
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801441:	6a 01                	push   $0x1
  801443:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801446:	50                   	push   %eax
  801447:	e8 6a ec ff ff       	call   8000b6 <sys_cputs>
}
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <getchar>:
{
  801451:	f3 0f 1e fb          	endbr32 
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80145b:	6a 01                	push   $0x1
  80145d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	6a 00                	push   $0x0
  801463:	e8 a1 f1 ff ff       	call   800609 <read>
	if (r < 0)
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 06                	js     801475 <getchar+0x24>
	if (r < 1)
  80146f:	74 06                	je     801477 <getchar+0x26>
	return c;
  801471:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    
		return -E_EOF;
  801477:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80147c:	eb f7                	jmp    801475 <getchar+0x24>

0080147e <iscons>:
{
  80147e:	f3 0f 1e fb          	endbr32 
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	ff 75 08             	pushl  0x8(%ebp)
  80148f:	e8 ed ee ff ff       	call   800381 <fd_lookup>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 11                	js     8014ac <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80149b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149e:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014a4:	39 10                	cmp    %edx,(%eax)
  8014a6:	0f 94 c0             	sete   %al
  8014a9:	0f b6 c0             	movzbl %al,%eax
}
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <opencons>:
{
  8014ae:	f3 0f 1e fb          	endbr32 
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	e8 6a ee ff ff       	call   80032b <fd_alloc>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 3a                	js     801502 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	68 07 04 00 00       	push   $0x407
  8014d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d3:	6a 00                	push   $0x0
  8014d5:	e8 8b ec ff ff       	call   800165 <sys_page_alloc>
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 21                	js     801502 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e4:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014ea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	50                   	push   %eax
  8014fa:	e8 fd ed ff ff       	call   8002fc <fd2num>
  8014ff:	83 c4 10             	add    $0x10,%esp
}
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801504:	f3 0f 1e fb          	endbr32 
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80150d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801510:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801516:	e8 04 ec ff ff       	call   80011f <sys_getenvid>
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	ff 75 0c             	pushl  0xc(%ebp)
  801521:	ff 75 08             	pushl  0x8(%ebp)
  801524:	56                   	push   %esi
  801525:	50                   	push   %eax
  801526:	68 f4 24 80 00       	push   $0x8024f4
  80152b:	e8 bb 00 00 00       	call   8015eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801530:	83 c4 18             	add    $0x18,%esp
  801533:	53                   	push   %ebx
  801534:	ff 75 10             	pushl  0x10(%ebp)
  801537:	e8 5a 00 00 00       	call   801596 <vcprintf>
	cprintf("\n");
  80153c:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  801543:	e8 a3 00 00 00       	call   8015eb <cprintf>
  801548:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80154b:	cc                   	int3   
  80154c:	eb fd                	jmp    80154b <_panic+0x47>

0080154e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80154e:	f3 0f 1e fb          	endbr32 
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	53                   	push   %ebx
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80155c:	8b 13                	mov    (%ebx),%edx
  80155e:	8d 42 01             	lea    0x1(%edx),%eax
  801561:	89 03                	mov    %eax,(%ebx)
  801563:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801566:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80156a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80156f:	74 09                	je     80157a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801571:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801578:	c9                   	leave  
  801579:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	68 ff 00 00 00       	push   $0xff
  801582:	8d 43 08             	lea    0x8(%ebx),%eax
  801585:	50                   	push   %eax
  801586:	e8 2b eb ff ff       	call   8000b6 <sys_cputs>
		b->idx = 0;
  80158b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	eb db                	jmp    801571 <putch+0x23>

00801596 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801596:	f3 0f 1e fb          	endbr32 
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015aa:	00 00 00 
	b.cnt = 0;
  8015ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015b7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	68 4e 15 80 00       	push   $0x80154e
  8015c9:	e8 20 01 00 00       	call   8016ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	e8 d3 ea ff ff       	call   8000b6 <sys_cputs>

	return b.cnt;
}
  8015e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015eb:	f3 0f 1e fb          	endbr32 
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015f5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015f8:	50                   	push   %eax
  8015f9:	ff 75 08             	pushl  0x8(%ebp)
  8015fc:	e8 95 ff ff ff       	call   801596 <vcprintf>
	va_end(ap);

	return cnt;
}
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	57                   	push   %edi
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 1c             	sub    $0x1c,%esp
  80160c:	89 c7                	mov    %eax,%edi
  80160e:	89 d6                	mov    %edx,%esi
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	8b 55 0c             	mov    0xc(%ebp),%edx
  801616:	89 d1                	mov    %edx,%ecx
  801618:	89 c2                	mov    %eax,%edx
  80161a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80161d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801620:	8b 45 10             	mov    0x10(%ebp),%eax
  801623:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801626:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801629:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801630:	39 c2                	cmp    %eax,%edx
  801632:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801635:	72 3e                	jb     801675 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	ff 75 18             	pushl  0x18(%ebp)
  80163d:	83 eb 01             	sub    $0x1,%ebx
  801640:	53                   	push   %ebx
  801641:	50                   	push   %eax
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	ff 75 e4             	pushl  -0x1c(%ebp)
  801648:	ff 75 e0             	pushl  -0x20(%ebp)
  80164b:	ff 75 dc             	pushl  -0x24(%ebp)
  80164e:	ff 75 d8             	pushl  -0x28(%ebp)
  801651:	e8 aa 0a 00 00       	call   802100 <__udivdi3>
  801656:	83 c4 18             	add    $0x18,%esp
  801659:	52                   	push   %edx
  80165a:	50                   	push   %eax
  80165b:	89 f2                	mov    %esi,%edx
  80165d:	89 f8                	mov    %edi,%eax
  80165f:	e8 9f ff ff ff       	call   801603 <printnum>
  801664:	83 c4 20             	add    $0x20,%esp
  801667:	eb 13                	jmp    80167c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	56                   	push   %esi
  80166d:	ff 75 18             	pushl  0x18(%ebp)
  801670:	ff d7                	call   *%edi
  801672:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801675:	83 eb 01             	sub    $0x1,%ebx
  801678:	85 db                	test   %ebx,%ebx
  80167a:	7f ed                	jg     801669 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80167c:	83 ec 08             	sub    $0x8,%esp
  80167f:	56                   	push   %esi
  801680:	83 ec 04             	sub    $0x4,%esp
  801683:	ff 75 e4             	pushl  -0x1c(%ebp)
  801686:	ff 75 e0             	pushl  -0x20(%ebp)
  801689:	ff 75 dc             	pushl  -0x24(%ebp)
  80168c:	ff 75 d8             	pushl  -0x28(%ebp)
  80168f:	e8 7c 0b 00 00       	call   802210 <__umoddi3>
  801694:	83 c4 14             	add    $0x14,%esp
  801697:	0f be 80 17 25 80 00 	movsbl 0x802517(%eax),%eax
  80169e:	50                   	push   %eax
  80169f:	ff d7                	call   *%edi
}
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5f                   	pop    %edi
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ac:	f3 0f 1e fb          	endbr32 
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016ba:	8b 10                	mov    (%eax),%edx
  8016bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8016bf:	73 0a                	jae    8016cb <sprintputch+0x1f>
		*b->buf++ = ch;
  8016c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016c4:	89 08                	mov    %ecx,(%eax)
  8016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c9:	88 02                	mov    %al,(%edx)
}
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <printfmt>:
{
  8016cd:	f3 0f 1e fb          	endbr32 
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016da:	50                   	push   %eax
  8016db:	ff 75 10             	pushl  0x10(%ebp)
  8016de:	ff 75 0c             	pushl  0xc(%ebp)
  8016e1:	ff 75 08             	pushl  0x8(%ebp)
  8016e4:	e8 05 00 00 00       	call   8016ee <vprintfmt>
}
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <vprintfmt>:
{
  8016ee:	f3 0f 1e fb          	endbr32 
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	57                   	push   %edi
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 3c             	sub    $0x3c,%esp
  8016fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801701:	8b 7d 10             	mov    0x10(%ebp),%edi
  801704:	e9 8e 03 00 00       	jmp    801a97 <vprintfmt+0x3a9>
		padc = ' ';
  801709:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80170d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801714:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80171b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801722:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801727:	8d 47 01             	lea    0x1(%edi),%eax
  80172a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80172d:	0f b6 17             	movzbl (%edi),%edx
  801730:	8d 42 dd             	lea    -0x23(%edx),%eax
  801733:	3c 55                	cmp    $0x55,%al
  801735:	0f 87 df 03 00 00    	ja     801b1a <vprintfmt+0x42c>
  80173b:	0f b6 c0             	movzbl %al,%eax
  80173e:	3e ff 24 85 60 26 80 	notrack jmp *0x802660(,%eax,4)
  801745:	00 
  801746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801749:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80174d:	eb d8                	jmp    801727 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80174f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801752:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801756:	eb cf                	jmp    801727 <vprintfmt+0x39>
  801758:	0f b6 d2             	movzbl %dl,%edx
  80175b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
  801763:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801766:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801769:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80176d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801770:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801773:	83 f9 09             	cmp    $0x9,%ecx
  801776:	77 55                	ja     8017cd <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801778:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80177b:	eb e9                	jmp    801766 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80177d:	8b 45 14             	mov    0x14(%ebp),%eax
  801780:	8b 00                	mov    (%eax),%eax
  801782:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801785:	8b 45 14             	mov    0x14(%ebp),%eax
  801788:	8d 40 04             	lea    0x4(%eax),%eax
  80178b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80178e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801791:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801795:	79 90                	jns    801727 <vprintfmt+0x39>
				width = precision, precision = -1;
  801797:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80179a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80179d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8017a4:	eb 81                	jmp    801727 <vprintfmt+0x39>
  8017a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	0f 49 d0             	cmovns %eax,%edx
  8017b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017b9:	e9 69 ff ff ff       	jmp    801727 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017c1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017c8:	e9 5a ff ff ff       	jmp    801727 <vprintfmt+0x39>
  8017cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017d3:	eb bc                	jmp    801791 <vprintfmt+0xa3>
			lflag++;
  8017d5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017db:	e9 47 ff ff ff       	jmp    801727 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e3:	8d 78 04             	lea    0x4(%eax),%edi
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	53                   	push   %ebx
  8017ea:	ff 30                	pushl  (%eax)
  8017ec:	ff d6                	call   *%esi
			break;
  8017ee:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017f1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017f4:	e9 9b 02 00 00       	jmp    801a94 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8017f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fc:	8d 78 04             	lea    0x4(%eax),%edi
  8017ff:	8b 00                	mov    (%eax),%eax
  801801:	99                   	cltd   
  801802:	31 d0                	xor    %edx,%eax
  801804:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801806:	83 f8 0f             	cmp    $0xf,%eax
  801809:	7f 23                	jg     80182e <vprintfmt+0x140>
  80180b:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  801812:	85 d2                	test   %edx,%edx
  801814:	74 18                	je     80182e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801816:	52                   	push   %edx
  801817:	68 15 24 80 00       	push   $0x802415
  80181c:	53                   	push   %ebx
  80181d:	56                   	push   %esi
  80181e:	e8 aa fe ff ff       	call   8016cd <printfmt>
  801823:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801826:	89 7d 14             	mov    %edi,0x14(%ebp)
  801829:	e9 66 02 00 00       	jmp    801a94 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80182e:	50                   	push   %eax
  80182f:	68 2f 25 80 00       	push   $0x80252f
  801834:	53                   	push   %ebx
  801835:	56                   	push   %esi
  801836:	e8 92 fe ff ff       	call   8016cd <printfmt>
  80183b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80183e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801841:	e9 4e 02 00 00       	jmp    801a94 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801846:	8b 45 14             	mov    0x14(%ebp),%eax
  801849:	83 c0 04             	add    $0x4,%eax
  80184c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80184f:	8b 45 14             	mov    0x14(%ebp),%eax
  801852:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801854:	85 d2                	test   %edx,%edx
  801856:	b8 28 25 80 00       	mov    $0x802528,%eax
  80185b:	0f 45 c2             	cmovne %edx,%eax
  80185e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801861:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801865:	7e 06                	jle    80186d <vprintfmt+0x17f>
  801867:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80186b:	75 0d                	jne    80187a <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80186d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801870:	89 c7                	mov    %eax,%edi
  801872:	03 45 e0             	add    -0x20(%ebp),%eax
  801875:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801878:	eb 55                	jmp    8018cf <vprintfmt+0x1e1>
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	ff 75 d8             	pushl  -0x28(%ebp)
  801880:	ff 75 cc             	pushl  -0x34(%ebp)
  801883:	e8 46 03 00 00       	call   801bce <strnlen>
  801888:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80188b:	29 c2                	sub    %eax,%edx
  80188d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801895:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801899:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80189c:	85 ff                	test   %edi,%edi
  80189e:	7e 11                	jle    8018b1 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	53                   	push   %ebx
  8018a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018a7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a9:	83 ef 01             	sub    $0x1,%edi
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	eb eb                	jmp    80189c <vprintfmt+0x1ae>
  8018b1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018b4:	85 d2                	test   %edx,%edx
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bb:	0f 49 c2             	cmovns %edx,%eax
  8018be:	29 c2                	sub    %eax,%edx
  8018c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018c3:	eb a8                	jmp    80186d <vprintfmt+0x17f>
					putch(ch, putdat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	53                   	push   %ebx
  8018c9:	52                   	push   %edx
  8018ca:	ff d6                	call   *%esi
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018d2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d4:	83 c7 01             	add    $0x1,%edi
  8018d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018db:	0f be d0             	movsbl %al,%edx
  8018de:	85 d2                	test   %edx,%edx
  8018e0:	74 4b                	je     80192d <vprintfmt+0x23f>
  8018e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018e6:	78 06                	js     8018ee <vprintfmt+0x200>
  8018e8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018ec:	78 1e                	js     80190c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8018ee:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018f2:	74 d1                	je     8018c5 <vprintfmt+0x1d7>
  8018f4:	0f be c0             	movsbl %al,%eax
  8018f7:	83 e8 20             	sub    $0x20,%eax
  8018fa:	83 f8 5e             	cmp    $0x5e,%eax
  8018fd:	76 c6                	jbe    8018c5 <vprintfmt+0x1d7>
					putch('?', putdat);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	53                   	push   %ebx
  801903:	6a 3f                	push   $0x3f
  801905:	ff d6                	call   *%esi
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	eb c3                	jmp    8018cf <vprintfmt+0x1e1>
  80190c:	89 cf                	mov    %ecx,%edi
  80190e:	eb 0e                	jmp    80191e <vprintfmt+0x230>
				putch(' ', putdat);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	53                   	push   %ebx
  801914:	6a 20                	push   $0x20
  801916:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801918:	83 ef 01             	sub    $0x1,%edi
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	85 ff                	test   %edi,%edi
  801920:	7f ee                	jg     801910 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  801922:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801925:	89 45 14             	mov    %eax,0x14(%ebp)
  801928:	e9 67 01 00 00       	jmp    801a94 <vprintfmt+0x3a6>
  80192d:	89 cf                	mov    %ecx,%edi
  80192f:	eb ed                	jmp    80191e <vprintfmt+0x230>
	if (lflag >= 2)
  801931:	83 f9 01             	cmp    $0x1,%ecx
  801934:	7f 1b                	jg     801951 <vprintfmt+0x263>
	else if (lflag)
  801936:	85 c9                	test   %ecx,%ecx
  801938:	74 63                	je     80199d <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80193a:	8b 45 14             	mov    0x14(%ebp),%eax
  80193d:	8b 00                	mov    (%eax),%eax
  80193f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801942:	99                   	cltd   
  801943:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801946:	8b 45 14             	mov    0x14(%ebp),%eax
  801949:	8d 40 04             	lea    0x4(%eax),%eax
  80194c:	89 45 14             	mov    %eax,0x14(%ebp)
  80194f:	eb 17                	jmp    801968 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  801951:	8b 45 14             	mov    0x14(%ebp),%eax
  801954:	8b 50 04             	mov    0x4(%eax),%edx
  801957:	8b 00                	mov    (%eax),%eax
  801959:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195f:	8b 45 14             	mov    0x14(%ebp),%eax
  801962:	8d 40 08             	lea    0x8(%eax),%eax
  801965:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801968:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80196b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80196e:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801973:	85 c9                	test   %ecx,%ecx
  801975:	0f 89 ff 00 00 00    	jns    801a7a <vprintfmt+0x38c>
				putch('-', putdat);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	53                   	push   %ebx
  80197f:	6a 2d                	push   $0x2d
  801981:	ff d6                	call   *%esi
				num = -(long long) num;
  801983:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801986:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801989:	f7 da                	neg    %edx
  80198b:	83 d1 00             	adc    $0x0,%ecx
  80198e:	f7 d9                	neg    %ecx
  801990:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801993:	b8 0a 00 00 00       	mov    $0xa,%eax
  801998:	e9 dd 00 00 00       	jmp    801a7a <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80199d:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a0:	8b 00                	mov    (%eax),%eax
  8019a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a5:	99                   	cltd   
  8019a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ac:	8d 40 04             	lea    0x4(%eax),%eax
  8019af:	89 45 14             	mov    %eax,0x14(%ebp)
  8019b2:	eb b4                	jmp    801968 <vprintfmt+0x27a>
	if (lflag >= 2)
  8019b4:	83 f9 01             	cmp    $0x1,%ecx
  8019b7:	7f 1e                	jg     8019d7 <vprintfmt+0x2e9>
	else if (lflag)
  8019b9:	85 c9                	test   %ecx,%ecx
  8019bb:	74 32                	je     8019ef <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c0:	8b 10                	mov    (%eax),%edx
  8019c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c7:	8d 40 04             	lea    0x4(%eax),%eax
  8019ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019cd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019d2:	e9 a3 00 00 00       	jmp    801a7a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019da:	8b 10                	mov    (%eax),%edx
  8019dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8019df:	8d 40 08             	lea    0x8(%eax),%eax
  8019e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019e5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8019ea:	e9 8b 00 00 00       	jmp    801a7a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8019ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f2:	8b 10                	mov    (%eax),%edx
  8019f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f9:	8d 40 04             	lea    0x4(%eax),%eax
  8019fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019ff:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801a04:	eb 74                	jmp    801a7a <vprintfmt+0x38c>
	if (lflag >= 2)
  801a06:	83 f9 01             	cmp    $0x1,%ecx
  801a09:	7f 1b                	jg     801a26 <vprintfmt+0x338>
	else if (lflag)
  801a0b:	85 c9                	test   %ecx,%ecx
  801a0d:	74 2c                	je     801a3b <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801a0f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a12:	8b 10                	mov    (%eax),%edx
  801a14:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a19:	8d 40 04             	lea    0x4(%eax),%eax
  801a1c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a1f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a24:	eb 54                	jmp    801a7a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a26:	8b 45 14             	mov    0x14(%ebp),%eax
  801a29:	8b 10                	mov    (%eax),%edx
  801a2b:	8b 48 04             	mov    0x4(%eax),%ecx
  801a2e:	8d 40 08             	lea    0x8(%eax),%eax
  801a31:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a34:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a39:	eb 3f                	jmp    801a7a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3e:	8b 10                	mov    (%eax),%edx
  801a40:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a45:	8d 40 04             	lea    0x4(%eax),%eax
  801a48:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a4b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a50:	eb 28                	jmp    801a7a <vprintfmt+0x38c>
			putch('0', putdat);
  801a52:	83 ec 08             	sub    $0x8,%esp
  801a55:	53                   	push   %ebx
  801a56:	6a 30                	push   $0x30
  801a58:	ff d6                	call   *%esi
			putch('x', putdat);
  801a5a:	83 c4 08             	add    $0x8,%esp
  801a5d:	53                   	push   %ebx
  801a5e:	6a 78                	push   $0x78
  801a60:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a62:	8b 45 14             	mov    0x14(%ebp),%eax
  801a65:	8b 10                	mov    (%eax),%edx
  801a67:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a6c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a6f:	8d 40 04             	lea    0x4(%eax),%eax
  801a72:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a75:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a81:	57                   	push   %edi
  801a82:	ff 75 e0             	pushl  -0x20(%ebp)
  801a85:	50                   	push   %eax
  801a86:	51                   	push   %ecx
  801a87:	52                   	push   %edx
  801a88:	89 da                	mov    %ebx,%edx
  801a8a:	89 f0                	mov    %esi,%eax
  801a8c:	e8 72 fb ff ff       	call   801603 <printnum>
			break;
  801a91:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801a94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801a97:	83 c7 01             	add    $0x1,%edi
  801a9a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a9e:	83 f8 25             	cmp    $0x25,%eax
  801aa1:	0f 84 62 fc ff ff    	je     801709 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	0f 84 8b 00 00 00    	je     801b3a <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801aaf:	83 ec 08             	sub    $0x8,%esp
  801ab2:	53                   	push   %ebx
  801ab3:	50                   	push   %eax
  801ab4:	ff d6                	call   *%esi
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	eb dc                	jmp    801a97 <vprintfmt+0x3a9>
	if (lflag >= 2)
  801abb:	83 f9 01             	cmp    $0x1,%ecx
  801abe:	7f 1b                	jg     801adb <vprintfmt+0x3ed>
	else if (lflag)
  801ac0:	85 c9                	test   %ecx,%ecx
  801ac2:	74 2c                	je     801af0 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801ac4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac7:	8b 10                	mov    (%eax),%edx
  801ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ace:	8d 40 04             	lea    0x4(%eax),%eax
  801ad1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ad4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801ad9:	eb 9f                	jmp    801a7a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801adb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ade:	8b 10                	mov    (%eax),%edx
  801ae0:	8b 48 04             	mov    0x4(%eax),%ecx
  801ae3:	8d 40 08             	lea    0x8(%eax),%eax
  801ae6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ae9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801aee:	eb 8a                	jmp    801a7a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801af0:	8b 45 14             	mov    0x14(%ebp),%eax
  801af3:	8b 10                	mov    (%eax),%edx
  801af5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801afa:	8d 40 04             	lea    0x4(%eax),%eax
  801afd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b00:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801b05:	e9 70 ff ff ff       	jmp    801a7a <vprintfmt+0x38c>
			putch(ch, putdat);
  801b0a:	83 ec 08             	sub    $0x8,%esp
  801b0d:	53                   	push   %ebx
  801b0e:	6a 25                	push   $0x25
  801b10:	ff d6                	call   *%esi
			break;
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	e9 7a ff ff ff       	jmp    801a94 <vprintfmt+0x3a6>
			putch('%', putdat);
  801b1a:	83 ec 08             	sub    $0x8,%esp
  801b1d:	53                   	push   %ebx
  801b1e:	6a 25                	push   $0x25
  801b20:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	89 f8                	mov    %edi,%eax
  801b27:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b2b:	74 05                	je     801b32 <vprintfmt+0x444>
  801b2d:	83 e8 01             	sub    $0x1,%eax
  801b30:	eb f5                	jmp    801b27 <vprintfmt+0x439>
  801b32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b35:	e9 5a ff ff ff       	jmp    801a94 <vprintfmt+0x3a6>
}
  801b3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5f                   	pop    %edi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b42:	f3 0f 1e fb          	endbr32 
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 18             	sub    $0x18,%esp
  801b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b55:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b59:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b63:	85 c0                	test   %eax,%eax
  801b65:	74 26                	je     801b8d <vsnprintf+0x4b>
  801b67:	85 d2                	test   %edx,%edx
  801b69:	7e 22                	jle    801b8d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b6b:	ff 75 14             	pushl  0x14(%ebp)
  801b6e:	ff 75 10             	pushl  0x10(%ebp)
  801b71:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b74:	50                   	push   %eax
  801b75:	68 ac 16 80 00       	push   $0x8016ac
  801b7a:	e8 6f fb ff ff       	call   8016ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b82:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b88:	83 c4 10             	add    $0x10,%esp
}
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    
		return -E_INVAL;
  801b8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b92:	eb f7                	jmp    801b8b <vsnprintf+0x49>

00801b94 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b94:	f3 0f 1e fb          	endbr32 
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801b9e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ba1:	50                   	push   %eax
  801ba2:	ff 75 10             	pushl  0x10(%ebp)
  801ba5:	ff 75 0c             	pushl  0xc(%ebp)
  801ba8:	ff 75 08             	pushl  0x8(%ebp)
  801bab:	e8 92 ff ff ff       	call   801b42 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bb2:	f3 0f 1e fb          	endbr32 
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bc5:	74 05                	je     801bcc <strlen+0x1a>
		n++;
  801bc7:	83 c0 01             	add    $0x1,%eax
  801bca:	eb f5                	jmp    801bc1 <strlen+0xf>
	return n;
}
  801bcc:	5d                   	pop    %ebp
  801bcd:	c3                   	ret    

00801bce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bce:	f3 0f 1e fb          	endbr32 
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801be0:	39 d0                	cmp    %edx,%eax
  801be2:	74 0d                	je     801bf1 <strnlen+0x23>
  801be4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801be8:	74 05                	je     801bef <strnlen+0x21>
		n++;
  801bea:	83 c0 01             	add    $0x1,%eax
  801bed:	eb f1                	jmp    801be0 <strnlen+0x12>
  801bef:	89 c2                	mov    %eax,%edx
	return n;
}
  801bf1:	89 d0                	mov    %edx,%eax
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bf5:	f3 0f 1e fb          	endbr32 
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	53                   	push   %ebx
  801bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
  801c08:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801c0c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801c0f:	83 c0 01             	add    $0x1,%eax
  801c12:	84 d2                	test   %dl,%dl
  801c14:	75 f2                	jne    801c08 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c16:	89 c8                	mov    %ecx,%eax
  801c18:	5b                   	pop    %ebx
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c1b:	f3 0f 1e fb          	endbr32 
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	53                   	push   %ebx
  801c23:	83 ec 10             	sub    $0x10,%esp
  801c26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c29:	53                   	push   %ebx
  801c2a:	e8 83 ff ff ff       	call   801bb2 <strlen>
  801c2f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c32:	ff 75 0c             	pushl  0xc(%ebp)
  801c35:	01 d8                	add    %ebx,%eax
  801c37:	50                   	push   %eax
  801c38:	e8 b8 ff ff ff       	call   801bf5 <strcpy>
	return dst;
}
  801c3d:	89 d8                	mov    %ebx,%eax
  801c3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c44:	f3 0f 1e fb          	endbr32 
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c50:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c53:	89 f3                	mov    %esi,%ebx
  801c55:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c58:	89 f0                	mov    %esi,%eax
  801c5a:	39 d8                	cmp    %ebx,%eax
  801c5c:	74 11                	je     801c6f <strncpy+0x2b>
		*dst++ = *src;
  801c5e:	83 c0 01             	add    $0x1,%eax
  801c61:	0f b6 0a             	movzbl (%edx),%ecx
  801c64:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c67:	80 f9 01             	cmp    $0x1,%cl
  801c6a:	83 da ff             	sbb    $0xffffffff,%edx
  801c6d:	eb eb                	jmp    801c5a <strncpy+0x16>
	}
	return ret;
}
  801c6f:	89 f0                	mov    %esi,%eax
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c75:	f3 0f 1e fb          	endbr32 
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c84:	8b 55 10             	mov    0x10(%ebp),%edx
  801c87:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c89:	85 d2                	test   %edx,%edx
  801c8b:	74 21                	je     801cae <strlcpy+0x39>
  801c8d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c91:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801c93:	39 c2                	cmp    %eax,%edx
  801c95:	74 14                	je     801cab <strlcpy+0x36>
  801c97:	0f b6 19             	movzbl (%ecx),%ebx
  801c9a:	84 db                	test   %bl,%bl
  801c9c:	74 0b                	je     801ca9 <strlcpy+0x34>
			*dst++ = *src++;
  801c9e:	83 c1 01             	add    $0x1,%ecx
  801ca1:	83 c2 01             	add    $0x1,%edx
  801ca4:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ca7:	eb ea                	jmp    801c93 <strlcpy+0x1e>
  801ca9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801cab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cae:	29 f0                	sub    %esi,%eax
}
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cb4:	f3 0f 1e fb          	endbr32 
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cc1:	0f b6 01             	movzbl (%ecx),%eax
  801cc4:	84 c0                	test   %al,%al
  801cc6:	74 0c                	je     801cd4 <strcmp+0x20>
  801cc8:	3a 02                	cmp    (%edx),%al
  801cca:	75 08                	jne    801cd4 <strcmp+0x20>
		p++, q++;
  801ccc:	83 c1 01             	add    $0x1,%ecx
  801ccf:	83 c2 01             	add    $0x1,%edx
  801cd2:	eb ed                	jmp    801cc1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd4:	0f b6 c0             	movzbl %al,%eax
  801cd7:	0f b6 12             	movzbl (%edx),%edx
  801cda:	29 d0                	sub    %edx,%eax
}
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cde:	f3 0f 1e fb          	endbr32 
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	53                   	push   %ebx
  801ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cf1:	eb 06                	jmp    801cf9 <strncmp+0x1b>
		n--, p++, q++;
  801cf3:	83 c0 01             	add    $0x1,%eax
  801cf6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801cf9:	39 d8                	cmp    %ebx,%eax
  801cfb:	74 16                	je     801d13 <strncmp+0x35>
  801cfd:	0f b6 08             	movzbl (%eax),%ecx
  801d00:	84 c9                	test   %cl,%cl
  801d02:	74 04                	je     801d08 <strncmp+0x2a>
  801d04:	3a 0a                	cmp    (%edx),%cl
  801d06:	74 eb                	je     801cf3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d08:	0f b6 00             	movzbl (%eax),%eax
  801d0b:	0f b6 12             	movzbl (%edx),%edx
  801d0e:	29 d0                	sub    %edx,%eax
}
  801d10:	5b                   	pop    %ebx
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    
		return 0;
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
  801d18:	eb f6                	jmp    801d10 <strncmp+0x32>

00801d1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d1a:	f3 0f 1e fb          	endbr32 
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d28:	0f b6 10             	movzbl (%eax),%edx
  801d2b:	84 d2                	test   %dl,%dl
  801d2d:	74 09                	je     801d38 <strchr+0x1e>
		if (*s == c)
  801d2f:	38 ca                	cmp    %cl,%dl
  801d31:	74 0a                	je     801d3d <strchr+0x23>
	for (; *s; s++)
  801d33:	83 c0 01             	add    $0x1,%eax
  801d36:	eb f0                	jmp    801d28 <strchr+0xe>
			return (char *) s;
	return 0;
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    

00801d3f <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d3f:	f3 0f 1e fb          	endbr32 
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d49:	6a 78                	push   $0x78
  801d4b:	ff 75 08             	pushl  0x8(%ebp)
  801d4e:	e8 c7 ff ff ff       	call   801d1a <strchr>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d5e:	eb 0d                	jmp    801d6d <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d60:	c1 e0 04             	shl    $0x4,%eax
  801d63:	0f be d2             	movsbl %dl,%edx
  801d66:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d6a:	83 c1 01             	add    $0x1,%ecx
  801d6d:	0f b6 11             	movzbl (%ecx),%edx
  801d70:	84 d2                	test   %dl,%dl
  801d72:	74 11                	je     801d85 <atox+0x46>
		if (*p>='a'){
  801d74:	80 fa 60             	cmp    $0x60,%dl
  801d77:	7e e7                	jle    801d60 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d79:	c1 e0 04             	shl    $0x4,%eax
  801d7c:	0f be d2             	movsbl %dl,%edx
  801d7f:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d83:	eb e5                	jmp    801d6a <atox+0x2b>
	}

	return v;

}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d87:	f3 0f 1e fb          	endbr32 
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d98:	38 ca                	cmp    %cl,%dl
  801d9a:	74 09                	je     801da5 <strfind+0x1e>
  801d9c:	84 d2                	test   %dl,%dl
  801d9e:	74 05                	je     801da5 <strfind+0x1e>
	for (; *s; s++)
  801da0:	83 c0 01             	add    $0x1,%eax
  801da3:	eb f0                	jmp    801d95 <strfind+0xe>
			break;
	return (char *) s;
}
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801da7:	f3 0f 1e fb          	endbr32 
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	57                   	push   %edi
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801db4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801db7:	85 c9                	test   %ecx,%ecx
  801db9:	74 31                	je     801dec <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801dbb:	89 f8                	mov    %edi,%eax
  801dbd:	09 c8                	or     %ecx,%eax
  801dbf:	a8 03                	test   $0x3,%al
  801dc1:	75 23                	jne    801de6 <memset+0x3f>
		c &= 0xFF;
  801dc3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801dc7:	89 d3                	mov    %edx,%ebx
  801dc9:	c1 e3 08             	shl    $0x8,%ebx
  801dcc:	89 d0                	mov    %edx,%eax
  801dce:	c1 e0 18             	shl    $0x18,%eax
  801dd1:	89 d6                	mov    %edx,%esi
  801dd3:	c1 e6 10             	shl    $0x10,%esi
  801dd6:	09 f0                	or     %esi,%eax
  801dd8:	09 c2                	or     %eax,%edx
  801dda:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ddc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801ddf:	89 d0                	mov    %edx,%eax
  801de1:	fc                   	cld    
  801de2:	f3 ab                	rep stos %eax,%es:(%edi)
  801de4:	eb 06                	jmp    801dec <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de9:	fc                   	cld    
  801dea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dec:	89 f8                	mov    %edi,%eax
  801dee:	5b                   	pop    %ebx
  801def:	5e                   	pop    %esi
  801df0:	5f                   	pop    %edi
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    

00801df3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801df3:	f3 0f 1e fb          	endbr32 
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	57                   	push   %edi
  801dfb:	56                   	push   %esi
  801dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dff:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e05:	39 c6                	cmp    %eax,%esi
  801e07:	73 32                	jae    801e3b <memmove+0x48>
  801e09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e0c:	39 c2                	cmp    %eax,%edx
  801e0e:	76 2b                	jbe    801e3b <memmove+0x48>
		s += n;
		d += n;
  801e10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e13:	89 fe                	mov    %edi,%esi
  801e15:	09 ce                	or     %ecx,%esi
  801e17:	09 d6                	or     %edx,%esi
  801e19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e1f:	75 0e                	jne    801e2f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e21:	83 ef 04             	sub    $0x4,%edi
  801e24:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e2a:	fd                   	std    
  801e2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e2d:	eb 09                	jmp    801e38 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e2f:	83 ef 01             	sub    $0x1,%edi
  801e32:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e35:	fd                   	std    
  801e36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e38:	fc                   	cld    
  801e39:	eb 1a                	jmp    801e55 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e3b:	89 c2                	mov    %eax,%edx
  801e3d:	09 ca                	or     %ecx,%edx
  801e3f:	09 f2                	or     %esi,%edx
  801e41:	f6 c2 03             	test   $0x3,%dl
  801e44:	75 0a                	jne    801e50 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e46:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e49:	89 c7                	mov    %eax,%edi
  801e4b:	fc                   	cld    
  801e4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e4e:	eb 05                	jmp    801e55 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e50:	89 c7                	mov    %eax,%edi
  801e52:	fc                   	cld    
  801e53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e55:	5e                   	pop    %esi
  801e56:	5f                   	pop    %edi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e59:	f3 0f 1e fb          	endbr32 
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e63:	ff 75 10             	pushl  0x10(%ebp)
  801e66:	ff 75 0c             	pushl  0xc(%ebp)
  801e69:	ff 75 08             	pushl  0x8(%ebp)
  801e6c:	e8 82 ff ff ff       	call   801df3 <memmove>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e73:	f3 0f 1e fb          	endbr32 
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	56                   	push   %esi
  801e7b:	53                   	push   %ebx
  801e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e82:	89 c6                	mov    %eax,%esi
  801e84:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e87:	39 f0                	cmp    %esi,%eax
  801e89:	74 1c                	je     801ea7 <memcmp+0x34>
		if (*s1 != *s2)
  801e8b:	0f b6 08             	movzbl (%eax),%ecx
  801e8e:	0f b6 1a             	movzbl (%edx),%ebx
  801e91:	38 d9                	cmp    %bl,%cl
  801e93:	75 08                	jne    801e9d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801e95:	83 c0 01             	add    $0x1,%eax
  801e98:	83 c2 01             	add    $0x1,%edx
  801e9b:	eb ea                	jmp    801e87 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801e9d:	0f b6 c1             	movzbl %cl,%eax
  801ea0:	0f b6 db             	movzbl %bl,%ebx
  801ea3:	29 d8                	sub    %ebx,%eax
  801ea5:	eb 05                	jmp    801eac <memcmp+0x39>
	}

	return 0;
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eac:	5b                   	pop    %ebx
  801ead:	5e                   	pop    %esi
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    

00801eb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801eb0:	f3 0f 1e fb          	endbr32 
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ebd:	89 c2                	mov    %eax,%edx
  801ebf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ec2:	39 d0                	cmp    %edx,%eax
  801ec4:	73 09                	jae    801ecf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ec6:	38 08                	cmp    %cl,(%eax)
  801ec8:	74 05                	je     801ecf <memfind+0x1f>
	for (; s < ends; s++)
  801eca:	83 c0 01             	add    $0x1,%eax
  801ecd:	eb f3                	jmp    801ec2 <memfind+0x12>
			break;
	return (void *) s;
}
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ed1:	f3 0f 1e fb          	endbr32 
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	57                   	push   %edi
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ede:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ee1:	eb 03                	jmp    801ee6 <strtol+0x15>
		s++;
  801ee3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801ee6:	0f b6 01             	movzbl (%ecx),%eax
  801ee9:	3c 20                	cmp    $0x20,%al
  801eeb:	74 f6                	je     801ee3 <strtol+0x12>
  801eed:	3c 09                	cmp    $0x9,%al
  801eef:	74 f2                	je     801ee3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801ef1:	3c 2b                	cmp    $0x2b,%al
  801ef3:	74 2a                	je     801f1f <strtol+0x4e>
	int neg = 0;
  801ef5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801efa:	3c 2d                	cmp    $0x2d,%al
  801efc:	74 2b                	je     801f29 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801efe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f04:	75 0f                	jne    801f15 <strtol+0x44>
  801f06:	80 39 30             	cmpb   $0x30,(%ecx)
  801f09:	74 28                	je     801f33 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f0b:	85 db                	test   %ebx,%ebx
  801f0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f12:	0f 44 d8             	cmove  %eax,%ebx
  801f15:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f1d:	eb 46                	jmp    801f65 <strtol+0x94>
		s++;
  801f1f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f22:	bf 00 00 00 00       	mov    $0x0,%edi
  801f27:	eb d5                	jmp    801efe <strtol+0x2d>
		s++, neg = 1;
  801f29:	83 c1 01             	add    $0x1,%ecx
  801f2c:	bf 01 00 00 00       	mov    $0x1,%edi
  801f31:	eb cb                	jmp    801efe <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f37:	74 0e                	je     801f47 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f39:	85 db                	test   %ebx,%ebx
  801f3b:	75 d8                	jne    801f15 <strtol+0x44>
		s++, base = 8;
  801f3d:	83 c1 01             	add    $0x1,%ecx
  801f40:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f45:	eb ce                	jmp    801f15 <strtol+0x44>
		s += 2, base = 16;
  801f47:	83 c1 02             	add    $0x2,%ecx
  801f4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f4f:	eb c4                	jmp    801f15 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f51:	0f be d2             	movsbl %dl,%edx
  801f54:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f57:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f5a:	7d 3a                	jge    801f96 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f5c:	83 c1 01             	add    $0x1,%ecx
  801f5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f63:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f65:	0f b6 11             	movzbl (%ecx),%edx
  801f68:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f6b:	89 f3                	mov    %esi,%ebx
  801f6d:	80 fb 09             	cmp    $0x9,%bl
  801f70:	76 df                	jbe    801f51 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f72:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f75:	89 f3                	mov    %esi,%ebx
  801f77:	80 fb 19             	cmp    $0x19,%bl
  801f7a:	77 08                	ja     801f84 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f7c:	0f be d2             	movsbl %dl,%edx
  801f7f:	83 ea 57             	sub    $0x57,%edx
  801f82:	eb d3                	jmp    801f57 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f84:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f87:	89 f3                	mov    %esi,%ebx
  801f89:	80 fb 19             	cmp    $0x19,%bl
  801f8c:	77 08                	ja     801f96 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f8e:	0f be d2             	movsbl %dl,%edx
  801f91:	83 ea 37             	sub    $0x37,%edx
  801f94:	eb c1                	jmp    801f57 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801f96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f9a:	74 05                	je     801fa1 <strtol+0xd0>
		*endptr = (char *) s;
  801f9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f9f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801fa1:	89 c2                	mov    %eax,%edx
  801fa3:	f7 da                	neg    %edx
  801fa5:	85 ff                	test   %edi,%edi
  801fa7:	0f 45 c2             	cmovne %edx,%eax
}
  801faa:	5b                   	pop    %ebx
  801fab:	5e                   	pop    %esi
  801fac:	5f                   	pop    %edi
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801faf:	f3 0f 1e fb          	endbr32 
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	56                   	push   %esi
  801fb7:	53                   	push   %ebx
  801fb8:	8b 75 08             	mov    0x8(%ebp),%esi
  801fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fc8:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	50                   	push   %eax
  801fcf:	e8 97 e2 ff ff       	call   80026b <sys_ipc_recv>
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	75 2b                	jne    802006 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fdb:	85 f6                	test   %esi,%esi
  801fdd:	74 0a                	je     801fe9 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fdf:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe4:	8b 40 74             	mov    0x74(%eax),%eax
  801fe7:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fe9:	85 db                	test   %ebx,%ebx
  801feb:	74 0a                	je     801ff7 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801fed:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff2:	8b 40 78             	mov    0x78(%eax),%eax
  801ff5:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801ff7:	a1 08 40 80 00       	mov    0x804008,%eax
  801ffc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802002:	5b                   	pop    %ebx
  802003:	5e                   	pop    %esi
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802006:	85 f6                	test   %esi,%esi
  802008:	74 06                	je     802010 <ipc_recv+0x61>
  80200a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802010:	85 db                	test   %ebx,%ebx
  802012:	74 eb                	je     801fff <ipc_recv+0x50>
  802014:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80201a:	eb e3                	jmp    801fff <ipc_recv+0x50>

0080201c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80201c:	f3 0f 1e fb          	endbr32 
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	53                   	push   %ebx
  802026:	83 ec 0c             	sub    $0xc,%esp
  802029:	8b 7d 08             	mov    0x8(%ebp),%edi
  80202c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80202f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802032:	85 db                	test   %ebx,%ebx
  802034:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802039:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80203c:	ff 75 14             	pushl  0x14(%ebp)
  80203f:	53                   	push   %ebx
  802040:	56                   	push   %esi
  802041:	57                   	push   %edi
  802042:	e8 fd e1 ff ff       	call   800244 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80204d:	75 07                	jne    802056 <ipc_send+0x3a>
			sys_yield();
  80204f:	e8 ee e0 ff ff       	call   800142 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802054:	eb e6                	jmp    80203c <ipc_send+0x20>
		}
		else if (ret == 0)
  802056:	85 c0                	test   %eax,%eax
  802058:	75 08                	jne    802062 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80205a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802062:	50                   	push   %eax
  802063:	68 1f 28 80 00       	push   $0x80281f
  802068:	6a 48                	push   $0x48
  80206a:	68 2d 28 80 00       	push   $0x80282d
  80206f:	e8 90 f4 ff ff       	call   801504 <_panic>

00802074 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802074:	f3 0f 1e fb          	endbr32 
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80207e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802083:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802086:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80208c:	8b 52 50             	mov    0x50(%edx),%edx
  80208f:	39 ca                	cmp    %ecx,%edx
  802091:	74 11                	je     8020a4 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802093:	83 c0 01             	add    $0x1,%eax
  802096:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209b:	75 e6                	jne    802083 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80209d:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a2:	eb 0b                	jmp    8020af <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020ac:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    

008020b1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b1:	f3 0f 1e fb          	endbr32 
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020bb:	89 c2                	mov    %eax,%edx
  8020bd:	c1 ea 16             	shr    $0x16,%edx
  8020c0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020c7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020cc:	f6 c1 01             	test   $0x1,%cl
  8020cf:	74 1c                	je     8020ed <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020d1:	c1 e8 0c             	shr    $0xc,%eax
  8020d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020db:	a8 01                	test   $0x1,%al
  8020dd:	74 0e                	je     8020ed <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020df:	c1 e8 0c             	shr    $0xc,%eax
  8020e2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020e9:	ef 
  8020ea:	0f b7 d2             	movzwl %dx,%edx
}
  8020ed:	89 d0                	mov    %edx,%eax
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    
  8020f1:	66 90                	xchg   %ax,%ax
  8020f3:	66 90                	xchg   %ax,%ax
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
