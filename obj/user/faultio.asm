
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 42 00 00 00       	call   800073 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  80003d:	9c                   	pushf  
  80003e:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003f:	f6 c4 30             	test   $0x30,%ah
  800042:	75 1d                	jne    800061 <umain+0x2e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800044:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800049:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80004e:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80004f:	83 ec 0c             	sub    $0xc,%esp
  800052:	68 8e 23 80 00       	push   $0x80238e
  800057:	e8 1c 01 00 00       	call   800178 <cprintf>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    
		cprintf("eflags wrong\n");
  800061:	83 ec 0c             	sub    $0xc,%esp
  800064:	68 80 23 80 00       	push   $0x802380
  800069:	e8 0a 01 00 00       	call   800178 <cprintf>
  80006e:	83 c4 10             	add    $0x10,%esp
  800071:	eb d1                	jmp    800044 <umain+0x11>

00800073 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800073:	f3 0f 1e fb          	endbr32 
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800082:	e8 1e 0b 00 00       	call   800ba5 <sys_getenvid>
  800087:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800094:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 db                	test   %ebx,%ebx
  80009b:	7e 07                	jle    8000a4 <libmain+0x31>
		binaryname = argv[0];
  80009d:	8b 06                	mov    (%esi),%eax
  80009f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	e8 85 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ae:	e8 0a 00 00 00       	call   8000bd <exit>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8000c7:	e8 aa 0e 00 00       	call   800f76 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 ab 0a 00 00       	call   800b81 <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000db:	f3 0f 1e fb          	endbr32 
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 04             	sub    $0x4,%esp
  8000e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e9:	8b 13                	mov    (%ebx),%edx
  8000eb:	8d 42 01             	lea    0x1(%edx),%eax
  8000ee:	89 03                	mov    %eax,(%ebx)
  8000f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fc:	74 09                	je     800107 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800105:	c9                   	leave  
  800106:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	68 ff 00 00 00       	push   $0xff
  80010f:	8d 43 08             	lea    0x8(%ebx),%eax
  800112:	50                   	push   %eax
  800113:	e8 24 0a 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  800118:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	eb db                	jmp    8000fe <putch+0x23>

00800123 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800123:	f3 0f 1e fb          	endbr32 
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800130:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800137:	00 00 00 
	b.cnt = 0;
  80013a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800141:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800144:	ff 75 0c             	pushl  0xc(%ebp)
  800147:	ff 75 08             	pushl  0x8(%ebp)
  80014a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800150:	50                   	push   %eax
  800151:	68 db 00 80 00       	push   $0x8000db
  800156:	e8 20 01 00 00       	call   80027b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015b:	83 c4 08             	add    $0x8,%esp
  80015e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800164:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 cc 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  800170:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 95 ff ff ff       	call   800123 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 1c             	sub    $0x1c,%esp
  800199:	89 c7                	mov    %eax,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a3:	89 d1                	mov    %edx,%ecx
  8001a5:	89 c2                	mov    %eax,%edx
  8001a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8001b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001bd:	39 c2                	cmp    %eax,%edx
  8001bf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001c2:	72 3e                	jb     800202 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	ff 75 18             	pushl  0x18(%ebp)
  8001ca:	83 eb 01             	sub    $0x1,%ebx
  8001cd:	53                   	push   %ebx
  8001ce:	50                   	push   %eax
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001db:	ff 75 d8             	pushl  -0x28(%ebp)
  8001de:	e8 3d 1f 00 00       	call   802120 <__udivdi3>
  8001e3:	83 c4 18             	add    $0x18,%esp
  8001e6:	52                   	push   %edx
  8001e7:	50                   	push   %eax
  8001e8:	89 f2                	mov    %esi,%edx
  8001ea:	89 f8                	mov    %edi,%eax
  8001ec:	e8 9f ff ff ff       	call   800190 <printnum>
  8001f1:	83 c4 20             	add    $0x20,%esp
  8001f4:	eb 13                	jmp    800209 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f6:	83 ec 08             	sub    $0x8,%esp
  8001f9:	56                   	push   %esi
  8001fa:	ff 75 18             	pushl  0x18(%ebp)
  8001fd:	ff d7                	call   *%edi
  8001ff:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800202:	83 eb 01             	sub    $0x1,%ebx
  800205:	85 db                	test   %ebx,%ebx
  800207:	7f ed                	jg     8001f6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	83 ec 04             	sub    $0x4,%esp
  800210:	ff 75 e4             	pushl  -0x1c(%ebp)
  800213:	ff 75 e0             	pushl  -0x20(%ebp)
  800216:	ff 75 dc             	pushl  -0x24(%ebp)
  800219:	ff 75 d8             	pushl  -0x28(%ebp)
  80021c:	e8 0f 20 00 00       	call   802230 <__umoddi3>
  800221:	83 c4 14             	add    $0x14,%esp
  800224:	0f be 80 b2 23 80 00 	movsbl 0x8023b2(%eax),%eax
  80022b:	50                   	push   %eax
  80022c:	ff d7                	call   *%edi
}
  80022e:	83 c4 10             	add    $0x10,%esp
  800231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800234:	5b                   	pop    %ebx
  800235:	5e                   	pop    %esi
  800236:	5f                   	pop    %edi
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800239:	f3 0f 1e fb          	endbr32 
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800243:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800247:	8b 10                	mov    (%eax),%edx
  800249:	3b 50 04             	cmp    0x4(%eax),%edx
  80024c:	73 0a                	jae    800258 <sprintputch+0x1f>
		*b->buf++ = ch;
  80024e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800251:	89 08                	mov    %ecx,(%eax)
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	88 02                	mov    %al,(%edx)
}
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <printfmt>:
{
  80025a:	f3 0f 1e fb          	endbr32 
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800264:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800267:	50                   	push   %eax
  800268:	ff 75 10             	pushl  0x10(%ebp)
  80026b:	ff 75 0c             	pushl  0xc(%ebp)
  80026e:	ff 75 08             	pushl  0x8(%ebp)
  800271:	e8 05 00 00 00       	call   80027b <vprintfmt>
}
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <vprintfmt>:
{
  80027b:	f3 0f 1e fb          	endbr32 
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 3c             	sub    $0x3c,%esp
  800288:	8b 75 08             	mov    0x8(%ebp),%esi
  80028b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800291:	e9 8e 03 00 00       	jmp    800624 <vprintfmt+0x3a9>
		padc = ' ';
  800296:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80029a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002a1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002a8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002af:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002b4:	8d 47 01             	lea    0x1(%edi),%eax
  8002b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ba:	0f b6 17             	movzbl (%edi),%edx
  8002bd:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002c0:	3c 55                	cmp    $0x55,%al
  8002c2:	0f 87 df 03 00 00    	ja     8006a7 <vprintfmt+0x42c>
  8002c8:	0f b6 c0             	movzbl %al,%eax
  8002cb:	3e ff 24 85 00 25 80 	notrack jmp *0x802500(,%eax,4)
  8002d2:	00 
  8002d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002d6:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002da:	eb d8                	jmp    8002b4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002df:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002e3:	eb cf                	jmp    8002b4 <vprintfmt+0x39>
  8002e5:	0f b6 d2             	movzbl %dl,%edx
  8002e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8002f3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002fa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002fd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800300:	83 f9 09             	cmp    $0x9,%ecx
  800303:	77 55                	ja     80035a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800305:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800308:	eb e9                	jmp    8002f3 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80030a:	8b 45 14             	mov    0x14(%ebp),%eax
  80030d:	8b 00                	mov    (%eax),%eax
  80030f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800312:	8b 45 14             	mov    0x14(%ebp),%eax
  800315:	8d 40 04             	lea    0x4(%eax),%eax
  800318:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80031e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800322:	79 90                	jns    8002b4 <vprintfmt+0x39>
				width = precision, precision = -1;
  800324:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800327:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800331:	eb 81                	jmp    8002b4 <vprintfmt+0x39>
  800333:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800336:	85 c0                	test   %eax,%eax
  800338:	ba 00 00 00 00       	mov    $0x0,%edx
  80033d:	0f 49 d0             	cmovns %eax,%edx
  800340:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800346:	e9 69 ff ff ff       	jmp    8002b4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80034e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800355:	e9 5a ff ff ff       	jmp    8002b4 <vprintfmt+0x39>
  80035a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80035d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800360:	eb bc                	jmp    80031e <vprintfmt+0xa3>
			lflag++;
  800362:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800368:	e9 47 ff ff ff       	jmp    8002b4 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80036d:	8b 45 14             	mov    0x14(%ebp),%eax
  800370:	8d 78 04             	lea    0x4(%eax),%edi
  800373:	83 ec 08             	sub    $0x8,%esp
  800376:	53                   	push   %ebx
  800377:	ff 30                	pushl  (%eax)
  800379:	ff d6                	call   *%esi
			break;
  80037b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80037e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800381:	e9 9b 02 00 00       	jmp    800621 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 78 04             	lea    0x4(%eax),%edi
  80038c:	8b 00                	mov    (%eax),%eax
  80038e:	99                   	cltd   
  80038f:	31 d0                	xor    %edx,%eax
  800391:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800393:	83 f8 0f             	cmp    $0xf,%eax
  800396:	7f 23                	jg     8003bb <vprintfmt+0x140>
  800398:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  80039f:	85 d2                	test   %edx,%edx
  8003a1:	74 18                	je     8003bb <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003a3:	52                   	push   %edx
  8003a4:	68 69 27 80 00       	push   $0x802769
  8003a9:	53                   	push   %ebx
  8003aa:	56                   	push   %esi
  8003ab:	e8 aa fe ff ff       	call   80025a <printfmt>
  8003b0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003b6:	e9 66 02 00 00       	jmp    800621 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003bb:	50                   	push   %eax
  8003bc:	68 ca 23 80 00       	push   $0x8023ca
  8003c1:	53                   	push   %ebx
  8003c2:	56                   	push   %esi
  8003c3:	e8 92 fe ff ff       	call   80025a <printfmt>
  8003c8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003cb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ce:	e9 4e 02 00 00       	jmp    800621 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	83 c0 04             	add    $0x4,%eax
  8003d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003e1:	85 d2                	test   %edx,%edx
  8003e3:	b8 c3 23 80 00       	mov    $0x8023c3,%eax
  8003e8:	0f 45 c2             	cmovne %edx,%eax
  8003eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f2:	7e 06                	jle    8003fa <vprintfmt+0x17f>
  8003f4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003f8:	75 0d                	jne    800407 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003fd:	89 c7                	mov    %eax,%edi
  8003ff:	03 45 e0             	add    -0x20(%ebp),%eax
  800402:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800405:	eb 55                	jmp    80045c <vprintfmt+0x1e1>
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	ff 75 d8             	pushl  -0x28(%ebp)
  80040d:	ff 75 cc             	pushl  -0x34(%ebp)
  800410:	e8 46 03 00 00       	call   80075b <strnlen>
  800415:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800418:	29 c2                	sub    %eax,%edx
  80041a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80041d:	83 c4 10             	add    $0x10,%esp
  800420:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800422:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	85 ff                	test   %edi,%edi
  80042b:	7e 11                	jle    80043e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	53                   	push   %ebx
  800431:	ff 75 e0             	pushl  -0x20(%ebp)
  800434:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	83 ef 01             	sub    $0x1,%edi
  800439:	83 c4 10             	add    $0x10,%esp
  80043c:	eb eb                	jmp    800429 <vprintfmt+0x1ae>
  80043e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	0f 49 c2             	cmovns %edx,%eax
  80044b:	29 c2                	sub    %eax,%edx
  80044d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800450:	eb a8                	jmp    8003fa <vprintfmt+0x17f>
					putch(ch, putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	53                   	push   %ebx
  800456:	52                   	push   %edx
  800457:	ff d6                	call   *%esi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800461:	83 c7 01             	add    $0x1,%edi
  800464:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800468:	0f be d0             	movsbl %al,%edx
  80046b:	85 d2                	test   %edx,%edx
  80046d:	74 4b                	je     8004ba <vprintfmt+0x23f>
  80046f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800473:	78 06                	js     80047b <vprintfmt+0x200>
  800475:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800479:	78 1e                	js     800499 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80047b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80047f:	74 d1                	je     800452 <vprintfmt+0x1d7>
  800481:	0f be c0             	movsbl %al,%eax
  800484:	83 e8 20             	sub    $0x20,%eax
  800487:	83 f8 5e             	cmp    $0x5e,%eax
  80048a:	76 c6                	jbe    800452 <vprintfmt+0x1d7>
					putch('?', putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	53                   	push   %ebx
  800490:	6a 3f                	push   $0x3f
  800492:	ff d6                	call   *%esi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	eb c3                	jmp    80045c <vprintfmt+0x1e1>
  800499:	89 cf                	mov    %ecx,%edi
  80049b:	eb 0e                	jmp    8004ab <vprintfmt+0x230>
				putch(' ', putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	53                   	push   %ebx
  8004a1:	6a 20                	push   $0x20
  8004a3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004a5:	83 ef 01             	sub    $0x1,%edi
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	85 ff                	test   %edi,%edi
  8004ad:	7f ee                	jg     80049d <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004af:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b5:	e9 67 01 00 00       	jmp    800621 <vprintfmt+0x3a6>
  8004ba:	89 cf                	mov    %ecx,%edi
  8004bc:	eb ed                	jmp    8004ab <vprintfmt+0x230>
	if (lflag >= 2)
  8004be:	83 f9 01             	cmp    $0x1,%ecx
  8004c1:	7f 1b                	jg     8004de <vprintfmt+0x263>
	else if (lflag)
  8004c3:	85 c9                	test   %ecx,%ecx
  8004c5:	74 63                	je     80052a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cf:	99                   	cltd   
  8004d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 40 04             	lea    0x4(%eax),%eax
  8004d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004dc:	eb 17                	jmp    8004f5 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8b 50 04             	mov    0x4(%eax),%edx
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8d 40 08             	lea    0x8(%eax),%eax
  8004f2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004fb:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800500:	85 c9                	test   %ecx,%ecx
  800502:	0f 89 ff 00 00 00    	jns    800607 <vprintfmt+0x38c>
				putch('-', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	6a 2d                	push   $0x2d
  80050e:	ff d6                	call   *%esi
				num = -(long long) num;
  800510:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800513:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800516:	f7 da                	neg    %edx
  800518:	83 d1 00             	adc    $0x0,%ecx
  80051b:	f7 d9                	neg    %ecx
  80051d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800520:	b8 0a 00 00 00       	mov    $0xa,%eax
  800525:	e9 dd 00 00 00       	jmp    800607 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800532:	99                   	cltd   
  800533:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 40 04             	lea    0x4(%eax),%eax
  80053c:	89 45 14             	mov    %eax,0x14(%ebp)
  80053f:	eb b4                	jmp    8004f5 <vprintfmt+0x27a>
	if (lflag >= 2)
  800541:	83 f9 01             	cmp    $0x1,%ecx
  800544:	7f 1e                	jg     800564 <vprintfmt+0x2e9>
	else if (lflag)
  800546:	85 c9                	test   %ecx,%ecx
  800548:	74 32                	je     80057c <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8b 10                	mov    (%eax),%edx
  80054f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800554:	8d 40 04             	lea    0x4(%eax),%eax
  800557:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80055f:	e9 a3 00 00 00       	jmp    800607 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 10                	mov    (%eax),%edx
  800569:	8b 48 04             	mov    0x4(%eax),%ecx
  80056c:	8d 40 08             	lea    0x8(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800572:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800577:	e9 8b 00 00 00       	jmp    800607 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 10                	mov    (%eax),%edx
  800581:	b9 00 00 00 00       	mov    $0x0,%ecx
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800591:	eb 74                	jmp    800607 <vprintfmt+0x38c>
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7f 1b                	jg     8005b3 <vprintfmt+0x338>
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	74 2c                	je     8005c8 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ac:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005b1:	eb 54                	jmp    800607 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8b 10                	mov    (%eax),%edx
  8005b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bb:	8d 40 08             	lea    0x8(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005c1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005c6:	eb 3f                	jmp    800607 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005d8:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005dd:	eb 28                	jmp    800607 <vprintfmt+0x38c>
			putch('0', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	53                   	push   %ebx
  8005e3:	6a 30                	push   $0x30
  8005e5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e7:	83 c4 08             	add    $0x8,%esp
  8005ea:	53                   	push   %ebx
  8005eb:	6a 78                	push   $0x78
  8005ed:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005f9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800602:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80060e:	57                   	push   %edi
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	50                   	push   %eax
  800613:	51                   	push   %ecx
  800614:	52                   	push   %edx
  800615:	89 da                	mov    %ebx,%edx
  800617:	89 f0                	mov    %esi,%eax
  800619:	e8 72 fb ff ff       	call   800190 <printnum>
			break;
  80061e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800624:	83 c7 01             	add    $0x1,%edi
  800627:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062b:	83 f8 25             	cmp    $0x25,%eax
  80062e:	0f 84 62 fc ff ff    	je     800296 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800634:	85 c0                	test   %eax,%eax
  800636:	0f 84 8b 00 00 00    	je     8006c7 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	50                   	push   %eax
  800641:	ff d6                	call   *%esi
  800643:	83 c4 10             	add    $0x10,%esp
  800646:	eb dc                	jmp    800624 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800648:	83 f9 01             	cmp    $0x1,%ecx
  80064b:	7f 1b                	jg     800668 <vprintfmt+0x3ed>
	else if (lflag)
  80064d:	85 c9                	test   %ecx,%ecx
  80064f:	74 2c                	je     80067d <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800661:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800666:	eb 9f                	jmp    800607 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	8b 48 04             	mov    0x4(%eax),%ecx
  800670:	8d 40 08             	lea    0x8(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800676:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80067b:	eb 8a                	jmp    800607 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	b9 00 00 00 00       	mov    $0x0,%ecx
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800692:	e9 70 ff ff ff       	jmp    800607 <vprintfmt+0x38c>
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 25                	push   $0x25
  80069d:	ff d6                	call   *%esi
			break;
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	e9 7a ff ff ff       	jmp    800621 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 25                	push   $0x25
  8006ad:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	89 f8                	mov    %edi,%eax
  8006b4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b8:	74 05                	je     8006bf <vprintfmt+0x444>
  8006ba:	83 e8 01             	sub    $0x1,%eax
  8006bd:	eb f5                	jmp    8006b4 <vprintfmt+0x439>
  8006bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c2:	e9 5a ff ff ff       	jmp    800621 <vprintfmt+0x3a6>
}
  8006c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5f                   	pop    %edi
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cf:	f3 0f 1e fb          	endbr32 
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 18             	sub    $0x18,%esp
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 26                	je     80071a <vsnprintf+0x4b>
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	7e 22                	jle    80071a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f8:	ff 75 14             	pushl  0x14(%ebp)
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	68 39 02 80 00       	push   $0x800239
  800707:	e8 6f fb ff ff       	call   80027b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	83 c4 10             	add    $0x10,%esp
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    
		return -E_INVAL;
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071f:	eb f7                	jmp    800718 <vsnprintf+0x49>

00800721 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800721:	f3 0f 1e fb          	endbr32 
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072e:	50                   	push   %eax
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	ff 75 08             	pushl  0x8(%ebp)
  800738:	e8 92 ff ff ff       	call   8006cf <vsnprintf>
	va_end(ap);

	return rc;
}
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073f:	f3 0f 1e fb          	endbr32 
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800749:	b8 00 00 00 00       	mov    $0x0,%eax
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	74 05                	je     800759 <strlen+0x1a>
		n++;
  800754:	83 c0 01             	add    $0x1,%eax
  800757:	eb f5                	jmp    80074e <strlen+0xf>
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075b:	f3 0f 1e fb          	endbr32 
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800765:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	b8 00 00 00 00       	mov    $0x0,%eax
  80076d:	39 d0                	cmp    %edx,%eax
  80076f:	74 0d                	je     80077e <strnlen+0x23>
  800771:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800775:	74 05                	je     80077c <strnlen+0x21>
		n++;
  800777:	83 c0 01             	add    $0x1,%eax
  80077a:	eb f1                	jmp    80076d <strnlen+0x12>
  80077c:	89 c2                	mov    %eax,%edx
	return n;
}
  80077e:	89 d0                	mov    %edx,%eax
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800782:	f3 0f 1e fb          	endbr32 
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	53                   	push   %ebx
  80078a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800799:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80079c:	83 c0 01             	add    $0x1,%eax
  80079f:	84 d2                	test   %dl,%dl
  8007a1:	75 f2                	jne    800795 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007a3:	89 c8                	mov    %ecx,%eax
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a8:	f3 0f 1e fb          	endbr32 
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	83 ec 10             	sub    $0x10,%esp
  8007b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b6:	53                   	push   %ebx
  8007b7:	e8 83 ff ff ff       	call   80073f <strlen>
  8007bc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	01 d8                	add    %ebx,%eax
  8007c4:	50                   	push   %eax
  8007c5:	e8 b8 ff ff ff       	call   800782 <strcpy>
	return dst;
}
  8007ca:	89 d8                	mov    %ebx,%eax
  8007cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d1:	f3 0f 1e fb          	endbr32 
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e0:	89 f3                	mov    %esi,%ebx
  8007e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	39 d8                	cmp    %ebx,%eax
  8007e9:	74 11                	je     8007fc <strncpy+0x2b>
		*dst++ = *src;
  8007eb:	83 c0 01             	add    $0x1,%eax
  8007ee:	0f b6 0a             	movzbl (%edx),%ecx
  8007f1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f4:	80 f9 01             	cmp    $0x1,%cl
  8007f7:	83 da ff             	sbb    $0xffffffff,%edx
  8007fa:	eb eb                	jmp    8007e7 <strncpy+0x16>
	}
	return ret;
}
  8007fc:	89 f0                	mov    %esi,%eax
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800802:	f3 0f 1e fb          	endbr32 
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
  800814:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	74 21                	je     80083b <strlcpy+0x39>
  80081a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800820:	39 c2                	cmp    %eax,%edx
  800822:	74 14                	je     800838 <strlcpy+0x36>
  800824:	0f b6 19             	movzbl (%ecx),%ebx
  800827:	84 db                	test   %bl,%bl
  800829:	74 0b                	je     800836 <strlcpy+0x34>
			*dst++ = *src++;
  80082b:	83 c1 01             	add    $0x1,%ecx
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	88 5a ff             	mov    %bl,-0x1(%edx)
  800834:	eb ea                	jmp    800820 <strlcpy+0x1e>
  800836:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800838:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083b:	29 f0                	sub    %esi,%eax
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800841:	f3 0f 1e fb          	endbr32 
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084e:	0f b6 01             	movzbl (%ecx),%eax
  800851:	84 c0                	test   %al,%al
  800853:	74 0c                	je     800861 <strcmp+0x20>
  800855:	3a 02                	cmp    (%edx),%al
  800857:	75 08                	jne    800861 <strcmp+0x20>
		p++, q++;
  800859:	83 c1 01             	add    $0x1,%ecx
  80085c:	83 c2 01             	add    $0x1,%edx
  80085f:	eb ed                	jmp    80084e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800861:	0f b6 c0             	movzbl %al,%eax
  800864:	0f b6 12             	movzbl (%edx),%edx
  800867:	29 d0                	sub    %edx,%eax
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086b:	f3 0f 1e fb          	endbr32 
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	89 c3                	mov    %eax,%ebx
  80087b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087e:	eb 06                	jmp    800886 <strncmp+0x1b>
		n--, p++, q++;
  800880:	83 c0 01             	add    $0x1,%eax
  800883:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800886:	39 d8                	cmp    %ebx,%eax
  800888:	74 16                	je     8008a0 <strncmp+0x35>
  80088a:	0f b6 08             	movzbl (%eax),%ecx
  80088d:	84 c9                	test   %cl,%cl
  80088f:	74 04                	je     800895 <strncmp+0x2a>
  800891:	3a 0a                	cmp    (%edx),%cl
  800893:	74 eb                	je     800880 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800895:	0f b6 00             	movzbl (%eax),%eax
  800898:	0f b6 12             	movzbl (%edx),%edx
  80089b:	29 d0                	sub    %edx,%eax
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    
		return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	eb f6                	jmp    80089d <strncmp+0x32>

008008a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a7:	f3 0f 1e fb          	endbr32 
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b5:	0f b6 10             	movzbl (%eax),%edx
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	74 09                	je     8008c5 <strchr+0x1e>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 0a                	je     8008ca <strchr+0x23>
	for (; *s; s++)
  8008c0:	83 c0 01             	add    $0x1,%eax
  8008c3:	eb f0                	jmp    8008b5 <strchr+0xe>
			return (char *) s;
	return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8008d6:	6a 78                	push   $0x78
  8008d8:	ff 75 08             	pushl  0x8(%ebp)
  8008db:	e8 c7 ff ff ff       	call   8008a7 <strchr>
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8008eb:	eb 0d                	jmp    8008fa <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8008ed:	c1 e0 04             	shl    $0x4,%eax
  8008f0:	0f be d2             	movsbl %dl,%edx
  8008f3:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8008f7:	83 c1 01             	add    $0x1,%ecx
  8008fa:	0f b6 11             	movzbl (%ecx),%edx
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	74 11                	je     800912 <atox+0x46>
		if (*p>='a'){
  800901:	80 fa 60             	cmp    $0x60,%dl
  800904:	7e e7                	jle    8008ed <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800906:	c1 e0 04             	shl    $0x4,%eax
  800909:	0f be d2             	movsbl %dl,%edx
  80090c:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800910:	eb e5                	jmp    8008f7 <atox+0x2b>
	}

	return v;

}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800914:	f3 0f 1e fb          	endbr32 
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800922:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 09                	je     800932 <strfind+0x1e>
  800929:	84 d2                	test   %dl,%dl
  80092b:	74 05                	je     800932 <strfind+0x1e>
	for (; *s; s++)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	eb f0                	jmp    800922 <strfind+0xe>
			break;
	return (char *) s;
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800934:	f3 0f 1e fb          	endbr32 
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 31                	je     800979 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	89 f8                	mov    %edi,%eax
  80094a:	09 c8                	or     %ecx,%eax
  80094c:	a8 03                	test   $0x3,%al
  80094e:	75 23                	jne    800973 <memset+0x3f>
		c &= 0xFF;
  800950:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800954:	89 d3                	mov    %edx,%ebx
  800956:	c1 e3 08             	shl    $0x8,%ebx
  800959:	89 d0                	mov    %edx,%eax
  80095b:	c1 e0 18             	shl    $0x18,%eax
  80095e:	89 d6                	mov    %edx,%esi
  800960:	c1 e6 10             	shl    $0x10,%esi
  800963:	09 f0                	or     %esi,%eax
  800965:	09 c2                	or     %eax,%edx
  800967:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800969:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	fc                   	cld    
  80096f:	f3 ab                	rep stos %eax,%es:(%edi)
  800971:	eb 06                	jmp    800979 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	fc                   	cld    
  800977:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800979:	89 f8                	mov    %edi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	f3 0f 1e fb          	endbr32 
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 32                	jae    8009c8 <memmove+0x48>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 c2                	cmp    %eax,%edx
  80099b:	76 2b                	jbe    8009c8 <memmove+0x48>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 fe                	mov    %edi,%esi
  8009a2:	09 ce                	or     %ecx,%esi
  8009a4:	09 d6                	or     %edx,%esi
  8009a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ac:	75 0e                	jne    8009bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ae:	83 ef 04             	sub    $0x4,%edi
  8009b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009b7:	fd                   	std    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 09                	jmp    8009c5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bc:	83 ef 01             	sub    $0x1,%edi
  8009bf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c5:	fc                   	cld    
  8009c6:	eb 1a                	jmp    8009e2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c8:	89 c2                	mov    %eax,%edx
  8009ca:	09 ca                	or     %ecx,%edx
  8009cc:	09 f2                	or     %esi,%edx
  8009ce:	f6 c2 03             	test   $0x3,%dl
  8009d1:	75 0a                	jne    8009dd <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 05                	jmp    8009e2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e6:	f3 0f 1e fb          	endbr32 
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 82 ff ff ff       	call   800980 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	f3 0f 1e fb          	endbr32 
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0f:	89 c6                	mov    %eax,%esi
  800a11:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a14:	39 f0                	cmp    %esi,%eax
  800a16:	74 1c                	je     800a34 <memcmp+0x34>
		if (*s1 != *s2)
  800a18:	0f b6 08             	movzbl (%eax),%ecx
  800a1b:	0f b6 1a             	movzbl (%edx),%ebx
  800a1e:	38 d9                	cmp    %bl,%cl
  800a20:	75 08                	jne    800a2a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	83 c2 01             	add    $0x1,%edx
  800a28:	eb ea                	jmp    800a14 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a2a:	0f b6 c1             	movzbl %cl,%eax
  800a2d:	0f b6 db             	movzbl %bl,%ebx
  800a30:	29 d8                	sub    %ebx,%eax
  800a32:	eb 05                	jmp    800a39 <memcmp+0x39>
	}

	return 0;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3d:	f3 0f 1e fb          	endbr32 
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	73 09                	jae    800a5c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a53:	38 08                	cmp    %cl,(%eax)
  800a55:	74 05                	je     800a5c <memfind+0x1f>
	for (; s < ends; s++)
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	eb f3                	jmp    800a4f <memfind+0x12>
			break;
	return (void *) s;
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	f3 0f 1e fb          	endbr32 
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	eb 03                	jmp    800a73 <strtol+0x15>
		s++;
  800a70:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a73:	0f b6 01             	movzbl (%ecx),%eax
  800a76:	3c 20                	cmp    $0x20,%al
  800a78:	74 f6                	je     800a70 <strtol+0x12>
  800a7a:	3c 09                	cmp    $0x9,%al
  800a7c:	74 f2                	je     800a70 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a7e:	3c 2b                	cmp    $0x2b,%al
  800a80:	74 2a                	je     800aac <strtol+0x4e>
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	74 2b                	je     800ab6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a91:	75 0f                	jne    800aa2 <strtol+0x44>
  800a93:	80 39 30             	cmpb   $0x30,(%ecx)
  800a96:	74 28                	je     800ac0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9f:	0f 44 d8             	cmove  %eax,%ebx
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aaa:	eb 46                	jmp    800af2 <strtol+0x94>
		s++;
  800aac:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab4:	eb d5                	jmp    800a8b <strtol+0x2d>
		s++, neg = 1;
  800ab6:	83 c1 01             	add    $0x1,%ecx
  800ab9:	bf 01 00 00 00       	mov    $0x1,%edi
  800abe:	eb cb                	jmp    800a8b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac4:	74 0e                	je     800ad4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ac6:	85 db                	test   %ebx,%ebx
  800ac8:	75 d8                	jne    800aa2 <strtol+0x44>
		s++, base = 8;
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad2:	eb ce                	jmp    800aa2 <strtol+0x44>
		s += 2, base = 16;
  800ad4:	83 c1 02             	add    $0x2,%ecx
  800ad7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adc:	eb c4                	jmp    800aa2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae7:	7d 3a                	jge    800b23 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af2:	0f b6 11             	movzbl (%ecx),%edx
  800af5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 09             	cmp    $0x9,%bl
  800afd:	76 df                	jbe    800ade <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aff:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b02:	89 f3                	mov    %esi,%ebx
  800b04:	80 fb 19             	cmp    $0x19,%bl
  800b07:	77 08                	ja     800b11 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b09:	0f be d2             	movsbl %dl,%edx
  800b0c:	83 ea 57             	sub    $0x57,%edx
  800b0f:	eb d3                	jmp    800ae4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b11:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b14:	89 f3                	mov    %esi,%ebx
  800b16:	80 fb 19             	cmp    $0x19,%bl
  800b19:	77 08                	ja     800b23 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1b:	0f be d2             	movsbl %dl,%edx
  800b1e:	83 ea 37             	sub    $0x37,%edx
  800b21:	eb c1                	jmp    800ae4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b27:	74 05                	je     800b2e <strtol+0xd0>
		*endptr = (char *) s;
  800b29:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	f7 da                	neg    %edx
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 45 c2             	cmovne %edx,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	f3 0f 1e fb          	endbr32 
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b81:	f3 0f 1e fb          	endbr32 
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	b8 03 00 00 00       	mov    $0x3,%eax
  800b98:	89 cb                	mov    %ecx,%ebx
  800b9a:	89 cf                	mov    %ecx,%edi
  800b9c:	89 ce                	mov    %ecx,%esi
  800b9e:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba5:	f3 0f 1e fb          	endbr32 
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800baf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb4:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb9:	89 d1                	mov    %edx,%ecx
  800bbb:	89 d3                	mov    %edx,%ebx
  800bbd:	89 d7                	mov    %edx,%edi
  800bbf:	89 d6                	mov    %edx,%esi
  800bc1:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_yield>:

void
sys_yield(void)
{
  800bc8:	f3 0f 1e fb          	endbr32 
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf5:	be 00 00 00 00       	mov    $0x0,%esi
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	b8 04 00 00 00       	mov    $0x4,%eax
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	89 f7                	mov    %esi,%edi
  800c0a:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c11:	f3 0f 1e fb          	endbr32 
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	b8 05 00 00 00       	mov    $0x5,%eax
  800c26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2f:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c36:	f3 0f 1e fb          	endbr32 
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c50:	89 df                	mov    %ebx,%edi
  800c52:	89 de                	mov    %ebx,%esi
  800c54:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5b:	f3 0f 1e fb          	endbr32 
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	b8 08 00 00 00       	mov    $0x8,%eax
  800c75:	89 df                	mov    %ebx,%edi
  800c77:	89 de                	mov    %ebx,%esi
  800c79:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c80:	f3 0f 1e fb          	endbr32 
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cca:	f3 0f 1e fb          	endbr32 
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf1:	f3 0f 1e fb          	endbr32 
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d08:	89 cb                	mov    %ecx,%ebx
  800d0a:	89 cf                	mov    %ecx,%edi
  800d0c:	89 ce                	mov    %ecx,%esi
  800d0e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d15:	f3 0f 1e fb          	endbr32 
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d24:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d29:	89 d1                	mov    %edx,%ecx
  800d2b:	89 d3                	mov    %edx,%ebx
  800d2d:	89 d7                	mov    %edx,%edi
  800d2f:	89 d6                	mov    %edx,%esi
  800d31:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d38:	f3 0f 1e fb          	endbr32 
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d52:	89 df                	mov    %ebx,%edi
  800d54:	89 de                	mov    %ebx,%esi
  800d56:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800d5d:	f3 0f 1e fb          	endbr32 
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d72:	b8 10 00 00 00       	mov    $0x10,%eax
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d82:	f3 0f 1e fb          	endbr32 
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d91:	c1 e8 0c             	shr    $0xc,%eax
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d96:	f3 0f 1e fb          	endbr32 
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800da5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800daa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db1:	f3 0f 1e fb          	endbr32 
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	c1 ea 16             	shr    $0x16,%edx
  800dc2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc9:	f6 c2 01             	test   $0x1,%dl
  800dcc:	74 2d                	je     800dfb <fd_alloc+0x4a>
  800dce:	89 c2                	mov    %eax,%edx
  800dd0:	c1 ea 0c             	shr    $0xc,%edx
  800dd3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dda:	f6 c2 01             	test   $0x1,%dl
  800ddd:	74 1c                	je     800dfb <fd_alloc+0x4a>
  800ddf:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800de4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800de9:	75 d2                	jne    800dbd <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800df4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800df9:	eb 0a                	jmp    800e05 <fd_alloc+0x54>
			*fd_store = fd;
  800dfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfe:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e07:	f3 0f 1e fb          	endbr32 
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e11:	83 f8 1f             	cmp    $0x1f,%eax
  800e14:	77 30                	ja     800e46 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e16:	c1 e0 0c             	shl    $0xc,%eax
  800e19:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e1e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e24:	f6 c2 01             	test   $0x1,%dl
  800e27:	74 24                	je     800e4d <fd_lookup+0x46>
  800e29:	89 c2                	mov    %eax,%edx
  800e2b:	c1 ea 0c             	shr    $0xc,%edx
  800e2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e35:	f6 c2 01             	test   $0x1,%dl
  800e38:	74 1a                	je     800e54 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3d:	89 02                	mov    %eax,(%edx)
	return 0;
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    
		return -E_INVAL;
  800e46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4b:	eb f7                	jmp    800e44 <fd_lookup+0x3d>
		return -E_INVAL;
  800e4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e52:	eb f0                	jmp    800e44 <fd_lookup+0x3d>
  800e54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e59:	eb e9                	jmp    800e44 <fd_lookup+0x3d>

00800e5b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e5b:	f3 0f 1e fb          	endbr32 
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800e68:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6d:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e72:	39 08                	cmp    %ecx,(%eax)
  800e74:	74 38                	je     800eae <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800e76:	83 c2 01             	add    $0x1,%edx
  800e79:	8b 04 95 3c 27 80 00 	mov    0x80273c(,%edx,4),%eax
  800e80:	85 c0                	test   %eax,%eax
  800e82:	75 ee                	jne    800e72 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e84:	a1 08 40 80 00       	mov    0x804008,%eax
  800e89:	8b 40 48             	mov    0x48(%eax),%eax
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	51                   	push   %ecx
  800e90:	50                   	push   %eax
  800e91:	68 c0 26 80 00       	push   $0x8026c0
  800e96:	e8 dd f2 ff ff       	call   800178 <cprintf>
	*dev = 0;
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    
			*dev = devtab[i];
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	eb f2                	jmp    800eac <dev_lookup+0x51>

00800eba <fd_close>:
{
  800eba:	f3 0f 1e fb          	endbr32 
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 24             	sub    $0x24,%esp
  800ec7:	8b 75 08             	mov    0x8(%ebp),%esi
  800eca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ecd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed0:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eda:	50                   	push   %eax
  800edb:	e8 27 ff ff ff       	call   800e07 <fd_lookup>
  800ee0:	89 c3                	mov    %eax,%ebx
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	78 05                	js     800eee <fd_close+0x34>
	    || fd != fd2)
  800ee9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800eec:	74 16                	je     800f04 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800eee:	89 f8                	mov    %edi,%eax
  800ef0:	84 c0                	test   %al,%al
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	0f 44 d8             	cmove  %eax,%ebx
}
  800efa:	89 d8                	mov    %ebx,%eax
  800efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 36                	pushl  (%esi)
  800f0d:	e8 49 ff ff ff       	call   800e5b <dev_lookup>
  800f12:	89 c3                	mov    %eax,%ebx
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 1a                	js     800f35 <fd_close+0x7b>
		if (dev->dev_close)
  800f1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f1e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f21:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	74 0b                	je     800f35 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	56                   	push   %esi
  800f2e:	ff d0                	call   *%eax
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	56                   	push   %esi
  800f39:	6a 00                	push   $0x0
  800f3b:	e8 f6 fc ff ff       	call   800c36 <sys_page_unmap>
	return r;
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	eb b5                	jmp    800efa <fd_close+0x40>

00800f45 <close>:

int
close(int fdnum)
{
  800f45:	f3 0f 1e fb          	endbr32 
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	ff 75 08             	pushl  0x8(%ebp)
  800f56:	e8 ac fe ff ff       	call   800e07 <fd_lookup>
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 02                	jns    800f64 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    
		return fd_close(fd, 1);
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	6a 01                	push   $0x1
  800f69:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6c:	e8 49 ff ff ff       	call   800eba <fd_close>
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	eb ec                	jmp    800f62 <close+0x1d>

00800f76 <close_all>:

void
close_all(void)
{
  800f76:	f3 0f 1e fb          	endbr32 
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	53                   	push   %ebx
  800f7e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f81:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	53                   	push   %ebx
  800f8a:	e8 b6 ff ff ff       	call   800f45 <close>
	for (i = 0; i < MAXFD; i++)
  800f8f:	83 c3 01             	add    $0x1,%ebx
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	83 fb 20             	cmp    $0x20,%ebx
  800f98:	75 ec                	jne    800f86 <close_all+0x10>
}
  800f9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f9f:	f3 0f 1e fb          	endbr32 
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	ff 75 08             	pushl  0x8(%ebp)
  800fb3:	e8 4f fe ff ff       	call   800e07 <fd_lookup>
  800fb8:	89 c3                	mov    %eax,%ebx
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	0f 88 81 00 00 00    	js     801046 <dup+0xa7>
		return r;
	close(newfdnum);
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	ff 75 0c             	pushl  0xc(%ebp)
  800fcb:	e8 75 ff ff ff       	call   800f45 <close>

	newfd = INDEX2FD(newfdnum);
  800fd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fd3:	c1 e6 0c             	shl    $0xc,%esi
  800fd6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fdc:	83 c4 04             	add    $0x4,%esp
  800fdf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe2:	e8 af fd ff ff       	call   800d96 <fd2data>
  800fe7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fe9:	89 34 24             	mov    %esi,(%esp)
  800fec:	e8 a5 fd ff ff       	call   800d96 <fd2data>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ff6:	89 d8                	mov    %ebx,%eax
  800ff8:	c1 e8 16             	shr    $0x16,%eax
  800ffb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801002:	a8 01                	test   $0x1,%al
  801004:	74 11                	je     801017 <dup+0x78>
  801006:	89 d8                	mov    %ebx,%eax
  801008:	c1 e8 0c             	shr    $0xc,%eax
  80100b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801012:	f6 c2 01             	test   $0x1,%dl
  801015:	75 39                	jne    801050 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801017:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80101a:	89 d0                	mov    %edx,%eax
  80101c:	c1 e8 0c             	shr    $0xc,%eax
  80101f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	25 07 0e 00 00       	and    $0xe07,%eax
  80102e:	50                   	push   %eax
  80102f:	56                   	push   %esi
  801030:	6a 00                	push   $0x0
  801032:	52                   	push   %edx
  801033:	6a 00                	push   $0x0
  801035:	e8 d7 fb ff ff       	call   800c11 <sys_page_map>
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	83 c4 20             	add    $0x20,%esp
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 31                	js     801074 <dup+0xd5>
		goto err;

	return newfdnum;
  801043:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801046:	89 d8                	mov    %ebx,%eax
  801048:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801050:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	25 07 0e 00 00       	and    $0xe07,%eax
  80105f:	50                   	push   %eax
  801060:	57                   	push   %edi
  801061:	6a 00                	push   $0x0
  801063:	53                   	push   %ebx
  801064:	6a 00                	push   $0x0
  801066:	e8 a6 fb ff ff       	call   800c11 <sys_page_map>
  80106b:	89 c3                	mov    %eax,%ebx
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	79 a3                	jns    801017 <dup+0x78>
	sys_page_unmap(0, newfd);
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	56                   	push   %esi
  801078:	6a 00                	push   $0x0
  80107a:	e8 b7 fb ff ff       	call   800c36 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80107f:	83 c4 08             	add    $0x8,%esp
  801082:	57                   	push   %edi
  801083:	6a 00                	push   $0x0
  801085:	e8 ac fb ff ff       	call   800c36 <sys_page_unmap>
	return r;
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	eb b7                	jmp    801046 <dup+0xa7>

0080108f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80108f:	f3 0f 1e fb          	endbr32 
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	53                   	push   %ebx
  801097:	83 ec 1c             	sub    $0x1c,%esp
  80109a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80109d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a0:	50                   	push   %eax
  8010a1:	53                   	push   %ebx
  8010a2:	e8 60 fd ff ff       	call   800e07 <fd_lookup>
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 3f                	js     8010ed <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b8:	ff 30                	pushl  (%eax)
  8010ba:	e8 9c fd ff ff       	call   800e5b <dev_lookup>
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 27                	js     8010ed <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010c9:	8b 42 08             	mov    0x8(%edx),%eax
  8010cc:	83 e0 03             	and    $0x3,%eax
  8010cf:	83 f8 01             	cmp    $0x1,%eax
  8010d2:	74 1e                	je     8010f2 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d7:	8b 40 08             	mov    0x8(%eax),%eax
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	74 35                	je     801113 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010de:	83 ec 04             	sub    $0x4,%esp
  8010e1:	ff 75 10             	pushl  0x10(%ebp)
  8010e4:	ff 75 0c             	pushl  0xc(%ebp)
  8010e7:	52                   	push   %edx
  8010e8:	ff d0                	call   *%eax
  8010ea:	83 c4 10             	add    $0x10,%esp
}
  8010ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f7:	8b 40 48             	mov    0x48(%eax),%eax
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	53                   	push   %ebx
  8010fe:	50                   	push   %eax
  8010ff:	68 01 27 80 00       	push   $0x802701
  801104:	e8 6f f0 ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801111:	eb da                	jmp    8010ed <read+0x5e>
		return -E_NOT_SUPP;
  801113:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801118:	eb d3                	jmp    8010ed <read+0x5e>

0080111a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80111a:	f3 0f 1e fb          	endbr32 
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801132:	eb 02                	jmp    801136 <readn+0x1c>
  801134:	01 c3                	add    %eax,%ebx
  801136:	39 f3                	cmp    %esi,%ebx
  801138:	73 21                	jae    80115b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	89 f0                	mov    %esi,%eax
  80113f:	29 d8                	sub    %ebx,%eax
  801141:	50                   	push   %eax
  801142:	89 d8                	mov    %ebx,%eax
  801144:	03 45 0c             	add    0xc(%ebp),%eax
  801147:	50                   	push   %eax
  801148:	57                   	push   %edi
  801149:	e8 41 ff ff ff       	call   80108f <read>
		if (m < 0)
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 04                	js     801159 <readn+0x3f>
			return m;
		if (m == 0)
  801155:	75 dd                	jne    801134 <readn+0x1a>
  801157:	eb 02                	jmp    80115b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801159:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801165:	f3 0f 1e fb          	endbr32 
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	53                   	push   %ebx
  80116d:	83 ec 1c             	sub    $0x1c,%esp
  801170:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801173:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	53                   	push   %ebx
  801178:	e8 8a fc ff ff       	call   800e07 <fd_lookup>
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	78 3a                	js     8011be <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118e:	ff 30                	pushl  (%eax)
  801190:	e8 c6 fc ff ff       	call   800e5b <dev_lookup>
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 22                	js     8011be <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80119c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a3:	74 1e                	je     8011c3 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8011ab:	85 d2                	test   %edx,%edx
  8011ad:	74 35                	je     8011e4 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011af:	83 ec 04             	sub    $0x4,%esp
  8011b2:	ff 75 10             	pushl  0x10(%ebp)
  8011b5:	ff 75 0c             	pushl  0xc(%ebp)
  8011b8:	50                   	push   %eax
  8011b9:	ff d2                	call   *%edx
  8011bb:	83 c4 10             	add    $0x10,%esp
}
  8011be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c8:	8b 40 48             	mov    0x48(%eax),%eax
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	53                   	push   %ebx
  8011cf:	50                   	push   %eax
  8011d0:	68 1d 27 80 00       	push   $0x80271d
  8011d5:	e8 9e ef ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e2:	eb da                	jmp    8011be <write+0x59>
		return -E_NOT_SUPP;
  8011e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011e9:	eb d3                	jmp    8011be <write+0x59>

008011eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8011eb:	f3 0f 1e fb          	endbr32 
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 06 fc ff ff       	call   800e07 <fd_lookup>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 0e                	js     801216 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801208:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801218:	f3 0f 1e fb          	endbr32 
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	53                   	push   %ebx
  801220:	83 ec 1c             	sub    $0x1c,%esp
  801223:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801226:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	53                   	push   %ebx
  80122b:	e8 d7 fb ff ff       	call   800e07 <fd_lookup>
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	78 37                	js     80126e <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	ff 30                	pushl  (%eax)
  801243:	e8 13 fc ff ff       	call   800e5b <dev_lookup>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 1f                	js     80126e <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801256:	74 1b                	je     801273 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801258:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125b:	8b 52 18             	mov    0x18(%edx),%edx
  80125e:	85 d2                	test   %edx,%edx
  801260:	74 32                	je     801294 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	ff 75 0c             	pushl  0xc(%ebp)
  801268:	50                   	push   %eax
  801269:	ff d2                	call   *%edx
  80126b:	83 c4 10             	add    $0x10,%esp
}
  80126e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801271:	c9                   	leave  
  801272:	c3                   	ret    
			thisenv->env_id, fdnum);
  801273:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801278:	8b 40 48             	mov    0x48(%eax),%eax
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	53                   	push   %ebx
  80127f:	50                   	push   %eax
  801280:	68 e0 26 80 00       	push   $0x8026e0
  801285:	e8 ee ee ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801292:	eb da                	jmp    80126e <ftruncate+0x56>
		return -E_NOT_SUPP;
  801294:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801299:	eb d3                	jmp    80126e <ftruncate+0x56>

0080129b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80129b:	f3 0f 1e fb          	endbr32 
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 1c             	sub    $0x1c,%esp
  8012a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	ff 75 08             	pushl  0x8(%ebp)
  8012b0:	e8 52 fb ff ff       	call   800e07 <fd_lookup>
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 4b                	js     801307 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bc:	83 ec 08             	sub    $0x8,%esp
  8012bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c2:	50                   	push   %eax
  8012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c6:	ff 30                	pushl  (%eax)
  8012c8:	e8 8e fb ff ff       	call   800e5b <dev_lookup>
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 33                	js     801307 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8012d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012db:	74 2f                	je     80130c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012e7:	00 00 00 
	stat->st_isdir = 0;
  8012ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f1:	00 00 00 
	stat->st_dev = dev;
  8012f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	53                   	push   %ebx
  8012fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801301:	ff 50 14             	call   *0x14(%eax)
  801304:	83 c4 10             	add    $0x10,%esp
}
  801307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    
		return -E_NOT_SUPP;
  80130c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801311:	eb f4                	jmp    801307 <fstat+0x6c>

00801313 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801313:	f3 0f 1e fb          	endbr32 
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	56                   	push   %esi
  80131b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	6a 00                	push   $0x0
  801321:	ff 75 08             	pushl  0x8(%ebp)
  801324:	e8 01 02 00 00       	call   80152a <open>
  801329:	89 c3                	mov    %eax,%ebx
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	85 c0                	test   %eax,%eax
  801330:	78 1b                	js     80134d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	ff 75 0c             	pushl  0xc(%ebp)
  801338:	50                   	push   %eax
  801339:	e8 5d ff ff ff       	call   80129b <fstat>
  80133e:	89 c6                	mov    %eax,%esi
	close(fd);
  801340:	89 1c 24             	mov    %ebx,(%esp)
  801343:	e8 fd fb ff ff       	call   800f45 <close>
	return r;
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	89 f3                	mov    %esi,%ebx
}
  80134d:	89 d8                	mov    %ebx,%eax
  80134f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801352:	5b                   	pop    %ebx
  801353:	5e                   	pop    %esi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	56                   	push   %esi
  80135a:	53                   	push   %ebx
  80135b:	89 c6                	mov    %eax,%esi
  80135d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80135f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801366:	74 27                	je     80138f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801368:	6a 07                	push   $0x7
  80136a:	68 00 50 80 00       	push   $0x805000
  80136f:	56                   	push   %esi
  801370:	ff 35 00 40 80 00    	pushl  0x804000
  801376:	e8 c6 0c 00 00       	call   802041 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80137b:	83 c4 0c             	add    $0xc,%esp
  80137e:	6a 00                	push   $0x0
  801380:	53                   	push   %ebx
  801381:	6a 00                	push   $0x0
  801383:	e8 4c 0c 00 00       	call   801fd4 <ipc_recv>
}
  801388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	6a 01                	push   $0x1
  801394:	e8 00 0d 00 00       	call   802099 <ipc_find_env>
  801399:	a3 00 40 80 00       	mov    %eax,0x804000
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	eb c5                	jmp    801368 <fsipc+0x12>

008013a3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013a3:	f3 0f 1e fb          	endbr32 
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c5:	b8 02 00 00 00       	mov    $0x2,%eax
  8013ca:	e8 87 ff ff ff       	call   801356 <fsipc>
}
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <devfile_flush>:
{
  8013d1:	f3 0f 1e fb          	endbr32 
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013db:	8b 45 08             	mov    0x8(%ebp),%eax
  8013de:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8013f0:	e8 61 ff ff ff       	call   801356 <fsipc>
}
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <devfile_stat>:
{
  8013f7:	f3 0f 1e fb          	endbr32 
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 04             	sub    $0x4,%esp
  801402:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	8b 40 0c             	mov    0xc(%eax),%eax
  80140b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801410:	ba 00 00 00 00       	mov    $0x0,%edx
  801415:	b8 05 00 00 00       	mov    $0x5,%eax
  80141a:	e8 37 ff ff ff       	call   801356 <fsipc>
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 2c                	js     80144f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	68 00 50 80 00       	push   $0x805000
  80142b:	53                   	push   %ebx
  80142c:	e8 51 f3 ff ff       	call   800782 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801431:	a1 80 50 80 00       	mov    0x805080,%eax
  801436:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80143c:	a1 84 50 80 00       	mov    0x805084,%eax
  801441:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <devfile_write>:
{
  801454:	f3 0f 1e fb          	endbr32 
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	8b 45 10             	mov    0x10(%ebp),%eax
  801461:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801466:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80146b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80146e:	8b 55 08             	mov    0x8(%ebp),%edx
  801471:	8b 52 0c             	mov    0xc(%edx),%edx
  801474:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80147a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80147f:	50                   	push   %eax
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	68 08 50 80 00       	push   $0x805008
  801488:	e8 f3 f4 ff ff       	call   800980 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80148d:	ba 00 00 00 00       	mov    $0x0,%edx
  801492:	b8 04 00 00 00       	mov    $0x4,%eax
  801497:	e8 ba fe ff ff       	call   801356 <fsipc>
}
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <devfile_read>:
{
  80149e:	f3 0f 1e fb          	endbr32 
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c5:	e8 8c fe ff ff       	call   801356 <fsipc>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 1f                	js     8014ef <devfile_read+0x51>
	assert(r <= n);
  8014d0:	39 f0                	cmp    %esi,%eax
  8014d2:	77 24                	ja     8014f8 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014d4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014d9:	7f 36                	jg     801511 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014db:	83 ec 04             	sub    $0x4,%esp
  8014de:	50                   	push   %eax
  8014df:	68 00 50 80 00       	push   $0x805000
  8014e4:	ff 75 0c             	pushl  0xc(%ebp)
  8014e7:	e8 94 f4 ff ff       	call   800980 <memmove>
	return r;
  8014ec:	83 c4 10             	add    $0x10,%esp
}
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    
	assert(r <= n);
  8014f8:	68 50 27 80 00       	push   $0x802750
  8014fd:	68 57 27 80 00       	push   $0x802757
  801502:	68 8c 00 00 00       	push   $0x8c
  801507:	68 6c 27 80 00       	push   $0x80276c
  80150c:	e8 79 0a 00 00       	call   801f8a <_panic>
	assert(r <= PGSIZE);
  801511:	68 77 27 80 00       	push   $0x802777
  801516:	68 57 27 80 00       	push   $0x802757
  80151b:	68 8d 00 00 00       	push   $0x8d
  801520:	68 6c 27 80 00       	push   $0x80276c
  801525:	e8 60 0a 00 00       	call   801f8a <_panic>

0080152a <open>:
{
  80152a:	f3 0f 1e fb          	endbr32 
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
  801533:	83 ec 1c             	sub    $0x1c,%esp
  801536:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801539:	56                   	push   %esi
  80153a:	e8 00 f2 ff ff       	call   80073f <strlen>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801547:	7f 6c                	jg     8015b5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801549:	83 ec 0c             	sub    $0xc,%esp
  80154c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	e8 5c f8 ff ff       	call   800db1 <fd_alloc>
  801555:	89 c3                	mov    %eax,%ebx
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 3c                	js     80159a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	56                   	push   %esi
  801562:	68 00 50 80 00       	push   $0x805000
  801567:	e8 16 f2 ff ff       	call   800782 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80156c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801574:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801577:	b8 01 00 00 00       	mov    $0x1,%eax
  80157c:	e8 d5 fd ff ff       	call   801356 <fsipc>
  801581:	89 c3                	mov    %eax,%ebx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 19                	js     8015a3 <open+0x79>
	return fd2num(fd);
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	ff 75 f4             	pushl  -0xc(%ebp)
  801590:	e8 ed f7 ff ff       	call   800d82 <fd2num>
  801595:	89 c3                	mov    %eax,%ebx
  801597:	83 c4 10             	add    $0x10,%esp
}
  80159a:	89 d8                	mov    %ebx,%eax
  80159c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5e                   	pop    %esi
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    
		fd_close(fd, 0);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	6a 00                	push   $0x0
  8015a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ab:	e8 0a f9 ff ff       	call   800eba <fd_close>
		return r;
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb e5                	jmp    80159a <open+0x70>
		return -E_BAD_PATH;
  8015b5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015ba:	eb de                	jmp    80159a <open+0x70>

008015bc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015bc:	f3 0f 1e fb          	endbr32 
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d0:	e8 81 fd ff ff       	call   801356 <fsipc>
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015d7:	f3 0f 1e fb          	endbr32 
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015e1:	68 e3 27 80 00       	push   $0x8027e3
  8015e6:	ff 75 0c             	pushl  0xc(%ebp)
  8015e9:	e8 94 f1 ff ff       	call   800782 <strcpy>
	return 0;
}
  8015ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <devsock_close>:
{
  8015f5:	f3 0f 1e fb          	endbr32 
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 10             	sub    $0x10,%esp
  801600:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801603:	53                   	push   %ebx
  801604:	e8 cd 0a 00 00       	call   8020d6 <pageref>
  801609:	89 c2                	mov    %eax,%edx
  80160b:	83 c4 10             	add    $0x10,%esp
		return 0;
  80160e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801613:	83 fa 01             	cmp    $0x1,%edx
  801616:	74 05                	je     80161d <devsock_close+0x28>
}
  801618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	ff 73 0c             	pushl  0xc(%ebx)
  801623:	e8 e3 02 00 00       	call   80190b <nsipc_close>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb eb                	jmp    801618 <devsock_close+0x23>

0080162d <devsock_write>:
{
  80162d:	f3 0f 1e fb          	endbr32 
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801637:	6a 00                	push   $0x0
  801639:	ff 75 10             	pushl  0x10(%ebp)
  80163c:	ff 75 0c             	pushl  0xc(%ebp)
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	ff 70 0c             	pushl  0xc(%eax)
  801645:	e8 b5 03 00 00       	call   8019ff <nsipc_send>
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <devsock_read>:
{
  80164c:	f3 0f 1e fb          	endbr32 
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801656:	6a 00                	push   $0x0
  801658:	ff 75 10             	pushl  0x10(%ebp)
  80165b:	ff 75 0c             	pushl  0xc(%ebp)
  80165e:	8b 45 08             	mov    0x8(%ebp),%eax
  801661:	ff 70 0c             	pushl  0xc(%eax)
  801664:	e8 1f 03 00 00       	call   801988 <nsipc_recv>
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <fd2sockid>:
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801671:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801674:	52                   	push   %edx
  801675:	50                   	push   %eax
  801676:	e8 8c f7 ff ff       	call   800e07 <fd_lookup>
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 10                	js     801692 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801685:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80168b:	39 08                	cmp    %ecx,(%eax)
  80168d:	75 05                	jne    801694 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80168f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    
		return -E_NOT_SUPP;
  801694:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801699:	eb f7                	jmp    801692 <fd2sockid+0x27>

0080169b <alloc_sockfd>:
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	56                   	push   %esi
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 1c             	sub    $0x1c,%esp
  8016a3:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	e8 03 f7 ff ff       	call   800db1 <fd_alloc>
  8016ae:	89 c3                	mov    %eax,%ebx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 43                	js     8016fa <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8016b7:	83 ec 04             	sub    $0x4,%esp
  8016ba:	68 07 04 00 00       	push   $0x407
  8016bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c2:	6a 00                	push   $0x0
  8016c4:	e8 22 f5 ff ff       	call   800beb <sys_page_alloc>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 28                	js     8016fa <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d5:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8016db:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016e7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016ea:	83 ec 0c             	sub    $0xc,%esp
  8016ed:	50                   	push   %eax
  8016ee:	e8 8f f6 ff ff       	call   800d82 <fd2num>
  8016f3:	89 c3                	mov    %eax,%ebx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb 0c                	jmp    801706 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8016fa:	83 ec 0c             	sub    $0xc,%esp
  8016fd:	56                   	push   %esi
  8016fe:	e8 08 02 00 00       	call   80190b <nsipc_close>
		return r;
  801703:	83 c4 10             	add    $0x10,%esp
}
  801706:	89 d8                	mov    %ebx,%eax
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <accept>:
{
  80170f:	f3 0f 1e fb          	endbr32 
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	e8 4a ff ff ff       	call   80166b <fd2sockid>
  801721:	85 c0                	test   %eax,%eax
  801723:	78 1b                	js     801740 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801725:	83 ec 04             	sub    $0x4,%esp
  801728:	ff 75 10             	pushl  0x10(%ebp)
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	50                   	push   %eax
  80172f:	e8 22 01 00 00       	call   801856 <nsipc_accept>
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	78 05                	js     801740 <accept+0x31>
	return alloc_sockfd(r);
  80173b:	e8 5b ff ff ff       	call   80169b <alloc_sockfd>
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <bind>:
{
  801742:	f3 0f 1e fb          	endbr32 
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	e8 17 ff ff ff       	call   80166b <fd2sockid>
  801754:	85 c0                	test   %eax,%eax
  801756:	78 12                	js     80176a <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801758:	83 ec 04             	sub    $0x4,%esp
  80175b:	ff 75 10             	pushl  0x10(%ebp)
  80175e:	ff 75 0c             	pushl  0xc(%ebp)
  801761:	50                   	push   %eax
  801762:	e8 45 01 00 00       	call   8018ac <nsipc_bind>
  801767:	83 c4 10             	add    $0x10,%esp
}
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <shutdown>:
{
  80176c:	f3 0f 1e fb          	endbr32 
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	e8 ed fe ff ff       	call   80166b <fd2sockid>
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 0f                	js     801791 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	ff 75 0c             	pushl  0xc(%ebp)
  801788:	50                   	push   %eax
  801789:	e8 57 01 00 00       	call   8018e5 <nsipc_shutdown>
  80178e:	83 c4 10             	add    $0x10,%esp
}
  801791:	c9                   	leave  
  801792:	c3                   	ret    

00801793 <connect>:
{
  801793:	f3 0f 1e fb          	endbr32 
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80179d:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a0:	e8 c6 fe ff ff       	call   80166b <fd2sockid>
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 12                	js     8017bb <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8017a9:	83 ec 04             	sub    $0x4,%esp
  8017ac:	ff 75 10             	pushl  0x10(%ebp)
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	50                   	push   %eax
  8017b3:	e8 71 01 00 00       	call   801929 <nsipc_connect>
  8017b8:	83 c4 10             	add    $0x10,%esp
}
  8017bb:	c9                   	leave  
  8017bc:	c3                   	ret    

008017bd <listen>:
{
  8017bd:	f3 0f 1e fb          	endbr32 
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	e8 9c fe ff ff       	call   80166b <fd2sockid>
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	78 0f                	js     8017e2 <listen+0x25>
	return nsipc_listen(r, backlog);
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	ff 75 0c             	pushl  0xc(%ebp)
  8017d9:	50                   	push   %eax
  8017da:	e8 83 01 00 00       	call   801962 <nsipc_listen>
  8017df:	83 c4 10             	add    $0x10,%esp
}
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <socket>:

int
socket(int domain, int type, int protocol)
{
  8017e4:	f3 0f 1e fb          	endbr32 
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8017ee:	ff 75 10             	pushl  0x10(%ebp)
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	ff 75 08             	pushl  0x8(%ebp)
  8017f7:	e8 65 02 00 00       	call   801a61 <nsipc_socket>
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 05                	js     801808 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801803:	e8 93 fe ff ff       	call   80169b <alloc_sockfd>
}
  801808:	c9                   	leave  
  801809:	c3                   	ret    

0080180a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	53                   	push   %ebx
  80180e:	83 ec 04             	sub    $0x4,%esp
  801811:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801813:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80181a:	74 26                	je     801842 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80181c:	6a 07                	push   $0x7
  80181e:	68 00 60 80 00       	push   $0x806000
  801823:	53                   	push   %ebx
  801824:	ff 35 04 40 80 00    	pushl  0x804004
  80182a:	e8 12 08 00 00       	call   802041 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80182f:	83 c4 0c             	add    $0xc,%esp
  801832:	6a 00                	push   $0x0
  801834:	6a 00                	push   $0x0
  801836:	6a 00                	push   $0x0
  801838:	e8 97 07 00 00       	call   801fd4 <ipc_recv>
}
  80183d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801840:	c9                   	leave  
  801841:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	6a 02                	push   $0x2
  801847:	e8 4d 08 00 00       	call   802099 <ipc_find_env>
  80184c:	a3 04 40 80 00       	mov    %eax,0x804004
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	eb c6                	jmp    80181c <nsipc+0x12>

00801856 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801856:	f3 0f 1e fb          	endbr32 
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80186a:	8b 06                	mov    (%esi),%eax
  80186c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801871:	b8 01 00 00 00       	mov    $0x1,%eax
  801876:	e8 8f ff ff ff       	call   80180a <nsipc>
  80187b:	89 c3                	mov    %eax,%ebx
  80187d:	85 c0                	test   %eax,%eax
  80187f:	79 09                	jns    80188a <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801881:	89 d8                	mov    %ebx,%eax
  801883:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801886:	5b                   	pop    %ebx
  801887:	5e                   	pop    %esi
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	ff 35 10 60 80 00    	pushl  0x806010
  801893:	68 00 60 80 00       	push   $0x806000
  801898:	ff 75 0c             	pushl  0xc(%ebp)
  80189b:	e8 e0 f0 ff ff       	call   800980 <memmove>
		*addrlen = ret->ret_addrlen;
  8018a0:	a1 10 60 80 00       	mov    0x806010,%eax
  8018a5:	89 06                	mov    %eax,(%esi)
  8018a7:	83 c4 10             	add    $0x10,%esp
	return r;
  8018aa:	eb d5                	jmp    801881 <nsipc_accept+0x2b>

008018ac <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018ac:	f3 0f 1e fb          	endbr32 
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	53                   	push   %ebx
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018c2:	53                   	push   %ebx
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	68 04 60 80 00       	push   $0x806004
  8018cb:	e8 b0 f0 ff ff       	call   800980 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8018d0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8018d6:	b8 02 00 00 00       	mov    $0x2,%eax
  8018db:	e8 2a ff ff ff       	call   80180a <nsipc>
}
  8018e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8018e5:	f3 0f 1e fb          	endbr32 
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8018f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fa:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8018ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801904:	e8 01 ff ff ff       	call   80180a <nsipc>
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <nsipc_close>:

int
nsipc_close(int s)
{
  80190b:	f3 0f 1e fb          	endbr32 
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80191d:	b8 04 00 00 00       	mov    $0x4,%eax
  801922:	e8 e3 fe ff ff       	call   80180a <nsipc>
}
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801929:	f3 0f 1e fb          	endbr32 
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	53                   	push   %ebx
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801937:	8b 45 08             	mov    0x8(%ebp),%eax
  80193a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80193f:	53                   	push   %ebx
  801940:	ff 75 0c             	pushl  0xc(%ebp)
  801943:	68 04 60 80 00       	push   $0x806004
  801948:	e8 33 f0 ff ff       	call   800980 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80194d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801953:	b8 05 00 00 00       	mov    $0x5,%eax
  801958:	e8 ad fe ff ff       	call   80180a <nsipc>
}
  80195d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801962:	f3 0f 1e fb          	endbr32 
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801974:	8b 45 0c             	mov    0xc(%ebp),%eax
  801977:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80197c:	b8 06 00 00 00       	mov    $0x6,%eax
  801981:	e8 84 fe ff ff       	call   80180a <nsipc>
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801988:	f3 0f 1e fb          	endbr32 
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	56                   	push   %esi
  801990:	53                   	push   %ebx
  801991:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80199c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a5:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019aa:	b8 07 00 00 00       	mov    $0x7,%eax
  8019af:	e8 56 fe ff ff       	call   80180a <nsipc>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 26                	js     8019e0 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8019ba:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8019c0:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8019c5:	0f 4e c6             	cmovle %esi,%eax
  8019c8:	39 c3                	cmp    %eax,%ebx
  8019ca:	7f 1d                	jg     8019e9 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	53                   	push   %ebx
  8019d0:	68 00 60 80 00       	push   $0x806000
  8019d5:	ff 75 0c             	pushl  0xc(%ebp)
  8019d8:	e8 a3 ef ff ff       	call   800980 <memmove>
  8019dd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8019e0:	89 d8                	mov    %ebx,%eax
  8019e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    
		assert(r < 1600 && r <= len);
  8019e9:	68 ef 27 80 00       	push   $0x8027ef
  8019ee:	68 57 27 80 00       	push   $0x802757
  8019f3:	6a 62                	push   $0x62
  8019f5:	68 04 28 80 00       	push   $0x802804
  8019fa:	e8 8b 05 00 00       	call   801f8a <_panic>

008019ff <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8019ff:	f3 0f 1e fb          	endbr32 
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	53                   	push   %ebx
  801a07:	83 ec 04             	sub    $0x4,%esp
  801a0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a10:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a15:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a1b:	7f 2e                	jg     801a4b <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a1d:	83 ec 04             	sub    $0x4,%esp
  801a20:	53                   	push   %ebx
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	68 0c 60 80 00       	push   $0x80600c
  801a29:	e8 52 ef ff ff       	call   800980 <memmove>
	nsipcbuf.send.req_size = size;
  801a2e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a34:	8b 45 14             	mov    0x14(%ebp),%eax
  801a37:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a3c:	b8 08 00 00 00       	mov    $0x8,%eax
  801a41:	e8 c4 fd ff ff       	call   80180a <nsipc>
}
  801a46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    
	assert(size < 1600);
  801a4b:	68 10 28 80 00       	push   $0x802810
  801a50:	68 57 27 80 00       	push   $0x802757
  801a55:	6a 6d                	push   $0x6d
  801a57:	68 04 28 80 00       	push   $0x802804
  801a5c:	e8 29 05 00 00       	call   801f8a <_panic>

00801a61 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a61:	f3 0f 1e fb          	endbr32 
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a76:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a83:	b8 09 00 00 00       	mov    $0x9,%eax
  801a88:	e8 7d fd ff ff       	call   80180a <nsipc>
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a8f:	f3 0f 1e fb          	endbr32 
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	ff 75 08             	pushl  0x8(%ebp)
  801aa1:	e8 f0 f2 ff ff       	call   800d96 <fd2data>
  801aa6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa8:	83 c4 08             	add    $0x8,%esp
  801aab:	68 1c 28 80 00       	push   $0x80281c
  801ab0:	53                   	push   %ebx
  801ab1:	e8 cc ec ff ff       	call   800782 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab6:	8b 46 04             	mov    0x4(%esi),%eax
  801ab9:	2b 06                	sub    (%esi),%eax
  801abb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ac1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac8:	00 00 00 
	stat->st_dev = &devpipe;
  801acb:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801ad2:	30 80 00 
	return 0;
}
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  801ada:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ae1:	f3 0f 1e fb          	endbr32 
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aef:	53                   	push   %ebx
  801af0:	6a 00                	push   $0x0
  801af2:	e8 3f f1 ff ff       	call   800c36 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801af7:	89 1c 24             	mov    %ebx,(%esp)
  801afa:	e8 97 f2 ff ff       	call   800d96 <fd2data>
  801aff:	83 c4 08             	add    $0x8,%esp
  801b02:	50                   	push   %eax
  801b03:	6a 00                	push   $0x0
  801b05:	e8 2c f1 ff ff       	call   800c36 <sys_page_unmap>
}
  801b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <_pipeisclosed>:
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	57                   	push   %edi
  801b13:	56                   	push   %esi
  801b14:	53                   	push   %ebx
  801b15:	83 ec 1c             	sub    $0x1c,%esp
  801b18:	89 c7                	mov    %eax,%edi
  801b1a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b1c:	a1 08 40 80 00       	mov    0x804008,%eax
  801b21:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	57                   	push   %edi
  801b28:	e8 a9 05 00 00       	call   8020d6 <pageref>
  801b2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b30:	89 34 24             	mov    %esi,(%esp)
  801b33:	e8 9e 05 00 00       	call   8020d6 <pageref>
		nn = thisenv->env_runs;
  801b38:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b3e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	39 cb                	cmp    %ecx,%ebx
  801b46:	74 1b                	je     801b63 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b48:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b4b:	75 cf                	jne    801b1c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b4d:	8b 42 58             	mov    0x58(%edx),%eax
  801b50:	6a 01                	push   $0x1
  801b52:	50                   	push   %eax
  801b53:	53                   	push   %ebx
  801b54:	68 23 28 80 00       	push   $0x802823
  801b59:	e8 1a e6 ff ff       	call   800178 <cprintf>
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	eb b9                	jmp    801b1c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b63:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b66:	0f 94 c0             	sete   %al
  801b69:	0f b6 c0             	movzbl %al,%eax
}
  801b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5f                   	pop    %edi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <devpipe_write>:
{
  801b74:	f3 0f 1e fb          	endbr32 
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	57                   	push   %edi
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 28             	sub    $0x28,%esp
  801b81:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b84:	56                   	push   %esi
  801b85:	e8 0c f2 ff ff       	call   800d96 <fd2data>
  801b8a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801b94:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b97:	74 4f                	je     801be8 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b99:	8b 43 04             	mov    0x4(%ebx),%eax
  801b9c:	8b 0b                	mov    (%ebx),%ecx
  801b9e:	8d 51 20             	lea    0x20(%ecx),%edx
  801ba1:	39 d0                	cmp    %edx,%eax
  801ba3:	72 14                	jb     801bb9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801ba5:	89 da                	mov    %ebx,%edx
  801ba7:	89 f0                	mov    %esi,%eax
  801ba9:	e8 61 ff ff ff       	call   801b0f <_pipeisclosed>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	75 3b                	jne    801bed <devpipe_write+0x79>
			sys_yield();
  801bb2:	e8 11 f0 ff ff       	call   800bc8 <sys_yield>
  801bb7:	eb e0                	jmp    801b99 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bc0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bc3:	89 c2                	mov    %eax,%edx
  801bc5:	c1 fa 1f             	sar    $0x1f,%edx
  801bc8:	89 d1                	mov    %edx,%ecx
  801bca:	c1 e9 1b             	shr    $0x1b,%ecx
  801bcd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bd0:	83 e2 1f             	and    $0x1f,%edx
  801bd3:	29 ca                	sub    %ecx,%edx
  801bd5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bd9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bdd:	83 c0 01             	add    $0x1,%eax
  801be0:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801be3:	83 c7 01             	add    $0x1,%edi
  801be6:	eb ac                	jmp    801b94 <devpipe_write+0x20>
	return i;
  801be8:	8b 45 10             	mov    0x10(%ebp),%eax
  801beb:	eb 05                	jmp    801bf2 <devpipe_write+0x7e>
				return 0;
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    

00801bfa <devpipe_read>:
{
  801bfa:	f3 0f 1e fb          	endbr32 
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	57                   	push   %edi
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	83 ec 18             	sub    $0x18,%esp
  801c07:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c0a:	57                   	push   %edi
  801c0b:	e8 86 f1 ff ff       	call   800d96 <fd2data>
  801c10:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	be 00 00 00 00       	mov    $0x0,%esi
  801c1a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c1d:	75 14                	jne    801c33 <devpipe_read+0x39>
	return i;
  801c1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801c22:	eb 02                	jmp    801c26 <devpipe_read+0x2c>
				return i;
  801c24:	89 f0                	mov    %esi,%eax
}
  801c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c29:	5b                   	pop    %ebx
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
			sys_yield();
  801c2e:	e8 95 ef ff ff       	call   800bc8 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c33:	8b 03                	mov    (%ebx),%eax
  801c35:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c38:	75 18                	jne    801c52 <devpipe_read+0x58>
			if (i > 0)
  801c3a:	85 f6                	test   %esi,%esi
  801c3c:	75 e6                	jne    801c24 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c3e:	89 da                	mov    %ebx,%edx
  801c40:	89 f8                	mov    %edi,%eax
  801c42:	e8 c8 fe ff ff       	call   801b0f <_pipeisclosed>
  801c47:	85 c0                	test   %eax,%eax
  801c49:	74 e3                	je     801c2e <devpipe_read+0x34>
				return 0;
  801c4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c50:	eb d4                	jmp    801c26 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c52:	99                   	cltd   
  801c53:	c1 ea 1b             	shr    $0x1b,%edx
  801c56:	01 d0                	add    %edx,%eax
  801c58:	83 e0 1f             	and    $0x1f,%eax
  801c5b:	29 d0                	sub    %edx,%eax
  801c5d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c65:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c68:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c6b:	83 c6 01             	add    $0x1,%esi
  801c6e:	eb aa                	jmp    801c1a <devpipe_read+0x20>

00801c70 <pipe>:
{
  801c70:	f3 0f 1e fb          	endbr32 
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	e8 2c f1 ff ff       	call   800db1 <fd_alloc>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	0f 88 23 01 00 00    	js     801db5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c92:	83 ec 04             	sub    $0x4,%esp
  801c95:	68 07 04 00 00       	push   $0x407
  801c9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c9d:	6a 00                	push   $0x0
  801c9f:	e8 47 ef ff ff       	call   800beb <sys_page_alloc>
  801ca4:	89 c3                	mov    %eax,%ebx
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	0f 88 04 01 00 00    	js     801db5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb7:	50                   	push   %eax
  801cb8:	e8 f4 f0 ff ff       	call   800db1 <fd_alloc>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	0f 88 db 00 00 00    	js     801da5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cca:	83 ec 04             	sub    $0x4,%esp
  801ccd:	68 07 04 00 00       	push   $0x407
  801cd2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 0f ef ff ff       	call   800beb <sys_page_alloc>
  801cdc:	89 c3                	mov    %eax,%ebx
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	0f 88 bc 00 00 00    	js     801da5 <pipe+0x135>
	va = fd2data(fd0);
  801ce9:	83 ec 0c             	sub    $0xc,%esp
  801cec:	ff 75 f4             	pushl  -0xc(%ebp)
  801cef:	e8 a2 f0 ff ff       	call   800d96 <fd2data>
  801cf4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf6:	83 c4 0c             	add    $0xc,%esp
  801cf9:	68 07 04 00 00       	push   $0x407
  801cfe:	50                   	push   %eax
  801cff:	6a 00                	push   $0x0
  801d01:	e8 e5 ee ff ff       	call   800beb <sys_page_alloc>
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	0f 88 82 00 00 00    	js     801d95 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	ff 75 f0             	pushl  -0x10(%ebp)
  801d19:	e8 78 f0 ff ff       	call   800d96 <fd2data>
  801d1e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d25:	50                   	push   %eax
  801d26:	6a 00                	push   $0x0
  801d28:	56                   	push   %esi
  801d29:	6a 00                	push   $0x0
  801d2b:	e8 e1 ee ff ff       	call   800c11 <sys_page_map>
  801d30:	89 c3                	mov    %eax,%ebx
  801d32:	83 c4 20             	add    $0x20,%esp
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 4e                	js     801d87 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d39:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801d3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d41:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d46:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d4d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d50:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d55:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d5c:	83 ec 0c             	sub    $0xc,%esp
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	e8 1b f0 ff ff       	call   800d82 <fd2num>
  801d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d6c:	83 c4 04             	add    $0x4,%esp
  801d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d72:	e8 0b f0 ff ff       	call   800d82 <fd2num>
  801d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d85:	eb 2e                	jmp    801db5 <pipe+0x145>
	sys_page_unmap(0, va);
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	56                   	push   %esi
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 a4 ee ff ff       	call   800c36 <sys_page_unmap>
  801d92:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 94 ee ff ff       	call   800c36 <sys_page_unmap>
  801da2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dab:	6a 00                	push   $0x0
  801dad:	e8 84 ee ff ff       	call   800c36 <sys_page_unmap>
  801db2:	83 c4 10             	add    $0x10,%esp
}
  801db5:	89 d8                	mov    %ebx,%eax
  801db7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <pipeisclosed>:
{
  801dbe:	f3 0f 1e fb          	endbr32 
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcb:	50                   	push   %eax
  801dcc:	ff 75 08             	pushl  0x8(%ebp)
  801dcf:	e8 33 f0 ff ff       	call   800e07 <fd_lookup>
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 18                	js     801df3 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801ddb:	83 ec 0c             	sub    $0xc,%esp
  801dde:	ff 75 f4             	pushl  -0xc(%ebp)
  801de1:	e8 b0 ef ff ff       	call   800d96 <fd2data>
  801de6:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801deb:	e8 1f fd ff ff       	call   801b0f <_pipeisclosed>
  801df0:	83 c4 10             	add    $0x10,%esp
}
  801df3:	c9                   	leave  
  801df4:	c3                   	ret    

00801df5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df5:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfe:	c3                   	ret    

00801dff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dff:	f3 0f 1e fb          	endbr32 
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e09:	68 3b 28 80 00       	push   $0x80283b
  801e0e:	ff 75 0c             	pushl  0xc(%ebp)
  801e11:	e8 6c e9 ff ff       	call   800782 <strcpy>
	return 0;
}
  801e16:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1b:	c9                   	leave  
  801e1c:	c3                   	ret    

00801e1d <devcons_write>:
{
  801e1d:	f3 0f 1e fb          	endbr32 
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	57                   	push   %edi
  801e25:	56                   	push   %esi
  801e26:	53                   	push   %ebx
  801e27:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e2d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e32:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e38:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3b:	73 31                	jae    801e6e <devcons_write+0x51>
		m = n - tot;
  801e3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e40:	29 f3                	sub    %esi,%ebx
  801e42:	83 fb 7f             	cmp    $0x7f,%ebx
  801e45:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e4a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e4d:	83 ec 04             	sub    $0x4,%esp
  801e50:	53                   	push   %ebx
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	03 45 0c             	add    0xc(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	57                   	push   %edi
  801e58:	e8 23 eb ff ff       	call   800980 <memmove>
		sys_cputs(buf, m);
  801e5d:	83 c4 08             	add    $0x8,%esp
  801e60:	53                   	push   %ebx
  801e61:	57                   	push   %edi
  801e62:	e8 d5 ec ff ff       	call   800b3c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e67:	01 de                	add    %ebx,%esi
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	eb ca                	jmp    801e38 <devcons_write+0x1b>
}
  801e6e:	89 f0                	mov    %esi,%eax
  801e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <devcons_read>:
{
  801e78:	f3 0f 1e fb          	endbr32 
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 08             	sub    $0x8,%esp
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e8b:	74 21                	je     801eae <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e8d:	e8 cc ec ff ff       	call   800b5e <sys_cgetc>
  801e92:	85 c0                	test   %eax,%eax
  801e94:	75 07                	jne    801e9d <devcons_read+0x25>
		sys_yield();
  801e96:	e8 2d ed ff ff       	call   800bc8 <sys_yield>
  801e9b:	eb f0                	jmp    801e8d <devcons_read+0x15>
	if (c < 0)
  801e9d:	78 0f                	js     801eae <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e9f:	83 f8 04             	cmp    $0x4,%eax
  801ea2:	74 0c                	je     801eb0 <devcons_read+0x38>
	*(char*)vbuf = c;
  801ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea7:	88 02                	mov    %al,(%edx)
	return 1;
  801ea9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    
		return 0;
  801eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb5:	eb f7                	jmp    801eae <devcons_read+0x36>

00801eb7 <cputchar>:
{
  801eb7:	f3 0f 1e fb          	endbr32 
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ec7:	6a 01                	push   $0x1
  801ec9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	e8 6a ec ff ff       	call   800b3c <sys_cputs>
}
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <getchar>:
{
  801ed7:	f3 0f 1e fb          	endbr32 
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ee1:	6a 01                	push   $0x1
  801ee3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee6:	50                   	push   %eax
  801ee7:	6a 00                	push   $0x0
  801ee9:	e8 a1 f1 ff ff       	call   80108f <read>
	if (r < 0)
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 06                	js     801efb <getchar+0x24>
	if (r < 1)
  801ef5:	74 06                	je     801efd <getchar+0x26>
	return c;
  801ef7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    
		return -E_EOF;
  801efd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f02:	eb f7                	jmp    801efb <getchar+0x24>

00801f04 <iscons>:
{
  801f04:	f3 0f 1e fb          	endbr32 
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f11:	50                   	push   %eax
  801f12:	ff 75 08             	pushl  0x8(%ebp)
  801f15:	e8 ed ee ff ff       	call   800e07 <fd_lookup>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 11                	js     801f32 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f24:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f2a:	39 10                	cmp    %edx,(%eax)
  801f2c:	0f 94 c0             	sete   %al
  801f2f:	0f b6 c0             	movzbl %al,%eax
}
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    

00801f34 <opencons>:
{
  801f34:	f3 0f 1e fb          	endbr32 
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f41:	50                   	push   %eax
  801f42:	e8 6a ee ff ff       	call   800db1 <fd_alloc>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	78 3a                	js     801f88 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4e:	83 ec 04             	sub    $0x4,%esp
  801f51:	68 07 04 00 00       	push   $0x407
  801f56:	ff 75 f4             	pushl  -0xc(%ebp)
  801f59:	6a 00                	push   $0x0
  801f5b:	e8 8b ec ff ff       	call   800beb <sys_page_alloc>
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	85 c0                	test   %eax,%eax
  801f65:	78 21                	js     801f88 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6a:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801f70:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f75:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f7c:	83 ec 0c             	sub    $0xc,%esp
  801f7f:	50                   	push   %eax
  801f80:	e8 fd ed ff ff       	call   800d82 <fd2num>
  801f85:	83 c4 10             	add    $0x10,%esp
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f8a:	f3 0f 1e fb          	endbr32 
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f93:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f96:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f9c:	e8 04 ec ff ff       	call   800ba5 <sys_getenvid>
  801fa1:	83 ec 0c             	sub    $0xc,%esp
  801fa4:	ff 75 0c             	pushl  0xc(%ebp)
  801fa7:	ff 75 08             	pushl  0x8(%ebp)
  801faa:	56                   	push   %esi
  801fab:	50                   	push   %eax
  801fac:	68 48 28 80 00       	push   $0x802848
  801fb1:	e8 c2 e1 ff ff       	call   800178 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fb6:	83 c4 18             	add    $0x18,%esp
  801fb9:	53                   	push   %ebx
  801fba:	ff 75 10             	pushl  0x10(%ebp)
  801fbd:	e8 61 e1 ff ff       	call   800123 <vcprintf>
	cprintf("\n");
  801fc2:	c7 04 24 34 28 80 00 	movl   $0x802834,(%esp)
  801fc9:	e8 aa e1 ff ff       	call   800178 <cprintf>
  801fce:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fd1:	cc                   	int3   
  801fd2:	eb fd                	jmp    801fd1 <_panic+0x47>

00801fd4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fd4:	f3 0f 1e fb          	endbr32 
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	56                   	push   %esi
  801fdc:	53                   	push   %ebx
  801fdd:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fed:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801ff0:	83 ec 0c             	sub    $0xc,%esp
  801ff3:	50                   	push   %eax
  801ff4:	e8 f8 ec ff ff       	call   800cf1 <sys_ipc_recv>
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	75 2b                	jne    80202b <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802000:	85 f6                	test   %esi,%esi
  802002:	74 0a                	je     80200e <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802004:	a1 08 40 80 00       	mov    0x804008,%eax
  802009:	8b 40 74             	mov    0x74(%eax),%eax
  80200c:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80200e:	85 db                	test   %ebx,%ebx
  802010:	74 0a                	je     80201c <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802012:	a1 08 40 80 00       	mov    0x804008,%eax
  802017:	8b 40 78             	mov    0x78(%eax),%eax
  80201a:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80201c:	a1 08 40 80 00       	mov    0x804008,%eax
  802021:	8b 40 70             	mov    0x70(%eax),%eax
}
  802024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80202b:	85 f6                	test   %esi,%esi
  80202d:	74 06                	je     802035 <ipc_recv+0x61>
  80202f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802035:	85 db                	test   %ebx,%ebx
  802037:	74 eb                	je     802024 <ipc_recv+0x50>
  802039:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80203f:	eb e3                	jmp    802024 <ipc_recv+0x50>

00802041 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802041:	f3 0f 1e fb          	endbr32 
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	57                   	push   %edi
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	83 ec 0c             	sub    $0xc,%esp
  80204e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802051:	8b 75 0c             	mov    0xc(%ebp),%esi
  802054:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802057:	85 db                	test   %ebx,%ebx
  802059:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80205e:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802061:	ff 75 14             	pushl  0x14(%ebp)
  802064:	53                   	push   %ebx
  802065:	56                   	push   %esi
  802066:	57                   	push   %edi
  802067:	e8 5e ec ff ff       	call   800cca <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80206c:	83 c4 10             	add    $0x10,%esp
  80206f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802072:	75 07                	jne    80207b <ipc_send+0x3a>
			sys_yield();
  802074:	e8 4f eb ff ff       	call   800bc8 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802079:	eb e6                	jmp    802061 <ipc_send+0x20>
		}
		else if (ret == 0)
  80207b:	85 c0                	test   %eax,%eax
  80207d:	75 08                	jne    802087 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80207f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5f                   	pop    %edi
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802087:	50                   	push   %eax
  802088:	68 6b 28 80 00       	push   $0x80286b
  80208d:	6a 48                	push   $0x48
  80208f:	68 79 28 80 00       	push   $0x802879
  802094:	e8 f1 fe ff ff       	call   801f8a <_panic>

00802099 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802099:	f3 0f 1e fb          	endbr32 
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ab:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020b1:	8b 52 50             	mov    0x50(%edx),%edx
  8020b4:	39 ca                	cmp    %ecx,%edx
  8020b6:	74 11                	je     8020c9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8020b8:	83 c0 01             	add    $0x1,%eax
  8020bb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c0:	75 e6                	jne    8020a8 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c7:	eb 0b                	jmp    8020d4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020d4:	5d                   	pop    %ebp
  8020d5:	c3                   	ret    

008020d6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d6:	f3 0f 1e fb          	endbr32 
  8020da:	55                   	push   %ebp
  8020db:	89 e5                	mov    %esp,%ebp
  8020dd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e0:	89 c2                	mov    %eax,%edx
  8020e2:	c1 ea 16             	shr    $0x16,%edx
  8020e5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020ec:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020f1:	f6 c1 01             	test   $0x1,%cl
  8020f4:	74 1c                	je     802112 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8020f6:	c1 e8 0c             	shr    $0xc,%eax
  8020f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802100:	a8 01                	test   $0x1,%al
  802102:	74 0e                	je     802112 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802104:	c1 e8 0c             	shr    $0xc,%eax
  802107:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80210e:	ef 
  80210f:	0f b7 d2             	movzwl %dx,%edx
}
  802112:	89 d0                	mov    %edx,%eax
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__udivdi3>:
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802133:	8b 74 24 34          	mov    0x34(%esp),%esi
  802137:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80213b:	85 d2                	test   %edx,%edx
  80213d:	75 19                	jne    802158 <__udivdi3+0x38>
  80213f:	39 f3                	cmp    %esi,%ebx
  802141:	76 4d                	jbe    802190 <__udivdi3+0x70>
  802143:	31 ff                	xor    %edi,%edi
  802145:	89 e8                	mov    %ebp,%eax
  802147:	89 f2                	mov    %esi,%edx
  802149:	f7 f3                	div    %ebx
  80214b:	89 fa                	mov    %edi,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	76 14                	jbe    802170 <__udivdi3+0x50>
  80215c:	31 ff                	xor    %edi,%edi
  80215e:	31 c0                	xor    %eax,%eax
  802160:	89 fa                	mov    %edi,%edx
  802162:	83 c4 1c             	add    $0x1c,%esp
  802165:	5b                   	pop    %ebx
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	0f bd fa             	bsr    %edx,%edi
  802173:	83 f7 1f             	xor    $0x1f,%edi
  802176:	75 48                	jne    8021c0 <__udivdi3+0xa0>
  802178:	39 f2                	cmp    %esi,%edx
  80217a:	72 06                	jb     802182 <__udivdi3+0x62>
  80217c:	31 c0                	xor    %eax,%eax
  80217e:	39 eb                	cmp    %ebp,%ebx
  802180:	77 de                	ja     802160 <__udivdi3+0x40>
  802182:	b8 01 00 00 00       	mov    $0x1,%eax
  802187:	eb d7                	jmp    802160 <__udivdi3+0x40>
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d9                	mov    %ebx,%ecx
  802192:	85 db                	test   %ebx,%ebx
  802194:	75 0b                	jne    8021a1 <__udivdi3+0x81>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f3                	div    %ebx
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	31 d2                	xor    %edx,%edx
  8021a3:	89 f0                	mov    %esi,%eax
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 c6                	mov    %eax,%esi
  8021a9:	89 e8                	mov    %ebp,%eax
  8021ab:	89 f7                	mov    %esi,%edi
  8021ad:	f7 f1                	div    %ecx
  8021af:	89 fa                	mov    %edi,%edx
  8021b1:	83 c4 1c             	add    $0x1c,%esp
  8021b4:	5b                   	pop    %ebx
  8021b5:	5e                   	pop    %esi
  8021b6:	5f                   	pop    %edi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 f9                	mov    %edi,%ecx
  8021c2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021c7:	29 f8                	sub    %edi,%eax
  8021c9:	d3 e2                	shl    %cl,%edx
  8021cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	89 da                	mov    %ebx,%edx
  8021d3:	d3 ea                	shr    %cl,%edx
  8021d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021d9:	09 d1                	or     %edx,%ecx
  8021db:	89 f2                	mov    %esi,%edx
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e3                	shl    %cl,%ebx
  8021e5:	89 c1                	mov    %eax,%ecx
  8021e7:	d3 ea                	shr    %cl,%edx
  8021e9:	89 f9                	mov    %edi,%ecx
  8021eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021ef:	89 eb                	mov    %ebp,%ebx
  8021f1:	d3 e6                	shl    %cl,%esi
  8021f3:	89 c1                	mov    %eax,%ecx
  8021f5:	d3 eb                	shr    %cl,%ebx
  8021f7:	09 de                	or     %ebx,%esi
  8021f9:	89 f0                	mov    %esi,%eax
  8021fb:	f7 74 24 08          	divl   0x8(%esp)
  8021ff:	89 d6                	mov    %edx,%esi
  802201:	89 c3                	mov    %eax,%ebx
  802203:	f7 64 24 0c          	mull   0xc(%esp)
  802207:	39 d6                	cmp    %edx,%esi
  802209:	72 15                	jb     802220 <__udivdi3+0x100>
  80220b:	89 f9                	mov    %edi,%ecx
  80220d:	d3 e5                	shl    %cl,%ebp
  80220f:	39 c5                	cmp    %eax,%ebp
  802211:	73 04                	jae    802217 <__udivdi3+0xf7>
  802213:	39 d6                	cmp    %edx,%esi
  802215:	74 09                	je     802220 <__udivdi3+0x100>
  802217:	89 d8                	mov    %ebx,%eax
  802219:	31 ff                	xor    %edi,%edi
  80221b:	e9 40 ff ff ff       	jmp    802160 <__udivdi3+0x40>
  802220:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802223:	31 ff                	xor    %edi,%edi
  802225:	e9 36 ff ff ff       	jmp    802160 <__udivdi3+0x40>
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	f3 0f 1e fb          	endbr32 
  802234:	55                   	push   %ebp
  802235:	57                   	push   %edi
  802236:	56                   	push   %esi
  802237:	53                   	push   %ebx
  802238:	83 ec 1c             	sub    $0x1c,%esp
  80223b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80223f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802243:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802247:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80224b:	85 c0                	test   %eax,%eax
  80224d:	75 19                	jne    802268 <__umoddi3+0x38>
  80224f:	39 df                	cmp    %ebx,%edi
  802251:	76 5d                	jbe    8022b0 <__umoddi3+0x80>
  802253:	89 f0                	mov    %esi,%eax
  802255:	89 da                	mov    %ebx,%edx
  802257:	f7 f7                	div    %edi
  802259:	89 d0                	mov    %edx,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	83 c4 1c             	add    $0x1c,%esp
  802260:	5b                   	pop    %ebx
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
  802265:	8d 76 00             	lea    0x0(%esi),%esi
  802268:	89 f2                	mov    %esi,%edx
  80226a:	39 d8                	cmp    %ebx,%eax
  80226c:	76 12                	jbe    802280 <__umoddi3+0x50>
  80226e:	89 f0                	mov    %esi,%eax
  802270:	89 da                	mov    %ebx,%edx
  802272:	83 c4 1c             	add    $0x1c,%esp
  802275:	5b                   	pop    %ebx
  802276:	5e                   	pop    %esi
  802277:	5f                   	pop    %edi
  802278:	5d                   	pop    %ebp
  802279:	c3                   	ret    
  80227a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802280:	0f bd e8             	bsr    %eax,%ebp
  802283:	83 f5 1f             	xor    $0x1f,%ebp
  802286:	75 50                	jne    8022d8 <__umoddi3+0xa8>
  802288:	39 d8                	cmp    %ebx,%eax
  80228a:	0f 82 e0 00 00 00    	jb     802370 <__umoddi3+0x140>
  802290:	89 d9                	mov    %ebx,%ecx
  802292:	39 f7                	cmp    %esi,%edi
  802294:	0f 86 d6 00 00 00    	jbe    802370 <__umoddi3+0x140>
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	89 ca                	mov    %ecx,%edx
  80229e:	83 c4 1c             	add    $0x1c,%esp
  8022a1:	5b                   	pop    %ebx
  8022a2:	5e                   	pop    %esi
  8022a3:	5f                   	pop    %edi
  8022a4:	5d                   	pop    %ebp
  8022a5:	c3                   	ret    
  8022a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	89 fd                	mov    %edi,%ebp
  8022b2:	85 ff                	test   %edi,%edi
  8022b4:	75 0b                	jne    8022c1 <__umoddi3+0x91>
  8022b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	f7 f7                	div    %edi
  8022bf:	89 c5                	mov    %eax,%ebp
  8022c1:	89 d8                	mov    %ebx,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f5                	div    %ebp
  8022c7:	89 f0                	mov    %esi,%eax
  8022c9:	f7 f5                	div    %ebp
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	31 d2                	xor    %edx,%edx
  8022cf:	eb 8c                	jmp    80225d <__umoddi3+0x2d>
  8022d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	ba 20 00 00 00       	mov    $0x20,%edx
  8022df:	29 ea                	sub    %ebp,%edx
  8022e1:	d3 e0                	shl    %cl,%eax
  8022e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 f8                	mov    %edi,%eax
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022f9:	09 c1                	or     %eax,%ecx
  8022fb:	89 d8                	mov    %ebx,%eax
  8022fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802301:	89 e9                	mov    %ebp,%ecx
  802303:	d3 e7                	shl    %cl,%edi
  802305:	89 d1                	mov    %edx,%ecx
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80230f:	d3 e3                	shl    %cl,%ebx
  802311:	89 c7                	mov    %eax,%edi
  802313:	89 d1                	mov    %edx,%ecx
  802315:	89 f0                	mov    %esi,%eax
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	89 fa                	mov    %edi,%edx
  80231d:	d3 e6                	shl    %cl,%esi
  80231f:	09 d8                	or     %ebx,%eax
  802321:	f7 74 24 08          	divl   0x8(%esp)
  802325:	89 d1                	mov    %edx,%ecx
  802327:	89 f3                	mov    %esi,%ebx
  802329:	f7 64 24 0c          	mull   0xc(%esp)
  80232d:	89 c6                	mov    %eax,%esi
  80232f:	89 d7                	mov    %edx,%edi
  802331:	39 d1                	cmp    %edx,%ecx
  802333:	72 06                	jb     80233b <__umoddi3+0x10b>
  802335:	75 10                	jne    802347 <__umoddi3+0x117>
  802337:	39 c3                	cmp    %eax,%ebx
  802339:	73 0c                	jae    802347 <__umoddi3+0x117>
  80233b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80233f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802343:	89 d7                	mov    %edx,%edi
  802345:	89 c6                	mov    %eax,%esi
  802347:	89 ca                	mov    %ecx,%edx
  802349:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80234e:	29 f3                	sub    %esi,%ebx
  802350:	19 fa                	sbb    %edi,%edx
  802352:	89 d0                	mov    %edx,%eax
  802354:	d3 e0                	shl    %cl,%eax
  802356:	89 e9                	mov    %ebp,%ecx
  802358:	d3 eb                	shr    %cl,%ebx
  80235a:	d3 ea                	shr    %cl,%edx
  80235c:	09 d8                	or     %ebx,%eax
  80235e:	83 c4 1c             	add    $0x1c,%esp
  802361:	5b                   	pop    %ebx
  802362:	5e                   	pop    %esi
  802363:	5f                   	pop    %edi
  802364:	5d                   	pop    %ebp
  802365:	c3                   	ret    
  802366:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	29 fe                	sub    %edi,%esi
  802372:	19 c3                	sbb    %eax,%ebx
  802374:	89 f2                	mov    %esi,%edx
  802376:	89 d9                	mov    %ebx,%ecx
  802378:	e9 1d ff ff ff       	jmp    80229a <__umoddi3+0x6a>
