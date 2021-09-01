
obj/user/testtime.debug:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
	unsigned now = sys_time_msec();
  80003e:	e8 a5 0d 00 00       	call   800de8 <sys_time_msec>
	unsigned end = now + sec * 1000;
  800043:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx
  80004a:	01 c3                	add    %eax,%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
  80004c:	85 c0                	test   %eax,%eax
  80004e:	79 05                	jns    800055 <sleep+0x22>
  800050:	83 f8 f1             	cmp    $0xfffffff1,%eax
  800053:	7d 18                	jge    80006d <sleep+0x3a>
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
  800055:	39 d8                	cmp    %ebx,%eax
  800057:	76 2b                	jbe    800084 <sleep+0x51>
		panic("sleep: wrap");
  800059:	83 ec 04             	sub    $0x4,%esp
  80005c:	68 22 24 80 00       	push   $0x802422
  800061:	6a 0d                	push   $0xd
  800063:	68 12 24 80 00       	push   $0x802412
  800068:	e8 f7 00 00 00       	call   800164 <_panic>
		panic("sys_time_msec: %e", (int)now);
  80006d:	50                   	push   %eax
  80006e:	68 00 24 80 00       	push   $0x802400
  800073:	6a 0b                	push   $0xb
  800075:	68 12 24 80 00       	push   $0x802412
  80007a:	e8 e5 00 00 00       	call   800164 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  80007f:	e8 17 0c 00 00       	call   800c9b <sys_yield>
	while (sys_time_msec() < end)
  800084:	e8 5f 0d 00 00       	call   800de8 <sys_time_msec>
  800089:	39 d8                	cmp    %ebx,%eax
  80008b:	72 f2                	jb     80007f <sleep+0x4c>
}
  80008d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <umain>:

void
umain(int argc, char **argv)
{
  800092:	f3 0f 1e fb          	endbr32 
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	53                   	push   %ebx
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  8000a2:	e8 f4 0b 00 00       	call   800c9b <sys_yield>
	for (i = 0; i < 50; i++)
  8000a7:	83 eb 01             	sub    $0x1,%ebx
  8000aa:	75 f6                	jne    8000a2 <umain+0x10>

	cprintf("starting count down: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 2e 24 80 00       	push   $0x80242e
  8000b4:	e8 92 01 00 00       	call   80024b <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000bc:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	53                   	push   %ebx
  8000c5:	68 44 24 80 00       	push   $0x802444
  8000ca:	e8 7c 01 00 00       	call   80024b <cprintf>
		sleep(1);
  8000cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000d6:	e8 58 ff ff ff       	call   800033 <sleep>
	for (i = 5; i >= 0; i--) {
  8000db:	83 eb 01             	sub    $0x1,%ebx
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000e4:	75 db                	jne    8000c1 <umain+0x2f>
	}
	cprintf("\n");
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	68 f4 28 80 00       	push   $0x8028f4
  8000ee:	e8 58 01 00 00       	call   80024b <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8000f3:	cc                   	int3   
	breakpoint();
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	f3 0f 1e fb          	endbr32 
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800108:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010b:	e8 68 0b 00 00       	call   800c78 <sys_getenvid>
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800118:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011d:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800122:	85 db                	test   %ebx,%ebx
  800124:	7e 07                	jle    80012d <libmain+0x31>
		binaryname = argv[0];
  800126:	8b 06                	mov    (%esi),%eax
  800128:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
  800132:	e8 5b ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  800137:	e8 0a 00 00 00       	call   800146 <exit>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800146:	f3 0f 1e fb          	endbr32 
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800150:	e8 f4 0e 00 00       	call   801049 <close_all>
	sys_env_destroy(0);
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	6a 00                	push   $0x0
  80015a:	e8 f5 0a 00 00       	call   800c54 <sys_env_destroy>
}
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	f3 0f 1e fb          	endbr32 
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80016d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800170:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800176:	e8 fd 0a 00 00       	call   800c78 <sys_getenvid>
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	ff 75 0c             	pushl  0xc(%ebp)
  800181:	ff 75 08             	pushl  0x8(%ebp)
  800184:	56                   	push   %esi
  800185:	50                   	push   %eax
  800186:	68 54 24 80 00       	push   $0x802454
  80018b:	e8 bb 00 00 00       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800190:	83 c4 18             	add    $0x18,%esp
  800193:	53                   	push   %ebx
  800194:	ff 75 10             	pushl  0x10(%ebp)
  800197:	e8 5a 00 00 00       	call   8001f6 <vcprintf>
	cprintf("\n");
  80019c:	c7 04 24 f4 28 80 00 	movl   $0x8028f4,(%esp)
  8001a3:	e8 a3 00 00 00       	call   80024b <cprintf>
  8001a8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ab:	cc                   	int3   
  8001ac:	eb fd                	jmp    8001ab <_panic+0x47>

008001ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ae:	f3 0f 1e fb          	endbr32 
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 04             	sub    $0x4,%esp
  8001b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001bc:	8b 13                	mov    (%ebx),%edx
  8001be:	8d 42 01             	lea    0x1(%edx),%eax
  8001c1:	89 03                	mov    %eax,(%ebx)
  8001c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cf:	74 09                	je     8001da <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001da:	83 ec 08             	sub    $0x8,%esp
  8001dd:	68 ff 00 00 00       	push   $0xff
  8001e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e5:	50                   	push   %eax
  8001e6:	e8 24 0a 00 00       	call   800c0f <sys_cputs>
		b->idx = 0;
  8001eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	eb db                	jmp    8001d1 <putch+0x23>

008001f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f6:	f3 0f 1e fb          	endbr32 
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800203:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020a:	00 00 00 
	b.cnt = 0;
  80020d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800214:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800217:	ff 75 0c             	pushl  0xc(%ebp)
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	68 ae 01 80 00       	push   $0x8001ae
  800229:	e8 20 01 00 00       	call   80034e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022e:	83 c4 08             	add    $0x8,%esp
  800231:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800237:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023d:	50                   	push   %eax
  80023e:	e8 cc 09 00 00       	call   800c0f <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	f3 0f 1e fb          	endbr32 
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800255:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800258:	50                   	push   %eax
  800259:	ff 75 08             	pushl  0x8(%ebp)
  80025c:	e8 95 ff ff ff       	call   8001f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 1c             	sub    $0x1c,%esp
  80026c:	89 c7                	mov    %eax,%edi
  80026e:	89 d6                	mov    %edx,%esi
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	8b 55 0c             	mov    0xc(%ebp),%edx
  800276:	89 d1                	mov    %edx,%ecx
  800278:	89 c2                	mov    %eax,%edx
  80027a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800280:	8b 45 10             	mov    0x10(%ebp),%eax
  800283:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800286:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800289:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800290:	39 c2                	cmp    %eax,%edx
  800292:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800295:	72 3e                	jb     8002d5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	ff 75 18             	pushl  0x18(%ebp)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	53                   	push   %ebx
  8002a1:	50                   	push   %eax
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b1:	e8 ea 1e 00 00       	call   8021a0 <__udivdi3>
  8002b6:	83 c4 18             	add    $0x18,%esp
  8002b9:	52                   	push   %edx
  8002ba:	50                   	push   %eax
  8002bb:	89 f2                	mov    %esi,%edx
  8002bd:	89 f8                	mov    %edi,%eax
  8002bf:	e8 9f ff ff ff       	call   800263 <printnum>
  8002c4:	83 c4 20             	add    $0x20,%esp
  8002c7:	eb 13                	jmp    8002dc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	ff 75 18             	pushl  0x18(%ebp)
  8002d0:	ff d7                	call   *%edi
  8002d2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002d5:	83 eb 01             	sub    $0x1,%ebx
  8002d8:	85 db                	test   %ebx,%ebx
  8002da:	7f ed                	jg     8002c9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002dc:	83 ec 08             	sub    $0x8,%esp
  8002df:	56                   	push   %esi
  8002e0:	83 ec 04             	sub    $0x4,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 bc 1f 00 00       	call   8022b0 <__umoddi3>
  8002f4:	83 c4 14             	add    $0x14,%esp
  8002f7:	0f be 80 77 24 80 00 	movsbl 0x802477(%eax),%eax
  8002fe:	50                   	push   %eax
  8002ff:	ff d7                	call   *%edi
}
  800301:	83 c4 10             	add    $0x10,%esp
  800304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800307:	5b                   	pop    %ebx
  800308:	5e                   	pop    %esi
  800309:	5f                   	pop    %edi
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030c:	f3 0f 1e fb          	endbr32 
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800316:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	3b 50 04             	cmp    0x4(%eax),%edx
  80031f:	73 0a                	jae    80032b <sprintputch+0x1f>
		*b->buf++ = ch;
  800321:	8d 4a 01             	lea    0x1(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	88 02                	mov    %al,(%edx)
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <printfmt>:
{
  80032d:	f3 0f 1e fb          	endbr32 
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800337:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033a:	50                   	push   %eax
  80033b:	ff 75 10             	pushl  0x10(%ebp)
  80033e:	ff 75 0c             	pushl  0xc(%ebp)
  800341:	ff 75 08             	pushl  0x8(%ebp)
  800344:	e8 05 00 00 00       	call   80034e <vprintfmt>
}
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <vprintfmt>:
{
  80034e:	f3 0f 1e fb          	endbr32 
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	57                   	push   %edi
  800356:	56                   	push   %esi
  800357:	53                   	push   %ebx
  800358:	83 ec 3c             	sub    $0x3c,%esp
  80035b:	8b 75 08             	mov    0x8(%ebp),%esi
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800361:	8b 7d 10             	mov    0x10(%ebp),%edi
  800364:	e9 8e 03 00 00       	jmp    8006f7 <vprintfmt+0x3a9>
		padc = ' ';
  800369:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80036d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800374:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8d 47 01             	lea    0x1(%edi),%eax
  80038a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038d:	0f b6 17             	movzbl (%edi),%edx
  800390:	8d 42 dd             	lea    -0x23(%edx),%eax
  800393:	3c 55                	cmp    $0x55,%al
  800395:	0f 87 df 03 00 00    	ja     80077a <vprintfmt+0x42c>
  80039b:	0f b6 c0             	movzbl %al,%eax
  80039e:	3e ff 24 85 c0 25 80 	notrack jmp *0x8025c0(,%eax,4)
  8003a5:	00 
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003a9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003ad:	eb d8                	jmp    800387 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b2:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003b6:	eb cf                	jmp    800387 <vprintfmt+0x39>
  8003b8:	0f b6 d2             	movzbl %dl,%edx
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003cd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003d0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003d3:	83 f9 09             	cmp    $0x9,%ecx
  8003d6:	77 55                	ja     80042d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003d8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003db:	eb e9                	jmp    8003c6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 40 04             	lea    0x4(%eax),%eax
  8003eb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f5:	79 90                	jns    800387 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800404:	eb 81                	jmp    800387 <vprintfmt+0x39>
  800406:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800409:	85 c0                	test   %eax,%eax
  80040b:	ba 00 00 00 00       	mov    $0x0,%edx
  800410:	0f 49 d0             	cmovns %eax,%edx
  800413:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800419:	e9 69 ff ff ff       	jmp    800387 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800421:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800428:	e9 5a ff ff ff       	jmp    800387 <vprintfmt+0x39>
  80042d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800430:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800433:	eb bc                	jmp    8003f1 <vprintfmt+0xa3>
			lflag++;
  800435:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043b:	e9 47 ff ff ff       	jmp    800387 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 78 04             	lea    0x4(%eax),%edi
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	ff 30                	pushl  (%eax)
  80044c:	ff d6                	call   *%esi
			break;
  80044e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800454:	e9 9b 02 00 00       	jmp    8006f4 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 78 04             	lea    0x4(%eax),%edi
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	99                   	cltd   
  800462:	31 d0                	xor    %edx,%eax
  800464:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800466:	83 f8 0f             	cmp    $0xf,%eax
  800469:	7f 23                	jg     80048e <vprintfmt+0x140>
  80046b:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  800472:	85 d2                	test   %edx,%edx
  800474:	74 18                	je     80048e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800476:	52                   	push   %edx
  800477:	68 29 28 80 00       	push   $0x802829
  80047c:	53                   	push   %ebx
  80047d:	56                   	push   %esi
  80047e:	e8 aa fe ff ff       	call   80032d <printfmt>
  800483:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800486:	89 7d 14             	mov    %edi,0x14(%ebp)
  800489:	e9 66 02 00 00       	jmp    8006f4 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 8f 24 80 00       	push   $0x80248f
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 92 fe ff ff       	call   80032d <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80049e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 4e 02 00 00       	jmp    8006f4 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	83 c0 04             	add    $0x4,%eax
  8004ac:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004b4:	85 d2                	test   %edx,%edx
  8004b6:	b8 88 24 80 00       	mov    $0x802488,%eax
  8004bb:	0f 45 c2             	cmovne %edx,%eax
  8004be:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	7e 06                	jle    8004cd <vprintfmt+0x17f>
  8004c7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004cb:	75 0d                	jne    8004da <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d0:	89 c7                	mov    %eax,%edi
  8004d2:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d8:	eb 55                	jmp    80052f <vprintfmt+0x1e1>
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e0:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e3:	e8 46 03 00 00       	call   80082e <strnlen>
  8004e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004eb:	29 c2                	sub    %eax,%edx
  8004ed:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004f5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	7e 11                	jle    800511 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	ff 75 e0             	pushl  -0x20(%ebp)
  800507:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	83 ef 01             	sub    $0x1,%edi
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb eb                	jmp    8004fc <vprintfmt+0x1ae>
  800511:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	b8 00 00 00 00       	mov    $0x0,%eax
  80051b:	0f 49 c2             	cmovns %edx,%eax
  80051e:	29 c2                	sub    %eax,%edx
  800520:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800523:	eb a8                	jmp    8004cd <vprintfmt+0x17f>
					putch(ch, putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	52                   	push   %edx
  80052a:	ff d6                	call   *%esi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800532:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800534:	83 c7 01             	add    $0x1,%edi
  800537:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053b:	0f be d0             	movsbl %al,%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	74 4b                	je     80058d <vprintfmt+0x23f>
  800542:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800546:	78 06                	js     80054e <vprintfmt+0x200>
  800548:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80054c:	78 1e                	js     80056c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  80054e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800552:	74 d1                	je     800525 <vprintfmt+0x1d7>
  800554:	0f be c0             	movsbl %al,%eax
  800557:	83 e8 20             	sub    $0x20,%eax
  80055a:	83 f8 5e             	cmp    $0x5e,%eax
  80055d:	76 c6                	jbe    800525 <vprintfmt+0x1d7>
					putch('?', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	53                   	push   %ebx
  800563:	6a 3f                	push   $0x3f
  800565:	ff d6                	call   *%esi
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	eb c3                	jmp    80052f <vprintfmt+0x1e1>
  80056c:	89 cf                	mov    %ecx,%edi
  80056e:	eb 0e                	jmp    80057e <vprintfmt+0x230>
				putch(' ', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	6a 20                	push   $0x20
  800576:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800578:	83 ef 01             	sub    $0x1,%edi
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	85 ff                	test   %edi,%edi
  800580:	7f ee                	jg     800570 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800582:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
  800588:	e9 67 01 00 00       	jmp    8006f4 <vprintfmt+0x3a6>
  80058d:	89 cf                	mov    %ecx,%edi
  80058f:	eb ed                	jmp    80057e <vprintfmt+0x230>
	if (lflag >= 2)
  800591:	83 f9 01             	cmp    $0x1,%ecx
  800594:	7f 1b                	jg     8005b1 <vprintfmt+0x263>
	else if (lflag)
  800596:	85 c9                	test   %ecx,%ecx
  800598:	74 63                	je     8005fd <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a2:	99                   	cltd   
  8005a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8005af:	eb 17                	jmp    8005c8 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 50 04             	mov    0x4(%eax),%edx
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 40 08             	lea    0x8(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	0f 89 ff 00 00 00    	jns    8006da <vprintfmt+0x38c>
				putch('-', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 2d                	push   $0x2d
  8005e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e9:	f7 da                	neg    %edx
  8005eb:	83 d1 00             	adc    $0x0,%ecx
  8005ee:	f7 d9                	neg    %ecx
  8005f0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f8:	e9 dd 00 00 00       	jmp    8006da <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	99                   	cltd   
  800606:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 40 04             	lea    0x4(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
  800612:	eb b4                	jmp    8005c8 <vprintfmt+0x27a>
	if (lflag >= 2)
  800614:	83 f9 01             	cmp    $0x1,%ecx
  800617:	7f 1e                	jg     800637 <vprintfmt+0x2e9>
	else if (lflag)
  800619:	85 c9                	test   %ecx,%ecx
  80061b:	74 32                	je     80064f <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800632:	e9 a3 00 00 00       	jmp    8006da <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	8b 48 04             	mov    0x4(%eax),%ecx
  80063f:	8d 40 08             	lea    0x8(%eax),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800645:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80064a:	e9 8b 00 00 00       	jmp    8006da <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 10                	mov    (%eax),%edx
  800654:	b9 00 00 00 00       	mov    $0x0,%ecx
  800659:	8d 40 04             	lea    0x4(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80065f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800664:	eb 74                	jmp    8006da <vprintfmt+0x38c>
	if (lflag >= 2)
  800666:	83 f9 01             	cmp    $0x1,%ecx
  800669:	7f 1b                	jg     800686 <vprintfmt+0x338>
	else if (lflag)
  80066b:	85 c9                	test   %ecx,%ecx
  80066d:	74 2c                	je     80069b <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	b9 00 00 00 00       	mov    $0x0,%ecx
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800684:	eb 54                	jmp    8006da <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 10                	mov    (%eax),%edx
  80068b:	8b 48 04             	mov    0x4(%eax),%ecx
  80068e:	8d 40 08             	lea    0x8(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800694:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800699:	eb 3f                	jmp    8006da <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a5:	8d 40 04             	lea    0x4(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ab:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006b0:	eb 28                	jmp    8006da <vprintfmt+0x38c>
			putch('0', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 30                	push   $0x30
  8006b8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ba:	83 c4 08             	add    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	6a 78                	push   $0x78
  8006c0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 10                	mov    (%eax),%edx
  8006c7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006cc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006da:	83 ec 0c             	sub    $0xc,%esp
  8006dd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006e1:	57                   	push   %edi
  8006e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e5:	50                   	push   %eax
  8006e6:	51                   	push   %ecx
  8006e7:	52                   	push   %edx
  8006e8:	89 da                	mov    %ebx,%edx
  8006ea:	89 f0                	mov    %esi,%eax
  8006ec:	e8 72 fb ff ff       	call   800263 <printnum>
			break;
  8006f1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006f7:	83 c7 01             	add    $0x1,%edi
  8006fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006fe:	83 f8 25             	cmp    $0x25,%eax
  800701:	0f 84 62 fc ff ff    	je     800369 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800707:	85 c0                	test   %eax,%eax
  800709:	0f 84 8b 00 00 00    	je     80079a <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	50                   	push   %eax
  800714:	ff d6                	call   *%esi
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb dc                	jmp    8006f7 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80071b:	83 f9 01             	cmp    $0x1,%ecx
  80071e:	7f 1b                	jg     80073b <vprintfmt+0x3ed>
	else if (lflag)
  800720:	85 c9                	test   %ecx,%ecx
  800722:	74 2c                	je     800750 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 10                	mov    (%eax),%edx
  800729:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072e:	8d 40 04             	lea    0x4(%eax),%eax
  800731:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800734:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800739:	eb 9f                	jmp    8006da <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8b 10                	mov    (%eax),%edx
  800740:	8b 48 04             	mov    0x4(%eax),%ecx
  800743:	8d 40 08             	lea    0x8(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800749:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80074e:	eb 8a                	jmp    8006da <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075a:	8d 40 04             	lea    0x4(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800760:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800765:	e9 70 ff ff ff       	jmp    8006da <vprintfmt+0x38c>
			putch(ch, putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 25                	push   $0x25
  800770:	ff d6                	call   *%esi
			break;
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	e9 7a ff ff ff       	jmp    8006f4 <vprintfmt+0x3a6>
			putch('%', putdat);
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	53                   	push   %ebx
  80077e:	6a 25                	push   $0x25
  800780:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	89 f8                	mov    %edi,%eax
  800787:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80078b:	74 05                	je     800792 <vprintfmt+0x444>
  80078d:	83 e8 01             	sub    $0x1,%eax
  800790:	eb f5                	jmp    800787 <vprintfmt+0x439>
  800792:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800795:	e9 5a ff ff ff       	jmp    8006f4 <vprintfmt+0x3a6>
}
  80079a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a2:	f3 0f 1e fb          	endbr32 
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 18             	sub    $0x18,%esp
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	74 26                	je     8007ed <vsnprintf+0x4b>
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	7e 22                	jle    8007ed <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cb:	ff 75 14             	pushl  0x14(%ebp)
  8007ce:	ff 75 10             	pushl  0x10(%ebp)
  8007d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	68 0c 03 80 00       	push   $0x80030c
  8007da:	e8 6f fb ff ff       	call   80034e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e8:	83 c4 10             	add    $0x10,%esp
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
		return -E_INVAL;
  8007ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f2:	eb f7                	jmp    8007eb <vsnprintf+0x49>

008007f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f4:	f3 0f 1e fb          	endbr32 
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800801:	50                   	push   %eax
  800802:	ff 75 10             	pushl  0x10(%ebp)
  800805:	ff 75 0c             	pushl  0xc(%ebp)
  800808:	ff 75 08             	pushl  0x8(%ebp)
  80080b:	e8 92 ff ff ff       	call   8007a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800812:	f3 0f 1e fb          	endbr32 
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
  800821:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800825:	74 05                	je     80082c <strlen+0x1a>
		n++;
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	eb f5                	jmp    800821 <strlen+0xf>
	return n;
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082e:	f3 0f 1e fb          	endbr32 
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
  800840:	39 d0                	cmp    %edx,%eax
  800842:	74 0d                	je     800851 <strnlen+0x23>
  800844:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800848:	74 05                	je     80084f <strnlen+0x21>
		n++;
  80084a:	83 c0 01             	add    $0x1,%eax
  80084d:	eb f1                	jmp    800840 <strnlen+0x12>
  80084f:	89 c2                	mov    %eax,%edx
	return n;
}
  800851:	89 d0                	mov    %edx,%eax
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800855:	f3 0f 1e fb          	endbr32 
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80086c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	84 d2                	test   %dl,%dl
  800874:	75 f2                	jne    800868 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800876:	89 c8                	mov    %ecx,%eax
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087b:	f3 0f 1e fb          	endbr32 
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	53                   	push   %ebx
  800883:	83 ec 10             	sub    $0x10,%esp
  800886:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800889:	53                   	push   %ebx
  80088a:	e8 83 ff ff ff       	call   800812 <strlen>
  80088f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800892:	ff 75 0c             	pushl  0xc(%ebp)
  800895:	01 d8                	add    %ebx,%eax
  800897:	50                   	push   %eax
  800898:	e8 b8 ff ff ff       	call   800855 <strcpy>
	return dst;
}
  80089d:	89 d8                	mov    %ebx,%eax
  80089f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a4:	f3 0f 1e fb          	endbr32 
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	56                   	push   %esi
  8008ac:	53                   	push   %ebx
  8008ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b3:	89 f3                	mov    %esi,%ebx
  8008b5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b8:	89 f0                	mov    %esi,%eax
  8008ba:	39 d8                	cmp    %ebx,%eax
  8008bc:	74 11                	je     8008cf <strncpy+0x2b>
		*dst++ = *src;
  8008be:	83 c0 01             	add    $0x1,%eax
  8008c1:	0f b6 0a             	movzbl (%edx),%ecx
  8008c4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c7:	80 f9 01             	cmp    $0x1,%cl
  8008ca:	83 da ff             	sbb    $0xffffffff,%edx
  8008cd:	eb eb                	jmp    8008ba <strncpy+0x16>
	}
	return ret;
}
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d5:	f3 0f 1e fb          	endbr32 
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e9:	85 d2                	test   %edx,%edx
  8008eb:	74 21                	je     80090e <strlcpy+0x39>
  8008ed:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008f1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008f3:	39 c2                	cmp    %eax,%edx
  8008f5:	74 14                	je     80090b <strlcpy+0x36>
  8008f7:	0f b6 19             	movzbl (%ecx),%ebx
  8008fa:	84 db                	test   %bl,%bl
  8008fc:	74 0b                	je     800909 <strlcpy+0x34>
			*dst++ = *src++;
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	88 5a ff             	mov    %bl,-0x1(%edx)
  800907:	eb ea                	jmp    8008f3 <strlcpy+0x1e>
  800909:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80090b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80090e:	29 f0                	sub    %esi,%eax
}
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800914:	f3 0f 1e fb          	endbr32 
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800921:	0f b6 01             	movzbl (%ecx),%eax
  800924:	84 c0                	test   %al,%al
  800926:	74 0c                	je     800934 <strcmp+0x20>
  800928:	3a 02                	cmp    (%edx),%al
  80092a:	75 08                	jne    800934 <strcmp+0x20>
		p++, q++;
  80092c:	83 c1 01             	add    $0x1,%ecx
  80092f:	83 c2 01             	add    $0x1,%edx
  800932:	eb ed                	jmp    800921 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800934:	0f b6 c0             	movzbl %al,%eax
  800937:	0f b6 12             	movzbl (%edx),%edx
  80093a:	29 d0                	sub    %edx,%eax
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093e:	f3 0f 1e fb          	endbr32 
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094c:	89 c3                	mov    %eax,%ebx
  80094e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800951:	eb 06                	jmp    800959 <strncmp+0x1b>
		n--, p++, q++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800959:	39 d8                	cmp    %ebx,%eax
  80095b:	74 16                	je     800973 <strncmp+0x35>
  80095d:	0f b6 08             	movzbl (%eax),%ecx
  800960:	84 c9                	test   %cl,%cl
  800962:	74 04                	je     800968 <strncmp+0x2a>
  800964:	3a 0a                	cmp    (%edx),%cl
  800966:	74 eb                	je     800953 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5b                   	pop    %ebx
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    
		return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
  800978:	eb f6                	jmp    800970 <strncmp+0x32>

0080097a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097a:	f3 0f 1e fb          	endbr32 
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	0f b6 10             	movzbl (%eax),%edx
  80098b:	84 d2                	test   %dl,%dl
  80098d:	74 09                	je     800998 <strchr+0x1e>
		if (*s == c)
  80098f:	38 ca                	cmp    %cl,%dl
  800991:	74 0a                	je     80099d <strchr+0x23>
	for (; *s; s++)
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	eb f0                	jmp    800988 <strchr+0xe>
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  80099f:	f3 0f 1e fb          	endbr32 
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  8009a9:	6a 78                	push   $0x78
  8009ab:	ff 75 08             	pushl  0x8(%ebp)
  8009ae:	e8 c7 ff ff ff       	call   80097a <strchr>
  8009b3:	83 c4 10             	add    $0x10,%esp
  8009b6:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  8009be:	eb 0d                	jmp    8009cd <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  8009c0:	c1 e0 04             	shl    $0x4,%eax
  8009c3:	0f be d2             	movsbl %dl,%edx
  8009c6:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  8009ca:	83 c1 01             	add    $0x1,%ecx
  8009cd:	0f b6 11             	movzbl (%ecx),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	74 11                	je     8009e5 <atox+0x46>
		if (*p>='a'){
  8009d4:	80 fa 60             	cmp    $0x60,%dl
  8009d7:	7e e7                	jle    8009c0 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8009d9:	c1 e0 04             	shl    $0x4,%eax
  8009dc:	0f be d2             	movsbl %dl,%edx
  8009df:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009e3:	eb e5                	jmp    8009ca <atox+0x2b>
	}

	return v;

}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e7:	f3 0f 1e fb          	endbr32 
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f8:	38 ca                	cmp    %cl,%dl
  8009fa:	74 09                	je     800a05 <strfind+0x1e>
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	74 05                	je     800a05 <strfind+0x1e>
	for (; *s; s++)
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	eb f0                	jmp    8009f5 <strfind+0xe>
			break;
	return (char *) s;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a07:	f3 0f 1e fb          	endbr32 
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a14:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a17:	85 c9                	test   %ecx,%ecx
  800a19:	74 31                	je     800a4c <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1b:	89 f8                	mov    %edi,%eax
  800a1d:	09 c8                	or     %ecx,%eax
  800a1f:	a8 03                	test   $0x3,%al
  800a21:	75 23                	jne    800a46 <memset+0x3f>
		c &= 0xFF;
  800a23:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a27:	89 d3                	mov    %edx,%ebx
  800a29:	c1 e3 08             	shl    $0x8,%ebx
  800a2c:	89 d0                	mov    %edx,%eax
  800a2e:	c1 e0 18             	shl    $0x18,%eax
  800a31:	89 d6                	mov    %edx,%esi
  800a33:	c1 e6 10             	shl    $0x10,%esi
  800a36:	09 f0                	or     %esi,%eax
  800a38:	09 c2                	or     %eax,%edx
  800a3a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3f:	89 d0                	mov    %edx,%eax
  800a41:	fc                   	cld    
  800a42:	f3 ab                	rep stos %eax,%es:(%edi)
  800a44:	eb 06                	jmp    800a4c <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	fc                   	cld    
  800a4a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4c:	89 f8                	mov    %edi,%eax
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a53:	f3 0f 1e fb          	endbr32 
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a65:	39 c6                	cmp    %eax,%esi
  800a67:	73 32                	jae    800a9b <memmove+0x48>
  800a69:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6c:	39 c2                	cmp    %eax,%edx
  800a6e:	76 2b                	jbe    800a9b <memmove+0x48>
		s += n;
		d += n;
  800a70:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a73:	89 fe                	mov    %edi,%esi
  800a75:	09 ce                	or     %ecx,%esi
  800a77:	09 d6                	or     %edx,%esi
  800a79:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7f:	75 0e                	jne    800a8f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a81:	83 ef 04             	sub    $0x4,%edi
  800a84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a87:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a8a:	fd                   	std    
  800a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8d:	eb 09                	jmp    800a98 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a8f:	83 ef 01             	sub    $0x1,%edi
  800a92:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a95:	fd                   	std    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a98:	fc                   	cld    
  800a99:	eb 1a                	jmp    800ab5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	89 c2                	mov    %eax,%edx
  800a9d:	09 ca                	or     %ecx,%edx
  800a9f:	09 f2                	or     %esi,%edx
  800aa1:	f6 c2 03             	test   $0x3,%dl
  800aa4:	75 0a                	jne    800ab0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aae:	eb 05                	jmp    800ab5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ab0:	89 c7                	mov    %eax,%edi
  800ab2:	fc                   	cld    
  800ab3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab9:	f3 0f 1e fb          	endbr32 
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac3:	ff 75 10             	pushl  0x10(%ebp)
  800ac6:	ff 75 0c             	pushl  0xc(%ebp)
  800ac9:	ff 75 08             	pushl  0x8(%ebp)
  800acc:	e8 82 ff ff ff       	call   800a53 <memmove>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad3:	f3 0f 1e fb          	endbr32 
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	89 c6                	mov    %eax,%esi
  800ae4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae7:	39 f0                	cmp    %esi,%eax
  800ae9:	74 1c                	je     800b07 <memcmp+0x34>
		if (*s1 != *s2)
  800aeb:	0f b6 08             	movzbl (%eax),%ecx
  800aee:	0f b6 1a             	movzbl (%edx),%ebx
  800af1:	38 d9                	cmp    %bl,%cl
  800af3:	75 08                	jne    800afd <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	83 c2 01             	add    $0x1,%edx
  800afb:	eb ea                	jmp    800ae7 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800afd:	0f b6 c1             	movzbl %cl,%eax
  800b00:	0f b6 db             	movzbl %bl,%ebx
  800b03:	29 d8                	sub    %ebx,%eax
  800b05:	eb 05                	jmp    800b0c <memcmp+0x39>
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b10:	f3 0f 1e fb          	endbr32 
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	73 09                	jae    800b2f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	38 08                	cmp    %cl,(%eax)
  800b28:	74 05                	je     800b2f <memfind+0x1f>
	for (; s < ends; s++)
  800b2a:	83 c0 01             	add    $0x1,%eax
  800b2d:	eb f3                	jmp    800b22 <memfind+0x12>
			break;
	return (void *) s;
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b31:	f3 0f 1e fb          	endbr32 
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b41:	eb 03                	jmp    800b46 <strtol+0x15>
		s++;
  800b43:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b46:	0f b6 01             	movzbl (%ecx),%eax
  800b49:	3c 20                	cmp    $0x20,%al
  800b4b:	74 f6                	je     800b43 <strtol+0x12>
  800b4d:	3c 09                	cmp    $0x9,%al
  800b4f:	74 f2                	je     800b43 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b51:	3c 2b                	cmp    $0x2b,%al
  800b53:	74 2a                	je     800b7f <strtol+0x4e>
	int neg = 0;
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b5a:	3c 2d                	cmp    $0x2d,%al
  800b5c:	74 2b                	je     800b89 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b64:	75 0f                	jne    800b75 <strtol+0x44>
  800b66:	80 39 30             	cmpb   $0x30,(%ecx)
  800b69:	74 28                	je     800b93 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6b:	85 db                	test   %ebx,%ebx
  800b6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b72:	0f 44 d8             	cmove  %eax,%ebx
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7d:	eb 46                	jmp    800bc5 <strtol+0x94>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb d5                	jmp    800b5e <strtol+0x2d>
		s++, neg = 1;
  800b89:	83 c1 01             	add    $0x1,%ecx
  800b8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b91:	eb cb                	jmp    800b5e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b97:	74 0e                	je     800ba7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b99:	85 db                	test   %ebx,%ebx
  800b9b:	75 d8                	jne    800b75 <strtol+0x44>
		s++, base = 8;
  800b9d:	83 c1 01             	add    $0x1,%ecx
  800ba0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba5:	eb ce                	jmp    800b75 <strtol+0x44>
		s += 2, base = 16;
  800ba7:	83 c1 02             	add    $0x2,%ecx
  800baa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800baf:	eb c4                	jmp    800b75 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bb1:	0f be d2             	movsbl %dl,%edx
  800bb4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bba:	7d 3a                	jge    800bf6 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bbc:	83 c1 01             	add    $0x1,%ecx
  800bbf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc5:	0f b6 11             	movzbl (%ecx),%edx
  800bc8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 09             	cmp    $0x9,%bl
  800bd0:	76 df                	jbe    800bb1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bd2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd5:	89 f3                	mov    %esi,%ebx
  800bd7:	80 fb 19             	cmp    $0x19,%bl
  800bda:	77 08                	ja     800be4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bdc:	0f be d2             	movsbl %dl,%edx
  800bdf:	83 ea 57             	sub    $0x57,%edx
  800be2:	eb d3                	jmp    800bb7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800be4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be7:	89 f3                	mov    %esi,%ebx
  800be9:	80 fb 19             	cmp    $0x19,%bl
  800bec:	77 08                	ja     800bf6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bee:	0f be d2             	movsbl %dl,%edx
  800bf1:	83 ea 37             	sub    $0x37,%edx
  800bf4:	eb c1                	jmp    800bb7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfa:	74 05                	je     800c01 <strtol+0xd0>
		*endptr = (char *) s;
  800bfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bff:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c01:	89 c2                	mov    %eax,%edx
  800c03:	f7 da                	neg    %edx
  800c05:	85 ff                	test   %edi,%edi
  800c07:	0f 45 c2             	cmovne %edx,%eax
}
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c0f:	f3 0f 1e fb          	endbr32 
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c19:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	89 c3                	mov    %eax,%ebx
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	89 c6                	mov    %eax,%esi
  800c2a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c31:	f3 0f 1e fb          	endbr32 
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 01 00 00 00       	mov    $0x1,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6b:	89 cb                	mov    %ecx,%ebx
  800c6d:	89 cf                	mov    %ecx,%edi
  800c6f:	89 ce                	mov    %ecx,%esi
  800c71:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c78:	f3 0f 1e fb          	endbr32 
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8c:	89 d1                	mov    %edx,%ecx
  800c8e:	89 d3                	mov    %edx,%ebx
  800c90:	89 d7                	mov    %edx,%edi
  800c92:	89 d6                	mov    %edx,%esi
  800c94:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_yield>:

void
sys_yield(void)
{
  800c9b:	f3 0f 1e fb          	endbr32 
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  800caa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800caf:	89 d1                	mov    %edx,%ecx
  800cb1:	89 d3                	mov    %edx,%ebx
  800cb3:	89 d7                	mov    %edx,%edi
  800cb5:	89 d6                	mov    %edx,%esi
  800cb7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cbe:	f3 0f 1e fb          	endbr32 
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc8:	be 00 00 00 00       	mov    $0x0,%esi
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	89 f7                	mov    %esi,%edi
  800cdd:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce4:	f3 0f 1e fb          	endbr32 
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cff:	8b 75 18             	mov    0x18(%ebp),%esi
  800d02:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d09:	f3 0f 1e fb          	endbr32 
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d23:	89 df                	mov    %ebx,%edi
  800d25:	89 de                	mov    %ebx,%esi
  800d27:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2e:	f3 0f 1e fb          	endbr32 
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	b8 08 00 00 00       	mov    $0x8,%eax
  800d48:	89 df                	mov    %ebx,%edi
  800d4a:	89 de                	mov    %ebx,%esi
  800d4c:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d53:	f3 0f 1e fb          	endbr32 
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d78:	f3 0f 1e fb          	endbr32 
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9d:	f3 0f 1e fb          	endbr32 
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db2:	be 00 00 00 00       	mov    $0x0,%esi
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	f3 0f 1e fb          	endbr32 
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddb:	89 cb                	mov    %ecx,%ebx
  800ddd:	89 cf                	mov    %ecx,%edi
  800ddf:	89 ce                	mov    %ecx,%esi
  800de1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de8:	f3 0f 1e fb          	endbr32 
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df2:	ba 00 00 00 00       	mov    $0x0,%edx
  800df7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfc:	89 d1                	mov    %edx,%ecx
  800dfe:	89 d3                	mov    %edx,%ebx
  800e00:	89 d7                	mov    %edx,%edi
  800e02:	89 d6                	mov    %edx,%esi
  800e04:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800e0b:	f3 0f 1e fb          	endbr32 
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5f                   	pop    %edi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	b8 10 00 00 00       	mov    $0x10,%eax
  800e4a:	89 df                	mov    %ebx,%edi
  800e4c:	89 de                	mov    %ebx,%esi
  800e4e:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e55:	f3 0f 1e fb          	endbr32 
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	05 00 00 00 30       	add    $0x30000000,%eax
  800e64:	c1 e8 0c             	shr    $0xc,%eax
}
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e69:	f3 0f 1e fb          	endbr32 
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e7d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e84:	f3 0f 1e fb          	endbr32 
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e90:	89 c2                	mov    %eax,%edx
  800e92:	c1 ea 16             	shr    $0x16,%edx
  800e95:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e9c:	f6 c2 01             	test   $0x1,%dl
  800e9f:	74 2d                	je     800ece <fd_alloc+0x4a>
  800ea1:	89 c2                	mov    %eax,%edx
  800ea3:	c1 ea 0c             	shr    $0xc,%edx
  800ea6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ead:	f6 c2 01             	test   $0x1,%dl
  800eb0:	74 1c                	je     800ece <fd_alloc+0x4a>
  800eb2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800eb7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ebc:	75 d2                	jne    800e90 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800ec7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800ecc:	eb 0a                	jmp    800ed8 <fd_alloc+0x54>
			*fd_store = fd;
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eda:	f3 0f 1e fb          	endbr32 
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee4:	83 f8 1f             	cmp    $0x1f,%eax
  800ee7:	77 30                	ja     800f19 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee9:	c1 e0 0c             	shl    $0xc,%eax
  800eec:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ef1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800ef7:	f6 c2 01             	test   $0x1,%dl
  800efa:	74 24                	je     800f20 <fd_lookup+0x46>
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	c1 ea 0c             	shr    $0xc,%edx
  800f01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f08:	f6 c2 01             	test   $0x1,%dl
  800f0b:	74 1a                	je     800f27 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f10:	89 02                	mov    %eax,(%edx)
	return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    
		return -E_INVAL;
  800f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f1e:	eb f7                	jmp    800f17 <fd_lookup+0x3d>
		return -E_INVAL;
  800f20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f25:	eb f0                	jmp    800f17 <fd_lookup+0x3d>
  800f27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f2c:	eb e9                	jmp    800f17 <fd_lookup+0x3d>

00800f2e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f2e:	f3 0f 1e fb          	endbr32 
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  800f3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f40:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f45:	39 08                	cmp    %ecx,(%eax)
  800f47:	74 38                	je     800f81 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  800f49:	83 c2 01             	add    $0x1,%edx
  800f4c:	8b 04 95 fc 27 80 00 	mov    0x8027fc(,%edx,4),%eax
  800f53:	85 c0                	test   %eax,%eax
  800f55:	75 ee                	jne    800f45 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f57:	a1 08 40 80 00       	mov    0x804008,%eax
  800f5c:	8b 40 48             	mov    0x48(%eax),%eax
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	51                   	push   %ecx
  800f63:	50                   	push   %eax
  800f64:	68 80 27 80 00       	push   $0x802780
  800f69:	e8 dd f2 ff ff       	call   80024b <cprintf>
	*dev = 0;
  800f6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    
			*dev = devtab[i];
  800f81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f84:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8b:	eb f2                	jmp    800f7f <dev_lookup+0x51>

00800f8d <fd_close>:
{
  800f8d:	f3 0f 1e fb          	endbr32 
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	57                   	push   %edi
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
  800f97:	83 ec 24             	sub    $0x24,%esp
  800f9a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fa0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fa3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fa4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800faa:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fad:	50                   	push   %eax
  800fae:	e8 27 ff ff ff       	call   800eda <fd_lookup>
  800fb3:	89 c3                	mov    %eax,%ebx
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 05                	js     800fc1 <fd_close+0x34>
	    || fd != fd2)
  800fbc:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fbf:	74 16                	je     800fd7 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800fc1:	89 f8                	mov    %edi,%eax
  800fc3:	84 c0                	test   %al,%al
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	0f 44 d8             	cmove  %eax,%ebx
}
  800fcd:	89 d8                	mov    %ebx,%eax
  800fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fd7:	83 ec 08             	sub    $0x8,%esp
  800fda:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800fdd:	50                   	push   %eax
  800fde:	ff 36                	pushl  (%esi)
  800fe0:	e8 49 ff ff ff       	call   800f2e <dev_lookup>
  800fe5:	89 c3                	mov    %eax,%ebx
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 1a                	js     801008 <fd_close+0x7b>
		if (dev->dev_close)
  800fee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff1:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ff4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	74 0b                	je     801008 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800ffd:	83 ec 0c             	sub    $0xc,%esp
  801000:	56                   	push   %esi
  801001:	ff d0                	call   *%eax
  801003:	89 c3                	mov    %eax,%ebx
  801005:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801008:	83 ec 08             	sub    $0x8,%esp
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	e8 f6 fc ff ff       	call   800d09 <sys_page_unmap>
	return r;
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	eb b5                	jmp    800fcd <fd_close+0x40>

00801018 <close>:

int
close(int fdnum)
{
  801018:	f3 0f 1e fb          	endbr32 
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801025:	50                   	push   %eax
  801026:	ff 75 08             	pushl  0x8(%ebp)
  801029:	e8 ac fe ff ff       	call   800eda <fd_lookup>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	79 02                	jns    801037 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801035:	c9                   	leave  
  801036:	c3                   	ret    
		return fd_close(fd, 1);
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	6a 01                	push   $0x1
  80103c:	ff 75 f4             	pushl  -0xc(%ebp)
  80103f:	e8 49 ff ff ff       	call   800f8d <fd_close>
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	eb ec                	jmp    801035 <close+0x1d>

00801049 <close_all>:

void
close_all(void)
{
  801049:	f3 0f 1e fb          	endbr32 
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	53                   	push   %ebx
  801051:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801054:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	53                   	push   %ebx
  80105d:	e8 b6 ff ff ff       	call   801018 <close>
	for (i = 0; i < MAXFD; i++)
  801062:	83 c3 01             	add    $0x1,%ebx
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	83 fb 20             	cmp    $0x20,%ebx
  80106b:	75 ec                	jne    801059 <close_all+0x10>
}
  80106d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801072:	f3 0f 1e fb          	endbr32 
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
  80107c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801082:	50                   	push   %eax
  801083:	ff 75 08             	pushl  0x8(%ebp)
  801086:	e8 4f fe ff ff       	call   800eda <fd_lookup>
  80108b:	89 c3                	mov    %eax,%ebx
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	85 c0                	test   %eax,%eax
  801092:	0f 88 81 00 00 00    	js     801119 <dup+0xa7>
		return r;
	close(newfdnum);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	ff 75 0c             	pushl  0xc(%ebp)
  80109e:	e8 75 ff ff ff       	call   801018 <close>

	newfd = INDEX2FD(newfdnum);
  8010a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010a6:	c1 e6 0c             	shl    $0xc,%esi
  8010a9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010af:	83 c4 04             	add    $0x4,%esp
  8010b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b5:	e8 af fd ff ff       	call   800e69 <fd2data>
  8010ba:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010bc:	89 34 24             	mov    %esi,(%esp)
  8010bf:	e8 a5 fd ff ff       	call   800e69 <fd2data>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c9:	89 d8                	mov    %ebx,%eax
  8010cb:	c1 e8 16             	shr    $0x16,%eax
  8010ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d5:	a8 01                	test   $0x1,%al
  8010d7:	74 11                	je     8010ea <dup+0x78>
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	c1 e8 0c             	shr    $0xc,%eax
  8010de:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e5:	f6 c2 01             	test   $0x1,%dl
  8010e8:	75 39                	jne    801123 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010ed:	89 d0                	mov    %edx,%eax
  8010ef:	c1 e8 0c             	shr    $0xc,%eax
  8010f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801101:	50                   	push   %eax
  801102:	56                   	push   %esi
  801103:	6a 00                	push   $0x0
  801105:	52                   	push   %edx
  801106:	6a 00                	push   $0x0
  801108:	e8 d7 fb ff ff       	call   800ce4 <sys_page_map>
  80110d:	89 c3                	mov    %eax,%ebx
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 31                	js     801147 <dup+0xd5>
		goto err;

	return newfdnum;
  801116:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801119:	89 d8                	mov    %ebx,%eax
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801123:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	25 07 0e 00 00       	and    $0xe07,%eax
  801132:	50                   	push   %eax
  801133:	57                   	push   %edi
  801134:	6a 00                	push   $0x0
  801136:	53                   	push   %ebx
  801137:	6a 00                	push   $0x0
  801139:	e8 a6 fb ff ff       	call   800ce4 <sys_page_map>
  80113e:	89 c3                	mov    %eax,%ebx
  801140:	83 c4 20             	add    $0x20,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	79 a3                	jns    8010ea <dup+0x78>
	sys_page_unmap(0, newfd);
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	56                   	push   %esi
  80114b:	6a 00                	push   $0x0
  80114d:	e8 b7 fb ff ff       	call   800d09 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801152:	83 c4 08             	add    $0x8,%esp
  801155:	57                   	push   %edi
  801156:	6a 00                	push   $0x0
  801158:	e8 ac fb ff ff       	call   800d09 <sys_page_unmap>
	return r;
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	eb b7                	jmp    801119 <dup+0xa7>

00801162 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801162:	f3 0f 1e fb          	endbr32 
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	53                   	push   %ebx
  80116a:	83 ec 1c             	sub    $0x1c,%esp
  80116d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801170:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801173:	50                   	push   %eax
  801174:	53                   	push   %ebx
  801175:	e8 60 fd ff ff       	call   800eda <fd_lookup>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 3f                	js     8011c0 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801187:	50                   	push   %eax
  801188:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118b:	ff 30                	pushl  (%eax)
  80118d:	e8 9c fd ff ff       	call   800f2e <dev_lookup>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 27                	js     8011c0 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801199:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119c:	8b 42 08             	mov    0x8(%edx),%eax
  80119f:	83 e0 03             	and    $0x3,%eax
  8011a2:	83 f8 01             	cmp    $0x1,%eax
  8011a5:	74 1e                	je     8011c5 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011aa:	8b 40 08             	mov    0x8(%eax),%eax
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	74 35                	je     8011e6 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	ff 75 10             	pushl  0x10(%ebp)
  8011b7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ba:	52                   	push   %edx
  8011bb:	ff d0                	call   *%eax
  8011bd:	83 c4 10             	add    $0x10,%esp
}
  8011c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c3:	c9                   	leave  
  8011c4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ca:	8b 40 48             	mov    0x48(%eax),%eax
  8011cd:	83 ec 04             	sub    $0x4,%esp
  8011d0:	53                   	push   %ebx
  8011d1:	50                   	push   %eax
  8011d2:	68 c1 27 80 00       	push   $0x8027c1
  8011d7:	e8 6f f0 ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb da                	jmp    8011c0 <read+0x5e>
		return -E_NOT_SUPP;
  8011e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011eb:	eb d3                	jmp    8011c0 <read+0x5e>

008011ed <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ed:	f3 0f 1e fb          	endbr32 
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	57                   	push   %edi
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801200:	bb 00 00 00 00       	mov    $0x0,%ebx
  801205:	eb 02                	jmp    801209 <readn+0x1c>
  801207:	01 c3                	add    %eax,%ebx
  801209:	39 f3                	cmp    %esi,%ebx
  80120b:	73 21                	jae    80122e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	89 f0                	mov    %esi,%eax
  801212:	29 d8                	sub    %ebx,%eax
  801214:	50                   	push   %eax
  801215:	89 d8                	mov    %ebx,%eax
  801217:	03 45 0c             	add    0xc(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	57                   	push   %edi
  80121c:	e8 41 ff ff ff       	call   801162 <read>
		if (m < 0)
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 04                	js     80122c <readn+0x3f>
			return m;
		if (m == 0)
  801228:	75 dd                	jne    801207 <readn+0x1a>
  80122a:	eb 02                	jmp    80122e <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80122e:	89 d8                	mov    %ebx,%eax
  801230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801238:	f3 0f 1e fb          	endbr32 
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	53                   	push   %ebx
  801240:	83 ec 1c             	sub    $0x1c,%esp
  801243:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801246:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801249:	50                   	push   %eax
  80124a:	53                   	push   %ebx
  80124b:	e8 8a fc ff ff       	call   800eda <fd_lookup>
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 3a                	js     801291 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801261:	ff 30                	pushl  (%eax)
  801263:	e8 c6 fc ff ff       	call   800f2e <dev_lookup>
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 22                	js     801291 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801272:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801276:	74 1e                	je     801296 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801278:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127b:	8b 52 0c             	mov    0xc(%edx),%edx
  80127e:	85 d2                	test   %edx,%edx
  801280:	74 35                	je     8012b7 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801282:	83 ec 04             	sub    $0x4,%esp
  801285:	ff 75 10             	pushl  0x10(%ebp)
  801288:	ff 75 0c             	pushl  0xc(%ebp)
  80128b:	50                   	push   %eax
  80128c:	ff d2                	call   *%edx
  80128e:	83 c4 10             	add    $0x10,%esp
}
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801296:	a1 08 40 80 00       	mov    0x804008,%eax
  80129b:	8b 40 48             	mov    0x48(%eax),%eax
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	53                   	push   %ebx
  8012a2:	50                   	push   %eax
  8012a3:	68 dd 27 80 00       	push   $0x8027dd
  8012a8:	e8 9e ef ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b5:	eb da                	jmp    801291 <write+0x59>
		return -E_NOT_SUPP;
  8012b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012bc:	eb d3                	jmp    801291 <write+0x59>

008012be <seek>:

int
seek(int fdnum, off_t offset)
{
  8012be:	f3 0f 1e fb          	endbr32 
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 06 fc ff ff       	call   800eda <fd_lookup>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 0e                	js     8012e9 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8012db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012eb:	f3 0f 1e fb          	endbr32 
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 1c             	sub    $0x1c,%esp
  8012f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	53                   	push   %ebx
  8012fe:	e8 d7 fb ff ff       	call   800eda <fd_lookup>
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 37                	js     801341 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801314:	ff 30                	pushl  (%eax)
  801316:	e8 13 fc ff ff       	call   800f2e <dev_lookup>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 1f                	js     801341 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801329:	74 1b                	je     801346 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80132b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132e:	8b 52 18             	mov    0x18(%edx),%edx
  801331:	85 d2                	test   %edx,%edx
  801333:	74 32                	je     801367 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	ff 75 0c             	pushl  0xc(%ebp)
  80133b:	50                   	push   %eax
  80133c:	ff d2                	call   *%edx
  80133e:	83 c4 10             	add    $0x10,%esp
}
  801341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801344:	c9                   	leave  
  801345:	c3                   	ret    
			thisenv->env_id, fdnum);
  801346:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80134b:	8b 40 48             	mov    0x48(%eax),%eax
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	53                   	push   %ebx
  801352:	50                   	push   %eax
  801353:	68 a0 27 80 00       	push   $0x8027a0
  801358:	e8 ee ee ff ff       	call   80024b <cprintf>
		return -E_INVAL;
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801365:	eb da                	jmp    801341 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801367:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80136c:	eb d3                	jmp    801341 <ftruncate+0x56>

0080136e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80136e:	f3 0f 1e fb          	endbr32 
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	53                   	push   %ebx
  801376:	83 ec 1c             	sub    $0x1c,%esp
  801379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 75 08             	pushl  0x8(%ebp)
  801383:	e8 52 fb ff ff       	call   800eda <fd_lookup>
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 4b                	js     8013da <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801399:	ff 30                	pushl  (%eax)
  80139b:	e8 8e fb ff ff       	call   800f2e <dev_lookup>
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 33                	js     8013da <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8013a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013aa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ae:	74 2f                	je     8013df <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ba:	00 00 00 
	stat->st_isdir = 0;
  8013bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c4:	00 00 00 
	stat->st_dev = dev;
  8013c7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d4:	ff 50 14             	call   *0x14(%eax)
  8013d7:	83 c4 10             	add    $0x10,%esp
}
  8013da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013dd:	c9                   	leave  
  8013de:	c3                   	ret    
		return -E_NOT_SUPP;
  8013df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e4:	eb f4                	jmp    8013da <fstat+0x6c>

008013e6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e6:	f3 0f 1e fb          	endbr32 
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	56                   	push   %esi
  8013ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	6a 00                	push   $0x0
  8013f4:	ff 75 08             	pushl  0x8(%ebp)
  8013f7:	e8 01 02 00 00       	call   8015fd <open>
  8013fc:	89 c3                	mov    %eax,%ebx
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 1b                	js     801420 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	ff 75 0c             	pushl  0xc(%ebp)
  80140b:	50                   	push   %eax
  80140c:	e8 5d ff ff ff       	call   80136e <fstat>
  801411:	89 c6                	mov    %eax,%esi
	close(fd);
  801413:	89 1c 24             	mov    %ebx,(%esp)
  801416:	e8 fd fb ff ff       	call   801018 <close>
	return r;
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	89 f3                	mov    %esi,%ebx
}
  801420:	89 d8                	mov    %ebx,%eax
  801422:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801425:	5b                   	pop    %ebx
  801426:	5e                   	pop    %esi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    

00801429 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	56                   	push   %esi
  80142d:	53                   	push   %ebx
  80142e:	89 c6                	mov    %eax,%esi
  801430:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801432:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801439:	74 27                	je     801462 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80143b:	6a 07                	push   $0x7
  80143d:	68 00 50 80 00       	push   $0x805000
  801442:	56                   	push   %esi
  801443:	ff 35 00 40 80 00    	pushl  0x804000
  801449:	e8 7c 0c 00 00       	call   8020ca <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144e:	83 c4 0c             	add    $0xc,%esp
  801451:	6a 00                	push   $0x0
  801453:	53                   	push   %ebx
  801454:	6a 00                	push   $0x0
  801456:	e8 02 0c 00 00       	call   80205d <ipc_recv>
}
  80145b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145e:	5b                   	pop    %ebx
  80145f:	5e                   	pop    %esi
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	6a 01                	push   $0x1
  801467:	e8 b6 0c 00 00       	call   802122 <ipc_find_env>
  80146c:	a3 00 40 80 00       	mov    %eax,0x804000
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	eb c5                	jmp    80143b <fsipc+0x12>

00801476 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801476:	f3 0f 1e fb          	endbr32 
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 40 0c             	mov    0xc(%eax),%eax
  801486:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80148b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801493:	ba 00 00 00 00       	mov    $0x0,%edx
  801498:	b8 02 00 00 00       	mov    $0x2,%eax
  80149d:	e8 87 ff ff ff       	call   801429 <fsipc>
}
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <devfile_flush>:
{
  8014a4:	f3 0f 1e fb          	endbr32 
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014be:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c3:	e8 61 ff ff ff       	call   801429 <fsipc>
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <devfile_stat>:
{
  8014ca:	f3 0f 1e fb          	endbr32 
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	8b 40 0c             	mov    0xc(%eax),%eax
  8014de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ed:	e8 37 ff ff ff       	call   801429 <fsipc>
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 2c                	js     801522 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	68 00 50 80 00       	push   $0x805000
  8014fe:	53                   	push   %ebx
  8014ff:	e8 51 f3 ff ff       	call   800855 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801504:	a1 80 50 80 00       	mov    0x805080,%eax
  801509:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80150f:	a1 84 50 80 00       	mov    0x805084,%eax
  801514:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <devfile_write>:
{
  801527:	f3 0f 1e fb          	endbr32 
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	8b 45 10             	mov    0x10(%ebp),%eax
  801534:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801539:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80153e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801541:	8b 55 08             	mov    0x8(%ebp),%edx
  801544:	8b 52 0c             	mov    0xc(%edx),%edx
  801547:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80154d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801552:	50                   	push   %eax
  801553:	ff 75 0c             	pushl  0xc(%ebp)
  801556:	68 08 50 80 00       	push   $0x805008
  80155b:	e8 f3 f4 ff ff       	call   800a53 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
  801565:	b8 04 00 00 00       	mov    $0x4,%eax
  80156a:	e8 ba fe ff ff       	call   801429 <fsipc>
}
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <devfile_read>:
{
  801571:	f3 0f 1e fb          	endbr32 
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	56                   	push   %esi
  801579:	53                   	push   %ebx
  80157a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80157d:	8b 45 08             	mov    0x8(%ebp),%eax
  801580:	8b 40 0c             	mov    0xc(%eax),%eax
  801583:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801588:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80158e:	ba 00 00 00 00       	mov    $0x0,%edx
  801593:	b8 03 00 00 00       	mov    $0x3,%eax
  801598:	e8 8c fe ff ff       	call   801429 <fsipc>
  80159d:	89 c3                	mov    %eax,%ebx
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 1f                	js     8015c2 <devfile_read+0x51>
	assert(r <= n);
  8015a3:	39 f0                	cmp    %esi,%eax
  8015a5:	77 24                	ja     8015cb <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8015a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015ac:	7f 36                	jg     8015e4 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	50                   	push   %eax
  8015b2:	68 00 50 80 00       	push   $0x805000
  8015b7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ba:	e8 94 f4 ff ff       	call   800a53 <memmove>
	return r;
  8015bf:	83 c4 10             	add    $0x10,%esp
}
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5e                   	pop    %esi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    
	assert(r <= n);
  8015cb:	68 10 28 80 00       	push   $0x802810
  8015d0:	68 17 28 80 00       	push   $0x802817
  8015d5:	68 8c 00 00 00       	push   $0x8c
  8015da:	68 2c 28 80 00       	push   $0x80282c
  8015df:	e8 80 eb ff ff       	call   800164 <_panic>
	assert(r <= PGSIZE);
  8015e4:	68 37 28 80 00       	push   $0x802837
  8015e9:	68 17 28 80 00       	push   $0x802817
  8015ee:	68 8d 00 00 00       	push   $0x8d
  8015f3:	68 2c 28 80 00       	push   $0x80282c
  8015f8:	e8 67 eb ff ff       	call   800164 <_panic>

008015fd <open>:
{
  8015fd:	f3 0f 1e fb          	endbr32 
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
  801606:	83 ec 1c             	sub    $0x1c,%esp
  801609:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80160c:	56                   	push   %esi
  80160d:	e8 00 f2 ff ff       	call   800812 <strlen>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80161a:	7f 6c                	jg     801688 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	e8 5c f8 ff ff       	call   800e84 <fd_alloc>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 3c                	js     80166d <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801631:	83 ec 08             	sub    $0x8,%esp
  801634:	56                   	push   %esi
  801635:	68 00 50 80 00       	push   $0x805000
  80163a:	e8 16 f2 ff ff       	call   800855 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80163f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801642:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	b8 01 00 00 00       	mov    $0x1,%eax
  80164f:	e8 d5 fd ff ff       	call   801429 <fsipc>
  801654:	89 c3                	mov    %eax,%ebx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 19                	js     801676 <open+0x79>
	return fd2num(fd);
  80165d:	83 ec 0c             	sub    $0xc,%esp
  801660:	ff 75 f4             	pushl  -0xc(%ebp)
  801663:	e8 ed f7 ff ff       	call   800e55 <fd2num>
  801668:	89 c3                	mov    %eax,%ebx
  80166a:	83 c4 10             	add    $0x10,%esp
}
  80166d:	89 d8                	mov    %ebx,%eax
  80166f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    
		fd_close(fd, 0);
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	6a 00                	push   $0x0
  80167b:	ff 75 f4             	pushl  -0xc(%ebp)
  80167e:	e8 0a f9 ff ff       	call   800f8d <fd_close>
		return r;
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	eb e5                	jmp    80166d <open+0x70>
		return -E_BAD_PATH;
  801688:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80168d:	eb de                	jmp    80166d <open+0x70>

0080168f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168f:	f3 0f 1e fb          	endbr32 
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801699:	ba 00 00 00 00       	mov    $0x0,%edx
  80169e:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a3:	e8 81 fd ff ff       	call   801429 <fsipc>
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016aa:	f3 0f 1e fb          	endbr32 
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016b4:	68 a3 28 80 00       	push   $0x8028a3
  8016b9:	ff 75 0c             	pushl  0xc(%ebp)
  8016bc:	e8 94 f1 ff ff       	call   800855 <strcpy>
	return 0;
}
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <devsock_close>:
{
  8016c8:	f3 0f 1e fb          	endbr32 
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 10             	sub    $0x10,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016d6:	53                   	push   %ebx
  8016d7:	e8 83 0a 00 00       	call   80215f <pageref>
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	83 c4 10             	add    $0x10,%esp
		return 0;
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8016e6:	83 fa 01             	cmp    $0x1,%edx
  8016e9:	74 05                	je     8016f0 <devsock_close+0x28>
}
  8016eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	ff 73 0c             	pushl  0xc(%ebx)
  8016f6:	e8 e3 02 00 00       	call   8019de <nsipc_close>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	eb eb                	jmp    8016eb <devsock_close+0x23>

00801700 <devsock_write>:
{
  801700:	f3 0f 1e fb          	endbr32 
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80170a:	6a 00                	push   $0x0
  80170c:	ff 75 10             	pushl  0x10(%ebp)
  80170f:	ff 75 0c             	pushl  0xc(%ebp)
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	ff 70 0c             	pushl  0xc(%eax)
  801718:	e8 b5 03 00 00       	call   801ad2 <nsipc_send>
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devsock_read>:
{
  80171f:	f3 0f 1e fb          	endbr32 
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801729:	6a 00                	push   $0x0
  80172b:	ff 75 10             	pushl  0x10(%ebp)
  80172e:	ff 75 0c             	pushl  0xc(%ebp)
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	ff 70 0c             	pushl  0xc(%eax)
  801737:	e8 1f 03 00 00       	call   801a5b <nsipc_recv>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <fd2sockid>:
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801744:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801747:	52                   	push   %edx
  801748:	50                   	push   %eax
  801749:	e8 8c f7 ff ff       	call   800eda <fd_lookup>
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 10                	js     801765 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801758:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  80175e:	39 08                	cmp    %ecx,(%eax)
  801760:	75 05                	jne    801767 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801762:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    
		return -E_NOT_SUPP;
  801767:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80176c:	eb f7                	jmp    801765 <fd2sockid+0x27>

0080176e <alloc_sockfd>:
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	56                   	push   %esi
  801772:	53                   	push   %ebx
  801773:	83 ec 1c             	sub    $0x1c,%esp
  801776:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801778:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	e8 03 f7 ff ff       	call   800e84 <fd_alloc>
  801781:	89 c3                	mov    %eax,%ebx
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	78 43                	js     8017cd <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	68 07 04 00 00       	push   $0x407
  801792:	ff 75 f4             	pushl  -0xc(%ebp)
  801795:	6a 00                	push   $0x0
  801797:	e8 22 f5 ff ff       	call   800cbe <sys_page_alloc>
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 28                	js     8017cd <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a8:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8017ae:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017ba:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017bd:	83 ec 0c             	sub    $0xc,%esp
  8017c0:	50                   	push   %eax
  8017c1:	e8 8f f6 ff ff       	call   800e55 <fd2num>
  8017c6:	89 c3                	mov    %eax,%ebx
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	eb 0c                	jmp    8017d9 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	56                   	push   %esi
  8017d1:	e8 08 02 00 00       	call   8019de <nsipc_close>
		return r;
  8017d6:	83 c4 10             	add    $0x10,%esp
}
  8017d9:	89 d8                	mov    %ebx,%eax
  8017db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017de:	5b                   	pop    %ebx
  8017df:	5e                   	pop    %esi
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <accept>:
{
  8017e2:	f3 0f 1e fb          	endbr32 
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	e8 4a ff ff ff       	call   80173e <fd2sockid>
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 1b                	js     801813 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8017f8:	83 ec 04             	sub    $0x4,%esp
  8017fb:	ff 75 10             	pushl  0x10(%ebp)
  8017fe:	ff 75 0c             	pushl  0xc(%ebp)
  801801:	50                   	push   %eax
  801802:	e8 22 01 00 00       	call   801929 <nsipc_accept>
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 05                	js     801813 <accept+0x31>
	return alloc_sockfd(r);
  80180e:	e8 5b ff ff ff       	call   80176e <alloc_sockfd>
}
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <bind>:
{
  801815:	f3 0f 1e fb          	endbr32 
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	e8 17 ff ff ff       	call   80173e <fd2sockid>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 12                	js     80183d <bind+0x28>
	return nsipc_bind(r, name, namelen);
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	ff 75 10             	pushl  0x10(%ebp)
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	50                   	push   %eax
  801835:	e8 45 01 00 00       	call   80197f <nsipc_bind>
  80183a:	83 c4 10             	add    $0x10,%esp
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <shutdown>:
{
  80183f:	f3 0f 1e fb          	endbr32 
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801849:	8b 45 08             	mov    0x8(%ebp),%eax
  80184c:	e8 ed fe ff ff       	call   80173e <fd2sockid>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 0f                	js     801864 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801855:	83 ec 08             	sub    $0x8,%esp
  801858:	ff 75 0c             	pushl  0xc(%ebp)
  80185b:	50                   	push   %eax
  80185c:	e8 57 01 00 00       	call   8019b8 <nsipc_shutdown>
  801861:	83 c4 10             	add    $0x10,%esp
}
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <connect>:
{
  801866:	f3 0f 1e fb          	endbr32 
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	e8 c6 fe ff ff       	call   80173e <fd2sockid>
  801878:	85 c0                	test   %eax,%eax
  80187a:	78 12                	js     80188e <connect+0x28>
	return nsipc_connect(r, name, namelen);
  80187c:	83 ec 04             	sub    $0x4,%esp
  80187f:	ff 75 10             	pushl  0x10(%ebp)
  801882:	ff 75 0c             	pushl  0xc(%ebp)
  801885:	50                   	push   %eax
  801886:	e8 71 01 00 00       	call   8019fc <nsipc_connect>
  80188b:	83 c4 10             	add    $0x10,%esp
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <listen>:
{
  801890:	f3 0f 1e fb          	endbr32 
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	e8 9c fe ff ff       	call   80173e <fd2sockid>
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 0f                	js     8018b5 <listen+0x25>
	return nsipc_listen(r, backlog);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	ff 75 0c             	pushl  0xc(%ebp)
  8018ac:	50                   	push   %eax
  8018ad:	e8 83 01 00 00       	call   801a35 <nsipc_listen>
  8018b2:	83 c4 10             	add    $0x10,%esp
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <socket>:

int
socket(int domain, int type, int protocol)
{
  8018b7:	f3 0f 1e fb          	endbr32 
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018c1:	ff 75 10             	pushl  0x10(%ebp)
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	ff 75 08             	pushl  0x8(%ebp)
  8018ca:	e8 65 02 00 00       	call   801b34 <nsipc_socket>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 05                	js     8018db <socket+0x24>
		return r;
	return alloc_sockfd(r);
  8018d6:	e8 93 fe ff ff       	call   80176e <alloc_sockfd>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 04             	sub    $0x4,%esp
  8018e4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018e6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018ed:	74 26                	je     801915 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8018ef:	6a 07                	push   $0x7
  8018f1:	68 00 60 80 00       	push   $0x806000
  8018f6:	53                   	push   %ebx
  8018f7:	ff 35 04 40 80 00    	pushl  0x804004
  8018fd:	e8 c8 07 00 00       	call   8020ca <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801902:	83 c4 0c             	add    $0xc,%esp
  801905:	6a 00                	push   $0x0
  801907:	6a 00                	push   $0x0
  801909:	6a 00                	push   $0x0
  80190b:	e8 4d 07 00 00       	call   80205d <ipc_recv>
}
  801910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801913:	c9                   	leave  
  801914:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801915:	83 ec 0c             	sub    $0xc,%esp
  801918:	6a 02                	push   $0x2
  80191a:	e8 03 08 00 00       	call   802122 <ipc_find_env>
  80191f:	a3 04 40 80 00       	mov    %eax,0x804004
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	eb c6                	jmp    8018ef <nsipc+0x12>

00801929 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801929:	f3 0f 1e fb          	endbr32 
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
  801938:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80193d:	8b 06                	mov    (%esi),%eax
  80193f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801944:	b8 01 00 00 00       	mov    $0x1,%eax
  801949:	e8 8f ff ff ff       	call   8018dd <nsipc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	85 c0                	test   %eax,%eax
  801952:	79 09                	jns    80195d <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801954:	89 d8                	mov    %ebx,%eax
  801956:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80195d:	83 ec 04             	sub    $0x4,%esp
  801960:	ff 35 10 60 80 00    	pushl  0x806010
  801966:	68 00 60 80 00       	push   $0x806000
  80196b:	ff 75 0c             	pushl  0xc(%ebp)
  80196e:	e8 e0 f0 ff ff       	call   800a53 <memmove>
		*addrlen = ret->ret_addrlen;
  801973:	a1 10 60 80 00       	mov    0x806010,%eax
  801978:	89 06                	mov    %eax,(%esi)
  80197a:	83 c4 10             	add    $0x10,%esp
	return r;
  80197d:	eb d5                	jmp    801954 <nsipc_accept+0x2b>

0080197f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80197f:	f3 0f 1e fb          	endbr32 
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	53                   	push   %ebx
  801987:	83 ec 08             	sub    $0x8,%esp
  80198a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80198d:	8b 45 08             	mov    0x8(%ebp),%eax
  801990:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801995:	53                   	push   %ebx
  801996:	ff 75 0c             	pushl  0xc(%ebp)
  801999:	68 04 60 80 00       	push   $0x806004
  80199e:	e8 b0 f0 ff ff       	call   800a53 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019a3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8019a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ae:	e8 2a ff ff ff       	call   8018dd <nsipc>
}
  8019b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019b8:	f3 0f 1e fb          	endbr32 
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019d2:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d7:	e8 01 ff ff ff       	call   8018dd <nsipc>
}
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <nsipc_close>:

int
nsipc_close(int s)
{
  8019de:	f3 0f 1e fb          	endbr32 
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f5:	e8 e3 fe ff ff       	call   8018dd <nsipc>
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019fc:	f3 0f 1e fb          	endbr32 
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	53                   	push   %ebx
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a12:	53                   	push   %ebx
  801a13:	ff 75 0c             	pushl  0xc(%ebp)
  801a16:	68 04 60 80 00       	push   $0x806004
  801a1b:	e8 33 f0 ff ff       	call   800a53 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a20:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a26:	b8 05 00 00 00       	mov    $0x5,%eax
  801a2b:	e8 ad fe ff ff       	call   8018dd <nsipc>
}
  801a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a35:	f3 0f 1e fb          	endbr32 
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a4f:	b8 06 00 00 00       	mov    $0x6,%eax
  801a54:	e8 84 fe ff ff       	call   8018dd <nsipc>
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a5b:	f3 0f 1e fb          	endbr32 
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a6f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a75:	8b 45 14             	mov    0x14(%ebp),%eax
  801a78:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a7d:	b8 07 00 00 00       	mov    $0x7,%eax
  801a82:	e8 56 fe ff ff       	call   8018dd <nsipc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 26                	js     801ab3 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801a8d:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801a93:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801a98:	0f 4e c6             	cmovle %esi,%eax
  801a9b:	39 c3                	cmp    %eax,%ebx
  801a9d:	7f 1d                	jg     801abc <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a9f:	83 ec 04             	sub    $0x4,%esp
  801aa2:	53                   	push   %ebx
  801aa3:	68 00 60 80 00       	push   $0x806000
  801aa8:	ff 75 0c             	pushl  0xc(%ebp)
  801aab:	e8 a3 ef ff ff       	call   800a53 <memmove>
  801ab0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ab3:	89 d8                	mov    %ebx,%eax
  801ab5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801abc:	68 af 28 80 00       	push   $0x8028af
  801ac1:	68 17 28 80 00       	push   $0x802817
  801ac6:	6a 62                	push   $0x62
  801ac8:	68 c4 28 80 00       	push   $0x8028c4
  801acd:	e8 92 e6 ff ff       	call   800164 <_panic>

00801ad2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ad2:	f3 0f 1e fb          	endbr32 
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	53                   	push   %ebx
  801ada:	83 ec 04             	sub    $0x4,%esp
  801add:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ae8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801aee:	7f 2e                	jg     801b1e <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801af0:	83 ec 04             	sub    $0x4,%esp
  801af3:	53                   	push   %ebx
  801af4:	ff 75 0c             	pushl  0xc(%ebp)
  801af7:	68 0c 60 80 00       	push   $0x80600c
  801afc:	e8 52 ef ff ff       	call   800a53 <memmove>
	nsipcbuf.send.req_size = size;
  801b01:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801b07:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801b0f:	b8 08 00 00 00       	mov    $0x8,%eax
  801b14:	e8 c4 fd ff ff       	call   8018dd <nsipc>
}
  801b19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    
	assert(size < 1600);
  801b1e:	68 d0 28 80 00       	push   $0x8028d0
  801b23:	68 17 28 80 00       	push   $0x802817
  801b28:	6a 6d                	push   $0x6d
  801b2a:	68 c4 28 80 00       	push   $0x8028c4
  801b2f:	e8 30 e6 ff ff       	call   800164 <_panic>

00801b34 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b34:	f3 0f 1e fb          	endbr32 
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b49:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b51:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b56:	b8 09 00 00 00       	mov    $0x9,%eax
  801b5b:	e8 7d fd ff ff       	call   8018dd <nsipc>
}
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b62:	f3 0f 1e fb          	endbr32 
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	56                   	push   %esi
  801b6a:	53                   	push   %ebx
  801b6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	ff 75 08             	pushl  0x8(%ebp)
  801b74:	e8 f0 f2 ff ff       	call   800e69 <fd2data>
  801b79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b7b:	83 c4 08             	add    $0x8,%esp
  801b7e:	68 dc 28 80 00       	push   $0x8028dc
  801b83:	53                   	push   %ebx
  801b84:	e8 cc ec ff ff       	call   800855 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b89:	8b 46 04             	mov    0x4(%esi),%eax
  801b8c:	2b 06                	sub    (%esi),%eax
  801b8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b9b:	00 00 00 
	stat->st_dev = &devpipe;
  801b9e:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801ba5:	30 80 00 
	return 0;
}
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    

00801bb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb4:	f3 0f 1e fb          	endbr32 
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bc2:	53                   	push   %ebx
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 3f f1 ff ff       	call   800d09 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bca:	89 1c 24             	mov    %ebx,(%esp)
  801bcd:	e8 97 f2 ff ff       	call   800e69 <fd2data>
  801bd2:	83 c4 08             	add    $0x8,%esp
  801bd5:	50                   	push   %eax
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 2c f1 ff ff       	call   800d09 <sys_page_unmap>
}
  801bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <_pipeisclosed>:
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	57                   	push   %edi
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	83 ec 1c             	sub    $0x1c,%esp
  801beb:	89 c7                	mov    %eax,%edi
  801bed:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801bef:	a1 08 40 80 00       	mov    0x804008,%eax
  801bf4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	57                   	push   %edi
  801bfb:	e8 5f 05 00 00       	call   80215f <pageref>
  801c00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c03:	89 34 24             	mov    %esi,(%esp)
  801c06:	e8 54 05 00 00       	call   80215f <pageref>
		nn = thisenv->env_runs;
  801c0b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	39 cb                	cmp    %ecx,%ebx
  801c19:	74 1b                	je     801c36 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c1b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c1e:	75 cf                	jne    801bef <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c20:	8b 42 58             	mov    0x58(%edx),%eax
  801c23:	6a 01                	push   $0x1
  801c25:	50                   	push   %eax
  801c26:	53                   	push   %ebx
  801c27:	68 e3 28 80 00       	push   $0x8028e3
  801c2c:	e8 1a e6 ff ff       	call   80024b <cprintf>
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	eb b9                	jmp    801bef <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c36:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c39:	0f 94 c0             	sete   %al
  801c3c:	0f b6 c0             	movzbl %al,%eax
}
  801c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <devpipe_write>:
{
  801c47:	f3 0f 1e fb          	endbr32 
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	57                   	push   %edi
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	83 ec 28             	sub    $0x28,%esp
  801c54:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c57:	56                   	push   %esi
  801c58:	e8 0c f2 ff ff       	call   800e69 <fd2data>
  801c5d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	bf 00 00 00 00       	mov    $0x0,%edi
  801c67:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c6a:	74 4f                	je     801cbb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c6c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6f:	8b 0b                	mov    (%ebx),%ecx
  801c71:	8d 51 20             	lea    0x20(%ecx),%edx
  801c74:	39 d0                	cmp    %edx,%eax
  801c76:	72 14                	jb     801c8c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c78:	89 da                	mov    %ebx,%edx
  801c7a:	89 f0                	mov    %esi,%eax
  801c7c:	e8 61 ff ff ff       	call   801be2 <_pipeisclosed>
  801c81:	85 c0                	test   %eax,%eax
  801c83:	75 3b                	jne    801cc0 <devpipe_write+0x79>
			sys_yield();
  801c85:	e8 11 f0 ff ff       	call   800c9b <sys_yield>
  801c8a:	eb e0                	jmp    801c6c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c96:	89 c2                	mov    %eax,%edx
  801c98:	c1 fa 1f             	sar    $0x1f,%edx
  801c9b:	89 d1                	mov    %edx,%ecx
  801c9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801ca0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ca3:	83 e2 1f             	and    $0x1f,%edx
  801ca6:	29 ca                	sub    %ecx,%edx
  801ca8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cb0:	83 c0 01             	add    $0x1,%eax
  801cb3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cb6:	83 c7 01             	add    $0x1,%edi
  801cb9:	eb ac                	jmp    801c67 <devpipe_write+0x20>
	return i;
  801cbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801cbe:	eb 05                	jmp    801cc5 <devpipe_write+0x7e>
				return 0;
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5f                   	pop    %edi
  801ccb:	5d                   	pop    %ebp
  801ccc:	c3                   	ret    

00801ccd <devpipe_read>:
{
  801ccd:	f3 0f 1e fb          	endbr32 
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	57                   	push   %edi
  801cd5:	56                   	push   %esi
  801cd6:	53                   	push   %ebx
  801cd7:	83 ec 18             	sub    $0x18,%esp
  801cda:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cdd:	57                   	push   %edi
  801cde:	e8 86 f1 ff ff       	call   800e69 <fd2data>
  801ce3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	be 00 00 00 00       	mov    $0x0,%esi
  801ced:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cf0:	75 14                	jne    801d06 <devpipe_read+0x39>
	return i;
  801cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf5:	eb 02                	jmp    801cf9 <devpipe_read+0x2c>
				return i;
  801cf7:	89 f0                	mov    %esi,%eax
}
  801cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    
			sys_yield();
  801d01:	e8 95 ef ff ff       	call   800c9b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d06:	8b 03                	mov    (%ebx),%eax
  801d08:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d0b:	75 18                	jne    801d25 <devpipe_read+0x58>
			if (i > 0)
  801d0d:	85 f6                	test   %esi,%esi
  801d0f:	75 e6                	jne    801cf7 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d11:	89 da                	mov    %ebx,%edx
  801d13:	89 f8                	mov    %edi,%eax
  801d15:	e8 c8 fe ff ff       	call   801be2 <_pipeisclosed>
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	74 e3                	je     801d01 <devpipe_read+0x34>
				return 0;
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d23:	eb d4                	jmp    801cf9 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d25:	99                   	cltd   
  801d26:	c1 ea 1b             	shr    $0x1b,%edx
  801d29:	01 d0                	add    %edx,%eax
  801d2b:	83 e0 1f             	and    $0x1f,%eax
  801d2e:	29 d0                	sub    %edx,%eax
  801d30:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d38:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d3b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d3e:	83 c6 01             	add    $0x1,%esi
  801d41:	eb aa                	jmp    801ced <devpipe_read+0x20>

00801d43 <pipe>:
{
  801d43:	f3 0f 1e fb          	endbr32 
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
  801d4c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d52:	50                   	push   %eax
  801d53:	e8 2c f1 ff ff       	call   800e84 <fd_alloc>
  801d58:	89 c3                	mov    %eax,%ebx
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	0f 88 23 01 00 00    	js     801e88 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d65:	83 ec 04             	sub    $0x4,%esp
  801d68:	68 07 04 00 00       	push   $0x407
  801d6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d70:	6a 00                	push   $0x0
  801d72:	e8 47 ef ff ff       	call   800cbe <sys_page_alloc>
  801d77:	89 c3                	mov    %eax,%ebx
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	0f 88 04 01 00 00    	js     801e88 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d84:	83 ec 0c             	sub    $0xc,%esp
  801d87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d8a:	50                   	push   %eax
  801d8b:	e8 f4 f0 ff ff       	call   800e84 <fd_alloc>
  801d90:	89 c3                	mov    %eax,%ebx
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	0f 88 db 00 00 00    	js     801e78 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9d:	83 ec 04             	sub    $0x4,%esp
  801da0:	68 07 04 00 00       	push   $0x407
  801da5:	ff 75 f0             	pushl  -0x10(%ebp)
  801da8:	6a 00                	push   $0x0
  801daa:	e8 0f ef ff ff       	call   800cbe <sys_page_alloc>
  801daf:	89 c3                	mov    %eax,%ebx
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	0f 88 bc 00 00 00    	js     801e78 <pipe+0x135>
	va = fd2data(fd0);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc2:	e8 a2 f0 ff ff       	call   800e69 <fd2data>
  801dc7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc9:	83 c4 0c             	add    $0xc,%esp
  801dcc:	68 07 04 00 00       	push   $0x407
  801dd1:	50                   	push   %eax
  801dd2:	6a 00                	push   $0x0
  801dd4:	e8 e5 ee ff ff       	call   800cbe <sys_page_alloc>
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	0f 88 82 00 00 00    	js     801e68 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de6:	83 ec 0c             	sub    $0xc,%esp
  801de9:	ff 75 f0             	pushl  -0x10(%ebp)
  801dec:	e8 78 f0 ff ff       	call   800e69 <fd2data>
  801df1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801df8:	50                   	push   %eax
  801df9:	6a 00                	push   $0x0
  801dfb:	56                   	push   %esi
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 e1 ee ff ff       	call   800ce4 <sys_page_map>
  801e03:	89 c3                	mov    %eax,%ebx
  801e05:	83 c4 20             	add    $0x20,%esp
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	78 4e                	js     801e5a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e0c:	a1 7c 30 80 00       	mov    0x80307c,%eax
  801e11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e14:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e19:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e23:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e2f:	83 ec 0c             	sub    $0xc,%esp
  801e32:	ff 75 f4             	pushl  -0xc(%ebp)
  801e35:	e8 1b f0 ff ff       	call   800e55 <fd2num>
  801e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e3f:	83 c4 04             	add    $0x4,%esp
  801e42:	ff 75 f0             	pushl  -0x10(%ebp)
  801e45:	e8 0b f0 ff ff       	call   800e55 <fd2num>
  801e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e58:	eb 2e                	jmp    801e88 <pipe+0x145>
	sys_page_unmap(0, va);
  801e5a:	83 ec 08             	sub    $0x8,%esp
  801e5d:	56                   	push   %esi
  801e5e:	6a 00                	push   $0x0
  801e60:	e8 a4 ee ff ff       	call   800d09 <sys_page_unmap>
  801e65:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6e:	6a 00                	push   $0x0
  801e70:	e8 94 ee ff ff       	call   800d09 <sys_page_unmap>
  801e75:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 84 ee ff ff       	call   800d09 <sys_page_unmap>
  801e85:	83 c4 10             	add    $0x10,%esp
}
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <pipeisclosed>:
{
  801e91:	f3 0f 1e fb          	endbr32 
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	ff 75 08             	pushl  0x8(%ebp)
  801ea2:	e8 33 f0 ff ff       	call   800eda <fd_lookup>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 18                	js     801ec6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb4:	e8 b0 ef ff ff       	call   800e69 <fd2data>
  801eb9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	e8 1f fd ff ff       	call   801be2 <_pipeisclosed>
  801ec3:	83 c4 10             	add    $0x10,%esp
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ec8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed1:	c3                   	ret    

00801ed2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ed2:	f3 0f 1e fb          	endbr32 
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801edc:	68 fb 28 80 00       	push   $0x8028fb
  801ee1:	ff 75 0c             	pushl  0xc(%ebp)
  801ee4:	e8 6c e9 ff ff       	call   800855 <strcpy>
	return 0;
}
  801ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <devcons_write>:
{
  801ef0:	f3 0f 1e fb          	endbr32 
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	57                   	push   %edi
  801ef8:	56                   	push   %esi
  801ef9:	53                   	push   %ebx
  801efa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f00:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f05:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f0e:	73 31                	jae    801f41 <devcons_write+0x51>
		m = n - tot;
  801f10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f13:	29 f3                	sub    %esi,%ebx
  801f15:	83 fb 7f             	cmp    $0x7f,%ebx
  801f18:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f1d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f20:	83 ec 04             	sub    $0x4,%esp
  801f23:	53                   	push   %ebx
  801f24:	89 f0                	mov    %esi,%eax
  801f26:	03 45 0c             	add    0xc(%ebp),%eax
  801f29:	50                   	push   %eax
  801f2a:	57                   	push   %edi
  801f2b:	e8 23 eb ff ff       	call   800a53 <memmove>
		sys_cputs(buf, m);
  801f30:	83 c4 08             	add    $0x8,%esp
  801f33:	53                   	push   %ebx
  801f34:	57                   	push   %edi
  801f35:	e8 d5 ec ff ff       	call   800c0f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f3a:	01 de                	add    %ebx,%esi
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	eb ca                	jmp    801f0b <devcons_write+0x1b>
}
  801f41:	89 f0                	mov    %esi,%eax
  801f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5f                   	pop    %edi
  801f49:	5d                   	pop    %ebp
  801f4a:	c3                   	ret    

00801f4b <devcons_read>:
{
  801f4b:	f3 0f 1e fb          	endbr32 
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	83 ec 08             	sub    $0x8,%esp
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f5e:	74 21                	je     801f81 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f60:	e8 cc ec ff ff       	call   800c31 <sys_cgetc>
  801f65:	85 c0                	test   %eax,%eax
  801f67:	75 07                	jne    801f70 <devcons_read+0x25>
		sys_yield();
  801f69:	e8 2d ed ff ff       	call   800c9b <sys_yield>
  801f6e:	eb f0                	jmp    801f60 <devcons_read+0x15>
	if (c < 0)
  801f70:	78 0f                	js     801f81 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f72:	83 f8 04             	cmp    $0x4,%eax
  801f75:	74 0c                	je     801f83 <devcons_read+0x38>
	*(char*)vbuf = c;
  801f77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f7a:	88 02                	mov    %al,(%edx)
	return 1;
  801f7c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    
		return 0;
  801f83:	b8 00 00 00 00       	mov    $0x0,%eax
  801f88:	eb f7                	jmp    801f81 <devcons_read+0x36>

00801f8a <cputchar>:
{
  801f8a:	f3 0f 1e fb          	endbr32 
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f94:	8b 45 08             	mov    0x8(%ebp),%eax
  801f97:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f9a:	6a 01                	push   $0x1
  801f9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f9f:	50                   	push   %eax
  801fa0:	e8 6a ec ff ff       	call   800c0f <sys_cputs>
}
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	c9                   	leave  
  801fa9:	c3                   	ret    

00801faa <getchar>:
{
  801faa:	f3 0f 1e fb          	endbr32 
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fb4:	6a 01                	push   $0x1
  801fb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb9:	50                   	push   %eax
  801fba:	6a 00                	push   $0x0
  801fbc:	e8 a1 f1 ff ff       	call   801162 <read>
	if (r < 0)
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	78 06                	js     801fce <getchar+0x24>
	if (r < 1)
  801fc8:	74 06                	je     801fd0 <getchar+0x26>
	return c;
  801fca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    
		return -E_EOF;
  801fd0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fd5:	eb f7                	jmp    801fce <getchar+0x24>

00801fd7 <iscons>:
{
  801fd7:	f3 0f 1e fb          	endbr32 
  801fdb:	55                   	push   %ebp
  801fdc:	89 e5                	mov    %esp,%ebp
  801fde:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe4:	50                   	push   %eax
  801fe5:	ff 75 08             	pushl  0x8(%ebp)
  801fe8:	e8 ed ee ff ff       	call   800eda <fd_lookup>
  801fed:	83 c4 10             	add    $0x10,%esp
  801ff0:	85 c0                	test   %eax,%eax
  801ff2:	78 11                	js     802005 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff7:	8b 15 98 30 80 00    	mov    0x803098,%edx
  801ffd:	39 10                	cmp    %edx,(%eax)
  801fff:	0f 94 c0             	sete   %al
  802002:	0f b6 c0             	movzbl %al,%eax
}
  802005:	c9                   	leave  
  802006:	c3                   	ret    

00802007 <opencons>:
{
  802007:	f3 0f 1e fb          	endbr32 
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802011:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802014:	50                   	push   %eax
  802015:	e8 6a ee ff ff       	call   800e84 <fd_alloc>
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	85 c0                	test   %eax,%eax
  80201f:	78 3a                	js     80205b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802021:	83 ec 04             	sub    $0x4,%esp
  802024:	68 07 04 00 00       	push   $0x407
  802029:	ff 75 f4             	pushl  -0xc(%ebp)
  80202c:	6a 00                	push   $0x0
  80202e:	e8 8b ec ff ff       	call   800cbe <sys_page_alloc>
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	85 c0                	test   %eax,%eax
  802038:	78 21                	js     80205b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80203a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203d:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802043:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802048:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80204f:	83 ec 0c             	sub    $0xc,%esp
  802052:	50                   	push   %eax
  802053:	e8 fd ed ff ff       	call   800e55 <fd2num>
  802058:	83 c4 10             	add    $0x10,%esp
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80205d:	f3 0f 1e fb          	endbr32 
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	56                   	push   %esi
  802065:	53                   	push   %ebx
  802066:	8b 75 08             	mov    0x8(%ebp),%esi
  802069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80206f:	85 c0                	test   %eax,%eax
  802071:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802076:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802079:	83 ec 0c             	sub    $0xc,%esp
  80207c:	50                   	push   %eax
  80207d:	e8 42 ed ff ff       	call   800dc4 <sys_ipc_recv>
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	85 c0                	test   %eax,%eax
  802087:	75 2b                	jne    8020b4 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802089:	85 f6                	test   %esi,%esi
  80208b:	74 0a                	je     802097 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80208d:	a1 08 40 80 00       	mov    0x804008,%eax
  802092:	8b 40 74             	mov    0x74(%eax),%eax
  802095:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802097:	85 db                	test   %ebx,%ebx
  802099:	74 0a                	je     8020a5 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80209b:	a1 08 40 80 00       	mov    0x804008,%eax
  8020a0:	8b 40 78             	mov    0x78(%eax),%eax
  8020a3:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8020a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8020aa:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b0:	5b                   	pop    %ebx
  8020b1:	5e                   	pop    %esi
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8020b4:	85 f6                	test   %esi,%esi
  8020b6:	74 06                	je     8020be <ipc_recv+0x61>
  8020b8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8020be:	85 db                	test   %ebx,%ebx
  8020c0:	74 eb                	je     8020ad <ipc_recv+0x50>
  8020c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020c8:	eb e3                	jmp    8020ad <ipc_recv+0x50>

008020ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ca:	f3 0f 1e fb          	endbr32 
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 0c             	sub    $0xc,%esp
  8020d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8020e0:	85 db                	test   %ebx,%ebx
  8020e2:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020e7:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8020ea:	ff 75 14             	pushl  0x14(%ebp)
  8020ed:	53                   	push   %ebx
  8020ee:	56                   	push   %esi
  8020ef:	57                   	push   %edi
  8020f0:	e8 a8 ec ff ff       	call   800d9d <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020fb:	75 07                	jne    802104 <ipc_send+0x3a>
			sys_yield();
  8020fd:	e8 99 eb ff ff       	call   800c9b <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802102:	eb e6                	jmp    8020ea <ipc_send+0x20>
		}
		else if (ret == 0)
  802104:	85 c0                	test   %eax,%eax
  802106:	75 08                	jne    802110 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80210b:	5b                   	pop    %ebx
  80210c:	5e                   	pop    %esi
  80210d:	5f                   	pop    %edi
  80210e:	5d                   	pop    %ebp
  80210f:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802110:	50                   	push   %eax
  802111:	68 07 29 80 00       	push   $0x802907
  802116:	6a 48                	push   $0x48
  802118:	68 15 29 80 00       	push   $0x802915
  80211d:	e8 42 e0 ff ff       	call   800164 <_panic>

00802122 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802122:	f3 0f 1e fb          	endbr32 
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80212c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802131:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802134:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80213a:	8b 52 50             	mov    0x50(%edx),%edx
  80213d:	39 ca                	cmp    %ecx,%edx
  80213f:	74 11                	je     802152 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802141:	83 c0 01             	add    $0x1,%eax
  802144:	3d 00 04 00 00       	cmp    $0x400,%eax
  802149:	75 e6                	jne    802131 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80214b:	b8 00 00 00 00       	mov    $0x0,%eax
  802150:	eb 0b                	jmp    80215d <ipc_find_env+0x3b>
			return envs[i].env_id;
  802152:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802155:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80215a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80215f:	f3 0f 1e fb          	endbr32 
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802169:	89 c2                	mov    %eax,%edx
  80216b:	c1 ea 16             	shr    $0x16,%edx
  80216e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802175:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80217a:	f6 c1 01             	test   $0x1,%cl
  80217d:	74 1c                	je     80219b <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80217f:	c1 e8 0c             	shr    $0xc,%eax
  802182:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802189:	a8 01                	test   $0x1,%al
  80218b:	74 0e                	je     80219b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80218d:	c1 e8 0c             	shr    $0xc,%eax
  802190:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802197:	ef 
  802198:	0f b7 d2             	movzwl %dx,%edx
}
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	5d                   	pop    %ebp
  80219e:	c3                   	ret    
  80219f:	90                   	nop

008021a0 <__udivdi3>:
  8021a0:	f3 0f 1e fb          	endbr32 
  8021a4:	55                   	push   %ebp
  8021a5:	57                   	push   %edi
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 1c             	sub    $0x1c,%esp
  8021ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021bb:	85 d2                	test   %edx,%edx
  8021bd:	75 19                	jne    8021d8 <__udivdi3+0x38>
  8021bf:	39 f3                	cmp    %esi,%ebx
  8021c1:	76 4d                	jbe    802210 <__udivdi3+0x70>
  8021c3:	31 ff                	xor    %edi,%edi
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	89 f2                	mov    %esi,%edx
  8021c9:	f7 f3                	div    %ebx
  8021cb:	89 fa                	mov    %edi,%edx
  8021cd:	83 c4 1c             	add    $0x1c,%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	76 14                	jbe    8021f0 <__udivdi3+0x50>
  8021dc:	31 ff                	xor    %edi,%edi
  8021de:	31 c0                	xor    %eax,%eax
  8021e0:	89 fa                	mov    %edi,%edx
  8021e2:	83 c4 1c             	add    $0x1c,%esp
  8021e5:	5b                   	pop    %ebx
  8021e6:	5e                   	pop    %esi
  8021e7:	5f                   	pop    %edi
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    
  8021ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f0:	0f bd fa             	bsr    %edx,%edi
  8021f3:	83 f7 1f             	xor    $0x1f,%edi
  8021f6:	75 48                	jne    802240 <__udivdi3+0xa0>
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	72 06                	jb     802202 <__udivdi3+0x62>
  8021fc:	31 c0                	xor    %eax,%eax
  8021fe:	39 eb                	cmp    %ebp,%ebx
  802200:	77 de                	ja     8021e0 <__udivdi3+0x40>
  802202:	b8 01 00 00 00       	mov    $0x1,%eax
  802207:	eb d7                	jmp    8021e0 <__udivdi3+0x40>
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d9                	mov    %ebx,%ecx
  802212:	85 db                	test   %ebx,%ebx
  802214:	75 0b                	jne    802221 <__udivdi3+0x81>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f3                	div    %ebx
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	31 d2                	xor    %edx,%edx
  802223:	89 f0                	mov    %esi,%eax
  802225:	f7 f1                	div    %ecx
  802227:	89 c6                	mov    %eax,%esi
  802229:	89 e8                	mov    %ebp,%eax
  80222b:	89 f7                	mov    %esi,%edi
  80222d:	f7 f1                	div    %ecx
  80222f:	89 fa                	mov    %edi,%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 f9                	mov    %edi,%ecx
  802242:	b8 20 00 00 00       	mov    $0x20,%eax
  802247:	29 f8                	sub    %edi,%eax
  802249:	d3 e2                	shl    %cl,%edx
  80224b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	89 da                	mov    %ebx,%edx
  802253:	d3 ea                	shr    %cl,%edx
  802255:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802259:	09 d1                	or     %edx,%ecx
  80225b:	89 f2                	mov    %esi,%edx
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e3                	shl    %cl,%ebx
  802265:	89 c1                	mov    %eax,%ecx
  802267:	d3 ea                	shr    %cl,%edx
  802269:	89 f9                	mov    %edi,%ecx
  80226b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80226f:	89 eb                	mov    %ebp,%ebx
  802271:	d3 e6                	shl    %cl,%esi
  802273:	89 c1                	mov    %eax,%ecx
  802275:	d3 eb                	shr    %cl,%ebx
  802277:	09 de                	or     %ebx,%esi
  802279:	89 f0                	mov    %esi,%eax
  80227b:	f7 74 24 08          	divl   0x8(%esp)
  80227f:	89 d6                	mov    %edx,%esi
  802281:	89 c3                	mov    %eax,%ebx
  802283:	f7 64 24 0c          	mull   0xc(%esp)
  802287:	39 d6                	cmp    %edx,%esi
  802289:	72 15                	jb     8022a0 <__udivdi3+0x100>
  80228b:	89 f9                	mov    %edi,%ecx
  80228d:	d3 e5                	shl    %cl,%ebp
  80228f:	39 c5                	cmp    %eax,%ebp
  802291:	73 04                	jae    802297 <__udivdi3+0xf7>
  802293:	39 d6                	cmp    %edx,%esi
  802295:	74 09                	je     8022a0 <__udivdi3+0x100>
  802297:	89 d8                	mov    %ebx,%eax
  802299:	31 ff                	xor    %edi,%edi
  80229b:	e9 40 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022a3:	31 ff                	xor    %edi,%edi
  8022a5:	e9 36 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	f3 0f 1e fb          	endbr32 
  8022b4:	55                   	push   %ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	83 ec 1c             	sub    $0x1c,%esp
  8022bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	75 19                	jne    8022e8 <__umoddi3+0x38>
  8022cf:	39 df                	cmp    %ebx,%edi
  8022d1:	76 5d                	jbe    802330 <__umoddi3+0x80>
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	89 da                	mov    %ebx,%edx
  8022d7:	f7 f7                	div    %edi
  8022d9:	89 d0                	mov    %edx,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	83 c4 1c             	add    $0x1c,%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
  8022e8:	89 f2                	mov    %esi,%edx
  8022ea:	39 d8                	cmp    %ebx,%eax
  8022ec:	76 12                	jbe    802300 <__umoddi3+0x50>
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	89 da                	mov    %ebx,%edx
  8022f2:	83 c4 1c             	add    $0x1c,%esp
  8022f5:	5b                   	pop    %ebx
  8022f6:	5e                   	pop    %esi
  8022f7:	5f                   	pop    %edi
  8022f8:	5d                   	pop    %ebp
  8022f9:	c3                   	ret    
  8022fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802300:	0f bd e8             	bsr    %eax,%ebp
  802303:	83 f5 1f             	xor    $0x1f,%ebp
  802306:	75 50                	jne    802358 <__umoddi3+0xa8>
  802308:	39 d8                	cmp    %ebx,%eax
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	89 d9                	mov    %ebx,%ecx
  802312:	39 f7                	cmp    %esi,%edi
  802314:	0f 86 d6 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	89 ca                	mov    %ecx,%edx
  80231e:	83 c4 1c             	add    $0x1c,%esp
  802321:	5b                   	pop    %ebx
  802322:	5e                   	pop    %esi
  802323:	5f                   	pop    %edi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	89 fd                	mov    %edi,%ebp
  802332:	85 ff                	test   %edi,%edi
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 d8                	mov    %ebx,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 f0                	mov    %esi,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	31 d2                	xor    %edx,%edx
  80234f:	eb 8c                	jmp    8022dd <__umoddi3+0x2d>
  802351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	ba 20 00 00 00       	mov    $0x20,%edx
  80235f:	29 ea                	sub    %ebp,%edx
  802361:	d3 e0                	shl    %cl,%eax
  802363:	89 44 24 08          	mov    %eax,0x8(%esp)
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 f8                	mov    %edi,%eax
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802371:	89 54 24 04          	mov    %edx,0x4(%esp)
  802375:	8b 54 24 04          	mov    0x4(%esp),%edx
  802379:	09 c1                	or     %eax,%ecx
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 e9                	mov    %ebp,%ecx
  802383:	d3 e7                	shl    %cl,%edi
  802385:	89 d1                	mov    %edx,%ecx
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80238f:	d3 e3                	shl    %cl,%ebx
  802391:	89 c7                	mov    %eax,%edi
  802393:	89 d1                	mov    %edx,%ecx
  802395:	89 f0                	mov    %esi,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	89 fa                	mov    %edi,%edx
  80239d:	d3 e6                	shl    %cl,%esi
  80239f:	09 d8                	or     %ebx,%eax
  8023a1:	f7 74 24 08          	divl   0x8(%esp)
  8023a5:	89 d1                	mov    %edx,%ecx
  8023a7:	89 f3                	mov    %esi,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	89 c6                	mov    %eax,%esi
  8023af:	89 d7                	mov    %edx,%edi
  8023b1:	39 d1                	cmp    %edx,%ecx
  8023b3:	72 06                	jb     8023bb <__umoddi3+0x10b>
  8023b5:	75 10                	jne    8023c7 <__umoddi3+0x117>
  8023b7:	39 c3                	cmp    %eax,%ebx
  8023b9:	73 0c                	jae    8023c7 <__umoddi3+0x117>
  8023bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023c3:	89 d7                	mov    %edx,%edi
  8023c5:	89 c6                	mov    %eax,%esi
  8023c7:	89 ca                	mov    %ecx,%edx
  8023c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023ce:	29 f3                	sub    %esi,%ebx
  8023d0:	19 fa                	sbb    %edi,%edx
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	d3 e0                	shl    %cl,%eax
  8023d6:	89 e9                	mov    %ebp,%ecx
  8023d8:	d3 eb                	shr    %cl,%ebx
  8023da:	d3 ea                	shr    %cl,%edx
  8023dc:	09 d8                	or     %ebx,%eax
  8023de:	83 c4 1c             	add    $0x1c,%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
  8023e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 fe                	sub    %edi,%esi
  8023f2:	19 c3                	sbb    %eax,%ebx
  8023f4:	89 f2                	mov    %esi,%edx
  8023f6:	89 d9                	mov    %ebx,%ecx
  8023f8:	e9 1d ff ff ff       	jmp    80231a <__umoddi3+0x6a>
