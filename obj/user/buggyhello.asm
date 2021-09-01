
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 1a 00 00 00       	call   80004b <libmain>
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
	sys_cputs((char*)1, 1);
  80003d:	6a 01                	push   $0x1
  80003f:	6a 01                	push   $0x1
  800041:	e8 6d 00 00 00       	call   8000b3 <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    

0080004b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004b:	f3 0f 1e fb          	endbr32 
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005a:	e8 bd 00 00 00       	call   80011c <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006c:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 db                	test   %ebx,%ebx
  800073:	7e 07                	jle    80007c <libmain+0x31>
		binaryname = argv[0];
  800075:	8b 06                	mov    (%esi),%eax
  800077:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	e8 ad ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800086:	e8 0a 00 00 00       	call   800095 <exit>
}
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    

00800095 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80009f:	e8 49 04 00 00       	call   8004ed <close_all>
	sys_env_destroy(0);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	6a 00                	push   $0x0
  8000a9:	e8 4a 00 00 00       	call   8000f8 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b3:	f3 0f 1e fb          	endbr32 
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c8:	89 c3                	mov    %eax,%ebx
  8000ca:	89 c7                	mov    %eax,%edi
  8000cc:	89 c6                	mov    %eax,%esi
  8000ce:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d5:	f3 0f 1e fb          	endbr32 
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000df:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e9:	89 d1                	mov    %edx,%ecx
  8000eb:	89 d3                	mov    %edx,%ebx
  8000ed:	89 d7                	mov    %edx,%edi
  8000ef:	89 d6                	mov    %edx,%esi
  8000f1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f8:	f3 0f 1e fb          	endbr32 
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	8b 55 08             	mov    0x8(%ebp),%edx
  80010a:	b8 03 00 00 00       	mov    $0x3,%eax
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	f3 0f 1e fb          	endbr32 
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	f3 0f 1e fb          	endbr32 
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	f3 0f 1e fb          	endbr32 
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800177:	b8 04 00 00 00       	mov    $0x4,%eax
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	5f                   	pop    %edi
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800188:	f3 0f 1e fb          	endbr32 
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
	asm volatile("int %1\n"
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800198:	b8 05 00 00 00       	mov    $0x5,%eax
  80019d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001a6:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ad:	f3 0f 1e fb          	endbr32 
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	57                   	push   %edi
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8001c7:	89 df                	mov    %ebx,%edi
  8001c9:	89 de                	mov    %ebx,%esi
  8001cb:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001d2:	f3 0f 1e fb          	endbr32 
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001f7:	f3 0f 1e fb          	endbr32 
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	57                   	push   %edi
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
	asm volatile("int %1\n"
  800201:	bb 00 00 00 00       	mov    $0x0,%ebx
  800206:	8b 55 08             	mov    0x8(%ebp),%edx
  800209:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020c:	b8 09 00 00 00       	mov    $0x9,%eax
  800211:	89 df                	mov    %ebx,%edi
  800213:	89 de                	mov    %ebx,%esi
  800215:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80021c:	f3 0f 1e fb          	endbr32 
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	b8 0a 00 00 00       	mov    $0xa,%eax
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5f                   	pop    %edi
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800241:	f3 0f 1e fb          	endbr32 
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800251:	b8 0c 00 00 00       	mov    $0xc,%eax
  800256:	be 00 00 00 00       	mov    $0x0,%esi
  80025b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80025e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800261:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800268:	f3 0f 1e fb          	endbr32 
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
	asm volatile("int %1\n"
  800272:	b9 00 00 00 00       	mov    $0x0,%ecx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80027f:	89 cb                	mov    %ecx,%ebx
  800281:	89 cf                	mov    %ecx,%edi
  800283:	89 ce                	mov    %ecx,%esi
  800285:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800287:	5b                   	pop    %ebx
  800288:	5e                   	pop    %esi
  800289:	5f                   	pop    %edi
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80028c:	f3 0f 1e fb          	endbr32 
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
	asm volatile("int %1\n"
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
  80029b:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002a0:	89 d1                	mov    %edx,%ecx
  8002a2:	89 d3                	mov    %edx,%ebx
  8002a4:	89 d7                	mov    %edx,%edi
  8002a6:	89 d6                	mov    %edx,%esi
  8002a8:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  8002af:	f3 0f 1e fb          	endbr32 
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002be:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	b8 0f 00 00 00       	mov    $0xf,%eax
  8002c9:	89 df                	mov    %ebx,%edi
  8002cb:	89 de                	mov    %ebx,%esi
  8002cd:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  8002d4:	f3 0f 1e fb          	endbr32 
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e9:	b8 10 00 00 00       	mov    $0x10,%eax
  8002ee:	89 df                	mov    %ebx,%edi
  8002f0:	89 de                	mov    %ebx,%esi
  8002f2:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f9:	f3 0f 1e fb          	endbr32 
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800300:	8b 45 08             	mov    0x8(%ebp),%eax
  800303:	05 00 00 00 30       	add    $0x30000000,%eax
  800308:	c1 e8 0c             	shr    $0xc,%eax
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030d:	f3 0f 1e fb          	endbr32 
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800314:	8b 45 08             	mov    0x8(%ebp),%eax
  800317:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80031c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800321:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800328:	f3 0f 1e fb          	endbr32 
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800334:	89 c2                	mov    %eax,%edx
  800336:	c1 ea 16             	shr    $0x16,%edx
  800339:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800340:	f6 c2 01             	test   $0x1,%dl
  800343:	74 2d                	je     800372 <fd_alloc+0x4a>
  800345:	89 c2                	mov    %eax,%edx
  800347:	c1 ea 0c             	shr    $0xc,%edx
  80034a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800351:	f6 c2 01             	test   $0x1,%dl
  800354:	74 1c                	je     800372 <fd_alloc+0x4a>
  800356:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80035b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800360:	75 d2                	jne    800334 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80036b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800370:	eb 0a                	jmp    80037c <fd_alloc+0x54>
			*fd_store = fd;
  800372:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800375:	89 01                	mov    %eax,(%ecx)
			return 0;
  800377:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80037e:	f3 0f 1e fb          	endbr32 
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800388:	83 f8 1f             	cmp    $0x1f,%eax
  80038b:	77 30                	ja     8003bd <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80038d:	c1 e0 0c             	shl    $0xc,%eax
  800390:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800395:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80039b:	f6 c2 01             	test   $0x1,%dl
  80039e:	74 24                	je     8003c4 <fd_lookup+0x46>
  8003a0:	89 c2                	mov    %eax,%edx
  8003a2:	c1 ea 0c             	shr    $0xc,%edx
  8003a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ac:	f6 c2 01             	test   $0x1,%dl
  8003af:	74 1a                	je     8003cb <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    
		return -E_INVAL;
  8003bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c2:	eb f7                	jmp    8003bb <fd_lookup+0x3d>
		return -E_INVAL;
  8003c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c9:	eb f0                	jmp    8003bb <fd_lookup+0x3d>
  8003cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d0:	eb e9                	jmp    8003bb <fd_lookup+0x3d>

008003d2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d2:	f3 0f 1e fb          	endbr32 
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e4:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003e9:	39 08                	cmp    %ecx,(%eax)
  8003eb:	74 38                	je     800425 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8003ed:	83 c2 01             	add    $0x1,%edx
  8003f0:	8b 04 95 e8 23 80 00 	mov    0x8023e8(,%edx,4),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	75 ee                	jne    8003e9 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003fb:	a1 08 40 80 00       	mov    0x804008,%eax
  800400:	8b 40 48             	mov    0x48(%eax),%eax
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	51                   	push   %ecx
  800407:	50                   	push   %eax
  800408:	68 6c 23 80 00       	push   $0x80236c
  80040d:	e8 d6 11 00 00       	call   8015e8 <cprintf>
	*dev = 0;
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
  800415:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800423:	c9                   	leave  
  800424:	c3                   	ret    
			*dev = devtab[i];
  800425:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800428:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb f2                	jmp    800423 <dev_lookup+0x51>

00800431 <fd_close>:
{
  800431:	f3 0f 1e fb          	endbr32 
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	57                   	push   %edi
  800439:	56                   	push   %esi
  80043a:	53                   	push   %ebx
  80043b:	83 ec 24             	sub    $0x24,%esp
  80043e:	8b 75 08             	mov    0x8(%ebp),%esi
  800441:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800444:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800447:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800448:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80044e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800451:	50                   	push   %eax
  800452:	e8 27 ff ff ff       	call   80037e <fd_lookup>
  800457:	89 c3                	mov    %eax,%ebx
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	78 05                	js     800465 <fd_close+0x34>
	    || fd != fd2)
  800460:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800463:	74 16                	je     80047b <fd_close+0x4a>
		return (must_exist ? r : 0);
  800465:	89 f8                	mov    %edi,%eax
  800467:	84 c0                	test   %al,%al
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	0f 44 d8             	cmove  %eax,%ebx
}
  800471:	89 d8                	mov    %ebx,%eax
  800473:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800476:	5b                   	pop    %ebx
  800477:	5e                   	pop    %esi
  800478:	5f                   	pop    %edi
  800479:	5d                   	pop    %ebp
  80047a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	ff 36                	pushl  (%esi)
  800484:	e8 49 ff ff ff       	call   8003d2 <dev_lookup>
  800489:	89 c3                	mov    %eax,%ebx
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 1a                	js     8004ac <fd_close+0x7b>
		if (dev->dev_close)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800498:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80049d:	85 c0                	test   %eax,%eax
  80049f:	74 0b                	je     8004ac <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	56                   	push   %esi
  8004a5:	ff d0                	call   *%eax
  8004a7:	89 c3                	mov    %eax,%ebx
  8004a9:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	56                   	push   %esi
  8004b0:	6a 00                	push   $0x0
  8004b2:	e8 f6 fc ff ff       	call   8001ad <sys_page_unmap>
	return r;
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	eb b5                	jmp    800471 <fd_close+0x40>

008004bc <close>:

int
close(int fdnum)
{
  8004bc:	f3 0f 1e fb          	endbr32 
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c9:	50                   	push   %eax
  8004ca:	ff 75 08             	pushl  0x8(%ebp)
  8004cd:	e8 ac fe ff ff       	call   80037e <fd_lookup>
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	79 02                	jns    8004db <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004d9:	c9                   	leave  
  8004da:	c3                   	ret    
		return fd_close(fd, 1);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	6a 01                	push   $0x1
  8004e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e3:	e8 49 ff ff ff       	call   800431 <fd_close>
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	eb ec                	jmp    8004d9 <close+0x1d>

008004ed <close_all>:

void
close_all(void)
{
  8004ed:	f3 0f 1e fb          	endbr32 
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	53                   	push   %ebx
  8004f5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004fd:	83 ec 0c             	sub    $0xc,%esp
  800500:	53                   	push   %ebx
  800501:	e8 b6 ff ff ff       	call   8004bc <close>
	for (i = 0; i < MAXFD; i++)
  800506:	83 c3 01             	add    $0x1,%ebx
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	83 fb 20             	cmp    $0x20,%ebx
  80050f:	75 ec                	jne    8004fd <close_all+0x10>
}
  800511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800516:	f3 0f 1e fb          	endbr32 
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	57                   	push   %edi
  80051e:	56                   	push   %esi
  80051f:	53                   	push   %ebx
  800520:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800523:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800526:	50                   	push   %eax
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 4f fe ff ff       	call   80037e <fd_lookup>
  80052f:	89 c3                	mov    %eax,%ebx
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	85 c0                	test   %eax,%eax
  800536:	0f 88 81 00 00 00    	js     8005bd <dup+0xa7>
		return r;
	close(newfdnum);
  80053c:	83 ec 0c             	sub    $0xc,%esp
  80053f:	ff 75 0c             	pushl  0xc(%ebp)
  800542:	e8 75 ff ff ff       	call   8004bc <close>

	newfd = INDEX2FD(newfdnum);
  800547:	8b 75 0c             	mov    0xc(%ebp),%esi
  80054a:	c1 e6 0c             	shl    $0xc,%esi
  80054d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800553:	83 c4 04             	add    $0x4,%esp
  800556:	ff 75 e4             	pushl  -0x1c(%ebp)
  800559:	e8 af fd ff ff       	call   80030d <fd2data>
  80055e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800560:	89 34 24             	mov    %esi,(%esp)
  800563:	e8 a5 fd ff ff       	call   80030d <fd2data>
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80056d:	89 d8                	mov    %ebx,%eax
  80056f:	c1 e8 16             	shr    $0x16,%eax
  800572:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800579:	a8 01                	test   $0x1,%al
  80057b:	74 11                	je     80058e <dup+0x78>
  80057d:	89 d8                	mov    %ebx,%eax
  80057f:	c1 e8 0c             	shr    $0xc,%eax
  800582:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800589:	f6 c2 01             	test   $0x1,%dl
  80058c:	75 39                	jne    8005c7 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80058e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800591:	89 d0                	mov    %edx,%eax
  800593:	c1 e8 0c             	shr    $0xc,%eax
  800596:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a5:	50                   	push   %eax
  8005a6:	56                   	push   %esi
  8005a7:	6a 00                	push   $0x0
  8005a9:	52                   	push   %edx
  8005aa:	6a 00                	push   $0x0
  8005ac:	e8 d7 fb ff ff       	call   800188 <sys_page_map>
  8005b1:	89 c3                	mov    %eax,%ebx
  8005b3:	83 c4 20             	add    $0x20,%esp
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	78 31                	js     8005eb <dup+0xd5>
		goto err;

	return newfdnum;
  8005ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005bd:	89 d8                	mov    %ebx,%eax
  8005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c2:	5b                   	pop    %ebx
  8005c3:	5e                   	pop    %esi
  8005c4:	5f                   	pop    %edi
  8005c5:	5d                   	pop    %ebp
  8005c6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ce:	83 ec 0c             	sub    $0xc,%esp
  8005d1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d6:	50                   	push   %eax
  8005d7:	57                   	push   %edi
  8005d8:	6a 00                	push   $0x0
  8005da:	53                   	push   %ebx
  8005db:	6a 00                	push   $0x0
  8005dd:	e8 a6 fb ff ff       	call   800188 <sys_page_map>
  8005e2:	89 c3                	mov    %eax,%ebx
  8005e4:	83 c4 20             	add    $0x20,%esp
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 a3                	jns    80058e <dup+0x78>
	sys_page_unmap(0, newfd);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	56                   	push   %esi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 b7 fb ff ff       	call   8001ad <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f6:	83 c4 08             	add    $0x8,%esp
  8005f9:	57                   	push   %edi
  8005fa:	6a 00                	push   $0x0
  8005fc:	e8 ac fb ff ff       	call   8001ad <sys_page_unmap>
	return r;
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	eb b7                	jmp    8005bd <dup+0xa7>

00800606 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800606:	f3 0f 1e fb          	endbr32 
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	53                   	push   %ebx
  80060e:	83 ec 1c             	sub    $0x1c,%esp
  800611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800617:	50                   	push   %eax
  800618:	53                   	push   %ebx
  800619:	e8 60 fd ff ff       	call   80037e <fd_lookup>
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	85 c0                	test   %eax,%eax
  800623:	78 3f                	js     800664 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80062b:	50                   	push   %eax
  80062c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062f:	ff 30                	pushl  (%eax)
  800631:	e8 9c fd ff ff       	call   8003d2 <dev_lookup>
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	85 c0                	test   %eax,%eax
  80063b:	78 27                	js     800664 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80063d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800640:	8b 42 08             	mov    0x8(%edx),%eax
  800643:	83 e0 03             	and    $0x3,%eax
  800646:	83 f8 01             	cmp    $0x1,%eax
  800649:	74 1e                	je     800669 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80064b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064e:	8b 40 08             	mov    0x8(%eax),%eax
  800651:	85 c0                	test   %eax,%eax
  800653:	74 35                	je     80068a <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800655:	83 ec 04             	sub    $0x4,%esp
  800658:	ff 75 10             	pushl  0x10(%ebp)
  80065b:	ff 75 0c             	pushl  0xc(%ebp)
  80065e:	52                   	push   %edx
  80065f:	ff d0                	call   *%eax
  800661:	83 c4 10             	add    $0x10,%esp
}
  800664:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800667:	c9                   	leave  
  800668:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800669:	a1 08 40 80 00       	mov    0x804008,%eax
  80066e:	8b 40 48             	mov    0x48(%eax),%eax
  800671:	83 ec 04             	sub    $0x4,%esp
  800674:	53                   	push   %ebx
  800675:	50                   	push   %eax
  800676:	68 ad 23 80 00       	push   $0x8023ad
  80067b:	e8 68 0f 00 00       	call   8015e8 <cprintf>
		return -E_INVAL;
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800688:	eb da                	jmp    800664 <read+0x5e>
		return -E_NOT_SUPP;
  80068a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80068f:	eb d3                	jmp    800664 <read+0x5e>

00800691 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800691:	f3 0f 1e fb          	endbr32 
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	57                   	push   %edi
  800699:	56                   	push   %esi
  80069a:	53                   	push   %ebx
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a9:	eb 02                	jmp    8006ad <readn+0x1c>
  8006ab:	01 c3                	add    %eax,%ebx
  8006ad:	39 f3                	cmp    %esi,%ebx
  8006af:	73 21                	jae    8006d2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b1:	83 ec 04             	sub    $0x4,%esp
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	29 d8                	sub    %ebx,%eax
  8006b8:	50                   	push   %eax
  8006b9:	89 d8                	mov    %ebx,%eax
  8006bb:	03 45 0c             	add    0xc(%ebp),%eax
  8006be:	50                   	push   %eax
  8006bf:	57                   	push   %edi
  8006c0:	e8 41 ff ff ff       	call   800606 <read>
		if (m < 0)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	78 04                	js     8006d0 <readn+0x3f>
			return m;
		if (m == 0)
  8006cc:	75 dd                	jne    8006ab <readn+0x1a>
  8006ce:	eb 02                	jmp    8006d2 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006dc:	f3 0f 1e fb          	endbr32 
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 1c             	sub    $0x1c,%esp
  8006e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ed:	50                   	push   %eax
  8006ee:	53                   	push   %ebx
  8006ef:	e8 8a fc ff ff       	call   80037e <fd_lookup>
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	78 3a                	js     800735 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800705:	ff 30                	pushl  (%eax)
  800707:	e8 c6 fc ff ff       	call   8003d2 <dev_lookup>
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	85 c0                	test   %eax,%eax
  800711:	78 22                	js     800735 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800716:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80071a:	74 1e                	je     80073a <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80071c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80071f:	8b 52 0c             	mov    0xc(%edx),%edx
  800722:	85 d2                	test   %edx,%edx
  800724:	74 35                	je     80075b <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800726:	83 ec 04             	sub    $0x4,%esp
  800729:	ff 75 10             	pushl  0x10(%ebp)
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	50                   	push   %eax
  800730:	ff d2                	call   *%edx
  800732:	83 c4 10             	add    $0x10,%esp
}
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073a:	a1 08 40 80 00       	mov    0x804008,%eax
  80073f:	8b 40 48             	mov    0x48(%eax),%eax
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	53                   	push   %ebx
  800746:	50                   	push   %eax
  800747:	68 c9 23 80 00       	push   $0x8023c9
  80074c:	e8 97 0e 00 00       	call   8015e8 <cprintf>
		return -E_INVAL;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800759:	eb da                	jmp    800735 <write+0x59>
		return -E_NOT_SUPP;
  80075b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800760:	eb d3                	jmp    800735 <write+0x59>

00800762 <seek>:

int
seek(int fdnum, off_t offset)
{
  800762:	f3 0f 1e fb          	endbr32 
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80076c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076f:	50                   	push   %eax
  800770:	ff 75 08             	pushl  0x8(%ebp)
  800773:	e8 06 fc ff ff       	call   80037e <fd_lookup>
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	85 c0                	test   %eax,%eax
  80077d:	78 0e                	js     80078d <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80077f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800785:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80078f:	f3 0f 1e fb          	endbr32 
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	83 ec 1c             	sub    $0x1c,%esp
  80079a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a0:	50                   	push   %eax
  8007a1:	53                   	push   %ebx
  8007a2:	e8 d7 fb ff ff       	call   80037e <fd_lookup>
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	78 37                	js     8007e5 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b8:	ff 30                	pushl  (%eax)
  8007ba:	e8 13 fc ff ff       	call   8003d2 <dev_lookup>
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	78 1f                	js     8007e5 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007cd:	74 1b                	je     8007ea <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d2:	8b 52 18             	mov    0x18(%edx),%edx
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 32                	je     80080b <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	50                   	push   %eax
  8007e0:	ff d2                	call   *%edx
  8007e2:	83 c4 10             	add    $0x10,%esp
}
  8007e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ea:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007ef:	8b 40 48             	mov    0x48(%eax),%eax
  8007f2:	83 ec 04             	sub    $0x4,%esp
  8007f5:	53                   	push   %ebx
  8007f6:	50                   	push   %eax
  8007f7:	68 8c 23 80 00       	push   $0x80238c
  8007fc:	e8 e7 0d 00 00       	call   8015e8 <cprintf>
		return -E_INVAL;
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800809:	eb da                	jmp    8007e5 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80080b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800810:	eb d3                	jmp    8007e5 <ftruncate+0x56>

00800812 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800812:	f3 0f 1e fb          	endbr32 
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	83 ec 1c             	sub    $0x1c,%esp
  80081d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800820:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	ff 75 08             	pushl  0x8(%ebp)
  800827:	e8 52 fb ff ff       	call   80037e <fd_lookup>
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 4b                	js     80087e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800839:	50                   	push   %eax
  80083a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083d:	ff 30                	pushl  (%eax)
  80083f:	e8 8e fb ff ff       	call   8003d2 <dev_lookup>
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	85 c0                	test   %eax,%eax
  800849:	78 33                	js     80087e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800852:	74 2f                	je     800883 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800854:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800857:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085e:	00 00 00 
	stat->st_isdir = 0;
  800861:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800868:	00 00 00 
	stat->st_dev = dev;
  80086b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	ff 75 f0             	pushl  -0x10(%ebp)
  800878:	ff 50 14             	call   *0x14(%eax)
  80087b:	83 c4 10             	add    $0x10,%esp
}
  80087e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    
		return -E_NOT_SUPP;
  800883:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800888:	eb f4                	jmp    80087e <fstat+0x6c>

0080088a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088a:	f3 0f 1e fb          	endbr32 
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	6a 00                	push   $0x0
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 01 02 00 00       	call   800aa1 <open>
  8008a0:	89 c3                	mov    %eax,%ebx
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	78 1b                	js     8008c4 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	50                   	push   %eax
  8008b0:	e8 5d ff ff ff       	call   800812 <fstat>
  8008b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b7:	89 1c 24             	mov    %ebx,(%esp)
  8008ba:	e8 fd fb ff ff       	call   8004bc <close>
	return r;
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	89 f3                	mov    %esi,%ebx
}
  8008c4:	89 d8                	mov    %ebx,%eax
  8008c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	89 c6                	mov    %eax,%esi
  8008d4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008dd:	74 27                	je     800906 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008df:	6a 07                	push   $0x7
  8008e1:	68 00 50 80 00       	push   $0x805000
  8008e6:	56                   	push   %esi
  8008e7:	ff 35 00 40 80 00    	pushl  0x804000
  8008ed:	e8 27 17 00 00       	call   802019 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f2:	83 c4 0c             	add    $0xc,%esp
  8008f5:	6a 00                	push   $0x0
  8008f7:	53                   	push   %ebx
  8008f8:	6a 00                	push   $0x0
  8008fa:	e8 ad 16 00 00       	call   801fac <ipc_recv>
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800906:	83 ec 0c             	sub    $0xc,%esp
  800909:	6a 01                	push   $0x1
  80090b:	e8 61 17 00 00       	call   802071 <ipc_find_env>
  800910:	a3 00 40 80 00       	mov    %eax,0x804000
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	eb c5                	jmp    8008df <fsipc+0x12>

0080091a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091a:	f3 0f 1e fb          	endbr32 
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 40 0c             	mov    0xc(%eax),%eax
  80092a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800937:	ba 00 00 00 00       	mov    $0x0,%edx
  80093c:	b8 02 00 00 00       	mov    $0x2,%eax
  800941:	e8 87 ff ff ff       	call   8008cd <fsipc>
}
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <devfile_flush>:
{
  800948:	f3 0f 1e fb          	endbr32 
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 40 0c             	mov    0xc(%eax),%eax
  800958:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80095d:	ba 00 00 00 00       	mov    $0x0,%edx
  800962:	b8 06 00 00 00       	mov    $0x6,%eax
  800967:	e8 61 ff ff ff       	call   8008cd <fsipc>
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <devfile_stat>:
{
  80096e:	f3 0f 1e fb          	endbr32 
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	83 ec 04             	sub    $0x4,%esp
  800979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 40 0c             	mov    0xc(%eax),%eax
  800982:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800987:	ba 00 00 00 00       	mov    $0x0,%edx
  80098c:	b8 05 00 00 00       	mov    $0x5,%eax
  800991:	e8 37 ff ff ff       	call   8008cd <fsipc>
  800996:	85 c0                	test   %eax,%eax
  800998:	78 2c                	js     8009c6 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	68 00 50 80 00       	push   $0x805000
  8009a2:	53                   	push   %ebx
  8009a3:	e8 4a 12 00 00       	call   801bf2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009be:	83 c4 10             	add    $0x10,%esp
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_write>:
{
  8009cb:	f3 0f 1e fb          	endbr32 
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 0c             	sub    $0xc,%esp
  8009d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009dd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009e2:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8009eb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009f1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f6:	50                   	push   %eax
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	68 08 50 80 00       	push   $0x805008
  8009ff:	e8 ec 13 00 00       	call   801df0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
  800a09:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0e:	e8 ba fe ff ff       	call   8008cd <fsipc>
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_read>:
{
  800a15:	f3 0f 1e fb          	endbr32 
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8b 40 0c             	mov    0xc(%eax),%eax
  800a27:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a2c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a32:	ba 00 00 00 00       	mov    $0x0,%edx
  800a37:	b8 03 00 00 00       	mov    $0x3,%eax
  800a3c:	e8 8c fe ff ff       	call   8008cd <fsipc>
  800a41:	89 c3                	mov    %eax,%ebx
  800a43:	85 c0                	test   %eax,%eax
  800a45:	78 1f                	js     800a66 <devfile_read+0x51>
	assert(r <= n);
  800a47:	39 f0                	cmp    %esi,%eax
  800a49:	77 24                	ja     800a6f <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a4b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a50:	7f 36                	jg     800a88 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a52:	83 ec 04             	sub    $0x4,%esp
  800a55:	50                   	push   %eax
  800a56:	68 00 50 80 00       	push   $0x805000
  800a5b:	ff 75 0c             	pushl  0xc(%ebp)
  800a5e:	e8 8d 13 00 00       	call   801df0 <memmove>
	return r;
  800a63:	83 c4 10             	add    $0x10,%esp
}
  800a66:	89 d8                	mov    %ebx,%eax
  800a68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    
	assert(r <= n);
  800a6f:	68 fc 23 80 00       	push   $0x8023fc
  800a74:	68 03 24 80 00       	push   $0x802403
  800a79:	68 8c 00 00 00       	push   $0x8c
  800a7e:	68 18 24 80 00       	push   $0x802418
  800a83:	e8 79 0a 00 00       	call   801501 <_panic>
	assert(r <= PGSIZE);
  800a88:	68 23 24 80 00       	push   $0x802423
  800a8d:	68 03 24 80 00       	push   $0x802403
  800a92:	68 8d 00 00 00       	push   $0x8d
  800a97:	68 18 24 80 00       	push   $0x802418
  800a9c:	e8 60 0a 00 00       	call   801501 <_panic>

00800aa1 <open>:
{
  800aa1:	f3 0f 1e fb          	endbr32 
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	83 ec 1c             	sub    $0x1c,%esp
  800aad:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ab0:	56                   	push   %esi
  800ab1:	e8 f9 10 00 00       	call   801baf <strlen>
  800ab6:	83 c4 10             	add    $0x10,%esp
  800ab9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800abe:	7f 6c                	jg     800b2c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ac0:	83 ec 0c             	sub    $0xc,%esp
  800ac3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	e8 5c f8 ff ff       	call   800328 <fd_alloc>
  800acc:	89 c3                	mov    %eax,%ebx
  800ace:	83 c4 10             	add    $0x10,%esp
  800ad1:	85 c0                	test   %eax,%eax
  800ad3:	78 3c                	js     800b11 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ad5:	83 ec 08             	sub    $0x8,%esp
  800ad8:	56                   	push   %esi
  800ad9:	68 00 50 80 00       	push   $0x805000
  800ade:	e8 0f 11 00 00       	call   801bf2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aee:	b8 01 00 00 00       	mov    $0x1,%eax
  800af3:	e8 d5 fd ff ff       	call   8008cd <fsipc>
  800af8:	89 c3                	mov    %eax,%ebx
  800afa:	83 c4 10             	add    $0x10,%esp
  800afd:	85 c0                	test   %eax,%eax
  800aff:	78 19                	js     800b1a <open+0x79>
	return fd2num(fd);
  800b01:	83 ec 0c             	sub    $0xc,%esp
  800b04:	ff 75 f4             	pushl  -0xc(%ebp)
  800b07:	e8 ed f7 ff ff       	call   8002f9 <fd2num>
  800b0c:	89 c3                	mov    %eax,%ebx
  800b0e:	83 c4 10             	add    $0x10,%esp
}
  800b11:	89 d8                	mov    %ebx,%eax
  800b13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    
		fd_close(fd, 0);
  800b1a:	83 ec 08             	sub    $0x8,%esp
  800b1d:	6a 00                	push   $0x0
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 0a f9 ff ff       	call   800431 <fd_close>
		return r;
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	eb e5                	jmp    800b11 <open+0x70>
		return -E_BAD_PATH;
  800b2c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b31:	eb de                	jmp    800b11 <open+0x70>

00800b33 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b33:	f3 0f 1e fb          	endbr32 
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	b8 08 00 00 00       	mov    $0x8,%eax
  800b47:	e8 81 fd ff ff       	call   8008cd <fsipc>
}
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b4e:	f3 0f 1e fb          	endbr32 
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b58:	68 8f 24 80 00       	push   $0x80248f
  800b5d:	ff 75 0c             	pushl  0xc(%ebp)
  800b60:	e8 8d 10 00 00       	call   801bf2 <strcpy>
	return 0;
}
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <devsock_close>:
{
  800b6c:	f3 0f 1e fb          	endbr32 
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	53                   	push   %ebx
  800b74:	83 ec 10             	sub    $0x10,%esp
  800b77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800b7a:	53                   	push   %ebx
  800b7b:	e8 2e 15 00 00       	call   8020ae <pageref>
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	83 c4 10             	add    $0x10,%esp
		return 0;
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800b8a:	83 fa 01             	cmp    $0x1,%edx
  800b8d:	74 05                	je     800b94 <devsock_close+0x28>
}
  800b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	ff 73 0c             	pushl  0xc(%ebx)
  800b9a:	e8 e3 02 00 00       	call   800e82 <nsipc_close>
  800b9f:	83 c4 10             	add    $0x10,%esp
  800ba2:	eb eb                	jmp    800b8f <devsock_close+0x23>

00800ba4 <devsock_write>:
{
  800ba4:	f3 0f 1e fb          	endbr32 
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bae:	6a 00                	push   $0x0
  800bb0:	ff 75 10             	pushl  0x10(%ebp)
  800bb3:	ff 75 0c             	pushl  0xc(%ebp)
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	ff 70 0c             	pushl  0xc(%eax)
  800bbc:	e8 b5 03 00 00       	call   800f76 <nsipc_send>
}
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <devsock_read>:
{
  800bc3:	f3 0f 1e fb          	endbr32 
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bcd:	6a 00                	push   $0x0
  800bcf:	ff 75 10             	pushl  0x10(%ebp)
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	ff 70 0c             	pushl  0xc(%eax)
  800bdb:	e8 1f 03 00 00       	call   800eff <nsipc_recv>
}
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <fd2sockid>:
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800be8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800beb:	52                   	push   %edx
  800bec:	50                   	push   %eax
  800bed:	e8 8c f7 ff ff       	call   80037e <fd_lookup>
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	78 10                	js     800c09 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bfc:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  800c02:	39 08                	cmp    %ecx,(%eax)
  800c04:	75 05                	jne    800c0b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c06:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    
		return -E_NOT_SUPP;
  800c0b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c10:	eb f7                	jmp    800c09 <fd2sockid+0x27>

00800c12 <alloc_sockfd>:
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 1c             	sub    $0x1c,%esp
  800c1a:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c1f:	50                   	push   %eax
  800c20:	e8 03 f7 ff ff       	call   800328 <fd_alloc>
  800c25:	89 c3                	mov    %eax,%ebx
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	78 43                	js     800c71 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c2e:	83 ec 04             	sub    $0x4,%esp
  800c31:	68 07 04 00 00       	push   $0x407
  800c36:	ff 75 f4             	pushl  -0xc(%ebp)
  800c39:	6a 00                	push   $0x0
  800c3b:	e8 22 f5 ff ff       	call   800162 <sys_page_alloc>
  800c40:	89 c3                	mov    %eax,%ebx
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	85 c0                	test   %eax,%eax
  800c47:	78 28                	js     800c71 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4c:	8b 15 60 30 80 00    	mov    0x803060,%edx
  800c52:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c57:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c5e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	e8 8f f6 ff ff       	call   8002f9 <fd2num>
  800c6a:	89 c3                	mov    %eax,%ebx
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	eb 0c                	jmp    800c7d <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	56                   	push   %esi
  800c75:	e8 08 02 00 00       	call   800e82 <nsipc_close>
		return r;
  800c7a:	83 c4 10             	add    $0x10,%esp
}
  800c7d:	89 d8                	mov    %ebx,%eax
  800c7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <accept>:
{
  800c86:	f3 0f 1e fb          	endbr32 
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	e8 4a ff ff ff       	call   800be2 <fd2sockid>
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	78 1b                	js     800cb7 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800c9c:	83 ec 04             	sub    $0x4,%esp
  800c9f:	ff 75 10             	pushl  0x10(%ebp)
  800ca2:	ff 75 0c             	pushl  0xc(%ebp)
  800ca5:	50                   	push   %eax
  800ca6:	e8 22 01 00 00       	call   800dcd <nsipc_accept>
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	78 05                	js     800cb7 <accept+0x31>
	return alloc_sockfd(r);
  800cb2:	e8 5b ff ff ff       	call   800c12 <alloc_sockfd>
}
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    

00800cb9 <bind>:
{
  800cb9:	f3 0f 1e fb          	endbr32 
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	e8 17 ff ff ff       	call   800be2 <fd2sockid>
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	78 12                	js     800ce1 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  800ccf:	83 ec 04             	sub    $0x4,%esp
  800cd2:	ff 75 10             	pushl  0x10(%ebp)
  800cd5:	ff 75 0c             	pushl  0xc(%ebp)
  800cd8:	50                   	push   %eax
  800cd9:	e8 45 01 00 00       	call   800e23 <nsipc_bind>
  800cde:	83 c4 10             	add    $0x10,%esp
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <shutdown>:
{
  800ce3:	f3 0f 1e fb          	endbr32 
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	e8 ed fe ff ff       	call   800be2 <fd2sockid>
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	78 0f                	js     800d08 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  800cf9:	83 ec 08             	sub    $0x8,%esp
  800cfc:	ff 75 0c             	pushl  0xc(%ebp)
  800cff:	50                   	push   %eax
  800d00:	e8 57 01 00 00       	call   800e5c <nsipc_shutdown>
  800d05:	83 c4 10             	add    $0x10,%esp
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <connect>:
{
  800d0a:	f3 0f 1e fb          	endbr32 
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	e8 c6 fe ff ff       	call   800be2 <fd2sockid>
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	78 12                	js     800d32 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  800d20:	83 ec 04             	sub    $0x4,%esp
  800d23:	ff 75 10             	pushl  0x10(%ebp)
  800d26:	ff 75 0c             	pushl  0xc(%ebp)
  800d29:	50                   	push   %eax
  800d2a:	e8 71 01 00 00       	call   800ea0 <nsipc_connect>
  800d2f:	83 c4 10             	add    $0x10,%esp
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <listen>:
{
  800d34:	f3 0f 1e fb          	endbr32 
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	e8 9c fe ff ff       	call   800be2 <fd2sockid>
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 0f                	js     800d59 <listen+0x25>
	return nsipc_listen(r, backlog);
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	ff 75 0c             	pushl  0xc(%ebp)
  800d50:	50                   	push   %eax
  800d51:	e8 83 01 00 00       	call   800ed9 <nsipc_listen>
  800d56:	83 c4 10             	add    $0x10,%esp
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <socket>:

int
socket(int domain, int type, int protocol)
{
  800d5b:	f3 0f 1e fb          	endbr32 
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d65:	ff 75 10             	pushl  0x10(%ebp)
  800d68:	ff 75 0c             	pushl  0xc(%ebp)
  800d6b:	ff 75 08             	pushl  0x8(%ebp)
  800d6e:	e8 65 02 00 00       	call   800fd8 <nsipc_socket>
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	78 05                	js     800d7f <socket+0x24>
		return r;
	return alloc_sockfd(r);
  800d7a:	e8 93 fe ff ff       	call   800c12 <alloc_sockfd>
}
  800d7f:	c9                   	leave  
  800d80:	c3                   	ret    

00800d81 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	53                   	push   %ebx
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d8a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800d91:	74 26                	je     800db9 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800d93:	6a 07                	push   $0x7
  800d95:	68 00 60 80 00       	push   $0x806000
  800d9a:	53                   	push   %ebx
  800d9b:	ff 35 04 40 80 00    	pushl  0x804004
  800da1:	e8 73 12 00 00       	call   802019 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800da6:	83 c4 0c             	add    $0xc,%esp
  800da9:	6a 00                	push   $0x0
  800dab:	6a 00                	push   $0x0
  800dad:	6a 00                	push   $0x0
  800daf:	e8 f8 11 00 00       	call   801fac <ipc_recv>
}
  800db4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	6a 02                	push   $0x2
  800dbe:	e8 ae 12 00 00       	call   802071 <ipc_find_env>
  800dc3:	a3 04 40 80 00       	mov    %eax,0x804004
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	eb c6                	jmp    800d93 <nsipc+0x12>

00800dcd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dcd:	f3 0f 1e fb          	endbr32 
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800de1:	8b 06                	mov    (%esi),%eax
  800de3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800de8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ded:	e8 8f ff ff ff       	call   800d81 <nsipc>
  800df2:	89 c3                	mov    %eax,%ebx
  800df4:	85 c0                	test   %eax,%eax
  800df6:	79 09                	jns    800e01 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	ff 35 10 60 80 00    	pushl  0x806010
  800e0a:	68 00 60 80 00       	push   $0x806000
  800e0f:	ff 75 0c             	pushl  0xc(%ebp)
  800e12:	e8 d9 0f 00 00       	call   801df0 <memmove>
		*addrlen = ret->ret_addrlen;
  800e17:	a1 10 60 80 00       	mov    0x806010,%eax
  800e1c:	89 06                	mov    %eax,(%esi)
  800e1e:	83 c4 10             	add    $0x10,%esp
	return r;
  800e21:	eb d5                	jmp    800df8 <nsipc_accept+0x2b>

00800e23 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e23:	f3 0f 1e fb          	endbr32 
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 08             	sub    $0x8,%esp
  800e2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e39:	53                   	push   %ebx
  800e3a:	ff 75 0c             	pushl  0xc(%ebp)
  800e3d:	68 04 60 80 00       	push   $0x806004
  800e42:	e8 a9 0f 00 00       	call   801df0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e47:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e52:	e8 2a ff ff ff       	call   800d81 <nsipc>
}
  800e57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e5c:	f3 0f 1e fb          	endbr32 
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e76:	b8 03 00 00 00       	mov    $0x3,%eax
  800e7b:	e8 01 ff ff ff       	call   800d81 <nsipc>
}
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <nsipc_close>:

int
nsipc_close(int s)
{
  800e82:	f3 0f 1e fb          	endbr32 
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800e94:	b8 04 00 00 00       	mov    $0x4,%eax
  800e99:	e8 e3 fe ff ff       	call   800d81 <nsipc>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea0:	f3 0f 1e fb          	endbr32 
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eb6:	53                   	push   %ebx
  800eb7:	ff 75 0c             	pushl  0xc(%ebp)
  800eba:	68 04 60 80 00       	push   $0x806004
  800ebf:	e8 2c 0f 00 00       	call   801df0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ec4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ecf:	e8 ad fe ff ff       	call   800d81 <nsipc>
}
  800ed4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ed9:	f3 0f 1e fb          	endbr32 
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eee:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef8:	e8 84 fe ff ff       	call   800d81 <nsipc>
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800eff:	f3 0f 1e fb          	endbr32 
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f13:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f19:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f21:	b8 07 00 00 00       	mov    $0x7,%eax
  800f26:	e8 56 fe ff ff       	call   800d81 <nsipc>
  800f2b:	89 c3                	mov    %eax,%ebx
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 26                	js     800f57 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  800f31:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  800f37:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f3c:	0f 4e c6             	cmovle %esi,%eax
  800f3f:	39 c3                	cmp    %eax,%ebx
  800f41:	7f 1d                	jg     800f60 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	53                   	push   %ebx
  800f47:	68 00 60 80 00       	push   $0x806000
  800f4c:	ff 75 0c             	pushl  0xc(%ebp)
  800f4f:	e8 9c 0e 00 00       	call   801df0 <memmove>
  800f54:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f57:	89 d8                	mov    %ebx,%eax
  800f59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f60:	68 9b 24 80 00       	push   $0x80249b
  800f65:	68 03 24 80 00       	push   $0x802403
  800f6a:	6a 62                	push   $0x62
  800f6c:	68 b0 24 80 00       	push   $0x8024b0
  800f71:	e8 8b 05 00 00       	call   801501 <_panic>

00800f76 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f76:	f3 0f 1e fb          	endbr32 
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	53                   	push   %ebx
  800f7e:	83 ec 04             	sub    $0x4,%esp
  800f81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f8c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f92:	7f 2e                	jg     800fc2 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	53                   	push   %ebx
  800f98:	ff 75 0c             	pushl  0xc(%ebp)
  800f9b:	68 0c 60 80 00       	push   $0x80600c
  800fa0:	e8 4b 0e 00 00       	call   801df0 <memmove>
	nsipcbuf.send.req_size = size;
  800fa5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fab:	8b 45 14             	mov    0x14(%ebp),%eax
  800fae:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fb3:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb8:	e8 c4 fd ff ff       	call   800d81 <nsipc>
}
  800fbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    
	assert(size < 1600);
  800fc2:	68 bc 24 80 00       	push   $0x8024bc
  800fc7:	68 03 24 80 00       	push   $0x802403
  800fcc:	6a 6d                	push   $0x6d
  800fce:	68 b0 24 80 00       	push   $0x8024b0
  800fd3:	e8 29 05 00 00       	call   801501 <_panic>

00800fd8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd8:	f3 0f 1e fb          	endbr32 
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fed:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ffa:	b8 09 00 00 00       	mov    $0x9,%eax
  800fff:	e8 7d fd ff ff       	call   800d81 <nsipc>
}
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801006:	f3 0f 1e fb          	endbr32 
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	56                   	push   %esi
  80100e:	53                   	push   %ebx
  80100f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	ff 75 08             	pushl  0x8(%ebp)
  801018:	e8 f0 f2 ff ff       	call   80030d <fd2data>
  80101d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101f:	83 c4 08             	add    $0x8,%esp
  801022:	68 c8 24 80 00       	push   $0x8024c8
  801027:	53                   	push   %ebx
  801028:	e8 c5 0b 00 00       	call   801bf2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102d:	8b 46 04             	mov    0x4(%esi),%eax
  801030:	2b 06                	sub    (%esi),%eax
  801032:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801038:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103f:	00 00 00 
	stat->st_dev = &devpipe;
  801042:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801049:	30 80 00 
	return 0;
}
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
  801051:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801058:	f3 0f 1e fb          	endbr32 
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801066:	53                   	push   %ebx
  801067:	6a 00                	push   $0x0
  801069:	e8 3f f1 ff ff       	call   8001ad <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106e:	89 1c 24             	mov    %ebx,(%esp)
  801071:	e8 97 f2 ff ff       	call   80030d <fd2data>
  801076:	83 c4 08             	add    $0x8,%esp
  801079:	50                   	push   %eax
  80107a:	6a 00                	push   $0x0
  80107c:	e8 2c f1 ff ff       	call   8001ad <sys_page_unmap>
}
  801081:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <_pipeisclosed>:
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	57                   	push   %edi
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
  80108c:	83 ec 1c             	sub    $0x1c,%esp
  80108f:	89 c7                	mov    %eax,%edi
  801091:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801093:	a1 08 40 80 00       	mov    0x804008,%eax
  801098:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	57                   	push   %edi
  80109f:	e8 0a 10 00 00       	call   8020ae <pageref>
  8010a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a7:	89 34 24             	mov    %esi,(%esp)
  8010aa:	e8 ff 0f 00 00       	call   8020ae <pageref>
		nn = thisenv->env_runs;
  8010af:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	39 cb                	cmp    %ecx,%ebx
  8010bd:	74 1b                	je     8010da <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010bf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c2:	75 cf                	jne    801093 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c4:	8b 42 58             	mov    0x58(%edx),%eax
  8010c7:	6a 01                	push   $0x1
  8010c9:	50                   	push   %eax
  8010ca:	53                   	push   %ebx
  8010cb:	68 cf 24 80 00       	push   $0x8024cf
  8010d0:	e8 13 05 00 00       	call   8015e8 <cprintf>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	eb b9                	jmp    801093 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010da:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010dd:	0f 94 c0             	sete   %al
  8010e0:	0f b6 c0             	movzbl %al,%eax
}
  8010e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    

008010eb <devpipe_write>:
{
  8010eb:	f3 0f 1e fb          	endbr32 
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	57                   	push   %edi
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 28             	sub    $0x28,%esp
  8010f8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010fb:	56                   	push   %esi
  8010fc:	e8 0c f2 ff ff       	call   80030d <fd2data>
  801101:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	bf 00 00 00 00       	mov    $0x0,%edi
  80110b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80110e:	74 4f                	je     80115f <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801110:	8b 43 04             	mov    0x4(%ebx),%eax
  801113:	8b 0b                	mov    (%ebx),%ecx
  801115:	8d 51 20             	lea    0x20(%ecx),%edx
  801118:	39 d0                	cmp    %edx,%eax
  80111a:	72 14                	jb     801130 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80111c:	89 da                	mov    %ebx,%edx
  80111e:	89 f0                	mov    %esi,%eax
  801120:	e8 61 ff ff ff       	call   801086 <_pipeisclosed>
  801125:	85 c0                	test   %eax,%eax
  801127:	75 3b                	jne    801164 <devpipe_write+0x79>
			sys_yield();
  801129:	e8 11 f0 ff ff       	call   80013f <sys_yield>
  80112e:	eb e0                	jmp    801110 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801133:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801137:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113a:	89 c2                	mov    %eax,%edx
  80113c:	c1 fa 1f             	sar    $0x1f,%edx
  80113f:	89 d1                	mov    %edx,%ecx
  801141:	c1 e9 1b             	shr    $0x1b,%ecx
  801144:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801147:	83 e2 1f             	and    $0x1f,%edx
  80114a:	29 ca                	sub    %ecx,%edx
  80114c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801150:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801154:	83 c0 01             	add    $0x1,%eax
  801157:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80115a:	83 c7 01             	add    $0x1,%edi
  80115d:	eb ac                	jmp    80110b <devpipe_write+0x20>
	return i;
  80115f:	8b 45 10             	mov    0x10(%ebp),%eax
  801162:	eb 05                	jmp    801169 <devpipe_write+0x7e>
				return 0;
  801164:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <devpipe_read>:
{
  801171:	f3 0f 1e fb          	endbr32 
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 18             	sub    $0x18,%esp
  80117e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801181:	57                   	push   %edi
  801182:	e8 86 f1 ff ff       	call   80030d <fd2data>
  801187:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	be 00 00 00 00       	mov    $0x0,%esi
  801191:	3b 75 10             	cmp    0x10(%ebp),%esi
  801194:	75 14                	jne    8011aa <devpipe_read+0x39>
	return i;
  801196:	8b 45 10             	mov    0x10(%ebp),%eax
  801199:	eb 02                	jmp    80119d <devpipe_read+0x2c>
				return i;
  80119b:	89 f0                	mov    %esi,%eax
}
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    
			sys_yield();
  8011a5:	e8 95 ef ff ff       	call   80013f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011aa:	8b 03                	mov    (%ebx),%eax
  8011ac:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011af:	75 18                	jne    8011c9 <devpipe_read+0x58>
			if (i > 0)
  8011b1:	85 f6                	test   %esi,%esi
  8011b3:	75 e6                	jne    80119b <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8011b5:	89 da                	mov    %ebx,%edx
  8011b7:	89 f8                	mov    %edi,%eax
  8011b9:	e8 c8 fe ff ff       	call   801086 <_pipeisclosed>
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	74 e3                	je     8011a5 <devpipe_read+0x34>
				return 0;
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c7:	eb d4                	jmp    80119d <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011c9:	99                   	cltd   
  8011ca:	c1 ea 1b             	shr    $0x1b,%edx
  8011cd:	01 d0                	add    %edx,%eax
  8011cf:	83 e0 1f             	and    $0x1f,%eax
  8011d2:	29 d0                	sub    %edx,%eax
  8011d4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011df:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011e2:	83 c6 01             	add    $0x1,%esi
  8011e5:	eb aa                	jmp    801191 <devpipe_read+0x20>

008011e7 <pipe>:
{
  8011e7:	f3 0f 1e fb          	endbr32 
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	e8 2c f1 ff ff       	call   800328 <fd_alloc>
  8011fc:	89 c3                	mov    %eax,%ebx
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 23 01 00 00    	js     80132c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	68 07 04 00 00       	push   $0x407
  801211:	ff 75 f4             	pushl  -0xc(%ebp)
  801214:	6a 00                	push   $0x0
  801216:	e8 47 ef ff ff       	call   800162 <sys_page_alloc>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 88 04 01 00 00    	js     80132c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	e8 f4 f0 ff ff       	call   800328 <fd_alloc>
  801234:	89 c3                	mov    %eax,%ebx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	0f 88 db 00 00 00    	js     80131c <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	68 07 04 00 00       	push   $0x407
  801249:	ff 75 f0             	pushl  -0x10(%ebp)
  80124c:	6a 00                	push   $0x0
  80124e:	e8 0f ef ff ff       	call   800162 <sys_page_alloc>
  801253:	89 c3                	mov    %eax,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	0f 88 bc 00 00 00    	js     80131c <pipe+0x135>
	va = fd2data(fd0);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	ff 75 f4             	pushl  -0xc(%ebp)
  801266:	e8 a2 f0 ff ff       	call   80030d <fd2data>
  80126b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126d:	83 c4 0c             	add    $0xc,%esp
  801270:	68 07 04 00 00       	push   $0x407
  801275:	50                   	push   %eax
  801276:	6a 00                	push   $0x0
  801278:	e8 e5 ee ff ff       	call   800162 <sys_page_alloc>
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 88 82 00 00 00    	js     80130c <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	ff 75 f0             	pushl  -0x10(%ebp)
  801290:	e8 78 f0 ff ff       	call   80030d <fd2data>
  801295:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80129c:	50                   	push   %eax
  80129d:	6a 00                	push   $0x0
  80129f:	56                   	push   %esi
  8012a0:	6a 00                	push   $0x0
  8012a2:	e8 e1 ee ff ff       	call   800188 <sys_page_map>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	83 c4 20             	add    $0x20,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 4e                	js     8012fe <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8012b0:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8012b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012c7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d9:	e8 1b f0 ff ff       	call   8002f9 <fd2num>
  8012de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e3:	83 c4 04             	add    $0x4,%esp
  8012e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e9:	e8 0b f0 ff ff       	call   8002f9 <fd2num>
  8012ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fc:	eb 2e                	jmp    80132c <pipe+0x145>
	sys_page_unmap(0, va);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	56                   	push   %esi
  801302:	6a 00                	push   $0x0
  801304:	e8 a4 ee ff ff       	call   8001ad <sys_page_unmap>
  801309:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	ff 75 f0             	pushl  -0x10(%ebp)
  801312:	6a 00                	push   $0x0
  801314:	e8 94 ee ff ff       	call   8001ad <sys_page_unmap>
  801319:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	ff 75 f4             	pushl  -0xc(%ebp)
  801322:	6a 00                	push   $0x0
  801324:	e8 84 ee ff ff       	call   8001ad <sys_page_unmap>
  801329:	83 c4 10             	add    $0x10,%esp
}
  80132c:	89 d8                	mov    %ebx,%eax
  80132e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <pipeisclosed>:
{
  801335:	f3 0f 1e fb          	endbr32 
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	ff 75 08             	pushl  0x8(%ebp)
  801346:	e8 33 f0 ff ff       	call   80037e <fd_lookup>
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 18                	js     80136a <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	ff 75 f4             	pushl  -0xc(%ebp)
  801358:	e8 b0 ef ff ff       	call   80030d <fd2data>
  80135d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80135f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801362:	e8 1f fd ff ff       	call   801086 <_pipeisclosed>
  801367:	83 c4 10             	add    $0x10,%esp
}
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80136c:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	c3                   	ret    

00801376 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801376:	f3 0f 1e fb          	endbr32 
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801380:	68 e7 24 80 00       	push   $0x8024e7
  801385:	ff 75 0c             	pushl  0xc(%ebp)
  801388:	e8 65 08 00 00       	call   801bf2 <strcpy>
	return 0;
}
  80138d:	b8 00 00 00 00       	mov    $0x0,%eax
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <devcons_write>:
{
  801394:	f3 0f 1e fb          	endbr32 
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	57                   	push   %edi
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
  80139e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8013a4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013a9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013b2:	73 31                	jae    8013e5 <devcons_write+0x51>
		m = n - tot;
  8013b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b7:	29 f3                	sub    %esi,%ebx
  8013b9:	83 fb 7f             	cmp    $0x7f,%ebx
  8013bc:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013c1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	53                   	push   %ebx
  8013c8:	89 f0                	mov    %esi,%eax
  8013ca:	03 45 0c             	add    0xc(%ebp),%eax
  8013cd:	50                   	push   %eax
  8013ce:	57                   	push   %edi
  8013cf:	e8 1c 0a 00 00       	call   801df0 <memmove>
		sys_cputs(buf, m);
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	53                   	push   %ebx
  8013d8:	57                   	push   %edi
  8013d9:	e8 d5 ec ff ff       	call   8000b3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013de:	01 de                	add    %ebx,%esi
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	eb ca                	jmp    8013af <devcons_write+0x1b>
}
  8013e5:	89 f0                	mov    %esi,%eax
  8013e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ea:	5b                   	pop    %ebx
  8013eb:	5e                   	pop    %esi
  8013ec:	5f                   	pop    %edi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    

008013ef <devcons_read>:
{
  8013ef:	f3 0f 1e fb          	endbr32 
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801402:	74 21                	je     801425 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801404:	e8 cc ec ff ff       	call   8000d5 <sys_cgetc>
  801409:	85 c0                	test   %eax,%eax
  80140b:	75 07                	jne    801414 <devcons_read+0x25>
		sys_yield();
  80140d:	e8 2d ed ff ff       	call   80013f <sys_yield>
  801412:	eb f0                	jmp    801404 <devcons_read+0x15>
	if (c < 0)
  801414:	78 0f                	js     801425 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801416:	83 f8 04             	cmp    $0x4,%eax
  801419:	74 0c                	je     801427 <devcons_read+0x38>
	*(char*)vbuf = c;
  80141b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80141e:	88 02                	mov    %al,(%edx)
	return 1;
  801420:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    
		return 0;
  801427:	b8 00 00 00 00       	mov    $0x0,%eax
  80142c:	eb f7                	jmp    801425 <devcons_read+0x36>

0080142e <cputchar>:
{
  80142e:	f3 0f 1e fb          	endbr32 
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80143e:	6a 01                	push   $0x1
  801440:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801443:	50                   	push   %eax
  801444:	e8 6a ec ff ff       	call   8000b3 <sys_cputs>
}
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <getchar>:
{
  80144e:	f3 0f 1e fb          	endbr32 
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801458:	6a 01                	push   $0x1
  80145a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	6a 00                	push   $0x0
  801460:	e8 a1 f1 ff ff       	call   800606 <read>
	if (r < 0)
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 06                	js     801472 <getchar+0x24>
	if (r < 1)
  80146c:	74 06                	je     801474 <getchar+0x26>
	return c;
  80146e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    
		return -E_EOF;
  801474:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801479:	eb f7                	jmp    801472 <getchar+0x24>

0080147b <iscons>:
{
  80147b:	f3 0f 1e fb          	endbr32 
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801485:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	ff 75 08             	pushl  0x8(%ebp)
  80148c:	e8 ed ee ff ff       	call   80037e <fd_lookup>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	85 c0                	test   %eax,%eax
  801496:	78 11                	js     8014a9 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801498:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149b:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014a1:	39 10                	cmp    %edx,(%eax)
  8014a3:	0f 94 c0             	sete   %al
  8014a6:	0f b6 c0             	movzbl %al,%eax
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    

008014ab <opencons>:
{
  8014ab:	f3 0f 1e fb          	endbr32 
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b8:	50                   	push   %eax
  8014b9:	e8 6a ee ff ff       	call   800328 <fd_alloc>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 3a                	js     8014ff <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c5:	83 ec 04             	sub    $0x4,%esp
  8014c8:	68 07 04 00 00       	push   $0x407
  8014cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 8b ec ff ff       	call   800162 <sys_page_alloc>
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 21                	js     8014ff <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e1:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8014e7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	50                   	push   %eax
  8014f7:	e8 fd ed ff ff       	call   8002f9 <fd2num>
  8014fc:	83 c4 10             	add    $0x10,%esp
}
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801501:	f3 0f 1e fb          	endbr32 
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	56                   	push   %esi
  801509:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80150a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80150d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801513:	e8 04 ec ff ff       	call   80011c <sys_getenvid>
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	ff 75 0c             	pushl  0xc(%ebp)
  80151e:	ff 75 08             	pushl  0x8(%ebp)
  801521:	56                   	push   %esi
  801522:	50                   	push   %eax
  801523:	68 f4 24 80 00       	push   $0x8024f4
  801528:	e8 bb 00 00 00       	call   8015e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80152d:	83 c4 18             	add    $0x18,%esp
  801530:	53                   	push   %ebx
  801531:	ff 75 10             	pushl  0x10(%ebp)
  801534:	e8 5a 00 00 00       	call   801593 <vcprintf>
	cprintf("\n");
  801539:	c7 04 24 e0 24 80 00 	movl   $0x8024e0,(%esp)
  801540:	e8 a3 00 00 00       	call   8015e8 <cprintf>
  801545:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801548:	cc                   	int3   
  801549:	eb fd                	jmp    801548 <_panic+0x47>

0080154b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80154b:	f3 0f 1e fb          	endbr32 
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801559:	8b 13                	mov    (%ebx),%edx
  80155b:	8d 42 01             	lea    0x1(%edx),%eax
  80155e:	89 03                	mov    %eax,(%ebx)
  801560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801563:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801567:	3d ff 00 00 00       	cmp    $0xff,%eax
  80156c:	74 09                	je     801577 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80156e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801575:	c9                   	leave  
  801576:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	68 ff 00 00 00       	push   $0xff
  80157f:	8d 43 08             	lea    0x8(%ebx),%eax
  801582:	50                   	push   %eax
  801583:	e8 2b eb ff ff       	call   8000b3 <sys_cputs>
		b->idx = 0;
  801588:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	eb db                	jmp    80156e <putch+0x23>

00801593 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801593:	f3 0f 1e fb          	endbr32 
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015a7:	00 00 00 
	b.cnt = 0;
  8015aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	ff 75 08             	pushl  0x8(%ebp)
  8015ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	68 4b 15 80 00       	push   $0x80154b
  8015c6:	e8 20 01 00 00       	call   8016eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	e8 d3 ea ff ff       	call   8000b3 <sys_cputs>

	return b.cnt;
}
  8015e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015e8:	f3 0f 1e fb          	endbr32 
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015f5:	50                   	push   %eax
  8015f6:	ff 75 08             	pushl  0x8(%ebp)
  8015f9:	e8 95 ff ff ff       	call   801593 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	57                   	push   %edi
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
  801606:	83 ec 1c             	sub    $0x1c,%esp
  801609:	89 c7                	mov    %eax,%edi
  80160b:	89 d6                	mov    %edx,%esi
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	8b 55 0c             	mov    0xc(%ebp),%edx
  801613:	89 d1                	mov    %edx,%ecx
  801615:	89 c2                	mov    %eax,%edx
  801617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80161a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80161d:	8b 45 10             	mov    0x10(%ebp),%eax
  801620:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  801623:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801626:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80162d:	39 c2                	cmp    %eax,%edx
  80162f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801632:	72 3e                	jb     801672 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801634:	83 ec 0c             	sub    $0xc,%esp
  801637:	ff 75 18             	pushl  0x18(%ebp)
  80163a:	83 eb 01             	sub    $0x1,%ebx
  80163d:	53                   	push   %ebx
  80163e:	50                   	push   %eax
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	ff 75 e4             	pushl  -0x1c(%ebp)
  801645:	ff 75 e0             	pushl  -0x20(%ebp)
  801648:	ff 75 dc             	pushl  -0x24(%ebp)
  80164b:	ff 75 d8             	pushl  -0x28(%ebp)
  80164e:	e8 9d 0a 00 00       	call   8020f0 <__udivdi3>
  801653:	83 c4 18             	add    $0x18,%esp
  801656:	52                   	push   %edx
  801657:	50                   	push   %eax
  801658:	89 f2                	mov    %esi,%edx
  80165a:	89 f8                	mov    %edi,%eax
  80165c:	e8 9f ff ff ff       	call   801600 <printnum>
  801661:	83 c4 20             	add    $0x20,%esp
  801664:	eb 13                	jmp    801679 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	56                   	push   %esi
  80166a:	ff 75 18             	pushl  0x18(%ebp)
  80166d:	ff d7                	call   *%edi
  80166f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801672:	83 eb 01             	sub    $0x1,%ebx
  801675:	85 db                	test   %ebx,%ebx
  801677:	7f ed                	jg     801666 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	56                   	push   %esi
  80167d:	83 ec 04             	sub    $0x4,%esp
  801680:	ff 75 e4             	pushl  -0x1c(%ebp)
  801683:	ff 75 e0             	pushl  -0x20(%ebp)
  801686:	ff 75 dc             	pushl  -0x24(%ebp)
  801689:	ff 75 d8             	pushl  -0x28(%ebp)
  80168c:	e8 6f 0b 00 00       	call   802200 <__umoddi3>
  801691:	83 c4 14             	add    $0x14,%esp
  801694:	0f be 80 17 25 80 00 	movsbl 0x802517(%eax),%eax
  80169b:	50                   	push   %eax
  80169c:	ff d7                	call   *%edi
}
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5f                   	pop    %edi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016a9:	f3 0f 1e fb          	endbr32 
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016b7:	8b 10                	mov    (%eax),%edx
  8016b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8016bc:	73 0a                	jae    8016c8 <sprintputch+0x1f>
		*b->buf++ = ch;
  8016be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016c1:	89 08                	mov    %ecx,(%eax)
  8016c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c6:	88 02                	mov    %al,(%edx)
}
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <printfmt>:
{
  8016ca:	f3 0f 1e fb          	endbr32 
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016d7:	50                   	push   %eax
  8016d8:	ff 75 10             	pushl  0x10(%ebp)
  8016db:	ff 75 0c             	pushl  0xc(%ebp)
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 05 00 00 00       	call   8016eb <vprintfmt>
}
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <vprintfmt>:
{
  8016eb:	f3 0f 1e fb          	endbr32 
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	57                   	push   %edi
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 3c             	sub    $0x3c,%esp
  8016f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801701:	e9 8e 03 00 00       	jmp    801a94 <vprintfmt+0x3a9>
		padc = ' ';
  801706:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80170a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801711:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801718:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80171f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801724:	8d 47 01             	lea    0x1(%edi),%eax
  801727:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80172a:	0f b6 17             	movzbl (%edi),%edx
  80172d:	8d 42 dd             	lea    -0x23(%edx),%eax
  801730:	3c 55                	cmp    $0x55,%al
  801732:	0f 87 df 03 00 00    	ja     801b17 <vprintfmt+0x42c>
  801738:	0f b6 c0             	movzbl %al,%eax
  80173b:	3e ff 24 85 60 26 80 	notrack jmp *0x802660(,%eax,4)
  801742:	00 
  801743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801746:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80174a:	eb d8                	jmp    801724 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80174c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80174f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801753:	eb cf                	jmp    801724 <vprintfmt+0x39>
  801755:	0f b6 d2             	movzbl %dl,%edx
  801758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80175b:	b8 00 00 00 00       	mov    $0x0,%eax
  801760:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801763:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801766:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80176a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80176d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801770:	83 f9 09             	cmp    $0x9,%ecx
  801773:	77 55                	ja     8017ca <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  801775:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  801778:	eb e9                	jmp    801763 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80177a:	8b 45 14             	mov    0x14(%ebp),%eax
  80177d:	8b 00                	mov    (%eax),%eax
  80177f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801782:	8b 45 14             	mov    0x14(%ebp),%eax
  801785:	8d 40 04             	lea    0x4(%eax),%eax
  801788:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80178b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80178e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801792:	79 90                	jns    801724 <vprintfmt+0x39>
				width = precision, precision = -1;
  801794:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801797:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80179a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8017a1:	eb 81                	jmp    801724 <vprintfmt+0x39>
  8017a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	0f 49 d0             	cmovns %eax,%edx
  8017b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017b6:	e9 69 ff ff ff       	jmp    801724 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017be:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017c5:	e9 5a ff ff ff       	jmp    801724 <vprintfmt+0x39>
  8017ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017d0:	eb bc                	jmp    80178e <vprintfmt+0xa3>
			lflag++;
  8017d2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017d8:	e9 47 ff ff ff       	jmp    801724 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8017dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e0:	8d 78 04             	lea    0x4(%eax),%edi
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	53                   	push   %ebx
  8017e7:	ff 30                	pushl  (%eax)
  8017e9:	ff d6                	call   *%esi
			break;
  8017eb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017ee:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017f1:	e9 9b 02 00 00       	jmp    801a91 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8017f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f9:	8d 78 04             	lea    0x4(%eax),%edi
  8017fc:	8b 00                	mov    (%eax),%eax
  8017fe:	99                   	cltd   
  8017ff:	31 d0                	xor    %edx,%eax
  801801:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801803:	83 f8 0f             	cmp    $0xf,%eax
  801806:	7f 23                	jg     80182b <vprintfmt+0x140>
  801808:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  80180f:	85 d2                	test   %edx,%edx
  801811:	74 18                	je     80182b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  801813:	52                   	push   %edx
  801814:	68 15 24 80 00       	push   $0x802415
  801819:	53                   	push   %ebx
  80181a:	56                   	push   %esi
  80181b:	e8 aa fe ff ff       	call   8016ca <printfmt>
  801820:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801823:	89 7d 14             	mov    %edi,0x14(%ebp)
  801826:	e9 66 02 00 00       	jmp    801a91 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80182b:	50                   	push   %eax
  80182c:	68 2f 25 80 00       	push   $0x80252f
  801831:	53                   	push   %ebx
  801832:	56                   	push   %esi
  801833:	e8 92 fe ff ff       	call   8016ca <printfmt>
  801838:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80183b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80183e:	e9 4e 02 00 00       	jmp    801a91 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  801843:	8b 45 14             	mov    0x14(%ebp),%eax
  801846:	83 c0 04             	add    $0x4,%eax
  801849:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80184c:	8b 45 14             	mov    0x14(%ebp),%eax
  80184f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801851:	85 d2                	test   %edx,%edx
  801853:	b8 28 25 80 00       	mov    $0x802528,%eax
  801858:	0f 45 c2             	cmovne %edx,%eax
  80185b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80185e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801862:	7e 06                	jle    80186a <vprintfmt+0x17f>
  801864:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801868:	75 0d                	jne    801877 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80186a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80186d:	89 c7                	mov    %eax,%edi
  80186f:	03 45 e0             	add    -0x20(%ebp),%eax
  801872:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801875:	eb 55                	jmp    8018cc <vprintfmt+0x1e1>
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	ff 75 d8             	pushl  -0x28(%ebp)
  80187d:	ff 75 cc             	pushl  -0x34(%ebp)
  801880:	e8 46 03 00 00       	call   801bcb <strnlen>
  801885:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801888:	29 c2                	sub    %eax,%edx
  80188a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  801892:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801896:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801899:	85 ff                	test   %edi,%edi
  80189b:	7e 11                	jle    8018ae <vprintfmt+0x1c3>
					putch(padc, putdat);
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	53                   	push   %ebx
  8018a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8018a4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a6:	83 ef 01             	sub    $0x1,%edi
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	eb eb                	jmp    801899 <vprintfmt+0x1ae>
  8018ae:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018b1:	85 d2                	test   %edx,%edx
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b8:	0f 49 c2             	cmovns %edx,%eax
  8018bb:	29 c2                	sub    %eax,%edx
  8018bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018c0:	eb a8                	jmp    80186a <vprintfmt+0x17f>
					putch(ch, putdat);
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	53                   	push   %ebx
  8018c6:	52                   	push   %edx
  8018c7:	ff d6                	call   *%esi
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018cf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d1:	83 c7 01             	add    $0x1,%edi
  8018d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018d8:	0f be d0             	movsbl %al,%edx
  8018db:	85 d2                	test   %edx,%edx
  8018dd:	74 4b                	je     80192a <vprintfmt+0x23f>
  8018df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018e3:	78 06                	js     8018eb <vprintfmt+0x200>
  8018e5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018e9:	78 1e                	js     801909 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8018eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018ef:	74 d1                	je     8018c2 <vprintfmt+0x1d7>
  8018f1:	0f be c0             	movsbl %al,%eax
  8018f4:	83 e8 20             	sub    $0x20,%eax
  8018f7:	83 f8 5e             	cmp    $0x5e,%eax
  8018fa:	76 c6                	jbe    8018c2 <vprintfmt+0x1d7>
					putch('?', putdat);
  8018fc:	83 ec 08             	sub    $0x8,%esp
  8018ff:	53                   	push   %ebx
  801900:	6a 3f                	push   $0x3f
  801902:	ff d6                	call   *%esi
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb c3                	jmp    8018cc <vprintfmt+0x1e1>
  801909:	89 cf                	mov    %ecx,%edi
  80190b:	eb 0e                	jmp    80191b <vprintfmt+0x230>
				putch(' ', putdat);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	53                   	push   %ebx
  801911:	6a 20                	push   $0x20
  801913:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801915:	83 ef 01             	sub    $0x1,%edi
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	85 ff                	test   %edi,%edi
  80191d:	7f ee                	jg     80190d <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80191f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801922:	89 45 14             	mov    %eax,0x14(%ebp)
  801925:	e9 67 01 00 00       	jmp    801a91 <vprintfmt+0x3a6>
  80192a:	89 cf                	mov    %ecx,%edi
  80192c:	eb ed                	jmp    80191b <vprintfmt+0x230>
	if (lflag >= 2)
  80192e:	83 f9 01             	cmp    $0x1,%ecx
  801931:	7f 1b                	jg     80194e <vprintfmt+0x263>
	else if (lflag)
  801933:	85 c9                	test   %ecx,%ecx
  801935:	74 63                	je     80199a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  801937:	8b 45 14             	mov    0x14(%ebp),%eax
  80193a:	8b 00                	mov    (%eax),%eax
  80193c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80193f:	99                   	cltd   
  801940:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801943:	8b 45 14             	mov    0x14(%ebp),%eax
  801946:	8d 40 04             	lea    0x4(%eax),%eax
  801949:	89 45 14             	mov    %eax,0x14(%ebp)
  80194c:	eb 17                	jmp    801965 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80194e:	8b 45 14             	mov    0x14(%ebp),%eax
  801951:	8b 50 04             	mov    0x4(%eax),%edx
  801954:	8b 00                	mov    (%eax),%eax
  801956:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801959:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195c:	8b 45 14             	mov    0x14(%ebp),%eax
  80195f:	8d 40 08             	lea    0x8(%eax),%eax
  801962:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801965:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801968:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80196b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  801970:	85 c9                	test   %ecx,%ecx
  801972:	0f 89 ff 00 00 00    	jns    801a77 <vprintfmt+0x38c>
				putch('-', putdat);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	53                   	push   %ebx
  80197c:	6a 2d                	push   $0x2d
  80197e:	ff d6                	call   *%esi
				num = -(long long) num;
  801980:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801983:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801986:	f7 da                	neg    %edx
  801988:	83 d1 00             	adc    $0x0,%ecx
  80198b:	f7 d9                	neg    %ecx
  80198d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801990:	b8 0a 00 00 00       	mov    $0xa,%eax
  801995:	e9 dd 00 00 00       	jmp    801a77 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80199a:	8b 45 14             	mov    0x14(%ebp),%eax
  80199d:	8b 00                	mov    (%eax),%eax
  80199f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a2:	99                   	cltd   
  8019a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a9:	8d 40 04             	lea    0x4(%eax),%eax
  8019ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8019af:	eb b4                	jmp    801965 <vprintfmt+0x27a>
	if (lflag >= 2)
  8019b1:	83 f9 01             	cmp    $0x1,%ecx
  8019b4:	7f 1e                	jg     8019d4 <vprintfmt+0x2e9>
	else if (lflag)
  8019b6:	85 c9                	test   %ecx,%ecx
  8019b8:	74 32                	je     8019ec <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8019ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bd:	8b 10                	mov    (%eax),%edx
  8019bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c4:	8d 40 04             	lea    0x4(%eax),%eax
  8019c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019ca:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8019cf:	e9 a3 00 00 00       	jmp    801a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8019d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d7:	8b 10                	mov    (%eax),%edx
  8019d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8019dc:	8d 40 08             	lea    0x8(%eax),%eax
  8019df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019e2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8019e7:	e9 8b 00 00 00       	jmp    801a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8019ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ef:	8b 10                	mov    (%eax),%edx
  8019f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f6:	8d 40 04             	lea    0x4(%eax),%eax
  8019f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019fc:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  801a01:	eb 74                	jmp    801a77 <vprintfmt+0x38c>
	if (lflag >= 2)
  801a03:	83 f9 01             	cmp    $0x1,%ecx
  801a06:	7f 1b                	jg     801a23 <vprintfmt+0x338>
	else if (lflag)
  801a08:	85 c9                	test   %ecx,%ecx
  801a0a:	74 2c                	je     801a38 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  801a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0f:	8b 10                	mov    (%eax),%edx
  801a11:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a16:	8d 40 04             	lea    0x4(%eax),%eax
  801a19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a1c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  801a21:	eb 54                	jmp    801a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801a23:	8b 45 14             	mov    0x14(%ebp),%eax
  801a26:	8b 10                	mov    (%eax),%edx
  801a28:	8b 48 04             	mov    0x4(%eax),%ecx
  801a2b:	8d 40 08             	lea    0x8(%eax),%eax
  801a2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a31:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  801a36:	eb 3f                	jmp    801a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	8b 10                	mov    (%eax),%edx
  801a3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a42:	8d 40 04             	lea    0x4(%eax),%eax
  801a45:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  801a48:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  801a4d:	eb 28                	jmp    801a77 <vprintfmt+0x38c>
			putch('0', putdat);
  801a4f:	83 ec 08             	sub    $0x8,%esp
  801a52:	53                   	push   %ebx
  801a53:	6a 30                	push   $0x30
  801a55:	ff d6                	call   *%esi
			putch('x', putdat);
  801a57:	83 c4 08             	add    $0x8,%esp
  801a5a:	53                   	push   %ebx
  801a5b:	6a 78                	push   $0x78
  801a5d:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a62:	8b 10                	mov    (%eax),%edx
  801a64:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a69:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a6c:	8d 40 04             	lea    0x4(%eax),%eax
  801a6f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a72:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801a7e:	57                   	push   %edi
  801a7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a82:	50                   	push   %eax
  801a83:	51                   	push   %ecx
  801a84:	52                   	push   %edx
  801a85:	89 da                	mov    %ebx,%edx
  801a87:	89 f0                	mov    %esi,%eax
  801a89:	e8 72 fb ff ff       	call   801600 <printnum>
			break;
  801a8e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  801a91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  801a94:	83 c7 01             	add    $0x1,%edi
  801a97:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a9b:	83 f8 25             	cmp    $0x25,%eax
  801a9e:	0f 84 62 fc ff ff    	je     801706 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	0f 84 8b 00 00 00    	je     801b37 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	53                   	push   %ebx
  801ab0:	50                   	push   %eax
  801ab1:	ff d6                	call   *%esi
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	eb dc                	jmp    801a94 <vprintfmt+0x3a9>
	if (lflag >= 2)
  801ab8:	83 f9 01             	cmp    $0x1,%ecx
  801abb:	7f 1b                	jg     801ad8 <vprintfmt+0x3ed>
	else if (lflag)
  801abd:	85 c9                	test   %ecx,%ecx
  801abf:	74 2c                	je     801aed <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  801ac1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac4:	8b 10                	mov    (%eax),%edx
  801ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  801acb:	8d 40 04             	lea    0x4(%eax),%eax
  801ace:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ad1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  801ad6:	eb 9f                	jmp    801a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  801ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  801adb:	8b 10                	mov    (%eax),%edx
  801add:	8b 48 04             	mov    0x4(%eax),%ecx
  801ae0:	8d 40 08             	lea    0x8(%eax),%eax
  801ae3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ae6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  801aeb:	eb 8a                	jmp    801a77 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  801aed:	8b 45 14             	mov    0x14(%ebp),%eax
  801af0:	8b 10                	mov    (%eax),%edx
  801af2:	b9 00 00 00 00       	mov    $0x0,%ecx
  801af7:	8d 40 04             	lea    0x4(%eax),%eax
  801afa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801afd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  801b02:	e9 70 ff ff ff       	jmp    801a77 <vprintfmt+0x38c>
			putch(ch, putdat);
  801b07:	83 ec 08             	sub    $0x8,%esp
  801b0a:	53                   	push   %ebx
  801b0b:	6a 25                	push   $0x25
  801b0d:	ff d6                	call   *%esi
			break;
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	e9 7a ff ff ff       	jmp    801a91 <vprintfmt+0x3a6>
			putch('%', putdat);
  801b17:	83 ec 08             	sub    $0x8,%esp
  801b1a:	53                   	push   %ebx
  801b1b:	6a 25                	push   $0x25
  801b1d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	89 f8                	mov    %edi,%eax
  801b24:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801b28:	74 05                	je     801b2f <vprintfmt+0x444>
  801b2a:	83 e8 01             	sub    $0x1,%eax
  801b2d:	eb f5                	jmp    801b24 <vprintfmt+0x439>
  801b2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b32:	e9 5a ff ff ff       	jmp    801a91 <vprintfmt+0x3a6>
}
  801b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5f                   	pop    %edi
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b3f:	f3 0f 1e fb          	endbr32 
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 18             	sub    $0x18,%esp
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b52:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b56:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b60:	85 c0                	test   %eax,%eax
  801b62:	74 26                	je     801b8a <vsnprintf+0x4b>
  801b64:	85 d2                	test   %edx,%edx
  801b66:	7e 22                	jle    801b8a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b68:	ff 75 14             	pushl  0x14(%ebp)
  801b6b:	ff 75 10             	pushl  0x10(%ebp)
  801b6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b71:	50                   	push   %eax
  801b72:	68 a9 16 80 00       	push   $0x8016a9
  801b77:	e8 6f fb ff ff       	call   8016eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b85:	83 c4 10             	add    $0x10,%esp
}
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    
		return -E_INVAL;
  801b8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b8f:	eb f7                	jmp    801b88 <vsnprintf+0x49>

00801b91 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b91:	f3 0f 1e fb          	endbr32 
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  801b9b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b9e:	50                   	push   %eax
  801b9f:	ff 75 10             	pushl  0x10(%ebp)
  801ba2:	ff 75 0c             	pushl  0xc(%ebp)
  801ba5:	ff 75 08             	pushl  0x8(%ebp)
  801ba8:	e8 92 ff ff ff       	call   801b3f <vsnprintf>
	va_end(ap);

	return rc;
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801baf:	f3 0f 1e fb          	endbr32 
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bc2:	74 05                	je     801bc9 <strlen+0x1a>
		n++;
  801bc4:	83 c0 01             	add    $0x1,%eax
  801bc7:	eb f5                	jmp    801bbe <strlen+0xf>
	return n;
}
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bcb:	f3 0f 1e fb          	endbr32 
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdd:	39 d0                	cmp    %edx,%eax
  801bdf:	74 0d                	je     801bee <strnlen+0x23>
  801be1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801be5:	74 05                	je     801bec <strnlen+0x21>
		n++;
  801be7:	83 c0 01             	add    $0x1,%eax
  801bea:	eb f1                	jmp    801bdd <strnlen+0x12>
  801bec:	89 c2                	mov    %eax,%edx
	return n;
}
  801bee:	89 d0                	mov    %edx,%eax
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bf2:	f3 0f 1e fb          	endbr32 
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	53                   	push   %ebx
  801bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
  801c05:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801c09:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801c0c:	83 c0 01             	add    $0x1,%eax
  801c0f:	84 d2                	test   %dl,%dl
  801c11:	75 f2                	jne    801c05 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801c13:	89 c8                	mov    %ecx,%eax
  801c15:	5b                   	pop    %ebx
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c18:	f3 0f 1e fb          	endbr32 
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	53                   	push   %ebx
  801c20:	83 ec 10             	sub    $0x10,%esp
  801c23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c26:	53                   	push   %ebx
  801c27:	e8 83 ff ff ff       	call   801baf <strlen>
  801c2c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801c2f:	ff 75 0c             	pushl  0xc(%ebp)
  801c32:	01 d8                	add    %ebx,%eax
  801c34:	50                   	push   %eax
  801c35:	e8 b8 ff ff ff       	call   801bf2 <strcpy>
	return dst;
}
  801c3a:	89 d8                	mov    %ebx,%eax
  801c3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c41:	f3 0f 1e fb          	endbr32 
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	56                   	push   %esi
  801c49:	53                   	push   %ebx
  801c4a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c50:	89 f3                	mov    %esi,%ebx
  801c52:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c55:	89 f0                	mov    %esi,%eax
  801c57:	39 d8                	cmp    %ebx,%eax
  801c59:	74 11                	je     801c6c <strncpy+0x2b>
		*dst++ = *src;
  801c5b:	83 c0 01             	add    $0x1,%eax
  801c5e:	0f b6 0a             	movzbl (%edx),%ecx
  801c61:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c64:	80 f9 01             	cmp    $0x1,%cl
  801c67:	83 da ff             	sbb    $0xffffffff,%edx
  801c6a:	eb eb                	jmp    801c57 <strncpy+0x16>
	}
	return ret;
}
  801c6c:	89 f0                	mov    %esi,%eax
  801c6e:	5b                   	pop    %ebx
  801c6f:	5e                   	pop    %esi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c72:	f3 0f 1e fb          	endbr32 
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c81:	8b 55 10             	mov    0x10(%ebp),%edx
  801c84:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c86:	85 d2                	test   %edx,%edx
  801c88:	74 21                	je     801cab <strlcpy+0x39>
  801c8a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c8e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801c90:	39 c2                	cmp    %eax,%edx
  801c92:	74 14                	je     801ca8 <strlcpy+0x36>
  801c94:	0f b6 19             	movzbl (%ecx),%ebx
  801c97:	84 db                	test   %bl,%bl
  801c99:	74 0b                	je     801ca6 <strlcpy+0x34>
			*dst++ = *src++;
  801c9b:	83 c1 01             	add    $0x1,%ecx
  801c9e:	83 c2 01             	add    $0x1,%edx
  801ca1:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ca4:	eb ea                	jmp    801c90 <strlcpy+0x1e>
  801ca6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801ca8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cab:	29 f0                	sub    %esi,%eax
}
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cb1:	f3 0f 1e fb          	endbr32 
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cbe:	0f b6 01             	movzbl (%ecx),%eax
  801cc1:	84 c0                	test   %al,%al
  801cc3:	74 0c                	je     801cd1 <strcmp+0x20>
  801cc5:	3a 02                	cmp    (%edx),%al
  801cc7:	75 08                	jne    801cd1 <strcmp+0x20>
		p++, q++;
  801cc9:	83 c1 01             	add    $0x1,%ecx
  801ccc:	83 c2 01             	add    $0x1,%edx
  801ccf:	eb ed                	jmp    801cbe <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd1:	0f b6 c0             	movzbl %al,%eax
  801cd4:	0f b6 12             	movzbl (%edx),%edx
  801cd7:	29 d0                	sub    %edx,%eax
}
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cdb:	f3 0f 1e fb          	endbr32 
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	53                   	push   %ebx
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce9:	89 c3                	mov    %eax,%ebx
  801ceb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cee:	eb 06                	jmp    801cf6 <strncmp+0x1b>
		n--, p++, q++;
  801cf0:	83 c0 01             	add    $0x1,%eax
  801cf3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801cf6:	39 d8                	cmp    %ebx,%eax
  801cf8:	74 16                	je     801d10 <strncmp+0x35>
  801cfa:	0f b6 08             	movzbl (%eax),%ecx
  801cfd:	84 c9                	test   %cl,%cl
  801cff:	74 04                	je     801d05 <strncmp+0x2a>
  801d01:	3a 0a                	cmp    (%edx),%cl
  801d03:	74 eb                	je     801cf0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d05:	0f b6 00             	movzbl (%eax),%eax
  801d08:	0f b6 12             	movzbl (%edx),%edx
  801d0b:	29 d0                	sub    %edx,%eax
}
  801d0d:	5b                   	pop    %ebx
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    
		return 0;
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
  801d15:	eb f6                	jmp    801d0d <strncmp+0x32>

00801d17 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d17:	f3 0f 1e fb          	endbr32 
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d25:	0f b6 10             	movzbl (%eax),%edx
  801d28:	84 d2                	test   %dl,%dl
  801d2a:	74 09                	je     801d35 <strchr+0x1e>
		if (*s == c)
  801d2c:	38 ca                	cmp    %cl,%dl
  801d2e:	74 0a                	je     801d3a <strchr+0x23>
	for (; *s; s++)
  801d30:	83 c0 01             	add    $0x1,%eax
  801d33:	eb f0                	jmp    801d25 <strchr+0xe>
			return (char *) s;
	return 0;
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  801d3c:	f3 0f 1e fb          	endbr32 
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  801d46:	6a 78                	push   $0x78
  801d48:	ff 75 08             	pushl  0x8(%ebp)
  801d4b:	e8 c7 ff ff ff       	call   801d17 <strchr>
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  801d5b:	eb 0d                	jmp    801d6a <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  801d5d:	c1 e0 04             	shl    $0x4,%eax
  801d60:	0f be d2             	movsbl %dl,%edx
  801d63:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  801d67:	83 c1 01             	add    $0x1,%ecx
  801d6a:	0f b6 11             	movzbl (%ecx),%edx
  801d6d:	84 d2                	test   %dl,%dl
  801d6f:	74 11                	je     801d82 <atox+0x46>
		if (*p>='a'){
  801d71:	80 fa 60             	cmp    $0x60,%dl
  801d74:	7e e7                	jle    801d5d <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  801d76:	c1 e0 04             	shl    $0x4,%eax
  801d79:	0f be d2             	movsbl %dl,%edx
  801d7c:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  801d80:	eb e5                	jmp    801d67 <atox+0x2b>
	}

	return v;

}
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d84:	f3 0f 1e fb          	endbr32 
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d95:	38 ca                	cmp    %cl,%dl
  801d97:	74 09                	je     801da2 <strfind+0x1e>
  801d99:	84 d2                	test   %dl,%dl
  801d9b:	74 05                	je     801da2 <strfind+0x1e>
	for (; *s; s++)
  801d9d:	83 c0 01             	add    $0x1,%eax
  801da0:	eb f0                	jmp    801d92 <strfind+0xe>
			break;
	return (char *) s;
}
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801da4:	f3 0f 1e fb          	endbr32 
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	57                   	push   %edi
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	8b 7d 08             	mov    0x8(%ebp),%edi
  801db1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801db4:	85 c9                	test   %ecx,%ecx
  801db6:	74 31                	je     801de9 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801db8:	89 f8                	mov    %edi,%eax
  801dba:	09 c8                	or     %ecx,%eax
  801dbc:	a8 03                	test   $0x3,%al
  801dbe:	75 23                	jne    801de3 <memset+0x3f>
		c &= 0xFF;
  801dc0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801dc4:	89 d3                	mov    %edx,%ebx
  801dc6:	c1 e3 08             	shl    $0x8,%ebx
  801dc9:	89 d0                	mov    %edx,%eax
  801dcb:	c1 e0 18             	shl    $0x18,%eax
  801dce:	89 d6                	mov    %edx,%esi
  801dd0:	c1 e6 10             	shl    $0x10,%esi
  801dd3:	09 f0                	or     %esi,%eax
  801dd5:	09 c2                	or     %eax,%edx
  801dd7:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801dd9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801ddc:	89 d0                	mov    %edx,%eax
  801dde:	fc                   	cld    
  801ddf:	f3 ab                	rep stos %eax,%es:(%edi)
  801de1:	eb 06                	jmp    801de9 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801de3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de6:	fc                   	cld    
  801de7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801de9:	89 f8                	mov    %edi,%eax
  801deb:	5b                   	pop    %ebx
  801dec:	5e                   	pop    %esi
  801ded:	5f                   	pop    %edi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801df0:	f3 0f 1e fb          	endbr32 
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	57                   	push   %edi
  801df8:	56                   	push   %esi
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e02:	39 c6                	cmp    %eax,%esi
  801e04:	73 32                	jae    801e38 <memmove+0x48>
  801e06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e09:	39 c2                	cmp    %eax,%edx
  801e0b:	76 2b                	jbe    801e38 <memmove+0x48>
		s += n;
		d += n;
  801e0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e10:	89 fe                	mov    %edi,%esi
  801e12:	09 ce                	or     %ecx,%esi
  801e14:	09 d6                	or     %edx,%esi
  801e16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e1c:	75 0e                	jne    801e2c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e1e:	83 ef 04             	sub    $0x4,%edi
  801e21:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e24:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801e27:	fd                   	std    
  801e28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e2a:	eb 09                	jmp    801e35 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e2c:	83 ef 01             	sub    $0x1,%edi
  801e2f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801e32:	fd                   	std    
  801e33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e35:	fc                   	cld    
  801e36:	eb 1a                	jmp    801e52 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e38:	89 c2                	mov    %eax,%edx
  801e3a:	09 ca                	or     %ecx,%edx
  801e3c:	09 f2                	or     %esi,%edx
  801e3e:	f6 c2 03             	test   $0x3,%dl
  801e41:	75 0a                	jne    801e4d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e43:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801e46:	89 c7                	mov    %eax,%edi
  801e48:	fc                   	cld    
  801e49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e4b:	eb 05                	jmp    801e52 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  801e4d:	89 c7                	mov    %eax,%edi
  801e4f:	fc                   	cld    
  801e50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e52:	5e                   	pop    %esi
  801e53:	5f                   	pop    %edi
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    

00801e56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e56:	f3 0f 1e fb          	endbr32 
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e60:	ff 75 10             	pushl  0x10(%ebp)
  801e63:	ff 75 0c             	pushl  0xc(%ebp)
  801e66:	ff 75 08             	pushl  0x8(%ebp)
  801e69:	e8 82 ff ff ff       	call   801df0 <memmove>
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e70:	f3 0f 1e fb          	endbr32 
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	56                   	push   %esi
  801e78:	53                   	push   %ebx
  801e79:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7f:	89 c6                	mov    %eax,%esi
  801e81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e84:	39 f0                	cmp    %esi,%eax
  801e86:	74 1c                	je     801ea4 <memcmp+0x34>
		if (*s1 != *s2)
  801e88:	0f b6 08             	movzbl (%eax),%ecx
  801e8b:	0f b6 1a             	movzbl (%edx),%ebx
  801e8e:	38 d9                	cmp    %bl,%cl
  801e90:	75 08                	jne    801e9a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801e92:	83 c0 01             	add    $0x1,%eax
  801e95:	83 c2 01             	add    $0x1,%edx
  801e98:	eb ea                	jmp    801e84 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801e9a:	0f b6 c1             	movzbl %cl,%eax
  801e9d:	0f b6 db             	movzbl %bl,%ebx
  801ea0:	29 d8                	sub    %ebx,%eax
  801ea2:	eb 05                	jmp    801ea9 <memcmp+0x39>
	}

	return 0;
  801ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ead:	f3 0f 1e fb          	endbr32 
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801eba:	89 c2                	mov    %eax,%edx
  801ebc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ebf:	39 d0                	cmp    %edx,%eax
  801ec1:	73 09                	jae    801ecc <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ec3:	38 08                	cmp    %cl,(%eax)
  801ec5:	74 05                	je     801ecc <memfind+0x1f>
	for (; s < ends; s++)
  801ec7:	83 c0 01             	add    $0x1,%eax
  801eca:	eb f3                	jmp    801ebf <memfind+0x12>
			break;
	return (void *) s;
}
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ece:	f3 0f 1e fb          	endbr32 
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801edb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ede:	eb 03                	jmp    801ee3 <strtol+0x15>
		s++;
  801ee0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801ee3:	0f b6 01             	movzbl (%ecx),%eax
  801ee6:	3c 20                	cmp    $0x20,%al
  801ee8:	74 f6                	je     801ee0 <strtol+0x12>
  801eea:	3c 09                	cmp    $0x9,%al
  801eec:	74 f2                	je     801ee0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801eee:	3c 2b                	cmp    $0x2b,%al
  801ef0:	74 2a                	je     801f1c <strtol+0x4e>
	int neg = 0;
  801ef2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801ef7:	3c 2d                	cmp    $0x2d,%al
  801ef9:	74 2b                	je     801f26 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801efb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f01:	75 0f                	jne    801f12 <strtol+0x44>
  801f03:	80 39 30             	cmpb   $0x30,(%ecx)
  801f06:	74 28                	je     801f30 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f08:	85 db                	test   %ebx,%ebx
  801f0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801f0f:	0f 44 d8             	cmove  %eax,%ebx
  801f12:	b8 00 00 00 00       	mov    $0x0,%eax
  801f17:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801f1a:	eb 46                	jmp    801f62 <strtol+0x94>
		s++;
  801f1c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801f1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f24:	eb d5                	jmp    801efb <strtol+0x2d>
		s++, neg = 1;
  801f26:	83 c1 01             	add    $0x1,%ecx
  801f29:	bf 01 00 00 00       	mov    $0x1,%edi
  801f2e:	eb cb                	jmp    801efb <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f30:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f34:	74 0e                	je     801f44 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801f36:	85 db                	test   %ebx,%ebx
  801f38:	75 d8                	jne    801f12 <strtol+0x44>
		s++, base = 8;
  801f3a:	83 c1 01             	add    $0x1,%ecx
  801f3d:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f42:	eb ce                	jmp    801f12 <strtol+0x44>
		s += 2, base = 16;
  801f44:	83 c1 02             	add    $0x2,%ecx
  801f47:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f4c:	eb c4                	jmp    801f12 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801f4e:	0f be d2             	movsbl %dl,%edx
  801f51:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f54:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f57:	7d 3a                	jge    801f93 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801f59:	83 c1 01             	add    $0x1,%ecx
  801f5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f60:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801f62:	0f b6 11             	movzbl (%ecx),%edx
  801f65:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f68:	89 f3                	mov    %esi,%ebx
  801f6a:	80 fb 09             	cmp    $0x9,%bl
  801f6d:	76 df                	jbe    801f4e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801f6f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f72:	89 f3                	mov    %esi,%ebx
  801f74:	80 fb 19             	cmp    $0x19,%bl
  801f77:	77 08                	ja     801f81 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801f79:	0f be d2             	movsbl %dl,%edx
  801f7c:	83 ea 57             	sub    $0x57,%edx
  801f7f:	eb d3                	jmp    801f54 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801f81:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f84:	89 f3                	mov    %esi,%ebx
  801f86:	80 fb 19             	cmp    $0x19,%bl
  801f89:	77 08                	ja     801f93 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801f8b:	0f be d2             	movsbl %dl,%edx
  801f8e:	83 ea 37             	sub    $0x37,%edx
  801f91:	eb c1                	jmp    801f54 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801f93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f97:	74 05                	je     801f9e <strtol+0xd0>
		*endptr = (char *) s;
  801f99:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f9c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801f9e:	89 c2                	mov    %eax,%edx
  801fa0:	f7 da                	neg    %edx
  801fa2:	85 ff                	test   %edi,%edi
  801fa4:	0f 45 c2             	cmovne %edx,%eax
}
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fac:	f3 0f 1e fb          	endbr32 
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	56                   	push   %esi
  801fb4:	53                   	push   %ebx
  801fb5:	8b 75 08             	mov    0x8(%ebp),%esi
  801fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fc5:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fc8:	83 ec 0c             	sub    $0xc,%esp
  801fcb:	50                   	push   %eax
  801fcc:	e8 97 e2 ff ff       	call   800268 <sys_ipc_recv>
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	75 2b                	jne    802003 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fd8:	85 f6                	test   %esi,%esi
  801fda:	74 0a                	je     801fe6 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fdc:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe1:	8b 40 74             	mov    0x74(%eax),%eax
  801fe4:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fe6:	85 db                	test   %ebx,%ebx
  801fe8:	74 0a                	je     801ff4 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801fea:	a1 08 40 80 00       	mov    0x804008,%eax
  801fef:	8b 40 78             	mov    0x78(%eax),%eax
  801ff2:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801ff4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ffc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5d                   	pop    %ebp
  802002:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802003:	85 f6                	test   %esi,%esi
  802005:	74 06                	je     80200d <ipc_recv+0x61>
  802007:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80200d:	85 db                	test   %ebx,%ebx
  80200f:	74 eb                	je     801ffc <ipc_recv+0x50>
  802011:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802017:	eb e3                	jmp    801ffc <ipc_recv+0x50>

00802019 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802019:	f3 0f 1e fb          	endbr32 
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	57                   	push   %edi
  802021:	56                   	push   %esi
  802022:	53                   	push   %ebx
  802023:	83 ec 0c             	sub    $0xc,%esp
  802026:	8b 7d 08             	mov    0x8(%ebp),%edi
  802029:	8b 75 0c             	mov    0xc(%ebp),%esi
  80202c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80202f:	85 db                	test   %ebx,%ebx
  802031:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802036:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802039:	ff 75 14             	pushl  0x14(%ebp)
  80203c:	53                   	push   %ebx
  80203d:	56                   	push   %esi
  80203e:	57                   	push   %edi
  80203f:	e8 fd e1 ff ff       	call   800241 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80204a:	75 07                	jne    802053 <ipc_send+0x3a>
			sys_yield();
  80204c:	e8 ee e0 ff ff       	call   80013f <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802051:	eb e6                	jmp    802039 <ipc_send+0x20>
		}
		else if (ret == 0)
  802053:	85 c0                	test   %eax,%eax
  802055:	75 08                	jne    80205f <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802057:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205a:	5b                   	pop    %ebx
  80205b:	5e                   	pop    %esi
  80205c:	5f                   	pop    %edi
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80205f:	50                   	push   %eax
  802060:	68 1f 28 80 00       	push   $0x80281f
  802065:	6a 48                	push   $0x48
  802067:	68 2d 28 80 00       	push   $0x80282d
  80206c:	e8 90 f4 ff ff       	call   801501 <_panic>

00802071 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802071:	f3 0f 1e fb          	endbr32 
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802080:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802083:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802089:	8b 52 50             	mov    0x50(%edx),%edx
  80208c:	39 ca                	cmp    %ecx,%edx
  80208e:	74 11                	je     8020a1 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802090:	83 c0 01             	add    $0x1,%eax
  802093:	3d 00 04 00 00       	cmp    $0x400,%eax
  802098:	75 e6                	jne    802080 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
  80209f:	eb 0b                	jmp    8020ac <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020a9:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ae:	f3 0f 1e fb          	endbr32 
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b8:	89 c2                	mov    %eax,%edx
  8020ba:	c1 ea 16             	shr    $0x16,%edx
  8020bd:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020c4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020c9:	f6 c1 01             	test   $0x1,%cl
  8020cc:	74 1c                	je     8020ea <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020ce:	c1 e8 0c             	shr    $0xc,%eax
  8020d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020d8:	a8 01                	test   $0x1,%al
  8020da:	74 0e                	je     8020ea <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020dc:	c1 e8 0c             	shr    $0xc,%eax
  8020df:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020e6:	ef 
  8020e7:	0f b7 d2             	movzwl %dx,%edx
}
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    
  8020ee:	66 90                	xchg   %ax,%ax

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
