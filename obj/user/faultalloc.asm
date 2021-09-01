
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 a1 00 00 00       	call   8000d2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>
#include <inc/x86.h>
void
handler(struct UTrapframe *utf)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003e:	8b 45 08             	mov    0x8(%ebp),%eax
  800041:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800043:	53                   	push   %ebx
  800044:	68 80 24 80 00       	push   $0x802480
  800049:	e8 d3 01 00 00       	call   800221 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 32 0c 00 00       	call   800c94 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e\n", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x\n", addr);
  800069:	53                   	push   %ebx
  80006a:	68 cc 24 80 00       	push   $0x8024cc
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 53 07 00 00       	call   8007ca <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e\n", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 a0 24 80 00       	push   $0x8024a0
  800089:	6a 0e                	push   $0xe
  80008b:	68 8a 24 80 00       	push   $0x80248a
  800090:	e8 a5 00 00 00       	call   80013a <_panic>

00800095 <umain>:


void
umain(int argc, char **argv)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80009f:	68 33 00 80 00       	push   $0x800033
  8000a4:	e8 82 0d 00 00       	call   800e2b <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 9c 24 80 00       	push   $0x80249c
  8000b6:	e8 66 01 00 00       	call   800221 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 9c 24 80 00       	push   $0x80249c
  8000c8:	e8 54 01 00 00       	call   800221 <cprintf>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e1:	e8 68 0b 00 00       	call   800c4e <sys_getenvid>
  8000e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f3:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f8:	85 db                	test   %ebx,%ebx
  8000fa:	7e 07                	jle    800103 <libmain+0x31>
		binaryname = argv[0];
  8000fc:	8b 06                	mov    (%esi),%eax
  8000fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	e8 88 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  80010d:	e8 0a 00 00 00       	call   80011c <exit>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	f3 0f 1e fb          	endbr32 
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800126:	e8 8b 0f 00 00       	call   8010b6 <close_all>
	sys_env_destroy(0);
  80012b:	83 ec 0c             	sub    $0xc,%esp
  80012e:	6a 00                	push   $0x0
  800130:	e8 f5 0a 00 00       	call   800c2a <sys_env_destroy>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	c9                   	leave  
  800139:	c3                   	ret    

0080013a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013a:	f3 0f 1e fb          	endbr32 
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800143:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800146:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014c:	e8 fd 0a 00 00       	call   800c4e <sys_getenvid>
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	ff 75 0c             	pushl  0xc(%ebp)
  800157:	ff 75 08             	pushl  0x8(%ebp)
  80015a:	56                   	push   %esi
  80015b:	50                   	push   %eax
  80015c:	68 f8 24 80 00       	push   $0x8024f8
  800161:	e8 bb 00 00 00       	call   800221 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800166:	83 c4 18             	add    $0x18,%esp
  800169:	53                   	push   %ebx
  80016a:	ff 75 10             	pushl  0x10(%ebp)
  80016d:	e8 5a 00 00 00       	call   8001cc <vcprintf>
	cprintf("\n");
  800172:	c7 04 24 04 2a 80 00 	movl   $0x802a04,(%esp)
  800179:	e8 a3 00 00 00       	call   800221 <cprintf>
  80017e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800181:	cc                   	int3   
  800182:	eb fd                	jmp    800181 <_panic+0x47>

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	f3 0f 1e fb          	endbr32 
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	53                   	push   %ebx
  80018c:	83 ec 04             	sub    $0x4,%esp
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800192:	8b 13                	mov    (%ebx),%edx
  800194:	8d 42 01             	lea    0x1(%edx),%eax
  800197:	89 03                	mov    %eax,(%ebx)
  800199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a5:	74 09                	je     8001b0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	68 ff 00 00 00       	push   $0xff
  8001b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bb:	50                   	push   %eax
  8001bc:	e8 24 0a 00 00       	call   800be5 <sys_cputs>
		b->idx = 0;
  8001c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c7:	83 c4 10             	add    $0x10,%esp
  8001ca:	eb db                	jmp    8001a7 <putch+0x23>

008001cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cc:	f3 0f 1e fb          	endbr32 
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e0:	00 00 00 
	b.cnt = 0;
  8001e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ed:	ff 75 0c             	pushl  0xc(%ebp)
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f9:	50                   	push   %eax
  8001fa:	68 84 01 80 00       	push   $0x800184
  8001ff:	e8 20 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800204:	83 c4 08             	add    $0x8,%esp
  800207:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800213:	50                   	push   %eax
  800214:	e8 cc 09 00 00       	call   800be5 <sys_cputs>

	return b.cnt;
}
  800219:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800221:	f3 0f 1e fb          	endbr32 
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022e:	50                   	push   %eax
  80022f:	ff 75 08             	pushl  0x8(%ebp)
  800232:	e8 95 ff ff ff       	call   8001cc <vcprintf>
	va_end(ap);

	return cnt;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 1c             	sub    $0x1c,%esp
  800242:	89 c7                	mov    %eax,%edi
  800244:	89 d6                	mov    %edx,%esi
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024c:	89 d1                	mov    %edx,%ecx
  80024e:	89 c2                	mov    %eax,%edx
  800250:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800253:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800256:	8b 45 10             	mov    0x10(%ebp),%eax
  800259:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80025c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800266:	39 c2                	cmp    %eax,%edx
  800268:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026b:	72 3e                	jb     8002ab <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	83 eb 01             	sub    $0x1,%ebx
  800276:	53                   	push   %ebx
  800277:	50                   	push   %eax
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027e:	ff 75 e0             	pushl  -0x20(%ebp)
  800281:	ff 75 dc             	pushl  -0x24(%ebp)
  800284:	ff 75 d8             	pushl  -0x28(%ebp)
  800287:	e8 84 1f 00 00       	call   802210 <__udivdi3>
  80028c:	83 c4 18             	add    $0x18,%esp
  80028f:	52                   	push   %edx
  800290:	50                   	push   %eax
  800291:	89 f2                	mov    %esi,%edx
  800293:	89 f8                	mov    %edi,%eax
  800295:	e8 9f ff ff ff       	call   800239 <printnum>
  80029a:	83 c4 20             	add    $0x20,%esp
  80029d:	eb 13                	jmp    8002b2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	56                   	push   %esi
  8002a3:	ff 75 18             	pushl  0x18(%ebp)
  8002a6:	ff d7                	call   *%edi
  8002a8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ab:	83 eb 01             	sub    $0x1,%ebx
  8002ae:	85 db                	test   %ebx,%ebx
  8002b0:	7f ed                	jg     80029f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	56                   	push   %esi
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c5:	e8 56 20 00 00       	call   802320 <__umoddi3>
  8002ca:	83 c4 14             	add    $0x14,%esp
  8002cd:	0f be 80 1b 25 80 00 	movsbl 0x80251b(%eax),%eax
  8002d4:	50                   	push   %eax
  8002d5:	ff d7                	call   *%edi
}
  8002d7:	83 c4 10             	add    $0x10,%esp
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e2:	f3 0f 1e fb          	endbr32 
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
{
  800303:	f3 0f 1e fb          	endbr32 
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 10             	pushl  0x10(%ebp)
  800314:	ff 75 0c             	pushl  0xc(%ebp)
  800317:	ff 75 08             	pushl  0x8(%ebp)
  80031a:	e8 05 00 00 00       	call   800324 <vprintfmt>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
{
  800324:	f3 0f 1e fb          	endbr32 
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 3c             	sub    $0x3c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	e9 8e 03 00 00       	jmp    8006cd <vprintfmt+0x3a9>
		padc = ' ';
  80033f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800343:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80034a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800351:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800358:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8d 47 01             	lea    0x1(%edi),%eax
  800360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800363:	0f b6 17             	movzbl (%edi),%edx
  800366:	8d 42 dd             	lea    -0x23(%edx),%eax
  800369:	3c 55                	cmp    $0x55,%al
  80036b:	0f 87 df 03 00 00    	ja     800750 <vprintfmt+0x42c>
  800371:	0f b6 c0             	movzbl %al,%eax
  800374:	3e ff 24 85 60 26 80 	notrack jmp *0x802660(,%eax,4)
  80037b:	00 
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80037f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800383:	eb d8                	jmp    80035d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800388:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80038c:	eb cf                	jmp    80035d <vprintfmt+0x39>
  80038e:	0f b6 d2             	movzbl %dl,%edx
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800394:	b8 00 00 00 00       	mov    $0x0,%eax
  800399:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a9:	83 f9 09             	cmp    $0x9,%ecx
  8003ac:	77 55                	ja     800403 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003ae:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003b1:	eb e9                	jmp    80039c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 40 04             	lea    0x4(%eax),%eax
  8003c1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	79 90                	jns    80035d <vprintfmt+0x39>
				width = precision, precision = -1;
  8003cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003da:	eb 81                	jmp    80035d <vprintfmt+0x39>
  8003dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003df:	85 c0                	test   %eax,%eax
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e6:	0f 49 d0             	cmovns %eax,%edx
  8003e9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ef:	e9 69 ff ff ff       	jmp    80035d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003fe:	e9 5a ff ff ff       	jmp    80035d <vprintfmt+0x39>
  800403:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800406:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800409:	eb bc                	jmp    8003c7 <vprintfmt+0xa3>
			lflag++;
  80040b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800411:	e9 47 ff ff ff       	jmp    80035d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 78 04             	lea    0x4(%eax),%edi
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	53                   	push   %ebx
  800420:	ff 30                	pushl  (%eax)
  800422:	ff d6                	call   *%esi
			break;
  800424:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800427:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80042a:	e9 9b 02 00 00       	jmp    8006ca <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 78 04             	lea    0x4(%eax),%edi
  800435:	8b 00                	mov    (%eax),%eax
  800437:	99                   	cltd   
  800438:	31 d0                	xor    %edx,%eax
  80043a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043c:	83 f8 0f             	cmp    $0xf,%eax
  80043f:	7f 23                	jg     800464 <vprintfmt+0x140>
  800441:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800448:	85 d2                	test   %edx,%edx
  80044a:	74 18                	je     800464 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80044c:	52                   	push   %edx
  80044d:	68 39 29 80 00       	push   $0x802939
  800452:	53                   	push   %ebx
  800453:	56                   	push   %esi
  800454:	e8 aa fe ff ff       	call   800303 <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80045f:	e9 66 02 00 00       	jmp    8006ca <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800464:	50                   	push   %eax
  800465:	68 33 25 80 00       	push   $0x802533
  80046a:	53                   	push   %ebx
  80046b:	56                   	push   %esi
  80046c:	e8 92 fe ff ff       	call   800303 <printfmt>
  800471:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800474:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 4e 02 00 00       	jmp    8006ca <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	83 c0 04             	add    $0x4,%eax
  800482:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80048a:	85 d2                	test   %edx,%edx
  80048c:	b8 2c 25 80 00       	mov    $0x80252c,%eax
  800491:	0f 45 c2             	cmovne %edx,%eax
  800494:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800497:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049b:	7e 06                	jle    8004a3 <vprintfmt+0x17f>
  80049d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a1:	75 0d                	jne    8004b0 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a6:	89 c7                	mov    %eax,%edi
  8004a8:	03 45 e0             	add    -0x20(%ebp),%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	eb 55                	jmp    800505 <vprintfmt+0x1e1>
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b6:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b9:	e8 46 03 00 00       	call   800804 <strnlen>
  8004be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c1:	29 c2                	sub    %eax,%edx
  8004c3:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004cb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7e 11                	jle    8004e7 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	53                   	push   %ebx
  8004da:	ff 75 e0             	pushl  -0x20(%ebp)
  8004dd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	83 ef 01             	sub    $0x1,%edi
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb eb                	jmp    8004d2 <vprintfmt+0x1ae>
  8004e7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ea:	85 d2                	test   %edx,%edx
  8004ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f1:	0f 49 c2             	cmovns %edx,%eax
  8004f4:	29 c2                	sub    %eax,%edx
  8004f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f9:	eb a8                	jmp    8004a3 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	53                   	push   %ebx
  8004ff:	52                   	push   %edx
  800500:	ff d6                	call   *%esi
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800508:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 4b                	je     800563 <vprintfmt+0x23f>
  800518:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051c:	78 06                	js     800524 <vprintfmt+0x200>
  80051e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800522:	78 1e                	js     800542 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800524:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800528:	74 d1                	je     8004fb <vprintfmt+0x1d7>
  80052a:	0f be c0             	movsbl %al,%eax
  80052d:	83 e8 20             	sub    $0x20,%eax
  800530:	83 f8 5e             	cmp    $0x5e,%eax
  800533:	76 c6                	jbe    8004fb <vprintfmt+0x1d7>
					putch('?', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 3f                	push   $0x3f
  80053b:	ff d6                	call   *%esi
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb c3                	jmp    800505 <vprintfmt+0x1e1>
  800542:	89 cf                	mov    %ecx,%edi
  800544:	eb 0e                	jmp    800554 <vprintfmt+0x230>
				putch(' ', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	53                   	push   %ebx
  80054a:	6a 20                	push   $0x20
  80054c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054e:	83 ef 01             	sub    $0x1,%edi
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	85 ff                	test   %edi,%edi
  800556:	7f ee                	jg     800546 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800558:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
  80055e:	e9 67 01 00 00       	jmp    8006ca <vprintfmt+0x3a6>
  800563:	89 cf                	mov    %ecx,%edi
  800565:	eb ed                	jmp    800554 <vprintfmt+0x230>
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7f 1b                	jg     800587 <vprintfmt+0x263>
	else if (lflag)
  80056c:	85 c9                	test   %ecx,%ecx
  80056e:	74 63                	je     8005d3 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800578:	99                   	cltd   
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 04             	lea    0x4(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
  800585:	eb 17                	jmp    80059e <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8b 50 04             	mov    0x4(%eax),%edx
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800592:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 40 08             	lea    0x8(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80059e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005a9:	85 c9                	test   %ecx,%ecx
  8005ab:	0f 89 ff 00 00 00    	jns    8006b0 <vprintfmt+0x38c>
				putch('-', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 2d                	push   $0x2d
  8005b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bf:	f7 da                	neg    %edx
  8005c1:	83 d1 00             	adc    $0x0,%ecx
  8005c4:	f7 d9                	neg    %ecx
  8005c6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ce:	e9 dd 00 00 00       	jmp    8006b0 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	99                   	cltd   
  8005dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e8:	eb b4                	jmp    80059e <vprintfmt+0x27a>
	if (lflag >= 2)
  8005ea:	83 f9 01             	cmp    $0x1,%ecx
  8005ed:	7f 1e                	jg     80060d <vprintfmt+0x2e9>
	else if (lflag)
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	74 32                	je     800625 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800608:	e9 a3 00 00 00       	jmp    8006b0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	8b 48 04             	mov    0x4(%eax),%ecx
  800615:	8d 40 08             	lea    0x8(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800620:	e9 8b 00 00 00       	jmp    8006b0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80063a:	eb 74                	jmp    8006b0 <vprintfmt+0x38c>
	if (lflag >= 2)
  80063c:	83 f9 01             	cmp    $0x1,%ecx
  80063f:	7f 1b                	jg     80065c <vprintfmt+0x338>
	else if (lflag)
  800641:	85 c9                	test   %ecx,%ecx
  800643:	74 2c                	je     800671 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064f:	8d 40 04             	lea    0x4(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800655:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80065a:	eb 54                	jmp    8006b0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	8b 48 04             	mov    0x4(%eax),%ecx
  800664:	8d 40 08             	lea    0x8(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80066f:	eb 3f                	jmp    8006b0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800681:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800686:	eb 28                	jmp    8006b0 <vprintfmt+0x38c>
			putch('0', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 30                	push   $0x30
  80068e:	ff d6                	call   *%esi
			putch('x', putdat);
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 78                	push   $0x78
  800696:	ff d6                	call   *%esi
			num = (unsigned long long)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a5:	8d 40 04             	lea    0x4(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006b7:	57                   	push   %edi
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	50                   	push   %eax
  8006bc:	51                   	push   %ecx
  8006bd:	52                   	push   %edx
  8006be:	89 da                	mov    %ebx,%edx
  8006c0:	89 f0                	mov    %esi,%eax
  8006c2:	e8 72 fb ff ff       	call   800239 <printnum>
			break;
  8006c7:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006cd:	83 c7 01             	add    $0x1,%edi
  8006d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d4:	83 f8 25             	cmp    $0x25,%eax
  8006d7:	0f 84 62 fc ff ff    	je     80033f <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	0f 84 8b 00 00 00    	je     800770 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	50                   	push   %eax
  8006ea:	ff d6                	call   *%esi
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb dc                	jmp    8006cd <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006f1:	83 f9 01             	cmp    $0x1,%ecx
  8006f4:	7f 1b                	jg     800711 <vprintfmt+0x3ed>
	else if (lflag)
  8006f6:	85 c9                	test   %ecx,%ecx
  8006f8:	74 2c                	je     800726 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80070f:	eb 9f                	jmp    8006b0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	8b 48 04             	mov    0x4(%eax),%ecx
  800719:	8d 40 08             	lea    0x8(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800724:	eb 8a                	jmp    8006b0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 10                	mov    (%eax),%edx
  80072b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800730:	8d 40 04             	lea    0x4(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80073b:	e9 70 ff ff ff       	jmp    8006b0 <vprintfmt+0x38c>
			putch(ch, putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 25                	push   $0x25
  800746:	ff d6                	call   *%esi
			break;
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	e9 7a ff ff ff       	jmp    8006ca <vprintfmt+0x3a6>
			putch('%', putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	6a 25                	push   $0x25
  800756:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	89 f8                	mov    %edi,%eax
  80075d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800761:	74 05                	je     800768 <vprintfmt+0x444>
  800763:	83 e8 01             	sub    $0x1,%eax
  800766:	eb f5                	jmp    80075d <vprintfmt+0x439>
  800768:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076b:	e9 5a ff ff ff       	jmp    8006ca <vprintfmt+0x3a6>
}
  800770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800778:	f3 0f 1e fb          	endbr32 
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 18             	sub    $0x18,%esp
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800788:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800792:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800799:	85 c0                	test   %eax,%eax
  80079b:	74 26                	je     8007c3 <vsnprintf+0x4b>
  80079d:	85 d2                	test   %edx,%edx
  80079f:	7e 22                	jle    8007c3 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a1:	ff 75 14             	pushl  0x14(%ebp)
  8007a4:	ff 75 10             	pushl  0x10(%ebp)
  8007a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007aa:	50                   	push   %eax
  8007ab:	68 e2 02 80 00       	push   $0x8002e2
  8007b0:	e8 6f fb ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007be:	83 c4 10             	add    $0x10,%esp
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    
		return -E_INVAL;
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c8:	eb f7                	jmp    8007c1 <vsnprintf+0x49>

008007ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ca:	f3 0f 1e fb          	endbr32 
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d7:	50                   	push   %eax
  8007d8:	ff 75 10             	pushl  0x10(%ebp)
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	ff 75 08             	pushl  0x8(%ebp)
  8007e1:	e8 92 ff ff ff       	call   800778 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	f3 0f 1e fb          	endbr32 
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fb:	74 05                	je     800802 <strlen+0x1a>
		n++;
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	eb f5                	jmp    8007f7 <strlen+0xf>
	return n;
}
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800804:	f3 0f 1e fb          	endbr32 
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	39 d0                	cmp    %edx,%eax
  800818:	74 0d                	je     800827 <strnlen+0x23>
  80081a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081e:	74 05                	je     800825 <strnlen+0x21>
		n++;
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	eb f1                	jmp    800816 <strnlen+0x12>
  800825:	89 c2                	mov    %eax,%edx
	return n;
}
  800827:	89 d0                	mov    %edx,%eax
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082b:	f3 0f 1e fb          	endbr32 
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
  80083e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800842:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	84 d2                	test   %dl,%dl
  80084a:	75 f2                	jne    80083e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80084c:	89 c8                	mov    %ecx,%eax
  80084e:	5b                   	pop    %ebx
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	83 ec 10             	sub    $0x10,%esp
  80085c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085f:	53                   	push   %ebx
  800860:	e8 83 ff ff ff       	call   8007e8 <strlen>
  800865:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	01 d8                	add    %ebx,%eax
  80086d:	50                   	push   %eax
  80086e:	e8 b8 ff ff ff       	call   80082b <strcpy>
	return dst;
}
  800873:	89 d8                	mov    %ebx,%eax
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087a:	f3 0f 1e fb          	endbr32 
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	89 f3                	mov    %esi,%ebx
  80088b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088e:	89 f0                	mov    %esi,%eax
  800890:	39 d8                	cmp    %ebx,%eax
  800892:	74 11                	je     8008a5 <strncpy+0x2b>
		*dst++ = *src;
  800894:	83 c0 01             	add    $0x1,%eax
  800897:	0f b6 0a             	movzbl (%edx),%ecx
  80089a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089d:	80 f9 01             	cmp    $0x1,%cl
  8008a0:	83 da ff             	sbb    $0xffffffff,%edx
  8008a3:	eb eb                	jmp    800890 <strncpy+0x16>
	}
	return ret;
}
  8008a5:	89 f0                	mov    %esi,%eax
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ab:	f3 0f 1e fb          	endbr32 
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8008bd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bf:	85 d2                	test   %edx,%edx
  8008c1:	74 21                	je     8008e4 <strlcpy+0x39>
  8008c3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c7:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008c9:	39 c2                	cmp    %eax,%edx
  8008cb:	74 14                	je     8008e1 <strlcpy+0x36>
  8008cd:	0f b6 19             	movzbl (%ecx),%ebx
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	74 0b                	je     8008df <strlcpy+0x34>
			*dst++ = *src++;
  8008d4:	83 c1 01             	add    $0x1,%ecx
  8008d7:	83 c2 01             	add    $0x1,%edx
  8008da:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008dd:	eb ea                	jmp    8008c9 <strlcpy+0x1e>
  8008df:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e4:	29 f0                	sub    %esi,%eax
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ea:	f3 0f 1e fb          	endbr32 
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f7:	0f b6 01             	movzbl (%ecx),%eax
  8008fa:	84 c0                	test   %al,%al
  8008fc:	74 0c                	je     80090a <strcmp+0x20>
  8008fe:	3a 02                	cmp    (%edx),%al
  800900:	75 08                	jne    80090a <strcmp+0x20>
		p++, q++;
  800902:	83 c1 01             	add    $0x1,%ecx
  800905:	83 c2 01             	add    $0x1,%edx
  800908:	eb ed                	jmp    8008f7 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 c0             	movzbl %al,%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800914:	f3 0f 1e fb          	endbr32 
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800922:	89 c3                	mov    %eax,%ebx
  800924:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800927:	eb 06                	jmp    80092f <strncmp+0x1b>
		n--, p++, q++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80092f:	39 d8                	cmp    %ebx,%eax
  800931:	74 16                	je     800949 <strncmp+0x35>
  800933:	0f b6 08             	movzbl (%eax),%ecx
  800936:	84 c9                	test   %cl,%cl
  800938:	74 04                	je     80093e <strncmp+0x2a>
  80093a:	3a 0a                	cmp    (%edx),%cl
  80093c:	74 eb                	je     800929 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093e:	0f b6 00             	movzbl (%eax),%eax
  800941:	0f b6 12             	movzbl (%edx),%edx
  800944:	29 d0                	sub    %edx,%eax
}
  800946:	5b                   	pop    %ebx
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    
		return 0;
  800949:	b8 00 00 00 00       	mov    $0x0,%eax
  80094e:	eb f6                	jmp    800946 <strncmp+0x32>

00800950 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800950:	f3 0f 1e fb          	endbr32 
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095e:	0f b6 10             	movzbl (%eax),%edx
  800961:	84 d2                	test   %dl,%dl
  800963:	74 09                	je     80096e <strchr+0x1e>
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 0a                	je     800973 <strchr+0x23>
	for (; *s; s++)
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	eb f0                	jmp    80095e <strchr+0xe>
			return (char *) s;
	return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800975:	f3 0f 1e fb          	endbr32 
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80097f:	6a 78                	push   $0x78
  800981:	ff 75 08             	pushl  0x8(%ebp)
  800984:	e8 c7 ff ff ff       	call   800950 <strchr>
  800989:	83 c4 10             	add    $0x10,%esp
  80098c:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800994:	eb 0d                	jmp    8009a3 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800996:	c1 e0 04             	shl    $0x4,%eax
  800999:	0f be d2             	movsbl %dl,%edx
  80099c:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8009a0:	83 c1 01             	add    $0x1,%ecx
  8009a3:	0f b6 11             	movzbl (%ecx),%edx
  8009a6:	84 d2                	test   %dl,%dl
  8009a8:	74 11                	je     8009bb <atox+0x46>
		if (*p>='a'){
  8009aa:	80 fa 60             	cmp    $0x60,%dl
  8009ad:	7e e7                	jle    800996 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8009af:	c1 e0 04             	shl    $0x4,%eax
  8009b2:	0f be d2             	movsbl %dl,%edx
  8009b5:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009b9:	eb e5                	jmp    8009a0 <atox+0x2b>
	}

	return v;

}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	f3 0f 1e fb          	endbr32 
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ce:	38 ca                	cmp    %cl,%dl
  8009d0:	74 09                	je     8009db <strfind+0x1e>
  8009d2:	84 d2                	test   %dl,%dl
  8009d4:	74 05                	je     8009db <strfind+0x1e>
	for (; *s; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	eb f0                	jmp    8009cb <strfind+0xe>
			break;
	return (char *) s;
}
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009dd:	f3 0f 1e fb          	endbr32 
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ed:	85 c9                	test   %ecx,%ecx
  8009ef:	74 31                	je     800a22 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f1:	89 f8                	mov    %edi,%eax
  8009f3:	09 c8                	or     %ecx,%eax
  8009f5:	a8 03                	test   $0x3,%al
  8009f7:	75 23                	jne    800a1c <memset+0x3f>
		c &= 0xFF;
  8009f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fd:	89 d3                	mov    %edx,%ebx
  8009ff:	c1 e3 08             	shl    $0x8,%ebx
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	c1 e0 18             	shl    $0x18,%eax
  800a07:	89 d6                	mov    %edx,%esi
  800a09:	c1 e6 10             	shl    $0x10,%esi
  800a0c:	09 f0                	or     %esi,%eax
  800a0e:	09 c2                	or     %eax,%edx
  800a10:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a12:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a15:	89 d0                	mov    %edx,%eax
  800a17:	fc                   	cld    
  800a18:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1a:	eb 06                	jmp    800a22 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1f:	fc                   	cld    
  800a20:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a22:	89 f8                	mov    %edi,%eax
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3b:	39 c6                	cmp    %eax,%esi
  800a3d:	73 32                	jae    800a71 <memmove+0x48>
  800a3f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a42:	39 c2                	cmp    %eax,%edx
  800a44:	76 2b                	jbe    800a71 <memmove+0x48>
		s += n;
		d += n;
  800a46:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a49:	89 fe                	mov    %edi,%esi
  800a4b:	09 ce                	or     %ecx,%esi
  800a4d:	09 d6                	or     %edx,%esi
  800a4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a55:	75 0e                	jne    800a65 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a57:	83 ef 04             	sub    $0x4,%edi
  800a5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a60:	fd                   	std    
  800a61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a63:	eb 09                	jmp    800a6e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a65:	83 ef 01             	sub    $0x1,%edi
  800a68:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6b:	fd                   	std    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6e:	fc                   	cld    
  800a6f:	eb 1a                	jmp    800a8b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a71:	89 c2                	mov    %eax,%edx
  800a73:	09 ca                	or     %ecx,%edx
  800a75:	09 f2                	or     %esi,%edx
  800a77:	f6 c2 03             	test   $0x3,%dl
  800a7a:	75 0a                	jne    800a86 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7f:	89 c7                	mov    %eax,%edi
  800a81:	fc                   	cld    
  800a82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a84:	eb 05                	jmp    800a8b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	fc                   	cld    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a99:	ff 75 10             	pushl  0x10(%ebp)
  800a9c:	ff 75 0c             	pushl  0xc(%ebp)
  800a9f:	ff 75 08             	pushl  0x8(%ebp)
  800aa2:	e8 82 ff ff ff       	call   800a29 <memmove>
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa9:	f3 0f 1e fb          	endbr32 
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab8:	89 c6                	mov    %eax,%esi
  800aba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abd:	39 f0                	cmp    %esi,%eax
  800abf:	74 1c                	je     800add <memcmp+0x34>
		if (*s1 != *s2)
  800ac1:	0f b6 08             	movzbl (%eax),%ecx
  800ac4:	0f b6 1a             	movzbl (%edx),%ebx
  800ac7:	38 d9                	cmp    %bl,%cl
  800ac9:	75 08                	jne    800ad3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800acb:	83 c0 01             	add    $0x1,%eax
  800ace:	83 c2 01             	add    $0x1,%edx
  800ad1:	eb ea                	jmp    800abd <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ad3:	0f b6 c1             	movzbl %cl,%eax
  800ad6:	0f b6 db             	movzbl %bl,%ebx
  800ad9:	29 d8                	sub    %ebx,%eax
  800adb:	eb 05                	jmp    800ae2 <memcmp+0x39>
	}

	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae6:	f3 0f 1e fb          	endbr32 
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af8:	39 d0                	cmp    %edx,%eax
  800afa:	73 09                	jae    800b05 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afc:	38 08                	cmp    %cl,(%eax)
  800afe:	74 05                	je     800b05 <memfind+0x1f>
	for (; s < ends; s++)
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	eb f3                	jmp    800af8 <memfind+0x12>
			break;
	return (void *) s;
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b07:	f3 0f 1e fb          	endbr32 
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x15>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0x12>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	74 2a                	je     800b55 <strtol+0x4e>
	int neg = 0;
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b30:	3c 2d                	cmp    $0x2d,%al
  800b32:	74 2b                	je     800b5f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3a:	75 0f                	jne    800b4b <strtol+0x44>
  800b3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3f:	74 28                	je     800b69 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b48:	0f 44 d8             	cmove  %eax,%ebx
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b53:	eb 46                	jmp    800b9b <strtol+0x94>
		s++;
  800b55:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b58:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5d:	eb d5                	jmp    800b34 <strtol+0x2d>
		s++, neg = 1;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	bf 01 00 00 00       	mov    $0x1,%edi
  800b67:	eb cb                	jmp    800b34 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6d:	74 0e                	je     800b7d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b6f:	85 db                	test   %ebx,%ebx
  800b71:	75 d8                	jne    800b4b <strtol+0x44>
		s++, base = 8;
  800b73:	83 c1 01             	add    $0x1,%ecx
  800b76:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b7b:	eb ce                	jmp    800b4b <strtol+0x44>
		s += 2, base = 16;
  800b7d:	83 c1 02             	add    $0x2,%ecx
  800b80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b85:	eb c4                	jmp    800b4b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b87:	0f be d2             	movsbl %dl,%edx
  800b8a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b90:	7d 3a                	jge    800bcc <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b99:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b9b:	0f b6 11             	movzbl (%ecx),%edx
  800b9e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba1:	89 f3                	mov    %esi,%ebx
  800ba3:	80 fb 09             	cmp    $0x9,%bl
  800ba6:	76 df                	jbe    800b87 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ba8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 57             	sub    $0x57,%edx
  800bb8:	eb d3                	jmp    800b8d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 19             	cmp    $0x19,%bl
  800bc2:	77 08                	ja     800bcc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc4:	0f be d2             	movsbl %dl,%edx
  800bc7:	83 ea 37             	sub    $0x37,%edx
  800bca:	eb c1                	jmp    800b8d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd0:	74 05                	je     800bd7 <strtol+0xd0>
		*endptr = (char *) s;
  800bd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bd7:	89 c2                	mov    %eax,%edx
  800bd9:	f7 da                	neg    %edx
  800bdb:	85 ff                	test   %edi,%edi
  800bdd:	0f 45 c2             	cmovne %edx,%eax
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be5:	f3 0f 1e fb          	endbr32 
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	f3 0f 1e fb          	endbr32 
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c11:	ba 00 00 00 00       	mov    $0x0,%edx
  800c16:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1b:	89 d1                	mov    %edx,%ecx
  800c1d:	89 d3                	mov    %edx,%ebx
  800c1f:	89 d7                	mov    %edx,%edi
  800c21:	89 d6                	mov    %edx,%esi
  800c23:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2a:	f3 0f 1e fb          	endbr32 
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800c41:	89 cb                	mov    %ecx,%ebx
  800c43:	89 cf                	mov    %ecx,%edi
  800c45:	89 ce                	mov    %ecx,%esi
  800c47:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4e:	f3 0f 1e fb          	endbr32 
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c58:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c62:	89 d1                	mov    %edx,%ecx
  800c64:	89 d3                	mov    %edx,%ebx
  800c66:	89 d7                	mov    %edx,%edi
  800c68:	89 d6                	mov    %edx,%esi
  800c6a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_yield>:

void
sys_yield(void)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c94:	f3 0f 1e fb          	endbr32 
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9e:	be 00 00 00 00       	mov    $0x0,%esi
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 04 00 00 00       	mov    $0x4,%eax
  800cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb1:	89 f7                	mov    %esi,%edi
  800cb3:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cba:	f3 0f 1e fb          	endbr32 
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd8:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cdf:	f3 0f 1e fb          	endbr32 
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d04:	f3 0f 1e fb          	endbr32 
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1e:	89 df                	mov    %ebx,%edi
  800d20:	89 de                	mov    %ebx,%esi
  800d22:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d29:	f3 0f 1e fb          	endbr32 
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4e:	f3 0f 1e fb          	endbr32 
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d73:	f3 0f 1e fb          	endbr32 
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d88:	be 00 00 00 00       	mov    $0x0,%esi
  800d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d90:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d93:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9a:	f3 0f 1e fb          	endbr32 
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db1:	89 cb                	mov    %ecx,%ebx
  800db3:	89 cf                	mov    %ecx,%edi
  800db5:	89 ce                	mov    %ecx,%esi
  800db7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dbe:	f3 0f 1e fb          	endbr32 
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	89 d3                	mov    %edx,%ebx
  800dd6:	89 d7                	mov    %edx,%edi
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800de1:	f3 0f 1e fb          	endbr32 
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e06:	f3 0f 1e fb          	endbr32 
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	b8 10 00 00 00       	mov    $0x10,%eax
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e2b:	f3 0f 1e fb          	endbr32 
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e35:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e3c:	74 0a                	je     800e48 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	a3 0c 40 80 00       	mov    %eax,0x80400c

}
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	6a 07                	push   $0x7
  800e4d:	68 00 f0 bf ee       	push   $0xeebff000
  800e52:	6a 00                	push   $0x0
  800e54:	e8 3b fe ff ff       	call   800c94 <sys_page_alloc>
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 2a                	js     800e8a <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	68 9e 0e 80 00       	push   $0x800e9e
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 df fe ff ff       	call   800d4e <sys_env_set_pgfault_upcall>
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 c8                	jns    800e3e <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	68 4c 28 80 00       	push   $0x80284c
  800e7e:	6a 2c                	push   $0x2c
  800e80:	68 82 28 80 00       	push   $0x802882
  800e85:	e8 b0 f2 ff ff       	call   80013a <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	68 20 28 80 00       	push   $0x802820
  800e92:	6a 22                	push   $0x22
  800e94:	68 82 28 80 00       	push   $0x802882
  800e99:	e8 9c f2 ff ff       	call   80013a <_panic>

00800e9e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e9e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e9f:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax   			// 间接寻址
  800ea4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800ea6:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  800ea9:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  800ead:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  800eb2:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  800eb6:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  800eb8:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  800ebb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  800ebc:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  800ebf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  800ec0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  800ec1:	c3                   	ret    

00800ec2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec2:	f3 0f 1e fb          	endbr32 
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed1:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed6:	f3 0f 1e fb          	endbr32 
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ee5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef1:	f3 0f 1e fb          	endbr32 
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efd:	89 c2                	mov    %eax,%edx
  800eff:	c1 ea 16             	shr    $0x16,%edx
  800f02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f09:	f6 c2 01             	test   $0x1,%dl
  800f0c:	74 2d                	je     800f3b <fd_alloc+0x4a>
  800f0e:	89 c2                	mov    %eax,%edx
  800f10:	c1 ea 0c             	shr    $0xc,%edx
  800f13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1a:	f6 c2 01             	test   $0x1,%dl
  800f1d:	74 1c                	je     800f3b <fd_alloc+0x4a>
  800f1f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f24:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f29:	75 d2                	jne    800efd <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f34:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f39:	eb 0a                	jmp    800f45 <fd_alloc+0x54>
			*fd_store = fd;
  800f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f47:	f3 0f 1e fb          	endbr32 
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f51:	83 f8 1f             	cmp    $0x1f,%eax
  800f54:	77 30                	ja     800f86 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f56:	c1 e0 0c             	shl    $0xc,%eax
  800f59:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f5e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f64:	f6 c2 01             	test   $0x1,%dl
  800f67:	74 24                	je     800f8d <fd_lookup+0x46>
  800f69:	89 c2                	mov    %eax,%edx
  800f6b:	c1 ea 0c             	shr    $0xc,%edx
  800f6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	74 1a                	je     800f94 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7d:	89 02                	mov    %eax,(%edx)
	return 0;
  800f7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    
		return -E_INVAL;
  800f86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8b:	eb f7                	jmp    800f84 <fd_lookup+0x3d>
		return -E_INVAL;
  800f8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f92:	eb f0                	jmp    800f84 <fd_lookup+0x3d>
  800f94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f99:	eb e9                	jmp    800f84 <fd_lookup+0x3d>

00800f9b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f9b:	f3 0f 1e fb          	endbr32 
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 08             	sub    $0x8,%esp
  800fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fad:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800fb2:	39 08                	cmp    %ecx,(%eax)
  800fb4:	74 38                	je     800fee <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800fb6:	83 c2 01             	add    $0x1,%edx
  800fb9:	8b 04 95 0c 29 80 00 	mov    0x80290c(,%edx,4),%eax
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	75 ee                	jne    800fb2 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fc4:	a1 08 40 80 00       	mov    0x804008,%eax
  800fc9:	8b 40 48             	mov    0x48(%eax),%eax
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	51                   	push   %ecx
  800fd0:	50                   	push   %eax
  800fd1:	68 90 28 80 00       	push   $0x802890
  800fd6:	e8 46 f2 ff ff       	call   800221 <cprintf>
	*dev = 0;
  800fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fde:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fec:	c9                   	leave  
  800fed:	c3                   	ret    
			*dev = devtab[i];
  800fee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	eb f2                	jmp    800fec <dev_lookup+0x51>

00800ffa <fd_close>:
{
  800ffa:	f3 0f 1e fb          	endbr32 
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 24             	sub    $0x24,%esp
  801007:	8b 75 08             	mov    0x8(%ebp),%esi
  80100a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80100d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801010:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801011:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801017:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80101a:	50                   	push   %eax
  80101b:	e8 27 ff ff ff       	call   800f47 <fd_lookup>
  801020:	89 c3                	mov    %eax,%ebx
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	78 05                	js     80102e <fd_close+0x34>
	    || fd != fd2)
  801029:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80102c:	74 16                	je     801044 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80102e:	89 f8                	mov    %edi,%eax
  801030:	84 c0                	test   %al,%al
  801032:	b8 00 00 00 00       	mov    $0x0,%eax
  801037:	0f 44 d8             	cmove  %eax,%ebx
}
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103f:	5b                   	pop    %ebx
  801040:	5e                   	pop    %esi
  801041:	5f                   	pop    %edi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80104a:	50                   	push   %eax
  80104b:	ff 36                	pushl  (%esi)
  80104d:	e8 49 ff ff ff       	call   800f9b <dev_lookup>
  801052:	89 c3                	mov    %eax,%ebx
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	78 1a                	js     801075 <fd_close+0x7b>
		if (dev->dev_close)
  80105b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80105e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801066:	85 c0                	test   %eax,%eax
  801068:	74 0b                	je     801075 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80106a:	83 ec 0c             	sub    $0xc,%esp
  80106d:	56                   	push   %esi
  80106e:	ff d0                	call   *%eax
  801070:	89 c3                	mov    %eax,%ebx
  801072:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801075:	83 ec 08             	sub    $0x8,%esp
  801078:	56                   	push   %esi
  801079:	6a 00                	push   $0x0
  80107b:	e8 5f fc ff ff       	call   800cdf <sys_page_unmap>
	return r;
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	eb b5                	jmp    80103a <fd_close+0x40>

00801085 <close>:

int
close(int fdnum)
{
  801085:	f3 0f 1e fb          	endbr32 
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	e8 ac fe ff ff       	call   800f47 <fd_lookup>
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 02                	jns    8010a4 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    
		return fd_close(fd, 1);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	6a 01                	push   $0x1
  8010a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ac:	e8 49 ff ff ff       	call   800ffa <fd_close>
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	eb ec                	jmp    8010a2 <close+0x1d>

008010b6 <close_all>:

void
close_all(void)
{
  8010b6:	f3 0f 1e fb          	endbr32 
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	53                   	push   %ebx
  8010ca:	e8 b6 ff ff ff       	call   801085 <close>
	for (i = 0; i < MAXFD; i++)
  8010cf:	83 c3 01             	add    $0x1,%ebx
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	83 fb 20             	cmp    $0x20,%ebx
  8010d8:	75 ec                	jne    8010c6 <close_all+0x10>
}
  8010da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010dd:	c9                   	leave  
  8010de:	c3                   	ret    

008010df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010df:	f3 0f 1e fb          	endbr32 
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010ec:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	ff 75 08             	pushl  0x8(%ebp)
  8010f3:	e8 4f fe ff ff       	call   800f47 <fd_lookup>
  8010f8:	89 c3                	mov    %eax,%ebx
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	0f 88 81 00 00 00    	js     801186 <dup+0xa7>
		return r;
	close(newfdnum);
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	ff 75 0c             	pushl  0xc(%ebp)
  80110b:	e8 75 ff ff ff       	call   801085 <close>

	newfd = INDEX2FD(newfdnum);
  801110:	8b 75 0c             	mov    0xc(%ebp),%esi
  801113:	c1 e6 0c             	shl    $0xc,%esi
  801116:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80111c:	83 c4 04             	add    $0x4,%esp
  80111f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801122:	e8 af fd ff ff       	call   800ed6 <fd2data>
  801127:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801129:	89 34 24             	mov    %esi,(%esp)
  80112c:	e8 a5 fd ff ff       	call   800ed6 <fd2data>
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801136:	89 d8                	mov    %ebx,%eax
  801138:	c1 e8 16             	shr    $0x16,%eax
  80113b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801142:	a8 01                	test   $0x1,%al
  801144:	74 11                	je     801157 <dup+0x78>
  801146:	89 d8                	mov    %ebx,%eax
  801148:	c1 e8 0c             	shr    $0xc,%eax
  80114b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801152:	f6 c2 01             	test   $0x1,%dl
  801155:	75 39                	jne    801190 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801157:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80115a:	89 d0                	mov    %edx,%eax
  80115c:	c1 e8 0c             	shr    $0xc,%eax
  80115f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	25 07 0e 00 00       	and    $0xe07,%eax
  80116e:	50                   	push   %eax
  80116f:	56                   	push   %esi
  801170:	6a 00                	push   $0x0
  801172:	52                   	push   %edx
  801173:	6a 00                	push   $0x0
  801175:	e8 40 fb ff ff       	call   800cba <sys_page_map>
  80117a:	89 c3                	mov    %eax,%ebx
  80117c:	83 c4 20             	add    $0x20,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	78 31                	js     8011b4 <dup+0xd5>
		goto err;

	return newfdnum;
  801183:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801186:	89 d8                	mov    %ebx,%eax
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801190:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	25 07 0e 00 00       	and    $0xe07,%eax
  80119f:	50                   	push   %eax
  8011a0:	57                   	push   %edi
  8011a1:	6a 00                	push   $0x0
  8011a3:	53                   	push   %ebx
  8011a4:	6a 00                	push   $0x0
  8011a6:	e8 0f fb ff ff       	call   800cba <sys_page_map>
  8011ab:	89 c3                	mov    %eax,%ebx
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	79 a3                	jns    801157 <dup+0x78>
	sys_page_unmap(0, newfd);
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	56                   	push   %esi
  8011b8:	6a 00                	push   $0x0
  8011ba:	e8 20 fb ff ff       	call   800cdf <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011bf:	83 c4 08             	add    $0x8,%esp
  8011c2:	57                   	push   %edi
  8011c3:	6a 00                	push   $0x0
  8011c5:	e8 15 fb ff ff       	call   800cdf <sys_page_unmap>
	return r;
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	eb b7                	jmp    801186 <dup+0xa7>

008011cf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011cf:	f3 0f 1e fb          	endbr32 
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 1c             	sub    $0x1c,%esp
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e0:	50                   	push   %eax
  8011e1:	53                   	push   %ebx
  8011e2:	e8 60 fd ff ff       	call   800f47 <fd_lookup>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 3f                	js     80122d <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f8:	ff 30                	pushl  (%eax)
  8011fa:	e8 9c fd ff ff       	call   800f9b <dev_lookup>
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 27                	js     80122d <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801206:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801209:	8b 42 08             	mov    0x8(%edx),%eax
  80120c:	83 e0 03             	and    $0x3,%eax
  80120f:	83 f8 01             	cmp    $0x1,%eax
  801212:	74 1e                	je     801232 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801214:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801217:	8b 40 08             	mov    0x8(%eax),%eax
  80121a:	85 c0                	test   %eax,%eax
  80121c:	74 35                	je     801253 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	ff 75 10             	pushl  0x10(%ebp)
  801224:	ff 75 0c             	pushl  0xc(%ebp)
  801227:	52                   	push   %edx
  801228:	ff d0                	call   *%eax
  80122a:	83 c4 10             	add    $0x10,%esp
}
  80122d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801230:	c9                   	leave  
  801231:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801232:	a1 08 40 80 00       	mov    0x804008,%eax
  801237:	8b 40 48             	mov    0x48(%eax),%eax
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	53                   	push   %ebx
  80123e:	50                   	push   %eax
  80123f:	68 d1 28 80 00       	push   $0x8028d1
  801244:	e8 d8 ef ff ff       	call   800221 <cprintf>
		return -E_INVAL;
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801251:	eb da                	jmp    80122d <read+0x5e>
		return -E_NOT_SUPP;
  801253:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801258:	eb d3                	jmp    80122d <read+0x5e>

0080125a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80125a:	f3 0f 1e fb          	endbr32 
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	8b 7d 08             	mov    0x8(%ebp),%edi
  80126a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801272:	eb 02                	jmp    801276 <readn+0x1c>
  801274:	01 c3                	add    %eax,%ebx
  801276:	39 f3                	cmp    %esi,%ebx
  801278:	73 21                	jae    80129b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	89 f0                	mov    %esi,%eax
  80127f:	29 d8                	sub    %ebx,%eax
  801281:	50                   	push   %eax
  801282:	89 d8                	mov    %ebx,%eax
  801284:	03 45 0c             	add    0xc(%ebp),%eax
  801287:	50                   	push   %eax
  801288:	57                   	push   %edi
  801289:	e8 41 ff ff ff       	call   8011cf <read>
		if (m < 0)
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	85 c0                	test   %eax,%eax
  801293:	78 04                	js     801299 <readn+0x3f>
			return m;
		if (m == 0)
  801295:	75 dd                	jne    801274 <readn+0x1a>
  801297:	eb 02                	jmp    80129b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801299:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80129b:	89 d8                	mov    %ebx,%eax
  80129d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012a5:	f3 0f 1e fb          	endbr32 
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	53                   	push   %ebx
  8012ad:	83 ec 1c             	sub    $0x1c,%esp
  8012b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b6:	50                   	push   %eax
  8012b7:	53                   	push   %ebx
  8012b8:	e8 8a fc ff ff       	call   800f47 <fd_lookup>
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 3a                	js     8012fe <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	ff 30                	pushl  (%eax)
  8012d0:	e8 c6 fc ff ff       	call   800f9b <dev_lookup>
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 22                	js     8012fe <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012e3:	74 1e                	je     801303 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8012eb:	85 d2                	test   %edx,%edx
  8012ed:	74 35                	je     801324 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ef:	83 ec 04             	sub    $0x4,%esp
  8012f2:	ff 75 10             	pushl  0x10(%ebp)
  8012f5:	ff 75 0c             	pushl  0xc(%ebp)
  8012f8:	50                   	push   %eax
  8012f9:	ff d2                	call   *%edx
  8012fb:	83 c4 10             	add    $0x10,%esp
}
  8012fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801301:	c9                   	leave  
  801302:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801303:	a1 08 40 80 00       	mov    0x804008,%eax
  801308:	8b 40 48             	mov    0x48(%eax),%eax
  80130b:	83 ec 04             	sub    $0x4,%esp
  80130e:	53                   	push   %ebx
  80130f:	50                   	push   %eax
  801310:	68 ed 28 80 00       	push   $0x8028ed
  801315:	e8 07 ef ff ff       	call   800221 <cprintf>
		return -E_INVAL;
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801322:	eb da                	jmp    8012fe <write+0x59>
		return -E_NOT_SUPP;
  801324:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801329:	eb d3                	jmp    8012fe <write+0x59>

0080132b <seek>:

int
seek(int fdnum, off_t offset)
{
  80132b:	f3 0f 1e fb          	endbr32 
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 06 fc ff ff       	call   800f47 <fd_lookup>
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 0e                	js     801356 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801348:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801351:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801358:	f3 0f 1e fb          	endbr32 
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	53                   	push   %ebx
  801360:	83 ec 1c             	sub    $0x1c,%esp
  801363:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801366:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801369:	50                   	push   %eax
  80136a:	53                   	push   %ebx
  80136b:	e8 d7 fb ff ff       	call   800f47 <fd_lookup>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 37                	js     8013ae <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801381:	ff 30                	pushl  (%eax)
  801383:	e8 13 fc ff ff       	call   800f9b <dev_lookup>
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 1f                	js     8013ae <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80138f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801392:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801396:	74 1b                	je     8013b3 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801398:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139b:	8b 52 18             	mov    0x18(%edx),%edx
  80139e:	85 d2                	test   %edx,%edx
  8013a0:	74 32                	je     8013d4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	ff 75 0c             	pushl  0xc(%ebp)
  8013a8:	50                   	push   %eax
  8013a9:	ff d2                	call   *%edx
  8013ab:	83 c4 10             	add    $0x10,%esp
}
  8013ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013b3:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013b8:	8b 40 48             	mov    0x48(%eax),%eax
  8013bb:	83 ec 04             	sub    $0x4,%esp
  8013be:	53                   	push   %ebx
  8013bf:	50                   	push   %eax
  8013c0:	68 b0 28 80 00       	push   $0x8028b0
  8013c5:	e8 57 ee ff ff       	call   800221 <cprintf>
		return -E_INVAL;
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d2:	eb da                	jmp    8013ae <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d9:	eb d3                	jmp    8013ae <ftruncate+0x56>

008013db <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013db:	f3 0f 1e fb          	endbr32 
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 1c             	sub    $0x1c,%esp
  8013e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ec:	50                   	push   %eax
  8013ed:	ff 75 08             	pushl  0x8(%ebp)
  8013f0:	e8 52 fb ff ff       	call   800f47 <fd_lookup>
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	78 4b                	js     801447 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801406:	ff 30                	pushl  (%eax)
  801408:	e8 8e fb ff ff       	call   800f9b <dev_lookup>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 33                	js     801447 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801414:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801417:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80141b:	74 2f                	je     80144c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80141d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801420:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801427:	00 00 00 
	stat->st_isdir = 0;
  80142a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801431:	00 00 00 
	stat->st_dev = dev;
  801434:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	53                   	push   %ebx
  80143e:	ff 75 f0             	pushl  -0x10(%ebp)
  801441:	ff 50 14             	call   *0x14(%eax)
  801444:	83 c4 10             	add    $0x10,%esp
}
  801447:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    
		return -E_NOT_SUPP;
  80144c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801451:	eb f4                	jmp    801447 <fstat+0x6c>

00801453 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801453:	f3 0f 1e fb          	endbr32 
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	6a 00                	push   $0x0
  801461:	ff 75 08             	pushl  0x8(%ebp)
  801464:	e8 01 02 00 00       	call   80166a <open>
  801469:	89 c3                	mov    %eax,%ebx
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 1b                	js     80148d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	50                   	push   %eax
  801479:	e8 5d ff ff ff       	call   8013db <fstat>
  80147e:	89 c6                	mov    %eax,%esi
	close(fd);
  801480:	89 1c 24             	mov    %ebx,(%esp)
  801483:	e8 fd fb ff ff       	call   801085 <close>
	return r;
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	89 f3                	mov    %esi,%ebx
}
  80148d:	89 d8                	mov    %ebx,%eax
  80148f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801492:	5b                   	pop    %ebx
  801493:	5e                   	pop    %esi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    

00801496 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	56                   	push   %esi
  80149a:	53                   	push   %ebx
  80149b:	89 c6                	mov    %eax,%esi
  80149d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80149f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014a6:	74 27                	je     8014cf <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a8:	6a 07                	push   $0x7
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	56                   	push   %esi
  8014b0:	ff 35 00 40 80 00    	pushl  0x804000
  8014b6:	e8 7c 0c 00 00       	call   802137 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014bb:	83 c4 0c             	add    $0xc,%esp
  8014be:	6a 00                	push   $0x0
  8014c0:	53                   	push   %ebx
  8014c1:	6a 00                	push   $0x0
  8014c3:	e8 02 0c 00 00       	call   8020ca <ipc_recv>
}
  8014c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	6a 01                	push   $0x1
  8014d4:	e8 b6 0c 00 00       	call   80218f <ipc_find_env>
  8014d9:	a3 00 40 80 00       	mov    %eax,0x804000
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	eb c5                	jmp    8014a8 <fsipc+0x12>

008014e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014e3:	f3 0f 1e fb          	endbr32 
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801500:	ba 00 00 00 00       	mov    $0x0,%edx
  801505:	b8 02 00 00 00       	mov    $0x2,%eax
  80150a:	e8 87 ff ff ff       	call   801496 <fsipc>
}
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <devfile_flush>:
{
  801511:	f3 0f 1e fb          	endbr32 
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	8b 40 0c             	mov    0xc(%eax),%eax
  801521:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 06 00 00 00       	mov    $0x6,%eax
  801530:	e8 61 ff ff ff       	call   801496 <fsipc>
}
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <devfile_stat>:
{
  801537:	f3 0f 1e fb          	endbr32 
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	53                   	push   %ebx
  80153f:	83 ec 04             	sub    $0x4,%esp
  801542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801545:	8b 45 08             	mov    0x8(%ebp),%eax
  801548:	8b 40 0c             	mov    0xc(%eax),%eax
  80154b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 05 00 00 00       	mov    $0x5,%eax
  80155a:	e8 37 ff ff ff       	call   801496 <fsipc>
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 2c                	js     80158f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	68 00 50 80 00       	push   $0x805000
  80156b:	53                   	push   %ebx
  80156c:	e8 ba f2 ff ff       	call   80082b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801571:	a1 80 50 80 00       	mov    0x805080,%eax
  801576:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80157c:	a1 84 50 80 00       	mov    0x805084,%eax
  801581:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <devfile_write>:
{
  801594:	f3 0f 1e fb          	endbr32 
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	8b 45 10             	mov    0x10(%ebp),%eax
  8015a1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015a6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015ab:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015ba:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015bf:	50                   	push   %eax
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	68 08 50 80 00       	push   $0x805008
  8015c8:	e8 5c f4 ff ff       	call   800a29 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8015d7:	e8 ba fe ff ff       	call   801496 <fsipc>
}
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <devfile_read>:
{
  8015de:	f3 0f 1e fb          	endbr32 
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801600:	b8 03 00 00 00       	mov    $0x3,%eax
  801605:	e8 8c fe ff ff       	call   801496 <fsipc>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 1f                	js     80162f <devfile_read+0x51>
	assert(r <= n);
  801610:	39 f0                	cmp    %esi,%eax
  801612:	77 24                	ja     801638 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801614:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801619:	7f 36                	jg     801651 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	50                   	push   %eax
  80161f:	68 00 50 80 00       	push   $0x805000
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	e8 fd f3 ff ff       	call   800a29 <memmove>
	return r;
  80162c:	83 c4 10             	add    $0x10,%esp
}
  80162f:	89 d8                	mov    %ebx,%eax
  801631:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    
	assert(r <= n);
  801638:	68 20 29 80 00       	push   $0x802920
  80163d:	68 27 29 80 00       	push   $0x802927
  801642:	68 8c 00 00 00       	push   $0x8c
  801647:	68 3c 29 80 00       	push   $0x80293c
  80164c:	e8 e9 ea ff ff       	call   80013a <_panic>
	assert(r <= PGSIZE);
  801651:	68 47 29 80 00       	push   $0x802947
  801656:	68 27 29 80 00       	push   $0x802927
  80165b:	68 8d 00 00 00       	push   $0x8d
  801660:	68 3c 29 80 00       	push   $0x80293c
  801665:	e8 d0 ea ff ff       	call   80013a <_panic>

0080166a <open>:
{
  80166a:	f3 0f 1e fb          	endbr32 
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 1c             	sub    $0x1c,%esp
  801676:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801679:	56                   	push   %esi
  80167a:	e8 69 f1 ff ff       	call   8007e8 <strlen>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801687:	7f 6c                	jg     8016f5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	e8 5c f8 ff ff       	call   800ef1 <fd_alloc>
  801695:	89 c3                	mov    %eax,%ebx
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 3c                	js     8016da <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	56                   	push   %esi
  8016a2:	68 00 50 80 00       	push   $0x805000
  8016a7:	e8 7f f1 ff ff       	call   80082b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016af:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8016bc:	e8 d5 fd ff ff       	call   801496 <fsipc>
  8016c1:	89 c3                	mov    %eax,%ebx
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 19                	js     8016e3 <open+0x79>
	return fd2num(fd);
  8016ca:	83 ec 0c             	sub    $0xc,%esp
  8016cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d0:	e8 ed f7 ff ff       	call   800ec2 <fd2num>
  8016d5:	89 c3                	mov    %eax,%ebx
  8016d7:	83 c4 10             	add    $0x10,%esp
}
  8016da:	89 d8                	mov    %ebx,%eax
  8016dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    
		fd_close(fd, 0);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	6a 00                	push   $0x0
  8016e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8016eb:	e8 0a f9 ff ff       	call   800ffa <fd_close>
		return r;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	eb e5                	jmp    8016da <open+0x70>
		return -E_BAD_PATH;
  8016f5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016fa:	eb de                	jmp    8016da <open+0x70>

008016fc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016fc:	f3 0f 1e fb          	endbr32 
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	b8 08 00 00 00       	mov    $0x8,%eax
  801710:	e8 81 fd ff ff       	call   801496 <fsipc>
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801717:	f3 0f 1e fb          	endbr32 
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801721:	68 b3 29 80 00       	push   $0x8029b3
  801726:	ff 75 0c             	pushl  0xc(%ebp)
  801729:	e8 fd f0 ff ff       	call   80082b <strcpy>
	return 0;
}
  80172e:	b8 00 00 00 00       	mov    $0x0,%eax
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <devsock_close>:
{
  801735:	f3 0f 1e fb          	endbr32 
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	53                   	push   %ebx
  80173d:	83 ec 10             	sub    $0x10,%esp
  801740:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801743:	53                   	push   %ebx
  801744:	e8 83 0a 00 00       	call   8021cc <pageref>
  801749:	89 c2                	mov    %eax,%edx
  80174b:	83 c4 10             	add    $0x10,%esp
		return 0;
  80174e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801753:	83 fa 01             	cmp    $0x1,%edx
  801756:	74 05                	je     80175d <devsock_close+0x28>
}
  801758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80175d:	83 ec 0c             	sub    $0xc,%esp
  801760:	ff 73 0c             	pushl  0xc(%ebx)
  801763:	e8 e3 02 00 00       	call   801a4b <nsipc_close>
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	eb eb                	jmp    801758 <devsock_close+0x23>

0080176d <devsock_write>:
{
  80176d:	f3 0f 1e fb          	endbr32 
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801777:	6a 00                	push   $0x0
  801779:	ff 75 10             	pushl  0x10(%ebp)
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	ff 70 0c             	pushl  0xc(%eax)
  801785:	e8 b5 03 00 00       	call   801b3f <nsipc_send>
}
  80178a:	c9                   	leave  
  80178b:	c3                   	ret    

0080178c <devsock_read>:
{
  80178c:	f3 0f 1e fb          	endbr32 
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801796:	6a 00                	push   $0x0
  801798:	ff 75 10             	pushl  0x10(%ebp)
  80179b:	ff 75 0c             	pushl  0xc(%ebp)
  80179e:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a1:	ff 70 0c             	pushl  0xc(%eax)
  8017a4:	e8 1f 03 00 00       	call   801ac8 <nsipc_recv>
}
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <fd2sockid>:
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017b1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017b4:	52                   	push   %edx
  8017b5:	50                   	push   %eax
  8017b6:	e8 8c f7 ff ff       	call   800f47 <fd_lookup>
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 10                	js     8017d2 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c5:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  8017cb:	39 08                	cmp    %ecx,(%eax)
  8017cd:	75 05                	jne    8017d4 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8017cf:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    
		return -E_NOT_SUPP;
  8017d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d9:	eb f7                	jmp    8017d2 <fd2sockid+0x27>

008017db <alloc_sockfd>:
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 1c             	sub    $0x1c,%esp
  8017e3:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8017e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e8:	50                   	push   %eax
  8017e9:	e8 03 f7 ff ff       	call   800ef1 <fd_alloc>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 43                	js     80183a <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017f7:	83 ec 04             	sub    $0x4,%esp
  8017fa:	68 07 04 00 00       	push   $0x407
  8017ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801802:	6a 00                	push   $0x0
  801804:	e8 8b f4 ff ff       	call   800c94 <sys_page_alloc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 28                	js     80183a <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801815:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80181b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801820:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801827:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	50                   	push   %eax
  80182e:	e8 8f f6 ff ff       	call   800ec2 <fd2num>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	eb 0c                	jmp    801846 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	56                   	push   %esi
  80183e:	e8 08 02 00 00       	call   801a4b <nsipc_close>
		return r;
  801843:	83 c4 10             	add    $0x10,%esp
}
  801846:	89 d8                	mov    %ebx,%eax
  801848:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5e                   	pop    %esi
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <accept>:
{
  80184f:	f3 0f 1e fb          	endbr32 
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801859:	8b 45 08             	mov    0x8(%ebp),%eax
  80185c:	e8 4a ff ff ff       	call   8017ab <fd2sockid>
  801861:	85 c0                	test   %eax,%eax
  801863:	78 1b                	js     801880 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	ff 75 10             	pushl  0x10(%ebp)
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	50                   	push   %eax
  80186f:	e8 22 01 00 00       	call   801996 <nsipc_accept>
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	78 05                	js     801880 <accept+0x31>
	return alloc_sockfd(r);
  80187b:	e8 5b ff ff ff       	call   8017db <alloc_sockfd>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <bind>:
{
  801882:	f3 0f 1e fb          	endbr32 
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	e8 17 ff ff ff       	call   8017ab <fd2sockid>
  801894:	85 c0                	test   %eax,%eax
  801896:	78 12                	js     8018aa <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801898:	83 ec 04             	sub    $0x4,%esp
  80189b:	ff 75 10             	pushl  0x10(%ebp)
  80189e:	ff 75 0c             	pushl  0xc(%ebp)
  8018a1:	50                   	push   %eax
  8018a2:	e8 45 01 00 00       	call   8019ec <nsipc_bind>
  8018a7:	83 c4 10             	add    $0x10,%esp
}
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <shutdown>:
{
  8018ac:	f3 0f 1e fb          	endbr32 
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	e8 ed fe ff ff       	call   8017ab <fd2sockid>
  8018be:	85 c0                	test   %eax,%eax
  8018c0:	78 0f                	js     8018d1 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	ff 75 0c             	pushl  0xc(%ebp)
  8018c8:	50                   	push   %eax
  8018c9:	e8 57 01 00 00       	call   801a25 <nsipc_shutdown>
  8018ce:	83 c4 10             	add    $0x10,%esp
}
  8018d1:	c9                   	leave  
  8018d2:	c3                   	ret    

008018d3 <connect>:
{
  8018d3:	f3 0f 1e fb          	endbr32 
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e0:	e8 c6 fe ff ff       	call   8017ab <fd2sockid>
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 12                	js     8018fb <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8018e9:	83 ec 04             	sub    $0x4,%esp
  8018ec:	ff 75 10             	pushl  0x10(%ebp)
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	50                   	push   %eax
  8018f3:	e8 71 01 00 00       	call   801a69 <nsipc_connect>
  8018f8:	83 c4 10             	add    $0x10,%esp
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <listen>:
{
  8018fd:	f3 0f 1e fb          	endbr32 
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	e8 9c fe ff ff       	call   8017ab <fd2sockid>
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 0f                	js     801922 <listen+0x25>
	return nsipc_listen(r, backlog);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	50                   	push   %eax
  80191a:	e8 83 01 00 00       	call   801aa2 <nsipc_listen>
  80191f:	83 c4 10             	add    $0x10,%esp
}
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <socket>:

int
socket(int domain, int type, int protocol)
{
  801924:	f3 0f 1e fb          	endbr32 
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80192e:	ff 75 10             	pushl  0x10(%ebp)
  801931:	ff 75 0c             	pushl  0xc(%ebp)
  801934:	ff 75 08             	pushl  0x8(%ebp)
  801937:	e8 65 02 00 00       	call   801ba1 <nsipc_socket>
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 05                	js     801948 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801943:	e8 93 fe ff ff       	call   8017db <alloc_sockfd>
}
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801953:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80195a:	74 26                	je     801982 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80195c:	6a 07                	push   $0x7
  80195e:	68 00 60 80 00       	push   $0x806000
  801963:	53                   	push   %ebx
  801964:	ff 35 04 40 80 00    	pushl  0x804004
  80196a:	e8 c8 07 00 00       	call   802137 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80196f:	83 c4 0c             	add    $0xc,%esp
  801972:	6a 00                	push   $0x0
  801974:	6a 00                	push   $0x0
  801976:	6a 00                	push   $0x0
  801978:	e8 4d 07 00 00       	call   8020ca <ipc_recv>
}
  80197d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	6a 02                	push   $0x2
  801987:	e8 03 08 00 00       	call   80218f <ipc_find_env>
  80198c:	a3 04 40 80 00       	mov    %eax,0x804004
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	eb c6                	jmp    80195c <nsipc+0x12>

00801996 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801996:	f3 0f 1e fb          	endbr32 
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8019a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8019aa:	8b 06                	mov    (%esi),%eax
  8019ac:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b6:	e8 8f ff ff ff       	call   80194a <nsipc>
  8019bb:	89 c3                	mov    %eax,%ebx
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	79 09                	jns    8019ca <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8019c1:	89 d8                	mov    %ebx,%eax
  8019c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c6:	5b                   	pop    %ebx
  8019c7:	5e                   	pop    %esi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	ff 35 10 60 80 00    	pushl  0x806010
  8019d3:	68 00 60 80 00       	push   $0x806000
  8019d8:	ff 75 0c             	pushl  0xc(%ebp)
  8019db:	e8 49 f0 ff ff       	call   800a29 <memmove>
		*addrlen = ret->ret_addrlen;
  8019e0:	a1 10 60 80 00       	mov    0x806010,%eax
  8019e5:	89 06                	mov    %eax,(%esi)
  8019e7:	83 c4 10             	add    $0x10,%esp
	return r;
  8019ea:	eb d5                	jmp    8019c1 <nsipc_accept+0x2b>

008019ec <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019ec:	f3 0f 1e fb          	endbr32 
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	53                   	push   %ebx
  8019f4:	83 ec 08             	sub    $0x8,%esp
  8019f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801a02:	53                   	push   %ebx
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	68 04 60 80 00       	push   $0x806004
  801a0b:	e8 19 f0 ff ff       	call   800a29 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a10:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a16:	b8 02 00 00 00       	mov    $0x2,%eax
  801a1b:	e8 2a ff ff ff       	call   80194a <nsipc>
}
  801a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a25:	f3 0f 1e fb          	endbr32 
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a32:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a3f:	b8 03 00 00 00       	mov    $0x3,%eax
  801a44:	e8 01 ff ff ff       	call   80194a <nsipc>
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <nsipc_close>:

int
nsipc_close(int s)
{
  801a4b:	f3 0f 1e fb          	endbr32 
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a5d:	b8 04 00 00 00       	mov    $0x4,%eax
  801a62:	e8 e3 fe ff ff       	call   80194a <nsipc>
}
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a69:	f3 0f 1e fb          	endbr32 
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	53                   	push   %ebx
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a7f:	53                   	push   %ebx
  801a80:	ff 75 0c             	pushl  0xc(%ebp)
  801a83:	68 04 60 80 00       	push   $0x806004
  801a88:	e8 9c ef ff ff       	call   800a29 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a8d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a93:	b8 05 00 00 00       	mov    $0x5,%eax
  801a98:	e8 ad fe ff ff       	call   80194a <nsipc>
}
  801a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801aa2:	f3 0f 1e fb          	endbr32 
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801abc:	b8 06 00 00 00       	mov    $0x6,%eax
  801ac1:	e8 84 fe ff ff       	call   80194a <nsipc>
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ac8:	f3 0f 1e fb          	endbr32 
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	56                   	push   %esi
  801ad0:	53                   	push   %ebx
  801ad1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801adc:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae5:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801aea:	b8 07 00 00 00       	mov    $0x7,%eax
  801aef:	e8 56 fe ff ff       	call   80194a <nsipc>
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 26                	js     801b20 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801afa:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801b00:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801b05:	0f 4e c6             	cmovle %esi,%eax
  801b08:	39 c3                	cmp    %eax,%ebx
  801b0a:	7f 1d                	jg     801b29 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b0c:	83 ec 04             	sub    $0x4,%esp
  801b0f:	53                   	push   %ebx
  801b10:	68 00 60 80 00       	push   $0x806000
  801b15:	ff 75 0c             	pushl  0xc(%ebp)
  801b18:	e8 0c ef ff ff       	call   800a29 <memmove>
  801b1d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b20:	89 d8                	mov    %ebx,%eax
  801b22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801b29:	68 bf 29 80 00       	push   $0x8029bf
  801b2e:	68 27 29 80 00       	push   $0x802927
  801b33:	6a 62                	push   $0x62
  801b35:	68 d4 29 80 00       	push   $0x8029d4
  801b3a:	e8 fb e5 ff ff       	call   80013a <_panic>

00801b3f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b3f:	f3 0f 1e fb          	endbr32 
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	53                   	push   %ebx
  801b47:	83 ec 04             	sub    $0x4,%esp
  801b4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b55:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b5b:	7f 2e                	jg     801b8b <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b5d:	83 ec 04             	sub    $0x4,%esp
  801b60:	53                   	push   %ebx
  801b61:	ff 75 0c             	pushl  0xc(%ebp)
  801b64:	68 0c 60 80 00       	push   $0x80600c
  801b69:	e8 bb ee ff ff       	call   800a29 <memmove>
	nsipcbuf.send.req_size = size;
  801b6e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b74:	8b 45 14             	mov    0x14(%ebp),%eax
  801b77:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b7c:	b8 08 00 00 00       	mov    $0x8,%eax
  801b81:	e8 c4 fd ff ff       	call   80194a <nsipc>
}
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    
	assert(size < 1600);
  801b8b:	68 e0 29 80 00       	push   $0x8029e0
  801b90:	68 27 29 80 00       	push   $0x802927
  801b95:	6a 6d                	push   $0x6d
  801b97:	68 d4 29 80 00       	push   $0x8029d4
  801b9c:	e8 99 e5 ff ff       	call   80013a <_panic>

00801ba1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ba1:	f3 0f 1e fb          	endbr32 
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801bc3:	b8 09 00 00 00       	mov    $0x9,%eax
  801bc8:	e8 7d fd ff ff       	call   80194a <nsipc>
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bcf:	f3 0f 1e fb          	endbr32 
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 75 08             	pushl  0x8(%ebp)
  801be1:	e8 f0 f2 ff ff       	call   800ed6 <fd2data>
  801be6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801be8:	83 c4 08             	add    $0x8,%esp
  801beb:	68 ec 29 80 00       	push   $0x8029ec
  801bf0:	53                   	push   %ebx
  801bf1:	e8 35 ec ff ff       	call   80082b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bf6:	8b 46 04             	mov    0x4(%esi),%eax
  801bf9:	2b 06                	sub    (%esi),%eax
  801bfb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c01:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c08:	00 00 00 
	stat->st_dev = &devpipe;
  801c0b:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801c12:	30 80 00 
	return 0;
}
  801c15:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c21:	f3 0f 1e fb          	endbr32 
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c2f:	53                   	push   %ebx
  801c30:	6a 00                	push   $0x0
  801c32:	e8 a8 f0 ff ff       	call   800cdf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c37:	89 1c 24             	mov    %ebx,(%esp)
  801c3a:	e8 97 f2 ff ff       	call   800ed6 <fd2data>
  801c3f:	83 c4 08             	add    $0x8,%esp
  801c42:	50                   	push   %eax
  801c43:	6a 00                	push   $0x0
  801c45:	e8 95 f0 ff ff       	call   800cdf <sys_page_unmap>
}
  801c4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <_pipeisclosed>:
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	57                   	push   %edi
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 1c             	sub    $0x1c,%esp
  801c58:	89 c7                	mov    %eax,%edi
  801c5a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c5c:	a1 08 40 80 00       	mov    0x804008,%eax
  801c61:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c64:	83 ec 0c             	sub    $0xc,%esp
  801c67:	57                   	push   %edi
  801c68:	e8 5f 05 00 00       	call   8021cc <pageref>
  801c6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c70:	89 34 24             	mov    %esi,(%esp)
  801c73:	e8 54 05 00 00       	call   8021cc <pageref>
		nn = thisenv->env_runs;
  801c78:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c7e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	39 cb                	cmp    %ecx,%ebx
  801c86:	74 1b                	je     801ca3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c88:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c8b:	75 cf                	jne    801c5c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c8d:	8b 42 58             	mov    0x58(%edx),%eax
  801c90:	6a 01                	push   $0x1
  801c92:	50                   	push   %eax
  801c93:	53                   	push   %ebx
  801c94:	68 f3 29 80 00       	push   $0x8029f3
  801c99:	e8 83 e5 ff ff       	call   800221 <cprintf>
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	eb b9                	jmp    801c5c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ca3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ca6:	0f 94 c0             	sete   %al
  801ca9:	0f b6 c0             	movzbl %al,%eax
}
  801cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    

00801cb4 <devpipe_write>:
{
  801cb4:	f3 0f 1e fb          	endbr32 
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 28             	sub    $0x28,%esp
  801cc1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cc4:	56                   	push   %esi
  801cc5:	e8 0c f2 ff ff       	call   800ed6 <fd2data>
  801cca:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	bf 00 00 00 00       	mov    $0x0,%edi
  801cd4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cd7:	74 4f                	je     801d28 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cd9:	8b 43 04             	mov    0x4(%ebx),%eax
  801cdc:	8b 0b                	mov    (%ebx),%ecx
  801cde:	8d 51 20             	lea    0x20(%ecx),%edx
  801ce1:	39 d0                	cmp    %edx,%eax
  801ce3:	72 14                	jb     801cf9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801ce5:	89 da                	mov    %ebx,%edx
  801ce7:	89 f0                	mov    %esi,%eax
  801ce9:	e8 61 ff ff ff       	call   801c4f <_pipeisclosed>
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	75 3b                	jne    801d2d <devpipe_write+0x79>
			sys_yield();
  801cf2:	e8 7a ef ff ff       	call   800c71 <sys_yield>
  801cf7:	eb e0                	jmp    801cd9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d00:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d03:	89 c2                	mov    %eax,%edx
  801d05:	c1 fa 1f             	sar    $0x1f,%edx
  801d08:	89 d1                	mov    %edx,%ecx
  801d0a:	c1 e9 1b             	shr    $0x1b,%ecx
  801d0d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d10:	83 e2 1f             	and    $0x1f,%edx
  801d13:	29 ca                	sub    %ecx,%edx
  801d15:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d1d:	83 c0 01             	add    $0x1,%eax
  801d20:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d23:	83 c7 01             	add    $0x1,%edi
  801d26:	eb ac                	jmp    801cd4 <devpipe_write+0x20>
	return i;
  801d28:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2b:	eb 05                	jmp    801d32 <devpipe_write+0x7e>
				return 0;
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <devpipe_read>:
{
  801d3a:	f3 0f 1e fb          	endbr32 
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 18             	sub    $0x18,%esp
  801d47:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d4a:	57                   	push   %edi
  801d4b:	e8 86 f1 ff ff       	call   800ed6 <fd2data>
  801d50:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	be 00 00 00 00       	mov    $0x0,%esi
  801d5a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d5d:	75 14                	jne    801d73 <devpipe_read+0x39>
	return i;
  801d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d62:	eb 02                	jmp    801d66 <devpipe_read+0x2c>
				return i;
  801d64:	89 f0                	mov    %esi,%eax
}
  801d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d69:	5b                   	pop    %ebx
  801d6a:	5e                   	pop    %esi
  801d6b:	5f                   	pop    %edi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    
			sys_yield();
  801d6e:	e8 fe ee ff ff       	call   800c71 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d73:	8b 03                	mov    (%ebx),%eax
  801d75:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d78:	75 18                	jne    801d92 <devpipe_read+0x58>
			if (i > 0)
  801d7a:	85 f6                	test   %esi,%esi
  801d7c:	75 e6                	jne    801d64 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d7e:	89 da                	mov    %ebx,%edx
  801d80:	89 f8                	mov    %edi,%eax
  801d82:	e8 c8 fe ff ff       	call   801c4f <_pipeisclosed>
  801d87:	85 c0                	test   %eax,%eax
  801d89:	74 e3                	je     801d6e <devpipe_read+0x34>
				return 0;
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d90:	eb d4                	jmp    801d66 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d92:	99                   	cltd   
  801d93:	c1 ea 1b             	shr    $0x1b,%edx
  801d96:	01 d0                	add    %edx,%eax
  801d98:	83 e0 1f             	and    $0x1f,%eax
  801d9b:	29 d0                	sub    %edx,%eax
  801d9d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801da8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dab:	83 c6 01             	add    $0x1,%esi
  801dae:	eb aa                	jmp    801d5a <devpipe_read+0x20>

00801db0 <pipe>:
{
  801db0:	f3 0f 1e fb          	endbr32 
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	56                   	push   %esi
  801db8:	53                   	push   %ebx
  801db9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801dbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbf:	50                   	push   %eax
  801dc0:	e8 2c f1 ff ff       	call   800ef1 <fd_alloc>
  801dc5:	89 c3                	mov    %eax,%ebx
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	0f 88 23 01 00 00    	js     801ef5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd2:	83 ec 04             	sub    $0x4,%esp
  801dd5:	68 07 04 00 00       	push   $0x407
  801dda:	ff 75 f4             	pushl  -0xc(%ebp)
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 b0 ee ff ff       	call   800c94 <sys_page_alloc>
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	0f 88 04 01 00 00    	js     801ef5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801df7:	50                   	push   %eax
  801df8:	e8 f4 f0 ff ff       	call   800ef1 <fd_alloc>
  801dfd:	89 c3                	mov    %eax,%ebx
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	85 c0                	test   %eax,%eax
  801e04:	0f 88 db 00 00 00    	js     801ee5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0a:	83 ec 04             	sub    $0x4,%esp
  801e0d:	68 07 04 00 00       	push   $0x407
  801e12:	ff 75 f0             	pushl  -0x10(%ebp)
  801e15:	6a 00                	push   $0x0
  801e17:	e8 78 ee ff ff       	call   800c94 <sys_page_alloc>
  801e1c:	89 c3                	mov    %eax,%ebx
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	85 c0                	test   %eax,%eax
  801e23:	0f 88 bc 00 00 00    	js     801ee5 <pipe+0x135>
	va = fd2data(fd0);
  801e29:	83 ec 0c             	sub    $0xc,%esp
  801e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2f:	e8 a2 f0 ff ff       	call   800ed6 <fd2data>
  801e34:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e36:	83 c4 0c             	add    $0xc,%esp
  801e39:	68 07 04 00 00       	push   $0x407
  801e3e:	50                   	push   %eax
  801e3f:	6a 00                	push   $0x0
  801e41:	e8 4e ee ff ff       	call   800c94 <sys_page_alloc>
  801e46:	89 c3                	mov    %eax,%ebx
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	0f 88 82 00 00 00    	js     801ed5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	ff 75 f0             	pushl  -0x10(%ebp)
  801e59:	e8 78 f0 ff ff       	call   800ed6 <fd2data>
  801e5e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e65:	50                   	push   %eax
  801e66:	6a 00                	push   $0x0
  801e68:	56                   	push   %esi
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 4a ee ff ff       	call   800cba <sys_page_map>
  801e70:	89 c3                	mov    %eax,%ebx
  801e72:	83 c4 20             	add    $0x20,%esp
  801e75:	85 c0                	test   %eax,%eax
  801e77:	78 4e                	js     801ec7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e79:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801e7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e81:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e86:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e8d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e90:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e95:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea2:	e8 1b f0 ff ff       	call   800ec2 <fd2num>
  801ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eaa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eac:	83 c4 04             	add    $0x4,%esp
  801eaf:	ff 75 f0             	pushl  -0x10(%ebp)
  801eb2:	e8 0b f0 ff ff       	call   800ec2 <fd2num>
  801eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ec5:	eb 2e                	jmp    801ef5 <pipe+0x145>
	sys_page_unmap(0, va);
  801ec7:	83 ec 08             	sub    $0x8,%esp
  801eca:	56                   	push   %esi
  801ecb:	6a 00                	push   $0x0
  801ecd:	e8 0d ee ff ff       	call   800cdf <sys_page_unmap>
  801ed2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	ff 75 f0             	pushl  -0x10(%ebp)
  801edb:	6a 00                	push   $0x0
  801edd:	e8 fd ed ff ff       	call   800cdf <sys_page_unmap>
  801ee2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ee5:	83 ec 08             	sub    $0x8,%esp
  801ee8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eeb:	6a 00                	push   $0x0
  801eed:	e8 ed ed ff ff       	call   800cdf <sys_page_unmap>
  801ef2:	83 c4 10             	add    $0x10,%esp
}
  801ef5:	89 d8                	mov    %ebx,%eax
  801ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efa:	5b                   	pop    %ebx
  801efb:	5e                   	pop    %esi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <pipeisclosed>:
{
  801efe:	f3 0f 1e fb          	endbr32 
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0b:	50                   	push   %eax
  801f0c:	ff 75 08             	pushl  0x8(%ebp)
  801f0f:	e8 33 f0 ff ff       	call   800f47 <fd_lookup>
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 18                	js     801f33 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f1b:	83 ec 0c             	sub    $0xc,%esp
  801f1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f21:	e8 b0 ef ff ff       	call   800ed6 <fd2data>
  801f26:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2b:	e8 1f fd ff ff       	call   801c4f <_pipeisclosed>
  801f30:	83 c4 10             	add    $0x10,%esp
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f35:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3e:	c3                   	ret    

00801f3f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f3f:	f3 0f 1e fb          	endbr32 
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f49:	68 0b 2a 80 00       	push   $0x802a0b
  801f4e:	ff 75 0c             	pushl  0xc(%ebp)
  801f51:	e8 d5 e8 ff ff       	call   80082b <strcpy>
	return 0;
}
  801f56:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <devcons_write>:
{
  801f5d:	f3 0f 1e fb          	endbr32 
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	57                   	push   %edi
  801f65:	56                   	push   %esi
  801f66:	53                   	push   %ebx
  801f67:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f6d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f72:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f78:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f7b:	73 31                	jae    801fae <devcons_write+0x51>
		m = n - tot;
  801f7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f80:	29 f3                	sub    %esi,%ebx
  801f82:	83 fb 7f             	cmp    $0x7f,%ebx
  801f85:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f8a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f8d:	83 ec 04             	sub    $0x4,%esp
  801f90:	53                   	push   %ebx
  801f91:	89 f0                	mov    %esi,%eax
  801f93:	03 45 0c             	add    0xc(%ebp),%eax
  801f96:	50                   	push   %eax
  801f97:	57                   	push   %edi
  801f98:	e8 8c ea ff ff       	call   800a29 <memmove>
		sys_cputs(buf, m);
  801f9d:	83 c4 08             	add    $0x8,%esp
  801fa0:	53                   	push   %ebx
  801fa1:	57                   	push   %edi
  801fa2:	e8 3e ec ff ff       	call   800be5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fa7:	01 de                	add    %ebx,%esi
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	eb ca                	jmp    801f78 <devcons_write+0x1b>
}
  801fae:	89 f0                	mov    %esi,%eax
  801fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <devcons_read>:
{
  801fb8:	f3 0f 1e fb          	endbr32 
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 08             	sub    $0x8,%esp
  801fc2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fcb:	74 21                	je     801fee <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801fcd:	e8 35 ec ff ff       	call   800c07 <sys_cgetc>
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	75 07                	jne    801fdd <devcons_read+0x25>
		sys_yield();
  801fd6:	e8 96 ec ff ff       	call   800c71 <sys_yield>
  801fdb:	eb f0                	jmp    801fcd <devcons_read+0x15>
	if (c < 0)
  801fdd:	78 0f                	js     801fee <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801fdf:	83 f8 04             	cmp    $0x4,%eax
  801fe2:	74 0c                	je     801ff0 <devcons_read+0x38>
	*(char*)vbuf = c;
  801fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe7:	88 02                	mov    %al,(%edx)
	return 1;
  801fe9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    
		return 0;
  801ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff5:	eb f7                	jmp    801fee <devcons_read+0x36>

00801ff7 <cputchar>:
{
  801ff7:	f3 0f 1e fb          	endbr32 
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802007:	6a 01                	push   $0x1
  802009:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80200c:	50                   	push   %eax
  80200d:	e8 d3 eb ff ff       	call   800be5 <sys_cputs>
}
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	c9                   	leave  
  802016:	c3                   	ret    

00802017 <getchar>:
{
  802017:	f3 0f 1e fb          	endbr32 
  80201b:	55                   	push   %ebp
  80201c:	89 e5                	mov    %esp,%ebp
  80201e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802021:	6a 01                	push   $0x1
  802023:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802026:	50                   	push   %eax
  802027:	6a 00                	push   $0x0
  802029:	e8 a1 f1 ff ff       	call   8011cf <read>
	if (r < 0)
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	78 06                	js     80203b <getchar+0x24>
	if (r < 1)
  802035:	74 06                	je     80203d <getchar+0x26>
	return c;
  802037:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80203b:	c9                   	leave  
  80203c:	c3                   	ret    
		return -E_EOF;
  80203d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802042:	eb f7                	jmp    80203b <getchar+0x24>

00802044 <iscons>:
{
  802044:	f3 0f 1e fb          	endbr32 
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802051:	50                   	push   %eax
  802052:	ff 75 08             	pushl  0x8(%ebp)
  802055:	e8 ed ee ff ff       	call   800f47 <fd_lookup>
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 11                	js     802072 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802064:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80206a:	39 10                	cmp    %edx,(%eax)
  80206c:	0f 94 c0             	sete   %al
  80206f:	0f b6 c0             	movzbl %al,%eax
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <opencons>:
{
  802074:	f3 0f 1e fb          	endbr32 
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80207e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802081:	50                   	push   %eax
  802082:	e8 6a ee ff ff       	call   800ef1 <fd_alloc>
  802087:	83 c4 10             	add    $0x10,%esp
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 3a                	js     8020c8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80208e:	83 ec 04             	sub    $0x4,%esp
  802091:	68 07 04 00 00       	push   $0x407
  802096:	ff 75 f4             	pushl  -0xc(%ebp)
  802099:	6a 00                	push   $0x0
  80209b:	e8 f4 eb ff ff       	call   800c94 <sys_page_alloc>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 21                	js     8020c8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020aa:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8020b0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020bc:	83 ec 0c             	sub    $0xc,%esp
  8020bf:	50                   	push   %eax
  8020c0:	e8 fd ed ff ff       	call   800ec2 <fd2num>
  8020c5:	83 c4 10             	add    $0x10,%esp
}
  8020c8:	c9                   	leave  
  8020c9:	c3                   	ret    

008020ca <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020ca:	f3 0f 1e fb          	endbr32 
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	56                   	push   %esi
  8020d2:	53                   	push   %ebx
  8020d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8020d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020e3:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	50                   	push   %eax
  8020ea:	e8 ab ec ff ff       	call   800d9a <sys_ipc_recv>
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	85 c0                	test   %eax,%eax
  8020f4:	75 2b                	jne    802121 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8020f6:	85 f6                	test   %esi,%esi
  8020f8:	74 0a                	je     802104 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8020fa:	a1 08 40 80 00       	mov    0x804008,%eax
  8020ff:	8b 40 74             	mov    0x74(%eax),%eax
  802102:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802104:	85 db                	test   %ebx,%ebx
  802106:	74 0a                	je     802112 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802108:	a1 08 40 80 00       	mov    0x804008,%eax
  80210d:	8b 40 78             	mov    0x78(%eax),%eax
  802110:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802112:	a1 08 40 80 00       	mov    0x804008,%eax
  802117:	8b 40 70             	mov    0x70(%eax),%eax
}
  80211a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802121:	85 f6                	test   %esi,%esi
  802123:	74 06                	je     80212b <ipc_recv+0x61>
  802125:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80212b:	85 db                	test   %ebx,%ebx
  80212d:	74 eb                	je     80211a <ipc_recv+0x50>
  80212f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802135:	eb e3                	jmp    80211a <ipc_recv+0x50>

00802137 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802137:	f3 0f 1e fb          	endbr32 
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	57                   	push   %edi
  80213f:	56                   	push   %esi
  802140:	53                   	push   %ebx
  802141:	83 ec 0c             	sub    $0xc,%esp
  802144:	8b 7d 08             	mov    0x8(%ebp),%edi
  802147:	8b 75 0c             	mov    0xc(%ebp),%esi
  80214a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80214d:	85 db                	test   %ebx,%ebx
  80214f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802154:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802157:	ff 75 14             	pushl  0x14(%ebp)
  80215a:	53                   	push   %ebx
  80215b:	56                   	push   %esi
  80215c:	57                   	push   %edi
  80215d:	e8 11 ec ff ff       	call   800d73 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802168:	75 07                	jne    802171 <ipc_send+0x3a>
			sys_yield();
  80216a:	e8 02 eb ff ff       	call   800c71 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80216f:	eb e6                	jmp    802157 <ipc_send+0x20>
		}
		else if (ret == 0)
  802171:	85 c0                	test   %eax,%eax
  802173:	75 08                	jne    80217d <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802175:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802178:	5b                   	pop    %ebx
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80217d:	50                   	push   %eax
  80217e:	68 17 2a 80 00       	push   $0x802a17
  802183:	6a 48                	push   $0x48
  802185:	68 25 2a 80 00       	push   $0x802a25
  80218a:	e8 ab df ff ff       	call   80013a <_panic>

0080218f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80218f:	f3 0f 1e fb          	endbr32 
  802193:	55                   	push   %ebp
  802194:	89 e5                	mov    %esp,%ebp
  802196:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80219e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021a1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021a7:	8b 52 50             	mov    0x50(%edx),%edx
  8021aa:	39 ca                	cmp    %ecx,%edx
  8021ac:	74 11                	je     8021bf <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8021ae:	83 c0 01             	add    $0x1,%eax
  8021b1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021b6:	75 e6                	jne    80219e <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8021b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021bd:	eb 0b                	jmp    8021ca <ipc_find_env+0x3b>
			return envs[i].env_id;
  8021bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021c7:	8b 40 48             	mov    0x48(%eax),%eax
}
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    

008021cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021cc:	f3 0f 1e fb          	endbr32 
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d6:	89 c2                	mov    %eax,%edx
  8021d8:	c1 ea 16             	shr    $0x16,%edx
  8021db:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021e2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021e7:	f6 c1 01             	test   $0x1,%cl
  8021ea:	74 1c                	je     802208 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8021ec:	c1 e8 0c             	shr    $0xc,%eax
  8021ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021f6:	a8 01                	test   $0x1,%al
  8021f8:	74 0e                	je     802208 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021fa:	c1 e8 0c             	shr    $0xc,%eax
  8021fd:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802204:	ef 
  802205:	0f b7 d2             	movzwl %dx,%edx
}
  802208:	89 d0                	mov    %edx,%eax
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__udivdi3>:
  802210:	f3 0f 1e fb          	endbr32 
  802214:	55                   	push   %ebp
  802215:	57                   	push   %edi
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	83 ec 1c             	sub    $0x1c,%esp
  80221b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802223:	8b 74 24 34          	mov    0x34(%esp),%esi
  802227:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80222b:	85 d2                	test   %edx,%edx
  80222d:	75 19                	jne    802248 <__udivdi3+0x38>
  80222f:	39 f3                	cmp    %esi,%ebx
  802231:	76 4d                	jbe    802280 <__udivdi3+0x70>
  802233:	31 ff                	xor    %edi,%edi
  802235:	89 e8                	mov    %ebp,%eax
  802237:	89 f2                	mov    %esi,%edx
  802239:	f7 f3                	div    %ebx
  80223b:	89 fa                	mov    %edi,%edx
  80223d:	83 c4 1c             	add    $0x1c,%esp
  802240:	5b                   	pop    %ebx
  802241:	5e                   	pop    %esi
  802242:	5f                   	pop    %edi
  802243:	5d                   	pop    %ebp
  802244:	c3                   	ret    
  802245:	8d 76 00             	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	76 14                	jbe    802260 <__udivdi3+0x50>
  80224c:	31 ff                	xor    %edi,%edi
  80224e:	31 c0                	xor    %eax,%eax
  802250:	89 fa                	mov    %edi,%edx
  802252:	83 c4 1c             	add    $0x1c,%esp
  802255:	5b                   	pop    %ebx
  802256:	5e                   	pop    %esi
  802257:	5f                   	pop    %edi
  802258:	5d                   	pop    %ebp
  802259:	c3                   	ret    
  80225a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802260:	0f bd fa             	bsr    %edx,%edi
  802263:	83 f7 1f             	xor    $0x1f,%edi
  802266:	75 48                	jne    8022b0 <__udivdi3+0xa0>
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	72 06                	jb     802272 <__udivdi3+0x62>
  80226c:	31 c0                	xor    %eax,%eax
  80226e:	39 eb                	cmp    %ebp,%ebx
  802270:	77 de                	ja     802250 <__udivdi3+0x40>
  802272:	b8 01 00 00 00       	mov    $0x1,%eax
  802277:	eb d7                	jmp    802250 <__udivdi3+0x40>
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	89 d9                	mov    %ebx,%ecx
  802282:	85 db                	test   %ebx,%ebx
  802284:	75 0b                	jne    802291 <__udivdi3+0x81>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f3                	div    %ebx
  80228f:	89 c1                	mov    %eax,%ecx
  802291:	31 d2                	xor    %edx,%edx
  802293:	89 f0                	mov    %esi,%eax
  802295:	f7 f1                	div    %ecx
  802297:	89 c6                	mov    %eax,%esi
  802299:	89 e8                	mov    %ebp,%eax
  80229b:	89 f7                	mov    %esi,%edi
  80229d:	f7 f1                	div    %ecx
  80229f:	89 fa                	mov    %edi,%edx
  8022a1:	83 c4 1c             	add    $0x1c,%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5f                   	pop    %edi
  8022a7:	5d                   	pop    %ebp
  8022a8:	c3                   	ret    
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 f9                	mov    %edi,%ecx
  8022b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8022b7:	29 f8                	sub    %edi,%eax
  8022b9:	d3 e2                	shl    %cl,%edx
  8022bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022bf:	89 c1                	mov    %eax,%ecx
  8022c1:	89 da                	mov    %ebx,%edx
  8022c3:	d3 ea                	shr    %cl,%edx
  8022c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022c9:	09 d1                	or     %edx,%ecx
  8022cb:	89 f2                	mov    %esi,%edx
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	d3 e3                	shl    %cl,%ebx
  8022d5:	89 c1                	mov    %eax,%ecx
  8022d7:	d3 ea                	shr    %cl,%edx
  8022d9:	89 f9                	mov    %edi,%ecx
  8022db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022df:	89 eb                	mov    %ebp,%ebx
  8022e1:	d3 e6                	shl    %cl,%esi
  8022e3:	89 c1                	mov    %eax,%ecx
  8022e5:	d3 eb                	shr    %cl,%ebx
  8022e7:	09 de                	or     %ebx,%esi
  8022e9:	89 f0                	mov    %esi,%eax
  8022eb:	f7 74 24 08          	divl   0x8(%esp)
  8022ef:	89 d6                	mov    %edx,%esi
  8022f1:	89 c3                	mov    %eax,%ebx
  8022f3:	f7 64 24 0c          	mull   0xc(%esp)
  8022f7:	39 d6                	cmp    %edx,%esi
  8022f9:	72 15                	jb     802310 <__udivdi3+0x100>
  8022fb:	89 f9                	mov    %edi,%ecx
  8022fd:	d3 e5                	shl    %cl,%ebp
  8022ff:	39 c5                	cmp    %eax,%ebp
  802301:	73 04                	jae    802307 <__udivdi3+0xf7>
  802303:	39 d6                	cmp    %edx,%esi
  802305:	74 09                	je     802310 <__udivdi3+0x100>
  802307:	89 d8                	mov    %ebx,%eax
  802309:	31 ff                	xor    %edi,%edi
  80230b:	e9 40 ff ff ff       	jmp    802250 <__udivdi3+0x40>
  802310:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802313:	31 ff                	xor    %edi,%edi
  802315:	e9 36 ff ff ff       	jmp    802250 <__udivdi3+0x40>
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	f3 0f 1e fb          	endbr32 
  802324:	55                   	push   %ebp
  802325:	57                   	push   %edi
  802326:	56                   	push   %esi
  802327:	53                   	push   %ebx
  802328:	83 ec 1c             	sub    $0x1c,%esp
  80232b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80232f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802333:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802337:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80233b:	85 c0                	test   %eax,%eax
  80233d:	75 19                	jne    802358 <__umoddi3+0x38>
  80233f:	39 df                	cmp    %ebx,%edi
  802341:	76 5d                	jbe    8023a0 <__umoddi3+0x80>
  802343:	89 f0                	mov    %esi,%eax
  802345:	89 da                	mov    %ebx,%edx
  802347:	f7 f7                	div    %edi
  802349:	89 d0                	mov    %edx,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	83 c4 1c             	add    $0x1c,%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    
  802355:	8d 76 00             	lea    0x0(%esi),%esi
  802358:	89 f2                	mov    %esi,%edx
  80235a:	39 d8                	cmp    %ebx,%eax
  80235c:	76 12                	jbe    802370 <__umoddi3+0x50>
  80235e:	89 f0                	mov    %esi,%eax
  802360:	89 da                	mov    %ebx,%edx
  802362:	83 c4 1c             	add    $0x1c,%esp
  802365:	5b                   	pop    %ebx
  802366:	5e                   	pop    %esi
  802367:	5f                   	pop    %edi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    
  80236a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802370:	0f bd e8             	bsr    %eax,%ebp
  802373:	83 f5 1f             	xor    $0x1f,%ebp
  802376:	75 50                	jne    8023c8 <__umoddi3+0xa8>
  802378:	39 d8                	cmp    %ebx,%eax
  80237a:	0f 82 e0 00 00 00    	jb     802460 <__umoddi3+0x140>
  802380:	89 d9                	mov    %ebx,%ecx
  802382:	39 f7                	cmp    %esi,%edi
  802384:	0f 86 d6 00 00 00    	jbe    802460 <__umoddi3+0x140>
  80238a:	89 d0                	mov    %edx,%eax
  80238c:	89 ca                	mov    %ecx,%edx
  80238e:	83 c4 1c             	add    $0x1c,%esp
  802391:	5b                   	pop    %ebx
  802392:	5e                   	pop    %esi
  802393:	5f                   	pop    %edi
  802394:	5d                   	pop    %ebp
  802395:	c3                   	ret    
  802396:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	89 fd                	mov    %edi,%ebp
  8023a2:	85 ff                	test   %edi,%edi
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x91>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f7                	div    %edi
  8023af:	89 c5                	mov    %eax,%ebp
  8023b1:	89 d8                	mov    %ebx,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f5                	div    %ebp
  8023b7:	89 f0                	mov    %esi,%eax
  8023b9:	f7 f5                	div    %ebp
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	31 d2                	xor    %edx,%edx
  8023bf:	eb 8c                	jmp    80234d <__umoddi3+0x2d>
  8023c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8023cf:	29 ea                	sub    %ebp,%edx
  8023d1:	d3 e0                	shl    %cl,%eax
  8023d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023d7:	89 d1                	mov    %edx,%ecx
  8023d9:	89 f8                	mov    %edi,%eax
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023e9:	09 c1                	or     %eax,%ecx
  8023eb:	89 d8                	mov    %ebx,%eax
  8023ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023f1:	89 e9                	mov    %ebp,%ecx
  8023f3:	d3 e7                	shl    %cl,%edi
  8023f5:	89 d1                	mov    %edx,%ecx
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023ff:	d3 e3                	shl    %cl,%ebx
  802401:	89 c7                	mov    %eax,%edi
  802403:	89 d1                	mov    %edx,%ecx
  802405:	89 f0                	mov    %esi,%eax
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	89 fa                	mov    %edi,%edx
  80240d:	d3 e6                	shl    %cl,%esi
  80240f:	09 d8                	or     %ebx,%eax
  802411:	f7 74 24 08          	divl   0x8(%esp)
  802415:	89 d1                	mov    %edx,%ecx
  802417:	89 f3                	mov    %esi,%ebx
  802419:	f7 64 24 0c          	mull   0xc(%esp)
  80241d:	89 c6                	mov    %eax,%esi
  80241f:	89 d7                	mov    %edx,%edi
  802421:	39 d1                	cmp    %edx,%ecx
  802423:	72 06                	jb     80242b <__umoddi3+0x10b>
  802425:	75 10                	jne    802437 <__umoddi3+0x117>
  802427:	39 c3                	cmp    %eax,%ebx
  802429:	73 0c                	jae    802437 <__umoddi3+0x117>
  80242b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80242f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802433:	89 d7                	mov    %edx,%edi
  802435:	89 c6                	mov    %eax,%esi
  802437:	89 ca                	mov    %ecx,%edx
  802439:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80243e:	29 f3                	sub    %esi,%ebx
  802440:	19 fa                	sbb    %edi,%edx
  802442:	89 d0                	mov    %edx,%eax
  802444:	d3 e0                	shl    %cl,%eax
  802446:	89 e9                	mov    %ebp,%ecx
  802448:	d3 eb                	shr    %cl,%ebx
  80244a:	d3 ea                	shr    %cl,%edx
  80244c:	09 d8                	or     %ebx,%eax
  80244e:	83 c4 1c             	add    $0x1c,%esp
  802451:	5b                   	pop    %ebx
  802452:	5e                   	pop    %esi
  802453:	5f                   	pop    %edi
  802454:	5d                   	pop    %ebp
  802455:	c3                   	ret    
  802456:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80245d:	8d 76 00             	lea    0x0(%esi),%esi
  802460:	29 fe                	sub    %edi,%esi
  802462:	19 c3                	sbb    %eax,%ebx
  802464:	89 f2                	mov    %esi,%edx
  802466:	89 d9                	mov    %ebx,%ecx
  802468:	e9 1d ff ff ff       	jmp    80238a <__umoddi3+0x6a>
