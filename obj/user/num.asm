
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 58 01 00 00       	call   800189 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 10             	sub    $0x10,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800042:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800045:	eb 43                	jmp    80008a <num+0x57>
		if (bol) {
			printf("%5d ", ++line);
  800047:	a1 00 40 80 00       	mov    0x804000,%eax
  80004c:	83 c0 01             	add    $0x1,%eax
  80004f:	a3 00 40 80 00       	mov    %eax,0x804000
  800054:	83 ec 08             	sub    $0x8,%esp
  800057:	50                   	push   %eax
  800058:	68 c0 25 80 00       	push   $0x8025c0
  80005d:	e8 df 17 00 00       	call   801841 <printf>
			bol = 0;
  800062:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800069:	00 00 00 
  80006c:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	6a 01                	push   $0x1
  800074:	53                   	push   %ebx
  800075:	6a 01                	push   $0x1
  800077:	e8 49 12 00 00       	call   8012c5 <write>
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	83 f8 01             	cmp    $0x1,%eax
  800082:	75 24                	jne    8000a8 <num+0x75>
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
  800084:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  800088:	74 36                	je     8000c0 <num+0x8d>
	while ((n = read(f, &c, 1)) > 0) {
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 01                	push   $0x1
  80008f:	53                   	push   %ebx
  800090:	56                   	push   %esi
  800091:	e8 59 11 00 00       	call   8011ef <read>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	7e 2f                	jle    8000cc <num+0x99>
		if (bol) {
  80009d:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  8000a4:	74 c9                	je     80006f <num+0x3c>
  8000a6:	eb 9f                	jmp    800047 <num+0x14>
			panic("write error copying %s: %e", s, r);
  8000a8:	83 ec 0c             	sub    $0xc,%esp
  8000ab:	50                   	push   %eax
  8000ac:	ff 75 0c             	pushl  0xc(%ebp)
  8000af:	68 c5 25 80 00       	push   $0x8025c5
  8000b4:	6a 13                	push   $0x13
  8000b6:	68 e0 25 80 00       	push   $0x8025e0
  8000bb:	e8 31 01 00 00       	call   8001f1 <_panic>
			bol = 1;
  8000c0:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000c7:	00 00 00 
  8000ca:	eb be                	jmp    80008a <num+0x57>
	}
	if (n < 0)
  8000cc:	78 07                	js     8000d5 <num+0xa2>
		panic("error reading %s: %e", s, n);
}
  8000ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    
		panic("error reading %s: %e", s, n);
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	50                   	push   %eax
  8000d9:	ff 75 0c             	pushl  0xc(%ebp)
  8000dc:	68 eb 25 80 00       	push   $0x8025eb
  8000e1:	6a 18                	push   $0x18
  8000e3:	68 e0 25 80 00       	push   $0x8025e0
  8000e8:	e8 04 01 00 00       	call   8001f1 <_panic>

008000ed <umain>:

void
umain(int argc, char **argv)
{
  8000ed:	f3 0f 1e fb          	endbr32 
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000fa:	c7 05 04 30 80 00 00 	movl   $0x802600,0x803004
  800101:	26 80 00 
	if (argc == 1)
  800104:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800108:	74 46                	je     800150 <umain+0x63>
  80010a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010d:	8d 70 04             	lea    0x4(%eax),%esi
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800110:	bf 01 00 00 00       	mov    $0x1,%edi
  800115:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800118:	7d 48                	jge    800162 <umain+0x75>
			f = open(argv[i], O_RDONLY);
  80011a:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	6a 00                	push   $0x0
  800122:	ff 36                	pushl  (%esi)
  800124:	e8 61 15 00 00       	call   80168a <open>
  800129:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	85 c0                	test   %eax,%eax
  800130:	78 3d                	js     80016f <umain+0x82>
				panic("can't open %s: %e", argv[i], f);
			else {
				num(f, argv[i]);
  800132:	83 ec 08             	sub    $0x8,%esp
  800135:	ff 36                	pushl  (%esi)
  800137:	50                   	push   %eax
  800138:	e8 f6 fe ff ff       	call   800033 <num>
				close(f);
  80013d:	89 1c 24             	mov    %ebx,(%esp)
  800140:	e8 60 0f 00 00       	call   8010a5 <close>
		for (i = 1; i < argc; i++) {
  800145:	83 c7 01             	add    $0x1,%edi
  800148:	83 c6 04             	add    $0x4,%esi
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	eb c5                	jmp    800115 <umain+0x28>
		num(0, "<stdin>");
  800150:	83 ec 08             	sub    $0x8,%esp
  800153:	68 04 26 80 00       	push   $0x802604
  800158:	6a 00                	push   $0x0
  80015a:	e8 d4 fe ff ff       	call   800033 <num>
  80015f:	83 c4 10             	add    $0x10,%esp
			}
		}
	exit();
  800162:	e8 6c 00 00 00       	call   8001d3 <exit>
}
  800167:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
				panic("can't open %s: %e", argv[i], f);
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	50                   	push   %eax
  800173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800176:	ff 30                	pushl  (%eax)
  800178:	68 0c 26 80 00       	push   $0x80260c
  80017d:	6a 27                	push   $0x27
  80017f:	68 e0 25 80 00       	push   $0x8025e0
  800184:	e8 68 00 00 00       	call   8001f1 <_panic>

00800189 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800189:	f3 0f 1e fb          	endbr32 
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800195:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800198:	e8 68 0b 00 00       	call   800d05 <sys_getenvid>
  80019d:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001a2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001aa:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001af:	85 db                	test   %ebx,%ebx
  8001b1:	7e 07                	jle    8001ba <libmain+0x31>
		binaryname = argv[0];
  8001b3:	8b 06                	mov    (%esi),%eax
  8001b5:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	e8 29 ff ff ff       	call   8000ed <umain>

	// exit gracefully
	exit();
  8001c4:	e8 0a 00 00 00       	call   8001d3 <exit>
}
  8001c9:	83 c4 10             	add    $0x10,%esp
  8001cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d3:	f3 0f 1e fb          	endbr32 
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8001dd:	e8 f4 0e 00 00       	call   8010d6 <close_all>
	sys_env_destroy(0);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	6a 00                	push   $0x0
  8001e7:	e8 f5 0a 00 00       	call   800ce1 <sys_env_destroy>
}
  8001ec:	83 c4 10             	add    $0x10,%esp
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f1:	f3 0f 1e fb          	endbr32 
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	56                   	push   %esi
  8001f9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001fa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fd:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800203:	e8 fd 0a 00 00       	call   800d05 <sys_getenvid>
  800208:	83 ec 0c             	sub    $0xc,%esp
  80020b:	ff 75 0c             	pushl  0xc(%ebp)
  80020e:	ff 75 08             	pushl  0x8(%ebp)
  800211:	56                   	push   %esi
  800212:	50                   	push   %eax
  800213:	68 28 26 80 00       	push   $0x802628
  800218:	e8 bb 00 00 00       	call   8002d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021d:	83 c4 18             	add    $0x18,%esp
  800220:	53                   	push   %ebx
  800221:	ff 75 10             	pushl  0x10(%ebp)
  800224:	e8 5a 00 00 00       	call   800283 <vcprintf>
	cprintf("\n");
  800229:	c7 04 24 b4 2a 80 00 	movl   $0x802ab4,(%esp)
  800230:	e8 a3 00 00 00       	call   8002d8 <cprintf>
  800235:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800238:	cc                   	int3   
  800239:	eb fd                	jmp    800238 <_panic+0x47>

0080023b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023b:	f3 0f 1e fb          	endbr32 
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	53                   	push   %ebx
  800243:	83 ec 04             	sub    $0x4,%esp
  800246:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800249:	8b 13                	mov    (%ebx),%edx
  80024b:	8d 42 01             	lea    0x1(%edx),%eax
  80024e:	89 03                	mov    %eax,(%ebx)
  800250:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800253:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800257:	3d ff 00 00 00       	cmp    $0xff,%eax
  80025c:	74 09                	je     800267 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80025e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800265:	c9                   	leave  
  800266:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	68 ff 00 00 00       	push   $0xff
  80026f:	8d 43 08             	lea    0x8(%ebx),%eax
  800272:	50                   	push   %eax
  800273:	e8 24 0a 00 00       	call   800c9c <sys_cputs>
		b->idx = 0;
  800278:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	eb db                	jmp    80025e <putch+0x23>

00800283 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800283:	f3 0f 1e fb          	endbr32 
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800290:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800297:	00 00 00 
	b.cnt = 0;
  80029a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a4:	ff 75 0c             	pushl  0xc(%ebp)
  8002a7:	ff 75 08             	pushl  0x8(%ebp)
  8002aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	68 3b 02 80 00       	push   $0x80023b
  8002b6:	e8 20 01 00 00       	call   8003db <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bb:	83 c4 08             	add    $0x8,%esp
  8002be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ca:	50                   	push   %eax
  8002cb:	e8 cc 09 00 00       	call   800c9c <sys_cputs>

	return b.cnt;
}
  8002d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d8:	f3 0f 1e fb          	endbr32 
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e5:	50                   	push   %eax
  8002e6:	ff 75 08             	pushl  0x8(%ebp)
  8002e9:	e8 95 ff ff ff       	call   800283 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 1c             	sub    $0x1c,%esp
  8002f9:	89 c7                	mov    %eax,%edi
  8002fb:	89 d6                	mov    %edx,%esi
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	8b 55 0c             	mov    0xc(%ebp),%edx
  800303:	89 d1                	mov    %edx,%ecx
  800305:	89 c2                	mov    %eax,%edx
  800307:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800313:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800316:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80031d:	39 c2                	cmp    %eax,%edx
  80031f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800322:	72 3e                	jb     800362 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 18             	pushl  0x18(%ebp)
  80032a:	83 eb 01             	sub    $0x1,%ebx
  80032d:	53                   	push   %ebx
  80032e:	50                   	push   %eax
  80032f:	83 ec 08             	sub    $0x8,%esp
  800332:	ff 75 e4             	pushl  -0x1c(%ebp)
  800335:	ff 75 e0             	pushl  -0x20(%ebp)
  800338:	ff 75 dc             	pushl  -0x24(%ebp)
  80033b:	ff 75 d8             	pushl  -0x28(%ebp)
  80033e:	e8 0d 20 00 00       	call   802350 <__udivdi3>
  800343:	83 c4 18             	add    $0x18,%esp
  800346:	52                   	push   %edx
  800347:	50                   	push   %eax
  800348:	89 f2                	mov    %esi,%edx
  80034a:	89 f8                	mov    %edi,%eax
  80034c:	e8 9f ff ff ff       	call   8002f0 <printnum>
  800351:	83 c4 20             	add    $0x20,%esp
  800354:	eb 13                	jmp    800369 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	56                   	push   %esi
  80035a:	ff 75 18             	pushl  0x18(%ebp)
  80035d:	ff d7                	call   *%edi
  80035f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800362:	83 eb 01             	sub    $0x1,%ebx
  800365:	85 db                	test   %ebx,%ebx
  800367:	7f ed                	jg     800356 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	56                   	push   %esi
  80036d:	83 ec 04             	sub    $0x4,%esp
  800370:	ff 75 e4             	pushl  -0x1c(%ebp)
  800373:	ff 75 e0             	pushl  -0x20(%ebp)
  800376:	ff 75 dc             	pushl  -0x24(%ebp)
  800379:	ff 75 d8             	pushl  -0x28(%ebp)
  80037c:	e8 df 20 00 00       	call   802460 <__umoddi3>
  800381:	83 c4 14             	add    $0x14,%esp
  800384:	0f be 80 4b 26 80 00 	movsbl 0x80264b(%eax),%eax
  80038b:	50                   	push   %eax
  80038c:	ff d7                	call   *%edi
}
  80038e:	83 c4 10             	add    $0x10,%esp
  800391:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800394:	5b                   	pop    %ebx
  800395:	5e                   	pop    %esi
  800396:	5f                   	pop    %edi
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800399:	f3 0f 1e fb          	endbr32 
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003a7:	8b 10                	mov    (%eax),%edx
  8003a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ac:	73 0a                	jae    8003b8 <sprintputch+0x1f>
		*b->buf++ = ch;
  8003ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003b1:	89 08                	mov    %ecx,(%eax)
  8003b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b6:	88 02                	mov    %al,(%edx)
}
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <printfmt>:
{
  8003ba:	f3 0f 1e fb          	endbr32 
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003c7:	50                   	push   %eax
  8003c8:	ff 75 10             	pushl  0x10(%ebp)
  8003cb:	ff 75 0c             	pushl  0xc(%ebp)
  8003ce:	ff 75 08             	pushl  0x8(%ebp)
  8003d1:	e8 05 00 00 00       	call   8003db <vprintfmt>
}
  8003d6:	83 c4 10             	add    $0x10,%esp
  8003d9:	c9                   	leave  
  8003da:	c3                   	ret    

008003db <vprintfmt>:
{
  8003db:	f3 0f 1e fb          	endbr32 
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	57                   	push   %edi
  8003e3:	56                   	push   %esi
  8003e4:	53                   	push   %ebx
  8003e5:	83 ec 3c             	sub    $0x3c,%esp
  8003e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f1:	e9 8e 03 00 00       	jmp    800784 <vprintfmt+0x3a9>
		padc = ' ';
  8003f6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003fa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800401:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800408:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80040f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8d 47 01             	lea    0x1(%edi),%eax
  800417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041a:	0f b6 17             	movzbl (%edi),%edx
  80041d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800420:	3c 55                	cmp    $0x55,%al
  800422:	0f 87 df 03 00 00    	ja     800807 <vprintfmt+0x42c>
  800428:	0f b6 c0             	movzbl %al,%eax
  80042b:	3e ff 24 85 80 27 80 	notrack jmp *0x802780(,%eax,4)
  800432:	00 
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800436:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80043a:	eb d8                	jmp    800414 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800443:	eb cf                	jmp    800414 <vprintfmt+0x39>
  800445:	0f b6 d2             	movzbl %dl,%edx
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80044b:	b8 00 00 00 00       	mov    $0x0,%eax
  800450:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800453:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800456:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80045a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80045d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800460:	83 f9 09             	cmp    $0x9,%ecx
  800463:	77 55                	ja     8004ba <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800465:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800468:	eb e9                	jmp    800453 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 40 04             	lea    0x4(%eax),%eax
  800478:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	79 90                	jns    800414 <vprintfmt+0x39>
				width = precision, precision = -1;
  800484:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800487:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800491:	eb 81                	jmp    800414 <vprintfmt+0x39>
  800493:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800496:	85 c0                	test   %eax,%eax
  800498:	ba 00 00 00 00       	mov    $0x0,%edx
  80049d:	0f 49 d0             	cmovns %eax,%edx
  8004a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004a6:	e9 69 ff ff ff       	jmp    800414 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004ae:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004b5:	e9 5a ff ff ff       	jmp    800414 <vprintfmt+0x39>
  8004ba:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c0:	eb bc                	jmp    80047e <vprintfmt+0xa3>
			lflag++;
  8004c2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004c8:	e9 47 ff ff ff       	jmp    800414 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 78 04             	lea    0x4(%eax),%edi
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	ff 30                	pushl  (%eax)
  8004d9:	ff d6                	call   *%esi
			break;
  8004db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004de:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004e1:	e9 9b 02 00 00       	jmp    800781 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 78 04             	lea    0x4(%eax),%edi
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	99                   	cltd   
  8004ef:	31 d0                	xor    %edx,%eax
  8004f1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 f8 0f             	cmp    $0xf,%eax
  8004f6:	7f 23                	jg     80051b <vprintfmt+0x140>
  8004f8:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	74 18                	je     80051b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800503:	52                   	push   %edx
  800504:	68 e9 29 80 00       	push   $0x8029e9
  800509:	53                   	push   %ebx
  80050a:	56                   	push   %esi
  80050b:	e8 aa fe ff ff       	call   8003ba <printfmt>
  800510:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800513:	89 7d 14             	mov    %edi,0x14(%ebp)
  800516:	e9 66 02 00 00       	jmp    800781 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80051b:	50                   	push   %eax
  80051c:	68 63 26 80 00       	push   $0x802663
  800521:	53                   	push   %ebx
  800522:	56                   	push   %esi
  800523:	e8 92 fe ff ff       	call   8003ba <printfmt>
  800528:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80052b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80052e:	e9 4e 02 00 00       	jmp    800781 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	83 c0 04             	add    $0x4,%eax
  800539:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800541:	85 d2                	test   %edx,%edx
  800543:	b8 5c 26 80 00       	mov    $0x80265c,%eax
  800548:	0f 45 c2             	cmovne %edx,%eax
  80054b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80054e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800552:	7e 06                	jle    80055a <vprintfmt+0x17f>
  800554:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800558:	75 0d                	jne    800567 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80055d:	89 c7                	mov    %eax,%edi
  80055f:	03 45 e0             	add    -0x20(%ebp),%eax
  800562:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800565:	eb 55                	jmp    8005bc <vprintfmt+0x1e1>
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	ff 75 d8             	pushl  -0x28(%ebp)
  80056d:	ff 75 cc             	pushl  -0x34(%ebp)
  800570:	e8 46 03 00 00       	call   8008bb <strnlen>
  800575:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800578:	29 c2                	sub    %eax,%edx
  80057a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800582:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800586:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	85 ff                	test   %edi,%edi
  80058b:	7e 11                	jle    80059e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	53                   	push   %ebx
  800591:	ff 75 e0             	pushl  -0x20(%ebp)
  800594:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800596:	83 ef 01             	sub    $0x1,%edi
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	eb eb                	jmp    800589 <vprintfmt+0x1ae>
  80059e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005a1:	85 d2                	test   %edx,%edx
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	0f 49 c2             	cmovns %edx,%eax
  8005ab:	29 c2                	sub    %eax,%edx
  8005ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b0:	eb a8                	jmp    80055a <vprintfmt+0x17f>
					putch(ch, putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	52                   	push   %edx
  8005b7:	ff d6                	call   *%esi
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	83 c7 01             	add    $0x1,%edi
  8005c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005c8:	0f be d0             	movsbl %al,%edx
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	74 4b                	je     80061a <vprintfmt+0x23f>
  8005cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d3:	78 06                	js     8005db <vprintfmt+0x200>
  8005d5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d9:	78 1e                	js     8005f9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8005db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005df:	74 d1                	je     8005b2 <vprintfmt+0x1d7>
  8005e1:	0f be c0             	movsbl %al,%eax
  8005e4:	83 e8 20             	sub    $0x20,%eax
  8005e7:	83 f8 5e             	cmp    $0x5e,%eax
  8005ea:	76 c6                	jbe    8005b2 <vprintfmt+0x1d7>
					putch('?', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 3f                	push   $0x3f
  8005f2:	ff d6                	call   *%esi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	eb c3                	jmp    8005bc <vprintfmt+0x1e1>
  8005f9:	89 cf                	mov    %ecx,%edi
  8005fb:	eb 0e                	jmp    80060b <vprintfmt+0x230>
				putch(' ', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 20                	push   $0x20
  800603:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800605:	83 ef 01             	sub    $0x1,%edi
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	85 ff                	test   %edi,%edi
  80060d:	7f ee                	jg     8005fd <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80060f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
  800615:	e9 67 01 00 00       	jmp    800781 <vprintfmt+0x3a6>
  80061a:	89 cf                	mov    %ecx,%edi
  80061c:	eb ed                	jmp    80060b <vprintfmt+0x230>
	if (lflag >= 2)
  80061e:	83 f9 01             	cmp    $0x1,%ecx
  800621:	7f 1b                	jg     80063e <vprintfmt+0x263>
	else if (lflag)
  800623:	85 c9                	test   %ecx,%ecx
  800625:	74 63                	je     80068a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	99                   	cltd   
  800630:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 40 04             	lea    0x4(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
  80063c:	eb 17                	jmp    800655 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 50 04             	mov    0x4(%eax),%edx
  800644:	8b 00                	mov    (%eax),%eax
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 40 08             	lea    0x8(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800655:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800658:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80065b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800660:	85 c9                	test   %ecx,%ecx
  800662:	0f 89 ff 00 00 00    	jns    800767 <vprintfmt+0x38c>
				putch('-', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 2d                	push   $0x2d
  80066e:	ff d6                	call   *%esi
				num = -(long long) num;
  800670:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800673:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800676:	f7 da                	neg    %edx
  800678:	83 d1 00             	adc    $0x0,%ecx
  80067b:	f7 d9                	neg    %ecx
  80067d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800680:	b8 0a 00 00 00       	mov    $0xa,%eax
  800685:	e9 dd 00 00 00       	jmp    800767 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800692:	99                   	cltd   
  800693:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
  80069f:	eb b4                	jmp    800655 <vprintfmt+0x27a>
	if (lflag >= 2)
  8006a1:	83 f9 01             	cmp    $0x1,%ecx
  8006a4:	7f 1e                	jg     8006c4 <vprintfmt+0x2e9>
	else if (lflag)
  8006a6:	85 c9                	test   %ecx,%ecx
  8006a8:	74 32                	je     8006dc <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ba:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8006bf:	e9 a3 00 00 00       	jmp    800767 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cc:	8d 40 08             	lea    0x8(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006d7:	e9 8b 00 00 00       	jmp    800767 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ec:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006f1:	eb 74                	jmp    800767 <vprintfmt+0x38c>
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7f 1b                	jg     800713 <vprintfmt+0x338>
	else if (lflag)
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	74 2c                	je     800728 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	b9 00 00 00 00       	mov    $0x0,%ecx
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80070c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800711:	eb 54                	jmp    800767 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	8b 48 04             	mov    0x4(%eax),%ecx
  80071b:	8d 40 08             	lea    0x8(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800721:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800726:	eb 3f                	jmp    800767 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800738:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80073d:	eb 28                	jmp    800767 <vprintfmt+0x38c>
			putch('0', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	53                   	push   %ebx
  800743:	6a 30                	push   $0x30
  800745:	ff d6                	call   *%esi
			putch('x', putdat);
  800747:	83 c4 08             	add    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 78                	push   $0x78
  80074d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 10                	mov    (%eax),%edx
  800754:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800759:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80075c:	8d 40 04             	lea    0x4(%eax),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800762:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800767:	83 ec 0c             	sub    $0xc,%esp
  80076a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80076e:	57                   	push   %edi
  80076f:	ff 75 e0             	pushl  -0x20(%ebp)
  800772:	50                   	push   %eax
  800773:	51                   	push   %ecx
  800774:	52                   	push   %edx
  800775:	89 da                	mov    %ebx,%edx
  800777:	89 f0                	mov    %esi,%eax
  800779:	e8 72 fb ff ff       	call   8002f0 <printnum>
			break;
  80077e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800784:	83 c7 01             	add    $0x1,%edi
  800787:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078b:	83 f8 25             	cmp    $0x25,%eax
  80078e:	0f 84 62 fc ff ff    	je     8003f6 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800794:	85 c0                	test   %eax,%eax
  800796:	0f 84 8b 00 00 00    	je     800827 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	50                   	push   %eax
  8007a1:	ff d6                	call   *%esi
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb dc                	jmp    800784 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8007a8:	83 f9 01             	cmp    $0x1,%ecx
  8007ab:	7f 1b                	jg     8007c8 <vprintfmt+0x3ed>
	else if (lflag)
  8007ad:	85 c9                	test   %ecx,%ecx
  8007af:	74 2c                	je     8007dd <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8b 10                	mov    (%eax),%edx
  8007b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bb:	8d 40 04             	lea    0x4(%eax),%eax
  8007be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8007c6:	eb 9f                	jmp    800767 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 10                	mov    (%eax),%edx
  8007cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d0:	8d 40 08             	lea    0x8(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007db:	eb 8a                	jmp    800767 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ed:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007f2:	e9 70 ff ff ff       	jmp    800767 <vprintfmt+0x38c>
			putch(ch, putdat);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	6a 25                	push   $0x25
  8007fd:	ff d6                	call   *%esi
			break;
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	e9 7a ff ff ff       	jmp    800781 <vprintfmt+0x3a6>
			putch('%', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 25                	push   $0x25
  80080d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	89 f8                	mov    %edi,%eax
  800814:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800818:	74 05                	je     80081f <vprintfmt+0x444>
  80081a:	83 e8 01             	sub    $0x1,%eax
  80081d:	eb f5                	jmp    800814 <vprintfmt+0x439>
  80081f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800822:	e9 5a ff ff ff       	jmp    800781 <vprintfmt+0x3a6>
}
  800827:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082a:	5b                   	pop    %ebx
  80082b:	5e                   	pop    %esi
  80082c:	5f                   	pop    %edi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082f:	f3 0f 1e fb          	endbr32 
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	83 ec 18             	sub    $0x18,%esp
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800842:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800846:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800849:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800850:	85 c0                	test   %eax,%eax
  800852:	74 26                	je     80087a <vsnprintf+0x4b>
  800854:	85 d2                	test   %edx,%edx
  800856:	7e 22                	jle    80087a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800858:	ff 75 14             	pushl  0x14(%ebp)
  80085b:	ff 75 10             	pushl  0x10(%ebp)
  80085e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800861:	50                   	push   %eax
  800862:	68 99 03 80 00       	push   $0x800399
  800867:	e8 6f fb ff ff       	call   8003db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 c4 10             	add    $0x10,%esp
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    
		return -E_INVAL;
  80087a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087f:	eb f7                	jmp    800878 <vsnprintf+0x49>

00800881 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80088e:	50                   	push   %eax
  80088f:	ff 75 10             	pushl  0x10(%ebp)
  800892:	ff 75 0c             	pushl  0xc(%ebp)
  800895:	ff 75 08             	pushl  0x8(%ebp)
  800898:	e8 92 ff ff ff       	call   80082f <vsnprintf>
	va_end(ap);

	return rc;
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b2:	74 05                	je     8008b9 <strlen+0x1a>
		n++;
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	eb f5                	jmp    8008ae <strlen+0xf>
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bb:	f3 0f 1e fb          	endbr32 
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	39 d0                	cmp    %edx,%eax
  8008cf:	74 0d                	je     8008de <strnlen+0x23>
  8008d1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d5:	74 05                	je     8008dc <strnlen+0x21>
		n++;
  8008d7:	83 c0 01             	add    $0x1,%eax
  8008da:	eb f1                	jmp    8008cd <strnlen+0x12>
  8008dc:	89 c2                	mov    %eax,%edx
	return n;
}
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e2:	f3 0f 1e fb          	endbr32 
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008f9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f2                	jne    8008f5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800903:	89 c8                	mov    %ecx,%eax
  800905:	5b                   	pop    %ebx
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800908:	f3 0f 1e fb          	endbr32 
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	83 ec 10             	sub    $0x10,%esp
  800913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800916:	53                   	push   %ebx
  800917:	e8 83 ff ff ff       	call   80089f <strlen>
  80091c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80091f:	ff 75 0c             	pushl  0xc(%ebp)
  800922:	01 d8                	add    %ebx,%eax
  800924:	50                   	push   %eax
  800925:	e8 b8 ff ff ff       	call   8008e2 <strcpy>
	return dst;
}
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800931:	f3 0f 1e fb          	endbr32 
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 75 08             	mov    0x8(%ebp),%esi
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	89 f3                	mov    %esi,%ebx
  800942:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800945:	89 f0                	mov    %esi,%eax
  800947:	39 d8                	cmp    %ebx,%eax
  800949:	74 11                	je     80095c <strncpy+0x2b>
		*dst++ = *src;
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	0f b6 0a             	movzbl (%edx),%ecx
  800951:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800954:	80 f9 01             	cmp    $0x1,%cl
  800957:	83 da ff             	sbb    $0xffffffff,%edx
  80095a:	eb eb                	jmp    800947 <strncpy+0x16>
	}
	return ret;
}
  80095c:	89 f0                	mov    %esi,%eax
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800962:	f3 0f 1e fb          	endbr32 
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 75 08             	mov    0x8(%ebp),%esi
  80096e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800971:	8b 55 10             	mov    0x10(%ebp),%edx
  800974:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800976:	85 d2                	test   %edx,%edx
  800978:	74 21                	je     80099b <strlcpy+0x39>
  80097a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800980:	39 c2                	cmp    %eax,%edx
  800982:	74 14                	je     800998 <strlcpy+0x36>
  800984:	0f b6 19             	movzbl (%ecx),%ebx
  800987:	84 db                	test   %bl,%bl
  800989:	74 0b                	je     800996 <strlcpy+0x34>
			*dst++ = *src++;
  80098b:	83 c1 01             	add    $0x1,%ecx
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	88 5a ff             	mov    %bl,-0x1(%edx)
  800994:	eb ea                	jmp    800980 <strlcpy+0x1e>
  800996:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800998:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099b:	29 f0                	sub    %esi,%eax
}
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a1:	f3 0f 1e fb          	endbr32 
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ae:	0f b6 01             	movzbl (%ecx),%eax
  8009b1:	84 c0                	test   %al,%al
  8009b3:	74 0c                	je     8009c1 <strcmp+0x20>
  8009b5:	3a 02                	cmp    (%edx),%al
  8009b7:	75 08                	jne    8009c1 <strcmp+0x20>
		p++, q++;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	83 c2 01             	add    $0x1,%edx
  8009bf:	eb ed                	jmp    8009ae <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c1:	0f b6 c0             	movzbl %al,%eax
  8009c4:	0f b6 12             	movzbl (%edx),%edx
  8009c7:	29 d0                	sub    %edx,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009cb:	f3 0f 1e fb          	endbr32 
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	53                   	push   %ebx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	89 c3                	mov    %eax,%ebx
  8009db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009de:	eb 06                	jmp    8009e6 <strncmp+0x1b>
		n--, p++, q++;
  8009e0:	83 c0 01             	add    $0x1,%eax
  8009e3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009e6:	39 d8                	cmp    %ebx,%eax
  8009e8:	74 16                	je     800a00 <strncmp+0x35>
  8009ea:	0f b6 08             	movzbl (%eax),%ecx
  8009ed:	84 c9                	test   %cl,%cl
  8009ef:	74 04                	je     8009f5 <strncmp+0x2a>
  8009f1:	3a 0a                	cmp    (%edx),%cl
  8009f3:	74 eb                	je     8009e0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f5:	0f b6 00             	movzbl (%eax),%eax
  8009f8:	0f b6 12             	movzbl (%edx),%edx
  8009fb:	29 d0                	sub    %edx,%eax
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    
		return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
  800a05:	eb f6                	jmp    8009fd <strncmp+0x32>

00800a07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a07:	f3 0f 1e fb          	endbr32 
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 09                	je     800a25 <strchr+0x1e>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	74 0a                	je     800a2a <strchr+0x23>
	for (; *s; s++)
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	eb f0                	jmp    800a15 <strchr+0xe>
			return (char *) s;
	return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800a2c:	f3 0f 1e fb          	endbr32 
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800a36:	6a 78                	push   $0x78
  800a38:	ff 75 08             	pushl  0x8(%ebp)
  800a3b:	e8 c7 ff ff ff       	call   800a07 <strchr>
  800a40:	83 c4 10             	add    $0x10,%esp
  800a43:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800a4b:	eb 0d                	jmp    800a5a <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800a4d:	c1 e0 04             	shl    $0x4,%eax
  800a50:	0f be d2             	movsbl %dl,%edx
  800a53:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	0f b6 11             	movzbl (%ecx),%edx
  800a5d:	84 d2                	test   %dl,%dl
  800a5f:	74 11                	je     800a72 <atox+0x46>
		if (*p>='a'){
  800a61:	80 fa 60             	cmp    $0x60,%dl
  800a64:	7e e7                	jle    800a4d <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800a66:	c1 e0 04             	shl    $0x4,%eax
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800a70:	eb e5                	jmp    800a57 <atox+0x2b>
	}

	return v;

}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a74:	f3 0f 1e fb          	endbr32 
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a82:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a85:	38 ca                	cmp    %cl,%dl
  800a87:	74 09                	je     800a92 <strfind+0x1e>
  800a89:	84 d2                	test   %dl,%dl
  800a8b:	74 05                	je     800a92 <strfind+0x1e>
	for (; *s; s++)
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	eb f0                	jmp    800a82 <strfind+0xe>
			break;
	return (char *) s;
}
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a94:	f3 0f 1e fb          	endbr32 
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa4:	85 c9                	test   %ecx,%ecx
  800aa6:	74 31                	je     800ad9 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa8:	89 f8                	mov    %edi,%eax
  800aaa:	09 c8                	or     %ecx,%eax
  800aac:	a8 03                	test   $0x3,%al
  800aae:	75 23                	jne    800ad3 <memset+0x3f>
		c &= 0xFF;
  800ab0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab4:	89 d3                	mov    %edx,%ebx
  800ab6:	c1 e3 08             	shl    $0x8,%ebx
  800ab9:	89 d0                	mov    %edx,%eax
  800abb:	c1 e0 18             	shl    $0x18,%eax
  800abe:	89 d6                	mov    %edx,%esi
  800ac0:	c1 e6 10             	shl    $0x10,%esi
  800ac3:	09 f0                	or     %esi,%eax
  800ac5:	09 c2                	or     %eax,%edx
  800ac7:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800acc:	89 d0                	mov    %edx,%eax
  800ace:	fc                   	cld    
  800acf:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad1:	eb 06                	jmp    800ad9 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	fc                   	cld    
  800ad7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad9:	89 f8                	mov    %edi,%eax
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae0:	f3 0f 1e fb          	endbr32 
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af2:	39 c6                	cmp    %eax,%esi
  800af4:	73 32                	jae    800b28 <memmove+0x48>
  800af6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af9:	39 c2                	cmp    %eax,%edx
  800afb:	76 2b                	jbe    800b28 <memmove+0x48>
		s += n;
		d += n;
  800afd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b00:	89 fe                	mov    %edi,%esi
  800b02:	09 ce                	or     %ecx,%esi
  800b04:	09 d6                	or     %edx,%esi
  800b06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0c:	75 0e                	jne    800b1c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b0e:	83 ef 04             	sub    $0x4,%edi
  800b11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b14:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b17:	fd                   	std    
  800b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1a:	eb 09                	jmp    800b25 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1c:	83 ef 01             	sub    $0x1,%edi
  800b1f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b22:	fd                   	std    
  800b23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b25:	fc                   	cld    
  800b26:	eb 1a                	jmp    800b42 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	09 ca                	or     %ecx,%edx
  800b2c:	09 f2                	or     %esi,%edx
  800b2e:	f6 c2 03             	test   $0x3,%dl
  800b31:	75 0a                	jne    800b3d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b33:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b36:	89 c7                	mov    %eax,%edi
  800b38:	fc                   	cld    
  800b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3b:	eb 05                	jmp    800b42 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	fc                   	cld    
  800b40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b46:	f3 0f 1e fb          	endbr32 
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b50:	ff 75 10             	pushl  0x10(%ebp)
  800b53:	ff 75 0c             	pushl  0xc(%ebp)
  800b56:	ff 75 08             	pushl  0x8(%ebp)
  800b59:	e8 82 ff ff ff       	call   800ae0 <memmove>
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b60:	f3 0f 1e fb          	endbr32 
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6f:	89 c6                	mov    %eax,%esi
  800b71:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b74:	39 f0                	cmp    %esi,%eax
  800b76:	74 1c                	je     800b94 <memcmp+0x34>
		if (*s1 != *s2)
  800b78:	0f b6 08             	movzbl (%eax),%ecx
  800b7b:	0f b6 1a             	movzbl (%edx),%ebx
  800b7e:	38 d9                	cmp    %bl,%cl
  800b80:	75 08                	jne    800b8a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b82:	83 c0 01             	add    $0x1,%eax
  800b85:	83 c2 01             	add    $0x1,%edx
  800b88:	eb ea                	jmp    800b74 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b8a:	0f b6 c1             	movzbl %cl,%eax
  800b8d:	0f b6 db             	movzbl %bl,%ebx
  800b90:	29 d8                	sub    %ebx,%eax
  800b92:	eb 05                	jmp    800b99 <memcmp+0x39>
	}

	return 0;
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9d:	f3 0f 1e fb          	endbr32 
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800baf:	39 d0                	cmp    %edx,%eax
  800bb1:	73 09                	jae    800bbc <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb3:	38 08                	cmp    %cl,(%eax)
  800bb5:	74 05                	je     800bbc <memfind+0x1f>
	for (; s < ends; s++)
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	eb f3                	jmp    800baf <memfind+0x12>
			break;
	return (void *) s;
}
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbe:	f3 0f 1e fb          	endbr32 
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bce:	eb 03                	jmp    800bd3 <strtol+0x15>
		s++;
  800bd0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bd3:	0f b6 01             	movzbl (%ecx),%eax
  800bd6:	3c 20                	cmp    $0x20,%al
  800bd8:	74 f6                	je     800bd0 <strtol+0x12>
  800bda:	3c 09                	cmp    $0x9,%al
  800bdc:	74 f2                	je     800bd0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800bde:	3c 2b                	cmp    $0x2b,%al
  800be0:	74 2a                	je     800c0c <strtol+0x4e>
	int neg = 0;
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800be7:	3c 2d                	cmp    $0x2d,%al
  800be9:	74 2b                	je     800c16 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800beb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bf1:	75 0f                	jne    800c02 <strtol+0x44>
  800bf3:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf6:	74 28                	je     800c20 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf8:	85 db                	test   %ebx,%ebx
  800bfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bff:	0f 44 d8             	cmove  %eax,%ebx
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c0a:	eb 46                	jmp    800c52 <strtol+0x94>
		s++;
  800c0c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c14:	eb d5                	jmp    800beb <strtol+0x2d>
		s++, neg = 1;
  800c16:	83 c1 01             	add    $0x1,%ecx
  800c19:	bf 01 00 00 00       	mov    $0x1,%edi
  800c1e:	eb cb                	jmp    800beb <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c24:	74 0e                	je     800c34 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c26:	85 db                	test   %ebx,%ebx
  800c28:	75 d8                	jne    800c02 <strtol+0x44>
		s++, base = 8;
  800c2a:	83 c1 01             	add    $0x1,%ecx
  800c2d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c32:	eb ce                	jmp    800c02 <strtol+0x44>
		s += 2, base = 16;
  800c34:	83 c1 02             	add    $0x2,%ecx
  800c37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3c:	eb c4                	jmp    800c02 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c3e:	0f be d2             	movsbl %dl,%edx
  800c41:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c44:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c47:	7d 3a                	jge    800c83 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c49:	83 c1 01             	add    $0x1,%ecx
  800c4c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c50:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c52:	0f b6 11             	movzbl (%ecx),%edx
  800c55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c58:	89 f3                	mov    %esi,%ebx
  800c5a:	80 fb 09             	cmp    $0x9,%bl
  800c5d:	76 df                	jbe    800c3e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c5f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c62:	89 f3                	mov    %esi,%ebx
  800c64:	80 fb 19             	cmp    $0x19,%bl
  800c67:	77 08                	ja     800c71 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c69:	0f be d2             	movsbl %dl,%edx
  800c6c:	83 ea 57             	sub    $0x57,%edx
  800c6f:	eb d3                	jmp    800c44 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c71:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c74:	89 f3                	mov    %esi,%ebx
  800c76:	80 fb 19             	cmp    $0x19,%bl
  800c79:	77 08                	ja     800c83 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c7b:	0f be d2             	movsbl %dl,%edx
  800c7e:	83 ea 37             	sub    $0x37,%edx
  800c81:	eb c1                	jmp    800c44 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c87:	74 05                	je     800c8e <strtol+0xd0>
		*endptr = (char *) s;
  800c89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c8e:	89 c2                	mov    %eax,%edx
  800c90:	f7 da                	neg    %edx
  800c92:	85 ff                	test   %edi,%edi
  800c94:	0f 45 c2             	cmovne %edx,%eax
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c9c:	f3 0f 1e fb          	endbr32 
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	89 c7                	mov    %eax,%edi
  800cb5:	89 c6                	mov    %eax,%esi
  800cb7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbe:	f3 0f 1e fb          	endbr32 
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	89 d6                	mov    %edx,%esi
  800cda:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ce1:	f3 0f 1e fb          	endbr32 
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ceb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf8:	89 cb                	mov    %ecx,%ebx
  800cfa:	89 cf                	mov    %ecx,%edi
  800cfc:	89 ce                	mov    %ecx,%esi
  800cfe:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	f3 0f 1e fb          	endbr32 
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d14:	b8 02 00 00 00       	mov    $0x2,%eax
  800d19:	89 d1                	mov    %edx,%ecx
  800d1b:	89 d3                	mov    %edx,%ebx
  800d1d:	89 d7                	mov    %edx,%edi
  800d1f:	89 d6                	mov    %edx,%esi
  800d21:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_yield>:

void
sys_yield(void)
{
  800d28:	f3 0f 1e fb          	endbr32 
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3c:	89 d1                	mov    %edx,%ecx
  800d3e:	89 d3                	mov    %edx,%ebx
  800d40:	89 d7                	mov    %edx,%edi
  800d42:	89 d6                	mov    %edx,%esi
  800d44:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d4b:	f3 0f 1e fb          	endbr32 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d55:	be 00 00 00 00       	mov    $0x0,%esi
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	b8 04 00 00 00       	mov    $0x4,%eax
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	89 f7                	mov    %esi,%edi
  800d6a:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d71:	f3 0f 1e fb          	endbr32 
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	b8 05 00 00 00       	mov    $0x5,%eax
  800d86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8f:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d96:	f3 0f 1e fb          	endbr32 
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	b8 06 00 00 00       	mov    $0x6,%eax
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbb:	f3 0f 1e fb          	endbr32 
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfa:	89 df                	mov    %ebx,%edi
  800dfc:	89 de                	mov    %ebx,%esi
  800dfe:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e05:	f3 0f 1e fb          	endbr32 
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1f:	89 df                	mov    %ebx,%edi
  800e21:	89 de                	mov    %ebx,%esi
  800e23:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2a:	f3 0f 1e fb          	endbr32 
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e34:	8b 55 08             	mov    0x8(%ebp),%edx
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3f:	be 00 00 00 00       	mov    $0x0,%esi
  800e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e51:	f3 0f 1e fb          	endbr32 
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e68:	89 cb                	mov    %ecx,%ebx
  800e6a:	89 cf                	mov    %ecx,%edi
  800e6c:	89 ce                	mov    %ecx,%esi
  800e6e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e75:	f3 0f 1e fb          	endbr32 
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e84:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e89:	89 d1                	mov    %edx,%ecx
  800e8b:	89 d3                	mov    %edx,%ebx
  800e8d:	89 d7                	mov    %edx,%edi
  800e8f:	89 d6                	mov    %edx,%esi
  800e91:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800e98:	f3 0f 1e fb          	endbr32 
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ead:	b8 0f 00 00 00       	mov    $0xf,%eax
  800eb2:	89 df                	mov    %ebx,%edi
  800eb4:	89 de                	mov    %ebx,%esi
  800eb6:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800ebd:	f3 0f 1e fb          	endbr32 
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	57                   	push   %edi
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	b8 10 00 00 00       	mov    $0x10,%eax
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ee2:	f3 0f 1e fb          	endbr32 
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	05 00 00 00 30       	add    $0x30000000,%eax
  800ef1:	c1 e8 0c             	shr    $0xc,%eax
}
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ef6:	f3 0f 1e fb          	endbr32 
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f0a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f11:	f3 0f 1e fb          	endbr32 
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f1d:	89 c2                	mov    %eax,%edx
  800f1f:	c1 ea 16             	shr    $0x16,%edx
  800f22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f29:	f6 c2 01             	test   $0x1,%dl
  800f2c:	74 2d                	je     800f5b <fd_alloc+0x4a>
  800f2e:	89 c2                	mov    %eax,%edx
  800f30:	c1 ea 0c             	shr    $0xc,%edx
  800f33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3a:	f6 c2 01             	test   $0x1,%dl
  800f3d:	74 1c                	je     800f5b <fd_alloc+0x4a>
  800f3f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800f44:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f49:	75 d2                	jne    800f1d <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800f54:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800f59:	eb 0a                	jmp    800f65 <fd_alloc+0x54>
			*fd_store = fd;
  800f5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f67:	f3 0f 1e fb          	endbr32 
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f71:	83 f8 1f             	cmp    $0x1f,%eax
  800f74:	77 30                	ja     800fa6 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f76:	c1 e0 0c             	shl    $0xc,%eax
  800f79:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f7e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f84:	f6 c2 01             	test   $0x1,%dl
  800f87:	74 24                	je     800fad <fd_lookup+0x46>
  800f89:	89 c2                	mov    %eax,%edx
  800f8b:	c1 ea 0c             	shr    $0xc,%edx
  800f8e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f95:	f6 c2 01             	test   $0x1,%dl
  800f98:	74 1a                	je     800fb4 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9d:	89 02                	mov    %eax,(%edx)
	return 0;
  800f9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    
		return -E_INVAL;
  800fa6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fab:	eb f7                	jmp    800fa4 <fd_lookup+0x3d>
		return -E_INVAL;
  800fad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb2:	eb f0                	jmp    800fa4 <fd_lookup+0x3d>
  800fb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fb9:	eb e9                	jmp    800fa4 <fd_lookup+0x3d>

00800fbb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fbb:	f3 0f 1e fb          	endbr32 
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 08             	sub    $0x8,%esp
  800fc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800fc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcd:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800fd2:	39 08                	cmp    %ecx,(%eax)
  800fd4:	74 38                	je     80100e <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800fd6:	83 c2 01             	add    $0x1,%edx
  800fd9:	8b 04 95 bc 29 80 00 	mov    0x8029bc(,%edx,4),%eax
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	75 ee                	jne    800fd2 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fe4:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800fe9:	8b 40 48             	mov    0x48(%eax),%eax
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	51                   	push   %ecx
  800ff0:	50                   	push   %eax
  800ff1:	68 40 29 80 00       	push   $0x802940
  800ff6:	e8 dd f2 ff ff       	call   8002d8 <cprintf>
	*dev = 0;
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    
			*dev = devtab[i];
  80100e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801011:	89 01                	mov    %eax,(%ecx)
			return 0;
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
  801018:	eb f2                	jmp    80100c <dev_lookup+0x51>

0080101a <fd_close>:
{
  80101a:	f3 0f 1e fb          	endbr32 
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 24             	sub    $0x24,%esp
  801027:	8b 75 08             	mov    0x8(%ebp),%esi
  80102a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80102d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801030:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801031:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801037:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80103a:	50                   	push   %eax
  80103b:	e8 27 ff ff ff       	call   800f67 <fd_lookup>
  801040:	89 c3                	mov    %eax,%ebx
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	85 c0                	test   %eax,%eax
  801047:	78 05                	js     80104e <fd_close+0x34>
	    || fd != fd2)
  801049:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80104c:	74 16                	je     801064 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80104e:	89 f8                	mov    %edi,%eax
  801050:	84 c0                	test   %al,%al
  801052:	b8 00 00 00 00       	mov    $0x0,%eax
  801057:	0f 44 d8             	cmove  %eax,%ebx
}
  80105a:	89 d8                	mov    %ebx,%eax
  80105c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 36                	pushl  (%esi)
  80106d:	e8 49 ff ff ff       	call   800fbb <dev_lookup>
  801072:	89 c3                	mov    %eax,%ebx
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 1a                	js     801095 <fd_close+0x7b>
		if (dev->dev_close)
  80107b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80107e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801086:	85 c0                	test   %eax,%eax
  801088:	74 0b                	je     801095 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	56                   	push   %esi
  80108e:	ff d0                	call   *%eax
  801090:	89 c3                	mov    %eax,%ebx
  801092:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	56                   	push   %esi
  801099:	6a 00                	push   $0x0
  80109b:	e8 f6 fc ff ff       	call   800d96 <sys_page_unmap>
	return r;
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	eb b5                	jmp    80105a <fd_close+0x40>

008010a5 <close>:

int
close(int fdnum)
{
  8010a5:	f3 0f 1e fb          	endbr32 
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b2:	50                   	push   %eax
  8010b3:	ff 75 08             	pushl  0x8(%ebp)
  8010b6:	e8 ac fe ff ff       	call   800f67 <fd_lookup>
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	79 02                	jns    8010c4 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    
		return fd_close(fd, 1);
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	6a 01                	push   $0x1
  8010c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010cc:	e8 49 ff ff ff       	call   80101a <fd_close>
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	eb ec                	jmp    8010c2 <close+0x1d>

008010d6 <close_all>:

void
close_all(void)
{
  8010d6:	f3 0f 1e fb          	endbr32 
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	53                   	push   %ebx
  8010ea:	e8 b6 ff ff ff       	call   8010a5 <close>
	for (i = 0; i < MAXFD; i++)
  8010ef:	83 c3 01             	add    $0x1,%ebx
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	83 fb 20             	cmp    $0x20,%ebx
  8010f8:	75 ec                	jne    8010e6 <close_all+0x10>
}
  8010fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ff:	f3 0f 1e fb          	endbr32 
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	57                   	push   %edi
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80110c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	ff 75 08             	pushl  0x8(%ebp)
  801113:	e8 4f fe ff ff       	call   800f67 <fd_lookup>
  801118:	89 c3                	mov    %eax,%ebx
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	0f 88 81 00 00 00    	js     8011a6 <dup+0xa7>
		return r;
	close(newfdnum);
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	ff 75 0c             	pushl  0xc(%ebp)
  80112b:	e8 75 ff ff ff       	call   8010a5 <close>

	newfd = INDEX2FD(newfdnum);
  801130:	8b 75 0c             	mov    0xc(%ebp),%esi
  801133:	c1 e6 0c             	shl    $0xc,%esi
  801136:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80113c:	83 c4 04             	add    $0x4,%esp
  80113f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801142:	e8 af fd ff ff       	call   800ef6 <fd2data>
  801147:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801149:	89 34 24             	mov    %esi,(%esp)
  80114c:	e8 a5 fd ff ff       	call   800ef6 <fd2data>
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801156:	89 d8                	mov    %ebx,%eax
  801158:	c1 e8 16             	shr    $0x16,%eax
  80115b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801162:	a8 01                	test   $0x1,%al
  801164:	74 11                	je     801177 <dup+0x78>
  801166:	89 d8                	mov    %ebx,%eax
  801168:	c1 e8 0c             	shr    $0xc,%eax
  80116b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801172:	f6 c2 01             	test   $0x1,%dl
  801175:	75 39                	jne    8011b0 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801177:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80117a:	89 d0                	mov    %edx,%eax
  80117c:	c1 e8 0c             	shr    $0xc,%eax
  80117f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	25 07 0e 00 00       	and    $0xe07,%eax
  80118e:	50                   	push   %eax
  80118f:	56                   	push   %esi
  801190:	6a 00                	push   $0x0
  801192:	52                   	push   %edx
  801193:	6a 00                	push   $0x0
  801195:	e8 d7 fb ff ff       	call   800d71 <sys_page_map>
  80119a:	89 c3                	mov    %eax,%ebx
  80119c:	83 c4 20             	add    $0x20,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 31                	js     8011d4 <dup+0xd5>
		goto err;

	return newfdnum;
  8011a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011a6:	89 d8                	mov    %ebx,%eax
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bf:	50                   	push   %eax
  8011c0:	57                   	push   %edi
  8011c1:	6a 00                	push   $0x0
  8011c3:	53                   	push   %ebx
  8011c4:	6a 00                	push   $0x0
  8011c6:	e8 a6 fb ff ff       	call   800d71 <sys_page_map>
  8011cb:	89 c3                	mov    %eax,%ebx
  8011cd:	83 c4 20             	add    $0x20,%esp
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	79 a3                	jns    801177 <dup+0x78>
	sys_page_unmap(0, newfd);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	56                   	push   %esi
  8011d8:	6a 00                	push   $0x0
  8011da:	e8 b7 fb ff ff       	call   800d96 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011df:	83 c4 08             	add    $0x8,%esp
  8011e2:	57                   	push   %edi
  8011e3:	6a 00                	push   $0x0
  8011e5:	e8 ac fb ff ff       	call   800d96 <sys_page_unmap>
	return r;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	eb b7                	jmp    8011a6 <dup+0xa7>

008011ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011ef:	f3 0f 1e fb          	endbr32 
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 1c             	sub    $0x1c,%esp
  8011fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	53                   	push   %ebx
  801202:	e8 60 fd ff ff       	call   800f67 <fd_lookup>
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 3f                	js     80124d <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801218:	ff 30                	pushl  (%eax)
  80121a:	e8 9c fd ff ff       	call   800fbb <dev_lookup>
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 27                	js     80124d <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801226:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801229:	8b 42 08             	mov    0x8(%edx),%eax
  80122c:	83 e0 03             	and    $0x3,%eax
  80122f:	83 f8 01             	cmp    $0x1,%eax
  801232:	74 1e                	je     801252 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801234:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801237:	8b 40 08             	mov    0x8(%eax),%eax
  80123a:	85 c0                	test   %eax,%eax
  80123c:	74 35                	je     801273 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	ff 75 10             	pushl  0x10(%ebp)
  801244:	ff 75 0c             	pushl  0xc(%ebp)
  801247:	52                   	push   %edx
  801248:	ff d0                	call   *%eax
  80124a:	83 c4 10             	add    $0x10,%esp
}
  80124d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801250:	c9                   	leave  
  801251:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801252:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801257:	8b 40 48             	mov    0x48(%eax),%eax
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	53                   	push   %ebx
  80125e:	50                   	push   %eax
  80125f:	68 81 29 80 00       	push   $0x802981
  801264:	e8 6f f0 ff ff       	call   8002d8 <cprintf>
		return -E_INVAL;
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801271:	eb da                	jmp    80124d <read+0x5e>
		return -E_NOT_SUPP;
  801273:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801278:	eb d3                	jmp    80124d <read+0x5e>

0080127a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127a:	f3 0f 1e fb          	endbr32 
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	8b 7d 08             	mov    0x8(%ebp),%edi
  80128a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801292:	eb 02                	jmp    801296 <readn+0x1c>
  801294:	01 c3                	add    %eax,%ebx
  801296:	39 f3                	cmp    %esi,%ebx
  801298:	73 21                	jae    8012bb <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	29 d8                	sub    %ebx,%eax
  8012a1:	50                   	push   %eax
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	03 45 0c             	add    0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	57                   	push   %edi
  8012a9:	e8 41 ff ff ff       	call   8011ef <read>
		if (m < 0)
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 04                	js     8012b9 <readn+0x3f>
			return m;
		if (m == 0)
  8012b5:	75 dd                	jne    801294 <readn+0x1a>
  8012b7:	eb 02                	jmp    8012bb <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c5:	f3 0f 1e fb          	endbr32 
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 1c             	sub    $0x1c,%esp
  8012d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	53                   	push   %ebx
  8012d8:	e8 8a fc ff ff       	call   800f67 <fd_lookup>
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 3a                	js     80131e <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ee:	ff 30                	pushl  (%eax)
  8012f0:	e8 c6 fc ff ff       	call   800fbb <dev_lookup>
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 22                	js     80131e <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801303:	74 1e                	je     801323 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801305:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801308:	8b 52 0c             	mov    0xc(%edx),%edx
  80130b:	85 d2                	test   %edx,%edx
  80130d:	74 35                	je     801344 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80130f:	83 ec 04             	sub    $0x4,%esp
  801312:	ff 75 10             	pushl  0x10(%ebp)
  801315:	ff 75 0c             	pushl  0xc(%ebp)
  801318:	50                   	push   %eax
  801319:	ff d2                	call   *%edx
  80131b:	83 c4 10             	add    $0x10,%esp
}
  80131e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801321:	c9                   	leave  
  801322:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801323:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801328:	8b 40 48             	mov    0x48(%eax),%eax
  80132b:	83 ec 04             	sub    $0x4,%esp
  80132e:	53                   	push   %ebx
  80132f:	50                   	push   %eax
  801330:	68 9d 29 80 00       	push   $0x80299d
  801335:	e8 9e ef ff ff       	call   8002d8 <cprintf>
		return -E_INVAL;
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801342:	eb da                	jmp    80131e <write+0x59>
		return -E_NOT_SUPP;
  801344:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801349:	eb d3                	jmp    80131e <write+0x59>

0080134b <seek>:

int
seek(int fdnum, off_t offset)
{
  80134b:	f3 0f 1e fb          	endbr32 
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 75 08             	pushl  0x8(%ebp)
  80135c:	e8 06 fc ff ff       	call   800f67 <fd_lookup>
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 0e                	js     801376 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801371:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801378:	f3 0f 1e fb          	endbr32 
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	53                   	push   %ebx
  801380:	83 ec 1c             	sub    $0x1c,%esp
  801383:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801386:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	53                   	push   %ebx
  80138b:	e8 d7 fb ff ff       	call   800f67 <fd_lookup>
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 37                	js     8013ce <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	ff 30                	pushl  (%eax)
  8013a3:	e8 13 fc ff ff       	call   800fbb <dev_lookup>
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 1f                	js     8013ce <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b6:	74 1b                	je     8013d3 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013bb:	8b 52 18             	mov    0x18(%edx),%edx
  8013be:	85 d2                	test   %edx,%edx
  8013c0:	74 32                	je     8013f4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	ff 75 0c             	pushl  0xc(%ebp)
  8013c8:	50                   	push   %eax
  8013c9:	ff d2                	call   *%edx
  8013cb:	83 c4 10             	add    $0x10,%esp
}
  8013ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013d3:	a1 0c 40 80 00       	mov    0x80400c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013d8:	8b 40 48             	mov    0x48(%eax),%eax
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	53                   	push   %ebx
  8013df:	50                   	push   %eax
  8013e0:	68 60 29 80 00       	push   $0x802960
  8013e5:	e8 ee ee ff ff       	call   8002d8 <cprintf>
		return -E_INVAL;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f2:	eb da                	jmp    8013ce <ftruncate+0x56>
		return -E_NOT_SUPP;
  8013f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f9:	eb d3                	jmp    8013ce <ftruncate+0x56>

008013fb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013fb:	f3 0f 1e fb          	endbr32 
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	53                   	push   %ebx
  801403:	83 ec 1c             	sub    $0x1c,%esp
  801406:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801409:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	ff 75 08             	pushl  0x8(%ebp)
  801410:	e8 52 fb ff ff       	call   800f67 <fd_lookup>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 4b                	js     801467 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801422:	50                   	push   %eax
  801423:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801426:	ff 30                	pushl  (%eax)
  801428:	e8 8e fb ff ff       	call   800fbb <dev_lookup>
  80142d:	83 c4 10             	add    $0x10,%esp
  801430:	85 c0                	test   %eax,%eax
  801432:	78 33                	js     801467 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801437:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143b:	74 2f                	je     80146c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80143d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801440:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801447:	00 00 00 
	stat->st_isdir = 0;
  80144a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801451:	00 00 00 
	stat->st_dev = dev;
  801454:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	53                   	push   %ebx
  80145e:	ff 75 f0             	pushl  -0x10(%ebp)
  801461:	ff 50 14             	call   *0x14(%eax)
  801464:	83 c4 10             	add    $0x10,%esp
}
  801467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    
		return -E_NOT_SUPP;
  80146c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801471:	eb f4                	jmp    801467 <fstat+0x6c>

00801473 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801473:	f3 0f 1e fb          	endbr32 
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	56                   	push   %esi
  80147b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	6a 00                	push   $0x0
  801481:	ff 75 08             	pushl  0x8(%ebp)
  801484:	e8 01 02 00 00       	call   80168a <open>
  801489:	89 c3                	mov    %eax,%ebx
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 1b                	js     8014ad <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	ff 75 0c             	pushl  0xc(%ebp)
  801498:	50                   	push   %eax
  801499:	e8 5d ff ff ff       	call   8013fb <fstat>
  80149e:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a0:	89 1c 24             	mov    %ebx,(%esp)
  8014a3:	e8 fd fb ff ff       	call   8010a5 <close>
	return r;
  8014a8:	83 c4 10             	add    $0x10,%esp
  8014ab:	89 f3                	mov    %esi,%ebx
}
  8014ad:	89 d8                	mov    %ebx,%eax
  8014af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
  8014bb:	89 c6                	mov    %eax,%esi
  8014bd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014bf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014c6:	74 27                	je     8014ef <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014c8:	6a 07                	push   $0x7
  8014ca:	68 00 50 80 00       	push   $0x805000
  8014cf:	56                   	push   %esi
  8014d0:	ff 35 04 40 80 00    	pushl  0x804004
  8014d6:	e8 a0 0d 00 00       	call   80227b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014db:	83 c4 0c             	add    $0xc,%esp
  8014de:	6a 00                	push   $0x0
  8014e0:	53                   	push   %ebx
  8014e1:	6a 00                	push   $0x0
  8014e3:	e8 26 0d 00 00       	call   80220e <ipc_recv>
}
  8014e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014eb:	5b                   	pop    %ebx
  8014ec:	5e                   	pop    %esi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	6a 01                	push   $0x1
  8014f4:	e8 da 0d 00 00       	call   8022d3 <ipc_find_env>
  8014f9:	a3 04 40 80 00       	mov    %eax,0x804004
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	eb c5                	jmp    8014c8 <fsipc+0x12>

00801503 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801503:	f3 0f 1e fb          	endbr32 
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80150d:	8b 45 08             	mov    0x8(%ebp),%eax
  801510:	8b 40 0c             	mov    0xc(%eax),%eax
  801513:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	b8 02 00 00 00       	mov    $0x2,%eax
  80152a:	e8 87 ff ff ff       	call   8014b6 <fsipc>
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <devfile_flush>:
{
  801531:	f3 0f 1e fb          	endbr32 
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
  801538:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80153b:	8b 45 08             	mov    0x8(%ebp),%eax
  80153e:	8b 40 0c             	mov    0xc(%eax),%eax
  801541:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	b8 06 00 00 00       	mov    $0x6,%eax
  801550:	e8 61 ff ff ff       	call   8014b6 <fsipc>
}
  801555:	c9                   	leave  
  801556:	c3                   	ret    

00801557 <devfile_stat>:
{
  801557:	f3 0f 1e fb          	endbr32 
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801565:	8b 45 08             	mov    0x8(%ebp),%eax
  801568:	8b 40 0c             	mov    0xc(%eax),%eax
  80156b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801570:	ba 00 00 00 00       	mov    $0x0,%edx
  801575:	b8 05 00 00 00       	mov    $0x5,%eax
  80157a:	e8 37 ff ff ff       	call   8014b6 <fsipc>
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 2c                	js     8015af <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	68 00 50 80 00       	push   $0x805000
  80158b:	53                   	push   %ebx
  80158c:	e8 51 f3 ff ff       	call   8008e2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801591:	a1 80 50 80 00       	mov    0x805080,%eax
  801596:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80159c:	a1 84 50 80 00       	mov    0x805084,%eax
  8015a1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <devfile_write>:
{
  8015b4:	f3 0f 1e fb          	endbr32 
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015c6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015cb:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015da:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015df:	50                   	push   %eax
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	68 08 50 80 00       	push   $0x805008
  8015e8:	e8 f3 f4 ff ff       	call   800ae0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8015ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8015f7:	e8 ba fe ff ff       	call   8014b6 <fsipc>
}
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <devfile_read>:
{
  8015fe:	f3 0f 1e fb          	endbr32 
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	56                   	push   %esi
  801606:	53                   	push   %ebx
  801607:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
  801610:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801615:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80161b:	ba 00 00 00 00       	mov    $0x0,%edx
  801620:	b8 03 00 00 00       	mov    $0x3,%eax
  801625:	e8 8c fe ff ff       	call   8014b6 <fsipc>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 1f                	js     80164f <devfile_read+0x51>
	assert(r <= n);
  801630:	39 f0                	cmp    %esi,%eax
  801632:	77 24                	ja     801658 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801634:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801639:	7f 36                	jg     801671 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80163b:	83 ec 04             	sub    $0x4,%esp
  80163e:	50                   	push   %eax
  80163f:	68 00 50 80 00       	push   $0x805000
  801644:	ff 75 0c             	pushl  0xc(%ebp)
  801647:	e8 94 f4 ff ff       	call   800ae0 <memmove>
	return r;
  80164c:	83 c4 10             	add    $0x10,%esp
}
  80164f:	89 d8                	mov    %ebx,%eax
  801651:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801654:	5b                   	pop    %ebx
  801655:	5e                   	pop    %esi
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    
	assert(r <= n);
  801658:	68 d0 29 80 00       	push   $0x8029d0
  80165d:	68 d7 29 80 00       	push   $0x8029d7
  801662:	68 8c 00 00 00       	push   $0x8c
  801667:	68 ec 29 80 00       	push   $0x8029ec
  80166c:	e8 80 eb ff ff       	call   8001f1 <_panic>
	assert(r <= PGSIZE);
  801671:	68 f7 29 80 00       	push   $0x8029f7
  801676:	68 d7 29 80 00       	push   $0x8029d7
  80167b:	68 8d 00 00 00       	push   $0x8d
  801680:	68 ec 29 80 00       	push   $0x8029ec
  801685:	e8 67 eb ff ff       	call   8001f1 <_panic>

0080168a <open>:
{
  80168a:	f3 0f 1e fb          	endbr32 
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	56                   	push   %esi
  801692:	53                   	push   %ebx
  801693:	83 ec 1c             	sub    $0x1c,%esp
  801696:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801699:	56                   	push   %esi
  80169a:	e8 00 f2 ff ff       	call   80089f <strlen>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016a7:	7f 6c                	jg     801715 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	e8 5c f8 ff ff       	call   800f11 <fd_alloc>
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 3c                	js     8016fa <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	56                   	push   %esi
  8016c2:	68 00 50 80 00       	push   $0x805000
  8016c7:	e8 16 f2 ff ff       	call   8008e2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016cf:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8016dc:	e8 d5 fd ff ff       	call   8014b6 <fsipc>
  8016e1:	89 c3                	mov    %eax,%ebx
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 19                	js     801703 <open+0x79>
	return fd2num(fd);
  8016ea:	83 ec 0c             	sub    $0xc,%esp
  8016ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f0:	e8 ed f7 ff ff       	call   800ee2 <fd2num>
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	83 c4 10             	add    $0x10,%esp
}
  8016fa:	89 d8                	mov    %ebx,%eax
  8016fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    
		fd_close(fd, 0);
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	6a 00                	push   $0x0
  801708:	ff 75 f4             	pushl  -0xc(%ebp)
  80170b:	e8 0a f9 ff ff       	call   80101a <fd_close>
		return r;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	eb e5                	jmp    8016fa <open+0x70>
		return -E_BAD_PATH;
  801715:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80171a:	eb de                	jmp    8016fa <open+0x70>

0080171c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80171c:	f3 0f 1e fb          	endbr32 
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801726:	ba 00 00 00 00       	mov    $0x0,%edx
  80172b:	b8 08 00 00 00       	mov    $0x8,%eax
  801730:	e8 81 fd ff ff       	call   8014b6 <fsipc>
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801737:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80173b:	7f 01                	jg     80173e <writebuf+0x7>
  80173d:	c3                   	ret    
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801747:	ff 70 04             	pushl  0x4(%eax)
  80174a:	8d 40 10             	lea    0x10(%eax),%eax
  80174d:	50                   	push   %eax
  80174e:	ff 33                	pushl  (%ebx)
  801750:	e8 70 fb ff ff       	call   8012c5 <write>
		if (result > 0)
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	7e 03                	jle    80175f <writebuf+0x28>
			b->result += result;
  80175c:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80175f:	39 43 04             	cmp    %eax,0x4(%ebx)
  801762:	74 0d                	je     801771 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801764:	85 c0                	test   %eax,%eax
  801766:	ba 00 00 00 00       	mov    $0x0,%edx
  80176b:	0f 4f c2             	cmovg  %edx,%eax
  80176e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <putch>:

static void
putch(int ch, void *thunk)
{
  801776:	f3 0f 1e fb          	endbr32 
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	53                   	push   %ebx
  80177e:	83 ec 04             	sub    $0x4,%esp
  801781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801784:	8b 53 04             	mov    0x4(%ebx),%edx
  801787:	8d 42 01             	lea    0x1(%edx),%eax
  80178a:	89 43 04             	mov    %eax,0x4(%ebx)
  80178d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801790:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801794:	3d 00 01 00 00       	cmp    $0x100,%eax
  801799:	74 06                	je     8017a1 <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  80179b:	83 c4 04             	add    $0x4,%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    
		writebuf(b);
  8017a1:	89 d8                	mov    %ebx,%eax
  8017a3:	e8 8f ff ff ff       	call   801737 <writebuf>
		b->idx = 0;
  8017a8:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8017af:	eb ea                	jmp    80179b <putch+0x25>

008017b1 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017b1:	f3 0f 1e fb          	endbr32 
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017c7:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017ce:	00 00 00 
	b.result = 0;
  8017d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017d8:	00 00 00 
	b.error = 1;
  8017db:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017e2:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017e5:	ff 75 10             	pushl  0x10(%ebp)
  8017e8:	ff 75 0c             	pushl  0xc(%ebp)
  8017eb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017f1:	50                   	push   %eax
  8017f2:	68 76 17 80 00       	push   $0x801776
  8017f7:	e8 df eb ff ff       	call   8003db <vprintfmt>
	if (b.idx > 0)
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801806:	7f 11                	jg     801819 <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801808:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80180e:	85 c0                	test   %eax,%eax
  801810:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    
		writebuf(&b);
  801819:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80181f:	e8 13 ff ff ff       	call   801737 <writebuf>
  801824:	eb e2                	jmp    801808 <vfprintf+0x57>

00801826 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801826:	f3 0f 1e fb          	endbr32 
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801830:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801833:	50                   	push   %eax
  801834:	ff 75 0c             	pushl  0xc(%ebp)
  801837:	ff 75 08             	pushl  0x8(%ebp)
  80183a:	e8 72 ff ff ff       	call   8017b1 <vfprintf>
	va_end(ap);

	return cnt;
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <printf>:

int
printf(const char *fmt, ...)
{
  801841:	f3 0f 1e fb          	endbr32 
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80184b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80184e:	50                   	push   %eax
  80184f:	ff 75 08             	pushl  0x8(%ebp)
  801852:	6a 01                	push   $0x1
  801854:	e8 58 ff ff ff       	call   8017b1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80185b:	f3 0f 1e fb          	endbr32 
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801865:	68 63 2a 80 00       	push   $0x802a63
  80186a:	ff 75 0c             	pushl  0xc(%ebp)
  80186d:	e8 70 f0 ff ff       	call   8008e2 <strcpy>
	return 0;
}
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devsock_close>:
{
  801879:	f3 0f 1e fb          	endbr32 
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	53                   	push   %ebx
  801881:	83 ec 10             	sub    $0x10,%esp
  801884:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801887:	53                   	push   %ebx
  801888:	e8 83 0a 00 00       	call   802310 <pageref>
  80188d:	89 c2                	mov    %eax,%edx
  80188f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801892:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801897:	83 fa 01             	cmp    $0x1,%edx
  80189a:	74 05                	je     8018a1 <devsock_close+0x28>
}
  80189c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018a1:	83 ec 0c             	sub    $0xc,%esp
  8018a4:	ff 73 0c             	pushl  0xc(%ebx)
  8018a7:	e8 e3 02 00 00       	call   801b8f <nsipc_close>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	eb eb                	jmp    80189c <devsock_close+0x23>

008018b1 <devsock_write>:
{
  8018b1:	f3 0f 1e fb          	endbr32 
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018bb:	6a 00                	push   $0x0
  8018bd:	ff 75 10             	pushl  0x10(%ebp)
  8018c0:	ff 75 0c             	pushl  0xc(%ebp)
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	ff 70 0c             	pushl  0xc(%eax)
  8018c9:	e8 b5 03 00 00       	call   801c83 <nsipc_send>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devsock_read>:
{
  8018d0:	f3 0f 1e fb          	endbr32 
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018da:	6a 00                	push   $0x0
  8018dc:	ff 75 10             	pushl  0x10(%ebp)
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	ff 70 0c             	pushl  0xc(%eax)
  8018e8:	e8 1f 03 00 00       	call   801c0c <nsipc_recv>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <fd2sockid>:
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018f5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018f8:	52                   	push   %edx
  8018f9:	50                   	push   %eax
  8018fa:	e8 68 f6 ff ff       	call   800f67 <fd_lookup>
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	85 c0                	test   %eax,%eax
  801904:	78 10                	js     801916 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801906:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801909:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80190f:	39 08                	cmp    %ecx,(%eax)
  801911:	75 05                	jne    801918 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801913:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    
		return -E_NOT_SUPP;
  801918:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80191d:	eb f7                	jmp    801916 <fd2sockid+0x27>

0080191f <alloc_sockfd>:
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	83 ec 1c             	sub    $0x1c,%esp
  801927:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	e8 df f5 ff ff       	call   800f11 <fd_alloc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 43                	js     80197e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	68 07 04 00 00       	push   $0x407
  801943:	ff 75 f4             	pushl  -0xc(%ebp)
  801946:	6a 00                	push   $0x0
  801948:	e8 fe f3 ff ff       	call   800d4b <sys_page_alloc>
  80194d:	89 c3                	mov    %eax,%ebx
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	85 c0                	test   %eax,%eax
  801954:	78 28                	js     80197e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801959:	8b 15 60 30 80 00    	mov    0x803060,%edx
  80195f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801961:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801964:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80196b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80196e:	83 ec 0c             	sub    $0xc,%esp
  801971:	50                   	push   %eax
  801972:	e8 6b f5 ff ff       	call   800ee2 <fd2num>
  801977:	89 c3                	mov    %eax,%ebx
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	eb 0c                	jmp    80198a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	56                   	push   %esi
  801982:	e8 08 02 00 00       	call   801b8f <nsipc_close>
		return r;
  801987:	83 c4 10             	add    $0x10,%esp
}
  80198a:	89 d8                	mov    %ebx,%eax
  80198c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <accept>:
{
  801993:	f3 0f 1e fb          	endbr32 
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	e8 4a ff ff ff       	call   8018ef <fd2sockid>
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 1b                	js     8019c4 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019a9:	83 ec 04             	sub    $0x4,%esp
  8019ac:	ff 75 10             	pushl  0x10(%ebp)
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	50                   	push   %eax
  8019b3:	e8 22 01 00 00       	call   801ada <nsipc_accept>
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 05                	js     8019c4 <accept+0x31>
	return alloc_sockfd(r);
  8019bf:	e8 5b ff ff ff       	call   80191f <alloc_sockfd>
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <bind>:
{
  8019c6:	f3 0f 1e fb          	endbr32 
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	e8 17 ff ff ff       	call   8018ef <fd2sockid>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 12                	js     8019ee <bind+0x28>
	return nsipc_bind(r, name, namelen);
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	ff 75 10             	pushl  0x10(%ebp)
  8019e2:	ff 75 0c             	pushl  0xc(%ebp)
  8019e5:	50                   	push   %eax
  8019e6:	e8 45 01 00 00       	call   801b30 <nsipc_bind>
  8019eb:	83 c4 10             	add    $0x10,%esp
}
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <shutdown>:
{
  8019f0:	f3 0f 1e fb          	endbr32 
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	e8 ed fe ff ff       	call   8018ef <fd2sockid>
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 0f                	js     801a15 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801a06:	83 ec 08             	sub    $0x8,%esp
  801a09:	ff 75 0c             	pushl  0xc(%ebp)
  801a0c:	50                   	push   %eax
  801a0d:	e8 57 01 00 00       	call   801b69 <nsipc_shutdown>
  801a12:	83 c4 10             	add    $0x10,%esp
}
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <connect>:
{
  801a17:	f3 0f 1e fb          	endbr32 
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	e8 c6 fe ff ff       	call   8018ef <fd2sockid>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 12                	js     801a3f <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801a2d:	83 ec 04             	sub    $0x4,%esp
  801a30:	ff 75 10             	pushl  0x10(%ebp)
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	50                   	push   %eax
  801a37:	e8 71 01 00 00       	call   801bad <nsipc_connect>
  801a3c:	83 c4 10             	add    $0x10,%esp
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <listen>:
{
  801a41:	f3 0f 1e fb          	endbr32 
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	e8 9c fe ff ff       	call   8018ef <fd2sockid>
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 0f                	js     801a66 <listen+0x25>
	return nsipc_listen(r, backlog);
  801a57:	83 ec 08             	sub    $0x8,%esp
  801a5a:	ff 75 0c             	pushl  0xc(%ebp)
  801a5d:	50                   	push   %eax
  801a5e:	e8 83 01 00 00       	call   801be6 <nsipc_listen>
  801a63:	83 c4 10             	add    $0x10,%esp
}
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a68:	f3 0f 1e fb          	endbr32 
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a72:	ff 75 10             	pushl  0x10(%ebp)
  801a75:	ff 75 0c             	pushl  0xc(%ebp)
  801a78:	ff 75 08             	pushl  0x8(%ebp)
  801a7b:	e8 65 02 00 00       	call   801ce5 <nsipc_socket>
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 05                	js     801a8c <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801a87:	e8 93 fe ff ff       	call   80191f <alloc_sockfd>
}
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	53                   	push   %ebx
  801a92:	83 ec 04             	sub    $0x4,%esp
  801a95:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a97:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801a9e:	74 26                	je     801ac6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801aa0:	6a 07                	push   $0x7
  801aa2:	68 00 60 80 00       	push   $0x806000
  801aa7:	53                   	push   %ebx
  801aa8:	ff 35 08 40 80 00    	pushl  0x804008
  801aae:	e8 c8 07 00 00       	call   80227b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ab3:	83 c4 0c             	add    $0xc,%esp
  801ab6:	6a 00                	push   $0x0
  801ab8:	6a 00                	push   $0x0
  801aba:	6a 00                	push   $0x0
  801abc:	e8 4d 07 00 00       	call   80220e <ipc_recv>
}
  801ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	6a 02                	push   $0x2
  801acb:	e8 03 08 00 00       	call   8022d3 <ipc_find_env>
  801ad0:	a3 08 40 80 00       	mov    %eax,0x804008
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	eb c6                	jmp    801aa0 <nsipc+0x12>

00801ada <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ada:	f3 0f 1e fb          	endbr32 
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801aee:	8b 06                	mov    (%esi),%eax
  801af0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801af5:	b8 01 00 00 00       	mov    $0x1,%eax
  801afa:	e8 8f ff ff ff       	call   801a8e <nsipc>
  801aff:	89 c3                	mov    %eax,%ebx
  801b01:	85 c0                	test   %eax,%eax
  801b03:	79 09                	jns    801b0e <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801b05:	89 d8                	mov    %ebx,%eax
  801b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b0e:	83 ec 04             	sub    $0x4,%esp
  801b11:	ff 35 10 60 80 00    	pushl  0x806010
  801b17:	68 00 60 80 00       	push   $0x806000
  801b1c:	ff 75 0c             	pushl  0xc(%ebp)
  801b1f:	e8 bc ef ff ff       	call   800ae0 <memmove>
		*addrlen = ret->ret_addrlen;
  801b24:	a1 10 60 80 00       	mov    0x806010,%eax
  801b29:	89 06                	mov    %eax,(%esi)
  801b2b:	83 c4 10             	add    $0x10,%esp
	return r;
  801b2e:	eb d5                	jmp    801b05 <nsipc_accept+0x2b>

00801b30 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b30:	f3 0f 1e fb          	endbr32 
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	53                   	push   %ebx
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b46:	53                   	push   %ebx
  801b47:	ff 75 0c             	pushl  0xc(%ebp)
  801b4a:	68 04 60 80 00       	push   $0x806004
  801b4f:	e8 8c ef ff ff       	call   800ae0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b54:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b5a:	b8 02 00 00 00       	mov    $0x2,%eax
  801b5f:	e8 2a ff ff ff       	call   801a8e <nsipc>
}
  801b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b69:	f3 0f 1e fb          	endbr32 
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b83:	b8 03 00 00 00       	mov    $0x3,%eax
  801b88:	e8 01 ff ff ff       	call   801a8e <nsipc>
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <nsipc_close>:

int
nsipc_close(int s)
{
  801b8f:	f3 0f 1e fb          	endbr32 
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b99:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ba1:	b8 04 00 00 00       	mov    $0x4,%eax
  801ba6:	e8 e3 fe ff ff       	call   801a8e <nsipc>
}
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bad:	f3 0f 1e fb          	endbr32 
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 08             	sub    $0x8,%esp
  801bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bc3:	53                   	push   %ebx
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	68 04 60 80 00       	push   $0x806004
  801bcc:	e8 0f ef ff ff       	call   800ae0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bd1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bd7:	b8 05 00 00 00       	mov    $0x5,%eax
  801bdc:	e8 ad fe ff ff       	call   801a8e <nsipc>
}
  801be1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801be6:	f3 0f 1e fb          	endbr32 
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c00:	b8 06 00 00 00       	mov    $0x6,%eax
  801c05:	e8 84 fe ff ff       	call   801a8e <nsipc>
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c0c:	f3 0f 1e fb          	endbr32 
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c20:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c26:	8b 45 14             	mov    0x14(%ebp),%eax
  801c29:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c2e:	b8 07 00 00 00       	mov    $0x7,%eax
  801c33:	e8 56 fe ff ff       	call   801a8e <nsipc>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	78 26                	js     801c64 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801c3e:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801c44:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c49:	0f 4e c6             	cmovle %esi,%eax
  801c4c:	39 c3                	cmp    %eax,%ebx
  801c4e:	7f 1d                	jg     801c6d <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c50:	83 ec 04             	sub    $0x4,%esp
  801c53:	53                   	push   %ebx
  801c54:	68 00 60 80 00       	push   $0x806000
  801c59:	ff 75 0c             	pushl  0xc(%ebp)
  801c5c:	e8 7f ee ff ff       	call   800ae0 <memmove>
  801c61:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c6d:	68 6f 2a 80 00       	push   $0x802a6f
  801c72:	68 d7 29 80 00       	push   $0x8029d7
  801c77:	6a 62                	push   $0x62
  801c79:	68 84 2a 80 00       	push   $0x802a84
  801c7e:	e8 6e e5 ff ff       	call   8001f1 <_panic>

00801c83 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c83:	f3 0f 1e fb          	endbr32 
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	53                   	push   %ebx
  801c8b:	83 ec 04             	sub    $0x4,%esp
  801c8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c99:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c9f:	7f 2e                	jg     801ccf <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ca1:	83 ec 04             	sub    $0x4,%esp
  801ca4:	53                   	push   %ebx
  801ca5:	ff 75 0c             	pushl  0xc(%ebp)
  801ca8:	68 0c 60 80 00       	push   $0x80600c
  801cad:	e8 2e ee ff ff       	call   800ae0 <memmove>
	nsipcbuf.send.req_size = size;
  801cb2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801cbb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  801cc5:	e8 c4 fd ff ff       	call   801a8e <nsipc>
}
  801cca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    
	assert(size < 1600);
  801ccf:	68 90 2a 80 00       	push   $0x802a90
  801cd4:	68 d7 29 80 00       	push   $0x8029d7
  801cd9:	6a 6d                	push   $0x6d
  801cdb:	68 84 2a 80 00       	push   $0x802a84
  801ce0:	e8 0c e5 ff ff       	call   8001f1 <_panic>

00801ce5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ce5:	f3 0f 1e fb          	endbr32 
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfa:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cff:	8b 45 10             	mov    0x10(%ebp),%eax
  801d02:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d07:	b8 09 00 00 00       	mov    $0x9,%eax
  801d0c:	e8 7d fd ff ff       	call   801a8e <nsipc>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d13:	f3 0f 1e fb          	endbr32 
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	56                   	push   %esi
  801d1b:	53                   	push   %ebx
  801d1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff 75 08             	pushl  0x8(%ebp)
  801d25:	e8 cc f1 ff ff       	call   800ef6 <fd2data>
  801d2a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d2c:	83 c4 08             	add    $0x8,%esp
  801d2f:	68 9c 2a 80 00       	push   $0x802a9c
  801d34:	53                   	push   %ebx
  801d35:	e8 a8 eb ff ff       	call   8008e2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d3a:	8b 46 04             	mov    0x4(%esi),%eax
  801d3d:	2b 06                	sub    (%esi),%eax
  801d3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d45:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d4c:	00 00 00 
	stat->st_dev = &devpipe;
  801d4f:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801d56:	30 80 00 
	return 0;
}
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d61:	5b                   	pop    %ebx
  801d62:	5e                   	pop    %esi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d65:	f3 0f 1e fb          	endbr32 
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d73:	53                   	push   %ebx
  801d74:	6a 00                	push   $0x0
  801d76:	e8 1b f0 ff ff       	call   800d96 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d7b:	89 1c 24             	mov    %ebx,(%esp)
  801d7e:	e8 73 f1 ff ff       	call   800ef6 <fd2data>
  801d83:	83 c4 08             	add    $0x8,%esp
  801d86:	50                   	push   %eax
  801d87:	6a 00                	push   $0x0
  801d89:	e8 08 f0 ff ff       	call   800d96 <sys_page_unmap>
}
  801d8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <_pipeisclosed>:
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	57                   	push   %edi
  801d97:	56                   	push   %esi
  801d98:	53                   	push   %ebx
  801d99:	83 ec 1c             	sub    $0x1c,%esp
  801d9c:	89 c7                	mov    %eax,%edi
  801d9e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801da0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801da5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	57                   	push   %edi
  801dac:	e8 5f 05 00 00       	call   802310 <pageref>
  801db1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801db4:	89 34 24             	mov    %esi,(%esp)
  801db7:	e8 54 05 00 00       	call   802310 <pageref>
		nn = thisenv->env_runs;
  801dbc:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801dc2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	39 cb                	cmp    %ecx,%ebx
  801dca:	74 1b                	je     801de7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801dcc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dcf:	75 cf                	jne    801da0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801dd1:	8b 42 58             	mov    0x58(%edx),%eax
  801dd4:	6a 01                	push   $0x1
  801dd6:	50                   	push   %eax
  801dd7:	53                   	push   %ebx
  801dd8:	68 a3 2a 80 00       	push   $0x802aa3
  801ddd:	e8 f6 e4 ff ff       	call   8002d8 <cprintf>
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	eb b9                	jmp    801da0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801de7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dea:	0f 94 c0             	sete   %al
  801ded:	0f b6 c0             	movzbl %al,%eax
}
  801df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <devpipe_write>:
{
  801df8:	f3 0f 1e fb          	endbr32 
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	57                   	push   %edi
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
  801e02:	83 ec 28             	sub    $0x28,%esp
  801e05:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e08:	56                   	push   %esi
  801e09:	e8 e8 f0 ff ff       	call   800ef6 <fd2data>
  801e0e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	bf 00 00 00 00       	mov    $0x0,%edi
  801e18:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e1b:	74 4f                	je     801e6c <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801e20:	8b 0b                	mov    (%ebx),%ecx
  801e22:	8d 51 20             	lea    0x20(%ecx),%edx
  801e25:	39 d0                	cmp    %edx,%eax
  801e27:	72 14                	jb     801e3d <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801e29:	89 da                	mov    %ebx,%edx
  801e2b:	89 f0                	mov    %esi,%eax
  801e2d:	e8 61 ff ff ff       	call   801d93 <_pipeisclosed>
  801e32:	85 c0                	test   %eax,%eax
  801e34:	75 3b                	jne    801e71 <devpipe_write+0x79>
			sys_yield();
  801e36:	e8 ed ee ff ff       	call   800d28 <sys_yield>
  801e3b:	eb e0                	jmp    801e1d <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e40:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e44:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e47:	89 c2                	mov    %eax,%edx
  801e49:	c1 fa 1f             	sar    $0x1f,%edx
  801e4c:	89 d1                	mov    %edx,%ecx
  801e4e:	c1 e9 1b             	shr    $0x1b,%ecx
  801e51:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e54:	83 e2 1f             	and    $0x1f,%edx
  801e57:	29 ca                	sub    %ecx,%edx
  801e59:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e5d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e61:	83 c0 01             	add    $0x1,%eax
  801e64:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e67:	83 c7 01             	add    $0x1,%edi
  801e6a:	eb ac                	jmp    801e18 <devpipe_write+0x20>
	return i;
  801e6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e6f:	eb 05                	jmp    801e76 <devpipe_write+0x7e>
				return 0;
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e79:	5b                   	pop    %ebx
  801e7a:	5e                   	pop    %esi
  801e7b:	5f                   	pop    %edi
  801e7c:	5d                   	pop    %ebp
  801e7d:	c3                   	ret    

00801e7e <devpipe_read>:
{
  801e7e:	f3 0f 1e fb          	endbr32 
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	57                   	push   %edi
  801e86:	56                   	push   %esi
  801e87:	53                   	push   %ebx
  801e88:	83 ec 18             	sub    $0x18,%esp
  801e8b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e8e:	57                   	push   %edi
  801e8f:	e8 62 f0 ff ff       	call   800ef6 <fd2data>
  801e94:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	be 00 00 00 00       	mov    $0x0,%esi
  801e9e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea1:	75 14                	jne    801eb7 <devpipe_read+0x39>
	return i;
  801ea3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea6:	eb 02                	jmp    801eaa <devpipe_read+0x2c>
				return i;
  801ea8:	89 f0                	mov    %esi,%eax
}
  801eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5f                   	pop    %edi
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    
			sys_yield();
  801eb2:	e8 71 ee ff ff       	call   800d28 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801eb7:	8b 03                	mov    (%ebx),%eax
  801eb9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ebc:	75 18                	jne    801ed6 <devpipe_read+0x58>
			if (i > 0)
  801ebe:	85 f6                	test   %esi,%esi
  801ec0:	75 e6                	jne    801ea8 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801ec2:	89 da                	mov    %ebx,%edx
  801ec4:	89 f8                	mov    %edi,%eax
  801ec6:	e8 c8 fe ff ff       	call   801d93 <_pipeisclosed>
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	74 e3                	je     801eb2 <devpipe_read+0x34>
				return 0;
  801ecf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed4:	eb d4                	jmp    801eaa <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ed6:	99                   	cltd   
  801ed7:	c1 ea 1b             	shr    $0x1b,%edx
  801eda:	01 d0                	add    %edx,%eax
  801edc:	83 e0 1f             	and    $0x1f,%eax
  801edf:	29 d0                	sub    %edx,%eax
  801ee1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ee6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801eec:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801eef:	83 c6 01             	add    $0x1,%esi
  801ef2:	eb aa                	jmp    801e9e <devpipe_read+0x20>

00801ef4 <pipe>:
{
  801ef4:	f3 0f 1e fb          	endbr32 
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f03:	50                   	push   %eax
  801f04:	e8 08 f0 ff ff       	call   800f11 <fd_alloc>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	0f 88 23 01 00 00    	js     802039 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f16:	83 ec 04             	sub    $0x4,%esp
  801f19:	68 07 04 00 00       	push   $0x407
  801f1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f21:	6a 00                	push   $0x0
  801f23:	e8 23 ee ff ff       	call   800d4b <sys_page_alloc>
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	0f 88 04 01 00 00    	js     802039 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f3b:	50                   	push   %eax
  801f3c:	e8 d0 ef ff ff       	call   800f11 <fd_alloc>
  801f41:	89 c3                	mov    %eax,%ebx
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	85 c0                	test   %eax,%eax
  801f48:	0f 88 db 00 00 00    	js     802029 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f4e:	83 ec 04             	sub    $0x4,%esp
  801f51:	68 07 04 00 00       	push   $0x407
  801f56:	ff 75 f0             	pushl  -0x10(%ebp)
  801f59:	6a 00                	push   $0x0
  801f5b:	e8 eb ed ff ff       	call   800d4b <sys_page_alloc>
  801f60:	89 c3                	mov    %eax,%ebx
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	85 c0                	test   %eax,%eax
  801f67:	0f 88 bc 00 00 00    	js     802029 <pipe+0x135>
	va = fd2data(fd0);
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	ff 75 f4             	pushl  -0xc(%ebp)
  801f73:	e8 7e ef ff ff       	call   800ef6 <fd2data>
  801f78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f7a:	83 c4 0c             	add    $0xc,%esp
  801f7d:	68 07 04 00 00       	push   $0x407
  801f82:	50                   	push   %eax
  801f83:	6a 00                	push   $0x0
  801f85:	e8 c1 ed ff ff       	call   800d4b <sys_page_alloc>
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	0f 88 82 00 00 00    	js     802019 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f97:	83 ec 0c             	sub    $0xc,%esp
  801f9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f9d:	e8 54 ef ff ff       	call   800ef6 <fd2data>
  801fa2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fa9:	50                   	push   %eax
  801faa:	6a 00                	push   $0x0
  801fac:	56                   	push   %esi
  801fad:	6a 00                	push   $0x0
  801faf:	e8 bd ed ff ff       	call   800d71 <sys_page_map>
  801fb4:	89 c3                	mov    %eax,%ebx
  801fb6:	83 c4 20             	add    $0x20,%esp
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 4e                	js     80200b <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801fbd:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fc5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801fc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fca:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801fd1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fd4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe6:	e8 f7 ee ff ff       	call   800ee2 <fd2num>
  801feb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ff0:	83 c4 04             	add    $0x4,%esp
  801ff3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff6:	e8 e7 ee ff ff       	call   800ee2 <fd2num>
  801ffb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ffe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802001:	83 c4 10             	add    $0x10,%esp
  802004:	bb 00 00 00 00       	mov    $0x0,%ebx
  802009:	eb 2e                	jmp    802039 <pipe+0x145>
	sys_page_unmap(0, va);
  80200b:	83 ec 08             	sub    $0x8,%esp
  80200e:	56                   	push   %esi
  80200f:	6a 00                	push   $0x0
  802011:	e8 80 ed ff ff       	call   800d96 <sys_page_unmap>
  802016:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802019:	83 ec 08             	sub    $0x8,%esp
  80201c:	ff 75 f0             	pushl  -0x10(%ebp)
  80201f:	6a 00                	push   $0x0
  802021:	e8 70 ed ff ff       	call   800d96 <sys_page_unmap>
  802026:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802029:	83 ec 08             	sub    $0x8,%esp
  80202c:	ff 75 f4             	pushl  -0xc(%ebp)
  80202f:	6a 00                	push   $0x0
  802031:	e8 60 ed ff ff       	call   800d96 <sys_page_unmap>
  802036:	83 c4 10             	add    $0x10,%esp
}
  802039:	89 d8                	mov    %ebx,%eax
  80203b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203e:	5b                   	pop    %ebx
  80203f:	5e                   	pop    %esi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    

00802042 <pipeisclosed>:
{
  802042:	f3 0f 1e fb          	endbr32 
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	ff 75 08             	pushl  0x8(%ebp)
  802053:	e8 0f ef ff ff       	call   800f67 <fd_lookup>
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	78 18                	js     802077 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80205f:	83 ec 0c             	sub    $0xc,%esp
  802062:	ff 75 f4             	pushl  -0xc(%ebp)
  802065:	e8 8c ee ff ff       	call   800ef6 <fd2data>
  80206a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80206c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206f:	e8 1f fd ff ff       	call   801d93 <_pipeisclosed>
  802074:	83 c4 10             	add    $0x10,%esp
}
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802079:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80207d:	b8 00 00 00 00       	mov    $0x0,%eax
  802082:	c3                   	ret    

00802083 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802083:	f3 0f 1e fb          	endbr32 
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80208d:	68 bb 2a 80 00       	push   $0x802abb
  802092:	ff 75 0c             	pushl  0xc(%ebp)
  802095:	e8 48 e8 ff ff       	call   8008e2 <strcpy>
	return 0;
}
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
  80209f:	c9                   	leave  
  8020a0:	c3                   	ret    

008020a1 <devcons_write>:
{
  8020a1:	f3 0f 1e fb          	endbr32 
  8020a5:	55                   	push   %ebp
  8020a6:	89 e5                	mov    %esp,%ebp
  8020a8:	57                   	push   %edi
  8020a9:	56                   	push   %esi
  8020aa:	53                   	push   %ebx
  8020ab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020b1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020b6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8020bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020bf:	73 31                	jae    8020f2 <devcons_write+0x51>
		m = n - tot;
  8020c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020c4:	29 f3                	sub    %esi,%ebx
  8020c6:	83 fb 7f             	cmp    $0x7f,%ebx
  8020c9:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8020ce:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020d1:	83 ec 04             	sub    $0x4,%esp
  8020d4:	53                   	push   %ebx
  8020d5:	89 f0                	mov    %esi,%eax
  8020d7:	03 45 0c             	add    0xc(%ebp),%eax
  8020da:	50                   	push   %eax
  8020db:	57                   	push   %edi
  8020dc:	e8 ff e9 ff ff       	call   800ae0 <memmove>
		sys_cputs(buf, m);
  8020e1:	83 c4 08             	add    $0x8,%esp
  8020e4:	53                   	push   %ebx
  8020e5:	57                   	push   %edi
  8020e6:	e8 b1 eb ff ff       	call   800c9c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020eb:	01 de                	add    %ebx,%esi
  8020ed:	83 c4 10             	add    $0x10,%esp
  8020f0:	eb ca                	jmp    8020bc <devcons_write+0x1b>
}
  8020f2:	89 f0                	mov    %esi,%eax
  8020f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    

008020fc <devcons_read>:
{
  8020fc:	f3 0f 1e fb          	endbr32 
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	83 ec 08             	sub    $0x8,%esp
  802106:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80210b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80210f:	74 21                	je     802132 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802111:	e8 a8 eb ff ff       	call   800cbe <sys_cgetc>
  802116:	85 c0                	test   %eax,%eax
  802118:	75 07                	jne    802121 <devcons_read+0x25>
		sys_yield();
  80211a:	e8 09 ec ff ff       	call   800d28 <sys_yield>
  80211f:	eb f0                	jmp    802111 <devcons_read+0x15>
	if (c < 0)
  802121:	78 0f                	js     802132 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802123:	83 f8 04             	cmp    $0x4,%eax
  802126:	74 0c                	je     802134 <devcons_read+0x38>
	*(char*)vbuf = c;
  802128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80212b:	88 02                	mov    %al,(%edx)
	return 1;
  80212d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802132:	c9                   	leave  
  802133:	c3                   	ret    
		return 0;
  802134:	b8 00 00 00 00       	mov    $0x0,%eax
  802139:	eb f7                	jmp    802132 <devcons_read+0x36>

0080213b <cputchar>:
{
  80213b:	f3 0f 1e fb          	endbr32 
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802145:	8b 45 08             	mov    0x8(%ebp),%eax
  802148:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80214b:	6a 01                	push   $0x1
  80214d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802150:	50                   	push   %eax
  802151:	e8 46 eb ff ff       	call   800c9c <sys_cputs>
}
  802156:	83 c4 10             	add    $0x10,%esp
  802159:	c9                   	leave  
  80215a:	c3                   	ret    

0080215b <getchar>:
{
  80215b:	f3 0f 1e fb          	endbr32 
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802165:	6a 01                	push   $0x1
  802167:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80216a:	50                   	push   %eax
  80216b:	6a 00                	push   $0x0
  80216d:	e8 7d f0 ff ff       	call   8011ef <read>
	if (r < 0)
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	85 c0                	test   %eax,%eax
  802177:	78 06                	js     80217f <getchar+0x24>
	if (r < 1)
  802179:	74 06                	je     802181 <getchar+0x26>
	return c;
  80217b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80217f:	c9                   	leave  
  802180:	c3                   	ret    
		return -E_EOF;
  802181:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802186:	eb f7                	jmp    80217f <getchar+0x24>

00802188 <iscons>:
{
  802188:	f3 0f 1e fb          	endbr32 
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802195:	50                   	push   %eax
  802196:	ff 75 08             	pushl  0x8(%ebp)
  802199:	e8 c9 ed ff ff       	call   800f67 <fd_lookup>
  80219e:	83 c4 10             	add    $0x10,%esp
  8021a1:	85 c0                	test   %eax,%eax
  8021a3:	78 11                	js     8021b6 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8021a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a8:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8021ae:	39 10                	cmp    %edx,(%eax)
  8021b0:	0f 94 c0             	sete   %al
  8021b3:	0f b6 c0             	movzbl %al,%eax
}
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <opencons>:
{
  8021b8:	f3 0f 1e fb          	endbr32 
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8021c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c5:	50                   	push   %eax
  8021c6:	e8 46 ed ff ff       	call   800f11 <fd_alloc>
  8021cb:	83 c4 10             	add    $0x10,%esp
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	78 3a                	js     80220c <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d2:	83 ec 04             	sub    $0x4,%esp
  8021d5:	68 07 04 00 00       	push   $0x407
  8021da:	ff 75 f4             	pushl  -0xc(%ebp)
  8021dd:	6a 00                	push   $0x0
  8021df:	e8 67 eb ff ff       	call   800d4b <sys_page_alloc>
  8021e4:	83 c4 10             	add    $0x10,%esp
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	78 21                	js     80220c <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8021eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ee:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8021f4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802200:	83 ec 0c             	sub    $0xc,%esp
  802203:	50                   	push   %eax
  802204:	e8 d9 ec ff ff       	call   800ee2 <fd2num>
  802209:	83 c4 10             	add    $0x10,%esp
}
  80220c:	c9                   	leave  
  80220d:	c3                   	ret    

0080220e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80220e:	f3 0f 1e fb          	endbr32 
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	8b 75 08             	mov    0x8(%ebp),%esi
  80221a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80221d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802220:	85 c0                	test   %eax,%eax
  802222:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802227:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80222a:	83 ec 0c             	sub    $0xc,%esp
  80222d:	50                   	push   %eax
  80222e:	e8 1e ec ff ff       	call   800e51 <sys_ipc_recv>
  802233:	83 c4 10             	add    $0x10,%esp
  802236:	85 c0                	test   %eax,%eax
  802238:	75 2b                	jne    802265 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80223a:	85 f6                	test   %esi,%esi
  80223c:	74 0a                	je     802248 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80223e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802243:	8b 40 74             	mov    0x74(%eax),%eax
  802246:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802248:	85 db                	test   %ebx,%ebx
  80224a:	74 0a                	je     802256 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80224c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802251:	8b 40 78             	mov    0x78(%eax),%eax
  802254:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802256:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80225b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80225e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802265:	85 f6                	test   %esi,%esi
  802267:	74 06                	je     80226f <ipc_recv+0x61>
  802269:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80226f:	85 db                	test   %ebx,%ebx
  802271:	74 eb                	je     80225e <ipc_recv+0x50>
  802273:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802279:	eb e3                	jmp    80225e <ipc_recv+0x50>

0080227b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80227b:	f3 0f 1e fb          	endbr32 
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	57                   	push   %edi
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	83 ec 0c             	sub    $0xc,%esp
  802288:	8b 7d 08             	mov    0x8(%ebp),%edi
  80228b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80228e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802291:	85 db                	test   %ebx,%ebx
  802293:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802298:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80229b:	ff 75 14             	pushl  0x14(%ebp)
  80229e:	53                   	push   %ebx
  80229f:	56                   	push   %esi
  8022a0:	57                   	push   %edi
  8022a1:	e8 84 eb ff ff       	call   800e2a <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8022a6:	83 c4 10             	add    $0x10,%esp
  8022a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ac:	75 07                	jne    8022b5 <ipc_send+0x3a>
			sys_yield();
  8022ae:	e8 75 ea ff ff       	call   800d28 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8022b3:	eb e6                	jmp    80229b <ipc_send+0x20>
		}
		else if (ret == 0)
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	75 08                	jne    8022c1 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8022b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5e                   	pop    %esi
  8022be:	5f                   	pop    %edi
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8022c1:	50                   	push   %eax
  8022c2:	68 c7 2a 80 00       	push   $0x802ac7
  8022c7:	6a 48                	push   $0x48
  8022c9:	68 d5 2a 80 00       	push   $0x802ad5
  8022ce:	e8 1e df ff ff       	call   8001f1 <_panic>

008022d3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022d3:	f3 0f 1e fb          	endbr32 
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022dd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022e2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022e5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022eb:	8b 52 50             	mov    0x50(%edx),%edx
  8022ee:	39 ca                	cmp    %ecx,%edx
  8022f0:	74 11                	je     802303 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8022f2:	83 c0 01             	add    $0x1,%eax
  8022f5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022fa:	75 e6                	jne    8022e2 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8022fc:	b8 00 00 00 00       	mov    $0x0,%eax
  802301:	eb 0b                	jmp    80230e <ipc_find_env+0x3b>
			return envs[i].env_id;
  802303:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802306:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80230b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    

00802310 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802310:	f3 0f 1e fb          	endbr32 
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80231a:	89 c2                	mov    %eax,%edx
  80231c:	c1 ea 16             	shr    $0x16,%edx
  80231f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802326:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80232b:	f6 c1 01             	test   $0x1,%cl
  80232e:	74 1c                	je     80234c <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802330:	c1 e8 0c             	shr    $0xc,%eax
  802333:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80233a:	a8 01                	test   $0x1,%al
  80233c:	74 0e                	je     80234c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80233e:	c1 e8 0c             	shr    $0xc,%eax
  802341:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802348:	ef 
  802349:	0f b7 d2             	movzwl %dx,%edx
}
  80234c:	89 d0                	mov    %edx,%eax
  80234e:	5d                   	pop    %ebp
  80234f:	c3                   	ret    

00802350 <__udivdi3>:
  802350:	f3 0f 1e fb          	endbr32 
  802354:	55                   	push   %ebp
  802355:	57                   	push   %edi
  802356:	56                   	push   %esi
  802357:	53                   	push   %ebx
  802358:	83 ec 1c             	sub    $0x1c,%esp
  80235b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80235f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802363:	8b 74 24 34          	mov    0x34(%esp),%esi
  802367:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80236b:	85 d2                	test   %edx,%edx
  80236d:	75 19                	jne    802388 <__udivdi3+0x38>
  80236f:	39 f3                	cmp    %esi,%ebx
  802371:	76 4d                	jbe    8023c0 <__udivdi3+0x70>
  802373:	31 ff                	xor    %edi,%edi
  802375:	89 e8                	mov    %ebp,%eax
  802377:	89 f2                	mov    %esi,%edx
  802379:	f7 f3                	div    %ebx
  80237b:	89 fa                	mov    %edi,%edx
  80237d:	83 c4 1c             	add    $0x1c,%esp
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5f                   	pop    %edi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    
  802385:	8d 76 00             	lea    0x0(%esi),%esi
  802388:	39 f2                	cmp    %esi,%edx
  80238a:	76 14                	jbe    8023a0 <__udivdi3+0x50>
  80238c:	31 ff                	xor    %edi,%edi
  80238e:	31 c0                	xor    %eax,%eax
  802390:	89 fa                	mov    %edi,%edx
  802392:	83 c4 1c             	add    $0x1c,%esp
  802395:	5b                   	pop    %ebx
  802396:	5e                   	pop    %esi
  802397:	5f                   	pop    %edi
  802398:	5d                   	pop    %ebp
  802399:	c3                   	ret    
  80239a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023a0:	0f bd fa             	bsr    %edx,%edi
  8023a3:	83 f7 1f             	xor    $0x1f,%edi
  8023a6:	75 48                	jne    8023f0 <__udivdi3+0xa0>
  8023a8:	39 f2                	cmp    %esi,%edx
  8023aa:	72 06                	jb     8023b2 <__udivdi3+0x62>
  8023ac:	31 c0                	xor    %eax,%eax
  8023ae:	39 eb                	cmp    %ebp,%ebx
  8023b0:	77 de                	ja     802390 <__udivdi3+0x40>
  8023b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b7:	eb d7                	jmp    802390 <__udivdi3+0x40>
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	89 d9                	mov    %ebx,%ecx
  8023c2:	85 db                	test   %ebx,%ebx
  8023c4:	75 0b                	jne    8023d1 <__udivdi3+0x81>
  8023c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f3                	div    %ebx
  8023cf:	89 c1                	mov    %eax,%ecx
  8023d1:	31 d2                	xor    %edx,%edx
  8023d3:	89 f0                	mov    %esi,%eax
  8023d5:	f7 f1                	div    %ecx
  8023d7:	89 c6                	mov    %eax,%esi
  8023d9:	89 e8                	mov    %ebp,%eax
  8023db:	89 f7                	mov    %esi,%edi
  8023dd:	f7 f1                	div    %ecx
  8023df:	89 fa                	mov    %edi,%edx
  8023e1:	83 c4 1c             	add    $0x1c,%esp
  8023e4:	5b                   	pop    %ebx
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 f9                	mov    %edi,%ecx
  8023f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8023f7:	29 f8                	sub    %edi,%eax
  8023f9:	d3 e2                	shl    %cl,%edx
  8023fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023ff:	89 c1                	mov    %eax,%ecx
  802401:	89 da                	mov    %ebx,%edx
  802403:	d3 ea                	shr    %cl,%edx
  802405:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802409:	09 d1                	or     %edx,%ecx
  80240b:	89 f2                	mov    %esi,%edx
  80240d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802411:	89 f9                	mov    %edi,%ecx
  802413:	d3 e3                	shl    %cl,%ebx
  802415:	89 c1                	mov    %eax,%ecx
  802417:	d3 ea                	shr    %cl,%edx
  802419:	89 f9                	mov    %edi,%ecx
  80241b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80241f:	89 eb                	mov    %ebp,%ebx
  802421:	d3 e6                	shl    %cl,%esi
  802423:	89 c1                	mov    %eax,%ecx
  802425:	d3 eb                	shr    %cl,%ebx
  802427:	09 de                	or     %ebx,%esi
  802429:	89 f0                	mov    %esi,%eax
  80242b:	f7 74 24 08          	divl   0x8(%esp)
  80242f:	89 d6                	mov    %edx,%esi
  802431:	89 c3                	mov    %eax,%ebx
  802433:	f7 64 24 0c          	mull   0xc(%esp)
  802437:	39 d6                	cmp    %edx,%esi
  802439:	72 15                	jb     802450 <__udivdi3+0x100>
  80243b:	89 f9                	mov    %edi,%ecx
  80243d:	d3 e5                	shl    %cl,%ebp
  80243f:	39 c5                	cmp    %eax,%ebp
  802441:	73 04                	jae    802447 <__udivdi3+0xf7>
  802443:	39 d6                	cmp    %edx,%esi
  802445:	74 09                	je     802450 <__udivdi3+0x100>
  802447:	89 d8                	mov    %ebx,%eax
  802449:	31 ff                	xor    %edi,%edi
  80244b:	e9 40 ff ff ff       	jmp    802390 <__udivdi3+0x40>
  802450:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802453:	31 ff                	xor    %edi,%edi
  802455:	e9 36 ff ff ff       	jmp    802390 <__udivdi3+0x40>
  80245a:	66 90                	xchg   %ax,%ax
  80245c:	66 90                	xchg   %ax,%ax
  80245e:	66 90                	xchg   %ax,%ax

00802460 <__umoddi3>:
  802460:	f3 0f 1e fb          	endbr32 
  802464:	55                   	push   %ebp
  802465:	57                   	push   %edi
  802466:	56                   	push   %esi
  802467:	53                   	push   %ebx
  802468:	83 ec 1c             	sub    $0x1c,%esp
  80246b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80246f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802473:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802477:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80247b:	85 c0                	test   %eax,%eax
  80247d:	75 19                	jne    802498 <__umoddi3+0x38>
  80247f:	39 df                	cmp    %ebx,%edi
  802481:	76 5d                	jbe    8024e0 <__umoddi3+0x80>
  802483:	89 f0                	mov    %esi,%eax
  802485:	89 da                	mov    %ebx,%edx
  802487:	f7 f7                	div    %edi
  802489:	89 d0                	mov    %edx,%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	83 c4 1c             	add    $0x1c,%esp
  802490:	5b                   	pop    %ebx
  802491:	5e                   	pop    %esi
  802492:	5f                   	pop    %edi
  802493:	5d                   	pop    %ebp
  802494:	c3                   	ret    
  802495:	8d 76 00             	lea    0x0(%esi),%esi
  802498:	89 f2                	mov    %esi,%edx
  80249a:	39 d8                	cmp    %ebx,%eax
  80249c:	76 12                	jbe    8024b0 <__umoddi3+0x50>
  80249e:	89 f0                	mov    %esi,%eax
  8024a0:	89 da                	mov    %ebx,%edx
  8024a2:	83 c4 1c             	add    $0x1c,%esp
  8024a5:	5b                   	pop    %ebx
  8024a6:	5e                   	pop    %esi
  8024a7:	5f                   	pop    %edi
  8024a8:	5d                   	pop    %ebp
  8024a9:	c3                   	ret    
  8024aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b0:	0f bd e8             	bsr    %eax,%ebp
  8024b3:	83 f5 1f             	xor    $0x1f,%ebp
  8024b6:	75 50                	jne    802508 <__umoddi3+0xa8>
  8024b8:	39 d8                	cmp    %ebx,%eax
  8024ba:	0f 82 e0 00 00 00    	jb     8025a0 <__umoddi3+0x140>
  8024c0:	89 d9                	mov    %ebx,%ecx
  8024c2:	39 f7                	cmp    %esi,%edi
  8024c4:	0f 86 d6 00 00 00    	jbe    8025a0 <__umoddi3+0x140>
  8024ca:	89 d0                	mov    %edx,%eax
  8024cc:	89 ca                	mov    %ecx,%edx
  8024ce:	83 c4 1c             	add    $0x1c,%esp
  8024d1:	5b                   	pop    %ebx
  8024d2:	5e                   	pop    %esi
  8024d3:	5f                   	pop    %edi
  8024d4:	5d                   	pop    %ebp
  8024d5:	c3                   	ret    
  8024d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024dd:	8d 76 00             	lea    0x0(%esi),%esi
  8024e0:	89 fd                	mov    %edi,%ebp
  8024e2:	85 ff                	test   %edi,%edi
  8024e4:	75 0b                	jne    8024f1 <__umoddi3+0x91>
  8024e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	f7 f7                	div    %edi
  8024ef:	89 c5                	mov    %eax,%ebp
  8024f1:	89 d8                	mov    %ebx,%eax
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	f7 f5                	div    %ebp
  8024f7:	89 f0                	mov    %esi,%eax
  8024f9:	f7 f5                	div    %ebp
  8024fb:	89 d0                	mov    %edx,%eax
  8024fd:	31 d2                	xor    %edx,%edx
  8024ff:	eb 8c                	jmp    80248d <__umoddi3+0x2d>
  802501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802508:	89 e9                	mov    %ebp,%ecx
  80250a:	ba 20 00 00 00       	mov    $0x20,%edx
  80250f:	29 ea                	sub    %ebp,%edx
  802511:	d3 e0                	shl    %cl,%eax
  802513:	89 44 24 08          	mov    %eax,0x8(%esp)
  802517:	89 d1                	mov    %edx,%ecx
  802519:	89 f8                	mov    %edi,%eax
  80251b:	d3 e8                	shr    %cl,%eax
  80251d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802521:	89 54 24 04          	mov    %edx,0x4(%esp)
  802525:	8b 54 24 04          	mov    0x4(%esp),%edx
  802529:	09 c1                	or     %eax,%ecx
  80252b:	89 d8                	mov    %ebx,%eax
  80252d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802531:	89 e9                	mov    %ebp,%ecx
  802533:	d3 e7                	shl    %cl,%edi
  802535:	89 d1                	mov    %edx,%ecx
  802537:	d3 e8                	shr    %cl,%eax
  802539:	89 e9                	mov    %ebp,%ecx
  80253b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80253f:	d3 e3                	shl    %cl,%ebx
  802541:	89 c7                	mov    %eax,%edi
  802543:	89 d1                	mov    %edx,%ecx
  802545:	89 f0                	mov    %esi,%eax
  802547:	d3 e8                	shr    %cl,%eax
  802549:	89 e9                	mov    %ebp,%ecx
  80254b:	89 fa                	mov    %edi,%edx
  80254d:	d3 e6                	shl    %cl,%esi
  80254f:	09 d8                	or     %ebx,%eax
  802551:	f7 74 24 08          	divl   0x8(%esp)
  802555:	89 d1                	mov    %edx,%ecx
  802557:	89 f3                	mov    %esi,%ebx
  802559:	f7 64 24 0c          	mull   0xc(%esp)
  80255d:	89 c6                	mov    %eax,%esi
  80255f:	89 d7                	mov    %edx,%edi
  802561:	39 d1                	cmp    %edx,%ecx
  802563:	72 06                	jb     80256b <__umoddi3+0x10b>
  802565:	75 10                	jne    802577 <__umoddi3+0x117>
  802567:	39 c3                	cmp    %eax,%ebx
  802569:	73 0c                	jae    802577 <__umoddi3+0x117>
  80256b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80256f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802573:	89 d7                	mov    %edx,%edi
  802575:	89 c6                	mov    %eax,%esi
  802577:	89 ca                	mov    %ecx,%edx
  802579:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80257e:	29 f3                	sub    %esi,%ebx
  802580:	19 fa                	sbb    %edi,%edx
  802582:	89 d0                	mov    %edx,%eax
  802584:	d3 e0                	shl    %cl,%eax
  802586:	89 e9                	mov    %ebp,%ecx
  802588:	d3 eb                	shr    %cl,%ebx
  80258a:	d3 ea                	shr    %cl,%edx
  80258c:	09 d8                	or     %ebx,%eax
  80258e:	83 c4 1c             	add    $0x1c,%esp
  802591:	5b                   	pop    %ebx
  802592:	5e                   	pop    %esi
  802593:	5f                   	pop    %edi
  802594:	5d                   	pop    %ebp
  802595:	c3                   	ret    
  802596:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	29 fe                	sub    %edi,%esi
  8025a2:	19 c3                	sbb    %eax,%ebx
  8025a4:	89 f2                	mov    %esi,%edx
  8025a6:	89 d9                	mov    %ebx,%ecx
  8025a8:	e9 1d ff ff ff       	jmp    8024ca <__umoddi3+0x6a>
