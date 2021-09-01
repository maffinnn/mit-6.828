
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 77 01 00 00       	call   8001a8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003d:	e8 71 0f 00 00       	call   800fb3 <fork>
  800042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	0f 84 a5 00 00 00    	je     8000f2 <umain+0xbf>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80004d:	a1 08 40 80 00       	mov    0x804008,%eax
  800052:	8b 40 48             	mov    0x48(%eax),%eax
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 a0 00       	push   $0xa00000
  80005f:	50                   	push   %eax
  800060:	e8 bb 0c 00 00       	call   800d20 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 30 80 00    	pushl  0x803004
  80006e:	e8 01 08 00 00       	call   800874 <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 30 80 00    	pushl  0x803004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 91 0a 00 00       	call   800b1b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80008a:	6a 07                	push   $0x7
  80008c:	68 00 00 a0 00       	push   $0xa00000
  800091:	6a 00                	push   $0x0
  800093:	ff 75 f4             	pushl  -0xc(%ebp)
  800096:	e8 16 11 00 00       	call   8011b1 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80009b:	83 c4 1c             	add    $0x1c,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	68 00 00 a0 00       	push   $0xa00000
  8000a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a8:	50                   	push   %eax
  8000a9:	e8 96 10 00 00       	call   801144 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000ae:	83 c4 0c             	add    $0xc,%esp
  8000b1:	68 00 00 a0 00       	push   $0xa00000
  8000b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8000b9:	68 e0 27 80 00       	push   $0x8027e0
  8000be:	e8 ea 01 00 00       	call   8002ad <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000c3:	83 c4 04             	add    $0x4,%esp
  8000c6:	ff 35 00 30 80 00    	pushl  0x803000
  8000cc:	e8 a3 07 00 00       	call   800874 <strlen>
  8000d1:	83 c4 0c             	add    $0xc,%esp
  8000d4:	50                   	push   %eax
  8000d5:	ff 35 00 30 80 00    	pushl  0x803000
  8000db:	68 00 00 a0 00       	push   $0xa00000
  8000e0:	e8 bb 08 00 00       	call   8009a0 <strncmp>
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	0f 84 a3 00 00 00    	je     800193 <umain+0x160>
		cprintf("parent received correct message\n");
	return;
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000f2:	83 ec 04             	sub    $0x4,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	68 00 00 b0 00       	push   $0xb00000
  8000fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ff:	50                   	push   %eax
  800100:	e8 3f 10 00 00       	call   801144 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	68 00 00 b0 00       	push   $0xb00000
  80010d:	ff 75 f4             	pushl  -0xc(%ebp)
  800110:	68 e0 27 80 00       	push   $0x8027e0
  800115:	e8 93 01 00 00       	call   8002ad <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 04 30 80 00    	pushl  0x803004
  800123:	e8 4c 07 00 00       	call   800874 <strlen>
  800128:	83 c4 0c             	add    $0xc,%esp
  80012b:	50                   	push   %eax
  80012c:	ff 35 04 30 80 00    	pushl  0x803004
  800132:	68 00 00 b0 00       	push   $0xb00000
  800137:	e8 64 08 00 00       	call   8009a0 <strncmp>
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	85 c0                	test   %eax,%eax
  800141:	74 3e                	je     800181 <umain+0x14e>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  800143:	83 ec 0c             	sub    $0xc,%esp
  800146:	ff 35 00 30 80 00    	pushl  0x803000
  80014c:	e8 23 07 00 00       	call   800874 <strlen>
  800151:	83 c4 0c             	add    $0xc,%esp
  800154:	83 c0 01             	add    $0x1,%eax
  800157:	50                   	push   %eax
  800158:	ff 35 00 30 80 00    	pushl  0x803000
  80015e:	68 00 00 b0 00       	push   $0xb00000
  800163:	e8 b3 09 00 00       	call   800b1b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800168:	6a 07                	push   $0x7
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	6a 00                	push   $0x0
  800171:	ff 75 f4             	pushl  -0xc(%ebp)
  800174:	e8 38 10 00 00       	call   8011b1 <ipc_send>
		return;
  800179:	83 c4 20             	add    $0x20,%esp
  80017c:	e9 6f ff ff ff       	jmp    8000f0 <umain+0xbd>
			cprintf("child received correct message\n");
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	68 f4 27 80 00       	push   $0x8027f4
  800189:	e8 1f 01 00 00       	call   8002ad <cprintf>
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	eb b0                	jmp    800143 <umain+0x110>
		cprintf("parent received correct message\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 14 28 80 00       	push   $0x802814
  80019b:	e8 0d 01 00 00       	call   8002ad <cprintf>
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	e9 48 ff ff ff       	jmp    8000f0 <umain+0xbd>

008001a8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001a8:	f3 0f 1e fb          	endbr32 
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001b7:	e8 1e 0b 00 00       	call   800cda <sys_getenvid>
  8001bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c9:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ce:	85 db                	test   %ebx,%ebx
  8001d0:	7e 07                	jle    8001d9 <libmain+0x31>
		binaryname = argv[0];
  8001d2:	8b 06                	mov    (%esi),%eax
  8001d4:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	e8 50 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001e3:	e8 0a 00 00 00       	call   8001f2 <exit>
}
  8001e8:	83 c4 10             	add    $0x10,%esp
  8001eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    

008001f2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001f2:	f3 0f 1e fb          	endbr32 
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  8001fc:	e8 39 12 00 00       	call   80143a <close_all>
	sys_env_destroy(0);
  800201:	83 ec 0c             	sub    $0xc,%esp
  800204:	6a 00                	push   $0x0
  800206:	e8 ab 0a 00 00       	call   800cb6 <sys_env_destroy>
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800210:	f3 0f 1e fb          	endbr32 
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	53                   	push   %ebx
  800218:	83 ec 04             	sub    $0x4,%esp
  80021b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021e:	8b 13                	mov    (%ebx),%edx
  800220:	8d 42 01             	lea    0x1(%edx),%eax
  800223:	89 03                	mov    %eax,(%ebx)
  800225:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800228:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80022c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800231:	74 09                	je     80023c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800233:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800237:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	68 ff 00 00 00       	push   $0xff
  800244:	8d 43 08             	lea    0x8(%ebx),%eax
  800247:	50                   	push   %eax
  800248:	e8 24 0a 00 00       	call   800c71 <sys_cputs>
		b->idx = 0;
  80024d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800253:	83 c4 10             	add    $0x10,%esp
  800256:	eb db                	jmp    800233 <putch+0x23>

00800258 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800258:	f3 0f 1e fb          	endbr32 
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800265:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026c:	00 00 00 
	b.cnt = 0;
  80026f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800276:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800279:	ff 75 0c             	pushl  0xc(%ebp)
  80027c:	ff 75 08             	pushl  0x8(%ebp)
  80027f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800285:	50                   	push   %eax
  800286:	68 10 02 80 00       	push   $0x800210
  80028b:	e8 20 01 00 00       	call   8003b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800290:	83 c4 08             	add    $0x8,%esp
  800293:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800299:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029f:	50                   	push   %eax
  8002a0:	e8 cc 09 00 00       	call   800c71 <sys_cputs>

	return b.cnt;
}
  8002a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ad:	f3 0f 1e fb          	endbr32 
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 95 ff ff ff       	call   800258 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 d1                	mov    %edx,%ecx
  8002da:	89 c2                	mov    %eax,%edx
  8002dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  8002e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002eb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002f2:	39 c2                	cmp    %eax,%edx
  8002f4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002f7:	72 3e                	jb     800337 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f9:	83 ec 0c             	sub    $0xc,%esp
  8002fc:	ff 75 18             	pushl  0x18(%ebp)
  8002ff:	83 eb 01             	sub    $0x1,%ebx
  800302:	53                   	push   %ebx
  800303:	50                   	push   %eax
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 58 22 00 00       	call   802570 <__udivdi3>
  800318:	83 c4 18             	add    $0x18,%esp
  80031b:	52                   	push   %edx
  80031c:	50                   	push   %eax
  80031d:	89 f2                	mov    %esi,%edx
  80031f:	89 f8                	mov    %edi,%eax
  800321:	e8 9f ff ff ff       	call   8002c5 <printnum>
  800326:	83 c4 20             	add    $0x20,%esp
  800329:	eb 13                	jmp    80033e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032b:	83 ec 08             	sub    $0x8,%esp
  80032e:	56                   	push   %esi
  80032f:	ff 75 18             	pushl  0x18(%ebp)
  800332:	ff d7                	call   *%edi
  800334:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800337:	83 eb 01             	sub    $0x1,%ebx
  80033a:	85 db                	test   %ebx,%ebx
  80033c:	7f ed                	jg     80032b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033e:	83 ec 08             	sub    $0x8,%esp
  800341:	56                   	push   %esi
  800342:	83 ec 04             	sub    $0x4,%esp
  800345:	ff 75 e4             	pushl  -0x1c(%ebp)
  800348:	ff 75 e0             	pushl  -0x20(%ebp)
  80034b:	ff 75 dc             	pushl  -0x24(%ebp)
  80034e:	ff 75 d8             	pushl  -0x28(%ebp)
  800351:	e8 2a 23 00 00       	call   802680 <__umoddi3>
  800356:	83 c4 14             	add    $0x14,%esp
  800359:	0f be 80 8c 28 80 00 	movsbl 0x80288c(%eax),%eax
  800360:	50                   	push   %eax
  800361:	ff d7                	call   *%edi
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036e:	f3 0f 1e fb          	endbr32 
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800378:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	3b 50 04             	cmp    0x4(%eax),%edx
  800381:	73 0a                	jae    80038d <sprintputch+0x1f>
		*b->buf++ = ch;
  800383:	8d 4a 01             	lea    0x1(%edx),%ecx
  800386:	89 08                	mov    %ecx,(%eax)
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	88 02                	mov    %al,(%edx)
}
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <printfmt>:
{
  80038f:	f3 0f 1e fb          	endbr32 
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800399:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039c:	50                   	push   %eax
  80039d:	ff 75 10             	pushl  0x10(%ebp)
  8003a0:	ff 75 0c             	pushl  0xc(%ebp)
  8003a3:	ff 75 08             	pushl  0x8(%ebp)
  8003a6:	e8 05 00 00 00       	call   8003b0 <vprintfmt>
}
  8003ab:	83 c4 10             	add    $0x10,%esp
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <vprintfmt>:
{
  8003b0:	f3 0f 1e fb          	endbr32 
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 3c             	sub    $0x3c,%esp
  8003bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8003c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c6:	e9 8e 03 00 00       	jmp    800759 <vprintfmt+0x3a9>
		padc = ' ';
  8003cb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003cf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003d6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8d 47 01             	lea    0x1(%edi),%eax
  8003ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ef:	0f b6 17             	movzbl (%edi),%edx
  8003f2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f5:	3c 55                	cmp    $0x55,%al
  8003f7:	0f 87 df 03 00 00    	ja     8007dc <vprintfmt+0x42c>
  8003fd:	0f b6 c0             	movzbl %al,%eax
  800400:	3e ff 24 85 c0 29 80 	notrack jmp *0x8029c0(,%eax,4)
  800407:	00 
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80040b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80040f:	eb d8                	jmp    8003e9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800414:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800418:	eb cf                	jmp    8003e9 <vprintfmt+0x39>
  80041a:	0f b6 d2             	movzbl %dl,%edx
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800420:	b8 00 00 00 00       	mov    $0x0,%eax
  800425:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800428:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800432:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800435:	83 f9 09             	cmp    $0x9,%ecx
  800438:	77 55                	ja     80048f <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80043a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80043d:	eb e9                	jmp    800428 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8b 00                	mov    (%eax),%eax
  800444:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 40 04             	lea    0x4(%eax),%eax
  80044d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800453:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800457:	79 90                	jns    8003e9 <vprintfmt+0x39>
				width = precision, precision = -1;
  800459:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800466:	eb 81                	jmp    8003e9 <vprintfmt+0x39>
  800468:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	ba 00 00 00 00       	mov    $0x0,%edx
  800472:	0f 49 d0             	cmovns %eax,%edx
  800475:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80047b:	e9 69 ff ff ff       	jmp    8003e9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800483:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80048a:	e9 5a ff ff ff       	jmp    8003e9 <vprintfmt+0x39>
  80048f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800492:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800495:	eb bc                	jmp    800453 <vprintfmt+0xa3>
			lflag++;
  800497:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049d:	e9 47 ff ff ff       	jmp    8003e9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 78 04             	lea    0x4(%eax),%edi
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 30                	pushl  (%eax)
  8004ae:	ff d6                	call   *%esi
			break;
  8004b0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b6:	e9 9b 02 00 00       	jmp    800756 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 78 04             	lea    0x4(%eax),%edi
  8004c1:	8b 00                	mov    (%eax),%eax
  8004c3:	99                   	cltd   
  8004c4:	31 d0                	xor    %edx,%eax
  8004c6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c8:	83 f8 0f             	cmp    $0xf,%eax
  8004cb:	7f 23                	jg     8004f0 <vprintfmt+0x140>
  8004cd:	8b 14 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%edx
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	74 18                	je     8004f0 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004d8:	52                   	push   %edx
  8004d9:	68 3d 2d 80 00       	push   $0x802d3d
  8004de:	53                   	push   %ebx
  8004df:	56                   	push   %esi
  8004e0:	e8 aa fe ff ff       	call   80038f <printfmt>
  8004e5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004eb:	e9 66 02 00 00       	jmp    800756 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8004f0:	50                   	push   %eax
  8004f1:	68 a4 28 80 00       	push   $0x8028a4
  8004f6:	53                   	push   %ebx
  8004f7:	56                   	push   %esi
  8004f8:	e8 92 fe ff ff       	call   80038f <printfmt>
  8004fd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800500:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800503:	e9 4e 02 00 00       	jmp    800756 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	83 c0 04             	add    $0x4,%eax
  80050e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800516:	85 d2                	test   %edx,%edx
  800518:	b8 9d 28 80 00       	mov    $0x80289d,%eax
  80051d:	0f 45 c2             	cmovne %edx,%eax
  800520:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800523:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800527:	7e 06                	jle    80052f <vprintfmt+0x17f>
  800529:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80052d:	75 0d                	jne    80053c <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800532:	89 c7                	mov    %eax,%edi
  800534:	03 45 e0             	add    -0x20(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	eb 55                	jmp    800591 <vprintfmt+0x1e1>
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	ff 75 d8             	pushl  -0x28(%ebp)
  800542:	ff 75 cc             	pushl  -0x34(%ebp)
  800545:	e8 46 03 00 00       	call   800890 <strnlen>
  80054a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80054d:	29 c2                	sub    %eax,%edx
  80054f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800557:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80055b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	85 ff                	test   %edi,%edi
  800560:	7e 11                	jle    800573 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	53                   	push   %ebx
  800566:	ff 75 e0             	pushl  -0x20(%ebp)
  800569:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	83 ef 01             	sub    $0x1,%edi
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb eb                	jmp    80055e <vprintfmt+0x1ae>
  800573:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800576:	85 d2                	test   %edx,%edx
  800578:	b8 00 00 00 00       	mov    $0x0,%eax
  80057d:	0f 49 c2             	cmovns %edx,%eax
  800580:	29 c2                	sub    %eax,%edx
  800582:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800585:	eb a8                	jmp    80052f <vprintfmt+0x17f>
					putch(ch, putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	52                   	push   %edx
  80058c:	ff d6                	call   *%esi
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800594:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 c7 01             	add    $0x1,%edi
  800599:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059d:	0f be d0             	movsbl %al,%edx
  8005a0:	85 d2                	test   %edx,%edx
  8005a2:	74 4b                	je     8005ef <vprintfmt+0x23f>
  8005a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a8:	78 06                	js     8005b0 <vprintfmt+0x200>
  8005aa:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ae:	78 1e                	js     8005ce <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8005b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b4:	74 d1                	je     800587 <vprintfmt+0x1d7>
  8005b6:	0f be c0             	movsbl %al,%eax
  8005b9:	83 e8 20             	sub    $0x20,%eax
  8005bc:	83 f8 5e             	cmp    $0x5e,%eax
  8005bf:	76 c6                	jbe    800587 <vprintfmt+0x1d7>
					putch('?', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 3f                	push   $0x3f
  8005c7:	ff d6                	call   *%esi
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb c3                	jmp    800591 <vprintfmt+0x1e1>
  8005ce:	89 cf                	mov    %ecx,%edi
  8005d0:	eb 0e                	jmp    8005e0 <vprintfmt+0x230>
				putch(' ', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 20                	push   $0x20
  8005d8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005da:	83 ef 01             	sub    $0x1,%edi
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f ee                	jg     8005d2 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ea:	e9 67 01 00 00       	jmp    800756 <vprintfmt+0x3a6>
  8005ef:	89 cf                	mov    %ecx,%edi
  8005f1:	eb ed                	jmp    8005e0 <vprintfmt+0x230>
	if (lflag >= 2)
  8005f3:	83 f9 01             	cmp    $0x1,%ecx
  8005f6:	7f 1b                	jg     800613 <vprintfmt+0x263>
	else if (lflag)
  8005f8:	85 c9                	test   %ecx,%ecx
  8005fa:	74 63                	je     80065f <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	99                   	cltd   
  800605:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 40 04             	lea    0x4(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
  800611:	eb 17                	jmp    80062a <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 50 04             	mov    0x4(%eax),%edx
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 40 08             	lea    0x8(%eax),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80062a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800630:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800635:	85 c9                	test   %ecx,%ecx
  800637:	0f 89 ff 00 00 00    	jns    80073c <vprintfmt+0x38c>
				putch('-', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 2d                	push   $0x2d
  800643:	ff d6                	call   *%esi
				num = -(long long) num;
  800645:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800648:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064b:	f7 da                	neg    %edx
  80064d:	83 d1 00             	adc    $0x0,%ecx
  800650:	f7 d9                	neg    %ecx
  800652:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800655:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065a:	e9 dd 00 00 00       	jmp    80073c <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 00                	mov    (%eax),%eax
  800664:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800667:	99                   	cltd   
  800668:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 40 04             	lea    0x4(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
  800674:	eb b4                	jmp    80062a <vprintfmt+0x27a>
	if (lflag >= 2)
  800676:	83 f9 01             	cmp    $0x1,%ecx
  800679:	7f 1e                	jg     800699 <vprintfmt+0x2e9>
	else if (lflag)
  80067b:	85 c9                	test   %ecx,%ecx
  80067d:	74 32                	je     8006b1 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800694:	e9 a3 00 00 00       	jmp    80073c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	8d 40 08             	lea    0x8(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006ac:	e9 8b 00 00 00       	jmp    80073c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006c6:	eb 74                	jmp    80073c <vprintfmt+0x38c>
	if (lflag >= 2)
  8006c8:	83 f9 01             	cmp    $0x1,%ecx
  8006cb:	7f 1b                	jg     8006e8 <vprintfmt+0x338>
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	74 2c                	je     8006fd <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8006e6:	eb 54                	jmp    80073c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f0:	8d 40 08             	lea    0x8(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006f6:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8006fb:	eb 3f                	jmp    80073c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 10                	mov    (%eax),%edx
  800702:	b9 00 00 00 00       	mov    $0x0,%ecx
  800707:	8d 40 04             	lea    0x4(%eax),%eax
  80070a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80070d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800712:	eb 28                	jmp    80073c <vprintfmt+0x38c>
			putch('0', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 30                	push   $0x30
  80071a:	ff d6                	call   *%esi
			putch('x', putdat);
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 78                	push   $0x78
  800722:	ff d6                	call   *%esi
			num = (unsigned long long)
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 10                	mov    (%eax),%edx
  800729:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80072e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800731:	8d 40 04             	lea    0x4(%eax),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80073c:	83 ec 0c             	sub    $0xc,%esp
  80073f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800743:	57                   	push   %edi
  800744:	ff 75 e0             	pushl  -0x20(%ebp)
  800747:	50                   	push   %eax
  800748:	51                   	push   %ecx
  800749:	52                   	push   %edx
  80074a:	89 da                	mov    %ebx,%edx
  80074c:	89 f0                	mov    %esi,%eax
  80074e:	e8 72 fb ff ff       	call   8002c5 <printnum>
			break;
  800753:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800759:	83 c7 01             	add    $0x1,%edi
  80075c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800760:	83 f8 25             	cmp    $0x25,%eax
  800763:	0f 84 62 fc ff ff    	je     8003cb <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800769:	85 c0                	test   %eax,%eax
  80076b:	0f 84 8b 00 00 00    	je     8007fc <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	50                   	push   %eax
  800776:	ff d6                	call   *%esi
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb dc                	jmp    800759 <vprintfmt+0x3a9>
	if (lflag >= 2)
  80077d:	83 f9 01             	cmp    $0x1,%ecx
  800780:	7f 1b                	jg     80079d <vprintfmt+0x3ed>
	else if (lflag)
  800782:	85 c9                	test   %ecx,%ecx
  800784:	74 2c                	je     8007b2 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 10                	mov    (%eax),%edx
  80078b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800790:	8d 40 04             	lea    0x4(%eax),%eax
  800793:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800796:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80079b:	eb 9f                	jmp    80073c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8007a5:	8d 40 08             	lea    0x8(%eax),%eax
  8007a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ab:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007b0:	eb 8a                	jmp    80073c <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007c7:	e9 70 ff ff ff       	jmp    80073c <vprintfmt+0x38c>
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 25                	push   $0x25
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	e9 7a ff ff ff       	jmp    800756 <vprintfmt+0x3a6>
			putch('%', putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	89 f8                	mov    %edi,%eax
  8007e9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ed:	74 05                	je     8007f4 <vprintfmt+0x444>
  8007ef:	83 e8 01             	sub    $0x1,%eax
  8007f2:	eb f5                	jmp    8007e9 <vprintfmt+0x439>
  8007f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f7:	e9 5a ff ff ff       	jmp    800756 <vprintfmt+0x3a6>
}
  8007fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5f                   	pop    %edi
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800804:	f3 0f 1e fb          	endbr32 
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 18             	sub    $0x18,%esp
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800814:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800817:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800825:	85 c0                	test   %eax,%eax
  800827:	74 26                	je     80084f <vsnprintf+0x4b>
  800829:	85 d2                	test   %edx,%edx
  80082b:	7e 22                	jle    80084f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082d:	ff 75 14             	pushl  0x14(%ebp)
  800830:	ff 75 10             	pushl  0x10(%ebp)
  800833:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800836:	50                   	push   %eax
  800837:	68 6e 03 80 00       	push   $0x80036e
  80083c:	e8 6f fb ff ff       	call   8003b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800841:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800844:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084a:	83 c4 10             	add    $0x10,%esp
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    
		return -E_INVAL;
  80084f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800854:	eb f7                	jmp    80084d <vsnprintf+0x49>

00800856 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800856:	f3 0f 1e fb          	endbr32 
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800863:	50                   	push   %eax
  800864:	ff 75 10             	pushl  0x10(%ebp)
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	ff 75 08             	pushl  0x8(%ebp)
  80086d:	e8 92 ff ff ff       	call   800804 <vsnprintf>
	va_end(ap);

	return rc;
}
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800874:	f3 0f 1e fb          	endbr32 
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	74 05                	je     80088e <strlen+0x1a>
		n++;
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	eb f5                	jmp    800883 <strlen+0xf>
	return n;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800890:	f3 0f 1e fb          	endbr32 
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	39 d0                	cmp    %edx,%eax
  8008a4:	74 0d                	je     8008b3 <strnlen+0x23>
  8008a6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008aa:	74 05                	je     8008b1 <strnlen+0x21>
		n++;
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	eb f1                	jmp    8008a2 <strnlen+0x12>
  8008b1:	89 c2                	mov    %eax,%edx
	return n;
}
  8008b3:	89 d0                	mov    %edx,%eax
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ca:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008ce:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008d8:	89 c8                	mov    %ecx,%eax
  8008da:	5b                   	pop    %ebx
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008dd:	f3 0f 1e fb          	endbr32 
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	83 ec 10             	sub    $0x10,%esp
  8008e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008eb:	53                   	push   %ebx
  8008ec:	e8 83 ff ff ff       	call   800874 <strlen>
  8008f1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	01 d8                	add    %ebx,%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 b8 ff ff ff       	call   8008b7 <strcpy>
	return dst;
}
  8008ff:	89 d8                	mov    %ebx,%eax
  800901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800906:	f3 0f 1e fb          	endbr32 
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	8b 75 08             	mov    0x8(%ebp),%esi
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
  800915:	89 f3                	mov    %esi,%ebx
  800917:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091a:	89 f0                	mov    %esi,%eax
  80091c:	39 d8                	cmp    %ebx,%eax
  80091e:	74 11                	je     800931 <strncpy+0x2b>
		*dst++ = *src;
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	0f b6 0a             	movzbl (%edx),%ecx
  800926:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800929:	80 f9 01             	cmp    $0x1,%cl
  80092c:	83 da ff             	sbb    $0xffffffff,%edx
  80092f:	eb eb                	jmp    80091c <strncpy+0x16>
	}
	return ret;
}
  800931:	89 f0                	mov    %esi,%eax
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800937:	f3 0f 1e fb          	endbr32 
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 75 08             	mov    0x8(%ebp),%esi
  800943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800946:	8b 55 10             	mov    0x10(%ebp),%edx
  800949:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094b:	85 d2                	test   %edx,%edx
  80094d:	74 21                	je     800970 <strlcpy+0x39>
  80094f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800953:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800955:	39 c2                	cmp    %eax,%edx
  800957:	74 14                	je     80096d <strlcpy+0x36>
  800959:	0f b6 19             	movzbl (%ecx),%ebx
  80095c:	84 db                	test   %bl,%bl
  80095e:	74 0b                	je     80096b <strlcpy+0x34>
			*dst++ = *src++;
  800960:	83 c1 01             	add    $0x1,%ecx
  800963:	83 c2 01             	add    $0x1,%edx
  800966:	88 5a ff             	mov    %bl,-0x1(%edx)
  800969:	eb ea                	jmp    800955 <strlcpy+0x1e>
  80096b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80096d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800970:	29 f0                	sub    %esi,%eax
}
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800983:	0f b6 01             	movzbl (%ecx),%eax
  800986:	84 c0                	test   %al,%al
  800988:	74 0c                	je     800996 <strcmp+0x20>
  80098a:	3a 02                	cmp    (%edx),%al
  80098c:	75 08                	jne    800996 <strcmp+0x20>
		p++, q++;
  80098e:	83 c1 01             	add    $0x1,%ecx
  800991:	83 c2 01             	add    $0x1,%edx
  800994:	eb ed                	jmp    800983 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800996:	0f b6 c0             	movzbl %al,%eax
  800999:	0f b6 12             	movzbl (%edx),%edx
  80099c:	29 d0                	sub    %edx,%eax
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a0:	f3 0f 1e fb          	endbr32 
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	89 c3                	mov    %eax,%ebx
  8009b0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b3:	eb 06                	jmp    8009bb <strncmp+0x1b>
		n--, p++, q++;
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bb:	39 d8                	cmp    %ebx,%eax
  8009bd:	74 16                	je     8009d5 <strncmp+0x35>
  8009bf:	0f b6 08             	movzbl (%eax),%ecx
  8009c2:	84 c9                	test   %cl,%cl
  8009c4:	74 04                	je     8009ca <strncmp+0x2a>
  8009c6:	3a 0a                	cmp    (%edx),%cl
  8009c8:	74 eb                	je     8009b5 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ca:	0f b6 00             	movzbl (%eax),%eax
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	29 d0                	sub    %edx,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    
		return 0;
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	eb f6                	jmp    8009d2 <strncmp+0x32>

008009dc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009dc:	f3 0f 1e fb          	endbr32 
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ea:	0f b6 10             	movzbl (%eax),%edx
  8009ed:	84 d2                	test   %dl,%dl
  8009ef:	74 09                	je     8009fa <strchr+0x1e>
		if (*s == c)
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 0a                	je     8009ff <strchr+0x23>
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	eb f0                	jmp    8009ea <strchr+0xe>
			return (char *) s;
	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800a01:	f3 0f 1e fb          	endbr32 
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800a0b:	6a 78                	push   $0x78
  800a0d:	ff 75 08             	pushl  0x8(%ebp)
  800a10:	e8 c7 ff ff ff       	call   8009dc <strchr>
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800a20:	eb 0d                	jmp    800a2f <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800a22:	c1 e0 04             	shl    $0x4,%eax
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	0f b6 11             	movzbl (%ecx),%edx
  800a32:	84 d2                	test   %dl,%dl
  800a34:	74 11                	je     800a47 <atox+0x46>
		if (*p>='a'){
  800a36:	80 fa 60             	cmp    $0x60,%dl
  800a39:	7e e7                	jle    800a22 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800a3b:	c1 e0 04             	shl    $0x4,%eax
  800a3e:	0f be d2             	movsbl %dl,%edx
  800a41:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800a45:	eb e5                	jmp    800a2c <atox+0x2b>
	}

	return v;

}
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a49:	f3 0f 1e fb          	endbr32 
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a57:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5a:	38 ca                	cmp    %cl,%dl
  800a5c:	74 09                	je     800a67 <strfind+0x1e>
  800a5e:	84 d2                	test   %dl,%dl
  800a60:	74 05                	je     800a67 <strfind+0x1e>
	for (; *s; s++)
  800a62:	83 c0 01             	add    $0x1,%eax
  800a65:	eb f0                	jmp    800a57 <strfind+0xe>
			break;
	return (char *) s;
}
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a69:	f3 0f 1e fb          	endbr32 
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	74 31                	je     800aae <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	09 c8                	or     %ecx,%eax
  800a81:	a8 03                	test   $0x3,%al
  800a83:	75 23                	jne    800aa8 <memset+0x3f>
		c &= 0xFF;
  800a85:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a89:	89 d3                	mov    %edx,%ebx
  800a8b:	c1 e3 08             	shl    $0x8,%ebx
  800a8e:	89 d0                	mov    %edx,%eax
  800a90:	c1 e0 18             	shl    $0x18,%eax
  800a93:	89 d6                	mov    %edx,%esi
  800a95:	c1 e6 10             	shl    $0x10,%esi
  800a98:	09 f0                	or     %esi,%eax
  800a9a:	09 c2                	or     %eax,%edx
  800a9c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800aa1:	89 d0                	mov    %edx,%eax
  800aa3:	fc                   	cld    
  800aa4:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa6:	eb 06                	jmp    800aae <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	fc                   	cld    
  800aac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aae:	89 f8                	mov    %edi,%eax
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab5:	f3 0f 1e fb          	endbr32 
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac7:	39 c6                	cmp    %eax,%esi
  800ac9:	73 32                	jae    800afd <memmove+0x48>
  800acb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ace:	39 c2                	cmp    %eax,%edx
  800ad0:	76 2b                	jbe    800afd <memmove+0x48>
		s += n;
		d += n;
  800ad2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad5:	89 fe                	mov    %edi,%esi
  800ad7:	09 ce                	or     %ecx,%esi
  800ad9:	09 d6                	or     %edx,%esi
  800adb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae1:	75 0e                	jne    800af1 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae3:	83 ef 04             	sub    $0x4,%edi
  800ae6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aec:	fd                   	std    
  800aed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aef:	eb 09                	jmp    800afa <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af1:	83 ef 01             	sub    $0x1,%edi
  800af4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800af7:	fd                   	std    
  800af8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afa:	fc                   	cld    
  800afb:	eb 1a                	jmp    800b17 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afd:	89 c2                	mov    %eax,%edx
  800aff:	09 ca                	or     %ecx,%edx
  800b01:	09 f2                	or     %esi,%edx
  800b03:	f6 c2 03             	test   $0x3,%dl
  800b06:	75 0a                	jne    800b12 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b08:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b10:	eb 05                	jmp    800b17 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	fc                   	cld    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1b:	f3 0f 1e fb          	endbr32 
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b25:	ff 75 10             	pushl  0x10(%ebp)
  800b28:	ff 75 0c             	pushl  0xc(%ebp)
  800b2b:	ff 75 08             	pushl  0x8(%ebp)
  800b2e:	e8 82 ff ff ff       	call   800ab5 <memmove>
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b35:	f3 0f 1e fb          	endbr32 
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b44:	89 c6                	mov    %eax,%esi
  800b46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b49:	39 f0                	cmp    %esi,%eax
  800b4b:	74 1c                	je     800b69 <memcmp+0x34>
		if (*s1 != *s2)
  800b4d:	0f b6 08             	movzbl (%eax),%ecx
  800b50:	0f b6 1a             	movzbl (%edx),%ebx
  800b53:	38 d9                	cmp    %bl,%cl
  800b55:	75 08                	jne    800b5f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b57:	83 c0 01             	add    $0x1,%eax
  800b5a:	83 c2 01             	add    $0x1,%edx
  800b5d:	eb ea                	jmp    800b49 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b5f:	0f b6 c1             	movzbl %cl,%eax
  800b62:	0f b6 db             	movzbl %bl,%ebx
  800b65:	29 d8                	sub    %ebx,%eax
  800b67:	eb 05                	jmp    800b6e <memcmp+0x39>
	}

	return 0;
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b72:	f3 0f 1e fb          	endbr32 
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b84:	39 d0                	cmp    %edx,%eax
  800b86:	73 09                	jae    800b91 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b88:	38 08                	cmp    %cl,(%eax)
  800b8a:	74 05                	je     800b91 <memfind+0x1f>
	for (; s < ends; s++)
  800b8c:	83 c0 01             	add    $0x1,%eax
  800b8f:	eb f3                	jmp    800b84 <memfind+0x12>
			break;
	return (void *) s;
}
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba3:	eb 03                	jmp    800ba8 <strtol+0x15>
		s++;
  800ba5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ba8:	0f b6 01             	movzbl (%ecx),%eax
  800bab:	3c 20                	cmp    $0x20,%al
  800bad:	74 f6                	je     800ba5 <strtol+0x12>
  800baf:	3c 09                	cmp    $0x9,%al
  800bb1:	74 f2                	je     800ba5 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800bb3:	3c 2b                	cmp    $0x2b,%al
  800bb5:	74 2a                	je     800be1 <strtol+0x4e>
	int neg = 0;
  800bb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bbc:	3c 2d                	cmp    $0x2d,%al
  800bbe:	74 2b                	je     800beb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc6:	75 0f                	jne    800bd7 <strtol+0x44>
  800bc8:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcb:	74 28                	je     800bf5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bcd:	85 db                	test   %ebx,%ebx
  800bcf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd4:	0f 44 d8             	cmove  %eax,%ebx
  800bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bdf:	eb 46                	jmp    800c27 <strtol+0x94>
		s++;
  800be1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800be4:	bf 00 00 00 00       	mov    $0x0,%edi
  800be9:	eb d5                	jmp    800bc0 <strtol+0x2d>
		s++, neg = 1;
  800beb:	83 c1 01             	add    $0x1,%ecx
  800bee:	bf 01 00 00 00       	mov    $0x1,%edi
  800bf3:	eb cb                	jmp    800bc0 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf9:	74 0e                	je     800c09 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bfb:	85 db                	test   %ebx,%ebx
  800bfd:	75 d8                	jne    800bd7 <strtol+0x44>
		s++, base = 8;
  800bff:	83 c1 01             	add    $0x1,%ecx
  800c02:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c07:	eb ce                	jmp    800bd7 <strtol+0x44>
		s += 2, base = 16;
  800c09:	83 c1 02             	add    $0x2,%ecx
  800c0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c11:	eb c4                	jmp    800bd7 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c13:	0f be d2             	movsbl %dl,%edx
  800c16:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c19:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1c:	7d 3a                	jge    800c58 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c25:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c27:	0f b6 11             	movzbl (%ecx),%edx
  800c2a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2d:	89 f3                	mov    %esi,%ebx
  800c2f:	80 fb 09             	cmp    $0x9,%bl
  800c32:	76 df                	jbe    800c13 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c34:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c37:	89 f3                	mov    %esi,%ebx
  800c39:	80 fb 19             	cmp    $0x19,%bl
  800c3c:	77 08                	ja     800c46 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c3e:	0f be d2             	movsbl %dl,%edx
  800c41:	83 ea 57             	sub    $0x57,%edx
  800c44:	eb d3                	jmp    800c19 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c46:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c49:	89 f3                	mov    %esi,%ebx
  800c4b:	80 fb 19             	cmp    $0x19,%bl
  800c4e:	77 08                	ja     800c58 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c50:	0f be d2             	movsbl %dl,%edx
  800c53:	83 ea 37             	sub    $0x37,%edx
  800c56:	eb c1                	jmp    800c19 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5c:	74 05                	je     800c63 <strtol+0xd0>
		*endptr = (char *) s;
  800c5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c61:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c63:	89 c2                	mov    %eax,%edx
  800c65:	f7 da                	neg    %edx
  800c67:	85 ff                	test   %edi,%edi
  800c69:	0f 45 c2             	cmovne %edx,%eax
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	89 c3                	mov    %eax,%ebx
  800c88:	89 c7                	mov    %eax,%edi
  800c8a:	89 c6                	mov    %eax,%esi
  800c8c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c93:	f3 0f 1e fb          	endbr32 
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	89 d3                	mov    %edx,%ebx
  800cab:	89 d7                	mov    %edx,%edi
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb6:	f3 0f 1e fb          	endbr32 
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800ccd:	89 cb                	mov    %ecx,%ebx
  800ccf:	89 cf                	mov    %ecx,%edi
  800cd1:	89 ce                	mov    %ecx,%esi
  800cd3:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cda:	f3 0f 1e fb          	endbr32 
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cee:	89 d1                	mov    %edx,%ecx
  800cf0:	89 d3                	mov    %edx,%ebx
  800cf2:	89 d7                	mov    %edx,%edi
  800cf4:	89 d6                	mov    %edx,%esi
  800cf6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_yield>:

void
sys_yield(void)
{
  800cfd:	f3 0f 1e fb          	endbr32 
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d07:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d11:	89 d1                	mov    %edx,%ecx
  800d13:	89 d3                	mov    %edx,%ebx
  800d15:	89 d7                	mov    %edx,%edi
  800d17:	89 d6                	mov    %edx,%esi
  800d19:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2a:	be 00 00 00 00       	mov    $0x0,%esi
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	b8 04 00 00 00       	mov    $0x4,%eax
  800d3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3d:	89 f7                	mov    %esi,%edi
  800d3f:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d46:	f3 0f 1e fb          	endbr32 
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d61:	8b 75 18             	mov    0x18(%ebp),%esi
  800d64:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6b:	f3 0f 1e fb          	endbr32 
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	b8 06 00 00 00       	mov    $0x6,%eax
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8b:	5b                   	pop    %ebx
  800d8c:	5e                   	pop    %esi
  800d8d:	5f                   	pop    %edi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d90:	f3 0f 1e fb          	endbr32 
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da5:	b8 08 00 00 00       	mov    $0x8,%eax
  800daa:	89 df                	mov    %ebx,%edi
  800dac:	89 de                	mov    %ebx,%esi
  800dae:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db5:	f3 0f 1e fb          	endbr32 
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	b8 09 00 00 00       	mov    $0x9,%eax
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dda:	f3 0f 1e fb          	endbr32 
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df4:	89 df                	mov    %ebx,%edi
  800df6:	89 de                	mov    %ebx,%esi
  800df8:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dff:	f3 0f 1e fb          	endbr32 
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e14:	be 00 00 00 00       	mov    $0x0,%esi
  800e19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e26:	f3 0f 1e fb          	endbr32 
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3d:	89 cb                	mov    %ecx,%ebx
  800e3f:	89 cf                	mov    %ecx,%edi
  800e41:	89 ce                	mov    %ecx,%esi
  800e43:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e4a:	f3 0f 1e fb          	endbr32 
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e54:	ba 00 00 00 00       	mov    $0x0,%edx
  800e59:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e5e:	89 d1                	mov    %edx,%ecx
  800e60:	89 d3                	mov    %edx,%ebx
  800e62:	89 d7                	mov    %edx,%edi
  800e64:	89 d6                	mov    %edx,%esi
  800e66:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800e6d:	f3 0f 1e fb          	endbr32 
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e87:	89 df                	mov    %ebx,%edi
  800e89:	89 de                	mov    %ebx,%esi
  800e8b:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e92:	f3 0f 1e fb          	endbr32 
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	b8 10 00 00 00       	mov    $0x10,%eax
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	89 de                	mov    %ebx,%esi
  800eb0:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800eb7:	f3 0f 1e fb          	endbr32 
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800ec5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800ec7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ecb:	0f 84 9a 00 00 00    	je     800f6b <pgfault+0xb4>
  800ed1:	89 d8                	mov    %ebx,%eax
  800ed3:	c1 e8 16             	shr    $0x16,%eax
  800ed6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800edd:	a8 01                	test   $0x1,%al
  800edf:	0f 84 86 00 00 00    	je     800f6b <pgfault+0xb4>
  800ee5:	89 d8                	mov    %ebx,%eax
  800ee7:	c1 e8 0c             	shr    $0xc,%eax
  800eea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef1:	f6 c2 01             	test   $0x1,%dl
  800ef4:	74 75                	je     800f6b <pgfault+0xb4>
  800ef6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800efd:	f6 c4 08             	test   $0x8,%ah
  800f00:	74 69                	je     800f6b <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	6a 07                	push   $0x7
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	6a 00                	push   $0x0
  800f0e:	e8 0d fe ff ff       	call   800d20 <sys_page_alloc>
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 63                	js     800f7d <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800f1a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800f20:	83 ec 04             	sub    $0x4,%esp
  800f23:	68 00 10 00 00       	push   $0x1000
  800f28:	53                   	push   %ebx
  800f29:	68 00 f0 7f 00       	push   $0x7ff000
  800f2e:	e8 e8 fb ff ff       	call   800b1b <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800f33:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f3a:	53                   	push   %ebx
  800f3b:	6a 00                	push   $0x0
  800f3d:	68 00 f0 7f 00       	push   $0x7ff000
  800f42:	6a 00                	push   $0x0
  800f44:	e8 fd fd ff ff       	call   800d46 <sys_page_map>
  800f49:	83 c4 20             	add    $0x20,%esp
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	78 3f                	js     800f8f <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	68 00 f0 7f 00       	push   $0x7ff000
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 0c fe ff ff       	call   800d6b <sys_page_unmap>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 3b                	js     800fa1 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800f66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800f6b:	53                   	push   %ebx
  800f6c:	68 80 2b 80 00       	push   $0x802b80
  800f71:	6a 20                	push   $0x20
  800f73:	68 3e 2c 80 00       	push   $0x802c3e
  800f78:	e8 d1 14 00 00       	call   80244e <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800f7d:	50                   	push   %eax
  800f7e:	68 c0 2b 80 00       	push   $0x802bc0
  800f83:	6a 2c                	push   $0x2c
  800f85:	68 3e 2c 80 00       	push   $0x802c3e
  800f8a:	e8 bf 14 00 00       	call   80244e <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800f8f:	50                   	push   %eax
  800f90:	68 ec 2b 80 00       	push   $0x802bec
  800f95:	6a 33                	push   $0x33
  800f97:	68 3e 2c 80 00       	push   $0x802c3e
  800f9c:	e8 ad 14 00 00       	call   80244e <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800fa1:	50                   	push   %eax
  800fa2:	68 14 2c 80 00       	push   $0x802c14
  800fa7:	6a 36                	push   $0x36
  800fa9:	68 3e 2c 80 00       	push   $0x802c3e
  800fae:	e8 9b 14 00 00       	call   80244e <_panic>

00800fb3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb3:	f3 0f 1e fb          	endbr32 
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800fc0:	68 b7 0e 80 00       	push   $0x800eb7
  800fc5:	e8 ce 14 00 00       	call   802498 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fca:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcf:	cd 30                	int    $0x30
  800fd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 29                	js     801004 <fork+0x51>
  800fdb:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  800fe2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fe6:	75 60                	jne    801048 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe8:	e8 ed fc ff ff       	call   800cda <sys_getenvid>
  800fed:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ff5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ffa:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800fff:	e9 14 01 00 00       	jmp    801118 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  801004:	50                   	push   %eax
  801005:	68 49 2c 80 00       	push   $0x802c49
  80100a:	68 90 00 00 00       	push   $0x90
  80100f:	68 3e 2c 80 00       	push   $0x802c3e
  801014:	e8 35 14 00 00       	call   80244e <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  801019:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	25 07 0e 00 00       	and    $0xe07,%eax
  801028:	50                   	push   %eax
  801029:	56                   	push   %esi
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	6a 00                	push   $0x0
  80102e:	e8 13 fd ff ff       	call   800d46 <sys_page_map>
  801033:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  801036:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801042:	0f 84 95 00 00 00    	je     8010dd <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801048:	89 d8                	mov    %ebx,%eax
  80104a:	c1 e8 16             	shr    $0x16,%eax
  80104d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801054:	a8 01                	test   $0x1,%al
  801056:	74 de                	je     801036 <fork+0x83>
  801058:	89 d8                	mov    %ebx,%eax
  80105a:	c1 e8 0c             	shr    $0xc,%eax
  80105d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801064:	f6 c2 01             	test   $0x1,%dl
  801067:	74 cd                	je     801036 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  801069:	89 c6                	mov    %eax,%esi
  80106b:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  80106e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801075:	f6 c6 04             	test   $0x4,%dh
  801078:	75 9f                	jne    801019 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  80107a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801081:	f6 c2 02             	test   $0x2,%dl
  801084:	75 0c                	jne    801092 <fork+0xdf>
  801086:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108d:	f6 c4 08             	test   $0x8,%ah
  801090:	74 34                	je     8010c6 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	68 05 08 00 00       	push   $0x805
  80109a:	56                   	push   %esi
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	6a 00                	push   $0x0
  80109f:	e8 a2 fc ff ff       	call   800d46 <sys_page_map>
			if (r<0) return r;
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 8b                	js     801036 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	68 05 08 00 00       	push   $0x805
  8010b3:	56                   	push   %esi
  8010b4:	6a 00                	push   $0x0
  8010b6:	56                   	push   %esi
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 88 fc ff ff       	call   800d46 <sys_page_map>
  8010be:	83 c4 20             	add    $0x20,%esp
  8010c1:	e9 70 ff ff ff       	jmp    801036 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	6a 05                	push   $0x5
  8010cb:	56                   	push   %esi
  8010cc:	57                   	push   %edi
  8010cd:	56                   	push   %esi
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 71 fc ff ff       	call   800d46 <sys_page_map>
  8010d5:	83 c4 20             	add    $0x20,%esp
  8010d8:	e9 59 ff ff ff       	jmp    801036 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	6a 07                	push   $0x7
  8010e2:	68 00 f0 bf ee       	push   $0xeebff000
  8010e7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8010ea:	56                   	push   %esi
  8010eb:	e8 30 fc ff ff       	call   800d20 <sys_page_alloc>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 2b                	js     801122 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	68 0b 25 80 00       	push   $0x80250b
  8010ff:	56                   	push   %esi
  801100:	e8 d5 fc ff ff       	call   800dda <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801105:	83 c4 08             	add    $0x8,%esp
  801108:	6a 02                	push   $0x2
  80110a:	56                   	push   %esi
  80110b:	e8 80 fc ff ff       	call   800d90 <sys_env_set_status>
  801110:	83 c4 10             	add    $0x10,%esp
		return r;
  801113:	85 c0                	test   %eax,%eax
  801115:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801118:	89 f8                	mov    %edi,%eax
  80111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    
		return r;
  801122:	89 c7                	mov    %eax,%edi
  801124:	eb f2                	jmp    801118 <fork+0x165>

00801126 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801126:	f3 0f 1e fb          	endbr32 
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801130:	68 65 2c 80 00       	push   $0x802c65
  801135:	68 b2 00 00 00       	push   $0xb2
  80113a:	68 3e 2c 80 00       	push   $0x802c3e
  80113f:	e8 0a 13 00 00       	call   80244e <_panic>

00801144 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801144:	f3 0f 1e fb          	endbr32 
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	8b 75 08             	mov    0x8(%ebp),%esi
  801150:	8b 45 0c             	mov    0xc(%ebp),%eax
  801153:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801156:	85 c0                	test   %eax,%eax
  801158:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80115d:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	50                   	push   %eax
  801164:	e8 bd fc ff ff       	call   800e26 <sys_ipc_recv>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	75 2b                	jne    80119b <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  801170:	85 f6                	test   %esi,%esi
  801172:	74 0a                	je     80117e <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801174:	a1 08 40 80 00       	mov    0x804008,%eax
  801179:	8b 40 74             	mov    0x74(%eax),%eax
  80117c:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80117e:	85 db                	test   %ebx,%ebx
  801180:	74 0a                	je     80118c <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  801182:	a1 08 40 80 00       	mov    0x804008,%eax
  801187:	8b 40 78             	mov    0x78(%eax),%eax
  80118a:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  80118c:	a1 08 40 80 00       	mov    0x804008,%eax
  801191:	8b 40 70             	mov    0x70(%eax),%eax
}
  801194:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  80119b:	85 f6                	test   %esi,%esi
  80119d:	74 06                	je     8011a5 <ipc_recv+0x61>
  80119f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8011a5:	85 db                	test   %ebx,%ebx
  8011a7:	74 eb                	je     801194 <ipc_recv+0x50>
  8011a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011af:	eb e3                	jmp    801194 <ipc_recv+0x50>

008011b1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011b1:	f3 0f 1e fb          	endbr32 
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	57                   	push   %edi
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8011c7:	85 db                	test   %ebx,%ebx
  8011c9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011ce:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8011d1:	ff 75 14             	pushl  0x14(%ebp)
  8011d4:	53                   	push   %ebx
  8011d5:	56                   	push   %esi
  8011d6:	57                   	push   %edi
  8011d7:	e8 23 fc ff ff       	call   800dff <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011e2:	75 07                	jne    8011eb <ipc_send+0x3a>
			sys_yield();
  8011e4:	e8 14 fb ff ff       	call   800cfd <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8011e9:	eb e6                	jmp    8011d1 <ipc_send+0x20>
		}
		else if (ret == 0)
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	75 08                	jne    8011f7 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8011f7:	50                   	push   %eax
  8011f8:	68 7b 2c 80 00       	push   $0x802c7b
  8011fd:	6a 48                	push   $0x48
  8011ff:	68 89 2c 80 00       	push   $0x802c89
  801204:	e8 45 12 00 00       	call   80244e <_panic>

00801209 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801209:	f3 0f 1e fb          	endbr32 
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801213:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801218:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80121b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801221:	8b 52 50             	mov    0x50(%edx),%edx
  801224:	39 ca                	cmp    %ecx,%edx
  801226:	74 11                	je     801239 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801228:	83 c0 01             	add    $0x1,%eax
  80122b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801230:	75 e6                	jne    801218 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
  801237:	eb 0b                	jmp    801244 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801239:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80123c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801241:	8b 40 48             	mov    0x48(%eax),%eax
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801246:	f3 0f 1e fb          	endbr32 
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124d:	8b 45 08             	mov    0x8(%ebp),%eax
  801250:	05 00 00 00 30       	add    $0x30000000,%eax
  801255:	c1 e8 0c             	shr    $0xc,%eax
}
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80125a:	f3 0f 1e fb          	endbr32 
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801261:	8b 45 08             	mov    0x8(%ebp),%eax
  801264:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801269:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80126e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801275:	f3 0f 1e fb          	endbr32 
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 16             	shr    $0x16,%edx
  801286:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 2d                	je     8012bf <fd_alloc+0x4a>
  801292:	89 c2                	mov    %eax,%edx
  801294:	c1 ea 0c             	shr    $0xc,%edx
  801297:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129e:	f6 c2 01             	test   $0x1,%dl
  8012a1:	74 1c                	je     8012bf <fd_alloc+0x4a>
  8012a3:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ad:	75 d2                	jne    801281 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8012af:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012b8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012bd:	eb 0a                	jmp    8012c9 <fd_alloc+0x54>
			*fd_store = fd;
  8012bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012cb:	f3 0f 1e fb          	endbr32 
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d5:	83 f8 1f             	cmp    $0x1f,%eax
  8012d8:	77 30                	ja     80130a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012da:	c1 e0 0c             	shl    $0xc,%eax
  8012dd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e2:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012e8:	f6 c2 01             	test   $0x1,%dl
  8012eb:	74 24                	je     801311 <fd_lookup+0x46>
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	c1 ea 0c             	shr    $0xc,%edx
  8012f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	74 1a                	je     801318 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801301:	89 02                	mov    %eax,(%edx)
	return 0;
  801303:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    
		return -E_INVAL;
  80130a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130f:	eb f7                	jmp    801308 <fd_lookup+0x3d>
		return -E_INVAL;
  801311:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801316:	eb f0                	jmp    801308 <fd_lookup+0x3d>
  801318:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131d:	eb e9                	jmp    801308 <fd_lookup+0x3d>

0080131f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80131f:	f3 0f 1e fb          	endbr32 
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80132c:	ba 00 00 00 00       	mov    $0x0,%edx
  801331:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801336:	39 08                	cmp    %ecx,(%eax)
  801338:	74 38                	je     801372 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80133a:	83 c2 01             	add    $0x1,%edx
  80133d:	8b 04 95 10 2d 80 00 	mov    0x802d10(,%edx,4),%eax
  801344:	85 c0                	test   %eax,%eax
  801346:	75 ee                	jne    801336 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801348:	a1 08 40 80 00       	mov    0x804008,%eax
  80134d:	8b 40 48             	mov    0x48(%eax),%eax
  801350:	83 ec 04             	sub    $0x4,%esp
  801353:	51                   	push   %ecx
  801354:	50                   	push   %eax
  801355:	68 94 2c 80 00       	push   $0x802c94
  80135a:	e8 4e ef ff ff       	call   8002ad <cprintf>
	*dev = 0;
  80135f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801362:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801370:	c9                   	leave  
  801371:	c3                   	ret    
			*dev = devtab[i];
  801372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801375:	89 01                	mov    %eax,(%ecx)
			return 0;
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
  80137c:	eb f2                	jmp    801370 <dev_lookup+0x51>

0080137e <fd_close>:
{
  80137e:	f3 0f 1e fb          	endbr32 
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 24             	sub    $0x24,%esp
  80138b:	8b 75 08             	mov    0x8(%ebp),%esi
  80138e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801391:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801394:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801395:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80139b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139e:	50                   	push   %eax
  80139f:	e8 27 ff ff ff       	call   8012cb <fd_lookup>
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 05                	js     8013b2 <fd_close+0x34>
	    || fd != fd2)
  8013ad:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013b0:	74 16                	je     8013c8 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8013b2:	89 f8                	mov    %edi,%eax
  8013b4:	84 c0                	test   %al,%al
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bb:	0f 44 d8             	cmove  %eax,%ebx
}
  8013be:	89 d8                	mov    %ebx,%eax
  8013c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013ce:	50                   	push   %eax
  8013cf:	ff 36                	pushl  (%esi)
  8013d1:	e8 49 ff ff ff       	call   80131f <dev_lookup>
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 1a                	js     8013f9 <fd_close+0x7b>
		if (dev->dev_close)
  8013df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e2:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 0b                	je     8013f9 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	56                   	push   %esi
  8013f2:	ff d0                	call   *%eax
  8013f4:	89 c3                	mov    %eax,%ebx
  8013f6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	56                   	push   %esi
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 67 f9 ff ff       	call   800d6b <sys_page_unmap>
	return r;
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	eb b5                	jmp    8013be <fd_close+0x40>

00801409 <close>:

int
close(int fdnum)
{
  801409:	f3 0f 1e fb          	endbr32 
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 ac fe ff ff       	call   8012cb <fd_lookup>
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	79 02                	jns    801428 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    
		return fd_close(fd, 1);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	6a 01                	push   $0x1
  80142d:	ff 75 f4             	pushl  -0xc(%ebp)
  801430:	e8 49 ff ff ff       	call   80137e <fd_close>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	eb ec                	jmp    801426 <close+0x1d>

0080143a <close_all>:

void
close_all(void)
{
  80143a:	f3 0f 1e fb          	endbr32 
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	53                   	push   %ebx
  801442:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801445:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	53                   	push   %ebx
  80144e:	e8 b6 ff ff ff       	call   801409 <close>
	for (i = 0; i < MAXFD; i++)
  801453:	83 c3 01             	add    $0x1,%ebx
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	83 fb 20             	cmp    $0x20,%ebx
  80145c:	75 ec                	jne    80144a <close_all+0x10>
}
  80145e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801463:	f3 0f 1e fb          	endbr32 
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	57                   	push   %edi
  80146b:	56                   	push   %esi
  80146c:	53                   	push   %ebx
  80146d:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801470:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 75 08             	pushl  0x8(%ebp)
  801477:	e8 4f fe ff ff       	call   8012cb <fd_lookup>
  80147c:	89 c3                	mov    %eax,%ebx
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	85 c0                	test   %eax,%eax
  801483:	0f 88 81 00 00 00    	js     80150a <dup+0xa7>
		return r;
	close(newfdnum);
  801489:	83 ec 0c             	sub    $0xc,%esp
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	e8 75 ff ff ff       	call   801409 <close>

	newfd = INDEX2FD(newfdnum);
  801494:	8b 75 0c             	mov    0xc(%ebp),%esi
  801497:	c1 e6 0c             	shl    $0xc,%esi
  80149a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014a0:	83 c4 04             	add    $0x4,%esp
  8014a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a6:	e8 af fd ff ff       	call   80125a <fd2data>
  8014ab:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014ad:	89 34 24             	mov    %esi,(%esp)
  8014b0:	e8 a5 fd ff ff       	call   80125a <fd2data>
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	c1 e8 16             	shr    $0x16,%eax
  8014bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c6:	a8 01                	test   $0x1,%al
  8014c8:	74 11                	je     8014db <dup+0x78>
  8014ca:	89 d8                	mov    %ebx,%eax
  8014cc:	c1 e8 0c             	shr    $0xc,%eax
  8014cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d6:	f6 c2 01             	test   $0x1,%dl
  8014d9:	75 39                	jne    801514 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014de:	89 d0                	mov    %edx,%eax
  8014e0:	c1 e8 0c             	shr    $0xc,%eax
  8014e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f2:	50                   	push   %eax
  8014f3:	56                   	push   %esi
  8014f4:	6a 00                	push   $0x0
  8014f6:	52                   	push   %edx
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 48 f8 ff ff       	call   800d46 <sys_page_map>
  8014fe:	89 c3                	mov    %eax,%ebx
  801500:	83 c4 20             	add    $0x20,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	78 31                	js     801538 <dup+0xd5>
		goto err;

	return newfdnum;
  801507:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80150a:	89 d8                	mov    %ebx,%eax
  80150c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150f:	5b                   	pop    %ebx
  801510:	5e                   	pop    %esi
  801511:	5f                   	pop    %edi
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801514:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	25 07 0e 00 00       	and    $0xe07,%eax
  801523:	50                   	push   %eax
  801524:	57                   	push   %edi
  801525:	6a 00                	push   $0x0
  801527:	53                   	push   %ebx
  801528:	6a 00                	push   $0x0
  80152a:	e8 17 f8 ff ff       	call   800d46 <sys_page_map>
  80152f:	89 c3                	mov    %eax,%ebx
  801531:	83 c4 20             	add    $0x20,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	79 a3                	jns    8014db <dup+0x78>
	sys_page_unmap(0, newfd);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	56                   	push   %esi
  80153c:	6a 00                	push   $0x0
  80153e:	e8 28 f8 ff ff       	call   800d6b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801543:	83 c4 08             	add    $0x8,%esp
  801546:	57                   	push   %edi
  801547:	6a 00                	push   $0x0
  801549:	e8 1d f8 ff ff       	call   800d6b <sys_page_unmap>
	return r;
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	eb b7                	jmp    80150a <dup+0xa7>

00801553 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801553:	f3 0f 1e fb          	endbr32 
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	53                   	push   %ebx
  80155b:	83 ec 1c             	sub    $0x1c,%esp
  80155e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801561:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	53                   	push   %ebx
  801566:	e8 60 fd ff ff       	call   8012cb <fd_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 3f                	js     8015b1 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157c:	ff 30                	pushl  (%eax)
  80157e:	e8 9c fd ff ff       	call   80131f <dev_lookup>
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 27                	js     8015b1 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80158a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80158d:	8b 42 08             	mov    0x8(%edx),%eax
  801590:	83 e0 03             	and    $0x3,%eax
  801593:	83 f8 01             	cmp    $0x1,%eax
  801596:	74 1e                	je     8015b6 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	8b 40 08             	mov    0x8(%eax),%eax
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	74 35                	je     8015d7 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	ff 75 10             	pushl  0x10(%ebp)
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	52                   	push   %edx
  8015ac:	ff d0                	call   *%eax
  8015ae:	83 c4 10             	add    $0x10,%esp
}
  8015b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8015bb:	8b 40 48             	mov    0x48(%eax),%eax
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	50                   	push   %eax
  8015c3:	68 d5 2c 80 00       	push   $0x802cd5
  8015c8:	e8 e0 ec ff ff       	call   8002ad <cprintf>
		return -E_INVAL;
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d5:	eb da                	jmp    8015b1 <read+0x5e>
		return -E_NOT_SUPP;
  8015d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015dc:	eb d3                	jmp    8015b1 <read+0x5e>

008015de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015de:	f3 0f 1e fb          	endbr32 
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	57                   	push   %edi
  8015e6:	56                   	push   %esi
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f6:	eb 02                	jmp    8015fa <readn+0x1c>
  8015f8:	01 c3                	add    %eax,%ebx
  8015fa:	39 f3                	cmp    %esi,%ebx
  8015fc:	73 21                	jae    80161f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	89 f0                	mov    %esi,%eax
  801603:	29 d8                	sub    %ebx,%eax
  801605:	50                   	push   %eax
  801606:	89 d8                	mov    %ebx,%eax
  801608:	03 45 0c             	add    0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	57                   	push   %edi
  80160d:	e8 41 ff ff ff       	call   801553 <read>
		if (m < 0)
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 04                	js     80161d <readn+0x3f>
			return m;
		if (m == 0)
  801619:	75 dd                	jne    8015f8 <readn+0x1a>
  80161b:	eb 02                	jmp    80161f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80161d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80161f:	89 d8                	mov    %ebx,%eax
  801621:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5f                   	pop    %edi
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801629:	f3 0f 1e fb          	endbr32 
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	53                   	push   %ebx
  801631:	83 ec 1c             	sub    $0x1c,%esp
  801634:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801637:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	53                   	push   %ebx
  80163c:	e8 8a fc ff ff       	call   8012cb <fd_lookup>
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	85 c0                	test   %eax,%eax
  801646:	78 3a                	js     801682 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	ff 30                	pushl  (%eax)
  801654:	e8 c6 fc ff ff       	call   80131f <dev_lookup>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	78 22                	js     801682 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801667:	74 1e                	je     801687 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801669:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166c:	8b 52 0c             	mov    0xc(%edx),%edx
  80166f:	85 d2                	test   %edx,%edx
  801671:	74 35                	je     8016a8 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801673:	83 ec 04             	sub    $0x4,%esp
  801676:	ff 75 10             	pushl  0x10(%ebp)
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	50                   	push   %eax
  80167d:	ff d2                	call   *%edx
  80167f:	83 c4 10             	add    $0x10,%esp
}
  801682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801685:	c9                   	leave  
  801686:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801687:	a1 08 40 80 00       	mov    0x804008,%eax
  80168c:	8b 40 48             	mov    0x48(%eax),%eax
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	53                   	push   %ebx
  801693:	50                   	push   %eax
  801694:	68 f1 2c 80 00       	push   $0x802cf1
  801699:	e8 0f ec ff ff       	call   8002ad <cprintf>
		return -E_INVAL;
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a6:	eb da                	jmp    801682 <write+0x59>
		return -E_NOT_SUPP;
  8016a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ad:	eb d3                	jmp    801682 <write+0x59>

008016af <seek>:

int
seek(int fdnum, off_t offset)
{
  8016af:	f3 0f 1e fb          	endbr32 
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bc:	50                   	push   %eax
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 06 fc ff ff       	call   8012cb <fd_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 0e                	js     8016da <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8016cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016dc:	f3 0f 1e fb          	endbr32 
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 1c             	sub    $0x1c,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	53                   	push   %ebx
  8016ef:	e8 d7 fb ff ff       	call   8012cb <fd_lookup>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 37                	js     801732 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801705:	ff 30                	pushl  (%eax)
  801707:	e8 13 fc ff ff       	call   80131f <dev_lookup>
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 1f                	js     801732 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801716:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171a:	74 1b                	je     801737 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80171c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80171f:	8b 52 18             	mov    0x18(%edx),%edx
  801722:	85 d2                	test   %edx,%edx
  801724:	74 32                	je     801758 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	ff 75 0c             	pushl  0xc(%ebp)
  80172c:	50                   	push   %eax
  80172d:	ff d2                	call   *%edx
  80172f:	83 c4 10             	add    $0x10,%esp
}
  801732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801735:	c9                   	leave  
  801736:	c3                   	ret    
			thisenv->env_id, fdnum);
  801737:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80173c:	8b 40 48             	mov    0x48(%eax),%eax
  80173f:	83 ec 04             	sub    $0x4,%esp
  801742:	53                   	push   %ebx
  801743:	50                   	push   %eax
  801744:	68 b4 2c 80 00       	push   $0x802cb4
  801749:	e8 5f eb ff ff       	call   8002ad <cprintf>
		return -E_INVAL;
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801756:	eb da                	jmp    801732 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801758:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80175d:	eb d3                	jmp    801732 <ftruncate+0x56>

0080175f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80175f:	f3 0f 1e fb          	endbr32 
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	53                   	push   %ebx
  801767:	83 ec 1c             	sub    $0x1c,%esp
  80176a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	ff 75 08             	pushl  0x8(%ebp)
  801774:	e8 52 fb ff ff       	call   8012cb <fd_lookup>
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 4b                	js     8017cb <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801786:	50                   	push   %eax
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	ff 30                	pushl  (%eax)
  80178c:	e8 8e fb ff ff       	call   80131f <dev_lookup>
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	78 33                	js     8017cb <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80179f:	74 2f                	je     8017d0 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ab:	00 00 00 
	stat->st_isdir = 0;
  8017ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b5:	00 00 00 
	stat->st_dev = dev;
  8017b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	53                   	push   %ebx
  8017c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c5:	ff 50 14             	call   *0x14(%eax)
  8017c8:	83 c4 10             	add    $0x10,%esp
}
  8017cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    
		return -E_NOT_SUPP;
  8017d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d5:	eb f4                	jmp    8017cb <fstat+0x6c>

008017d7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d7:	f3 0f 1e fb          	endbr32 
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e0:	83 ec 08             	sub    $0x8,%esp
  8017e3:	6a 00                	push   $0x0
  8017e5:	ff 75 08             	pushl  0x8(%ebp)
  8017e8:	e8 01 02 00 00       	call   8019ee <open>
  8017ed:	89 c3                	mov    %eax,%ebx
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	78 1b                	js     801811 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	ff 75 0c             	pushl  0xc(%ebp)
  8017fc:	50                   	push   %eax
  8017fd:	e8 5d ff ff ff       	call   80175f <fstat>
  801802:	89 c6                	mov    %eax,%esi
	close(fd);
  801804:	89 1c 24             	mov    %ebx,(%esp)
  801807:	e8 fd fb ff ff       	call   801409 <close>
	return r;
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	89 f3                	mov    %esi,%ebx
}
  801811:	89 d8                	mov    %ebx,%eax
  801813:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	56                   	push   %esi
  80181e:	53                   	push   %ebx
  80181f:	89 c6                	mov    %eax,%esi
  801821:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801823:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182a:	74 27                	je     801853 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80182c:	6a 07                	push   $0x7
  80182e:	68 00 50 80 00       	push   $0x805000
  801833:	56                   	push   %esi
  801834:	ff 35 00 40 80 00    	pushl  0x804000
  80183a:	e8 72 f9 ff ff       	call   8011b1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183f:	83 c4 0c             	add    $0xc,%esp
  801842:	6a 00                	push   $0x0
  801844:	53                   	push   %ebx
  801845:	6a 00                	push   $0x0
  801847:	e8 f8 f8 ff ff       	call   801144 <ipc_recv>
}
  80184c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184f:	5b                   	pop    %ebx
  801850:	5e                   	pop    %esi
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	6a 01                	push   $0x1
  801858:	e8 ac f9 ff ff       	call   801209 <ipc_find_env>
  80185d:	a3 00 40 80 00       	mov    %eax,0x804000
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	eb c5                	jmp    80182c <fsipc+0x12>

00801867 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801867:	f3 0f 1e fb          	endbr32 
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 40 0c             	mov    0xc(%eax),%eax
  801877:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80187c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801884:	ba 00 00 00 00       	mov    $0x0,%edx
  801889:	b8 02 00 00 00       	mov    $0x2,%eax
  80188e:	e8 87 ff ff ff       	call   80181a <fsipc>
}
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <devfile_flush>:
{
  801895:	f3 0f 1e fb          	endbr32 
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b4:	e8 61 ff ff ff       	call   80181a <fsipc>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <devfile_stat>:
{
  8018bb:	f3 0f 1e fb          	endbr32 
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8018de:	e8 37 ff ff ff       	call   80181a <fsipc>
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 2c                	js     801913 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	68 00 50 80 00       	push   $0x805000
  8018ef:	53                   	push   %ebx
  8018f0:	e8 c2 ef ff ff       	call   8008b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018fa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801900:	a1 84 50 80 00       	mov    0x805084,%eax
  801905:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801913:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <devfile_write>:
{
  801918:	f3 0f 1e fb          	endbr32 
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 0c             	sub    $0xc,%esp
  801922:	8b 45 10             	mov    0x10(%ebp),%eax
  801925:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80192a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80192f:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801932:	8b 55 08             	mov    0x8(%ebp),%edx
  801935:	8b 52 0c             	mov    0xc(%edx),%edx
  801938:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80193e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801943:	50                   	push   %eax
  801944:	ff 75 0c             	pushl  0xc(%ebp)
  801947:	68 08 50 80 00       	push   $0x805008
  80194c:	e8 64 f1 ff ff       	call   800ab5 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	b8 04 00 00 00       	mov    $0x4,%eax
  80195b:	e8 ba fe ff ff       	call   80181a <fsipc>
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devfile_read>:
{
  801962:	f3 0f 1e fb          	endbr32 
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	56                   	push   %esi
  80196a:	53                   	push   %ebx
  80196b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	8b 40 0c             	mov    0xc(%eax),%eax
  801974:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801979:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80197f:	ba 00 00 00 00       	mov    $0x0,%edx
  801984:	b8 03 00 00 00       	mov    $0x3,%eax
  801989:	e8 8c fe ff ff       	call   80181a <fsipc>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	85 c0                	test   %eax,%eax
  801992:	78 1f                	js     8019b3 <devfile_read+0x51>
	assert(r <= n);
  801994:	39 f0                	cmp    %esi,%eax
  801996:	77 24                	ja     8019bc <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801998:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80199d:	7f 36                	jg     8019d5 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80199f:	83 ec 04             	sub    $0x4,%esp
  8019a2:	50                   	push   %eax
  8019a3:	68 00 50 80 00       	push   $0x805000
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	e8 05 f1 ff ff       	call   800ab5 <memmove>
	return r;
  8019b0:	83 c4 10             	add    $0x10,%esp
}
  8019b3:	89 d8                	mov    %ebx,%eax
  8019b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5d                   	pop    %ebp
  8019bb:	c3                   	ret    
	assert(r <= n);
  8019bc:	68 24 2d 80 00       	push   $0x802d24
  8019c1:	68 2b 2d 80 00       	push   $0x802d2b
  8019c6:	68 8c 00 00 00       	push   $0x8c
  8019cb:	68 40 2d 80 00       	push   $0x802d40
  8019d0:	e8 79 0a 00 00       	call   80244e <_panic>
	assert(r <= PGSIZE);
  8019d5:	68 4b 2d 80 00       	push   $0x802d4b
  8019da:	68 2b 2d 80 00       	push   $0x802d2b
  8019df:	68 8d 00 00 00       	push   $0x8d
  8019e4:	68 40 2d 80 00       	push   $0x802d40
  8019e9:	e8 60 0a 00 00       	call   80244e <_panic>

008019ee <open>:
{
  8019ee:	f3 0f 1e fb          	endbr32 
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 1c             	sub    $0x1c,%esp
  8019fa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019fd:	56                   	push   %esi
  8019fe:	e8 71 ee ff ff       	call   800874 <strlen>
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a0b:	7f 6c                	jg     801a79 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a13:	50                   	push   %eax
  801a14:	e8 5c f8 ff ff       	call   801275 <fd_alloc>
  801a19:	89 c3                	mov    %eax,%ebx
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 3c                	js     801a5e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	56                   	push   %esi
  801a26:	68 00 50 80 00       	push   $0x805000
  801a2b:	e8 87 ee ff ff       	call   8008b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a33:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a40:	e8 d5 fd ff ff       	call   80181a <fsipc>
  801a45:	89 c3                	mov    %eax,%ebx
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 19                	js     801a67 <open+0x79>
	return fd2num(fd);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	ff 75 f4             	pushl  -0xc(%ebp)
  801a54:	e8 ed f7 ff ff       	call   801246 <fd2num>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	83 c4 10             	add    $0x10,%esp
}
  801a5e:	89 d8                	mov    %ebx,%eax
  801a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5d                   	pop    %ebp
  801a66:	c3                   	ret    
		fd_close(fd, 0);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	6a 00                	push   $0x0
  801a6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6f:	e8 0a f9 ff ff       	call   80137e <fd_close>
		return r;
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	eb e5                	jmp    801a5e <open+0x70>
		return -E_BAD_PATH;
  801a79:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a7e:	eb de                	jmp    801a5e <open+0x70>

00801a80 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a80:	f3 0f 1e fb          	endbr32 
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a94:	e8 81 fd ff ff       	call   80181a <fsipc>
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a9b:	f3 0f 1e fb          	endbr32 
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aa5:	68 b7 2d 80 00       	push   $0x802db7
  801aaa:	ff 75 0c             	pushl  0xc(%ebp)
  801aad:	e8 05 ee ff ff       	call   8008b7 <strcpy>
	return 0;
}
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <devsock_close>:
{
  801ab9:	f3 0f 1e fb          	endbr32 
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 10             	sub    $0x10,%esp
  801ac4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ac7:	53                   	push   %ebx
  801ac8:	e8 62 0a 00 00       	call   80252f <pageref>
  801acd:	89 c2                	mov    %eax,%edx
  801acf:	83 c4 10             	add    $0x10,%esp
		return 0;
  801ad2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801ad7:	83 fa 01             	cmp    $0x1,%edx
  801ada:	74 05                	je     801ae1 <devsock_close+0x28>
}
  801adc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 73 0c             	pushl  0xc(%ebx)
  801ae7:	e8 e3 02 00 00       	call   801dcf <nsipc_close>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	eb eb                	jmp    801adc <devsock_close+0x23>

00801af1 <devsock_write>:
{
  801af1:	f3 0f 1e fb          	endbr32 
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801afb:	6a 00                	push   $0x0
  801afd:	ff 75 10             	pushl  0x10(%ebp)
  801b00:	ff 75 0c             	pushl  0xc(%ebp)
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	ff 70 0c             	pushl  0xc(%eax)
  801b09:	e8 b5 03 00 00       	call   801ec3 <nsipc_send>
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devsock_read>:
{
  801b10:	f3 0f 1e fb          	endbr32 
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b1a:	6a 00                	push   $0x0
  801b1c:	ff 75 10             	pushl  0x10(%ebp)
  801b1f:	ff 75 0c             	pushl  0xc(%ebp)
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	ff 70 0c             	pushl  0xc(%eax)
  801b28:	e8 1f 03 00 00       	call   801e4c <nsipc_recv>
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <fd2sockid>:
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b35:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b38:	52                   	push   %edx
  801b39:	50                   	push   %eax
  801b3a:	e8 8c f7 ff ff       	call   8012cb <fd_lookup>
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 10                	js     801b56 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b49:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801b4f:	39 08                	cmp    %ecx,(%eax)
  801b51:	75 05                	jne    801b58 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b53:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    
		return -E_NOT_SUPP;
  801b58:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b5d:	eb f7                	jmp    801b56 <fd2sockid+0x27>

00801b5f <alloc_sockfd>:
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6c:	50                   	push   %eax
  801b6d:	e8 03 f7 ff ff       	call   801275 <fd_alloc>
  801b72:	89 c3                	mov    %eax,%ebx
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	85 c0                	test   %eax,%eax
  801b79:	78 43                	js     801bbe <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b7b:	83 ec 04             	sub    $0x4,%esp
  801b7e:	68 07 04 00 00       	push   $0x407
  801b83:	ff 75 f4             	pushl  -0xc(%ebp)
  801b86:	6a 00                	push   $0x0
  801b88:	e8 93 f1 ff ff       	call   800d20 <sys_page_alloc>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	78 28                	js     801bbe <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b99:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801b9f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bab:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	50                   	push   %eax
  801bb2:	e8 8f f6 ff ff       	call   801246 <fd2num>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	eb 0c                	jmp    801bca <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	56                   	push   %esi
  801bc2:	e8 08 02 00 00       	call   801dcf <nsipc_close>
		return r;
  801bc7:	83 c4 10             	add    $0x10,%esp
}
  801bca:	89 d8                	mov    %ebx,%eax
  801bcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <accept>:
{
  801bd3:	f3 0f 1e fb          	endbr32 
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801be0:	e8 4a ff ff ff       	call   801b2f <fd2sockid>
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 1b                	js     801c04 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801be9:	83 ec 04             	sub    $0x4,%esp
  801bec:	ff 75 10             	pushl  0x10(%ebp)
  801bef:	ff 75 0c             	pushl  0xc(%ebp)
  801bf2:	50                   	push   %eax
  801bf3:	e8 22 01 00 00       	call   801d1a <nsipc_accept>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 05                	js     801c04 <accept+0x31>
	return alloc_sockfd(r);
  801bff:	e8 5b ff ff ff       	call   801b5f <alloc_sockfd>
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <bind>:
{
  801c06:	f3 0f 1e fb          	endbr32 
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	e8 17 ff ff ff       	call   801b2f <fd2sockid>
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 12                	js     801c2e <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	ff 75 10             	pushl  0x10(%ebp)
  801c22:	ff 75 0c             	pushl  0xc(%ebp)
  801c25:	50                   	push   %eax
  801c26:	e8 45 01 00 00       	call   801d70 <nsipc_bind>
  801c2b:	83 c4 10             	add    $0x10,%esp
}
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <shutdown>:
{
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3d:	e8 ed fe ff ff       	call   801b2f <fd2sockid>
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 0f                	js     801c55 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801c46:	83 ec 08             	sub    $0x8,%esp
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	50                   	push   %eax
  801c4d:	e8 57 01 00 00       	call   801da9 <nsipc_shutdown>
  801c52:	83 c4 10             	add    $0x10,%esp
}
  801c55:	c9                   	leave  
  801c56:	c3                   	ret    

00801c57 <connect>:
{
  801c57:	f3 0f 1e fb          	endbr32 
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c61:	8b 45 08             	mov    0x8(%ebp),%eax
  801c64:	e8 c6 fe ff ff       	call   801b2f <fd2sockid>
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 12                	js     801c7f <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	ff 75 10             	pushl  0x10(%ebp)
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	50                   	push   %eax
  801c77:	e8 71 01 00 00       	call   801ded <nsipc_connect>
  801c7c:	83 c4 10             	add    $0x10,%esp
}
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <listen>:
{
  801c81:	f3 0f 1e fb          	endbr32 
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8e:	e8 9c fe ff ff       	call   801b2f <fd2sockid>
  801c93:	85 c0                	test   %eax,%eax
  801c95:	78 0f                	js     801ca6 <listen+0x25>
	return nsipc_listen(r, backlog);
  801c97:	83 ec 08             	sub    $0x8,%esp
  801c9a:	ff 75 0c             	pushl  0xc(%ebp)
  801c9d:	50                   	push   %eax
  801c9e:	e8 83 01 00 00       	call   801e26 <nsipc_listen>
  801ca3:	83 c4 10             	add    $0x10,%esp
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <socket>:

int
socket(int domain, int type, int protocol)
{
  801ca8:	f3 0f 1e fb          	endbr32 
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cb2:	ff 75 10             	pushl  0x10(%ebp)
  801cb5:	ff 75 0c             	pushl  0xc(%ebp)
  801cb8:	ff 75 08             	pushl  0x8(%ebp)
  801cbb:	e8 65 02 00 00       	call   801f25 <nsipc_socket>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 05                	js     801ccc <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801cc7:	e8 93 fe ff ff       	call   801b5f <alloc_sockfd>
}
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 04             	sub    $0x4,%esp
  801cd5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cd7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cde:	74 26                	je     801d06 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ce0:	6a 07                	push   $0x7
  801ce2:	68 00 60 80 00       	push   $0x806000
  801ce7:	53                   	push   %ebx
  801ce8:	ff 35 04 40 80 00    	pushl  0x804004
  801cee:	e8 be f4 ff ff       	call   8011b1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cf3:	83 c4 0c             	add    $0xc,%esp
  801cf6:	6a 00                	push   $0x0
  801cf8:	6a 00                	push   $0x0
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 43 f4 ff ff       	call   801144 <ipc_recv>
}
  801d01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	6a 02                	push   $0x2
  801d0b:	e8 f9 f4 ff ff       	call   801209 <ipc_find_env>
  801d10:	a3 04 40 80 00       	mov    %eax,0x804004
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	eb c6                	jmp    801ce0 <nsipc+0x12>

00801d1a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d1a:	f3 0f 1e fb          	endbr32 
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	56                   	push   %esi
  801d22:	53                   	push   %ebx
  801d23:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d2e:	8b 06                	mov    (%esi),%eax
  801d30:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d35:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3a:	e8 8f ff ff ff       	call   801cce <nsipc>
  801d3f:	89 c3                	mov    %eax,%ebx
  801d41:	85 c0                	test   %eax,%eax
  801d43:	79 09                	jns    801d4e <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801d45:	89 d8                	mov    %ebx,%eax
  801d47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d4e:	83 ec 04             	sub    $0x4,%esp
  801d51:	ff 35 10 60 80 00    	pushl  0x806010
  801d57:	68 00 60 80 00       	push   $0x806000
  801d5c:	ff 75 0c             	pushl  0xc(%ebp)
  801d5f:	e8 51 ed ff ff       	call   800ab5 <memmove>
		*addrlen = ret->ret_addrlen;
  801d64:	a1 10 60 80 00       	mov    0x806010,%eax
  801d69:	89 06                	mov    %eax,(%esi)
  801d6b:	83 c4 10             	add    $0x10,%esp
	return r;
  801d6e:	eb d5                	jmp    801d45 <nsipc_accept+0x2b>

00801d70 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d70:	f3 0f 1e fb          	endbr32 
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	53                   	push   %ebx
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d86:	53                   	push   %ebx
  801d87:	ff 75 0c             	pushl  0xc(%ebp)
  801d8a:	68 04 60 80 00       	push   $0x806004
  801d8f:	e8 21 ed ff ff       	call   800ab5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d94:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d9a:	b8 02 00 00 00       	mov    $0x2,%eax
  801d9f:	e8 2a ff ff ff       	call   801cce <nsipc>
}
  801da4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801da9:	f3 0f 1e fb          	endbr32 
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801db3:	8b 45 08             	mov    0x8(%ebp),%eax
  801db6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbe:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801dc3:	b8 03 00 00 00       	mov    $0x3,%eax
  801dc8:	e8 01 ff ff ff       	call   801cce <nsipc>
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <nsipc_close>:

int
nsipc_close(int s)
{
  801dcf:	f3 0f 1e fb          	endbr32 
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801de1:	b8 04 00 00 00       	mov    $0x4,%eax
  801de6:	e8 e3 fe ff ff       	call   801cce <nsipc>
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ded:	f3 0f 1e fb          	endbr32 
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	53                   	push   %ebx
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e03:	53                   	push   %ebx
  801e04:	ff 75 0c             	pushl  0xc(%ebp)
  801e07:	68 04 60 80 00       	push   $0x806004
  801e0c:	e8 a4 ec ff ff       	call   800ab5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e11:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e17:	b8 05 00 00 00       	mov    $0x5,%eax
  801e1c:	e8 ad fe ff ff       	call   801cce <nsipc>
}
  801e21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e26:	f3 0f 1e fb          	endbr32 
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e30:	8b 45 08             	mov    0x8(%ebp),%eax
  801e33:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e40:	b8 06 00 00 00       	mov    $0x6,%eax
  801e45:	e8 84 fe ff ff       	call   801cce <nsipc>
}
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e4c:	f3 0f 1e fb          	endbr32 
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	56                   	push   %esi
  801e54:	53                   	push   %ebx
  801e55:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e60:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e66:	8b 45 14             	mov    0x14(%ebp),%eax
  801e69:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e6e:	b8 07 00 00 00       	mov    $0x7,%eax
  801e73:	e8 56 fe ff ff       	call   801cce <nsipc>
  801e78:	89 c3                	mov    %eax,%ebx
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	78 26                	js     801ea4 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801e7e:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801e84:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e89:	0f 4e c6             	cmovle %esi,%eax
  801e8c:	39 c3                	cmp    %eax,%ebx
  801e8e:	7f 1d                	jg     801ead <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e90:	83 ec 04             	sub    $0x4,%esp
  801e93:	53                   	push   %ebx
  801e94:	68 00 60 80 00       	push   $0x806000
  801e99:	ff 75 0c             	pushl  0xc(%ebp)
  801e9c:	e8 14 ec ff ff       	call   800ab5 <memmove>
  801ea1:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ea4:	89 d8                	mov    %ebx,%eax
  801ea6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801ead:	68 c3 2d 80 00       	push   $0x802dc3
  801eb2:	68 2b 2d 80 00       	push   $0x802d2b
  801eb7:	6a 62                	push   $0x62
  801eb9:	68 d8 2d 80 00       	push   $0x802dd8
  801ebe:	e8 8b 05 00 00       	call   80244e <_panic>

00801ec3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ec3:	f3 0f 1e fb          	endbr32 
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ed9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801edf:	7f 2e                	jg     801f0f <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ee1:	83 ec 04             	sub    $0x4,%esp
  801ee4:	53                   	push   %ebx
  801ee5:	ff 75 0c             	pushl  0xc(%ebp)
  801ee8:	68 0c 60 80 00       	push   $0x80600c
  801eed:	e8 c3 eb ff ff       	call   800ab5 <memmove>
	nsipcbuf.send.req_size = size;
  801ef2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ef8:	8b 45 14             	mov    0x14(%ebp),%eax
  801efb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f00:	b8 08 00 00 00       	mov    $0x8,%eax
  801f05:	e8 c4 fd ff ff       	call   801cce <nsipc>
}
  801f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    
	assert(size < 1600);
  801f0f:	68 e4 2d 80 00       	push   $0x802de4
  801f14:	68 2b 2d 80 00       	push   $0x802d2b
  801f19:	6a 6d                	push   $0x6d
  801f1b:	68 d8 2d 80 00       	push   $0x802dd8
  801f20:	e8 29 05 00 00       	call   80244e <_panic>

00801f25 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f25:	f3 0f 1e fb          	endbr32 
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f32:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f3f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f42:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f47:	b8 09 00 00 00       	mov    $0x9,%eax
  801f4c:	e8 7d fd ff ff       	call   801cce <nsipc>
}
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f53:	f3 0f 1e fb          	endbr32 
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	56                   	push   %esi
  801f5b:	53                   	push   %ebx
  801f5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	ff 75 08             	pushl  0x8(%ebp)
  801f65:	e8 f0 f2 ff ff       	call   80125a <fd2data>
  801f6a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f6c:	83 c4 08             	add    $0x8,%esp
  801f6f:	68 f0 2d 80 00       	push   $0x802df0
  801f74:	53                   	push   %ebx
  801f75:	e8 3d e9 ff ff       	call   8008b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f7a:	8b 46 04             	mov    0x4(%esi),%eax
  801f7d:	2b 06                	sub    (%esi),%eax
  801f7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f85:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f8c:	00 00 00 
	stat->st_dev = &devpipe;
  801f8f:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801f96:	30 80 00 
	return 0;
}
  801f99:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    

00801fa5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fa5:	f3 0f 1e fb          	endbr32 
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	53                   	push   %ebx
  801fad:	83 ec 0c             	sub    $0xc,%esp
  801fb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fb3:	53                   	push   %ebx
  801fb4:	6a 00                	push   $0x0
  801fb6:	e8 b0 ed ff ff       	call   800d6b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fbb:	89 1c 24             	mov    %ebx,(%esp)
  801fbe:	e8 97 f2 ff ff       	call   80125a <fd2data>
  801fc3:	83 c4 08             	add    $0x8,%esp
  801fc6:	50                   	push   %eax
  801fc7:	6a 00                	push   $0x0
  801fc9:	e8 9d ed ff ff       	call   800d6b <sys_page_unmap>
}
  801fce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <_pipeisclosed>:
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	57                   	push   %edi
  801fd7:	56                   	push   %esi
  801fd8:	53                   	push   %ebx
  801fd9:	83 ec 1c             	sub    $0x1c,%esp
  801fdc:	89 c7                	mov    %eax,%edi
  801fde:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801fe0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fe8:	83 ec 0c             	sub    $0xc,%esp
  801feb:	57                   	push   %edi
  801fec:	e8 3e 05 00 00       	call   80252f <pageref>
  801ff1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ff4:	89 34 24             	mov    %esi,(%esp)
  801ff7:	e8 33 05 00 00       	call   80252f <pageref>
		nn = thisenv->env_runs;
  801ffc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802002:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	39 cb                	cmp    %ecx,%ebx
  80200a:	74 1b                	je     802027 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80200c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80200f:	75 cf                	jne    801fe0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802011:	8b 42 58             	mov    0x58(%edx),%eax
  802014:	6a 01                	push   $0x1
  802016:	50                   	push   %eax
  802017:	53                   	push   %ebx
  802018:	68 f7 2d 80 00       	push   $0x802df7
  80201d:	e8 8b e2 ff ff       	call   8002ad <cprintf>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	eb b9                	jmp    801fe0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802027:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80202a:	0f 94 c0             	sete   %al
  80202d:	0f b6 c0             	movzbl %al,%eax
}
  802030:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    

00802038 <devpipe_write>:
{
  802038:	f3 0f 1e fb          	endbr32 
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	57                   	push   %edi
  802040:	56                   	push   %esi
  802041:	53                   	push   %ebx
  802042:	83 ec 28             	sub    $0x28,%esp
  802045:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802048:	56                   	push   %esi
  802049:	e8 0c f2 ff ff       	call   80125a <fd2data>
  80204e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	bf 00 00 00 00       	mov    $0x0,%edi
  802058:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80205b:	74 4f                	je     8020ac <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80205d:	8b 43 04             	mov    0x4(%ebx),%eax
  802060:	8b 0b                	mov    (%ebx),%ecx
  802062:	8d 51 20             	lea    0x20(%ecx),%edx
  802065:	39 d0                	cmp    %edx,%eax
  802067:	72 14                	jb     80207d <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802069:	89 da                	mov    %ebx,%edx
  80206b:	89 f0                	mov    %esi,%eax
  80206d:	e8 61 ff ff ff       	call   801fd3 <_pipeisclosed>
  802072:	85 c0                	test   %eax,%eax
  802074:	75 3b                	jne    8020b1 <devpipe_write+0x79>
			sys_yield();
  802076:	e8 82 ec ff ff       	call   800cfd <sys_yield>
  80207b:	eb e0                	jmp    80205d <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80207d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802080:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802084:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802087:	89 c2                	mov    %eax,%edx
  802089:	c1 fa 1f             	sar    $0x1f,%edx
  80208c:	89 d1                	mov    %edx,%ecx
  80208e:	c1 e9 1b             	shr    $0x1b,%ecx
  802091:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802094:	83 e2 1f             	and    $0x1f,%edx
  802097:	29 ca                	sub    %ecx,%edx
  802099:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80209d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020a1:	83 c0 01             	add    $0x1,%eax
  8020a4:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8020a7:	83 c7 01             	add    $0x1,%edi
  8020aa:	eb ac                	jmp    802058 <devpipe_write+0x20>
	return i;
  8020ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8020af:	eb 05                	jmp    8020b6 <devpipe_write+0x7e>
				return 0;
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b9:	5b                   	pop    %ebx
  8020ba:	5e                   	pop    %esi
  8020bb:	5f                   	pop    %edi
  8020bc:	5d                   	pop    %ebp
  8020bd:	c3                   	ret    

008020be <devpipe_read>:
{
  8020be:	f3 0f 1e fb          	endbr32 
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	57                   	push   %edi
  8020c6:	56                   	push   %esi
  8020c7:	53                   	push   %ebx
  8020c8:	83 ec 18             	sub    $0x18,%esp
  8020cb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8020ce:	57                   	push   %edi
  8020cf:	e8 86 f1 ff ff       	call   80125a <fd2data>
  8020d4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020d6:	83 c4 10             	add    $0x10,%esp
  8020d9:	be 00 00 00 00       	mov    $0x0,%esi
  8020de:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020e1:	75 14                	jne    8020f7 <devpipe_read+0x39>
	return i;
  8020e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e6:	eb 02                	jmp    8020ea <devpipe_read+0x2c>
				return i;
  8020e8:	89 f0                	mov    %esi,%eax
}
  8020ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
			sys_yield();
  8020f2:	e8 06 ec ff ff       	call   800cfd <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8020f7:	8b 03                	mov    (%ebx),%eax
  8020f9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020fc:	75 18                	jne    802116 <devpipe_read+0x58>
			if (i > 0)
  8020fe:	85 f6                	test   %esi,%esi
  802100:	75 e6                	jne    8020e8 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802102:	89 da                	mov    %ebx,%edx
  802104:	89 f8                	mov    %edi,%eax
  802106:	e8 c8 fe ff ff       	call   801fd3 <_pipeisclosed>
  80210b:	85 c0                	test   %eax,%eax
  80210d:	74 e3                	je     8020f2 <devpipe_read+0x34>
				return 0;
  80210f:	b8 00 00 00 00       	mov    $0x0,%eax
  802114:	eb d4                	jmp    8020ea <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802116:	99                   	cltd   
  802117:	c1 ea 1b             	shr    $0x1b,%edx
  80211a:	01 d0                	add    %edx,%eax
  80211c:	83 e0 1f             	and    $0x1f,%eax
  80211f:	29 d0                	sub    %edx,%eax
  802121:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802126:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802129:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80212c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80212f:	83 c6 01             	add    $0x1,%esi
  802132:	eb aa                	jmp    8020de <devpipe_read+0x20>

00802134 <pipe>:
{
  802134:	f3 0f 1e fb          	endbr32 
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	56                   	push   %esi
  80213c:	53                   	push   %ebx
  80213d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802143:	50                   	push   %eax
  802144:	e8 2c f1 ff ff       	call   801275 <fd_alloc>
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	0f 88 23 01 00 00    	js     802279 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802156:	83 ec 04             	sub    $0x4,%esp
  802159:	68 07 04 00 00       	push   $0x407
  80215e:	ff 75 f4             	pushl  -0xc(%ebp)
  802161:	6a 00                	push   $0x0
  802163:	e8 b8 eb ff ff       	call   800d20 <sys_page_alloc>
  802168:	89 c3                	mov    %eax,%ebx
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	0f 88 04 01 00 00    	js     802279 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80217b:	50                   	push   %eax
  80217c:	e8 f4 f0 ff ff       	call   801275 <fd_alloc>
  802181:	89 c3                	mov    %eax,%ebx
  802183:	83 c4 10             	add    $0x10,%esp
  802186:	85 c0                	test   %eax,%eax
  802188:	0f 88 db 00 00 00    	js     802269 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218e:	83 ec 04             	sub    $0x4,%esp
  802191:	68 07 04 00 00       	push   $0x407
  802196:	ff 75 f0             	pushl  -0x10(%ebp)
  802199:	6a 00                	push   $0x0
  80219b:	e8 80 eb ff ff       	call   800d20 <sys_page_alloc>
  8021a0:	89 c3                	mov    %eax,%ebx
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	0f 88 bc 00 00 00    	js     802269 <pipe+0x135>
	va = fd2data(fd0);
  8021ad:	83 ec 0c             	sub    $0xc,%esp
  8021b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b3:	e8 a2 f0 ff ff       	call   80125a <fd2data>
  8021b8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ba:	83 c4 0c             	add    $0xc,%esp
  8021bd:	68 07 04 00 00       	push   $0x407
  8021c2:	50                   	push   %eax
  8021c3:	6a 00                	push   $0x0
  8021c5:	e8 56 eb ff ff       	call   800d20 <sys_page_alloc>
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	83 c4 10             	add    $0x10,%esp
  8021cf:	85 c0                	test   %eax,%eax
  8021d1:	0f 88 82 00 00 00    	js     802259 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d7:	83 ec 0c             	sub    $0xc,%esp
  8021da:	ff 75 f0             	pushl  -0x10(%ebp)
  8021dd:	e8 78 f0 ff ff       	call   80125a <fd2data>
  8021e2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021e9:	50                   	push   %eax
  8021ea:	6a 00                	push   $0x0
  8021ec:	56                   	push   %esi
  8021ed:	6a 00                	push   $0x0
  8021ef:	e8 52 eb ff ff       	call   800d46 <sys_page_map>
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	83 c4 20             	add    $0x20,%esp
  8021f9:	85 c0                	test   %eax,%eax
  8021fb:	78 4e                	js     80224b <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8021fd:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802202:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802205:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802207:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80220a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802211:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802214:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802219:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802220:	83 ec 0c             	sub    $0xc,%esp
  802223:	ff 75 f4             	pushl  -0xc(%ebp)
  802226:	e8 1b f0 ff ff       	call   801246 <fd2num>
  80222b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80222e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802230:	83 c4 04             	add    $0x4,%esp
  802233:	ff 75 f0             	pushl  -0x10(%ebp)
  802236:	e8 0b f0 ff ff       	call   801246 <fd2num>
  80223b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80223e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	bb 00 00 00 00       	mov    $0x0,%ebx
  802249:	eb 2e                	jmp    802279 <pipe+0x145>
	sys_page_unmap(0, va);
  80224b:	83 ec 08             	sub    $0x8,%esp
  80224e:	56                   	push   %esi
  80224f:	6a 00                	push   $0x0
  802251:	e8 15 eb ff ff       	call   800d6b <sys_page_unmap>
  802256:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802259:	83 ec 08             	sub    $0x8,%esp
  80225c:	ff 75 f0             	pushl  -0x10(%ebp)
  80225f:	6a 00                	push   $0x0
  802261:	e8 05 eb ff ff       	call   800d6b <sys_page_unmap>
  802266:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802269:	83 ec 08             	sub    $0x8,%esp
  80226c:	ff 75 f4             	pushl  -0xc(%ebp)
  80226f:	6a 00                	push   $0x0
  802271:	e8 f5 ea ff ff       	call   800d6b <sys_page_unmap>
  802276:	83 c4 10             	add    $0x10,%esp
}
  802279:	89 d8                	mov    %ebx,%eax
  80227b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    

00802282 <pipeisclosed>:
{
  802282:	f3 0f 1e fb          	endbr32 
  802286:	55                   	push   %ebp
  802287:	89 e5                	mov    %esp,%ebp
  802289:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80228c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228f:	50                   	push   %eax
  802290:	ff 75 08             	pushl  0x8(%ebp)
  802293:	e8 33 f0 ff ff       	call   8012cb <fd_lookup>
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	85 c0                	test   %eax,%eax
  80229d:	78 18                	js     8022b7 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80229f:	83 ec 0c             	sub    $0xc,%esp
  8022a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a5:	e8 b0 ef ff ff       	call   80125a <fd2data>
  8022aa:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	e8 1f fd ff ff       	call   801fd3 <_pipeisclosed>
  8022b4:	83 c4 10             	add    $0x10,%esp
}
  8022b7:	c9                   	leave  
  8022b8:	c3                   	ret    

008022b9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022b9:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8022bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c2:	c3                   	ret    

008022c3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022c3:	f3 0f 1e fb          	endbr32 
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022cd:	68 0f 2e 80 00       	push   $0x802e0f
  8022d2:	ff 75 0c             	pushl  0xc(%ebp)
  8022d5:	e8 dd e5 ff ff       	call   8008b7 <strcpy>
	return 0;
}
  8022da:	b8 00 00 00 00       	mov    $0x0,%eax
  8022df:	c9                   	leave  
  8022e0:	c3                   	ret    

008022e1 <devcons_write>:
{
  8022e1:	f3 0f 1e fb          	endbr32 
  8022e5:	55                   	push   %ebp
  8022e6:	89 e5                	mov    %esp,%ebp
  8022e8:	57                   	push   %edi
  8022e9:	56                   	push   %esi
  8022ea:	53                   	push   %ebx
  8022eb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022f1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022f6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022fc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022ff:	73 31                	jae    802332 <devcons_write+0x51>
		m = n - tot;
  802301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802304:	29 f3                	sub    %esi,%ebx
  802306:	83 fb 7f             	cmp    $0x7f,%ebx
  802309:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80230e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802311:	83 ec 04             	sub    $0x4,%esp
  802314:	53                   	push   %ebx
  802315:	89 f0                	mov    %esi,%eax
  802317:	03 45 0c             	add    0xc(%ebp),%eax
  80231a:	50                   	push   %eax
  80231b:	57                   	push   %edi
  80231c:	e8 94 e7 ff ff       	call   800ab5 <memmove>
		sys_cputs(buf, m);
  802321:	83 c4 08             	add    $0x8,%esp
  802324:	53                   	push   %ebx
  802325:	57                   	push   %edi
  802326:	e8 46 e9 ff ff       	call   800c71 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80232b:	01 de                	add    %ebx,%esi
  80232d:	83 c4 10             	add    $0x10,%esp
  802330:	eb ca                	jmp    8022fc <devcons_write+0x1b>
}
  802332:	89 f0                	mov    %esi,%eax
  802334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    

0080233c <devcons_read>:
{
  80233c:	f3 0f 1e fb          	endbr32 
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	83 ec 08             	sub    $0x8,%esp
  802346:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80234b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80234f:	74 21                	je     802372 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802351:	e8 3d e9 ff ff       	call   800c93 <sys_cgetc>
  802356:	85 c0                	test   %eax,%eax
  802358:	75 07                	jne    802361 <devcons_read+0x25>
		sys_yield();
  80235a:	e8 9e e9 ff ff       	call   800cfd <sys_yield>
  80235f:	eb f0                	jmp    802351 <devcons_read+0x15>
	if (c < 0)
  802361:	78 0f                	js     802372 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802363:	83 f8 04             	cmp    $0x4,%eax
  802366:	74 0c                	je     802374 <devcons_read+0x38>
	*(char*)vbuf = c;
  802368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80236b:	88 02                	mov    %al,(%edx)
	return 1;
  80236d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802372:	c9                   	leave  
  802373:	c3                   	ret    
		return 0;
  802374:	b8 00 00 00 00       	mov    $0x0,%eax
  802379:	eb f7                	jmp    802372 <devcons_read+0x36>

0080237b <cputchar>:
{
  80237b:	f3 0f 1e fb          	endbr32 
  80237f:	55                   	push   %ebp
  802380:	89 e5                	mov    %esp,%ebp
  802382:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802385:	8b 45 08             	mov    0x8(%ebp),%eax
  802388:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80238b:	6a 01                	push   $0x1
  80238d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802390:	50                   	push   %eax
  802391:	e8 db e8 ff ff       	call   800c71 <sys_cputs>
}
  802396:	83 c4 10             	add    $0x10,%esp
  802399:	c9                   	leave  
  80239a:	c3                   	ret    

0080239b <getchar>:
{
  80239b:	f3 0f 1e fb          	endbr32 
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8023a5:	6a 01                	push   $0x1
  8023a7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023aa:	50                   	push   %eax
  8023ab:	6a 00                	push   $0x0
  8023ad:	e8 a1 f1 ff ff       	call   801553 <read>
	if (r < 0)
  8023b2:	83 c4 10             	add    $0x10,%esp
  8023b5:	85 c0                	test   %eax,%eax
  8023b7:	78 06                	js     8023bf <getchar+0x24>
	if (r < 1)
  8023b9:	74 06                	je     8023c1 <getchar+0x26>
	return c;
  8023bb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8023bf:	c9                   	leave  
  8023c0:	c3                   	ret    
		return -E_EOF;
  8023c1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8023c6:	eb f7                	jmp    8023bf <getchar+0x24>

008023c8 <iscons>:
{
  8023c8:	f3 0f 1e fb          	endbr32 
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d5:	50                   	push   %eax
  8023d6:	ff 75 08             	pushl  0x8(%ebp)
  8023d9:	e8 ed ee ff ff       	call   8012cb <fd_lookup>
  8023de:	83 c4 10             	add    $0x10,%esp
  8023e1:	85 c0                	test   %eax,%eax
  8023e3:	78 11                	js     8023f6 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8023e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e8:	8b 15 98 30 80 00    	mov    0x803098,%edx
  8023ee:	39 10                	cmp    %edx,(%eax)
  8023f0:	0f 94 c0             	sete   %al
  8023f3:	0f b6 c0             	movzbl %al,%eax
}
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <opencons>:
{
  8023f8:	f3 0f 1e fb          	endbr32 
  8023fc:	55                   	push   %ebp
  8023fd:	89 e5                	mov    %esp,%ebp
  8023ff:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802402:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802405:	50                   	push   %eax
  802406:	e8 6a ee ff ff       	call   801275 <fd_alloc>
  80240b:	83 c4 10             	add    $0x10,%esp
  80240e:	85 c0                	test   %eax,%eax
  802410:	78 3a                	js     80244c <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802412:	83 ec 04             	sub    $0x4,%esp
  802415:	68 07 04 00 00       	push   $0x407
  80241a:	ff 75 f4             	pushl  -0xc(%ebp)
  80241d:	6a 00                	push   $0x0
  80241f:	e8 fc e8 ff ff       	call   800d20 <sys_page_alloc>
  802424:	83 c4 10             	add    $0x10,%esp
  802427:	85 c0                	test   %eax,%eax
  802429:	78 21                	js     80244c <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80242b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242e:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802434:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802439:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802440:	83 ec 0c             	sub    $0xc,%esp
  802443:	50                   	push   %eax
  802444:	e8 fd ed ff ff       	call   801246 <fd2num>
  802449:	83 c4 10             	add    $0x10,%esp
}
  80244c:	c9                   	leave  
  80244d:	c3                   	ret    

0080244e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80244e:	f3 0f 1e fb          	endbr32 
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	56                   	push   %esi
  802456:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802457:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80245a:	8b 35 08 30 80 00    	mov    0x803008,%esi
  802460:	e8 75 e8 ff ff       	call   800cda <sys_getenvid>
  802465:	83 ec 0c             	sub    $0xc,%esp
  802468:	ff 75 0c             	pushl  0xc(%ebp)
  80246b:	ff 75 08             	pushl  0x8(%ebp)
  80246e:	56                   	push   %esi
  80246f:	50                   	push   %eax
  802470:	68 1c 2e 80 00       	push   $0x802e1c
  802475:	e8 33 de ff ff       	call   8002ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80247a:	83 c4 18             	add    $0x18,%esp
  80247d:	53                   	push   %ebx
  80247e:	ff 75 10             	pushl  0x10(%ebp)
  802481:	e8 d2 dd ff ff       	call   800258 <vcprintf>
	cprintf("\n");
  802486:	c7 04 24 08 2e 80 00 	movl   $0x802e08,(%esp)
  80248d:	e8 1b de ff ff       	call   8002ad <cprintf>
  802492:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802495:	cc                   	int3   
  802496:	eb fd                	jmp    802495 <_panic+0x47>

00802498 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802498:	f3 0f 1e fb          	endbr32 
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024a2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024a9:	74 0a                	je     8024b5 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ae:	a3 00 70 80 00       	mov    %eax,0x807000

}
  8024b3:	c9                   	leave  
  8024b4:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8024b5:	83 ec 04             	sub    $0x4,%esp
  8024b8:	6a 07                	push   $0x7
  8024ba:	68 00 f0 bf ee       	push   $0xeebff000
  8024bf:	6a 00                	push   $0x0
  8024c1:	e8 5a e8 ff ff       	call   800d20 <sys_page_alloc>
  8024c6:	83 c4 10             	add    $0x10,%esp
  8024c9:	85 c0                	test   %eax,%eax
  8024cb:	78 2a                	js     8024f7 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  8024cd:	83 ec 08             	sub    $0x8,%esp
  8024d0:	68 0b 25 80 00       	push   $0x80250b
  8024d5:	6a 00                	push   $0x0
  8024d7:	e8 fe e8 ff ff       	call   800dda <sys_env_set_pgfault_upcall>
  8024dc:	83 c4 10             	add    $0x10,%esp
  8024df:	85 c0                	test   %eax,%eax
  8024e1:	79 c8                	jns    8024ab <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  8024e3:	83 ec 04             	sub    $0x4,%esp
  8024e6:	68 6c 2e 80 00       	push   $0x802e6c
  8024eb:	6a 2c                	push   $0x2c
  8024ed:	68 a2 2e 80 00       	push   $0x802ea2
  8024f2:	e8 57 ff ff ff       	call   80244e <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  8024f7:	83 ec 04             	sub    $0x4,%esp
  8024fa:	68 40 2e 80 00       	push   $0x802e40
  8024ff:	6a 22                	push   $0x22
  802501:	68 a2 2e 80 00       	push   $0x802ea2
  802506:	e8 43 ff ff ff       	call   80244e <_panic>

0080250b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80250b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80250c:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  802511:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802513:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802516:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  80251a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  80251f:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802523:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802525:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802528:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802529:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  80252c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  80252d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  80252e:	c3                   	ret    

0080252f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80252f:	f3 0f 1e fb          	endbr32 
  802533:	55                   	push   %ebp
  802534:	89 e5                	mov    %esp,%ebp
  802536:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802539:	89 c2                	mov    %eax,%edx
  80253b:	c1 ea 16             	shr    $0x16,%edx
  80253e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802545:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80254a:	f6 c1 01             	test   $0x1,%cl
  80254d:	74 1c                	je     80256b <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80254f:	c1 e8 0c             	shr    $0xc,%eax
  802552:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802559:	a8 01                	test   $0x1,%al
  80255b:	74 0e                	je     80256b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80255d:	c1 e8 0c             	shr    $0xc,%eax
  802560:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802567:	ef 
  802568:	0f b7 d2             	movzwl %dx,%edx
}
  80256b:	89 d0                	mov    %edx,%eax
  80256d:	5d                   	pop    %ebp
  80256e:	c3                   	ret    
  80256f:	90                   	nop

00802570 <__udivdi3>:
  802570:	f3 0f 1e fb          	endbr32 
  802574:	55                   	push   %ebp
  802575:	57                   	push   %edi
  802576:	56                   	push   %esi
  802577:	53                   	push   %ebx
  802578:	83 ec 1c             	sub    $0x1c,%esp
  80257b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80257f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802583:	8b 74 24 34          	mov    0x34(%esp),%esi
  802587:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80258b:	85 d2                	test   %edx,%edx
  80258d:	75 19                	jne    8025a8 <__udivdi3+0x38>
  80258f:	39 f3                	cmp    %esi,%ebx
  802591:	76 4d                	jbe    8025e0 <__udivdi3+0x70>
  802593:	31 ff                	xor    %edi,%edi
  802595:	89 e8                	mov    %ebp,%eax
  802597:	89 f2                	mov    %esi,%edx
  802599:	f7 f3                	div    %ebx
  80259b:	89 fa                	mov    %edi,%edx
  80259d:	83 c4 1c             	add    $0x1c,%esp
  8025a0:	5b                   	pop    %ebx
  8025a1:	5e                   	pop    %esi
  8025a2:	5f                   	pop    %edi
  8025a3:	5d                   	pop    %ebp
  8025a4:	c3                   	ret    
  8025a5:	8d 76 00             	lea    0x0(%esi),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	76 14                	jbe    8025c0 <__udivdi3+0x50>
  8025ac:	31 ff                	xor    %edi,%edi
  8025ae:	31 c0                	xor    %eax,%eax
  8025b0:	89 fa                	mov    %edi,%edx
  8025b2:	83 c4 1c             	add    $0x1c,%esp
  8025b5:	5b                   	pop    %ebx
  8025b6:	5e                   	pop    %esi
  8025b7:	5f                   	pop    %edi
  8025b8:	5d                   	pop    %ebp
  8025b9:	c3                   	ret    
  8025ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c0:	0f bd fa             	bsr    %edx,%edi
  8025c3:	83 f7 1f             	xor    $0x1f,%edi
  8025c6:	75 48                	jne    802610 <__udivdi3+0xa0>
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	72 06                	jb     8025d2 <__udivdi3+0x62>
  8025cc:	31 c0                	xor    %eax,%eax
  8025ce:	39 eb                	cmp    %ebp,%ebx
  8025d0:	77 de                	ja     8025b0 <__udivdi3+0x40>
  8025d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d7:	eb d7                	jmp    8025b0 <__udivdi3+0x40>
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	89 d9                	mov    %ebx,%ecx
  8025e2:	85 db                	test   %ebx,%ebx
  8025e4:	75 0b                	jne    8025f1 <__udivdi3+0x81>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f3                	div    %ebx
  8025ef:	89 c1                	mov    %eax,%ecx
  8025f1:	31 d2                	xor    %edx,%edx
  8025f3:	89 f0                	mov    %esi,%eax
  8025f5:	f7 f1                	div    %ecx
  8025f7:	89 c6                	mov    %eax,%esi
  8025f9:	89 e8                	mov    %ebp,%eax
  8025fb:	89 f7                	mov    %esi,%edi
  8025fd:	f7 f1                	div    %ecx
  8025ff:	89 fa                	mov    %edi,%edx
  802601:	83 c4 1c             	add    $0x1c,%esp
  802604:	5b                   	pop    %ebx
  802605:	5e                   	pop    %esi
  802606:	5f                   	pop    %edi
  802607:	5d                   	pop    %ebp
  802608:	c3                   	ret    
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	89 f9                	mov    %edi,%ecx
  802612:	b8 20 00 00 00       	mov    $0x20,%eax
  802617:	29 f8                	sub    %edi,%eax
  802619:	d3 e2                	shl    %cl,%edx
  80261b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80261f:	89 c1                	mov    %eax,%ecx
  802621:	89 da                	mov    %ebx,%edx
  802623:	d3 ea                	shr    %cl,%edx
  802625:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802629:	09 d1                	or     %edx,%ecx
  80262b:	89 f2                	mov    %esi,%edx
  80262d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e3                	shl    %cl,%ebx
  802635:	89 c1                	mov    %eax,%ecx
  802637:	d3 ea                	shr    %cl,%edx
  802639:	89 f9                	mov    %edi,%ecx
  80263b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80263f:	89 eb                	mov    %ebp,%ebx
  802641:	d3 e6                	shl    %cl,%esi
  802643:	89 c1                	mov    %eax,%ecx
  802645:	d3 eb                	shr    %cl,%ebx
  802647:	09 de                	or     %ebx,%esi
  802649:	89 f0                	mov    %esi,%eax
  80264b:	f7 74 24 08          	divl   0x8(%esp)
  80264f:	89 d6                	mov    %edx,%esi
  802651:	89 c3                	mov    %eax,%ebx
  802653:	f7 64 24 0c          	mull   0xc(%esp)
  802657:	39 d6                	cmp    %edx,%esi
  802659:	72 15                	jb     802670 <__udivdi3+0x100>
  80265b:	89 f9                	mov    %edi,%ecx
  80265d:	d3 e5                	shl    %cl,%ebp
  80265f:	39 c5                	cmp    %eax,%ebp
  802661:	73 04                	jae    802667 <__udivdi3+0xf7>
  802663:	39 d6                	cmp    %edx,%esi
  802665:	74 09                	je     802670 <__udivdi3+0x100>
  802667:	89 d8                	mov    %ebx,%eax
  802669:	31 ff                	xor    %edi,%edi
  80266b:	e9 40 ff ff ff       	jmp    8025b0 <__udivdi3+0x40>
  802670:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802673:	31 ff                	xor    %edi,%edi
  802675:	e9 36 ff ff ff       	jmp    8025b0 <__udivdi3+0x40>
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	f3 0f 1e fb          	endbr32 
  802684:	55                   	push   %ebp
  802685:	57                   	push   %edi
  802686:	56                   	push   %esi
  802687:	53                   	push   %ebx
  802688:	83 ec 1c             	sub    $0x1c,%esp
  80268b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80268f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802693:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802697:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80269b:	85 c0                	test   %eax,%eax
  80269d:	75 19                	jne    8026b8 <__umoddi3+0x38>
  80269f:	39 df                	cmp    %ebx,%edi
  8026a1:	76 5d                	jbe    802700 <__umoddi3+0x80>
  8026a3:	89 f0                	mov    %esi,%eax
  8026a5:	89 da                	mov    %ebx,%edx
  8026a7:	f7 f7                	div    %edi
  8026a9:	89 d0                	mov    %edx,%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	83 c4 1c             	add    $0x1c,%esp
  8026b0:	5b                   	pop    %ebx
  8026b1:	5e                   	pop    %esi
  8026b2:	5f                   	pop    %edi
  8026b3:	5d                   	pop    %ebp
  8026b4:	c3                   	ret    
  8026b5:	8d 76 00             	lea    0x0(%esi),%esi
  8026b8:	89 f2                	mov    %esi,%edx
  8026ba:	39 d8                	cmp    %ebx,%eax
  8026bc:	76 12                	jbe    8026d0 <__umoddi3+0x50>
  8026be:	89 f0                	mov    %esi,%eax
  8026c0:	89 da                	mov    %ebx,%edx
  8026c2:	83 c4 1c             	add    $0x1c,%esp
  8026c5:	5b                   	pop    %ebx
  8026c6:	5e                   	pop    %esi
  8026c7:	5f                   	pop    %edi
  8026c8:	5d                   	pop    %ebp
  8026c9:	c3                   	ret    
  8026ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026d0:	0f bd e8             	bsr    %eax,%ebp
  8026d3:	83 f5 1f             	xor    $0x1f,%ebp
  8026d6:	75 50                	jne    802728 <__umoddi3+0xa8>
  8026d8:	39 d8                	cmp    %ebx,%eax
  8026da:	0f 82 e0 00 00 00    	jb     8027c0 <__umoddi3+0x140>
  8026e0:	89 d9                	mov    %ebx,%ecx
  8026e2:	39 f7                	cmp    %esi,%edi
  8026e4:	0f 86 d6 00 00 00    	jbe    8027c0 <__umoddi3+0x140>
  8026ea:	89 d0                	mov    %edx,%eax
  8026ec:	89 ca                	mov    %ecx,%edx
  8026ee:	83 c4 1c             	add    $0x1c,%esp
  8026f1:	5b                   	pop    %ebx
  8026f2:	5e                   	pop    %esi
  8026f3:	5f                   	pop    %edi
  8026f4:	5d                   	pop    %ebp
  8026f5:	c3                   	ret    
  8026f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026fd:	8d 76 00             	lea    0x0(%esi),%esi
  802700:	89 fd                	mov    %edi,%ebp
  802702:	85 ff                	test   %edi,%edi
  802704:	75 0b                	jne    802711 <__umoddi3+0x91>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f7                	div    %edi
  80270f:	89 c5                	mov    %eax,%ebp
  802711:	89 d8                	mov    %ebx,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 f5                	div    %ebp
  802717:	89 f0                	mov    %esi,%eax
  802719:	f7 f5                	div    %ebp
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	31 d2                	xor    %edx,%edx
  80271f:	eb 8c                	jmp    8026ad <__umoddi3+0x2d>
  802721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802728:	89 e9                	mov    %ebp,%ecx
  80272a:	ba 20 00 00 00       	mov    $0x20,%edx
  80272f:	29 ea                	sub    %ebp,%edx
  802731:	d3 e0                	shl    %cl,%eax
  802733:	89 44 24 08          	mov    %eax,0x8(%esp)
  802737:	89 d1                	mov    %edx,%ecx
  802739:	89 f8                	mov    %edi,%eax
  80273b:	d3 e8                	shr    %cl,%eax
  80273d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802741:	89 54 24 04          	mov    %edx,0x4(%esp)
  802745:	8b 54 24 04          	mov    0x4(%esp),%edx
  802749:	09 c1                	or     %eax,%ecx
  80274b:	89 d8                	mov    %ebx,%eax
  80274d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802751:	89 e9                	mov    %ebp,%ecx
  802753:	d3 e7                	shl    %cl,%edi
  802755:	89 d1                	mov    %edx,%ecx
  802757:	d3 e8                	shr    %cl,%eax
  802759:	89 e9                	mov    %ebp,%ecx
  80275b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80275f:	d3 e3                	shl    %cl,%ebx
  802761:	89 c7                	mov    %eax,%edi
  802763:	89 d1                	mov    %edx,%ecx
  802765:	89 f0                	mov    %esi,%eax
  802767:	d3 e8                	shr    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	89 fa                	mov    %edi,%edx
  80276d:	d3 e6                	shl    %cl,%esi
  80276f:	09 d8                	or     %ebx,%eax
  802771:	f7 74 24 08          	divl   0x8(%esp)
  802775:	89 d1                	mov    %edx,%ecx
  802777:	89 f3                	mov    %esi,%ebx
  802779:	f7 64 24 0c          	mull   0xc(%esp)
  80277d:	89 c6                	mov    %eax,%esi
  80277f:	89 d7                	mov    %edx,%edi
  802781:	39 d1                	cmp    %edx,%ecx
  802783:	72 06                	jb     80278b <__umoddi3+0x10b>
  802785:	75 10                	jne    802797 <__umoddi3+0x117>
  802787:	39 c3                	cmp    %eax,%ebx
  802789:	73 0c                	jae    802797 <__umoddi3+0x117>
  80278b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80278f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802793:	89 d7                	mov    %edx,%edi
  802795:	89 c6                	mov    %eax,%esi
  802797:	89 ca                	mov    %ecx,%edx
  802799:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80279e:	29 f3                	sub    %esi,%ebx
  8027a0:	19 fa                	sbb    %edi,%edx
  8027a2:	89 d0                	mov    %edx,%eax
  8027a4:	d3 e0                	shl    %cl,%eax
  8027a6:	89 e9                	mov    %ebp,%ecx
  8027a8:	d3 eb                	shr    %cl,%ebx
  8027aa:	d3 ea                	shr    %cl,%edx
  8027ac:	09 d8                	or     %ebx,%eax
  8027ae:	83 c4 1c             	add    $0x1c,%esp
  8027b1:	5b                   	pop    %ebx
  8027b2:	5e                   	pop    %esi
  8027b3:	5f                   	pop    %edi
  8027b4:	5d                   	pop    %ebp
  8027b5:	c3                   	ret    
  8027b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027bd:	8d 76 00             	lea    0x0(%esi),%esi
  8027c0:	29 fe                	sub    %edi,%esi
  8027c2:	19 c3                	sbb    %eax,%ebx
  8027c4:	89 f2                	mov    %esi,%edx
  8027c6:	89 d9                	mov    %ebx,%ecx
  8027c8:	e9 1d ff ff ff       	jmp    8026ea <__umoddi3+0x6a>
