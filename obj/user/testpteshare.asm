
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 6b 01 00 00       	call   80019c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  80003d:	ff 35 00 40 80 00    	pushl  0x804000
  800043:	68 00 00 00 a0       	push   $0xa0000000
  800048:	e8 a8 08 00 00       	call   8008f5 <strcpy>
	exit();
  80004d:	e8 94 01 00 00       	call   8001e6 <exit>
}
  800052:	83 c4 10             	add    $0x10,%esp
  800055:	c9                   	leave  
  800056:	c3                   	ret    

00800057 <umain>:
{
  800057:	f3 0f 1e fb          	endbr32 
  80005b:	55                   	push   %ebp
  80005c:	89 e5                	mov    %esp,%ebp
  80005e:	53                   	push   %ebx
  80005f:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  800062:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800066:	0f 85 d0 00 00 00    	jne    80013c <umain+0xe5>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 07 04 00 00       	push   $0x407
  800074:	68 00 00 00 a0       	push   $0xa0000000
  800079:	6a 00                	push   $0x0
  80007b:	e8 de 0c 00 00       	call   800d5e <sys_page_alloc>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	85 c0                	test   %eax,%eax
  800085:	0f 88 bb 00 00 00    	js     800146 <umain+0xef>
	if ((r = fork()) < 0)
  80008b:	e8 61 0f 00 00       	call   800ff1 <fork>
  800090:	89 c3                	mov    %eax,%ebx
  800092:	85 c0                	test   %eax,%eax
  800094:	0f 88 be 00 00 00    	js     800158 <umain+0x101>
	if (r == 0) {
  80009a:	0f 84 ca 00 00 00    	je     80016a <umain+0x113>
	wait(r);
  8000a0:	83 ec 0c             	sub    $0xc,%esp
  8000a3:	53                   	push   %ebx
  8000a4:	e8 77 27 00 00       	call   802820 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	ff 35 04 40 80 00    	pushl  0x804004
  8000b2:	68 00 00 00 a0       	push   $0xa0000000
  8000b7:	e8 f8 08 00 00       	call   8009b4 <strcmp>
  8000bc:	83 c4 08             	add    $0x8,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	b8 60 2e 80 00       	mov    $0x802e60,%eax
  8000c6:	ba 66 2e 80 00       	mov    $0x802e66,%edx
  8000cb:	0f 45 c2             	cmovne %edx,%eax
  8000ce:	50                   	push   %eax
  8000cf:	68 9c 2e 80 00       	push   $0x802e9c
  8000d4:	e8 12 02 00 00       	call   8002eb <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000d9:	6a 00                	push   $0x0
  8000db:	68 b7 2e 80 00       	push   $0x802eb7
  8000e0:	68 bc 2e 80 00       	push   $0x802ebc
  8000e5:	68 bb 2e 80 00       	push   $0x802ebb
  8000ea:	e8 61 1e 00 00       	call   801f50 <spawnl>
  8000ef:	83 c4 20             	add    $0x20,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	0f 88 90 00 00 00    	js     80018a <umain+0x133>
	wait(r);
  8000fa:	83 ec 0c             	sub    $0xc,%esp
  8000fd:	50                   	push   %eax
  8000fe:	e8 1d 27 00 00       	call   802820 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800103:	83 c4 08             	add    $0x8,%esp
  800106:	ff 35 00 40 80 00    	pushl  0x804000
  80010c:	68 00 00 00 a0       	push   $0xa0000000
  800111:	e8 9e 08 00 00       	call   8009b4 <strcmp>
  800116:	83 c4 08             	add    $0x8,%esp
  800119:	85 c0                	test   %eax,%eax
  80011b:	b8 60 2e 80 00       	mov    $0x802e60,%eax
  800120:	ba 66 2e 80 00       	mov    $0x802e66,%edx
  800125:	0f 45 c2             	cmovne %edx,%eax
  800128:	50                   	push   %eax
  800129:	68 d3 2e 80 00       	push   $0x802ed3
  80012e:	e8 b8 01 00 00       	call   8002eb <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800133:	cc                   	int3   
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    
		childofspawn();
  80013c:	e8 f2 fe ff ff       	call   800033 <childofspawn>
  800141:	e9 26 ff ff ff       	jmp    80006c <umain+0x15>
		panic("sys_page_alloc: %e", r);
  800146:	50                   	push   %eax
  800147:	68 6c 2e 80 00       	push   $0x802e6c
  80014c:	6a 13                	push   $0x13
  80014e:	68 7f 2e 80 00       	push   $0x802e7f
  800153:	e8 ac 00 00 00       	call   800204 <_panic>
		panic("fork: %e", r);
  800158:	50                   	push   %eax
  800159:	68 93 2e 80 00       	push   $0x802e93
  80015e:	6a 17                	push   $0x17
  800160:	68 7f 2e 80 00       	push   $0x802e7f
  800165:	e8 9a 00 00 00       	call   800204 <_panic>
		strcpy(VA, msg);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	ff 35 04 40 80 00    	pushl  0x804004
  800173:	68 00 00 00 a0       	push   $0xa0000000
  800178:	e8 78 07 00 00       	call   8008f5 <strcpy>
		exit();
  80017d:	e8 64 00 00 00       	call   8001e6 <exit>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	e9 16 ff ff ff       	jmp    8000a0 <umain+0x49>
		panic("spawn: %e", r);
  80018a:	50                   	push   %eax
  80018b:	68 c9 2e 80 00       	push   $0x802ec9
  800190:	6a 21                	push   $0x21
  800192:	68 7f 2e 80 00       	push   $0x802e7f
  800197:	e8 68 00 00 00       	call   800204 <_panic>

0080019c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80019c:	f3 0f 1e fb          	endbr32 
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
  8001a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ab:	e8 68 0b 00 00       	call   800d18 <sys_getenvid>
  8001b0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001bd:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c2:	85 db                	test   %ebx,%ebx
  8001c4:	7e 07                	jle    8001cd <libmain+0x31>
		binaryname = argv[0];
  8001c6:	8b 06                	mov    (%esi),%eax
  8001c8:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	e8 80 fe ff ff       	call   800057 <umain>

	// exit gracefully
	exit();
  8001d7:	e8 0a 00 00 00       	call   8001e6 <exit>
}
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e6:	f3 0f 1e fb          	endbr32 
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8001f0:	e8 81 11 00 00       	call   801376 <close_all>
	sys_env_destroy(0);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	6a 00                	push   $0x0
  8001fa:	e8 f5 0a 00 00       	call   800cf4 <sys_env_destroy>
}
  8001ff:	83 c4 10             	add    $0x10,%esp
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800204:	f3 0f 1e fb          	endbr32 
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80020d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800210:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800216:	e8 fd 0a 00 00       	call   800d18 <sys_getenvid>
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	ff 75 0c             	pushl  0xc(%ebp)
  800221:	ff 75 08             	pushl  0x8(%ebp)
  800224:	56                   	push   %esi
  800225:	50                   	push   %eax
  800226:	68 18 2f 80 00       	push   $0x802f18
  80022b:	e8 bb 00 00 00       	call   8002eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800230:	83 c4 18             	add    $0x18,%esp
  800233:	53                   	push   %ebx
  800234:	ff 75 10             	pushl  0x10(%ebp)
  800237:	e8 5a 00 00 00       	call   800296 <vcprintf>
	cprintf("\n");
  80023c:	c7 04 24 63 35 80 00 	movl   $0x803563,(%esp)
  800243:	e8 a3 00 00 00       	call   8002eb <cprintf>
  800248:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80024b:	cc                   	int3   
  80024c:	eb fd                	jmp    80024b <_panic+0x47>

0080024e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80024e:	f3 0f 1e fb          	endbr32 
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	53                   	push   %ebx
  800256:	83 ec 04             	sub    $0x4,%esp
  800259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025c:	8b 13                	mov    (%ebx),%edx
  80025e:	8d 42 01             	lea    0x1(%edx),%eax
  800261:	89 03                	mov    %eax,(%ebx)
  800263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800266:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80026a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026f:	74 09                	je     80027a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800271:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800278:	c9                   	leave  
  800279:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	68 ff 00 00 00       	push   $0xff
  800282:	8d 43 08             	lea    0x8(%ebx),%eax
  800285:	50                   	push   %eax
  800286:	e8 24 0a 00 00       	call   800caf <sys_cputs>
		b->idx = 0;
  80028b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800291:	83 c4 10             	add    $0x10,%esp
  800294:	eb db                	jmp    800271 <putch+0x23>

00800296 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800296:	f3 0f 1e fb          	endbr32 
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002aa:	00 00 00 
	b.cnt = 0;
  8002ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ba:	ff 75 08             	pushl  0x8(%ebp)
  8002bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	68 4e 02 80 00       	push   $0x80024e
  8002c9:	e8 20 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ce:	83 c4 08             	add    $0x8,%esp
  8002d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002dd:	50                   	push   %eax
  8002de:	e8 cc 09 00 00       	call   800caf <sys_cputs>

	return b.cnt;
}
  8002e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002eb:	f3 0f 1e fb          	endbr32 
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f8:	50                   	push   %eax
  8002f9:	ff 75 08             	pushl  0x8(%ebp)
  8002fc:	e8 95 ff ff ff       	call   800296 <vcprintf>
	va_end(ap);

	return cnt;
}
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 1c             	sub    $0x1c,%esp
  80030c:	89 c7                	mov    %eax,%edi
  80030e:	89 d6                	mov    %edx,%esi
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	8b 55 0c             	mov    0xc(%ebp),%edx
  800316:	89 d1                	mov    %edx,%ecx
  800318:	89 c2                	mov    %eax,%edx
  80031a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800320:	8b 45 10             	mov    0x10(%ebp),%eax
  800323:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800326:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800329:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800330:	39 c2                	cmp    %eax,%edx
  800332:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800335:	72 3e                	jb     800375 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 18             	pushl  0x18(%ebp)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	53                   	push   %ebx
  800341:	50                   	push   %eax
  800342:	83 ec 08             	sub    $0x8,%esp
  800345:	ff 75 e4             	pushl  -0x1c(%ebp)
  800348:	ff 75 e0             	pushl  -0x20(%ebp)
  80034b:	ff 75 dc             	pushl  -0x24(%ebp)
  80034e:	ff 75 d8             	pushl  -0x28(%ebp)
  800351:	e8 9a 28 00 00       	call   802bf0 <__udivdi3>
  800356:	83 c4 18             	add    $0x18,%esp
  800359:	52                   	push   %edx
  80035a:	50                   	push   %eax
  80035b:	89 f2                	mov    %esi,%edx
  80035d:	89 f8                	mov    %edi,%eax
  80035f:	e8 9f ff ff ff       	call   800303 <printnum>
  800364:	83 c4 20             	add    $0x20,%esp
  800367:	eb 13                	jmp    80037c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	56                   	push   %esi
  80036d:	ff 75 18             	pushl  0x18(%ebp)
  800370:	ff d7                	call   *%edi
  800372:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800375:	83 eb 01             	sub    $0x1,%ebx
  800378:	85 db                	test   %ebx,%ebx
  80037a:	7f ed                	jg     800369 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	56                   	push   %esi
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	ff 75 e4             	pushl  -0x1c(%ebp)
  800386:	ff 75 e0             	pushl  -0x20(%ebp)
  800389:	ff 75 dc             	pushl  -0x24(%ebp)
  80038c:	ff 75 d8             	pushl  -0x28(%ebp)
  80038f:	e8 6c 29 00 00       	call   802d00 <__umoddi3>
  800394:	83 c4 14             	add    $0x14,%esp
  800397:	0f be 80 3b 2f 80 00 	movsbl 0x802f3b(%eax),%eax
  80039e:	50                   	push   %eax
  80039f:	ff d7                	call   *%edi
}
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a7:	5b                   	pop    %ebx
  8003a8:	5e                   	pop    %esi
  8003a9:	5f                   	pop    %edi
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ac:	f3 0f 1e fb          	endbr32 
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bf:	73 0a                	jae    8003cb <sprintputch+0x1f>
		*b->buf++ = ch;
  8003c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	88 02                	mov    %al,(%edx)
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <printfmt>:
{
  8003cd:	f3 0f 1e fb          	endbr32 
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
{
  8003ee:	f3 0f 1e fb          	endbr32 
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 3c             	sub    $0x3c,%esp
  8003fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800401:	8b 7d 10             	mov    0x10(%ebp),%edi
  800404:	e9 8e 03 00 00       	jmp    800797 <vprintfmt+0x3a9>
		padc = ' ';
  800409:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80040d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800414:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80041b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800422:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8d 47 01             	lea    0x1(%edi),%eax
  80042a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042d:	0f b6 17             	movzbl (%edi),%edx
  800430:	8d 42 dd             	lea    -0x23(%edx),%eax
  800433:	3c 55                	cmp    $0x55,%al
  800435:	0f 87 df 03 00 00    	ja     80081a <vprintfmt+0x42c>
  80043b:	0f b6 c0             	movzbl %al,%eax
  80043e:	3e ff 24 85 80 30 80 	notrack jmp *0x803080(,%eax,4)
  800445:	00 
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800449:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80044d:	eb d8                	jmp    800427 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800452:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800456:	eb cf                	jmp    800427 <vprintfmt+0x39>
  800458:	0f b6 d2             	movzbl %dl,%edx
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800466:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800469:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80046d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800470:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800473:	83 f9 09             	cmp    $0x9,%ecx
  800476:	77 55                	ja     8004cd <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800478:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80047b:	eb e9                	jmp    800466 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8b 00                	mov    (%eax),%eax
  800482:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 40 04             	lea    0x4(%eax),%eax
  80048b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800491:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800495:	79 90                	jns    800427 <vprintfmt+0x39>
				width = precision, precision = -1;
  800497:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80049a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004a4:	eb 81                	jmp    800427 <vprintfmt+0x39>
  8004a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b0:	0f 49 d0             	cmovns %eax,%edx
  8004b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b9:	e9 69 ff ff ff       	jmp    800427 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004c1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004c8:	e9 5a ff ff ff       	jmp    800427 <vprintfmt+0x39>
  8004cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d3:	eb bc                	jmp    800491 <vprintfmt+0xa3>
			lflag++;
  8004d5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004db:	e9 47 ff ff ff       	jmp    800427 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 78 04             	lea    0x4(%eax),%edi
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	53                   	push   %ebx
  8004ea:	ff 30                	pushl  (%eax)
  8004ec:	ff d6                	call   *%esi
			break;
  8004ee:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004f1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004f4:	e9 9b 02 00 00       	jmp    800794 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 78 04             	lea    0x4(%eax),%edi
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	99                   	cltd   
  800502:	31 d0                	xor    %edx,%eax
  800504:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800506:	83 f8 0f             	cmp    $0xf,%eax
  800509:	7f 23                	jg     80052e <vprintfmt+0x140>
  80050b:	8b 14 85 e0 31 80 00 	mov    0x8031e0(,%eax,4),%edx
  800512:	85 d2                	test   %edx,%edx
  800514:	74 18                	je     80052e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800516:	52                   	push   %edx
  800517:	68 e5 33 80 00       	push   $0x8033e5
  80051c:	53                   	push   %ebx
  80051d:	56                   	push   %esi
  80051e:	e8 aa fe ff ff       	call   8003cd <printfmt>
  800523:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800526:	89 7d 14             	mov    %edi,0x14(%ebp)
  800529:	e9 66 02 00 00       	jmp    800794 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80052e:	50                   	push   %eax
  80052f:	68 53 2f 80 00       	push   $0x802f53
  800534:	53                   	push   %ebx
  800535:	56                   	push   %esi
  800536:	e8 92 fe ff ff       	call   8003cd <printfmt>
  80053b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80053e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800541:	e9 4e 02 00 00       	jmp    800794 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	83 c0 04             	add    $0x4,%eax
  80054c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800554:	85 d2                	test   %edx,%edx
  800556:	b8 4c 2f 80 00       	mov    $0x802f4c,%eax
  80055b:	0f 45 c2             	cmovne %edx,%eax
  80055e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800561:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800565:	7e 06                	jle    80056d <vprintfmt+0x17f>
  800567:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80056b:	75 0d                	jne    80057a <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800570:	89 c7                	mov    %eax,%edi
  800572:	03 45 e0             	add    -0x20(%ebp),%eax
  800575:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800578:	eb 55                	jmp    8005cf <vprintfmt+0x1e1>
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	ff 75 d8             	pushl  -0x28(%ebp)
  800580:	ff 75 cc             	pushl  -0x34(%ebp)
  800583:	e8 46 03 00 00       	call   8008ce <strnlen>
  800588:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80058b:	29 c2                	sub    %eax,%edx
  80058d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800595:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800599:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7e 11                	jle    8005b1 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	53                   	push   %ebx
  8005a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005a7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a9:	83 ef 01             	sub    $0x1,%edi
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	eb eb                	jmp    80059c <vprintfmt+0x1ae>
  8005b1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bb:	0f 49 c2             	cmovns %edx,%eax
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005c3:	eb a8                	jmp    80056d <vprintfmt+0x17f>
					putch(ch, putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	52                   	push   %edx
  8005ca:	ff d6                	call   *%esi
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d4:	83 c7 01             	add    $0x1,%edi
  8005d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005db:	0f be d0             	movsbl %al,%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 4b                	je     80062d <vprintfmt+0x23f>
  8005e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e6:	78 06                	js     8005ee <vprintfmt+0x200>
  8005e8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ec:	78 1e                	js     80060c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8005ee:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f2:	74 d1                	je     8005c5 <vprintfmt+0x1d7>
  8005f4:	0f be c0             	movsbl %al,%eax
  8005f7:	83 e8 20             	sub    $0x20,%eax
  8005fa:	83 f8 5e             	cmp    $0x5e,%eax
  8005fd:	76 c6                	jbe    8005c5 <vprintfmt+0x1d7>
					putch('?', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 3f                	push   $0x3f
  800605:	ff d6                	call   *%esi
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	eb c3                	jmp    8005cf <vprintfmt+0x1e1>
  80060c:	89 cf                	mov    %ecx,%edi
  80060e:	eb 0e                	jmp    80061e <vprintfmt+0x230>
				putch(' ', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 20                	push   $0x20
  800616:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800618:	83 ef 01             	sub    $0x1,%edi
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	85 ff                	test   %edi,%edi
  800620:	7f ee                	jg     800610 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800622:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
  800628:	e9 67 01 00 00       	jmp    800794 <vprintfmt+0x3a6>
  80062d:	89 cf                	mov    %ecx,%edi
  80062f:	eb ed                	jmp    80061e <vprintfmt+0x230>
	if (lflag >= 2)
  800631:	83 f9 01             	cmp    $0x1,%ecx
  800634:	7f 1b                	jg     800651 <vprintfmt+0x263>
	else if (lflag)
  800636:	85 c9                	test   %ecx,%ecx
  800638:	74 63                	je     80069d <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800642:	99                   	cltd   
  800643:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
  80064f:	eb 17                	jmp    800668 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 50 04             	mov    0x4(%eax),%edx
  800657:	8b 00                	mov    (%eax),%eax
  800659:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 40 08             	lea    0x8(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800668:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80066b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800673:	85 c9                	test   %ecx,%ecx
  800675:	0f 89 ff 00 00 00    	jns    80077a <vprintfmt+0x38c>
				putch('-', putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 2d                	push   $0x2d
  800681:	ff d6                	call   *%esi
				num = -(long long) num;
  800683:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800686:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800689:	f7 da                	neg    %edx
  80068b:	83 d1 00             	adc    $0x0,%ecx
  80068e:	f7 d9                	neg    %ecx
  800690:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800693:	b8 0a 00 00 00       	mov    $0xa,%eax
  800698:	e9 dd 00 00 00       	jmp    80077a <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a5:	99                   	cltd   
  8006a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 40 04             	lea    0x4(%eax),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b2:	eb b4                	jmp    800668 <vprintfmt+0x27a>
	if (lflag >= 2)
  8006b4:	83 f9 01             	cmp    $0x1,%ecx
  8006b7:	7f 1e                	jg     8006d7 <vprintfmt+0x2e9>
	else if (lflag)
  8006b9:	85 c9                	test   %ecx,%ecx
  8006bb:	74 32                	je     8006ef <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8006d2:	e9 a3 00 00 00       	jmp    80077a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 10                	mov    (%eax),%edx
  8006dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006df:	8d 40 08             	lea    0x8(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e5:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006ea:	e9 8b 00 00 00       	jmp    80077a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ff:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800704:	eb 74                	jmp    80077a <vprintfmt+0x38c>
	if (lflag >= 2)
  800706:	83 f9 01             	cmp    $0x1,%ecx
  800709:	7f 1b                	jg     800726 <vprintfmt+0x338>
	else if (lflag)
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	74 2c                	je     80073b <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	b9 00 00 00 00       	mov    $0x0,%ecx
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80071f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800724:	eb 54                	jmp    80077a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 10                	mov    (%eax),%edx
  80072b:	8b 48 04             	mov    0x4(%eax),%ecx
  80072e:	8d 40 08             	lea    0x8(%eax),%eax
  800731:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800734:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800739:	eb 3f                	jmp    80077a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8b 10                	mov    (%eax),%edx
  800740:	b9 00 00 00 00       	mov    $0x0,%ecx
  800745:	8d 40 04             	lea    0x4(%eax),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80074b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800750:	eb 28                	jmp    80077a <vprintfmt+0x38c>
			putch('0', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	53                   	push   %ebx
  800756:	6a 30                	push   $0x30
  800758:	ff d6                	call   *%esi
			putch('x', putdat);
  80075a:	83 c4 08             	add    $0x8,%esp
  80075d:	53                   	push   %ebx
  80075e:	6a 78                	push   $0x78
  800760:	ff d6                	call   *%esi
			num = (unsigned long long)
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 10                	mov    (%eax),%edx
  800767:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80076c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800775:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80077a:	83 ec 0c             	sub    $0xc,%esp
  80077d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800781:	57                   	push   %edi
  800782:	ff 75 e0             	pushl  -0x20(%ebp)
  800785:	50                   	push   %eax
  800786:	51                   	push   %ecx
  800787:	52                   	push   %edx
  800788:	89 da                	mov    %ebx,%edx
  80078a:	89 f0                	mov    %esi,%eax
  80078c:	e8 72 fb ff ff       	call   800303 <printnum>
			break;
  800791:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800797:	83 c7 01             	add    $0x1,%edi
  80079a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079e:	83 f8 25             	cmp    $0x25,%eax
  8007a1:	0f 84 62 fc ff ff    	je     800409 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	0f 84 8b 00 00 00    	je     80083a <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	50                   	push   %eax
  8007b4:	ff d6                	call   *%esi
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	eb dc                	jmp    800797 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8007bb:	83 f9 01             	cmp    $0x1,%ecx
  8007be:	7f 1b                	jg     8007db <vprintfmt+0x3ed>
	else if (lflag)
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	74 2c                	je     8007f0 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8b 10                	mov    (%eax),%edx
  8007c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d4:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8007d9:	eb 9f                	jmp    80077a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e3:	8d 40 08             	lea    0x8(%eax),%eax
  8007e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007ee:	eb 8a                	jmp    80077a <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fa:	8d 40 04             	lea    0x4(%eax),%eax
  8007fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800800:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800805:	e9 70 ff ff ff       	jmp    80077a <vprintfmt+0x38c>
			putch(ch, putdat);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	53                   	push   %ebx
  80080e:	6a 25                	push   $0x25
  800810:	ff d6                	call   *%esi
			break;
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	e9 7a ff ff ff       	jmp    800794 <vprintfmt+0x3a6>
			putch('%', putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	53                   	push   %ebx
  80081e:	6a 25                	push   $0x25
  800820:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	89 f8                	mov    %edi,%eax
  800827:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80082b:	74 05                	je     800832 <vprintfmt+0x444>
  80082d:	83 e8 01             	sub    $0x1,%eax
  800830:	eb f5                	jmp    800827 <vprintfmt+0x439>
  800832:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800835:	e9 5a ff ff ff       	jmp    800794 <vprintfmt+0x3a6>
}
  80083a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5f                   	pop    %edi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800842:	f3 0f 1e fb          	endbr32 
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 18             	sub    $0x18,%esp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800852:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800855:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800859:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800863:	85 c0                	test   %eax,%eax
  800865:	74 26                	je     80088d <vsnprintf+0x4b>
  800867:	85 d2                	test   %edx,%edx
  800869:	7e 22                	jle    80088d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086b:	ff 75 14             	pushl  0x14(%ebp)
  80086e:	ff 75 10             	pushl  0x10(%ebp)
  800871:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	68 ac 03 80 00       	push   $0x8003ac
  80087a:	e8 6f fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800882:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800888:	83 c4 10             	add    $0x10,%esp
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    
		return -E_INVAL;
  80088d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800892:	eb f7                	jmp    80088b <vsnprintf+0x49>

00800894 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800894:	f3 0f 1e fb          	endbr32 
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80089e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a1:	50                   	push   %eax
  8008a2:	ff 75 10             	pushl  0x10(%ebp)
  8008a5:	ff 75 0c             	pushl  0xc(%ebp)
  8008a8:	ff 75 08             	pushl  0x8(%ebp)
  8008ab:	e8 92 ff ff ff       	call   800842 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b2:	f3 0f 1e fb          	endbr32 
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c5:	74 05                	je     8008cc <strlen+0x1a>
		n++;
  8008c7:	83 c0 01             	add    $0x1,%eax
  8008ca:	eb f5                	jmp    8008c1 <strlen+0xf>
	return n;
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ce:	f3 0f 1e fb          	endbr32 
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	74 0d                	je     8008f1 <strnlen+0x23>
  8008e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e8:	74 05                	je     8008ef <strnlen+0x21>
		n++;
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	eb f1                	jmp    8008e0 <strnlen+0x12>
  8008ef:	89 c2                	mov    %eax,%edx
	return n;
}
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f5:	f3 0f 1e fb          	endbr32 
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800900:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
  800908:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80090c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80090f:	83 c0 01             	add    $0x1,%eax
  800912:	84 d2                	test   %dl,%dl
  800914:	75 f2                	jne    800908 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800916:	89 c8                	mov    %ecx,%eax
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091b:	f3 0f 1e fb          	endbr32 
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	83 ec 10             	sub    $0x10,%esp
  800926:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800929:	53                   	push   %ebx
  80092a:	e8 83 ff ff ff       	call   8008b2 <strlen>
  80092f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800932:	ff 75 0c             	pushl  0xc(%ebp)
  800935:	01 d8                	add    %ebx,%eax
  800937:	50                   	push   %eax
  800938:	e8 b8 ff ff ff       	call   8008f5 <strcpy>
	return dst;
}
  80093d:	89 d8                	mov    %ebx,%eax
  80093f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800944:	f3 0f 1e fb          	endbr32 
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 75 08             	mov    0x8(%ebp),%esi
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
  800953:	89 f3                	mov    %esi,%ebx
  800955:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800958:	89 f0                	mov    %esi,%eax
  80095a:	39 d8                	cmp    %ebx,%eax
  80095c:	74 11                	je     80096f <strncpy+0x2b>
		*dst++ = *src;
  80095e:	83 c0 01             	add    $0x1,%eax
  800961:	0f b6 0a             	movzbl (%edx),%ecx
  800964:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800967:	80 f9 01             	cmp    $0x1,%cl
  80096a:	83 da ff             	sbb    $0xffffffff,%edx
  80096d:	eb eb                	jmp    80095a <strncpy+0x16>
	}
	return ret;
}
  80096f:	89 f0                	mov    %esi,%eax
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800975:	f3 0f 1e fb          	endbr32 
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	56                   	push   %esi
  80097d:	53                   	push   %ebx
  80097e:	8b 75 08             	mov    0x8(%ebp),%esi
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800984:	8b 55 10             	mov    0x10(%ebp),%edx
  800987:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800989:	85 d2                	test   %edx,%edx
  80098b:	74 21                	je     8009ae <strlcpy+0x39>
  80098d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800991:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800993:	39 c2                	cmp    %eax,%edx
  800995:	74 14                	je     8009ab <strlcpy+0x36>
  800997:	0f b6 19             	movzbl (%ecx),%ebx
  80099a:	84 db                	test   %bl,%bl
  80099c:	74 0b                	je     8009a9 <strlcpy+0x34>
			*dst++ = *src++;
  80099e:	83 c1 01             	add    $0x1,%ecx
  8009a1:	83 c2 01             	add    $0x1,%edx
  8009a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a7:	eb ea                	jmp    800993 <strlcpy+0x1e>
  8009a9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ae:	29 f0                	sub    %esi,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b4:	f3 0f 1e fb          	endbr32 
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c1:	0f b6 01             	movzbl (%ecx),%eax
  8009c4:	84 c0                	test   %al,%al
  8009c6:	74 0c                	je     8009d4 <strcmp+0x20>
  8009c8:	3a 02                	cmp    (%edx),%al
  8009ca:	75 08                	jne    8009d4 <strcmp+0x20>
		p++, q++;
  8009cc:	83 c1 01             	add    $0x1,%ecx
  8009cf:	83 c2 01             	add    $0x1,%edx
  8009d2:	eb ed                	jmp    8009c1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d4:	0f b6 c0             	movzbl %al,%eax
  8009d7:	0f b6 12             	movzbl (%edx),%edx
  8009da:	29 d0                	sub    %edx,%eax
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009de:	f3 0f 1e fb          	endbr32 
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f1:	eb 06                	jmp    8009f9 <strncmp+0x1b>
		n--, p++, q++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009f9:	39 d8                	cmp    %ebx,%eax
  8009fb:	74 16                	je     800a13 <strncmp+0x35>
  8009fd:	0f b6 08             	movzbl (%eax),%ecx
  800a00:	84 c9                	test   %cl,%cl
  800a02:	74 04                	je     800a08 <strncmp+0x2a>
  800a04:	3a 0a                	cmp    (%edx),%cl
  800a06:	74 eb                	je     8009f3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 00             	movzbl (%eax),%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    
		return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	eb f6                	jmp    800a10 <strncmp+0x32>

00800a1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1a:	f3 0f 1e fb          	endbr32 
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a28:	0f b6 10             	movzbl (%eax),%edx
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	74 09                	je     800a38 <strchr+0x1e>
		if (*s == c)
  800a2f:	38 ca                	cmp    %cl,%dl
  800a31:	74 0a                	je     800a3d <strchr+0x23>
	for (; *s; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	eb f0                	jmp    800a28 <strchr+0xe>
			return (char *) s;
	return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800a3f:	f3 0f 1e fb          	endbr32 
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800a49:	6a 78                	push   $0x78
  800a4b:	ff 75 08             	pushl  0x8(%ebp)
  800a4e:	e8 c7 ff ff ff       	call   800a1a <strchr>
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800a5e:	eb 0d                	jmp    800a6d <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800a60:	c1 e0 04             	shl    $0x4,%eax
  800a63:	0f be d2             	movsbl %dl,%edx
  800a66:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	0f b6 11             	movzbl (%ecx),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	74 11                	je     800a85 <atox+0x46>
		if (*p>='a'){
  800a74:	80 fa 60             	cmp    $0x60,%dl
  800a77:	7e e7                	jle    800a60 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800a79:	c1 e0 04             	shl    $0x4,%eax
  800a7c:	0f be d2             	movsbl %dl,%edx
  800a7f:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800a83:	eb e5                	jmp    800a6a <atox+0x2b>
	}

	return v;

}
  800a85:	c9                   	leave  
  800a86:	c3                   	ret    

00800a87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a87:	f3 0f 1e fb          	endbr32 
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a98:	38 ca                	cmp    %cl,%dl
  800a9a:	74 09                	je     800aa5 <strfind+0x1e>
  800a9c:	84 d2                	test   %dl,%dl
  800a9e:	74 05                	je     800aa5 <strfind+0x1e>
	for (; *s; s++)
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	eb f0                	jmp    800a95 <strfind+0xe>
			break;
	return (char *) s;
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa7:	f3 0f 1e fb          	endbr32 
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab7:	85 c9                	test   %ecx,%ecx
  800ab9:	74 31                	je     800aec <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abb:	89 f8                	mov    %edi,%eax
  800abd:	09 c8                	or     %ecx,%eax
  800abf:	a8 03                	test   $0x3,%al
  800ac1:	75 23                	jne    800ae6 <memset+0x3f>
		c &= 0xFF;
  800ac3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac7:	89 d3                	mov    %edx,%ebx
  800ac9:	c1 e3 08             	shl    $0x8,%ebx
  800acc:	89 d0                	mov    %edx,%eax
  800ace:	c1 e0 18             	shl    $0x18,%eax
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	c1 e6 10             	shl    $0x10,%esi
  800ad6:	09 f0                	or     %esi,%eax
  800ad8:	09 c2                	or     %eax,%edx
  800ada:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800adc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800adf:	89 d0                	mov    %edx,%eax
  800ae1:	fc                   	cld    
  800ae2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae4:	eb 06                	jmp    800aec <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	fc                   	cld    
  800aea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aec:	89 f8                	mov    %edi,%eax
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af3:	f3 0f 1e fb          	endbr32 
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b05:	39 c6                	cmp    %eax,%esi
  800b07:	73 32                	jae    800b3b <memmove+0x48>
  800b09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0c:	39 c2                	cmp    %eax,%edx
  800b0e:	76 2b                	jbe    800b3b <memmove+0x48>
		s += n;
		d += n;
  800b10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b13:	89 fe                	mov    %edi,%esi
  800b15:	09 ce                	or     %ecx,%esi
  800b17:	09 d6                	or     %edx,%esi
  800b19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1f:	75 0e                	jne    800b2f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b21:	83 ef 04             	sub    $0x4,%edi
  800b24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b2a:	fd                   	std    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb 09                	jmp    800b38 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2f:	83 ef 01             	sub    $0x1,%edi
  800b32:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b35:	fd                   	std    
  800b36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b38:	fc                   	cld    
  800b39:	eb 1a                	jmp    800b55 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	09 ca                	or     %ecx,%edx
  800b3f:	09 f2                	or     %esi,%edx
  800b41:	f6 c2 03             	test   $0x3,%dl
  800b44:	75 0a                	jne    800b50 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b46:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	fc                   	cld    
  800b4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4e:	eb 05                	jmp    800b55 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b50:	89 c7                	mov    %eax,%edi
  800b52:	fc                   	cld    
  800b53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b59:	f3 0f 1e fb          	endbr32 
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b63:	ff 75 10             	pushl  0x10(%ebp)
  800b66:	ff 75 0c             	pushl  0xc(%ebp)
  800b69:	ff 75 08             	pushl  0x8(%ebp)
  800b6c:	e8 82 ff ff ff       	call   800af3 <memmove>
}
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b73:	f3 0f 1e fb          	endbr32 
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b82:	89 c6                	mov    %eax,%esi
  800b84:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b87:	39 f0                	cmp    %esi,%eax
  800b89:	74 1c                	je     800ba7 <memcmp+0x34>
		if (*s1 != *s2)
  800b8b:	0f b6 08             	movzbl (%eax),%ecx
  800b8e:	0f b6 1a             	movzbl (%edx),%ebx
  800b91:	38 d9                	cmp    %bl,%cl
  800b93:	75 08                	jne    800b9d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b95:	83 c0 01             	add    $0x1,%eax
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	eb ea                	jmp    800b87 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b9d:	0f b6 c1             	movzbl %cl,%eax
  800ba0:	0f b6 db             	movzbl %bl,%ebx
  800ba3:	29 d8                	sub    %ebx,%eax
  800ba5:	eb 05                	jmp    800bac <memcmp+0x39>
	}

	return 0;
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb0:	f3 0f 1e fb          	endbr32 
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc2:	39 d0                	cmp    %edx,%eax
  800bc4:	73 09                	jae    800bcf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc6:	38 08                	cmp    %cl,(%eax)
  800bc8:	74 05                	je     800bcf <memfind+0x1f>
	for (; s < ends; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	eb f3                	jmp    800bc2 <memfind+0x12>
			break;
	return (void *) s;
}
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd1:	f3 0f 1e fb          	endbr32 
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be1:	eb 03                	jmp    800be6 <strtol+0x15>
		s++;
  800be3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800be6:	0f b6 01             	movzbl (%ecx),%eax
  800be9:	3c 20                	cmp    $0x20,%al
  800beb:	74 f6                	je     800be3 <strtol+0x12>
  800bed:	3c 09                	cmp    $0x9,%al
  800bef:	74 f2                	je     800be3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800bf1:	3c 2b                	cmp    $0x2b,%al
  800bf3:	74 2a                	je     800c1f <strtol+0x4e>
	int neg = 0;
  800bf5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bfa:	3c 2d                	cmp    $0x2d,%al
  800bfc:	74 2b                	je     800c29 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c04:	75 0f                	jne    800c15 <strtol+0x44>
  800c06:	80 39 30             	cmpb   $0x30,(%ecx)
  800c09:	74 28                	je     800c33 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c0b:	85 db                	test   %ebx,%ebx
  800c0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c12:	0f 44 d8             	cmove  %eax,%ebx
  800c15:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c1d:	eb 46                	jmp    800c65 <strtol+0x94>
		s++;
  800c1f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c22:	bf 00 00 00 00       	mov    $0x0,%edi
  800c27:	eb d5                	jmp    800bfe <strtol+0x2d>
		s++, neg = 1;
  800c29:	83 c1 01             	add    $0x1,%ecx
  800c2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800c31:	eb cb                	jmp    800bfe <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c37:	74 0e                	je     800c47 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c39:	85 db                	test   %ebx,%ebx
  800c3b:	75 d8                	jne    800c15 <strtol+0x44>
		s++, base = 8;
  800c3d:	83 c1 01             	add    $0x1,%ecx
  800c40:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c45:	eb ce                	jmp    800c15 <strtol+0x44>
		s += 2, base = 16;
  800c47:	83 c1 02             	add    $0x2,%ecx
  800c4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4f:	eb c4                	jmp    800c15 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c51:	0f be d2             	movsbl %dl,%edx
  800c54:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c57:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c5a:	7d 3a                	jge    800c96 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c5c:	83 c1 01             	add    $0x1,%ecx
  800c5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c63:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c65:	0f b6 11             	movzbl (%ecx),%edx
  800c68:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c6b:	89 f3                	mov    %esi,%ebx
  800c6d:	80 fb 09             	cmp    $0x9,%bl
  800c70:	76 df                	jbe    800c51 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c72:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c75:	89 f3                	mov    %esi,%ebx
  800c77:	80 fb 19             	cmp    $0x19,%bl
  800c7a:	77 08                	ja     800c84 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c7c:	0f be d2             	movsbl %dl,%edx
  800c7f:	83 ea 57             	sub    $0x57,%edx
  800c82:	eb d3                	jmp    800c57 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c84:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c87:	89 f3                	mov    %esi,%ebx
  800c89:	80 fb 19             	cmp    $0x19,%bl
  800c8c:	77 08                	ja     800c96 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c8e:	0f be d2             	movsbl %dl,%edx
  800c91:	83 ea 37             	sub    $0x37,%edx
  800c94:	eb c1                	jmp    800c57 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9a:	74 05                	je     800ca1 <strtol+0xd0>
		*endptr = (char *) s;
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ca1:	89 c2                	mov    %eax,%edx
  800ca3:	f7 da                	neg    %edx
  800ca5:	85 ff                	test   %edi,%edi
  800ca7:	0f 45 c2             	cmovne %edx,%eax
}
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800caf:	f3 0f 1e fb          	endbr32 
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	89 c3                	mov    %eax,%ebx
  800cc6:	89 c7                	mov    %eax,%edi
  800cc8:	89 c6                	mov    %eax,%esi
  800cca:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd1:	f3 0f 1e fb          	endbr32 
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf4:	f3 0f 1e fb          	endbr32 
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0b:	89 cb                	mov    %ecx,%ebx
  800d0d:	89 cf                	mov    %ecx,%edi
  800d0f:	89 ce                	mov    %ecx,%esi
  800d11:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d18:	f3 0f 1e fb          	endbr32 
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	b8 02 00 00 00       	mov    $0x2,%eax
  800d2c:	89 d1                	mov    %edx,%ecx
  800d2e:	89 d3                	mov    %edx,%ebx
  800d30:	89 d7                	mov    %edx,%edi
  800d32:	89 d6                	mov    %edx,%esi
  800d34:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_yield>:

void
sys_yield(void)
{
  800d3b:	f3 0f 1e fb          	endbr32 
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d45:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4f:	89 d1                	mov    %edx,%ecx
  800d51:	89 d3                	mov    %edx,%ebx
  800d53:	89 d7                	mov    %edx,%edi
  800d55:	89 d6                	mov    %edx,%esi
  800d57:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d5e:	f3 0f 1e fb          	endbr32 
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d68:	be 00 00 00 00       	mov    $0x0,%esi
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d73:	b8 04 00 00 00       	mov    $0x4,%eax
  800d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7b:	89 f7                	mov    %esi,%edi
  800d7d:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d84:	f3 0f 1e fb          	endbr32 
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	b8 05 00 00 00       	mov    $0x5,%eax
  800d99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9f:	8b 75 18             	mov    0x18(%ebp),%esi
  800da2:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da9:	f3 0f 1e fb          	endbr32 
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dce:	f3 0f 1e fb          	endbr32 
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	b8 08 00 00 00       	mov    $0x8,%eax
  800de8:	89 df                	mov    %ebx,%edi
  800dea:	89 de                	mov    %ebx,%esi
  800dec:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df3:	f3 0f 1e fb          	endbr32 
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0d:	89 df                	mov    %ebx,%edi
  800e0f:	89 de                	mov    %ebx,%esi
  800e11:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e18:	f3 0f 1e fb          	endbr32 
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e32:	89 df                	mov    %ebx,%edi
  800e34:	89 de                	mov    %ebx,%esi
  800e36:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3d:	f3 0f 1e fb          	endbr32 
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e47:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e52:	be 00 00 00 00       	mov    $0x0,%esi
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e64:	f3 0f 1e fb          	endbr32 
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7b:	89 cb                	mov    %ecx,%ebx
  800e7d:	89 cf                	mov    %ecx,%edi
  800e7f:	89 ce                	mov    %ecx,%esi
  800e81:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e88:	f3 0f 1e fb          	endbr32 
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e92:	ba 00 00 00 00       	mov    $0x0,%edx
  800e97:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9c:	89 d1                	mov    %edx,%ecx
  800e9e:	89 d3                	mov    %edx,%ebx
  800ea0:	89 d7                	mov    %edx,%edi
  800ea2:	89 d6                	mov    %edx,%esi
  800ea4:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800eab:	f3 0f 1e fb          	endbr32 
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ec5:	89 df                	mov    %ebx,%edi
  800ec7:	89 de                	mov    %ebx,%esi
  800ec9:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800ed0:	f3 0f 1e fb          	endbr32 
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	b8 10 00 00 00       	mov    $0x10,%eax
  800eea:	89 df                	mov    %ebx,%edi
  800eec:	89 de                	mov    %ebx,%esi
  800eee:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800ef5:	f3 0f 1e fb          	endbr32 
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	53                   	push   %ebx
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800f03:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800f05:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f09:	0f 84 9a 00 00 00    	je     800fa9 <pgfault+0xb4>
  800f0f:	89 d8                	mov    %ebx,%eax
  800f11:	c1 e8 16             	shr    $0x16,%eax
  800f14:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f1b:	a8 01                	test   $0x1,%al
  800f1d:	0f 84 86 00 00 00    	je     800fa9 <pgfault+0xb4>
  800f23:	89 d8                	mov    %ebx,%eax
  800f25:	c1 e8 0c             	shr    $0xc,%eax
  800f28:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	74 75                	je     800fa9 <pgfault+0xb4>
  800f34:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3b:	f6 c4 08             	test   $0x8,%ah
  800f3e:	74 69                	je     800fa9 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	6a 07                	push   $0x7
  800f45:	68 00 f0 7f 00       	push   $0x7ff000
  800f4a:	6a 00                	push   $0x0
  800f4c:	e8 0d fe ff ff       	call   800d5e <sys_page_alloc>
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 63                	js     800fbb <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f58:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800f5e:	83 ec 04             	sub    $0x4,%esp
  800f61:	68 00 10 00 00       	push   $0x1000
  800f66:	53                   	push   %ebx
  800f67:	68 00 f0 7f 00       	push   $0x7ff000
  800f6c:	e8 e8 fb ff ff       	call   800b59 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800f71:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f78:	53                   	push   %ebx
  800f79:	6a 00                	push   $0x0
  800f7b:	68 00 f0 7f 00       	push   $0x7ff000
  800f80:	6a 00                	push   $0x0
  800f82:	e8 fd fd ff ff       	call   800d84 <sys_page_map>
  800f87:	83 c4 20             	add    $0x20,%esp
  800f8a:	85 c0                	test   %eax,%eax
  800f8c:	78 3f                	js     800fcd <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800f8e:	83 ec 08             	sub    $0x8,%esp
  800f91:	68 00 f0 7f 00       	push   $0x7ff000
  800f96:	6a 00                	push   $0x0
  800f98:	e8 0c fe ff ff       	call   800da9 <sys_page_unmap>
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 3b                	js     800fdf <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800fa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800fa9:	53                   	push   %ebx
  800faa:	68 40 32 80 00       	push   $0x803240
  800faf:	6a 20                	push   $0x20
  800fb1:	68 fe 32 80 00       	push   $0x8032fe
  800fb6:	e8 49 f2 ff ff       	call   800204 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800fbb:	50                   	push   %eax
  800fbc:	68 80 32 80 00       	push   $0x803280
  800fc1:	6a 2c                	push   $0x2c
  800fc3:	68 fe 32 80 00       	push   $0x8032fe
  800fc8:	e8 37 f2 ff ff       	call   800204 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800fcd:	50                   	push   %eax
  800fce:	68 ac 32 80 00       	push   $0x8032ac
  800fd3:	6a 33                	push   $0x33
  800fd5:	68 fe 32 80 00       	push   $0x8032fe
  800fda:	e8 25 f2 ff ff       	call   800204 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800fdf:	50                   	push   %eax
  800fe0:	68 d4 32 80 00       	push   $0x8032d4
  800fe5:	6a 36                	push   $0x36
  800fe7:	68 fe 32 80 00       	push   $0x8032fe
  800fec:	e8 13 f2 ff ff       	call   800204 <_panic>

00800ff1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ff1:	f3 0f 1e fb          	endbr32 
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800ffe:	68 f5 0e 80 00       	push   $0x800ef5
  801003:	e8 00 1a 00 00       	call   802a08 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801008:	b8 07 00 00 00       	mov    $0x7,%eax
  80100d:	cd 30                	int    $0x30
  80100f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 29                	js     801042 <fork+0x51>
  801019:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  80101b:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  801020:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801024:	75 60                	jne    801086 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  801026:	e8 ed fc ff ff       	call   800d18 <sys_getenvid>
  80102b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801030:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801033:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801038:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80103d:	e9 14 01 00 00       	jmp    801156 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  801042:	50                   	push   %eax
  801043:	68 09 33 80 00       	push   $0x803309
  801048:	68 90 00 00 00       	push   $0x90
  80104d:	68 fe 32 80 00       	push   $0x8032fe
  801052:	e8 ad f1 ff ff       	call   800204 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  801057:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	25 07 0e 00 00       	and    $0xe07,%eax
  801066:	50                   	push   %eax
  801067:	56                   	push   %esi
  801068:	57                   	push   %edi
  801069:	56                   	push   %esi
  80106a:	6a 00                	push   $0x0
  80106c:	e8 13 fd ff ff       	call   800d84 <sys_page_map>
  801071:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801074:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80107a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801080:	0f 84 95 00 00 00    	je     80111b <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801086:	89 d8                	mov    %ebx,%eax
  801088:	c1 e8 16             	shr    $0x16,%eax
  80108b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801092:	a8 01                	test   $0x1,%al
  801094:	74 de                	je     801074 <fork+0x83>
  801096:	89 d8                	mov    %ebx,%eax
  801098:	c1 e8 0c             	shr    $0xc,%eax
  80109b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a2:	f6 c2 01             	test   $0x1,%dl
  8010a5:	74 cd                	je     801074 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  8010a7:	89 c6                	mov    %eax,%esi
  8010a9:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  8010ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b3:	f6 c6 04             	test   $0x4,%dh
  8010b6:	75 9f                	jne    801057 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  8010b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bf:	f6 c2 02             	test   $0x2,%dl
  8010c2:	75 0c                	jne    8010d0 <fork+0xdf>
  8010c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cb:	f6 c4 08             	test   $0x8,%ah
  8010ce:	74 34                	je     801104 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	68 05 08 00 00       	push   $0x805
  8010d8:	56                   	push   %esi
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	6a 00                	push   $0x0
  8010dd:	e8 a2 fc ff ff       	call   800d84 <sys_page_map>
			if (r<0) return r;
  8010e2:	83 c4 20             	add    $0x20,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 8b                	js     801074 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	68 05 08 00 00       	push   $0x805
  8010f1:	56                   	push   %esi
  8010f2:	6a 00                	push   $0x0
  8010f4:	56                   	push   %esi
  8010f5:	6a 00                	push   $0x0
  8010f7:	e8 88 fc ff ff       	call   800d84 <sys_page_map>
  8010fc:	83 c4 20             	add    $0x20,%esp
  8010ff:	e9 70 ff ff ff       	jmp    801074 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	6a 05                	push   $0x5
  801109:	56                   	push   %esi
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	6a 00                	push   $0x0
  80110e:	e8 71 fc ff ff       	call   800d84 <sys_page_map>
  801113:	83 c4 20             	add    $0x20,%esp
  801116:	e9 59 ff ff ff       	jmp    801074 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  80111b:	83 ec 04             	sub    $0x4,%esp
  80111e:	6a 07                	push   $0x7
  801120:	68 00 f0 bf ee       	push   $0xeebff000
  801125:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801128:	56                   	push   %esi
  801129:	e8 30 fc ff ff       	call   800d5e <sys_page_alloc>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 2b                	js     801160 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	68 7b 2a 80 00       	push   $0x802a7b
  80113d:	56                   	push   %esi
  80113e:	e8 d5 fc ff ff       	call   800e18 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	6a 02                	push   $0x2
  801148:	56                   	push   %esi
  801149:	e8 80 fc ff ff       	call   800dce <sys_env_set_status>
  80114e:	83 c4 10             	add    $0x10,%esp
		return r;
  801151:	85 c0                	test   %eax,%eax
  801153:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801156:	89 f8                	mov    %edi,%eax
  801158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    
		return r;
  801160:	89 c7                	mov    %eax,%edi
  801162:	eb f2                	jmp    801156 <fork+0x165>

00801164 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801164:	f3 0f 1e fb          	endbr32 
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80116e:	68 25 33 80 00       	push   $0x803325
  801173:	68 b2 00 00 00       	push   $0xb2
  801178:	68 fe 32 80 00       	push   $0x8032fe
  80117d:	e8 82 f0 ff ff       	call   800204 <_panic>

00801182 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801182:	f3 0f 1e fb          	endbr32 
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801189:	8b 45 08             	mov    0x8(%ebp),%eax
  80118c:	05 00 00 00 30       	add    $0x30000000,%eax
  801191:	c1 e8 0c             	shr    $0xc,%eax
}
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801196:	f3 0f 1e fb          	endbr32 
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011aa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b1:	f3 0f 1e fb          	endbr32 
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	c1 ea 16             	shr    $0x16,%edx
  8011c2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c9:	f6 c2 01             	test   $0x1,%dl
  8011cc:	74 2d                	je     8011fb <fd_alloc+0x4a>
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	c1 ea 0c             	shr    $0xc,%edx
  8011d3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011da:	f6 c2 01             	test   $0x1,%dl
  8011dd:	74 1c                	je     8011fb <fd_alloc+0x4a>
  8011df:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011e4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e9:	75 d2                	jne    8011bd <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8011f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8011f9:	eb 0a                	jmp    801205 <fd_alloc+0x54>
			*fd_store = fd;
  8011fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801200:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801207:	f3 0f 1e fb          	endbr32 
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801211:	83 f8 1f             	cmp    $0x1f,%eax
  801214:	77 30                	ja     801246 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801216:	c1 e0 0c             	shl    $0xc,%eax
  801219:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	74 24                	je     80124d <fd_lookup+0x46>
  801229:	89 c2                	mov    %eax,%edx
  80122b:	c1 ea 0c             	shr    $0xc,%edx
  80122e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801235:	f6 c2 01             	test   $0x1,%dl
  801238:	74 1a                	je     801254 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123d:	89 02                	mov    %eax,(%edx)
	return 0;
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    
		return -E_INVAL;
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124b:	eb f7                	jmp    801244 <fd_lookup+0x3d>
		return -E_INVAL;
  80124d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801252:	eb f0                	jmp    801244 <fd_lookup+0x3d>
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801259:	eb e9                	jmp    801244 <fd_lookup+0x3d>

0080125b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125b:	f3 0f 1e fb          	endbr32 
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801268:	ba 00 00 00 00       	mov    $0x0,%edx
  80126d:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801272:	39 08                	cmp    %ecx,(%eax)
  801274:	74 38                	je     8012ae <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801276:	83 c2 01             	add    $0x1,%edx
  801279:	8b 04 95 b8 33 80 00 	mov    0x8033b8(,%edx,4),%eax
  801280:	85 c0                	test   %eax,%eax
  801282:	75 ee                	jne    801272 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801284:	a1 08 50 80 00       	mov    0x805008,%eax
  801289:	8b 40 48             	mov    0x48(%eax),%eax
  80128c:	83 ec 04             	sub    $0x4,%esp
  80128f:	51                   	push   %ecx
  801290:	50                   	push   %eax
  801291:	68 3c 33 80 00       	push   $0x80333c
  801296:	e8 50 f0 ff ff       	call   8002eb <cprintf>
	*dev = 0;
  80129b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ac:	c9                   	leave  
  8012ad:	c3                   	ret    
			*dev = devtab[i];
  8012ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b8:	eb f2                	jmp    8012ac <dev_lookup+0x51>

008012ba <fd_close>:
{
  8012ba:	f3 0f 1e fb          	endbr32 
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 24             	sub    $0x24,%esp
  8012c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d0:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012d7:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012da:	50                   	push   %eax
  8012db:	e8 27 ff ff ff       	call   801207 <fd_lookup>
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 05                	js     8012ee <fd_close+0x34>
	    || fd != fd2)
  8012e9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012ec:	74 16                	je     801304 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8012ee:	89 f8                	mov    %edi,%eax
  8012f0:	84 c0                	test   %al,%al
  8012f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f7:	0f 44 d8             	cmove  %eax,%ebx
}
  8012fa:	89 d8                	mov    %ebx,%eax
  8012fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	ff 36                	pushl  (%esi)
  80130d:	e8 49 ff ff ff       	call   80125b <dev_lookup>
  801312:	89 c3                	mov    %eax,%ebx
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 1a                	js     801335 <fd_close+0x7b>
		if (dev->dev_close)
  80131b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80131e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801321:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801326:	85 c0                	test   %eax,%eax
  801328:	74 0b                	je     801335 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	56                   	push   %esi
  80132e:	ff d0                	call   *%eax
  801330:	89 c3                	mov    %eax,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	56                   	push   %esi
  801339:	6a 00                	push   $0x0
  80133b:	e8 69 fa ff ff       	call   800da9 <sys_page_unmap>
	return r;
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	eb b5                	jmp    8012fa <fd_close+0x40>

00801345 <close>:

int
close(int fdnum)
{
  801345:	f3 0f 1e fb          	endbr32 
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 ac fe ff ff       	call   801207 <fd_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	79 02                	jns    801364 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801362:	c9                   	leave  
  801363:	c3                   	ret    
		return fd_close(fd, 1);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	6a 01                	push   $0x1
  801369:	ff 75 f4             	pushl  -0xc(%ebp)
  80136c:	e8 49 ff ff ff       	call   8012ba <fd_close>
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	eb ec                	jmp    801362 <close+0x1d>

00801376 <close_all>:

void
close_all(void)
{
  801376:	f3 0f 1e fb          	endbr32 
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	53                   	push   %ebx
  80137e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801381:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	53                   	push   %ebx
  80138a:	e8 b6 ff ff ff       	call   801345 <close>
	for (i = 0; i < MAXFD; i++)
  80138f:	83 c3 01             	add    $0x1,%ebx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	83 fb 20             	cmp    $0x20,%ebx
  801398:	75 ec                	jne    801386 <close_all+0x10>
}
  80139a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139f:	f3 0f 1e fb          	endbr32 
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	57                   	push   %edi
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 75 08             	pushl  0x8(%ebp)
  8013b3:	e8 4f fe ff ff       	call   801207 <fd_lookup>
  8013b8:	89 c3                	mov    %eax,%ebx
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	0f 88 81 00 00 00    	js     801446 <dup+0xa7>
		return r;
	close(newfdnum);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	ff 75 0c             	pushl  0xc(%ebp)
  8013cb:	e8 75 ff ff ff       	call   801345 <close>

	newfd = INDEX2FD(newfdnum);
  8013d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d3:	c1 e6 0c             	shl    $0xc,%esi
  8013d6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013dc:	83 c4 04             	add    $0x4,%esp
  8013df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e2:	e8 af fd ff ff       	call   801196 <fd2data>
  8013e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e9:	89 34 24             	mov    %esi,(%esp)
  8013ec:	e8 a5 fd ff ff       	call   801196 <fd2data>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f6:	89 d8                	mov    %ebx,%eax
  8013f8:	c1 e8 16             	shr    $0x16,%eax
  8013fb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801402:	a8 01                	test   $0x1,%al
  801404:	74 11                	je     801417 <dup+0x78>
  801406:	89 d8                	mov    %ebx,%eax
  801408:	c1 e8 0c             	shr    $0xc,%eax
  80140b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801412:	f6 c2 01             	test   $0x1,%dl
  801415:	75 39                	jne    801450 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801417:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	c1 e8 0c             	shr    $0xc,%eax
  80141f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	25 07 0e 00 00       	and    $0xe07,%eax
  80142e:	50                   	push   %eax
  80142f:	56                   	push   %esi
  801430:	6a 00                	push   $0x0
  801432:	52                   	push   %edx
  801433:	6a 00                	push   $0x0
  801435:	e8 4a f9 ff ff       	call   800d84 <sys_page_map>
  80143a:	89 c3                	mov    %eax,%ebx
  80143c:	83 c4 20             	add    $0x20,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 31                	js     801474 <dup+0xd5>
		goto err;

	return newfdnum;
  801443:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801446:	89 d8                	mov    %ebx,%eax
  801448:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5f                   	pop    %edi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801450:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801457:	83 ec 0c             	sub    $0xc,%esp
  80145a:	25 07 0e 00 00       	and    $0xe07,%eax
  80145f:	50                   	push   %eax
  801460:	57                   	push   %edi
  801461:	6a 00                	push   $0x0
  801463:	53                   	push   %ebx
  801464:	6a 00                	push   $0x0
  801466:	e8 19 f9 ff ff       	call   800d84 <sys_page_map>
  80146b:	89 c3                	mov    %eax,%ebx
  80146d:	83 c4 20             	add    $0x20,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	79 a3                	jns    801417 <dup+0x78>
	sys_page_unmap(0, newfd);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	56                   	push   %esi
  801478:	6a 00                	push   $0x0
  80147a:	e8 2a f9 ff ff       	call   800da9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147f:	83 c4 08             	add    $0x8,%esp
  801482:	57                   	push   %edi
  801483:	6a 00                	push   $0x0
  801485:	e8 1f f9 ff ff       	call   800da9 <sys_page_unmap>
	return r;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	eb b7                	jmp    801446 <dup+0xa7>

0080148f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148f:	f3 0f 1e fb          	endbr32 
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	53                   	push   %ebx
  801497:	83 ec 1c             	sub    $0x1c,%esp
  80149a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	53                   	push   %ebx
  8014a2:	e8 60 fd ff ff       	call   801207 <fd_lookup>
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 3f                	js     8014ed <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b8:	ff 30                	pushl  (%eax)
  8014ba:	e8 9c fd ff ff       	call   80125b <dev_lookup>
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 27                	js     8014ed <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c9:	8b 42 08             	mov    0x8(%edx),%eax
  8014cc:	83 e0 03             	and    $0x3,%eax
  8014cf:	83 f8 01             	cmp    $0x1,%eax
  8014d2:	74 1e                	je     8014f2 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d7:	8b 40 08             	mov    0x8(%eax),%eax
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	74 35                	je     801513 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014de:	83 ec 04             	sub    $0x4,%esp
  8014e1:	ff 75 10             	pushl  0x10(%ebp)
  8014e4:	ff 75 0c             	pushl  0xc(%ebp)
  8014e7:	52                   	push   %edx
  8014e8:	ff d0                	call   *%eax
  8014ea:	83 c4 10             	add    $0x10,%esp
}
  8014ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f2:	a1 08 50 80 00       	mov    0x805008,%eax
  8014f7:	8b 40 48             	mov    0x48(%eax),%eax
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	50                   	push   %eax
  8014ff:	68 7d 33 80 00       	push   $0x80337d
  801504:	e8 e2 ed ff ff       	call   8002eb <cprintf>
		return -E_INVAL;
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801511:	eb da                	jmp    8014ed <read+0x5e>
		return -E_NOT_SUPP;
  801513:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801518:	eb d3                	jmp    8014ed <read+0x5e>

0080151a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151a:	f3 0f 1e fb          	endbr32 
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	57                   	push   %edi
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	8b 7d 08             	mov    0x8(%ebp),%edi
  80152a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801532:	eb 02                	jmp    801536 <readn+0x1c>
  801534:	01 c3                	add    %eax,%ebx
  801536:	39 f3                	cmp    %esi,%ebx
  801538:	73 21                	jae    80155b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	89 f0                	mov    %esi,%eax
  80153f:	29 d8                	sub    %ebx,%eax
  801541:	50                   	push   %eax
  801542:	89 d8                	mov    %ebx,%eax
  801544:	03 45 0c             	add    0xc(%ebp),%eax
  801547:	50                   	push   %eax
  801548:	57                   	push   %edi
  801549:	e8 41 ff ff ff       	call   80148f <read>
		if (m < 0)
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	85 c0                	test   %eax,%eax
  801553:	78 04                	js     801559 <readn+0x3f>
			return m;
		if (m == 0)
  801555:	75 dd                	jne    801534 <readn+0x1a>
  801557:	eb 02                	jmp    80155b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801559:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80155b:	89 d8                	mov    %ebx,%eax
  80155d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801560:	5b                   	pop    %ebx
  801561:	5e                   	pop    %esi
  801562:	5f                   	pop    %edi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801565:	f3 0f 1e fb          	endbr32 
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	53                   	push   %ebx
  80156d:	83 ec 1c             	sub    $0x1c,%esp
  801570:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801573:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	53                   	push   %ebx
  801578:	e8 8a fc ff ff       	call   801207 <fd_lookup>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 3a                	js     8015be <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158e:	ff 30                	pushl  (%eax)
  801590:	e8 c6 fc ff ff       	call   80125b <dev_lookup>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 22                	js     8015be <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a3:	74 1e                	je     8015c3 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ab:	85 d2                	test   %edx,%edx
  8015ad:	74 35                	je     8015e4 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	ff 75 10             	pushl  0x10(%ebp)
  8015b5:	ff 75 0c             	pushl  0xc(%ebp)
  8015b8:	50                   	push   %eax
  8015b9:	ff d2                	call   *%edx
  8015bb:	83 c4 10             	add    $0x10,%esp
}
  8015be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c3:	a1 08 50 80 00       	mov    0x805008,%eax
  8015c8:	8b 40 48             	mov    0x48(%eax),%eax
  8015cb:	83 ec 04             	sub    $0x4,%esp
  8015ce:	53                   	push   %ebx
  8015cf:	50                   	push   %eax
  8015d0:	68 99 33 80 00       	push   $0x803399
  8015d5:	e8 11 ed ff ff       	call   8002eb <cprintf>
		return -E_INVAL;
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e2:	eb da                	jmp    8015be <write+0x59>
		return -E_NOT_SUPP;
  8015e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e9:	eb d3                	jmp    8015be <write+0x59>

008015eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8015eb:	f3 0f 1e fb          	endbr32 
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	ff 75 08             	pushl  0x8(%ebp)
  8015fc:	e8 06 fc ff ff       	call   801207 <fd_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 0e                	js     801616 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801608:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801611:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801618:	f3 0f 1e fb          	endbr32 
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	53                   	push   %ebx
  801620:	83 ec 1c             	sub    $0x1c,%esp
  801623:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801626:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801629:	50                   	push   %eax
  80162a:	53                   	push   %ebx
  80162b:	e8 d7 fb ff ff       	call   801207 <fd_lookup>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 37                	js     80166e <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801641:	ff 30                	pushl  (%eax)
  801643:	e8 13 fc ff ff       	call   80125b <dev_lookup>
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 1f                	js     80166e <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801656:	74 1b                	je     801673 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801658:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165b:	8b 52 18             	mov    0x18(%edx),%edx
  80165e:	85 d2                	test   %edx,%edx
  801660:	74 32                	je     801694 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	50                   	push   %eax
  801669:	ff d2                	call   *%edx
  80166b:	83 c4 10             	add    $0x10,%esp
}
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    
			thisenv->env_id, fdnum);
  801673:	a1 08 50 80 00       	mov    0x805008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801678:	8b 40 48             	mov    0x48(%eax),%eax
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	53                   	push   %ebx
  80167f:	50                   	push   %eax
  801680:	68 5c 33 80 00       	push   $0x80335c
  801685:	e8 61 ec ff ff       	call   8002eb <cprintf>
		return -E_INVAL;
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801692:	eb da                	jmp    80166e <ftruncate+0x56>
		return -E_NOT_SUPP;
  801694:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801699:	eb d3                	jmp    80166e <ftruncate+0x56>

0080169b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80169b:	f3 0f 1e fb          	endbr32 
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 1c             	sub    $0x1c,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 52 fb ff ff       	call   801207 <fd_lookup>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 4b                	js     801707 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	ff 30                	pushl  (%eax)
  8016c8:	e8 8e fb ff ff       	call   80125b <dev_lookup>
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	78 33                	js     801707 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8016d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016db:	74 2f                	je     80170c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e7:	00 00 00 
	stat->st_isdir = 0;
  8016ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f1:	00 00 00 
	stat->st_dev = dev;
  8016f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	53                   	push   %ebx
  8016fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801701:	ff 50 14             	call   *0x14(%eax)
  801704:	83 c4 10             	add    $0x10,%esp
}
  801707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    
		return -E_NOT_SUPP;
  80170c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801711:	eb f4                	jmp    801707 <fstat+0x6c>

00801713 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801713:	f3 0f 1e fb          	endbr32 
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80171c:	83 ec 08             	sub    $0x8,%esp
  80171f:	6a 00                	push   $0x0
  801721:	ff 75 08             	pushl  0x8(%ebp)
  801724:	e8 01 02 00 00       	call   80192a <open>
  801729:	89 c3                	mov    %eax,%ebx
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 1b                	js     80174d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	ff 75 0c             	pushl  0xc(%ebp)
  801738:	50                   	push   %eax
  801739:	e8 5d ff ff ff       	call   80169b <fstat>
  80173e:	89 c6                	mov    %eax,%esi
	close(fd);
  801740:	89 1c 24             	mov    %ebx,(%esp)
  801743:	e8 fd fb ff ff       	call   801345 <close>
	return r;
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	89 f3                	mov    %esi,%ebx
}
  80174d:	89 d8                	mov    %ebx,%eax
  80174f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801752:	5b                   	pop    %ebx
  801753:	5e                   	pop    %esi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	89 c6                	mov    %eax,%esi
  80175d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80175f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801766:	74 27                	je     80178f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801768:	6a 07                	push   $0x7
  80176a:	68 00 60 80 00       	push   $0x806000
  80176f:	56                   	push   %esi
  801770:	ff 35 00 50 80 00    	pushl  0x805000
  801776:	e8 91 13 00 00       	call   802b0c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177b:	83 c4 0c             	add    $0xc,%esp
  80177e:	6a 00                	push   $0x0
  801780:	53                   	push   %ebx
  801781:	6a 00                	push   $0x0
  801783:	e8 17 13 00 00       	call   802a9f <ipc_recv>
}
  801788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80178f:	83 ec 0c             	sub    $0xc,%esp
  801792:	6a 01                	push   $0x1
  801794:	e8 cb 13 00 00       	call   802b64 <ipc_find_env>
  801799:	a3 00 50 80 00       	mov    %eax,0x805000
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	eb c5                	jmp    801768 <fsipc+0x12>

008017a3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a3:	f3 0f 1e fb          	endbr32 
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b3:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8017b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bb:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ca:	e8 87 ff ff ff       	call   801756 <fsipc>
}
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <devfile_flush>:
{
  8017d1:	f3 0f 1e fb          	endbr32 
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e1:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f0:	e8 61 ff ff ff       	call   801756 <fsipc>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_stat>:
{
  8017f7:	f3 0f 1e fb          	endbr32 
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 05 00 00 00       	mov    $0x5,%eax
  80181a:	e8 37 ff ff ff       	call   801756 <fsipc>
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 2c                	js     80184f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	68 00 60 80 00       	push   $0x806000
  80182b:	53                   	push   %ebx
  80182c:	e8 c4 f0 ff ff       	call   8008f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801831:	a1 80 60 80 00       	mov    0x806080,%eax
  801836:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80183c:	a1 84 60 80 00       	mov    0x806084,%eax
  801841:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <devfile_write>:
{
  801854:	f3 0f 1e fb          	endbr32 
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	8b 45 10             	mov    0x10(%ebp),%eax
  801861:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801866:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80186b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80186e:	8b 55 08             	mov    0x8(%ebp),%edx
  801871:	8b 52 0c             	mov    0xc(%edx),%edx
  801874:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80187a:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80187f:	50                   	push   %eax
  801880:	ff 75 0c             	pushl  0xc(%ebp)
  801883:	68 08 60 80 00       	push   $0x806008
  801888:	e8 66 f2 ff ff       	call   800af3 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	b8 04 00 00 00       	mov    $0x4,%eax
  801897:	e8 ba fe ff ff       	call   801756 <fsipc>
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_read>:
{
  80189e:	f3 0f 1e fb          	endbr32 
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8018b5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c5:	e8 8c fe ff ff       	call   801756 <fsipc>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 1f                	js     8018ef <devfile_read+0x51>
	assert(r <= n);
  8018d0:	39 f0                	cmp    %esi,%eax
  8018d2:	77 24                	ja     8018f8 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8018d4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d9:	7f 36                	jg     801911 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018db:	83 ec 04             	sub    $0x4,%esp
  8018de:	50                   	push   %eax
  8018df:	68 00 60 80 00       	push   $0x806000
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	e8 07 f2 ff ff       	call   800af3 <memmove>
	return r;
  8018ec:	83 c4 10             	add    $0x10,%esp
}
  8018ef:	89 d8                	mov    %ebx,%eax
  8018f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    
	assert(r <= n);
  8018f8:	68 cc 33 80 00       	push   $0x8033cc
  8018fd:	68 d3 33 80 00       	push   $0x8033d3
  801902:	68 8c 00 00 00       	push   $0x8c
  801907:	68 e8 33 80 00       	push   $0x8033e8
  80190c:	e8 f3 e8 ff ff       	call   800204 <_panic>
	assert(r <= PGSIZE);
  801911:	68 f3 33 80 00       	push   $0x8033f3
  801916:	68 d3 33 80 00       	push   $0x8033d3
  80191b:	68 8d 00 00 00       	push   $0x8d
  801920:	68 e8 33 80 00       	push   $0x8033e8
  801925:	e8 da e8 ff ff       	call   800204 <_panic>

0080192a <open>:
{
  80192a:	f3 0f 1e fb          	endbr32 
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	56                   	push   %esi
  801932:	53                   	push   %ebx
  801933:	83 ec 1c             	sub    $0x1c,%esp
  801936:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801939:	56                   	push   %esi
  80193a:	e8 73 ef ff ff       	call   8008b2 <strlen>
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801947:	7f 6c                	jg     8019b5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801949:	83 ec 0c             	sub    $0xc,%esp
  80194c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194f:	50                   	push   %eax
  801950:	e8 5c f8 ff ff       	call   8011b1 <fd_alloc>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	85 c0                	test   %eax,%eax
  80195c:	78 3c                	js     80199a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80195e:	83 ec 08             	sub    $0x8,%esp
  801961:	56                   	push   %esi
  801962:	68 00 60 80 00       	push   $0x806000
  801967:	e8 89 ef ff ff       	call   8008f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801974:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801977:	b8 01 00 00 00       	mov    $0x1,%eax
  80197c:	e8 d5 fd ff ff       	call   801756 <fsipc>
  801981:	89 c3                	mov    %eax,%ebx
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	78 19                	js     8019a3 <open+0x79>
	return fd2num(fd);
  80198a:	83 ec 0c             	sub    $0xc,%esp
  80198d:	ff 75 f4             	pushl  -0xc(%ebp)
  801990:	e8 ed f7 ff ff       	call   801182 <fd2num>
  801995:	89 c3                	mov    %eax,%ebx
  801997:	83 c4 10             	add    $0x10,%esp
}
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    
		fd_close(fd, 0);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	6a 00                	push   $0x0
  8019a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ab:	e8 0a f9 ff ff       	call   8012ba <fd_close>
		return r;
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	eb e5                	jmp    80199a <open+0x70>
		return -E_BAD_PATH;
  8019b5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ba:	eb de                	jmp    80199a <open+0x70>

008019bc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019bc:	f3 0f 1e fb          	endbr32 
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d0:	e8 81 fd ff ff       	call   801756 <fsipc>
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019d7:	f3 0f 1e fb          	endbr32 
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	57                   	push   %edi
  8019df:	56                   	push   %esi
  8019e0:	53                   	push   %ebx
  8019e1:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019e7:	6a 00                	push   $0x0
  8019e9:	ff 75 08             	pushl  0x8(%ebp)
  8019ec:	e8 39 ff ff ff       	call   80192a <open>
  8019f1:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	0f 88 b2 04 00 00    	js     801eb4 <spawn+0x4dd>
  801a02:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	68 00 02 00 00       	push   $0x200
  801a0c:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a12:	50                   	push   %eax
  801a13:	51                   	push   %ecx
  801a14:	e8 01 fb ff ff       	call   80151a <readn>
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a21:	75 7e                	jne    801aa1 <spawn+0xca>
	    || elf->e_magic != ELF_MAGIC) {
  801a23:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a2a:	45 4c 46 
  801a2d:	75 72                	jne    801aa1 <spawn+0xca>
  801a2f:	b8 07 00 00 00       	mov    $0x7,%eax
  801a34:	cd 30                	int    $0x30
  801a36:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a3c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a42:	85 c0                	test   %eax,%eax
  801a44:	0f 88 5e 04 00 00    	js     801ea8 <spawn+0x4d1>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a4a:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a4f:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801a52:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a58:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a5e:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a65:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a6b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a71:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801a76:	be 00 00 00 00       	mov    $0x0,%esi
  801a7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a7e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801a85:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	74 4d                	je     801ad9 <spawn+0x102>
		string_size += strlen(argv[argc]) + 1;
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	50                   	push   %eax
  801a90:	e8 1d ee ff ff       	call   8008b2 <strlen>
  801a95:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801a99:	83 c3 01             	add    $0x1,%ebx
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	eb dd                	jmp    801a7e <spawn+0xa7>
		close(fd);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801aaa:	e8 96 f8 ff ff       	call   801345 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801aaf:	83 c4 0c             	add    $0xc,%esp
  801ab2:	68 7f 45 4c 46       	push   $0x464c457f
  801ab7:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801abd:	68 5f 34 80 00       	push   $0x80345f
  801ac2:	e8 24 e8 ff ff       	call   8002eb <cprintf>
		return -E_NOT_EXEC;
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801ad1:	ff ff ff 
  801ad4:	e9 db 03 00 00       	jmp    801eb4 <spawn+0x4dd>
  801ad9:	89 85 70 fd ff ff    	mov    %eax,-0x290(%ebp)
  801adf:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801ae5:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801aeb:	bf 00 10 40 00       	mov    $0x401000,%edi
  801af0:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801af2:	89 fa                	mov    %edi,%edx
  801af4:	83 e2 fc             	and    $0xfffffffc,%edx
  801af7:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801afe:	29 c2                	sub    %eax,%edx
  801b00:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b06:	8d 42 f8             	lea    -0x8(%edx),%eax
  801b09:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b0e:	0f 86 12 04 00 00    	jbe    801f26 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b14:	83 ec 04             	sub    $0x4,%esp
  801b17:	6a 07                	push   $0x7
  801b19:	68 00 00 40 00       	push   $0x400000
  801b1e:	6a 00                	push   $0x0
  801b20:	e8 39 f2 ff ff       	call   800d5e <sys_page_alloc>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	0f 88 fb 03 00 00    	js     801f2b <spawn+0x554>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b30:	be 00 00 00 00       	mov    $0x0,%esi
  801b35:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801b3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b3e:	eb 30                	jmp    801b70 <spawn+0x199>
		argv_store[i] = UTEMP2USTACK(string_store);
  801b40:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b46:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801b4c:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801b4f:	83 ec 08             	sub    $0x8,%esp
  801b52:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b55:	57                   	push   %edi
  801b56:	e8 9a ed ff ff       	call   8008f5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b5b:	83 c4 04             	add    $0x4,%esp
  801b5e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b61:	e8 4c ed ff ff       	call   8008b2 <strlen>
  801b66:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801b6a:	83 c6 01             	add    $0x1,%esi
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801b76:	7f c8                	jg     801b40 <spawn+0x169>
	}
	argv_store[argc] = 0;
  801b78:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b7e:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b84:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b8b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b91:	0f 85 88 00 00 00    	jne    801c1f <spawn+0x248>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b97:	8b 8d 90 fd ff ff    	mov    -0x270(%ebp),%ecx
  801b9d:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801ba3:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801ba6:	89 c8                	mov    %ecx,%eax
  801ba8:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801bae:	89 51 f8             	mov    %edx,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801bb1:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801bb6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	6a 07                	push   $0x7
  801bc1:	68 00 d0 bf ee       	push   $0xeebfd000
  801bc6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bcc:	68 00 00 40 00       	push   $0x400000
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 ac f1 ff ff       	call   800d84 <sys_page_map>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	83 c4 20             	add    $0x20,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 4e 03 00 00    	js     801f33 <spawn+0x55c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801be5:	83 ec 08             	sub    $0x8,%esp
  801be8:	68 00 00 40 00       	push   $0x400000
  801bed:	6a 00                	push   $0x0
  801bef:	e8 b5 f1 ff ff       	call   800da9 <sys_page_unmap>
  801bf4:	89 c3                	mov    %eax,%ebx
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	0f 88 32 03 00 00    	js     801f33 <spawn+0x55c>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c01:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c07:	8d b4 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%esi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c0e:	c7 85 84 fd ff ff 00 	movl   $0x0,-0x27c(%ebp)
  801c15:	00 00 00 
  801c18:	89 f7                	mov    %esi,%edi
  801c1a:	e9 4f 01 00 00       	jmp    801d6e <spawn+0x397>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c1f:	68 ec 34 80 00       	push   $0x8034ec
  801c24:	68 d3 33 80 00       	push   $0x8033d3
  801c29:	68 f1 00 00 00       	push   $0xf1
  801c2e:	68 79 34 80 00       	push   $0x803479
  801c33:	e8 cc e5 ff ff       	call   800204 <_panic>
			// allocate a blank page bss segment
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c38:	83 ec 04             	sub    $0x4,%esp
  801c3b:	6a 07                	push   $0x7
  801c3d:	68 00 00 40 00       	push   $0x400000
  801c42:	6a 00                	push   $0x0
  801c44:	e8 15 f1 ff ff       	call   800d5e <sys_page_alloc>
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 6e 02 00 00    	js     801ec2 <spawn+0x4eb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c5d:	01 f8                	add    %edi,%eax
  801c5f:	50                   	push   %eax
  801c60:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801c66:	e8 80 f9 ff ff       	call   8015eb <seek>
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	0f 88 53 02 00 00    	js     801ec9 <spawn+0x4f2>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c76:	83 ec 04             	sub    $0x4,%esp
  801c79:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801c7f:	29 f8                	sub    %edi,%eax
  801c81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c86:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c8b:	0f 47 c1             	cmova  %ecx,%eax
  801c8e:	50                   	push   %eax
  801c8f:	68 00 00 40 00       	push   $0x400000
  801c94:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801c9a:	e8 7b f8 ff ff       	call   80151a <readn>
  801c9f:	83 c4 10             	add    $0x10,%esp
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	0f 88 26 02 00 00    	js     801ed0 <spawn+0x4f9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cb3:	53                   	push   %ebx
  801cb4:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cba:	68 00 00 40 00       	push   $0x400000
  801cbf:	6a 00                	push   $0x0
  801cc1:	e8 be f0 ff ff       	call   800d84 <sys_page_map>
  801cc6:	83 c4 20             	add    $0x20,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 7c                	js     801d49 <spawn+0x372>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801ccd:	83 ec 08             	sub    $0x8,%esp
  801cd0:	68 00 00 40 00       	push   $0x400000
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 cd f0 ff ff       	call   800da9 <sys_page_unmap>
  801cdc:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801cdf:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801ce5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ceb:	89 f7                	mov    %esi,%edi
  801ced:	39 b5 7c fd ff ff    	cmp    %esi,-0x284(%ebp)
  801cf3:	76 69                	jbe    801d5e <spawn+0x387>
		if (i >= filesz) {
  801cf5:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801cfb:	0f 87 37 ff ff ff    	ja     801c38 <spawn+0x261>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d01:	83 ec 04             	sub    $0x4,%esp
  801d04:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d0a:	53                   	push   %ebx
  801d0b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d11:	e8 48 f0 ff ff       	call   800d5e <sys_page_alloc>
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	79 c2                	jns    801cdf <spawn+0x308>
  801d1d:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d28:	e8 c7 ef ff ff       	call   800cf4 <sys_env_destroy>
	close(fd);
  801d2d:	83 c4 04             	add    $0x4,%esp
  801d30:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801d36:	e8 0a f6 ff ff       	call   801345 <close>
	return r;
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
  801d44:	e9 6b 01 00 00       	jmp    801eb4 <spawn+0x4dd>
				panic("spawn: sys_page_map data: %e", r);
  801d49:	50                   	push   %eax
  801d4a:	68 85 34 80 00       	push   $0x803485
  801d4f:	68 24 01 00 00       	push   $0x124
  801d54:	68 79 34 80 00       	push   $0x803479
  801d59:	e8 a6 e4 ff ff       	call   800204 <_panic>
  801d5e:	8b bd 78 fd ff ff    	mov    -0x288(%ebp),%edi
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d64:	83 85 84 fd ff ff 01 	addl   $0x1,-0x27c(%ebp)
  801d6b:	83 c7 20             	add    $0x20,%edi
  801d6e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d75:	3b 85 84 fd ff ff    	cmp    -0x27c(%ebp),%eax
  801d7b:	7e 6d                	jle    801dea <spawn+0x413>
		if (ph->p_type != ELF_PROG_LOAD)
  801d7d:	83 3f 01             	cmpl   $0x1,(%edi)
  801d80:	75 e2                	jne    801d64 <spawn+0x38d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d82:	8b 47 18             	mov    0x18(%edi),%eax
  801d85:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d88:	83 f8 01             	cmp    $0x1,%eax
  801d8b:	19 c0                	sbb    %eax,%eax
  801d8d:	83 e0 fe             	and    $0xfffffffe,%eax
  801d90:	83 c0 07             	add    $0x7,%eax
  801d93:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d99:	8b 57 04             	mov    0x4(%edi),%edx
  801d9c:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  801da2:	8b 4f 10             	mov    0x10(%edi),%ecx
  801da5:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801dab:	8b 77 14             	mov    0x14(%edi),%esi
  801dae:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
  801db4:	8b 5f 08             	mov    0x8(%edi),%ebx
	if ((i = PGOFF(va))) {
  801db7:	89 d8                	mov    %ebx,%eax
  801db9:	25 ff 0f 00 00       	and    $0xfff,%eax
  801dbe:	74 1a                	je     801dda <spawn+0x403>
		va -= i;
  801dc0:	29 c3                	sub    %eax,%ebx
		memsz += i;
  801dc2:	01 c6                	add    %eax,%esi
  801dc4:	89 b5 7c fd ff ff    	mov    %esi,-0x284(%ebp)
		filesz += i;
  801dca:	01 c1                	add    %eax,%ecx
  801dcc:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		fileoffset -= i;
  801dd2:	29 c2                	sub    %eax,%edx
  801dd4:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801dda:	be 00 00 00 00       	mov    $0x0,%esi
  801ddf:	89 bd 78 fd ff ff    	mov    %edi,-0x288(%ebp)
  801de5:	e9 01 ff ff ff       	jmp    801ceb <spawn+0x314>
	close(fd);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801df3:	e8 4d f5 ff ff       	call   801345 <close>
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801e01:	8b 9d 70 fd ff ff    	mov    -0x290(%ebp),%ebx
  801e07:	eb 12                	jmp    801e1b <spawn+0x444>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	void* addr; int r;
	for (addr = 0; addr<(void*)USTACKTOP; addr+=PGSIZE){
  801e09:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e0f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801e15:	0f 84 bc 00 00 00    	je     801ed7 <spawn+0x500>
		if ((uvpd[PDX(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_P) && (uvpt[PGNUM(addr)]&PTE_SHARE)){
  801e1b:	89 d8                	mov    %ebx,%eax
  801e1d:	c1 e8 16             	shr    $0x16,%eax
  801e20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e27:	a8 01                	test   $0x1,%al
  801e29:	74 de                	je     801e09 <spawn+0x432>
  801e2b:	89 d8                	mov    %ebx,%eax
  801e2d:	c1 e8 0c             	shr    $0xc,%eax
  801e30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e37:	f6 c2 01             	test   $0x1,%dl
  801e3a:	74 cd                	je     801e09 <spawn+0x432>
  801e3c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e43:	f6 c6 04             	test   $0x4,%dh
  801e46:	74 c1                	je     801e09 <spawn+0x432>
			if ((r = sys_page_map(0, addr, child, addr, (uvpt[PGNUM(addr)]&PTE_SYSCALL)))<0)
  801e48:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e4f:	83 ec 0c             	sub    $0xc,%esp
  801e52:	25 07 0e 00 00       	and    $0xe07,%eax
  801e57:	50                   	push   %eax
  801e58:	53                   	push   %ebx
  801e59:	56                   	push   %esi
  801e5a:	53                   	push   %ebx
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 22 ef ff ff       	call   800d84 <sys_page_map>
  801e62:	83 c4 20             	add    $0x20,%esp
  801e65:	85 c0                	test   %eax,%eax
  801e67:	79 a0                	jns    801e09 <spawn+0x432>
		panic("copy_shared_pages: %e", r);
  801e69:	50                   	push   %eax
  801e6a:	68 d3 34 80 00       	push   $0x8034d3
  801e6f:	68 82 00 00 00       	push   $0x82
  801e74:	68 79 34 80 00       	push   $0x803479
  801e79:	e8 86 e3 ff ff       	call   800204 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801e7e:	50                   	push   %eax
  801e7f:	68 a2 34 80 00       	push   $0x8034a2
  801e84:	68 86 00 00 00       	push   $0x86
  801e89:	68 79 34 80 00       	push   $0x803479
  801e8e:	e8 71 e3 ff ff       	call   800204 <_panic>
		panic("sys_env_set_status: %e", r);
  801e93:	50                   	push   %eax
  801e94:	68 bc 34 80 00       	push   $0x8034bc
  801e99:	68 89 00 00 00       	push   $0x89
  801e9e:	68 79 34 80 00       	push   $0x803479
  801ea3:	e8 5c e3 ff ff       	call   800204 <_panic>
		return r;
  801ea8:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801eae:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801eb4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    
  801ec2:	89 c7                	mov    %eax,%edi
  801ec4:	e9 56 fe ff ff       	jmp    801d1f <spawn+0x348>
  801ec9:	89 c7                	mov    %eax,%edi
  801ecb:	e9 4f fe ff ff       	jmp    801d1f <spawn+0x348>
  801ed0:	89 c7                	mov    %eax,%edi
  801ed2:	e9 48 fe ff ff       	jmp    801d1f <spawn+0x348>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ed7:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ede:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ee1:	83 ec 08             	sub    $0x8,%esp
  801ee4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801eea:	50                   	push   %eax
  801eeb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ef1:	e8 fd ee ff ff       	call   800df3 <sys_env_set_trapframe>
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 81                	js     801e7e <spawn+0x4a7>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801efd:	83 ec 08             	sub    $0x8,%esp
  801f00:	6a 02                	push   $0x2
  801f02:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f08:	e8 c1 ee ff ff       	call   800dce <sys_env_set_status>
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	0f 88 7b ff ff ff    	js     801e93 <spawn+0x4bc>
	return child;
  801f18:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f1e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f24:	eb 8e                	jmp    801eb4 <spawn+0x4dd>
		return -E_NO_MEM;
  801f26:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f2b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f31:	eb 81                	jmp    801eb4 <spawn+0x4dd>
	sys_page_unmap(0, UTEMP);
  801f33:	83 ec 08             	sub    $0x8,%esp
  801f36:	68 00 00 40 00       	push   $0x400000
  801f3b:	6a 00                	push   $0x0
  801f3d:	e8 67 ee ff ff       	call   800da9 <sys_page_unmap>
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f4b:	e9 64 ff ff ff       	jmp    801eb4 <spawn+0x4dd>

00801f50 <spawnl>:
{
  801f50:	f3 0f 1e fb          	endbr32 
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	57                   	push   %edi
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801f5d:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801f65:	8d 4a 04             	lea    0x4(%edx),%ecx
  801f68:	83 3a 00             	cmpl   $0x0,(%edx)
  801f6b:	74 07                	je     801f74 <spawnl+0x24>
		argc++;
  801f6d:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801f70:	89 ca                	mov    %ecx,%edx
  801f72:	eb f1                	jmp    801f65 <spawnl+0x15>
	const char *argv[argc+2];
  801f74:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801f7b:	89 d1                	mov    %edx,%ecx
  801f7d:	83 e1 f0             	and    $0xfffffff0,%ecx
  801f80:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801f86:	89 e6                	mov    %esp,%esi
  801f88:	29 d6                	sub    %edx,%esi
  801f8a:	89 f2                	mov    %esi,%edx
  801f8c:	39 d4                	cmp    %edx,%esp
  801f8e:	74 10                	je     801fa0 <spawnl+0x50>
  801f90:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801f96:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801f9d:	00 
  801f9e:	eb ec                	jmp    801f8c <spawnl+0x3c>
  801fa0:	89 ca                	mov    %ecx,%edx
  801fa2:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801fa8:	29 d4                	sub    %edx,%esp
  801faa:	85 d2                	test   %edx,%edx
  801fac:	74 05                	je     801fb3 <spawnl+0x63>
  801fae:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801fb3:	8d 74 24 03          	lea    0x3(%esp),%esi
  801fb7:	89 f2                	mov    %esi,%edx
  801fb9:	c1 ea 02             	shr    $0x2,%edx
  801fbc:	83 e6 fc             	and    $0xfffffffc,%esi
  801fbf:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801fc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc4:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801fcb:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801fd2:	00 
	va_start(vl, arg0);
  801fd3:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801fd6:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdd:	eb 0b                	jmp    801fea <spawnl+0x9a>
		argv[i+1] = va_arg(vl, const char *);
  801fdf:	83 c0 01             	add    $0x1,%eax
  801fe2:	8b 39                	mov    (%ecx),%edi
  801fe4:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801fe7:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801fea:	39 d0                	cmp    %edx,%eax
  801fec:	75 f1                	jne    801fdf <spawnl+0x8f>
	return spawn(prog, argv);
  801fee:	83 ec 08             	sub    $0x8,%esp
  801ff1:	56                   	push   %esi
  801ff2:	ff 75 08             	pushl  0x8(%ebp)
  801ff5:	e8 dd f9 ff ff       	call   8019d7 <spawn>
}
  801ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802002:	f3 0f 1e fb          	endbr32 
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80200c:	68 12 35 80 00       	push   $0x803512
  802011:	ff 75 0c             	pushl  0xc(%ebp)
  802014:	e8 dc e8 ff ff       	call   8008f5 <strcpy>
	return 0;
}
  802019:	b8 00 00 00 00       	mov    $0x0,%eax
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <devsock_close>:
{
  802020:	f3 0f 1e fb          	endbr32 
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	53                   	push   %ebx
  802028:	83 ec 10             	sub    $0x10,%esp
  80202b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80202e:	53                   	push   %ebx
  80202f:	e8 6d 0b 00 00       	call   802ba1 <pageref>
  802034:	89 c2                	mov    %eax,%edx
  802036:	83 c4 10             	add    $0x10,%esp
		return 0;
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80203e:	83 fa 01             	cmp    $0x1,%edx
  802041:	74 05                	je     802048 <devsock_close+0x28>
}
  802043:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802046:	c9                   	leave  
  802047:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	ff 73 0c             	pushl  0xc(%ebx)
  80204e:	e8 e3 02 00 00       	call   802336 <nsipc_close>
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	eb eb                	jmp    802043 <devsock_close+0x23>

00802058 <devsock_write>:
{
  802058:	f3 0f 1e fb          	endbr32 
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802062:	6a 00                	push   $0x0
  802064:	ff 75 10             	pushl  0x10(%ebp)
  802067:	ff 75 0c             	pushl  0xc(%ebp)
  80206a:	8b 45 08             	mov    0x8(%ebp),%eax
  80206d:	ff 70 0c             	pushl  0xc(%eax)
  802070:	e8 b5 03 00 00       	call   80242a <nsipc_send>
}
  802075:	c9                   	leave  
  802076:	c3                   	ret    

00802077 <devsock_read>:
{
  802077:	f3 0f 1e fb          	endbr32 
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802081:	6a 00                	push   $0x0
  802083:	ff 75 10             	pushl  0x10(%ebp)
  802086:	ff 75 0c             	pushl  0xc(%ebp)
  802089:	8b 45 08             	mov    0x8(%ebp),%eax
  80208c:	ff 70 0c             	pushl  0xc(%eax)
  80208f:	e8 1f 03 00 00       	call   8023b3 <nsipc_recv>
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    

00802096 <fd2sockid>:
{
  802096:	55                   	push   %ebp
  802097:	89 e5                	mov    %esp,%ebp
  802099:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80209c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80209f:	52                   	push   %edx
  8020a0:	50                   	push   %eax
  8020a1:	e8 61 f1 ff ff       	call   801207 <fd_lookup>
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	78 10                	js     8020bd <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8020ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b0:	8b 0d 60 40 80 00    	mov    0x804060,%ecx
  8020b6:	39 08                	cmp    %ecx,(%eax)
  8020b8:	75 05                	jne    8020bf <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8020ba:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    
		return -E_NOT_SUPP;
  8020bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020c4:	eb f7                	jmp    8020bd <fd2sockid+0x27>

008020c6 <alloc_sockfd>:
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	56                   	push   %esi
  8020ca:	53                   	push   %ebx
  8020cb:	83 ec 1c             	sub    $0x1c,%esp
  8020ce:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8020d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d3:	50                   	push   %eax
  8020d4:	e8 d8 f0 ff ff       	call   8011b1 <fd_alloc>
  8020d9:	89 c3                	mov    %eax,%ebx
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 43                	js     802125 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8020e2:	83 ec 04             	sub    $0x4,%esp
  8020e5:	68 07 04 00 00       	push   $0x407
  8020ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ed:	6a 00                	push   $0x0
  8020ef:	e8 6a ec ff ff       	call   800d5e <sys_page_alloc>
  8020f4:	89 c3                	mov    %eax,%ebx
  8020f6:	83 c4 10             	add    $0x10,%esp
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	78 28                	js     802125 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8020fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802100:	8b 15 60 40 80 00    	mov    0x804060,%edx
  802106:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802112:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802115:	83 ec 0c             	sub    $0xc,%esp
  802118:	50                   	push   %eax
  802119:	e8 64 f0 ff ff       	call   801182 <fd2num>
  80211e:	89 c3                	mov    %eax,%ebx
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	eb 0c                	jmp    802131 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802125:	83 ec 0c             	sub    $0xc,%esp
  802128:	56                   	push   %esi
  802129:	e8 08 02 00 00       	call   802336 <nsipc_close>
		return r;
  80212e:	83 c4 10             	add    $0x10,%esp
}
  802131:	89 d8                	mov    %ebx,%eax
  802133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802136:	5b                   	pop    %ebx
  802137:	5e                   	pop    %esi
  802138:	5d                   	pop    %ebp
  802139:	c3                   	ret    

0080213a <accept>:
{
  80213a:	f3 0f 1e fb          	endbr32 
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802144:	8b 45 08             	mov    0x8(%ebp),%eax
  802147:	e8 4a ff ff ff       	call   802096 <fd2sockid>
  80214c:	85 c0                	test   %eax,%eax
  80214e:	78 1b                	js     80216b <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802150:	83 ec 04             	sub    $0x4,%esp
  802153:	ff 75 10             	pushl  0x10(%ebp)
  802156:	ff 75 0c             	pushl  0xc(%ebp)
  802159:	50                   	push   %eax
  80215a:	e8 22 01 00 00       	call   802281 <nsipc_accept>
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	85 c0                	test   %eax,%eax
  802164:	78 05                	js     80216b <accept+0x31>
	return alloc_sockfd(r);
  802166:	e8 5b ff ff ff       	call   8020c6 <alloc_sockfd>
}
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    

0080216d <bind>:
{
  80216d:	f3 0f 1e fb          	endbr32 
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802177:	8b 45 08             	mov    0x8(%ebp),%eax
  80217a:	e8 17 ff ff ff       	call   802096 <fd2sockid>
  80217f:	85 c0                	test   %eax,%eax
  802181:	78 12                	js     802195 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  802183:	83 ec 04             	sub    $0x4,%esp
  802186:	ff 75 10             	pushl  0x10(%ebp)
  802189:	ff 75 0c             	pushl  0xc(%ebp)
  80218c:	50                   	push   %eax
  80218d:	e8 45 01 00 00       	call   8022d7 <nsipc_bind>
  802192:	83 c4 10             	add    $0x10,%esp
}
  802195:	c9                   	leave  
  802196:	c3                   	ret    

00802197 <shutdown>:
{
  802197:	f3 0f 1e fb          	endbr32 
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8021a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a4:	e8 ed fe ff ff       	call   802096 <fd2sockid>
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	78 0f                	js     8021bc <shutdown+0x25>
	return nsipc_shutdown(r, how);
  8021ad:	83 ec 08             	sub    $0x8,%esp
  8021b0:	ff 75 0c             	pushl  0xc(%ebp)
  8021b3:	50                   	push   %eax
  8021b4:	e8 57 01 00 00       	call   802310 <nsipc_shutdown>
  8021b9:	83 c4 10             	add    $0x10,%esp
}
  8021bc:	c9                   	leave  
  8021bd:	c3                   	ret    

008021be <connect>:
{
  8021be:	f3 0f 1e fb          	endbr32 
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	e8 c6 fe ff ff       	call   802096 <fd2sockid>
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 12                	js     8021e6 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  8021d4:	83 ec 04             	sub    $0x4,%esp
  8021d7:	ff 75 10             	pushl  0x10(%ebp)
  8021da:	ff 75 0c             	pushl  0xc(%ebp)
  8021dd:	50                   	push   %eax
  8021de:	e8 71 01 00 00       	call   802354 <nsipc_connect>
  8021e3:	83 c4 10             	add    $0x10,%esp
}
  8021e6:	c9                   	leave  
  8021e7:	c3                   	ret    

008021e8 <listen>:
{
  8021e8:	f3 0f 1e fb          	endbr32 
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8021f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f5:	e8 9c fe ff ff       	call   802096 <fd2sockid>
  8021fa:	85 c0                	test   %eax,%eax
  8021fc:	78 0f                	js     80220d <listen+0x25>
	return nsipc_listen(r, backlog);
  8021fe:	83 ec 08             	sub    $0x8,%esp
  802201:	ff 75 0c             	pushl  0xc(%ebp)
  802204:	50                   	push   %eax
  802205:	e8 83 01 00 00       	call   80238d <nsipc_listen>
  80220a:	83 c4 10             	add    $0x10,%esp
}
  80220d:	c9                   	leave  
  80220e:	c3                   	ret    

0080220f <socket>:

int
socket(int domain, int type, int protocol)
{
  80220f:	f3 0f 1e fb          	endbr32 
  802213:	55                   	push   %ebp
  802214:	89 e5                	mov    %esp,%ebp
  802216:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802219:	ff 75 10             	pushl  0x10(%ebp)
  80221c:	ff 75 0c             	pushl  0xc(%ebp)
  80221f:	ff 75 08             	pushl  0x8(%ebp)
  802222:	e8 65 02 00 00       	call   80248c <nsipc_socket>
  802227:	83 c4 10             	add    $0x10,%esp
  80222a:	85 c0                	test   %eax,%eax
  80222c:	78 05                	js     802233 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  80222e:	e8 93 fe ff ff       	call   8020c6 <alloc_sockfd>
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	53                   	push   %ebx
  802239:	83 ec 04             	sub    $0x4,%esp
  80223c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80223e:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802245:	74 26                	je     80226d <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802247:	6a 07                	push   $0x7
  802249:	68 00 70 80 00       	push   $0x807000
  80224e:	53                   	push   %ebx
  80224f:	ff 35 04 50 80 00    	pushl  0x805004
  802255:	e8 b2 08 00 00       	call   802b0c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80225a:	83 c4 0c             	add    $0xc,%esp
  80225d:	6a 00                	push   $0x0
  80225f:	6a 00                	push   $0x0
  802261:	6a 00                	push   $0x0
  802263:	e8 37 08 00 00       	call   802a9f <ipc_recv>
}
  802268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80226b:	c9                   	leave  
  80226c:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80226d:	83 ec 0c             	sub    $0xc,%esp
  802270:	6a 02                	push   $0x2
  802272:	e8 ed 08 00 00       	call   802b64 <ipc_find_env>
  802277:	a3 04 50 80 00       	mov    %eax,0x805004
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	eb c6                	jmp    802247 <nsipc+0x12>

00802281 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802281:	f3 0f 1e fb          	endbr32 
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	56                   	push   %esi
  802289:	53                   	push   %ebx
  80228a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80228d:	8b 45 08             	mov    0x8(%ebp),%eax
  802290:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802295:	8b 06                	mov    (%esi),%eax
  802297:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80229c:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a1:	e8 8f ff ff ff       	call   802235 <nsipc>
  8022a6:	89 c3                	mov    %eax,%ebx
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	79 09                	jns    8022b5 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b1:	5b                   	pop    %ebx
  8022b2:	5e                   	pop    %esi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8022b5:	83 ec 04             	sub    $0x4,%esp
  8022b8:	ff 35 10 70 80 00    	pushl  0x807010
  8022be:	68 00 70 80 00       	push   $0x807000
  8022c3:	ff 75 0c             	pushl  0xc(%ebp)
  8022c6:	e8 28 e8 ff ff       	call   800af3 <memmove>
		*addrlen = ret->ret_addrlen;
  8022cb:	a1 10 70 80 00       	mov    0x807010,%eax
  8022d0:	89 06                	mov    %eax,(%esi)
  8022d2:	83 c4 10             	add    $0x10,%esp
	return r;
  8022d5:	eb d5                	jmp    8022ac <nsipc_accept+0x2b>

008022d7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022d7:	f3 0f 1e fb          	endbr32 
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	53                   	push   %ebx
  8022df:	83 ec 08             	sub    $0x8,%esp
  8022e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8022e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8022ed:	53                   	push   %ebx
  8022ee:	ff 75 0c             	pushl  0xc(%ebp)
  8022f1:	68 04 70 80 00       	push   $0x807004
  8022f6:	e8 f8 e7 ff ff       	call   800af3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022fb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802301:	b8 02 00 00 00       	mov    $0x2,%eax
  802306:	e8 2a ff ff ff       	call   802235 <nsipc>
}
  80230b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80230e:	c9                   	leave  
  80230f:	c3                   	ret    

00802310 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802310:	f3 0f 1e fb          	endbr32 
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80231a:	8b 45 08             	mov    0x8(%ebp),%eax
  80231d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802322:	8b 45 0c             	mov    0xc(%ebp),%eax
  802325:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80232a:	b8 03 00 00 00       	mov    $0x3,%eax
  80232f:	e8 01 ff ff ff       	call   802235 <nsipc>
}
  802334:	c9                   	leave  
  802335:	c3                   	ret    

00802336 <nsipc_close>:

int
nsipc_close(int s)
{
  802336:	f3 0f 1e fb          	endbr32 
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802340:	8b 45 08             	mov    0x8(%ebp),%eax
  802343:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802348:	b8 04 00 00 00       	mov    $0x4,%eax
  80234d:	e8 e3 fe ff ff       	call   802235 <nsipc>
}
  802352:	c9                   	leave  
  802353:	c3                   	ret    

00802354 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802354:	f3 0f 1e fb          	endbr32 
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	53                   	push   %ebx
  80235c:	83 ec 08             	sub    $0x8,%esp
  80235f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802362:	8b 45 08             	mov    0x8(%ebp),%eax
  802365:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80236a:	53                   	push   %ebx
  80236b:	ff 75 0c             	pushl  0xc(%ebp)
  80236e:	68 04 70 80 00       	push   $0x807004
  802373:	e8 7b e7 ff ff       	call   800af3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802378:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80237e:	b8 05 00 00 00       	mov    $0x5,%eax
  802383:	e8 ad fe ff ff       	call   802235 <nsipc>
}
  802388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80238b:	c9                   	leave  
  80238c:	c3                   	ret    

0080238d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80238d:	f3 0f 1e fb          	endbr32 
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802397:	8b 45 08             	mov    0x8(%ebp),%eax
  80239a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80239f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a2:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8023a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8023ac:	e8 84 fe ff ff       	call   802235 <nsipc>
}
  8023b1:	c9                   	leave  
  8023b2:	c3                   	ret    

008023b3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023b3:	f3 0f 1e fb          	endbr32 
  8023b7:	55                   	push   %ebp
  8023b8:	89 e5                	mov    %esp,%ebp
  8023ba:	56                   	push   %esi
  8023bb:	53                   	push   %ebx
  8023bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8023c7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8023cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8023d0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8023d5:	b8 07 00 00 00       	mov    $0x7,%eax
  8023da:	e8 56 fe ff ff       	call   802235 <nsipc>
  8023df:	89 c3                	mov    %eax,%ebx
  8023e1:	85 c0                	test   %eax,%eax
  8023e3:	78 26                	js     80240b <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  8023e5:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  8023eb:	b8 3f 06 00 00       	mov    $0x63f,%eax
  8023f0:	0f 4e c6             	cmovle %esi,%eax
  8023f3:	39 c3                	cmp    %eax,%ebx
  8023f5:	7f 1d                	jg     802414 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023f7:	83 ec 04             	sub    $0x4,%esp
  8023fa:	53                   	push   %ebx
  8023fb:	68 00 70 80 00       	push   $0x807000
  802400:	ff 75 0c             	pushl  0xc(%ebp)
  802403:	e8 eb e6 ff ff       	call   800af3 <memmove>
  802408:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80240b:	89 d8                	mov    %ebx,%eax
  80240d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802410:	5b                   	pop    %ebx
  802411:	5e                   	pop    %esi
  802412:	5d                   	pop    %ebp
  802413:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802414:	68 1e 35 80 00       	push   $0x80351e
  802419:	68 d3 33 80 00       	push   $0x8033d3
  80241e:	6a 62                	push   $0x62
  802420:	68 33 35 80 00       	push   $0x803533
  802425:	e8 da dd ff ff       	call   800204 <_panic>

0080242a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80242a:	f3 0f 1e fb          	endbr32 
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	53                   	push   %ebx
  802432:	83 ec 04             	sub    $0x4,%esp
  802435:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802438:	8b 45 08             	mov    0x8(%ebp),%eax
  80243b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802440:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802446:	7f 2e                	jg     802476 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802448:	83 ec 04             	sub    $0x4,%esp
  80244b:	53                   	push   %ebx
  80244c:	ff 75 0c             	pushl  0xc(%ebp)
  80244f:	68 0c 70 80 00       	push   $0x80700c
  802454:	e8 9a e6 ff ff       	call   800af3 <memmove>
	nsipcbuf.send.req_size = size;
  802459:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80245f:	8b 45 14             	mov    0x14(%ebp),%eax
  802462:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802467:	b8 08 00 00 00       	mov    $0x8,%eax
  80246c:	e8 c4 fd ff ff       	call   802235 <nsipc>
}
  802471:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802474:	c9                   	leave  
  802475:	c3                   	ret    
	assert(size < 1600);
  802476:	68 3f 35 80 00       	push   $0x80353f
  80247b:	68 d3 33 80 00       	push   $0x8033d3
  802480:	6a 6d                	push   $0x6d
  802482:	68 33 35 80 00       	push   $0x803533
  802487:	e8 78 dd ff ff       	call   800204 <_panic>

0080248c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80248c:	f3 0f 1e fb          	endbr32 
  802490:	55                   	push   %ebp
  802491:	89 e5                	mov    %esp,%ebp
  802493:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802496:	8b 45 08             	mov    0x8(%ebp),%eax
  802499:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80249e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a1:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8024a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8024a9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8024ae:	b8 09 00 00 00       	mov    $0x9,%eax
  8024b3:	e8 7d fd ff ff       	call   802235 <nsipc>
}
  8024b8:	c9                   	leave  
  8024b9:	c3                   	ret    

008024ba <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024ba:	f3 0f 1e fb          	endbr32 
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	56                   	push   %esi
  8024c2:	53                   	push   %ebx
  8024c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8024c6:	83 ec 0c             	sub    $0xc,%esp
  8024c9:	ff 75 08             	pushl  0x8(%ebp)
  8024cc:	e8 c5 ec ff ff       	call   801196 <fd2data>
  8024d1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8024d3:	83 c4 08             	add    $0x8,%esp
  8024d6:	68 4b 35 80 00       	push   $0x80354b
  8024db:	53                   	push   %ebx
  8024dc:	e8 14 e4 ff ff       	call   8008f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024e1:	8b 46 04             	mov    0x4(%esi),%eax
  8024e4:	2b 06                	sub    (%esi),%eax
  8024e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8024ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8024f3:	00 00 00 
	stat->st_dev = &devpipe;
  8024f6:	c7 83 88 00 00 00 7c 	movl   $0x80407c,0x88(%ebx)
  8024fd:	40 80 00 
	return 0;
}
  802500:	b8 00 00 00 00       	mov    $0x0,%eax
  802505:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802508:	5b                   	pop    %ebx
  802509:	5e                   	pop    %esi
  80250a:	5d                   	pop    %ebp
  80250b:	c3                   	ret    

0080250c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80250c:	f3 0f 1e fb          	endbr32 
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	53                   	push   %ebx
  802514:	83 ec 0c             	sub    $0xc,%esp
  802517:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80251a:	53                   	push   %ebx
  80251b:	6a 00                	push   $0x0
  80251d:	e8 87 e8 ff ff       	call   800da9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802522:	89 1c 24             	mov    %ebx,(%esp)
  802525:	e8 6c ec ff ff       	call   801196 <fd2data>
  80252a:	83 c4 08             	add    $0x8,%esp
  80252d:	50                   	push   %eax
  80252e:	6a 00                	push   $0x0
  802530:	e8 74 e8 ff ff       	call   800da9 <sys_page_unmap>
}
  802535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802538:	c9                   	leave  
  802539:	c3                   	ret    

0080253a <_pipeisclosed>:
{
  80253a:	55                   	push   %ebp
  80253b:	89 e5                	mov    %esp,%ebp
  80253d:	57                   	push   %edi
  80253e:	56                   	push   %esi
  80253f:	53                   	push   %ebx
  802540:	83 ec 1c             	sub    $0x1c,%esp
  802543:	89 c7                	mov    %eax,%edi
  802545:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802547:	a1 08 50 80 00       	mov    0x805008,%eax
  80254c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80254f:	83 ec 0c             	sub    $0xc,%esp
  802552:	57                   	push   %edi
  802553:	e8 49 06 00 00       	call   802ba1 <pageref>
  802558:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80255b:	89 34 24             	mov    %esi,(%esp)
  80255e:	e8 3e 06 00 00       	call   802ba1 <pageref>
		nn = thisenv->env_runs;
  802563:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802569:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80256c:	83 c4 10             	add    $0x10,%esp
  80256f:	39 cb                	cmp    %ecx,%ebx
  802571:	74 1b                	je     80258e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802573:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802576:	75 cf                	jne    802547 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802578:	8b 42 58             	mov    0x58(%edx),%eax
  80257b:	6a 01                	push   $0x1
  80257d:	50                   	push   %eax
  80257e:	53                   	push   %ebx
  80257f:	68 52 35 80 00       	push   $0x803552
  802584:	e8 62 dd ff ff       	call   8002eb <cprintf>
  802589:	83 c4 10             	add    $0x10,%esp
  80258c:	eb b9                	jmp    802547 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80258e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802591:	0f 94 c0             	sete   %al
  802594:	0f b6 c0             	movzbl %al,%eax
}
  802597:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80259a:	5b                   	pop    %ebx
  80259b:	5e                   	pop    %esi
  80259c:	5f                   	pop    %edi
  80259d:	5d                   	pop    %ebp
  80259e:	c3                   	ret    

0080259f <devpipe_write>:
{
  80259f:	f3 0f 1e fb          	endbr32 
  8025a3:	55                   	push   %ebp
  8025a4:	89 e5                	mov    %esp,%ebp
  8025a6:	57                   	push   %edi
  8025a7:	56                   	push   %esi
  8025a8:	53                   	push   %ebx
  8025a9:	83 ec 28             	sub    $0x28,%esp
  8025ac:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8025af:	56                   	push   %esi
  8025b0:	e8 e1 eb ff ff       	call   801196 <fd2data>
  8025b5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8025b7:	83 c4 10             	add    $0x10,%esp
  8025ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8025bf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025c2:	74 4f                	je     802613 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025c4:	8b 43 04             	mov    0x4(%ebx),%eax
  8025c7:	8b 0b                	mov    (%ebx),%ecx
  8025c9:	8d 51 20             	lea    0x20(%ecx),%edx
  8025cc:	39 d0                	cmp    %edx,%eax
  8025ce:	72 14                	jb     8025e4 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8025d0:	89 da                	mov    %ebx,%edx
  8025d2:	89 f0                	mov    %esi,%eax
  8025d4:	e8 61 ff ff ff       	call   80253a <_pipeisclosed>
  8025d9:	85 c0                	test   %eax,%eax
  8025db:	75 3b                	jne    802618 <devpipe_write+0x79>
			sys_yield();
  8025dd:	e8 59 e7 ff ff       	call   800d3b <sys_yield>
  8025e2:	eb e0                	jmp    8025c4 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025e7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8025eb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8025ee:	89 c2                	mov    %eax,%edx
  8025f0:	c1 fa 1f             	sar    $0x1f,%edx
  8025f3:	89 d1                	mov    %edx,%ecx
  8025f5:	c1 e9 1b             	shr    $0x1b,%ecx
  8025f8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8025fb:	83 e2 1f             	and    $0x1f,%edx
  8025fe:	29 ca                	sub    %ecx,%edx
  802600:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802604:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802608:	83 c0 01             	add    $0x1,%eax
  80260b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80260e:	83 c7 01             	add    $0x1,%edi
  802611:	eb ac                	jmp    8025bf <devpipe_write+0x20>
	return i;
  802613:	8b 45 10             	mov    0x10(%ebp),%eax
  802616:	eb 05                	jmp    80261d <devpipe_write+0x7e>
				return 0;
  802618:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80261d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802620:	5b                   	pop    %ebx
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    

00802625 <devpipe_read>:
{
  802625:	f3 0f 1e fb          	endbr32 
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	57                   	push   %edi
  80262d:	56                   	push   %esi
  80262e:	53                   	push   %ebx
  80262f:	83 ec 18             	sub    $0x18,%esp
  802632:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802635:	57                   	push   %edi
  802636:	e8 5b eb ff ff       	call   801196 <fd2data>
  80263b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80263d:	83 c4 10             	add    $0x10,%esp
  802640:	be 00 00 00 00       	mov    $0x0,%esi
  802645:	3b 75 10             	cmp    0x10(%ebp),%esi
  802648:	75 14                	jne    80265e <devpipe_read+0x39>
	return i;
  80264a:	8b 45 10             	mov    0x10(%ebp),%eax
  80264d:	eb 02                	jmp    802651 <devpipe_read+0x2c>
				return i;
  80264f:	89 f0                	mov    %esi,%eax
}
  802651:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    
			sys_yield();
  802659:	e8 dd e6 ff ff       	call   800d3b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80265e:	8b 03                	mov    (%ebx),%eax
  802660:	3b 43 04             	cmp    0x4(%ebx),%eax
  802663:	75 18                	jne    80267d <devpipe_read+0x58>
			if (i > 0)
  802665:	85 f6                	test   %esi,%esi
  802667:	75 e6                	jne    80264f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802669:	89 da                	mov    %ebx,%edx
  80266b:	89 f8                	mov    %edi,%eax
  80266d:	e8 c8 fe ff ff       	call   80253a <_pipeisclosed>
  802672:	85 c0                	test   %eax,%eax
  802674:	74 e3                	je     802659 <devpipe_read+0x34>
				return 0;
  802676:	b8 00 00 00 00       	mov    $0x0,%eax
  80267b:	eb d4                	jmp    802651 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80267d:	99                   	cltd   
  80267e:	c1 ea 1b             	shr    $0x1b,%edx
  802681:	01 d0                	add    %edx,%eax
  802683:	83 e0 1f             	and    $0x1f,%eax
  802686:	29 d0                	sub    %edx,%eax
  802688:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80268d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802690:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802693:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802696:	83 c6 01             	add    $0x1,%esi
  802699:	eb aa                	jmp    802645 <devpipe_read+0x20>

0080269b <pipe>:
{
  80269b:	f3 0f 1e fb          	endbr32 
  80269f:	55                   	push   %ebp
  8026a0:	89 e5                	mov    %esp,%ebp
  8026a2:	56                   	push   %esi
  8026a3:	53                   	push   %ebx
  8026a4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8026a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026aa:	50                   	push   %eax
  8026ab:	e8 01 eb ff ff       	call   8011b1 <fd_alloc>
  8026b0:	89 c3                	mov    %eax,%ebx
  8026b2:	83 c4 10             	add    $0x10,%esp
  8026b5:	85 c0                	test   %eax,%eax
  8026b7:	0f 88 23 01 00 00    	js     8027e0 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026bd:	83 ec 04             	sub    $0x4,%esp
  8026c0:	68 07 04 00 00       	push   $0x407
  8026c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8026c8:	6a 00                	push   $0x0
  8026ca:	e8 8f e6 ff ff       	call   800d5e <sys_page_alloc>
  8026cf:	89 c3                	mov    %eax,%ebx
  8026d1:	83 c4 10             	add    $0x10,%esp
  8026d4:	85 c0                	test   %eax,%eax
  8026d6:	0f 88 04 01 00 00    	js     8027e0 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8026dc:	83 ec 0c             	sub    $0xc,%esp
  8026df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026e2:	50                   	push   %eax
  8026e3:	e8 c9 ea ff ff       	call   8011b1 <fd_alloc>
  8026e8:	89 c3                	mov    %eax,%ebx
  8026ea:	83 c4 10             	add    $0x10,%esp
  8026ed:	85 c0                	test   %eax,%eax
  8026ef:	0f 88 db 00 00 00    	js     8027d0 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026f5:	83 ec 04             	sub    $0x4,%esp
  8026f8:	68 07 04 00 00       	push   $0x407
  8026fd:	ff 75 f0             	pushl  -0x10(%ebp)
  802700:	6a 00                	push   $0x0
  802702:	e8 57 e6 ff ff       	call   800d5e <sys_page_alloc>
  802707:	89 c3                	mov    %eax,%ebx
  802709:	83 c4 10             	add    $0x10,%esp
  80270c:	85 c0                	test   %eax,%eax
  80270e:	0f 88 bc 00 00 00    	js     8027d0 <pipe+0x135>
	va = fd2data(fd0);
  802714:	83 ec 0c             	sub    $0xc,%esp
  802717:	ff 75 f4             	pushl  -0xc(%ebp)
  80271a:	e8 77 ea ff ff       	call   801196 <fd2data>
  80271f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802721:	83 c4 0c             	add    $0xc,%esp
  802724:	68 07 04 00 00       	push   $0x407
  802729:	50                   	push   %eax
  80272a:	6a 00                	push   $0x0
  80272c:	e8 2d e6 ff ff       	call   800d5e <sys_page_alloc>
  802731:	89 c3                	mov    %eax,%ebx
  802733:	83 c4 10             	add    $0x10,%esp
  802736:	85 c0                	test   %eax,%eax
  802738:	0f 88 82 00 00 00    	js     8027c0 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80273e:	83 ec 0c             	sub    $0xc,%esp
  802741:	ff 75 f0             	pushl  -0x10(%ebp)
  802744:	e8 4d ea ff ff       	call   801196 <fd2data>
  802749:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802750:	50                   	push   %eax
  802751:	6a 00                	push   $0x0
  802753:	56                   	push   %esi
  802754:	6a 00                	push   $0x0
  802756:	e8 29 e6 ff ff       	call   800d84 <sys_page_map>
  80275b:	89 c3                	mov    %eax,%ebx
  80275d:	83 c4 20             	add    $0x20,%esp
  802760:	85 c0                	test   %eax,%eax
  802762:	78 4e                	js     8027b2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802764:	a1 7c 40 80 00       	mov    0x80407c,%eax
  802769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80276c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80276e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802771:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802778:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80277b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80277d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802780:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802787:	83 ec 0c             	sub    $0xc,%esp
  80278a:	ff 75 f4             	pushl  -0xc(%ebp)
  80278d:	e8 f0 e9 ff ff       	call   801182 <fd2num>
  802792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802795:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802797:	83 c4 04             	add    $0x4,%esp
  80279a:	ff 75 f0             	pushl  -0x10(%ebp)
  80279d:	e8 e0 e9 ff ff       	call   801182 <fd2num>
  8027a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027a5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8027a8:	83 c4 10             	add    $0x10,%esp
  8027ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027b0:	eb 2e                	jmp    8027e0 <pipe+0x145>
	sys_page_unmap(0, va);
  8027b2:	83 ec 08             	sub    $0x8,%esp
  8027b5:	56                   	push   %esi
  8027b6:	6a 00                	push   $0x0
  8027b8:	e8 ec e5 ff ff       	call   800da9 <sys_page_unmap>
  8027bd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8027c0:	83 ec 08             	sub    $0x8,%esp
  8027c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8027c6:	6a 00                	push   $0x0
  8027c8:	e8 dc e5 ff ff       	call   800da9 <sys_page_unmap>
  8027cd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8027d0:	83 ec 08             	sub    $0x8,%esp
  8027d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8027d6:	6a 00                	push   $0x0
  8027d8:	e8 cc e5 ff ff       	call   800da9 <sys_page_unmap>
  8027dd:	83 c4 10             	add    $0x10,%esp
}
  8027e0:	89 d8                	mov    %ebx,%eax
  8027e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027e5:	5b                   	pop    %ebx
  8027e6:	5e                   	pop    %esi
  8027e7:	5d                   	pop    %ebp
  8027e8:	c3                   	ret    

008027e9 <pipeisclosed>:
{
  8027e9:	f3 0f 1e fb          	endbr32 
  8027ed:	55                   	push   %ebp
  8027ee:	89 e5                	mov    %esp,%ebp
  8027f0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027f6:	50                   	push   %eax
  8027f7:	ff 75 08             	pushl  0x8(%ebp)
  8027fa:	e8 08 ea ff ff       	call   801207 <fd_lookup>
  8027ff:	83 c4 10             	add    $0x10,%esp
  802802:	85 c0                	test   %eax,%eax
  802804:	78 18                	js     80281e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802806:	83 ec 0c             	sub    $0xc,%esp
  802809:	ff 75 f4             	pushl  -0xc(%ebp)
  80280c:	e8 85 e9 ff ff       	call   801196 <fd2data>
  802811:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802813:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802816:	e8 1f fd ff ff       	call   80253a <_pipeisclosed>
  80281b:	83 c4 10             	add    $0x10,%esp
}
  80281e:	c9                   	leave  
  80281f:	c3                   	ret    

00802820 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802820:	f3 0f 1e fb          	endbr32 
  802824:	55                   	push   %ebp
  802825:	89 e5                	mov    %esp,%ebp
  802827:	56                   	push   %esi
  802828:	53                   	push   %ebx
  802829:	8b 75 08             	mov    0x8(%ebp),%esi
	// cprintf("[%08x] called wait for child %08x\n", thisenv->env_id, envid);
	const volatile struct Env *e;

	assert(envid != 0);
  80282c:	85 f6                	test   %esi,%esi
  80282e:	74 13                	je     802843 <wait+0x23>
	e = &envs[ENVX(envid)];
  802830:	89 f3                	mov    %esi,%ebx
  802832:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802838:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80283b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802841:	eb 1b                	jmp    80285e <wait+0x3e>
	assert(envid != 0);
  802843:	68 6a 35 80 00       	push   $0x80356a
  802848:	68 d3 33 80 00       	push   $0x8033d3
  80284d:	6a 0a                	push   $0xa
  80284f:	68 75 35 80 00       	push   $0x803575
  802854:	e8 ab d9 ff ff       	call   800204 <_panic>
		sys_yield();
  802859:	e8 dd e4 ff ff       	call   800d3b <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80285e:	8b 43 48             	mov    0x48(%ebx),%eax
  802861:	39 f0                	cmp    %esi,%eax
  802863:	75 07                	jne    80286c <wait+0x4c>
  802865:	8b 43 54             	mov    0x54(%ebx),%eax
  802868:	85 c0                	test   %eax,%eax
  80286a:	75 ed                	jne    802859 <wait+0x39>
}
  80286c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80286f:	5b                   	pop    %ebx
  802870:	5e                   	pop    %esi
  802871:	5d                   	pop    %ebp
  802872:	c3                   	ret    

00802873 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802873:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802877:	b8 00 00 00 00       	mov    $0x0,%eax
  80287c:	c3                   	ret    

0080287d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80287d:	f3 0f 1e fb          	endbr32 
  802881:	55                   	push   %ebp
  802882:	89 e5                	mov    %esp,%ebp
  802884:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802887:	68 80 35 80 00       	push   $0x803580
  80288c:	ff 75 0c             	pushl  0xc(%ebp)
  80288f:	e8 61 e0 ff ff       	call   8008f5 <strcpy>
	return 0;
}
  802894:	b8 00 00 00 00       	mov    $0x0,%eax
  802899:	c9                   	leave  
  80289a:	c3                   	ret    

0080289b <devcons_write>:
{
  80289b:	f3 0f 1e fb          	endbr32 
  80289f:	55                   	push   %ebp
  8028a0:	89 e5                	mov    %esp,%ebp
  8028a2:	57                   	push   %edi
  8028a3:	56                   	push   %esi
  8028a4:	53                   	push   %ebx
  8028a5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8028ab:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8028b0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8028b6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8028b9:	73 31                	jae    8028ec <devcons_write+0x51>
		m = n - tot;
  8028bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028be:	29 f3                	sub    %esi,%ebx
  8028c0:	83 fb 7f             	cmp    $0x7f,%ebx
  8028c3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8028c8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8028cb:	83 ec 04             	sub    $0x4,%esp
  8028ce:	53                   	push   %ebx
  8028cf:	89 f0                	mov    %esi,%eax
  8028d1:	03 45 0c             	add    0xc(%ebp),%eax
  8028d4:	50                   	push   %eax
  8028d5:	57                   	push   %edi
  8028d6:	e8 18 e2 ff ff       	call   800af3 <memmove>
		sys_cputs(buf, m);
  8028db:	83 c4 08             	add    $0x8,%esp
  8028de:	53                   	push   %ebx
  8028df:	57                   	push   %edi
  8028e0:	e8 ca e3 ff ff       	call   800caf <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8028e5:	01 de                	add    %ebx,%esi
  8028e7:	83 c4 10             	add    $0x10,%esp
  8028ea:	eb ca                	jmp    8028b6 <devcons_write+0x1b>
}
  8028ec:	89 f0                	mov    %esi,%eax
  8028ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028f1:	5b                   	pop    %ebx
  8028f2:	5e                   	pop    %esi
  8028f3:	5f                   	pop    %edi
  8028f4:	5d                   	pop    %ebp
  8028f5:	c3                   	ret    

008028f6 <devcons_read>:
{
  8028f6:	f3 0f 1e fb          	endbr32 
  8028fa:	55                   	push   %ebp
  8028fb:	89 e5                	mov    %esp,%ebp
  8028fd:	83 ec 08             	sub    $0x8,%esp
  802900:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802905:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802909:	74 21                	je     80292c <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80290b:	e8 c1 e3 ff ff       	call   800cd1 <sys_cgetc>
  802910:	85 c0                	test   %eax,%eax
  802912:	75 07                	jne    80291b <devcons_read+0x25>
		sys_yield();
  802914:	e8 22 e4 ff ff       	call   800d3b <sys_yield>
  802919:	eb f0                	jmp    80290b <devcons_read+0x15>
	if (c < 0)
  80291b:	78 0f                	js     80292c <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80291d:	83 f8 04             	cmp    $0x4,%eax
  802920:	74 0c                	je     80292e <devcons_read+0x38>
	*(char*)vbuf = c;
  802922:	8b 55 0c             	mov    0xc(%ebp),%edx
  802925:	88 02                	mov    %al,(%edx)
	return 1;
  802927:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80292c:	c9                   	leave  
  80292d:	c3                   	ret    
		return 0;
  80292e:	b8 00 00 00 00       	mov    $0x0,%eax
  802933:	eb f7                	jmp    80292c <devcons_read+0x36>

00802935 <cputchar>:
{
  802935:	f3 0f 1e fb          	endbr32 
  802939:	55                   	push   %ebp
  80293a:	89 e5                	mov    %esp,%ebp
  80293c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80293f:	8b 45 08             	mov    0x8(%ebp),%eax
  802942:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802945:	6a 01                	push   $0x1
  802947:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80294a:	50                   	push   %eax
  80294b:	e8 5f e3 ff ff       	call   800caf <sys_cputs>
}
  802950:	83 c4 10             	add    $0x10,%esp
  802953:	c9                   	leave  
  802954:	c3                   	ret    

00802955 <getchar>:
{
  802955:	f3 0f 1e fb          	endbr32 
  802959:	55                   	push   %ebp
  80295a:	89 e5                	mov    %esp,%ebp
  80295c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80295f:	6a 01                	push   $0x1
  802961:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802964:	50                   	push   %eax
  802965:	6a 00                	push   $0x0
  802967:	e8 23 eb ff ff       	call   80148f <read>
	if (r < 0)
  80296c:	83 c4 10             	add    $0x10,%esp
  80296f:	85 c0                	test   %eax,%eax
  802971:	78 06                	js     802979 <getchar+0x24>
	if (r < 1)
  802973:	74 06                	je     80297b <getchar+0x26>
	return c;
  802975:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802979:	c9                   	leave  
  80297a:	c3                   	ret    
		return -E_EOF;
  80297b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802980:	eb f7                	jmp    802979 <getchar+0x24>

00802982 <iscons>:
{
  802982:	f3 0f 1e fb          	endbr32 
  802986:	55                   	push   %ebp
  802987:	89 e5                	mov    %esp,%ebp
  802989:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80298c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80298f:	50                   	push   %eax
  802990:	ff 75 08             	pushl  0x8(%ebp)
  802993:	e8 6f e8 ff ff       	call   801207 <fd_lookup>
  802998:	83 c4 10             	add    $0x10,%esp
  80299b:	85 c0                	test   %eax,%eax
  80299d:	78 11                	js     8029b0 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80299f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029a2:	8b 15 98 40 80 00    	mov    0x804098,%edx
  8029a8:	39 10                	cmp    %edx,(%eax)
  8029aa:	0f 94 c0             	sete   %al
  8029ad:	0f b6 c0             	movzbl %al,%eax
}
  8029b0:	c9                   	leave  
  8029b1:	c3                   	ret    

008029b2 <opencons>:
{
  8029b2:	f3 0f 1e fb          	endbr32 
  8029b6:	55                   	push   %ebp
  8029b7:	89 e5                	mov    %esp,%ebp
  8029b9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8029bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029bf:	50                   	push   %eax
  8029c0:	e8 ec e7 ff ff       	call   8011b1 <fd_alloc>
  8029c5:	83 c4 10             	add    $0x10,%esp
  8029c8:	85 c0                	test   %eax,%eax
  8029ca:	78 3a                	js     802a06 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8029cc:	83 ec 04             	sub    $0x4,%esp
  8029cf:	68 07 04 00 00       	push   $0x407
  8029d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8029d7:	6a 00                	push   $0x0
  8029d9:	e8 80 e3 ff ff       	call   800d5e <sys_page_alloc>
  8029de:	83 c4 10             	add    $0x10,%esp
  8029e1:	85 c0                	test   %eax,%eax
  8029e3:	78 21                	js     802a06 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8029e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029e8:	8b 15 98 40 80 00    	mov    0x804098,%edx
  8029ee:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8029f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029f3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8029fa:	83 ec 0c             	sub    $0xc,%esp
  8029fd:	50                   	push   %eax
  8029fe:	e8 7f e7 ff ff       	call   801182 <fd2num>
  802a03:	83 c4 10             	add    $0x10,%esp
}
  802a06:	c9                   	leave  
  802a07:	c3                   	ret    

00802a08 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a08:	f3 0f 1e fb          	endbr32 
  802a0c:	55                   	push   %ebp
  802a0d:	89 e5                	mov    %esp,%ebp
  802a0f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802a12:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802a19:	74 0a                	je     802a25 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  802a1e:	a3 00 80 80 00       	mov    %eax,0x808000

}
  802a23:	c9                   	leave  
  802a24:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  802a25:	83 ec 04             	sub    $0x4,%esp
  802a28:	6a 07                	push   $0x7
  802a2a:	68 00 f0 bf ee       	push   $0xeebff000
  802a2f:	6a 00                	push   $0x0
  802a31:	e8 28 e3 ff ff       	call   800d5e <sys_page_alloc>
  802a36:	83 c4 10             	add    $0x10,%esp
  802a39:	85 c0                	test   %eax,%eax
  802a3b:	78 2a                	js     802a67 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802a3d:	83 ec 08             	sub    $0x8,%esp
  802a40:	68 7b 2a 80 00       	push   $0x802a7b
  802a45:	6a 00                	push   $0x0
  802a47:	e8 cc e3 ff ff       	call   800e18 <sys_env_set_pgfault_upcall>
  802a4c:	83 c4 10             	add    $0x10,%esp
  802a4f:	85 c0                	test   %eax,%eax
  802a51:	79 c8                	jns    802a1b <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802a53:	83 ec 04             	sub    $0x4,%esp
  802a56:	68 b8 35 80 00       	push   $0x8035b8
  802a5b:	6a 2c                	push   $0x2c
  802a5d:	68 ee 35 80 00       	push   $0x8035ee
  802a62:	e8 9d d7 ff ff       	call   800204 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802a67:	83 ec 04             	sub    $0x4,%esp
  802a6a:	68 8c 35 80 00       	push   $0x80358c
  802a6f:	6a 22                	push   $0x22
  802a71:	68 ee 35 80 00       	push   $0x8035ee
  802a76:	e8 89 d7 ff ff       	call   800204 <_panic>

00802a7b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a7b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a7c:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax   			// 间接寻址
  802a81:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a83:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802a86:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802a8a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802a8f:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802a93:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802a95:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802a98:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802a99:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802a9c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802a9d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  802a9e:	c3                   	ret    

00802a9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a9f:	f3 0f 1e fb          	endbr32 
  802aa3:	55                   	push   %ebp
  802aa4:	89 e5                	mov    %esp,%ebp
  802aa6:	56                   	push   %esi
  802aa7:	53                   	push   %ebx
  802aa8:	8b 75 08             	mov    0x8(%ebp),%esi
  802aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  802aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802ab1:	85 c0                	test   %eax,%eax
  802ab3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802ab8:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802abb:	83 ec 0c             	sub    $0xc,%esp
  802abe:	50                   	push   %eax
  802abf:	e8 a0 e3 ff ff       	call   800e64 <sys_ipc_recv>
  802ac4:	83 c4 10             	add    $0x10,%esp
  802ac7:	85 c0                	test   %eax,%eax
  802ac9:	75 2b                	jne    802af6 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802acb:	85 f6                	test   %esi,%esi
  802acd:	74 0a                	je     802ad9 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  802acf:	a1 08 50 80 00       	mov    0x805008,%eax
  802ad4:	8b 40 74             	mov    0x74(%eax),%eax
  802ad7:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802ad9:	85 db                	test   %ebx,%ebx
  802adb:	74 0a                	je     802ae7 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  802add:	a1 08 50 80 00       	mov    0x805008,%eax
  802ae2:	8b 40 78             	mov    0x78(%eax),%eax
  802ae5:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802ae7:	a1 08 50 80 00       	mov    0x805008,%eax
  802aec:	8b 40 70             	mov    0x70(%eax),%eax
}
  802aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802af2:	5b                   	pop    %ebx
  802af3:	5e                   	pop    %esi
  802af4:	5d                   	pop    %ebp
  802af5:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802af6:	85 f6                	test   %esi,%esi
  802af8:	74 06                	je     802b00 <ipc_recv+0x61>
  802afa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  802b00:	85 db                	test   %ebx,%ebx
  802b02:	74 eb                	je     802aef <ipc_recv+0x50>
  802b04:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802b0a:	eb e3                	jmp    802aef <ipc_recv+0x50>

00802b0c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b0c:	f3 0f 1e fb          	endbr32 
  802b10:	55                   	push   %ebp
  802b11:	89 e5                	mov    %esp,%ebp
  802b13:	57                   	push   %edi
  802b14:	56                   	push   %esi
  802b15:	53                   	push   %ebx
  802b16:	83 ec 0c             	sub    $0xc,%esp
  802b19:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802b22:	85 db                	test   %ebx,%ebx
  802b24:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b29:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802b2c:	ff 75 14             	pushl  0x14(%ebp)
  802b2f:	53                   	push   %ebx
  802b30:	56                   	push   %esi
  802b31:	57                   	push   %edi
  802b32:	e8 06 e3 ff ff       	call   800e3d <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802b37:	83 c4 10             	add    $0x10,%esp
  802b3a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b3d:	75 07                	jne    802b46 <ipc_send+0x3a>
			sys_yield();
  802b3f:	e8 f7 e1 ff ff       	call   800d3b <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802b44:	eb e6                	jmp    802b2c <ipc_send+0x20>
		}
		else if (ret == 0)
  802b46:	85 c0                	test   %eax,%eax
  802b48:	75 08                	jne    802b52 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  802b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b4d:	5b                   	pop    %ebx
  802b4e:	5e                   	pop    %esi
  802b4f:	5f                   	pop    %edi
  802b50:	5d                   	pop    %ebp
  802b51:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802b52:	50                   	push   %eax
  802b53:	68 fc 35 80 00       	push   $0x8035fc
  802b58:	6a 48                	push   $0x48
  802b5a:	68 0a 36 80 00       	push   $0x80360a
  802b5f:	e8 a0 d6 ff ff       	call   800204 <_panic>

00802b64 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b64:	f3 0f 1e fb          	endbr32 
  802b68:	55                   	push   %ebp
  802b69:	89 e5                	mov    %esp,%ebp
  802b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b6e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b73:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802b76:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b7c:	8b 52 50             	mov    0x50(%edx),%edx
  802b7f:	39 ca                	cmp    %ecx,%edx
  802b81:	74 11                	je     802b94 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802b83:	83 c0 01             	add    $0x1,%eax
  802b86:	3d 00 04 00 00       	cmp    $0x400,%eax
  802b8b:	75 e6                	jne    802b73 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  802b92:	eb 0b                	jmp    802b9f <ipc_find_env+0x3b>
			return envs[i].env_id;
  802b94:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802b97:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802b9c:	8b 40 48             	mov    0x48(%eax),%eax
}
  802b9f:	5d                   	pop    %ebp
  802ba0:	c3                   	ret    

00802ba1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ba1:	f3 0f 1e fb          	endbr32 
  802ba5:	55                   	push   %ebp
  802ba6:	89 e5                	mov    %esp,%ebp
  802ba8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bab:	89 c2                	mov    %eax,%edx
  802bad:	c1 ea 16             	shr    $0x16,%edx
  802bb0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802bb7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802bbc:	f6 c1 01             	test   $0x1,%cl
  802bbf:	74 1c                	je     802bdd <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802bc1:	c1 e8 0c             	shr    $0xc,%eax
  802bc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802bcb:	a8 01                	test   $0x1,%al
  802bcd:	74 0e                	je     802bdd <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802bcf:	c1 e8 0c             	shr    $0xc,%eax
  802bd2:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802bd9:	ef 
  802bda:	0f b7 d2             	movzwl %dx,%edx
}
  802bdd:	89 d0                	mov    %edx,%eax
  802bdf:	5d                   	pop    %ebp
  802be0:	c3                   	ret    
  802be1:	66 90                	xchg   %ax,%ax
  802be3:	66 90                	xchg   %ax,%ax
  802be5:	66 90                	xchg   %ax,%ax
  802be7:	66 90                	xchg   %ax,%ax
  802be9:	66 90                	xchg   %ax,%ax
  802beb:	66 90                	xchg   %ax,%ax
  802bed:	66 90                	xchg   %ax,%ax
  802bef:	90                   	nop

00802bf0 <__udivdi3>:
  802bf0:	f3 0f 1e fb          	endbr32 
  802bf4:	55                   	push   %ebp
  802bf5:	57                   	push   %edi
  802bf6:	56                   	push   %esi
  802bf7:	53                   	push   %ebx
  802bf8:	83 ec 1c             	sub    $0x1c,%esp
  802bfb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802bff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802c03:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802c0b:	85 d2                	test   %edx,%edx
  802c0d:	75 19                	jne    802c28 <__udivdi3+0x38>
  802c0f:	39 f3                	cmp    %esi,%ebx
  802c11:	76 4d                	jbe    802c60 <__udivdi3+0x70>
  802c13:	31 ff                	xor    %edi,%edi
  802c15:	89 e8                	mov    %ebp,%eax
  802c17:	89 f2                	mov    %esi,%edx
  802c19:	f7 f3                	div    %ebx
  802c1b:	89 fa                	mov    %edi,%edx
  802c1d:	83 c4 1c             	add    $0x1c,%esp
  802c20:	5b                   	pop    %ebx
  802c21:	5e                   	pop    %esi
  802c22:	5f                   	pop    %edi
  802c23:	5d                   	pop    %ebp
  802c24:	c3                   	ret    
  802c25:	8d 76 00             	lea    0x0(%esi),%esi
  802c28:	39 f2                	cmp    %esi,%edx
  802c2a:	76 14                	jbe    802c40 <__udivdi3+0x50>
  802c2c:	31 ff                	xor    %edi,%edi
  802c2e:	31 c0                	xor    %eax,%eax
  802c30:	89 fa                	mov    %edi,%edx
  802c32:	83 c4 1c             	add    $0x1c,%esp
  802c35:	5b                   	pop    %ebx
  802c36:	5e                   	pop    %esi
  802c37:	5f                   	pop    %edi
  802c38:	5d                   	pop    %ebp
  802c39:	c3                   	ret    
  802c3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c40:	0f bd fa             	bsr    %edx,%edi
  802c43:	83 f7 1f             	xor    $0x1f,%edi
  802c46:	75 48                	jne    802c90 <__udivdi3+0xa0>
  802c48:	39 f2                	cmp    %esi,%edx
  802c4a:	72 06                	jb     802c52 <__udivdi3+0x62>
  802c4c:	31 c0                	xor    %eax,%eax
  802c4e:	39 eb                	cmp    %ebp,%ebx
  802c50:	77 de                	ja     802c30 <__udivdi3+0x40>
  802c52:	b8 01 00 00 00       	mov    $0x1,%eax
  802c57:	eb d7                	jmp    802c30 <__udivdi3+0x40>
  802c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c60:	89 d9                	mov    %ebx,%ecx
  802c62:	85 db                	test   %ebx,%ebx
  802c64:	75 0b                	jne    802c71 <__udivdi3+0x81>
  802c66:	b8 01 00 00 00       	mov    $0x1,%eax
  802c6b:	31 d2                	xor    %edx,%edx
  802c6d:	f7 f3                	div    %ebx
  802c6f:	89 c1                	mov    %eax,%ecx
  802c71:	31 d2                	xor    %edx,%edx
  802c73:	89 f0                	mov    %esi,%eax
  802c75:	f7 f1                	div    %ecx
  802c77:	89 c6                	mov    %eax,%esi
  802c79:	89 e8                	mov    %ebp,%eax
  802c7b:	89 f7                	mov    %esi,%edi
  802c7d:	f7 f1                	div    %ecx
  802c7f:	89 fa                	mov    %edi,%edx
  802c81:	83 c4 1c             	add    $0x1c,%esp
  802c84:	5b                   	pop    %ebx
  802c85:	5e                   	pop    %esi
  802c86:	5f                   	pop    %edi
  802c87:	5d                   	pop    %ebp
  802c88:	c3                   	ret    
  802c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c90:	89 f9                	mov    %edi,%ecx
  802c92:	b8 20 00 00 00       	mov    $0x20,%eax
  802c97:	29 f8                	sub    %edi,%eax
  802c99:	d3 e2                	shl    %cl,%edx
  802c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  802c9f:	89 c1                	mov    %eax,%ecx
  802ca1:	89 da                	mov    %ebx,%edx
  802ca3:	d3 ea                	shr    %cl,%edx
  802ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ca9:	09 d1                	or     %edx,%ecx
  802cab:	89 f2                	mov    %esi,%edx
  802cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cb1:	89 f9                	mov    %edi,%ecx
  802cb3:	d3 e3                	shl    %cl,%ebx
  802cb5:	89 c1                	mov    %eax,%ecx
  802cb7:	d3 ea                	shr    %cl,%edx
  802cb9:	89 f9                	mov    %edi,%ecx
  802cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802cbf:	89 eb                	mov    %ebp,%ebx
  802cc1:	d3 e6                	shl    %cl,%esi
  802cc3:	89 c1                	mov    %eax,%ecx
  802cc5:	d3 eb                	shr    %cl,%ebx
  802cc7:	09 de                	or     %ebx,%esi
  802cc9:	89 f0                	mov    %esi,%eax
  802ccb:	f7 74 24 08          	divl   0x8(%esp)
  802ccf:	89 d6                	mov    %edx,%esi
  802cd1:	89 c3                	mov    %eax,%ebx
  802cd3:	f7 64 24 0c          	mull   0xc(%esp)
  802cd7:	39 d6                	cmp    %edx,%esi
  802cd9:	72 15                	jb     802cf0 <__udivdi3+0x100>
  802cdb:	89 f9                	mov    %edi,%ecx
  802cdd:	d3 e5                	shl    %cl,%ebp
  802cdf:	39 c5                	cmp    %eax,%ebp
  802ce1:	73 04                	jae    802ce7 <__udivdi3+0xf7>
  802ce3:	39 d6                	cmp    %edx,%esi
  802ce5:	74 09                	je     802cf0 <__udivdi3+0x100>
  802ce7:	89 d8                	mov    %ebx,%eax
  802ce9:	31 ff                	xor    %edi,%edi
  802ceb:	e9 40 ff ff ff       	jmp    802c30 <__udivdi3+0x40>
  802cf0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802cf3:	31 ff                	xor    %edi,%edi
  802cf5:	e9 36 ff ff ff       	jmp    802c30 <__udivdi3+0x40>
  802cfa:	66 90                	xchg   %ax,%ax
  802cfc:	66 90                	xchg   %ax,%ax
  802cfe:	66 90                	xchg   %ax,%ax

00802d00 <__umoddi3>:
  802d00:	f3 0f 1e fb          	endbr32 
  802d04:	55                   	push   %ebp
  802d05:	57                   	push   %edi
  802d06:	56                   	push   %esi
  802d07:	53                   	push   %ebx
  802d08:	83 ec 1c             	sub    $0x1c,%esp
  802d0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802d0f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802d13:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802d17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802d1b:	85 c0                	test   %eax,%eax
  802d1d:	75 19                	jne    802d38 <__umoddi3+0x38>
  802d1f:	39 df                	cmp    %ebx,%edi
  802d21:	76 5d                	jbe    802d80 <__umoddi3+0x80>
  802d23:	89 f0                	mov    %esi,%eax
  802d25:	89 da                	mov    %ebx,%edx
  802d27:	f7 f7                	div    %edi
  802d29:	89 d0                	mov    %edx,%eax
  802d2b:	31 d2                	xor    %edx,%edx
  802d2d:	83 c4 1c             	add    $0x1c,%esp
  802d30:	5b                   	pop    %ebx
  802d31:	5e                   	pop    %esi
  802d32:	5f                   	pop    %edi
  802d33:	5d                   	pop    %ebp
  802d34:	c3                   	ret    
  802d35:	8d 76 00             	lea    0x0(%esi),%esi
  802d38:	89 f2                	mov    %esi,%edx
  802d3a:	39 d8                	cmp    %ebx,%eax
  802d3c:	76 12                	jbe    802d50 <__umoddi3+0x50>
  802d3e:	89 f0                	mov    %esi,%eax
  802d40:	89 da                	mov    %ebx,%edx
  802d42:	83 c4 1c             	add    $0x1c,%esp
  802d45:	5b                   	pop    %ebx
  802d46:	5e                   	pop    %esi
  802d47:	5f                   	pop    %edi
  802d48:	5d                   	pop    %ebp
  802d49:	c3                   	ret    
  802d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d50:	0f bd e8             	bsr    %eax,%ebp
  802d53:	83 f5 1f             	xor    $0x1f,%ebp
  802d56:	75 50                	jne    802da8 <__umoddi3+0xa8>
  802d58:	39 d8                	cmp    %ebx,%eax
  802d5a:	0f 82 e0 00 00 00    	jb     802e40 <__umoddi3+0x140>
  802d60:	89 d9                	mov    %ebx,%ecx
  802d62:	39 f7                	cmp    %esi,%edi
  802d64:	0f 86 d6 00 00 00    	jbe    802e40 <__umoddi3+0x140>
  802d6a:	89 d0                	mov    %edx,%eax
  802d6c:	89 ca                	mov    %ecx,%edx
  802d6e:	83 c4 1c             	add    $0x1c,%esp
  802d71:	5b                   	pop    %ebx
  802d72:	5e                   	pop    %esi
  802d73:	5f                   	pop    %edi
  802d74:	5d                   	pop    %ebp
  802d75:	c3                   	ret    
  802d76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d7d:	8d 76 00             	lea    0x0(%esi),%esi
  802d80:	89 fd                	mov    %edi,%ebp
  802d82:	85 ff                	test   %edi,%edi
  802d84:	75 0b                	jne    802d91 <__umoddi3+0x91>
  802d86:	b8 01 00 00 00       	mov    $0x1,%eax
  802d8b:	31 d2                	xor    %edx,%edx
  802d8d:	f7 f7                	div    %edi
  802d8f:	89 c5                	mov    %eax,%ebp
  802d91:	89 d8                	mov    %ebx,%eax
  802d93:	31 d2                	xor    %edx,%edx
  802d95:	f7 f5                	div    %ebp
  802d97:	89 f0                	mov    %esi,%eax
  802d99:	f7 f5                	div    %ebp
  802d9b:	89 d0                	mov    %edx,%eax
  802d9d:	31 d2                	xor    %edx,%edx
  802d9f:	eb 8c                	jmp    802d2d <__umoddi3+0x2d>
  802da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802da8:	89 e9                	mov    %ebp,%ecx
  802daa:	ba 20 00 00 00       	mov    $0x20,%edx
  802daf:	29 ea                	sub    %ebp,%edx
  802db1:	d3 e0                	shl    %cl,%eax
  802db3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802db7:	89 d1                	mov    %edx,%ecx
  802db9:	89 f8                	mov    %edi,%eax
  802dbb:	d3 e8                	shr    %cl,%eax
  802dbd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  802dc5:	8b 54 24 04          	mov    0x4(%esp),%edx
  802dc9:	09 c1                	or     %eax,%ecx
  802dcb:	89 d8                	mov    %ebx,%eax
  802dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802dd1:	89 e9                	mov    %ebp,%ecx
  802dd3:	d3 e7                	shl    %cl,%edi
  802dd5:	89 d1                	mov    %edx,%ecx
  802dd7:	d3 e8                	shr    %cl,%eax
  802dd9:	89 e9                	mov    %ebp,%ecx
  802ddb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802ddf:	d3 e3                	shl    %cl,%ebx
  802de1:	89 c7                	mov    %eax,%edi
  802de3:	89 d1                	mov    %edx,%ecx
  802de5:	89 f0                	mov    %esi,%eax
  802de7:	d3 e8                	shr    %cl,%eax
  802de9:	89 e9                	mov    %ebp,%ecx
  802deb:	89 fa                	mov    %edi,%edx
  802ded:	d3 e6                	shl    %cl,%esi
  802def:	09 d8                	or     %ebx,%eax
  802df1:	f7 74 24 08          	divl   0x8(%esp)
  802df5:	89 d1                	mov    %edx,%ecx
  802df7:	89 f3                	mov    %esi,%ebx
  802df9:	f7 64 24 0c          	mull   0xc(%esp)
  802dfd:	89 c6                	mov    %eax,%esi
  802dff:	89 d7                	mov    %edx,%edi
  802e01:	39 d1                	cmp    %edx,%ecx
  802e03:	72 06                	jb     802e0b <__umoddi3+0x10b>
  802e05:	75 10                	jne    802e17 <__umoddi3+0x117>
  802e07:	39 c3                	cmp    %eax,%ebx
  802e09:	73 0c                	jae    802e17 <__umoddi3+0x117>
  802e0b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802e0f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802e13:	89 d7                	mov    %edx,%edi
  802e15:	89 c6                	mov    %eax,%esi
  802e17:	89 ca                	mov    %ecx,%edx
  802e19:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e1e:	29 f3                	sub    %esi,%ebx
  802e20:	19 fa                	sbb    %edi,%edx
  802e22:	89 d0                	mov    %edx,%eax
  802e24:	d3 e0                	shl    %cl,%eax
  802e26:	89 e9                	mov    %ebp,%ecx
  802e28:	d3 eb                	shr    %cl,%ebx
  802e2a:	d3 ea                	shr    %cl,%edx
  802e2c:	09 d8                	or     %ebx,%eax
  802e2e:	83 c4 1c             	add    $0x1c,%esp
  802e31:	5b                   	pop    %ebx
  802e32:	5e                   	pop    %esi
  802e33:	5f                   	pop    %edi
  802e34:	5d                   	pop    %ebp
  802e35:	c3                   	ret    
  802e36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802e3d:	8d 76 00             	lea    0x0(%esi),%esi
  802e40:	29 fe                	sub    %edi,%esi
  802e42:	19 c3                	sbb    %eax,%ebx
  802e44:	89 f2                	mov    %esi,%edx
  802e46:	89 d9                	mov    %ebx,%ecx
  802e48:	e9 1d ff ff ff       	jmp    802d6a <__umoddi3+0x6a>
