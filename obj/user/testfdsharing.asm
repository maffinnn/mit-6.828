
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 9d 01 00 00       	call   8001ce <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  800040:	6a 00                	push   $0x0
  800042:	68 60 28 80 00       	push   $0x802860
  800047:	e8 10 19 00 00       	call   80195c <open>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	85 c0                	test   %eax,%eax
  800053:	0f 88 ff 00 00 00    	js     800158 <umain+0x125>
		panic("open motd: %e", fd);
	seek(fd, 0);
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	6a 00                	push   $0x0
  80005e:	50                   	push   %eax
  80005f:	e8 b9 15 00 00       	call   80161d <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800064:	83 c4 0c             	add    $0xc,%esp
  800067:	68 00 02 00 00       	push   $0x200
  80006c:	68 20 42 80 00       	push   $0x804220
  800071:	53                   	push   %ebx
  800072:	e8 d5 14 00 00       	call   80154c <readn>
  800077:	89 c6                	mov    %eax,%esi
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	0f 8e e6 00 00 00    	jle    80016a <umain+0x137>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800084:	e8 9a 0f 00 00       	call   801023 <fork>
  800089:	89 c7                	mov    %eax,%edi
  80008b:	85 c0                	test   %eax,%eax
  80008d:	0f 88 e9 00 00 00    	js     80017c <umain+0x149>
		panic("fork: %e", r);
	if (r == 0) {
  800093:	75 7b                	jne    800110 <umain+0xdd>
		seek(fd, 0);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	6a 00                	push   $0x0
  80009a:	53                   	push   %ebx
  80009b:	e8 7d 15 00 00       	call   80161d <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000a0:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  8000a7:	e8 71 02 00 00       	call   80031d <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000ac:	83 c4 0c             	add    $0xc,%esp
  8000af:	68 00 02 00 00       	push   $0x200
  8000b4:	68 20 40 80 00       	push   $0x804020
  8000b9:	53                   	push   %ebx
  8000ba:	e8 8d 14 00 00       	call   80154c <readn>
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	39 c6                	cmp    %eax,%esi
  8000c4:	0f 85 c4 00 00 00    	jne    80018e <umain+0x15b>
			panic("read in parent got %d, read in child got %d", n, n2);
		if (memcmp(buf, buf2, n) != 0)
  8000ca:	83 ec 04             	sub    $0x4,%esp
  8000cd:	56                   	push   %esi
  8000ce:	68 20 40 80 00       	push   $0x804020
  8000d3:	68 20 42 80 00       	push   $0x804220
  8000d8:	e8 c8 0a 00 00       	call   800ba5 <memcmp>
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	0f 85 bc 00 00 00    	jne    8001a4 <umain+0x171>
			panic("read in parent got different bytes from read in child");
		cprintf("read in child succeeded\n");
  8000e8:	83 ec 0c             	sub    $0xc,%esp
  8000eb:	68 9b 28 80 00       	push   $0x80289b
  8000f0:	e8 28 02 00 00       	call   80031d <cprintf>
		seek(fd, 0);
  8000f5:	83 c4 08             	add    $0x8,%esp
  8000f8:	6a 00                	push   $0x0
  8000fa:	53                   	push   %ebx
  8000fb:	e8 1d 15 00 00       	call   80161d <seek>
		close(fd);
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 6f 12 00 00       	call   801377 <close>
		exit();
  800108:	e8 0b 01 00 00       	call   800218 <exit>
  80010d:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	57                   	push   %edi
  800114:	e8 0e 21 00 00       	call   802227 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800119:	83 c4 0c             	add    $0xc,%esp
  80011c:	68 00 02 00 00       	push   $0x200
  800121:	68 20 40 80 00       	push   $0x804020
  800126:	53                   	push   %ebx
  800127:	e8 20 14 00 00       	call   80154c <readn>
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	39 c6                	cmp    %eax,%esi
  800131:	0f 85 81 00 00 00    	jne    8001b8 <umain+0x185>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	68 b4 28 80 00       	push   $0x8028b4
  80013f:	e8 d9 01 00 00       	call   80031d <cprintf>
	close(fd);
  800144:	89 1c 24             	mov    %ebx,(%esp)
  800147:	e8 2b 12 00 00       	call   801377 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80014c:	cc                   	int3   

	breakpoint();
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    
		panic("open motd: %e", fd);
  800158:	50                   	push   %eax
  800159:	68 65 28 80 00       	push   $0x802865
  80015e:	6a 0c                	push   $0xc
  800160:	68 73 28 80 00       	push   $0x802873
  800165:	e8 cc 00 00 00       	call   800236 <_panic>
		panic("readn: %e", n);
  80016a:	50                   	push   %eax
  80016b:	68 88 28 80 00       	push   $0x802888
  800170:	6a 0f                	push   $0xf
  800172:	68 73 28 80 00       	push   $0x802873
  800177:	e8 ba 00 00 00       	call   800236 <_panic>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 92 28 80 00       	push   $0x802892
  800182:	6a 12                	push   $0x12
  800184:	68 73 28 80 00       	push   $0x802873
  800189:	e8 a8 00 00 00       	call   800236 <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	56                   	push   %esi
  800193:	68 14 29 80 00       	push   $0x802914
  800198:	6a 17                	push   $0x17
  80019a:	68 73 28 80 00       	push   $0x802873
  80019f:	e8 92 00 00 00       	call   800236 <_panic>
			panic("read in parent got different bytes from read in child");
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	68 40 29 80 00       	push   $0x802940
  8001ac:	6a 19                	push   $0x19
  8001ae:	68 73 28 80 00       	push   $0x802873
  8001b3:	e8 7e 00 00 00       	call   800236 <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	56                   	push   %esi
  8001bd:	68 78 29 80 00       	push   $0x802978
  8001c2:	6a 21                	push   $0x21
  8001c4:	68 73 28 80 00       	push   $0x802873
  8001c9:	e8 68 00 00 00       	call   800236 <_panic>

008001ce <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ce:	f3 0f 1e fb          	endbr32 
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001dd:	e8 68 0b 00 00       	call   800d4a <sys_getenvid>
  8001e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ef:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7e 07                	jle    8001ff <libmain+0x31>
		binaryname = argv[0];
  8001f8:	8b 06                	mov    (%esi),%eax
  8001fa:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	e8 2a fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800209:	e8 0a 00 00 00       	call   800218 <exit>
}
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800218:	f3 0f 1e fb          	endbr32 
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800222:	e8 81 11 00 00       	call   8013a8 <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 f5 0a 00 00       	call   800d26 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	f3 0f 1e fb          	endbr32 
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800242:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800248:	e8 fd 0a 00 00       	call   800d4a <sys_getenvid>
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	56                   	push   %esi
  800257:	50                   	push   %eax
  800258:	68 a8 29 80 00       	push   $0x8029a8
  80025d:	e8 bb 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800262:	83 c4 18             	add    $0x18,%esp
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	e8 5a 00 00 00       	call   8002c8 <vcprintf>
	cprintf("\n");
  80026e:	c7 04 24 b2 28 80 00 	movl   $0x8028b2,(%esp)
  800275:	e8 a3 00 00 00       	call   80031d <cprintf>
  80027a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027d:	cc                   	int3   
  80027e:	eb fd                	jmp    80027d <_panic+0x47>

00800280 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800280:	f3 0f 1e fb          	endbr32 
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	53                   	push   %ebx
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028e:	8b 13                	mov    (%ebx),%edx
  800290:	8d 42 01             	lea    0x1(%edx),%eax
  800293:	89 03                	mov    %eax,(%ebx)
  800295:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800298:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80029c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a1:	74 09                	je     8002ac <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	68 ff 00 00 00       	push   $0xff
  8002b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b7:	50                   	push   %eax
  8002b8:	e8 24 0a 00 00       	call   800ce1 <sys_cputs>
		b->idx = 0;
  8002bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c3:	83 c4 10             	add    $0x10,%esp
  8002c6:	eb db                	jmp    8002a3 <putch+0x23>

008002c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c8:	f3 0f 1e fb          	endbr32 
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 80 02 80 00       	push   $0x800280
  8002fb:	e8 20 01 00 00       	call   800420 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 cc 09 00 00       	call   800ce1 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	f3 0f 1e fb          	endbr32 
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800327:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80032a:	50                   	push   %eax
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	e8 95 ff ff ff       	call   8002c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 1c             	sub    $0x1c,%esp
  80033e:	89 c7                	mov    %eax,%edi
  800340:	89 d6                	mov    %edx,%esi
  800342:	8b 45 08             	mov    0x8(%ebp),%eax
  800345:	8b 55 0c             	mov    0xc(%ebp),%edx
  800348:	89 d1                	mov    %edx,%ecx
  80034a:	89 c2                	mov    %eax,%edx
  80034c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800352:	8b 45 10             	mov    0x10(%ebp),%eax
  800355:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800358:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800362:	39 c2                	cmp    %eax,%edx
  800364:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800367:	72 3e                	jb     8003a7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800369:	83 ec 0c             	sub    $0xc,%esp
  80036c:	ff 75 18             	pushl  0x18(%ebp)
  80036f:	83 eb 01             	sub    $0x1,%ebx
  800372:	53                   	push   %ebx
  800373:	50                   	push   %eax
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	ff 75 e4             	pushl  -0x1c(%ebp)
  80037a:	ff 75 e0             	pushl  -0x20(%ebp)
  80037d:	ff 75 dc             	pushl  -0x24(%ebp)
  800380:	ff 75 d8             	pushl  -0x28(%ebp)
  800383:	e8 68 22 00 00       	call   8025f0 <__udivdi3>
  800388:	83 c4 18             	add    $0x18,%esp
  80038b:	52                   	push   %edx
  80038c:	50                   	push   %eax
  80038d:	89 f2                	mov    %esi,%edx
  80038f:	89 f8                	mov    %edi,%eax
  800391:	e8 9f ff ff ff       	call   800335 <printnum>
  800396:	83 c4 20             	add    $0x20,%esp
  800399:	eb 13                	jmp    8003ae <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	56                   	push   %esi
  80039f:	ff 75 18             	pushl  0x18(%ebp)
  8003a2:	ff d7                	call   *%edi
  8003a4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003a7:	83 eb 01             	sub    $0x1,%ebx
  8003aa:	85 db                	test   %ebx,%ebx
  8003ac:	7f ed                	jg     80039b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	56                   	push   %esi
  8003b2:	83 ec 04             	sub    $0x4,%esp
  8003b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8003be:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c1:	e8 3a 23 00 00       	call   802700 <__umoddi3>
  8003c6:	83 c4 14             	add    $0x14,%esp
  8003c9:	0f be 80 cb 29 80 00 	movsbl 0x8029cb(%eax),%eax
  8003d0:	50                   	push   %eax
  8003d1:	ff d7                	call   *%edi
}
  8003d3:	83 c4 10             	add    $0x10,%esp
  8003d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d9:	5b                   	pop    %ebx
  8003da:	5e                   	pop    %esi
  8003db:	5f                   	pop    %edi
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003de:	f3 0f 1e fb          	endbr32 
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f1:	73 0a                	jae    8003fd <sprintputch+0x1f>
		*b->buf++ = ch;
  8003f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	88 02                	mov    %al,(%edx)
}
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <printfmt>:
{
  8003ff:	f3 0f 1e fb          	endbr32 
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800409:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 10             	pushl  0x10(%ebp)
  800410:	ff 75 0c             	pushl  0xc(%ebp)
  800413:	ff 75 08             	pushl  0x8(%ebp)
  800416:	e8 05 00 00 00       	call   800420 <vprintfmt>
}
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <vprintfmt>:
{
  800420:	f3 0f 1e fb          	endbr32 
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 3c             	sub    $0x3c,%esp
  80042d:	8b 75 08             	mov    0x8(%ebp),%esi
  800430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800433:	8b 7d 10             	mov    0x10(%ebp),%edi
  800436:	e9 8e 03 00 00       	jmp    8007c9 <vprintfmt+0x3a9>
		padc = ' ';
  80043b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80043f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800446:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80044d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8d 47 01             	lea    0x1(%edi),%eax
  80045c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045f:	0f b6 17             	movzbl (%edi),%edx
  800462:	8d 42 dd             	lea    -0x23(%edx),%eax
  800465:	3c 55                	cmp    $0x55,%al
  800467:	0f 87 df 03 00 00    	ja     80084c <vprintfmt+0x42c>
  80046d:	0f b6 c0             	movzbl %al,%eax
  800470:	3e ff 24 85 00 2b 80 	notrack jmp *0x802b00(,%eax,4)
  800477:	00 
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80047b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80047f:	eb d8                	jmp    800459 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800484:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800488:	eb cf                	jmp    800459 <vprintfmt+0x39>
  80048a:	0f b6 d2             	movzbl %dl,%edx
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800498:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80049f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a5:	83 f9 09             	cmp    $0x9,%ecx
  8004a8:	77 55                	ja     8004ff <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8004ad:	eb e9                	jmp    800498 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 40 04             	lea    0x4(%eax),%eax
  8004bd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c7:	79 90                	jns    800459 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cf:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004d6:	eb 81                	jmp    800459 <vprintfmt+0x39>
  8004d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	0f 49 d0             	cmovns %eax,%edx
  8004e5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004eb:	e9 69 ff ff ff       	jmp    800459 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004fa:	e9 5a ff ff ff       	jmp    800459 <vprintfmt+0x39>
  8004ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800505:	eb bc                	jmp    8004c3 <vprintfmt+0xa3>
			lflag++;
  800507:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80050d:	e9 47 ff ff ff       	jmp    800459 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 78 04             	lea    0x4(%eax),%edi
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	ff 30                	pushl  (%eax)
  80051e:	ff d6                	call   *%esi
			break;
  800520:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800523:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800526:	e9 9b 02 00 00       	jmp    8007c6 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 78 04             	lea    0x4(%eax),%edi
  800531:	8b 00                	mov    (%eax),%eax
  800533:	99                   	cltd   
  800534:	31 d0                	xor    %edx,%eax
  800536:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800538:	83 f8 0f             	cmp    $0xf,%eax
  80053b:	7f 23                	jg     800560 <vprintfmt+0x140>
  80053d:	8b 14 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%edx
  800544:	85 d2                	test   %edx,%edx
  800546:	74 18                	je     800560 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800548:	52                   	push   %edx
  800549:	68 65 2e 80 00       	push   $0x802e65
  80054e:	53                   	push   %ebx
  80054f:	56                   	push   %esi
  800550:	e8 aa fe ff ff       	call   8003ff <printfmt>
  800555:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800558:	89 7d 14             	mov    %edi,0x14(%ebp)
  80055b:	e9 66 02 00 00       	jmp    8007c6 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800560:	50                   	push   %eax
  800561:	68 e3 29 80 00       	push   $0x8029e3
  800566:	53                   	push   %ebx
  800567:	56                   	push   %esi
  800568:	e8 92 fe ff ff       	call   8003ff <printfmt>
  80056d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800570:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800573:	e9 4e 02 00 00       	jmp    8007c6 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	83 c0 04             	add    $0x4,%eax
  80057e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800586:	85 d2                	test   %edx,%edx
  800588:	b8 dc 29 80 00       	mov    $0x8029dc,%eax
  80058d:	0f 45 c2             	cmovne %edx,%eax
  800590:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800593:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800597:	7e 06                	jle    80059f <vprintfmt+0x17f>
  800599:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80059d:	75 0d                	jne    8005ac <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a2:	89 c7                	mov    %eax,%edi
  8005a4:	03 45 e0             	add    -0x20(%ebp),%eax
  8005a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005aa:	eb 55                	jmp    800601 <vprintfmt+0x1e1>
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b2:	ff 75 cc             	pushl  -0x34(%ebp)
  8005b5:	e8 46 03 00 00       	call   800900 <strnlen>
  8005ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005bd:	29 c2                	sub    %eax,%edx
  8005bf:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005c7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ce:	85 ff                	test   %edi,%edi
  8005d0:	7e 11                	jle    8005e3 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	83 ef 01             	sub    $0x1,%edi
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	eb eb                	jmp    8005ce <vprintfmt+0x1ae>
  8005e3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ed:	0f 49 c2             	cmovns %edx,%eax
  8005f0:	29 c2                	sub    %eax,%edx
  8005f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f5:	eb a8                	jmp    80059f <vprintfmt+0x17f>
					putch(ch, putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	52                   	push   %edx
  8005fc:	ff d6                	call   *%esi
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800604:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	83 c7 01             	add    $0x1,%edi
  800609:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060d:	0f be d0             	movsbl %al,%edx
  800610:	85 d2                	test   %edx,%edx
  800612:	74 4b                	je     80065f <vprintfmt+0x23f>
  800614:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800618:	78 06                	js     800620 <vprintfmt+0x200>
  80061a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80061e:	78 1e                	js     80063e <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800620:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800624:	74 d1                	je     8005f7 <vprintfmt+0x1d7>
  800626:	0f be c0             	movsbl %al,%eax
  800629:	83 e8 20             	sub    $0x20,%eax
  80062c:	83 f8 5e             	cmp    $0x5e,%eax
  80062f:	76 c6                	jbe    8005f7 <vprintfmt+0x1d7>
					putch('?', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 3f                	push   $0x3f
  800637:	ff d6                	call   *%esi
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb c3                	jmp    800601 <vprintfmt+0x1e1>
  80063e:	89 cf                	mov    %ecx,%edi
  800640:	eb 0e                	jmp    800650 <vprintfmt+0x230>
				putch(' ', putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	6a 20                	push   $0x20
  800648:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80064a:	83 ef 01             	sub    $0x1,%edi
  80064d:	83 c4 10             	add    $0x10,%esp
  800650:	85 ff                	test   %edi,%edi
  800652:	7f ee                	jg     800642 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800654:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
  80065a:	e9 67 01 00 00       	jmp    8007c6 <vprintfmt+0x3a6>
  80065f:	89 cf                	mov    %ecx,%edi
  800661:	eb ed                	jmp    800650 <vprintfmt+0x230>
	if (lflag >= 2)
  800663:	83 f9 01             	cmp    $0x1,%ecx
  800666:	7f 1b                	jg     800683 <vprintfmt+0x263>
	else if (lflag)
  800668:	85 c9                	test   %ecx,%ecx
  80066a:	74 63                	je     8006cf <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	99                   	cltd   
  800675:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
  800681:	eb 17                	jmp    80069a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 50 04             	mov    0x4(%eax),%edx
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 40 08             	lea    0x8(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80069a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006a5:	85 c9                	test   %ecx,%ecx
  8006a7:	0f 89 ff 00 00 00    	jns    8007ac <vprintfmt+0x38c>
				putch('-', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 2d                	push   $0x2d
  8006b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bb:	f7 da                	neg    %edx
  8006bd:	83 d1 00             	adc    $0x0,%ecx
  8006c0:	f7 d9                	neg    %ecx
  8006c2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	e9 dd 00 00 00       	jmp    8007ac <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d7:	99                   	cltd   
  8006d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 40 04             	lea    0x4(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e4:	eb b4                	jmp    80069a <vprintfmt+0x27a>
	if (lflag >= 2)
  8006e6:	83 f9 01             	cmp    $0x1,%ecx
  8006e9:	7f 1e                	jg     800709 <vprintfmt+0x2e9>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	74 32                	je     800721 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ff:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800704:	e9 a3 00 00 00       	jmp    8007ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 10                	mov    (%eax),%edx
  80070e:	8b 48 04             	mov    0x4(%eax),%ecx
  800711:	8d 40 08             	lea    0x8(%eax),%eax
  800714:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800717:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80071c:	e9 8b 00 00 00       	jmp    8007ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800731:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800736:	eb 74                	jmp    8007ac <vprintfmt+0x38c>
	if (lflag >= 2)
  800738:	83 f9 01             	cmp    $0x1,%ecx
  80073b:	7f 1b                	jg     800758 <vprintfmt+0x338>
	else if (lflag)
  80073d:	85 c9                	test   %ecx,%ecx
  80073f:	74 2c                	je     80076d <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 10                	mov    (%eax),%edx
  800746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074b:	8d 40 04             	lea    0x4(%eax),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800751:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800756:	eb 54                	jmp    8007ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	8b 48 04             	mov    0x4(%eax),%ecx
  800760:	8d 40 08             	lea    0x8(%eax),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800766:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80076b:	eb 3f                	jmp    8007ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8b 10                	mov    (%eax),%edx
  800772:	b9 00 00 00 00       	mov    $0x0,%ecx
  800777:	8d 40 04             	lea    0x4(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80077d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800782:	eb 28                	jmp    8007ac <vprintfmt+0x38c>
			putch('0', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 30                	push   $0x30
  80078a:	ff d6                	call   *%esi
			putch('x', putdat);
  80078c:	83 c4 08             	add    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 78                	push   $0x78
  800792:	ff d6                	call   *%esi
			num = (unsigned long long)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8b 10                	mov    (%eax),%edx
  800799:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80079e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007a1:	8d 40 04             	lea    0x4(%eax),%eax
  8007a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007ac:	83 ec 0c             	sub    $0xc,%esp
  8007af:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8007b3:	57                   	push   %edi
  8007b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b7:	50                   	push   %eax
  8007b8:	51                   	push   %ecx
  8007b9:	52                   	push   %edx
  8007ba:	89 da                	mov    %ebx,%edx
  8007bc:	89 f0                	mov    %esi,%eax
  8007be:	e8 72 fb ff ff       	call   800335 <printnum>
			break;
  8007c3:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8007c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8007c9:	83 c7 01             	add    $0x1,%edi
  8007cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007d0:	83 f8 25             	cmp    $0x25,%eax
  8007d3:	0f 84 62 fc ff ff    	je     80043b <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	0f 84 8b 00 00 00    	je     80086c <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8007e1:	83 ec 08             	sub    $0x8,%esp
  8007e4:	53                   	push   %ebx
  8007e5:	50                   	push   %eax
  8007e6:	ff d6                	call   *%esi
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	eb dc                	jmp    8007c9 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8007ed:	83 f9 01             	cmp    $0x1,%ecx
  8007f0:	7f 1b                	jg     80080d <vprintfmt+0x3ed>
	else if (lflag)
  8007f2:	85 c9                	test   %ecx,%ecx
  8007f4:	74 2c                	je     800822 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800800:	8d 40 04             	lea    0x4(%eax),%eax
  800803:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800806:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80080b:	eb 9f                	jmp    8007ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80080d:	8b 45 14             	mov    0x14(%ebp),%eax
  800810:	8b 10                	mov    (%eax),%edx
  800812:	8b 48 04             	mov    0x4(%eax),%ecx
  800815:	8d 40 08             	lea    0x8(%eax),%eax
  800818:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80081b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800820:	eb 8a                	jmp    8007ac <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082c:	8d 40 04             	lea    0x4(%eax),%eax
  80082f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800832:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800837:	e9 70 ff ff ff       	jmp    8007ac <vprintfmt+0x38c>
			putch(ch, putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 25                	push   $0x25
  800842:	ff d6                	call   *%esi
			break;
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	e9 7a ff ff ff       	jmp    8007c6 <vprintfmt+0x3a6>
			putch('%', putdat);
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	53                   	push   %ebx
  800850:	6a 25                	push   $0x25
  800852:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	89 f8                	mov    %edi,%eax
  800859:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80085d:	74 05                	je     800864 <vprintfmt+0x444>
  80085f:	83 e8 01             	sub    $0x1,%eax
  800862:	eb f5                	jmp    800859 <vprintfmt+0x439>
  800864:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800867:	e9 5a ff ff ff       	jmp    8007c6 <vprintfmt+0x3a6>
}
  80086c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5f                   	pop    %edi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800874:	f3 0f 1e fb          	endbr32 
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 18             	sub    $0x18,%esp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800884:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800887:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800895:	85 c0                	test   %eax,%eax
  800897:	74 26                	je     8008bf <vsnprintf+0x4b>
  800899:	85 d2                	test   %edx,%edx
  80089b:	7e 22                	jle    8008bf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089d:	ff 75 14             	pushl  0x14(%ebp)
  8008a0:	ff 75 10             	pushl  0x10(%ebp)
  8008a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a6:	50                   	push   %eax
  8008a7:	68 de 03 80 00       	push   $0x8003de
  8008ac:	e8 6f fb ff ff       	call   800420 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ba:	83 c4 10             	add    $0x10,%esp
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    
		return -E_INVAL;
  8008bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c4:	eb f7                	jmp    8008bd <vsnprintf+0x49>

008008c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c6:	f3 0f 1e fb          	endbr32 
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8008d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d3:	50                   	push   %eax
  8008d4:	ff 75 10             	pushl  0x10(%ebp)
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	ff 75 08             	pushl  0x8(%ebp)
  8008dd:	e8 92 ff ff ff       	call   800874 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e4:	f3 0f 1e fb          	endbr32 
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f7:	74 05                	je     8008fe <strlen+0x1a>
		n++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	eb f5                	jmp    8008f3 <strlen+0xf>
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800900:	f3 0f 1e fb          	endbr32 
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	39 d0                	cmp    %edx,%eax
  800914:	74 0d                	je     800923 <strnlen+0x23>
  800916:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80091a:	74 05                	je     800921 <strnlen+0x21>
		n++;
  80091c:	83 c0 01             	add    $0x1,%eax
  80091f:	eb f1                	jmp    800912 <strnlen+0x12>
  800921:	89 c2                	mov    %eax,%edx
	return n;
}
  800923:	89 d0                	mov    %edx,%eax
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800927:	f3 0f 1e fb          	endbr32 
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800932:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80093e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800941:	83 c0 01             	add    $0x1,%eax
  800944:	84 d2                	test   %dl,%dl
  800946:	75 f2                	jne    80093a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800948:	89 c8                	mov    %ecx,%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094d:	f3 0f 1e fb          	endbr32 
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	53                   	push   %ebx
  800955:	83 ec 10             	sub    $0x10,%esp
  800958:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095b:	53                   	push   %ebx
  80095c:	e8 83 ff ff ff       	call   8008e4 <strlen>
  800961:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800964:	ff 75 0c             	pushl  0xc(%ebp)
  800967:	01 d8                	add    %ebx,%eax
  800969:	50                   	push   %eax
  80096a:	e8 b8 ff ff ff       	call   800927 <strcpy>
	return dst;
}
  80096f:	89 d8                	mov    %ebx,%eax
  800971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 75 08             	mov    0x8(%ebp),%esi
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 f3                	mov    %esi,%ebx
  800987:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098a:	89 f0                	mov    %esi,%eax
  80098c:	39 d8                	cmp    %ebx,%eax
  80098e:	74 11                	je     8009a1 <strncpy+0x2b>
		*dst++ = *src;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	0f b6 0a             	movzbl (%edx),%ecx
  800996:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800999:	80 f9 01             	cmp    $0x1,%cl
  80099c:	83 da ff             	sbb    $0xffffffff,%edx
  80099f:	eb eb                	jmp    80098c <strncpy+0x16>
	}
	return ret;
}
  8009a1:	89 f0                	mov    %esi,%eax
  8009a3:	5b                   	pop    %ebx
  8009a4:	5e                   	pop    %esi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a7:	f3 0f 1e fb          	endbr32 
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8009b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bb:	85 d2                	test   %edx,%edx
  8009bd:	74 21                	je     8009e0 <strlcpy+0x39>
  8009bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009c5:	39 c2                	cmp    %eax,%edx
  8009c7:	74 14                	je     8009dd <strlcpy+0x36>
  8009c9:	0f b6 19             	movzbl (%ecx),%ebx
  8009cc:	84 db                	test   %bl,%bl
  8009ce:	74 0b                	je     8009db <strlcpy+0x34>
			*dst++ = *src++;
  8009d0:	83 c1 01             	add    $0x1,%ecx
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d9:	eb ea                	jmp    8009c5 <strlcpy+0x1e>
  8009db:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e0:	29 f0                	sub    %esi,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e6:	f3 0f 1e fb          	endbr32 
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	84 c0                	test   %al,%al
  8009f8:	74 0c                	je     800a06 <strcmp+0x20>
  8009fa:	3a 02                	cmp    (%edx),%al
  8009fc:	75 08                	jne    800a06 <strcmp+0x20>
		p++, q++;
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	eb ed                	jmp    8009f3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a06:	0f b6 c0             	movzbl %al,%eax
  800a09:	0f b6 12             	movzbl (%edx),%edx
  800a0c:	29 d0                	sub    %edx,%eax
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a10:	f3 0f 1e fb          	endbr32 
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a23:	eb 06                	jmp    800a2b <strncmp+0x1b>
		n--, p++, q++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a2b:	39 d8                	cmp    %ebx,%eax
  800a2d:	74 16                	je     800a45 <strncmp+0x35>
  800a2f:	0f b6 08             	movzbl (%eax),%ecx
  800a32:	84 c9                	test   %cl,%cl
  800a34:	74 04                	je     800a3a <strncmp+0x2a>
  800a36:	3a 0a                	cmp    (%edx),%cl
  800a38:	74 eb                	je     800a25 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3a:	0f b6 00             	movzbl (%eax),%eax
  800a3d:	0f b6 12             	movzbl (%edx),%edx
  800a40:	29 d0                	sub    %edx,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    
		return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	eb f6                	jmp    800a42 <strncmp+0x32>

00800a4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4c:	f3 0f 1e fb          	endbr32 
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5a:	0f b6 10             	movzbl (%eax),%edx
  800a5d:	84 d2                	test   %dl,%dl
  800a5f:	74 09                	je     800a6a <strchr+0x1e>
		if (*s == c)
  800a61:	38 ca                	cmp    %cl,%dl
  800a63:	74 0a                	je     800a6f <strchr+0x23>
	for (; *s; s++)
  800a65:	83 c0 01             	add    $0x1,%eax
  800a68:	eb f0                	jmp    800a5a <strchr+0xe>
			return (char *) s;
	return 0;
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800a71:	f3 0f 1e fb          	endbr32 
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800a7b:	6a 78                	push   $0x78
  800a7d:	ff 75 08             	pushl  0x8(%ebp)
  800a80:	e8 c7 ff ff ff       	call   800a4c <strchr>
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800a90:	eb 0d                	jmp    800a9f <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800a92:	c1 e0 04             	shl    $0x4,%eax
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800a9c:	83 c1 01             	add    $0x1,%ecx
  800a9f:	0f b6 11             	movzbl (%ecx),%edx
  800aa2:	84 d2                	test   %dl,%dl
  800aa4:	74 11                	je     800ab7 <atox+0x46>
		if (*p>='a'){
  800aa6:	80 fa 60             	cmp    $0x60,%dl
  800aa9:	7e e7                	jle    800a92 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800aab:	c1 e0 04             	shl    $0x4,%eax
  800aae:	0f be d2             	movsbl %dl,%edx
  800ab1:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800ab5:	eb e5                	jmp    800a9c <atox+0x2b>
	}

	return v;

}
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab9:	f3 0f 1e fb          	endbr32 
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aca:	38 ca                	cmp    %cl,%dl
  800acc:	74 09                	je     800ad7 <strfind+0x1e>
  800ace:	84 d2                	test   %dl,%dl
  800ad0:	74 05                	je     800ad7 <strfind+0x1e>
	for (; *s; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	eb f0                	jmp    800ac7 <strfind+0xe>
			break;
	return (char *) s;
}
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad9:	f3 0f 1e fb          	endbr32 
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae9:	85 c9                	test   %ecx,%ecx
  800aeb:	74 31                	je     800b1e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aed:	89 f8                	mov    %edi,%eax
  800aef:	09 c8                	or     %ecx,%eax
  800af1:	a8 03                	test   $0x3,%al
  800af3:	75 23                	jne    800b18 <memset+0x3f>
		c &= 0xFF;
  800af5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	c1 e3 08             	shl    $0x8,%ebx
  800afe:	89 d0                	mov    %edx,%eax
  800b00:	c1 e0 18             	shl    $0x18,%eax
  800b03:	89 d6                	mov    %edx,%esi
  800b05:	c1 e6 10             	shl    $0x10,%esi
  800b08:	09 f0                	or     %esi,%eax
  800b0a:	09 c2                	or     %eax,%edx
  800b0c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b0e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b11:	89 d0                	mov    %edx,%eax
  800b13:	fc                   	cld    
  800b14:	f3 ab                	rep stos %eax,%es:(%edi)
  800b16:	eb 06                	jmp    800b1e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	fc                   	cld    
  800b1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1e:	89 f8                	mov    %edi,%eax
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b25:	f3 0f 1e fb          	endbr32 
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b37:	39 c6                	cmp    %eax,%esi
  800b39:	73 32                	jae    800b6d <memmove+0x48>
  800b3b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b3e:	39 c2                	cmp    %eax,%edx
  800b40:	76 2b                	jbe    800b6d <memmove+0x48>
		s += n;
		d += n;
  800b42:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b45:	89 fe                	mov    %edi,%esi
  800b47:	09 ce                	or     %ecx,%esi
  800b49:	09 d6                	or     %edx,%esi
  800b4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b51:	75 0e                	jne    800b61 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b53:	83 ef 04             	sub    $0x4,%edi
  800b56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b59:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b5c:	fd                   	std    
  800b5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5f:	eb 09                	jmp    800b6a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b61:	83 ef 01             	sub    $0x1,%edi
  800b64:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b67:	fd                   	std    
  800b68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b6a:	fc                   	cld    
  800b6b:	eb 1a                	jmp    800b87 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6d:	89 c2                	mov    %eax,%edx
  800b6f:	09 ca                	or     %ecx,%edx
  800b71:	09 f2                	or     %esi,%edx
  800b73:	f6 c2 03             	test   $0x3,%dl
  800b76:	75 0a                	jne    800b82 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b7b:	89 c7                	mov    %eax,%edi
  800b7d:	fc                   	cld    
  800b7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b80:	eb 05                	jmp    800b87 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b82:	89 c7                	mov    %eax,%edi
  800b84:	fc                   	cld    
  800b85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8b:	f3 0f 1e fb          	endbr32 
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b95:	ff 75 10             	pushl  0x10(%ebp)
  800b98:	ff 75 0c             	pushl  0xc(%ebp)
  800b9b:	ff 75 08             	pushl  0x8(%ebp)
  800b9e:	e8 82 ff ff ff       	call   800b25 <memmove>
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba5:	f3 0f 1e fb          	endbr32 
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb4:	89 c6                	mov    %eax,%esi
  800bb6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb9:	39 f0                	cmp    %esi,%eax
  800bbb:	74 1c                	je     800bd9 <memcmp+0x34>
		if (*s1 != *s2)
  800bbd:	0f b6 08             	movzbl (%eax),%ecx
  800bc0:	0f b6 1a             	movzbl (%edx),%ebx
  800bc3:	38 d9                	cmp    %bl,%cl
  800bc5:	75 08                	jne    800bcf <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	83 c2 01             	add    $0x1,%edx
  800bcd:	eb ea                	jmp    800bb9 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800bcf:	0f b6 c1             	movzbl %cl,%eax
  800bd2:	0f b6 db             	movzbl %bl,%ebx
  800bd5:	29 d8                	sub    %ebx,%eax
  800bd7:	eb 05                	jmp    800bde <memcmp+0x39>
	}

	return 0;
  800bd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be2:	f3 0f 1e fb          	endbr32 
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bef:	89 c2                	mov    %eax,%edx
  800bf1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf4:	39 d0                	cmp    %edx,%eax
  800bf6:	73 09                	jae    800c01 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf8:	38 08                	cmp    %cl,(%eax)
  800bfa:	74 05                	je     800c01 <memfind+0x1f>
	for (; s < ends; s++)
  800bfc:	83 c0 01             	add    $0x1,%eax
  800bff:	eb f3                	jmp    800bf4 <memfind+0x12>
			break;
	return (void *) s;
}
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c03:	f3 0f 1e fb          	endbr32 
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c13:	eb 03                	jmp    800c18 <strtol+0x15>
		s++;
  800c15:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c18:	0f b6 01             	movzbl (%ecx),%eax
  800c1b:	3c 20                	cmp    $0x20,%al
  800c1d:	74 f6                	je     800c15 <strtol+0x12>
  800c1f:	3c 09                	cmp    $0x9,%al
  800c21:	74 f2                	je     800c15 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c23:	3c 2b                	cmp    $0x2b,%al
  800c25:	74 2a                	je     800c51 <strtol+0x4e>
	int neg = 0;
  800c27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c2c:	3c 2d                	cmp    $0x2d,%al
  800c2e:	74 2b                	je     800c5b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c36:	75 0f                	jne    800c47 <strtol+0x44>
  800c38:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3b:	74 28                	je     800c65 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3d:	85 db                	test   %ebx,%ebx
  800c3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c44:	0f 44 d8             	cmove  %eax,%ebx
  800c47:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c4f:	eb 46                	jmp    800c97 <strtol+0x94>
		s++;
  800c51:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c54:	bf 00 00 00 00       	mov    $0x0,%edi
  800c59:	eb d5                	jmp    800c30 <strtol+0x2d>
		s++, neg = 1;
  800c5b:	83 c1 01             	add    $0x1,%ecx
  800c5e:	bf 01 00 00 00       	mov    $0x1,%edi
  800c63:	eb cb                	jmp    800c30 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c69:	74 0e                	je     800c79 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c6b:	85 db                	test   %ebx,%ebx
  800c6d:	75 d8                	jne    800c47 <strtol+0x44>
		s++, base = 8;
  800c6f:	83 c1 01             	add    $0x1,%ecx
  800c72:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c77:	eb ce                	jmp    800c47 <strtol+0x44>
		s += 2, base = 16;
  800c79:	83 c1 02             	add    $0x2,%ecx
  800c7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c81:	eb c4                	jmp    800c47 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c83:	0f be d2             	movsbl %dl,%edx
  800c86:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8c:	7d 3a                	jge    800cc8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c8e:	83 c1 01             	add    $0x1,%ecx
  800c91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c95:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c97:	0f b6 11             	movzbl (%ecx),%edx
  800c9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c9d:	89 f3                	mov    %esi,%ebx
  800c9f:	80 fb 09             	cmp    $0x9,%bl
  800ca2:	76 df                	jbe    800c83 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ca4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca7:	89 f3                	mov    %esi,%ebx
  800ca9:	80 fb 19             	cmp    $0x19,%bl
  800cac:	77 08                	ja     800cb6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cae:	0f be d2             	movsbl %dl,%edx
  800cb1:	83 ea 57             	sub    $0x57,%edx
  800cb4:	eb d3                	jmp    800c89 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800cb6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb9:	89 f3                	mov    %esi,%ebx
  800cbb:	80 fb 19             	cmp    $0x19,%bl
  800cbe:	77 08                	ja     800cc8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cc0:	0f be d2             	movsbl %dl,%edx
  800cc3:	83 ea 37             	sub    $0x37,%edx
  800cc6:	eb c1                	jmp    800c89 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccc:	74 05                	je     800cd3 <strtol+0xd0>
		*endptr = (char *) s;
  800cce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cd3:	89 c2                	mov    %eax,%edx
  800cd5:	f7 da                	neg    %edx
  800cd7:	85 ff                	test   %edi,%edi
  800cd9:	0f 45 c2             	cmovne %edx,%eax
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce1:	f3 0f 1e fb          	endbr32 
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	89 c3                	mov    %eax,%ebx
  800cf8:	89 c7                	mov    %eax,%edi
  800cfa:	89 c6                	mov    %eax,%esi
  800cfc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 01 00 00 00       	mov    $0x1,%eax
  800d17:	89 d1                	mov    %edx,%ecx
  800d19:	89 d3                	mov    %edx,%ebx
  800d1b:	89 d7                	mov    %edx,%edi
  800d1d:	89 d6                	mov    %edx,%esi
  800d1f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d26:	f3 0f 1e fb          	endbr32 
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3d:	89 cb                	mov    %ecx,%ebx
  800d3f:	89 cf                	mov    %ecx,%edi
  800d41:	89 ce                	mov    %ecx,%esi
  800d43:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4a:	f3 0f 1e fb          	endbr32 
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d54:	ba 00 00 00 00       	mov    $0x0,%edx
  800d59:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5e:	89 d1                	mov    %edx,%ecx
  800d60:	89 d3                	mov    %edx,%ebx
  800d62:	89 d7                	mov    %edx,%edi
  800d64:	89 d6                	mov    %edx,%esi
  800d66:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_yield>:

void
sys_yield(void)
{
  800d6d:	f3 0f 1e fb          	endbr32 
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d77:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d81:	89 d1                	mov    %edx,%ecx
  800d83:	89 d3                	mov    %edx,%ebx
  800d85:	89 d7                	mov    %edx,%edi
  800d87:	89 d6                	mov    %edx,%esi
  800d89:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d90:	f3 0f 1e fb          	endbr32 
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9a:	be 00 00 00 00       	mov    $0x0,%esi
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	b8 04 00 00 00       	mov    $0x4,%eax
  800daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dad:	89 f7                	mov    %esi,%edi
  800daf:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db6:	f3 0f 1e fb          	endbr32 
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd1:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd4:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ddb:	f3 0f 1e fb          	endbr32 
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	b8 06 00 00 00       	mov    $0x6,%eax
  800df5:	89 df                	mov    %ebx,%edi
  800df7:	89 de                	mov    %ebx,%esi
  800df9:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e00:	f3 0f 1e fb          	endbr32 
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e15:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e25:	f3 0f 1e fb          	endbr32 
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e34:	8b 55 08             	mov    0x8(%ebp),%edx
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3f:	89 df                	mov    %ebx,%edi
  800e41:	89 de                	mov    %ebx,%esi
  800e43:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4a:	f3 0f 1e fb          	endbr32 
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e64:	89 df                	mov    %ebx,%edi
  800e66:	89 de                	mov    %ebx,%esi
  800e68:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6f:	f3 0f 1e fb          	endbr32 
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e84:	be 00 00 00 00       	mov    $0x0,%esi
  800e89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e96:	f3 0f 1e fb          	endbr32 
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ead:	89 cb                	mov    %ecx,%ebx
  800eaf:	89 cf                	mov    %ecx,%edi
  800eb1:	89 ce                	mov    %ecx,%esi
  800eb3:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eba:	f3 0f 1e fb          	endbr32 
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ece:	89 d1                	mov    %edx,%ecx
  800ed0:	89 d3                	mov    %edx,%ebx
  800ed2:	89 d7                	mov    %edx,%edi
  800ed4:	89 d6                	mov    %edx,%esi
  800ed6:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ed8:	5b                   	pop    %ebx
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800edd:	f3 0f 1e fb          	endbr32 
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ef7:	89 df                	mov    %ebx,%edi
  800ef9:	89 de                	mov    %ebx,%esi
  800efb:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800f02:	f3 0f 1e fb          	endbr32 
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f17:	b8 10 00 00 00       	mov    $0x10,%eax
  800f1c:	89 df                	mov    %ebx,%edi
  800f1e:	89 de                	mov    %ebx,%esi
  800f20:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800f27:	f3 0f 1e fb          	endbr32 
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 04             	sub    $0x4,%esp
  800f32:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800f35:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800f37:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f3b:	0f 84 9a 00 00 00    	je     800fdb <pgfault+0xb4>
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	c1 e8 16             	shr    $0x16,%eax
  800f46:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f4d:	a8 01                	test   $0x1,%al
  800f4f:	0f 84 86 00 00 00    	je     800fdb <pgfault+0xb4>
  800f55:	89 d8                	mov    %ebx,%eax
  800f57:	c1 e8 0c             	shr    $0xc,%eax
  800f5a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f61:	f6 c2 01             	test   $0x1,%dl
  800f64:	74 75                	je     800fdb <pgfault+0xb4>
  800f66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6d:	f6 c4 08             	test   $0x8,%ah
  800f70:	74 69                	je     800fdb <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	6a 07                	push   $0x7
  800f77:	68 00 f0 7f 00       	push   $0x7ff000
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 0d fe ff ff       	call   800d90 <sys_page_alloc>
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 63                	js     800fed <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f8a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800f90:	83 ec 04             	sub    $0x4,%esp
  800f93:	68 00 10 00 00       	push   $0x1000
  800f98:	53                   	push   %ebx
  800f99:	68 00 f0 7f 00       	push   $0x7ff000
  800f9e:	e8 e8 fb ff ff       	call   800b8b <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800fa3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800faa:	53                   	push   %ebx
  800fab:	6a 00                	push   $0x0
  800fad:	68 00 f0 7f 00       	push   $0x7ff000
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 fd fd ff ff       	call   800db6 <sys_page_map>
  800fb9:	83 c4 20             	add    $0x20,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 3f                	js     800fff <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	68 00 f0 7f 00       	push   $0x7ff000
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 0c fe ff ff       	call   800ddb <sys_page_unmap>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 3b                	js     801011 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800fdb:	53                   	push   %ebx
  800fdc:	68 c0 2c 80 00       	push   $0x802cc0
  800fe1:	6a 20                	push   $0x20
  800fe3:	68 7e 2d 80 00       	push   $0x802d7e
  800fe8:	e8 49 f2 ff ff       	call   800236 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800fed:	50                   	push   %eax
  800fee:	68 00 2d 80 00       	push   $0x802d00
  800ff3:	6a 2c                	push   $0x2c
  800ff5:	68 7e 2d 80 00       	push   $0x802d7e
  800ffa:	e8 37 f2 ff ff       	call   800236 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800fff:	50                   	push   %eax
  801000:	68 2c 2d 80 00       	push   $0x802d2c
  801005:	6a 33                	push   $0x33
  801007:	68 7e 2d 80 00       	push   $0x802d7e
  80100c:	e8 25 f2 ff ff       	call   800236 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  801011:	50                   	push   %eax
  801012:	68 54 2d 80 00       	push   $0x802d54
  801017:	6a 36                	push   $0x36
  801019:	68 7e 2d 80 00       	push   $0x802d7e
  80101e:	e8 13 f2 ff ff       	call   800236 <_panic>

00801023 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801023:	f3 0f 1e fb          	endbr32 
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  801030:	68 27 0f 80 00       	push   $0x800f27
  801035:	e8 d5 13 00 00       	call   80240f <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80103a:	b8 07 00 00 00       	mov    $0x7,%eax
  80103f:	cd 30                	int    $0x30
  801041:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	78 29                	js     801074 <fork+0x51>
  80104b:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  80104d:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  801052:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801056:	75 60                	jne    8010b8 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  801058:	e8 ed fc ff ff       	call   800d4a <sys_getenvid>
  80105d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801062:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80106a:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80106f:	e9 14 01 00 00       	jmp    801188 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  801074:	50                   	push   %eax
  801075:	68 89 2d 80 00       	push   $0x802d89
  80107a:	68 90 00 00 00       	push   $0x90
  80107f:	68 7e 2d 80 00       	push   $0x802d7e
  801084:	e8 ad f1 ff ff       	call   800236 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  801089:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	25 07 0e 00 00       	and    $0xe07,%eax
  801098:	50                   	push   %eax
  801099:	56                   	push   %esi
  80109a:	57                   	push   %edi
  80109b:	56                   	push   %esi
  80109c:	6a 00                	push   $0x0
  80109e:	e8 13 fd ff ff       	call   800db6 <sys_page_map>
  8010a3:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  8010a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ac:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010b2:	0f 84 95 00 00 00    	je     80114d <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	c1 e8 16             	shr    $0x16,%eax
  8010bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c4:	a8 01                	test   $0x1,%al
  8010c6:	74 de                	je     8010a6 <fork+0x83>
  8010c8:	89 d8                	mov    %ebx,%eax
  8010ca:	c1 e8 0c             	shr    $0xc,%eax
  8010cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d4:	f6 c2 01             	test   $0x1,%dl
  8010d7:	74 cd                	je     8010a6 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  8010d9:	89 c6                	mov    %eax,%esi
  8010db:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  8010de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e5:	f6 c6 04             	test   $0x4,%dh
  8010e8:	75 9f                	jne    801089 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  8010ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f1:	f6 c2 02             	test   $0x2,%dl
  8010f4:	75 0c                	jne    801102 <fork+0xdf>
  8010f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fd:	f6 c4 08             	test   $0x8,%ah
  801100:	74 34                	je     801136 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801102:	83 ec 0c             	sub    $0xc,%esp
  801105:	68 05 08 00 00       	push   $0x805
  80110a:	56                   	push   %esi
  80110b:	57                   	push   %edi
  80110c:	56                   	push   %esi
  80110d:	6a 00                	push   $0x0
  80110f:	e8 a2 fc ff ff       	call   800db6 <sys_page_map>
			if (r<0) return r;
  801114:	83 c4 20             	add    $0x20,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 8b                	js     8010a6 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	68 05 08 00 00       	push   $0x805
  801123:	56                   	push   %esi
  801124:	6a 00                	push   $0x0
  801126:	56                   	push   %esi
  801127:	6a 00                	push   $0x0
  801129:	e8 88 fc ff ff       	call   800db6 <sys_page_map>
  80112e:	83 c4 20             	add    $0x20,%esp
  801131:	e9 70 ff ff ff       	jmp    8010a6 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	6a 05                	push   $0x5
  80113b:	56                   	push   %esi
  80113c:	57                   	push   %edi
  80113d:	56                   	push   %esi
  80113e:	6a 00                	push   $0x0
  801140:	e8 71 fc ff ff       	call   800db6 <sys_page_map>
  801145:	83 c4 20             	add    $0x20,%esp
  801148:	e9 59 ff ff ff       	jmp    8010a6 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	6a 07                	push   $0x7
  801152:	68 00 f0 bf ee       	push   $0xeebff000
  801157:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80115a:	56                   	push   %esi
  80115b:	e8 30 fc ff ff       	call   800d90 <sys_page_alloc>
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 2b                	js     801192 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	68 82 24 80 00       	push   $0x802482
  80116f:	56                   	push   %esi
  801170:	e8 d5 fc ff ff       	call   800e4a <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801175:	83 c4 08             	add    $0x8,%esp
  801178:	6a 02                	push   $0x2
  80117a:	56                   	push   %esi
  80117b:	e8 80 fc ff ff       	call   800e00 <sys_env_set_status>
  801180:	83 c4 10             	add    $0x10,%esp
		return r;
  801183:	85 c0                	test   %eax,%eax
  801185:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801188:	89 f8                	mov    %edi,%eax
  80118a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    
		return r;
  801192:	89 c7                	mov    %eax,%edi
  801194:	eb f2                	jmp    801188 <fork+0x165>

00801196 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801196:	f3 0f 1e fb          	endbr32 
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a0:	68 a5 2d 80 00       	push   $0x802da5
  8011a5:	68 b2 00 00 00       	push   $0xb2
  8011aa:	68 7e 2d 80 00       	push   $0x802d7e
  8011af:	e8 82 f0 ff ff       	call   800236 <_panic>

008011b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b4:	f3 0f 1e fb          	endbr32 
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011be:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c8:	f3 0f 1e fb          	endbr32 
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011dc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e3:	f3 0f 1e fb          	endbr32 
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	c1 ea 16             	shr    $0x16,%edx
  8011f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fb:	f6 c2 01             	test   $0x1,%dl
  8011fe:	74 2d                	je     80122d <fd_alloc+0x4a>
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 ea 0c             	shr    $0xc,%edx
  801205:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120c:	f6 c2 01             	test   $0x1,%dl
  80120f:	74 1c                	je     80122d <fd_alloc+0x4a>
  801211:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801216:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80121b:	75 d2                	jne    8011ef <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
  801220:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801226:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80122b:	eb 0a                	jmp    801237 <fd_alloc+0x54>
			*fd_store = fd;
  80122d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801230:	89 01                	mov    %eax,(%ecx)
			return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801239:	f3 0f 1e fb          	endbr32 
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801243:	83 f8 1f             	cmp    $0x1f,%eax
  801246:	77 30                	ja     801278 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801248:	c1 e0 0c             	shl    $0xc,%eax
  80124b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801250:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801256:	f6 c2 01             	test   $0x1,%dl
  801259:	74 24                	je     80127f <fd_lookup+0x46>
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 1a                	je     801286 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80126f:	89 02                	mov    %eax,(%edx)
	return 0;
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
		return -E_INVAL;
  801278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127d:	eb f7                	jmp    801276 <fd_lookup+0x3d>
		return -E_INVAL;
  80127f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801284:	eb f0                	jmp    801276 <fd_lookup+0x3d>
  801286:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128b:	eb e9                	jmp    801276 <fd_lookup+0x3d>

0080128d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128d:	f3 0f 1e fb          	endbr32 
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80129a:	ba 00 00 00 00       	mov    $0x0,%edx
  80129f:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012a4:	39 08                	cmp    %ecx,(%eax)
  8012a6:	74 38                	je     8012e0 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8012a8:	83 c2 01             	add    $0x1,%edx
  8012ab:	8b 04 95 38 2e 80 00 	mov    0x802e38(,%edx,4),%eax
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	75 ee                	jne    8012a4 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b6:	a1 20 44 80 00       	mov    0x804420,%eax
  8012bb:	8b 40 48             	mov    0x48(%eax),%eax
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	51                   	push   %ecx
  8012c2:	50                   	push   %eax
  8012c3:	68 bc 2d 80 00       	push   $0x802dbc
  8012c8:	e8 50 f0 ff ff       	call   80031d <cprintf>
	*dev = 0;
  8012cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012de:	c9                   	leave  
  8012df:	c3                   	ret    
			*dev = devtab[i];
  8012e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ea:	eb f2                	jmp    8012de <dev_lookup+0x51>

008012ec <fd_close>:
{
  8012ec:	f3 0f 1e fb          	endbr32 
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 24             	sub    $0x24,%esp
  8012f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801302:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801303:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801309:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130c:	50                   	push   %eax
  80130d:	e8 27 ff ff ff       	call   801239 <fd_lookup>
  801312:	89 c3                	mov    %eax,%ebx
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 05                	js     801320 <fd_close+0x34>
	    || fd != fd2)
  80131b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80131e:	74 16                	je     801336 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801320:	89 f8                	mov    %edi,%eax
  801322:	84 c0                	test   %al,%al
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
  801329:	0f 44 d8             	cmove  %eax,%ebx
}
  80132c:	89 d8                	mov    %ebx,%eax
  80132e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80133c:	50                   	push   %eax
  80133d:	ff 36                	pushl  (%esi)
  80133f:	e8 49 ff ff ff       	call   80128d <dev_lookup>
  801344:	89 c3                	mov    %eax,%ebx
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 1a                	js     801367 <fd_close+0x7b>
		if (dev->dev_close)
  80134d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801350:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801353:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801358:	85 c0                	test   %eax,%eax
  80135a:	74 0b                	je     801367 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	56                   	push   %esi
  801360:	ff d0                	call   *%eax
  801362:	89 c3                	mov    %eax,%ebx
  801364:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	56                   	push   %esi
  80136b:	6a 00                	push   $0x0
  80136d:	e8 69 fa ff ff       	call   800ddb <sys_page_unmap>
	return r;
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	eb b5                	jmp    80132c <fd_close+0x40>

00801377 <close>:

int
close(int fdnum)
{
  801377:	f3 0f 1e fb          	endbr32 
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	ff 75 08             	pushl  0x8(%ebp)
  801388:	e8 ac fe ff ff       	call   801239 <fd_lookup>
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	85 c0                	test   %eax,%eax
  801392:	79 02                	jns    801396 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    
		return fd_close(fd, 1);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	6a 01                	push   $0x1
  80139b:	ff 75 f4             	pushl  -0xc(%ebp)
  80139e:	e8 49 ff ff ff       	call   8012ec <fd_close>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	eb ec                	jmp    801394 <close+0x1d>

008013a8 <close_all>:

void
close_all(void)
{
  8013a8:	f3 0f 1e fb          	endbr32 
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	e8 b6 ff ff ff       	call   801377 <close>
	for (i = 0; i < MAXFD; i++)
  8013c1:	83 c3 01             	add    $0x1,%ebx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	83 fb 20             	cmp    $0x20,%ebx
  8013ca:	75 ec                	jne    8013b8 <close_all+0x10>
}
  8013cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d1:	f3 0f 1e fb          	endbr32 
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	57                   	push   %edi
  8013d9:	56                   	push   %esi
  8013da:	53                   	push   %ebx
  8013db:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	ff 75 08             	pushl  0x8(%ebp)
  8013e5:	e8 4f fe ff ff       	call   801239 <fd_lookup>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	0f 88 81 00 00 00    	js     801478 <dup+0xa7>
		return r;
	close(newfdnum);
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	ff 75 0c             	pushl  0xc(%ebp)
  8013fd:	e8 75 ff ff ff       	call   801377 <close>

	newfd = INDEX2FD(newfdnum);
  801402:	8b 75 0c             	mov    0xc(%ebp),%esi
  801405:	c1 e6 0c             	shl    $0xc,%esi
  801408:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80140e:	83 c4 04             	add    $0x4,%esp
  801411:	ff 75 e4             	pushl  -0x1c(%ebp)
  801414:	e8 af fd ff ff       	call   8011c8 <fd2data>
  801419:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80141b:	89 34 24             	mov    %esi,(%esp)
  80141e:	e8 a5 fd ff ff       	call   8011c8 <fd2data>
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	c1 e8 16             	shr    $0x16,%eax
  80142d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801434:	a8 01                	test   $0x1,%al
  801436:	74 11                	je     801449 <dup+0x78>
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	c1 e8 0c             	shr    $0xc,%eax
  80143d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801444:	f6 c2 01             	test   $0x1,%dl
  801447:	75 39                	jne    801482 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801449:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144c:	89 d0                	mov    %edx,%eax
  80144e:	c1 e8 0c             	shr    $0xc,%eax
  801451:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801458:	83 ec 0c             	sub    $0xc,%esp
  80145b:	25 07 0e 00 00       	and    $0xe07,%eax
  801460:	50                   	push   %eax
  801461:	56                   	push   %esi
  801462:	6a 00                	push   $0x0
  801464:	52                   	push   %edx
  801465:	6a 00                	push   $0x0
  801467:	e8 4a f9 ff ff       	call   800db6 <sys_page_map>
  80146c:	89 c3                	mov    %eax,%ebx
  80146e:	83 c4 20             	add    $0x20,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 31                	js     8014a6 <dup+0xd5>
		goto err;

	return newfdnum;
  801475:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5f                   	pop    %edi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801482:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801489:	83 ec 0c             	sub    $0xc,%esp
  80148c:	25 07 0e 00 00       	and    $0xe07,%eax
  801491:	50                   	push   %eax
  801492:	57                   	push   %edi
  801493:	6a 00                	push   $0x0
  801495:	53                   	push   %ebx
  801496:	6a 00                	push   $0x0
  801498:	e8 19 f9 ff ff       	call   800db6 <sys_page_map>
  80149d:	89 c3                	mov    %eax,%ebx
  80149f:	83 c4 20             	add    $0x20,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	79 a3                	jns    801449 <dup+0x78>
	sys_page_unmap(0, newfd);
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	56                   	push   %esi
  8014aa:	6a 00                	push   $0x0
  8014ac:	e8 2a f9 ff ff       	call   800ddb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	57                   	push   %edi
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 1f f9 ff ff       	call   800ddb <sys_page_unmap>
	return r;
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	eb b7                	jmp    801478 <dup+0xa7>

008014c1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c1:	f3 0f 1e fb          	endbr32 
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 1c             	sub    $0x1c,%esp
  8014cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	53                   	push   %ebx
  8014d4:	e8 60 fd ff ff       	call   801239 <fd_lookup>
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 3f                	js     80151f <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	50                   	push   %eax
  8014e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ea:	ff 30                	pushl  (%eax)
  8014ec:	e8 9c fd ff ff       	call   80128d <dev_lookup>
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 27                	js     80151f <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014fb:	8b 42 08             	mov    0x8(%edx),%eax
  8014fe:	83 e0 03             	and    $0x3,%eax
  801501:	83 f8 01             	cmp    $0x1,%eax
  801504:	74 1e                	je     801524 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801506:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801509:	8b 40 08             	mov    0x8(%eax),%eax
  80150c:	85 c0                	test   %eax,%eax
  80150e:	74 35                	je     801545 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	ff 75 10             	pushl  0x10(%ebp)
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	52                   	push   %edx
  80151a:	ff d0                	call   *%eax
  80151c:	83 c4 10             	add    $0x10,%esp
}
  80151f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801522:	c9                   	leave  
  801523:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801524:	a1 20 44 80 00       	mov    0x804420,%eax
  801529:	8b 40 48             	mov    0x48(%eax),%eax
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	53                   	push   %ebx
  801530:	50                   	push   %eax
  801531:	68 fd 2d 80 00       	push   $0x802dfd
  801536:	e8 e2 ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801543:	eb da                	jmp    80151f <read+0x5e>
		return -E_NOT_SUPP;
  801545:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80154a:	eb d3                	jmp    80151f <read+0x5e>

0080154c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154c:	f3 0f 1e fb          	endbr32 
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	57                   	push   %edi
  801554:	56                   	push   %esi
  801555:	53                   	push   %ebx
  801556:	83 ec 0c             	sub    $0xc,%esp
  801559:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801564:	eb 02                	jmp    801568 <readn+0x1c>
  801566:	01 c3                	add    %eax,%ebx
  801568:	39 f3                	cmp    %esi,%ebx
  80156a:	73 21                	jae    80158d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	89 f0                	mov    %esi,%eax
  801571:	29 d8                	sub    %ebx,%eax
  801573:	50                   	push   %eax
  801574:	89 d8                	mov    %ebx,%eax
  801576:	03 45 0c             	add    0xc(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	57                   	push   %edi
  80157b:	e8 41 ff ff ff       	call   8014c1 <read>
		if (m < 0)
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 04                	js     80158b <readn+0x3f>
			return m;
		if (m == 0)
  801587:	75 dd                	jne    801566 <readn+0x1a>
  801589:	eb 02                	jmp    80158d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80158d:	89 d8                	mov    %ebx,%eax
  80158f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5f                   	pop    %edi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801597:	f3 0f 1e fb          	endbr32 
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	53                   	push   %ebx
  80159f:	83 ec 1c             	sub    $0x1c,%esp
  8015a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a8:	50                   	push   %eax
  8015a9:	53                   	push   %ebx
  8015aa:	e8 8a fc ff ff       	call   801239 <fd_lookup>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 3a                	js     8015f0 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	ff 30                	pushl  (%eax)
  8015c2:	e8 c6 fc ff ff       	call   80128d <dev_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 22                	js     8015f0 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d5:	74 1e                	je     8015f5 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015da:	8b 52 0c             	mov    0xc(%edx),%edx
  8015dd:	85 d2                	test   %edx,%edx
  8015df:	74 35                	je     801616 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	ff 75 10             	pushl  0x10(%ebp)
  8015e7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ea:	50                   	push   %eax
  8015eb:	ff d2                	call   *%edx
  8015ed:	83 c4 10             	add    $0x10,%esp
}
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f5:	a1 20 44 80 00       	mov    0x804420,%eax
  8015fa:	8b 40 48             	mov    0x48(%eax),%eax
  8015fd:	83 ec 04             	sub    $0x4,%esp
  801600:	53                   	push   %ebx
  801601:	50                   	push   %eax
  801602:	68 19 2e 80 00       	push   $0x802e19
  801607:	e8 11 ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801614:	eb da                	jmp    8015f0 <write+0x59>
		return -E_NOT_SUPP;
  801616:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161b:	eb d3                	jmp    8015f0 <write+0x59>

0080161d <seek>:

int
seek(int fdnum, off_t offset)
{
  80161d:	f3 0f 1e fb          	endbr32 
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801627:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162a:	50                   	push   %eax
  80162b:	ff 75 08             	pushl  0x8(%ebp)
  80162e:	e8 06 fc ff ff       	call   801239 <fd_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 0e                	js     801648 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80163a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80164a:	f3 0f 1e fb          	endbr32 
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	53                   	push   %ebx
  801652:	83 ec 1c             	sub    $0x1c,%esp
  801655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	53                   	push   %ebx
  80165d:	e8 d7 fb ff ff       	call   801239 <fd_lookup>
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	85 c0                	test   %eax,%eax
  801667:	78 37                	js     8016a0 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801673:	ff 30                	pushl  (%eax)
  801675:	e8 13 fc ff ff       	call   80128d <dev_lookup>
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 1f                	js     8016a0 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801688:	74 1b                	je     8016a5 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80168a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168d:	8b 52 18             	mov    0x18(%edx),%edx
  801690:	85 d2                	test   %edx,%edx
  801692:	74 32                	je     8016c6 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	ff 75 0c             	pushl  0xc(%ebp)
  80169a:	50                   	push   %eax
  80169b:	ff d2                	call   *%edx
  80169d:	83 c4 10             	add    $0x10,%esp
}
  8016a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016a5:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016aa:	8b 40 48             	mov    0x48(%eax),%eax
  8016ad:	83 ec 04             	sub    $0x4,%esp
  8016b0:	53                   	push   %ebx
  8016b1:	50                   	push   %eax
  8016b2:	68 dc 2d 80 00       	push   $0x802ddc
  8016b7:	e8 61 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c4:	eb da                	jmp    8016a0 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016cb:	eb d3                	jmp    8016a0 <ftruncate+0x56>

008016cd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016cd:	f3 0f 1e fb          	endbr32 
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 1c             	sub    $0x1c,%esp
  8016d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	ff 75 08             	pushl  0x8(%ebp)
  8016e2:	e8 52 fb ff ff       	call   801239 <fd_lookup>
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 4b                	js     801739 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f4:	50                   	push   %eax
  8016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f8:	ff 30                	pushl  (%eax)
  8016fa:	e8 8e fb ff ff       	call   80128d <dev_lookup>
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	78 33                	js     801739 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801709:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170d:	74 2f                	je     80173e <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801712:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801719:	00 00 00 
	stat->st_isdir = 0;
  80171c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801723:	00 00 00 
	stat->st_dev = dev;
  801726:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	53                   	push   %ebx
  801730:	ff 75 f0             	pushl  -0x10(%ebp)
  801733:	ff 50 14             	call   *0x14(%eax)
  801736:	83 c4 10             	add    $0x10,%esp
}
  801739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    
		return -E_NOT_SUPP;
  80173e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801743:	eb f4                	jmp    801739 <fstat+0x6c>

00801745 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801745:	f3 0f 1e fb          	endbr32 
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	56                   	push   %esi
  80174d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174e:	83 ec 08             	sub    $0x8,%esp
  801751:	6a 00                	push   $0x0
  801753:	ff 75 08             	pushl  0x8(%ebp)
  801756:	e8 01 02 00 00       	call   80195c <open>
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 1b                	js     80177f <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	ff 75 0c             	pushl  0xc(%ebp)
  80176a:	50                   	push   %eax
  80176b:	e8 5d ff ff ff       	call   8016cd <fstat>
  801770:	89 c6                	mov    %eax,%esi
	close(fd);
  801772:	89 1c 24             	mov    %ebx,(%esp)
  801775:	e8 fd fb ff ff       	call   801377 <close>
	return r;
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	89 f3                	mov    %esi,%ebx
}
  80177f:	89 d8                	mov    %ebx,%eax
  801781:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801784:	5b                   	pop    %ebx
  801785:	5e                   	pop    %esi
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	89 c6                	mov    %eax,%esi
  80178f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801791:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801798:	74 27                	je     8017c1 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80179a:	6a 07                	push   $0x7
  80179c:	68 00 50 80 00       	push   $0x805000
  8017a1:	56                   	push   %esi
  8017a2:	ff 35 00 40 80 00    	pushl  0x804000
  8017a8:	e8 66 0d 00 00       	call   802513 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ad:	83 c4 0c             	add    $0xc,%esp
  8017b0:	6a 00                	push   $0x0
  8017b2:	53                   	push   %ebx
  8017b3:	6a 00                	push   $0x0
  8017b5:	e8 ec 0c 00 00       	call   8024a6 <ipc_recv>
}
  8017ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bd:	5b                   	pop    %ebx
  8017be:	5e                   	pop    %esi
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c1:	83 ec 0c             	sub    $0xc,%esp
  8017c4:	6a 01                	push   $0x1
  8017c6:	e8 a0 0d 00 00       	call   80256b <ipc_find_env>
  8017cb:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	eb c5                	jmp    80179a <fsipc+0x12>

008017d5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d5:	f3 0f 1e fb          	endbr32 
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ed:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fc:	e8 87 ff ff ff       	call   801788 <fsipc>
}
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <devfile_flush>:
{
  801803:	f3 0f 1e fb          	endbr32 
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	8b 40 0c             	mov    0xc(%eax),%eax
  801813:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	b8 06 00 00 00       	mov    $0x6,%eax
  801822:	e8 61 ff ff ff       	call   801788 <fsipc>
}
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <devfile_stat>:
{
  801829:	f3 0f 1e fb          	endbr32 
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	53                   	push   %ebx
  801831:	83 ec 04             	sub    $0x4,%esp
  801834:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801837:	8b 45 08             	mov    0x8(%ebp),%eax
  80183a:	8b 40 0c             	mov    0xc(%eax),%eax
  80183d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	b8 05 00 00 00       	mov    $0x5,%eax
  80184c:	e8 37 ff ff ff       	call   801788 <fsipc>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 2c                	js     801881 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	68 00 50 80 00       	push   $0x805000
  80185d:	53                   	push   %ebx
  80185e:	e8 c4 f0 ff ff       	call   800927 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801863:	a1 80 50 80 00       	mov    0x805080,%eax
  801868:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80186e:	a1 84 50 80 00       	mov    0x805084,%eax
  801873:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_write>:
{
  801886:	f3 0f 1e fb          	endbr32 
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	8b 45 10             	mov    0x10(%ebp),%eax
  801893:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801898:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80189d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ac:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b1:	50                   	push   %eax
  8018b2:	ff 75 0c             	pushl  0xc(%ebp)
  8018b5:	68 08 50 80 00       	push   $0x805008
  8018ba:	e8 66 f2 ff ff       	call   800b25 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c9:	e8 ba fe ff ff       	call   801788 <fsipc>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devfile_read>:
{
  8018d0:	f3 0f 1e fb          	endbr32 
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018df:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f7:	e8 8c fe ff ff       	call   801788 <fsipc>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 1f                	js     801921 <devfile_read+0x51>
	assert(r <= n);
  801902:	39 f0                	cmp    %esi,%eax
  801904:	77 24                	ja     80192a <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801906:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190b:	7f 36                	jg     801943 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190d:	83 ec 04             	sub    $0x4,%esp
  801910:	50                   	push   %eax
  801911:	68 00 50 80 00       	push   $0x805000
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	e8 07 f2 ff ff       	call   800b25 <memmove>
	return r;
  80191e:	83 c4 10             	add    $0x10,%esp
}
  801921:	89 d8                	mov    %ebx,%eax
  801923:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    
	assert(r <= n);
  80192a:	68 4c 2e 80 00       	push   $0x802e4c
  80192f:	68 53 2e 80 00       	push   $0x802e53
  801934:	68 8c 00 00 00       	push   $0x8c
  801939:	68 68 2e 80 00       	push   $0x802e68
  80193e:	e8 f3 e8 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  801943:	68 73 2e 80 00       	push   $0x802e73
  801948:	68 53 2e 80 00       	push   $0x802e53
  80194d:	68 8d 00 00 00       	push   $0x8d
  801952:	68 68 2e 80 00       	push   $0x802e68
  801957:	e8 da e8 ff ff       	call   800236 <_panic>

0080195c <open>:
{
  80195c:	f3 0f 1e fb          	endbr32 
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	83 ec 1c             	sub    $0x1c,%esp
  801968:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80196b:	56                   	push   %esi
  80196c:	e8 73 ef ff ff       	call   8008e4 <strlen>
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801979:	7f 6c                	jg     8019e7 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801981:	50                   	push   %eax
  801982:	e8 5c f8 ff ff       	call   8011e3 <fd_alloc>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 3c                	js     8019cc <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	56                   	push   %esi
  801994:	68 00 50 80 00       	push   $0x805000
  801999:	e8 89 ef ff ff       	call   800927 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ae:	e8 d5 fd ff ff       	call   801788 <fsipc>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 19                	js     8019d5 <open+0x79>
	return fd2num(fd);
  8019bc:	83 ec 0c             	sub    $0xc,%esp
  8019bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c2:	e8 ed f7 ff ff       	call   8011b4 <fd2num>
  8019c7:	89 c3                	mov    %eax,%ebx
  8019c9:	83 c4 10             	add    $0x10,%esp
}
  8019cc:	89 d8                	mov    %ebx,%eax
  8019ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d1:	5b                   	pop    %ebx
  8019d2:	5e                   	pop    %esi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    
		fd_close(fd, 0);
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	6a 00                	push   $0x0
  8019da:	ff 75 f4             	pushl  -0xc(%ebp)
  8019dd:	e8 0a f9 ff ff       	call   8012ec <fd_close>
		return r;
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	eb e5                	jmp    8019cc <open+0x70>
		return -E_BAD_PATH;
  8019e7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ec:	eb de                	jmp    8019cc <open+0x70>

008019ee <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ee:	f3 0f 1e fb          	endbr32 
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fd:	b8 08 00 00 00       	mov    $0x8,%eax
  801a02:	e8 81 fd ff ff       	call   801788 <fsipc>
}
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a09:	f3 0f 1e fb          	endbr32 
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a13:	68 df 2e 80 00       	push   $0x802edf
  801a18:	ff 75 0c             	pushl  0xc(%ebp)
  801a1b:	e8 07 ef ff ff       	call   800927 <strcpy>
	return 0;
}
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <devsock_close>:
{
  801a27:	f3 0f 1e fb          	endbr32 
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	53                   	push   %ebx
  801a2f:	83 ec 10             	sub    $0x10,%esp
  801a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a35:	53                   	push   %ebx
  801a36:	e8 6d 0b 00 00       	call   8025a8 <pageref>
  801a3b:	89 c2                	mov    %eax,%edx
  801a3d:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a45:	83 fa 01             	cmp    $0x1,%edx
  801a48:	74 05                	je     801a4f <devsock_close+0x28>
}
  801a4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	ff 73 0c             	pushl  0xc(%ebx)
  801a55:	e8 e3 02 00 00       	call   801d3d <nsipc_close>
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	eb eb                	jmp    801a4a <devsock_close+0x23>

00801a5f <devsock_write>:
{
  801a5f:	f3 0f 1e fb          	endbr32 
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a69:	6a 00                	push   $0x0
  801a6b:	ff 75 10             	pushl  0x10(%ebp)
  801a6e:	ff 75 0c             	pushl  0xc(%ebp)
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	ff 70 0c             	pushl  0xc(%eax)
  801a77:	e8 b5 03 00 00       	call   801e31 <nsipc_send>
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devsock_read>:
{
  801a7e:	f3 0f 1e fb          	endbr32 
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a88:	6a 00                	push   $0x0
  801a8a:	ff 75 10             	pushl  0x10(%ebp)
  801a8d:	ff 75 0c             	pushl  0xc(%ebp)
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	ff 70 0c             	pushl  0xc(%eax)
  801a96:	e8 1f 03 00 00       	call   801dba <nsipc_recv>
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <fd2sockid>:
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aa3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aa6:	52                   	push   %edx
  801aa7:	50                   	push   %eax
  801aa8:	e8 8c f7 ff ff       	call   801239 <fd_lookup>
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 10                	js     801ac4 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab7:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801abd:	39 08                	cmp    %ecx,(%eax)
  801abf:	75 05                	jne    801ac6 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801ac1:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    
		return -E_NOT_SUPP;
  801ac6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801acb:	eb f7                	jmp    801ac4 <fd2sockid+0x27>

00801acd <alloc_sockfd>:
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	56                   	push   %esi
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 1c             	sub    $0x1c,%esp
  801ad5:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801ad7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ada:	50                   	push   %eax
  801adb:	e8 03 f7 ff ff       	call   8011e3 <fd_alloc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	78 43                	js     801b2c <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ae9:	83 ec 04             	sub    $0x4,%esp
  801aec:	68 07 04 00 00       	push   $0x407
  801af1:	ff 75 f4             	pushl  -0xc(%ebp)
  801af4:	6a 00                	push   $0x0
  801af6:	e8 95 f2 ff ff       	call   800d90 <sys_page_alloc>
  801afb:	89 c3                	mov    %eax,%ebx
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 28                	js     801b2c <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b07:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b0d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b12:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b19:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	50                   	push   %eax
  801b20:	e8 8f f6 ff ff       	call   8011b4 <fd2num>
  801b25:	89 c3                	mov    %eax,%ebx
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	eb 0c                	jmp    801b38 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	56                   	push   %esi
  801b30:	e8 08 02 00 00       	call   801d3d <nsipc_close>
		return r;
  801b35:	83 c4 10             	add    $0x10,%esp
}
  801b38:	89 d8                	mov    %ebx,%eax
  801b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3d:	5b                   	pop    %ebx
  801b3e:	5e                   	pop    %esi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <accept>:
{
  801b41:	f3 0f 1e fb          	endbr32 
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	e8 4a ff ff ff       	call   801a9d <fd2sockid>
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 1b                	js     801b72 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b57:	83 ec 04             	sub    $0x4,%esp
  801b5a:	ff 75 10             	pushl  0x10(%ebp)
  801b5d:	ff 75 0c             	pushl  0xc(%ebp)
  801b60:	50                   	push   %eax
  801b61:	e8 22 01 00 00       	call   801c88 <nsipc_accept>
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	78 05                	js     801b72 <accept+0x31>
	return alloc_sockfd(r);
  801b6d:	e8 5b ff ff ff       	call   801acd <alloc_sockfd>
}
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <bind>:
{
  801b74:	f3 0f 1e fb          	endbr32 
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	e8 17 ff ff ff       	call   801a9d <fd2sockid>
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 12                	js     801b9c <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801b8a:	83 ec 04             	sub    $0x4,%esp
  801b8d:	ff 75 10             	pushl  0x10(%ebp)
  801b90:	ff 75 0c             	pushl  0xc(%ebp)
  801b93:	50                   	push   %eax
  801b94:	e8 45 01 00 00       	call   801cde <nsipc_bind>
  801b99:	83 c4 10             	add    $0x10,%esp
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <shutdown>:
{
  801b9e:	f3 0f 1e fb          	endbr32 
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bab:	e8 ed fe ff ff       	call   801a9d <fd2sockid>
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	78 0f                	js     801bc3 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801bb4:	83 ec 08             	sub    $0x8,%esp
  801bb7:	ff 75 0c             	pushl  0xc(%ebp)
  801bba:	50                   	push   %eax
  801bbb:	e8 57 01 00 00       	call   801d17 <nsipc_shutdown>
  801bc0:	83 c4 10             	add    $0x10,%esp
}
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <connect>:
{
  801bc5:	f3 0f 1e fb          	endbr32 
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	e8 c6 fe ff ff       	call   801a9d <fd2sockid>
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	78 12                	js     801bed <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801bdb:	83 ec 04             	sub    $0x4,%esp
  801bde:	ff 75 10             	pushl  0x10(%ebp)
  801be1:	ff 75 0c             	pushl  0xc(%ebp)
  801be4:	50                   	push   %eax
  801be5:	e8 71 01 00 00       	call   801d5b <nsipc_connect>
  801bea:	83 c4 10             	add    $0x10,%esp
}
  801bed:	c9                   	leave  
  801bee:	c3                   	ret    

00801bef <listen>:
{
  801bef:	f3 0f 1e fb          	endbr32 
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	e8 9c fe ff ff       	call   801a9d <fd2sockid>
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 0f                	js     801c14 <listen+0x25>
	return nsipc_listen(r, backlog);
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	ff 75 0c             	pushl  0xc(%ebp)
  801c0b:	50                   	push   %eax
  801c0c:	e8 83 01 00 00       	call   801d94 <nsipc_listen>
  801c11:	83 c4 10             	add    $0x10,%esp
}
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c16:	f3 0f 1e fb          	endbr32 
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c20:	ff 75 10             	pushl  0x10(%ebp)
  801c23:	ff 75 0c             	pushl  0xc(%ebp)
  801c26:	ff 75 08             	pushl  0x8(%ebp)
  801c29:	e8 65 02 00 00       	call   801e93 <nsipc_socket>
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 05                	js     801c3a <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801c35:	e8 93 fe ff ff       	call   801acd <alloc_sockfd>
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c45:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c4c:	74 26                	je     801c74 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c4e:	6a 07                	push   $0x7
  801c50:	68 00 60 80 00       	push   $0x806000
  801c55:	53                   	push   %ebx
  801c56:	ff 35 04 40 80 00    	pushl  0x804004
  801c5c:	e8 b2 08 00 00       	call   802513 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c61:	83 c4 0c             	add    $0xc,%esp
  801c64:	6a 00                	push   $0x0
  801c66:	6a 00                	push   $0x0
  801c68:	6a 00                	push   $0x0
  801c6a:	e8 37 08 00 00       	call   8024a6 <ipc_recv>
}
  801c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c74:	83 ec 0c             	sub    $0xc,%esp
  801c77:	6a 02                	push   $0x2
  801c79:	e8 ed 08 00 00       	call   80256b <ipc_find_env>
  801c7e:	a3 04 40 80 00       	mov    %eax,0x804004
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	eb c6                	jmp    801c4e <nsipc+0x12>

00801c88 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c88:	f3 0f 1e fb          	endbr32 
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c9c:	8b 06                	mov    (%esi),%eax
  801c9e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ca3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca8:	e8 8f ff ff ff       	call   801c3c <nsipc>
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	79 09                	jns    801cbc <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801cb3:	89 d8                	mov    %ebx,%eax
  801cb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5e                   	pop    %esi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cbc:	83 ec 04             	sub    $0x4,%esp
  801cbf:	ff 35 10 60 80 00    	pushl  0x806010
  801cc5:	68 00 60 80 00       	push   $0x806000
  801cca:	ff 75 0c             	pushl  0xc(%ebp)
  801ccd:	e8 53 ee ff ff       	call   800b25 <memmove>
		*addrlen = ret->ret_addrlen;
  801cd2:	a1 10 60 80 00       	mov    0x806010,%eax
  801cd7:	89 06                	mov    %eax,(%esi)
  801cd9:	83 c4 10             	add    $0x10,%esp
	return r;
  801cdc:	eb d5                	jmp    801cb3 <nsipc_accept+0x2b>

00801cde <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cde:	f3 0f 1e fb          	endbr32 
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cec:	8b 45 08             	mov    0x8(%ebp),%eax
  801cef:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cf4:	53                   	push   %ebx
  801cf5:	ff 75 0c             	pushl  0xc(%ebp)
  801cf8:	68 04 60 80 00       	push   $0x806004
  801cfd:	e8 23 ee ff ff       	call   800b25 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d02:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d08:	b8 02 00 00 00       	mov    $0x2,%eax
  801d0d:	e8 2a ff ff ff       	call   801c3c <nsipc>
}
  801d12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d17:	f3 0f 1e fb          	endbr32 
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d31:	b8 03 00 00 00       	mov    $0x3,%eax
  801d36:	e8 01 ff ff ff       	call   801c3c <nsipc>
}
  801d3b:	c9                   	leave  
  801d3c:	c3                   	ret    

00801d3d <nsipc_close>:

int
nsipc_close(int s)
{
  801d3d:	f3 0f 1e fb          	endbr32 
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d4f:	b8 04 00 00 00       	mov    $0x4,%eax
  801d54:	e8 e3 fe ff ff       	call   801c3c <nsipc>
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d5b:	f3 0f 1e fb          	endbr32 
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	53                   	push   %ebx
  801d63:	83 ec 08             	sub    $0x8,%esp
  801d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d69:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d71:	53                   	push   %ebx
  801d72:	ff 75 0c             	pushl  0xc(%ebp)
  801d75:	68 04 60 80 00       	push   $0x806004
  801d7a:	e8 a6 ed ff ff       	call   800b25 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d7f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d85:	b8 05 00 00 00       	mov    $0x5,%eax
  801d8a:	e8 ad fe ff ff       	call   801c3c <nsipc>
}
  801d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d94:	f3 0f 1e fb          	endbr32 
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801da1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dae:	b8 06 00 00 00       	mov    $0x6,%eax
  801db3:	e8 84 fe ff ff       	call   801c3c <nsipc>
}
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dba:	f3 0f 1e fb          	endbr32 
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	56                   	push   %esi
  801dc2:	53                   	push   %ebx
  801dc3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dce:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ddc:	b8 07 00 00 00       	mov    $0x7,%eax
  801de1:	e8 56 fe ff ff       	call   801c3c <nsipc>
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 26                	js     801e12 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801dec:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801df2:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801df7:	0f 4e c6             	cmovle %esi,%eax
  801dfa:	39 c3                	cmp    %eax,%ebx
  801dfc:	7f 1d                	jg     801e1b <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dfe:	83 ec 04             	sub    $0x4,%esp
  801e01:	53                   	push   %ebx
  801e02:	68 00 60 80 00       	push   $0x806000
  801e07:	ff 75 0c             	pushl  0xc(%ebp)
  801e0a:	e8 16 ed ff ff       	call   800b25 <memmove>
  801e0f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e12:	89 d8                	mov    %ebx,%eax
  801e14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e1b:	68 eb 2e 80 00       	push   $0x802eeb
  801e20:	68 53 2e 80 00       	push   $0x802e53
  801e25:	6a 62                	push   $0x62
  801e27:	68 00 2f 80 00       	push   $0x802f00
  801e2c:	e8 05 e4 ff ff       	call   800236 <_panic>

00801e31 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e31:	f3 0f 1e fb          	endbr32 
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	53                   	push   %ebx
  801e39:	83 ec 04             	sub    $0x4,%esp
  801e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e42:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e47:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e4d:	7f 2e                	jg     801e7d <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	53                   	push   %ebx
  801e53:	ff 75 0c             	pushl  0xc(%ebp)
  801e56:	68 0c 60 80 00       	push   $0x80600c
  801e5b:	e8 c5 ec ff ff       	call   800b25 <memmove>
	nsipcbuf.send.req_size = size;
  801e60:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e66:	8b 45 14             	mov    0x14(%ebp),%eax
  801e69:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e6e:	b8 08 00 00 00       	mov    $0x8,%eax
  801e73:	e8 c4 fd ff ff       	call   801c3c <nsipc>
}
  801e78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    
	assert(size < 1600);
  801e7d:	68 0c 2f 80 00       	push   $0x802f0c
  801e82:	68 53 2e 80 00       	push   $0x802e53
  801e87:	6a 6d                	push   $0x6d
  801e89:	68 00 2f 80 00       	push   $0x802f00
  801e8e:	e8 a3 e3 ff ff       	call   800236 <_panic>

00801e93 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e93:	f3 0f 1e fb          	endbr32 
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ead:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801eb5:	b8 09 00 00 00       	mov    $0x9,%eax
  801eba:	e8 7d fd ff ff       	call   801c3c <nsipc>
}
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ec1:	f3 0f 1e fb          	endbr32 
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	ff 75 08             	pushl  0x8(%ebp)
  801ed3:	e8 f0 f2 ff ff       	call   8011c8 <fd2data>
  801ed8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eda:	83 c4 08             	add    $0x8,%esp
  801edd:	68 18 2f 80 00       	push   $0x802f18
  801ee2:	53                   	push   %ebx
  801ee3:	e8 3f ea ff ff       	call   800927 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ee8:	8b 46 04             	mov    0x4(%esi),%eax
  801eeb:	2b 06                	sub    (%esi),%eax
  801eed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ef3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801efa:	00 00 00 
	stat->st_dev = &devpipe;
  801efd:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f04:	30 80 00 
	return 0;
}
  801f07:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5d                   	pop    %ebp
  801f12:	c3                   	ret    

00801f13 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f13:	f3 0f 1e fb          	endbr32 
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	53                   	push   %ebx
  801f1b:	83 ec 0c             	sub    $0xc,%esp
  801f1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f21:	53                   	push   %ebx
  801f22:	6a 00                	push   $0x0
  801f24:	e8 b2 ee ff ff       	call   800ddb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f29:	89 1c 24             	mov    %ebx,(%esp)
  801f2c:	e8 97 f2 ff ff       	call   8011c8 <fd2data>
  801f31:	83 c4 08             	add    $0x8,%esp
  801f34:	50                   	push   %eax
  801f35:	6a 00                	push   $0x0
  801f37:	e8 9f ee ff ff       	call   800ddb <sys_page_unmap>
}
  801f3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <_pipeisclosed>:
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	57                   	push   %edi
  801f45:	56                   	push   %esi
  801f46:	53                   	push   %ebx
  801f47:	83 ec 1c             	sub    $0x1c,%esp
  801f4a:	89 c7                	mov    %eax,%edi
  801f4c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f4e:	a1 20 44 80 00       	mov    0x804420,%eax
  801f53:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f56:	83 ec 0c             	sub    $0xc,%esp
  801f59:	57                   	push   %edi
  801f5a:	e8 49 06 00 00       	call   8025a8 <pageref>
  801f5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f62:	89 34 24             	mov    %esi,(%esp)
  801f65:	e8 3e 06 00 00       	call   8025a8 <pageref>
		nn = thisenv->env_runs;
  801f6a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f70:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	39 cb                	cmp    %ecx,%ebx
  801f78:	74 1b                	je     801f95 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f7a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f7d:	75 cf                	jne    801f4e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f7f:	8b 42 58             	mov    0x58(%edx),%eax
  801f82:	6a 01                	push   $0x1
  801f84:	50                   	push   %eax
  801f85:	53                   	push   %ebx
  801f86:	68 1f 2f 80 00       	push   $0x802f1f
  801f8b:	e8 8d e3 ff ff       	call   80031d <cprintf>
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	eb b9                	jmp    801f4e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f95:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f98:	0f 94 c0             	sete   %al
  801f9b:	0f b6 c0             	movzbl %al,%eax
}
  801f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5f                   	pop    %edi
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    

00801fa6 <devpipe_write>:
{
  801fa6:	f3 0f 1e fb          	endbr32 
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	57                   	push   %edi
  801fae:	56                   	push   %esi
  801faf:	53                   	push   %ebx
  801fb0:	83 ec 28             	sub    $0x28,%esp
  801fb3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fb6:	56                   	push   %esi
  801fb7:	e8 0c f2 ff ff       	call   8011c8 <fd2data>
  801fbc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	bf 00 00 00 00       	mov    $0x0,%edi
  801fc6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fc9:	74 4f                	je     80201a <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fcb:	8b 43 04             	mov    0x4(%ebx),%eax
  801fce:	8b 0b                	mov    (%ebx),%ecx
  801fd0:	8d 51 20             	lea    0x20(%ecx),%edx
  801fd3:	39 d0                	cmp    %edx,%eax
  801fd5:	72 14                	jb     801feb <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801fd7:	89 da                	mov    %ebx,%edx
  801fd9:	89 f0                	mov    %esi,%eax
  801fdb:	e8 61 ff ff ff       	call   801f41 <_pipeisclosed>
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	75 3b                	jne    80201f <devpipe_write+0x79>
			sys_yield();
  801fe4:	e8 84 ed ff ff       	call   800d6d <sys_yield>
  801fe9:	eb e0                	jmp    801fcb <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801feb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fee:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ff2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ff5:	89 c2                	mov    %eax,%edx
  801ff7:	c1 fa 1f             	sar    $0x1f,%edx
  801ffa:	89 d1                	mov    %edx,%ecx
  801ffc:	c1 e9 1b             	shr    $0x1b,%ecx
  801fff:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802002:	83 e2 1f             	and    $0x1f,%edx
  802005:	29 ca                	sub    %ecx,%edx
  802007:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80200b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80200f:	83 c0 01             	add    $0x1,%eax
  802012:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802015:	83 c7 01             	add    $0x1,%edi
  802018:	eb ac                	jmp    801fc6 <devpipe_write+0x20>
	return i;
  80201a:	8b 45 10             	mov    0x10(%ebp),%eax
  80201d:	eb 05                	jmp    802024 <devpipe_write+0x7e>
				return 0;
  80201f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5f                   	pop    %edi
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    

0080202c <devpipe_read>:
{
  80202c:	f3 0f 1e fb          	endbr32 
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	57                   	push   %edi
  802034:	56                   	push   %esi
  802035:	53                   	push   %ebx
  802036:	83 ec 18             	sub    $0x18,%esp
  802039:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80203c:	57                   	push   %edi
  80203d:	e8 86 f1 ff ff       	call   8011c8 <fd2data>
  802042:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	be 00 00 00 00       	mov    $0x0,%esi
  80204c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80204f:	75 14                	jne    802065 <devpipe_read+0x39>
	return i;
  802051:	8b 45 10             	mov    0x10(%ebp),%eax
  802054:	eb 02                	jmp    802058 <devpipe_read+0x2c>
				return i;
  802056:	89 f0                	mov    %esi,%eax
}
  802058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205b:	5b                   	pop    %ebx
  80205c:	5e                   	pop    %esi
  80205d:	5f                   	pop    %edi
  80205e:	5d                   	pop    %ebp
  80205f:	c3                   	ret    
			sys_yield();
  802060:	e8 08 ed ff ff       	call   800d6d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802065:	8b 03                	mov    (%ebx),%eax
  802067:	3b 43 04             	cmp    0x4(%ebx),%eax
  80206a:	75 18                	jne    802084 <devpipe_read+0x58>
			if (i > 0)
  80206c:	85 f6                	test   %esi,%esi
  80206e:	75 e6                	jne    802056 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802070:	89 da                	mov    %ebx,%edx
  802072:	89 f8                	mov    %edi,%eax
  802074:	e8 c8 fe ff ff       	call   801f41 <_pipeisclosed>
  802079:	85 c0                	test   %eax,%eax
  80207b:	74 e3                	je     802060 <devpipe_read+0x34>
				return 0;
  80207d:	b8 00 00 00 00       	mov    $0x0,%eax
  802082:	eb d4                	jmp    802058 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802084:	99                   	cltd   
  802085:	c1 ea 1b             	shr    $0x1b,%edx
  802088:	01 d0                	add    %edx,%eax
  80208a:	83 e0 1f             	and    $0x1f,%eax
  80208d:	29 d0                	sub    %edx,%eax
  80208f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802094:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802097:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80209a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80209d:	83 c6 01             	add    $0x1,%esi
  8020a0:	eb aa                	jmp    80204c <devpipe_read+0x20>

008020a2 <pipe>:
{
  8020a2:	f3 0f 1e fb          	endbr32 
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	56                   	push   %esi
  8020aa:	53                   	push   %ebx
  8020ab:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b1:	50                   	push   %eax
  8020b2:	e8 2c f1 ff ff       	call   8011e3 <fd_alloc>
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	83 c4 10             	add    $0x10,%esp
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	0f 88 23 01 00 00    	js     8021e7 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c4:	83 ec 04             	sub    $0x4,%esp
  8020c7:	68 07 04 00 00       	push   $0x407
  8020cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020cf:	6a 00                	push   $0x0
  8020d1:	e8 ba ec ff ff       	call   800d90 <sys_page_alloc>
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	0f 88 04 01 00 00    	js     8021e7 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e9:	50                   	push   %eax
  8020ea:	e8 f4 f0 ff ff       	call   8011e3 <fd_alloc>
  8020ef:	89 c3                	mov    %eax,%ebx
  8020f1:	83 c4 10             	add    $0x10,%esp
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	0f 88 db 00 00 00    	js     8021d7 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020fc:	83 ec 04             	sub    $0x4,%esp
  8020ff:	68 07 04 00 00       	push   $0x407
  802104:	ff 75 f0             	pushl  -0x10(%ebp)
  802107:	6a 00                	push   $0x0
  802109:	e8 82 ec ff ff       	call   800d90 <sys_page_alloc>
  80210e:	89 c3                	mov    %eax,%ebx
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	85 c0                	test   %eax,%eax
  802115:	0f 88 bc 00 00 00    	js     8021d7 <pipe+0x135>
	va = fd2data(fd0);
  80211b:	83 ec 0c             	sub    $0xc,%esp
  80211e:	ff 75 f4             	pushl  -0xc(%ebp)
  802121:	e8 a2 f0 ff ff       	call   8011c8 <fd2data>
  802126:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802128:	83 c4 0c             	add    $0xc,%esp
  80212b:	68 07 04 00 00       	push   $0x407
  802130:	50                   	push   %eax
  802131:	6a 00                	push   $0x0
  802133:	e8 58 ec ff ff       	call   800d90 <sys_page_alloc>
  802138:	89 c3                	mov    %eax,%ebx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	0f 88 82 00 00 00    	js     8021c7 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802145:	83 ec 0c             	sub    $0xc,%esp
  802148:	ff 75 f0             	pushl  -0x10(%ebp)
  80214b:	e8 78 f0 ff ff       	call   8011c8 <fd2data>
  802150:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802157:	50                   	push   %eax
  802158:	6a 00                	push   $0x0
  80215a:	56                   	push   %esi
  80215b:	6a 00                	push   $0x0
  80215d:	e8 54 ec ff ff       	call   800db6 <sys_page_map>
  802162:	89 c3                	mov    %eax,%ebx
  802164:	83 c4 20             	add    $0x20,%esp
  802167:	85 c0                	test   %eax,%eax
  802169:	78 4e                	js     8021b9 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80216b:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802170:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802173:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802175:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802178:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80217f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802182:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802184:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802187:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80218e:	83 ec 0c             	sub    $0xc,%esp
  802191:	ff 75 f4             	pushl  -0xc(%ebp)
  802194:	e8 1b f0 ff ff       	call   8011b4 <fd2num>
  802199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80219e:	83 c4 04             	add    $0x4,%esp
  8021a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a4:	e8 0b f0 ff ff       	call   8011b4 <fd2num>
  8021a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ac:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021af:	83 c4 10             	add    $0x10,%esp
  8021b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021b7:	eb 2e                	jmp    8021e7 <pipe+0x145>
	sys_page_unmap(0, va);
  8021b9:	83 ec 08             	sub    $0x8,%esp
  8021bc:	56                   	push   %esi
  8021bd:	6a 00                	push   $0x0
  8021bf:	e8 17 ec ff ff       	call   800ddb <sys_page_unmap>
  8021c4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021c7:	83 ec 08             	sub    $0x8,%esp
  8021ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8021cd:	6a 00                	push   $0x0
  8021cf:	e8 07 ec ff ff       	call   800ddb <sys_page_unmap>
  8021d4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8021d7:	83 ec 08             	sub    $0x8,%esp
  8021da:	ff 75 f4             	pushl  -0xc(%ebp)
  8021dd:	6a 00                	push   $0x0
  8021df:	e8 f7 eb ff ff       	call   800ddb <sys_page_unmap>
  8021e4:	83 c4 10             	add    $0x10,%esp
}
  8021e7:	89 d8                	mov    %ebx,%eax
  8021e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ec:	5b                   	pop    %ebx
  8021ed:	5e                   	pop    %esi
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    

008021f0 <pipeisclosed>:
{
  8021f0:	f3 0f 1e fb          	endbr32 
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fd:	50                   	push   %eax
  8021fe:	ff 75 08             	pushl  0x8(%ebp)
  802201:	e8 33 f0 ff ff       	call   801239 <fd_lookup>
  802206:	83 c4 10             	add    $0x10,%esp
  802209:	85 c0                	test   %eax,%eax
  80220b:	78 18                	js     802225 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80220d:	83 ec 0c             	sub    $0xc,%esp
  802210:	ff 75 f4             	pushl  -0xc(%ebp)
  802213:	e8 b0 ef ff ff       	call   8011c8 <fd2data>
  802218:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80221a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221d:	e8 1f fd ff ff       	call   801f41 <_pipeisclosed>
  802222:	83 c4 10             	add    $0x10,%esp
}
  802225:	c9                   	leave  
  802226:	c3                   	ret    

00802227 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802227:	f3 0f 1e fb          	endbr32 
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	56                   	push   %esi
  80222f:	53                   	push   %ebx
  802230:	8b 75 08             	mov    0x8(%ebp),%esi
	// cprintf("[%08x] called wait for child %08x\n", thisenv->env_id, envid);
	const volatile struct Env *e;

	assert(envid != 0);
  802233:	85 f6                	test   %esi,%esi
  802235:	74 13                	je     80224a <wait+0x23>
	e = &envs[ENVX(envid)];
  802237:	89 f3                	mov    %esi,%ebx
  802239:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80223f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802242:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802248:	eb 1b                	jmp    802265 <wait+0x3e>
	assert(envid != 0);
  80224a:	68 37 2f 80 00       	push   $0x802f37
  80224f:	68 53 2e 80 00       	push   $0x802e53
  802254:	6a 0a                	push   $0xa
  802256:	68 42 2f 80 00       	push   $0x802f42
  80225b:	e8 d6 df ff ff       	call   800236 <_panic>
		sys_yield();
  802260:	e8 08 eb ff ff       	call   800d6d <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802265:	8b 43 48             	mov    0x48(%ebx),%eax
  802268:	39 f0                	cmp    %esi,%eax
  80226a:	75 07                	jne    802273 <wait+0x4c>
  80226c:	8b 43 54             	mov    0x54(%ebx),%eax
  80226f:	85 c0                	test   %eax,%eax
  802271:	75 ed                	jne    802260 <wait+0x39>
}
  802273:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802276:	5b                   	pop    %ebx
  802277:	5e                   	pop    %esi
  802278:	5d                   	pop    %ebp
  802279:	c3                   	ret    

0080227a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80227a:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80227e:	b8 00 00 00 00       	mov    $0x0,%eax
  802283:	c3                   	ret    

00802284 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802284:	f3 0f 1e fb          	endbr32 
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80228e:	68 4d 2f 80 00       	push   $0x802f4d
  802293:	ff 75 0c             	pushl  0xc(%ebp)
  802296:	e8 8c e6 ff ff       	call   800927 <strcpy>
	return 0;
}
  80229b:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a0:	c9                   	leave  
  8022a1:	c3                   	ret    

008022a2 <devcons_write>:
{
  8022a2:	f3 0f 1e fb          	endbr32 
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	57                   	push   %edi
  8022aa:	56                   	push   %esi
  8022ab:	53                   	push   %ebx
  8022ac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022b2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022bd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022c0:	73 31                	jae    8022f3 <devcons_write+0x51>
		m = n - tot;
  8022c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022c5:	29 f3                	sub    %esi,%ebx
  8022c7:	83 fb 7f             	cmp    $0x7f,%ebx
  8022ca:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022cf:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022d2:	83 ec 04             	sub    $0x4,%esp
  8022d5:	53                   	push   %ebx
  8022d6:	89 f0                	mov    %esi,%eax
  8022d8:	03 45 0c             	add    0xc(%ebp),%eax
  8022db:	50                   	push   %eax
  8022dc:	57                   	push   %edi
  8022dd:	e8 43 e8 ff ff       	call   800b25 <memmove>
		sys_cputs(buf, m);
  8022e2:	83 c4 08             	add    $0x8,%esp
  8022e5:	53                   	push   %ebx
  8022e6:	57                   	push   %edi
  8022e7:	e8 f5 e9 ff ff       	call   800ce1 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8022ec:	01 de                	add    %ebx,%esi
  8022ee:	83 c4 10             	add    $0x10,%esp
  8022f1:	eb ca                	jmp    8022bd <devcons_write+0x1b>
}
  8022f3:	89 f0                	mov    %esi,%eax
  8022f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    

008022fd <devcons_read>:
{
  8022fd:	f3 0f 1e fb          	endbr32 
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	83 ec 08             	sub    $0x8,%esp
  802307:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80230c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802310:	74 21                	je     802333 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802312:	e8 ec e9 ff ff       	call   800d03 <sys_cgetc>
  802317:	85 c0                	test   %eax,%eax
  802319:	75 07                	jne    802322 <devcons_read+0x25>
		sys_yield();
  80231b:	e8 4d ea ff ff       	call   800d6d <sys_yield>
  802320:	eb f0                	jmp    802312 <devcons_read+0x15>
	if (c < 0)
  802322:	78 0f                	js     802333 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802324:	83 f8 04             	cmp    $0x4,%eax
  802327:	74 0c                	je     802335 <devcons_read+0x38>
	*(char*)vbuf = c;
  802329:	8b 55 0c             	mov    0xc(%ebp),%edx
  80232c:	88 02                	mov    %al,(%edx)
	return 1;
  80232e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    
		return 0;
  802335:	b8 00 00 00 00       	mov    $0x0,%eax
  80233a:	eb f7                	jmp    802333 <devcons_read+0x36>

0080233c <cputchar>:
{
  80233c:	f3 0f 1e fb          	endbr32 
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802346:	8b 45 08             	mov    0x8(%ebp),%eax
  802349:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80234c:	6a 01                	push   $0x1
  80234e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802351:	50                   	push   %eax
  802352:	e8 8a e9 ff ff       	call   800ce1 <sys_cputs>
}
  802357:	83 c4 10             	add    $0x10,%esp
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <getchar>:
{
  80235c:	f3 0f 1e fb          	endbr32 
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802366:	6a 01                	push   $0x1
  802368:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80236b:	50                   	push   %eax
  80236c:	6a 00                	push   $0x0
  80236e:	e8 4e f1 ff ff       	call   8014c1 <read>
	if (r < 0)
  802373:	83 c4 10             	add    $0x10,%esp
  802376:	85 c0                	test   %eax,%eax
  802378:	78 06                	js     802380 <getchar+0x24>
	if (r < 1)
  80237a:	74 06                	je     802382 <getchar+0x26>
	return c;
  80237c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802380:	c9                   	leave  
  802381:	c3                   	ret    
		return -E_EOF;
  802382:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802387:	eb f7                	jmp    802380 <getchar+0x24>

00802389 <iscons>:
{
  802389:	f3 0f 1e fb          	endbr32 
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802396:	50                   	push   %eax
  802397:	ff 75 08             	pushl  0x8(%ebp)
  80239a:	e8 9a ee ff ff       	call   801239 <fd_lookup>
  80239f:	83 c4 10             	add    $0x10,%esp
  8023a2:	85 c0                	test   %eax,%eax
  8023a4:	78 11                	js     8023b7 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8023a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a9:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023af:	39 10                	cmp    %edx,(%eax)
  8023b1:	0f 94 c0             	sete   %al
  8023b4:	0f b6 c0             	movzbl %al,%eax
}
  8023b7:	c9                   	leave  
  8023b8:	c3                   	ret    

008023b9 <opencons>:
{
  8023b9:	f3 0f 1e fb          	endbr32 
  8023bd:	55                   	push   %ebp
  8023be:	89 e5                	mov    %esp,%ebp
  8023c0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c6:	50                   	push   %eax
  8023c7:	e8 17 ee ff ff       	call   8011e3 <fd_alloc>
  8023cc:	83 c4 10             	add    $0x10,%esp
  8023cf:	85 c0                	test   %eax,%eax
  8023d1:	78 3a                	js     80240d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d3:	83 ec 04             	sub    $0x4,%esp
  8023d6:	68 07 04 00 00       	push   $0x407
  8023db:	ff 75 f4             	pushl  -0xc(%ebp)
  8023de:	6a 00                	push   $0x0
  8023e0:	e8 ab e9 ff ff       	call   800d90 <sys_page_alloc>
  8023e5:	83 c4 10             	add    $0x10,%esp
  8023e8:	85 c0                	test   %eax,%eax
  8023ea:	78 21                	js     80240d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8023ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ef:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023f5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802401:	83 ec 0c             	sub    $0xc,%esp
  802404:	50                   	push   %eax
  802405:	e8 aa ed ff ff       	call   8011b4 <fd2num>
  80240a:	83 c4 10             	add    $0x10,%esp
}
  80240d:	c9                   	leave  
  80240e:	c3                   	ret    

0080240f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80240f:	f3 0f 1e fb          	endbr32 
  802413:	55                   	push   %ebp
  802414:	89 e5                	mov    %esp,%ebp
  802416:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802419:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802420:	74 0a                	je     80242c <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802422:	8b 45 08             	mov    0x8(%ebp),%eax
  802425:	a3 00 70 80 00       	mov    %eax,0x807000

}
  80242a:	c9                   	leave  
  80242b:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  80242c:	83 ec 04             	sub    $0x4,%esp
  80242f:	6a 07                	push   $0x7
  802431:	68 00 f0 bf ee       	push   $0xeebff000
  802436:	6a 00                	push   $0x0
  802438:	e8 53 e9 ff ff       	call   800d90 <sys_page_alloc>
  80243d:	83 c4 10             	add    $0x10,%esp
  802440:	85 c0                	test   %eax,%eax
  802442:	78 2a                	js     80246e <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802444:	83 ec 08             	sub    $0x8,%esp
  802447:	68 82 24 80 00       	push   $0x802482
  80244c:	6a 00                	push   $0x0
  80244e:	e8 f7 e9 ff ff       	call   800e4a <sys_env_set_pgfault_upcall>
  802453:	83 c4 10             	add    $0x10,%esp
  802456:	85 c0                	test   %eax,%eax
  802458:	79 c8                	jns    802422 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  80245a:	83 ec 04             	sub    $0x4,%esp
  80245d:	68 88 2f 80 00       	push   $0x802f88
  802462:	6a 2c                	push   $0x2c
  802464:	68 be 2f 80 00       	push   $0x802fbe
  802469:	e8 c8 dd ff ff       	call   800236 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  80246e:	83 ec 04             	sub    $0x4,%esp
  802471:	68 5c 2f 80 00       	push   $0x802f5c
  802476:	6a 22                	push   $0x22
  802478:	68 be 2f 80 00       	push   $0x802fbe
  80247d:	e8 b4 dd ff ff       	call   800236 <_panic>

00802482 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802482:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802483:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  802488:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80248a:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  80248d:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802491:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802496:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  80249a:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  80249c:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  80249f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  8024a0:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  8024a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  8024a4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  8024a5:	c3                   	ret    

008024a6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024a6:	f3 0f 1e fb          	endbr32 
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	56                   	push   %esi
  8024ae:	53                   	push   %ebx
  8024af:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8024b8:	85 c0                	test   %eax,%eax
  8024ba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024bf:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8024c2:	83 ec 0c             	sub    $0xc,%esp
  8024c5:	50                   	push   %eax
  8024c6:	e8 cb e9 ff ff       	call   800e96 <sys_ipc_recv>
  8024cb:	83 c4 10             	add    $0x10,%esp
  8024ce:	85 c0                	test   %eax,%eax
  8024d0:	75 2b                	jne    8024fd <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8024d2:	85 f6                	test   %esi,%esi
  8024d4:	74 0a                	je     8024e0 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8024d6:	a1 20 44 80 00       	mov    0x804420,%eax
  8024db:	8b 40 74             	mov    0x74(%eax),%eax
  8024de:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8024e0:	85 db                	test   %ebx,%ebx
  8024e2:	74 0a                	je     8024ee <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8024e4:	a1 20 44 80 00       	mov    0x804420,%eax
  8024e9:	8b 40 78             	mov    0x78(%eax),%eax
  8024ec:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8024ee:	a1 20 44 80 00       	mov    0x804420,%eax
  8024f3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8024f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024f9:	5b                   	pop    %ebx
  8024fa:	5e                   	pop    %esi
  8024fb:	5d                   	pop    %ebp
  8024fc:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8024fd:	85 f6                	test   %esi,%esi
  8024ff:	74 06                	je     802507 <ipc_recv+0x61>
  802501:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802507:	85 db                	test   %ebx,%ebx
  802509:	74 eb                	je     8024f6 <ipc_recv+0x50>
  80250b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802511:	eb e3                	jmp    8024f6 <ipc_recv+0x50>

00802513 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802513:	f3 0f 1e fb          	endbr32 
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	57                   	push   %edi
  80251b:	56                   	push   %esi
  80251c:	53                   	push   %ebx
  80251d:	83 ec 0c             	sub    $0xc,%esp
  802520:	8b 7d 08             	mov    0x8(%ebp),%edi
  802523:	8b 75 0c             	mov    0xc(%ebp),%esi
  802526:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802529:	85 db                	test   %ebx,%ebx
  80252b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802530:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802533:	ff 75 14             	pushl  0x14(%ebp)
  802536:	53                   	push   %ebx
  802537:	56                   	push   %esi
  802538:	57                   	push   %edi
  802539:	e8 31 e9 ff ff       	call   800e6f <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80253e:	83 c4 10             	add    $0x10,%esp
  802541:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802544:	75 07                	jne    80254d <ipc_send+0x3a>
			sys_yield();
  802546:	e8 22 e8 ff ff       	call   800d6d <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80254b:	eb e6                	jmp    802533 <ipc_send+0x20>
		}
		else if (ret == 0)
  80254d:	85 c0                	test   %eax,%eax
  80254f:	75 08                	jne    802559 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802551:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802554:	5b                   	pop    %ebx
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802559:	50                   	push   %eax
  80255a:	68 cc 2f 80 00       	push   $0x802fcc
  80255f:	6a 48                	push   $0x48
  802561:	68 da 2f 80 00       	push   $0x802fda
  802566:	e8 cb dc ff ff       	call   800236 <_panic>

0080256b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80256b:	f3 0f 1e fb          	endbr32 
  80256f:	55                   	push   %ebp
  802570:	89 e5                	mov    %esp,%ebp
  802572:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802575:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80257a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80257d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802583:	8b 52 50             	mov    0x50(%edx),%edx
  802586:	39 ca                	cmp    %ecx,%edx
  802588:	74 11                	je     80259b <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80258a:	83 c0 01             	add    $0x1,%eax
  80258d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802592:	75 e6                	jne    80257a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802594:	b8 00 00 00 00       	mov    $0x0,%eax
  802599:	eb 0b                	jmp    8025a6 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80259b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80259e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025a3:	8b 40 48             	mov    0x48(%eax),%eax
}
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    

008025a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025a8:	f3 0f 1e fb          	endbr32 
  8025ac:	55                   	push   %ebp
  8025ad:	89 e5                	mov    %esp,%ebp
  8025af:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025b2:	89 c2                	mov    %eax,%edx
  8025b4:	c1 ea 16             	shr    $0x16,%edx
  8025b7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8025be:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8025c3:	f6 c1 01             	test   $0x1,%cl
  8025c6:	74 1c                	je     8025e4 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8025c8:	c1 e8 0c             	shr    $0xc,%eax
  8025cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025d2:	a8 01                	test   $0x1,%al
  8025d4:	74 0e                	je     8025e4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025d6:	c1 e8 0c             	shr    $0xc,%eax
  8025d9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8025e0:	ef 
  8025e1:	0f b7 d2             	movzwl %dx,%edx
}
  8025e4:	89 d0                	mov    %edx,%eax
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__udivdi3>:
  8025f0:	f3 0f 1e fb          	endbr32 
  8025f4:	55                   	push   %ebp
  8025f5:	57                   	push   %edi
  8025f6:	56                   	push   %esi
  8025f7:	53                   	push   %ebx
  8025f8:	83 ec 1c             	sub    $0x1c,%esp
  8025fb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802603:	8b 74 24 34          	mov    0x34(%esp),%esi
  802607:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80260b:	85 d2                	test   %edx,%edx
  80260d:	75 19                	jne    802628 <__udivdi3+0x38>
  80260f:	39 f3                	cmp    %esi,%ebx
  802611:	76 4d                	jbe    802660 <__udivdi3+0x70>
  802613:	31 ff                	xor    %edi,%edi
  802615:	89 e8                	mov    %ebp,%eax
  802617:	89 f2                	mov    %esi,%edx
  802619:	f7 f3                	div    %ebx
  80261b:	89 fa                	mov    %edi,%edx
  80261d:	83 c4 1c             	add    $0x1c,%esp
  802620:	5b                   	pop    %ebx
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	8d 76 00             	lea    0x0(%esi),%esi
  802628:	39 f2                	cmp    %esi,%edx
  80262a:	76 14                	jbe    802640 <__udivdi3+0x50>
  80262c:	31 ff                	xor    %edi,%edi
  80262e:	31 c0                	xor    %eax,%eax
  802630:	89 fa                	mov    %edi,%edx
  802632:	83 c4 1c             	add    $0x1c,%esp
  802635:	5b                   	pop    %ebx
  802636:	5e                   	pop    %esi
  802637:	5f                   	pop    %edi
  802638:	5d                   	pop    %ebp
  802639:	c3                   	ret    
  80263a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802640:	0f bd fa             	bsr    %edx,%edi
  802643:	83 f7 1f             	xor    $0x1f,%edi
  802646:	75 48                	jne    802690 <__udivdi3+0xa0>
  802648:	39 f2                	cmp    %esi,%edx
  80264a:	72 06                	jb     802652 <__udivdi3+0x62>
  80264c:	31 c0                	xor    %eax,%eax
  80264e:	39 eb                	cmp    %ebp,%ebx
  802650:	77 de                	ja     802630 <__udivdi3+0x40>
  802652:	b8 01 00 00 00       	mov    $0x1,%eax
  802657:	eb d7                	jmp    802630 <__udivdi3+0x40>
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 d9                	mov    %ebx,%ecx
  802662:	85 db                	test   %ebx,%ebx
  802664:	75 0b                	jne    802671 <__udivdi3+0x81>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f3                	div    %ebx
  80266f:	89 c1                	mov    %eax,%ecx
  802671:	31 d2                	xor    %edx,%edx
  802673:	89 f0                	mov    %esi,%eax
  802675:	f7 f1                	div    %ecx
  802677:	89 c6                	mov    %eax,%esi
  802679:	89 e8                	mov    %ebp,%eax
  80267b:	89 f7                	mov    %esi,%edi
  80267d:	f7 f1                	div    %ecx
  80267f:	89 fa                	mov    %edi,%edx
  802681:	83 c4 1c             	add    $0x1c,%esp
  802684:	5b                   	pop    %ebx
  802685:	5e                   	pop    %esi
  802686:	5f                   	pop    %edi
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	89 f9                	mov    %edi,%ecx
  802692:	b8 20 00 00 00       	mov    $0x20,%eax
  802697:	29 f8                	sub    %edi,%eax
  802699:	d3 e2                	shl    %cl,%edx
  80269b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80269f:	89 c1                	mov    %eax,%ecx
  8026a1:	89 da                	mov    %ebx,%edx
  8026a3:	d3 ea                	shr    %cl,%edx
  8026a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026a9:	09 d1                	or     %edx,%ecx
  8026ab:	89 f2                	mov    %esi,%edx
  8026ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	d3 e3                	shl    %cl,%ebx
  8026b5:	89 c1                	mov    %eax,%ecx
  8026b7:	d3 ea                	shr    %cl,%edx
  8026b9:	89 f9                	mov    %edi,%ecx
  8026bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026bf:	89 eb                	mov    %ebp,%ebx
  8026c1:	d3 e6                	shl    %cl,%esi
  8026c3:	89 c1                	mov    %eax,%ecx
  8026c5:	d3 eb                	shr    %cl,%ebx
  8026c7:	09 de                	or     %ebx,%esi
  8026c9:	89 f0                	mov    %esi,%eax
  8026cb:	f7 74 24 08          	divl   0x8(%esp)
  8026cf:	89 d6                	mov    %edx,%esi
  8026d1:	89 c3                	mov    %eax,%ebx
  8026d3:	f7 64 24 0c          	mull   0xc(%esp)
  8026d7:	39 d6                	cmp    %edx,%esi
  8026d9:	72 15                	jb     8026f0 <__udivdi3+0x100>
  8026db:	89 f9                	mov    %edi,%ecx
  8026dd:	d3 e5                	shl    %cl,%ebp
  8026df:	39 c5                	cmp    %eax,%ebp
  8026e1:	73 04                	jae    8026e7 <__udivdi3+0xf7>
  8026e3:	39 d6                	cmp    %edx,%esi
  8026e5:	74 09                	je     8026f0 <__udivdi3+0x100>
  8026e7:	89 d8                	mov    %ebx,%eax
  8026e9:	31 ff                	xor    %edi,%edi
  8026eb:	e9 40 ff ff ff       	jmp    802630 <__udivdi3+0x40>
  8026f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8026f3:	31 ff                	xor    %edi,%edi
  8026f5:	e9 36 ff ff ff       	jmp    802630 <__udivdi3+0x40>
  8026fa:	66 90                	xchg   %ax,%ax
  8026fc:	66 90                	xchg   %ax,%ax
  8026fe:	66 90                	xchg   %ax,%ax

00802700 <__umoddi3>:
  802700:	f3 0f 1e fb          	endbr32 
  802704:	55                   	push   %ebp
  802705:	57                   	push   %edi
  802706:	56                   	push   %esi
  802707:	53                   	push   %ebx
  802708:	83 ec 1c             	sub    $0x1c,%esp
  80270b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80270f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802713:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802717:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80271b:	85 c0                	test   %eax,%eax
  80271d:	75 19                	jne    802738 <__umoddi3+0x38>
  80271f:	39 df                	cmp    %ebx,%edi
  802721:	76 5d                	jbe    802780 <__umoddi3+0x80>
  802723:	89 f0                	mov    %esi,%eax
  802725:	89 da                	mov    %ebx,%edx
  802727:	f7 f7                	div    %edi
  802729:	89 d0                	mov    %edx,%eax
  80272b:	31 d2                	xor    %edx,%edx
  80272d:	83 c4 1c             	add    $0x1c,%esp
  802730:	5b                   	pop    %ebx
  802731:	5e                   	pop    %esi
  802732:	5f                   	pop    %edi
  802733:	5d                   	pop    %ebp
  802734:	c3                   	ret    
  802735:	8d 76 00             	lea    0x0(%esi),%esi
  802738:	89 f2                	mov    %esi,%edx
  80273a:	39 d8                	cmp    %ebx,%eax
  80273c:	76 12                	jbe    802750 <__umoddi3+0x50>
  80273e:	89 f0                	mov    %esi,%eax
  802740:	89 da                	mov    %ebx,%edx
  802742:	83 c4 1c             	add    $0x1c,%esp
  802745:	5b                   	pop    %ebx
  802746:	5e                   	pop    %esi
  802747:	5f                   	pop    %edi
  802748:	5d                   	pop    %ebp
  802749:	c3                   	ret    
  80274a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802750:	0f bd e8             	bsr    %eax,%ebp
  802753:	83 f5 1f             	xor    $0x1f,%ebp
  802756:	75 50                	jne    8027a8 <__umoddi3+0xa8>
  802758:	39 d8                	cmp    %ebx,%eax
  80275a:	0f 82 e0 00 00 00    	jb     802840 <__umoddi3+0x140>
  802760:	89 d9                	mov    %ebx,%ecx
  802762:	39 f7                	cmp    %esi,%edi
  802764:	0f 86 d6 00 00 00    	jbe    802840 <__umoddi3+0x140>
  80276a:	89 d0                	mov    %edx,%eax
  80276c:	89 ca                	mov    %ecx,%edx
  80276e:	83 c4 1c             	add    $0x1c,%esp
  802771:	5b                   	pop    %ebx
  802772:	5e                   	pop    %esi
  802773:	5f                   	pop    %edi
  802774:	5d                   	pop    %ebp
  802775:	c3                   	ret    
  802776:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80277d:	8d 76 00             	lea    0x0(%esi),%esi
  802780:	89 fd                	mov    %edi,%ebp
  802782:	85 ff                	test   %edi,%edi
  802784:	75 0b                	jne    802791 <__umoddi3+0x91>
  802786:	b8 01 00 00 00       	mov    $0x1,%eax
  80278b:	31 d2                	xor    %edx,%edx
  80278d:	f7 f7                	div    %edi
  80278f:	89 c5                	mov    %eax,%ebp
  802791:	89 d8                	mov    %ebx,%eax
  802793:	31 d2                	xor    %edx,%edx
  802795:	f7 f5                	div    %ebp
  802797:	89 f0                	mov    %esi,%eax
  802799:	f7 f5                	div    %ebp
  80279b:	89 d0                	mov    %edx,%eax
  80279d:	31 d2                	xor    %edx,%edx
  80279f:	eb 8c                	jmp    80272d <__umoddi3+0x2d>
  8027a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a8:	89 e9                	mov    %ebp,%ecx
  8027aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8027af:	29 ea                	sub    %ebp,%edx
  8027b1:	d3 e0                	shl    %cl,%eax
  8027b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027b7:	89 d1                	mov    %edx,%ecx
  8027b9:	89 f8                	mov    %edi,%eax
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8027c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027c9:	09 c1                	or     %eax,%ecx
  8027cb:	89 d8                	mov    %ebx,%eax
  8027cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027d1:	89 e9                	mov    %ebp,%ecx
  8027d3:	d3 e7                	shl    %cl,%edi
  8027d5:	89 d1                	mov    %edx,%ecx
  8027d7:	d3 e8                	shr    %cl,%eax
  8027d9:	89 e9                	mov    %ebp,%ecx
  8027db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8027df:	d3 e3                	shl    %cl,%ebx
  8027e1:	89 c7                	mov    %eax,%edi
  8027e3:	89 d1                	mov    %edx,%ecx
  8027e5:	89 f0                	mov    %esi,%eax
  8027e7:	d3 e8                	shr    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	89 fa                	mov    %edi,%edx
  8027ed:	d3 e6                	shl    %cl,%esi
  8027ef:	09 d8                	or     %ebx,%eax
  8027f1:	f7 74 24 08          	divl   0x8(%esp)
  8027f5:	89 d1                	mov    %edx,%ecx
  8027f7:	89 f3                	mov    %esi,%ebx
  8027f9:	f7 64 24 0c          	mull   0xc(%esp)
  8027fd:	89 c6                	mov    %eax,%esi
  8027ff:	89 d7                	mov    %edx,%edi
  802801:	39 d1                	cmp    %edx,%ecx
  802803:	72 06                	jb     80280b <__umoddi3+0x10b>
  802805:	75 10                	jne    802817 <__umoddi3+0x117>
  802807:	39 c3                	cmp    %eax,%ebx
  802809:	73 0c                	jae    802817 <__umoddi3+0x117>
  80280b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80280f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802813:	89 d7                	mov    %edx,%edi
  802815:	89 c6                	mov    %eax,%esi
  802817:	89 ca                	mov    %ecx,%edx
  802819:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80281e:	29 f3                	sub    %esi,%ebx
  802820:	19 fa                	sbb    %edi,%edx
  802822:	89 d0                	mov    %edx,%eax
  802824:	d3 e0                	shl    %cl,%eax
  802826:	89 e9                	mov    %ebp,%ecx
  802828:	d3 eb                	shr    %cl,%ebx
  80282a:	d3 ea                	shr    %cl,%edx
  80282c:	09 d8                	or     %ebx,%eax
  80282e:	83 c4 1c             	add    $0x1c,%esp
  802831:	5b                   	pop    %ebx
  802832:	5e                   	pop    %esi
  802833:	5f                   	pop    %edi
  802834:	5d                   	pop    %ebp
  802835:	c3                   	ret    
  802836:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80283d:	8d 76 00             	lea    0x0(%esi),%esi
  802840:	29 fe                	sub    %edi,%esi
  802842:	19 c3                	sbb    %eax,%ebx
  802844:	89 f2                	mov    %esi,%edx
  802846:	89 d9                	mov    %ebx,%ecx
  802848:	e9 1d ff ff ff       	jmp    80276a <__umoddi3+0x6a>
