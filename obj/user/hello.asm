
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003d:	68 80 23 80 00       	push   $0x802380
  800042:	e8 20 01 00 00       	call   800167 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800047:	a1 08 40 80 00       	mov    0x804008,%eax
  80004c:	8b 40 48             	mov    0x48(%eax),%eax
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	50                   	push   %eax
  800053:	68 8e 23 80 00       	push   $0x80238e
  800058:	e8 0a 01 00 00       	call   800167 <cprintf>
}
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	f3 0f 1e fb          	endbr32 
  800066:	55                   	push   %ebp
  800067:	89 e5                	mov    %esp,%ebp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800071:	e8 1e 0b 00 00       	call   800b94 <sys_getenvid>
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800083:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 db                	test   %ebx,%ebx
  80008a:	7e 07                	jle    800093 <libmain+0x31>
		binaryname = argv[0];
  80008c:	8b 06                	mov    (%esi),%eax
  80008e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 0a 00 00 00       	call   8000ac <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	f3 0f 1e fb          	endbr32 
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000b6:	e8 aa 0e 00 00       	call   800f65 <close_all>
	sys_env_destroy(0);
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 ab 0a 00 00       	call   800b70 <sys_env_destroy>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ca:	f3 0f 1e fb          	endbr32 
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	53                   	push   %ebx
  8000d2:	83 ec 04             	sub    $0x4,%esp
  8000d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d8:	8b 13                	mov    (%ebx),%edx
  8000da:	8d 42 01             	lea    0x1(%edx),%eax
  8000dd:	89 03                	mov    %eax,(%ebx)
  8000df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	74 09                	je     8000f6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ed:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f6:	83 ec 08             	sub    $0x8,%esp
  8000f9:	68 ff 00 00 00       	push   $0xff
  8000fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800101:	50                   	push   %eax
  800102:	e8 24 0a 00 00       	call   800b2b <sys_cputs>
		b->idx = 0;
  800107:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	eb db                	jmp    8000ed <putch+0x23>

00800112 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800112:	f3 0f 1e fb          	endbr32 
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800126:	00 00 00 
	b.cnt = 0;
  800129:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800130:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800133:	ff 75 0c             	pushl  0xc(%ebp)
  800136:	ff 75 08             	pushl  0x8(%ebp)
  800139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013f:	50                   	push   %eax
  800140:	68 ca 00 80 00       	push   $0x8000ca
  800145:	e8 20 01 00 00       	call   80026a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014a:	83 c4 08             	add    $0x8,%esp
  80014d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	50                   	push   %eax
  80015a:	e8 cc 09 00 00       	call   800b2b <sys_cputs>

	return b.cnt;
}
  80015f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800167:	f3 0f 1e fb          	endbr32 
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	50                   	push   %eax
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	e8 95 ff ff ff       	call   800112 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 1c             	sub    $0x1c,%esp
  800188:	89 c7                	mov    %eax,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 d1                	mov    %edx,%ecx
  800194:	89 c2                	mov    %eax,%edx
  800196:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800199:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019c:	8b 45 10             	mov    0x10(%ebp),%eax
  80019f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8001a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ac:	39 c2                	cmp    %eax,%edx
  8001ae:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b1:	72 3e                	jb     8001f1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	ff 75 18             	pushl  0x18(%ebp)
  8001b9:	83 eb 01             	sub    $0x1,%ebx
  8001bc:	53                   	push   %ebx
  8001bd:	50                   	push   %eax
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8001cd:	e8 3e 1f 00 00       	call   802110 <__udivdi3>
  8001d2:	83 c4 18             	add    $0x18,%esp
  8001d5:	52                   	push   %edx
  8001d6:	50                   	push   %eax
  8001d7:	89 f2                	mov    %esi,%edx
  8001d9:	89 f8                	mov    %edi,%eax
  8001db:	e8 9f ff ff ff       	call   80017f <printnum>
  8001e0:	83 c4 20             	add    $0x20,%esp
  8001e3:	eb 13                	jmp    8001f8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	ff 75 18             	pushl  0x18(%ebp)
  8001ec:	ff d7                	call   *%edi
  8001ee:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f1:	83 eb 01             	sub    $0x1,%ebx
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7f ed                	jg     8001e5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	56                   	push   %esi
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 10 20 00 00       	call   802220 <__umoddi3>
  800210:	83 c4 14             	add    $0x14,%esp
  800213:	0f be 80 af 23 80 00 	movsbl 0x8023af(%eax),%eax
  80021a:	50                   	push   %eax
  80021b:	ff d7                	call   *%edi
}
  80021d:	83 c4 10             	add    $0x10,%esp
  800220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800228:	f3 0f 1e fb          	endbr32 
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800232:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800236:	8b 10                	mov    (%eax),%edx
  800238:	3b 50 04             	cmp    0x4(%eax),%edx
  80023b:	73 0a                	jae    800247 <sprintputch+0x1f>
		*b->buf++ = ch;
  80023d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800240:	89 08                	mov    %ecx,(%eax)
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	88 02                	mov    %al,(%edx)
}
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <printfmt>:
{
  800249:	f3 0f 1e fb          	endbr32 
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800253:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800256:	50                   	push   %eax
  800257:	ff 75 10             	pushl  0x10(%ebp)
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	e8 05 00 00 00       	call   80026a <vprintfmt>
}
  800265:	83 c4 10             	add    $0x10,%esp
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <vprintfmt>:
{
  80026a:	f3 0f 1e fb          	endbr32 
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	83 ec 3c             	sub    $0x3c,%esp
  800277:	8b 75 08             	mov    0x8(%ebp),%esi
  80027a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800280:	e9 8e 03 00 00       	jmp    800613 <vprintfmt+0x3a9>
		padc = ' ';
  800285:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800289:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800290:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800297:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80029e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a3:	8d 47 01             	lea    0x1(%edi),%eax
  8002a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a9:	0f b6 17             	movzbl (%edi),%edx
  8002ac:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002af:	3c 55                	cmp    $0x55,%al
  8002b1:	0f 87 df 03 00 00    	ja     800696 <vprintfmt+0x42c>
  8002b7:	0f b6 c0             	movzbl %al,%eax
  8002ba:	3e ff 24 85 00 25 80 	notrack jmp *0x802500(,%eax,4)
  8002c1:	00 
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c9:	eb d8                	jmp    8002a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ce:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002d2:	eb cf                	jmp    8002a3 <vprintfmt+0x39>
  8002d4:	0f b6 d2             	movzbl %dl,%edx
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002da:	b8 00 00 00 00       	mov    $0x0,%eax
  8002df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8002e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002ec:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ef:	83 f9 09             	cmp    $0x9,%ecx
  8002f2:	77 55                	ja     800349 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8002f7:	eb e9                	jmp    8002e2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fc:	8b 00                	mov    (%eax),%eax
  8002fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800301:	8b 45 14             	mov    0x14(%ebp),%eax
  800304:	8d 40 04             	lea    0x4(%eax),%eax
  800307:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80030d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800311:	79 90                	jns    8002a3 <vprintfmt+0x39>
				width = precision, precision = -1;
  800313:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800316:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800319:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800320:	eb 81                	jmp    8002a3 <vprintfmt+0x39>
  800322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800325:	85 c0                	test   %eax,%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
  80032c:	0f 49 d0             	cmovns %eax,%edx
  80032f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800335:	e9 69 ff ff ff       	jmp    8002a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80033d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800344:	e9 5a ff ff ff       	jmp    8002a3 <vprintfmt+0x39>
  800349:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034f:	eb bc                	jmp    80030d <vprintfmt+0xa3>
			lflag++;
  800351:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800357:	e9 47 ff ff ff       	jmp    8002a3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8d 78 04             	lea    0x4(%eax),%edi
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	53                   	push   %ebx
  800366:	ff 30                	pushl  (%eax)
  800368:	ff d6                	call   *%esi
			break;
  80036a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80036d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800370:	e9 9b 02 00 00       	jmp    800610 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800375:	8b 45 14             	mov    0x14(%ebp),%eax
  800378:	8d 78 04             	lea    0x4(%eax),%edi
  80037b:	8b 00                	mov    (%eax),%eax
  80037d:	99                   	cltd   
  80037e:	31 d0                	xor    %edx,%eax
  800380:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800382:	83 f8 0f             	cmp    $0xf,%eax
  800385:	7f 23                	jg     8003aa <vprintfmt+0x140>
  800387:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 18                	je     8003aa <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800392:	52                   	push   %edx
  800393:	68 69 27 80 00       	push   $0x802769
  800398:	53                   	push   %ebx
  800399:	56                   	push   %esi
  80039a:	e8 aa fe ff ff       	call   800249 <printfmt>
  80039f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a5:	e9 66 02 00 00       	jmp    800610 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003aa:	50                   	push   %eax
  8003ab:	68 c7 23 80 00       	push   $0x8023c7
  8003b0:	53                   	push   %ebx
  8003b1:	56                   	push   %esi
  8003b2:	e8 92 fe ff ff       	call   800249 <printfmt>
  8003b7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ba:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003bd:	e9 4e 02 00 00       	jmp    800610 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	83 c0 04             	add    $0x4,%eax
  8003c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003d0:	85 d2                	test   %edx,%edx
  8003d2:	b8 c0 23 80 00       	mov    $0x8023c0,%eax
  8003d7:	0f 45 c2             	cmovne %edx,%eax
  8003da:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e1:	7e 06                	jle    8003e9 <vprintfmt+0x17f>
  8003e3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e7:	75 0d                	jne    8003f6 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003ec:	89 c7                	mov    %eax,%edi
  8003ee:	03 45 e0             	add    -0x20(%ebp),%eax
  8003f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f4:	eb 55                	jmp    80044b <vprintfmt+0x1e1>
  8003f6:	83 ec 08             	sub    $0x8,%esp
  8003f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003fc:	ff 75 cc             	pushl  -0x34(%ebp)
  8003ff:	e8 46 03 00 00       	call   80074a <strnlen>
  800404:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800407:	29 c2                	sub    %eax,%edx
  800409:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800411:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800415:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800418:	85 ff                	test   %edi,%edi
  80041a:	7e 11                	jle    80042d <vprintfmt+0x1c3>
					putch(padc, putdat);
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	53                   	push   %ebx
  800420:	ff 75 e0             	pushl  -0x20(%ebp)
  800423:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ef 01             	sub    $0x1,%edi
  800428:	83 c4 10             	add    $0x10,%esp
  80042b:	eb eb                	jmp    800418 <vprintfmt+0x1ae>
  80042d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800430:	85 d2                	test   %edx,%edx
  800432:	b8 00 00 00 00       	mov    $0x0,%eax
  800437:	0f 49 c2             	cmovns %edx,%eax
  80043a:	29 c2                	sub    %eax,%edx
  80043c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043f:	eb a8                	jmp    8003e9 <vprintfmt+0x17f>
					putch(ch, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	52                   	push   %edx
  800446:	ff d6                	call   *%esi
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800450:	83 c7 01             	add    $0x1,%edi
  800453:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800457:	0f be d0             	movsbl %al,%edx
  80045a:	85 d2                	test   %edx,%edx
  80045c:	74 4b                	je     8004a9 <vprintfmt+0x23f>
  80045e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800462:	78 06                	js     80046a <vprintfmt+0x200>
  800464:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800468:	78 1e                	js     800488 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80046a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046e:	74 d1                	je     800441 <vprintfmt+0x1d7>
  800470:	0f be c0             	movsbl %al,%eax
  800473:	83 e8 20             	sub    $0x20,%eax
  800476:	83 f8 5e             	cmp    $0x5e,%eax
  800479:	76 c6                	jbe    800441 <vprintfmt+0x1d7>
					putch('?', putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	53                   	push   %ebx
  80047f:	6a 3f                	push   $0x3f
  800481:	ff d6                	call   *%esi
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	eb c3                	jmp    80044b <vprintfmt+0x1e1>
  800488:	89 cf                	mov    %ecx,%edi
  80048a:	eb 0e                	jmp    80049a <vprintfmt+0x230>
				putch(' ', putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	53                   	push   %ebx
  800490:	6a 20                	push   $0x20
  800492:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ee                	jg     80048c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a4:	e9 67 01 00 00       	jmp    800610 <vprintfmt+0x3a6>
  8004a9:	89 cf                	mov    %ecx,%edi
  8004ab:	eb ed                	jmp    80049a <vprintfmt+0x230>
	if (lflag >= 2)
  8004ad:	83 f9 01             	cmp    $0x1,%ecx
  8004b0:	7f 1b                	jg     8004cd <vprintfmt+0x263>
	else if (lflag)
  8004b2:	85 c9                	test   %ecx,%ecx
  8004b4:	74 63                	je     800519 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004be:	99                   	cltd   
  8004bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 40 04             	lea    0x4(%eax),%eax
  8004c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cb:	eb 17                	jmp    8004e4 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8b 50 04             	mov    0x4(%eax),%edx
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 40 08             	lea    0x8(%eax),%eax
  8004e1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004ef:	85 c9                	test   %ecx,%ecx
  8004f1:	0f 89 ff 00 00 00    	jns    8005f6 <vprintfmt+0x38c>
				putch('-', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	6a 2d                	push   $0x2d
  8004fd:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800502:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800505:	f7 da                	neg    %edx
  800507:	83 d1 00             	adc    $0x0,%ecx
  80050a:	f7 d9                	neg    %ecx
  80050c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800514:	e9 dd 00 00 00       	jmp    8005f6 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800521:	99                   	cltd   
  800522:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 40 04             	lea    0x4(%eax),%eax
  80052b:	89 45 14             	mov    %eax,0x14(%ebp)
  80052e:	eb b4                	jmp    8004e4 <vprintfmt+0x27a>
	if (lflag >= 2)
  800530:	83 f9 01             	cmp    $0x1,%ecx
  800533:	7f 1e                	jg     800553 <vprintfmt+0x2e9>
	else if (lflag)
  800535:	85 c9                	test   %ecx,%ecx
  800537:	74 32                	je     80056b <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8b 10                	mov    (%eax),%edx
  80053e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800543:	8d 40 04             	lea    0x4(%eax),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800549:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80054e:	e9 a3 00 00 00       	jmp    8005f6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8b 10                	mov    (%eax),%edx
  800558:	8b 48 04             	mov    0x4(%eax),%ecx
  80055b:	8d 40 08             	lea    0x8(%eax),%eax
  80055e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800561:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800566:	e9 8b 00 00 00       	jmp    8005f6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8b 10                	mov    (%eax),%edx
  800570:	b9 00 00 00 00       	mov    $0x0,%ecx
  800575:	8d 40 04             	lea    0x4(%eax),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800580:	eb 74                	jmp    8005f6 <vprintfmt+0x38c>
	if (lflag >= 2)
  800582:	83 f9 01             	cmp    $0x1,%ecx
  800585:	7f 1b                	jg     8005a2 <vprintfmt+0x338>
	else if (lflag)
  800587:	85 c9                	test   %ecx,%ecx
  800589:	74 2c                	je     8005b7 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8b 10                	mov    (%eax),%edx
  800590:	b9 00 00 00 00       	mov    $0x0,%ecx
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80059b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005a0:	eb 54                	jmp    8005f6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	8b 48 04             	mov    0x4(%eax),%ecx
  8005aa:	8d 40 08             	lea    0x8(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005b0:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005b5:	eb 3f                	jmp    8005f6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 10                	mov    (%eax),%edx
  8005bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005c7:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005cc:	eb 28                	jmp    8005f6 <vprintfmt+0x38c>
			putch('0', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	6a 30                	push   $0x30
  8005d4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 78                	push   $0x78
  8005dc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005f1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f6:	83 ec 0c             	sub    $0xc,%esp
  8005f9:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005fd:	57                   	push   %edi
  8005fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800601:	50                   	push   %eax
  800602:	51                   	push   %ecx
  800603:	52                   	push   %edx
  800604:	89 da                	mov    %ebx,%edx
  800606:	89 f0                	mov    %esi,%eax
  800608:	e8 72 fb ff ff       	call   80017f <printnum>
			break;
  80060d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800613:	83 c7 01             	add    $0x1,%edi
  800616:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061a:	83 f8 25             	cmp    $0x25,%eax
  80061d:	0f 84 62 fc ff ff    	je     800285 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800623:	85 c0                	test   %eax,%eax
  800625:	0f 84 8b 00 00 00    	je     8006b6 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	50                   	push   %eax
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb dc                	jmp    800613 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800637:	83 f9 01             	cmp    $0x1,%ecx
  80063a:	7f 1b                	jg     800657 <vprintfmt+0x3ed>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 2c                	je     80066c <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800650:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800655:	eb 9f                	jmp    8005f6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	8b 48 04             	mov    0x4(%eax),%ecx
  80065f:	8d 40 08             	lea    0x8(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800665:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80066a:	eb 8a                	jmp    8005f6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800681:	e9 70 ff ff ff       	jmp    8005f6 <vprintfmt+0x38c>
			putch(ch, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 25                	push   $0x25
  80068c:	ff d6                	call   *%esi
			break;
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	e9 7a ff ff ff       	jmp    800610 <vprintfmt+0x3a6>
			putch('%', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 25                	push   $0x25
  80069c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	89 f8                	mov    %edi,%eax
  8006a3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a7:	74 05                	je     8006ae <vprintfmt+0x444>
  8006a9:	83 e8 01             	sub    $0x1,%eax
  8006ac:	eb f5                	jmp    8006a3 <vprintfmt+0x439>
  8006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b1:	e9 5a ff ff ff       	jmp    800610 <vprintfmt+0x3a6>
}
  8006b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b9:	5b                   	pop    %ebx
  8006ba:	5e                   	pop    %esi
  8006bb:	5f                   	pop    %edi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006be:	f3 0f 1e fb          	endbr32 
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 18             	sub    $0x18,%esp
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006df:	85 c0                	test   %eax,%eax
  8006e1:	74 26                	je     800709 <vsnprintf+0x4b>
  8006e3:	85 d2                	test   %edx,%edx
  8006e5:	7e 22                	jle    800709 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e7:	ff 75 14             	pushl  0x14(%ebp)
  8006ea:	ff 75 10             	pushl  0x10(%ebp)
  8006ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	68 28 02 80 00       	push   $0x800228
  8006f6:	e8 6f fb ff ff       	call   80026a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800701:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800704:	83 c4 10             	add    $0x10,%esp
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    
		return -E_INVAL;
  800709:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070e:	eb f7                	jmp    800707 <vsnprintf+0x49>

00800710 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800710:	f3 0f 1e fb          	endbr32 
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071d:	50                   	push   %eax
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	ff 75 0c             	pushl  0xc(%ebp)
  800724:	ff 75 08             	pushl  0x8(%ebp)
  800727:	e8 92 ff ff ff       	call   8006be <vsnprintf>
	va_end(ap);

	return rc;
}
  80072c:	c9                   	leave  
  80072d:	c3                   	ret    

0080072e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072e:	f3 0f 1e fb          	endbr32 
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
  80073d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800741:	74 05                	je     800748 <strlen+0x1a>
		n++;
  800743:	83 c0 01             	add    $0x1,%eax
  800746:	eb f5                	jmp    80073d <strlen+0xf>
	return n;
}
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074a:	f3 0f 1e fb          	endbr32 
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	39 d0                	cmp    %edx,%eax
  80075e:	74 0d                	je     80076d <strnlen+0x23>
  800760:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800764:	74 05                	je     80076b <strnlen+0x21>
		n++;
  800766:	83 c0 01             	add    $0x1,%eax
  800769:	eb f1                	jmp    80075c <strnlen+0x12>
  80076b:	89 c2                	mov    %eax,%edx
	return n;
}
  80076d:	89 d0                	mov    %edx,%eax
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800771:	f3 0f 1e fb          	endbr32 
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
  800784:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800788:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80078b:	83 c0 01             	add    $0x1,%eax
  80078e:	84 d2                	test   %dl,%dl
  800790:	75 f2                	jne    800784 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800792:	89 c8                	mov    %ecx,%eax
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	f3 0f 1e fb          	endbr32 
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	83 ec 10             	sub    $0x10,%esp
  8007a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a5:	53                   	push   %ebx
  8007a6:	e8 83 ff ff ff       	call   80072e <strlen>
  8007ab:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007ae:	ff 75 0c             	pushl  0xc(%ebp)
  8007b1:	01 d8                	add    %ebx,%eax
  8007b3:	50                   	push   %eax
  8007b4:	e8 b8 ff ff ff       	call   800771 <strcpy>
	return dst;
}
  8007b9:	89 d8                	mov    %ebx,%eax
  8007bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c0:	f3 0f 1e fb          	endbr32 
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cf:	89 f3                	mov    %esi,%ebx
  8007d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	89 f0                	mov    %esi,%eax
  8007d6:	39 d8                	cmp    %ebx,%eax
  8007d8:	74 11                	je     8007eb <strncpy+0x2b>
		*dst++ = *src;
  8007da:	83 c0 01             	add    $0x1,%eax
  8007dd:	0f b6 0a             	movzbl (%edx),%ecx
  8007e0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e3:	80 f9 01             	cmp    $0x1,%cl
  8007e6:	83 da ff             	sbb    $0xffffffff,%edx
  8007e9:	eb eb                	jmp    8007d6 <strncpy+0x16>
	}
	return ret;
}
  8007eb:	89 f0                	mov    %esi,%eax
  8007ed:	5b                   	pop    %ebx
  8007ee:	5e                   	pop    %esi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f1:	f3 0f 1e fb          	endbr32 
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800800:	8b 55 10             	mov    0x10(%ebp),%edx
  800803:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800805:	85 d2                	test   %edx,%edx
  800807:	74 21                	je     80082a <strlcpy+0x39>
  800809:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80080f:	39 c2                	cmp    %eax,%edx
  800811:	74 14                	je     800827 <strlcpy+0x36>
  800813:	0f b6 19             	movzbl (%ecx),%ebx
  800816:	84 db                	test   %bl,%bl
  800818:	74 0b                	je     800825 <strlcpy+0x34>
			*dst++ = *src++;
  80081a:	83 c1 01             	add    $0x1,%ecx
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	88 5a ff             	mov    %bl,-0x1(%edx)
  800823:	eb ea                	jmp    80080f <strlcpy+0x1e>
  800825:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800827:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082a:	29 f0                	sub    %esi,%eax
}
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800830:	f3 0f 1e fb          	endbr32 
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	84 c0                	test   %al,%al
  800842:	74 0c                	je     800850 <strcmp+0x20>
  800844:	3a 02                	cmp    (%edx),%al
  800846:	75 08                	jne    800850 <strcmp+0x20>
		p++, q++;
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	eb ed                	jmp    80083d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800850:	0f b6 c0             	movzbl %al,%eax
  800853:	0f b6 12             	movzbl (%edx),%edx
  800856:	29 d0                	sub    %edx,%eax
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085a:	f3 0f 1e fb          	endbr32 
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
  800868:	89 c3                	mov    %eax,%ebx
  80086a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086d:	eb 06                	jmp    800875 <strncmp+0x1b>
		n--, p++, q++;
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800875:	39 d8                	cmp    %ebx,%eax
  800877:	74 16                	je     80088f <strncmp+0x35>
  800879:	0f b6 08             	movzbl (%eax),%ecx
  80087c:	84 c9                	test   %cl,%cl
  80087e:	74 04                	je     800884 <strncmp+0x2a>
  800880:	3a 0a                	cmp    (%edx),%cl
  800882:	74 eb                	je     80086f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800884:	0f b6 00             	movzbl (%eax),%eax
  800887:	0f b6 12             	movzbl (%edx),%edx
  80088a:	29 d0                	sub    %edx,%eax
}
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    
		return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
  800894:	eb f6                	jmp    80088c <strncmp+0x32>

00800896 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a4:	0f b6 10             	movzbl (%eax),%edx
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	74 09                	je     8008b4 <strchr+0x1e>
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	74 0a                	je     8008b9 <strchr+0x23>
	for (; *s; s++)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	eb f0                	jmp    8008a4 <strchr+0xe>
			return (char *) s;
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8008bb:	f3 0f 1e fb          	endbr32 
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8008c5:	6a 78                	push   $0x78
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 c7 ff ff ff       	call   800896 <strchr>
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8008da:	eb 0d                	jmp    8008e9 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8008dc:	c1 e0 04             	shl    $0x4,%eax
  8008df:	0f be d2             	movsbl %dl,%edx
  8008e2:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8008e6:	83 c1 01             	add    $0x1,%ecx
  8008e9:	0f b6 11             	movzbl (%ecx),%edx
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 11                	je     800901 <atox+0x46>
		if (*p>='a'){
  8008f0:	80 fa 60             	cmp    $0x60,%dl
  8008f3:	7e e7                	jle    8008dc <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8008f5:	c1 e0 04             	shl    $0x4,%eax
  8008f8:	0f be d2             	movsbl %dl,%edx
  8008fb:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8008ff:	eb e5                	jmp    8008e6 <atox+0x2b>
	}

	return v;

}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800903:	f3 0f 1e fb          	endbr32 
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800911:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 09                	je     800921 <strfind+0x1e>
  800918:	84 d2                	test   %dl,%dl
  80091a:	74 05                	je     800921 <strfind+0x1e>
	for (; *s; s++)
  80091c:	83 c0 01             	add    $0x1,%eax
  80091f:	eb f0                	jmp    800911 <strfind+0xe>
			break;
	return (char *) s;
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800923:	f3 0f 1e fb          	endbr32 
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800933:	85 c9                	test   %ecx,%ecx
  800935:	74 31                	je     800968 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800937:	89 f8                	mov    %edi,%eax
  800939:	09 c8                	or     %ecx,%eax
  80093b:	a8 03                	test   $0x3,%al
  80093d:	75 23                	jne    800962 <memset+0x3f>
		c &= 0xFF;
  80093f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800943:	89 d3                	mov    %edx,%ebx
  800945:	c1 e3 08             	shl    $0x8,%ebx
  800948:	89 d0                	mov    %edx,%eax
  80094a:	c1 e0 18             	shl    $0x18,%eax
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 10             	shl    $0x10,%esi
  800952:	09 f0                	or     %esi,%eax
  800954:	09 c2                	or     %eax,%edx
  800956:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800958:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095b:	89 d0                	mov    %edx,%eax
  80095d:	fc                   	cld    
  80095e:	f3 ab                	rep stos %eax,%es:(%edi)
  800960:	eb 06                	jmp    800968 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	fc                   	cld    
  800966:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800968:	89 f8                	mov    %edi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096f:	f3 0f 1e fb          	endbr32 
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800981:	39 c6                	cmp    %eax,%esi
  800983:	73 32                	jae    8009b7 <memmove+0x48>
  800985:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800988:	39 c2                	cmp    %eax,%edx
  80098a:	76 2b                	jbe    8009b7 <memmove+0x48>
		s += n;
		d += n;
  80098c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 fe                	mov    %edi,%esi
  800991:	09 ce                	or     %ecx,%esi
  800993:	09 d6                	or     %edx,%esi
  800995:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099b:	75 0e                	jne    8009ab <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099d:	83 ef 04             	sub    $0x4,%edi
  8009a0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a6:	fd                   	std    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 09                	jmp    8009b4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ab:	83 ef 01             	sub    $0x1,%edi
  8009ae:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b1:	fd                   	std    
  8009b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b4:	fc                   	cld    
  8009b5:	eb 1a                	jmp    8009d1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b7:	89 c2                	mov    %eax,%edx
  8009b9:	09 ca                	or     %ecx,%edx
  8009bb:	09 f2                	or     %esi,%edx
  8009bd:	f6 c2 03             	test   $0x3,%dl
  8009c0:	75 0a                	jne    8009cc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 05                	jmp    8009d1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009cc:	89 c7                	mov    %eax,%edi
  8009ce:	fc                   	cld    
  8009cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d5:	f3 0f 1e fb          	endbr32 
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009df:	ff 75 10             	pushl  0x10(%ebp)
  8009e2:	ff 75 0c             	pushl  0xc(%ebp)
  8009e5:	ff 75 08             	pushl  0x8(%ebp)
  8009e8:	e8 82 ff ff ff       	call   80096f <memmove>
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ef:	f3 0f 1e fb          	endbr32 
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fe:	89 c6                	mov    %eax,%esi
  800a00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a03:	39 f0                	cmp    %esi,%eax
  800a05:	74 1c                	je     800a23 <memcmp+0x34>
		if (*s1 != *s2)
  800a07:	0f b6 08             	movzbl (%eax),%ecx
  800a0a:	0f b6 1a             	movzbl (%edx),%ebx
  800a0d:	38 d9                	cmp    %bl,%cl
  800a0f:	75 08                	jne    800a19 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a11:	83 c0 01             	add    $0x1,%eax
  800a14:	83 c2 01             	add    $0x1,%edx
  800a17:	eb ea                	jmp    800a03 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a19:	0f b6 c1             	movzbl %cl,%eax
  800a1c:	0f b6 db             	movzbl %bl,%ebx
  800a1f:	29 d8                	sub    %ebx,%eax
  800a21:	eb 05                	jmp    800a28 <memcmp+0x39>
	}

	return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a39:	89 c2                	mov    %eax,%edx
  800a3b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3e:	39 d0                	cmp    %edx,%eax
  800a40:	73 09                	jae    800a4b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a42:	38 08                	cmp    %cl,(%eax)
  800a44:	74 05                	je     800a4b <memfind+0x1f>
	for (; s < ends; s++)
  800a46:	83 c0 01             	add    $0x1,%eax
  800a49:	eb f3                	jmp    800a3e <memfind+0x12>
			break;
	return (void *) s;
}
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4d:	f3 0f 1e fb          	endbr32 
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5d:	eb 03                	jmp    800a62 <strtol+0x15>
		s++;
  800a5f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a62:	0f b6 01             	movzbl (%ecx),%eax
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f6                	je     800a5f <strtol+0x12>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f2                	je     800a5f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	74 2a                	je     800a9b <strtol+0x4e>
	int neg = 0;
  800a71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a76:	3c 2d                	cmp    $0x2d,%al
  800a78:	74 2b                	je     800aa5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a80:	75 0f                	jne    800a91 <strtol+0x44>
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	74 28                	je     800aaf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a87:	85 db                	test   %ebx,%ebx
  800a89:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a8e:	0f 44 d8             	cmove  %eax,%ebx
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a99:	eb 46                	jmp    800ae1 <strtol+0x94>
		s++;
  800a9b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa3:	eb d5                	jmp    800a7a <strtol+0x2d>
		s++, neg = 1;
  800aa5:	83 c1 01             	add    $0x1,%ecx
  800aa8:	bf 01 00 00 00       	mov    $0x1,%edi
  800aad:	eb cb                	jmp    800a7a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aaf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab3:	74 0e                	je     800ac3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab5:	85 db                	test   %ebx,%ebx
  800ab7:	75 d8                	jne    800a91 <strtol+0x44>
		s++, base = 8;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac1:	eb ce                	jmp    800a91 <strtol+0x44>
		s += 2, base = 16;
  800ac3:	83 c1 02             	add    $0x2,%ecx
  800ac6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acb:	eb c4                	jmp    800a91 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad6:	7d 3a                	jge    800b12 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ae1:	0f b6 11             	movzbl (%ecx),%edx
  800ae4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 09             	cmp    $0x9,%bl
  800aec:	76 df                	jbe    800acd <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 08                	ja     800b00 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 57             	sub    $0x57,%edx
  800afe:	eb d3                	jmp    800ad3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b03:	89 f3                	mov    %esi,%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 08                	ja     800b12 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0a:	0f be d2             	movsbl %dl,%edx
  800b0d:	83 ea 37             	sub    $0x37,%edx
  800b10:	eb c1                	jmp    800ad3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b16:	74 05                	je     800b1d <strtol+0xd0>
		*endptr = (char *) s;
  800b18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	f7 da                	neg    %edx
  800b21:	85 ff                	test   %edi,%edi
  800b23:	0f 45 c2             	cmovne %edx,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2b:	f3 0f 1e fb          	endbr32 
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	89 c7                	mov    %eax,%edi
  800b44:	89 c6                	mov    %eax,%esi
  800b46:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4d:	f3 0f 1e fb          	endbr32 
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b57:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b61:	89 d1                	mov    %edx,%ecx
  800b63:	89 d3                	mov    %edx,%ebx
  800b65:	89 d7                	mov    %edx,%edi
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b70:	f3 0f 1e fb          	endbr32 
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b94:	f3 0f 1e fb          	endbr32 
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba8:	89 d1                	mov    %edx,%ecx
  800baa:	89 d3                	mov    %edx,%ebx
  800bac:	89 d7                	mov    %edx,%edi
  800bae:	89 d6                	mov    %edx,%esi
  800bb0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_yield>:

void
sys_yield(void)
{
  800bb7:	f3 0f 1e fb          	endbr32 
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bda:	f3 0f 1e fb          	endbr32 
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be4:	be 00 00 00 00       	mov    $0x0,%esi
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	89 f7                	mov    %esi,%edi
  800bf9:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	b8 05 00 00 00       	mov    $0x5,%eax
  800c15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1e:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c25:	f3 0f 1e fb          	endbr32 
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3f:	89 df                	mov    %ebx,%edi
  800c41:	89 de                	mov    %ebx,%esi
  800c43:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4a:	f3 0f 1e fb          	endbr32 
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6f:	f3 0f 1e fb          	endbr32 
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	b8 09 00 00 00       	mov    $0x9,%eax
  800c89:	89 df                	mov    %ebx,%edi
  800c8b:	89 de                	mov    %ebx,%esi
  800c8d:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c94:	f3 0f 1e fb          	endbr32 
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb9:	f3 0f 1e fb          	endbr32 
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	f3 0f 1e fb          	endbr32 
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf7:	89 cb                	mov    %ecx,%ebx
  800cf9:	89 cf                	mov    %ecx,%edi
  800cfb:	89 ce                	mov    %ecx,%esi
  800cfd:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d04:	f3 0f 1e fb          	endbr32 
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d13:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d18:	89 d1                	mov    %edx,%ecx
  800d1a:	89 d3                	mov    %edx,%ebx
  800d1c:	89 d7                	mov    %edx,%edi
  800d1e:	89 d6                	mov    %edx,%esi
  800d20:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d27:	f3 0f 1e fb          	endbr32 
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d41:	89 df                	mov    %ebx,%edi
  800d43:	89 de                	mov    %ebx,%esi
  800d45:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800d4c:	f3 0f 1e fb          	endbr32 
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	b8 10 00 00 00       	mov    $0x10,%eax
  800d66:	89 df                	mov    %ebx,%edi
  800d68:	89 de                	mov    %ebx,%esi
  800d6a:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d71:	f3 0f 1e fb          	endbr32 
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d80:	c1 e8 0c             	shr    $0xc,%eax
}
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d85:	f3 0f 1e fb          	endbr32 
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8f:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d99:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	c1 ea 16             	shr    $0x16,%edx
  800db1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db8:	f6 c2 01             	test   $0x1,%dl
  800dbb:	74 2d                	je     800dea <fd_alloc+0x4a>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	c1 ea 0c             	shr    $0xc,%edx
  800dc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc9:	f6 c2 01             	test   $0x1,%dl
  800dcc:	74 1c                	je     800dea <fd_alloc+0x4a>
  800dce:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800dd3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd8:	75 d2                	jne    800dac <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800de3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800de8:	eb 0a                	jmp    800df4 <fd_alloc+0x54>
			*fd_store = fd;
  800dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ded:	89 01                	mov    %eax,(%ecx)
			return 0;
  800def:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800df6:	f3 0f 1e fb          	endbr32 
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e00:	83 f8 1f             	cmp    $0x1f,%eax
  800e03:	77 30                	ja     800e35 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e05:	c1 e0 0c             	shl    $0xc,%eax
  800e08:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e0d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e13:	f6 c2 01             	test   $0x1,%dl
  800e16:	74 24                	je     800e3c <fd_lookup+0x46>
  800e18:	89 c2                	mov    %eax,%edx
  800e1a:	c1 ea 0c             	shr    $0xc,%edx
  800e1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e24:	f6 c2 01             	test   $0x1,%dl
  800e27:	74 1a                	je     800e43 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2c:	89 02                	mov    %eax,(%edx)
	return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
		return -E_INVAL;
  800e35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3a:	eb f7                	jmp    800e33 <fd_lookup+0x3d>
		return -E_INVAL;
  800e3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e41:	eb f0                	jmp    800e33 <fd_lookup+0x3d>
  800e43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e48:	eb e9                	jmp    800e33 <fd_lookup+0x3d>

00800e4a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e4a:	f3 0f 1e fb          	endbr32 
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e57:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5c:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e61:	39 08                	cmp    %ecx,(%eax)
  800e63:	74 38                	je     800e9d <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800e65:	83 c2 01             	add    $0x1,%edx
  800e68:	8b 04 95 3c 27 80 00 	mov    0x80273c(,%edx,4),%eax
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	75 ee                	jne    800e61 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e73:	a1 08 40 80 00       	mov    0x804008,%eax
  800e78:	8b 40 48             	mov    0x48(%eax),%eax
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	51                   	push   %ecx
  800e7f:	50                   	push   %eax
  800e80:	68 c0 26 80 00       	push   $0x8026c0
  800e85:	e8 dd f2 ff ff       	call   800167 <cprintf>
	*dev = 0;
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    
			*dev = devtab[i];
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb f2                	jmp    800e9b <dev_lookup+0x51>

00800ea9 <fd_close>:
{
  800ea9:	f3 0f 1e fb          	endbr32 
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 24             	sub    $0x24,%esp
  800eb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ebc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ebf:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ec6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec9:	50                   	push   %eax
  800eca:	e8 27 ff ff ff       	call   800df6 <fd_lookup>
  800ecf:	89 c3                	mov    %eax,%ebx
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	78 05                	js     800edd <fd_close+0x34>
	    || fd != fd2)
  800ed8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800edb:	74 16                	je     800ef3 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800edd:	89 f8                	mov    %edi,%eax
  800edf:	84 c0                	test   %al,%al
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	0f 44 d8             	cmove  %eax,%ebx
}
  800ee9:	89 d8                	mov    %ebx,%eax
  800eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ef9:	50                   	push   %eax
  800efa:	ff 36                	pushl  (%esi)
  800efc:	e8 49 ff ff ff       	call   800e4a <dev_lookup>
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	78 1a                	js     800f24 <fd_close+0x7b>
		if (dev->dev_close)
  800f0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f0d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f10:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	74 0b                	je     800f24 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f19:	83 ec 0c             	sub    $0xc,%esp
  800f1c:	56                   	push   %esi
  800f1d:	ff d0                	call   *%eax
  800f1f:	89 c3                	mov    %eax,%ebx
  800f21:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f24:	83 ec 08             	sub    $0x8,%esp
  800f27:	56                   	push   %esi
  800f28:	6a 00                	push   $0x0
  800f2a:	e8 f6 fc ff ff       	call   800c25 <sys_page_unmap>
	return r;
  800f2f:	83 c4 10             	add    $0x10,%esp
  800f32:	eb b5                	jmp    800ee9 <fd_close+0x40>

00800f34 <close>:

int
close(int fdnum)
{
  800f34:	f3 0f 1e fb          	endbr32 
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	ff 75 08             	pushl  0x8(%ebp)
  800f45:	e8 ac fe ff ff       	call   800df6 <fd_lookup>
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 02                	jns    800f53 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    
		return fd_close(fd, 1);
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	6a 01                	push   $0x1
  800f58:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5b:	e8 49 ff ff ff       	call   800ea9 <fd_close>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	eb ec                	jmp    800f51 <close+0x1d>

00800f65 <close_all>:

void
close_all(void)
{
  800f65:	f3 0f 1e fb          	endbr32 
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f70:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	53                   	push   %ebx
  800f79:	e8 b6 ff ff ff       	call   800f34 <close>
	for (i = 0; i < MAXFD; i++)
  800f7e:	83 c3 01             	add    $0x1,%ebx
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	83 fb 20             	cmp    $0x20,%ebx
  800f87:	75 ec                	jne    800f75 <close_all+0x10>
}
  800f89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f8e:	f3 0f 1e fb          	endbr32 
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	53                   	push   %ebx
  800f98:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f9b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	ff 75 08             	pushl  0x8(%ebp)
  800fa2:	e8 4f fe ff ff       	call   800df6 <fd_lookup>
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	0f 88 81 00 00 00    	js     801035 <dup+0xa7>
		return r;
	close(newfdnum);
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	ff 75 0c             	pushl  0xc(%ebp)
  800fba:	e8 75 ff ff ff       	call   800f34 <close>

	newfd = INDEX2FD(newfdnum);
  800fbf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc2:	c1 e6 0c             	shl    $0xc,%esi
  800fc5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fcb:	83 c4 04             	add    $0x4,%esp
  800fce:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd1:	e8 af fd ff ff       	call   800d85 <fd2data>
  800fd6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fd8:	89 34 24             	mov    %esi,(%esp)
  800fdb:	e8 a5 fd ff ff       	call   800d85 <fd2data>
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fe5:	89 d8                	mov    %ebx,%eax
  800fe7:	c1 e8 16             	shr    $0x16,%eax
  800fea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff1:	a8 01                	test   $0x1,%al
  800ff3:	74 11                	je     801006 <dup+0x78>
  800ff5:	89 d8                	mov    %ebx,%eax
  800ff7:	c1 e8 0c             	shr    $0xc,%eax
  800ffa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801001:	f6 c2 01             	test   $0x1,%dl
  801004:	75 39                	jne    80103f <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801006:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801009:	89 d0                	mov    %edx,%eax
  80100b:	c1 e8 0c             	shr    $0xc,%eax
  80100e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	25 07 0e 00 00       	and    $0xe07,%eax
  80101d:	50                   	push   %eax
  80101e:	56                   	push   %esi
  80101f:	6a 00                	push   $0x0
  801021:	52                   	push   %edx
  801022:	6a 00                	push   $0x0
  801024:	e8 d7 fb ff ff       	call   800c00 <sys_page_map>
  801029:	89 c3                	mov    %eax,%ebx
  80102b:	83 c4 20             	add    $0x20,%esp
  80102e:	85 c0                	test   %eax,%eax
  801030:	78 31                	js     801063 <dup+0xd5>
		goto err;

	return newfdnum;
  801032:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801035:	89 d8                	mov    %ebx,%eax
  801037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80103f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	25 07 0e 00 00       	and    $0xe07,%eax
  80104e:	50                   	push   %eax
  80104f:	57                   	push   %edi
  801050:	6a 00                	push   $0x0
  801052:	53                   	push   %ebx
  801053:	6a 00                	push   $0x0
  801055:	e8 a6 fb ff ff       	call   800c00 <sys_page_map>
  80105a:	89 c3                	mov    %eax,%ebx
  80105c:	83 c4 20             	add    $0x20,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 a3                	jns    801006 <dup+0x78>
	sys_page_unmap(0, newfd);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	56                   	push   %esi
  801067:	6a 00                	push   $0x0
  801069:	e8 b7 fb ff ff       	call   800c25 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	57                   	push   %edi
  801072:	6a 00                	push   $0x0
  801074:	e8 ac fb ff ff       	call   800c25 <sys_page_unmap>
	return r;
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	eb b7                	jmp    801035 <dup+0xa7>

0080107e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80107e:	f3 0f 1e fb          	endbr32 
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	53                   	push   %ebx
  801086:	83 ec 1c             	sub    $0x1c,%esp
  801089:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80108c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80108f:	50                   	push   %eax
  801090:	53                   	push   %ebx
  801091:	e8 60 fd ff ff       	call   800df6 <fd_lookup>
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 3f                	js     8010dc <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a3:	50                   	push   %eax
  8010a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a7:	ff 30                	pushl  (%eax)
  8010a9:	e8 9c fd ff ff       	call   800e4a <dev_lookup>
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	78 27                	js     8010dc <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010b8:	8b 42 08             	mov    0x8(%edx),%eax
  8010bb:	83 e0 03             	and    $0x3,%eax
  8010be:	83 f8 01             	cmp    $0x1,%eax
  8010c1:	74 1e                	je     8010e1 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c6:	8b 40 08             	mov    0x8(%eax),%eax
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	74 35                	je     801102 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	ff 75 10             	pushl  0x10(%ebp)
  8010d3:	ff 75 0c             	pushl  0xc(%ebp)
  8010d6:	52                   	push   %edx
  8010d7:	ff d0                	call   *%eax
  8010d9:	83 c4 10             	add    $0x10,%esp
}
  8010dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e6:	8b 40 48             	mov    0x48(%eax),%eax
  8010e9:	83 ec 04             	sub    $0x4,%esp
  8010ec:	53                   	push   %ebx
  8010ed:	50                   	push   %eax
  8010ee:	68 01 27 80 00       	push   $0x802701
  8010f3:	e8 6f f0 ff ff       	call   800167 <cprintf>
		return -E_INVAL;
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801100:	eb da                	jmp    8010dc <read+0x5e>
		return -E_NOT_SUPP;
  801102:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801107:	eb d3                	jmp    8010dc <read+0x5e>

00801109 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801109:	f3 0f 1e fb          	endbr32 
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	8b 7d 08             	mov    0x8(%ebp),%edi
  801119:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80111c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801121:	eb 02                	jmp    801125 <readn+0x1c>
  801123:	01 c3                	add    %eax,%ebx
  801125:	39 f3                	cmp    %esi,%ebx
  801127:	73 21                	jae    80114a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801129:	83 ec 04             	sub    $0x4,%esp
  80112c:	89 f0                	mov    %esi,%eax
  80112e:	29 d8                	sub    %ebx,%eax
  801130:	50                   	push   %eax
  801131:	89 d8                	mov    %ebx,%eax
  801133:	03 45 0c             	add    0xc(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	57                   	push   %edi
  801138:	e8 41 ff ff ff       	call   80107e <read>
		if (m < 0)
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	78 04                	js     801148 <readn+0x3f>
			return m;
		if (m == 0)
  801144:	75 dd                	jne    801123 <readn+0x1a>
  801146:	eb 02                	jmp    80114a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801148:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80114a:	89 d8                	mov    %ebx,%eax
  80114c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801154:	f3 0f 1e fb          	endbr32 
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	53                   	push   %ebx
  80115c:	83 ec 1c             	sub    $0x1c,%esp
  80115f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801162:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801165:	50                   	push   %eax
  801166:	53                   	push   %ebx
  801167:	e8 8a fc ff ff       	call   800df6 <fd_lookup>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 3a                	js     8011ad <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801173:	83 ec 08             	sub    $0x8,%esp
  801176:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801179:	50                   	push   %eax
  80117a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117d:	ff 30                	pushl  (%eax)
  80117f:	e8 c6 fc ff ff       	call   800e4a <dev_lookup>
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	78 22                	js     8011ad <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80118b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801192:	74 1e                	je     8011b2 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801194:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801197:	8b 52 0c             	mov    0xc(%edx),%edx
  80119a:	85 d2                	test   %edx,%edx
  80119c:	74 35                	je     8011d3 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	ff 75 10             	pushl  0x10(%ebp)
  8011a4:	ff 75 0c             	pushl  0xc(%ebp)
  8011a7:	50                   	push   %eax
  8011a8:	ff d2                	call   *%edx
  8011aa:	83 c4 10             	add    $0x10,%esp
}
  8011ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	53                   	push   %ebx
  8011be:	50                   	push   %eax
  8011bf:	68 1d 27 80 00       	push   $0x80271d
  8011c4:	e8 9e ef ff ff       	call   800167 <cprintf>
		return -E_INVAL;
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d1:	eb da                	jmp    8011ad <write+0x59>
		return -E_NOT_SUPP;
  8011d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011d8:	eb d3                	jmp    8011ad <write+0x59>

008011da <seek>:

int
seek(int fdnum, off_t offset)
{
  8011da:	f3 0f 1e fb          	endbr32 
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	ff 75 08             	pushl  0x8(%ebp)
  8011eb:	e8 06 fc ff ff       	call   800df6 <fd_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 0e                	js     801205 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8011f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801200:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801207:	f3 0f 1e fb          	endbr32 
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	53                   	push   %ebx
  80120f:	83 ec 1c             	sub    $0x1c,%esp
  801212:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801215:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	53                   	push   %ebx
  80121a:	e8 d7 fb ff ff       	call   800df6 <fd_lookup>
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 37                	js     80125d <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801230:	ff 30                	pushl  (%eax)
  801232:	e8 13 fc ff ff       	call   800e4a <dev_lookup>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 1f                	js     80125d <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801245:	74 1b                	je     801262 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801247:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124a:	8b 52 18             	mov    0x18(%edx),%edx
  80124d:	85 d2                	test   %edx,%edx
  80124f:	74 32                	je     801283 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	ff 75 0c             	pushl  0xc(%ebp)
  801257:	50                   	push   %eax
  801258:	ff d2                	call   *%edx
  80125a:	83 c4 10             	add    $0x10,%esp
}
  80125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801260:	c9                   	leave  
  801261:	c3                   	ret    
			thisenv->env_id, fdnum);
  801262:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801267:	8b 40 48             	mov    0x48(%eax),%eax
  80126a:	83 ec 04             	sub    $0x4,%esp
  80126d:	53                   	push   %ebx
  80126e:	50                   	push   %eax
  80126f:	68 e0 26 80 00       	push   $0x8026e0
  801274:	e8 ee ee ff ff       	call   800167 <cprintf>
		return -E_INVAL;
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801281:	eb da                	jmp    80125d <ftruncate+0x56>
		return -E_NOT_SUPP;
  801283:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801288:	eb d3                	jmp    80125d <ftruncate+0x56>

0080128a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80128a:	f3 0f 1e fb          	endbr32 
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	53                   	push   %ebx
  801292:	83 ec 1c             	sub    $0x1c,%esp
  801295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801298:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	ff 75 08             	pushl  0x8(%ebp)
  80129f:	e8 52 fb ff ff       	call   800df6 <fd_lookup>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 4b                	js     8012f6 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b5:	ff 30                	pushl  (%eax)
  8012b7:	e8 8e fb ff ff       	call   800e4a <dev_lookup>
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 33                	js     8012f6 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8012c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ca:	74 2f                	je     8012fb <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012d6:	00 00 00 
	stat->st_isdir = 0;
  8012d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012e0:	00 00 00 
	stat->st_dev = dev;
  8012e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	53                   	push   %ebx
  8012ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f0:	ff 50 14             	call   *0x14(%eax)
  8012f3:	83 c4 10             	add    $0x10,%esp
}
  8012f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    
		return -E_NOT_SUPP;
  8012fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801300:	eb f4                	jmp    8012f6 <fstat+0x6c>

00801302 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801302:	f3 0f 1e fb          	endbr32 
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	6a 00                	push   $0x0
  801310:	ff 75 08             	pushl  0x8(%ebp)
  801313:	e8 01 02 00 00       	call   801519 <open>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 1b                	js     80133c <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	ff 75 0c             	pushl  0xc(%ebp)
  801327:	50                   	push   %eax
  801328:	e8 5d ff ff ff       	call   80128a <fstat>
  80132d:	89 c6                	mov    %eax,%esi
	close(fd);
  80132f:	89 1c 24             	mov    %ebx,(%esp)
  801332:	e8 fd fb ff ff       	call   800f34 <close>
	return r;
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	89 f3                	mov    %esi,%ebx
}
  80133c:	89 d8                	mov    %ebx,%eax
  80133e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	56                   	push   %esi
  801349:	53                   	push   %ebx
  80134a:	89 c6                	mov    %eax,%esi
  80134c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80134e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801355:	74 27                	je     80137e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801357:	6a 07                	push   $0x7
  801359:	68 00 50 80 00       	push   $0x805000
  80135e:	56                   	push   %esi
  80135f:	ff 35 00 40 80 00    	pushl  0x804000
  801365:	e8 c6 0c 00 00       	call   802030 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136a:	83 c4 0c             	add    $0xc,%esp
  80136d:	6a 00                	push   $0x0
  80136f:	53                   	push   %ebx
  801370:	6a 00                	push   $0x0
  801372:	e8 4c 0c 00 00       	call   801fc3 <ipc_recv>
}
  801377:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137a:	5b                   	pop    %ebx
  80137b:	5e                   	pop    %esi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	6a 01                	push   $0x1
  801383:	e8 00 0d 00 00       	call   802088 <ipc_find_env>
  801388:	a3 00 40 80 00       	mov    %eax,0x804000
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	eb c5                	jmp    801357 <fsipc+0x12>

00801392 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801392:	f3 0f 1e fb          	endbr32 
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
  80139f:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013aa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013af:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b9:	e8 87 ff ff ff       	call   801345 <fsipc>
}
  8013be:	c9                   	leave  
  8013bf:	c3                   	ret    

008013c0 <devfile_flush>:
{
  8013c0:	f3 0f 1e fb          	endbr32 
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013da:	b8 06 00 00 00       	mov    $0x6,%eax
  8013df:	e8 61 ff ff ff       	call   801345 <fsipc>
}
  8013e4:	c9                   	leave  
  8013e5:	c3                   	ret    

008013e6 <devfile_stat>:
{
  8013e6:	f3 0f 1e fb          	endbr32 
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801404:	b8 05 00 00 00       	mov    $0x5,%eax
  801409:	e8 37 ff ff ff       	call   801345 <fsipc>
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 2c                	js     80143e <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	68 00 50 80 00       	push   $0x805000
  80141a:	53                   	push   %ebx
  80141b:	e8 51 f3 ff ff       	call   800771 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801420:	a1 80 50 80 00       	mov    0x805080,%eax
  801425:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80142b:	a1 84 50 80 00       	mov    0x805084,%eax
  801430:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <devfile_write>:
{
  801443:	f3 0f 1e fb          	endbr32 
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	8b 45 10             	mov    0x10(%ebp),%eax
  801450:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801455:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80145a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80145d:	8b 55 08             	mov    0x8(%ebp),%edx
  801460:	8b 52 0c             	mov    0xc(%edx),%edx
  801463:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801469:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80146e:	50                   	push   %eax
  80146f:	ff 75 0c             	pushl  0xc(%ebp)
  801472:	68 08 50 80 00       	push   $0x805008
  801477:	e8 f3 f4 ff ff       	call   80096f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80147c:	ba 00 00 00 00       	mov    $0x0,%edx
  801481:	b8 04 00 00 00       	mov    $0x4,%eax
  801486:	e8 ba fe ff ff       	call   801345 <fsipc>
}
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <devfile_read>:
{
  80148d:	f3 0f 1e fb          	endbr32 
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	56                   	push   %esi
  801495:	53                   	push   %ebx
  801496:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	8b 40 0c             	mov    0xc(%eax),%eax
  80149f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014af:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b4:	e8 8c fe ff ff       	call   801345 <fsipc>
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 1f                	js     8014de <devfile_read+0x51>
	assert(r <= n);
  8014bf:	39 f0                	cmp    %esi,%eax
  8014c1:	77 24                	ja     8014e7 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014c3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c8:	7f 36                	jg     801500 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014ca:	83 ec 04             	sub    $0x4,%esp
  8014cd:	50                   	push   %eax
  8014ce:	68 00 50 80 00       	push   $0x805000
  8014d3:	ff 75 0c             	pushl  0xc(%ebp)
  8014d6:	e8 94 f4 ff ff       	call   80096f <memmove>
	return r;
  8014db:	83 c4 10             	add    $0x10,%esp
}
  8014de:	89 d8                	mov    %ebx,%eax
  8014e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    
	assert(r <= n);
  8014e7:	68 50 27 80 00       	push   $0x802750
  8014ec:	68 57 27 80 00       	push   $0x802757
  8014f1:	68 8c 00 00 00       	push   $0x8c
  8014f6:	68 6c 27 80 00       	push   $0x80276c
  8014fb:	e8 79 0a 00 00       	call   801f79 <_panic>
	assert(r <= PGSIZE);
  801500:	68 77 27 80 00       	push   $0x802777
  801505:	68 57 27 80 00       	push   $0x802757
  80150a:	68 8d 00 00 00       	push   $0x8d
  80150f:	68 6c 27 80 00       	push   $0x80276c
  801514:	e8 60 0a 00 00       	call   801f79 <_panic>

00801519 <open>:
{
  801519:	f3 0f 1e fb          	endbr32 
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	56                   	push   %esi
  801521:	53                   	push   %ebx
  801522:	83 ec 1c             	sub    $0x1c,%esp
  801525:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801528:	56                   	push   %esi
  801529:	e8 00 f2 ff ff       	call   80072e <strlen>
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801536:	7f 6c                	jg     8015a4 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	e8 5c f8 ff ff       	call   800da0 <fd_alloc>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 3c                	js     801589 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	56                   	push   %esi
  801551:	68 00 50 80 00       	push   $0x805000
  801556:	e8 16 f2 ff ff       	call   800771 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80155b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801563:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801566:	b8 01 00 00 00       	mov    $0x1,%eax
  80156b:	e8 d5 fd ff ff       	call   801345 <fsipc>
  801570:	89 c3                	mov    %eax,%ebx
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 19                	js     801592 <open+0x79>
	return fd2num(fd);
  801579:	83 ec 0c             	sub    $0xc,%esp
  80157c:	ff 75 f4             	pushl  -0xc(%ebp)
  80157f:	e8 ed f7 ff ff       	call   800d71 <fd2num>
  801584:	89 c3                	mov    %eax,%ebx
  801586:	83 c4 10             	add    $0x10,%esp
}
  801589:	89 d8                	mov    %ebx,%eax
  80158b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    
		fd_close(fd, 0);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	6a 00                	push   $0x0
  801597:	ff 75 f4             	pushl  -0xc(%ebp)
  80159a:	e8 0a f9 ff ff       	call   800ea9 <fd_close>
		return r;
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	eb e5                	jmp    801589 <open+0x70>
		return -E_BAD_PATH;
  8015a4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015a9:	eb de                	jmp    801589 <open+0x70>

008015ab <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ab:	f3 0f 1e fb          	endbr32 
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8015bf:	e8 81 fd ff ff       	call   801345 <fsipc>
}
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015c6:	f3 0f 1e fb          	endbr32 
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015d0:	68 e3 27 80 00       	push   $0x8027e3
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	e8 94 f1 ff ff       	call   800771 <strcpy>
	return 0;
}
  8015dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    

008015e4 <devsock_close>:
{
  8015e4:	f3 0f 1e fb          	endbr32 
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 10             	sub    $0x10,%esp
  8015ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015f2:	53                   	push   %ebx
  8015f3:	e8 cd 0a 00 00       	call   8020c5 <pageref>
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	83 c4 10             	add    $0x10,%esp
		return 0;
  8015fd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801602:	83 fa 01             	cmp    $0x1,%edx
  801605:	74 05                	je     80160c <devsock_close+0x28>
}
  801607:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160a:	c9                   	leave  
  80160b:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	ff 73 0c             	pushl  0xc(%ebx)
  801612:	e8 e3 02 00 00       	call   8018fa <nsipc_close>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb eb                	jmp    801607 <devsock_close+0x23>

0080161c <devsock_write>:
{
  80161c:	f3 0f 1e fb          	endbr32 
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801626:	6a 00                	push   $0x0
  801628:	ff 75 10             	pushl  0x10(%ebp)
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	8b 45 08             	mov    0x8(%ebp),%eax
  801631:	ff 70 0c             	pushl  0xc(%eax)
  801634:	e8 b5 03 00 00       	call   8019ee <nsipc_send>
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <devsock_read>:
{
  80163b:	f3 0f 1e fb          	endbr32 
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801645:	6a 00                	push   $0x0
  801647:	ff 75 10             	pushl  0x10(%ebp)
  80164a:	ff 75 0c             	pushl  0xc(%ebp)
  80164d:	8b 45 08             	mov    0x8(%ebp),%eax
  801650:	ff 70 0c             	pushl  0xc(%eax)
  801653:	e8 1f 03 00 00       	call   801977 <nsipc_recv>
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <fd2sockid>:
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801660:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801663:	52                   	push   %edx
  801664:	50                   	push   %eax
  801665:	e8 8c f7 ff ff       	call   800df6 <fd_lookup>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 10                	js     801681 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80167a:	39 08                	cmp    %ecx,(%eax)
  80167c:	75 05                	jne    801683 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80167e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    
		return -E_NOT_SUPP;
  801683:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801688:	eb f7                	jmp    801681 <fd2sockid+0x27>

0080168a <alloc_sockfd>:
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 1c             	sub    $0x1c,%esp
  801692:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801694:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801697:	50                   	push   %eax
  801698:	e8 03 f7 ff ff       	call   800da0 <fd_alloc>
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 43                	js     8016e9 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016a6:	83 ec 04             	sub    $0x4,%esp
  8016a9:	68 07 04 00 00       	push   $0x407
  8016ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b1:	6a 00                	push   $0x0
  8016b3:	e8 22 f5 ff ff       	call   800bda <sys_page_alloc>
  8016b8:	89 c3                	mov    %eax,%ebx
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 28                	js     8016e9 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8016c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c4:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8016ca:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016d6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016d9:	83 ec 0c             	sub    $0xc,%esp
  8016dc:	50                   	push   %eax
  8016dd:	e8 8f f6 ff ff       	call   800d71 <fd2num>
  8016e2:	89 c3                	mov    %eax,%ebx
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	eb 0c                	jmp    8016f5 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8016e9:	83 ec 0c             	sub    $0xc,%esp
  8016ec:	56                   	push   %esi
  8016ed:	e8 08 02 00 00       	call   8018fa <nsipc_close>
		return r;
  8016f2:	83 c4 10             	add    $0x10,%esp
}
  8016f5:	89 d8                	mov    %ebx,%eax
  8016f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <accept>:
{
  8016fe:	f3 0f 1e fb          	endbr32 
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	e8 4a ff ff ff       	call   80165a <fd2sockid>
  801710:	85 c0                	test   %eax,%eax
  801712:	78 1b                	js     80172f <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	ff 75 10             	pushl  0x10(%ebp)
  80171a:	ff 75 0c             	pushl  0xc(%ebp)
  80171d:	50                   	push   %eax
  80171e:	e8 22 01 00 00       	call   801845 <nsipc_accept>
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	78 05                	js     80172f <accept+0x31>
	return alloc_sockfd(r);
  80172a:	e8 5b ff ff ff       	call   80168a <alloc_sockfd>
}
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <bind>:
{
  801731:	f3 0f 1e fb          	endbr32 
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80173b:	8b 45 08             	mov    0x8(%ebp),%eax
  80173e:	e8 17 ff ff ff       	call   80165a <fd2sockid>
  801743:	85 c0                	test   %eax,%eax
  801745:	78 12                	js     801759 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	ff 75 10             	pushl  0x10(%ebp)
  80174d:	ff 75 0c             	pushl  0xc(%ebp)
  801750:	50                   	push   %eax
  801751:	e8 45 01 00 00       	call   80189b <nsipc_bind>
  801756:	83 c4 10             	add    $0x10,%esp
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <shutdown>:
{
  80175b:	f3 0f 1e fb          	endbr32 
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801765:	8b 45 08             	mov    0x8(%ebp),%eax
  801768:	e8 ed fe ff ff       	call   80165a <fd2sockid>
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 0f                	js     801780 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	ff 75 0c             	pushl  0xc(%ebp)
  801777:	50                   	push   %eax
  801778:	e8 57 01 00 00       	call   8018d4 <nsipc_shutdown>
  80177d:	83 c4 10             	add    $0x10,%esp
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <connect>:
{
  801782:	f3 0f 1e fb          	endbr32 
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	e8 c6 fe ff ff       	call   80165a <fd2sockid>
  801794:	85 c0                	test   %eax,%eax
  801796:	78 12                	js     8017aa <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	ff 75 10             	pushl  0x10(%ebp)
  80179e:	ff 75 0c             	pushl  0xc(%ebp)
  8017a1:	50                   	push   %eax
  8017a2:	e8 71 01 00 00       	call   801918 <nsipc_connect>
  8017a7:	83 c4 10             	add    $0x10,%esp
}
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <listen>:
{
  8017ac:	f3 0f 1e fb          	endbr32 
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	e8 9c fe ff ff       	call   80165a <fd2sockid>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 0f                	js     8017d1 <listen+0x25>
	return nsipc_listen(r, backlog);
  8017c2:	83 ec 08             	sub    $0x8,%esp
  8017c5:	ff 75 0c             	pushl  0xc(%ebp)
  8017c8:	50                   	push   %eax
  8017c9:	e8 83 01 00 00       	call   801951 <nsipc_listen>
  8017ce:	83 c4 10             	add    $0x10,%esp
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <socket>:

int
socket(int domain, int type, int protocol)
{
  8017d3:	f3 0f 1e fb          	endbr32 
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017dd:	ff 75 10             	pushl  0x10(%ebp)
  8017e0:	ff 75 0c             	pushl  0xc(%ebp)
  8017e3:	ff 75 08             	pushl  0x8(%ebp)
  8017e6:	e8 65 02 00 00       	call   801a50 <nsipc_socket>
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 05                	js     8017f7 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8017f2:	e8 93 fe ff ff       	call   80168a <alloc_sockfd>
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 04             	sub    $0x4,%esp
  801800:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801802:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801809:	74 26                	je     801831 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80180b:	6a 07                	push   $0x7
  80180d:	68 00 60 80 00       	push   $0x806000
  801812:	53                   	push   %ebx
  801813:	ff 35 04 40 80 00    	pushl  0x804004
  801819:	e8 12 08 00 00       	call   802030 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80181e:	83 c4 0c             	add    $0xc,%esp
  801821:	6a 00                	push   $0x0
  801823:	6a 00                	push   $0x0
  801825:	6a 00                	push   $0x0
  801827:	e8 97 07 00 00       	call   801fc3 <ipc_recv>
}
  80182c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182f:	c9                   	leave  
  801830:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801831:	83 ec 0c             	sub    $0xc,%esp
  801834:	6a 02                	push   $0x2
  801836:	e8 4d 08 00 00       	call   802088 <ipc_find_env>
  80183b:	a3 04 40 80 00       	mov    %eax,0x804004
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	eb c6                	jmp    80180b <nsipc+0x12>

00801845 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801845:	f3 0f 1e fb          	endbr32 
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801851:	8b 45 08             	mov    0x8(%ebp),%eax
  801854:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801859:	8b 06                	mov    (%esi),%eax
  80185b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801860:	b8 01 00 00 00       	mov    $0x1,%eax
  801865:	e8 8f ff ff ff       	call   8017f9 <nsipc>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	85 c0                	test   %eax,%eax
  80186e:	79 09                	jns    801879 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801870:	89 d8                	mov    %ebx,%eax
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801879:	83 ec 04             	sub    $0x4,%esp
  80187c:	ff 35 10 60 80 00    	pushl  0x806010
  801882:	68 00 60 80 00       	push   $0x806000
  801887:	ff 75 0c             	pushl  0xc(%ebp)
  80188a:	e8 e0 f0 ff ff       	call   80096f <memmove>
		*addrlen = ret->ret_addrlen;
  80188f:	a1 10 60 80 00       	mov    0x806010,%eax
  801894:	89 06                	mov    %eax,(%esi)
  801896:	83 c4 10             	add    $0x10,%esp
	return r;
  801899:	eb d5                	jmp    801870 <nsipc_accept+0x2b>

0080189b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80189b:	f3 0f 1e fb          	endbr32 
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	53                   	push   %ebx
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ac:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018b1:	53                   	push   %ebx
  8018b2:	ff 75 0c             	pushl  0xc(%ebp)
  8018b5:	68 04 60 80 00       	push   $0x806004
  8018ba:	e8 b0 f0 ff ff       	call   80096f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018bf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018c5:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ca:	e8 2a ff ff ff       	call   8017f9 <nsipc>
}
  8018cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018d4:	f3 0f 1e fb          	endbr32 
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f3:	e8 01 ff ff ff       	call   8017f9 <nsipc>
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <nsipc_close>:

int
nsipc_close(int s)
{
  8018fa:	f3 0f 1e fb          	endbr32 
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80190c:	b8 04 00 00 00       	mov    $0x4,%eax
  801911:	e8 e3 fe ff ff       	call   8017f9 <nsipc>
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801918:	f3 0f 1e fb          	endbr32 
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80192e:	53                   	push   %ebx
  80192f:	ff 75 0c             	pushl  0xc(%ebp)
  801932:	68 04 60 80 00       	push   $0x806004
  801937:	e8 33 f0 ff ff       	call   80096f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80193c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801942:	b8 05 00 00 00       	mov    $0x5,%eax
  801947:	e8 ad fe ff ff       	call   8017f9 <nsipc>
}
  80194c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194f:	c9                   	leave  
  801950:	c3                   	ret    

00801951 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801951:	f3 0f 1e fb          	endbr32 
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801963:	8b 45 0c             	mov    0xc(%ebp),%eax
  801966:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80196b:	b8 06 00 00 00       	mov    $0x6,%eax
  801970:	e8 84 fe ff ff       	call   8017f9 <nsipc>
}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801977:	f3 0f 1e fb          	endbr32 
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80198b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801991:	8b 45 14             	mov    0x14(%ebp),%eax
  801994:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801999:	b8 07 00 00 00       	mov    $0x7,%eax
  80199e:	e8 56 fe ff ff       	call   8017f9 <nsipc>
  8019a3:	89 c3                	mov    %eax,%ebx
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 26                	js     8019cf <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8019a9:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8019af:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019b4:	0f 4e c6             	cmovle %esi,%eax
  8019b7:	39 c3                	cmp    %eax,%ebx
  8019b9:	7f 1d                	jg     8019d8 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019bb:	83 ec 04             	sub    $0x4,%esp
  8019be:	53                   	push   %ebx
  8019bf:	68 00 60 80 00       	push   $0x806000
  8019c4:	ff 75 0c             	pushl  0xc(%ebp)
  8019c7:	e8 a3 ef ff ff       	call   80096f <memmove>
  8019cc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019d8:	68 ef 27 80 00       	push   $0x8027ef
  8019dd:	68 57 27 80 00       	push   $0x802757
  8019e2:	6a 62                	push   $0x62
  8019e4:	68 04 28 80 00       	push   $0x802804
  8019e9:	e8 8b 05 00 00       	call   801f79 <_panic>

008019ee <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019ee:	f3 0f 1e fb          	endbr32 
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ff:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a04:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a0a:	7f 2e                	jg     801a3a <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a0c:	83 ec 04             	sub    $0x4,%esp
  801a0f:	53                   	push   %ebx
  801a10:	ff 75 0c             	pushl  0xc(%ebp)
  801a13:	68 0c 60 80 00       	push   $0x80600c
  801a18:	e8 52 ef ff ff       	call   80096f <memmove>
	nsipcbuf.send.req_size = size;
  801a1d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a23:	8b 45 14             	mov    0x14(%ebp),%eax
  801a26:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a2b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a30:	e8 c4 fd ff ff       	call   8017f9 <nsipc>
}
  801a35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    
	assert(size < 1600);
  801a3a:	68 10 28 80 00       	push   $0x802810
  801a3f:	68 57 27 80 00       	push   $0x802757
  801a44:	6a 6d                	push   $0x6d
  801a46:	68 04 28 80 00       	push   $0x802804
  801a4b:	e8 29 05 00 00       	call   801f79 <_panic>

00801a50 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a50:	f3 0f 1e fb          	endbr32 
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a65:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a72:	b8 09 00 00 00       	mov    $0x9,%eax
  801a77:	e8 7d fd ff ff       	call   8017f9 <nsipc>
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a7e:	f3 0f 1e fb          	endbr32 
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	ff 75 08             	pushl  0x8(%ebp)
  801a90:	e8 f0 f2 ff ff       	call   800d85 <fd2data>
  801a95:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a97:	83 c4 08             	add    $0x8,%esp
  801a9a:	68 1c 28 80 00       	push   $0x80281c
  801a9f:	53                   	push   %ebx
  801aa0:	e8 cc ec ff ff       	call   800771 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa5:	8b 46 04             	mov    0x4(%esi),%eax
  801aa8:	2b 06                	sub    (%esi),%eax
  801aaa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab7:	00 00 00 
	stat->st_dev = &devpipe;
  801aba:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801ac1:	30 80 00 
	return 0;
}
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad0:	f3 0f 1e fb          	endbr32 
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ade:	53                   	push   %ebx
  801adf:	6a 00                	push   $0x0
  801ae1:	e8 3f f1 ff ff       	call   800c25 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae6:	89 1c 24             	mov    %ebx,(%esp)
  801ae9:	e8 97 f2 ff ff       	call   800d85 <fd2data>
  801aee:	83 c4 08             	add    $0x8,%esp
  801af1:	50                   	push   %eax
  801af2:	6a 00                	push   $0x0
  801af4:	e8 2c f1 ff ff       	call   800c25 <sys_page_unmap>
}
  801af9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <_pipeisclosed>:
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	57                   	push   %edi
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 1c             	sub    $0x1c,%esp
  801b07:	89 c7                	mov    %eax,%edi
  801b09:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b0b:	a1 08 40 80 00       	mov    0x804008,%eax
  801b10:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	57                   	push   %edi
  801b17:	e8 a9 05 00 00       	call   8020c5 <pageref>
  801b1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b1f:	89 34 24             	mov    %esi,(%esp)
  801b22:	e8 9e 05 00 00       	call   8020c5 <pageref>
		nn = thisenv->env_runs;
  801b27:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b2d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	39 cb                	cmp    %ecx,%ebx
  801b35:	74 1b                	je     801b52 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b37:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b3a:	75 cf                	jne    801b0b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b3c:	8b 42 58             	mov    0x58(%edx),%eax
  801b3f:	6a 01                	push   $0x1
  801b41:	50                   	push   %eax
  801b42:	53                   	push   %ebx
  801b43:	68 23 28 80 00       	push   $0x802823
  801b48:	e8 1a e6 ff ff       	call   800167 <cprintf>
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	eb b9                	jmp    801b0b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b52:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b55:	0f 94 c0             	sete   %al
  801b58:	0f b6 c0             	movzbl %al,%eax
}
  801b5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5e:	5b                   	pop    %ebx
  801b5f:	5e                   	pop    %esi
  801b60:	5f                   	pop    %edi
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <devpipe_write>:
{
  801b63:	f3 0f 1e fb          	endbr32 
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	57                   	push   %edi
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 28             	sub    $0x28,%esp
  801b70:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b73:	56                   	push   %esi
  801b74:	e8 0c f2 ff ff       	call   800d85 <fd2data>
  801b79:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b83:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b86:	74 4f                	je     801bd7 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b88:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8b:	8b 0b                	mov    (%ebx),%ecx
  801b8d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b90:	39 d0                	cmp    %edx,%eax
  801b92:	72 14                	jb     801ba8 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b94:	89 da                	mov    %ebx,%edx
  801b96:	89 f0                	mov    %esi,%eax
  801b98:	e8 61 ff ff ff       	call   801afe <_pipeisclosed>
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	75 3b                	jne    801bdc <devpipe_write+0x79>
			sys_yield();
  801ba1:	e8 11 f0 ff ff       	call   800bb7 <sys_yield>
  801ba6:	eb e0                	jmp    801b88 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bab:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801baf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb2:	89 c2                	mov    %eax,%edx
  801bb4:	c1 fa 1f             	sar    $0x1f,%edx
  801bb7:	89 d1                	mov    %edx,%ecx
  801bb9:	c1 e9 1b             	shr    $0x1b,%ecx
  801bbc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bbf:	83 e2 1f             	and    $0x1f,%edx
  801bc2:	29 ca                	sub    %ecx,%edx
  801bc4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bc8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bcc:	83 c0 01             	add    $0x1,%eax
  801bcf:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bd2:	83 c7 01             	add    $0x1,%edi
  801bd5:	eb ac                	jmp    801b83 <devpipe_write+0x20>
	return i;
  801bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bda:	eb 05                	jmp    801be1 <devpipe_write+0x7e>
				return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <devpipe_read>:
{
  801be9:	f3 0f 1e fb          	endbr32 
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	57                   	push   %edi
  801bf1:	56                   	push   %esi
  801bf2:	53                   	push   %ebx
  801bf3:	83 ec 18             	sub    $0x18,%esp
  801bf6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bf9:	57                   	push   %edi
  801bfa:	e8 86 f1 ff ff       	call   800d85 <fd2data>
  801bff:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	be 00 00 00 00       	mov    $0x0,%esi
  801c09:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c0c:	75 14                	jne    801c22 <devpipe_read+0x39>
	return i;
  801c0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c11:	eb 02                	jmp    801c15 <devpipe_read+0x2c>
				return i;
  801c13:	89 f0                	mov    %esi,%eax
}
  801c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c18:	5b                   	pop    %ebx
  801c19:	5e                   	pop    %esi
  801c1a:	5f                   	pop    %edi
  801c1b:	5d                   	pop    %ebp
  801c1c:	c3                   	ret    
			sys_yield();
  801c1d:	e8 95 ef ff ff       	call   800bb7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c22:	8b 03                	mov    (%ebx),%eax
  801c24:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c27:	75 18                	jne    801c41 <devpipe_read+0x58>
			if (i > 0)
  801c29:	85 f6                	test   %esi,%esi
  801c2b:	75 e6                	jne    801c13 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c2d:	89 da                	mov    %ebx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	e8 c8 fe ff ff       	call   801afe <_pipeisclosed>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	74 e3                	je     801c1d <devpipe_read+0x34>
				return 0;
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3f:	eb d4                	jmp    801c15 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c41:	99                   	cltd   
  801c42:	c1 ea 1b             	shr    $0x1b,%edx
  801c45:	01 d0                	add    %edx,%eax
  801c47:	83 e0 1f             	and    $0x1f,%eax
  801c4a:	29 d0                	sub    %edx,%eax
  801c4c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c54:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c57:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c5a:	83 c6 01             	add    $0x1,%esi
  801c5d:	eb aa                	jmp    801c09 <devpipe_read+0x20>

00801c5f <pipe>:
{
  801c5f:	f3 0f 1e fb          	endbr32 
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	e8 2c f1 ff ff       	call   800da0 <fd_alloc>
  801c74:	89 c3                	mov    %eax,%ebx
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	0f 88 23 01 00 00    	js     801da4 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	68 07 04 00 00       	push   $0x407
  801c89:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 47 ef ff ff       	call   800bda <sys_page_alloc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	0f 88 04 01 00 00    	js     801da4 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801ca0:	83 ec 0c             	sub    $0xc,%esp
  801ca3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	e8 f4 f0 ff ff       	call   800da0 <fd_alloc>
  801cac:	89 c3                	mov    %eax,%ebx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	0f 88 db 00 00 00    	js     801d94 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb9:	83 ec 04             	sub    $0x4,%esp
  801cbc:	68 07 04 00 00       	push   $0x407
  801cc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 0f ef ff ff       	call   800bda <sys_page_alloc>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	0f 88 bc 00 00 00    	js     801d94 <pipe+0x135>
	va = fd2data(fd0);
  801cd8:	83 ec 0c             	sub    $0xc,%esp
  801cdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cde:	e8 a2 f0 ff ff       	call   800d85 <fd2data>
  801ce3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce5:	83 c4 0c             	add    $0xc,%esp
  801ce8:	68 07 04 00 00       	push   $0x407
  801ced:	50                   	push   %eax
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 e5 ee ff ff       	call   800bda <sys_page_alloc>
  801cf5:	89 c3                	mov    %eax,%ebx
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	0f 88 82 00 00 00    	js     801d84 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	ff 75 f0             	pushl  -0x10(%ebp)
  801d08:	e8 78 f0 ff ff       	call   800d85 <fd2data>
  801d0d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d14:	50                   	push   %eax
  801d15:	6a 00                	push   $0x0
  801d17:	56                   	push   %esi
  801d18:	6a 00                	push   $0x0
  801d1a:	e8 e1 ee ff ff       	call   800c00 <sys_page_map>
  801d1f:	89 c3                	mov    %eax,%ebx
  801d21:	83 c4 20             	add    $0x20,%esp
  801d24:	85 c0                	test   %eax,%eax
  801d26:	78 4e                	js     801d76 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d28:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d30:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d35:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d3f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d44:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d4b:	83 ec 0c             	sub    $0xc,%esp
  801d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d51:	e8 1b f0 ff ff       	call   800d71 <fd2num>
  801d56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d59:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d5b:	83 c4 04             	add    $0x4,%esp
  801d5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d61:	e8 0b f0 ff ff       	call   800d71 <fd2num>
  801d66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d69:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d74:	eb 2e                	jmp    801da4 <pipe+0x145>
	sys_page_unmap(0, va);
  801d76:	83 ec 08             	sub    $0x8,%esp
  801d79:	56                   	push   %esi
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 a4 ee ff ff       	call   800c25 <sys_page_unmap>
  801d81:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d84:	83 ec 08             	sub    $0x8,%esp
  801d87:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8a:	6a 00                	push   $0x0
  801d8c:	e8 94 ee ff ff       	call   800c25 <sys_page_unmap>
  801d91:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d94:	83 ec 08             	sub    $0x8,%esp
  801d97:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 84 ee ff ff       	call   800c25 <sys_page_unmap>
  801da1:	83 c4 10             	add    $0x10,%esp
}
  801da4:	89 d8                	mov    %ebx,%eax
  801da6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da9:	5b                   	pop    %ebx
  801daa:	5e                   	pop    %esi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <pipeisclosed>:
{
  801dad:	f3 0f 1e fb          	endbr32 
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dba:	50                   	push   %eax
  801dbb:	ff 75 08             	pushl  0x8(%ebp)
  801dbe:	e8 33 f0 ff ff       	call   800df6 <fd_lookup>
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 18                	js     801de2 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801dca:	83 ec 0c             	sub    $0xc,%esp
  801dcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd0:	e8 b0 ef ff ff       	call   800d85 <fd2data>
  801dd5:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dda:	e8 1f fd ff ff       	call   801afe <_pipeisclosed>
  801ddf:	83 c4 10             	add    $0x10,%esp
}
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801de4:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801de8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ded:	c3                   	ret    

00801dee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dee:	f3 0f 1e fb          	endbr32 
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801df8:	68 3b 28 80 00       	push   $0x80283b
  801dfd:	ff 75 0c             	pushl  0xc(%ebp)
  801e00:	e8 6c e9 ff ff       	call   800771 <strcpy>
	return 0;
}
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <devcons_write>:
{
  801e0c:	f3 0f 1e fb          	endbr32 
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	57                   	push   %edi
  801e14:	56                   	push   %esi
  801e15:	53                   	push   %ebx
  801e16:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e1c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e21:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e27:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e2a:	73 31                	jae    801e5d <devcons_write+0x51>
		m = n - tot;
  801e2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e2f:	29 f3                	sub    %esi,%ebx
  801e31:	83 fb 7f             	cmp    $0x7f,%ebx
  801e34:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e39:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	53                   	push   %ebx
  801e40:	89 f0                	mov    %esi,%eax
  801e42:	03 45 0c             	add    0xc(%ebp),%eax
  801e45:	50                   	push   %eax
  801e46:	57                   	push   %edi
  801e47:	e8 23 eb ff ff       	call   80096f <memmove>
		sys_cputs(buf, m);
  801e4c:	83 c4 08             	add    $0x8,%esp
  801e4f:	53                   	push   %ebx
  801e50:	57                   	push   %edi
  801e51:	e8 d5 ec ff ff       	call   800b2b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e56:	01 de                	add    %ebx,%esi
  801e58:	83 c4 10             	add    $0x10,%esp
  801e5b:	eb ca                	jmp    801e27 <devcons_write+0x1b>
}
  801e5d:	89 f0                	mov    %esi,%eax
  801e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e62:	5b                   	pop    %ebx
  801e63:	5e                   	pop    %esi
  801e64:	5f                   	pop    %edi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <devcons_read>:
{
  801e67:	f3 0f 1e fb          	endbr32 
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 08             	sub    $0x8,%esp
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7a:	74 21                	je     801e9d <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e7c:	e8 cc ec ff ff       	call   800b4d <sys_cgetc>
  801e81:	85 c0                	test   %eax,%eax
  801e83:	75 07                	jne    801e8c <devcons_read+0x25>
		sys_yield();
  801e85:	e8 2d ed ff ff       	call   800bb7 <sys_yield>
  801e8a:	eb f0                	jmp    801e7c <devcons_read+0x15>
	if (c < 0)
  801e8c:	78 0f                	js     801e9d <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e8e:	83 f8 04             	cmp    $0x4,%eax
  801e91:	74 0c                	je     801e9f <devcons_read+0x38>
	*(char*)vbuf = c;
  801e93:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e96:	88 02                	mov    %al,(%edx)
	return 1;
  801e98:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    
		return 0;
  801e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea4:	eb f7                	jmp    801e9d <devcons_read+0x36>

00801ea6 <cputchar>:
{
  801ea6:	f3 0f 1e fb          	endbr32 
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801eb6:	6a 01                	push   $0x1
  801eb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	e8 6a ec ff ff       	call   800b2b <sys_cputs>
}
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	c9                   	leave  
  801ec5:	c3                   	ret    

00801ec6 <getchar>:
{
  801ec6:	f3 0f 1e fb          	endbr32 
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ed0:	6a 01                	push   $0x1
  801ed2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed5:	50                   	push   %eax
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 a1 f1 ff ff       	call   80107e <read>
	if (r < 0)
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 06                	js     801eea <getchar+0x24>
	if (r < 1)
  801ee4:	74 06                	je     801eec <getchar+0x26>
	return c;
  801ee6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    
		return -E_EOF;
  801eec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ef1:	eb f7                	jmp    801eea <getchar+0x24>

00801ef3 <iscons>:
{
  801ef3:	f3 0f 1e fb          	endbr32 
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f00:	50                   	push   %eax
  801f01:	ff 75 08             	pushl  0x8(%ebp)
  801f04:	e8 ed ee ff ff       	call   800df6 <fd_lookup>
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 11                	js     801f21 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f13:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f19:	39 10                	cmp    %edx,(%eax)
  801f1b:	0f 94 c0             	sete   %al
  801f1e:	0f b6 c0             	movzbl %al,%eax
}
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    

00801f23 <opencons>:
{
  801f23:	f3 0f 1e fb          	endbr32 
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f30:	50                   	push   %eax
  801f31:	e8 6a ee ff ff       	call   800da0 <fd_alloc>
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 3a                	js     801f77 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f3d:	83 ec 04             	sub    $0x4,%esp
  801f40:	68 07 04 00 00       	push   $0x407
  801f45:	ff 75 f4             	pushl  -0xc(%ebp)
  801f48:	6a 00                	push   $0x0
  801f4a:	e8 8b ec ff ff       	call   800bda <sys_page_alloc>
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	85 c0                	test   %eax,%eax
  801f54:	78 21                	js     801f77 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f59:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f5f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f6b:	83 ec 0c             	sub    $0xc,%esp
  801f6e:	50                   	push   %eax
  801f6f:	e8 fd ed ff ff       	call   800d71 <fd2num>
  801f74:	83 c4 10             	add    $0x10,%esp
}
  801f77:	c9                   	leave  
  801f78:	c3                   	ret    

00801f79 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f79:	f3 0f 1e fb          	endbr32 
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	56                   	push   %esi
  801f81:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f82:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f85:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f8b:	e8 04 ec ff ff       	call   800b94 <sys_getenvid>
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	ff 75 0c             	pushl  0xc(%ebp)
  801f96:	ff 75 08             	pushl  0x8(%ebp)
  801f99:	56                   	push   %esi
  801f9a:	50                   	push   %eax
  801f9b:	68 48 28 80 00       	push   $0x802848
  801fa0:	e8 c2 e1 ff ff       	call   800167 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fa5:	83 c4 18             	add    $0x18,%esp
  801fa8:	53                   	push   %ebx
  801fa9:	ff 75 10             	pushl  0x10(%ebp)
  801fac:	e8 61 e1 ff ff       	call   800112 <vcprintf>
	cprintf("\n");
  801fb1:	c7 04 24 34 28 80 00 	movl   $0x802834,(%esp)
  801fb8:	e8 aa e1 ff ff       	call   800167 <cprintf>
  801fbd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fc0:	cc                   	int3   
  801fc1:	eb fd                	jmp    801fc0 <_panic+0x47>

00801fc3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc3:	f3 0f 1e fb          	endbr32 
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	56                   	push   %esi
  801fcb:	53                   	push   %ebx
  801fcc:	8b 75 08             	mov    0x8(%ebp),%esi
  801fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fdc:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fdf:	83 ec 0c             	sub    $0xc,%esp
  801fe2:	50                   	push   %eax
  801fe3:	e8 f8 ec ff ff       	call   800ce0 <sys_ipc_recv>
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	85 c0                	test   %eax,%eax
  801fed:	75 2b                	jne    80201a <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fef:	85 f6                	test   %esi,%esi
  801ff1:	74 0a                	je     801ffd <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801ff3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff8:	8b 40 74             	mov    0x74(%eax),%eax
  801ffb:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801ffd:	85 db                	test   %ebx,%ebx
  801fff:	74 0a                	je     80200b <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802001:	a1 08 40 80 00       	mov    0x804008,%eax
  802006:	8b 40 78             	mov    0x78(%eax),%eax
  802009:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80200b:	a1 08 40 80 00       	mov    0x804008,%eax
  802010:	8b 40 70             	mov    0x70(%eax),%eax
}
  802013:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802016:	5b                   	pop    %ebx
  802017:	5e                   	pop    %esi
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80201a:	85 f6                	test   %esi,%esi
  80201c:	74 06                	je     802024 <ipc_recv+0x61>
  80201e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802024:	85 db                	test   %ebx,%ebx
  802026:	74 eb                	je     802013 <ipc_recv+0x50>
  802028:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80202e:	eb e3                	jmp    802013 <ipc_recv+0x50>

00802030 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802030:	f3 0f 1e fb          	endbr32 
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	57                   	push   %edi
  802038:	56                   	push   %esi
  802039:	53                   	push   %ebx
  80203a:	83 ec 0c             	sub    $0xc,%esp
  80203d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802040:	8b 75 0c             	mov    0xc(%ebp),%esi
  802043:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802046:	85 db                	test   %ebx,%ebx
  802048:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80204d:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802050:	ff 75 14             	pushl  0x14(%ebp)
  802053:	53                   	push   %ebx
  802054:	56                   	push   %esi
  802055:	57                   	push   %edi
  802056:	e8 5e ec ff ff       	call   800cb9 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802061:	75 07                	jne    80206a <ipc_send+0x3a>
			sys_yield();
  802063:	e8 4f eb ff ff       	call   800bb7 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802068:	eb e6                	jmp    802050 <ipc_send+0x20>
		}
		else if (ret == 0)
  80206a:	85 c0                	test   %eax,%eax
  80206c:	75 08                	jne    802076 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80206e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802076:	50                   	push   %eax
  802077:	68 6b 28 80 00       	push   $0x80286b
  80207c:	6a 48                	push   $0x48
  80207e:	68 79 28 80 00       	push   $0x802879
  802083:	e8 f1 fe ff ff       	call   801f79 <_panic>

00802088 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802088:	f3 0f 1e fb          	endbr32 
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802092:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802097:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80209a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a0:	8b 52 50             	mov    0x50(%edx),%edx
  8020a3:	39 ca                	cmp    %ecx,%edx
  8020a5:	74 11                	je     8020b8 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8020a7:	83 c0 01             	add    $0x1,%eax
  8020aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020af:	75 e6                	jne    802097 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b6:	eb 0b                	jmp    8020c3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c5:	f3 0f 1e fb          	endbr32 
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020cf:	89 c2                	mov    %eax,%edx
  8020d1:	c1 ea 16             	shr    $0x16,%edx
  8020d4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020db:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020e0:	f6 c1 01             	test   $0x1,%cl
  8020e3:	74 1c                	je     802101 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020e5:	c1 e8 0c             	shr    $0xc,%eax
  8020e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020ef:	a8 01                	test   $0x1,%al
  8020f1:	74 0e                	je     802101 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f3:	c1 e8 0c             	shr    $0xc,%eax
  8020f6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020fd:	ef 
  8020fe:	0f b7 d2             	movzwl %dx,%edx
}
  802101:	89 d0                	mov    %edx,%eax
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	66 90                	xchg   %ax,%ax
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
