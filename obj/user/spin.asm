
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
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
  80003b:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003e:	68 e0 26 80 00       	push   $0x8026e0
  800043:	e8 76 01 00 00       	call   8001be <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 77 0e 00 00       	call   800ec4 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 58 27 80 00       	push   $0x802758
  80005c:	e8 5d 01 00 00       	call   8001be <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 08 27 80 00       	push   $0x802708
  800070:	e8 49 01 00 00       	call   8001be <cprintf>
	sys_yield();
  800075:	e8 94 0b 00 00       	call   800c0e <sys_yield>
	sys_yield();
  80007a:	e8 8f 0b 00 00       	call   800c0e <sys_yield>
	sys_yield();
  80007f:	e8 8a 0b 00 00       	call   800c0e <sys_yield>
	sys_yield();
  800084:	e8 85 0b 00 00       	call   800c0e <sys_yield>
	sys_yield();
  800089:	e8 80 0b 00 00       	call   800c0e <sys_yield>
	sys_yield();
  80008e:	e8 7b 0b 00 00       	call   800c0e <sys_yield>
	sys_yield();
  800093:	e8 76 0b 00 00       	call   800c0e <sys_yield>
	sys_yield();
  800098:	e8 71 0b 00 00       	call   800c0e <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 30 27 80 00 	movl   $0x802730,(%esp)
  8000a4:	e8 15 01 00 00       	call   8001be <cprintf>

	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 16 0b 00 00       	call   800bc7 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c8:	e8 1e 0b 00 00       	call   800beb <sys_getenvid>
  8000cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000da:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000df:	85 db                	test   %ebx,%ebx
  8000e1:	7e 07                	jle    8000ea <libmain+0x31>
		binaryname = argv[0];
  8000e3:	8b 06                	mov    (%esi),%eax
  8000e5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ea:	83 ec 08             	sub    $0x8,%esp
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	e8 3f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f4:	e8 0a 00 00 00       	call   800103 <exit>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800103:	f3 0f 1e fb          	endbr32 
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80010d:	e8 37 11 00 00       	call   801249 <close_all>
	sys_env_destroy(0);
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	6a 00                	push   $0x0
  800117:	e8 ab 0a 00 00       	call   800bc7 <sys_env_destroy>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	f3 0f 1e fb          	endbr32 
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	53                   	push   %ebx
  800129:	83 ec 04             	sub    $0x4,%esp
  80012c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012f:	8b 13                	mov    (%ebx),%edx
  800131:	8d 42 01             	lea    0x1(%edx),%eax
  800134:	89 03                	mov    %eax,(%ebx)
  800136:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800139:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80013d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800142:	74 09                	je     80014d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800144:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80014d:	83 ec 08             	sub    $0x8,%esp
  800150:	68 ff 00 00 00       	push   $0xff
  800155:	8d 43 08             	lea    0x8(%ebx),%eax
  800158:	50                   	push   %eax
  800159:	e8 24 0a 00 00       	call   800b82 <sys_cputs>
		b->idx = 0;
  80015e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	eb db                	jmp    800144 <putch+0x23>

00800169 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800169:	f3 0f 1e fb          	endbr32 
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800176:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017d:	00 00 00 
	b.cnt = 0;
  800180:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800187:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018a:	ff 75 0c             	pushl  0xc(%ebp)
  80018d:	ff 75 08             	pushl  0x8(%ebp)
  800190:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	68 21 01 80 00       	push   $0x800121
  80019c:	e8 20 01 00 00       	call   8002c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a1:	83 c4 08             	add    $0x8,%esp
  8001a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 cc 09 00 00       	call   800b82 <sys_cputs>

	return b.cnt;
}
  8001b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001be:	f3 0f 1e fb          	endbr32 
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cb:	50                   	push   %eax
  8001cc:	ff 75 08             	pushl  0x8(%ebp)
  8001cf:	e8 95 ff ff ff       	call   800169 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d4:	c9                   	leave  
  8001d5:	c3                   	ret    

008001d6 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 1c             	sub    $0x1c,%esp
  8001df:	89 c7                	mov    %eax,%edi
  8001e1:	89 d6                	mov    %edx,%esi
  8001e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e9:	89 d1                	mov    %edx,%ecx
  8001eb:	89 c2                	mov    %eax,%edx
  8001ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8001f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800203:	39 c2                	cmp    %eax,%edx
  800205:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800208:	72 3e                	jb     800248 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	ff 75 18             	pushl  0x18(%ebp)
  800210:	83 eb 01             	sub    $0x1,%ebx
  800213:	53                   	push   %ebx
  800214:	50                   	push   %eax
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021b:	ff 75 e0             	pushl  -0x20(%ebp)
  80021e:	ff 75 dc             	pushl  -0x24(%ebp)
  800221:	ff 75 d8             	pushl  -0x28(%ebp)
  800224:	e8 57 22 00 00       	call   802480 <__udivdi3>
  800229:	83 c4 18             	add    $0x18,%esp
  80022c:	52                   	push   %edx
  80022d:	50                   	push   %eax
  80022e:	89 f2                	mov    %esi,%edx
  800230:	89 f8                	mov    %edi,%eax
  800232:	e8 9f ff ff ff       	call   8001d6 <printnum>
  800237:	83 c4 20             	add    $0x20,%esp
  80023a:	eb 13                	jmp    80024f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	56                   	push   %esi
  800240:	ff 75 18             	pushl  0x18(%ebp)
  800243:	ff d7                	call   *%edi
  800245:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800248:	83 eb 01             	sub    $0x1,%ebx
  80024b:	85 db                	test   %ebx,%ebx
  80024d:	7f ed                	jg     80023c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	83 ec 04             	sub    $0x4,%esp
  800256:	ff 75 e4             	pushl  -0x1c(%ebp)
  800259:	ff 75 e0             	pushl  -0x20(%ebp)
  80025c:	ff 75 dc             	pushl  -0x24(%ebp)
  80025f:	ff 75 d8             	pushl  -0x28(%ebp)
  800262:	e8 29 23 00 00       	call   802590 <__umoddi3>
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	0f be 80 80 27 80 00 	movsbl 0x802780(%eax),%eax
  800271:	50                   	push   %eax
  800272:	ff d7                	call   *%edi
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027f:	f3 0f 1e fb          	endbr32 
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800289:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	3b 50 04             	cmp    0x4(%eax),%edx
  800292:	73 0a                	jae    80029e <sprintputch+0x1f>
		*b->buf++ = ch;
  800294:	8d 4a 01             	lea    0x1(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 45 08             	mov    0x8(%ebp),%eax
  80029c:	88 02                	mov    %al,(%edx)
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <printfmt>:
{
  8002a0:	f3 0f 1e fb          	endbr32 
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ad:	50                   	push   %eax
  8002ae:	ff 75 10             	pushl  0x10(%ebp)
  8002b1:	ff 75 0c             	pushl  0xc(%ebp)
  8002b4:	ff 75 08             	pushl  0x8(%ebp)
  8002b7:	e8 05 00 00 00       	call   8002c1 <vprintfmt>
}
  8002bc:	83 c4 10             	add    $0x10,%esp
  8002bf:	c9                   	leave  
  8002c0:	c3                   	ret    

008002c1 <vprintfmt>:
{
  8002c1:	f3 0f 1e fb          	endbr32 
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 3c             	sub    $0x3c,%esp
  8002ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d7:	e9 8e 03 00 00       	jmp    80066a <vprintfmt+0x3a9>
		padc = ' ';
  8002dc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002fa:	8d 47 01             	lea    0x1(%edi),%eax
  8002fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800300:	0f b6 17             	movzbl (%edi),%edx
  800303:	8d 42 dd             	lea    -0x23(%edx),%eax
  800306:	3c 55                	cmp    $0x55,%al
  800308:	0f 87 df 03 00 00    	ja     8006ed <vprintfmt+0x42c>
  80030e:	0f b6 c0             	movzbl %al,%eax
  800311:	3e ff 24 85 c0 28 80 	notrack jmp *0x8028c0(,%eax,4)
  800318:	00 
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80031c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800320:	eb d8                	jmp    8002fa <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800325:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800329:	eb cf                	jmp    8002fa <vprintfmt+0x39>
  80032b:	0f b6 d2             	movzbl %dl,%edx
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800331:	b8 00 00 00 00       	mov    $0x0,%eax
  800336:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800339:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800340:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800343:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800346:	83 f9 09             	cmp    $0x9,%ecx
  800349:	77 55                	ja     8003a0 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80034b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80034e:	eb e9                	jmp    800339 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8b 00                	mov    (%eax),%eax
  800355:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800358:	8b 45 14             	mov    0x14(%ebp),%eax
  80035b:	8d 40 04             	lea    0x4(%eax),%eax
  80035e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800364:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800368:	79 90                	jns    8002fa <vprintfmt+0x39>
				width = precision, precision = -1;
  80036a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80036d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800370:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800377:	eb 81                	jmp    8002fa <vprintfmt+0x39>
  800379:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037c:	85 c0                	test   %eax,%eax
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
  800383:	0f 49 d0             	cmovns %eax,%edx
  800386:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038c:	e9 69 ff ff ff       	jmp    8002fa <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800394:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80039b:	e9 5a ff ff ff       	jmp    8002fa <vprintfmt+0x39>
  8003a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a6:	eb bc                	jmp    800364 <vprintfmt+0xa3>
			lflag++;
  8003a8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ae:	e9 47 ff ff ff       	jmp    8002fa <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 78 04             	lea    0x4(%eax),%edi
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff d6                	call   *%esi
			break;
  8003c1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c7:	e9 9b 02 00 00       	jmp    800667 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 78 04             	lea    0x4(%eax),%edi
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	99                   	cltd   
  8003d5:	31 d0                	xor    %edx,%eax
  8003d7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d9:	83 f8 0f             	cmp    $0xf,%eax
  8003dc:	7f 23                	jg     800401 <vprintfmt+0x140>
  8003de:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	74 18                	je     800401 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003e9:	52                   	push   %edx
  8003ea:	68 25 2c 80 00       	push   $0x802c25
  8003ef:	53                   	push   %ebx
  8003f0:	56                   	push   %esi
  8003f1:	e8 aa fe ff ff       	call   8002a0 <printfmt>
  8003f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003fc:	e9 66 02 00 00       	jmp    800667 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800401:	50                   	push   %eax
  800402:	68 98 27 80 00       	push   $0x802798
  800407:	53                   	push   %ebx
  800408:	56                   	push   %esi
  800409:	e8 92 fe ff ff       	call   8002a0 <printfmt>
  80040e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800411:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800414:	e9 4e 02 00 00       	jmp    800667 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	83 c0 04             	add    $0x4,%eax
  80041f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800427:	85 d2                	test   %edx,%edx
  800429:	b8 91 27 80 00       	mov    $0x802791,%eax
  80042e:	0f 45 c2             	cmovne %edx,%eax
  800431:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800434:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800438:	7e 06                	jle    800440 <vprintfmt+0x17f>
  80043a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80043e:	75 0d                	jne    80044d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800443:	89 c7                	mov    %eax,%edi
  800445:	03 45 e0             	add    -0x20(%ebp),%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044b:	eb 55                	jmp    8004a2 <vprintfmt+0x1e1>
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	ff 75 d8             	pushl  -0x28(%ebp)
  800453:	ff 75 cc             	pushl  -0x34(%ebp)
  800456:	e8 46 03 00 00       	call   8007a1 <strnlen>
  80045b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80045e:	29 c2                	sub    %eax,%edx
  800460:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800468:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80046c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	85 ff                	test   %edi,%edi
  800471:	7e 11                	jle    800484 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	53                   	push   %ebx
  800477:	ff 75 e0             	pushl  -0x20(%ebp)
  80047a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80047c:	83 ef 01             	sub    $0x1,%edi
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	eb eb                	jmp    80046f <vprintfmt+0x1ae>
  800484:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800487:	85 d2                	test   %edx,%edx
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	0f 49 c2             	cmovns %edx,%eax
  800491:	29 c2                	sub    %eax,%edx
  800493:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800496:	eb a8                	jmp    800440 <vprintfmt+0x17f>
					putch(ch, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	53                   	push   %ebx
  80049c:	52                   	push   %edx
  80049d:	ff d6                	call   *%esi
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a7:	83 c7 01             	add    $0x1,%edi
  8004aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ae:	0f be d0             	movsbl %al,%edx
  8004b1:	85 d2                	test   %edx,%edx
  8004b3:	74 4b                	je     800500 <vprintfmt+0x23f>
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	78 06                	js     8004c1 <vprintfmt+0x200>
  8004bb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004bf:	78 1e                	js     8004df <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8004c1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c5:	74 d1                	je     800498 <vprintfmt+0x1d7>
  8004c7:	0f be c0             	movsbl %al,%eax
  8004ca:	83 e8 20             	sub    $0x20,%eax
  8004cd:	83 f8 5e             	cmp    $0x5e,%eax
  8004d0:	76 c6                	jbe    800498 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	6a 3f                	push   $0x3f
  8004d8:	ff d6                	call   *%esi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	eb c3                	jmp    8004a2 <vprintfmt+0x1e1>
  8004df:	89 cf                	mov    %ecx,%edi
  8004e1:	eb 0e                	jmp    8004f1 <vprintfmt+0x230>
				putch(' ', putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	6a 20                	push   $0x20
  8004e9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004eb:	83 ef 01             	sub    $0x1,%edi
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	85 ff                	test   %edi,%edi
  8004f3:	7f ee                	jg     8004e3 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fb:	e9 67 01 00 00       	jmp    800667 <vprintfmt+0x3a6>
  800500:	89 cf                	mov    %ecx,%edi
  800502:	eb ed                	jmp    8004f1 <vprintfmt+0x230>
	if (lflag >= 2)
  800504:	83 f9 01             	cmp    $0x1,%ecx
  800507:	7f 1b                	jg     800524 <vprintfmt+0x263>
	else if (lflag)
  800509:	85 c9                	test   %ecx,%ecx
  80050b:	74 63                	je     800570 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 00                	mov    (%eax),%eax
  800512:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800515:	99                   	cltd   
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 04             	lea    0x4(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
  800522:	eb 17                	jmp    80053b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8b 50 04             	mov    0x4(%eax),%edx
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 40 08             	lea    0x8(%eax),%eax
  800538:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80053b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800541:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800546:	85 c9                	test   %ecx,%ecx
  800548:	0f 89 ff 00 00 00    	jns    80064d <vprintfmt+0x38c>
				putch('-', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	53                   	push   %ebx
  800552:	6a 2d                	push   $0x2d
  800554:	ff d6                	call   *%esi
				num = -(long long) num;
  800556:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800559:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055c:	f7 da                	neg    %edx
  80055e:	83 d1 00             	adc    $0x0,%ecx
  800561:	f7 d9                	neg    %ecx
  800563:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056b:	e9 dd 00 00 00       	jmp    80064d <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800578:	99                   	cltd   
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 04             	lea    0x4(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
  800585:	eb b4                	jmp    80053b <vprintfmt+0x27a>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7f 1e                	jg     8005aa <vprintfmt+0x2e9>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 32                	je     8005c2 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 10                	mov    (%eax),%edx
  800595:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059a:	8d 40 04             	lea    0x4(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005a5:	e9 a3 00 00 00       	jmp    80064d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b2:	8d 40 08             	lea    0x8(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005bd:	e9 8b 00 00 00       	jmp    80064d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005d7:	eb 74                	jmp    80064d <vprintfmt+0x38c>
	if (lflag >= 2)
  8005d9:	83 f9 01             	cmp    $0x1,%ecx
  8005dc:	7f 1b                	jg     8005f9 <vprintfmt+0x338>
	else if (lflag)
  8005de:	85 c9                	test   %ecx,%ecx
  8005e0:	74 2c                	je     80060e <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005f2:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005f7:	eb 54                	jmp    80064d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800607:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80060c:	eb 3f                	jmp    80064d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 10                	mov    (%eax),%edx
  800613:	b9 00 00 00 00       	mov    $0x0,%ecx
  800618:	8d 40 04             	lea    0x4(%eax),%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80061e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800623:	eb 28                	jmp    80064d <vprintfmt+0x38c>
			putch('0', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 30                	push   $0x30
  80062b:	ff d6                	call   *%esi
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 78                	push   $0x78
  800633:	ff d6                	call   *%esi
			num = (unsigned long long)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80063f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800654:	57                   	push   %edi
  800655:	ff 75 e0             	pushl  -0x20(%ebp)
  800658:	50                   	push   %eax
  800659:	51                   	push   %ecx
  80065a:	52                   	push   %edx
  80065b:	89 da                	mov    %ebx,%edx
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	e8 72 fb ff ff       	call   8001d6 <printnum>
			break;
  800664:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  80066a:	83 c7 01             	add    $0x1,%edi
  80066d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800671:	83 f8 25             	cmp    $0x25,%eax
  800674:	0f 84 62 fc ff ff    	je     8002dc <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  80067a:	85 c0                	test   %eax,%eax
  80067c:	0f 84 8b 00 00 00    	je     80070d <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	ff d6                	call   *%esi
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb dc                	jmp    80066a <vprintfmt+0x3a9>
	if (lflag >= 2)
  80068e:	83 f9 01             	cmp    $0x1,%ecx
  800691:	7f 1b                	jg     8006ae <vprintfmt+0x3ed>
	else if (lflag)
  800693:	85 c9                	test   %ecx,%ecx
  800695:	74 2c                	je     8006c3 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a1:	8d 40 04             	lea    0x4(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006ac:	eb 9f                	jmp    80064d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b6:	8d 40 08             	lea    0x8(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006c1:	eb 8a                	jmp    80064d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cd:	8d 40 04             	lea    0x4(%eax),%eax
  8006d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006d8:	e9 70 ff ff ff       	jmp    80064d <vprintfmt+0x38c>
			putch(ch, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 25                	push   $0x25
  8006e3:	ff d6                	call   *%esi
			break;
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	e9 7a ff ff ff       	jmp    800667 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	6a 25                	push   $0x25
  8006f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	89 f8                	mov    %edi,%eax
  8006fa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006fe:	74 05                	je     800705 <vprintfmt+0x444>
  800700:	83 e8 01             	sub    $0x1,%eax
  800703:	eb f5                	jmp    8006fa <vprintfmt+0x439>
  800705:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800708:	e9 5a ff ff ff       	jmp    800667 <vprintfmt+0x3a6>
}
  80070d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800710:	5b                   	pop    %ebx
  800711:	5e                   	pop    %esi
  800712:	5f                   	pop    %edi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800715:	f3 0f 1e fb          	endbr32 
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 18             	sub    $0x18,%esp
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800728:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800736:	85 c0                	test   %eax,%eax
  800738:	74 26                	je     800760 <vsnprintf+0x4b>
  80073a:	85 d2                	test   %edx,%edx
  80073c:	7e 22                	jle    800760 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073e:	ff 75 14             	pushl  0x14(%ebp)
  800741:	ff 75 10             	pushl  0x10(%ebp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	50                   	push   %eax
  800748:	68 7f 02 80 00       	push   $0x80027f
  80074d:	e8 6f fb ff ff       	call   8002c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800752:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800755:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075b:	83 c4 10             	add    $0x10,%esp
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    
		return -E_INVAL;
  800760:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800765:	eb f7                	jmp    80075e <vsnprintf+0x49>

00800767 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800767:	f3 0f 1e fb          	endbr32 
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 92 ff ff ff       	call   800715 <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800785:	f3 0f 1e fb          	endbr32 
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
  800794:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800798:	74 05                	je     80079f <strlen+0x1a>
		n++;
  80079a:	83 c0 01             	add    $0x1,%eax
  80079d:	eb f5                	jmp    800794 <strlen+0xf>
	return n;
}
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a1:	f3 0f 1e fb          	endbr32 
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	39 d0                	cmp    %edx,%eax
  8007b5:	74 0d                	je     8007c4 <strnlen+0x23>
  8007b7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bb:	74 05                	je     8007c2 <strnlen+0x21>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
  8007c0:	eb f1                	jmp    8007b3 <strnlen+0x12>
  8007c2:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c4:	89 d0                	mov    %edx,%eax
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c8:	f3 0f 1e fb          	endbr32 
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007df:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e2:	83 c0 01             	add    $0x1,%eax
  8007e5:	84 d2                	test   %dl,%dl
  8007e7:	75 f2                	jne    8007db <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007e9:	89 c8                	mov    %ecx,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ee:	f3 0f 1e fb          	endbr32 
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 10             	sub    $0x10,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fc:	53                   	push   %ebx
  8007fd:	e8 83 ff ff ff       	call   800785 <strlen>
  800802:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800805:	ff 75 0c             	pushl  0xc(%ebp)
  800808:	01 d8                	add    %ebx,%eax
  80080a:	50                   	push   %eax
  80080b:	e8 b8 ff ff ff       	call   8007c8 <strcpy>
	return dst;
}
  800810:	89 d8                	mov    %ebx,%eax
  800812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
  800826:	89 f3                	mov    %esi,%ebx
  800828:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082b:	89 f0                	mov    %esi,%eax
  80082d:	39 d8                	cmp    %ebx,%eax
  80082f:	74 11                	je     800842 <strncpy+0x2b>
		*dst++ = *src;
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	0f b6 0a             	movzbl (%edx),%ecx
  800837:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083a:	80 f9 01             	cmp    $0x1,%cl
  80083d:	83 da ff             	sbb    $0xffffffff,%edx
  800840:	eb eb                	jmp    80082d <strncpy+0x16>
	}
	return ret;
}
  800842:	89 f0                	mov    %esi,%eax
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800848:	f3 0f 1e fb          	endbr32 
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 55 10             	mov    0x10(%ebp),%edx
  80085a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085c:	85 d2                	test   %edx,%edx
  80085e:	74 21                	je     800881 <strlcpy+0x39>
  800860:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800864:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800866:	39 c2                	cmp    %eax,%edx
  800868:	74 14                	je     80087e <strlcpy+0x36>
  80086a:	0f b6 19             	movzbl (%ecx),%ebx
  80086d:	84 db                	test   %bl,%bl
  80086f:	74 0b                	je     80087c <strlcpy+0x34>
			*dst++ = *src++;
  800871:	83 c1 01             	add    $0x1,%ecx
  800874:	83 c2 01             	add    $0x1,%edx
  800877:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087a:	eb ea                	jmp    800866 <strlcpy+0x1e>
  80087c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800881:	29 f0                	sub    %esi,%eax
}
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800887:	f3 0f 1e fb          	endbr32 
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800894:	0f b6 01             	movzbl (%ecx),%eax
  800897:	84 c0                	test   %al,%al
  800899:	74 0c                	je     8008a7 <strcmp+0x20>
  80089b:	3a 02                	cmp    (%edx),%al
  80089d:	75 08                	jne    8008a7 <strcmp+0x20>
		p++, q++;
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	83 c2 01             	add    $0x1,%edx
  8008a5:	eb ed                	jmp    800894 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 c0             	movzbl %al,%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b1:	f3 0f 1e fb          	endbr32 
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	89 c3                	mov    %eax,%ebx
  8008c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strncmp+0x1b>
		n--, p++, q++;
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008cc:	39 d8                	cmp    %ebx,%eax
  8008ce:	74 16                	je     8008e6 <strncmp+0x35>
  8008d0:	0f b6 08             	movzbl (%eax),%ecx
  8008d3:	84 c9                	test   %cl,%cl
  8008d5:	74 04                	je     8008db <strncmp+0x2a>
  8008d7:	3a 0a                	cmp    (%edx),%cl
  8008d9:	74 eb                	je     8008c6 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 00             	movzbl (%eax),%eax
  8008de:	0f b6 12             	movzbl (%edx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
}
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    
		return 0;
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb f6                	jmp    8008e3 <strncmp+0x32>

008008ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ed:	f3 0f 1e fb          	endbr32 
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fb:	0f b6 10             	movzbl (%eax),%edx
  8008fe:	84 d2                	test   %dl,%dl
  800900:	74 09                	je     80090b <strchr+0x1e>
		if (*s == c)
  800902:	38 ca                	cmp    %cl,%dl
  800904:	74 0a                	je     800910 <strchr+0x23>
	for (; *s; s++)
  800906:	83 c0 01             	add    $0x1,%eax
  800909:	eb f0                	jmp    8008fb <strchr+0xe>
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800912:	f3 0f 1e fb          	endbr32 
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80091c:	6a 78                	push   $0x78
  80091e:	ff 75 08             	pushl  0x8(%ebp)
  800921:	e8 c7 ff ff ff       	call   8008ed <strchr>
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800931:	eb 0d                	jmp    800940 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800933:	c1 e0 04             	shl    $0x4,%eax
  800936:	0f be d2             	movsbl %dl,%edx
  800939:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  80093d:	83 c1 01             	add    $0x1,%ecx
  800940:	0f b6 11             	movzbl (%ecx),%edx
  800943:	84 d2                	test   %dl,%dl
  800945:	74 11                	je     800958 <atox+0x46>
		if (*p>='a'){
  800947:	80 fa 60             	cmp    $0x60,%dl
  80094a:	7e e7                	jle    800933 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  80094c:	c1 e0 04             	shl    $0x4,%eax
  80094f:	0f be d2             	movsbl %dl,%edx
  800952:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800956:	eb e5                	jmp    80093d <atox+0x2b>
	}

	return v;

}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095a:	f3 0f 1e fb          	endbr32 
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800968:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096b:	38 ca                	cmp    %cl,%dl
  80096d:	74 09                	je     800978 <strfind+0x1e>
  80096f:	84 d2                	test   %dl,%dl
  800971:	74 05                	je     800978 <strfind+0x1e>
	for (; *s; s++)
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	eb f0                	jmp    800968 <strfind+0xe>
			break;
	return (char *) s;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097a:	f3 0f 1e fb          	endbr32 
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 7d 08             	mov    0x8(%ebp),%edi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098a:	85 c9                	test   %ecx,%ecx
  80098c:	74 31                	je     8009bf <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098e:	89 f8                	mov    %edi,%eax
  800990:	09 c8                	or     %ecx,%eax
  800992:	a8 03                	test   $0x3,%al
  800994:	75 23                	jne    8009b9 <memset+0x3f>
		c &= 0xFF;
  800996:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099a:	89 d3                	mov    %edx,%ebx
  80099c:	c1 e3 08             	shl    $0x8,%ebx
  80099f:	89 d0                	mov    %edx,%eax
  8009a1:	c1 e0 18             	shl    $0x18,%eax
  8009a4:	89 d6                	mov    %edx,%esi
  8009a6:	c1 e6 10             	shl    $0x10,%esi
  8009a9:	09 f0                	or     %esi,%eax
  8009ab:	09 c2                	or     %eax,%edx
  8009ad:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009af:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	fc                   	cld    
  8009b5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b7:	eb 06                	jmp    8009bf <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bc:	fc                   	cld    
  8009bd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c6:	f3 0f 1e fb          	endbr32 
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d8:	39 c6                	cmp    %eax,%esi
  8009da:	73 32                	jae    800a0e <memmove+0x48>
  8009dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009df:	39 c2                	cmp    %eax,%edx
  8009e1:	76 2b                	jbe    800a0e <memmove+0x48>
		s += n;
		d += n;
  8009e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	89 fe                	mov    %edi,%esi
  8009e8:	09 ce                	or     %ecx,%esi
  8009ea:	09 d6                	or     %edx,%esi
  8009ec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f2:	75 0e                	jne    800a02 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f4:	83 ef 04             	sub    $0x4,%edi
  8009f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009fd:	fd                   	std    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 09                	jmp    800a0b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a02:	83 ef 01             	sub    $0x1,%edi
  800a05:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a08:	fd                   	std    
  800a09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0b:	fc                   	cld    
  800a0c:	eb 1a                	jmp    800a28 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0e:	89 c2                	mov    %eax,%edx
  800a10:	09 ca                	or     %ecx,%edx
  800a12:	09 f2                	or     %esi,%edx
  800a14:	f6 c2 03             	test   $0x3,%dl
  800a17:	75 0a                	jne    800a23 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a19:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a1c:	89 c7                	mov    %eax,%edi
  800a1e:	fc                   	cld    
  800a1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a21:	eb 05                	jmp    800a28 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a23:	89 c7                	mov    %eax,%edi
  800a25:	fc                   	cld    
  800a26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a36:	ff 75 10             	pushl  0x10(%ebp)
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	ff 75 08             	pushl  0x8(%ebp)
  800a3f:	e8 82 ff ff ff       	call   8009c6 <memmove>
}
  800a44:	c9                   	leave  
  800a45:	c3                   	ret    

00800a46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a46:	f3 0f 1e fb          	endbr32 
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a55:	89 c6                	mov    %eax,%esi
  800a57:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5a:	39 f0                	cmp    %esi,%eax
  800a5c:	74 1c                	je     800a7a <memcmp+0x34>
		if (*s1 != *s2)
  800a5e:	0f b6 08             	movzbl (%eax),%ecx
  800a61:	0f b6 1a             	movzbl (%edx),%ebx
  800a64:	38 d9                	cmp    %bl,%cl
  800a66:	75 08                	jne    800a70 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	83 c2 01             	add    $0x1,%edx
  800a6e:	eb ea                	jmp    800a5a <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a70:	0f b6 c1             	movzbl %cl,%eax
  800a73:	0f b6 db             	movzbl %bl,%ebx
  800a76:	29 d8                	sub    %ebx,%eax
  800a78:	eb 05                	jmp    800a7f <memcmp+0x39>
	}

	return 0;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a83:	f3 0f 1e fb          	endbr32 
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a90:	89 c2                	mov    %eax,%edx
  800a92:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a95:	39 d0                	cmp    %edx,%eax
  800a97:	73 09                	jae    800aa2 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a99:	38 08                	cmp    %cl,(%eax)
  800a9b:	74 05                	je     800aa2 <memfind+0x1f>
	for (; s < ends; s++)
  800a9d:	83 c0 01             	add    $0x1,%eax
  800aa0:	eb f3                	jmp    800a95 <memfind+0x12>
			break;
	return (void *) s;
}
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa4:	f3 0f 1e fb          	endbr32 
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab4:	eb 03                	jmp    800ab9 <strtol+0x15>
		s++;
  800ab6:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab9:	0f b6 01             	movzbl (%ecx),%eax
  800abc:	3c 20                	cmp    $0x20,%al
  800abe:	74 f6                	je     800ab6 <strtol+0x12>
  800ac0:	3c 09                	cmp    $0x9,%al
  800ac2:	74 f2                	je     800ab6 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ac4:	3c 2b                	cmp    $0x2b,%al
  800ac6:	74 2a                	je     800af2 <strtol+0x4e>
	int neg = 0;
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800acd:	3c 2d                	cmp    $0x2d,%al
  800acf:	74 2b                	je     800afc <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad7:	75 0f                	jne    800ae8 <strtol+0x44>
  800ad9:	80 39 30             	cmpb   $0x30,(%ecx)
  800adc:	74 28                	je     800b06 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae5:	0f 44 d8             	cmove  %eax,%ebx
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af0:	eb 46                	jmp    800b38 <strtol+0x94>
		s++;
  800af2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af5:	bf 00 00 00 00       	mov    $0x0,%edi
  800afa:	eb d5                	jmp    800ad1 <strtol+0x2d>
		s++, neg = 1;
  800afc:	83 c1 01             	add    $0x1,%ecx
  800aff:	bf 01 00 00 00       	mov    $0x1,%edi
  800b04:	eb cb                	jmp    800ad1 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0a:	74 0e                	je     800b1a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b0c:	85 db                	test   %ebx,%ebx
  800b0e:	75 d8                	jne    800ae8 <strtol+0x44>
		s++, base = 8;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b18:	eb ce                	jmp    800ae8 <strtol+0x44>
		s += 2, base = 16;
  800b1a:	83 c1 02             	add    $0x2,%ecx
  800b1d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b22:	eb c4                	jmp    800ae8 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b24:	0f be d2             	movsbl %dl,%edx
  800b27:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2d:	7d 3a                	jge    800b69 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b2f:	83 c1 01             	add    $0x1,%ecx
  800b32:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b36:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b38:	0f b6 11             	movzbl (%ecx),%edx
  800b3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 09             	cmp    $0x9,%bl
  800b43:	76 df                	jbe    800b24 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b45:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b48:	89 f3                	mov    %esi,%ebx
  800b4a:	80 fb 19             	cmp    $0x19,%bl
  800b4d:	77 08                	ja     800b57 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b4f:	0f be d2             	movsbl %dl,%edx
  800b52:	83 ea 57             	sub    $0x57,%edx
  800b55:	eb d3                	jmp    800b2a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b57:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5a:	89 f3                	mov    %esi,%ebx
  800b5c:	80 fb 19             	cmp    $0x19,%bl
  800b5f:	77 08                	ja     800b69 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	83 ea 37             	sub    $0x37,%edx
  800b67:	eb c1                	jmp    800b2a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6d:	74 05                	je     800b74 <strtol+0xd0>
		*endptr = (char *) s;
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b74:	89 c2                	mov    %eax,%edx
  800b76:	f7 da                	neg    %edx
  800b78:	85 ff                	test   %edi,%edi
  800b7a:	0f 45 c2             	cmovne %edx,%eax
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b82:	f3 0f 1e fb          	endbr32 
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	89 c3                	mov    %eax,%ebx
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	89 c6                	mov    %eax,%esi
  800b9d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba4:	f3 0f 1e fb          	endbr32 
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb8:	89 d1                	mov    %edx,%ecx
  800bba:	89 d3                	mov    %edx,%ebx
  800bbc:	89 d7                	mov    %edx,%edi
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc7:	f3 0f 1e fb          	endbr32 
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bde:	89 cb                	mov    %ecx,%ebx
  800be0:	89 cf                	mov    %ecx,%edi
  800be2:	89 ce                	mov    %ecx,%esi
  800be4:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_yield>:

void
sys_yield(void)
{
  800c0e:	f3 0f 1e fb          	endbr32 
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c22:	89 d1                	mov    %edx,%ecx
  800c24:	89 d3                	mov    %edx,%ebx
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c31:	f3 0f 1e fb          	endbr32 
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3b:	be 00 00 00 00       	mov    $0x0,%esi
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	89 f7                	mov    %esi,%edi
  800c50:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	f3 0f 1e fb          	endbr32 
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c72:	8b 75 18             	mov    0x18(%ebp),%esi
  800c75:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7c:	f3 0f 1e fb          	endbr32 
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	b8 06 00 00 00       	mov    $0x6,%eax
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca1:	f3 0f 1e fb          	endbr32 
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc6:	f3 0f 1e fb          	endbr32 
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ceb:	f3 0f 1e fb          	endbr32 
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d05:	89 df                	mov    %ebx,%edi
  800d07:	89 de                	mov    %ebx,%esi
  800d09:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d10:	f3 0f 1e fb          	endbr32 
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d25:	be 00 00 00 00       	mov    $0x0,%esi
  800d2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d30:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4e:	89 cb                	mov    %ecx,%ebx
  800d50:	89 cf                	mov    %ecx,%edi
  800d52:	89 ce                	mov    %ecx,%esi
  800d54:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d5b:	f3 0f 1e fb          	endbr32 
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d65:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6a:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d6f:	89 d1                	mov    %edx,%ecx
  800d71:	89 d3                	mov    %edx,%ebx
  800d73:	89 d7                	mov    %edx,%edi
  800d75:	89 d6                	mov    %edx,%esi
  800d77:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d7e:	f3 0f 1e fb          	endbr32 
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800da3:	f3 0f 1e fb          	endbr32 
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	b8 10 00 00 00       	mov    $0x10,%eax
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800dc8:	f3 0f 1e fb          	endbr32 
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800dd6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800dd8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ddc:	0f 84 9a 00 00 00    	je     800e7c <pgfault+0xb4>
  800de2:	89 d8                	mov    %ebx,%eax
  800de4:	c1 e8 16             	shr    $0x16,%eax
  800de7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dee:	a8 01                	test   $0x1,%al
  800df0:	0f 84 86 00 00 00    	je     800e7c <pgfault+0xb4>
  800df6:	89 d8                	mov    %ebx,%eax
  800df8:	c1 e8 0c             	shr    $0xc,%eax
  800dfb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e02:	f6 c2 01             	test   $0x1,%dl
  800e05:	74 75                	je     800e7c <pgfault+0xb4>
  800e07:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e0e:	f6 c4 08             	test   $0x8,%ah
  800e11:	74 69                	je     800e7c <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	6a 07                	push   $0x7
  800e18:	68 00 f0 7f 00       	push   $0x7ff000
  800e1d:	6a 00                	push   $0x0
  800e1f:	e8 0d fe ff ff       	call   800c31 <sys_page_alloc>
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	78 63                	js     800e8e <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800e31:	83 ec 04             	sub    $0x4,%esp
  800e34:	68 00 10 00 00       	push   $0x1000
  800e39:	53                   	push   %ebx
  800e3a:	68 00 f0 7f 00       	push   $0x7ff000
  800e3f:	e8 e8 fb ff ff       	call   800a2c <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800e44:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4b:	53                   	push   %ebx
  800e4c:	6a 00                	push   $0x0
  800e4e:	68 00 f0 7f 00       	push   $0x7ff000
  800e53:	6a 00                	push   $0x0
  800e55:	e8 fd fd ff ff       	call   800c57 <sys_page_map>
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	78 3f                	js     800ea0 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	68 00 f0 7f 00       	push   $0x7ff000
  800e69:	6a 00                	push   $0x0
  800e6b:	e8 0c fe ff ff       	call   800c7c <sys_page_unmap>
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	85 c0                	test   %eax,%eax
  800e75:	78 3b                	js     800eb2 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800e77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800e7c:	53                   	push   %ebx
  800e7d:	68 80 2a 80 00       	push   $0x802a80
  800e82:	6a 20                	push   $0x20
  800e84:	68 3e 2b 80 00       	push   $0x802b3e
  800e89:	e8 cf 13 00 00       	call   80225d <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800e8e:	50                   	push   %eax
  800e8f:	68 c0 2a 80 00       	push   $0x802ac0
  800e94:	6a 2c                	push   $0x2c
  800e96:	68 3e 2b 80 00       	push   $0x802b3e
  800e9b:	e8 bd 13 00 00       	call   80225d <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800ea0:	50                   	push   %eax
  800ea1:	68 ec 2a 80 00       	push   $0x802aec
  800ea6:	6a 33                	push   $0x33
  800ea8:	68 3e 2b 80 00       	push   $0x802b3e
  800ead:	e8 ab 13 00 00       	call   80225d <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800eb2:	50                   	push   %eax
  800eb3:	68 14 2b 80 00       	push   $0x802b14
  800eb8:	6a 36                	push   $0x36
  800eba:	68 3e 2b 80 00       	push   $0x802b3e
  800ebf:	e8 99 13 00 00       	call   80225d <_panic>

00800ec4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec4:	f3 0f 1e fb          	endbr32 
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800ed1:	68 c8 0d 80 00       	push   $0x800dc8
  800ed6:	e8 cc 13 00 00       	call   8022a7 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800edb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee0:	cd 30                	int    $0x30
  800ee2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 29                	js     800f15 <fork+0x51>
  800eec:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  800ef3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef7:	75 60                	jne    800f59 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef9:	e8 ed fc ff ff       	call   800beb <sys_getenvid>
  800efe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f03:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f06:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f0b:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f10:	e9 14 01 00 00       	jmp    801029 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  800f15:	50                   	push   %eax
  800f16:	68 49 2b 80 00       	push   $0x802b49
  800f1b:	68 90 00 00 00       	push   $0x90
  800f20:	68 3e 2b 80 00       	push   $0x802b3e
  800f25:	e8 33 13 00 00       	call   80225d <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  800f2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f31:	83 ec 0c             	sub    $0xc,%esp
  800f34:	25 07 0e 00 00       	and    $0xe07,%eax
  800f39:	50                   	push   %eax
  800f3a:	56                   	push   %esi
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	6a 00                	push   $0x0
  800f3f:	e8 13 fd ff ff       	call   800c57 <sys_page_map>
  800f44:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f47:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f4d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f53:	0f 84 95 00 00 00    	je     800fee <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	c1 e8 16             	shr    $0x16,%eax
  800f5e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f65:	a8 01                	test   $0x1,%al
  800f67:	74 de                	je     800f47 <fork+0x83>
  800f69:	89 d8                	mov    %ebx,%eax
  800f6b:	c1 e8 0c             	shr    $0xc,%eax
  800f6e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	74 cd                	je     800f47 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  800f7a:	89 c6                	mov    %eax,%esi
  800f7c:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  800f7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f86:	f6 c6 04             	test   $0x4,%dh
  800f89:	75 9f                	jne    800f2a <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  800f8b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f92:	f6 c2 02             	test   $0x2,%dl
  800f95:	75 0c                	jne    800fa3 <fork+0xdf>
  800f97:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9e:	f6 c4 08             	test   $0x8,%ah
  800fa1:	74 34                	je     800fd7 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	68 05 08 00 00       	push   $0x805
  800fab:	56                   	push   %esi
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 a2 fc ff ff       	call   800c57 <sys_page_map>
			if (r<0) return r;
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 8b                	js     800f47 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	68 05 08 00 00       	push   $0x805
  800fc4:	56                   	push   %esi
  800fc5:	6a 00                	push   $0x0
  800fc7:	56                   	push   %esi
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 88 fc ff ff       	call   800c57 <sys_page_map>
  800fcf:	83 c4 20             	add    $0x20,%esp
  800fd2:	e9 70 ff ff ff       	jmp    800f47 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  800fd7:	83 ec 0c             	sub    $0xc,%esp
  800fda:	6a 05                	push   $0x5
  800fdc:	56                   	push   %esi
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 71 fc ff ff       	call   800c57 <sys_page_map>
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	e9 59 ff ff ff       	jmp    800f47 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	6a 07                	push   $0x7
  800ff3:	68 00 f0 bf ee       	push   $0xeebff000
  800ff8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800ffb:	56                   	push   %esi
  800ffc:	e8 30 fc ff ff       	call   800c31 <sys_page_alloc>
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 2b                	js     801033 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801008:	83 ec 08             	sub    $0x8,%esp
  80100b:	68 1a 23 80 00       	push   $0x80231a
  801010:	56                   	push   %esi
  801011:	e8 d5 fc ff ff       	call   800ceb <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	6a 02                	push   $0x2
  80101b:	56                   	push   %esi
  80101c:	e8 80 fc ff ff       	call   800ca1 <sys_env_set_status>
  801021:	83 c4 10             	add    $0x10,%esp
		return r;
  801024:	85 c0                	test   %eax,%eax
  801026:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801029:	89 f8                	mov    %edi,%eax
  80102b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    
		return r;
  801033:	89 c7                	mov    %eax,%edi
  801035:	eb f2                	jmp    801029 <fork+0x165>

00801037 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801037:	f3 0f 1e fb          	endbr32 
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801041:	68 65 2b 80 00       	push   $0x802b65
  801046:	68 b2 00 00 00       	push   $0xb2
  80104b:	68 3e 2b 80 00       	push   $0x802b3e
  801050:	e8 08 12 00 00       	call   80225d <_panic>

00801055 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801055:	f3 0f 1e fb          	endbr32 
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	05 00 00 00 30       	add    $0x30000000,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
}
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801069:	f3 0f 1e fb          	endbr32 
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801070:	8b 45 08             	mov    0x8(%ebp),%eax
  801073:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801078:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80107d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801084:	f3 0f 1e fb          	endbr32 
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801090:	89 c2                	mov    %eax,%edx
  801092:	c1 ea 16             	shr    $0x16,%edx
  801095:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	74 2d                	je     8010ce <fd_alloc+0x4a>
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	c1 ea 0c             	shr    $0xc,%edx
  8010a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ad:	f6 c2 01             	test   $0x1,%dl
  8010b0:	74 1c                	je     8010ce <fd_alloc+0x4a>
  8010b2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010b7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010bc:	75 d2                	jne    801090 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010c7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8010cc:	eb 0a                	jmp    8010d8 <fd_alloc+0x54>
			*fd_store = fd;
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010da:	f3 0f 1e fb          	endbr32 
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e4:	83 f8 1f             	cmp    $0x1f,%eax
  8010e7:	77 30                	ja     801119 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010e9:	c1 e0 0c             	shl    $0xc,%eax
  8010ec:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8010f7:	f6 c2 01             	test   $0x1,%dl
  8010fa:	74 24                	je     801120 <fd_lookup+0x46>
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	c1 ea 0c             	shr    $0xc,%edx
  801101:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801108:	f6 c2 01             	test   $0x1,%dl
  80110b:	74 1a                	je     801127 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80110d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801110:	89 02                	mov    %eax,(%edx)
	return 0;
  801112:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    
		return -E_INVAL;
  801119:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111e:	eb f7                	jmp    801117 <fd_lookup+0x3d>
		return -E_INVAL;
  801120:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801125:	eb f0                	jmp    801117 <fd_lookup+0x3d>
  801127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112c:	eb e9                	jmp    801117 <fd_lookup+0x3d>

0080112e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80112e:	f3 0f 1e fb          	endbr32 
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80113b:	ba 00 00 00 00       	mov    $0x0,%edx
  801140:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801145:	39 08                	cmp    %ecx,(%eax)
  801147:	74 38                	je     801181 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801149:	83 c2 01             	add    $0x1,%edx
  80114c:	8b 04 95 f8 2b 80 00 	mov    0x802bf8(,%edx,4),%eax
  801153:	85 c0                	test   %eax,%eax
  801155:	75 ee                	jne    801145 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801157:	a1 08 40 80 00       	mov    0x804008,%eax
  80115c:	8b 40 48             	mov    0x48(%eax),%eax
  80115f:	83 ec 04             	sub    $0x4,%esp
  801162:	51                   	push   %ecx
  801163:	50                   	push   %eax
  801164:	68 7c 2b 80 00       	push   $0x802b7c
  801169:	e8 50 f0 ff ff       	call   8001be <cprintf>
	*dev = 0;
  80116e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801171:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    
			*dev = devtab[i];
  801181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801184:	89 01                	mov    %eax,(%ecx)
			return 0;
  801186:	b8 00 00 00 00       	mov    $0x0,%eax
  80118b:	eb f2                	jmp    80117f <dev_lookup+0x51>

0080118d <fd_close>:
{
  80118d:	f3 0f 1e fb          	endbr32 
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 24             	sub    $0x24,%esp
  80119a:	8b 75 08             	mov    0x8(%ebp),%esi
  80119d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011a3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011aa:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ad:	50                   	push   %eax
  8011ae:	e8 27 ff ff ff       	call   8010da <fd_lookup>
  8011b3:	89 c3                	mov    %eax,%ebx
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 05                	js     8011c1 <fd_close+0x34>
	    || fd != fd2)
  8011bc:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011bf:	74 16                	je     8011d7 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8011c1:	89 f8                	mov    %edi,%eax
  8011c3:	84 c0                	test   %al,%al
  8011c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ca:	0f 44 d8             	cmove  %eax,%ebx
}
  8011cd:	89 d8                	mov    %ebx,%eax
  8011cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011dd:	50                   	push   %eax
  8011de:	ff 36                	pushl  (%esi)
  8011e0:	e8 49 ff ff ff       	call   80112e <dev_lookup>
  8011e5:	89 c3                	mov    %eax,%ebx
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 1a                	js     801208 <fd_close+0x7b>
		if (dev->dev_close)
  8011ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011f1:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	74 0b                	je     801208 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	56                   	push   %esi
  801201:	ff d0                	call   *%eax
  801203:	89 c3                	mov    %eax,%ebx
  801205:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801208:	83 ec 08             	sub    $0x8,%esp
  80120b:	56                   	push   %esi
  80120c:	6a 00                	push   $0x0
  80120e:	e8 69 fa ff ff       	call   800c7c <sys_page_unmap>
	return r;
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	eb b5                	jmp    8011cd <fd_close+0x40>

00801218 <close>:

int
close(int fdnum)
{
  801218:	f3 0f 1e fb          	endbr32 
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	ff 75 08             	pushl  0x8(%ebp)
  801229:	e8 ac fe ff ff       	call   8010da <fd_lookup>
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	79 02                	jns    801237 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801235:	c9                   	leave  
  801236:	c3                   	ret    
		return fd_close(fd, 1);
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	6a 01                	push   $0x1
  80123c:	ff 75 f4             	pushl  -0xc(%ebp)
  80123f:	e8 49 ff ff ff       	call   80118d <fd_close>
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	eb ec                	jmp    801235 <close+0x1d>

00801249 <close_all>:

void
close_all(void)
{
  801249:	f3 0f 1e fb          	endbr32 
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	53                   	push   %ebx
  801251:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801254:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801259:	83 ec 0c             	sub    $0xc,%esp
  80125c:	53                   	push   %ebx
  80125d:	e8 b6 ff ff ff       	call   801218 <close>
	for (i = 0; i < MAXFD; i++)
  801262:	83 c3 01             	add    $0x1,%ebx
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	83 fb 20             	cmp    $0x20,%ebx
  80126b:	75 ec                	jne    801259 <close_all+0x10>
}
  80126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801272:	f3 0f 1e fb          	endbr32 
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	57                   	push   %edi
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
  80127c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80127f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 4f fe ff ff       	call   8010da <fd_lookup>
  80128b:	89 c3                	mov    %eax,%ebx
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	0f 88 81 00 00 00    	js     801319 <dup+0xa7>
		return r;
	close(newfdnum);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	e8 75 ff ff ff       	call   801218 <close>

	newfd = INDEX2FD(newfdnum);
  8012a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a6:	c1 e6 0c             	shl    $0xc,%esi
  8012a9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012af:	83 c4 04             	add    $0x4,%esp
  8012b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b5:	e8 af fd ff ff       	call   801069 <fd2data>
  8012ba:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012bc:	89 34 24             	mov    %esi,(%esp)
  8012bf:	e8 a5 fd ff ff       	call   801069 <fd2data>
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c9:	89 d8                	mov    %ebx,%eax
  8012cb:	c1 e8 16             	shr    $0x16,%eax
  8012ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d5:	a8 01                	test   $0x1,%al
  8012d7:	74 11                	je     8012ea <dup+0x78>
  8012d9:	89 d8                	mov    %ebx,%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
  8012de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e5:	f6 c2 01             	test   $0x1,%dl
  8012e8:	75 39                	jne    801323 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012ed:	89 d0                	mov    %edx,%eax
  8012ef:	c1 e8 0c             	shr    $0xc,%eax
  8012f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f9:	83 ec 0c             	sub    $0xc,%esp
  8012fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801301:	50                   	push   %eax
  801302:	56                   	push   %esi
  801303:	6a 00                	push   $0x0
  801305:	52                   	push   %edx
  801306:	6a 00                	push   $0x0
  801308:	e8 4a f9 ff ff       	call   800c57 <sys_page_map>
  80130d:	89 c3                	mov    %eax,%ebx
  80130f:	83 c4 20             	add    $0x20,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 31                	js     801347 <dup+0xd5>
		goto err;

	return newfdnum;
  801316:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801319:	89 d8                	mov    %ebx,%eax
  80131b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801323:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	25 07 0e 00 00       	and    $0xe07,%eax
  801332:	50                   	push   %eax
  801333:	57                   	push   %edi
  801334:	6a 00                	push   $0x0
  801336:	53                   	push   %ebx
  801337:	6a 00                	push   $0x0
  801339:	e8 19 f9 ff ff       	call   800c57 <sys_page_map>
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 20             	add    $0x20,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	79 a3                	jns    8012ea <dup+0x78>
	sys_page_unmap(0, newfd);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	56                   	push   %esi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 2a f9 ff ff       	call   800c7c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801352:	83 c4 08             	add    $0x8,%esp
  801355:	57                   	push   %edi
  801356:	6a 00                	push   $0x0
  801358:	e8 1f f9 ff ff       	call   800c7c <sys_page_unmap>
	return r;
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	eb b7                	jmp    801319 <dup+0xa7>

00801362 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801362:	f3 0f 1e fb          	endbr32 
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	53                   	push   %ebx
  80136a:	83 ec 1c             	sub    $0x1c,%esp
  80136d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801370:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	53                   	push   %ebx
  801375:	e8 60 fd ff ff       	call   8010da <fd_lookup>
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 3f                	js     8013c0 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138b:	ff 30                	pushl  (%eax)
  80138d:	e8 9c fd ff ff       	call   80112e <dev_lookup>
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	78 27                	js     8013c0 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801399:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80139c:	8b 42 08             	mov    0x8(%edx),%eax
  80139f:	83 e0 03             	and    $0x3,%eax
  8013a2:	83 f8 01             	cmp    $0x1,%eax
  8013a5:	74 1e                	je     8013c5 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013aa:	8b 40 08             	mov    0x8(%eax),%eax
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	74 35                	je     8013e6 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	ff 75 10             	pushl  0x10(%ebp)
  8013b7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ba:	52                   	push   %edx
  8013bb:	ff d0                	call   *%eax
  8013bd:	83 c4 10             	add    $0x10,%esp
}
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ca:	8b 40 48             	mov    0x48(%eax),%eax
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	50                   	push   %eax
  8013d2:	68 bd 2b 80 00       	push   $0x802bbd
  8013d7:	e8 e2 ed ff ff       	call   8001be <cprintf>
		return -E_INVAL;
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e4:	eb da                	jmp    8013c0 <read+0x5e>
		return -E_NOT_SUPP;
  8013e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013eb:	eb d3                	jmp    8013c0 <read+0x5e>

008013ed <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ed:	f3 0f 1e fb          	endbr32 
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	57                   	push   %edi
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801400:	bb 00 00 00 00       	mov    $0x0,%ebx
  801405:	eb 02                	jmp    801409 <readn+0x1c>
  801407:	01 c3                	add    %eax,%ebx
  801409:	39 f3                	cmp    %esi,%ebx
  80140b:	73 21                	jae    80142e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	89 f0                	mov    %esi,%eax
  801412:	29 d8                	sub    %ebx,%eax
  801414:	50                   	push   %eax
  801415:	89 d8                	mov    %ebx,%eax
  801417:	03 45 0c             	add    0xc(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	57                   	push   %edi
  80141c:	e8 41 ff ff ff       	call   801362 <read>
		if (m < 0)
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 04                	js     80142c <readn+0x3f>
			return m;
		if (m == 0)
  801428:	75 dd                	jne    801407 <readn+0x1a>
  80142a:	eb 02                	jmp    80142e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80142c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80142e:	89 d8                	mov    %ebx,%eax
  801430:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801438:	f3 0f 1e fb          	endbr32 
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	53                   	push   %ebx
  801440:	83 ec 1c             	sub    $0x1c,%esp
  801443:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801446:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	53                   	push   %ebx
  80144b:	e8 8a fc ff ff       	call   8010da <fd_lookup>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 3a                	js     801491 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801461:	ff 30                	pushl  (%eax)
  801463:	e8 c6 fc ff ff       	call   80112e <dev_lookup>
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 22                	js     801491 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80146f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801472:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801476:	74 1e                	je     801496 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801478:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147b:	8b 52 0c             	mov    0xc(%edx),%edx
  80147e:	85 d2                	test   %edx,%edx
  801480:	74 35                	je     8014b7 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	ff 75 10             	pushl  0x10(%ebp)
  801488:	ff 75 0c             	pushl  0xc(%ebp)
  80148b:	50                   	push   %eax
  80148c:	ff d2                	call   *%edx
  80148e:	83 c4 10             	add    $0x10,%esp
}
  801491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801494:	c9                   	leave  
  801495:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801496:	a1 08 40 80 00       	mov    0x804008,%eax
  80149b:	8b 40 48             	mov    0x48(%eax),%eax
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	50                   	push   %eax
  8014a3:	68 d9 2b 80 00       	push   $0x802bd9
  8014a8:	e8 11 ed ff ff       	call   8001be <cprintf>
		return -E_INVAL;
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b5:	eb da                	jmp    801491 <write+0x59>
		return -E_NOT_SUPP;
  8014b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014bc:	eb d3                	jmp    801491 <write+0x59>

008014be <seek>:

int
seek(int fdnum, off_t offset)
{
  8014be:	f3 0f 1e fb          	endbr32 
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	ff 75 08             	pushl  0x8(%ebp)
  8014cf:	e8 06 fc ff ff       	call   8010da <fd_lookup>
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 0e                	js     8014e9 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8014db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014eb:	f3 0f 1e fb          	endbr32 
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 1c             	sub    $0x1c,%esp
  8014f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	53                   	push   %ebx
  8014fe:	e8 d7 fb ff ff       	call   8010da <fd_lookup>
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	85 c0                	test   %eax,%eax
  801508:	78 37                	js     801541 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801514:	ff 30                	pushl  (%eax)
  801516:	e8 13 fc ff ff       	call   80112e <dev_lookup>
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 1f                	js     801541 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801529:	74 1b                	je     801546 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80152b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152e:	8b 52 18             	mov    0x18(%edx),%edx
  801531:	85 d2                	test   %edx,%edx
  801533:	74 32                	je     801567 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	ff 75 0c             	pushl  0xc(%ebp)
  80153b:	50                   	push   %eax
  80153c:	ff d2                	call   *%edx
  80153e:	83 c4 10             	add    $0x10,%esp
}
  801541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801544:	c9                   	leave  
  801545:	c3                   	ret    
			thisenv->env_id, fdnum);
  801546:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80154b:	8b 40 48             	mov    0x48(%eax),%eax
  80154e:	83 ec 04             	sub    $0x4,%esp
  801551:	53                   	push   %ebx
  801552:	50                   	push   %eax
  801553:	68 9c 2b 80 00       	push   $0x802b9c
  801558:	e8 61 ec ff ff       	call   8001be <cprintf>
		return -E_INVAL;
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801565:	eb da                	jmp    801541 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801567:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80156c:	eb d3                	jmp    801541 <ftruncate+0x56>

0080156e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156e:	f3 0f 1e fb          	endbr32 
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 1c             	sub    $0x1c,%esp
  801579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	ff 75 08             	pushl  0x8(%ebp)
  801583:	e8 52 fb ff ff       	call   8010da <fd_lookup>
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 4b                	js     8015da <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801599:	ff 30                	pushl  (%eax)
  80159b:	e8 8e fb ff ff       	call   80112e <dev_lookup>
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 33                	js     8015da <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8015a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015aa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ae:	74 2f                	je     8015df <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ba:	00 00 00 
	stat->st_isdir = 0;
  8015bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c4:	00 00 00 
	stat->st_dev = dev;
  8015c7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8015d4:	ff 50 14             	call   *0x14(%eax)
  8015d7:	83 c4 10             	add    $0x10,%esp
}
  8015da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    
		return -E_NOT_SUPP;
  8015df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e4:	eb f4                	jmp    8015da <fstat+0x6c>

008015e6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e6:	f3 0f 1e fb          	endbr32 
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	6a 00                	push   $0x0
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	e8 01 02 00 00       	call   8017fd <open>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 1b                	js     801620 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	ff 75 0c             	pushl  0xc(%ebp)
  80160b:	50                   	push   %eax
  80160c:	e8 5d ff ff ff       	call   80156e <fstat>
  801611:	89 c6                	mov    %eax,%esi
	close(fd);
  801613:	89 1c 24             	mov    %ebx,(%esp)
  801616:	e8 fd fb ff ff       	call   801218 <close>
	return r;
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	89 f3                	mov    %esi,%ebx
}
  801620:	89 d8                	mov    %ebx,%eax
  801622:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801625:	5b                   	pop    %ebx
  801626:	5e                   	pop    %esi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
  80162e:	89 c6                	mov    %eax,%esi
  801630:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801632:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801639:	74 27                	je     801662 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80163b:	6a 07                	push   $0x7
  80163d:	68 00 50 80 00       	push   $0x805000
  801642:	56                   	push   %esi
  801643:	ff 35 00 40 80 00    	pushl  0x804000
  801649:	e8 5d 0d 00 00       	call   8023ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80164e:	83 c4 0c             	add    $0xc,%esp
  801651:	6a 00                	push   $0x0
  801653:	53                   	push   %ebx
  801654:	6a 00                	push   $0x0
  801656:	e8 e3 0c 00 00       	call   80233e <ipc_recv>
}
  80165b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165e:	5b                   	pop    %ebx
  80165f:	5e                   	pop    %esi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801662:	83 ec 0c             	sub    $0xc,%esp
  801665:	6a 01                	push   $0x1
  801667:	e8 97 0d 00 00       	call   802403 <ipc_find_env>
  80166c:	a3 00 40 80 00       	mov    %eax,0x804000
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	eb c5                	jmp    80163b <fsipc+0x12>

00801676 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801676:	f3 0f 1e fb          	endbr32 
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	8b 40 0c             	mov    0xc(%eax),%eax
  801686:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80168b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801693:	ba 00 00 00 00       	mov    $0x0,%edx
  801698:	b8 02 00 00 00       	mov    $0x2,%eax
  80169d:	e8 87 ff ff ff       	call   801629 <fsipc>
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <devfile_flush>:
{
  8016a4:	f3 0f 1e fb          	endbr32 
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016be:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c3:	e8 61 ff ff ff       	call   801629 <fsipc>
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <devfile_stat>:
{
  8016ca:	f3 0f 1e fb          	endbr32 
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 04             	sub    $0x4,%esp
  8016d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016db:	8b 40 0c             	mov    0xc(%eax),%eax
  8016de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ed:	e8 37 ff ff ff       	call   801629 <fsipc>
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 2c                	js     801722 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f6:	83 ec 08             	sub    $0x8,%esp
  8016f9:	68 00 50 80 00       	push   $0x805000
  8016fe:	53                   	push   %ebx
  8016ff:	e8 c4 f0 ff ff       	call   8007c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801704:	a1 80 50 80 00       	mov    0x805080,%eax
  801709:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80170f:	a1 84 50 80 00       	mov    0x805084,%eax
  801714:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801725:	c9                   	leave  
  801726:	c3                   	ret    

00801727 <devfile_write>:
{
  801727:	f3 0f 1e fb          	endbr32 
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 0c             	sub    $0xc,%esp
  801731:	8b 45 10             	mov    0x10(%ebp),%eax
  801734:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801739:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80173e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801741:	8b 55 08             	mov    0x8(%ebp),%edx
  801744:	8b 52 0c             	mov    0xc(%edx),%edx
  801747:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80174d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801752:	50                   	push   %eax
  801753:	ff 75 0c             	pushl  0xc(%ebp)
  801756:	68 08 50 80 00       	push   $0x805008
  80175b:	e8 66 f2 ff ff       	call   8009c6 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
  801765:	b8 04 00 00 00       	mov    $0x4,%eax
  80176a:	e8 ba fe ff ff       	call   801629 <fsipc>
}
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <devfile_read>:
{
  801771:	f3 0f 1e fb          	endbr32 
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801788:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80178e:	ba 00 00 00 00       	mov    $0x0,%edx
  801793:	b8 03 00 00 00       	mov    $0x3,%eax
  801798:	e8 8c fe ff ff       	call   801629 <fsipc>
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 1f                	js     8017c2 <devfile_read+0x51>
	assert(r <= n);
  8017a3:	39 f0                	cmp    %esi,%eax
  8017a5:	77 24                	ja     8017cb <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8017a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ac:	7f 36                	jg     8017e4 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	50                   	push   %eax
  8017b2:	68 00 50 80 00       	push   $0x805000
  8017b7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ba:	e8 07 f2 ff ff       	call   8009c6 <memmove>
	return r;
  8017bf:	83 c4 10             	add    $0x10,%esp
}
  8017c2:	89 d8                	mov    %ebx,%eax
  8017c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    
	assert(r <= n);
  8017cb:	68 0c 2c 80 00       	push   $0x802c0c
  8017d0:	68 13 2c 80 00       	push   $0x802c13
  8017d5:	68 8c 00 00 00       	push   $0x8c
  8017da:	68 28 2c 80 00       	push   $0x802c28
  8017df:	e8 79 0a 00 00       	call   80225d <_panic>
	assert(r <= PGSIZE);
  8017e4:	68 33 2c 80 00       	push   $0x802c33
  8017e9:	68 13 2c 80 00       	push   $0x802c13
  8017ee:	68 8d 00 00 00       	push   $0x8d
  8017f3:	68 28 2c 80 00       	push   $0x802c28
  8017f8:	e8 60 0a 00 00       	call   80225d <_panic>

008017fd <open>:
{
  8017fd:	f3 0f 1e fb          	endbr32 
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	83 ec 1c             	sub    $0x1c,%esp
  801809:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80180c:	56                   	push   %esi
  80180d:	e8 73 ef ff ff       	call   800785 <strlen>
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181a:	7f 6c                	jg     801888 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80181c:	83 ec 0c             	sub    $0xc,%esp
  80181f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801822:	50                   	push   %eax
  801823:	e8 5c f8 ff ff       	call   801084 <fd_alloc>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 3c                	js     80186d <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	56                   	push   %esi
  801835:	68 00 50 80 00       	push   $0x805000
  80183a:	e8 89 ef ff ff       	call   8007c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801842:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801847:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184a:	b8 01 00 00 00       	mov    $0x1,%eax
  80184f:	e8 d5 fd ff ff       	call   801629 <fsipc>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	78 19                	js     801876 <open+0x79>
	return fd2num(fd);
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	ff 75 f4             	pushl  -0xc(%ebp)
  801863:	e8 ed f7 ff ff       	call   801055 <fd2num>
  801868:	89 c3                	mov    %eax,%ebx
  80186a:	83 c4 10             	add    $0x10,%esp
}
  80186d:	89 d8                	mov    %ebx,%eax
  80186f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    
		fd_close(fd, 0);
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	6a 00                	push   $0x0
  80187b:	ff 75 f4             	pushl  -0xc(%ebp)
  80187e:	e8 0a f9 ff ff       	call   80118d <fd_close>
		return r;
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	eb e5                	jmp    80186d <open+0x70>
		return -E_BAD_PATH;
  801888:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80188d:	eb de                	jmp    80186d <open+0x70>

0080188f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188f:	f3 0f 1e fb          	endbr32 
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a3:	e8 81 fd ff ff       	call   801629 <fsipc>
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018aa:	f3 0f 1e fb          	endbr32 
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018b4:	68 9f 2c 80 00       	push   $0x802c9f
  8018b9:	ff 75 0c             	pushl  0xc(%ebp)
  8018bc:	e8 07 ef ff ff       	call   8007c8 <strcpy>
	return 0;
}
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devsock_close>:
{
  8018c8:	f3 0f 1e fb          	endbr32 
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	53                   	push   %ebx
  8018d0:	83 ec 10             	sub    $0x10,%esp
  8018d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018d6:	53                   	push   %ebx
  8018d7:	e8 64 0b 00 00       	call   802440 <pageref>
  8018dc:	89 c2                	mov    %eax,%edx
  8018de:	83 c4 10             	add    $0x10,%esp
		return 0;
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8018e6:	83 fa 01             	cmp    $0x1,%edx
  8018e9:	74 05                	je     8018f0 <devsock_close+0x28>
}
  8018eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018f0:	83 ec 0c             	sub    $0xc,%esp
  8018f3:	ff 73 0c             	pushl  0xc(%ebx)
  8018f6:	e8 e3 02 00 00       	call   801bde <nsipc_close>
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	eb eb                	jmp    8018eb <devsock_close+0x23>

00801900 <devsock_write>:
{
  801900:	f3 0f 1e fb          	endbr32 
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80190a:	6a 00                	push   $0x0
  80190c:	ff 75 10             	pushl  0x10(%ebp)
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	ff 70 0c             	pushl  0xc(%eax)
  801918:	e8 b5 03 00 00       	call   801cd2 <nsipc_send>
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <devsock_read>:
{
  80191f:	f3 0f 1e fb          	endbr32 
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801929:	6a 00                	push   $0x0
  80192b:	ff 75 10             	pushl  0x10(%ebp)
  80192e:	ff 75 0c             	pushl  0xc(%ebp)
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
  801934:	ff 70 0c             	pushl  0xc(%eax)
  801937:	e8 1f 03 00 00       	call   801c5b <nsipc_recv>
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <fd2sockid>:
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801944:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801947:	52                   	push   %edx
  801948:	50                   	push   %eax
  801949:	e8 8c f7 ff ff       	call   8010da <fd_lookup>
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	78 10                	js     801965 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801958:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80195e:	39 08                	cmp    %ecx,(%eax)
  801960:	75 05                	jne    801967 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801962:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    
		return -E_NOT_SUPP;
  801967:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80196c:	eb f7                	jmp    801965 <fd2sockid+0x27>

0080196e <alloc_sockfd>:
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	56                   	push   %esi
  801972:	53                   	push   %ebx
  801973:	83 ec 1c             	sub    $0x1c,%esp
  801976:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	e8 03 f7 ff ff       	call   801084 <fd_alloc>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	78 43                	js     8019cd <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	68 07 04 00 00       	push   $0x407
  801992:	ff 75 f4             	pushl  -0xc(%ebp)
  801995:	6a 00                	push   $0x0
  801997:	e8 95 f2 ff ff       	call   800c31 <sys_page_alloc>
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 28                	js     8019cd <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a8:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8019ae:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019ba:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	50                   	push   %eax
  8019c1:	e8 8f f6 ff ff       	call   801055 <fd2num>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	eb 0c                	jmp    8019d9 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	56                   	push   %esi
  8019d1:	e8 08 02 00 00       	call   801bde <nsipc_close>
		return r;
  8019d6:	83 c4 10             	add    $0x10,%esp
}
  8019d9:	89 d8                	mov    %ebx,%eax
  8019db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <accept>:
{
  8019e2:	f3 0f 1e fb          	endbr32 
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	e8 4a ff ff ff       	call   80193e <fd2sockid>
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 1b                	js     801a13 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019f8:	83 ec 04             	sub    $0x4,%esp
  8019fb:	ff 75 10             	pushl  0x10(%ebp)
  8019fe:	ff 75 0c             	pushl  0xc(%ebp)
  801a01:	50                   	push   %eax
  801a02:	e8 22 01 00 00       	call   801b29 <nsipc_accept>
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 05                	js     801a13 <accept+0x31>
	return alloc_sockfd(r);
  801a0e:	e8 5b ff ff ff       	call   80196e <alloc_sockfd>
}
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <bind>:
{
  801a15:	f3 0f 1e fb          	endbr32 
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a22:	e8 17 ff ff ff       	call   80193e <fd2sockid>
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 12                	js     801a3d <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801a2b:	83 ec 04             	sub    $0x4,%esp
  801a2e:	ff 75 10             	pushl  0x10(%ebp)
  801a31:	ff 75 0c             	pushl  0xc(%ebp)
  801a34:	50                   	push   %eax
  801a35:	e8 45 01 00 00       	call   801b7f <nsipc_bind>
  801a3a:	83 c4 10             	add    $0x10,%esp
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <shutdown>:
{
  801a3f:	f3 0f 1e fb          	endbr32 
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	e8 ed fe ff ff       	call   80193e <fd2sockid>
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 0f                	js     801a64 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801a55:	83 ec 08             	sub    $0x8,%esp
  801a58:	ff 75 0c             	pushl  0xc(%ebp)
  801a5b:	50                   	push   %eax
  801a5c:	e8 57 01 00 00       	call   801bb8 <nsipc_shutdown>
  801a61:	83 c4 10             	add    $0x10,%esp
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <connect>:
{
  801a66:	f3 0f 1e fb          	endbr32 
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a70:	8b 45 08             	mov    0x8(%ebp),%eax
  801a73:	e8 c6 fe ff ff       	call   80193e <fd2sockid>
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 12                	js     801a8e <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801a7c:	83 ec 04             	sub    $0x4,%esp
  801a7f:	ff 75 10             	pushl  0x10(%ebp)
  801a82:	ff 75 0c             	pushl  0xc(%ebp)
  801a85:	50                   	push   %eax
  801a86:	e8 71 01 00 00       	call   801bfc <nsipc_connect>
  801a8b:	83 c4 10             	add    $0x10,%esp
}
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <listen>:
{
  801a90:	f3 0f 1e fb          	endbr32 
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9d:	e8 9c fe ff ff       	call   80193e <fd2sockid>
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 0f                	js     801ab5 <listen+0x25>
	return nsipc_listen(r, backlog);
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	ff 75 0c             	pushl  0xc(%ebp)
  801aac:	50                   	push   %eax
  801aad:	e8 83 01 00 00       	call   801c35 <nsipc_listen>
  801ab2:	83 c4 10             	add    $0x10,%esp
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <socket>:

int
socket(int domain, int type, int protocol)
{
  801ab7:	f3 0f 1e fb          	endbr32 
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ac1:	ff 75 10             	pushl  0x10(%ebp)
  801ac4:	ff 75 0c             	pushl  0xc(%ebp)
  801ac7:	ff 75 08             	pushl  0x8(%ebp)
  801aca:	e8 65 02 00 00       	call   801d34 <nsipc_socket>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	78 05                	js     801adb <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801ad6:	e8 93 fe ff ff       	call   80196e <alloc_sockfd>
}
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 04             	sub    $0x4,%esp
  801ae4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ae6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801aed:	74 26                	je     801b15 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801aef:	6a 07                	push   $0x7
  801af1:	68 00 60 80 00       	push   $0x806000
  801af6:	53                   	push   %ebx
  801af7:	ff 35 04 40 80 00    	pushl  0x804004
  801afd:	e8 a9 08 00 00       	call   8023ab <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b02:	83 c4 0c             	add    $0xc,%esp
  801b05:	6a 00                	push   $0x0
  801b07:	6a 00                	push   $0x0
  801b09:	6a 00                	push   $0x0
  801b0b:	e8 2e 08 00 00       	call   80233e <ipc_recv>
}
  801b10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	6a 02                	push   $0x2
  801b1a:	e8 e4 08 00 00       	call   802403 <ipc_find_env>
  801b1f:	a3 04 40 80 00       	mov    %eax,0x804004
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	eb c6                	jmp    801aef <nsipc+0x12>

00801b29 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b29:	f3 0f 1e fb          	endbr32 
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b3d:	8b 06                	mov    (%esi),%eax
  801b3f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b44:	b8 01 00 00 00       	mov    $0x1,%eax
  801b49:	e8 8f ff ff ff       	call   801add <nsipc>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	85 c0                	test   %eax,%eax
  801b52:	79 09                	jns    801b5d <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b5d:	83 ec 04             	sub    $0x4,%esp
  801b60:	ff 35 10 60 80 00    	pushl  0x806010
  801b66:	68 00 60 80 00       	push   $0x806000
  801b6b:	ff 75 0c             	pushl  0xc(%ebp)
  801b6e:	e8 53 ee ff ff       	call   8009c6 <memmove>
		*addrlen = ret->ret_addrlen;
  801b73:	a1 10 60 80 00       	mov    0x806010,%eax
  801b78:	89 06                	mov    %eax,(%esi)
  801b7a:	83 c4 10             	add    $0x10,%esp
	return r;
  801b7d:	eb d5                	jmp    801b54 <nsipc_accept+0x2b>

00801b7f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b7f:	f3 0f 1e fb          	endbr32 
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	53                   	push   %ebx
  801b87:	83 ec 08             	sub    $0x8,%esp
  801b8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b95:	53                   	push   %ebx
  801b96:	ff 75 0c             	pushl  0xc(%ebp)
  801b99:	68 04 60 80 00       	push   $0x806004
  801b9e:	e8 23 ee ff ff       	call   8009c6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ba3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ba9:	b8 02 00 00 00       	mov    $0x2,%eax
  801bae:	e8 2a ff ff ff       	call   801add <nsipc>
}
  801bb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801bb8:	f3 0f 1e fb          	endbr32 
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bd2:	b8 03 00 00 00       	mov    $0x3,%eax
  801bd7:	e8 01 ff ff ff       	call   801add <nsipc>
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <nsipc_close>:

int
nsipc_close(int s)
{
  801bde:	f3 0f 1e fb          	endbr32 
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801bf0:	b8 04 00 00 00       	mov    $0x4,%eax
  801bf5:	e8 e3 fe ff ff       	call   801add <nsipc>
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bfc:	f3 0f 1e fb          	endbr32 
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	53                   	push   %ebx
  801c04:	83 ec 08             	sub    $0x8,%esp
  801c07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c12:	53                   	push   %ebx
  801c13:	ff 75 0c             	pushl  0xc(%ebp)
  801c16:	68 04 60 80 00       	push   $0x806004
  801c1b:	e8 a6 ed ff ff       	call   8009c6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c20:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c26:	b8 05 00 00 00       	mov    $0x5,%eax
  801c2b:	e8 ad fe ff ff       	call   801add <nsipc>
}
  801c30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c33:	c9                   	leave  
  801c34:	c3                   	ret    

00801c35 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c35:	f3 0f 1e fb          	endbr32 
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c4f:	b8 06 00 00 00       	mov    $0x6,%eax
  801c54:	e8 84 fe ff ff       	call   801add <nsipc>
}
  801c59:	c9                   	leave  
  801c5a:	c3                   	ret    

00801c5b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c5b:	f3 0f 1e fb          	endbr32 
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c6f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c75:	8b 45 14             	mov    0x14(%ebp),%eax
  801c78:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c7d:	b8 07 00 00 00       	mov    $0x7,%eax
  801c82:	e8 56 fe ff ff       	call   801add <nsipc>
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 26                	js     801cb3 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801c8d:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801c93:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c98:	0f 4e c6             	cmovle %esi,%eax
  801c9b:	39 c3                	cmp    %eax,%ebx
  801c9d:	7f 1d                	jg     801cbc <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c9f:	83 ec 04             	sub    $0x4,%esp
  801ca2:	53                   	push   %ebx
  801ca3:	68 00 60 80 00       	push   $0x806000
  801ca8:	ff 75 0c             	pushl  0xc(%ebp)
  801cab:	e8 16 ed ff ff       	call   8009c6 <memmove>
  801cb0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801cb3:	89 d8                	mov    %ebx,%eax
  801cb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5e                   	pop    %esi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801cbc:	68 ab 2c 80 00       	push   $0x802cab
  801cc1:	68 13 2c 80 00       	push   $0x802c13
  801cc6:	6a 62                	push   $0x62
  801cc8:	68 c0 2c 80 00       	push   $0x802cc0
  801ccd:	e8 8b 05 00 00       	call   80225d <_panic>

00801cd2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801cd2:	f3 0f 1e fb          	endbr32 
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	53                   	push   %ebx
  801cda:	83 ec 04             	sub    $0x4,%esp
  801cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ce8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cee:	7f 2e                	jg     801d1e <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cf0:	83 ec 04             	sub    $0x4,%esp
  801cf3:	53                   	push   %ebx
  801cf4:	ff 75 0c             	pushl  0xc(%ebp)
  801cf7:	68 0c 60 80 00       	push   $0x80600c
  801cfc:	e8 c5 ec ff ff       	call   8009c6 <memmove>
	nsipcbuf.send.req_size = size;
  801d01:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d07:	8b 45 14             	mov    0x14(%ebp),%eax
  801d0a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d0f:	b8 08 00 00 00       	mov    $0x8,%eax
  801d14:	e8 c4 fd ff ff       	call   801add <nsipc>
}
  801d19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    
	assert(size < 1600);
  801d1e:	68 cc 2c 80 00       	push   $0x802ccc
  801d23:	68 13 2c 80 00       	push   $0x802c13
  801d28:	6a 6d                	push   $0x6d
  801d2a:	68 c0 2c 80 00       	push   $0x802cc0
  801d2f:	e8 29 05 00 00       	call   80225d <_panic>

00801d34 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d34:	f3 0f 1e fb          	endbr32 
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d41:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d49:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d51:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d56:	b8 09 00 00 00       	mov    $0x9,%eax
  801d5b:	e8 7d fd ff ff       	call   801add <nsipc>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d62:	f3 0f 1e fb          	endbr32 
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d6e:	83 ec 0c             	sub    $0xc,%esp
  801d71:	ff 75 08             	pushl  0x8(%ebp)
  801d74:	e8 f0 f2 ff ff       	call   801069 <fd2data>
  801d79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d7b:	83 c4 08             	add    $0x8,%esp
  801d7e:	68 d8 2c 80 00       	push   $0x802cd8
  801d83:	53                   	push   %ebx
  801d84:	e8 3f ea ff ff       	call   8007c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d89:	8b 46 04             	mov    0x4(%esi),%eax
  801d8c:	2b 06                	sub    (%esi),%eax
  801d8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d9b:	00 00 00 
	stat->st_dev = &devpipe;
  801d9e:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801da5:	30 80 00 
	return 0;
}
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801db4:	f3 0f 1e fb          	endbr32 
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc2:	53                   	push   %ebx
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 b2 ee ff ff       	call   800c7c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dca:	89 1c 24             	mov    %ebx,(%esp)
  801dcd:	e8 97 f2 ff ff       	call   801069 <fd2data>
  801dd2:	83 c4 08             	add    $0x8,%esp
  801dd5:	50                   	push   %eax
  801dd6:	6a 00                	push   $0x0
  801dd8:	e8 9f ee ff ff       	call   800c7c <sys_page_unmap>
}
  801ddd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <_pipeisclosed>:
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	57                   	push   %edi
  801de6:	56                   	push   %esi
  801de7:	53                   	push   %ebx
  801de8:	83 ec 1c             	sub    $0x1c,%esp
  801deb:	89 c7                	mov    %eax,%edi
  801ded:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801def:	a1 08 40 80 00       	mov    0x804008,%eax
  801df4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801df7:	83 ec 0c             	sub    $0xc,%esp
  801dfa:	57                   	push   %edi
  801dfb:	e8 40 06 00 00       	call   802440 <pageref>
  801e00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e03:	89 34 24             	mov    %esi,(%esp)
  801e06:	e8 35 06 00 00       	call   802440 <pageref>
		nn = thisenv->env_runs;
  801e0b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	39 cb                	cmp    %ecx,%ebx
  801e19:	74 1b                	je     801e36 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e1b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e1e:	75 cf                	jne    801def <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e20:	8b 42 58             	mov    0x58(%edx),%eax
  801e23:	6a 01                	push   $0x1
  801e25:	50                   	push   %eax
  801e26:	53                   	push   %ebx
  801e27:	68 df 2c 80 00       	push   $0x802cdf
  801e2c:	e8 8d e3 ff ff       	call   8001be <cprintf>
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	eb b9                	jmp    801def <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801e36:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e39:	0f 94 c0             	sete   %al
  801e3c:	0f b6 c0             	movzbl %al,%eax
}
  801e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e42:	5b                   	pop    %ebx
  801e43:	5e                   	pop    %esi
  801e44:	5f                   	pop    %edi
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    

00801e47 <devpipe_write>:
{
  801e47:	f3 0f 1e fb          	endbr32 
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	57                   	push   %edi
  801e4f:	56                   	push   %esi
  801e50:	53                   	push   %ebx
  801e51:	83 ec 28             	sub    $0x28,%esp
  801e54:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e57:	56                   	push   %esi
  801e58:	e8 0c f2 ff ff       	call   801069 <fd2data>
  801e5d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	bf 00 00 00 00       	mov    $0x0,%edi
  801e67:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e6a:	74 4f                	je     801ebb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e6c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e6f:	8b 0b                	mov    (%ebx),%ecx
  801e71:	8d 51 20             	lea    0x20(%ecx),%edx
  801e74:	39 d0                	cmp    %edx,%eax
  801e76:	72 14                	jb     801e8c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801e78:	89 da                	mov    %ebx,%edx
  801e7a:	89 f0                	mov    %esi,%eax
  801e7c:	e8 61 ff ff ff       	call   801de2 <_pipeisclosed>
  801e81:	85 c0                	test   %eax,%eax
  801e83:	75 3b                	jne    801ec0 <devpipe_write+0x79>
			sys_yield();
  801e85:	e8 84 ed ff ff       	call   800c0e <sys_yield>
  801e8a:	eb e0                	jmp    801e6c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e96:	89 c2                	mov    %eax,%edx
  801e98:	c1 fa 1f             	sar    $0x1f,%edx
  801e9b:	89 d1                	mov    %edx,%ecx
  801e9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801ea0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ea3:	83 e2 1f             	and    $0x1f,%edx
  801ea6:	29 ca                	sub    %ecx,%edx
  801ea8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801eac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801eb0:	83 c0 01             	add    $0x1,%eax
  801eb3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801eb6:	83 c7 01             	add    $0x1,%edi
  801eb9:	eb ac                	jmp    801e67 <devpipe_write+0x20>
	return i;
  801ebb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ebe:	eb 05                	jmp    801ec5 <devpipe_write+0x7e>
				return 0;
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <devpipe_read>:
{
  801ecd:	f3 0f 1e fb          	endbr32 
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	57                   	push   %edi
  801ed5:	56                   	push   %esi
  801ed6:	53                   	push   %ebx
  801ed7:	83 ec 18             	sub    $0x18,%esp
  801eda:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801edd:	57                   	push   %edi
  801ede:	e8 86 f1 ff ff       	call   801069 <fd2data>
  801ee3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	be 00 00 00 00       	mov    $0x0,%esi
  801eed:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef0:	75 14                	jne    801f06 <devpipe_read+0x39>
	return i;
  801ef2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef5:	eb 02                	jmp    801ef9 <devpipe_read+0x2c>
				return i;
  801ef7:	89 f0                	mov    %esi,%eax
}
  801ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5f                   	pop    %edi
  801eff:	5d                   	pop    %ebp
  801f00:	c3                   	ret    
			sys_yield();
  801f01:	e8 08 ed ff ff       	call   800c0e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f06:	8b 03                	mov    (%ebx),%eax
  801f08:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f0b:	75 18                	jne    801f25 <devpipe_read+0x58>
			if (i > 0)
  801f0d:	85 f6                	test   %esi,%esi
  801f0f:	75 e6                	jne    801ef7 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801f11:	89 da                	mov    %ebx,%edx
  801f13:	89 f8                	mov    %edi,%eax
  801f15:	e8 c8 fe ff ff       	call   801de2 <_pipeisclosed>
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	74 e3                	je     801f01 <devpipe_read+0x34>
				return 0;
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f23:	eb d4                	jmp    801ef9 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f25:	99                   	cltd   
  801f26:	c1 ea 1b             	shr    $0x1b,%edx
  801f29:	01 d0                	add    %edx,%eax
  801f2b:	83 e0 1f             	and    $0x1f,%eax
  801f2e:	29 d0                	sub    %edx,%eax
  801f30:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f38:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f3b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f3e:	83 c6 01             	add    $0x1,%esi
  801f41:	eb aa                	jmp    801eed <devpipe_read+0x20>

00801f43 <pipe>:
{
  801f43:	f3 0f 1e fb          	endbr32 
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	56                   	push   %esi
  801f4b:	53                   	push   %ebx
  801f4c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f52:	50                   	push   %eax
  801f53:	e8 2c f1 ff ff       	call   801084 <fd_alloc>
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	0f 88 23 01 00 00    	js     802088 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f65:	83 ec 04             	sub    $0x4,%esp
  801f68:	68 07 04 00 00       	push   $0x407
  801f6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f70:	6a 00                	push   $0x0
  801f72:	e8 ba ec ff ff       	call   800c31 <sys_page_alloc>
  801f77:	89 c3                	mov    %eax,%ebx
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	0f 88 04 01 00 00    	js     802088 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f8a:	50                   	push   %eax
  801f8b:	e8 f4 f0 ff ff       	call   801084 <fd_alloc>
  801f90:	89 c3                	mov    %eax,%ebx
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	85 c0                	test   %eax,%eax
  801f97:	0f 88 db 00 00 00    	js     802078 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9d:	83 ec 04             	sub    $0x4,%esp
  801fa0:	68 07 04 00 00       	push   $0x407
  801fa5:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa8:	6a 00                	push   $0x0
  801faa:	e8 82 ec ff ff       	call   800c31 <sys_page_alloc>
  801faf:	89 c3                	mov    %eax,%ebx
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	0f 88 bc 00 00 00    	js     802078 <pipe+0x135>
	va = fd2data(fd0);
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc2:	e8 a2 f0 ff ff       	call   801069 <fd2data>
  801fc7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc9:	83 c4 0c             	add    $0xc,%esp
  801fcc:	68 07 04 00 00       	push   $0x407
  801fd1:	50                   	push   %eax
  801fd2:	6a 00                	push   $0x0
  801fd4:	e8 58 ec ff ff       	call   800c31 <sys_page_alloc>
  801fd9:	89 c3                	mov    %eax,%ebx
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	0f 88 82 00 00 00    	js     802068 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	ff 75 f0             	pushl  -0x10(%ebp)
  801fec:	e8 78 f0 ff ff       	call   801069 <fd2data>
  801ff1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ff8:	50                   	push   %eax
  801ff9:	6a 00                	push   $0x0
  801ffb:	56                   	push   %esi
  801ffc:	6a 00                	push   $0x0
  801ffe:	e8 54 ec ff ff       	call   800c57 <sys_page_map>
  802003:	89 c3                	mov    %eax,%ebx
  802005:	83 c4 20             	add    $0x20,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 4e                	js     80205a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80200c:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802011:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802014:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802016:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802019:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802020:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802023:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802025:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802028:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	ff 75 f4             	pushl  -0xc(%ebp)
  802035:	e8 1b f0 ff ff       	call   801055 <fd2num>
  80203a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80203d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80203f:	83 c4 04             	add    $0x4,%esp
  802042:	ff 75 f0             	pushl  -0x10(%ebp)
  802045:	e8 0b f0 ff ff       	call   801055 <fd2num>
  80204a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80204d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	bb 00 00 00 00       	mov    $0x0,%ebx
  802058:	eb 2e                	jmp    802088 <pipe+0x145>
	sys_page_unmap(0, va);
  80205a:	83 ec 08             	sub    $0x8,%esp
  80205d:	56                   	push   %esi
  80205e:	6a 00                	push   $0x0
  802060:	e8 17 ec ff ff       	call   800c7c <sys_page_unmap>
  802065:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802068:	83 ec 08             	sub    $0x8,%esp
  80206b:	ff 75 f0             	pushl  -0x10(%ebp)
  80206e:	6a 00                	push   $0x0
  802070:	e8 07 ec ff ff       	call   800c7c <sys_page_unmap>
  802075:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802078:	83 ec 08             	sub    $0x8,%esp
  80207b:	ff 75 f4             	pushl  -0xc(%ebp)
  80207e:	6a 00                	push   $0x0
  802080:	e8 f7 eb ff ff       	call   800c7c <sys_page_unmap>
  802085:	83 c4 10             	add    $0x10,%esp
}
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5d                   	pop    %ebp
  802090:	c3                   	ret    

00802091 <pipeisclosed>:
{
  802091:	f3 0f 1e fb          	endbr32 
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80209b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80209e:	50                   	push   %eax
  80209f:	ff 75 08             	pushl  0x8(%ebp)
  8020a2:	e8 33 f0 ff ff       	call   8010da <fd_lookup>
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	78 18                	js     8020c6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8020ae:	83 ec 0c             	sub    $0xc,%esp
  8020b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b4:	e8 b0 ef ff ff       	call   801069 <fd2data>
  8020b9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8020bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020be:	e8 1f fd ff ff       	call   801de2 <_pipeisclosed>
  8020c3:	83 c4 10             	add    $0x10,%esp
}
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    

008020c8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020c8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8020cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d1:	c3                   	ret    

008020d2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020d2:	f3 0f 1e fb          	endbr32 
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020dc:	68 f7 2c 80 00       	push   $0x802cf7
  8020e1:	ff 75 0c             	pushl  0xc(%ebp)
  8020e4:	e8 df e6 ff ff       	call   8007c8 <strcpy>
	return 0;
}
  8020e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ee:	c9                   	leave  
  8020ef:	c3                   	ret    

008020f0 <devcons_write>:
{
  8020f0:	f3 0f 1e fb          	endbr32 
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	57                   	push   %edi
  8020f8:	56                   	push   %esi
  8020f9:	53                   	push   %ebx
  8020fa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802100:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802105:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80210b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80210e:	73 31                	jae    802141 <devcons_write+0x51>
		m = n - tot;
  802110:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802113:	29 f3                	sub    %esi,%ebx
  802115:	83 fb 7f             	cmp    $0x7f,%ebx
  802118:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80211d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802120:	83 ec 04             	sub    $0x4,%esp
  802123:	53                   	push   %ebx
  802124:	89 f0                	mov    %esi,%eax
  802126:	03 45 0c             	add    0xc(%ebp),%eax
  802129:	50                   	push   %eax
  80212a:	57                   	push   %edi
  80212b:	e8 96 e8 ff ff       	call   8009c6 <memmove>
		sys_cputs(buf, m);
  802130:	83 c4 08             	add    $0x8,%esp
  802133:	53                   	push   %ebx
  802134:	57                   	push   %edi
  802135:	e8 48 ea ff ff       	call   800b82 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80213a:	01 de                	add    %ebx,%esi
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	eb ca                	jmp    80210b <devcons_write+0x1b>
}
  802141:	89 f0                	mov    %esi,%eax
  802143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802146:	5b                   	pop    %ebx
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    

0080214b <devcons_read>:
{
  80214b:	f3 0f 1e fb          	endbr32 
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	83 ec 08             	sub    $0x8,%esp
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80215a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80215e:	74 21                	je     802181 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802160:	e8 3f ea ff ff       	call   800ba4 <sys_cgetc>
  802165:	85 c0                	test   %eax,%eax
  802167:	75 07                	jne    802170 <devcons_read+0x25>
		sys_yield();
  802169:	e8 a0 ea ff ff       	call   800c0e <sys_yield>
  80216e:	eb f0                	jmp    802160 <devcons_read+0x15>
	if (c < 0)
  802170:	78 0f                	js     802181 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802172:	83 f8 04             	cmp    $0x4,%eax
  802175:	74 0c                	je     802183 <devcons_read+0x38>
	*(char*)vbuf = c;
  802177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80217a:	88 02                	mov    %al,(%edx)
	return 1;
  80217c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802181:	c9                   	leave  
  802182:	c3                   	ret    
		return 0;
  802183:	b8 00 00 00 00       	mov    $0x0,%eax
  802188:	eb f7                	jmp    802181 <devcons_read+0x36>

0080218a <cputchar>:
{
  80218a:	f3 0f 1e fb          	endbr32 
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802194:	8b 45 08             	mov    0x8(%ebp),%eax
  802197:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80219a:	6a 01                	push   $0x1
  80219c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80219f:	50                   	push   %eax
  8021a0:	e8 dd e9 ff ff       	call   800b82 <sys_cputs>
}
  8021a5:	83 c4 10             	add    $0x10,%esp
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    

008021aa <getchar>:
{
  8021aa:	f3 0f 1e fb          	endbr32 
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8021b4:	6a 01                	push   $0x1
  8021b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021b9:	50                   	push   %eax
  8021ba:	6a 00                	push   $0x0
  8021bc:	e8 a1 f1 ff ff       	call   801362 <read>
	if (r < 0)
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	78 06                	js     8021ce <getchar+0x24>
	if (r < 1)
  8021c8:	74 06                	je     8021d0 <getchar+0x26>
	return c;
  8021ca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8021ce:	c9                   	leave  
  8021cf:	c3                   	ret    
		return -E_EOF;
  8021d0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8021d5:	eb f7                	jmp    8021ce <getchar+0x24>

008021d7 <iscons>:
{
  8021d7:	f3 0f 1e fb          	endbr32 
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021e4:	50                   	push   %eax
  8021e5:	ff 75 08             	pushl  0x8(%ebp)
  8021e8:	e8 ed ee ff ff       	call   8010da <fd_lookup>
  8021ed:	83 c4 10             	add    $0x10,%esp
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	78 11                	js     802205 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8021f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f7:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8021fd:	39 10                	cmp    %edx,(%eax)
  8021ff:	0f 94 c0             	sete   %al
  802202:	0f b6 c0             	movzbl %al,%eax
}
  802205:	c9                   	leave  
  802206:	c3                   	ret    

00802207 <opencons>:
{
  802207:	f3 0f 1e fb          	endbr32 
  80220b:	55                   	push   %ebp
  80220c:	89 e5                	mov    %esp,%ebp
  80220e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802214:	50                   	push   %eax
  802215:	e8 6a ee ff ff       	call   801084 <fd_alloc>
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	85 c0                	test   %eax,%eax
  80221f:	78 3a                	js     80225b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802221:	83 ec 04             	sub    $0x4,%esp
  802224:	68 07 04 00 00       	push   $0x407
  802229:	ff 75 f4             	pushl  -0xc(%ebp)
  80222c:	6a 00                	push   $0x0
  80222e:	e8 fe e9 ff ff       	call   800c31 <sys_page_alloc>
  802233:	83 c4 10             	add    $0x10,%esp
  802236:	85 c0                	test   %eax,%eax
  802238:	78 21                	js     80225b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80223a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223d:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802243:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802248:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80224f:	83 ec 0c             	sub    $0xc,%esp
  802252:	50                   	push   %eax
  802253:	e8 fd ed ff ff       	call   801055 <fd2num>
  802258:	83 c4 10             	add    $0x10,%esp
}
  80225b:	c9                   	leave  
  80225c:	c3                   	ret    

0080225d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80225d:	f3 0f 1e fb          	endbr32 
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	56                   	push   %esi
  802265:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802266:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802269:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80226f:	e8 77 e9 ff ff       	call   800beb <sys_getenvid>
  802274:	83 ec 0c             	sub    $0xc,%esp
  802277:	ff 75 0c             	pushl  0xc(%ebp)
  80227a:	ff 75 08             	pushl  0x8(%ebp)
  80227d:	56                   	push   %esi
  80227e:	50                   	push   %eax
  80227f:	68 04 2d 80 00       	push   $0x802d04
  802284:	e8 35 df ff ff       	call   8001be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802289:	83 c4 18             	add    $0x18,%esp
  80228c:	53                   	push   %ebx
  80228d:	ff 75 10             	pushl  0x10(%ebp)
  802290:	e8 d4 de ff ff       	call   800169 <vcprintf>
	cprintf("\n");
  802295:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  80229c:	e8 1d df ff ff       	call   8001be <cprintf>
  8022a1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022a4:	cc                   	int3   
  8022a5:	eb fd                	jmp    8022a4 <_panic+0x47>

008022a7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022a7:	f3 0f 1e fb          	endbr32 
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022b1:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022b8:	74 0a                	je     8022c4 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bd:	a3 00 70 80 00       	mov    %eax,0x807000

}
  8022c2:	c9                   	leave  
  8022c3:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8022c4:	83 ec 04             	sub    $0x4,%esp
  8022c7:	6a 07                	push   $0x7
  8022c9:	68 00 f0 bf ee       	push   $0xeebff000
  8022ce:	6a 00                	push   $0x0
  8022d0:	e8 5c e9 ff ff       	call   800c31 <sys_page_alloc>
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 2a                	js     802306 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  8022dc:	83 ec 08             	sub    $0x8,%esp
  8022df:	68 1a 23 80 00       	push   $0x80231a
  8022e4:	6a 00                	push   $0x0
  8022e6:	e8 00 ea ff ff       	call   800ceb <sys_env_set_pgfault_upcall>
  8022eb:	83 c4 10             	add    $0x10,%esp
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	79 c8                	jns    8022ba <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  8022f2:	83 ec 04             	sub    $0x4,%esp
  8022f5:	68 54 2d 80 00       	push   $0x802d54
  8022fa:	6a 2c                	push   $0x2c
  8022fc:	68 8a 2d 80 00       	push   $0x802d8a
  802301:	e8 57 ff ff ff       	call   80225d <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802306:	83 ec 04             	sub    $0x4,%esp
  802309:	68 28 2d 80 00       	push   $0x802d28
  80230e:	6a 22                	push   $0x22
  802310:	68 8a 2d 80 00       	push   $0x802d8a
  802315:	e8 43 ff ff ff       	call   80225d <_panic>

0080231a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80231a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80231b:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  802320:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802322:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802325:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802329:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  80232e:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802332:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802334:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802337:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802338:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  80233b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  80233c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  80233d:	c3                   	ret    

0080233e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80233e:	f3 0f 1e fb          	endbr32 
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	56                   	push   %esi
  802346:	53                   	push   %ebx
  802347:	8b 75 08             	mov    0x8(%ebp),%esi
  80234a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802350:	85 c0                	test   %eax,%eax
  802352:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802357:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80235a:	83 ec 0c             	sub    $0xc,%esp
  80235d:	50                   	push   %eax
  80235e:	e8 d4 e9 ff ff       	call   800d37 <sys_ipc_recv>
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	85 c0                	test   %eax,%eax
  802368:	75 2b                	jne    802395 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80236a:	85 f6                	test   %esi,%esi
  80236c:	74 0a                	je     802378 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80236e:	a1 08 40 80 00       	mov    0x804008,%eax
  802373:	8b 40 74             	mov    0x74(%eax),%eax
  802376:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802378:	85 db                	test   %ebx,%ebx
  80237a:	74 0a                	je     802386 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80237c:	a1 08 40 80 00       	mov    0x804008,%eax
  802381:	8b 40 78             	mov    0x78(%eax),%eax
  802384:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802386:	a1 08 40 80 00       	mov    0x804008,%eax
  80238b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80238e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802391:	5b                   	pop    %ebx
  802392:	5e                   	pop    %esi
  802393:	5d                   	pop    %ebp
  802394:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802395:	85 f6                	test   %esi,%esi
  802397:	74 06                	je     80239f <ipc_recv+0x61>
  802399:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80239f:	85 db                	test   %ebx,%ebx
  8023a1:	74 eb                	je     80238e <ipc_recv+0x50>
  8023a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023a9:	eb e3                	jmp    80238e <ipc_recv+0x50>

008023ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023ab:	f3 0f 1e fb          	endbr32 
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	57                   	push   %edi
  8023b3:	56                   	push   %esi
  8023b4:	53                   	push   %ebx
  8023b5:	83 ec 0c             	sub    $0xc,%esp
  8023b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8023c1:	85 db                	test   %ebx,%ebx
  8023c3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023c8:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8023cb:	ff 75 14             	pushl  0x14(%ebp)
  8023ce:	53                   	push   %ebx
  8023cf:	56                   	push   %esi
  8023d0:	57                   	push   %edi
  8023d1:	e8 3a e9 ff ff       	call   800d10 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8023d6:	83 c4 10             	add    $0x10,%esp
  8023d9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023dc:	75 07                	jne    8023e5 <ipc_send+0x3a>
			sys_yield();
  8023de:	e8 2b e8 ff ff       	call   800c0e <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8023e3:	eb e6                	jmp    8023cb <ipc_send+0x20>
		}
		else if (ret == 0)
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	75 08                	jne    8023f1 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8023e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ec:	5b                   	pop    %ebx
  8023ed:	5e                   	pop    %esi
  8023ee:	5f                   	pop    %edi
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8023f1:	50                   	push   %eax
  8023f2:	68 98 2d 80 00       	push   $0x802d98
  8023f7:	6a 48                	push   $0x48
  8023f9:	68 a6 2d 80 00       	push   $0x802da6
  8023fe:	e8 5a fe ff ff       	call   80225d <_panic>

00802403 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802403:	f3 0f 1e fb          	endbr32 
  802407:	55                   	push   %ebp
  802408:	89 e5                	mov    %esp,%ebp
  80240a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80240d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802412:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802415:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80241b:	8b 52 50             	mov    0x50(%edx),%edx
  80241e:	39 ca                	cmp    %ecx,%edx
  802420:	74 11                	je     802433 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802422:	83 c0 01             	add    $0x1,%eax
  802425:	3d 00 04 00 00       	cmp    $0x400,%eax
  80242a:	75 e6                	jne    802412 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80242c:	b8 00 00 00 00       	mov    $0x0,%eax
  802431:	eb 0b                	jmp    80243e <ipc_find_env+0x3b>
			return envs[i].env_id;
  802433:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802436:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80243b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    

00802440 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802440:	f3 0f 1e fb          	endbr32 
  802444:	55                   	push   %ebp
  802445:	89 e5                	mov    %esp,%ebp
  802447:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80244a:	89 c2                	mov    %eax,%edx
  80244c:	c1 ea 16             	shr    $0x16,%edx
  80244f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802456:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80245b:	f6 c1 01             	test   $0x1,%cl
  80245e:	74 1c                	je     80247c <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802460:	c1 e8 0c             	shr    $0xc,%eax
  802463:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80246a:	a8 01                	test   $0x1,%al
  80246c:	74 0e                	je     80247c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80246e:	c1 e8 0c             	shr    $0xc,%eax
  802471:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802478:	ef 
  802479:	0f b7 d2             	movzwl %dx,%edx
}
  80247c:	89 d0                	mov    %edx,%eax
  80247e:	5d                   	pop    %ebp
  80247f:	c3                   	ret    

00802480 <__udivdi3>:
  802480:	f3 0f 1e fb          	endbr32 
  802484:	55                   	push   %ebp
  802485:	57                   	push   %edi
  802486:	56                   	push   %esi
  802487:	53                   	push   %ebx
  802488:	83 ec 1c             	sub    $0x1c,%esp
  80248b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80248f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802493:	8b 74 24 34          	mov    0x34(%esp),%esi
  802497:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80249b:	85 d2                	test   %edx,%edx
  80249d:	75 19                	jne    8024b8 <__udivdi3+0x38>
  80249f:	39 f3                	cmp    %esi,%ebx
  8024a1:	76 4d                	jbe    8024f0 <__udivdi3+0x70>
  8024a3:	31 ff                	xor    %edi,%edi
  8024a5:	89 e8                	mov    %ebp,%eax
  8024a7:	89 f2                	mov    %esi,%edx
  8024a9:	f7 f3                	div    %ebx
  8024ab:	89 fa                	mov    %edi,%edx
  8024ad:	83 c4 1c             	add    $0x1c,%esp
  8024b0:	5b                   	pop    %ebx
  8024b1:	5e                   	pop    %esi
  8024b2:	5f                   	pop    %edi
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    
  8024b5:	8d 76 00             	lea    0x0(%esi),%esi
  8024b8:	39 f2                	cmp    %esi,%edx
  8024ba:	76 14                	jbe    8024d0 <__udivdi3+0x50>
  8024bc:	31 ff                	xor    %edi,%edi
  8024be:	31 c0                	xor    %eax,%eax
  8024c0:	89 fa                	mov    %edi,%edx
  8024c2:	83 c4 1c             	add    $0x1c,%esp
  8024c5:	5b                   	pop    %ebx
  8024c6:	5e                   	pop    %esi
  8024c7:	5f                   	pop    %edi
  8024c8:	5d                   	pop    %ebp
  8024c9:	c3                   	ret    
  8024ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d0:	0f bd fa             	bsr    %edx,%edi
  8024d3:	83 f7 1f             	xor    $0x1f,%edi
  8024d6:	75 48                	jne    802520 <__udivdi3+0xa0>
  8024d8:	39 f2                	cmp    %esi,%edx
  8024da:	72 06                	jb     8024e2 <__udivdi3+0x62>
  8024dc:	31 c0                	xor    %eax,%eax
  8024de:	39 eb                	cmp    %ebp,%ebx
  8024e0:	77 de                	ja     8024c0 <__udivdi3+0x40>
  8024e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e7:	eb d7                	jmp    8024c0 <__udivdi3+0x40>
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	89 d9                	mov    %ebx,%ecx
  8024f2:	85 db                	test   %ebx,%ebx
  8024f4:	75 0b                	jne    802501 <__udivdi3+0x81>
  8024f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	f7 f3                	div    %ebx
  8024ff:	89 c1                	mov    %eax,%ecx
  802501:	31 d2                	xor    %edx,%edx
  802503:	89 f0                	mov    %esi,%eax
  802505:	f7 f1                	div    %ecx
  802507:	89 c6                	mov    %eax,%esi
  802509:	89 e8                	mov    %ebp,%eax
  80250b:	89 f7                	mov    %esi,%edi
  80250d:	f7 f1                	div    %ecx
  80250f:	89 fa                	mov    %edi,%edx
  802511:	83 c4 1c             	add    $0x1c,%esp
  802514:	5b                   	pop    %ebx
  802515:	5e                   	pop    %esi
  802516:	5f                   	pop    %edi
  802517:	5d                   	pop    %ebp
  802518:	c3                   	ret    
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 f9                	mov    %edi,%ecx
  802522:	b8 20 00 00 00       	mov    $0x20,%eax
  802527:	29 f8                	sub    %edi,%eax
  802529:	d3 e2                	shl    %cl,%edx
  80252b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80252f:	89 c1                	mov    %eax,%ecx
  802531:	89 da                	mov    %ebx,%edx
  802533:	d3 ea                	shr    %cl,%edx
  802535:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802539:	09 d1                	or     %edx,%ecx
  80253b:	89 f2                	mov    %esi,%edx
  80253d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 e3                	shl    %cl,%ebx
  802545:	89 c1                	mov    %eax,%ecx
  802547:	d3 ea                	shr    %cl,%edx
  802549:	89 f9                	mov    %edi,%ecx
  80254b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80254f:	89 eb                	mov    %ebp,%ebx
  802551:	d3 e6                	shl    %cl,%esi
  802553:	89 c1                	mov    %eax,%ecx
  802555:	d3 eb                	shr    %cl,%ebx
  802557:	09 de                	or     %ebx,%esi
  802559:	89 f0                	mov    %esi,%eax
  80255b:	f7 74 24 08          	divl   0x8(%esp)
  80255f:	89 d6                	mov    %edx,%esi
  802561:	89 c3                	mov    %eax,%ebx
  802563:	f7 64 24 0c          	mull   0xc(%esp)
  802567:	39 d6                	cmp    %edx,%esi
  802569:	72 15                	jb     802580 <__udivdi3+0x100>
  80256b:	89 f9                	mov    %edi,%ecx
  80256d:	d3 e5                	shl    %cl,%ebp
  80256f:	39 c5                	cmp    %eax,%ebp
  802571:	73 04                	jae    802577 <__udivdi3+0xf7>
  802573:	39 d6                	cmp    %edx,%esi
  802575:	74 09                	je     802580 <__udivdi3+0x100>
  802577:	89 d8                	mov    %ebx,%eax
  802579:	31 ff                	xor    %edi,%edi
  80257b:	e9 40 ff ff ff       	jmp    8024c0 <__udivdi3+0x40>
  802580:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802583:	31 ff                	xor    %edi,%edi
  802585:	e9 36 ff ff ff       	jmp    8024c0 <__udivdi3+0x40>
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__umoddi3>:
  802590:	f3 0f 1e fb          	endbr32 
  802594:	55                   	push   %ebp
  802595:	57                   	push   %edi
  802596:	56                   	push   %esi
  802597:	53                   	push   %ebx
  802598:	83 ec 1c             	sub    $0x1c,%esp
  80259b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80259f:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025a3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025ab:	85 c0                	test   %eax,%eax
  8025ad:	75 19                	jne    8025c8 <__umoddi3+0x38>
  8025af:	39 df                	cmp    %ebx,%edi
  8025b1:	76 5d                	jbe    802610 <__umoddi3+0x80>
  8025b3:	89 f0                	mov    %esi,%eax
  8025b5:	89 da                	mov    %ebx,%edx
  8025b7:	f7 f7                	div    %edi
  8025b9:	89 d0                	mov    %edx,%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	83 c4 1c             	add    $0x1c,%esp
  8025c0:	5b                   	pop    %ebx
  8025c1:	5e                   	pop    %esi
  8025c2:	5f                   	pop    %edi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    
  8025c5:	8d 76 00             	lea    0x0(%esi),%esi
  8025c8:	89 f2                	mov    %esi,%edx
  8025ca:	39 d8                	cmp    %ebx,%eax
  8025cc:	76 12                	jbe    8025e0 <__umoddi3+0x50>
  8025ce:	89 f0                	mov    %esi,%eax
  8025d0:	89 da                	mov    %ebx,%edx
  8025d2:	83 c4 1c             	add    $0x1c,%esp
  8025d5:	5b                   	pop    %ebx
  8025d6:	5e                   	pop    %esi
  8025d7:	5f                   	pop    %edi
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    
  8025da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e0:	0f bd e8             	bsr    %eax,%ebp
  8025e3:	83 f5 1f             	xor    $0x1f,%ebp
  8025e6:	75 50                	jne    802638 <__umoddi3+0xa8>
  8025e8:	39 d8                	cmp    %ebx,%eax
  8025ea:	0f 82 e0 00 00 00    	jb     8026d0 <__umoddi3+0x140>
  8025f0:	89 d9                	mov    %ebx,%ecx
  8025f2:	39 f7                	cmp    %esi,%edi
  8025f4:	0f 86 d6 00 00 00    	jbe    8026d0 <__umoddi3+0x140>
  8025fa:	89 d0                	mov    %edx,%eax
  8025fc:	89 ca                	mov    %ecx,%edx
  8025fe:	83 c4 1c             	add    $0x1c,%esp
  802601:	5b                   	pop    %ebx
  802602:	5e                   	pop    %esi
  802603:	5f                   	pop    %edi
  802604:	5d                   	pop    %ebp
  802605:	c3                   	ret    
  802606:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80260d:	8d 76 00             	lea    0x0(%esi),%esi
  802610:	89 fd                	mov    %edi,%ebp
  802612:	85 ff                	test   %edi,%edi
  802614:	75 0b                	jne    802621 <__umoddi3+0x91>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f7                	div    %edi
  80261f:	89 c5                	mov    %eax,%ebp
  802621:	89 d8                	mov    %ebx,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f5                	div    %ebp
  802627:	89 f0                	mov    %esi,%eax
  802629:	f7 f5                	div    %ebp
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	31 d2                	xor    %edx,%edx
  80262f:	eb 8c                	jmp    8025bd <__umoddi3+0x2d>
  802631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	ba 20 00 00 00       	mov    $0x20,%edx
  80263f:	29 ea                	sub    %ebp,%edx
  802641:	d3 e0                	shl    %cl,%eax
  802643:	89 44 24 08          	mov    %eax,0x8(%esp)
  802647:	89 d1                	mov    %edx,%ecx
  802649:	89 f8                	mov    %edi,%eax
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802651:	89 54 24 04          	mov    %edx,0x4(%esp)
  802655:	8b 54 24 04          	mov    0x4(%esp),%edx
  802659:	09 c1                	or     %eax,%ecx
  80265b:	89 d8                	mov    %ebx,%eax
  80265d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802661:	89 e9                	mov    %ebp,%ecx
  802663:	d3 e7                	shl    %cl,%edi
  802665:	89 d1                	mov    %edx,%ecx
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80266f:	d3 e3                	shl    %cl,%ebx
  802671:	89 c7                	mov    %eax,%edi
  802673:	89 d1                	mov    %edx,%ecx
  802675:	89 f0                	mov    %esi,%eax
  802677:	d3 e8                	shr    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	89 fa                	mov    %edi,%edx
  80267d:	d3 e6                	shl    %cl,%esi
  80267f:	09 d8                	or     %ebx,%eax
  802681:	f7 74 24 08          	divl   0x8(%esp)
  802685:	89 d1                	mov    %edx,%ecx
  802687:	89 f3                	mov    %esi,%ebx
  802689:	f7 64 24 0c          	mull   0xc(%esp)
  80268d:	89 c6                	mov    %eax,%esi
  80268f:	89 d7                	mov    %edx,%edi
  802691:	39 d1                	cmp    %edx,%ecx
  802693:	72 06                	jb     80269b <__umoddi3+0x10b>
  802695:	75 10                	jne    8026a7 <__umoddi3+0x117>
  802697:	39 c3                	cmp    %eax,%ebx
  802699:	73 0c                	jae    8026a7 <__umoddi3+0x117>
  80269b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80269f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026a3:	89 d7                	mov    %edx,%edi
  8026a5:	89 c6                	mov    %eax,%esi
  8026a7:	89 ca                	mov    %ecx,%edx
  8026a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026ae:	29 f3                	sub    %esi,%ebx
  8026b0:	19 fa                	sbb    %edi,%edx
  8026b2:	89 d0                	mov    %edx,%eax
  8026b4:	d3 e0                	shl    %cl,%eax
  8026b6:	89 e9                	mov    %ebp,%ecx
  8026b8:	d3 eb                	shr    %cl,%ebx
  8026ba:	d3 ea                	shr    %cl,%edx
  8026bc:	09 d8                	or     %ebx,%eax
  8026be:	83 c4 1c             	add    $0x1c,%esp
  8026c1:	5b                   	pop    %ebx
  8026c2:	5e                   	pop    %esi
  8026c3:	5f                   	pop    %edi
  8026c4:	5d                   	pop    %ebp
  8026c5:	c3                   	ret    
  8026c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026cd:	8d 76 00             	lea    0x0(%esi),%esi
  8026d0:	29 fe                	sub    %edi,%esi
  8026d2:	19 c3                	sbb    %eax,%ebx
  8026d4:	89 f2                	mov    %esi,%edx
  8026d6:	89 d9                	mov    %ebx,%ecx
  8026d8:	e9 1d ff ff ff       	jmp    8025fa <__umoddi3+0x6a>
