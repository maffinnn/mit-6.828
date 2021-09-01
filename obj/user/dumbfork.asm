
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 ad 01 00 00       	call   8001de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	6a 07                	push   $0x7
  800047:	53                   	push   %ebx
  800048:	56                   	push   %esi
  800049:	e8 52 0d 00 00       	call   800da0 <sys_page_alloc>
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	85 c0                	test   %eax,%eax
  800053:	78 4a                	js     80009f <duppage+0x6c>
		panic("sys_page_alloc: %e\n", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800055:	83 ec 0c             	sub    $0xc,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 40 00       	push   $0x400000
  80005f:	6a 00                	push   $0x0
  800061:	53                   	push   %ebx
  800062:	56                   	push   %esi
  800063:	e8 5e 0d 00 00       	call   800dc6 <sys_page_map>
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	78 42                	js     8000b1 <duppage+0x7e>
		panic("sys_page_map: %e\n", r);
	memmove(UTEMP, addr, PGSIZE);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	68 00 10 00 00       	push   $0x1000
  800077:	53                   	push   %ebx
  800078:	68 00 00 40 00       	push   $0x400000
  80007d:	e8 b3 0a 00 00       	call   800b35 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800082:	83 c4 08             	add    $0x8,%esp
  800085:	68 00 00 40 00       	push   $0x400000
  80008a:	6a 00                	push   $0x0
  80008c:	e8 5a 0d 00 00       	call   800deb <sys_page_unmap>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	78 2b                	js     8000c3 <duppage+0x90>
		panic("sys_page_unmap: %e\n", r);
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
		panic("sys_page_alloc: %e\n", r);
  80009f:	50                   	push   %eax
  8000a0:	68 00 25 80 00       	push   $0x802500
  8000a5:	6a 20                	push   $0x20
  8000a7:	68 14 25 80 00       	push   $0x802514
  8000ac:	e8 95 01 00 00       	call   800246 <_panic>
		panic("sys_page_map: %e\n", r);
  8000b1:	50                   	push   %eax
  8000b2:	68 24 25 80 00       	push   $0x802524
  8000b7:	6a 22                	push   $0x22
  8000b9:	68 14 25 80 00       	push   $0x802514
  8000be:	e8 83 01 00 00       	call   800246 <_panic>
		panic("sys_page_unmap: %e\n", r);
  8000c3:	50                   	push   %eax
  8000c4:	68 36 25 80 00       	push   $0x802536
  8000c9:	6a 25                	push   $0x25
  8000cb:	68 14 25 80 00       	push   $0x802514
  8000d0:	e8 71 01 00 00       	call   800246 <_panic>

008000d5 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d5:	f3 0f 1e fb          	endbr32 
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 10             	sub    $0x10,%esp
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8000e6:	cd 30                	int    $0x30
  8000e8:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	78 0d                	js     8000fb <dumbfork+0x26>
  8000ee:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e\n", envid);
	if (envid == 0) {
  8000f0:	74 1b                	je     80010d <dumbfork+0x38>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000f2:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f9:	eb 3f                	jmp    80013a <dumbfork+0x65>
		panic("sys_exofork: %e\n", envid);
  8000fb:	50                   	push   %eax
  8000fc:	68 4a 25 80 00       	push   $0x80254a
  800101:	6a 37                	push   $0x37
  800103:	68 14 25 80 00       	push   $0x802514
  800108:	e8 39 01 00 00       	call   800246 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 48 0c 00 00       	call   800d5a <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800124:	eb 43                	jmp    800169 <dumbfork+0x94>
		duppage(envid, addr);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	52                   	push   %edx
  80012a:	56                   	push   %esi
  80012b:	e8 03 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800130:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013d:	81 fa 00 70 80 00    	cmp    $0x807000,%edx
  800143:	72 e1                	jb     800126 <dumbfork+0x51>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800150:	50                   	push   %eax
  800151:	53                   	push   %ebx
  800152:	e8 dc fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800157:	83 c4 08             	add    $0x8,%esp
  80015a:	6a 02                	push   $0x2
  80015c:	53                   	push   %ebx
  80015d:	e8 ae 0c 00 00       	call   800e10 <sys_env_set_status>
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	85 c0                	test   %eax,%eax
  800167:	78 09                	js     800172 <dumbfork+0x9d>
		panic("sys_env_set_status: %e\n", r);

	return envid;
}
  800169:	89 d8                	mov    %ebx,%eax
  80016b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    
		panic("sys_env_set_status: %e\n", r);
  800172:	50                   	push   %eax
  800173:	68 5b 25 80 00       	push   $0x80255b
  800178:	6a 4c                	push   $0x4c
  80017a:	68 14 25 80 00       	push   $0x802514
  80017f:	e8 c2 00 00 00       	call   800246 <_panic>

00800184 <umain>:
{
  800184:	f3 0f 1e fb          	endbr32 
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	53                   	push   %ebx
  80018e:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800191:	e8 3f ff ff ff       	call   8000d5 <dumbfork>
  800196:	89 c6                	mov    %eax,%esi
  800198:	85 c0                	test   %eax,%eax
  80019a:	bf 73 25 80 00       	mov    $0x802573,%edi
  80019f:	b8 7a 25 80 00       	mov    $0x80257a,%eax
  8001a4:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ac:	eb 1f                	jmp    8001cd <umain+0x49>
  8001ae:	83 fb 13             	cmp    $0x13,%ebx
  8001b1:	7f 23                	jg     8001d6 <umain+0x52>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	57                   	push   %edi
  8001b7:	53                   	push   %ebx
  8001b8:	68 80 25 80 00       	push   $0x802580
  8001bd:	e8 6b 01 00 00       	call   80032d <cprintf>
		sys_yield();
  8001c2:	e8 b6 0b 00 00       	call   800d7d <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001c7:	83 c3 01             	add    $0x1,%ebx
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	85 f6                	test   %esi,%esi
  8001cf:	74 dd                	je     8001ae <umain+0x2a>
  8001d1:	83 fb 09             	cmp    $0x9,%ebx
  8001d4:	7e dd                	jle    8001b3 <umain+0x2f>
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    

008001de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001de:	f3 0f 1e fb          	endbr32 
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ea:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ed:	e8 68 0b 00 00       	call   800d5a <sys_getenvid>
  8001f2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ff:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800204:	85 db                	test   %ebx,%ebx
  800206:	7e 07                	jle    80020f <libmain+0x31>
		binaryname = argv[0];
  800208:	8b 06                	mov    (%esi),%eax
  80020a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	e8 6b ff ff ff       	call   800184 <umain>

	// exit gracefully
	exit();
  800219:	e8 0a 00 00 00       	call   800228 <exit>
}
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	f3 0f 1e fb          	endbr32 
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800232:	e8 f4 0e 00 00       	call   80112b <close_all>
	sys_env_destroy(0);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	6a 00                	push   $0x0
  80023c:	e8 f5 0a 00 00       	call   800d36 <sys_env_destroy>
}
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800246:	f3 0f 1e fb          	endbr32 
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80024f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800252:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800258:	e8 fd 0a 00 00       	call   800d5a <sys_getenvid>
  80025d:	83 ec 0c             	sub    $0xc,%esp
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	56                   	push   %esi
  800267:	50                   	push   %eax
  800268:	68 9c 25 80 00       	push   $0x80259c
  80026d:	e8 bb 00 00 00       	call   80032d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800272:	83 c4 18             	add    $0x18,%esp
  800275:	53                   	push   %ebx
  800276:	ff 75 10             	pushl  0x10(%ebp)
  800279:	e8 5a 00 00 00       	call   8002d8 <vcprintf>
	cprintf("\n");
  80027e:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  800285:	e8 a3 00 00 00       	call   80032d <cprintf>
  80028a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80028d:	cc                   	int3   
  80028e:	eb fd                	jmp    80028d <_panic+0x47>

00800290 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800290:	f3 0f 1e fb          	endbr32 
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	53                   	push   %ebx
  800298:	83 ec 04             	sub    $0x4,%esp
  80029b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80029e:	8b 13                	mov    (%ebx),%edx
  8002a0:	8d 42 01             	lea    0x1(%edx),%eax
  8002a3:	89 03                	mov    %eax,(%ebx)
  8002a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b1:	74 09                	je     8002bc <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	68 ff 00 00 00       	push   $0xff
  8002c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c7:	50                   	push   %eax
  8002c8:	e8 24 0a 00 00       	call   800cf1 <sys_cputs>
		b->idx = 0;
  8002cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d3:	83 c4 10             	add    $0x10,%esp
  8002d6:	eb db                	jmp    8002b3 <putch+0x23>

008002d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d8:	f3 0f 1e fb          	endbr32 
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ec:	00 00 00 
	b.cnt = 0;
  8002ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f9:	ff 75 0c             	pushl  0xc(%ebp)
  8002fc:	ff 75 08             	pushl  0x8(%ebp)
  8002ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800305:	50                   	push   %eax
  800306:	68 90 02 80 00       	push   $0x800290
  80030b:	e8 20 01 00 00       	call   800430 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800310:	83 c4 08             	add    $0x8,%esp
  800313:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800319:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031f:	50                   	push   %eax
  800320:	e8 cc 09 00 00       	call   800cf1 <sys_cputs>

	return b.cnt;
}
  800325:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032d:	f3 0f 1e fb          	endbr32 
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800337:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80033a:	50                   	push   %eax
  80033b:	ff 75 08             	pushl  0x8(%ebp)
  80033e:	e8 95 ff ff ff       	call   8002d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
  80034b:	83 ec 1c             	sub    $0x1c,%esp
  80034e:	89 c7                	mov    %eax,%edi
  800350:	89 d6                	mov    %edx,%esi
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	8b 55 0c             	mov    0xc(%ebp),%edx
  800358:	89 d1                	mov    %edx,%ecx
  80035a:	89 c2                	mov    %eax,%edx
  80035c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800362:	8b 45 10             	mov    0x10(%ebp),%eax
  800365:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800368:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800372:	39 c2                	cmp    %eax,%edx
  800374:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800377:	72 3e                	jb     8003b7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800379:	83 ec 0c             	sub    $0xc,%esp
  80037c:	ff 75 18             	pushl  0x18(%ebp)
  80037f:	83 eb 01             	sub    $0x1,%ebx
  800382:	53                   	push   %ebx
  800383:	50                   	push   %eax
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038a:	ff 75 e0             	pushl  -0x20(%ebp)
  80038d:	ff 75 dc             	pushl  -0x24(%ebp)
  800390:	ff 75 d8             	pushl  -0x28(%ebp)
  800393:	e8 f8 1e 00 00       	call   802290 <__udivdi3>
  800398:	83 c4 18             	add    $0x18,%esp
  80039b:	52                   	push   %edx
  80039c:	50                   	push   %eax
  80039d:	89 f2                	mov    %esi,%edx
  80039f:	89 f8                	mov    %edi,%eax
  8003a1:	e8 9f ff ff ff       	call   800345 <printnum>
  8003a6:	83 c4 20             	add    $0x20,%esp
  8003a9:	eb 13                	jmp    8003be <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	56                   	push   %esi
  8003af:	ff 75 18             	pushl  0x18(%ebp)
  8003b2:	ff d7                	call   *%edi
  8003b4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b7:	83 eb 01             	sub    $0x1,%ebx
  8003ba:	85 db                	test   %ebx,%ebx
  8003bc:	7f ed                	jg     8003ab <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003be:	83 ec 08             	sub    $0x8,%esp
  8003c1:	56                   	push   %esi
  8003c2:	83 ec 04             	sub    $0x4,%esp
  8003c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d1:	e8 ca 1f 00 00       	call   8023a0 <__umoddi3>
  8003d6:	83 c4 14             	add    $0x14,%esp
  8003d9:	0f be 80 bf 25 80 00 	movsbl 0x8025bf(%eax),%eax
  8003e0:	50                   	push   %eax
  8003e1:	ff d7                	call   *%edi
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e9:	5b                   	pop    %ebx
  8003ea:	5e                   	pop    %esi
  8003eb:	5f                   	pop    %edi
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	f3 0f 1e fb          	endbr32 
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800401:	73 0a                	jae    80040d <sprintputch+0x1f>
		*b->buf++ = ch;
  800403:	8d 4a 01             	lea    0x1(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 45 08             	mov    0x8(%ebp),%eax
  80040b:	88 02                	mov    %al,(%edx)
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <printfmt>:
{
  80040f:	f3 0f 1e fb          	endbr32 
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800419:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041c:	50                   	push   %eax
  80041d:	ff 75 10             	pushl  0x10(%ebp)
  800420:	ff 75 0c             	pushl  0xc(%ebp)
  800423:	ff 75 08             	pushl  0x8(%ebp)
  800426:	e8 05 00 00 00       	call   800430 <vprintfmt>
}
  80042b:	83 c4 10             	add    $0x10,%esp
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <vprintfmt>:
{
  800430:	f3 0f 1e fb          	endbr32 
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 3c             	sub    $0x3c,%esp
  80043d:	8b 75 08             	mov    0x8(%ebp),%esi
  800440:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800443:	8b 7d 10             	mov    0x10(%ebp),%edi
  800446:	e9 8e 03 00 00       	jmp    8007d9 <vprintfmt+0x3a9>
		padc = ' ';
  80044b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80044f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800456:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80045d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800464:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8d 47 01             	lea    0x1(%edi),%eax
  80046c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046f:	0f b6 17             	movzbl (%edi),%edx
  800472:	8d 42 dd             	lea    -0x23(%edx),%eax
  800475:	3c 55                	cmp    $0x55,%al
  800477:	0f 87 df 03 00 00    	ja     80085c <vprintfmt+0x42c>
  80047d:	0f b6 c0             	movzbl %al,%eax
  800480:	3e ff 24 85 00 27 80 	notrack jmp *0x802700(,%eax,4)
  800487:	00 
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80048b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80048f:	eb d8                	jmp    800469 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800494:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800498:	eb cf                	jmp    800469 <vprintfmt+0x39>
  80049a:	0f b6 d2             	movzbl %dl,%edx
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8004a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004b5:	83 f9 09             	cmp    $0x9,%ecx
  8004b8:	77 55                	ja     80050f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8004bd:	eb e9                	jmp    8004a8 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 40 04             	lea    0x4(%eax),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	79 90                	jns    800469 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004e6:	eb 81                	jmp    800469 <vprintfmt+0x39>
  8004e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f2:	0f 49 d0             	cmovns %eax,%edx
  8004f5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004fb:	e9 69 ff ff ff       	jmp    800469 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800503:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80050a:	e9 5a ff ff ff       	jmp    800469 <vprintfmt+0x39>
  80050f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800512:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800515:	eb bc                	jmp    8004d3 <vprintfmt+0xa3>
			lflag++;
  800517:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80051d:	e9 47 ff ff ff       	jmp    800469 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 78 04             	lea    0x4(%eax),%edi
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 30                	pushl  (%eax)
  80052e:	ff d6                	call   *%esi
			break;
  800530:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800533:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800536:	e9 9b 02 00 00       	jmp    8007d6 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 78 04             	lea    0x4(%eax),%edi
  800541:	8b 00                	mov    (%eax),%eax
  800543:	99                   	cltd   
  800544:	31 d0                	xor    %edx,%eax
  800546:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800548:	83 f8 0f             	cmp    $0xf,%eax
  80054b:	7f 23                	jg     800570 <vprintfmt+0x140>
  80054d:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	74 18                	je     800570 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800558:	52                   	push   %edx
  800559:	68 69 29 80 00       	push   $0x802969
  80055e:	53                   	push   %ebx
  80055f:	56                   	push   %esi
  800560:	e8 aa fe ff ff       	call   80040f <printfmt>
  800565:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800568:	89 7d 14             	mov    %edi,0x14(%ebp)
  80056b:	e9 66 02 00 00       	jmp    8007d6 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800570:	50                   	push   %eax
  800571:	68 d7 25 80 00       	push   $0x8025d7
  800576:	53                   	push   %ebx
  800577:	56                   	push   %esi
  800578:	e8 92 fe ff ff       	call   80040f <printfmt>
  80057d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800580:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800583:	e9 4e 02 00 00       	jmp    8007d6 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	83 c0 04             	add    $0x4,%eax
  80058e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800596:	85 d2                	test   %edx,%edx
  800598:	b8 d0 25 80 00       	mov    $0x8025d0,%eax
  80059d:	0f 45 c2             	cmovne %edx,%eax
  8005a0:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a7:	7e 06                	jle    8005af <vprintfmt+0x17f>
  8005a9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005ad:	75 0d                	jne    8005bc <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b2:	89 c7                	mov    %eax,%edi
  8005b4:	03 45 e0             	add    -0x20(%ebp),%eax
  8005b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ba:	eb 55                	jmp    800611 <vprintfmt+0x1e1>
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8005c2:	ff 75 cc             	pushl  -0x34(%ebp)
  8005c5:	e8 46 03 00 00       	call   800910 <strnlen>
  8005ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005cd:	29 c2                	sub    %eax,%edx
  8005cf:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005d7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005db:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005de:	85 ff                	test   %edi,%edi
  8005e0:	7e 11                	jle    8005f3 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	83 ef 01             	sub    $0x1,%edi
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	eb eb                	jmp    8005de <vprintfmt+0x1ae>
  8005f3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fd:	0f 49 c2             	cmovns %edx,%eax
  800600:	29 c2                	sub    %eax,%edx
  800602:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800605:	eb a8                	jmp    8005af <vprintfmt+0x17f>
					putch(ch, putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	52                   	push   %edx
  80060c:	ff d6                	call   *%esi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800614:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	83 c7 01             	add    $0x1,%edi
  800619:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061d:	0f be d0             	movsbl %al,%edx
  800620:	85 d2                	test   %edx,%edx
  800622:	74 4b                	je     80066f <vprintfmt+0x23f>
  800624:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800628:	78 06                	js     800630 <vprintfmt+0x200>
  80062a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80062e:	78 1e                	js     80064e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800630:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800634:	74 d1                	je     800607 <vprintfmt+0x1d7>
  800636:	0f be c0             	movsbl %al,%eax
  800639:	83 e8 20             	sub    $0x20,%eax
  80063c:	83 f8 5e             	cmp    $0x5e,%eax
  80063f:	76 c6                	jbe    800607 <vprintfmt+0x1d7>
					putch('?', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 3f                	push   $0x3f
  800647:	ff d6                	call   *%esi
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	eb c3                	jmp    800611 <vprintfmt+0x1e1>
  80064e:	89 cf                	mov    %ecx,%edi
  800650:	eb 0e                	jmp    800660 <vprintfmt+0x230>
				putch(' ', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 20                	push   $0x20
  800658:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	85 ff                	test   %edi,%edi
  800662:	7f ee                	jg     800652 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800664:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
  80066a:	e9 67 01 00 00       	jmp    8007d6 <vprintfmt+0x3a6>
  80066f:	89 cf                	mov    %ecx,%edi
  800671:	eb ed                	jmp    800660 <vprintfmt+0x230>
	if (lflag >= 2)
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7f 1b                	jg     800693 <vprintfmt+0x263>
	else if (lflag)
  800678:	85 c9                	test   %ecx,%ecx
  80067a:	74 63                	je     8006df <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 00                	mov    (%eax),%eax
  800681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800684:	99                   	cltd   
  800685:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
  800691:	eb 17                	jmp    8006aa <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 50 04             	mov    0x4(%eax),%edx
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 40 08             	lea    0x8(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ad:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006b0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	0f 89 ff 00 00 00    	jns    8007bc <vprintfmt+0x38c>
				putch('-', putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 2d                	push   $0x2d
  8006c3:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006cb:	f7 da                	neg    %edx
  8006cd:	83 d1 00             	adc    $0x0,%ecx
  8006d0:	f7 d9                	neg    %ecx
  8006d2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006da:	e9 dd 00 00 00       	jmp    8007bc <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e7:	99                   	cltd   
  8006e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f4:	eb b4                	jmp    8006aa <vprintfmt+0x27a>
	if (lflag >= 2)
  8006f6:	83 f9 01             	cmp    $0x1,%ecx
  8006f9:	7f 1e                	jg     800719 <vprintfmt+0x2e9>
	else if (lflag)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	74 32                	je     800731 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	b9 00 00 00 00       	mov    $0x0,%ecx
  800709:	8d 40 04             	lea    0x4(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800714:	e9 a3 00 00 00       	jmp    8007bc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	8b 48 04             	mov    0x4(%eax),%ecx
  800721:	8d 40 08             	lea    0x8(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80072c:	e9 8b 00 00 00       	jmp    8007bc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073b:	8d 40 04             	lea    0x4(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800741:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800746:	eb 74                	jmp    8007bc <vprintfmt+0x38c>
	if (lflag >= 2)
  800748:	83 f9 01             	cmp    $0x1,%ecx
  80074b:	7f 1b                	jg     800768 <vprintfmt+0x338>
	else if (lflag)
  80074d:	85 c9                	test   %ecx,%ecx
  80074f:	74 2c                	je     80077d <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	8d 40 04             	lea    0x4(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800761:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800766:	eb 54                	jmp    8007bc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	8b 48 04             	mov    0x4(%eax),%ecx
  800770:	8d 40 08             	lea    0x8(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800776:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80077b:	eb 3f                	jmp    8007bc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8b 10                	mov    (%eax),%edx
  800782:	b9 00 00 00 00       	mov    $0x0,%ecx
  800787:	8d 40 04             	lea    0x4(%eax),%eax
  80078a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80078d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800792:	eb 28                	jmp    8007bc <vprintfmt+0x38c>
			putch('0', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 30                	push   $0x30
  80079a:	ff d6                	call   *%esi
			putch('x', putdat);
  80079c:	83 c4 08             	add    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 78                	push   $0x78
  8007a2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007ae:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007b1:	8d 40 04             	lea    0x4(%eax),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007bc:	83 ec 0c             	sub    $0xc,%esp
  8007bf:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8007c3:	57                   	push   %edi
  8007c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c7:	50                   	push   %eax
  8007c8:	51                   	push   %ecx
  8007c9:	52                   	push   %edx
  8007ca:	89 da                	mov    %ebx,%edx
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	e8 72 fb ff ff       	call   800345 <printnum>
			break;
  8007d3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8007d9:	83 c7 01             	add    $0x1,%edi
  8007dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e0:	83 f8 25             	cmp    $0x25,%eax
  8007e3:	0f 84 62 fc ff ff    	je     80044b <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	0f 84 8b 00 00 00    	je     80087c <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	50                   	push   %eax
  8007f6:	ff d6                	call   *%esi
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	eb dc                	jmp    8007d9 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8007fd:	83 f9 01             	cmp    $0x1,%ecx
  800800:	7f 1b                	jg     80081d <vprintfmt+0x3ed>
	else if (lflag)
  800802:	85 c9                	test   %ecx,%ecx
  800804:	74 2c                	je     800832 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800810:	8d 40 04             	lea    0x4(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800816:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80081b:	eb 9f                	jmp    8007bc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8b 10                	mov    (%eax),%edx
  800822:	8b 48 04             	mov    0x4(%eax),%ecx
  800825:	8d 40 08             	lea    0x8(%eax),%eax
  800828:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800830:	eb 8a                	jmp    8007bc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8b 10                	mov    (%eax),%edx
  800837:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083c:	8d 40 04             	lea    0x4(%eax),%eax
  80083f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800842:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800847:	e9 70 ff ff ff       	jmp    8007bc <vprintfmt+0x38c>
			putch(ch, putdat);
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	53                   	push   %ebx
  800850:	6a 25                	push   $0x25
  800852:	ff d6                	call   *%esi
			break;
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	e9 7a ff ff ff       	jmp    8007d6 <vprintfmt+0x3a6>
			putch('%', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 25                	push   $0x25
  800862:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	89 f8                	mov    %edi,%eax
  800869:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80086d:	74 05                	je     800874 <vprintfmt+0x444>
  80086f:	83 e8 01             	sub    $0x1,%eax
  800872:	eb f5                	jmp    800869 <vprintfmt+0x439>
  800874:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800877:	e9 5a ff ff ff       	jmp    8007d6 <vprintfmt+0x3a6>
}
  80087c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5f                   	pop    %edi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800884:	f3 0f 1e fb          	endbr32 
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 18             	sub    $0x18,%esp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800894:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800897:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	74 26                	je     8008cf <vsnprintf+0x4b>
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	7e 22                	jle    8008cf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ad:	ff 75 14             	pushl  0x14(%ebp)
  8008b0:	ff 75 10             	pushl  0x10(%ebp)
  8008b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b6:	50                   	push   %eax
  8008b7:	68 ee 03 80 00       	push   $0x8003ee
  8008bc:	e8 6f fb ff ff       	call   800430 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ca:	83 c4 10             	add    $0x10,%esp
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    
		return -E_INVAL;
  8008cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d4:	eb f7                	jmp    8008cd <vsnprintf+0x49>

008008d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d6:	f3 0f 1e fb          	endbr32 
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8008e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e3:	50                   	push   %eax
  8008e4:	ff 75 10             	pushl  0x10(%ebp)
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	ff 75 08             	pushl  0x8(%ebp)
  8008ed:	e8 92 ff ff ff       	call   800884 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f4:	f3 0f 1e fb          	endbr32 
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800903:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800907:	74 05                	je     80090e <strlen+0x1a>
		n++;
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	eb f5                	jmp    800903 <strlen+0xf>
	return n;
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800910:	f3 0f 1e fb          	endbr32 
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
  800922:	39 d0                	cmp    %edx,%eax
  800924:	74 0d                	je     800933 <strnlen+0x23>
  800926:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092a:	74 05                	je     800931 <strnlen+0x21>
		n++;
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	eb f1                	jmp    800922 <strnlen+0x12>
  800931:	89 c2                	mov    %eax,%edx
	return n;
}
  800933:	89 d0                	mov    %edx,%eax
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800937:	f3 0f 1e fb          	endbr32 
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
  80094a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80094e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800951:	83 c0 01             	add    $0x1,%eax
  800954:	84 d2                	test   %dl,%dl
  800956:	75 f2                	jne    80094a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800958:	89 c8                	mov    %ecx,%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095d:	f3 0f 1e fb          	endbr32 
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	83 ec 10             	sub    $0x10,%esp
  800968:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096b:	53                   	push   %ebx
  80096c:	e8 83 ff ff ff       	call   8008f4 <strlen>
  800971:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	01 d8                	add    %ebx,%eax
  800979:	50                   	push   %eax
  80097a:	e8 b8 ff ff ff       	call   800937 <strcpy>
	return dst;
}
  80097f:	89 d8                	mov    %ebx,%eax
  800981:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800986:	f3 0f 1e fb          	endbr32 
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 75 08             	mov    0x8(%ebp),%esi
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
  800995:	89 f3                	mov    %esi,%ebx
  800997:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099a:	89 f0                	mov    %esi,%eax
  80099c:	39 d8                	cmp    %ebx,%eax
  80099e:	74 11                	je     8009b1 <strncpy+0x2b>
		*dst++ = *src;
  8009a0:	83 c0 01             	add    $0x1,%eax
  8009a3:	0f b6 0a             	movzbl (%edx),%ecx
  8009a6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a9:	80 f9 01             	cmp    $0x1,%cl
  8009ac:	83 da ff             	sbb    $0xffffffff,%edx
  8009af:	eb eb                	jmp    80099c <strncpy+0x16>
	}
	return ret;
}
  8009b1:	89 f0                	mov    %esi,%eax
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b7:	f3 0f 1e fb          	endbr32 
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	56                   	push   %esi
  8009bf:	53                   	push   %ebx
  8009c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c6:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cb:	85 d2                	test   %edx,%edx
  8009cd:	74 21                	je     8009f0 <strlcpy+0x39>
  8009cf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009d3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009d5:	39 c2                	cmp    %eax,%edx
  8009d7:	74 14                	je     8009ed <strlcpy+0x36>
  8009d9:	0f b6 19             	movzbl (%ecx),%ebx
  8009dc:	84 db                	test   %bl,%bl
  8009de:	74 0b                	je     8009eb <strlcpy+0x34>
			*dst++ = *src++;
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e9:	eb ea                	jmp    8009d5 <strlcpy+0x1e>
  8009eb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009ed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f0:	29 f0                	sub    %esi,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f6:	f3 0f 1e fb          	endbr32 
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a03:	0f b6 01             	movzbl (%ecx),%eax
  800a06:	84 c0                	test   %al,%al
  800a08:	74 0c                	je     800a16 <strcmp+0x20>
  800a0a:	3a 02                	cmp    (%edx),%al
  800a0c:	75 08                	jne    800a16 <strcmp+0x20>
		p++, q++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
  800a11:	83 c2 01             	add    $0x1,%edx
  800a14:	eb ed                	jmp    800a03 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a16:	0f b6 c0             	movzbl %al,%eax
  800a19:	0f b6 12             	movzbl (%edx),%edx
  800a1c:	29 d0                	sub    %edx,%eax
}
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a20:	f3 0f 1e fb          	endbr32 
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	53                   	push   %ebx
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2e:	89 c3                	mov    %eax,%ebx
  800a30:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a33:	eb 06                	jmp    800a3b <strncmp+0x1b>
		n--, p++, q++;
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a3b:	39 d8                	cmp    %ebx,%eax
  800a3d:	74 16                	je     800a55 <strncmp+0x35>
  800a3f:	0f b6 08             	movzbl (%eax),%ecx
  800a42:	84 c9                	test   %cl,%cl
  800a44:	74 04                	je     800a4a <strncmp+0x2a>
  800a46:	3a 0a                	cmp    (%edx),%cl
  800a48:	74 eb                	je     800a35 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4a:	0f b6 00             	movzbl (%eax),%eax
  800a4d:	0f b6 12             	movzbl (%edx),%edx
  800a50:	29 d0                	sub    %edx,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    
		return 0;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	eb f6                	jmp    800a52 <strncmp+0x32>

00800a5c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5c:	f3 0f 1e fb          	endbr32 
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6a:	0f b6 10             	movzbl (%eax),%edx
  800a6d:	84 d2                	test   %dl,%dl
  800a6f:	74 09                	je     800a7a <strchr+0x1e>
		if (*s == c)
  800a71:	38 ca                	cmp    %cl,%dl
  800a73:	74 0a                	je     800a7f <strchr+0x23>
	for (; *s; s++)
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	eb f0                	jmp    800a6a <strchr+0xe>
			return (char *) s;
	return 0;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800a81:	f3 0f 1e fb          	endbr32 
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800a8b:	6a 78                	push   $0x78
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 c7 ff ff ff       	call   800a5c <strchr>
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800aa0:	eb 0d                	jmp    800aaf <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800aa2:	c1 e0 04             	shl    $0x4,%eax
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	0f b6 11             	movzbl (%ecx),%edx
  800ab2:	84 d2                	test   %dl,%dl
  800ab4:	74 11                	je     800ac7 <atox+0x46>
		if (*p>='a'){
  800ab6:	80 fa 60             	cmp    $0x60,%dl
  800ab9:	7e e7                	jle    800aa2 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800abb:	c1 e0 04             	shl    $0x4,%eax
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800ac5:	eb e5                	jmp    800aac <atox+0x2b>
	}

	return v;

}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac9:	f3 0f 1e fb          	endbr32 
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ada:	38 ca                	cmp    %cl,%dl
  800adc:	74 09                	je     800ae7 <strfind+0x1e>
  800ade:	84 d2                	test   %dl,%dl
  800ae0:	74 05                	je     800ae7 <strfind+0x1e>
	for (; *s; s++)
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	eb f0                	jmp    800ad7 <strfind+0xe>
			break;
	return (char *) s;
}
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae9:	f3 0f 1e fb          	endbr32 
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af9:	85 c9                	test   %ecx,%ecx
  800afb:	74 31                	je     800b2e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afd:	89 f8                	mov    %edi,%eax
  800aff:	09 c8                	or     %ecx,%eax
  800b01:	a8 03                	test   $0x3,%al
  800b03:	75 23                	jne    800b28 <memset+0x3f>
		c &= 0xFF;
  800b05:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b09:	89 d3                	mov    %edx,%ebx
  800b0b:	c1 e3 08             	shl    $0x8,%ebx
  800b0e:	89 d0                	mov    %edx,%eax
  800b10:	c1 e0 18             	shl    $0x18,%eax
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	c1 e6 10             	shl    $0x10,%esi
  800b18:	09 f0                	or     %esi,%eax
  800b1a:	09 c2                	or     %eax,%edx
  800b1c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b1e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b21:	89 d0                	mov    %edx,%eax
  800b23:	fc                   	cld    
  800b24:	f3 ab                	rep stos %eax,%es:(%edi)
  800b26:	eb 06                	jmp    800b2e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	fc                   	cld    
  800b2c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2e:	89 f8                	mov    %edi,%eax
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b35:	f3 0f 1e fb          	endbr32 
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b47:	39 c6                	cmp    %eax,%esi
  800b49:	73 32                	jae    800b7d <memmove+0x48>
  800b4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b4e:	39 c2                	cmp    %eax,%edx
  800b50:	76 2b                	jbe    800b7d <memmove+0x48>
		s += n;
		d += n;
  800b52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b55:	89 fe                	mov    %edi,%esi
  800b57:	09 ce                	or     %ecx,%esi
  800b59:	09 d6                	or     %edx,%esi
  800b5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b61:	75 0e                	jne    800b71 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b63:	83 ef 04             	sub    $0x4,%edi
  800b66:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b6c:	fd                   	std    
  800b6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6f:	eb 09                	jmp    800b7a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b71:	83 ef 01             	sub    $0x1,%edi
  800b74:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b77:	fd                   	std    
  800b78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7a:	fc                   	cld    
  800b7b:	eb 1a                	jmp    800b97 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7d:	89 c2                	mov    %eax,%edx
  800b7f:	09 ca                	or     %ecx,%edx
  800b81:	09 f2                	or     %esi,%edx
  800b83:	f6 c2 03             	test   $0x3,%dl
  800b86:	75 0a                	jne    800b92 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b88:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	fc                   	cld    
  800b8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b90:	eb 05                	jmp    800b97 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	fc                   	cld    
  800b95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba5:	ff 75 10             	pushl  0x10(%ebp)
  800ba8:	ff 75 0c             	pushl  0xc(%ebp)
  800bab:	ff 75 08             	pushl  0x8(%ebp)
  800bae:	e8 82 ff ff ff       	call   800b35 <memmove>
}
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    

00800bb5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb5:	f3 0f 1e fb          	endbr32 
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc4:	89 c6                	mov    %eax,%esi
  800bc6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc9:	39 f0                	cmp    %esi,%eax
  800bcb:	74 1c                	je     800be9 <memcmp+0x34>
		if (*s1 != *s2)
  800bcd:	0f b6 08             	movzbl (%eax),%ecx
  800bd0:	0f b6 1a             	movzbl (%edx),%ebx
  800bd3:	38 d9                	cmp    %bl,%cl
  800bd5:	75 08                	jne    800bdf <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bd7:	83 c0 01             	add    $0x1,%eax
  800bda:	83 c2 01             	add    $0x1,%edx
  800bdd:	eb ea                	jmp    800bc9 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800bdf:	0f b6 c1             	movzbl %cl,%eax
  800be2:	0f b6 db             	movzbl %bl,%ebx
  800be5:	29 d8                	sub    %ebx,%eax
  800be7:	eb 05                	jmp    800bee <memcmp+0x39>
	}

	return 0;
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf2:	f3 0f 1e fb          	endbr32 
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 09                	jae    800c11 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c08:	38 08                	cmp    %cl,(%eax)
  800c0a:	74 05                	je     800c11 <memfind+0x1f>
	for (; s < ends; s++)
  800c0c:	83 c0 01             	add    $0x1,%eax
  800c0f:	eb f3                	jmp    800c04 <memfind+0x12>
			break;
	return (void *) s;
}
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c13:	f3 0f 1e fb          	endbr32 
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c23:	eb 03                	jmp    800c28 <strtol+0x15>
		s++;
  800c25:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c28:	0f b6 01             	movzbl (%ecx),%eax
  800c2b:	3c 20                	cmp    $0x20,%al
  800c2d:	74 f6                	je     800c25 <strtol+0x12>
  800c2f:	3c 09                	cmp    $0x9,%al
  800c31:	74 f2                	je     800c25 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c33:	3c 2b                	cmp    $0x2b,%al
  800c35:	74 2a                	je     800c61 <strtol+0x4e>
	int neg = 0;
  800c37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c3c:	3c 2d                	cmp    $0x2d,%al
  800c3e:	74 2b                	je     800c6b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c46:	75 0f                	jne    800c57 <strtol+0x44>
  800c48:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4b:	74 28                	je     800c75 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c4d:	85 db                	test   %ebx,%ebx
  800c4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c54:	0f 44 d8             	cmove  %eax,%ebx
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c5f:	eb 46                	jmp    800ca7 <strtol+0x94>
		s++;
  800c61:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c64:	bf 00 00 00 00       	mov    $0x0,%edi
  800c69:	eb d5                	jmp    800c40 <strtol+0x2d>
		s++, neg = 1;
  800c6b:	83 c1 01             	add    $0x1,%ecx
  800c6e:	bf 01 00 00 00       	mov    $0x1,%edi
  800c73:	eb cb                	jmp    800c40 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c79:	74 0e                	je     800c89 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c7b:	85 db                	test   %ebx,%ebx
  800c7d:	75 d8                	jne    800c57 <strtol+0x44>
		s++, base = 8;
  800c7f:	83 c1 01             	add    $0x1,%ecx
  800c82:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c87:	eb ce                	jmp    800c57 <strtol+0x44>
		s += 2, base = 16;
  800c89:	83 c1 02             	add    $0x2,%ecx
  800c8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c91:	eb c4                	jmp    800c57 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c93:	0f be d2             	movsbl %dl,%edx
  800c96:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c99:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9c:	7d 3a                	jge    800cd8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c9e:	83 c1 01             	add    $0x1,%ecx
  800ca1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ca7:	0f b6 11             	movzbl (%ecx),%edx
  800caa:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cad:	89 f3                	mov    %esi,%ebx
  800caf:	80 fb 09             	cmp    $0x9,%bl
  800cb2:	76 df                	jbe    800c93 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800cb4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb7:	89 f3                	mov    %esi,%ebx
  800cb9:	80 fb 19             	cmp    $0x19,%bl
  800cbc:	77 08                	ja     800cc6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cbe:	0f be d2             	movsbl %dl,%edx
  800cc1:	83 ea 57             	sub    $0x57,%edx
  800cc4:	eb d3                	jmp    800c99 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800cc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc9:	89 f3                	mov    %esi,%ebx
  800ccb:	80 fb 19             	cmp    $0x19,%bl
  800cce:	77 08                	ja     800cd8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cd0:	0f be d2             	movsbl %dl,%edx
  800cd3:	83 ea 37             	sub    $0x37,%edx
  800cd6:	eb c1                	jmp    800c99 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdc:	74 05                	je     800ce3 <strtol+0xd0>
		*endptr = (char *) s;
  800cde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ce3:	89 c2                	mov    %eax,%edx
  800ce5:	f7 da                	neg    %edx
  800ce7:	85 ff                	test   %edi,%edi
  800ce9:	0f 45 c2             	cmovne %edx,%eax
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf1:	f3 0f 1e fb          	endbr32 
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	89 c3                	mov    %eax,%ebx
  800d08:	89 c7                	mov    %eax,%edi
  800d0a:	89 c6                	mov    %eax,%esi
  800d0c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d13:	f3 0f 1e fb          	endbr32 
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	89 d1                	mov    %edx,%ecx
  800d29:	89 d3                	mov    %edx,%ebx
  800d2b:	89 d7                	mov    %edx,%edi
  800d2d:	89 d6                	mov    %edx,%esi
  800d2f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d36:	f3 0f 1e fb          	endbr32 
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	b8 03 00 00 00       	mov    $0x3,%eax
  800d4d:	89 cb                	mov    %ecx,%ebx
  800d4f:	89 cf                	mov    %ecx,%edi
  800d51:	89 ce                	mov    %ecx,%esi
  800d53:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d64:	ba 00 00 00 00       	mov    $0x0,%edx
  800d69:	b8 02 00 00 00       	mov    $0x2,%eax
  800d6e:	89 d1                	mov    %edx,%ecx
  800d70:	89 d3                	mov    %edx,%ebx
  800d72:	89 d7                	mov    %edx,%edi
  800d74:	89 d6                	mov    %edx,%esi
  800d76:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_yield>:

void
sys_yield(void)
{
  800d7d:	f3 0f 1e fb          	endbr32 
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d91:	89 d1                	mov    %edx,%ecx
  800d93:	89 d3                	mov    %edx,%ebx
  800d95:	89 d7                	mov    %edx,%edi
  800d97:	89 d6                	mov    %edx,%esi
  800d99:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800daa:	be 00 00 00 00       	mov    $0x0,%esi
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	b8 04 00 00 00       	mov    $0x4,%eax
  800dba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbd:	89 f7                	mov    %esi,%edi
  800dbf:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc6:	f3 0f 1e fb          	endbr32 
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de1:	8b 75 18             	mov    0x18(%ebp),%esi
  800de4:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800deb:	f3 0f 1e fb          	endbr32 
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	b8 06 00 00 00       	mov    $0x6,%eax
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	b8 08 00 00 00       	mov    $0x8,%eax
  800e2a:	89 df                	mov    %ebx,%edi
  800e2c:	89 de                	mov    %ebx,%esi
  800e2e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e35:	f3 0f 1e fb          	endbr32 
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e4f:	89 df                	mov    %ebx,%edi
  800e51:	89 de                	mov    %ebx,%esi
  800e53:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e5a:	f3 0f 1e fb          	endbr32 
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e74:	89 df                	mov    %ebx,%edi
  800e76:	89 de                	mov    %ebx,%esi
  800e78:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7f:	f3 0f 1e fb          	endbr32 
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e94:	be 00 00 00 00       	mov    $0x0,%esi
  800e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea6:	f3 0f 1e fb          	endbr32 
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebd:	89 cb                	mov    %ecx,%ebx
  800ebf:	89 cf                	mov    %ecx,%edi
  800ec1:	89 ce                	mov    %ecx,%esi
  800ec3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eca:	f3 0f 1e fb          	endbr32 
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ede:	89 d1                	mov    %edx,%ecx
  800ee0:	89 d3                	mov    %edx,%ebx
  800ee2:	89 d7                	mov    %edx,%edi
  800ee4:	89 d6                	mov    %edx,%esi
  800ee6:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800eed:	f3 0f 1e fb          	endbr32 
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	57                   	push   %edi
  800ef5:	56                   	push   %esi
  800ef6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efc:	8b 55 08             	mov    0x8(%ebp),%edx
  800eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f02:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	89 de                	mov    %ebx,%esi
  800f0b:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800f12:	f3 0f 1e fb          	endbr32 
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f21:	8b 55 08             	mov    0x8(%ebp),%edx
  800f24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f27:	b8 10 00 00 00       	mov    $0x10,%eax
  800f2c:	89 df                	mov    %ebx,%edi
  800f2e:	89 de                	mov    %ebx,%esi
  800f30:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f37:	f3 0f 1e fb          	endbr32 
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	05 00 00 00 30       	add    $0x30000000,%eax
  800f46:	c1 e8 0c             	shr    $0xc,%eax
}
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f4b:	f3 0f 1e fb          	endbr32 
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
  800f55:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f5f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f66:	f3 0f 1e fb          	endbr32 
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f72:	89 c2                	mov    %eax,%edx
  800f74:	c1 ea 16             	shr    $0x16,%edx
  800f77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f7e:	f6 c2 01             	test   $0x1,%dl
  800f81:	74 2d                	je     800fb0 <fd_alloc+0x4a>
  800f83:	89 c2                	mov    %eax,%edx
  800f85:	c1 ea 0c             	shr    $0xc,%edx
  800f88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8f:	f6 c2 01             	test   $0x1,%dl
  800f92:	74 1c                	je     800fb0 <fd_alloc+0x4a>
  800f94:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f99:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f9e:	75 d2                	jne    800f72 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800fa9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800fae:	eb 0a                	jmp    800fba <fd_alloc+0x54>
			*fd_store = fd;
  800fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fbc:	f3 0f 1e fb          	endbr32 
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fc6:	83 f8 1f             	cmp    $0x1f,%eax
  800fc9:	77 30                	ja     800ffb <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fcb:	c1 e0 0c             	shl    $0xc,%eax
  800fce:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fd3:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800fd9:	f6 c2 01             	test   $0x1,%dl
  800fdc:	74 24                	je     801002 <fd_lookup+0x46>
  800fde:	89 c2                	mov    %eax,%edx
  800fe0:	c1 ea 0c             	shr    $0xc,%edx
  800fe3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fea:	f6 c2 01             	test   $0x1,%dl
  800fed:	74 1a                	je     801009 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff2:	89 02                	mov    %eax,(%edx)
	return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    
		return -E_INVAL;
  800ffb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801000:	eb f7                	jmp    800ff9 <fd_lookup+0x3d>
		return -E_INVAL;
  801002:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801007:	eb f0                	jmp    800ff9 <fd_lookup+0x3d>
  801009:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80100e:	eb e9                	jmp    800ff9 <fd_lookup+0x3d>

00801010 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801010:	f3 0f 1e fb          	endbr32 
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 08             	sub    $0x8,%esp
  80101a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80101d:	ba 00 00 00 00       	mov    $0x0,%edx
  801022:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801027:	39 08                	cmp    %ecx,(%eax)
  801029:	74 38                	je     801063 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80102b:	83 c2 01             	add    $0x1,%edx
  80102e:	8b 04 95 3c 29 80 00 	mov    0x80293c(,%edx,4),%eax
  801035:	85 c0                	test   %eax,%eax
  801037:	75 ee                	jne    801027 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801039:	a1 08 40 80 00       	mov    0x804008,%eax
  80103e:	8b 40 48             	mov    0x48(%eax),%eax
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	51                   	push   %ecx
  801045:	50                   	push   %eax
  801046:	68 c0 28 80 00       	push   $0x8028c0
  80104b:	e8 dd f2 ff ff       	call   80032d <cprintf>
	*dev = 0;
  801050:	8b 45 0c             	mov    0xc(%ebp),%eax
  801053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801061:	c9                   	leave  
  801062:	c3                   	ret    
			*dev = devtab[i];
  801063:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801066:	89 01                	mov    %eax,(%ecx)
			return 0;
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
  80106d:	eb f2                	jmp    801061 <dev_lookup+0x51>

0080106f <fd_close>:
{
  80106f:	f3 0f 1e fb          	endbr32 
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 24             	sub    $0x24,%esp
  80107c:	8b 75 08             	mov    0x8(%ebp),%esi
  80107f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801082:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801085:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801086:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80108c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80108f:	50                   	push   %eax
  801090:	e8 27 ff ff ff       	call   800fbc <fd_lookup>
  801095:	89 c3                	mov    %eax,%ebx
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 05                	js     8010a3 <fd_close+0x34>
	    || fd != fd2)
  80109e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8010a1:	74 16                	je     8010b9 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8010a3:	89 f8                	mov    %edi,%eax
  8010a5:	84 c0                	test   %al,%al
  8010a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ac:	0f 44 d8             	cmove  %eax,%ebx
}
  8010af:	89 d8                	mov    %ebx,%eax
  8010b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8010bf:	50                   	push   %eax
  8010c0:	ff 36                	pushl  (%esi)
  8010c2:	e8 49 ff ff ff       	call   801010 <dev_lookup>
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 1a                	js     8010ea <fd_close+0x7b>
		if (dev->dev_close)
  8010d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010d3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	74 0b                	je     8010ea <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	56                   	push   %esi
  8010e3:	ff d0                	call   *%eax
  8010e5:	89 c3                	mov    %eax,%ebx
  8010e7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	56                   	push   %esi
  8010ee:	6a 00                	push   $0x0
  8010f0:	e8 f6 fc ff ff       	call   800deb <sys_page_unmap>
	return r;
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	eb b5                	jmp    8010af <fd_close+0x40>

008010fa <close>:

int
close(int fdnum)
{
  8010fa:	f3 0f 1e fb          	endbr32 
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801104:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801107:	50                   	push   %eax
  801108:	ff 75 08             	pushl  0x8(%ebp)
  80110b:	e8 ac fe ff ff       	call   800fbc <fd_lookup>
  801110:	83 c4 10             	add    $0x10,%esp
  801113:	85 c0                	test   %eax,%eax
  801115:	79 02                	jns    801119 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801117:	c9                   	leave  
  801118:	c3                   	ret    
		return fd_close(fd, 1);
  801119:	83 ec 08             	sub    $0x8,%esp
  80111c:	6a 01                	push   $0x1
  80111e:	ff 75 f4             	pushl  -0xc(%ebp)
  801121:	e8 49 ff ff ff       	call   80106f <fd_close>
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	eb ec                	jmp    801117 <close+0x1d>

0080112b <close_all>:

void
close_all(void)
{
  80112b:	f3 0f 1e fb          	endbr32 
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	53                   	push   %ebx
  801133:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801136:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	53                   	push   %ebx
  80113f:	e8 b6 ff ff ff       	call   8010fa <close>
	for (i = 0; i < MAXFD; i++)
  801144:	83 c3 01             	add    $0x1,%ebx
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	83 fb 20             	cmp    $0x20,%ebx
  80114d:	75 ec                	jne    80113b <close_all+0x10>
}
  80114f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801152:	c9                   	leave  
  801153:	c3                   	ret    

00801154 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801154:	f3 0f 1e fb          	endbr32 
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	57                   	push   %edi
  80115c:	56                   	push   %esi
  80115d:	53                   	push   %ebx
  80115e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801161:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801164:	50                   	push   %eax
  801165:	ff 75 08             	pushl  0x8(%ebp)
  801168:	e8 4f fe ff ff       	call   800fbc <fd_lookup>
  80116d:	89 c3                	mov    %eax,%ebx
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	0f 88 81 00 00 00    	js     8011fb <dup+0xa7>
		return r;
	close(newfdnum);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	ff 75 0c             	pushl  0xc(%ebp)
  801180:	e8 75 ff ff ff       	call   8010fa <close>

	newfd = INDEX2FD(newfdnum);
  801185:	8b 75 0c             	mov    0xc(%ebp),%esi
  801188:	c1 e6 0c             	shl    $0xc,%esi
  80118b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801191:	83 c4 04             	add    $0x4,%esp
  801194:	ff 75 e4             	pushl  -0x1c(%ebp)
  801197:	e8 af fd ff ff       	call   800f4b <fd2data>
  80119c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80119e:	89 34 24             	mov    %esi,(%esp)
  8011a1:	e8 a5 fd ff ff       	call   800f4b <fd2data>
  8011a6:	83 c4 10             	add    $0x10,%esp
  8011a9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011ab:	89 d8                	mov    %ebx,%eax
  8011ad:	c1 e8 16             	shr    $0x16,%eax
  8011b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011b7:	a8 01                	test   $0x1,%al
  8011b9:	74 11                	je     8011cc <dup+0x78>
  8011bb:	89 d8                	mov    %ebx,%eax
  8011bd:	c1 e8 0c             	shr    $0xc,%eax
  8011c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011c7:	f6 c2 01             	test   $0x1,%dl
  8011ca:	75 39                	jne    801205 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011cf:	89 d0                	mov    %edx,%eax
  8011d1:	c1 e8 0c             	shr    $0xc,%eax
  8011d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e3:	50                   	push   %eax
  8011e4:	56                   	push   %esi
  8011e5:	6a 00                	push   $0x0
  8011e7:	52                   	push   %edx
  8011e8:	6a 00                	push   $0x0
  8011ea:	e8 d7 fb ff ff       	call   800dc6 <sys_page_map>
  8011ef:	89 c3                	mov    %eax,%ebx
  8011f1:	83 c4 20             	add    $0x20,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 31                	js     801229 <dup+0xd5>
		goto err;

	return newfdnum;
  8011f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801200:	5b                   	pop    %ebx
  801201:	5e                   	pop    %esi
  801202:	5f                   	pop    %edi
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801205:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80120c:	83 ec 0c             	sub    $0xc,%esp
  80120f:	25 07 0e 00 00       	and    $0xe07,%eax
  801214:	50                   	push   %eax
  801215:	57                   	push   %edi
  801216:	6a 00                	push   $0x0
  801218:	53                   	push   %ebx
  801219:	6a 00                	push   $0x0
  80121b:	e8 a6 fb ff ff       	call   800dc6 <sys_page_map>
  801220:	89 c3                	mov    %eax,%ebx
  801222:	83 c4 20             	add    $0x20,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	79 a3                	jns    8011cc <dup+0x78>
	sys_page_unmap(0, newfd);
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	56                   	push   %esi
  80122d:	6a 00                	push   $0x0
  80122f:	e8 b7 fb ff ff       	call   800deb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801234:	83 c4 08             	add    $0x8,%esp
  801237:	57                   	push   %edi
  801238:	6a 00                	push   $0x0
  80123a:	e8 ac fb ff ff       	call   800deb <sys_page_unmap>
	return r;
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	eb b7                	jmp    8011fb <dup+0xa7>

00801244 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801244:	f3 0f 1e fb          	endbr32 
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 1c             	sub    $0x1c,%esp
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801252:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	53                   	push   %ebx
  801257:	e8 60 fd ff ff       	call   800fbc <fd_lookup>
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 3f                	js     8012a2 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	ff 30                	pushl  (%eax)
  80126f:	e8 9c fd ff ff       	call   801010 <dev_lookup>
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 27                	js     8012a2 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80127b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80127e:	8b 42 08             	mov    0x8(%edx),%eax
  801281:	83 e0 03             	and    $0x3,%eax
  801284:	83 f8 01             	cmp    $0x1,%eax
  801287:	74 1e                	je     8012a7 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801289:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128c:	8b 40 08             	mov    0x8(%eax),%eax
  80128f:	85 c0                	test   %eax,%eax
  801291:	74 35                	je     8012c8 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801293:	83 ec 04             	sub    $0x4,%esp
  801296:	ff 75 10             	pushl  0x10(%ebp)
  801299:	ff 75 0c             	pushl  0xc(%ebp)
  80129c:	52                   	push   %edx
  80129d:	ff d0                	call   *%eax
  80129f:	83 c4 10             	add    $0x10,%esp
}
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ac:	8b 40 48             	mov    0x48(%eax),%eax
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	53                   	push   %ebx
  8012b3:	50                   	push   %eax
  8012b4:	68 01 29 80 00       	push   $0x802901
  8012b9:	e8 6f f0 ff ff       	call   80032d <cprintf>
		return -E_INVAL;
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c6:	eb da                	jmp    8012a2 <read+0x5e>
		return -E_NOT_SUPP;
  8012c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cd:	eb d3                	jmp    8012a2 <read+0x5e>

008012cf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012cf:	f3 0f 1e fb          	endbr32 
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	57                   	push   %edi
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e7:	eb 02                	jmp    8012eb <readn+0x1c>
  8012e9:	01 c3                	add    %eax,%ebx
  8012eb:	39 f3                	cmp    %esi,%ebx
  8012ed:	73 21                	jae    801310 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012ef:	83 ec 04             	sub    $0x4,%esp
  8012f2:	89 f0                	mov    %esi,%eax
  8012f4:	29 d8                	sub    %ebx,%eax
  8012f6:	50                   	push   %eax
  8012f7:	89 d8                	mov    %ebx,%eax
  8012f9:	03 45 0c             	add    0xc(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	57                   	push   %edi
  8012fe:	e8 41 ff ff ff       	call   801244 <read>
		if (m < 0)
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 04                	js     80130e <readn+0x3f>
			return m;
		if (m == 0)
  80130a:	75 dd                	jne    8012e9 <readn+0x1a>
  80130c:	eb 02                	jmp    801310 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80130e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801310:	89 d8                	mov    %ebx,%eax
  801312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801315:	5b                   	pop    %ebx
  801316:	5e                   	pop    %esi
  801317:	5f                   	pop    %edi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80131a:	f3 0f 1e fb          	endbr32 
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	53                   	push   %ebx
  801322:	83 ec 1c             	sub    $0x1c,%esp
  801325:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801328:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	53                   	push   %ebx
  80132d:	e8 8a fc ff ff       	call   800fbc <fd_lookup>
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 3a                	js     801373 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801343:	ff 30                	pushl  (%eax)
  801345:	e8 c6 fc ff ff       	call   801010 <dev_lookup>
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 22                	js     801373 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801358:	74 1e                	je     801378 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80135a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135d:	8b 52 0c             	mov    0xc(%edx),%edx
  801360:	85 d2                	test   %edx,%edx
  801362:	74 35                	je     801399 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801364:	83 ec 04             	sub    $0x4,%esp
  801367:	ff 75 10             	pushl  0x10(%ebp)
  80136a:	ff 75 0c             	pushl  0xc(%ebp)
  80136d:	50                   	push   %eax
  80136e:	ff d2                	call   *%edx
  801370:	83 c4 10             	add    $0x10,%esp
}
  801373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801376:	c9                   	leave  
  801377:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801378:	a1 08 40 80 00       	mov    0x804008,%eax
  80137d:	8b 40 48             	mov    0x48(%eax),%eax
  801380:	83 ec 04             	sub    $0x4,%esp
  801383:	53                   	push   %ebx
  801384:	50                   	push   %eax
  801385:	68 1d 29 80 00       	push   $0x80291d
  80138a:	e8 9e ef ff ff       	call   80032d <cprintf>
		return -E_INVAL;
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801397:	eb da                	jmp    801373 <write+0x59>
		return -E_NOT_SUPP;
  801399:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80139e:	eb d3                	jmp    801373 <write+0x59>

008013a0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013a0:	f3 0f 1e fb          	endbr32 
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	ff 75 08             	pushl  0x8(%ebp)
  8013b1:	e8 06 fc ff ff       	call   800fbc <fd_lookup>
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 0e                	js     8013cb <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8013bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013cd:	f3 0f 1e fb          	endbr32 
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	53                   	push   %ebx
  8013d5:	83 ec 1c             	sub    $0x1c,%esp
  8013d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013de:	50                   	push   %eax
  8013df:	53                   	push   %ebx
  8013e0:	e8 d7 fb ff ff       	call   800fbc <fd_lookup>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 37                	js     801423 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f6:	ff 30                	pushl  (%eax)
  8013f8:	e8 13 fc ff ff       	call   801010 <dev_lookup>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 1f                	js     801423 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801404:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801407:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80140b:	74 1b                	je     801428 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80140d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801410:	8b 52 18             	mov    0x18(%edx),%edx
  801413:	85 d2                	test   %edx,%edx
  801415:	74 32                	je     801449 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	ff 75 0c             	pushl  0xc(%ebp)
  80141d:	50                   	push   %eax
  80141e:	ff d2                	call   *%edx
  801420:	83 c4 10             	add    $0x10,%esp
}
  801423:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801426:	c9                   	leave  
  801427:	c3                   	ret    
			thisenv->env_id, fdnum);
  801428:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	53                   	push   %ebx
  801434:	50                   	push   %eax
  801435:	68 e0 28 80 00       	push   $0x8028e0
  80143a:	e8 ee ee ff ff       	call   80032d <cprintf>
		return -E_INVAL;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801447:	eb da                	jmp    801423 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801449:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80144e:	eb d3                	jmp    801423 <ftruncate+0x56>

00801450 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801450:	f3 0f 1e fb          	endbr32 
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	53                   	push   %ebx
  801458:	83 ec 1c             	sub    $0x1c,%esp
  80145b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	ff 75 08             	pushl  0x8(%ebp)
  801465:	e8 52 fb ff ff       	call   800fbc <fd_lookup>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 4b                	js     8014bc <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147b:	ff 30                	pushl  (%eax)
  80147d:	e8 8e fb ff ff       	call   801010 <dev_lookup>
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 33                	js     8014bc <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801490:	74 2f                	je     8014c1 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801492:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801495:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80149c:	00 00 00 
	stat->st_isdir = 0;
  80149f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014a6:	00 00 00 
	stat->st_dev = dev;
  8014a9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	53                   	push   %ebx
  8014b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8014b6:	ff 50 14             	call   *0x14(%eax)
  8014b9:	83 c4 10             	add    $0x10,%esp
}
  8014bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    
		return -E_NOT_SUPP;
  8014c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c6:	eb f4                	jmp    8014bc <fstat+0x6c>

008014c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014c8:	f3 0f 1e fb          	endbr32 
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	6a 00                	push   $0x0
  8014d6:	ff 75 08             	pushl  0x8(%ebp)
  8014d9:	e8 01 02 00 00       	call   8016df <open>
  8014de:	89 c3                	mov    %eax,%ebx
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 1b                	js     801502 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	50                   	push   %eax
  8014ee:	e8 5d ff ff ff       	call   801450 <fstat>
  8014f3:	89 c6                	mov    %eax,%esi
	close(fd);
  8014f5:	89 1c 24             	mov    %ebx,(%esp)
  8014f8:	e8 fd fb ff ff       	call   8010fa <close>
	return r;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	89 f3                	mov    %esi,%ebx
}
  801502:	89 d8                	mov    %ebx,%eax
  801504:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801507:	5b                   	pop    %ebx
  801508:	5e                   	pop    %esi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	89 c6                	mov    %eax,%esi
  801512:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801514:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80151b:	74 27                	je     801544 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80151d:	6a 07                	push   $0x7
  80151f:	68 00 50 80 00       	push   $0x805000
  801524:	56                   	push   %esi
  801525:	ff 35 00 40 80 00    	pushl  0x804000
  80152b:	e8 7c 0c 00 00       	call   8021ac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801530:	83 c4 0c             	add    $0xc,%esp
  801533:	6a 00                	push   $0x0
  801535:	53                   	push   %ebx
  801536:	6a 00                	push   $0x0
  801538:	e8 02 0c 00 00       	call   80213f <ipc_recv>
}
  80153d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	6a 01                	push   $0x1
  801549:	e8 b6 0c 00 00       	call   802204 <ipc_find_env>
  80154e:	a3 00 40 80 00       	mov    %eax,0x804000
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	eb c5                	jmp    80151d <fsipc+0x12>

00801558 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801558:	f3 0f 1e fb          	endbr32 
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801562:	8b 45 08             	mov    0x8(%ebp),%eax
  801565:	8b 40 0c             	mov    0xc(%eax),%eax
  801568:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80156d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801570:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801575:	ba 00 00 00 00       	mov    $0x0,%edx
  80157a:	b8 02 00 00 00       	mov    $0x2,%eax
  80157f:	e8 87 ff ff ff       	call   80150b <fsipc>
}
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <devfile_flush>:
{
  801586:	f3 0f 1e fb          	endbr32 
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801590:	8b 45 08             	mov    0x8(%ebp),%eax
  801593:	8b 40 0c             	mov    0xc(%eax),%eax
  801596:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8015a5:	e8 61 ff ff ff       	call   80150b <fsipc>
}
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <devfile_stat>:
{
  8015ac:	f3 0f 1e fb          	endbr32 
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 04             	sub    $0x4,%esp
  8015b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8015cf:	e8 37 ff ff ff       	call   80150b <fsipc>
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 2c                	js     801604 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	68 00 50 80 00       	push   $0x805000
  8015e0:	53                   	push   %ebx
  8015e1:	e8 51 f3 ff ff       	call   800937 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8015eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8015f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801604:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801607:	c9                   	leave  
  801608:	c3                   	ret    

00801609 <devfile_write>:
{
  801609:	f3 0f 1e fb          	endbr32 
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	8b 45 10             	mov    0x10(%ebp),%eax
  801616:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80161b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801620:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801623:	8b 55 08             	mov    0x8(%ebp),%edx
  801626:	8b 52 0c             	mov    0xc(%edx),%edx
  801629:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80162f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801634:	50                   	push   %eax
  801635:	ff 75 0c             	pushl  0xc(%ebp)
  801638:	68 08 50 80 00       	push   $0x805008
  80163d:	e8 f3 f4 ff ff       	call   800b35 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 04 00 00 00       	mov    $0x4,%eax
  80164c:	e8 ba fe ff ff       	call   80150b <fsipc>
}
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <devfile_read>:
{
  801653:	f3 0f 1e fb          	endbr32 
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	56                   	push   %esi
  80165b:	53                   	push   %ebx
  80165c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80165f:	8b 45 08             	mov    0x8(%ebp),%eax
  801662:	8b 40 0c             	mov    0xc(%eax),%eax
  801665:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80166a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
  801675:	b8 03 00 00 00       	mov    $0x3,%eax
  80167a:	e8 8c fe ff ff       	call   80150b <fsipc>
  80167f:	89 c3                	mov    %eax,%ebx
  801681:	85 c0                	test   %eax,%eax
  801683:	78 1f                	js     8016a4 <devfile_read+0x51>
	assert(r <= n);
  801685:	39 f0                	cmp    %esi,%eax
  801687:	77 24                	ja     8016ad <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801689:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80168e:	7f 36                	jg     8016c6 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801690:	83 ec 04             	sub    $0x4,%esp
  801693:	50                   	push   %eax
  801694:	68 00 50 80 00       	push   $0x805000
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	e8 94 f4 ff ff       	call   800b35 <memmove>
	return r;
  8016a1:	83 c4 10             	add    $0x10,%esp
}
  8016a4:	89 d8                	mov    %ebx,%eax
  8016a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    
	assert(r <= n);
  8016ad:	68 50 29 80 00       	push   $0x802950
  8016b2:	68 57 29 80 00       	push   $0x802957
  8016b7:	68 8c 00 00 00       	push   $0x8c
  8016bc:	68 6c 29 80 00       	push   $0x80296c
  8016c1:	e8 80 eb ff ff       	call   800246 <_panic>
	assert(r <= PGSIZE);
  8016c6:	68 77 29 80 00       	push   $0x802977
  8016cb:	68 57 29 80 00       	push   $0x802957
  8016d0:	68 8d 00 00 00       	push   $0x8d
  8016d5:	68 6c 29 80 00       	push   $0x80296c
  8016da:	e8 67 eb ff ff       	call   800246 <_panic>

008016df <open>:
{
  8016df:	f3 0f 1e fb          	endbr32 
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	56                   	push   %esi
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 1c             	sub    $0x1c,%esp
  8016eb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8016ee:	56                   	push   %esi
  8016ef:	e8 00 f2 ff ff       	call   8008f4 <strlen>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016fc:	7f 6c                	jg     80176a <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	e8 5c f8 ff ff       	call   800f66 <fd_alloc>
  80170a:	89 c3                	mov    %eax,%ebx
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 3c                	js     80174f <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	56                   	push   %esi
  801717:	68 00 50 80 00       	push   $0x805000
  80171c:	e8 16 f2 ff ff       	call   800937 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801721:	8b 45 0c             	mov    0xc(%ebp),%eax
  801724:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801729:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172c:	b8 01 00 00 00       	mov    $0x1,%eax
  801731:	e8 d5 fd ff ff       	call   80150b <fsipc>
  801736:	89 c3                	mov    %eax,%ebx
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 19                	js     801758 <open+0x79>
	return fd2num(fd);
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	ff 75 f4             	pushl  -0xc(%ebp)
  801745:	e8 ed f7 ff ff       	call   800f37 <fd2num>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 10             	add    $0x10,%esp
}
  80174f:	89 d8                	mov    %ebx,%eax
  801751:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801754:	5b                   	pop    %ebx
  801755:	5e                   	pop    %esi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    
		fd_close(fd, 0);
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	6a 00                	push   $0x0
  80175d:	ff 75 f4             	pushl  -0xc(%ebp)
  801760:	e8 0a f9 ff ff       	call   80106f <fd_close>
		return r;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	eb e5                	jmp    80174f <open+0x70>
		return -E_BAD_PATH;
  80176a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80176f:	eb de                	jmp    80174f <open+0x70>

00801771 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801771:	f3 0f 1e fb          	endbr32 
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80177b:	ba 00 00 00 00       	mov    $0x0,%edx
  801780:	b8 08 00 00 00       	mov    $0x8,%eax
  801785:	e8 81 fd ff ff       	call   80150b <fsipc>
}
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80178c:	f3 0f 1e fb          	endbr32 
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801796:	68 e3 29 80 00       	push   $0x8029e3
  80179b:	ff 75 0c             	pushl  0xc(%ebp)
  80179e:	e8 94 f1 ff ff       	call   800937 <strcpy>
	return 0;
}
  8017a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devsock_close>:
{
  8017aa:	f3 0f 1e fb          	endbr32 
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	53                   	push   %ebx
  8017b2:	83 ec 10             	sub    $0x10,%esp
  8017b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8017b8:	53                   	push   %ebx
  8017b9:	e8 83 0a 00 00       	call   802241 <pageref>
  8017be:	89 c2                	mov    %eax,%edx
  8017c0:	83 c4 10             	add    $0x10,%esp
		return 0;
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8017c8:	83 fa 01             	cmp    $0x1,%edx
  8017cb:	74 05                	je     8017d2 <devsock_close+0x28>
}
  8017cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	ff 73 0c             	pushl  0xc(%ebx)
  8017d8:	e8 e3 02 00 00       	call   801ac0 <nsipc_close>
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	eb eb                	jmp    8017cd <devsock_close+0x23>

008017e2 <devsock_write>:
{
  8017e2:	f3 0f 1e fb          	endbr32 
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8017ec:	6a 00                	push   $0x0
  8017ee:	ff 75 10             	pushl  0x10(%ebp)
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	ff 70 0c             	pushl  0xc(%eax)
  8017fa:	e8 b5 03 00 00       	call   801bb4 <nsipc_send>
}
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <devsock_read>:
{
  801801:	f3 0f 1e fb          	endbr32 
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80180b:	6a 00                	push   $0x0
  80180d:	ff 75 10             	pushl  0x10(%ebp)
  801810:	ff 75 0c             	pushl  0xc(%ebp)
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	ff 70 0c             	pushl  0xc(%eax)
  801819:	e8 1f 03 00 00       	call   801b3d <nsipc_recv>
}
  80181e:	c9                   	leave  
  80181f:	c3                   	ret    

00801820 <fd2sockid>:
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801826:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801829:	52                   	push   %edx
  80182a:	50                   	push   %eax
  80182b:	e8 8c f7 ff ff       	call   800fbc <fd_lookup>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	78 10                	js     801847 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183a:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801840:	39 08                	cmp    %ecx,(%eax)
  801842:	75 05                	jne    801849 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801844:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    
		return -E_NOT_SUPP;
  801849:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80184e:	eb f7                	jmp    801847 <fd2sockid+0x27>

00801850 <alloc_sockfd>:
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	83 ec 1c             	sub    $0x1c,%esp
  801858:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80185a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185d:	50                   	push   %eax
  80185e:	e8 03 f7 ff ff       	call   800f66 <fd_alloc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 43                	js     8018af <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	68 07 04 00 00       	push   $0x407
  801874:	ff 75 f4             	pushl  -0xc(%ebp)
  801877:	6a 00                	push   $0x0
  801879:	e8 22 f5 ff ff       	call   800da0 <sys_page_alloc>
  80187e:	89 c3                	mov    %eax,%ebx
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	78 28                	js     8018af <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801887:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188a:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801890:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801892:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801895:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80189c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80189f:	83 ec 0c             	sub    $0xc,%esp
  8018a2:	50                   	push   %eax
  8018a3:	e8 8f f6 ff ff       	call   800f37 <fd2num>
  8018a8:	89 c3                	mov    %eax,%ebx
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	eb 0c                	jmp    8018bb <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8018af:	83 ec 0c             	sub    $0xc,%esp
  8018b2:	56                   	push   %esi
  8018b3:	e8 08 02 00 00       	call   801ac0 <nsipc_close>
		return r;
  8018b8:	83 c4 10             	add    $0x10,%esp
}
  8018bb:	89 d8                	mov    %ebx,%eax
  8018bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c0:	5b                   	pop    %ebx
  8018c1:	5e                   	pop    %esi
  8018c2:	5d                   	pop    %ebp
  8018c3:	c3                   	ret    

008018c4 <accept>:
{
  8018c4:	f3 0f 1e fb          	endbr32 
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	e8 4a ff ff ff       	call   801820 <fd2sockid>
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 1b                	js     8018f5 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8018da:	83 ec 04             	sub    $0x4,%esp
  8018dd:	ff 75 10             	pushl  0x10(%ebp)
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	50                   	push   %eax
  8018e4:	e8 22 01 00 00       	call   801a0b <nsipc_accept>
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 05                	js     8018f5 <accept+0x31>
	return alloc_sockfd(r);
  8018f0:	e8 5b ff ff ff       	call   801850 <alloc_sockfd>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <bind>:
{
  8018f7:	f3 0f 1e fb          	endbr32 
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	e8 17 ff ff ff       	call   801820 <fd2sockid>
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 12                	js     80191f <bind+0x28>
	return nsipc_bind(r, name, namelen);
  80190d:	83 ec 04             	sub    $0x4,%esp
  801910:	ff 75 10             	pushl  0x10(%ebp)
  801913:	ff 75 0c             	pushl  0xc(%ebp)
  801916:	50                   	push   %eax
  801917:	e8 45 01 00 00       	call   801a61 <nsipc_bind>
  80191c:	83 c4 10             	add    $0x10,%esp
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <shutdown>:
{
  801921:	f3 0f 1e fb          	endbr32 
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	e8 ed fe ff ff       	call   801820 <fd2sockid>
  801933:	85 c0                	test   %eax,%eax
  801935:	78 0f                	js     801946 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	ff 75 0c             	pushl  0xc(%ebp)
  80193d:	50                   	push   %eax
  80193e:	e8 57 01 00 00       	call   801a9a <nsipc_shutdown>
  801943:	83 c4 10             	add    $0x10,%esp
}
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <connect>:
{
  801948:	f3 0f 1e fb          	endbr32 
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	e8 c6 fe ff ff       	call   801820 <fd2sockid>
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 12                	js     801970 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  80195e:	83 ec 04             	sub    $0x4,%esp
  801961:	ff 75 10             	pushl  0x10(%ebp)
  801964:	ff 75 0c             	pushl  0xc(%ebp)
  801967:	50                   	push   %eax
  801968:	e8 71 01 00 00       	call   801ade <nsipc_connect>
  80196d:	83 c4 10             	add    $0x10,%esp
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <listen>:
{
  801972:	f3 0f 1e fb          	endbr32 
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	e8 9c fe ff ff       	call   801820 <fd2sockid>
  801984:	85 c0                	test   %eax,%eax
  801986:	78 0f                	js     801997 <listen+0x25>
	return nsipc_listen(r, backlog);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	ff 75 0c             	pushl  0xc(%ebp)
  80198e:	50                   	push   %eax
  80198f:	e8 83 01 00 00       	call   801b17 <nsipc_listen>
  801994:	83 c4 10             	add    $0x10,%esp
}
  801997:	c9                   	leave  
  801998:	c3                   	ret    

00801999 <socket>:

int
socket(int domain, int type, int protocol)
{
  801999:	f3 0f 1e fb          	endbr32 
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8019a3:	ff 75 10             	pushl  0x10(%ebp)
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	ff 75 08             	pushl  0x8(%ebp)
  8019ac:	e8 65 02 00 00       	call   801c16 <nsipc_socket>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 05                	js     8019bd <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8019b8:	e8 93 fe ff ff       	call   801850 <alloc_sockfd>
}
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 04             	sub    $0x4,%esp
  8019c6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8019c8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019cf:	74 26                	je     8019f7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8019d1:	6a 07                	push   $0x7
  8019d3:	68 00 60 80 00       	push   $0x806000
  8019d8:	53                   	push   %ebx
  8019d9:	ff 35 04 40 80 00    	pushl  0x804004
  8019df:	e8 c8 07 00 00       	call   8021ac <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8019e4:	83 c4 0c             	add    $0xc,%esp
  8019e7:	6a 00                	push   $0x0
  8019e9:	6a 00                	push   $0x0
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 4d 07 00 00       	call   80213f <ipc_recv>
}
  8019f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	6a 02                	push   $0x2
  8019fc:	e8 03 08 00 00       	call   802204 <ipc_find_env>
  801a01:	a3 04 40 80 00       	mov    %eax,0x804004
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	eb c6                	jmp    8019d1 <nsipc+0x12>

00801a0b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a0b:	f3 0f 1e fb          	endbr32 
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
  801a14:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a1f:	8b 06                	mov    (%esi),%eax
  801a21:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a26:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2b:	e8 8f ff ff ff       	call   8019bf <nsipc>
  801a30:	89 c3                	mov    %eax,%ebx
  801a32:	85 c0                	test   %eax,%eax
  801a34:	79 09                	jns    801a3f <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801a36:	89 d8                	mov    %ebx,%eax
  801a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	ff 35 10 60 80 00    	pushl  0x806010
  801a48:	68 00 60 80 00       	push   $0x806000
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	e8 e0 f0 ff ff       	call   800b35 <memmove>
		*addrlen = ret->ret_addrlen;
  801a55:	a1 10 60 80 00       	mov    0x806010,%eax
  801a5a:	89 06                	mov    %eax,(%esi)
  801a5c:	83 c4 10             	add    $0x10,%esp
	return r;
  801a5f:	eb d5                	jmp    801a36 <nsipc_accept+0x2b>

00801a61 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a61:	f3 0f 1e fb          	endbr32 
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	53                   	push   %ebx
  801a69:	83 ec 08             	sub    $0x8,%esp
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a72:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a77:	53                   	push   %ebx
  801a78:	ff 75 0c             	pushl  0xc(%ebp)
  801a7b:	68 04 60 80 00       	push   $0x806004
  801a80:	e8 b0 f0 ff ff       	call   800b35 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a85:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a8b:	b8 02 00 00 00       	mov    $0x2,%eax
  801a90:	e8 2a ff ff ff       	call   8019bf <nsipc>
}
  801a95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a9a:	f3 0f 1e fb          	endbr32 
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aaf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ab4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ab9:	e8 01 ff ff ff       	call   8019bf <nsipc>
}
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <nsipc_close>:

int
nsipc_close(int s)
{
  801ac0:	f3 0f 1e fb          	endbr32 
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801aca:	8b 45 08             	mov    0x8(%ebp),%eax
  801acd:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ad2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad7:	e8 e3 fe ff ff       	call   8019bf <nsipc>
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ade:	f3 0f 1e fb          	endbr32 
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801af4:	53                   	push   %ebx
  801af5:	ff 75 0c             	pushl  0xc(%ebp)
  801af8:	68 04 60 80 00       	push   $0x806004
  801afd:	e8 33 f0 ff ff       	call   800b35 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b02:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801b08:	b8 05 00 00 00       	mov    $0x5,%eax
  801b0d:	e8 ad fe ff ff       	call   8019bf <nsipc>
}
  801b12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    

00801b17 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b17:	f3 0f 1e fb          	endbr32 
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b21:	8b 45 08             	mov    0x8(%ebp),%eax
  801b24:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801b31:	b8 06 00 00 00       	mov    $0x6,%eax
  801b36:	e8 84 fe ff ff       	call   8019bf <nsipc>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b3d:	f3 0f 1e fb          	endbr32 
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	56                   	push   %esi
  801b45:	53                   	push   %ebx
  801b46:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b49:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801b51:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801b57:	8b 45 14             	mov    0x14(%ebp),%eax
  801b5a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b5f:	b8 07 00 00 00       	mov    $0x7,%eax
  801b64:	e8 56 fe ff ff       	call   8019bf <nsipc>
  801b69:	89 c3                	mov    %eax,%ebx
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 26                	js     801b95 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801b6f:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801b75:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801b7a:	0f 4e c6             	cmovle %esi,%eax
  801b7d:	39 c3                	cmp    %eax,%ebx
  801b7f:	7f 1d                	jg     801b9e <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b81:	83 ec 04             	sub    $0x4,%esp
  801b84:	53                   	push   %ebx
  801b85:	68 00 60 80 00       	push   $0x806000
  801b8a:	ff 75 0c             	pushl  0xc(%ebp)
  801b8d:	e8 a3 ef ff ff       	call   800b35 <memmove>
  801b92:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b95:	89 d8                	mov    %ebx,%eax
  801b97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9a:	5b                   	pop    %ebx
  801b9b:	5e                   	pop    %esi
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801b9e:	68 ef 29 80 00       	push   $0x8029ef
  801ba3:	68 57 29 80 00       	push   $0x802957
  801ba8:	6a 62                	push   $0x62
  801baa:	68 04 2a 80 00       	push   $0x802a04
  801baf:	e8 92 e6 ff ff       	call   800246 <_panic>

00801bb4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bb4:	f3 0f 1e fb          	endbr32 
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801bca:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801bd0:	7f 2e                	jg     801c00 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	53                   	push   %ebx
  801bd6:	ff 75 0c             	pushl  0xc(%ebp)
  801bd9:	68 0c 60 80 00       	push   $0x80600c
  801bde:	e8 52 ef ff ff       	call   800b35 <memmove>
	nsipcbuf.send.req_size = size;
  801be3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801be9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801bf1:	b8 08 00 00 00       	mov    $0x8,%eax
  801bf6:	e8 c4 fd ff ff       	call   8019bf <nsipc>
}
  801bfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    
	assert(size < 1600);
  801c00:	68 10 2a 80 00       	push   $0x802a10
  801c05:	68 57 29 80 00       	push   $0x802957
  801c0a:	6a 6d                	push   $0x6d
  801c0c:	68 04 2a 80 00       	push   $0x802a04
  801c11:	e8 30 e6 ff ff       	call   800246 <_panic>

00801c16 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c16:	f3 0f 1e fb          	endbr32 
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c20:	8b 45 08             	mov    0x8(%ebp),%eax
  801c23:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c30:	8b 45 10             	mov    0x10(%ebp),%eax
  801c33:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c38:	b8 09 00 00 00       	mov    $0x9,%eax
  801c3d:	e8 7d fd ff ff       	call   8019bf <nsipc>
}
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c44:	f3 0f 1e fb          	endbr32 
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	ff 75 08             	pushl  0x8(%ebp)
  801c56:	e8 f0 f2 ff ff       	call   800f4b <fd2data>
  801c5b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c5d:	83 c4 08             	add    $0x8,%esp
  801c60:	68 1c 2a 80 00       	push   $0x802a1c
  801c65:	53                   	push   %ebx
  801c66:	e8 cc ec ff ff       	call   800937 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c6b:	8b 46 04             	mov    0x4(%esi),%eax
  801c6e:	2b 06                	sub    (%esi),%eax
  801c70:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c7d:	00 00 00 
	stat->st_dev = &devpipe;
  801c80:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801c87:	30 80 00 
	return 0;
}
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c96:	f3 0f 1e fb          	endbr32 
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	53                   	push   %ebx
  801c9e:	83 ec 0c             	sub    $0xc,%esp
  801ca1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ca4:	53                   	push   %ebx
  801ca5:	6a 00                	push   $0x0
  801ca7:	e8 3f f1 ff ff       	call   800deb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cac:	89 1c 24             	mov    %ebx,(%esp)
  801caf:	e8 97 f2 ff ff       	call   800f4b <fd2data>
  801cb4:	83 c4 08             	add    $0x8,%esp
  801cb7:	50                   	push   %eax
  801cb8:	6a 00                	push   $0x0
  801cba:	e8 2c f1 ff ff       	call   800deb <sys_page_unmap>
}
  801cbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <_pipeisclosed>:
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	57                   	push   %edi
  801cc8:	56                   	push   %esi
  801cc9:	53                   	push   %ebx
  801cca:	83 ec 1c             	sub    $0x1c,%esp
  801ccd:	89 c7                	mov    %eax,%edi
  801ccf:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cd1:	a1 08 40 80 00       	mov    0x804008,%eax
  801cd6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	57                   	push   %edi
  801cdd:	e8 5f 05 00 00       	call   802241 <pageref>
  801ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ce5:	89 34 24             	mov    %esi,(%esp)
  801ce8:	e8 54 05 00 00       	call   802241 <pageref>
		nn = thisenv->env_runs;
  801ced:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801cf3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	39 cb                	cmp    %ecx,%ebx
  801cfb:	74 1b                	je     801d18 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cfd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d00:	75 cf                	jne    801cd1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d02:	8b 42 58             	mov    0x58(%edx),%eax
  801d05:	6a 01                	push   $0x1
  801d07:	50                   	push   %eax
  801d08:	53                   	push   %ebx
  801d09:	68 23 2a 80 00       	push   $0x802a23
  801d0e:	e8 1a e6 ff ff       	call   80032d <cprintf>
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	eb b9                	jmp    801cd1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d18:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d1b:	0f 94 c0             	sete   %al
  801d1e:	0f b6 c0             	movzbl %al,%eax
}
  801d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <devpipe_write>:
{
  801d29:	f3 0f 1e fb          	endbr32 
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	57                   	push   %edi
  801d31:	56                   	push   %esi
  801d32:	53                   	push   %ebx
  801d33:	83 ec 28             	sub    $0x28,%esp
  801d36:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d39:	56                   	push   %esi
  801d3a:	e8 0c f2 ff ff       	call   800f4b <fd2data>
  801d3f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	bf 00 00 00 00       	mov    $0x0,%edi
  801d49:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d4c:	74 4f                	je     801d9d <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d4e:	8b 43 04             	mov    0x4(%ebx),%eax
  801d51:	8b 0b                	mov    (%ebx),%ecx
  801d53:	8d 51 20             	lea    0x20(%ecx),%edx
  801d56:	39 d0                	cmp    %edx,%eax
  801d58:	72 14                	jb     801d6e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d5a:	89 da                	mov    %ebx,%edx
  801d5c:	89 f0                	mov    %esi,%eax
  801d5e:	e8 61 ff ff ff       	call   801cc4 <_pipeisclosed>
  801d63:	85 c0                	test   %eax,%eax
  801d65:	75 3b                	jne    801da2 <devpipe_write+0x79>
			sys_yield();
  801d67:	e8 11 f0 ff ff       	call   800d7d <sys_yield>
  801d6c:	eb e0                	jmp    801d4e <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d71:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d75:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d78:	89 c2                	mov    %eax,%edx
  801d7a:	c1 fa 1f             	sar    $0x1f,%edx
  801d7d:	89 d1                	mov    %edx,%ecx
  801d7f:	c1 e9 1b             	shr    $0x1b,%ecx
  801d82:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d85:	83 e2 1f             	and    $0x1f,%edx
  801d88:	29 ca                	sub    %ecx,%edx
  801d8a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d8e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d92:	83 c0 01             	add    $0x1,%eax
  801d95:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d98:	83 c7 01             	add    $0x1,%edi
  801d9b:	eb ac                	jmp    801d49 <devpipe_write+0x20>
	return i;
  801d9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801da0:	eb 05                	jmp    801da7 <devpipe_write+0x7e>
				return 0;
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <devpipe_read>:
{
  801daf:	f3 0f 1e fb          	endbr32 
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	57                   	push   %edi
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	83 ec 18             	sub    $0x18,%esp
  801dbc:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801dbf:	57                   	push   %edi
  801dc0:	e8 86 f1 ff ff       	call   800f4b <fd2data>
  801dc5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	be 00 00 00 00       	mov    $0x0,%esi
  801dcf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd2:	75 14                	jne    801de8 <devpipe_read+0x39>
	return i;
  801dd4:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd7:	eb 02                	jmp    801ddb <devpipe_read+0x2c>
				return i;
  801dd9:	89 f0                	mov    %esi,%eax
}
  801ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
			sys_yield();
  801de3:	e8 95 ef ff ff       	call   800d7d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801de8:	8b 03                	mov    (%ebx),%eax
  801dea:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ded:	75 18                	jne    801e07 <devpipe_read+0x58>
			if (i > 0)
  801def:	85 f6                	test   %esi,%esi
  801df1:	75 e6                	jne    801dd9 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801df3:	89 da                	mov    %ebx,%edx
  801df5:	89 f8                	mov    %edi,%eax
  801df7:	e8 c8 fe ff ff       	call   801cc4 <_pipeisclosed>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	74 e3                	je     801de3 <devpipe_read+0x34>
				return 0;
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
  801e05:	eb d4                	jmp    801ddb <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e07:	99                   	cltd   
  801e08:	c1 ea 1b             	shr    $0x1b,%edx
  801e0b:	01 d0                	add    %edx,%eax
  801e0d:	83 e0 1f             	and    $0x1f,%eax
  801e10:	29 d0                	sub    %edx,%eax
  801e12:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e1d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e20:	83 c6 01             	add    $0x1,%esi
  801e23:	eb aa                	jmp    801dcf <devpipe_read+0x20>

00801e25 <pipe>:
{
  801e25:	f3 0f 1e fb          	endbr32 
  801e29:	55                   	push   %ebp
  801e2a:	89 e5                	mov    %esp,%ebp
  801e2c:	56                   	push   %esi
  801e2d:	53                   	push   %ebx
  801e2e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	e8 2c f1 ff ff       	call   800f66 <fd_alloc>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	0f 88 23 01 00 00    	js     801f6a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e47:	83 ec 04             	sub    $0x4,%esp
  801e4a:	68 07 04 00 00       	push   $0x407
  801e4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e52:	6a 00                	push   $0x0
  801e54:	e8 47 ef ff ff       	call   800da0 <sys_page_alloc>
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	0f 88 04 01 00 00    	js     801f6a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e6c:	50                   	push   %eax
  801e6d:	e8 f4 f0 ff ff       	call   800f66 <fd_alloc>
  801e72:	89 c3                	mov    %eax,%ebx
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	85 c0                	test   %eax,%eax
  801e79:	0f 88 db 00 00 00    	js     801f5a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7f:	83 ec 04             	sub    $0x4,%esp
  801e82:	68 07 04 00 00       	push   $0x407
  801e87:	ff 75 f0             	pushl  -0x10(%ebp)
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 0f ef ff ff       	call   800da0 <sys_page_alloc>
  801e91:	89 c3                	mov    %eax,%ebx
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	0f 88 bc 00 00 00    	js     801f5a <pipe+0x135>
	va = fd2data(fd0);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea4:	e8 a2 f0 ff ff       	call   800f4b <fd2data>
  801ea9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eab:	83 c4 0c             	add    $0xc,%esp
  801eae:	68 07 04 00 00       	push   $0x407
  801eb3:	50                   	push   %eax
  801eb4:	6a 00                	push   $0x0
  801eb6:	e8 e5 ee ff ff       	call   800da0 <sys_page_alloc>
  801ebb:	89 c3                	mov    %eax,%ebx
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	0f 88 82 00 00 00    	js     801f4a <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ece:	e8 78 f0 ff ff       	call   800f4b <fd2data>
  801ed3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eda:	50                   	push   %eax
  801edb:	6a 00                	push   $0x0
  801edd:	56                   	push   %esi
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 e1 ee ff ff       	call   800dc6 <sys_page_map>
  801ee5:	89 c3                	mov    %eax,%ebx
  801ee7:	83 c4 20             	add    $0x20,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	78 4e                	js     801f3c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801eee:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801ef3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ef6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801efb:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f02:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f05:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	ff 75 f4             	pushl  -0xc(%ebp)
  801f17:	e8 1b f0 ff ff       	call   800f37 <fd2num>
  801f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f1f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f21:	83 c4 04             	add    $0x4,%esp
  801f24:	ff 75 f0             	pushl  -0x10(%ebp)
  801f27:	e8 0b f0 ff ff       	call   800f37 <fd2num>
  801f2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f2f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f3a:	eb 2e                	jmp    801f6a <pipe+0x145>
	sys_page_unmap(0, va);
  801f3c:	83 ec 08             	sub    $0x8,%esp
  801f3f:	56                   	push   %esi
  801f40:	6a 00                	push   $0x0
  801f42:	e8 a4 ee ff ff       	call   800deb <sys_page_unmap>
  801f47:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f4a:	83 ec 08             	sub    $0x8,%esp
  801f4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f50:	6a 00                	push   $0x0
  801f52:	e8 94 ee ff ff       	call   800deb <sys_page_unmap>
  801f57:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f5a:	83 ec 08             	sub    $0x8,%esp
  801f5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f60:	6a 00                	push   $0x0
  801f62:	e8 84 ee ff ff       	call   800deb <sys_page_unmap>
  801f67:	83 c4 10             	add    $0x10,%esp
}
  801f6a:	89 d8                	mov    %ebx,%eax
  801f6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <pipeisclosed>:
{
  801f73:	f3 0f 1e fb          	endbr32 
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f80:	50                   	push   %eax
  801f81:	ff 75 08             	pushl  0x8(%ebp)
  801f84:	e8 33 f0 ff ff       	call   800fbc <fd_lookup>
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 18                	js     801fa8 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	ff 75 f4             	pushl  -0xc(%ebp)
  801f96:	e8 b0 ef ff ff       	call   800f4b <fd2data>
  801f9b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa0:	e8 1f fd ff ff       	call   801cc4 <_pipeisclosed>
  801fa5:	83 c4 10             	add    $0x10,%esp
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801faa:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb3:	c3                   	ret    

00801fb4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fb4:	f3 0f 1e fb          	endbr32 
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fbe:	68 3b 2a 80 00       	push   $0x802a3b
  801fc3:	ff 75 0c             	pushl  0xc(%ebp)
  801fc6:	e8 6c e9 ff ff       	call   800937 <strcpy>
	return 0;
}
  801fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <devcons_write>:
{
  801fd2:	f3 0f 1e fb          	endbr32 
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	57                   	push   %edi
  801fda:	56                   	push   %esi
  801fdb:	53                   	push   %ebx
  801fdc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fe2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fe7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fed:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ff0:	73 31                	jae    802023 <devcons_write+0x51>
		m = n - tot;
  801ff2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ff5:	29 f3                	sub    %esi,%ebx
  801ff7:	83 fb 7f             	cmp    $0x7f,%ebx
  801ffa:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fff:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802002:	83 ec 04             	sub    $0x4,%esp
  802005:	53                   	push   %ebx
  802006:	89 f0                	mov    %esi,%eax
  802008:	03 45 0c             	add    0xc(%ebp),%eax
  80200b:	50                   	push   %eax
  80200c:	57                   	push   %edi
  80200d:	e8 23 eb ff ff       	call   800b35 <memmove>
		sys_cputs(buf, m);
  802012:	83 c4 08             	add    $0x8,%esp
  802015:	53                   	push   %ebx
  802016:	57                   	push   %edi
  802017:	e8 d5 ec ff ff       	call   800cf1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80201c:	01 de                	add    %ebx,%esi
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	eb ca                	jmp    801fed <devcons_write+0x1b>
}
  802023:	89 f0                	mov    %esi,%eax
  802025:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802028:	5b                   	pop    %ebx
  802029:	5e                   	pop    %esi
  80202a:	5f                   	pop    %edi
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <devcons_read>:
{
  80202d:	f3 0f 1e fb          	endbr32 
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	83 ec 08             	sub    $0x8,%esp
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80203c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802040:	74 21                	je     802063 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802042:	e8 cc ec ff ff       	call   800d13 <sys_cgetc>
  802047:	85 c0                	test   %eax,%eax
  802049:	75 07                	jne    802052 <devcons_read+0x25>
		sys_yield();
  80204b:	e8 2d ed ff ff       	call   800d7d <sys_yield>
  802050:	eb f0                	jmp    802042 <devcons_read+0x15>
	if (c < 0)
  802052:	78 0f                	js     802063 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802054:	83 f8 04             	cmp    $0x4,%eax
  802057:	74 0c                	je     802065 <devcons_read+0x38>
	*(char*)vbuf = c;
  802059:	8b 55 0c             	mov    0xc(%ebp),%edx
  80205c:	88 02                	mov    %al,(%edx)
	return 1;
  80205e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    
		return 0;
  802065:	b8 00 00 00 00       	mov    $0x0,%eax
  80206a:	eb f7                	jmp    802063 <devcons_read+0x36>

0080206c <cputchar>:
{
  80206c:	f3 0f 1e fb          	endbr32 
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802076:	8b 45 08             	mov    0x8(%ebp),%eax
  802079:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80207c:	6a 01                	push   $0x1
  80207e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802081:	50                   	push   %eax
  802082:	e8 6a ec ff ff       	call   800cf1 <sys_cputs>
}
  802087:	83 c4 10             	add    $0x10,%esp
  80208a:	c9                   	leave  
  80208b:	c3                   	ret    

0080208c <getchar>:
{
  80208c:	f3 0f 1e fb          	endbr32 
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802096:	6a 01                	push   $0x1
  802098:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209b:	50                   	push   %eax
  80209c:	6a 00                	push   $0x0
  80209e:	e8 a1 f1 ff ff       	call   801244 <read>
	if (r < 0)
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 06                	js     8020b0 <getchar+0x24>
	if (r < 1)
  8020aa:	74 06                	je     8020b2 <getchar+0x26>
	return c;
  8020ac:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    
		return -E_EOF;
  8020b2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020b7:	eb f7                	jmp    8020b0 <getchar+0x24>

008020b9 <iscons>:
{
  8020b9:	f3 0f 1e fb          	endbr32 
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c6:	50                   	push   %eax
  8020c7:	ff 75 08             	pushl  0x8(%ebp)
  8020ca:	e8 ed ee ff ff       	call   800fbc <fd_lookup>
  8020cf:	83 c4 10             	add    $0x10,%esp
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	78 11                	js     8020e7 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d9:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8020df:	39 10                	cmp    %edx,(%eax)
  8020e1:	0f 94 c0             	sete   %al
  8020e4:	0f b6 c0             	movzbl %al,%eax
}
  8020e7:	c9                   	leave  
  8020e8:	c3                   	ret    

008020e9 <opencons>:
{
  8020e9:	f3 0f 1e fb          	endbr32 
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	50                   	push   %eax
  8020f7:	e8 6a ee ff ff       	call   800f66 <fd_alloc>
  8020fc:	83 c4 10             	add    $0x10,%esp
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 3a                	js     80213d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802103:	83 ec 04             	sub    $0x4,%esp
  802106:	68 07 04 00 00       	push   $0x407
  80210b:	ff 75 f4             	pushl  -0xc(%ebp)
  80210e:	6a 00                	push   $0x0
  802110:	e8 8b ec ff ff       	call   800da0 <sys_page_alloc>
  802115:	83 c4 10             	add    $0x10,%esp
  802118:	85 c0                	test   %eax,%eax
  80211a:	78 21                	js     80213d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80211c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211f:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802125:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802131:	83 ec 0c             	sub    $0xc,%esp
  802134:	50                   	push   %eax
  802135:	e8 fd ed ff ff       	call   800f37 <fd2num>
  80213a:	83 c4 10             	add    $0x10,%esp
}
  80213d:	c9                   	leave  
  80213e:	c3                   	ret    

0080213f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80213f:	f3 0f 1e fb          	endbr32 
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	56                   	push   %esi
  802147:	53                   	push   %ebx
  802148:	8b 75 08             	mov    0x8(%ebp),%esi
  80214b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802151:	85 c0                	test   %eax,%eax
  802153:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802158:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80215b:	83 ec 0c             	sub    $0xc,%esp
  80215e:	50                   	push   %eax
  80215f:	e8 42 ed ff ff       	call   800ea6 <sys_ipc_recv>
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	85 c0                	test   %eax,%eax
  802169:	75 2b                	jne    802196 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80216b:	85 f6                	test   %esi,%esi
  80216d:	74 0a                	je     802179 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80216f:	a1 08 40 80 00       	mov    0x804008,%eax
  802174:	8b 40 74             	mov    0x74(%eax),%eax
  802177:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802179:	85 db                	test   %ebx,%ebx
  80217b:	74 0a                	je     802187 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80217d:	a1 08 40 80 00       	mov    0x804008,%eax
  802182:	8b 40 78             	mov    0x78(%eax),%eax
  802185:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802187:	a1 08 40 80 00       	mov    0x804008,%eax
  80218c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80218f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802192:	5b                   	pop    %ebx
  802193:	5e                   	pop    %esi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802196:	85 f6                	test   %esi,%esi
  802198:	74 06                	je     8021a0 <ipc_recv+0x61>
  80219a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8021a0:	85 db                	test   %ebx,%ebx
  8021a2:	74 eb                	je     80218f <ipc_recv+0x50>
  8021a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021aa:	eb e3                	jmp    80218f <ipc_recv+0x50>

008021ac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021ac:	f3 0f 1e fb          	endbr32 
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	57                   	push   %edi
  8021b4:	56                   	push   %esi
  8021b5:	53                   	push   %ebx
  8021b6:	83 ec 0c             	sub    $0xc,%esp
  8021b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8021c2:	85 db                	test   %ebx,%ebx
  8021c4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021c9:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8021cc:	ff 75 14             	pushl  0x14(%ebp)
  8021cf:	53                   	push   %ebx
  8021d0:	56                   	push   %esi
  8021d1:	57                   	push   %edi
  8021d2:	e8 a8 ec ff ff       	call   800e7f <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8021d7:	83 c4 10             	add    $0x10,%esp
  8021da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021dd:	75 07                	jne    8021e6 <ipc_send+0x3a>
			sys_yield();
  8021df:	e8 99 eb ff ff       	call   800d7d <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8021e4:	eb e6                	jmp    8021cc <ipc_send+0x20>
		}
		else if (ret == 0)
  8021e6:	85 c0                	test   %eax,%eax
  8021e8:	75 08                	jne    8021f2 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8021ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8021f2:	50                   	push   %eax
  8021f3:	68 47 2a 80 00       	push   $0x802a47
  8021f8:	6a 48                	push   $0x48
  8021fa:	68 55 2a 80 00       	push   $0x802a55
  8021ff:	e8 42 e0 ff ff       	call   800246 <_panic>

00802204 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802204:	f3 0f 1e fb          	endbr32 
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802213:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802216:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80221c:	8b 52 50             	mov    0x50(%edx),%edx
  80221f:	39 ca                	cmp    %ecx,%edx
  802221:	74 11                	je     802234 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802223:	83 c0 01             	add    $0x1,%eax
  802226:	3d 00 04 00 00       	cmp    $0x400,%eax
  80222b:	75 e6                	jne    802213 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
  802232:	eb 0b                	jmp    80223f <ipc_find_env+0x3b>
			return envs[i].env_id;
  802234:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802237:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80223c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    

00802241 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802241:	f3 0f 1e fb          	endbr32 
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80224b:	89 c2                	mov    %eax,%edx
  80224d:	c1 ea 16             	shr    $0x16,%edx
  802250:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802257:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80225c:	f6 c1 01             	test   $0x1,%cl
  80225f:	74 1c                	je     80227d <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802261:	c1 e8 0c             	shr    $0xc,%eax
  802264:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80226b:	a8 01                	test   $0x1,%al
  80226d:	74 0e                	je     80227d <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80226f:	c1 e8 0c             	shr    $0xc,%eax
  802272:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802279:	ef 
  80227a:	0f b7 d2             	movzwl %dx,%edx
}
  80227d:	89 d0                	mov    %edx,%eax
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    
  802281:	66 90                	xchg   %ax,%ax
  802283:	66 90                	xchg   %ax,%ax
  802285:	66 90                	xchg   %ax,%ax
  802287:	66 90                	xchg   %ax,%ax
  802289:	66 90                	xchg   %ax,%ax
  80228b:	66 90                	xchg   %ax,%ax
  80228d:	66 90                	xchg   %ax,%ax
  80228f:	90                   	nop

00802290 <__udivdi3>:
  802290:	f3 0f 1e fb          	endbr32 
  802294:	55                   	push   %ebp
  802295:	57                   	push   %edi
  802296:	56                   	push   %esi
  802297:	53                   	push   %ebx
  802298:	83 ec 1c             	sub    $0x1c,%esp
  80229b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022ab:	85 d2                	test   %edx,%edx
  8022ad:	75 19                	jne    8022c8 <__udivdi3+0x38>
  8022af:	39 f3                	cmp    %esi,%ebx
  8022b1:	76 4d                	jbe    802300 <__udivdi3+0x70>
  8022b3:	31 ff                	xor    %edi,%edi
  8022b5:	89 e8                	mov    %ebp,%eax
  8022b7:	89 f2                	mov    %esi,%edx
  8022b9:	f7 f3                	div    %ebx
  8022bb:	89 fa                	mov    %edi,%edx
  8022bd:	83 c4 1c             	add    $0x1c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	39 f2                	cmp    %esi,%edx
  8022ca:	76 14                	jbe    8022e0 <__udivdi3+0x50>
  8022cc:	31 ff                	xor    %edi,%edi
  8022ce:	31 c0                	xor    %eax,%eax
  8022d0:	89 fa                	mov    %edi,%edx
  8022d2:	83 c4 1c             	add    $0x1c,%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5f                   	pop    %edi
  8022d8:	5d                   	pop    %ebp
  8022d9:	c3                   	ret    
  8022da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e0:	0f bd fa             	bsr    %edx,%edi
  8022e3:	83 f7 1f             	xor    $0x1f,%edi
  8022e6:	75 48                	jne    802330 <__udivdi3+0xa0>
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	72 06                	jb     8022f2 <__udivdi3+0x62>
  8022ec:	31 c0                	xor    %eax,%eax
  8022ee:	39 eb                	cmp    %ebp,%ebx
  8022f0:	77 de                	ja     8022d0 <__udivdi3+0x40>
  8022f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f7:	eb d7                	jmp    8022d0 <__udivdi3+0x40>
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d9                	mov    %ebx,%ecx
  802302:	85 db                	test   %ebx,%ebx
  802304:	75 0b                	jne    802311 <__udivdi3+0x81>
  802306:	b8 01 00 00 00       	mov    $0x1,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	f7 f3                	div    %ebx
  80230f:	89 c1                	mov    %eax,%ecx
  802311:	31 d2                	xor    %edx,%edx
  802313:	89 f0                	mov    %esi,%eax
  802315:	f7 f1                	div    %ecx
  802317:	89 c6                	mov    %eax,%esi
  802319:	89 e8                	mov    %ebp,%eax
  80231b:	89 f7                	mov    %esi,%edi
  80231d:	f7 f1                	div    %ecx
  80231f:	89 fa                	mov    %edi,%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 f9                	mov    %edi,%ecx
  802332:	b8 20 00 00 00       	mov    $0x20,%eax
  802337:	29 f8                	sub    %edi,%eax
  802339:	d3 e2                	shl    %cl,%edx
  80233b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80233f:	89 c1                	mov    %eax,%ecx
  802341:	89 da                	mov    %ebx,%edx
  802343:	d3 ea                	shr    %cl,%edx
  802345:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802349:	09 d1                	or     %edx,%ecx
  80234b:	89 f2                	mov    %esi,%edx
  80234d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802351:	89 f9                	mov    %edi,%ecx
  802353:	d3 e3                	shl    %cl,%ebx
  802355:	89 c1                	mov    %eax,%ecx
  802357:	d3 ea                	shr    %cl,%edx
  802359:	89 f9                	mov    %edi,%ecx
  80235b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80235f:	89 eb                	mov    %ebp,%ebx
  802361:	d3 e6                	shl    %cl,%esi
  802363:	89 c1                	mov    %eax,%ecx
  802365:	d3 eb                	shr    %cl,%ebx
  802367:	09 de                	or     %ebx,%esi
  802369:	89 f0                	mov    %esi,%eax
  80236b:	f7 74 24 08          	divl   0x8(%esp)
  80236f:	89 d6                	mov    %edx,%esi
  802371:	89 c3                	mov    %eax,%ebx
  802373:	f7 64 24 0c          	mull   0xc(%esp)
  802377:	39 d6                	cmp    %edx,%esi
  802379:	72 15                	jb     802390 <__udivdi3+0x100>
  80237b:	89 f9                	mov    %edi,%ecx
  80237d:	d3 e5                	shl    %cl,%ebp
  80237f:	39 c5                	cmp    %eax,%ebp
  802381:	73 04                	jae    802387 <__udivdi3+0xf7>
  802383:	39 d6                	cmp    %edx,%esi
  802385:	74 09                	je     802390 <__udivdi3+0x100>
  802387:	89 d8                	mov    %ebx,%eax
  802389:	31 ff                	xor    %edi,%edi
  80238b:	e9 40 ff ff ff       	jmp    8022d0 <__udivdi3+0x40>
  802390:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802393:	31 ff                	xor    %edi,%edi
  802395:	e9 36 ff ff ff       	jmp    8022d0 <__udivdi3+0x40>
  80239a:	66 90                	xchg   %ax,%ax
  80239c:	66 90                	xchg   %ax,%ax
  80239e:	66 90                	xchg   %ax,%ax

008023a0 <__umoddi3>:
  8023a0:	f3 0f 1e fb          	endbr32 
  8023a4:	55                   	push   %ebp
  8023a5:	57                   	push   %edi
  8023a6:	56                   	push   %esi
  8023a7:	53                   	push   %ebx
  8023a8:	83 ec 1c             	sub    $0x1c,%esp
  8023ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	75 19                	jne    8023d8 <__umoddi3+0x38>
  8023bf:	39 df                	cmp    %ebx,%edi
  8023c1:	76 5d                	jbe    802420 <__umoddi3+0x80>
  8023c3:	89 f0                	mov    %esi,%eax
  8023c5:	89 da                	mov    %ebx,%edx
  8023c7:	f7 f7                	div    %edi
  8023c9:	89 d0                	mov    %edx,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	83 c4 1c             	add    $0x1c,%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    
  8023d5:	8d 76 00             	lea    0x0(%esi),%esi
  8023d8:	89 f2                	mov    %esi,%edx
  8023da:	39 d8                	cmp    %ebx,%eax
  8023dc:	76 12                	jbe    8023f0 <__umoddi3+0x50>
  8023de:	89 f0                	mov    %esi,%eax
  8023e0:	89 da                	mov    %ebx,%edx
  8023e2:	83 c4 1c             	add    $0x1c,%esp
  8023e5:	5b                   	pop    %ebx
  8023e6:	5e                   	pop    %esi
  8023e7:	5f                   	pop    %edi
  8023e8:	5d                   	pop    %ebp
  8023e9:	c3                   	ret    
  8023ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f0:	0f bd e8             	bsr    %eax,%ebp
  8023f3:	83 f5 1f             	xor    $0x1f,%ebp
  8023f6:	75 50                	jne    802448 <__umoddi3+0xa8>
  8023f8:	39 d8                	cmp    %ebx,%eax
  8023fa:	0f 82 e0 00 00 00    	jb     8024e0 <__umoddi3+0x140>
  802400:	89 d9                	mov    %ebx,%ecx
  802402:	39 f7                	cmp    %esi,%edi
  802404:	0f 86 d6 00 00 00    	jbe    8024e0 <__umoddi3+0x140>
  80240a:	89 d0                	mov    %edx,%eax
  80240c:	89 ca                	mov    %ecx,%edx
  80240e:	83 c4 1c             	add    $0x1c,%esp
  802411:	5b                   	pop    %ebx
  802412:	5e                   	pop    %esi
  802413:	5f                   	pop    %edi
  802414:	5d                   	pop    %ebp
  802415:	c3                   	ret    
  802416:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80241d:	8d 76 00             	lea    0x0(%esi),%esi
  802420:	89 fd                	mov    %edi,%ebp
  802422:	85 ff                	test   %edi,%edi
  802424:	75 0b                	jne    802431 <__umoddi3+0x91>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f7                	div    %edi
  80242f:	89 c5                	mov    %eax,%ebp
  802431:	89 d8                	mov    %ebx,%eax
  802433:	31 d2                	xor    %edx,%edx
  802435:	f7 f5                	div    %ebp
  802437:	89 f0                	mov    %esi,%eax
  802439:	f7 f5                	div    %ebp
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	31 d2                	xor    %edx,%edx
  80243f:	eb 8c                	jmp    8023cd <__umoddi3+0x2d>
  802441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802448:	89 e9                	mov    %ebp,%ecx
  80244a:	ba 20 00 00 00       	mov    $0x20,%edx
  80244f:	29 ea                	sub    %ebp,%edx
  802451:	d3 e0                	shl    %cl,%eax
  802453:	89 44 24 08          	mov    %eax,0x8(%esp)
  802457:	89 d1                	mov    %edx,%ecx
  802459:	89 f8                	mov    %edi,%eax
  80245b:	d3 e8                	shr    %cl,%eax
  80245d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802461:	89 54 24 04          	mov    %edx,0x4(%esp)
  802465:	8b 54 24 04          	mov    0x4(%esp),%edx
  802469:	09 c1                	or     %eax,%ecx
  80246b:	89 d8                	mov    %ebx,%eax
  80246d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802471:	89 e9                	mov    %ebp,%ecx
  802473:	d3 e7                	shl    %cl,%edi
  802475:	89 d1                	mov    %edx,%ecx
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80247f:	d3 e3                	shl    %cl,%ebx
  802481:	89 c7                	mov    %eax,%edi
  802483:	89 d1                	mov    %edx,%ecx
  802485:	89 f0                	mov    %esi,%eax
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	89 fa                	mov    %edi,%edx
  80248d:	d3 e6                	shl    %cl,%esi
  80248f:	09 d8                	or     %ebx,%eax
  802491:	f7 74 24 08          	divl   0x8(%esp)
  802495:	89 d1                	mov    %edx,%ecx
  802497:	89 f3                	mov    %esi,%ebx
  802499:	f7 64 24 0c          	mull   0xc(%esp)
  80249d:	89 c6                	mov    %eax,%esi
  80249f:	89 d7                	mov    %edx,%edi
  8024a1:	39 d1                	cmp    %edx,%ecx
  8024a3:	72 06                	jb     8024ab <__umoddi3+0x10b>
  8024a5:	75 10                	jne    8024b7 <__umoddi3+0x117>
  8024a7:	39 c3                	cmp    %eax,%ebx
  8024a9:	73 0c                	jae    8024b7 <__umoddi3+0x117>
  8024ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8024af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024b3:	89 d7                	mov    %edx,%edi
  8024b5:	89 c6                	mov    %eax,%esi
  8024b7:	89 ca                	mov    %ecx,%edx
  8024b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024be:	29 f3                	sub    %esi,%ebx
  8024c0:	19 fa                	sbb    %edi,%edx
  8024c2:	89 d0                	mov    %edx,%eax
  8024c4:	d3 e0                	shl    %cl,%eax
  8024c6:	89 e9                	mov    %ebp,%ecx
  8024c8:	d3 eb                	shr    %cl,%ebx
  8024ca:	d3 ea                	shr    %cl,%edx
  8024cc:	09 d8                	or     %ebx,%eax
  8024ce:	83 c4 1c             	add    $0x1c,%esp
  8024d1:	5b                   	pop    %ebx
  8024d2:	5e                   	pop    %esi
  8024d3:	5f                   	pop    %edi
  8024d4:	5d                   	pop    %ebp
  8024d5:	c3                   	ret    
  8024d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024dd:	8d 76 00             	lea    0x0(%esi),%esi
  8024e0:	29 fe                	sub    %edi,%esi
  8024e2:	19 c3                	sbb    %eax,%ebx
  8024e4:	89 f2                	mov    %esi,%edx
  8024e6:	89 d9                	mov    %ebx,%ecx
  8024e8:	e9 1d ff ff ff       	jmp    80240a <__umoddi3+0x6a>
