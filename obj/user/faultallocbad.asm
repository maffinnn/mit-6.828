
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 8c 00 00 00       	call   8000bd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

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
  800044:	68 60 24 80 00       	push   $0x802460
  800049:	e8 be 01 00 00       	call   80020c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 1d 0c 00 00       	call   800c7f <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 ac 24 80 00       	push   $0x8024ac
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 3e 07 00 00       	call   8007b5 <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 80 24 80 00       	push   $0x802480
  800089:	6a 0f                	push   $0xf
  80008b:	68 6a 24 80 00       	push   $0x80246a
  800090:	e8 90 00 00 00       	call   800125 <_panic>

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
  8000a4:	e8 6d 0d 00 00       	call   800e16 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	68 ef be ad de       	push   $0xdeadbeef
  8000b3:	e8 18 0b 00 00       	call   800bd0 <sys_cputs>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cc:	e8 68 0b 00 00       	call   800c39 <sys_getenvid>
  8000d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x31>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	e8 9d ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0a 00 00 00       	call   800107 <exit>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800111:	e8 8b 0f 00 00       	call   8010a1 <close_all>
	sys_env_destroy(0);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	6a 00                	push   $0x0
  80011b:	e8 f5 0a 00 00       	call   800c15 <sys_env_destroy>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800125:	f3 0f 1e fb          	endbr32 
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800131:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800137:	e8 fd 0a 00 00       	call   800c39 <sys_getenvid>
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	56                   	push   %esi
  800146:	50                   	push   %eax
  800147:	68 d8 24 80 00       	push   $0x8024d8
  80014c:	e8 bb 00 00 00       	call   80020c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800151:	83 c4 18             	add    $0x18,%esp
  800154:	53                   	push   %ebx
  800155:	ff 75 10             	pushl  0x10(%ebp)
  800158:	e8 5a 00 00 00       	call   8001b7 <vcprintf>
	cprintf("\n");
  80015d:	c7 04 24 e4 29 80 00 	movl   $0x8029e4,(%esp)
  800164:	e8 a3 00 00 00       	call   80020c <cprintf>
  800169:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016c:	cc                   	int3   
  80016d:	eb fd                	jmp    80016c <_panic+0x47>

0080016f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016f:	f3 0f 1e fb          	endbr32 
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	53                   	push   %ebx
  800177:	83 ec 04             	sub    $0x4,%esp
  80017a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017d:	8b 13                	mov    (%ebx),%edx
  80017f:	8d 42 01             	lea    0x1(%edx),%eax
  800182:	89 03                	mov    %eax,(%ebx)
  800184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800187:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800190:	74 09                	je     80019b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800192:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800199:	c9                   	leave  
  80019a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019b:	83 ec 08             	sub    $0x8,%esp
  80019e:	68 ff 00 00 00       	push   $0xff
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 24 0a 00 00       	call   800bd0 <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b2:	83 c4 10             	add    $0x10,%esp
  8001b5:	eb db                	jmp    800192 <putch+0x23>

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	f3 0f 1e fb          	endbr32 
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cb:	00 00 00 
	b.cnt = 0;
  8001ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d8:	ff 75 0c             	pushl  0xc(%ebp)
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	68 6f 01 80 00       	push   $0x80016f
  8001ea:	e8 20 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	83 c4 08             	add    $0x8,%esp
  8001f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	e8 cc 09 00 00       	call   800bd0 <sys_cputs>

	return b.cnt;
}
  800204:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020c:	f3 0f 1e fb          	endbr32 
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 95 ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 1c             	sub    $0x1c,%esp
  80022d:	89 c7                	mov    %eax,%edi
  80022f:	89 d6                	mov    %edx,%esi
  800231:	8b 45 08             	mov    0x8(%ebp),%eax
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 d1                	mov    %edx,%ecx
  800239:	89 c2                	mov    %eax,%edx
  80023b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800241:	8b 45 10             	mov    0x10(%ebp),%eax
  800244:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800247:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800251:	39 c2                	cmp    %eax,%edx
  800253:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800256:	72 3e                	jb     800296 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	83 eb 01             	sub    $0x1,%ebx
  800261:	53                   	push   %ebx
  800262:	50                   	push   %eax
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 89 1f 00 00       	call   802200 <__udivdi3>
  800277:	83 c4 18             	add    $0x18,%esp
  80027a:	52                   	push   %edx
  80027b:	50                   	push   %eax
  80027c:	89 f2                	mov    %esi,%edx
  80027e:	89 f8                	mov    %edi,%eax
  800280:	e8 9f ff ff ff       	call   800224 <printnum>
  800285:	83 c4 20             	add    $0x20,%esp
  800288:	eb 13                	jmp    80029d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	ff 75 18             	pushl  0x18(%ebp)
  800291:	ff d7                	call   *%edi
  800293:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800296:	83 eb 01             	sub    $0x1,%ebx
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f ed                	jg     80028a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 5b 20 00 00       	call   802310 <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 fb 24 80 00 	movsbl 0x8024fb(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff d7                	call   *%edi
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cd:	f3 0f 1e fb          	endbr32 
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1f>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
{
  8002ee:	f3 0f 1e fb          	endbr32 
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	50                   	push   %eax
  8002fc:	ff 75 10             	pushl  0x10(%ebp)
  8002ff:	ff 75 0c             	pushl  0xc(%ebp)
  800302:	ff 75 08             	pushl  0x8(%ebp)
  800305:	e8 05 00 00 00       	call   80030f <vprintfmt>
}
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 3c             	sub    $0x3c,%esp
  80031c:	8b 75 08             	mov    0x8(%ebp),%esi
  80031f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800322:	8b 7d 10             	mov    0x10(%ebp),%edi
  800325:	e9 8e 03 00 00       	jmp    8006b8 <vprintfmt+0x3a9>
		padc = ' ';
  80032a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800335:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800343:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8d 47 01             	lea    0x1(%edi),%eax
  80034b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034e:	0f b6 17             	movzbl (%edi),%edx
  800351:	8d 42 dd             	lea    -0x23(%edx),%eax
  800354:	3c 55                	cmp    $0x55,%al
  800356:	0f 87 df 03 00 00    	ja     80073b <vprintfmt+0x42c>
  80035c:	0f b6 c0             	movzbl %al,%eax
  80035f:	3e ff 24 85 40 26 80 	notrack jmp *0x802640(,%eax,4)
  800366:	00 
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80036e:	eb d8                	jmp    800348 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800373:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800377:	eb cf                	jmp    800348 <vprintfmt+0x39>
  800379:	0f b6 d2             	movzbl %dl,%edx
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037f:	b8 00 00 00 00       	mov    $0x0,%eax
  800384:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800387:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80038e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800391:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800394:	83 f9 09             	cmp    $0x9,%ecx
  800397:	77 55                	ja     8003ee <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800399:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80039c:	eb e9                	jmp    800387 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8d 40 04             	lea    0x4(%eax),%eax
  8003ac:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b6:	79 90                	jns    800348 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003be:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c5:	eb 81                	jmp    800348 <vprintfmt+0x39>
  8003c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d1:	0f 49 d0             	cmovns %eax,%edx
  8003d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003da:	e9 69 ff ff ff       	jmp    800348 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e9:	e9 5a ff ff ff       	jmp    800348 <vprintfmt+0x39>
  8003ee:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f4:	eb bc                	jmp    8003b2 <vprintfmt+0xa3>
			lflag++;
  8003f6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fc:	e9 47 ff ff ff       	jmp    800348 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 78 04             	lea    0x4(%eax),%edi
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	53                   	push   %ebx
  80040b:	ff 30                	pushl  (%eax)
  80040d:	ff d6                	call   *%esi
			break;
  80040f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800412:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800415:	e9 9b 02 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 78 04             	lea    0x4(%eax),%edi
  800420:	8b 00                	mov    (%eax),%eax
  800422:	99                   	cltd   
  800423:	31 d0                	xor    %edx,%eax
  800425:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800427:	83 f8 0f             	cmp    $0xf,%eax
  80042a:	7f 23                	jg     80044f <vprintfmt+0x140>
  80042c:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  800433:	85 d2                	test   %edx,%edx
  800435:	74 18                	je     80044f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800437:	52                   	push   %edx
  800438:	68 19 29 80 00       	push   $0x802919
  80043d:	53                   	push   %ebx
  80043e:	56                   	push   %esi
  80043f:	e8 aa fe ff ff       	call   8002ee <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800447:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044a:	e9 66 02 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80044f:	50                   	push   %eax
  800450:	68 13 25 80 00       	push   $0x802513
  800455:	53                   	push   %ebx
  800456:	56                   	push   %esi
  800457:	e8 92 fe ff ff       	call   8002ee <printfmt>
  80045c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800462:	e9 4e 02 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	83 c0 04             	add    $0x4,%eax
  80046d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800475:	85 d2                	test   %edx,%edx
  800477:	b8 0c 25 80 00       	mov    $0x80250c,%eax
  80047c:	0f 45 c2             	cmovne %edx,%eax
  80047f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800482:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800486:	7e 06                	jle    80048e <vprintfmt+0x17f>
  800488:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80048c:	75 0d                	jne    80049b <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800491:	89 c7                	mov    %eax,%edi
  800493:	03 45 e0             	add    -0x20(%ebp),%eax
  800496:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800499:	eb 55                	jmp    8004f0 <vprintfmt+0x1e1>
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a1:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a4:	e8 46 03 00 00       	call   8007ef <strnlen>
  8004a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ac:	29 c2                	sub    %eax,%edx
  8004ae:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	7e 11                	jle    8004d2 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ef 01             	sub    $0x1,%edi
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	eb eb                	jmp    8004bd <vprintfmt+0x1ae>
  8004d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dc:	0f 49 c2             	cmovns %edx,%eax
  8004df:	29 c2                	sub    %eax,%edx
  8004e1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e4:	eb a8                	jmp    80048e <vprintfmt+0x17f>
					putch(ch, putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	52                   	push   %edx
  8004eb:	ff d6                	call   *%esi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f5:	83 c7 01             	add    $0x1,%edi
  8004f8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fc:	0f be d0             	movsbl %al,%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	74 4b                	je     80054e <vprintfmt+0x23f>
  800503:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800507:	78 06                	js     80050f <vprintfmt+0x200>
  800509:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050d:	78 1e                	js     80052d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80050f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800513:	74 d1                	je     8004e6 <vprintfmt+0x1d7>
  800515:	0f be c0             	movsbl %al,%eax
  800518:	83 e8 20             	sub    $0x20,%eax
  80051b:	83 f8 5e             	cmp    $0x5e,%eax
  80051e:	76 c6                	jbe    8004e6 <vprintfmt+0x1d7>
					putch('?', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	6a 3f                	push   $0x3f
  800526:	ff d6                	call   *%esi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb c3                	jmp    8004f0 <vprintfmt+0x1e1>
  80052d:	89 cf                	mov    %ecx,%edi
  80052f:	eb 0e                	jmp    80053f <vprintfmt+0x230>
				putch(' ', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	6a 20                	push   $0x20
  800537:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800539:	83 ef 01             	sub    $0x1,%edi
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	85 ff                	test   %edi,%edi
  800541:	7f ee                	jg     800531 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
  800549:	e9 67 01 00 00       	jmp    8006b5 <vprintfmt+0x3a6>
  80054e:	89 cf                	mov    %ecx,%edi
  800550:	eb ed                	jmp    80053f <vprintfmt+0x230>
	if (lflag >= 2)
  800552:	83 f9 01             	cmp    $0x1,%ecx
  800555:	7f 1b                	jg     800572 <vprintfmt+0x263>
	else if (lflag)
  800557:	85 c9                	test   %ecx,%ecx
  800559:	74 63                	je     8005be <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800563:	99                   	cltd   
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
  800570:	eb 17                	jmp    800589 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 50 04             	mov    0x4(%eax),%edx
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 40 08             	lea    0x8(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800589:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80058f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800594:	85 c9                	test   %ecx,%ecx
  800596:	0f 89 ff 00 00 00    	jns    80069b <vprintfmt+0x38c>
				putch('-', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 2d                	push   $0x2d
  8005a2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005aa:	f7 da                	neg    %edx
  8005ac:	83 d1 00             	adc    $0x0,%ecx
  8005af:	f7 d9                	neg    %ecx
  8005b1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b9:	e9 dd 00 00 00       	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	99                   	cltd   
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d3:	eb b4                	jmp    800589 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005d5:	83 f9 01             	cmp    $0x1,%ecx
  8005d8:	7f 1e                	jg     8005f8 <vprintfmt+0x2e9>
	else if (lflag)
  8005da:	85 c9                	test   %ecx,%ecx
  8005dc:	74 32                	je     800610 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005f3:	e9 a3 00 00 00       	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800600:	8d 40 08             	lea    0x8(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80060b:	e9 8b 00 00 00       	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 10                	mov    (%eax),%edx
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061a:	8d 40 04             	lea    0x4(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800625:	eb 74                	jmp    80069b <vprintfmt+0x38c>
	if (lflag >= 2)
  800627:	83 f9 01             	cmp    $0x1,%ecx
  80062a:	7f 1b                	jg     800647 <vprintfmt+0x338>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	74 2c                	je     80065c <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	8d 40 04             	lea    0x4(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800640:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800645:	eb 54                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 10                	mov    (%eax),%edx
  80064c:	8b 48 04             	mov    0x4(%eax),%ecx
  80064f:	8d 40 08             	lea    0x8(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800655:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80065a:	eb 3f                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800671:	eb 28                	jmp    80069b <vprintfmt+0x38c>
			putch('0', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 30                	push   $0x30
  800679:	ff d6                	call   *%esi
			putch('x', putdat);
  80067b:	83 c4 08             	add    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 78                	push   $0x78
  800681:	ff d6                	call   *%esi
			num = (unsigned long long)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80068d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800696:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006a2:	57                   	push   %edi
  8006a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a6:	50                   	push   %eax
  8006a7:	51                   	push   %ecx
  8006a8:	52                   	push   %edx
  8006a9:	89 da                	mov    %ebx,%edx
  8006ab:	89 f0                	mov    %esi,%eax
  8006ad:	e8 72 fb ff ff       	call   800224 <printnum>
			break;
  8006b2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006b8:	83 c7 01             	add    $0x1,%edi
  8006bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006bf:	83 f8 25             	cmp    $0x25,%eax
  8006c2:	0f 84 62 fc ff ff    	je     80032a <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	0f 84 8b 00 00 00    	je     80075b <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	50                   	push   %eax
  8006d5:	ff d6                	call   *%esi
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb dc                	jmp    8006b8 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006dc:	83 f9 01             	cmp    $0x1,%ecx
  8006df:	7f 1b                	jg     8006fc <vprintfmt+0x3ed>
	else if (lflag)
  8006e1:	85 c9                	test   %ecx,%ecx
  8006e3:	74 2c                	je     800711 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006fa:	eb 9f                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	8b 48 04             	mov    0x4(%eax),%ecx
  800704:	8d 40 08             	lea    0x8(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80070f:	eb 8a                	jmp    80069b <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071b:	8d 40 04             	lea    0x4(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800721:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800726:	e9 70 ff ff ff       	jmp    80069b <vprintfmt+0x38c>
			putch(ch, putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 25                	push   $0x25
  800731:	ff d6                	call   *%esi
			break;
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	e9 7a ff ff ff       	jmp    8006b5 <vprintfmt+0x3a6>
			putch('%', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 25                	push   $0x25
  800741:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	89 f8                	mov    %edi,%eax
  800748:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80074c:	74 05                	je     800753 <vprintfmt+0x444>
  80074e:	83 e8 01             	sub    $0x1,%eax
  800751:	eb f5                	jmp    800748 <vprintfmt+0x439>
  800753:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800756:	e9 5a ff ff ff       	jmp    8006b5 <vprintfmt+0x3a6>
}
  80075b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075e:	5b                   	pop    %ebx
  80075f:	5e                   	pop    %esi
  800760:	5f                   	pop    %edi
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800763:	f3 0f 1e fb          	endbr32 
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 18             	sub    $0x18,%esp
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
  800770:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800773:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800776:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800784:	85 c0                	test   %eax,%eax
  800786:	74 26                	je     8007ae <vsnprintf+0x4b>
  800788:	85 d2                	test   %edx,%edx
  80078a:	7e 22                	jle    8007ae <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078c:	ff 75 14             	pushl  0x14(%ebp)
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800795:	50                   	push   %eax
  800796:	68 cd 02 80 00       	push   $0x8002cd
  80079b:	e8 6f fb ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	83 c4 10             	add    $0x10,%esp
}
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    
		return -E_INVAL;
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b3:	eb f7                	jmp    8007ac <vsnprintf+0x49>

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	f3 0f 1e fb          	endbr32 
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c2:	50                   	push   %eax
  8007c3:	ff 75 10             	pushl  0x10(%ebp)
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	ff 75 08             	pushl  0x8(%ebp)
  8007cc:	e8 92 ff ff ff       	call   800763 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d3:	f3 0f 1e fb          	endbr32 
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e6:	74 05                	je     8007ed <strlen+0x1a>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	eb f5                	jmp    8007e2 <strlen+0xf>
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ef:	f3 0f 1e fb          	endbr32 
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800801:	39 d0                	cmp    %edx,%eax
  800803:	74 0d                	je     800812 <strnlen+0x23>
  800805:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800809:	74 05                	je     800810 <strnlen+0x21>
		n++;
  80080b:	83 c0 01             	add    $0x1,%eax
  80080e:	eb f1                	jmp    800801 <strnlen+0x12>
  800810:	89 c2                	mov    %eax,%edx
	return n;
}
  800812:	89 d0                	mov    %edx,%eax
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800816:	f3 0f 1e fb          	endbr32 
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80082d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800830:	83 c0 01             	add    $0x1,%eax
  800833:	84 d2                	test   %dl,%dl
  800835:	75 f2                	jne    800829 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800837:	89 c8                	mov    %ecx,%eax
  800839:	5b                   	pop    %ebx
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083c:	f3 0f 1e fb          	endbr32 
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	83 ec 10             	sub    $0x10,%esp
  800847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084a:	53                   	push   %ebx
  80084b:	e8 83 ff ff ff       	call   8007d3 <strlen>
  800850:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800853:	ff 75 0c             	pushl  0xc(%ebp)
  800856:	01 d8                	add    %ebx,%eax
  800858:	50                   	push   %eax
  800859:	e8 b8 ff ff ff       	call   800816 <strcpy>
	return dst;
}
  80085e:	89 d8                	mov    %ebx,%eax
  800860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800865:	f3 0f 1e fb          	endbr32 
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	8b 75 08             	mov    0x8(%ebp),%esi
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
  800874:	89 f3                	mov    %esi,%ebx
  800876:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	89 f0                	mov    %esi,%eax
  80087b:	39 d8                	cmp    %ebx,%eax
  80087d:	74 11                	je     800890 <strncpy+0x2b>
		*dst++ = *src;
  80087f:	83 c0 01             	add    $0x1,%eax
  800882:	0f b6 0a             	movzbl (%edx),%ecx
  800885:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800888:	80 f9 01             	cmp    $0x1,%cl
  80088b:	83 da ff             	sbb    $0xffffffff,%edx
  80088e:	eb eb                	jmp    80087b <strncpy+0x16>
	}
	return ret;
}
  800890:	89 f0                	mov    %esi,%eax
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a5:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	74 21                	je     8008cf <strlcpy+0x39>
  8008ae:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b2:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008b4:	39 c2                	cmp    %eax,%edx
  8008b6:	74 14                	je     8008cc <strlcpy+0x36>
  8008b8:	0f b6 19             	movzbl (%ecx),%ebx
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	74 0b                	je     8008ca <strlcpy+0x34>
			*dst++ = *src++;
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c8:	eb ea                	jmp    8008b4 <strlcpy+0x1e>
  8008ca:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008cc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008cf:	29 f0                	sub    %esi,%eax
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d5:	f3 0f 1e fb          	endbr32 
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e2:	0f b6 01             	movzbl (%ecx),%eax
  8008e5:	84 c0                	test   %al,%al
  8008e7:	74 0c                	je     8008f5 <strcmp+0x20>
  8008e9:	3a 02                	cmp    (%edx),%al
  8008eb:	75 08                	jne    8008f5 <strcmp+0x20>
		p++, q++;
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	eb ed                	jmp    8008e2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 c0             	movzbl %al,%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ff:	f3 0f 1e fb          	endbr32 
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 c3                	mov    %eax,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800912:	eb 06                	jmp    80091a <strncmp+0x1b>
		n--, p++, q++;
  800914:	83 c0 01             	add    $0x1,%eax
  800917:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091a:	39 d8                	cmp    %ebx,%eax
  80091c:	74 16                	je     800934 <strncmp+0x35>
  80091e:	0f b6 08             	movzbl (%eax),%ecx
  800921:	84 c9                	test   %cl,%cl
  800923:	74 04                	je     800929 <strncmp+0x2a>
  800925:	3a 0a                	cmp    (%edx),%cl
  800927:	74 eb                	je     800914 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 00             	movzbl (%eax),%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    
		return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb f6                	jmp    800931 <strncmp+0x32>

0080093b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093b:	f3 0f 1e fb          	endbr32 
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800949:	0f b6 10             	movzbl (%eax),%edx
  80094c:	84 d2                	test   %dl,%dl
  80094e:	74 09                	je     800959 <strchr+0x1e>
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 0a                	je     80095e <strchr+0x23>
	for (; *s; s++)
  800954:	83 c0 01             	add    $0x1,%eax
  800957:	eb f0                	jmp    800949 <strchr+0xe>
			return (char *) s;
	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800960:	f3 0f 1e fb          	endbr32 
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80096a:	6a 78                	push   $0x78
  80096c:	ff 75 08             	pushl  0x8(%ebp)
  80096f:	e8 c7 ff ff ff       	call   80093b <strchr>
  800974:	83 c4 10             	add    $0x10,%esp
  800977:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80097a:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  80097f:	eb 0d                	jmp    80098e <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800981:	c1 e0 04             	shl    $0x4,%eax
  800984:	0f be d2             	movsbl %dl,%edx
  800987:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  80098b:	83 c1 01             	add    $0x1,%ecx
  80098e:	0f b6 11             	movzbl (%ecx),%edx
  800991:	84 d2                	test   %dl,%dl
  800993:	74 11                	je     8009a6 <atox+0x46>
		if (*p>='a'){
  800995:	80 fa 60             	cmp    $0x60,%dl
  800998:	7e e7                	jle    800981 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  80099a:	c1 e0 04             	shl    $0x4,%eax
  80099d:	0f be d2             	movsbl %dl,%edx
  8009a0:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009a4:	eb e5                	jmp    80098b <atox+0x2b>
	}

	return v;

}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a8:	f3 0f 1e fb          	endbr32 
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b9:	38 ca                	cmp    %cl,%dl
  8009bb:	74 09                	je     8009c6 <strfind+0x1e>
  8009bd:	84 d2                	test   %dl,%dl
  8009bf:	74 05                	je     8009c6 <strfind+0x1e>
	for (; *s; s++)
  8009c1:	83 c0 01             	add    $0x1,%eax
  8009c4:	eb f0                	jmp    8009b6 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c8:	f3 0f 1e fb          	endbr32 
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d8:	85 c9                	test   %ecx,%ecx
  8009da:	74 31                	je     800a0d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009dc:	89 f8                	mov    %edi,%eax
  8009de:	09 c8                	or     %ecx,%eax
  8009e0:	a8 03                	test   $0x3,%al
  8009e2:	75 23                	jne    800a07 <memset+0x3f>
		c &= 0xFF;
  8009e4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e8:	89 d3                	mov    %edx,%ebx
  8009ea:	c1 e3 08             	shl    $0x8,%ebx
  8009ed:	89 d0                	mov    %edx,%eax
  8009ef:	c1 e0 18             	shl    $0x18,%eax
  8009f2:	89 d6                	mov    %edx,%esi
  8009f4:	c1 e6 10             	shl    $0x10,%esi
  8009f7:	09 f0                	or     %esi,%eax
  8009f9:	09 c2                	or     %eax,%edx
  8009fb:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009fd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a00:	89 d0                	mov    %edx,%eax
  800a02:	fc                   	cld    
  800a03:	f3 ab                	rep stos %eax,%es:(%edi)
  800a05:	eb 06                	jmp    800a0d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	fc                   	cld    
  800a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0d:	89 f8                	mov    %edi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a14:	f3 0f 1e fb          	endbr32 
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a26:	39 c6                	cmp    %eax,%esi
  800a28:	73 32                	jae    800a5c <memmove+0x48>
  800a2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2d:	39 c2                	cmp    %eax,%edx
  800a2f:	76 2b                	jbe    800a5c <memmove+0x48>
		s += n;
		d += n;
  800a31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a34:	89 fe                	mov    %edi,%esi
  800a36:	09 ce                	or     %ecx,%esi
  800a38:	09 d6                	or     %edx,%esi
  800a3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a40:	75 0e                	jne    800a50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a42:	83 ef 04             	sub    $0x4,%edi
  800a45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a48:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4b:	fd                   	std    
  800a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4e:	eb 09                	jmp    800a59 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a50:	83 ef 01             	sub    $0x1,%edi
  800a53:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a56:	fd                   	std    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a59:	fc                   	cld    
  800a5a:	eb 1a                	jmp    800a76 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5c:	89 c2                	mov    %eax,%edx
  800a5e:	09 ca                	or     %ecx,%edx
  800a60:	09 f2                	or     %esi,%edx
  800a62:	f6 c2 03             	test   $0x3,%dl
  800a65:	75 0a                	jne    800a71 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6a:	89 c7                	mov    %eax,%edi
  800a6c:	fc                   	cld    
  800a6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6f:	eb 05                	jmp    800a76 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a71:	89 c7                	mov    %eax,%edi
  800a73:	fc                   	cld    
  800a74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7a:	f3 0f 1e fb          	endbr32 
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a84:	ff 75 10             	pushl  0x10(%ebp)
  800a87:	ff 75 0c             	pushl  0xc(%ebp)
  800a8a:	ff 75 08             	pushl  0x8(%ebp)
  800a8d:	e8 82 ff ff ff       	call   800a14 <memmove>
}
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    

00800a94 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a94:	f3 0f 1e fb          	endbr32 
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	89 c6                	mov    %eax,%esi
  800aa5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa8:	39 f0                	cmp    %esi,%eax
  800aaa:	74 1c                	je     800ac8 <memcmp+0x34>
		if (*s1 != *s2)
  800aac:	0f b6 08             	movzbl (%eax),%ecx
  800aaf:	0f b6 1a             	movzbl (%edx),%ebx
  800ab2:	38 d9                	cmp    %bl,%cl
  800ab4:	75 08                	jne    800abe <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab6:	83 c0 01             	add    $0x1,%eax
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	eb ea                	jmp    800aa8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800abe:	0f b6 c1             	movzbl %cl,%eax
  800ac1:	0f b6 db             	movzbl %bl,%ebx
  800ac4:	29 d8                	sub    %ebx,%eax
  800ac6:	eb 05                	jmp    800acd <memcmp+0x39>
	}

	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad1:	f3 0f 1e fb          	endbr32 
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ade:	89 c2                	mov    %eax,%edx
  800ae0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae3:	39 d0                	cmp    %edx,%eax
  800ae5:	73 09                	jae    800af0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae7:	38 08                	cmp    %cl,(%eax)
  800ae9:	74 05                	je     800af0 <memfind+0x1f>
	for (; s < ends; s++)
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	eb f3                	jmp    800ae3 <memfind+0x12>
			break;
	return (void *) s;
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af2:	f3 0f 1e fb          	endbr32 
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b02:	eb 03                	jmp    800b07 <strtol+0x15>
		s++;
  800b04:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	3c 20                	cmp    $0x20,%al
  800b0c:	74 f6                	je     800b04 <strtol+0x12>
  800b0e:	3c 09                	cmp    $0x9,%al
  800b10:	74 f2                	je     800b04 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b12:	3c 2b                	cmp    $0x2b,%al
  800b14:	74 2a                	je     800b40 <strtol+0x4e>
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1b:	3c 2d                	cmp    $0x2d,%al
  800b1d:	74 2b                	je     800b4a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b25:	75 0f                	jne    800b36 <strtol+0x44>
  800b27:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2a:	74 28                	je     800b54 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2c:	85 db                	test   %ebx,%ebx
  800b2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b33:	0f 44 d8             	cmove  %eax,%ebx
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b3e:	eb 46                	jmp    800b86 <strtol+0x94>
		s++;
  800b40:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	eb d5                	jmp    800b1f <strtol+0x2d>
		s++, neg = 1;
  800b4a:	83 c1 01             	add    $0x1,%ecx
  800b4d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b52:	eb cb                	jmp    800b1f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b58:	74 0e                	je     800b68 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 d8                	jne    800b36 <strtol+0x44>
		s++, base = 8;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b66:	eb ce                	jmp    800b36 <strtol+0x44>
		s += 2, base = 16;
  800b68:	83 c1 02             	add    $0x2,%ecx
  800b6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b70:	eb c4                	jmp    800b36 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b72:	0f be d2             	movsbl %dl,%edx
  800b75:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b78:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7b:	7d 3a                	jge    800bb7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b7d:	83 c1 01             	add    $0x1,%ecx
  800b80:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b84:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b86:	0f b6 11             	movzbl (%ecx),%edx
  800b89:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 09             	cmp    $0x9,%bl
  800b91:	76 df                	jbe    800b72 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b93:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b96:	89 f3                	mov    %esi,%ebx
  800b98:	80 fb 19             	cmp    $0x19,%bl
  800b9b:	77 08                	ja     800ba5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9d:	0f be d2             	movsbl %dl,%edx
  800ba0:	83 ea 57             	sub    $0x57,%edx
  800ba3:	eb d3                	jmp    800b78 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba8:	89 f3                	mov    %esi,%ebx
  800baa:	80 fb 19             	cmp    $0x19,%bl
  800bad:	77 08                	ja     800bb7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800baf:	0f be d2             	movsbl %dl,%edx
  800bb2:	83 ea 37             	sub    $0x37,%edx
  800bb5:	eb c1                	jmp    800b78 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbb:	74 05                	je     800bc2 <strtol+0xd0>
		*endptr = (char *) s;
  800bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc2:	89 c2                	mov    %eax,%edx
  800bc4:	f7 da                	neg    %edx
  800bc6:	85 ff                	test   %edi,%edi
  800bc8:	0f 45 c2             	cmovne %edx,%eax
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	89 c3                	mov    %eax,%ebx
  800be7:	89 c7                	mov    %eax,%edi
  800be9:	89 c6                	mov    %eax,%esi
  800beb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf2:	f3 0f 1e fb          	endbr32 
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c15:	f3 0f 1e fb          	endbr32 
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2c:	89 cb                	mov    %ecx,%ebx
  800c2e:	89 cf                	mov    %ecx,%edi
  800c30:	89 ce                	mov    %ecx,%esi
  800c32:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c39:	f3 0f 1e fb          	endbr32 
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_yield>:

void
sys_yield(void)
{
  800c5c:	f3 0f 1e fb          	endbr32 
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c70:	89 d1                	mov    %edx,%ecx
  800c72:	89 d3                	mov    %edx,%ebx
  800c74:	89 d7                	mov    %edx,%edi
  800c76:	89 d6                	mov    %edx,%esi
  800c78:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c7f:	f3 0f 1e fb          	endbr32 
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c89:	be 00 00 00 00       	mov    $0x0,%esi
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	b8 04 00 00 00       	mov    $0x4,%eax
  800c99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9c:	89 f7                	mov    %esi,%edi
  800c9e:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc0:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc3:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cca:	f3 0f 1e fb          	endbr32 
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cef:	f3 0f 1e fb          	endbr32 
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	b8 08 00 00 00       	mov    $0x8,%eax
  800d09:	89 df                	mov    %ebx,%edi
  800d0b:	89 de                	mov    %ebx,%esi
  800d0d:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d14:	f3 0f 1e fb          	endbr32 
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d39:	f3 0f 1e fb          	endbr32 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5e:	f3 0f 1e fb          	endbr32 
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d73:	be 00 00 00 00       	mov    $0x0,%esi
  800d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d85:	f3 0f 1e fb          	endbr32 
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9c:	89 cb                	mov    %ecx,%ebx
  800d9e:	89 cf                	mov    %ecx,%edi
  800da0:	89 ce                	mov    %ecx,%esi
  800da2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800da9:	f3 0f 1e fb          	endbr32 
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db3:	ba 00 00 00 00       	mov    $0x0,%edx
  800db8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dbd:	89 d1                	mov    %edx,%ecx
  800dbf:	89 d3                	mov    %edx,%ebx
  800dc1:	89 d7                	mov    %edx,%edi
  800dc3:	89 d6                	mov    %edx,%esi
  800dc5:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800dcc:	f3 0f 1e fb          	endbr32 
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800df1:	f3 0f 1e fb          	endbr32 
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	b8 10 00 00 00       	mov    $0x10,%eax
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e16:	f3 0f 1e fb          	endbr32 
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e20:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800e27:	74 0a                	je     800e33 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	a3 0c 40 80 00       	mov    %eax,0x80400c

}
  800e31:	c9                   	leave  
  800e32:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	6a 07                	push   $0x7
  800e38:	68 00 f0 bf ee       	push   $0xeebff000
  800e3d:	6a 00                	push   $0x0
  800e3f:	e8 3b fe ff ff       	call   800c7f <sys_page_alloc>
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	78 2a                	js     800e75 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	68 89 0e 80 00       	push   $0x800e89
  800e53:	6a 00                	push   $0x0
  800e55:	e8 df fe ff ff       	call   800d39 <sys_env_set_pgfault_upcall>
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	79 c8                	jns    800e29 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	68 2c 28 80 00       	push   $0x80282c
  800e69:	6a 2c                	push   $0x2c
  800e6b:	68 62 28 80 00       	push   $0x802862
  800e70:	e8 b0 f2 ff ff       	call   800125 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	68 00 28 80 00       	push   $0x802800
  800e7d:	6a 22                	push   $0x22
  800e7f:	68 62 28 80 00       	push   $0x802862
  800e84:	e8 9c f2 ff ff       	call   800125 <_panic>

00800e89 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e89:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e8a:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax   			// 间接寻址
  800e8f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e91:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  800e94:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  800e98:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  800e9d:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  800ea1:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  800ea3:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  800ea6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  800ea7:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  800eaa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  800eab:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  800eac:	c3                   	ret    

00800ead <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ead:	f3 0f 1e fb          	endbr32 
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	05 00 00 00 30       	add    $0x30000000,%eax
  800ebc:	c1 e8 0c             	shr    $0xc,%eax
}
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ec1:	f3 0f 1e fb          	endbr32 
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ed0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ed5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800edc:	f3 0f 1e fb          	endbr32 
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ee8:	89 c2                	mov    %eax,%edx
  800eea:	c1 ea 16             	shr    $0x16,%edx
  800eed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef4:	f6 c2 01             	test   $0x1,%dl
  800ef7:	74 2d                	je     800f26 <fd_alloc+0x4a>
  800ef9:	89 c2                	mov    %eax,%edx
  800efb:	c1 ea 0c             	shr    $0xc,%edx
  800efe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f05:	f6 c2 01             	test   $0x1,%dl
  800f08:	74 1c                	je     800f26 <fd_alloc+0x4a>
  800f0a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f0f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f14:	75 d2                	jne    800ee8 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f1f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f24:	eb 0a                	jmp    800f30 <fd_alloc+0x54>
			*fd_store = fd;
  800f26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f29:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f32:	f3 0f 1e fb          	endbr32 
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f3c:	83 f8 1f             	cmp    $0x1f,%eax
  800f3f:	77 30                	ja     800f71 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f41:	c1 e0 0c             	shl    $0xc,%eax
  800f44:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f49:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f4f:	f6 c2 01             	test   $0x1,%dl
  800f52:	74 24                	je     800f78 <fd_lookup+0x46>
  800f54:	89 c2                	mov    %eax,%edx
  800f56:	c1 ea 0c             	shr    $0xc,%edx
  800f59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f60:	f6 c2 01             	test   $0x1,%dl
  800f63:	74 1a                	je     800f7f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f68:	89 02                	mov    %eax,(%edx)
	return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    
		return -E_INVAL;
  800f71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f76:	eb f7                	jmp    800f6f <fd_lookup+0x3d>
		return -E_INVAL;
  800f78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7d:	eb f0                	jmp    800f6f <fd_lookup+0x3d>
  800f7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f84:	eb e9                	jmp    800f6f <fd_lookup+0x3d>

00800f86 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f86:	f3 0f 1e fb          	endbr32 
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f93:	ba 00 00 00 00       	mov    $0x0,%edx
  800f98:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f9d:	39 08                	cmp    %ecx,(%eax)
  800f9f:	74 38                	je     800fd9 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800fa1:	83 c2 01             	add    $0x1,%edx
  800fa4:	8b 04 95 ec 28 80 00 	mov    0x8028ec(,%edx,4),%eax
  800fab:	85 c0                	test   %eax,%eax
  800fad:	75 ee                	jne    800f9d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800faf:	a1 08 40 80 00       	mov    0x804008,%eax
  800fb4:	8b 40 48             	mov    0x48(%eax),%eax
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	51                   	push   %ecx
  800fbb:	50                   	push   %eax
  800fbc:	68 70 28 80 00       	push   $0x802870
  800fc1:	e8 46 f2 ff ff       	call   80020c <cprintf>
	*dev = 0;
  800fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    
			*dev = devtab[i];
  800fd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe3:	eb f2                	jmp    800fd7 <dev_lookup+0x51>

00800fe5 <fd_close>:
{
  800fe5:	f3 0f 1e fb          	endbr32 
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 24             	sub    $0x24,%esp
  800ff2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ffb:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ffc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801002:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801005:	50                   	push   %eax
  801006:	e8 27 ff ff ff       	call   800f32 <fd_lookup>
  80100b:	89 c3                	mov    %eax,%ebx
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 05                	js     801019 <fd_close+0x34>
	    || fd != fd2)
  801014:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801017:	74 16                	je     80102f <fd_close+0x4a>
		return (must_exist ? r : 0);
  801019:	89 f8                	mov    %edi,%eax
  80101b:	84 c0                	test   %al,%al
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
  801022:	0f 44 d8             	cmove  %eax,%ebx
}
  801025:	89 d8                	mov    %ebx,%eax
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	ff 36                	pushl  (%esi)
  801038:	e8 49 ff ff ff       	call   800f86 <dev_lookup>
  80103d:	89 c3                	mov    %eax,%ebx
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 1a                	js     801060 <fd_close+0x7b>
		if (dev->dev_close)
  801046:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801049:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80104c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801051:	85 c0                	test   %eax,%eax
  801053:	74 0b                	je     801060 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	56                   	push   %esi
  801059:	ff d0                	call   *%eax
  80105b:	89 c3                	mov    %eax,%ebx
  80105d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 5f fc ff ff       	call   800cca <sys_page_unmap>
	return r;
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	eb b5                	jmp    801025 <fd_close+0x40>

00801070 <close>:

int
close(int fdnum)
{
  801070:	f3 0f 1e fb          	endbr32 
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80107a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	ff 75 08             	pushl  0x8(%ebp)
  801081:	e8 ac fe ff ff       	call   800f32 <fd_lookup>
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	79 02                	jns    80108f <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    
		return fd_close(fd, 1);
  80108f:	83 ec 08             	sub    $0x8,%esp
  801092:	6a 01                	push   $0x1
  801094:	ff 75 f4             	pushl  -0xc(%ebp)
  801097:	e8 49 ff ff ff       	call   800fe5 <fd_close>
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	eb ec                	jmp    80108d <close+0x1d>

008010a1 <close_all>:

void
close_all(void)
{
  8010a1:	f3 0f 1e fb          	endbr32 
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	e8 b6 ff ff ff       	call   801070 <close>
	for (i = 0; i < MAXFD; i++)
  8010ba:	83 c3 01             	add    $0x1,%ebx
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	83 fb 20             	cmp    $0x20,%ebx
  8010c3:	75 ec                	jne    8010b1 <close_all+0x10>
}
  8010c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ca:	f3 0f 1e fb          	endbr32 
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010da:	50                   	push   %eax
  8010db:	ff 75 08             	pushl  0x8(%ebp)
  8010de:	e8 4f fe ff ff       	call   800f32 <fd_lookup>
  8010e3:	89 c3                	mov    %eax,%ebx
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	0f 88 81 00 00 00    	js     801171 <dup+0xa7>
		return r;
	close(newfdnum);
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	ff 75 0c             	pushl  0xc(%ebp)
  8010f6:	e8 75 ff ff ff       	call   801070 <close>

	newfd = INDEX2FD(newfdnum);
  8010fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010fe:	c1 e6 0c             	shl    $0xc,%esi
  801101:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801107:	83 c4 04             	add    $0x4,%esp
  80110a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110d:	e8 af fd ff ff       	call   800ec1 <fd2data>
  801112:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801114:	89 34 24             	mov    %esi,(%esp)
  801117:	e8 a5 fd ff ff       	call   800ec1 <fd2data>
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801121:	89 d8                	mov    %ebx,%eax
  801123:	c1 e8 16             	shr    $0x16,%eax
  801126:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112d:	a8 01                	test   $0x1,%al
  80112f:	74 11                	je     801142 <dup+0x78>
  801131:	89 d8                	mov    %ebx,%eax
  801133:	c1 e8 0c             	shr    $0xc,%eax
  801136:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	75 39                	jne    80117b <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801142:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801145:	89 d0                	mov    %edx,%eax
  801147:	c1 e8 0c             	shr    $0xc,%eax
  80114a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	25 07 0e 00 00       	and    $0xe07,%eax
  801159:	50                   	push   %eax
  80115a:	56                   	push   %esi
  80115b:	6a 00                	push   $0x0
  80115d:	52                   	push   %edx
  80115e:	6a 00                	push   $0x0
  801160:	e8 40 fb ff ff       	call   800ca5 <sys_page_map>
  801165:	89 c3                	mov    %eax,%ebx
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 31                	js     80119f <dup+0xd5>
		goto err;

	return newfdnum;
  80116e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801171:	89 d8                	mov    %ebx,%eax
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801182:	83 ec 0c             	sub    $0xc,%esp
  801185:	25 07 0e 00 00       	and    $0xe07,%eax
  80118a:	50                   	push   %eax
  80118b:	57                   	push   %edi
  80118c:	6a 00                	push   $0x0
  80118e:	53                   	push   %ebx
  80118f:	6a 00                	push   $0x0
  801191:	e8 0f fb ff ff       	call   800ca5 <sys_page_map>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 20             	add    $0x20,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	79 a3                	jns    801142 <dup+0x78>
	sys_page_unmap(0, newfd);
  80119f:	83 ec 08             	sub    $0x8,%esp
  8011a2:	56                   	push   %esi
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 20 fb ff ff       	call   800cca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011aa:	83 c4 08             	add    $0x8,%esp
  8011ad:	57                   	push   %edi
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 15 fb ff ff       	call   800cca <sys_page_unmap>
	return r;
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	eb b7                	jmp    801171 <dup+0xa7>

008011ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ba:	f3 0f 1e fb          	endbr32 
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 1c             	sub    $0x1c,%esp
  8011c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	53                   	push   %ebx
  8011cd:	e8 60 fd ff ff       	call   800f32 <fd_lookup>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 3f                	js     801218 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e3:	ff 30                	pushl  (%eax)
  8011e5:	e8 9c fd ff ff       	call   800f86 <dev_lookup>
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 27                	js     801218 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011f4:	8b 42 08             	mov    0x8(%edx),%eax
  8011f7:	83 e0 03             	and    $0x3,%eax
  8011fa:	83 f8 01             	cmp    $0x1,%eax
  8011fd:	74 1e                	je     80121d <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801202:	8b 40 08             	mov    0x8(%eax),%eax
  801205:	85 c0                	test   %eax,%eax
  801207:	74 35                	je     80123e <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	ff 75 10             	pushl  0x10(%ebp)
  80120f:	ff 75 0c             	pushl  0xc(%ebp)
  801212:	52                   	push   %edx
  801213:	ff d0                	call   *%eax
  801215:	83 c4 10             	add    $0x10,%esp
}
  801218:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80121d:	a1 08 40 80 00       	mov    0x804008,%eax
  801222:	8b 40 48             	mov    0x48(%eax),%eax
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	53                   	push   %ebx
  801229:	50                   	push   %eax
  80122a:	68 b1 28 80 00       	push   $0x8028b1
  80122f:	e8 d8 ef ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123c:	eb da                	jmp    801218 <read+0x5e>
		return -E_NOT_SUPP;
  80123e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801243:	eb d3                	jmp    801218 <read+0x5e>

00801245 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801245:	f3 0f 1e fb          	endbr32 
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	8b 7d 08             	mov    0x8(%ebp),%edi
  801255:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801258:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125d:	eb 02                	jmp    801261 <readn+0x1c>
  80125f:	01 c3                	add    %eax,%ebx
  801261:	39 f3                	cmp    %esi,%ebx
  801263:	73 21                	jae    801286 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	89 f0                	mov    %esi,%eax
  80126a:	29 d8                	sub    %ebx,%eax
  80126c:	50                   	push   %eax
  80126d:	89 d8                	mov    %ebx,%eax
  80126f:	03 45 0c             	add    0xc(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	57                   	push   %edi
  801274:	e8 41 ff ff ff       	call   8011ba <read>
		if (m < 0)
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	78 04                	js     801284 <readn+0x3f>
			return m;
		if (m == 0)
  801280:	75 dd                	jne    80125f <readn+0x1a>
  801282:	eb 02                	jmp    801286 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801284:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801286:	89 d8                	mov    %ebx,%eax
  801288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801290:	f3 0f 1e fb          	endbr32 
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	53                   	push   %ebx
  801298:	83 ec 1c             	sub    $0x1c,%esp
  80129b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	53                   	push   %ebx
  8012a3:	e8 8a fc ff ff       	call   800f32 <fd_lookup>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 3a                	js     8012e9 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b5:	50                   	push   %eax
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	ff 30                	pushl  (%eax)
  8012bb:	e8 c6 fc ff ff       	call   800f86 <dev_lookup>
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 22                	js     8012e9 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ce:	74 1e                	je     8012ee <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d6:	85 d2                	test   %edx,%edx
  8012d8:	74 35                	je     80130f <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	ff 75 10             	pushl  0x10(%ebp)
  8012e0:	ff 75 0c             	pushl  0xc(%ebp)
  8012e3:	50                   	push   %eax
  8012e4:	ff d2                	call   *%edx
  8012e6:	83 c4 10             	add    $0x10,%esp
}
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8012f3:	8b 40 48             	mov    0x48(%eax),%eax
  8012f6:	83 ec 04             	sub    $0x4,%esp
  8012f9:	53                   	push   %ebx
  8012fa:	50                   	push   %eax
  8012fb:	68 cd 28 80 00       	push   $0x8028cd
  801300:	e8 07 ef ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130d:	eb da                	jmp    8012e9 <write+0x59>
		return -E_NOT_SUPP;
  80130f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801314:	eb d3                	jmp    8012e9 <write+0x59>

00801316 <seek>:

int
seek(int fdnum, off_t offset)
{
  801316:	f3 0f 1e fb          	endbr32 
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 06 fc ff ff       	call   800f32 <fd_lookup>
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 0e                	js     801341 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801333:	8b 55 0c             	mov    0xc(%ebp),%edx
  801336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801339:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80133c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801343:	f3 0f 1e fb          	endbr32 
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	53                   	push   %ebx
  80134b:	83 ec 1c             	sub    $0x1c,%esp
  80134e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801351:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	53                   	push   %ebx
  801356:	e8 d7 fb ff ff       	call   800f32 <fd_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 37                	js     801399 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801368:	50                   	push   %eax
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	ff 30                	pushl  (%eax)
  80136e:	e8 13 fc ff ff       	call   800f86 <dev_lookup>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 1f                	js     801399 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801381:	74 1b                	je     80139e <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801383:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801386:	8b 52 18             	mov    0x18(%edx),%edx
  801389:	85 d2                	test   %edx,%edx
  80138b:	74 32                	je     8013bf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	ff 75 0c             	pushl  0xc(%ebp)
  801393:	50                   	push   %eax
  801394:	ff d2                	call   *%edx
  801396:	83 c4 10             	add    $0x10,%esp
}
  801399:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80139e:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013a3:	8b 40 48             	mov    0x48(%eax),%eax
  8013a6:	83 ec 04             	sub    $0x4,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	50                   	push   %eax
  8013ab:	68 90 28 80 00       	push   $0x802890
  8013b0:	e8 57 ee ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  8013b5:	83 c4 10             	add    $0x10,%esp
  8013b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bd:	eb da                	jmp    801399 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013c4:	eb d3                	jmp    801399 <ftruncate+0x56>

008013c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013c6:	f3 0f 1e fb          	endbr32 
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 1c             	sub    $0x1c,%esp
  8013d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d7:	50                   	push   %eax
  8013d8:	ff 75 08             	pushl  0x8(%ebp)
  8013db:	e8 52 fb ff ff       	call   800f32 <fd_lookup>
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 4b                	js     801432 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f1:	ff 30                	pushl  (%eax)
  8013f3:	e8 8e fb ff ff       	call   800f86 <dev_lookup>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 33                	js     801432 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8013ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801402:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801406:	74 2f                	je     801437 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801408:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80140b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801412:	00 00 00 
	stat->st_isdir = 0;
  801415:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80141c:	00 00 00 
	stat->st_dev = dev;
  80141f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	53                   	push   %ebx
  801429:	ff 75 f0             	pushl  -0x10(%ebp)
  80142c:	ff 50 14             	call   *0x14(%eax)
  80142f:	83 c4 10             	add    $0x10,%esp
}
  801432:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801435:	c9                   	leave  
  801436:	c3                   	ret    
		return -E_NOT_SUPP;
  801437:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80143c:	eb f4                	jmp    801432 <fstat+0x6c>

0080143e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80143e:	f3 0f 1e fb          	endbr32 
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	56                   	push   %esi
  801446:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	6a 00                	push   $0x0
  80144c:	ff 75 08             	pushl  0x8(%ebp)
  80144f:	e8 01 02 00 00       	call   801655 <open>
  801454:	89 c3                	mov    %eax,%ebx
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 1b                	js     801478 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	ff 75 0c             	pushl  0xc(%ebp)
  801463:	50                   	push   %eax
  801464:	e8 5d ff ff ff       	call   8013c6 <fstat>
  801469:	89 c6                	mov    %eax,%esi
	close(fd);
  80146b:	89 1c 24             	mov    %ebx,(%esp)
  80146e:	e8 fd fb ff ff       	call   801070 <close>
	return r;
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	89 f3                	mov    %esi,%ebx
}
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5d                   	pop    %ebp
  801480:	c3                   	ret    

00801481 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
  801486:	89 c6                	mov    %eax,%esi
  801488:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80148a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801491:	74 27                	je     8014ba <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801493:	6a 07                	push   $0x7
  801495:	68 00 50 80 00       	push   $0x805000
  80149a:	56                   	push   %esi
  80149b:	ff 35 00 40 80 00    	pushl  0x804000
  8014a1:	e8 7c 0c 00 00       	call   802122 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014a6:	83 c4 0c             	add    $0xc,%esp
  8014a9:	6a 00                	push   $0x0
  8014ab:	53                   	push   %ebx
  8014ac:	6a 00                	push   $0x0
  8014ae:	e8 02 0c 00 00       	call   8020b5 <ipc_recv>
}
  8014b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ba:	83 ec 0c             	sub    $0xc,%esp
  8014bd:	6a 01                	push   $0x1
  8014bf:	e8 b6 0c 00 00       	call   80217a <ipc_find_env>
  8014c4:	a3 00 40 80 00       	mov    %eax,0x804000
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	eb c5                	jmp    801493 <fsipc+0x12>

008014ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014ce:	f3 0f 1e fb          	endbr32 
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	8b 40 0c             	mov    0xc(%eax),%eax
  8014de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8014f5:	e8 87 ff ff ff       	call   801481 <fsipc>
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <devfile_flush>:
{
  8014fc:	f3 0f 1e fb          	endbr32 
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	8b 40 0c             	mov    0xc(%eax),%eax
  80150c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 06 00 00 00       	mov    $0x6,%eax
  80151b:	e8 61 ff ff ff       	call   801481 <fsipc>
}
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <devfile_stat>:
{
  801522:	f3 0f 1e fb          	endbr32 
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	53                   	push   %ebx
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	8b 40 0c             	mov    0xc(%eax),%eax
  801536:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 05 00 00 00       	mov    $0x5,%eax
  801545:	e8 37 ff ff ff       	call   801481 <fsipc>
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 2c                	js     80157a <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	68 00 50 80 00       	push   $0x805000
  801556:	53                   	push   %ebx
  801557:	e8 ba f2 ff ff       	call   800816 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80155c:	a1 80 50 80 00       	mov    0x805080,%eax
  801561:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801567:	a1 84 50 80 00       	mov    0x805084,%eax
  80156c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <devfile_write>:
{
  80157f:	f3 0f 1e fb          	endbr32 
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	8b 45 10             	mov    0x10(%ebp),%eax
  80158c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801591:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801596:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801599:	8b 55 08             	mov    0x8(%ebp),%edx
  80159c:	8b 52 0c             	mov    0xc(%edx),%edx
  80159f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015a5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015aa:	50                   	push   %eax
  8015ab:	ff 75 0c             	pushl  0xc(%ebp)
  8015ae:	68 08 50 80 00       	push   $0x805008
  8015b3:	e8 5c f4 ff ff       	call   800a14 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8015c2:	e8 ba fe ff ff       	call   801481 <fsipc>
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <devfile_read>:
{
  8015c9:	f3 0f 1e fb          	endbr32 
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015e0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8015f0:	e8 8c fe ff ff       	call   801481 <fsipc>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 1f                	js     80161a <devfile_read+0x51>
	assert(r <= n);
  8015fb:	39 f0                	cmp    %esi,%eax
  8015fd:	77 24                	ja     801623 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801604:	7f 36                	jg     80163c <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801606:	83 ec 04             	sub    $0x4,%esp
  801609:	50                   	push   %eax
  80160a:	68 00 50 80 00       	push   $0x805000
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	e8 fd f3 ff ff       	call   800a14 <memmove>
	return r;
  801617:	83 c4 10             	add    $0x10,%esp
}
  80161a:	89 d8                	mov    %ebx,%eax
  80161c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    
	assert(r <= n);
  801623:	68 00 29 80 00       	push   $0x802900
  801628:	68 07 29 80 00       	push   $0x802907
  80162d:	68 8c 00 00 00       	push   $0x8c
  801632:	68 1c 29 80 00       	push   $0x80291c
  801637:	e8 e9 ea ff ff       	call   800125 <_panic>
	assert(r <= PGSIZE);
  80163c:	68 27 29 80 00       	push   $0x802927
  801641:	68 07 29 80 00       	push   $0x802907
  801646:	68 8d 00 00 00       	push   $0x8d
  80164b:	68 1c 29 80 00       	push   $0x80291c
  801650:	e8 d0 ea ff ff       	call   800125 <_panic>

00801655 <open>:
{
  801655:	f3 0f 1e fb          	endbr32 
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	83 ec 1c             	sub    $0x1c,%esp
  801661:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801664:	56                   	push   %esi
  801665:	e8 69 f1 ff ff       	call   8007d3 <strlen>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801672:	7f 6c                	jg     8016e0 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801674:	83 ec 0c             	sub    $0xc,%esp
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	e8 5c f8 ff ff       	call   800edc <fd_alloc>
  801680:	89 c3                	mov    %eax,%ebx
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	85 c0                	test   %eax,%eax
  801687:	78 3c                	js     8016c5 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	56                   	push   %esi
  80168d:	68 00 50 80 00       	push   $0x805000
  801692:	e8 7f f1 ff ff       	call   800816 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80169f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8016a7:	e8 d5 fd ff ff       	call   801481 <fsipc>
  8016ac:	89 c3                	mov    %eax,%ebx
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 19                	js     8016ce <open+0x79>
	return fd2num(fd);
  8016b5:	83 ec 0c             	sub    $0xc,%esp
  8016b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8016bb:	e8 ed f7 ff ff       	call   800ead <fd2num>
  8016c0:	89 c3                	mov    %eax,%ebx
  8016c2:	83 c4 10             	add    $0x10,%esp
}
  8016c5:	89 d8                	mov    %ebx,%eax
  8016c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ca:	5b                   	pop    %ebx
  8016cb:	5e                   	pop    %esi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    
		fd_close(fd, 0);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	6a 00                	push   $0x0
  8016d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d6:	e8 0a f9 ff ff       	call   800fe5 <fd_close>
		return r;
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	eb e5                	jmp    8016c5 <open+0x70>
		return -E_BAD_PATH;
  8016e0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016e5:	eb de                	jmp    8016c5 <open+0x70>

008016e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016e7:	f3 0f 1e fb          	endbr32 
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8016fb:	e8 81 fd ff ff       	call   801481 <fsipc>
}
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801702:	f3 0f 1e fb          	endbr32 
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80170c:	68 93 29 80 00       	push   $0x802993
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	e8 fd f0 ff ff       	call   800816 <strcpy>
	return 0;
}
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <devsock_close>:
{
  801720:	f3 0f 1e fb          	endbr32 
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	83 ec 10             	sub    $0x10,%esp
  80172b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80172e:	53                   	push   %ebx
  80172f:	e8 83 0a 00 00       	call   8021b7 <pageref>
  801734:	89 c2                	mov    %eax,%edx
  801736:	83 c4 10             	add    $0x10,%esp
		return 0;
  801739:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80173e:	83 fa 01             	cmp    $0x1,%edx
  801741:	74 05                	je     801748 <devsock_close+0x28>
}
  801743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801746:	c9                   	leave  
  801747:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801748:	83 ec 0c             	sub    $0xc,%esp
  80174b:	ff 73 0c             	pushl  0xc(%ebx)
  80174e:	e8 e3 02 00 00       	call   801a36 <nsipc_close>
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	eb eb                	jmp    801743 <devsock_close+0x23>

00801758 <devsock_write>:
{
  801758:	f3 0f 1e fb          	endbr32 
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801762:	6a 00                	push   $0x0
  801764:	ff 75 10             	pushl  0x10(%ebp)
  801767:	ff 75 0c             	pushl  0xc(%ebp)
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	ff 70 0c             	pushl  0xc(%eax)
  801770:	e8 b5 03 00 00       	call   801b2a <nsipc_send>
}
  801775:	c9                   	leave  
  801776:	c3                   	ret    

00801777 <devsock_read>:
{
  801777:	f3 0f 1e fb          	endbr32 
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801781:	6a 00                	push   $0x0
  801783:	ff 75 10             	pushl  0x10(%ebp)
  801786:	ff 75 0c             	pushl  0xc(%ebp)
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	ff 70 0c             	pushl  0xc(%eax)
  80178f:	e8 1f 03 00 00       	call   801ab3 <nsipc_recv>
}
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <fd2sockid>:
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80179c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80179f:	52                   	push   %edx
  8017a0:	50                   	push   %eax
  8017a1:	e8 8c f7 ff ff       	call   800f32 <fd_lookup>
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 10                	js     8017bd <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8017ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b0:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  8017b6:	39 08                	cmp    %ecx,(%eax)
  8017b8:	75 05                	jne    8017bf <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8017ba:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    
		return -E_NOT_SUPP;
  8017bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017c4:	eb f7                	jmp    8017bd <fd2sockid+0x27>

008017c6 <alloc_sockfd>:
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 1c             	sub    $0x1c,%esp
  8017ce:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8017d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	e8 03 f7 ff ff       	call   800edc <fd_alloc>
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 43                	js     801825 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	68 07 04 00 00       	push   $0x407
  8017ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ed:	6a 00                	push   $0x0
  8017ef:	e8 8b f4 ff ff       	call   800c7f <sys_page_alloc>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 28                	js     801825 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801806:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801812:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	50                   	push   %eax
  801819:	e8 8f f6 ff ff       	call   800ead <fd2num>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	eb 0c                	jmp    801831 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801825:	83 ec 0c             	sub    $0xc,%esp
  801828:	56                   	push   %esi
  801829:	e8 08 02 00 00       	call   801a36 <nsipc_close>
		return r;
  80182e:	83 c4 10             	add    $0x10,%esp
}
  801831:	89 d8                	mov    %ebx,%eax
  801833:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <accept>:
{
  80183a:	f3 0f 1e fb          	endbr32 
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	e8 4a ff ff ff       	call   801796 <fd2sockid>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 1b                	js     80186b <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	ff 75 10             	pushl  0x10(%ebp)
  801856:	ff 75 0c             	pushl  0xc(%ebp)
  801859:	50                   	push   %eax
  80185a:	e8 22 01 00 00       	call   801981 <nsipc_accept>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	78 05                	js     80186b <accept+0x31>
	return alloc_sockfd(r);
  801866:	e8 5b ff ff ff       	call   8017c6 <alloc_sockfd>
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <bind>:
{
  80186d:	f3 0f 1e fb          	endbr32 
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	e8 17 ff ff ff       	call   801796 <fd2sockid>
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 12                	js     801895 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801883:	83 ec 04             	sub    $0x4,%esp
  801886:	ff 75 10             	pushl  0x10(%ebp)
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	50                   	push   %eax
  80188d:	e8 45 01 00 00       	call   8019d7 <nsipc_bind>
  801892:	83 c4 10             	add    $0x10,%esp
}
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <shutdown>:
{
  801897:	f3 0f 1e fb          	endbr32 
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a4:	e8 ed fe ff ff       	call   801796 <fd2sockid>
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	78 0f                	js     8018bc <shutdown+0x25>
	return nsipc_shutdown(r, how);
  8018ad:	83 ec 08             	sub    $0x8,%esp
  8018b0:	ff 75 0c             	pushl  0xc(%ebp)
  8018b3:	50                   	push   %eax
  8018b4:	e8 57 01 00 00       	call   801a10 <nsipc_shutdown>
  8018b9:	83 c4 10             	add    $0x10,%esp
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <connect>:
{
  8018be:	f3 0f 1e fb          	endbr32 
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cb:	e8 c6 fe ff ff       	call   801796 <fd2sockid>
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 12                	js     8018e6 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8018d4:	83 ec 04             	sub    $0x4,%esp
  8018d7:	ff 75 10             	pushl  0x10(%ebp)
  8018da:	ff 75 0c             	pushl  0xc(%ebp)
  8018dd:	50                   	push   %eax
  8018de:	e8 71 01 00 00       	call   801a54 <nsipc_connect>
  8018e3:	83 c4 10             	add    $0x10,%esp
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <listen>:
{
  8018e8:	f3 0f 1e fb          	endbr32 
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	e8 9c fe ff ff       	call   801796 <fd2sockid>
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 0f                	js     80190d <listen+0x25>
	return nsipc_listen(r, backlog);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	ff 75 0c             	pushl  0xc(%ebp)
  801904:	50                   	push   %eax
  801905:	e8 83 01 00 00       	call   801a8d <nsipc_listen>
  80190a:	83 c4 10             	add    $0x10,%esp
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <socket>:

int
socket(int domain, int type, int protocol)
{
  80190f:	f3 0f 1e fb          	endbr32 
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801919:	ff 75 10             	pushl  0x10(%ebp)
  80191c:	ff 75 0c             	pushl  0xc(%ebp)
  80191f:	ff 75 08             	pushl  0x8(%ebp)
  801922:	e8 65 02 00 00       	call   801b8c <nsipc_socket>
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	85 c0                	test   %eax,%eax
  80192c:	78 05                	js     801933 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  80192e:	e8 93 fe ff ff       	call   8017c6 <alloc_sockfd>
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	53                   	push   %ebx
  801939:	83 ec 04             	sub    $0x4,%esp
  80193c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80193e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801945:	74 26                	je     80196d <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801947:	6a 07                	push   $0x7
  801949:	68 00 60 80 00       	push   $0x806000
  80194e:	53                   	push   %ebx
  80194f:	ff 35 04 40 80 00    	pushl  0x804004
  801955:	e8 c8 07 00 00       	call   802122 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80195a:	83 c4 0c             	add    $0xc,%esp
  80195d:	6a 00                	push   $0x0
  80195f:	6a 00                	push   $0x0
  801961:	6a 00                	push   $0x0
  801963:	e8 4d 07 00 00       	call   8020b5 <ipc_recv>
}
  801968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	6a 02                	push   $0x2
  801972:	e8 03 08 00 00       	call   80217a <ipc_find_env>
  801977:	a3 04 40 80 00       	mov    %eax,0x804004
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	eb c6                	jmp    801947 <nsipc+0x12>

00801981 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801981:	f3 0f 1e fb          	endbr32 
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
  80198a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801995:	8b 06                	mov    (%esi),%eax
  801997:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80199c:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a1:	e8 8f ff ff ff       	call   801935 <nsipc>
  8019a6:	89 c3                	mov    %eax,%ebx
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	79 09                	jns    8019b5 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8019ac:	89 d8                	mov    %ebx,%eax
  8019ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019b5:	83 ec 04             	sub    $0x4,%esp
  8019b8:	ff 35 10 60 80 00    	pushl  0x806010
  8019be:	68 00 60 80 00       	push   $0x806000
  8019c3:	ff 75 0c             	pushl  0xc(%ebp)
  8019c6:	e8 49 f0 ff ff       	call   800a14 <memmove>
		*addrlen = ret->ret_addrlen;
  8019cb:	a1 10 60 80 00       	mov    0x806010,%eax
  8019d0:	89 06                	mov    %eax,(%esi)
  8019d2:	83 c4 10             	add    $0x10,%esp
	return r;
  8019d5:	eb d5                	jmp    8019ac <nsipc_accept+0x2b>

008019d7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019d7:	f3 0f 1e fb          	endbr32 
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	53                   	push   %ebx
  8019df:	83 ec 08             	sub    $0x8,%esp
  8019e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019ed:	53                   	push   %ebx
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	68 04 60 80 00       	push   $0x806004
  8019f6:	e8 19 f0 ff ff       	call   800a14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019fb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a01:	b8 02 00 00 00       	mov    $0x2,%eax
  801a06:	e8 2a ff ff ff       	call   801935 <nsipc>
}
  801a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a10:	f3 0f 1e fb          	endbr32 
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a25:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a2a:	b8 03 00 00 00       	mov    $0x3,%eax
  801a2f:	e8 01 ff ff ff       	call   801935 <nsipc>
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <nsipc_close>:

int
nsipc_close(int s)
{
  801a36:	f3 0f 1e fb          	endbr32 
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a48:	b8 04 00 00 00       	mov    $0x4,%eax
  801a4d:	e8 e3 fe ff ff       	call   801935 <nsipc>
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a54:	f3 0f 1e fb          	endbr32 
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a62:	8b 45 08             	mov    0x8(%ebp),%eax
  801a65:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a6a:	53                   	push   %ebx
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	68 04 60 80 00       	push   $0x806004
  801a73:	e8 9c ef ff ff       	call   800a14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a78:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a7e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a83:	e8 ad fe ff ff       	call   801935 <nsipc>
}
  801a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a8d:	f3 0f 1e fb          	endbr32 
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801aa7:	b8 06 00 00 00       	mov    $0x6,%eax
  801aac:	e8 84 fe ff ff       	call   801935 <nsipc>
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ab3:	f3 0f 1e fb          	endbr32 
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801abf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ac7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801acd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ad5:	b8 07 00 00 00       	mov    $0x7,%eax
  801ada:	e8 56 fe ff ff       	call   801935 <nsipc>
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	78 26                	js     801b0b <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801ae5:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801aeb:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801af0:	0f 4e c6             	cmovle %esi,%eax
  801af3:	39 c3                	cmp    %eax,%ebx
  801af5:	7f 1d                	jg     801b14 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	53                   	push   %ebx
  801afb:	68 00 60 80 00       	push   $0x806000
  801b00:	ff 75 0c             	pushl  0xc(%ebp)
  801b03:	e8 0c ef ff ff       	call   800a14 <memmove>
  801b08:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b0b:	89 d8                	mov    %ebx,%eax
  801b0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801b14:	68 9f 29 80 00       	push   $0x80299f
  801b19:	68 07 29 80 00       	push   $0x802907
  801b1e:	6a 62                	push   $0x62
  801b20:	68 b4 29 80 00       	push   $0x8029b4
  801b25:	e8 fb e5 ff ff       	call   800125 <_panic>

00801b2a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b2a:	f3 0f 1e fb          	endbr32 
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	53                   	push   %ebx
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b40:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b46:	7f 2e                	jg     801b76 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b48:	83 ec 04             	sub    $0x4,%esp
  801b4b:	53                   	push   %ebx
  801b4c:	ff 75 0c             	pushl  0xc(%ebp)
  801b4f:	68 0c 60 80 00       	push   $0x80600c
  801b54:	e8 bb ee ff ff       	call   800a14 <memmove>
	nsipcbuf.send.req_size = size;
  801b59:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b62:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b67:	b8 08 00 00 00       	mov    $0x8,%eax
  801b6c:	e8 c4 fd ff ff       	call   801935 <nsipc>
}
  801b71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    
	assert(size < 1600);
  801b76:	68 c0 29 80 00       	push   $0x8029c0
  801b7b:	68 07 29 80 00       	push   $0x802907
  801b80:	6a 6d                	push   $0x6d
  801b82:	68 b4 29 80 00       	push   $0x8029b4
  801b87:	e8 99 e5 ff ff       	call   800125 <_panic>

00801b8c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b8c:	f3 0f 1e fb          	endbr32 
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ba6:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801bae:	b8 09 00 00 00       	mov    $0x9,%eax
  801bb3:	e8 7d fd ff ff       	call   801935 <nsipc>
}
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bba:	f3 0f 1e fb          	endbr32 
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 75 08             	pushl  0x8(%ebp)
  801bcc:	e8 f0 f2 ff ff       	call   800ec1 <fd2data>
  801bd1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bd3:	83 c4 08             	add    $0x8,%esp
  801bd6:	68 cc 29 80 00       	push   $0x8029cc
  801bdb:	53                   	push   %ebx
  801bdc:	e8 35 ec ff ff       	call   800816 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801be1:	8b 46 04             	mov    0x4(%esi),%eax
  801be4:	2b 06                	sub    (%esi),%eax
  801be6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bf3:	00 00 00 
	stat->st_dev = &devpipe;
  801bf6:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801bfd:	30 80 00 
	return 0;
}
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
  801c05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5e                   	pop    %esi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c0c:	f3 0f 1e fb          	endbr32 
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	53                   	push   %ebx
  801c14:	83 ec 0c             	sub    $0xc,%esp
  801c17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c1a:	53                   	push   %ebx
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 a8 f0 ff ff       	call   800cca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c22:	89 1c 24             	mov    %ebx,(%esp)
  801c25:	e8 97 f2 ff ff       	call   800ec1 <fd2data>
  801c2a:	83 c4 08             	add    $0x8,%esp
  801c2d:	50                   	push   %eax
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 95 f0 ff ff       	call   800cca <sys_page_unmap>
}
  801c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <_pipeisclosed>:
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	57                   	push   %edi
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 1c             	sub    $0x1c,%esp
  801c43:	89 c7                	mov    %eax,%edi
  801c45:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c47:	a1 08 40 80 00       	mov    0x804008,%eax
  801c4c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	57                   	push   %edi
  801c53:	e8 5f 05 00 00       	call   8021b7 <pageref>
  801c58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c5b:	89 34 24             	mov    %esi,(%esp)
  801c5e:	e8 54 05 00 00       	call   8021b7 <pageref>
		nn = thisenv->env_runs;
  801c63:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c69:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	39 cb                	cmp    %ecx,%ebx
  801c71:	74 1b                	je     801c8e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c73:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c76:	75 cf                	jne    801c47 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c78:	8b 42 58             	mov    0x58(%edx),%eax
  801c7b:	6a 01                	push   $0x1
  801c7d:	50                   	push   %eax
  801c7e:	53                   	push   %ebx
  801c7f:	68 d3 29 80 00       	push   $0x8029d3
  801c84:	e8 83 e5 ff ff       	call   80020c <cprintf>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	eb b9                	jmp    801c47 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c8e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c91:	0f 94 c0             	sete   %al
  801c94:	0f b6 c0             	movzbl %al,%eax
}
  801c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5f                   	pop    %edi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <devpipe_write>:
{
  801c9f:	f3 0f 1e fb          	endbr32 
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	57                   	push   %edi
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	83 ec 28             	sub    $0x28,%esp
  801cac:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801caf:	56                   	push   %esi
  801cb0:	e8 0c f2 ff ff       	call   800ec1 <fd2data>
  801cb5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	bf 00 00 00 00       	mov    $0x0,%edi
  801cbf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cc2:	74 4f                	je     801d13 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cc4:	8b 43 04             	mov    0x4(%ebx),%eax
  801cc7:	8b 0b                	mov    (%ebx),%ecx
  801cc9:	8d 51 20             	lea    0x20(%ecx),%edx
  801ccc:	39 d0                	cmp    %edx,%eax
  801cce:	72 14                	jb     801ce4 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801cd0:	89 da                	mov    %ebx,%edx
  801cd2:	89 f0                	mov    %esi,%eax
  801cd4:	e8 61 ff ff ff       	call   801c3a <_pipeisclosed>
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	75 3b                	jne    801d18 <devpipe_write+0x79>
			sys_yield();
  801cdd:	e8 7a ef ff ff       	call   800c5c <sys_yield>
  801ce2:	eb e0                	jmp    801cc4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ceb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cee:	89 c2                	mov    %eax,%edx
  801cf0:	c1 fa 1f             	sar    $0x1f,%edx
  801cf3:	89 d1                	mov    %edx,%ecx
  801cf5:	c1 e9 1b             	shr    $0x1b,%ecx
  801cf8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cfb:	83 e2 1f             	and    $0x1f,%edx
  801cfe:	29 ca                	sub    %ecx,%edx
  801d00:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d04:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d08:	83 c0 01             	add    $0x1,%eax
  801d0b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d0e:	83 c7 01             	add    $0x1,%edi
  801d11:	eb ac                	jmp    801cbf <devpipe_write+0x20>
	return i;
  801d13:	8b 45 10             	mov    0x10(%ebp),%eax
  801d16:	eb 05                	jmp    801d1d <devpipe_write+0x7e>
				return 0;
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <devpipe_read>:
{
  801d25:	f3 0f 1e fb          	endbr32 
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	57                   	push   %edi
  801d2d:	56                   	push   %esi
  801d2e:	53                   	push   %ebx
  801d2f:	83 ec 18             	sub    $0x18,%esp
  801d32:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d35:	57                   	push   %edi
  801d36:	e8 86 f1 ff ff       	call   800ec1 <fd2data>
  801d3b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d3d:	83 c4 10             	add    $0x10,%esp
  801d40:	be 00 00 00 00       	mov    $0x0,%esi
  801d45:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d48:	75 14                	jne    801d5e <devpipe_read+0x39>
	return i;
  801d4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4d:	eb 02                	jmp    801d51 <devpipe_read+0x2c>
				return i;
  801d4f:	89 f0                	mov    %esi,%eax
}
  801d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
			sys_yield();
  801d59:	e8 fe ee ff ff       	call   800c5c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d5e:	8b 03                	mov    (%ebx),%eax
  801d60:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d63:	75 18                	jne    801d7d <devpipe_read+0x58>
			if (i > 0)
  801d65:	85 f6                	test   %esi,%esi
  801d67:	75 e6                	jne    801d4f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d69:	89 da                	mov    %ebx,%edx
  801d6b:	89 f8                	mov    %edi,%eax
  801d6d:	e8 c8 fe ff ff       	call   801c3a <_pipeisclosed>
  801d72:	85 c0                	test   %eax,%eax
  801d74:	74 e3                	je     801d59 <devpipe_read+0x34>
				return 0;
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7b:	eb d4                	jmp    801d51 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d7d:	99                   	cltd   
  801d7e:	c1 ea 1b             	shr    $0x1b,%edx
  801d81:	01 d0                	add    %edx,%eax
  801d83:	83 e0 1f             	and    $0x1f,%eax
  801d86:	29 d0                	sub    %edx,%eax
  801d88:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d90:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d93:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d96:	83 c6 01             	add    $0x1,%esi
  801d99:	eb aa                	jmp    801d45 <devpipe_read+0x20>

00801d9b <pipe>:
{
  801d9b:	f3 0f 1e fb          	endbr32 
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801da7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	e8 2c f1 ff ff       	call   800edc <fd_alloc>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	85 c0                	test   %eax,%eax
  801db7:	0f 88 23 01 00 00    	js     801ee0 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbd:	83 ec 04             	sub    $0x4,%esp
  801dc0:	68 07 04 00 00       	push   $0x407
  801dc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 b0 ee ff ff       	call   800c7f <sys_page_alloc>
  801dcf:	89 c3                	mov    %eax,%ebx
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	0f 88 04 01 00 00    	js     801ee0 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801ddc:	83 ec 0c             	sub    $0xc,%esp
  801ddf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de2:	50                   	push   %eax
  801de3:	e8 f4 f0 ff ff       	call   800edc <fd_alloc>
  801de8:	89 c3                	mov    %eax,%ebx
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	85 c0                	test   %eax,%eax
  801def:	0f 88 db 00 00 00    	js     801ed0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df5:	83 ec 04             	sub    $0x4,%esp
  801df8:	68 07 04 00 00       	push   $0x407
  801dfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801e00:	6a 00                	push   $0x0
  801e02:	e8 78 ee ff ff       	call   800c7f <sys_page_alloc>
  801e07:	89 c3                	mov    %eax,%ebx
  801e09:	83 c4 10             	add    $0x10,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	0f 88 bc 00 00 00    	js     801ed0 <pipe+0x135>
	va = fd2data(fd0);
  801e14:	83 ec 0c             	sub    $0xc,%esp
  801e17:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1a:	e8 a2 f0 ff ff       	call   800ec1 <fd2data>
  801e1f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e21:	83 c4 0c             	add    $0xc,%esp
  801e24:	68 07 04 00 00       	push   $0x407
  801e29:	50                   	push   %eax
  801e2a:	6a 00                	push   $0x0
  801e2c:	e8 4e ee ff ff       	call   800c7f <sys_page_alloc>
  801e31:	89 c3                	mov    %eax,%ebx
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	85 c0                	test   %eax,%eax
  801e38:	0f 88 82 00 00 00    	js     801ec0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3e:	83 ec 0c             	sub    $0xc,%esp
  801e41:	ff 75 f0             	pushl  -0x10(%ebp)
  801e44:	e8 78 f0 ff ff       	call   800ec1 <fd2data>
  801e49:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e50:	50                   	push   %eax
  801e51:	6a 00                	push   $0x0
  801e53:	56                   	push   %esi
  801e54:	6a 00                	push   $0x0
  801e56:	e8 4a ee ff ff       	call   800ca5 <sys_page_map>
  801e5b:	89 c3                	mov    %eax,%ebx
  801e5d:	83 c4 20             	add    $0x20,%esp
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 4e                	js     801eb2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e64:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801e69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e6c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e71:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e7b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e87:	83 ec 0c             	sub    $0xc,%esp
  801e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8d:	e8 1b f0 ff ff       	call   800ead <fd2num>
  801e92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e95:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e97:	83 c4 04             	add    $0x4,%esp
  801e9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9d:	e8 0b f0 ff ff       	call   800ead <fd2num>
  801ea2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eb0:	eb 2e                	jmp    801ee0 <pipe+0x145>
	sys_page_unmap(0, va);
  801eb2:	83 ec 08             	sub    $0x8,%esp
  801eb5:	56                   	push   %esi
  801eb6:	6a 00                	push   $0x0
  801eb8:	e8 0d ee ff ff       	call   800cca <sys_page_unmap>
  801ebd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ec0:	83 ec 08             	sub    $0x8,%esp
  801ec3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 fd ed ff ff       	call   800cca <sys_page_unmap>
  801ecd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ed0:	83 ec 08             	sub    $0x8,%esp
  801ed3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 ed ed ff ff       	call   800cca <sys_page_unmap>
  801edd:	83 c4 10             	add    $0x10,%esp
}
  801ee0:	89 d8                	mov    %ebx,%eax
  801ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <pipeisclosed>:
{
  801ee9:	f3 0f 1e fb          	endbr32 
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef6:	50                   	push   %eax
  801ef7:	ff 75 08             	pushl  0x8(%ebp)
  801efa:	e8 33 f0 ff ff       	call   800f32 <fd_lookup>
  801eff:	83 c4 10             	add    $0x10,%esp
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 18                	js     801f1e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f06:	83 ec 0c             	sub    $0xc,%esp
  801f09:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0c:	e8 b0 ef ff ff       	call   800ec1 <fd2data>
  801f11:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f16:	e8 1f fd ff ff       	call   801c3a <_pipeisclosed>
  801f1b:	83 c4 10             	add    $0x10,%esp
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f20:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
  801f29:	c3                   	ret    

00801f2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f2a:	f3 0f 1e fb          	endbr32 
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f34:	68 eb 29 80 00       	push   $0x8029eb
  801f39:	ff 75 0c             	pushl  0xc(%ebp)
  801f3c:	e8 d5 e8 ff ff       	call   800816 <strcpy>
	return 0;
}
  801f41:	b8 00 00 00 00       	mov    $0x0,%eax
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    

00801f48 <devcons_write>:
{
  801f48:	f3 0f 1e fb          	endbr32 
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	57                   	push   %edi
  801f50:	56                   	push   %esi
  801f51:	53                   	push   %ebx
  801f52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f58:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f63:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f66:	73 31                	jae    801f99 <devcons_write+0x51>
		m = n - tot;
  801f68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f6b:	29 f3                	sub    %esi,%ebx
  801f6d:	83 fb 7f             	cmp    $0x7f,%ebx
  801f70:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f75:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f78:	83 ec 04             	sub    $0x4,%esp
  801f7b:	53                   	push   %ebx
  801f7c:	89 f0                	mov    %esi,%eax
  801f7e:	03 45 0c             	add    0xc(%ebp),%eax
  801f81:	50                   	push   %eax
  801f82:	57                   	push   %edi
  801f83:	e8 8c ea ff ff       	call   800a14 <memmove>
		sys_cputs(buf, m);
  801f88:	83 c4 08             	add    $0x8,%esp
  801f8b:	53                   	push   %ebx
  801f8c:	57                   	push   %edi
  801f8d:	e8 3e ec ff ff       	call   800bd0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f92:	01 de                	add    %ebx,%esi
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	eb ca                	jmp    801f63 <devcons_write+0x1b>
}
  801f99:	89 f0                	mov    %esi,%eax
  801f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9e:	5b                   	pop    %ebx
  801f9f:	5e                   	pop    %esi
  801fa0:	5f                   	pop    %edi
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    

00801fa3 <devcons_read>:
{
  801fa3:	f3 0f 1e fb          	endbr32 
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	83 ec 08             	sub    $0x8,%esp
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb6:	74 21                	je     801fd9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801fb8:	e8 35 ec ff ff       	call   800bf2 <sys_cgetc>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	75 07                	jne    801fc8 <devcons_read+0x25>
		sys_yield();
  801fc1:	e8 96 ec ff ff       	call   800c5c <sys_yield>
  801fc6:	eb f0                	jmp    801fb8 <devcons_read+0x15>
	if (c < 0)
  801fc8:	78 0f                	js     801fd9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801fca:	83 f8 04             	cmp    $0x4,%eax
  801fcd:	74 0c                	je     801fdb <devcons_read+0x38>
	*(char*)vbuf = c;
  801fcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd2:	88 02                	mov    %al,(%edx)
	return 1;
  801fd4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    
		return 0;
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe0:	eb f7                	jmp    801fd9 <devcons_read+0x36>

00801fe2 <cputchar>:
{
  801fe2:	f3 0f 1e fb          	endbr32 
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fec:	8b 45 08             	mov    0x8(%ebp),%eax
  801fef:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ff2:	6a 01                	push   $0x1
  801ff4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff7:	50                   	push   %eax
  801ff8:	e8 d3 eb ff ff       	call   800bd0 <sys_cputs>
}
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	c9                   	leave  
  802001:	c3                   	ret    

00802002 <getchar>:
{
  802002:	f3 0f 1e fb          	endbr32 
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80200c:	6a 01                	push   $0x1
  80200e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802011:	50                   	push   %eax
  802012:	6a 00                	push   $0x0
  802014:	e8 a1 f1 ff ff       	call   8011ba <read>
	if (r < 0)
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	85 c0                	test   %eax,%eax
  80201e:	78 06                	js     802026 <getchar+0x24>
	if (r < 1)
  802020:	74 06                	je     802028 <getchar+0x26>
	return c;
  802022:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802026:	c9                   	leave  
  802027:	c3                   	ret    
		return -E_EOF;
  802028:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80202d:	eb f7                	jmp    802026 <getchar+0x24>

0080202f <iscons>:
{
  80202f:	f3 0f 1e fb          	endbr32 
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203c:	50                   	push   %eax
  80203d:	ff 75 08             	pushl  0x8(%ebp)
  802040:	e8 ed ee ff ff       	call   800f32 <fd_lookup>
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	85 c0                	test   %eax,%eax
  80204a:	78 11                	js     80205d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80204c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204f:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802055:	39 10                	cmp    %edx,(%eax)
  802057:	0f 94 c0             	sete   %al
  80205a:	0f b6 c0             	movzbl %al,%eax
}
  80205d:	c9                   	leave  
  80205e:	c3                   	ret    

0080205f <opencons>:
{
  80205f:	f3 0f 1e fb          	endbr32 
  802063:	55                   	push   %ebp
  802064:	89 e5                	mov    %esp,%ebp
  802066:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802069:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206c:	50                   	push   %eax
  80206d:	e8 6a ee ff ff       	call   800edc <fd_alloc>
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	85 c0                	test   %eax,%eax
  802077:	78 3a                	js     8020b3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802079:	83 ec 04             	sub    $0x4,%esp
  80207c:	68 07 04 00 00       	push   $0x407
  802081:	ff 75 f4             	pushl  -0xc(%ebp)
  802084:	6a 00                	push   $0x0
  802086:	e8 f4 eb ff ff       	call   800c7f <sys_page_alloc>
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	85 c0                	test   %eax,%eax
  802090:	78 21                	js     8020b3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802095:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80209b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80209d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020a7:	83 ec 0c             	sub    $0xc,%esp
  8020aa:	50                   	push   %eax
  8020ab:	e8 fd ed ff ff       	call   800ead <fd2num>
  8020b0:	83 c4 10             	add    $0x10,%esp
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b5:	f3 0f 1e fb          	endbr32 
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	8b 75 08             	mov    0x8(%ebp),%esi
  8020c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020ce:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	50                   	push   %eax
  8020d5:	e8 ab ec ff ff       	call   800d85 <sys_ipc_recv>
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	75 2b                	jne    80210c <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8020e1:	85 f6                	test   %esi,%esi
  8020e3:	74 0a                	je     8020ef <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8020e5:	a1 08 40 80 00       	mov    0x804008,%eax
  8020ea:	8b 40 74             	mov    0x74(%eax),%eax
  8020ed:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8020ef:	85 db                	test   %ebx,%ebx
  8020f1:	74 0a                	je     8020fd <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8020f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8020f8:	8b 40 78             	mov    0x78(%eax),%eax
  8020fb:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8020fd:	a1 08 40 80 00       	mov    0x804008,%eax
  802102:	8b 40 70             	mov    0x70(%eax),%eax
}
  802105:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802108:	5b                   	pop    %ebx
  802109:	5e                   	pop    %esi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80210c:	85 f6                	test   %esi,%esi
  80210e:	74 06                	je     802116 <ipc_recv+0x61>
  802110:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802116:	85 db                	test   %ebx,%ebx
  802118:	74 eb                	je     802105 <ipc_recv+0x50>
  80211a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802120:	eb e3                	jmp    802105 <ipc_recv+0x50>

00802122 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802122:	f3 0f 1e fb          	endbr32 
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	57                   	push   %edi
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	83 ec 0c             	sub    $0xc,%esp
  80212f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802132:	8b 75 0c             	mov    0xc(%ebp),%esi
  802135:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802138:	85 db                	test   %ebx,%ebx
  80213a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80213f:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802142:	ff 75 14             	pushl  0x14(%ebp)
  802145:	53                   	push   %ebx
  802146:	56                   	push   %esi
  802147:	57                   	push   %edi
  802148:	e8 11 ec ff ff       	call   800d5e <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802153:	75 07                	jne    80215c <ipc_send+0x3a>
			sys_yield();
  802155:	e8 02 eb ff ff       	call   800c5c <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80215a:	eb e6                	jmp    802142 <ipc_send+0x20>
		}
		else if (ret == 0)
  80215c:	85 c0                	test   %eax,%eax
  80215e:	75 08                	jne    802168 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802168:	50                   	push   %eax
  802169:	68 f7 29 80 00       	push   $0x8029f7
  80216e:	6a 48                	push   $0x48
  802170:	68 05 2a 80 00       	push   $0x802a05
  802175:	e8 ab df ff ff       	call   800125 <_panic>

0080217a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80217a:	f3 0f 1e fb          	endbr32 
  80217e:	55                   	push   %ebp
  80217f:	89 e5                	mov    %esp,%ebp
  802181:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802184:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802189:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80218c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802192:	8b 52 50             	mov    0x50(%edx),%edx
  802195:	39 ca                	cmp    %ecx,%edx
  802197:	74 11                	je     8021aa <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802199:	83 c0 01             	add    $0x1,%eax
  80219c:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a1:	75 e6                	jne    802189 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8021a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a8:	eb 0b                	jmp    8021b5 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8021aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021b2:	8b 40 48             	mov    0x48(%eax),%eax
}
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    

008021b7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b7:	f3 0f 1e fb          	endbr32 
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c1:	89 c2                	mov    %eax,%edx
  8021c3:	c1 ea 16             	shr    $0x16,%edx
  8021c6:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021cd:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021d2:	f6 c1 01             	test   $0x1,%cl
  8021d5:	74 1c                	je     8021f3 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8021d7:	c1 e8 0c             	shr    $0xc,%eax
  8021da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021e1:	a8 01                	test   $0x1,%al
  8021e3:	74 0e                	je     8021f3 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021e5:	c1 e8 0c             	shr    $0xc,%eax
  8021e8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021ef:	ef 
  8021f0:	0f b7 d2             	movzwl %dx,%edx
}
  8021f3:	89 d0                	mov    %edx,%eax
  8021f5:	5d                   	pop    %ebp
  8021f6:	c3                   	ret    
  8021f7:	66 90                	xchg   %ax,%ax
  8021f9:	66 90                	xchg   %ax,%ax
  8021fb:	66 90                	xchg   %ax,%ax
  8021fd:	66 90                	xchg   %ax,%ax
  8021ff:	90                   	nop

00802200 <__udivdi3>:
  802200:	f3 0f 1e fb          	endbr32 
  802204:	55                   	push   %ebp
  802205:	57                   	push   %edi
  802206:	56                   	push   %esi
  802207:	53                   	push   %ebx
  802208:	83 ec 1c             	sub    $0x1c,%esp
  80220b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802213:	8b 74 24 34          	mov    0x34(%esp),%esi
  802217:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80221b:	85 d2                	test   %edx,%edx
  80221d:	75 19                	jne    802238 <__udivdi3+0x38>
  80221f:	39 f3                	cmp    %esi,%ebx
  802221:	76 4d                	jbe    802270 <__udivdi3+0x70>
  802223:	31 ff                	xor    %edi,%edi
  802225:	89 e8                	mov    %ebp,%eax
  802227:	89 f2                	mov    %esi,%edx
  802229:	f7 f3                	div    %ebx
  80222b:	89 fa                	mov    %edi,%edx
  80222d:	83 c4 1c             	add    $0x1c,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	8d 76 00             	lea    0x0(%esi),%esi
  802238:	39 f2                	cmp    %esi,%edx
  80223a:	76 14                	jbe    802250 <__udivdi3+0x50>
  80223c:	31 ff                	xor    %edi,%edi
  80223e:	31 c0                	xor    %eax,%eax
  802240:	89 fa                	mov    %edi,%edx
  802242:	83 c4 1c             	add    $0x1c,%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5f                   	pop    %edi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    
  80224a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802250:	0f bd fa             	bsr    %edx,%edi
  802253:	83 f7 1f             	xor    $0x1f,%edi
  802256:	75 48                	jne    8022a0 <__udivdi3+0xa0>
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	72 06                	jb     802262 <__udivdi3+0x62>
  80225c:	31 c0                	xor    %eax,%eax
  80225e:	39 eb                	cmp    %ebp,%ebx
  802260:	77 de                	ja     802240 <__udivdi3+0x40>
  802262:	b8 01 00 00 00       	mov    $0x1,%eax
  802267:	eb d7                	jmp    802240 <__udivdi3+0x40>
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d9                	mov    %ebx,%ecx
  802272:	85 db                	test   %ebx,%ebx
  802274:	75 0b                	jne    802281 <__udivdi3+0x81>
  802276:	b8 01 00 00 00       	mov    $0x1,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	f7 f3                	div    %ebx
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	31 d2                	xor    %edx,%edx
  802283:	89 f0                	mov    %esi,%eax
  802285:	f7 f1                	div    %ecx
  802287:	89 c6                	mov    %eax,%esi
  802289:	89 e8                	mov    %ebp,%eax
  80228b:	89 f7                	mov    %esi,%edi
  80228d:	f7 f1                	div    %ecx
  80228f:	89 fa                	mov    %edi,%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	89 f9                	mov    %edi,%ecx
  8022a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8022a7:	29 f8                	sub    %edi,%eax
  8022a9:	d3 e2                	shl    %cl,%edx
  8022ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022af:	89 c1                	mov    %eax,%ecx
  8022b1:	89 da                	mov    %ebx,%edx
  8022b3:	d3 ea                	shr    %cl,%edx
  8022b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022b9:	09 d1                	or     %edx,%ecx
  8022bb:	89 f2                	mov    %esi,%edx
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f9                	mov    %edi,%ecx
  8022c3:	d3 e3                	shl    %cl,%ebx
  8022c5:	89 c1                	mov    %eax,%ecx
  8022c7:	d3 ea                	shr    %cl,%edx
  8022c9:	89 f9                	mov    %edi,%ecx
  8022cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022cf:	89 eb                	mov    %ebp,%ebx
  8022d1:	d3 e6                	shl    %cl,%esi
  8022d3:	89 c1                	mov    %eax,%ecx
  8022d5:	d3 eb                	shr    %cl,%ebx
  8022d7:	09 de                	or     %ebx,%esi
  8022d9:	89 f0                	mov    %esi,%eax
  8022db:	f7 74 24 08          	divl   0x8(%esp)
  8022df:	89 d6                	mov    %edx,%esi
  8022e1:	89 c3                	mov    %eax,%ebx
  8022e3:	f7 64 24 0c          	mull   0xc(%esp)
  8022e7:	39 d6                	cmp    %edx,%esi
  8022e9:	72 15                	jb     802300 <__udivdi3+0x100>
  8022eb:	89 f9                	mov    %edi,%ecx
  8022ed:	d3 e5                	shl    %cl,%ebp
  8022ef:	39 c5                	cmp    %eax,%ebp
  8022f1:	73 04                	jae    8022f7 <__udivdi3+0xf7>
  8022f3:	39 d6                	cmp    %edx,%esi
  8022f5:	74 09                	je     802300 <__udivdi3+0x100>
  8022f7:	89 d8                	mov    %ebx,%eax
  8022f9:	31 ff                	xor    %edi,%edi
  8022fb:	e9 40 ff ff ff       	jmp    802240 <__udivdi3+0x40>
  802300:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802303:	31 ff                	xor    %edi,%edi
  802305:	e9 36 ff ff ff       	jmp    802240 <__udivdi3+0x40>
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	f3 0f 1e fb          	endbr32 
  802314:	55                   	push   %ebp
  802315:	57                   	push   %edi
  802316:	56                   	push   %esi
  802317:	53                   	push   %ebx
  802318:	83 ec 1c             	sub    $0x1c,%esp
  80231b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80231f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802323:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802327:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80232b:	85 c0                	test   %eax,%eax
  80232d:	75 19                	jne    802348 <__umoddi3+0x38>
  80232f:	39 df                	cmp    %ebx,%edi
  802331:	76 5d                	jbe    802390 <__umoddi3+0x80>
  802333:	89 f0                	mov    %esi,%eax
  802335:	89 da                	mov    %ebx,%edx
  802337:	f7 f7                	div    %edi
  802339:	89 d0                	mov    %edx,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	83 c4 1c             	add    $0x1c,%esp
  802340:	5b                   	pop    %ebx
  802341:	5e                   	pop    %esi
  802342:	5f                   	pop    %edi
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    
  802345:	8d 76 00             	lea    0x0(%esi),%esi
  802348:	89 f2                	mov    %esi,%edx
  80234a:	39 d8                	cmp    %ebx,%eax
  80234c:	76 12                	jbe    802360 <__umoddi3+0x50>
  80234e:	89 f0                	mov    %esi,%eax
  802350:	89 da                	mov    %ebx,%edx
  802352:	83 c4 1c             	add    $0x1c,%esp
  802355:	5b                   	pop    %ebx
  802356:	5e                   	pop    %esi
  802357:	5f                   	pop    %edi
  802358:	5d                   	pop    %ebp
  802359:	c3                   	ret    
  80235a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802360:	0f bd e8             	bsr    %eax,%ebp
  802363:	83 f5 1f             	xor    $0x1f,%ebp
  802366:	75 50                	jne    8023b8 <__umoddi3+0xa8>
  802368:	39 d8                	cmp    %ebx,%eax
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	89 d9                	mov    %ebx,%ecx
  802372:	39 f7                	cmp    %esi,%edi
  802374:	0f 86 d6 00 00 00    	jbe    802450 <__umoddi3+0x140>
  80237a:	89 d0                	mov    %edx,%eax
  80237c:	89 ca                	mov    %ecx,%edx
  80237e:	83 c4 1c             	add    $0x1c,%esp
  802381:	5b                   	pop    %ebx
  802382:	5e                   	pop    %esi
  802383:	5f                   	pop    %edi
  802384:	5d                   	pop    %ebp
  802385:	c3                   	ret    
  802386:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	89 fd                	mov    %edi,%ebp
  802392:	85 ff                	test   %edi,%edi
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 d8                	mov    %ebx,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 f0                	mov    %esi,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	31 d2                	xor    %edx,%edx
  8023af:	eb 8c                	jmp    80233d <__umoddi3+0x2d>
  8023b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8023bf:	29 ea                	sub    %ebp,%edx
  8023c1:	d3 e0                	shl    %cl,%eax
  8023c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 f8                	mov    %edi,%eax
  8023cb:	d3 e8                	shr    %cl,%eax
  8023cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023d9:	09 c1                	or     %eax,%ecx
  8023db:	89 d8                	mov    %ebx,%eax
  8023dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023e1:	89 e9                	mov    %ebp,%ecx
  8023e3:	d3 e7                	shl    %cl,%edi
  8023e5:	89 d1                	mov    %edx,%ecx
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023ef:	d3 e3                	shl    %cl,%ebx
  8023f1:	89 c7                	mov    %eax,%edi
  8023f3:	89 d1                	mov    %edx,%ecx
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	89 fa                	mov    %edi,%edx
  8023fd:	d3 e6                	shl    %cl,%esi
  8023ff:	09 d8                	or     %ebx,%eax
  802401:	f7 74 24 08          	divl   0x8(%esp)
  802405:	89 d1                	mov    %edx,%ecx
  802407:	89 f3                	mov    %esi,%ebx
  802409:	f7 64 24 0c          	mull   0xc(%esp)
  80240d:	89 c6                	mov    %eax,%esi
  80240f:	89 d7                	mov    %edx,%edi
  802411:	39 d1                	cmp    %edx,%ecx
  802413:	72 06                	jb     80241b <__umoddi3+0x10b>
  802415:	75 10                	jne    802427 <__umoddi3+0x117>
  802417:	39 c3                	cmp    %eax,%ebx
  802419:	73 0c                	jae    802427 <__umoddi3+0x117>
  80241b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80241f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802423:	89 d7                	mov    %edx,%edi
  802425:	89 c6                	mov    %eax,%esi
  802427:	89 ca                	mov    %ecx,%edx
  802429:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80242e:	29 f3                	sub    %esi,%ebx
  802430:	19 fa                	sbb    %edi,%edx
  802432:	89 d0                	mov    %edx,%eax
  802434:	d3 e0                	shl    %cl,%eax
  802436:	89 e9                	mov    %ebp,%ecx
  802438:	d3 eb                	shr    %cl,%ebx
  80243a:	d3 ea                	shr    %cl,%edx
  80243c:	09 d8                	or     %ebx,%eax
  80243e:	83 c4 1c             	add    $0x1c,%esp
  802441:	5b                   	pop    %ebx
  802442:	5e                   	pop    %esi
  802443:	5f                   	pop    %edi
  802444:	5d                   	pop    %ebp
  802445:	c3                   	ret    
  802446:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 fe                	sub    %edi,%esi
  802452:	19 c3                	sbb    %eax,%ebx
  802454:	89 f2                	mov    %esi,%edx
  802456:	89 d9                	mov    %ebx,%ecx
  802458:	e9 1d ff ff ff       	jmp    80237a <__umoddi3+0x6a>
