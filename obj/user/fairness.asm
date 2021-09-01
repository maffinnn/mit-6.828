
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 74 00 00 00       	call   8000a5 <libmain>
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
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003f:	e8 93 0b 00 00       	call   800bd7 <sys_getenvid>
  800044:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800046:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  80004d:	00 c0 ee 
  800050:	74 2d                	je     80007f <umain+0x4c>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800052:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	50                   	push   %eax
  80005b:	53                   	push   %ebx
  80005c:	68 d1 23 80 00       	push   $0x8023d1
  800061:	e8 44 01 00 00       	call   8001aa <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800069:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  80006e:	6a 00                	push   $0x0
  800070:	6a 00                	push   $0x0
  800072:	6a 00                	push   $0x0
  800074:	50                   	push   %eax
  800075:	e8 a7 0d 00 00       	call   800e21 <ipc_send>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	eb ea                	jmp    800069 <umain+0x36>
			ipc_recv(&who, 0, 0);
  80007f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	6a 00                	push   $0x0
  800087:	6a 00                	push   $0x0
  800089:	56                   	push   %esi
  80008a:	e8 25 0d 00 00       	call   800db4 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008f:	83 c4 0c             	add    $0xc,%esp
  800092:	ff 75 f4             	pushl  -0xc(%ebp)
  800095:	53                   	push   %ebx
  800096:	68 c0 23 80 00       	push   $0x8023c0
  80009b:	e8 0a 01 00 00       	call   8001aa <cprintf>
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	eb dd                	jmp    800082 <umain+0x4f>

008000a5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000b4:	e8 1e 0b 00 00       	call   800bd7 <sys_getenvid>
  8000b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c6:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cb:	85 db                	test   %ebx,%ebx
  8000cd:	7e 07                	jle    8000d6 <libmain+0x31>
		binaryname = argv[0];
  8000cf:	8b 06                	mov    (%esi),%eax
  8000d1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	e8 53 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0a 00 00 00       	call   8000ef <exit>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000f9:	e8 ac 0f 00 00       	call   8010aa <close_all>
	sys_env_destroy(0);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	6a 00                	push   $0x0
  800103:	e8 ab 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	f3 0f 1e fb          	endbr32 
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	53                   	push   %ebx
  800115:	83 ec 04             	sub    $0x4,%esp
  800118:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011b:	8b 13                	mov    (%ebx),%edx
  80011d:	8d 42 01             	lea    0x1(%edx),%eax
  800120:	89 03                	mov    %eax,(%ebx)
  800122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800125:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800129:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012e:	74 09                	je     800139 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800130:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800134:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800137:	c9                   	leave  
  800138:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	68 ff 00 00 00       	push   $0xff
  800141:	8d 43 08             	lea    0x8(%ebx),%eax
  800144:	50                   	push   %eax
  800145:	e8 24 0a 00 00       	call   800b6e <sys_cputs>
		b->idx = 0;
  80014a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	eb db                	jmp    800130 <putch+0x23>

00800155 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800162:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800169:	00 00 00 
	b.cnt = 0;
  80016c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800173:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	68 0d 01 80 00       	push   $0x80010d
  800188:	e8 20 01 00 00       	call   8002ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018d:	83 c4 08             	add    $0x8,%esp
  800190:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800196:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 cc 09 00 00       	call   800b6e <sys_cputs>

	return b.cnt;
}
  8001a2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001aa:	f3 0f 1e fb          	endbr32 
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b7:	50                   	push   %eax
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	e8 95 ff ff ff       	call   800155 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	57                   	push   %edi
  8001c6:	56                   	push   %esi
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 1c             	sub    $0x1c,%esp
  8001cb:	89 c7                	mov    %eax,%edi
  8001cd:	89 d6                	mov    %edx,%esi
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	89 d1                	mov    %edx,%ecx
  8001d7:	89 c2                	mov    %eax,%edx
  8001d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001df:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8001e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ef:	39 c2                	cmp    %eax,%edx
  8001f1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001f4:	72 3e                	jb     800234 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	ff 75 18             	pushl  0x18(%ebp)
  8001fc:	83 eb 01             	sub    $0x1,%ebx
  8001ff:	53                   	push   %ebx
  800200:	50                   	push   %eax
  800201:	83 ec 08             	sub    $0x8,%esp
  800204:	ff 75 e4             	pushl  -0x1c(%ebp)
  800207:	ff 75 e0             	pushl  -0x20(%ebp)
  80020a:	ff 75 dc             	pushl  -0x24(%ebp)
  80020d:	ff 75 d8             	pushl  -0x28(%ebp)
  800210:	e8 3b 1f 00 00       	call   802150 <__udivdi3>
  800215:	83 c4 18             	add    $0x18,%esp
  800218:	52                   	push   %edx
  800219:	50                   	push   %eax
  80021a:	89 f2                	mov    %esi,%edx
  80021c:	89 f8                	mov    %edi,%eax
  80021e:	e8 9f ff ff ff       	call   8001c2 <printnum>
  800223:	83 c4 20             	add    $0x20,%esp
  800226:	eb 13                	jmp    80023b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	56                   	push   %esi
  80022c:	ff 75 18             	pushl  0x18(%ebp)
  80022f:	ff d7                	call   *%edi
  800231:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f ed                	jg     800228 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 0d 20 00 00       	call   802260 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 f2 23 80 00 	movsbl 0x8023f2(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026b:	f3 0f 1e fb          	endbr32 
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800275:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	3b 50 04             	cmp    0x4(%eax),%edx
  80027e:	73 0a                	jae    80028a <sprintputch+0x1f>
		*b->buf++ = ch;
  800280:	8d 4a 01             	lea    0x1(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	88 02                	mov    %al,(%edx)
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <printfmt>:
{
  80028c:	f3 0f 1e fb          	endbr32 
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800296:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 10             	pushl  0x10(%ebp)
  80029d:	ff 75 0c             	pushl  0xc(%ebp)
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	e8 05 00 00 00       	call   8002ad <vprintfmt>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <vprintfmt>:
{
  8002ad:	f3 0f 1e fb          	endbr32 
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 3c             	sub    $0x3c,%esp
  8002ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c3:	e9 8e 03 00 00       	jmp    800656 <vprintfmt+0x3a9>
		padc = ' ';
  8002c8:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002cc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002d3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	8d 47 01             	lea    0x1(%edi),%eax
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	0f b6 17             	movzbl (%edi),%edx
  8002ef:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 df 03 00 00    	ja     8006d9 <vprintfmt+0x42c>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	3e ff 24 85 40 25 80 	notrack jmp *0x802540(,%eax,4)
  800304:	00 
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800308:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80030c:	eb d8                	jmp    8002e6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800311:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800315:	eb cf                	jmp    8002e6 <vprintfmt+0x39>
  800317:	0f b6 d2             	movzbl %dl,%edx
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031d:	b8 00 00 00 00       	mov    $0x0,%eax
  800322:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800325:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800328:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800332:	83 f9 09             	cmp    $0x9,%ecx
  800335:	77 55                	ja     80038c <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800337:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80033a:	eb e9                	jmp    800325 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8b 00                	mov    (%eax),%eax
  800341:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8d 40 04             	lea    0x4(%eax),%eax
  80034a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800350:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800354:	79 90                	jns    8002e6 <vprintfmt+0x39>
				width = precision, precision = -1;
  800356:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800359:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800363:	eb 81                	jmp    8002e6 <vprintfmt+0x39>
  800365:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800368:	85 c0                	test   %eax,%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	0f 49 d0             	cmovns %eax,%edx
  800372:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800378:	e9 69 ff ff ff       	jmp    8002e6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800380:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800387:	e9 5a ff ff ff       	jmp    8002e6 <vprintfmt+0x39>
  80038c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80038f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800392:	eb bc                	jmp    800350 <vprintfmt+0xa3>
			lflag++;
  800394:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039a:	e9 47 ff ff ff       	jmp    8002e6 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 78 04             	lea    0x4(%eax),%edi
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	ff 30                	pushl  (%eax)
  8003ab:	ff d6                	call   *%esi
			break;
  8003ad:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b3:	e9 9b 02 00 00       	jmp    800653 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 78 04             	lea    0x4(%eax),%edi
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	99                   	cltd   
  8003c1:	31 d0                	xor    %edx,%eax
  8003c3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c5:	83 f8 0f             	cmp    $0xf,%eax
  8003c8:	7f 23                	jg     8003ed <vprintfmt+0x140>
  8003ca:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	74 18                	je     8003ed <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003d5:	52                   	push   %edx
  8003d6:	68 c1 27 80 00       	push   $0x8027c1
  8003db:	53                   	push   %ebx
  8003dc:	56                   	push   %esi
  8003dd:	e8 aa fe ff ff       	call   80028c <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e8:	e9 66 02 00 00       	jmp    800653 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003ed:	50                   	push   %eax
  8003ee:	68 0a 24 80 00       	push   $0x80240a
  8003f3:	53                   	push   %ebx
  8003f4:	56                   	push   %esi
  8003f5:	e8 92 fe ff ff       	call   80028c <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 4e 02 00 00       	jmp    800653 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	83 c0 04             	add    $0x4,%eax
  80040b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800413:	85 d2                	test   %edx,%edx
  800415:	b8 03 24 80 00       	mov    $0x802403,%eax
  80041a:	0f 45 c2             	cmovne %edx,%eax
  80041d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800424:	7e 06                	jle    80042c <vprintfmt+0x17f>
  800426:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80042a:	75 0d                	jne    800439 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80042f:	89 c7                	mov    %eax,%edi
  800431:	03 45 e0             	add    -0x20(%ebp),%eax
  800434:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800437:	eb 55                	jmp    80048e <vprintfmt+0x1e1>
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	ff 75 d8             	pushl  -0x28(%ebp)
  80043f:	ff 75 cc             	pushl  -0x34(%ebp)
  800442:	e8 46 03 00 00       	call   80078d <strnlen>
  800447:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80044a:	29 c2                	sub    %eax,%edx
  80044c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800454:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	85 ff                	test   %edi,%edi
  80045d:	7e 11                	jle    800470 <vprintfmt+0x1c3>
					putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	ff 75 e0             	pushl  -0x20(%ebp)
  800466:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	83 ef 01             	sub    $0x1,%edi
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	eb eb                	jmp    80045b <vprintfmt+0x1ae>
  800470:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800473:	85 d2                	test   %edx,%edx
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	0f 49 c2             	cmovns %edx,%eax
  80047d:	29 c2                	sub    %eax,%edx
  80047f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800482:	eb a8                	jmp    80042c <vprintfmt+0x17f>
					putch(ch, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	52                   	push   %edx
  800489:	ff d6                	call   *%esi
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800491:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800493:	83 c7 01             	add    $0x1,%edi
  800496:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049a:	0f be d0             	movsbl %al,%edx
  80049d:	85 d2                	test   %edx,%edx
  80049f:	74 4b                	je     8004ec <vprintfmt+0x23f>
  8004a1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a5:	78 06                	js     8004ad <vprintfmt+0x200>
  8004a7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ab:	78 1e                	js     8004cb <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8004ad:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b1:	74 d1                	je     800484 <vprintfmt+0x1d7>
  8004b3:	0f be c0             	movsbl %al,%eax
  8004b6:	83 e8 20             	sub    $0x20,%eax
  8004b9:	83 f8 5e             	cmp    $0x5e,%eax
  8004bc:	76 c6                	jbe    800484 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	53                   	push   %ebx
  8004c2:	6a 3f                	push   $0x3f
  8004c4:	ff d6                	call   *%esi
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	eb c3                	jmp    80048e <vprintfmt+0x1e1>
  8004cb:	89 cf                	mov    %ecx,%edi
  8004cd:	eb 0e                	jmp    8004dd <vprintfmt+0x230>
				putch(' ', putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	53                   	push   %ebx
  8004d3:	6a 20                	push   $0x20
  8004d5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ee                	jg     8004cf <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e7:	e9 67 01 00 00       	jmp    800653 <vprintfmt+0x3a6>
  8004ec:	89 cf                	mov    %ecx,%edi
  8004ee:	eb ed                	jmp    8004dd <vprintfmt+0x230>
	if (lflag >= 2)
  8004f0:	83 f9 01             	cmp    $0x1,%ecx
  8004f3:	7f 1b                	jg     800510 <vprintfmt+0x263>
	else if (lflag)
  8004f5:	85 c9                	test   %ecx,%ecx
  8004f7:	74 63                	je     80055c <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8b 00                	mov    (%eax),%eax
  8004fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800501:	99                   	cltd   
  800502:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 40 04             	lea    0x4(%eax),%eax
  80050b:	89 45 14             	mov    %eax,0x14(%ebp)
  80050e:	eb 17                	jmp    800527 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 50 04             	mov    0x4(%eax),%edx
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 40 08             	lea    0x8(%eax),%eax
  800524:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800527:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80052d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800532:	85 c9                	test   %ecx,%ecx
  800534:	0f 89 ff 00 00 00    	jns    800639 <vprintfmt+0x38c>
				putch('-', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	53                   	push   %ebx
  80053e:	6a 2d                	push   $0x2d
  800540:	ff d6                	call   *%esi
				num = -(long long) num;
  800542:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800545:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800548:	f7 da                	neg    %edx
  80054a:	83 d1 00             	adc    $0x0,%ecx
  80054d:	f7 d9                	neg    %ecx
  80054f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
  800557:	e9 dd 00 00 00       	jmp    800639 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	99                   	cltd   
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 40 04             	lea    0x4(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	eb b4                	jmp    800527 <vprintfmt+0x27a>
	if (lflag >= 2)
  800573:	83 f9 01             	cmp    $0x1,%ecx
  800576:	7f 1e                	jg     800596 <vprintfmt+0x2e9>
	else if (lflag)
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	74 32                	je     8005ae <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 10                	mov    (%eax),%edx
  800581:	b9 00 00 00 00       	mov    $0x0,%ecx
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800591:	e9 a3 00 00 00       	jmp    800639 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	8b 48 04             	mov    0x4(%eax),%ecx
  80059e:	8d 40 08             	lea    0x8(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a9:	e9 8b 00 00 00       	jmp    800639 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005c3:	eb 74                	jmp    800639 <vprintfmt+0x38c>
	if (lflag >= 2)
  8005c5:	83 f9 01             	cmp    $0x1,%ecx
  8005c8:	7f 1b                	jg     8005e5 <vprintfmt+0x338>
	else if (lflag)
  8005ca:	85 c9                	test   %ecx,%ecx
  8005cc:	74 2c                	je     8005fa <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005de:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005e3:	eb 54                	jmp    800639 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8b 10                	mov    (%eax),%edx
  8005ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ed:	8d 40 08             	lea    0x8(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005f3:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005f8:	eb 3f                	jmp    800639 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8b 10                	mov    (%eax),%edx
  8005ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800604:	8d 40 04             	lea    0x4(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80060a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80060f:	eb 28                	jmp    800639 <vprintfmt+0x38c>
			putch('0', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 30                	push   $0x30
  800617:	ff d6                	call   *%esi
			putch('x', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 78                	push   $0x78
  80061f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800634:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800639:	83 ec 0c             	sub    $0xc,%esp
  80063c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800640:	57                   	push   %edi
  800641:	ff 75 e0             	pushl  -0x20(%ebp)
  800644:	50                   	push   %eax
  800645:	51                   	push   %ecx
  800646:	52                   	push   %edx
  800647:	89 da                	mov    %ebx,%edx
  800649:	89 f0                	mov    %esi,%eax
  80064b:	e8 72 fb ff ff       	call   8001c2 <printnum>
			break;
  800650:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800656:	83 c7 01             	add    $0x1,%edi
  800659:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065d:	83 f8 25             	cmp    $0x25,%eax
  800660:	0f 84 62 fc ff ff    	je     8002c8 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800666:	85 c0                	test   %eax,%eax
  800668:	0f 84 8b 00 00 00    	je     8006f9 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	ff d6                	call   *%esi
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	eb dc                	jmp    800656 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80067a:	83 f9 01             	cmp    $0x1,%ecx
  80067d:	7f 1b                	jg     80069a <vprintfmt+0x3ed>
	else if (lflag)
  80067f:	85 c9                	test   %ecx,%ecx
  800681:	74 2c                	je     8006af <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800698:	eb 9f                	jmp    800639 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8b 10                	mov    (%eax),%edx
  80069f:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a2:	8d 40 08             	lea    0x8(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006ad:	eb 8a                	jmp    800639 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006c4:	e9 70 ff ff ff       	jmp    800639 <vprintfmt+0x38c>
			putch(ch, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 25                	push   $0x25
  8006cf:	ff d6                	call   *%esi
			break;
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	e9 7a ff ff ff       	jmp    800653 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	6a 25                	push   $0x25
  8006df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	89 f8                	mov    %edi,%eax
  8006e6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006ea:	74 05                	je     8006f1 <vprintfmt+0x444>
  8006ec:	83 e8 01             	sub    $0x1,%eax
  8006ef:	eb f5                	jmp    8006e6 <vprintfmt+0x439>
  8006f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f4:	e9 5a ff ff ff       	jmp    800653 <vprintfmt+0x3a6>
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800701:	f3 0f 1e fb          	endbr32 
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800711:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800714:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800718:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800722:	85 c0                	test   %eax,%eax
  800724:	74 26                	je     80074c <vsnprintf+0x4b>
  800726:	85 d2                	test   %edx,%edx
  800728:	7e 22                	jle    80074c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072a:	ff 75 14             	pushl  0x14(%ebp)
  80072d:	ff 75 10             	pushl  0x10(%ebp)
  800730:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800733:	50                   	push   %eax
  800734:	68 6b 02 80 00       	push   $0x80026b
  800739:	e8 6f fb ff ff       	call   8002ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800741:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800747:	83 c4 10             	add    $0x10,%esp
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    
		return -E_INVAL;
  80074c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800751:	eb f7                	jmp    80074a <vsnprintf+0x49>

00800753 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800753:	f3 0f 1e fb          	endbr32 
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80075d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800760:	50                   	push   %eax
  800761:	ff 75 10             	pushl  0x10(%ebp)
  800764:	ff 75 0c             	pushl  0xc(%ebp)
  800767:	ff 75 08             	pushl  0x8(%ebp)
  80076a:	e8 92 ff ff ff       	call   800701 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800771:	f3 0f 1e fb          	endbr32 
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
  800780:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800784:	74 05                	je     80078b <strlen+0x1a>
		n++;
  800786:	83 c0 01             	add    $0x1,%eax
  800789:	eb f5                	jmp    800780 <strlen+0xf>
	return n;
}
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078d:	f3 0f 1e fb          	endbr32 
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
  80079f:	39 d0                	cmp    %edx,%eax
  8007a1:	74 0d                	je     8007b0 <strnlen+0x23>
  8007a3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a7:	74 05                	je     8007ae <strnlen+0x21>
		n++;
  8007a9:	83 c0 01             	add    $0x1,%eax
  8007ac:	eb f1                	jmp    80079f <strnlen+0x12>
  8007ae:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b0:	89 d0                	mov    %edx,%eax
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b4:	f3 0f 1e fb          	endbr32 
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007cb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ce:	83 c0 01             	add    $0x1,%eax
  8007d1:	84 d2                	test   %dl,%dl
  8007d3:	75 f2                	jne    8007c7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007d5:	89 c8                	mov    %ecx,%eax
  8007d7:	5b                   	pop    %ebx
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007da:	f3 0f 1e fb          	endbr32 
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	83 ec 10             	sub    $0x10,%esp
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e8:	53                   	push   %ebx
  8007e9:	e8 83 ff ff ff       	call   800771 <strlen>
  8007ee:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	01 d8                	add    %ebx,%eax
  8007f6:	50                   	push   %eax
  8007f7:	e8 b8 ff ff ff       	call   8007b4 <strcpy>
	return dst;
}
  8007fc:	89 d8                	mov    %ebx,%eax
  8007fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800803:	f3 0f 1e fb          	endbr32 
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 75 08             	mov    0x8(%ebp),%esi
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	89 f3                	mov    %esi,%ebx
  800814:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800817:	89 f0                	mov    %esi,%eax
  800819:	39 d8                	cmp    %ebx,%eax
  80081b:	74 11                	je     80082e <strncpy+0x2b>
		*dst++ = *src;
  80081d:	83 c0 01             	add    $0x1,%eax
  800820:	0f b6 0a             	movzbl (%edx),%ecx
  800823:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800826:	80 f9 01             	cmp    $0x1,%cl
  800829:	83 da ff             	sbb    $0xffffffff,%edx
  80082c:	eb eb                	jmp    800819 <strncpy+0x16>
	}
	return ret;
}
  80082e:	89 f0                	mov    %esi,%eax
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800834:	f3 0f 1e fb          	endbr32 
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800843:	8b 55 10             	mov    0x10(%ebp),%edx
  800846:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	85 d2                	test   %edx,%edx
  80084a:	74 21                	je     80086d <strlcpy+0x39>
  80084c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800850:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800852:	39 c2                	cmp    %eax,%edx
  800854:	74 14                	je     80086a <strlcpy+0x36>
  800856:	0f b6 19             	movzbl (%ecx),%ebx
  800859:	84 db                	test   %bl,%bl
  80085b:	74 0b                	je     800868 <strlcpy+0x34>
			*dst++ = *src++;
  80085d:	83 c1 01             	add    $0x1,%ecx
  800860:	83 c2 01             	add    $0x1,%edx
  800863:	88 5a ff             	mov    %bl,-0x1(%edx)
  800866:	eb ea                	jmp    800852 <strlcpy+0x1e>
  800868:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086d:	29 f0                	sub    %esi,%eax
}
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800873:	f3 0f 1e fb          	endbr32 
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800880:	0f b6 01             	movzbl (%ecx),%eax
  800883:	84 c0                	test   %al,%al
  800885:	74 0c                	je     800893 <strcmp+0x20>
  800887:	3a 02                	cmp    (%edx),%al
  800889:	75 08                	jne    800893 <strcmp+0x20>
		p++, q++;
  80088b:	83 c1 01             	add    $0x1,%ecx
  80088e:	83 c2 01             	add    $0x1,%edx
  800891:	eb ed                	jmp    800880 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 c0             	movzbl %al,%eax
  800896:	0f b6 12             	movzbl (%edx),%edx
  800899:	29 d0                	sub    %edx,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089d:	f3 0f 1e fb          	endbr32 
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strncmp+0x1b>
		n--, p++, q++;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 16                	je     8008d2 <strncmp+0x35>
  8008bc:	0f b6 08             	movzbl (%eax),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 04                	je     8008c7 <strncmp+0x2a>
  8008c3:	3a 0a                	cmp    (%edx),%cl
  8008c5:	74 eb                	je     8008b2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 12             	movzbl (%edx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    
		return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	eb f6                	jmp    8008cf <strncmp+0x32>

008008d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d9:	f3 0f 1e fb          	endbr32 
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e7:	0f b6 10             	movzbl (%eax),%edx
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	74 09                	je     8008f7 <strchr+0x1e>
		if (*s == c)
  8008ee:	38 ca                	cmp    %cl,%dl
  8008f0:	74 0a                	je     8008fc <strchr+0x23>
	for (; *s; s++)
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	eb f0                	jmp    8008e7 <strchr+0xe>
			return (char *) s;
	return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8008fe:	f3 0f 1e fb          	endbr32 
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800908:	6a 78                	push   $0x78
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 c7 ff ff ff       	call   8008d9 <strchr>
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  80091d:	eb 0d                	jmp    80092c <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  80091f:	c1 e0 04             	shl    $0x4,%eax
  800922:	0f be d2             	movsbl %dl,%edx
  800925:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	0f b6 11             	movzbl (%ecx),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	74 11                	je     800944 <atox+0x46>
		if (*p>='a'){
  800933:	80 fa 60             	cmp    $0x60,%dl
  800936:	7e e7                	jle    80091f <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800938:	c1 e0 04             	shl    $0x4,%eax
  80093b:	0f be d2             	movsbl %dl,%edx
  80093e:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800942:	eb e5                	jmp    800929 <atox+0x2b>
	}

	return v;

}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800946:	f3 0f 1e fb          	endbr32 
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800954:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 09                	je     800964 <strfind+0x1e>
  80095b:	84 d2                	test   %dl,%dl
  80095d:	74 05                	je     800964 <strfind+0x1e>
	for (; *s; s++)
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	eb f0                	jmp    800954 <strfind+0xe>
			break;
	return (char *) s;
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800966:	f3 0f 1e fb          	endbr32 
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 7d 08             	mov    0x8(%ebp),%edi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800976:	85 c9                	test   %ecx,%ecx
  800978:	74 31                	je     8009ab <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097a:	89 f8                	mov    %edi,%eax
  80097c:	09 c8                	or     %ecx,%eax
  80097e:	a8 03                	test   $0x3,%al
  800980:	75 23                	jne    8009a5 <memset+0x3f>
		c &= 0xFF;
  800982:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800986:	89 d3                	mov    %edx,%ebx
  800988:	c1 e3 08             	shl    $0x8,%ebx
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	c1 e0 18             	shl    $0x18,%eax
  800990:	89 d6                	mov    %edx,%esi
  800992:	c1 e6 10             	shl    $0x10,%esi
  800995:	09 f0                	or     %esi,%eax
  800997:	09 c2                	or     %eax,%edx
  800999:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80099e:	89 d0                	mov    %edx,%eax
  8009a0:	fc                   	cld    
  8009a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a3:	eb 06                	jmp    8009ab <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	fc                   	cld    
  8009a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ab:	89 f8                	mov    %edi,%eax
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b2:	f3 0f 1e fb          	endbr32 
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c4:	39 c6                	cmp    %eax,%esi
  8009c6:	73 32                	jae    8009fa <memmove+0x48>
  8009c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009cb:	39 c2                	cmp    %eax,%edx
  8009cd:	76 2b                	jbe    8009fa <memmove+0x48>
		s += n;
		d += n;
  8009cf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	89 fe                	mov    %edi,%esi
  8009d4:	09 ce                	or     %ecx,%esi
  8009d6:	09 d6                	or     %edx,%esi
  8009d8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009de:	75 0e                	jne    8009ee <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e0:	83 ef 04             	sub    $0x4,%edi
  8009e3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e9:	fd                   	std    
  8009ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ec:	eb 09                	jmp    8009f7 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ee:	83 ef 01             	sub    $0x1,%edi
  8009f1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f4:	fd                   	std    
  8009f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f7:	fc                   	cld    
  8009f8:	eb 1a                	jmp    800a14 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	09 ca                	or     %ecx,%edx
  8009fe:	09 f2                	or     %esi,%edx
  800a00:	f6 c2 03             	test   $0x3,%dl
  800a03:	75 0a                	jne    800a0f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a05:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a08:	89 c7                	mov    %eax,%edi
  800a0a:	fc                   	cld    
  800a0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0d:	eb 05                	jmp    800a14 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a0f:	89 c7                	mov    %eax,%edi
  800a11:	fc                   	cld    
  800a12:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a14:	5e                   	pop    %esi
  800a15:	5f                   	pop    %edi
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a18:	f3 0f 1e fb          	endbr32 
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a22:	ff 75 10             	pushl  0x10(%ebp)
  800a25:	ff 75 0c             	pushl  0xc(%ebp)
  800a28:	ff 75 08             	pushl  0x8(%ebp)
  800a2b:	e8 82 ff ff ff       	call   8009b2 <memmove>
}
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a32:	f3 0f 1e fb          	endbr32 
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a41:	89 c6                	mov    %eax,%esi
  800a43:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a46:	39 f0                	cmp    %esi,%eax
  800a48:	74 1c                	je     800a66 <memcmp+0x34>
		if (*s1 != *s2)
  800a4a:	0f b6 08             	movzbl (%eax),%ecx
  800a4d:	0f b6 1a             	movzbl (%edx),%ebx
  800a50:	38 d9                	cmp    %bl,%cl
  800a52:	75 08                	jne    800a5c <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	eb ea                	jmp    800a46 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a5c:	0f b6 c1             	movzbl %cl,%eax
  800a5f:	0f b6 db             	movzbl %bl,%ebx
  800a62:	29 d8                	sub    %ebx,%eax
  800a64:	eb 05                	jmp    800a6b <memcmp+0x39>
	}

	return 0;
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6f:	f3 0f 1e fb          	endbr32 
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a7c:	89 c2                	mov    %eax,%edx
  800a7e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a81:	39 d0                	cmp    %edx,%eax
  800a83:	73 09                	jae    800a8e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a85:	38 08                	cmp    %cl,(%eax)
  800a87:	74 05                	je     800a8e <memfind+0x1f>
	for (; s < ends; s++)
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	eb f3                	jmp    800a81 <memfind+0x12>
			break;
	return (void *) s;
}
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a90:	f3 0f 1e fb          	endbr32 
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa0:	eb 03                	jmp    800aa5 <strtol+0x15>
		s++;
  800aa2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa5:	0f b6 01             	movzbl (%ecx),%eax
  800aa8:	3c 20                	cmp    $0x20,%al
  800aaa:	74 f6                	je     800aa2 <strtol+0x12>
  800aac:	3c 09                	cmp    $0x9,%al
  800aae:	74 f2                	je     800aa2 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ab0:	3c 2b                	cmp    $0x2b,%al
  800ab2:	74 2a                	je     800ade <strtol+0x4e>
	int neg = 0;
  800ab4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab9:	3c 2d                	cmp    $0x2d,%al
  800abb:	74 2b                	je     800ae8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac3:	75 0f                	jne    800ad4 <strtol+0x44>
  800ac5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac8:	74 28                	je     800af2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ad1:	0f 44 d8             	cmove  %eax,%ebx
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800adc:	eb 46                	jmp    800b24 <strtol+0x94>
		s++;
  800ade:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ae1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae6:	eb d5                	jmp    800abd <strtol+0x2d>
		s++, neg = 1;
  800ae8:	83 c1 01             	add    $0x1,%ecx
  800aeb:	bf 01 00 00 00       	mov    $0x1,%edi
  800af0:	eb cb                	jmp    800abd <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af6:	74 0e                	je     800b06 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af8:	85 db                	test   %ebx,%ebx
  800afa:	75 d8                	jne    800ad4 <strtol+0x44>
		s++, base = 8;
  800afc:	83 c1 01             	add    $0x1,%ecx
  800aff:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b04:	eb ce                	jmp    800ad4 <strtol+0x44>
		s += 2, base = 16;
  800b06:	83 c1 02             	add    $0x2,%ecx
  800b09:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b0e:	eb c4                	jmp    800ad4 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b16:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b19:	7d 3a                	jge    800b55 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b1b:	83 c1 01             	add    $0x1,%ecx
  800b1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b22:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b24:	0f b6 11             	movzbl (%ecx),%edx
  800b27:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b2a:	89 f3                	mov    %esi,%ebx
  800b2c:	80 fb 09             	cmp    $0x9,%bl
  800b2f:	76 df                	jbe    800b10 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b34:	89 f3                	mov    %esi,%ebx
  800b36:	80 fb 19             	cmp    $0x19,%bl
  800b39:	77 08                	ja     800b43 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3b:	0f be d2             	movsbl %dl,%edx
  800b3e:	83 ea 57             	sub    $0x57,%edx
  800b41:	eb d3                	jmp    800b16 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b43:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b46:	89 f3                	mov    %esi,%ebx
  800b48:	80 fb 19             	cmp    $0x19,%bl
  800b4b:	77 08                	ja     800b55 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b4d:	0f be d2             	movsbl %dl,%edx
  800b50:	83 ea 37             	sub    $0x37,%edx
  800b53:	eb c1                	jmp    800b16 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b59:	74 05                	je     800b60 <strtol+0xd0>
		*endptr = (char *) s;
  800b5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b60:	89 c2                	mov    %eax,%edx
  800b62:	f7 da                	neg    %edx
  800b64:	85 ff                	test   %edi,%edi
  800b66:	0f 45 c2             	cmovne %edx,%eax
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b6e:	f3 0f 1e fb          	endbr32 
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	89 c3                	mov    %eax,%ebx
  800b85:	89 c7                	mov    %eax,%edi
  800b87:	89 c6                	mov    %eax,%esi
  800b89:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b90:	f3 0f 1e fb          	endbr32 
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bca:	89 cb                	mov    %ecx,%ebx
  800bcc:	89 cf                	mov    %ecx,%edi
  800bce:	89 ce                	mov    %ecx,%esi
  800bd0:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd7:	f3 0f 1e fb          	endbr32 
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 02 00 00 00       	mov    $0x2,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_yield>:

void
sys_yield(void)
{
  800bfa:	f3 0f 1e fb          	endbr32 
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1d:	f3 0f 1e fb          	endbr32 
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c27:	be 00 00 00 00       	mov    $0x0,%esi
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	b8 04 00 00 00       	mov    $0x4,%eax
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	89 f7                	mov    %esi,%edi
  800c3c:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c43:	f3 0f 1e fb          	endbr32 
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	b8 05 00 00 00       	mov    $0x5,%eax
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c61:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c68:	f3 0f 1e fb          	endbr32 
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c82:	89 df                	mov    %ebx,%edi
  800c84:	89 de                	mov    %ebx,%esi
  800c86:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8d:	f3 0f 1e fb          	endbr32 
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb2:	f3 0f 1e fb          	endbr32 
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccc:	89 df                	mov    %ebx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfc:	f3 0f 1e fb          	endbr32 
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d11:	be 00 00 00 00       	mov    $0x0,%esi
  800d16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d23:	f3 0f 1e fb          	endbr32 
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3a:	89 cb                	mov    %ecx,%ebx
  800d3c:	89 cf                	mov    %ecx,%edi
  800d3e:	89 ce                	mov    %ecx,%esi
  800d40:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d47:	f3 0f 1e fb          	endbr32 
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d51:	ba 00 00 00 00       	mov    $0x0,%edx
  800d56:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5b:	89 d1                	mov    %edx,%ecx
  800d5d:	89 d3                	mov    %edx,%ebx
  800d5f:	89 d7                	mov    %edx,%edi
  800d61:	89 d6                	mov    %edx,%esi
  800d63:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d6a:	f3 0f 1e fb          	endbr32 
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	89 de                	mov    %ebx,%esi
  800d88:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800d8f:	f3 0f 1e fb          	endbr32 
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	b8 10 00 00 00       	mov    $0x10,%eax
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800db4:	f3 0f 1e fb          	endbr32 
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800dcd:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	50                   	push   %eax
  800dd4:	e8 4a ff ff ff       	call   800d23 <sys_ipc_recv>
  800dd9:	83 c4 10             	add    $0x10,%esp
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	75 2b                	jne    800e0b <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  800de0:	85 f6                	test   %esi,%esi
  800de2:	74 0a                	je     800dee <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  800de4:	a1 08 40 80 00       	mov    0x804008,%eax
  800de9:	8b 40 74             	mov    0x74(%eax),%eax
  800dec:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  800dee:	85 db                	test   %ebx,%ebx
  800df0:	74 0a                	je     800dfc <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  800df2:	a1 08 40 80 00       	mov    0x804008,%eax
  800df7:	8b 40 78             	mov    0x78(%eax),%eax
  800dfa:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  800dfc:	a1 08 40 80 00       	mov    0x804008,%eax
  800e01:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  800e0b:	85 f6                	test   %esi,%esi
  800e0d:	74 06                	je     800e15 <ipc_recv+0x61>
  800e0f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  800e15:	85 db                	test   %ebx,%ebx
  800e17:	74 eb                	je     800e04 <ipc_recv+0x50>
  800e19:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e1f:	eb e3                	jmp    800e04 <ipc_recv+0x50>

00800e21 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e21:	f3 0f 1e fb          	endbr32 
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  800e37:	85 db                	test   %ebx,%ebx
  800e39:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e3e:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  800e41:	ff 75 14             	pushl  0x14(%ebp)
  800e44:	53                   	push   %ebx
  800e45:	56                   	push   %esi
  800e46:	57                   	push   %edi
  800e47:	e8 b0 fe ff ff       	call   800cfc <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e52:	75 07                	jne    800e5b <ipc_send+0x3a>
			sys_yield();
  800e54:	e8 a1 fd ff ff       	call   800bfa <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  800e59:	eb e6                	jmp    800e41 <ipc_send+0x20>
		}
		else if (ret == 0)
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	75 08                	jne    800e67 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  800e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  800e67:	50                   	push   %eax
  800e68:	68 ff 26 80 00       	push   $0x8026ff
  800e6d:	6a 48                	push   $0x48
  800e6f:	68 0d 27 80 00       	push   $0x80270d
  800e74:	e8 45 12 00 00       	call   8020be <_panic>

00800e79 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e79:	f3 0f 1e fb          	endbr32 
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e88:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e8b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e91:	8b 52 50             	mov    0x50(%edx),%edx
  800e94:	39 ca                	cmp    %ecx,%edx
  800e96:	74 11                	je     800ea9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  800e98:	83 c0 01             	add    $0x1,%eax
  800e9b:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ea0:	75 e6                	jne    800e88 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb 0b                	jmp    800eb4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  800ea9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb1:	8b 40 48             	mov    0x48(%eax),%eax
}
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eb6:	f3 0f 1e fb          	endbr32 
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ec5:	c1 e8 0c             	shr    $0xc,%eax
}
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eca:	f3 0f 1e fb          	endbr32 
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed4:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ed9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ede:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ee5:	f3 0f 1e fb          	endbr32 
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef1:	89 c2                	mov    %eax,%edx
  800ef3:	c1 ea 16             	shr    $0x16,%edx
  800ef6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efd:	f6 c2 01             	test   $0x1,%dl
  800f00:	74 2d                	je     800f2f <fd_alloc+0x4a>
  800f02:	89 c2                	mov    %eax,%edx
  800f04:	c1 ea 0c             	shr    $0xc,%edx
  800f07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0e:	f6 c2 01             	test   $0x1,%dl
  800f11:	74 1c                	je     800f2f <fd_alloc+0x4a>
  800f13:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f18:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f1d:	75 d2                	jne    800ef1 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f28:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f2d:	eb 0a                	jmp    800f39 <fd_alloc+0x54>
			*fd_store = fd;
  800f2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f32:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f3b:	f3 0f 1e fb          	endbr32 
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f45:	83 f8 1f             	cmp    $0x1f,%eax
  800f48:	77 30                	ja     800f7a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4a:	c1 e0 0c             	shl    $0xc,%eax
  800f4d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f52:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f58:	f6 c2 01             	test   $0x1,%dl
  800f5b:	74 24                	je     800f81 <fd_lookup+0x46>
  800f5d:	89 c2                	mov    %eax,%edx
  800f5f:	c1 ea 0c             	shr    $0xc,%edx
  800f62:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	74 1a                	je     800f88 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f71:	89 02                	mov    %eax,(%edx)
	return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    
		return -E_INVAL;
  800f7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7f:	eb f7                	jmp    800f78 <fd_lookup+0x3d>
		return -E_INVAL;
  800f81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f86:	eb f0                	jmp    800f78 <fd_lookup+0x3d>
  800f88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8d:	eb e9                	jmp    800f78 <fd_lookup+0x3d>

00800f8f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f8f:	f3 0f 1e fb          	endbr32 
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa1:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800fa6:	39 08                	cmp    %ecx,(%eax)
  800fa8:	74 38                	je     800fe2 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800faa:	83 c2 01             	add    $0x1,%edx
  800fad:	8b 04 95 94 27 80 00 	mov    0x802794(,%edx,4),%eax
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	75 ee                	jne    800fa6 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb8:	a1 08 40 80 00       	mov    0x804008,%eax
  800fbd:	8b 40 48             	mov    0x48(%eax),%eax
  800fc0:	83 ec 04             	sub    $0x4,%esp
  800fc3:	51                   	push   %ecx
  800fc4:	50                   	push   %eax
  800fc5:	68 18 27 80 00       	push   $0x802718
  800fca:	e8 db f1 ff ff       	call   8001aa <cprintf>
	*dev = 0;
  800fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    
			*dev = devtab[i];
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fe7:	b8 00 00 00 00       	mov    $0x0,%eax
  800fec:	eb f2                	jmp    800fe0 <dev_lookup+0x51>

00800fee <fd_close>:
{
  800fee:	f3 0f 1e fb          	endbr32 
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	83 ec 24             	sub    $0x24,%esp
  800ffb:	8b 75 08             	mov    0x8(%ebp),%esi
  800ffe:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801001:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801004:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801005:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80100b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80100e:	50                   	push   %eax
  80100f:	e8 27 ff ff ff       	call   800f3b <fd_lookup>
  801014:	89 c3                	mov    %eax,%ebx
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 05                	js     801022 <fd_close+0x34>
	    || fd != fd2)
  80101d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801020:	74 16                	je     801038 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801022:	89 f8                	mov    %edi,%eax
  801024:	84 c0                	test   %al,%al
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	0f 44 d8             	cmove  %eax,%ebx
}
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80103e:	50                   	push   %eax
  80103f:	ff 36                	pushl  (%esi)
  801041:	e8 49 ff ff ff       	call   800f8f <dev_lookup>
  801046:	89 c3                	mov    %eax,%ebx
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 1a                	js     801069 <fd_close+0x7b>
		if (dev->dev_close)
  80104f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801052:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801055:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80105a:	85 c0                	test   %eax,%eax
  80105c:	74 0b                	je     801069 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	56                   	push   %esi
  801062:	ff d0                	call   *%eax
  801064:	89 c3                	mov    %eax,%ebx
  801066:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	56                   	push   %esi
  80106d:	6a 00                	push   $0x0
  80106f:	e8 f4 fb ff ff       	call   800c68 <sys_page_unmap>
	return r;
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	eb b5                	jmp    80102e <fd_close+0x40>

00801079 <close>:

int
close(int fdnum)
{
  801079:	f3 0f 1e fb          	endbr32 
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801083:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801086:	50                   	push   %eax
  801087:	ff 75 08             	pushl  0x8(%ebp)
  80108a:	e8 ac fe ff ff       	call   800f3b <fd_lookup>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	79 02                	jns    801098 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801096:	c9                   	leave  
  801097:	c3                   	ret    
		return fd_close(fd, 1);
  801098:	83 ec 08             	sub    $0x8,%esp
  80109b:	6a 01                	push   $0x1
  80109d:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a0:	e8 49 ff ff ff       	call   800fee <fd_close>
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	eb ec                	jmp    801096 <close+0x1d>

008010aa <close_all>:

void
close_all(void)
{
  8010aa:	f3 0f 1e fb          	endbr32 
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	53                   	push   %ebx
  8010b2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	53                   	push   %ebx
  8010be:	e8 b6 ff ff ff       	call   801079 <close>
	for (i = 0; i < MAXFD; i++)
  8010c3:	83 c3 01             	add    $0x1,%ebx
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	83 fb 20             	cmp    $0x20,%ebx
  8010cc:	75 ec                	jne    8010ba <close_all+0x10>
}
  8010ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d3:	f3 0f 1e fb          	endbr32 
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	ff 75 08             	pushl  0x8(%ebp)
  8010e7:	e8 4f fe ff ff       	call   800f3b <fd_lookup>
  8010ec:	89 c3                	mov    %eax,%ebx
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	0f 88 81 00 00 00    	js     80117a <dup+0xa7>
		return r;
	close(newfdnum);
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	ff 75 0c             	pushl  0xc(%ebp)
  8010ff:	e8 75 ff ff ff       	call   801079 <close>

	newfd = INDEX2FD(newfdnum);
  801104:	8b 75 0c             	mov    0xc(%ebp),%esi
  801107:	c1 e6 0c             	shl    $0xc,%esi
  80110a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801110:	83 c4 04             	add    $0x4,%esp
  801113:	ff 75 e4             	pushl  -0x1c(%ebp)
  801116:	e8 af fd ff ff       	call   800eca <fd2data>
  80111b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80111d:	89 34 24             	mov    %esi,(%esp)
  801120:	e8 a5 fd ff ff       	call   800eca <fd2data>
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	c1 e8 16             	shr    $0x16,%eax
  80112f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801136:	a8 01                	test   $0x1,%al
  801138:	74 11                	je     80114b <dup+0x78>
  80113a:	89 d8                	mov    %ebx,%eax
  80113c:	c1 e8 0c             	shr    $0xc,%eax
  80113f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801146:	f6 c2 01             	test   $0x1,%dl
  801149:	75 39                	jne    801184 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80114e:	89 d0                	mov    %edx,%eax
  801150:	c1 e8 0c             	shr    $0xc,%eax
  801153:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	25 07 0e 00 00       	and    $0xe07,%eax
  801162:	50                   	push   %eax
  801163:	56                   	push   %esi
  801164:	6a 00                	push   $0x0
  801166:	52                   	push   %edx
  801167:	6a 00                	push   $0x0
  801169:	e8 d5 fa ff ff       	call   800c43 <sys_page_map>
  80116e:	89 c3                	mov    %eax,%ebx
  801170:	83 c4 20             	add    $0x20,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 31                	js     8011a8 <dup+0xd5>
		goto err;

	return newfdnum;
  801177:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801184:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	25 07 0e 00 00       	and    $0xe07,%eax
  801193:	50                   	push   %eax
  801194:	57                   	push   %edi
  801195:	6a 00                	push   $0x0
  801197:	53                   	push   %ebx
  801198:	6a 00                	push   $0x0
  80119a:	e8 a4 fa ff ff       	call   800c43 <sys_page_map>
  80119f:	89 c3                	mov    %eax,%ebx
  8011a1:	83 c4 20             	add    $0x20,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	79 a3                	jns    80114b <dup+0x78>
	sys_page_unmap(0, newfd);
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	56                   	push   %esi
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 b5 fa ff ff       	call   800c68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011b3:	83 c4 08             	add    $0x8,%esp
  8011b6:	57                   	push   %edi
  8011b7:	6a 00                	push   $0x0
  8011b9:	e8 aa fa ff ff       	call   800c68 <sys_page_unmap>
	return r;
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	eb b7                	jmp    80117a <dup+0xa7>

008011c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c3:	f3 0f 1e fb          	endbr32 
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 1c             	sub    $0x1c,%esp
  8011ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	53                   	push   %ebx
  8011d6:	e8 60 fd ff ff       	call   800f3b <fd_lookup>
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	78 3f                	js     801221 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ec:	ff 30                	pushl  (%eax)
  8011ee:	e8 9c fd ff ff       	call   800f8f <dev_lookup>
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 27                	js     801221 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011fd:	8b 42 08             	mov    0x8(%edx),%eax
  801200:	83 e0 03             	and    $0x3,%eax
  801203:	83 f8 01             	cmp    $0x1,%eax
  801206:	74 1e                	je     801226 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801208:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120b:	8b 40 08             	mov    0x8(%eax),%eax
  80120e:	85 c0                	test   %eax,%eax
  801210:	74 35                	je     801247 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801212:	83 ec 04             	sub    $0x4,%esp
  801215:	ff 75 10             	pushl  0x10(%ebp)
  801218:	ff 75 0c             	pushl  0xc(%ebp)
  80121b:	52                   	push   %edx
  80121c:	ff d0                	call   *%eax
  80121e:	83 c4 10             	add    $0x10,%esp
}
  801221:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801224:	c9                   	leave  
  801225:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801226:	a1 08 40 80 00       	mov    0x804008,%eax
  80122b:	8b 40 48             	mov    0x48(%eax),%eax
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	53                   	push   %ebx
  801232:	50                   	push   %eax
  801233:	68 59 27 80 00       	push   $0x802759
  801238:	e8 6d ef ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801245:	eb da                	jmp    801221 <read+0x5e>
		return -E_NOT_SUPP;
  801247:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80124c:	eb d3                	jmp    801221 <read+0x5e>

0080124e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80124e:	f3 0f 1e fb          	endbr32 
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80125e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801261:	bb 00 00 00 00       	mov    $0x0,%ebx
  801266:	eb 02                	jmp    80126a <readn+0x1c>
  801268:	01 c3                	add    %eax,%ebx
  80126a:	39 f3                	cmp    %esi,%ebx
  80126c:	73 21                	jae    80128f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126e:	83 ec 04             	sub    $0x4,%esp
  801271:	89 f0                	mov    %esi,%eax
  801273:	29 d8                	sub    %ebx,%eax
  801275:	50                   	push   %eax
  801276:	89 d8                	mov    %ebx,%eax
  801278:	03 45 0c             	add    0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	57                   	push   %edi
  80127d:	e8 41 ff ff ff       	call   8011c3 <read>
		if (m < 0)
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	78 04                	js     80128d <readn+0x3f>
			return m;
		if (m == 0)
  801289:	75 dd                	jne    801268 <readn+0x1a>
  80128b:	eb 02                	jmp    80128f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80128d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80128f:	89 d8                	mov    %ebx,%eax
  801291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801299:	f3 0f 1e fb          	endbr32 
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 1c             	sub    $0x1c,%esp
  8012a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012aa:	50                   	push   %eax
  8012ab:	53                   	push   %ebx
  8012ac:	e8 8a fc ff ff       	call   800f3b <fd_lookup>
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 3a                	js     8012f2 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	ff 30                	pushl  (%eax)
  8012c4:	e8 c6 fc ff ff       	call   800f8f <dev_lookup>
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	78 22                	js     8012f2 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d7:	74 1e                	je     8012f7 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012df:	85 d2                	test   %edx,%edx
  8012e1:	74 35                	je     801318 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	ff 75 10             	pushl  0x10(%ebp)
  8012e9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ec:	50                   	push   %eax
  8012ed:	ff d2                	call   *%edx
  8012ef:	83 c4 10             	add    $0x10,%esp
}
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012f7:	a1 08 40 80 00       	mov    0x804008,%eax
  8012fc:	8b 40 48             	mov    0x48(%eax),%eax
  8012ff:	83 ec 04             	sub    $0x4,%esp
  801302:	53                   	push   %ebx
  801303:	50                   	push   %eax
  801304:	68 75 27 80 00       	push   $0x802775
  801309:	e8 9c ee ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801316:	eb da                	jmp    8012f2 <write+0x59>
		return -E_NOT_SUPP;
  801318:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80131d:	eb d3                	jmp    8012f2 <write+0x59>

0080131f <seek>:

int
seek(int fdnum, off_t offset)
{
  80131f:	f3 0f 1e fb          	endbr32 
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	ff 75 08             	pushl  0x8(%ebp)
  801330:	e8 06 fc ff ff       	call   800f3b <fd_lookup>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 0e                	js     80134a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80133c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801342:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80134c:	f3 0f 1e fb          	endbr32 
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	53                   	push   %ebx
  801354:	83 ec 1c             	sub    $0x1c,%esp
  801357:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135d:	50                   	push   %eax
  80135e:	53                   	push   %ebx
  80135f:	e8 d7 fb ff ff       	call   800f3b <fd_lookup>
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 37                	js     8013a2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801375:	ff 30                	pushl  (%eax)
  801377:	e8 13 fc ff ff       	call   800f8f <dev_lookup>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 1f                	js     8013a2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801386:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80138a:	74 1b                	je     8013a7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80138c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138f:	8b 52 18             	mov    0x18(%edx),%edx
  801392:	85 d2                	test   %edx,%edx
  801394:	74 32                	je     8013c8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	ff 75 0c             	pushl  0xc(%ebp)
  80139c:	50                   	push   %eax
  80139d:	ff d2                	call   *%edx
  80139f:	83 c4 10             	add    $0x10,%esp
}
  8013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013a7:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ac:	8b 40 48             	mov    0x48(%eax),%eax
  8013af:	83 ec 04             	sub    $0x4,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	50                   	push   %eax
  8013b4:	68 38 27 80 00       	push   $0x802738
  8013b9:	e8 ec ed ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c6:	eb da                	jmp    8013a2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013cd:	eb d3                	jmp    8013a2 <ftruncate+0x56>

008013cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013cf:	f3 0f 1e fb          	endbr32 
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 1c             	sub    $0x1c,%esp
  8013da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 52 fb ff ff       	call   800f3b <fd_lookup>
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 4b                	js     80143b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f6:	50                   	push   %eax
  8013f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fa:	ff 30                	pushl  (%eax)
  8013fc:	e8 8e fb ff ff       	call   800f8f <dev_lookup>
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	85 c0                	test   %eax,%eax
  801406:	78 33                	js     80143b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80140f:	74 2f                	je     801440 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801411:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801414:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80141b:	00 00 00 
	stat->st_isdir = 0;
  80141e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801425:	00 00 00 
	stat->st_dev = dev;
  801428:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	53                   	push   %ebx
  801432:	ff 75 f0             	pushl  -0x10(%ebp)
  801435:	ff 50 14             	call   *0x14(%eax)
  801438:	83 c4 10             	add    $0x10,%esp
}
  80143b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    
		return -E_NOT_SUPP;
  801440:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801445:	eb f4                	jmp    80143b <fstat+0x6c>

00801447 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801447:	f3 0f 1e fb          	endbr32 
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	56                   	push   %esi
  80144f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	6a 00                	push   $0x0
  801455:	ff 75 08             	pushl  0x8(%ebp)
  801458:	e8 01 02 00 00       	call   80165e <open>
  80145d:	89 c3                	mov    %eax,%ebx
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 1b                	js     801481 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	ff 75 0c             	pushl  0xc(%ebp)
  80146c:	50                   	push   %eax
  80146d:	e8 5d ff ff ff       	call   8013cf <fstat>
  801472:	89 c6                	mov    %eax,%esi
	close(fd);
  801474:	89 1c 24             	mov    %ebx,(%esp)
  801477:	e8 fd fb ff ff       	call   801079 <close>
	return r;
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	89 f3                	mov    %esi,%ebx
}
  801481:	89 d8                	mov    %ebx,%eax
  801483:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	56                   	push   %esi
  80148e:	53                   	push   %ebx
  80148f:	89 c6                	mov    %eax,%esi
  801491:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801493:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80149a:	74 27                	je     8014c3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80149c:	6a 07                	push   $0x7
  80149e:	68 00 50 80 00       	push   $0x805000
  8014a3:	56                   	push   %esi
  8014a4:	ff 35 00 40 80 00    	pushl  0x804000
  8014aa:	e8 72 f9 ff ff       	call   800e21 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014af:	83 c4 0c             	add    $0xc,%esp
  8014b2:	6a 00                	push   $0x0
  8014b4:	53                   	push   %ebx
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 f8 f8 ff ff       	call   800db4 <ipc_recv>
}
  8014bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5e                   	pop    %esi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	6a 01                	push   $0x1
  8014c8:	e8 ac f9 ff ff       	call   800e79 <ipc_find_env>
  8014cd:	a3 00 40 80 00       	mov    %eax,0x804000
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	eb c5                	jmp    80149c <fsipc+0x12>

008014d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014d7:	f3 0f 1e fb          	endbr32 
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ef:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014fe:	e8 87 ff ff ff       	call   80148a <fsipc>
}
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <devfile_flush>:
{
  801505:	f3 0f 1e fb          	endbr32 
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80150f:	8b 45 08             	mov    0x8(%ebp),%eax
  801512:	8b 40 0c             	mov    0xc(%eax),%eax
  801515:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80151a:	ba 00 00 00 00       	mov    $0x0,%edx
  80151f:	b8 06 00 00 00       	mov    $0x6,%eax
  801524:	e8 61 ff ff ff       	call   80148a <fsipc>
}
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <devfile_stat>:
{
  80152b:	f3 0f 1e fb          	endbr32 
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	53                   	push   %ebx
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	8b 40 0c             	mov    0xc(%eax),%eax
  80153f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
  801549:	b8 05 00 00 00       	mov    $0x5,%eax
  80154e:	e8 37 ff ff ff       	call   80148a <fsipc>
  801553:	85 c0                	test   %eax,%eax
  801555:	78 2c                	js     801583 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	68 00 50 80 00       	push   $0x805000
  80155f:	53                   	push   %ebx
  801560:	e8 4f f2 ff ff       	call   8007b4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801565:	a1 80 50 80 00       	mov    0x805080,%eax
  80156a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801570:	a1 84 50 80 00       	mov    0x805084,%eax
  801575:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801583:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <devfile_write>:
{
  801588:	f3 0f 1e fb          	endbr32 
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	8b 45 10             	mov    0x10(%ebp),%eax
  801595:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80159a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80159f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015ae:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015b3:	50                   	push   %eax
  8015b4:	ff 75 0c             	pushl  0xc(%ebp)
  8015b7:	68 08 50 80 00       	push   $0x805008
  8015bc:	e8 f1 f3 ff ff       	call   8009b2 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015cb:	e8 ba fe ff ff       	call   80148a <fsipc>
}
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <devfile_read>:
{
  8015d2:	f3 0f 1e fb          	endbr32 
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	56                   	push   %esi
  8015da:	53                   	push   %ebx
  8015db:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015de:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015e9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8015f9:	e8 8c fe ff ff       	call   80148a <fsipc>
  8015fe:	89 c3                	mov    %eax,%ebx
  801600:	85 c0                	test   %eax,%eax
  801602:	78 1f                	js     801623 <devfile_read+0x51>
	assert(r <= n);
  801604:	39 f0                	cmp    %esi,%eax
  801606:	77 24                	ja     80162c <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801608:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80160d:	7f 36                	jg     801645 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80160f:	83 ec 04             	sub    $0x4,%esp
  801612:	50                   	push   %eax
  801613:	68 00 50 80 00       	push   $0x805000
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	e8 92 f3 ff ff       	call   8009b2 <memmove>
	return r;
  801620:	83 c4 10             	add    $0x10,%esp
}
  801623:	89 d8                	mov    %ebx,%eax
  801625:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    
	assert(r <= n);
  80162c:	68 a8 27 80 00       	push   $0x8027a8
  801631:	68 af 27 80 00       	push   $0x8027af
  801636:	68 8c 00 00 00       	push   $0x8c
  80163b:	68 c4 27 80 00       	push   $0x8027c4
  801640:	e8 79 0a 00 00       	call   8020be <_panic>
	assert(r <= PGSIZE);
  801645:	68 cf 27 80 00       	push   $0x8027cf
  80164a:	68 af 27 80 00       	push   $0x8027af
  80164f:	68 8d 00 00 00       	push   $0x8d
  801654:	68 c4 27 80 00       	push   $0x8027c4
  801659:	e8 60 0a 00 00       	call   8020be <_panic>

0080165e <open>:
{
  80165e:	f3 0f 1e fb          	endbr32 
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	56                   	push   %esi
  801666:	53                   	push   %ebx
  801667:	83 ec 1c             	sub    $0x1c,%esp
  80166a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80166d:	56                   	push   %esi
  80166e:	e8 fe f0 ff ff       	call   800771 <strlen>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80167b:	7f 6c                	jg     8016e9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801683:	50                   	push   %eax
  801684:	e8 5c f8 ff ff       	call   800ee5 <fd_alloc>
  801689:	89 c3                	mov    %eax,%ebx
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 3c                	js     8016ce <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	56                   	push   %esi
  801696:	68 00 50 80 00       	push   $0x805000
  80169b:	e8 14 f1 ff ff       	call   8007b4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8016b0:	e8 d5 fd ff ff       	call   80148a <fsipc>
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 19                	js     8016d7 <open+0x79>
	return fd2num(fd);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c4:	e8 ed f7 ff ff       	call   800eb6 <fd2num>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	83 c4 10             	add    $0x10,%esp
}
  8016ce:	89 d8                	mov    %ebx,%eax
  8016d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    
		fd_close(fd, 0);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	6a 00                	push   $0x0
  8016dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016df:	e8 0a f9 ff ff       	call   800fee <fd_close>
		return r;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	eb e5                	jmp    8016ce <open+0x70>
		return -E_BAD_PATH;
  8016e9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016ee:	eb de                	jmp    8016ce <open+0x70>

008016f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016f0:	f3 0f 1e fb          	endbr32 
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ff:	b8 08 00 00 00       	mov    $0x8,%eax
  801704:	e8 81 fd ff ff       	call   80148a <fsipc>
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80170b:	f3 0f 1e fb          	endbr32 
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801715:	68 3b 28 80 00       	push   $0x80283b
  80171a:	ff 75 0c             	pushl  0xc(%ebp)
  80171d:	e8 92 f0 ff ff       	call   8007b4 <strcpy>
	return 0;
}
  801722:	b8 00 00 00 00       	mov    $0x0,%eax
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <devsock_close>:
{
  801729:	f3 0f 1e fb          	endbr32 
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	53                   	push   %ebx
  801731:	83 ec 10             	sub    $0x10,%esp
  801734:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801737:	53                   	push   %ebx
  801738:	e8 cb 09 00 00       	call   802108 <pageref>
  80173d:	89 c2                	mov    %eax,%edx
  80173f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801742:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801747:	83 fa 01             	cmp    $0x1,%edx
  80174a:	74 05                	je     801751 <devsock_close+0x28>
}
  80174c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174f:	c9                   	leave  
  801750:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801751:	83 ec 0c             	sub    $0xc,%esp
  801754:	ff 73 0c             	pushl  0xc(%ebx)
  801757:	e8 e3 02 00 00       	call   801a3f <nsipc_close>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	eb eb                	jmp    80174c <devsock_close+0x23>

00801761 <devsock_write>:
{
  801761:	f3 0f 1e fb          	endbr32 
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80176b:	6a 00                	push   $0x0
  80176d:	ff 75 10             	pushl  0x10(%ebp)
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	ff 70 0c             	pushl  0xc(%eax)
  801779:	e8 b5 03 00 00       	call   801b33 <nsipc_send>
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devsock_read>:
{
  801780:	f3 0f 1e fb          	endbr32 
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80178a:	6a 00                	push   $0x0
  80178c:	ff 75 10             	pushl  0x10(%ebp)
  80178f:	ff 75 0c             	pushl  0xc(%ebp)
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	ff 70 0c             	pushl  0xc(%eax)
  801798:	e8 1f 03 00 00       	call   801abc <nsipc_recv>
}
  80179d:	c9                   	leave  
  80179e:	c3                   	ret    

0080179f <fd2sockid>:
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017a5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017a8:	52                   	push   %edx
  8017a9:	50                   	push   %eax
  8017aa:	e8 8c f7 ff ff       	call   800f3b <fd_lookup>
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 10                	js     8017c6 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8017b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b9:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  8017bf:	39 08                	cmp    %ecx,(%eax)
  8017c1:	75 05                	jne    8017c8 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8017c3:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8017c6:	c9                   	leave  
  8017c7:	c3                   	ret    
		return -E_NOT_SUPP;
  8017c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017cd:	eb f7                	jmp    8017c6 <fd2sockid+0x27>

008017cf <alloc_sockfd>:
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	56                   	push   %esi
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 1c             	sub    $0x1c,%esp
  8017d7:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8017d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dc:	50                   	push   %eax
  8017dd:	e8 03 f7 ff ff       	call   800ee5 <fd_alloc>
  8017e2:	89 c3                	mov    %eax,%ebx
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 43                	js     80182e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	68 07 04 00 00       	push   $0x407
  8017f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 20 f4 ff ff       	call   800c1d <sys_page_alloc>
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	85 c0                	test   %eax,%eax
  801804:	78 28                	js     80182e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801806:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801809:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80180f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801811:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801814:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80181b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80181e:	83 ec 0c             	sub    $0xc,%esp
  801821:	50                   	push   %eax
  801822:	e8 8f f6 ff ff       	call   800eb6 <fd2num>
  801827:	89 c3                	mov    %eax,%ebx
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	eb 0c                	jmp    80183a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	56                   	push   %esi
  801832:	e8 08 02 00 00       	call   801a3f <nsipc_close>
		return r;
  801837:	83 c4 10             	add    $0x10,%esp
}
  80183a:	89 d8                	mov    %ebx,%eax
  80183c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <accept>:
{
  801843:	f3 0f 1e fb          	endbr32 
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	e8 4a ff ff ff       	call   80179f <fd2sockid>
  801855:	85 c0                	test   %eax,%eax
  801857:	78 1b                	js     801874 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801859:	83 ec 04             	sub    $0x4,%esp
  80185c:	ff 75 10             	pushl  0x10(%ebp)
  80185f:	ff 75 0c             	pushl  0xc(%ebp)
  801862:	50                   	push   %eax
  801863:	e8 22 01 00 00       	call   80198a <nsipc_accept>
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 05                	js     801874 <accept+0x31>
	return alloc_sockfd(r);
  80186f:	e8 5b ff ff ff       	call   8017cf <alloc_sockfd>
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <bind>:
{
  801876:	f3 0f 1e fb          	endbr32 
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	e8 17 ff ff ff       	call   80179f <fd2sockid>
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 12                	js     80189e <bind+0x28>
	return nsipc_bind(r, name, namelen);
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	ff 75 10             	pushl  0x10(%ebp)
  801892:	ff 75 0c             	pushl  0xc(%ebp)
  801895:	50                   	push   %eax
  801896:	e8 45 01 00 00       	call   8019e0 <nsipc_bind>
  80189b:	83 c4 10             	add    $0x10,%esp
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <shutdown>:
{
  8018a0:	f3 0f 1e fb          	endbr32 
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	e8 ed fe ff ff       	call   80179f <fd2sockid>
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 0f                	js     8018c5 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  8018b6:	83 ec 08             	sub    $0x8,%esp
  8018b9:	ff 75 0c             	pushl  0xc(%ebp)
  8018bc:	50                   	push   %eax
  8018bd:	e8 57 01 00 00       	call   801a19 <nsipc_shutdown>
  8018c2:	83 c4 10             	add    $0x10,%esp
}
  8018c5:	c9                   	leave  
  8018c6:	c3                   	ret    

008018c7 <connect>:
{
  8018c7:	f3 0f 1e fb          	endbr32 
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d4:	e8 c6 fe ff ff       	call   80179f <fd2sockid>
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 12                	js     8018ef <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	ff 75 10             	pushl  0x10(%ebp)
  8018e3:	ff 75 0c             	pushl  0xc(%ebp)
  8018e6:	50                   	push   %eax
  8018e7:	e8 71 01 00 00       	call   801a5d <nsipc_connect>
  8018ec:	83 c4 10             	add    $0x10,%esp
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <listen>:
{
  8018f1:	f3 0f 1e fb          	endbr32 
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	e8 9c fe ff ff       	call   80179f <fd2sockid>
  801903:	85 c0                	test   %eax,%eax
  801905:	78 0f                	js     801916 <listen+0x25>
	return nsipc_listen(r, backlog);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	ff 75 0c             	pushl  0xc(%ebp)
  80190d:	50                   	push   %eax
  80190e:	e8 83 01 00 00       	call   801a96 <nsipc_listen>
  801913:	83 c4 10             	add    $0x10,%esp
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <socket>:

int
socket(int domain, int type, int protocol)
{
  801918:	f3 0f 1e fb          	endbr32 
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801922:	ff 75 10             	pushl  0x10(%ebp)
  801925:	ff 75 0c             	pushl  0xc(%ebp)
  801928:	ff 75 08             	pushl  0x8(%ebp)
  80192b:	e8 65 02 00 00       	call   801b95 <nsipc_socket>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	78 05                	js     80193c <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801937:	e8 93 fe ff ff       	call   8017cf <alloc_sockfd>
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 04             	sub    $0x4,%esp
  801945:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801947:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80194e:	74 26                	je     801976 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801950:	6a 07                	push   $0x7
  801952:	68 00 60 80 00       	push   $0x806000
  801957:	53                   	push   %ebx
  801958:	ff 35 04 40 80 00    	pushl  0x804004
  80195e:	e8 be f4 ff ff       	call   800e21 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801963:	83 c4 0c             	add    $0xc,%esp
  801966:	6a 00                	push   $0x0
  801968:	6a 00                	push   $0x0
  80196a:	6a 00                	push   $0x0
  80196c:	e8 43 f4 ff ff       	call   800db4 <ipc_recv>
}
  801971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801974:	c9                   	leave  
  801975:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801976:	83 ec 0c             	sub    $0xc,%esp
  801979:	6a 02                	push   $0x2
  80197b:	e8 f9 f4 ff ff       	call   800e79 <ipc_find_env>
  801980:	a3 04 40 80 00       	mov    %eax,0x804004
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	eb c6                	jmp    801950 <nsipc+0x12>

0080198a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80198a:	f3 0f 1e fb          	endbr32 
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80199e:	8b 06                	mov    (%esi),%eax
  8019a0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8019a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019aa:	e8 8f ff ff ff       	call   80193e <nsipc>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	79 09                	jns    8019be <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8019b5:	89 d8                	mov    %ebx,%eax
  8019b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019be:	83 ec 04             	sub    $0x4,%esp
  8019c1:	ff 35 10 60 80 00    	pushl  0x806010
  8019c7:	68 00 60 80 00       	push   $0x806000
  8019cc:	ff 75 0c             	pushl  0xc(%ebp)
  8019cf:	e8 de ef ff ff       	call   8009b2 <memmove>
		*addrlen = ret->ret_addrlen;
  8019d4:	a1 10 60 80 00       	mov    0x806010,%eax
  8019d9:	89 06                	mov    %eax,(%esi)
  8019db:	83 c4 10             	add    $0x10,%esp
	return r;
  8019de:	eb d5                	jmp    8019b5 <nsipc_accept+0x2b>

008019e0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019e0:	f3 0f 1e fb          	endbr32 
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	53                   	push   %ebx
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019f6:	53                   	push   %ebx
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	68 04 60 80 00       	push   $0x806004
  8019ff:	e8 ae ef ff ff       	call   8009b2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801a04:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801a0a:	b8 02 00 00 00       	mov    $0x2,%eax
  801a0f:	e8 2a ff ff ff       	call   80193e <nsipc>
}
  801a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801a19:	f3 0f 1e fb          	endbr32 
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801a33:	b8 03 00 00 00       	mov    $0x3,%eax
  801a38:	e8 01 ff ff ff       	call   80193e <nsipc>
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <nsipc_close>:

int
nsipc_close(int s)
{
  801a3f:	f3 0f 1e fb          	endbr32 
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801a51:	b8 04 00 00 00       	mov    $0x4,%eax
  801a56:	e8 e3 fe ff ff       	call   80193e <nsipc>
}
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a5d:	f3 0f 1e fb          	endbr32 
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	53                   	push   %ebx
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a73:	53                   	push   %ebx
  801a74:	ff 75 0c             	pushl  0xc(%ebp)
  801a77:	68 04 60 80 00       	push   $0x806004
  801a7c:	e8 31 ef ff ff       	call   8009b2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a81:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a87:	b8 05 00 00 00       	mov    $0x5,%eax
  801a8c:	e8 ad fe ff ff       	call   80193e <nsipc>
}
  801a91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a96:	f3 0f 1e fb          	endbr32 
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aab:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ab0:	b8 06 00 00 00       	mov    $0x6,%eax
  801ab5:	e8 84 fe ff ff       	call   80193e <nsipc>
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801abc:	f3 0f 1e fb          	endbr32 
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  801acb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ad0:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ad6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad9:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ade:	b8 07 00 00 00       	mov    $0x7,%eax
  801ae3:	e8 56 fe ff ff       	call   80193e <nsipc>
  801ae8:	89 c3                	mov    %eax,%ebx
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 26                	js     801b14 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801aee:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801af4:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801af9:	0f 4e c6             	cmovle %esi,%eax
  801afc:	39 c3                	cmp    %eax,%ebx
  801afe:	7f 1d                	jg     801b1d <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	53                   	push   %ebx
  801b04:	68 00 60 80 00       	push   $0x806000
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	e8 a1 ee ff ff       	call   8009b2 <memmove>
  801b11:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801b14:	89 d8                	mov    %ebx,%eax
  801b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801b1d:	68 47 28 80 00       	push   $0x802847
  801b22:	68 af 27 80 00       	push   $0x8027af
  801b27:	6a 62                	push   $0x62
  801b29:	68 5c 28 80 00       	push   $0x80285c
  801b2e:	e8 8b 05 00 00       	call   8020be <_panic>

00801b33 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801b33:	f3 0f 1e fb          	endbr32 
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b41:	8b 45 08             	mov    0x8(%ebp),%eax
  801b44:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801b49:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b4f:	7f 2e                	jg     801b7f <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b51:	83 ec 04             	sub    $0x4,%esp
  801b54:	53                   	push   %ebx
  801b55:	ff 75 0c             	pushl  0xc(%ebp)
  801b58:	68 0c 60 80 00       	push   $0x80600c
  801b5d:	e8 50 ee ff ff       	call   8009b2 <memmove>
	nsipcbuf.send.req_size = size;
  801b62:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b68:	8b 45 14             	mov    0x14(%ebp),%eax
  801b6b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b70:	b8 08 00 00 00       	mov    $0x8,%eax
  801b75:	e8 c4 fd ff ff       	call   80193e <nsipc>
}
  801b7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    
	assert(size < 1600);
  801b7f:	68 68 28 80 00       	push   $0x802868
  801b84:	68 af 27 80 00       	push   $0x8027af
  801b89:	6a 6d                	push   $0x6d
  801b8b:	68 5c 28 80 00       	push   $0x80285c
  801b90:	e8 29 05 00 00       	call   8020be <_panic>

00801b95 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b95:	f3 0f 1e fb          	endbr32 
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801baa:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801baf:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801bb7:	b8 09 00 00 00       	mov    $0x9,%eax
  801bbc:	e8 7d fd ff ff       	call   80193e <nsipc>
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bc3:	f3 0f 1e fb          	endbr32 
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bcf:	83 ec 0c             	sub    $0xc,%esp
  801bd2:	ff 75 08             	pushl  0x8(%ebp)
  801bd5:	e8 f0 f2 ff ff       	call   800eca <fd2data>
  801bda:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bdc:	83 c4 08             	add    $0x8,%esp
  801bdf:	68 74 28 80 00       	push   $0x802874
  801be4:	53                   	push   %ebx
  801be5:	e8 ca eb ff ff       	call   8007b4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bea:	8b 46 04             	mov    0x4(%esi),%eax
  801bed:	2b 06                	sub    (%esi),%eax
  801bef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bf5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bfc:	00 00 00 
	stat->st_dev = &devpipe;
  801bff:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801c06:	30 80 00 
	return 0;
}
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    

00801c15 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c15:	f3 0f 1e fb          	endbr32 
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c23:	53                   	push   %ebx
  801c24:	6a 00                	push   $0x0
  801c26:	e8 3d f0 ff ff       	call   800c68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c2b:	89 1c 24             	mov    %ebx,(%esp)
  801c2e:	e8 97 f2 ff ff       	call   800eca <fd2data>
  801c33:	83 c4 08             	add    $0x8,%esp
  801c36:	50                   	push   %eax
  801c37:	6a 00                	push   $0x0
  801c39:	e8 2a f0 ff ff       	call   800c68 <sys_page_unmap>
}
  801c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <_pipeisclosed>:
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	57                   	push   %edi
  801c47:	56                   	push   %esi
  801c48:	53                   	push   %ebx
  801c49:	83 ec 1c             	sub    $0x1c,%esp
  801c4c:	89 c7                	mov    %eax,%edi
  801c4e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c50:	a1 08 40 80 00       	mov    0x804008,%eax
  801c55:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	57                   	push   %edi
  801c5c:	e8 a7 04 00 00       	call   802108 <pageref>
  801c61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c64:	89 34 24             	mov    %esi,(%esp)
  801c67:	e8 9c 04 00 00       	call   802108 <pageref>
		nn = thisenv->env_runs;
  801c6c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c72:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	39 cb                	cmp    %ecx,%ebx
  801c7a:	74 1b                	je     801c97 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c7f:	75 cf                	jne    801c50 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c81:	8b 42 58             	mov    0x58(%edx),%eax
  801c84:	6a 01                	push   $0x1
  801c86:	50                   	push   %eax
  801c87:	53                   	push   %ebx
  801c88:	68 7b 28 80 00       	push   $0x80287b
  801c8d:	e8 18 e5 ff ff       	call   8001aa <cprintf>
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	eb b9                	jmp    801c50 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c97:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c9a:	0f 94 c0             	sete   %al
  801c9d:	0f b6 c0             	movzbl %al,%eax
}
  801ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <devpipe_write>:
{
  801ca8:	f3 0f 1e fb          	endbr32 
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	57                   	push   %edi
  801cb0:	56                   	push   %esi
  801cb1:	53                   	push   %ebx
  801cb2:	83 ec 28             	sub    $0x28,%esp
  801cb5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cb8:	56                   	push   %esi
  801cb9:	e8 0c f2 ff ff       	call   800eca <fd2data>
  801cbe:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	bf 00 00 00 00       	mov    $0x0,%edi
  801cc8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ccb:	74 4f                	je     801d1c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ccd:	8b 43 04             	mov    0x4(%ebx),%eax
  801cd0:	8b 0b                	mov    (%ebx),%ecx
  801cd2:	8d 51 20             	lea    0x20(%ecx),%edx
  801cd5:	39 d0                	cmp    %edx,%eax
  801cd7:	72 14                	jb     801ced <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801cd9:	89 da                	mov    %ebx,%edx
  801cdb:	89 f0                	mov    %esi,%eax
  801cdd:	e8 61 ff ff ff       	call   801c43 <_pipeisclosed>
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	75 3b                	jne    801d21 <devpipe_write+0x79>
			sys_yield();
  801ce6:	e8 0f ef ff ff       	call   800bfa <sys_yield>
  801ceb:	eb e0                	jmp    801ccd <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cf4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cf7:	89 c2                	mov    %eax,%edx
  801cf9:	c1 fa 1f             	sar    $0x1f,%edx
  801cfc:	89 d1                	mov    %edx,%ecx
  801cfe:	c1 e9 1b             	shr    $0x1b,%ecx
  801d01:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d04:	83 e2 1f             	and    $0x1f,%edx
  801d07:	29 ca                	sub    %ecx,%edx
  801d09:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d0d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d11:	83 c0 01             	add    $0x1,%eax
  801d14:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d17:	83 c7 01             	add    $0x1,%edi
  801d1a:	eb ac                	jmp    801cc8 <devpipe_write+0x20>
	return i;
  801d1c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1f:	eb 05                	jmp    801d26 <devpipe_write+0x7e>
				return 0;
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d29:	5b                   	pop    %ebx
  801d2a:	5e                   	pop    %esi
  801d2b:	5f                   	pop    %edi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <devpipe_read>:
{
  801d2e:	f3 0f 1e fb          	endbr32 
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	57                   	push   %edi
  801d36:	56                   	push   %esi
  801d37:	53                   	push   %ebx
  801d38:	83 ec 18             	sub    $0x18,%esp
  801d3b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d3e:	57                   	push   %edi
  801d3f:	e8 86 f1 ff ff       	call   800eca <fd2data>
  801d44:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	be 00 00 00 00       	mov    $0x0,%esi
  801d4e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d51:	75 14                	jne    801d67 <devpipe_read+0x39>
	return i;
  801d53:	8b 45 10             	mov    0x10(%ebp),%eax
  801d56:	eb 02                	jmp    801d5a <devpipe_read+0x2c>
				return i;
  801d58:	89 f0                	mov    %esi,%eax
}
  801d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
			sys_yield();
  801d62:	e8 93 ee ff ff       	call   800bfa <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d67:	8b 03                	mov    (%ebx),%eax
  801d69:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d6c:	75 18                	jne    801d86 <devpipe_read+0x58>
			if (i > 0)
  801d6e:	85 f6                	test   %esi,%esi
  801d70:	75 e6                	jne    801d58 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d72:	89 da                	mov    %ebx,%edx
  801d74:	89 f8                	mov    %edi,%eax
  801d76:	e8 c8 fe ff ff       	call   801c43 <_pipeisclosed>
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	74 e3                	je     801d62 <devpipe_read+0x34>
				return 0;
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d84:	eb d4                	jmp    801d5a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d86:	99                   	cltd   
  801d87:	c1 ea 1b             	shr    $0x1b,%edx
  801d8a:	01 d0                	add    %edx,%eax
  801d8c:	83 e0 1f             	and    $0x1f,%eax
  801d8f:	29 d0                	sub    %edx,%eax
  801d91:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d99:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d9c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d9f:	83 c6 01             	add    $0x1,%esi
  801da2:	eb aa                	jmp    801d4e <devpipe_read+0x20>

00801da4 <pipe>:
{
  801da4:	f3 0f 1e fb          	endbr32 
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801db0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db3:	50                   	push   %eax
  801db4:	e8 2c f1 ff ff       	call   800ee5 <fd_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 23 01 00 00    	js     801ee9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc6:	83 ec 04             	sub    $0x4,%esp
  801dc9:	68 07 04 00 00       	push   $0x407
  801dce:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 45 ee ff ff       	call   800c1d <sys_page_alloc>
  801dd8:	89 c3                	mov    %eax,%ebx
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	0f 88 04 01 00 00    	js     801ee9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801deb:	50                   	push   %eax
  801dec:	e8 f4 f0 ff ff       	call   800ee5 <fd_alloc>
  801df1:	89 c3                	mov    %eax,%ebx
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	85 c0                	test   %eax,%eax
  801df8:	0f 88 db 00 00 00    	js     801ed9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	68 07 04 00 00       	push   $0x407
  801e06:	ff 75 f0             	pushl  -0x10(%ebp)
  801e09:	6a 00                	push   $0x0
  801e0b:	e8 0d ee ff ff       	call   800c1d <sys_page_alloc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	0f 88 bc 00 00 00    	js     801ed9 <pipe+0x135>
	va = fd2data(fd0);
  801e1d:	83 ec 0c             	sub    $0xc,%esp
  801e20:	ff 75 f4             	pushl  -0xc(%ebp)
  801e23:	e8 a2 f0 ff ff       	call   800eca <fd2data>
  801e28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2a:	83 c4 0c             	add    $0xc,%esp
  801e2d:	68 07 04 00 00       	push   $0x407
  801e32:	50                   	push   %eax
  801e33:	6a 00                	push   $0x0
  801e35:	e8 e3 ed ff ff       	call   800c1d <sys_page_alloc>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	0f 88 82 00 00 00    	js     801ec9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e47:	83 ec 0c             	sub    $0xc,%esp
  801e4a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e4d:	e8 78 f0 ff ff       	call   800eca <fd2data>
  801e52:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e59:	50                   	push   %eax
  801e5a:	6a 00                	push   $0x0
  801e5c:	56                   	push   %esi
  801e5d:	6a 00                	push   $0x0
  801e5f:	e8 df ed ff ff       	call   800c43 <sys_page_map>
  801e64:	89 c3                	mov    %eax,%ebx
  801e66:	83 c4 20             	add    $0x20,%esp
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 4e                	js     801ebb <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e6d:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801e72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e75:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e7a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e81:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e84:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e89:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e90:	83 ec 0c             	sub    $0xc,%esp
  801e93:	ff 75 f4             	pushl  -0xc(%ebp)
  801e96:	e8 1b f0 ff ff       	call   800eb6 <fd2num>
  801e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ea0:	83 c4 04             	add    $0x4,%esp
  801ea3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea6:	e8 0b f0 ff ff       	call   800eb6 <fd2num>
  801eab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eb1:	83 c4 10             	add    $0x10,%esp
  801eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eb9:	eb 2e                	jmp    801ee9 <pipe+0x145>
	sys_page_unmap(0, va);
  801ebb:	83 ec 08             	sub    $0x8,%esp
  801ebe:	56                   	push   %esi
  801ebf:	6a 00                	push   $0x0
  801ec1:	e8 a2 ed ff ff       	call   800c68 <sys_page_unmap>
  801ec6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ec9:	83 ec 08             	sub    $0x8,%esp
  801ecc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ecf:	6a 00                	push   $0x0
  801ed1:	e8 92 ed ff ff       	call   800c68 <sys_page_unmap>
  801ed6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ed9:	83 ec 08             	sub    $0x8,%esp
  801edc:	ff 75 f4             	pushl  -0xc(%ebp)
  801edf:	6a 00                	push   $0x0
  801ee1:	e8 82 ed ff ff       	call   800c68 <sys_page_unmap>
  801ee6:	83 c4 10             	add    $0x10,%esp
}
  801ee9:	89 d8                	mov    %ebx,%eax
  801eeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eee:	5b                   	pop    %ebx
  801eef:	5e                   	pop    %esi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <pipeisclosed>:
{
  801ef2:	f3 0f 1e fb          	endbr32 
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801efc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eff:	50                   	push   %eax
  801f00:	ff 75 08             	pushl  0x8(%ebp)
  801f03:	e8 33 f0 ff ff       	call   800f3b <fd_lookup>
  801f08:	83 c4 10             	add    $0x10,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 18                	js     801f27 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f0f:	83 ec 0c             	sub    $0xc,%esp
  801f12:	ff 75 f4             	pushl  -0xc(%ebp)
  801f15:	e8 b0 ef ff ff       	call   800eca <fd2data>
  801f1a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1f:	e8 1f fd ff ff       	call   801c43 <_pipeisclosed>
  801f24:	83 c4 10             	add    $0x10,%esp
}
  801f27:	c9                   	leave  
  801f28:	c3                   	ret    

00801f29 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f29:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f32:	c3                   	ret    

00801f33 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f33:	f3 0f 1e fb          	endbr32 
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f3d:	68 93 28 80 00       	push   $0x802893
  801f42:	ff 75 0c             	pushl  0xc(%ebp)
  801f45:	e8 6a e8 ff ff       	call   8007b4 <strcpy>
	return 0;
}
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <devcons_write>:
{
  801f51:	f3 0f 1e fb          	endbr32 
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	57                   	push   %edi
  801f59:	56                   	push   %esi
  801f5a:	53                   	push   %ebx
  801f5b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f61:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f66:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f6c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f6f:	73 31                	jae    801fa2 <devcons_write+0x51>
		m = n - tot;
  801f71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f74:	29 f3                	sub    %esi,%ebx
  801f76:	83 fb 7f             	cmp    $0x7f,%ebx
  801f79:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f7e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f81:	83 ec 04             	sub    $0x4,%esp
  801f84:	53                   	push   %ebx
  801f85:	89 f0                	mov    %esi,%eax
  801f87:	03 45 0c             	add    0xc(%ebp),%eax
  801f8a:	50                   	push   %eax
  801f8b:	57                   	push   %edi
  801f8c:	e8 21 ea ff ff       	call   8009b2 <memmove>
		sys_cputs(buf, m);
  801f91:	83 c4 08             	add    $0x8,%esp
  801f94:	53                   	push   %ebx
  801f95:	57                   	push   %edi
  801f96:	e8 d3 eb ff ff       	call   800b6e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f9b:	01 de                	add    %ebx,%esi
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	eb ca                	jmp    801f6c <devcons_write+0x1b>
}
  801fa2:	89 f0                	mov    %esi,%eax
  801fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <devcons_read>:
{
  801fac:	f3 0f 1e fb          	endbr32 
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 08             	sub    $0x8,%esp
  801fb6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fbf:	74 21                	je     801fe2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801fc1:	e8 ca eb ff ff       	call   800b90 <sys_cgetc>
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	75 07                	jne    801fd1 <devcons_read+0x25>
		sys_yield();
  801fca:	e8 2b ec ff ff       	call   800bfa <sys_yield>
  801fcf:	eb f0                	jmp    801fc1 <devcons_read+0x15>
	if (c < 0)
  801fd1:	78 0f                	js     801fe2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801fd3:	83 f8 04             	cmp    $0x4,%eax
  801fd6:	74 0c                	je     801fe4 <devcons_read+0x38>
	*(char*)vbuf = c;
  801fd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fdb:	88 02                	mov    %al,(%edx)
	return 1;
  801fdd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    
		return 0;
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe9:	eb f7                	jmp    801fe2 <devcons_read+0x36>

00801feb <cputchar>:
{
  801feb:	f3 0f 1e fb          	endbr32 
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ffb:	6a 01                	push   $0x1
  801ffd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802000:	50                   	push   %eax
  802001:	e8 68 eb ff ff       	call   800b6e <sys_cputs>
}
  802006:	83 c4 10             	add    $0x10,%esp
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <getchar>:
{
  80200b:	f3 0f 1e fb          	endbr32 
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802015:	6a 01                	push   $0x1
  802017:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80201a:	50                   	push   %eax
  80201b:	6a 00                	push   $0x0
  80201d:	e8 a1 f1 ff ff       	call   8011c3 <read>
	if (r < 0)
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	85 c0                	test   %eax,%eax
  802027:	78 06                	js     80202f <getchar+0x24>
	if (r < 1)
  802029:	74 06                	je     802031 <getchar+0x26>
	return c;
  80202b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80202f:	c9                   	leave  
  802030:	c3                   	ret    
		return -E_EOF;
  802031:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802036:	eb f7                	jmp    80202f <getchar+0x24>

00802038 <iscons>:
{
  802038:	f3 0f 1e fb          	endbr32 
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802042:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802045:	50                   	push   %eax
  802046:	ff 75 08             	pushl  0x8(%ebp)
  802049:	e8 ed ee ff ff       	call   800f3b <fd_lookup>
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	85 c0                	test   %eax,%eax
  802053:	78 11                	js     802066 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80205e:	39 10                	cmp    %edx,(%eax)
  802060:	0f 94 c0             	sete   %al
  802063:	0f b6 c0             	movzbl %al,%eax
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <opencons>:
{
  802068:	f3 0f 1e fb          	endbr32 
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802075:	50                   	push   %eax
  802076:	e8 6a ee ff ff       	call   800ee5 <fd_alloc>
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	85 c0                	test   %eax,%eax
  802080:	78 3a                	js     8020bc <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802082:	83 ec 04             	sub    $0x4,%esp
  802085:	68 07 04 00 00       	push   $0x407
  80208a:	ff 75 f4             	pushl  -0xc(%ebp)
  80208d:	6a 00                	push   $0x0
  80208f:	e8 89 eb ff ff       	call   800c1d <sys_page_alloc>
  802094:	83 c4 10             	add    $0x10,%esp
  802097:	85 c0                	test   %eax,%eax
  802099:	78 21                	js     8020bc <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80209b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209e:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8020a4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020b0:	83 ec 0c             	sub    $0xc,%esp
  8020b3:	50                   	push   %eax
  8020b4:	e8 fd ed ff ff       	call   800eb6 <fd2num>
  8020b9:	83 c4 10             	add    $0x10,%esp
}
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    

008020be <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020be:	f3 0f 1e fb          	endbr32 
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	56                   	push   %esi
  8020c6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8020c7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020ca:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020d0:	e8 02 eb ff ff       	call   800bd7 <sys_getenvid>
  8020d5:	83 ec 0c             	sub    $0xc,%esp
  8020d8:	ff 75 0c             	pushl  0xc(%ebp)
  8020db:	ff 75 08             	pushl  0x8(%ebp)
  8020de:	56                   	push   %esi
  8020df:	50                   	push   %eax
  8020e0:	68 a0 28 80 00       	push   $0x8028a0
  8020e5:	e8 c0 e0 ff ff       	call   8001aa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020ea:	83 c4 18             	add    $0x18,%esp
  8020ed:	53                   	push   %ebx
  8020ee:	ff 75 10             	pushl  0x10(%ebp)
  8020f1:	e8 5f e0 ff ff       	call   800155 <vcprintf>
	cprintf("\n");
  8020f6:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
  8020fd:	e8 a8 e0 ff ff       	call   8001aa <cprintf>
  802102:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802105:	cc                   	int3   
  802106:	eb fd                	jmp    802105 <_panic+0x47>

00802108 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802108:	f3 0f 1e fb          	endbr32 
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802112:	89 c2                	mov    %eax,%edx
  802114:	c1 ea 16             	shr    $0x16,%edx
  802117:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80211e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802123:	f6 c1 01             	test   $0x1,%cl
  802126:	74 1c                	je     802144 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802128:	c1 e8 0c             	shr    $0xc,%eax
  80212b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802132:	a8 01                	test   $0x1,%al
  802134:	74 0e                	je     802144 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802136:	c1 e8 0c             	shr    $0xc,%eax
  802139:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802140:	ef 
  802141:	0f b7 d2             	movzwl %dx,%edx
}
  802144:	89 d0                	mov    %edx,%eax
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

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
