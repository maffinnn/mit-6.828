
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 04 01 00 00       	call   800135 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	68 00 20 00 00       	push   $0x2000
  800047:	68 20 40 80 00       	push   $0x804020
  80004c:	56                   	push   %esi
  80004d:	e8 49 11 00 00       	call   80119b <read>
  800052:	89 c3                	mov    %eax,%ebx
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	7e 2f                	jle    80008a <cat+0x57>
		if ((r = write(1, buf, n)) != n)
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	53                   	push   %ebx
  80005f:	68 20 40 80 00       	push   $0x804020
  800064:	6a 01                	push   $0x1
  800066:	e8 06 12 00 00       	call   801271 <write>
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	39 c3                	cmp    %eax,%ebx
  800070:	74 cd                	je     80003f <cat+0xc>
			panic("write error copying %s: %e", s, r);
  800072:	83 ec 0c             	sub    $0xc,%esp
  800075:	50                   	push   %eax
  800076:	ff 75 0c             	pushl  0xc(%ebp)
  800079:	68 60 25 80 00       	push   $0x802560
  80007e:	6a 0d                	push   $0xd
  800080:	68 7b 25 80 00       	push   $0x80257b
  800085:	e8 13 01 00 00       	call   80019d <_panic>
	if (n < 0)
  80008a:	78 07                	js     800093 <cat+0x60>
		panic("error reading %s: %e", s, n);
}
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
		panic("error reading %s: %e", s, n);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	50                   	push   %eax
  800097:	ff 75 0c             	pushl  0xc(%ebp)
  80009a:	68 86 25 80 00       	push   $0x802586
  80009f:	6a 0f                	push   $0xf
  8000a1:	68 7b 25 80 00       	push   $0x80257b
  8000a6:	e8 f2 00 00 00       	call   80019d <_panic>

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	f3 0f 1e fb          	endbr32 
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 0c             	sub    $0xc,%esp
  8000b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000bb:	c7 05 00 30 80 00 9b 	movl   $0x80259b,0x803000
  8000c2:	25 80 00 
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000c5:	be 01 00 00 00       	mov    $0x1,%esi
	if (argc == 1)
  8000ca:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ce:	75 31                	jne    800101 <umain+0x56>
		cat(0, "<stdin>");
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	68 9f 25 80 00       	push   $0x80259f
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 54 ff ff ff       	call   800033 <cat>
  8000df:	83 c4 10             	add    $0x10,%esp
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  8000e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    
				printf("can't open %s: %e\n", argv[i], f);
  8000ea:	83 ec 04             	sub    $0x4,%esp
  8000ed:	50                   	push   %eax
  8000ee:	ff 34 b7             	pushl  (%edi,%esi,4)
  8000f1:	68 a7 25 80 00       	push   $0x8025a7
  8000f6:	e8 f2 16 00 00       	call   8017ed <printf>
  8000fb:	83 c4 10             	add    $0x10,%esp
		for (i = 1; i < argc; i++) {
  8000fe:	83 c6 01             	add    $0x1,%esi
  800101:	3b 75 08             	cmp    0x8(%ebp),%esi
  800104:	7d dc                	jge    8000e2 <umain+0x37>
			f = open(argv[i], O_RDONLY);
  800106:	83 ec 08             	sub    $0x8,%esp
  800109:	6a 00                	push   $0x0
  80010b:	ff 34 b7             	pushl  (%edi,%esi,4)
  80010e:	e8 23 15 00 00       	call   801636 <open>
  800113:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	85 c0                	test   %eax,%eax
  80011a:	78 ce                	js     8000ea <umain+0x3f>
				cat(f, argv[i]);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	ff 34 b7             	pushl  (%edi,%esi,4)
  800122:	50                   	push   %eax
  800123:	e8 0b ff ff ff       	call   800033 <cat>
				close(f);
  800128:	89 1c 24             	mov    %ebx,(%esp)
  80012b:	e8 21 0f 00 00       	call   801051 <close>
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	eb c9                	jmp    8000fe <umain+0x53>

00800135 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
  80013e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800141:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800144:	e8 68 0b 00 00       	call   800cb1 <sys_getenvid>
  800149:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800151:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800156:	a3 20 60 80 00       	mov    %eax,0x806020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015b:	85 db                	test   %ebx,%ebx
  80015d:	7e 07                	jle    800166 <libmain+0x31>
		binaryname = argv[0];
  80015f:	8b 06                	mov    (%esi),%eax
  800161:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800166:	83 ec 08             	sub    $0x8,%esp
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	e8 3b ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  800170:	e8 0a 00 00 00       	call   80017f <exit>
}
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017f:	f3 0f 1e fb          	endbr32 
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800189:	e8 f4 0e 00 00       	call   801082 <close_all>
	sys_env_destroy(0);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	6a 00                	push   $0x0
  800193:	e8 f5 0a 00 00       	call   800c8d <sys_env_destroy>
}
  800198:	83 c4 10             	add    $0x10,%esp
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019d:	f3 0f 1e fb          	endbr32 
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001af:	e8 fd 0a 00 00       	call   800cb1 <sys_getenvid>
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ba:	ff 75 08             	pushl  0x8(%ebp)
  8001bd:	56                   	push   %esi
  8001be:	50                   	push   %eax
  8001bf:	68 c4 25 80 00       	push   $0x8025c4
  8001c4:	e8 bb 00 00 00       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c9:	83 c4 18             	add    $0x18,%esp
  8001cc:	53                   	push   %ebx
  8001cd:	ff 75 10             	pushl  0x10(%ebp)
  8001d0:	e8 5a 00 00 00       	call   80022f <vcprintf>
	cprintf("\n");
  8001d5:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  8001dc:	e8 a3 00 00 00       	call   800284 <cprintf>
  8001e1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e4:	cc                   	int3   
  8001e5:	eb fd                	jmp    8001e4 <_panic+0x47>

008001e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e7:	f3 0f 1e fb          	endbr32 
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 04             	sub    $0x4,%esp
  8001f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f5:	8b 13                	mov    (%ebx),%edx
  8001f7:	8d 42 01             	lea    0x1(%edx),%eax
  8001fa:	89 03                	mov    %eax,(%ebx)
  8001fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800203:	3d ff 00 00 00       	cmp    $0xff,%eax
  800208:	74 09                	je     800213 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80020a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800211:	c9                   	leave  
  800212:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	68 ff 00 00 00       	push   $0xff
  80021b:	8d 43 08             	lea    0x8(%ebx),%eax
  80021e:	50                   	push   %eax
  80021f:	e8 24 0a 00 00       	call   800c48 <sys_cputs>
		b->idx = 0;
  800224:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	eb db                	jmp    80020a <putch+0x23>

0080022f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022f:	f3 0f 1e fb          	endbr32 
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 e7 01 80 00       	push   $0x8001e7
  800262:	e8 20 01 00 00       	call   800387 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 cc 09 00 00       	call   800c48 <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	f3 0f 1e fb          	endbr32 
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	e8 95 ff ff ff       	call   80022f <vcprintf>
	va_end(ap);

	return cnt;
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 1c             	sub    $0x1c,%esp
  8002a5:	89 c7                	mov    %eax,%edi
  8002a7:	89 d6                	mov    %edx,%esi
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002af:	89 d1                	mov    %edx,%ecx
  8002b1:	89 c2                	mov    %eax,%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8002bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002c9:	39 c2                	cmp    %eax,%edx
  8002cb:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002ce:	72 3e                	jb     80030e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	83 eb 01             	sub    $0x1,%ebx
  8002d9:	53                   	push   %ebx
  8002da:	50                   	push   %eax
  8002db:	83 ec 08             	sub    $0x8,%esp
  8002de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ea:	e8 11 20 00 00       	call   802300 <__udivdi3>
  8002ef:	83 c4 18             	add    $0x18,%esp
  8002f2:	52                   	push   %edx
  8002f3:	50                   	push   %eax
  8002f4:	89 f2                	mov    %esi,%edx
  8002f6:	89 f8                	mov    %edi,%eax
  8002f8:	e8 9f ff ff ff       	call   80029c <printnum>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	eb 13                	jmp    800315 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	56                   	push   %esi
  800306:	ff 75 18             	pushl  0x18(%ebp)
  800309:	ff d7                	call   *%edi
  80030b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80030e:	83 eb 01             	sub    $0x1,%ebx
  800311:	85 db                	test   %ebx,%ebx
  800313:	7f ed                	jg     800302 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	56                   	push   %esi
  800319:	83 ec 04             	sub    $0x4,%esp
  80031c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031f:	ff 75 e0             	pushl  -0x20(%ebp)
  800322:	ff 75 dc             	pushl  -0x24(%ebp)
  800325:	ff 75 d8             	pushl  -0x28(%ebp)
  800328:	e8 e3 20 00 00       	call   802410 <__umoddi3>
  80032d:	83 c4 14             	add    $0x14,%esp
  800330:	0f be 80 e7 25 80 00 	movsbl 0x8025e7(%eax),%eax
  800337:	50                   	push   %eax
  800338:	ff d7                	call   *%edi
}
  80033a:	83 c4 10             	add    $0x10,%esp
  80033d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800345:	f3 0f 1e fb          	endbr32 
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 0a                	jae    800364 <sprintputch+0x1f>
		*b->buf++ = ch;
  80035a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	88 02                	mov    %al,(%edx)
}
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <printfmt>:
{
  800366:	f3 0f 1e fb          	endbr32 
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800370:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800373:	50                   	push   %eax
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 05 00 00 00       	call   800387 <vprintfmt>
}
  800382:	83 c4 10             	add    $0x10,%esp
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <vprintfmt>:
{
  800387:	f3 0f 1e fb          	endbr32 
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	57                   	push   %edi
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	83 ec 3c             	sub    $0x3c,%esp
  800394:	8b 75 08             	mov    0x8(%ebp),%esi
  800397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039d:	e9 8e 03 00 00       	jmp    800730 <vprintfmt+0x3a9>
		padc = ' ';
  8003a2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ad:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8d 47 01             	lea    0x1(%edi),%eax
  8003c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c6:	0f b6 17             	movzbl (%edi),%edx
  8003c9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cc:	3c 55                	cmp    $0x55,%al
  8003ce:	0f 87 df 03 00 00    	ja     8007b3 <vprintfmt+0x42c>
  8003d4:	0f b6 c0             	movzbl %al,%eax
  8003d7:	3e ff 24 85 20 27 80 	notrack jmp *0x802720(,%eax,4)
  8003de:	00 
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e2:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003e6:	eb d8                	jmp    8003c0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ef:	eb cf                	jmp    8003c0 <vprintfmt+0x39>
  8003f1:	0f b6 d2             	movzbl %dl,%edx
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800402:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800406:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800409:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040c:	83 f9 09             	cmp    $0x9,%ecx
  80040f:	77 55                	ja     800466 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800411:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800414:	eb e9                	jmp    8003ff <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 40 04             	lea    0x4(%eax),%eax
  800424:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	79 90                	jns    8003c0 <vprintfmt+0x39>
				width = precision, precision = -1;
  800430:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043d:	eb 81                	jmp    8003c0 <vprintfmt+0x39>
  80043f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800442:	85 c0                	test   %eax,%eax
  800444:	ba 00 00 00 00       	mov    $0x0,%edx
  800449:	0f 49 d0             	cmovns %eax,%edx
  80044c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800452:	e9 69 ff ff ff       	jmp    8003c0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80045a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800461:	e9 5a ff ff ff       	jmp    8003c0 <vprintfmt+0x39>
  800466:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800469:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046c:	eb bc                	jmp    80042a <vprintfmt+0xa3>
			lflag++;
  80046e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800474:	e9 47 ff ff ff       	jmp    8003c0 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 78 04             	lea    0x4(%eax),%edi
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	ff 30                	pushl  (%eax)
  800485:	ff d6                	call   *%esi
			break;
  800487:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80048a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80048d:	e9 9b 02 00 00       	jmp    80072d <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 78 04             	lea    0x4(%eax),%edi
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	99                   	cltd   
  80049b:	31 d0                	xor    %edx,%eax
  80049d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 0f             	cmp    $0xf,%eax
  8004a2:	7f 23                	jg     8004c7 <vprintfmt+0x140>
  8004a4:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	74 18                	je     8004c7 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004af:	52                   	push   %edx
  8004b0:	68 89 29 80 00       	push   $0x802989
  8004b5:	53                   	push   %ebx
  8004b6:	56                   	push   %esi
  8004b7:	e8 aa fe ff ff       	call   800366 <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004bf:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c2:	e9 66 02 00 00       	jmp    80072d <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8004c7:	50                   	push   %eax
  8004c8:	68 ff 25 80 00       	push   $0x8025ff
  8004cd:	53                   	push   %ebx
  8004ce:	56                   	push   %esi
  8004cf:	e8 92 fe ff ff       	call   800366 <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004da:	e9 4e 02 00 00       	jmp    80072d <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	83 c0 04             	add    $0x4,%eax
  8004e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	b8 f8 25 80 00       	mov    $0x8025f8,%eax
  8004f4:	0f 45 c2             	cmovne %edx,%eax
  8004f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fe:	7e 06                	jle    800506 <vprintfmt+0x17f>
  800500:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800504:	75 0d                	jne    800513 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800509:	89 c7                	mov    %eax,%edi
  80050b:	03 45 e0             	add    -0x20(%ebp),%eax
  80050e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800511:	eb 55                	jmp    800568 <vprintfmt+0x1e1>
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	ff 75 d8             	pushl  -0x28(%ebp)
  800519:	ff 75 cc             	pushl  -0x34(%ebp)
  80051c:	e8 46 03 00 00       	call   800867 <strnlen>
  800521:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800524:	29 c2                	sub    %eax,%edx
  800526:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80052e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	85 ff                	test   %edi,%edi
  800537:	7e 11                	jle    80054a <vprintfmt+0x1c3>
					putch(padc, putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	ff 75 e0             	pushl  -0x20(%ebp)
  800540:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	83 ef 01             	sub    $0x1,%edi
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb eb                	jmp    800535 <vprintfmt+0x1ae>
  80054a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80054d:	85 d2                	test   %edx,%edx
  80054f:	b8 00 00 00 00       	mov    $0x0,%eax
  800554:	0f 49 c2             	cmovns %edx,%eax
  800557:	29 c2                	sub    %eax,%edx
  800559:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055c:	eb a8                	jmp    800506 <vprintfmt+0x17f>
					putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	52                   	push   %edx
  800563:	ff d6                	call   *%esi
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056d:	83 c7 01             	add    $0x1,%edi
  800570:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800574:	0f be d0             	movsbl %al,%edx
  800577:	85 d2                	test   %edx,%edx
  800579:	74 4b                	je     8005c6 <vprintfmt+0x23f>
  80057b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057f:	78 06                	js     800587 <vprintfmt+0x200>
  800581:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800585:	78 1e                	js     8005a5 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800587:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80058b:	74 d1                	je     80055e <vprintfmt+0x1d7>
  80058d:	0f be c0             	movsbl %al,%eax
  800590:	83 e8 20             	sub    $0x20,%eax
  800593:	83 f8 5e             	cmp    $0x5e,%eax
  800596:	76 c6                	jbe    80055e <vprintfmt+0x1d7>
					putch('?', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	53                   	push   %ebx
  80059c:	6a 3f                	push   $0x3f
  80059e:	ff d6                	call   *%esi
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	eb c3                	jmp    800568 <vprintfmt+0x1e1>
  8005a5:	89 cf                	mov    %ecx,%edi
  8005a7:	eb 0e                	jmp    8005b7 <vprintfmt+0x230>
				putch(' ', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 20                	push   $0x20
  8005af:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f ee                	jg     8005a9 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c1:	e9 67 01 00 00       	jmp    80072d <vprintfmt+0x3a6>
  8005c6:	89 cf                	mov    %ecx,%edi
  8005c8:	eb ed                	jmp    8005b7 <vprintfmt+0x230>
	if (lflag >= 2)
  8005ca:	83 f9 01             	cmp    $0x1,%ecx
  8005cd:	7f 1b                	jg     8005ea <vprintfmt+0x263>
	else if (lflag)
  8005cf:	85 c9                	test   %ecx,%ecx
  8005d1:	74 63                	je     800636 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	99                   	cltd   
  8005dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e8:	eb 17                	jmp    800601 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 50 04             	mov    0x4(%eax),%edx
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 40 08             	lea    0x8(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800601:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800604:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80060c:	85 c9                	test   %ecx,%ecx
  80060e:	0f 89 ff 00 00 00    	jns    800713 <vprintfmt+0x38c>
				putch('-', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 2d                	push   $0x2d
  80061a:	ff d6                	call   *%esi
				num = -(long long) num;
  80061c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800622:	f7 da                	neg    %edx
  800624:	83 d1 00             	adc    $0x0,%ecx
  800627:	f7 d9                	neg    %ecx
  800629:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80062c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800631:	e9 dd 00 00 00       	jmp    800713 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	99                   	cltd   
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
  80064b:	eb b4                	jmp    800601 <vprintfmt+0x27a>
	if (lflag >= 2)
  80064d:	83 f9 01             	cmp    $0x1,%ecx
  800650:	7f 1e                	jg     800670 <vprintfmt+0x2e9>
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	74 32                	je     800688 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800660:	8d 40 04             	lea    0x4(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80066b:	e9 a3 00 00 00       	jmp    800713 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 10                	mov    (%eax),%edx
  800675:	8b 48 04             	mov    0x4(%eax),%ecx
  800678:	8d 40 08             	lea    0x8(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80067e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800683:	e9 8b 00 00 00       	jmp    800713 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800698:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80069d:	eb 74                	jmp    800713 <vprintfmt+0x38c>
	if (lflag >= 2)
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7f 1b                	jg     8006bf <vprintfmt+0x338>
	else if (lflag)
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	74 2c                	je     8006d4 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006b8:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8006bd:	eb 54                	jmp    800713 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006cd:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8006d2:	eb 3f                	jmp    800713 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 10                	mov    (%eax),%edx
  8006d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006de:	8d 40 04             	lea    0x4(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e4:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006e9:	eb 28                	jmp    800713 <vprintfmt+0x38c>
			putch('0', putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	6a 30                	push   $0x30
  8006f1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f3:	83 c4 08             	add    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 78                	push   $0x78
  8006f9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800705:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80071a:	57                   	push   %edi
  80071b:	ff 75 e0             	pushl  -0x20(%ebp)
  80071e:	50                   	push   %eax
  80071f:	51                   	push   %ecx
  800720:	52                   	push   %edx
  800721:	89 da                	mov    %ebx,%edx
  800723:	89 f0                	mov    %esi,%eax
  800725:	e8 72 fb ff ff       	call   80029c <printnum>
			break;
  80072a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800730:	83 c7 01             	add    $0x1,%edi
  800733:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800737:	83 f8 25             	cmp    $0x25,%eax
  80073a:	0f 84 62 fc ff ff    	je     8003a2 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800740:	85 c0                	test   %eax,%eax
  800742:	0f 84 8b 00 00 00    	je     8007d3 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	50                   	push   %eax
  80074d:	ff d6                	call   *%esi
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb dc                	jmp    800730 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800754:	83 f9 01             	cmp    $0x1,%ecx
  800757:	7f 1b                	jg     800774 <vprintfmt+0x3ed>
	else if (lflag)
  800759:	85 c9                	test   %ecx,%ecx
  80075b:	74 2c                	je     800789 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80075d:	8b 45 14             	mov    0x14(%ebp),%eax
  800760:	8b 10                	mov    (%eax),%edx
  800762:	b9 00 00 00 00       	mov    $0x0,%ecx
  800767:	8d 40 04             	lea    0x4(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800772:	eb 9f                	jmp    800713 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800787:	eb 8a                	jmp    800713 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 10                	mov    (%eax),%edx
  80078e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800793:	8d 40 04             	lea    0x4(%eax),%eax
  800796:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800799:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80079e:	e9 70 ff ff ff       	jmp    800713 <vprintfmt+0x38c>
			putch(ch, putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 25                	push   $0x25
  8007a9:	ff d6                	call   *%esi
			break;
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	e9 7a ff ff ff       	jmp    80072d <vprintfmt+0x3a6>
			putch('%', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	6a 25                	push   $0x25
  8007b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	89 f8                	mov    %edi,%eax
  8007c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007c4:	74 05                	je     8007cb <vprintfmt+0x444>
  8007c6:	83 e8 01             	sub    $0x1,%eax
  8007c9:	eb f5                	jmp    8007c0 <vprintfmt+0x439>
  8007cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ce:	e9 5a ff ff ff       	jmp    80072d <vprintfmt+0x3a6>
}
  8007d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5f                   	pop    %edi
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007db:	f3 0f 1e fb          	endbr32 
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 18             	sub    $0x18,%esp
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fc:	85 c0                	test   %eax,%eax
  8007fe:	74 26                	je     800826 <vsnprintf+0x4b>
  800800:	85 d2                	test   %edx,%edx
  800802:	7e 22                	jle    800826 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800804:	ff 75 14             	pushl  0x14(%ebp)
  800807:	ff 75 10             	pushl  0x10(%ebp)
  80080a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080d:	50                   	push   %eax
  80080e:	68 45 03 80 00       	push   $0x800345
  800813:	e8 6f fb ff ff       	call   800387 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800818:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800821:	83 c4 10             	add    $0x10,%esp
}
  800824:	c9                   	leave  
  800825:	c3                   	ret    
		return -E_INVAL;
  800826:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082b:	eb f7                	jmp    800824 <vsnprintf+0x49>

0080082d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082d:	f3 0f 1e fb          	endbr32 
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800837:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083a:	50                   	push   %eax
  80083b:	ff 75 10             	pushl  0x10(%ebp)
  80083e:	ff 75 0c             	pushl  0xc(%ebp)
  800841:	ff 75 08             	pushl  0x8(%ebp)
  800844:	e8 92 ff ff ff       	call   8007db <vsnprintf>
	va_end(ap);

	return rc;
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084b:	f3 0f 1e fb          	endbr32 
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085e:	74 05                	je     800865 <strlen+0x1a>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	eb f5                	jmp    80085a <strlen+0xf>
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800867:	f3 0f 1e fb          	endbr32 
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
  800879:	39 d0                	cmp    %edx,%eax
  80087b:	74 0d                	je     80088a <strnlen+0x23>
  80087d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800881:	74 05                	je     800888 <strnlen+0x21>
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	eb f1                	jmp    800879 <strnlen+0x12>
  800888:	89 c2                	mov    %eax,%edx
	return n;
}
  80088a:	89 d0                	mov    %edx,%eax
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088e:	f3 0f 1e fb          	endbr32 
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	75 f2                	jne    8008a1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008af:	89 c8                	mov    %ecx,%eax
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	83 ec 10             	sub    $0x10,%esp
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c2:	53                   	push   %ebx
  8008c3:	e8 83 ff ff ff       	call   80084b <strlen>
  8008c8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008cb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ce:	01 d8                	add    %ebx,%eax
  8008d0:	50                   	push   %eax
  8008d1:	e8 b8 ff ff ff       	call   80088e <strcpy>
	return dst;
}
  8008d6:	89 d8                	mov    %ebx,%eax
  8008d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008dd:	f3 0f 1e fb          	endbr32 
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 f3                	mov    %esi,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f1:	89 f0                	mov    %esi,%eax
  8008f3:	39 d8                	cmp    %ebx,%eax
  8008f5:	74 11                	je     800908 <strncpy+0x2b>
		*dst++ = *src;
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	0f b6 0a             	movzbl (%edx),%ecx
  8008fd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800900:	80 f9 01             	cmp    $0x1,%cl
  800903:	83 da ff             	sbb    $0xffffffff,%edx
  800906:	eb eb                	jmp    8008f3 <strncpy+0x16>
	}
	return ret;
}
  800908:	89 f0                	mov    %esi,%eax
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090e:	f3 0f 1e fb          	endbr32 
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091d:	8b 55 10             	mov    0x10(%ebp),%edx
  800920:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800922:	85 d2                	test   %edx,%edx
  800924:	74 21                	je     800947 <strlcpy+0x39>
  800926:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80092c:	39 c2                	cmp    %eax,%edx
  80092e:	74 14                	je     800944 <strlcpy+0x36>
  800930:	0f b6 19             	movzbl (%ecx),%ebx
  800933:	84 db                	test   %bl,%bl
  800935:	74 0b                	je     800942 <strlcpy+0x34>
			*dst++ = *src++;
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800940:	eb ea                	jmp    80092c <strlcpy+0x1e>
  800942:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800944:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800947:	29 f0                	sub    %esi,%eax
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094d:	f3 0f 1e fb          	endbr32 
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095a:	0f b6 01             	movzbl (%ecx),%eax
  80095d:	84 c0                	test   %al,%al
  80095f:	74 0c                	je     80096d <strcmp+0x20>
  800961:	3a 02                	cmp    (%edx),%al
  800963:	75 08                	jne    80096d <strcmp+0x20>
		p++, q++;
  800965:	83 c1 01             	add    $0x1,%ecx
  800968:	83 c2 01             	add    $0x1,%edx
  80096b:	eb ed                	jmp    80095a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096d:	0f b6 c0             	movzbl %al,%eax
  800970:	0f b6 12             	movzbl (%edx),%edx
  800973:	29 d0                	sub    %edx,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800977:	f3 0f 1e fb          	endbr32 
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 c3                	mov    %eax,%ebx
  800987:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098a:	eb 06                	jmp    800992 <strncmp+0x1b>
		n--, p++, q++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800992:	39 d8                	cmp    %ebx,%eax
  800994:	74 16                	je     8009ac <strncmp+0x35>
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	84 c9                	test   %cl,%cl
  80099b:	74 04                	je     8009a1 <strncmp+0x2a>
  80099d:	3a 0a                	cmp    (%edx),%cl
  80099f:	74 eb                	je     80098c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 00             	movzbl (%eax),%eax
  8009a4:	0f b6 12             	movzbl (%edx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
}
  8009a9:	5b                   	pop    %ebx
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    
		return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb f6                	jmp    8009a9 <strncmp+0x32>

008009b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b3:	f3 0f 1e fb          	endbr32 
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c1:	0f b6 10             	movzbl (%eax),%edx
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	74 09                	je     8009d1 <strchr+0x1e>
		if (*s == c)
  8009c8:	38 ca                	cmp    %cl,%dl
  8009ca:	74 0a                	je     8009d6 <strchr+0x23>
	for (; *s; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	eb f0                	jmp    8009c1 <strchr+0xe>
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8009d8:	f3 0f 1e fb          	endbr32 
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8009e2:	6a 78                	push   $0x78
  8009e4:	ff 75 08             	pushl  0x8(%ebp)
  8009e7:	e8 c7 ff ff ff       	call   8009b3 <strchr>
  8009ec:	83 c4 10             	add    $0x10,%esp
  8009ef:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8009f7:	eb 0d                	jmp    800a06 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8009f9:	c1 e0 04             	shl    $0x4,%eax
  8009fc:	0f be d2             	movsbl %dl,%edx
  8009ff:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800a03:	83 c1 01             	add    $0x1,%ecx
  800a06:	0f b6 11             	movzbl (%ecx),%edx
  800a09:	84 d2                	test   %dl,%dl
  800a0b:	74 11                	je     800a1e <atox+0x46>
		if (*p>='a'){
  800a0d:	80 fa 60             	cmp    $0x60,%dl
  800a10:	7e e7                	jle    8009f9 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800a12:	c1 e0 04             	shl    $0x4,%eax
  800a15:	0f be d2             	movsbl %dl,%edx
  800a18:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800a1c:	eb e5                	jmp    800a03 <atox+0x2b>
	}

	return v;

}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a20:	f3 0f 1e fb          	endbr32 
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 09                	je     800a3e <strfind+0x1e>
  800a35:	84 d2                	test   %dl,%dl
  800a37:	74 05                	je     800a3e <strfind+0x1e>
	for (; *s; s++)
  800a39:	83 c0 01             	add    $0x1,%eax
  800a3c:	eb f0                	jmp    800a2e <strfind+0xe>
			break;
	return (char *) s;
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a40:	f3 0f 1e fb          	endbr32 
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a50:	85 c9                	test   %ecx,%ecx
  800a52:	74 31                	je     800a85 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	09 c8                	or     %ecx,%eax
  800a58:	a8 03                	test   $0x3,%al
  800a5a:	75 23                	jne    800a7f <memset+0x3f>
		c &= 0xFF;
  800a5c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a60:	89 d3                	mov    %edx,%ebx
  800a62:	c1 e3 08             	shl    $0x8,%ebx
  800a65:	89 d0                	mov    %edx,%eax
  800a67:	c1 e0 18             	shl    $0x18,%eax
  800a6a:	89 d6                	mov    %edx,%esi
  800a6c:	c1 e6 10             	shl    $0x10,%esi
  800a6f:	09 f0                	or     %esi,%eax
  800a71:	09 c2                	or     %eax,%edx
  800a73:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a75:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a78:	89 d0                	mov    %edx,%eax
  800a7a:	fc                   	cld    
  800a7b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7d:	eb 06                	jmp    800a85 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a82:	fc                   	cld    
  800a83:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a85:	89 f8                	mov    %edi,%eax
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8c:	f3 0f 1e fb          	endbr32 
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a9e:	39 c6                	cmp    %eax,%esi
  800aa0:	73 32                	jae    800ad4 <memmove+0x48>
  800aa2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa5:	39 c2                	cmp    %eax,%edx
  800aa7:	76 2b                	jbe    800ad4 <memmove+0x48>
		s += n;
		d += n;
  800aa9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aac:	89 fe                	mov    %edi,%esi
  800aae:	09 ce                	or     %ecx,%esi
  800ab0:	09 d6                	or     %edx,%esi
  800ab2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab8:	75 0e                	jne    800ac8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aba:	83 ef 04             	sub    $0x4,%edi
  800abd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac3:	fd                   	std    
  800ac4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac6:	eb 09                	jmp    800ad1 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac8:	83 ef 01             	sub    $0x1,%edi
  800acb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ace:	fd                   	std    
  800acf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad1:	fc                   	cld    
  800ad2:	eb 1a                	jmp    800aee <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad4:	89 c2                	mov    %eax,%edx
  800ad6:	09 ca                	or     %ecx,%edx
  800ad8:	09 f2                	or     %esi,%edx
  800ada:	f6 c2 03             	test   $0x3,%dl
  800add:	75 0a                	jne    800ae9 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ae2:	89 c7                	mov    %eax,%edi
  800ae4:	fc                   	cld    
  800ae5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae7:	eb 05                	jmp    800aee <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ae9:	89 c7                	mov    %eax,%edi
  800aeb:	fc                   	cld    
  800aec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af2:	f3 0f 1e fb          	endbr32 
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800afc:	ff 75 10             	pushl  0x10(%ebp)
  800aff:	ff 75 0c             	pushl  0xc(%ebp)
  800b02:	ff 75 08             	pushl  0x8(%ebp)
  800b05:	e8 82 ff ff ff       	call   800a8c <memmove>
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0c:	f3 0f 1e fb          	endbr32 
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b20:	39 f0                	cmp    %esi,%eax
  800b22:	74 1c                	je     800b40 <memcmp+0x34>
		if (*s1 != *s2)
  800b24:	0f b6 08             	movzbl (%eax),%ecx
  800b27:	0f b6 1a             	movzbl (%edx),%ebx
  800b2a:	38 d9                	cmp    %bl,%cl
  800b2c:	75 08                	jne    800b36 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b2e:	83 c0 01             	add    $0x1,%eax
  800b31:	83 c2 01             	add    $0x1,%edx
  800b34:	eb ea                	jmp    800b20 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b36:	0f b6 c1             	movzbl %cl,%eax
  800b39:	0f b6 db             	movzbl %bl,%ebx
  800b3c:	29 d8                	sub    %ebx,%eax
  800b3e:	eb 05                	jmp    800b45 <memcmp+0x39>
	}

	return 0;
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b49:	f3 0f 1e fb          	endbr32 
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5b:	39 d0                	cmp    %edx,%eax
  800b5d:	73 09                	jae    800b68 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5f:	38 08                	cmp    %cl,(%eax)
  800b61:	74 05                	je     800b68 <memfind+0x1f>
	for (; s < ends; s++)
  800b63:	83 c0 01             	add    $0x1,%eax
  800b66:	eb f3                	jmp    800b5b <memfind+0x12>
			break;
	return (void *) s;
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6a:	f3 0f 1e fb          	endbr32 
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	eb 03                	jmp    800b7f <strtol+0x15>
		s++;
  800b7c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b7f:	0f b6 01             	movzbl (%ecx),%eax
  800b82:	3c 20                	cmp    $0x20,%al
  800b84:	74 f6                	je     800b7c <strtol+0x12>
  800b86:	3c 09                	cmp    $0x9,%al
  800b88:	74 f2                	je     800b7c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b8a:	3c 2b                	cmp    $0x2b,%al
  800b8c:	74 2a                	je     800bb8 <strtol+0x4e>
	int neg = 0;
  800b8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b93:	3c 2d                	cmp    $0x2d,%al
  800b95:	74 2b                	je     800bc2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9d:	75 0f                	jne    800bae <strtol+0x44>
  800b9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba2:	74 28                	je     800bcc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba4:	85 db                	test   %ebx,%ebx
  800ba6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bab:	0f 44 d8             	cmove  %eax,%ebx
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb6:	eb 46                	jmp    800bfe <strtol+0x94>
		s++;
  800bb8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc0:	eb d5                	jmp    800b97 <strtol+0x2d>
		s++, neg = 1;
  800bc2:	83 c1 01             	add    $0x1,%ecx
  800bc5:	bf 01 00 00 00       	mov    $0x1,%edi
  800bca:	eb cb                	jmp    800b97 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd0:	74 0e                	je     800be0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bd2:	85 db                	test   %ebx,%ebx
  800bd4:	75 d8                	jne    800bae <strtol+0x44>
		s++, base = 8;
  800bd6:	83 c1 01             	add    $0x1,%ecx
  800bd9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bde:	eb ce                	jmp    800bae <strtol+0x44>
		s += 2, base = 16;
  800be0:	83 c1 02             	add    $0x2,%ecx
  800be3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be8:	eb c4                	jmp    800bae <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bea:	0f be d2             	movsbl %dl,%edx
  800bed:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf3:	7d 3a                	jge    800c2f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bf5:	83 c1 01             	add    $0x1,%ecx
  800bf8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bfc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bfe:	0f b6 11             	movzbl (%ecx),%edx
  800c01:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c04:	89 f3                	mov    %esi,%ebx
  800c06:	80 fb 09             	cmp    $0x9,%bl
  800c09:	76 df                	jbe    800bea <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0e:	89 f3                	mov    %esi,%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c15:	0f be d2             	movsbl %dl,%edx
  800c18:	83 ea 57             	sub    $0x57,%edx
  800c1b:	eb d3                	jmp    800bf0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c20:	89 f3                	mov    %esi,%ebx
  800c22:	80 fb 19             	cmp    $0x19,%bl
  800c25:	77 08                	ja     800c2f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c27:	0f be d2             	movsbl %dl,%edx
  800c2a:	83 ea 37             	sub    $0x37,%edx
  800c2d:	eb c1                	jmp    800bf0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c33:	74 05                	je     800c3a <strtol+0xd0>
		*endptr = (char *) s;
  800c35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c38:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c3a:	89 c2                	mov    %eax,%edx
  800c3c:	f7 da                	neg    %edx
  800c3e:	85 ff                	test   %edi,%edi
  800c40:	0f 45 c2             	cmovne %edx,%eax
}
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c48:	f3 0f 1e fb          	endbr32 
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c52:	b8 00 00 00 00       	mov    $0x0,%eax
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	89 c3                	mov    %eax,%ebx
  800c5f:	89 c7                	mov    %eax,%edi
  800c61:	89 c6                	mov    %eax,%esi
  800c63:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6a:	f3 0f 1e fb          	endbr32 
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c8d:	f3 0f 1e fb          	endbr32 
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca4:	89 cb                	mov    %ecx,%ebx
  800ca6:	89 cf                	mov    %ecx,%edi
  800ca8:	89 ce                	mov    %ecx,%esi
  800caa:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb1:	f3 0f 1e fb          	endbr32 
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	89 d3                	mov    %edx,%ebx
  800cc9:	89 d7                	mov    %edx,%edi
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_yield>:

void
sys_yield(void)
{
  800cd4:	f3 0f 1e fb          	endbr32 
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf7:	f3 0f 1e fb          	endbr32 
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d01:	be 00 00 00 00       	mov    $0x0,%esi
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	89 f7                	mov    %esi,%edi
  800d16:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d1d:	f3 0f 1e fb          	endbr32 
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d38:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3b:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d42:	f3 0f 1e fb          	endbr32 
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d67:	f3 0f 1e fb          	endbr32 
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d81:	89 df                	mov    %ebx,%edi
  800d83:	89 de                	mov    %ebx,%esi
  800d85:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8c:	f3 0f 1e fb          	endbr32 
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 09 00 00 00       	mov    $0x9,%eax
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db1:	f3 0f 1e fb          	endbr32 
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dcb:	89 df                	mov    %ebx,%edi
  800dcd:	89 de                	mov    %ebx,%esi
  800dcf:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd6:	f3 0f 1e fb          	endbr32 
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800deb:	be 00 00 00 00       	mov    $0x0,%esi
  800df0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfd:	f3 0f 1e fb          	endbr32 
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e14:	89 cb                	mov    %ecx,%ebx
  800e16:	89 cf                	mov    %ecx,%edi
  800e18:	89 ce                	mov    %ecx,%esi
  800e1a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e21:	f3 0f 1e fb          	endbr32 
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800e44:	f3 0f 1e fb          	endbr32 
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e5e:	89 df                	mov    %ebx,%edi
  800e60:	89 de                	mov    %ebx,%esi
  800e62:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e69:	f3 0f 1e fb          	endbr32 
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	57                   	push   %edi
  800e71:	56                   	push   %esi
  800e72:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8e:	f3 0f 1e fb          	endbr32 
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9d:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea2:	f3 0f 1e fb          	endbr32 
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eac:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ebd:	f3 0f 1e fb          	endbr32 
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	c1 ea 16             	shr    $0x16,%edx
  800ece:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed5:	f6 c2 01             	test   $0x1,%dl
  800ed8:	74 2d                	je     800f07 <fd_alloc+0x4a>
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	c1 ea 0c             	shr    $0xc,%edx
  800edf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee6:	f6 c2 01             	test   $0x1,%dl
  800ee9:	74 1c                	je     800f07 <fd_alloc+0x4a>
  800eeb:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ef0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef5:	75 d2                	jne    800ec9 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f00:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f05:	eb 0a                	jmp    800f11 <fd_alloc+0x54>
			*fd_store = fd;
  800f07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f13:	f3 0f 1e fb          	endbr32 
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f1d:	83 f8 1f             	cmp    $0x1f,%eax
  800f20:	77 30                	ja     800f52 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f22:	c1 e0 0c             	shl    $0xc,%eax
  800f25:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f30:	f6 c2 01             	test   $0x1,%dl
  800f33:	74 24                	je     800f59 <fd_lookup+0x46>
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	c1 ea 0c             	shr    $0xc,%edx
  800f3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f41:	f6 c2 01             	test   $0x1,%dl
  800f44:	74 1a                	je     800f60 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f49:	89 02                	mov    %eax,(%edx)
	return 0;
  800f4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
		return -E_INVAL;
  800f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f57:	eb f7                	jmp    800f50 <fd_lookup+0x3d>
		return -E_INVAL;
  800f59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5e:	eb f0                	jmp    800f50 <fd_lookup+0x3d>
  800f60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f65:	eb e9                	jmp    800f50 <fd_lookup+0x3d>

00800f67 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f67:	f3 0f 1e fb          	endbr32 
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f7e:	39 08                	cmp    %ecx,(%eax)
  800f80:	74 38                	je     800fba <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f82:	83 c2 01             	add    $0x1,%edx
  800f85:	8b 04 95 5c 29 80 00 	mov    0x80295c(,%edx,4),%eax
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	75 ee                	jne    800f7e <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f90:	a1 20 60 80 00       	mov    0x806020,%eax
  800f95:	8b 40 48             	mov    0x48(%eax),%eax
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	51                   	push   %ecx
  800f9c:	50                   	push   %eax
  800f9d:	68 e0 28 80 00       	push   $0x8028e0
  800fa2:	e8 dd f2 ff ff       	call   800284 <cprintf>
	*dev = 0;
  800fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800faa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    
			*dev = devtab[i];
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc4:	eb f2                	jmp    800fb8 <dev_lookup+0x51>

00800fc6 <fd_close>:
{
  800fc6:	f3 0f 1e fb          	endbr32 
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 24             	sub    $0x24,%esp
  800fd3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdc:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fdd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe6:	50                   	push   %eax
  800fe7:	e8 27 ff ff ff       	call   800f13 <fd_lookup>
  800fec:	89 c3                	mov    %eax,%ebx
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 05                	js     800ffa <fd_close+0x34>
	    || fd != fd2)
  800ff5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ff8:	74 16                	je     801010 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800ffa:	89 f8                	mov    %edi,%eax
  800ffc:	84 c0                	test   %al,%al
  800ffe:	b8 00 00 00 00       	mov    $0x0,%eax
  801003:	0f 44 d8             	cmove  %eax,%ebx
}
  801006:	89 d8                	mov    %ebx,%eax
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801016:	50                   	push   %eax
  801017:	ff 36                	pushl  (%esi)
  801019:	e8 49 ff ff ff       	call   800f67 <dev_lookup>
  80101e:	89 c3                	mov    %eax,%ebx
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	78 1a                	js     801041 <fd_close+0x7b>
		if (dev->dev_close)
  801027:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801032:	85 c0                	test   %eax,%eax
  801034:	74 0b                	je     801041 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	56                   	push   %esi
  80103a:	ff d0                	call   *%eax
  80103c:	89 c3                	mov    %eax,%ebx
  80103e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	56                   	push   %esi
  801045:	6a 00                	push   $0x0
  801047:	e8 f6 fc ff ff       	call   800d42 <sys_page_unmap>
	return r;
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	eb b5                	jmp    801006 <fd_close+0x40>

00801051 <close>:

int
close(int fdnum)
{
  801051:	f3 0f 1e fb          	endbr32 
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105e:	50                   	push   %eax
  80105f:	ff 75 08             	pushl  0x8(%ebp)
  801062:	e8 ac fe ff ff       	call   800f13 <fd_lookup>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	79 02                	jns    801070 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    
		return fd_close(fd, 1);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	6a 01                	push   $0x1
  801075:	ff 75 f4             	pushl  -0xc(%ebp)
  801078:	e8 49 ff ff ff       	call   800fc6 <fd_close>
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	eb ec                	jmp    80106e <close+0x1d>

00801082 <close_all>:

void
close_all(void)
{
  801082:	f3 0f 1e fb          	endbr32 
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	53                   	push   %ebx
  80108a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80108d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	53                   	push   %ebx
  801096:	e8 b6 ff ff ff       	call   801051 <close>
	for (i = 0; i < MAXFD; i++)
  80109b:	83 c3 01             	add    $0x1,%ebx
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	83 fb 20             	cmp    $0x20,%ebx
  8010a4:	75 ec                	jne    801092 <close_all+0x10>
}
  8010a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ab:	f3 0f 1e fb          	endbr32 
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	57                   	push   %edi
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010bb:	50                   	push   %eax
  8010bc:	ff 75 08             	pushl  0x8(%ebp)
  8010bf:	e8 4f fe ff ff       	call   800f13 <fd_lookup>
  8010c4:	89 c3                	mov    %eax,%ebx
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	0f 88 81 00 00 00    	js     801152 <dup+0xa7>
		return r;
	close(newfdnum);
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	ff 75 0c             	pushl  0xc(%ebp)
  8010d7:	e8 75 ff ff ff       	call   801051 <close>

	newfd = INDEX2FD(newfdnum);
  8010dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010df:	c1 e6 0c             	shl    $0xc,%esi
  8010e2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010e8:	83 c4 04             	add    $0x4,%esp
  8010eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ee:	e8 af fd ff ff       	call   800ea2 <fd2data>
  8010f3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010f5:	89 34 24             	mov    %esi,(%esp)
  8010f8:	e8 a5 fd ff ff       	call   800ea2 <fd2data>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801102:	89 d8                	mov    %ebx,%eax
  801104:	c1 e8 16             	shr    $0x16,%eax
  801107:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110e:	a8 01                	test   $0x1,%al
  801110:	74 11                	je     801123 <dup+0x78>
  801112:	89 d8                	mov    %ebx,%eax
  801114:	c1 e8 0c             	shr    $0xc,%eax
  801117:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111e:	f6 c2 01             	test   $0x1,%dl
  801121:	75 39                	jne    80115c <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801123:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801126:	89 d0                	mov    %edx,%eax
  801128:	c1 e8 0c             	shr    $0xc,%eax
  80112b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801132:	83 ec 0c             	sub    $0xc,%esp
  801135:	25 07 0e 00 00       	and    $0xe07,%eax
  80113a:	50                   	push   %eax
  80113b:	56                   	push   %esi
  80113c:	6a 00                	push   $0x0
  80113e:	52                   	push   %edx
  80113f:	6a 00                	push   $0x0
  801141:	e8 d7 fb ff ff       	call   800d1d <sys_page_map>
  801146:	89 c3                	mov    %eax,%ebx
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	78 31                	js     801180 <dup+0xd5>
		goto err;

	return newfdnum;
  80114f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801152:	89 d8                	mov    %ebx,%eax
  801154:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80115c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	25 07 0e 00 00       	and    $0xe07,%eax
  80116b:	50                   	push   %eax
  80116c:	57                   	push   %edi
  80116d:	6a 00                	push   $0x0
  80116f:	53                   	push   %ebx
  801170:	6a 00                	push   $0x0
  801172:	e8 a6 fb ff ff       	call   800d1d <sys_page_map>
  801177:	89 c3                	mov    %eax,%ebx
  801179:	83 c4 20             	add    $0x20,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 a3                	jns    801123 <dup+0x78>
	sys_page_unmap(0, newfd);
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	56                   	push   %esi
  801184:	6a 00                	push   $0x0
  801186:	e8 b7 fb ff ff       	call   800d42 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118b:	83 c4 08             	add    $0x8,%esp
  80118e:	57                   	push   %edi
  80118f:	6a 00                	push   $0x0
  801191:	e8 ac fb ff ff       	call   800d42 <sys_page_unmap>
	return r;
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	eb b7                	jmp    801152 <dup+0xa7>

0080119b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80119b:	f3 0f 1e fb          	endbr32 
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 1c             	sub    $0x1c,%esp
  8011a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	53                   	push   %ebx
  8011ae:	e8 60 fd ff ff       	call   800f13 <fd_lookup>
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 3f                	js     8011f9 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	ff 30                	pushl  (%eax)
  8011c6:	e8 9c fd ff ff       	call   800f67 <dev_lookup>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 27                	js     8011f9 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d5:	8b 42 08             	mov    0x8(%edx),%eax
  8011d8:	83 e0 03             	and    $0x3,%eax
  8011db:	83 f8 01             	cmp    $0x1,%eax
  8011de:	74 1e                	je     8011fe <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e3:	8b 40 08             	mov    0x8(%eax),%eax
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	74 35                	je     80121f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	ff 75 10             	pushl  0x10(%ebp)
  8011f0:	ff 75 0c             	pushl  0xc(%ebp)
  8011f3:	52                   	push   %edx
  8011f4:	ff d0                	call   *%eax
  8011f6:	83 c4 10             	add    $0x10,%esp
}
  8011f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fc:	c9                   	leave  
  8011fd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011fe:	a1 20 60 80 00       	mov    0x806020,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	53                   	push   %ebx
  80120a:	50                   	push   %eax
  80120b:	68 21 29 80 00       	push   $0x802921
  801210:	e8 6f f0 ff ff       	call   800284 <cprintf>
		return -E_INVAL;
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121d:	eb da                	jmp    8011f9 <read+0x5e>
		return -E_NOT_SUPP;
  80121f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801224:	eb d3                	jmp    8011f9 <read+0x5e>

00801226 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801226:	f3 0f 1e fb          	endbr32 
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	57                   	push   %edi
  80122e:	56                   	push   %esi
  80122f:	53                   	push   %ebx
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	8b 7d 08             	mov    0x8(%ebp),%edi
  801236:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123e:	eb 02                	jmp    801242 <readn+0x1c>
  801240:	01 c3                	add    %eax,%ebx
  801242:	39 f3                	cmp    %esi,%ebx
  801244:	73 21                	jae    801267 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	89 f0                	mov    %esi,%eax
  80124b:	29 d8                	sub    %ebx,%eax
  80124d:	50                   	push   %eax
  80124e:	89 d8                	mov    %ebx,%eax
  801250:	03 45 0c             	add    0xc(%ebp),%eax
  801253:	50                   	push   %eax
  801254:	57                   	push   %edi
  801255:	e8 41 ff ff ff       	call   80119b <read>
		if (m < 0)
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 04                	js     801265 <readn+0x3f>
			return m;
		if (m == 0)
  801261:	75 dd                	jne    801240 <readn+0x1a>
  801263:	eb 02                	jmp    801267 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801265:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801267:	89 d8                	mov    %ebx,%eax
  801269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801271:	f3 0f 1e fb          	endbr32 
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 1c             	sub    $0x1c,%esp
  80127c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	53                   	push   %ebx
  801284:	e8 8a fc ff ff       	call   800f13 <fd_lookup>
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 3a                	js     8012ca <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	ff 30                	pushl  (%eax)
  80129c:	e8 c6 fc ff ff       	call   800f67 <dev_lookup>
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 22                	js     8012ca <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012af:	74 1e                	je     8012cf <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8012b7:	85 d2                	test   %edx,%edx
  8012b9:	74 35                	je     8012f0 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	ff 75 10             	pushl  0x10(%ebp)
  8012c1:	ff 75 0c             	pushl  0xc(%ebp)
  8012c4:	50                   	push   %eax
  8012c5:	ff d2                	call   *%edx
  8012c7:	83 c4 10             	add    $0x10,%esp
}
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012cf:	a1 20 60 80 00       	mov    0x806020,%eax
  8012d4:	8b 40 48             	mov    0x48(%eax),%eax
  8012d7:	83 ec 04             	sub    $0x4,%esp
  8012da:	53                   	push   %ebx
  8012db:	50                   	push   %eax
  8012dc:	68 3d 29 80 00       	push   $0x80293d
  8012e1:	e8 9e ef ff ff       	call   800284 <cprintf>
		return -E_INVAL;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ee:	eb da                	jmp    8012ca <write+0x59>
		return -E_NOT_SUPP;
  8012f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f5:	eb d3                	jmp    8012ca <write+0x59>

008012f7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f7:	f3 0f 1e fb          	endbr32 
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	ff 75 08             	pushl  0x8(%ebp)
  801308:	e8 06 fc ff ff       	call   800f13 <fd_lookup>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	78 0e                	js     801322 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801322:	c9                   	leave  
  801323:	c3                   	ret    

00801324 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801324:	f3 0f 1e fb          	endbr32 
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	53                   	push   %ebx
  80132c:	83 ec 1c             	sub    $0x1c,%esp
  80132f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801332:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	53                   	push   %ebx
  801337:	e8 d7 fb ff ff       	call   800f13 <fd_lookup>
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 37                	js     80137a <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801349:	50                   	push   %eax
  80134a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134d:	ff 30                	pushl  (%eax)
  80134f:	e8 13 fc ff ff       	call   800f67 <dev_lookup>
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 1f                	js     80137a <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801362:	74 1b                	je     80137f <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801364:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801367:	8b 52 18             	mov    0x18(%edx),%edx
  80136a:	85 d2                	test   %edx,%edx
  80136c:	74 32                	je     8013a0 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	ff 75 0c             	pushl  0xc(%ebp)
  801374:	50                   	push   %eax
  801375:	ff d2                	call   *%edx
  801377:	83 c4 10             	add    $0x10,%esp
}
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80137f:	a1 20 60 80 00       	mov    0x806020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801384:	8b 40 48             	mov    0x48(%eax),%eax
  801387:	83 ec 04             	sub    $0x4,%esp
  80138a:	53                   	push   %ebx
  80138b:	50                   	push   %eax
  80138c:	68 00 29 80 00       	push   $0x802900
  801391:	e8 ee ee ff ff       	call   800284 <cprintf>
		return -E_INVAL;
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139e:	eb da                	jmp    80137a <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a5:	eb d3                	jmp    80137a <ftruncate+0x56>

008013a7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a7:	f3 0f 1e fb          	endbr32 
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 1c             	sub    $0x1c,%esp
  8013b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	ff 75 08             	pushl  0x8(%ebp)
  8013bc:	e8 52 fb ff ff       	call   800f13 <fd_lookup>
  8013c1:	83 c4 10             	add    $0x10,%esp
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 4b                	js     801413 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d2:	ff 30                	pushl  (%eax)
  8013d4:	e8 8e fb ff ff       	call   800f67 <dev_lookup>
  8013d9:	83 c4 10             	add    $0x10,%esp
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 33                	js     801413 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8013e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e7:	74 2f                	je     801418 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f3:	00 00 00 
	stat->st_isdir = 0;
  8013f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013fd:	00 00 00 
	stat->st_dev = dev;
  801400:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	53                   	push   %ebx
  80140a:	ff 75 f0             	pushl  -0x10(%ebp)
  80140d:	ff 50 14             	call   *0x14(%eax)
  801410:	83 c4 10             	add    $0x10,%esp
}
  801413:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801416:	c9                   	leave  
  801417:	c3                   	ret    
		return -E_NOT_SUPP;
  801418:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80141d:	eb f4                	jmp    801413 <fstat+0x6c>

0080141f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141f:	f3 0f 1e fb          	endbr32 
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	6a 00                	push   $0x0
  80142d:	ff 75 08             	pushl  0x8(%ebp)
  801430:	e8 01 02 00 00       	call   801636 <open>
  801435:	89 c3                	mov    %eax,%ebx
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 1b                	js     801459 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	ff 75 0c             	pushl  0xc(%ebp)
  801444:	50                   	push   %eax
  801445:	e8 5d ff ff ff       	call   8013a7 <fstat>
  80144a:	89 c6                	mov    %eax,%esi
	close(fd);
  80144c:	89 1c 24             	mov    %ebx,(%esp)
  80144f:	e8 fd fb ff ff       	call   801051 <close>
	return r;
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	89 f3                	mov    %esi,%ebx
}
  801459:	89 d8                	mov    %ebx,%eax
  80145b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145e:	5b                   	pop    %ebx
  80145f:	5e                   	pop    %esi
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	56                   	push   %esi
  801466:	53                   	push   %ebx
  801467:	89 c6                	mov    %eax,%esi
  801469:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80146b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801472:	74 27                	je     80149b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801474:	6a 07                	push   $0x7
  801476:	68 00 70 80 00       	push   $0x807000
  80147b:	56                   	push   %esi
  80147c:	ff 35 00 40 80 00    	pushl  0x804000
  801482:	e8 a0 0d 00 00       	call   802227 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801487:	83 c4 0c             	add    $0xc,%esp
  80148a:	6a 00                	push   $0x0
  80148c:	53                   	push   %ebx
  80148d:	6a 00                	push   $0x0
  80148f:	e8 26 0d 00 00       	call   8021ba <ipc_recv>
}
  801494:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801497:	5b                   	pop    %ebx
  801498:	5e                   	pop    %esi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80149b:	83 ec 0c             	sub    $0xc,%esp
  80149e:	6a 01                	push   $0x1
  8014a0:	e8 da 0d 00 00       	call   80227f <ipc_find_env>
  8014a5:	a3 00 40 80 00       	mov    %eax,0x804000
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	eb c5                	jmp    801474 <fsipc+0x12>

008014af <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014af:	f3 0f 1e fb          	endbr32 
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bf:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8014c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c7:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d1:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d6:	e8 87 ff ff ff       	call   801462 <fsipc>
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <devfile_flush>:
{
  8014dd:	f3 0f 1e fb          	endbr32 
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ed:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8014fc:	e8 61 ff ff ff       	call   801462 <fsipc>
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <devfile_stat>:
{
  801503:	f3 0f 1e fb          	endbr32 
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 04             	sub    $0x4,%esp
  80150e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	8b 40 0c             	mov    0xc(%eax),%eax
  801517:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151c:	ba 00 00 00 00       	mov    $0x0,%edx
  801521:	b8 05 00 00 00       	mov    $0x5,%eax
  801526:	e8 37 ff ff ff       	call   801462 <fsipc>
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 2c                	js     80155b <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	68 00 70 80 00       	push   $0x807000
  801537:	53                   	push   %ebx
  801538:	e8 51 f3 ff ff       	call   80088e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153d:	a1 80 70 80 00       	mov    0x807080,%eax
  801542:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801548:	a1 84 70 80 00       	mov    0x807084,%eax
  80154d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <devfile_write>:
{
  801560:	f3 0f 1e fb          	endbr32 
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	8b 45 10             	mov    0x10(%ebp),%eax
  80156d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801572:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801577:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80157a:	8b 55 08             	mov    0x8(%ebp),%edx
  80157d:	8b 52 0c             	mov    0xc(%edx),%edx
  801580:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  801586:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80158b:	50                   	push   %eax
  80158c:	ff 75 0c             	pushl  0xc(%ebp)
  80158f:	68 08 70 80 00       	push   $0x807008
  801594:	e8 f3 f4 ff ff       	call   800a8c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801599:	ba 00 00 00 00       	mov    $0x0,%edx
  80159e:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a3:	e8 ba fe ff ff       	call   801462 <fsipc>
}
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <devfile_read>:
{
  8015aa:	f3 0f 1e fb          	endbr32 
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	56                   	push   %esi
  8015b2:	53                   	push   %ebx
  8015b3:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015bc:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8015c1:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d1:	e8 8c fe ff ff       	call   801462 <fsipc>
  8015d6:	89 c3                	mov    %eax,%ebx
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 1f                	js     8015fb <devfile_read+0x51>
	assert(r <= n);
  8015dc:	39 f0                	cmp    %esi,%eax
  8015de:	77 24                	ja     801604 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e5:	7f 36                	jg     80161d <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	50                   	push   %eax
  8015eb:	68 00 70 80 00       	push   $0x807000
  8015f0:	ff 75 0c             	pushl  0xc(%ebp)
  8015f3:	e8 94 f4 ff ff       	call   800a8c <memmove>
	return r;
  8015f8:	83 c4 10             	add    $0x10,%esp
}
  8015fb:	89 d8                	mov    %ebx,%eax
  8015fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801600:	5b                   	pop    %ebx
  801601:	5e                   	pop    %esi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    
	assert(r <= n);
  801604:	68 70 29 80 00       	push   $0x802970
  801609:	68 77 29 80 00       	push   $0x802977
  80160e:	68 8c 00 00 00       	push   $0x8c
  801613:	68 8c 29 80 00       	push   $0x80298c
  801618:	e8 80 eb ff ff       	call   80019d <_panic>
	assert(r <= PGSIZE);
  80161d:	68 97 29 80 00       	push   $0x802997
  801622:	68 77 29 80 00       	push   $0x802977
  801627:	68 8d 00 00 00       	push   $0x8d
  80162c:	68 8c 29 80 00       	push   $0x80298c
  801631:	e8 67 eb ff ff       	call   80019d <_panic>

00801636 <open>:
{
  801636:	f3 0f 1e fb          	endbr32 
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	56                   	push   %esi
  80163e:	53                   	push   %ebx
  80163f:	83 ec 1c             	sub    $0x1c,%esp
  801642:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801645:	56                   	push   %esi
  801646:	e8 00 f2 ff ff       	call   80084b <strlen>
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801653:	7f 6c                	jg     8016c1 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801655:	83 ec 0c             	sub    $0xc,%esp
  801658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	e8 5c f8 ff ff       	call   800ebd <fd_alloc>
  801661:	89 c3                	mov    %eax,%ebx
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	78 3c                	js     8016a6 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	56                   	push   %esi
  80166e:	68 00 70 80 00       	push   $0x807000
  801673:	e8 16 f2 ff ff       	call   80088e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801678:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167b:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801680:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801683:	b8 01 00 00 00       	mov    $0x1,%eax
  801688:	e8 d5 fd ff ff       	call   801462 <fsipc>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 19                	js     8016af <open+0x79>
	return fd2num(fd);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	ff 75 f4             	pushl  -0xc(%ebp)
  80169c:	e8 ed f7 ff ff       	call   800e8e <fd2num>
  8016a1:	89 c3                	mov    %eax,%ebx
  8016a3:	83 c4 10             	add    $0x10,%esp
}
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    
		fd_close(fd, 0);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	6a 00                	push   $0x0
  8016b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b7:	e8 0a f9 ff ff       	call   800fc6 <fd_close>
		return r;
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb e5                	jmp    8016a6 <open+0x70>
		return -E_BAD_PATH;
  8016c1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016c6:	eb de                	jmp    8016a6 <open+0x70>

008016c8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016c8:	f3 0f 1e fb          	endbr32 
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8016dc:	e8 81 fd ff ff       	call   801462 <fsipc>
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016e3:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8016e7:	7f 01                	jg     8016ea <writebuf+0x7>
  8016e9:	c3                   	ret    
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8016f3:	ff 70 04             	pushl  0x4(%eax)
  8016f6:	8d 40 10             	lea    0x10(%eax),%eax
  8016f9:	50                   	push   %eax
  8016fa:	ff 33                	pushl  (%ebx)
  8016fc:	e8 70 fb ff ff       	call   801271 <write>
		if (result > 0)
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	85 c0                	test   %eax,%eax
  801706:	7e 03                	jle    80170b <writebuf+0x28>
			b->result += result;
  801708:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80170b:	39 43 04             	cmp    %eax,0x4(%ebx)
  80170e:	74 0d                	je     80171d <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801710:	85 c0                	test   %eax,%eax
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	0f 4f c2             	cmovg  %edx,%eax
  80171a:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <putch>:

static void
putch(int ch, void *thunk)
{
  801722:	f3 0f 1e fb          	endbr32 
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	53                   	push   %ebx
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801730:	8b 53 04             	mov    0x4(%ebx),%edx
  801733:	8d 42 01             	lea    0x1(%edx),%eax
  801736:	89 43 04             	mov    %eax,0x4(%ebx)
  801739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80173c:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801740:	3d 00 01 00 00       	cmp    $0x100,%eax
  801745:	74 06                	je     80174d <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  801747:	83 c4 04             	add    $0x4,%esp
  80174a:	5b                   	pop    %ebx
  80174b:	5d                   	pop    %ebp
  80174c:	c3                   	ret    
		writebuf(b);
  80174d:	89 d8                	mov    %ebx,%eax
  80174f:	e8 8f ff ff ff       	call   8016e3 <writebuf>
		b->idx = 0;
  801754:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80175b:	eb ea                	jmp    801747 <putch+0x25>

0080175d <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80175d:	f3 0f 1e fb          	endbr32 
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801773:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80177a:	00 00 00 
	b.result = 0;
  80177d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801784:	00 00 00 
	b.error = 1;
  801787:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80178e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801791:	ff 75 10             	pushl  0x10(%ebp)
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80179d:	50                   	push   %eax
  80179e:	68 22 17 80 00       	push   $0x801722
  8017a3:	e8 df eb ff ff       	call   800387 <vprintfmt>
	if (b.idx > 0)
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017b2:	7f 11                	jg     8017c5 <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8017b4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    
		writebuf(&b);
  8017c5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017cb:	e8 13 ff ff ff       	call   8016e3 <writebuf>
  8017d0:	eb e2                	jmp    8017b4 <vfprintf+0x57>

008017d2 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017d2:	f3 0f 1e fb          	endbr32 
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017dc:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017df:	50                   	push   %eax
  8017e0:	ff 75 0c             	pushl  0xc(%ebp)
  8017e3:	ff 75 08             	pushl  0x8(%ebp)
  8017e6:	e8 72 ff ff ff       	call   80175d <vfprintf>
	va_end(ap);

	return cnt;
}
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <printf>:

int
printf(const char *fmt, ...)
{
  8017ed:	f3 0f 1e fb          	endbr32 
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8017fa:	50                   	push   %eax
  8017fb:	ff 75 08             	pushl  0x8(%ebp)
  8017fe:	6a 01                	push   $0x1
  801800:	e8 58 ff ff ff       	call   80175d <vfprintf>
	va_end(ap);

	return cnt;
}
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801807:	f3 0f 1e fb          	endbr32 
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801811:	68 03 2a 80 00       	push   $0x802a03
  801816:	ff 75 0c             	pushl  0xc(%ebp)
  801819:	e8 70 f0 ff ff       	call   80088e <strcpy>
	return 0;
}
  80181e:	b8 00 00 00 00       	mov    $0x0,%eax
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <devsock_close>:
{
  801825:	f3 0f 1e fb          	endbr32 
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	53                   	push   %ebx
  80182d:	83 ec 10             	sub    $0x10,%esp
  801830:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801833:	53                   	push   %ebx
  801834:	e8 83 0a 00 00       	call   8022bc <pageref>
  801839:	89 c2                	mov    %eax,%edx
  80183b:	83 c4 10             	add    $0x10,%esp
		return 0;
  80183e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801843:	83 fa 01             	cmp    $0x1,%edx
  801846:	74 05                	je     80184d <devsock_close+0x28>
}
  801848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	ff 73 0c             	pushl  0xc(%ebx)
  801853:	e8 e3 02 00 00       	call   801b3b <nsipc_close>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	eb eb                	jmp    801848 <devsock_close+0x23>

0080185d <devsock_write>:
{
  80185d:	f3 0f 1e fb          	endbr32 
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801867:	6a 00                	push   $0x0
  801869:	ff 75 10             	pushl  0x10(%ebp)
  80186c:	ff 75 0c             	pushl  0xc(%ebp)
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	ff 70 0c             	pushl  0xc(%eax)
  801875:	e8 b5 03 00 00       	call   801c2f <nsipc_send>
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devsock_read>:
{
  80187c:	f3 0f 1e fb          	endbr32 
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801886:	6a 00                	push   $0x0
  801888:	ff 75 10             	pushl  0x10(%ebp)
  80188b:	ff 75 0c             	pushl  0xc(%ebp)
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	ff 70 0c             	pushl  0xc(%eax)
  801894:	e8 1f 03 00 00       	call   801bb8 <nsipc_recv>
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <fd2sockid>:
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018a1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018a4:	52                   	push   %edx
  8018a5:	50                   	push   %eax
  8018a6:	e8 68 f6 ff ff       	call   800f13 <fd_lookup>
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 10                	js     8018c2 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  8018bb:	39 08                	cmp    %ecx,(%eax)
  8018bd:	75 05                	jne    8018c4 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8018bf:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    
		return -E_NOT_SUPP;
  8018c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018c9:	eb f7                	jmp    8018c2 <fd2sockid+0x27>

008018cb <alloc_sockfd>:
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	83 ec 1c             	sub    $0x1c,%esp
  8018d3:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8018d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d8:	50                   	push   %eax
  8018d9:	e8 df f5 ff ff       	call   800ebd <fd_alloc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 43                	js     80192a <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	68 07 04 00 00       	push   $0x407
  8018ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f2:	6a 00                	push   $0x0
  8018f4:	e8 fe f3 ff ff       	call   800cf7 <sys_page_alloc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 28                	js     80192a <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801905:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80190b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80190d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801910:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801917:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	50                   	push   %eax
  80191e:	e8 6b f5 ff ff       	call   800e8e <fd2num>
  801923:	89 c3                	mov    %eax,%ebx
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	eb 0c                	jmp    801936 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	56                   	push   %esi
  80192e:	e8 08 02 00 00       	call   801b3b <nsipc_close>
		return r;
  801933:	83 c4 10             	add    $0x10,%esp
}
  801936:	89 d8                	mov    %ebx,%eax
  801938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5e                   	pop    %esi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <accept>:
{
  80193f:	f3 0f 1e fb          	endbr32 
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	e8 4a ff ff ff       	call   80189b <fd2sockid>
  801951:	85 c0                	test   %eax,%eax
  801953:	78 1b                	js     801970 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	ff 75 10             	pushl  0x10(%ebp)
  80195b:	ff 75 0c             	pushl  0xc(%ebp)
  80195e:	50                   	push   %eax
  80195f:	e8 22 01 00 00       	call   801a86 <nsipc_accept>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	85 c0                	test   %eax,%eax
  801969:	78 05                	js     801970 <accept+0x31>
	return alloc_sockfd(r);
  80196b:	e8 5b ff ff ff       	call   8018cb <alloc_sockfd>
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <bind>:
{
  801972:	f3 0f 1e fb          	endbr32 
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	e8 17 ff ff ff       	call   80189b <fd2sockid>
  801984:	85 c0                	test   %eax,%eax
  801986:	78 12                	js     80199a <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801988:	83 ec 04             	sub    $0x4,%esp
  80198b:	ff 75 10             	pushl  0x10(%ebp)
  80198e:	ff 75 0c             	pushl  0xc(%ebp)
  801991:	50                   	push   %eax
  801992:	e8 45 01 00 00       	call   801adc <nsipc_bind>
  801997:	83 c4 10             	add    $0x10,%esp
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <shutdown>:
{
  80199c:	f3 0f 1e fb          	endbr32 
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	e8 ed fe ff ff       	call   80189b <fd2sockid>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 0f                	js     8019c1 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  8019b2:	83 ec 08             	sub    $0x8,%esp
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	50                   	push   %eax
  8019b9:	e8 57 01 00 00       	call   801b15 <nsipc_shutdown>
  8019be:	83 c4 10             	add    $0x10,%esp
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <connect>:
{
  8019c3:	f3 0f 1e fb          	endbr32 
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d0:	e8 c6 fe ff ff       	call   80189b <fd2sockid>
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 12                	js     8019eb <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8019d9:	83 ec 04             	sub    $0x4,%esp
  8019dc:	ff 75 10             	pushl  0x10(%ebp)
  8019df:	ff 75 0c             	pushl  0xc(%ebp)
  8019e2:	50                   	push   %eax
  8019e3:	e8 71 01 00 00       	call   801b59 <nsipc_connect>
  8019e8:	83 c4 10             	add    $0x10,%esp
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <listen>:
{
  8019ed:	f3 0f 1e fb          	endbr32 
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	e8 9c fe ff ff       	call   80189b <fd2sockid>
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 0f                	js     801a12 <listen+0x25>
	return nsipc_listen(r, backlog);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	ff 75 0c             	pushl  0xc(%ebp)
  801a09:	50                   	push   %eax
  801a0a:	e8 83 01 00 00       	call   801b92 <nsipc_listen>
  801a0f:	83 c4 10             	add    $0x10,%esp
}
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a14:	f3 0f 1e fb          	endbr32 
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a1e:	ff 75 10             	pushl  0x10(%ebp)
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	ff 75 08             	pushl  0x8(%ebp)
  801a27:	e8 65 02 00 00       	call   801c91 <nsipc_socket>
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 05                	js     801a38 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801a33:	e8 93 fe ff ff       	call   8018cb <alloc_sockfd>
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	53                   	push   %ebx
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a43:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a4a:	74 26                	je     801a72 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a4c:	6a 07                	push   $0x7
  801a4e:	68 00 80 80 00       	push   $0x808000
  801a53:	53                   	push   %ebx
  801a54:	ff 35 04 40 80 00    	pushl  0x804004
  801a5a:	e8 c8 07 00 00       	call   802227 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a5f:	83 c4 0c             	add    $0xc,%esp
  801a62:	6a 00                	push   $0x0
  801a64:	6a 00                	push   $0x0
  801a66:	6a 00                	push   $0x0
  801a68:	e8 4d 07 00 00       	call   8021ba <ipc_recv>
}
  801a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	6a 02                	push   $0x2
  801a77:	e8 03 08 00 00       	call   80227f <ipc_find_env>
  801a7c:	a3 04 40 80 00       	mov    %eax,0x804004
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	eb c6                	jmp    801a4c <nsipc+0x12>

00801a86 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a86:	f3 0f 1e fb          	endbr32 
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a9a:	8b 06                	mov    (%esi),%eax
  801a9c:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa6:	e8 8f ff ff ff       	call   801a3a <nsipc>
  801aab:	89 c3                	mov    %eax,%ebx
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	79 09                	jns    801aba <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801ab1:	89 d8                	mov    %ebx,%eax
  801ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801aba:	83 ec 04             	sub    $0x4,%esp
  801abd:	ff 35 10 80 80 00    	pushl  0x808010
  801ac3:	68 00 80 80 00       	push   $0x808000
  801ac8:	ff 75 0c             	pushl  0xc(%ebp)
  801acb:	e8 bc ef ff ff       	call   800a8c <memmove>
		*addrlen = ret->ret_addrlen;
  801ad0:	a1 10 80 80 00       	mov    0x808010,%eax
  801ad5:	89 06                	mov    %eax,(%esi)
  801ad7:	83 c4 10             	add    $0x10,%esp
	return r;
  801ada:	eb d5                	jmp    801ab1 <nsipc_accept+0x2b>

00801adc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801adc:	f3 0f 1e fb          	endbr32 
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801af2:	53                   	push   %ebx
  801af3:	ff 75 0c             	pushl  0xc(%ebp)
  801af6:	68 04 80 80 00       	push   $0x808004
  801afb:	e8 8c ef ff ff       	call   800a8c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b00:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801b06:	b8 02 00 00 00       	mov    $0x2,%eax
  801b0b:	e8 2a ff ff ff       	call   801a3a <nsipc>
}
  801b10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b15:	f3 0f 1e fb          	endbr32 
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2a:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801b2f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b34:	e8 01 ff ff ff       	call   801a3a <nsipc>
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <nsipc_close>:

int
nsipc_close(int s)
{
  801b3b:	f3 0f 1e fb          	endbr32 
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801b4d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b52:	e8 e3 fe ff ff       	call   801a3a <nsipc>
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b59:	f3 0f 1e fb          	endbr32 
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	53                   	push   %ebx
  801b61:	83 ec 08             	sub    $0x8,%esp
  801b64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b6f:	53                   	push   %ebx
  801b70:	ff 75 0c             	pushl  0xc(%ebp)
  801b73:	68 04 80 80 00       	push   $0x808004
  801b78:	e8 0f ef ff ff       	call   800a8c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b7d:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801b83:	b8 05 00 00 00       	mov    $0x5,%eax
  801b88:	e8 ad fe ff ff       	call   801a3a <nsipc>
}
  801b8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b92:	f3 0f 1e fb          	endbr32 
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba7:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801bac:	b8 06 00 00 00       	mov    $0x6,%eax
  801bb1:	e8 84 fe ff ff       	call   801a3a <nsipc>
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bb8:	f3 0f 1e fb          	endbr32 
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801bcc:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801bd2:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd5:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bda:	b8 07 00 00 00       	mov    $0x7,%eax
  801bdf:	e8 56 fe ff ff       	call   801a3a <nsipc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 26                	js     801c10 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801bea:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801bf0:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801bf5:	0f 4e c6             	cmovle %esi,%eax
  801bf8:	39 c3                	cmp    %eax,%ebx
  801bfa:	7f 1d                	jg     801c19 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bfc:	83 ec 04             	sub    $0x4,%esp
  801bff:	53                   	push   %ebx
  801c00:	68 00 80 80 00       	push   $0x808000
  801c05:	ff 75 0c             	pushl  0xc(%ebp)
  801c08:	e8 7f ee ff ff       	call   800a8c <memmove>
  801c0d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c10:	89 d8                	mov    %ebx,%eax
  801c12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c15:	5b                   	pop    %ebx
  801c16:	5e                   	pop    %esi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c19:	68 0f 2a 80 00       	push   $0x802a0f
  801c1e:	68 77 29 80 00       	push   $0x802977
  801c23:	6a 62                	push   $0x62
  801c25:	68 24 2a 80 00       	push   $0x802a24
  801c2a:	e8 6e e5 ff ff       	call   80019d <_panic>

00801c2f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c2f:	f3 0f 1e fb          	endbr32 
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	83 ec 04             	sub    $0x4,%esp
  801c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801c45:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c4b:	7f 2e                	jg     801c7b <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c4d:	83 ec 04             	sub    $0x4,%esp
  801c50:	53                   	push   %ebx
  801c51:	ff 75 0c             	pushl  0xc(%ebp)
  801c54:	68 0c 80 80 00       	push   $0x80800c
  801c59:	e8 2e ee ff ff       	call   800a8c <memmove>
	nsipcbuf.send.req_size = size;
  801c5e:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801c64:	8b 45 14             	mov    0x14(%ebp),%eax
  801c67:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801c6c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c71:	e8 c4 fd ff ff       	call   801a3a <nsipc>
}
  801c76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    
	assert(size < 1600);
  801c7b:	68 30 2a 80 00       	push   $0x802a30
  801c80:	68 77 29 80 00       	push   $0x802977
  801c85:	6a 6d                	push   $0x6d
  801c87:	68 24 2a 80 00       	push   $0x802a24
  801c8c:	e8 0c e5 ff ff       	call   80019d <_panic>

00801c91 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c91:	f3 0f 1e fb          	endbr32 
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca6:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801cab:	8b 45 10             	mov    0x10(%ebp),%eax
  801cae:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801cb3:	b8 09 00 00 00       	mov    $0x9,%eax
  801cb8:	e8 7d fd ff ff       	call   801a3a <nsipc>
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cbf:	f3 0f 1e fb          	endbr32 
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	56                   	push   %esi
  801cc7:	53                   	push   %ebx
  801cc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	ff 75 08             	pushl  0x8(%ebp)
  801cd1:	e8 cc f1 ff ff       	call   800ea2 <fd2data>
  801cd6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cd8:	83 c4 08             	add    $0x8,%esp
  801cdb:	68 3c 2a 80 00       	push   $0x802a3c
  801ce0:	53                   	push   %ebx
  801ce1:	e8 a8 eb ff ff       	call   80088e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ce6:	8b 46 04             	mov    0x4(%esi),%eax
  801ce9:	2b 06                	sub    (%esi),%eax
  801ceb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cf1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cf8:	00 00 00 
	stat->st_dev = &devpipe;
  801cfb:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801d02:	30 80 00 
	return 0;
}
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d11:	f3 0f 1e fb          	endbr32 
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	53                   	push   %ebx
  801d19:	83 ec 0c             	sub    $0xc,%esp
  801d1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d1f:	53                   	push   %ebx
  801d20:	6a 00                	push   $0x0
  801d22:	e8 1b f0 ff ff       	call   800d42 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d27:	89 1c 24             	mov    %ebx,(%esp)
  801d2a:	e8 73 f1 ff ff       	call   800ea2 <fd2data>
  801d2f:	83 c4 08             	add    $0x8,%esp
  801d32:	50                   	push   %eax
  801d33:	6a 00                	push   $0x0
  801d35:	e8 08 f0 ff ff       	call   800d42 <sys_page_unmap>
}
  801d3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <_pipeisclosed>:
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	57                   	push   %edi
  801d43:	56                   	push   %esi
  801d44:	53                   	push   %ebx
  801d45:	83 ec 1c             	sub    $0x1c,%esp
  801d48:	89 c7                	mov    %eax,%edi
  801d4a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d4c:	a1 20 60 80 00       	mov    0x806020,%eax
  801d51:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	57                   	push   %edi
  801d58:	e8 5f 05 00 00       	call   8022bc <pageref>
  801d5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d60:	89 34 24             	mov    %esi,(%esp)
  801d63:	e8 54 05 00 00       	call   8022bc <pageref>
		nn = thisenv->env_runs;
  801d68:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801d6e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	39 cb                	cmp    %ecx,%ebx
  801d76:	74 1b                	je     801d93 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d78:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d7b:	75 cf                	jne    801d4c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d7d:	8b 42 58             	mov    0x58(%edx),%eax
  801d80:	6a 01                	push   $0x1
  801d82:	50                   	push   %eax
  801d83:	53                   	push   %ebx
  801d84:	68 43 2a 80 00       	push   $0x802a43
  801d89:	e8 f6 e4 ff ff       	call   800284 <cprintf>
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	eb b9                	jmp    801d4c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d93:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d96:	0f 94 c0             	sete   %al
  801d99:	0f b6 c0             	movzbl %al,%eax
}
  801d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <devpipe_write>:
{
  801da4:	f3 0f 1e fb          	endbr32 
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	57                   	push   %edi
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	83 ec 28             	sub    $0x28,%esp
  801db1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801db4:	56                   	push   %esi
  801db5:	e8 e8 f0 ff ff       	call   800ea2 <fd2data>
  801dba:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	bf 00 00 00 00       	mov    $0x0,%edi
  801dc4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dc7:	74 4f                	je     801e18 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dc9:	8b 43 04             	mov    0x4(%ebx),%eax
  801dcc:	8b 0b                	mov    (%ebx),%ecx
  801dce:	8d 51 20             	lea    0x20(%ecx),%edx
  801dd1:	39 d0                	cmp    %edx,%eax
  801dd3:	72 14                	jb     801de9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801dd5:	89 da                	mov    %ebx,%edx
  801dd7:	89 f0                	mov    %esi,%eax
  801dd9:	e8 61 ff ff ff       	call   801d3f <_pipeisclosed>
  801dde:	85 c0                	test   %eax,%eax
  801de0:	75 3b                	jne    801e1d <devpipe_write+0x79>
			sys_yield();
  801de2:	e8 ed ee ff ff       	call   800cd4 <sys_yield>
  801de7:	eb e0                	jmp    801dc9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801de9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801df0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801df3:	89 c2                	mov    %eax,%edx
  801df5:	c1 fa 1f             	sar    $0x1f,%edx
  801df8:	89 d1                	mov    %edx,%ecx
  801dfa:	c1 e9 1b             	shr    $0x1b,%ecx
  801dfd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e00:	83 e2 1f             	and    $0x1f,%edx
  801e03:	29 ca                	sub    %ecx,%edx
  801e05:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e0d:	83 c0 01             	add    $0x1,%eax
  801e10:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e13:	83 c7 01             	add    $0x1,%edi
  801e16:	eb ac                	jmp    801dc4 <devpipe_write+0x20>
	return i;
  801e18:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1b:	eb 05                	jmp    801e22 <devpipe_write+0x7e>
				return 0;
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5f                   	pop    %edi
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <devpipe_read>:
{
  801e2a:	f3 0f 1e fb          	endbr32 
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	83 ec 18             	sub    $0x18,%esp
  801e37:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e3a:	57                   	push   %edi
  801e3b:	e8 62 f0 ff ff       	call   800ea2 <fd2data>
  801e40:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e42:	83 c4 10             	add    $0x10,%esp
  801e45:	be 00 00 00 00       	mov    $0x0,%esi
  801e4a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e4d:	75 14                	jne    801e63 <devpipe_read+0x39>
	return i;
  801e4f:	8b 45 10             	mov    0x10(%ebp),%eax
  801e52:	eb 02                	jmp    801e56 <devpipe_read+0x2c>
				return i;
  801e54:	89 f0                	mov    %esi,%eax
}
  801e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e59:	5b                   	pop    %ebx
  801e5a:	5e                   	pop    %esi
  801e5b:	5f                   	pop    %edi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    
			sys_yield();
  801e5e:	e8 71 ee ff ff       	call   800cd4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e63:	8b 03                	mov    (%ebx),%eax
  801e65:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e68:	75 18                	jne    801e82 <devpipe_read+0x58>
			if (i > 0)
  801e6a:	85 f6                	test   %esi,%esi
  801e6c:	75 e6                	jne    801e54 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e6e:	89 da                	mov    %ebx,%edx
  801e70:	89 f8                	mov    %edi,%eax
  801e72:	e8 c8 fe ff ff       	call   801d3f <_pipeisclosed>
  801e77:	85 c0                	test   %eax,%eax
  801e79:	74 e3                	je     801e5e <devpipe_read+0x34>
				return 0;
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e80:	eb d4                	jmp    801e56 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e82:	99                   	cltd   
  801e83:	c1 ea 1b             	shr    $0x1b,%edx
  801e86:	01 d0                	add    %edx,%eax
  801e88:	83 e0 1f             	and    $0x1f,%eax
  801e8b:	29 d0                	sub    %edx,%eax
  801e8d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e95:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e98:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e9b:	83 c6 01             	add    $0x1,%esi
  801e9e:	eb aa                	jmp    801e4a <devpipe_read+0x20>

00801ea0 <pipe>:
{
  801ea0:	f3 0f 1e fb          	endbr32 
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	56                   	push   %esi
  801ea8:	53                   	push   %ebx
  801ea9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaf:	50                   	push   %eax
  801eb0:	e8 08 f0 ff ff       	call   800ebd <fd_alloc>
  801eb5:	89 c3                	mov    %eax,%ebx
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	0f 88 23 01 00 00    	js     801fe5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec2:	83 ec 04             	sub    $0x4,%esp
  801ec5:	68 07 04 00 00       	push   $0x407
  801eca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecd:	6a 00                	push   $0x0
  801ecf:	e8 23 ee ff ff       	call   800cf7 <sys_page_alloc>
  801ed4:	89 c3                	mov    %eax,%ebx
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	0f 88 04 01 00 00    	js     801fe5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801ee1:	83 ec 0c             	sub    $0xc,%esp
  801ee4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ee7:	50                   	push   %eax
  801ee8:	e8 d0 ef ff ff       	call   800ebd <fd_alloc>
  801eed:	89 c3                	mov    %eax,%ebx
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	0f 88 db 00 00 00    	js     801fd5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efa:	83 ec 04             	sub    $0x4,%esp
  801efd:	68 07 04 00 00       	push   $0x407
  801f02:	ff 75 f0             	pushl  -0x10(%ebp)
  801f05:	6a 00                	push   $0x0
  801f07:	e8 eb ed ff ff       	call   800cf7 <sys_page_alloc>
  801f0c:	89 c3                	mov    %eax,%ebx
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	0f 88 bc 00 00 00    	js     801fd5 <pipe+0x135>
	va = fd2data(fd0);
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1f:	e8 7e ef ff ff       	call   800ea2 <fd2data>
  801f24:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f26:	83 c4 0c             	add    $0xc,%esp
  801f29:	68 07 04 00 00       	push   $0x407
  801f2e:	50                   	push   %eax
  801f2f:	6a 00                	push   $0x0
  801f31:	e8 c1 ed ff ff       	call   800cf7 <sys_page_alloc>
  801f36:	89 c3                	mov    %eax,%ebx
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	0f 88 82 00 00 00    	js     801fc5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	ff 75 f0             	pushl  -0x10(%ebp)
  801f49:	e8 54 ef ff ff       	call   800ea2 <fd2data>
  801f4e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f55:	50                   	push   %eax
  801f56:	6a 00                	push   $0x0
  801f58:	56                   	push   %esi
  801f59:	6a 00                	push   $0x0
  801f5b:	e8 bd ed ff ff       	call   800d1d <sys_page_map>
  801f60:	89 c3                	mov    %eax,%ebx
  801f62:	83 c4 20             	add    $0x20,%esp
  801f65:	85 c0                	test   %eax,%eax
  801f67:	78 4e                	js     801fb7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f69:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801f6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f71:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f76:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f80:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f85:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f8c:	83 ec 0c             	sub    $0xc,%esp
  801f8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f92:	e8 f7 ee ff ff       	call   800e8e <fd2num>
  801f97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f9a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f9c:	83 c4 04             	add    $0x4,%esp
  801f9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa2:	e8 e7 ee ff ff       	call   800e8e <fd2num>
  801fa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801faa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb5:	eb 2e                	jmp    801fe5 <pipe+0x145>
	sys_page_unmap(0, va);
  801fb7:	83 ec 08             	sub    $0x8,%esp
  801fba:	56                   	push   %esi
  801fbb:	6a 00                	push   $0x0
  801fbd:	e8 80 ed ff ff       	call   800d42 <sys_page_unmap>
  801fc2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fc5:	83 ec 08             	sub    $0x8,%esp
  801fc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801fcb:	6a 00                	push   $0x0
  801fcd:	e8 70 ed ff ff       	call   800d42 <sys_page_unmap>
  801fd2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fd5:	83 ec 08             	sub    $0x8,%esp
  801fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 60 ed ff ff       	call   800d42 <sys_page_unmap>
  801fe2:	83 c4 10             	add    $0x10,%esp
}
  801fe5:	89 d8                	mov    %ebx,%eax
  801fe7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fea:	5b                   	pop    %ebx
  801feb:	5e                   	pop    %esi
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    

00801fee <pipeisclosed>:
{
  801fee:	f3 0f 1e fb          	endbr32 
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffb:	50                   	push   %eax
  801ffc:	ff 75 08             	pushl  0x8(%ebp)
  801fff:	e8 0f ef ff ff       	call   800f13 <fd_lookup>
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	78 18                	js     802023 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	ff 75 f4             	pushl  -0xc(%ebp)
  802011:	e8 8c ee ff ff       	call   800ea2 <fd2data>
  802016:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201b:	e8 1f fd ff ff       	call   801d3f <_pipeisclosed>
  802020:	83 c4 10             	add    $0x10,%esp
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802025:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802029:	b8 00 00 00 00       	mov    $0x0,%eax
  80202e:	c3                   	ret    

0080202f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80202f:	f3 0f 1e fb          	endbr32 
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802039:	68 5b 2a 80 00       	push   $0x802a5b
  80203e:	ff 75 0c             	pushl  0xc(%ebp)
  802041:	e8 48 e8 ff ff       	call   80088e <strcpy>
	return 0;
}
  802046:	b8 00 00 00 00       	mov    $0x0,%eax
  80204b:	c9                   	leave  
  80204c:	c3                   	ret    

0080204d <devcons_write>:
{
  80204d:	f3 0f 1e fb          	endbr32 
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	57                   	push   %edi
  802055:	56                   	push   %esi
  802056:	53                   	push   %ebx
  802057:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80205d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802062:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802068:	3b 75 10             	cmp    0x10(%ebp),%esi
  80206b:	73 31                	jae    80209e <devcons_write+0x51>
		m = n - tot;
  80206d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802070:	29 f3                	sub    %esi,%ebx
  802072:	83 fb 7f             	cmp    $0x7f,%ebx
  802075:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80207a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80207d:	83 ec 04             	sub    $0x4,%esp
  802080:	53                   	push   %ebx
  802081:	89 f0                	mov    %esi,%eax
  802083:	03 45 0c             	add    0xc(%ebp),%eax
  802086:	50                   	push   %eax
  802087:	57                   	push   %edi
  802088:	e8 ff e9 ff ff       	call   800a8c <memmove>
		sys_cputs(buf, m);
  80208d:	83 c4 08             	add    $0x8,%esp
  802090:	53                   	push   %ebx
  802091:	57                   	push   %edi
  802092:	e8 b1 eb ff ff       	call   800c48 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802097:	01 de                	add    %ebx,%esi
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	eb ca                	jmp    802068 <devcons_write+0x1b>
}
  80209e:	89 f0                	mov    %esi,%eax
  8020a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <devcons_read>:
{
  8020a8:	f3 0f 1e fb          	endbr32 
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 08             	sub    $0x8,%esp
  8020b2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020bb:	74 21                	je     8020de <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8020bd:	e8 a8 eb ff ff       	call   800c6a <sys_cgetc>
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	75 07                	jne    8020cd <devcons_read+0x25>
		sys_yield();
  8020c6:	e8 09 ec ff ff       	call   800cd4 <sys_yield>
  8020cb:	eb f0                	jmp    8020bd <devcons_read+0x15>
	if (c < 0)
  8020cd:	78 0f                	js     8020de <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8020cf:	83 f8 04             	cmp    $0x4,%eax
  8020d2:	74 0c                	je     8020e0 <devcons_read+0x38>
	*(char*)vbuf = c;
  8020d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d7:	88 02                	mov    %al,(%edx)
	return 1;
  8020d9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    
		return 0;
  8020e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8020e5:	eb f7                	jmp    8020de <devcons_read+0x36>

008020e7 <cputchar>:
{
  8020e7:	f3 0f 1e fb          	endbr32 
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020f7:	6a 01                	push   $0x1
  8020f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020fc:	50                   	push   %eax
  8020fd:	e8 46 eb ff ff       	call   800c48 <sys_cputs>
}
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	c9                   	leave  
  802106:	c3                   	ret    

00802107 <getchar>:
{
  802107:	f3 0f 1e fb          	endbr32 
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802111:	6a 01                	push   $0x1
  802113:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802116:	50                   	push   %eax
  802117:	6a 00                	push   $0x0
  802119:	e8 7d f0 ff ff       	call   80119b <read>
	if (r < 0)
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	85 c0                	test   %eax,%eax
  802123:	78 06                	js     80212b <getchar+0x24>
	if (r < 1)
  802125:	74 06                	je     80212d <getchar+0x26>
	return c;
  802127:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    
		return -E_EOF;
  80212d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802132:	eb f7                	jmp    80212b <getchar+0x24>

00802134 <iscons>:
{
  802134:	f3 0f 1e fb          	endbr32 
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80213e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802141:	50                   	push   %eax
  802142:	ff 75 08             	pushl  0x8(%ebp)
  802145:	e8 c9 ed ff ff       	call   800f13 <fd_lookup>
  80214a:	83 c4 10             	add    $0x10,%esp
  80214d:	85 c0                	test   %eax,%eax
  80214f:	78 11                	js     802162 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802154:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80215a:	39 10                	cmp    %edx,(%eax)
  80215c:	0f 94 c0             	sete   %al
  80215f:	0f b6 c0             	movzbl %al,%eax
}
  802162:	c9                   	leave  
  802163:	c3                   	ret    

00802164 <opencons>:
{
  802164:	f3 0f 1e fb          	endbr32 
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80216e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802171:	50                   	push   %eax
  802172:	e8 46 ed ff ff       	call   800ebd <fd_alloc>
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	85 c0                	test   %eax,%eax
  80217c:	78 3a                	js     8021b8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80217e:	83 ec 04             	sub    $0x4,%esp
  802181:	68 07 04 00 00       	push   $0x407
  802186:	ff 75 f4             	pushl  -0xc(%ebp)
  802189:	6a 00                	push   $0x0
  80218b:	e8 67 eb ff ff       	call   800cf7 <sys_page_alloc>
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	85 c0                	test   %eax,%eax
  802195:	78 21                	js     8021b8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802197:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219a:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8021a0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021ac:	83 ec 0c             	sub    $0xc,%esp
  8021af:	50                   	push   %eax
  8021b0:	e8 d9 ec ff ff       	call   800e8e <fd2num>
  8021b5:	83 c4 10             	add    $0x10,%esp
}
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021ba:	f3 0f 1e fb          	endbr32 
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	56                   	push   %esi
  8021c2:	53                   	push   %ebx
  8021c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8021c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021d3:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8021d6:	83 ec 0c             	sub    $0xc,%esp
  8021d9:	50                   	push   %eax
  8021da:	e8 1e ec ff ff       	call   800dfd <sys_ipc_recv>
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	75 2b                	jne    802211 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8021e6:	85 f6                	test   %esi,%esi
  8021e8:	74 0a                	je     8021f4 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8021ea:	a1 20 60 80 00       	mov    0x806020,%eax
  8021ef:	8b 40 74             	mov    0x74(%eax),%eax
  8021f2:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8021f4:	85 db                	test   %ebx,%ebx
  8021f6:	74 0a                	je     802202 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8021f8:	a1 20 60 80 00       	mov    0x806020,%eax
  8021fd:	8b 40 78             	mov    0x78(%eax),%eax
  802200:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802202:	a1 20 60 80 00       	mov    0x806020,%eax
  802207:	8b 40 70             	mov    0x70(%eax),%eax
}
  80220a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802211:	85 f6                	test   %esi,%esi
  802213:	74 06                	je     80221b <ipc_recv+0x61>
  802215:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80221b:	85 db                	test   %ebx,%ebx
  80221d:	74 eb                	je     80220a <ipc_recv+0x50>
  80221f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802225:	eb e3                	jmp    80220a <ipc_recv+0x50>

00802227 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802227:	f3 0f 1e fb          	endbr32 
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	57                   	push   %edi
  80222f:	56                   	push   %esi
  802230:	53                   	push   %ebx
  802231:	83 ec 0c             	sub    $0xc,%esp
  802234:	8b 7d 08             	mov    0x8(%ebp),%edi
  802237:	8b 75 0c             	mov    0xc(%ebp),%esi
  80223a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80223d:	85 db                	test   %ebx,%ebx
  80223f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802244:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802247:	ff 75 14             	pushl  0x14(%ebp)
  80224a:	53                   	push   %ebx
  80224b:	56                   	push   %esi
  80224c:	57                   	push   %edi
  80224d:	e8 84 eb ff ff       	call   800dd6 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802252:	83 c4 10             	add    $0x10,%esp
  802255:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802258:	75 07                	jne    802261 <ipc_send+0x3a>
			sys_yield();
  80225a:	e8 75 ea ff ff       	call   800cd4 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80225f:	eb e6                	jmp    802247 <ipc_send+0x20>
		}
		else if (ret == 0)
  802261:	85 c0                	test   %eax,%eax
  802263:	75 08                	jne    80226d <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802268:	5b                   	pop    %ebx
  802269:	5e                   	pop    %esi
  80226a:	5f                   	pop    %edi
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80226d:	50                   	push   %eax
  80226e:	68 67 2a 80 00       	push   $0x802a67
  802273:	6a 48                	push   $0x48
  802275:	68 75 2a 80 00       	push   $0x802a75
  80227a:	e8 1e df ff ff       	call   80019d <_panic>

0080227f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80227f:	f3 0f 1e fb          	endbr32 
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802289:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80228e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802291:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802297:	8b 52 50             	mov    0x50(%edx),%edx
  80229a:	39 ca                	cmp    %ecx,%edx
  80229c:	74 11                	je     8022af <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80229e:	83 c0 01             	add    $0x1,%eax
  8022a1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022a6:	75 e6                	jne    80228e <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8022a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ad:	eb 0b                	jmp    8022ba <ipc_find_env+0x3b>
			return envs[i].env_id;
  8022af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022b7:	8b 40 48             	mov    0x48(%eax),%eax
}
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    

008022bc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bc:	f3 0f 1e fb          	endbr32 
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c6:	89 c2                	mov    %eax,%edx
  8022c8:	c1 ea 16             	shr    $0x16,%edx
  8022cb:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8022d2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8022d7:	f6 c1 01             	test   $0x1,%cl
  8022da:	74 1c                	je     8022f8 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8022dc:	c1 e8 0c             	shr    $0xc,%eax
  8022df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022e6:	a8 01                	test   $0x1,%al
  8022e8:	74 0e                	je     8022f8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022ea:	c1 e8 0c             	shr    $0xc,%eax
  8022ed:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8022f4:	ef 
  8022f5:	0f b7 d2             	movzwl %dx,%edx
}
  8022f8:	89 d0                	mov    %edx,%eax
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__udivdi3>:
  802300:	f3 0f 1e fb          	endbr32 
  802304:	55                   	push   %ebp
  802305:	57                   	push   %edi
  802306:	56                   	push   %esi
  802307:	53                   	push   %ebx
  802308:	83 ec 1c             	sub    $0x1c,%esp
  80230b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802313:	8b 74 24 34          	mov    0x34(%esp),%esi
  802317:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80231b:	85 d2                	test   %edx,%edx
  80231d:	75 19                	jne    802338 <__udivdi3+0x38>
  80231f:	39 f3                	cmp    %esi,%ebx
  802321:	76 4d                	jbe    802370 <__udivdi3+0x70>
  802323:	31 ff                	xor    %edi,%edi
  802325:	89 e8                	mov    %ebp,%eax
  802327:	89 f2                	mov    %esi,%edx
  802329:	f7 f3                	div    %ebx
  80232b:	89 fa                	mov    %edi,%edx
  80232d:	83 c4 1c             	add    $0x1c,%esp
  802330:	5b                   	pop    %ebx
  802331:	5e                   	pop    %esi
  802332:	5f                   	pop    %edi
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    
  802335:	8d 76 00             	lea    0x0(%esi),%esi
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	76 14                	jbe    802350 <__udivdi3+0x50>
  80233c:	31 ff                	xor    %edi,%edi
  80233e:	31 c0                	xor    %eax,%eax
  802340:	89 fa                	mov    %edi,%edx
  802342:	83 c4 1c             	add    $0x1c,%esp
  802345:	5b                   	pop    %ebx
  802346:	5e                   	pop    %esi
  802347:	5f                   	pop    %edi
  802348:	5d                   	pop    %ebp
  802349:	c3                   	ret    
  80234a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802350:	0f bd fa             	bsr    %edx,%edi
  802353:	83 f7 1f             	xor    $0x1f,%edi
  802356:	75 48                	jne    8023a0 <__udivdi3+0xa0>
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	72 06                	jb     802362 <__udivdi3+0x62>
  80235c:	31 c0                	xor    %eax,%eax
  80235e:	39 eb                	cmp    %ebp,%ebx
  802360:	77 de                	ja     802340 <__udivdi3+0x40>
  802362:	b8 01 00 00 00       	mov    $0x1,%eax
  802367:	eb d7                	jmp    802340 <__udivdi3+0x40>
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 d9                	mov    %ebx,%ecx
  802372:	85 db                	test   %ebx,%ebx
  802374:	75 0b                	jne    802381 <__udivdi3+0x81>
  802376:	b8 01 00 00 00       	mov    $0x1,%eax
  80237b:	31 d2                	xor    %edx,%edx
  80237d:	f7 f3                	div    %ebx
  80237f:	89 c1                	mov    %eax,%ecx
  802381:	31 d2                	xor    %edx,%edx
  802383:	89 f0                	mov    %esi,%eax
  802385:	f7 f1                	div    %ecx
  802387:	89 c6                	mov    %eax,%esi
  802389:	89 e8                	mov    %ebp,%eax
  80238b:	89 f7                	mov    %esi,%edi
  80238d:	f7 f1                	div    %ecx
  80238f:	89 fa                	mov    %edi,%edx
  802391:	83 c4 1c             	add    $0x1c,%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	89 f9                	mov    %edi,%ecx
  8023a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8023a7:	29 f8                	sub    %edi,%eax
  8023a9:	d3 e2                	shl    %cl,%edx
  8023ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023af:	89 c1                	mov    %eax,%ecx
  8023b1:	89 da                	mov    %ebx,%edx
  8023b3:	d3 ea                	shr    %cl,%edx
  8023b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023b9:	09 d1                	or     %edx,%ecx
  8023bb:	89 f2                	mov    %esi,%edx
  8023bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023c1:	89 f9                	mov    %edi,%ecx
  8023c3:	d3 e3                	shl    %cl,%ebx
  8023c5:	89 c1                	mov    %eax,%ecx
  8023c7:	d3 ea                	shr    %cl,%edx
  8023c9:	89 f9                	mov    %edi,%ecx
  8023cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023cf:	89 eb                	mov    %ebp,%ebx
  8023d1:	d3 e6                	shl    %cl,%esi
  8023d3:	89 c1                	mov    %eax,%ecx
  8023d5:	d3 eb                	shr    %cl,%ebx
  8023d7:	09 de                	or     %ebx,%esi
  8023d9:	89 f0                	mov    %esi,%eax
  8023db:	f7 74 24 08          	divl   0x8(%esp)
  8023df:	89 d6                	mov    %edx,%esi
  8023e1:	89 c3                	mov    %eax,%ebx
  8023e3:	f7 64 24 0c          	mull   0xc(%esp)
  8023e7:	39 d6                	cmp    %edx,%esi
  8023e9:	72 15                	jb     802400 <__udivdi3+0x100>
  8023eb:	89 f9                	mov    %edi,%ecx
  8023ed:	d3 e5                	shl    %cl,%ebp
  8023ef:	39 c5                	cmp    %eax,%ebp
  8023f1:	73 04                	jae    8023f7 <__udivdi3+0xf7>
  8023f3:	39 d6                	cmp    %edx,%esi
  8023f5:	74 09                	je     802400 <__udivdi3+0x100>
  8023f7:	89 d8                	mov    %ebx,%eax
  8023f9:	31 ff                	xor    %edi,%edi
  8023fb:	e9 40 ff ff ff       	jmp    802340 <__udivdi3+0x40>
  802400:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802403:	31 ff                	xor    %edi,%edi
  802405:	e9 36 ff ff ff       	jmp    802340 <__udivdi3+0x40>
  80240a:	66 90                	xchg   %ax,%ax
  80240c:	66 90                	xchg   %ax,%ax
  80240e:	66 90                	xchg   %ax,%ax

00802410 <__umoddi3>:
  802410:	f3 0f 1e fb          	endbr32 
  802414:	55                   	push   %ebp
  802415:	57                   	push   %edi
  802416:	56                   	push   %esi
  802417:	53                   	push   %ebx
  802418:	83 ec 1c             	sub    $0x1c,%esp
  80241b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80241f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802423:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802427:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80242b:	85 c0                	test   %eax,%eax
  80242d:	75 19                	jne    802448 <__umoddi3+0x38>
  80242f:	39 df                	cmp    %ebx,%edi
  802431:	76 5d                	jbe    802490 <__umoddi3+0x80>
  802433:	89 f0                	mov    %esi,%eax
  802435:	89 da                	mov    %ebx,%edx
  802437:	f7 f7                	div    %edi
  802439:	89 d0                	mov    %edx,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	83 c4 1c             	add    $0x1c,%esp
  802440:	5b                   	pop    %ebx
  802441:	5e                   	pop    %esi
  802442:	5f                   	pop    %edi
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    
  802445:	8d 76 00             	lea    0x0(%esi),%esi
  802448:	89 f2                	mov    %esi,%edx
  80244a:	39 d8                	cmp    %ebx,%eax
  80244c:	76 12                	jbe    802460 <__umoddi3+0x50>
  80244e:	89 f0                	mov    %esi,%eax
  802450:	89 da                	mov    %ebx,%edx
  802452:	83 c4 1c             	add    $0x1c,%esp
  802455:	5b                   	pop    %ebx
  802456:	5e                   	pop    %esi
  802457:	5f                   	pop    %edi
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    
  80245a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802460:	0f bd e8             	bsr    %eax,%ebp
  802463:	83 f5 1f             	xor    $0x1f,%ebp
  802466:	75 50                	jne    8024b8 <__umoddi3+0xa8>
  802468:	39 d8                	cmp    %ebx,%eax
  80246a:	0f 82 e0 00 00 00    	jb     802550 <__umoddi3+0x140>
  802470:	89 d9                	mov    %ebx,%ecx
  802472:	39 f7                	cmp    %esi,%edi
  802474:	0f 86 d6 00 00 00    	jbe    802550 <__umoddi3+0x140>
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	89 ca                	mov    %ecx,%edx
  80247e:	83 c4 1c             	add    $0x1c,%esp
  802481:	5b                   	pop    %ebx
  802482:	5e                   	pop    %esi
  802483:	5f                   	pop    %edi
  802484:	5d                   	pop    %ebp
  802485:	c3                   	ret    
  802486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	89 fd                	mov    %edi,%ebp
  802492:	85 ff                	test   %edi,%edi
  802494:	75 0b                	jne    8024a1 <__umoddi3+0x91>
  802496:	b8 01 00 00 00       	mov    $0x1,%eax
  80249b:	31 d2                	xor    %edx,%edx
  80249d:	f7 f7                	div    %edi
  80249f:	89 c5                	mov    %eax,%ebp
  8024a1:	89 d8                	mov    %ebx,%eax
  8024a3:	31 d2                	xor    %edx,%edx
  8024a5:	f7 f5                	div    %ebp
  8024a7:	89 f0                	mov    %esi,%eax
  8024a9:	f7 f5                	div    %ebp
  8024ab:	89 d0                	mov    %edx,%eax
  8024ad:	31 d2                	xor    %edx,%edx
  8024af:	eb 8c                	jmp    80243d <__umoddi3+0x2d>
  8024b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b8:	89 e9                	mov    %ebp,%ecx
  8024ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8024bf:	29 ea                	sub    %ebp,%edx
  8024c1:	d3 e0                	shl    %cl,%eax
  8024c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024c7:	89 d1                	mov    %edx,%ecx
  8024c9:	89 f8                	mov    %edi,%eax
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024d9:	09 c1                	or     %eax,%ecx
  8024db:	89 d8                	mov    %ebx,%eax
  8024dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024e1:	89 e9                	mov    %ebp,%ecx
  8024e3:	d3 e7                	shl    %cl,%edi
  8024e5:	89 d1                	mov    %edx,%ecx
  8024e7:	d3 e8                	shr    %cl,%eax
  8024e9:	89 e9                	mov    %ebp,%ecx
  8024eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024ef:	d3 e3                	shl    %cl,%ebx
  8024f1:	89 c7                	mov    %eax,%edi
  8024f3:	89 d1                	mov    %edx,%ecx
  8024f5:	89 f0                	mov    %esi,%eax
  8024f7:	d3 e8                	shr    %cl,%eax
  8024f9:	89 e9                	mov    %ebp,%ecx
  8024fb:	89 fa                	mov    %edi,%edx
  8024fd:	d3 e6                	shl    %cl,%esi
  8024ff:	09 d8                	or     %ebx,%eax
  802501:	f7 74 24 08          	divl   0x8(%esp)
  802505:	89 d1                	mov    %edx,%ecx
  802507:	89 f3                	mov    %esi,%ebx
  802509:	f7 64 24 0c          	mull   0xc(%esp)
  80250d:	89 c6                	mov    %eax,%esi
  80250f:	89 d7                	mov    %edx,%edi
  802511:	39 d1                	cmp    %edx,%ecx
  802513:	72 06                	jb     80251b <__umoddi3+0x10b>
  802515:	75 10                	jne    802527 <__umoddi3+0x117>
  802517:	39 c3                	cmp    %eax,%ebx
  802519:	73 0c                	jae    802527 <__umoddi3+0x117>
  80251b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80251f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802523:	89 d7                	mov    %edx,%edi
  802525:	89 c6                	mov    %eax,%esi
  802527:	89 ca                	mov    %ecx,%edx
  802529:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80252e:	29 f3                	sub    %esi,%ebx
  802530:	19 fa                	sbb    %edi,%edx
  802532:	89 d0                	mov    %edx,%eax
  802534:	d3 e0                	shl    %cl,%eax
  802536:	89 e9                	mov    %ebp,%ecx
  802538:	d3 eb                	shr    %cl,%ebx
  80253a:	d3 ea                	shr    %cl,%edx
  80253c:	09 d8                	or     %ebx,%eax
  80253e:	83 c4 1c             	add    $0x1c,%esp
  802541:	5b                   	pop    %ebx
  802542:	5e                   	pop    %esi
  802543:	5f                   	pop    %edi
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    
  802546:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80254d:	8d 76 00             	lea    0x0(%esi),%esi
  802550:	29 fe                	sub    %edi,%esi
  802552:	19 c3                	sbb    %eax,%ebx
  802554:	89 f2                	mov    %esi,%edx
  802556:	89 d9                	mov    %ebx,%ecx
  802558:	e9 1d ff ff ff       	jmp    80247a <__umoddi3+0x6a>
