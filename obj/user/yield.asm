
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003e:	a1 08 40 80 00       	mov    0x804008,%eax
  800043:	8b 40 48             	mov    0x48(%eax),%eax
  800046:	50                   	push   %eax
  800047:	68 c0 23 80 00       	push   $0x8023c0
  80004c:	e8 52 01 00 00       	call   8001a3 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800054:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800059:	e8 95 0b 00 00       	call   800bf3 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005e:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800063:	8b 40 48             	mov    0x48(%eax),%eax
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	53                   	push   %ebx
  80006a:	50                   	push   %eax
  80006b:	68 e0 23 80 00       	push   $0x8023e0
  800070:	e8 2e 01 00 00       	call   8001a3 <cprintf>
	for (i = 0; i < 5; i++) {
  800075:	83 c3 01             	add    $0x1,%ebx
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d9                	jne    800059 <umain+0x26>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 08 40 80 00       	mov    0x804008,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	50                   	push   %eax
  80008c:	68 0c 24 80 00       	push   $0x80240c
  800091:	e8 0d 01 00 00       	call   8001a3 <cprintf>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	f3 0f 1e fb          	endbr32 
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ad:	e8 1e 0b 00 00       	call   800bd0 <sys_getenvid>
  8000b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000bf:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c4:	85 db                	test   %ebx,%ebx
  8000c6:	7e 07                	jle    8000cf <libmain+0x31>
		binaryname = argv[0];
  8000c8:	8b 06                	mov    (%esi),%eax
  8000ca:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	e8 5a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d9:	e8 0a 00 00 00       	call   8000e8 <exit>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	f3 0f 1e fb          	endbr32 
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000f2:	e8 aa 0e 00 00       	call   800fa1 <close_all>
	sys_env_destroy(0);
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	6a 00                	push   $0x0
  8000fc:	e8 ab 0a 00 00       	call   800bac <sys_env_destroy>
}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	c9                   	leave  
  800105:	c3                   	ret    

00800106 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800106:	f3 0f 1e fb          	endbr32 
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	53                   	push   %ebx
  80010e:	83 ec 04             	sub    $0x4,%esp
  800111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800114:	8b 13                	mov    (%ebx),%edx
  800116:	8d 42 01             	lea    0x1(%edx),%eax
  800119:	89 03                	mov    %eax,(%ebx)
  80011b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800122:	3d ff 00 00 00       	cmp    $0xff,%eax
  800127:	74 09                	je     800132 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800129:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800130:	c9                   	leave  
  800131:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800132:	83 ec 08             	sub    $0x8,%esp
  800135:	68 ff 00 00 00       	push   $0xff
  80013a:	8d 43 08             	lea    0x8(%ebx),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 24 0a 00 00       	call   800b67 <sys_cputs>
		b->idx = 0;
  800143:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	eb db                	jmp    800129 <putch+0x23>

0080014e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014e:	f3 0f 1e fb          	endbr32 
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800162:	00 00 00 
	b.cnt = 0;
  800165:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	68 06 01 80 00       	push   $0x800106
  800181:	e8 20 01 00 00       	call   8002a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800186:	83 c4 08             	add    $0x8,%esp
  800189:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800195:	50                   	push   %eax
  800196:	e8 cc 09 00 00       	call   800b67 <sys_cputs>

	return b.cnt;
}
  80019b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a3:	f3 0f 1e fb          	endbr32 
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	50                   	push   %eax
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	e8 95 ff ff ff       	call   80014e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 1c             	sub    $0x1c,%esp
  8001c4:	89 c7                	mov    %eax,%edi
  8001c6:	89 d6                	mov    %edx,%esi
  8001c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ce:	89 d1                	mov    %edx,%ecx
  8001d0:	89 c2                	mov    %eax,%edx
  8001d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001db:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8001de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e8:	39 c2                	cmp    %eax,%edx
  8001ea:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ed:	72 3e                	jb     80022d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	83 eb 01             	sub    $0x1,%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	50                   	push   %eax
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800200:	ff 75 e0             	pushl  -0x20(%ebp)
  800203:	ff 75 dc             	pushl  -0x24(%ebp)
  800206:	ff 75 d8             	pushl  -0x28(%ebp)
  800209:	e8 42 1f 00 00       	call   802150 <__udivdi3>
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	52                   	push   %edx
  800212:	50                   	push   %eax
  800213:	89 f2                	mov    %esi,%edx
  800215:	89 f8                	mov    %edi,%eax
  800217:	e8 9f ff ff ff       	call   8001bb <printnum>
  80021c:	83 c4 20             	add    $0x20,%esp
  80021f:	eb 13                	jmp    800234 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	56                   	push   %esi
  800225:	ff 75 18             	pushl  0x18(%ebp)
  800228:	ff d7                	call   *%edi
  80022a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ed                	jg     800221 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	83 ec 04             	sub    $0x4,%esp
  80023b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023e:	ff 75 e0             	pushl  -0x20(%ebp)
  800241:	ff 75 dc             	pushl  -0x24(%ebp)
  800244:	ff 75 d8             	pushl  -0x28(%ebp)
  800247:	e8 14 20 00 00       	call   802260 <__umoddi3>
  80024c:	83 c4 14             	add    $0x14,%esp
  80024f:	0f be 80 35 24 80 00 	movsbl 0x802435(%eax),%eax
  800256:	50                   	push   %eax
  800257:	ff d7                	call   *%edi
}
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800264:	f3 0f 1e fb          	endbr32 
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800272:	8b 10                	mov    (%eax),%edx
  800274:	3b 50 04             	cmp    0x4(%eax),%edx
  800277:	73 0a                	jae    800283 <sprintputch+0x1f>
		*b->buf++ = ch;
  800279:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	88 02                	mov    %al,(%edx)
}
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <printfmt>:
{
  800285:	f3 0f 1e fb          	endbr32 
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800292:	50                   	push   %eax
  800293:	ff 75 10             	pushl  0x10(%ebp)
  800296:	ff 75 0c             	pushl  0xc(%ebp)
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	e8 05 00 00 00       	call   8002a6 <vprintfmt>
}
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <vprintfmt>:
{
  8002a6:	f3 0f 1e fb          	endbr32 
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 3c             	sub    $0x3c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	e9 8e 03 00 00       	jmp    80064f <vprintfmt+0x3a9>
		padc = ' ';
  8002c1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002da:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002df:	8d 47 01             	lea    0x1(%edi),%eax
  8002e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e5:	0f b6 17             	movzbl (%edi),%edx
  8002e8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002eb:	3c 55                	cmp    $0x55,%al
  8002ed:	0f 87 df 03 00 00    	ja     8006d2 <vprintfmt+0x42c>
  8002f3:	0f b6 c0             	movzbl %al,%eax
  8002f6:	3e ff 24 85 80 25 80 	notrack jmp *0x802580(,%eax,4)
  8002fd:	00 
  8002fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800301:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800305:	eb d8                	jmp    8002df <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80030e:	eb cf                	jmp    8002df <vprintfmt+0x39>
  800310:	0f b6 d2             	movzbl %dl,%edx
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800316:	b8 00 00 00 00       	mov    $0x0,%eax
  80031b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80031e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800321:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800325:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800328:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032b:	83 f9 09             	cmp    $0x9,%ecx
  80032e:	77 55                	ja     800385 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800330:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800333:	eb e9                	jmp    80031e <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800335:	8b 45 14             	mov    0x14(%ebp),%eax
  800338:	8b 00                	mov    (%eax),%eax
  80033a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033d:	8b 45 14             	mov    0x14(%ebp),%eax
  800340:	8d 40 04             	lea    0x4(%eax),%eax
  800343:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800349:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034d:	79 90                	jns    8002df <vprintfmt+0x39>
				width = precision, precision = -1;
  80034f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800352:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800355:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035c:	eb 81                	jmp    8002df <vprintfmt+0x39>
  80035e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800361:	85 c0                	test   %eax,%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
  800368:	0f 49 d0             	cmovns %eax,%edx
  80036b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800371:	e9 69 ff ff ff       	jmp    8002df <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800379:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800380:	e9 5a ff ff ff       	jmp    8002df <vprintfmt+0x39>
  800385:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800388:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038b:	eb bc                	jmp    800349 <vprintfmt+0xa3>
			lflag++;
  80038d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800393:	e9 47 ff ff ff       	jmp    8002df <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 78 04             	lea    0x4(%eax),%edi
  80039e:	83 ec 08             	sub    $0x8,%esp
  8003a1:	53                   	push   %ebx
  8003a2:	ff 30                	pushl  (%eax)
  8003a4:	ff d6                	call   *%esi
			break;
  8003a6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ac:	e9 9b 02 00 00       	jmp    80064c <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 78 04             	lea    0x4(%eax),%edi
  8003b7:	8b 00                	mov    (%eax),%eax
  8003b9:	99                   	cltd   
  8003ba:	31 d0                	xor    %edx,%eax
  8003bc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003be:	83 f8 0f             	cmp    $0xf,%eax
  8003c1:	7f 23                	jg     8003e6 <vprintfmt+0x140>
  8003c3:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 18                	je     8003e6 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003ce:	52                   	push   %edx
  8003cf:	68 e9 27 80 00       	push   $0x8027e9
  8003d4:	53                   	push   %ebx
  8003d5:	56                   	push   %esi
  8003d6:	e8 aa fe ff ff       	call   800285 <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003de:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e1:	e9 66 02 00 00       	jmp    80064c <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003e6:	50                   	push   %eax
  8003e7:	68 4d 24 80 00       	push   $0x80244d
  8003ec:	53                   	push   %ebx
  8003ed:	56                   	push   %esi
  8003ee:	e8 92 fe ff ff       	call   800285 <printfmt>
  8003f3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f6:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f9:	e9 4e 02 00 00       	jmp    80064c <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	83 c0 04             	add    $0x4,%eax
  800404:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80040c:	85 d2                	test   %edx,%edx
  80040e:	b8 46 24 80 00       	mov    $0x802446,%eax
  800413:	0f 45 c2             	cmovne %edx,%eax
  800416:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041d:	7e 06                	jle    800425 <vprintfmt+0x17f>
  80041f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800423:	75 0d                	jne    800432 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800428:	89 c7                	mov    %eax,%edi
  80042a:	03 45 e0             	add    -0x20(%ebp),%eax
  80042d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800430:	eb 55                	jmp    800487 <vprintfmt+0x1e1>
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 d8             	pushl  -0x28(%ebp)
  800438:	ff 75 cc             	pushl  -0x34(%ebp)
  80043b:	e8 46 03 00 00       	call   800786 <strnlen>
  800440:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800443:	29 c2                	sub    %eax,%edx
  800445:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80044d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800454:	85 ff                	test   %edi,%edi
  800456:	7e 11                	jle    800469 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	ff 75 e0             	pushl  -0x20(%ebp)
  80045f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	83 ef 01             	sub    $0x1,%edi
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	eb eb                	jmp    800454 <vprintfmt+0x1ae>
  800469:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	0f 49 c2             	cmovns %edx,%eax
  800476:	29 c2                	sub    %eax,%edx
  800478:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80047b:	eb a8                	jmp    800425 <vprintfmt+0x17f>
					putch(ch, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	52                   	push   %edx
  800482:	ff d6                	call   *%esi
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048c:	83 c7 01             	add    $0x1,%edi
  80048f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800493:	0f be d0             	movsbl %al,%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	74 4b                	je     8004e5 <vprintfmt+0x23f>
  80049a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049e:	78 06                	js     8004a6 <vprintfmt+0x200>
  8004a0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a4:	78 1e                	js     8004c4 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8004a6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004aa:	74 d1                	je     80047d <vprintfmt+0x1d7>
  8004ac:	0f be c0             	movsbl %al,%eax
  8004af:	83 e8 20             	sub    $0x20,%eax
  8004b2:	83 f8 5e             	cmp    $0x5e,%eax
  8004b5:	76 c6                	jbe    80047d <vprintfmt+0x1d7>
					putch('?', putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	6a 3f                	push   $0x3f
  8004bd:	ff d6                	call   *%esi
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	eb c3                	jmp    800487 <vprintfmt+0x1e1>
  8004c4:	89 cf                	mov    %ecx,%edi
  8004c6:	eb 0e                	jmp    8004d6 <vprintfmt+0x230>
				putch(' ', putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	53                   	push   %ebx
  8004cc:	6a 20                	push   $0x20
  8004ce:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d0:	83 ef 01             	sub    $0x1,%edi
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	85 ff                	test   %edi,%edi
  8004d8:	7f ee                	jg     8004c8 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e0:	e9 67 01 00 00       	jmp    80064c <vprintfmt+0x3a6>
  8004e5:	89 cf                	mov    %ecx,%edi
  8004e7:	eb ed                	jmp    8004d6 <vprintfmt+0x230>
	if (lflag >= 2)
  8004e9:	83 f9 01             	cmp    $0x1,%ecx
  8004ec:	7f 1b                	jg     800509 <vprintfmt+0x263>
	else if (lflag)
  8004ee:	85 c9                	test   %ecx,%ecx
  8004f0:	74 63                	je     800555 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fa:	99                   	cltd   
  8004fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 40 04             	lea    0x4(%eax),%eax
  800504:	89 45 14             	mov    %eax,0x14(%ebp)
  800507:	eb 17                	jmp    800520 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8b 50 04             	mov    0x4(%eax),%edx
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800514:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 40 08             	lea    0x8(%eax),%eax
  80051d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800520:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800523:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800526:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80052b:	85 c9                	test   %ecx,%ecx
  80052d:	0f 89 ff 00 00 00    	jns    800632 <vprintfmt+0x38c>
				putch('-', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	6a 2d                	push   $0x2d
  800539:	ff d6                	call   *%esi
				num = -(long long) num;
  80053b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800541:	f7 da                	neg    %edx
  800543:	83 d1 00             	adc    $0x0,%ecx
  800546:	f7 d9                	neg    %ecx
  800548:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800550:	e9 dd 00 00 00       	jmp    800632 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	99                   	cltd   
  80055e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 40 04             	lea    0x4(%eax),%eax
  800567:	89 45 14             	mov    %eax,0x14(%ebp)
  80056a:	eb b4                	jmp    800520 <vprintfmt+0x27a>
	if (lflag >= 2)
  80056c:	83 f9 01             	cmp    $0x1,%ecx
  80056f:	7f 1e                	jg     80058f <vprintfmt+0x2e9>
	else if (lflag)
  800571:	85 c9                	test   %ecx,%ecx
  800573:	74 32                	je     8005a7 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 10                	mov    (%eax),%edx
  80057a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057f:	8d 40 04             	lea    0x4(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800585:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80058a:	e9 a3 00 00 00       	jmp    800632 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 10                	mov    (%eax),%edx
  800594:	8b 48 04             	mov    0x4(%eax),%ecx
  800597:	8d 40 08             	lea    0x8(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a2:	e9 8b 00 00 00       	jmp    800632 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005bc:	eb 74                	jmp    800632 <vprintfmt+0x38c>
	if (lflag >= 2)
  8005be:	83 f9 01             	cmp    $0x1,%ecx
  8005c1:	7f 1b                	jg     8005de <vprintfmt+0x338>
	else if (lflag)
  8005c3:	85 c9                	test   %ecx,%ecx
  8005c5:	74 2c                	je     8005f3 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 10                	mov    (%eax),%edx
  8005cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005d7:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005dc:	eb 54                	jmp    800632 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e6:	8d 40 08             	lea    0x8(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ec:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005f1:	eb 3f                	jmp    800632 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800603:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800608:	eb 28                	jmp    800632 <vprintfmt+0x38c>
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800624:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800632:	83 ec 0c             	sub    $0xc,%esp
  800635:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800639:	57                   	push   %edi
  80063a:	ff 75 e0             	pushl  -0x20(%ebp)
  80063d:	50                   	push   %eax
  80063e:	51                   	push   %ecx
  80063f:	52                   	push   %edx
  800640:	89 da                	mov    %ebx,%edx
  800642:	89 f0                	mov    %esi,%eax
  800644:	e8 72 fb ff ff       	call   8001bb <printnum>
			break;
  800649:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  80064f:	83 c7 01             	add    $0x1,%edi
  800652:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800656:	83 f8 25             	cmp    $0x25,%eax
  800659:	0f 84 62 fc ff ff    	je     8002c1 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  80065f:	85 c0                	test   %eax,%eax
  800661:	0f 84 8b 00 00 00    	je     8006f2 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	50                   	push   %eax
  80066c:	ff d6                	call   *%esi
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	eb dc                	jmp    80064f <vprintfmt+0x3a9>
	if (lflag >= 2)
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7f 1b                	jg     800693 <vprintfmt+0x3ed>
	else if (lflag)
  800678:	85 c9                	test   %ecx,%ecx
  80067a:	74 2c                	je     8006a8 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	b9 00 00 00 00       	mov    $0x0,%ecx
  800686:	8d 40 04             	lea    0x4(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800691:	eb 9f                	jmp    800632 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	8b 48 04             	mov    0x4(%eax),%ecx
  80069b:	8d 40 08             	lea    0x8(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006a6:	eb 8a                	jmp    800632 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006bd:	e9 70 ff ff ff       	jmp    800632 <vprintfmt+0x38c>
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 25                	push   $0x25
  8006c8:	ff d6                	call   *%esi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	e9 7a ff ff ff       	jmp    80064c <vprintfmt+0x3a6>
			putch('%', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	89 f8                	mov    %edi,%eax
  8006df:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e3:	74 05                	je     8006ea <vprintfmt+0x444>
  8006e5:	83 e8 01             	sub    $0x1,%eax
  8006e8:	eb f5                	jmp    8006df <vprintfmt+0x439>
  8006ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ed:	e9 5a ff ff ff       	jmp    80064c <vprintfmt+0x3a6>
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fa:	f3 0f 1e fb          	endbr32 
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	83 ec 18             	sub    $0x18,%esp
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800711:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	74 26                	je     800745 <vsnprintf+0x4b>
  80071f:	85 d2                	test   %edx,%edx
  800721:	7e 22                	jle    800745 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800723:	ff 75 14             	pushl  0x14(%ebp)
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072c:	50                   	push   %eax
  80072d:	68 64 02 80 00       	push   $0x800264
  800732:	e8 6f fb ff ff       	call   8002a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800737:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800740:	83 c4 10             	add    $0x10,%esp
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    
		return -E_INVAL;
  800745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074a:	eb f7                	jmp    800743 <vsnprintf+0x49>

0080074c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074c:	f3 0f 1e fb          	endbr32 
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800759:	50                   	push   %eax
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	ff 75 08             	pushl  0x8(%ebp)
  800763:	e8 92 ff ff ff       	call   8006fa <vsnprintf>
	va_end(ap);

	return rc;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076a:	f3 0f 1e fb          	endbr32 
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077d:	74 05                	je     800784 <strlen+0x1a>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
  800782:	eb f5                	jmp    800779 <strlen+0xf>
	return n;
}
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800786:	f3 0f 1e fb          	endbr32 
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	39 d0                	cmp    %edx,%eax
  80079a:	74 0d                	je     8007a9 <strnlen+0x23>
  80079c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a0:	74 05                	je     8007a7 <strnlen+0x21>
		n++;
  8007a2:	83 c0 01             	add    $0x1,%eax
  8007a5:	eb f1                	jmp    800798 <strnlen+0x12>
  8007a7:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a9:	89 d0                	mov    %edx,%eax
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ad:	f3 0f 1e fb          	endbr32 
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c7:	83 c0 01             	add    $0x1,%eax
  8007ca:	84 d2                	test   %dl,%dl
  8007cc:	75 f2                	jne    8007c0 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007ce:	89 c8                	mov    %ecx,%eax
  8007d0:	5b                   	pop    %ebx
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d3:	f3 0f 1e fb          	endbr32 
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	83 ec 10             	sub    $0x10,%esp
  8007de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e1:	53                   	push   %ebx
  8007e2:	e8 83 ff ff ff       	call   80076a <strlen>
  8007e7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	01 d8                	add    %ebx,%eax
  8007ef:	50                   	push   %eax
  8007f0:	e8 b8 ff ff ff       	call   8007ad <strcpy>
	return dst;
}
  8007f5:	89 d8                	mov    %ebx,%eax
  8007f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fc:	f3 0f 1e fb          	endbr32 
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080b:	89 f3                	mov    %esi,%ebx
  80080d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	89 f0                	mov    %esi,%eax
  800812:	39 d8                	cmp    %ebx,%eax
  800814:	74 11                	je     800827 <strncpy+0x2b>
		*dst++ = *src;
  800816:	83 c0 01             	add    $0x1,%eax
  800819:	0f b6 0a             	movzbl (%edx),%ecx
  80081c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081f:	80 f9 01             	cmp    $0x1,%cl
  800822:	83 da ff             	sbb    $0xffffffff,%edx
  800825:	eb eb                	jmp    800812 <strncpy+0x16>
	}
	return ret;
}
  800827:	89 f0                	mov    %esi,%eax
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082d:	f3 0f 1e fb          	endbr32 
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	8b 75 08             	mov    0x8(%ebp),%esi
  800839:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083c:	8b 55 10             	mov    0x10(%ebp),%edx
  80083f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800841:	85 d2                	test   %edx,%edx
  800843:	74 21                	je     800866 <strlcpy+0x39>
  800845:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800849:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80084b:	39 c2                	cmp    %eax,%edx
  80084d:	74 14                	je     800863 <strlcpy+0x36>
  80084f:	0f b6 19             	movzbl (%ecx),%ebx
  800852:	84 db                	test   %bl,%bl
  800854:	74 0b                	je     800861 <strlcpy+0x34>
			*dst++ = *src++;
  800856:	83 c1 01             	add    $0x1,%ecx
  800859:	83 c2 01             	add    $0x1,%edx
  80085c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085f:	eb ea                	jmp    80084b <strlcpy+0x1e>
  800861:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800863:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800866:	29 f0                	sub    %esi,%eax
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086c:	f3 0f 1e fb          	endbr32 
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	84 c0                	test   %al,%al
  80087e:	74 0c                	je     80088c <strcmp+0x20>
  800880:	3a 02                	cmp    (%edx),%al
  800882:	75 08                	jne    80088c <strcmp+0x20>
		p++, q++;
  800884:	83 c1 01             	add    $0x1,%ecx
  800887:	83 c2 01             	add    $0x1,%edx
  80088a:	eb ed                	jmp    800879 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 c0             	movzbl %al,%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a4:	89 c3                	mov    %eax,%ebx
  8008a6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a9:	eb 06                	jmp    8008b1 <strncmp+0x1b>
		n--, p++, q++;
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b1:	39 d8                	cmp    %ebx,%eax
  8008b3:	74 16                	je     8008cb <strncmp+0x35>
  8008b5:	0f b6 08             	movzbl (%eax),%ecx
  8008b8:	84 c9                	test   %cl,%cl
  8008ba:	74 04                	je     8008c0 <strncmp+0x2a>
  8008bc:	3a 0a                	cmp    (%edx),%cl
  8008be:	74 eb                	je     8008ab <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c0:	0f b6 00             	movzbl (%eax),%eax
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	29 d0                	sub    %edx,%eax
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    
		return 0;
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d0:	eb f6                	jmp    8008c8 <strncmp+0x32>

008008d2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d2:	f3 0f 1e fb          	endbr32 
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e0:	0f b6 10             	movzbl (%eax),%edx
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	74 09                	je     8008f0 <strchr+0x1e>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 0a                	je     8008f5 <strchr+0x23>
	for (; *s; s++)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	eb f0                	jmp    8008e0 <strchr+0xe>
			return (char *) s;
	return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8008f7:	f3 0f 1e fb          	endbr32 
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800901:	6a 78                	push   $0x78
  800903:	ff 75 08             	pushl  0x8(%ebp)
  800906:	e8 c7 ff ff ff       	call   8008d2 <strchr>
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800916:	eb 0d                	jmp    800925 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800918:	c1 e0 04             	shl    $0x4,%eax
  80091b:	0f be d2             	movsbl %dl,%edx
  80091e:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	0f b6 11             	movzbl (%ecx),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 11                	je     80093d <atox+0x46>
		if (*p>='a'){
  80092c:	80 fa 60             	cmp    $0x60,%dl
  80092f:	7e e7                	jle    800918 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800931:	c1 e0 04             	shl    $0x4,%eax
  800934:	0f be d2             	movsbl %dl,%edx
  800937:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  80093b:	eb e5                	jmp    800922 <atox+0x2b>
	}

	return v;

}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 09                	je     80095d <strfind+0x1e>
  800954:	84 d2                	test   %dl,%dl
  800956:	74 05                	je     80095d <strfind+0x1e>
	for (; *s; s++)
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	eb f0                	jmp    80094d <strfind+0xe>
			break;
	return (char *) s;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095f:	f3 0f 1e fb          	endbr32 
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80096f:	85 c9                	test   %ecx,%ecx
  800971:	74 31                	je     8009a4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800973:	89 f8                	mov    %edi,%eax
  800975:	09 c8                	or     %ecx,%eax
  800977:	a8 03                	test   $0x3,%al
  800979:	75 23                	jne    80099e <memset+0x3f>
		c &= 0xFF;
  80097b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d3                	mov    %edx,%ebx
  800981:	c1 e3 08             	shl    $0x8,%ebx
  800984:	89 d0                	mov    %edx,%eax
  800986:	c1 e0 18             	shl    $0x18,%eax
  800989:	89 d6                	mov    %edx,%esi
  80098b:	c1 e6 10             	shl    $0x10,%esi
  80098e:	09 f0                	or     %esi,%eax
  800990:	09 c2                	or     %eax,%edx
  800992:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800994:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800997:	89 d0                	mov    %edx,%eax
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb 06                	jmp    8009a4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	fc                   	cld    
  8009a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a4:	89 f8                	mov    %edi,%eax
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ab:	f3 0f 1e fb          	endbr32 
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bd:	39 c6                	cmp    %eax,%esi
  8009bf:	73 32                	jae    8009f3 <memmove+0x48>
  8009c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c4:	39 c2                	cmp    %eax,%edx
  8009c6:	76 2b                	jbe    8009f3 <memmove+0x48>
		s += n;
		d += n;
  8009c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 fe                	mov    %edi,%esi
  8009cd:	09 ce                	or     %ecx,%esi
  8009cf:	09 d6                	or     %edx,%esi
  8009d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d7:	75 0e                	jne    8009e7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d9:	83 ef 04             	sub    $0x4,%edi
  8009dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009df:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e2:	fd                   	std    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 09                	jmp    8009f0 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e7:	83 ef 01             	sub    $0x1,%edi
  8009ea:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ed:	fd                   	std    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f0:	fc                   	cld    
  8009f1:	eb 1a                	jmp    800a0d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f3:	89 c2                	mov    %eax,%edx
  8009f5:	09 ca                	or     %ecx,%edx
  8009f7:	09 f2                	or     %esi,%edx
  8009f9:	f6 c2 03             	test   $0x3,%dl
  8009fc:	75 0a                	jne    800a08 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fe:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 05                	jmp    800a0d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a08:	89 c7                	mov    %eax,%edi
  800a0a:	fc                   	cld    
  800a0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0d:	5e                   	pop    %esi
  800a0e:	5f                   	pop    %edi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a11:	f3 0f 1e fb          	endbr32 
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1b:	ff 75 10             	pushl  0x10(%ebp)
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	ff 75 08             	pushl  0x8(%ebp)
  800a24:	e8 82 ff ff ff       	call   8009ab <memmove>
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2b:	f3 0f 1e fb          	endbr32 
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3a:	89 c6                	mov    %eax,%esi
  800a3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	39 f0                	cmp    %esi,%eax
  800a41:	74 1c                	je     800a5f <memcmp+0x34>
		if (*s1 != *s2)
  800a43:	0f b6 08             	movzbl (%eax),%ecx
  800a46:	0f b6 1a             	movzbl (%edx),%ebx
  800a49:	38 d9                	cmp    %bl,%cl
  800a4b:	75 08                	jne    800a55 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	83 c2 01             	add    $0x1,%edx
  800a53:	eb ea                	jmp    800a3f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a55:	0f b6 c1             	movzbl %cl,%eax
  800a58:	0f b6 db             	movzbl %bl,%ebx
  800a5b:	29 d8                	sub    %ebx,%eax
  800a5d:	eb 05                	jmp    800a64 <memcmp+0x39>
	}

	return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a68:	f3 0f 1e fb          	endbr32 
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7a:	39 d0                	cmp    %edx,%eax
  800a7c:	73 09                	jae    800a87 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7e:	38 08                	cmp    %cl,(%eax)
  800a80:	74 05                	je     800a87 <memfind+0x1f>
	for (; s < ends; s++)
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	eb f3                	jmp    800a7a <memfind+0x12>
			break;
	return (void *) s;
}
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a89:	f3 0f 1e fb          	endbr32 
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a99:	eb 03                	jmp    800a9e <strtol+0x15>
		s++;
  800a9b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a9e:	0f b6 01             	movzbl (%ecx),%eax
  800aa1:	3c 20                	cmp    $0x20,%al
  800aa3:	74 f6                	je     800a9b <strtol+0x12>
  800aa5:	3c 09                	cmp    $0x9,%al
  800aa7:	74 f2                	je     800a9b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aa9:	3c 2b                	cmp    $0x2b,%al
  800aab:	74 2a                	je     800ad7 <strtol+0x4e>
	int neg = 0;
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab2:	3c 2d                	cmp    $0x2d,%al
  800ab4:	74 2b                	je     800ae1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abc:	75 0f                	jne    800acd <strtol+0x44>
  800abe:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac1:	74 28                	je     800aeb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aca:	0f 44 d8             	cmove  %eax,%ebx
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad5:	eb 46                	jmp    800b1d <strtol+0x94>
		s++;
  800ad7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
  800adf:	eb d5                	jmp    800ab6 <strtol+0x2d>
		s++, neg = 1;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae9:	eb cb                	jmp    800ab6 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aeb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aef:	74 0e                	je     800aff <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	75 d8                	jne    800acd <strtol+0x44>
		s++, base = 8;
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800afd:	eb ce                	jmp    800acd <strtol+0x44>
		s += 2, base = 16;
  800aff:	83 c1 02             	add    $0x2,%ecx
  800b02:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b07:	eb c4                	jmp    800acd <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b09:	0f be d2             	movsbl %dl,%edx
  800b0c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b12:	7d 3a                	jge    800b4e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b14:	83 c1 01             	add    $0x1,%ecx
  800b17:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b1d:	0f b6 11             	movzbl (%ecx),%edx
  800b20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b23:	89 f3                	mov    %esi,%ebx
  800b25:	80 fb 09             	cmp    $0x9,%bl
  800b28:	76 df                	jbe    800b09 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2d:	89 f3                	mov    %esi,%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 08                	ja     800b3c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b34:	0f be d2             	movsbl %dl,%edx
  800b37:	83 ea 57             	sub    $0x57,%edx
  800b3a:	eb d3                	jmp    800b0f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 08                	ja     800b4e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 37             	sub    $0x37,%edx
  800b4c:	eb c1                	jmp    800b0f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b52:	74 05                	je     800b59 <strtol+0xd0>
		*endptr = (char *) s;
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b57:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	f7 da                	neg    %edx
  800b5d:	85 ff                	test   %edi,%edi
  800b5f:	0f 45 c2             	cmovne %edx,%eax
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b67:	f3 0f 1e fb          	endbr32 
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	89 c3                	mov    %eax,%ebx
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	89 c6                	mov    %eax,%esi
  800b82:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9d:	89 d1                	mov    %edx,%ecx
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	89 d7                	mov    %edx,%edi
  800ba3:	89 d6                	mov    %edx,%esi
  800ba5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bac:	f3 0f 1e fb          	endbr32 
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc3:	89 cb                	mov    %ecx,%ebx
  800bc5:	89 cf                	mov    %ecx,%edi
  800bc7:	89 ce                	mov    %ecx,%esi
  800bc9:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcb:	5b                   	pop    %ebx
  800bcc:	5e                   	pop    %esi
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 02 00 00 00       	mov    $0x2,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_yield>:

void
sys_yield(void)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c07:	89 d1                	mov    %edx,%ecx
  800c09:	89 d3                	mov    %edx,%ebx
  800c0b:	89 d7                	mov    %edx,%edi
  800c0d:	89 d6                	mov    %edx,%esi
  800c0f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c16:	f3 0f 1e fb          	endbr32 
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c20:	be 00 00 00 00       	mov    $0x0,%esi
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c33:	89 f7                	mov    %esi,%edi
  800c35:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3c:	f3 0f 1e fb          	endbr32 
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c57:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5a:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c61:	f3 0f 1e fb          	endbr32 
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c86:	f3 0f 1e fb          	endbr32 
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cab:	f3 0f 1e fb          	endbr32 
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd0:	f3 0f 1e fb          	endbr32 
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf5:	f3 0f 1e fb          	endbr32 
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d0a:	be 00 00 00 00       	mov    $0x0,%esi
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1c:	f3 0f 1e fb          	endbr32 
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d33:	89 cb                	mov    %ecx,%ebx
  800d35:	89 cf                	mov    %ecx,%edi
  800d37:	89 ce                	mov    %ecx,%esi
  800d39:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d40:	f3 0f 1e fb          	endbr32 
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d54:	89 d1                	mov    %edx,%ecx
  800d56:	89 d3                	mov    %edx,%ebx
  800d58:	89 d7                	mov    %edx,%edi
  800d5a:	89 d6                	mov    %edx,%esi
  800d5c:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d63:	f3 0f 1e fb          	endbr32 
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800d88:	f3 0f 1e fb          	endbr32 
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	b8 10 00 00 00       	mov    $0x10,%eax
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dad:	f3 0f 1e fb          	endbr32 
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dbc:	c1 e8 0c             	shr    $0xc,%eax
}
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc1:	f3 0f 1e fb          	endbr32 
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800dd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dd5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ddc:	f3 0f 1e fb          	endbr32 
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de8:	89 c2                	mov    %eax,%edx
  800dea:	c1 ea 16             	shr    $0x16,%edx
  800ded:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df4:	f6 c2 01             	test   $0x1,%dl
  800df7:	74 2d                	je     800e26 <fd_alloc+0x4a>
  800df9:	89 c2                	mov    %eax,%edx
  800dfb:	c1 ea 0c             	shr    $0xc,%edx
  800dfe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e05:	f6 c2 01             	test   $0x1,%dl
  800e08:	74 1c                	je     800e26 <fd_alloc+0x4a>
  800e0a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e0f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e14:	75 d2                	jne    800de8 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e1f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e24:	eb 0a                	jmp    800e30 <fd_alloc+0x54>
			*fd_store = fd;
  800e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e29:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e32:	f3 0f 1e fb          	endbr32 
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3c:	83 f8 1f             	cmp    $0x1f,%eax
  800e3f:	77 30                	ja     800e71 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e41:	c1 e0 0c             	shl    $0xc,%eax
  800e44:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e49:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e4f:	f6 c2 01             	test   $0x1,%dl
  800e52:	74 24                	je     800e78 <fd_lookup+0x46>
  800e54:	89 c2                	mov    %eax,%edx
  800e56:	c1 ea 0c             	shr    $0xc,%edx
  800e59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	74 1a                	je     800e7f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e68:	89 02                	mov    %eax,(%edx)
	return 0;
  800e6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    
		return -E_INVAL;
  800e71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e76:	eb f7                	jmp    800e6f <fd_lookup+0x3d>
		return -E_INVAL;
  800e78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7d:	eb f0                	jmp    800e6f <fd_lookup+0x3d>
  800e7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e84:	eb e9                	jmp    800e6f <fd_lookup+0x3d>

00800e86 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e86:	f3 0f 1e fb          	endbr32 
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 08             	sub    $0x8,%esp
  800e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e9d:	39 08                	cmp    %ecx,(%eax)
  800e9f:	74 38                	je     800ed9 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800ea1:	83 c2 01             	add    $0x1,%edx
  800ea4:	8b 04 95 bc 27 80 00 	mov    0x8027bc(,%edx,4),%eax
  800eab:	85 c0                	test   %eax,%eax
  800ead:	75 ee                	jne    800e9d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eaf:	a1 08 40 80 00       	mov    0x804008,%eax
  800eb4:	8b 40 48             	mov    0x48(%eax),%eax
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	51                   	push   %ecx
  800ebb:	50                   	push   %eax
  800ebc:	68 40 27 80 00       	push   $0x802740
  800ec1:	e8 dd f2 ff ff       	call   8001a3 <cprintf>
	*dev = 0;
  800ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    
			*dev = devtab[i];
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	eb f2                	jmp    800ed7 <dev_lookup+0x51>

00800ee5 <fd_close>:
{
  800ee5:	f3 0f 1e fb          	endbr32 
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 24             	sub    $0x24,%esp
  800ef2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800efb:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800efc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f02:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f05:	50                   	push   %eax
  800f06:	e8 27 ff ff ff       	call   800e32 <fd_lookup>
  800f0b:	89 c3                	mov    %eax,%ebx
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	78 05                	js     800f19 <fd_close+0x34>
	    || fd != fd2)
  800f14:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f17:	74 16                	je     800f2f <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f19:	89 f8                	mov    %edi,%eax
  800f1b:	84 c0                	test   %al,%al
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	0f 44 d8             	cmove  %eax,%ebx
}
  800f25:	89 d8                	mov    %ebx,%eax
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f2f:	83 ec 08             	sub    $0x8,%esp
  800f32:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f35:	50                   	push   %eax
  800f36:	ff 36                	pushl  (%esi)
  800f38:	e8 49 ff ff ff       	call   800e86 <dev_lookup>
  800f3d:	89 c3                	mov    %eax,%ebx
  800f3f:	83 c4 10             	add    $0x10,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 1a                	js     800f60 <fd_close+0x7b>
		if (dev->dev_close)
  800f46:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f49:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f4c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f51:	85 c0                	test   %eax,%eax
  800f53:	74 0b                	je     800f60 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	56                   	push   %esi
  800f59:	ff d0                	call   *%eax
  800f5b:	89 c3                	mov    %eax,%ebx
  800f5d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	56                   	push   %esi
  800f64:	6a 00                	push   $0x0
  800f66:	e8 f6 fc ff ff       	call   800c61 <sys_page_unmap>
	return r;
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	eb b5                	jmp    800f25 <fd_close+0x40>

00800f70 <close>:

int
close(int fdnum)
{
  800f70:	f3 0f 1e fb          	endbr32 
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7d:	50                   	push   %eax
  800f7e:	ff 75 08             	pushl  0x8(%ebp)
  800f81:	e8 ac fe ff ff       	call   800e32 <fd_lookup>
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 02                	jns    800f8f <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    
		return fd_close(fd, 1);
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	6a 01                	push   $0x1
  800f94:	ff 75 f4             	pushl  -0xc(%ebp)
  800f97:	e8 49 ff ff ff       	call   800ee5 <fd_close>
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	eb ec                	jmp    800f8d <close+0x1d>

00800fa1 <close_all>:

void
close_all(void)
{
  800fa1:	f3 0f 1e fb          	endbr32 
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	53                   	push   %ebx
  800fb5:	e8 b6 ff ff ff       	call   800f70 <close>
	for (i = 0; i < MAXFD; i++)
  800fba:	83 c3 01             	add    $0x1,%ebx
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	83 fb 20             	cmp    $0x20,%ebx
  800fc3:	75 ec                	jne    800fb1 <close_all+0x10>
}
  800fc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fca:	f3 0f 1e fb          	endbr32 
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fda:	50                   	push   %eax
  800fdb:	ff 75 08             	pushl  0x8(%ebp)
  800fde:	e8 4f fe ff ff       	call   800e32 <fd_lookup>
  800fe3:	89 c3                	mov    %eax,%ebx
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	0f 88 81 00 00 00    	js     801071 <dup+0xa7>
		return r;
	close(newfdnum);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	ff 75 0c             	pushl  0xc(%ebp)
  800ff6:	e8 75 ff ff ff       	call   800f70 <close>

	newfd = INDEX2FD(newfdnum);
  800ffb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ffe:	c1 e6 0c             	shl    $0xc,%esi
  801001:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801007:	83 c4 04             	add    $0x4,%esp
  80100a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100d:	e8 af fd ff ff       	call   800dc1 <fd2data>
  801012:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801014:	89 34 24             	mov    %esi,(%esp)
  801017:	e8 a5 fd ff ff       	call   800dc1 <fd2data>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801021:	89 d8                	mov    %ebx,%eax
  801023:	c1 e8 16             	shr    $0x16,%eax
  801026:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102d:	a8 01                	test   $0x1,%al
  80102f:	74 11                	je     801042 <dup+0x78>
  801031:	89 d8                	mov    %ebx,%eax
  801033:	c1 e8 0c             	shr    $0xc,%eax
  801036:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103d:	f6 c2 01             	test   $0x1,%dl
  801040:	75 39                	jne    80107b <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801042:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801045:	89 d0                	mov    %edx,%eax
  801047:	c1 e8 0c             	shr    $0xc,%eax
  80104a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	25 07 0e 00 00       	and    $0xe07,%eax
  801059:	50                   	push   %eax
  80105a:	56                   	push   %esi
  80105b:	6a 00                	push   $0x0
  80105d:	52                   	push   %edx
  80105e:	6a 00                	push   $0x0
  801060:	e8 d7 fb ff ff       	call   800c3c <sys_page_map>
  801065:	89 c3                	mov    %eax,%ebx
  801067:	83 c4 20             	add    $0x20,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 31                	js     80109f <dup+0xd5>
		goto err;

	return newfdnum;
  80106e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801071:	89 d8                	mov    %ebx,%eax
  801073:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80107b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	25 07 0e 00 00       	and    $0xe07,%eax
  80108a:	50                   	push   %eax
  80108b:	57                   	push   %edi
  80108c:	6a 00                	push   $0x0
  80108e:	53                   	push   %ebx
  80108f:	6a 00                	push   $0x0
  801091:	e8 a6 fb ff ff       	call   800c3c <sys_page_map>
  801096:	89 c3                	mov    %eax,%ebx
  801098:	83 c4 20             	add    $0x20,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	79 a3                	jns    801042 <dup+0x78>
	sys_page_unmap(0, newfd);
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	56                   	push   %esi
  8010a3:	6a 00                	push   $0x0
  8010a5:	e8 b7 fb ff ff       	call   800c61 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010aa:	83 c4 08             	add    $0x8,%esp
  8010ad:	57                   	push   %edi
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 ac fb ff ff       	call   800c61 <sys_page_unmap>
	return r;
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	eb b7                	jmp    801071 <dup+0xa7>

008010ba <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ba:	f3 0f 1e fb          	endbr32 
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 1c             	sub    $0x1c,%esp
  8010c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	53                   	push   %ebx
  8010cd:	e8 60 fd ff ff       	call   800e32 <fd_lookup>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 3f                	js     801118 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d9:	83 ec 08             	sub    $0x8,%esp
  8010dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e3:	ff 30                	pushl  (%eax)
  8010e5:	e8 9c fd ff ff       	call   800e86 <dev_lookup>
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 27                	js     801118 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f4:	8b 42 08             	mov    0x8(%edx),%eax
  8010f7:	83 e0 03             	and    $0x3,%eax
  8010fa:	83 f8 01             	cmp    $0x1,%eax
  8010fd:	74 1e                	je     80111d <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801102:	8b 40 08             	mov    0x8(%eax),%eax
  801105:	85 c0                	test   %eax,%eax
  801107:	74 35                	je     80113e <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	ff 75 10             	pushl  0x10(%ebp)
  80110f:	ff 75 0c             	pushl  0xc(%ebp)
  801112:	52                   	push   %edx
  801113:	ff d0                	call   *%eax
  801115:	83 c4 10             	add    $0x10,%esp
}
  801118:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111d:	a1 08 40 80 00       	mov    0x804008,%eax
  801122:	8b 40 48             	mov    0x48(%eax),%eax
  801125:	83 ec 04             	sub    $0x4,%esp
  801128:	53                   	push   %ebx
  801129:	50                   	push   %eax
  80112a:	68 81 27 80 00       	push   $0x802781
  80112f:	e8 6f f0 ff ff       	call   8001a3 <cprintf>
		return -E_INVAL;
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113c:	eb da                	jmp    801118 <read+0x5e>
		return -E_NOT_SUPP;
  80113e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801143:	eb d3                	jmp    801118 <read+0x5e>

00801145 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801145:	f3 0f 1e fb          	endbr32 
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	8b 7d 08             	mov    0x8(%ebp),%edi
  801155:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801158:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115d:	eb 02                	jmp    801161 <readn+0x1c>
  80115f:	01 c3                	add    %eax,%ebx
  801161:	39 f3                	cmp    %esi,%ebx
  801163:	73 21                	jae    801186 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	89 f0                	mov    %esi,%eax
  80116a:	29 d8                	sub    %ebx,%eax
  80116c:	50                   	push   %eax
  80116d:	89 d8                	mov    %ebx,%eax
  80116f:	03 45 0c             	add    0xc(%ebp),%eax
  801172:	50                   	push   %eax
  801173:	57                   	push   %edi
  801174:	e8 41 ff ff ff       	call   8010ba <read>
		if (m < 0)
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	78 04                	js     801184 <readn+0x3f>
			return m;
		if (m == 0)
  801180:	75 dd                	jne    80115f <readn+0x1a>
  801182:	eb 02                	jmp    801186 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801184:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801186:	89 d8                	mov    %ebx,%eax
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801190:	f3 0f 1e fb          	endbr32 
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	53                   	push   %ebx
  801198:	83 ec 1c             	sub    $0x1c,%esp
  80119b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	53                   	push   %ebx
  8011a3:	e8 8a fc ff ff       	call   800e32 <fd_lookup>
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 3a                	js     8011e9 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b9:	ff 30                	pushl  (%eax)
  8011bb:	e8 c6 fc ff ff       	call   800e86 <dev_lookup>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 22                	js     8011e9 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ce:	74 1e                	je     8011ee <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8011d6:	85 d2                	test   %edx,%edx
  8011d8:	74 35                	je     80120f <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	ff 75 10             	pushl  0x10(%ebp)
  8011e0:	ff 75 0c             	pushl  0xc(%ebp)
  8011e3:	50                   	push   %eax
  8011e4:	ff d2                	call   *%edx
  8011e6:	83 c4 10             	add    $0x10,%esp
}
  8011e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f3:	8b 40 48             	mov    0x48(%eax),%eax
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	53                   	push   %ebx
  8011fa:	50                   	push   %eax
  8011fb:	68 9d 27 80 00       	push   $0x80279d
  801200:	e8 9e ef ff ff       	call   8001a3 <cprintf>
		return -E_INVAL;
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120d:	eb da                	jmp    8011e9 <write+0x59>
		return -E_NOT_SUPP;
  80120f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801214:	eb d3                	jmp    8011e9 <write+0x59>

00801216 <seek>:

int
seek(int fdnum, off_t offset)
{
  801216:	f3 0f 1e fb          	endbr32 
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801220:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	ff 75 08             	pushl  0x8(%ebp)
  801227:	e8 06 fc ff ff       	call   800e32 <fd_lookup>
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 0e                	js     801241 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801233:	8b 55 0c             	mov    0xc(%ebp),%edx
  801236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801239:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801243:	f3 0f 1e fb          	endbr32 
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	53                   	push   %ebx
  80124b:	83 ec 1c             	sub    $0x1c,%esp
  80124e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801251:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801254:	50                   	push   %eax
  801255:	53                   	push   %ebx
  801256:	e8 d7 fb ff ff       	call   800e32 <fd_lookup>
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 37                	js     801299 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126c:	ff 30                	pushl  (%eax)
  80126e:	e8 13 fc ff ff       	call   800e86 <dev_lookup>
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 1f                	js     801299 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801281:	74 1b                	je     80129e <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801283:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801286:	8b 52 18             	mov    0x18(%edx),%edx
  801289:	85 d2                	test   %edx,%edx
  80128b:	74 32                	je     8012bf <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	ff 75 0c             	pushl  0xc(%ebp)
  801293:	50                   	push   %eax
  801294:	ff d2                	call   *%edx
  801296:	83 c4 10             	add    $0x10,%esp
}
  801299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80129e:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a3:	8b 40 48             	mov    0x48(%eax),%eax
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	53                   	push   %ebx
  8012aa:	50                   	push   %eax
  8012ab:	68 60 27 80 00       	push   $0x802760
  8012b0:	e8 ee ee ff ff       	call   8001a3 <cprintf>
		return -E_INVAL;
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bd:	eb da                	jmp    801299 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c4:	eb d3                	jmp    801299 <ftruncate+0x56>

008012c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c6:	f3 0f 1e fb          	endbr32 
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 1c             	sub    $0x1c,%esp
  8012d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d7:	50                   	push   %eax
  8012d8:	ff 75 08             	pushl  0x8(%ebp)
  8012db:	e8 52 fb ff ff       	call   800e32 <fd_lookup>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 4b                	js     801332 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ed:	50                   	push   %eax
  8012ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f1:	ff 30                	pushl  (%eax)
  8012f3:	e8 8e fb ff ff       	call   800e86 <dev_lookup>
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 33                	js     801332 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8012ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801302:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801306:	74 2f                	je     801337 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801308:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80130b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801312:	00 00 00 
	stat->st_isdir = 0;
  801315:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80131c:	00 00 00 
	stat->st_dev = dev;
  80131f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	53                   	push   %ebx
  801329:	ff 75 f0             	pushl  -0x10(%ebp)
  80132c:	ff 50 14             	call   *0x14(%eax)
  80132f:	83 c4 10             	add    $0x10,%esp
}
  801332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801335:	c9                   	leave  
  801336:	c3                   	ret    
		return -E_NOT_SUPP;
  801337:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80133c:	eb f4                	jmp    801332 <fstat+0x6c>

0080133e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80133e:	f3 0f 1e fb          	endbr32 
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	56                   	push   %esi
  801346:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	6a 00                	push   $0x0
  80134c:	ff 75 08             	pushl  0x8(%ebp)
  80134f:	e8 01 02 00 00       	call   801555 <open>
  801354:	89 c3                	mov    %eax,%ebx
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 1b                	js     801378 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	ff 75 0c             	pushl  0xc(%ebp)
  801363:	50                   	push   %eax
  801364:	e8 5d ff ff ff       	call   8012c6 <fstat>
  801369:	89 c6                	mov    %eax,%esi
	close(fd);
  80136b:	89 1c 24             	mov    %ebx,(%esp)
  80136e:	e8 fd fb ff ff       	call   800f70 <close>
	return r;
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	89 f3                	mov    %esi,%ebx
}
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	89 c6                	mov    %eax,%esi
  801388:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80138a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801391:	74 27                	je     8013ba <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801393:	6a 07                	push   $0x7
  801395:	68 00 50 80 00       	push   $0x805000
  80139a:	56                   	push   %esi
  80139b:	ff 35 00 40 80 00    	pushl  0x804000
  8013a1:	e8 c6 0c 00 00       	call   80206c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013a6:	83 c4 0c             	add    $0xc,%esp
  8013a9:	6a 00                	push   $0x0
  8013ab:	53                   	push   %ebx
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 4c 0c 00 00       	call   801fff <ipc_recv>
}
  8013b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b6:	5b                   	pop    %ebx
  8013b7:	5e                   	pop    %esi
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	6a 01                	push   $0x1
  8013bf:	e8 00 0d 00 00       	call   8020c4 <ipc_find_env>
  8013c4:	a3 00 40 80 00       	mov    %eax,0x804000
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	eb c5                	jmp    801393 <fsipc+0x12>

008013ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ce:	f3 0f 1e fb          	endbr32 
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	8b 40 0c             	mov    0xc(%eax),%eax
  8013de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f5:	e8 87 ff ff ff       	call   801381 <fsipc>
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devfile_flush>:
{
  8013fc:	f3 0f 1e fb          	endbr32 
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801406:	8b 45 08             	mov    0x8(%ebp),%eax
  801409:	8b 40 0c             	mov    0xc(%eax),%eax
  80140c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801411:	ba 00 00 00 00       	mov    $0x0,%edx
  801416:	b8 06 00 00 00       	mov    $0x6,%eax
  80141b:	e8 61 ff ff ff       	call   801381 <fsipc>
}
  801420:	c9                   	leave  
  801421:	c3                   	ret    

00801422 <devfile_stat>:
{
  801422:	f3 0f 1e fb          	endbr32 
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	53                   	push   %ebx
  80142a:	83 ec 04             	sub    $0x4,%esp
  80142d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80143b:	ba 00 00 00 00       	mov    $0x0,%edx
  801440:	b8 05 00 00 00       	mov    $0x5,%eax
  801445:	e8 37 ff ff ff       	call   801381 <fsipc>
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 2c                	js     80147a <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	68 00 50 80 00       	push   $0x805000
  801456:	53                   	push   %ebx
  801457:	e8 51 f3 ff ff       	call   8007ad <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80145c:	a1 80 50 80 00       	mov    0x805080,%eax
  801461:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801467:	a1 84 50 80 00       	mov    0x805084,%eax
  80146c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <devfile_write>:
{
  80147f:	f3 0f 1e fb          	endbr32 
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	8b 45 10             	mov    0x10(%ebp),%eax
  80148c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801491:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801496:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801499:	8b 55 08             	mov    0x8(%ebp),%edx
  80149c:	8b 52 0c             	mov    0xc(%edx),%edx
  80149f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014a5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014aa:	50                   	push   %eax
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	68 08 50 80 00       	push   $0x805008
  8014b3:	e8 f3 f4 ff ff       	call   8009ab <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c2:	e8 ba fe ff ff       	call   801381 <fsipc>
}
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <devfile_read>:
{
  8014c9:	f3 0f 1e fb          	endbr32 
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
  8014d2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014e0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f0:	e8 8c fe ff ff       	call   801381 <fsipc>
  8014f5:	89 c3                	mov    %eax,%ebx
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 1f                	js     80151a <devfile_read+0x51>
	assert(r <= n);
  8014fb:	39 f0                	cmp    %esi,%eax
  8014fd:	77 24                	ja     801523 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014ff:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801504:	7f 36                	jg     80153c <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801506:	83 ec 04             	sub    $0x4,%esp
  801509:	50                   	push   %eax
  80150a:	68 00 50 80 00       	push   $0x805000
  80150f:	ff 75 0c             	pushl  0xc(%ebp)
  801512:	e8 94 f4 ff ff       	call   8009ab <memmove>
	return r;
  801517:	83 c4 10             	add    $0x10,%esp
}
  80151a:	89 d8                	mov    %ebx,%eax
  80151c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151f:	5b                   	pop    %ebx
  801520:	5e                   	pop    %esi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    
	assert(r <= n);
  801523:	68 d0 27 80 00       	push   $0x8027d0
  801528:	68 d7 27 80 00       	push   $0x8027d7
  80152d:	68 8c 00 00 00       	push   $0x8c
  801532:	68 ec 27 80 00       	push   $0x8027ec
  801537:	e8 79 0a 00 00       	call   801fb5 <_panic>
	assert(r <= PGSIZE);
  80153c:	68 f7 27 80 00       	push   $0x8027f7
  801541:	68 d7 27 80 00       	push   $0x8027d7
  801546:	68 8d 00 00 00       	push   $0x8d
  80154b:	68 ec 27 80 00       	push   $0x8027ec
  801550:	e8 60 0a 00 00       	call   801fb5 <_panic>

00801555 <open>:
{
  801555:	f3 0f 1e fb          	endbr32 
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	83 ec 1c             	sub    $0x1c,%esp
  801561:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801564:	56                   	push   %esi
  801565:	e8 00 f2 ff ff       	call   80076a <strlen>
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801572:	7f 6c                	jg     8015e0 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	e8 5c f8 ff ff       	call   800ddc <fd_alloc>
  801580:	89 c3                	mov    %eax,%ebx
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	78 3c                	js     8015c5 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	56                   	push   %esi
  80158d:	68 00 50 80 00       	push   $0x805000
  801592:	e8 16 f2 ff ff       	call   8007ad <strcpy>
	fsipcbuf.open.req_omode = mode;
  801597:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80159f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a7:	e8 d5 fd ff ff       	call   801381 <fsipc>
  8015ac:	89 c3                	mov    %eax,%ebx
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 19                	js     8015ce <open+0x79>
	return fd2num(fd);
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bb:	e8 ed f7 ff ff       	call   800dad <fd2num>
  8015c0:	89 c3                	mov    %eax,%ebx
  8015c2:	83 c4 10             	add    $0x10,%esp
}
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    
		fd_close(fd, 0);
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	6a 00                	push   $0x0
  8015d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d6:	e8 0a f9 ff ff       	call   800ee5 <fd_close>
		return r;
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	eb e5                	jmp    8015c5 <open+0x70>
		return -E_BAD_PATH;
  8015e0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015e5:	eb de                	jmp    8015c5 <open+0x70>

008015e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e7:	f3 0f 1e fb          	endbr32 
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8015fb:	e8 81 fd ff ff       	call   801381 <fsipc>
}
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801602:	f3 0f 1e fb          	endbr32 
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80160c:	68 63 28 80 00       	push   $0x802863
  801611:	ff 75 0c             	pushl  0xc(%ebp)
  801614:	e8 94 f1 ff ff       	call   8007ad <strcpy>
	return 0;
}
  801619:	b8 00 00 00 00       	mov    $0x0,%eax
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <devsock_close>:
{
  801620:	f3 0f 1e fb          	endbr32 
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	53                   	push   %ebx
  801628:	83 ec 10             	sub    $0x10,%esp
  80162b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80162e:	53                   	push   %ebx
  80162f:	e8 cd 0a 00 00       	call   802101 <pageref>
  801634:	89 c2                	mov    %eax,%edx
  801636:	83 c4 10             	add    $0x10,%esp
		return 0;
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80163e:	83 fa 01             	cmp    $0x1,%edx
  801641:	74 05                	je     801648 <devsock_close+0x28>
}
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	ff 73 0c             	pushl  0xc(%ebx)
  80164e:	e8 e3 02 00 00       	call   801936 <nsipc_close>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	eb eb                	jmp    801643 <devsock_close+0x23>

00801658 <devsock_write>:
{
  801658:	f3 0f 1e fb          	endbr32 
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801662:	6a 00                	push   $0x0
  801664:	ff 75 10             	pushl  0x10(%ebp)
  801667:	ff 75 0c             	pushl  0xc(%ebp)
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	ff 70 0c             	pushl  0xc(%eax)
  801670:	e8 b5 03 00 00       	call   801a2a <nsipc_send>
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <devsock_read>:
{
  801677:	f3 0f 1e fb          	endbr32 
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801681:	6a 00                	push   $0x0
  801683:	ff 75 10             	pushl  0x10(%ebp)
  801686:	ff 75 0c             	pushl  0xc(%ebp)
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	ff 70 0c             	pushl  0xc(%eax)
  80168f:	e8 1f 03 00 00       	call   8019b3 <nsipc_recv>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <fd2sockid>:
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80169c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80169f:	52                   	push   %edx
  8016a0:	50                   	push   %eax
  8016a1:	e8 8c f7 ff ff       	call   800e32 <fd_lookup>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 10                	js     8016bd <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8016ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b0:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  8016b6:	39 08                	cmp    %ecx,(%eax)
  8016b8:	75 05                	jne    8016bf <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8016ba:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    
		return -E_NOT_SUPP;
  8016bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c4:	eb f7                	jmp    8016bd <fd2sockid+0x27>

008016c6 <alloc_sockfd>:
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 1c             	sub    $0x1c,%esp
  8016ce:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8016d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d3:	50                   	push   %eax
  8016d4:	e8 03 f7 ff ff       	call   800ddc <fd_alloc>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 43                	js     801725 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016e2:	83 ec 04             	sub    $0x4,%esp
  8016e5:	68 07 04 00 00       	push   $0x407
  8016ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ed:	6a 00                	push   $0x0
  8016ef:	e8 22 f5 ff ff       	call   800c16 <sys_page_alloc>
  8016f4:	89 c3                	mov    %eax,%ebx
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 28                	js     801725 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8016fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801700:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801706:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801712:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801715:	83 ec 0c             	sub    $0xc,%esp
  801718:	50                   	push   %eax
  801719:	e8 8f f6 ff ff       	call   800dad <fd2num>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	eb 0c                	jmp    801731 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801725:	83 ec 0c             	sub    $0xc,%esp
  801728:	56                   	push   %esi
  801729:	e8 08 02 00 00       	call   801936 <nsipc_close>
		return r;
  80172e:	83 c4 10             	add    $0x10,%esp
}
  801731:	89 d8                	mov    %ebx,%eax
  801733:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801736:	5b                   	pop    %ebx
  801737:	5e                   	pop    %esi
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <accept>:
{
  80173a:	f3 0f 1e fb          	endbr32 
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
  801747:	e8 4a ff ff ff       	call   801696 <fd2sockid>
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 1b                	js     80176b <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	ff 75 10             	pushl  0x10(%ebp)
  801756:	ff 75 0c             	pushl  0xc(%ebp)
  801759:	50                   	push   %eax
  80175a:	e8 22 01 00 00       	call   801881 <nsipc_accept>
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	85 c0                	test   %eax,%eax
  801764:	78 05                	js     80176b <accept+0x31>
	return alloc_sockfd(r);
  801766:	e8 5b ff ff ff       	call   8016c6 <alloc_sockfd>
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <bind>:
{
  80176d:	f3 0f 1e fb          	endbr32 
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
  80177a:	e8 17 ff ff ff       	call   801696 <fd2sockid>
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 12                	js     801795 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801783:	83 ec 04             	sub    $0x4,%esp
  801786:	ff 75 10             	pushl  0x10(%ebp)
  801789:	ff 75 0c             	pushl  0xc(%ebp)
  80178c:	50                   	push   %eax
  80178d:	e8 45 01 00 00       	call   8018d7 <nsipc_bind>
  801792:	83 c4 10             	add    $0x10,%esp
}
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <shutdown>:
{
  801797:	f3 0f 1e fb          	endbr32 
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	e8 ed fe ff ff       	call   801696 <fd2sockid>
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 0f                	js     8017bc <shutdown+0x25>
	return nsipc_shutdown(r, how);
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	ff 75 0c             	pushl  0xc(%ebp)
  8017b3:	50                   	push   %eax
  8017b4:	e8 57 01 00 00       	call   801910 <nsipc_shutdown>
  8017b9:	83 c4 10             	add    $0x10,%esp
}
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <connect>:
{
  8017be:	f3 0f 1e fb          	endbr32 
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	e8 c6 fe ff ff       	call   801696 <fd2sockid>
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 12                	js     8017e6 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8017d4:	83 ec 04             	sub    $0x4,%esp
  8017d7:	ff 75 10             	pushl  0x10(%ebp)
  8017da:	ff 75 0c             	pushl  0xc(%ebp)
  8017dd:	50                   	push   %eax
  8017de:	e8 71 01 00 00       	call   801954 <nsipc_connect>
  8017e3:	83 c4 10             	add    $0x10,%esp
}
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <listen>:
{
  8017e8:	f3 0f 1e fb          	endbr32 
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	e8 9c fe ff ff       	call   801696 <fd2sockid>
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 0f                	js     80180d <listen+0x25>
	return nsipc_listen(r, backlog);
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	ff 75 0c             	pushl  0xc(%ebp)
  801804:	50                   	push   %eax
  801805:	e8 83 01 00 00       	call   80198d <nsipc_listen>
  80180a:	83 c4 10             	add    $0x10,%esp
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <socket>:

int
socket(int domain, int type, int protocol)
{
  80180f:	f3 0f 1e fb          	endbr32 
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801819:	ff 75 10             	pushl  0x10(%ebp)
  80181c:	ff 75 0c             	pushl  0xc(%ebp)
  80181f:	ff 75 08             	pushl  0x8(%ebp)
  801822:	e8 65 02 00 00       	call   801a8c <nsipc_socket>
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 05                	js     801833 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  80182e:	e8 93 fe ff ff       	call   8016c6 <alloc_sockfd>
}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	53                   	push   %ebx
  801839:	83 ec 04             	sub    $0x4,%esp
  80183c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80183e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801845:	74 26                	je     80186d <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801847:	6a 07                	push   $0x7
  801849:	68 00 60 80 00       	push   $0x806000
  80184e:	53                   	push   %ebx
  80184f:	ff 35 04 40 80 00    	pushl  0x804004
  801855:	e8 12 08 00 00       	call   80206c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80185a:	83 c4 0c             	add    $0xc,%esp
  80185d:	6a 00                	push   $0x0
  80185f:	6a 00                	push   $0x0
  801861:	6a 00                	push   $0x0
  801863:	e8 97 07 00 00       	call   801fff <ipc_recv>
}
  801868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	6a 02                	push   $0x2
  801872:	e8 4d 08 00 00       	call   8020c4 <ipc_find_env>
  801877:	a3 04 40 80 00       	mov    %eax,0x804004
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	eb c6                	jmp    801847 <nsipc+0x12>

00801881 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801881:	f3 0f 1e fb          	endbr32 
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	56                   	push   %esi
  801889:	53                   	push   %ebx
  80188a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801895:	8b 06                	mov    (%esi),%eax
  801897:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80189c:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a1:	e8 8f ff ff ff       	call   801835 <nsipc>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	79 09                	jns    8018b5 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8018ac:	89 d8                	mov    %ebx,%eax
  8018ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b1:	5b                   	pop    %ebx
  8018b2:	5e                   	pop    %esi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018b5:	83 ec 04             	sub    $0x4,%esp
  8018b8:	ff 35 10 60 80 00    	pushl  0x806010
  8018be:	68 00 60 80 00       	push   $0x806000
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	e8 e0 f0 ff ff       	call   8009ab <memmove>
		*addrlen = ret->ret_addrlen;
  8018cb:	a1 10 60 80 00       	mov    0x806010,%eax
  8018d0:	89 06                	mov    %eax,(%esi)
  8018d2:	83 c4 10             	add    $0x10,%esp
	return r;
  8018d5:	eb d5                	jmp    8018ac <nsipc_accept+0x2b>

008018d7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018d7:	f3 0f 1e fb          	endbr32 
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	53                   	push   %ebx
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018ed:	53                   	push   %ebx
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	68 04 60 80 00       	push   $0x806004
  8018f6:	e8 b0 f0 ff ff       	call   8009ab <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018fb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801901:	b8 02 00 00 00       	mov    $0x2,%eax
  801906:	e8 2a ff ff ff       	call   801835 <nsipc>
}
  80190b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801910:	f3 0f 1e fb          	endbr32 
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801922:	8b 45 0c             	mov    0xc(%ebp),%eax
  801925:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80192a:	b8 03 00 00 00       	mov    $0x3,%eax
  80192f:	e8 01 ff ff ff       	call   801835 <nsipc>
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <nsipc_close>:

int
nsipc_close(int s)
{
  801936:	f3 0f 1e fb          	endbr32 
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801940:	8b 45 08             	mov    0x8(%ebp),%eax
  801943:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801948:	b8 04 00 00 00       	mov    $0x4,%eax
  80194d:	e8 e3 fe ff ff       	call   801835 <nsipc>
}
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801954:	f3 0f 1e fb          	endbr32 
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	53                   	push   %ebx
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80196a:	53                   	push   %ebx
  80196b:	ff 75 0c             	pushl  0xc(%ebp)
  80196e:	68 04 60 80 00       	push   $0x806004
  801973:	e8 33 f0 ff ff       	call   8009ab <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801978:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80197e:	b8 05 00 00 00       	mov    $0x5,%eax
  801983:	e8 ad fe ff ff       	call   801835 <nsipc>
}
  801988:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80198d:	f3 0f 1e fb          	endbr32 
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80199f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ac:	e8 84 fe ff ff       	call   801835 <nsipc>
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019b3:	f3 0f 1e fb          	endbr32 
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019c7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019d5:	b8 07 00 00 00       	mov    $0x7,%eax
  8019da:	e8 56 fe ff ff       	call   801835 <nsipc>
  8019df:	89 c3                	mov    %eax,%ebx
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	78 26                	js     801a0b <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8019e5:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8019eb:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019f0:	0f 4e c6             	cmovle %esi,%eax
  8019f3:	39 c3                	cmp    %eax,%ebx
  8019f5:	7f 1d                	jg     801a14 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019f7:	83 ec 04             	sub    $0x4,%esp
  8019fa:	53                   	push   %ebx
  8019fb:	68 00 60 80 00       	push   $0x806000
  801a00:	ff 75 0c             	pushl  0xc(%ebp)
  801a03:	e8 a3 ef ff ff       	call   8009ab <memmove>
  801a08:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a0b:	89 d8                	mov    %ebx,%eax
  801a0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a14:	68 6f 28 80 00       	push   $0x80286f
  801a19:	68 d7 27 80 00       	push   $0x8027d7
  801a1e:	6a 62                	push   $0x62
  801a20:	68 84 28 80 00       	push   $0x802884
  801a25:	e8 8b 05 00 00       	call   801fb5 <_panic>

00801a2a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a2a:	f3 0f 1e fb          	endbr32 
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	53                   	push   %ebx
  801a32:	83 ec 04             	sub    $0x4,%esp
  801a35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a40:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a46:	7f 2e                	jg     801a76 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a48:	83 ec 04             	sub    $0x4,%esp
  801a4b:	53                   	push   %ebx
  801a4c:	ff 75 0c             	pushl  0xc(%ebp)
  801a4f:	68 0c 60 80 00       	push   $0x80600c
  801a54:	e8 52 ef ff ff       	call   8009ab <memmove>
	nsipcbuf.send.req_size = size;
  801a59:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a62:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a67:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6c:	e8 c4 fd ff ff       	call   801835 <nsipc>
}
  801a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    
	assert(size < 1600);
  801a76:	68 90 28 80 00       	push   $0x802890
  801a7b:	68 d7 27 80 00       	push   $0x8027d7
  801a80:	6a 6d                	push   $0x6d
  801a82:	68 84 28 80 00       	push   $0x802884
  801a87:	e8 29 05 00 00       	call   801fb5 <_panic>

00801a8c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a8c:	f3 0f 1e fb          	endbr32 
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801aae:	b8 09 00 00 00       	mov    $0x9,%eax
  801ab3:	e8 7d fd ff ff       	call   801835 <nsipc>
}
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aba:	f3 0f 1e fb          	endbr32 
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	56                   	push   %esi
  801ac2:	53                   	push   %ebx
  801ac3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	ff 75 08             	pushl  0x8(%ebp)
  801acc:	e8 f0 f2 ff ff       	call   800dc1 <fd2data>
  801ad1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ad3:	83 c4 08             	add    $0x8,%esp
  801ad6:	68 9c 28 80 00       	push   $0x80289c
  801adb:	53                   	push   %ebx
  801adc:	e8 cc ec ff ff       	call   8007ad <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ae1:	8b 46 04             	mov    0x4(%esi),%eax
  801ae4:	2b 06                	sub    (%esi),%eax
  801ae6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801af3:	00 00 00 
	stat->st_dev = &devpipe;
  801af6:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801afd:	30 80 00 
	return 0;
}
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
  801b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b08:	5b                   	pop    %ebx
  801b09:	5e                   	pop    %esi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b0c:	f3 0f 1e fb          	endbr32 
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	53                   	push   %ebx
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b1a:	53                   	push   %ebx
  801b1b:	6a 00                	push   $0x0
  801b1d:	e8 3f f1 ff ff       	call   800c61 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b22:	89 1c 24             	mov    %ebx,(%esp)
  801b25:	e8 97 f2 ff ff       	call   800dc1 <fd2data>
  801b2a:	83 c4 08             	add    $0x8,%esp
  801b2d:	50                   	push   %eax
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 2c f1 ff ff       	call   800c61 <sys_page_unmap>
}
  801b35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <_pipeisclosed>:
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 1c             	sub    $0x1c,%esp
  801b43:	89 c7                	mov    %eax,%edi
  801b45:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b47:	a1 08 40 80 00       	mov    0x804008,%eax
  801b4c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	57                   	push   %edi
  801b53:	e8 a9 05 00 00       	call   802101 <pageref>
  801b58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b5b:	89 34 24             	mov    %esi,(%esp)
  801b5e:	e8 9e 05 00 00       	call   802101 <pageref>
		nn = thisenv->env_runs;
  801b63:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b69:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	39 cb                	cmp    %ecx,%ebx
  801b71:	74 1b                	je     801b8e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b73:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b76:	75 cf                	jne    801b47 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b78:	8b 42 58             	mov    0x58(%edx),%eax
  801b7b:	6a 01                	push   $0x1
  801b7d:	50                   	push   %eax
  801b7e:	53                   	push   %ebx
  801b7f:	68 a3 28 80 00       	push   $0x8028a3
  801b84:	e8 1a e6 ff ff       	call   8001a3 <cprintf>
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	eb b9                	jmp    801b47 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b8e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b91:	0f 94 c0             	sete   %al
  801b94:	0f b6 c0             	movzbl %al,%eax
}
  801b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9a:	5b                   	pop    %ebx
  801b9b:	5e                   	pop    %esi
  801b9c:	5f                   	pop    %edi
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <devpipe_write>:
{
  801b9f:	f3 0f 1e fb          	endbr32 
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	57                   	push   %edi
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 28             	sub    $0x28,%esp
  801bac:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801baf:	56                   	push   %esi
  801bb0:	e8 0c f2 ff ff       	call   800dc1 <fd2data>
  801bb5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	bf 00 00 00 00       	mov    $0x0,%edi
  801bbf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bc2:	74 4f                	je     801c13 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc4:	8b 43 04             	mov    0x4(%ebx),%eax
  801bc7:	8b 0b                	mov    (%ebx),%ecx
  801bc9:	8d 51 20             	lea    0x20(%ecx),%edx
  801bcc:	39 d0                	cmp    %edx,%eax
  801bce:	72 14                	jb     801be4 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801bd0:	89 da                	mov    %ebx,%edx
  801bd2:	89 f0                	mov    %esi,%eax
  801bd4:	e8 61 ff ff ff       	call   801b3a <_pipeisclosed>
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	75 3b                	jne    801c18 <devpipe_write+0x79>
			sys_yield();
  801bdd:	e8 11 f0 ff ff       	call   800bf3 <sys_yield>
  801be2:	eb e0                	jmp    801bc4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801beb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bee:	89 c2                	mov    %eax,%edx
  801bf0:	c1 fa 1f             	sar    $0x1f,%edx
  801bf3:	89 d1                	mov    %edx,%ecx
  801bf5:	c1 e9 1b             	shr    $0x1b,%ecx
  801bf8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bfb:	83 e2 1f             	and    $0x1f,%edx
  801bfe:	29 ca                	sub    %ecx,%edx
  801c00:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c04:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c08:	83 c0 01             	add    $0x1,%eax
  801c0b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c0e:	83 c7 01             	add    $0x1,%edi
  801c11:	eb ac                	jmp    801bbf <devpipe_write+0x20>
	return i;
  801c13:	8b 45 10             	mov    0x10(%ebp),%eax
  801c16:	eb 05                	jmp    801c1d <devpipe_write+0x7e>
				return 0;
  801c18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <devpipe_read>:
{
  801c25:	f3 0f 1e fb          	endbr32 
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	57                   	push   %edi
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	83 ec 18             	sub    $0x18,%esp
  801c32:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c35:	57                   	push   %edi
  801c36:	e8 86 f1 ff ff       	call   800dc1 <fd2data>
  801c3b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	be 00 00 00 00       	mov    $0x0,%esi
  801c45:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c48:	75 14                	jne    801c5e <devpipe_read+0x39>
	return i;
  801c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4d:	eb 02                	jmp    801c51 <devpipe_read+0x2c>
				return i;
  801c4f:	89 f0                	mov    %esi,%eax
}
  801c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
			sys_yield();
  801c59:	e8 95 ef ff ff       	call   800bf3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c5e:	8b 03                	mov    (%ebx),%eax
  801c60:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c63:	75 18                	jne    801c7d <devpipe_read+0x58>
			if (i > 0)
  801c65:	85 f6                	test   %esi,%esi
  801c67:	75 e6                	jne    801c4f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c69:	89 da                	mov    %ebx,%edx
  801c6b:	89 f8                	mov    %edi,%eax
  801c6d:	e8 c8 fe ff ff       	call   801b3a <_pipeisclosed>
  801c72:	85 c0                	test   %eax,%eax
  801c74:	74 e3                	je     801c59 <devpipe_read+0x34>
				return 0;
  801c76:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7b:	eb d4                	jmp    801c51 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c7d:	99                   	cltd   
  801c7e:	c1 ea 1b             	shr    $0x1b,%edx
  801c81:	01 d0                	add    %edx,%eax
  801c83:	83 e0 1f             	and    $0x1f,%eax
  801c86:	29 d0                	sub    %edx,%eax
  801c88:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c90:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c93:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c96:	83 c6 01             	add    $0x1,%esi
  801c99:	eb aa                	jmp    801c45 <devpipe_read+0x20>

00801c9b <pipe>:
{
  801c9b:	f3 0f 1e fb          	endbr32 
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ca7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801caa:	50                   	push   %eax
  801cab:	e8 2c f1 ff ff       	call   800ddc <fd_alloc>
  801cb0:	89 c3                	mov    %eax,%ebx
  801cb2:	83 c4 10             	add    $0x10,%esp
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	0f 88 23 01 00 00    	js     801de0 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbd:	83 ec 04             	sub    $0x4,%esp
  801cc0:	68 07 04 00 00       	push   $0x407
  801cc5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc8:	6a 00                	push   $0x0
  801cca:	e8 47 ef ff ff       	call   800c16 <sys_page_alloc>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	0f 88 04 01 00 00    	js     801de0 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801cdc:	83 ec 0c             	sub    $0xc,%esp
  801cdf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce2:	50                   	push   %eax
  801ce3:	e8 f4 f0 ff ff       	call   800ddc <fd_alloc>
  801ce8:	89 c3                	mov    %eax,%ebx
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	0f 88 db 00 00 00    	js     801dd0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf5:	83 ec 04             	sub    $0x4,%esp
  801cf8:	68 07 04 00 00       	push   $0x407
  801cfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801d00:	6a 00                	push   $0x0
  801d02:	e8 0f ef ff ff       	call   800c16 <sys_page_alloc>
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	83 c4 10             	add    $0x10,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	0f 88 bc 00 00 00    	js     801dd0 <pipe+0x135>
	va = fd2data(fd0);
  801d14:	83 ec 0c             	sub    $0xc,%esp
  801d17:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1a:	e8 a2 f0 ff ff       	call   800dc1 <fd2data>
  801d1f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d21:	83 c4 0c             	add    $0xc,%esp
  801d24:	68 07 04 00 00       	push   $0x407
  801d29:	50                   	push   %eax
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 e5 ee ff ff       	call   800c16 <sys_page_alloc>
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	0f 88 82 00 00 00    	js     801dc0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	ff 75 f0             	pushl  -0x10(%ebp)
  801d44:	e8 78 f0 ff ff       	call   800dc1 <fd2data>
  801d49:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d50:	50                   	push   %eax
  801d51:	6a 00                	push   $0x0
  801d53:	56                   	push   %esi
  801d54:	6a 00                	push   $0x0
  801d56:	e8 e1 ee ff ff       	call   800c3c <sys_page_map>
  801d5b:	89 c3                	mov    %eax,%ebx
  801d5d:	83 c4 20             	add    $0x20,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 4e                	js     801db2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d64:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801d69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d6c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d71:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d7b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d87:	83 ec 0c             	sub    $0xc,%esp
  801d8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8d:	e8 1b f0 ff ff       	call   800dad <fd2num>
  801d92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d95:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d97:	83 c4 04             	add    $0x4,%esp
  801d9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9d:	e8 0b f0 ff ff       	call   800dad <fd2num>
  801da2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801db0:	eb 2e                	jmp    801de0 <pipe+0x145>
	sys_page_unmap(0, va);
  801db2:	83 ec 08             	sub    $0x8,%esp
  801db5:	56                   	push   %esi
  801db6:	6a 00                	push   $0x0
  801db8:	e8 a4 ee ff ff       	call   800c61 <sys_page_unmap>
  801dbd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc6:	6a 00                	push   $0x0
  801dc8:	e8 94 ee ff ff       	call   800c61 <sys_page_unmap>
  801dcd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801dd0:	83 ec 08             	sub    $0x8,%esp
  801dd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd6:	6a 00                	push   $0x0
  801dd8:	e8 84 ee ff ff       	call   800c61 <sys_page_unmap>
  801ddd:	83 c4 10             	add    $0x10,%esp
}
  801de0:	89 d8                	mov    %ebx,%eax
  801de2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de5:	5b                   	pop    %ebx
  801de6:	5e                   	pop    %esi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    

00801de9 <pipeisclosed>:
{
  801de9:	f3 0f 1e fb          	endbr32 
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df6:	50                   	push   %eax
  801df7:	ff 75 08             	pushl  0x8(%ebp)
  801dfa:	e8 33 f0 ff ff       	call   800e32 <fd_lookup>
  801dff:	83 c4 10             	add    $0x10,%esp
  801e02:	85 c0                	test   %eax,%eax
  801e04:	78 18                	js     801e1e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801e06:	83 ec 0c             	sub    $0xc,%esp
  801e09:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0c:	e8 b0 ef ff ff       	call   800dc1 <fd2data>
  801e11:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e16:	e8 1f fd ff ff       	call   801b3a <_pipeisclosed>
  801e1b:	83 c4 10             	add    $0x10,%esp
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e20:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801e24:	b8 00 00 00 00       	mov    $0x0,%eax
  801e29:	c3                   	ret    

00801e2a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e2a:	f3 0f 1e fb          	endbr32 
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e34:	68 bb 28 80 00       	push   $0x8028bb
  801e39:	ff 75 0c             	pushl  0xc(%ebp)
  801e3c:	e8 6c e9 ff ff       	call   8007ad <strcpy>
	return 0;
}
  801e41:	b8 00 00 00 00       	mov    $0x0,%eax
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <devcons_write>:
{
  801e48:	f3 0f 1e fb          	endbr32 
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	57                   	push   %edi
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e58:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e5d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e63:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e66:	73 31                	jae    801e99 <devcons_write+0x51>
		m = n - tot;
  801e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e6b:	29 f3                	sub    %esi,%ebx
  801e6d:	83 fb 7f             	cmp    $0x7f,%ebx
  801e70:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e75:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e78:	83 ec 04             	sub    $0x4,%esp
  801e7b:	53                   	push   %ebx
  801e7c:	89 f0                	mov    %esi,%eax
  801e7e:	03 45 0c             	add    0xc(%ebp),%eax
  801e81:	50                   	push   %eax
  801e82:	57                   	push   %edi
  801e83:	e8 23 eb ff ff       	call   8009ab <memmove>
		sys_cputs(buf, m);
  801e88:	83 c4 08             	add    $0x8,%esp
  801e8b:	53                   	push   %ebx
  801e8c:	57                   	push   %edi
  801e8d:	e8 d5 ec ff ff       	call   800b67 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e92:	01 de                	add    %ebx,%esi
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	eb ca                	jmp    801e63 <devcons_write+0x1b>
}
  801e99:	89 f0                	mov    %esi,%eax
  801e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5e                   	pop    %esi
  801ea0:	5f                   	pop    %edi
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    

00801ea3 <devcons_read>:
{
  801ea3:	f3 0f 1e fb          	endbr32 
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 08             	sub    $0x8,%esp
  801ead:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801eb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb6:	74 21                	je     801ed9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801eb8:	e8 cc ec ff ff       	call   800b89 <sys_cgetc>
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	75 07                	jne    801ec8 <devcons_read+0x25>
		sys_yield();
  801ec1:	e8 2d ed ff ff       	call   800bf3 <sys_yield>
  801ec6:	eb f0                	jmp    801eb8 <devcons_read+0x15>
	if (c < 0)
  801ec8:	78 0f                	js     801ed9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801eca:	83 f8 04             	cmp    $0x4,%eax
  801ecd:	74 0c                	je     801edb <devcons_read+0x38>
	*(char*)vbuf = c;
  801ecf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed2:	88 02                	mov    %al,(%edx)
	return 1;
  801ed4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    
		return 0;
  801edb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee0:	eb f7                	jmp    801ed9 <devcons_read+0x36>

00801ee2 <cputchar>:
{
  801ee2:	f3 0f 1e fb          	endbr32 
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ef2:	6a 01                	push   $0x1
  801ef4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef7:	50                   	push   %eax
  801ef8:	e8 6a ec ff ff       	call   800b67 <sys_cputs>
}
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    

00801f02 <getchar>:
{
  801f02:	f3 0f 1e fb          	endbr32 
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f0c:	6a 01                	push   $0x1
  801f0e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f11:	50                   	push   %eax
  801f12:	6a 00                	push   $0x0
  801f14:	e8 a1 f1 ff ff       	call   8010ba <read>
	if (r < 0)
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	78 06                	js     801f26 <getchar+0x24>
	if (r < 1)
  801f20:	74 06                	je     801f28 <getchar+0x26>
	return c;
  801f22:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    
		return -E_EOF;
  801f28:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f2d:	eb f7                	jmp    801f26 <getchar+0x24>

00801f2f <iscons>:
{
  801f2f:	f3 0f 1e fb          	endbr32 
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3c:	50                   	push   %eax
  801f3d:	ff 75 08             	pushl  0x8(%ebp)
  801f40:	e8 ed ee ff ff       	call   800e32 <fd_lookup>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	78 11                	js     801f5d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4f:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f55:	39 10                	cmp    %edx,(%eax)
  801f57:	0f 94 c0             	sete   %al
  801f5a:	0f b6 c0             	movzbl %al,%eax
}
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    

00801f5f <opencons>:
{
  801f5f:	f3 0f 1e fb          	endbr32 
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6c:	50                   	push   %eax
  801f6d:	e8 6a ee ff ff       	call   800ddc <fd_alloc>
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 3a                	js     801fb3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f79:	83 ec 04             	sub    $0x4,%esp
  801f7c:	68 07 04 00 00       	push   $0x407
  801f81:	ff 75 f4             	pushl  -0xc(%ebp)
  801f84:	6a 00                	push   $0x0
  801f86:	e8 8b ec ff ff       	call   800c16 <sys_page_alloc>
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 21                	js     801fb3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f9b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa7:	83 ec 0c             	sub    $0xc,%esp
  801faa:	50                   	push   %eax
  801fab:	e8 fd ed ff ff       	call   800dad <fd2num>
  801fb0:	83 c4 10             	add    $0x10,%esp
}
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fb5:	f3 0f 1e fb          	endbr32 
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fbe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fc1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fc7:	e8 04 ec ff ff       	call   800bd0 <sys_getenvid>
  801fcc:	83 ec 0c             	sub    $0xc,%esp
  801fcf:	ff 75 0c             	pushl  0xc(%ebp)
  801fd2:	ff 75 08             	pushl  0x8(%ebp)
  801fd5:	56                   	push   %esi
  801fd6:	50                   	push   %eax
  801fd7:	68 c8 28 80 00       	push   $0x8028c8
  801fdc:	e8 c2 e1 ff ff       	call   8001a3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fe1:	83 c4 18             	add    $0x18,%esp
  801fe4:	53                   	push   %ebx
  801fe5:	ff 75 10             	pushl  0x10(%ebp)
  801fe8:	e8 61 e1 ff ff       	call   80014e <vcprintf>
	cprintf("\n");
  801fed:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  801ff4:	e8 aa e1 ff ff       	call   8001a3 <cprintf>
  801ff9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ffc:	cc                   	int3   
  801ffd:	eb fd                	jmp    801ffc <_panic+0x47>

00801fff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fff:	f3 0f 1e fb          	endbr32 
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	8b 75 08             	mov    0x8(%ebp),%esi
  80200b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802011:	85 c0                	test   %eax,%eax
  802013:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802018:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80201b:	83 ec 0c             	sub    $0xc,%esp
  80201e:	50                   	push   %eax
  80201f:	e8 f8 ec ff ff       	call   800d1c <sys_ipc_recv>
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	85 c0                	test   %eax,%eax
  802029:	75 2b                	jne    802056 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80202b:	85 f6                	test   %esi,%esi
  80202d:	74 0a                	je     802039 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80202f:	a1 08 40 80 00       	mov    0x804008,%eax
  802034:	8b 40 74             	mov    0x74(%eax),%eax
  802037:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802039:	85 db                	test   %ebx,%ebx
  80203b:	74 0a                	je     802047 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80203d:	a1 08 40 80 00       	mov    0x804008,%eax
  802042:	8b 40 78             	mov    0x78(%eax),%eax
  802045:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802047:	a1 08 40 80 00       	mov    0x804008,%eax
  80204c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80204f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802052:	5b                   	pop    %ebx
  802053:	5e                   	pop    %esi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802056:	85 f6                	test   %esi,%esi
  802058:	74 06                	je     802060 <ipc_recv+0x61>
  80205a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802060:	85 db                	test   %ebx,%ebx
  802062:	74 eb                	je     80204f <ipc_recv+0x50>
  802064:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80206a:	eb e3                	jmp    80204f <ipc_recv+0x50>

0080206c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80206c:	f3 0f 1e fb          	endbr32 
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	57                   	push   %edi
  802074:	56                   	push   %esi
  802075:	53                   	push   %ebx
  802076:	83 ec 0c             	sub    $0xc,%esp
  802079:	8b 7d 08             	mov    0x8(%ebp),%edi
  80207c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80207f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802082:	85 db                	test   %ebx,%ebx
  802084:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802089:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80208c:	ff 75 14             	pushl  0x14(%ebp)
  80208f:	53                   	push   %ebx
  802090:	56                   	push   %esi
  802091:	57                   	push   %edi
  802092:	e8 5e ec ff ff       	call   800cf5 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80209d:	75 07                	jne    8020a6 <ipc_send+0x3a>
			sys_yield();
  80209f:	e8 4f eb ff ff       	call   800bf3 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020a4:	eb e6                	jmp    80208c <ipc_send+0x20>
		}
		else if (ret == 0)
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	75 08                	jne    8020b2 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8020aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8020b2:	50                   	push   %eax
  8020b3:	68 eb 28 80 00       	push   $0x8028eb
  8020b8:	6a 48                	push   $0x48
  8020ba:	68 f9 28 80 00       	push   $0x8028f9
  8020bf:	e8 f1 fe ff ff       	call   801fb5 <_panic>

008020c4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020c4:	f3 0f 1e fb          	endbr32 
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020ce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020d3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020d6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020dc:	8b 52 50             	mov    0x50(%edx),%edx
  8020df:	39 ca                	cmp    %ecx,%edx
  8020e1:	74 11                	je     8020f4 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8020e3:	83 c0 01             	add    $0x1,%eax
  8020e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020eb:	75 e6                	jne    8020d3 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f2:	eb 0b                	jmp    8020ff <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020f4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020fc:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    

00802101 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802101:	f3 0f 1e fb          	endbr32 
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80210b:	89 c2                	mov    %eax,%edx
  80210d:	c1 ea 16             	shr    $0x16,%edx
  802110:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802117:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80211c:	f6 c1 01             	test   $0x1,%cl
  80211f:	74 1c                	je     80213d <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802121:	c1 e8 0c             	shr    $0xc,%eax
  802124:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80212b:	a8 01                	test   $0x1,%al
  80212d:	74 0e                	je     80213d <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80212f:	c1 e8 0c             	shr    $0xc,%eax
  802132:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802139:	ef 
  80213a:	0f b7 d2             	movzwl %dx,%edx
}
  80213d:	89 d0                	mov    %edx,%eax
  80213f:	5d                   	pop    %ebp
  802140:	c3                   	ret    
  802141:	66 90                	xchg   %ax,%ax
  802143:	66 90                	xchg   %ax,%ax
  802145:	66 90                	xchg   %ax,%ax
  802147:	66 90                	xchg   %ax,%ax
  802149:	66 90                	xchg   %ax,%ax
  80214b:	66 90                	xchg   %ax,%ax
  80214d:	66 90                	xchg   %ax,%ax
  80214f:	90                   	nop

00802150 <__udivdi3>:
  802150:	f3 0f 1e fb          	endbr32 
  802154:	55                   	push   %ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	53                   	push   %ebx
  802158:	83 ec 1c             	sub    $0x1c,%esp
  80215b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802163:	8b 74 24 34          	mov    0x34(%esp),%esi
  802167:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80216b:	85 d2                	test   %edx,%edx
  80216d:	75 19                	jne    802188 <__udivdi3+0x38>
  80216f:	39 f3                	cmp    %esi,%ebx
  802171:	76 4d                	jbe    8021c0 <__udivdi3+0x70>
  802173:	31 ff                	xor    %edi,%edi
  802175:	89 e8                	mov    %ebp,%eax
  802177:	89 f2                	mov    %esi,%edx
  802179:	f7 f3                	div    %ebx
  80217b:	89 fa                	mov    %edi,%edx
  80217d:	83 c4 1c             	add    $0x1c,%esp
  802180:	5b                   	pop    %ebx
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	76 14                	jbe    8021a0 <__udivdi3+0x50>
  80218c:	31 ff                	xor    %edi,%edi
  80218e:	31 c0                	xor    %eax,%eax
  802190:	89 fa                	mov    %edi,%edx
  802192:	83 c4 1c             	add    $0x1c,%esp
  802195:	5b                   	pop    %ebx
  802196:	5e                   	pop    %esi
  802197:	5f                   	pop    %edi
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    
  80219a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a0:	0f bd fa             	bsr    %edx,%edi
  8021a3:	83 f7 1f             	xor    $0x1f,%edi
  8021a6:	75 48                	jne    8021f0 <__udivdi3+0xa0>
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	72 06                	jb     8021b2 <__udivdi3+0x62>
  8021ac:	31 c0                	xor    %eax,%eax
  8021ae:	39 eb                	cmp    %ebp,%ebx
  8021b0:	77 de                	ja     802190 <__udivdi3+0x40>
  8021b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b7:	eb d7                	jmp    802190 <__udivdi3+0x40>
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d9                	mov    %ebx,%ecx
  8021c2:	85 db                	test   %ebx,%ebx
  8021c4:	75 0b                	jne    8021d1 <__udivdi3+0x81>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f3                	div    %ebx
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	89 f0                	mov    %esi,%eax
  8021d5:	f7 f1                	div    %ecx
  8021d7:	89 c6                	mov    %eax,%esi
  8021d9:	89 e8                	mov    %ebp,%eax
  8021db:	89 f7                	mov    %esi,%edi
  8021dd:	f7 f1                	div    %ecx
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 f9                	mov    %edi,%ecx
  8021f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021f7:	29 f8                	sub    %edi,%eax
  8021f9:	d3 e2                	shl    %cl,%edx
  8021fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021ff:	89 c1                	mov    %eax,%ecx
  802201:	89 da                	mov    %ebx,%edx
  802203:	d3 ea                	shr    %cl,%edx
  802205:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802209:	09 d1                	or     %edx,%ecx
  80220b:	89 f2                	mov    %esi,%edx
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f9                	mov    %edi,%ecx
  802213:	d3 e3                	shl    %cl,%ebx
  802215:	89 c1                	mov    %eax,%ecx
  802217:	d3 ea                	shr    %cl,%edx
  802219:	89 f9                	mov    %edi,%ecx
  80221b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80221f:	89 eb                	mov    %ebp,%ebx
  802221:	d3 e6                	shl    %cl,%esi
  802223:	89 c1                	mov    %eax,%ecx
  802225:	d3 eb                	shr    %cl,%ebx
  802227:	09 de                	or     %ebx,%esi
  802229:	89 f0                	mov    %esi,%eax
  80222b:	f7 74 24 08          	divl   0x8(%esp)
  80222f:	89 d6                	mov    %edx,%esi
  802231:	89 c3                	mov    %eax,%ebx
  802233:	f7 64 24 0c          	mull   0xc(%esp)
  802237:	39 d6                	cmp    %edx,%esi
  802239:	72 15                	jb     802250 <__udivdi3+0x100>
  80223b:	89 f9                	mov    %edi,%ecx
  80223d:	d3 e5                	shl    %cl,%ebp
  80223f:	39 c5                	cmp    %eax,%ebp
  802241:	73 04                	jae    802247 <__udivdi3+0xf7>
  802243:	39 d6                	cmp    %edx,%esi
  802245:	74 09                	je     802250 <__udivdi3+0x100>
  802247:	89 d8                	mov    %ebx,%eax
  802249:	31 ff                	xor    %edi,%edi
  80224b:	e9 40 ff ff ff       	jmp    802190 <__udivdi3+0x40>
  802250:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802253:	31 ff                	xor    %edi,%edi
  802255:	e9 36 ff ff ff       	jmp    802190 <__udivdi3+0x40>
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__umoddi3>:
  802260:	f3 0f 1e fb          	endbr32 
  802264:	55                   	push   %ebp
  802265:	57                   	push   %edi
  802266:	56                   	push   %esi
  802267:	53                   	push   %ebx
  802268:	83 ec 1c             	sub    $0x1c,%esp
  80226b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80226f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802273:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802277:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80227b:	85 c0                	test   %eax,%eax
  80227d:	75 19                	jne    802298 <__umoddi3+0x38>
  80227f:	39 df                	cmp    %ebx,%edi
  802281:	76 5d                	jbe    8022e0 <__umoddi3+0x80>
  802283:	89 f0                	mov    %esi,%eax
  802285:	89 da                	mov    %ebx,%edx
  802287:	f7 f7                	div    %edi
  802289:	89 d0                	mov    %edx,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	83 c4 1c             	add    $0x1c,%esp
  802290:	5b                   	pop    %ebx
  802291:	5e                   	pop    %esi
  802292:	5f                   	pop    %edi
  802293:	5d                   	pop    %ebp
  802294:	c3                   	ret    
  802295:	8d 76 00             	lea    0x0(%esi),%esi
  802298:	89 f2                	mov    %esi,%edx
  80229a:	39 d8                	cmp    %ebx,%eax
  80229c:	76 12                	jbe    8022b0 <__umoddi3+0x50>
  80229e:	89 f0                	mov    %esi,%eax
  8022a0:	89 da                	mov    %ebx,%edx
  8022a2:	83 c4 1c             	add    $0x1c,%esp
  8022a5:	5b                   	pop    %ebx
  8022a6:	5e                   	pop    %esi
  8022a7:	5f                   	pop    %edi
  8022a8:	5d                   	pop    %ebp
  8022a9:	c3                   	ret    
  8022aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b0:	0f bd e8             	bsr    %eax,%ebp
  8022b3:	83 f5 1f             	xor    $0x1f,%ebp
  8022b6:	75 50                	jne    802308 <__umoddi3+0xa8>
  8022b8:	39 d8                	cmp    %ebx,%eax
  8022ba:	0f 82 e0 00 00 00    	jb     8023a0 <__umoddi3+0x140>
  8022c0:	89 d9                	mov    %ebx,%ecx
  8022c2:	39 f7                	cmp    %esi,%edi
  8022c4:	0f 86 d6 00 00 00    	jbe    8023a0 <__umoddi3+0x140>
  8022ca:	89 d0                	mov    %edx,%eax
  8022cc:	89 ca                	mov    %ecx,%edx
  8022ce:	83 c4 1c             	add    $0x1c,%esp
  8022d1:	5b                   	pop    %ebx
  8022d2:	5e                   	pop    %esi
  8022d3:	5f                   	pop    %edi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    
  8022d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	89 fd                	mov    %edi,%ebp
  8022e2:	85 ff                	test   %edi,%edi
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x91>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f7                	div    %edi
  8022ef:	89 c5                	mov    %eax,%ebp
  8022f1:	89 d8                	mov    %ebx,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f5                	div    %ebp
  8022f7:	89 f0                	mov    %esi,%eax
  8022f9:	f7 f5                	div    %ebp
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	eb 8c                	jmp    80228d <__umoddi3+0x2d>
  802301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	ba 20 00 00 00       	mov    $0x20,%edx
  80230f:	29 ea                	sub    %ebp,%edx
  802311:	d3 e0                	shl    %cl,%eax
  802313:	89 44 24 08          	mov    %eax,0x8(%esp)
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 f8                	mov    %edi,%eax
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802321:	89 54 24 04          	mov    %edx,0x4(%esp)
  802325:	8b 54 24 04          	mov    0x4(%esp),%edx
  802329:	09 c1                	or     %eax,%ecx
  80232b:	89 d8                	mov    %ebx,%eax
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 e9                	mov    %ebp,%ecx
  802333:	d3 e7                	shl    %cl,%edi
  802335:	89 d1                	mov    %edx,%ecx
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80233f:	d3 e3                	shl    %cl,%ebx
  802341:	89 c7                	mov    %eax,%edi
  802343:	89 d1                	mov    %edx,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	89 fa                	mov    %edi,%edx
  80234d:	d3 e6                	shl    %cl,%esi
  80234f:	09 d8                	or     %ebx,%eax
  802351:	f7 74 24 08          	divl   0x8(%esp)
  802355:	89 d1                	mov    %edx,%ecx
  802357:	89 f3                	mov    %esi,%ebx
  802359:	f7 64 24 0c          	mull   0xc(%esp)
  80235d:	89 c6                	mov    %eax,%esi
  80235f:	89 d7                	mov    %edx,%edi
  802361:	39 d1                	cmp    %edx,%ecx
  802363:	72 06                	jb     80236b <__umoddi3+0x10b>
  802365:	75 10                	jne    802377 <__umoddi3+0x117>
  802367:	39 c3                	cmp    %eax,%ebx
  802369:	73 0c                	jae    802377 <__umoddi3+0x117>
  80236b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80236f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802373:	89 d7                	mov    %edx,%edi
  802375:	89 c6                	mov    %eax,%esi
  802377:	89 ca                	mov    %ecx,%edx
  802379:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80237e:	29 f3                	sub    %esi,%ebx
  802380:	19 fa                	sbb    %edi,%edx
  802382:	89 d0                	mov    %edx,%eax
  802384:	d3 e0                	shl    %cl,%eax
  802386:	89 e9                	mov    %ebp,%ecx
  802388:	d3 eb                	shr    %cl,%ebx
  80238a:	d3 ea                	shr    %cl,%edx
  80238c:	09 d8                	or     %ebx,%eax
  80238e:	83 c4 1c             	add    $0x1c,%esp
  802391:	5b                   	pop    %ebx
  802392:	5e                   	pop    %esi
  802393:	5f                   	pop    %edi
  802394:	5d                   	pop    %ebp
  802395:	c3                   	ret    
  802396:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	29 fe                	sub    %edi,%esi
  8023a2:	19 c3                	sbb    %eax,%ebx
  8023a4:	89 f2                	mov    %esi,%edx
  8023a6:	89 d9                	mov    %ebx,%ecx
  8023a8:	e9 1d ff ff ff       	jmp    8022ca <__umoddi3+0x6a>
