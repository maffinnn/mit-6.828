
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800040:	8b 42 04             	mov    0x4(%edx),%eax
  800043:	83 e0 07             	and    $0x7,%eax
  800046:	50                   	push   %eax
  800047:	ff 32                	pushl  (%edx)
  800049:	68 40 24 80 00       	push   $0x802440
  80004e:	e8 3a 01 00 00       	call   80018d <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 62 0b 00 00       	call   800bba <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 36 0b 00 00       	call   800b96 <sys_env_destroy>
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <umain>:

void
umain(int argc, char **argv)
{
  800065:	f3 0f 1e fb          	endbr32 
  800069:	55                   	push   %ebp
  80006a:	89 e5                	mov    %esp,%ebp
  80006c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80006f:	68 33 00 80 00       	push   $0x800033
  800074:	e8 1e 0d 00 00       	call   800d97 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800079:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800080:	00 00 00 
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800094:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800097:	e8 1e 0b 00 00       	call   800bba <sys_getenvid>
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a9:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	85 db                	test   %ebx,%ebx
  8000b0:	7e 07                	jle    8000b9 <libmain+0x31>
		binaryname = argv[0];
  8000b2:	8b 06                	mov    (%esi),%eax
  8000b4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  8000be:	e8 a2 ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000c3:	e8 0a 00 00 00       	call   8000d2 <exit>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000dc:	e8 41 0f 00 00       	call   801022 <close_all>
	sys_env_destroy(0);
  8000e1:	83 ec 0c             	sub    $0xc,%esp
  8000e4:	6a 00                	push   $0x0
  8000e6:	e8 ab 0a 00 00       	call   800b96 <sys_env_destroy>
}
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f0:	f3 0f 1e fb          	endbr32 
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	53                   	push   %ebx
  8000f8:	83 ec 04             	sub    $0x4,%esp
  8000fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fe:	8b 13                	mov    (%ebx),%edx
  800100:	8d 42 01             	lea    0x1(%edx),%eax
  800103:	89 03                	mov    %eax,(%ebx)
  800105:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800108:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800111:	74 09                	je     80011c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800113:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011a:	c9                   	leave  
  80011b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	68 ff 00 00 00       	push   $0xff
  800124:	8d 43 08             	lea    0x8(%ebx),%eax
  800127:	50                   	push   %eax
  800128:	e8 24 0a 00 00       	call   800b51 <sys_cputs>
		b->idx = 0;
  80012d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	eb db                	jmp    800113 <putch+0x23>

00800138 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800138:	f3 0f 1e fb          	endbr32 
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 f0 00 80 00       	push   $0x8000f0
  80016b:	e8 20 01 00 00       	call   800290 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 cc 09 00 00       	call   800b51 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	f3 0f 1e fb          	endbr32 
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	50                   	push   %eax
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	e8 95 ff ff ff       	call   800138 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 1c             	sub    $0x1c,%esp
  8001ae:	89 c7                	mov    %eax,%edi
  8001b0:	89 d6                	mov    %edx,%esi
  8001b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b8:	89 d1                	mov    %edx,%ecx
  8001ba:	89 c2                	mov    %eax,%edx
  8001bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8001c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d2:	39 c2                	cmp    %eax,%edx
  8001d4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d7:	72 3e                	jb     800217 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d9:	83 ec 0c             	sub    $0xc,%esp
  8001dc:	ff 75 18             	pushl  0x18(%ebp)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	53                   	push   %ebx
  8001e3:	50                   	push   %eax
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f3:	e8 d8 1f 00 00       	call   8021d0 <__udivdi3>
  8001f8:	83 c4 18             	add    $0x18,%esp
  8001fb:	52                   	push   %edx
  8001fc:	50                   	push   %eax
  8001fd:	89 f2                	mov    %esi,%edx
  8001ff:	89 f8                	mov    %edi,%eax
  800201:	e8 9f ff ff ff       	call   8001a5 <printnum>
  800206:	83 c4 20             	add    $0x20,%esp
  800209:	eb 13                	jmp    80021e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	56                   	push   %esi
  80020f:	ff 75 18             	pushl  0x18(%ebp)
  800212:	ff d7                	call   *%edi
  800214:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800217:	83 eb 01             	sub    $0x1,%ebx
  80021a:	85 db                	test   %ebx,%ebx
  80021c:	7f ed                	jg     80020b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021e:	83 ec 08             	sub    $0x8,%esp
  800221:	56                   	push   %esi
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	ff 75 e4             	pushl  -0x1c(%ebp)
  800228:	ff 75 e0             	pushl  -0x20(%ebp)
  80022b:	ff 75 dc             	pushl  -0x24(%ebp)
  80022e:	ff 75 d8             	pushl  -0x28(%ebp)
  800231:	e8 aa 20 00 00       	call   8022e0 <__umoddi3>
  800236:	83 c4 14             	add    $0x14,%esp
  800239:	0f be 80 66 24 80 00 	movsbl 0x802466(%eax),%eax
  800240:	50                   	push   %eax
  800241:	ff d7                	call   *%edi
}
  800243:	83 c4 10             	add    $0x10,%esp
  800246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	f3 0f 1e fb          	endbr32 
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800258:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	3b 50 04             	cmp    0x4(%eax),%edx
  800261:	73 0a                	jae    80026d <sprintputch+0x1f>
		*b->buf++ = ch;
  800263:	8d 4a 01             	lea    0x1(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	88 02                	mov    %al,(%edx)
}
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <printfmt>:
{
  80026f:	f3 0f 1e fb          	endbr32 
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800279:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027c:	50                   	push   %eax
  80027d:	ff 75 10             	pushl  0x10(%ebp)
  800280:	ff 75 0c             	pushl  0xc(%ebp)
  800283:	ff 75 08             	pushl  0x8(%ebp)
  800286:	e8 05 00 00 00       	call   800290 <vprintfmt>
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <vprintfmt>:
{
  800290:	f3 0f 1e fb          	endbr32 
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 3c             	sub    $0x3c,%esp
  80029d:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a6:	e9 8e 03 00 00       	jmp    800639 <vprintfmt+0x3a9>
		padc = ' ';
  8002ab:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002af:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002bd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cf:	0f b6 17             	movzbl (%edi),%edx
  8002d2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d5:	3c 55                	cmp    $0x55,%al
  8002d7:	0f 87 df 03 00 00    	ja     8006bc <vprintfmt+0x42c>
  8002dd:	0f b6 c0             	movzbl %al,%eax
  8002e0:	3e ff 24 85 a0 25 80 	notrack jmp *0x8025a0(,%eax,4)
  8002e7:	00 
  8002e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002eb:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002ef:	eb d8                	jmp    8002c9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002f8:	eb cf                	jmp    8002c9 <vprintfmt+0x39>
  8002fa:	0f b6 d2             	movzbl %dl,%edx
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800300:	b8 00 00 00 00       	mov    $0x0,%eax
  800305:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800308:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800312:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800315:	83 f9 09             	cmp    $0x9,%ecx
  800318:	77 55                	ja     80036f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80031a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80031d:	eb e9                	jmp    800308 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8b 00                	mov    (%eax),%eax
  800324:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800327:	8b 45 14             	mov    0x14(%ebp),%eax
  80032a:	8d 40 04             	lea    0x4(%eax),%eax
  80032d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800333:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800337:	79 90                	jns    8002c9 <vprintfmt+0x39>
				width = precision, precision = -1;
  800339:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80033c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800346:	eb 81                	jmp    8002c9 <vprintfmt+0x39>
  800348:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034b:	85 c0                	test   %eax,%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	0f 49 d0             	cmovns %eax,%edx
  800355:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80035b:	e9 69 ff ff ff       	jmp    8002c9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800363:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80036a:	e9 5a ff ff ff       	jmp    8002c9 <vprintfmt+0x39>
  80036f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800372:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800375:	eb bc                	jmp    800333 <vprintfmt+0xa3>
			lflag++;
  800377:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037d:	e9 47 ff ff ff       	jmp    8002c9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800382:	8b 45 14             	mov    0x14(%ebp),%eax
  800385:	8d 78 04             	lea    0x4(%eax),%edi
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	53                   	push   %ebx
  80038c:	ff 30                	pushl  (%eax)
  80038e:	ff d6                	call   *%esi
			break;
  800390:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800393:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800396:	e9 9b 02 00 00       	jmp    800636 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 78 04             	lea    0x4(%eax),%edi
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	99                   	cltd   
  8003a4:	31 d0                	xor    %edx,%eax
  8003a6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a8:	83 f8 0f             	cmp    $0xf,%eax
  8003ab:	7f 23                	jg     8003d0 <vprintfmt+0x140>
  8003ad:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8003b4:	85 d2                	test   %edx,%edx
  8003b6:	74 18                	je     8003d0 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003b8:	52                   	push   %edx
  8003b9:	68 79 28 80 00       	push   $0x802879
  8003be:	53                   	push   %ebx
  8003bf:	56                   	push   %esi
  8003c0:	e8 aa fe ff ff       	call   80026f <printfmt>
  8003c5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003cb:	e9 66 02 00 00       	jmp    800636 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003d0:	50                   	push   %eax
  8003d1:	68 7e 24 80 00       	push   $0x80247e
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 92 fe ff ff       	call   80026f <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003e3:	e9 4e 02 00 00       	jmp    800636 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	83 c0 04             	add    $0x4,%eax
  8003ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	b8 77 24 80 00       	mov    $0x802477,%eax
  8003fd:	0f 45 c2             	cmovne %edx,%eax
  800400:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800403:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800407:	7e 06                	jle    80040f <vprintfmt+0x17f>
  800409:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80040d:	75 0d                	jne    80041c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800412:	89 c7                	mov    %eax,%edi
  800414:	03 45 e0             	add    -0x20(%ebp),%eax
  800417:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041a:	eb 55                	jmp    800471 <vprintfmt+0x1e1>
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	ff 75 d8             	pushl  -0x28(%ebp)
  800422:	ff 75 cc             	pushl  -0x34(%ebp)
  800425:	e8 46 03 00 00       	call   800770 <strnlen>
  80042a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80042d:	29 c2                	sub    %eax,%edx
  80042f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800432:	83 c4 10             	add    $0x10,%esp
  800435:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800437:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80043b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80043e:	85 ff                	test   %edi,%edi
  800440:	7e 11                	jle    800453 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	ff 75 e0             	pushl  -0x20(%ebp)
  800449:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ef 01             	sub    $0x1,%edi
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	eb eb                	jmp    80043e <vprintfmt+0x1ae>
  800453:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800456:	85 d2                	test   %edx,%edx
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	0f 49 c2             	cmovns %edx,%eax
  800460:	29 c2                	sub    %eax,%edx
  800462:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800465:	eb a8                	jmp    80040f <vprintfmt+0x17f>
					putch(ch, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	52                   	push   %edx
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800474:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800476:	83 c7 01             	add    $0x1,%edi
  800479:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80047d:	0f be d0             	movsbl %al,%edx
  800480:	85 d2                	test   %edx,%edx
  800482:	74 4b                	je     8004cf <vprintfmt+0x23f>
  800484:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800488:	78 06                	js     800490 <vprintfmt+0x200>
  80048a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80048e:	78 1e                	js     8004ae <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800490:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800494:	74 d1                	je     800467 <vprintfmt+0x1d7>
  800496:	0f be c0             	movsbl %al,%eax
  800499:	83 e8 20             	sub    $0x20,%eax
  80049c:	83 f8 5e             	cmp    $0x5e,%eax
  80049f:	76 c6                	jbe    800467 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	53                   	push   %ebx
  8004a5:	6a 3f                	push   $0x3f
  8004a7:	ff d6                	call   *%esi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	eb c3                	jmp    800471 <vprintfmt+0x1e1>
  8004ae:	89 cf                	mov    %ecx,%edi
  8004b0:	eb 0e                	jmp    8004c0 <vprintfmt+0x230>
				putch(' ', putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	6a 20                	push   $0x20
  8004b8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ba:	83 ef 01             	sub    $0x1,%edi
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	85 ff                	test   %edi,%edi
  8004c2:	7f ee                	jg     8004b2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ca:	e9 67 01 00 00       	jmp    800636 <vprintfmt+0x3a6>
  8004cf:	89 cf                	mov    %ecx,%edi
  8004d1:	eb ed                	jmp    8004c0 <vprintfmt+0x230>
	if (lflag >= 2)
  8004d3:	83 f9 01             	cmp    $0x1,%ecx
  8004d6:	7f 1b                	jg     8004f3 <vprintfmt+0x263>
	else if (lflag)
  8004d8:	85 c9                	test   %ecx,%ecx
  8004da:	74 63                	je     80053f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e4:	99                   	cltd   
  8004e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 40 04             	lea    0x4(%eax),%eax
  8004ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f1:	eb 17                	jmp    80050a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8b 50 04             	mov    0x4(%eax),%edx
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 40 08             	lea    0x8(%eax),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80050a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80050d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800510:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800515:	85 c9                	test   %ecx,%ecx
  800517:	0f 89 ff 00 00 00    	jns    80061c <vprintfmt+0x38c>
				putch('-', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	6a 2d                	push   $0x2d
  800523:	ff d6                	call   *%esi
				num = -(long long) num;
  800525:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800528:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052b:	f7 da                	neg    %edx
  80052d:	83 d1 00             	adc    $0x0,%ecx
  800530:	f7 d9                	neg    %ecx
  800532:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800535:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053a:	e9 dd 00 00 00       	jmp    80061c <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800547:	99                   	cltd   
  800548:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 40 04             	lea    0x4(%eax),%eax
  800551:	89 45 14             	mov    %eax,0x14(%ebp)
  800554:	eb b4                	jmp    80050a <vprintfmt+0x27a>
	if (lflag >= 2)
  800556:	83 f9 01             	cmp    $0x1,%ecx
  800559:	7f 1e                	jg     800579 <vprintfmt+0x2e9>
	else if (lflag)
  80055b:	85 c9                	test   %ecx,%ecx
  80055d:	74 32                	je     800591 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 10                	mov    (%eax),%edx
  800564:	b9 00 00 00 00       	mov    $0x0,%ecx
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800574:	e9 a3 00 00 00       	jmp    80061c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 10                	mov    (%eax),%edx
  80057e:	8b 48 04             	mov    0x4(%eax),%ecx
  800581:	8d 40 08             	lea    0x8(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80058c:	e9 8b 00 00 00       	jmp    80061c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 10                	mov    (%eax),%edx
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059b:	8d 40 04             	lea    0x4(%eax),%eax
  80059e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005a6:	eb 74                	jmp    80061c <vprintfmt+0x38c>
	if (lflag >= 2)
  8005a8:	83 f9 01             	cmp    $0x1,%ecx
  8005ab:	7f 1b                	jg     8005c8 <vprintfmt+0x338>
	else if (lflag)
  8005ad:	85 c9                	test   %ecx,%ecx
  8005af:	74 2c                	je     8005dd <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 10                	mov    (%eax),%edx
  8005b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005c1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005c6:	eb 54                	jmp    80061c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d0:	8d 40 08             	lea    0x8(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005d6:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005db:	eb 3f                	jmp    80061c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ed:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005f2:	eb 28                	jmp    80061c <vprintfmt+0x38c>
			putch('0', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 30                	push   $0x30
  8005fa:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fc:	83 c4 08             	add    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 78                	push   $0x78
  800602:	ff d6                	call   *%esi
			num = (unsigned long long)
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80060e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80061c:	83 ec 0c             	sub    $0xc,%esp
  80061f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800623:	57                   	push   %edi
  800624:	ff 75 e0             	pushl  -0x20(%ebp)
  800627:	50                   	push   %eax
  800628:	51                   	push   %ecx
  800629:	52                   	push   %edx
  80062a:	89 da                	mov    %ebx,%edx
  80062c:	89 f0                	mov    %esi,%eax
  80062e:	e8 72 fb ff ff       	call   8001a5 <printnum>
			break;
  800633:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800640:	83 f8 25             	cmp    $0x25,%eax
  800643:	0f 84 62 fc ff ff    	je     8002ab <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800649:	85 c0                	test   %eax,%eax
  80064b:	0f 84 8b 00 00 00    	je     8006dc <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	50                   	push   %eax
  800656:	ff d6                	call   *%esi
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	eb dc                	jmp    800639 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80065d:	83 f9 01             	cmp    $0x1,%ecx
  800660:	7f 1b                	jg     80067d <vprintfmt+0x3ed>
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 2c                	je     800692 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800676:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80067b:	eb 9f                	jmp    80061c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8b 48 04             	mov    0x4(%eax),%ecx
  800685:	8d 40 08             	lea    0x8(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800690:	eb 8a                	jmp    80061c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006a7:	e9 70 ff ff ff       	jmp    80061c <vprintfmt+0x38c>
			putch(ch, putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 25                	push   $0x25
  8006b2:	ff d6                	call   *%esi
			break;
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	e9 7a ff ff ff       	jmp    800636 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 f8                	mov    %edi,%eax
  8006c9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006cd:	74 05                	je     8006d4 <vprintfmt+0x444>
  8006cf:	83 e8 01             	sub    $0x1,%eax
  8006d2:	eb f5                	jmp    8006c9 <vprintfmt+0x439>
  8006d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d7:	e9 5a ff ff ff       	jmp    800636 <vprintfmt+0x3a6>
}
  8006dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5f                   	pop    %edi
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	f3 0f 1e fb          	endbr32 
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 18             	sub    $0x18,%esp
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800705:	85 c0                	test   %eax,%eax
  800707:	74 26                	je     80072f <vsnprintf+0x4b>
  800709:	85 d2                	test   %edx,%edx
  80070b:	7e 22                	jle    80072f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070d:	ff 75 14             	pushl  0x14(%ebp)
  800710:	ff 75 10             	pushl  0x10(%ebp)
  800713:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800716:	50                   	push   %eax
  800717:	68 4e 02 80 00       	push   $0x80024e
  80071c:	e8 6f fb ff ff       	call   800290 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800721:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800724:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072a:	83 c4 10             	add    $0x10,%esp
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    
		return -E_INVAL;
  80072f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800734:	eb f7                	jmp    80072d <vsnprintf+0x49>

00800736 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800736:	f3 0f 1e fb          	endbr32 
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800743:	50                   	push   %eax
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	ff 75 08             	pushl  0x8(%ebp)
  80074d:	e8 92 ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800754:	f3 0f 1e fb          	endbr32 
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800767:	74 05                	je     80076e <strlen+0x1a>
		n++;
  800769:	83 c0 01             	add    $0x1,%eax
  80076c:	eb f5                	jmp    800763 <strlen+0xf>
	return n;
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	f3 0f 1e fb          	endbr32 
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
  800782:	39 d0                	cmp    %edx,%eax
  800784:	74 0d                	je     800793 <strnlen+0x23>
  800786:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078a:	74 05                	je     800791 <strnlen+0x21>
		n++;
  80078c:	83 c0 01             	add    $0x1,%eax
  80078f:	eb f1                	jmp    800782 <strnlen+0x12>
  800791:	89 c2                	mov    %eax,%edx
	return n;
}
  800793:	89 d0                	mov    %edx,%eax
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	f3 0f 1e fb          	endbr32 
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007ae:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007b1:	83 c0 01             	add    $0x1,%eax
  8007b4:	84 d2                	test   %dl,%dl
  8007b6:	75 f2                	jne    8007aa <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007b8:	89 c8                	mov    %ecx,%eax
  8007ba:	5b                   	pop    %ebx
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bd:	f3 0f 1e fb          	endbr32 
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	53                   	push   %ebx
  8007c5:	83 ec 10             	sub    $0x10,%esp
  8007c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cb:	53                   	push   %ebx
  8007cc:	e8 83 ff ff ff       	call   800754 <strlen>
  8007d1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007d4:	ff 75 0c             	pushl  0xc(%ebp)
  8007d7:	01 d8                	add    %ebx,%eax
  8007d9:	50                   	push   %eax
  8007da:	e8 b8 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e6:	f3 0f 1e fb          	endbr32 
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 f3                	mov    %esi,%ebx
  8007f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fa:	89 f0                	mov    %esi,%eax
  8007fc:	39 d8                	cmp    %ebx,%eax
  8007fe:	74 11                	je     800811 <strncpy+0x2b>
		*dst++ = *src;
  800800:	83 c0 01             	add    $0x1,%eax
  800803:	0f b6 0a             	movzbl (%edx),%ecx
  800806:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800809:	80 f9 01             	cmp    $0x1,%cl
  80080c:	83 da ff             	sbb    $0xffffffff,%edx
  80080f:	eb eb                	jmp    8007fc <strncpy+0x16>
	}
	return ret;
}
  800811:	89 f0                	mov    %esi,%eax
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	8b 55 10             	mov    0x10(%ebp),%edx
  800829:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 21                	je     800850 <strlcpy+0x39>
  80082f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800833:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800835:	39 c2                	cmp    %eax,%edx
  800837:	74 14                	je     80084d <strlcpy+0x36>
  800839:	0f b6 19             	movzbl (%ecx),%ebx
  80083c:	84 db                	test   %bl,%bl
  80083e:	74 0b                	je     80084b <strlcpy+0x34>
			*dst++ = *src++;
  800840:	83 c1 01             	add    $0x1,%ecx
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	88 5a ff             	mov    %bl,-0x1(%edx)
  800849:	eb ea                	jmp    800835 <strlcpy+0x1e>
  80084b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80084d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	f3 0f 1e fb          	endbr32 
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800863:	0f b6 01             	movzbl (%ecx),%eax
  800866:	84 c0                	test   %al,%al
  800868:	74 0c                	je     800876 <strcmp+0x20>
  80086a:	3a 02                	cmp    (%edx),%al
  80086c:	75 08                	jne    800876 <strcmp+0x20>
		p++, q++;
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	83 c2 01             	add    $0x1,%edx
  800874:	eb ed                	jmp    800863 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 c0             	movzbl %al,%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800880:	f3 0f 1e fb          	endbr32 
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	53                   	push   %ebx
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088e:	89 c3                	mov    %eax,%ebx
  800890:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800893:	eb 06                	jmp    80089b <strncmp+0x1b>
		n--, p++, q++;
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80089b:	39 d8                	cmp    %ebx,%eax
  80089d:	74 16                	je     8008b5 <strncmp+0x35>
  80089f:	0f b6 08             	movzbl (%eax),%ecx
  8008a2:	84 c9                	test   %cl,%cl
  8008a4:	74 04                	je     8008aa <strncmp+0x2a>
  8008a6:	3a 0a                	cmp    (%edx),%cl
  8008a8:	74 eb                	je     800895 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 00             	movzbl (%eax),%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    
		return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	eb f6                	jmp    8008b2 <strncmp+0x32>

008008bc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bc:	f3 0f 1e fb          	endbr32 
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	0f b6 10             	movzbl (%eax),%edx
  8008cd:	84 d2                	test   %dl,%dl
  8008cf:	74 09                	je     8008da <strchr+0x1e>
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 0a                	je     8008df <strchr+0x23>
	for (; *s; s++)
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	eb f0                	jmp    8008ca <strchr+0xe>
			return (char *) s;
	return 0;
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8008e1:	f3 0f 1e fb          	endbr32 
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8008eb:	6a 78                	push   $0x78
  8008ed:	ff 75 08             	pushl  0x8(%ebp)
  8008f0:	e8 c7 ff ff ff       	call   8008bc <strchr>
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800900:	eb 0d                	jmp    80090f <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800902:	c1 e0 04             	shl    $0x4,%eax
  800905:	0f be d2             	movsbl %dl,%edx
  800908:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	0f b6 11             	movzbl (%ecx),%edx
  800912:	84 d2                	test   %dl,%dl
  800914:	74 11                	je     800927 <atox+0x46>
		if (*p>='a'){
  800916:	80 fa 60             	cmp    $0x60,%dl
  800919:	7e e7                	jle    800902 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  80091b:	c1 e0 04             	shl    $0x4,%eax
  80091e:	0f be d2             	movsbl %dl,%edx
  800921:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800925:	eb e5                	jmp    80090c <atox+0x2b>
	}

	return v;

}
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800929:	f3 0f 1e fb          	endbr32 
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800937:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	74 09                	je     800947 <strfind+0x1e>
  80093e:	84 d2                	test   %dl,%dl
  800940:	74 05                	je     800947 <strfind+0x1e>
	for (; *s; s++)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	eb f0                	jmp    800937 <strfind+0xe>
			break;
	return (char *) s;
}
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800949:	f3 0f 1e fb          	endbr32 
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	57                   	push   %edi
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 7d 08             	mov    0x8(%ebp),%edi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	74 31                	je     80098e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	09 c8                	or     %ecx,%eax
  800961:	a8 03                	test   $0x3,%al
  800963:	75 23                	jne    800988 <memset+0x3f>
		c &= 0xFF;
  800965:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800969:	89 d3                	mov    %edx,%ebx
  80096b:	c1 e3 08             	shl    $0x8,%ebx
  80096e:	89 d0                	mov    %edx,%eax
  800970:	c1 e0 18             	shl    $0x18,%eax
  800973:	89 d6                	mov    %edx,%esi
  800975:	c1 e6 10             	shl    $0x10,%esi
  800978:	09 f0                	or     %esi,%eax
  80097a:	09 c2                	or     %eax,%edx
  80097c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800981:	89 d0                	mov    %edx,%eax
  800983:	fc                   	cld    
  800984:	f3 ab                	rep stos %eax,%es:(%edi)
  800986:	eb 06                	jmp    80098e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098b:	fc                   	cld    
  80098c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098e:	89 f8                	mov    %edi,%eax
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800995:	f3 0f 1e fb          	endbr32 
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a7:	39 c6                	cmp    %eax,%esi
  8009a9:	73 32                	jae    8009dd <memmove+0x48>
  8009ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ae:	39 c2                	cmp    %eax,%edx
  8009b0:	76 2b                	jbe    8009dd <memmove+0x48>
		s += n;
		d += n;
  8009b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 fe                	mov    %edi,%esi
  8009b7:	09 ce                	or     %ecx,%esi
  8009b9:	09 d6                	or     %edx,%esi
  8009bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c1:	75 0e                	jne    8009d1 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c3:	83 ef 04             	sub    $0x4,%edi
  8009c6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 09                	jmp    8009da <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d1:	83 ef 01             	sub    $0x1,%edi
  8009d4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d7:	fd                   	std    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009da:	fc                   	cld    
  8009db:	eb 1a                	jmp    8009f7 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dd:	89 c2                	mov    %eax,%edx
  8009df:	09 ca                	or     %ecx,%edx
  8009e1:	09 f2                	or     %esi,%edx
  8009e3:	f6 c2 03             	test   $0x3,%dl
  8009e6:	75 0a                	jne    8009f2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	fc                   	cld    
  8009ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f0:	eb 05                	jmp    8009f7 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009f2:	89 c7                	mov    %eax,%edi
  8009f4:	fc                   	cld    
  8009f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fb:	f3 0f 1e fb          	endbr32 
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a05:	ff 75 10             	pushl  0x10(%ebp)
  800a08:	ff 75 0c             	pushl  0xc(%ebp)
  800a0b:	ff 75 08             	pushl  0x8(%ebp)
  800a0e:	e8 82 ff ff ff       	call   800995 <memmove>
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a15:	f3 0f 1e fb          	endbr32 
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a24:	89 c6                	mov    %eax,%esi
  800a26:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a29:	39 f0                	cmp    %esi,%eax
  800a2b:	74 1c                	je     800a49 <memcmp+0x34>
		if (*s1 != *s2)
  800a2d:	0f b6 08             	movzbl (%eax),%ecx
  800a30:	0f b6 1a             	movzbl (%edx),%ebx
  800a33:	38 d9                	cmp    %bl,%cl
  800a35:	75 08                	jne    800a3f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	83 c2 01             	add    $0x1,%edx
  800a3d:	eb ea                	jmp    800a29 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a3f:	0f b6 c1             	movzbl %cl,%eax
  800a42:	0f b6 db             	movzbl %bl,%ebx
  800a45:	29 d8                	sub    %ebx,%eax
  800a47:	eb 05                	jmp    800a4e <memcmp+0x39>
	}

	return 0;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a52:	f3 0f 1e fb          	endbr32 
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a64:	39 d0                	cmp    %edx,%eax
  800a66:	73 09                	jae    800a71 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a68:	38 08                	cmp    %cl,(%eax)
  800a6a:	74 05                	je     800a71 <memfind+0x1f>
	for (; s < ends; s++)
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	eb f3                	jmp    800a64 <memfind+0x12>
			break;
	return (void *) s;
}
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a73:	f3 0f 1e fb          	endbr32 
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	eb 03                	jmp    800a88 <strtol+0x15>
		s++;
  800a85:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a88:	0f b6 01             	movzbl (%ecx),%eax
  800a8b:	3c 20                	cmp    $0x20,%al
  800a8d:	74 f6                	je     800a85 <strtol+0x12>
  800a8f:	3c 09                	cmp    $0x9,%al
  800a91:	74 f2                	je     800a85 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a93:	3c 2b                	cmp    $0x2b,%al
  800a95:	74 2a                	je     800ac1 <strtol+0x4e>
	int neg = 0;
  800a97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a9c:	3c 2d                	cmp    $0x2d,%al
  800a9e:	74 2b                	je     800acb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa6:	75 0f                	jne    800ab7 <strtol+0x44>
  800aa8:	80 39 30             	cmpb   $0x30,(%ecx)
  800aab:	74 28                	je     800ad5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aad:	85 db                	test   %ebx,%ebx
  800aaf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab4:	0f 44 d8             	cmove  %eax,%ebx
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800abf:	eb 46                	jmp    800b07 <strtol+0x94>
		s++;
  800ac1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ac4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac9:	eb d5                	jmp    800aa0 <strtol+0x2d>
		s++, neg = 1;
  800acb:	83 c1 01             	add    $0x1,%ecx
  800ace:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad3:	eb cb                	jmp    800aa0 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad9:	74 0e                	je     800ae9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800adb:	85 db                	test   %ebx,%ebx
  800add:	75 d8                	jne    800ab7 <strtol+0x44>
		s++, base = 8;
  800adf:	83 c1 01             	add    $0x1,%ecx
  800ae2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae7:	eb ce                	jmp    800ab7 <strtol+0x44>
		s += 2, base = 16;
  800ae9:	83 c1 02             	add    $0x2,%ecx
  800aec:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af1:	eb c4                	jmp    800ab7 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800afc:	7d 3a                	jge    800b38 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800afe:	83 c1 01             	add    $0x1,%ecx
  800b01:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b05:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b07:	0f b6 11             	movzbl (%ecx),%edx
  800b0a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 09             	cmp    $0x9,%bl
  800b12:	76 df                	jbe    800af3 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b14:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b17:	89 f3                	mov    %esi,%ebx
  800b19:	80 fb 19             	cmp    $0x19,%bl
  800b1c:	77 08                	ja     800b26 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b1e:	0f be d2             	movsbl %dl,%edx
  800b21:	83 ea 57             	sub    $0x57,%edx
  800b24:	eb d3                	jmp    800af9 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b26:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b29:	89 f3                	mov    %esi,%ebx
  800b2b:	80 fb 19             	cmp    $0x19,%bl
  800b2e:	77 08                	ja     800b38 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b30:	0f be d2             	movsbl %dl,%edx
  800b33:	83 ea 37             	sub    $0x37,%edx
  800b36:	eb c1                	jmp    800af9 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3c:	74 05                	je     800b43 <strtol+0xd0>
		*endptr = (char *) s;
  800b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b41:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b43:	89 c2                	mov    %eax,%edx
  800b45:	f7 da                	neg    %edx
  800b47:	85 ff                	test   %edi,%edi
  800b49:	0f 45 c2             	cmovne %edx,%eax
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b51:	f3 0f 1e fb          	endbr32 
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	89 c7                	mov    %eax,%edi
  800b6a:	89 c6                	mov    %eax,%esi
  800b6c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b73:	f3 0f 1e fb          	endbr32 
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 01 00 00 00       	mov    $0x1,%eax
  800b87:	89 d1                	mov    %edx,%ecx
  800b89:	89 d3                	mov    %edx,%ebx
  800b8b:	89 d7                	mov    %edx,%edi
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b96:	f3 0f 1e fb          	endbr32 
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bad:	89 cb                	mov    %ecx,%ebx
  800baf:	89 cf                	mov    %ecx,%edi
  800bb1:	89 ce                	mov    %ecx,%esi
  800bb3:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bba:	f3 0f 1e fb          	endbr32 
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_yield>:

void
sys_yield(void)
{
  800bdd:	f3 0f 1e fb          	endbr32 
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf1:	89 d1                	mov    %edx,%ecx
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	89 d6                	mov    %edx,%esi
  800bf9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0a:	be 00 00 00 00       	mov    $0x0,%esi
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	89 f7                	mov    %esi,%edi
  800c1f:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c26:	f3 0f 1e fb          	endbr32 
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c41:	8b 75 18             	mov    0x18(%ebp),%esi
  800c44:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4b:	f3 0f 1e fb          	endbr32 
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	b8 06 00 00 00       	mov    $0x6,%eax
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c70:	f3 0f 1e fb          	endbr32 
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8a:	89 df                	mov    %ebx,%edi
  800c8c:	89 de                	mov    %ebx,%esi
  800c8e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c95:	f3 0f 1e fb          	endbr32 
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	b8 09 00 00 00       	mov    $0x9,%eax
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cba:	f3 0f 1e fb          	endbr32 
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cdf:	f3 0f 1e fb          	endbr32 
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf4:	be 00 00 00 00       	mov    $0x0,%esi
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d06:	f3 0f 1e fb          	endbr32 
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1d:	89 cb                	mov    %ecx,%ebx
  800d1f:	89 cf                	mov    %ecx,%edi
  800d21:	89 ce                	mov    %ecx,%esi
  800d23:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2a:	f3 0f 1e fb          	endbr32 
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3e:	89 d1                	mov    %edx,%ecx
  800d40:	89 d3                	mov    %edx,%ebx
  800d42:	89 d7                	mov    %edx,%edi
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d4d:	f3 0f 1e fb          	endbr32 
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800d72:	f3 0f 1e fb          	endbr32 
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	57                   	push   %edi
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	b8 10 00 00 00       	mov    $0x10,%eax
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d97:	f3 0f 1e fb          	endbr32 
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800da1:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800da8:	74 0a                	je     800db4 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	a3 0c 40 80 00       	mov    %eax,0x80400c

}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  800db4:	83 ec 04             	sub    $0x4,%esp
  800db7:	6a 07                	push   $0x7
  800db9:	68 00 f0 bf ee       	push   $0xeebff000
  800dbe:	6a 00                	push   $0x0
  800dc0:	e8 3b fe ff ff       	call   800c00 <sys_page_alloc>
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	78 2a                	js     800df6 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  800dcc:	83 ec 08             	sub    $0x8,%esp
  800dcf:	68 0a 0e 80 00       	push   $0x800e0a
  800dd4:	6a 00                	push   $0x0
  800dd6:	e8 df fe ff ff       	call   800cba <sys_env_set_pgfault_upcall>
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	79 c8                	jns    800daa <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	68 8c 27 80 00       	push   $0x80278c
  800dea:	6a 2c                	push   $0x2c
  800dec:	68 c2 27 80 00       	push   $0x8027c2
  800df1:	e8 40 12 00 00       	call   802036 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	68 60 27 80 00       	push   $0x802760
  800dfe:	6a 22                	push   $0x22
  800e00:	68 c2 27 80 00       	push   $0x8027c2
  800e05:	e8 2c 12 00 00       	call   802036 <_panic>

00800e0a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e0a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e0b:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax   			// 间接寻址
  800e10:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e12:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  800e15:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  800e19:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  800e1e:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  800e22:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  800e24:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  800e27:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  800e28:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  800e2b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  800e2c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  800e2d:	c3                   	ret    

00800e2e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e2e:	f3 0f 1e fb          	endbr32 
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e42:	f3 0f 1e fb          	endbr32 
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e56:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e5d:	f3 0f 1e fb          	endbr32 
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 16             	shr    $0x16,%edx
  800e6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e75:	f6 c2 01             	test   $0x1,%dl
  800e78:	74 2d                	je     800ea7 <fd_alloc+0x4a>
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 ea 0c             	shr    $0xc,%edx
  800e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	74 1c                	je     800ea7 <fd_alloc+0x4a>
  800e8b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e90:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e95:	75 d2                	jne    800e69 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800ea0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800ea5:	eb 0a                	jmp    800eb1 <fd_alloc+0x54>
			*fd_store = fd;
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb3:	f3 0f 1e fb          	endbr32 
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ebd:	83 f8 1f             	cmp    $0x1f,%eax
  800ec0:	77 30                	ja     800ef2 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec2:	c1 e0 0c             	shl    $0xc,%eax
  800ec5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eca:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ed0:	f6 c2 01             	test   $0x1,%dl
  800ed3:	74 24                	je     800ef9 <fd_lookup+0x46>
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	c1 ea 0c             	shr    $0xc,%edx
  800eda:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee1:	f6 c2 01             	test   $0x1,%dl
  800ee4:	74 1a                	je     800f00 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee9:	89 02                	mov    %eax,(%edx)
	return 0;
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
		return -E_INVAL;
  800ef2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef7:	eb f7                	jmp    800ef0 <fd_lookup+0x3d>
		return -E_INVAL;
  800ef9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efe:	eb f0                	jmp    800ef0 <fd_lookup+0x3d>
  800f00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f05:	eb e9                	jmp    800ef0 <fd_lookup+0x3d>

00800f07 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f07:	f3 0f 1e fb          	endbr32 
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	83 ec 08             	sub    $0x8,%esp
  800f11:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f14:	ba 00 00 00 00       	mov    $0x0,%edx
  800f19:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f1e:	39 08                	cmp    %ecx,(%eax)
  800f20:	74 38                	je     800f5a <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f22:	83 c2 01             	add    $0x1,%edx
  800f25:	8b 04 95 4c 28 80 00 	mov    0x80284c(,%edx,4),%eax
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	75 ee                	jne    800f1e <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f30:	a1 08 40 80 00       	mov    0x804008,%eax
  800f35:	8b 40 48             	mov    0x48(%eax),%eax
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	51                   	push   %ecx
  800f3c:	50                   	push   %eax
  800f3d:	68 d0 27 80 00       	push   $0x8027d0
  800f42:	e8 46 f2 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f58:	c9                   	leave  
  800f59:	c3                   	ret    
			*dev = devtab[i];
  800f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f64:	eb f2                	jmp    800f58 <dev_lookup+0x51>

00800f66 <fd_close>:
{
  800f66:	f3 0f 1e fb          	endbr32 
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	57                   	push   %edi
  800f6e:	56                   	push   %esi
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 24             	sub    $0x24,%esp
  800f73:	8b 75 08             	mov    0x8(%ebp),%esi
  800f76:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f79:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f7c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f7d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f83:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f86:	50                   	push   %eax
  800f87:	e8 27 ff ff ff       	call   800eb3 <fd_lookup>
  800f8c:	89 c3                	mov    %eax,%ebx
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 05                	js     800f9a <fd_close+0x34>
	    || fd != fd2)
  800f95:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f98:	74 16                	je     800fb0 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f9a:	89 f8                	mov    %edi,%eax
  800f9c:	84 c0                	test   %al,%al
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa3:	0f 44 d8             	cmove  %eax,%ebx
}
  800fa6:	89 d8                	mov    %ebx,%eax
  800fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	ff 36                	pushl  (%esi)
  800fb9:	e8 49 ff ff ff       	call   800f07 <dev_lookup>
  800fbe:	89 c3                	mov    %eax,%ebx
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 1a                	js     800fe1 <fd_close+0x7b>
		if (dev->dev_close)
  800fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fca:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fcd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	74 0b                	je     800fe1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	56                   	push   %esi
  800fda:	ff d0                	call   *%eax
  800fdc:	89 c3                	mov    %eax,%ebx
  800fde:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	56                   	push   %esi
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 5f fc ff ff       	call   800c4b <sys_page_unmap>
	return r;
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	eb b5                	jmp    800fa6 <fd_close+0x40>

00800ff1 <close>:

int
close(int fdnum)
{
  800ff1:	f3 0f 1e fb          	endbr32 
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	ff 75 08             	pushl  0x8(%ebp)
  801002:	e8 ac fe ff ff       	call   800eb3 <fd_lookup>
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	79 02                	jns    801010 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80100e:	c9                   	leave  
  80100f:	c3                   	ret    
		return fd_close(fd, 1);
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	6a 01                	push   $0x1
  801015:	ff 75 f4             	pushl  -0xc(%ebp)
  801018:	e8 49 ff ff ff       	call   800f66 <fd_close>
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	eb ec                	jmp    80100e <close+0x1d>

00801022 <close_all>:

void
close_all(void)
{
  801022:	f3 0f 1e fb          	endbr32 
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	53                   	push   %ebx
  801036:	e8 b6 ff ff ff       	call   800ff1 <close>
	for (i = 0; i < MAXFD; i++)
  80103b:	83 c3 01             	add    $0x1,%ebx
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	83 fb 20             	cmp    $0x20,%ebx
  801044:	75 ec                	jne    801032 <close_all+0x10>
}
  801046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80104b:	f3 0f 1e fb          	endbr32 
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801058:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80105b:	50                   	push   %eax
  80105c:	ff 75 08             	pushl  0x8(%ebp)
  80105f:	e8 4f fe ff ff       	call   800eb3 <fd_lookup>
  801064:	89 c3                	mov    %eax,%ebx
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	0f 88 81 00 00 00    	js     8010f2 <dup+0xa7>
		return r;
	close(newfdnum);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	ff 75 0c             	pushl  0xc(%ebp)
  801077:	e8 75 ff ff ff       	call   800ff1 <close>

	newfd = INDEX2FD(newfdnum);
  80107c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80107f:	c1 e6 0c             	shl    $0xc,%esi
  801082:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801088:	83 c4 04             	add    $0x4,%esp
  80108b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108e:	e8 af fd ff ff       	call   800e42 <fd2data>
  801093:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801095:	89 34 24             	mov    %esi,(%esp)
  801098:	e8 a5 fd ff ff       	call   800e42 <fd2data>
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a2:	89 d8                	mov    %ebx,%eax
  8010a4:	c1 e8 16             	shr    $0x16,%eax
  8010a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ae:	a8 01                	test   $0x1,%al
  8010b0:	74 11                	je     8010c3 <dup+0x78>
  8010b2:	89 d8                	mov    %ebx,%eax
  8010b4:	c1 e8 0c             	shr    $0xc,%eax
  8010b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010be:	f6 c2 01             	test   $0x1,%dl
  8010c1:	75 39                	jne    8010fc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010c6:	89 d0                	mov    %edx,%eax
  8010c8:	c1 e8 0c             	shr    $0xc,%eax
  8010cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010da:	50                   	push   %eax
  8010db:	56                   	push   %esi
  8010dc:	6a 00                	push   $0x0
  8010de:	52                   	push   %edx
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 40 fb ff ff       	call   800c26 <sys_page_map>
  8010e6:	89 c3                	mov    %eax,%ebx
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 31                	js     801120 <dup+0xd5>
		goto err;

	return newfdnum;
  8010ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010f2:	89 d8                	mov    %ebx,%eax
  8010f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	25 07 0e 00 00       	and    $0xe07,%eax
  80110b:	50                   	push   %eax
  80110c:	57                   	push   %edi
  80110d:	6a 00                	push   $0x0
  80110f:	53                   	push   %ebx
  801110:	6a 00                	push   $0x0
  801112:	e8 0f fb ff ff       	call   800c26 <sys_page_map>
  801117:	89 c3                	mov    %eax,%ebx
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 a3                	jns    8010c3 <dup+0x78>
	sys_page_unmap(0, newfd);
  801120:	83 ec 08             	sub    $0x8,%esp
  801123:	56                   	push   %esi
  801124:	6a 00                	push   $0x0
  801126:	e8 20 fb ff ff       	call   800c4b <sys_page_unmap>
	sys_page_unmap(0, nva);
  80112b:	83 c4 08             	add    $0x8,%esp
  80112e:	57                   	push   %edi
  80112f:	6a 00                	push   $0x0
  801131:	e8 15 fb ff ff       	call   800c4b <sys_page_unmap>
	return r;
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	eb b7                	jmp    8010f2 <dup+0xa7>

0080113b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80113b:	f3 0f 1e fb          	endbr32 
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	53                   	push   %ebx
  801143:	83 ec 1c             	sub    $0x1c,%esp
  801146:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801149:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	53                   	push   %ebx
  80114e:	e8 60 fd ff ff       	call   800eb3 <fd_lookup>
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	78 3f                	js     801199 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801164:	ff 30                	pushl  (%eax)
  801166:	e8 9c fd ff ff       	call   800f07 <dev_lookup>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 27                	js     801199 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801172:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801175:	8b 42 08             	mov    0x8(%edx),%eax
  801178:	83 e0 03             	and    $0x3,%eax
  80117b:	83 f8 01             	cmp    $0x1,%eax
  80117e:	74 1e                	je     80119e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801180:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801183:	8b 40 08             	mov    0x8(%eax),%eax
  801186:	85 c0                	test   %eax,%eax
  801188:	74 35                	je     8011bf <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	ff 75 10             	pushl  0x10(%ebp)
  801190:	ff 75 0c             	pushl  0xc(%ebp)
  801193:	52                   	push   %edx
  801194:	ff d0                	call   *%eax
  801196:	83 c4 10             	add    $0x10,%esp
}
  801199:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80119e:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a3:	8b 40 48             	mov    0x48(%eax),%eax
  8011a6:	83 ec 04             	sub    $0x4,%esp
  8011a9:	53                   	push   %ebx
  8011aa:	50                   	push   %eax
  8011ab:	68 11 28 80 00       	push   $0x802811
  8011b0:	e8 d8 ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bd:	eb da                	jmp    801199 <read+0x5e>
		return -E_NOT_SUPP;
  8011bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011c4:	eb d3                	jmp    801199 <read+0x5e>

008011c6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c6:	f3 0f 1e fb          	endbr32 
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011de:	eb 02                	jmp    8011e2 <readn+0x1c>
  8011e0:	01 c3                	add    %eax,%ebx
  8011e2:	39 f3                	cmp    %esi,%ebx
  8011e4:	73 21                	jae    801207 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	89 f0                	mov    %esi,%eax
  8011eb:	29 d8                	sub    %ebx,%eax
  8011ed:	50                   	push   %eax
  8011ee:	89 d8                	mov    %ebx,%eax
  8011f0:	03 45 0c             	add    0xc(%ebp),%eax
  8011f3:	50                   	push   %eax
  8011f4:	57                   	push   %edi
  8011f5:	e8 41 ff ff ff       	call   80113b <read>
		if (m < 0)
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 04                	js     801205 <readn+0x3f>
			return m;
		if (m == 0)
  801201:	75 dd                	jne    8011e0 <readn+0x1a>
  801203:	eb 02                	jmp    801207 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801205:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801207:	89 d8                	mov    %ebx,%eax
  801209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801211:	f3 0f 1e fb          	endbr32 
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	53                   	push   %ebx
  801219:	83 ec 1c             	sub    $0x1c,%esp
  80121c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	53                   	push   %ebx
  801224:	e8 8a fc ff ff       	call   800eb3 <fd_lookup>
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 3a                	js     80126a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123a:	ff 30                	pushl  (%eax)
  80123c:	e8 c6 fc ff ff       	call   800f07 <dev_lookup>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 22                	js     80126a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124f:	74 1e                	je     80126f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801251:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801254:	8b 52 0c             	mov    0xc(%edx),%edx
  801257:	85 d2                	test   %edx,%edx
  801259:	74 35                	je     801290 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	ff 75 10             	pushl  0x10(%ebp)
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	50                   	push   %eax
  801265:	ff d2                	call   *%edx
  801267:	83 c4 10             	add    $0x10,%esp
}
  80126a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80126f:	a1 08 40 80 00       	mov    0x804008,%eax
  801274:	8b 40 48             	mov    0x48(%eax),%eax
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	53                   	push   %ebx
  80127b:	50                   	push   %eax
  80127c:	68 2d 28 80 00       	push   $0x80282d
  801281:	e8 07 ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128e:	eb da                	jmp    80126a <write+0x59>
		return -E_NOT_SUPP;
  801290:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801295:	eb d3                	jmp    80126a <write+0x59>

00801297 <seek>:

int
seek(int fdnum, off_t offset)
{
  801297:	f3 0f 1e fb          	endbr32 
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	ff 75 08             	pushl  0x8(%ebp)
  8012a8:	e8 06 fc ff ff       	call   800eb3 <fd_lookup>
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 0e                	js     8012c2 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8012b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c4:	f3 0f 1e fb          	endbr32 
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 1c             	sub    $0x1c,%esp
  8012cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	53                   	push   %ebx
  8012d7:	e8 d7 fb ff ff       	call   800eb3 <fd_lookup>
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	78 37                	js     80131a <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ed:	ff 30                	pushl  (%eax)
  8012ef:	e8 13 fc ff ff       	call   800f07 <dev_lookup>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 1f                	js     80131a <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801302:	74 1b                	je     80131f <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801304:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801307:	8b 52 18             	mov    0x18(%edx),%edx
  80130a:	85 d2                	test   %edx,%edx
  80130c:	74 32                	je     801340 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	ff 75 0c             	pushl  0xc(%ebp)
  801314:	50                   	push   %eax
  801315:	ff d2                	call   *%edx
  801317:	83 c4 10             	add    $0x10,%esp
}
  80131a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80131f:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	53                   	push   %ebx
  80132b:	50                   	push   %eax
  80132c:	68 f0 27 80 00       	push   $0x8027f0
  801331:	e8 57 ee ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb da                	jmp    80131a <ftruncate+0x56>
		return -E_NOT_SUPP;
  801340:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801345:	eb d3                	jmp    80131a <ftruncate+0x56>

00801347 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801347:	f3 0f 1e fb          	endbr32 
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	53                   	push   %ebx
  80134f:	83 ec 1c             	sub    $0x1c,%esp
  801352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801355:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 75 08             	pushl  0x8(%ebp)
  80135c:	e8 52 fb ff ff       	call   800eb3 <fd_lookup>
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 4b                	js     8013b3 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801372:	ff 30                	pushl  (%eax)
  801374:	e8 8e fb ff ff       	call   800f07 <dev_lookup>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 33                	js     8013b3 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801383:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801387:	74 2f                	je     8013b8 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801389:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80138c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801393:	00 00 00 
	stat->st_isdir = 0;
  801396:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80139d:	00 00 00 
	stat->st_dev = dev;
  8013a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ad:	ff 50 14             	call   *0x14(%eax)
  8013b0:	83 c4 10             	add    $0x10,%esp
}
  8013b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b6:	c9                   	leave  
  8013b7:	c3                   	ret    
		return -E_NOT_SUPP;
  8013b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013bd:	eb f4                	jmp    8013b3 <fstat+0x6c>

008013bf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013bf:	f3 0f 1e fb          	endbr32 
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	6a 00                	push   $0x0
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 01 02 00 00       	call   8015d6 <open>
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 1b                	js     8013f9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	ff 75 0c             	pushl  0xc(%ebp)
  8013e4:	50                   	push   %eax
  8013e5:	e8 5d ff ff ff       	call   801347 <fstat>
  8013ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ec:	89 1c 24             	mov    %ebx,(%esp)
  8013ef:	e8 fd fb ff ff       	call   800ff1 <close>
	return r;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	89 f3                	mov    %esi,%ebx
}
  8013f9:	89 d8                	mov    %ebx,%eax
  8013fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fe:	5b                   	pop    %ebx
  8013ff:	5e                   	pop    %esi
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	89 c6                	mov    %eax,%esi
  801409:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80140b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801412:	74 27                	je     80143b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801414:	6a 07                	push   $0x7
  801416:	68 00 50 80 00       	push   $0x805000
  80141b:	56                   	push   %esi
  80141c:	ff 35 00 40 80 00    	pushl  0x804000
  801422:	e8 c6 0c 00 00       	call   8020ed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801427:	83 c4 0c             	add    $0xc,%esp
  80142a:	6a 00                	push   $0x0
  80142c:	53                   	push   %ebx
  80142d:	6a 00                	push   $0x0
  80142f:	e8 4c 0c 00 00       	call   802080 <ipc_recv>
}
  801434:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	6a 01                	push   $0x1
  801440:	e8 00 0d 00 00       	call   802145 <ipc_find_env>
  801445:	a3 00 40 80 00       	mov    %eax,0x804000
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	eb c5                	jmp    801414 <fsipc+0x12>

0080144f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80144f:	f3 0f 1e fb          	endbr32 
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801464:	8b 45 0c             	mov    0xc(%ebp),%eax
  801467:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 02 00 00 00       	mov    $0x2,%eax
  801476:	e8 87 ff ff ff       	call   801402 <fsipc>
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_flush>:
{
  80147d:	f3 0f 1e fb          	endbr32 
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801487:	8b 45 08             	mov    0x8(%ebp),%eax
  80148a:	8b 40 0c             	mov    0xc(%eax),%eax
  80148d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 06 00 00 00       	mov    $0x6,%eax
  80149c:	e8 61 ff ff ff       	call   801402 <fsipc>
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_stat>:
{
  8014a3:	f3 0f 1e fb          	endbr32 
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c6:	e8 37 ff ff ff       	call   801402 <fsipc>
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 2c                	js     8014fb <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	68 00 50 80 00       	push   $0x805000
  8014d7:	53                   	push   %ebx
  8014d8:	e8 ba f2 ff ff       	call   800797 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <devfile_write>:
{
  801500:	f3 0f 1e fb          	endbr32 
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	8b 45 10             	mov    0x10(%ebp),%eax
  80150d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801512:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801517:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151a:	8b 55 08             	mov    0x8(%ebp),%edx
  80151d:	8b 52 0c             	mov    0xc(%edx),%edx
  801520:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801526:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80152b:	50                   	push   %eax
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	68 08 50 80 00       	push   $0x805008
  801534:	e8 5c f4 ff ff       	call   800995 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 04 00 00 00       	mov    $0x4,%eax
  801543:	e8 ba fe ff ff       	call   801402 <fsipc>
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_read>:
{
  80154a:	f3 0f 1e fb          	endbr32 
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801556:	8b 45 08             	mov    0x8(%ebp),%eax
  801559:	8b 40 0c             	mov    0xc(%eax),%eax
  80155c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801561:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801567:	ba 00 00 00 00       	mov    $0x0,%edx
  80156c:	b8 03 00 00 00       	mov    $0x3,%eax
  801571:	e8 8c fe ff ff       	call   801402 <fsipc>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 1f                	js     80159b <devfile_read+0x51>
	assert(r <= n);
  80157c:	39 f0                	cmp    %esi,%eax
  80157e:	77 24                	ja     8015a4 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801580:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801585:	7f 36                	jg     8015bd <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801587:	83 ec 04             	sub    $0x4,%esp
  80158a:	50                   	push   %eax
  80158b:	68 00 50 80 00       	push   $0x805000
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	e8 fd f3 ff ff       	call   800995 <memmove>
	return r;
  801598:	83 c4 10             	add    $0x10,%esp
}
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    
	assert(r <= n);
  8015a4:	68 60 28 80 00       	push   $0x802860
  8015a9:	68 67 28 80 00       	push   $0x802867
  8015ae:	68 8c 00 00 00       	push   $0x8c
  8015b3:	68 7c 28 80 00       	push   $0x80287c
  8015b8:	e8 79 0a 00 00       	call   802036 <_panic>
	assert(r <= PGSIZE);
  8015bd:	68 87 28 80 00       	push   $0x802887
  8015c2:	68 67 28 80 00       	push   $0x802867
  8015c7:	68 8d 00 00 00       	push   $0x8d
  8015cc:	68 7c 28 80 00       	push   $0x80287c
  8015d1:	e8 60 0a 00 00       	call   802036 <_panic>

008015d6 <open>:
{
  8015d6:	f3 0f 1e fb          	endbr32 
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
  8015df:	83 ec 1c             	sub    $0x1c,%esp
  8015e2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015e5:	56                   	push   %esi
  8015e6:	e8 69 f1 ff ff       	call   800754 <strlen>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015f3:	7f 6c                	jg     801661 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	e8 5c f8 ff ff       	call   800e5d <fd_alloc>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	78 3c                	js     801646 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	56                   	push   %esi
  80160e:	68 00 50 80 00       	push   $0x805000
  801613:	e8 7f f1 ff ff       	call   800797 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801620:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801623:	b8 01 00 00 00       	mov    $0x1,%eax
  801628:	e8 d5 fd ff ff       	call   801402 <fsipc>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 19                	js     80164f <open+0x79>
	return fd2num(fd);
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	ff 75 f4             	pushl  -0xc(%ebp)
  80163c:	e8 ed f7 ff ff       	call   800e2e <fd2num>
  801641:	89 c3                	mov    %eax,%ebx
  801643:	83 c4 10             	add    $0x10,%esp
}
  801646:	89 d8                	mov    %ebx,%eax
  801648:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    
		fd_close(fd, 0);
  80164f:	83 ec 08             	sub    $0x8,%esp
  801652:	6a 00                	push   $0x0
  801654:	ff 75 f4             	pushl  -0xc(%ebp)
  801657:	e8 0a f9 ff ff       	call   800f66 <fd_close>
		return r;
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb e5                	jmp    801646 <open+0x70>
		return -E_BAD_PATH;
  801661:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801666:	eb de                	jmp    801646 <open+0x70>

00801668 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801668:	f3 0f 1e fb          	endbr32 
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801672:	ba 00 00 00 00       	mov    $0x0,%edx
  801677:	b8 08 00 00 00       	mov    $0x8,%eax
  80167c:	e8 81 fd ff ff       	call   801402 <fsipc>
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801683:	f3 0f 1e fb          	endbr32 
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80168d:	68 f3 28 80 00       	push   $0x8028f3
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	e8 fd f0 ff ff       	call   800797 <strcpy>
	return 0;
}
  80169a:	b8 00 00 00 00       	mov    $0x0,%eax
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <devsock_close>:
{
  8016a1:	f3 0f 1e fb          	endbr32 
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 10             	sub    $0x10,%esp
  8016ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016af:	53                   	push   %ebx
  8016b0:	e8 cd 0a 00 00       	call   802182 <pageref>
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016bf:	83 fa 01             	cmp    $0x1,%edx
  8016c2:	74 05                	je     8016c9 <devsock_close+0x28>
}
  8016c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	ff 73 0c             	pushl  0xc(%ebx)
  8016cf:	e8 e3 02 00 00       	call   8019b7 <nsipc_close>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	eb eb                	jmp    8016c4 <devsock_close+0x23>

008016d9 <devsock_write>:
{
  8016d9:	f3 0f 1e fb          	endbr32 
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016e3:	6a 00                	push   $0x0
  8016e5:	ff 75 10             	pushl  0x10(%ebp)
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	ff 70 0c             	pushl  0xc(%eax)
  8016f1:	e8 b5 03 00 00       	call   801aab <nsipc_send>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <devsock_read>:
{
  8016f8:	f3 0f 1e fb          	endbr32 
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801702:	6a 00                	push   $0x0
  801704:	ff 75 10             	pushl  0x10(%ebp)
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	8b 45 08             	mov    0x8(%ebp),%eax
  80170d:	ff 70 0c             	pushl  0xc(%eax)
  801710:	e8 1f 03 00 00       	call   801a34 <nsipc_recv>
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <fd2sockid>:
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80171d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801720:	52                   	push   %edx
  801721:	50                   	push   %eax
  801722:	e8 8c f7 ff ff       	call   800eb3 <fd_lookup>
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 10                	js     80173e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80172e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801731:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801737:	39 08                	cmp    %ecx,(%eax)
  801739:	75 05                	jne    801740 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80173b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    
		return -E_NOT_SUPP;
  801740:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801745:	eb f7                	jmp    80173e <fd2sockid+0x27>

00801747 <alloc_sockfd>:
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	83 ec 1c             	sub    $0x1c,%esp
  80174f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801751:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801754:	50                   	push   %eax
  801755:	e8 03 f7 ff ff       	call   800e5d <fd_alloc>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 43                	js     8017a6 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	68 07 04 00 00       	push   $0x407
  80176b:	ff 75 f4             	pushl  -0xc(%ebp)
  80176e:	6a 00                	push   $0x0
  801770:	e8 8b f4 ff ff       	call   800c00 <sys_page_alloc>
  801775:	89 c3                	mov    %eax,%ebx
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 28                	js     8017a6 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80177e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801781:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801787:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801793:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801796:	83 ec 0c             	sub    $0xc,%esp
  801799:	50                   	push   %eax
  80179a:	e8 8f f6 ff ff       	call   800e2e <fd2num>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	eb 0c                	jmp    8017b2 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	56                   	push   %esi
  8017aa:	e8 08 02 00 00       	call   8019b7 <nsipc_close>
		return r;
  8017af:	83 c4 10             	add    $0x10,%esp
}
  8017b2:	89 d8                	mov    %ebx,%eax
  8017b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b7:	5b                   	pop    %ebx
  8017b8:	5e                   	pop    %esi
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <accept>:
{
  8017bb:	f3 0f 1e fb          	endbr32 
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	e8 4a ff ff ff       	call   801717 <fd2sockid>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 1b                	js     8017ec <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017d1:	83 ec 04             	sub    $0x4,%esp
  8017d4:	ff 75 10             	pushl  0x10(%ebp)
  8017d7:	ff 75 0c             	pushl  0xc(%ebp)
  8017da:	50                   	push   %eax
  8017db:	e8 22 01 00 00       	call   801902 <nsipc_accept>
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 05                	js     8017ec <accept+0x31>
	return alloc_sockfd(r);
  8017e7:	e8 5b ff ff ff       	call   801747 <alloc_sockfd>
}
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <bind>:
{
  8017ee:	f3 0f 1e fb          	endbr32 
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	e8 17 ff ff ff       	call   801717 <fd2sockid>
  801800:	85 c0                	test   %eax,%eax
  801802:	78 12                	js     801816 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801804:	83 ec 04             	sub    $0x4,%esp
  801807:	ff 75 10             	pushl  0x10(%ebp)
  80180a:	ff 75 0c             	pushl  0xc(%ebp)
  80180d:	50                   	push   %eax
  80180e:	e8 45 01 00 00       	call   801958 <nsipc_bind>
  801813:	83 c4 10             	add    $0x10,%esp
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <shutdown>:
{
  801818:	f3 0f 1e fb          	endbr32 
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	e8 ed fe ff ff       	call   801717 <fd2sockid>
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 0f                	js     80183d <shutdown+0x25>
	return nsipc_shutdown(r, how);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	50                   	push   %eax
  801835:	e8 57 01 00 00       	call   801991 <nsipc_shutdown>
  80183a:	83 c4 10             	add    $0x10,%esp
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <connect>:
{
  80183f:	f3 0f 1e fb          	endbr32 
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	e8 c6 fe ff ff       	call   801717 <fd2sockid>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 12                	js     801867 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	ff 75 10             	pushl  0x10(%ebp)
  80185b:	ff 75 0c             	pushl  0xc(%ebp)
  80185e:	50                   	push   %eax
  80185f:	e8 71 01 00 00       	call   8019d5 <nsipc_connect>
  801864:	83 c4 10             	add    $0x10,%esp
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <listen>:
{
  801869:	f3 0f 1e fb          	endbr32 
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	e8 9c fe ff ff       	call   801717 <fd2sockid>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 0f                	js     80188e <listen+0x25>
	return nsipc_listen(r, backlog);
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	ff 75 0c             	pushl  0xc(%ebp)
  801885:	50                   	push   %eax
  801886:	e8 83 01 00 00       	call   801a0e <nsipc_listen>
  80188b:	83 c4 10             	add    $0x10,%esp
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <socket>:

int
socket(int domain, int type, int protocol)
{
  801890:	f3 0f 1e fb          	endbr32 
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80189a:	ff 75 10             	pushl  0x10(%ebp)
  80189d:	ff 75 0c             	pushl  0xc(%ebp)
  8018a0:	ff 75 08             	pushl  0x8(%ebp)
  8018a3:	e8 65 02 00 00       	call   801b0d <nsipc_socket>
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 05                	js     8018b4 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8018af:	e8 93 fe ff ff       	call   801747 <alloc_sockfd>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 04             	sub    $0x4,%esp
  8018bd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018bf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018c6:	74 26                	je     8018ee <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018c8:	6a 07                	push   $0x7
  8018ca:	68 00 60 80 00       	push   $0x806000
  8018cf:	53                   	push   %ebx
  8018d0:	ff 35 04 40 80 00    	pushl  0x804004
  8018d6:	e8 12 08 00 00       	call   8020ed <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018db:	83 c4 0c             	add    $0xc,%esp
  8018de:	6a 00                	push   $0x0
  8018e0:	6a 00                	push   $0x0
  8018e2:	6a 00                	push   $0x0
  8018e4:	e8 97 07 00 00       	call   802080 <ipc_recv>
}
  8018e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	6a 02                	push   $0x2
  8018f3:	e8 4d 08 00 00       	call   802145 <ipc_find_env>
  8018f8:	a3 04 40 80 00       	mov    %eax,0x804004
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	eb c6                	jmp    8018c8 <nsipc+0x12>

00801902 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801902:	f3 0f 1e fb          	endbr32 
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801916:	8b 06                	mov    (%esi),%eax
  801918:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80191d:	b8 01 00 00 00       	mov    $0x1,%eax
  801922:	e8 8f ff ff ff       	call   8018b6 <nsipc>
  801927:	89 c3                	mov    %eax,%ebx
  801929:	85 c0                	test   %eax,%eax
  80192b:	79 09                	jns    801936 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80192d:	89 d8                	mov    %ebx,%eax
  80192f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801932:	5b                   	pop    %ebx
  801933:	5e                   	pop    %esi
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	ff 35 10 60 80 00    	pushl  0x806010
  80193f:	68 00 60 80 00       	push   $0x806000
  801944:	ff 75 0c             	pushl  0xc(%ebp)
  801947:	e8 49 f0 ff ff       	call   800995 <memmove>
		*addrlen = ret->ret_addrlen;
  80194c:	a1 10 60 80 00       	mov    0x806010,%eax
  801951:	89 06                	mov    %eax,(%esi)
  801953:	83 c4 10             	add    $0x10,%esp
	return r;
  801956:	eb d5                	jmp    80192d <nsipc_accept+0x2b>

00801958 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801958:	f3 0f 1e fb          	endbr32 
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80196e:	53                   	push   %ebx
  80196f:	ff 75 0c             	pushl  0xc(%ebp)
  801972:	68 04 60 80 00       	push   $0x806004
  801977:	e8 19 f0 ff ff       	call   800995 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80197c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801982:	b8 02 00 00 00       	mov    $0x2,%eax
  801987:	e8 2a ff ff ff       	call   8018b6 <nsipc>
}
  80198c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801991:	f3 0f 1e fb          	endbr32 
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80199b:	8b 45 08             	mov    0x8(%ebp),%eax
  80199e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019ab:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b0:	e8 01 ff ff ff       	call   8018b6 <nsipc>
}
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <nsipc_close>:

int
nsipc_close(int s)
{
  8019b7:	f3 0f 1e fb          	endbr32 
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019c9:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ce:	e8 e3 fe ff ff       	call   8018b6 <nsipc>
}
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019d5:	f3 0f 1e fb          	endbr32 
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	53                   	push   %ebx
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019eb:	53                   	push   %ebx
  8019ec:	ff 75 0c             	pushl  0xc(%ebp)
  8019ef:	68 04 60 80 00       	push   $0x806004
  8019f4:	e8 9c ef ff ff       	call   800995 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8019f9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8019ff:	b8 05 00 00 00       	mov    $0x5,%eax
  801a04:	e8 ad fe ff ff       	call   8018b6 <nsipc>
}
  801a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a0e:	f3 0f 1e fb          	endbr32 
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a23:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a28:	b8 06 00 00 00       	mov    $0x6,%eax
  801a2d:	e8 84 fe ff ff       	call   8018b6 <nsipc>
}
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a34:	f3 0f 1e fb          	endbr32 
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a48:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a4e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a51:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a56:	b8 07 00 00 00       	mov    $0x7,%eax
  801a5b:	e8 56 fe ff ff       	call   8018b6 <nsipc>
  801a60:	89 c3                	mov    %eax,%ebx
  801a62:	85 c0                	test   %eax,%eax
  801a64:	78 26                	js     801a8c <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801a66:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801a6c:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a71:	0f 4e c6             	cmovle %esi,%eax
  801a74:	39 c3                	cmp    %eax,%ebx
  801a76:	7f 1d                	jg     801a95 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a78:	83 ec 04             	sub    $0x4,%esp
  801a7b:	53                   	push   %ebx
  801a7c:	68 00 60 80 00       	push   $0x806000
  801a81:	ff 75 0c             	pushl  0xc(%ebp)
  801a84:	e8 0c ef ff ff       	call   800995 <memmove>
  801a89:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a8c:	89 d8                	mov    %ebx,%eax
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801a95:	68 ff 28 80 00       	push   $0x8028ff
  801a9a:	68 67 28 80 00       	push   $0x802867
  801a9f:	6a 62                	push   $0x62
  801aa1:	68 14 29 80 00       	push   $0x802914
  801aa6:	e8 8b 05 00 00       	call   802036 <_panic>

00801aab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801aab:	f3 0f 1e fb          	endbr32 
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 04             	sub    $0x4,%esp
  801ab6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ac1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ac7:	7f 2e                	jg     801af7 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	53                   	push   %ebx
  801acd:	ff 75 0c             	pushl  0xc(%ebp)
  801ad0:	68 0c 60 80 00       	push   $0x80600c
  801ad5:	e8 bb ee ff ff       	call   800995 <memmove>
	nsipcbuf.send.req_size = size;
  801ada:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ae0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ae8:	b8 08 00 00 00       	mov    $0x8,%eax
  801aed:	e8 c4 fd ff ff       	call   8018b6 <nsipc>
}
  801af2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    
	assert(size < 1600);
  801af7:	68 20 29 80 00       	push   $0x802920
  801afc:	68 67 28 80 00       	push   $0x802867
  801b01:	6a 6d                	push   $0x6d
  801b03:	68 14 29 80 00       	push   $0x802914
  801b08:	e8 29 05 00 00       	call   802036 <_panic>

00801b0d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b0d:	f3 0f 1e fb          	endbr32 
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b17:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b22:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b27:	8b 45 10             	mov    0x10(%ebp),%eax
  801b2a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b2f:	b8 09 00 00 00       	mov    $0x9,%eax
  801b34:	e8 7d fd ff ff       	call   8018b6 <nsipc>
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b3b:	f3 0f 1e fb          	endbr32 
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	ff 75 08             	pushl  0x8(%ebp)
  801b4d:	e8 f0 f2 ff ff       	call   800e42 <fd2data>
  801b52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b54:	83 c4 08             	add    $0x8,%esp
  801b57:	68 2c 29 80 00       	push   $0x80292c
  801b5c:	53                   	push   %ebx
  801b5d:	e8 35 ec ff ff       	call   800797 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b62:	8b 46 04             	mov    0x4(%esi),%eax
  801b65:	2b 06                	sub    (%esi),%eax
  801b67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b74:	00 00 00 
	stat->st_dev = &devpipe;
  801b77:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801b7e:	30 80 00 
	return 0;
}
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
  801b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b8d:	f3 0f 1e fb          	endbr32 
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	53                   	push   %ebx
  801b95:	83 ec 0c             	sub    $0xc,%esp
  801b98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b9b:	53                   	push   %ebx
  801b9c:	6a 00                	push   $0x0
  801b9e:	e8 a8 f0 ff ff       	call   800c4b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ba3:	89 1c 24             	mov    %ebx,(%esp)
  801ba6:	e8 97 f2 ff ff       	call   800e42 <fd2data>
  801bab:	83 c4 08             	add    $0x8,%esp
  801bae:	50                   	push   %eax
  801baf:	6a 00                	push   $0x0
  801bb1:	e8 95 f0 ff ff       	call   800c4b <sys_page_unmap>
}
  801bb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <_pipeisclosed>:
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	57                   	push   %edi
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 1c             	sub    $0x1c,%esp
  801bc4:	89 c7                	mov    %eax,%edi
  801bc6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801bc8:	a1 08 40 80 00       	mov    0x804008,%eax
  801bcd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	57                   	push   %edi
  801bd4:	e8 a9 05 00 00       	call   802182 <pageref>
  801bd9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bdc:	89 34 24             	mov    %esi,(%esp)
  801bdf:	e8 9e 05 00 00       	call   802182 <pageref>
		nn = thisenv->env_runs;
  801be4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	39 cb                	cmp    %ecx,%ebx
  801bf2:	74 1b                	je     801c0f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bf4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bf7:	75 cf                	jne    801bc8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bf9:	8b 42 58             	mov    0x58(%edx),%eax
  801bfc:	6a 01                	push   $0x1
  801bfe:	50                   	push   %eax
  801bff:	53                   	push   %ebx
  801c00:	68 33 29 80 00       	push   $0x802933
  801c05:	e8 83 e5 ff ff       	call   80018d <cprintf>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	eb b9                	jmp    801bc8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c0f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c12:	0f 94 c0             	sete   %al
  801c15:	0f b6 c0             	movzbl %al,%eax
}
  801c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5f                   	pop    %edi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <devpipe_write>:
{
  801c20:	f3 0f 1e fb          	endbr32 
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	57                   	push   %edi
  801c28:	56                   	push   %esi
  801c29:	53                   	push   %ebx
  801c2a:	83 ec 28             	sub    $0x28,%esp
  801c2d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c30:	56                   	push   %esi
  801c31:	e8 0c f2 ff ff       	call   800e42 <fd2data>
  801c36:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	bf 00 00 00 00       	mov    $0x0,%edi
  801c40:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c43:	74 4f                	je     801c94 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c45:	8b 43 04             	mov    0x4(%ebx),%eax
  801c48:	8b 0b                	mov    (%ebx),%ecx
  801c4a:	8d 51 20             	lea    0x20(%ecx),%edx
  801c4d:	39 d0                	cmp    %edx,%eax
  801c4f:	72 14                	jb     801c65 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c51:	89 da                	mov    %ebx,%edx
  801c53:	89 f0                	mov    %esi,%eax
  801c55:	e8 61 ff ff ff       	call   801bbb <_pipeisclosed>
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	75 3b                	jne    801c99 <devpipe_write+0x79>
			sys_yield();
  801c5e:	e8 7a ef ff ff       	call   800bdd <sys_yield>
  801c63:	eb e0                	jmp    801c45 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c68:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c6c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c6f:	89 c2                	mov    %eax,%edx
  801c71:	c1 fa 1f             	sar    $0x1f,%edx
  801c74:	89 d1                	mov    %edx,%ecx
  801c76:	c1 e9 1b             	shr    $0x1b,%ecx
  801c79:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c7c:	83 e2 1f             	and    $0x1f,%edx
  801c7f:	29 ca                	sub    %ecx,%edx
  801c81:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c85:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c89:	83 c0 01             	add    $0x1,%eax
  801c8c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c8f:	83 c7 01             	add    $0x1,%edi
  801c92:	eb ac                	jmp    801c40 <devpipe_write+0x20>
	return i;
  801c94:	8b 45 10             	mov    0x10(%ebp),%eax
  801c97:	eb 05                	jmp    801c9e <devpipe_write+0x7e>
				return 0;
  801c99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca1:	5b                   	pop    %ebx
  801ca2:	5e                   	pop    %esi
  801ca3:	5f                   	pop    %edi
  801ca4:	5d                   	pop    %ebp
  801ca5:	c3                   	ret    

00801ca6 <devpipe_read>:
{
  801ca6:	f3 0f 1e fb          	endbr32 
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	57                   	push   %edi
  801cae:	56                   	push   %esi
  801caf:	53                   	push   %ebx
  801cb0:	83 ec 18             	sub    $0x18,%esp
  801cb3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cb6:	57                   	push   %edi
  801cb7:	e8 86 f1 ff ff       	call   800e42 <fd2data>
  801cbc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	be 00 00 00 00       	mov    $0x0,%esi
  801cc6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cc9:	75 14                	jne    801cdf <devpipe_read+0x39>
	return i;
  801ccb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cce:	eb 02                	jmp    801cd2 <devpipe_read+0x2c>
				return i;
  801cd0:	89 f0                	mov    %esi,%eax
}
  801cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    
			sys_yield();
  801cda:	e8 fe ee ff ff       	call   800bdd <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cdf:	8b 03                	mov    (%ebx),%eax
  801ce1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ce4:	75 18                	jne    801cfe <devpipe_read+0x58>
			if (i > 0)
  801ce6:	85 f6                	test   %esi,%esi
  801ce8:	75 e6                	jne    801cd0 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801cea:	89 da                	mov    %ebx,%edx
  801cec:	89 f8                	mov    %edi,%eax
  801cee:	e8 c8 fe ff ff       	call   801bbb <_pipeisclosed>
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	74 e3                	je     801cda <devpipe_read+0x34>
				return 0;
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfc:	eb d4                	jmp    801cd2 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cfe:	99                   	cltd   
  801cff:	c1 ea 1b             	shr    $0x1b,%edx
  801d02:	01 d0                	add    %edx,%eax
  801d04:	83 e0 1f             	and    $0x1f,%eax
  801d07:	29 d0                	sub    %edx,%eax
  801d09:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d11:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d14:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d17:	83 c6 01             	add    $0x1,%esi
  801d1a:	eb aa                	jmp    801cc6 <devpipe_read+0x20>

00801d1c <pipe>:
{
  801d1c:	f3 0f 1e fb          	endbr32 
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	56                   	push   %esi
  801d24:	53                   	push   %ebx
  801d25:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2b:	50                   	push   %eax
  801d2c:	e8 2c f1 ff ff       	call   800e5d <fd_alloc>
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	0f 88 23 01 00 00    	js     801e61 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d3e:	83 ec 04             	sub    $0x4,%esp
  801d41:	68 07 04 00 00       	push   $0x407
  801d46:	ff 75 f4             	pushl  -0xc(%ebp)
  801d49:	6a 00                	push   $0x0
  801d4b:	e8 b0 ee ff ff       	call   800c00 <sys_page_alloc>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 c0                	test   %eax,%eax
  801d57:	0f 88 04 01 00 00    	js     801e61 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d5d:	83 ec 0c             	sub    $0xc,%esp
  801d60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d63:	50                   	push   %eax
  801d64:	e8 f4 f0 ff ff       	call   800e5d <fd_alloc>
  801d69:	89 c3                	mov    %eax,%ebx
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 db 00 00 00    	js     801e51 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d76:	83 ec 04             	sub    $0x4,%esp
  801d79:	68 07 04 00 00       	push   $0x407
  801d7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d81:	6a 00                	push   $0x0
  801d83:	e8 78 ee ff ff       	call   800c00 <sys_page_alloc>
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	0f 88 bc 00 00 00    	js     801e51 <pipe+0x135>
	va = fd2data(fd0);
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9b:	e8 a2 f0 ff ff       	call   800e42 <fd2data>
  801da0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da2:	83 c4 0c             	add    $0xc,%esp
  801da5:	68 07 04 00 00       	push   $0x407
  801daa:	50                   	push   %eax
  801dab:	6a 00                	push   $0x0
  801dad:	e8 4e ee ff ff       	call   800c00 <sys_page_alloc>
  801db2:	89 c3                	mov    %eax,%ebx
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 88 82 00 00 00    	js     801e41 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbf:	83 ec 0c             	sub    $0xc,%esp
  801dc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc5:	e8 78 f0 ff ff       	call   800e42 <fd2data>
  801dca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dd1:	50                   	push   %eax
  801dd2:	6a 00                	push   $0x0
  801dd4:	56                   	push   %esi
  801dd5:	6a 00                	push   $0x0
  801dd7:	e8 4a ee ff ff       	call   800c26 <sys_page_map>
  801ddc:	89 c3                	mov    %eax,%ebx
  801dde:	83 c4 20             	add    $0x20,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 4e                	js     801e33 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801de5:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801dea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ded:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801def:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801df2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801df9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dfc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e01:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e08:	83 ec 0c             	sub    $0xc,%esp
  801e0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0e:	e8 1b f0 ff ff       	call   800e2e <fd2num>
  801e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e16:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e18:	83 c4 04             	add    $0x4,%esp
  801e1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1e:	e8 0b f0 ff ff       	call   800e2e <fd2num>
  801e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e26:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e29:	83 c4 10             	add    $0x10,%esp
  801e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e31:	eb 2e                	jmp    801e61 <pipe+0x145>
	sys_page_unmap(0, va);
  801e33:	83 ec 08             	sub    $0x8,%esp
  801e36:	56                   	push   %esi
  801e37:	6a 00                	push   $0x0
  801e39:	e8 0d ee ff ff       	call   800c4b <sys_page_unmap>
  801e3e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	ff 75 f0             	pushl  -0x10(%ebp)
  801e47:	6a 00                	push   $0x0
  801e49:	e8 fd ed ff ff       	call   800c4b <sys_page_unmap>
  801e4e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e51:	83 ec 08             	sub    $0x8,%esp
  801e54:	ff 75 f4             	pushl  -0xc(%ebp)
  801e57:	6a 00                	push   $0x0
  801e59:	e8 ed ed ff ff       	call   800c4b <sys_page_unmap>
  801e5e:	83 c4 10             	add    $0x10,%esp
}
  801e61:	89 d8                	mov    %ebx,%eax
  801e63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <pipeisclosed>:
{
  801e6a:	f3 0f 1e fb          	endbr32 
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	ff 75 08             	pushl  0x8(%ebp)
  801e7b:	e8 33 f0 ff ff       	call   800eb3 <fd_lookup>
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 18                	js     801e9f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801e87:	83 ec 0c             	sub    $0xc,%esp
  801e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8d:	e8 b0 ef ff ff       	call   800e42 <fd2data>
  801e92:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e97:	e8 1f fd ff ff       	call   801bbb <_pipeisclosed>
  801e9c:	83 c4 10             	add    $0x10,%esp
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea1:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eaa:	c3                   	ret    

00801eab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eab:	f3 0f 1e fb          	endbr32 
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb5:	68 4b 29 80 00       	push   $0x80294b
  801eba:	ff 75 0c             	pushl  0xc(%ebp)
  801ebd:	e8 d5 e8 ff ff       	call   800797 <strcpy>
	return 0;
}
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <devcons_write>:
{
  801ec9:	f3 0f 1e fb          	endbr32 
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	57                   	push   %edi
  801ed1:	56                   	push   %esi
  801ed2:	53                   	push   %ebx
  801ed3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ed9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ede:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ee4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ee7:	73 31                	jae    801f1a <devcons_write+0x51>
		m = n - tot;
  801ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eec:	29 f3                	sub    %esi,%ebx
  801eee:	83 fb 7f             	cmp    $0x7f,%ebx
  801ef1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ef6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ef9:	83 ec 04             	sub    $0x4,%esp
  801efc:	53                   	push   %ebx
  801efd:	89 f0                	mov    %esi,%eax
  801eff:	03 45 0c             	add    0xc(%ebp),%eax
  801f02:	50                   	push   %eax
  801f03:	57                   	push   %edi
  801f04:	e8 8c ea ff ff       	call   800995 <memmove>
		sys_cputs(buf, m);
  801f09:	83 c4 08             	add    $0x8,%esp
  801f0c:	53                   	push   %ebx
  801f0d:	57                   	push   %edi
  801f0e:	e8 3e ec ff ff       	call   800b51 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f13:	01 de                	add    %ebx,%esi
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	eb ca                	jmp    801ee4 <devcons_write+0x1b>
}
  801f1a:	89 f0                	mov    %esi,%eax
  801f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <devcons_read>:
{
  801f24:	f3 0f 1e fb          	endbr32 
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 08             	sub    $0x8,%esp
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f37:	74 21                	je     801f5a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f39:	e8 35 ec ff ff       	call   800b73 <sys_cgetc>
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	75 07                	jne    801f49 <devcons_read+0x25>
		sys_yield();
  801f42:	e8 96 ec ff ff       	call   800bdd <sys_yield>
  801f47:	eb f0                	jmp    801f39 <devcons_read+0x15>
	if (c < 0)
  801f49:	78 0f                	js     801f5a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f4b:	83 f8 04             	cmp    $0x4,%eax
  801f4e:	74 0c                	je     801f5c <devcons_read+0x38>
	*(char*)vbuf = c;
  801f50:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f53:	88 02                	mov    %al,(%edx)
	return 1;
  801f55:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f5a:	c9                   	leave  
  801f5b:	c3                   	ret    
		return 0;
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f61:	eb f7                	jmp    801f5a <devcons_read+0x36>

00801f63 <cputchar>:
{
  801f63:	f3 0f 1e fb          	endbr32 
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f70:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f73:	6a 01                	push   $0x1
  801f75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f78:	50                   	push   %eax
  801f79:	e8 d3 eb ff ff       	call   800b51 <sys_cputs>
}
  801f7e:	83 c4 10             	add    $0x10,%esp
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <getchar>:
{
  801f83:	f3 0f 1e fb          	endbr32 
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f8d:	6a 01                	push   $0x1
  801f8f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f92:	50                   	push   %eax
  801f93:	6a 00                	push   $0x0
  801f95:	e8 a1 f1 ff ff       	call   80113b <read>
	if (r < 0)
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 06                	js     801fa7 <getchar+0x24>
	if (r < 1)
  801fa1:	74 06                	je     801fa9 <getchar+0x26>
	return c;
  801fa3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fa7:	c9                   	leave  
  801fa8:	c3                   	ret    
		return -E_EOF;
  801fa9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fae:	eb f7                	jmp    801fa7 <getchar+0x24>

00801fb0 <iscons>:
{
  801fb0:	f3 0f 1e fb          	endbr32 
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	ff 75 08             	pushl  0x8(%ebp)
  801fc1:	e8 ed ee ff ff       	call   800eb3 <fd_lookup>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 11                	js     801fde <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd0:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801fd6:	39 10                	cmp    %edx,(%eax)
  801fd8:	0f 94 c0             	sete   %al
  801fdb:	0f b6 c0             	movzbl %al,%eax
}
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <opencons>:
{
  801fe0:	f3 0f 1e fb          	endbr32 
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fed:	50                   	push   %eax
  801fee:	e8 6a ee ff ff       	call   800e5d <fd_alloc>
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 3a                	js     802034 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ffa:	83 ec 04             	sub    $0x4,%esp
  801ffd:	68 07 04 00 00       	push   $0x407
  802002:	ff 75 f4             	pushl  -0xc(%ebp)
  802005:	6a 00                	push   $0x0
  802007:	e8 f4 eb ff ff       	call   800c00 <sys_page_alloc>
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	85 c0                	test   %eax,%eax
  802011:	78 21                	js     802034 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802016:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80201c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802021:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802028:	83 ec 0c             	sub    $0xc,%esp
  80202b:	50                   	push   %eax
  80202c:	e8 fd ed ff ff       	call   800e2e <fd2num>
  802031:	83 c4 10             	add    $0x10,%esp
}
  802034:	c9                   	leave  
  802035:	c3                   	ret    

00802036 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802036:	f3 0f 1e fb          	endbr32 
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	56                   	push   %esi
  80203e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80203f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802042:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802048:	e8 6d eb ff ff       	call   800bba <sys_getenvid>
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	ff 75 0c             	pushl  0xc(%ebp)
  802053:	ff 75 08             	pushl  0x8(%ebp)
  802056:	56                   	push   %esi
  802057:	50                   	push   %eax
  802058:	68 58 29 80 00       	push   $0x802958
  80205d:	e8 2b e1 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802062:	83 c4 18             	add    $0x18,%esp
  802065:	53                   	push   %ebx
  802066:	ff 75 10             	pushl  0x10(%ebp)
  802069:	e8 ca e0 ff ff       	call   800138 <vcprintf>
	cprintf("\n");
  80206e:	c7 04 24 44 29 80 00 	movl   $0x802944,(%esp)
  802075:	e8 13 e1 ff ff       	call   80018d <cprintf>
  80207a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80207d:	cc                   	int3   
  80207e:	eb fd                	jmp    80207d <_panic+0x47>

00802080 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802080:	f3 0f 1e fb          	endbr32 
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	8b 75 08             	mov    0x8(%ebp),%esi
  80208c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802092:	85 c0                	test   %eax,%eax
  802094:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802099:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80209c:	83 ec 0c             	sub    $0xc,%esp
  80209f:	50                   	push   %eax
  8020a0:	e8 61 ec ff ff       	call   800d06 <sys_ipc_recv>
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	85 c0                	test   %eax,%eax
  8020aa:	75 2b                	jne    8020d7 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8020ac:	85 f6                	test   %esi,%esi
  8020ae:	74 0a                	je     8020ba <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8020b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8020b5:	8b 40 74             	mov    0x74(%eax),%eax
  8020b8:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8020ba:	85 db                	test   %ebx,%ebx
  8020bc:	74 0a                	je     8020c8 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8020be:	a1 08 40 80 00       	mov    0x804008,%eax
  8020c3:	8b 40 78             	mov    0x78(%eax),%eax
  8020c6:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8020c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8020cd:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8020d7:	85 f6                	test   %esi,%esi
  8020d9:	74 06                	je     8020e1 <ipc_recv+0x61>
  8020db:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020e1:	85 db                	test   %ebx,%ebx
  8020e3:	74 eb                	je     8020d0 <ipc_recv+0x50>
  8020e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020eb:	eb e3                	jmp    8020d0 <ipc_recv+0x50>

008020ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ed:	f3 0f 1e fb          	endbr32 
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	57                   	push   %edi
  8020f5:	56                   	push   %esi
  8020f6:	53                   	push   %ebx
  8020f7:	83 ec 0c             	sub    $0xc,%esp
  8020fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  802100:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802103:	85 db                	test   %ebx,%ebx
  802105:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80210a:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80210d:	ff 75 14             	pushl  0x14(%ebp)
  802110:	53                   	push   %ebx
  802111:	56                   	push   %esi
  802112:	57                   	push   %edi
  802113:	e8 c7 eb ff ff       	call   800cdf <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802118:	83 c4 10             	add    $0x10,%esp
  80211b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80211e:	75 07                	jne    802127 <ipc_send+0x3a>
			sys_yield();
  802120:	e8 b8 ea ff ff       	call   800bdd <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802125:	eb e6                	jmp    80210d <ipc_send+0x20>
		}
		else if (ret == 0)
  802127:	85 c0                	test   %eax,%eax
  802129:	75 08                	jne    802133 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80212b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212e:	5b                   	pop    %ebx
  80212f:	5e                   	pop    %esi
  802130:	5f                   	pop    %edi
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802133:	50                   	push   %eax
  802134:	68 7b 29 80 00       	push   $0x80297b
  802139:	6a 48                	push   $0x48
  80213b:	68 89 29 80 00       	push   $0x802989
  802140:	e8 f1 fe ff ff       	call   802036 <_panic>

00802145 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802145:	f3 0f 1e fb          	endbr32 
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80214f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802154:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802157:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80215d:	8b 52 50             	mov    0x50(%edx),%edx
  802160:	39 ca                	cmp    %ecx,%edx
  802162:	74 11                	je     802175 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802164:	83 c0 01             	add    $0x1,%eax
  802167:	3d 00 04 00 00       	cmp    $0x400,%eax
  80216c:	75 e6                	jne    802154 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80216e:	b8 00 00 00 00       	mov    $0x0,%eax
  802173:	eb 0b                	jmp    802180 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802175:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802178:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80217d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802182:	f3 0f 1e fb          	endbr32 
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80218c:	89 c2                	mov    %eax,%edx
  80218e:	c1 ea 16             	shr    $0x16,%edx
  802191:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802198:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80219d:	f6 c1 01             	test   $0x1,%cl
  8021a0:	74 1c                	je     8021be <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8021a2:	c1 e8 0c             	shr    $0xc,%eax
  8021a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021ac:	a8 01                	test   $0x1,%al
  8021ae:	74 0e                	je     8021be <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021b0:	c1 e8 0c             	shr    $0xc,%eax
  8021b3:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021ba:	ef 
  8021bb:	0f b7 d2             	movzwl %dx,%edx
}
  8021be:	89 d0                	mov    %edx,%eax
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__udivdi3>:
  8021d0:	f3 0f 1e fb          	endbr32 
  8021d4:	55                   	push   %ebp
  8021d5:	57                   	push   %edi
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
  8021d8:	83 ec 1c             	sub    $0x1c,%esp
  8021db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021eb:	85 d2                	test   %edx,%edx
  8021ed:	75 19                	jne    802208 <__udivdi3+0x38>
  8021ef:	39 f3                	cmp    %esi,%ebx
  8021f1:	76 4d                	jbe    802240 <__udivdi3+0x70>
  8021f3:	31 ff                	xor    %edi,%edi
  8021f5:	89 e8                	mov    %ebp,%eax
  8021f7:	89 f2                	mov    %esi,%edx
  8021f9:	f7 f3                	div    %ebx
  8021fb:	89 fa                	mov    %edi,%edx
  8021fd:	83 c4 1c             	add    $0x1c,%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	76 14                	jbe    802220 <__udivdi3+0x50>
  80220c:	31 ff                	xor    %edi,%edi
  80220e:	31 c0                	xor    %eax,%eax
  802210:	89 fa                	mov    %edi,%edx
  802212:	83 c4 1c             	add    $0x1c,%esp
  802215:	5b                   	pop    %ebx
  802216:	5e                   	pop    %esi
  802217:	5f                   	pop    %edi
  802218:	5d                   	pop    %ebp
  802219:	c3                   	ret    
  80221a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802220:	0f bd fa             	bsr    %edx,%edi
  802223:	83 f7 1f             	xor    $0x1f,%edi
  802226:	75 48                	jne    802270 <__udivdi3+0xa0>
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	72 06                	jb     802232 <__udivdi3+0x62>
  80222c:	31 c0                	xor    %eax,%eax
  80222e:	39 eb                	cmp    %ebp,%ebx
  802230:	77 de                	ja     802210 <__udivdi3+0x40>
  802232:	b8 01 00 00 00       	mov    $0x1,%eax
  802237:	eb d7                	jmp    802210 <__udivdi3+0x40>
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 d9                	mov    %ebx,%ecx
  802242:	85 db                	test   %ebx,%ebx
  802244:	75 0b                	jne    802251 <__udivdi3+0x81>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f3                	div    %ebx
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	31 d2                	xor    %edx,%edx
  802253:	89 f0                	mov    %esi,%eax
  802255:	f7 f1                	div    %ecx
  802257:	89 c6                	mov    %eax,%esi
  802259:	89 e8                	mov    %ebp,%eax
  80225b:	89 f7                	mov    %esi,%edi
  80225d:	f7 f1                	div    %ecx
  80225f:	89 fa                	mov    %edi,%edx
  802261:	83 c4 1c             	add    $0x1c,%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 f9                	mov    %edi,%ecx
  802272:	b8 20 00 00 00       	mov    $0x20,%eax
  802277:	29 f8                	sub    %edi,%eax
  802279:	d3 e2                	shl    %cl,%edx
  80227b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	89 da                	mov    %ebx,%edx
  802283:	d3 ea                	shr    %cl,%edx
  802285:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802289:	09 d1                	or     %edx,%ecx
  80228b:	89 f2                	mov    %esi,%edx
  80228d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802291:	89 f9                	mov    %edi,%ecx
  802293:	d3 e3                	shl    %cl,%ebx
  802295:	89 c1                	mov    %eax,%ecx
  802297:	d3 ea                	shr    %cl,%edx
  802299:	89 f9                	mov    %edi,%ecx
  80229b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80229f:	89 eb                	mov    %ebp,%ebx
  8022a1:	d3 e6                	shl    %cl,%esi
  8022a3:	89 c1                	mov    %eax,%ecx
  8022a5:	d3 eb                	shr    %cl,%ebx
  8022a7:	09 de                	or     %ebx,%esi
  8022a9:	89 f0                	mov    %esi,%eax
  8022ab:	f7 74 24 08          	divl   0x8(%esp)
  8022af:	89 d6                	mov    %edx,%esi
  8022b1:	89 c3                	mov    %eax,%ebx
  8022b3:	f7 64 24 0c          	mull   0xc(%esp)
  8022b7:	39 d6                	cmp    %edx,%esi
  8022b9:	72 15                	jb     8022d0 <__udivdi3+0x100>
  8022bb:	89 f9                	mov    %edi,%ecx
  8022bd:	d3 e5                	shl    %cl,%ebp
  8022bf:	39 c5                	cmp    %eax,%ebp
  8022c1:	73 04                	jae    8022c7 <__udivdi3+0xf7>
  8022c3:	39 d6                	cmp    %edx,%esi
  8022c5:	74 09                	je     8022d0 <__udivdi3+0x100>
  8022c7:	89 d8                	mov    %ebx,%eax
  8022c9:	31 ff                	xor    %edi,%edi
  8022cb:	e9 40 ff ff ff       	jmp    802210 <__udivdi3+0x40>
  8022d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022d3:	31 ff                	xor    %edi,%edi
  8022d5:	e9 36 ff ff ff       	jmp    802210 <__udivdi3+0x40>
  8022da:	66 90                	xchg   %ax,%ax
  8022dc:	66 90                	xchg   %ax,%ax
  8022de:	66 90                	xchg   %ax,%ax

008022e0 <__umoddi3>:
  8022e0:	f3 0f 1e fb          	endbr32 
  8022e4:	55                   	push   %ebp
  8022e5:	57                   	push   %edi
  8022e6:	56                   	push   %esi
  8022e7:	53                   	push   %ebx
  8022e8:	83 ec 1c             	sub    $0x1c,%esp
  8022eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022fb:	85 c0                	test   %eax,%eax
  8022fd:	75 19                	jne    802318 <__umoddi3+0x38>
  8022ff:	39 df                	cmp    %ebx,%edi
  802301:	76 5d                	jbe    802360 <__umoddi3+0x80>
  802303:	89 f0                	mov    %esi,%eax
  802305:	89 da                	mov    %ebx,%edx
  802307:	f7 f7                	div    %edi
  802309:	89 d0                	mov    %edx,%eax
  80230b:	31 d2                	xor    %edx,%edx
  80230d:	83 c4 1c             	add    $0x1c,%esp
  802310:	5b                   	pop    %ebx
  802311:	5e                   	pop    %esi
  802312:	5f                   	pop    %edi
  802313:	5d                   	pop    %ebp
  802314:	c3                   	ret    
  802315:	8d 76 00             	lea    0x0(%esi),%esi
  802318:	89 f2                	mov    %esi,%edx
  80231a:	39 d8                	cmp    %ebx,%eax
  80231c:	76 12                	jbe    802330 <__umoddi3+0x50>
  80231e:	89 f0                	mov    %esi,%eax
  802320:	89 da                	mov    %ebx,%edx
  802322:	83 c4 1c             	add    $0x1c,%esp
  802325:	5b                   	pop    %ebx
  802326:	5e                   	pop    %esi
  802327:	5f                   	pop    %edi
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    
  80232a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802330:	0f bd e8             	bsr    %eax,%ebp
  802333:	83 f5 1f             	xor    $0x1f,%ebp
  802336:	75 50                	jne    802388 <__umoddi3+0xa8>
  802338:	39 d8                	cmp    %ebx,%eax
  80233a:	0f 82 e0 00 00 00    	jb     802420 <__umoddi3+0x140>
  802340:	89 d9                	mov    %ebx,%ecx
  802342:	39 f7                	cmp    %esi,%edi
  802344:	0f 86 d6 00 00 00    	jbe    802420 <__umoddi3+0x140>
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	89 ca                	mov    %ecx,%edx
  80234e:	83 c4 1c             	add    $0x1c,%esp
  802351:	5b                   	pop    %ebx
  802352:	5e                   	pop    %esi
  802353:	5f                   	pop    %edi
  802354:	5d                   	pop    %ebp
  802355:	c3                   	ret    
  802356:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	89 fd                	mov    %edi,%ebp
  802362:	85 ff                	test   %edi,%edi
  802364:	75 0b                	jne    802371 <__umoddi3+0x91>
  802366:	b8 01 00 00 00       	mov    $0x1,%eax
  80236b:	31 d2                	xor    %edx,%edx
  80236d:	f7 f7                	div    %edi
  80236f:	89 c5                	mov    %eax,%ebp
  802371:	89 d8                	mov    %ebx,%eax
  802373:	31 d2                	xor    %edx,%edx
  802375:	f7 f5                	div    %ebp
  802377:	89 f0                	mov    %esi,%eax
  802379:	f7 f5                	div    %ebp
  80237b:	89 d0                	mov    %edx,%eax
  80237d:	31 d2                	xor    %edx,%edx
  80237f:	eb 8c                	jmp    80230d <__umoddi3+0x2d>
  802381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	ba 20 00 00 00       	mov    $0x20,%edx
  80238f:	29 ea                	sub    %ebp,%edx
  802391:	d3 e0                	shl    %cl,%eax
  802393:	89 44 24 08          	mov    %eax,0x8(%esp)
  802397:	89 d1                	mov    %edx,%ecx
  802399:	89 f8                	mov    %edi,%eax
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023a9:	09 c1                	or     %eax,%ecx
  8023ab:	89 d8                	mov    %ebx,%eax
  8023ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023b1:	89 e9                	mov    %ebp,%ecx
  8023b3:	d3 e7                	shl    %cl,%edi
  8023b5:	89 d1                	mov    %edx,%ecx
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023bf:	d3 e3                	shl    %cl,%ebx
  8023c1:	89 c7                	mov    %eax,%edi
  8023c3:	89 d1                	mov    %edx,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e8                	shr    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	89 fa                	mov    %edi,%edx
  8023cd:	d3 e6                	shl    %cl,%esi
  8023cf:	09 d8                	or     %ebx,%eax
  8023d1:	f7 74 24 08          	divl   0x8(%esp)
  8023d5:	89 d1                	mov    %edx,%ecx
  8023d7:	89 f3                	mov    %esi,%ebx
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)
  8023dd:	89 c6                	mov    %eax,%esi
  8023df:	89 d7                	mov    %edx,%edi
  8023e1:	39 d1                	cmp    %edx,%ecx
  8023e3:	72 06                	jb     8023eb <__umoddi3+0x10b>
  8023e5:	75 10                	jne    8023f7 <__umoddi3+0x117>
  8023e7:	39 c3                	cmp    %eax,%ebx
  8023e9:	73 0c                	jae    8023f7 <__umoddi3+0x117>
  8023eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023f3:	89 d7                	mov    %edx,%edi
  8023f5:	89 c6                	mov    %eax,%esi
  8023f7:	89 ca                	mov    %ecx,%edx
  8023f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023fe:	29 f3                	sub    %esi,%ebx
  802400:	19 fa                	sbb    %edi,%edx
  802402:	89 d0                	mov    %edx,%eax
  802404:	d3 e0                	shl    %cl,%eax
  802406:	89 e9                	mov    %ebp,%ecx
  802408:	d3 eb                	shr    %cl,%ebx
  80240a:	d3 ea                	shr    %cl,%edx
  80240c:	09 d8                	or     %ebx,%eax
  80240e:	83 c4 1c             	add    $0x1c,%esp
  802411:	5b                   	pop    %ebx
  802412:	5e                   	pop    %esi
  802413:	5f                   	pop    %edi
  802414:	5d                   	pop    %ebp
  802415:	c3                   	ret    
  802416:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80241d:	8d 76 00             	lea    0x0(%esi),%esi
  802420:	29 fe                	sub    %edi,%esi
  802422:	19 c3                	sbb    %eax,%ebx
  802424:	89 f2                	mov    %esi,%edx
  802426:	89 d9                	mov    %ebx,%ecx
  802428:	e9 1d ff ff ff       	jmp    80234a <__umoddi3+0x6a>
