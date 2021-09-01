
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4e 00 00 00       	call   80007f <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003d:	a1 08 40 80 00       	mov    0x804008,%eax
  800042:	8b 40 48             	mov    0x48(%eax),%eax
  800045:	50                   	push   %eax
  800046:	68 c0 29 80 00       	push   $0x8029c0
  80004b:	e8 7e 01 00 00       	call   8001ce <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800050:	83 c4 0c             	add    $0xc,%esp
  800053:	6a 00                	push   $0x0
  800055:	68 de 29 80 00       	push   $0x8029de
  80005a:	68 de 29 80 00       	push   $0x8029de
  80005f:	e8 42 1b 00 00       	call   801ba6 <spawnl>
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 02                	js     80006d <umain+0x3a>
		panic("spawn(hello) failed: %e", r);
}
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    
		panic("spawn(hello) failed: %e", r);
  80006d:	50                   	push   %eax
  80006e:	68 e4 29 80 00       	push   $0x8029e4
  800073:	6a 09                	push   $0x9
  800075:	68 fc 29 80 00       	push   $0x8029fc
  80007a:	e8 68 00 00 00       	call   8000e7 <_panic>

0080007f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007f:	f3 0f 1e fb          	endbr32 
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008e:	e8 68 0b 00 00       	call   800bfb <sys_getenvid>
  800093:	25 ff 03 00 00       	and    $0x3ff,%eax
  800098:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80009b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a0:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a5:	85 db                	test   %ebx,%ebx
  8000a7:	7e 07                	jle    8000b0 <libmain+0x31>
		binaryname = argv[0];
  8000a9:	8b 06                	mov    (%esi),%eax
  8000ab:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b0:	83 ec 08             	sub    $0x8,%esp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	e8 79 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ba:	e8 0a 00 00 00       	call   8000c9 <exit>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c9:	f3 0f 1e fb          	endbr32 
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000d3:	e8 f4 0e 00 00       	call   800fcc <close_all>
	sys_env_destroy(0);
  8000d8:	83 ec 0c             	sub    $0xc,%esp
  8000db:	6a 00                	push   $0x0
  8000dd:	e8 f5 0a 00 00       	call   800bd7 <sys_env_destroy>
}
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000f0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000f3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000f9:	e8 fd 0a 00 00       	call   800bfb <sys_getenvid>
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	ff 75 08             	pushl  0x8(%ebp)
  800107:	56                   	push   %esi
  800108:	50                   	push   %eax
  800109:	68 18 2a 80 00       	push   $0x802a18
  80010e:	e8 bb 00 00 00       	call   8001ce <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800113:	83 c4 18             	add    $0x18,%esp
  800116:	53                   	push   %ebx
  800117:	ff 75 10             	pushl  0x10(%ebp)
  80011a:	e8 5a 00 00 00       	call   800179 <vcprintf>
	cprintf("\n");
  80011f:	c7 04 24 67 2f 80 00 	movl   $0x802f67,(%esp)
  800126:	e8 a3 00 00 00       	call   8001ce <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80012e:	cc                   	int3   
  80012f:	eb fd                	jmp    80012e <_panic+0x47>

00800131 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800131:	f3 0f 1e fb          	endbr32 
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	53                   	push   %ebx
  800139:	83 ec 04             	sub    $0x4,%esp
  80013c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013f:	8b 13                	mov    (%ebx),%edx
  800141:	8d 42 01             	lea    0x1(%edx),%eax
  800144:	89 03                	mov    %eax,(%ebx)
  800146:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800149:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80014d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800152:	74 09                	je     80015d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800154:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800158:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80015d:	83 ec 08             	sub    $0x8,%esp
  800160:	68 ff 00 00 00       	push   $0xff
  800165:	8d 43 08             	lea    0x8(%ebx),%eax
  800168:	50                   	push   %eax
  800169:	e8 24 0a 00 00       	call   800b92 <sys_cputs>
		b->idx = 0;
  80016e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800174:	83 c4 10             	add    $0x10,%esp
  800177:	eb db                	jmp    800154 <putch+0x23>

00800179 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800179:	f3 0f 1e fb          	endbr32 
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800186:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018d:	00 00 00 
	b.cnt = 0;
  800190:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800197:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019a:	ff 75 0c             	pushl  0xc(%ebp)
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	68 31 01 80 00       	push   $0x800131
  8001ac:	e8 20 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b1:	83 c4 08             	add    $0x8,%esp
  8001b4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ba:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 cc 09 00 00       	call   800b92 <sys_cputs>

	return b.cnt;
}
  8001c6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ce:	f3 0f 1e fb          	endbr32 
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001db:	50                   	push   %eax
  8001dc:	ff 75 08             	pushl  0x8(%ebp)
  8001df:	e8 95 ff ff ff       	call   800179 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	57                   	push   %edi
  8001ea:	56                   	push   %esi
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 1c             	sub    $0x1c,%esp
  8001ef:	89 c7                	mov    %eax,%edi
  8001f1:	89 d6                	mov    %edx,%esi
  8001f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f9:	89 d1                	mov    %edx,%ecx
  8001fb:	89 c2                	mov    %eax,%edx
  8001fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800200:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800203:	8b 45 10             	mov    0x10(%ebp),%eax
  800206:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800209:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800213:	39 c2                	cmp    %eax,%edx
  800215:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800218:	72 3e                	jb     800258 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	ff 75 18             	pushl  0x18(%ebp)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	53                   	push   %ebx
  800224:	50                   	push   %eax
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022b:	ff 75 e0             	pushl  -0x20(%ebp)
  80022e:	ff 75 dc             	pushl  -0x24(%ebp)
  800231:	ff 75 d8             	pushl  -0x28(%ebp)
  800234:	e8 17 25 00 00       	call   802750 <__udivdi3>
  800239:	83 c4 18             	add    $0x18,%esp
  80023c:	52                   	push   %edx
  80023d:	50                   	push   %eax
  80023e:	89 f2                	mov    %esi,%edx
  800240:	89 f8                	mov    %edi,%eax
  800242:	e8 9f ff ff ff       	call   8001e6 <printnum>
  800247:	83 c4 20             	add    $0x20,%esp
  80024a:	eb 13                	jmp    80025f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	56                   	push   %esi
  800250:	ff 75 18             	pushl  0x18(%ebp)
  800253:	ff d7                	call   *%edi
  800255:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	7f ed                	jg     80024c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	56                   	push   %esi
  800263:	83 ec 04             	sub    $0x4,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 e9 25 00 00       	call   802860 <__umoddi3>
  800277:	83 c4 14             	add    $0x14,%esp
  80027a:	0f be 80 3b 2a 80 00 	movsbl 0x802a3b(%eax),%eax
  800281:	50                   	push   %eax
  800282:	ff d7                	call   *%edi
}
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028f:	f3 0f 1e fb          	endbr32 
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800299:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a2:	73 0a                	jae    8002ae <sprintputch+0x1f>
		*b->buf++ = ch;
  8002a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	88 02                	mov    %al,(%edx)
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <printfmt>:
{
  8002b0:	f3 0f 1e fb          	endbr32 
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	e8 05 00 00 00       	call   8002d1 <vprintfmt>
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
{
  8002d1:	f3 0f 1e fb          	endbr32 
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 3c             	sub    $0x3c,%esp
  8002de:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e7:	e9 8e 03 00 00       	jmp    80067a <vprintfmt+0x3a9>
		padc = ' ';
  8002ec:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002f0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800305:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 17             	movzbl (%edi),%edx
  800313:	8d 42 dd             	lea    -0x23(%edx),%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 df 03 00 00    	ja     8006fd <vprintfmt+0x42c>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	3e ff 24 85 80 2b 80 	notrack jmp *0x802b80(,%eax,4)
  800328:	00 
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80032c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800330:	eb d8                	jmp    80030a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800335:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800339:	eb cf                	jmp    80030a <vprintfmt+0x39>
  80033b:	0f b6 d2             	movzbl %dl,%edx
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800341:	b8 00 00 00 00       	mov    $0x0,%eax
  800346:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800349:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800350:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800353:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800356:	83 f9 09             	cmp    $0x9,%ecx
  800359:	77 55                	ja     8003b0 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80035b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80035e:	eb e9                	jmp    800349 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8b 00                	mov    (%eax),%eax
  800365:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 40 04             	lea    0x4(%eax),%eax
  80036e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800374:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800378:	79 90                	jns    80030a <vprintfmt+0x39>
				width = precision, precision = -1;
  80037a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80037d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800380:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800387:	eb 81                	jmp    80030a <vprintfmt+0x39>
  800389:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038c:	85 c0                	test   %eax,%eax
  80038e:	ba 00 00 00 00       	mov    $0x0,%edx
  800393:	0f 49 d0             	cmovns %eax,%edx
  800396:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039c:	e9 69 ff ff ff       	jmp    80030a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003ab:	e9 5a ff ff ff       	jmp    80030a <vprintfmt+0x39>
  8003b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b6:	eb bc                	jmp    800374 <vprintfmt+0xa3>
			lflag++;
  8003b8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003be:	e9 47 ff ff ff       	jmp    80030a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	8d 78 04             	lea    0x4(%eax),%edi
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	53                   	push   %ebx
  8003cd:	ff 30                	pushl  (%eax)
  8003cf:	ff d6                	call   *%esi
			break;
  8003d1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d7:	e9 9b 02 00 00       	jmp    800677 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 78 04             	lea    0x4(%eax),%edi
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	99                   	cltd   
  8003e5:	31 d0                	xor    %edx,%eax
  8003e7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e9:	83 f8 0f             	cmp    $0xf,%eax
  8003ec:	7f 23                	jg     800411 <vprintfmt+0x140>
  8003ee:	8b 14 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%edx
  8003f5:	85 d2                	test   %edx,%edx
  8003f7:	74 18                	je     800411 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003f9:	52                   	push   %edx
  8003fa:	68 e9 2d 80 00       	push   $0x802de9
  8003ff:	53                   	push   %ebx
  800400:	56                   	push   %esi
  800401:	e8 aa fe ff ff       	call   8002b0 <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800409:	89 7d 14             	mov    %edi,0x14(%ebp)
  80040c:	e9 66 02 00 00       	jmp    800677 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800411:	50                   	push   %eax
  800412:	68 53 2a 80 00       	push   $0x802a53
  800417:	53                   	push   %ebx
  800418:	56                   	push   %esi
  800419:	e8 92 fe ff ff       	call   8002b0 <printfmt>
  80041e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800421:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800424:	e9 4e 02 00 00       	jmp    800677 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	83 c0 04             	add    $0x4,%eax
  80042f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800437:	85 d2                	test   %edx,%edx
  800439:	b8 4c 2a 80 00       	mov    $0x802a4c,%eax
  80043e:	0f 45 c2             	cmovne %edx,%eax
  800441:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800444:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800448:	7e 06                	jle    800450 <vprintfmt+0x17f>
  80044a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80044e:	75 0d                	jne    80045d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800450:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800453:	89 c7                	mov    %eax,%edi
  800455:	03 45 e0             	add    -0x20(%ebp),%eax
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045b:	eb 55                	jmp    8004b2 <vprintfmt+0x1e1>
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 d8             	pushl  -0x28(%ebp)
  800463:	ff 75 cc             	pushl  -0x34(%ebp)
  800466:	e8 46 03 00 00       	call   8007b1 <strnlen>
  80046b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80046e:	29 c2                	sub    %eax,%edx
  800470:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800478:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80047c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	85 ff                	test   %edi,%edi
  800481:	7e 11                	jle    800494 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	eb eb                	jmp    80047f <vprintfmt+0x1ae>
  800494:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	b8 00 00 00 00       	mov    $0x0,%eax
  80049e:	0f 49 c2             	cmovns %edx,%eax
  8004a1:	29 c2                	sub    %eax,%edx
  8004a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a6:	eb a8                	jmp    800450 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	52                   	push   %edx
  8004ad:	ff d6                	call   *%esi
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b7:	83 c7 01             	add    $0x1,%edi
  8004ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004be:	0f be d0             	movsbl %al,%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 4b                	je     800510 <vprintfmt+0x23f>
  8004c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c9:	78 06                	js     8004d1 <vprintfmt+0x200>
  8004cb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004cf:	78 1e                	js     8004ef <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8004d1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d5:	74 d1                	je     8004a8 <vprintfmt+0x1d7>
  8004d7:	0f be c0             	movsbl %al,%eax
  8004da:	83 e8 20             	sub    $0x20,%eax
  8004dd:	83 f8 5e             	cmp    $0x5e,%eax
  8004e0:	76 c6                	jbe    8004a8 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 3f                	push   $0x3f
  8004e8:	ff d6                	call   *%esi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	eb c3                	jmp    8004b2 <vprintfmt+0x1e1>
  8004ef:	89 cf                	mov    %ecx,%edi
  8004f1:	eb 0e                	jmp    800501 <vprintfmt+0x230>
				putch(' ', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	6a 20                	push   $0x20
  8004f9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ee                	jg     8004f3 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800505:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800508:	89 45 14             	mov    %eax,0x14(%ebp)
  80050b:	e9 67 01 00 00       	jmp    800677 <vprintfmt+0x3a6>
  800510:	89 cf                	mov    %ecx,%edi
  800512:	eb ed                	jmp    800501 <vprintfmt+0x230>
	if (lflag >= 2)
  800514:	83 f9 01             	cmp    $0x1,%ecx
  800517:	7f 1b                	jg     800534 <vprintfmt+0x263>
	else if (lflag)
  800519:	85 c9                	test   %ecx,%ecx
  80051b:	74 63                	je     800580 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8b 00                	mov    (%eax),%eax
  800522:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800525:	99                   	cltd   
  800526:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 40 04             	lea    0x4(%eax),%eax
  80052f:	89 45 14             	mov    %eax,0x14(%ebp)
  800532:	eb 17                	jmp    80054b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 50 04             	mov    0x4(%eax),%edx
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 40 08             	lea    0x8(%eax),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80054b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800551:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800556:	85 c9                	test   %ecx,%ecx
  800558:	0f 89 ff 00 00 00    	jns    80065d <vprintfmt+0x38c>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056c:	f7 da                	neg    %edx
  80056e:	83 d1 00             	adc    $0x0,%ecx
  800571:	f7 d9                	neg    %ecx
  800573:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 dd 00 00 00       	jmp    80065d <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800588:	99                   	cltd   
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 04             	lea    0x4(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
  800595:	eb b4                	jmp    80054b <vprintfmt+0x27a>
	if (lflag >= 2)
  800597:	83 f9 01             	cmp    $0x1,%ecx
  80059a:	7f 1e                	jg     8005ba <vprintfmt+0x2e9>
	else if (lflag)
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	74 32                	je     8005d2 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8b 10                	mov    (%eax),%edx
  8005a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005b5:	e9 a3 00 00 00       	jmp    80065d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8b 10                	mov    (%eax),%edx
  8005bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c2:	8d 40 08             	lea    0x8(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005cd:	e9 8b 00 00 00       	jmp    80065d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dc:	8d 40 04             	lea    0x4(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005e7:	eb 74                	jmp    80065d <vprintfmt+0x38c>
	if (lflag >= 2)
  8005e9:	83 f9 01             	cmp    $0x1,%ecx
  8005ec:	7f 1b                	jg     800609 <vprintfmt+0x338>
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	74 2c                	je     80061e <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800602:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800607:	eb 54                	jmp    80065d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	8b 48 04             	mov    0x4(%eax),%ecx
  800611:	8d 40 08             	lea    0x8(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800617:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80061c:	eb 3f                	jmp    80065d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8b 10                	mov    (%eax),%edx
  800623:	b9 00 00 00 00       	mov    $0x0,%ecx
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80062e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800633:	eb 28                	jmp    80065d <vprintfmt+0x38c>
			putch('0', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 30                	push   $0x30
  80063b:	ff d6                	call   *%esi
			putch('x', putdat);
  80063d:	83 c4 08             	add    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 78                	push   $0x78
  800643:	ff d6                	call   *%esi
			num = (unsigned long long)
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 10                	mov    (%eax),%edx
  80064a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80064f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800658:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80065d:	83 ec 0c             	sub    $0xc,%esp
  800660:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800664:	57                   	push   %edi
  800665:	ff 75 e0             	pushl  -0x20(%ebp)
  800668:	50                   	push   %eax
  800669:	51                   	push   %ecx
  80066a:	52                   	push   %edx
  80066b:	89 da                	mov    %ebx,%edx
  80066d:	89 f0                	mov    %esi,%eax
  80066f:	e8 72 fb ff ff       	call   8001e6 <printnum>
			break;
  800674:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  80067a:	83 c7 01             	add    $0x1,%edi
  80067d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800681:	83 f8 25             	cmp    $0x25,%eax
  800684:	0f 84 62 fc ff ff    	je     8002ec <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  80068a:	85 c0                	test   %eax,%eax
  80068c:	0f 84 8b 00 00 00    	je     80071d <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	50                   	push   %eax
  800697:	ff d6                	call   *%esi
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb dc                	jmp    80067a <vprintfmt+0x3a9>
	if (lflag >= 2)
  80069e:	83 f9 01             	cmp    $0x1,%ecx
  8006a1:	7f 1b                	jg     8006be <vprintfmt+0x3ed>
	else if (lflag)
  8006a3:	85 c9                	test   %ecx,%ecx
  8006a5:	74 2c                	je     8006d3 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006bc:	eb 9f                	jmp    80065d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 10                	mov    (%eax),%edx
  8006c3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cc:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006d1:	eb 8a                	jmp    80065d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006e8:	e9 70 ff ff ff       	jmp    80065d <vprintfmt+0x38c>
			putch(ch, putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	6a 25                	push   $0x25
  8006f3:	ff d6                	call   *%esi
			break;
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	e9 7a ff ff ff       	jmp    800677 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	89 f8                	mov    %edi,%eax
  80070a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80070e:	74 05                	je     800715 <vprintfmt+0x444>
  800710:	83 e8 01             	sub    $0x1,%eax
  800713:	eb f5                	jmp    80070a <vprintfmt+0x439>
  800715:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800718:	e9 5a ff ff ff       	jmp    800677 <vprintfmt+0x3a6>
}
  80071d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800720:	5b                   	pop    %ebx
  800721:	5e                   	pop    %esi
  800722:	5f                   	pop    %edi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800725:	f3 0f 1e fb          	endbr32 
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	83 ec 18             	sub    $0x18,%esp
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800738:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800746:	85 c0                	test   %eax,%eax
  800748:	74 26                	je     800770 <vsnprintf+0x4b>
  80074a:	85 d2                	test   %edx,%edx
  80074c:	7e 22                	jle    800770 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074e:	ff 75 14             	pushl  0x14(%ebp)
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800757:	50                   	push   %eax
  800758:	68 8f 02 80 00       	push   $0x80028f
  80075d:	e8 6f fb ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800762:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800765:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076b:	83 c4 10             	add    $0x10,%esp
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    
		return -E_INVAL;
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800775:	eb f7                	jmp    80076e <vsnprintf+0x49>

00800777 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800777:	f3 0f 1e fb          	endbr32 
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800781:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800784:	50                   	push   %eax
  800785:	ff 75 10             	pushl  0x10(%ebp)
  800788:	ff 75 0c             	pushl  0xc(%ebp)
  80078b:	ff 75 08             	pushl  0x8(%ebp)
  80078e:	e8 92 ff ff ff       	call   800725 <vsnprintf>
	va_end(ap);

	return rc;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800795:	f3 0f 1e fb          	endbr32 
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a8:	74 05                	je     8007af <strlen+0x1a>
		n++;
  8007aa:	83 c0 01             	add    $0x1,%eax
  8007ad:	eb f5                	jmp    8007a4 <strlen+0xf>
	return n;
}
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b1:	f3 0f 1e fb          	endbr32 
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	39 d0                	cmp    %edx,%eax
  8007c5:	74 0d                	je     8007d4 <strnlen+0x23>
  8007c7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cb:	74 05                	je     8007d2 <strnlen+0x21>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
  8007d0:	eb f1                	jmp    8007c3 <strnlen+0x12>
  8007d2:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d4:	89 d0                	mov    %edx,%eax
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d8:	f3 0f 1e fb          	endbr32 
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007ef:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f2:	83 c0 01             	add    $0x1,%eax
  8007f5:	84 d2                	test   %dl,%dl
  8007f7:	75 f2                	jne    8007eb <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007f9:	89 c8                	mov    %ecx,%eax
  8007fb:	5b                   	pop    %ebx
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fe:	f3 0f 1e fb          	endbr32 
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	83 ec 10             	sub    $0x10,%esp
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080c:	53                   	push   %ebx
  80080d:	e8 83 ff ff ff       	call   800795 <strlen>
  800812:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	01 d8                	add    %ebx,%eax
  80081a:	50                   	push   %eax
  80081b:	e8 b8 ff ff ff       	call   8007d8 <strcpy>
	return dst;
}
  800820:	89 d8                	mov    %ebx,%eax
  800822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 75 08             	mov    0x8(%ebp),%esi
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	89 f3                	mov    %esi,%ebx
  800838:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	89 f0                	mov    %esi,%eax
  80083d:	39 d8                	cmp    %ebx,%eax
  80083f:	74 11                	je     800852 <strncpy+0x2b>
		*dst++ = *src;
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	0f b6 0a             	movzbl (%edx),%ecx
  800847:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084a:	80 f9 01             	cmp    $0x1,%cl
  80084d:	83 da ff             	sbb    $0xffffffff,%edx
  800850:	eb eb                	jmp    80083d <strncpy+0x16>
	}
	return ret;
}
  800852:	89 f0                	mov    %esi,%eax
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800858:	f3 0f 1e fb          	endbr32 
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 75 08             	mov    0x8(%ebp),%esi
  800864:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800867:	8b 55 10             	mov    0x10(%ebp),%edx
  80086a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086c:	85 d2                	test   %edx,%edx
  80086e:	74 21                	je     800891 <strlcpy+0x39>
  800870:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800874:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800876:	39 c2                	cmp    %eax,%edx
  800878:	74 14                	je     80088e <strlcpy+0x36>
  80087a:	0f b6 19             	movzbl (%ecx),%ebx
  80087d:	84 db                	test   %bl,%bl
  80087f:	74 0b                	je     80088c <strlcpy+0x34>
			*dst++ = *src++;
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	83 c2 01             	add    $0x1,%edx
  800887:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088a:	eb ea                	jmp    800876 <strlcpy+0x1e>
  80088c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80088e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800891:	29 f0                	sub    %esi,%eax
}
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800897:	f3 0f 1e fb          	endbr32 
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a4:	0f b6 01             	movzbl (%ecx),%eax
  8008a7:	84 c0                	test   %al,%al
  8008a9:	74 0c                	je     8008b7 <strcmp+0x20>
  8008ab:	3a 02                	cmp    (%edx),%al
  8008ad:	75 08                	jne    8008b7 <strcmp+0x20>
		p++, q++;
  8008af:	83 c1 01             	add    $0x1,%ecx
  8008b2:	83 c2 01             	add    $0x1,%edx
  8008b5:	eb ed                	jmp    8008a4 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 c0             	movzbl %al,%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c1:	f3 0f 1e fb          	endbr32 
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strncmp+0x1b>
		n--, p++, q++;
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008dc:	39 d8                	cmp    %ebx,%eax
  8008de:	74 16                	je     8008f6 <strncmp+0x35>
  8008e0:	0f b6 08             	movzbl (%eax),%ecx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	74 04                	je     8008eb <strncmp+0x2a>
  8008e7:	3a 0a                	cmp    (%edx),%cl
  8008e9:	74 eb                	je     8008d6 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    
		return 0;
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	eb f6                	jmp    8008f3 <strncmp+0x32>

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	f3 0f 1e fb          	endbr32 
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	0f b6 10             	movzbl (%eax),%edx
  80090e:	84 d2                	test   %dl,%dl
  800910:	74 09                	je     80091b <strchr+0x1e>
		if (*s == c)
  800912:	38 ca                	cmp    %cl,%dl
  800914:	74 0a                	je     800920 <strchr+0x23>
	for (; *s; s++)
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	eb f0                	jmp    80090b <strchr+0xe>
			return (char *) s;
	return 0;
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800922:	f3 0f 1e fb          	endbr32 
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80092c:	6a 78                	push   $0x78
  80092e:	ff 75 08             	pushl  0x8(%ebp)
  800931:	e8 c7 ff ff ff       	call   8008fd <strchr>
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800941:	eb 0d                	jmp    800950 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800943:	c1 e0 04             	shl    $0x4,%eax
  800946:	0f be d2             	movsbl %dl,%edx
  800949:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  80094d:	83 c1 01             	add    $0x1,%ecx
  800950:	0f b6 11             	movzbl (%ecx),%edx
  800953:	84 d2                	test   %dl,%dl
  800955:	74 11                	je     800968 <atox+0x46>
		if (*p>='a'){
  800957:	80 fa 60             	cmp    $0x60,%dl
  80095a:	7e e7                	jle    800943 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  80095c:	c1 e0 04             	shl    $0x4,%eax
  80095f:	0f be d2             	movsbl %dl,%edx
  800962:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800966:	eb e5                	jmp    80094d <atox+0x2b>
	}

	return v;

}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096a:	f3 0f 1e fb          	endbr32 
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800978:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097b:	38 ca                	cmp    %cl,%dl
  80097d:	74 09                	je     800988 <strfind+0x1e>
  80097f:	84 d2                	test   %dl,%dl
  800981:	74 05                	je     800988 <strfind+0x1e>
	for (; *s; s++)
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	eb f0                	jmp    800978 <strfind+0xe>
			break;
	return (char *) s;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098a:	f3 0f 1e fb          	endbr32 
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 7d 08             	mov    0x8(%ebp),%edi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099a:	85 c9                	test   %ecx,%ecx
  80099c:	74 31                	je     8009cf <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099e:	89 f8                	mov    %edi,%eax
  8009a0:	09 c8                	or     %ecx,%eax
  8009a2:	a8 03                	test   $0x3,%al
  8009a4:	75 23                	jne    8009c9 <memset+0x3f>
		c &= 0xFF;
  8009a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009aa:	89 d3                	mov    %edx,%ebx
  8009ac:	c1 e3 08             	shl    $0x8,%ebx
  8009af:	89 d0                	mov    %edx,%eax
  8009b1:	c1 e0 18             	shl    $0x18,%eax
  8009b4:	89 d6                	mov    %edx,%esi
  8009b6:	c1 e6 10             	shl    $0x10,%esi
  8009b9:	09 f0                	or     %esi,%eax
  8009bb:	09 c2                	or     %eax,%edx
  8009bd:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	fc                   	cld    
  8009c5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c7:	eb 06                	jmp    8009cf <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	fc                   	cld    
  8009cd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cf:	89 f8                	mov    %edi,%eax
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d6:	f3 0f 1e fb          	endbr32 
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	57                   	push   %edi
  8009de:	56                   	push   %esi
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e8:	39 c6                	cmp    %eax,%esi
  8009ea:	73 32                	jae    800a1e <memmove+0x48>
  8009ec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ef:	39 c2                	cmp    %eax,%edx
  8009f1:	76 2b                	jbe    800a1e <memmove+0x48>
		s += n;
		d += n;
  8009f3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f6:	89 fe                	mov    %edi,%esi
  8009f8:	09 ce                	or     %ecx,%esi
  8009fa:	09 d6                	or     %edx,%esi
  8009fc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a02:	75 0e                	jne    800a12 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a04:	83 ef 04             	sub    $0x4,%edi
  800a07:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0d:	fd                   	std    
  800a0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a10:	eb 09                	jmp    800a1b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a12:	83 ef 01             	sub    $0x1,%edi
  800a15:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a18:	fd                   	std    
  800a19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1b:	fc                   	cld    
  800a1c:	eb 1a                	jmp    800a38 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	09 ca                	or     %ecx,%edx
  800a22:	09 f2                	or     %esi,%edx
  800a24:	f6 c2 03             	test   $0x3,%dl
  800a27:	75 0a                	jne    800a33 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a29:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a2c:	89 c7                	mov    %eax,%edi
  800a2e:	fc                   	cld    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 05                	jmp    800a38 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	fc                   	cld    
  800a36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a38:	5e                   	pop    %esi
  800a39:	5f                   	pop    %edi
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3c:	f3 0f 1e fb          	endbr32 
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a46:	ff 75 10             	pushl  0x10(%ebp)
  800a49:	ff 75 0c             	pushl  0xc(%ebp)
  800a4c:	ff 75 08             	pushl  0x8(%ebp)
  800a4f:	e8 82 ff ff ff       	call   8009d6 <memmove>
}
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a56:	f3 0f 1e fb          	endbr32 
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c6                	mov    %eax,%esi
  800a67:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6a:	39 f0                	cmp    %esi,%eax
  800a6c:	74 1c                	je     800a8a <memcmp+0x34>
		if (*s1 != *s2)
  800a6e:	0f b6 08             	movzbl (%eax),%ecx
  800a71:	0f b6 1a             	movzbl (%edx),%ebx
  800a74:	38 d9                	cmp    %bl,%cl
  800a76:	75 08                	jne    800a80 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	83 c2 01             	add    $0x1,%edx
  800a7e:	eb ea                	jmp    800a6a <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a80:	0f b6 c1             	movzbl %cl,%eax
  800a83:	0f b6 db             	movzbl %bl,%ebx
  800a86:	29 d8                	sub    %ebx,%eax
  800a88:	eb 05                	jmp    800a8f <memcmp+0x39>
	}

	return 0;
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a93:	f3 0f 1e fb          	endbr32 
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa0:	89 c2                	mov    %eax,%edx
  800aa2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa5:	39 d0                	cmp    %edx,%eax
  800aa7:	73 09                	jae    800ab2 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa9:	38 08                	cmp    %cl,(%eax)
  800aab:	74 05                	je     800ab2 <memfind+0x1f>
	for (; s < ends; s++)
  800aad:	83 c0 01             	add    $0x1,%eax
  800ab0:	eb f3                	jmp    800aa5 <memfind+0x12>
			break;
	return (void *) s;
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab4:	f3 0f 1e fb          	endbr32 
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	57                   	push   %edi
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
  800abe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac4:	eb 03                	jmp    800ac9 <strtol+0x15>
		s++;
  800ac6:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac9:	0f b6 01             	movzbl (%ecx),%eax
  800acc:	3c 20                	cmp    $0x20,%al
  800ace:	74 f6                	je     800ac6 <strtol+0x12>
  800ad0:	3c 09                	cmp    $0x9,%al
  800ad2:	74 f2                	je     800ac6 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ad4:	3c 2b                	cmp    $0x2b,%al
  800ad6:	74 2a                	je     800b02 <strtol+0x4e>
	int neg = 0;
  800ad8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800add:	3c 2d                	cmp    $0x2d,%al
  800adf:	74 2b                	je     800b0c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae7:	75 0f                	jne    800af8 <strtol+0x44>
  800ae9:	80 39 30             	cmpb   $0x30,(%ecx)
  800aec:	74 28                	je     800b16 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aee:	85 db                	test   %ebx,%ebx
  800af0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af5:	0f 44 d8             	cmove  %eax,%ebx
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b00:	eb 46                	jmp    800b48 <strtol+0x94>
		s++;
  800b02:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b05:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0a:	eb d5                	jmp    800ae1 <strtol+0x2d>
		s++, neg = 1;
  800b0c:	83 c1 01             	add    $0x1,%ecx
  800b0f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b14:	eb cb                	jmp    800ae1 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b16:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b1a:	74 0e                	je     800b2a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b1c:	85 db                	test   %ebx,%ebx
  800b1e:	75 d8                	jne    800af8 <strtol+0x44>
		s++, base = 8;
  800b20:	83 c1 01             	add    $0x1,%ecx
  800b23:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b28:	eb ce                	jmp    800af8 <strtol+0x44>
		s += 2, base = 16;
  800b2a:	83 c1 02             	add    $0x2,%ecx
  800b2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b32:	eb c4                	jmp    800af8 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b3a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b3d:	7d 3a                	jge    800b79 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b3f:	83 c1 01             	add    $0x1,%ecx
  800b42:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b46:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b48:	0f b6 11             	movzbl (%ecx),%edx
  800b4b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b4e:	89 f3                	mov    %esi,%ebx
  800b50:	80 fb 09             	cmp    $0x9,%bl
  800b53:	76 df                	jbe    800b34 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b55:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b58:	89 f3                	mov    %esi,%ebx
  800b5a:	80 fb 19             	cmp    $0x19,%bl
  800b5d:	77 08                	ja     800b67 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b5f:	0f be d2             	movsbl %dl,%edx
  800b62:	83 ea 57             	sub    $0x57,%edx
  800b65:	eb d3                	jmp    800b3a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b67:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b6a:	89 f3                	mov    %esi,%ebx
  800b6c:	80 fb 19             	cmp    $0x19,%bl
  800b6f:	77 08                	ja     800b79 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b71:	0f be d2             	movsbl %dl,%edx
  800b74:	83 ea 37             	sub    $0x37,%edx
  800b77:	eb c1                	jmp    800b3a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7d:	74 05                	je     800b84 <strtol+0xd0>
		*endptr = (char *) s;
  800b7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b82:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b84:	89 c2                	mov    %eax,%edx
  800b86:	f7 da                	neg    %edx
  800b88:	85 ff                	test   %edi,%edi
  800b8a:	0f 45 c2             	cmovne %edx,%eax
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b92:	f3 0f 1e fb          	endbr32 
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	89 c3                	mov    %eax,%ebx
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	89 c6                	mov    %eax,%esi
  800bad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb4:	f3 0f 1e fb          	endbr32 
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	89 d3                	mov    %edx,%ebx
  800bcc:	89 d7                	mov    %edx,%edi
  800bce:	89 d6                	mov    %edx,%esi
  800bd0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd7:	f3 0f 1e fb          	endbr32 
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bee:	89 cb                	mov    %ecx,%ebx
  800bf0:	89 cf                	mov    %ecx,%edi
  800bf2:	89 ce                	mov    %ecx,%esi
  800bf4:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	f3 0f 1e fb          	endbr32 
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_yield>:

void
sys_yield(void)
{
  800c1e:	f3 0f 1e fb          	endbr32 
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c41:	f3 0f 1e fb          	endbr32 
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4b:	be 00 00 00 00       	mov    $0x0,%esi
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5e:	89 f7                	mov    %esi,%edi
  800c60:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c82:	8b 75 18             	mov    0x18(%ebp),%esi
  800c85:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8c:	f3 0f 1e fb          	endbr32 
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb1:	f3 0f 1e fb          	endbr32 
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd6:	f3 0f 1e fb          	endbr32 
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfb:	f3 0f 1e fb          	endbr32 
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d15:	89 df                	mov    %ebx,%edi
  800d17:	89 de                	mov    %ebx,%esi
  800d19:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d35:	be 00 00 00 00       	mov    $0x0,%esi
  800d3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d40:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d47:	f3 0f 1e fb          	endbr32 
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	89 cb                	mov    %ecx,%ebx
  800d60:	89 cf                	mov    %ecx,%edi
  800d62:	89 ce                	mov    %ecx,%esi
  800d64:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d6b:	f3 0f 1e fb          	endbr32 
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d75:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7f:	89 d1                	mov    %edx,%ecx
  800d81:	89 d3                	mov    %edx,%ebx
  800d83:	89 d7                	mov    %edx,%edi
  800d85:	89 d6                	mov    %edx,%esi
  800d87:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d8e:	f3 0f 1e fb          	endbr32 
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da8:	89 df                	mov    %ebx,%edi
  800daa:	89 de                	mov    %ebx,%esi
  800dac:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800db3:	f3 0f 1e fb          	endbr32 
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	b8 10 00 00 00       	mov    $0x10,%eax
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd8:	f3 0f 1e fb          	endbr32 
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	05 00 00 00 30       	add    $0x30000000,%eax
  800de7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dec:	f3 0f 1e fb          	endbr32 
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800dfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e00:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e07:	f3 0f 1e fb          	endbr32 
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e13:	89 c2                	mov    %eax,%edx
  800e15:	c1 ea 16             	shr    $0x16,%edx
  800e18:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1f:	f6 c2 01             	test   $0x1,%dl
  800e22:	74 2d                	je     800e51 <fd_alloc+0x4a>
  800e24:	89 c2                	mov    %eax,%edx
  800e26:	c1 ea 0c             	shr    $0xc,%edx
  800e29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e30:	f6 c2 01             	test   $0x1,%dl
  800e33:	74 1c                	je     800e51 <fd_alloc+0x4a>
  800e35:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e3a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3f:	75 d2                	jne    800e13 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e4a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e4f:	eb 0a                	jmp    800e5b <fd_alloc+0x54>
			*fd_store = fd;
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e5d:	f3 0f 1e fb          	endbr32 
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e67:	83 f8 1f             	cmp    $0x1f,%eax
  800e6a:	77 30                	ja     800e9c <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e6c:	c1 e0 0c             	shl    $0xc,%eax
  800e6f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e74:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	74 24                	je     800ea3 <fd_lookup+0x46>
  800e7f:	89 c2                	mov    %eax,%edx
  800e81:	c1 ea 0c             	shr    $0xc,%edx
  800e84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8b:	f6 c2 01             	test   $0x1,%dl
  800e8e:	74 1a                	je     800eaa <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e93:	89 02                	mov    %eax,(%edx)
	return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
		return -E_INVAL;
  800e9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea1:	eb f7                	jmp    800e9a <fd_lookup+0x3d>
		return -E_INVAL;
  800ea3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea8:	eb f0                	jmp    800e9a <fd_lookup+0x3d>
  800eaa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eaf:	eb e9                	jmp    800e9a <fd_lookup+0x3d>

00800eb1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb1:	f3 0f 1e fb          	endbr32 
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 08             	sub    $0x8,%esp
  800ebb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800ebe:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec3:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ec8:	39 08                	cmp    %ecx,(%eax)
  800eca:	74 38                	je     800f04 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800ecc:	83 c2 01             	add    $0x1,%edx
  800ecf:	8b 04 95 bc 2d 80 00 	mov    0x802dbc(,%edx,4),%eax
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	75 ee                	jne    800ec8 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eda:	a1 08 40 80 00       	mov    0x804008,%eax
  800edf:	8b 40 48             	mov    0x48(%eax),%eax
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	51                   	push   %ecx
  800ee6:	50                   	push   %eax
  800ee7:	68 40 2d 80 00       	push   $0x802d40
  800eec:	e8 dd f2 ff ff       	call   8001ce <cprintf>
	*dev = 0;
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    
			*dev = devtab[i];
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	eb f2                	jmp    800f02 <dev_lookup+0x51>

00800f10 <fd_close>:
{
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 24             	sub    $0x24,%esp
  800f1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f20:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f26:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f27:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f2d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f30:	50                   	push   %eax
  800f31:	e8 27 ff ff ff       	call   800e5d <fd_lookup>
  800f36:	89 c3                	mov    %eax,%ebx
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 05                	js     800f44 <fd_close+0x34>
	    || fd != fd2)
  800f3f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f42:	74 16                	je     800f5a <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f44:	89 f8                	mov    %edi,%eax
  800f46:	84 c0                	test   %al,%al
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4d:	0f 44 d8             	cmove  %eax,%ebx
}
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5a:	83 ec 08             	sub    $0x8,%esp
  800f5d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	ff 36                	pushl  (%esi)
  800f63:	e8 49 ff ff ff       	call   800eb1 <dev_lookup>
  800f68:	89 c3                	mov    %eax,%ebx
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 1a                	js     800f8b <fd_close+0x7b>
		if (dev->dev_close)
  800f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f74:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	74 0b                	je     800f8b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	56                   	push   %esi
  800f84:	ff d0                	call   *%eax
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f8b:	83 ec 08             	sub    $0x8,%esp
  800f8e:	56                   	push   %esi
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 f6 fc ff ff       	call   800c8c <sys_page_unmap>
	return r;
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	eb b5                	jmp    800f50 <fd_close+0x40>

00800f9b <close>:

int
close(int fdnum)
{
  800f9b:	f3 0f 1e fb          	endbr32 
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 75 08             	pushl  0x8(%ebp)
  800fac:	e8 ac fe ff ff       	call   800e5d <fd_lookup>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	79 02                	jns    800fba <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    
		return fd_close(fd, 1);
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	6a 01                	push   $0x1
  800fbf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc2:	e8 49 ff ff ff       	call   800f10 <fd_close>
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	eb ec                	jmp    800fb8 <close+0x1d>

00800fcc <close_all>:

void
close_all(void)
{
  800fcc:	f3 0f 1e fb          	endbr32 
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	53                   	push   %ebx
  800fe0:	e8 b6 ff ff ff       	call   800f9b <close>
	for (i = 0; i < MAXFD; i++)
  800fe5:	83 c3 01             	add    $0x1,%ebx
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	83 fb 20             	cmp    $0x20,%ebx
  800fee:	75 ec                	jne    800fdc <close_all+0x10>
}
  800ff0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff5:	f3 0f 1e fb          	endbr32 
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	57                   	push   %edi
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801002:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801005:	50                   	push   %eax
  801006:	ff 75 08             	pushl  0x8(%ebp)
  801009:	e8 4f fe ff ff       	call   800e5d <fd_lookup>
  80100e:	89 c3                	mov    %eax,%ebx
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	0f 88 81 00 00 00    	js     80109c <dup+0xa7>
		return r;
	close(newfdnum);
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	ff 75 0c             	pushl  0xc(%ebp)
  801021:	e8 75 ff ff ff       	call   800f9b <close>

	newfd = INDEX2FD(newfdnum);
  801026:	8b 75 0c             	mov    0xc(%ebp),%esi
  801029:	c1 e6 0c             	shl    $0xc,%esi
  80102c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801032:	83 c4 04             	add    $0x4,%esp
  801035:	ff 75 e4             	pushl  -0x1c(%ebp)
  801038:	e8 af fd ff ff       	call   800dec <fd2data>
  80103d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80103f:	89 34 24             	mov    %esi,(%esp)
  801042:	e8 a5 fd ff ff       	call   800dec <fd2data>
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104c:	89 d8                	mov    %ebx,%eax
  80104e:	c1 e8 16             	shr    $0x16,%eax
  801051:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801058:	a8 01                	test   $0x1,%al
  80105a:	74 11                	je     80106d <dup+0x78>
  80105c:	89 d8                	mov    %ebx,%eax
  80105e:	c1 e8 0c             	shr    $0xc,%eax
  801061:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801068:	f6 c2 01             	test   $0x1,%dl
  80106b:	75 39                	jne    8010a6 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801070:	89 d0                	mov    %edx,%eax
  801072:	c1 e8 0c             	shr    $0xc,%eax
  801075:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	25 07 0e 00 00       	and    $0xe07,%eax
  801084:	50                   	push   %eax
  801085:	56                   	push   %esi
  801086:	6a 00                	push   $0x0
  801088:	52                   	push   %edx
  801089:	6a 00                	push   $0x0
  80108b:	e8 d7 fb ff ff       	call   800c67 <sys_page_map>
  801090:	89 c3                	mov    %eax,%ebx
  801092:	83 c4 20             	add    $0x20,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	78 31                	js     8010ca <dup+0xd5>
		goto err;

	return newfdnum;
  801099:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80109c:	89 d8                	mov    %ebx,%eax
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ad:	83 ec 0c             	sub    $0xc,%esp
  8010b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b5:	50                   	push   %eax
  8010b6:	57                   	push   %edi
  8010b7:	6a 00                	push   $0x0
  8010b9:	53                   	push   %ebx
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 a6 fb ff ff       	call   800c67 <sys_page_map>
  8010c1:	89 c3                	mov    %eax,%ebx
  8010c3:	83 c4 20             	add    $0x20,%esp
  8010c6:	85 c0                	test   %eax,%eax
  8010c8:	79 a3                	jns    80106d <dup+0x78>
	sys_page_unmap(0, newfd);
  8010ca:	83 ec 08             	sub    $0x8,%esp
  8010cd:	56                   	push   %esi
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 b7 fb ff ff       	call   800c8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	57                   	push   %edi
  8010d9:	6a 00                	push   $0x0
  8010db:	e8 ac fb ff ff       	call   800c8c <sys_page_unmap>
	return r;
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	eb b7                	jmp    80109c <dup+0xa7>

008010e5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e5:	f3 0f 1e fb          	endbr32 
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 1c             	sub    $0x1c,%esp
  8010f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	53                   	push   %ebx
  8010f8:	e8 60 fd ff ff       	call   800e5d <fd_lookup>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	78 3f                	js     801143 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801104:	83 ec 08             	sub    $0x8,%esp
  801107:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110a:	50                   	push   %eax
  80110b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110e:	ff 30                	pushl  (%eax)
  801110:	e8 9c fd ff ff       	call   800eb1 <dev_lookup>
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 27                	js     801143 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80111f:	8b 42 08             	mov    0x8(%edx),%eax
  801122:	83 e0 03             	and    $0x3,%eax
  801125:	83 f8 01             	cmp    $0x1,%eax
  801128:	74 1e                	je     801148 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112d:	8b 40 08             	mov    0x8(%eax),%eax
  801130:	85 c0                	test   %eax,%eax
  801132:	74 35                	je     801169 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	ff 75 10             	pushl  0x10(%ebp)
  80113a:	ff 75 0c             	pushl  0xc(%ebp)
  80113d:	52                   	push   %edx
  80113e:	ff d0                	call   *%eax
  801140:	83 c4 10             	add    $0x10,%esp
}
  801143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801146:	c9                   	leave  
  801147:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801148:	a1 08 40 80 00       	mov    0x804008,%eax
  80114d:	8b 40 48             	mov    0x48(%eax),%eax
  801150:	83 ec 04             	sub    $0x4,%esp
  801153:	53                   	push   %ebx
  801154:	50                   	push   %eax
  801155:	68 81 2d 80 00       	push   $0x802d81
  80115a:	e8 6f f0 ff ff       	call   8001ce <cprintf>
		return -E_INVAL;
  80115f:	83 c4 10             	add    $0x10,%esp
  801162:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801167:	eb da                	jmp    801143 <read+0x5e>
		return -E_NOT_SUPP;
  801169:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80116e:	eb d3                	jmp    801143 <read+0x5e>

00801170 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801170:	f3 0f 1e fb          	endbr32 
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	53                   	push   %ebx
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801180:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801183:	bb 00 00 00 00       	mov    $0x0,%ebx
  801188:	eb 02                	jmp    80118c <readn+0x1c>
  80118a:	01 c3                	add    %eax,%ebx
  80118c:	39 f3                	cmp    %esi,%ebx
  80118e:	73 21                	jae    8011b1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	89 f0                	mov    %esi,%eax
  801195:	29 d8                	sub    %ebx,%eax
  801197:	50                   	push   %eax
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	03 45 0c             	add    0xc(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	57                   	push   %edi
  80119f:	e8 41 ff ff ff       	call   8010e5 <read>
		if (m < 0)
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 04                	js     8011af <readn+0x3f>
			return m;
		if (m == 0)
  8011ab:	75 dd                	jne    80118a <readn+0x1a>
  8011ad:	eb 02                	jmp    8011b1 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011af:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011b1:	89 d8                	mov    %ebx,%eax
  8011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011bb:	f3 0f 1e fb          	endbr32 
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 1c             	sub    $0x1c,%esp
  8011c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	53                   	push   %ebx
  8011ce:	e8 8a fc ff ff       	call   800e5d <fd_lookup>
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 3a                	js     801214 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e0:	50                   	push   %eax
  8011e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e4:	ff 30                	pushl  (%eax)
  8011e6:	e8 c6 fc ff ff       	call   800eb1 <dev_lookup>
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 22                	js     801214 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f9:	74 1e                	je     801219 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fe:	8b 52 0c             	mov    0xc(%edx),%edx
  801201:	85 d2                	test   %edx,%edx
  801203:	74 35                	je     80123a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	ff 75 10             	pushl  0x10(%ebp)
  80120b:	ff 75 0c             	pushl  0xc(%ebp)
  80120e:	50                   	push   %eax
  80120f:	ff d2                	call   *%edx
  801211:	83 c4 10             	add    $0x10,%esp
}
  801214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801217:	c9                   	leave  
  801218:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801219:	a1 08 40 80 00       	mov    0x804008,%eax
  80121e:	8b 40 48             	mov    0x48(%eax),%eax
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	53                   	push   %ebx
  801225:	50                   	push   %eax
  801226:	68 9d 2d 80 00       	push   $0x802d9d
  80122b:	e8 9e ef ff ff       	call   8001ce <cprintf>
		return -E_INVAL;
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801238:	eb da                	jmp    801214 <write+0x59>
		return -E_NOT_SUPP;
  80123a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80123f:	eb d3                	jmp    801214 <write+0x59>

00801241 <seek>:

int
seek(int fdnum, off_t offset)
{
  801241:	f3 0f 1e fb          	endbr32 
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	ff 75 08             	pushl  0x8(%ebp)
  801252:	e8 06 fc ff ff       	call   800e5d <fd_lookup>
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 0e                	js     80126c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80125e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801261:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801264:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126e:	f3 0f 1e fb          	endbr32 
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	53                   	push   %ebx
  801276:	83 ec 1c             	sub    $0x1c,%esp
  801279:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127f:	50                   	push   %eax
  801280:	53                   	push   %ebx
  801281:	e8 d7 fb ff ff       	call   800e5d <fd_lookup>
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 37                	js     8012c4 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801297:	ff 30                	pushl  (%eax)
  801299:	e8 13 fc ff ff       	call   800eb1 <dev_lookup>
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 1f                	js     8012c4 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ac:	74 1b                	je     8012c9 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b1:	8b 52 18             	mov    0x18(%edx),%edx
  8012b4:	85 d2                	test   %edx,%edx
  8012b6:	74 32                	je     8012ea <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	ff 75 0c             	pushl  0xc(%ebp)
  8012be:	50                   	push   %eax
  8012bf:	ff d2                	call   *%edx
  8012c1:	83 c4 10             	add    $0x10,%esp
}
  8012c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012c9:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ce:	8b 40 48             	mov    0x48(%eax),%eax
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	50                   	push   %eax
  8012d6:	68 60 2d 80 00       	push   $0x802d60
  8012db:	e8 ee ee ff ff       	call   8001ce <cprintf>
		return -E_INVAL;
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e8:	eb da                	jmp    8012c4 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ef:	eb d3                	jmp    8012c4 <ftruncate+0x56>

008012f1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f1:	f3 0f 1e fb          	endbr32 
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 1c             	sub    $0x1c,%esp
  8012fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801302:	50                   	push   %eax
  801303:	ff 75 08             	pushl  0x8(%ebp)
  801306:	e8 52 fb ff ff       	call   800e5d <fd_lookup>
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 4b                	js     80135d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	ff 30                	pushl  (%eax)
  80131e:	e8 8e fb ff ff       	call   800eb1 <dev_lookup>
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 33                	js     80135d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801331:	74 2f                	je     801362 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801333:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801336:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133d:	00 00 00 
	stat->st_isdir = 0;
  801340:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801347:	00 00 00 
	stat->st_dev = dev;
  80134a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	53                   	push   %ebx
  801354:	ff 75 f0             	pushl  -0x10(%ebp)
  801357:	ff 50 14             	call   *0x14(%eax)
  80135a:	83 c4 10             	add    $0x10,%esp
}
  80135d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801360:	c9                   	leave  
  801361:	c3                   	ret    
		return -E_NOT_SUPP;
  801362:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801367:	eb f4                	jmp    80135d <fstat+0x6c>

00801369 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801369:	f3 0f 1e fb          	endbr32 
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	6a 00                	push   $0x0
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 01 02 00 00       	call   801580 <open>
  80137f:	89 c3                	mov    %eax,%ebx
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 1b                	js     8013a3 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	ff 75 0c             	pushl  0xc(%ebp)
  80138e:	50                   	push   %eax
  80138f:	e8 5d ff ff ff       	call   8012f1 <fstat>
  801394:	89 c6                	mov    %eax,%esi
	close(fd);
  801396:	89 1c 24             	mov    %ebx,(%esp)
  801399:	e8 fd fb ff ff       	call   800f9b <close>
	return r;
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	89 f3                	mov    %esi,%ebx
}
  8013a3:	89 d8                	mov    %ebx,%eax
  8013a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	89 c6                	mov    %eax,%esi
  8013b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013bc:	74 27                	je     8013e5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013be:	6a 07                	push   $0x7
  8013c0:	68 00 50 80 00       	push   $0x805000
  8013c5:	56                   	push   %esi
  8013c6:	ff 35 00 40 80 00    	pushl  0x804000
  8013cc:	e8 a7 12 00 00       	call   802678 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d1:	83 c4 0c             	add    $0xc,%esp
  8013d4:	6a 00                	push   $0x0
  8013d6:	53                   	push   %ebx
  8013d7:	6a 00                	push   $0x0
  8013d9:	e8 2d 12 00 00       	call   80260b <ipc_recv>
}
  8013de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	6a 01                	push   $0x1
  8013ea:	e8 e1 12 00 00       	call   8026d0 <ipc_find_env>
  8013ef:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	eb c5                	jmp    8013be <fsipc+0x12>

008013f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f9:	f3 0f 1e fb          	endbr32 
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801403:	8b 45 08             	mov    0x8(%ebp),%eax
  801406:	8b 40 0c             	mov    0xc(%eax),%eax
  801409:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801411:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801416:	ba 00 00 00 00       	mov    $0x0,%edx
  80141b:	b8 02 00 00 00       	mov    $0x2,%eax
  801420:	e8 87 ff ff ff       	call   8013ac <fsipc>
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <devfile_flush>:
{
  801427:	f3 0f 1e fb          	endbr32 
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
  801434:	8b 40 0c             	mov    0xc(%eax),%eax
  801437:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143c:	ba 00 00 00 00       	mov    $0x0,%edx
  801441:	b8 06 00 00 00       	mov    $0x6,%eax
  801446:	e8 61 ff ff ff       	call   8013ac <fsipc>
}
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <devfile_stat>:
{
  80144d:	f3 0f 1e fb          	endbr32 
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	53                   	push   %ebx
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	8b 40 0c             	mov    0xc(%eax),%eax
  801461:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	b8 05 00 00 00       	mov    $0x5,%eax
  801470:	e8 37 ff ff ff       	call   8013ac <fsipc>
  801475:	85 c0                	test   %eax,%eax
  801477:	78 2c                	js     8014a5 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	68 00 50 80 00       	push   $0x805000
  801481:	53                   	push   %ebx
  801482:	e8 51 f3 ff ff       	call   8007d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801487:	a1 80 50 80 00       	mov    0x805080,%eax
  80148c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801492:	a1 84 50 80 00       	mov    0x805084,%eax
  801497:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <devfile_write>:
{
  8014aa:	f3 0f 1e fb          	endbr32 
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8014b7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014bc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014c1:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ca:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014d0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014d5:	50                   	push   %eax
  8014d6:	ff 75 0c             	pushl  0xc(%ebp)
  8014d9:	68 08 50 80 00       	push   $0x805008
  8014de:	e8 f3 f4 ff ff       	call   8009d6 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ed:	e8 ba fe ff ff       	call   8013ac <fsipc>
}
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <devfile_read>:
{
  8014f4:	f3 0f 1e fb          	endbr32 
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	56                   	push   %esi
  8014fc:	53                   	push   %ebx
  8014fd:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	8b 40 0c             	mov    0xc(%eax),%eax
  801506:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80150b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 03 00 00 00       	mov    $0x3,%eax
  80151b:	e8 8c fe ff ff       	call   8013ac <fsipc>
  801520:	89 c3                	mov    %eax,%ebx
  801522:	85 c0                	test   %eax,%eax
  801524:	78 1f                	js     801545 <devfile_read+0x51>
	assert(r <= n);
  801526:	39 f0                	cmp    %esi,%eax
  801528:	77 24                	ja     80154e <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80152a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80152f:	7f 36                	jg     801567 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	50                   	push   %eax
  801535:	68 00 50 80 00       	push   $0x805000
  80153a:	ff 75 0c             	pushl  0xc(%ebp)
  80153d:	e8 94 f4 ff ff       	call   8009d6 <memmove>
	return r;
  801542:	83 c4 10             	add    $0x10,%esp
}
  801545:	89 d8                	mov    %ebx,%eax
  801547:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    
	assert(r <= n);
  80154e:	68 d0 2d 80 00       	push   $0x802dd0
  801553:	68 d7 2d 80 00       	push   $0x802dd7
  801558:	68 8c 00 00 00       	push   $0x8c
  80155d:	68 ec 2d 80 00       	push   $0x802dec
  801562:	e8 80 eb ff ff       	call   8000e7 <_panic>
	assert(r <= PGSIZE);
  801567:	68 f7 2d 80 00       	push   $0x802df7
  80156c:	68 d7 2d 80 00       	push   $0x802dd7
  801571:	68 8d 00 00 00       	push   $0x8d
  801576:	68 ec 2d 80 00       	push   $0x802dec
  80157b:	e8 67 eb ff ff       	call   8000e7 <_panic>

00801580 <open>:
{
  801580:	f3 0f 1e fb          	endbr32 
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 1c             	sub    $0x1c,%esp
  80158c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80158f:	56                   	push   %esi
  801590:	e8 00 f2 ff ff       	call   800795 <strlen>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80159d:	7f 6c                	jg     80160b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	e8 5c f8 ff ff       	call   800e07 <fd_alloc>
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 3c                	js     8015f0 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	56                   	push   %esi
  8015b8:	68 00 50 80 00       	push   $0x805000
  8015bd:	e8 16 f2 ff ff       	call   8007d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d2:	e8 d5 fd ff ff       	call   8013ac <fsipc>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 19                	js     8015f9 <open+0x79>
	return fd2num(fd);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e6:	e8 ed f7 ff ff       	call   800dd8 <fd2num>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	83 c4 10             	add    $0x10,%esp
}
  8015f0:	89 d8                	mov    %ebx,%eax
  8015f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f5:	5b                   	pop    %ebx
  8015f6:	5e                   	pop    %esi
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    
		fd_close(fd, 0);
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	6a 00                	push   $0x0
  8015fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801601:	e8 0a f9 ff ff       	call   800f10 <fd_close>
		return r;
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	eb e5                	jmp    8015f0 <open+0x70>
		return -E_BAD_PATH;
  80160b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801610:	eb de                	jmp    8015f0 <open+0x70>

00801612 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801612:	f3 0f 1e fb          	endbr32 
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80161c:	ba 00 00 00 00       	mov    $0x0,%edx
  801621:	b8 08 00 00 00       	mov    $0x8,%eax
  801626:	e8 81 fd ff ff       	call   8013ac <fsipc>
}
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    

0080162d <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80162d:	f3 0f 1e fb          	endbr32 
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	57                   	push   %edi
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80163d:	6a 00                	push   $0x0
  80163f:	ff 75 08             	pushl  0x8(%ebp)
  801642:	e8 39 ff ff ff       	call   801580 <open>
  801647:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	85 c0                	test   %eax,%eax
  801652:	0f 88 b2 04 00 00    	js     801b0a <spawn+0x4dd>
  801658:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80165a:	83 ec 04             	sub    $0x4,%esp
  80165d:	68 00 02 00 00       	push   $0x200
  801662:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	51                   	push   %ecx
  80166a:	e8 01 fb ff ff       	call   801170 <readn>
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	3d 00 02 00 00       	cmp    $0x200,%eax
  801677:	75 7e                	jne    8016f7 <spawn+0xca>
	    || elf->e_magic != ELF_MAGIC) {
  801679:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801680:	45 4c 46 
  801683:	75 72                	jne    8016f7 <spawn+0xca>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801685:	b8 07 00 00 00       	mov    $0x7,%eax
  80168a:	cd 30                	int    $0x30
  80168c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801692:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801698:	85 c0                	test   %eax,%eax
  80169a:	0f 88 5e 04 00 00    	js     801afe <spawn+0x4d1>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016a5:	6b f0 7c             	imul   $0x7c,%eax,%esi
  8016a8:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016ae:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016b4:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016bb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016c1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8016cc:	be 00 00 00 00       	mov    $0x0,%esi
  8016d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016d4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  8016db:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	74 4d                	je     80172f <spawn+0x102>
		string_size += strlen(argv[argc]) + 1;
  8016e2:	83 ec 0c             	sub    $0xc,%esp
  8016e5:	50                   	push   %eax
  8016e6:	e8 aa f0 ff ff       	call   800795 <strlen>
  8016eb:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016ef:	83 c3 01             	add    $0x1,%ebx
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	eb dd                	jmp    8016d4 <spawn+0xa7>
		close(fd);
  8016f7:	83 ec 0c             	sub    $0xc,%esp
  8016fa:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801700:	e8 96 f8 ff ff       	call   800f9b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801705:	83 c4 0c             	add    $0xc,%esp
  801708:	68 7f 45 4c 46       	push   $0x464c457f
  80170d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801713:	68 63 2e 80 00       	push   $0x802e63
  801718:	e8 b1 ea ff ff       	call   8001ce <cprintf>
		return -E_NOT_EXEC;
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801727:	ff ff ff 
  80172a:	e9 db 03 00 00       	jmp    801b0a <spawn+0x4dd>
  80172f:	89 85 70 fd ff ff    	mov    %eax,-0x290(%ebp)
  801735:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  80173b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801741:	bf 00 10 40 00       	mov    $0x401000,%edi
  801746:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801748:	89 fa                	mov    %edi,%edx
  80174a:	83 e2 fc             	and    $0xfffffffc,%edx
  80174d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801754:	29 c2                	sub    %eax,%edx
  801756:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80175c:	8d 42 f8             	lea    -0x8(%edx),%eax
  80175f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801764:	0f 86 12 04 00 00    	jbe    801b7c <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80176a:	83 ec 04             	sub    $0x4,%esp
  80176d:	6a 07                	push   $0x7
  80176f:	68 00 00 40 00       	push   $0x400000
  801774:	6a 00                	push   $0x0
  801776:	e8 c6 f4 ff ff       	call   800c41 <sys_page_alloc>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	0f 88 fb 03 00 00    	js     801b81 <spawn+0x554>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801786:	be 00 00 00 00       	mov    $0x0,%esi
  80178b:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801791:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801794:	eb 30                	jmp    8017c6 <spawn+0x199>
		argv_store[i] = UTEMP2USTACK(string_store);
  801796:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80179c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8017a2:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ab:	57                   	push   %edi
  8017ac:	e8 27 f0 ff ff       	call   8007d8 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017b1:	83 c4 04             	add    $0x4,%esp
  8017b4:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017b7:	e8 d9 ef ff ff       	call   800795 <strlen>
  8017bc:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8017c0:	83 c6 01             	add    $0x1,%esi
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  8017cc:	7f c8                	jg     801796 <spawn+0x169>
	}
	argv_store[argc] = 0;
  8017ce:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8017d4:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017da:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017e1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017e7:	0f 85 88 00 00 00    	jne    801875 <spawn+0x248>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017ed:	8b 8d 90 fd ff ff    	mov    -0x270(%ebp),%ecx
  8017f3:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  8017f9:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8017fc:	89 c8                	mov    %ecx,%eax
  8017fe:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801804:	89 51 f8             	mov    %edx,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801807:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80180c:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	6a 07                	push   $0x7
  801817:	68 00 d0 bf ee       	push   $0xeebfd000
  80181c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801822:	68 00 00 40 00       	push   $0x400000
  801827:	6a 00                	push   $0x0
  801829:	e8 39 f4 ff ff       	call   800c67 <sys_page_map>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	83 c4 20             	add    $0x20,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	0f 88 4e 03 00 00    	js     801b89 <spawn+0x55c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	68 00 00 40 00       	push   $0x400000
  801843:	6a 00                	push   $0x0
  801845:	e8 42 f4 ff ff       	call   800c8c <sys_page_unmap>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	85 c0                	test   %eax,%eax
  801851:	0f 88 32 03 00 00    	js     801b89 <spawn+0x55c>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801857:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80185d:	8d b4 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%esi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801864:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  80186b:	00 00 00 
  80186e:	89 f7                	mov    %esi,%edi
  801870:	e9 4f 01 00 00       	jmp    8019c4 <spawn+0x397>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801875:	68 f0 2e 80 00       	push   $0x802ef0
  80187a:	68 d7 2d 80 00       	push   $0x802dd7
  80187f:	68 f1 00 00 00       	push   $0xf1
  801884:	68 7d 2e 80 00       	push   $0x802e7d
  801889:	e8 59 e8 ff ff       	call   8000e7 <_panic>
			// allocate a blank page bss segment
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80188e:	83 ec 04             	sub    $0x4,%esp
  801891:	6a 07                	push   $0x7
  801893:	68 00 00 40 00       	push   $0x400000
  801898:	6a 00                	push   $0x0
  80189a:	e8 a2 f3 ff ff       	call   800c41 <sys_page_alloc>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	0f 88 6e 02 00 00    	js     801b18 <spawn+0x4eb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018b3:	01 f8                	add    %edi,%eax
  8018b5:	50                   	push   %eax
  8018b6:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8018bc:	e8 80 f9 ff ff       	call   801241 <seek>
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	0f 88 53 02 00 00    	js     801b1f <spawn+0x4f2>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8018d5:	29 f8                	sub    %edi,%eax
  8018d7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018dc:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8018e1:	0f 47 c1             	cmova  %ecx,%eax
  8018e4:	50                   	push   %eax
  8018e5:	68 00 00 40 00       	push   $0x400000
  8018ea:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8018f0:	e8 7b f8 ff ff       	call   801170 <readn>
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	0f 88 26 02 00 00    	js     801b26 <spawn+0x4f9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801909:	53                   	push   %ebx
  80190a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801910:	68 00 00 40 00       	push   $0x400000
  801915:	6a 00                	push   $0x0
  801917:	e8 4b f3 ff ff       	call   800c67 <sys_page_map>
  80191c:	83 c4 20             	add    $0x20,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 7c                	js     80199f <spawn+0x372>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	68 00 00 40 00       	push   $0x400000
  80192b:	6a 00                	push   $0x0
  80192d:	e8 5a f3 ff ff       	call   800c8c <sys_page_unmap>
  801932:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801935:	81 c6 00 10 00 00    	add    $0x1000,%esi
  80193b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801941:	89 f7                	mov    %esi,%edi
  801943:	39 b5 7c fd ff ff    	cmp    %esi,-0x284(%ebp)
  801949:	76 69                	jbe    8019b4 <spawn+0x387>
		if (i >= filesz) {
  80194b:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801951:	0f 87 37 ff ff ff    	ja     80188e <spawn+0x261>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801960:	53                   	push   %ebx
  801961:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801967:	e8 d5 f2 ff ff       	call   800c41 <sys_page_alloc>
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	79 c2                	jns    801935 <spawn+0x308>
  801973:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80197e:	e8 54 f2 ff ff       	call   800bd7 <sys_env_destroy>
	close(fd);
  801983:	83 c4 04             	add    $0x4,%esp
  801986:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  80198c:	e8 0a f6 ff ff       	call   800f9b <close>
	return r;
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
  80199a:	e9 6b 01 00 00       	jmp    801b0a <spawn+0x4dd>
				panic("spawn: sys_page_map data: %e", r);
  80199f:	50                   	push   %eax
  8019a0:	68 89 2e 80 00       	push   $0x802e89
  8019a5:	68 24 01 00 00       	push   $0x124
  8019aa:	68 7d 2e 80 00       	push   $0x802e7d
  8019af:	e8 33 e7 ff ff       	call   8000e7 <_panic>
  8019b4:	8b bd 78 fd ff ff    	mov    -0x288(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019ba:	83 85 84 fd ff ff 01 	addl   $0x1,-0x27c(%ebp)
  8019c1:	83 c7 20             	add    $0x20,%edi
  8019c4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019cb:	3b 85 84 fd ff ff    	cmp    -0x27c(%ebp),%eax
  8019d1:	7e 6d                	jle    801a40 <spawn+0x413>
		if (ph->p_type != ELF_PROG_LOAD)
  8019d3:	83 3f 01             	cmpl   $0x1,(%edi)
  8019d6:	75 e2                	jne    8019ba <spawn+0x38d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8019d8:	8b 47 18             	mov    0x18(%edi),%eax
  8019db:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8019de:	83 f8 01             	cmp    $0x1,%eax
  8019e1:	19 c0                	sbb    %eax,%eax
  8019e3:	83 e0 fe             	and    $0xfffffffe,%eax
  8019e6:	83 c0 07             	add    $0x7,%eax
  8019e9:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8019ef:	8b 57 04             	mov    0x4(%edi),%edx
  8019f2:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  8019f8:	8b 4f 10             	mov    0x10(%edi),%ecx
  8019fb:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801a01:	8b 77 14             	mov    0x14(%edi),%esi
  801a04:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
  801a0a:	8b 5f 08             	mov    0x8(%edi),%ebx
	if ((i = PGOFF(va))) {
  801a0d:	89 d8                	mov    %ebx,%eax
  801a0f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a14:	74 1a                	je     801a30 <spawn+0x403>
		va -= i;
  801a16:	29 c3                	sub    %eax,%ebx
		memsz += i;
  801a18:	01 c6                	add    %eax,%esi
  801a1a:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
		filesz += i;
  801a20:	01 c1                	add    %eax,%ecx
  801a22:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		fileoffset -= i;
  801a28:	29 c2                	sub    %eax,%edx
  801a2a:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801a30:	be 00 00 00 00       	mov    $0x0,%esi
  801a35:	89 bd 78 fd ff ff    	mov    %edi,-0x288(%ebp)
  801a3b:	e9 01 ff ff ff       	jmp    801941 <spawn+0x314>
	close(fd);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801a49:	e8 4d f5 ff ff       	call   800f9b <close>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801a57:	8b 9d 70 fd ff ff    	mov    -0x290(%ebp),%ebx
  801a5d:	eb 12                	jmp    801a71 <spawn+0x444>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	void* addr; int r;
	for (addr = 0; addr<(void*)USTACKTOP; addr+=PGSIZE){
  801a5f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a65:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a6b:	0f 84 bc 00 00 00    	je     801b2d <spawn+0x500>
		if ((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_SHARE)){
  801a71:	89 d8                	mov    %ebx,%eax
  801a73:	c1 e8 16             	shr    $0x16,%eax
  801a76:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a7d:	a8 01                	test   $0x1,%al
  801a7f:	74 de                	je     801a5f <spawn+0x432>
  801a81:	89 d8                	mov    %ebx,%eax
  801a83:	c1 e8 0c             	shr    $0xc,%eax
  801a86:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a8d:	f6 c2 01             	test   $0x1,%dl
  801a90:	74 cd                	je     801a5f <spawn+0x432>
  801a92:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a99:	f6 c6 04             	test   $0x4,%dh
  801a9c:	74 c1                	je     801a5f <spawn+0x432>
			if ((r = sys_page_map(0, addr, child, addr, (uvpt[PGNUM(addr)]&PTE_SYSCALL)))<0)
  801a9e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	25 07 0e 00 00       	and    $0xe07,%eax
  801aad:	50                   	push   %eax
  801aae:	53                   	push   %ebx
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	6a 00                	push   $0x0
  801ab3:	e8 af f1 ff ff       	call   800c67 <sys_page_map>
  801ab8:	83 c4 20             	add    $0x20,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	79 a0                	jns    801a5f <spawn+0x432>
		panic("copy_shared_pages: %e", r);
  801abf:	50                   	push   %eax
  801ac0:	68 d7 2e 80 00       	push   $0x802ed7
  801ac5:	68 82 00 00 00       	push   $0x82
  801aca:	68 7d 2e 80 00       	push   $0x802e7d
  801acf:	e8 13 e6 ff ff       	call   8000e7 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801ad4:	50                   	push   %eax
  801ad5:	68 a6 2e 80 00       	push   $0x802ea6
  801ada:	68 86 00 00 00       	push   $0x86
  801adf:	68 7d 2e 80 00       	push   $0x802e7d
  801ae4:	e8 fe e5 ff ff       	call   8000e7 <_panic>
		panic("sys_env_set_status: %e", r);
  801ae9:	50                   	push   %eax
  801aea:	68 c0 2e 80 00       	push   $0x802ec0
  801aef:	68 89 00 00 00       	push   $0x89
  801af4:	68 7d 2e 80 00       	push   $0x802e7d
  801af9:	e8 e9 e5 ff ff       	call   8000e7 <_panic>
		return r;
  801afe:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b04:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801b0a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    
  801b18:	89 c7                	mov    %eax,%edi
  801b1a:	e9 56 fe ff ff       	jmp    801975 <spawn+0x348>
  801b1f:	89 c7                	mov    %eax,%edi
  801b21:	e9 4f fe ff ff       	jmp    801975 <spawn+0x348>
  801b26:	89 c7                	mov    %eax,%edi
  801b28:	e9 48 fe ff ff       	jmp    801975 <spawn+0x348>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b2d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b34:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b37:	83 ec 08             	sub    $0x8,%esp
  801b3a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b40:	50                   	push   %eax
  801b41:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b47:	e8 8a f1 ff ff       	call   800cd6 <sys_env_set_trapframe>
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 81                	js     801ad4 <spawn+0x4a7>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	6a 02                	push   $0x2
  801b58:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b5e:	e8 4e f1 ff ff       	call   800cb1 <sys_env_set_status>
  801b63:	83 c4 10             	add    $0x10,%esp
  801b66:	85 c0                	test   %eax,%eax
  801b68:	0f 88 7b ff ff ff    	js     801ae9 <spawn+0x4bc>
	return child;
  801b6e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b74:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b7a:	eb 8e                	jmp    801b0a <spawn+0x4dd>
		return -E_NO_MEM;
  801b7c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b81:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b87:	eb 81                	jmp    801b0a <spawn+0x4dd>
	sys_page_unmap(0, UTEMP);
  801b89:	83 ec 08             	sub    $0x8,%esp
  801b8c:	68 00 00 40 00       	push   $0x400000
  801b91:	6a 00                	push   $0x0
  801b93:	e8 f4 f0 ff ff       	call   800c8c <sys_page_unmap>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801ba1:	e9 64 ff ff ff       	jmp    801b0a <spawn+0x4dd>

00801ba6 <spawnl>:
{
  801ba6:	f3 0f 1e fb          	endbr32 
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	57                   	push   %edi
  801bae:	56                   	push   %esi
  801baf:	53                   	push   %ebx
  801bb0:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801bb3:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801bbb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801bbe:	83 3a 00             	cmpl   $0x0,(%edx)
  801bc1:	74 07                	je     801bca <spawnl+0x24>
		argc++;
  801bc3:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801bc6:	89 ca                	mov    %ecx,%edx
  801bc8:	eb f1                	jmp    801bbb <spawnl+0x15>
	const char *argv[argc+2];
  801bca:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801bd1:	89 d1                	mov    %edx,%ecx
  801bd3:	83 e1 f0             	and    $0xfffffff0,%ecx
  801bd6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801bdc:	89 e6                	mov    %esp,%esi
  801bde:	29 d6                	sub    %edx,%esi
  801be0:	89 f2                	mov    %esi,%edx
  801be2:	39 d4                	cmp    %edx,%esp
  801be4:	74 10                	je     801bf6 <spawnl+0x50>
  801be6:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801bec:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801bf3:	00 
  801bf4:	eb ec                	jmp    801be2 <spawnl+0x3c>
  801bf6:	89 ca                	mov    %ecx,%edx
  801bf8:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801bfe:	29 d4                	sub    %edx,%esp
  801c00:	85 d2                	test   %edx,%edx
  801c02:	74 05                	je     801c09 <spawnl+0x63>
  801c04:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801c09:	8d 74 24 03          	lea    0x3(%esp),%esi
  801c0d:	89 f2                	mov    %esi,%edx
  801c0f:	c1 ea 02             	shr    $0x2,%edx
  801c12:	83 e6 fc             	and    $0xfffffffc,%esi
  801c15:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c21:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c28:	00 
	va_start(vl, arg0);
  801c29:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801c2c:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c33:	eb 0b                	jmp    801c40 <spawnl+0x9a>
		argv[i+1] = va_arg(vl, const char *);
  801c35:	83 c0 01             	add    $0x1,%eax
  801c38:	8b 39                	mov    (%ecx),%edi
  801c3a:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801c3d:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801c40:	39 d0                	cmp    %edx,%eax
  801c42:	75 f1                	jne    801c35 <spawnl+0x8f>
	return spawn(prog, argv);
  801c44:	83 ec 08             	sub    $0x8,%esp
  801c47:	56                   	push   %esi
  801c48:	ff 75 08             	pushl  0x8(%ebp)
  801c4b:	e8 dd f9 ff ff       	call   80162d <spawn>
}
  801c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c58:	f3 0f 1e fb          	endbr32 
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c62:	68 16 2f 80 00       	push   $0x802f16
  801c67:	ff 75 0c             	pushl  0xc(%ebp)
  801c6a:	e8 69 eb ff ff       	call   8007d8 <strcpy>
	return 0;
}
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <devsock_close>:
{
  801c76:	f3 0f 1e fb          	endbr32 
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 10             	sub    $0x10,%esp
  801c81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c84:	53                   	push   %ebx
  801c85:	e8 83 0a 00 00       	call   80270d <pageref>
  801c8a:	89 c2                	mov    %eax,%edx
  801c8c:	83 c4 10             	add    $0x10,%esp
		return 0;
  801c8f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801c94:	83 fa 01             	cmp    $0x1,%edx
  801c97:	74 05                	je     801c9e <devsock_close+0x28>
}
  801c99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801c9e:	83 ec 0c             	sub    $0xc,%esp
  801ca1:	ff 73 0c             	pushl  0xc(%ebx)
  801ca4:	e8 e3 02 00 00       	call   801f8c <nsipc_close>
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	eb eb                	jmp    801c99 <devsock_close+0x23>

00801cae <devsock_write>:
{
  801cae:	f3 0f 1e fb          	endbr32 
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cb8:	6a 00                	push   $0x0
  801cba:	ff 75 10             	pushl  0x10(%ebp)
  801cbd:	ff 75 0c             	pushl  0xc(%ebp)
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc3:	ff 70 0c             	pushl  0xc(%eax)
  801cc6:	e8 b5 03 00 00       	call   802080 <nsipc_send>
}
  801ccb:	c9                   	leave  
  801ccc:	c3                   	ret    

00801ccd <devsock_read>:
{
  801ccd:	f3 0f 1e fb          	endbr32 
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cd7:	6a 00                	push   $0x0
  801cd9:	ff 75 10             	pushl  0x10(%ebp)
  801cdc:	ff 75 0c             	pushl  0xc(%ebp)
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	ff 70 0c             	pushl  0xc(%eax)
  801ce5:	e8 1f 03 00 00       	call   802009 <nsipc_recv>
}
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <fd2sockid>:
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cf2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cf5:	52                   	push   %edx
  801cf6:	50                   	push   %eax
  801cf7:	e8 61 f1 ff ff       	call   800e5d <fd_lookup>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 10                	js     801d13 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d06:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801d0c:	39 08                	cmp    %ecx,(%eax)
  801d0e:	75 05                	jne    801d15 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801d10:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    
		return -E_NOT_SUPP;
  801d15:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d1a:	eb f7                	jmp    801d13 <fd2sockid+0x27>

00801d1c <alloc_sockfd>:
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	56                   	push   %esi
  801d20:	53                   	push   %ebx
  801d21:	83 ec 1c             	sub    $0x1c,%esp
  801d24:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801d26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	e8 d8 f0 ff ff       	call   800e07 <fd_alloc>
  801d2f:	89 c3                	mov    %eax,%ebx
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	78 43                	js     801d7b <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d38:	83 ec 04             	sub    $0x4,%esp
  801d3b:	68 07 04 00 00       	push   $0x407
  801d40:	ff 75 f4             	pushl  -0xc(%ebp)
  801d43:	6a 00                	push   $0x0
  801d45:	e8 f7 ee ff ff       	call   800c41 <sys_page_alloc>
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 28                	js     801d7b <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d56:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801d5c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d61:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d68:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d6b:	83 ec 0c             	sub    $0xc,%esp
  801d6e:	50                   	push   %eax
  801d6f:	e8 64 f0 ff ff       	call   800dd8 <fd2num>
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	eb 0c                	jmp    801d87 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801d7b:	83 ec 0c             	sub    $0xc,%esp
  801d7e:	56                   	push   %esi
  801d7f:	e8 08 02 00 00       	call   801f8c <nsipc_close>
		return r;
  801d84:	83 c4 10             	add    $0x10,%esp
}
  801d87:	89 d8                	mov    %ebx,%eax
  801d89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8c:	5b                   	pop    %ebx
  801d8d:	5e                   	pop    %esi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    

00801d90 <accept>:
{
  801d90:	f3 0f 1e fb          	endbr32 
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9d:	e8 4a ff ff ff       	call   801cec <fd2sockid>
  801da2:	85 c0                	test   %eax,%eax
  801da4:	78 1b                	js     801dc1 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801da6:	83 ec 04             	sub    $0x4,%esp
  801da9:	ff 75 10             	pushl  0x10(%ebp)
  801dac:	ff 75 0c             	pushl  0xc(%ebp)
  801daf:	50                   	push   %eax
  801db0:	e8 22 01 00 00       	call   801ed7 <nsipc_accept>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 05                	js     801dc1 <accept+0x31>
	return alloc_sockfd(r);
  801dbc:	e8 5b ff ff ff       	call   801d1c <alloc_sockfd>
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <bind>:
{
  801dc3:	f3 0f 1e fb          	endbr32 
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	e8 17 ff ff ff       	call   801cec <fd2sockid>
  801dd5:	85 c0                	test   %eax,%eax
  801dd7:	78 12                	js     801deb <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	ff 75 10             	pushl  0x10(%ebp)
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	50                   	push   %eax
  801de3:	e8 45 01 00 00       	call   801f2d <nsipc_bind>
  801de8:	83 c4 10             	add    $0x10,%esp
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <shutdown>:
{
  801ded:	f3 0f 1e fb          	endbr32 
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801df7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfa:	e8 ed fe ff ff       	call   801cec <fd2sockid>
  801dff:	85 c0                	test   %eax,%eax
  801e01:	78 0f                	js     801e12 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801e03:	83 ec 08             	sub    $0x8,%esp
  801e06:	ff 75 0c             	pushl  0xc(%ebp)
  801e09:	50                   	push   %eax
  801e0a:	e8 57 01 00 00       	call   801f66 <nsipc_shutdown>
  801e0f:	83 c4 10             	add    $0x10,%esp
}
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <connect>:
{
  801e14:	f3 0f 1e fb          	endbr32 
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	e8 c6 fe ff ff       	call   801cec <fd2sockid>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	78 12                	js     801e3c <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	ff 75 10             	pushl  0x10(%ebp)
  801e30:	ff 75 0c             	pushl  0xc(%ebp)
  801e33:	50                   	push   %eax
  801e34:	e8 71 01 00 00       	call   801faa <nsipc_connect>
  801e39:	83 c4 10             	add    $0x10,%esp
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <listen>:
{
  801e3e:	f3 0f 1e fb          	endbr32 
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e48:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4b:	e8 9c fe ff ff       	call   801cec <fd2sockid>
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 0f                	js     801e63 <listen+0x25>
	return nsipc_listen(r, backlog);
  801e54:	83 ec 08             	sub    $0x8,%esp
  801e57:	ff 75 0c             	pushl  0xc(%ebp)
  801e5a:	50                   	push   %eax
  801e5b:	e8 83 01 00 00       	call   801fe3 <nsipc_listen>
  801e60:	83 c4 10             	add    $0x10,%esp
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <socket>:

int
socket(int domain, int type, int protocol)
{
  801e65:	f3 0f 1e fb          	endbr32 
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e6f:	ff 75 10             	pushl  0x10(%ebp)
  801e72:	ff 75 0c             	pushl  0xc(%ebp)
  801e75:	ff 75 08             	pushl  0x8(%ebp)
  801e78:	e8 65 02 00 00       	call   8020e2 <nsipc_socket>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 05                	js     801e89 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801e84:	e8 93 fe ff ff       	call   801d1c <alloc_sockfd>
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	53                   	push   %ebx
  801e8f:	83 ec 04             	sub    $0x4,%esp
  801e92:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e94:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e9b:	74 26                	je     801ec3 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e9d:	6a 07                	push   $0x7
  801e9f:	68 00 60 80 00       	push   $0x806000
  801ea4:	53                   	push   %ebx
  801ea5:	ff 35 04 40 80 00    	pushl  0x804004
  801eab:	e8 c8 07 00 00       	call   802678 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801eb0:	83 c4 0c             	add    $0xc,%esp
  801eb3:	6a 00                	push   $0x0
  801eb5:	6a 00                	push   $0x0
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 4d 07 00 00       	call   80260b <ipc_recv>
}
  801ebe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	6a 02                	push   $0x2
  801ec8:	e8 03 08 00 00       	call   8026d0 <ipc_find_env>
  801ecd:	a3 04 40 80 00       	mov    %eax,0x804004
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	eb c6                	jmp    801e9d <nsipc+0x12>

00801ed7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ed7:	f3 0f 1e fb          	endbr32 
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
  801ee0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801eeb:	8b 06                	mov    (%esi),%eax
  801eed:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef7:	e8 8f ff ff ff       	call   801e8b <nsipc>
  801efc:	89 c3                	mov    %eax,%ebx
  801efe:	85 c0                	test   %eax,%eax
  801f00:	79 09                	jns    801f0b <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801f02:	89 d8                	mov    %ebx,%eax
  801f04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f0b:	83 ec 04             	sub    $0x4,%esp
  801f0e:	ff 35 10 60 80 00    	pushl  0x806010
  801f14:	68 00 60 80 00       	push   $0x806000
  801f19:	ff 75 0c             	pushl  0xc(%ebp)
  801f1c:	e8 b5 ea ff ff       	call   8009d6 <memmove>
		*addrlen = ret->ret_addrlen;
  801f21:	a1 10 60 80 00       	mov    0x806010,%eax
  801f26:	89 06                	mov    %eax,(%esi)
  801f28:	83 c4 10             	add    $0x10,%esp
	return r;
  801f2b:	eb d5                	jmp    801f02 <nsipc_accept+0x2b>

00801f2d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f2d:	f3 0f 1e fb          	endbr32 
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	53                   	push   %ebx
  801f35:	83 ec 08             	sub    $0x8,%esp
  801f38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f43:	53                   	push   %ebx
  801f44:	ff 75 0c             	pushl  0xc(%ebp)
  801f47:	68 04 60 80 00       	push   $0x806004
  801f4c:	e8 85 ea ff ff       	call   8009d6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f51:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f57:	b8 02 00 00 00       	mov    $0x2,%eax
  801f5c:	e8 2a ff ff ff       	call   801e8b <nsipc>
}
  801f61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f64:	c9                   	leave  
  801f65:	c3                   	ret    

00801f66 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f66:	f3 0f 1e fb          	endbr32 
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f70:	8b 45 08             	mov    0x8(%ebp),%eax
  801f73:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f80:	b8 03 00 00 00       	mov    $0x3,%eax
  801f85:	e8 01 ff ff ff       	call   801e8b <nsipc>
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <nsipc_close>:

int
nsipc_close(int s)
{
  801f8c:	f3 0f 1e fb          	endbr32 
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f9e:	b8 04 00 00 00       	mov    $0x4,%eax
  801fa3:	e8 e3 fe ff ff       	call   801e8b <nsipc>
}
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801faa:	f3 0f 1e fb          	endbr32 
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	53                   	push   %ebx
  801fb2:	83 ec 08             	sub    $0x8,%esp
  801fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fc0:	53                   	push   %ebx
  801fc1:	ff 75 0c             	pushl  0xc(%ebp)
  801fc4:	68 04 60 80 00       	push   $0x806004
  801fc9:	e8 08 ea ff ff       	call   8009d6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fce:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fd4:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd9:	e8 ad fe ff ff       	call   801e8b <nsipc>
}
  801fde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fe3:	f3 0f 1e fb          	endbr32 
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ffd:	b8 06 00 00 00       	mov    $0x6,%eax
  802002:	e8 84 fe ff ff       	call   801e8b <nsipc>
}
  802007:	c9                   	leave  
  802008:	c3                   	ret    

00802009 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802009:	f3 0f 1e fb          	endbr32 
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	56                   	push   %esi
  802011:	53                   	push   %ebx
  802012:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802015:	8b 45 08             	mov    0x8(%ebp),%eax
  802018:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80201d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802023:	8b 45 14             	mov    0x14(%ebp),%eax
  802026:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80202b:	b8 07 00 00 00       	mov    $0x7,%eax
  802030:	e8 56 fe ff ff       	call   801e8b <nsipc>
  802035:	89 c3                	mov    %eax,%ebx
  802037:	85 c0                	test   %eax,%eax
  802039:	78 26                	js     802061 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  80203b:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  802041:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802046:	0f 4e c6             	cmovle %esi,%eax
  802049:	39 c3                	cmp    %eax,%ebx
  80204b:	7f 1d                	jg     80206a <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80204d:	83 ec 04             	sub    $0x4,%esp
  802050:	53                   	push   %ebx
  802051:	68 00 60 80 00       	push   $0x806000
  802056:	ff 75 0c             	pushl  0xc(%ebp)
  802059:	e8 78 e9 ff ff       	call   8009d6 <memmove>
  80205e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802061:	89 d8                	mov    %ebx,%eax
  802063:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802066:	5b                   	pop    %ebx
  802067:	5e                   	pop    %esi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80206a:	68 22 2f 80 00       	push   $0x802f22
  80206f:	68 d7 2d 80 00       	push   $0x802dd7
  802074:	6a 62                	push   $0x62
  802076:	68 37 2f 80 00       	push   $0x802f37
  80207b:	e8 67 e0 ff ff       	call   8000e7 <_panic>

00802080 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802080:	f3 0f 1e fb          	endbr32 
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	53                   	push   %ebx
  802088:	83 ec 04             	sub    $0x4,%esp
  80208b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802096:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80209c:	7f 2e                	jg     8020cc <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80209e:	83 ec 04             	sub    $0x4,%esp
  8020a1:	53                   	push   %ebx
  8020a2:	ff 75 0c             	pushl  0xc(%ebp)
  8020a5:	68 0c 60 80 00       	push   $0x80600c
  8020aa:	e8 27 e9 ff ff       	call   8009d6 <memmove>
	nsipcbuf.send.req_size = size;
  8020af:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8020c2:	e8 c4 fd ff ff       	call   801e8b <nsipc>
}
  8020c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    
	assert(size < 1600);
  8020cc:	68 43 2f 80 00       	push   $0x802f43
  8020d1:	68 d7 2d 80 00       	push   $0x802dd7
  8020d6:	6a 6d                	push   $0x6d
  8020d8:	68 37 2f 80 00       	push   $0x802f37
  8020dd:	e8 05 e0 ff ff       	call   8000e7 <_panic>

008020e2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020e2:	f3 0f 1e fb          	endbr32 
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ff:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802104:	b8 09 00 00 00       	mov    $0x9,%eax
  802109:	e8 7d fd ff ff       	call   801e8b <nsipc>
}
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	56                   	push   %esi
  802118:	53                   	push   %ebx
  802119:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80211c:	83 ec 0c             	sub    $0xc,%esp
  80211f:	ff 75 08             	pushl  0x8(%ebp)
  802122:	e8 c5 ec ff ff       	call   800dec <fd2data>
  802127:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802129:	83 c4 08             	add    $0x8,%esp
  80212c:	68 4f 2f 80 00       	push   $0x802f4f
  802131:	53                   	push   %ebx
  802132:	e8 a1 e6 ff ff       	call   8007d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802137:	8b 46 04             	mov    0x4(%esi),%eax
  80213a:	2b 06                	sub    (%esi),%eax
  80213c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802142:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802149:	00 00 00 
	stat->st_dev = &devpipe;
  80214c:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  802153:	30 80 00 
	return 0;
}
  802156:	b8 00 00 00 00       	mov    $0x0,%eax
  80215b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215e:	5b                   	pop    %ebx
  80215f:	5e                   	pop    %esi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    

00802162 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802162:	f3 0f 1e fb          	endbr32 
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	53                   	push   %ebx
  80216a:	83 ec 0c             	sub    $0xc,%esp
  80216d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802170:	53                   	push   %ebx
  802171:	6a 00                	push   $0x0
  802173:	e8 14 eb ff ff       	call   800c8c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802178:	89 1c 24             	mov    %ebx,(%esp)
  80217b:	e8 6c ec ff ff       	call   800dec <fd2data>
  802180:	83 c4 08             	add    $0x8,%esp
  802183:	50                   	push   %eax
  802184:	6a 00                	push   $0x0
  802186:	e8 01 eb ff ff       	call   800c8c <sys_page_unmap>
}
  80218b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <_pipeisclosed>:
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	57                   	push   %edi
  802194:	56                   	push   %esi
  802195:	53                   	push   %ebx
  802196:	83 ec 1c             	sub    $0x1c,%esp
  802199:	89 c7                	mov    %eax,%edi
  80219b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80219d:	a1 08 40 80 00       	mov    0x804008,%eax
  8021a2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021a5:	83 ec 0c             	sub    $0xc,%esp
  8021a8:	57                   	push   %edi
  8021a9:	e8 5f 05 00 00       	call   80270d <pageref>
  8021ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021b1:	89 34 24             	mov    %esi,(%esp)
  8021b4:	e8 54 05 00 00       	call   80270d <pageref>
		nn = thisenv->env_runs;
  8021b9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021bf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021c2:	83 c4 10             	add    $0x10,%esp
  8021c5:	39 cb                	cmp    %ecx,%ebx
  8021c7:	74 1b                	je     8021e4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8021c9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021cc:	75 cf                	jne    80219d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021ce:	8b 42 58             	mov    0x58(%edx),%eax
  8021d1:	6a 01                	push   $0x1
  8021d3:	50                   	push   %eax
  8021d4:	53                   	push   %ebx
  8021d5:	68 56 2f 80 00       	push   $0x802f56
  8021da:	e8 ef df ff ff       	call   8001ce <cprintf>
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	eb b9                	jmp    80219d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8021e4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021e7:	0f 94 c0             	sete   %al
  8021ea:	0f b6 c0             	movzbl %al,%eax
}
  8021ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <devpipe_write>:
{
  8021f5:	f3 0f 1e fb          	endbr32 
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	57                   	push   %edi
  8021fd:	56                   	push   %esi
  8021fe:	53                   	push   %ebx
  8021ff:	83 ec 28             	sub    $0x28,%esp
  802202:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802205:	56                   	push   %esi
  802206:	e8 e1 eb ff ff       	call   800dec <fd2data>
  80220b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80220d:	83 c4 10             	add    $0x10,%esp
  802210:	bf 00 00 00 00       	mov    $0x0,%edi
  802215:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802218:	74 4f                	je     802269 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80221a:	8b 43 04             	mov    0x4(%ebx),%eax
  80221d:	8b 0b                	mov    (%ebx),%ecx
  80221f:	8d 51 20             	lea    0x20(%ecx),%edx
  802222:	39 d0                	cmp    %edx,%eax
  802224:	72 14                	jb     80223a <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802226:	89 da                	mov    %ebx,%edx
  802228:	89 f0                	mov    %esi,%eax
  80222a:	e8 61 ff ff ff       	call   802190 <_pipeisclosed>
  80222f:	85 c0                	test   %eax,%eax
  802231:	75 3b                	jne    80226e <devpipe_write+0x79>
			sys_yield();
  802233:	e8 e6 e9 ff ff       	call   800c1e <sys_yield>
  802238:	eb e0                	jmp    80221a <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80223a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80223d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802241:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802244:	89 c2                	mov    %eax,%edx
  802246:	c1 fa 1f             	sar    $0x1f,%edx
  802249:	89 d1                	mov    %edx,%ecx
  80224b:	c1 e9 1b             	shr    $0x1b,%ecx
  80224e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802251:	83 e2 1f             	and    $0x1f,%edx
  802254:	29 ca                	sub    %ecx,%edx
  802256:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80225a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80225e:	83 c0 01             	add    $0x1,%eax
  802261:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802264:	83 c7 01             	add    $0x1,%edi
  802267:	eb ac                	jmp    802215 <devpipe_write+0x20>
	return i;
  802269:	8b 45 10             	mov    0x10(%ebp),%eax
  80226c:	eb 05                	jmp    802273 <devpipe_write+0x7e>
				return 0;
  80226e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802276:	5b                   	pop    %ebx
  802277:	5e                   	pop    %esi
  802278:	5f                   	pop    %edi
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    

0080227b <devpipe_read>:
{
  80227b:	f3 0f 1e fb          	endbr32 
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	57                   	push   %edi
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	83 ec 18             	sub    $0x18,%esp
  802288:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80228b:	57                   	push   %edi
  80228c:	e8 5b eb ff ff       	call   800dec <fd2data>
  802291:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802293:	83 c4 10             	add    $0x10,%esp
  802296:	be 00 00 00 00       	mov    $0x0,%esi
  80229b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80229e:	75 14                	jne    8022b4 <devpipe_read+0x39>
	return i;
  8022a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8022a3:	eb 02                	jmp    8022a7 <devpipe_read+0x2c>
				return i;
  8022a5:	89 f0                	mov    %esi,%eax
}
  8022a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022aa:	5b                   	pop    %ebx
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    
			sys_yield();
  8022af:	e8 6a e9 ff ff       	call   800c1e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8022b4:	8b 03                	mov    (%ebx),%eax
  8022b6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022b9:	75 18                	jne    8022d3 <devpipe_read+0x58>
			if (i > 0)
  8022bb:	85 f6                	test   %esi,%esi
  8022bd:	75 e6                	jne    8022a5 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8022bf:	89 da                	mov    %ebx,%edx
  8022c1:	89 f8                	mov    %edi,%eax
  8022c3:	e8 c8 fe ff ff       	call   802190 <_pipeisclosed>
  8022c8:	85 c0                	test   %eax,%eax
  8022ca:	74 e3                	je     8022af <devpipe_read+0x34>
				return 0;
  8022cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d1:	eb d4                	jmp    8022a7 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022d3:	99                   	cltd   
  8022d4:	c1 ea 1b             	shr    $0x1b,%edx
  8022d7:	01 d0                	add    %edx,%eax
  8022d9:	83 e0 1f             	and    $0x1f,%eax
  8022dc:	29 d0                	sub    %edx,%eax
  8022de:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8022e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022e6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8022e9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8022ec:	83 c6 01             	add    $0x1,%esi
  8022ef:	eb aa                	jmp    80229b <devpipe_read+0x20>

008022f1 <pipe>:
{
  8022f1:	f3 0f 1e fb          	endbr32 
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	56                   	push   %esi
  8022f9:	53                   	push   %ebx
  8022fa:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8022fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802300:	50                   	push   %eax
  802301:	e8 01 eb ff ff       	call   800e07 <fd_alloc>
  802306:	89 c3                	mov    %eax,%ebx
  802308:	83 c4 10             	add    $0x10,%esp
  80230b:	85 c0                	test   %eax,%eax
  80230d:	0f 88 23 01 00 00    	js     802436 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802313:	83 ec 04             	sub    $0x4,%esp
  802316:	68 07 04 00 00       	push   $0x407
  80231b:	ff 75 f4             	pushl  -0xc(%ebp)
  80231e:	6a 00                	push   $0x0
  802320:	e8 1c e9 ff ff       	call   800c41 <sys_page_alloc>
  802325:	89 c3                	mov    %eax,%ebx
  802327:	83 c4 10             	add    $0x10,%esp
  80232a:	85 c0                	test   %eax,%eax
  80232c:	0f 88 04 01 00 00    	js     802436 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802332:	83 ec 0c             	sub    $0xc,%esp
  802335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802338:	50                   	push   %eax
  802339:	e8 c9 ea ff ff       	call   800e07 <fd_alloc>
  80233e:	89 c3                	mov    %eax,%ebx
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	85 c0                	test   %eax,%eax
  802345:	0f 88 db 00 00 00    	js     802426 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80234b:	83 ec 04             	sub    $0x4,%esp
  80234e:	68 07 04 00 00       	push   $0x407
  802353:	ff 75 f0             	pushl  -0x10(%ebp)
  802356:	6a 00                	push   $0x0
  802358:	e8 e4 e8 ff ff       	call   800c41 <sys_page_alloc>
  80235d:	89 c3                	mov    %eax,%ebx
  80235f:	83 c4 10             	add    $0x10,%esp
  802362:	85 c0                	test   %eax,%eax
  802364:	0f 88 bc 00 00 00    	js     802426 <pipe+0x135>
	va = fd2data(fd0);
  80236a:	83 ec 0c             	sub    $0xc,%esp
  80236d:	ff 75 f4             	pushl  -0xc(%ebp)
  802370:	e8 77 ea ff ff       	call   800dec <fd2data>
  802375:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802377:	83 c4 0c             	add    $0xc,%esp
  80237a:	68 07 04 00 00       	push   $0x407
  80237f:	50                   	push   %eax
  802380:	6a 00                	push   $0x0
  802382:	e8 ba e8 ff ff       	call   800c41 <sys_page_alloc>
  802387:	89 c3                	mov    %eax,%ebx
  802389:	83 c4 10             	add    $0x10,%esp
  80238c:	85 c0                	test   %eax,%eax
  80238e:	0f 88 82 00 00 00    	js     802416 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802394:	83 ec 0c             	sub    $0xc,%esp
  802397:	ff 75 f0             	pushl  -0x10(%ebp)
  80239a:	e8 4d ea ff ff       	call   800dec <fd2data>
  80239f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023a6:	50                   	push   %eax
  8023a7:	6a 00                	push   $0x0
  8023a9:	56                   	push   %esi
  8023aa:	6a 00                	push   $0x0
  8023ac:	e8 b6 e8 ff ff       	call   800c67 <sys_page_map>
  8023b1:	89 c3                	mov    %eax,%ebx
  8023b3:	83 c4 20             	add    $0x20,%esp
  8023b6:	85 c0                	test   %eax,%eax
  8023b8:	78 4e                	js     802408 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8023ba:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8023bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023c2:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8023c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023c7:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8023ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023d1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8023d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023d6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8023dd:	83 ec 0c             	sub    $0xc,%esp
  8023e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023e3:	e8 f0 e9 ff ff       	call   800dd8 <fd2num>
  8023e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023eb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023ed:	83 c4 04             	add    $0x4,%esp
  8023f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8023f3:	e8 e0 e9 ff ff       	call   800dd8 <fd2num>
  8023f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023fb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023fe:	83 c4 10             	add    $0x10,%esp
  802401:	bb 00 00 00 00       	mov    $0x0,%ebx
  802406:	eb 2e                	jmp    802436 <pipe+0x145>
	sys_page_unmap(0, va);
  802408:	83 ec 08             	sub    $0x8,%esp
  80240b:	56                   	push   %esi
  80240c:	6a 00                	push   $0x0
  80240e:	e8 79 e8 ff ff       	call   800c8c <sys_page_unmap>
  802413:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802416:	83 ec 08             	sub    $0x8,%esp
  802419:	ff 75 f0             	pushl  -0x10(%ebp)
  80241c:	6a 00                	push   $0x0
  80241e:	e8 69 e8 ff ff       	call   800c8c <sys_page_unmap>
  802423:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802426:	83 ec 08             	sub    $0x8,%esp
  802429:	ff 75 f4             	pushl  -0xc(%ebp)
  80242c:	6a 00                	push   $0x0
  80242e:	e8 59 e8 ff ff       	call   800c8c <sys_page_unmap>
  802433:	83 c4 10             	add    $0x10,%esp
}
  802436:	89 d8                	mov    %ebx,%eax
  802438:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80243b:	5b                   	pop    %ebx
  80243c:	5e                   	pop    %esi
  80243d:	5d                   	pop    %ebp
  80243e:	c3                   	ret    

0080243f <pipeisclosed>:
{
  80243f:	f3 0f 1e fb          	endbr32 
  802443:	55                   	push   %ebp
  802444:	89 e5                	mov    %esp,%ebp
  802446:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80244c:	50                   	push   %eax
  80244d:	ff 75 08             	pushl  0x8(%ebp)
  802450:	e8 08 ea ff ff       	call   800e5d <fd_lookup>
  802455:	83 c4 10             	add    $0x10,%esp
  802458:	85 c0                	test   %eax,%eax
  80245a:	78 18                	js     802474 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80245c:	83 ec 0c             	sub    $0xc,%esp
  80245f:	ff 75 f4             	pushl  -0xc(%ebp)
  802462:	e8 85 e9 ff ff       	call   800dec <fd2data>
  802467:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246c:	e8 1f fd ff ff       	call   802190 <_pipeisclosed>
  802471:	83 c4 10             	add    $0x10,%esp
}
  802474:	c9                   	leave  
  802475:	c3                   	ret    

00802476 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802476:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80247a:	b8 00 00 00 00       	mov    $0x0,%eax
  80247f:	c3                   	ret    

00802480 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802480:	f3 0f 1e fb          	endbr32 
  802484:	55                   	push   %ebp
  802485:	89 e5                	mov    %esp,%ebp
  802487:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80248a:	68 6e 2f 80 00       	push   $0x802f6e
  80248f:	ff 75 0c             	pushl  0xc(%ebp)
  802492:	e8 41 e3 ff ff       	call   8007d8 <strcpy>
	return 0;
}
  802497:	b8 00 00 00 00       	mov    $0x0,%eax
  80249c:	c9                   	leave  
  80249d:	c3                   	ret    

0080249e <devcons_write>:
{
  80249e:	f3 0f 1e fb          	endbr32 
  8024a2:	55                   	push   %ebp
  8024a3:	89 e5                	mov    %esp,%ebp
  8024a5:	57                   	push   %edi
  8024a6:	56                   	push   %esi
  8024a7:	53                   	push   %ebx
  8024a8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8024ae:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8024b3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8024b9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024bc:	73 31                	jae    8024ef <devcons_write+0x51>
		m = n - tot;
  8024be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024c1:	29 f3                	sub    %esi,%ebx
  8024c3:	83 fb 7f             	cmp    $0x7f,%ebx
  8024c6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8024cb:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8024ce:	83 ec 04             	sub    $0x4,%esp
  8024d1:	53                   	push   %ebx
  8024d2:	89 f0                	mov    %esi,%eax
  8024d4:	03 45 0c             	add    0xc(%ebp),%eax
  8024d7:	50                   	push   %eax
  8024d8:	57                   	push   %edi
  8024d9:	e8 f8 e4 ff ff       	call   8009d6 <memmove>
		sys_cputs(buf, m);
  8024de:	83 c4 08             	add    $0x8,%esp
  8024e1:	53                   	push   %ebx
  8024e2:	57                   	push   %edi
  8024e3:	e8 aa e6 ff ff       	call   800b92 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8024e8:	01 de                	add    %ebx,%esi
  8024ea:	83 c4 10             	add    $0x10,%esp
  8024ed:	eb ca                	jmp    8024b9 <devcons_write+0x1b>
}
  8024ef:	89 f0                	mov    %esi,%eax
  8024f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024f4:	5b                   	pop    %ebx
  8024f5:	5e                   	pop    %esi
  8024f6:	5f                   	pop    %edi
  8024f7:	5d                   	pop    %ebp
  8024f8:	c3                   	ret    

008024f9 <devcons_read>:
{
  8024f9:	f3 0f 1e fb          	endbr32 
  8024fd:	55                   	push   %ebp
  8024fe:	89 e5                	mov    %esp,%ebp
  802500:	83 ec 08             	sub    $0x8,%esp
  802503:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802508:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80250c:	74 21                	je     80252f <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80250e:	e8 a1 e6 ff ff       	call   800bb4 <sys_cgetc>
  802513:	85 c0                	test   %eax,%eax
  802515:	75 07                	jne    80251e <devcons_read+0x25>
		sys_yield();
  802517:	e8 02 e7 ff ff       	call   800c1e <sys_yield>
  80251c:	eb f0                	jmp    80250e <devcons_read+0x15>
	if (c < 0)
  80251e:	78 0f                	js     80252f <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802520:	83 f8 04             	cmp    $0x4,%eax
  802523:	74 0c                	je     802531 <devcons_read+0x38>
	*(char*)vbuf = c;
  802525:	8b 55 0c             	mov    0xc(%ebp),%edx
  802528:	88 02                	mov    %al,(%edx)
	return 1;
  80252a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80252f:	c9                   	leave  
  802530:	c3                   	ret    
		return 0;
  802531:	b8 00 00 00 00       	mov    $0x0,%eax
  802536:	eb f7                	jmp    80252f <devcons_read+0x36>

00802538 <cputchar>:
{
  802538:	f3 0f 1e fb          	endbr32 
  80253c:	55                   	push   %ebp
  80253d:	89 e5                	mov    %esp,%ebp
  80253f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802542:	8b 45 08             	mov    0x8(%ebp),%eax
  802545:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802548:	6a 01                	push   $0x1
  80254a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80254d:	50                   	push   %eax
  80254e:	e8 3f e6 ff ff       	call   800b92 <sys_cputs>
}
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	c9                   	leave  
  802557:	c3                   	ret    

00802558 <getchar>:
{
  802558:	f3 0f 1e fb          	endbr32 
  80255c:	55                   	push   %ebp
  80255d:	89 e5                	mov    %esp,%ebp
  80255f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802562:	6a 01                	push   $0x1
  802564:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802567:	50                   	push   %eax
  802568:	6a 00                	push   $0x0
  80256a:	e8 76 eb ff ff       	call   8010e5 <read>
	if (r < 0)
  80256f:	83 c4 10             	add    $0x10,%esp
  802572:	85 c0                	test   %eax,%eax
  802574:	78 06                	js     80257c <getchar+0x24>
	if (r < 1)
  802576:	74 06                	je     80257e <getchar+0x26>
	return c;
  802578:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80257c:	c9                   	leave  
  80257d:	c3                   	ret    
		return -E_EOF;
  80257e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802583:	eb f7                	jmp    80257c <getchar+0x24>

00802585 <iscons>:
{
  802585:	f3 0f 1e fb          	endbr32 
  802589:	55                   	push   %ebp
  80258a:	89 e5                	mov    %esp,%ebp
  80258c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80258f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802592:	50                   	push   %eax
  802593:	ff 75 08             	pushl  0x8(%ebp)
  802596:	e8 c2 e8 ff ff       	call   800e5d <fd_lookup>
  80259b:	83 c4 10             	add    $0x10,%esp
  80259e:	85 c0                	test   %eax,%eax
  8025a0:	78 11                	js     8025b3 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8025a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a5:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8025ab:	39 10                	cmp    %edx,(%eax)
  8025ad:	0f 94 c0             	sete   %al
  8025b0:	0f b6 c0             	movzbl %al,%eax
}
  8025b3:	c9                   	leave  
  8025b4:	c3                   	ret    

008025b5 <opencons>:
{
  8025b5:	f3 0f 1e fb          	endbr32 
  8025b9:	55                   	push   %ebp
  8025ba:	89 e5                	mov    %esp,%ebp
  8025bc:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8025bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025c2:	50                   	push   %eax
  8025c3:	e8 3f e8 ff ff       	call   800e07 <fd_alloc>
  8025c8:	83 c4 10             	add    $0x10,%esp
  8025cb:	85 c0                	test   %eax,%eax
  8025cd:	78 3a                	js     802609 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025cf:	83 ec 04             	sub    $0x4,%esp
  8025d2:	68 07 04 00 00       	push   $0x407
  8025d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8025da:	6a 00                	push   $0x0
  8025dc:	e8 60 e6 ff ff       	call   800c41 <sys_page_alloc>
  8025e1:	83 c4 10             	add    $0x10,%esp
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	78 21                	js     802609 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8025e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025eb:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8025f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025fd:	83 ec 0c             	sub    $0xc,%esp
  802600:	50                   	push   %eax
  802601:	e8 d2 e7 ff ff       	call   800dd8 <fd2num>
  802606:	83 c4 10             	add    $0x10,%esp
}
  802609:	c9                   	leave  
  80260a:	c3                   	ret    

0080260b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80260b:	f3 0f 1e fb          	endbr32 
  80260f:	55                   	push   %ebp
  802610:	89 e5                	mov    %esp,%ebp
  802612:	56                   	push   %esi
  802613:	53                   	push   %ebx
  802614:	8b 75 08             	mov    0x8(%ebp),%esi
  802617:	8b 45 0c             	mov    0xc(%ebp),%eax
  80261a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80261d:	85 c0                	test   %eax,%eax
  80261f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802624:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802627:	83 ec 0c             	sub    $0xc,%esp
  80262a:	50                   	push   %eax
  80262b:	e8 17 e7 ff ff       	call   800d47 <sys_ipc_recv>
  802630:	83 c4 10             	add    $0x10,%esp
  802633:	85 c0                	test   %eax,%eax
  802635:	75 2b                	jne    802662 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802637:	85 f6                	test   %esi,%esi
  802639:	74 0a                	je     802645 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80263b:	a1 08 40 80 00       	mov    0x804008,%eax
  802640:	8b 40 74             	mov    0x74(%eax),%eax
  802643:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802645:	85 db                	test   %ebx,%ebx
  802647:	74 0a                	je     802653 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802649:	a1 08 40 80 00       	mov    0x804008,%eax
  80264e:	8b 40 78             	mov    0x78(%eax),%eax
  802651:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802653:	a1 08 40 80 00       	mov    0x804008,%eax
  802658:	8b 40 70             	mov    0x70(%eax),%eax
}
  80265b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80265e:	5b                   	pop    %ebx
  80265f:	5e                   	pop    %esi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802662:	85 f6                	test   %esi,%esi
  802664:	74 06                	je     80266c <ipc_recv+0x61>
  802666:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80266c:	85 db                	test   %ebx,%ebx
  80266e:	74 eb                	je     80265b <ipc_recv+0x50>
  802670:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802676:	eb e3                	jmp    80265b <ipc_recv+0x50>

00802678 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802678:	f3 0f 1e fb          	endbr32 
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	57                   	push   %edi
  802680:	56                   	push   %esi
  802681:	53                   	push   %ebx
  802682:	83 ec 0c             	sub    $0xc,%esp
  802685:	8b 7d 08             	mov    0x8(%ebp),%edi
  802688:	8b 75 0c             	mov    0xc(%ebp),%esi
  80268b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80268e:	85 db                	test   %ebx,%ebx
  802690:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802695:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802698:	ff 75 14             	pushl  0x14(%ebp)
  80269b:	53                   	push   %ebx
  80269c:	56                   	push   %esi
  80269d:	57                   	push   %edi
  80269e:	e8 7d e6 ff ff       	call   800d20 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8026a3:	83 c4 10             	add    $0x10,%esp
  8026a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026a9:	75 07                	jne    8026b2 <ipc_send+0x3a>
			sys_yield();
  8026ab:	e8 6e e5 ff ff       	call   800c1e <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8026b0:	eb e6                	jmp    802698 <ipc_send+0x20>
		}
		else if (ret == 0)
  8026b2:	85 c0                	test   %eax,%eax
  8026b4:	75 08                	jne    8026be <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8026b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026b9:	5b                   	pop    %ebx
  8026ba:	5e                   	pop    %esi
  8026bb:	5f                   	pop    %edi
  8026bc:	5d                   	pop    %ebp
  8026bd:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8026be:	50                   	push   %eax
  8026bf:	68 7a 2f 80 00       	push   $0x802f7a
  8026c4:	6a 48                	push   $0x48
  8026c6:	68 88 2f 80 00       	push   $0x802f88
  8026cb:	e8 17 da ff ff       	call   8000e7 <_panic>

008026d0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026d0:	f3 0f 1e fb          	endbr32 
  8026d4:	55                   	push   %ebp
  8026d5:	89 e5                	mov    %esp,%ebp
  8026d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026df:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026e8:	8b 52 50             	mov    0x50(%edx),%edx
  8026eb:	39 ca                	cmp    %ecx,%edx
  8026ed:	74 11                	je     802700 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8026ef:	83 c0 01             	add    $0x1,%eax
  8026f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026f7:	75 e6                	jne    8026df <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8026f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8026fe:	eb 0b                	jmp    80270b <ipc_find_env+0x3b>
			return envs[i].env_id;
  802700:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802703:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802708:	8b 40 48             	mov    0x48(%eax),%eax
}
  80270b:	5d                   	pop    %ebp
  80270c:	c3                   	ret    

0080270d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80270d:	f3 0f 1e fb          	endbr32 
  802711:	55                   	push   %ebp
  802712:	89 e5                	mov    %esp,%ebp
  802714:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802717:	89 c2                	mov    %eax,%edx
  802719:	c1 ea 16             	shr    $0x16,%edx
  80271c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802723:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802728:	f6 c1 01             	test   $0x1,%cl
  80272b:	74 1c                	je     802749 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80272d:	c1 e8 0c             	shr    $0xc,%eax
  802730:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802737:	a8 01                	test   $0x1,%al
  802739:	74 0e                	je     802749 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80273b:	c1 e8 0c             	shr    $0xc,%eax
  80273e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802745:	ef 
  802746:	0f b7 d2             	movzwl %dx,%edx
}
  802749:	89 d0                	mov    %edx,%eax
  80274b:	5d                   	pop    %ebp
  80274c:	c3                   	ret    
  80274d:	66 90                	xchg   %ax,%ax
  80274f:	90                   	nop

00802750 <__udivdi3>:
  802750:	f3 0f 1e fb          	endbr32 
  802754:	55                   	push   %ebp
  802755:	57                   	push   %edi
  802756:	56                   	push   %esi
  802757:	53                   	push   %ebx
  802758:	83 ec 1c             	sub    $0x1c,%esp
  80275b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80275f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802763:	8b 74 24 34          	mov    0x34(%esp),%esi
  802767:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80276b:	85 d2                	test   %edx,%edx
  80276d:	75 19                	jne    802788 <__udivdi3+0x38>
  80276f:	39 f3                	cmp    %esi,%ebx
  802771:	76 4d                	jbe    8027c0 <__udivdi3+0x70>
  802773:	31 ff                	xor    %edi,%edi
  802775:	89 e8                	mov    %ebp,%eax
  802777:	89 f2                	mov    %esi,%edx
  802779:	f7 f3                	div    %ebx
  80277b:	89 fa                	mov    %edi,%edx
  80277d:	83 c4 1c             	add    $0x1c,%esp
  802780:	5b                   	pop    %ebx
  802781:	5e                   	pop    %esi
  802782:	5f                   	pop    %edi
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    
  802785:	8d 76 00             	lea    0x0(%esi),%esi
  802788:	39 f2                	cmp    %esi,%edx
  80278a:	76 14                	jbe    8027a0 <__udivdi3+0x50>
  80278c:	31 ff                	xor    %edi,%edi
  80278e:	31 c0                	xor    %eax,%eax
  802790:	89 fa                	mov    %edi,%edx
  802792:	83 c4 1c             	add    $0x1c,%esp
  802795:	5b                   	pop    %ebx
  802796:	5e                   	pop    %esi
  802797:	5f                   	pop    %edi
  802798:	5d                   	pop    %ebp
  802799:	c3                   	ret    
  80279a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a0:	0f bd fa             	bsr    %edx,%edi
  8027a3:	83 f7 1f             	xor    $0x1f,%edi
  8027a6:	75 48                	jne    8027f0 <__udivdi3+0xa0>
  8027a8:	39 f2                	cmp    %esi,%edx
  8027aa:	72 06                	jb     8027b2 <__udivdi3+0x62>
  8027ac:	31 c0                	xor    %eax,%eax
  8027ae:	39 eb                	cmp    %ebp,%ebx
  8027b0:	77 de                	ja     802790 <__udivdi3+0x40>
  8027b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b7:	eb d7                	jmp    802790 <__udivdi3+0x40>
  8027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	89 d9                	mov    %ebx,%ecx
  8027c2:	85 db                	test   %ebx,%ebx
  8027c4:	75 0b                	jne    8027d1 <__udivdi3+0x81>
  8027c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027cb:	31 d2                	xor    %edx,%edx
  8027cd:	f7 f3                	div    %ebx
  8027cf:	89 c1                	mov    %eax,%ecx
  8027d1:	31 d2                	xor    %edx,%edx
  8027d3:	89 f0                	mov    %esi,%eax
  8027d5:	f7 f1                	div    %ecx
  8027d7:	89 c6                	mov    %eax,%esi
  8027d9:	89 e8                	mov    %ebp,%eax
  8027db:	89 f7                	mov    %esi,%edi
  8027dd:	f7 f1                	div    %ecx
  8027df:	89 fa                	mov    %edi,%edx
  8027e1:	83 c4 1c             	add    $0x1c,%esp
  8027e4:	5b                   	pop    %ebx
  8027e5:	5e                   	pop    %esi
  8027e6:	5f                   	pop    %edi
  8027e7:	5d                   	pop    %ebp
  8027e8:	c3                   	ret    
  8027e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027f0:	89 f9                	mov    %edi,%ecx
  8027f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8027f7:	29 f8                	sub    %edi,%eax
  8027f9:	d3 e2                	shl    %cl,%edx
  8027fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8027ff:	89 c1                	mov    %eax,%ecx
  802801:	89 da                	mov    %ebx,%edx
  802803:	d3 ea                	shr    %cl,%edx
  802805:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802809:	09 d1                	or     %edx,%ecx
  80280b:	89 f2                	mov    %esi,%edx
  80280d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802811:	89 f9                	mov    %edi,%ecx
  802813:	d3 e3                	shl    %cl,%ebx
  802815:	89 c1                	mov    %eax,%ecx
  802817:	d3 ea                	shr    %cl,%edx
  802819:	89 f9                	mov    %edi,%ecx
  80281b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80281f:	89 eb                	mov    %ebp,%ebx
  802821:	d3 e6                	shl    %cl,%esi
  802823:	89 c1                	mov    %eax,%ecx
  802825:	d3 eb                	shr    %cl,%ebx
  802827:	09 de                	or     %ebx,%esi
  802829:	89 f0                	mov    %esi,%eax
  80282b:	f7 74 24 08          	divl   0x8(%esp)
  80282f:	89 d6                	mov    %edx,%esi
  802831:	89 c3                	mov    %eax,%ebx
  802833:	f7 64 24 0c          	mull   0xc(%esp)
  802837:	39 d6                	cmp    %edx,%esi
  802839:	72 15                	jb     802850 <__udivdi3+0x100>
  80283b:	89 f9                	mov    %edi,%ecx
  80283d:	d3 e5                	shl    %cl,%ebp
  80283f:	39 c5                	cmp    %eax,%ebp
  802841:	73 04                	jae    802847 <__udivdi3+0xf7>
  802843:	39 d6                	cmp    %edx,%esi
  802845:	74 09                	je     802850 <__udivdi3+0x100>
  802847:	89 d8                	mov    %ebx,%eax
  802849:	31 ff                	xor    %edi,%edi
  80284b:	e9 40 ff ff ff       	jmp    802790 <__udivdi3+0x40>
  802850:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802853:	31 ff                	xor    %edi,%edi
  802855:	e9 36 ff ff ff       	jmp    802790 <__udivdi3+0x40>
  80285a:	66 90                	xchg   %ax,%ax
  80285c:	66 90                	xchg   %ax,%ax
  80285e:	66 90                	xchg   %ax,%ax

00802860 <__umoddi3>:
  802860:	f3 0f 1e fb          	endbr32 
  802864:	55                   	push   %ebp
  802865:	57                   	push   %edi
  802866:	56                   	push   %esi
  802867:	53                   	push   %ebx
  802868:	83 ec 1c             	sub    $0x1c,%esp
  80286b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80286f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802873:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802877:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80287b:	85 c0                	test   %eax,%eax
  80287d:	75 19                	jne    802898 <__umoddi3+0x38>
  80287f:	39 df                	cmp    %ebx,%edi
  802881:	76 5d                	jbe    8028e0 <__umoddi3+0x80>
  802883:	89 f0                	mov    %esi,%eax
  802885:	89 da                	mov    %ebx,%edx
  802887:	f7 f7                	div    %edi
  802889:	89 d0                	mov    %edx,%eax
  80288b:	31 d2                	xor    %edx,%edx
  80288d:	83 c4 1c             	add    $0x1c,%esp
  802890:	5b                   	pop    %ebx
  802891:	5e                   	pop    %esi
  802892:	5f                   	pop    %edi
  802893:	5d                   	pop    %ebp
  802894:	c3                   	ret    
  802895:	8d 76 00             	lea    0x0(%esi),%esi
  802898:	89 f2                	mov    %esi,%edx
  80289a:	39 d8                	cmp    %ebx,%eax
  80289c:	76 12                	jbe    8028b0 <__umoddi3+0x50>
  80289e:	89 f0                	mov    %esi,%eax
  8028a0:	89 da                	mov    %ebx,%edx
  8028a2:	83 c4 1c             	add    $0x1c,%esp
  8028a5:	5b                   	pop    %ebx
  8028a6:	5e                   	pop    %esi
  8028a7:	5f                   	pop    %edi
  8028a8:	5d                   	pop    %ebp
  8028a9:	c3                   	ret    
  8028aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028b0:	0f bd e8             	bsr    %eax,%ebp
  8028b3:	83 f5 1f             	xor    $0x1f,%ebp
  8028b6:	75 50                	jne    802908 <__umoddi3+0xa8>
  8028b8:	39 d8                	cmp    %ebx,%eax
  8028ba:	0f 82 e0 00 00 00    	jb     8029a0 <__umoddi3+0x140>
  8028c0:	89 d9                	mov    %ebx,%ecx
  8028c2:	39 f7                	cmp    %esi,%edi
  8028c4:	0f 86 d6 00 00 00    	jbe    8029a0 <__umoddi3+0x140>
  8028ca:	89 d0                	mov    %edx,%eax
  8028cc:	89 ca                	mov    %ecx,%edx
  8028ce:	83 c4 1c             	add    $0x1c,%esp
  8028d1:	5b                   	pop    %ebx
  8028d2:	5e                   	pop    %esi
  8028d3:	5f                   	pop    %edi
  8028d4:	5d                   	pop    %ebp
  8028d5:	c3                   	ret    
  8028d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028dd:	8d 76 00             	lea    0x0(%esi),%esi
  8028e0:	89 fd                	mov    %edi,%ebp
  8028e2:	85 ff                	test   %edi,%edi
  8028e4:	75 0b                	jne    8028f1 <__umoddi3+0x91>
  8028e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028eb:	31 d2                	xor    %edx,%edx
  8028ed:	f7 f7                	div    %edi
  8028ef:	89 c5                	mov    %eax,%ebp
  8028f1:	89 d8                	mov    %ebx,%eax
  8028f3:	31 d2                	xor    %edx,%edx
  8028f5:	f7 f5                	div    %ebp
  8028f7:	89 f0                	mov    %esi,%eax
  8028f9:	f7 f5                	div    %ebp
  8028fb:	89 d0                	mov    %edx,%eax
  8028fd:	31 d2                	xor    %edx,%edx
  8028ff:	eb 8c                	jmp    80288d <__umoddi3+0x2d>
  802901:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802908:	89 e9                	mov    %ebp,%ecx
  80290a:	ba 20 00 00 00       	mov    $0x20,%edx
  80290f:	29 ea                	sub    %ebp,%edx
  802911:	d3 e0                	shl    %cl,%eax
  802913:	89 44 24 08          	mov    %eax,0x8(%esp)
  802917:	89 d1                	mov    %edx,%ecx
  802919:	89 f8                	mov    %edi,%eax
  80291b:	d3 e8                	shr    %cl,%eax
  80291d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802921:	89 54 24 04          	mov    %edx,0x4(%esp)
  802925:	8b 54 24 04          	mov    0x4(%esp),%edx
  802929:	09 c1                	or     %eax,%ecx
  80292b:	89 d8                	mov    %ebx,%eax
  80292d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802931:	89 e9                	mov    %ebp,%ecx
  802933:	d3 e7                	shl    %cl,%edi
  802935:	89 d1                	mov    %edx,%ecx
  802937:	d3 e8                	shr    %cl,%eax
  802939:	89 e9                	mov    %ebp,%ecx
  80293b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80293f:	d3 e3                	shl    %cl,%ebx
  802941:	89 c7                	mov    %eax,%edi
  802943:	89 d1                	mov    %edx,%ecx
  802945:	89 f0                	mov    %esi,%eax
  802947:	d3 e8                	shr    %cl,%eax
  802949:	89 e9                	mov    %ebp,%ecx
  80294b:	89 fa                	mov    %edi,%edx
  80294d:	d3 e6                	shl    %cl,%esi
  80294f:	09 d8                	or     %ebx,%eax
  802951:	f7 74 24 08          	divl   0x8(%esp)
  802955:	89 d1                	mov    %edx,%ecx
  802957:	89 f3                	mov    %esi,%ebx
  802959:	f7 64 24 0c          	mull   0xc(%esp)
  80295d:	89 c6                	mov    %eax,%esi
  80295f:	89 d7                	mov    %edx,%edi
  802961:	39 d1                	cmp    %edx,%ecx
  802963:	72 06                	jb     80296b <__umoddi3+0x10b>
  802965:	75 10                	jne    802977 <__umoddi3+0x117>
  802967:	39 c3                	cmp    %eax,%ebx
  802969:	73 0c                	jae    802977 <__umoddi3+0x117>
  80296b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80296f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802973:	89 d7                	mov    %edx,%edi
  802975:	89 c6                	mov    %eax,%esi
  802977:	89 ca                	mov    %ecx,%edx
  802979:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80297e:	29 f3                	sub    %esi,%ebx
  802980:	19 fa                	sbb    %edi,%edx
  802982:	89 d0                	mov    %edx,%eax
  802984:	d3 e0                	shl    %cl,%eax
  802986:	89 e9                	mov    %ebp,%ecx
  802988:	d3 eb                	shr    %cl,%ebx
  80298a:	d3 ea                	shr    %cl,%edx
  80298c:	09 d8                	or     %ebx,%eax
  80298e:	83 c4 1c             	add    $0x1c,%esp
  802991:	5b                   	pop    %ebx
  802992:	5e                   	pop    %esi
  802993:	5f                   	pop    %edi
  802994:	5d                   	pop    %ebp
  802995:	c3                   	ret    
  802996:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80299d:	8d 76 00             	lea    0x0(%esi),%esi
  8029a0:	29 fe                	sub    %edi,%esi
  8029a2:	19 c3                	sbb    %eax,%ebx
  8029a4:	89 f2                	mov    %esi,%edx
  8029a6:	89 d9                	mov    %ebx,%ecx
  8029a8:	e9 1d ff ff ff       	jmp    8028ca <__umoddi3+0x6a>
