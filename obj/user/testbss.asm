
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003d:	68 00 24 80 00       	push   $0x802400
  800042:	e8 e8 01 00 00       	call   80022f <cprintf>
  800047:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  80004a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004f:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800056:	00 
  800057:	75 63                	jne    8000bc <umain+0x89>
	for (i = 0; i < ARRAYSIZE; i++)
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800061:	75 ec                	jne    80004f <umain+0x1c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800068:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	83 c0 01             	add    $0x1,%eax
  800072:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800077:	75 ef                	jne    800068 <umain+0x35>
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007e:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  800085:	75 47                	jne    8000ce <umain+0x9b>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	83 c0 01             	add    $0x1,%eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 ed                	jne    80007e <umain+0x4b>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800091:	83 ec 0c             	sub    $0xc,%esp
  800094:	68 48 24 80 00       	push   $0x802448
  800099:	e8 91 01 00 00       	call   80022f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009e:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000a5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 a7 24 80 00       	push   $0x8024a7
  8000b0:	6a 1a                	push   $0x1a
  8000b2:	68 98 24 80 00       	push   $0x802498
  8000b7:	e8 8c 00 00 00       	call   800148 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000bc:	50                   	push   %eax
  8000bd:	68 7b 24 80 00       	push   $0x80247b
  8000c2:	6a 11                	push   $0x11
  8000c4:	68 98 24 80 00       	push   $0x802498
  8000c9:	e8 7a 00 00 00       	call   800148 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ce:	50                   	push   %eax
  8000cf:	68 20 24 80 00       	push   $0x802420
  8000d4:	6a 16                	push   $0x16
  8000d6:	68 98 24 80 00       	push   $0x802498
  8000db:	e8 68 00 00 00       	call   800148 <_panic>

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	f3 0f 1e fb          	endbr32 
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ef:	e8 68 0b 00 00       	call   800c5c <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800106:	85 db                	test   %ebx,%ebx
  800108:	7e 07                	jle    800111 <libmain+0x31>
		binaryname = argv[0];
  80010a:	8b 06                	mov    (%esi),%eax
  80010c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	e8 18 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011b:	e8 0a 00 00 00       	call   80012a <exit>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012a:	f3 0f 1e fb          	endbr32 
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800134:	e8 f4 0e 00 00       	call   80102d <close_all>
	sys_env_destroy(0);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	e8 f5 0a 00 00       	call   800c38 <sys_env_destroy>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	f3 0f 1e fb          	endbr32 
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800151:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800154:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015a:	e8 fd 0a 00 00       	call   800c5c <sys_getenvid>
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	56                   	push   %esi
  800169:	50                   	push   %eax
  80016a:	68 c8 24 80 00       	push   $0x8024c8
  80016f:	e8 bb 00 00 00       	call   80022f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	83 c4 18             	add    $0x18,%esp
  800177:	53                   	push   %ebx
  800178:	ff 75 10             	pushl  0x10(%ebp)
  80017b:	e8 5a 00 00 00       	call   8001da <vcprintf>
	cprintf("\n");
  800180:	c7 04 24 96 24 80 00 	movl   $0x802496,(%esp)
  800187:	e8 a3 00 00 00       	call   80022f <cprintf>
  80018c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x47>

00800192 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800192:	f3 0f 1e fb          	endbr32 
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	74 09                	je     8001be <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	68 ff 00 00 00       	push   $0xff
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 24 0a 00 00       	call   800bf3 <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb db                	jmp    8001b5 <putch+0x23>

008001da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001da:	f3 0f 1e fb          	endbr32 
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ee:	00 00 00 
	b.cnt = 0;
  8001f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	68 92 01 80 00       	push   $0x800192
  80020d:	e8 20 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800212:	83 c4 08             	add    $0x8,%esp
  800215:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800221:	50                   	push   %eax
  800222:	e8 cc 09 00 00       	call   800bf3 <sys_cputs>

	return b.cnt;
}
  800227:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022f:	f3 0f 1e fb          	endbr32 
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800239:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	e8 95 ff ff ff       	call   8001da <vcprintf>
	va_end(ap);

	return cnt;
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 1c             	sub    $0x1c,%esp
  800250:	89 c7                	mov    %eax,%edi
  800252:	89 d6                	mov    %edx,%esi
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025a:	89 d1                	mov    %edx,%ecx
  80025c:	89 c2                	mov    %eax,%edx
  80025e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800261:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800264:	8b 45 10             	mov    0x10(%ebp),%eax
  800267:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80026a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800274:	39 c2                	cmp    %eax,%edx
  800276:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800279:	72 3e                	jb     8002b9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027b:	83 ec 0c             	sub    $0xc,%esp
  80027e:	ff 75 18             	pushl  0x18(%ebp)
  800281:	83 eb 01             	sub    $0x1,%ebx
  800284:	53                   	push   %ebx
  800285:	50                   	push   %eax
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028c:	ff 75 e0             	pushl  -0x20(%ebp)
  80028f:	ff 75 dc             	pushl  -0x24(%ebp)
  800292:	ff 75 d8             	pushl  -0x28(%ebp)
  800295:	e8 f6 1e 00 00       	call   802190 <__udivdi3>
  80029a:	83 c4 18             	add    $0x18,%esp
  80029d:	52                   	push   %edx
  80029e:	50                   	push   %eax
  80029f:	89 f2                	mov    %esi,%edx
  8002a1:	89 f8                	mov    %edi,%eax
  8002a3:	e8 9f ff ff ff       	call   800247 <printnum>
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	eb 13                	jmp    8002c0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	ff 75 18             	pushl  0x18(%ebp)
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b9:	83 eb 01             	sub    $0x1,%ebx
  8002bc:	85 db                	test   %ebx,%ebx
  8002be:	7f ed                	jg     8002ad <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	56                   	push   %esi
  8002c4:	83 ec 04             	sub    $0x4,%esp
  8002c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d3:	e8 c8 1f 00 00       	call   8022a0 <__umoddi3>
  8002d8:	83 c4 14             	add    $0x14,%esp
  8002db:	0f be 80 eb 24 80 00 	movsbl 0x8024eb(%eax),%eax
  8002e2:	50                   	push   %eax
  8002e3:	ff d7                	call   *%edi
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1f>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
{
  800311:	f3 0f 1e fb          	endbr32 
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
{
  800332:	f3 0f 1e fb          	endbr32 
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
  80033c:	83 ec 3c             	sub    $0x3c,%esp
  80033f:	8b 75 08             	mov    0x8(%ebp),%esi
  800342:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800345:	8b 7d 10             	mov    0x10(%ebp),%edi
  800348:	e9 8e 03 00 00       	jmp    8006db <vprintfmt+0x3a9>
		padc = ' ';
  80034d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800351:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800358:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800366:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8d 47 01             	lea    0x1(%edi),%eax
  80036e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800371:	0f b6 17             	movzbl (%edi),%edx
  800374:	8d 42 dd             	lea    -0x23(%edx),%eax
  800377:	3c 55                	cmp    $0x55,%al
  800379:	0f 87 df 03 00 00    	ja     80075e <vprintfmt+0x42c>
  80037f:	0f b6 c0             	movzbl %al,%eax
  800382:	3e ff 24 85 20 26 80 	notrack jmp *0x802620(,%eax,4)
  800389:	00 
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80038d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800391:	eb d8                	jmp    80036b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80039a:	eb cf                	jmp    80036b <vprintfmt+0x39>
  80039c:	0f b6 d2             	movzbl %dl,%edx
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003aa:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ad:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b7:	83 f9 09             	cmp    $0x9,%ecx
  8003ba:	77 55                	ja     800411 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003bc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003bf:	eb e9                	jmp    8003aa <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8b 00                	mov    (%eax),%eax
  8003c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 40 04             	lea    0x4(%eax),%eax
  8003cf:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d9:	79 90                	jns    80036b <vprintfmt+0x39>
				width = precision, precision = -1;
  8003db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e8:	eb 81                	jmp    80036b <vprintfmt+0x39>
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	0f 49 d0             	cmovns %eax,%edx
  8003f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003fd:	e9 69 ff ff ff       	jmp    80036b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800405:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80040c:	e9 5a ff ff ff       	jmp    80036b <vprintfmt+0x39>
  800411:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800414:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800417:	eb bc                	jmp    8003d5 <vprintfmt+0xa3>
			lflag++;
  800419:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041f:	e9 47 ff ff ff       	jmp    80036b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 78 04             	lea    0x4(%eax),%edi
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	53                   	push   %ebx
  80042e:	ff 30                	pushl  (%eax)
  800430:	ff d6                	call   *%esi
			break;
  800432:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800435:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800438:	e9 9b 02 00 00       	jmp    8006d8 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 78 04             	lea    0x4(%eax),%edi
  800443:	8b 00                	mov    (%eax),%eax
  800445:	99                   	cltd   
  800446:	31 d0                	xor    %edx,%eax
  800448:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044a:	83 f8 0f             	cmp    $0xf,%eax
  80044d:	7f 23                	jg     800472 <vprintfmt+0x140>
  80044f:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800456:	85 d2                	test   %edx,%edx
  800458:	74 18                	je     800472 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80045a:	52                   	push   %edx
  80045b:	68 89 28 80 00       	push   $0x802889
  800460:	53                   	push   %ebx
  800461:	56                   	push   %esi
  800462:	e8 aa fe ff ff       	call   800311 <printfmt>
  800467:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80046d:	e9 66 02 00 00       	jmp    8006d8 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800472:	50                   	push   %eax
  800473:	68 03 25 80 00       	push   $0x802503
  800478:	53                   	push   %ebx
  800479:	56                   	push   %esi
  80047a:	e8 92 fe ff ff       	call   800311 <printfmt>
  80047f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800482:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800485:	e9 4e 02 00 00       	jmp    8006d8 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	83 c0 04             	add    $0x4,%eax
  800490:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800498:	85 d2                	test   %edx,%edx
  80049a:	b8 fc 24 80 00       	mov    $0x8024fc,%eax
  80049f:	0f 45 c2             	cmovne %edx,%eax
  8004a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a9:	7e 06                	jle    8004b1 <vprintfmt+0x17f>
  8004ab:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004af:	75 0d                	jne    8004be <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b4:	89 c7                	mov    %eax,%edi
  8004b6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bc:	eb 55                	jmp    800513 <vprintfmt+0x1e1>
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c4:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c7:	e8 46 03 00 00       	call   800812 <strnlen>
  8004cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004cf:	29 c2                	sub    %eax,%edx
  8004d1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004d9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e0:	85 ff                	test   %edi,%edi
  8004e2:	7e 11                	jle    8004f5 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	53                   	push   %ebx
  8004e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004eb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb eb                	jmp    8004e0 <vprintfmt+0x1ae>
  8004f5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f8:	85 d2                	test   %edx,%edx
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ff:	0f 49 c2             	cmovns %edx,%eax
  800502:	29 c2                	sub    %eax,%edx
  800504:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800507:	eb a8                	jmp    8004b1 <vprintfmt+0x17f>
					putch(ch, putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	53                   	push   %ebx
  80050d:	52                   	push   %edx
  80050e:	ff d6                	call   *%esi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800516:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800518:	83 c7 01             	add    $0x1,%edi
  80051b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051f:	0f be d0             	movsbl %al,%edx
  800522:	85 d2                	test   %edx,%edx
  800524:	74 4b                	je     800571 <vprintfmt+0x23f>
  800526:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052a:	78 06                	js     800532 <vprintfmt+0x200>
  80052c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800530:	78 1e                	js     800550 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800532:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800536:	74 d1                	je     800509 <vprintfmt+0x1d7>
  800538:	0f be c0             	movsbl %al,%eax
  80053b:	83 e8 20             	sub    $0x20,%eax
  80053e:	83 f8 5e             	cmp    $0x5e,%eax
  800541:	76 c6                	jbe    800509 <vprintfmt+0x1d7>
					putch('?', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	53                   	push   %ebx
  800547:	6a 3f                	push   $0x3f
  800549:	ff d6                	call   *%esi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	eb c3                	jmp    800513 <vprintfmt+0x1e1>
  800550:	89 cf                	mov    %ecx,%edi
  800552:	eb 0e                	jmp    800562 <vprintfmt+0x230>
				putch(' ', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	6a 20                	push   $0x20
  80055a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80055c:	83 ef 01             	sub    $0x1,%edi
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	85 ff                	test   %edi,%edi
  800564:	7f ee                	jg     800554 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800566:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	e9 67 01 00 00       	jmp    8006d8 <vprintfmt+0x3a6>
  800571:	89 cf                	mov    %ecx,%edi
  800573:	eb ed                	jmp    800562 <vprintfmt+0x230>
	if (lflag >= 2)
  800575:	83 f9 01             	cmp    $0x1,%ecx
  800578:	7f 1b                	jg     800595 <vprintfmt+0x263>
	else if (lflag)
  80057a:	85 c9                	test   %ecx,%ecx
  80057c:	74 63                	je     8005e1 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 00                	mov    (%eax),%eax
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	99                   	cltd   
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 40 04             	lea    0x4(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
  800593:	eb 17                	jmp    8005ac <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 50 04             	mov    0x4(%eax),%edx
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 40 08             	lea    0x8(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005b7:	85 c9                	test   %ecx,%ecx
  8005b9:	0f 89 ff 00 00 00    	jns    8006be <vprintfmt+0x38c>
				putch('-', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	6a 2d                	push   $0x2d
  8005c5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005cd:	f7 da                	neg    %edx
  8005cf:	83 d1 00             	adc    $0x0,%ecx
  8005d2:	f7 d9                	neg    %ecx
  8005d4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dc:	e9 dd 00 00 00       	jmp    8006be <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	99                   	cltd   
  8005ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f6:	eb b4                	jmp    8005ac <vprintfmt+0x27a>
	if (lflag >= 2)
  8005f8:	83 f9 01             	cmp    $0x1,%ecx
  8005fb:	7f 1e                	jg     80061b <vprintfmt+0x2e9>
	else if (lflag)
  8005fd:	85 c9                	test   %ecx,%ecx
  8005ff:	74 32                	je     800633 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 10                	mov    (%eax),%edx
  800606:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060b:	8d 40 04             	lea    0x4(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800616:	e9 a3 00 00 00       	jmp    8006be <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	8b 48 04             	mov    0x4(%eax),%ecx
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80062e:	e9 8b 00 00 00       	jmp    8006be <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800643:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800648:	eb 74                	jmp    8006be <vprintfmt+0x38c>
	if (lflag >= 2)
  80064a:	83 f9 01             	cmp    $0x1,%ecx
  80064d:	7f 1b                	jg     80066a <vprintfmt+0x338>
	else if (lflag)
  80064f:	85 c9                	test   %ecx,%ecx
  800651:	74 2c                	je     80067f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800663:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800668:	eb 54                	jmp    8006be <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	8b 48 04             	mov    0x4(%eax),%ecx
  800672:	8d 40 08             	lea    0x8(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800678:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80067d:	eb 3f                	jmp    8006be <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800694:	eb 28                	jmp    8006be <vprintfmt+0x38c>
			putch('0', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 30                	push   $0x30
  80069c:	ff d6                	call   *%esi
			putch('x', putdat);
  80069e:	83 c4 08             	add    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 78                	push   $0x78
  8006a4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b3:	8d 40 04             	lea    0x4(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	50                   	push   %eax
  8006ca:	51                   	push   %ecx
  8006cb:	52                   	push   %edx
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 72 fb ff ff       	call   800247 <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006db:	83 c7 01             	add    $0x1,%edi
  8006de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e2:	83 f8 25             	cmp    $0x25,%eax
  8006e5:	0f 84 62 fc ff ff    	je     80034d <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	0f 84 8b 00 00 00    	je     80077e <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	50                   	push   %eax
  8006f8:	ff d6                	call   *%esi
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb dc                	jmp    8006db <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7f 1b                	jg     80071f <vprintfmt+0x3ed>
	else if (lflag)
  800704:	85 c9                	test   %ecx,%ecx
  800706:	74 2c                	je     800734 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800718:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80071d:	eb 9f                	jmp    8006be <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	8b 48 04             	mov    0x4(%eax),%ecx
  800727:	8d 40 08             	lea    0x8(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800732:	eb 8a                	jmp    8006be <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800744:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800749:	e9 70 ff ff ff       	jmp    8006be <vprintfmt+0x38c>
			putch(ch, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 25                	push   $0x25
  800754:	ff d6                	call   *%esi
			break;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	e9 7a ff ff ff       	jmp    8006d8 <vprintfmt+0x3a6>
			putch('%', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	89 f8                	mov    %edi,%eax
  80076b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076f:	74 05                	je     800776 <vprintfmt+0x444>
  800771:	83 e8 01             	sub    $0x1,%eax
  800774:	eb f5                	jmp    80076b <vprintfmt+0x439>
  800776:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800779:	e9 5a ff ff ff       	jmp    8006d8 <vprintfmt+0x3a6>
}
  80077e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5f                   	pop    %edi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800786:	f3 0f 1e fb          	endbr32 
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 18             	sub    $0x18,%esp
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800796:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800799:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	74 26                	je     8007d1 <vsnprintf+0x4b>
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	7e 22                	jle    8007d1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007af:	ff 75 14             	pushl  0x14(%ebp)
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b8:	50                   	push   %eax
  8007b9:	68 f0 02 80 00       	push   $0x8002f0
  8007be:	e8 6f fb ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cc:	83 c4 10             	add    $0x10,%esp
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    
		return -E_INVAL;
  8007d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d6:	eb f7                	jmp    8007cf <vsnprintf+0x49>

008007d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d8:	f3 0f 1e fb          	endbr32 
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 10             	pushl  0x10(%ebp)
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	ff 75 08             	pushl  0x8(%ebp)
  8007ef:	e8 92 ff ff ff       	call   800786 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f6:	f3 0f 1e fb          	endbr32 
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
  800805:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800809:	74 05                	je     800810 <strlen+0x1a>
		n++;
  80080b:	83 c0 01             	add    $0x1,%eax
  80080e:	eb f5                	jmp    800805 <strlen+0xf>
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	f3 0f 1e fb          	endbr32 
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	39 d0                	cmp    %edx,%eax
  800826:	74 0d                	je     800835 <strnlen+0x23>
  800828:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082c:	74 05                	je     800833 <strnlen+0x21>
		n++;
  80082e:	83 c0 01             	add    $0x1,%eax
  800831:	eb f1                	jmp    800824 <strnlen+0x12>
  800833:	89 c2                	mov    %eax,%edx
	return n;
}
  800835:	89 d0                	mov    %edx,%eax
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800839:	f3 0f 1e fb          	endbr32 
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	53                   	push   %ebx
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800844:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800850:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800853:	83 c0 01             	add    $0x1,%eax
  800856:	84 d2                	test   %dl,%dl
  800858:	75 f2                	jne    80084c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80085a:	89 c8                	mov    %ecx,%eax
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085f:	f3 0f 1e fb          	endbr32 
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	83 ec 10             	sub    $0x10,%esp
  80086a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086d:	53                   	push   %ebx
  80086e:	e8 83 ff ff ff       	call   8007f6 <strlen>
  800873:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800876:	ff 75 0c             	pushl  0xc(%ebp)
  800879:	01 d8                	add    %ebx,%eax
  80087b:	50                   	push   %eax
  80087c:	e8 b8 ff ff ff       	call   800839 <strcpy>
	return dst;
}
  800881:	89 d8                	mov    %ebx,%eax
  800883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800888:	f3 0f 1e fb          	endbr32 
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	89 f3                	mov    %esi,%ebx
  800899:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	39 d8                	cmp    %ebx,%eax
  8008a0:	74 11                	je     8008b3 <strncpy+0x2b>
		*dst++ = *src;
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	0f b6 0a             	movzbl (%edx),%ecx
  8008a8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ab:	80 f9 01             	cmp    $0x1,%cl
  8008ae:	83 da ff             	sbb    $0xffffffff,%edx
  8008b1:	eb eb                	jmp    80089e <strncpy+0x16>
	}
	return ret;
}
  8008b3:	89 f0                	mov    %esi,%eax
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b9:	f3 0f 1e fb          	endbr32 
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c8:	8b 55 10             	mov    0x10(%ebp),%edx
  8008cb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	74 21                	je     8008f2 <strlcpy+0x39>
  8008d1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008d7:	39 c2                	cmp    %eax,%edx
  8008d9:	74 14                	je     8008ef <strlcpy+0x36>
  8008db:	0f b6 19             	movzbl (%ecx),%ebx
  8008de:	84 db                	test   %bl,%bl
  8008e0:	74 0b                	je     8008ed <strlcpy+0x34>
			*dst++ = *src++;
  8008e2:	83 c1 01             	add    $0x1,%ecx
  8008e5:	83 c2 01             	add    $0x1,%edx
  8008e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008eb:	eb ea                	jmp    8008d7 <strlcpy+0x1e>
  8008ed:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f2:	29 f0                	sub    %esi,%eax
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f8:	f3 0f 1e fb          	endbr32 
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800905:	0f b6 01             	movzbl (%ecx),%eax
  800908:	84 c0                	test   %al,%al
  80090a:	74 0c                	je     800918 <strcmp+0x20>
  80090c:	3a 02                	cmp    (%edx),%al
  80090e:	75 08                	jne    800918 <strcmp+0x20>
		p++, q++;
  800910:	83 c1 01             	add    $0x1,%ecx
  800913:	83 c2 01             	add    $0x1,%edx
  800916:	eb ed                	jmp    800905 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800918:	0f b6 c0             	movzbl %al,%eax
  80091b:	0f b6 12             	movzbl (%edx),%edx
  80091e:	29 d0                	sub    %edx,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800922:	f3 0f 1e fb          	endbr32 
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 c3                	mov    %eax,%ebx
  800932:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800935:	eb 06                	jmp    80093d <strncmp+0x1b>
		n--, p++, q++;
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80093d:	39 d8                	cmp    %ebx,%eax
  80093f:	74 16                	je     800957 <strncmp+0x35>
  800941:	0f b6 08             	movzbl (%eax),%ecx
  800944:	84 c9                	test   %cl,%cl
  800946:	74 04                	je     80094c <strncmp+0x2a>
  800948:	3a 0a                	cmp    (%edx),%cl
  80094a:	74 eb                	je     800937 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094c:	0f b6 00             	movzbl (%eax),%eax
  80094f:	0f b6 12             	movzbl (%edx),%edx
  800952:	29 d0                	sub    %edx,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    
		return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
  80095c:	eb f6                	jmp    800954 <strncmp+0x32>

0080095e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095e:	f3 0f 1e fb          	endbr32 
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096c:	0f b6 10             	movzbl (%eax),%edx
  80096f:	84 d2                	test   %dl,%dl
  800971:	74 09                	je     80097c <strchr+0x1e>
		if (*s == c)
  800973:	38 ca                	cmp    %cl,%dl
  800975:	74 0a                	je     800981 <strchr+0x23>
	for (; *s; s++)
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	eb f0                	jmp    80096c <strchr+0xe>
			return (char *) s;
	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800983:	f3 0f 1e fb          	endbr32 
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80098d:	6a 78                	push   $0x78
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 c7 ff ff ff       	call   80095e <strchr>
  800997:	83 c4 10             	add    $0x10,%esp
  80099a:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8009a2:	eb 0d                	jmp    8009b1 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8009a4:	c1 e0 04             	shl    $0x4,%eax
  8009a7:	0f be d2             	movsbl %dl,%edx
  8009aa:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8009ae:	83 c1 01             	add    $0x1,%ecx
  8009b1:	0f b6 11             	movzbl (%ecx),%edx
  8009b4:	84 d2                	test   %dl,%dl
  8009b6:	74 11                	je     8009c9 <atox+0x46>
		if (*p>='a'){
  8009b8:	80 fa 60             	cmp    $0x60,%dl
  8009bb:	7e e7                	jle    8009a4 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8009bd:	c1 e0 04             	shl    $0x4,%eax
  8009c0:	0f be d2             	movsbl %dl,%edx
  8009c3:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009c7:	eb e5                	jmp    8009ae <atox+0x2b>
	}

	return v;

}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	f3 0f 1e fb          	endbr32 
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	74 09                	je     8009e9 <strfind+0x1e>
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	74 05                	je     8009e9 <strfind+0x1e>
	for (; *s; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	eb f0                	jmp    8009d9 <strfind+0xe>
			break;
	return (char *) s;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009eb:	f3 0f 1e fb          	endbr32 
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009fb:	85 c9                	test   %ecx,%ecx
  8009fd:	74 31                	je     800a30 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ff:	89 f8                	mov    %edi,%eax
  800a01:	09 c8                	or     %ecx,%eax
  800a03:	a8 03                	test   $0x3,%al
  800a05:	75 23                	jne    800a2a <memset+0x3f>
		c &= 0xFF;
  800a07:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a0b:	89 d3                	mov    %edx,%ebx
  800a0d:	c1 e3 08             	shl    $0x8,%ebx
  800a10:	89 d0                	mov    %edx,%eax
  800a12:	c1 e0 18             	shl    $0x18,%eax
  800a15:	89 d6                	mov    %edx,%esi
  800a17:	c1 e6 10             	shl    $0x10,%esi
  800a1a:	09 f0                	or     %esi,%eax
  800a1c:	09 c2                	or     %eax,%edx
  800a1e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a20:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a23:	89 d0                	mov    %edx,%eax
  800a25:	fc                   	cld    
  800a26:	f3 ab                	rep stos %eax,%es:(%edi)
  800a28:	eb 06                	jmp    800a30 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2d:	fc                   	cld    
  800a2e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a30:	89 f8                	mov    %edi,%eax
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a37:	f3 0f 1e fb          	endbr32 
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a49:	39 c6                	cmp    %eax,%esi
  800a4b:	73 32                	jae    800a7f <memmove+0x48>
  800a4d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a50:	39 c2                	cmp    %eax,%edx
  800a52:	76 2b                	jbe    800a7f <memmove+0x48>
		s += n;
		d += n;
  800a54:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a57:	89 fe                	mov    %edi,%esi
  800a59:	09 ce                	or     %ecx,%esi
  800a5b:	09 d6                	or     %edx,%esi
  800a5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a63:	75 0e                	jne    800a73 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a65:	83 ef 04             	sub    $0x4,%edi
  800a68:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a6e:	fd                   	std    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a71:	eb 09                	jmp    800a7c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a73:	83 ef 01             	sub    $0x1,%edi
  800a76:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a79:	fd                   	std    
  800a7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7c:	fc                   	cld    
  800a7d:	eb 1a                	jmp    800a99 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	09 ca                	or     %ecx,%edx
  800a83:	09 f2                	or     %esi,%edx
  800a85:	f6 c2 03             	test   $0x3,%dl
  800a88:	75 0a                	jne    800a94 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a8d:	89 c7                	mov    %eax,%edi
  800a8f:	fc                   	cld    
  800a90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a92:	eb 05                	jmp    800a99 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	fc                   	cld    
  800a97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9d:	f3 0f 1e fb          	endbr32 
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa7:	ff 75 10             	pushl  0x10(%ebp)
  800aaa:	ff 75 0c             	pushl  0xc(%ebp)
  800aad:	ff 75 08             	pushl  0x8(%ebp)
  800ab0:	e8 82 ff ff ff       	call   800a37 <memmove>
}
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab7:	f3 0f 1e fb          	endbr32 
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac6:	89 c6                	mov    %eax,%esi
  800ac8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acb:	39 f0                	cmp    %esi,%eax
  800acd:	74 1c                	je     800aeb <memcmp+0x34>
		if (*s1 != *s2)
  800acf:	0f b6 08             	movzbl (%eax),%ecx
  800ad2:	0f b6 1a             	movzbl (%edx),%ebx
  800ad5:	38 d9                	cmp    %bl,%cl
  800ad7:	75 08                	jne    800ae1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad9:	83 c0 01             	add    $0x1,%eax
  800adc:	83 c2 01             	add    $0x1,%edx
  800adf:	eb ea                	jmp    800acb <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ae1:	0f b6 c1             	movzbl %cl,%eax
  800ae4:	0f b6 db             	movzbl %bl,%ebx
  800ae7:	29 d8                	sub    %ebx,%eax
  800ae9:	eb 05                	jmp    800af0 <memcmp+0x39>
	}

	return 0;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af4:	f3 0f 1e fb          	endbr32 
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b06:	39 d0                	cmp    %edx,%eax
  800b08:	73 09                	jae    800b13 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0a:	38 08                	cmp    %cl,(%eax)
  800b0c:	74 05                	je     800b13 <memfind+0x1f>
	for (; s < ends; s++)
  800b0e:	83 c0 01             	add    $0x1,%eax
  800b11:	eb f3                	jmp    800b06 <memfind+0x12>
			break;
	return (void *) s;
}
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b15:	f3 0f 1e fb          	endbr32 
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b25:	eb 03                	jmp    800b2a <strtol+0x15>
		s++;
  800b27:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b2a:	0f b6 01             	movzbl (%ecx),%eax
  800b2d:	3c 20                	cmp    $0x20,%al
  800b2f:	74 f6                	je     800b27 <strtol+0x12>
  800b31:	3c 09                	cmp    $0x9,%al
  800b33:	74 f2                	je     800b27 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b35:	3c 2b                	cmp    $0x2b,%al
  800b37:	74 2a                	je     800b63 <strtol+0x4e>
	int neg = 0;
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b3e:	3c 2d                	cmp    $0x2d,%al
  800b40:	74 2b                	je     800b6d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b48:	75 0f                	jne    800b59 <strtol+0x44>
  800b4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b4d:	74 28                	je     800b77 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4f:	85 db                	test   %ebx,%ebx
  800b51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b56:	0f 44 d8             	cmove  %eax,%ebx
  800b59:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b61:	eb 46                	jmp    800ba9 <strtol+0x94>
		s++;
  800b63:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b66:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6b:	eb d5                	jmp    800b42 <strtol+0x2d>
		s++, neg = 1;
  800b6d:	83 c1 01             	add    $0x1,%ecx
  800b70:	bf 01 00 00 00       	mov    $0x1,%edi
  800b75:	eb cb                	jmp    800b42 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b77:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b7b:	74 0e                	je     800b8b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	75 d8                	jne    800b59 <strtol+0x44>
		s++, base = 8;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b89:	eb ce                	jmp    800b59 <strtol+0x44>
		s += 2, base = 16;
  800b8b:	83 c1 02             	add    $0x2,%ecx
  800b8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b93:	eb c4                	jmp    800b59 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b95:	0f be d2             	movsbl %dl,%edx
  800b98:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b9e:	7d 3a                	jge    800bda <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba0:	83 c1 01             	add    $0x1,%ecx
  800ba3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ba9:	0f b6 11             	movzbl (%ecx),%edx
  800bac:	8d 72 d0             	lea    -0x30(%edx),%esi
  800baf:	89 f3                	mov    %esi,%ebx
  800bb1:	80 fb 09             	cmp    $0x9,%bl
  800bb4:	76 df                	jbe    800b95 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bb6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb9:	89 f3                	mov    %esi,%ebx
  800bbb:	80 fb 19             	cmp    $0x19,%bl
  800bbe:	77 08                	ja     800bc8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc0:	0f be d2             	movsbl %dl,%edx
  800bc3:	83 ea 57             	sub    $0x57,%edx
  800bc6:	eb d3                	jmp    800b9b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bc8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 08                	ja     800bda <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bd2:	0f be d2             	movsbl %dl,%edx
  800bd5:	83 ea 37             	sub    $0x37,%edx
  800bd8:	eb c1                	jmp    800b9b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bde:	74 05                	je     800be5 <strtol+0xd0>
		*endptr = (char *) s;
  800be0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	f7 da                	neg    %edx
  800be9:	85 ff                	test   %edi,%edi
  800beb:	0f 45 c2             	cmovne %edx,%eax
}
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	89 c3                	mov    %eax,%ebx
  800c0a:	89 c7                	mov    %eax,%edi
  800c0c:	89 c6                	mov    %eax,%esi
  800c0e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c15:	f3 0f 1e fb          	endbr32 
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 01 00 00 00       	mov    $0x1,%eax
  800c29:	89 d1                	mov    %edx,%ecx
  800c2b:	89 d3                	mov    %edx,%ebx
  800c2d:	89 d7                	mov    %edx,%edi
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c38:	f3 0f 1e fb          	endbr32 
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5c:	f3 0f 1e fb          	endbr32 
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c70:	89 d1                	mov    %edx,%ecx
  800c72:	89 d3                	mov    %edx,%ebx
  800c74:	89 d7                	mov    %edx,%edi
  800c76:	89 d6                	mov    %edx,%esi
  800c78:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_yield>:

void
sys_yield(void)
{
  800c7f:	f3 0f 1e fb          	endbr32 
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c93:	89 d1                	mov    %edx,%ecx
  800c95:	89 d3                	mov    %edx,%ebx
  800c97:	89 d7                	mov    %edx,%edi
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cac:	be 00 00 00 00       	mov    $0x0,%esi
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbf:	89 f7                	mov    %esi,%edi
  800cc1:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc8:	f3 0f 1e fb          	endbr32 
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce6:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ced:	f3 0f 1e fb          	endbr32 
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	b8 06 00 00 00       	mov    $0x6,%eax
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d12:	f3 0f 1e fb          	endbr32 
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d51:	89 df                	mov    %ebx,%edi
  800d53:	89 de                	mov    %ebx,%esi
  800d55:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5c:	f3 0f 1e fb          	endbr32 
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d76:	89 df                	mov    %ebx,%edi
  800d78:	89 de                	mov    %ebx,%esi
  800d7a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d81:	f3 0f 1e fb          	endbr32 
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d96:	be 00 00 00 00       	mov    $0x0,%esi
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da8:	f3 0f 1e fb          	endbr32 
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbf:	89 cb                	mov    %ecx,%ebx
  800dc1:	89 cf                	mov    %ecx,%edi
  800dc3:	89 ce                	mov    %ecx,%esi
  800dc5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dcc:	f3 0f 1e fb          	endbr32 
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de0:	89 d1                	mov    %edx,%ecx
  800de2:	89 d3                	mov    %edx,%ebx
  800de4:	89 d7                	mov    %edx,%edi
  800de6:	89 d6                	mov    %edx,%esi
  800de8:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800def:	f3 0f 1e fb          	endbr32 
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e14:	f3 0f 1e fb          	endbr32 
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	b8 10 00 00 00       	mov    $0x10,%eax
  800e2e:	89 df                	mov    %ebx,%edi
  800e30:	89 de                	mov    %ebx,%esi
  800e32:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e39:	f3 0f 1e fb          	endbr32 
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	05 00 00 00 30       	add    $0x30000000,%eax
  800e48:	c1 e8 0c             	shr    $0xc,%eax
}
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e4d:	f3 0f 1e fb          	endbr32 
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e61:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e68:	f3 0f 1e fb          	endbr32 
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	c1 ea 16             	shr    $0x16,%edx
  800e79:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e80:	f6 c2 01             	test   $0x1,%dl
  800e83:	74 2d                	je     800eb2 <fd_alloc+0x4a>
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	c1 ea 0c             	shr    $0xc,%edx
  800e8a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e91:	f6 c2 01             	test   $0x1,%dl
  800e94:	74 1c                	je     800eb2 <fd_alloc+0x4a>
  800e96:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e9b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ea0:	75 d2                	jne    800e74 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800eab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800eb0:	eb 0a                	jmp    800ebc <fd_alloc+0x54>
			*fd_store = fd;
  800eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ebe:	f3 0f 1e fb          	endbr32 
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ec8:	83 f8 1f             	cmp    $0x1f,%eax
  800ecb:	77 30                	ja     800efd <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ecd:	c1 e0 0c             	shl    $0xc,%eax
  800ed0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ed5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800edb:	f6 c2 01             	test   $0x1,%dl
  800ede:	74 24                	je     800f04 <fd_lookup+0x46>
  800ee0:	89 c2                	mov    %eax,%edx
  800ee2:	c1 ea 0c             	shr    $0xc,%edx
  800ee5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eec:	f6 c2 01             	test   $0x1,%dl
  800eef:	74 1a                	je     800f0b <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef4:	89 02                	mov    %eax,(%edx)
	return 0;
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    
		return -E_INVAL;
  800efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f02:	eb f7                	jmp    800efb <fd_lookup+0x3d>
		return -E_INVAL;
  800f04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f09:	eb f0                	jmp    800efb <fd_lookup+0x3d>
  800f0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f10:	eb e9                	jmp    800efb <fd_lookup+0x3d>

00800f12 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f12:	f3 0f 1e fb          	endbr32 
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	83 ec 08             	sub    $0x8,%esp
  800f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f24:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f29:	39 08                	cmp    %ecx,(%eax)
  800f2b:	74 38                	je     800f65 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f2d:	83 c2 01             	add    $0x1,%edx
  800f30:	8b 04 95 5c 28 80 00 	mov    0x80285c(,%edx,4),%eax
  800f37:	85 c0                	test   %eax,%eax
  800f39:	75 ee                	jne    800f29 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f3b:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f40:	8b 40 48             	mov    0x48(%eax),%eax
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	51                   	push   %ecx
  800f47:	50                   	push   %eax
  800f48:	68 e0 27 80 00       	push   $0x8027e0
  800f4d:	e8 dd f2 ff ff       	call   80022f <cprintf>
	*dev = 0;
  800f52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    
			*dev = devtab[i];
  800f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f68:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	eb f2                	jmp    800f63 <dev_lookup+0x51>

00800f71 <fd_close>:
{
  800f71:	f3 0f 1e fb          	endbr32 
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 24             	sub    $0x24,%esp
  800f7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f81:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f87:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f88:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f8e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f91:	50                   	push   %eax
  800f92:	e8 27 ff ff ff       	call   800ebe <fd_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 05                	js     800fa5 <fd_close+0x34>
	    || fd != fd2)
  800fa0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fa3:	74 16                	je     800fbb <fd_close+0x4a>
		return (must_exist ? r : 0);
  800fa5:	89 f8                	mov    %edi,%eax
  800fa7:	84 c0                	test   %al,%al
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fae:	0f 44 d8             	cmove  %eax,%ebx
}
  800fb1:	89 d8                	mov    %ebx,%eax
  800fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	ff 36                	pushl  (%esi)
  800fc4:	e8 49 ff ff ff       	call   800f12 <dev_lookup>
  800fc9:	89 c3                	mov    %eax,%ebx
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 1a                	js     800fec <fd_close+0x7b>
		if (dev->dev_close)
  800fd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd5:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800fd8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	74 0b                	je     800fec <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	56                   	push   %esi
  800fe5:	ff d0                	call   *%eax
  800fe7:	89 c3                	mov    %eax,%ebx
  800fe9:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	56                   	push   %esi
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 f6 fc ff ff       	call   800ced <sys_page_unmap>
	return r;
  800ff7:	83 c4 10             	add    $0x10,%esp
  800ffa:	eb b5                	jmp    800fb1 <fd_close+0x40>

00800ffc <close>:

int
close(int fdnum)
{
  800ffc:	f3 0f 1e fb          	endbr32 
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801006:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801009:	50                   	push   %eax
  80100a:	ff 75 08             	pushl  0x8(%ebp)
  80100d:	e8 ac fe ff ff       	call   800ebe <fd_lookup>
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	79 02                	jns    80101b <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    
		return fd_close(fd, 1);
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	6a 01                	push   $0x1
  801020:	ff 75 f4             	pushl  -0xc(%ebp)
  801023:	e8 49 ff ff ff       	call   800f71 <fd_close>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	eb ec                	jmp    801019 <close+0x1d>

0080102d <close_all>:

void
close_all(void)
{
  80102d:	f3 0f 1e fb          	endbr32 
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	53                   	push   %ebx
  801035:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801038:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	53                   	push   %ebx
  801041:	e8 b6 ff ff ff       	call   800ffc <close>
	for (i = 0; i < MAXFD; i++)
  801046:	83 c3 01             	add    $0x1,%ebx
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	83 fb 20             	cmp    $0x20,%ebx
  80104f:	75 ec                	jne    80103d <close_all+0x10>
}
  801051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801056:	f3 0f 1e fb          	endbr32 
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	57                   	push   %edi
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
  801060:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801063:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	ff 75 08             	pushl  0x8(%ebp)
  80106a:	e8 4f fe ff ff       	call   800ebe <fd_lookup>
  80106f:	89 c3                	mov    %eax,%ebx
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	0f 88 81 00 00 00    	js     8010fd <dup+0xa7>
		return r;
	close(newfdnum);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	ff 75 0c             	pushl  0xc(%ebp)
  801082:	e8 75 ff ff ff       	call   800ffc <close>

	newfd = INDEX2FD(newfdnum);
  801087:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108a:	c1 e6 0c             	shl    $0xc,%esi
  80108d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801093:	83 c4 04             	add    $0x4,%esp
  801096:	ff 75 e4             	pushl  -0x1c(%ebp)
  801099:	e8 af fd ff ff       	call   800e4d <fd2data>
  80109e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010a0:	89 34 24             	mov    %esi,(%esp)
  8010a3:	e8 a5 fd ff ff       	call   800e4d <fd2data>
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ad:	89 d8                	mov    %ebx,%eax
  8010af:	c1 e8 16             	shr    $0x16,%eax
  8010b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b9:	a8 01                	test   $0x1,%al
  8010bb:	74 11                	je     8010ce <dup+0x78>
  8010bd:	89 d8                	mov    %ebx,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
  8010c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c9:	f6 c2 01             	test   $0x1,%dl
  8010cc:	75 39                	jne    801107 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010d1:	89 d0                	mov    %edx,%eax
  8010d3:	c1 e8 0c             	shr    $0xc,%eax
  8010d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e5:	50                   	push   %eax
  8010e6:	56                   	push   %esi
  8010e7:	6a 00                	push   $0x0
  8010e9:	52                   	push   %edx
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 d7 fb ff ff       	call   800cc8 <sys_page_map>
  8010f1:	89 c3                	mov    %eax,%ebx
  8010f3:	83 c4 20             	add    $0x20,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 31                	js     80112b <dup+0xd5>
		goto err;

	return newfdnum;
  8010fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010fd:	89 d8                	mov    %ebx,%eax
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801107:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	25 07 0e 00 00       	and    $0xe07,%eax
  801116:	50                   	push   %eax
  801117:	57                   	push   %edi
  801118:	6a 00                	push   $0x0
  80111a:	53                   	push   %ebx
  80111b:	6a 00                	push   $0x0
  80111d:	e8 a6 fb ff ff       	call   800cc8 <sys_page_map>
  801122:	89 c3                	mov    %eax,%ebx
  801124:	83 c4 20             	add    $0x20,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 a3                	jns    8010ce <dup+0x78>
	sys_page_unmap(0, newfd);
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	56                   	push   %esi
  80112f:	6a 00                	push   $0x0
  801131:	e8 b7 fb ff ff       	call   800ced <sys_page_unmap>
	sys_page_unmap(0, nva);
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	57                   	push   %edi
  80113a:	6a 00                	push   $0x0
  80113c:	e8 ac fb ff ff       	call   800ced <sys_page_unmap>
	return r;
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	eb b7                	jmp    8010fd <dup+0xa7>

00801146 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801146:	f3 0f 1e fb          	endbr32 
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	53                   	push   %ebx
  80114e:	83 ec 1c             	sub    $0x1c,%esp
  801151:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801154:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801157:	50                   	push   %eax
  801158:	53                   	push   %ebx
  801159:	e8 60 fd ff ff       	call   800ebe <fd_lookup>
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	78 3f                	js     8011a4 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116b:	50                   	push   %eax
  80116c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116f:	ff 30                	pushl  (%eax)
  801171:	e8 9c fd ff ff       	call   800f12 <dev_lookup>
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	78 27                	js     8011a4 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80117d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801180:	8b 42 08             	mov    0x8(%edx),%eax
  801183:	83 e0 03             	and    $0x3,%eax
  801186:	83 f8 01             	cmp    $0x1,%eax
  801189:	74 1e                	je     8011a9 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80118b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118e:	8b 40 08             	mov    0x8(%eax),%eax
  801191:	85 c0                	test   %eax,%eax
  801193:	74 35                	je     8011ca <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	ff 75 10             	pushl  0x10(%ebp)
  80119b:	ff 75 0c             	pushl  0xc(%ebp)
  80119e:	52                   	push   %edx
  80119f:	ff d0                	call   *%eax
  8011a1:	83 c4 10             	add    $0x10,%esp
}
  8011a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a9:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011ae:	8b 40 48             	mov    0x48(%eax),%eax
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	53                   	push   %ebx
  8011b5:	50                   	push   %eax
  8011b6:	68 21 28 80 00       	push   $0x802821
  8011bb:	e8 6f f0 ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c8:	eb da                	jmp    8011a4 <read+0x5e>
		return -E_NOT_SUPP;
  8011ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011cf:	eb d3                	jmp    8011a4 <read+0x5e>

008011d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d1:	f3 0f 1e fb          	endbr32 
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e9:	eb 02                	jmp    8011ed <readn+0x1c>
  8011eb:	01 c3                	add    %eax,%ebx
  8011ed:	39 f3                	cmp    %esi,%ebx
  8011ef:	73 21                	jae    801212 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	89 f0                	mov    %esi,%eax
  8011f6:	29 d8                	sub    %ebx,%eax
  8011f8:	50                   	push   %eax
  8011f9:	89 d8                	mov    %ebx,%eax
  8011fb:	03 45 0c             	add    0xc(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	57                   	push   %edi
  801200:	e8 41 ff ff ff       	call   801146 <read>
		if (m < 0)
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 04                	js     801210 <readn+0x3f>
			return m;
		if (m == 0)
  80120c:	75 dd                	jne    8011eb <readn+0x1a>
  80120e:	eb 02                	jmp    801212 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801210:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801212:	89 d8                	mov    %ebx,%eax
  801214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121c:	f3 0f 1e fb          	endbr32 
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	53                   	push   %ebx
  801224:	83 ec 1c             	sub    $0x1c,%esp
  801227:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	53                   	push   %ebx
  80122f:	e8 8a fc ff ff       	call   800ebe <fd_lookup>
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 3a                	js     801275 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123b:	83 ec 08             	sub    $0x8,%esp
  80123e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801245:	ff 30                	pushl  (%eax)
  801247:	e8 c6 fc ff ff       	call   800f12 <dev_lookup>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 22                	js     801275 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801256:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80125a:	74 1e                	je     80127a <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80125c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125f:	8b 52 0c             	mov    0xc(%edx),%edx
  801262:	85 d2                	test   %edx,%edx
  801264:	74 35                	je     80129b <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801266:	83 ec 04             	sub    $0x4,%esp
  801269:	ff 75 10             	pushl  0x10(%ebp)
  80126c:	ff 75 0c             	pushl  0xc(%ebp)
  80126f:	50                   	push   %eax
  801270:	ff d2                	call   *%edx
  801272:	83 c4 10             	add    $0x10,%esp
}
  801275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801278:	c9                   	leave  
  801279:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80127a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80127f:	8b 40 48             	mov    0x48(%eax),%eax
  801282:	83 ec 04             	sub    $0x4,%esp
  801285:	53                   	push   %ebx
  801286:	50                   	push   %eax
  801287:	68 3d 28 80 00       	push   $0x80283d
  80128c:	e8 9e ef ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801299:	eb da                	jmp    801275 <write+0x59>
		return -E_NOT_SUPP;
  80129b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012a0:	eb d3                	jmp    801275 <write+0x59>

008012a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a2:	f3 0f 1e fb          	endbr32 
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012af:	50                   	push   %eax
  8012b0:	ff 75 08             	pushl  0x8(%ebp)
  8012b3:	e8 06 fc ff ff       	call   800ebe <fd_lookup>
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 0e                	js     8012cd <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8012bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012cf:	f3 0f 1e fb          	endbr32 
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 1c             	sub    $0x1c,%esp
  8012da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	53                   	push   %ebx
  8012e2:	e8 d7 fb ff ff       	call   800ebe <fd_lookup>
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 37                	js     801325 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	ff 30                	pushl  (%eax)
  8012fa:	e8 13 fc ff ff       	call   800f12 <dev_lookup>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 1f                	js     801325 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	74 1b                	je     80132a <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80130f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801312:	8b 52 18             	mov    0x18(%edx),%edx
  801315:	85 d2                	test   %edx,%edx
  801317:	74 32                	je     80134b <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	ff 75 0c             	pushl  0xc(%ebp)
  80131f:	50                   	push   %eax
  801320:	ff d2                	call   *%edx
  801322:	83 c4 10             	add    $0x10,%esp
}
  801325:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801328:	c9                   	leave  
  801329:	c3                   	ret    
			thisenv->env_id, fdnum);
  80132a:	a1 20 40 c0 00       	mov    0xc04020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80132f:	8b 40 48             	mov    0x48(%eax),%eax
  801332:	83 ec 04             	sub    $0x4,%esp
  801335:	53                   	push   %ebx
  801336:	50                   	push   %eax
  801337:	68 00 28 80 00       	push   $0x802800
  80133c:	e8 ee ee ff ff       	call   80022f <cprintf>
		return -E_INVAL;
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801349:	eb da                	jmp    801325 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80134b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801350:	eb d3                	jmp    801325 <ftruncate+0x56>

00801352 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801352:	f3 0f 1e fb          	endbr32 
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 1c             	sub    $0x1c,%esp
  80135d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	ff 75 08             	pushl  0x8(%ebp)
  801367:	e8 52 fb ff ff       	call   800ebe <fd_lookup>
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 4b                	js     8013be <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	ff 30                	pushl  (%eax)
  80137f:	e8 8e fb ff ff       	call   800f12 <dev_lookup>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 33                	js     8013be <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801392:	74 2f                	je     8013c3 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801394:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801397:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80139e:	00 00 00 
	stat->st_isdir = 0;
  8013a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a8:	00 00 00 
	stat->st_dev = dev;
  8013ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b8:	ff 50 14             	call   *0x14(%eax)
  8013bb:	83 c4 10             	add    $0x10,%esp
}
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    
		return -E_NOT_SUPP;
  8013c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013c8:	eb f4                	jmp    8013be <fstat+0x6c>

008013ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ca:	f3 0f 1e fb          	endbr32 
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	6a 00                	push   $0x0
  8013d8:	ff 75 08             	pushl  0x8(%ebp)
  8013db:	e8 01 02 00 00       	call   8015e1 <open>
  8013e0:	89 c3                	mov    %eax,%ebx
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 1b                	js     801404 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	ff 75 0c             	pushl  0xc(%ebp)
  8013ef:	50                   	push   %eax
  8013f0:	e8 5d ff ff ff       	call   801352 <fstat>
  8013f5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013f7:	89 1c 24             	mov    %ebx,(%esp)
  8013fa:	e8 fd fb ff ff       	call   800ffc <close>
	return r;
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	89 f3                	mov    %esi,%ebx
}
  801404:	89 d8                	mov    %ebx,%eax
  801406:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
  801412:	89 c6                	mov    %eax,%esi
  801414:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801416:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80141d:	74 27                	je     801446 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80141f:	6a 07                	push   $0x7
  801421:	68 00 50 c0 00       	push   $0xc05000
  801426:	56                   	push   %esi
  801427:	ff 35 00 40 80 00    	pushl  0x804000
  80142d:	e8 7c 0c 00 00       	call   8020ae <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801432:	83 c4 0c             	add    $0xc,%esp
  801435:	6a 00                	push   $0x0
  801437:	53                   	push   %ebx
  801438:	6a 00                	push   $0x0
  80143a:	e8 02 0c 00 00       	call   802041 <ipc_recv>
}
  80143f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801442:	5b                   	pop    %ebx
  801443:	5e                   	pop    %esi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	6a 01                	push   $0x1
  80144b:	e8 b6 0c 00 00       	call   802106 <ipc_find_env>
  801450:	a3 00 40 80 00       	mov    %eax,0x804000
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	eb c5                	jmp    80141f <fsipc+0x12>

0080145a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80145a:	f3 0f 1e fb          	endbr32 
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
  801467:	8b 40 0c             	mov    0xc(%eax),%eax
  80146a:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  80146f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801472:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801477:	ba 00 00 00 00       	mov    $0x0,%edx
  80147c:	b8 02 00 00 00       	mov    $0x2,%eax
  801481:	e8 87 ff ff ff       	call   80140d <fsipc>
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <devfile_flush>:
{
  801488:	f3 0f 1e fb          	endbr32 
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801492:	8b 45 08             	mov    0x8(%ebp),%eax
  801495:	8b 40 0c             	mov    0xc(%eax),%eax
  801498:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  80149d:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a7:	e8 61 ff ff ff       	call   80140d <fsipc>
}
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <devfile_stat>:
{
  8014ae:	f3 0f 1e fb          	endbr32 
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 04             	sub    $0x4,%esp
  8014b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c2:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d1:	e8 37 ff ff ff       	call   80140d <fsipc>
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 2c                	js     801506 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	68 00 50 c0 00       	push   $0xc05000
  8014e2:	53                   	push   %ebx
  8014e3:	e8 51 f3 ff ff       	call   800839 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e8:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8014ed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f3:	a1 84 50 c0 00       	mov    0xc05084,%eax
  8014f8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801506:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <devfile_write>:
{
  80150b:	f3 0f 1e fb          	endbr32 
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	8b 45 10             	mov    0x10(%ebp),%eax
  801518:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80151d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801522:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801525:	8b 55 08             	mov    0x8(%ebp),%edx
  801528:	8b 52 0c             	mov    0xc(%edx),%edx
  80152b:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  801531:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801536:	50                   	push   %eax
  801537:	ff 75 0c             	pushl  0xc(%ebp)
  80153a:	68 08 50 c0 00       	push   $0xc05008
  80153f:	e8 f3 f4 ff ff       	call   800a37 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
  801549:	b8 04 00 00 00       	mov    $0x4,%eax
  80154e:	e8 ba fe ff ff       	call   80140d <fsipc>
}
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <devfile_read>:
{
  801555:	f3 0f 1e fb          	endbr32 
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	56                   	push   %esi
  80155d:	53                   	push   %ebx
  80155e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801561:	8b 45 08             	mov    0x8(%ebp),%eax
  801564:	8b 40 0c             	mov    0xc(%eax),%eax
  801567:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  80156c:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 03 00 00 00       	mov    $0x3,%eax
  80157c:	e8 8c fe ff ff       	call   80140d <fsipc>
  801581:	89 c3                	mov    %eax,%ebx
  801583:	85 c0                	test   %eax,%eax
  801585:	78 1f                	js     8015a6 <devfile_read+0x51>
	assert(r <= n);
  801587:	39 f0                	cmp    %esi,%eax
  801589:	77 24                	ja     8015af <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80158b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801590:	7f 36                	jg     8015c8 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	50                   	push   %eax
  801596:	68 00 50 c0 00       	push   $0xc05000
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	e8 94 f4 ff ff       	call   800a37 <memmove>
	return r;
  8015a3:	83 c4 10             	add    $0x10,%esp
}
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    
	assert(r <= n);
  8015af:	68 70 28 80 00       	push   $0x802870
  8015b4:	68 77 28 80 00       	push   $0x802877
  8015b9:	68 8c 00 00 00       	push   $0x8c
  8015be:	68 8c 28 80 00       	push   $0x80288c
  8015c3:	e8 80 eb ff ff       	call   800148 <_panic>
	assert(r <= PGSIZE);
  8015c8:	68 97 28 80 00       	push   $0x802897
  8015cd:	68 77 28 80 00       	push   $0x802877
  8015d2:	68 8d 00 00 00       	push   $0x8d
  8015d7:	68 8c 28 80 00       	push   $0x80288c
  8015dc:	e8 67 eb ff ff       	call   800148 <_panic>

008015e1 <open>:
{
  8015e1:	f3 0f 1e fb          	endbr32 
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 1c             	sub    $0x1c,%esp
  8015ed:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015f0:	56                   	push   %esi
  8015f1:	e8 00 f2 ff ff       	call   8007f6 <strlen>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fe:	7f 6c                	jg     80166c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801600:	83 ec 0c             	sub    $0xc,%esp
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	e8 5c f8 ff ff       	call   800e68 <fd_alloc>
  80160c:	89 c3                	mov    %eax,%ebx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	78 3c                	js     801651 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	56                   	push   %esi
  801619:	68 00 50 c0 00       	push   $0xc05000
  80161e:	e8 16 f2 ff ff       	call   800839 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801623:	8b 45 0c             	mov    0xc(%ebp),%eax
  801626:	a3 00 54 c0 00       	mov    %eax,0xc05400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80162b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162e:	b8 01 00 00 00       	mov    $0x1,%eax
  801633:	e8 d5 fd ff ff       	call   80140d <fsipc>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 19                	js     80165a <open+0x79>
	return fd2num(fd);
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	ff 75 f4             	pushl  -0xc(%ebp)
  801647:	e8 ed f7 ff ff       	call   800e39 <fd2num>
  80164c:	89 c3                	mov    %eax,%ebx
  80164e:	83 c4 10             	add    $0x10,%esp
}
  801651:	89 d8                	mov    %ebx,%eax
  801653:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    
		fd_close(fd, 0);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	6a 00                	push   $0x0
  80165f:	ff 75 f4             	pushl  -0xc(%ebp)
  801662:	e8 0a f9 ff ff       	call   800f71 <fd_close>
		return r;
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	eb e5                	jmp    801651 <open+0x70>
		return -E_BAD_PATH;
  80166c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801671:	eb de                	jmp    801651 <open+0x70>

00801673 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801673:	f3 0f 1e fb          	endbr32 
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80167d:	ba 00 00 00 00       	mov    $0x0,%edx
  801682:	b8 08 00 00 00       	mov    $0x8,%eax
  801687:	e8 81 fd ff ff       	call   80140d <fsipc>
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80168e:	f3 0f 1e fb          	endbr32 
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801698:	68 03 29 80 00       	push   $0x802903
  80169d:	ff 75 0c             	pushl  0xc(%ebp)
  8016a0:	e8 94 f1 ff ff       	call   800839 <strcpy>
	return 0;
}
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <devsock_close>:
{
  8016ac:	f3 0f 1e fb          	endbr32 
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 10             	sub    $0x10,%esp
  8016b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016ba:	53                   	push   %ebx
  8016bb:	e8 83 0a 00 00       	call   802143 <pageref>
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016c5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016ca:	83 fa 01             	cmp    $0x1,%edx
  8016cd:	74 05                	je     8016d4 <devsock_close+0x28>
}
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016d4:	83 ec 0c             	sub    $0xc,%esp
  8016d7:	ff 73 0c             	pushl  0xc(%ebx)
  8016da:	e8 e3 02 00 00       	call   8019c2 <nsipc_close>
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	eb eb                	jmp    8016cf <devsock_close+0x23>

008016e4 <devsock_write>:
{
  8016e4:	f3 0f 1e fb          	endbr32 
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8016ee:	6a 00                	push   $0x0
  8016f0:	ff 75 10             	pushl  0x10(%ebp)
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	ff 70 0c             	pushl  0xc(%eax)
  8016fc:	e8 b5 03 00 00       	call   801ab6 <nsipc_send>
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <devsock_read>:
{
  801703:	f3 0f 1e fb          	endbr32 
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80170d:	6a 00                	push   $0x0
  80170f:	ff 75 10             	pushl  0x10(%ebp)
  801712:	ff 75 0c             	pushl  0xc(%ebp)
  801715:	8b 45 08             	mov    0x8(%ebp),%eax
  801718:	ff 70 0c             	pushl  0xc(%eax)
  80171b:	e8 1f 03 00 00       	call   801a3f <nsipc_recv>
}
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <fd2sockid>:
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801728:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80172b:	52                   	push   %edx
  80172c:	50                   	push   %eax
  80172d:	e8 8c f7 ff ff       	call   800ebe <fd_lookup>
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	85 c0                	test   %eax,%eax
  801737:	78 10                	js     801749 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173c:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801742:	39 08                	cmp    %ecx,(%eax)
  801744:	75 05                	jne    80174b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801746:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801749:	c9                   	leave  
  80174a:	c3                   	ret    
		return -E_NOT_SUPP;
  80174b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801750:	eb f7                	jmp    801749 <fd2sockid+0x27>

00801752 <alloc_sockfd>:
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	83 ec 1c             	sub    $0x1c,%esp
  80175a:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80175c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175f:	50                   	push   %eax
  801760:	e8 03 f7 ff ff       	call   800e68 <fd_alloc>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 43                	js     8017b1 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	68 07 04 00 00       	push   $0x407
  801776:	ff 75 f4             	pushl  -0xc(%ebp)
  801779:	6a 00                	push   $0x0
  80177b:	e8 22 f5 ff ff       	call   800ca2 <sys_page_alloc>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 28                	js     8017b1 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178c:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801792:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80179e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	50                   	push   %eax
  8017a5:	e8 8f f6 ff ff       	call   800e39 <fd2num>
  8017aa:	89 c3                	mov    %eax,%ebx
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	eb 0c                	jmp    8017bd <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	56                   	push   %esi
  8017b5:	e8 08 02 00 00       	call   8019c2 <nsipc_close>
		return r;
  8017ba:	83 c4 10             	add    $0x10,%esp
}
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <accept>:
{
  8017c6:	f3 0f 1e fb          	endbr32 
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	e8 4a ff ff ff       	call   801722 <fd2sockid>
  8017d8:	85 c0                	test   %eax,%eax
  8017da:	78 1b                	js     8017f7 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	ff 75 10             	pushl  0x10(%ebp)
  8017e2:	ff 75 0c             	pushl  0xc(%ebp)
  8017e5:	50                   	push   %eax
  8017e6:	e8 22 01 00 00       	call   80190d <nsipc_accept>
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 05                	js     8017f7 <accept+0x31>
	return alloc_sockfd(r);
  8017f2:	e8 5b ff ff ff       	call   801752 <alloc_sockfd>
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <bind>:
{
  8017f9:	f3 0f 1e fb          	endbr32 
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	e8 17 ff ff ff       	call   801722 <fd2sockid>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 12                	js     801821 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	ff 75 10             	pushl  0x10(%ebp)
  801815:	ff 75 0c             	pushl  0xc(%ebp)
  801818:	50                   	push   %eax
  801819:	e8 45 01 00 00       	call   801963 <nsipc_bind>
  80181e:	83 c4 10             	add    $0x10,%esp
}
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <shutdown>:
{
  801823:	f3 0f 1e fb          	endbr32 
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	e8 ed fe ff ff       	call   801722 <fd2sockid>
  801835:	85 c0                	test   %eax,%eax
  801837:	78 0f                	js     801848 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	ff 75 0c             	pushl  0xc(%ebp)
  80183f:	50                   	push   %eax
  801840:	e8 57 01 00 00       	call   80199c <nsipc_shutdown>
  801845:	83 c4 10             	add    $0x10,%esp
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <connect>:
{
  80184a:	f3 0f 1e fb          	endbr32 
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	e8 c6 fe ff ff       	call   801722 <fd2sockid>
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 12                	js     801872 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801860:	83 ec 04             	sub    $0x4,%esp
  801863:	ff 75 10             	pushl  0x10(%ebp)
  801866:	ff 75 0c             	pushl  0xc(%ebp)
  801869:	50                   	push   %eax
  80186a:	e8 71 01 00 00       	call   8019e0 <nsipc_connect>
  80186f:	83 c4 10             	add    $0x10,%esp
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <listen>:
{
  801874:	f3 0f 1e fb          	endbr32 
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	e8 9c fe ff ff       	call   801722 <fd2sockid>
  801886:	85 c0                	test   %eax,%eax
  801888:	78 0f                	js     801899 <listen+0x25>
	return nsipc_listen(r, backlog);
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	50                   	push   %eax
  801891:	e8 83 01 00 00       	call   801a19 <nsipc_listen>
  801896:	83 c4 10             	add    $0x10,%esp
}
  801899:	c9                   	leave  
  80189a:	c3                   	ret    

0080189b <socket>:

int
socket(int domain, int type, int protocol)
{
  80189b:	f3 0f 1e fb          	endbr32 
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018a5:	ff 75 10             	pushl  0x10(%ebp)
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	ff 75 08             	pushl  0x8(%ebp)
  8018ae:	e8 65 02 00 00       	call   801b18 <nsipc_socket>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 05                	js     8018bf <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8018ba:	e8 93 fe ff ff       	call   801752 <alloc_sockfd>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 04             	sub    $0x4,%esp
  8018c8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018ca:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018d1:	74 26                	je     8018f9 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018d3:	6a 07                	push   $0x7
  8018d5:	68 00 60 c0 00       	push   $0xc06000
  8018da:	53                   	push   %ebx
  8018db:	ff 35 04 40 80 00    	pushl  0x804004
  8018e1:	e8 c8 07 00 00       	call   8020ae <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8018e6:	83 c4 0c             	add    $0xc,%esp
  8018e9:	6a 00                	push   $0x0
  8018eb:	6a 00                	push   $0x0
  8018ed:	6a 00                	push   $0x0
  8018ef:	e8 4d 07 00 00       	call   802041 <ipc_recv>
}
  8018f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018f9:	83 ec 0c             	sub    $0xc,%esp
  8018fc:	6a 02                	push   $0x2
  8018fe:	e8 03 08 00 00       	call   802106 <ipc_find_env>
  801903:	a3 04 40 80 00       	mov    %eax,0x804004
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	eb c6                	jmp    8018d3 <nsipc+0x12>

0080190d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80190d:	f3 0f 1e fb          	endbr32 
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801921:	8b 06                	mov    (%esi),%eax
  801923:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801928:	b8 01 00 00 00       	mov    $0x1,%eax
  80192d:	e8 8f ff ff ff       	call   8018c1 <nsipc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	85 c0                	test   %eax,%eax
  801936:	79 09                	jns    801941 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801938:	89 d8                	mov    %ebx,%eax
  80193a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801941:	83 ec 04             	sub    $0x4,%esp
  801944:	ff 35 10 60 c0 00    	pushl  0xc06010
  80194a:	68 00 60 c0 00       	push   $0xc06000
  80194f:	ff 75 0c             	pushl  0xc(%ebp)
  801952:	e8 e0 f0 ff ff       	call   800a37 <memmove>
		*addrlen = ret->ret_addrlen;
  801957:	a1 10 60 c0 00       	mov    0xc06010,%eax
  80195c:	89 06                	mov    %eax,(%esi)
  80195e:	83 c4 10             	add    $0x10,%esp
	return r;
  801961:	eb d5                	jmp    801938 <nsipc_accept+0x2b>

00801963 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801963:	f3 0f 1e fb          	endbr32 
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801979:	53                   	push   %ebx
  80197a:	ff 75 0c             	pushl  0xc(%ebp)
  80197d:	68 04 60 c0 00       	push   $0xc06004
  801982:	e8 b0 f0 ff ff       	call   800a37 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801987:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  80198d:	b8 02 00 00 00       	mov    $0x2,%eax
  801992:	e8 2a ff ff ff       	call   8018c1 <nsipc>
}
  801997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80199c:	f3 0f 1e fb          	endbr32 
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  8019ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b1:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  8019b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8019bb:	e8 01 ff ff ff       	call   8018c1 <nsipc>
}
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <nsipc_close>:

int
nsipc_close(int s)
{
  8019c2:	f3 0f 1e fb          	endbr32 
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cf:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  8019d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d9:	e8 e3 fe ff ff       	call   8018c1 <nsipc>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019e0:	f3 0f 1e fb          	endbr32 
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	53                   	push   %ebx
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019f6:	53                   	push   %ebx
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	68 04 60 c0 00       	push   $0xc06004
  8019ff:	e8 33 f0 ff ff       	call   800a37 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a04:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801a0a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a0f:	e8 ad fe ff ff       	call   8018c1 <nsipc>
}
  801a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a19:	f3 0f 1e fb          	endbr32 
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  801a33:	b8 06 00 00 00       	mov    $0x6,%eax
  801a38:	e8 84 fe ff ff       	call   8018c1 <nsipc>
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a3f:	f3 0f 1e fb          	endbr32 
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  801a53:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801a59:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5c:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a61:	b8 07 00 00 00       	mov    $0x7,%eax
  801a66:	e8 56 fe ff ff       	call   8018c1 <nsipc>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	78 26                	js     801a97 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801a71:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801a77:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a7c:	0f 4e c6             	cmovle %esi,%eax
  801a7f:	39 c3                	cmp    %eax,%ebx
  801a81:	7f 1d                	jg     801aa0 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a83:	83 ec 04             	sub    $0x4,%esp
  801a86:	53                   	push   %ebx
  801a87:	68 00 60 c0 00       	push   $0xc06000
  801a8c:	ff 75 0c             	pushl  0xc(%ebp)
  801a8f:	e8 a3 ef ff ff       	call   800a37 <memmove>
  801a94:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a97:	89 d8                	mov    %ebx,%eax
  801a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801aa0:	68 0f 29 80 00       	push   $0x80290f
  801aa5:	68 77 28 80 00       	push   $0x802877
  801aaa:	6a 62                	push   $0x62
  801aac:	68 24 29 80 00       	push   $0x802924
  801ab1:	e8 92 e6 ff ff       	call   800148 <_panic>

00801ab6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ab6:	f3 0f 1e fb          	endbr32 
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	53                   	push   %ebx
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac7:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801acc:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ad2:	7f 2e                	jg     801b02 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ad4:	83 ec 04             	sub    $0x4,%esp
  801ad7:	53                   	push   %ebx
  801ad8:	ff 75 0c             	pushl  0xc(%ebp)
  801adb:	68 0c 60 c0 00       	push   $0xc0600c
  801ae0:	e8 52 ef ff ff       	call   800a37 <memmove>
	nsipcbuf.send.req_size = size;
  801ae5:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801aeb:	8b 45 14             	mov    0x14(%ebp),%eax
  801aee:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801af3:	b8 08 00 00 00       	mov    $0x8,%eax
  801af8:	e8 c4 fd ff ff       	call   8018c1 <nsipc>
}
  801afd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    
	assert(size < 1600);
  801b02:	68 30 29 80 00       	push   $0x802930
  801b07:	68 77 28 80 00       	push   $0x802877
  801b0c:	6a 6d                	push   $0x6d
  801b0e:	68 24 29 80 00       	push   $0x802924
  801b13:	e8 30 e6 ff ff       	call   800148 <_panic>

00801b18 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b18:	f3 0f 1e fb          	endbr32 
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2d:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801b32:	8b 45 10             	mov    0x10(%ebp),%eax
  801b35:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801b3a:	b8 09 00 00 00       	mov    $0x9,%eax
  801b3f:	e8 7d fd ff ff       	call   8018c1 <nsipc>
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b46:	f3 0f 1e fb          	endbr32 
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	ff 75 08             	pushl  0x8(%ebp)
  801b58:	e8 f0 f2 ff ff       	call   800e4d <fd2data>
  801b5d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b5f:	83 c4 08             	add    $0x8,%esp
  801b62:	68 3c 29 80 00       	push   $0x80293c
  801b67:	53                   	push   %ebx
  801b68:	e8 cc ec ff ff       	call   800839 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b6d:	8b 46 04             	mov    0x4(%esi),%eax
  801b70:	2b 06                	sub    (%esi),%eax
  801b72:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b78:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b7f:	00 00 00 
	stat->st_dev = &devpipe;
  801b82:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801b89:	30 80 00 
	return 0;
}
  801b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b94:	5b                   	pop    %ebx
  801b95:	5e                   	pop    %esi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b98:	f3 0f 1e fb          	endbr32 
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ba6:	53                   	push   %ebx
  801ba7:	6a 00                	push   $0x0
  801ba9:	e8 3f f1 ff ff       	call   800ced <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bae:	89 1c 24             	mov    %ebx,(%esp)
  801bb1:	e8 97 f2 ff ff       	call   800e4d <fd2data>
  801bb6:	83 c4 08             	add    $0x8,%esp
  801bb9:	50                   	push   %eax
  801bba:	6a 00                	push   $0x0
  801bbc:	e8 2c f1 ff ff       	call   800ced <sys_page_unmap>
}
  801bc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc4:	c9                   	leave  
  801bc5:	c3                   	ret    

00801bc6 <_pipeisclosed>:
{
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	57                   	push   %edi
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	83 ec 1c             	sub    $0x1c,%esp
  801bcf:	89 c7                	mov    %eax,%edi
  801bd1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801bd3:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801bd8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	57                   	push   %edi
  801bdf:	e8 5f 05 00 00       	call   802143 <pageref>
  801be4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801be7:	89 34 24             	mov    %esi,(%esp)
  801bea:	e8 54 05 00 00       	call   802143 <pageref>
		nn = thisenv->env_runs;
  801bef:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  801bf5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	39 cb                	cmp    %ecx,%ebx
  801bfd:	74 1b                	je     801c1a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bff:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c02:	75 cf                	jne    801bd3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c04:	8b 42 58             	mov    0x58(%edx),%eax
  801c07:	6a 01                	push   $0x1
  801c09:	50                   	push   %eax
  801c0a:	53                   	push   %ebx
  801c0b:	68 43 29 80 00       	push   $0x802943
  801c10:	e8 1a e6 ff ff       	call   80022f <cprintf>
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	eb b9                	jmp    801bd3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c1a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c1d:	0f 94 c0             	sete   %al
  801c20:	0f b6 c0             	movzbl %al,%eax
}
  801c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <devpipe_write>:
{
  801c2b:	f3 0f 1e fb          	endbr32 
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	57                   	push   %edi
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	83 ec 28             	sub    $0x28,%esp
  801c38:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c3b:	56                   	push   %esi
  801c3c:	e8 0c f2 ff ff       	call   800e4d <fd2data>
  801c41:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	bf 00 00 00 00       	mov    $0x0,%edi
  801c4b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c4e:	74 4f                	je     801c9f <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c50:	8b 43 04             	mov    0x4(%ebx),%eax
  801c53:	8b 0b                	mov    (%ebx),%ecx
  801c55:	8d 51 20             	lea    0x20(%ecx),%edx
  801c58:	39 d0                	cmp    %edx,%eax
  801c5a:	72 14                	jb     801c70 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c5c:	89 da                	mov    %ebx,%edx
  801c5e:	89 f0                	mov    %esi,%eax
  801c60:	e8 61 ff ff ff       	call   801bc6 <_pipeisclosed>
  801c65:	85 c0                	test   %eax,%eax
  801c67:	75 3b                	jne    801ca4 <devpipe_write+0x79>
			sys_yield();
  801c69:	e8 11 f0 ff ff       	call   800c7f <sys_yield>
  801c6e:	eb e0                	jmp    801c50 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c73:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c77:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c7a:	89 c2                	mov    %eax,%edx
  801c7c:	c1 fa 1f             	sar    $0x1f,%edx
  801c7f:	89 d1                	mov    %edx,%ecx
  801c81:	c1 e9 1b             	shr    $0x1b,%ecx
  801c84:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c87:	83 e2 1f             	and    $0x1f,%edx
  801c8a:	29 ca                	sub    %ecx,%edx
  801c8c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c90:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c94:	83 c0 01             	add    $0x1,%eax
  801c97:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c9a:	83 c7 01             	add    $0x1,%edi
  801c9d:	eb ac                	jmp    801c4b <devpipe_write+0x20>
	return i;
  801c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca2:	eb 05                	jmp    801ca9 <devpipe_write+0x7e>
				return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <devpipe_read>:
{
  801cb1:	f3 0f 1e fb          	endbr32 
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	57                   	push   %edi
  801cb9:	56                   	push   %esi
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 18             	sub    $0x18,%esp
  801cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cc1:	57                   	push   %edi
  801cc2:	e8 86 f1 ff ff       	call   800e4d <fd2data>
  801cc7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	be 00 00 00 00       	mov    $0x0,%esi
  801cd1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cd4:	75 14                	jne    801cea <devpipe_read+0x39>
	return i;
  801cd6:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd9:	eb 02                	jmp    801cdd <devpipe_read+0x2c>
				return i;
  801cdb:	89 f0                	mov    %esi,%eax
}
  801cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
			sys_yield();
  801ce5:	e8 95 ef ff ff       	call   800c7f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cea:	8b 03                	mov    (%ebx),%eax
  801cec:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cef:	75 18                	jne    801d09 <devpipe_read+0x58>
			if (i > 0)
  801cf1:	85 f6                	test   %esi,%esi
  801cf3:	75 e6                	jne    801cdb <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801cf5:	89 da                	mov    %ebx,%edx
  801cf7:	89 f8                	mov    %edi,%eax
  801cf9:	e8 c8 fe ff ff       	call   801bc6 <_pipeisclosed>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	74 e3                	je     801ce5 <devpipe_read+0x34>
				return 0;
  801d02:	b8 00 00 00 00       	mov    $0x0,%eax
  801d07:	eb d4                	jmp    801cdd <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d09:	99                   	cltd   
  801d0a:	c1 ea 1b             	shr    $0x1b,%edx
  801d0d:	01 d0                	add    %edx,%eax
  801d0f:	83 e0 1f             	and    $0x1f,%eax
  801d12:	29 d0                	sub    %edx,%eax
  801d14:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d1c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d1f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d22:	83 c6 01             	add    $0x1,%esi
  801d25:	eb aa                	jmp    801cd1 <devpipe_read+0x20>

00801d27 <pipe>:
{
  801d27:	f3 0f 1e fb          	endbr32 
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	56                   	push   %esi
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d36:	50                   	push   %eax
  801d37:	e8 2c f1 ff ff       	call   800e68 <fd_alloc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	0f 88 23 01 00 00    	js     801e6c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	68 07 04 00 00       	push   $0x407
  801d51:	ff 75 f4             	pushl  -0xc(%ebp)
  801d54:	6a 00                	push   $0x0
  801d56:	e8 47 ef ff ff       	call   800ca2 <sys_page_alloc>
  801d5b:	89 c3                	mov    %eax,%ebx
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	85 c0                	test   %eax,%eax
  801d62:	0f 88 04 01 00 00    	js     801e6c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	e8 f4 f0 ff ff       	call   800e68 <fd_alloc>
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	83 c4 10             	add    $0x10,%esp
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	0f 88 db 00 00 00    	js     801e5c <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d81:	83 ec 04             	sub    $0x4,%esp
  801d84:	68 07 04 00 00       	push   $0x407
  801d89:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8c:	6a 00                	push   $0x0
  801d8e:	e8 0f ef ff ff       	call   800ca2 <sys_page_alloc>
  801d93:	89 c3                	mov    %eax,%ebx
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	0f 88 bc 00 00 00    	js     801e5c <pipe+0x135>
	va = fd2data(fd0);
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	ff 75 f4             	pushl  -0xc(%ebp)
  801da6:	e8 a2 f0 ff ff       	call   800e4d <fd2data>
  801dab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dad:	83 c4 0c             	add    $0xc,%esp
  801db0:	68 07 04 00 00       	push   $0x407
  801db5:	50                   	push   %eax
  801db6:	6a 00                	push   $0x0
  801db8:	e8 e5 ee ff ff       	call   800ca2 <sys_page_alloc>
  801dbd:	89 c3                	mov    %eax,%ebx
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	0f 88 82 00 00 00    	js     801e4c <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dca:	83 ec 0c             	sub    $0xc,%esp
  801dcd:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd0:	e8 78 f0 ff ff       	call   800e4d <fd2data>
  801dd5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ddc:	50                   	push   %eax
  801ddd:	6a 00                	push   $0x0
  801ddf:	56                   	push   %esi
  801de0:	6a 00                	push   $0x0
  801de2:	e8 e1 ee ff ff       	call   800cc8 <sys_page_map>
  801de7:	89 c3                	mov    %eax,%ebx
  801de9:	83 c4 20             	add    $0x20,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	78 4e                	js     801e3e <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801df0:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801df5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801df8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dfd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e04:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e07:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e13:	83 ec 0c             	sub    $0xc,%esp
  801e16:	ff 75 f4             	pushl  -0xc(%ebp)
  801e19:	e8 1b f0 ff ff       	call   800e39 <fd2num>
  801e1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e21:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e23:	83 c4 04             	add    $0x4,%esp
  801e26:	ff 75 f0             	pushl  -0x10(%ebp)
  801e29:	e8 0b f0 ff ff       	call   800e39 <fd2num>
  801e2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e31:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e3c:	eb 2e                	jmp    801e6c <pipe+0x145>
	sys_page_unmap(0, va);
  801e3e:	83 ec 08             	sub    $0x8,%esp
  801e41:	56                   	push   %esi
  801e42:	6a 00                	push   $0x0
  801e44:	e8 a4 ee ff ff       	call   800ced <sys_page_unmap>
  801e49:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e4c:	83 ec 08             	sub    $0x8,%esp
  801e4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e52:	6a 00                	push   $0x0
  801e54:	e8 94 ee ff ff       	call   800ced <sys_page_unmap>
  801e59:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e5c:	83 ec 08             	sub    $0x8,%esp
  801e5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e62:	6a 00                	push   $0x0
  801e64:	e8 84 ee ff ff       	call   800ced <sys_page_unmap>
  801e69:	83 c4 10             	add    $0x10,%esp
}
  801e6c:	89 d8                	mov    %ebx,%eax
  801e6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e71:	5b                   	pop    %ebx
  801e72:	5e                   	pop    %esi
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    

00801e75 <pipeisclosed>:
{
  801e75:	f3 0f 1e fb          	endbr32 
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	ff 75 08             	pushl  0x8(%ebp)
  801e86:	e8 33 f0 ff ff       	call   800ebe <fd_lookup>
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 18                	js     801eaa <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	ff 75 f4             	pushl  -0xc(%ebp)
  801e98:	e8 b0 ef ff ff       	call   800e4d <fd2data>
  801e9d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea2:	e8 1f fd ff ff       	call   801bc6 <_pipeisclosed>
  801ea7:	83 c4 10             	add    $0x10,%esp
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eac:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801eb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb5:	c3                   	ret    

00801eb6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb6:	f3 0f 1e fb          	endbr32 
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ec0:	68 5b 29 80 00       	push   $0x80295b
  801ec5:	ff 75 0c             	pushl  0xc(%ebp)
  801ec8:	e8 6c e9 ff ff       	call   800839 <strcpy>
	return 0;
}
  801ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <devcons_write>:
{
  801ed4:	f3 0f 1e fb          	endbr32 
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	57                   	push   %edi
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ee4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ee9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801eef:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef2:	73 31                	jae    801f25 <devcons_write+0x51>
		m = n - tot;
  801ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef7:	29 f3                	sub    %esi,%ebx
  801ef9:	83 fb 7f             	cmp    $0x7f,%ebx
  801efc:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f01:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f04:	83 ec 04             	sub    $0x4,%esp
  801f07:	53                   	push   %ebx
  801f08:	89 f0                	mov    %esi,%eax
  801f0a:	03 45 0c             	add    0xc(%ebp),%eax
  801f0d:	50                   	push   %eax
  801f0e:	57                   	push   %edi
  801f0f:	e8 23 eb ff ff       	call   800a37 <memmove>
		sys_cputs(buf, m);
  801f14:	83 c4 08             	add    $0x8,%esp
  801f17:	53                   	push   %ebx
  801f18:	57                   	push   %edi
  801f19:	e8 d5 ec ff ff       	call   800bf3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f1e:	01 de                	add    %ebx,%esi
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	eb ca                	jmp    801eef <devcons_write+0x1b>
}
  801f25:	89 f0                	mov    %esi,%eax
  801f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2a:	5b                   	pop    %ebx
  801f2b:	5e                   	pop    %esi
  801f2c:	5f                   	pop    %edi
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    

00801f2f <devcons_read>:
{
  801f2f:	f3 0f 1e fb          	endbr32 
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 08             	sub    $0x8,%esp
  801f39:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f42:	74 21                	je     801f65 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f44:	e8 cc ec ff ff       	call   800c15 <sys_cgetc>
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	75 07                	jne    801f54 <devcons_read+0x25>
		sys_yield();
  801f4d:	e8 2d ed ff ff       	call   800c7f <sys_yield>
  801f52:	eb f0                	jmp    801f44 <devcons_read+0x15>
	if (c < 0)
  801f54:	78 0f                	js     801f65 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f56:	83 f8 04             	cmp    $0x4,%eax
  801f59:	74 0c                	je     801f67 <devcons_read+0x38>
	*(char*)vbuf = c;
  801f5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5e:	88 02                	mov    %al,(%edx)
	return 1;
  801f60:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    
		return 0;
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6c:	eb f7                	jmp    801f65 <devcons_read+0x36>

00801f6e <cputchar>:
{
  801f6e:	f3 0f 1e fb          	endbr32 
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f78:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f7e:	6a 01                	push   $0x1
  801f80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f83:	50                   	push   %eax
  801f84:	e8 6a ec ff ff       	call   800bf3 <sys_cputs>
}
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    

00801f8e <getchar>:
{
  801f8e:	f3 0f 1e fb          	endbr32 
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f98:	6a 01                	push   $0x1
  801f9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f9d:	50                   	push   %eax
  801f9e:	6a 00                	push   $0x0
  801fa0:	e8 a1 f1 ff ff       	call   801146 <read>
	if (r < 0)
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	78 06                	js     801fb2 <getchar+0x24>
	if (r < 1)
  801fac:	74 06                	je     801fb4 <getchar+0x26>
	return c;
  801fae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    
		return -E_EOF;
  801fb4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fb9:	eb f7                	jmp    801fb2 <getchar+0x24>

00801fbb <iscons>:
{
  801fbb:	f3 0f 1e fb          	endbr32 
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc8:	50                   	push   %eax
  801fc9:	ff 75 08             	pushl  0x8(%ebp)
  801fcc:	e8 ed ee ff ff       	call   800ebe <fd_lookup>
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	85 c0                	test   %eax,%eax
  801fd6:	78 11                	js     801fe9 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801fe1:	39 10                	cmp    %edx,(%eax)
  801fe3:	0f 94 c0             	sete   %al
  801fe6:	0f b6 c0             	movzbl %al,%eax
}
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <opencons>:
{
  801feb:	f3 0f 1e fb          	endbr32 
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ff5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff8:	50                   	push   %eax
  801ff9:	e8 6a ee ff ff       	call   800e68 <fd_alloc>
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	78 3a                	js     80203f <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802005:	83 ec 04             	sub    $0x4,%esp
  802008:	68 07 04 00 00       	push   $0x407
  80200d:	ff 75 f4             	pushl  -0xc(%ebp)
  802010:	6a 00                	push   $0x0
  802012:	e8 8b ec ff ff       	call   800ca2 <sys_page_alloc>
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	78 21                	js     80203f <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802021:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802027:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802033:	83 ec 0c             	sub    $0xc,%esp
  802036:	50                   	push   %eax
  802037:	e8 fd ed ff ff       	call   800e39 <fd2num>
  80203c:	83 c4 10             	add    $0x10,%esp
}
  80203f:	c9                   	leave  
  802040:	c3                   	ret    

00802041 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802041:	f3 0f 1e fb          	endbr32 
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	56                   	push   %esi
  802049:	53                   	push   %ebx
  80204a:	8b 75 08             	mov    0x8(%ebp),%esi
  80204d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802050:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802053:	85 c0                	test   %eax,%eax
  802055:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80205a:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80205d:	83 ec 0c             	sub    $0xc,%esp
  802060:	50                   	push   %eax
  802061:	e8 42 ed ff ff       	call   800da8 <sys_ipc_recv>
  802066:	83 c4 10             	add    $0x10,%esp
  802069:	85 c0                	test   %eax,%eax
  80206b:	75 2b                	jne    802098 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80206d:	85 f6                	test   %esi,%esi
  80206f:	74 0a                	je     80207b <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802071:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802076:	8b 40 74             	mov    0x74(%eax),%eax
  802079:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80207b:	85 db                	test   %ebx,%ebx
  80207d:	74 0a                	je     802089 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80207f:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802084:	8b 40 78             	mov    0x78(%eax),%eax
  802087:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802089:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80208e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802098:	85 f6                	test   %esi,%esi
  80209a:	74 06                	je     8020a2 <ipc_recv+0x61>
  80209c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020a2:	85 db                	test   %ebx,%ebx
  8020a4:	74 eb                	je     802091 <ipc_recv+0x50>
  8020a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020ac:	eb e3                	jmp    802091 <ipc_recv+0x50>

008020ae <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ae:	f3 0f 1e fb          	endbr32 
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	57                   	push   %edi
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	83 ec 0c             	sub    $0xc,%esp
  8020bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8020c4:	85 db                	test   %ebx,%ebx
  8020c6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020cb:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020ce:	ff 75 14             	pushl  0x14(%ebp)
  8020d1:	53                   	push   %ebx
  8020d2:	56                   	push   %esi
  8020d3:	57                   	push   %edi
  8020d4:	e8 a8 ec ff ff       	call   800d81 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020df:	75 07                	jne    8020e8 <ipc_send+0x3a>
			sys_yield();
  8020e1:	e8 99 eb ff ff       	call   800c7f <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020e6:	eb e6                	jmp    8020ce <ipc_send+0x20>
		}
		else if (ret == 0)
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	75 08                	jne    8020f4 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8020ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8020f4:	50                   	push   %eax
  8020f5:	68 67 29 80 00       	push   $0x802967
  8020fa:	6a 48                	push   $0x48
  8020fc:	68 75 29 80 00       	push   $0x802975
  802101:	e8 42 e0 ff ff       	call   800148 <_panic>

00802106 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802106:	f3 0f 1e fb          	endbr32 
  80210a:	55                   	push   %ebp
  80210b:	89 e5                	mov    %esp,%ebp
  80210d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802110:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802115:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802118:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80211e:	8b 52 50             	mov    0x50(%edx),%edx
  802121:	39 ca                	cmp    %ecx,%edx
  802123:	74 11                	je     802136 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802125:	83 c0 01             	add    $0x1,%eax
  802128:	3d 00 04 00 00       	cmp    $0x400,%eax
  80212d:	75 e6                	jne    802115 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80212f:	b8 00 00 00 00       	mov    $0x0,%eax
  802134:	eb 0b                	jmp    802141 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802136:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802139:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80213e:	8b 40 48             	mov    0x48(%eax),%eax
}
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802143:	f3 0f 1e fb          	endbr32 
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214d:	89 c2                	mov    %eax,%edx
  80214f:	c1 ea 16             	shr    $0x16,%edx
  802152:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802159:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80215e:	f6 c1 01             	test   $0x1,%cl
  802161:	74 1c                	je     80217f <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802163:	c1 e8 0c             	shr    $0xc,%eax
  802166:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80216d:	a8 01                	test   $0x1,%al
  80216f:	74 0e                	je     80217f <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802171:	c1 e8 0c             	shr    $0xc,%eax
  802174:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80217b:	ef 
  80217c:	0f b7 d2             	movzwl %dx,%edx
}
  80217f:	89 d0                	mov    %edx,%eax
  802181:	5d                   	pop    %ebp
  802182:	c3                   	ret    
  802183:	66 90                	xchg   %ax,%ax
  802185:	66 90                	xchg   %ax,%ax
  802187:	66 90                	xchg   %ax,%ax
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__udivdi3>:
  802190:	f3 0f 1e fb          	endbr32 
  802194:	55                   	push   %ebp
  802195:	57                   	push   %edi
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
  802198:	83 ec 1c             	sub    $0x1c,%esp
  80219b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021ab:	85 d2                	test   %edx,%edx
  8021ad:	75 19                	jne    8021c8 <__udivdi3+0x38>
  8021af:	39 f3                	cmp    %esi,%ebx
  8021b1:	76 4d                	jbe    802200 <__udivdi3+0x70>
  8021b3:	31 ff                	xor    %edi,%edi
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	89 f2                	mov    %esi,%edx
  8021b9:	f7 f3                	div    %ebx
  8021bb:	89 fa                	mov    %edi,%edx
  8021bd:	83 c4 1c             	add    $0x1c,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	76 14                	jbe    8021e0 <__udivdi3+0x50>
  8021cc:	31 ff                	xor    %edi,%edi
  8021ce:	31 c0                	xor    %eax,%eax
  8021d0:	89 fa                	mov    %edi,%edx
  8021d2:	83 c4 1c             	add    $0x1c,%esp
  8021d5:	5b                   	pop    %ebx
  8021d6:	5e                   	pop    %esi
  8021d7:	5f                   	pop    %edi
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    
  8021da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e0:	0f bd fa             	bsr    %edx,%edi
  8021e3:	83 f7 1f             	xor    $0x1f,%edi
  8021e6:	75 48                	jne    802230 <__udivdi3+0xa0>
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	72 06                	jb     8021f2 <__udivdi3+0x62>
  8021ec:	31 c0                	xor    %eax,%eax
  8021ee:	39 eb                	cmp    %ebp,%ebx
  8021f0:	77 de                	ja     8021d0 <__udivdi3+0x40>
  8021f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f7:	eb d7                	jmp    8021d0 <__udivdi3+0x40>
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d9                	mov    %ebx,%ecx
  802202:	85 db                	test   %ebx,%ebx
  802204:	75 0b                	jne    802211 <__udivdi3+0x81>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f3                	div    %ebx
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	31 d2                	xor    %edx,%edx
  802213:	89 f0                	mov    %esi,%eax
  802215:	f7 f1                	div    %ecx
  802217:	89 c6                	mov    %eax,%esi
  802219:	89 e8                	mov    %ebp,%eax
  80221b:	89 f7                	mov    %esi,%edi
  80221d:	f7 f1                	div    %ecx
  80221f:	89 fa                	mov    %edi,%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f9                	mov    %edi,%ecx
  802232:	b8 20 00 00 00       	mov    $0x20,%eax
  802237:	29 f8                	sub    %edi,%eax
  802239:	d3 e2                	shl    %cl,%edx
  80223b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80223f:	89 c1                	mov    %eax,%ecx
  802241:	89 da                	mov    %ebx,%edx
  802243:	d3 ea                	shr    %cl,%edx
  802245:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802249:	09 d1                	or     %edx,%ecx
  80224b:	89 f2                	mov    %esi,%edx
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e3                	shl    %cl,%ebx
  802255:	89 c1                	mov    %eax,%ecx
  802257:	d3 ea                	shr    %cl,%edx
  802259:	89 f9                	mov    %edi,%ecx
  80225b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80225f:	89 eb                	mov    %ebp,%ebx
  802261:	d3 e6                	shl    %cl,%esi
  802263:	89 c1                	mov    %eax,%ecx
  802265:	d3 eb                	shr    %cl,%ebx
  802267:	09 de                	or     %ebx,%esi
  802269:	89 f0                	mov    %esi,%eax
  80226b:	f7 74 24 08          	divl   0x8(%esp)
  80226f:	89 d6                	mov    %edx,%esi
  802271:	89 c3                	mov    %eax,%ebx
  802273:	f7 64 24 0c          	mull   0xc(%esp)
  802277:	39 d6                	cmp    %edx,%esi
  802279:	72 15                	jb     802290 <__udivdi3+0x100>
  80227b:	89 f9                	mov    %edi,%ecx
  80227d:	d3 e5                	shl    %cl,%ebp
  80227f:	39 c5                	cmp    %eax,%ebp
  802281:	73 04                	jae    802287 <__udivdi3+0xf7>
  802283:	39 d6                	cmp    %edx,%esi
  802285:	74 09                	je     802290 <__udivdi3+0x100>
  802287:	89 d8                	mov    %ebx,%eax
  802289:	31 ff                	xor    %edi,%edi
  80228b:	e9 40 ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  802290:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802293:	31 ff                	xor    %edi,%edi
  802295:	e9 36 ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	f3 0f 1e fb          	endbr32 
  8022a4:	55                   	push   %ebp
  8022a5:	57                   	push   %edi
  8022a6:	56                   	push   %esi
  8022a7:	53                   	push   %ebx
  8022a8:	83 ec 1c             	sub    $0x1c,%esp
  8022ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	75 19                	jne    8022d8 <__umoddi3+0x38>
  8022bf:	39 df                	cmp    %ebx,%edi
  8022c1:	76 5d                	jbe    802320 <__umoddi3+0x80>
  8022c3:	89 f0                	mov    %esi,%eax
  8022c5:	89 da                	mov    %ebx,%edx
  8022c7:	f7 f7                	div    %edi
  8022c9:	89 d0                	mov    %edx,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	39 d8                	cmp    %ebx,%eax
  8022dc:	76 12                	jbe    8022f0 <__umoddi3+0x50>
  8022de:	89 f0                	mov    %esi,%eax
  8022e0:	89 da                	mov    %ebx,%edx
  8022e2:	83 c4 1c             	add    $0x1c,%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    
  8022ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f0:	0f bd e8             	bsr    %eax,%ebp
  8022f3:	83 f5 1f             	xor    $0x1f,%ebp
  8022f6:	75 50                	jne    802348 <__umoddi3+0xa8>
  8022f8:	39 d8                	cmp    %ebx,%eax
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	89 d9                	mov    %ebx,%ecx
  802302:	39 f7                	cmp    %esi,%edi
  802304:	0f 86 d6 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  80230a:	89 d0                	mov    %edx,%eax
  80230c:	89 ca                	mov    %ecx,%edx
  80230e:	83 c4 1c             	add    $0x1c,%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5f                   	pop    %edi
  802314:	5d                   	pop    %ebp
  802315:	c3                   	ret    
  802316:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	89 fd                	mov    %edi,%ebp
  802322:	85 ff                	test   %edi,%edi
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 d8                	mov    %ebx,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 f0                	mov    %esi,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	31 d2                	xor    %edx,%edx
  80233f:	eb 8c                	jmp    8022cd <__umoddi3+0x2d>
  802341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	ba 20 00 00 00       	mov    $0x20,%edx
  80234f:	29 ea                	sub    %ebp,%edx
  802351:	d3 e0                	shl    %cl,%eax
  802353:	89 44 24 08          	mov    %eax,0x8(%esp)
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 f8                	mov    %edi,%eax
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802361:	89 54 24 04          	mov    %edx,0x4(%esp)
  802365:	8b 54 24 04          	mov    0x4(%esp),%edx
  802369:	09 c1                	or     %eax,%ecx
  80236b:	89 d8                	mov    %ebx,%eax
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 e9                	mov    %ebp,%ecx
  802373:	d3 e7                	shl    %cl,%edi
  802375:	89 d1                	mov    %edx,%ecx
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80237f:	d3 e3                	shl    %cl,%ebx
  802381:	89 c7                	mov    %eax,%edi
  802383:	89 d1                	mov    %edx,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	89 fa                	mov    %edi,%edx
  80238d:	d3 e6                	shl    %cl,%esi
  80238f:	09 d8                	or     %ebx,%eax
  802391:	f7 74 24 08          	divl   0x8(%esp)
  802395:	89 d1                	mov    %edx,%ecx
  802397:	89 f3                	mov    %esi,%ebx
  802399:	f7 64 24 0c          	mull   0xc(%esp)
  80239d:	89 c6                	mov    %eax,%esi
  80239f:	89 d7                	mov    %edx,%edi
  8023a1:	39 d1                	cmp    %edx,%ecx
  8023a3:	72 06                	jb     8023ab <__umoddi3+0x10b>
  8023a5:	75 10                	jne    8023b7 <__umoddi3+0x117>
  8023a7:	39 c3                	cmp    %eax,%ebx
  8023a9:	73 0c                	jae    8023b7 <__umoddi3+0x117>
  8023ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023b3:	89 d7                	mov    %edx,%edi
  8023b5:	89 c6                	mov    %eax,%esi
  8023b7:	89 ca                	mov    %ecx,%edx
  8023b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023be:	29 f3                	sub    %esi,%ebx
  8023c0:	19 fa                	sbb    %edi,%edx
  8023c2:	89 d0                	mov    %edx,%eax
  8023c4:	d3 e0                	shl    %cl,%eax
  8023c6:	89 e9                	mov    %ebp,%ecx
  8023c8:	d3 eb                	shr    %cl,%ebx
  8023ca:	d3 ea                	shr    %cl,%edx
  8023cc:	09 d8                	or     %ebx,%eax
  8023ce:	83 c4 1c             	add    $0x1c,%esp
  8023d1:	5b                   	pop    %ebx
  8023d2:	5e                   	pop    %esi
  8023d3:	5f                   	pop    %edi
  8023d4:	5d                   	pop    %ebp
  8023d5:	c3                   	ret    
  8023d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 fe                	sub    %edi,%esi
  8023e2:	19 c3                	sbb    %eax,%ebx
  8023e4:	89 f2                	mov    %esi,%edx
  8023e6:	89 d9                	mov    %ebx,%ecx
  8023e8:	e9 1d ff ff ff       	jmp    80230a <__umoddi3+0x6a>
