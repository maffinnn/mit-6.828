
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003d:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800043:	68 60 23 80 00       	push   $0x802360
  800048:	e8 0a 01 00 00       	call   800157 <cprintf>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800061:	e8 1e 0b 00 00       	call   800b84 <sys_getenvid>
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x31>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	f3 0f 1e fb          	endbr32 
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000a6:	e8 aa 0e 00 00       	call   800f55 <close_all>
	sys_env_destroy(0);
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 ab 0a 00 00       	call   800b60 <sys_env_destroy>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ba:	f3 0f 1e fb          	endbr32 
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	74 09                	je     8000e6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000dd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	68 ff 00 00 00       	push   $0xff
  8000ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f1:	50                   	push   %eax
  8000f2:	e8 24 0a 00 00       	call   800b1b <sys_cputs>
		b->idx = 0;
  8000f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	eb db                	jmp    8000dd <putch+0x23>

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	f3 0f 1e fb          	endbr32 
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800116:	00 00 00 
	b.cnt = 0;
  800119:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800120:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012f:	50                   	push   %eax
  800130:	68 ba 00 80 00       	push   $0x8000ba
  800135:	e8 20 01 00 00       	call   80025a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013a:	83 c4 08             	add    $0x8,%esp
  80013d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800143:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800149:	50                   	push   %eax
  80014a:	e8 cc 09 00 00       	call   800b1b <sys_cputs>

	return b.cnt;
}
  80014f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800157:	f3 0f 1e fb          	endbr32 
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800164:	50                   	push   %eax
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	e8 95 ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 1c             	sub    $0x1c,%esp
  800178:	89 c7                	mov    %eax,%edi
  80017a:	89 d6                	mov    %edx,%esi
  80017c:	8b 45 08             	mov    0x8(%ebp),%eax
  80017f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 c2                	mov    %eax,%edx
  800186:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800189:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800192:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800195:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80019c:	39 c2                	cmp    %eax,%edx
  80019e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001a1:	72 3e                	jb     8001e1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 18             	pushl  0x18(%ebp)
  8001a9:	83 eb 01             	sub    $0x1,%ebx
  8001ac:	53                   	push   %ebx
  8001ad:	50                   	push   %eax
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bd:	e8 3e 1f 00 00       	call   802100 <__udivdi3>
  8001c2:	83 c4 18             	add    $0x18,%esp
  8001c5:	52                   	push   %edx
  8001c6:	50                   	push   %eax
  8001c7:	89 f2                	mov    %esi,%edx
  8001c9:	89 f8                	mov    %edi,%eax
  8001cb:	e8 9f ff ff ff       	call   80016f <printnum>
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	eb 13                	jmp    8001e8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d5:	83 ec 08             	sub    $0x8,%esp
  8001d8:	56                   	push   %esi
  8001d9:	ff 75 18             	pushl  0x18(%ebp)
  8001dc:	ff d7                	call   *%edi
  8001de:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001e1:	83 eb 01             	sub    $0x1,%ebx
  8001e4:	85 db                	test   %ebx,%ebx
  8001e6:	7f ed                	jg     8001d5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	56                   	push   %esi
  8001ec:	83 ec 04             	sub    $0x4,%esp
  8001ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fb:	e8 10 20 00 00       	call   802210 <__umoddi3>
  800200:	83 c4 14             	add    $0x14,%esp
  800203:	0f be 80 91 23 80 00 	movsbl 0x802391(%eax),%eax
  80020a:	50                   	push   %eax
  80020b:	ff d7                	call   *%edi
}
  80020d:	83 c4 10             	add    $0x10,%esp
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800218:	f3 0f 1e fb          	endbr32 
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800222:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800226:	8b 10                	mov    (%eax),%edx
  800228:	3b 50 04             	cmp    0x4(%eax),%edx
  80022b:	73 0a                	jae    800237 <sprintputch+0x1f>
		*b->buf++ = ch;
  80022d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	88 02                	mov    %al,(%edx)
}
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <printfmt>:
{
  800239:	f3 0f 1e fb          	endbr32 
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800243:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800246:	50                   	push   %eax
  800247:	ff 75 10             	pushl  0x10(%ebp)
  80024a:	ff 75 0c             	pushl  0xc(%ebp)
  80024d:	ff 75 08             	pushl  0x8(%ebp)
  800250:	e8 05 00 00 00       	call   80025a <vprintfmt>
}
  800255:	83 c4 10             	add    $0x10,%esp
  800258:	c9                   	leave  
  800259:	c3                   	ret    

0080025a <vprintfmt>:
{
  80025a:	f3 0f 1e fb          	endbr32 
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 3c             	sub    $0x3c,%esp
  800267:	8b 75 08             	mov    0x8(%ebp),%esi
  80026a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800270:	e9 8e 03 00 00       	jmp    800603 <vprintfmt+0x3a9>
		padc = ' ';
  800275:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800279:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800280:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800287:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80028e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800293:	8d 47 01             	lea    0x1(%edi),%eax
  800296:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800299:	0f b6 17             	movzbl (%edi),%edx
  80029c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80029f:	3c 55                	cmp    $0x55,%al
  8002a1:	0f 87 df 03 00 00    	ja     800686 <vprintfmt+0x42c>
  8002a7:	0f b6 c0             	movzbl %al,%eax
  8002aa:	3e ff 24 85 e0 24 80 	notrack jmp *0x8024e0(,%eax,4)
  8002b1:	00 
  8002b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002b5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002b9:	eb d8                	jmp    800293 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002be:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002c2:	eb cf                	jmp    800293 <vprintfmt+0x39>
  8002c4:	0f b6 d2             	movzbl %dl,%edx
  8002c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8002cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8002d2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002dc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002df:	83 f9 09             	cmp    $0x9,%ecx
  8002e2:	77 55                	ja     800339 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002e4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8002e7:	eb e9                	jmp    8002d2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ec:	8b 00                	mov    (%eax),%eax
  8002ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f4:	8d 40 04             	lea    0x4(%eax),%eax
  8002f7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800301:	79 90                	jns    800293 <vprintfmt+0x39>
				width = precision, precision = -1;
  800303:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800306:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800309:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800310:	eb 81                	jmp    800293 <vprintfmt+0x39>
  800312:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800315:	85 c0                	test   %eax,%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	0f 49 d0             	cmovns %eax,%edx
  80031f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800325:	e9 69 ff ff ff       	jmp    800293 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80032d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800334:	e9 5a ff ff ff       	jmp    800293 <vprintfmt+0x39>
  800339:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80033c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033f:	eb bc                	jmp    8002fd <vprintfmt+0xa3>
			lflag++;
  800341:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800347:	e9 47 ff ff ff       	jmp    800293 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80034c:	8b 45 14             	mov    0x14(%ebp),%eax
  80034f:	8d 78 04             	lea    0x4(%eax),%edi
  800352:	83 ec 08             	sub    $0x8,%esp
  800355:	53                   	push   %ebx
  800356:	ff 30                	pushl  (%eax)
  800358:	ff d6                	call   *%esi
			break;
  80035a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80035d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800360:	e9 9b 02 00 00       	jmp    800600 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800365:	8b 45 14             	mov    0x14(%ebp),%eax
  800368:	8d 78 04             	lea    0x4(%eax),%edi
  80036b:	8b 00                	mov    (%eax),%eax
  80036d:	99                   	cltd   
  80036e:	31 d0                	xor    %edx,%eax
  800370:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800372:	83 f8 0f             	cmp    $0xf,%eax
  800375:	7f 23                	jg     80039a <vprintfmt+0x140>
  800377:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  80037e:	85 d2                	test   %edx,%edx
  800380:	74 18                	je     80039a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800382:	52                   	push   %edx
  800383:	68 49 27 80 00       	push   $0x802749
  800388:	53                   	push   %ebx
  800389:	56                   	push   %esi
  80038a:	e8 aa fe ff ff       	call   800239 <printfmt>
  80038f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800392:	89 7d 14             	mov    %edi,0x14(%ebp)
  800395:	e9 66 02 00 00       	jmp    800600 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80039a:	50                   	push   %eax
  80039b:	68 a9 23 80 00       	push   $0x8023a9
  8003a0:	53                   	push   %ebx
  8003a1:	56                   	push   %esi
  8003a2:	e8 92 fe ff ff       	call   800239 <printfmt>
  8003a7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003aa:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ad:	e9 4e 02 00 00       	jmp    800600 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	83 c0 04             	add    $0x4,%eax
  8003b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	b8 a2 23 80 00       	mov    $0x8023a2,%eax
  8003c7:	0f 45 c2             	cmovne %edx,%eax
  8003ca:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d1:	7e 06                	jle    8003d9 <vprintfmt+0x17f>
  8003d3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003d7:	75 0d                	jne    8003e6 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003dc:	89 c7                	mov    %eax,%edi
  8003de:	03 45 e0             	add    -0x20(%ebp),%eax
  8003e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e4:	eb 55                	jmp    80043b <vprintfmt+0x1e1>
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ec:	ff 75 cc             	pushl  -0x34(%ebp)
  8003ef:	e8 46 03 00 00       	call   80073a <strnlen>
  8003f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f7:	29 c2                	sub    %eax,%edx
  8003f9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800401:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800405:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800408:	85 ff                	test   %edi,%edi
  80040a:	7e 11                	jle    80041d <vprintfmt+0x1c3>
					putch(padc, putdat);
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	53                   	push   %ebx
  800410:	ff 75 e0             	pushl  -0x20(%ebp)
  800413:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800415:	83 ef 01             	sub    $0x1,%edi
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	eb eb                	jmp    800408 <vprintfmt+0x1ae>
  80041d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800420:	85 d2                	test   %edx,%edx
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	0f 49 c2             	cmovns %edx,%eax
  80042a:	29 c2                	sub    %eax,%edx
  80042c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042f:	eb a8                	jmp    8003d9 <vprintfmt+0x17f>
					putch(ch, putdat);
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	53                   	push   %ebx
  800435:	52                   	push   %edx
  800436:	ff d6                	call   *%esi
  800438:	83 c4 10             	add    $0x10,%esp
  80043b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800440:	83 c7 01             	add    $0x1,%edi
  800443:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800447:	0f be d0             	movsbl %al,%edx
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 4b                	je     800499 <vprintfmt+0x23f>
  80044e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800452:	78 06                	js     80045a <vprintfmt+0x200>
  800454:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800458:	78 1e                	js     800478 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80045a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045e:	74 d1                	je     800431 <vprintfmt+0x1d7>
  800460:	0f be c0             	movsbl %al,%eax
  800463:	83 e8 20             	sub    $0x20,%eax
  800466:	83 f8 5e             	cmp    $0x5e,%eax
  800469:	76 c6                	jbe    800431 <vprintfmt+0x1d7>
					putch('?', putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	53                   	push   %ebx
  80046f:	6a 3f                	push   $0x3f
  800471:	ff d6                	call   *%esi
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	eb c3                	jmp    80043b <vprintfmt+0x1e1>
  800478:	89 cf                	mov    %ecx,%edi
  80047a:	eb 0e                	jmp    80048a <vprintfmt+0x230>
				putch(' ', putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	6a 20                	push   $0x20
  800482:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800484:	83 ef 01             	sub    $0x1,%edi
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 ff                	test   %edi,%edi
  80048c:	7f ee                	jg     80047c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80048e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800491:	89 45 14             	mov    %eax,0x14(%ebp)
  800494:	e9 67 01 00 00       	jmp    800600 <vprintfmt+0x3a6>
  800499:	89 cf                	mov    %ecx,%edi
  80049b:	eb ed                	jmp    80048a <vprintfmt+0x230>
	if (lflag >= 2)
  80049d:	83 f9 01             	cmp    $0x1,%ecx
  8004a0:	7f 1b                	jg     8004bd <vprintfmt+0x263>
	else if (lflag)
  8004a2:	85 c9                	test   %ecx,%ecx
  8004a4:	74 63                	je     800509 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8b 00                	mov    (%eax),%eax
  8004ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ae:	99                   	cltd   
  8004af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 40 04             	lea    0x4(%eax),%eax
  8004b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bb:	eb 17                	jmp    8004d4 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8b 50 04             	mov    0x4(%eax),%edx
  8004c3:	8b 00                	mov    (%eax),%eax
  8004c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 40 08             	lea    0x8(%eax),%eax
  8004d1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004da:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004df:	85 c9                	test   %ecx,%ecx
  8004e1:	0f 89 ff 00 00 00    	jns    8005e6 <vprintfmt+0x38c>
				putch('-', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 2d                	push   $0x2d
  8004ed:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f5:	f7 da                	neg    %edx
  8004f7:	83 d1 00             	adc    $0x0,%ecx
  8004fa:	f7 d9                	neg    %ecx
  8004fc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800504:	e9 dd 00 00 00       	jmp    8005e6 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8b 00                	mov    (%eax),%eax
  80050e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800511:	99                   	cltd   
  800512:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 40 04             	lea    0x4(%eax),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	eb b4                	jmp    8004d4 <vprintfmt+0x27a>
	if (lflag >= 2)
  800520:	83 f9 01             	cmp    $0x1,%ecx
  800523:	7f 1e                	jg     800543 <vprintfmt+0x2e9>
	else if (lflag)
  800525:	85 c9                	test   %ecx,%ecx
  800527:	74 32                	je     80055b <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8b 10                	mov    (%eax),%edx
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800533:	8d 40 04             	lea    0x4(%eax),%eax
  800536:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800539:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80053e:	e9 a3 00 00 00       	jmp    8005e6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 10                	mov    (%eax),%edx
  800548:	8b 48 04             	mov    0x4(%eax),%ecx
  80054b:	8d 40 08             	lea    0x8(%eax),%eax
  80054e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800551:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800556:	e9 8b 00 00 00       	jmp    8005e6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 10                	mov    (%eax),%edx
  800560:	b9 00 00 00 00       	mov    $0x0,%ecx
  800565:	8d 40 04             	lea    0x4(%eax),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800570:	eb 74                	jmp    8005e6 <vprintfmt+0x38c>
	if (lflag >= 2)
  800572:	83 f9 01             	cmp    $0x1,%ecx
  800575:	7f 1b                	jg     800592 <vprintfmt+0x338>
	else if (lflag)
  800577:	85 c9                	test   %ecx,%ecx
  800579:	74 2c                	je     8005a7 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	b9 00 00 00 00       	mov    $0x0,%ecx
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80058b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800590:	eb 54                	jmp    8005e6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	8b 48 04             	mov    0x4(%eax),%ecx
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005a0:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005a5:	eb 3f                	jmp    8005e6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b1:	8d 40 04             	lea    0x4(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005b7:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005bc:	eb 28                	jmp    8005e6 <vprintfmt+0x38c>
			putch('0', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 30                	push   $0x30
  8005c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c6:	83 c4 08             	add    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 78                	push   $0x78
  8005cc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005d8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005db:	8d 40 04             	lea    0x4(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005e1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005ed:	57                   	push   %edi
  8005ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f1:	50                   	push   %eax
  8005f2:	51                   	push   %ecx
  8005f3:	52                   	push   %edx
  8005f4:	89 da                	mov    %ebx,%edx
  8005f6:	89 f0                	mov    %esi,%eax
  8005f8:	e8 72 fb ff ff       	call   80016f <printnum>
			break;
  8005fd:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800603:	83 c7 01             	add    $0x1,%edi
  800606:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060a:	83 f8 25             	cmp    $0x25,%eax
  80060d:	0f 84 62 fc ff ff    	je     800275 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800613:	85 c0                	test   %eax,%eax
  800615:	0f 84 8b 00 00 00    	je     8006a6 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	50                   	push   %eax
  800620:	ff d6                	call   *%esi
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	eb dc                	jmp    800603 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800627:	83 f9 01             	cmp    $0x1,%ecx
  80062a:	7f 1b                	jg     800647 <vprintfmt+0x3ed>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	74 2c                	je     80065c <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	8d 40 04             	lea    0x4(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800640:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800645:	eb 9f                	jmp    8005e6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 10                	mov    (%eax),%edx
  80064c:	8b 48 04             	mov    0x4(%eax),%ecx
  80064f:	8d 40 08             	lea    0x8(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800655:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80065a:	eb 8a                	jmp    8005e6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800671:	e9 70 ff ff ff       	jmp    8005e6 <vprintfmt+0x38c>
			putch(ch, putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 25                	push   $0x25
  80067c:	ff d6                	call   *%esi
			break;
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	e9 7a ff ff ff       	jmp    800600 <vprintfmt+0x3a6>
			putch('%', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 25                	push   $0x25
  80068c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	89 f8                	mov    %edi,%eax
  800693:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800697:	74 05                	je     80069e <vprintfmt+0x444>
  800699:	83 e8 01             	sub    $0x1,%eax
  80069c:	eb f5                	jmp    800693 <vprintfmt+0x439>
  80069e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a1:	e9 5a ff ff ff       	jmp    800600 <vprintfmt+0x3a6>
}
  8006a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a9:	5b                   	pop    %ebx
  8006aa:	5e                   	pop    %esi
  8006ab:	5f                   	pop    %edi
  8006ac:	5d                   	pop    %ebp
  8006ad:	c3                   	ret    

008006ae <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ae:	f3 0f 1e fb          	endbr32 
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 18             	sub    $0x18,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 26                	je     8006f9 <vsnprintf+0x4b>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 22                	jle    8006f9 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	ff 75 14             	pushl  0x14(%ebp)
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e0:	50                   	push   %eax
  8006e1:	68 18 02 80 00       	push   $0x800218
  8006e6:	e8 6f fb ff ff       	call   80025a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	83 c4 10             	add    $0x10,%esp
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    
		return -E_INVAL;
  8006f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fe:	eb f7                	jmp    8006f7 <vsnprintf+0x49>

00800700 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800700:	f3 0f 1e fb          	endbr32 
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070d:	50                   	push   %eax
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	ff 75 08             	pushl  0x8(%ebp)
  800717:	e8 92 ff ff ff       	call   8006ae <vsnprintf>
	va_end(ap);

	return rc;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071e:	f3 0f 1e fb          	endbr32 
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800728:	b8 00 00 00 00       	mov    $0x0,%eax
  80072d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800731:	74 05                	je     800738 <strlen+0x1a>
		n++;
  800733:	83 c0 01             	add    $0x1,%eax
  800736:	eb f5                	jmp    80072d <strlen+0xf>
	return n;
}
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073a:	f3 0f 1e fb          	endbr32 
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	39 d0                	cmp    %edx,%eax
  80074e:	74 0d                	je     80075d <strnlen+0x23>
  800750:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800754:	74 05                	je     80075b <strnlen+0x21>
		n++;
  800756:	83 c0 01             	add    $0x1,%eax
  800759:	eb f1                	jmp    80074c <strnlen+0x12>
  80075b:	89 c2                	mov    %eax,%edx
	return n;
}
  80075d:	89 d0                	mov    %edx,%eax
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800761:	f3 0f 1e fb          	endbr32 
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800778:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80077b:	83 c0 01             	add    $0x1,%eax
  80077e:	84 d2                	test   %dl,%dl
  800780:	75 f2                	jne    800774 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800782:	89 c8                	mov    %ecx,%eax
  800784:	5b                   	pop    %ebx
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800787:	f3 0f 1e fb          	endbr32 
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	83 ec 10             	sub    $0x10,%esp
  800792:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800795:	53                   	push   %ebx
  800796:	e8 83 ff ff ff       	call   80071e <strlen>
  80079b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80079e:	ff 75 0c             	pushl  0xc(%ebp)
  8007a1:	01 d8                	add    %ebx,%eax
  8007a3:	50                   	push   %eax
  8007a4:	e8 b8 ff ff ff       	call   800761 <strcpy>
	return dst;
}
  8007a9:	89 d8                	mov    %ebx,%eax
  8007ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b0:	f3 0f 1e fb          	endbr32 
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c4:	89 f0                	mov    %esi,%eax
  8007c6:	39 d8                	cmp    %ebx,%eax
  8007c8:	74 11                	je     8007db <strncpy+0x2b>
		*dst++ = *src;
  8007ca:	83 c0 01             	add    $0x1,%eax
  8007cd:	0f b6 0a             	movzbl (%edx),%ecx
  8007d0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d3:	80 f9 01             	cmp    $0x1,%cl
  8007d6:	83 da ff             	sbb    $0xffffffff,%edx
  8007d9:	eb eb                	jmp    8007c6 <strncpy+0x16>
	}
	return ret;
}
  8007db:	89 f0                	mov    %esi,%eax
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e1:	f3 0f 1e fb          	endbr32 
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 21                	je     80081a <strlcpy+0x39>
  8007f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fd:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007ff:	39 c2                	cmp    %eax,%edx
  800801:	74 14                	je     800817 <strlcpy+0x36>
  800803:	0f b6 19             	movzbl (%ecx),%ebx
  800806:	84 db                	test   %bl,%bl
  800808:	74 0b                	je     800815 <strlcpy+0x34>
			*dst++ = *src++;
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	83 c2 01             	add    $0x1,%edx
  800810:	88 5a ff             	mov    %bl,-0x1(%edx)
  800813:	eb ea                	jmp    8007ff <strlcpy+0x1e>
  800815:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800817:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081a:	29 f0                	sub    %esi,%eax
}
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	84 c0                	test   %al,%al
  800832:	74 0c                	je     800840 <strcmp+0x20>
  800834:	3a 02                	cmp    (%edx),%al
  800836:	75 08                	jne    800840 <strcmp+0x20>
		p++, q++;
  800838:	83 c1 01             	add    $0x1,%ecx
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	eb ed                	jmp    80082d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800840:	0f b6 c0             	movzbl %al,%eax
  800843:	0f b6 12             	movzbl (%edx),%edx
  800846:	29 d0                	sub    %edx,%eax
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084a:	f3 0f 1e fb          	endbr32 
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	53                   	push   %ebx
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
  800858:	89 c3                	mov    %eax,%ebx
  80085a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085d:	eb 06                	jmp    800865 <strncmp+0x1b>
		n--, p++, q++;
  80085f:	83 c0 01             	add    $0x1,%eax
  800862:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800865:	39 d8                	cmp    %ebx,%eax
  800867:	74 16                	je     80087f <strncmp+0x35>
  800869:	0f b6 08             	movzbl (%eax),%ecx
  80086c:	84 c9                	test   %cl,%cl
  80086e:	74 04                	je     800874 <strncmp+0x2a>
  800870:	3a 0a                	cmp    (%edx),%cl
  800872:	74 eb                	je     80085f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800874:	0f b6 00             	movzbl (%eax),%eax
  800877:	0f b6 12             	movzbl (%edx),%edx
  80087a:	29 d0                	sub    %edx,%eax
}
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    
		return 0;
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	eb f6                	jmp    80087c <strncmp+0x32>

00800886 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800886:	f3 0f 1e fb          	endbr32 
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800894:	0f b6 10             	movzbl (%eax),%edx
  800897:	84 d2                	test   %dl,%dl
  800899:	74 09                	je     8008a4 <strchr+0x1e>
		if (*s == c)
  80089b:	38 ca                	cmp    %cl,%dl
  80089d:	74 0a                	je     8008a9 <strchr+0x23>
	for (; *s; s++)
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	eb f0                	jmp    800894 <strchr+0xe>
			return (char *) s;
	return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8008ab:	f3 0f 1e fb          	endbr32 
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8008b5:	6a 78                	push   $0x78
  8008b7:	ff 75 08             	pushl  0x8(%ebp)
  8008ba:	e8 c7 ff ff ff       	call   800886 <strchr>
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8008ca:	eb 0d                	jmp    8008d9 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8008cc:	c1 e0 04             	shl    $0x4,%eax
  8008cf:	0f be d2             	movsbl %dl,%edx
  8008d2:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	0f b6 11             	movzbl (%ecx),%edx
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	74 11                	je     8008f1 <atox+0x46>
		if (*p>='a'){
  8008e0:	80 fa 60             	cmp    $0x60,%dl
  8008e3:	7e e7                	jle    8008cc <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8008e5:	c1 e0 04             	shl    $0x4,%eax
  8008e8:	0f be d2             	movsbl %dl,%edx
  8008eb:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8008ef:	eb e5                	jmp    8008d6 <atox+0x2b>
	}

	return v;

}
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f3:	f3 0f 1e fb          	endbr32 
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 09                	je     800911 <strfind+0x1e>
  800908:	84 d2                	test   %dl,%dl
  80090a:	74 05                	je     800911 <strfind+0x1e>
	for (; *s; s++)
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	eb f0                	jmp    800901 <strfind+0xe>
			break;
	return (char *) s;
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800913:	f3 0f 1e fb          	endbr32 
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800923:	85 c9                	test   %ecx,%ecx
  800925:	74 31                	je     800958 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800927:	89 f8                	mov    %edi,%eax
  800929:	09 c8                	or     %ecx,%eax
  80092b:	a8 03                	test   $0x3,%al
  80092d:	75 23                	jne    800952 <memset+0x3f>
		c &= 0xFF;
  80092f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800933:	89 d3                	mov    %edx,%ebx
  800935:	c1 e3 08             	shl    $0x8,%ebx
  800938:	89 d0                	mov    %edx,%eax
  80093a:	c1 e0 18             	shl    $0x18,%eax
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	c1 e6 10             	shl    $0x10,%esi
  800942:	09 f0                	or     %esi,%eax
  800944:	09 c2                	or     %eax,%edx
  800946:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800948:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	fc                   	cld    
  80094e:	f3 ab                	rep stos %eax,%es:(%edi)
  800950:	eb 06                	jmp    800958 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	fc                   	cld    
  800956:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800958:	89 f8                	mov    %edi,%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5f                   	pop    %edi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095f:	f3 0f 1e fb          	endbr32 
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800971:	39 c6                	cmp    %eax,%esi
  800973:	73 32                	jae    8009a7 <memmove+0x48>
  800975:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800978:	39 c2                	cmp    %eax,%edx
  80097a:	76 2b                	jbe    8009a7 <memmove+0x48>
		s += n;
		d += n;
  80097c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	89 fe                	mov    %edi,%esi
  800981:	09 ce                	or     %ecx,%esi
  800983:	09 d6                	or     %edx,%esi
  800985:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098b:	75 0e                	jne    80099b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098d:	83 ef 04             	sub    $0x4,%edi
  800990:	8d 72 fc             	lea    -0x4(%edx),%esi
  800993:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800996:	fd                   	std    
  800997:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800999:	eb 09                	jmp    8009a4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099b:	83 ef 01             	sub    $0x1,%edi
  80099e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a1:	fd                   	std    
  8009a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a4:	fc                   	cld    
  8009a5:	eb 1a                	jmp    8009c1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	89 c2                	mov    %eax,%edx
  8009a9:	09 ca                	or     %ecx,%edx
  8009ab:	09 f2                	or     %esi,%edx
  8009ad:	f6 c2 03             	test   $0x3,%dl
  8009b0:	75 0a                	jne    8009bc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	fc                   	cld    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 05                	jmp    8009c1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009bc:	89 c7                	mov    %eax,%edi
  8009be:	fc                   	cld    
  8009bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c1:	5e                   	pop    %esi
  8009c2:	5f                   	pop    %edi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c5:	f3 0f 1e fb          	endbr32 
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009cf:	ff 75 10             	pushl  0x10(%ebp)
  8009d2:	ff 75 0c             	pushl  0xc(%ebp)
  8009d5:	ff 75 08             	pushl  0x8(%ebp)
  8009d8:	e8 82 ff ff ff       	call   80095f <memmove>
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ee:	89 c6                	mov    %eax,%esi
  8009f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f3:	39 f0                	cmp    %esi,%eax
  8009f5:	74 1c                	je     800a13 <memcmp+0x34>
		if (*s1 != *s2)
  8009f7:	0f b6 08             	movzbl (%eax),%ecx
  8009fa:	0f b6 1a             	movzbl (%edx),%ebx
  8009fd:	38 d9                	cmp    %bl,%cl
  8009ff:	75 08                	jne    800a09 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	83 c2 01             	add    $0x1,%edx
  800a07:	eb ea                	jmp    8009f3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c1             	movzbl %cl,%eax
  800a0c:	0f b6 db             	movzbl %bl,%ebx
  800a0f:	29 d8                	sub    %ebx,%eax
  800a11:	eb 05                	jmp    800a18 <memcmp+0x39>
	}

	return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1c:	f3 0f 1e fb          	endbr32 
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a29:	89 c2                	mov    %eax,%edx
  800a2b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2e:	39 d0                	cmp    %edx,%eax
  800a30:	73 09                	jae    800a3b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a32:	38 08                	cmp    %cl,(%eax)
  800a34:	74 05                	je     800a3b <memfind+0x1f>
	for (; s < ends; s++)
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	eb f3                	jmp    800a2e <memfind+0x12>
			break;
	return (void *) s;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3d:	f3 0f 1e fb          	endbr32 
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	eb 03                	jmp    800a52 <strtol+0x15>
		s++;
  800a4f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a52:	0f b6 01             	movzbl (%ecx),%eax
  800a55:	3c 20                	cmp    $0x20,%al
  800a57:	74 f6                	je     800a4f <strtol+0x12>
  800a59:	3c 09                	cmp    $0x9,%al
  800a5b:	74 f2                	je     800a4f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a5d:	3c 2b                	cmp    $0x2b,%al
  800a5f:	74 2a                	je     800a8b <strtol+0x4e>
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a66:	3c 2d                	cmp    $0x2d,%al
  800a68:	74 2b                	je     800a95 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a70:	75 0f                	jne    800a81 <strtol+0x44>
  800a72:	80 39 30             	cmpb   $0x30,(%ecx)
  800a75:	74 28                	je     800a9f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a7e:	0f 44 d8             	cmove  %eax,%ebx
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
  800a86:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a89:	eb 46                	jmp    800ad1 <strtol+0x94>
		s++;
  800a8b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a93:	eb d5                	jmp    800a6a <strtol+0x2d>
		s++, neg = 1;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9d:	eb cb                	jmp    800a6a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa3:	74 0e                	je     800ab3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa5:	85 db                	test   %ebx,%ebx
  800aa7:	75 d8                	jne    800a81 <strtol+0x44>
		s++, base = 8;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab1:	eb ce                	jmp    800a81 <strtol+0x44>
		s += 2, base = 16;
  800ab3:	83 c1 02             	add    $0x2,%ecx
  800ab6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abb:	eb c4                	jmp    800a81 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800abd:	0f be d2             	movsbl %dl,%edx
  800ac0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac6:	7d 3a                	jge    800b02 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac8:	83 c1 01             	add    $0x1,%ecx
  800acb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	76 df                	jbe    800abd <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ade:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 57             	sub    $0x57,%edx
  800aee:	eb d3                	jmp    800ac3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800af0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 08                	ja     800b02 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 37             	sub    $0x37,%edx
  800b00:	eb c1                	jmp    800ac3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b06:	74 05                	je     800b0d <strtol+0xd0>
		*endptr = (char *) s;
  800b08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0d:	89 c2                	mov    %eax,%edx
  800b0f:	f7 da                	neg    %edx
  800b11:	85 ff                	test   %edi,%edi
  800b13:	0f 45 c2             	cmovne %edx,%eax
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1b:	f3 0f 1e fb          	endbr32 
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	89 c6                	mov    %eax,%esi
  800b36:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3d:	f3 0f 1e fb          	endbr32 
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	89 d1                	mov    %edx,%ecx
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	89 d7                	mov    %edx,%edi
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b60:	f3 0f 1e fb          	endbr32 
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	b8 03 00 00 00       	mov    $0x3,%eax
  800b77:	89 cb                	mov    %ecx,%ebx
  800b79:	89 cf                	mov    %ecx,%edi
  800b7b:	89 ce                	mov    %ecx,%esi
  800b7d:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b84:	f3 0f 1e fb          	endbr32 
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 02 00 00 00       	mov    $0x2,%eax
  800b98:	89 d1                	mov    %edx,%ecx
  800b9a:	89 d3                	mov    %edx,%ebx
  800b9c:	89 d7                	mov    %edx,%edi
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_yield>:

void
sys_yield(void)
{
  800ba7:	f3 0f 1e fb          	endbr32 
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbb:	89 d1                	mov    %edx,%ecx
  800bbd:	89 d3                	mov    %edx,%ebx
  800bbf:	89 d7                	mov    %edx,%edi
  800bc1:	89 d6                	mov    %edx,%esi
  800bc3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd4:	be 00 00 00 00       	mov    $0x0,%esi
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	b8 04 00 00 00       	mov    $0x4,%eax
  800be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be7:	89 f7                	mov    %esi,%edi
  800be9:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c15:	f3 0f 1e fb          	endbr32 
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2f:	89 df                	mov    %ebx,%edi
  800c31:	89 de                	mov    %ebx,%esi
  800c33:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3a:	f3 0f 1e fb          	endbr32 
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5f:	f3 0f 1e fb          	endbr32 
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	b8 09 00 00 00       	mov    $0x9,%eax
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c84:	f3 0f 1e fb          	endbr32 
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca9:	f3 0f 1e fb          	endbr32 
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbe:	be 00 00 00 00       	mov    $0x0,%esi
  800cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd0:	f3 0f 1e fb          	endbr32 
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce7:	89 cb                	mov    %ecx,%ebx
  800ce9:	89 cf                	mov    %ecx,%edi
  800ceb:	89 ce                	mov    %ecx,%esi
  800ced:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cf4:	f3 0f 1e fb          	endbr32 
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800d03:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d08:	89 d1                	mov    %edx,%ecx
  800d0a:	89 d3                	mov    %edx,%ebx
  800d0c:	89 d7                	mov    %edx,%edi
  800d0e:	89 d6                	mov    %edx,%esi
  800d10:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d17:	f3 0f 1e fb          	endbr32 
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800d3c:	f3 0f 1e fb          	endbr32 
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	b8 10 00 00 00       	mov    $0x10,%eax
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d61:	f3 0f 1e fb          	endbr32 
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d70:	c1 e8 0c             	shr    $0xc,%eax
}
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d75:	f3 0f 1e fb          	endbr32 
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d89:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d90:	f3 0f 1e fb          	endbr32 
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9c:	89 c2                	mov    %eax,%edx
  800d9e:	c1 ea 16             	shr    $0x16,%edx
  800da1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da8:	f6 c2 01             	test   $0x1,%dl
  800dab:	74 2d                	je     800dda <fd_alloc+0x4a>
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	c1 ea 0c             	shr    $0xc,%edx
  800db2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db9:	f6 c2 01             	test   $0x1,%dl
  800dbc:	74 1c                	je     800dda <fd_alloc+0x4a>
  800dbe:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800dc3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc8:	75 d2                	jne    800d9c <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800dd3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800dd8:	eb 0a                	jmp    800de4 <fd_alloc+0x54>
			*fd_store = fd;
  800dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de6:	f3 0f 1e fb          	endbr32 
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df0:	83 f8 1f             	cmp    $0x1f,%eax
  800df3:	77 30                	ja     800e25 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df5:	c1 e0 0c             	shl    $0xc,%eax
  800df8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dfd:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e03:	f6 c2 01             	test   $0x1,%dl
  800e06:	74 24                	je     800e2c <fd_lookup+0x46>
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	c1 ea 0c             	shr    $0xc,%edx
  800e0d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e14:	f6 c2 01             	test   $0x1,%dl
  800e17:	74 1a                	je     800e33 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1c:	89 02                	mov    %eax,(%edx)
	return 0;
  800e1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
		return -E_INVAL;
  800e25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2a:	eb f7                	jmp    800e23 <fd_lookup+0x3d>
		return -E_INVAL;
  800e2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e31:	eb f0                	jmp    800e23 <fd_lookup+0x3d>
  800e33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e38:	eb e9                	jmp    800e23 <fd_lookup+0x3d>

00800e3a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e3a:	f3 0f 1e fb          	endbr32 
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e51:	39 08                	cmp    %ecx,(%eax)
  800e53:	74 38                	je     800e8d <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800e55:	83 c2 01             	add    $0x1,%edx
  800e58:	8b 04 95 1c 27 80 00 	mov    0x80271c(,%edx,4),%eax
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	75 ee                	jne    800e51 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e63:	a1 08 40 80 00       	mov    0x804008,%eax
  800e68:	8b 40 48             	mov    0x48(%eax),%eax
  800e6b:	83 ec 04             	sub    $0x4,%esp
  800e6e:	51                   	push   %ecx
  800e6f:	50                   	push   %eax
  800e70:	68 a0 26 80 00       	push   $0x8026a0
  800e75:	e8 dd f2 ff ff       	call   800157 <cprintf>
	*dev = 0;
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    
			*dev = devtab[i];
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	eb f2                	jmp    800e8b <dev_lookup+0x51>

00800e99 <fd_close>:
{
  800e99:	f3 0f 1e fb          	endbr32 
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 24             	sub    $0x24,%esp
  800ea6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800eaf:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eb0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eb6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb9:	50                   	push   %eax
  800eba:	e8 27 ff ff ff       	call   800de6 <fd_lookup>
  800ebf:	89 c3                	mov    %eax,%ebx
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	78 05                	js     800ecd <fd_close+0x34>
	    || fd != fd2)
  800ec8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ecb:	74 16                	je     800ee3 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800ecd:	89 f8                	mov    %edi,%eax
  800ecf:	84 c0                	test   %al,%al
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	0f 44 d8             	cmove  %eax,%ebx
}
  800ed9:	89 d8                	mov    %ebx,%eax
  800edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee3:	83 ec 08             	sub    $0x8,%esp
  800ee6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ee9:	50                   	push   %eax
  800eea:	ff 36                	pushl  (%esi)
  800eec:	e8 49 ff ff ff       	call   800e3a <dev_lookup>
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	78 1a                	js     800f14 <fd_close+0x7b>
		if (dev->dev_close)
  800efa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efd:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f05:	85 c0                	test   %eax,%eax
  800f07:	74 0b                	je     800f14 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f09:	83 ec 0c             	sub    $0xc,%esp
  800f0c:	56                   	push   %esi
  800f0d:	ff d0                	call   *%eax
  800f0f:	89 c3                	mov    %eax,%ebx
  800f11:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f14:	83 ec 08             	sub    $0x8,%esp
  800f17:	56                   	push   %esi
  800f18:	6a 00                	push   $0x0
  800f1a:	e8 f6 fc ff ff       	call   800c15 <sys_page_unmap>
	return r;
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	eb b5                	jmp    800ed9 <fd_close+0x40>

00800f24 <close>:

int
close(int fdnum)
{
  800f24:	f3 0f 1e fb          	endbr32 
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f31:	50                   	push   %eax
  800f32:	ff 75 08             	pushl  0x8(%ebp)
  800f35:	e8 ac fe ff ff       	call   800de6 <fd_lookup>
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 02                	jns    800f43 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    
		return fd_close(fd, 1);
  800f43:	83 ec 08             	sub    $0x8,%esp
  800f46:	6a 01                	push   $0x1
  800f48:	ff 75 f4             	pushl  -0xc(%ebp)
  800f4b:	e8 49 ff ff ff       	call   800e99 <fd_close>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	eb ec                	jmp    800f41 <close+0x1d>

00800f55 <close_all>:

void
close_all(void)
{
  800f55:	f3 0f 1e fb          	endbr32 
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f60:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	53                   	push   %ebx
  800f69:	e8 b6 ff ff ff       	call   800f24 <close>
	for (i = 0; i < MAXFD; i++)
  800f6e:	83 c3 01             	add    $0x1,%ebx
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	83 fb 20             	cmp    $0x20,%ebx
  800f77:	75 ec                	jne    800f65 <close_all+0x10>
}
  800f79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f7e:	f3 0f 1e fb          	endbr32 
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	ff 75 08             	pushl  0x8(%ebp)
  800f92:	e8 4f fe ff ff       	call   800de6 <fd_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	0f 88 81 00 00 00    	js     801025 <dup+0xa7>
		return r;
	close(newfdnum);
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	ff 75 0c             	pushl  0xc(%ebp)
  800faa:	e8 75 ff ff ff       	call   800f24 <close>

	newfd = INDEX2FD(newfdnum);
  800faf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fb2:	c1 e6 0c             	shl    $0xc,%esi
  800fb5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fbb:	83 c4 04             	add    $0x4,%esp
  800fbe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc1:	e8 af fd ff ff       	call   800d75 <fd2data>
  800fc6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fc8:	89 34 24             	mov    %esi,(%esp)
  800fcb:	e8 a5 fd ff ff       	call   800d75 <fd2data>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd5:	89 d8                	mov    %ebx,%eax
  800fd7:	c1 e8 16             	shr    $0x16,%eax
  800fda:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe1:	a8 01                	test   $0x1,%al
  800fe3:	74 11                	je     800ff6 <dup+0x78>
  800fe5:	89 d8                	mov    %ebx,%eax
  800fe7:	c1 e8 0c             	shr    $0xc,%eax
  800fea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff1:	f6 c2 01             	test   $0x1,%dl
  800ff4:	75 39                	jne    80102f <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff9:	89 d0                	mov    %edx,%eax
  800ffb:	c1 e8 0c             	shr    $0xc,%eax
  800ffe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	25 07 0e 00 00       	and    $0xe07,%eax
  80100d:	50                   	push   %eax
  80100e:	56                   	push   %esi
  80100f:	6a 00                	push   $0x0
  801011:	52                   	push   %edx
  801012:	6a 00                	push   $0x0
  801014:	e8 d7 fb ff ff       	call   800bf0 <sys_page_map>
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	83 c4 20             	add    $0x20,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 31                	js     801053 <dup+0xd5>
		goto err;

	return newfdnum;
  801022:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801025:	89 d8                	mov    %ebx,%eax
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80102f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	25 07 0e 00 00       	and    $0xe07,%eax
  80103e:	50                   	push   %eax
  80103f:	57                   	push   %edi
  801040:	6a 00                	push   $0x0
  801042:	53                   	push   %ebx
  801043:	6a 00                	push   $0x0
  801045:	e8 a6 fb ff ff       	call   800bf0 <sys_page_map>
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 a3                	jns    800ff6 <dup+0x78>
	sys_page_unmap(0, newfd);
  801053:	83 ec 08             	sub    $0x8,%esp
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 b7 fb ff ff       	call   800c15 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	57                   	push   %edi
  801062:	6a 00                	push   $0x0
  801064:	e8 ac fb ff ff       	call   800c15 <sys_page_unmap>
	return r;
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	eb b7                	jmp    801025 <dup+0xa7>

0080106e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80106e:	f3 0f 1e fb          	endbr32 
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	53                   	push   %ebx
  801076:	83 ec 1c             	sub    $0x1c,%esp
  801079:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80107c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80107f:	50                   	push   %eax
  801080:	53                   	push   %ebx
  801081:	e8 60 fd ff ff       	call   800de6 <fd_lookup>
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	78 3f                	js     8010cc <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801093:	50                   	push   %eax
  801094:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801097:	ff 30                	pushl  (%eax)
  801099:	e8 9c fd ff ff       	call   800e3a <dev_lookup>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 27                	js     8010cc <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010a8:	8b 42 08             	mov    0x8(%edx),%eax
  8010ab:	83 e0 03             	and    $0x3,%eax
  8010ae:	83 f8 01             	cmp    $0x1,%eax
  8010b1:	74 1e                	je     8010d1 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b6:	8b 40 08             	mov    0x8(%eax),%eax
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	74 35                	je     8010f2 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010bd:	83 ec 04             	sub    $0x4,%esp
  8010c0:	ff 75 10             	pushl  0x10(%ebp)
  8010c3:	ff 75 0c             	pushl  0xc(%ebp)
  8010c6:	52                   	push   %edx
  8010c7:	ff d0                	call   *%eax
  8010c9:	83 c4 10             	add    $0x10,%esp
}
  8010cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d6:	8b 40 48             	mov    0x48(%eax),%eax
  8010d9:	83 ec 04             	sub    $0x4,%esp
  8010dc:	53                   	push   %ebx
  8010dd:	50                   	push   %eax
  8010de:	68 e1 26 80 00       	push   $0x8026e1
  8010e3:	e8 6f f0 ff ff       	call   800157 <cprintf>
		return -E_INVAL;
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f0:	eb da                	jmp    8010cc <read+0x5e>
		return -E_NOT_SUPP;
  8010f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010f7:	eb d3                	jmp    8010cc <read+0x5e>

008010f9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f9:	f3 0f 1e fb          	endbr32 
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	57                   	push   %edi
  801101:	56                   	push   %esi
  801102:	53                   	push   %ebx
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	8b 7d 08             	mov    0x8(%ebp),%edi
  801109:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80110c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801111:	eb 02                	jmp    801115 <readn+0x1c>
  801113:	01 c3                	add    %eax,%ebx
  801115:	39 f3                	cmp    %esi,%ebx
  801117:	73 21                	jae    80113a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	89 f0                	mov    %esi,%eax
  80111e:	29 d8                	sub    %ebx,%eax
  801120:	50                   	push   %eax
  801121:	89 d8                	mov    %ebx,%eax
  801123:	03 45 0c             	add    0xc(%ebp),%eax
  801126:	50                   	push   %eax
  801127:	57                   	push   %edi
  801128:	e8 41 ff ff ff       	call   80106e <read>
		if (m < 0)
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 04                	js     801138 <readn+0x3f>
			return m;
		if (m == 0)
  801134:	75 dd                	jne    801113 <readn+0x1a>
  801136:	eb 02                	jmp    80113a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801138:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80113a:	89 d8                	mov    %ebx,%eax
  80113c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801144:	f3 0f 1e fb          	endbr32 
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	53                   	push   %ebx
  80114c:	83 ec 1c             	sub    $0x1c,%esp
  80114f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801152:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	53                   	push   %ebx
  801157:	e8 8a fc ff ff       	call   800de6 <fd_lookup>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 3a                	js     80119d <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801169:	50                   	push   %eax
  80116a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116d:	ff 30                	pushl  (%eax)
  80116f:	e8 c6 fc ff ff       	call   800e3a <dev_lookup>
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	78 22                	js     80119d <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80117b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801182:	74 1e                	je     8011a2 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801184:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801187:	8b 52 0c             	mov    0xc(%edx),%edx
  80118a:	85 d2                	test   %edx,%edx
  80118c:	74 35                	je     8011c3 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	ff 75 10             	pushl  0x10(%ebp)
  801194:	ff 75 0c             	pushl  0xc(%ebp)
  801197:	50                   	push   %eax
  801198:	ff d2                	call   *%edx
  80119a:	83 c4 10             	add    $0x10,%esp
}
  80119d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a0:	c9                   	leave  
  8011a1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a7:	8b 40 48             	mov    0x48(%eax),%eax
  8011aa:	83 ec 04             	sub    $0x4,%esp
  8011ad:	53                   	push   %ebx
  8011ae:	50                   	push   %eax
  8011af:	68 fd 26 80 00       	push   $0x8026fd
  8011b4:	e8 9e ef ff ff       	call   800157 <cprintf>
		return -E_INVAL;
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c1:	eb da                	jmp    80119d <write+0x59>
		return -E_NOT_SUPP;
  8011c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011c8:	eb d3                	jmp    80119d <write+0x59>

008011ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ca:	f3 0f 1e fb          	endbr32 
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d7:	50                   	push   %eax
  8011d8:	ff 75 08             	pushl  0x8(%ebp)
  8011db:	e8 06 fc ff ff       	call   800de6 <fd_lookup>
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 0e                	js     8011f5 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8011e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ed:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f7:	f3 0f 1e fb          	endbr32 
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	53                   	push   %ebx
  8011ff:	83 ec 1c             	sub    $0x1c,%esp
  801202:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801205:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801208:	50                   	push   %eax
  801209:	53                   	push   %ebx
  80120a:	e8 d7 fb ff ff       	call   800de6 <fd_lookup>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 37                	js     80124d <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801220:	ff 30                	pushl  (%eax)
  801222:	e8 13 fc ff ff       	call   800e3a <dev_lookup>
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 1f                	js     80124d <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801231:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801235:	74 1b                	je     801252 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801237:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123a:	8b 52 18             	mov    0x18(%edx),%edx
  80123d:	85 d2                	test   %edx,%edx
  80123f:	74 32                	je     801273 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	ff 75 0c             	pushl  0xc(%ebp)
  801247:	50                   	push   %eax
  801248:	ff d2                	call   *%edx
  80124a:	83 c4 10             	add    $0x10,%esp
}
  80124d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801250:	c9                   	leave  
  801251:	c3                   	ret    
			thisenv->env_id, fdnum);
  801252:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801257:	8b 40 48             	mov    0x48(%eax),%eax
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	53                   	push   %ebx
  80125e:	50                   	push   %eax
  80125f:	68 c0 26 80 00       	push   $0x8026c0
  801264:	e8 ee ee ff ff       	call   800157 <cprintf>
		return -E_INVAL;
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801271:	eb da                	jmp    80124d <ftruncate+0x56>
		return -E_NOT_SUPP;
  801273:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801278:	eb d3                	jmp    80124d <ftruncate+0x56>

0080127a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80127a:	f3 0f 1e fb          	endbr32 
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	53                   	push   %ebx
  801282:	83 ec 1c             	sub    $0x1c,%esp
  801285:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801288:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	ff 75 08             	pushl  0x8(%ebp)
  80128f:	e8 52 fb ff ff       	call   800de6 <fd_lookup>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 4b                	js     8012e6 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a5:	ff 30                	pushl  (%eax)
  8012a7:	e8 8e fb ff ff       	call   800e3a <dev_lookup>
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 33                	js     8012e6 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8012b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ba:	74 2f                	je     8012eb <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c6:	00 00 00 
	stat->st_isdir = 0;
  8012c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012d0:	00 00 00 
	stat->st_dev = dev;
  8012d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	53                   	push   %ebx
  8012dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e0:	ff 50 14             	call   *0x14(%eax)
  8012e3:	83 c4 10             	add    $0x10,%esp
}
  8012e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    
		return -E_NOT_SUPP;
  8012eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f0:	eb f4                	jmp    8012e6 <fstat+0x6c>

008012f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012f2:	f3 0f 1e fb          	endbr32 
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	6a 00                	push   $0x0
  801300:	ff 75 08             	pushl  0x8(%ebp)
  801303:	e8 01 02 00 00       	call   801509 <open>
  801308:	89 c3                	mov    %eax,%ebx
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 1b                	js     80132c <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	ff 75 0c             	pushl  0xc(%ebp)
  801317:	50                   	push   %eax
  801318:	e8 5d ff ff ff       	call   80127a <fstat>
  80131d:	89 c6                	mov    %eax,%esi
	close(fd);
  80131f:	89 1c 24             	mov    %ebx,(%esp)
  801322:	e8 fd fb ff ff       	call   800f24 <close>
	return r;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	89 f3                	mov    %esi,%ebx
}
  80132c:	89 d8                	mov    %ebx,%eax
  80132e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	56                   	push   %esi
  801339:	53                   	push   %ebx
  80133a:	89 c6                	mov    %eax,%esi
  80133c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80133e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801345:	74 27                	je     80136e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801347:	6a 07                	push   $0x7
  801349:	68 00 50 80 00       	push   $0x805000
  80134e:	56                   	push   %esi
  80134f:	ff 35 00 40 80 00    	pushl  0x804000
  801355:	e8 c6 0c 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80135a:	83 c4 0c             	add    $0xc,%esp
  80135d:	6a 00                	push   $0x0
  80135f:	53                   	push   %ebx
  801360:	6a 00                	push   $0x0
  801362:	e8 4c 0c 00 00       	call   801fb3 <ipc_recv>
}
  801367:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	6a 01                	push   $0x1
  801373:	e8 00 0d 00 00       	call   802078 <ipc_find_env>
  801378:	a3 00 40 80 00       	mov    %eax,0x804000
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	eb c5                	jmp    801347 <fsipc+0x12>

00801382 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801382:	f3 0f 1e fb          	endbr32 
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80138c:	8b 45 08             	mov    0x8(%ebp),%eax
  80138f:	8b 40 0c             	mov    0xc(%eax),%eax
  801392:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80139f:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a9:	e8 87 ff ff ff       	call   801335 <fsipc>
}
  8013ae:	c9                   	leave  
  8013af:	c3                   	ret    

008013b0 <devfile_flush>:
{
  8013b0:	f3 0f 1e fb          	endbr32 
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8013cf:	e8 61 ff ff ff       	call   801335 <fsipc>
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <devfile_stat>:
{
  8013d6:	f3 0f 1e fb          	endbr32 
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 04             	sub    $0x4,%esp
  8013e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013f9:	e8 37 ff ff ff       	call   801335 <fsipc>
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 2c                	js     80142e <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	68 00 50 80 00       	push   $0x805000
  80140a:	53                   	push   %ebx
  80140b:	e8 51 f3 ff ff       	call   800761 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801410:	a1 80 50 80 00       	mov    0x805080,%eax
  801415:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80141b:	a1 84 50 80 00       	mov    0x805084,%eax
  801420:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <devfile_write>:
{
  801433:	f3 0f 1e fb          	endbr32 
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	83 ec 0c             	sub    $0xc,%esp
  80143d:	8b 45 10             	mov    0x10(%ebp),%eax
  801440:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801445:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80144a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80144d:	8b 55 08             	mov    0x8(%ebp),%edx
  801450:	8b 52 0c             	mov    0xc(%edx),%edx
  801453:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801459:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80145e:	50                   	push   %eax
  80145f:	ff 75 0c             	pushl  0xc(%ebp)
  801462:	68 08 50 80 00       	push   $0x805008
  801467:	e8 f3 f4 ff ff       	call   80095f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 04 00 00 00       	mov    $0x4,%eax
  801476:	e8 ba fe ff ff       	call   801335 <fsipc>
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_read>:
{
  80147d:	f3 0f 1e fb          	endbr32 
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
  801486:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	8b 40 0c             	mov    0xc(%eax),%eax
  80148f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801494:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80149a:	ba 00 00 00 00       	mov    $0x0,%edx
  80149f:	b8 03 00 00 00       	mov    $0x3,%eax
  8014a4:	e8 8c fe ff ff       	call   801335 <fsipc>
  8014a9:	89 c3                	mov    %eax,%ebx
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 1f                	js     8014ce <devfile_read+0x51>
	assert(r <= n);
  8014af:	39 f0                	cmp    %esi,%eax
  8014b1:	77 24                	ja     8014d7 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014b3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014b8:	7f 36                	jg     8014f0 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	50                   	push   %eax
  8014be:	68 00 50 80 00       	push   $0x805000
  8014c3:	ff 75 0c             	pushl  0xc(%ebp)
  8014c6:	e8 94 f4 ff ff       	call   80095f <memmove>
	return r;
  8014cb:	83 c4 10             	add    $0x10,%esp
}
  8014ce:	89 d8                	mov    %ebx,%eax
  8014d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    
	assert(r <= n);
  8014d7:	68 30 27 80 00       	push   $0x802730
  8014dc:	68 37 27 80 00       	push   $0x802737
  8014e1:	68 8c 00 00 00       	push   $0x8c
  8014e6:	68 4c 27 80 00       	push   $0x80274c
  8014eb:	e8 79 0a 00 00       	call   801f69 <_panic>
	assert(r <= PGSIZE);
  8014f0:	68 57 27 80 00       	push   $0x802757
  8014f5:	68 37 27 80 00       	push   $0x802737
  8014fa:	68 8d 00 00 00       	push   $0x8d
  8014ff:	68 4c 27 80 00       	push   $0x80274c
  801504:	e8 60 0a 00 00       	call   801f69 <_panic>

00801509 <open>:
{
  801509:	f3 0f 1e fb          	endbr32 
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	83 ec 1c             	sub    $0x1c,%esp
  801515:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801518:	56                   	push   %esi
  801519:	e8 00 f2 ff ff       	call   80071e <strlen>
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801526:	7f 6c                	jg     801594 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	e8 5c f8 ff ff       	call   800d90 <fd_alloc>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 3c                	js     801579 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80153d:	83 ec 08             	sub    $0x8,%esp
  801540:	56                   	push   %esi
  801541:	68 00 50 80 00       	push   $0x805000
  801546:	e8 16 f2 ff ff       	call   800761 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80154b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801553:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801556:	b8 01 00 00 00       	mov    $0x1,%eax
  80155b:	e8 d5 fd ff ff       	call   801335 <fsipc>
  801560:	89 c3                	mov    %eax,%ebx
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 19                	js     801582 <open+0x79>
	return fd2num(fd);
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	ff 75 f4             	pushl  -0xc(%ebp)
  80156f:	e8 ed f7 ff ff       	call   800d61 <fd2num>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	83 c4 10             	add    $0x10,%esp
}
  801579:	89 d8                	mov    %ebx,%eax
  80157b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    
		fd_close(fd, 0);
  801582:	83 ec 08             	sub    $0x8,%esp
  801585:	6a 00                	push   $0x0
  801587:	ff 75 f4             	pushl  -0xc(%ebp)
  80158a:	e8 0a f9 ff ff       	call   800e99 <fd_close>
		return r;
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	eb e5                	jmp    801579 <open+0x70>
		return -E_BAD_PATH;
  801594:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801599:	eb de                	jmp    801579 <open+0x70>

0080159b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80159b:	f3 0f 1e fb          	endbr32 
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8015af:	e8 81 fd ff ff       	call   801335 <fsipc>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015b6:	f3 0f 1e fb          	endbr32 
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015c0:	68 c3 27 80 00       	push   $0x8027c3
  8015c5:	ff 75 0c             	pushl  0xc(%ebp)
  8015c8:	e8 94 f1 ff ff       	call   800761 <strcpy>
	return 0;
}
  8015cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <devsock_close>:
{
  8015d4:	f3 0f 1e fb          	endbr32 
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 10             	sub    $0x10,%esp
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015e2:	53                   	push   %ebx
  8015e3:	e8 cd 0a 00 00       	call   8020b5 <pageref>
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	83 c4 10             	add    $0x10,%esp
		return 0;
  8015ed:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8015f2:	83 fa 01             	cmp    $0x1,%edx
  8015f5:	74 05                	je     8015fc <devsock_close+0x28>
}
  8015f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	ff 73 0c             	pushl  0xc(%ebx)
  801602:	e8 e3 02 00 00       	call   8018ea <nsipc_close>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb eb                	jmp    8015f7 <devsock_close+0x23>

0080160c <devsock_write>:
{
  80160c:	f3 0f 1e fb          	endbr32 
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801616:	6a 00                	push   $0x0
  801618:	ff 75 10             	pushl  0x10(%ebp)
  80161b:	ff 75 0c             	pushl  0xc(%ebp)
  80161e:	8b 45 08             	mov    0x8(%ebp),%eax
  801621:	ff 70 0c             	pushl  0xc(%eax)
  801624:	e8 b5 03 00 00       	call   8019de <nsipc_send>
}
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <devsock_read>:
{
  80162b:	f3 0f 1e fb          	endbr32 
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801635:	6a 00                	push   $0x0
  801637:	ff 75 10             	pushl  0x10(%ebp)
  80163a:	ff 75 0c             	pushl  0xc(%ebp)
  80163d:	8b 45 08             	mov    0x8(%ebp),%eax
  801640:	ff 70 0c             	pushl  0xc(%eax)
  801643:	e8 1f 03 00 00       	call   801967 <nsipc_recv>
}
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <fd2sockid>:
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801650:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801653:	52                   	push   %edx
  801654:	50                   	push   %eax
  801655:	e8 8c f7 ff ff       	call   800de6 <fd_lookup>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 10                	js     801671 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80166a:	39 08                	cmp    %ecx,(%eax)
  80166c:	75 05                	jne    801673 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80166e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    
		return -E_NOT_SUPP;
  801673:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801678:	eb f7                	jmp    801671 <fd2sockid+0x27>

0080167a <alloc_sockfd>:
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	56                   	push   %esi
  80167e:	53                   	push   %ebx
  80167f:	83 ec 1c             	sub    $0x1c,%esp
  801682:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801684:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801687:	50                   	push   %eax
  801688:	e8 03 f7 ff ff       	call   800d90 <fd_alloc>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 43                	js     8016d9 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801696:	83 ec 04             	sub    $0x4,%esp
  801699:	68 07 04 00 00       	push   $0x407
  80169e:	ff 75 f4             	pushl  -0xc(%ebp)
  8016a1:	6a 00                	push   $0x0
  8016a3:	e8 22 f5 ff ff       	call   800bca <sys_page_alloc>
  8016a8:	89 c3                	mov    %eax,%ebx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 28                	js     8016d9 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b4:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8016ba:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016c6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	50                   	push   %eax
  8016cd:	e8 8f f6 ff ff       	call   800d61 <fd2num>
  8016d2:	89 c3                	mov    %eax,%ebx
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	eb 0c                	jmp    8016e5 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8016d9:	83 ec 0c             	sub    $0xc,%esp
  8016dc:	56                   	push   %esi
  8016dd:	e8 08 02 00 00       	call   8018ea <nsipc_close>
		return r;
  8016e2:	83 c4 10             	add    $0x10,%esp
}
  8016e5:	89 d8                	mov    %ebx,%eax
  8016e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ea:	5b                   	pop    %ebx
  8016eb:	5e                   	pop    %esi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <accept>:
{
  8016ee:	f3 0f 1e fb          	endbr32 
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	e8 4a ff ff ff       	call   80164a <fd2sockid>
  801700:	85 c0                	test   %eax,%eax
  801702:	78 1b                	js     80171f <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801704:	83 ec 04             	sub    $0x4,%esp
  801707:	ff 75 10             	pushl  0x10(%ebp)
  80170a:	ff 75 0c             	pushl  0xc(%ebp)
  80170d:	50                   	push   %eax
  80170e:	e8 22 01 00 00       	call   801835 <nsipc_accept>
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	85 c0                	test   %eax,%eax
  801718:	78 05                	js     80171f <accept+0x31>
	return alloc_sockfd(r);
  80171a:	e8 5b ff ff ff       	call   80167a <alloc_sockfd>
}
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <bind>:
{
  801721:	f3 0f 1e fb          	endbr32 
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	e8 17 ff ff ff       	call   80164a <fd2sockid>
  801733:	85 c0                	test   %eax,%eax
  801735:	78 12                	js     801749 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 10             	pushl  0x10(%ebp)
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	50                   	push   %eax
  801741:	e8 45 01 00 00       	call   80188b <nsipc_bind>
  801746:	83 c4 10             	add    $0x10,%esp
}
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <shutdown>:
{
  80174b:	f3 0f 1e fb          	endbr32 
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	e8 ed fe ff ff       	call   80164a <fd2sockid>
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 0f                	js     801770 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	ff 75 0c             	pushl  0xc(%ebp)
  801767:	50                   	push   %eax
  801768:	e8 57 01 00 00       	call   8018c4 <nsipc_shutdown>
  80176d:	83 c4 10             	add    $0x10,%esp
}
  801770:	c9                   	leave  
  801771:	c3                   	ret    

00801772 <connect>:
{
  801772:	f3 0f 1e fb          	endbr32 
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	e8 c6 fe ff ff       	call   80164a <fd2sockid>
  801784:	85 c0                	test   %eax,%eax
  801786:	78 12                	js     80179a <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	ff 75 10             	pushl  0x10(%ebp)
  80178e:	ff 75 0c             	pushl  0xc(%ebp)
  801791:	50                   	push   %eax
  801792:	e8 71 01 00 00       	call   801908 <nsipc_connect>
  801797:	83 c4 10             	add    $0x10,%esp
}
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    

0080179c <listen>:
{
  80179c:	f3 0f 1e fb          	endbr32 
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a9:	e8 9c fe ff ff       	call   80164a <fd2sockid>
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 0f                	js     8017c1 <listen+0x25>
	return nsipc_listen(r, backlog);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	50                   	push   %eax
  8017b9:	e8 83 01 00 00       	call   801941 <nsipc_listen>
  8017be:	83 c4 10             	add    $0x10,%esp
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <socket>:

int
socket(int domain, int type, int protocol)
{
  8017c3:	f3 0f 1e fb          	endbr32 
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017cd:	ff 75 10             	pushl  0x10(%ebp)
  8017d0:	ff 75 0c             	pushl  0xc(%ebp)
  8017d3:	ff 75 08             	pushl  0x8(%ebp)
  8017d6:	e8 65 02 00 00       	call   801a40 <nsipc_socket>
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 05                	js     8017e7 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8017e2:	e8 93 fe ff ff       	call   80167a <alloc_sockfd>
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 04             	sub    $0x4,%esp
  8017f0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017f2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017f9:	74 26                	je     801821 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017fb:	6a 07                	push   $0x7
  8017fd:	68 00 60 80 00       	push   $0x806000
  801802:	53                   	push   %ebx
  801803:	ff 35 04 40 80 00    	pushl  0x804004
  801809:	e8 12 08 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80180e:	83 c4 0c             	add    $0xc,%esp
  801811:	6a 00                	push   $0x0
  801813:	6a 00                	push   $0x0
  801815:	6a 00                	push   $0x0
  801817:	e8 97 07 00 00       	call   801fb3 <ipc_recv>
}
  80181c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181f:	c9                   	leave  
  801820:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801821:	83 ec 0c             	sub    $0xc,%esp
  801824:	6a 02                	push   $0x2
  801826:	e8 4d 08 00 00       	call   802078 <ipc_find_env>
  80182b:	a3 04 40 80 00       	mov    %eax,0x804004
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	eb c6                	jmp    8017fb <nsipc+0x12>

00801835 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801835:	f3 0f 1e fb          	endbr32 
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801849:	8b 06                	mov    (%esi),%eax
  80184b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801850:	b8 01 00 00 00       	mov    $0x1,%eax
  801855:	e8 8f ff ff ff       	call   8017e9 <nsipc>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	85 c0                	test   %eax,%eax
  80185e:	79 09                	jns    801869 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801860:	89 d8                	mov    %ebx,%eax
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801869:	83 ec 04             	sub    $0x4,%esp
  80186c:	ff 35 10 60 80 00    	pushl  0x806010
  801872:	68 00 60 80 00       	push   $0x806000
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	e8 e0 f0 ff ff       	call   80095f <memmove>
		*addrlen = ret->ret_addrlen;
  80187f:	a1 10 60 80 00       	mov    0x806010,%eax
  801884:	89 06                	mov    %eax,(%esi)
  801886:	83 c4 10             	add    $0x10,%esp
	return r;
  801889:	eb d5                	jmp    801860 <nsipc_accept+0x2b>

0080188b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80188b:	f3 0f 1e fb          	endbr32 
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	53                   	push   %ebx
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801899:	8b 45 08             	mov    0x8(%ebp),%eax
  80189c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018a1:	53                   	push   %ebx
  8018a2:	ff 75 0c             	pushl  0xc(%ebp)
  8018a5:	68 04 60 80 00       	push   $0x806004
  8018aa:	e8 b0 f0 ff ff       	call   80095f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018af:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018b5:	b8 02 00 00 00       	mov    $0x2,%eax
  8018ba:	e8 2a ff ff ff       	call   8017e9 <nsipc>
}
  8018bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018c4:	f3 0f 1e fb          	endbr32 
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018de:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e3:	e8 01 ff ff ff       	call   8017e9 <nsipc>
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <nsipc_close>:

int
nsipc_close(int s)
{
  8018ea:	f3 0f 1e fb          	endbr32 
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801901:	e8 e3 fe ff ff       	call   8017e9 <nsipc>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801908:	f3 0f 1e fb          	endbr32 
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	53                   	push   %ebx
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80191e:	53                   	push   %ebx
  80191f:	ff 75 0c             	pushl  0xc(%ebp)
  801922:	68 04 60 80 00       	push   $0x806004
  801927:	e8 33 f0 ff ff       	call   80095f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80192c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801932:	b8 05 00 00 00       	mov    $0x5,%eax
  801937:	e8 ad fe ff ff       	call   8017e9 <nsipc>
}
  80193c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801941:	f3 0f 1e fb          	endbr32 
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80194b:	8b 45 08             	mov    0x8(%ebp),%eax
  80194e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801953:	8b 45 0c             	mov    0xc(%ebp),%eax
  801956:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80195b:	b8 06 00 00 00       	mov    $0x6,%eax
  801960:	e8 84 fe ff ff       	call   8017e9 <nsipc>
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801967:	f3 0f 1e fb          	endbr32 
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80197b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801989:	b8 07 00 00 00       	mov    $0x7,%eax
  80198e:	e8 56 fe ff ff       	call   8017e9 <nsipc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	85 c0                	test   %eax,%eax
  801997:	78 26                	js     8019bf <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801999:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  80199f:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019a4:	0f 4e c6             	cmovle %esi,%eax
  8019a7:	39 c3                	cmp    %eax,%ebx
  8019a9:	7f 1d                	jg     8019c8 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019ab:	83 ec 04             	sub    $0x4,%esp
  8019ae:	53                   	push   %ebx
  8019af:	68 00 60 80 00       	push   $0x806000
  8019b4:	ff 75 0c             	pushl  0xc(%ebp)
  8019b7:	e8 a3 ef ff ff       	call   80095f <memmove>
  8019bc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019bf:	89 d8                	mov    %ebx,%eax
  8019c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c4:	5b                   	pop    %ebx
  8019c5:	5e                   	pop    %esi
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019c8:	68 cf 27 80 00       	push   $0x8027cf
  8019cd:	68 37 27 80 00       	push   $0x802737
  8019d2:	6a 62                	push   $0x62
  8019d4:	68 e4 27 80 00       	push   $0x8027e4
  8019d9:	e8 8b 05 00 00       	call   801f69 <_panic>

008019de <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019de:	f3 0f 1e fb          	endbr32 
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	53                   	push   %ebx
  8019e6:	83 ec 04             	sub    $0x4,%esp
  8019e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8019f4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8019fa:	7f 2e                	jg     801a2a <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019fc:	83 ec 04             	sub    $0x4,%esp
  8019ff:	53                   	push   %ebx
  801a00:	ff 75 0c             	pushl  0xc(%ebp)
  801a03:	68 0c 60 80 00       	push   $0x80600c
  801a08:	e8 52 ef ff ff       	call   80095f <memmove>
	nsipcbuf.send.req_size = size;
  801a0d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a13:	8b 45 14             	mov    0x14(%ebp),%eax
  801a16:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a20:	e8 c4 fd ff ff       	call   8017e9 <nsipc>
}
  801a25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    
	assert(size < 1600);
  801a2a:	68 f0 27 80 00       	push   $0x8027f0
  801a2f:	68 37 27 80 00       	push   $0x802737
  801a34:	6a 6d                	push   $0x6d
  801a36:	68 e4 27 80 00       	push   $0x8027e4
  801a3b:	e8 29 05 00 00       	call   801f69 <_panic>

00801a40 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a40:	f3 0f 1e fb          	endbr32 
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a55:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a5a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a62:	b8 09 00 00 00       	mov    $0x9,%eax
  801a67:	e8 7d fd ff ff       	call   8017e9 <nsipc>
}
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a6e:	f3 0f 1e fb          	endbr32 
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	ff 75 08             	pushl  0x8(%ebp)
  801a80:	e8 f0 f2 ff ff       	call   800d75 <fd2data>
  801a85:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a87:	83 c4 08             	add    $0x8,%esp
  801a8a:	68 fc 27 80 00       	push   $0x8027fc
  801a8f:	53                   	push   %ebx
  801a90:	e8 cc ec ff ff       	call   800761 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a95:	8b 46 04             	mov    0x4(%esi),%eax
  801a98:	2b 06                	sub    (%esi),%eax
  801a9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aa0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aa7:	00 00 00 
	stat->st_dev = &devpipe;
  801aaa:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801ab1:	30 80 00 
	return 0;
}
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    

00801ac0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ac0:	f3 0f 1e fb          	endbr32 
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ace:	53                   	push   %ebx
  801acf:	6a 00                	push   $0x0
  801ad1:	e8 3f f1 ff ff       	call   800c15 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ad6:	89 1c 24             	mov    %ebx,(%esp)
  801ad9:	e8 97 f2 ff ff       	call   800d75 <fd2data>
  801ade:	83 c4 08             	add    $0x8,%esp
  801ae1:	50                   	push   %eax
  801ae2:	6a 00                	push   $0x0
  801ae4:	e8 2c f1 ff ff       	call   800c15 <sys_page_unmap>
}
  801ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <_pipeisclosed>:
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 1c             	sub    $0x1c,%esp
  801af7:	89 c7                	mov    %eax,%edi
  801af9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801afb:	a1 08 40 80 00       	mov    0x804008,%eax
  801b00:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	57                   	push   %edi
  801b07:	e8 a9 05 00 00       	call   8020b5 <pageref>
  801b0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b0f:	89 34 24             	mov    %esi,(%esp)
  801b12:	e8 9e 05 00 00       	call   8020b5 <pageref>
		nn = thisenv->env_runs;
  801b17:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	39 cb                	cmp    %ecx,%ebx
  801b25:	74 1b                	je     801b42 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b27:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b2a:	75 cf                	jne    801afb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b2c:	8b 42 58             	mov    0x58(%edx),%eax
  801b2f:	6a 01                	push   $0x1
  801b31:	50                   	push   %eax
  801b32:	53                   	push   %ebx
  801b33:	68 03 28 80 00       	push   $0x802803
  801b38:	e8 1a e6 ff ff       	call   800157 <cprintf>
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	eb b9                	jmp    801afb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b42:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b45:	0f 94 c0             	sete   %al
  801b48:	0f b6 c0             	movzbl %al,%eax
}
  801b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4e:	5b                   	pop    %ebx
  801b4f:	5e                   	pop    %esi
  801b50:	5f                   	pop    %edi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devpipe_write>:
{
  801b53:	f3 0f 1e fb          	endbr32 
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	57                   	push   %edi
  801b5b:	56                   	push   %esi
  801b5c:	53                   	push   %ebx
  801b5d:	83 ec 28             	sub    $0x28,%esp
  801b60:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b63:	56                   	push   %esi
  801b64:	e8 0c f2 ff ff       	call   800d75 <fd2data>
  801b69:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	bf 00 00 00 00       	mov    $0x0,%edi
  801b73:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b76:	74 4f                	je     801bc7 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b78:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7b:	8b 0b                	mov    (%ebx),%ecx
  801b7d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b80:	39 d0                	cmp    %edx,%eax
  801b82:	72 14                	jb     801b98 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b84:	89 da                	mov    %ebx,%edx
  801b86:	89 f0                	mov    %esi,%eax
  801b88:	e8 61 ff ff ff       	call   801aee <_pipeisclosed>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	75 3b                	jne    801bcc <devpipe_write+0x79>
			sys_yield();
  801b91:	e8 11 f0 ff ff       	call   800ba7 <sys_yield>
  801b96:	eb e0                	jmp    801b78 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b9f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ba2:	89 c2                	mov    %eax,%edx
  801ba4:	c1 fa 1f             	sar    $0x1f,%edx
  801ba7:	89 d1                	mov    %edx,%ecx
  801ba9:	c1 e9 1b             	shr    $0x1b,%ecx
  801bac:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801baf:	83 e2 1f             	and    $0x1f,%edx
  801bb2:	29 ca                	sub    %ecx,%edx
  801bb4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bb8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bbc:	83 c0 01             	add    $0x1,%eax
  801bbf:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bc2:	83 c7 01             	add    $0x1,%edi
  801bc5:	eb ac                	jmp    801b73 <devpipe_write+0x20>
	return i;
  801bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bca:	eb 05                	jmp    801bd1 <devpipe_write+0x7e>
				return 0;
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    

00801bd9 <devpipe_read>:
{
  801bd9:	f3 0f 1e fb          	endbr32 
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	57                   	push   %edi
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	83 ec 18             	sub    $0x18,%esp
  801be6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801be9:	57                   	push   %edi
  801bea:	e8 86 f1 ff ff       	call   800d75 <fd2data>
  801bef:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	be 00 00 00 00       	mov    $0x0,%esi
  801bf9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bfc:	75 14                	jne    801c12 <devpipe_read+0x39>
	return i;
  801bfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801c01:	eb 02                	jmp    801c05 <devpipe_read+0x2c>
				return i;
  801c03:	89 f0                	mov    %esi,%eax
}
  801c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5e                   	pop    %esi
  801c0a:	5f                   	pop    %edi
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    
			sys_yield();
  801c0d:	e8 95 ef ff ff       	call   800ba7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c12:	8b 03                	mov    (%ebx),%eax
  801c14:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c17:	75 18                	jne    801c31 <devpipe_read+0x58>
			if (i > 0)
  801c19:	85 f6                	test   %esi,%esi
  801c1b:	75 e6                	jne    801c03 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c1d:	89 da                	mov    %ebx,%edx
  801c1f:	89 f8                	mov    %edi,%eax
  801c21:	e8 c8 fe ff ff       	call   801aee <_pipeisclosed>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	74 e3                	je     801c0d <devpipe_read+0x34>
				return 0;
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2f:	eb d4                	jmp    801c05 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c31:	99                   	cltd   
  801c32:	c1 ea 1b             	shr    $0x1b,%edx
  801c35:	01 d0                	add    %edx,%eax
  801c37:	83 e0 1f             	and    $0x1f,%eax
  801c3a:	29 d0                	sub    %edx,%eax
  801c3c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c44:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c47:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c4a:	83 c6 01             	add    $0x1,%esi
  801c4d:	eb aa                	jmp    801bf9 <devpipe_read+0x20>

00801c4f <pipe>:
{
  801c4f:	f3 0f 1e fb          	endbr32 
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5e:	50                   	push   %eax
  801c5f:	e8 2c f1 ff ff       	call   800d90 <fd_alloc>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	0f 88 23 01 00 00    	js     801d94 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c71:	83 ec 04             	sub    $0x4,%esp
  801c74:	68 07 04 00 00       	push   $0x407
  801c79:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7c:	6a 00                	push   $0x0
  801c7e:	e8 47 ef ff ff       	call   800bca <sys_page_alloc>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 04 01 00 00    	js     801d94 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801c90:	83 ec 0c             	sub    $0xc,%esp
  801c93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c96:	50                   	push   %eax
  801c97:	e8 f4 f0 ff ff       	call   800d90 <fd_alloc>
  801c9c:	89 c3                	mov    %eax,%ebx
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	0f 88 db 00 00 00    	js     801d84 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca9:	83 ec 04             	sub    $0x4,%esp
  801cac:	68 07 04 00 00       	push   $0x407
  801cb1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 0f ef ff ff       	call   800bca <sys_page_alloc>
  801cbb:	89 c3                	mov    %eax,%ebx
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	0f 88 bc 00 00 00    	js     801d84 <pipe+0x135>
	va = fd2data(fd0);
  801cc8:	83 ec 0c             	sub    $0xc,%esp
  801ccb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cce:	e8 a2 f0 ff ff       	call   800d75 <fd2data>
  801cd3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd5:	83 c4 0c             	add    $0xc,%esp
  801cd8:	68 07 04 00 00       	push   $0x407
  801cdd:	50                   	push   %eax
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 e5 ee ff ff       	call   800bca <sys_page_alloc>
  801ce5:	89 c3                	mov    %eax,%ebx
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	0f 88 82 00 00 00    	js     801d74 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf8:	e8 78 f0 ff ff       	call   800d75 <fd2data>
  801cfd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d04:	50                   	push   %eax
  801d05:	6a 00                	push   $0x0
  801d07:	56                   	push   %esi
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 e1 ee ff ff       	call   800bf0 <sys_page_map>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	83 c4 20             	add    $0x20,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	78 4e                	js     801d66 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d18:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d20:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d25:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d2f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d3b:	83 ec 0c             	sub    $0xc,%esp
  801d3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d41:	e8 1b f0 ff ff       	call   800d61 <fd2num>
  801d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d4b:	83 c4 04             	add    $0x4,%esp
  801d4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d51:	e8 0b f0 ff ff       	call   800d61 <fd2num>
  801d56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d59:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d64:	eb 2e                	jmp    801d94 <pipe+0x145>
	sys_page_unmap(0, va);
  801d66:	83 ec 08             	sub    $0x8,%esp
  801d69:	56                   	push   %esi
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 a4 ee ff ff       	call   800c15 <sys_page_unmap>
  801d71:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d74:	83 ec 08             	sub    $0x8,%esp
  801d77:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 94 ee ff ff       	call   800c15 <sys_page_unmap>
  801d81:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d84:	83 ec 08             	sub    $0x8,%esp
  801d87:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8a:	6a 00                	push   $0x0
  801d8c:	e8 84 ee ff ff       	call   800c15 <sys_page_unmap>
  801d91:	83 c4 10             	add    $0x10,%esp
}
  801d94:	89 d8                	mov    %ebx,%eax
  801d96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <pipeisclosed>:
{
  801d9d:	f3 0f 1e fb          	endbr32 
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	ff 75 08             	pushl  0x8(%ebp)
  801dae:	e8 33 f0 ff ff       	call   800de6 <fd_lookup>
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 18                	js     801dd2 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc0:	e8 b0 ef ff ff       	call   800d75 <fd2data>
  801dc5:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dca:	e8 1f fd ff ff       	call   801aee <_pipeisclosed>
  801dcf:	83 c4 10             	add    $0x10,%esp
}
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dd4:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801dd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddd:	c3                   	ret    

00801dde <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dde:	f3 0f 1e fb          	endbr32 
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801de8:	68 1b 28 80 00       	push   $0x80281b
  801ded:	ff 75 0c             	pushl  0xc(%ebp)
  801df0:	e8 6c e9 ff ff       	call   800761 <strcpy>
	return 0;
}
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <devcons_write>:
{
  801dfc:	f3 0f 1e fb          	endbr32 
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	57                   	push   %edi
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e0c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e11:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1a:	73 31                	jae    801e4d <devcons_write+0x51>
		m = n - tot;
  801e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e1f:	29 f3                	sub    %esi,%ebx
  801e21:	83 fb 7f             	cmp    $0x7f,%ebx
  801e24:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e29:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e2c:	83 ec 04             	sub    $0x4,%esp
  801e2f:	53                   	push   %ebx
  801e30:	89 f0                	mov    %esi,%eax
  801e32:	03 45 0c             	add    0xc(%ebp),%eax
  801e35:	50                   	push   %eax
  801e36:	57                   	push   %edi
  801e37:	e8 23 eb ff ff       	call   80095f <memmove>
		sys_cputs(buf, m);
  801e3c:	83 c4 08             	add    $0x8,%esp
  801e3f:	53                   	push   %ebx
  801e40:	57                   	push   %edi
  801e41:	e8 d5 ec ff ff       	call   800b1b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e46:	01 de                	add    %ebx,%esi
  801e48:	83 c4 10             	add    $0x10,%esp
  801e4b:	eb ca                	jmp    801e17 <devcons_write+0x1b>
}
  801e4d:	89 f0                	mov    %esi,%eax
  801e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <devcons_read>:
{
  801e57:	f3 0f 1e fb          	endbr32 
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 08             	sub    $0x8,%esp
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e6a:	74 21                	je     801e8d <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e6c:	e8 cc ec ff ff       	call   800b3d <sys_cgetc>
  801e71:	85 c0                	test   %eax,%eax
  801e73:	75 07                	jne    801e7c <devcons_read+0x25>
		sys_yield();
  801e75:	e8 2d ed ff ff       	call   800ba7 <sys_yield>
  801e7a:	eb f0                	jmp    801e6c <devcons_read+0x15>
	if (c < 0)
  801e7c:	78 0f                	js     801e8d <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e7e:	83 f8 04             	cmp    $0x4,%eax
  801e81:	74 0c                	je     801e8f <devcons_read+0x38>
	*(char*)vbuf = c;
  801e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e86:	88 02                	mov    %al,(%edx)
	return 1;
  801e88:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    
		return 0;
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e94:	eb f7                	jmp    801e8d <devcons_read+0x36>

00801e96 <cputchar>:
{
  801e96:	f3 0f 1e fb          	endbr32 
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ea6:	6a 01                	push   $0x1
  801ea8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	e8 6a ec ff ff       	call   800b1b <sys_cputs>
}
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <getchar>:
{
  801eb6:	f3 0f 1e fb          	endbr32 
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ec0:	6a 01                	push   $0x1
  801ec2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	6a 00                	push   $0x0
  801ec8:	e8 a1 f1 ff ff       	call   80106e <read>
	if (r < 0)
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	78 06                	js     801eda <getchar+0x24>
	if (r < 1)
  801ed4:	74 06                	je     801edc <getchar+0x26>
	return c;
  801ed6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    
		return -E_EOF;
  801edc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ee1:	eb f7                	jmp    801eda <getchar+0x24>

00801ee3 <iscons>:
{
  801ee3:	f3 0f 1e fb          	endbr32 
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef0:	50                   	push   %eax
  801ef1:	ff 75 08             	pushl  0x8(%ebp)
  801ef4:	e8 ed ee ff ff       	call   800de6 <fd_lookup>
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 11                	js     801f11 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f03:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f09:	39 10                	cmp    %edx,(%eax)
  801f0b:	0f 94 c0             	sete   %al
  801f0e:	0f b6 c0             	movzbl %al,%eax
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <opencons>:
{
  801f13:	f3 0f 1e fb          	endbr32 
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f20:	50                   	push   %eax
  801f21:	e8 6a ee ff ff       	call   800d90 <fd_alloc>
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 3a                	js     801f67 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f2d:	83 ec 04             	sub    $0x4,%esp
  801f30:	68 07 04 00 00       	push   $0x407
  801f35:	ff 75 f4             	pushl  -0xc(%ebp)
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 8b ec ff ff       	call   800bca <sys_page_alloc>
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 c0                	test   %eax,%eax
  801f44:	78 21                	js     801f67 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f49:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f4f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f54:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	50                   	push   %eax
  801f5f:	e8 fd ed ff ff       	call   800d61 <fd2num>
  801f64:	83 c4 10             	add    $0x10,%esp
}
  801f67:	c9                   	leave  
  801f68:	c3                   	ret    

00801f69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f69:	f3 0f 1e fb          	endbr32 
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	56                   	push   %esi
  801f71:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f72:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f75:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f7b:	e8 04 ec ff ff       	call   800b84 <sys_getenvid>
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	ff 75 0c             	pushl  0xc(%ebp)
  801f86:	ff 75 08             	pushl  0x8(%ebp)
  801f89:	56                   	push   %esi
  801f8a:	50                   	push   %eax
  801f8b:	68 28 28 80 00       	push   $0x802828
  801f90:	e8 c2 e1 ff ff       	call   800157 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f95:	83 c4 18             	add    $0x18,%esp
  801f98:	53                   	push   %ebx
  801f99:	ff 75 10             	pushl  0x10(%ebp)
  801f9c:	e8 61 e1 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801fa1:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  801fa8:	e8 aa e1 ff ff       	call   800157 <cprintf>
  801fad:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fb0:	cc                   	int3   
  801fb1:	eb fd                	jmp    801fb0 <_panic+0x47>

00801fb3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb3:	f3 0f 1e fb          	endbr32 
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	56                   	push   %esi
  801fbb:	53                   	push   %ebx
  801fbc:	8b 75 08             	mov    0x8(%ebp),%esi
  801fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fcc:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	50                   	push   %eax
  801fd3:	e8 f8 ec ff ff       	call   800cd0 <sys_ipc_recv>
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	75 2b                	jne    80200a <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801fdf:	85 f6                	test   %esi,%esi
  801fe1:	74 0a                	je     801fed <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801fe3:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe8:	8b 40 74             	mov    0x74(%eax),%eax
  801feb:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801fed:	85 db                	test   %ebx,%ebx
  801fef:	74 0a                	je     801ffb <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801ff1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff6:	8b 40 78             	mov    0x78(%eax),%eax
  801ff9:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801ffb:	a1 08 40 80 00       	mov    0x804008,%eax
  802000:	8b 40 70             	mov    0x70(%eax),%eax
}
  802003:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80200a:	85 f6                	test   %esi,%esi
  80200c:	74 06                	je     802014 <ipc_recv+0x61>
  80200e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802014:	85 db                	test   %ebx,%ebx
  802016:	74 eb                	je     802003 <ipc_recv+0x50>
  802018:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80201e:	eb e3                	jmp    802003 <ipc_recv+0x50>

00802020 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802020:	f3 0f 1e fb          	endbr32 
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	57                   	push   %edi
  802028:	56                   	push   %esi
  802029:	53                   	push   %ebx
  80202a:	83 ec 0c             	sub    $0xc,%esp
  80202d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802030:	8b 75 0c             	mov    0xc(%ebp),%esi
  802033:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802036:	85 db                	test   %ebx,%ebx
  802038:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80203d:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802040:	ff 75 14             	pushl  0x14(%ebp)
  802043:	53                   	push   %ebx
  802044:	56                   	push   %esi
  802045:	57                   	push   %edi
  802046:	e8 5e ec ff ff       	call   800ca9 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802051:	75 07                	jne    80205a <ipc_send+0x3a>
			sys_yield();
  802053:	e8 4f eb ff ff       	call   800ba7 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802058:	eb e6                	jmp    802040 <ipc_send+0x20>
		}
		else if (ret == 0)
  80205a:	85 c0                	test   %eax,%eax
  80205c:	75 08                	jne    802066 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80205e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802066:	50                   	push   %eax
  802067:	68 4b 28 80 00       	push   $0x80284b
  80206c:	6a 48                	push   $0x48
  80206e:	68 59 28 80 00       	push   $0x802859
  802073:	e8 f1 fe ff ff       	call   801f69 <_panic>

00802078 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802078:	f3 0f 1e fb          	endbr32 
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802082:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802087:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80208a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802090:	8b 52 50             	mov    0x50(%edx),%edx
  802093:	39 ca                	cmp    %ecx,%edx
  802095:	74 11                	je     8020a8 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802097:	83 c0 01             	add    $0x1,%eax
  80209a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209f:	75 e6                	jne    802087 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a6:	eb 0b                	jmp    8020b3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020b3:	5d                   	pop    %ebp
  8020b4:	c3                   	ret    

008020b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b5:	f3 0f 1e fb          	endbr32 
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020bf:	89 c2                	mov    %eax,%edx
  8020c1:	c1 ea 16             	shr    $0x16,%edx
  8020c4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020cb:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020d0:	f6 c1 01             	test   $0x1,%cl
  8020d3:	74 1c                	je     8020f1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020d5:	c1 e8 0c             	shr    $0xc,%eax
  8020d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020df:	a8 01                	test   $0x1,%al
  8020e1:	74 0e                	je     8020f1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020e3:	c1 e8 0c             	shr    $0xc,%eax
  8020e6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8020ed:	ef 
  8020ee:	0f b7 d2             	movzwl %dx,%edx
}
  8020f1:	89 d0                	mov    %edx,%eax
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
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
