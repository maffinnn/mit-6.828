
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 c1 01 00 00       	call   8001f2 <libmain>
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
  80003c:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003f:	68 20 28 80 00       	push   $0x802820
  800044:	e8 f8 02 00 00       	call   800341 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 b4 21 00 00       	call   802208 <pipe>
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	78 59                	js     8000b4 <umain+0x81>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  80005b:	e8 e7 0f 00 00       	call   801047 <fork>
  800060:	89 c6                	mov    %eax,%esi
  800062:	85 c0                	test   %eax,%eax
  800064:	78 60                	js     8000c6 <umain+0x93>
		panic("fork: %e", r);
	if (r == 0) {
  800066:	74 70                	je     8000d8 <umain+0xa5>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800068:	83 ec 08             	sub    $0x8,%esp
  80006b:	56                   	push   %esi
  80006c:	68 7a 28 80 00       	push   $0x80287a
  800071:	e8 cb 02 00 00       	call   800341 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800076:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  80007c:	83 c4 08             	add    $0x8,%esp
  80007f:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800082:	c1 f8 02             	sar    $0x2,%eax
  800085:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  80008b:	50                   	push   %eax
  80008c:	68 85 28 80 00       	push   $0x802885
  800091:	e8 ab 02 00 00       	call   800341 <cprintf>
	dup(p[0], 10);
  800096:	83 c4 08             	add    $0x8,%esp
  800099:	6a 0a                	push   $0xa
  80009b:	ff 75 f0             	pushl  -0x10(%ebp)
  80009e:	e8 54 14 00 00       	call   8014f7 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000af:	e9 92 00 00 00       	jmp    800146 <umain+0x113>
		panic("pipe: %e", r);
  8000b4:	50                   	push   %eax
  8000b5:	68 39 28 80 00       	push   $0x802839
  8000ba:	6a 0d                	push   $0xd
  8000bc:	68 42 28 80 00       	push   $0x802842
  8000c1:	e8 94 01 00 00       	call   80025a <_panic>
		panic("fork: %e", r);
  8000c6:	50                   	push   %eax
  8000c7:	68 56 28 80 00       	push   $0x802856
  8000cc:	6a 10                	push   $0x10
  8000ce:	68 42 28 80 00       	push   $0x802842
  8000d3:	e8 82 01 00 00       	call   80025a <_panic>
		close(p[1]);
  8000d8:	83 ec 0c             	sub    $0xc,%esp
  8000db:	ff 75 f4             	pushl  -0xc(%ebp)
  8000de:	e8 ba 13 00 00       	call   80149d <close>
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000eb:	eb 1f                	jmp    80010c <umain+0xd9>
				cprintf("RACE: pipe appears closed\n");
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	68 5f 28 80 00       	push   $0x80285f
  8000f5:	e8 47 02 00 00       	call   800341 <cprintf>
				exit();
  8000fa:	e8 3d 01 00 00       	call   80023c <exit>
  8000ff:	83 c4 10             	add    $0x10,%esp
			sys_yield();
  800102:	e8 8a 0c 00 00       	call   800d91 <sys_yield>
		for (i=0; i<max; i++) {
  800107:	83 eb 01             	sub    $0x1,%ebx
  80010a:	74 14                	je     800120 <umain+0xed>
			if(pipeisclosed(p[0])){
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	ff 75 f0             	pushl  -0x10(%ebp)
  800112:	e8 3f 22 00 00       	call   802356 <pipeisclosed>
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	85 c0                	test   %eax,%eax
  80011c:	74 e4                	je     800102 <umain+0xcf>
  80011e:	eb cd                	jmp    8000ed <umain+0xba>
		ipc_recv(0,0,0);
  800120:	83 ec 04             	sub    $0x4,%esp
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	e8 aa 10 00 00       	call   8011d8 <ipc_recv>
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	e9 32 ff ff ff       	jmp    800068 <umain+0x35>
		dup(p[0], 10);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	6a 0a                	push   $0xa
  80013b:	ff 75 f0             	pushl  -0x10(%ebp)
  80013e:	e8 b4 13 00 00       	call   8014f7 <dup>
  800143:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 43 54             	mov    0x54(%ebx),%eax
  800149:	83 f8 02             	cmp    $0x2,%eax
  80014c:	74 e8                	je     800136 <umain+0x103>

	cprintf("child done with loop\n");
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	68 90 28 80 00       	push   $0x802890
  800156:	e8 e6 01 00 00       	call   800341 <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	83 c4 04             	add    $0x4,%esp
  80015e:	ff 75 f0             	pushl  -0x10(%ebp)
  800161:	e8 f0 21 00 00       	call   802356 <pipeisclosed>
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	85 c0                	test   %eax,%eax
  80016b:	75 48                	jne    8001b5 <umain+0x182>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800173:	50                   	push   %eax
  800174:	ff 75 f0             	pushl  -0x10(%ebp)
  800177:	e8 e3 11 00 00       	call   80135f <fd_lookup>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	85 c0                	test   %eax,%eax
  800181:	78 46                	js     8001c9 <umain+0x196>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 ec             	pushl  -0x14(%ebp)
  800189:	e8 60 11 00 00       	call   8012ee <fd2data>
	if (pageref(va) != 3+1)
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 99 19 00 00       	call   801b2f <pageref>
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	83 f8 04             	cmp    $0x4,%eax
  80019c:	74 3d                	je     8001db <umain+0x1a8>
		cprintf("\nchild detected race\n");
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	68 be 28 80 00       	push   $0x8028be
  8001a6:	e8 96 01 00 00       	call   800341 <cprintf>
  8001ab:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b5:	83 ec 04             	sub    $0x4,%esp
  8001b8:	68 ec 28 80 00       	push   $0x8028ec
  8001bd:	6a 3a                	push   $0x3a
  8001bf:	68 42 28 80 00       	push   $0x802842
  8001c4:	e8 91 00 00 00       	call   80025a <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c9:	50                   	push   %eax
  8001ca:	68 a6 28 80 00       	push   $0x8028a6
  8001cf:	6a 3c                	push   $0x3c
  8001d1:	68 42 28 80 00       	push   $0x802842
  8001d6:	e8 7f 00 00 00       	call   80025a <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	68 c8 00 00 00       	push   $0xc8
  8001e3:	68 d4 28 80 00       	push   $0x8028d4
  8001e8:	e8 54 01 00 00       	call   800341 <cprintf>
  8001ed:	83 c4 10             	add    $0x10,%esp
}
  8001f0:	eb bc                	jmp    8001ae <umain+0x17b>

008001f2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f2:	f3 0f 1e fb          	endbr32 
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800201:	e8 68 0b 00 00       	call   800d6e <sys_getenvid>
  800206:	25 ff 03 00 00       	and    $0x3ff,%eax
  80020b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80020e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800213:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7e 07                	jle    800223 <libmain+0x31>
		binaryname = argv[0];
  80021c:	8b 06                	mov    (%esi),%eax
  80021e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	e8 06 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80022d:	e8 0a 00 00 00       	call   80023c <exit>
}
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800238:	5b                   	pop    %ebx
  800239:	5e                   	pop    %esi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023c:	f3 0f 1e fb          	endbr32 
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800246:	e8 83 12 00 00       	call   8014ce <close_all>
	sys_env_destroy(0);
  80024b:	83 ec 0c             	sub    $0xc,%esp
  80024e:	6a 00                	push   $0x0
  800250:	e8 f5 0a 00 00       	call   800d4a <sys_env_destroy>
}
  800255:	83 c4 10             	add    $0x10,%esp
  800258:	c9                   	leave  
  800259:	c3                   	ret    

0080025a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80025a:	f3 0f 1e fb          	endbr32 
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800263:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800266:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80026c:	e8 fd 0a 00 00       	call   800d6e <sys_getenvid>
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	ff 75 0c             	pushl  0xc(%ebp)
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	56                   	push   %esi
  80027b:	50                   	push   %eax
  80027c:	68 20 29 80 00       	push   $0x802920
  800281:	e8 bb 00 00 00       	call   800341 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	53                   	push   %ebx
  80028a:	ff 75 10             	pushl  0x10(%ebp)
  80028d:	e8 5a 00 00 00       	call   8002ec <vcprintf>
	cprintf("\n");
  800292:	c7 04 24 37 28 80 00 	movl   $0x802837,(%esp)
  800299:	e8 a3 00 00 00       	call   800341 <cprintf>
  80029e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a1:	cc                   	int3   
  8002a2:	eb fd                	jmp    8002a1 <_panic+0x47>

008002a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a4:	f3 0f 1e fb          	endbr32 
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	53                   	push   %ebx
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b2:	8b 13                	mov    (%ebx),%edx
  8002b4:	8d 42 01             	lea    0x1(%edx),%eax
  8002b7:	89 03                	mov    %eax,(%ebx)
  8002b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c5:	74 09                	je     8002d0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002c7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	68 ff 00 00 00       	push   $0xff
  8002d8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002db:	50                   	push   %eax
  8002dc:	e8 24 0a 00 00       	call   800d05 <sys_cputs>
		b->idx = 0;
  8002e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002e7:	83 c4 10             	add    $0x10,%esp
  8002ea:	eb db                	jmp    8002c7 <putch+0x23>

008002ec <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ec:	f3 0f 1e fb          	endbr32 
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800300:	00 00 00 
	b.cnt = 0;
  800303:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80030a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80030d:	ff 75 0c             	pushl  0xc(%ebp)
  800310:	ff 75 08             	pushl  0x8(%ebp)
  800313:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800319:	50                   	push   %eax
  80031a:	68 a4 02 80 00       	push   $0x8002a4
  80031f:	e8 20 01 00 00       	call   800444 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800324:	83 c4 08             	add    $0x8,%esp
  800327:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80032d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800333:	50                   	push   %eax
  800334:	e8 cc 09 00 00       	call   800d05 <sys_cputs>

	return b.cnt;
}
  800339:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80033f:	c9                   	leave  
  800340:	c3                   	ret    

00800341 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800341:	f3 0f 1e fb          	endbr32 
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80034e:	50                   	push   %eax
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	e8 95 ff ff ff       	call   8002ec <vcprintf>
	va_end(ap);

	return cnt;
}
  800357:	c9                   	leave  
  800358:	c3                   	ret    

00800359 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	57                   	push   %edi
  80035d:	56                   	push   %esi
  80035e:	53                   	push   %ebx
  80035f:	83 ec 1c             	sub    $0x1c,%esp
  800362:	89 c7                	mov    %eax,%edi
  800364:	89 d6                	mov    %edx,%esi
  800366:	8b 45 08             	mov    0x8(%ebp),%eax
  800369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036c:	89 d1                	mov    %edx,%ecx
  80036e:	89 c2                	mov    %eax,%edx
  800370:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800373:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800376:	8b 45 10             	mov    0x10(%ebp),%eax
  800379:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80037c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800386:	39 c2                	cmp    %eax,%edx
  800388:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80038b:	72 3e                	jb     8003cb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	ff 75 18             	pushl  0x18(%ebp)
  800393:	83 eb 01             	sub    $0x1,%ebx
  800396:	53                   	push   %ebx
  800397:	50                   	push   %eax
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039e:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a7:	e8 14 22 00 00       	call   8025c0 <__udivdi3>
  8003ac:	83 c4 18             	add    $0x18,%esp
  8003af:	52                   	push   %edx
  8003b0:	50                   	push   %eax
  8003b1:	89 f2                	mov    %esi,%edx
  8003b3:	89 f8                	mov    %edi,%eax
  8003b5:	e8 9f ff ff ff       	call   800359 <printnum>
  8003ba:	83 c4 20             	add    $0x20,%esp
  8003bd:	eb 13                	jmp    8003d2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	56                   	push   %esi
  8003c3:	ff 75 18             	pushl  0x18(%ebp)
  8003c6:	ff d7                	call   *%edi
  8003c8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003cb:	83 eb 01             	sub    $0x1,%ebx
  8003ce:	85 db                	test   %ebx,%ebx
  8003d0:	7f ed                	jg     8003bf <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	56                   	push   %esi
  8003d6:	83 ec 04             	sub    $0x4,%esp
  8003d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8003df:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e5:	e8 e6 22 00 00       	call   8026d0 <__umoddi3>
  8003ea:	83 c4 14             	add    $0x14,%esp
  8003ed:	0f be 80 43 29 80 00 	movsbl 0x802943(%eax),%eax
  8003f4:	50                   	push   %eax
  8003f5:	ff d7                	call   *%edi
}
  8003f7:	83 c4 10             	add    $0x10,%esp
  8003fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003fd:	5b                   	pop    %ebx
  8003fe:	5e                   	pop    %esi
  8003ff:	5f                   	pop    %edi
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800402:	f3 0f 1e fb          	endbr32 
  800406:	55                   	push   %ebp
  800407:	89 e5                	mov    %esp,%ebp
  800409:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800410:	8b 10                	mov    (%eax),%edx
  800412:	3b 50 04             	cmp    0x4(%eax),%edx
  800415:	73 0a                	jae    800421 <sprintputch+0x1f>
		*b->buf++ = ch;
  800417:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041a:	89 08                	mov    %ecx,(%eax)
  80041c:	8b 45 08             	mov    0x8(%ebp),%eax
  80041f:	88 02                	mov    %al,(%edx)
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <printfmt>:
{
  800423:	f3 0f 1e fb          	endbr32 
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80042d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800430:	50                   	push   %eax
  800431:	ff 75 10             	pushl  0x10(%ebp)
  800434:	ff 75 0c             	pushl  0xc(%ebp)
  800437:	ff 75 08             	pushl  0x8(%ebp)
  80043a:	e8 05 00 00 00       	call   800444 <vprintfmt>
}
  80043f:	83 c4 10             	add    $0x10,%esp
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <vprintfmt>:
{
  800444:	f3 0f 1e fb          	endbr32 
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 3c             	sub    $0x3c,%esp
  800451:	8b 75 08             	mov    0x8(%ebp),%esi
  800454:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800457:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045a:	e9 8e 03 00 00       	jmp    8007ed <vprintfmt+0x3a9>
		padc = ' ';
  80045f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800463:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80046a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800471:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800478:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8d 47 01             	lea    0x1(%edi),%eax
  800480:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800483:	0f b6 17             	movzbl (%edi),%edx
  800486:	8d 42 dd             	lea    -0x23(%edx),%eax
  800489:	3c 55                	cmp    $0x55,%al
  80048b:	0f 87 df 03 00 00    	ja     800870 <vprintfmt+0x42c>
  800491:	0f b6 c0             	movzbl %al,%eax
  800494:	3e ff 24 85 80 2a 80 	notrack jmp *0x802a80(,%eax,4)
  80049b:	00 
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80049f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004a3:	eb d8                	jmp    80047d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004ac:	eb cf                	jmp    80047d <vprintfmt+0x39>
  8004ae:	0f b6 d2             	movzbl %dl,%edx
  8004b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8004bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004bf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004c3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004c6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004c9:	83 f9 09             	cmp    $0x9,%ecx
  8004cc:	77 55                	ja     800523 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004ce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8004d1:	eb e9                	jmp    8004bc <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 40 04             	lea    0x4(%eax),%eax
  8004e1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004eb:	79 90                	jns    80047d <vprintfmt+0x39>
				width = precision, precision = -1;
  8004ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004fa:	eb 81                	jmp    80047d <vprintfmt+0x39>
  8004fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ff:	85 c0                	test   %eax,%eax
  800501:	ba 00 00 00 00       	mov    $0x0,%edx
  800506:	0f 49 d0             	cmovns %eax,%edx
  800509:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80050f:	e9 69 ff ff ff       	jmp    80047d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800517:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80051e:	e9 5a ff ff ff       	jmp    80047d <vprintfmt+0x39>
  800523:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	eb bc                	jmp    8004e7 <vprintfmt+0xa3>
			lflag++;
  80052b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800531:	e9 47 ff ff ff       	jmp    80047d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 78 04             	lea    0x4(%eax),%edi
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	ff 30                	pushl  (%eax)
  800542:	ff d6                	call   *%esi
			break;
  800544:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800547:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80054a:	e9 9b 02 00 00       	jmp    8007ea <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 78 04             	lea    0x4(%eax),%edi
  800555:	8b 00                	mov    (%eax),%eax
  800557:	99                   	cltd   
  800558:	31 d0                	xor    %edx,%eax
  80055a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055c:	83 f8 0f             	cmp    $0xf,%eax
  80055f:	7f 23                	jg     800584 <vprintfmt+0x140>
  800561:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  800568:	85 d2                	test   %edx,%edx
  80056a:	74 18                	je     800584 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80056c:	52                   	push   %edx
  80056d:	68 fd 2d 80 00       	push   $0x802dfd
  800572:	53                   	push   %ebx
  800573:	56                   	push   %esi
  800574:	e8 aa fe ff ff       	call   800423 <printfmt>
  800579:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80057c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80057f:	e9 66 02 00 00       	jmp    8007ea <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800584:	50                   	push   %eax
  800585:	68 5b 29 80 00       	push   $0x80295b
  80058a:	53                   	push   %ebx
  80058b:	56                   	push   %esi
  80058c:	e8 92 fe ff ff       	call   800423 <printfmt>
  800591:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800594:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800597:	e9 4e 02 00 00       	jmp    8007ea <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	83 c0 04             	add    $0x4,%eax
  8005a2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	b8 54 29 80 00       	mov    $0x802954,%eax
  8005b1:	0f 45 c2             	cmovne %edx,%eax
  8005b4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bb:	7e 06                	jle    8005c3 <vprintfmt+0x17f>
  8005bd:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005c1:	75 0d                	jne    8005d0 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005c6:	89 c7                	mov    %eax,%edi
  8005c8:	03 45 e0             	add    -0x20(%ebp),%eax
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ce:	eb 55                	jmp    800625 <vprintfmt+0x1e1>
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8005d6:	ff 75 cc             	pushl  -0x34(%ebp)
  8005d9:	e8 46 03 00 00       	call   800924 <strnlen>
  8005de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e1:	29 c2                	sub    %eax,%edx
  8005e3:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005eb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	7e 11                	jle    800607 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ff:	83 ef 01             	sub    $0x1,%edi
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb eb                	jmp    8005f2 <vprintfmt+0x1ae>
  800607:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80060a:	85 d2                	test   %edx,%edx
  80060c:	b8 00 00 00 00       	mov    $0x0,%eax
  800611:	0f 49 c2             	cmovns %edx,%eax
  800614:	29 c2                	sub    %eax,%edx
  800616:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800619:	eb a8                	jmp    8005c3 <vprintfmt+0x17f>
					putch(ch, putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	52                   	push   %edx
  800620:	ff d6                	call   *%esi
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800628:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	83 c7 01             	add    $0x1,%edi
  80062d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800631:	0f be d0             	movsbl %al,%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	74 4b                	je     800683 <vprintfmt+0x23f>
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	78 06                	js     800644 <vprintfmt+0x200>
  80063e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800642:	78 1e                	js     800662 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800644:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800648:	74 d1                	je     80061b <vprintfmt+0x1d7>
  80064a:	0f be c0             	movsbl %al,%eax
  80064d:	83 e8 20             	sub    $0x20,%eax
  800650:	83 f8 5e             	cmp    $0x5e,%eax
  800653:	76 c6                	jbe    80061b <vprintfmt+0x1d7>
					putch('?', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 3f                	push   $0x3f
  80065b:	ff d6                	call   *%esi
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb c3                	jmp    800625 <vprintfmt+0x1e1>
  800662:	89 cf                	mov    %ecx,%edi
  800664:	eb 0e                	jmp    800674 <vprintfmt+0x230>
				putch(' ', putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	6a 20                	push   $0x20
  80066c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80066e:	83 ef 01             	sub    $0x1,%edi
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	85 ff                	test   %edi,%edi
  800676:	7f ee                	jg     800666 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800678:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
  80067e:	e9 67 01 00 00       	jmp    8007ea <vprintfmt+0x3a6>
  800683:	89 cf                	mov    %ecx,%edi
  800685:	eb ed                	jmp    800674 <vprintfmt+0x230>
	if (lflag >= 2)
  800687:	83 f9 01             	cmp    $0x1,%ecx
  80068a:	7f 1b                	jg     8006a7 <vprintfmt+0x263>
	else if (lflag)
  80068c:	85 c9                	test   %ecx,%ecx
  80068e:	74 63                	je     8006f3 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 00                	mov    (%eax),%eax
  800695:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800698:	99                   	cltd   
  800699:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a5:	eb 17                	jmp    8006be <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 50 04             	mov    0x4(%eax),%edx
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 40 08             	lea    0x8(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006c4:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	0f 89 ff 00 00 00    	jns    8007d0 <vprintfmt+0x38c>
				putch('-', putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	6a 2d                	push   $0x2d
  8006d7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006dc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006df:	f7 da                	neg    %edx
  8006e1:	83 d1 00             	adc    $0x0,%ecx
  8006e4:	f7 d9                	neg    %ecx
  8006e6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ee:	e9 dd 00 00 00       	jmp    8007d0 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 00                	mov    (%eax),%eax
  8006f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fb:	99                   	cltd   
  8006fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
  800708:	eb b4                	jmp    8006be <vprintfmt+0x27a>
	if (lflag >= 2)
  80070a:	83 f9 01             	cmp    $0x1,%ecx
  80070d:	7f 1e                	jg     80072d <vprintfmt+0x2e9>
	else if (lflag)
  80070f:	85 c9                	test   %ecx,%ecx
  800711:	74 32                	je     800745 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071d:	8d 40 04             	lea    0x4(%eax),%eax
  800720:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800723:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800728:	e9 a3 00 00 00       	jmp    8007d0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8b 10                	mov    (%eax),%edx
  800732:	8b 48 04             	mov    0x4(%eax),%ecx
  800735:	8d 40 08             	lea    0x8(%eax),%eax
  800738:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800740:	e9 8b 00 00 00       	jmp    8007d0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800755:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80075a:	eb 74                	jmp    8007d0 <vprintfmt+0x38c>
	if (lflag >= 2)
  80075c:	83 f9 01             	cmp    $0x1,%ecx
  80075f:	7f 1b                	jg     80077c <vprintfmt+0x338>
	else if (lflag)
  800761:	85 c9                	test   %ecx,%ecx
  800763:	74 2c                	je     800791 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 10                	mov    (%eax),%edx
  80076a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800775:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80077a:	eb 54                	jmp    8007d0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8b 10                	mov    (%eax),%edx
  800781:	8b 48 04             	mov    0x4(%eax),%ecx
  800784:	8d 40 08             	lea    0x8(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80078a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80078f:	eb 3f                	jmp    8007d0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8b 10                	mov    (%eax),%edx
  800796:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007a1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8007a6:	eb 28                	jmp    8007d0 <vprintfmt+0x38c>
			putch('0', putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	53                   	push   %ebx
  8007ac:	6a 30                	push   $0x30
  8007ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b0:	83 c4 08             	add    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	6a 78                	push   $0x78
  8007b6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007c2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007c5:	8d 40 04             	lea    0x4(%eax),%eax
  8007c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007d0:	83 ec 0c             	sub    $0xc,%esp
  8007d3:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8007d7:	57                   	push   %edi
  8007d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007db:	50                   	push   %eax
  8007dc:	51                   	push   %ecx
  8007dd:	52                   	push   %edx
  8007de:	89 da                	mov    %ebx,%edx
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	e8 72 fb ff ff       	call   800359 <printnum>
			break;
  8007e7:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8007ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8007ed:	83 c7 01             	add    $0x1,%edi
  8007f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007f4:	83 f8 25             	cmp    $0x25,%eax
  8007f7:	0f 84 62 fc ff ff    	je     80045f <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	0f 84 8b 00 00 00    	je     800890 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	ff d6                	call   *%esi
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	eb dc                	jmp    8007ed <vprintfmt+0x3a9>
	if (lflag >= 2)
  800811:	83 f9 01             	cmp    $0x1,%ecx
  800814:	7f 1b                	jg     800831 <vprintfmt+0x3ed>
	else if (lflag)
  800816:	85 c9                	test   %ecx,%ecx
  800818:	74 2c                	je     800846 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8b 10                	mov    (%eax),%edx
  80081f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80082f:	eb 9f                	jmp    8007d0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8b 10                	mov    (%eax),%edx
  800836:	8b 48 04             	mov    0x4(%eax),%ecx
  800839:	8d 40 08             	lea    0x8(%eax),%eax
  80083c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80083f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800844:	eb 8a                	jmp    8007d0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800856:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80085b:	e9 70 ff ff ff       	jmp    8007d0 <vprintfmt+0x38c>
			putch(ch, putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 25                	push   $0x25
  800866:	ff d6                	call   *%esi
			break;
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	e9 7a ff ff ff       	jmp    8007ea <vprintfmt+0x3a6>
			putch('%', putdat);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 25                	push   $0x25
  800876:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	89 f8                	mov    %edi,%eax
  80087d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800881:	74 05                	je     800888 <vprintfmt+0x444>
  800883:	83 e8 01             	sub    $0x1,%eax
  800886:	eb f5                	jmp    80087d <vprintfmt+0x439>
  800888:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80088b:	e9 5a ff ff ff       	jmp    8007ea <vprintfmt+0x3a6>
}
  800890:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5f                   	pop    %edi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800898:	f3 0f 1e fb          	endbr32 
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	83 ec 18             	sub    $0x18,%esp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008af:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	74 26                	je     8008e3 <vsnprintf+0x4b>
  8008bd:	85 d2                	test   %edx,%edx
  8008bf:	7e 22                	jle    8008e3 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c1:	ff 75 14             	pushl  0x14(%ebp)
  8008c4:	ff 75 10             	pushl  0x10(%ebp)
  8008c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ca:	50                   	push   %eax
  8008cb:	68 02 04 80 00       	push   $0x800402
  8008d0:	e8 6f fb ff ff       	call   800444 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008de:	83 c4 10             	add    $0x10,%esp
}
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    
		return -E_INVAL;
  8008e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e8:	eb f7                	jmp    8008e1 <vsnprintf+0x49>

008008ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ea:	f3 0f 1e fb          	endbr32 
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8008f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f7:	50                   	push   %eax
  8008f8:	ff 75 10             	pushl  0x10(%ebp)
  8008fb:	ff 75 0c             	pushl  0xc(%ebp)
  8008fe:	ff 75 08             	pushl  0x8(%ebp)
  800901:	e8 92 ff ff ff       	call   800898 <vsnprintf>
	va_end(ap);

	return rc;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800908:	f3 0f 1e fb          	endbr32 
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
  800917:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091b:	74 05                	je     800922 <strlen+0x1a>
		n++;
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	eb f5                	jmp    800917 <strlen+0xf>
	return n;
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800924:	f3 0f 1e fb          	endbr32 
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	39 d0                	cmp    %edx,%eax
  800938:	74 0d                	je     800947 <strnlen+0x23>
  80093a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093e:	74 05                	je     800945 <strnlen+0x21>
		n++;
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	eb f1                	jmp    800936 <strnlen+0x12>
  800945:	89 c2                	mov    %eax,%edx
	return n;
}
  800947:	89 d0                	mov    %edx,%eax
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094b:	f3 0f 1e fb          	endbr32 
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
  80095e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800962:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	84 d2                	test   %dl,%dl
  80096a:	75 f2                	jne    80095e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80096c:	89 c8                	mov    %ecx,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800971:	f3 0f 1e fb          	endbr32 
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	83 ec 10             	sub    $0x10,%esp
  80097c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097f:	53                   	push   %ebx
  800980:	e8 83 ff ff ff       	call   800908 <strlen>
  800985:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	01 d8                	add    %ebx,%eax
  80098d:	50                   	push   %eax
  80098e:	e8 b8 ff ff ff       	call   80094b <strcpy>
	return dst;
}
  800993:	89 d8                	mov    %ebx,%eax
  800995:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099a:	f3 0f 1e fb          	endbr32 
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 f3                	mov    %esi,%ebx
  8009ab:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ae:	89 f0                	mov    %esi,%eax
  8009b0:	39 d8                	cmp    %ebx,%eax
  8009b2:	74 11                	je     8009c5 <strncpy+0x2b>
		*dst++ = *src;
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	0f b6 0a             	movzbl (%edx),%ecx
  8009ba:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009bd:	80 f9 01             	cmp    $0x1,%cl
  8009c0:	83 da ff             	sbb    $0xffffffff,%edx
  8009c3:	eb eb                	jmp    8009b0 <strncpy+0x16>
	}
	return ret;
}
  8009c5:	89 f0                	mov    %esi,%eax
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009cb:	f3 0f 1e fb          	endbr32 
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	56                   	push   %esi
  8009d3:	53                   	push   %ebx
  8009d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009da:	8b 55 10             	mov    0x10(%ebp),%edx
  8009dd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009df:	85 d2                	test   %edx,%edx
  8009e1:	74 21                	je     800a04 <strlcpy+0x39>
  8009e3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009e7:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009e9:	39 c2                	cmp    %eax,%edx
  8009eb:	74 14                	je     800a01 <strlcpy+0x36>
  8009ed:	0f b6 19             	movzbl (%ecx),%ebx
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	74 0b                	je     8009ff <strlcpy+0x34>
			*dst++ = *src++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
  8009f7:	83 c2 01             	add    $0x1,%edx
  8009fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009fd:	eb ea                	jmp    8009e9 <strlcpy+0x1e>
  8009ff:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a01:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a04:	29 f0                	sub    %esi,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0a:	f3 0f 1e fb          	endbr32 
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a17:	0f b6 01             	movzbl (%ecx),%eax
  800a1a:	84 c0                	test   %al,%al
  800a1c:	74 0c                	je     800a2a <strcmp+0x20>
  800a1e:	3a 02                	cmp    (%edx),%al
  800a20:	75 08                	jne    800a2a <strcmp+0x20>
		p++, q++;
  800a22:	83 c1 01             	add    $0x1,%ecx
  800a25:	83 c2 01             	add    $0x1,%edx
  800a28:	eb ed                	jmp    800a17 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	0f b6 12             	movzbl (%edx),%edx
  800a30:	29 d0                	sub    %edx,%eax
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a34:	f3 0f 1e fb          	endbr32 
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a42:	89 c3                	mov    %eax,%ebx
  800a44:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a47:	eb 06                	jmp    800a4f <strncmp+0x1b>
		n--, p++, q++;
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a4f:	39 d8                	cmp    %ebx,%eax
  800a51:	74 16                	je     800a69 <strncmp+0x35>
  800a53:	0f b6 08             	movzbl (%eax),%ecx
  800a56:	84 c9                	test   %cl,%cl
  800a58:	74 04                	je     800a5e <strncmp+0x2a>
  800a5a:	3a 0a                	cmp    (%edx),%cl
  800a5c:	74 eb                	je     800a49 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5e:	0f b6 00             	movzbl (%eax),%eax
  800a61:	0f b6 12             	movzbl (%edx),%edx
  800a64:	29 d0                	sub    %edx,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    
		return 0;
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	eb f6                	jmp    800a66 <strncmp+0x32>

00800a70 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a70:	f3 0f 1e fb          	endbr32 
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7e:	0f b6 10             	movzbl (%eax),%edx
  800a81:	84 d2                	test   %dl,%dl
  800a83:	74 09                	je     800a8e <strchr+0x1e>
		if (*s == c)
  800a85:	38 ca                	cmp    %cl,%dl
  800a87:	74 0a                	je     800a93 <strchr+0x23>
	for (; *s; s++)
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	eb f0                	jmp    800a7e <strchr+0xe>
			return (char *) s;
	return 0;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800a95:	f3 0f 1e fb          	endbr32 
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800a9f:	6a 78                	push   $0x78
  800aa1:	ff 75 08             	pushl  0x8(%ebp)
  800aa4:	e8 c7 ff ff ff       	call   800a70 <strchr>
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800ab4:	eb 0d                	jmp    800ac3 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800ab6:	c1 e0 04             	shl    $0x4,%eax
  800ab9:	0f be d2             	movsbl %dl,%edx
  800abc:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	0f b6 11             	movzbl (%ecx),%edx
  800ac6:	84 d2                	test   %dl,%dl
  800ac8:	74 11                	je     800adb <atox+0x46>
		if (*p>='a'){
  800aca:	80 fa 60             	cmp    $0x60,%dl
  800acd:	7e e7                	jle    800ab6 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800acf:	c1 e0 04             	shl    $0x4,%eax
  800ad2:	0f be d2             	movsbl %dl,%edx
  800ad5:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800ad9:	eb e5                	jmp    800ac0 <atox+0x2b>
	}

	return v;

}
  800adb:	c9                   	leave  
  800adc:	c3                   	ret    

00800add <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800add:	f3 0f 1e fb          	endbr32 
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aeb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aee:	38 ca                	cmp    %cl,%dl
  800af0:	74 09                	je     800afb <strfind+0x1e>
  800af2:	84 d2                	test   %dl,%dl
  800af4:	74 05                	je     800afb <strfind+0x1e>
	for (; *s; s++)
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	eb f0                	jmp    800aeb <strfind+0xe>
			break;
	return (char *) s;
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0d:	85 c9                	test   %ecx,%ecx
  800b0f:	74 31                	je     800b42 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b11:	89 f8                	mov    %edi,%eax
  800b13:	09 c8                	or     %ecx,%eax
  800b15:	a8 03                	test   $0x3,%al
  800b17:	75 23                	jne    800b3c <memset+0x3f>
		c &= 0xFF;
  800b19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1d:	89 d3                	mov    %edx,%ebx
  800b1f:	c1 e3 08             	shl    $0x8,%ebx
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	c1 e0 18             	shl    $0x18,%eax
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	c1 e6 10             	shl    $0x10,%esi
  800b2c:	09 f0                	or     %esi,%eax
  800b2e:	09 c2                	or     %eax,%edx
  800b30:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b32:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b35:	89 d0                	mov    %edx,%eax
  800b37:	fc                   	cld    
  800b38:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3a:	eb 06                	jmp    800b42 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	fc                   	cld    
  800b40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b42:	89 f8                	mov    %edi,%eax
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b49:	f3 0f 1e fb          	endbr32 
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5b:	39 c6                	cmp    %eax,%esi
  800b5d:	73 32                	jae    800b91 <memmove+0x48>
  800b5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b62:	39 c2                	cmp    %eax,%edx
  800b64:	76 2b                	jbe    800b91 <memmove+0x48>
		s += n;
		d += n;
  800b66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b69:	89 fe                	mov    %edi,%esi
  800b6b:	09 ce                	or     %ecx,%esi
  800b6d:	09 d6                	or     %edx,%esi
  800b6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b75:	75 0e                	jne    800b85 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b77:	83 ef 04             	sub    $0x4,%edi
  800b7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b80:	fd                   	std    
  800b81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b83:	eb 09                	jmp    800b8e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b85:	83 ef 01             	sub    $0x1,%edi
  800b88:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b8b:	fd                   	std    
  800b8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8e:	fc                   	cld    
  800b8f:	eb 1a                	jmp    800bab <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	09 ca                	or     %ecx,%edx
  800b95:	09 f2                	or     %esi,%edx
  800b97:	f6 c2 03             	test   $0x3,%dl
  800b9a:	75 0a                	jne    800ba6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	fc                   	cld    
  800ba2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba4:	eb 05                	jmp    800bab <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb9:	ff 75 10             	pushl  0x10(%ebp)
  800bbc:	ff 75 0c             	pushl  0xc(%ebp)
  800bbf:	ff 75 08             	pushl  0x8(%ebp)
  800bc2:	e8 82 ff ff ff       	call   800b49 <memmove>
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc9:	f3 0f 1e fb          	endbr32 
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd8:	89 c6                	mov    %eax,%esi
  800bda:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdd:	39 f0                	cmp    %esi,%eax
  800bdf:	74 1c                	je     800bfd <memcmp+0x34>
		if (*s1 != *s2)
  800be1:	0f b6 08             	movzbl (%eax),%ecx
  800be4:	0f b6 1a             	movzbl (%edx),%ebx
  800be7:	38 d9                	cmp    %bl,%cl
  800be9:	75 08                	jne    800bf3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800beb:	83 c0 01             	add    $0x1,%eax
  800bee:	83 c2 01             	add    $0x1,%edx
  800bf1:	eb ea                	jmp    800bdd <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800bf3:	0f b6 c1             	movzbl %cl,%eax
  800bf6:	0f b6 db             	movzbl %bl,%ebx
  800bf9:	29 d8                	sub    %ebx,%eax
  800bfb:	eb 05                	jmp    800c02 <memcmp+0x39>
	}

	return 0;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c06:	f3 0f 1e fb          	endbr32 
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c13:	89 c2                	mov    %eax,%edx
  800c15:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c18:	39 d0                	cmp    %edx,%eax
  800c1a:	73 09                	jae    800c25 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1c:	38 08                	cmp    %cl,(%eax)
  800c1e:	74 05                	je     800c25 <memfind+0x1f>
	for (; s < ends; s++)
  800c20:	83 c0 01             	add    $0x1,%eax
  800c23:	eb f3                	jmp    800c18 <memfind+0x12>
			break;
	return (void *) s;
}
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c27:	f3 0f 1e fb          	endbr32 
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c37:	eb 03                	jmp    800c3c <strtol+0x15>
		s++;
  800c39:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c3c:	0f b6 01             	movzbl (%ecx),%eax
  800c3f:	3c 20                	cmp    $0x20,%al
  800c41:	74 f6                	je     800c39 <strtol+0x12>
  800c43:	3c 09                	cmp    $0x9,%al
  800c45:	74 f2                	je     800c39 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c47:	3c 2b                	cmp    $0x2b,%al
  800c49:	74 2a                	je     800c75 <strtol+0x4e>
	int neg = 0;
  800c4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c50:	3c 2d                	cmp    $0x2d,%al
  800c52:	74 2b                	je     800c7f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5a:	75 0f                	jne    800c6b <strtol+0x44>
  800c5c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5f:	74 28                	je     800c89 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c61:	85 db                	test   %ebx,%ebx
  800c63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c68:	0f 44 d8             	cmove  %eax,%ebx
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c70:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c73:	eb 46                	jmp    800cbb <strtol+0x94>
		s++;
  800c75:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	eb d5                	jmp    800c54 <strtol+0x2d>
		s++, neg = 1;
  800c7f:	83 c1 01             	add    $0x1,%ecx
  800c82:	bf 01 00 00 00       	mov    $0x1,%edi
  800c87:	eb cb                	jmp    800c54 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8d:	74 0e                	je     800c9d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c8f:	85 db                	test   %ebx,%ebx
  800c91:	75 d8                	jne    800c6b <strtol+0x44>
		s++, base = 8;
  800c93:	83 c1 01             	add    $0x1,%ecx
  800c96:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c9b:	eb ce                	jmp    800c6b <strtol+0x44>
		s += 2, base = 16;
  800c9d:	83 c1 02             	add    $0x2,%ecx
  800ca0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca5:	eb c4                	jmp    800c6b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ca7:	0f be d2             	movsbl %dl,%edx
  800caa:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb0:	7d 3a                	jge    800cec <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cb2:	83 c1 01             	add    $0x1,%ecx
  800cb5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cbb:	0f b6 11             	movzbl (%ecx),%edx
  800cbe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc1:	89 f3                	mov    %esi,%ebx
  800cc3:	80 fb 09             	cmp    $0x9,%bl
  800cc6:	76 df                	jbe    800ca7 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800cc8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ccb:	89 f3                	mov    %esi,%ebx
  800ccd:	80 fb 19             	cmp    $0x19,%bl
  800cd0:	77 08                	ja     800cda <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cd2:	0f be d2             	movsbl %dl,%edx
  800cd5:	83 ea 57             	sub    $0x57,%edx
  800cd8:	eb d3                	jmp    800cad <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800cda:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cdd:	89 f3                	mov    %esi,%ebx
  800cdf:	80 fb 19             	cmp    $0x19,%bl
  800ce2:	77 08                	ja     800cec <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ce4:	0f be d2             	movsbl %dl,%edx
  800ce7:	83 ea 37             	sub    $0x37,%edx
  800cea:	eb c1                	jmp    800cad <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf0:	74 05                	je     800cf7 <strtol+0xd0>
		*endptr = (char *) s;
  800cf2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cf7:	89 c2                	mov    %eax,%edx
  800cf9:	f7 da                	neg    %edx
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	0f 45 c2             	cmovne %edx,%eax
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d05:	f3 0f 1e fb          	endbr32 
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	89 c7                	mov    %eax,%edi
  800d1e:	89 c6                	mov    %eax,%esi
  800d20:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d27:	f3 0f 1e fb          	endbr32 
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d31:	ba 00 00 00 00       	mov    $0x0,%edx
  800d36:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3b:	89 d1                	mov    %edx,%ecx
  800d3d:	89 d3                	mov    %edx,%ebx
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 d6                	mov    %edx,%esi
  800d43:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d4a:	f3 0f 1e fb          	endbr32 
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d6e:	f3 0f 1e fb          	endbr32 
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d78:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 d3                	mov    %edx,%ebx
  800d86:	89 d7                	mov    %edx,%edi
  800d88:	89 d6                	mov    %edx,%esi
  800d8a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_yield>:

void
sys_yield(void)
{
  800d91:	f3 0f 1e fb          	endbr32 
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db4:	f3 0f 1e fb          	endbr32 
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbe:	be 00 00 00 00       	mov    $0x0,%esi
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800dce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd1:	89 f7                	mov    %esi,%edi
  800dd3:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dda:	f3 0f 1e fb          	endbr32 
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	b8 05 00 00 00       	mov    $0x5,%eax
  800def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df5:	8b 75 18             	mov    0x18(%ebp),%esi
  800df8:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dff:	f3 0f 1e fb          	endbr32 
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	b8 06 00 00 00       	mov    $0x6,%eax
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e24:	f3 0f 1e fb          	endbr32 
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	b8 08 00 00 00       	mov    $0x8,%eax
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	89 de                	mov    %ebx,%esi
  800e42:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e49:	f3 0f 1e fb          	endbr32 
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6e:	f3 0f 1e fb          	endbr32 
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e93:	f3 0f 1e fb          	endbr32 
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea8:	be 00 00 00 00       	mov    $0x0,%esi
  800ead:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eba:	f3 0f 1e fb          	endbr32 
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed1:	89 cb                	mov    %ecx,%ebx
  800ed3:	89 cf                	mov    %ecx,%edi
  800ed5:	89 ce                	mov    %ecx,%esi
  800ed7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ede:	f3 0f 1e fb          	endbr32 
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee8:	ba 00 00 00 00       	mov    $0x0,%edx
  800eed:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef2:	89 d1                	mov    %edx,%ecx
  800ef4:	89 d3                	mov    %edx,%ebx
  800ef6:	89 d7                	mov    %edx,%edi
  800ef8:	89 d6                	mov    %edx,%esi
  800efa:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800f01:	f3 0f 1e fb          	endbr32 
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f16:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f1b:	89 df                	mov    %ebx,%edi
  800f1d:	89 de                	mov    %ebx,%esi
  800f1f:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800f26:	f3 0f 1e fb          	endbr32 
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	8b 55 08             	mov    0x8(%ebp),%edx
  800f38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3b:	b8 10 00 00 00       	mov    $0x10,%eax
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800f4b:	f3 0f 1e fb          	endbr32 
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	53                   	push   %ebx
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800f59:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800f5b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f5f:	0f 84 9a 00 00 00    	je     800fff <pgfault+0xb4>
  800f65:	89 d8                	mov    %ebx,%eax
  800f67:	c1 e8 16             	shr    $0x16,%eax
  800f6a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f71:	a8 01                	test   $0x1,%al
  800f73:	0f 84 86 00 00 00    	je     800fff <pgfault+0xb4>
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	c1 e8 0c             	shr    $0xc,%eax
  800f7e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f85:	f6 c2 01             	test   $0x1,%dl
  800f88:	74 75                	je     800fff <pgfault+0xb4>
  800f8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f91:	f6 c4 08             	test   $0x8,%ah
  800f94:	74 69                	je     800fff <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800f96:	83 ec 04             	sub    $0x4,%esp
  800f99:	6a 07                	push   $0x7
  800f9b:	68 00 f0 7f 00       	push   $0x7ff000
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 0d fe ff ff       	call   800db4 <sys_page_alloc>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 63                	js     801011 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800fae:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	68 00 10 00 00       	push   $0x1000
  800fbc:	53                   	push   %ebx
  800fbd:	68 00 f0 7f 00       	push   $0x7ff000
  800fc2:	e8 e8 fb ff ff       	call   800baf <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800fc7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fce:	53                   	push   %ebx
  800fcf:	6a 00                	push   $0x0
  800fd1:	68 00 f0 7f 00       	push   $0x7ff000
  800fd6:	6a 00                	push   $0x0
  800fd8:	e8 fd fd ff ff       	call   800dda <sys_page_map>
  800fdd:	83 c4 20             	add    $0x20,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 3f                	js     801023 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	68 00 f0 7f 00       	push   $0x7ff000
  800fec:	6a 00                	push   $0x0
  800fee:	e8 0c fe ff ff       	call   800dff <sys_page_unmap>
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 3b                	js     801035 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800ffa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800fff:	53                   	push   %ebx
  801000:	68 40 2c 80 00       	push   $0x802c40
  801005:	6a 20                	push   $0x20
  801007:	68 fe 2c 80 00       	push   $0x802cfe
  80100c:	e8 49 f2 ff ff       	call   80025a <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  801011:	50                   	push   %eax
  801012:	68 80 2c 80 00       	push   $0x802c80
  801017:	6a 2c                	push   $0x2c
  801019:	68 fe 2c 80 00       	push   $0x802cfe
  80101e:	e8 37 f2 ff ff       	call   80025a <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  801023:	50                   	push   %eax
  801024:	68 ac 2c 80 00       	push   $0x802cac
  801029:	6a 33                	push   $0x33
  80102b:	68 fe 2c 80 00       	push   $0x802cfe
  801030:	e8 25 f2 ff ff       	call   80025a <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  801035:	50                   	push   %eax
  801036:	68 d4 2c 80 00       	push   $0x802cd4
  80103b:	6a 36                	push   $0x36
  80103d:	68 fe 2c 80 00       	push   $0x802cfe
  801042:	e8 13 f2 ff ff       	call   80025a <_panic>

00801047 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801047:	f3 0f 1e fb          	endbr32 
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  801054:	68 4b 0f 80 00       	push   $0x800f4b
  801059:	e8 c4 14 00 00       	call   802522 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80105e:	b8 07 00 00 00       	mov    $0x7,%eax
  801063:	cd 30                	int    $0x30
  801065:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 29                	js     801098 <fork+0x51>
  80106f:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801071:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  801076:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80107a:	75 60                	jne    8010dc <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  80107c:	e8 ed fc ff ff       	call   800d6e <sys_getenvid>
  801081:	25 ff 03 00 00       	and    $0x3ff,%eax
  801086:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80108e:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801093:	e9 14 01 00 00       	jmp    8011ac <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  801098:	50                   	push   %eax
  801099:	68 09 2d 80 00       	push   $0x802d09
  80109e:	68 90 00 00 00       	push   $0x90
  8010a3:	68 fe 2c 80 00       	push   $0x802cfe
  8010a8:	e8 ad f1 ff ff       	call   80025a <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  8010ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010bc:	50                   	push   %eax
  8010bd:	56                   	push   %esi
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 13 fd ff ff       	call   800dda <sys_page_map>
  8010c7:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8010ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010d0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d6:	0f 84 95 00 00 00    	je     801171 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	c1 e8 16             	shr    $0x16,%eax
  8010e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e8:	a8 01                	test   $0x1,%al
  8010ea:	74 de                	je     8010ca <fork+0x83>
  8010ec:	89 d8                	mov    %ebx,%eax
  8010ee:	c1 e8 0c             	shr    $0xc,%eax
  8010f1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f8:	f6 c2 01             	test   $0x1,%dl
  8010fb:	74 cd                	je     8010ca <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  8010fd:	89 c6                	mov    %eax,%esi
  8010ff:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  801102:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801109:	f6 c6 04             	test   $0x4,%dh
  80110c:	75 9f                	jne    8010ad <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  80110e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801115:	f6 c2 02             	test   $0x2,%dl
  801118:	75 0c                	jne    801126 <fork+0xdf>
  80111a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801121:	f6 c4 08             	test   $0x8,%ah
  801124:	74 34                	je     80115a <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801126:	83 ec 0c             	sub    $0xc,%esp
  801129:	68 05 08 00 00       	push   $0x805
  80112e:	56                   	push   %esi
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	6a 00                	push   $0x0
  801133:	e8 a2 fc ff ff       	call   800dda <sys_page_map>
			if (r<0) return r;
  801138:	83 c4 20             	add    $0x20,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 8b                	js     8010ca <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80113f:	83 ec 0c             	sub    $0xc,%esp
  801142:	68 05 08 00 00       	push   $0x805
  801147:	56                   	push   %esi
  801148:	6a 00                	push   $0x0
  80114a:	56                   	push   %esi
  80114b:	6a 00                	push   $0x0
  80114d:	e8 88 fc ff ff       	call   800dda <sys_page_map>
  801152:	83 c4 20             	add    $0x20,%esp
  801155:	e9 70 ff ff ff       	jmp    8010ca <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	6a 05                	push   $0x5
  80115f:	56                   	push   %esi
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	6a 00                	push   $0x0
  801164:	e8 71 fc ff ff       	call   800dda <sys_page_map>
  801169:	83 c4 20             	add    $0x20,%esp
  80116c:	e9 59 ff ff ff       	jmp    8010ca <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	6a 07                	push   $0x7
  801176:	68 00 f0 bf ee       	push   $0xeebff000
  80117b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80117e:	56                   	push   %esi
  80117f:	e8 30 fc ff ff       	call   800db4 <sys_page_alloc>
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	78 2b                	js     8011b6 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	68 95 25 80 00       	push   $0x802595
  801193:	56                   	push   %esi
  801194:	e8 d5 fc ff ff       	call   800e6e <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	6a 02                	push   $0x2
  80119e:	56                   	push   %esi
  80119f:	e8 80 fc ff ff       	call   800e24 <sys_env_set_status>
  8011a4:	83 c4 10             	add    $0x10,%esp
		return r;
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  8011ac:	89 f8                	mov    %edi,%eax
  8011ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    
		return r;
  8011b6:	89 c7                	mov    %eax,%edi
  8011b8:	eb f2                	jmp    8011ac <fork+0x165>

008011ba <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  8011ba:	f3 0f 1e fb          	endbr32 
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c4:	68 25 2d 80 00       	push   $0x802d25
  8011c9:	68 b2 00 00 00       	push   $0xb2
  8011ce:	68 fe 2c 80 00       	push   $0x802cfe
  8011d3:	e8 82 f0 ff ff       	call   80025a <_panic>

008011d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011d8:	f3 0f 1e fb          	endbr32 
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011f1:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	50                   	push   %eax
  8011f8:	e8 bd fc ff ff       	call   800eba <sys_ipc_recv>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	75 2b                	jne    80122f <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801204:	85 f6                	test   %esi,%esi
  801206:	74 0a                	je     801212 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801208:	a1 08 40 80 00       	mov    0x804008,%eax
  80120d:	8b 40 74             	mov    0x74(%eax),%eax
  801210:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  801212:	85 db                	test   %ebx,%ebx
  801214:	74 0a                	je     801220 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801216:	a1 08 40 80 00       	mov    0x804008,%eax
  80121b:	8b 40 78             	mov    0x78(%eax),%eax
  80121e:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  801220:	a1 08 40 80 00       	mov    0x804008,%eax
  801225:	8b 40 70             	mov    0x70(%eax),%eax
}
  801228:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80122f:	85 f6                	test   %esi,%esi
  801231:	74 06                	je     801239 <ipc_recv+0x61>
  801233:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801239:	85 db                	test   %ebx,%ebx
  80123b:	74 eb                	je     801228 <ipc_recv+0x50>
  80123d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801243:	eb e3                	jmp    801228 <ipc_recv+0x50>

00801245 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801245:	f3 0f 1e fb          	endbr32 
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	8b 7d 08             	mov    0x8(%ebp),%edi
  801255:	8b 75 0c             	mov    0xc(%ebp),%esi
  801258:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  80125b:	85 db                	test   %ebx,%ebx
  80125d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801262:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801265:	ff 75 14             	pushl  0x14(%ebp)
  801268:	53                   	push   %ebx
  801269:	56                   	push   %esi
  80126a:	57                   	push   %edi
  80126b:	e8 23 fc ff ff       	call   800e93 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801276:	75 07                	jne    80127f <ipc_send+0x3a>
			sys_yield();
  801278:	e8 14 fb ff ff       	call   800d91 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80127d:	eb e6                	jmp    801265 <ipc_send+0x20>
		}
		else if (ret == 0)
  80127f:	85 c0                	test   %eax,%eax
  801281:	75 08                	jne    80128b <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80128b:	50                   	push   %eax
  80128c:	68 3b 2d 80 00       	push   $0x802d3b
  801291:	6a 48                	push   $0x48
  801293:	68 49 2d 80 00       	push   $0x802d49
  801298:	e8 bd ef ff ff       	call   80025a <_panic>

0080129d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80129d:	f3 0f 1e fb          	endbr32 
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012ac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012b5:	8b 52 50             	mov    0x50(%edx),%edx
  8012b8:	39 ca                	cmp    %ecx,%edx
  8012ba:	74 11                	je     8012cd <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8012bc:	83 c0 01             	add    $0x1,%eax
  8012bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012c4:	75 e6                	jne    8012ac <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cb:	eb 0b                	jmp    8012d8 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8012cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d5:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012da:	f3 0f 1e fb          	endbr32 
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e9:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ee:	f3 0f 1e fb          	endbr32 
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801302:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801307:	5d                   	pop    %ebp
  801308:	c3                   	ret    

00801309 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801309:	f3 0f 1e fb          	endbr32 
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801315:	89 c2                	mov    %eax,%edx
  801317:	c1 ea 16             	shr    $0x16,%edx
  80131a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801321:	f6 c2 01             	test   $0x1,%dl
  801324:	74 2d                	je     801353 <fd_alloc+0x4a>
  801326:	89 c2                	mov    %eax,%edx
  801328:	c1 ea 0c             	shr    $0xc,%edx
  80132b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801332:	f6 c2 01             	test   $0x1,%dl
  801335:	74 1c                	je     801353 <fd_alloc+0x4a>
  801337:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80133c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801341:	75 d2                	jne    801315 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
  801346:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80134c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801351:	eb 0a                	jmp    80135d <fd_alloc+0x54>
			*fd_store = fd;
  801353:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801356:	89 01                	mov    %eax,(%ecx)
			return 0;
  801358:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80135f:	f3 0f 1e fb          	endbr32 
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801369:	83 f8 1f             	cmp    $0x1f,%eax
  80136c:	77 30                	ja     80139e <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80136e:	c1 e0 0c             	shl    $0xc,%eax
  801371:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801376:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80137c:	f6 c2 01             	test   $0x1,%dl
  80137f:	74 24                	je     8013a5 <fd_lookup+0x46>
  801381:	89 c2                	mov    %eax,%edx
  801383:	c1 ea 0c             	shr    $0xc,%edx
  801386:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80138d:	f6 c2 01             	test   $0x1,%dl
  801390:	74 1a                	je     8013ac <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801392:	8b 55 0c             	mov    0xc(%ebp),%edx
  801395:	89 02                	mov    %eax,(%edx)
	return 0;
  801397:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    
		return -E_INVAL;
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a3:	eb f7                	jmp    80139c <fd_lookup+0x3d>
		return -E_INVAL;
  8013a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013aa:	eb f0                	jmp    80139c <fd_lookup+0x3d>
  8013ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b1:	eb e9                	jmp    80139c <fd_lookup+0x3d>

008013b3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013b3:	f3 0f 1e fb          	endbr32 
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8013c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c5:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013ca:	39 08                	cmp    %ecx,(%eax)
  8013cc:	74 38                	je     801406 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8013ce:	83 c2 01             	add    $0x1,%edx
  8013d1:	8b 04 95 d0 2d 80 00 	mov    0x802dd0(,%edx,4),%eax
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	75 ee                	jne    8013ca <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8013e1:	8b 40 48             	mov    0x48(%eax),%eax
  8013e4:	83 ec 04             	sub    $0x4,%esp
  8013e7:	51                   	push   %ecx
  8013e8:	50                   	push   %eax
  8013e9:	68 54 2d 80 00       	push   $0x802d54
  8013ee:	e8 4e ef ff ff       	call   800341 <cprintf>
	*dev = 0;
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801404:	c9                   	leave  
  801405:	c3                   	ret    
			*dev = devtab[i];
  801406:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801409:	89 01                	mov    %eax,(%ecx)
			return 0;
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
  801410:	eb f2                	jmp    801404 <dev_lookup+0x51>

00801412 <fd_close>:
{
  801412:	f3 0f 1e fb          	endbr32 
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	57                   	push   %edi
  80141a:	56                   	push   %esi
  80141b:	53                   	push   %ebx
  80141c:	83 ec 24             	sub    $0x24,%esp
  80141f:	8b 75 08             	mov    0x8(%ebp),%esi
  801422:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801425:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801428:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801429:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80142f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801432:	50                   	push   %eax
  801433:	e8 27 ff ff ff       	call   80135f <fd_lookup>
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 05                	js     801446 <fd_close+0x34>
	    || fd != fd2)
  801441:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801444:	74 16                	je     80145c <fd_close+0x4a>
		return (must_exist ? r : 0);
  801446:	89 f8                	mov    %edi,%eax
  801448:	84 c0                	test   %al,%al
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
  80144f:	0f 44 d8             	cmove  %eax,%ebx
}
  801452:	89 d8                	mov    %ebx,%eax
  801454:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	ff 36                	pushl  (%esi)
  801465:	e8 49 ff ff ff       	call   8013b3 <dev_lookup>
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 1a                	js     80148d <fd_close+0x7b>
		if (dev->dev_close)
  801473:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801476:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801479:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80147e:	85 c0                	test   %eax,%eax
  801480:	74 0b                	je     80148d <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	56                   	push   %esi
  801486:	ff d0                	call   *%eax
  801488:	89 c3                	mov    %eax,%ebx
  80148a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	56                   	push   %esi
  801491:	6a 00                	push   $0x0
  801493:	e8 67 f9 ff ff       	call   800dff <sys_page_unmap>
	return r;
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb b5                	jmp    801452 <fd_close+0x40>

0080149d <close>:

int
close(int fdnum)
{
  80149d:	f3 0f 1e fb          	endbr32 
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	50                   	push   %eax
  8014ab:	ff 75 08             	pushl  0x8(%ebp)
  8014ae:	e8 ac fe ff ff       	call   80135f <fd_lookup>
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	79 02                	jns    8014bc <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    
		return fd_close(fd, 1);
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	6a 01                	push   $0x1
  8014c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c4:	e8 49 ff ff ff       	call   801412 <fd_close>
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	eb ec                	jmp    8014ba <close+0x1d>

008014ce <close_all>:

void
close_all(void)
{
  8014ce:	f3 0f 1e fb          	endbr32 
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	53                   	push   %ebx
  8014d6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	53                   	push   %ebx
  8014e2:	e8 b6 ff ff ff       	call   80149d <close>
	for (i = 0; i < MAXFD; i++)
  8014e7:	83 c3 01             	add    $0x1,%ebx
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	83 fb 20             	cmp    $0x20,%ebx
  8014f0:	75 ec                	jne    8014de <close_all+0x10>
}
  8014f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f5:	c9                   	leave  
  8014f6:	c3                   	ret    

008014f7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014f7:	f3 0f 1e fb          	endbr32 
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	57                   	push   %edi
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801504:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	ff 75 08             	pushl  0x8(%ebp)
  80150b:	e8 4f fe ff ff       	call   80135f <fd_lookup>
  801510:	89 c3                	mov    %eax,%ebx
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	0f 88 81 00 00 00    	js     80159e <dup+0xa7>
		return r;
	close(newfdnum);
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	ff 75 0c             	pushl  0xc(%ebp)
  801523:	e8 75 ff ff ff       	call   80149d <close>

	newfd = INDEX2FD(newfdnum);
  801528:	8b 75 0c             	mov    0xc(%ebp),%esi
  80152b:	c1 e6 0c             	shl    $0xc,%esi
  80152e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801534:	83 c4 04             	add    $0x4,%esp
  801537:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153a:	e8 af fd ff ff       	call   8012ee <fd2data>
  80153f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801541:	89 34 24             	mov    %esi,(%esp)
  801544:	e8 a5 fd ff ff       	call   8012ee <fd2data>
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80154e:	89 d8                	mov    %ebx,%eax
  801550:	c1 e8 16             	shr    $0x16,%eax
  801553:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80155a:	a8 01                	test   $0x1,%al
  80155c:	74 11                	je     80156f <dup+0x78>
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	c1 e8 0c             	shr    $0xc,%eax
  801563:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80156a:	f6 c2 01             	test   $0x1,%dl
  80156d:	75 39                	jne    8015a8 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801572:	89 d0                	mov    %edx,%eax
  801574:	c1 e8 0c             	shr    $0xc,%eax
  801577:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157e:	83 ec 0c             	sub    $0xc,%esp
  801581:	25 07 0e 00 00       	and    $0xe07,%eax
  801586:	50                   	push   %eax
  801587:	56                   	push   %esi
  801588:	6a 00                	push   $0x0
  80158a:	52                   	push   %edx
  80158b:	6a 00                	push   $0x0
  80158d:	e8 48 f8 ff ff       	call   800dda <sys_page_map>
  801592:	89 c3                	mov    %eax,%ebx
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 31                	js     8015cc <dup+0xd5>
		goto err;

	return newfdnum;
  80159b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80159e:	89 d8                	mov    %ebx,%eax
  8015a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5f                   	pop    %edi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b7:	50                   	push   %eax
  8015b8:	57                   	push   %edi
  8015b9:	6a 00                	push   $0x0
  8015bb:	53                   	push   %ebx
  8015bc:	6a 00                	push   $0x0
  8015be:	e8 17 f8 ff ff       	call   800dda <sys_page_map>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	83 c4 20             	add    $0x20,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	79 a3                	jns    80156f <dup+0x78>
	sys_page_unmap(0, newfd);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	56                   	push   %esi
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 28 f8 ff ff       	call   800dff <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d7:	83 c4 08             	add    $0x8,%esp
  8015da:	57                   	push   %edi
  8015db:	6a 00                	push   $0x0
  8015dd:	e8 1d f8 ff ff       	call   800dff <sys_page_unmap>
	return r;
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	eb b7                	jmp    80159e <dup+0xa7>

008015e7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015e7:	f3 0f 1e fb          	endbr32 
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 1c             	sub    $0x1c,%esp
  8015f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	53                   	push   %ebx
  8015fa:	e8 60 fd ff ff       	call   80135f <fd_lookup>
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 3f                	js     801645 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	ff 30                	pushl  (%eax)
  801612:	e8 9c fd ff ff       	call   8013b3 <dev_lookup>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 27                	js     801645 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80161e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801621:	8b 42 08             	mov    0x8(%edx),%eax
  801624:	83 e0 03             	and    $0x3,%eax
  801627:	83 f8 01             	cmp    $0x1,%eax
  80162a:	74 1e                	je     80164a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162f:	8b 40 08             	mov    0x8(%eax),%eax
  801632:	85 c0                	test   %eax,%eax
  801634:	74 35                	je     80166b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801636:	83 ec 04             	sub    $0x4,%esp
  801639:	ff 75 10             	pushl  0x10(%ebp)
  80163c:	ff 75 0c             	pushl  0xc(%ebp)
  80163f:	52                   	push   %edx
  801640:	ff d0                	call   *%eax
  801642:	83 c4 10             	add    $0x10,%esp
}
  801645:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801648:	c9                   	leave  
  801649:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80164a:	a1 08 40 80 00       	mov    0x804008,%eax
  80164f:	8b 40 48             	mov    0x48(%eax),%eax
  801652:	83 ec 04             	sub    $0x4,%esp
  801655:	53                   	push   %ebx
  801656:	50                   	push   %eax
  801657:	68 95 2d 80 00       	push   $0x802d95
  80165c:	e8 e0 ec ff ff       	call   800341 <cprintf>
		return -E_INVAL;
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801669:	eb da                	jmp    801645 <read+0x5e>
		return -E_NOT_SUPP;
  80166b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801670:	eb d3                	jmp    801645 <read+0x5e>

00801672 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801672:	f3 0f 1e fb          	endbr32 
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	57                   	push   %edi
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	83 ec 0c             	sub    $0xc,%esp
  80167f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801682:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801685:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168a:	eb 02                	jmp    80168e <readn+0x1c>
  80168c:	01 c3                	add    %eax,%ebx
  80168e:	39 f3                	cmp    %esi,%ebx
  801690:	73 21                	jae    8016b3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	89 f0                	mov    %esi,%eax
  801697:	29 d8                	sub    %ebx,%eax
  801699:	50                   	push   %eax
  80169a:	89 d8                	mov    %ebx,%eax
  80169c:	03 45 0c             	add    0xc(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	57                   	push   %edi
  8016a1:	e8 41 ff ff ff       	call   8015e7 <read>
		if (m < 0)
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 04                	js     8016b1 <readn+0x3f>
			return m;
		if (m == 0)
  8016ad:	75 dd                	jne    80168c <readn+0x1a>
  8016af:	eb 02                	jmp    8016b3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016b1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016b3:	89 d8                	mov    %ebx,%eax
  8016b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5f                   	pop    %edi
  8016bb:	5d                   	pop    %ebp
  8016bc:	c3                   	ret    

008016bd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016bd:	f3 0f 1e fb          	endbr32 
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 1c             	sub    $0x1c,%esp
  8016c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	53                   	push   %ebx
  8016d0:	e8 8a fc ff ff       	call   80135f <fd_lookup>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 3a                	js     801716 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e6:	ff 30                	pushl  (%eax)
  8016e8:	e8 c6 fc ff ff       	call   8013b3 <dev_lookup>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 22                	js     801716 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fb:	74 1e                	je     80171b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801700:	8b 52 0c             	mov    0xc(%edx),%edx
  801703:	85 d2                	test   %edx,%edx
  801705:	74 35                	je     80173c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801707:	83 ec 04             	sub    $0x4,%esp
  80170a:	ff 75 10             	pushl  0x10(%ebp)
  80170d:	ff 75 0c             	pushl  0xc(%ebp)
  801710:	50                   	push   %eax
  801711:	ff d2                	call   *%edx
  801713:	83 c4 10             	add    $0x10,%esp
}
  801716:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801719:	c9                   	leave  
  80171a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80171b:	a1 08 40 80 00       	mov    0x804008,%eax
  801720:	8b 40 48             	mov    0x48(%eax),%eax
  801723:	83 ec 04             	sub    $0x4,%esp
  801726:	53                   	push   %ebx
  801727:	50                   	push   %eax
  801728:	68 b1 2d 80 00       	push   $0x802db1
  80172d:	e8 0f ec ff ff       	call   800341 <cprintf>
		return -E_INVAL;
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173a:	eb da                	jmp    801716 <write+0x59>
		return -E_NOT_SUPP;
  80173c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801741:	eb d3                	jmp    801716 <write+0x59>

00801743 <seek>:

int
seek(int fdnum, off_t offset)
{
  801743:	f3 0f 1e fb          	endbr32 
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80174d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801750:	50                   	push   %eax
  801751:	ff 75 08             	pushl  0x8(%ebp)
  801754:	e8 06 fc ff ff       	call   80135f <fd_lookup>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 0e                	js     80176e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801760:	8b 55 0c             	mov    0xc(%ebp),%edx
  801763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801766:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801770:	f3 0f 1e fb          	endbr32 
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	53                   	push   %ebx
  801778:	83 ec 1c             	sub    $0x1c,%esp
  80177b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801781:	50                   	push   %eax
  801782:	53                   	push   %ebx
  801783:	e8 d7 fb ff ff       	call   80135f <fd_lookup>
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 37                	js     8017c6 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801795:	50                   	push   %eax
  801796:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801799:	ff 30                	pushl  (%eax)
  80179b:	e8 13 fc ff ff       	call   8013b3 <dev_lookup>
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 1f                	js     8017c6 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ae:	74 1b                	je     8017cb <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b3:	8b 52 18             	mov    0x18(%edx),%edx
  8017b6:	85 d2                	test   %edx,%edx
  8017b8:	74 32                	je     8017ec <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	ff 75 0c             	pushl  0xc(%ebp)
  8017c0:	50                   	push   %eax
  8017c1:	ff d2                	call   *%edx
  8017c3:	83 c4 10             	add    $0x10,%esp
}
  8017c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c9:	c9                   	leave  
  8017ca:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017cb:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d0:	8b 40 48             	mov    0x48(%eax),%eax
  8017d3:	83 ec 04             	sub    $0x4,%esp
  8017d6:	53                   	push   %ebx
  8017d7:	50                   	push   %eax
  8017d8:	68 74 2d 80 00       	push   $0x802d74
  8017dd:	e8 5f eb ff ff       	call   800341 <cprintf>
		return -E_INVAL;
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ea:	eb da                	jmp    8017c6 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8017ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f1:	eb d3                	jmp    8017c6 <ftruncate+0x56>

008017f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f3:	f3 0f 1e fb          	endbr32 
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	53                   	push   %ebx
  8017fb:	83 ec 1c             	sub    $0x1c,%esp
  8017fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801801:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801804:	50                   	push   %eax
  801805:	ff 75 08             	pushl  0x8(%ebp)
  801808:	e8 52 fb ff ff       	call   80135f <fd_lookup>
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 4b                	js     80185f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181a:	50                   	push   %eax
  80181b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181e:	ff 30                	pushl  (%eax)
  801820:	e8 8e fb ff ff       	call   8013b3 <dev_lookup>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 33                	js     80185f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801833:	74 2f                	je     801864 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801835:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801838:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80183f:	00 00 00 
	stat->st_isdir = 0;
  801842:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801849:	00 00 00 
	stat->st_dev = dev;
  80184c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	53                   	push   %ebx
  801856:	ff 75 f0             	pushl  -0x10(%ebp)
  801859:	ff 50 14             	call   *0x14(%eax)
  80185c:	83 c4 10             	add    $0x10,%esp
}
  80185f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801862:	c9                   	leave  
  801863:	c3                   	ret    
		return -E_NOT_SUPP;
  801864:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801869:	eb f4                	jmp    80185f <fstat+0x6c>

0080186b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80186b:	f3 0f 1e fb          	endbr32 
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	56                   	push   %esi
  801873:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	6a 00                	push   $0x0
  801879:	ff 75 08             	pushl  0x8(%ebp)
  80187c:	e8 01 02 00 00       	call   801a82 <open>
  801881:	89 c3                	mov    %eax,%ebx
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	78 1b                	js     8018a5 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	50                   	push   %eax
  801891:	e8 5d ff ff ff       	call   8017f3 <fstat>
  801896:	89 c6                	mov    %eax,%esi
	close(fd);
  801898:	89 1c 24             	mov    %ebx,(%esp)
  80189b:	e8 fd fb ff ff       	call   80149d <close>
	return r;
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	89 f3                	mov    %esi,%ebx
}
  8018a5:	89 d8                	mov    %ebx,%eax
  8018a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	56                   	push   %esi
  8018b2:	53                   	push   %ebx
  8018b3:	89 c6                	mov    %eax,%esi
  8018b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018b7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018be:	74 27                	je     8018e7 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018c0:	6a 07                	push   $0x7
  8018c2:	68 00 50 80 00       	push   $0x805000
  8018c7:	56                   	push   %esi
  8018c8:	ff 35 00 40 80 00    	pushl  0x804000
  8018ce:	e8 72 f9 ff ff       	call   801245 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018d3:	83 c4 0c             	add    $0xc,%esp
  8018d6:	6a 00                	push   $0x0
  8018d8:	53                   	push   %ebx
  8018d9:	6a 00                	push   $0x0
  8018db:	e8 f8 f8 ff ff       	call   8011d8 <ipc_recv>
}
  8018e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	6a 01                	push   $0x1
  8018ec:	e8 ac f9 ff ff       	call   80129d <ipc_find_env>
  8018f1:	a3 00 40 80 00       	mov    %eax,0x804000
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	eb c5                	jmp    8018c0 <fsipc+0x12>

008018fb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018fb:	f3 0f 1e fb          	endbr32 
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 40 0c             	mov    0xc(%eax),%eax
  80190b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801910:	8b 45 0c             	mov    0xc(%ebp),%eax
  801913:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801918:	ba 00 00 00 00       	mov    $0x0,%edx
  80191d:	b8 02 00 00 00       	mov    $0x2,%eax
  801922:	e8 87 ff ff ff       	call   8018ae <fsipc>
}
  801927:	c9                   	leave  
  801928:	c3                   	ret    

00801929 <devfile_flush>:
{
  801929:	f3 0f 1e fb          	endbr32 
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	8b 40 0c             	mov    0xc(%eax),%eax
  801939:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80193e:	ba 00 00 00 00       	mov    $0x0,%edx
  801943:	b8 06 00 00 00       	mov    $0x6,%eax
  801948:	e8 61 ff ff ff       	call   8018ae <fsipc>
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <devfile_stat>:
{
  80194f:	f3 0f 1e fb          	endbr32 
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	53                   	push   %ebx
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	8b 40 0c             	mov    0xc(%eax),%eax
  801963:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801968:	ba 00 00 00 00       	mov    $0x0,%edx
  80196d:	b8 05 00 00 00       	mov    $0x5,%eax
  801972:	e8 37 ff ff ff       	call   8018ae <fsipc>
  801977:	85 c0                	test   %eax,%eax
  801979:	78 2c                	js     8019a7 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	68 00 50 80 00       	push   $0x805000
  801983:	53                   	push   %ebx
  801984:	e8 c2 ef ff ff       	call   80094b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801989:	a1 80 50 80 00       	mov    0x805080,%eax
  80198e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801994:	a1 84 50 80 00       	mov    0x805084,%eax
  801999:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <devfile_write>:
{
  8019ac:	f3 0f 1e fb          	endbr32 
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019be:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019c3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8019c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8019cc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019d2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019d7:	50                   	push   %eax
  8019d8:	ff 75 0c             	pushl  0xc(%ebp)
  8019db:	68 08 50 80 00       	push   $0x805008
  8019e0:	e8 64 f1 ff ff       	call   800b49 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8019e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8019ef:	e8 ba fe ff ff       	call   8018ae <fsipc>
}
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <devfile_read>:
{
  8019f6:	f3 0f 1e fb          	endbr32 
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a02:	8b 45 08             	mov    0x8(%ebp),%eax
  801a05:	8b 40 0c             	mov    0xc(%eax),%eax
  801a08:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a0d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a13:	ba 00 00 00 00       	mov    $0x0,%edx
  801a18:	b8 03 00 00 00       	mov    $0x3,%eax
  801a1d:	e8 8c fe ff ff       	call   8018ae <fsipc>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 1f                	js     801a47 <devfile_read+0x51>
	assert(r <= n);
  801a28:	39 f0                	cmp    %esi,%eax
  801a2a:	77 24                	ja     801a50 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801a2c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a31:	7f 36                	jg     801a69 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a33:	83 ec 04             	sub    $0x4,%esp
  801a36:	50                   	push   %eax
  801a37:	68 00 50 80 00       	push   $0x805000
  801a3c:	ff 75 0c             	pushl  0xc(%ebp)
  801a3f:	e8 05 f1 ff ff       	call   800b49 <memmove>
	return r;
  801a44:	83 c4 10             	add    $0x10,%esp
}
  801a47:	89 d8                	mov    %ebx,%eax
  801a49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4c:	5b                   	pop    %ebx
  801a4d:	5e                   	pop    %esi
  801a4e:	5d                   	pop    %ebp
  801a4f:	c3                   	ret    
	assert(r <= n);
  801a50:	68 e4 2d 80 00       	push   $0x802de4
  801a55:	68 eb 2d 80 00       	push   $0x802deb
  801a5a:	68 8c 00 00 00       	push   $0x8c
  801a5f:	68 00 2e 80 00       	push   $0x802e00
  801a64:	e8 f1 e7 ff ff       	call   80025a <_panic>
	assert(r <= PGSIZE);
  801a69:	68 0b 2e 80 00       	push   $0x802e0b
  801a6e:	68 eb 2d 80 00       	push   $0x802deb
  801a73:	68 8d 00 00 00       	push   $0x8d
  801a78:	68 00 2e 80 00       	push   $0x802e00
  801a7d:	e8 d8 e7 ff ff       	call   80025a <_panic>

00801a82 <open>:
{
  801a82:	f3 0f 1e fb          	endbr32 
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 1c             	sub    $0x1c,%esp
  801a8e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a91:	56                   	push   %esi
  801a92:	e8 71 ee ff ff       	call   800908 <strlen>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9f:	7f 6c                	jg     801b0d <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	e8 5c f8 ff ff       	call   801309 <fd_alloc>
  801aad:	89 c3                	mov    %eax,%ebx
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 3c                	js     801af2 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801ab6:	83 ec 08             	sub    $0x8,%esp
  801ab9:	56                   	push   %esi
  801aba:	68 00 50 80 00       	push   $0x805000
  801abf:	e8 87 ee ff ff       	call   80094b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801acc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801acf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad4:	e8 d5 fd ff ff       	call   8018ae <fsipc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 19                	js     801afb <open+0x79>
	return fd2num(fd);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae8:	e8 ed f7 ff ff       	call   8012da <fd2num>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	83 c4 10             	add    $0x10,%esp
}
  801af2:	89 d8                	mov    %ebx,%eax
  801af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    
		fd_close(fd, 0);
  801afb:	83 ec 08             	sub    $0x8,%esp
  801afe:	6a 00                	push   $0x0
  801b00:	ff 75 f4             	pushl  -0xc(%ebp)
  801b03:	e8 0a f9 ff ff       	call   801412 <fd_close>
		return r;
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	eb e5                	jmp    801af2 <open+0x70>
		return -E_BAD_PATH;
  801b0d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b12:	eb de                	jmp    801af2 <open+0x70>

00801b14 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b14:	f3 0f 1e fb          	endbr32 
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b23:	b8 08 00 00 00       	mov    $0x8,%eax
  801b28:	e8 81 fd ff ff       	call   8018ae <fsipc>
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2f:	f3 0f 1e fb          	endbr32 
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	c1 ea 16             	shr    $0x16,%edx
  801b3e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b45:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b4a:	f6 c1 01             	test   $0x1,%cl
  801b4d:	74 1c                	je     801b6b <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b4f:	c1 e8 0c             	shr    $0xc,%eax
  801b52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b59:	a8 01                	test   $0x1,%al
  801b5b:	74 0e                	je     801b6b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5d:	c1 e8 0c             	shr    $0xc,%eax
  801b60:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b67:	ef 
  801b68:	0f b7 d2             	movzwl %dx,%edx
}
  801b6b:	89 d0                	mov    %edx,%eax
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b6f:	f3 0f 1e fb          	endbr32 
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b79:	68 77 2e 80 00       	push   $0x802e77
  801b7e:	ff 75 0c             	pushl  0xc(%ebp)
  801b81:	e8 c5 ed ff ff       	call   80094b <strcpy>
	return 0;
}
  801b86:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <devsock_close>:
{
  801b8d:	f3 0f 1e fb          	endbr32 
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	53                   	push   %ebx
  801b95:	83 ec 10             	sub    $0x10,%esp
  801b98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b9b:	53                   	push   %ebx
  801b9c:	e8 8e ff ff ff       	call   801b2f <pageref>
  801ba1:	89 c2                	mov    %eax,%edx
  801ba3:	83 c4 10             	add    $0x10,%esp
		return 0;
  801ba6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801bab:	83 fa 01             	cmp    $0x1,%edx
  801bae:	74 05                	je     801bb5 <devsock_close+0x28>
}
  801bb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	ff 73 0c             	pushl  0xc(%ebx)
  801bbb:	e8 e3 02 00 00       	call   801ea3 <nsipc_close>
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	eb eb                	jmp    801bb0 <devsock_close+0x23>

00801bc5 <devsock_write>:
{
  801bc5:	f3 0f 1e fb          	endbr32 
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bcf:	6a 00                	push   $0x0
  801bd1:	ff 75 10             	pushl  0x10(%ebp)
  801bd4:	ff 75 0c             	pushl  0xc(%ebp)
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	ff 70 0c             	pushl  0xc(%eax)
  801bdd:	e8 b5 03 00 00       	call   801f97 <nsipc_send>
}
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <devsock_read>:
{
  801be4:	f3 0f 1e fb          	endbr32 
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bee:	6a 00                	push   $0x0
  801bf0:	ff 75 10             	pushl  0x10(%ebp)
  801bf3:	ff 75 0c             	pushl  0xc(%ebp)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	ff 70 0c             	pushl  0xc(%eax)
  801bfc:	e8 1f 03 00 00       	call   801f20 <nsipc_recv>
}
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <fd2sockid>:
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c09:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c0c:	52                   	push   %edx
  801c0d:	50                   	push   %eax
  801c0e:	e8 4c f7 ff ff       	call   80135f <fd_lookup>
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 10                	js     801c2a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1d:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801c23:	39 08                	cmp    %ecx,(%eax)
  801c25:	75 05                	jne    801c2c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801c27:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    
		return -E_NOT_SUPP;
  801c2c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c31:	eb f7                	jmp    801c2a <fd2sockid+0x27>

00801c33 <alloc_sockfd>:
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801c3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c40:	50                   	push   %eax
  801c41:	e8 c3 f6 ff ff       	call   801309 <fd_alloc>
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	78 43                	js     801c92 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	68 07 04 00 00       	push   $0x407
  801c57:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5a:	6a 00                	push   $0x0
  801c5c:	e8 53 f1 ff ff       	call   800db4 <sys_page_alloc>
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 28                	js     801c92 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6d:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801c73:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c78:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c7f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c82:	83 ec 0c             	sub    $0xc,%esp
  801c85:	50                   	push   %eax
  801c86:	e8 4f f6 ff ff       	call   8012da <fd2num>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	eb 0c                	jmp    801c9e <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	56                   	push   %esi
  801c96:	e8 08 02 00 00       	call   801ea3 <nsipc_close>
		return r;
  801c9b:	83 c4 10             	add    $0x10,%esp
}
  801c9e:	89 d8                	mov    %ebx,%eax
  801ca0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <accept>:
{
  801ca7:	f3 0f 1e fb          	endbr32 
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb4:	e8 4a ff ff ff       	call   801c03 <fd2sockid>
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 1b                	js     801cd8 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cbd:	83 ec 04             	sub    $0x4,%esp
  801cc0:	ff 75 10             	pushl  0x10(%ebp)
  801cc3:	ff 75 0c             	pushl  0xc(%ebp)
  801cc6:	50                   	push   %eax
  801cc7:	e8 22 01 00 00       	call   801dee <nsipc_accept>
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 05                	js     801cd8 <accept+0x31>
	return alloc_sockfd(r);
  801cd3:	e8 5b ff ff ff       	call   801c33 <alloc_sockfd>
}
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <bind>:
{
  801cda:	f3 0f 1e fb          	endbr32 
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	e8 17 ff ff ff       	call   801c03 <fd2sockid>
  801cec:	85 c0                	test   %eax,%eax
  801cee:	78 12                	js     801d02 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801cf0:	83 ec 04             	sub    $0x4,%esp
  801cf3:	ff 75 10             	pushl  0x10(%ebp)
  801cf6:	ff 75 0c             	pushl  0xc(%ebp)
  801cf9:	50                   	push   %eax
  801cfa:	e8 45 01 00 00       	call   801e44 <nsipc_bind>
  801cff:	83 c4 10             	add    $0x10,%esp
}
  801d02:	c9                   	leave  
  801d03:	c3                   	ret    

00801d04 <shutdown>:
{
  801d04:	f3 0f 1e fb          	endbr32 
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d11:	e8 ed fe ff ff       	call   801c03 <fd2sockid>
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 0f                	js     801d29 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801d1a:	83 ec 08             	sub    $0x8,%esp
  801d1d:	ff 75 0c             	pushl  0xc(%ebp)
  801d20:	50                   	push   %eax
  801d21:	e8 57 01 00 00       	call   801e7d <nsipc_shutdown>
  801d26:	83 c4 10             	add    $0x10,%esp
}
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <connect>:
{
  801d2b:	f3 0f 1e fb          	endbr32 
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	e8 c6 fe ff ff       	call   801c03 <fd2sockid>
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 12                	js     801d53 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	ff 75 10             	pushl  0x10(%ebp)
  801d47:	ff 75 0c             	pushl  0xc(%ebp)
  801d4a:	50                   	push   %eax
  801d4b:	e8 71 01 00 00       	call   801ec1 <nsipc_connect>
  801d50:	83 c4 10             	add    $0x10,%esp
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <listen>:
{
  801d55:	f3 0f 1e fb          	endbr32 
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	e8 9c fe ff ff       	call   801c03 <fd2sockid>
  801d67:	85 c0                	test   %eax,%eax
  801d69:	78 0f                	js     801d7a <listen+0x25>
	return nsipc_listen(r, backlog);
  801d6b:	83 ec 08             	sub    $0x8,%esp
  801d6e:	ff 75 0c             	pushl  0xc(%ebp)
  801d71:	50                   	push   %eax
  801d72:	e8 83 01 00 00       	call   801efa <nsipc_listen>
  801d77:	83 c4 10             	add    $0x10,%esp
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <socket>:

int
socket(int domain, int type, int protocol)
{
  801d7c:	f3 0f 1e fb          	endbr32 
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d86:	ff 75 10             	pushl  0x10(%ebp)
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	ff 75 08             	pushl  0x8(%ebp)
  801d8f:	e8 65 02 00 00       	call   801ff9 <nsipc_socket>
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	78 05                	js     801da0 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801d9b:	e8 93 fe ff ff       	call   801c33 <alloc_sockfd>
}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	53                   	push   %ebx
  801da6:	83 ec 04             	sub    $0x4,%esp
  801da9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dab:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801db2:	74 26                	je     801dda <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801db4:	6a 07                	push   $0x7
  801db6:	68 00 60 80 00       	push   $0x806000
  801dbb:	53                   	push   %ebx
  801dbc:	ff 35 04 40 80 00    	pushl  0x804004
  801dc2:	e8 7e f4 ff ff       	call   801245 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dc7:	83 c4 0c             	add    $0xc,%esp
  801dca:	6a 00                	push   $0x0
  801dcc:	6a 00                	push   $0x0
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 03 f4 ff ff       	call   8011d8 <ipc_recv>
}
  801dd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801dda:	83 ec 0c             	sub    $0xc,%esp
  801ddd:	6a 02                	push   $0x2
  801ddf:	e8 b9 f4 ff ff       	call   80129d <ipc_find_env>
  801de4:	a3 04 40 80 00       	mov    %eax,0x804004
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	eb c6                	jmp    801db4 <nsipc+0x12>

00801dee <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dee:	f3 0f 1e fb          	endbr32 
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	56                   	push   %esi
  801df6:	53                   	push   %ebx
  801df7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e02:	8b 06                	mov    (%esi),%eax
  801e04:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e09:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0e:	e8 8f ff ff ff       	call   801da2 <nsipc>
  801e13:	89 c3                	mov    %eax,%ebx
  801e15:	85 c0                	test   %eax,%eax
  801e17:	79 09                	jns    801e22 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801e19:	89 d8                	mov    %ebx,%eax
  801e1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1e:	5b                   	pop    %ebx
  801e1f:	5e                   	pop    %esi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	ff 35 10 60 80 00    	pushl  0x806010
  801e2b:	68 00 60 80 00       	push   $0x806000
  801e30:	ff 75 0c             	pushl  0xc(%ebp)
  801e33:	e8 11 ed ff ff       	call   800b49 <memmove>
		*addrlen = ret->ret_addrlen;
  801e38:	a1 10 60 80 00       	mov    0x806010,%eax
  801e3d:	89 06                	mov    %eax,(%esi)
  801e3f:	83 c4 10             	add    $0x10,%esp
	return r;
  801e42:	eb d5                	jmp    801e19 <nsipc_accept+0x2b>

00801e44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e44:	f3 0f 1e fb          	endbr32 
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	53                   	push   %ebx
  801e4c:	83 ec 08             	sub    $0x8,%esp
  801e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e5a:	53                   	push   %ebx
  801e5b:	ff 75 0c             	pushl  0xc(%ebp)
  801e5e:	68 04 60 80 00       	push   $0x806004
  801e63:	e8 e1 ec ff ff       	call   800b49 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e68:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e6e:	b8 02 00 00 00       	mov    $0x2,%eax
  801e73:	e8 2a ff ff ff       	call   801da2 <nsipc>
}
  801e78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e7d:	f3 0f 1e fb          	endbr32 
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e87:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e92:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e97:	b8 03 00 00 00       	mov    $0x3,%eax
  801e9c:	e8 01 ff ff ff       	call   801da2 <nsipc>
}
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <nsipc_close>:

int
nsipc_close(int s)
{
  801ea3:	f3 0f 1e fb          	endbr32 
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801eb5:	b8 04 00 00 00       	mov    $0x4,%eax
  801eba:	e8 e3 fe ff ff       	call   801da2 <nsipc>
}
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ec1:	f3 0f 1e fb          	endbr32 
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 08             	sub    $0x8,%esp
  801ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ed7:	53                   	push   %ebx
  801ed8:	ff 75 0c             	pushl  0xc(%ebp)
  801edb:	68 04 60 80 00       	push   $0x806004
  801ee0:	e8 64 ec ff ff       	call   800b49 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ee5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801eeb:	b8 05 00 00 00       	mov    $0x5,%eax
  801ef0:	e8 ad fe ff ff       	call   801da2 <nsipc>
}
  801ef5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801efa:	f3 0f 1e fb          	endbr32 
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f14:	b8 06 00 00 00       	mov    $0x6,%eax
  801f19:	e8 84 fe ff ff       	call   801da2 <nsipc>
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f20:	f3 0f 1e fb          	endbr32 
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	56                   	push   %esi
  801f28:	53                   	push   %ebx
  801f29:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f34:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f3a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f42:	b8 07 00 00 00       	mov    $0x7,%eax
  801f47:	e8 56 fe ff ff       	call   801da2 <nsipc>
  801f4c:	89 c3                	mov    %eax,%ebx
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	78 26                	js     801f78 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801f52:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801f58:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801f5d:	0f 4e c6             	cmovle %esi,%eax
  801f60:	39 c3                	cmp    %eax,%ebx
  801f62:	7f 1d                	jg     801f81 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f64:	83 ec 04             	sub    $0x4,%esp
  801f67:	53                   	push   %ebx
  801f68:	68 00 60 80 00       	push   $0x806000
  801f6d:	ff 75 0c             	pushl  0xc(%ebp)
  801f70:	e8 d4 eb ff ff       	call   800b49 <memmove>
  801f75:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f78:	89 d8                	mov    %ebx,%eax
  801f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801f81:	68 83 2e 80 00       	push   $0x802e83
  801f86:	68 eb 2d 80 00       	push   $0x802deb
  801f8b:	6a 62                	push   $0x62
  801f8d:	68 98 2e 80 00       	push   $0x802e98
  801f92:	e8 c3 e2 ff ff       	call   80025a <_panic>

00801f97 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f97:	f3 0f 1e fb          	endbr32 
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	53                   	push   %ebx
  801f9f:	83 ec 04             	sub    $0x4,%esp
  801fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fad:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fb3:	7f 2e                	jg     801fe3 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fb5:	83 ec 04             	sub    $0x4,%esp
  801fb8:	53                   	push   %ebx
  801fb9:	ff 75 0c             	pushl  0xc(%ebp)
  801fbc:	68 0c 60 80 00       	push   $0x80600c
  801fc1:	e8 83 eb ff ff       	call   800b49 <memmove>
	nsipcbuf.send.req_size = size;
  801fc6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fcc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fcf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fd4:	b8 08 00 00 00       	mov    $0x8,%eax
  801fd9:	e8 c4 fd ff ff       	call   801da2 <nsipc>
}
  801fde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    
	assert(size < 1600);
  801fe3:	68 a4 2e 80 00       	push   $0x802ea4
  801fe8:	68 eb 2d 80 00       	push   $0x802deb
  801fed:	6a 6d                	push   $0x6d
  801fef:	68 98 2e 80 00       	push   $0x802e98
  801ff4:	e8 61 e2 ff ff       	call   80025a <_panic>

00801ff9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ff9:	f3 0f 1e fb          	endbr32 
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802003:	8b 45 08             	mov    0x8(%ebp),%eax
  802006:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80200b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200e:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802013:	8b 45 10             	mov    0x10(%ebp),%eax
  802016:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80201b:	b8 09 00 00 00       	mov    $0x9,%eax
  802020:	e8 7d fd ff ff       	call   801da2 <nsipc>
}
  802025:	c9                   	leave  
  802026:	c3                   	ret    

00802027 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802027:	f3 0f 1e fb          	endbr32 
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	56                   	push   %esi
  80202f:	53                   	push   %ebx
  802030:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802033:	83 ec 0c             	sub    $0xc,%esp
  802036:	ff 75 08             	pushl  0x8(%ebp)
  802039:	e8 b0 f2 ff ff       	call   8012ee <fd2data>
  80203e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802040:	83 c4 08             	add    $0x8,%esp
  802043:	68 b0 2e 80 00       	push   $0x802eb0
  802048:	53                   	push   %ebx
  802049:	e8 fd e8 ff ff       	call   80094b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80204e:	8b 46 04             	mov    0x4(%esi),%eax
  802051:	2b 06                	sub    (%esi),%eax
  802053:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802059:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802060:	00 00 00 
	stat->st_dev = &devpipe;
  802063:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  80206a:	30 80 00 
	return 0;
}
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
  802072:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    

00802079 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802079:	f3 0f 1e fb          	endbr32 
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	53                   	push   %ebx
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802087:	53                   	push   %ebx
  802088:	6a 00                	push   $0x0
  80208a:	e8 70 ed ff ff       	call   800dff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80208f:	89 1c 24             	mov    %ebx,(%esp)
  802092:	e8 57 f2 ff ff       	call   8012ee <fd2data>
  802097:	83 c4 08             	add    $0x8,%esp
  80209a:	50                   	push   %eax
  80209b:	6a 00                	push   $0x0
  80209d:	e8 5d ed ff ff       	call   800dff <sys_page_unmap>
}
  8020a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a5:	c9                   	leave  
  8020a6:	c3                   	ret    

008020a7 <_pipeisclosed>:
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	57                   	push   %edi
  8020ab:	56                   	push   %esi
  8020ac:	53                   	push   %ebx
  8020ad:	83 ec 1c             	sub    $0x1c,%esp
  8020b0:	89 c7                	mov    %eax,%edi
  8020b2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8020b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8020b9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020bc:	83 ec 0c             	sub    $0xc,%esp
  8020bf:	57                   	push   %edi
  8020c0:	e8 6a fa ff ff       	call   801b2f <pageref>
  8020c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020c8:	89 34 24             	mov    %esi,(%esp)
  8020cb:	e8 5f fa ff ff       	call   801b2f <pageref>
		nn = thisenv->env_runs;
  8020d0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8020d6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	39 cb                	cmp    %ecx,%ebx
  8020de:	74 1b                	je     8020fb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8020e0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020e3:	75 cf                	jne    8020b4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020e5:	8b 42 58             	mov    0x58(%edx),%eax
  8020e8:	6a 01                	push   $0x1
  8020ea:	50                   	push   %eax
  8020eb:	53                   	push   %ebx
  8020ec:	68 b7 2e 80 00       	push   $0x802eb7
  8020f1:	e8 4b e2 ff ff       	call   800341 <cprintf>
  8020f6:	83 c4 10             	add    $0x10,%esp
  8020f9:	eb b9                	jmp    8020b4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8020fb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020fe:	0f 94 c0             	sete   %al
  802101:	0f b6 c0             	movzbl %al,%eax
}
  802104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <devpipe_write>:
{
  80210c:	f3 0f 1e fb          	endbr32 
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	57                   	push   %edi
  802114:	56                   	push   %esi
  802115:	53                   	push   %ebx
  802116:	83 ec 28             	sub    $0x28,%esp
  802119:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80211c:	56                   	push   %esi
  80211d:	e8 cc f1 ff ff       	call   8012ee <fd2data>
  802122:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	bf 00 00 00 00       	mov    $0x0,%edi
  80212c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80212f:	74 4f                	je     802180 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802131:	8b 43 04             	mov    0x4(%ebx),%eax
  802134:	8b 0b                	mov    (%ebx),%ecx
  802136:	8d 51 20             	lea    0x20(%ecx),%edx
  802139:	39 d0                	cmp    %edx,%eax
  80213b:	72 14                	jb     802151 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80213d:	89 da                	mov    %ebx,%edx
  80213f:	89 f0                	mov    %esi,%eax
  802141:	e8 61 ff ff ff       	call   8020a7 <_pipeisclosed>
  802146:	85 c0                	test   %eax,%eax
  802148:	75 3b                	jne    802185 <devpipe_write+0x79>
			sys_yield();
  80214a:	e8 42 ec ff ff       	call   800d91 <sys_yield>
  80214f:	eb e0                	jmp    802131 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802154:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802158:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80215b:	89 c2                	mov    %eax,%edx
  80215d:	c1 fa 1f             	sar    $0x1f,%edx
  802160:	89 d1                	mov    %edx,%ecx
  802162:	c1 e9 1b             	shr    $0x1b,%ecx
  802165:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802168:	83 e2 1f             	and    $0x1f,%edx
  80216b:	29 ca                	sub    %ecx,%edx
  80216d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802171:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802175:	83 c0 01             	add    $0x1,%eax
  802178:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80217b:	83 c7 01             	add    $0x1,%edi
  80217e:	eb ac                	jmp    80212c <devpipe_write+0x20>
	return i;
  802180:	8b 45 10             	mov    0x10(%ebp),%eax
  802183:	eb 05                	jmp    80218a <devpipe_write+0x7e>
				return 0;
  802185:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80218a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    

00802192 <devpipe_read>:
{
  802192:	f3 0f 1e fb          	endbr32 
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
  802199:	57                   	push   %edi
  80219a:	56                   	push   %esi
  80219b:	53                   	push   %ebx
  80219c:	83 ec 18             	sub    $0x18,%esp
  80219f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8021a2:	57                   	push   %edi
  8021a3:	e8 46 f1 ff ff       	call   8012ee <fd2data>
  8021a8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	be 00 00 00 00       	mov    $0x0,%esi
  8021b2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021b5:	75 14                	jne    8021cb <devpipe_read+0x39>
	return i;
  8021b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ba:	eb 02                	jmp    8021be <devpipe_read+0x2c>
				return i;
  8021bc:	89 f0                	mov    %esi,%eax
}
  8021be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021c1:	5b                   	pop    %ebx
  8021c2:	5e                   	pop    %esi
  8021c3:	5f                   	pop    %edi
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    
			sys_yield();
  8021c6:	e8 c6 eb ff ff       	call   800d91 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8021cb:	8b 03                	mov    (%ebx),%eax
  8021cd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021d0:	75 18                	jne    8021ea <devpipe_read+0x58>
			if (i > 0)
  8021d2:	85 f6                	test   %esi,%esi
  8021d4:	75 e6                	jne    8021bc <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8021d6:	89 da                	mov    %ebx,%edx
  8021d8:	89 f8                	mov    %edi,%eax
  8021da:	e8 c8 fe ff ff       	call   8020a7 <_pipeisclosed>
  8021df:	85 c0                	test   %eax,%eax
  8021e1:	74 e3                	je     8021c6 <devpipe_read+0x34>
				return 0;
  8021e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e8:	eb d4                	jmp    8021be <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021ea:	99                   	cltd   
  8021eb:	c1 ea 1b             	shr    $0x1b,%edx
  8021ee:	01 d0                	add    %edx,%eax
  8021f0:	83 e0 1f             	and    $0x1f,%eax
  8021f3:	29 d0                	sub    %edx,%eax
  8021f5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8021fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021fd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802200:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802203:	83 c6 01             	add    $0x1,%esi
  802206:	eb aa                	jmp    8021b2 <devpipe_read+0x20>

00802208 <pipe>:
{
  802208:	f3 0f 1e fb          	endbr32 
  80220c:	55                   	push   %ebp
  80220d:	89 e5                	mov    %esp,%ebp
  80220f:	56                   	push   %esi
  802210:	53                   	push   %ebx
  802211:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802214:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802217:	50                   	push   %eax
  802218:	e8 ec f0 ff ff       	call   801309 <fd_alloc>
  80221d:	89 c3                	mov    %eax,%ebx
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	85 c0                	test   %eax,%eax
  802224:	0f 88 23 01 00 00    	js     80234d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222a:	83 ec 04             	sub    $0x4,%esp
  80222d:	68 07 04 00 00       	push   $0x407
  802232:	ff 75 f4             	pushl  -0xc(%ebp)
  802235:	6a 00                	push   $0x0
  802237:	e8 78 eb ff ff       	call   800db4 <sys_page_alloc>
  80223c:	89 c3                	mov    %eax,%ebx
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	85 c0                	test   %eax,%eax
  802243:	0f 88 04 01 00 00    	js     80234d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802249:	83 ec 0c             	sub    $0xc,%esp
  80224c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80224f:	50                   	push   %eax
  802250:	e8 b4 f0 ff ff       	call   801309 <fd_alloc>
  802255:	89 c3                	mov    %eax,%ebx
  802257:	83 c4 10             	add    $0x10,%esp
  80225a:	85 c0                	test   %eax,%eax
  80225c:	0f 88 db 00 00 00    	js     80233d <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802262:	83 ec 04             	sub    $0x4,%esp
  802265:	68 07 04 00 00       	push   $0x407
  80226a:	ff 75 f0             	pushl  -0x10(%ebp)
  80226d:	6a 00                	push   $0x0
  80226f:	e8 40 eb ff ff       	call   800db4 <sys_page_alloc>
  802274:	89 c3                	mov    %eax,%ebx
  802276:	83 c4 10             	add    $0x10,%esp
  802279:	85 c0                	test   %eax,%eax
  80227b:	0f 88 bc 00 00 00    	js     80233d <pipe+0x135>
	va = fd2data(fd0);
  802281:	83 ec 0c             	sub    $0xc,%esp
  802284:	ff 75 f4             	pushl  -0xc(%ebp)
  802287:	e8 62 f0 ff ff       	call   8012ee <fd2data>
  80228c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80228e:	83 c4 0c             	add    $0xc,%esp
  802291:	68 07 04 00 00       	push   $0x407
  802296:	50                   	push   %eax
  802297:	6a 00                	push   $0x0
  802299:	e8 16 eb ff ff       	call   800db4 <sys_page_alloc>
  80229e:	89 c3                	mov    %eax,%ebx
  8022a0:	83 c4 10             	add    $0x10,%esp
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	0f 88 82 00 00 00    	js     80232d <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ab:	83 ec 0c             	sub    $0xc,%esp
  8022ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8022b1:	e8 38 f0 ff ff       	call   8012ee <fd2data>
  8022b6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022bd:	50                   	push   %eax
  8022be:	6a 00                	push   $0x0
  8022c0:	56                   	push   %esi
  8022c1:	6a 00                	push   $0x0
  8022c3:	e8 12 eb ff ff       	call   800dda <sys_page_map>
  8022c8:	89 c3                	mov    %eax,%ebx
  8022ca:	83 c4 20             	add    $0x20,%esp
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	78 4e                	js     80231f <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8022d1:	a1 7c 30 80 00       	mov    0x80307c,%eax
  8022d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022d9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8022db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022de:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8022e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022e8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8022ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ed:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8022f4:	83 ec 0c             	sub    $0xc,%esp
  8022f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8022fa:	e8 db ef ff ff       	call   8012da <fd2num>
  8022ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802302:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802304:	83 c4 04             	add    $0x4,%esp
  802307:	ff 75 f0             	pushl  -0x10(%ebp)
  80230a:	e8 cb ef ff ff       	call   8012da <fd2num>
  80230f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802312:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802315:	83 c4 10             	add    $0x10,%esp
  802318:	bb 00 00 00 00       	mov    $0x0,%ebx
  80231d:	eb 2e                	jmp    80234d <pipe+0x145>
	sys_page_unmap(0, va);
  80231f:	83 ec 08             	sub    $0x8,%esp
  802322:	56                   	push   %esi
  802323:	6a 00                	push   $0x0
  802325:	e8 d5 ea ff ff       	call   800dff <sys_page_unmap>
  80232a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80232d:	83 ec 08             	sub    $0x8,%esp
  802330:	ff 75 f0             	pushl  -0x10(%ebp)
  802333:	6a 00                	push   $0x0
  802335:	e8 c5 ea ff ff       	call   800dff <sys_page_unmap>
  80233a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80233d:	83 ec 08             	sub    $0x8,%esp
  802340:	ff 75 f4             	pushl  -0xc(%ebp)
  802343:	6a 00                	push   $0x0
  802345:	e8 b5 ea ff ff       	call   800dff <sys_page_unmap>
  80234a:	83 c4 10             	add    $0x10,%esp
}
  80234d:	89 d8                	mov    %ebx,%eax
  80234f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802352:	5b                   	pop    %ebx
  802353:	5e                   	pop    %esi
  802354:	5d                   	pop    %ebp
  802355:	c3                   	ret    

00802356 <pipeisclosed>:
{
  802356:	f3 0f 1e fb          	endbr32 
  80235a:	55                   	push   %ebp
  80235b:	89 e5                	mov    %esp,%ebp
  80235d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802363:	50                   	push   %eax
  802364:	ff 75 08             	pushl  0x8(%ebp)
  802367:	e8 f3 ef ff ff       	call   80135f <fd_lookup>
  80236c:	83 c4 10             	add    $0x10,%esp
  80236f:	85 c0                	test   %eax,%eax
  802371:	78 18                	js     80238b <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802373:	83 ec 0c             	sub    $0xc,%esp
  802376:	ff 75 f4             	pushl  -0xc(%ebp)
  802379:	e8 70 ef ff ff       	call   8012ee <fd2data>
  80237e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802383:	e8 1f fd ff ff       	call   8020a7 <_pipeisclosed>
  802388:	83 c4 10             	add    $0x10,%esp
}
  80238b:	c9                   	leave  
  80238c:	c3                   	ret    

0080238d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80238d:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802391:	b8 00 00 00 00       	mov    $0x0,%eax
  802396:	c3                   	ret    

00802397 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802397:	f3 0f 1e fb          	endbr32 
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023a1:	68 cf 2e 80 00       	push   $0x802ecf
  8023a6:	ff 75 0c             	pushl  0xc(%ebp)
  8023a9:	e8 9d e5 ff ff       	call   80094b <strcpy>
	return 0;
}
  8023ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b3:	c9                   	leave  
  8023b4:	c3                   	ret    

008023b5 <devcons_write>:
{
  8023b5:	f3 0f 1e fb          	endbr32 
  8023b9:	55                   	push   %ebp
  8023ba:	89 e5                	mov    %esp,%ebp
  8023bc:	57                   	push   %edi
  8023bd:	56                   	push   %esi
  8023be:	53                   	push   %ebx
  8023bf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8023c5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023ca:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8023d0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023d3:	73 31                	jae    802406 <devcons_write+0x51>
		m = n - tot;
  8023d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023d8:	29 f3                	sub    %esi,%ebx
  8023da:	83 fb 7f             	cmp    $0x7f,%ebx
  8023dd:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8023e2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8023e5:	83 ec 04             	sub    $0x4,%esp
  8023e8:	53                   	push   %ebx
  8023e9:	89 f0                	mov    %esi,%eax
  8023eb:	03 45 0c             	add    0xc(%ebp),%eax
  8023ee:	50                   	push   %eax
  8023ef:	57                   	push   %edi
  8023f0:	e8 54 e7 ff ff       	call   800b49 <memmove>
		sys_cputs(buf, m);
  8023f5:	83 c4 08             	add    $0x8,%esp
  8023f8:	53                   	push   %ebx
  8023f9:	57                   	push   %edi
  8023fa:	e8 06 e9 ff ff       	call   800d05 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8023ff:	01 de                	add    %ebx,%esi
  802401:	83 c4 10             	add    $0x10,%esp
  802404:	eb ca                	jmp    8023d0 <devcons_write+0x1b>
}
  802406:	89 f0                	mov    %esi,%eax
  802408:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240b:	5b                   	pop    %ebx
  80240c:	5e                   	pop    %esi
  80240d:	5f                   	pop    %edi
  80240e:	5d                   	pop    %ebp
  80240f:	c3                   	ret    

00802410 <devcons_read>:
{
  802410:	f3 0f 1e fb          	endbr32 
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	83 ec 08             	sub    $0x8,%esp
  80241a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80241f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802423:	74 21                	je     802446 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802425:	e8 fd e8 ff ff       	call   800d27 <sys_cgetc>
  80242a:	85 c0                	test   %eax,%eax
  80242c:	75 07                	jne    802435 <devcons_read+0x25>
		sys_yield();
  80242e:	e8 5e e9 ff ff       	call   800d91 <sys_yield>
  802433:	eb f0                	jmp    802425 <devcons_read+0x15>
	if (c < 0)
  802435:	78 0f                	js     802446 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802437:	83 f8 04             	cmp    $0x4,%eax
  80243a:	74 0c                	je     802448 <devcons_read+0x38>
	*(char*)vbuf = c;
  80243c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80243f:	88 02                	mov    %al,(%edx)
	return 1;
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802446:	c9                   	leave  
  802447:	c3                   	ret    
		return 0;
  802448:	b8 00 00 00 00       	mov    $0x0,%eax
  80244d:	eb f7                	jmp    802446 <devcons_read+0x36>

0080244f <cputchar>:
{
  80244f:	f3 0f 1e fb          	endbr32 
  802453:	55                   	push   %ebp
  802454:	89 e5                	mov    %esp,%ebp
  802456:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802459:	8b 45 08             	mov    0x8(%ebp),%eax
  80245c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80245f:	6a 01                	push   $0x1
  802461:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802464:	50                   	push   %eax
  802465:	e8 9b e8 ff ff       	call   800d05 <sys_cputs>
}
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	c9                   	leave  
  80246e:	c3                   	ret    

0080246f <getchar>:
{
  80246f:	f3 0f 1e fb          	endbr32 
  802473:	55                   	push   %ebp
  802474:	89 e5                	mov    %esp,%ebp
  802476:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802479:	6a 01                	push   $0x1
  80247b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80247e:	50                   	push   %eax
  80247f:	6a 00                	push   $0x0
  802481:	e8 61 f1 ff ff       	call   8015e7 <read>
	if (r < 0)
  802486:	83 c4 10             	add    $0x10,%esp
  802489:	85 c0                	test   %eax,%eax
  80248b:	78 06                	js     802493 <getchar+0x24>
	if (r < 1)
  80248d:	74 06                	je     802495 <getchar+0x26>
	return c;
  80248f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802493:	c9                   	leave  
  802494:	c3                   	ret    
		return -E_EOF;
  802495:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80249a:	eb f7                	jmp    802493 <getchar+0x24>

0080249c <iscons>:
{
  80249c:	f3 0f 1e fb          	endbr32 
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a9:	50                   	push   %eax
  8024aa:	ff 75 08             	pushl  0x8(%ebp)
  8024ad:	e8 ad ee ff ff       	call   80135f <fd_lookup>
  8024b2:	83 c4 10             	add    $0x10,%esp
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	78 11                	js     8024ca <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8024b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bc:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8024c2:	39 10                	cmp    %edx,(%eax)
  8024c4:	0f 94 c0             	sete   %al
  8024c7:	0f b6 c0             	movzbl %al,%eax
}
  8024ca:	c9                   	leave  
  8024cb:	c3                   	ret    

008024cc <opencons>:
{
  8024cc:	f3 0f 1e fb          	endbr32 
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8024d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024d9:	50                   	push   %eax
  8024da:	e8 2a ee ff ff       	call   801309 <fd_alloc>
  8024df:	83 c4 10             	add    $0x10,%esp
  8024e2:	85 c0                	test   %eax,%eax
  8024e4:	78 3a                	js     802520 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024e6:	83 ec 04             	sub    $0x4,%esp
  8024e9:	68 07 04 00 00       	push   $0x407
  8024ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f1:	6a 00                	push   $0x0
  8024f3:	e8 bc e8 ff ff       	call   800db4 <sys_page_alloc>
  8024f8:	83 c4 10             	add    $0x10,%esp
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	78 21                	js     802520 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8024ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802502:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802508:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80250a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80250d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802514:	83 ec 0c             	sub    $0xc,%esp
  802517:	50                   	push   %eax
  802518:	e8 bd ed ff ff       	call   8012da <fd2num>
  80251d:	83 c4 10             	add    $0x10,%esp
}
  802520:	c9                   	leave  
  802521:	c3                   	ret    

00802522 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802522:	f3 0f 1e fb          	endbr32 
  802526:	55                   	push   %ebp
  802527:	89 e5                	mov    %esp,%ebp
  802529:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80252c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802533:	74 0a                	je     80253f <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802535:	8b 45 08             	mov    0x8(%ebp),%eax
  802538:	a3 00 70 80 00       	mov    %eax,0x807000

}
  80253d:	c9                   	leave  
  80253e:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  80253f:	83 ec 04             	sub    $0x4,%esp
  802542:	6a 07                	push   $0x7
  802544:	68 00 f0 bf ee       	push   $0xeebff000
  802549:	6a 00                	push   $0x0
  80254b:	e8 64 e8 ff ff       	call   800db4 <sys_page_alloc>
  802550:	83 c4 10             	add    $0x10,%esp
  802553:	85 c0                	test   %eax,%eax
  802555:	78 2a                	js     802581 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802557:	83 ec 08             	sub    $0x8,%esp
  80255a:	68 95 25 80 00       	push   $0x802595
  80255f:	6a 00                	push   $0x0
  802561:	e8 08 e9 ff ff       	call   800e6e <sys_env_set_pgfault_upcall>
  802566:	83 c4 10             	add    $0x10,%esp
  802569:	85 c0                	test   %eax,%eax
  80256b:	79 c8                	jns    802535 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  80256d:	83 ec 04             	sub    $0x4,%esp
  802570:	68 08 2f 80 00       	push   $0x802f08
  802575:	6a 2c                	push   $0x2c
  802577:	68 3e 2f 80 00       	push   $0x802f3e
  80257c:	e8 d9 dc ff ff       	call   80025a <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802581:	83 ec 04             	sub    $0x4,%esp
  802584:	68 dc 2e 80 00       	push   $0x802edc
  802589:	6a 22                	push   $0x22
  80258b:	68 3e 2f 80 00       	push   $0x802f3e
  802590:	e8 c5 dc ff ff       	call   80025a <_panic>

00802595 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802595:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802596:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  80259b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80259d:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  8025a0:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  8025a4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  8025a9:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  8025ad:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  8025af:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  8025b2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  8025b3:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  8025b6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  8025b7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  8025b8:	c3                   	ret    
  8025b9:	66 90                	xchg   %ax,%ax
  8025bb:	66 90                	xchg   %ax,%ax
  8025bd:	66 90                	xchg   %ax,%ax
  8025bf:	90                   	nop

008025c0 <__udivdi3>:
  8025c0:	f3 0f 1e fb          	endbr32 
  8025c4:	55                   	push   %ebp
  8025c5:	57                   	push   %edi
  8025c6:	56                   	push   %esi
  8025c7:	53                   	push   %ebx
  8025c8:	83 ec 1c             	sub    $0x1c,%esp
  8025cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8025d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8025db:	85 d2                	test   %edx,%edx
  8025dd:	75 19                	jne    8025f8 <__udivdi3+0x38>
  8025df:	39 f3                	cmp    %esi,%ebx
  8025e1:	76 4d                	jbe    802630 <__udivdi3+0x70>
  8025e3:	31 ff                	xor    %edi,%edi
  8025e5:	89 e8                	mov    %ebp,%eax
  8025e7:	89 f2                	mov    %esi,%edx
  8025e9:	f7 f3                	div    %ebx
  8025eb:	89 fa                	mov    %edi,%edx
  8025ed:	83 c4 1c             	add    $0x1c,%esp
  8025f0:	5b                   	pop    %ebx
  8025f1:	5e                   	pop    %esi
  8025f2:	5f                   	pop    %edi
  8025f3:	5d                   	pop    %ebp
  8025f4:	c3                   	ret    
  8025f5:	8d 76 00             	lea    0x0(%esi),%esi
  8025f8:	39 f2                	cmp    %esi,%edx
  8025fa:	76 14                	jbe    802610 <__udivdi3+0x50>
  8025fc:	31 ff                	xor    %edi,%edi
  8025fe:	31 c0                	xor    %eax,%eax
  802600:	89 fa                	mov    %edi,%edx
  802602:	83 c4 1c             	add    $0x1c,%esp
  802605:	5b                   	pop    %ebx
  802606:	5e                   	pop    %esi
  802607:	5f                   	pop    %edi
  802608:	5d                   	pop    %ebp
  802609:	c3                   	ret    
  80260a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802610:	0f bd fa             	bsr    %edx,%edi
  802613:	83 f7 1f             	xor    $0x1f,%edi
  802616:	75 48                	jne    802660 <__udivdi3+0xa0>
  802618:	39 f2                	cmp    %esi,%edx
  80261a:	72 06                	jb     802622 <__udivdi3+0x62>
  80261c:	31 c0                	xor    %eax,%eax
  80261e:	39 eb                	cmp    %ebp,%ebx
  802620:	77 de                	ja     802600 <__udivdi3+0x40>
  802622:	b8 01 00 00 00       	mov    $0x1,%eax
  802627:	eb d7                	jmp    802600 <__udivdi3+0x40>
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	89 d9                	mov    %ebx,%ecx
  802632:	85 db                	test   %ebx,%ebx
  802634:	75 0b                	jne    802641 <__udivdi3+0x81>
  802636:	b8 01 00 00 00       	mov    $0x1,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	f7 f3                	div    %ebx
  80263f:	89 c1                	mov    %eax,%ecx
  802641:	31 d2                	xor    %edx,%edx
  802643:	89 f0                	mov    %esi,%eax
  802645:	f7 f1                	div    %ecx
  802647:	89 c6                	mov    %eax,%esi
  802649:	89 e8                	mov    %ebp,%eax
  80264b:	89 f7                	mov    %esi,%edi
  80264d:	f7 f1                	div    %ecx
  80264f:	89 fa                	mov    %edi,%edx
  802651:	83 c4 1c             	add    $0x1c,%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 f9                	mov    %edi,%ecx
  802662:	b8 20 00 00 00       	mov    $0x20,%eax
  802667:	29 f8                	sub    %edi,%eax
  802669:	d3 e2                	shl    %cl,%edx
  80266b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80266f:	89 c1                	mov    %eax,%ecx
  802671:	89 da                	mov    %ebx,%edx
  802673:	d3 ea                	shr    %cl,%edx
  802675:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802679:	09 d1                	or     %edx,%ecx
  80267b:	89 f2                	mov    %esi,%edx
  80267d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802681:	89 f9                	mov    %edi,%ecx
  802683:	d3 e3                	shl    %cl,%ebx
  802685:	89 c1                	mov    %eax,%ecx
  802687:	d3 ea                	shr    %cl,%edx
  802689:	89 f9                	mov    %edi,%ecx
  80268b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80268f:	89 eb                	mov    %ebp,%ebx
  802691:	d3 e6                	shl    %cl,%esi
  802693:	89 c1                	mov    %eax,%ecx
  802695:	d3 eb                	shr    %cl,%ebx
  802697:	09 de                	or     %ebx,%esi
  802699:	89 f0                	mov    %esi,%eax
  80269b:	f7 74 24 08          	divl   0x8(%esp)
  80269f:	89 d6                	mov    %edx,%esi
  8026a1:	89 c3                	mov    %eax,%ebx
  8026a3:	f7 64 24 0c          	mull   0xc(%esp)
  8026a7:	39 d6                	cmp    %edx,%esi
  8026a9:	72 15                	jb     8026c0 <__udivdi3+0x100>
  8026ab:	89 f9                	mov    %edi,%ecx
  8026ad:	d3 e5                	shl    %cl,%ebp
  8026af:	39 c5                	cmp    %eax,%ebp
  8026b1:	73 04                	jae    8026b7 <__udivdi3+0xf7>
  8026b3:	39 d6                	cmp    %edx,%esi
  8026b5:	74 09                	je     8026c0 <__udivdi3+0x100>
  8026b7:	89 d8                	mov    %ebx,%eax
  8026b9:	31 ff                	xor    %edi,%edi
  8026bb:	e9 40 ff ff ff       	jmp    802600 <__udivdi3+0x40>
  8026c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8026c3:	31 ff                	xor    %edi,%edi
  8026c5:	e9 36 ff ff ff       	jmp    802600 <__udivdi3+0x40>
  8026ca:	66 90                	xchg   %ax,%ax
  8026cc:	66 90                	xchg   %ax,%ax
  8026ce:	66 90                	xchg   %ax,%ax

008026d0 <__umoddi3>:
  8026d0:	f3 0f 1e fb          	endbr32 
  8026d4:	55                   	push   %ebp
  8026d5:	57                   	push   %edi
  8026d6:	56                   	push   %esi
  8026d7:	53                   	push   %ebx
  8026d8:	83 ec 1c             	sub    $0x1c,%esp
  8026db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8026df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8026e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8026e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026eb:	85 c0                	test   %eax,%eax
  8026ed:	75 19                	jne    802708 <__umoddi3+0x38>
  8026ef:	39 df                	cmp    %ebx,%edi
  8026f1:	76 5d                	jbe    802750 <__umoddi3+0x80>
  8026f3:	89 f0                	mov    %esi,%eax
  8026f5:	89 da                	mov    %ebx,%edx
  8026f7:	f7 f7                	div    %edi
  8026f9:	89 d0                	mov    %edx,%eax
  8026fb:	31 d2                	xor    %edx,%edx
  8026fd:	83 c4 1c             	add    $0x1c,%esp
  802700:	5b                   	pop    %ebx
  802701:	5e                   	pop    %esi
  802702:	5f                   	pop    %edi
  802703:	5d                   	pop    %ebp
  802704:	c3                   	ret    
  802705:	8d 76 00             	lea    0x0(%esi),%esi
  802708:	89 f2                	mov    %esi,%edx
  80270a:	39 d8                	cmp    %ebx,%eax
  80270c:	76 12                	jbe    802720 <__umoddi3+0x50>
  80270e:	89 f0                	mov    %esi,%eax
  802710:	89 da                	mov    %ebx,%edx
  802712:	83 c4 1c             	add    $0x1c,%esp
  802715:	5b                   	pop    %ebx
  802716:	5e                   	pop    %esi
  802717:	5f                   	pop    %edi
  802718:	5d                   	pop    %ebp
  802719:	c3                   	ret    
  80271a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802720:	0f bd e8             	bsr    %eax,%ebp
  802723:	83 f5 1f             	xor    $0x1f,%ebp
  802726:	75 50                	jne    802778 <__umoddi3+0xa8>
  802728:	39 d8                	cmp    %ebx,%eax
  80272a:	0f 82 e0 00 00 00    	jb     802810 <__umoddi3+0x140>
  802730:	89 d9                	mov    %ebx,%ecx
  802732:	39 f7                	cmp    %esi,%edi
  802734:	0f 86 d6 00 00 00    	jbe    802810 <__umoddi3+0x140>
  80273a:	89 d0                	mov    %edx,%eax
  80273c:	89 ca                	mov    %ecx,%edx
  80273e:	83 c4 1c             	add    $0x1c,%esp
  802741:	5b                   	pop    %ebx
  802742:	5e                   	pop    %esi
  802743:	5f                   	pop    %edi
  802744:	5d                   	pop    %ebp
  802745:	c3                   	ret    
  802746:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80274d:	8d 76 00             	lea    0x0(%esi),%esi
  802750:	89 fd                	mov    %edi,%ebp
  802752:	85 ff                	test   %edi,%edi
  802754:	75 0b                	jne    802761 <__umoddi3+0x91>
  802756:	b8 01 00 00 00       	mov    $0x1,%eax
  80275b:	31 d2                	xor    %edx,%edx
  80275d:	f7 f7                	div    %edi
  80275f:	89 c5                	mov    %eax,%ebp
  802761:	89 d8                	mov    %ebx,%eax
  802763:	31 d2                	xor    %edx,%edx
  802765:	f7 f5                	div    %ebp
  802767:	89 f0                	mov    %esi,%eax
  802769:	f7 f5                	div    %ebp
  80276b:	89 d0                	mov    %edx,%eax
  80276d:	31 d2                	xor    %edx,%edx
  80276f:	eb 8c                	jmp    8026fd <__umoddi3+0x2d>
  802771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	ba 20 00 00 00       	mov    $0x20,%edx
  80277f:	29 ea                	sub    %ebp,%edx
  802781:	d3 e0                	shl    %cl,%eax
  802783:	89 44 24 08          	mov    %eax,0x8(%esp)
  802787:	89 d1                	mov    %edx,%ecx
  802789:	89 f8                	mov    %edi,%eax
  80278b:	d3 e8                	shr    %cl,%eax
  80278d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802791:	89 54 24 04          	mov    %edx,0x4(%esp)
  802795:	8b 54 24 04          	mov    0x4(%esp),%edx
  802799:	09 c1                	or     %eax,%ecx
  80279b:	89 d8                	mov    %ebx,%eax
  80279d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027a1:	89 e9                	mov    %ebp,%ecx
  8027a3:	d3 e7                	shl    %cl,%edi
  8027a5:	89 d1                	mov    %edx,%ecx
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027af:	d3 e3                	shl    %cl,%ebx
  8027b1:	89 c7                	mov    %eax,%edi
  8027b3:	89 d1                	mov    %edx,%ecx
  8027b5:	89 f0                	mov    %esi,%eax
  8027b7:	d3 e8                	shr    %cl,%eax
  8027b9:	89 e9                	mov    %ebp,%ecx
  8027bb:	89 fa                	mov    %edi,%edx
  8027bd:	d3 e6                	shl    %cl,%esi
  8027bf:	09 d8                	or     %ebx,%eax
  8027c1:	f7 74 24 08          	divl   0x8(%esp)
  8027c5:	89 d1                	mov    %edx,%ecx
  8027c7:	89 f3                	mov    %esi,%ebx
  8027c9:	f7 64 24 0c          	mull   0xc(%esp)
  8027cd:	89 c6                	mov    %eax,%esi
  8027cf:	89 d7                	mov    %edx,%edi
  8027d1:	39 d1                	cmp    %edx,%ecx
  8027d3:	72 06                	jb     8027db <__umoddi3+0x10b>
  8027d5:	75 10                	jne    8027e7 <__umoddi3+0x117>
  8027d7:	39 c3                	cmp    %eax,%ebx
  8027d9:	73 0c                	jae    8027e7 <__umoddi3+0x117>
  8027db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8027df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8027e3:	89 d7                	mov    %edx,%edi
  8027e5:	89 c6                	mov    %eax,%esi
  8027e7:	89 ca                	mov    %ecx,%edx
  8027e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027ee:	29 f3                	sub    %esi,%ebx
  8027f0:	19 fa                	sbb    %edi,%edx
  8027f2:	89 d0                	mov    %edx,%eax
  8027f4:	d3 e0                	shl    %cl,%eax
  8027f6:	89 e9                	mov    %ebp,%ecx
  8027f8:	d3 eb                	shr    %cl,%ebx
  8027fa:	d3 ea                	shr    %cl,%edx
  8027fc:	09 d8                	or     %ebx,%eax
  8027fe:	83 c4 1c             	add    $0x1c,%esp
  802801:	5b                   	pop    %ebx
  802802:	5e                   	pop    %esi
  802803:	5f                   	pop    %edi
  802804:	5d                   	pop    %ebp
  802805:	c3                   	ret    
  802806:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80280d:	8d 76 00             	lea    0x0(%esi),%esi
  802810:	29 fe                	sub    %edi,%esi
  802812:	19 c3                	sbb    %eax,%ebx
  802814:	89 f2                	mov    %esi,%edx
  802816:	89 d9                	mov    %ebx,%ecx
  802818:	e9 1d ff ff ff       	jmp    80273a <__umoddi3+0x6a>
