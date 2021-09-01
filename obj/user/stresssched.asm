
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 b6 00 00 00       	call   8000e7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 22 0c 00 00       	call   800c63 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 ef 0e 00 00       	call   800f3c <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 28 0c 00 00       	call   800c86 <sys_yield>
		return;
  80005e:	eb 69                	jmp    8000c9 <umain+0x96>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	eb 02                	jmp    800073 <umain+0x40>
		asm volatile("pause");
  800071:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800073:	8b 50 54             	mov    0x54(%eax),%edx
  800076:	85 d2                	test   %edx,%edx
  800078:	75 f7                	jne    800071 <umain+0x3e>
  80007a:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007f:	e8 02 0c 00 00       	call   800c86 <sys_yield>
  800084:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800089:	a1 08 40 80 00       	mov    0x804008,%eax
  80008e:	83 c0 01             	add    $0x1,%eax
  800091:	a3 08 40 80 00       	mov    %eax,0x804008
		for (j = 0; j < 10000; j++)
  800096:	83 ea 01             	sub    $0x1,%edx
  800099:	75 ee                	jne    800089 <umain+0x56>
	for (i = 0; i < 10; i++) {
  80009b:	83 eb 01             	sub    $0x1,%ebx
  80009e:	75 df                	jne    80007f <umain+0x4c>
	}

	if (counter != 10*10000)
  8000a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8000a5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000aa:	75 24                	jne    8000d0 <umain+0x9d>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ac:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000b1:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b4:	8b 40 48             	mov    0x48(%eax),%eax
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	52                   	push   %edx
  8000bb:	50                   	push   %eax
  8000bc:	68 5b 27 80 00       	push   $0x80275b
  8000c1:	e8 70 01 00 00       	call   800236 <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp

}
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 08 40 80 00       	mov    0x804008,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 20 27 80 00       	push   $0x802720
  8000db:	6a 21                	push   $0x21
  8000dd:	68 48 27 80 00       	push   $0x802748
  8000e2:	e8 68 00 00 00       	call   80014f <_panic>

008000e7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f6:	e8 68 0b 00 00       	call   800c63 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 db                	test   %ebx,%ebx
  80010f:	7e 07                	jle    800118 <libmain+0x31>
		binaryname = argv[0];
  800111:	8b 06                	mov    (%esi),%eax
  800113:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	e8 11 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800122:	e8 0a 00 00 00       	call   800131 <exit>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800131:	f3 0f 1e fb          	endbr32 
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80013b:	e8 81 11 00 00       	call   8012c1 <close_all>
	sys_env_destroy(0);
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	6a 00                	push   $0x0
  800145:	e8 f5 0a 00 00       	call   800c3f <sys_env_destroy>
}
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014f:	f3 0f 1e fb          	endbr32 
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800161:	e8 fd 0a 00 00       	call   800c63 <sys_getenvid>
  800166:	83 ec 0c             	sub    $0xc,%esp
  800169:	ff 75 0c             	pushl  0xc(%ebp)
  80016c:	ff 75 08             	pushl  0x8(%ebp)
  80016f:	56                   	push   %esi
  800170:	50                   	push   %eax
  800171:	68 84 27 80 00       	push   $0x802784
  800176:	e8 bb 00 00 00       	call   800236 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017b:	83 c4 18             	add    $0x18,%esp
  80017e:	53                   	push   %ebx
  80017f:	ff 75 10             	pushl  0x10(%ebp)
  800182:	e8 5a 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  800187:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  80018e:	e8 a3 00 00 00       	call   800236 <cprintf>
  800193:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800196:	cc                   	int3   
  800197:	eb fd                	jmp    800196 <_panic+0x47>

00800199 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800199:	f3 0f 1e fb          	endbr32 
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 04             	sub    $0x4,%esp
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a7:	8b 13                	mov    (%ebx),%edx
  8001a9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ac:	89 03                	mov    %eax,(%ebx)
  8001ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ba:	74 09                	je     8001c5 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 24 0a 00 00       	call   800bfa <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	eb db                	jmp    8001bc <putch+0x23>

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	f3 0f 1e fb          	endbr32 
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f5:	00 00 00 
	b.cnt = 0;
  8001f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	68 99 01 80 00       	push   $0x800199
  800214:	e8 20 01 00 00       	call   800339 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800219:	83 c4 08             	add    $0x8,%esp
  80021c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800222:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800228:	50                   	push   %eax
  800229:	e8 cc 09 00 00       	call   800bfa <sys_cputs>

	return b.cnt;
}
  80022e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800236:	f3 0f 1e fb          	endbr32 
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800240:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800243:	50                   	push   %eax
  800244:	ff 75 08             	pushl  0x8(%ebp)
  800247:	e8 95 ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 1c             	sub    $0x1c,%esp
  800257:	89 c7                	mov    %eax,%edi
  800259:	89 d6                	mov    %edx,%esi
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800261:	89 d1                	mov    %edx,%ecx
  800263:	89 c2                	mov    %eax,%edx
  800265:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800268:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80026b:	8b 45 10             	mov    0x10(%ebp),%eax
  80026e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80027b:	39 c2                	cmp    %eax,%edx
  80027d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800280:	72 3e                	jb     8002c0 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	ff 75 18             	pushl  0x18(%ebp)
  800288:	83 eb 01             	sub    $0x1,%ebx
  80028b:	53                   	push   %ebx
  80028c:	50                   	push   %eax
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	ff 75 e4             	pushl  -0x1c(%ebp)
  800293:	ff 75 e0             	pushl  -0x20(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 0f 22 00 00       	call   8024b0 <__udivdi3>
  8002a1:	83 c4 18             	add    $0x18,%esp
  8002a4:	52                   	push   %edx
  8002a5:	50                   	push   %eax
  8002a6:	89 f2                	mov    %esi,%edx
  8002a8:	89 f8                	mov    %edi,%eax
  8002aa:	e8 9f ff ff ff       	call   80024e <printnum>
  8002af:	83 c4 20             	add    $0x20,%esp
  8002b2:	eb 13                	jmp    8002c7 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	ff 75 18             	pushl  0x18(%ebp)
  8002bb:	ff d7                	call   *%edi
  8002bd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c0:	83 eb 01             	sub    $0x1,%ebx
  8002c3:	85 db                	test   %ebx,%ebx
  8002c5:	7f ed                	jg     8002b4 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c7:	83 ec 08             	sub    $0x8,%esp
  8002ca:	56                   	push   %esi
  8002cb:	83 ec 04             	sub    $0x4,%esp
  8002ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002da:	e8 e1 22 00 00       	call   8025c0 <__umoddi3>
  8002df:	83 c4 14             	add    $0x14,%esp
  8002e2:	0f be 80 a7 27 80 00 	movsbl 0x8027a7(%eax),%eax
  8002e9:	50                   	push   %eax
  8002ea:	ff d7                	call   *%edi
}
  8002ec:	83 c4 10             	add    $0x10,%esp
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f7:	f3 0f 1e fb          	endbr32 
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800301:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800305:	8b 10                	mov    (%eax),%edx
  800307:	3b 50 04             	cmp    0x4(%eax),%edx
  80030a:	73 0a                	jae    800316 <sprintputch+0x1f>
		*b->buf++ = ch;
  80030c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	88 02                	mov    %al,(%edx)
}
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <printfmt>:
{
  800318:	f3 0f 1e fb          	endbr32 
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800322:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800325:	50                   	push   %eax
  800326:	ff 75 10             	pushl  0x10(%ebp)
  800329:	ff 75 0c             	pushl  0xc(%ebp)
  80032c:	ff 75 08             	pushl  0x8(%ebp)
  80032f:	e8 05 00 00 00       	call   800339 <vprintfmt>
}
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	c9                   	leave  
  800338:	c3                   	ret    

00800339 <vprintfmt>:
{
  800339:	f3 0f 1e fb          	endbr32 
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 3c             	sub    $0x3c,%esp
  800346:	8b 75 08             	mov    0x8(%ebp),%esi
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034f:	e9 8e 03 00 00       	jmp    8006e2 <vprintfmt+0x3a9>
		padc = ' ';
  800354:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800358:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800366:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80036d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8d 47 01             	lea    0x1(%edi),%eax
  800375:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800378:	0f b6 17             	movzbl (%edi),%edx
  80037b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80037e:	3c 55                	cmp    $0x55,%al
  800380:	0f 87 df 03 00 00    	ja     800765 <vprintfmt+0x42c>
  800386:	0f b6 c0             	movzbl %al,%eax
  800389:	3e ff 24 85 e0 28 80 	notrack jmp *0x8028e0(,%eax,4)
  800390:	00 
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800394:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800398:	eb d8                	jmp    800372 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a1:	eb cf                	jmp    800372 <vprintfmt+0x39>
  8003a3:	0f b6 d2             	movzbl %dl,%edx
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003be:	83 f9 09             	cmp    $0x9,%ecx
  8003c1:	77 55                	ja     800418 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 40 04             	lea    0x4(%eax),%eax
  8003d6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e0:	79 90                	jns    800372 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ef:	eb 81                	jmp    800372 <vprintfmt+0x39>
  8003f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fb:	0f 49 d0             	cmovns %eax,%edx
  8003fe:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800404:	e9 69 ff ff ff       	jmp    800372 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80040c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800413:	e9 5a ff ff ff       	jmp    800372 <vprintfmt+0x39>
  800418:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80041b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041e:	eb bc                	jmp    8003dc <vprintfmt+0xa3>
			lflag++;
  800420:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800426:	e9 47 ff ff ff       	jmp    800372 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 78 04             	lea    0x4(%eax),%edi
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	53                   	push   %ebx
  800435:	ff 30                	pushl  (%eax)
  800437:	ff d6                	call   *%esi
			break;
  800439:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80043c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043f:	e9 9b 02 00 00       	jmp    8006df <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 78 04             	lea    0x4(%eax),%edi
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	99                   	cltd   
  80044d:	31 d0                	xor    %edx,%eax
  80044f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800451:	83 f8 0f             	cmp    $0xf,%eax
  800454:	7f 23                	jg     800479 <vprintfmt+0x140>
  800456:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  80045d:	85 d2                	test   %edx,%edx
  80045f:	74 18                	je     800479 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800461:	52                   	push   %edx
  800462:	68 45 2c 80 00       	push   $0x802c45
  800467:	53                   	push   %ebx
  800468:	56                   	push   %esi
  800469:	e8 aa fe ff ff       	call   800318 <printfmt>
  80046e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800471:	89 7d 14             	mov    %edi,0x14(%ebp)
  800474:	e9 66 02 00 00       	jmp    8006df <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 bf 27 80 00       	push   $0x8027bf
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 92 fe ff ff       	call   800318 <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800489:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 4e 02 00 00       	jmp    8006df <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	83 c0 04             	add    $0x4,%eax
  800497:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	b8 b8 27 80 00       	mov    $0x8027b8,%eax
  8004a6:	0f 45 c2             	cmovne %edx,%eax
  8004a9:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	7e 06                	jle    8004b8 <vprintfmt+0x17f>
  8004b2:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b6:	75 0d                	jne    8004c5 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004bb:	89 c7                	mov    %eax,%edi
  8004bd:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c3:	eb 55                	jmp    80051a <vprintfmt+0x1e1>
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cb:	ff 75 cc             	pushl  -0x34(%ebp)
  8004ce:	e8 46 03 00 00       	call   800819 <strnlen>
  8004d3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d6:	29 c2                	sub    %eax,%edx
  8004d8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004e0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	85 ff                	test   %edi,%edi
  8004e9:	7e 11                	jle    8004fc <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 ef 01             	sub    $0x1,%edi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	eb eb                	jmp    8004e7 <vprintfmt+0x1ae>
  8004fc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	b8 00 00 00 00       	mov    $0x0,%eax
  800506:	0f 49 c2             	cmovns %edx,%eax
  800509:	29 c2                	sub    %eax,%edx
  80050b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050e:	eb a8                	jmp    8004b8 <vprintfmt+0x17f>
					putch(ch, putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	53                   	push   %ebx
  800514:	52                   	push   %edx
  800515:	ff d6                	call   *%esi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051f:	83 c7 01             	add    $0x1,%edi
  800522:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800526:	0f be d0             	movsbl %al,%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 4b                	je     800578 <vprintfmt+0x23f>
  80052d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800531:	78 06                	js     800539 <vprintfmt+0x200>
  800533:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800537:	78 1e                	js     800557 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800539:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053d:	74 d1                	je     800510 <vprintfmt+0x1d7>
  80053f:	0f be c0             	movsbl %al,%eax
  800542:	83 e8 20             	sub    $0x20,%eax
  800545:	83 f8 5e             	cmp    $0x5e,%eax
  800548:	76 c6                	jbe    800510 <vprintfmt+0x1d7>
					putch('?', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 3f                	push   $0x3f
  800550:	ff d6                	call   *%esi
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	eb c3                	jmp    80051a <vprintfmt+0x1e1>
  800557:	89 cf                	mov    %ecx,%edi
  800559:	eb 0e                	jmp    800569 <vprintfmt+0x230>
				putch(' ', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	53                   	push   %ebx
  80055f:	6a 20                	push   $0x20
  800561:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800563:	83 ef 01             	sub    $0x1,%edi
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	85 ff                	test   %edi,%edi
  80056b:	7f ee                	jg     80055b <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80056d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800570:	89 45 14             	mov    %eax,0x14(%ebp)
  800573:	e9 67 01 00 00       	jmp    8006df <vprintfmt+0x3a6>
  800578:	89 cf                	mov    %ecx,%edi
  80057a:	eb ed                	jmp    800569 <vprintfmt+0x230>
	if (lflag >= 2)
  80057c:	83 f9 01             	cmp    $0x1,%ecx
  80057f:	7f 1b                	jg     80059c <vprintfmt+0x263>
	else if (lflag)
  800581:	85 c9                	test   %ecx,%ecx
  800583:	74 63                	je     8005e8 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	99                   	cltd   
  80058e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
  80059a:	eb 17                	jmp    8005b3 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 08             	lea    0x8(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	0f 89 ff 00 00 00    	jns    8006c5 <vprintfmt+0x38c>
				putch('-', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 2d                	push   $0x2d
  8005cc:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d4:	f7 da                	neg    %edx
  8005d6:	83 d1 00             	adc    $0x0,%ecx
  8005d9:	f7 d9                	neg    %ecx
  8005db:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 dd 00 00 00       	jmp    8006c5 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	99                   	cltd   
  8005f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 40 04             	lea    0x4(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fd:	eb b4                	jmp    8005b3 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005ff:	83 f9 01             	cmp    $0x1,%ecx
  800602:	7f 1e                	jg     800622 <vprintfmt+0x2e9>
	else if (lflag)
  800604:	85 c9                	test   %ecx,%ecx
  800606:	74 32                	je     80063a <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800612:	8d 40 04             	lea    0x4(%eax),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800618:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80061d:	e9 a3 00 00 00       	jmp    8006c5 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	8b 48 04             	mov    0x4(%eax),%ecx
  80062a:	8d 40 08             	lea    0x8(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800630:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800635:	e9 8b 00 00 00       	jmp    8006c5 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80064f:	eb 74                	jmp    8006c5 <vprintfmt+0x38c>
	if (lflag >= 2)
  800651:	83 f9 01             	cmp    $0x1,%ecx
  800654:	7f 1b                	jg     800671 <vprintfmt+0x338>
	else if (lflag)
  800656:	85 c9                	test   %ecx,%ecx
  800658:	74 2c                	je     800686 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80066f:	eb 54                	jmp    8006c5 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	8b 48 04             	mov    0x4(%eax),%ecx
  800679:	8d 40 08             	lea    0x8(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800684:	eb 3f                	jmp    8006c5 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800696:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80069b:	eb 28                	jmp    8006c5 <vprintfmt+0x38c>
			putch('0', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 30                	push   $0x30
  8006a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 78                	push   $0x78
  8006ab:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006c5:	83 ec 0c             	sub    $0xc,%esp
  8006c8:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006cc:	57                   	push   %edi
  8006cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d0:	50                   	push   %eax
  8006d1:	51                   	push   %ecx
  8006d2:	52                   	push   %edx
  8006d3:	89 da                	mov    %ebx,%edx
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	e8 72 fb ff ff       	call   80024e <printnum>
			break;
  8006dc:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006e2:	83 c7 01             	add    $0x1,%edi
  8006e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e9:	83 f8 25             	cmp    $0x25,%eax
  8006ec:	0f 84 62 fc ff ff    	je     800354 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	0f 84 8b 00 00 00    	je     800785 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	50                   	push   %eax
  8006ff:	ff d6                	call   *%esi
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb dc                	jmp    8006e2 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800706:	83 f9 01             	cmp    $0x1,%ecx
  800709:	7f 1b                	jg     800726 <vprintfmt+0x3ed>
	else if (lflag)
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	74 2c                	je     80073b <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	b9 00 00 00 00       	mov    $0x0,%ecx
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800724:	eb 9f                	jmp    8006c5 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 10                	mov    (%eax),%edx
  80072b:	8b 48 04             	mov    0x4(%eax),%ecx
  80072e:	8d 40 08             	lea    0x8(%eax),%eax
  800731:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800734:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800739:	eb 8a                	jmp    8006c5 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8b 10                	mov    (%eax),%edx
  800740:	b9 00 00 00 00       	mov    $0x0,%ecx
  800745:	8d 40 04             	lea    0x4(%eax),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800750:	e9 70 ff ff ff       	jmp    8006c5 <vprintfmt+0x38c>
			putch(ch, putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	53                   	push   %ebx
  800759:	6a 25                	push   $0x25
  80075b:	ff d6                	call   *%esi
			break;
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	e9 7a ff ff ff       	jmp    8006df <vprintfmt+0x3a6>
			putch('%', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 25                	push   $0x25
  80076b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	89 f8                	mov    %edi,%eax
  800772:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800776:	74 05                	je     80077d <vprintfmt+0x444>
  800778:	83 e8 01             	sub    $0x1,%eax
  80077b:	eb f5                	jmp    800772 <vprintfmt+0x439>
  80077d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800780:	e9 5a ff ff ff       	jmp    8006df <vprintfmt+0x3a6>
}
  800785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5f                   	pop    %edi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078d:	f3 0f 1e fb          	endbr32 
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 18             	sub    $0x18,%esp
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	74 26                	je     8007d8 <vsnprintf+0x4b>
  8007b2:	85 d2                	test   %edx,%edx
  8007b4:	7e 22                	jle    8007d8 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b6:	ff 75 14             	pushl  0x14(%ebp)
  8007b9:	ff 75 10             	pushl  0x10(%ebp)
  8007bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	68 f7 02 80 00       	push   $0x8002f7
  8007c5:	e8 6f fb ff ff       	call   800339 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d3:	83 c4 10             	add    $0x10,%esp
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    
		return -E_INVAL;
  8007d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007dd:	eb f7                	jmp    8007d6 <vsnprintf+0x49>

008007df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007df:	f3 0f 1e fb          	endbr32 
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 10             	pushl  0x10(%ebp)
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 92 ff ff ff       	call   80078d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fd:	f3 0f 1e fb          	endbr32 
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800810:	74 05                	je     800817 <strlen+0x1a>
		n++;
  800812:	83 c0 01             	add    $0x1,%eax
  800815:	eb f5                	jmp    80080c <strlen+0xf>
	return n;
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800819:	f3 0f 1e fb          	endbr32 
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	39 d0                	cmp    %edx,%eax
  80082d:	74 0d                	je     80083c <strnlen+0x23>
  80082f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800833:	74 05                	je     80083a <strnlen+0x21>
		n++;
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	eb f1                	jmp    80082b <strnlen+0x12>
  80083a:	89 c2                	mov    %eax,%edx
	return n;
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800840:	f3 0f 1e fb          	endbr32 
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
  800853:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800857:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	84 d2                	test   %dl,%dl
  80085f:	75 f2                	jne    800853 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800861:	89 c8                	mov    %ecx,%eax
  800863:	5b                   	pop    %ebx
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800866:	f3 0f 1e fb          	endbr32 
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 10             	sub    $0x10,%esp
  800871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800874:	53                   	push   %ebx
  800875:	e8 83 ff ff ff       	call   8007fd <strlen>
  80087a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80087d:	ff 75 0c             	pushl  0xc(%ebp)
  800880:	01 d8                	add    %ebx,%eax
  800882:	50                   	push   %eax
  800883:	e8 b8 ff ff ff       	call   800840 <strcpy>
	return dst;
}
  800888:	89 d8                	mov    %ebx,%eax
  80088a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088f:	f3 0f 1e fb          	endbr32 
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 75 08             	mov    0x8(%ebp),%esi
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	89 f3                	mov    %esi,%ebx
  8008a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a3:	89 f0                	mov    %esi,%eax
  8008a5:	39 d8                	cmp    %ebx,%eax
  8008a7:	74 11                	je     8008ba <strncpy+0x2b>
		*dst++ = *src;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 0a             	movzbl (%edx),%ecx
  8008af:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b2:	80 f9 01             	cmp    $0x1,%cl
  8008b5:	83 da ff             	sbb    $0xffffffff,%edx
  8008b8:	eb eb                	jmp    8008a5 <strncpy+0x16>
	}
	return ret;
}
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c0:	f3 0f 1e fb          	endbr32 
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cf:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d4:	85 d2                	test   %edx,%edx
  8008d6:	74 21                	je     8008f9 <strlcpy+0x39>
  8008d8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008dc:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008de:	39 c2                	cmp    %eax,%edx
  8008e0:	74 14                	je     8008f6 <strlcpy+0x36>
  8008e2:	0f b6 19             	movzbl (%ecx),%ebx
  8008e5:	84 db                	test   %bl,%bl
  8008e7:	74 0b                	je     8008f4 <strlcpy+0x34>
			*dst++ = *src++;
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f2:	eb ea                	jmp    8008de <strlcpy+0x1e>
  8008f4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f9:	29 f0                	sub    %esi,%eax
}
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ff:	f3 0f 1e fb          	endbr32 
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090c:	0f b6 01             	movzbl (%ecx),%eax
  80090f:	84 c0                	test   %al,%al
  800911:	74 0c                	je     80091f <strcmp+0x20>
  800913:	3a 02                	cmp    (%edx),%al
  800915:	75 08                	jne    80091f <strcmp+0x20>
		p++, q++;
  800917:	83 c1 01             	add    $0x1,%ecx
  80091a:	83 c2 01             	add    $0x1,%edx
  80091d:	eb ed                	jmp    80090c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091f:	0f b6 c0             	movzbl %al,%eax
  800922:	0f b6 12             	movzbl (%edx),%edx
  800925:	29 d0                	sub    %edx,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800929:	f3 0f 1e fb          	endbr32 
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	53                   	push   %ebx
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	89 c3                	mov    %eax,%ebx
  800939:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093c:	eb 06                	jmp    800944 <strncmp+0x1b>
		n--, p++, q++;
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800944:	39 d8                	cmp    %ebx,%eax
  800946:	74 16                	je     80095e <strncmp+0x35>
  800948:	0f b6 08             	movzbl (%eax),%ecx
  80094b:	84 c9                	test   %cl,%cl
  80094d:	74 04                	je     800953 <strncmp+0x2a>
  80094f:	3a 0a                	cmp    (%edx),%cl
  800951:	74 eb                	je     80093e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800953:	0f b6 00             	movzbl (%eax),%eax
  800956:	0f b6 12             	movzbl (%edx),%edx
  800959:	29 d0                	sub    %edx,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    
		return 0;
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
  800963:	eb f6                	jmp    80095b <strncmp+0x32>

00800965 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800965:	f3 0f 1e fb          	endbr32 
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800973:	0f b6 10             	movzbl (%eax),%edx
  800976:	84 d2                	test   %dl,%dl
  800978:	74 09                	je     800983 <strchr+0x1e>
		if (*s == c)
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	74 0a                	je     800988 <strchr+0x23>
	for (; *s; s++)
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	eb f0                	jmp    800973 <strchr+0xe>
			return (char *) s;
	return 0;
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  80098a:	f3 0f 1e fb          	endbr32 
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800994:	6a 78                	push   $0x78
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 c7 ff ff ff       	call   800965 <strchr>
  80099e:	83 c4 10             	add    $0x10,%esp
  8009a1:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8009a9:	eb 0d                	jmp    8009b8 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8009ab:	c1 e0 04             	shl    $0x4,%eax
  8009ae:	0f be d2             	movsbl %dl,%edx
  8009b1:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	0f b6 11             	movzbl (%ecx),%edx
  8009bb:	84 d2                	test   %dl,%dl
  8009bd:	74 11                	je     8009d0 <atox+0x46>
		if (*p>='a'){
  8009bf:	80 fa 60             	cmp    $0x60,%dl
  8009c2:	7e e7                	jle    8009ab <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8009c4:	c1 e0 04             	shl    $0x4,%eax
  8009c7:	0f be d2             	movsbl %dl,%edx
  8009ca:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009ce:	eb e5                	jmp    8009b5 <atox+0x2b>
	}

	return v;

}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d2:	f3 0f 1e fb          	endbr32 
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e3:	38 ca                	cmp    %cl,%dl
  8009e5:	74 09                	je     8009f0 <strfind+0x1e>
  8009e7:	84 d2                	test   %dl,%dl
  8009e9:	74 05                	je     8009f0 <strfind+0x1e>
	for (; *s; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	eb f0                	jmp    8009e0 <strfind+0xe>
			break;
	return (char *) s;
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f2:	f3 0f 1e fb          	endbr32 
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a02:	85 c9                	test   %ecx,%ecx
  800a04:	74 31                	je     800a37 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a06:	89 f8                	mov    %edi,%eax
  800a08:	09 c8                	or     %ecx,%eax
  800a0a:	a8 03                	test   $0x3,%al
  800a0c:	75 23                	jne    800a31 <memset+0x3f>
		c &= 0xFF;
  800a0e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a12:	89 d3                	mov    %edx,%ebx
  800a14:	c1 e3 08             	shl    $0x8,%ebx
  800a17:	89 d0                	mov    %edx,%eax
  800a19:	c1 e0 18             	shl    $0x18,%eax
  800a1c:	89 d6                	mov    %edx,%esi
  800a1e:	c1 e6 10             	shl    $0x10,%esi
  800a21:	09 f0                	or     %esi,%eax
  800a23:	09 c2                	or     %eax,%edx
  800a25:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a27:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a2a:	89 d0                	mov    %edx,%eax
  800a2c:	fc                   	cld    
  800a2d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2f:	eb 06                	jmp    800a37 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a34:	fc                   	cld    
  800a35:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a37:	89 f8                	mov    %edi,%eax
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3e:	f3 0f 1e fb          	endbr32 
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	57                   	push   %edi
  800a46:	56                   	push   %esi
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a50:	39 c6                	cmp    %eax,%esi
  800a52:	73 32                	jae    800a86 <memmove+0x48>
  800a54:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a57:	39 c2                	cmp    %eax,%edx
  800a59:	76 2b                	jbe    800a86 <memmove+0x48>
		s += n;
		d += n;
  800a5b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5e:	89 fe                	mov    %edi,%esi
  800a60:	09 ce                	or     %ecx,%esi
  800a62:	09 d6                	or     %edx,%esi
  800a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6a:	75 0e                	jne    800a7a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a6c:	83 ef 04             	sub    $0x4,%edi
  800a6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a72:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a75:	fd                   	std    
  800a76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a78:	eb 09                	jmp    800a83 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
  800a84:	eb 1a                	jmp    800aa0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	89 c2                	mov    %eax,%edx
  800a88:	09 ca                	or     %ecx,%edx
  800a8a:	09 f2                	or     %esi,%edx
  800a8c:	f6 c2 03             	test   $0x3,%dl
  800a8f:	75 0a                	jne    800a9b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a91:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	fc                   	cld    
  800a97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a99:	eb 05                	jmp    800aa0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	fc                   	cld    
  800a9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa4:	f3 0f 1e fb          	endbr32 
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aae:	ff 75 10             	pushl  0x10(%ebp)
  800ab1:	ff 75 0c             	pushl  0xc(%ebp)
  800ab4:	ff 75 08             	pushl  0x8(%ebp)
  800ab7:	e8 82 ff ff ff       	call   800a3e <memmove>
}
  800abc:	c9                   	leave  
  800abd:	c3                   	ret    

00800abe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abe:	f3 0f 1e fb          	endbr32 
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 c6                	mov    %eax,%esi
  800acf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	39 f0                	cmp    %esi,%eax
  800ad4:	74 1c                	je     800af2 <memcmp+0x34>
		if (*s1 != *s2)
  800ad6:	0f b6 08             	movzbl (%eax),%ecx
  800ad9:	0f b6 1a             	movzbl (%edx),%ebx
  800adc:	38 d9                	cmp    %bl,%cl
  800ade:	75 08                	jne    800ae8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ae0:	83 c0 01             	add    $0x1,%eax
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	eb ea                	jmp    800ad2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ae8:	0f b6 c1             	movzbl %cl,%eax
  800aeb:	0f b6 db             	movzbl %bl,%ebx
  800aee:	29 d8                	sub    %ebx,%eax
  800af0:	eb 05                	jmp    800af7 <memcmp+0x39>
	}

	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afb:	f3 0f 1e fb          	endbr32 
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b08:	89 c2                	mov    %eax,%edx
  800b0a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0d:	39 d0                	cmp    %edx,%eax
  800b0f:	73 09                	jae    800b1a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b11:	38 08                	cmp    %cl,(%eax)
  800b13:	74 05                	je     800b1a <memfind+0x1f>
	for (; s < ends; s++)
  800b15:	83 c0 01             	add    $0x1,%eax
  800b18:	eb f3                	jmp    800b0d <memfind+0x12>
			break;
	return (void *) s;
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1c:	f3 0f 1e fb          	endbr32 
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2c:	eb 03                	jmp    800b31 <strtol+0x15>
		s++;
  800b2e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b31:	0f b6 01             	movzbl (%ecx),%eax
  800b34:	3c 20                	cmp    $0x20,%al
  800b36:	74 f6                	je     800b2e <strtol+0x12>
  800b38:	3c 09                	cmp    $0x9,%al
  800b3a:	74 f2                	je     800b2e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b3c:	3c 2b                	cmp    $0x2b,%al
  800b3e:	74 2a                	je     800b6a <strtol+0x4e>
	int neg = 0;
  800b40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b45:	3c 2d                	cmp    $0x2d,%al
  800b47:	74 2b                	je     800b74 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4f:	75 0f                	jne    800b60 <strtol+0x44>
  800b51:	80 39 30             	cmpb   $0x30,(%ecx)
  800b54:	74 28                	je     800b7e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b56:	85 db                	test   %ebx,%ebx
  800b58:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5d:	0f 44 d8             	cmove  %eax,%ebx
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
  800b65:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b68:	eb 46                	jmp    800bb0 <strtol+0x94>
		s++;
  800b6a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b72:	eb d5                	jmp    800b49 <strtol+0x2d>
		s++, neg = 1;
  800b74:	83 c1 01             	add    $0x1,%ecx
  800b77:	bf 01 00 00 00       	mov    $0x1,%edi
  800b7c:	eb cb                	jmp    800b49 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b82:	74 0e                	je     800b92 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b84:	85 db                	test   %ebx,%ebx
  800b86:	75 d8                	jne    800b60 <strtol+0x44>
		s++, base = 8;
  800b88:	83 c1 01             	add    $0x1,%ecx
  800b8b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b90:	eb ce                	jmp    800b60 <strtol+0x44>
		s += 2, base = 16;
  800b92:	83 c1 02             	add    $0x2,%ecx
  800b95:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9a:	eb c4                	jmp    800b60 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba5:	7d 3a                	jge    800be1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bae:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bb0:	0f b6 11             	movzbl (%ecx),%edx
  800bb3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb6:	89 f3                	mov    %esi,%ebx
  800bb8:	80 fb 09             	cmp    $0x9,%bl
  800bbb:	76 df                	jbe    800b9c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bbd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc0:	89 f3                	mov    %esi,%ebx
  800bc2:	80 fb 19             	cmp    $0x19,%bl
  800bc5:	77 08                	ja     800bcf <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc7:	0f be d2             	movsbl %dl,%edx
  800bca:	83 ea 57             	sub    $0x57,%edx
  800bcd:	eb d3                	jmp    800ba2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bcf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bd2:	89 f3                	mov    %esi,%ebx
  800bd4:	80 fb 19             	cmp    $0x19,%bl
  800bd7:	77 08                	ja     800be1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bd9:	0f be d2             	movsbl %dl,%edx
  800bdc:	83 ea 37             	sub    $0x37,%edx
  800bdf:	eb c1                	jmp    800ba2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800be1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be5:	74 05                	je     800bec <strtol+0xd0>
		*endptr = (char *) s;
  800be7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bea:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bec:	89 c2                	mov    %eax,%edx
  800bee:	f7 da                	neg    %edx
  800bf0:	85 ff                	test   %edi,%edi
  800bf2:	0f 45 c2             	cmovne %edx,%eax
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfa:	f3 0f 1e fb          	endbr32 
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	89 c3                	mov    %eax,%ebx
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	89 c6                	mov    %eax,%esi
  800c15:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1c:	f3 0f 1e fb          	endbr32 
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c26:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c30:	89 d1                	mov    %edx,%ecx
  800c32:	89 d3                	mov    %edx,%ebx
  800c34:	89 d7                	mov    %edx,%edi
  800c36:	89 d6                	mov    %edx,%esi
  800c38:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c3f:	f3 0f 1e fb          	endbr32 
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	b8 03 00 00 00       	mov    $0x3,%eax
  800c56:	89 cb                	mov    %ecx,%ebx
  800c58:	89 cf                	mov    %ecx,%edi
  800c5a:	89 ce                	mov    %ecx,%esi
  800c5c:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c63:	f3 0f 1e fb          	endbr32 
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	f3 0f 1e fb          	endbr32 
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c90:	ba 00 00 00 00       	mov    $0x0,%edx
  800c95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9a:	89 d1                	mov    %edx,%ecx
  800c9c:	89 d3                	mov    %edx,%ebx
  800c9e:	89 d7                	mov    %edx,%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca9:	f3 0f 1e fb          	endbr32 
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb3:	be 00 00 00 00       	mov    $0x0,%esi
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc6:	89 f7                	mov    %esi,%edi
  800cc8:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ccf:	f3 0f 1e fb          	endbr32 
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	8b 75 18             	mov    0x18(%ebp),%esi
  800ced:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf4:	f3 0f 1e fb          	endbr32 
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d19:	f3 0f 1e fb          	endbr32 
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d33:	89 df                	mov    %ebx,%edi
  800d35:	89 de                	mov    %ebx,%esi
  800d37:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3e:	f3 0f 1e fb          	endbr32 
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	b8 09 00 00 00       	mov    $0x9,%eax
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d63:	f3 0f 1e fb          	endbr32 
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d88:	f3 0f 1e fb          	endbr32 
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9d:	be 00 00 00 00       	mov    $0x0,%esi
  800da2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daf:	f3 0f 1e fb          	endbr32 
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dc6:	89 cb                	mov    %ecx,%ebx
  800dc8:	89 cf                	mov    %ecx,%edi
  800dca:	89 ce                	mov    %ecx,%esi
  800dcc:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dd3:	f3 0f 1e fb          	endbr32 
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ddd:	ba 00 00 00 00       	mov    $0x0,%edx
  800de2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de7:	89 d1                	mov    %edx,%ecx
  800de9:	89 d3                	mov    %edx,%ebx
  800deb:	89 d7                	mov    %edx,%edi
  800ded:	89 d6                	mov    %edx,%esi
  800def:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800df6:	f3 0f 1e fb          	endbr32 
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	89 de                	mov    %ebx,%esi
  800e14:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e1b:	f3 0f 1e fb          	endbr32 
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	b8 10 00 00 00       	mov    $0x10,%eax
  800e35:	89 df                	mov    %ebx,%edi
  800e37:	89 de                	mov    %ebx,%esi
  800e39:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800e4e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800e50:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e54:	0f 84 9a 00 00 00    	je     800ef4 <pgfault+0xb4>
  800e5a:	89 d8                	mov    %ebx,%eax
  800e5c:	c1 e8 16             	shr    $0x16,%eax
  800e5f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e66:	a8 01                	test   $0x1,%al
  800e68:	0f 84 86 00 00 00    	je     800ef4 <pgfault+0xb4>
  800e6e:	89 d8                	mov    %ebx,%eax
  800e70:	c1 e8 0c             	shr    $0xc,%eax
  800e73:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	74 75                	je     800ef4 <pgfault+0xb4>
  800e7f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e86:	f6 c4 08             	test   $0x8,%ah
  800e89:	74 69                	je     800ef4 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	6a 07                	push   $0x7
  800e90:	68 00 f0 7f 00       	push   $0x7ff000
  800e95:	6a 00                	push   $0x0
  800e97:	e8 0d fe ff ff       	call   800ca9 <sys_page_alloc>
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	78 63                	js     800f06 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	68 00 10 00 00       	push   $0x1000
  800eb1:	53                   	push   %ebx
  800eb2:	68 00 f0 7f 00       	push   $0x7ff000
  800eb7:	e8 e8 fb ff ff       	call   800aa4 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800ebc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec3:	53                   	push   %ebx
  800ec4:	6a 00                	push   $0x0
  800ec6:	68 00 f0 7f 00       	push   $0x7ff000
  800ecb:	6a 00                	push   $0x0
  800ecd:	e8 fd fd ff ff       	call   800ccf <sys_page_map>
  800ed2:	83 c4 20             	add    $0x20,%esp
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	78 3f                	js     800f18 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	68 00 f0 7f 00       	push   $0x7ff000
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 0c fe ff ff       	call   800cf4 <sys_page_unmap>
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 3b                	js     800f2a <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800ef4:	53                   	push   %ebx
  800ef5:	68 a0 2a 80 00       	push   $0x802aa0
  800efa:	6a 20                	push   $0x20
  800efc:	68 5e 2b 80 00       	push   $0x802b5e
  800f01:	e8 49 f2 ff ff       	call   80014f <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800f06:	50                   	push   %eax
  800f07:	68 e0 2a 80 00       	push   $0x802ae0
  800f0c:	6a 2c                	push   $0x2c
  800f0e:	68 5e 2b 80 00       	push   $0x802b5e
  800f13:	e8 37 f2 ff ff       	call   80014f <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800f18:	50                   	push   %eax
  800f19:	68 0c 2b 80 00       	push   $0x802b0c
  800f1e:	6a 33                	push   $0x33
  800f20:	68 5e 2b 80 00       	push   $0x802b5e
  800f25:	e8 25 f2 ff ff       	call   80014f <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800f2a:	50                   	push   %eax
  800f2b:	68 34 2b 80 00       	push   $0x802b34
  800f30:	6a 36                	push   $0x36
  800f32:	68 5e 2b 80 00       	push   $0x802b5e
  800f37:	e8 13 f2 ff ff       	call   80014f <_panic>

00800f3c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3c:	f3 0f 1e fb          	endbr32 
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800f49:	68 40 0e 80 00       	push   $0x800e40
  800f4e:	e8 82 13 00 00       	call   8022d5 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f53:	b8 07 00 00 00       	mov    $0x7,%eax
  800f58:	cd 30                	int    $0x30
  800f5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	78 29                	js     800f8d <fork+0x51>
  800f64:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f66:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  800f6b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f6f:	75 60                	jne    800fd1 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f71:	e8 ed fc ff ff       	call   800c63 <sys_getenvid>
  800f76:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f7e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f83:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800f88:	e9 14 01 00 00       	jmp    8010a1 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  800f8d:	50                   	push   %eax
  800f8e:	68 69 2b 80 00       	push   $0x802b69
  800f93:	68 90 00 00 00       	push   $0x90
  800f98:	68 5e 2b 80 00       	push   $0x802b5e
  800f9d:	e8 ad f1 ff ff       	call   80014f <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  800fa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb1:	50                   	push   %eax
  800fb2:	56                   	push   %esi
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 13 fd ff ff       	call   800ccf <sys_page_map>
  800fbc:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800fbf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fcb:	0f 84 95 00 00 00    	je     801066 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	c1 e8 16             	shr    $0x16,%eax
  800fd6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fdd:	a8 01                	test   $0x1,%al
  800fdf:	74 de                	je     800fbf <fork+0x83>
  800fe1:	89 d8                	mov    %ebx,%eax
  800fe3:	c1 e8 0c             	shr    $0xc,%eax
  800fe6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fed:	f6 c2 01             	test   $0x1,%dl
  800ff0:	74 cd                	je     800fbf <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  800ff2:	89 c6                	mov    %eax,%esi
  800ff4:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  800ff7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffe:	f6 c6 04             	test   $0x4,%dh
  801001:	75 9f                	jne    800fa2 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  801003:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100a:	f6 c2 02             	test   $0x2,%dl
  80100d:	75 0c                	jne    80101b <fork+0xdf>
  80100f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801016:	f6 c4 08             	test   $0x8,%ah
  801019:	74 34                	je     80104f <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	68 05 08 00 00       	push   $0x805
  801023:	56                   	push   %esi
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	6a 00                	push   $0x0
  801028:	e8 a2 fc ff ff       	call   800ccf <sys_page_map>
			if (r<0) return r;
  80102d:	83 c4 20             	add    $0x20,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 8b                	js     800fbf <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	68 05 08 00 00       	push   $0x805
  80103c:	56                   	push   %esi
  80103d:	6a 00                	push   $0x0
  80103f:	56                   	push   %esi
  801040:	6a 00                	push   $0x0
  801042:	e8 88 fc ff ff       	call   800ccf <sys_page_map>
  801047:	83 c4 20             	add    $0x20,%esp
  80104a:	e9 70 ff ff ff       	jmp    800fbf <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	6a 05                	push   $0x5
  801054:	56                   	push   %esi
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 71 fc ff ff       	call   800ccf <sys_page_map>
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	e9 59 ff ff ff       	jmp    800fbf <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  801066:	83 ec 04             	sub    $0x4,%esp
  801069:	6a 07                	push   $0x7
  80106b:	68 00 f0 bf ee       	push   $0xeebff000
  801070:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801073:	56                   	push   %esi
  801074:	e8 30 fc ff ff       	call   800ca9 <sys_page_alloc>
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	78 2b                	js     8010ab <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	68 48 23 80 00       	push   $0x802348
  801088:	56                   	push   %esi
  801089:	e8 d5 fc ff ff       	call   800d63 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80108e:	83 c4 08             	add    $0x8,%esp
  801091:	6a 02                	push   $0x2
  801093:	56                   	push   %esi
  801094:	e8 80 fc ff ff       	call   800d19 <sys_env_set_status>
  801099:	83 c4 10             	add    $0x10,%esp
		return r;
  80109c:	85 c0                	test   %eax,%eax
  80109e:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  8010a1:	89 f8                	mov    %edi,%eax
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    
		return r;
  8010ab:	89 c7                	mov    %eax,%edi
  8010ad:	eb f2                	jmp    8010a1 <fork+0x165>

008010af <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  8010af:	f3 0f 1e fb          	endbr32 
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b9:	68 85 2b 80 00       	push   $0x802b85
  8010be:	68 b2 00 00 00       	push   $0xb2
  8010c3:	68 5e 2b 80 00       	push   $0x802b5e
  8010c8:	e8 82 f0 ff ff       	call   80014f <_panic>

008010cd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010cd:	f3 0f 1e fb          	endbr32 
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010e1:	f3 0f 1e fb          	endbr32 
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010eb:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010f5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    

008010fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010fc:	f3 0f 1e fb          	endbr32 
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801108:	89 c2                	mov    %eax,%edx
  80110a:	c1 ea 16             	shr    $0x16,%edx
  80110d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801114:	f6 c2 01             	test   $0x1,%dl
  801117:	74 2d                	je     801146 <fd_alloc+0x4a>
  801119:	89 c2                	mov    %eax,%edx
  80111b:	c1 ea 0c             	shr    $0xc,%edx
  80111e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801125:	f6 c2 01             	test   $0x1,%dl
  801128:	74 1c                	je     801146 <fd_alloc+0x4a>
  80112a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80112f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801134:	75 d2                	jne    801108 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
  801139:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80113f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801144:	eb 0a                	jmp    801150 <fd_alloc+0x54>
			*fd_store = fd;
  801146:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801149:	89 01                	mov    %eax,(%ecx)
			return 0;
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801152:	f3 0f 1e fb          	endbr32 
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80115c:	83 f8 1f             	cmp    $0x1f,%eax
  80115f:	77 30                	ja     801191 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801161:	c1 e0 0c             	shl    $0xc,%eax
  801164:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801169:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80116f:	f6 c2 01             	test   $0x1,%dl
  801172:	74 24                	je     801198 <fd_lookup+0x46>
  801174:	89 c2                	mov    %eax,%edx
  801176:	c1 ea 0c             	shr    $0xc,%edx
  801179:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801180:	f6 c2 01             	test   $0x1,%dl
  801183:	74 1a                	je     80119f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801185:	8b 55 0c             	mov    0xc(%ebp),%edx
  801188:	89 02                	mov    %eax,(%edx)
	return 0;
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    
		return -E_INVAL;
  801191:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801196:	eb f7                	jmp    80118f <fd_lookup+0x3d>
		return -E_INVAL;
  801198:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119d:	eb f0                	jmp    80118f <fd_lookup+0x3d>
  80119f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a4:	eb e9                	jmp    80118f <fd_lookup+0x3d>

008011a6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011a6:	f3 0f 1e fb          	endbr32 
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  8011b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b8:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8011bd:	39 08                	cmp    %ecx,(%eax)
  8011bf:	74 38                	je     8011f9 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  8011c1:	83 c2 01             	add    $0x1,%edx
  8011c4:	8b 04 95 18 2c 80 00 	mov    0x802c18(,%edx,4),%eax
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	75 ee                	jne    8011bd <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011cf:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011d4:	8b 40 48             	mov    0x48(%eax),%eax
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	51                   	push   %ecx
  8011db:	50                   	push   %eax
  8011dc:	68 9c 2b 80 00       	push   $0x802b9c
  8011e1:	e8 50 f0 ff ff       	call   800236 <cprintf>
	*dev = 0;
  8011e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    
			*dev = devtab[i];
  8011f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801203:	eb f2                	jmp    8011f7 <dev_lookup+0x51>

00801205 <fd_close>:
{
  801205:	f3 0f 1e fb          	endbr32 
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	57                   	push   %edi
  80120d:	56                   	push   %esi
  80120e:	53                   	push   %ebx
  80120f:	83 ec 24             	sub    $0x24,%esp
  801212:	8b 75 08             	mov    0x8(%ebp),%esi
  801215:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801218:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80121b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801222:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801225:	50                   	push   %eax
  801226:	e8 27 ff ff ff       	call   801152 <fd_lookup>
  80122b:	89 c3                	mov    %eax,%ebx
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	78 05                	js     801239 <fd_close+0x34>
	    || fd != fd2)
  801234:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801237:	74 16                	je     80124f <fd_close+0x4a>
		return (must_exist ? r : 0);
  801239:	89 f8                	mov    %edi,%eax
  80123b:	84 c0                	test   %al,%al
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
  801242:	0f 44 d8             	cmove  %eax,%ebx
}
  801245:	89 d8                	mov    %ebx,%eax
  801247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124a:	5b                   	pop    %ebx
  80124b:	5e                   	pop    %esi
  80124c:	5f                   	pop    %edi
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80124f:	83 ec 08             	sub    $0x8,%esp
  801252:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	ff 36                	pushl  (%esi)
  801258:	e8 49 ff ff ff       	call   8011a6 <dev_lookup>
  80125d:	89 c3                	mov    %eax,%ebx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	78 1a                	js     801280 <fd_close+0x7b>
		if (dev->dev_close)
  801266:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801269:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80126c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801271:	85 c0                	test   %eax,%eax
  801273:	74 0b                	je     801280 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	56                   	push   %esi
  801279:	ff d0                	call   *%eax
  80127b:	89 c3                	mov    %eax,%ebx
  80127d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	56                   	push   %esi
  801284:	6a 00                	push   $0x0
  801286:	e8 69 fa ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	eb b5                	jmp    801245 <fd_close+0x40>

00801290 <close>:

int
close(int fdnum)
{
  801290:	f3 0f 1e fb          	endbr32 
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	ff 75 08             	pushl  0x8(%ebp)
  8012a1:	e8 ac fe ff ff       	call   801152 <fd_lookup>
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	79 02                	jns    8012af <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    
		return fd_close(fd, 1);
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	6a 01                	push   $0x1
  8012b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b7:	e8 49 ff ff ff       	call   801205 <fd_close>
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	eb ec                	jmp    8012ad <close+0x1d>

008012c1 <close_all>:

void
close_all(void)
{
  8012c1:	f3 0f 1e fb          	endbr32 
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	e8 b6 ff ff ff       	call   801290 <close>
	for (i = 0; i < MAXFD; i++)
  8012da:	83 c3 01             	add    $0x1,%ebx
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	83 fb 20             	cmp    $0x20,%ebx
  8012e3:	75 ec                	jne    8012d1 <close_all+0x10>
}
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012ea:	f3 0f 1e fb          	endbr32 
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	ff 75 08             	pushl  0x8(%ebp)
  8012fe:	e8 4f fe ff ff       	call   801152 <fd_lookup>
  801303:	89 c3                	mov    %eax,%ebx
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	0f 88 81 00 00 00    	js     801391 <dup+0xa7>
		return r;
	close(newfdnum);
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	ff 75 0c             	pushl  0xc(%ebp)
  801316:	e8 75 ff ff ff       	call   801290 <close>

	newfd = INDEX2FD(newfdnum);
  80131b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80131e:	c1 e6 0c             	shl    $0xc,%esi
  801321:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801327:	83 c4 04             	add    $0x4,%esp
  80132a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132d:	e8 af fd ff ff       	call   8010e1 <fd2data>
  801332:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801334:	89 34 24             	mov    %esi,(%esp)
  801337:	e8 a5 fd ff ff       	call   8010e1 <fd2data>
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801341:	89 d8                	mov    %ebx,%eax
  801343:	c1 e8 16             	shr    $0x16,%eax
  801346:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134d:	a8 01                	test   $0x1,%al
  80134f:	74 11                	je     801362 <dup+0x78>
  801351:	89 d8                	mov    %ebx,%eax
  801353:	c1 e8 0c             	shr    $0xc,%eax
  801356:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135d:	f6 c2 01             	test   $0x1,%dl
  801360:	75 39                	jne    80139b <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801362:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801365:	89 d0                	mov    %edx,%eax
  801367:	c1 e8 0c             	shr    $0xc,%eax
  80136a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	25 07 0e 00 00       	and    $0xe07,%eax
  801379:	50                   	push   %eax
  80137a:	56                   	push   %esi
  80137b:	6a 00                	push   $0x0
  80137d:	52                   	push   %edx
  80137e:	6a 00                	push   $0x0
  801380:	e8 4a f9 ff ff       	call   800ccf <sys_page_map>
  801385:	89 c3                	mov    %eax,%ebx
  801387:	83 c4 20             	add    $0x20,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 31                	js     8013bf <dup+0xd5>
		goto err;

	return newfdnum;
  80138e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801391:	89 d8                	mov    %ebx,%eax
  801393:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013aa:	50                   	push   %eax
  8013ab:	57                   	push   %edi
  8013ac:	6a 00                	push   $0x0
  8013ae:	53                   	push   %ebx
  8013af:	6a 00                	push   $0x0
  8013b1:	e8 19 f9 ff ff       	call   800ccf <sys_page_map>
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	83 c4 20             	add    $0x20,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	79 a3                	jns    801362 <dup+0x78>
	sys_page_unmap(0, newfd);
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	56                   	push   %esi
  8013c3:	6a 00                	push   $0x0
  8013c5:	e8 2a f9 ff ff       	call   800cf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ca:	83 c4 08             	add    $0x8,%esp
  8013cd:	57                   	push   %edi
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 1f f9 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	eb b7                	jmp    801391 <dup+0xa7>

008013da <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013da:	f3 0f 1e fb          	endbr32 
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 1c             	sub    $0x1c,%esp
  8013e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	53                   	push   %ebx
  8013ed:	e8 60 fd ff ff       	call   801152 <fd_lookup>
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 3f                	js     801438 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801403:	ff 30                	pushl  (%eax)
  801405:	e8 9c fd ff ff       	call   8011a6 <dev_lookup>
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 27                	js     801438 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801411:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801414:	8b 42 08             	mov    0x8(%edx),%eax
  801417:	83 e0 03             	and    $0x3,%eax
  80141a:	83 f8 01             	cmp    $0x1,%eax
  80141d:	74 1e                	je     80143d <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80141f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801422:	8b 40 08             	mov    0x8(%eax),%eax
  801425:	85 c0                	test   %eax,%eax
  801427:	74 35                	je     80145e <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801429:	83 ec 04             	sub    $0x4,%esp
  80142c:	ff 75 10             	pushl  0x10(%ebp)
  80142f:	ff 75 0c             	pushl  0xc(%ebp)
  801432:	52                   	push   %edx
  801433:	ff d0                	call   *%eax
  801435:	83 c4 10             	add    $0x10,%esp
}
  801438:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80143d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801442:	8b 40 48             	mov    0x48(%eax),%eax
  801445:	83 ec 04             	sub    $0x4,%esp
  801448:	53                   	push   %ebx
  801449:	50                   	push   %eax
  80144a:	68 dd 2b 80 00       	push   $0x802bdd
  80144f:	e8 e2 ed ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145c:	eb da                	jmp    801438 <read+0x5e>
		return -E_NOT_SUPP;
  80145e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801463:	eb d3                	jmp    801438 <read+0x5e>

00801465 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801465:	f3 0f 1e fb          	endbr32 
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	57                   	push   %edi
  80146d:	56                   	push   %esi
  80146e:	53                   	push   %ebx
  80146f:	83 ec 0c             	sub    $0xc,%esp
  801472:	8b 7d 08             	mov    0x8(%ebp),%edi
  801475:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801478:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147d:	eb 02                	jmp    801481 <readn+0x1c>
  80147f:	01 c3                	add    %eax,%ebx
  801481:	39 f3                	cmp    %esi,%ebx
  801483:	73 21                	jae    8014a6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801485:	83 ec 04             	sub    $0x4,%esp
  801488:	89 f0                	mov    %esi,%eax
  80148a:	29 d8                	sub    %ebx,%eax
  80148c:	50                   	push   %eax
  80148d:	89 d8                	mov    %ebx,%eax
  80148f:	03 45 0c             	add    0xc(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	57                   	push   %edi
  801494:	e8 41 ff ff ff       	call   8013da <read>
		if (m < 0)
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 04                	js     8014a4 <readn+0x3f>
			return m;
		if (m == 0)
  8014a0:	75 dd                	jne    80147f <readn+0x1a>
  8014a2:	eb 02                	jmp    8014a6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014a4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5e                   	pop    %esi
  8014ad:	5f                   	pop    %edi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b0:	f3 0f 1e fb          	endbr32 
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 1c             	sub    $0x1c,%esp
  8014bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	53                   	push   %ebx
  8014c3:	e8 8a fc ff ff       	call   801152 <fd_lookup>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 3a                	js     801509 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d9:	ff 30                	pushl  (%eax)
  8014db:	e8 c6 fc ff ff       	call   8011a6 <dev_lookup>
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 22                	js     801509 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ee:	74 1e                	je     80150e <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f6:	85 d2                	test   %edx,%edx
  8014f8:	74 35                	je     80152f <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	ff 75 10             	pushl  0x10(%ebp)
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	50                   	push   %eax
  801504:	ff d2                	call   *%edx
  801506:	83 c4 10             	add    $0x10,%esp
}
  801509:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80150e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801513:	8b 40 48             	mov    0x48(%eax),%eax
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	53                   	push   %ebx
  80151a:	50                   	push   %eax
  80151b:	68 f9 2b 80 00       	push   $0x802bf9
  801520:	e8 11 ed ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152d:	eb da                	jmp    801509 <write+0x59>
		return -E_NOT_SUPP;
  80152f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801534:	eb d3                	jmp    801509 <write+0x59>

00801536 <seek>:

int
seek(int fdnum, off_t offset)
{
  801536:	f3 0f 1e fb          	endbr32 
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	ff 75 08             	pushl  0x8(%ebp)
  801547:	e8 06 fc ff ff       	call   801152 <fd_lookup>
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 0e                	js     801561 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801553:	8b 55 0c             	mov    0xc(%ebp),%edx
  801556:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801559:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801563:	f3 0f 1e fb          	endbr32 
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	53                   	push   %ebx
  80156b:	83 ec 1c             	sub    $0x1c,%esp
  80156e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801571:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	53                   	push   %ebx
  801576:	e8 d7 fb ff ff       	call   801152 <fd_lookup>
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 37                	js     8015b9 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801582:	83 ec 08             	sub    $0x8,%esp
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158c:	ff 30                	pushl  (%eax)
  80158e:	e8 13 fc ff ff       	call   8011a6 <dev_lookup>
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	78 1f                	js     8015b9 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a1:	74 1b                	je     8015be <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a6:	8b 52 18             	mov    0x18(%edx),%edx
  8015a9:	85 d2                	test   %edx,%edx
  8015ab:	74 32                	je     8015df <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	ff 75 0c             	pushl  0xc(%ebp)
  8015b3:	50                   	push   %eax
  8015b4:	ff d2                	call   *%edx
  8015b6:	83 c4 10             	add    $0x10,%esp
}
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015be:	a1 0c 40 80 00       	mov    0x80400c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015c3:	8b 40 48             	mov    0x48(%eax),%eax
  8015c6:	83 ec 04             	sub    $0x4,%esp
  8015c9:	53                   	push   %ebx
  8015ca:	50                   	push   %eax
  8015cb:	68 bc 2b 80 00       	push   $0x802bbc
  8015d0:	e8 61 ec ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015dd:	eb da                	jmp    8015b9 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8015df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e4:	eb d3                	jmp    8015b9 <ftruncate+0x56>

008015e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e6:	f3 0f 1e fb          	endbr32 
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 1c             	sub    $0x1c,%esp
  8015f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	ff 75 08             	pushl  0x8(%ebp)
  8015fb:	e8 52 fb ff ff       	call   801152 <fd_lookup>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 4b                	js     801652 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	ff 30                	pushl  (%eax)
  801613:	e8 8e fb ff ff       	call   8011a6 <dev_lookup>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 33                	js     801652 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801622:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801626:	74 2f                	je     801657 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801628:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80162b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801632:	00 00 00 
	stat->st_isdir = 0;
  801635:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80163c:	00 00 00 
	stat->st_dev = dev;
  80163f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	53                   	push   %ebx
  801649:	ff 75 f0             	pushl  -0x10(%ebp)
  80164c:	ff 50 14             	call   *0x14(%eax)
  80164f:	83 c4 10             	add    $0x10,%esp
}
  801652:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801655:	c9                   	leave  
  801656:	c3                   	ret    
		return -E_NOT_SUPP;
  801657:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80165c:	eb f4                	jmp    801652 <fstat+0x6c>

0080165e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165e:	f3 0f 1e fb          	endbr32 
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	56                   	push   %esi
  801666:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	6a 00                	push   $0x0
  80166c:	ff 75 08             	pushl  0x8(%ebp)
  80166f:	e8 01 02 00 00       	call   801875 <open>
  801674:	89 c3                	mov    %eax,%ebx
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 1b                	js     801698 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80167d:	83 ec 08             	sub    $0x8,%esp
  801680:	ff 75 0c             	pushl  0xc(%ebp)
  801683:	50                   	push   %eax
  801684:	e8 5d ff ff ff       	call   8015e6 <fstat>
  801689:	89 c6                	mov    %eax,%esi
	close(fd);
  80168b:	89 1c 24             	mov    %ebx,(%esp)
  80168e:	e8 fd fb ff ff       	call   801290 <close>
	return r;
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	89 f3                	mov    %esi,%ebx
}
  801698:	89 d8                	mov    %ebx,%eax
  80169a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	89 c6                	mov    %eax,%esi
  8016a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016aa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016b1:	74 27                	je     8016da <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b3:	6a 07                	push   $0x7
  8016b5:	68 00 50 80 00       	push   $0x805000
  8016ba:	56                   	push   %esi
  8016bb:	ff 35 00 40 80 00    	pushl  0x804000
  8016c1:	e8 13 0d 00 00       	call   8023d9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016c6:	83 c4 0c             	add    $0xc,%esp
  8016c9:	6a 00                	push   $0x0
  8016cb:	53                   	push   %ebx
  8016cc:	6a 00                	push   $0x0
  8016ce:	e8 99 0c 00 00       	call   80236c <ipc_recv>
}
  8016d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d6:	5b                   	pop    %ebx
  8016d7:	5e                   	pop    %esi
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	6a 01                	push   $0x1
  8016df:	e8 4d 0d 00 00       	call   802431 <ipc_find_env>
  8016e4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	eb c5                	jmp    8016b3 <fsipc+0x12>

008016ee <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ee:	f3 0f 1e fb          	endbr32 
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
  801706:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170b:	ba 00 00 00 00       	mov    $0x0,%edx
  801710:	b8 02 00 00 00       	mov    $0x2,%eax
  801715:	e8 87 ff ff ff       	call   8016a1 <fsipc>
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <devfile_flush>:
{
  80171c:	f3 0f 1e fb          	endbr32 
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	8b 40 0c             	mov    0xc(%eax),%eax
  80172c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801731:	ba 00 00 00 00       	mov    $0x0,%edx
  801736:	b8 06 00 00 00       	mov    $0x6,%eax
  80173b:	e8 61 ff ff ff       	call   8016a1 <fsipc>
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <devfile_stat>:
{
  801742:	f3 0f 1e fb          	endbr32 
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	53                   	push   %ebx
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	8b 40 0c             	mov    0xc(%eax),%eax
  801756:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175b:	ba 00 00 00 00       	mov    $0x0,%edx
  801760:	b8 05 00 00 00       	mov    $0x5,%eax
  801765:	e8 37 ff ff ff       	call   8016a1 <fsipc>
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 2c                	js     80179a <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	68 00 50 80 00       	push   $0x805000
  801776:	53                   	push   %ebx
  801777:	e8 c4 f0 ff ff       	call   800840 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177c:	a1 80 50 80 00       	mov    0x805080,%eax
  801781:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801787:	a1 84 50 80 00       	mov    0x805084,%eax
  80178c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179d:	c9                   	leave  
  80179e:	c3                   	ret    

0080179f <devfile_write>:
{
  80179f:	f3 0f 1e fb          	endbr32 
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ac:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017b1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017b6:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8017bf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017c5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017ca:	50                   	push   %eax
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	68 08 50 80 00       	push   $0x805008
  8017d3:	e8 66 f2 ff ff       	call   800a3e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dd:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e2:	e8 ba fe ff ff       	call   8016a1 <fsipc>
}
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    

008017e9 <devfile_read>:
{
  8017e9:	f3 0f 1e fb          	endbr32 
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
  8017f2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801800:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801806:	ba 00 00 00 00       	mov    $0x0,%edx
  80180b:	b8 03 00 00 00       	mov    $0x3,%eax
  801810:	e8 8c fe ff ff       	call   8016a1 <fsipc>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	85 c0                	test   %eax,%eax
  801819:	78 1f                	js     80183a <devfile_read+0x51>
	assert(r <= n);
  80181b:	39 f0                	cmp    %esi,%eax
  80181d:	77 24                	ja     801843 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80181f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801824:	7f 36                	jg     80185c <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	50                   	push   %eax
  80182a:	68 00 50 80 00       	push   $0x805000
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	e8 07 f2 ff ff       	call   800a3e <memmove>
	return r;
  801837:	83 c4 10             	add    $0x10,%esp
}
  80183a:	89 d8                	mov    %ebx,%eax
  80183c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    
	assert(r <= n);
  801843:	68 2c 2c 80 00       	push   $0x802c2c
  801848:	68 33 2c 80 00       	push   $0x802c33
  80184d:	68 8c 00 00 00       	push   $0x8c
  801852:	68 48 2c 80 00       	push   $0x802c48
  801857:	e8 f3 e8 ff ff       	call   80014f <_panic>
	assert(r <= PGSIZE);
  80185c:	68 53 2c 80 00       	push   $0x802c53
  801861:	68 33 2c 80 00       	push   $0x802c33
  801866:	68 8d 00 00 00       	push   $0x8d
  80186b:	68 48 2c 80 00       	push   $0x802c48
  801870:	e8 da e8 ff ff       	call   80014f <_panic>

00801875 <open>:
{
  801875:	f3 0f 1e fb          	endbr32 
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	83 ec 1c             	sub    $0x1c,%esp
  801881:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801884:	56                   	push   %esi
  801885:	e8 73 ef ff ff       	call   8007fd <strlen>
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801892:	7f 6c                	jg     801900 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189a:	50                   	push   %eax
  80189b:	e8 5c f8 ff ff       	call   8010fc <fd_alloc>
  8018a0:	89 c3                	mov    %eax,%ebx
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 3c                	js     8018e5 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	56                   	push   %esi
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	e8 89 ef ff ff       	call   800840 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ba:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c7:	e8 d5 fd ff ff       	call   8016a1 <fsipc>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	78 19                	js     8018ee <open+0x79>
	return fd2num(fd);
  8018d5:	83 ec 0c             	sub    $0xc,%esp
  8018d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018db:	e8 ed f7 ff ff       	call   8010cd <fd2num>
  8018e0:	89 c3                	mov    %eax,%ebx
  8018e2:	83 c4 10             	add    $0x10,%esp
}
  8018e5:	89 d8                	mov    %ebx,%eax
  8018e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    
		fd_close(fd, 0);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	6a 00                	push   $0x0
  8018f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f6:	e8 0a f9 ff ff       	call   801205 <fd_close>
		return r;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	eb e5                	jmp    8018e5 <open+0x70>
		return -E_BAD_PATH;
  801900:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801905:	eb de                	jmp    8018e5 <open+0x70>

00801907 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801907:	f3 0f 1e fb          	endbr32 
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
  801916:	b8 08 00 00 00       	mov    $0x8,%eax
  80191b:	e8 81 fd ff ff       	call   8016a1 <fsipc>
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801922:	f3 0f 1e fb          	endbr32 
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80192c:	68 bf 2c 80 00       	push   $0x802cbf
  801931:	ff 75 0c             	pushl  0xc(%ebp)
  801934:	e8 07 ef ff ff       	call   800840 <strcpy>
	return 0;
}
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <devsock_close>:
{
  801940:	f3 0f 1e fb          	endbr32 
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 10             	sub    $0x10,%esp
  80194b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80194e:	53                   	push   %ebx
  80194f:	e8 1a 0b 00 00       	call   80246e <pageref>
  801954:	89 c2                	mov    %eax,%edx
  801956:	83 c4 10             	add    $0x10,%esp
		return 0;
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80195e:	83 fa 01             	cmp    $0x1,%edx
  801961:	74 05                	je     801968 <devsock_close+0x28>
}
  801963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801966:	c9                   	leave  
  801967:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	ff 73 0c             	pushl  0xc(%ebx)
  80196e:	e8 e3 02 00 00       	call   801c56 <nsipc_close>
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	eb eb                	jmp    801963 <devsock_close+0x23>

00801978 <devsock_write>:
{
  801978:	f3 0f 1e fb          	endbr32 
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801982:	6a 00                	push   $0x0
  801984:	ff 75 10             	pushl  0x10(%ebp)
  801987:	ff 75 0c             	pushl  0xc(%ebp)
  80198a:	8b 45 08             	mov    0x8(%ebp),%eax
  80198d:	ff 70 0c             	pushl  0xc(%eax)
  801990:	e8 b5 03 00 00       	call   801d4a <nsipc_send>
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <devsock_read>:
{
  801997:	f3 0f 1e fb          	endbr32 
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019a1:	6a 00                	push   $0x0
  8019a3:	ff 75 10             	pushl  0x10(%ebp)
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	ff 70 0c             	pushl  0xc(%eax)
  8019af:	e8 1f 03 00 00       	call   801cd3 <nsipc_recv>
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <fd2sockid>:
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019bc:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019bf:	52                   	push   %edx
  8019c0:	50                   	push   %eax
  8019c1:	e8 8c f7 ff ff       	call   801152 <fd_lookup>
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 10                	js     8019dd <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d0:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  8019d6:	39 08                	cmp    %ecx,(%eax)
  8019d8:	75 05                	jne    8019df <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8019da:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    
		return -E_NOT_SUPP;
  8019df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019e4:	eb f7                	jmp    8019dd <fd2sockid+0x27>

008019e6 <alloc_sockfd>:
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	83 ec 1c             	sub    $0x1c,%esp
  8019ee:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	e8 03 f7 ff ff       	call   8010fc <fd_alloc>
  8019f9:	89 c3                	mov    %eax,%ebx
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 43                	js     801a45 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a02:	83 ec 04             	sub    $0x4,%esp
  801a05:	68 07 04 00 00       	push   $0x407
  801a0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0d:	6a 00                	push   $0x0
  801a0f:	e8 95 f2 ff ff       	call   800ca9 <sys_page_alloc>
  801a14:	89 c3                	mov    %eax,%ebx
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	78 28                	js     801a45 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a20:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801a26:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a32:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	50                   	push   %eax
  801a39:	e8 8f f6 ff ff       	call   8010cd <fd2num>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	eb 0c                	jmp    801a51 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	56                   	push   %esi
  801a49:	e8 08 02 00 00       	call   801c56 <nsipc_close>
		return r;
  801a4e:	83 c4 10             	add    $0x10,%esp
}
  801a51:	89 d8                	mov    %ebx,%eax
  801a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <accept>:
{
  801a5a:	f3 0f 1e fb          	endbr32 
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	e8 4a ff ff ff       	call   8019b6 <fd2sockid>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 1b                	js     801a8b <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	ff 75 10             	pushl  0x10(%ebp)
  801a76:	ff 75 0c             	pushl  0xc(%ebp)
  801a79:	50                   	push   %eax
  801a7a:	e8 22 01 00 00       	call   801ba1 <nsipc_accept>
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 05                	js     801a8b <accept+0x31>
	return alloc_sockfd(r);
  801a86:	e8 5b ff ff ff       	call   8019e6 <alloc_sockfd>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <bind>:
{
  801a8d:	f3 0f 1e fb          	endbr32 
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	e8 17 ff ff ff       	call   8019b6 <fd2sockid>
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 12                	js     801ab5 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	ff 75 10             	pushl  0x10(%ebp)
  801aa9:	ff 75 0c             	pushl  0xc(%ebp)
  801aac:	50                   	push   %eax
  801aad:	e8 45 01 00 00       	call   801bf7 <nsipc_bind>
  801ab2:	83 c4 10             	add    $0x10,%esp
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <shutdown>:
{
  801ab7:	f3 0f 1e fb          	endbr32 
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	e8 ed fe ff ff       	call   8019b6 <fd2sockid>
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 0f                	js     801adc <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801acd:	83 ec 08             	sub    $0x8,%esp
  801ad0:	ff 75 0c             	pushl  0xc(%ebp)
  801ad3:	50                   	push   %eax
  801ad4:	e8 57 01 00 00       	call   801c30 <nsipc_shutdown>
  801ad9:	83 c4 10             	add    $0x10,%esp
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <connect>:
{
  801ade:	f3 0f 1e fb          	endbr32 
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aeb:	e8 c6 fe ff ff       	call   8019b6 <fd2sockid>
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 12                	js     801b06 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801af4:	83 ec 04             	sub    $0x4,%esp
  801af7:	ff 75 10             	pushl  0x10(%ebp)
  801afa:	ff 75 0c             	pushl  0xc(%ebp)
  801afd:	50                   	push   %eax
  801afe:	e8 71 01 00 00       	call   801c74 <nsipc_connect>
  801b03:	83 c4 10             	add    $0x10,%esp
}
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <listen>:
{
  801b08:	f3 0f 1e fb          	endbr32 
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	e8 9c fe ff ff       	call   8019b6 <fd2sockid>
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 0f                	js     801b2d <listen+0x25>
	return nsipc_listen(r, backlog);
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	ff 75 0c             	pushl  0xc(%ebp)
  801b24:	50                   	push   %eax
  801b25:	e8 83 01 00 00       	call   801cad <nsipc_listen>
  801b2a:	83 c4 10             	add    $0x10,%esp
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <socket>:

int
socket(int domain, int type, int protocol)
{
  801b2f:	f3 0f 1e fb          	endbr32 
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b39:	ff 75 10             	pushl  0x10(%ebp)
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	ff 75 08             	pushl  0x8(%ebp)
  801b42:	e8 65 02 00 00       	call   801dac <nsipc_socket>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 05                	js     801b53 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801b4e:	e8 93 fe ff ff       	call   8019e6 <alloc_sockfd>
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	53                   	push   %ebx
  801b59:	83 ec 04             	sub    $0x4,%esp
  801b5c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b5e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b65:	74 26                	je     801b8d <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b67:	6a 07                	push   $0x7
  801b69:	68 00 60 80 00       	push   $0x806000
  801b6e:	53                   	push   %ebx
  801b6f:	ff 35 04 40 80 00    	pushl  0x804004
  801b75:	e8 5f 08 00 00       	call   8023d9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b7a:	83 c4 0c             	add    $0xc,%esp
  801b7d:	6a 00                	push   $0x0
  801b7f:	6a 00                	push   $0x0
  801b81:	6a 00                	push   $0x0
  801b83:	e8 e4 07 00 00       	call   80236c <ipc_recv>
}
  801b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b8d:	83 ec 0c             	sub    $0xc,%esp
  801b90:	6a 02                	push   $0x2
  801b92:	e8 9a 08 00 00       	call   802431 <ipc_find_env>
  801b97:	a3 04 40 80 00       	mov    %eax,0x804004
  801b9c:	83 c4 10             	add    $0x10,%esp
  801b9f:	eb c6                	jmp    801b67 <nsipc+0x12>

00801ba1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ba1:	f3 0f 1e fb          	endbr32 
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	56                   	push   %esi
  801ba9:	53                   	push   %ebx
  801baa:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bad:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bb5:	8b 06                	mov    (%esi),%eax
  801bb7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bbc:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc1:	e8 8f ff ff ff       	call   801b55 <nsipc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	79 09                	jns    801bd5 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bd5:	83 ec 04             	sub    $0x4,%esp
  801bd8:	ff 35 10 60 80 00    	pushl  0x806010
  801bde:	68 00 60 80 00       	push   $0x806000
  801be3:	ff 75 0c             	pushl  0xc(%ebp)
  801be6:	e8 53 ee ff ff       	call   800a3e <memmove>
		*addrlen = ret->ret_addrlen;
  801beb:	a1 10 60 80 00       	mov    0x806010,%eax
  801bf0:	89 06                	mov    %eax,(%esi)
  801bf2:	83 c4 10             	add    $0x10,%esp
	return r;
  801bf5:	eb d5                	jmp    801bcc <nsipc_accept+0x2b>

00801bf7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bf7:	f3 0f 1e fb          	endbr32 
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	53                   	push   %ebx
  801bff:	83 ec 08             	sub    $0x8,%esp
  801c02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c05:	8b 45 08             	mov    0x8(%ebp),%eax
  801c08:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c0d:	53                   	push   %ebx
  801c0e:	ff 75 0c             	pushl  0xc(%ebp)
  801c11:	68 04 60 80 00       	push   $0x806004
  801c16:	e8 23 ee ff ff       	call   800a3e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c1b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c21:	b8 02 00 00 00       	mov    $0x2,%eax
  801c26:	e8 2a ff ff ff       	call   801b55 <nsipc>
}
  801c2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c45:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c4a:	b8 03 00 00 00       	mov    $0x3,%eax
  801c4f:	e8 01 ff ff ff       	call   801b55 <nsipc>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <nsipc_close>:

int
nsipc_close(int s)
{
  801c56:	f3 0f 1e fb          	endbr32 
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c68:	b8 04 00 00 00       	mov    $0x4,%eax
  801c6d:	e8 e3 fe ff ff       	call   801b55 <nsipc>
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c74:	f3 0f 1e fb          	endbr32 
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 08             	sub    $0x8,%esp
  801c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c8a:	53                   	push   %ebx
  801c8b:	ff 75 0c             	pushl  0xc(%ebp)
  801c8e:	68 04 60 80 00       	push   $0x806004
  801c93:	e8 a6 ed ff ff       	call   800a3e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c98:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c9e:	b8 05 00 00 00       	mov    $0x5,%eax
  801ca3:	e8 ad fe ff ff       	call   801b55 <nsipc>
}
  801ca8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cab:	c9                   	leave  
  801cac:	c3                   	ret    

00801cad <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cad:	f3 0f 1e fb          	endbr32 
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cc7:	b8 06 00 00 00       	mov    $0x6,%eax
  801ccc:	e8 84 fe ff ff       	call   801b55 <nsipc>
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cd3:	f3 0f 1e fb          	endbr32 
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	56                   	push   %esi
  801cdb:	53                   	push   %ebx
  801cdc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ce7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ced:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cf5:	b8 07 00 00 00       	mov    $0x7,%eax
  801cfa:	e8 56 fe ff ff       	call   801b55 <nsipc>
  801cff:	89 c3                	mov    %eax,%ebx
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 26                	js     801d2b <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801d05:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801d0b:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d10:	0f 4e c6             	cmovle %esi,%eax
  801d13:	39 c3                	cmp    %eax,%ebx
  801d15:	7f 1d                	jg     801d34 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	53                   	push   %ebx
  801d1b:	68 00 60 80 00       	push   $0x806000
  801d20:	ff 75 0c             	pushl  0xc(%ebp)
  801d23:	e8 16 ed ff ff       	call   800a3e <memmove>
  801d28:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d2b:	89 d8                	mov    %ebx,%eax
  801d2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d34:	68 cb 2c 80 00       	push   $0x802ccb
  801d39:	68 33 2c 80 00       	push   $0x802c33
  801d3e:	6a 62                	push   $0x62
  801d40:	68 e0 2c 80 00       	push   $0x802ce0
  801d45:	e8 05 e4 ff ff       	call   80014f <_panic>

00801d4a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d4a:	f3 0f 1e fb          	endbr32 
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	53                   	push   %ebx
  801d52:	83 ec 04             	sub    $0x4,%esp
  801d55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d60:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d66:	7f 2e                	jg     801d96 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d68:	83 ec 04             	sub    $0x4,%esp
  801d6b:	53                   	push   %ebx
  801d6c:	ff 75 0c             	pushl  0xc(%ebp)
  801d6f:	68 0c 60 80 00       	push   $0x80600c
  801d74:	e8 c5 ec ff ff       	call   800a3e <memmove>
	nsipcbuf.send.req_size = size;
  801d79:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d7f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d82:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d87:	b8 08 00 00 00       	mov    $0x8,%eax
  801d8c:	e8 c4 fd ff ff       	call   801b55 <nsipc>
}
  801d91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    
	assert(size < 1600);
  801d96:	68 ec 2c 80 00       	push   $0x802cec
  801d9b:	68 33 2c 80 00       	push   $0x802c33
  801da0:	6a 6d                	push   $0x6d
  801da2:	68 e0 2c 80 00       	push   $0x802ce0
  801da7:	e8 a3 e3 ff ff       	call   80014f <_panic>

00801dac <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dac:	f3 0f 1e fb          	endbr32 
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dc6:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dce:	b8 09 00 00 00       	mov    $0x9,%eax
  801dd3:	e8 7d fd ff ff       	call   801b55 <nsipc>
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dda:	f3 0f 1e fb          	endbr32 
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	56                   	push   %esi
  801de2:	53                   	push   %ebx
  801de3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	ff 75 08             	pushl  0x8(%ebp)
  801dec:	e8 f0 f2 ff ff       	call   8010e1 <fd2data>
  801df1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801df3:	83 c4 08             	add    $0x8,%esp
  801df6:	68 f8 2c 80 00       	push   $0x802cf8
  801dfb:	53                   	push   %ebx
  801dfc:	e8 3f ea ff ff       	call   800840 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e01:	8b 46 04             	mov    0x4(%esi),%eax
  801e04:	2b 06                	sub    (%esi),%eax
  801e06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e0c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e13:	00 00 00 
	stat->st_dev = &devpipe;
  801e16:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801e1d:	30 80 00 
	return 0;
}
  801e20:	b8 00 00 00 00       	mov    $0x0,%eax
  801e25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    

00801e2c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e2c:	f3 0f 1e fb          	endbr32 
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	53                   	push   %ebx
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e3a:	53                   	push   %ebx
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 b2 ee ff ff       	call   800cf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e42:	89 1c 24             	mov    %ebx,(%esp)
  801e45:	e8 97 f2 ff ff       	call   8010e1 <fd2data>
  801e4a:	83 c4 08             	add    $0x8,%esp
  801e4d:	50                   	push   %eax
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 9f ee ff ff       	call   800cf4 <sys_page_unmap>
}
  801e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <_pipeisclosed>:
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	57                   	push   %edi
  801e5e:	56                   	push   %esi
  801e5f:	53                   	push   %ebx
  801e60:	83 ec 1c             	sub    $0x1c,%esp
  801e63:	89 c7                	mov    %eax,%edi
  801e65:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e67:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801e6c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	57                   	push   %edi
  801e73:	e8 f6 05 00 00       	call   80246e <pageref>
  801e78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e7b:	89 34 24             	mov    %esi,(%esp)
  801e7e:	e8 eb 05 00 00       	call   80246e <pageref>
		nn = thisenv->env_runs;
  801e83:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801e89:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	39 cb                	cmp    %ecx,%ebx
  801e91:	74 1b                	je     801eae <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e93:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e96:	75 cf                	jne    801e67 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e98:	8b 42 58             	mov    0x58(%edx),%eax
  801e9b:	6a 01                	push   $0x1
  801e9d:	50                   	push   %eax
  801e9e:	53                   	push   %ebx
  801e9f:	68 ff 2c 80 00       	push   $0x802cff
  801ea4:	e8 8d e3 ff ff       	call   800236 <cprintf>
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	eb b9                	jmp    801e67 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801eae:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eb1:	0f 94 c0             	sete   %al
  801eb4:	0f b6 c0             	movzbl %al,%eax
}
  801eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5f                   	pop    %edi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <devpipe_write>:
{
  801ebf:	f3 0f 1e fb          	endbr32 
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	57                   	push   %edi
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 28             	sub    $0x28,%esp
  801ecc:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ecf:	56                   	push   %esi
  801ed0:	e8 0c f2 ff ff       	call   8010e1 <fd2data>
  801ed5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	bf 00 00 00 00       	mov    $0x0,%edi
  801edf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ee2:	74 4f                	je     801f33 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ee4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ee7:	8b 0b                	mov    (%ebx),%ecx
  801ee9:	8d 51 20             	lea    0x20(%ecx),%edx
  801eec:	39 d0                	cmp    %edx,%eax
  801eee:	72 14                	jb     801f04 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801ef0:	89 da                	mov    %ebx,%edx
  801ef2:	89 f0                	mov    %esi,%eax
  801ef4:	e8 61 ff ff ff       	call   801e5a <_pipeisclosed>
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	75 3b                	jne    801f38 <devpipe_write+0x79>
			sys_yield();
  801efd:	e8 84 ed ff ff       	call   800c86 <sys_yield>
  801f02:	eb e0                	jmp    801ee4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f07:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f0b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f0e:	89 c2                	mov    %eax,%edx
  801f10:	c1 fa 1f             	sar    $0x1f,%edx
  801f13:	89 d1                	mov    %edx,%ecx
  801f15:	c1 e9 1b             	shr    $0x1b,%ecx
  801f18:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f1b:	83 e2 1f             	and    $0x1f,%edx
  801f1e:	29 ca                	sub    %ecx,%edx
  801f20:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f24:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f28:	83 c0 01             	add    $0x1,%eax
  801f2b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f2e:	83 c7 01             	add    $0x1,%edi
  801f31:	eb ac                	jmp    801edf <devpipe_write+0x20>
	return i;
  801f33:	8b 45 10             	mov    0x10(%ebp),%eax
  801f36:	eb 05                	jmp    801f3d <devpipe_write+0x7e>
				return 0;
  801f38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5f                   	pop    %edi
  801f43:	5d                   	pop    %ebp
  801f44:	c3                   	ret    

00801f45 <devpipe_read>:
{
  801f45:	f3 0f 1e fb          	endbr32 
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	57                   	push   %edi
  801f4d:	56                   	push   %esi
  801f4e:	53                   	push   %ebx
  801f4f:	83 ec 18             	sub    $0x18,%esp
  801f52:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f55:	57                   	push   %edi
  801f56:	e8 86 f1 ff ff       	call   8010e1 <fd2data>
  801f5b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	be 00 00 00 00       	mov    $0x0,%esi
  801f65:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f68:	75 14                	jne    801f7e <devpipe_read+0x39>
	return i;
  801f6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f6d:	eb 02                	jmp    801f71 <devpipe_read+0x2c>
				return i;
  801f6f:	89 f0                	mov    %esi,%eax
}
  801f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    
			sys_yield();
  801f79:	e8 08 ed ff ff       	call   800c86 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f7e:	8b 03                	mov    (%ebx),%eax
  801f80:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f83:	75 18                	jne    801f9d <devpipe_read+0x58>
			if (i > 0)
  801f85:	85 f6                	test   %esi,%esi
  801f87:	75 e6                	jne    801f6f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801f89:	89 da                	mov    %ebx,%edx
  801f8b:	89 f8                	mov    %edi,%eax
  801f8d:	e8 c8 fe ff ff       	call   801e5a <_pipeisclosed>
  801f92:	85 c0                	test   %eax,%eax
  801f94:	74 e3                	je     801f79 <devpipe_read+0x34>
				return 0;
  801f96:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9b:	eb d4                	jmp    801f71 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f9d:	99                   	cltd   
  801f9e:	c1 ea 1b             	shr    $0x1b,%edx
  801fa1:	01 d0                	add    %edx,%eax
  801fa3:	83 e0 1f             	and    $0x1f,%eax
  801fa6:	29 d0                	sub    %edx,%eax
  801fa8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fb3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fb6:	83 c6 01             	add    $0x1,%esi
  801fb9:	eb aa                	jmp    801f65 <devpipe_read+0x20>

00801fbb <pipe>:
{
  801fbb:	f3 0f 1e fb          	endbr32 
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fca:	50                   	push   %eax
  801fcb:	e8 2c f1 ff ff       	call   8010fc <fd_alloc>
  801fd0:	89 c3                	mov    %eax,%ebx
  801fd2:	83 c4 10             	add    $0x10,%esp
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	0f 88 23 01 00 00    	js     802100 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	68 07 04 00 00       	push   $0x407
  801fe5:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe8:	6a 00                	push   $0x0
  801fea:	e8 ba ec ff ff       	call   800ca9 <sys_page_alloc>
  801fef:	89 c3                	mov    %eax,%ebx
  801ff1:	83 c4 10             	add    $0x10,%esp
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	0f 88 04 01 00 00    	js     802100 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801ffc:	83 ec 0c             	sub    $0xc,%esp
  801fff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802002:	50                   	push   %eax
  802003:	e8 f4 f0 ff ff       	call   8010fc <fd_alloc>
  802008:	89 c3                	mov    %eax,%ebx
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	0f 88 db 00 00 00    	js     8020f0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802015:	83 ec 04             	sub    $0x4,%esp
  802018:	68 07 04 00 00       	push   $0x407
  80201d:	ff 75 f0             	pushl  -0x10(%ebp)
  802020:	6a 00                	push   $0x0
  802022:	e8 82 ec ff ff       	call   800ca9 <sys_page_alloc>
  802027:	89 c3                	mov    %eax,%ebx
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	85 c0                	test   %eax,%eax
  80202e:	0f 88 bc 00 00 00    	js     8020f0 <pipe+0x135>
	va = fd2data(fd0);
  802034:	83 ec 0c             	sub    $0xc,%esp
  802037:	ff 75 f4             	pushl  -0xc(%ebp)
  80203a:	e8 a2 f0 ff ff       	call   8010e1 <fd2data>
  80203f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802041:	83 c4 0c             	add    $0xc,%esp
  802044:	68 07 04 00 00       	push   $0x407
  802049:	50                   	push   %eax
  80204a:	6a 00                	push   $0x0
  80204c:	e8 58 ec ff ff       	call   800ca9 <sys_page_alloc>
  802051:	89 c3                	mov    %eax,%ebx
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	0f 88 82 00 00 00    	js     8020e0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80205e:	83 ec 0c             	sub    $0xc,%esp
  802061:	ff 75 f0             	pushl  -0x10(%ebp)
  802064:	e8 78 f0 ff ff       	call   8010e1 <fd2data>
  802069:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802070:	50                   	push   %eax
  802071:	6a 00                	push   $0x0
  802073:	56                   	push   %esi
  802074:	6a 00                	push   $0x0
  802076:	e8 54 ec ff ff       	call   800ccf <sys_page_map>
  80207b:	89 c3                	mov    %eax,%ebx
  80207d:	83 c4 20             	add    $0x20,%esp
  802080:	85 c0                	test   %eax,%eax
  802082:	78 4e                	js     8020d2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802084:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802089:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80208c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80208e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802091:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802098:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80209b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80209d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020a7:	83 ec 0c             	sub    $0xc,%esp
  8020aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ad:	e8 1b f0 ff ff       	call   8010cd <fd2num>
  8020b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020b7:	83 c4 04             	add    $0x4,%esp
  8020ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8020bd:	e8 0b f0 ff ff       	call   8010cd <fd2num>
  8020c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d0:	eb 2e                	jmp    802100 <pipe+0x145>
	sys_page_unmap(0, va);
  8020d2:	83 ec 08             	sub    $0x8,%esp
  8020d5:	56                   	push   %esi
  8020d6:	6a 00                	push   $0x0
  8020d8:	e8 17 ec ff ff       	call   800cf4 <sys_page_unmap>
  8020dd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020e0:	83 ec 08             	sub    $0x8,%esp
  8020e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8020e6:	6a 00                	push   $0x0
  8020e8:	e8 07 ec ff ff       	call   800cf4 <sys_page_unmap>
  8020ed:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020f0:	83 ec 08             	sub    $0x8,%esp
  8020f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 f7 eb ff ff       	call   800cf4 <sys_page_unmap>
  8020fd:	83 c4 10             	add    $0x10,%esp
}
  802100:	89 d8                	mov    %ebx,%eax
  802102:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802105:	5b                   	pop    %ebx
  802106:	5e                   	pop    %esi
  802107:	5d                   	pop    %ebp
  802108:	c3                   	ret    

00802109 <pipeisclosed>:
{
  802109:	f3 0f 1e fb          	endbr32 
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802113:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802116:	50                   	push   %eax
  802117:	ff 75 08             	pushl  0x8(%ebp)
  80211a:	e8 33 f0 ff ff       	call   801152 <fd_lookup>
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	85 c0                	test   %eax,%eax
  802124:	78 18                	js     80213e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802126:	83 ec 0c             	sub    $0xc,%esp
  802129:	ff 75 f4             	pushl  -0xc(%ebp)
  80212c:	e8 b0 ef ff ff       	call   8010e1 <fd2data>
  802131:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802133:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802136:	e8 1f fd ff ff       	call   801e5a <_pipeisclosed>
  80213b:	83 c4 10             	add    $0x10,%esp
}
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802140:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802144:	b8 00 00 00 00       	mov    $0x0,%eax
  802149:	c3                   	ret    

0080214a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80214a:	f3 0f 1e fb          	endbr32 
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802154:	68 17 2d 80 00       	push   $0x802d17
  802159:	ff 75 0c             	pushl  0xc(%ebp)
  80215c:	e8 df e6 ff ff       	call   800840 <strcpy>
	return 0;
}
  802161:	b8 00 00 00 00       	mov    $0x0,%eax
  802166:	c9                   	leave  
  802167:	c3                   	ret    

00802168 <devcons_write>:
{
  802168:	f3 0f 1e fb          	endbr32 
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	57                   	push   %edi
  802170:	56                   	push   %esi
  802171:	53                   	push   %ebx
  802172:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802178:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80217d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802183:	3b 75 10             	cmp    0x10(%ebp),%esi
  802186:	73 31                	jae    8021b9 <devcons_write+0x51>
		m = n - tot;
  802188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80218b:	29 f3                	sub    %esi,%ebx
  80218d:	83 fb 7f             	cmp    $0x7f,%ebx
  802190:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802195:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802198:	83 ec 04             	sub    $0x4,%esp
  80219b:	53                   	push   %ebx
  80219c:	89 f0                	mov    %esi,%eax
  80219e:	03 45 0c             	add    0xc(%ebp),%eax
  8021a1:	50                   	push   %eax
  8021a2:	57                   	push   %edi
  8021a3:	e8 96 e8 ff ff       	call   800a3e <memmove>
		sys_cputs(buf, m);
  8021a8:	83 c4 08             	add    $0x8,%esp
  8021ab:	53                   	push   %ebx
  8021ac:	57                   	push   %edi
  8021ad:	e8 48 ea ff ff       	call   800bfa <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021b2:	01 de                	add    %ebx,%esi
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	eb ca                	jmp    802183 <devcons_write+0x1b>
}
  8021b9:	89 f0                	mov    %esi,%eax
  8021bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021be:	5b                   	pop    %ebx
  8021bf:	5e                   	pop    %esi
  8021c0:	5f                   	pop    %edi
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    

008021c3 <devcons_read>:
{
  8021c3:	f3 0f 1e fb          	endbr32 
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 08             	sub    $0x8,%esp
  8021cd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d6:	74 21                	je     8021f9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8021d8:	e8 3f ea ff ff       	call   800c1c <sys_cgetc>
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	75 07                	jne    8021e8 <devcons_read+0x25>
		sys_yield();
  8021e1:	e8 a0 ea ff ff       	call   800c86 <sys_yield>
  8021e6:	eb f0                	jmp    8021d8 <devcons_read+0x15>
	if (c < 0)
  8021e8:	78 0f                	js     8021f9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8021ea:	83 f8 04             	cmp    $0x4,%eax
  8021ed:	74 0c                	je     8021fb <devcons_read+0x38>
	*(char*)vbuf = c;
  8021ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f2:	88 02                	mov    %al,(%edx)
	return 1;
  8021f4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    
		return 0;
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
  802200:	eb f7                	jmp    8021f9 <devcons_read+0x36>

00802202 <cputchar>:
{
  802202:	f3 0f 1e fb          	endbr32 
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80220c:	8b 45 08             	mov    0x8(%ebp),%eax
  80220f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802212:	6a 01                	push   $0x1
  802214:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802217:	50                   	push   %eax
  802218:	e8 dd e9 ff ff       	call   800bfa <sys_cputs>
}
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	c9                   	leave  
  802221:	c3                   	ret    

00802222 <getchar>:
{
  802222:	f3 0f 1e fb          	endbr32 
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80222c:	6a 01                	push   $0x1
  80222e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802231:	50                   	push   %eax
  802232:	6a 00                	push   $0x0
  802234:	e8 a1 f1 ff ff       	call   8013da <read>
	if (r < 0)
  802239:	83 c4 10             	add    $0x10,%esp
  80223c:	85 c0                	test   %eax,%eax
  80223e:	78 06                	js     802246 <getchar+0x24>
	if (r < 1)
  802240:	74 06                	je     802248 <getchar+0x26>
	return c;
  802242:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802246:	c9                   	leave  
  802247:	c3                   	ret    
		return -E_EOF;
  802248:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80224d:	eb f7                	jmp    802246 <getchar+0x24>

0080224f <iscons>:
{
  80224f:	f3 0f 1e fb          	endbr32 
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225c:	50                   	push   %eax
  80225d:	ff 75 08             	pushl  0x8(%ebp)
  802260:	e8 ed ee ff ff       	call   801152 <fd_lookup>
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	85 c0                	test   %eax,%eax
  80226a:	78 11                	js     80227d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80226c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226f:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802275:	39 10                	cmp    %edx,(%eax)
  802277:	0f 94 c0             	sete   %al
  80227a:	0f b6 c0             	movzbl %al,%eax
}
  80227d:	c9                   	leave  
  80227e:	c3                   	ret    

0080227f <opencons>:
{
  80227f:	f3 0f 1e fb          	endbr32 
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802289:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228c:	50                   	push   %eax
  80228d:	e8 6a ee ff ff       	call   8010fc <fd_alloc>
  802292:	83 c4 10             	add    $0x10,%esp
  802295:	85 c0                	test   %eax,%eax
  802297:	78 3a                	js     8022d3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802299:	83 ec 04             	sub    $0x4,%esp
  80229c:	68 07 04 00 00       	push   $0x407
  8022a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a4:	6a 00                	push   $0x0
  8022a6:	e8 fe e9 ff ff       	call   800ca9 <sys_page_alloc>
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	78 21                	js     8022d3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b5:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8022bb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022c7:	83 ec 0c             	sub    $0xc,%esp
  8022ca:	50                   	push   %eax
  8022cb:	e8 fd ed ff ff       	call   8010cd <fd2num>
  8022d0:	83 c4 10             	add    $0x10,%esp
}
  8022d3:	c9                   	leave  
  8022d4:	c3                   	ret    

008022d5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022d5:	f3 0f 1e fb          	endbr32 
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022df:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022e6:	74 0a                	je     8022f2 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022eb:	a3 00 70 80 00       	mov    %eax,0x807000

}
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8022f2:	83 ec 04             	sub    $0x4,%esp
  8022f5:	6a 07                	push   $0x7
  8022f7:	68 00 f0 bf ee       	push   $0xeebff000
  8022fc:	6a 00                	push   $0x0
  8022fe:	e8 a6 e9 ff ff       	call   800ca9 <sys_page_alloc>
  802303:	83 c4 10             	add    $0x10,%esp
  802306:	85 c0                	test   %eax,%eax
  802308:	78 2a                	js     802334 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  80230a:	83 ec 08             	sub    $0x8,%esp
  80230d:	68 48 23 80 00       	push   $0x802348
  802312:	6a 00                	push   $0x0
  802314:	e8 4a ea ff ff       	call   800d63 <sys_env_set_pgfault_upcall>
  802319:	83 c4 10             	add    $0x10,%esp
  80231c:	85 c0                	test   %eax,%eax
  80231e:	79 c8                	jns    8022e8 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802320:	83 ec 04             	sub    $0x4,%esp
  802323:	68 50 2d 80 00       	push   $0x802d50
  802328:	6a 2c                	push   $0x2c
  80232a:	68 86 2d 80 00       	push   $0x802d86
  80232f:	e8 1b de ff ff       	call   80014f <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802334:	83 ec 04             	sub    $0x4,%esp
  802337:	68 24 2d 80 00       	push   $0x802d24
  80233c:	6a 22                	push   $0x22
  80233e:	68 86 2d 80 00       	push   $0x802d86
  802343:	e8 07 de ff ff       	call   80014f <_panic>

00802348 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802348:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802349:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  80234e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802350:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802353:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802357:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  80235c:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802360:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802362:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802365:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802366:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802369:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  80236a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  80236b:	c3                   	ret    

0080236c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80236c:	f3 0f 1e fb          	endbr32 
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	56                   	push   %esi
  802374:	53                   	push   %ebx
  802375:	8b 75 08             	mov    0x8(%ebp),%esi
  802378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80237e:	85 c0                	test   %eax,%eax
  802380:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802385:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802388:	83 ec 0c             	sub    $0xc,%esp
  80238b:	50                   	push   %eax
  80238c:	e8 1e ea ff ff       	call   800daf <sys_ipc_recv>
  802391:	83 c4 10             	add    $0x10,%esp
  802394:	85 c0                	test   %eax,%eax
  802396:	75 2b                	jne    8023c3 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802398:	85 f6                	test   %esi,%esi
  80239a:	74 0a                	je     8023a6 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80239c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023a1:	8b 40 74             	mov    0x74(%eax),%eax
  8023a4:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8023a6:	85 db                	test   %ebx,%ebx
  8023a8:	74 0a                	je     8023b4 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8023aa:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023af:	8b 40 78             	mov    0x78(%eax),%eax
  8023b2:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8023b4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8023b9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023bf:	5b                   	pop    %ebx
  8023c0:	5e                   	pop    %esi
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8023c3:	85 f6                	test   %esi,%esi
  8023c5:	74 06                	je     8023cd <ipc_recv+0x61>
  8023c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8023cd:	85 db                	test   %ebx,%ebx
  8023cf:	74 eb                	je     8023bc <ipc_recv+0x50>
  8023d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023d7:	eb e3                	jmp    8023bc <ipc_recv+0x50>

008023d9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023d9:	f3 0f 1e fb          	endbr32 
  8023dd:	55                   	push   %ebp
  8023de:	89 e5                	mov    %esp,%ebp
  8023e0:	57                   	push   %edi
  8023e1:	56                   	push   %esi
  8023e2:	53                   	push   %ebx
  8023e3:	83 ec 0c             	sub    $0xc,%esp
  8023e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8023ef:	85 db                	test   %ebx,%ebx
  8023f1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023f6:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8023f9:	ff 75 14             	pushl  0x14(%ebp)
  8023fc:	53                   	push   %ebx
  8023fd:	56                   	push   %esi
  8023fe:	57                   	push   %edi
  8023ff:	e8 84 e9 ff ff       	call   800d88 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802404:	83 c4 10             	add    $0x10,%esp
  802407:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80240a:	75 07                	jne    802413 <ipc_send+0x3a>
			sys_yield();
  80240c:	e8 75 e8 ff ff       	call   800c86 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802411:	eb e6                	jmp    8023f9 <ipc_send+0x20>
		}
		else if (ret == 0)
  802413:	85 c0                	test   %eax,%eax
  802415:	75 08                	jne    80241f <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802417:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80241a:	5b                   	pop    %ebx
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  80241f:	50                   	push   %eax
  802420:	68 94 2d 80 00       	push   $0x802d94
  802425:	6a 48                	push   $0x48
  802427:	68 a2 2d 80 00       	push   $0x802da2
  80242c:	e8 1e dd ff ff       	call   80014f <_panic>

00802431 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802431:	f3 0f 1e fb          	endbr32 
  802435:	55                   	push   %ebp
  802436:	89 e5                	mov    %esp,%ebp
  802438:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80243b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802440:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802443:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802449:	8b 52 50             	mov    0x50(%edx),%edx
  80244c:	39 ca                	cmp    %ecx,%edx
  80244e:	74 11                	je     802461 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802450:	83 c0 01             	add    $0x1,%eax
  802453:	3d 00 04 00 00       	cmp    $0x400,%eax
  802458:	75 e6                	jne    802440 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80245a:	b8 00 00 00 00       	mov    $0x0,%eax
  80245f:	eb 0b                	jmp    80246c <ipc_find_env+0x3b>
			return envs[i].env_id;
  802461:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802464:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802469:	8b 40 48             	mov    0x48(%eax),%eax
}
  80246c:	5d                   	pop    %ebp
  80246d:	c3                   	ret    

0080246e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80246e:	f3 0f 1e fb          	endbr32 
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
  802475:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802478:	89 c2                	mov    %eax,%edx
  80247a:	c1 ea 16             	shr    $0x16,%edx
  80247d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802484:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802489:	f6 c1 01             	test   $0x1,%cl
  80248c:	74 1c                	je     8024aa <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80248e:	c1 e8 0c             	shr    $0xc,%eax
  802491:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802498:	a8 01                	test   $0x1,%al
  80249a:	74 0e                	je     8024aa <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80249c:	c1 e8 0c             	shr    $0xc,%eax
  80249f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024a6:	ef 
  8024a7:	0f b7 d2             	movzwl %dx,%edx
}
  8024aa:	89 d0                	mov    %edx,%eax
  8024ac:	5d                   	pop    %ebp
  8024ad:	c3                   	ret    
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__udivdi3>:
  8024b0:	f3 0f 1e fb          	endbr32 
  8024b4:	55                   	push   %ebp
  8024b5:	57                   	push   %edi
  8024b6:	56                   	push   %esi
  8024b7:	53                   	push   %ebx
  8024b8:	83 ec 1c             	sub    $0x1c,%esp
  8024bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024cb:	85 d2                	test   %edx,%edx
  8024cd:	75 19                	jne    8024e8 <__udivdi3+0x38>
  8024cf:	39 f3                	cmp    %esi,%ebx
  8024d1:	76 4d                	jbe    802520 <__udivdi3+0x70>
  8024d3:	31 ff                	xor    %edi,%edi
  8024d5:	89 e8                	mov    %ebp,%eax
  8024d7:	89 f2                	mov    %esi,%edx
  8024d9:	f7 f3                	div    %ebx
  8024db:	89 fa                	mov    %edi,%edx
  8024dd:	83 c4 1c             	add    $0x1c,%esp
  8024e0:	5b                   	pop    %ebx
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi
  8024e8:	39 f2                	cmp    %esi,%edx
  8024ea:	76 14                	jbe    802500 <__udivdi3+0x50>
  8024ec:	31 ff                	xor    %edi,%edi
  8024ee:	31 c0                	xor    %eax,%eax
  8024f0:	89 fa                	mov    %edi,%edx
  8024f2:	83 c4 1c             	add    $0x1c,%esp
  8024f5:	5b                   	pop    %ebx
  8024f6:	5e                   	pop    %esi
  8024f7:	5f                   	pop    %edi
  8024f8:	5d                   	pop    %ebp
  8024f9:	c3                   	ret    
  8024fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802500:	0f bd fa             	bsr    %edx,%edi
  802503:	83 f7 1f             	xor    $0x1f,%edi
  802506:	75 48                	jne    802550 <__udivdi3+0xa0>
  802508:	39 f2                	cmp    %esi,%edx
  80250a:	72 06                	jb     802512 <__udivdi3+0x62>
  80250c:	31 c0                	xor    %eax,%eax
  80250e:	39 eb                	cmp    %ebp,%ebx
  802510:	77 de                	ja     8024f0 <__udivdi3+0x40>
  802512:	b8 01 00 00 00       	mov    $0x1,%eax
  802517:	eb d7                	jmp    8024f0 <__udivdi3+0x40>
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d9                	mov    %ebx,%ecx
  802522:	85 db                	test   %ebx,%ebx
  802524:	75 0b                	jne    802531 <__udivdi3+0x81>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f3                	div    %ebx
  80252f:	89 c1                	mov    %eax,%ecx
  802531:	31 d2                	xor    %edx,%edx
  802533:	89 f0                	mov    %esi,%eax
  802535:	f7 f1                	div    %ecx
  802537:	89 c6                	mov    %eax,%esi
  802539:	89 e8                	mov    %ebp,%eax
  80253b:	89 f7                	mov    %esi,%edi
  80253d:	f7 f1                	div    %ecx
  80253f:	89 fa                	mov    %edi,%edx
  802541:	83 c4 1c             	add    $0x1c,%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5f                   	pop    %edi
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 f9                	mov    %edi,%ecx
  802552:	b8 20 00 00 00       	mov    $0x20,%eax
  802557:	29 f8                	sub    %edi,%eax
  802559:	d3 e2                	shl    %cl,%edx
  80255b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80255f:	89 c1                	mov    %eax,%ecx
  802561:	89 da                	mov    %ebx,%edx
  802563:	d3 ea                	shr    %cl,%edx
  802565:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802569:	09 d1                	or     %edx,%ecx
  80256b:	89 f2                	mov    %esi,%edx
  80256d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802571:	89 f9                	mov    %edi,%ecx
  802573:	d3 e3                	shl    %cl,%ebx
  802575:	89 c1                	mov    %eax,%ecx
  802577:	d3 ea                	shr    %cl,%edx
  802579:	89 f9                	mov    %edi,%ecx
  80257b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80257f:	89 eb                	mov    %ebp,%ebx
  802581:	d3 e6                	shl    %cl,%esi
  802583:	89 c1                	mov    %eax,%ecx
  802585:	d3 eb                	shr    %cl,%ebx
  802587:	09 de                	or     %ebx,%esi
  802589:	89 f0                	mov    %esi,%eax
  80258b:	f7 74 24 08          	divl   0x8(%esp)
  80258f:	89 d6                	mov    %edx,%esi
  802591:	89 c3                	mov    %eax,%ebx
  802593:	f7 64 24 0c          	mull   0xc(%esp)
  802597:	39 d6                	cmp    %edx,%esi
  802599:	72 15                	jb     8025b0 <__udivdi3+0x100>
  80259b:	89 f9                	mov    %edi,%ecx
  80259d:	d3 e5                	shl    %cl,%ebp
  80259f:	39 c5                	cmp    %eax,%ebp
  8025a1:	73 04                	jae    8025a7 <__udivdi3+0xf7>
  8025a3:	39 d6                	cmp    %edx,%esi
  8025a5:	74 09                	je     8025b0 <__udivdi3+0x100>
  8025a7:	89 d8                	mov    %ebx,%eax
  8025a9:	31 ff                	xor    %edi,%edi
  8025ab:	e9 40 ff ff ff       	jmp    8024f0 <__udivdi3+0x40>
  8025b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025b3:	31 ff                	xor    %edi,%edi
  8025b5:	e9 36 ff ff ff       	jmp    8024f0 <__udivdi3+0x40>
  8025ba:	66 90                	xchg   %ax,%ax
  8025bc:	66 90                	xchg   %ax,%ax
  8025be:	66 90                	xchg   %ax,%ax

008025c0 <__umoddi3>:
  8025c0:	f3 0f 1e fb          	endbr32 
  8025c4:	55                   	push   %ebp
  8025c5:	57                   	push   %edi
  8025c6:	56                   	push   %esi
  8025c7:	53                   	push   %ebx
  8025c8:	83 ec 1c             	sub    $0x1c,%esp
  8025cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025db:	85 c0                	test   %eax,%eax
  8025dd:	75 19                	jne    8025f8 <__umoddi3+0x38>
  8025df:	39 df                	cmp    %ebx,%edi
  8025e1:	76 5d                	jbe    802640 <__umoddi3+0x80>
  8025e3:	89 f0                	mov    %esi,%eax
  8025e5:	89 da                	mov    %ebx,%edx
  8025e7:	f7 f7                	div    %edi
  8025e9:	89 d0                	mov    %edx,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	83 c4 1c             	add    $0x1c,%esp
  8025f0:	5b                   	pop    %ebx
  8025f1:	5e                   	pop    %esi
  8025f2:	5f                   	pop    %edi
  8025f3:	5d                   	pop    %ebp
  8025f4:	c3                   	ret    
  8025f5:	8d 76 00             	lea    0x0(%esi),%esi
  8025f8:	89 f2                	mov    %esi,%edx
  8025fa:	39 d8                	cmp    %ebx,%eax
  8025fc:	76 12                	jbe    802610 <__umoddi3+0x50>
  8025fe:	89 f0                	mov    %esi,%eax
  802600:	89 da                	mov    %ebx,%edx
  802602:	83 c4 1c             	add    $0x1c,%esp
  802605:	5b                   	pop    %ebx
  802606:	5e                   	pop    %esi
  802607:	5f                   	pop    %edi
  802608:	5d                   	pop    %ebp
  802609:	c3                   	ret    
  80260a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802610:	0f bd e8             	bsr    %eax,%ebp
  802613:	83 f5 1f             	xor    $0x1f,%ebp
  802616:	75 50                	jne    802668 <__umoddi3+0xa8>
  802618:	39 d8                	cmp    %ebx,%eax
  80261a:	0f 82 e0 00 00 00    	jb     802700 <__umoddi3+0x140>
  802620:	89 d9                	mov    %ebx,%ecx
  802622:	39 f7                	cmp    %esi,%edi
  802624:	0f 86 d6 00 00 00    	jbe    802700 <__umoddi3+0x140>
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	89 ca                	mov    %ecx,%edx
  80262e:	83 c4 1c             	add    $0x1c,%esp
  802631:	5b                   	pop    %ebx
  802632:	5e                   	pop    %esi
  802633:	5f                   	pop    %edi
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    
  802636:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80263d:	8d 76 00             	lea    0x0(%esi),%esi
  802640:	89 fd                	mov    %edi,%ebp
  802642:	85 ff                	test   %edi,%edi
  802644:	75 0b                	jne    802651 <__umoddi3+0x91>
  802646:	b8 01 00 00 00       	mov    $0x1,%eax
  80264b:	31 d2                	xor    %edx,%edx
  80264d:	f7 f7                	div    %edi
  80264f:	89 c5                	mov    %eax,%ebp
  802651:	89 d8                	mov    %ebx,%eax
  802653:	31 d2                	xor    %edx,%edx
  802655:	f7 f5                	div    %ebp
  802657:	89 f0                	mov    %esi,%eax
  802659:	f7 f5                	div    %ebp
  80265b:	89 d0                	mov    %edx,%eax
  80265d:	31 d2                	xor    %edx,%edx
  80265f:	eb 8c                	jmp    8025ed <__umoddi3+0x2d>
  802661:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802668:	89 e9                	mov    %ebp,%ecx
  80266a:	ba 20 00 00 00       	mov    $0x20,%edx
  80266f:	29 ea                	sub    %ebp,%edx
  802671:	d3 e0                	shl    %cl,%eax
  802673:	89 44 24 08          	mov    %eax,0x8(%esp)
  802677:	89 d1                	mov    %edx,%ecx
  802679:	89 f8                	mov    %edi,%eax
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802681:	89 54 24 04          	mov    %edx,0x4(%esp)
  802685:	8b 54 24 04          	mov    0x4(%esp),%edx
  802689:	09 c1                	or     %eax,%ecx
  80268b:	89 d8                	mov    %ebx,%eax
  80268d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802691:	89 e9                	mov    %ebp,%ecx
  802693:	d3 e7                	shl    %cl,%edi
  802695:	89 d1                	mov    %edx,%ecx
  802697:	d3 e8                	shr    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80269f:	d3 e3                	shl    %cl,%ebx
  8026a1:	89 c7                	mov    %eax,%edi
  8026a3:	89 d1                	mov    %edx,%ecx
  8026a5:	89 f0                	mov    %esi,%eax
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	89 fa                	mov    %edi,%edx
  8026ad:	d3 e6                	shl    %cl,%esi
  8026af:	09 d8                	or     %ebx,%eax
  8026b1:	f7 74 24 08          	divl   0x8(%esp)
  8026b5:	89 d1                	mov    %edx,%ecx
  8026b7:	89 f3                	mov    %esi,%ebx
  8026b9:	f7 64 24 0c          	mull   0xc(%esp)
  8026bd:	89 c6                	mov    %eax,%esi
  8026bf:	89 d7                	mov    %edx,%edi
  8026c1:	39 d1                	cmp    %edx,%ecx
  8026c3:	72 06                	jb     8026cb <__umoddi3+0x10b>
  8026c5:	75 10                	jne    8026d7 <__umoddi3+0x117>
  8026c7:	39 c3                	cmp    %eax,%ebx
  8026c9:	73 0c                	jae    8026d7 <__umoddi3+0x117>
  8026cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8026cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026d3:	89 d7                	mov    %edx,%edi
  8026d5:	89 c6                	mov    %eax,%esi
  8026d7:	89 ca                	mov    %ecx,%edx
  8026d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026de:	29 f3                	sub    %esi,%ebx
  8026e0:	19 fa                	sbb    %edi,%edx
  8026e2:	89 d0                	mov    %edx,%eax
  8026e4:	d3 e0                	shl    %cl,%eax
  8026e6:	89 e9                	mov    %ebp,%ecx
  8026e8:	d3 eb                	shr    %cl,%ebx
  8026ea:	d3 ea                	shr    %cl,%edx
  8026ec:	09 d8                	or     %ebx,%eax
  8026ee:	83 c4 1c             	add    $0x1c,%esp
  8026f1:	5b                   	pop    %ebx
  8026f2:	5e                   	pop    %esi
  8026f3:	5f                   	pop    %edi
  8026f4:	5d                   	pop    %ebp
  8026f5:	c3                   	ret    
  8026f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026fd:	8d 76 00             	lea    0x0(%esi),%esi
  802700:	29 fe                	sub    %edi,%esi
  802702:	19 c3                	sbb    %eax,%ebx
  802704:	89 f2                	mov    %esi,%edx
  802706:	89 d9                	mov    %ebx,%ecx
  802708:	e9 1d ff ff ff       	jmp    80262a <__umoddi3+0x6a>
