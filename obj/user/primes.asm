
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800040:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 00                	push   $0x0
  800048:	6a 00                	push   $0x0
  80004a:	56                   	push   %esi
  80004b:	e8 94 10 00 00       	call   8010e4 <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 08 40 80 00       	mov    0x804008,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 40 27 80 00       	push   $0x802740
  800064:	e8 e4 01 00 00       	call   80024d <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 e5 0e 00 00       	call   800f53 <fork>
  80006e:	89 c7                	mov    %eax,%edi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	78 07                	js     80007e <primeproc+0x4b>
		panic("fork: %e", id);
	if (id == 0)
  800077:	74 ca                	je     800043 <primeproc+0x10>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800079:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007c:	eb 20                	jmp    80009e <primeproc+0x6b>
		panic("fork: %e", id);
  80007e:	50                   	push   %eax
  80007f:	68 4c 27 80 00       	push   $0x80274c
  800084:	6a 1a                	push   $0x1a
  800086:	68 55 27 80 00       	push   $0x802755
  80008b:	e8 d6 00 00 00       	call   800166 <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 b6 10 00 00       	call   801151 <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 39 10 00 00       	call   8010e4 <ipc_recv>
  8000ab:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000ad:	99                   	cltd   
  8000ae:	f7 fb                	idiv   %ebx
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	85 d2                	test   %edx,%edx
  8000b5:	74 e7                	je     80009e <primeproc+0x6b>
  8000b7:	eb d7                	jmp    800090 <primeproc+0x5d>

008000b9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000c2:	e8 8c 0e 00 00       	call   800f53 <fork>
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	78 1a                	js     8000e7 <umain+0x2e>
	if (id == 0) // child
		primeproc();
		
	// parent
	// feed all the integers through
	for (i = 2; ; i++)
  8000cd:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0) // child
  8000d2:	74 25                	je     8000f9 <umain+0x40>
		ipc_send(id, i, 0, 0);
  8000d4:	6a 00                	push   $0x0
  8000d6:	6a 00                	push   $0x0
  8000d8:	53                   	push   %ebx
  8000d9:	56                   	push   %esi
  8000da:	e8 72 10 00 00       	call   801151 <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 4c 27 80 00       	push   $0x80274c
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 55 27 80 00       	push   $0x802755
  8000f4:	e8 6d 00 00 00       	call   800166 <_panic>
		primeproc();
  8000f9:	e8 35 ff ff ff       	call   800033 <primeproc>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	f3 0f 1e fb          	endbr32 
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 68 0b 00 00       	call   800c7a <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x31>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	e8 80 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	f3 0f 1e fb          	endbr32 
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800152:	e8 83 12 00 00       	call   8013da <close_all>
	sys_env_destroy(0);
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	6a 00                	push   $0x0
  80015c:	e8 f5 0a 00 00       	call   800c56 <sys_env_destroy>
}
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800166:	f3 0f 1e fb          	endbr32 
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80016f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800172:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800178:	e8 fd 0a 00 00       	call   800c7a <sys_getenvid>
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	56                   	push   %esi
  800187:	50                   	push   %eax
  800188:	68 70 27 80 00       	push   $0x802770
  80018d:	e8 bb 00 00 00       	call   80024d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800192:	83 c4 18             	add    $0x18,%esp
  800195:	53                   	push   %ebx
  800196:	ff 75 10             	pushl  0x10(%ebp)
  800199:	e8 5a 00 00 00       	call   8001f8 <vcprintf>
	cprintf("\n");
  80019e:	c7 04 24 28 2d 80 00 	movl   $0x802d28,(%esp)
  8001a5:	e8 a3 00 00 00       	call   80024d <cprintf>
  8001aa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ad:	cc                   	int3   
  8001ae:	eb fd                	jmp    8001ad <_panic+0x47>

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	f3 0f 1e fb          	endbr32 
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 04             	sub    $0x4,%esp
  8001bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001be:	8b 13                	mov    (%ebx),%edx
  8001c0:	8d 42 01             	lea    0x1(%edx),%eax
  8001c3:	89 03                	mov    %eax,(%ebx)
  8001c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d1:	74 09                	je     8001dc <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	68 ff 00 00 00       	push   $0xff
  8001e4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e7:	50                   	push   %eax
  8001e8:	e8 24 0a 00 00       	call   800c11 <sys_cputs>
		b->idx = 0;
  8001ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	eb db                	jmp    8001d3 <putch+0x23>

008001f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f8:	f3 0f 1e fb          	endbr32 
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800205:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020c:	00 00 00 
	b.cnt = 0;
  80020f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800216:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800219:	ff 75 0c             	pushl  0xc(%ebp)
  80021c:	ff 75 08             	pushl  0x8(%ebp)
  80021f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800225:	50                   	push   %eax
  800226:	68 b0 01 80 00       	push   $0x8001b0
  80022b:	e8 20 01 00 00       	call   800350 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800230:	83 c4 08             	add    $0x8,%esp
  800233:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800239:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023f:	50                   	push   %eax
  800240:	e8 cc 09 00 00       	call   800c11 <sys_cputs>

	return b.cnt;
}
  800245:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    

0080024d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024d:	f3 0f 1e fb          	endbr32 
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800257:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025a:	50                   	push   %eax
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	e8 95 ff ff ff       	call   8001f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 1c             	sub    $0x1c,%esp
  80026e:	89 c7                	mov    %eax,%edi
  800270:	89 d6                	mov    %edx,%esi
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	8b 55 0c             	mov    0xc(%ebp),%edx
  800278:	89 d1                	mov    %edx,%ecx
  80027a:	89 c2                	mov    %eax,%edx
  80027c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800282:	8b 45 10             	mov    0x10(%ebp),%eax
  800285:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800288:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800292:	39 c2                	cmp    %eax,%edx
  800294:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800297:	72 3e                	jb     8002d7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800299:	83 ec 0c             	sub    $0xc,%esp
  80029c:	ff 75 18             	pushl  0x18(%ebp)
  80029f:	83 eb 01             	sub    $0x1,%ebx
  8002a2:	53                   	push   %ebx
  8002a3:	50                   	push   %eax
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b3:	e8 18 22 00 00       	call   8024d0 <__udivdi3>
  8002b8:	83 c4 18             	add    $0x18,%esp
  8002bb:	52                   	push   %edx
  8002bc:	50                   	push   %eax
  8002bd:	89 f2                	mov    %esi,%edx
  8002bf:	89 f8                	mov    %edi,%eax
  8002c1:	e8 9f ff ff ff       	call   800265 <printnum>
  8002c6:	83 c4 20             	add    $0x20,%esp
  8002c9:	eb 13                	jmp    8002de <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cb:	83 ec 08             	sub    $0x8,%esp
  8002ce:	56                   	push   %esi
  8002cf:	ff 75 18             	pushl  0x18(%ebp)
  8002d2:	ff d7                	call   *%edi
  8002d4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002d7:	83 eb 01             	sub    $0x1,%ebx
  8002da:	85 db                	test   %ebx,%ebx
  8002dc:	7f ed                	jg     8002cb <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	56                   	push   %esi
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f1:	e8 ea 22 00 00       	call   8025e0 <__umoddi3>
  8002f6:	83 c4 14             	add    $0x14,%esp
  8002f9:	0f be 80 93 27 80 00 	movsbl 0x802793(%eax),%eax
  800300:	50                   	push   %eax
  800301:	ff d7                	call   *%edi
}
  800303:	83 c4 10             	add    $0x10,%esp
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030e:	f3 0f 1e fb          	endbr32 
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1f>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
{
  80032f:	f3 0f 1e fb          	endbr32 
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800339:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033c:	50                   	push   %eax
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	ff 75 08             	pushl  0x8(%ebp)
  800346:	e8 05 00 00 00       	call   800350 <vprintfmt>
}
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <vprintfmt>:
{
  800350:	f3 0f 1e fb          	endbr32 
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 3c             	sub    $0x3c,%esp
  80035d:	8b 75 08             	mov    0x8(%ebp),%esi
  800360:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800363:	8b 7d 10             	mov    0x10(%ebp),%edi
  800366:	e9 8e 03 00 00       	jmp    8006f9 <vprintfmt+0x3a9>
		padc = ' ';
  80036b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80036f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800376:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80037d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800384:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8d 47 01             	lea    0x1(%edi),%eax
  80038c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038f:	0f b6 17             	movzbl (%edi),%edx
  800392:	8d 42 dd             	lea    -0x23(%edx),%eax
  800395:	3c 55                	cmp    $0x55,%al
  800397:	0f 87 df 03 00 00    	ja     80077c <vprintfmt+0x42c>
  80039d:	0f b6 c0             	movzbl %al,%eax
  8003a0:	3e ff 24 85 e0 28 80 	notrack jmp *0x8028e0(,%eax,4)
  8003a7:	00 
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ab:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003af:	eb d8                	jmp    800389 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003b8:	eb cf                	jmp    800389 <vprintfmt+0x39>
  8003ba:	0f b6 d2             	movzbl %dl,%edx
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003cf:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003d5:	83 f9 09             	cmp    $0x9,%ecx
  8003d8:	77 55                	ja     80042f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003da:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003dd:	eb e9                	jmp    8003c8 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8d 40 04             	lea    0x4(%eax),%eax
  8003ed:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f7:	79 90                	jns    800389 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ff:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800406:	eb 81                	jmp    800389 <vprintfmt+0x39>
  800408:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	0f 49 d0             	cmovns %eax,%edx
  800415:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041b:	e9 69 ff ff ff       	jmp    800389 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800423:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80042a:	e9 5a ff ff ff       	jmp    800389 <vprintfmt+0x39>
  80042f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800432:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800435:	eb bc                	jmp    8003f3 <vprintfmt+0xa3>
			lflag++;
  800437:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043d:	e9 47 ff ff ff       	jmp    800389 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 78 04             	lea    0x4(%eax),%edi
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	53                   	push   %ebx
  80044c:	ff 30                	pushl  (%eax)
  80044e:	ff d6                	call   *%esi
			break;
  800450:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800456:	e9 9b 02 00 00       	jmp    8006f6 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 78 04             	lea    0x4(%eax),%edi
  800461:	8b 00                	mov    (%eax),%eax
  800463:	99                   	cltd   
  800464:	31 d0                	xor    %edx,%eax
  800466:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800468:	83 f8 0f             	cmp    $0xf,%eax
  80046b:	7f 23                	jg     800490 <vprintfmt+0x140>
  80046d:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800474:	85 d2                	test   %edx,%edx
  800476:	74 18                	je     800490 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800478:	52                   	push   %edx
  800479:	68 5d 2c 80 00       	push   $0x802c5d
  80047e:	53                   	push   %ebx
  80047f:	56                   	push   %esi
  800480:	e8 aa fe ff ff       	call   80032f <printfmt>
  800485:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800488:	89 7d 14             	mov    %edi,0x14(%ebp)
  80048b:	e9 66 02 00 00       	jmp    8006f6 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800490:	50                   	push   %eax
  800491:	68 ab 27 80 00       	push   $0x8027ab
  800496:	53                   	push   %ebx
  800497:	56                   	push   %esi
  800498:	e8 92 fe ff ff       	call   80032f <printfmt>
  80049d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004a0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004a3:	e9 4e 02 00 00       	jmp    8006f6 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	83 c0 04             	add    $0x4,%eax
  8004ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004b6:	85 d2                	test   %edx,%edx
  8004b8:	b8 a4 27 80 00       	mov    $0x8027a4,%eax
  8004bd:	0f 45 c2             	cmovne %edx,%eax
  8004c0:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c7:	7e 06                	jle    8004cf <vprintfmt+0x17f>
  8004c9:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004cd:	75 0d                	jne    8004dc <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d2:	89 c7                	mov    %eax,%edi
  8004d4:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004da:	eb 55                	jmp    800531 <vprintfmt+0x1e1>
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e2:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e5:	e8 46 03 00 00       	call   800830 <strnlen>
  8004ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ed:	29 c2                	sub    %eax,%edx
  8004ef:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004f7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7e 11                	jle    800513 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	53                   	push   %ebx
  800506:	ff 75 e0             	pushl  -0x20(%ebp)
  800509:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	83 ef 01             	sub    $0x1,%edi
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	eb eb                	jmp    8004fe <vprintfmt+0x1ae>
  800513:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	b8 00 00 00 00       	mov    $0x0,%eax
  80051d:	0f 49 c2             	cmovns %edx,%eax
  800520:	29 c2                	sub    %eax,%edx
  800522:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800525:	eb a8                	jmp    8004cf <vprintfmt+0x17f>
					putch(ch, putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	53                   	push   %ebx
  80052b:	52                   	push   %edx
  80052c:	ff d6                	call   *%esi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800534:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	0f be d0             	movsbl %al,%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	74 4b                	je     80058f <vprintfmt+0x23f>
  800544:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800548:	78 06                	js     800550 <vprintfmt+0x200>
  80054a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80054e:	78 1e                	js     80056e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800550:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800554:	74 d1                	je     800527 <vprintfmt+0x1d7>
  800556:	0f be c0             	movsbl %al,%eax
  800559:	83 e8 20             	sub    $0x20,%eax
  80055c:	83 f8 5e             	cmp    $0x5e,%eax
  80055f:	76 c6                	jbe    800527 <vprintfmt+0x1d7>
					putch('?', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	53                   	push   %ebx
  800565:	6a 3f                	push   $0x3f
  800567:	ff d6                	call   *%esi
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	eb c3                	jmp    800531 <vprintfmt+0x1e1>
  80056e:	89 cf                	mov    %ecx,%edi
  800570:	eb 0e                	jmp    800580 <vprintfmt+0x230>
				putch(' ', putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	53                   	push   %ebx
  800576:	6a 20                	push   $0x20
  800578:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80057a:	83 ef 01             	sub    $0x1,%edi
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	85 ff                	test   %edi,%edi
  800582:	7f ee                	jg     800572 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800584:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	e9 67 01 00 00       	jmp    8006f6 <vprintfmt+0x3a6>
  80058f:	89 cf                	mov    %ecx,%edi
  800591:	eb ed                	jmp    800580 <vprintfmt+0x230>
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7f 1b                	jg     8005b3 <vprintfmt+0x263>
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	74 63                	je     8005ff <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	99                   	cltd   
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 40 04             	lea    0x4(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b1:	eb 17                	jmp    8005ca <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8b 50 04             	mov    0x4(%eax),%edx
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 40 08             	lea    0x8(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005d0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d5:	85 c9                	test   %ecx,%ecx
  8005d7:	0f 89 ff 00 00 00    	jns    8006dc <vprintfmt+0x38c>
				putch('-', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	6a 2d                	push   $0x2d
  8005e3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005eb:	f7 da                	neg    %edx
  8005ed:	83 d1 00             	adc    $0x0,%ecx
  8005f0:	f7 d9                	neg    %ecx
  8005f2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fa:	e9 dd 00 00 00       	jmp    8006dc <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	99                   	cltd   
  800608:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
  800614:	eb b4                	jmp    8005ca <vprintfmt+0x27a>
	if (lflag >= 2)
  800616:	83 f9 01             	cmp    $0x1,%ecx
  800619:	7f 1e                	jg     800639 <vprintfmt+0x2e9>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	74 32                	je     800651 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 10                	mov    (%eax),%edx
  800624:	b9 00 00 00 00       	mov    $0x0,%ecx
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800634:	e9 a3 00 00 00       	jmp    8006dc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	8b 48 04             	mov    0x4(%eax),%ecx
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80064c:	e9 8b 00 00 00       	jmp    8006dc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800666:	eb 74                	jmp    8006dc <vprintfmt+0x38c>
	if (lflag >= 2)
  800668:	83 f9 01             	cmp    $0x1,%ecx
  80066b:	7f 1b                	jg     800688 <vprintfmt+0x338>
	else if (lflag)
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	74 2c                	je     80069d <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800681:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800686:	eb 54                	jmp    8006dc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	8b 48 04             	mov    0x4(%eax),%ecx
  800690:	8d 40 08             	lea    0x8(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800696:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80069b:	eb 3f                	jmp    8006dc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a7:	8d 40 04             	lea    0x4(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ad:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006b2:	eb 28                	jmp    8006dc <vprintfmt+0x38c>
			putch('0', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 30                	push   $0x30
  8006ba:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bc:	83 c4 08             	add    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 78                	push   $0x78
  8006c2:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ce:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d1:	8d 40 04             	lea    0x4(%eax),%eax
  8006d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006e3:	57                   	push   %edi
  8006e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e7:	50                   	push   %eax
  8006e8:	51                   	push   %ecx
  8006e9:	52                   	push   %edx
  8006ea:	89 da                	mov    %ebx,%edx
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	e8 72 fb ff ff       	call   800265 <printnum>
			break;
  8006f3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006f9:	83 c7 01             	add    $0x1,%edi
  8006fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800700:	83 f8 25             	cmp    $0x25,%eax
  800703:	0f 84 62 fc ff ff    	je     80036b <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800709:	85 c0                	test   %eax,%eax
  80070b:	0f 84 8b 00 00 00    	je     80079c <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	50                   	push   %eax
  800716:	ff d6                	call   *%esi
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb dc                	jmp    8006f9 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80071d:	83 f9 01             	cmp    $0x1,%ecx
  800720:	7f 1b                	jg     80073d <vprintfmt+0x3ed>
	else if (lflag)
  800722:	85 c9                	test   %ecx,%ecx
  800724:	74 2c                	je     800752 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 10                	mov    (%eax),%edx
  80072b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800730:	8d 40 04             	lea    0x4(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80073b:	eb 9f                	jmp    8006dc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
  800742:	8b 48 04             	mov    0x4(%eax),%ecx
  800745:	8d 40 08             	lea    0x8(%eax),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800750:	eb 8a                	jmp    8006dc <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 10                	mov    (%eax),%edx
  800757:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075c:	8d 40 04             	lea    0x4(%eax),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800762:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800767:	e9 70 ff ff ff       	jmp    8006dc <vprintfmt+0x38c>
			putch(ch, putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	6a 25                	push   $0x25
  800772:	ff d6                	call   *%esi
			break;
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	e9 7a ff ff ff       	jmp    8006f6 <vprintfmt+0x3a6>
			putch('%', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 25                	push   $0x25
  800782:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	89 f8                	mov    %edi,%eax
  800789:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80078d:	74 05                	je     800794 <vprintfmt+0x444>
  80078f:	83 e8 01             	sub    $0x1,%eax
  800792:	eb f5                	jmp    800789 <vprintfmt+0x439>
  800794:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800797:	e9 5a ff ff ff       	jmp    8006f6 <vprintfmt+0x3a6>
}
  80079c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079f:	5b                   	pop    %ebx
  8007a0:	5e                   	pop    %esi
  8007a1:	5f                   	pop    %edi
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a4:	f3 0f 1e fb          	endbr32 
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 18             	sub    $0x18,%esp
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	74 26                	je     8007ef <vsnprintf+0x4b>
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	7e 22                	jle    8007ef <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cd:	ff 75 14             	pushl  0x14(%ebp)
  8007d0:	ff 75 10             	pushl  0x10(%ebp)
  8007d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d6:	50                   	push   %eax
  8007d7:	68 0e 03 80 00       	push   $0x80030e
  8007dc:	e8 6f fb ff ff       	call   800350 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ea:	83 c4 10             	add    $0x10,%esp
}
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    
		return -E_INVAL;
  8007ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f4:	eb f7                	jmp    8007ed <vsnprintf+0x49>

008007f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f6:	f3 0f 1e fb          	endbr32 
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800803:	50                   	push   %eax
  800804:	ff 75 10             	pushl  0x10(%ebp)
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	ff 75 08             	pushl  0x8(%ebp)
  80080d:	e8 92 ff ff ff       	call   8007a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800814:	f3 0f 1e fb          	endbr32 
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
  800823:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800827:	74 05                	je     80082e <strlen+0x1a>
		n++;
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	eb f5                	jmp    800823 <strlen+0xf>
	return n;
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800830:	f3 0f 1e fb          	endbr32 
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
  800842:	39 d0                	cmp    %edx,%eax
  800844:	74 0d                	je     800853 <strnlen+0x23>
  800846:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084a:	74 05                	je     800851 <strnlen+0x21>
		n++;
  80084c:	83 c0 01             	add    $0x1,%eax
  80084f:	eb f1                	jmp    800842 <strnlen+0x12>
  800851:	89 c2                	mov    %eax,%edx
	return n;
}
  800853:	89 d0                	mov    %edx,%eax
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800857:	f3 0f 1e fb          	endbr32 
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
  80086a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80086e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	84 d2                	test   %dl,%dl
  800876:	75 f2                	jne    80086a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800878:	89 c8                	mov    %ecx,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087d:	f3 0f 1e fb          	endbr32 
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	83 ec 10             	sub    $0x10,%esp
  800888:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088b:	53                   	push   %ebx
  80088c:	e8 83 ff ff ff       	call   800814 <strlen>
  800891:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800894:	ff 75 0c             	pushl  0xc(%ebp)
  800897:	01 d8                	add    %ebx,%eax
  800899:	50                   	push   %eax
  80089a:	e8 b8 ff ff ff       	call   800857 <strcpy>
	return dst;
}
  80089f:	89 d8                	mov    %ebx,%eax
  8008a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a4:	c9                   	leave  
  8008a5:	c3                   	ret    

008008a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a6:	f3 0f 1e fb          	endbr32 
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b5:	89 f3                	mov    %esi,%ebx
  8008b7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	39 d8                	cmp    %ebx,%eax
  8008be:	74 11                	je     8008d1 <strncpy+0x2b>
		*dst++ = *src;
  8008c0:	83 c0 01             	add    $0x1,%eax
  8008c3:	0f b6 0a             	movzbl (%edx),%ecx
  8008c6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c9:	80 f9 01             	cmp    $0x1,%cl
  8008cc:	83 da ff             	sbb    $0xffffffff,%edx
  8008cf:	eb eb                	jmp    8008bc <strncpy+0x16>
	}
	return ret;
}
  8008d1:	89 f0                	mov    %esi,%eax
  8008d3:	5b                   	pop    %ebx
  8008d4:	5e                   	pop    %esi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d7:	f3 0f 1e fb          	endbr32 
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008eb:	85 d2                	test   %edx,%edx
  8008ed:	74 21                	je     800910 <strlcpy+0x39>
  8008ef:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008f5:	39 c2                	cmp    %eax,%edx
  8008f7:	74 14                	je     80090d <strlcpy+0x36>
  8008f9:	0f b6 19             	movzbl (%ecx),%ebx
  8008fc:	84 db                	test   %bl,%bl
  8008fe:	74 0b                	je     80090b <strlcpy+0x34>
			*dst++ = *src++;
  800900:	83 c1 01             	add    $0x1,%ecx
  800903:	83 c2 01             	add    $0x1,%edx
  800906:	88 5a ff             	mov    %bl,-0x1(%edx)
  800909:	eb ea                	jmp    8008f5 <strlcpy+0x1e>
  80090b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80090d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800910:	29 f0                	sub    %esi,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800916:	f3 0f 1e fb          	endbr32 
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800923:	0f b6 01             	movzbl (%ecx),%eax
  800926:	84 c0                	test   %al,%al
  800928:	74 0c                	je     800936 <strcmp+0x20>
  80092a:	3a 02                	cmp    (%edx),%al
  80092c:	75 08                	jne    800936 <strcmp+0x20>
		p++, q++;
  80092e:	83 c1 01             	add    $0x1,%ecx
  800931:	83 c2 01             	add    $0x1,%edx
  800934:	eb ed                	jmp    800923 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800936:	0f b6 c0             	movzbl %al,%eax
  800939:	0f b6 12             	movzbl (%edx),%edx
  80093c:	29 d0                	sub    %edx,%eax
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800940:	f3 0f 1e fb          	endbr32 
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 c3                	mov    %eax,%ebx
  800950:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800953:	eb 06                	jmp    80095b <strncmp+0x1b>
		n--, p++, q++;
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80095b:	39 d8                	cmp    %ebx,%eax
  80095d:	74 16                	je     800975 <strncmp+0x35>
  80095f:	0f b6 08             	movzbl (%eax),%ecx
  800962:	84 c9                	test   %cl,%cl
  800964:	74 04                	je     80096a <strncmp+0x2a>
  800966:	3a 0a                	cmp    (%edx),%cl
  800968:	74 eb                	je     800955 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096a:	0f b6 00             	movzbl (%eax),%eax
  80096d:	0f b6 12             	movzbl (%edx),%edx
  800970:	29 d0                	sub    %edx,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    
		return 0;
  800975:	b8 00 00 00 00       	mov    $0x0,%eax
  80097a:	eb f6                	jmp    800972 <strncmp+0x32>

0080097c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097c:	f3 0f 1e fb          	endbr32 
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098a:	0f b6 10             	movzbl (%eax),%edx
  80098d:	84 d2                	test   %dl,%dl
  80098f:	74 09                	je     80099a <strchr+0x1e>
		if (*s == c)
  800991:	38 ca                	cmp    %cl,%dl
  800993:	74 0a                	je     80099f <strchr+0x23>
	for (; *s; s++)
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	eb f0                	jmp    80098a <strchr+0xe>
			return (char *) s;
	return 0;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8009a1:	f3 0f 1e fb          	endbr32 
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8009ab:	6a 78                	push   $0x78
  8009ad:	ff 75 08             	pushl  0x8(%ebp)
  8009b0:	e8 c7 ff ff ff       	call   80097c <strchr>
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8009c0:	eb 0d                	jmp    8009cf <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8009c2:	c1 e0 04             	shl    $0x4,%eax
  8009c5:	0f be d2             	movsbl %dl,%edx
  8009c8:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8009cc:	83 c1 01             	add    $0x1,%ecx
  8009cf:	0f b6 11             	movzbl (%ecx),%edx
  8009d2:	84 d2                	test   %dl,%dl
  8009d4:	74 11                	je     8009e7 <atox+0x46>
		if (*p>='a'){
  8009d6:	80 fa 60             	cmp    $0x60,%dl
  8009d9:	7e e7                	jle    8009c2 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8009db:	c1 e0 04             	shl    $0x4,%eax
  8009de:	0f be d2             	movsbl %dl,%edx
  8009e1:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009e5:	eb e5                	jmp    8009cc <atox+0x2b>
	}

	return v;

}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e9:	f3 0f 1e fb          	endbr32 
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fa:	38 ca                	cmp    %cl,%dl
  8009fc:	74 09                	je     800a07 <strfind+0x1e>
  8009fe:	84 d2                	test   %dl,%dl
  800a00:	74 05                	je     800a07 <strfind+0x1e>
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	eb f0                	jmp    8009f7 <strfind+0xe>
			break;
	return (char *) s;
}
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a09:	f3 0f 1e fb          	endbr32 
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a19:	85 c9                	test   %ecx,%ecx
  800a1b:	74 31                	je     800a4e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1d:	89 f8                	mov    %edi,%eax
  800a1f:	09 c8                	or     %ecx,%eax
  800a21:	a8 03                	test   $0x3,%al
  800a23:	75 23                	jne    800a48 <memset+0x3f>
		c &= 0xFF;
  800a25:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a29:	89 d3                	mov    %edx,%ebx
  800a2b:	c1 e3 08             	shl    $0x8,%ebx
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	c1 e0 18             	shl    $0x18,%eax
  800a33:	89 d6                	mov    %edx,%esi
  800a35:	c1 e6 10             	shl    $0x10,%esi
  800a38:	09 f0                	or     %esi,%eax
  800a3a:	09 c2                	or     %eax,%edx
  800a3c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a41:	89 d0                	mov    %edx,%eax
  800a43:	fc                   	cld    
  800a44:	f3 ab                	rep stos %eax,%es:(%edi)
  800a46:	eb 06                	jmp    800a4e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	fc                   	cld    
  800a4c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4e:	89 f8                	mov    %edi,%eax
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a55:	f3 0f 1e fb          	endbr32 
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a64:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a67:	39 c6                	cmp    %eax,%esi
  800a69:	73 32                	jae    800a9d <memmove+0x48>
  800a6b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6e:	39 c2                	cmp    %eax,%edx
  800a70:	76 2b                	jbe    800a9d <memmove+0x48>
		s += n;
		d += n;
  800a72:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	89 fe                	mov    %edi,%esi
  800a77:	09 ce                	or     %ecx,%esi
  800a79:	09 d6                	or     %edx,%esi
  800a7b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a81:	75 0e                	jne    800a91 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a83:	83 ef 04             	sub    $0x4,%edi
  800a86:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a89:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8f:	eb 09                	jmp    800a9a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a91:	83 ef 01             	sub    $0x1,%edi
  800a94:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a97:	fd                   	std    
  800a98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9a:	fc                   	cld    
  800a9b:	eb 1a                	jmp    800ab7 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	09 ca                	or     %ecx,%edx
  800aa1:	09 f2                	or     %esi,%edx
  800aa3:	f6 c2 03             	test   $0x3,%dl
  800aa6:	75 0a                	jne    800ab2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aab:	89 c7                	mov    %eax,%edi
  800aad:	fc                   	cld    
  800aae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab0:	eb 05                	jmp    800ab7 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ab2:	89 c7                	mov    %eax,%edi
  800ab4:	fc                   	cld    
  800ab5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abb:	f3 0f 1e fb          	endbr32 
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac5:	ff 75 10             	pushl  0x10(%ebp)
  800ac8:	ff 75 0c             	pushl  0xc(%ebp)
  800acb:	ff 75 08             	pushl  0x8(%ebp)
  800ace:	e8 82 ff ff ff       	call   800a55 <memmove>
}
  800ad3:	c9                   	leave  
  800ad4:	c3                   	ret    

00800ad5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad5:	f3 0f 1e fb          	endbr32 
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae4:	89 c6                	mov    %eax,%esi
  800ae6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae9:	39 f0                	cmp    %esi,%eax
  800aeb:	74 1c                	je     800b09 <memcmp+0x34>
		if (*s1 != *s2)
  800aed:	0f b6 08             	movzbl (%eax),%ecx
  800af0:	0f b6 1a             	movzbl (%edx),%ebx
  800af3:	38 d9                	cmp    %bl,%cl
  800af5:	75 08                	jne    800aff <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	83 c2 01             	add    $0x1,%edx
  800afd:	eb ea                	jmp    800ae9 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aff:	0f b6 c1             	movzbl %cl,%eax
  800b02:	0f b6 db             	movzbl %bl,%ebx
  800b05:	29 d8                	sub    %ebx,%eax
  800b07:	eb 05                	jmp    800b0e <memcmp+0x39>
	}

	return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b12:	f3 0f 1e fb          	endbr32 
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b24:	39 d0                	cmp    %edx,%eax
  800b26:	73 09                	jae    800b31 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b28:	38 08                	cmp    %cl,(%eax)
  800b2a:	74 05                	je     800b31 <memfind+0x1f>
	for (; s < ends; s++)
  800b2c:	83 c0 01             	add    $0x1,%eax
  800b2f:	eb f3                	jmp    800b24 <memfind+0x12>
			break;
	return (void *) s;
}
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b33:	f3 0f 1e fb          	endbr32 
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b43:	eb 03                	jmp    800b48 <strtol+0x15>
		s++;
  800b45:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b48:	0f b6 01             	movzbl (%ecx),%eax
  800b4b:	3c 20                	cmp    $0x20,%al
  800b4d:	74 f6                	je     800b45 <strtol+0x12>
  800b4f:	3c 09                	cmp    $0x9,%al
  800b51:	74 f2                	je     800b45 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b53:	3c 2b                	cmp    $0x2b,%al
  800b55:	74 2a                	je     800b81 <strtol+0x4e>
	int neg = 0;
  800b57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b5c:	3c 2d                	cmp    $0x2d,%al
  800b5e:	74 2b                	je     800b8b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b60:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b66:	75 0f                	jne    800b77 <strtol+0x44>
  800b68:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6b:	74 28                	je     800b95 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6d:	85 db                	test   %ebx,%ebx
  800b6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b74:	0f 44 d8             	cmove  %eax,%ebx
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7f:	eb 46                	jmp    800bc7 <strtol+0x94>
		s++;
  800b81:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b84:	bf 00 00 00 00       	mov    $0x0,%edi
  800b89:	eb d5                	jmp    800b60 <strtol+0x2d>
		s++, neg = 1;
  800b8b:	83 c1 01             	add    $0x1,%ecx
  800b8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b93:	eb cb                	jmp    800b60 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b99:	74 0e                	je     800ba9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b9b:	85 db                	test   %ebx,%ebx
  800b9d:	75 d8                	jne    800b77 <strtol+0x44>
		s++, base = 8;
  800b9f:	83 c1 01             	add    $0x1,%ecx
  800ba2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba7:	eb ce                	jmp    800b77 <strtol+0x44>
		s += 2, base = 16;
  800ba9:	83 c1 02             	add    $0x2,%ecx
  800bac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb1:	eb c4                	jmp    800b77 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbc:	7d 3a                	jge    800bf8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c1 01             	add    $0x1,%ecx
  800bc1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc7:	0f b6 11             	movzbl (%ecx),%edx
  800bca:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bcd:	89 f3                	mov    %esi,%ebx
  800bcf:	80 fb 09             	cmp    $0x9,%bl
  800bd2:	76 df                	jbe    800bb3 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bd4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd7:	89 f3                	mov    %esi,%ebx
  800bd9:	80 fb 19             	cmp    $0x19,%bl
  800bdc:	77 08                	ja     800be6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bde:	0f be d2             	movsbl %dl,%edx
  800be1:	83 ea 57             	sub    $0x57,%edx
  800be4:	eb d3                	jmp    800bb9 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800be6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be9:	89 f3                	mov    %esi,%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bf0:	0f be d2             	movsbl %dl,%edx
  800bf3:	83 ea 37             	sub    $0x37,%edx
  800bf6:	eb c1                	jmp    800bb9 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfc:	74 05                	je     800c03 <strtol+0xd0>
		*endptr = (char *) s;
  800bfe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c01:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c03:	89 c2                	mov    %eax,%edx
  800c05:	f7 da                	neg    %edx
  800c07:	85 ff                	test   %edi,%edi
  800c09:	0f 45 c2             	cmovne %edx,%eax
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c11:	f3 0f 1e fb          	endbr32 
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	89 c7                	mov    %eax,%edi
  800c2a:	89 c6                	mov    %eax,%esi
  800c2c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c33:	f3 0f 1e fb          	endbr32 
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 01 00 00 00       	mov    $0x1,%eax
  800c47:	89 d1                	mov    %edx,%ecx
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	89 d7                	mov    %edx,%edi
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c56:	f3 0f 1e fb          	endbr32 
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6d:	89 cb                	mov    %ecx,%ebx
  800c6f:	89 cf                	mov    %ecx,%edi
  800c71:	89 ce                	mov    %ecx,%esi
  800c73:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7a:	f3 0f 1e fb          	endbr32 
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	89 d3                	mov    %edx,%ebx
  800c92:	89 d7                	mov    %edx,%edi
  800c94:	89 d6                	mov    %edx,%esi
  800c96:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_yield>:

void
sys_yield(void)
{
  800c9d:	f3 0f 1e fb          	endbr32 
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cac:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb1:	89 d1                	mov    %edx,%ecx
  800cb3:	89 d3                	mov    %edx,%ebx
  800cb5:	89 d7                	mov    %edx,%edi
  800cb7:	89 d6                	mov    %edx,%esi
  800cb9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cca:	be 00 00 00 00       	mov    $0x0,%esi
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	b8 04 00 00 00       	mov    $0x4,%eax
  800cda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdd:	89 f7                	mov    %esi,%edi
  800cdf:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce6:	f3 0f 1e fb          	endbr32 
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 75 18             	mov    0x18(%ebp),%esi
  800d04:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0b:	f3 0f 1e fb          	endbr32 
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	b8 06 00 00 00       	mov    $0x6,%eax
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	b8 08 00 00 00       	mov    $0x8,%eax
  800d4a:	89 df                	mov    %ebx,%edi
  800d4c:	89 de                	mov    %ebx,%esi
  800d4e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d55:	f3 0f 1e fb          	endbr32 
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6f:	89 df                	mov    %ebx,%edi
  800d71:	89 de                	mov    %ebx,%esi
  800d73:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7a:	f3 0f 1e fb          	endbr32 
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9f:	f3 0f 1e fb          	endbr32 
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db4:	be 00 00 00 00       	mov    $0x0,%esi
  800db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc6:	f3 0f 1e fb          	endbr32 
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddd:	89 cb                	mov    %ecx,%ebx
  800ddf:	89 cf                	mov    %ecx,%edi
  800de1:	89 ce                	mov    %ecx,%esi
  800de3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dea:	f3 0f 1e fb          	endbr32 
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df4:	ba 00 00 00 00       	mov    $0x0,%edx
  800df9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfe:	89 d1                	mov    %edx,%ecx
  800e00:	89 d3                	mov    %edx,%ebx
  800e02:	89 d7                	mov    %edx,%edi
  800e04:	89 d6                	mov    %edx,%esi
  800e06:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800e0d:	f3 0f 1e fb          	endbr32 
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e32:	f3 0f 1e fb          	endbr32 
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e47:	b8 10 00 00 00       	mov    $0x10,%eax
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800e57:	f3 0f 1e fb          	endbr32 
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800e65:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800e67:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6b:	0f 84 9a 00 00 00    	je     800f0b <pgfault+0xb4>
  800e71:	89 d8                	mov    %ebx,%eax
  800e73:	c1 e8 16             	shr    $0x16,%eax
  800e76:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7d:	a8 01                	test   $0x1,%al
  800e7f:	0f 84 86 00 00 00    	je     800f0b <pgfault+0xb4>
  800e85:	89 d8                	mov    %ebx,%eax
  800e87:	c1 e8 0c             	shr    $0xc,%eax
  800e8a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e91:	f6 c2 01             	test   $0x1,%dl
  800e94:	74 75                	je     800f0b <pgfault+0xb4>
  800e96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e9d:	f6 c4 08             	test   $0x8,%ah
  800ea0:	74 69                	je     800f0b <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800ea2:	83 ec 04             	sub    $0x4,%esp
  800ea5:	6a 07                	push   $0x7
  800ea7:	68 00 f0 7f 00       	push   $0x7ff000
  800eac:	6a 00                	push   $0x0
  800eae:	e8 0d fe ff ff       	call   800cc0 <sys_page_alloc>
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 63                	js     800f1d <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800eba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800ec0:	83 ec 04             	sub    $0x4,%esp
  800ec3:	68 00 10 00 00       	push   $0x1000
  800ec8:	53                   	push   %ebx
  800ec9:	68 00 f0 7f 00       	push   $0x7ff000
  800ece:	e8 e8 fb ff ff       	call   800abb <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800ed3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800eda:	53                   	push   %ebx
  800edb:	6a 00                	push   $0x0
  800edd:	68 00 f0 7f 00       	push   $0x7ff000
  800ee2:	6a 00                	push   $0x0
  800ee4:	e8 fd fd ff ff       	call   800ce6 <sys_page_map>
  800ee9:	83 c4 20             	add    $0x20,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 3f                	js     800f2f <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	68 00 f0 7f 00       	push   $0x7ff000
  800ef8:	6a 00                	push   $0x0
  800efa:	e8 0c fe ff ff       	call   800d0b <sys_page_unmap>
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	78 3b                	js     800f41 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800f06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800f0b:	53                   	push   %ebx
  800f0c:	68 a0 2a 80 00       	push   $0x802aa0
  800f11:	6a 20                	push   $0x20
  800f13:	68 5e 2b 80 00       	push   $0x802b5e
  800f18:	e8 49 f2 ff ff       	call   800166 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800f1d:	50                   	push   %eax
  800f1e:	68 e0 2a 80 00       	push   $0x802ae0
  800f23:	6a 2c                	push   $0x2c
  800f25:	68 5e 2b 80 00       	push   $0x802b5e
  800f2a:	e8 37 f2 ff ff       	call   800166 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800f2f:	50                   	push   %eax
  800f30:	68 0c 2b 80 00       	push   $0x802b0c
  800f35:	6a 33                	push   $0x33
  800f37:	68 5e 2b 80 00       	push   $0x802b5e
  800f3c:	e8 25 f2 ff ff       	call   800166 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800f41:	50                   	push   %eax
  800f42:	68 34 2b 80 00       	push   $0x802b34
  800f47:	6a 36                	push   $0x36
  800f49:	68 5e 2b 80 00       	push   $0x802b5e
  800f4e:	e8 13 f2 ff ff       	call   800166 <_panic>

00800f53 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f53:	f3 0f 1e fb          	endbr32 
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	57                   	push   %edi
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800f60:	68 57 0e 80 00       	push   $0x800e57
  800f65:	e8 84 14 00 00       	call   8023ee <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f6a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6f:	cd 30                	int    $0x30
  800f71:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	78 29                	js     800fa4 <fork+0x51>
  800f7b:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  800f82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f86:	75 60                	jne    800fe8 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f88:	e8 ed fc ff ff       	call   800c7a <sys_getenvid>
  800f8d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f92:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f95:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9a:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f9f:	e9 14 01 00 00       	jmp    8010b8 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  800fa4:	50                   	push   %eax
  800fa5:	68 69 2b 80 00       	push   $0x802b69
  800faa:	68 90 00 00 00       	push   $0x90
  800faf:	68 5e 2b 80 00       	push   $0x802b5e
  800fb4:	e8 ad f1 ff ff       	call   800166 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  800fb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc8:	50                   	push   %eax
  800fc9:	56                   	push   %esi
  800fca:	57                   	push   %edi
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 13 fd ff ff       	call   800ce6 <sys_page_map>
  800fd3:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800fd6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fdc:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fe2:	0f 84 95 00 00 00    	je     80107d <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  800fe8:	89 d8                	mov    %ebx,%eax
  800fea:	c1 e8 16             	shr    $0x16,%eax
  800fed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff4:	a8 01                	test   $0x1,%al
  800ff6:	74 de                	je     800fd6 <fork+0x83>
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
  800ffd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801004:	f6 c2 01             	test   $0x1,%dl
  801007:	74 cd                	je     800fd6 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  801009:	89 c6                	mov    %eax,%esi
  80100b:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  80100e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801015:	f6 c6 04             	test   $0x4,%dh
  801018:	75 9f                	jne    800fb9 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  80101a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801021:	f6 c2 02             	test   $0x2,%dl
  801024:	75 0c                	jne    801032 <fork+0xdf>
  801026:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102d:	f6 c4 08             	test   $0x8,%ah
  801030:	74 34                	je     801066 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	68 05 08 00 00       	push   $0x805
  80103a:	56                   	push   %esi
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	6a 00                	push   $0x0
  80103f:	e8 a2 fc ff ff       	call   800ce6 <sys_page_map>
			if (r<0) return r;
  801044:	83 c4 20             	add    $0x20,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	78 8b                	js     800fd6 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	68 05 08 00 00       	push   $0x805
  801053:	56                   	push   %esi
  801054:	6a 00                	push   $0x0
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 88 fc ff ff       	call   800ce6 <sys_page_map>
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	e9 70 ff ff ff       	jmp    800fd6 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	6a 05                	push   $0x5
  80106b:	56                   	push   %esi
  80106c:	57                   	push   %edi
  80106d:	56                   	push   %esi
  80106e:	6a 00                	push   $0x0
  801070:	e8 71 fc ff ff       	call   800ce6 <sys_page_map>
  801075:	83 c4 20             	add    $0x20,%esp
  801078:	e9 59 ff ff ff       	jmp    800fd6 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  80107d:	83 ec 04             	sub    $0x4,%esp
  801080:	6a 07                	push   $0x7
  801082:	68 00 f0 bf ee       	push   $0xeebff000
  801087:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80108a:	56                   	push   %esi
  80108b:	e8 30 fc ff ff       	call   800cc0 <sys_page_alloc>
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 2b                	js     8010c2 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	68 61 24 80 00       	push   $0x802461
  80109f:	56                   	push   %esi
  8010a0:	e8 d5 fc ff ff       	call   800d7a <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  8010a5:	83 c4 08             	add    $0x8,%esp
  8010a8:	6a 02                	push   $0x2
  8010aa:	56                   	push   %esi
  8010ab:	e8 80 fc ff ff       	call   800d30 <sys_env_set_status>
  8010b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  8010b8:	89 f8                	mov    %edi,%eax
  8010ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5f                   	pop    %edi
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    
		return r;
  8010c2:	89 c7                	mov    %eax,%edi
  8010c4:	eb f2                	jmp    8010b8 <fork+0x165>

008010c6 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  8010c6:	f3 0f 1e fb          	endbr32 
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010d0:	68 85 2b 80 00       	push   $0x802b85
  8010d5:	68 b2 00 00 00       	push   $0xb2
  8010da:	68 5e 2b 80 00       	push   $0x802b5e
  8010df:	e8 82 f0 ff ff       	call   800166 <_panic>

008010e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010e4:	f3 0f 1e fb          	endbr32 
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010fd:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	50                   	push   %eax
  801104:	e8 bd fc ff ff       	call   800dc6 <sys_ipc_recv>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	85 c0                	test   %eax,%eax
  80110e:	75 2b                	jne    80113b <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801110:	85 f6                	test   %esi,%esi
  801112:	74 0a                	je     80111e <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801114:	a1 08 40 80 00       	mov    0x804008,%eax
  801119:	8b 40 74             	mov    0x74(%eax),%eax
  80111c:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80111e:	85 db                	test   %ebx,%ebx
  801120:	74 0a                	je     80112c <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801122:	a1 08 40 80 00       	mov    0x804008,%eax
  801127:	8b 40 78             	mov    0x78(%eax),%eax
  80112a:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80112c:	a1 08 40 80 00       	mov    0x804008,%eax
  801131:	8b 40 70             	mov    0x70(%eax),%eax
}
  801134:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801137:	5b                   	pop    %ebx
  801138:	5e                   	pop    %esi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80113b:	85 f6                	test   %esi,%esi
  80113d:	74 06                	je     801145 <ipc_recv+0x61>
  80113f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801145:	85 db                	test   %ebx,%ebx
  801147:	74 eb                	je     801134 <ipc_recv+0x50>
  801149:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80114f:	eb e3                	jmp    801134 <ipc_recv+0x50>

00801151 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801151:	f3 0f 1e fb          	endbr32 
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801161:	8b 75 0c             	mov    0xc(%ebp),%esi
  801164:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  801167:	85 db                	test   %ebx,%ebx
  801169:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80116e:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801171:	ff 75 14             	pushl  0x14(%ebp)
  801174:	53                   	push   %ebx
  801175:	56                   	push   %esi
  801176:	57                   	push   %edi
  801177:	e8 23 fc ff ff       	call   800d9f <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801182:	75 07                	jne    80118b <ipc_send+0x3a>
			sys_yield();
  801184:	e8 14 fb ff ff       	call   800c9d <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801189:	eb e6                	jmp    801171 <ipc_send+0x20>
		}
		else if (ret == 0)
  80118b:	85 c0                	test   %eax,%eax
  80118d:	75 08                	jne    801197 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80118f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  801197:	50                   	push   %eax
  801198:	68 9b 2b 80 00       	push   $0x802b9b
  80119d:	6a 48                	push   $0x48
  80119f:	68 a9 2b 80 00       	push   $0x802ba9
  8011a4:	e8 bd ef ff ff       	call   800166 <_panic>

008011a9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011a9:	f3 0f 1e fb          	endbr32 
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011b8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011bb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011c1:	8b 52 50             	mov    0x50(%edx),%edx
  8011c4:	39 ca                	cmp    %ecx,%edx
  8011c6:	74 11                	je     8011d9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8011c8:	83 c0 01             	add    $0x1,%eax
  8011cb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d0:	75 e6                	jne    8011b8 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d7:	eb 0b                	jmp    8011e4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8011d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e6:	f3 0f 1e fb          	endbr32 
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f0:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f5:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011fa:	f3 0f 1e fb          	endbr32 
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801201:	8b 45 08             	mov    0x8(%ebp),%eax
  801204:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801209:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80120e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801215:	f3 0f 1e fb          	endbr32 
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801221:	89 c2                	mov    %eax,%edx
  801223:	c1 ea 16             	shr    $0x16,%edx
  801226:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122d:	f6 c2 01             	test   $0x1,%dl
  801230:	74 2d                	je     80125f <fd_alloc+0x4a>
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 0c             	shr    $0xc,%edx
  801237:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	74 1c                	je     80125f <fd_alloc+0x4a>
  801243:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801248:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80124d:	75 d2                	jne    801221 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801258:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80125d:	eb 0a                	jmp    801269 <fd_alloc+0x54>
			*fd_store = fd;
  80125f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801262:	89 01                	mov    %eax,(%ecx)
			return 0;
  801264:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80126b:	f3 0f 1e fb          	endbr32 
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801275:	83 f8 1f             	cmp    $0x1f,%eax
  801278:	77 30                	ja     8012aa <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127a:	c1 e0 0c             	shl    $0xc,%eax
  80127d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801282:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801288:	f6 c2 01             	test   $0x1,%dl
  80128b:	74 24                	je     8012b1 <fd_lookup+0x46>
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	c1 ea 0c             	shr    $0xc,%edx
  801292:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801299:	f6 c2 01             	test   $0x1,%dl
  80129c:	74 1a                	je     8012b8 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80129e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    
		return -E_INVAL;
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012af:	eb f7                	jmp    8012a8 <fd_lookup+0x3d>
		return -E_INVAL;
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	eb f0                	jmp    8012a8 <fd_lookup+0x3d>
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bd:	eb e9                	jmp    8012a8 <fd_lookup+0x3d>

008012bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bf:	f3 0f 1e fb          	endbr32 
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d1:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012d6:	39 08                	cmp    %ecx,(%eax)
  8012d8:	74 38                	je     801312 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8012da:	83 c2 01             	add    $0x1,%edx
  8012dd:	8b 04 95 30 2c 80 00 	mov    0x802c30(,%edx,4),%eax
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	75 ee                	jne    8012d6 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ed:	8b 40 48             	mov    0x48(%eax),%eax
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	51                   	push   %ecx
  8012f4:	50                   	push   %eax
  8012f5:	68 b4 2b 80 00       	push   $0x802bb4
  8012fa:	e8 4e ef ff ff       	call   80024d <cprintf>
	*dev = 0;
  8012ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801302:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    
			*dev = devtab[i];
  801312:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801315:	89 01                	mov    %eax,(%ecx)
			return 0;
  801317:	b8 00 00 00 00       	mov    $0x0,%eax
  80131c:	eb f2                	jmp    801310 <dev_lookup+0x51>

0080131e <fd_close>:
{
  80131e:	f3 0f 1e fb          	endbr32 
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 24             	sub    $0x24,%esp
  80132b:	8b 75 08             	mov    0x8(%ebp),%esi
  80132e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801331:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801334:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801335:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80133b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80133e:	50                   	push   %eax
  80133f:	e8 27 ff ff ff       	call   80126b <fd_lookup>
  801344:	89 c3                	mov    %eax,%ebx
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 05                	js     801352 <fd_close+0x34>
	    || fd != fd2)
  80134d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801350:	74 16                	je     801368 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801352:	89 f8                	mov    %edi,%eax
  801354:	84 c0                	test   %al,%al
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	0f 44 d8             	cmove  %eax,%ebx
}
  80135e:	89 d8                	mov    %ebx,%eax
  801360:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5f                   	pop    %edi
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	ff 36                	pushl  (%esi)
  801371:	e8 49 ff ff ff       	call   8012bf <dev_lookup>
  801376:	89 c3                	mov    %eax,%ebx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 1a                	js     801399 <fd_close+0x7b>
		if (dev->dev_close)
  80137f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801382:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801385:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80138a:	85 c0                	test   %eax,%eax
  80138c:	74 0b                	je     801399 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	56                   	push   %esi
  801392:	ff d0                	call   *%eax
  801394:	89 c3                	mov    %eax,%ebx
  801396:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	56                   	push   %esi
  80139d:	6a 00                	push   $0x0
  80139f:	e8 67 f9 ff ff       	call   800d0b <sys_page_unmap>
	return r;
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	eb b5                	jmp    80135e <fd_close+0x40>

008013a9 <close>:

int
close(int fdnum)
{
  8013a9:	f3 0f 1e fb          	endbr32 
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 75 08             	pushl  0x8(%ebp)
  8013ba:	e8 ac fe ff ff       	call   80126b <fd_lookup>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	79 02                	jns    8013c8 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    
		return fd_close(fd, 1);
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	6a 01                	push   $0x1
  8013cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d0:	e8 49 ff ff ff       	call   80131e <fd_close>
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	eb ec                	jmp    8013c6 <close+0x1d>

008013da <close_all>:

void
close_all(void)
{
  8013da:	f3 0f 1e fb          	endbr32 
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	53                   	push   %ebx
  8013ee:	e8 b6 ff ff ff       	call   8013a9 <close>
	for (i = 0; i < MAXFD; i++)
  8013f3:	83 c3 01             	add    $0x1,%ebx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	83 fb 20             	cmp    $0x20,%ebx
  8013fc:	75 ec                	jne    8013ea <close_all+0x10>
}
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801403:	f3 0f 1e fb          	endbr32 
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	57                   	push   %edi
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801410:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	ff 75 08             	pushl  0x8(%ebp)
  801417:	e8 4f fe ff ff       	call   80126b <fd_lookup>
  80141c:	89 c3                	mov    %eax,%ebx
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	0f 88 81 00 00 00    	js     8014aa <dup+0xa7>
		return r;
	close(newfdnum);
  801429:	83 ec 0c             	sub    $0xc,%esp
  80142c:	ff 75 0c             	pushl  0xc(%ebp)
  80142f:	e8 75 ff ff ff       	call   8013a9 <close>

	newfd = INDEX2FD(newfdnum);
  801434:	8b 75 0c             	mov    0xc(%ebp),%esi
  801437:	c1 e6 0c             	shl    $0xc,%esi
  80143a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801440:	83 c4 04             	add    $0x4,%esp
  801443:	ff 75 e4             	pushl  -0x1c(%ebp)
  801446:	e8 af fd ff ff       	call   8011fa <fd2data>
  80144b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80144d:	89 34 24             	mov    %esi,(%esp)
  801450:	e8 a5 fd ff ff       	call   8011fa <fd2data>
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145a:	89 d8                	mov    %ebx,%eax
  80145c:	c1 e8 16             	shr    $0x16,%eax
  80145f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801466:	a8 01                	test   $0x1,%al
  801468:	74 11                	je     80147b <dup+0x78>
  80146a:	89 d8                	mov    %ebx,%eax
  80146c:	c1 e8 0c             	shr    $0xc,%eax
  80146f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801476:	f6 c2 01             	test   $0x1,%dl
  801479:	75 39                	jne    8014b4 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80147b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80147e:	89 d0                	mov    %edx,%eax
  801480:	c1 e8 0c             	shr    $0xc,%eax
  801483:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148a:	83 ec 0c             	sub    $0xc,%esp
  80148d:	25 07 0e 00 00       	and    $0xe07,%eax
  801492:	50                   	push   %eax
  801493:	56                   	push   %esi
  801494:	6a 00                	push   $0x0
  801496:	52                   	push   %edx
  801497:	6a 00                	push   $0x0
  801499:	e8 48 f8 ff ff       	call   800ce6 <sys_page_map>
  80149e:	89 c3                	mov    %eax,%ebx
  8014a0:	83 c4 20             	add    $0x20,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 31                	js     8014d8 <dup+0xd5>
		goto err;

	return newfdnum;
  8014a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014aa:	89 d8                	mov    %ebx,%eax
  8014ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014af:	5b                   	pop    %ebx
  8014b0:	5e                   	pop    %esi
  8014b1:	5f                   	pop    %edi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c3:	50                   	push   %eax
  8014c4:	57                   	push   %edi
  8014c5:	6a 00                	push   $0x0
  8014c7:	53                   	push   %ebx
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 17 f8 ff ff       	call   800ce6 <sys_page_map>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	83 c4 20             	add    $0x20,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	79 a3                	jns    80147b <dup+0x78>
	sys_page_unmap(0, newfd);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	56                   	push   %esi
  8014dc:	6a 00                	push   $0x0
  8014de:	e8 28 f8 ff ff       	call   800d0b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	57                   	push   %edi
  8014e7:	6a 00                	push   $0x0
  8014e9:	e8 1d f8 ff ff       	call   800d0b <sys_page_unmap>
	return r;
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	eb b7                	jmp    8014aa <dup+0xa7>

008014f3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f3:	f3 0f 1e fb          	endbr32 
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	53                   	push   %ebx
  8014fb:	83 ec 1c             	sub    $0x1c,%esp
  8014fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801501:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	53                   	push   %ebx
  801506:	e8 60 fd ff ff       	call   80126b <fd_lookup>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 3f                	js     801551 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151c:	ff 30                	pushl  (%eax)
  80151e:	e8 9c fd ff ff       	call   8012bf <dev_lookup>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 27                	js     801551 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152d:	8b 42 08             	mov    0x8(%edx),%eax
  801530:	83 e0 03             	and    $0x3,%eax
  801533:	83 f8 01             	cmp    $0x1,%eax
  801536:	74 1e                	je     801556 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153b:	8b 40 08             	mov    0x8(%eax),%eax
  80153e:	85 c0                	test   %eax,%eax
  801540:	74 35                	je     801577 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801542:	83 ec 04             	sub    $0x4,%esp
  801545:	ff 75 10             	pushl  0x10(%ebp)
  801548:	ff 75 0c             	pushl  0xc(%ebp)
  80154b:	52                   	push   %edx
  80154c:	ff d0                	call   *%eax
  80154e:	83 c4 10             	add    $0x10,%esp
}
  801551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801554:	c9                   	leave  
  801555:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801556:	a1 08 40 80 00       	mov    0x804008,%eax
  80155b:	8b 40 48             	mov    0x48(%eax),%eax
  80155e:	83 ec 04             	sub    $0x4,%esp
  801561:	53                   	push   %ebx
  801562:	50                   	push   %eax
  801563:	68 f5 2b 80 00       	push   $0x802bf5
  801568:	e8 e0 ec ff ff       	call   80024d <cprintf>
		return -E_INVAL;
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801575:	eb da                	jmp    801551 <read+0x5e>
		return -E_NOT_SUPP;
  801577:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80157c:	eb d3                	jmp    801551 <read+0x5e>

0080157e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80157e:	f3 0f 1e fb          	endbr32 
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801591:	bb 00 00 00 00       	mov    $0x0,%ebx
  801596:	eb 02                	jmp    80159a <readn+0x1c>
  801598:	01 c3                	add    %eax,%ebx
  80159a:	39 f3                	cmp    %esi,%ebx
  80159c:	73 21                	jae    8015bf <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	89 f0                	mov    %esi,%eax
  8015a3:	29 d8                	sub    %ebx,%eax
  8015a5:	50                   	push   %eax
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	03 45 0c             	add    0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	57                   	push   %edi
  8015ad:	e8 41 ff ff ff       	call   8014f3 <read>
		if (m < 0)
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 04                	js     8015bd <readn+0x3f>
			return m;
		if (m == 0)
  8015b9:	75 dd                	jne    801598 <readn+0x1a>
  8015bb:	eb 02                	jmp    8015bf <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bd:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c9:	f3 0f 1e fb          	endbr32 
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 1c             	sub    $0x1c,%esp
  8015d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015da:	50                   	push   %eax
  8015db:	53                   	push   %ebx
  8015dc:	e8 8a fc ff ff       	call   80126b <fd_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 3a                	js     801622 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	ff 30                	pushl  (%eax)
  8015f4:	e8 c6 fc ff ff       	call   8012bf <dev_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 22                	js     801622 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801607:	74 1e                	je     801627 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801609:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160c:	8b 52 0c             	mov    0xc(%edx),%edx
  80160f:	85 d2                	test   %edx,%edx
  801611:	74 35                	je     801648 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801613:	83 ec 04             	sub    $0x4,%esp
  801616:	ff 75 10             	pushl  0x10(%ebp)
  801619:	ff 75 0c             	pushl  0xc(%ebp)
  80161c:	50                   	push   %eax
  80161d:	ff d2                	call   *%edx
  80161f:	83 c4 10             	add    $0x10,%esp
}
  801622:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801625:	c9                   	leave  
  801626:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801627:	a1 08 40 80 00       	mov    0x804008,%eax
  80162c:	8b 40 48             	mov    0x48(%eax),%eax
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	53                   	push   %ebx
  801633:	50                   	push   %eax
  801634:	68 11 2c 80 00       	push   $0x802c11
  801639:	e8 0f ec ff ff       	call   80024d <cprintf>
		return -E_INVAL;
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801646:	eb da                	jmp    801622 <write+0x59>
		return -E_NOT_SUPP;
  801648:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80164d:	eb d3                	jmp    801622 <write+0x59>

0080164f <seek>:

int
seek(int fdnum, off_t offset)
{
  80164f:	f3 0f 1e fb          	endbr32 
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	ff 75 08             	pushl  0x8(%ebp)
  801660:	e8 06 fc ff ff       	call   80126b <fd_lookup>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 0e                	js     80167a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80166c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801672:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801675:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80167c:	f3 0f 1e fb          	endbr32 
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	53                   	push   %ebx
  801684:	83 ec 1c             	sub    $0x1c,%esp
  801687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	53                   	push   %ebx
  80168f:	e8 d7 fb ff ff       	call   80126b <fd_lookup>
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 37                	js     8016d2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	ff 30                	pushl  (%eax)
  8016a7:	e8 13 fc ff ff       	call   8012bf <dev_lookup>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 1f                	js     8016d2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ba:	74 1b                	je     8016d7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bf:	8b 52 18             	mov    0x18(%edx),%edx
  8016c2:	85 d2                	test   %edx,%edx
  8016c4:	74 32                	je     8016f8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	ff 75 0c             	pushl  0xc(%ebp)
  8016cc:	50                   	push   %eax
  8016cd:	ff d2                	call   *%edx
  8016cf:	83 c4 10             	add    $0x10,%esp
}
  8016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016d7:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016dc:	8b 40 48             	mov    0x48(%eax),%eax
  8016df:	83 ec 04             	sub    $0x4,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	50                   	push   %eax
  8016e4:	68 d4 2b 80 00       	push   $0x802bd4
  8016e9:	e8 5f eb ff ff       	call   80024d <cprintf>
		return -E_INVAL;
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f6:	eb da                	jmp    8016d2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016fd:	eb d3                	jmp    8016d2 <ftruncate+0x56>

008016ff <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ff:	f3 0f 1e fb          	endbr32 
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	83 ec 1c             	sub    $0x1c,%esp
  80170a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	ff 75 08             	pushl  0x8(%ebp)
  801714:	e8 52 fb ff ff       	call   80126b <fd_lookup>
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 4b                	js     80176b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801726:	50                   	push   %eax
  801727:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172a:	ff 30                	pushl  (%eax)
  80172c:	e8 8e fb ff ff       	call   8012bf <dev_lookup>
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	85 c0                	test   %eax,%eax
  801736:	78 33                	js     80176b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80173f:	74 2f                	je     801770 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801741:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801744:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174b:	00 00 00 
	stat->st_isdir = 0;
  80174e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801755:	00 00 00 
	stat->st_dev = dev;
  801758:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80175e:	83 ec 08             	sub    $0x8,%esp
  801761:	53                   	push   %ebx
  801762:	ff 75 f0             	pushl  -0x10(%ebp)
  801765:	ff 50 14             	call   *0x14(%eax)
  801768:	83 c4 10             	add    $0x10,%esp
}
  80176b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    
		return -E_NOT_SUPP;
  801770:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801775:	eb f4                	jmp    80176b <fstat+0x6c>

00801777 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801777:	f3 0f 1e fb          	endbr32 
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	6a 00                	push   $0x0
  801785:	ff 75 08             	pushl  0x8(%ebp)
  801788:	e8 01 02 00 00       	call   80198e <open>
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	78 1b                	js     8017b1 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	ff 75 0c             	pushl  0xc(%ebp)
  80179c:	50                   	push   %eax
  80179d:	e8 5d ff ff ff       	call   8016ff <fstat>
  8017a2:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a4:	89 1c 24             	mov    %ebx,(%esp)
  8017a7:	e8 fd fb ff ff       	call   8013a9 <close>
	return r;
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	89 f3                	mov    %esi,%ebx
}
  8017b1:	89 d8                	mov    %ebx,%eax
  8017b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b6:	5b                   	pop    %ebx
  8017b7:	5e                   	pop    %esi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	89 c6                	mov    %eax,%esi
  8017c1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017c3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ca:	74 27                	je     8017f3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017cc:	6a 07                	push   $0x7
  8017ce:	68 00 50 80 00       	push   $0x805000
  8017d3:	56                   	push   %esi
  8017d4:	ff 35 00 40 80 00    	pushl  0x804000
  8017da:	e8 72 f9 ff ff       	call   801151 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017df:	83 c4 0c             	add    $0xc,%esp
  8017e2:	6a 00                	push   $0x0
  8017e4:	53                   	push   %ebx
  8017e5:	6a 00                	push   $0x0
  8017e7:	e8 f8 f8 ff ff       	call   8010e4 <ipc_recv>
}
  8017ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f3:	83 ec 0c             	sub    $0xc,%esp
  8017f6:	6a 01                	push   $0x1
  8017f8:	e8 ac f9 ff ff       	call   8011a9 <ipc_find_env>
  8017fd:	a3 00 40 80 00       	mov    %eax,0x804000
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	eb c5                	jmp    8017cc <fsipc+0x12>

00801807 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801807:	f3 0f 1e fb          	endbr32 
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80181c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801824:	ba 00 00 00 00       	mov    $0x0,%edx
  801829:	b8 02 00 00 00       	mov    $0x2,%eax
  80182e:	e8 87 ff ff ff       	call   8017ba <fsipc>
}
  801833:	c9                   	leave  
  801834:	c3                   	ret    

00801835 <devfile_flush>:
{
  801835:	f3 0f 1e fb          	endbr32 
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	8b 40 0c             	mov    0xc(%eax),%eax
  801845:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80184a:	ba 00 00 00 00       	mov    $0x0,%edx
  80184f:	b8 06 00 00 00       	mov    $0x6,%eax
  801854:	e8 61 ff ff ff       	call   8017ba <fsipc>
}
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <devfile_stat>:
{
  80185b:	f3 0f 1e fb          	endbr32 
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	53                   	push   %ebx
  801863:	83 ec 04             	sub    $0x4,%esp
  801866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	8b 40 0c             	mov    0xc(%eax),%eax
  80186f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 05 00 00 00       	mov    $0x5,%eax
  80187e:	e8 37 ff ff ff       	call   8017ba <fsipc>
  801883:	85 c0                	test   %eax,%eax
  801885:	78 2c                	js     8018b3 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	68 00 50 80 00       	push   $0x805000
  80188f:	53                   	push   %ebx
  801890:	e8 c2 ef ff ff       	call   800857 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801895:	a1 80 50 80 00       	mov    0x805080,%eax
  80189a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018a5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <devfile_write>:
{
  8018b8:	f3 0f 1e fb          	endbr32 
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c5:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018ca:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018cf:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018de:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018e3:	50                   	push   %eax
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	68 08 50 80 00       	push   $0x805008
  8018ec:	e8 64 f1 ff ff       	call   800a55 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018fb:	e8 ba fe ff ff       	call   8017ba <fsipc>
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <devfile_read>:
{
  801902:	f3 0f 1e fb          	endbr32 
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	8b 40 0c             	mov    0xc(%eax),%eax
  801914:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801919:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80191f:	ba 00 00 00 00       	mov    $0x0,%edx
  801924:	b8 03 00 00 00       	mov    $0x3,%eax
  801929:	e8 8c fe ff ff       	call   8017ba <fsipc>
  80192e:	89 c3                	mov    %eax,%ebx
  801930:	85 c0                	test   %eax,%eax
  801932:	78 1f                	js     801953 <devfile_read+0x51>
	assert(r <= n);
  801934:	39 f0                	cmp    %esi,%eax
  801936:	77 24                	ja     80195c <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801938:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80193d:	7f 36                	jg     801975 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80193f:	83 ec 04             	sub    $0x4,%esp
  801942:	50                   	push   %eax
  801943:	68 00 50 80 00       	push   $0x805000
  801948:	ff 75 0c             	pushl  0xc(%ebp)
  80194b:	e8 05 f1 ff ff       	call   800a55 <memmove>
	return r;
  801950:	83 c4 10             	add    $0x10,%esp
}
  801953:	89 d8                	mov    %ebx,%eax
  801955:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    
	assert(r <= n);
  80195c:	68 44 2c 80 00       	push   $0x802c44
  801961:	68 4b 2c 80 00       	push   $0x802c4b
  801966:	68 8c 00 00 00       	push   $0x8c
  80196b:	68 60 2c 80 00       	push   $0x802c60
  801970:	e8 f1 e7 ff ff       	call   800166 <_panic>
	assert(r <= PGSIZE);
  801975:	68 6b 2c 80 00       	push   $0x802c6b
  80197a:	68 4b 2c 80 00       	push   $0x802c4b
  80197f:	68 8d 00 00 00       	push   $0x8d
  801984:	68 60 2c 80 00       	push   $0x802c60
  801989:	e8 d8 e7 ff ff       	call   800166 <_panic>

0080198e <open>:
{
  80198e:	f3 0f 1e fb          	endbr32 
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	83 ec 1c             	sub    $0x1c,%esp
  80199a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80199d:	56                   	push   %esi
  80199e:	e8 71 ee ff ff       	call   800814 <strlen>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ab:	7f 6c                	jg     801a19 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	e8 5c f8 ff ff       	call   801215 <fd_alloc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 3c                	js     8019fe <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	56                   	push   %esi
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	e8 87 ee ff ff       	call   800857 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019db:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e0:	e8 d5 fd ff ff       	call   8017ba <fsipc>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 19                	js     801a07 <open+0x79>
	return fd2num(fd);
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f4:	e8 ed f7 ff ff       	call   8011e6 <fd2num>
  8019f9:	89 c3                	mov    %eax,%ebx
  8019fb:	83 c4 10             	add    $0x10,%esp
}
  8019fe:	89 d8                	mov    %ebx,%eax
  801a00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    
		fd_close(fd, 0);
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	6a 00                	push   $0x0
  801a0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0f:	e8 0a f9 ff ff       	call   80131e <fd_close>
		return r;
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	eb e5                	jmp    8019fe <open+0x70>
		return -E_BAD_PATH;
  801a19:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a1e:	eb de                	jmp    8019fe <open+0x70>

00801a20 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a20:	f3 0f 1e fb          	endbr32 
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a34:	e8 81 fd ff ff       	call   8017ba <fsipc>
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a3b:	f3 0f 1e fb          	endbr32 
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a45:	68 d7 2c 80 00       	push   $0x802cd7
  801a4a:	ff 75 0c             	pushl  0xc(%ebp)
  801a4d:	e8 05 ee ff ff       	call   800857 <strcpy>
	return 0;
}
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <devsock_close>:
{
  801a59:	f3 0f 1e fb          	endbr32 
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	53                   	push   %ebx
  801a61:	83 ec 10             	sub    $0x10,%esp
  801a64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a67:	53                   	push   %ebx
  801a68:	e8 18 0a 00 00       	call   802485 <pageref>
  801a6d:	89 c2                	mov    %eax,%edx
  801a6f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a72:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a77:	83 fa 01             	cmp    $0x1,%edx
  801a7a:	74 05                	je     801a81 <devsock_close+0x28>
}
  801a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	ff 73 0c             	pushl  0xc(%ebx)
  801a87:	e8 e3 02 00 00       	call   801d6f <nsipc_close>
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	eb eb                	jmp    801a7c <devsock_close+0x23>

00801a91 <devsock_write>:
{
  801a91:	f3 0f 1e fb          	endbr32 
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a9b:	6a 00                	push   $0x0
  801a9d:	ff 75 10             	pushl  0x10(%ebp)
  801aa0:	ff 75 0c             	pushl  0xc(%ebp)
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	ff 70 0c             	pushl  0xc(%eax)
  801aa9:	e8 b5 03 00 00       	call   801e63 <nsipc_send>
}
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <devsock_read>:
{
  801ab0:	f3 0f 1e fb          	endbr32 
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801aba:	6a 00                	push   $0x0
  801abc:	ff 75 10             	pushl  0x10(%ebp)
  801abf:	ff 75 0c             	pushl  0xc(%ebp)
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	ff 70 0c             	pushl  0xc(%eax)
  801ac8:	e8 1f 03 00 00       	call   801dec <nsipc_recv>
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <fd2sockid>:
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ad5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ad8:	52                   	push   %edx
  801ad9:	50                   	push   %eax
  801ada:	e8 8c f7 ff ff       	call   80126b <fd_lookup>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 10                	js     801af6 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae9:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801aef:	39 08                	cmp    %ecx,(%eax)
  801af1:	75 05                	jne    801af8 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801af3:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    
		return -E_NOT_SUPP;
  801af8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801afd:	eb f7                	jmp    801af6 <fd2sockid+0x27>

00801aff <alloc_sockfd>:
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	56                   	push   %esi
  801b03:	53                   	push   %ebx
  801b04:	83 ec 1c             	sub    $0x1c,%esp
  801b07:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0c:	50                   	push   %eax
  801b0d:	e8 03 f7 ff ff       	call   801215 <fd_alloc>
  801b12:	89 c3                	mov    %eax,%ebx
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 43                	js     801b5e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	68 07 04 00 00       	push   $0x407
  801b23:	ff 75 f4             	pushl  -0xc(%ebp)
  801b26:	6a 00                	push   $0x0
  801b28:	e8 93 f1 ff ff       	call   800cc0 <sys_page_alloc>
  801b2d:	89 c3                	mov    %eax,%ebx
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 28                	js     801b5e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b39:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b3f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b44:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b4b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b4e:	83 ec 0c             	sub    $0xc,%esp
  801b51:	50                   	push   %eax
  801b52:	e8 8f f6 ff ff       	call   8011e6 <fd2num>
  801b57:	89 c3                	mov    %eax,%ebx
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	eb 0c                	jmp    801b6a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b5e:	83 ec 0c             	sub    $0xc,%esp
  801b61:	56                   	push   %esi
  801b62:	e8 08 02 00 00       	call   801d6f <nsipc_close>
		return r;
  801b67:	83 c4 10             	add    $0x10,%esp
}
  801b6a:	89 d8                	mov    %ebx,%eax
  801b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <accept>:
{
  801b73:	f3 0f 1e fb          	endbr32 
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b80:	e8 4a ff ff ff       	call   801acf <fd2sockid>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 1b                	js     801ba4 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	ff 75 10             	pushl  0x10(%ebp)
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	50                   	push   %eax
  801b93:	e8 22 01 00 00       	call   801cba <nsipc_accept>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 05                	js     801ba4 <accept+0x31>
	return alloc_sockfd(r);
  801b9f:	e8 5b ff ff ff       	call   801aff <alloc_sockfd>
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <bind>:
{
  801ba6:	f3 0f 1e fb          	endbr32 
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb3:	e8 17 ff ff ff       	call   801acf <fd2sockid>
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 12                	js     801bce <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	ff 75 10             	pushl  0x10(%ebp)
  801bc2:	ff 75 0c             	pushl  0xc(%ebp)
  801bc5:	50                   	push   %eax
  801bc6:	e8 45 01 00 00       	call   801d10 <nsipc_bind>
  801bcb:	83 c4 10             	add    $0x10,%esp
}
  801bce:	c9                   	leave  
  801bcf:	c3                   	ret    

00801bd0 <shutdown>:
{
  801bd0:	f3 0f 1e fb          	endbr32 
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bda:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdd:	e8 ed fe ff ff       	call   801acf <fd2sockid>
  801be2:	85 c0                	test   %eax,%eax
  801be4:	78 0f                	js     801bf5 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801be6:	83 ec 08             	sub    $0x8,%esp
  801be9:	ff 75 0c             	pushl  0xc(%ebp)
  801bec:	50                   	push   %eax
  801bed:	e8 57 01 00 00       	call   801d49 <nsipc_shutdown>
  801bf2:	83 c4 10             	add    $0x10,%esp
}
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <connect>:
{
  801bf7:	f3 0f 1e fb          	endbr32 
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	e8 c6 fe ff ff       	call   801acf <fd2sockid>
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 12                	js     801c1f <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801c0d:	83 ec 04             	sub    $0x4,%esp
  801c10:	ff 75 10             	pushl  0x10(%ebp)
  801c13:	ff 75 0c             	pushl  0xc(%ebp)
  801c16:	50                   	push   %eax
  801c17:	e8 71 01 00 00       	call   801d8d <nsipc_connect>
  801c1c:	83 c4 10             	add    $0x10,%esp
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <listen>:
{
  801c21:	f3 0f 1e fb          	endbr32 
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	e8 9c fe ff ff       	call   801acf <fd2sockid>
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 0f                	js     801c46 <listen+0x25>
	return nsipc_listen(r, backlog);
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	ff 75 0c             	pushl  0xc(%ebp)
  801c3d:	50                   	push   %eax
  801c3e:	e8 83 01 00 00       	call   801dc6 <nsipc_listen>
  801c43:	83 c4 10             	add    $0x10,%esp
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c48:	f3 0f 1e fb          	endbr32 
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c52:	ff 75 10             	pushl  0x10(%ebp)
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	ff 75 08             	pushl  0x8(%ebp)
  801c5b:	e8 65 02 00 00       	call   801ec5 <nsipc_socket>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	78 05                	js     801c6c <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801c67:	e8 93 fe ff ff       	call   801aff <alloc_sockfd>
}
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	53                   	push   %ebx
  801c72:	83 ec 04             	sub    $0x4,%esp
  801c75:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c77:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c7e:	74 26                	je     801ca6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c80:	6a 07                	push   $0x7
  801c82:	68 00 60 80 00       	push   $0x806000
  801c87:	53                   	push   %ebx
  801c88:	ff 35 04 40 80 00    	pushl  0x804004
  801c8e:	e8 be f4 ff ff       	call   801151 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c93:	83 c4 0c             	add    $0xc,%esp
  801c96:	6a 00                	push   $0x0
  801c98:	6a 00                	push   $0x0
  801c9a:	6a 00                	push   $0x0
  801c9c:	e8 43 f4 ff ff       	call   8010e4 <ipc_recv>
}
  801ca1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ca6:	83 ec 0c             	sub    $0xc,%esp
  801ca9:	6a 02                	push   $0x2
  801cab:	e8 f9 f4 ff ff       	call   8011a9 <ipc_find_env>
  801cb0:	a3 04 40 80 00       	mov    %eax,0x804004
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	eb c6                	jmp    801c80 <nsipc+0x12>

00801cba <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cba:	f3 0f 1e fb          	endbr32 
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
  801cc3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cce:	8b 06                	mov    (%esi),%eax
  801cd0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801cd5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cda:	e8 8f ff ff ff       	call   801c6e <nsipc>
  801cdf:	89 c3                	mov    %eax,%ebx
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	79 09                	jns    801cee <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801ce5:	89 d8                	mov    %ebx,%eax
  801ce7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cea:	5b                   	pop    %ebx
  801ceb:	5e                   	pop    %esi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cee:	83 ec 04             	sub    $0x4,%esp
  801cf1:	ff 35 10 60 80 00    	pushl  0x806010
  801cf7:	68 00 60 80 00       	push   $0x806000
  801cfc:	ff 75 0c             	pushl  0xc(%ebp)
  801cff:	e8 51 ed ff ff       	call   800a55 <memmove>
		*addrlen = ret->ret_addrlen;
  801d04:	a1 10 60 80 00       	mov    0x806010,%eax
  801d09:	89 06                	mov    %eax,(%esi)
  801d0b:	83 c4 10             	add    $0x10,%esp
	return r;
  801d0e:	eb d5                	jmp    801ce5 <nsipc_accept+0x2b>

00801d10 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d10:	f3 0f 1e fb          	endbr32 
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	53                   	push   %ebx
  801d18:	83 ec 08             	sub    $0x8,%esp
  801d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d26:	53                   	push   %ebx
  801d27:	ff 75 0c             	pushl  0xc(%ebp)
  801d2a:	68 04 60 80 00       	push   $0x806004
  801d2f:	e8 21 ed ff ff       	call   800a55 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d34:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d3a:	b8 02 00 00 00       	mov    $0x2,%eax
  801d3f:	e8 2a ff ff ff       	call   801c6e <nsipc>
}
  801d44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d49:	f3 0f 1e fb          	endbr32 
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d53:	8b 45 08             	mov    0x8(%ebp),%eax
  801d56:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d63:	b8 03 00 00 00       	mov    $0x3,%eax
  801d68:	e8 01 ff ff ff       	call   801c6e <nsipc>
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <nsipc_close>:

int
nsipc_close(int s)
{
  801d6f:	f3 0f 1e fb          	endbr32 
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d81:	b8 04 00 00 00       	mov    $0x4,%eax
  801d86:	e8 e3 fe ff ff       	call   801c6e <nsipc>
}
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    

00801d8d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d8d:	f3 0f 1e fb          	endbr32 
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	53                   	push   %ebx
  801d95:	83 ec 08             	sub    $0x8,%esp
  801d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801da3:	53                   	push   %ebx
  801da4:	ff 75 0c             	pushl  0xc(%ebp)
  801da7:	68 04 60 80 00       	push   $0x806004
  801dac:	e8 a4 ec ff ff       	call   800a55 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801db1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801db7:	b8 05 00 00 00       	mov    $0x5,%eax
  801dbc:	e8 ad fe ff ff       	call   801c6e <nsipc>
}
  801dc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dc6:	f3 0f 1e fb          	endbr32 
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801de0:	b8 06 00 00 00       	mov    $0x6,%eax
  801de5:	e8 84 fe ff ff       	call   801c6e <nsipc>
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dec:	f3 0f 1e fb          	endbr32 
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	56                   	push   %esi
  801df4:	53                   	push   %ebx
  801df5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801df8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e00:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e06:	8b 45 14             	mov    0x14(%ebp),%eax
  801e09:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e0e:	b8 07 00 00 00       	mov    $0x7,%eax
  801e13:	e8 56 fe ff ff       	call   801c6e <nsipc>
  801e18:	89 c3                	mov    %eax,%ebx
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	78 26                	js     801e44 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801e1e:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801e24:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e29:	0f 4e c6             	cmovle %esi,%eax
  801e2c:	39 c3                	cmp    %eax,%ebx
  801e2e:	7f 1d                	jg     801e4d <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e30:	83 ec 04             	sub    $0x4,%esp
  801e33:	53                   	push   %ebx
  801e34:	68 00 60 80 00       	push   $0x806000
  801e39:	ff 75 0c             	pushl  0xc(%ebp)
  801e3c:	e8 14 ec ff ff       	call   800a55 <memmove>
  801e41:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e44:	89 d8                	mov    %ebx,%eax
  801e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e49:	5b                   	pop    %ebx
  801e4a:	5e                   	pop    %esi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e4d:	68 e3 2c 80 00       	push   $0x802ce3
  801e52:	68 4b 2c 80 00       	push   $0x802c4b
  801e57:	6a 62                	push   $0x62
  801e59:	68 f8 2c 80 00       	push   $0x802cf8
  801e5e:	e8 03 e3 ff ff       	call   800166 <_panic>

00801e63 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e63:	f3 0f 1e fb          	endbr32 
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	53                   	push   %ebx
  801e6b:	83 ec 04             	sub    $0x4,%esp
  801e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e79:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e7f:	7f 2e                	jg     801eaf <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e81:	83 ec 04             	sub    $0x4,%esp
  801e84:	53                   	push   %ebx
  801e85:	ff 75 0c             	pushl  0xc(%ebp)
  801e88:	68 0c 60 80 00       	push   $0x80600c
  801e8d:	e8 c3 eb ff ff       	call   800a55 <memmove>
	nsipcbuf.send.req_size = size;
  801e92:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e98:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ea0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea5:	e8 c4 fd ff ff       	call   801c6e <nsipc>
}
  801eaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    
	assert(size < 1600);
  801eaf:	68 04 2d 80 00       	push   $0x802d04
  801eb4:	68 4b 2c 80 00       	push   $0x802c4b
  801eb9:	6a 6d                	push   $0x6d
  801ebb:	68 f8 2c 80 00       	push   $0x802cf8
  801ec0:	e8 a1 e2 ff ff       	call   800166 <_panic>

00801ec5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ec5:	f3 0f 1e fb          	endbr32 
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eda:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801edf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ee7:	b8 09 00 00 00       	mov    $0x9,%eax
  801eec:	e8 7d fd ff ff       	call   801c6e <nsipc>
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ef3:	f3 0f 1e fb          	endbr32 
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	56                   	push   %esi
  801efb:	53                   	push   %ebx
  801efc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	ff 75 08             	pushl  0x8(%ebp)
  801f05:	e8 f0 f2 ff ff       	call   8011fa <fd2data>
  801f0a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f0c:	83 c4 08             	add    $0x8,%esp
  801f0f:	68 10 2d 80 00       	push   $0x802d10
  801f14:	53                   	push   %ebx
  801f15:	e8 3d e9 ff ff       	call   800857 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f1a:	8b 46 04             	mov    0x4(%esi),%eax
  801f1d:	2b 06                	sub    (%esi),%eax
  801f1f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f25:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f2c:	00 00 00 
	stat->st_dev = &devpipe;
  801f2f:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f36:	30 80 00 
	return 0;
}
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f45:	f3 0f 1e fb          	endbr32 
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 0c             	sub    $0xc,%esp
  801f50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f53:	53                   	push   %ebx
  801f54:	6a 00                	push   $0x0
  801f56:	e8 b0 ed ff ff       	call   800d0b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f5b:	89 1c 24             	mov    %ebx,(%esp)
  801f5e:	e8 97 f2 ff ff       	call   8011fa <fd2data>
  801f63:	83 c4 08             	add    $0x8,%esp
  801f66:	50                   	push   %eax
  801f67:	6a 00                	push   $0x0
  801f69:	e8 9d ed ff ff       	call   800d0b <sys_page_unmap>
}
  801f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <_pipeisclosed>:
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	57                   	push   %edi
  801f77:	56                   	push   %esi
  801f78:	53                   	push   %ebx
  801f79:	83 ec 1c             	sub    $0x1c,%esp
  801f7c:	89 c7                	mov    %eax,%edi
  801f7e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f80:	a1 08 40 80 00       	mov    0x804008,%eax
  801f85:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f88:	83 ec 0c             	sub    $0xc,%esp
  801f8b:	57                   	push   %edi
  801f8c:	e8 f4 04 00 00       	call   802485 <pageref>
  801f91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f94:	89 34 24             	mov    %esi,(%esp)
  801f97:	e8 e9 04 00 00       	call   802485 <pageref>
		nn = thisenv->env_runs;
  801f9c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fa2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	39 cb                	cmp    %ecx,%ebx
  801faa:	74 1b                	je     801fc7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801faf:	75 cf                	jne    801f80 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fb1:	8b 42 58             	mov    0x58(%edx),%eax
  801fb4:	6a 01                	push   $0x1
  801fb6:	50                   	push   %eax
  801fb7:	53                   	push   %ebx
  801fb8:	68 17 2d 80 00       	push   $0x802d17
  801fbd:	e8 8b e2 ff ff       	call   80024d <cprintf>
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	eb b9                	jmp    801f80 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801fc7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fca:	0f 94 c0             	sete   %al
  801fcd:	0f b6 c0             	movzbl %al,%eax
}
  801fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    

00801fd8 <devpipe_write>:
{
  801fd8:	f3 0f 1e fb          	endbr32 
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	57                   	push   %edi
  801fe0:	56                   	push   %esi
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 28             	sub    $0x28,%esp
  801fe5:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fe8:	56                   	push   %esi
  801fe9:	e8 0c f2 ff ff       	call   8011fa <fd2data>
  801fee:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	bf 00 00 00 00       	mov    $0x0,%edi
  801ff8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ffb:	74 4f                	je     80204c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ffd:	8b 43 04             	mov    0x4(%ebx),%eax
  802000:	8b 0b                	mov    (%ebx),%ecx
  802002:	8d 51 20             	lea    0x20(%ecx),%edx
  802005:	39 d0                	cmp    %edx,%eax
  802007:	72 14                	jb     80201d <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802009:	89 da                	mov    %ebx,%edx
  80200b:	89 f0                	mov    %esi,%eax
  80200d:	e8 61 ff ff ff       	call   801f73 <_pipeisclosed>
  802012:	85 c0                	test   %eax,%eax
  802014:	75 3b                	jne    802051 <devpipe_write+0x79>
			sys_yield();
  802016:	e8 82 ec ff ff       	call   800c9d <sys_yield>
  80201b:	eb e0                	jmp    801ffd <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80201d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802020:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802024:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802027:	89 c2                	mov    %eax,%edx
  802029:	c1 fa 1f             	sar    $0x1f,%edx
  80202c:	89 d1                	mov    %edx,%ecx
  80202e:	c1 e9 1b             	shr    $0x1b,%ecx
  802031:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802034:	83 e2 1f             	and    $0x1f,%edx
  802037:	29 ca                	sub    %ecx,%edx
  802039:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80203d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802041:	83 c0 01             	add    $0x1,%eax
  802044:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802047:	83 c7 01             	add    $0x1,%edi
  80204a:	eb ac                	jmp    801ff8 <devpipe_write+0x20>
	return i;
  80204c:	8b 45 10             	mov    0x10(%ebp),%eax
  80204f:	eb 05                	jmp    802056 <devpipe_write+0x7e>
				return 0;
  802051:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802056:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802059:	5b                   	pop    %ebx
  80205a:	5e                   	pop    %esi
  80205b:	5f                   	pop    %edi
  80205c:	5d                   	pop    %ebp
  80205d:	c3                   	ret    

0080205e <devpipe_read>:
{
  80205e:	f3 0f 1e fb          	endbr32 
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	57                   	push   %edi
  802066:	56                   	push   %esi
  802067:	53                   	push   %ebx
  802068:	83 ec 18             	sub    $0x18,%esp
  80206b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80206e:	57                   	push   %edi
  80206f:	e8 86 f1 ff ff       	call   8011fa <fd2data>
  802074:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	be 00 00 00 00       	mov    $0x0,%esi
  80207e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802081:	75 14                	jne    802097 <devpipe_read+0x39>
	return i;
  802083:	8b 45 10             	mov    0x10(%ebp),%eax
  802086:	eb 02                	jmp    80208a <devpipe_read+0x2c>
				return i;
  802088:	89 f0                	mov    %esi,%eax
}
  80208a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
			sys_yield();
  802092:	e8 06 ec ff ff       	call   800c9d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802097:	8b 03                	mov    (%ebx),%eax
  802099:	3b 43 04             	cmp    0x4(%ebx),%eax
  80209c:	75 18                	jne    8020b6 <devpipe_read+0x58>
			if (i > 0)
  80209e:	85 f6                	test   %esi,%esi
  8020a0:	75 e6                	jne    802088 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8020a2:	89 da                	mov    %ebx,%edx
  8020a4:	89 f8                	mov    %edi,%eax
  8020a6:	e8 c8 fe ff ff       	call   801f73 <_pipeisclosed>
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	74 e3                	je     802092 <devpipe_read+0x34>
				return 0;
  8020af:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b4:	eb d4                	jmp    80208a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020b6:	99                   	cltd   
  8020b7:	c1 ea 1b             	shr    $0x1b,%edx
  8020ba:	01 d0                	add    %edx,%eax
  8020bc:	83 e0 1f             	and    $0x1f,%eax
  8020bf:	29 d0                	sub    %edx,%eax
  8020c1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020c9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020cc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020cf:	83 c6 01             	add    $0x1,%esi
  8020d2:	eb aa                	jmp    80207e <devpipe_read+0x20>

008020d4 <pipe>:
{
  8020d4:	f3 0f 1e fb          	endbr32 
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	56                   	push   %esi
  8020dc:	53                   	push   %ebx
  8020dd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e3:	50                   	push   %eax
  8020e4:	e8 2c f1 ff ff       	call   801215 <fd_alloc>
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	83 c4 10             	add    $0x10,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	0f 88 23 01 00 00    	js     802219 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f6:	83 ec 04             	sub    $0x4,%esp
  8020f9:	68 07 04 00 00       	push   $0x407
  8020fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802101:	6a 00                	push   $0x0
  802103:	e8 b8 eb ff ff       	call   800cc0 <sys_page_alloc>
  802108:	89 c3                	mov    %eax,%ebx
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 c0                	test   %eax,%eax
  80210f:	0f 88 04 01 00 00    	js     802219 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802115:	83 ec 0c             	sub    $0xc,%esp
  802118:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80211b:	50                   	push   %eax
  80211c:	e8 f4 f0 ff ff       	call   801215 <fd_alloc>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	83 c4 10             	add    $0x10,%esp
  802126:	85 c0                	test   %eax,%eax
  802128:	0f 88 db 00 00 00    	js     802209 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212e:	83 ec 04             	sub    $0x4,%esp
  802131:	68 07 04 00 00       	push   $0x407
  802136:	ff 75 f0             	pushl  -0x10(%ebp)
  802139:	6a 00                	push   $0x0
  80213b:	e8 80 eb ff ff       	call   800cc0 <sys_page_alloc>
  802140:	89 c3                	mov    %eax,%ebx
  802142:	83 c4 10             	add    $0x10,%esp
  802145:	85 c0                	test   %eax,%eax
  802147:	0f 88 bc 00 00 00    	js     802209 <pipe+0x135>
	va = fd2data(fd0);
  80214d:	83 ec 0c             	sub    $0xc,%esp
  802150:	ff 75 f4             	pushl  -0xc(%ebp)
  802153:	e8 a2 f0 ff ff       	call   8011fa <fd2data>
  802158:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80215a:	83 c4 0c             	add    $0xc,%esp
  80215d:	68 07 04 00 00       	push   $0x407
  802162:	50                   	push   %eax
  802163:	6a 00                	push   $0x0
  802165:	e8 56 eb ff ff       	call   800cc0 <sys_page_alloc>
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	83 c4 10             	add    $0x10,%esp
  80216f:	85 c0                	test   %eax,%eax
  802171:	0f 88 82 00 00 00    	js     8021f9 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802177:	83 ec 0c             	sub    $0xc,%esp
  80217a:	ff 75 f0             	pushl  -0x10(%ebp)
  80217d:	e8 78 f0 ff ff       	call   8011fa <fd2data>
  802182:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802189:	50                   	push   %eax
  80218a:	6a 00                	push   $0x0
  80218c:	56                   	push   %esi
  80218d:	6a 00                	push   $0x0
  80218f:	e8 52 eb ff ff       	call   800ce6 <sys_page_map>
  802194:	89 c3                	mov    %eax,%ebx
  802196:	83 c4 20             	add    $0x20,%esp
  802199:	85 c0                	test   %eax,%eax
  80219b:	78 4e                	js     8021eb <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80219d:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8021a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021aa:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021b4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021c0:	83 ec 0c             	sub    $0xc,%esp
  8021c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c6:	e8 1b f0 ff ff       	call   8011e6 <fd2num>
  8021cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ce:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021d0:	83 c4 04             	add    $0x4,%esp
  8021d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d6:	e8 0b f0 ff ff       	call   8011e6 <fd2num>
  8021db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021de:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021e1:	83 c4 10             	add    $0x10,%esp
  8021e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021e9:	eb 2e                	jmp    802219 <pipe+0x145>
	sys_page_unmap(0, va);
  8021eb:	83 ec 08             	sub    $0x8,%esp
  8021ee:	56                   	push   %esi
  8021ef:	6a 00                	push   $0x0
  8021f1:	e8 15 eb ff ff       	call   800d0b <sys_page_unmap>
  8021f6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021f9:	83 ec 08             	sub    $0x8,%esp
  8021fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ff:	6a 00                	push   $0x0
  802201:	e8 05 eb ff ff       	call   800d0b <sys_page_unmap>
  802206:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802209:	83 ec 08             	sub    $0x8,%esp
  80220c:	ff 75 f4             	pushl  -0xc(%ebp)
  80220f:	6a 00                	push   $0x0
  802211:	e8 f5 ea ff ff       	call   800d0b <sys_page_unmap>
  802216:	83 c4 10             	add    $0x10,%esp
}
  802219:	89 d8                	mov    %ebx,%eax
  80221b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221e:	5b                   	pop    %ebx
  80221f:	5e                   	pop    %esi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    

00802222 <pipeisclosed>:
{
  802222:	f3 0f 1e fb          	endbr32 
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80222c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222f:	50                   	push   %eax
  802230:	ff 75 08             	pushl  0x8(%ebp)
  802233:	e8 33 f0 ff ff       	call   80126b <fd_lookup>
  802238:	83 c4 10             	add    $0x10,%esp
  80223b:	85 c0                	test   %eax,%eax
  80223d:	78 18                	js     802257 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80223f:	83 ec 0c             	sub    $0xc,%esp
  802242:	ff 75 f4             	pushl  -0xc(%ebp)
  802245:	e8 b0 ef ff ff       	call   8011fa <fd2data>
  80224a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80224c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224f:	e8 1f fd ff ff       	call   801f73 <_pipeisclosed>
  802254:	83 c4 10             	add    $0x10,%esp
}
  802257:	c9                   	leave  
  802258:	c3                   	ret    

00802259 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802259:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80225d:	b8 00 00 00 00       	mov    $0x0,%eax
  802262:	c3                   	ret    

00802263 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802263:	f3 0f 1e fb          	endbr32 
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80226d:	68 2f 2d 80 00       	push   $0x802d2f
  802272:	ff 75 0c             	pushl  0xc(%ebp)
  802275:	e8 dd e5 ff ff       	call   800857 <strcpy>
	return 0;
}
  80227a:	b8 00 00 00 00       	mov    $0x0,%eax
  80227f:	c9                   	leave  
  802280:	c3                   	ret    

00802281 <devcons_write>:
{
  802281:	f3 0f 1e fb          	endbr32 
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	57                   	push   %edi
  802289:	56                   	push   %esi
  80228a:	53                   	push   %ebx
  80228b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802291:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802296:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80229c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80229f:	73 31                	jae    8022d2 <devcons_write+0x51>
		m = n - tot;
  8022a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022a4:	29 f3                	sub    %esi,%ebx
  8022a6:	83 fb 7f             	cmp    $0x7f,%ebx
  8022a9:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022ae:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022b1:	83 ec 04             	sub    $0x4,%esp
  8022b4:	53                   	push   %ebx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	03 45 0c             	add    0xc(%ebp),%eax
  8022ba:	50                   	push   %eax
  8022bb:	57                   	push   %edi
  8022bc:	e8 94 e7 ff ff       	call   800a55 <memmove>
		sys_cputs(buf, m);
  8022c1:	83 c4 08             	add    $0x8,%esp
  8022c4:	53                   	push   %ebx
  8022c5:	57                   	push   %edi
  8022c6:	e8 46 e9 ff ff       	call   800c11 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8022cb:	01 de                	add    %ebx,%esi
  8022cd:	83 c4 10             	add    $0x10,%esp
  8022d0:	eb ca                	jmp    80229c <devcons_write+0x1b>
}
  8022d2:	89 f0                	mov    %esi,%eax
  8022d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d7:	5b                   	pop    %ebx
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    

008022dc <devcons_read>:
{
  8022dc:	f3 0f 1e fb          	endbr32 
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	83 ec 08             	sub    $0x8,%esp
  8022e6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8022eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ef:	74 21                	je     802312 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8022f1:	e8 3d e9 ff ff       	call   800c33 <sys_cgetc>
  8022f6:	85 c0                	test   %eax,%eax
  8022f8:	75 07                	jne    802301 <devcons_read+0x25>
		sys_yield();
  8022fa:	e8 9e e9 ff ff       	call   800c9d <sys_yield>
  8022ff:	eb f0                	jmp    8022f1 <devcons_read+0x15>
	if (c < 0)
  802301:	78 0f                	js     802312 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802303:	83 f8 04             	cmp    $0x4,%eax
  802306:	74 0c                	je     802314 <devcons_read+0x38>
	*(char*)vbuf = c;
  802308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230b:	88 02                	mov    %al,(%edx)
	return 1;
  80230d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802312:	c9                   	leave  
  802313:	c3                   	ret    
		return 0;
  802314:	b8 00 00 00 00       	mov    $0x0,%eax
  802319:	eb f7                	jmp    802312 <devcons_read+0x36>

0080231b <cputchar>:
{
  80231b:	f3 0f 1e fb          	endbr32 
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802325:	8b 45 08             	mov    0x8(%ebp),%eax
  802328:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80232b:	6a 01                	push   $0x1
  80232d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802330:	50                   	push   %eax
  802331:	e8 db e8 ff ff       	call   800c11 <sys_cputs>
}
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	c9                   	leave  
  80233a:	c3                   	ret    

0080233b <getchar>:
{
  80233b:	f3 0f 1e fb          	endbr32 
  80233f:	55                   	push   %ebp
  802340:	89 e5                	mov    %esp,%ebp
  802342:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802345:	6a 01                	push   $0x1
  802347:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80234a:	50                   	push   %eax
  80234b:	6a 00                	push   $0x0
  80234d:	e8 a1 f1 ff ff       	call   8014f3 <read>
	if (r < 0)
  802352:	83 c4 10             	add    $0x10,%esp
  802355:	85 c0                	test   %eax,%eax
  802357:	78 06                	js     80235f <getchar+0x24>
	if (r < 1)
  802359:	74 06                	je     802361 <getchar+0x26>
	return c;
  80235b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80235f:	c9                   	leave  
  802360:	c3                   	ret    
		return -E_EOF;
  802361:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802366:	eb f7                	jmp    80235f <getchar+0x24>

00802368 <iscons>:
{
  802368:	f3 0f 1e fb          	endbr32 
  80236c:	55                   	push   %ebp
  80236d:	89 e5                	mov    %esp,%ebp
  80236f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802372:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802375:	50                   	push   %eax
  802376:	ff 75 08             	pushl  0x8(%ebp)
  802379:	e8 ed ee ff ff       	call   80126b <fd_lookup>
  80237e:	83 c4 10             	add    $0x10,%esp
  802381:	85 c0                	test   %eax,%eax
  802383:	78 11                	js     802396 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802388:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80238e:	39 10                	cmp    %edx,(%eax)
  802390:	0f 94 c0             	sete   %al
  802393:	0f b6 c0             	movzbl %al,%eax
}
  802396:	c9                   	leave  
  802397:	c3                   	ret    

00802398 <opencons>:
{
  802398:	f3 0f 1e fb          	endbr32 
  80239c:	55                   	push   %ebp
  80239d:	89 e5                	mov    %esp,%ebp
  80239f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a5:	50                   	push   %eax
  8023a6:	e8 6a ee ff ff       	call   801215 <fd_alloc>
  8023ab:	83 c4 10             	add    $0x10,%esp
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	78 3a                	js     8023ec <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023b2:	83 ec 04             	sub    $0x4,%esp
  8023b5:	68 07 04 00 00       	push   $0x407
  8023ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8023bd:	6a 00                	push   $0x0
  8023bf:	e8 fc e8 ff ff       	call   800cc0 <sys_page_alloc>
  8023c4:	83 c4 10             	add    $0x10,%esp
  8023c7:	85 c0                	test   %eax,%eax
  8023c9:	78 21                	js     8023ec <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8023cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ce:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023d4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023e0:	83 ec 0c             	sub    $0xc,%esp
  8023e3:	50                   	push   %eax
  8023e4:	e8 fd ed ff ff       	call   8011e6 <fd2num>
  8023e9:	83 c4 10             	add    $0x10,%esp
}
  8023ec:	c9                   	leave  
  8023ed:	c3                   	ret    

008023ee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023ee:	f3 0f 1e fb          	endbr32 
  8023f2:	55                   	push   %ebp
  8023f3:	89 e5                	mov    %esp,%ebp
  8023f5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023f8:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023ff:	74 0a                	je     80240b <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802401:	8b 45 08             	mov    0x8(%ebp),%eax
  802404:	a3 00 70 80 00       	mov    %eax,0x807000

}
  802409:	c9                   	leave  
  80240a:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  80240b:	83 ec 04             	sub    $0x4,%esp
  80240e:	6a 07                	push   $0x7
  802410:	68 00 f0 bf ee       	push   $0xeebff000
  802415:	6a 00                	push   $0x0
  802417:	e8 a4 e8 ff ff       	call   800cc0 <sys_page_alloc>
  80241c:	83 c4 10             	add    $0x10,%esp
  80241f:	85 c0                	test   %eax,%eax
  802421:	78 2a                	js     80244d <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802423:	83 ec 08             	sub    $0x8,%esp
  802426:	68 61 24 80 00       	push   $0x802461
  80242b:	6a 00                	push   $0x0
  80242d:	e8 48 e9 ff ff       	call   800d7a <sys_env_set_pgfault_upcall>
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	85 c0                	test   %eax,%eax
  802437:	79 c8                	jns    802401 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802439:	83 ec 04             	sub    $0x4,%esp
  80243c:	68 68 2d 80 00       	push   $0x802d68
  802441:	6a 2c                	push   $0x2c
  802443:	68 9e 2d 80 00       	push   $0x802d9e
  802448:	e8 19 dd ff ff       	call   800166 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  80244d:	83 ec 04             	sub    $0x4,%esp
  802450:	68 3c 2d 80 00       	push   $0x802d3c
  802455:	6a 22                	push   $0x22
  802457:	68 9e 2d 80 00       	push   $0x802d9e
  80245c:	e8 05 dd ff ff       	call   800166 <_panic>

00802461 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802461:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802462:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  802467:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802469:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  80246c:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802470:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802475:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802479:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  80247b:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  80247e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  80247f:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802482:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802483:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  802484:	c3                   	ret    

00802485 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802485:	f3 0f 1e fb          	endbr32 
  802489:	55                   	push   %ebp
  80248a:	89 e5                	mov    %esp,%ebp
  80248c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80248f:	89 c2                	mov    %eax,%edx
  802491:	c1 ea 16             	shr    $0x16,%edx
  802494:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80249b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024a0:	f6 c1 01             	test   $0x1,%cl
  8024a3:	74 1c                	je     8024c1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8024a5:	c1 e8 0c             	shr    $0xc,%eax
  8024a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024af:	a8 01                	test   $0x1,%al
  8024b1:	74 0e                	je     8024c1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024b3:	c1 e8 0c             	shr    $0xc,%eax
  8024b6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024bd:	ef 
  8024be:	0f b7 d2             	movzwl %dx,%edx
}
  8024c1:	89 d0                	mov    %edx,%eax
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    
  8024c5:	66 90                	xchg   %ax,%ax
  8024c7:	66 90                	xchg   %ax,%ax
  8024c9:	66 90                	xchg   %ax,%ax
  8024cb:	66 90                	xchg   %ax,%ax
  8024cd:	66 90                	xchg   %ax,%ax
  8024cf:	90                   	nop

008024d0 <__udivdi3>:
  8024d0:	f3 0f 1e fb          	endbr32 
  8024d4:	55                   	push   %ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 1c             	sub    $0x1c,%esp
  8024db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024eb:	85 d2                	test   %edx,%edx
  8024ed:	75 19                	jne    802508 <__udivdi3+0x38>
  8024ef:	39 f3                	cmp    %esi,%ebx
  8024f1:	76 4d                	jbe    802540 <__udivdi3+0x70>
  8024f3:	31 ff                	xor    %edi,%edi
  8024f5:	89 e8                	mov    %ebp,%eax
  8024f7:	89 f2                	mov    %esi,%edx
  8024f9:	f7 f3                	div    %ebx
  8024fb:	89 fa                	mov    %edi,%edx
  8024fd:	83 c4 1c             	add    $0x1c,%esp
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi
  802508:	39 f2                	cmp    %esi,%edx
  80250a:	76 14                	jbe    802520 <__udivdi3+0x50>
  80250c:	31 ff                	xor    %edi,%edi
  80250e:	31 c0                	xor    %eax,%eax
  802510:	89 fa                	mov    %edi,%edx
  802512:	83 c4 1c             	add    $0x1c,%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	0f bd fa             	bsr    %edx,%edi
  802523:	83 f7 1f             	xor    $0x1f,%edi
  802526:	75 48                	jne    802570 <__udivdi3+0xa0>
  802528:	39 f2                	cmp    %esi,%edx
  80252a:	72 06                	jb     802532 <__udivdi3+0x62>
  80252c:	31 c0                	xor    %eax,%eax
  80252e:	39 eb                	cmp    %ebp,%ebx
  802530:	77 de                	ja     802510 <__udivdi3+0x40>
  802532:	b8 01 00 00 00       	mov    $0x1,%eax
  802537:	eb d7                	jmp    802510 <__udivdi3+0x40>
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d9                	mov    %ebx,%ecx
  802542:	85 db                	test   %ebx,%ebx
  802544:	75 0b                	jne    802551 <__udivdi3+0x81>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f3                	div    %ebx
  80254f:	89 c1                	mov    %eax,%ecx
  802551:	31 d2                	xor    %edx,%edx
  802553:	89 f0                	mov    %esi,%eax
  802555:	f7 f1                	div    %ecx
  802557:	89 c6                	mov    %eax,%esi
  802559:	89 e8                	mov    %ebp,%eax
  80255b:	89 f7                	mov    %esi,%edi
  80255d:	f7 f1                	div    %ecx
  80255f:	89 fa                	mov    %edi,%edx
  802561:	83 c4 1c             	add    $0x1c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	89 f9                	mov    %edi,%ecx
  802572:	b8 20 00 00 00       	mov    $0x20,%eax
  802577:	29 f8                	sub    %edi,%eax
  802579:	d3 e2                	shl    %cl,%edx
  80257b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80257f:	89 c1                	mov    %eax,%ecx
  802581:	89 da                	mov    %ebx,%edx
  802583:	d3 ea                	shr    %cl,%edx
  802585:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802589:	09 d1                	or     %edx,%ecx
  80258b:	89 f2                	mov    %esi,%edx
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f9                	mov    %edi,%ecx
  802593:	d3 e3                	shl    %cl,%ebx
  802595:	89 c1                	mov    %eax,%ecx
  802597:	d3 ea                	shr    %cl,%edx
  802599:	89 f9                	mov    %edi,%ecx
  80259b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80259f:	89 eb                	mov    %ebp,%ebx
  8025a1:	d3 e6                	shl    %cl,%esi
  8025a3:	89 c1                	mov    %eax,%ecx
  8025a5:	d3 eb                	shr    %cl,%ebx
  8025a7:	09 de                	or     %ebx,%esi
  8025a9:	89 f0                	mov    %esi,%eax
  8025ab:	f7 74 24 08          	divl   0x8(%esp)
  8025af:	89 d6                	mov    %edx,%esi
  8025b1:	89 c3                	mov    %eax,%ebx
  8025b3:	f7 64 24 0c          	mull   0xc(%esp)
  8025b7:	39 d6                	cmp    %edx,%esi
  8025b9:	72 15                	jb     8025d0 <__udivdi3+0x100>
  8025bb:	89 f9                	mov    %edi,%ecx
  8025bd:	d3 e5                	shl    %cl,%ebp
  8025bf:	39 c5                	cmp    %eax,%ebp
  8025c1:	73 04                	jae    8025c7 <__udivdi3+0xf7>
  8025c3:	39 d6                	cmp    %edx,%esi
  8025c5:	74 09                	je     8025d0 <__udivdi3+0x100>
  8025c7:	89 d8                	mov    %ebx,%eax
  8025c9:	31 ff                	xor    %edi,%edi
  8025cb:	e9 40 ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025d3:	31 ff                	xor    %edi,%edi
  8025d5:	e9 36 ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025da:	66 90                	xchg   %ax,%ax
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__umoddi3>:
  8025e0:	f3 0f 1e fb          	endbr32 
  8025e4:	55                   	push   %ebp
  8025e5:	57                   	push   %edi
  8025e6:	56                   	push   %esi
  8025e7:	53                   	push   %ebx
  8025e8:	83 ec 1c             	sub    $0x1c,%esp
  8025eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	75 19                	jne    802618 <__umoddi3+0x38>
  8025ff:	39 df                	cmp    %ebx,%edi
  802601:	76 5d                	jbe    802660 <__umoddi3+0x80>
  802603:	89 f0                	mov    %esi,%eax
  802605:	89 da                	mov    %ebx,%edx
  802607:	f7 f7                	div    %edi
  802609:	89 d0                	mov    %edx,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	83 c4 1c             	add    $0x1c,%esp
  802610:	5b                   	pop    %ebx
  802611:	5e                   	pop    %esi
  802612:	5f                   	pop    %edi
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    
  802615:	8d 76 00             	lea    0x0(%esi),%esi
  802618:	89 f2                	mov    %esi,%edx
  80261a:	39 d8                	cmp    %ebx,%eax
  80261c:	76 12                	jbe    802630 <__umoddi3+0x50>
  80261e:	89 f0                	mov    %esi,%eax
  802620:	89 da                	mov    %ebx,%edx
  802622:	83 c4 1c             	add    $0x1c,%esp
  802625:	5b                   	pop    %ebx
  802626:	5e                   	pop    %esi
  802627:	5f                   	pop    %edi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    
  80262a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802630:	0f bd e8             	bsr    %eax,%ebp
  802633:	83 f5 1f             	xor    $0x1f,%ebp
  802636:	75 50                	jne    802688 <__umoddi3+0xa8>
  802638:	39 d8                	cmp    %ebx,%eax
  80263a:	0f 82 e0 00 00 00    	jb     802720 <__umoddi3+0x140>
  802640:	89 d9                	mov    %ebx,%ecx
  802642:	39 f7                	cmp    %esi,%edi
  802644:	0f 86 d6 00 00 00    	jbe    802720 <__umoddi3+0x140>
  80264a:	89 d0                	mov    %edx,%eax
  80264c:	89 ca                	mov    %ecx,%edx
  80264e:	83 c4 1c             	add    $0x1c,%esp
  802651:	5b                   	pop    %ebx
  802652:	5e                   	pop    %esi
  802653:	5f                   	pop    %edi
  802654:	5d                   	pop    %ebp
  802655:	c3                   	ret    
  802656:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80265d:	8d 76 00             	lea    0x0(%esi),%esi
  802660:	89 fd                	mov    %edi,%ebp
  802662:	85 ff                	test   %edi,%edi
  802664:	75 0b                	jne    802671 <__umoddi3+0x91>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f7                	div    %edi
  80266f:	89 c5                	mov    %eax,%ebp
  802671:	89 d8                	mov    %ebx,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f5                	div    %ebp
  802677:	89 f0                	mov    %esi,%eax
  802679:	f7 f5                	div    %ebp
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	31 d2                	xor    %edx,%edx
  80267f:	eb 8c                	jmp    80260d <__umoddi3+0x2d>
  802681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802688:	89 e9                	mov    %ebp,%ecx
  80268a:	ba 20 00 00 00       	mov    $0x20,%edx
  80268f:	29 ea                	sub    %ebp,%edx
  802691:	d3 e0                	shl    %cl,%eax
  802693:	89 44 24 08          	mov    %eax,0x8(%esp)
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 f8                	mov    %edi,%eax
  80269b:	d3 e8                	shr    %cl,%eax
  80269d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026a9:	09 c1                	or     %eax,%ecx
  8026ab:	89 d8                	mov    %ebx,%eax
  8026ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026b1:	89 e9                	mov    %ebp,%ecx
  8026b3:	d3 e7                	shl    %cl,%edi
  8026b5:	89 d1                	mov    %edx,%ecx
  8026b7:	d3 e8                	shr    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026bf:	d3 e3                	shl    %cl,%ebx
  8026c1:	89 c7                	mov    %eax,%edi
  8026c3:	89 d1                	mov    %edx,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	89 fa                	mov    %edi,%edx
  8026cd:	d3 e6                	shl    %cl,%esi
  8026cf:	09 d8                	or     %ebx,%eax
  8026d1:	f7 74 24 08          	divl   0x8(%esp)
  8026d5:	89 d1                	mov    %edx,%ecx
  8026d7:	89 f3                	mov    %esi,%ebx
  8026d9:	f7 64 24 0c          	mull   0xc(%esp)
  8026dd:	89 c6                	mov    %eax,%esi
  8026df:	89 d7                	mov    %edx,%edi
  8026e1:	39 d1                	cmp    %edx,%ecx
  8026e3:	72 06                	jb     8026eb <__umoddi3+0x10b>
  8026e5:	75 10                	jne    8026f7 <__umoddi3+0x117>
  8026e7:	39 c3                	cmp    %eax,%ebx
  8026e9:	73 0c                	jae    8026f7 <__umoddi3+0x117>
  8026eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8026ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026f3:	89 d7                	mov    %edx,%edi
  8026f5:	89 c6                	mov    %eax,%esi
  8026f7:	89 ca                	mov    %ecx,%edx
  8026f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026fe:	29 f3                	sub    %esi,%ebx
  802700:	19 fa                	sbb    %edi,%edx
  802702:	89 d0                	mov    %edx,%eax
  802704:	d3 e0                	shl    %cl,%eax
  802706:	89 e9                	mov    %ebp,%ecx
  802708:	d3 eb                	shr    %cl,%ebx
  80270a:	d3 ea                	shr    %cl,%edx
  80270c:	09 d8                	or     %ebx,%eax
  80270e:	83 c4 1c             	add    $0x1c,%esp
  802711:	5b                   	pop    %ebx
  802712:	5e                   	pop    %esi
  802713:	5f                   	pop    %edi
  802714:	5d                   	pop    %ebp
  802715:	c3                   	ret    
  802716:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	29 fe                	sub    %edi,%esi
  802722:	19 c3                	sbb    %eax,%ebx
  802724:	89 f2                	mov    %esi,%edx
  802726:	89 d9                	mov    %ebx,%ecx
  802728:	e9 1d ff ff ff       	jmp    80264a <__umoddi3+0x6a>
