
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a3 01 00 00       	call   8001d4 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 28             	sub    $0x28,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  800040:	68 00 28 80 00       	push   $0x802800
  800045:	e8 d9 02 00 00       	call   800323 <cprintf>
	if ((r = pipe(p)) < 0)
  80004a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004d:	89 04 24             	mov    %eax,(%esp)
  800050:	e8 53 20 00 00       	call   8020a8 <pipe>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	85 c0                	test   %eax,%eax
  80005a:	78 5b                	js     8000b7 <umain+0x84>
		panic("pipe: %e", r);
	if ((r = fork()) < 0)
  80005c:	e8 c8 0f 00 00       	call   801029 <fork>
  800061:	89 c7                	mov    %eax,%edi
  800063:	85 c0                	test   %eax,%eax
  800065:	78 62                	js     8000c9 <umain+0x96>
		panic("fork: %e", r);
	if (r == 0) {
  800067:	74 72                	je     8000db <umain+0xa8>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800069:	89 fb                	mov    %edi,%ebx
  80006b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  800071:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800074:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80007a:	8b 43 54             	mov    0x54(%ebx),%eax
  80007d:	83 f8 02             	cmp    $0x2,%eax
  800080:	0f 85 d1 00 00 00    	jne    800157 <umain+0x124>
		if (pipeisclosed(p[0]) != 0) {
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	ff 75 e0             	pushl  -0x20(%ebp)
  80008c:	e8 65 21 00 00       	call   8021f6 <pipeisclosed>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	74 e2                	je     80007a <umain+0x47>
			cprintf("\nRACE: pipe appears closed\n");
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	68 79 28 80 00       	push   $0x802879
  8000a0:	e8 7e 02 00 00       	call   800323 <cprintf>
			sys_env_destroy(r);
  8000a5:	89 3c 24             	mov    %edi,(%esp)
  8000a8:	e8 7f 0c 00 00       	call   800d2c <sys_env_destroy>
			exit();
  8000ad:	e8 6c 01 00 00       	call   80021e <exit>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	eb c3                	jmp    80007a <umain+0x47>
		panic("pipe: %e", r);
  8000b7:	50                   	push   %eax
  8000b8:	68 4e 28 80 00       	push   $0x80284e
  8000bd:	6a 0d                	push   $0xd
  8000bf:	68 57 28 80 00       	push   $0x802857
  8000c4:	e8 73 01 00 00       	call   80023c <_panic>
		panic("fork: %e", r);
  8000c9:	50                   	push   %eax
  8000ca:	68 6c 28 80 00       	push   $0x80286c
  8000cf:	6a 0f                	push   $0xf
  8000d1:	68 57 28 80 00       	push   $0x802857
  8000d6:	e8 61 01 00 00       	call   80023c <_panic>
		close(p[1]);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e1:	e8 97 12 00 00       	call   80137d <close>
  8000e6:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  8000e9:	89 fb                	mov    %edi,%ebx
			if (i % 10 == 0)
  8000eb:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000f0:	eb 42                	jmp    800134 <umain+0x101>
				cprintf("%d.", i);
  8000f2:	83 ec 08             	sub    $0x8,%esp
  8000f5:	53                   	push   %ebx
  8000f6:	68 75 28 80 00       	push   $0x802875
  8000fb:	e8 23 02 00 00       	call   800323 <cprintf>
  800100:	83 c4 10             	add    $0x10,%esp
			dup(p[0], 10);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	6a 0a                	push   $0xa
  800108:	ff 75 e0             	pushl  -0x20(%ebp)
  80010b:	e8 c7 12 00 00       	call   8013d7 <dup>
			sys_yield();
  800110:	e8 5e 0c 00 00       	call   800d73 <sys_yield>
			close(10);
  800115:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80011c:	e8 5c 12 00 00       	call   80137d <close>
			sys_yield();
  800121:	e8 4d 0c 00 00       	call   800d73 <sys_yield>
		for (i = 0; i < 200; i++) {
  800126:	83 c3 01             	add    $0x1,%ebx
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  800132:	74 19                	je     80014d <umain+0x11a>
			if (i % 10 == 0)
  800134:	89 d8                	mov    %ebx,%eax
  800136:	f7 ee                	imul   %esi
  800138:	c1 fa 02             	sar    $0x2,%edx
  80013b:	89 d8                	mov    %ebx,%eax
  80013d:	c1 f8 1f             	sar    $0x1f,%eax
  800140:	29 c2                	sub    %eax,%edx
  800142:	8d 04 92             	lea    (%edx,%edx,4),%eax
  800145:	01 c0                	add    %eax,%eax
  800147:	39 c3                	cmp    %eax,%ebx
  800149:	75 b8                	jne    800103 <umain+0xd0>
  80014b:	eb a5                	jmp    8000f2 <umain+0xbf>
		exit();
  80014d:	e8 cc 00 00 00       	call   80021e <exit>
  800152:	e9 12 ff ff ff       	jmp    800069 <umain+0x36>
		}
	cprintf("child done with loop\n");
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 95 28 80 00       	push   $0x802895
  80015f:	e8 bf 01 00 00       	call   800323 <cprintf>
	if (pipeisclosed(p[0]))
  800164:	83 c4 04             	add    $0x4,%esp
  800167:	ff 75 e0             	pushl  -0x20(%ebp)
  80016a:	e8 87 20 00 00       	call   8021f6 <pipeisclosed>
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	85 c0                	test   %eax,%eax
  800174:	75 38                	jne    8001ae <umain+0x17b>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80017c:	50                   	push   %eax
  80017d:	ff 75 e0             	pushl  -0x20(%ebp)
  800180:	e8 ba 10 00 00       	call   80123f <fd_lookup>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	85 c0                	test   %eax,%eax
  80018a:	78 36                	js     8001c2 <umain+0x18f>
		panic("cannot look up p[0]: %e", r);
	(void) fd2data(fd);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	ff 75 dc             	pushl  -0x24(%ebp)
  800192:	e8 37 10 00 00       	call   8011ce <fd2data>
	cprintf("race didn't happen\n");
  800197:	c7 04 24 c3 28 80 00 	movl   $0x8028c3,(%esp)
  80019e:	e8 80 01 00 00       	call   800323 <cprintf>
}
  8001a3:	83 c4 10             	add    $0x10,%esp
  8001a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5f                   	pop    %edi
  8001ac:	5d                   	pop    %ebp
  8001ad:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001ae:	83 ec 04             	sub    $0x4,%esp
  8001b1:	68 24 28 80 00       	push   $0x802824
  8001b6:	6a 40                	push   $0x40
  8001b8:	68 57 28 80 00       	push   $0x802857
  8001bd:	e8 7a 00 00 00       	call   80023c <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c2:	50                   	push   %eax
  8001c3:	68 ab 28 80 00       	push   $0x8028ab
  8001c8:	6a 42                	push   $0x42
  8001ca:	68 57 28 80 00       	push   $0x802857
  8001cf:	e8 68 00 00 00       	call   80023c <_panic>

008001d4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d4:	f3 0f 1e fb          	endbr32 
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e3:	e8 68 0b 00 00       	call   800d50 <sys_getenvid>
  8001e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f5:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fa:	85 db                	test   %ebx,%ebx
  8001fc:	7e 07                	jle    800205 <libmain+0x31>
		binaryname = argv[0];
  8001fe:	8b 06                	mov    (%esi),%eax
  800200:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	e8 24 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020f:	e8 0a 00 00 00       	call   80021e <exit>
}
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021e:	f3 0f 1e fb          	endbr32 
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800228:	e8 81 11 00 00       	call   8013ae <close_all>
	sys_env_destroy(0);
  80022d:	83 ec 0c             	sub    $0xc,%esp
  800230:	6a 00                	push   $0x0
  800232:	e8 f5 0a 00 00       	call   800d2c <sys_env_destroy>
}
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023c:	f3 0f 1e fb          	endbr32 
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800245:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800248:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80024e:	e8 fd 0a 00 00       	call   800d50 <sys_getenvid>
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 0c             	pushl  0xc(%ebp)
  800259:	ff 75 08             	pushl  0x8(%ebp)
  80025c:	56                   	push   %esi
  80025d:	50                   	push   %eax
  80025e:	68 e4 28 80 00       	push   $0x8028e4
  800263:	e8 bb 00 00 00       	call   800323 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	53                   	push   %ebx
  80026c:	ff 75 10             	pushl  0x10(%ebp)
  80026f:	e8 5a 00 00 00       	call   8002ce <vcprintf>
	cprintf("\n");
  800274:	c7 04 24 70 2e 80 00 	movl   $0x802e70,(%esp)
  80027b:	e8 a3 00 00 00       	call   800323 <cprintf>
  800280:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x47>

00800286 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800286:	f3 0f 1e fb          	endbr32 
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	74 09                	je     8002b2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	68 ff 00 00 00       	push   $0xff
  8002ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8002bd:	50                   	push   %eax
  8002be:	e8 24 0a 00 00       	call   800ce7 <sys_cputs>
		b->idx = 0;
  8002c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	eb db                	jmp    8002a9 <putch+0x23>

008002ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ce:	f3 0f 1e fb          	endbr32 
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e2:	00 00 00 
	b.cnt = 0;
  8002e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ef:	ff 75 0c             	pushl  0xc(%ebp)
  8002f2:	ff 75 08             	pushl  0x8(%ebp)
  8002f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fb:	50                   	push   %eax
  8002fc:	68 86 02 80 00       	push   $0x800286
  800301:	e8 20 01 00 00       	call   800426 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800306:	83 c4 08             	add    $0x8,%esp
  800309:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80030f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800315:	50                   	push   %eax
  800316:	e8 cc 09 00 00       	call   800ce7 <sys_cputs>

	return b.cnt;
}
  80031b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800323:	f3 0f 1e fb          	endbr32 
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800330:	50                   	push   %eax
  800331:	ff 75 08             	pushl  0x8(%ebp)
  800334:	e8 95 ff ff ff       	call   8002ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 1c             	sub    $0x1c,%esp
  800344:	89 c7                	mov    %eax,%edi
  800346:	89 d6                	mov    %edx,%esi
  800348:	8b 45 08             	mov    0x8(%ebp),%eax
  80034b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80034e:	89 d1                	mov    %edx,%ecx
  800350:	89 c2                	mov    %eax,%edx
  800352:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800355:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800358:	8b 45 10             	mov    0x10(%ebp),%eax
  80035b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800361:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800368:	39 c2                	cmp    %eax,%edx
  80036a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80036d:	72 3e                	jb     8003ad <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036f:	83 ec 0c             	sub    $0xc,%esp
  800372:	ff 75 18             	pushl  0x18(%ebp)
  800375:	83 eb 01             	sub    $0x1,%ebx
  800378:	53                   	push   %ebx
  800379:	50                   	push   %eax
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800380:	ff 75 e0             	pushl  -0x20(%ebp)
  800383:	ff 75 dc             	pushl  -0x24(%ebp)
  800386:	ff 75 d8             	pushl  -0x28(%ebp)
  800389:	e8 12 22 00 00       	call   8025a0 <__udivdi3>
  80038e:	83 c4 18             	add    $0x18,%esp
  800391:	52                   	push   %edx
  800392:	50                   	push   %eax
  800393:	89 f2                	mov    %esi,%edx
  800395:	89 f8                	mov    %edi,%eax
  800397:	e8 9f ff ff ff       	call   80033b <printnum>
  80039c:	83 c4 20             	add    $0x20,%esp
  80039f:	eb 13                	jmp    8003b4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	56                   	push   %esi
  8003a5:	ff 75 18             	pushl  0x18(%ebp)
  8003a8:	ff d7                	call   *%edi
  8003aa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003ad:	83 eb 01             	sub    $0x1,%ebx
  8003b0:	85 db                	test   %ebx,%ebx
  8003b2:	7f ed                	jg     8003a1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b4:	83 ec 08             	sub    $0x8,%esp
  8003b7:	56                   	push   %esi
  8003b8:	83 ec 04             	sub    $0x4,%esp
  8003bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003be:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c7:	e8 e4 22 00 00       	call   8026b0 <__umoddi3>
  8003cc:	83 c4 14             	add    $0x14,%esp
  8003cf:	0f be 80 07 29 80 00 	movsbl 0x802907(%eax),%eax
  8003d6:	50                   	push   %eax
  8003d7:	ff d7                	call   *%edi
}
  8003d9:	83 c4 10             	add    $0x10,%esp
  8003dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003df:	5b                   	pop    %ebx
  8003e0:	5e                   	pop    %esi
  8003e1:	5f                   	pop    %edi
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e4:	f3 0f 1e fb          	endbr32 
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f7:	73 0a                	jae    800403 <sprintputch+0x1f>
		*b->buf++ = ch;
  8003f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003fc:	89 08                	mov    %ecx,(%eax)
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	88 02                	mov    %al,(%edx)
}
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <printfmt>:
{
  800405:	f3 0f 1e fb          	endbr32 
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80040f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800412:	50                   	push   %eax
  800413:	ff 75 10             	pushl  0x10(%ebp)
  800416:	ff 75 0c             	pushl  0xc(%ebp)
  800419:	ff 75 08             	pushl  0x8(%ebp)
  80041c:	e8 05 00 00 00       	call   800426 <vprintfmt>
}
  800421:	83 c4 10             	add    $0x10,%esp
  800424:	c9                   	leave  
  800425:	c3                   	ret    

00800426 <vprintfmt>:
{
  800426:	f3 0f 1e fb          	endbr32 
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 3c             	sub    $0x3c,%esp
  800433:	8b 75 08             	mov    0x8(%ebp),%esi
  800436:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800439:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043c:	e9 8e 03 00 00       	jmp    8007cf <vprintfmt+0x3a9>
		padc = ' ';
  800441:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800445:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80044c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800453:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80045a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8d 47 01             	lea    0x1(%edi),%eax
  800462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800465:	0f b6 17             	movzbl (%edi),%edx
  800468:	8d 42 dd             	lea    -0x23(%edx),%eax
  80046b:	3c 55                	cmp    $0x55,%al
  80046d:	0f 87 df 03 00 00    	ja     800852 <vprintfmt+0x42c>
  800473:	0f b6 c0             	movzbl %al,%eax
  800476:	3e ff 24 85 40 2a 80 	notrack jmp *0x802a40(,%eax,4)
  80047d:	00 
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800481:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800485:	eb d8                	jmp    80045f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80048e:	eb cf                	jmp    80045f <vprintfmt+0x39>
  800490:	0f b6 d2             	movzbl %dl,%edx
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80049e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ab:	83 f9 09             	cmp    $0x9,%ecx
  8004ae:	77 55                	ja     800505 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8004b3:	eb e9                	jmp    80049e <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 40 04             	lea    0x4(%eax),%eax
  8004c3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cd:	79 90                	jns    80045f <vprintfmt+0x39>
				width = precision, precision = -1;
  8004cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004dc:	eb 81                	jmp    80045f <vprintfmt+0x39>
  8004de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	0f 49 d0             	cmovns %eax,%edx
  8004eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004f1:	e9 69 ff ff ff       	jmp    80045f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800500:	e9 5a ff ff ff       	jmp    80045f <vprintfmt+0x39>
  800505:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800508:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050b:	eb bc                	jmp    8004c9 <vprintfmt+0xa3>
			lflag++;
  80050d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800513:	e9 47 ff ff ff       	jmp    80045f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 78 04             	lea    0x4(%eax),%edi
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	ff 30                	pushl  (%eax)
  800524:	ff d6                	call   *%esi
			break;
  800526:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800529:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80052c:	e9 9b 02 00 00       	jmp    8007cc <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 78 04             	lea    0x4(%eax),%edi
  800537:	8b 00                	mov    (%eax),%eax
  800539:	99                   	cltd   
  80053a:	31 d0                	xor    %edx,%eax
  80053c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053e:	83 f8 0f             	cmp    $0xf,%eax
  800541:	7f 23                	jg     800566 <vprintfmt+0x140>
  800543:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  80054a:	85 d2                	test   %edx,%edx
  80054c:	74 18                	je     800566 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80054e:	52                   	push   %edx
  80054f:	68 a5 2d 80 00       	push   $0x802da5
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 aa fe ff ff       	call   800405 <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80055e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800561:	e9 66 02 00 00       	jmp    8007cc <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800566:	50                   	push   %eax
  800567:	68 1f 29 80 00       	push   $0x80291f
  80056c:	53                   	push   %ebx
  80056d:	56                   	push   %esi
  80056e:	e8 92 fe ff ff       	call   800405 <printfmt>
  800573:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800576:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800579:	e9 4e 02 00 00       	jmp    8007cc <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	83 c0 04             	add    $0x4,%eax
  800584:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80058c:	85 d2                	test   %edx,%edx
  80058e:	b8 18 29 80 00       	mov    $0x802918,%eax
  800593:	0f 45 c2             	cmovne %edx,%eax
  800596:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800599:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059d:	7e 06                	jle    8005a5 <vprintfmt+0x17f>
  80059f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005a3:	75 0d                	jne    8005b2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a8:	89 c7                	mov    %eax,%edi
  8005aa:	03 45 e0             	add    -0x20(%ebp),%eax
  8005ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b0:	eb 55                	jmp    800607 <vprintfmt+0x1e1>
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b8:	ff 75 cc             	pushl  -0x34(%ebp)
  8005bb:	e8 46 03 00 00       	call   800906 <strnlen>
  8005c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005c3:	29 c2                	sub    %eax,%edx
  8005c5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005cd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	7e 11                	jle    8005e9 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005df:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ef 01             	sub    $0x1,%edi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb eb                	jmp    8005d4 <vprintfmt+0x1ae>
  8005e9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f3:	0f 49 c2             	cmovns %edx,%eax
  8005f6:	29 c2                	sub    %eax,%edx
  8005f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005fb:	eb a8                	jmp    8005a5 <vprintfmt+0x17f>
					putch(ch, putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	52                   	push   %edx
  800602:	ff d6                	call   *%esi
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80060a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060c:	83 c7 01             	add    $0x1,%edi
  80060f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800613:	0f be d0             	movsbl %al,%edx
  800616:	85 d2                	test   %edx,%edx
  800618:	74 4b                	je     800665 <vprintfmt+0x23f>
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	78 06                	js     800626 <vprintfmt+0x200>
  800620:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800624:	78 1e                	js     800644 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800626:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062a:	74 d1                	je     8005fd <vprintfmt+0x1d7>
  80062c:	0f be c0             	movsbl %al,%eax
  80062f:	83 e8 20             	sub    $0x20,%eax
  800632:	83 f8 5e             	cmp    $0x5e,%eax
  800635:	76 c6                	jbe    8005fd <vprintfmt+0x1d7>
					putch('?', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	6a 3f                	push   $0x3f
  80063d:	ff d6                	call   *%esi
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	eb c3                	jmp    800607 <vprintfmt+0x1e1>
  800644:	89 cf                	mov    %ecx,%edi
  800646:	eb 0e                	jmp    800656 <vprintfmt+0x230>
				putch(' ', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 20                	push   $0x20
  80064e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	85 ff                	test   %edi,%edi
  800658:	7f ee                	jg     800648 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80065a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
  800660:	e9 67 01 00 00       	jmp    8007cc <vprintfmt+0x3a6>
  800665:	89 cf                	mov    %ecx,%edi
  800667:	eb ed                	jmp    800656 <vprintfmt+0x230>
	if (lflag >= 2)
  800669:	83 f9 01             	cmp    $0x1,%ecx
  80066c:	7f 1b                	jg     800689 <vprintfmt+0x263>
	else if (lflag)
  80066e:	85 c9                	test   %ecx,%ecx
  800670:	74 63                	je     8006d5 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067a:	99                   	cltd   
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
  800687:	eb 17                	jmp    8006a0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	0f 89 ff 00 00 00    	jns    8007b2 <vprintfmt+0x38c>
				putch('-', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 2d                	push   $0x2d
  8006b9:	ff d6                	call   *%esi
				num = -(long long) num;
  8006bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006be:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006c1:	f7 da                	neg    %edx
  8006c3:	83 d1 00             	adc    $0x0,%ecx
  8006c6:	f7 d9                	neg    %ecx
  8006c8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d0:	e9 dd 00 00 00       	jmp    8007b2 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dd:	99                   	cltd   
  8006de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ea:	eb b4                	jmp    8006a0 <vprintfmt+0x27a>
	if (lflag >= 2)
  8006ec:	83 f9 01             	cmp    $0x1,%ecx
  8006ef:	7f 1e                	jg     80070f <vprintfmt+0x2e9>
	else if (lflag)
  8006f1:	85 c9                	test   %ecx,%ecx
  8006f3:	74 32                	je     800727 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 10                	mov    (%eax),%edx
  8006fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800705:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80070a:	e9 a3 00 00 00       	jmp    8007b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	8b 48 04             	mov    0x4(%eax),%ecx
  800717:	8d 40 08             	lea    0x8(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80071d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800722:	e9 8b 00 00 00       	jmp    8007b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8b 10                	mov    (%eax),%edx
  80072c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800731:	8d 40 04             	lea    0x4(%eax),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800737:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80073c:	eb 74                	jmp    8007b2 <vprintfmt+0x38c>
	if (lflag >= 2)
  80073e:	83 f9 01             	cmp    $0x1,%ecx
  800741:	7f 1b                	jg     80075e <vprintfmt+0x338>
	else if (lflag)
  800743:	85 c9                	test   %ecx,%ecx
  800745:	74 2c                	je     800773 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 10                	mov    (%eax),%edx
  80074c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800751:	8d 40 04             	lea    0x4(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800757:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80075c:	eb 54                	jmp    8007b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	8b 48 04             	mov    0x4(%eax),%ecx
  800766:	8d 40 08             	lea    0x8(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80076c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800771:	eb 3f                	jmp    8007b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8b 10                	mov    (%eax),%edx
  800778:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077d:	8d 40 04             	lea    0x4(%eax),%eax
  800780:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800783:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800788:	eb 28                	jmp    8007b2 <vprintfmt+0x38c>
			putch('0', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 30                	push   $0x30
  800790:	ff d6                	call   *%esi
			putch('x', putdat);
  800792:	83 c4 08             	add    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 78                	push   $0x78
  800798:	ff d6                	call   *%esi
			num = (unsigned long long)
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 10                	mov    (%eax),%edx
  80079f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007a4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007a7:	8d 40 04             	lea    0x4(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ad:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007b2:	83 ec 0c             	sub    $0xc,%esp
  8007b5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8007b9:	57                   	push   %edi
  8007ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bd:	50                   	push   %eax
  8007be:	51                   	push   %ecx
  8007bf:	52                   	push   %edx
  8007c0:	89 da                	mov    %ebx,%edx
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	e8 72 fb ff ff       	call   80033b <printnum>
			break;
  8007c9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8007cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8007cf:	83 c7 01             	add    $0x1,%edi
  8007d2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007d6:	83 f8 25             	cmp    $0x25,%eax
  8007d9:	0f 84 62 fc ff ff    	je     800441 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	0f 84 8b 00 00 00    	je     800872 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	53                   	push   %ebx
  8007eb:	50                   	push   %eax
  8007ec:	ff d6                	call   *%esi
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	eb dc                	jmp    8007cf <vprintfmt+0x3a9>
	if (lflag >= 2)
  8007f3:	83 f9 01             	cmp    $0x1,%ecx
  8007f6:	7f 1b                	jg     800813 <vprintfmt+0x3ed>
	else if (lflag)
  8007f8:	85 c9                	test   %ecx,%ecx
  8007fa:	74 2c                	je     800828 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
  800806:	8d 40 04             	lea    0x4(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800811:	eb 9f                	jmp    8007b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8b 10                	mov    (%eax),%edx
  800818:	8b 48 04             	mov    0x4(%eax),%ecx
  80081b:	8d 40 08             	lea    0x8(%eax),%eax
  80081e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800821:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800826:	eb 8a                	jmp    8007b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800832:	8d 40 04             	lea    0x4(%eax),%eax
  800835:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800838:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80083d:	e9 70 ff ff ff       	jmp    8007b2 <vprintfmt+0x38c>
			putch(ch, putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	6a 25                	push   $0x25
  800848:	ff d6                	call   *%esi
			break;
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	e9 7a ff ff ff       	jmp    8007cc <vprintfmt+0x3a6>
			putch('%', putdat);
  800852:	83 ec 08             	sub    $0x8,%esp
  800855:	53                   	push   %ebx
  800856:	6a 25                	push   $0x25
  800858:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	89 f8                	mov    %edi,%eax
  80085f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800863:	74 05                	je     80086a <vprintfmt+0x444>
  800865:	83 e8 01             	sub    $0x1,%eax
  800868:	eb f5                	jmp    80085f <vprintfmt+0x439>
  80086a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80086d:	e9 5a ff ff ff       	jmp    8007cc <vprintfmt+0x3a6>
}
  800872:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800875:	5b                   	pop    %ebx
  800876:	5e                   	pop    %esi
  800877:	5f                   	pop    %edi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087a:	f3 0f 1e fb          	endbr32 
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	83 ec 18             	sub    $0x18,%esp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800891:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800894:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089b:	85 c0                	test   %eax,%eax
  80089d:	74 26                	je     8008c5 <vsnprintf+0x4b>
  80089f:	85 d2                	test   %edx,%edx
  8008a1:	7e 22                	jle    8008c5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a3:	ff 75 14             	pushl  0x14(%ebp)
  8008a6:	ff 75 10             	pushl  0x10(%ebp)
  8008a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ac:	50                   	push   %eax
  8008ad:	68 e4 03 80 00       	push   $0x8003e4
  8008b2:	e8 6f fb ff ff       	call   800426 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c0:	83 c4 10             	add    $0x10,%esp
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    
		return -E_INVAL;
  8008c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ca:	eb f7                	jmp    8008c3 <vsnprintf+0x49>

008008cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8008d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d9:	50                   	push   %eax
  8008da:	ff 75 10             	pushl  0x10(%ebp)
  8008dd:	ff 75 0c             	pushl  0xc(%ebp)
  8008e0:	ff 75 08             	pushl  0x8(%ebp)
  8008e3:	e8 92 ff ff ff       	call   80087a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ea:	f3 0f 1e fb          	endbr32 
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fd:	74 05                	je     800904 <strlen+0x1a>
		n++;
  8008ff:	83 c0 01             	add    $0x1,%eax
  800902:	eb f5                	jmp    8008f9 <strlen+0xf>
	return n;
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800906:	f3 0f 1e fb          	endbr32 
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	39 d0                	cmp    %edx,%eax
  80091a:	74 0d                	je     800929 <strnlen+0x23>
  80091c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800920:	74 05                	je     800927 <strnlen+0x21>
		n++;
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	eb f1                	jmp    800918 <strnlen+0x12>
  800927:	89 c2                	mov    %eax,%edx
	return n;
}
  800929:	89 d0                	mov    %edx,%eax
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092d:	f3 0f 1e fb          	endbr32 
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	53                   	push   %ebx
  800935:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800938:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
  800940:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800944:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	84 d2                	test   %dl,%dl
  80094c:	75 f2                	jne    800940 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80094e:	89 c8                	mov    %ecx,%eax
  800950:	5b                   	pop    %ebx
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800953:	f3 0f 1e fb          	endbr32 
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	83 ec 10             	sub    $0x10,%esp
  80095e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800961:	53                   	push   %ebx
  800962:	e8 83 ff ff ff       	call   8008ea <strlen>
  800967:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80096a:	ff 75 0c             	pushl  0xc(%ebp)
  80096d:	01 d8                	add    %ebx,%eax
  80096f:	50                   	push   %eax
  800970:	e8 b8 ff ff ff       	call   80092d <strcpy>
	return dst;
}
  800975:	89 d8                	mov    %ebx,%eax
  800977:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097c:	f3 0f 1e fb          	endbr32 
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 75 08             	mov    0x8(%ebp),%esi
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	89 f3                	mov    %esi,%ebx
  80098d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800990:	89 f0                	mov    %esi,%eax
  800992:	39 d8                	cmp    %ebx,%eax
  800994:	74 11                	je     8009a7 <strncpy+0x2b>
		*dst++ = *src;
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	0f b6 0a             	movzbl (%edx),%ecx
  80099c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099f:	80 f9 01             	cmp    $0x1,%cl
  8009a2:	83 da ff             	sbb    $0xffffffff,%edx
  8009a5:	eb eb                	jmp    800992 <strncpy+0x16>
	}
	return ret;
}
  8009a7:	89 f0                	mov    %esi,%eax
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ad:	f3 0f 1e fb          	endbr32 
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bc:	8b 55 10             	mov    0x10(%ebp),%edx
  8009bf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c1:	85 d2                	test   %edx,%edx
  8009c3:	74 21                	je     8009e6 <strlcpy+0x39>
  8009c5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009cb:	39 c2                	cmp    %eax,%edx
  8009cd:	74 14                	je     8009e3 <strlcpy+0x36>
  8009cf:	0f b6 19             	movzbl (%ecx),%ebx
  8009d2:	84 db                	test   %bl,%bl
  8009d4:	74 0b                	je     8009e1 <strlcpy+0x34>
			*dst++ = *src++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	83 c2 01             	add    $0x1,%edx
  8009dc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009df:	eb ea                	jmp    8009cb <strlcpy+0x1e>
  8009e1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009e3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e6:	29 f0                	sub    %esi,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ec:	f3 0f 1e fb          	endbr32 
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	84 c0                	test   %al,%al
  8009fe:	74 0c                	je     800a0c <strcmp+0x20>
  800a00:	3a 02                	cmp    (%edx),%al
  800a02:	75 08                	jne    800a0c <strcmp+0x20>
		p++, q++;
  800a04:	83 c1 01             	add    $0x1,%ecx
  800a07:	83 c2 01             	add    $0x1,%edx
  800a0a:	eb ed                	jmp    8009f9 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	0f b6 12             	movzbl (%edx),%edx
  800a12:	29 d0                	sub    %edx,%eax
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a16:	f3 0f 1e fb          	endbr32 
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a24:	89 c3                	mov    %eax,%ebx
  800a26:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a29:	eb 06                	jmp    800a31 <strncmp+0x1b>
		n--, p++, q++;
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a31:	39 d8                	cmp    %ebx,%eax
  800a33:	74 16                	je     800a4b <strncmp+0x35>
  800a35:	0f b6 08             	movzbl (%eax),%ecx
  800a38:	84 c9                	test   %cl,%cl
  800a3a:	74 04                	je     800a40 <strncmp+0x2a>
  800a3c:	3a 0a                	cmp    (%edx),%cl
  800a3e:	74 eb                	je     800a2b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a40:	0f b6 00             	movzbl (%eax),%eax
  800a43:	0f b6 12             	movzbl (%edx),%edx
  800a46:	29 d0                	sub    %edx,%eax
}
  800a48:	5b                   	pop    %ebx
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    
		return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	eb f6                	jmp    800a48 <strncmp+0x32>

00800a52 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a52:	f3 0f 1e fb          	endbr32 
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a60:	0f b6 10             	movzbl (%eax),%edx
  800a63:	84 d2                	test   %dl,%dl
  800a65:	74 09                	je     800a70 <strchr+0x1e>
		if (*s == c)
  800a67:	38 ca                	cmp    %cl,%dl
  800a69:	74 0a                	je     800a75 <strchr+0x23>
	for (; *s; s++)
  800a6b:	83 c0 01             	add    $0x1,%eax
  800a6e:	eb f0                	jmp    800a60 <strchr+0xe>
			return (char *) s;
	return 0;
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800a77:	f3 0f 1e fb          	endbr32 
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800a81:	6a 78                	push   $0x78
  800a83:	ff 75 08             	pushl  0x8(%ebp)
  800a86:	e8 c7 ff ff ff       	call   800a52 <strchr>
  800a8b:	83 c4 10             	add    $0x10,%esp
  800a8e:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800a96:	eb 0d                	jmp    800aa5 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800a98:	c1 e0 04             	shl    $0x4,%eax
  800a9b:	0f be d2             	movsbl %dl,%edx
  800a9e:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800aa2:	83 c1 01             	add    $0x1,%ecx
  800aa5:	0f b6 11             	movzbl (%ecx),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	74 11                	je     800abd <atox+0x46>
		if (*p>='a'){
  800aac:	80 fa 60             	cmp    $0x60,%dl
  800aaf:	7e e7                	jle    800a98 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800ab1:	c1 e0 04             	shl    $0x4,%eax
  800ab4:	0f be d2             	movsbl %dl,%edx
  800ab7:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800abb:	eb e5                	jmp    800aa2 <atox+0x2b>
	}

	return v;

}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abf:	f3 0f 1e fb          	endbr32 
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad0:	38 ca                	cmp    %cl,%dl
  800ad2:	74 09                	je     800add <strfind+0x1e>
  800ad4:	84 d2                	test   %dl,%dl
  800ad6:	74 05                	je     800add <strfind+0x1e>
	for (; *s; s++)
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	eb f0                	jmp    800acd <strfind+0xe>
			break;
	return (char *) s;
}
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800adf:	f3 0f 1e fb          	endbr32 
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aef:	85 c9                	test   %ecx,%ecx
  800af1:	74 31                	je     800b24 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af3:	89 f8                	mov    %edi,%eax
  800af5:	09 c8                	or     %ecx,%eax
  800af7:	a8 03                	test   $0x3,%al
  800af9:	75 23                	jne    800b1e <memset+0x3f>
		c &= 0xFF;
  800afb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aff:	89 d3                	mov    %edx,%ebx
  800b01:	c1 e3 08             	shl    $0x8,%ebx
  800b04:	89 d0                	mov    %edx,%eax
  800b06:	c1 e0 18             	shl    $0x18,%eax
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	c1 e6 10             	shl    $0x10,%esi
  800b0e:	09 f0                	or     %esi,%eax
  800b10:	09 c2                	or     %eax,%edx
  800b12:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b14:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b17:	89 d0                	mov    %edx,%eax
  800b19:	fc                   	cld    
  800b1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1c:	eb 06                	jmp    800b24 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	fc                   	cld    
  800b22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2b:	f3 0f 1e fb          	endbr32 
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3d:	39 c6                	cmp    %eax,%esi
  800b3f:	73 32                	jae    800b73 <memmove+0x48>
  800b41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b44:	39 c2                	cmp    %eax,%edx
  800b46:	76 2b                	jbe    800b73 <memmove+0x48>
		s += n;
		d += n;
  800b48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4b:	89 fe                	mov    %edi,%esi
  800b4d:	09 ce                	or     %ecx,%esi
  800b4f:	09 d6                	or     %edx,%esi
  800b51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b57:	75 0e                	jne    800b67 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b59:	83 ef 04             	sub    $0x4,%edi
  800b5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b62:	fd                   	std    
  800b63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b65:	eb 09                	jmp    800b70 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b67:	83 ef 01             	sub    $0x1,%edi
  800b6a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b6d:	fd                   	std    
  800b6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b70:	fc                   	cld    
  800b71:	eb 1a                	jmp    800b8d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b73:	89 c2                	mov    %eax,%edx
  800b75:	09 ca                	or     %ecx,%edx
  800b77:	09 f2                	or     %esi,%edx
  800b79:	f6 c2 03             	test   $0x3,%dl
  800b7c:	75 0a                	jne    800b88 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b81:	89 c7                	mov    %eax,%edi
  800b83:	fc                   	cld    
  800b84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b86:	eb 05                	jmp    800b8d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b88:	89 c7                	mov    %eax,%edi
  800b8a:	fc                   	cld    
  800b8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b91:	f3 0f 1e fb          	endbr32 
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b9b:	ff 75 10             	pushl  0x10(%ebp)
  800b9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ba1:	ff 75 08             	pushl  0x8(%ebp)
  800ba4:	e8 82 ff ff ff       	call   800b2b <memmove>
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bba:	89 c6                	mov    %eax,%esi
  800bbc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbf:	39 f0                	cmp    %esi,%eax
  800bc1:	74 1c                	je     800bdf <memcmp+0x34>
		if (*s1 != *s2)
  800bc3:	0f b6 08             	movzbl (%eax),%ecx
  800bc6:	0f b6 1a             	movzbl (%edx),%ebx
  800bc9:	38 d9                	cmp    %bl,%cl
  800bcb:	75 08                	jne    800bd5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bcd:	83 c0 01             	add    $0x1,%eax
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	eb ea                	jmp    800bbf <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800bd5:	0f b6 c1             	movzbl %cl,%eax
  800bd8:	0f b6 db             	movzbl %bl,%ebx
  800bdb:	29 d8                	sub    %ebx,%eax
  800bdd:	eb 05                	jmp    800be4 <memcmp+0x39>
	}

	return 0;
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be8:	f3 0f 1e fb          	endbr32 
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bf5:	89 c2                	mov    %eax,%edx
  800bf7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bfa:	39 d0                	cmp    %edx,%eax
  800bfc:	73 09                	jae    800c07 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfe:	38 08                	cmp    %cl,(%eax)
  800c00:	74 05                	je     800c07 <memfind+0x1f>
	for (; s < ends; s++)
  800c02:	83 c0 01             	add    $0x1,%eax
  800c05:	eb f3                	jmp    800bfa <memfind+0x12>
			break;
	return (void *) s;
}
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c09:	f3 0f 1e fb          	endbr32 
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c19:	eb 03                	jmp    800c1e <strtol+0x15>
		s++;
  800c1b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c1e:	0f b6 01             	movzbl (%ecx),%eax
  800c21:	3c 20                	cmp    $0x20,%al
  800c23:	74 f6                	je     800c1b <strtol+0x12>
  800c25:	3c 09                	cmp    $0x9,%al
  800c27:	74 f2                	je     800c1b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c29:	3c 2b                	cmp    $0x2b,%al
  800c2b:	74 2a                	je     800c57 <strtol+0x4e>
	int neg = 0;
  800c2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c32:	3c 2d                	cmp    $0x2d,%al
  800c34:	74 2b                	je     800c61 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c36:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c3c:	75 0f                	jne    800c4d <strtol+0x44>
  800c3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c41:	74 28                	je     800c6b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4a:	0f 44 d8             	cmove  %eax,%ebx
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c52:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c55:	eb 46                	jmp    800c9d <strtol+0x94>
		s++;
  800c57:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	eb d5                	jmp    800c36 <strtol+0x2d>
		s++, neg = 1;
  800c61:	83 c1 01             	add    $0x1,%ecx
  800c64:	bf 01 00 00 00       	mov    $0x1,%edi
  800c69:	eb cb                	jmp    800c36 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c6f:	74 0e                	je     800c7f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c71:	85 db                	test   %ebx,%ebx
  800c73:	75 d8                	jne    800c4d <strtol+0x44>
		s++, base = 8;
  800c75:	83 c1 01             	add    $0x1,%ecx
  800c78:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c7d:	eb ce                	jmp    800c4d <strtol+0x44>
		s += 2, base = 16;
  800c7f:	83 c1 02             	add    $0x2,%ecx
  800c82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c87:	eb c4                	jmp    800c4d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c89:	0f be d2             	movsbl %dl,%edx
  800c8c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c8f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c92:	7d 3a                	jge    800cce <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c94:	83 c1 01             	add    $0x1,%ecx
  800c97:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c9b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c9d:	0f b6 11             	movzbl (%ecx),%edx
  800ca0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ca3:	89 f3                	mov    %esi,%ebx
  800ca5:	80 fb 09             	cmp    $0x9,%bl
  800ca8:	76 df                	jbe    800c89 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800caa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cad:	89 f3                	mov    %esi,%ebx
  800caf:	80 fb 19             	cmp    $0x19,%bl
  800cb2:	77 08                	ja     800cbc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cb4:	0f be d2             	movsbl %dl,%edx
  800cb7:	83 ea 57             	sub    $0x57,%edx
  800cba:	eb d3                	jmp    800c8f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800cbc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cbf:	89 f3                	mov    %esi,%ebx
  800cc1:	80 fb 19             	cmp    $0x19,%bl
  800cc4:	77 08                	ja     800cce <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cc6:	0f be d2             	movsbl %dl,%edx
  800cc9:	83 ea 37             	sub    $0x37,%edx
  800ccc:	eb c1                	jmp    800c8f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd2:	74 05                	je     800cd9 <strtol+0xd0>
		*endptr = (char *) s;
  800cd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cd9:	89 c2                	mov    %eax,%edx
  800cdb:	f7 da                	neg    %edx
  800cdd:	85 ff                	test   %edi,%edi
  800cdf:	0f 45 c2             	cmovne %edx,%eax
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce7:	f3 0f 1e fb          	endbr32 
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	89 c3                	mov    %eax,%ebx
  800cfe:	89 c7                	mov    %eax,%edi
  800d00:	89 c6                	mov    %eax,%esi
  800d02:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d09:	f3 0f 1e fb          	endbr32 
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1d:	89 d1                	mov    %edx,%ecx
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	89 d7                	mov    %edx,%edi
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d2c:	f3 0f 1e fb          	endbr32 
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d43:	89 cb                	mov    %ecx,%ebx
  800d45:	89 cf                	mov    %ecx,%edi
  800d47:	89 ce                	mov    %ecx,%esi
  800d49:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 02 00 00 00       	mov    $0x2,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_yield>:

void
sys_yield(void)
{
  800d73:	f3 0f 1e fb          	endbr32 
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d82:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	89 d3                	mov    %edx,%ebx
  800d8b:	89 d7                	mov    %edx,%edi
  800d8d:	89 d6                	mov    %edx,%esi
  800d8f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d96:	f3 0f 1e fb          	endbr32 
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da0:	be 00 00 00 00       	mov    $0x0,%esi
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	b8 04 00 00 00       	mov    $0x4,%eax
  800db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db3:	89 f7                	mov    %esi,%edi
  800db5:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbc:	f3 0f 1e fb          	endbr32 
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dda:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800de1:	f3 0f 1e fb          	endbr32 
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	b8 06 00 00 00       	mov    $0x6,%eax
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e06:	f3 0f 1e fb          	endbr32 
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2b:	f3 0f 1e fb          	endbr32 
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	b8 09 00 00 00       	mov    $0x9,%eax
  800e45:	89 df                	mov    %ebx,%edi
  800e47:	89 de                	mov    %ebx,%esi
  800e49:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e50:	f3 0f 1e fb          	endbr32 
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e75:	f3 0f 1e fb          	endbr32 
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8a:	be 00 00 00 00       	mov    $0x0,%esi
  800e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e95:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9c:	f3 0f 1e fb          	endbr32 
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb3:	89 cb                	mov    %ecx,%ebx
  800eb5:	89 cf                	mov    %ecx,%edi
  800eb7:	89 ce                	mov    %ecx,%esi
  800eb9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eca:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ed4:	89 d1                	mov    %edx,%ecx
  800ed6:	89 d3                	mov    %edx,%ebx
  800ed8:	89 d7                	mov    %edx,%edi
  800eda:	89 d6                	mov    %edx,%esi
  800edc:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800ee3:	f3 0f 1e fb          	endbr32 
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800efd:	89 df                	mov    %ebx,%edi
  800eff:	89 de                	mov    %ebx,%esi
  800f01:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800f08:	f3 0f 1e fb          	endbr32 
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f17:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1d:	b8 10 00 00 00       	mov    $0x10,%eax
  800f22:	89 df                	mov    %ebx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800f2d:	f3 0f 1e fb          	endbr32 
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	53                   	push   %ebx
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800f3b:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800f3d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f41:	0f 84 9a 00 00 00    	je     800fe1 <pgfault+0xb4>
  800f47:	89 d8                	mov    %ebx,%eax
  800f49:	c1 e8 16             	shr    $0x16,%eax
  800f4c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f53:	a8 01                	test   $0x1,%al
  800f55:	0f 84 86 00 00 00    	je     800fe1 <pgfault+0xb4>
  800f5b:	89 d8                	mov    %ebx,%eax
  800f5d:	c1 e8 0c             	shr    $0xc,%eax
  800f60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f67:	f6 c2 01             	test   $0x1,%dl
  800f6a:	74 75                	je     800fe1 <pgfault+0xb4>
  800f6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f73:	f6 c4 08             	test   $0x8,%ah
  800f76:	74 69                	je     800fe1 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	6a 07                	push   $0x7
  800f7d:	68 00 f0 7f 00       	push   $0x7ff000
  800f82:	6a 00                	push   $0x0
  800f84:	e8 0d fe ff ff       	call   800d96 <sys_page_alloc>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	78 63                	js     800ff3 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f90:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800f96:	83 ec 04             	sub    $0x4,%esp
  800f99:	68 00 10 00 00       	push   $0x1000
  800f9e:	53                   	push   %ebx
  800f9f:	68 00 f0 7f 00       	push   $0x7ff000
  800fa4:	e8 e8 fb ff ff       	call   800b91 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800fa9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fb0:	53                   	push   %ebx
  800fb1:	6a 00                	push   $0x0
  800fb3:	68 00 f0 7f 00       	push   $0x7ff000
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 fd fd ff ff       	call   800dbc <sys_page_map>
  800fbf:	83 c4 20             	add    $0x20,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 3f                	js     801005 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	68 00 f0 7f 00       	push   $0x7ff000
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 0c fe ff ff       	call   800de1 <sys_page_unmap>
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 3b                	js     801017 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800fdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800fe1:	53                   	push   %ebx
  800fe2:	68 00 2c 80 00       	push   $0x802c00
  800fe7:	6a 20                	push   $0x20
  800fe9:	68 be 2c 80 00       	push   $0x802cbe
  800fee:	e8 49 f2 ff ff       	call   80023c <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800ff3:	50                   	push   %eax
  800ff4:	68 40 2c 80 00       	push   $0x802c40
  800ff9:	6a 2c                	push   $0x2c
  800ffb:	68 be 2c 80 00       	push   $0x802cbe
  801000:	e8 37 f2 ff ff       	call   80023c <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  801005:	50                   	push   %eax
  801006:	68 6c 2c 80 00       	push   $0x802c6c
  80100b:	6a 33                	push   $0x33
  80100d:	68 be 2c 80 00       	push   $0x802cbe
  801012:	e8 25 f2 ff ff       	call   80023c <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  801017:	50                   	push   %eax
  801018:	68 94 2c 80 00       	push   $0x802c94
  80101d:	6a 36                	push   $0x36
  80101f:	68 be 2c 80 00       	push   $0x802cbe
  801024:	e8 13 f2 ff ff       	call   80023c <_panic>

00801029 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801029:	f3 0f 1e fb          	endbr32 
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
  801033:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  801036:	68 2d 0f 80 00       	push   $0x800f2d
  80103b:	e8 82 13 00 00       	call   8023c2 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801040:	b8 07 00 00 00       	mov    $0x7,%eax
  801045:	cd 30                	int    $0x30
  801047:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 29                	js     80107a <fork+0x51>
  801051:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801053:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  801058:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80105c:	75 60                	jne    8010be <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  80105e:	e8 ed fc ff ff       	call   800d50 <sys_getenvid>
  801063:	25 ff 03 00 00       	and    $0x3ff,%eax
  801068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80106b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801070:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801075:	e9 14 01 00 00       	jmp    80118e <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  80107a:	50                   	push   %eax
  80107b:	68 c9 2c 80 00       	push   $0x802cc9
  801080:	68 90 00 00 00       	push   $0x90
  801085:	68 be 2c 80 00       	push   $0x802cbe
  80108a:	e8 ad f1 ff ff       	call   80023c <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  80108f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	25 07 0e 00 00       	and    $0xe07,%eax
  80109e:	50                   	push   %eax
  80109f:	56                   	push   %esi
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	6a 00                	push   $0x0
  8010a4:	e8 13 fd ff ff       	call   800dbc <sys_page_map>
  8010a9:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8010ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010b8:	0f 84 95 00 00 00    	je     801153 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8010be:	89 d8                	mov    %ebx,%eax
  8010c0:	c1 e8 16             	shr    $0x16,%eax
  8010c3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ca:	a8 01                	test   $0x1,%al
  8010cc:	74 de                	je     8010ac <fork+0x83>
  8010ce:	89 d8                	mov    %ebx,%eax
  8010d0:	c1 e8 0c             	shr    $0xc,%eax
  8010d3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010da:	f6 c2 01             	test   $0x1,%dl
  8010dd:	74 cd                	je     8010ac <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  8010df:	89 c6                	mov    %eax,%esi
  8010e1:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  8010e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010eb:	f6 c6 04             	test   $0x4,%dh
  8010ee:	75 9f                	jne    80108f <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  8010f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f7:	f6 c2 02             	test   $0x2,%dl
  8010fa:	75 0c                	jne    801108 <fork+0xdf>
  8010fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801103:	f6 c4 08             	test   $0x8,%ah
  801106:	74 34                	je     80113c <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	68 05 08 00 00       	push   $0x805
  801110:	56                   	push   %esi
  801111:	57                   	push   %edi
  801112:	56                   	push   %esi
  801113:	6a 00                	push   $0x0
  801115:	e8 a2 fc ff ff       	call   800dbc <sys_page_map>
			if (r<0) return r;
  80111a:	83 c4 20             	add    $0x20,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 8b                	js     8010ac <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	68 05 08 00 00       	push   $0x805
  801129:	56                   	push   %esi
  80112a:	6a 00                	push   $0x0
  80112c:	56                   	push   %esi
  80112d:	6a 00                	push   $0x0
  80112f:	e8 88 fc ff ff       	call   800dbc <sys_page_map>
  801134:	83 c4 20             	add    $0x20,%esp
  801137:	e9 70 ff ff ff       	jmp    8010ac <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	6a 05                	push   $0x5
  801141:	56                   	push   %esi
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	6a 00                	push   $0x0
  801146:	e8 71 fc ff ff       	call   800dbc <sys_page_map>
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	e9 59 ff ff ff       	jmp    8010ac <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	6a 07                	push   $0x7
  801158:	68 00 f0 bf ee       	push   $0xeebff000
  80115d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801160:	56                   	push   %esi
  801161:	e8 30 fc ff ff       	call   800d96 <sys_page_alloc>
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	78 2b                	js     801198 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	68 35 24 80 00       	push   $0x802435
  801175:	56                   	push   %esi
  801176:	e8 d5 fc ff ff       	call   800e50 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80117b:	83 c4 08             	add    $0x8,%esp
  80117e:	6a 02                	push   $0x2
  801180:	56                   	push   %esi
  801181:	e8 80 fc ff ff       	call   800e06 <sys_env_set_status>
  801186:	83 c4 10             	add    $0x10,%esp
		return r;
  801189:	85 c0                	test   %eax,%eax
  80118b:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  80118e:	89 f8                	mov    %edi,%eax
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
		return r;
  801198:	89 c7                	mov    %eax,%edi
  80119a:	eb f2                	jmp    80118e <fork+0x165>

0080119c <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  80119c:	f3 0f 1e fb          	endbr32 
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a6:	68 e5 2c 80 00       	push   $0x802ce5
  8011ab:	68 b2 00 00 00       	push   $0xb2
  8011b0:	68 be 2c 80 00       	push   $0x802cbe
  8011b5:	e8 82 f0 ff ff       	call   80023c <_panic>

008011ba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ba:	f3 0f 1e fb          	endbr32 
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c9:	c1 e8 0c             	shr    $0xc,%eax
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ce:	f3 0f 1e fb          	endbr32 
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e9:	f3 0f 1e fb          	endbr32 
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	c1 ea 16             	shr    $0x16,%edx
  8011fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801201:	f6 c2 01             	test   $0x1,%dl
  801204:	74 2d                	je     801233 <fd_alloc+0x4a>
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 0c             	shr    $0xc,%edx
  80120b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 1c                	je     801233 <fd_alloc+0x4a>
  801217:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80121c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801221:	75 d2                	jne    8011f5 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80122c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801231:	eb 0a                	jmp    80123d <fd_alloc+0x54>
			*fd_store = fd;
  801233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801236:	89 01                	mov    %eax,(%ecx)
			return 0;
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123f:	f3 0f 1e fb          	endbr32 
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801249:	83 f8 1f             	cmp    $0x1f,%eax
  80124c:	77 30                	ja     80127e <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124e:	c1 e0 0c             	shl    $0xc,%eax
  801251:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801256:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80125c:	f6 c2 01             	test   $0x1,%dl
  80125f:	74 24                	je     801285 <fd_lookup+0x46>
  801261:	89 c2                	mov    %eax,%edx
  801263:	c1 ea 0c             	shr    $0xc,%edx
  801266:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126d:	f6 c2 01             	test   $0x1,%dl
  801270:	74 1a                	je     80128c <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801272:	8b 55 0c             	mov    0xc(%ebp),%edx
  801275:	89 02                	mov    %eax,(%edx)
	return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    
		return -E_INVAL;
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb f7                	jmp    80127c <fd_lookup+0x3d>
		return -E_INVAL;
  801285:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128a:	eb f0                	jmp    80127c <fd_lookup+0x3d>
  80128c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801291:	eb e9                	jmp    80127c <fd_lookup+0x3d>

00801293 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801293:	f3 0f 1e fb          	endbr32 
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a5:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012aa:	39 08                	cmp    %ecx,(%eax)
  8012ac:	74 38                	je     8012e6 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8012ae:	83 c2 01             	add    $0x1,%edx
  8012b1:	8b 04 95 78 2d 80 00 	mov    0x802d78(,%edx,4),%eax
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	75 ee                	jne    8012aa <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c1:	8b 40 48             	mov    0x48(%eax),%eax
  8012c4:	83 ec 04             	sub    $0x4,%esp
  8012c7:	51                   	push   %ecx
  8012c8:	50                   	push   %eax
  8012c9:	68 fc 2c 80 00       	push   $0x802cfc
  8012ce:	e8 50 f0 ff ff       	call   800323 <cprintf>
	*dev = 0;
  8012d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    
			*dev = devtab[i];
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f0:	eb f2                	jmp    8012e4 <dev_lookup+0x51>

008012f2 <fd_close>:
{
  8012f2:	f3 0f 1e fb          	endbr32 
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 24             	sub    $0x24,%esp
  8012ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801302:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801305:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801308:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801309:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801312:	50                   	push   %eax
  801313:	e8 27 ff ff ff       	call   80123f <fd_lookup>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 05                	js     801326 <fd_close+0x34>
	    || fd != fd2)
  801321:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801324:	74 16                	je     80133c <fd_close+0x4a>
		return (must_exist ? r : 0);
  801326:	89 f8                	mov    %edi,%eax
  801328:	84 c0                	test   %al,%al
  80132a:	b8 00 00 00 00       	mov    $0x0,%eax
  80132f:	0f 44 d8             	cmove  %eax,%ebx
}
  801332:	89 d8                	mov    %ebx,%eax
  801334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	ff 36                	pushl  (%esi)
  801345:	e8 49 ff ff ff       	call   801293 <dev_lookup>
  80134a:	89 c3                	mov    %eax,%ebx
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 1a                	js     80136d <fd_close+0x7b>
		if (dev->dev_close)
  801353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801356:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801359:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80135e:	85 c0                	test   %eax,%eax
  801360:	74 0b                	je     80136d <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	56                   	push   %esi
  801366:	ff d0                	call   *%eax
  801368:	89 c3                	mov    %eax,%ebx
  80136a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	56                   	push   %esi
  801371:	6a 00                	push   $0x0
  801373:	e8 69 fa ff ff       	call   800de1 <sys_page_unmap>
	return r;
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	eb b5                	jmp    801332 <fd_close+0x40>

0080137d <close>:

int
close(int fdnum)
{
  80137d:	f3 0f 1e fb          	endbr32 
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801387:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	ff 75 08             	pushl  0x8(%ebp)
  80138e:	e8 ac fe ff ff       	call   80123f <fd_lookup>
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	79 02                	jns    80139c <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    
		return fd_close(fd, 1);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	6a 01                	push   $0x1
  8013a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a4:	e8 49 ff ff ff       	call   8012f2 <fd_close>
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	eb ec                	jmp    80139a <close+0x1d>

008013ae <close_all>:

void
close_all(void)
{
  8013ae:	f3 0f 1e fb          	endbr32 
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013be:	83 ec 0c             	sub    $0xc,%esp
  8013c1:	53                   	push   %ebx
  8013c2:	e8 b6 ff ff ff       	call   80137d <close>
	for (i = 0; i < MAXFD; i++)
  8013c7:	83 c3 01             	add    $0x1,%ebx
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	83 fb 20             	cmp    $0x20,%ebx
  8013d0:	75 ec                	jne    8013be <close_all+0x10>
}
  8013d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d7:	f3 0f 1e fb          	endbr32 
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	57                   	push   %edi
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	ff 75 08             	pushl  0x8(%ebp)
  8013eb:	e8 4f fe ff ff       	call   80123f <fd_lookup>
  8013f0:	89 c3                	mov    %eax,%ebx
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	0f 88 81 00 00 00    	js     80147e <dup+0xa7>
		return r;
	close(newfdnum);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	ff 75 0c             	pushl  0xc(%ebp)
  801403:	e8 75 ff ff ff       	call   80137d <close>

	newfd = INDEX2FD(newfdnum);
  801408:	8b 75 0c             	mov    0xc(%ebp),%esi
  80140b:	c1 e6 0c             	shl    $0xc,%esi
  80140e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801414:	83 c4 04             	add    $0x4,%esp
  801417:	ff 75 e4             	pushl  -0x1c(%ebp)
  80141a:	e8 af fd ff ff       	call   8011ce <fd2data>
  80141f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801421:	89 34 24             	mov    %esi,(%esp)
  801424:	e8 a5 fd ff ff       	call   8011ce <fd2data>
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80142e:	89 d8                	mov    %ebx,%eax
  801430:	c1 e8 16             	shr    $0x16,%eax
  801433:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143a:	a8 01                	test   $0x1,%al
  80143c:	74 11                	je     80144f <dup+0x78>
  80143e:	89 d8                	mov    %ebx,%eax
  801440:	c1 e8 0c             	shr    $0xc,%eax
  801443:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144a:	f6 c2 01             	test   $0x1,%dl
  80144d:	75 39                	jne    801488 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801452:	89 d0                	mov    %edx,%eax
  801454:	c1 e8 0c             	shr    $0xc,%eax
  801457:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145e:	83 ec 0c             	sub    $0xc,%esp
  801461:	25 07 0e 00 00       	and    $0xe07,%eax
  801466:	50                   	push   %eax
  801467:	56                   	push   %esi
  801468:	6a 00                	push   $0x0
  80146a:	52                   	push   %edx
  80146b:	6a 00                	push   $0x0
  80146d:	e8 4a f9 ff ff       	call   800dbc <sys_page_map>
  801472:	89 c3                	mov    %eax,%ebx
  801474:	83 c4 20             	add    $0x20,%esp
  801477:	85 c0                	test   %eax,%eax
  801479:	78 31                	js     8014ac <dup+0xd5>
		goto err;

	return newfdnum;
  80147b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80147e:	89 d8                	mov    %ebx,%eax
  801480:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801488:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148f:	83 ec 0c             	sub    $0xc,%esp
  801492:	25 07 0e 00 00       	and    $0xe07,%eax
  801497:	50                   	push   %eax
  801498:	57                   	push   %edi
  801499:	6a 00                	push   $0x0
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	e8 19 f9 ff ff       	call   800dbc <sys_page_map>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	83 c4 20             	add    $0x20,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	79 a3                	jns    80144f <dup+0x78>
	sys_page_unmap(0, newfd);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	56                   	push   %esi
  8014b0:	6a 00                	push   $0x0
  8014b2:	e8 2a f9 ff ff       	call   800de1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b7:	83 c4 08             	add    $0x8,%esp
  8014ba:	57                   	push   %edi
  8014bb:	6a 00                	push   $0x0
  8014bd:	e8 1f f9 ff ff       	call   800de1 <sys_page_unmap>
	return r;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	eb b7                	jmp    80147e <dup+0xa7>

008014c7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c7:	f3 0f 1e fb          	endbr32 
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 1c             	sub    $0x1c,%esp
  8014d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	53                   	push   %ebx
  8014da:	e8 60 fd ff ff       	call   80123f <fd_lookup>
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 3f                	js     801525 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f0:	ff 30                	pushl  (%eax)
  8014f2:	e8 9c fd ff ff       	call   801293 <dev_lookup>
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 27                	js     801525 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801501:	8b 42 08             	mov    0x8(%edx),%eax
  801504:	83 e0 03             	and    $0x3,%eax
  801507:	83 f8 01             	cmp    $0x1,%eax
  80150a:	74 1e                	je     80152a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80150c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150f:	8b 40 08             	mov    0x8(%eax),%eax
  801512:	85 c0                	test   %eax,%eax
  801514:	74 35                	je     80154b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	ff 75 10             	pushl  0x10(%ebp)
  80151c:	ff 75 0c             	pushl  0xc(%ebp)
  80151f:	52                   	push   %edx
  801520:	ff d0                	call   *%eax
  801522:	83 c4 10             	add    $0x10,%esp
}
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80152a:	a1 08 40 80 00       	mov    0x804008,%eax
  80152f:	8b 40 48             	mov    0x48(%eax),%eax
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	53                   	push   %ebx
  801536:	50                   	push   %eax
  801537:	68 3d 2d 80 00       	push   $0x802d3d
  80153c:	e8 e2 ed ff ff       	call   800323 <cprintf>
		return -E_INVAL;
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801549:	eb da                	jmp    801525 <read+0x5e>
		return -E_NOT_SUPP;
  80154b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801550:	eb d3                	jmp    801525 <read+0x5e>

00801552 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801552:	f3 0f 1e fb          	endbr32 
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	57                   	push   %edi
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801562:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156a:	eb 02                	jmp    80156e <readn+0x1c>
  80156c:	01 c3                	add    %eax,%ebx
  80156e:	39 f3                	cmp    %esi,%ebx
  801570:	73 21                	jae    801593 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801572:	83 ec 04             	sub    $0x4,%esp
  801575:	89 f0                	mov    %esi,%eax
  801577:	29 d8                	sub    %ebx,%eax
  801579:	50                   	push   %eax
  80157a:	89 d8                	mov    %ebx,%eax
  80157c:	03 45 0c             	add    0xc(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	57                   	push   %edi
  801581:	e8 41 ff ff ff       	call   8014c7 <read>
		if (m < 0)
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 04                	js     801591 <readn+0x3f>
			return m;
		if (m == 0)
  80158d:	75 dd                	jne    80156c <readn+0x1a>
  80158f:	eb 02                	jmp    801593 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801591:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801593:	89 d8                	mov    %ebx,%eax
  801595:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801598:	5b                   	pop    %ebx
  801599:	5e                   	pop    %esi
  80159a:	5f                   	pop    %edi
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159d:	f3 0f 1e fb          	endbr32 
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 1c             	sub    $0x1c,%esp
  8015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	53                   	push   %ebx
  8015b0:	e8 8a fc ff ff       	call   80123f <fd_lookup>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 3a                	js     8015f6 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c6:	ff 30                	pushl  (%eax)
  8015c8:	e8 c6 fc ff ff       	call   801293 <dev_lookup>
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 22                	js     8015f6 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015db:	74 1e                	je     8015fb <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015e3:	85 d2                	test   %edx,%edx
  8015e5:	74 35                	je     80161c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	ff 75 10             	pushl  0x10(%ebp)
  8015ed:	ff 75 0c             	pushl  0xc(%ebp)
  8015f0:	50                   	push   %eax
  8015f1:	ff d2                	call   *%edx
  8015f3:	83 c4 10             	add    $0x10,%esp
}
  8015f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015fb:	a1 08 40 80 00       	mov    0x804008,%eax
  801600:	8b 40 48             	mov    0x48(%eax),%eax
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	53                   	push   %ebx
  801607:	50                   	push   %eax
  801608:	68 59 2d 80 00       	push   $0x802d59
  80160d:	e8 11 ed ff ff       	call   800323 <cprintf>
		return -E_INVAL;
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161a:	eb da                	jmp    8015f6 <write+0x59>
		return -E_NOT_SUPP;
  80161c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801621:	eb d3                	jmp    8015f6 <write+0x59>

00801623 <seek>:

int
seek(int fdnum, off_t offset)
{
  801623:	f3 0f 1e fb          	endbr32 
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	ff 75 08             	pushl  0x8(%ebp)
  801634:	e8 06 fc ff ff       	call   80123f <fd_lookup>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 0e                	js     80164e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801640:	8b 55 0c             	mov    0xc(%ebp),%edx
  801643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801646:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801649:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801650:	f3 0f 1e fb          	endbr32 
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	83 ec 1c             	sub    $0x1c,%esp
  80165b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	53                   	push   %ebx
  801663:	e8 d7 fb ff ff       	call   80123f <fd_lookup>
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 37                	js     8016a6 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801679:	ff 30                	pushl  (%eax)
  80167b:	e8 13 fc ff ff       	call   801293 <dev_lookup>
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 1f                	js     8016a6 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168e:	74 1b                	je     8016ab <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801690:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801693:	8b 52 18             	mov    0x18(%edx),%edx
  801696:	85 d2                	test   %edx,%edx
  801698:	74 32                	je     8016cc <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	ff 75 0c             	pushl  0xc(%ebp)
  8016a0:	50                   	push   %eax
  8016a1:	ff d2                	call   *%edx
  8016a3:	83 c4 10             	add    $0x10,%esp
}
  8016a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016ab:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b0:	8b 40 48             	mov    0x48(%eax),%eax
  8016b3:	83 ec 04             	sub    $0x4,%esp
  8016b6:	53                   	push   %ebx
  8016b7:	50                   	push   %eax
  8016b8:	68 1c 2d 80 00       	push   $0x802d1c
  8016bd:	e8 61 ec ff ff       	call   800323 <cprintf>
		return -E_INVAL;
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ca:	eb da                	jmp    8016a6 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d1:	eb d3                	jmp    8016a6 <ftruncate+0x56>

008016d3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d3:	f3 0f 1e fb          	endbr32 
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	83 ec 1c             	sub    $0x1c,%esp
  8016de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e4:	50                   	push   %eax
  8016e5:	ff 75 08             	pushl  0x8(%ebp)
  8016e8:	e8 52 fb ff ff       	call   80123f <fd_lookup>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 4b                	js     80173f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fe:	ff 30                	pushl  (%eax)
  801700:	e8 8e fb ff ff       	call   801293 <dev_lookup>
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 33                	js     80173f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80170c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801713:	74 2f                	je     801744 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801715:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801718:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171f:	00 00 00 
	stat->st_isdir = 0;
  801722:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801729:	00 00 00 
	stat->st_dev = dev;
  80172c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	53                   	push   %ebx
  801736:	ff 75 f0             	pushl  -0x10(%ebp)
  801739:	ff 50 14             	call   *0x14(%eax)
  80173c:	83 c4 10             	add    $0x10,%esp
}
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    
		return -E_NOT_SUPP;
  801744:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801749:	eb f4                	jmp    80173f <fstat+0x6c>

0080174b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174b:	f3 0f 1e fb          	endbr32 
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	56                   	push   %esi
  801753:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	6a 00                	push   $0x0
  801759:	ff 75 08             	pushl  0x8(%ebp)
  80175c:	e8 01 02 00 00       	call   801962 <open>
  801761:	89 c3                	mov    %eax,%ebx
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 1b                	js     801785 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	ff 75 0c             	pushl  0xc(%ebp)
  801770:	50                   	push   %eax
  801771:	e8 5d ff ff ff       	call   8016d3 <fstat>
  801776:	89 c6                	mov    %eax,%esi
	close(fd);
  801778:	89 1c 24             	mov    %ebx,(%esp)
  80177b:	e8 fd fb ff ff       	call   80137d <close>
	return r;
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	89 f3                	mov    %esi,%ebx
}
  801785:	89 d8                	mov    %ebx,%eax
  801787:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	89 c6                	mov    %eax,%esi
  801795:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801797:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179e:	74 27                	je     8017c7 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a0:	6a 07                	push   $0x7
  8017a2:	68 00 50 80 00       	push   $0x805000
  8017a7:	56                   	push   %esi
  8017a8:	ff 35 00 40 80 00    	pushl  0x804000
  8017ae:	e8 13 0d 00 00       	call   8024c6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b3:	83 c4 0c             	add    $0xc,%esp
  8017b6:	6a 00                	push   $0x0
  8017b8:	53                   	push   %ebx
  8017b9:	6a 00                	push   $0x0
  8017bb:	e8 99 0c 00 00       	call   802459 <ipc_recv>
}
  8017c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c3:	5b                   	pop    %ebx
  8017c4:	5e                   	pop    %esi
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	6a 01                	push   $0x1
  8017cc:	e8 4d 0d 00 00       	call   80251e <ipc_find_env>
  8017d1:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	eb c5                	jmp    8017a0 <fsipc+0x12>

008017db <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017db:	f3 0f 1e fb          	endbr32 
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017eb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 02 00 00 00       	mov    $0x2,%eax
  801802:	e8 87 ff ff ff       	call   80178e <fsipc>
}
  801807:	c9                   	leave  
  801808:	c3                   	ret    

00801809 <devfile_flush>:
{
  801809:	f3 0f 1e fb          	endbr32 
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 40 0c             	mov    0xc(%eax),%eax
  801819:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	b8 06 00 00 00       	mov    $0x6,%eax
  801828:	e8 61 ff ff ff       	call   80178e <fsipc>
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <devfile_stat>:
{
  80182f:	f3 0f 1e fb          	endbr32 
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	53                   	push   %ebx
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80183d:	8b 45 08             	mov    0x8(%ebp),%eax
  801840:	8b 40 0c             	mov    0xc(%eax),%eax
  801843:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801848:	ba 00 00 00 00       	mov    $0x0,%edx
  80184d:	b8 05 00 00 00       	mov    $0x5,%eax
  801852:	e8 37 ff ff ff       	call   80178e <fsipc>
  801857:	85 c0                	test   %eax,%eax
  801859:	78 2c                	js     801887 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	68 00 50 80 00       	push   $0x805000
  801863:	53                   	push   %ebx
  801864:	e8 c4 f0 ff ff       	call   80092d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801869:	a1 80 50 80 00       	mov    0x805080,%eax
  80186e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801874:	a1 84 50 80 00       	mov    0x805084,%eax
  801879:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <devfile_write>:
{
  80188c:	f3 0f 1e fb          	endbr32 
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	8b 45 10             	mov    0x10(%ebp),%eax
  801899:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80189e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ac:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018b2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b7:	50                   	push   %eax
  8018b8:	ff 75 0c             	pushl  0xc(%ebp)
  8018bb:	68 08 50 80 00       	push   $0x805008
  8018c0:	e8 66 f2 ff ff       	call   800b2b <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8018cf:	e8 ba fe ff ff       	call   80178e <fsipc>
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devfile_read>:
{
  8018d6:	f3 0f 1e fb          	endbr32 
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	56                   	push   %esi
  8018de:	53                   	push   %ebx
  8018df:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018ed:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8018fd:	e8 8c fe ff ff       	call   80178e <fsipc>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	85 c0                	test   %eax,%eax
  801906:	78 1f                	js     801927 <devfile_read+0x51>
	assert(r <= n);
  801908:	39 f0                	cmp    %esi,%eax
  80190a:	77 24                	ja     801930 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80190c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801911:	7f 36                	jg     801949 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801913:	83 ec 04             	sub    $0x4,%esp
  801916:	50                   	push   %eax
  801917:	68 00 50 80 00       	push   $0x805000
  80191c:	ff 75 0c             	pushl  0xc(%ebp)
  80191f:	e8 07 f2 ff ff       	call   800b2b <memmove>
	return r;
  801924:	83 c4 10             	add    $0x10,%esp
}
  801927:	89 d8                	mov    %ebx,%eax
  801929:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    
	assert(r <= n);
  801930:	68 8c 2d 80 00       	push   $0x802d8c
  801935:	68 93 2d 80 00       	push   $0x802d93
  80193a:	68 8c 00 00 00       	push   $0x8c
  80193f:	68 a8 2d 80 00       	push   $0x802da8
  801944:	e8 f3 e8 ff ff       	call   80023c <_panic>
	assert(r <= PGSIZE);
  801949:	68 b3 2d 80 00       	push   $0x802db3
  80194e:	68 93 2d 80 00       	push   $0x802d93
  801953:	68 8d 00 00 00       	push   $0x8d
  801958:	68 a8 2d 80 00       	push   $0x802da8
  80195d:	e8 da e8 ff ff       	call   80023c <_panic>

00801962 <open>:
{
  801962:	f3 0f 1e fb          	endbr32 
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	56                   	push   %esi
  80196a:	53                   	push   %ebx
  80196b:	83 ec 1c             	sub    $0x1c,%esp
  80196e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801971:	56                   	push   %esi
  801972:	e8 73 ef ff ff       	call   8008ea <strlen>
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197f:	7f 6c                	jg     8019ed <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801981:	83 ec 0c             	sub    $0xc,%esp
  801984:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801987:	50                   	push   %eax
  801988:	e8 5c f8 ff ff       	call   8011e9 <fd_alloc>
  80198d:	89 c3                	mov    %eax,%ebx
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	85 c0                	test   %eax,%eax
  801994:	78 3c                	js     8019d2 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	56                   	push   %esi
  80199a:	68 00 50 80 00       	push   $0x805000
  80199f:	e8 89 ef ff ff       	call   80092d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019af:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b4:	e8 d5 fd ff ff       	call   80178e <fsipc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 19                	js     8019db <open+0x79>
	return fd2num(fd);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c8:	e8 ed f7 ff ff       	call   8011ba <fd2num>
  8019cd:	89 c3                	mov    %eax,%ebx
  8019cf:	83 c4 10             	add    $0x10,%esp
}
  8019d2:	89 d8                	mov    %ebx,%eax
  8019d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    
		fd_close(fd, 0);
  8019db:	83 ec 08             	sub    $0x8,%esp
  8019de:	6a 00                	push   $0x0
  8019e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e3:	e8 0a f9 ff ff       	call   8012f2 <fd_close>
		return r;
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	eb e5                	jmp    8019d2 <open+0x70>
		return -E_BAD_PATH;
  8019ed:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019f2:	eb de                	jmp    8019d2 <open+0x70>

008019f4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f4:	f3 0f 1e fb          	endbr32 
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801a03:	b8 08 00 00 00       	mov    $0x8,%eax
  801a08:	e8 81 fd ff ff       	call   80178e <fsipc>
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a0f:	f3 0f 1e fb          	endbr32 
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a19:	68 1f 2e 80 00       	push   $0x802e1f
  801a1e:	ff 75 0c             	pushl  0xc(%ebp)
  801a21:	e8 07 ef ff ff       	call   80092d <strcpy>
	return 0;
}
  801a26:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <devsock_close>:
{
  801a2d:	f3 0f 1e fb          	endbr32 
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	53                   	push   %ebx
  801a35:	83 ec 10             	sub    $0x10,%esp
  801a38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a3b:	53                   	push   %ebx
  801a3c:	e8 1a 0b 00 00       	call   80255b <pageref>
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a46:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a4b:	83 fa 01             	cmp    $0x1,%edx
  801a4e:	74 05                	je     801a55 <devsock_close+0x28>
}
  801a50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	ff 73 0c             	pushl  0xc(%ebx)
  801a5b:	e8 e3 02 00 00       	call   801d43 <nsipc_close>
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	eb eb                	jmp    801a50 <devsock_close+0x23>

00801a65 <devsock_write>:
{
  801a65:	f3 0f 1e fb          	endbr32 
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a6f:	6a 00                	push   $0x0
  801a71:	ff 75 10             	pushl  0x10(%ebp)
  801a74:	ff 75 0c             	pushl  0xc(%ebp)
  801a77:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7a:	ff 70 0c             	pushl  0xc(%eax)
  801a7d:	e8 b5 03 00 00       	call   801e37 <nsipc_send>
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <devsock_read>:
{
  801a84:	f3 0f 1e fb          	endbr32 
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a8e:	6a 00                	push   $0x0
  801a90:	ff 75 10             	pushl  0x10(%ebp)
  801a93:	ff 75 0c             	pushl  0xc(%ebp)
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	ff 70 0c             	pushl  0xc(%eax)
  801a9c:	e8 1f 03 00 00       	call   801dc0 <nsipc_recv>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <fd2sockid>:
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aa9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aac:	52                   	push   %edx
  801aad:	50                   	push   %eax
  801aae:	e8 8c f7 ff ff       	call   80123f <fd_lookup>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 10                	js     801aca <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abd:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801ac3:	39 08                	cmp    %ecx,(%eax)
  801ac5:	75 05                	jne    801acc <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801ac7:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    
		return -E_NOT_SUPP;
  801acc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ad1:	eb f7                	jmp    801aca <fd2sockid+0x27>

00801ad3 <alloc_sockfd>:
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 1c             	sub    $0x1c,%esp
  801adb:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801add:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae0:	50                   	push   %eax
  801ae1:	e8 03 f7 ff ff       	call   8011e9 <fd_alloc>
  801ae6:	89 c3                	mov    %eax,%ebx
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 43                	js     801b32 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aef:	83 ec 04             	sub    $0x4,%esp
  801af2:	68 07 04 00 00       	push   $0x407
  801af7:	ff 75 f4             	pushl  -0xc(%ebp)
  801afa:	6a 00                	push   $0x0
  801afc:	e8 95 f2 ff ff       	call   800d96 <sys_page_alloc>
  801b01:	89 c3                	mov    %eax,%ebx
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 28                	js     801b32 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0d:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b13:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b18:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b1f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	50                   	push   %eax
  801b26:	e8 8f f6 ff ff       	call   8011ba <fd2num>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	eb 0c                	jmp    801b3e <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	56                   	push   %esi
  801b36:	e8 08 02 00 00       	call   801d43 <nsipc_close>
		return r;
  801b3b:	83 c4 10             	add    $0x10,%esp
}
  801b3e:	89 d8                	mov    %ebx,%eax
  801b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    

00801b47 <accept>:
{
  801b47:	f3 0f 1e fb          	endbr32 
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	e8 4a ff ff ff       	call   801aa3 <fd2sockid>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	78 1b                	js     801b78 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b5d:	83 ec 04             	sub    $0x4,%esp
  801b60:	ff 75 10             	pushl  0x10(%ebp)
  801b63:	ff 75 0c             	pushl  0xc(%ebp)
  801b66:	50                   	push   %eax
  801b67:	e8 22 01 00 00       	call   801c8e <nsipc_accept>
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 05                	js     801b78 <accept+0x31>
	return alloc_sockfd(r);
  801b73:	e8 5b ff ff ff       	call   801ad3 <alloc_sockfd>
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <bind>:
{
  801b7a:	f3 0f 1e fb          	endbr32 
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	e8 17 ff ff ff       	call   801aa3 <fd2sockid>
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 12                	js     801ba2 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801b90:	83 ec 04             	sub    $0x4,%esp
  801b93:	ff 75 10             	pushl  0x10(%ebp)
  801b96:	ff 75 0c             	pushl  0xc(%ebp)
  801b99:	50                   	push   %eax
  801b9a:	e8 45 01 00 00       	call   801ce4 <nsipc_bind>
  801b9f:	83 c4 10             	add    $0x10,%esp
}
  801ba2:	c9                   	leave  
  801ba3:	c3                   	ret    

00801ba4 <shutdown>:
{
  801ba4:	f3 0f 1e fb          	endbr32 
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bae:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb1:	e8 ed fe ff ff       	call   801aa3 <fd2sockid>
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	78 0f                	js     801bc9 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801bba:	83 ec 08             	sub    $0x8,%esp
  801bbd:	ff 75 0c             	pushl  0xc(%ebp)
  801bc0:	50                   	push   %eax
  801bc1:	e8 57 01 00 00       	call   801d1d <nsipc_shutdown>
  801bc6:	83 c4 10             	add    $0x10,%esp
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <connect>:
{
  801bcb:	f3 0f 1e fb          	endbr32 
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	e8 c6 fe ff ff       	call   801aa3 <fd2sockid>
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 12                	js     801bf3 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801be1:	83 ec 04             	sub    $0x4,%esp
  801be4:	ff 75 10             	pushl  0x10(%ebp)
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	50                   	push   %eax
  801beb:	e8 71 01 00 00       	call   801d61 <nsipc_connect>
  801bf0:	83 c4 10             	add    $0x10,%esp
}
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <listen>:
{
  801bf5:	f3 0f 1e fb          	endbr32 
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
  801c02:	e8 9c fe ff ff       	call   801aa3 <fd2sockid>
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 0f                	js     801c1a <listen+0x25>
	return nsipc_listen(r, backlog);
  801c0b:	83 ec 08             	sub    $0x8,%esp
  801c0e:	ff 75 0c             	pushl  0xc(%ebp)
  801c11:	50                   	push   %eax
  801c12:	e8 83 01 00 00       	call   801d9a <nsipc_listen>
  801c17:	83 c4 10             	add    $0x10,%esp
}
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <socket>:

int
socket(int domain, int type, int protocol)
{
  801c1c:	f3 0f 1e fb          	endbr32 
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c26:	ff 75 10             	pushl  0x10(%ebp)
  801c29:	ff 75 0c             	pushl  0xc(%ebp)
  801c2c:	ff 75 08             	pushl  0x8(%ebp)
  801c2f:	e8 65 02 00 00       	call   801e99 <nsipc_socket>
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	78 05                	js     801c40 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801c3b:	e8 93 fe ff ff       	call   801ad3 <alloc_sockfd>
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	53                   	push   %ebx
  801c46:	83 ec 04             	sub    $0x4,%esp
  801c49:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c4b:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c52:	74 26                	je     801c7a <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c54:	6a 07                	push   $0x7
  801c56:	68 00 60 80 00       	push   $0x806000
  801c5b:	53                   	push   %ebx
  801c5c:	ff 35 04 40 80 00    	pushl  0x804004
  801c62:	e8 5f 08 00 00       	call   8024c6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c67:	83 c4 0c             	add    $0xc,%esp
  801c6a:	6a 00                	push   $0x0
  801c6c:	6a 00                	push   $0x0
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 e4 07 00 00       	call   802459 <ipc_recv>
}
  801c75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	6a 02                	push   $0x2
  801c7f:	e8 9a 08 00 00       	call   80251e <ipc_find_env>
  801c84:	a3 04 40 80 00       	mov    %eax,0x804004
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	eb c6                	jmp    801c54 <nsipc+0x12>

00801c8e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c8e:	f3 0f 1e fb          	endbr32 
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ca2:	8b 06                	mov    (%esi),%eax
  801ca4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cae:	e8 8f ff ff ff       	call   801c42 <nsipc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	79 09                	jns    801cc2 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5e                   	pop    %esi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cc2:	83 ec 04             	sub    $0x4,%esp
  801cc5:	ff 35 10 60 80 00    	pushl  0x806010
  801ccb:	68 00 60 80 00       	push   $0x806000
  801cd0:	ff 75 0c             	pushl  0xc(%ebp)
  801cd3:	e8 53 ee ff ff       	call   800b2b <memmove>
		*addrlen = ret->ret_addrlen;
  801cd8:	a1 10 60 80 00       	mov    0x806010,%eax
  801cdd:	89 06                	mov    %eax,(%esi)
  801cdf:	83 c4 10             	add    $0x10,%esp
	return r;
  801ce2:	eb d5                	jmp    801cb9 <nsipc_accept+0x2b>

00801ce4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ce4:	f3 0f 1e fb          	endbr32 
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 08             	sub    $0x8,%esp
  801cef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cfa:	53                   	push   %ebx
  801cfb:	ff 75 0c             	pushl  0xc(%ebp)
  801cfe:	68 04 60 80 00       	push   $0x806004
  801d03:	e8 23 ee ff ff       	call   800b2b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d08:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d0e:	b8 02 00 00 00       	mov    $0x2,%eax
  801d13:	e8 2a ff ff ff       	call   801c42 <nsipc>
}
  801d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d1d:	f3 0f 1e fb          	endbr32 
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d32:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d37:	b8 03 00 00 00       	mov    $0x3,%eax
  801d3c:	e8 01 ff ff ff       	call   801c42 <nsipc>
}
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <nsipc_close>:

int
nsipc_close(int s)
{
  801d43:	f3 0f 1e fb          	endbr32 
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d55:	b8 04 00 00 00       	mov    $0x4,%eax
  801d5a:	e8 e3 fe ff ff       	call   801c42 <nsipc>
}
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d61:	f3 0f 1e fb          	endbr32 
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	53                   	push   %ebx
  801d69:	83 ec 08             	sub    $0x8,%esp
  801d6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d77:	53                   	push   %ebx
  801d78:	ff 75 0c             	pushl  0xc(%ebp)
  801d7b:	68 04 60 80 00       	push   $0x806004
  801d80:	e8 a6 ed ff ff       	call   800b2b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d85:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d8b:	b8 05 00 00 00       	mov    $0x5,%eax
  801d90:	e8 ad fe ff ff       	call   801c42 <nsipc>
}
  801d95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d9a:	f3 0f 1e fb          	endbr32 
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801db4:	b8 06 00 00 00       	mov    $0x6,%eax
  801db9:	e8 84 fe ff ff       	call   801c42 <nsipc>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dc0:	f3 0f 1e fb          	endbr32 
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dd4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dda:	8b 45 14             	mov    0x14(%ebp),%eax
  801ddd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801de2:	b8 07 00 00 00       	mov    $0x7,%eax
  801de7:	e8 56 fe ff ff       	call   801c42 <nsipc>
  801dec:	89 c3                	mov    %eax,%ebx
  801dee:	85 c0                	test   %eax,%eax
  801df0:	78 26                	js     801e18 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801df2:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801df8:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801dfd:	0f 4e c6             	cmovle %esi,%eax
  801e00:	39 c3                	cmp    %eax,%ebx
  801e02:	7f 1d                	jg     801e21 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e04:	83 ec 04             	sub    $0x4,%esp
  801e07:	53                   	push   %ebx
  801e08:	68 00 60 80 00       	push   $0x806000
  801e0d:	ff 75 0c             	pushl  0xc(%ebp)
  801e10:	e8 16 ed ff ff       	call   800b2b <memmove>
  801e15:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e18:	89 d8                	mov    %ebx,%eax
  801e1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e21:	68 2b 2e 80 00       	push   $0x802e2b
  801e26:	68 93 2d 80 00       	push   $0x802d93
  801e2b:	6a 62                	push   $0x62
  801e2d:	68 40 2e 80 00       	push   $0x802e40
  801e32:	e8 05 e4 ff ff       	call   80023c <_panic>

00801e37 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e37:	f3 0f 1e fb          	endbr32 
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 04             	sub    $0x4,%esp
  801e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e45:	8b 45 08             	mov    0x8(%ebp),%eax
  801e48:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e4d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e53:	7f 2e                	jg     801e83 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e55:	83 ec 04             	sub    $0x4,%esp
  801e58:	53                   	push   %ebx
  801e59:	ff 75 0c             	pushl  0xc(%ebp)
  801e5c:	68 0c 60 80 00       	push   $0x80600c
  801e61:	e8 c5 ec ff ff       	call   800b2b <memmove>
	nsipcbuf.send.req_size = size;
  801e66:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801e6f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e74:	b8 08 00 00 00       	mov    $0x8,%eax
  801e79:	e8 c4 fd ff ff       	call   801c42 <nsipc>
}
  801e7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    
	assert(size < 1600);
  801e83:	68 4c 2e 80 00       	push   $0x802e4c
  801e88:	68 93 2d 80 00       	push   $0x802d93
  801e8d:	6a 6d                	push   $0x6d
  801e8f:	68 40 2e 80 00       	push   $0x802e40
  801e94:	e8 a3 e3 ff ff       	call   80023c <_panic>

00801e99 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e99:	f3 0f 1e fb          	endbr32 
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eae:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801eb3:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ebb:	b8 09 00 00 00       	mov    $0x9,%eax
  801ec0:	e8 7d fd ff ff       	call   801c42 <nsipc>
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ec7:	f3 0f 1e fb          	endbr32 
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ed3:	83 ec 0c             	sub    $0xc,%esp
  801ed6:	ff 75 08             	pushl  0x8(%ebp)
  801ed9:	e8 f0 f2 ff ff       	call   8011ce <fd2data>
  801ede:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ee0:	83 c4 08             	add    $0x8,%esp
  801ee3:	68 58 2e 80 00       	push   $0x802e58
  801ee8:	53                   	push   %ebx
  801ee9:	e8 3f ea ff ff       	call   80092d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eee:	8b 46 04             	mov    0x4(%esi),%eax
  801ef1:	2b 06                	sub    (%esi),%eax
  801ef3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ef9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f00:	00 00 00 
	stat->st_dev = &devpipe;
  801f03:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f0a:	30 80 00 
	return 0;
}
  801f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f19:	f3 0f 1e fb          	endbr32 
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	53                   	push   %ebx
  801f21:	83 ec 0c             	sub    $0xc,%esp
  801f24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f27:	53                   	push   %ebx
  801f28:	6a 00                	push   $0x0
  801f2a:	e8 b2 ee ff ff       	call   800de1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f2f:	89 1c 24             	mov    %ebx,(%esp)
  801f32:	e8 97 f2 ff ff       	call   8011ce <fd2data>
  801f37:	83 c4 08             	add    $0x8,%esp
  801f3a:	50                   	push   %eax
  801f3b:	6a 00                	push   $0x0
  801f3d:	e8 9f ee ff ff       	call   800de1 <sys_page_unmap>
}
  801f42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <_pipeisclosed>:
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	57                   	push   %edi
  801f4b:	56                   	push   %esi
  801f4c:	53                   	push   %ebx
  801f4d:	83 ec 1c             	sub    $0x1c,%esp
  801f50:	89 c7                	mov    %eax,%edi
  801f52:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f54:	a1 08 40 80 00       	mov    0x804008,%eax
  801f59:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	57                   	push   %edi
  801f60:	e8 f6 05 00 00       	call   80255b <pageref>
  801f65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f68:	89 34 24             	mov    %esi,(%esp)
  801f6b:	e8 eb 05 00 00       	call   80255b <pageref>
		nn = thisenv->env_runs;
  801f70:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f76:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	39 cb                	cmp    %ecx,%ebx
  801f7e:	74 1b                	je     801f9b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f83:	75 cf                	jne    801f54 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f85:	8b 42 58             	mov    0x58(%edx),%eax
  801f88:	6a 01                	push   $0x1
  801f8a:	50                   	push   %eax
  801f8b:	53                   	push   %ebx
  801f8c:	68 5f 2e 80 00       	push   $0x802e5f
  801f91:	e8 8d e3 ff ff       	call   800323 <cprintf>
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	eb b9                	jmp    801f54 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f9b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f9e:	0f 94 c0             	sete   %al
  801fa1:	0f b6 c0             	movzbl %al,%eax
}
  801fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5f                   	pop    %edi
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <devpipe_write>:
{
  801fac:	f3 0f 1e fb          	endbr32 
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	57                   	push   %edi
  801fb4:	56                   	push   %esi
  801fb5:	53                   	push   %ebx
  801fb6:	83 ec 28             	sub    $0x28,%esp
  801fb9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fbc:	56                   	push   %esi
  801fbd:	e8 0c f2 ff ff       	call   8011ce <fd2data>
  801fc2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	bf 00 00 00 00       	mov    $0x0,%edi
  801fcc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fcf:	74 4f                	je     802020 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fd1:	8b 43 04             	mov    0x4(%ebx),%eax
  801fd4:	8b 0b                	mov    (%ebx),%ecx
  801fd6:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd9:	39 d0                	cmp    %edx,%eax
  801fdb:	72 14                	jb     801ff1 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801fdd:	89 da                	mov    %ebx,%edx
  801fdf:	89 f0                	mov    %esi,%eax
  801fe1:	e8 61 ff ff ff       	call   801f47 <_pipeisclosed>
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	75 3b                	jne    802025 <devpipe_write+0x79>
			sys_yield();
  801fea:	e8 84 ed ff ff       	call   800d73 <sys_yield>
  801fef:	eb e0                	jmp    801fd1 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ff1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ff4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ff8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ffb:	89 c2                	mov    %eax,%edx
  801ffd:	c1 fa 1f             	sar    $0x1f,%edx
  802000:	89 d1                	mov    %edx,%ecx
  802002:	c1 e9 1b             	shr    $0x1b,%ecx
  802005:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802008:	83 e2 1f             	and    $0x1f,%edx
  80200b:	29 ca                	sub    %ecx,%edx
  80200d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802011:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802015:	83 c0 01             	add    $0x1,%eax
  802018:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80201b:	83 c7 01             	add    $0x1,%edi
  80201e:	eb ac                	jmp    801fcc <devpipe_write+0x20>
	return i;
  802020:	8b 45 10             	mov    0x10(%ebp),%eax
  802023:	eb 05                	jmp    80202a <devpipe_write+0x7e>
				return 0;
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80202a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    

00802032 <devpipe_read>:
{
  802032:	f3 0f 1e fb          	endbr32 
  802036:	55                   	push   %ebp
  802037:	89 e5                	mov    %esp,%ebp
  802039:	57                   	push   %edi
  80203a:	56                   	push   %esi
  80203b:	53                   	push   %ebx
  80203c:	83 ec 18             	sub    $0x18,%esp
  80203f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802042:	57                   	push   %edi
  802043:	e8 86 f1 ff ff       	call   8011ce <fd2data>
  802048:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	be 00 00 00 00       	mov    $0x0,%esi
  802052:	3b 75 10             	cmp    0x10(%ebp),%esi
  802055:	75 14                	jne    80206b <devpipe_read+0x39>
	return i;
  802057:	8b 45 10             	mov    0x10(%ebp),%eax
  80205a:	eb 02                	jmp    80205e <devpipe_read+0x2c>
				return i;
  80205c:	89 f0                	mov    %esi,%eax
}
  80205e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
			sys_yield();
  802066:	e8 08 ed ff ff       	call   800d73 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80206b:	8b 03                	mov    (%ebx),%eax
  80206d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802070:	75 18                	jne    80208a <devpipe_read+0x58>
			if (i > 0)
  802072:	85 f6                	test   %esi,%esi
  802074:	75 e6                	jne    80205c <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802076:	89 da                	mov    %ebx,%edx
  802078:	89 f8                	mov    %edi,%eax
  80207a:	e8 c8 fe ff ff       	call   801f47 <_pipeisclosed>
  80207f:	85 c0                	test   %eax,%eax
  802081:	74 e3                	je     802066 <devpipe_read+0x34>
				return 0;
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
  802088:	eb d4                	jmp    80205e <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80208a:	99                   	cltd   
  80208b:	c1 ea 1b             	shr    $0x1b,%edx
  80208e:	01 d0                	add    %edx,%eax
  802090:	83 e0 1f             	and    $0x1f,%eax
  802093:	29 d0                	sub    %edx,%eax
  802095:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80209a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020a0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020a3:	83 c6 01             	add    $0x1,%esi
  8020a6:	eb aa                	jmp    802052 <devpipe_read+0x20>

008020a8 <pipe>:
{
  8020a8:	f3 0f 1e fb          	endbr32 
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b7:	50                   	push   %eax
  8020b8:	e8 2c f1 ff ff       	call   8011e9 <fd_alloc>
  8020bd:	89 c3                	mov    %eax,%ebx
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	0f 88 23 01 00 00    	js     8021ed <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ca:	83 ec 04             	sub    $0x4,%esp
  8020cd:	68 07 04 00 00       	push   $0x407
  8020d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d5:	6a 00                	push   $0x0
  8020d7:	e8 ba ec ff ff       	call   800d96 <sys_page_alloc>
  8020dc:	89 c3                	mov    %eax,%ebx
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	0f 88 04 01 00 00    	js     8021ed <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8020e9:	83 ec 0c             	sub    $0xc,%esp
  8020ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020ef:	50                   	push   %eax
  8020f0:	e8 f4 f0 ff ff       	call   8011e9 <fd_alloc>
  8020f5:	89 c3                	mov    %eax,%ebx
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	0f 88 db 00 00 00    	js     8021dd <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802102:	83 ec 04             	sub    $0x4,%esp
  802105:	68 07 04 00 00       	push   $0x407
  80210a:	ff 75 f0             	pushl  -0x10(%ebp)
  80210d:	6a 00                	push   $0x0
  80210f:	e8 82 ec ff ff       	call   800d96 <sys_page_alloc>
  802114:	89 c3                	mov    %eax,%ebx
  802116:	83 c4 10             	add    $0x10,%esp
  802119:	85 c0                	test   %eax,%eax
  80211b:	0f 88 bc 00 00 00    	js     8021dd <pipe+0x135>
	va = fd2data(fd0);
  802121:	83 ec 0c             	sub    $0xc,%esp
  802124:	ff 75 f4             	pushl  -0xc(%ebp)
  802127:	e8 a2 f0 ff ff       	call   8011ce <fd2data>
  80212c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212e:	83 c4 0c             	add    $0xc,%esp
  802131:	68 07 04 00 00       	push   $0x407
  802136:	50                   	push   %eax
  802137:	6a 00                	push   $0x0
  802139:	e8 58 ec ff ff       	call   800d96 <sys_page_alloc>
  80213e:	89 c3                	mov    %eax,%ebx
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	85 c0                	test   %eax,%eax
  802145:	0f 88 82 00 00 00    	js     8021cd <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214b:	83 ec 0c             	sub    $0xc,%esp
  80214e:	ff 75 f0             	pushl  -0x10(%ebp)
  802151:	e8 78 f0 ff ff       	call   8011ce <fd2data>
  802156:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80215d:	50                   	push   %eax
  80215e:	6a 00                	push   $0x0
  802160:	56                   	push   %esi
  802161:	6a 00                	push   $0x0
  802163:	e8 54 ec ff ff       	call   800dbc <sys_page_map>
  802168:	89 c3                	mov    %eax,%ebx
  80216a:	83 c4 20             	add    $0x20,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 4e                	js     8021bf <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802171:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802176:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802179:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80217b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80217e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802185:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802188:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80218a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80218d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802194:	83 ec 0c             	sub    $0xc,%esp
  802197:	ff 75 f4             	pushl  -0xc(%ebp)
  80219a:	e8 1b f0 ff ff       	call   8011ba <fd2num>
  80219f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021a2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021a4:	83 c4 04             	add    $0x4,%esp
  8021a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8021aa:	e8 0b f0 ff ff       	call   8011ba <fd2num>
  8021af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021b2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021b5:	83 c4 10             	add    $0x10,%esp
  8021b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021bd:	eb 2e                	jmp    8021ed <pipe+0x145>
	sys_page_unmap(0, va);
  8021bf:	83 ec 08             	sub    $0x8,%esp
  8021c2:	56                   	push   %esi
  8021c3:	6a 00                	push   $0x0
  8021c5:	e8 17 ec ff ff       	call   800de1 <sys_page_unmap>
  8021ca:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021cd:	83 ec 08             	sub    $0x8,%esp
  8021d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d3:	6a 00                	push   $0x0
  8021d5:	e8 07 ec ff ff       	call   800de1 <sys_page_unmap>
  8021da:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8021dd:	83 ec 08             	sub    $0x8,%esp
  8021e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e3:	6a 00                	push   $0x0
  8021e5:	e8 f7 eb ff ff       	call   800de1 <sys_page_unmap>
  8021ea:	83 c4 10             	add    $0x10,%esp
}
  8021ed:	89 d8                	mov    %ebx,%eax
  8021ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f2:	5b                   	pop    %ebx
  8021f3:	5e                   	pop    %esi
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    

008021f6 <pipeisclosed>:
{
  8021f6:	f3 0f 1e fb          	endbr32 
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802200:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802203:	50                   	push   %eax
  802204:	ff 75 08             	pushl  0x8(%ebp)
  802207:	e8 33 f0 ff ff       	call   80123f <fd_lookup>
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	85 c0                	test   %eax,%eax
  802211:	78 18                	js     80222b <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802213:	83 ec 0c             	sub    $0xc,%esp
  802216:	ff 75 f4             	pushl  -0xc(%ebp)
  802219:	e8 b0 ef ff ff       	call   8011ce <fd2data>
  80221e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802220:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802223:	e8 1f fd ff ff       	call   801f47 <_pipeisclosed>
  802228:	83 c4 10             	add    $0x10,%esp
}
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    

0080222d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80222d:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
  802236:	c3                   	ret    

00802237 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802237:	f3 0f 1e fb          	endbr32 
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802241:	68 77 2e 80 00       	push   $0x802e77
  802246:	ff 75 0c             	pushl  0xc(%ebp)
  802249:	e8 df e6 ff ff       	call   80092d <strcpy>
	return 0;
}
  80224e:	b8 00 00 00 00       	mov    $0x0,%eax
  802253:	c9                   	leave  
  802254:	c3                   	ret    

00802255 <devcons_write>:
{
  802255:	f3 0f 1e fb          	endbr32 
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	57                   	push   %edi
  80225d:	56                   	push   %esi
  80225e:	53                   	push   %ebx
  80225f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802265:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80226a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802270:	3b 75 10             	cmp    0x10(%ebp),%esi
  802273:	73 31                	jae    8022a6 <devcons_write+0x51>
		m = n - tot;
  802275:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802278:	29 f3                	sub    %esi,%ebx
  80227a:	83 fb 7f             	cmp    $0x7f,%ebx
  80227d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802282:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802285:	83 ec 04             	sub    $0x4,%esp
  802288:	53                   	push   %ebx
  802289:	89 f0                	mov    %esi,%eax
  80228b:	03 45 0c             	add    0xc(%ebp),%eax
  80228e:	50                   	push   %eax
  80228f:	57                   	push   %edi
  802290:	e8 96 e8 ff ff       	call   800b2b <memmove>
		sys_cputs(buf, m);
  802295:	83 c4 08             	add    $0x8,%esp
  802298:	53                   	push   %ebx
  802299:	57                   	push   %edi
  80229a:	e8 48 ea ff ff       	call   800ce7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80229f:	01 de                	add    %ebx,%esi
  8022a1:	83 c4 10             	add    $0x10,%esp
  8022a4:	eb ca                	jmp    802270 <devcons_write+0x1b>
}
  8022a6:	89 f0                	mov    %esi,%eax
  8022a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ab:	5b                   	pop    %ebx
  8022ac:	5e                   	pop    %esi
  8022ad:	5f                   	pop    %edi
  8022ae:	5d                   	pop    %ebp
  8022af:	c3                   	ret    

008022b0 <devcons_read>:
{
  8022b0:	f3 0f 1e fb          	endbr32 
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	83 ec 08             	sub    $0x8,%esp
  8022ba:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8022bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022c3:	74 21                	je     8022e6 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8022c5:	e8 3f ea ff ff       	call   800d09 <sys_cgetc>
  8022ca:	85 c0                	test   %eax,%eax
  8022cc:	75 07                	jne    8022d5 <devcons_read+0x25>
		sys_yield();
  8022ce:	e8 a0 ea ff ff       	call   800d73 <sys_yield>
  8022d3:	eb f0                	jmp    8022c5 <devcons_read+0x15>
	if (c < 0)
  8022d5:	78 0f                	js     8022e6 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8022d7:	83 f8 04             	cmp    $0x4,%eax
  8022da:	74 0c                	je     8022e8 <devcons_read+0x38>
	*(char*)vbuf = c;
  8022dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022df:	88 02                	mov    %al,(%edx)
	return 1;
  8022e1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8022e6:	c9                   	leave  
  8022e7:	c3                   	ret    
		return 0;
  8022e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ed:	eb f7                	jmp    8022e6 <devcons_read+0x36>

008022ef <cputchar>:
{
  8022ef:	f3 0f 1e fb          	endbr32 
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fc:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8022ff:	6a 01                	push   $0x1
  802301:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802304:	50                   	push   %eax
  802305:	e8 dd e9 ff ff       	call   800ce7 <sys_cputs>
}
  80230a:	83 c4 10             	add    $0x10,%esp
  80230d:	c9                   	leave  
  80230e:	c3                   	ret    

0080230f <getchar>:
{
  80230f:	f3 0f 1e fb          	endbr32 
  802313:	55                   	push   %ebp
  802314:	89 e5                	mov    %esp,%ebp
  802316:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802319:	6a 01                	push   $0x1
  80231b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80231e:	50                   	push   %eax
  80231f:	6a 00                	push   $0x0
  802321:	e8 a1 f1 ff ff       	call   8014c7 <read>
	if (r < 0)
  802326:	83 c4 10             	add    $0x10,%esp
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 06                	js     802333 <getchar+0x24>
	if (r < 1)
  80232d:	74 06                	je     802335 <getchar+0x26>
	return c;
  80232f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    
		return -E_EOF;
  802335:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80233a:	eb f7                	jmp    802333 <getchar+0x24>

0080233c <iscons>:
{
  80233c:	f3 0f 1e fb          	endbr32 
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802349:	50                   	push   %eax
  80234a:	ff 75 08             	pushl  0x8(%ebp)
  80234d:	e8 ed ee ff ff       	call   80123f <fd_lookup>
  802352:	83 c4 10             	add    $0x10,%esp
  802355:	85 c0                	test   %eax,%eax
  802357:	78 11                	js     80236a <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802359:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235c:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802362:	39 10                	cmp    %edx,(%eax)
  802364:	0f 94 c0             	sete   %al
  802367:	0f b6 c0             	movzbl %al,%eax
}
  80236a:	c9                   	leave  
  80236b:	c3                   	ret    

0080236c <opencons>:
{
  80236c:	f3 0f 1e fb          	endbr32 
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802376:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802379:	50                   	push   %eax
  80237a:	e8 6a ee ff ff       	call   8011e9 <fd_alloc>
  80237f:	83 c4 10             	add    $0x10,%esp
  802382:	85 c0                	test   %eax,%eax
  802384:	78 3a                	js     8023c0 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802386:	83 ec 04             	sub    $0x4,%esp
  802389:	68 07 04 00 00       	push   $0x407
  80238e:	ff 75 f4             	pushl  -0xc(%ebp)
  802391:	6a 00                	push   $0x0
  802393:	e8 fe e9 ff ff       	call   800d96 <sys_page_alloc>
  802398:	83 c4 10             	add    $0x10,%esp
  80239b:	85 c0                	test   %eax,%eax
  80239d:	78 21                	js     8023c0 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80239f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a2:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023a8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023b4:	83 ec 0c             	sub    $0xc,%esp
  8023b7:	50                   	push   %eax
  8023b8:	e8 fd ed ff ff       	call   8011ba <fd2num>
  8023bd:	83 c4 10             	add    $0x10,%esp
}
  8023c0:	c9                   	leave  
  8023c1:	c3                   	ret    

008023c2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023c2:	f3 0f 1e fb          	endbr32 
  8023c6:	55                   	push   %ebp
  8023c7:	89 e5                	mov    %esp,%ebp
  8023c9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023cc:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023d3:	74 0a                	je     8023df <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d8:	a3 00 70 80 00       	mov    %eax,0x807000

}
  8023dd:	c9                   	leave  
  8023de:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8023df:	83 ec 04             	sub    $0x4,%esp
  8023e2:	6a 07                	push   $0x7
  8023e4:	68 00 f0 bf ee       	push   $0xeebff000
  8023e9:	6a 00                	push   $0x0
  8023eb:	e8 a6 e9 ff ff       	call   800d96 <sys_page_alloc>
  8023f0:	83 c4 10             	add    $0x10,%esp
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	78 2a                	js     802421 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  8023f7:	83 ec 08             	sub    $0x8,%esp
  8023fa:	68 35 24 80 00       	push   $0x802435
  8023ff:	6a 00                	push   $0x0
  802401:	e8 4a ea ff ff       	call   800e50 <sys_env_set_pgfault_upcall>
  802406:	83 c4 10             	add    $0x10,%esp
  802409:	85 c0                	test   %eax,%eax
  80240b:	79 c8                	jns    8023d5 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  80240d:	83 ec 04             	sub    $0x4,%esp
  802410:	68 b0 2e 80 00       	push   $0x802eb0
  802415:	6a 2c                	push   $0x2c
  802417:	68 e6 2e 80 00       	push   $0x802ee6
  80241c:	e8 1b de ff ff       	call   80023c <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802421:	83 ec 04             	sub    $0x4,%esp
  802424:	68 84 2e 80 00       	push   $0x802e84
  802429:	6a 22                	push   $0x22
  80242b:	68 e6 2e 80 00       	push   $0x802ee6
  802430:	e8 07 de ff ff       	call   80023c <_panic>

00802435 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802435:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802436:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  80243b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80243d:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802440:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802444:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802449:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  80244d:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  80244f:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802452:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802453:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802456:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802457:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  802458:	c3                   	ret    

00802459 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802459:	f3 0f 1e fb          	endbr32 
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	56                   	push   %esi
  802461:	53                   	push   %ebx
  802462:	8b 75 08             	mov    0x8(%ebp),%esi
  802465:	8b 45 0c             	mov    0xc(%ebp),%eax
  802468:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80246b:	85 c0                	test   %eax,%eax
  80246d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802472:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802475:	83 ec 0c             	sub    $0xc,%esp
  802478:	50                   	push   %eax
  802479:	e8 1e ea ff ff       	call   800e9c <sys_ipc_recv>
  80247e:	83 c4 10             	add    $0x10,%esp
  802481:	85 c0                	test   %eax,%eax
  802483:	75 2b                	jne    8024b0 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802485:	85 f6                	test   %esi,%esi
  802487:	74 0a                	je     802493 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802489:	a1 08 40 80 00       	mov    0x804008,%eax
  80248e:	8b 40 74             	mov    0x74(%eax),%eax
  802491:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802493:	85 db                	test   %ebx,%ebx
  802495:	74 0a                	je     8024a1 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802497:	a1 08 40 80 00       	mov    0x804008,%eax
  80249c:	8b 40 78             	mov    0x78(%eax),%eax
  80249f:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8024a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8024a6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024ac:	5b                   	pop    %ebx
  8024ad:	5e                   	pop    %esi
  8024ae:	5d                   	pop    %ebp
  8024af:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8024b0:	85 f6                	test   %esi,%esi
  8024b2:	74 06                	je     8024ba <ipc_recv+0x61>
  8024b4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8024ba:	85 db                	test   %ebx,%ebx
  8024bc:	74 eb                	je     8024a9 <ipc_recv+0x50>
  8024be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024c4:	eb e3                	jmp    8024a9 <ipc_recv+0x50>

008024c6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024c6:	f3 0f 1e fb          	endbr32 
  8024ca:	55                   	push   %ebp
  8024cb:	89 e5                	mov    %esp,%ebp
  8024cd:	57                   	push   %edi
  8024ce:	56                   	push   %esi
  8024cf:	53                   	push   %ebx
  8024d0:	83 ec 0c             	sub    $0xc,%esp
  8024d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8024dc:	85 db                	test   %ebx,%ebx
  8024de:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024e3:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8024e6:	ff 75 14             	pushl  0x14(%ebp)
  8024e9:	53                   	push   %ebx
  8024ea:	56                   	push   %esi
  8024eb:	57                   	push   %edi
  8024ec:	e8 84 e9 ff ff       	call   800e75 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8024f1:	83 c4 10             	add    $0x10,%esp
  8024f4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024f7:	75 07                	jne    802500 <ipc_send+0x3a>
			sys_yield();
  8024f9:	e8 75 e8 ff ff       	call   800d73 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8024fe:	eb e6                	jmp    8024e6 <ipc_send+0x20>
		}
		else if (ret == 0)
  802500:	85 c0                	test   %eax,%eax
  802502:	75 08                	jne    80250c <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802504:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802507:	5b                   	pop    %ebx
  802508:	5e                   	pop    %esi
  802509:	5f                   	pop    %edi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80250c:	50                   	push   %eax
  80250d:	68 f4 2e 80 00       	push   $0x802ef4
  802512:	6a 48                	push   $0x48
  802514:	68 02 2f 80 00       	push   $0x802f02
  802519:	e8 1e dd ff ff       	call   80023c <_panic>

0080251e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80251e:	f3 0f 1e fb          	endbr32 
  802522:	55                   	push   %ebp
  802523:	89 e5                	mov    %esp,%ebp
  802525:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802528:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80252d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802530:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802536:	8b 52 50             	mov    0x50(%edx),%edx
  802539:	39 ca                	cmp    %ecx,%edx
  80253b:	74 11                	je     80254e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80253d:	83 c0 01             	add    $0x1,%eax
  802540:	3d 00 04 00 00       	cmp    $0x400,%eax
  802545:	75 e6                	jne    80252d <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802547:	b8 00 00 00 00       	mov    $0x0,%eax
  80254c:	eb 0b                	jmp    802559 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80254e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802551:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802556:	8b 40 48             	mov    0x48(%eax),%eax
}
  802559:	5d                   	pop    %ebp
  80255a:	c3                   	ret    

0080255b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80255b:	f3 0f 1e fb          	endbr32 
  80255f:	55                   	push   %ebp
  802560:	89 e5                	mov    %esp,%ebp
  802562:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802565:	89 c2                	mov    %eax,%edx
  802567:	c1 ea 16             	shr    $0x16,%edx
  80256a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802571:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802576:	f6 c1 01             	test   $0x1,%cl
  802579:	74 1c                	je     802597 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80257b:	c1 e8 0c             	shr    $0xc,%eax
  80257e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802585:	a8 01                	test   $0x1,%al
  802587:	74 0e                	je     802597 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802589:	c1 e8 0c             	shr    $0xc,%eax
  80258c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802593:	ef 
  802594:	0f b7 d2             	movzwl %dx,%edx
}
  802597:	89 d0                	mov    %edx,%eax
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    
  80259b:	66 90                	xchg   %ax,%ax
  80259d:	66 90                	xchg   %ax,%ax
  80259f:	90                   	nop

008025a0 <__udivdi3>:
  8025a0:	f3 0f 1e fb          	endbr32 
  8025a4:	55                   	push   %ebp
  8025a5:	57                   	push   %edi
  8025a6:	56                   	push   %esi
  8025a7:	53                   	push   %ebx
  8025a8:	83 ec 1c             	sub    $0x1c,%esp
  8025ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8025b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8025bb:	85 d2                	test   %edx,%edx
  8025bd:	75 19                	jne    8025d8 <__udivdi3+0x38>
  8025bf:	39 f3                	cmp    %esi,%ebx
  8025c1:	76 4d                	jbe    802610 <__udivdi3+0x70>
  8025c3:	31 ff                	xor    %edi,%edi
  8025c5:	89 e8                	mov    %ebp,%eax
  8025c7:	89 f2                	mov    %esi,%edx
  8025c9:	f7 f3                	div    %ebx
  8025cb:	89 fa                	mov    %edi,%edx
  8025cd:	83 c4 1c             	add    $0x1c,%esp
  8025d0:	5b                   	pop    %ebx
  8025d1:	5e                   	pop    %esi
  8025d2:	5f                   	pop    %edi
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    
  8025d5:	8d 76 00             	lea    0x0(%esi),%esi
  8025d8:	39 f2                	cmp    %esi,%edx
  8025da:	76 14                	jbe    8025f0 <__udivdi3+0x50>
  8025dc:	31 ff                	xor    %edi,%edi
  8025de:	31 c0                	xor    %eax,%eax
  8025e0:	89 fa                	mov    %edi,%edx
  8025e2:	83 c4 1c             	add    $0x1c,%esp
  8025e5:	5b                   	pop    %ebx
  8025e6:	5e                   	pop    %esi
  8025e7:	5f                   	pop    %edi
  8025e8:	5d                   	pop    %ebp
  8025e9:	c3                   	ret    
  8025ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f0:	0f bd fa             	bsr    %edx,%edi
  8025f3:	83 f7 1f             	xor    $0x1f,%edi
  8025f6:	75 48                	jne    802640 <__udivdi3+0xa0>
  8025f8:	39 f2                	cmp    %esi,%edx
  8025fa:	72 06                	jb     802602 <__udivdi3+0x62>
  8025fc:	31 c0                	xor    %eax,%eax
  8025fe:	39 eb                	cmp    %ebp,%ebx
  802600:	77 de                	ja     8025e0 <__udivdi3+0x40>
  802602:	b8 01 00 00 00       	mov    $0x1,%eax
  802607:	eb d7                	jmp    8025e0 <__udivdi3+0x40>
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	89 d9                	mov    %ebx,%ecx
  802612:	85 db                	test   %ebx,%ebx
  802614:	75 0b                	jne    802621 <__udivdi3+0x81>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f3                	div    %ebx
  80261f:	89 c1                	mov    %eax,%ecx
  802621:	31 d2                	xor    %edx,%edx
  802623:	89 f0                	mov    %esi,%eax
  802625:	f7 f1                	div    %ecx
  802627:	89 c6                	mov    %eax,%esi
  802629:	89 e8                	mov    %ebp,%eax
  80262b:	89 f7                	mov    %esi,%edi
  80262d:	f7 f1                	div    %ecx
  80262f:	89 fa                	mov    %edi,%edx
  802631:	83 c4 1c             	add    $0x1c,%esp
  802634:	5b                   	pop    %ebx
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	89 f9                	mov    %edi,%ecx
  802642:	b8 20 00 00 00       	mov    $0x20,%eax
  802647:	29 f8                	sub    %edi,%eax
  802649:	d3 e2                	shl    %cl,%edx
  80264b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80264f:	89 c1                	mov    %eax,%ecx
  802651:	89 da                	mov    %ebx,%edx
  802653:	d3 ea                	shr    %cl,%edx
  802655:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802659:	09 d1                	or     %edx,%ecx
  80265b:	89 f2                	mov    %esi,%edx
  80265d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802661:	89 f9                	mov    %edi,%ecx
  802663:	d3 e3                	shl    %cl,%ebx
  802665:	89 c1                	mov    %eax,%ecx
  802667:	d3 ea                	shr    %cl,%edx
  802669:	89 f9                	mov    %edi,%ecx
  80266b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80266f:	89 eb                	mov    %ebp,%ebx
  802671:	d3 e6                	shl    %cl,%esi
  802673:	89 c1                	mov    %eax,%ecx
  802675:	d3 eb                	shr    %cl,%ebx
  802677:	09 de                	or     %ebx,%esi
  802679:	89 f0                	mov    %esi,%eax
  80267b:	f7 74 24 08          	divl   0x8(%esp)
  80267f:	89 d6                	mov    %edx,%esi
  802681:	89 c3                	mov    %eax,%ebx
  802683:	f7 64 24 0c          	mull   0xc(%esp)
  802687:	39 d6                	cmp    %edx,%esi
  802689:	72 15                	jb     8026a0 <__udivdi3+0x100>
  80268b:	89 f9                	mov    %edi,%ecx
  80268d:	d3 e5                	shl    %cl,%ebp
  80268f:	39 c5                	cmp    %eax,%ebp
  802691:	73 04                	jae    802697 <__udivdi3+0xf7>
  802693:	39 d6                	cmp    %edx,%esi
  802695:	74 09                	je     8026a0 <__udivdi3+0x100>
  802697:	89 d8                	mov    %ebx,%eax
  802699:	31 ff                	xor    %edi,%edi
  80269b:	e9 40 ff ff ff       	jmp    8025e0 <__udivdi3+0x40>
  8026a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8026a3:	31 ff                	xor    %edi,%edi
  8026a5:	e9 36 ff ff ff       	jmp    8025e0 <__udivdi3+0x40>
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__umoddi3>:
  8026b0:	f3 0f 1e fb          	endbr32 
  8026b4:	55                   	push   %ebp
  8026b5:	57                   	push   %edi
  8026b6:	56                   	push   %esi
  8026b7:	53                   	push   %ebx
  8026b8:	83 ec 1c             	sub    $0x1c,%esp
  8026bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8026c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8026c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026cb:	85 c0                	test   %eax,%eax
  8026cd:	75 19                	jne    8026e8 <__umoddi3+0x38>
  8026cf:	39 df                	cmp    %ebx,%edi
  8026d1:	76 5d                	jbe    802730 <__umoddi3+0x80>
  8026d3:	89 f0                	mov    %esi,%eax
  8026d5:	89 da                	mov    %ebx,%edx
  8026d7:	f7 f7                	div    %edi
  8026d9:	89 d0                	mov    %edx,%eax
  8026db:	31 d2                	xor    %edx,%edx
  8026dd:	83 c4 1c             	add    $0x1c,%esp
  8026e0:	5b                   	pop    %ebx
  8026e1:	5e                   	pop    %esi
  8026e2:	5f                   	pop    %edi
  8026e3:	5d                   	pop    %ebp
  8026e4:	c3                   	ret    
  8026e5:	8d 76 00             	lea    0x0(%esi),%esi
  8026e8:	89 f2                	mov    %esi,%edx
  8026ea:	39 d8                	cmp    %ebx,%eax
  8026ec:	76 12                	jbe    802700 <__umoddi3+0x50>
  8026ee:	89 f0                	mov    %esi,%eax
  8026f0:	89 da                	mov    %ebx,%edx
  8026f2:	83 c4 1c             	add    $0x1c,%esp
  8026f5:	5b                   	pop    %ebx
  8026f6:	5e                   	pop    %esi
  8026f7:	5f                   	pop    %edi
  8026f8:	5d                   	pop    %ebp
  8026f9:	c3                   	ret    
  8026fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802700:	0f bd e8             	bsr    %eax,%ebp
  802703:	83 f5 1f             	xor    $0x1f,%ebp
  802706:	75 50                	jne    802758 <__umoddi3+0xa8>
  802708:	39 d8                	cmp    %ebx,%eax
  80270a:	0f 82 e0 00 00 00    	jb     8027f0 <__umoddi3+0x140>
  802710:	89 d9                	mov    %ebx,%ecx
  802712:	39 f7                	cmp    %esi,%edi
  802714:	0f 86 d6 00 00 00    	jbe    8027f0 <__umoddi3+0x140>
  80271a:	89 d0                	mov    %edx,%eax
  80271c:	89 ca                	mov    %ecx,%edx
  80271e:	83 c4 1c             	add    $0x1c,%esp
  802721:	5b                   	pop    %ebx
  802722:	5e                   	pop    %esi
  802723:	5f                   	pop    %edi
  802724:	5d                   	pop    %ebp
  802725:	c3                   	ret    
  802726:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80272d:	8d 76 00             	lea    0x0(%esi),%esi
  802730:	89 fd                	mov    %edi,%ebp
  802732:	85 ff                	test   %edi,%edi
  802734:	75 0b                	jne    802741 <__umoddi3+0x91>
  802736:	b8 01 00 00 00       	mov    $0x1,%eax
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	f7 f7                	div    %edi
  80273f:	89 c5                	mov    %eax,%ebp
  802741:	89 d8                	mov    %ebx,%eax
  802743:	31 d2                	xor    %edx,%edx
  802745:	f7 f5                	div    %ebp
  802747:	89 f0                	mov    %esi,%eax
  802749:	f7 f5                	div    %ebp
  80274b:	89 d0                	mov    %edx,%eax
  80274d:	31 d2                	xor    %edx,%edx
  80274f:	eb 8c                	jmp    8026dd <__umoddi3+0x2d>
  802751:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802758:	89 e9                	mov    %ebp,%ecx
  80275a:	ba 20 00 00 00       	mov    $0x20,%edx
  80275f:	29 ea                	sub    %ebp,%edx
  802761:	d3 e0                	shl    %cl,%eax
  802763:	89 44 24 08          	mov    %eax,0x8(%esp)
  802767:	89 d1                	mov    %edx,%ecx
  802769:	89 f8                	mov    %edi,%eax
  80276b:	d3 e8                	shr    %cl,%eax
  80276d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802771:	89 54 24 04          	mov    %edx,0x4(%esp)
  802775:	8b 54 24 04          	mov    0x4(%esp),%edx
  802779:	09 c1                	or     %eax,%ecx
  80277b:	89 d8                	mov    %ebx,%eax
  80277d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802781:	89 e9                	mov    %ebp,%ecx
  802783:	d3 e7                	shl    %cl,%edi
  802785:	89 d1                	mov    %edx,%ecx
  802787:	d3 e8                	shr    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80278f:	d3 e3                	shl    %cl,%ebx
  802791:	89 c7                	mov    %eax,%edi
  802793:	89 d1                	mov    %edx,%ecx
  802795:	89 f0                	mov    %esi,%eax
  802797:	d3 e8                	shr    %cl,%eax
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	89 fa                	mov    %edi,%edx
  80279d:	d3 e6                	shl    %cl,%esi
  80279f:	09 d8                	or     %ebx,%eax
  8027a1:	f7 74 24 08          	divl   0x8(%esp)
  8027a5:	89 d1                	mov    %edx,%ecx
  8027a7:	89 f3                	mov    %esi,%ebx
  8027a9:	f7 64 24 0c          	mull   0xc(%esp)
  8027ad:	89 c6                	mov    %eax,%esi
  8027af:	89 d7                	mov    %edx,%edi
  8027b1:	39 d1                	cmp    %edx,%ecx
  8027b3:	72 06                	jb     8027bb <__umoddi3+0x10b>
  8027b5:	75 10                	jne    8027c7 <__umoddi3+0x117>
  8027b7:	39 c3                	cmp    %eax,%ebx
  8027b9:	73 0c                	jae    8027c7 <__umoddi3+0x117>
  8027bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8027bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8027c3:	89 d7                	mov    %edx,%edi
  8027c5:	89 c6                	mov    %eax,%esi
  8027c7:	89 ca                	mov    %ecx,%edx
  8027c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027ce:	29 f3                	sub    %esi,%ebx
  8027d0:	19 fa                	sbb    %edi,%edx
  8027d2:	89 d0                	mov    %edx,%eax
  8027d4:	d3 e0                	shl    %cl,%eax
  8027d6:	89 e9                	mov    %ebp,%ecx
  8027d8:	d3 eb                	shr    %cl,%ebx
  8027da:	d3 ea                	shr    %cl,%edx
  8027dc:	09 d8                	or     %ebx,%eax
  8027de:	83 c4 1c             	add    $0x1c,%esp
  8027e1:	5b                   	pop    %ebx
  8027e2:	5e                   	pop    %esi
  8027e3:	5f                   	pop    %edi
  8027e4:	5d                   	pop    %ebp
  8027e5:	c3                   	ret    
  8027e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027ed:	8d 76 00             	lea    0x0(%esi),%esi
  8027f0:	29 fe                	sub    %edi,%esi
  8027f2:	19 c3                	sbb    %eax,%ebx
  8027f4:	89 f2                	mov    %esi,%edx
  8027f6:	89 d9                	mov    %ebx,%ecx
  8027f8:	e9 1d ff ff ff       	jmp    80271a <__umoddi3+0x6a>
