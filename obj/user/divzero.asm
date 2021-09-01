
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003d:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800044:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800047:	b8 01 00 00 00       	mov    $0x1,%eax
  80004c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800051:	99                   	cltd   
  800052:	f7 f9                	idiv   %ecx
  800054:	50                   	push   %eax
  800055:	68 80 23 80 00       	push   $0x802380
  80005a:	e8 0a 01 00 00       	call   800169 <cprintf>
}
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	c9                   	leave  
  800063:	c3                   	ret    

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	f3 0f 1e fb          	endbr32 
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800073:	e8 1e 0b 00 00       	call   800b96 <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x31>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0a 00 00 00       	call   8000ae <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ae:	f3 0f 1e fb          	endbr32 
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000b8:	e8 aa 0e 00 00       	call   800f67 <close_all>
	sys_env_destroy(0);
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	6a 00                	push   $0x0
  8000c2:	e8 ab 0a 00 00       	call   800b72 <sys_env_destroy>
}
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cc:	f3 0f 1e fb          	endbr32 
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 13                	mov    (%ebx),%edx
  8000dc:	8d 42 01             	lea    0x1(%edx),%eax
  8000df:	89 03                	mov    %eax,(%ebx)
  8000e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ed:	74 09                	je     8000f8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	68 ff 00 00 00       	push   $0xff
  800100:	8d 43 08             	lea    0x8(%ebx),%eax
  800103:	50                   	push   %eax
  800104:	e8 24 0a 00 00       	call   800b2d <sys_cputs>
		b->idx = 0;
  800109:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb db                	jmp    8000ef <putch+0x23>

00800114 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800114:	f3 0f 1e fb          	endbr32 
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800121:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800128:	00 00 00 
	b.cnt = 0;
  80012b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800132:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800135:	ff 75 0c             	pushl  0xc(%ebp)
  800138:	ff 75 08             	pushl  0x8(%ebp)
  80013b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	68 cc 00 80 00       	push   $0x8000cc
  800147:	e8 20 01 00 00       	call   80026c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014c:	83 c4 08             	add    $0x8,%esp
  80014f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800155:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015b:	50                   	push   %eax
  80015c:	e8 cc 09 00 00       	call   800b2d <sys_cputs>

	return b.cnt;
}
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	f3 0f 1e fb          	endbr32 
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800173:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800176:	50                   	push   %eax
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	e8 95 ff ff ff       	call   800114 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 1c             	sub    $0x1c,%esp
  80018a:	89 c7                	mov    %eax,%edi
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	8b 55 0c             	mov    0xc(%ebp),%edx
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 c2                	mov    %eax,%edx
  800198:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019e:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ae:	39 c2                	cmp    %eax,%edx
  8001b0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b3:	72 3e                	jb     8001f3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	83 eb 01             	sub    $0x1,%ebx
  8001be:	53                   	push   %ebx
  8001bf:	50                   	push   %eax
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001cf:	e8 3c 1f 00 00       	call   802110 <__udivdi3>
  8001d4:	83 c4 18             	add    $0x18,%esp
  8001d7:	52                   	push   %edx
  8001d8:	50                   	push   %eax
  8001d9:	89 f2                	mov    %esi,%edx
  8001db:	89 f8                	mov    %edi,%eax
  8001dd:	e8 9f ff ff ff       	call   800181 <printnum>
  8001e2:	83 c4 20             	add    $0x20,%esp
  8001e5:	eb 13                	jmp    8001fa <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e7:	83 ec 08             	sub    $0x8,%esp
  8001ea:	56                   	push   %esi
  8001eb:	ff 75 18             	pushl  0x18(%ebp)
  8001ee:	ff d7                	call   *%edi
  8001f0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f3:	83 eb 01             	sub    $0x1,%ebx
  8001f6:	85 db                	test   %ebx,%ebx
  8001f8:	7f ed                	jg     8001e7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	56                   	push   %esi
  8001fe:	83 ec 04             	sub    $0x4,%esp
  800201:	ff 75 e4             	pushl  -0x1c(%ebp)
  800204:	ff 75 e0             	pushl  -0x20(%ebp)
  800207:	ff 75 dc             	pushl  -0x24(%ebp)
  80020a:	ff 75 d8             	pushl  -0x28(%ebp)
  80020d:	e8 0e 20 00 00       	call   802220 <__umoddi3>
  800212:	83 c4 14             	add    $0x14,%esp
  800215:	0f be 80 98 23 80 00 	movsbl 0x802398(%eax),%eax
  80021c:	50                   	push   %eax
  80021d:	ff d7                	call   *%edi
}
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022a:	f3 0f 1e fb          	endbr32 
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800234:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	3b 50 04             	cmp    0x4(%eax),%edx
  80023d:	73 0a                	jae    800249 <sprintputch+0x1f>
		*b->buf++ = ch;
  80023f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800242:	89 08                	mov    %ecx,(%eax)
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	88 02                	mov    %al,(%edx)
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <printfmt>:
{
  80024b:	f3 0f 1e fb          	endbr32 
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800255:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800258:	50                   	push   %eax
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	e8 05 00 00 00       	call   80026c <vprintfmt>
}
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <vprintfmt>:
{
  80026c:	f3 0f 1e fb          	endbr32 
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	e9 8e 03 00 00       	jmp    800615 <vprintfmt+0x3a9>
		padc = ' ';
  800287:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80028b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800292:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800299:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002a0:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a5:	8d 47 01             	lea    0x1(%edi),%eax
  8002a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ab:	0f b6 17             	movzbl (%edi),%edx
  8002ae:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b1:	3c 55                	cmp    $0x55,%al
  8002b3:	0f 87 df 03 00 00    	ja     800698 <vprintfmt+0x42c>
  8002b9:	0f b6 c0             	movzbl %al,%eax
  8002bc:	3e ff 24 85 e0 24 80 	notrack jmp *0x8024e0(,%eax,4)
  8002c3:	00 
  8002c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002cb:	eb d8                	jmp    8002a5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002d4:	eb cf                	jmp    8002a5 <vprintfmt+0x39>
  8002d6:	0f b6 d2             	movzbl %dl,%edx
  8002d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8002e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002eb:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ee:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f1:	83 f9 09             	cmp    $0x9,%ecx
  8002f4:	77 55                	ja     80034b <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8002f9:	eb e9                	jmp    8002e4 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8b 00                	mov    (%eax),%eax
  800300:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800303:	8b 45 14             	mov    0x14(%ebp),%eax
  800306:	8d 40 04             	lea    0x4(%eax),%eax
  800309:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80030f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800313:	79 90                	jns    8002a5 <vprintfmt+0x39>
				width = precision, precision = -1;
  800315:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800318:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800322:	eb 81                	jmp    8002a5 <vprintfmt+0x39>
  800324:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800327:	85 c0                	test   %eax,%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
  80032e:	0f 49 d0             	cmovns %eax,%edx
  800331:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800337:	e9 69 ff ff ff       	jmp    8002a5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80033f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800346:	e9 5a ff ff ff       	jmp    8002a5 <vprintfmt+0x39>
  80034b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800351:	eb bc                	jmp    80030f <vprintfmt+0xa3>
			lflag++;
  800353:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800359:	e9 47 ff ff ff       	jmp    8002a5 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 78 04             	lea    0x4(%eax),%edi
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	53                   	push   %ebx
  800368:	ff 30                	pushl  (%eax)
  80036a:	ff d6                	call   *%esi
			break;
  80036c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80036f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800372:	e9 9b 02 00 00       	jmp    800612 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8d 78 04             	lea    0x4(%eax),%edi
  80037d:	8b 00                	mov    (%eax),%eax
  80037f:	99                   	cltd   
  800380:	31 d0                	xor    %edx,%eax
  800382:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800384:	83 f8 0f             	cmp    $0xf,%eax
  800387:	7f 23                	jg     8003ac <vprintfmt+0x140>
  800389:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  800390:	85 d2                	test   %edx,%edx
  800392:	74 18                	je     8003ac <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800394:	52                   	push   %edx
  800395:	68 49 27 80 00       	push   $0x802749
  80039a:	53                   	push   %ebx
  80039b:	56                   	push   %esi
  80039c:	e8 aa fe ff ff       	call   80024b <printfmt>
  8003a1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a7:	e9 66 02 00 00       	jmp    800612 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003ac:	50                   	push   %eax
  8003ad:	68 b0 23 80 00       	push   $0x8023b0
  8003b2:	53                   	push   %ebx
  8003b3:	56                   	push   %esi
  8003b4:	e8 92 fe ff ff       	call   80024b <printfmt>
  8003b9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003bc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003bf:	e9 4e 02 00 00       	jmp    800612 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	83 c0 04             	add    $0x4,%eax
  8003ca:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	b8 a9 23 80 00       	mov    $0x8023a9,%eax
  8003d9:	0f 45 c2             	cmovne %edx,%eax
  8003dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e3:	7e 06                	jle    8003eb <vprintfmt+0x17f>
  8003e5:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e9:	75 0d                	jne    8003f8 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003eb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003ee:	89 c7                	mov    %eax,%edi
  8003f0:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f6:	eb 55                	jmp    80044d <vprintfmt+0x1e1>
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fe:	ff 75 cc             	pushl  -0x34(%ebp)
  800401:	e8 46 03 00 00       	call   80074c <strnlen>
  800406:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800409:	29 c2                	sub    %eax,%edx
  80040b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80040e:	83 c4 10             	add    $0x10,%esp
  800411:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800413:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800417:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80041a:	85 ff                	test   %edi,%edi
  80041c:	7e 11                	jle    80042f <vprintfmt+0x1c3>
					putch(padc, putdat);
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	53                   	push   %ebx
  800422:	ff 75 e0             	pushl  -0x20(%ebp)
  800425:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	83 ef 01             	sub    $0x1,%edi
  80042a:	83 c4 10             	add    $0x10,%esp
  80042d:	eb eb                	jmp    80041a <vprintfmt+0x1ae>
  80042f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800432:	85 d2                	test   %edx,%edx
  800434:	b8 00 00 00 00       	mov    $0x0,%eax
  800439:	0f 49 c2             	cmovns %edx,%eax
  80043c:	29 c2                	sub    %eax,%edx
  80043e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800441:	eb a8                	jmp    8003eb <vprintfmt+0x17f>
					putch(ch, putdat);
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	53                   	push   %ebx
  800447:	52                   	push   %edx
  800448:	ff d6                	call   *%esi
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800450:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800452:	83 c7 01             	add    $0x1,%edi
  800455:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800459:	0f be d0             	movsbl %al,%edx
  80045c:	85 d2                	test   %edx,%edx
  80045e:	74 4b                	je     8004ab <vprintfmt+0x23f>
  800460:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800464:	78 06                	js     80046c <vprintfmt+0x200>
  800466:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80046a:	78 1e                	js     80048a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80046c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800470:	74 d1                	je     800443 <vprintfmt+0x1d7>
  800472:	0f be c0             	movsbl %al,%eax
  800475:	83 e8 20             	sub    $0x20,%eax
  800478:	83 f8 5e             	cmp    $0x5e,%eax
  80047b:	76 c6                	jbe    800443 <vprintfmt+0x1d7>
					putch('?', putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	6a 3f                	push   $0x3f
  800483:	ff d6                	call   *%esi
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	eb c3                	jmp    80044d <vprintfmt+0x1e1>
  80048a:	89 cf                	mov    %ecx,%edi
  80048c:	eb 0e                	jmp    80049c <vprintfmt+0x230>
				putch(' ', putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	6a 20                	push   $0x20
  800494:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800496:	83 ef 01             	sub    $0x1,%edi
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 ff                	test   %edi,%edi
  80049e:	7f ee                	jg     80048e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a6:	e9 67 01 00 00       	jmp    800612 <vprintfmt+0x3a6>
  8004ab:	89 cf                	mov    %ecx,%edi
  8004ad:	eb ed                	jmp    80049c <vprintfmt+0x230>
	if (lflag >= 2)
  8004af:	83 f9 01             	cmp    $0x1,%ecx
  8004b2:	7f 1b                	jg     8004cf <vprintfmt+0x263>
	else if (lflag)
  8004b4:	85 c9                	test   %ecx,%ecx
  8004b6:	74 63                	je     80051b <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c0:	99                   	cltd   
  8004c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 40 04             	lea    0x4(%eax),%eax
  8004ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cd:	eb 17                	jmp    8004e6 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8b 50 04             	mov    0x4(%eax),%edx
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 40 08             	lea    0x8(%eax),%eax
  8004e3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004ec:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004f1:	85 c9                	test   %ecx,%ecx
  8004f3:	0f 89 ff 00 00 00    	jns    8005f8 <vprintfmt+0x38c>
				putch('-', putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	6a 2d                	push   $0x2d
  8004ff:	ff d6                	call   *%esi
				num = -(long long) num;
  800501:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800504:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800507:	f7 da                	neg    %edx
  800509:	83 d1 00             	adc    $0x0,%ecx
  80050c:	f7 d9                	neg    %ecx
  80050e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800511:	b8 0a 00 00 00       	mov    $0xa,%eax
  800516:	e9 dd 00 00 00       	jmp    8005f8 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	99                   	cltd   
  800524:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 40 04             	lea    0x4(%eax),%eax
  80052d:	89 45 14             	mov    %eax,0x14(%ebp)
  800530:	eb b4                	jmp    8004e6 <vprintfmt+0x27a>
	if (lflag >= 2)
  800532:	83 f9 01             	cmp    $0x1,%ecx
  800535:	7f 1e                	jg     800555 <vprintfmt+0x2e9>
	else if (lflag)
  800537:	85 c9                	test   %ecx,%ecx
  800539:	74 32                	je     80056d <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 10                	mov    (%eax),%edx
  800540:	b9 00 00 00 00       	mov    $0x0,%ecx
  800545:	8d 40 04             	lea    0x4(%eax),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800550:	e9 a3 00 00 00       	jmp    8005f8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8b 10                	mov    (%eax),%edx
  80055a:	8b 48 04             	mov    0x4(%eax),%ecx
  80055d:	8d 40 08             	lea    0x8(%eax),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800563:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800568:	e9 8b 00 00 00       	jmp    8005f8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 10                	mov    (%eax),%edx
  800572:	b9 00 00 00 00       	mov    $0x0,%ecx
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800582:	eb 74                	jmp    8005f8 <vprintfmt+0x38c>
	if (lflag >= 2)
  800584:	83 f9 01             	cmp    $0x1,%ecx
  800587:	7f 1b                	jg     8005a4 <vprintfmt+0x338>
	else if (lflag)
  800589:	85 c9                	test   %ecx,%ecx
  80058b:	74 2c                	je     8005b9 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80059d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005a2:	eb 54                	jmp    8005f8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 10                	mov    (%eax),%edx
  8005a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ac:	8d 40 08             	lea    0x8(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005b2:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005b7:	eb 3f                	jmp    8005f8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005c9:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005ce:	eb 28                	jmp    8005f8 <vprintfmt+0x38c>
			putch('0', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 30                	push   $0x30
  8005d6:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d8:	83 c4 08             	add    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	6a 78                	push   $0x78
  8005de:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005ea:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f8:	83 ec 0c             	sub    $0xc,%esp
  8005fb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005ff:	57                   	push   %edi
  800600:	ff 75 e0             	pushl  -0x20(%ebp)
  800603:	50                   	push   %eax
  800604:	51                   	push   %ecx
  800605:	52                   	push   %edx
  800606:	89 da                	mov    %ebx,%edx
  800608:	89 f0                	mov    %esi,%eax
  80060a:	e8 72 fb ff ff       	call   800181 <printnum>
			break;
  80060f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800615:	83 c7 01             	add    $0x1,%edi
  800618:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061c:	83 f8 25             	cmp    $0x25,%eax
  80061f:	0f 84 62 fc ff ff    	je     800287 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800625:	85 c0                	test   %eax,%eax
  800627:	0f 84 8b 00 00 00    	je     8006b8 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	50                   	push   %eax
  800632:	ff d6                	call   *%esi
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb dc                	jmp    800615 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800639:	83 f9 01             	cmp    $0x1,%ecx
  80063c:	7f 1b                	jg     800659 <vprintfmt+0x3ed>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	74 2c                	je     80066e <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800652:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800657:	eb 9f                	jmp    8005f8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8b 48 04             	mov    0x4(%eax),%ecx
  800661:	8d 40 08             	lea    0x8(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80066c:	eb 8a                	jmp    8005f8 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 10                	mov    (%eax),%edx
  800673:	b9 00 00 00 00       	mov    $0x0,%ecx
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800683:	e9 70 ff ff ff       	jmp    8005f8 <vprintfmt+0x38c>
			putch(ch, putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 25                	push   $0x25
  80068e:	ff d6                	call   *%esi
			break;
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	e9 7a ff ff ff       	jmp    800612 <vprintfmt+0x3a6>
			putch('%', putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 25                	push   $0x25
  80069e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	89 f8                	mov    %edi,%eax
  8006a5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a9:	74 05                	je     8006b0 <vprintfmt+0x444>
  8006ab:	83 e8 01             	sub    $0x1,%eax
  8006ae:	eb f5                	jmp    8006a5 <vprintfmt+0x439>
  8006b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b3:	e9 5a ff ff ff       	jmp    800612 <vprintfmt+0x3a6>
}
  8006b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006bb:	5b                   	pop    %ebx
  8006bc:	5e                   	pop    %esi
  8006bd:	5f                   	pop    %edi
  8006be:	5d                   	pop    %ebp
  8006bf:	c3                   	ret    

008006c0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c0:	f3 0f 1e fb          	endbr32 
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	83 ec 18             	sub    $0x18,%esp
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	74 26                	je     80070b <vsnprintf+0x4b>
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	7e 22                	jle    80070b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e9:	ff 75 14             	pushl  0x14(%ebp)
  8006ec:	ff 75 10             	pushl  0x10(%ebp)
  8006ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f2:	50                   	push   %eax
  8006f3:	68 2a 02 80 00       	push   $0x80022a
  8006f8:	e8 6f fb ff ff       	call   80026c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800700:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800703:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800706:	83 c4 10             	add    $0x10,%esp
}
  800709:	c9                   	leave  
  80070a:	c3                   	ret    
		return -E_INVAL;
  80070b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800710:	eb f7                	jmp    800709 <vsnprintf+0x49>

00800712 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800712:	f3 0f 1e fb          	endbr32 
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80071c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071f:	50                   	push   %eax
  800720:	ff 75 10             	pushl  0x10(%ebp)
  800723:	ff 75 0c             	pushl  0xc(%ebp)
  800726:	ff 75 08             	pushl  0x8(%ebp)
  800729:	e8 92 ff ff ff       	call   8006c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	f3 0f 1e fb          	endbr32 
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800743:	74 05                	je     80074a <strlen+0x1a>
		n++;
  800745:	83 c0 01             	add    $0x1,%eax
  800748:	eb f5                	jmp    80073f <strlen+0xf>
	return n;
}
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074c:	f3 0f 1e fb          	endbr32 
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	39 d0                	cmp    %edx,%eax
  800760:	74 0d                	je     80076f <strnlen+0x23>
  800762:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800766:	74 05                	je     80076d <strnlen+0x21>
		n++;
  800768:	83 c0 01             	add    $0x1,%eax
  80076b:	eb f1                	jmp    80075e <strnlen+0x12>
  80076d:	89 c2                	mov    %eax,%edx
	return n;
}
  80076f:	89 d0                	mov    %edx,%eax
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	f3 0f 1e fb          	endbr32 
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
  800786:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80078a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80078d:	83 c0 01             	add    $0x1,%eax
  800790:	84 d2                	test   %dl,%dl
  800792:	75 f2                	jne    800786 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800794:	89 c8                	mov    %ecx,%eax
  800796:	5b                   	pop    %ebx
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800799:	f3 0f 1e fb          	endbr32 
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	83 ec 10             	sub    $0x10,%esp
  8007a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a7:	53                   	push   %ebx
  8007a8:	e8 83 ff ff ff       	call   800730 <strlen>
  8007ad:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b0:	ff 75 0c             	pushl  0xc(%ebp)
  8007b3:	01 d8                	add    %ebx,%eax
  8007b5:	50                   	push   %eax
  8007b6:	e8 b8 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	f3 0f 1e fb          	endbr32 
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d1:	89 f3                	mov    %esi,%ebx
  8007d3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	39 d8                	cmp    %ebx,%eax
  8007da:	74 11                	je     8007ed <strncpy+0x2b>
		*dst++ = *src;
  8007dc:	83 c0 01             	add    $0x1,%eax
  8007df:	0f b6 0a             	movzbl (%edx),%ecx
  8007e2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e5:	80 f9 01             	cmp    $0x1,%cl
  8007e8:	83 da ff             	sbb    $0xffffffff,%edx
  8007eb:	eb eb                	jmp    8007d8 <strncpy+0x16>
	}
	return ret;
}
  8007ed:	89 f0                	mov    %esi,%eax
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f3:	f3 0f 1e fb          	endbr32 
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	8b 55 10             	mov    0x10(%ebp),%edx
  800805:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800807:	85 d2                	test   %edx,%edx
  800809:	74 21                	je     80082c <strlcpy+0x39>
  80080b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800811:	39 c2                	cmp    %eax,%edx
  800813:	74 14                	je     800829 <strlcpy+0x36>
  800815:	0f b6 19             	movzbl (%ecx),%ebx
  800818:	84 db                	test   %bl,%bl
  80081a:	74 0b                	je     800827 <strlcpy+0x34>
			*dst++ = *src++;
  80081c:	83 c1 01             	add    $0x1,%ecx
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	88 5a ff             	mov    %bl,-0x1(%edx)
  800825:	eb ea                	jmp    800811 <strlcpy+0x1e>
  800827:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800829:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082c:	29 f0                	sub    %esi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	f3 0f 1e fb          	endbr32 
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083f:	0f b6 01             	movzbl (%ecx),%eax
  800842:	84 c0                	test   %al,%al
  800844:	74 0c                	je     800852 <strcmp+0x20>
  800846:	3a 02                	cmp    (%edx),%al
  800848:	75 08                	jne    800852 <strcmp+0x20>
		p++, q++;
  80084a:	83 c1 01             	add    $0x1,%ecx
  80084d:	83 c2 01             	add    $0x1,%edx
  800850:	eb ed                	jmp    80083f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800852:	0f b6 c0             	movzbl %al,%eax
  800855:	0f b6 12             	movzbl (%edx),%edx
  800858:	29 d0                	sub    %edx,%eax
}
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085c:	f3 0f 1e fb          	endbr32 
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	89 c3                	mov    %eax,%ebx
  80086c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086f:	eb 06                	jmp    800877 <strncmp+0x1b>
		n--, p++, q++;
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800877:	39 d8                	cmp    %ebx,%eax
  800879:	74 16                	je     800891 <strncmp+0x35>
  80087b:	0f b6 08             	movzbl (%eax),%ecx
  80087e:	84 c9                	test   %cl,%cl
  800880:	74 04                	je     800886 <strncmp+0x2a>
  800882:	3a 0a                	cmp    (%edx),%cl
  800884:	74 eb                	je     800871 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 00             	movzbl (%eax),%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb f6                	jmp    80088e <strncmp+0x32>

00800898 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800898:	f3 0f 1e fb          	endbr32 
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	0f b6 10             	movzbl (%eax),%edx
  8008a9:	84 d2                	test   %dl,%dl
  8008ab:	74 09                	je     8008b6 <strchr+0x1e>
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 0a                	je     8008bb <strchr+0x23>
	for (; *s; s++)
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	eb f0                	jmp    8008a6 <strchr+0xe>
			return (char *) s;
	return 0;
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8008bd:	f3 0f 1e fb          	endbr32 
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8008c7:	6a 78                	push   $0x78
  8008c9:	ff 75 08             	pushl  0x8(%ebp)
  8008cc:	e8 c7 ff ff ff       	call   800898 <strchr>
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8008dc:	eb 0d                	jmp    8008eb <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8008de:	c1 e0 04             	shl    $0x4,%eax
  8008e1:	0f be d2             	movsbl %dl,%edx
  8008e4:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8008e8:	83 c1 01             	add    $0x1,%ecx
  8008eb:	0f b6 11             	movzbl (%ecx),%edx
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	74 11                	je     800903 <atox+0x46>
		if (*p>='a'){
  8008f2:	80 fa 60             	cmp    $0x60,%dl
  8008f5:	7e e7                	jle    8008de <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8008f7:	c1 e0 04             	shl    $0x4,%eax
  8008fa:	0f be d2             	movsbl %dl,%edx
  8008fd:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800901:	eb e5                	jmp    8008e8 <atox+0x2b>
	}

	return v;

}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800905:	f3 0f 1e fb          	endbr32 
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 09                	je     800923 <strfind+0x1e>
  80091a:	84 d2                	test   %dl,%dl
  80091c:	74 05                	je     800923 <strfind+0x1e>
	for (; *s; s++)
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	eb f0                	jmp    800913 <strfind+0xe>
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	f3 0f 1e fb          	endbr32 
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 31                	je     80096a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	89 f8                	mov    %edi,%eax
  80093b:	09 c8                	or     %ecx,%eax
  80093d:	a8 03                	test   $0x3,%al
  80093f:	75 23                	jne    800964 <memset+0x3f>
		c &= 0xFF;
  800941:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800945:	89 d3                	mov    %edx,%ebx
  800947:	c1 e3 08             	shl    $0x8,%ebx
  80094a:	89 d0                	mov    %edx,%eax
  80094c:	c1 e0 18             	shl    $0x18,%eax
  80094f:	89 d6                	mov    %edx,%esi
  800951:	c1 e6 10             	shl    $0x10,%esi
  800954:	09 f0                	or     %esi,%eax
  800956:	09 c2                	or     %eax,%edx
  800958:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095d:	89 d0                	mov    %edx,%eax
  80095f:	fc                   	cld    
  800960:	f3 ab                	rep stos %eax,%es:(%edi)
  800962:	eb 06                	jmp    80096a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800964:	8b 45 0c             	mov    0xc(%ebp),%eax
  800967:	fc                   	cld    
  800968:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096a:	89 f8                	mov    %edi,%eax
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800971:	f3 0f 1e fb          	endbr32 
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	56                   	push   %esi
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800983:	39 c6                	cmp    %eax,%esi
  800985:	73 32                	jae    8009b9 <memmove+0x48>
  800987:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	76 2b                	jbe    8009b9 <memmove+0x48>
		s += n;
		d += n;
  80098e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	89 fe                	mov    %edi,%esi
  800993:	09 ce                	or     %ecx,%esi
  800995:	09 d6                	or     %edx,%esi
  800997:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099d:	75 0e                	jne    8009ad <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099f:	83 ef 04             	sub    $0x4,%edi
  8009a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a8:	fd                   	std    
  8009a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ab:	eb 09                	jmp    8009b6 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ad:	83 ef 01             	sub    $0x1,%edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 1a                	jmp    8009d3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	09 ca                	or     %ecx,%edx
  8009bd:	09 f2                	or     %esi,%edx
  8009bf:	f6 c2 03             	test   $0x3,%dl
  8009c2:	75 0a                	jne    8009ce <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c7:	89 c7                	mov    %eax,%edi
  8009c9:	fc                   	cld    
  8009ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cc:	eb 05                	jmp    8009d3 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d7:	f3 0f 1e fb          	endbr32 
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e1:	ff 75 10             	pushl  0x10(%ebp)
  8009e4:	ff 75 0c             	pushl  0xc(%ebp)
  8009e7:	ff 75 08             	pushl  0x8(%ebp)
  8009ea:	e8 82 ff ff ff       	call   800971 <memmove>
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f1:	f3 0f 1e fb          	endbr32 
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a00:	89 c6                	mov    %eax,%esi
  800a02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a05:	39 f0                	cmp    %esi,%eax
  800a07:	74 1c                	je     800a25 <memcmp+0x34>
		if (*s1 != *s2)
  800a09:	0f b6 08             	movzbl (%eax),%ecx
  800a0c:	0f b6 1a             	movzbl (%edx),%ebx
  800a0f:	38 d9                	cmp    %bl,%cl
  800a11:	75 08                	jne    800a1b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	83 c2 01             	add    $0x1,%edx
  800a19:	eb ea                	jmp    800a05 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 05                	jmp    800a2a <memcmp+0x39>
	}

	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2e:	f3 0f 1e fb          	endbr32 
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	73 09                	jae    800a4d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	38 08                	cmp    %cl,(%eax)
  800a46:	74 05                	je     800a4d <memfind+0x1f>
	for (; s < ends; s++)
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	eb f3                	jmp    800a40 <memfind+0x12>
			break;
	return (void *) s;
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4f:	f3 0f 1e fb          	endbr32 
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	eb 03                	jmp    800a64 <strtol+0x15>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	3c 20                	cmp    $0x20,%al
  800a69:	74 f6                	je     800a61 <strtol+0x12>
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	74 f2                	je     800a61 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a6f:	3c 2b                	cmp    $0x2b,%al
  800a71:	74 2a                	je     800a9d <strtol+0x4e>
	int neg = 0;
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a78:	3c 2d                	cmp    $0x2d,%al
  800a7a:	74 2b                	je     800aa7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a82:	75 0f                	jne    800a93 <strtol+0x44>
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	74 28                	je     800ab1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a89:	85 db                	test   %ebx,%ebx
  800a8b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a90:	0f 44 d8             	cmove  %eax,%ebx
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
  800a98:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9b:	eb 46                	jmp    800ae3 <strtol+0x94>
		s++;
  800a9d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa5:	eb d5                	jmp    800a7c <strtol+0x2d>
		s++, neg = 1;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	bf 01 00 00 00       	mov    $0x1,%edi
  800aaf:	eb cb                	jmp    800a7c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab5:	74 0e                	je     800ac5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab7:	85 db                	test   %ebx,%ebx
  800ab9:	75 d8                	jne    800a93 <strtol+0x44>
		s++, base = 8;
  800abb:	83 c1 01             	add    $0x1,%ecx
  800abe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac3:	eb ce                	jmp    800a93 <strtol+0x44>
		s += 2, base = 16;
  800ac5:	83 c1 02             	add    $0x2,%ecx
  800ac8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acd:	eb c4                	jmp    800a93 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800acf:	0f be d2             	movsbl %dl,%edx
  800ad2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad8:	7d 3a                	jge    800b14 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ada:	83 c1 01             	add    $0x1,%ecx
  800add:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ae3:	0f b6 11             	movzbl (%ecx),%edx
  800ae6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 09             	cmp    $0x9,%bl
  800aee:	76 df                	jbe    800acf <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800af0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 08                	ja     800b02 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 57             	sub    $0x57,%edx
  800b00:	eb d3                	jmp    800ad5 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0c:	0f be d2             	movsbl %dl,%edx
  800b0f:	83 ea 37             	sub    $0x37,%edx
  800b12:	eb c1                	jmp    800ad5 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b18:	74 05                	je     800b1f <strtol+0xd0>
		*endptr = (char *) s;
  800b1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	f7 da                	neg    %edx
  800b23:	85 ff                	test   %edi,%edi
  800b25:	0f 45 c2             	cmovne %edx,%eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2d:	f3 0f 1e fb          	endbr32 
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b37:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	89 c6                	mov    %eax,%esi
  800b48:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4f:	f3 0f 1e fb          	endbr32 
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b72:	f3 0f 1e fb          	endbr32 
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b81:	8b 55 08             	mov    0x8(%ebp),%edx
  800b84:	b8 03 00 00 00       	mov    $0x3,%eax
  800b89:	89 cb                	mov    %ecx,%ebx
  800b8b:	89 cf                	mov    %ecx,%edi
  800b8d:	89 ce                	mov    %ecx,%esi
  800b8f:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b96:	f3 0f 1e fb          	endbr32 
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 02 00 00 00       	mov    $0x2,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_yield>:

void
sys_yield(void)
{
  800bb9:	f3 0f 1e fb          	endbr32 
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcd:	89 d1                	mov    %edx,%ecx
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	89 d6                	mov    %edx,%esi
  800bd5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdc:	f3 0f 1e fb          	endbr32 
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be6:	be 00 00 00 00       	mov    $0x0,%esi
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf9:	89 f7                	mov    %esi,%edi
  800bfb:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c02:	f3 0f 1e fb          	endbr32 
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	b8 05 00 00 00       	mov    $0x5,%eax
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c20:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c27:	f3 0f 1e fb          	endbr32 
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c41:	89 df                	mov    %ebx,%edi
  800c43:	89 de                	mov    %ebx,%esi
  800c45:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4c:	f3 0f 1e fb          	endbr32 
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c61:	b8 08 00 00 00       	mov    $0x8,%eax
  800c66:	89 df                	mov    %ebx,%edi
  800c68:	89 de                	mov    %ebx,%esi
  800c6a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8b:	89 df                	mov    %ebx,%edi
  800c8d:	89 de                	mov    %ebx,%esi
  800c8f:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb0:	89 df                	mov    %ebx,%edi
  800cb2:	89 de                	mov    %ebx,%esi
  800cb4:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbb:	f3 0f 1e fb          	endbr32 
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd0:	be 00 00 00 00       	mov    $0x0,%esi
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce2:	f3 0f 1e fb          	endbr32 
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf9:	89 cb                	mov    %ecx,%ebx
  800cfb:	89 cf                	mov    %ecx,%edi
  800cfd:	89 ce                	mov    %ecx,%esi
  800cff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d06:	f3 0f 1e fb          	endbr32 
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1a:	89 d1                	mov    %edx,%ecx
  800d1c:	89 d3                	mov    %edx,%ebx
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 d6                	mov    %edx,%esi
  800d22:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
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
  800d3e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
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
  800d63:	b8 10 00 00 00       	mov    $0x10,%eax
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d73:	f3 0f 1e fb          	endbr32 
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d82:	c1 e8 0c             	shr    $0xc,%eax
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d87:	f3 0f 1e fb          	endbr32 
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d9b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da2:	f3 0f 1e fb          	endbr32 
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 16             	shr    $0x16,%edx
  800db3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	74 2d                	je     800dec <fd_alloc+0x4a>
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	c1 ea 0c             	shr    $0xc,%edx
  800dc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcb:	f6 c2 01             	test   $0x1,%dl
  800dce:	74 1c                	je     800dec <fd_alloc+0x4a>
  800dd0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800dd5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dda:	75 d2                	jne    800dae <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800de5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800dea:	eb 0a                	jmp    800df6 <fd_alloc+0x54>
			*fd_store = fd;
  800dec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800def:	89 01                	mov    %eax,(%ecx)
			return 0;
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df8:	f3 0f 1e fb          	endbr32 
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e02:	83 f8 1f             	cmp    $0x1f,%eax
  800e05:	77 30                	ja     800e37 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e07:	c1 e0 0c             	shl    $0xc,%eax
  800e0a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e15:	f6 c2 01             	test   $0x1,%dl
  800e18:	74 24                	je     800e3e <fd_lookup+0x46>
  800e1a:	89 c2                	mov    %eax,%edx
  800e1c:	c1 ea 0c             	shr    $0xc,%edx
  800e1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e26:	f6 c2 01             	test   $0x1,%dl
  800e29:	74 1a                	je     800e45 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2e:	89 02                	mov    %eax,(%edx)
	return 0;
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
		return -E_INVAL;
  800e37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3c:	eb f7                	jmp    800e35 <fd_lookup+0x3d>
		return -E_INVAL;
  800e3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e43:	eb f0                	jmp    800e35 <fd_lookup+0x3d>
  800e45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4a:	eb e9                	jmp    800e35 <fd_lookup+0x3d>

00800e4c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e4c:	f3 0f 1e fb          	endbr32 
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e63:	39 08                	cmp    %ecx,(%eax)
  800e65:	74 38                	je     800e9f <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800e67:	83 c2 01             	add    $0x1,%edx
  800e6a:	8b 04 95 1c 27 80 00 	mov    0x80271c(,%edx,4),%eax
  800e71:	85 c0                	test   %eax,%eax
  800e73:	75 ee                	jne    800e63 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e75:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800e7a:	8b 40 48             	mov    0x48(%eax),%eax
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	51                   	push   %ecx
  800e81:	50                   	push   %eax
  800e82:	68 a0 26 80 00       	push   $0x8026a0
  800e87:	e8 dd f2 ff ff       	call   800169 <cprintf>
	*dev = 0;
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    
			*dev = devtab[i];
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	eb f2                	jmp    800e9d <dev_lookup+0x51>

00800eab <fd_close>:
{
  800eab:	f3 0f 1e fb          	endbr32 
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 24             	sub    $0x24,%esp
  800eb8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ebb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ebe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ec1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ec8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ecb:	50                   	push   %eax
  800ecc:	e8 27 ff ff ff       	call   800df8 <fd_lookup>
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 05                	js     800edf <fd_close+0x34>
	    || fd != fd2)
  800eda:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800edd:	74 16                	je     800ef5 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800edf:	89 f8                	mov    %edi,%eax
  800ee1:	84 c0                	test   %al,%al
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	0f 44 d8             	cmove  %eax,%ebx
}
  800eeb:	89 d8                	mov    %ebx,%eax
  800eed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800efb:	50                   	push   %eax
  800efc:	ff 36                	pushl  (%esi)
  800efe:	e8 49 ff ff ff       	call   800e4c <dev_lookup>
  800f03:	89 c3                	mov    %eax,%ebx
  800f05:	83 c4 10             	add    $0x10,%esp
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	78 1a                	js     800f26 <fd_close+0x7b>
		if (dev->dev_close)
  800f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f0f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f17:	85 c0                	test   %eax,%eax
  800f19:	74 0b                	je     800f26 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	56                   	push   %esi
  800f1f:	ff d0                	call   *%eax
  800f21:	89 c3                	mov    %eax,%ebx
  800f23:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f26:	83 ec 08             	sub    $0x8,%esp
  800f29:	56                   	push   %esi
  800f2a:	6a 00                	push   $0x0
  800f2c:	e8 f6 fc ff ff       	call   800c27 <sys_page_unmap>
	return r;
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	eb b5                	jmp    800eeb <fd_close+0x40>

00800f36 <close>:

int
close(int fdnum)
{
  800f36:	f3 0f 1e fb          	endbr32 
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f43:	50                   	push   %eax
  800f44:	ff 75 08             	pushl  0x8(%ebp)
  800f47:	e8 ac fe ff ff       	call   800df8 <fd_lookup>
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 02                	jns    800f55 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    
		return fd_close(fd, 1);
  800f55:	83 ec 08             	sub    $0x8,%esp
  800f58:	6a 01                	push   $0x1
  800f5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5d:	e8 49 ff ff ff       	call   800eab <fd_close>
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	eb ec                	jmp    800f53 <close+0x1d>

00800f67 <close_all>:

void
close_all(void)
{
  800f67:	f3 0f 1e fb          	endbr32 
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f72:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	53                   	push   %ebx
  800f7b:	e8 b6 ff ff ff       	call   800f36 <close>
	for (i = 0; i < MAXFD; i++)
  800f80:	83 c3 01             	add    $0x1,%ebx
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	83 fb 20             	cmp    $0x20,%ebx
  800f89:	75 ec                	jne    800f77 <close_all+0x10>
}
  800f8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f90:	f3 0f 1e fb          	endbr32 
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fa0:	50                   	push   %eax
  800fa1:	ff 75 08             	pushl  0x8(%ebp)
  800fa4:	e8 4f fe ff ff       	call   800df8 <fd_lookup>
  800fa9:	89 c3                	mov    %eax,%ebx
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	0f 88 81 00 00 00    	js     801037 <dup+0xa7>
		return r;
	close(newfdnum);
  800fb6:	83 ec 0c             	sub    $0xc,%esp
  800fb9:	ff 75 0c             	pushl  0xc(%ebp)
  800fbc:	e8 75 ff ff ff       	call   800f36 <close>

	newfd = INDEX2FD(newfdnum);
  800fc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc4:	c1 e6 0c             	shl    $0xc,%esi
  800fc7:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fcd:	83 c4 04             	add    $0x4,%esp
  800fd0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd3:	e8 af fd ff ff       	call   800d87 <fd2data>
  800fd8:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fda:	89 34 24             	mov    %esi,(%esp)
  800fdd:	e8 a5 fd ff ff       	call   800d87 <fd2data>
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fe7:	89 d8                	mov    %ebx,%eax
  800fe9:	c1 e8 16             	shr    $0x16,%eax
  800fec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff3:	a8 01                	test   $0x1,%al
  800ff5:	74 11                	je     801008 <dup+0x78>
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	c1 e8 0c             	shr    $0xc,%eax
  800ffc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801003:	f6 c2 01             	test   $0x1,%dl
  801006:	75 39                	jne    801041 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801008:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	c1 e8 0c             	shr    $0xc,%eax
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	25 07 0e 00 00       	and    $0xe07,%eax
  80101f:	50                   	push   %eax
  801020:	56                   	push   %esi
  801021:	6a 00                	push   $0x0
  801023:	52                   	push   %edx
  801024:	6a 00                	push   $0x0
  801026:	e8 d7 fb ff ff       	call   800c02 <sys_page_map>
  80102b:	89 c3                	mov    %eax,%ebx
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 31                	js     801065 <dup+0xd5>
		goto err;

	return newfdnum;
  801034:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801037:	89 d8                	mov    %ebx,%eax
  801039:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801041:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	25 07 0e 00 00       	and    $0xe07,%eax
  801050:	50                   	push   %eax
  801051:	57                   	push   %edi
  801052:	6a 00                	push   $0x0
  801054:	53                   	push   %ebx
  801055:	6a 00                	push   $0x0
  801057:	e8 a6 fb ff ff       	call   800c02 <sys_page_map>
  80105c:	89 c3                	mov    %eax,%ebx
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 a3                	jns    801008 <dup+0x78>
	sys_page_unmap(0, newfd);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	56                   	push   %esi
  801069:	6a 00                	push   $0x0
  80106b:	e8 b7 fb ff ff       	call   800c27 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801070:	83 c4 08             	add    $0x8,%esp
  801073:	57                   	push   %edi
  801074:	6a 00                	push   $0x0
  801076:	e8 ac fb ff ff       	call   800c27 <sys_page_unmap>
	return r;
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	eb b7                	jmp    801037 <dup+0xa7>

00801080 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801080:	f3 0f 1e fb          	endbr32 
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	53                   	push   %ebx
  801088:	83 ec 1c             	sub    $0x1c,%esp
  80108b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80108e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	53                   	push   %ebx
  801093:	e8 60 fd ff ff       	call   800df8 <fd_lookup>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 3f                	js     8010de <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a5:	50                   	push   %eax
  8010a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a9:	ff 30                	pushl  (%eax)
  8010ab:	e8 9c fd ff ff       	call   800e4c <dev_lookup>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	78 27                	js     8010de <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ba:	8b 42 08             	mov    0x8(%edx),%eax
  8010bd:	83 e0 03             	and    $0x3,%eax
  8010c0:	83 f8 01             	cmp    $0x1,%eax
  8010c3:	74 1e                	je     8010e3 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c8:	8b 40 08             	mov    0x8(%eax),%eax
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	74 35                	je     801104 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	ff 75 10             	pushl  0x10(%ebp)
  8010d5:	ff 75 0c             	pushl  0xc(%ebp)
  8010d8:	52                   	push   %edx
  8010d9:	ff d0                	call   *%eax
  8010db:	83 c4 10             	add    $0x10,%esp
}
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e3:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010e8:	8b 40 48             	mov    0x48(%eax),%eax
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	53                   	push   %ebx
  8010ef:	50                   	push   %eax
  8010f0:	68 e1 26 80 00       	push   $0x8026e1
  8010f5:	e8 6f f0 ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801102:	eb da                	jmp    8010de <read+0x5e>
		return -E_NOT_SUPP;
  801104:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801109:	eb d3                	jmp    8010de <read+0x5e>

0080110b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80110b:	f3 0f 1e fb          	endbr32 
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	8b 7d 08             	mov    0x8(%ebp),%edi
  80111b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80111e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801123:	eb 02                	jmp    801127 <readn+0x1c>
  801125:	01 c3                	add    %eax,%ebx
  801127:	39 f3                	cmp    %esi,%ebx
  801129:	73 21                	jae    80114c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	89 f0                	mov    %esi,%eax
  801130:	29 d8                	sub    %ebx,%eax
  801132:	50                   	push   %eax
  801133:	89 d8                	mov    %ebx,%eax
  801135:	03 45 0c             	add    0xc(%ebp),%eax
  801138:	50                   	push   %eax
  801139:	57                   	push   %edi
  80113a:	e8 41 ff ff ff       	call   801080 <read>
		if (m < 0)
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	85 c0                	test   %eax,%eax
  801144:	78 04                	js     80114a <readn+0x3f>
			return m;
		if (m == 0)
  801146:	75 dd                	jne    801125 <readn+0x1a>
  801148:	eb 02                	jmp    80114c <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80114c:	89 d8                	mov    %ebx,%eax
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801156:	f3 0f 1e fb          	endbr32 
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	53                   	push   %ebx
  80115e:	83 ec 1c             	sub    $0x1c,%esp
  801161:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801164:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801167:	50                   	push   %eax
  801168:	53                   	push   %ebx
  801169:	e8 8a fc ff ff       	call   800df8 <fd_lookup>
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	78 3a                	js     8011af <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117b:	50                   	push   %eax
  80117c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117f:	ff 30                	pushl  (%eax)
  801181:	e8 c6 fc ff ff       	call   800e4c <dev_lookup>
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 22                	js     8011af <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80118d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801190:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801194:	74 1e                	je     8011b4 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801196:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801199:	8b 52 0c             	mov    0xc(%edx),%edx
  80119c:	85 d2                	test   %edx,%edx
  80119e:	74 35                	je     8011d5 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a0:	83 ec 04             	sub    $0x4,%esp
  8011a3:	ff 75 10             	pushl  0x10(%ebp)
  8011a6:	ff 75 0c             	pushl  0xc(%ebp)
  8011a9:	50                   	push   %eax
  8011aa:	ff d2                	call   *%edx
  8011ac:	83 c4 10             	add    $0x10,%esp
}
  8011af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011b9:	8b 40 48             	mov    0x48(%eax),%eax
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	53                   	push   %ebx
  8011c0:	50                   	push   %eax
  8011c1:	68 fd 26 80 00       	push   $0x8026fd
  8011c6:	e8 9e ef ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d3:	eb da                	jmp    8011af <write+0x59>
		return -E_NOT_SUPP;
  8011d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011da:	eb d3                	jmp    8011af <write+0x59>

008011dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8011dc:	f3 0f 1e fb          	endbr32 
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	ff 75 08             	pushl  0x8(%ebp)
  8011ed:	e8 06 fc ff ff       	call   800df8 <fd_lookup>
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	78 0e                	js     801207 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8011f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ff:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801202:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801209:	f3 0f 1e fb          	endbr32 
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	53                   	push   %ebx
  801211:	83 ec 1c             	sub    $0x1c,%esp
  801214:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801217:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	53                   	push   %ebx
  80121c:	e8 d7 fb ff ff       	call   800df8 <fd_lookup>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 37                	js     80125f <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801228:	83 ec 08             	sub    $0x8,%esp
  80122b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801232:	ff 30                	pushl  (%eax)
  801234:	e8 13 fc ff ff       	call   800e4c <dev_lookup>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 1f                	js     80125f <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801247:	74 1b                	je     801264 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801249:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124c:	8b 52 18             	mov    0x18(%edx),%edx
  80124f:	85 d2                	test   %edx,%edx
  801251:	74 32                	je     801285 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801253:	83 ec 08             	sub    $0x8,%esp
  801256:	ff 75 0c             	pushl  0xc(%ebp)
  801259:	50                   	push   %eax
  80125a:	ff d2                	call   *%edx
  80125c:	83 c4 10             	add    $0x10,%esp
}
  80125f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801262:	c9                   	leave  
  801263:	c3                   	ret    
			thisenv->env_id, fdnum);
  801264:	a1 0c 40 80 00       	mov    0x80400c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801269:	8b 40 48             	mov    0x48(%eax),%eax
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	53                   	push   %ebx
  801270:	50                   	push   %eax
  801271:	68 c0 26 80 00       	push   $0x8026c0
  801276:	e8 ee ee ff ff       	call   800169 <cprintf>
		return -E_INVAL;
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb da                	jmp    80125f <ftruncate+0x56>
		return -E_NOT_SUPP;
  801285:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80128a:	eb d3                	jmp    80125f <ftruncate+0x56>

0080128c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80128c:	f3 0f 1e fb          	endbr32 
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 1c             	sub    $0x1c,%esp
  801297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	ff 75 08             	pushl  0x8(%ebp)
  8012a1:	e8 52 fb ff ff       	call   800df8 <fd_lookup>
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 4b                	js     8012f8 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b7:	ff 30                	pushl  (%eax)
  8012b9:	e8 8e fb ff ff       	call   800e4c <dev_lookup>
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 33                	js     8012f8 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8012c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012cc:	74 2f                	je     8012fd <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ce:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012d1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012d8:	00 00 00 
	stat->st_isdir = 0;
  8012db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012e2:	00 00 00 
	stat->st_dev = dev;
  8012e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f2:	ff 50 14             	call   *0x14(%eax)
  8012f5:	83 c4 10             	add    $0x10,%esp
}
  8012f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    
		return -E_NOT_SUPP;
  8012fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801302:	eb f4                	jmp    8012f8 <fstat+0x6c>

00801304 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801304:	f3 0f 1e fb          	endbr32 
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	6a 00                	push   $0x0
  801312:	ff 75 08             	pushl  0x8(%ebp)
  801315:	e8 01 02 00 00       	call   80151b <open>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 1b                	js     80133e <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	ff 75 0c             	pushl  0xc(%ebp)
  801329:	50                   	push   %eax
  80132a:	e8 5d ff ff ff       	call   80128c <fstat>
  80132f:	89 c6                	mov    %eax,%esi
	close(fd);
  801331:	89 1c 24             	mov    %ebx,(%esp)
  801334:	e8 fd fb ff ff       	call   800f36 <close>
	return r;
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	89 f3                	mov    %esi,%ebx
}
  80133e:	89 d8                	mov    %ebx,%eax
  801340:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	89 c6                	mov    %eax,%esi
  80134e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801350:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801357:	74 27                	je     801380 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801359:	6a 07                	push   $0x7
  80135b:	68 00 50 80 00       	push   $0x805000
  801360:	56                   	push   %esi
  801361:	ff 35 00 40 80 00    	pushl  0x804000
  801367:	e8 c6 0c 00 00       	call   802032 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136c:	83 c4 0c             	add    $0xc,%esp
  80136f:	6a 00                	push   $0x0
  801371:	53                   	push   %ebx
  801372:	6a 00                	push   $0x0
  801374:	e8 4c 0c 00 00       	call   801fc5 <ipc_recv>
}
  801379:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137c:	5b                   	pop    %ebx
  80137d:	5e                   	pop    %esi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801380:	83 ec 0c             	sub    $0xc,%esp
  801383:	6a 01                	push   $0x1
  801385:	e8 00 0d 00 00       	call   80208a <ipc_find_env>
  80138a:	a3 00 40 80 00       	mov    %eax,0x804000
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	eb c5                	jmp    801359 <fsipc+0x12>

00801394 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801394:	f3 0f 1e fb          	endbr32 
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ac:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8013bb:	e8 87 ff ff ff       	call   801347 <fsipc>
}
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <devfile_flush>:
{
  8013c2:	f3 0f 1e fb          	endbr32 
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013dc:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e1:	e8 61 ff ff ff       	call   801347 <fsipc>
}
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <devfile_stat>:
{
  8013e8:	f3 0f 1e fb          	endbr32 
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 04             	sub    $0x4,%esp
  8013f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801401:	ba 00 00 00 00       	mov    $0x0,%edx
  801406:	b8 05 00 00 00       	mov    $0x5,%eax
  80140b:	e8 37 ff ff ff       	call   801347 <fsipc>
  801410:	85 c0                	test   %eax,%eax
  801412:	78 2c                	js     801440 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	68 00 50 80 00       	push   $0x805000
  80141c:	53                   	push   %ebx
  80141d:	e8 51 f3 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801422:	a1 80 50 80 00       	mov    0x805080,%eax
  801427:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80142d:	a1 84 50 80 00       	mov    0x805084,%eax
  801432:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801440:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801443:	c9                   	leave  
  801444:	c3                   	ret    

00801445 <devfile_write>:
{
  801445:	f3 0f 1e fb          	endbr32 
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	8b 45 10             	mov    0x10(%ebp),%eax
  801452:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801457:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80145c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80145f:	8b 55 08             	mov    0x8(%ebp),%edx
  801462:	8b 52 0c             	mov    0xc(%edx),%edx
  801465:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80146b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801470:	50                   	push   %eax
  801471:	ff 75 0c             	pushl  0xc(%ebp)
  801474:	68 08 50 80 00       	push   $0x805008
  801479:	e8 f3 f4 ff ff       	call   800971 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80147e:	ba 00 00 00 00       	mov    $0x0,%edx
  801483:	b8 04 00 00 00       	mov    $0x4,%eax
  801488:	e8 ba fe ff ff       	call   801347 <fsipc>
}
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <devfile_read>:
{
  80148f:	f3 0f 1e fb          	endbr32 
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	56                   	push   %esi
  801497:	53                   	push   %ebx
  801498:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b6:	e8 8c fe ff ff       	call   801347 <fsipc>
  8014bb:	89 c3                	mov    %eax,%ebx
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 1f                	js     8014e0 <devfile_read+0x51>
	assert(r <= n);
  8014c1:	39 f0                	cmp    %esi,%eax
  8014c3:	77 24                	ja     8014e9 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ca:	7f 36                	jg     801502 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	50                   	push   %eax
  8014d0:	68 00 50 80 00       	push   $0x805000
  8014d5:	ff 75 0c             	pushl  0xc(%ebp)
  8014d8:	e8 94 f4 ff ff       	call   800971 <memmove>
	return r;
  8014dd:	83 c4 10             	add    $0x10,%esp
}
  8014e0:	89 d8                	mov    %ebx,%eax
  8014e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    
	assert(r <= n);
  8014e9:	68 30 27 80 00       	push   $0x802730
  8014ee:	68 37 27 80 00       	push   $0x802737
  8014f3:	68 8c 00 00 00       	push   $0x8c
  8014f8:	68 4c 27 80 00       	push   $0x80274c
  8014fd:	e8 79 0a 00 00       	call   801f7b <_panic>
	assert(r <= PGSIZE);
  801502:	68 57 27 80 00       	push   $0x802757
  801507:	68 37 27 80 00       	push   $0x802737
  80150c:	68 8d 00 00 00       	push   $0x8d
  801511:	68 4c 27 80 00       	push   $0x80274c
  801516:	e8 60 0a 00 00       	call   801f7b <_panic>

0080151b <open>:
{
  80151b:	f3 0f 1e fb          	endbr32 
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	83 ec 1c             	sub    $0x1c,%esp
  801527:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80152a:	56                   	push   %esi
  80152b:	e8 00 f2 ff ff       	call   800730 <strlen>
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801538:	7f 6c                	jg     8015a6 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	e8 5c f8 ff ff       	call   800da2 <fd_alloc>
  801546:	89 c3                	mov    %eax,%ebx
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 3c                	js     80158b <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	56                   	push   %esi
  801553:	68 00 50 80 00       	push   $0x805000
  801558:	e8 16 f2 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801560:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801565:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801568:	b8 01 00 00 00       	mov    $0x1,%eax
  80156d:	e8 d5 fd ff ff       	call   801347 <fsipc>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 19                	js     801594 <open+0x79>
	return fd2num(fd);
  80157b:	83 ec 0c             	sub    $0xc,%esp
  80157e:	ff 75 f4             	pushl  -0xc(%ebp)
  801581:	e8 ed f7 ff ff       	call   800d73 <fd2num>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 10             	add    $0x10,%esp
}
  80158b:	89 d8                	mov    %ebx,%eax
  80158d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801590:	5b                   	pop    %ebx
  801591:	5e                   	pop    %esi
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    
		fd_close(fd, 0);
  801594:	83 ec 08             	sub    $0x8,%esp
  801597:	6a 00                	push   $0x0
  801599:	ff 75 f4             	pushl  -0xc(%ebp)
  80159c:	e8 0a f9 ff ff       	call   800eab <fd_close>
		return r;
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	eb e5                	jmp    80158b <open+0x70>
		return -E_BAD_PATH;
  8015a6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015ab:	eb de                	jmp    80158b <open+0x70>

008015ad <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ad:	f3 0f 1e fb          	endbr32 
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c1:	e8 81 fd ff ff       	call   801347 <fsipc>
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015c8:	f3 0f 1e fb          	endbr32 
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015d2:	68 c3 27 80 00       	push   $0x8027c3
  8015d7:	ff 75 0c             	pushl  0xc(%ebp)
  8015da:	e8 94 f1 ff ff       	call   800773 <strcpy>
	return 0;
}
  8015df:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <devsock_close>:
{
  8015e6:	f3 0f 1e fb          	endbr32 
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 10             	sub    $0x10,%esp
  8015f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015f4:	53                   	push   %ebx
  8015f5:	e8 cd 0a 00 00       	call   8020c7 <pageref>
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	83 c4 10             	add    $0x10,%esp
		return 0;
  8015ff:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801604:	83 fa 01             	cmp    $0x1,%edx
  801607:	74 05                	je     80160e <devsock_close+0x28>
}
  801609:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	ff 73 0c             	pushl  0xc(%ebx)
  801614:	e8 e3 02 00 00       	call   8018fc <nsipc_close>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	eb eb                	jmp    801609 <devsock_close+0x23>

0080161e <devsock_write>:
{
  80161e:	f3 0f 1e fb          	endbr32 
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801628:	6a 00                	push   $0x0
  80162a:	ff 75 10             	pushl  0x10(%ebp)
  80162d:	ff 75 0c             	pushl  0xc(%ebp)
  801630:	8b 45 08             	mov    0x8(%ebp),%eax
  801633:	ff 70 0c             	pushl  0xc(%eax)
  801636:	e8 b5 03 00 00       	call   8019f0 <nsipc_send>
}
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <devsock_read>:
{
  80163d:	f3 0f 1e fb          	endbr32 
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801647:	6a 00                	push   $0x0
  801649:	ff 75 10             	pushl  0x10(%ebp)
  80164c:	ff 75 0c             	pushl  0xc(%ebp)
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	ff 70 0c             	pushl  0xc(%eax)
  801655:	e8 1f 03 00 00       	call   801979 <nsipc_recv>
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <fd2sockid>:
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801662:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801665:	52                   	push   %edx
  801666:	50                   	push   %eax
  801667:	e8 8c f7 ff ff       	call   800df8 <fd_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 10                	js     801683 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801676:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80167c:	39 08                	cmp    %ecx,(%eax)
  80167e:	75 05                	jne    801685 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801680:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    
		return -E_NOT_SUPP;
  801685:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80168a:	eb f7                	jmp    801683 <fd2sockid+0x27>

0080168c <alloc_sockfd>:
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 1c             	sub    $0x1c,%esp
  801694:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	e8 03 f7 ff ff       	call   800da2 <fd_alloc>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 43                	js     8016eb <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	68 07 04 00 00       	push   $0x407
  8016b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b3:	6a 00                	push   $0x0
  8016b5:	e8 22 f5 ff ff       	call   800bdc <sys_page_alloc>
  8016ba:	89 c3                	mov    %eax,%ebx
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 28                	js     8016eb <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8016c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c6:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8016cc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016d8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	50                   	push   %eax
  8016df:	e8 8f f6 ff ff       	call   800d73 <fd2num>
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	eb 0c                	jmp    8016f7 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8016eb:	83 ec 0c             	sub    $0xc,%esp
  8016ee:	56                   	push   %esi
  8016ef:	e8 08 02 00 00       	call   8018fc <nsipc_close>
		return r;
  8016f4:	83 c4 10             	add    $0x10,%esp
}
  8016f7:	89 d8                	mov    %ebx,%eax
  8016f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5e                   	pop    %esi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <accept>:
{
  801700:	f3 0f 1e fb          	endbr32 
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80170a:	8b 45 08             	mov    0x8(%ebp),%eax
  80170d:	e8 4a ff ff ff       	call   80165c <fd2sockid>
  801712:	85 c0                	test   %eax,%eax
  801714:	78 1b                	js     801731 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	ff 75 10             	pushl  0x10(%ebp)
  80171c:	ff 75 0c             	pushl  0xc(%ebp)
  80171f:	50                   	push   %eax
  801720:	e8 22 01 00 00       	call   801847 <nsipc_accept>
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 05                	js     801731 <accept+0x31>
	return alloc_sockfd(r);
  80172c:	e8 5b ff ff ff       	call   80168c <alloc_sockfd>
}
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <bind>:
{
  801733:	f3 0f 1e fb          	endbr32 
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	e8 17 ff ff ff       	call   80165c <fd2sockid>
  801745:	85 c0                	test   %eax,%eax
  801747:	78 12                	js     80175b <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	ff 75 10             	pushl  0x10(%ebp)
  80174f:	ff 75 0c             	pushl  0xc(%ebp)
  801752:	50                   	push   %eax
  801753:	e8 45 01 00 00       	call   80189d <nsipc_bind>
  801758:	83 c4 10             	add    $0x10,%esp
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <shutdown>:
{
  80175d:	f3 0f 1e fb          	endbr32 
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	e8 ed fe ff ff       	call   80165c <fd2sockid>
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 0f                	js     801782 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	50                   	push   %eax
  80177a:	e8 57 01 00 00       	call   8018d6 <nsipc_shutdown>
  80177f:	83 c4 10             	add    $0x10,%esp
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <connect>:
{
  801784:	f3 0f 1e fb          	endbr32 
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	e8 c6 fe ff ff       	call   80165c <fd2sockid>
  801796:	85 c0                	test   %eax,%eax
  801798:	78 12                	js     8017ac <connect+0x28>
	return nsipc_connect(r, name, namelen);
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	ff 75 10             	pushl  0x10(%ebp)
  8017a0:	ff 75 0c             	pushl  0xc(%ebp)
  8017a3:	50                   	push   %eax
  8017a4:	e8 71 01 00 00       	call   80191a <nsipc_connect>
  8017a9:	83 c4 10             	add    $0x10,%esp
}
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <listen>:
{
  8017ae:	f3 0f 1e fb          	endbr32 
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	e8 9c fe ff ff       	call   80165c <fd2sockid>
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 0f                	js     8017d3 <listen+0x25>
	return nsipc_listen(r, backlog);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	50                   	push   %eax
  8017cb:	e8 83 01 00 00       	call   801953 <nsipc_listen>
  8017d0:	83 c4 10             	add    $0x10,%esp
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <socket>:

int
socket(int domain, int type, int protocol)
{
  8017d5:	f3 0f 1e fb          	endbr32 
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017df:	ff 75 10             	pushl  0x10(%ebp)
  8017e2:	ff 75 0c             	pushl  0xc(%ebp)
  8017e5:	ff 75 08             	pushl  0x8(%ebp)
  8017e8:	e8 65 02 00 00       	call   801a52 <nsipc_socket>
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 05                	js     8017f9 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8017f4:	e8 93 fe ff ff       	call   80168c <alloc_sockfd>
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801804:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80180b:	74 26                	je     801833 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80180d:	6a 07                	push   $0x7
  80180f:	68 00 60 80 00       	push   $0x806000
  801814:	53                   	push   %ebx
  801815:	ff 35 04 40 80 00    	pushl  0x804004
  80181b:	e8 12 08 00 00       	call   802032 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801820:	83 c4 0c             	add    $0xc,%esp
  801823:	6a 00                	push   $0x0
  801825:	6a 00                	push   $0x0
  801827:	6a 00                	push   $0x0
  801829:	e8 97 07 00 00       	call   801fc5 <ipc_recv>
}
  80182e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801831:	c9                   	leave  
  801832:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	6a 02                	push   $0x2
  801838:	e8 4d 08 00 00       	call   80208a <ipc_find_env>
  80183d:	a3 04 40 80 00       	mov    %eax,0x804004
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	eb c6                	jmp    80180d <nsipc+0x12>

00801847 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801847:	f3 0f 1e fb          	endbr32 
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80185b:	8b 06                	mov    (%esi),%eax
  80185d:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801862:	b8 01 00 00 00       	mov    $0x1,%eax
  801867:	e8 8f ff ff ff       	call   8017fb <nsipc>
  80186c:	89 c3                	mov    %eax,%ebx
  80186e:	85 c0                	test   %eax,%eax
  801870:	79 09                	jns    80187b <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801872:	89 d8                	mov    %ebx,%eax
  801874:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	ff 35 10 60 80 00    	pushl  0x806010
  801884:	68 00 60 80 00       	push   $0x806000
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	e8 e0 f0 ff ff       	call   800971 <memmove>
		*addrlen = ret->ret_addrlen;
  801891:	a1 10 60 80 00       	mov    0x806010,%eax
  801896:	89 06                	mov    %eax,(%esi)
  801898:	83 c4 10             	add    $0x10,%esp
	return r;
  80189b:	eb d5                	jmp    801872 <nsipc_accept+0x2b>

0080189d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80189d:	f3 0f 1e fb          	endbr32 
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018b3:	53                   	push   %ebx
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	68 04 60 80 00       	push   $0x806004
  8018bc:	e8 b0 f0 ff ff       	call   800971 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018c1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8018cc:	e8 2a ff ff ff       	call   8017fb <nsipc>
}
  8018d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018d6:	f3 0f 1e fb          	endbr32 
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018eb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f5:	e8 01 ff ff ff       	call   8017fb <nsipc>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <nsipc_close>:

int
nsipc_close(int s)
{
  8018fc:	f3 0f 1e fb          	endbr32 
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
  801909:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80190e:	b8 04 00 00 00       	mov    $0x4,%eax
  801913:	e8 e3 fe ff ff       	call   8017fb <nsipc>
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80191a:	f3 0f 1e fb          	endbr32 
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801930:	53                   	push   %ebx
  801931:	ff 75 0c             	pushl  0xc(%ebp)
  801934:	68 04 60 80 00       	push   $0x806004
  801939:	e8 33 f0 ff ff       	call   800971 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80193e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801944:	b8 05 00 00 00       	mov    $0x5,%eax
  801949:	e8 ad fe ff ff       	call   8017fb <nsipc>
}
  80194e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801953:	f3 0f 1e fb          	endbr32 
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801965:	8b 45 0c             	mov    0xc(%ebp),%eax
  801968:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80196d:	b8 06 00 00 00       	mov    $0x6,%eax
  801972:	e8 84 fe ff ff       	call   8017fb <nsipc>
}
  801977:	c9                   	leave  
  801978:	c3                   	ret    

00801979 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801979:	f3 0f 1e fb          	endbr32 
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80198d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801993:	8b 45 14             	mov    0x14(%ebp),%eax
  801996:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80199b:	b8 07 00 00 00       	mov    $0x7,%eax
  8019a0:	e8 56 fe ff ff       	call   8017fb <nsipc>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 26                	js     8019d1 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8019ab:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8019b1:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019b6:	0f 4e c6             	cmovle %esi,%eax
  8019b9:	39 c3                	cmp    %eax,%ebx
  8019bb:	7f 1d                	jg     8019da <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019bd:	83 ec 04             	sub    $0x4,%esp
  8019c0:	53                   	push   %ebx
  8019c1:	68 00 60 80 00       	push   $0x806000
  8019c6:	ff 75 0c             	pushl  0xc(%ebp)
  8019c9:	e8 a3 ef ff ff       	call   800971 <memmove>
  8019ce:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019d1:	89 d8                	mov    %ebx,%eax
  8019d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019da:	68 cf 27 80 00       	push   $0x8027cf
  8019df:	68 37 27 80 00       	push   $0x802737
  8019e4:	6a 62                	push   $0x62
  8019e6:	68 e4 27 80 00       	push   $0x8027e4
  8019eb:	e8 8b 05 00 00       	call   801f7b <_panic>

008019f0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019f0:	f3 0f 1e fb          	endbr32 
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	53                   	push   %ebx
  8019f8:	83 ec 04             	sub    $0x4,%esp
  8019fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a06:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a0c:	7f 2e                	jg     801a3c <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a0e:	83 ec 04             	sub    $0x4,%esp
  801a11:	53                   	push   %ebx
  801a12:	ff 75 0c             	pushl  0xc(%ebp)
  801a15:	68 0c 60 80 00       	push   $0x80600c
  801a1a:	e8 52 ef ff ff       	call   800971 <memmove>
	nsipcbuf.send.req_size = size;
  801a1f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a25:	8b 45 14             	mov    0x14(%ebp),%eax
  801a28:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a2d:	b8 08 00 00 00       	mov    $0x8,%eax
  801a32:	e8 c4 fd ff ff       	call   8017fb <nsipc>
}
  801a37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    
	assert(size < 1600);
  801a3c:	68 f0 27 80 00       	push   $0x8027f0
  801a41:	68 37 27 80 00       	push   $0x802737
  801a46:	6a 6d                	push   $0x6d
  801a48:	68 e4 27 80 00       	push   $0x8027e4
  801a4d:	e8 29 05 00 00       	call   801f7b <_panic>

00801a52 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a52:	f3 0f 1e fb          	endbr32 
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a67:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a74:	b8 09 00 00 00       	mov    $0x9,%eax
  801a79:	e8 7d fd ff ff       	call   8017fb <nsipc>
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a80:	f3 0f 1e fb          	endbr32 
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	ff 75 08             	pushl  0x8(%ebp)
  801a92:	e8 f0 f2 ff ff       	call   800d87 <fd2data>
  801a97:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a99:	83 c4 08             	add    $0x8,%esp
  801a9c:	68 fc 27 80 00       	push   $0x8027fc
  801aa1:	53                   	push   %ebx
  801aa2:	e8 cc ec ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa7:	8b 46 04             	mov    0x4(%esi),%eax
  801aaa:	2b 06                	sub    (%esi),%eax
  801aac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab9:	00 00 00 
	stat->st_dev = &devpipe;
  801abc:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801ac3:	30 80 00 
	return 0;
}
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  801acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad2:	f3 0f 1e fb          	endbr32 
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	53                   	push   %ebx
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae0:	53                   	push   %ebx
  801ae1:	6a 00                	push   $0x0
  801ae3:	e8 3f f1 ff ff       	call   800c27 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae8:	89 1c 24             	mov    %ebx,(%esp)
  801aeb:	e8 97 f2 ff ff       	call   800d87 <fd2data>
  801af0:	83 c4 08             	add    $0x8,%esp
  801af3:	50                   	push   %eax
  801af4:	6a 00                	push   $0x0
  801af6:	e8 2c f1 ff ff       	call   800c27 <sys_page_unmap>
}
  801afb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <_pipeisclosed>:
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	57                   	push   %edi
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	83 ec 1c             	sub    $0x1c,%esp
  801b09:	89 c7                	mov    %eax,%edi
  801b0b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b0d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801b12:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	57                   	push   %edi
  801b19:	e8 a9 05 00 00       	call   8020c7 <pageref>
  801b1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b21:	89 34 24             	mov    %esi,(%esp)
  801b24:	e8 9e 05 00 00       	call   8020c7 <pageref>
		nn = thisenv->env_runs;
  801b29:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801b2f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	39 cb                	cmp    %ecx,%ebx
  801b37:	74 1b                	je     801b54 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b39:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b3c:	75 cf                	jne    801b0d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b3e:	8b 42 58             	mov    0x58(%edx),%eax
  801b41:	6a 01                	push   $0x1
  801b43:	50                   	push   %eax
  801b44:	53                   	push   %ebx
  801b45:	68 03 28 80 00       	push   $0x802803
  801b4a:	e8 1a e6 ff ff       	call   800169 <cprintf>
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	eb b9                	jmp    801b0d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b54:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b57:	0f 94 c0             	sete   %al
  801b5a:	0f b6 c0             	movzbl %al,%eax
}
  801b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devpipe_write>:
{
  801b65:	f3 0f 1e fb          	endbr32 
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	57                   	push   %edi
  801b6d:	56                   	push   %esi
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 28             	sub    $0x28,%esp
  801b72:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b75:	56                   	push   %esi
  801b76:	e8 0c f2 ff ff       	call   800d87 <fd2data>
  801b7b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	bf 00 00 00 00       	mov    $0x0,%edi
  801b85:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b88:	74 4f                	je     801bd9 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b8a:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8d:	8b 0b                	mov    (%ebx),%ecx
  801b8f:	8d 51 20             	lea    0x20(%ecx),%edx
  801b92:	39 d0                	cmp    %edx,%eax
  801b94:	72 14                	jb     801baa <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b96:	89 da                	mov    %ebx,%edx
  801b98:	89 f0                	mov    %esi,%eax
  801b9a:	e8 61 ff ff ff       	call   801b00 <_pipeisclosed>
  801b9f:	85 c0                	test   %eax,%eax
  801ba1:	75 3b                	jne    801bde <devpipe_write+0x79>
			sys_yield();
  801ba3:	e8 11 f0 ff ff       	call   800bb9 <sys_yield>
  801ba8:	eb e0                	jmp    801b8a <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bad:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb4:	89 c2                	mov    %eax,%edx
  801bb6:	c1 fa 1f             	sar    $0x1f,%edx
  801bb9:	89 d1                	mov    %edx,%ecx
  801bbb:	c1 e9 1b             	shr    $0x1b,%ecx
  801bbe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc1:	83 e2 1f             	and    $0x1f,%edx
  801bc4:	29 ca                	sub    %ecx,%edx
  801bc6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bce:	83 c0 01             	add    $0x1,%eax
  801bd1:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bd4:	83 c7 01             	add    $0x1,%edi
  801bd7:	eb ac                	jmp    801b85 <devpipe_write+0x20>
	return i;
  801bd9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bdc:	eb 05                	jmp    801be3 <devpipe_write+0x7e>
				return 0;
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	5f                   	pop    %edi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <devpipe_read>:
{
  801beb:	f3 0f 1e fb          	endbr32 
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	57                   	push   %edi
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 18             	sub    $0x18,%esp
  801bf8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bfb:	57                   	push   %edi
  801bfc:	e8 86 f1 ff ff       	call   800d87 <fd2data>
  801c01:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	be 00 00 00 00       	mov    $0x0,%esi
  801c0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c0e:	75 14                	jne    801c24 <devpipe_read+0x39>
	return i;
  801c10:	8b 45 10             	mov    0x10(%ebp),%eax
  801c13:	eb 02                	jmp    801c17 <devpipe_read+0x2c>
				return i;
  801c15:	89 f0                	mov    %esi,%eax
}
  801c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1a:	5b                   	pop    %ebx
  801c1b:	5e                   	pop    %esi
  801c1c:	5f                   	pop    %edi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    
			sys_yield();
  801c1f:	e8 95 ef ff ff       	call   800bb9 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c24:	8b 03                	mov    (%ebx),%eax
  801c26:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c29:	75 18                	jne    801c43 <devpipe_read+0x58>
			if (i > 0)
  801c2b:	85 f6                	test   %esi,%esi
  801c2d:	75 e6                	jne    801c15 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c2f:	89 da                	mov    %ebx,%edx
  801c31:	89 f8                	mov    %edi,%eax
  801c33:	e8 c8 fe ff ff       	call   801b00 <_pipeisclosed>
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	74 e3                	je     801c1f <devpipe_read+0x34>
				return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c41:	eb d4                	jmp    801c17 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c43:	99                   	cltd   
  801c44:	c1 ea 1b             	shr    $0x1b,%edx
  801c47:	01 d0                	add    %edx,%eax
  801c49:	83 e0 1f             	and    $0x1f,%eax
  801c4c:	29 d0                	sub    %edx,%eax
  801c4e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c56:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c59:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c5c:	83 c6 01             	add    $0x1,%esi
  801c5f:	eb aa                	jmp    801c0b <devpipe_read+0x20>

00801c61 <pipe>:
{
  801c61:	f3 0f 1e fb          	endbr32 
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	e8 2c f1 ff ff       	call   800da2 <fd_alloc>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	0f 88 23 01 00 00    	js     801da6 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c83:	83 ec 04             	sub    $0x4,%esp
  801c86:	68 07 04 00 00       	push   $0x407
  801c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8e:	6a 00                	push   $0x0
  801c90:	e8 47 ef ff ff       	call   800bdc <sys_page_alloc>
  801c95:	89 c3                	mov    %eax,%ebx
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	0f 88 04 01 00 00    	js     801da6 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca8:	50                   	push   %eax
  801ca9:	e8 f4 f0 ff ff       	call   800da2 <fd_alloc>
  801cae:	89 c3                	mov    %eax,%ebx
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 db 00 00 00    	js     801d96 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbb:	83 ec 04             	sub    $0x4,%esp
  801cbe:	68 07 04 00 00       	push   $0x407
  801cc3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 0f ef ff ff       	call   800bdc <sys_page_alloc>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 bc 00 00 00    	js     801d96 <pipe+0x135>
	va = fd2data(fd0);
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce0:	e8 a2 f0 ff ff       	call   800d87 <fd2data>
  801ce5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce7:	83 c4 0c             	add    $0xc,%esp
  801cea:	68 07 04 00 00       	push   $0x407
  801cef:	50                   	push   %eax
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 e5 ee ff ff       	call   800bdc <sys_page_alloc>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	0f 88 82 00 00 00    	js     801d86 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0a:	e8 78 f0 ff ff       	call   800d87 <fd2data>
  801d0f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d16:	50                   	push   %eax
  801d17:	6a 00                	push   $0x0
  801d19:	56                   	push   %esi
  801d1a:	6a 00                	push   $0x0
  801d1c:	e8 e1 ee ff ff       	call   800c02 <sys_page_map>
  801d21:	89 c3                	mov    %eax,%ebx
  801d23:	83 c4 20             	add    $0x20,%esp
  801d26:	85 c0                	test   %eax,%eax
  801d28:	78 4e                	js     801d78 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d2a:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801d2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d32:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d37:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d3e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d41:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d46:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	ff 75 f4             	pushl  -0xc(%ebp)
  801d53:	e8 1b f0 ff ff       	call   800d73 <fd2num>
  801d58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d5b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d5d:	83 c4 04             	add    $0x4,%esp
  801d60:	ff 75 f0             	pushl  -0x10(%ebp)
  801d63:	e8 0b f0 ff ff       	call   800d73 <fd2num>
  801d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d76:	eb 2e                	jmp    801da6 <pipe+0x145>
	sys_page_unmap(0, va);
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	56                   	push   %esi
  801d7c:	6a 00                	push   $0x0
  801d7e:	e8 a4 ee ff ff       	call   800c27 <sys_page_unmap>
  801d83:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d86:	83 ec 08             	sub    $0x8,%esp
  801d89:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8c:	6a 00                	push   $0x0
  801d8e:	e8 94 ee ff ff       	call   800c27 <sys_page_unmap>
  801d93:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d96:	83 ec 08             	sub    $0x8,%esp
  801d99:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9c:	6a 00                	push   $0x0
  801d9e:	e8 84 ee ff ff       	call   800c27 <sys_page_unmap>
  801da3:	83 c4 10             	add    $0x10,%esp
}
  801da6:	89 d8                	mov    %ebx,%eax
  801da8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dab:	5b                   	pop    %ebx
  801dac:	5e                   	pop    %esi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <pipeisclosed>:
{
  801daf:	f3 0f 1e fb          	endbr32 
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbc:	50                   	push   %eax
  801dbd:	ff 75 08             	pushl  0x8(%ebp)
  801dc0:	e8 33 f0 ff ff       	call   800df8 <fd_lookup>
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 18                	js     801de4 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801dcc:	83 ec 0c             	sub    $0xc,%esp
  801dcf:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd2:	e8 b0 ef ff ff       	call   800d87 <fd2data>
  801dd7:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	e8 1f fd ff ff       	call   801b00 <_pipeisclosed>
  801de1:	83 c4 10             	add    $0x10,%esp
}
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801de6:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801dea:	b8 00 00 00 00       	mov    $0x0,%eax
  801def:	c3                   	ret    

00801df0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801df0:	f3 0f 1e fb          	endbr32 
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dfa:	68 1b 28 80 00       	push   $0x80281b
  801dff:	ff 75 0c             	pushl  0xc(%ebp)
  801e02:	e8 6c e9 ff ff       	call   800773 <strcpy>
	return 0;
}
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <devcons_write>:
{
  801e0e:	f3 0f 1e fb          	endbr32 
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e1e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e23:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e29:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e2c:	73 31                	jae    801e5f <devcons_write+0x51>
		m = n - tot;
  801e2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e31:	29 f3                	sub    %esi,%ebx
  801e33:	83 fb 7f             	cmp    $0x7f,%ebx
  801e36:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e3b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e3e:	83 ec 04             	sub    $0x4,%esp
  801e41:	53                   	push   %ebx
  801e42:	89 f0                	mov    %esi,%eax
  801e44:	03 45 0c             	add    0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	57                   	push   %edi
  801e49:	e8 23 eb ff ff       	call   800971 <memmove>
		sys_cputs(buf, m);
  801e4e:	83 c4 08             	add    $0x8,%esp
  801e51:	53                   	push   %ebx
  801e52:	57                   	push   %edi
  801e53:	e8 d5 ec ff ff       	call   800b2d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e58:	01 de                	add    %ebx,%esi
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	eb ca                	jmp    801e29 <devcons_write+0x1b>
}
  801e5f:	89 f0                	mov    %esi,%eax
  801e61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5f                   	pop    %edi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    

00801e69 <devcons_read>:
{
  801e69:	f3 0f 1e fb          	endbr32 
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 08             	sub    $0x8,%esp
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7c:	74 21                	je     801e9f <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e7e:	e8 cc ec ff ff       	call   800b4f <sys_cgetc>
  801e83:	85 c0                	test   %eax,%eax
  801e85:	75 07                	jne    801e8e <devcons_read+0x25>
		sys_yield();
  801e87:	e8 2d ed ff ff       	call   800bb9 <sys_yield>
  801e8c:	eb f0                	jmp    801e7e <devcons_read+0x15>
	if (c < 0)
  801e8e:	78 0f                	js     801e9f <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e90:	83 f8 04             	cmp    $0x4,%eax
  801e93:	74 0c                	je     801ea1 <devcons_read+0x38>
	*(char*)vbuf = c;
  801e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e98:	88 02                	mov    %al,(%edx)
	return 1;
  801e9a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    
		return 0;
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea6:	eb f7                	jmp    801e9f <devcons_read+0x36>

00801ea8 <cputchar>:
{
  801ea8:	f3 0f 1e fb          	endbr32 
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb5:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801eb8:	6a 01                	push   $0x1
  801eba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ebd:	50                   	push   %eax
  801ebe:	e8 6a ec ff ff       	call   800b2d <sys_cputs>
}
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <getchar>:
{
  801ec8:	f3 0f 1e fb          	endbr32 
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ed2:	6a 01                	push   $0x1
  801ed4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	6a 00                	push   $0x0
  801eda:	e8 a1 f1 ff ff       	call   801080 <read>
	if (r < 0)
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 06                	js     801eec <getchar+0x24>
	if (r < 1)
  801ee6:	74 06                	je     801eee <getchar+0x26>
	return c;
  801ee8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    
		return -E_EOF;
  801eee:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ef3:	eb f7                	jmp    801eec <getchar+0x24>

00801ef5 <iscons>:
{
  801ef5:	f3 0f 1e fb          	endbr32 
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f02:	50                   	push   %eax
  801f03:	ff 75 08             	pushl  0x8(%ebp)
  801f06:	e8 ed ee ff ff       	call   800df8 <fd_lookup>
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 11                	js     801f23 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f15:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f1b:	39 10                	cmp    %edx,(%eax)
  801f1d:	0f 94 c0             	sete   %al
  801f20:	0f b6 c0             	movzbl %al,%eax
}
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    

00801f25 <opencons>:
{
  801f25:	f3 0f 1e fb          	endbr32 
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f32:	50                   	push   %eax
  801f33:	e8 6a ee ff ff       	call   800da2 <fd_alloc>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	78 3a                	js     801f79 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f3f:	83 ec 04             	sub    $0x4,%esp
  801f42:	68 07 04 00 00       	push   $0x407
  801f47:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4a:	6a 00                	push   $0x0
  801f4c:	e8 8b ec ff ff       	call   800bdc <sys_page_alloc>
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	85 c0                	test   %eax,%eax
  801f56:	78 21                	js     801f79 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5b:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f61:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f66:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	50                   	push   %eax
  801f71:	e8 fd ed ff ff       	call   800d73 <fd2num>
  801f76:	83 c4 10             	add    $0x10,%esp
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f7b:	f3 0f 1e fb          	endbr32 
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f84:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f87:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f8d:	e8 04 ec ff ff       	call   800b96 <sys_getenvid>
  801f92:	83 ec 0c             	sub    $0xc,%esp
  801f95:	ff 75 0c             	pushl  0xc(%ebp)
  801f98:	ff 75 08             	pushl  0x8(%ebp)
  801f9b:	56                   	push   %esi
  801f9c:	50                   	push   %eax
  801f9d:	68 28 28 80 00       	push   $0x802828
  801fa2:	e8 c2 e1 ff ff       	call   800169 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fa7:	83 c4 18             	add    $0x18,%esp
  801faa:	53                   	push   %ebx
  801fab:	ff 75 10             	pushl  0x10(%ebp)
  801fae:	e8 61 e1 ff ff       	call   800114 <vcprintf>
	cprintf("\n");
  801fb3:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  801fba:	e8 aa e1 ff ff       	call   800169 <cprintf>
  801fbf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fc2:	cc                   	int3   
  801fc3:	eb fd                	jmp    801fc2 <_panic+0x47>

00801fc5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc5:	f3 0f 1e fb          	endbr32 
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fde:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fe1:	83 ec 0c             	sub    $0xc,%esp
  801fe4:	50                   	push   %eax
  801fe5:	e8 f8 ec ff ff       	call   800ce2 <sys_ipc_recv>
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	85 c0                	test   %eax,%eax
  801fef:	75 2b                	jne    80201c <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801ff1:	85 f6                	test   %esi,%esi
  801ff3:	74 0a                	je     801fff <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801ff5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801ffa:	8b 40 74             	mov    0x74(%eax),%eax
  801ffd:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fff:	85 db                	test   %ebx,%ebx
  802001:	74 0a                	je     80200d <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802003:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802008:	8b 40 78             	mov    0x78(%eax),%eax
  80200b:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80200d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802012:	8b 40 70             	mov    0x70(%eax),%eax
}
  802015:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802018:	5b                   	pop    %ebx
  802019:	5e                   	pop    %esi
  80201a:	5d                   	pop    %ebp
  80201b:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80201c:	85 f6                	test   %esi,%esi
  80201e:	74 06                	je     802026 <ipc_recv+0x61>
  802020:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802026:	85 db                	test   %ebx,%ebx
  802028:	74 eb                	je     802015 <ipc_recv+0x50>
  80202a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802030:	eb e3                	jmp    802015 <ipc_recv+0x50>

00802032 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802032:	f3 0f 1e fb          	endbr32 
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	57                   	push   %edi
  80203a:	56                   	push   %esi
  80203b:	53                   	push   %ebx
  80203c:	83 ec 0c             	sub    $0xc,%esp
  80203f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802042:	8b 75 0c             	mov    0xc(%ebp),%esi
  802045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802048:	85 db                	test   %ebx,%ebx
  80204a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80204f:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802052:	ff 75 14             	pushl  0x14(%ebp)
  802055:	53                   	push   %ebx
  802056:	56                   	push   %esi
  802057:	57                   	push   %edi
  802058:	e8 5e ec ff ff       	call   800cbb <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802063:	75 07                	jne    80206c <ipc_send+0x3a>
			sys_yield();
  802065:	e8 4f eb ff ff       	call   800bb9 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80206a:	eb e6                	jmp    802052 <ipc_send+0x20>
		}
		else if (ret == 0)
  80206c:	85 c0                	test   %eax,%eax
  80206e:	75 08                	jne    802078 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802078:	50                   	push   %eax
  802079:	68 4b 28 80 00       	push   $0x80284b
  80207e:	6a 48                	push   $0x48
  802080:	68 59 28 80 00       	push   $0x802859
  802085:	e8 f1 fe ff ff       	call   801f7b <_panic>

0080208a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80208a:	f3 0f 1e fb          	endbr32 
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802094:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802099:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80209c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a2:	8b 52 50             	mov    0x50(%edx),%edx
  8020a5:	39 ca                	cmp    %ecx,%edx
  8020a7:	74 11                	je     8020ba <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8020a9:	83 c0 01             	add    $0x1,%eax
  8020ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b1:	75 e6                	jne    802099 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b8:	eb 0b                	jmp    8020c5 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c2:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    

008020c7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c7:	f3 0f 1e fb          	endbr32 
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d1:	89 c2                	mov    %eax,%edx
  8020d3:	c1 ea 16             	shr    $0x16,%edx
  8020d6:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020dd:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020e2:	f6 c1 01             	test   $0x1,%cl
  8020e5:	74 1c                	je     802103 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020e7:	c1 e8 0c             	shr    $0xc,%eax
  8020ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020f1:	a8 01                	test   $0x1,%al
  8020f3:	74 0e                	je     802103 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f5:	c1 e8 0c             	shr    $0xc,%eax
  8020f8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020ff:	ef 
  802100:	0f b7 d2             	movzwl %dx,%edx
}
  802103:	89 d0                	mov    %edx,%eax
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    
  802107:	66 90                	xchg   %ax,%ax
  802109:	66 90                	xchg   %ax,%ax
  80210b:	66 90                	xchg   %ax,%ax
  80210d:	66 90                	xchg   %ax,%ax
  80210f:	90                   	nop

00802110 <__udivdi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802123:	8b 74 24 34          	mov    0x34(%esp),%esi
  802127:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80212b:	85 d2                	test   %edx,%edx
  80212d:	75 19                	jne    802148 <__udivdi3+0x38>
  80212f:	39 f3                	cmp    %esi,%ebx
  802131:	76 4d                	jbe    802180 <__udivdi3+0x70>
  802133:	31 ff                	xor    %edi,%edi
  802135:	89 e8                	mov    %ebp,%eax
  802137:	89 f2                	mov    %esi,%edx
  802139:	f7 f3                	div    %ebx
  80213b:	89 fa                	mov    %edi,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	76 14                	jbe    802160 <__udivdi3+0x50>
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	31 c0                	xor    %eax,%eax
  802150:	89 fa                	mov    %edi,%edx
  802152:	83 c4 1c             	add    $0x1c,%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	0f bd fa             	bsr    %edx,%edi
  802163:	83 f7 1f             	xor    $0x1f,%edi
  802166:	75 48                	jne    8021b0 <__udivdi3+0xa0>
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	72 06                	jb     802172 <__udivdi3+0x62>
  80216c:	31 c0                	xor    %eax,%eax
  80216e:	39 eb                	cmp    %ebp,%ebx
  802170:	77 de                	ja     802150 <__udivdi3+0x40>
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb d7                	jmp    802150 <__udivdi3+0x40>
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d9                	mov    %ebx,%ecx
  802182:	85 db                	test   %ebx,%ebx
  802184:	75 0b                	jne    802191 <__udivdi3+0x81>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f3                	div    %ebx
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	31 d2                	xor    %edx,%edx
  802193:	89 f0                	mov    %esi,%eax
  802195:	f7 f1                	div    %ecx
  802197:	89 c6                	mov    %eax,%esi
  802199:	89 e8                	mov    %ebp,%eax
  80219b:	89 f7                	mov    %esi,%edi
  80219d:	f7 f1                	div    %ecx
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 f9                	mov    %edi,%ecx
  8021b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021b7:	29 f8                	sub    %edi,%eax
  8021b9:	d3 e2                	shl    %cl,%edx
  8021bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	89 da                	mov    %ebx,%edx
  8021c3:	d3 ea                	shr    %cl,%edx
  8021c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021c9:	09 d1                	or     %edx,%ecx
  8021cb:	89 f2                	mov    %esi,%edx
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	d3 e3                	shl    %cl,%ebx
  8021d5:	89 c1                	mov    %eax,%ecx
  8021d7:	d3 ea                	shr    %cl,%edx
  8021d9:	89 f9                	mov    %edi,%ecx
  8021db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021df:	89 eb                	mov    %ebp,%ebx
  8021e1:	d3 e6                	shl    %cl,%esi
  8021e3:	89 c1                	mov    %eax,%ecx
  8021e5:	d3 eb                	shr    %cl,%ebx
  8021e7:	09 de                	or     %ebx,%esi
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	f7 74 24 08          	divl   0x8(%esp)
  8021ef:	89 d6                	mov    %edx,%esi
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	f7 64 24 0c          	mull   0xc(%esp)
  8021f7:	39 d6                	cmp    %edx,%esi
  8021f9:	72 15                	jb     802210 <__udivdi3+0x100>
  8021fb:	89 f9                	mov    %edi,%ecx
  8021fd:	d3 e5                	shl    %cl,%ebp
  8021ff:	39 c5                	cmp    %eax,%ebp
  802201:	73 04                	jae    802207 <__udivdi3+0xf7>
  802203:	39 d6                	cmp    %edx,%esi
  802205:	74 09                	je     802210 <__udivdi3+0x100>
  802207:	89 d8                	mov    %ebx,%eax
  802209:	31 ff                	xor    %edi,%edi
  80220b:	e9 40 ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802210:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802213:	31 ff                	xor    %edi,%edi
  802215:	e9 36 ff ff ff       	jmp    802150 <__udivdi3+0x40>
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	f3 0f 1e fb          	endbr32 
  802224:	55                   	push   %ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	83 ec 1c             	sub    $0x1c,%esp
  80222b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80222f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802233:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802237:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80223b:	85 c0                	test   %eax,%eax
  80223d:	75 19                	jne    802258 <__umoddi3+0x38>
  80223f:	39 df                	cmp    %ebx,%edi
  802241:	76 5d                	jbe    8022a0 <__umoddi3+0x80>
  802243:	89 f0                	mov    %esi,%eax
  802245:	89 da                	mov    %ebx,%edx
  802247:	f7 f7                	div    %edi
  802249:	89 d0                	mov    %edx,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	83 c4 1c             	add    $0x1c,%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5f                   	pop    %edi
  802253:	5d                   	pop    %ebp
  802254:	c3                   	ret    
  802255:	8d 76 00             	lea    0x0(%esi),%esi
  802258:	89 f2                	mov    %esi,%edx
  80225a:	39 d8                	cmp    %ebx,%eax
  80225c:	76 12                	jbe    802270 <__umoddi3+0x50>
  80225e:	89 f0                	mov    %esi,%eax
  802260:	89 da                	mov    %ebx,%edx
  802262:	83 c4 1c             	add    $0x1c,%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5f                   	pop    %edi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    
  80226a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802270:	0f bd e8             	bsr    %eax,%ebp
  802273:	83 f5 1f             	xor    $0x1f,%ebp
  802276:	75 50                	jne    8022c8 <__umoddi3+0xa8>
  802278:	39 d8                	cmp    %ebx,%eax
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	89 d9                	mov    %ebx,%ecx
  802282:	39 f7                	cmp    %esi,%edi
  802284:	0f 86 d6 00 00 00    	jbe    802360 <__umoddi3+0x140>
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	89 ca                	mov    %ecx,%edx
  80228e:	83 c4 1c             	add    $0x1c,%esp
  802291:	5b                   	pop    %ebx
  802292:	5e                   	pop    %esi
  802293:	5f                   	pop    %edi
  802294:	5d                   	pop    %ebp
  802295:	c3                   	ret    
  802296:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	89 fd                	mov    %edi,%ebp
  8022a2:	85 ff                	test   %edi,%edi
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 d8                	mov    %ebx,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 f0                	mov    %esi,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	eb 8c                	jmp    80224d <__umoddi3+0x2d>
  8022c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8022cf:	29 ea                	sub    %ebp,%edx
  8022d1:	d3 e0                	shl    %cl,%eax
  8022d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 f8                	mov    %edi,%eax
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022e9:	09 c1                	or     %eax,%ecx
  8022eb:	89 d8                	mov    %ebx,%eax
  8022ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f1:	89 e9                	mov    %ebp,%ecx
  8022f3:	d3 e7                	shl    %cl,%edi
  8022f5:	89 d1                	mov    %edx,%ecx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8022ff:	d3 e3                	shl    %cl,%ebx
  802301:	89 c7                	mov    %eax,%edi
  802303:	89 d1                	mov    %edx,%ecx
  802305:	89 f0                	mov    %esi,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	89 fa                	mov    %edi,%edx
  80230d:	d3 e6                	shl    %cl,%esi
  80230f:	09 d8                	or     %ebx,%eax
  802311:	f7 74 24 08          	divl   0x8(%esp)
  802315:	89 d1                	mov    %edx,%ecx
  802317:	89 f3                	mov    %esi,%ebx
  802319:	f7 64 24 0c          	mull   0xc(%esp)
  80231d:	89 c6                	mov    %eax,%esi
  80231f:	89 d7                	mov    %edx,%edi
  802321:	39 d1                	cmp    %edx,%ecx
  802323:	72 06                	jb     80232b <__umoddi3+0x10b>
  802325:	75 10                	jne    802337 <__umoddi3+0x117>
  802327:	39 c3                	cmp    %eax,%ebx
  802329:	73 0c                	jae    802337 <__umoddi3+0x117>
  80232b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80232f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802333:	89 d7                	mov    %edx,%edi
  802335:	89 c6                	mov    %eax,%esi
  802337:	89 ca                	mov    %ecx,%edx
  802339:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80233e:	29 f3                	sub    %esi,%ebx
  802340:	19 fa                	sbb    %edi,%edx
  802342:	89 d0                	mov    %edx,%eax
  802344:	d3 e0                	shl    %cl,%eax
  802346:	89 e9                	mov    %ebp,%ecx
  802348:	d3 eb                	shr    %cl,%ebx
  80234a:	d3 ea                	shr    %cl,%edx
  80234c:	09 d8                	or     %ebx,%eax
  80234e:	83 c4 1c             	add    $0x1c,%esp
  802351:	5b                   	pop    %ebx
  802352:	5e                   	pop    %esi
  802353:	5f                   	pop    %edi
  802354:	5d                   	pop    %ebp
  802355:	c3                   	ret    
  802356:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 fe                	sub    %edi,%esi
  802362:	19 c3                	sbb    %eax,%ebx
  802364:	89 f2                	mov    %esi,%edx
  802366:	89 d9                	mov    %ebx,%ecx
  802368:	e9 1d ff ff ff       	jmp    80228a <__umoddi3+0x6a>
