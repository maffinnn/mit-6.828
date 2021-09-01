
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 07 01 00 00       	call   800138 <libmain>
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
  80003c:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  800042:	c7 05 00 40 80 00 80 	movl   $0x802a80,0x804000
  800049:	2a 80 00 

	cprintf("icode startup\n");
  80004c:	68 86 2a 80 00       	push   $0x802a86
  800051:	e8 31 02 00 00       	call   800287 <cprintf>

	cprintf("icode: open /motd\n");
  800056:	c7 04 24 95 2a 80 00 	movl   $0x802a95,(%esp)
  80005d:	e8 25 02 00 00       	call   800287 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800062:	83 c4 08             	add    $0x8,%esp
  800065:	6a 00                	push   $0x0
  800067:	68 a8 2a 80 00       	push   $0x802aa8
  80006c:	e8 c8 15 00 00       	call   801639 <open>
  800071:	89 c6                	mov    %eax,%esi
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	85 c0                	test   %eax,%eax
  800078:	78 18                	js     800092 <umain+0x5f>
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
  80007a:	83 ec 0c             	sub    $0xc,%esp
  80007d:	68 d1 2a 80 00       	push   $0x802ad1
  800082:	e8 00 02 00 00       	call   800287 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  800090:	eb 1f                	jmp    8000b1 <umain+0x7e>
		panic("icode: open /motd: %e", fd);
  800092:	50                   	push   %eax
  800093:	68 ae 2a 80 00       	push   $0x802aae
  800098:	6a 0f                	push   $0xf
  80009a:	68 c4 2a 80 00       	push   $0x802ac4
  80009f:	e8 fc 00 00 00       	call   8001a0 <_panic>
		sys_cputs(buf, n);
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	50                   	push   %eax
  8000a8:	53                   	push   %ebx
  8000a9:	e8 9d 0b 00 00       	call   800c4b <sys_cputs>
  8000ae:	83 c4 10             	add    $0x10,%esp
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	68 00 02 00 00       	push   $0x200
  8000b9:	53                   	push   %ebx
  8000ba:	56                   	push   %esi
  8000bb:	e8 de 10 00 00       	call   80119e <read>
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	85 c0                	test   %eax,%eax
  8000c5:	7f dd                	jg     8000a4 <umain+0x71>

	cprintf("icode: close /motd\n");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 e4 2a 80 00       	push   $0x802ae4
  8000cf:	e8 b3 01 00 00       	call   800287 <cprintf>
	close(fd);
  8000d4:	89 34 24             	mov    %esi,(%esp)
  8000d7:	e8 78 0f 00 00       	call   801054 <close>

	cprintf("icode: spawn /init\n");
  8000dc:	c7 04 24 f8 2a 80 00 	movl   $0x802af8,(%esp)
  8000e3:	e8 9f 01 00 00       	call   800287 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ef:	68 0c 2b 80 00       	push   $0x802b0c
  8000f4:	68 15 2b 80 00       	push   $0x802b15
  8000f9:	68 1f 2b 80 00       	push   $0x802b1f
  8000fe:	68 1e 2b 80 00       	push   $0x802b1e
  800103:	e8 57 1b 00 00       	call   801c5f <spawnl>
  800108:	83 c4 20             	add    $0x20,%esp
  80010b:	85 c0                	test   %eax,%eax
  80010d:	78 17                	js     800126 <umain+0xf3>
		panic("icode: spawn /init: %e", r);

	cprintf("icode: exiting\n");
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	68 3b 2b 80 00       	push   $0x802b3b
  800117:	e8 6b 01 00 00       	call   800287 <cprintf>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
		panic("icode: spawn /init: %e", r);
  800126:	50                   	push   %eax
  800127:	68 24 2b 80 00       	push   $0x802b24
  80012c:	6a 1a                	push   $0x1a
  80012e:	68 c4 2a 80 00       	push   $0x802ac4
  800133:	e8 68 00 00 00       	call   8001a0 <_panic>

00800138 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800138:	f3 0f 1e fb          	endbr32 
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800144:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800147:	e8 68 0b 00 00       	call   800cb4 <sys_getenvid>
  80014c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800151:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800154:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800159:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015e:	85 db                	test   %ebx,%ebx
  800160:	7e 07                	jle    800169 <libmain+0x31>
		binaryname = argv[0];
  800162:	8b 06                	mov    (%esi),%eax
  800164:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	e8 c0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800173:	e8 0a 00 00 00       	call   800182 <exit>
}
  800178:	83 c4 10             	add    $0x10,%esp
  80017b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800182:	f3 0f 1e fb          	endbr32 
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80018c:	e8 f4 0e 00 00       	call   801085 <close_all>
	sys_env_destroy(0);
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	6a 00                	push   $0x0
  800196:	e8 f5 0a 00 00       	call   800c90 <sys_env_destroy>
}
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a0:	f3 0f 1e fb          	endbr32 
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ac:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8001b2:	e8 fd 0a 00 00       	call   800cb4 <sys_getenvid>
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	56                   	push   %esi
  8001c1:	50                   	push   %eax
  8001c2:	68 58 2b 80 00       	push   $0x802b58
  8001c7:	e8 bb 00 00 00       	call   800287 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	53                   	push   %ebx
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	e8 5a 00 00 00       	call   800232 <vcprintf>
	cprintf("\n");
  8001d8:	c7 04 24 a7 30 80 00 	movl   $0x8030a7,(%esp)
  8001df:	e8 a3 00 00 00       	call   800287 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x47>

008001ea <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ea:	f3 0f 1e fb          	endbr32 
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 04             	sub    $0x4,%esp
  8001f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f8:	8b 13                	mov    (%ebx),%edx
  8001fa:	8d 42 01             	lea    0x1(%edx),%eax
  8001fd:	89 03                	mov    %eax,(%ebx)
  8001ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800202:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800206:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020b:	74 09                	je     800216 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80020d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800211:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800214:	c9                   	leave  
  800215:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800216:	83 ec 08             	sub    $0x8,%esp
  800219:	68 ff 00 00 00       	push   $0xff
  80021e:	8d 43 08             	lea    0x8(%ebx),%eax
  800221:	50                   	push   %eax
  800222:	e8 24 0a 00 00       	call   800c4b <sys_cputs>
		b->idx = 0;
  800227:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	eb db                	jmp    80020d <putch+0x23>

00800232 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800232:	f3 0f 1e fb          	endbr32 
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800246:	00 00 00 
	b.cnt = 0;
  800249:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800250:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800253:	ff 75 0c             	pushl  0xc(%ebp)
  800256:	ff 75 08             	pushl  0x8(%ebp)
  800259:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	68 ea 01 80 00       	push   $0x8001ea
  800265:	e8 20 01 00 00       	call   80038a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026a:	83 c4 08             	add    $0x8,%esp
  80026d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800273:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800279:	50                   	push   %eax
  80027a:	e8 cc 09 00 00       	call   800c4b <sys_cputs>

	return b.cnt;
}
  80027f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800285:	c9                   	leave  
  800286:	c3                   	ret    

00800287 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800287:	f3 0f 1e fb          	endbr32 
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800291:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800294:	50                   	push   %eax
  800295:	ff 75 08             	pushl  0x8(%ebp)
  800298:	e8 95 ff ff ff       	call   800232 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 1c             	sub    $0x1c,%esp
  8002a8:	89 c7                	mov    %eax,%edi
  8002aa:	89 d6                	mov    %edx,%esi
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b2:	89 d1                	mov    %edx,%ecx
  8002b4:	89 c2                	mov    %eax,%edx
  8002b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8002c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002cc:	39 c2                	cmp    %eax,%edx
  8002ce:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d1:	72 3e                	jb     800311 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	ff 75 18             	pushl  0x18(%ebp)
  8002d9:	83 eb 01             	sub    $0x1,%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	50                   	push   %eax
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ed:	e8 1e 25 00 00       	call   802810 <__udivdi3>
  8002f2:	83 c4 18             	add    $0x18,%esp
  8002f5:	52                   	push   %edx
  8002f6:	50                   	push   %eax
  8002f7:	89 f2                	mov    %esi,%edx
  8002f9:	89 f8                	mov    %edi,%eax
  8002fb:	e8 9f ff ff ff       	call   80029f <printnum>
  800300:	83 c4 20             	add    $0x20,%esp
  800303:	eb 13                	jmp    800318 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	56                   	push   %esi
  800309:	ff 75 18             	pushl  0x18(%ebp)
  80030c:	ff d7                	call   *%edi
  80030e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800311:	83 eb 01             	sub    $0x1,%ebx
  800314:	85 db                	test   %ebx,%ebx
  800316:	7f ed                	jg     800305 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800318:	83 ec 08             	sub    $0x8,%esp
  80031b:	56                   	push   %esi
  80031c:	83 ec 04             	sub    $0x4,%esp
  80031f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800322:	ff 75 e0             	pushl  -0x20(%ebp)
  800325:	ff 75 dc             	pushl  -0x24(%ebp)
  800328:	ff 75 d8             	pushl  -0x28(%ebp)
  80032b:	e8 f0 25 00 00       	call   802920 <__umoddi3>
  800330:	83 c4 14             	add    $0x14,%esp
  800333:	0f be 80 7b 2b 80 00 	movsbl 0x802b7b(%eax),%eax
  80033a:	50                   	push   %eax
  80033b:	ff d7                	call   *%edi
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800348:	f3 0f 1e fb          	endbr32 
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800352:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800356:	8b 10                	mov    (%eax),%edx
  800358:	3b 50 04             	cmp    0x4(%eax),%edx
  80035b:	73 0a                	jae    800367 <sprintputch+0x1f>
		*b->buf++ = ch;
  80035d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	88 02                	mov    %al,(%edx)
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <printfmt>:
{
  800369:	f3 0f 1e fb          	endbr32 
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800373:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800376:	50                   	push   %eax
  800377:	ff 75 10             	pushl  0x10(%ebp)
  80037a:	ff 75 0c             	pushl  0xc(%ebp)
  80037d:	ff 75 08             	pushl  0x8(%ebp)
  800380:	e8 05 00 00 00       	call   80038a <vprintfmt>
}
  800385:	83 c4 10             	add    $0x10,%esp
  800388:	c9                   	leave  
  800389:	c3                   	ret    

0080038a <vprintfmt>:
{
  80038a:	f3 0f 1e fb          	endbr32 
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 3c             	sub    $0x3c,%esp
  800397:	8b 75 08             	mov    0x8(%ebp),%esi
  80039a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a0:	e9 8e 03 00 00       	jmp    800733 <vprintfmt+0x3a9>
		padc = ' ';
  8003a5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003be:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8d 47 01             	lea    0x1(%edi),%eax
  8003c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c9:	0f b6 17             	movzbl (%edi),%edx
  8003cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cf:	3c 55                	cmp    $0x55,%al
  8003d1:	0f 87 df 03 00 00    	ja     8007b6 <vprintfmt+0x42c>
  8003d7:	0f b6 c0             	movzbl %al,%eax
  8003da:	3e ff 24 85 c0 2c 80 	notrack jmp *0x802cc0(,%eax,4)
  8003e1:	00 
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003e9:	eb d8                	jmp    8003c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003f2:	eb cf                	jmp    8003c3 <vprintfmt+0x39>
  8003f4:	0f b6 d2             	movzbl %dl,%edx
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800402:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800405:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800409:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80040c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040f:	83 f9 09             	cmp    $0x9,%ecx
  800412:	77 55                	ja     800469 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800414:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800417:	eb e9                	jmp    800402 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 40 04             	lea    0x4(%eax),%eax
  800427:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	79 90                	jns    8003c3 <vprintfmt+0x39>
				width = precision, precision = -1;
  800433:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800440:	eb 81                	jmp    8003c3 <vprintfmt+0x39>
  800442:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	ba 00 00 00 00       	mov    $0x0,%edx
  80044c:	0f 49 d0             	cmovns %eax,%edx
  80044f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800455:	e9 69 ff ff ff       	jmp    8003c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80045d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800464:	e9 5a ff ff ff       	jmp    8003c3 <vprintfmt+0x39>
  800469:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046f:	eb bc                	jmp    80042d <vprintfmt+0xa3>
			lflag++;
  800471:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800477:	e9 47 ff ff ff       	jmp    8003c3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 78 04             	lea    0x4(%eax),%edi
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	53                   	push   %ebx
  800486:	ff 30                	pushl  (%eax)
  800488:	ff d6                	call   *%esi
			break;
  80048a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80048d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800490:	e9 9b 02 00 00       	jmp    800730 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 78 04             	lea    0x4(%eax),%edi
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	99                   	cltd   
  80049e:	31 d0                	xor    %edx,%eax
  8004a0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a2:	83 f8 0f             	cmp    $0xf,%eax
  8004a5:	7f 23                	jg     8004ca <vprintfmt+0x140>
  8004a7:	8b 14 85 20 2e 80 00 	mov    0x802e20(,%eax,4),%edx
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	74 18                	je     8004ca <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004b2:	52                   	push   %edx
  8004b3:	68 29 2f 80 00       	push   $0x802f29
  8004b8:	53                   	push   %ebx
  8004b9:	56                   	push   %esi
  8004ba:	e8 aa fe ff ff       	call   800369 <printfmt>
  8004bf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c5:	e9 66 02 00 00       	jmp    800730 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8004ca:	50                   	push   %eax
  8004cb:	68 93 2b 80 00       	push   $0x802b93
  8004d0:	53                   	push   %ebx
  8004d1:	56                   	push   %esi
  8004d2:	e8 92 fe ff ff       	call   800369 <printfmt>
  8004d7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004da:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004dd:	e9 4e 02 00 00       	jmp    800730 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	83 c0 04             	add    $0x4,%eax
  8004e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	b8 8c 2b 80 00       	mov    $0x802b8c,%eax
  8004f7:	0f 45 c2             	cmovne %edx,%eax
  8004fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800501:	7e 06                	jle    800509 <vprintfmt+0x17f>
  800503:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800507:	75 0d                	jne    800516 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80050c:	89 c7                	mov    %eax,%edi
  80050e:	03 45 e0             	add    -0x20(%ebp),%eax
  800511:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800514:	eb 55                	jmp    80056b <vprintfmt+0x1e1>
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 d8             	pushl  -0x28(%ebp)
  80051c:	ff 75 cc             	pushl  -0x34(%ebp)
  80051f:	e8 46 03 00 00       	call   80086a <strnlen>
  800524:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800527:	29 c2                	sub    %eax,%edx
  800529:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800531:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800535:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	85 ff                	test   %edi,%edi
  80053a:	7e 11                	jle    80054d <vprintfmt+0x1c3>
					putch(padc, putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	ff 75 e0             	pushl  -0x20(%ebp)
  800543:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	83 ef 01             	sub    $0x1,%edi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb eb                	jmp    800538 <vprintfmt+0x1ae>
  80054d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800550:	85 d2                	test   %edx,%edx
  800552:	b8 00 00 00 00       	mov    $0x0,%eax
  800557:	0f 49 c2             	cmovns %edx,%eax
  80055a:	29 c2                	sub    %eax,%edx
  80055c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055f:	eb a8                	jmp    800509 <vprintfmt+0x17f>
					putch(ch, putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	53                   	push   %ebx
  800565:	52                   	push   %edx
  800566:	ff d6                	call   *%esi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800570:	83 c7 01             	add    $0x1,%edi
  800573:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800577:	0f be d0             	movsbl %al,%edx
  80057a:	85 d2                	test   %edx,%edx
  80057c:	74 4b                	je     8005c9 <vprintfmt+0x23f>
  80057e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800582:	78 06                	js     80058a <vprintfmt+0x200>
  800584:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800588:	78 1e                	js     8005a8 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80058a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80058e:	74 d1                	je     800561 <vprintfmt+0x1d7>
  800590:	0f be c0             	movsbl %al,%eax
  800593:	83 e8 20             	sub    $0x20,%eax
  800596:	83 f8 5e             	cmp    $0x5e,%eax
  800599:	76 c6                	jbe    800561 <vprintfmt+0x1d7>
					putch('?', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	53                   	push   %ebx
  80059f:	6a 3f                	push   $0x3f
  8005a1:	ff d6                	call   *%esi
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	eb c3                	jmp    80056b <vprintfmt+0x1e1>
  8005a8:	89 cf                	mov    %ecx,%edi
  8005aa:	eb 0e                	jmp    8005ba <vprintfmt+0x230>
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	85 ff                	test   %edi,%edi
  8005bc:	7f ee                	jg     8005ac <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8005be:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c4:	e9 67 01 00 00       	jmp    800730 <vprintfmt+0x3a6>
  8005c9:	89 cf                	mov    %ecx,%edi
  8005cb:	eb ed                	jmp    8005ba <vprintfmt+0x230>
	if (lflag >= 2)
  8005cd:	83 f9 01             	cmp    $0x1,%ecx
  8005d0:	7f 1b                	jg     8005ed <vprintfmt+0x263>
	else if (lflag)
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	74 63                	je     800639 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	99                   	cltd   
  8005df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 40 04             	lea    0x4(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005eb:	eb 17                	jmp    800604 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 50 04             	mov    0x4(%eax),%edx
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 40 08             	lea    0x8(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800604:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800607:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80060f:	85 c9                	test   %ecx,%ecx
  800611:	0f 89 ff 00 00 00    	jns    800716 <vprintfmt+0x38c>
				putch('-', putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 2d                	push   $0x2d
  80061d:	ff d6                	call   *%esi
				num = -(long long) num;
  80061f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800622:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800625:	f7 da                	neg    %edx
  800627:	83 d1 00             	adc    $0x0,%ecx
  80062a:	f7 d9                	neg    %ecx
  80062c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800634:	e9 dd 00 00 00       	jmp    800716 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	99                   	cltd   
  800642:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
  80064e:	eb b4                	jmp    800604 <vprintfmt+0x27a>
	if (lflag >= 2)
  800650:	83 f9 01             	cmp    $0x1,%ecx
  800653:	7f 1e                	jg     800673 <vprintfmt+0x2e9>
	else if (lflag)
  800655:	85 c9                	test   %ecx,%ecx
  800657:	74 32                	je     80068b <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800669:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80066e:	e9 a3 00 00 00       	jmp    800716 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	8b 48 04             	mov    0x4(%eax),%ecx
  80067b:	8d 40 08             	lea    0x8(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800681:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800686:	e9 8b 00 00 00       	jmp    800716 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	b9 00 00 00 00       	mov    $0x0,%ecx
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80069b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006a0:	eb 74                	jmp    800716 <vprintfmt+0x38c>
	if (lflag >= 2)
  8006a2:	83 f9 01             	cmp    $0x1,%ecx
  8006a5:	7f 1b                	jg     8006c2 <vprintfmt+0x338>
	else if (lflag)
  8006a7:	85 c9                	test   %ecx,%ecx
  8006a9:	74 2c                	je     8006d7 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006bb:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8006c0:	eb 54                	jmp    800716 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 10                	mov    (%eax),%edx
  8006c7:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ca:	8d 40 08             	lea    0x8(%eax),%eax
  8006cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006d0:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8006d5:	eb 3f                	jmp    800716 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 10                	mov    (%eax),%edx
  8006dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e1:	8d 40 04             	lea    0x4(%eax),%eax
  8006e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e7:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006ec:	eb 28                	jmp    800716 <vprintfmt+0x38c>
			putch('0', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 30                	push   $0x30
  8006f4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f6:	83 c4 08             	add    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 78                	push   $0x78
  8006fc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800708:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80070b:	8d 40 04             	lea    0x4(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800711:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800716:	83 ec 0c             	sub    $0xc,%esp
  800719:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80071d:	57                   	push   %edi
  80071e:	ff 75 e0             	pushl  -0x20(%ebp)
  800721:	50                   	push   %eax
  800722:	51                   	push   %ecx
  800723:	52                   	push   %edx
  800724:	89 da                	mov    %ebx,%edx
  800726:	89 f0                	mov    %esi,%eax
  800728:	e8 72 fb ff ff       	call   80029f <printnum>
			break;
  80072d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800733:	83 c7 01             	add    $0x1,%edi
  800736:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073a:	83 f8 25             	cmp    $0x25,%eax
  80073d:	0f 84 62 fc ff ff    	je     8003a5 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800743:	85 c0                	test   %eax,%eax
  800745:	0f 84 8b 00 00 00    	je     8007d6 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	ff d6                	call   *%esi
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	eb dc                	jmp    800733 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800757:	83 f9 01             	cmp    $0x1,%ecx
  80075a:	7f 1b                	jg     800777 <vprintfmt+0x3ed>
	else if (lflag)
  80075c:	85 c9                	test   %ecx,%ecx
  80075e:	74 2c                	je     80078c <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8b 10                	mov    (%eax),%edx
  800765:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076a:	8d 40 04             	lea    0x4(%eax),%eax
  80076d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800770:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800775:	eb 9f                	jmp    800716 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8b 10                	mov    (%eax),%edx
  80077c:	8b 48 04             	mov    0x4(%eax),%ecx
  80077f:	8d 40 08             	lea    0x8(%eax),%eax
  800782:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800785:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80078a:	eb 8a                	jmp    800716 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 10                	mov    (%eax),%edx
  800791:	b9 00 00 00 00       	mov    $0x0,%ecx
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007a1:	e9 70 ff ff ff       	jmp    800716 <vprintfmt+0x38c>
			putch(ch, putdat);
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	53                   	push   %ebx
  8007aa:	6a 25                	push   $0x25
  8007ac:	ff d6                	call   *%esi
			break;
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	e9 7a ff ff ff       	jmp    800730 <vprintfmt+0x3a6>
			putch('%', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	6a 25                	push   $0x25
  8007bc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	89 f8                	mov    %edi,%eax
  8007c3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007c7:	74 05                	je     8007ce <vprintfmt+0x444>
  8007c9:	83 e8 01             	sub    $0x1,%eax
  8007cc:	eb f5                	jmp    8007c3 <vprintfmt+0x439>
  8007ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d1:	e9 5a ff ff ff       	jmp    800730 <vprintfmt+0x3a6>
}
  8007d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5f                   	pop    %edi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007de:	f3 0f 1e fb          	endbr32 
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 18             	sub    $0x18,%esp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 26                	je     800829 <vsnprintf+0x4b>
  800803:	85 d2                	test   %edx,%edx
  800805:	7e 22                	jle    800829 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800807:	ff 75 14             	pushl  0x14(%ebp)
  80080a:	ff 75 10             	pushl  0x10(%ebp)
  80080d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800810:	50                   	push   %eax
  800811:	68 48 03 80 00       	push   $0x800348
  800816:	e8 6f fb ff ff       	call   80038a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800824:	83 c4 10             	add    $0x10,%esp
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    
		return -E_INVAL;
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082e:	eb f7                	jmp    800827 <vsnprintf+0x49>

00800830 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800830:	f3 0f 1e fb          	endbr32 
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083d:	50                   	push   %eax
  80083e:	ff 75 10             	pushl  0x10(%ebp)
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	ff 75 08             	pushl  0x8(%ebp)
  800847:	e8 92 ff ff ff       	call   8007de <vsnprintf>
	va_end(ap);

	return rc;
}
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800861:	74 05                	je     800868 <strlen+0x1a>
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	eb f5                	jmp    80085d <strlen+0xf>
	return n;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086a:	f3 0f 1e fb          	endbr32 
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	39 d0                	cmp    %edx,%eax
  80087e:	74 0d                	je     80088d <strnlen+0x23>
  800880:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800884:	74 05                	je     80088b <strnlen+0x21>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	eb f1                	jmp    80087c <strnlen+0x12>
  80088b:	89 c2                	mov    %eax,%edx
	return n;
}
  80088d:	89 d0                	mov    %edx,%eax
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f2                	jne    8008a4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008b2:	89 c8                	mov    %ecx,%eax
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 10             	sub    $0x10,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	53                   	push   %ebx
  8008c6:	e8 83 ff ff ff       	call   80084e <strlen>
  8008cb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	01 d8                	add    %ebx,%eax
  8008d3:	50                   	push   %eax
  8008d4:	e8 b8 ff ff ff       	call   800891 <strcpy>
	return dst;
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 11                	je     80090b <strncpy+0x2b>
		*dst++ = *src;
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 0a             	movzbl (%edx),%ecx
  800900:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800903:	80 f9 01             	cmp    $0x1,%cl
  800906:	83 da ff             	sbb    $0xffffffff,%edx
  800909:	eb eb                	jmp    8008f6 <strncpy+0x16>
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	f3 0f 1e fb          	endbr32 
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 75 08             	mov    0x8(%ebp),%esi
  80091d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800920:	8b 55 10             	mov    0x10(%ebp),%edx
  800923:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800925:	85 d2                	test   %edx,%edx
  800927:	74 21                	je     80094a <strlcpy+0x39>
  800929:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80092f:	39 c2                	cmp    %eax,%edx
  800931:	74 14                	je     800947 <strlcpy+0x36>
  800933:	0f b6 19             	movzbl (%ecx),%ebx
  800936:	84 db                	test   %bl,%bl
  800938:	74 0b                	je     800945 <strlcpy+0x34>
			*dst++ = *src++;
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	83 c2 01             	add    $0x1,%edx
  800940:	88 5a ff             	mov    %bl,-0x1(%edx)
  800943:	eb ea                	jmp    80092f <strlcpy+0x1e>
  800945:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800947:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094a:	29 f0                	sub    %esi,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800950:	f3 0f 1e fb          	endbr32 
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 0c                	je     800970 <strcmp+0x20>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	75 08                	jne    800970 <strcmp+0x20>
		p++, q++;
  800968:	83 c1 01             	add    $0x1,%ecx
  80096b:	83 c2 01             	add    $0x1,%edx
  80096e:	eb ed                	jmp    80095d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	0f b6 c0             	movzbl %al,%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097a:	f3 0f 1e fb          	endbr32 
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 c3                	mov    %eax,%ebx
  80098a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098d:	eb 06                	jmp    800995 <strncmp+0x1b>
		n--, p++, q++;
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800995:	39 d8                	cmp    %ebx,%eax
  800997:	74 16                	je     8009af <strncmp+0x35>
  800999:	0f b6 08             	movzbl (%eax),%ecx
  80099c:	84 c9                	test   %cl,%cl
  80099e:	74 04                	je     8009a4 <strncmp+0x2a>
  8009a0:	3a 0a                	cmp    (%edx),%cl
  8009a2:	74 eb                	je     80098f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a4:	0f b6 00             	movzbl (%eax),%eax
  8009a7:	0f b6 12             	movzbl (%edx),%edx
  8009aa:	29 d0                	sub    %edx,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    
		return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	eb f6                	jmp    8009ac <strncmp+0x32>

008009b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b6:	f3 0f 1e fb          	endbr32 
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	0f b6 10             	movzbl (%eax),%edx
  8009c7:	84 d2                	test   %dl,%dl
  8009c9:	74 09                	je     8009d4 <strchr+0x1e>
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 0a                	je     8009d9 <strchr+0x23>
	for (; *s; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	eb f0                	jmp    8009c4 <strchr+0xe>
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  8009db:	f3 0f 1e fb          	endbr32 
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8009e5:	6a 78                	push   $0x78
  8009e7:	ff 75 08             	pushl  0x8(%ebp)
  8009ea:	e8 c7 ff ff ff       	call   8009b6 <strchr>
  8009ef:	83 c4 10             	add    $0x10,%esp
  8009f2:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8009fa:	eb 0d                	jmp    800a09 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8009fc:	c1 e0 04             	shl    $0x4,%eax
  8009ff:	0f be d2             	movsbl %dl,%edx
  800a02:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800a06:	83 c1 01             	add    $0x1,%ecx
  800a09:	0f b6 11             	movzbl (%ecx),%edx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	74 11                	je     800a21 <atox+0x46>
		if (*p>='a'){
  800a10:	80 fa 60             	cmp    $0x60,%dl
  800a13:	7e e7                	jle    8009fc <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800a15:	c1 e0 04             	shl    $0x4,%eax
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800a1f:	eb e5                	jmp    800a06 <atox+0x2b>
	}

	return v;

}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a23:	f3 0f 1e fb          	endbr32 
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a31:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a34:	38 ca                	cmp    %cl,%dl
  800a36:	74 09                	je     800a41 <strfind+0x1e>
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	74 05                	je     800a41 <strfind+0x1e>
	for (; *s; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	eb f0                	jmp    800a31 <strfind+0xe>
			break;
	return (char *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a43:	f3 0f 1e fb          	endbr32 
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a53:	85 c9                	test   %ecx,%ecx
  800a55:	74 31                	je     800a88 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a57:	89 f8                	mov    %edi,%eax
  800a59:	09 c8                	or     %ecx,%eax
  800a5b:	a8 03                	test   $0x3,%al
  800a5d:	75 23                	jne    800a82 <memset+0x3f>
		c &= 0xFF;
  800a5f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a63:	89 d3                	mov    %edx,%ebx
  800a65:	c1 e3 08             	shl    $0x8,%ebx
  800a68:	89 d0                	mov    %edx,%eax
  800a6a:	c1 e0 18             	shl    $0x18,%eax
  800a6d:	89 d6                	mov    %edx,%esi
  800a6f:	c1 e6 10             	shl    $0x10,%esi
  800a72:	09 f0                	or     %esi,%eax
  800a74:	09 c2                	or     %eax,%edx
  800a76:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a78:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	fc                   	cld    
  800a7e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a80:	eb 06                	jmp    800a88 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	fc                   	cld    
  800a86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a88:	89 f8                	mov    %edi,%eax
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 32                	jae    800ad7 <memmove+0x48>
  800aa5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa8:	39 c2                	cmp    %eax,%edx
  800aaa:	76 2b                	jbe    800ad7 <memmove+0x48>
		s += n;
		d += n;
  800aac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	89 fe                	mov    %edi,%esi
  800ab1:	09 ce                	or     %ecx,%esi
  800ab3:	09 d6                	or     %edx,%esi
  800ab5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abb:	75 0e                	jne    800acb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800abd:	83 ef 04             	sub    $0x4,%edi
  800ac0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac6:	fd                   	std    
  800ac7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac9:	eb 09                	jmp    800ad4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800acb:	83 ef 01             	sub    $0x1,%edi
  800ace:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ad1:	fd                   	std    
  800ad2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad4:	fc                   	cld    
  800ad5:	eb 1a                	jmp    800af1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	09 ca                	or     %ecx,%edx
  800adb:	09 f2                	or     %esi,%edx
  800add:	f6 c2 03             	test   $0x3,%dl
  800ae0:	75 0a                	jne    800aec <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	fc                   	cld    
  800ae8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aea:	eb 05                	jmp    800af1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800aec:	89 c7                	mov    %eax,%edi
  800aee:	fc                   	cld    
  800aef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af5:	f3 0f 1e fb          	endbr32 
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aff:	ff 75 10             	pushl  0x10(%ebp)
  800b02:	ff 75 0c             	pushl  0xc(%ebp)
  800b05:	ff 75 08             	pushl  0x8(%ebp)
  800b08:	e8 82 ff ff ff       	call   800a8f <memmove>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0f:	f3 0f 1e fb          	endbr32 
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1e:	89 c6                	mov    %eax,%esi
  800b20:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	39 f0                	cmp    %esi,%eax
  800b25:	74 1c                	je     800b43 <memcmp+0x34>
		if (*s1 != *s2)
  800b27:	0f b6 08             	movzbl (%eax),%ecx
  800b2a:	0f b6 1a             	movzbl (%edx),%ebx
  800b2d:	38 d9                	cmp    %bl,%cl
  800b2f:	75 08                	jne    800b39 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b31:	83 c0 01             	add    $0x1,%eax
  800b34:	83 c2 01             	add    $0x1,%edx
  800b37:	eb ea                	jmp    800b23 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b39:	0f b6 c1             	movzbl %cl,%eax
  800b3c:	0f b6 db             	movzbl %bl,%ebx
  800b3f:	29 d8                	sub    %ebx,%eax
  800b41:	eb 05                	jmp    800b48 <memcmp+0x39>
	}

	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4c:	f3 0f 1e fb          	endbr32 
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b5e:	39 d0                	cmp    %edx,%eax
  800b60:	73 09                	jae    800b6b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b62:	38 08                	cmp    %cl,(%eax)
  800b64:	74 05                	je     800b6b <memfind+0x1f>
	for (; s < ends; s++)
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	eb f3                	jmp    800b5e <memfind+0x12>
			break;
	return (void *) s;
}
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6d:	f3 0f 1e fb          	endbr32 
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7d:	eb 03                	jmp    800b82 <strtol+0x15>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b82:	0f b6 01             	movzbl (%ecx),%eax
  800b85:	3c 20                	cmp    $0x20,%al
  800b87:	74 f6                	je     800b7f <strtol+0x12>
  800b89:	3c 09                	cmp    $0x9,%al
  800b8b:	74 f2                	je     800b7f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b8d:	3c 2b                	cmp    $0x2b,%al
  800b8f:	74 2a                	je     800bbb <strtol+0x4e>
	int neg = 0;
  800b91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b96:	3c 2d                	cmp    $0x2d,%al
  800b98:	74 2b                	je     800bc5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 0f                	jne    800bb1 <strtol+0x44>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	74 28                	je     800bcf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba7:	85 db                	test   %ebx,%ebx
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bae:	0f 44 d8             	cmove  %eax,%ebx
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb9:	eb 46                	jmp    800c01 <strtol+0x94>
		s++;
  800bbb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc3:	eb d5                	jmp    800b9a <strtol+0x2d>
		s++, neg = 1;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bcd:	eb cb                	jmp    800b9a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bd3:	74 0e                	je     800be3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	75 d8                	jne    800bb1 <strtol+0x44>
		s++, base = 8;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800be1:	eb ce                	jmp    800bb1 <strtol+0x44>
		s += 2, base = 16;
  800be3:	83 c1 02             	add    $0x2,%ecx
  800be6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800beb:	eb c4                	jmp    800bb1 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bed:	0f be d2             	movsbl %dl,%edx
  800bf0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf6:	7d 3a                	jge    800c32 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bff:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c01:	0f b6 11             	movzbl (%ecx),%edx
  800c04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c07:	89 f3                	mov    %esi,%ebx
  800c09:	80 fb 09             	cmp    $0x9,%bl
  800c0c:	76 df                	jbe    800bed <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 08                	ja     800c20 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 57             	sub    $0x57,%edx
  800c1e:	eb d3                	jmp    800bf3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c23:	89 f3                	mov    %esi,%ebx
  800c25:	80 fb 19             	cmp    $0x19,%bl
  800c28:	77 08                	ja     800c32 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c2a:	0f be d2             	movsbl %dl,%edx
  800c2d:	83 ea 37             	sub    $0x37,%edx
  800c30:	eb c1                	jmp    800bf3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c36:	74 05                	je     800c3d <strtol+0xd0>
		*endptr = (char *) s;
  800c38:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c3b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	f7 da                	neg    %edx
  800c41:	85 ff                	test   %edi,%edi
  800c43:	0f 45 c2             	cmovne %edx,%eax
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4b:	f3 0f 1e fb          	endbr32 
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	89 c6                	mov    %eax,%esi
  800c66:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6d:	f3 0f 1e fb          	endbr32 
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c81:	89 d1                	mov    %edx,%ecx
  800c83:	89 d3                	mov    %edx,%ebx
  800c85:	89 d7                	mov    %edx,%edi
  800c87:	89 d6                	mov    %edx,%esi
  800c89:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca7:	89 cb                	mov    %ecx,%ebx
  800ca9:	89 cf                	mov    %ecx,%edi
  800cab:	89 ce                	mov    %ecx,%esi
  800cad:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb4:	f3 0f 1e fb          	endbr32 
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc3:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc8:	89 d1                	mov    %edx,%ecx
  800cca:	89 d3                	mov    %edx,%ebx
  800ccc:	89 d7                	mov    %edx,%edi
  800cce:	89 d6                	mov    %edx,%esi
  800cd0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_yield>:

void
sys_yield(void)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ceb:	89 d1                	mov    %edx,%ecx
  800ced:	89 d3                	mov    %edx,%ebx
  800cef:	89 d7                	mov    %edx,%edi
  800cf1:	89 d6                	mov    %edx,%esi
  800cf3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cfa:	f3 0f 1e fb          	endbr32 
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d04:	be 00 00 00 00       	mov    $0x0,%esi
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d17:	89 f7                	mov    %esi,%edi
  800d19:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	b8 05 00 00 00       	mov    $0x5,%eax
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3e:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d45:	f3 0f 1e fb          	endbr32 
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5f:	89 df                	mov    %ebx,%edi
  800d61:	89 de                	mov    %ebx,%esi
  800d63:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	89 de                	mov    %ebx,%esi
  800d88:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800da4:	b8 09 00 00 00       	mov    $0x9,%eax
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 de                	mov    %ebx,%esi
  800dad:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db4:	f3 0f 1e fb          	endbr32 
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd9:	f3 0f 1e fb          	endbr32 
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dee:	be 00 00 00 00       	mov    $0x0,%esi
  800df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e00:	f3 0f 1e fb          	endbr32 
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e17:	89 cb                	mov    %ecx,%ebx
  800e19:	89 cf                	mov    %ecx,%edi
  800e1b:	89 ce                	mov    %ecx,%esi
  800e1d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e24:	f3 0f 1e fb          	endbr32 
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e33:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e38:	89 d1                	mov    %edx,%ecx
  800e3a:	89 d3                	mov    %edx,%ebx
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	89 d6                	mov    %edx,%esi
  800e40:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800e47:	f3 0f 1e fb          	endbr32 
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e61:	89 df                	mov    %ebx,%edi
  800e63:	89 de                	mov    %ebx,%esi
  800e65:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e6c:	f3 0f 1e fb          	endbr32 
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e81:	b8 10 00 00 00       	mov    $0x10,%eax
  800e86:	89 df                	mov    %ebx,%edi
  800e88:	89 de                	mov    %ebx,%esi
  800e8a:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5f                   	pop    %edi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e91:	f3 0f 1e fb          	endbr32 
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea0:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea5:	f3 0f 1e fb          	endbr32 
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800eb4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eb9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	c1 ea 16             	shr    $0x16,%edx
  800ed1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed8:	f6 c2 01             	test   $0x1,%dl
  800edb:	74 2d                	je     800f0a <fd_alloc+0x4a>
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	c1 ea 0c             	shr    $0xc,%edx
  800ee2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee9:	f6 c2 01             	test   $0x1,%dl
  800eec:	74 1c                	je     800f0a <fd_alloc+0x4a>
  800eee:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800ef3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef8:	75 d2                	jne    800ecc <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
  800efd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f03:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f08:	eb 0a                	jmp    800f14 <fd_alloc+0x54>
			*fd_store = fd;
  800f0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f16:	f3 0f 1e fb          	endbr32 
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f20:	83 f8 1f             	cmp    $0x1f,%eax
  800f23:	77 30                	ja     800f55 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f25:	c1 e0 0c             	shl    $0xc,%eax
  800f28:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f2d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f33:	f6 c2 01             	test   $0x1,%dl
  800f36:	74 24                	je     800f5c <fd_lookup+0x46>
  800f38:	89 c2                	mov    %eax,%edx
  800f3a:	c1 ea 0c             	shr    $0xc,%edx
  800f3d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f44:	f6 c2 01             	test   $0x1,%dl
  800f47:	74 1a                	je     800f63 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4c:	89 02                	mov    %eax,(%edx)
	return 0;
  800f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    
		return -E_INVAL;
  800f55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f5a:	eb f7                	jmp    800f53 <fd_lookup+0x3d>
		return -E_INVAL;
  800f5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f61:	eb f0                	jmp    800f53 <fd_lookup+0x3d>
  800f63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f68:	eb e9                	jmp    800f53 <fd_lookup+0x3d>

00800f6a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f6a:	f3 0f 1e fb          	endbr32 
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f77:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7c:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f81:	39 08                	cmp    %ecx,(%eax)
  800f83:	74 38                	je     800fbd <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f85:	83 c2 01             	add    $0x1,%edx
  800f88:	8b 04 95 fc 2e 80 00 	mov    0x802efc(,%edx,4),%eax
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	75 ee                	jne    800f81 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f93:	a1 08 50 80 00       	mov    0x805008,%eax
  800f98:	8b 40 48             	mov    0x48(%eax),%eax
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	51                   	push   %ecx
  800f9f:	50                   	push   %eax
  800fa0:	68 80 2e 80 00       	push   $0x802e80
  800fa5:	e8 dd f2 ff ff       	call   800287 <cprintf>
	*dev = 0;
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    
			*dev = devtab[i];
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc7:	eb f2                	jmp    800fbb <dev_lookup+0x51>

00800fc9 <fd_close>:
{
  800fc9:	f3 0f 1e fb          	endbr32 
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 24             	sub    $0x24,%esp
  800fd6:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fdc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdf:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fe0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe9:	50                   	push   %eax
  800fea:	e8 27 ff ff ff       	call   800f16 <fd_lookup>
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	78 05                	js     800ffd <fd_close+0x34>
	    || fd != fd2)
  800ff8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ffb:	74 16                	je     801013 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800ffd:	89 f8                	mov    %edi,%eax
  800fff:	84 c0                	test   %al,%al
  801001:	b8 00 00 00 00       	mov    $0x0,%eax
  801006:	0f 44 d8             	cmove  %eax,%ebx
}
  801009:	89 d8                	mov    %ebx,%eax
  80100b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801019:	50                   	push   %eax
  80101a:	ff 36                	pushl  (%esi)
  80101c:	e8 49 ff ff ff       	call   800f6a <dev_lookup>
  801021:	89 c3                	mov    %eax,%ebx
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	78 1a                	js     801044 <fd_close+0x7b>
		if (dev->dev_close)
  80102a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80102d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801030:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801035:	85 c0                	test   %eax,%eax
  801037:	74 0b                	je     801044 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	56                   	push   %esi
  80103d:	ff d0                	call   *%eax
  80103f:	89 c3                	mov    %eax,%ebx
  801041:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	56                   	push   %esi
  801048:	6a 00                	push   $0x0
  80104a:	e8 f6 fc ff ff       	call   800d45 <sys_page_unmap>
	return r;
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	eb b5                	jmp    801009 <fd_close+0x40>

00801054 <close>:

int
close(int fdnum)
{
  801054:	f3 0f 1e fb          	endbr32 
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80105e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	ff 75 08             	pushl  0x8(%ebp)
  801065:	e8 ac fe ff ff       	call   800f16 <fd_lookup>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 02                	jns    801073 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    
		return fd_close(fd, 1);
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	6a 01                	push   $0x1
  801078:	ff 75 f4             	pushl  -0xc(%ebp)
  80107b:	e8 49 ff ff ff       	call   800fc9 <fd_close>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	eb ec                	jmp    801071 <close+0x1d>

00801085 <close_all>:

void
close_all(void)
{
  801085:	f3 0f 1e fb          	endbr32 
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	53                   	push   %ebx
  80108d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801090:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	53                   	push   %ebx
  801099:	e8 b6 ff ff ff       	call   801054 <close>
	for (i = 0; i < MAXFD; i++)
  80109e:	83 c3 01             	add    $0x1,%ebx
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	83 fb 20             	cmp    $0x20,%ebx
  8010a7:	75 ec                	jne    801095 <close_all+0x10>
}
  8010a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ac:	c9                   	leave  
  8010ad:	c3                   	ret    

008010ae <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ae:	f3 0f 1e fb          	endbr32 
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	ff 75 08             	pushl  0x8(%ebp)
  8010c2:	e8 4f fe ff ff       	call   800f16 <fd_lookup>
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	0f 88 81 00 00 00    	js     801155 <dup+0xa7>
		return r;
	close(newfdnum);
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	ff 75 0c             	pushl  0xc(%ebp)
  8010da:	e8 75 ff ff ff       	call   801054 <close>

	newfd = INDEX2FD(newfdnum);
  8010df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e2:	c1 e6 0c             	shl    $0xc,%esi
  8010e5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010eb:	83 c4 04             	add    $0x4,%esp
  8010ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f1:	e8 af fd ff ff       	call   800ea5 <fd2data>
  8010f6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010f8:	89 34 24             	mov    %esi,(%esp)
  8010fb:	e8 a5 fd ff ff       	call   800ea5 <fd2data>
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801105:	89 d8                	mov    %ebx,%eax
  801107:	c1 e8 16             	shr    $0x16,%eax
  80110a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801111:	a8 01                	test   $0x1,%al
  801113:	74 11                	je     801126 <dup+0x78>
  801115:	89 d8                	mov    %ebx,%eax
  801117:	c1 e8 0c             	shr    $0xc,%eax
  80111a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801121:	f6 c2 01             	test   $0x1,%dl
  801124:	75 39                	jne    80115f <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801126:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801129:	89 d0                	mov    %edx,%eax
  80112b:	c1 e8 0c             	shr    $0xc,%eax
  80112e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	25 07 0e 00 00       	and    $0xe07,%eax
  80113d:	50                   	push   %eax
  80113e:	56                   	push   %esi
  80113f:	6a 00                	push   $0x0
  801141:	52                   	push   %edx
  801142:	6a 00                	push   $0x0
  801144:	e8 d7 fb ff ff       	call   800d20 <sys_page_map>
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 31                	js     801183 <dup+0xd5>
		goto err;

	return newfdnum;
  801152:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801155:	89 d8                	mov    %ebx,%eax
  801157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80115f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	25 07 0e 00 00       	and    $0xe07,%eax
  80116e:	50                   	push   %eax
  80116f:	57                   	push   %edi
  801170:	6a 00                	push   $0x0
  801172:	53                   	push   %ebx
  801173:	6a 00                	push   $0x0
  801175:	e8 a6 fb ff ff       	call   800d20 <sys_page_map>
  80117a:	89 c3                	mov    %eax,%ebx
  80117c:	83 c4 20             	add    $0x20,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	79 a3                	jns    801126 <dup+0x78>
	sys_page_unmap(0, newfd);
  801183:	83 ec 08             	sub    $0x8,%esp
  801186:	56                   	push   %esi
  801187:	6a 00                	push   $0x0
  801189:	e8 b7 fb ff ff       	call   800d45 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118e:	83 c4 08             	add    $0x8,%esp
  801191:	57                   	push   %edi
  801192:	6a 00                	push   $0x0
  801194:	e8 ac fb ff ff       	call   800d45 <sys_page_unmap>
	return r;
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	eb b7                	jmp    801155 <dup+0xa7>

0080119e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80119e:	f3 0f 1e fb          	endbr32 
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 1c             	sub    $0x1c,%esp
  8011a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	53                   	push   %ebx
  8011b1:	e8 60 fd ff ff       	call   800f16 <fd_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 3f                	js     8011fc <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c7:	ff 30                	pushl  (%eax)
  8011c9:	e8 9c fd ff ff       	call   800f6a <dev_lookup>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 27                	js     8011fc <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d8:	8b 42 08             	mov    0x8(%edx),%eax
  8011db:	83 e0 03             	and    $0x3,%eax
  8011de:	83 f8 01             	cmp    $0x1,%eax
  8011e1:	74 1e                	je     801201 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e6:	8b 40 08             	mov    0x8(%eax),%eax
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	74 35                	je     801222 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ed:	83 ec 04             	sub    $0x4,%esp
  8011f0:	ff 75 10             	pushl  0x10(%ebp)
  8011f3:	ff 75 0c             	pushl  0xc(%ebp)
  8011f6:	52                   	push   %edx
  8011f7:	ff d0                	call   *%eax
  8011f9:	83 c4 10             	add    $0x10,%esp
}
  8011fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801201:	a1 08 50 80 00       	mov    0x805008,%eax
  801206:	8b 40 48             	mov    0x48(%eax),%eax
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	53                   	push   %ebx
  80120d:	50                   	push   %eax
  80120e:	68 c1 2e 80 00       	push   $0x802ec1
  801213:	e8 6f f0 ff ff       	call   800287 <cprintf>
		return -E_INVAL;
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801220:	eb da                	jmp    8011fc <read+0x5e>
		return -E_NOT_SUPP;
  801222:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801227:	eb d3                	jmp    8011fc <read+0x5e>

00801229 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801229:	f3 0f 1e fb          	endbr32 
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	8b 7d 08             	mov    0x8(%ebp),%edi
  801239:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801241:	eb 02                	jmp    801245 <readn+0x1c>
  801243:	01 c3                	add    %eax,%ebx
  801245:	39 f3                	cmp    %esi,%ebx
  801247:	73 21                	jae    80126a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	89 f0                	mov    %esi,%eax
  80124e:	29 d8                	sub    %ebx,%eax
  801250:	50                   	push   %eax
  801251:	89 d8                	mov    %ebx,%eax
  801253:	03 45 0c             	add    0xc(%ebp),%eax
  801256:	50                   	push   %eax
  801257:	57                   	push   %edi
  801258:	e8 41 ff ff ff       	call   80119e <read>
		if (m < 0)
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 04                	js     801268 <readn+0x3f>
			return m;
		if (m == 0)
  801264:	75 dd                	jne    801243 <readn+0x1a>
  801266:	eb 02                	jmp    80126a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801268:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80126a:	89 d8                	mov    %ebx,%eax
  80126c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801274:	f3 0f 1e fb          	endbr32 
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	53                   	push   %ebx
  80127c:	83 ec 1c             	sub    $0x1c,%esp
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	53                   	push   %ebx
  801287:	e8 8a fc ff ff       	call   800f16 <fd_lookup>
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 3a                	js     8012cd <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801293:	83 ec 08             	sub    $0x8,%esp
  801296:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801299:	50                   	push   %eax
  80129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129d:	ff 30                	pushl  (%eax)
  80129f:	e8 c6 fc ff ff       	call   800f6a <dev_lookup>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 22                	js     8012cd <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b2:	74 1e                	je     8012d2 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	74 35                	je     8012f3 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	ff 75 10             	pushl  0x10(%ebp)
  8012c4:	ff 75 0c             	pushl  0xc(%ebp)
  8012c7:	50                   	push   %eax
  8012c8:	ff d2                	call   *%edx
  8012ca:	83 c4 10             	add    $0x10,%esp
}
  8012cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d0:	c9                   	leave  
  8012d1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d2:	a1 08 50 80 00       	mov    0x805008,%eax
  8012d7:	8b 40 48             	mov    0x48(%eax),%eax
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	53                   	push   %ebx
  8012de:	50                   	push   %eax
  8012df:	68 dd 2e 80 00       	push   $0x802edd
  8012e4:	e8 9e ef ff ff       	call   800287 <cprintf>
		return -E_INVAL;
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f1:	eb da                	jmp    8012cd <write+0x59>
		return -E_NOT_SUPP;
  8012f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f8:	eb d3                	jmp    8012cd <write+0x59>

008012fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8012fa:	f3 0f 1e fb          	endbr32 
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	ff 75 08             	pushl  0x8(%ebp)
  80130b:	e8 06 fc ff ff       	call   800f16 <fd_lookup>
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 0e                	js     801325 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801327:	f3 0f 1e fb          	endbr32 
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	53                   	push   %ebx
  80132f:	83 ec 1c             	sub    $0x1c,%esp
  801332:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801335:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	53                   	push   %ebx
  80133a:	e8 d7 fb ff ff       	call   800f16 <fd_lookup>
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 37                	js     80137d <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801346:	83 ec 08             	sub    $0x8,%esp
  801349:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801350:	ff 30                	pushl  (%eax)
  801352:	e8 13 fc ff ff       	call   800f6a <dev_lookup>
  801357:	83 c4 10             	add    $0x10,%esp
  80135a:	85 c0                	test   %eax,%eax
  80135c:	78 1f                	js     80137d <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801361:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801365:	74 1b                	je     801382 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801367:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80136a:	8b 52 18             	mov    0x18(%edx),%edx
  80136d:	85 d2                	test   %edx,%edx
  80136f:	74 32                	je     8013a3 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	ff 75 0c             	pushl  0xc(%ebp)
  801377:	50                   	push   %eax
  801378:	ff d2                	call   *%edx
  80137a:	83 c4 10             	add    $0x10,%esp
}
  80137d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801380:	c9                   	leave  
  801381:	c3                   	ret    
			thisenv->env_id, fdnum);
  801382:	a1 08 50 80 00       	mov    0x805008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801387:	8b 40 48             	mov    0x48(%eax),%eax
  80138a:	83 ec 04             	sub    $0x4,%esp
  80138d:	53                   	push   %ebx
  80138e:	50                   	push   %eax
  80138f:	68 a0 2e 80 00       	push   $0x802ea0
  801394:	e8 ee ee ff ff       	call   800287 <cprintf>
		return -E_INVAL;
  801399:	83 c4 10             	add    $0x10,%esp
  80139c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a1:	eb da                	jmp    80137d <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a8:	eb d3                	jmp    80137d <ftruncate+0x56>

008013aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013aa:	f3 0f 1e fb          	endbr32 
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 1c             	sub    $0x1c,%esp
  8013b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 75 08             	pushl  0x8(%ebp)
  8013bf:	e8 52 fb ff ff       	call   800f16 <fd_lookup>
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	78 4b                	js     801416 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d5:	ff 30                	pushl  (%eax)
  8013d7:	e8 8e fb ff ff       	call   800f6a <dev_lookup>
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 33                	js     801416 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ea:	74 2f                	je     80141b <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f6:	00 00 00 
	stat->st_isdir = 0;
  8013f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801400:	00 00 00 
	stat->st_dev = dev;
  801403:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	53                   	push   %ebx
  80140d:	ff 75 f0             	pushl  -0x10(%ebp)
  801410:	ff 50 14             	call   *0x14(%eax)
  801413:	83 c4 10             	add    $0x10,%esp
}
  801416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801419:	c9                   	leave  
  80141a:	c3                   	ret    
		return -E_NOT_SUPP;
  80141b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801420:	eb f4                	jmp    801416 <fstat+0x6c>

00801422 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801422:	f3 0f 1e fb          	endbr32 
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	6a 00                	push   $0x0
  801430:	ff 75 08             	pushl  0x8(%ebp)
  801433:	e8 01 02 00 00       	call   801639 <open>
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 1b                	js     80145c <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	ff 75 0c             	pushl  0xc(%ebp)
  801447:	50                   	push   %eax
  801448:	e8 5d ff ff ff       	call   8013aa <fstat>
  80144d:	89 c6                	mov    %eax,%esi
	close(fd);
  80144f:	89 1c 24             	mov    %ebx,(%esp)
  801452:	e8 fd fb ff ff       	call   801054 <close>
	return r;
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	89 f3                	mov    %esi,%ebx
}
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	56                   	push   %esi
  801469:	53                   	push   %ebx
  80146a:	89 c6                	mov    %eax,%esi
  80146c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80146e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801475:	74 27                	je     80149e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801477:	6a 07                	push   $0x7
  801479:	68 00 60 80 00       	push   $0x806000
  80147e:	56                   	push   %esi
  80147f:	ff 35 00 50 80 00    	pushl  0x805000
  801485:	e8 a7 12 00 00       	call   802731 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80148a:	83 c4 0c             	add    $0xc,%esp
  80148d:	6a 00                	push   $0x0
  80148f:	53                   	push   %ebx
  801490:	6a 00                	push   $0x0
  801492:	e8 2d 12 00 00       	call   8026c4 <ipc_recv>
}
  801497:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	6a 01                	push   $0x1
  8014a3:	e8 e1 12 00 00       	call   802789 <ipc_find_env>
  8014a8:	a3 00 50 80 00       	mov    %eax,0x805000
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	eb c5                	jmp    801477 <fsipc+0x12>

008014b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014b2:	f3 0f 1e fb          	endbr32 
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8014c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ca:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8014d9:	e8 87 ff ff ff       	call   801465 <fsipc>
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <devfile_flush>:
{
  8014e0:	f3 0f 1e fb          	endbr32 
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f0:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ff:	e8 61 ff ff ff       	call   801465 <fsipc>
}
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <devfile_stat>:
{
  801506:	f3 0f 1e fb          	endbr32 
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	53                   	push   %ebx
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801514:	8b 45 08             	mov    0x8(%ebp),%eax
  801517:	8b 40 0c             	mov    0xc(%eax),%eax
  80151a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 05 00 00 00       	mov    $0x5,%eax
  801529:	e8 37 ff ff ff       	call   801465 <fsipc>
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 2c                	js     80155e <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	68 00 60 80 00       	push   $0x806000
  80153a:	53                   	push   %ebx
  80153b:	e8 51 f3 ff ff       	call   800891 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801540:	a1 80 60 80 00       	mov    0x806080,%eax
  801545:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80154b:	a1 84 60 80 00       	mov    0x806084,%eax
  801550:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <devfile_write>:
{
  801563:	f3 0f 1e fb          	endbr32 
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	8b 45 10             	mov    0x10(%ebp),%eax
  801570:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801575:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80157a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80157d:	8b 55 08             	mov    0x8(%ebp),%edx
  801580:	8b 52 0c             	mov    0xc(%edx),%edx
  801583:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801589:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80158e:	50                   	push   %eax
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	68 08 60 80 00       	push   $0x806008
  801597:	e8 f3 f4 ff ff       	call   800a8f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80159c:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a6:	e8 ba fe ff ff       	call   801465 <fsipc>
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <devfile_read>:
{
  8015ad:	f3 0f 1e fb          	endbr32 
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8015bf:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8015c4:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8015d4:	e8 8c fe ff ff       	call   801465 <fsipc>
  8015d9:	89 c3                	mov    %eax,%ebx
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 1f                	js     8015fe <devfile_read+0x51>
	assert(r <= n);
  8015df:	39 f0                	cmp    %esi,%eax
  8015e1:	77 24                	ja     801607 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015e3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e8:	7f 36                	jg     801620 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ea:	83 ec 04             	sub    $0x4,%esp
  8015ed:	50                   	push   %eax
  8015ee:	68 00 60 80 00       	push   $0x806000
  8015f3:	ff 75 0c             	pushl  0xc(%ebp)
  8015f6:	e8 94 f4 ff ff       	call   800a8f <memmove>
	return r;
  8015fb:	83 c4 10             	add    $0x10,%esp
}
  8015fe:	89 d8                	mov    %ebx,%eax
  801600:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801603:	5b                   	pop    %ebx
  801604:	5e                   	pop    %esi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    
	assert(r <= n);
  801607:	68 10 2f 80 00       	push   $0x802f10
  80160c:	68 17 2f 80 00       	push   $0x802f17
  801611:	68 8c 00 00 00       	push   $0x8c
  801616:	68 2c 2f 80 00       	push   $0x802f2c
  80161b:	e8 80 eb ff ff       	call   8001a0 <_panic>
	assert(r <= PGSIZE);
  801620:	68 37 2f 80 00       	push   $0x802f37
  801625:	68 17 2f 80 00       	push   $0x802f17
  80162a:	68 8d 00 00 00       	push   $0x8d
  80162f:	68 2c 2f 80 00       	push   $0x802f2c
  801634:	e8 67 eb ff ff       	call   8001a0 <_panic>

00801639 <open>:
{
  801639:	f3 0f 1e fb          	endbr32 
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	56                   	push   %esi
  801641:	53                   	push   %ebx
  801642:	83 ec 1c             	sub    $0x1c,%esp
  801645:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801648:	56                   	push   %esi
  801649:	e8 00 f2 ff ff       	call   80084e <strlen>
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801656:	7f 6c                	jg     8016c4 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	e8 5c f8 ff ff       	call   800ec0 <fd_alloc>
  801664:	89 c3                	mov    %eax,%ebx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 3c                	js     8016a9 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	56                   	push   %esi
  801671:	68 00 60 80 00       	push   $0x806000
  801676:	e8 16 f2 ff ff       	call   800891 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80167b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167e:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801683:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801686:	b8 01 00 00 00       	mov    $0x1,%eax
  80168b:	e8 d5 fd ff ff       	call   801465 <fsipc>
  801690:	89 c3                	mov    %eax,%ebx
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	85 c0                	test   %eax,%eax
  801697:	78 19                	js     8016b2 <open+0x79>
	return fd2num(fd);
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	ff 75 f4             	pushl  -0xc(%ebp)
  80169f:	e8 ed f7 ff ff       	call   800e91 <fd2num>
  8016a4:	89 c3                	mov    %eax,%ebx
  8016a6:	83 c4 10             	add    $0x10,%esp
}
  8016a9:	89 d8                	mov    %ebx,%eax
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    
		fd_close(fd, 0);
  8016b2:	83 ec 08             	sub    $0x8,%esp
  8016b5:	6a 00                	push   $0x0
  8016b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ba:	e8 0a f9 ff ff       	call   800fc9 <fd_close>
		return r;
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb e5                	jmp    8016a9 <open+0x70>
		return -E_BAD_PATH;
  8016c4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016c9:	eb de                	jmp    8016a9 <open+0x70>

008016cb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016cb:	f3 0f 1e fb          	endbr32 
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016da:	b8 08 00 00 00       	mov    $0x8,%eax
  8016df:	e8 81 fd ff ff       	call   801465 <fsipc>
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8016e6:	f3 0f 1e fb          	endbr32 
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	57                   	push   %edi
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8016f6:	6a 00                	push   $0x0
  8016f8:	ff 75 08             	pushl  0x8(%ebp)
  8016fb:	e8 39 ff ff ff       	call   801639 <open>
  801700:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 88 b2 04 00 00    	js     801bc3 <spawn+0x4dd>
  801711:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	68 00 02 00 00       	push   $0x200
  80171b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	51                   	push   %ecx
  801723:	e8 01 fb ff ff       	call   801229 <readn>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	3d 00 02 00 00       	cmp    $0x200,%eax
  801730:	75 7e                	jne    8017b0 <spawn+0xca>
	    || elf->e_magic != ELF_MAGIC) {
  801732:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801739:	45 4c 46 
  80173c:	75 72                	jne    8017b0 <spawn+0xca>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80173e:	b8 07 00 00 00       	mov    $0x7,%eax
  801743:	cd 30                	int    $0x30
  801745:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80174b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801751:	85 c0                	test   %eax,%eax
  801753:	0f 88 5e 04 00 00    	js     801bb7 <spawn+0x4d1>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801759:	25 ff 03 00 00       	and    $0x3ff,%eax
  80175e:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801761:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801767:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80176d:	b9 11 00 00 00       	mov    $0x11,%ecx
  801772:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801774:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80177a:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801780:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801785:	be 00 00 00 00       	mov    $0x0,%esi
  80178a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80178d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801794:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801797:	85 c0                	test   %eax,%eax
  801799:	74 4d                	je     8017e8 <spawn+0x102>
		string_size += strlen(argv[argc]) + 1;
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	50                   	push   %eax
  80179f:	e8 aa f0 ff ff       	call   80084e <strlen>
  8017a4:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8017a8:	83 c3 01             	add    $0x1,%ebx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	eb dd                	jmp    80178d <spawn+0xa7>
		close(fd);
  8017b0:	83 ec 0c             	sub    $0xc,%esp
  8017b3:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8017b9:	e8 96 f8 ff ff       	call   801054 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8017be:	83 c4 0c             	add    $0xc,%esp
  8017c1:	68 7f 45 4c 46       	push   $0x464c457f
  8017c6:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8017cc:	68 a3 2f 80 00       	push   $0x802fa3
  8017d1:	e8 b1 ea ff ff       	call   800287 <cprintf>
		return -E_NOT_EXEC;
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  8017e0:	ff ff ff 
  8017e3:	e9 db 03 00 00       	jmp    801bc3 <spawn+0x4dd>
  8017e8:	89 85 70 fd ff ff    	mov    %eax,-0x290(%ebp)
  8017ee:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  8017f4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8017fa:	bf 00 10 40 00       	mov    $0x401000,%edi
  8017ff:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801801:	89 fa                	mov    %edi,%edx
  801803:	83 e2 fc             	and    $0xfffffffc,%edx
  801806:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80180d:	29 c2                	sub    %eax,%edx
  80180f:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801815:	8d 42 f8             	lea    -0x8(%edx),%eax
  801818:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80181d:	0f 86 12 04 00 00    	jbe    801c35 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	6a 07                	push   $0x7
  801828:	68 00 00 40 00       	push   $0x400000
  80182d:	6a 00                	push   $0x0
  80182f:	e8 c6 f4 ff ff       	call   800cfa <sys_page_alloc>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	85 c0                	test   %eax,%eax
  801839:	0f 88 fb 03 00 00    	js     801c3a <spawn+0x554>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80183f:	be 00 00 00 00       	mov    $0x0,%esi
  801844:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  80184a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80184d:	eb 30                	jmp    80187f <spawn+0x199>
		argv_store[i] = UTEMP2USTACK(string_store);
  80184f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801855:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80185b:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801864:	57                   	push   %edi
  801865:	e8 27 f0 ff ff       	call   800891 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80186a:	83 c4 04             	add    $0x4,%esp
  80186d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801870:	e8 d9 ef ff ff       	call   80084e <strlen>
  801875:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801879:	83 c6 01             	add    $0x1,%esi
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801885:	7f c8                	jg     80184f <spawn+0x169>
	}
	argv_store[argc] = 0;
  801887:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80188d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801893:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80189a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8018a0:	0f 85 88 00 00 00    	jne    80192e <spawn+0x248>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8018a6:	8b 8d 90 fd ff ff    	mov    -0x270(%ebp),%ecx
  8018ac:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  8018b2:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  8018b5:	89 c8                	mov    %ecx,%eax
  8018b7:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  8018bd:	89 51 f8             	mov    %edx,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8018c0:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8018c5:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	6a 07                	push   $0x7
  8018d0:	68 00 d0 bf ee       	push   $0xeebfd000
  8018d5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8018db:	68 00 00 40 00       	push   $0x400000
  8018e0:	6a 00                	push   $0x0
  8018e2:	e8 39 f4 ff ff       	call   800d20 <sys_page_map>
  8018e7:	89 c3                	mov    %eax,%ebx
  8018e9:	83 c4 20             	add    $0x20,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	0f 88 4e 03 00 00    	js     801c42 <spawn+0x55c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	68 00 00 40 00       	push   $0x400000
  8018fc:	6a 00                	push   $0x0
  8018fe:	e8 42 f4 ff ff       	call   800d45 <sys_page_unmap>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	0f 88 32 03 00 00    	js     801c42 <spawn+0x55c>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801910:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801916:	8d b4 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%esi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80191d:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  801924:	00 00 00 
  801927:	89 f7                	mov    %esi,%edi
  801929:	e9 4f 01 00 00       	jmp    801a7d <spawn+0x397>
	assert(string_store == (char*)UTEMP + PGSIZE);
  80192e:	68 30 30 80 00       	push   $0x803030
  801933:	68 17 2f 80 00       	push   $0x802f17
  801938:	68 f1 00 00 00       	push   $0xf1
  80193d:	68 bd 2f 80 00       	push   $0x802fbd
  801942:	e8 59 e8 ff ff       	call   8001a0 <_panic>
			// allocate a blank page bss segment
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	6a 07                	push   $0x7
  80194c:	68 00 00 40 00       	push   $0x400000
  801951:	6a 00                	push   $0x0
  801953:	e8 a2 f3 ff ff       	call   800cfa <sys_page_alloc>
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	85 c0                	test   %eax,%eax
  80195d:	0f 88 6e 02 00 00    	js     801bd1 <spawn+0x4eb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80196c:	01 f8                	add    %edi,%eax
  80196e:	50                   	push   %eax
  80196f:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801975:	e8 80 f9 ff ff       	call   8012fa <seek>
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	85 c0                	test   %eax,%eax
  80197f:	0f 88 53 02 00 00    	js     801bd8 <spawn+0x4f2>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80198e:	29 f8                	sub    %edi,%eax
  801990:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801995:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80199a:	0f 47 c1             	cmova  %ecx,%eax
  80199d:	50                   	push   %eax
  80199e:	68 00 00 40 00       	push   $0x400000
  8019a3:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8019a9:	e8 7b f8 ff ff       	call   801229 <readn>
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	0f 88 26 02 00 00    	js     801bdf <spawn+0x4f9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019c2:	53                   	push   %ebx
  8019c3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019c9:	68 00 00 40 00       	push   $0x400000
  8019ce:	6a 00                	push   $0x0
  8019d0:	e8 4b f3 ff ff       	call   800d20 <sys_page_map>
  8019d5:	83 c4 20             	add    $0x20,%esp
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 7c                	js     801a58 <spawn+0x372>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  8019dc:	83 ec 08             	sub    $0x8,%esp
  8019df:	68 00 00 40 00       	push   $0x400000
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 5a f3 ff ff       	call   800d45 <sys_page_unmap>
  8019eb:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8019ee:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019f4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019fa:	89 f7                	mov    %esi,%edi
  8019fc:	39 b5 7c fd ff ff    	cmp    %esi,-0x284(%ebp)
  801a02:	76 69                	jbe    801a6d <spawn+0x387>
		if (i >= filesz) {
  801a04:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801a0a:	0f 87 37 ff ff ff    	ja     801947 <spawn+0x261>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a19:	53                   	push   %ebx
  801a1a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a20:	e8 d5 f2 ff ff       	call   800cfa <sys_page_alloc>
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	79 c2                	jns    8019ee <spawn+0x308>
  801a2c:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a37:	e8 54 f2 ff ff       	call   800c90 <sys_env_destroy>
	close(fd);
  801a3c:	83 c4 04             	add    $0x4,%esp
  801a3f:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801a45:	e8 0a f6 ff ff       	call   801054 <close>
	return r;
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
  801a53:	e9 6b 01 00 00       	jmp    801bc3 <spawn+0x4dd>
				panic("spawn: sys_page_map data: %e", r);
  801a58:	50                   	push   %eax
  801a59:	68 c9 2f 80 00       	push   $0x802fc9
  801a5e:	68 24 01 00 00       	push   $0x124
  801a63:	68 bd 2f 80 00       	push   $0x802fbd
  801a68:	e8 33 e7 ff ff       	call   8001a0 <_panic>
  801a6d:	8b bd 78 fd ff ff    	mov    -0x288(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a73:	83 85 84 fd ff ff 01 	addl   $0x1,-0x27c(%ebp)
  801a7a:	83 c7 20             	add    $0x20,%edi
  801a7d:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a84:	3b 85 84 fd ff ff    	cmp    -0x27c(%ebp),%eax
  801a8a:	7e 6d                	jle    801af9 <spawn+0x413>
		if (ph->p_type != ELF_PROG_LOAD)
  801a8c:	83 3f 01             	cmpl   $0x1,(%edi)
  801a8f:	75 e2                	jne    801a73 <spawn+0x38d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a91:	8b 47 18             	mov    0x18(%edi),%eax
  801a94:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801a97:	83 f8 01             	cmp    $0x1,%eax
  801a9a:	19 c0                	sbb    %eax,%eax
  801a9c:	83 e0 fe             	and    $0xfffffffe,%eax
  801a9f:	83 c0 07             	add    $0x7,%eax
  801aa2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801aa8:	8b 57 04             	mov    0x4(%edi),%edx
  801aab:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801ab1:	8b 4f 10             	mov    0x10(%edi),%ecx
  801ab4:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801aba:	8b 77 14             	mov    0x14(%edi),%esi
  801abd:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
  801ac3:	8b 5f 08             	mov    0x8(%edi),%ebx
	if ((i = PGOFF(va))) {
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	25 ff 0f 00 00       	and    $0xfff,%eax
  801acd:	74 1a                	je     801ae9 <spawn+0x403>
		va -= i;
  801acf:	29 c3                	sub    %eax,%ebx
		memsz += i;
  801ad1:	01 c6                	add    %eax,%esi
  801ad3:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
		filesz += i;
  801ad9:	01 c1                	add    %eax,%ecx
  801adb:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		fileoffset -= i;
  801ae1:	29 c2                	sub    %eax,%edx
  801ae3:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801ae9:	be 00 00 00 00       	mov    $0x0,%esi
  801aee:	89 bd 78 fd ff ff    	mov    %edi,-0x288(%ebp)
  801af4:	e9 01 ff ff ff       	jmp    8019fa <spawn+0x314>
	close(fd);
  801af9:	83 ec 0c             	sub    $0xc,%esp
  801afc:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801b02:	e8 4d f5 ff ff       	call   801054 <close>
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801b10:	8b 9d 70 fd ff ff    	mov    -0x290(%ebp),%ebx
  801b16:	eb 12                	jmp    801b2a <spawn+0x444>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	void* addr; int r;
	for (addr = 0; addr<(void*)USTACKTOP; addr+=PGSIZE){
  801b18:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b1e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801b24:	0f 84 bc 00 00 00    	je     801be6 <spawn+0x500>
		if ((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_SHARE)){
  801b2a:	89 d8                	mov    %ebx,%eax
  801b2c:	c1 e8 16             	shr    $0x16,%eax
  801b2f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b36:	a8 01                	test   $0x1,%al
  801b38:	74 de                	je     801b18 <spawn+0x432>
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	c1 e8 0c             	shr    $0xc,%eax
  801b3f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801b46:	f6 c2 01             	test   $0x1,%dl
  801b49:	74 cd                	je     801b18 <spawn+0x432>
  801b4b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801b52:	f6 c6 04             	test   $0x4,%dh
  801b55:	74 c1                	je     801b18 <spawn+0x432>
			if ((r = sys_page_map(0, addr, child, addr, (uvpt[PGNUM(addr)]&PTE_SYSCALL)))<0)
  801b57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b5e:	83 ec 0c             	sub    $0xc,%esp
  801b61:	25 07 0e 00 00       	and    $0xe07,%eax
  801b66:	50                   	push   %eax
  801b67:	53                   	push   %ebx
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 af f1 ff ff       	call   800d20 <sys_page_map>
  801b71:	83 c4 20             	add    $0x20,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	79 a0                	jns    801b18 <spawn+0x432>
		panic("copy_shared_pages: %e", r);
  801b78:	50                   	push   %eax
  801b79:	68 17 30 80 00       	push   $0x803017
  801b7e:	68 82 00 00 00       	push   $0x82
  801b83:	68 bd 2f 80 00       	push   $0x802fbd
  801b88:	e8 13 e6 ff ff       	call   8001a0 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801b8d:	50                   	push   %eax
  801b8e:	68 e6 2f 80 00       	push   $0x802fe6
  801b93:	68 86 00 00 00       	push   $0x86
  801b98:	68 bd 2f 80 00       	push   $0x802fbd
  801b9d:	e8 fe e5 ff ff       	call   8001a0 <_panic>
		panic("sys_env_set_status: %e", r);
  801ba2:	50                   	push   %eax
  801ba3:	68 00 30 80 00       	push   $0x803000
  801ba8:	68 89 00 00 00       	push   $0x89
  801bad:	68 bd 2f 80 00       	push   $0x802fbd
  801bb2:	e8 e9 e5 ff ff       	call   8001a0 <_panic>
		return r;
  801bb7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801bbd:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801bc3:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    
  801bd1:	89 c7                	mov    %eax,%edi
  801bd3:	e9 56 fe ff ff       	jmp    801a2e <spawn+0x348>
  801bd8:	89 c7                	mov    %eax,%edi
  801bda:	e9 4f fe ff ff       	jmp    801a2e <spawn+0x348>
  801bdf:	89 c7                	mov    %eax,%edi
  801be1:	e9 48 fe ff ff       	jmp    801a2e <spawn+0x348>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801be6:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801bed:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801bf0:	83 ec 08             	sub    $0x8,%esp
  801bf3:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c00:	e8 8a f1 ff ff       	call   800d8f <sys_env_set_trapframe>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	85 c0                	test   %eax,%eax
  801c0a:	78 81                	js     801b8d <spawn+0x4a7>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801c0c:	83 ec 08             	sub    $0x8,%esp
  801c0f:	6a 02                	push   $0x2
  801c11:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c17:	e8 4e f1 ff ff       	call   800d6a <sys_env_set_status>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	0f 88 7b ff ff ff    	js     801ba2 <spawn+0x4bc>
	return child;
  801c27:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801c2d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c33:	eb 8e                	jmp    801bc3 <spawn+0x4dd>
		return -E_NO_MEM;
  801c35:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c3a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c40:	eb 81                	jmp    801bc3 <spawn+0x4dd>
	sys_page_unmap(0, UTEMP);
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	68 00 00 40 00       	push   $0x400000
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 f4 f0 ff ff       	call   800d45 <sys_page_unmap>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c5a:	e9 64 ff ff ff       	jmp    801bc3 <spawn+0x4dd>

00801c5f <spawnl>:
{
  801c5f:	f3 0f 1e fb          	endbr32 
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	57                   	push   %edi
  801c67:	56                   	push   %esi
  801c68:	53                   	push   %ebx
  801c69:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801c6c:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801c74:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c77:	83 3a 00             	cmpl   $0x0,(%edx)
  801c7a:	74 07                	je     801c83 <spawnl+0x24>
		argc++;
  801c7c:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801c7f:	89 ca                	mov    %ecx,%edx
  801c81:	eb f1                	jmp    801c74 <spawnl+0x15>
	const char *argv[argc+2];
  801c83:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801c8a:	89 d1                	mov    %edx,%ecx
  801c8c:	83 e1 f0             	and    $0xfffffff0,%ecx
  801c8f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801c95:	89 e6                	mov    %esp,%esi
  801c97:	29 d6                	sub    %edx,%esi
  801c99:	89 f2                	mov    %esi,%edx
  801c9b:	39 d4                	cmp    %edx,%esp
  801c9d:	74 10                	je     801caf <spawnl+0x50>
  801c9f:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801ca5:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801cac:	00 
  801cad:	eb ec                	jmp    801c9b <spawnl+0x3c>
  801caf:	89 ca                	mov    %ecx,%edx
  801cb1:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801cb7:	29 d4                	sub    %edx,%esp
  801cb9:	85 d2                	test   %edx,%edx
  801cbb:	74 05                	je     801cc2 <spawnl+0x63>
  801cbd:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801cc2:	8d 74 24 03          	lea    0x3(%esp),%esi
  801cc6:	89 f2                	mov    %esi,%edx
  801cc8:	c1 ea 02             	shr    $0x2,%edx
  801ccb:	83 e6 fc             	and    $0xfffffffc,%esi
  801cce:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd3:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801cda:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ce1:	00 
	va_start(vl, arg0);
  801ce2:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801ce5:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cec:	eb 0b                	jmp    801cf9 <spawnl+0x9a>
		argv[i+1] = va_arg(vl, const char *);
  801cee:	83 c0 01             	add    $0x1,%eax
  801cf1:	8b 39                	mov    (%ecx),%edi
  801cf3:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801cf6:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801cf9:	39 d0                	cmp    %edx,%eax
  801cfb:	75 f1                	jne    801cee <spawnl+0x8f>
	return spawn(prog, argv);
  801cfd:	83 ec 08             	sub    $0x8,%esp
  801d00:	56                   	push   %esi
  801d01:	ff 75 08             	pushl  0x8(%ebp)
  801d04:	e8 dd f9 ff ff       	call   8016e6 <spawn>
}
  801d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d11:	f3 0f 1e fb          	endbr32 
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d1b:	68 56 30 80 00       	push   $0x803056
  801d20:	ff 75 0c             	pushl  0xc(%ebp)
  801d23:	e8 69 eb ff ff       	call   800891 <strcpy>
	return 0;
}
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    

00801d2f <devsock_close>:
{
  801d2f:	f3 0f 1e fb          	endbr32 
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	83 ec 10             	sub    $0x10,%esp
  801d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d3d:	53                   	push   %ebx
  801d3e:	e8 83 0a 00 00       	call   8027c6 <pageref>
  801d43:	89 c2                	mov    %eax,%edx
  801d45:	83 c4 10             	add    $0x10,%esp
		return 0;
  801d48:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801d4d:	83 fa 01             	cmp    $0x1,%edx
  801d50:	74 05                	je     801d57 <devsock_close+0x28>
}
  801d52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801d57:	83 ec 0c             	sub    $0xc,%esp
  801d5a:	ff 73 0c             	pushl  0xc(%ebx)
  801d5d:	e8 e3 02 00 00       	call   802045 <nsipc_close>
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	eb eb                	jmp    801d52 <devsock_close+0x23>

00801d67 <devsock_write>:
{
  801d67:	f3 0f 1e fb          	endbr32 
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d71:	6a 00                	push   $0x0
  801d73:	ff 75 10             	pushl  0x10(%ebp)
  801d76:	ff 75 0c             	pushl  0xc(%ebp)
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	ff 70 0c             	pushl  0xc(%eax)
  801d7f:	e8 b5 03 00 00       	call   802139 <nsipc_send>
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <devsock_read>:
{
  801d86:	f3 0f 1e fb          	endbr32 
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d90:	6a 00                	push   $0x0
  801d92:	ff 75 10             	pushl  0x10(%ebp)
  801d95:	ff 75 0c             	pushl  0xc(%ebp)
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	ff 70 0c             	pushl  0xc(%eax)
  801d9e:	e8 1f 03 00 00       	call   8020c2 <nsipc_recv>
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <fd2sockid>:
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801dae:	52                   	push   %edx
  801daf:	50                   	push   %eax
  801db0:	e8 61 f1 ff ff       	call   800f16 <fd_lookup>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 10                	js     801dcc <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbf:	8b 0d 60 40 80 00    	mov    0x804060,%ecx
  801dc5:	39 08                	cmp    %ecx,(%eax)
  801dc7:	75 05                	jne    801dce <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801dc9:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    
		return -E_NOT_SUPP;
  801dce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dd3:	eb f7                	jmp    801dcc <fd2sockid+0x27>

00801dd5 <alloc_sockfd>:
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 1c             	sub    $0x1c,%esp
  801ddd:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801ddf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de2:	50                   	push   %eax
  801de3:	e8 d8 f0 ff ff       	call   800ec0 <fd_alloc>
  801de8:	89 c3                	mov    %eax,%ebx
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	85 c0                	test   %eax,%eax
  801def:	78 43                	js     801e34 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801df1:	83 ec 04             	sub    $0x4,%esp
  801df4:	68 07 04 00 00       	push   $0x407
  801df9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 f7 ee ff ff       	call   800cfa <sys_page_alloc>
  801e03:	89 c3                	mov    %eax,%ebx
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	78 28                	js     801e34 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0f:	8b 15 60 40 80 00    	mov    0x804060,%edx
  801e15:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e21:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	50                   	push   %eax
  801e28:	e8 64 f0 ff ff       	call   800e91 <fd2num>
  801e2d:	89 c3                	mov    %eax,%ebx
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	eb 0c                	jmp    801e40 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	56                   	push   %esi
  801e38:	e8 08 02 00 00       	call   802045 <nsipc_close>
		return r;
  801e3d:	83 c4 10             	add    $0x10,%esp
}
  801e40:	89 d8                	mov    %ebx,%eax
  801e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <accept>:
{
  801e49:	f3 0f 1e fb          	endbr32 
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e53:	8b 45 08             	mov    0x8(%ebp),%eax
  801e56:	e8 4a ff ff ff       	call   801da5 <fd2sockid>
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 1b                	js     801e7a <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	ff 75 10             	pushl  0x10(%ebp)
  801e65:	ff 75 0c             	pushl  0xc(%ebp)
  801e68:	50                   	push   %eax
  801e69:	e8 22 01 00 00       	call   801f90 <nsipc_accept>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 05                	js     801e7a <accept+0x31>
	return alloc_sockfd(r);
  801e75:	e8 5b ff ff ff       	call   801dd5 <alloc_sockfd>
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <bind>:
{
  801e7c:	f3 0f 1e fb          	endbr32 
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801e86:	8b 45 08             	mov    0x8(%ebp),%eax
  801e89:	e8 17 ff ff ff       	call   801da5 <fd2sockid>
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 12                	js     801ea4 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801e92:	83 ec 04             	sub    $0x4,%esp
  801e95:	ff 75 10             	pushl  0x10(%ebp)
  801e98:	ff 75 0c             	pushl  0xc(%ebp)
  801e9b:	50                   	push   %eax
  801e9c:	e8 45 01 00 00       	call   801fe6 <nsipc_bind>
  801ea1:	83 c4 10             	add    $0x10,%esp
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <shutdown>:
{
  801ea6:	f3 0f 1e fb          	endbr32 
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb3:	e8 ed fe ff ff       	call   801da5 <fd2sockid>
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	78 0f                	js     801ecb <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801ebc:	83 ec 08             	sub    $0x8,%esp
  801ebf:	ff 75 0c             	pushl  0xc(%ebp)
  801ec2:	50                   	push   %eax
  801ec3:	e8 57 01 00 00       	call   80201f <nsipc_shutdown>
  801ec8:	83 c4 10             	add    $0x10,%esp
}
  801ecb:	c9                   	leave  
  801ecc:	c3                   	ret    

00801ecd <connect>:
{
  801ecd:	f3 0f 1e fb          	endbr32 
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eda:	e8 c6 fe ff ff       	call   801da5 <fd2sockid>
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	78 12                	js     801ef5 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801ee3:	83 ec 04             	sub    $0x4,%esp
  801ee6:	ff 75 10             	pushl  0x10(%ebp)
  801ee9:	ff 75 0c             	pushl  0xc(%ebp)
  801eec:	50                   	push   %eax
  801eed:	e8 71 01 00 00       	call   802063 <nsipc_connect>
  801ef2:	83 c4 10             	add    $0x10,%esp
}
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <listen>:
{
  801ef7:	f3 0f 1e fb          	endbr32 
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801f01:	8b 45 08             	mov    0x8(%ebp),%eax
  801f04:	e8 9c fe ff ff       	call   801da5 <fd2sockid>
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	78 0f                	js     801f1c <listen+0x25>
	return nsipc_listen(r, backlog);
  801f0d:	83 ec 08             	sub    $0x8,%esp
  801f10:	ff 75 0c             	pushl  0xc(%ebp)
  801f13:	50                   	push   %eax
  801f14:	e8 83 01 00 00       	call   80209c <nsipc_listen>
  801f19:	83 c4 10             	add    $0x10,%esp
}
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <socket>:

int
socket(int domain, int type, int protocol)
{
  801f1e:	f3 0f 1e fb          	endbr32 
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f28:	ff 75 10             	pushl  0x10(%ebp)
  801f2b:	ff 75 0c             	pushl  0xc(%ebp)
  801f2e:	ff 75 08             	pushl  0x8(%ebp)
  801f31:	e8 65 02 00 00       	call   80219b <nsipc_socket>
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 05                	js     801f42 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801f3d:	e8 93 fe ff ff       	call   801dd5 <alloc_sockfd>
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	53                   	push   %ebx
  801f48:	83 ec 04             	sub    $0x4,%esp
  801f4b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f4d:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f54:	74 26                	je     801f7c <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f56:	6a 07                	push   $0x7
  801f58:	68 00 70 80 00       	push   $0x807000
  801f5d:	53                   	push   %ebx
  801f5e:	ff 35 04 50 80 00    	pushl  0x805004
  801f64:	e8 c8 07 00 00       	call   802731 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f69:	83 c4 0c             	add    $0xc,%esp
  801f6c:	6a 00                	push   $0x0
  801f6e:	6a 00                	push   $0x0
  801f70:	6a 00                	push   $0x0
  801f72:	e8 4d 07 00 00       	call   8026c4 <ipc_recv>
}
  801f77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f7c:	83 ec 0c             	sub    $0xc,%esp
  801f7f:	6a 02                	push   $0x2
  801f81:	e8 03 08 00 00       	call   802789 <ipc_find_env>
  801f86:	a3 04 50 80 00       	mov    %eax,0x805004
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	eb c6                	jmp    801f56 <nsipc+0x12>

00801f90 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f90:	f3 0f 1e fb          	endbr32 
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fa4:	8b 06                	mov    (%esi),%eax
  801fa6:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fab:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb0:	e8 8f ff ff ff       	call   801f44 <nsipc>
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	79 09                	jns    801fc4 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801fbb:	89 d8                	mov    %ebx,%eax
  801fbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc0:	5b                   	pop    %ebx
  801fc1:	5e                   	pop    %esi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fc4:	83 ec 04             	sub    $0x4,%esp
  801fc7:	ff 35 10 70 80 00    	pushl  0x807010
  801fcd:	68 00 70 80 00       	push   $0x807000
  801fd2:	ff 75 0c             	pushl  0xc(%ebp)
  801fd5:	e8 b5 ea ff ff       	call   800a8f <memmove>
		*addrlen = ret->ret_addrlen;
  801fda:	a1 10 70 80 00       	mov    0x807010,%eax
  801fdf:	89 06                	mov    %eax,(%esi)
  801fe1:	83 c4 10             	add    $0x10,%esp
	return r;
  801fe4:	eb d5                	jmp    801fbb <nsipc_accept+0x2b>

00801fe6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fe6:	f3 0f 1e fb          	endbr32 
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	53                   	push   %ebx
  801fee:	83 ec 08             	sub    $0x8,%esp
  801ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ffc:	53                   	push   %ebx
  801ffd:	ff 75 0c             	pushl  0xc(%ebp)
  802000:	68 04 70 80 00       	push   $0x807004
  802005:	e8 85 ea ff ff       	call   800a8f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80200a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802010:	b8 02 00 00 00       	mov    $0x2,%eax
  802015:	e8 2a ff ff ff       	call   801f44 <nsipc>
}
  80201a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80201d:	c9                   	leave  
  80201e:	c3                   	ret    

0080201f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80201f:	f3 0f 1e fb          	endbr32 
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802029:	8b 45 08             	mov    0x8(%ebp),%eax
  80202c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802031:	8b 45 0c             	mov    0xc(%ebp),%eax
  802034:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802039:	b8 03 00 00 00       	mov    $0x3,%eax
  80203e:	e8 01 ff ff ff       	call   801f44 <nsipc>
}
  802043:	c9                   	leave  
  802044:	c3                   	ret    

00802045 <nsipc_close>:

int
nsipc_close(int s)
{
  802045:	f3 0f 1e fb          	endbr32 
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80204f:	8b 45 08             	mov    0x8(%ebp),%eax
  802052:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802057:	b8 04 00 00 00       	mov    $0x4,%eax
  80205c:	e8 e3 fe ff ff       	call   801f44 <nsipc>
}
  802061:	c9                   	leave  
  802062:	c3                   	ret    

00802063 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802063:	f3 0f 1e fb          	endbr32 
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	53                   	push   %ebx
  80206b:	83 ec 08             	sub    $0x8,%esp
  80206e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802071:	8b 45 08             	mov    0x8(%ebp),%eax
  802074:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802079:	53                   	push   %ebx
  80207a:	ff 75 0c             	pushl  0xc(%ebp)
  80207d:	68 04 70 80 00       	push   $0x807004
  802082:	e8 08 ea ff ff       	call   800a8f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802087:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80208d:	b8 05 00 00 00       	mov    $0x5,%eax
  802092:	e8 ad fe ff ff       	call   801f44 <nsipc>
}
  802097:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80209c:	f3 0f 1e fb          	endbr32 
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8020bb:	e8 84 fe ff ff       	call   801f44 <nsipc>
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020c2:	f3 0f 1e fb          	endbr32 
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	56                   	push   %esi
  8020ca:	53                   	push   %ebx
  8020cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8020d6:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8020dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8020df:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020e4:	b8 07 00 00 00       	mov    $0x7,%eax
  8020e9:	e8 56 fe ff ff       	call   801f44 <nsipc>
  8020ee:	89 c3                	mov    %eax,%ebx
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	78 26                	js     80211a <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8020f4:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8020fa:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8020ff:	0f 4e c6             	cmovle %esi,%eax
  802102:	39 c3                	cmp    %eax,%ebx
  802104:	7f 1d                	jg     802123 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802106:	83 ec 04             	sub    $0x4,%esp
  802109:	53                   	push   %ebx
  80210a:	68 00 70 80 00       	push   $0x807000
  80210f:	ff 75 0c             	pushl  0xc(%ebp)
  802112:	e8 78 e9 ff ff       	call   800a8f <memmove>
  802117:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80211a:	89 d8                	mov    %ebx,%eax
  80211c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5d                   	pop    %ebp
  802122:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802123:	68 62 30 80 00       	push   $0x803062
  802128:	68 17 2f 80 00       	push   $0x802f17
  80212d:	6a 62                	push   $0x62
  80212f:	68 77 30 80 00       	push   $0x803077
  802134:	e8 67 e0 ff ff       	call   8001a0 <_panic>

00802139 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802139:	f3 0f 1e fb          	endbr32 
  80213d:	55                   	push   %ebp
  80213e:	89 e5                	mov    %esp,%ebp
  802140:	53                   	push   %ebx
  802141:	83 ec 04             	sub    $0x4,%esp
  802144:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802147:	8b 45 08             	mov    0x8(%ebp),%eax
  80214a:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80214f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802155:	7f 2e                	jg     802185 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802157:	83 ec 04             	sub    $0x4,%esp
  80215a:	53                   	push   %ebx
  80215b:	ff 75 0c             	pushl  0xc(%ebp)
  80215e:	68 0c 70 80 00       	push   $0x80700c
  802163:	e8 27 e9 ff ff       	call   800a8f <memmove>
	nsipcbuf.send.req_size = size;
  802168:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80216e:	8b 45 14             	mov    0x14(%ebp),%eax
  802171:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802176:	b8 08 00 00 00       	mov    $0x8,%eax
  80217b:	e8 c4 fd ff ff       	call   801f44 <nsipc>
}
  802180:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802183:	c9                   	leave  
  802184:	c3                   	ret    
	assert(size < 1600);
  802185:	68 83 30 80 00       	push   $0x803083
  80218a:	68 17 2f 80 00       	push   $0x802f17
  80218f:	6a 6d                	push   $0x6d
  802191:	68 77 30 80 00       	push   $0x803077
  802196:	e8 05 e0 ff ff       	call   8001a0 <_panic>

0080219b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80219b:	f3 0f 1e fb          	endbr32 
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8021ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b0:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8021b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8021b8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8021bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8021c2:	e8 7d fd ff ff       	call   801f44 <nsipc>
}
  8021c7:	c9                   	leave  
  8021c8:	c3                   	ret    

008021c9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021c9:	f3 0f 1e fb          	endbr32 
  8021cd:	55                   	push   %ebp
  8021ce:	89 e5                	mov    %esp,%ebp
  8021d0:	56                   	push   %esi
  8021d1:	53                   	push   %ebx
  8021d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021d5:	83 ec 0c             	sub    $0xc,%esp
  8021d8:	ff 75 08             	pushl  0x8(%ebp)
  8021db:	e8 c5 ec ff ff       	call   800ea5 <fd2data>
  8021e0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8021e2:	83 c4 08             	add    $0x8,%esp
  8021e5:	68 8f 30 80 00       	push   $0x80308f
  8021ea:	53                   	push   %ebx
  8021eb:	e8 a1 e6 ff ff       	call   800891 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021f0:	8b 46 04             	mov    0x4(%esi),%eax
  8021f3:	2b 06                	sub    (%esi),%eax
  8021f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8021fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802202:	00 00 00 
	stat->st_dev = &devpipe;
  802205:	c7 83 88 00 00 00 7c 	movl   $0x80407c,0x88(%ebx)
  80220c:	40 80 00 
	return 0;
}
  80220f:	b8 00 00 00 00       	mov    $0x0,%eax
  802214:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80221b:	f3 0f 1e fb          	endbr32 
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	53                   	push   %ebx
  802223:	83 ec 0c             	sub    $0xc,%esp
  802226:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802229:	53                   	push   %ebx
  80222a:	6a 00                	push   $0x0
  80222c:	e8 14 eb ff ff       	call   800d45 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802231:	89 1c 24             	mov    %ebx,(%esp)
  802234:	e8 6c ec ff ff       	call   800ea5 <fd2data>
  802239:	83 c4 08             	add    $0x8,%esp
  80223c:	50                   	push   %eax
  80223d:	6a 00                	push   $0x0
  80223f:	e8 01 eb ff ff       	call   800d45 <sys_page_unmap>
}
  802244:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802247:	c9                   	leave  
  802248:	c3                   	ret    

00802249 <_pipeisclosed>:
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	57                   	push   %edi
  80224d:	56                   	push   %esi
  80224e:	53                   	push   %ebx
  80224f:	83 ec 1c             	sub    $0x1c,%esp
  802252:	89 c7                	mov    %eax,%edi
  802254:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802256:	a1 08 50 80 00       	mov    0x805008,%eax
  80225b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80225e:	83 ec 0c             	sub    $0xc,%esp
  802261:	57                   	push   %edi
  802262:	e8 5f 05 00 00       	call   8027c6 <pageref>
  802267:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80226a:	89 34 24             	mov    %esi,(%esp)
  80226d:	e8 54 05 00 00       	call   8027c6 <pageref>
		nn = thisenv->env_runs;
  802272:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802278:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80227b:	83 c4 10             	add    $0x10,%esp
  80227e:	39 cb                	cmp    %ecx,%ebx
  802280:	74 1b                	je     80229d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802282:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802285:	75 cf                	jne    802256 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802287:	8b 42 58             	mov    0x58(%edx),%eax
  80228a:	6a 01                	push   $0x1
  80228c:	50                   	push   %eax
  80228d:	53                   	push   %ebx
  80228e:	68 96 30 80 00       	push   $0x803096
  802293:	e8 ef df ff ff       	call   800287 <cprintf>
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	eb b9                	jmp    802256 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80229d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8022a0:	0f 94 c0             	sete   %al
  8022a3:	0f b6 c0             	movzbl %al,%eax
}
  8022a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a9:	5b                   	pop    %ebx
  8022aa:	5e                   	pop    %esi
  8022ab:	5f                   	pop    %edi
  8022ac:	5d                   	pop    %ebp
  8022ad:	c3                   	ret    

008022ae <devpipe_write>:
{
  8022ae:	f3 0f 1e fb          	endbr32 
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	83 ec 28             	sub    $0x28,%esp
  8022bb:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8022be:	56                   	push   %esi
  8022bf:	e8 e1 eb ff ff       	call   800ea5 <fd2data>
  8022c4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8022c6:	83 c4 10             	add    $0x10,%esp
  8022c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022d1:	74 4f                	je     802322 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8022d6:	8b 0b                	mov    (%ebx),%ecx
  8022d8:	8d 51 20             	lea    0x20(%ecx),%edx
  8022db:	39 d0                	cmp    %edx,%eax
  8022dd:	72 14                	jb     8022f3 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8022df:	89 da                	mov    %ebx,%edx
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	e8 61 ff ff ff       	call   802249 <_pipeisclosed>
  8022e8:	85 c0                	test   %eax,%eax
  8022ea:	75 3b                	jne    802327 <devpipe_write+0x79>
			sys_yield();
  8022ec:	e8 e6 e9 ff ff       	call   800cd7 <sys_yield>
  8022f1:	eb e0                	jmp    8022d3 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022f6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8022fa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8022fd:	89 c2                	mov    %eax,%edx
  8022ff:	c1 fa 1f             	sar    $0x1f,%edx
  802302:	89 d1                	mov    %edx,%ecx
  802304:	c1 e9 1b             	shr    $0x1b,%ecx
  802307:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80230a:	83 e2 1f             	and    $0x1f,%edx
  80230d:	29 ca                	sub    %ecx,%edx
  80230f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802313:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802317:	83 c0 01             	add    $0x1,%eax
  80231a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80231d:	83 c7 01             	add    $0x1,%edi
  802320:	eb ac                	jmp    8022ce <devpipe_write+0x20>
	return i;
  802322:	8b 45 10             	mov    0x10(%ebp),%eax
  802325:	eb 05                	jmp    80232c <devpipe_write+0x7e>
				return 0;
  802327:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80232c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80232f:	5b                   	pop    %ebx
  802330:	5e                   	pop    %esi
  802331:	5f                   	pop    %edi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    

00802334 <devpipe_read>:
{
  802334:	f3 0f 1e fb          	endbr32 
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	57                   	push   %edi
  80233c:	56                   	push   %esi
  80233d:	53                   	push   %ebx
  80233e:	83 ec 18             	sub    $0x18,%esp
  802341:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802344:	57                   	push   %edi
  802345:	e8 5b eb ff ff       	call   800ea5 <fd2data>
  80234a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80234c:	83 c4 10             	add    $0x10,%esp
  80234f:	be 00 00 00 00       	mov    $0x0,%esi
  802354:	3b 75 10             	cmp    0x10(%ebp),%esi
  802357:	75 14                	jne    80236d <devpipe_read+0x39>
	return i;
  802359:	8b 45 10             	mov    0x10(%ebp),%eax
  80235c:	eb 02                	jmp    802360 <devpipe_read+0x2c>
				return i;
  80235e:	89 f0                	mov    %esi,%eax
}
  802360:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5f                   	pop    %edi
  802366:	5d                   	pop    %ebp
  802367:	c3                   	ret    
			sys_yield();
  802368:	e8 6a e9 ff ff       	call   800cd7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80236d:	8b 03                	mov    (%ebx),%eax
  80236f:	3b 43 04             	cmp    0x4(%ebx),%eax
  802372:	75 18                	jne    80238c <devpipe_read+0x58>
			if (i > 0)
  802374:	85 f6                	test   %esi,%esi
  802376:	75 e6                	jne    80235e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802378:	89 da                	mov    %ebx,%edx
  80237a:	89 f8                	mov    %edi,%eax
  80237c:	e8 c8 fe ff ff       	call   802249 <_pipeisclosed>
  802381:	85 c0                	test   %eax,%eax
  802383:	74 e3                	je     802368 <devpipe_read+0x34>
				return 0;
  802385:	b8 00 00 00 00       	mov    $0x0,%eax
  80238a:	eb d4                	jmp    802360 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80238c:	99                   	cltd   
  80238d:	c1 ea 1b             	shr    $0x1b,%edx
  802390:	01 d0                	add    %edx,%eax
  802392:	83 e0 1f             	and    $0x1f,%eax
  802395:	29 d0                	sub    %edx,%eax
  802397:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80239c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80239f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023a2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8023a5:	83 c6 01             	add    $0x1,%esi
  8023a8:	eb aa                	jmp    802354 <devpipe_read+0x20>

008023aa <pipe>:
{
  8023aa:	f3 0f 1e fb          	endbr32 
  8023ae:	55                   	push   %ebp
  8023af:	89 e5                	mov    %esp,%ebp
  8023b1:	56                   	push   %esi
  8023b2:	53                   	push   %ebx
  8023b3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8023b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b9:	50                   	push   %eax
  8023ba:	e8 01 eb ff ff       	call   800ec0 <fd_alloc>
  8023bf:	89 c3                	mov    %eax,%ebx
  8023c1:	83 c4 10             	add    $0x10,%esp
  8023c4:	85 c0                	test   %eax,%eax
  8023c6:	0f 88 23 01 00 00    	js     8024ef <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023cc:	83 ec 04             	sub    $0x4,%esp
  8023cf:	68 07 04 00 00       	push   $0x407
  8023d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023d7:	6a 00                	push   $0x0
  8023d9:	e8 1c e9 ff ff       	call   800cfa <sys_page_alloc>
  8023de:	89 c3                	mov    %eax,%ebx
  8023e0:	83 c4 10             	add    $0x10,%esp
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	0f 88 04 01 00 00    	js     8024ef <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8023eb:	83 ec 0c             	sub    $0xc,%esp
  8023ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8023f1:	50                   	push   %eax
  8023f2:	e8 c9 ea ff ff       	call   800ec0 <fd_alloc>
  8023f7:	89 c3                	mov    %eax,%ebx
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	85 c0                	test   %eax,%eax
  8023fe:	0f 88 db 00 00 00    	js     8024df <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802404:	83 ec 04             	sub    $0x4,%esp
  802407:	68 07 04 00 00       	push   $0x407
  80240c:	ff 75 f0             	pushl  -0x10(%ebp)
  80240f:	6a 00                	push   $0x0
  802411:	e8 e4 e8 ff ff       	call   800cfa <sys_page_alloc>
  802416:	89 c3                	mov    %eax,%ebx
  802418:	83 c4 10             	add    $0x10,%esp
  80241b:	85 c0                	test   %eax,%eax
  80241d:	0f 88 bc 00 00 00    	js     8024df <pipe+0x135>
	va = fd2data(fd0);
  802423:	83 ec 0c             	sub    $0xc,%esp
  802426:	ff 75 f4             	pushl  -0xc(%ebp)
  802429:	e8 77 ea ff ff       	call   800ea5 <fd2data>
  80242e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802430:	83 c4 0c             	add    $0xc,%esp
  802433:	68 07 04 00 00       	push   $0x407
  802438:	50                   	push   %eax
  802439:	6a 00                	push   $0x0
  80243b:	e8 ba e8 ff ff       	call   800cfa <sys_page_alloc>
  802440:	89 c3                	mov    %eax,%ebx
  802442:	83 c4 10             	add    $0x10,%esp
  802445:	85 c0                	test   %eax,%eax
  802447:	0f 88 82 00 00 00    	js     8024cf <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80244d:	83 ec 0c             	sub    $0xc,%esp
  802450:	ff 75 f0             	pushl  -0x10(%ebp)
  802453:	e8 4d ea ff ff       	call   800ea5 <fd2data>
  802458:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80245f:	50                   	push   %eax
  802460:	6a 00                	push   $0x0
  802462:	56                   	push   %esi
  802463:	6a 00                	push   $0x0
  802465:	e8 b6 e8 ff ff       	call   800d20 <sys_page_map>
  80246a:	89 c3                	mov    %eax,%ebx
  80246c:	83 c4 20             	add    $0x20,%esp
  80246f:	85 c0                	test   %eax,%eax
  802471:	78 4e                	js     8024c1 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802473:	a1 7c 40 80 00       	mov    0x80407c,%eax
  802478:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80247b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80247d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802480:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802487:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80248a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80248c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80248f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802496:	83 ec 0c             	sub    $0xc,%esp
  802499:	ff 75 f4             	pushl  -0xc(%ebp)
  80249c:	e8 f0 e9 ff ff       	call   800e91 <fd2num>
  8024a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024a4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8024a6:	83 c4 04             	add    $0x4,%esp
  8024a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8024ac:	e8 e0 e9 ff ff       	call   800e91 <fd2num>
  8024b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024b4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8024b7:	83 c4 10             	add    $0x10,%esp
  8024ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024bf:	eb 2e                	jmp    8024ef <pipe+0x145>
	sys_page_unmap(0, va);
  8024c1:	83 ec 08             	sub    $0x8,%esp
  8024c4:	56                   	push   %esi
  8024c5:	6a 00                	push   $0x0
  8024c7:	e8 79 e8 ff ff       	call   800d45 <sys_page_unmap>
  8024cc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8024cf:	83 ec 08             	sub    $0x8,%esp
  8024d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8024d5:	6a 00                	push   $0x0
  8024d7:	e8 69 e8 ff ff       	call   800d45 <sys_page_unmap>
  8024dc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8024df:	83 ec 08             	sub    $0x8,%esp
  8024e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e5:	6a 00                	push   $0x0
  8024e7:	e8 59 e8 ff ff       	call   800d45 <sys_page_unmap>
  8024ec:	83 c4 10             	add    $0x10,%esp
}
  8024ef:	89 d8                	mov    %ebx,%eax
  8024f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024f4:	5b                   	pop    %ebx
  8024f5:	5e                   	pop    %esi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    

008024f8 <pipeisclosed>:
{
  8024f8:	f3 0f 1e fb          	endbr32 
  8024fc:	55                   	push   %ebp
  8024fd:	89 e5                	mov    %esp,%ebp
  8024ff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802502:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802505:	50                   	push   %eax
  802506:	ff 75 08             	pushl  0x8(%ebp)
  802509:	e8 08 ea ff ff       	call   800f16 <fd_lookup>
  80250e:	83 c4 10             	add    $0x10,%esp
  802511:	85 c0                	test   %eax,%eax
  802513:	78 18                	js     80252d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802515:	83 ec 0c             	sub    $0xc,%esp
  802518:	ff 75 f4             	pushl  -0xc(%ebp)
  80251b:	e8 85 e9 ff ff       	call   800ea5 <fd2data>
  802520:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802522:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802525:	e8 1f fd ff ff       	call   802249 <_pipeisclosed>
  80252a:	83 c4 10             	add    $0x10,%esp
}
  80252d:	c9                   	leave  
  80252e:	c3                   	ret    

0080252f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80252f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802533:	b8 00 00 00 00       	mov    $0x0,%eax
  802538:	c3                   	ret    

00802539 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802539:	f3 0f 1e fb          	endbr32 
  80253d:	55                   	push   %ebp
  80253e:	89 e5                	mov    %esp,%ebp
  802540:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802543:	68 ae 30 80 00       	push   $0x8030ae
  802548:	ff 75 0c             	pushl  0xc(%ebp)
  80254b:	e8 41 e3 ff ff       	call   800891 <strcpy>
	return 0;
}
  802550:	b8 00 00 00 00       	mov    $0x0,%eax
  802555:	c9                   	leave  
  802556:	c3                   	ret    

00802557 <devcons_write>:
{
  802557:	f3 0f 1e fb          	endbr32 
  80255b:	55                   	push   %ebp
  80255c:	89 e5                	mov    %esp,%ebp
  80255e:	57                   	push   %edi
  80255f:	56                   	push   %esi
  802560:	53                   	push   %ebx
  802561:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802567:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80256c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802572:	3b 75 10             	cmp    0x10(%ebp),%esi
  802575:	73 31                	jae    8025a8 <devcons_write+0x51>
		m = n - tot;
  802577:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80257a:	29 f3                	sub    %esi,%ebx
  80257c:	83 fb 7f             	cmp    $0x7f,%ebx
  80257f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802584:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802587:	83 ec 04             	sub    $0x4,%esp
  80258a:	53                   	push   %ebx
  80258b:	89 f0                	mov    %esi,%eax
  80258d:	03 45 0c             	add    0xc(%ebp),%eax
  802590:	50                   	push   %eax
  802591:	57                   	push   %edi
  802592:	e8 f8 e4 ff ff       	call   800a8f <memmove>
		sys_cputs(buf, m);
  802597:	83 c4 08             	add    $0x8,%esp
  80259a:	53                   	push   %ebx
  80259b:	57                   	push   %edi
  80259c:	e8 aa e6 ff ff       	call   800c4b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8025a1:	01 de                	add    %ebx,%esi
  8025a3:	83 c4 10             	add    $0x10,%esp
  8025a6:	eb ca                	jmp    802572 <devcons_write+0x1b>
}
  8025a8:	89 f0                	mov    %esi,%eax
  8025aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    

008025b2 <devcons_read>:
{
  8025b2:	f3 0f 1e fb          	endbr32 
  8025b6:	55                   	push   %ebp
  8025b7:	89 e5                	mov    %esp,%ebp
  8025b9:	83 ec 08             	sub    $0x8,%esp
  8025bc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8025c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025c5:	74 21                	je     8025e8 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8025c7:	e8 a1 e6 ff ff       	call   800c6d <sys_cgetc>
  8025cc:	85 c0                	test   %eax,%eax
  8025ce:	75 07                	jne    8025d7 <devcons_read+0x25>
		sys_yield();
  8025d0:	e8 02 e7 ff ff       	call   800cd7 <sys_yield>
  8025d5:	eb f0                	jmp    8025c7 <devcons_read+0x15>
	if (c < 0)
  8025d7:	78 0f                	js     8025e8 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8025d9:	83 f8 04             	cmp    $0x4,%eax
  8025dc:	74 0c                	je     8025ea <devcons_read+0x38>
	*(char*)vbuf = c;
  8025de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025e1:	88 02                	mov    %al,(%edx)
	return 1;
  8025e3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8025e8:	c9                   	leave  
  8025e9:	c3                   	ret    
		return 0;
  8025ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8025ef:	eb f7                	jmp    8025e8 <devcons_read+0x36>

008025f1 <cputchar>:
{
  8025f1:	f3 0f 1e fb          	endbr32 
  8025f5:	55                   	push   %ebp
  8025f6:	89 e5                	mov    %esp,%ebp
  8025f8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fe:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802601:	6a 01                	push   $0x1
  802603:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802606:	50                   	push   %eax
  802607:	e8 3f e6 ff ff       	call   800c4b <sys_cputs>
}
  80260c:	83 c4 10             	add    $0x10,%esp
  80260f:	c9                   	leave  
  802610:	c3                   	ret    

00802611 <getchar>:
{
  802611:	f3 0f 1e fb          	endbr32 
  802615:	55                   	push   %ebp
  802616:	89 e5                	mov    %esp,%ebp
  802618:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80261b:	6a 01                	push   $0x1
  80261d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802620:	50                   	push   %eax
  802621:	6a 00                	push   $0x0
  802623:	e8 76 eb ff ff       	call   80119e <read>
	if (r < 0)
  802628:	83 c4 10             	add    $0x10,%esp
  80262b:	85 c0                	test   %eax,%eax
  80262d:	78 06                	js     802635 <getchar+0x24>
	if (r < 1)
  80262f:	74 06                	je     802637 <getchar+0x26>
	return c;
  802631:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802635:	c9                   	leave  
  802636:	c3                   	ret    
		return -E_EOF;
  802637:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80263c:	eb f7                	jmp    802635 <getchar+0x24>

0080263e <iscons>:
{
  80263e:	f3 0f 1e fb          	endbr32 
  802642:	55                   	push   %ebp
  802643:	89 e5                	mov    %esp,%ebp
  802645:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80264b:	50                   	push   %eax
  80264c:	ff 75 08             	pushl  0x8(%ebp)
  80264f:	e8 c2 e8 ff ff       	call   800f16 <fd_lookup>
  802654:	83 c4 10             	add    $0x10,%esp
  802657:	85 c0                	test   %eax,%eax
  802659:	78 11                	js     80266c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80265b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265e:	8b 15 98 40 80 00    	mov    0x804098,%edx
  802664:	39 10                	cmp    %edx,(%eax)
  802666:	0f 94 c0             	sete   %al
  802669:	0f b6 c0             	movzbl %al,%eax
}
  80266c:	c9                   	leave  
  80266d:	c3                   	ret    

0080266e <opencons>:
{
  80266e:	f3 0f 1e fb          	endbr32 
  802672:	55                   	push   %ebp
  802673:	89 e5                	mov    %esp,%ebp
  802675:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802678:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80267b:	50                   	push   %eax
  80267c:	e8 3f e8 ff ff       	call   800ec0 <fd_alloc>
  802681:	83 c4 10             	add    $0x10,%esp
  802684:	85 c0                	test   %eax,%eax
  802686:	78 3a                	js     8026c2 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802688:	83 ec 04             	sub    $0x4,%esp
  80268b:	68 07 04 00 00       	push   $0x407
  802690:	ff 75 f4             	pushl  -0xc(%ebp)
  802693:	6a 00                	push   $0x0
  802695:	e8 60 e6 ff ff       	call   800cfa <sys_page_alloc>
  80269a:	83 c4 10             	add    $0x10,%esp
  80269d:	85 c0                	test   %eax,%eax
  80269f:	78 21                	js     8026c2 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8026a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a4:	8b 15 98 40 80 00    	mov    0x804098,%edx
  8026aa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026b6:	83 ec 0c             	sub    $0xc,%esp
  8026b9:	50                   	push   %eax
  8026ba:	e8 d2 e7 ff ff       	call   800e91 <fd2num>
  8026bf:	83 c4 10             	add    $0x10,%esp
}
  8026c2:	c9                   	leave  
  8026c3:	c3                   	ret    

008026c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026c4:	f3 0f 1e fb          	endbr32 
  8026c8:	55                   	push   %ebp
  8026c9:	89 e5                	mov    %esp,%ebp
  8026cb:	56                   	push   %esi
  8026cc:	53                   	push   %ebx
  8026cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8026d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  8026d6:	85 c0                	test   %eax,%eax
  8026d8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8026dd:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  8026e0:	83 ec 0c             	sub    $0xc,%esp
  8026e3:	50                   	push   %eax
  8026e4:	e8 17 e7 ff ff       	call   800e00 <sys_ipc_recv>
  8026e9:	83 c4 10             	add    $0x10,%esp
  8026ec:	85 c0                	test   %eax,%eax
  8026ee:	75 2b                	jne    80271b <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8026f0:	85 f6                	test   %esi,%esi
  8026f2:	74 0a                	je     8026fe <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8026f4:	a1 08 50 80 00       	mov    0x805008,%eax
  8026f9:	8b 40 74             	mov    0x74(%eax),%eax
  8026fc:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8026fe:	85 db                	test   %ebx,%ebx
  802700:	74 0a                	je     80270c <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802702:	a1 08 50 80 00       	mov    0x805008,%eax
  802707:	8b 40 78             	mov    0x78(%eax),%eax
  80270a:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80270c:	a1 08 50 80 00       	mov    0x805008,%eax
  802711:	8b 40 70             	mov    0x70(%eax),%eax
}
  802714:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802717:	5b                   	pop    %ebx
  802718:	5e                   	pop    %esi
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80271b:	85 f6                	test   %esi,%esi
  80271d:	74 06                	je     802725 <ipc_recv+0x61>
  80271f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802725:	85 db                	test   %ebx,%ebx
  802727:	74 eb                	je     802714 <ipc_recv+0x50>
  802729:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80272f:	eb e3                	jmp    802714 <ipc_recv+0x50>

00802731 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802731:	f3 0f 1e fb          	endbr32 
  802735:	55                   	push   %ebp
  802736:	89 e5                	mov    %esp,%ebp
  802738:	57                   	push   %edi
  802739:	56                   	push   %esi
  80273a:	53                   	push   %ebx
  80273b:	83 ec 0c             	sub    $0xc,%esp
  80273e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802741:	8b 75 0c             	mov    0xc(%ebp),%esi
  802744:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802747:	85 db                	test   %ebx,%ebx
  802749:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80274e:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802751:	ff 75 14             	pushl  0x14(%ebp)
  802754:	53                   	push   %ebx
  802755:	56                   	push   %esi
  802756:	57                   	push   %edi
  802757:	e8 7d e6 ff ff       	call   800dd9 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80275c:	83 c4 10             	add    $0x10,%esp
  80275f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802762:	75 07                	jne    80276b <ipc_send+0x3a>
			sys_yield();
  802764:	e8 6e e5 ff ff       	call   800cd7 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802769:	eb e6                	jmp    802751 <ipc_send+0x20>
		}
		else if (ret == 0)
  80276b:	85 c0                	test   %eax,%eax
  80276d:	75 08                	jne    802777 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80276f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802772:	5b                   	pop    %ebx
  802773:	5e                   	pop    %esi
  802774:	5f                   	pop    %edi
  802775:	5d                   	pop    %ebp
  802776:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802777:	50                   	push   %eax
  802778:	68 ba 30 80 00       	push   $0x8030ba
  80277d:	6a 48                	push   $0x48
  80277f:	68 c8 30 80 00       	push   $0x8030c8
  802784:	e8 17 da ff ff       	call   8001a0 <_panic>

00802789 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802789:	f3 0f 1e fb          	endbr32 
  80278d:	55                   	push   %ebp
  80278e:	89 e5                	mov    %esp,%ebp
  802790:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802793:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802798:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80279b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027a1:	8b 52 50             	mov    0x50(%edx),%edx
  8027a4:	39 ca                	cmp    %ecx,%edx
  8027a6:	74 11                	je     8027b9 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8027a8:	83 c0 01             	add    $0x1,%eax
  8027ab:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027b0:	75 e6                	jne    802798 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8027b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8027b7:	eb 0b                	jmp    8027c4 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8027b9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027c1:	8b 40 48             	mov    0x48(%eax),%eax
}
  8027c4:	5d                   	pop    %ebp
  8027c5:	c3                   	ret    

008027c6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027c6:	f3 0f 1e fb          	endbr32 
  8027ca:	55                   	push   %ebp
  8027cb:	89 e5                	mov    %esp,%ebp
  8027cd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027d0:	89 c2                	mov    %eax,%edx
  8027d2:	c1 ea 16             	shr    $0x16,%edx
  8027d5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8027dc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8027e1:	f6 c1 01             	test   $0x1,%cl
  8027e4:	74 1c                	je     802802 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8027e6:	c1 e8 0c             	shr    $0xc,%eax
  8027e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8027f0:	a8 01                	test   $0x1,%al
  8027f2:	74 0e                	je     802802 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027f4:	c1 e8 0c             	shr    $0xc,%eax
  8027f7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8027fe:	ef 
  8027ff:	0f b7 d2             	movzwl %dx,%edx
}
  802802:	89 d0                	mov    %edx,%eax
  802804:	5d                   	pop    %ebp
  802805:	c3                   	ret    
  802806:	66 90                	xchg   %ax,%ax
  802808:	66 90                	xchg   %ax,%ax
  80280a:	66 90                	xchg   %ax,%ax
  80280c:	66 90                	xchg   %ax,%ax
  80280e:	66 90                	xchg   %ax,%ax

00802810 <__udivdi3>:
  802810:	f3 0f 1e fb          	endbr32 
  802814:	55                   	push   %ebp
  802815:	57                   	push   %edi
  802816:	56                   	push   %esi
  802817:	53                   	push   %ebx
  802818:	83 ec 1c             	sub    $0x1c,%esp
  80281b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80281f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802823:	8b 74 24 34          	mov    0x34(%esp),%esi
  802827:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80282b:	85 d2                	test   %edx,%edx
  80282d:	75 19                	jne    802848 <__udivdi3+0x38>
  80282f:	39 f3                	cmp    %esi,%ebx
  802831:	76 4d                	jbe    802880 <__udivdi3+0x70>
  802833:	31 ff                	xor    %edi,%edi
  802835:	89 e8                	mov    %ebp,%eax
  802837:	89 f2                	mov    %esi,%edx
  802839:	f7 f3                	div    %ebx
  80283b:	89 fa                	mov    %edi,%edx
  80283d:	83 c4 1c             	add    $0x1c,%esp
  802840:	5b                   	pop    %ebx
  802841:	5e                   	pop    %esi
  802842:	5f                   	pop    %edi
  802843:	5d                   	pop    %ebp
  802844:	c3                   	ret    
  802845:	8d 76 00             	lea    0x0(%esi),%esi
  802848:	39 f2                	cmp    %esi,%edx
  80284a:	76 14                	jbe    802860 <__udivdi3+0x50>
  80284c:	31 ff                	xor    %edi,%edi
  80284e:	31 c0                	xor    %eax,%eax
  802850:	89 fa                	mov    %edi,%edx
  802852:	83 c4 1c             	add    $0x1c,%esp
  802855:	5b                   	pop    %ebx
  802856:	5e                   	pop    %esi
  802857:	5f                   	pop    %edi
  802858:	5d                   	pop    %ebp
  802859:	c3                   	ret    
  80285a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802860:	0f bd fa             	bsr    %edx,%edi
  802863:	83 f7 1f             	xor    $0x1f,%edi
  802866:	75 48                	jne    8028b0 <__udivdi3+0xa0>
  802868:	39 f2                	cmp    %esi,%edx
  80286a:	72 06                	jb     802872 <__udivdi3+0x62>
  80286c:	31 c0                	xor    %eax,%eax
  80286e:	39 eb                	cmp    %ebp,%ebx
  802870:	77 de                	ja     802850 <__udivdi3+0x40>
  802872:	b8 01 00 00 00       	mov    $0x1,%eax
  802877:	eb d7                	jmp    802850 <__udivdi3+0x40>
  802879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802880:	89 d9                	mov    %ebx,%ecx
  802882:	85 db                	test   %ebx,%ebx
  802884:	75 0b                	jne    802891 <__udivdi3+0x81>
  802886:	b8 01 00 00 00       	mov    $0x1,%eax
  80288b:	31 d2                	xor    %edx,%edx
  80288d:	f7 f3                	div    %ebx
  80288f:	89 c1                	mov    %eax,%ecx
  802891:	31 d2                	xor    %edx,%edx
  802893:	89 f0                	mov    %esi,%eax
  802895:	f7 f1                	div    %ecx
  802897:	89 c6                	mov    %eax,%esi
  802899:	89 e8                	mov    %ebp,%eax
  80289b:	89 f7                	mov    %esi,%edi
  80289d:	f7 f1                	div    %ecx
  80289f:	89 fa                	mov    %edi,%edx
  8028a1:	83 c4 1c             	add    $0x1c,%esp
  8028a4:	5b                   	pop    %ebx
  8028a5:	5e                   	pop    %esi
  8028a6:	5f                   	pop    %edi
  8028a7:	5d                   	pop    %ebp
  8028a8:	c3                   	ret    
  8028a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028b0:	89 f9                	mov    %edi,%ecx
  8028b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8028b7:	29 f8                	sub    %edi,%eax
  8028b9:	d3 e2                	shl    %cl,%edx
  8028bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8028bf:	89 c1                	mov    %eax,%ecx
  8028c1:	89 da                	mov    %ebx,%edx
  8028c3:	d3 ea                	shr    %cl,%edx
  8028c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8028c9:	09 d1                	or     %edx,%ecx
  8028cb:	89 f2                	mov    %esi,%edx
  8028cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028d1:	89 f9                	mov    %edi,%ecx
  8028d3:	d3 e3                	shl    %cl,%ebx
  8028d5:	89 c1                	mov    %eax,%ecx
  8028d7:	d3 ea                	shr    %cl,%edx
  8028d9:	89 f9                	mov    %edi,%ecx
  8028db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8028df:	89 eb                	mov    %ebp,%ebx
  8028e1:	d3 e6                	shl    %cl,%esi
  8028e3:	89 c1                	mov    %eax,%ecx
  8028e5:	d3 eb                	shr    %cl,%ebx
  8028e7:	09 de                	or     %ebx,%esi
  8028e9:	89 f0                	mov    %esi,%eax
  8028eb:	f7 74 24 08          	divl   0x8(%esp)
  8028ef:	89 d6                	mov    %edx,%esi
  8028f1:	89 c3                	mov    %eax,%ebx
  8028f3:	f7 64 24 0c          	mull   0xc(%esp)
  8028f7:	39 d6                	cmp    %edx,%esi
  8028f9:	72 15                	jb     802910 <__udivdi3+0x100>
  8028fb:	89 f9                	mov    %edi,%ecx
  8028fd:	d3 e5                	shl    %cl,%ebp
  8028ff:	39 c5                	cmp    %eax,%ebp
  802901:	73 04                	jae    802907 <__udivdi3+0xf7>
  802903:	39 d6                	cmp    %edx,%esi
  802905:	74 09                	je     802910 <__udivdi3+0x100>
  802907:	89 d8                	mov    %ebx,%eax
  802909:	31 ff                	xor    %edi,%edi
  80290b:	e9 40 ff ff ff       	jmp    802850 <__udivdi3+0x40>
  802910:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802913:	31 ff                	xor    %edi,%edi
  802915:	e9 36 ff ff ff       	jmp    802850 <__udivdi3+0x40>
  80291a:	66 90                	xchg   %ax,%ax
  80291c:	66 90                	xchg   %ax,%ax
  80291e:	66 90                	xchg   %ax,%ax

00802920 <__umoddi3>:
  802920:	f3 0f 1e fb          	endbr32 
  802924:	55                   	push   %ebp
  802925:	57                   	push   %edi
  802926:	56                   	push   %esi
  802927:	53                   	push   %ebx
  802928:	83 ec 1c             	sub    $0x1c,%esp
  80292b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80292f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802933:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802937:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80293b:	85 c0                	test   %eax,%eax
  80293d:	75 19                	jne    802958 <__umoddi3+0x38>
  80293f:	39 df                	cmp    %ebx,%edi
  802941:	76 5d                	jbe    8029a0 <__umoddi3+0x80>
  802943:	89 f0                	mov    %esi,%eax
  802945:	89 da                	mov    %ebx,%edx
  802947:	f7 f7                	div    %edi
  802949:	89 d0                	mov    %edx,%eax
  80294b:	31 d2                	xor    %edx,%edx
  80294d:	83 c4 1c             	add    $0x1c,%esp
  802950:	5b                   	pop    %ebx
  802951:	5e                   	pop    %esi
  802952:	5f                   	pop    %edi
  802953:	5d                   	pop    %ebp
  802954:	c3                   	ret    
  802955:	8d 76 00             	lea    0x0(%esi),%esi
  802958:	89 f2                	mov    %esi,%edx
  80295a:	39 d8                	cmp    %ebx,%eax
  80295c:	76 12                	jbe    802970 <__umoddi3+0x50>
  80295e:	89 f0                	mov    %esi,%eax
  802960:	89 da                	mov    %ebx,%edx
  802962:	83 c4 1c             	add    $0x1c,%esp
  802965:	5b                   	pop    %ebx
  802966:	5e                   	pop    %esi
  802967:	5f                   	pop    %edi
  802968:	5d                   	pop    %ebp
  802969:	c3                   	ret    
  80296a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802970:	0f bd e8             	bsr    %eax,%ebp
  802973:	83 f5 1f             	xor    $0x1f,%ebp
  802976:	75 50                	jne    8029c8 <__umoddi3+0xa8>
  802978:	39 d8                	cmp    %ebx,%eax
  80297a:	0f 82 e0 00 00 00    	jb     802a60 <__umoddi3+0x140>
  802980:	89 d9                	mov    %ebx,%ecx
  802982:	39 f7                	cmp    %esi,%edi
  802984:	0f 86 d6 00 00 00    	jbe    802a60 <__umoddi3+0x140>
  80298a:	89 d0                	mov    %edx,%eax
  80298c:	89 ca                	mov    %ecx,%edx
  80298e:	83 c4 1c             	add    $0x1c,%esp
  802991:	5b                   	pop    %ebx
  802992:	5e                   	pop    %esi
  802993:	5f                   	pop    %edi
  802994:	5d                   	pop    %ebp
  802995:	c3                   	ret    
  802996:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80299d:	8d 76 00             	lea    0x0(%esi),%esi
  8029a0:	89 fd                	mov    %edi,%ebp
  8029a2:	85 ff                	test   %edi,%edi
  8029a4:	75 0b                	jne    8029b1 <__umoddi3+0x91>
  8029a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8029ab:	31 d2                	xor    %edx,%edx
  8029ad:	f7 f7                	div    %edi
  8029af:	89 c5                	mov    %eax,%ebp
  8029b1:	89 d8                	mov    %ebx,%eax
  8029b3:	31 d2                	xor    %edx,%edx
  8029b5:	f7 f5                	div    %ebp
  8029b7:	89 f0                	mov    %esi,%eax
  8029b9:	f7 f5                	div    %ebp
  8029bb:	89 d0                	mov    %edx,%eax
  8029bd:	31 d2                	xor    %edx,%edx
  8029bf:	eb 8c                	jmp    80294d <__umoddi3+0x2d>
  8029c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8029c8:	89 e9                	mov    %ebp,%ecx
  8029ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8029cf:	29 ea                	sub    %ebp,%edx
  8029d1:	d3 e0                	shl    %cl,%eax
  8029d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8029d7:	89 d1                	mov    %edx,%ecx
  8029d9:	89 f8                	mov    %edi,%eax
  8029db:	d3 e8                	shr    %cl,%eax
  8029dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8029e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8029e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029e9:	09 c1                	or     %eax,%ecx
  8029eb:	89 d8                	mov    %ebx,%eax
  8029ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029f1:	89 e9                	mov    %ebp,%ecx
  8029f3:	d3 e7                	shl    %cl,%edi
  8029f5:	89 d1                	mov    %edx,%ecx
  8029f7:	d3 e8                	shr    %cl,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8029ff:	d3 e3                	shl    %cl,%ebx
  802a01:	89 c7                	mov    %eax,%edi
  802a03:	89 d1                	mov    %edx,%ecx
  802a05:	89 f0                	mov    %esi,%eax
  802a07:	d3 e8                	shr    %cl,%eax
  802a09:	89 e9                	mov    %ebp,%ecx
  802a0b:	89 fa                	mov    %edi,%edx
  802a0d:	d3 e6                	shl    %cl,%esi
  802a0f:	09 d8                	or     %ebx,%eax
  802a11:	f7 74 24 08          	divl   0x8(%esp)
  802a15:	89 d1                	mov    %edx,%ecx
  802a17:	89 f3                	mov    %esi,%ebx
  802a19:	f7 64 24 0c          	mull   0xc(%esp)
  802a1d:	89 c6                	mov    %eax,%esi
  802a1f:	89 d7                	mov    %edx,%edi
  802a21:	39 d1                	cmp    %edx,%ecx
  802a23:	72 06                	jb     802a2b <__umoddi3+0x10b>
  802a25:	75 10                	jne    802a37 <__umoddi3+0x117>
  802a27:	39 c3                	cmp    %eax,%ebx
  802a29:	73 0c                	jae    802a37 <__umoddi3+0x117>
  802a2b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802a2f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802a33:	89 d7                	mov    %edx,%edi
  802a35:	89 c6                	mov    %eax,%esi
  802a37:	89 ca                	mov    %ecx,%edx
  802a39:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802a3e:	29 f3                	sub    %esi,%ebx
  802a40:	19 fa                	sbb    %edi,%edx
  802a42:	89 d0                	mov    %edx,%eax
  802a44:	d3 e0                	shl    %cl,%eax
  802a46:	89 e9                	mov    %ebp,%ecx
  802a48:	d3 eb                	shr    %cl,%ebx
  802a4a:	d3 ea                	shr    %cl,%edx
  802a4c:	09 d8                	or     %ebx,%eax
  802a4e:	83 c4 1c             	add    $0x1c,%esp
  802a51:	5b                   	pop    %ebx
  802a52:	5e                   	pop    %esi
  802a53:	5f                   	pop    %edi
  802a54:	5d                   	pop    %ebp
  802a55:	c3                   	ret    
  802a56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a5d:	8d 76 00             	lea    0x0(%esi),%esi
  802a60:	29 fe                	sub    %edi,%esi
  802a62:	19 c3                	sbb    %eax,%ebx
  802a64:	89 f2                	mov    %esi,%edx
  802a66:	89 d9                	mov    %ebx,%ecx
  802a68:	e9 1d ff ff ff       	jmp    80298a <__umoddi3+0x6a>
