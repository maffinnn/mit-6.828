
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 be 00 00 00       	call   8000ef <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800041:	e8 db 0b 00 00       	call   800c21 <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 20 27 80 00       	push   $0x802720
  800050:	e8 9f 01 00 00       	call   8001f4 <cprintf>

	forkchild(cur, '0');
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	6a 30                	push   $0x30
  80005a:	53                   	push   %ebx
  80005b:	e8 13 00 00 00       	call   800073 <forkchild>
	forkchild(cur, '1');
  800060:	83 c4 08             	add    $0x8,%esp
  800063:	6a 31                	push   $0x31
  800065:	53                   	push   %ebx
  800066:	e8 08 00 00 00       	call   800073 <forkchild>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <forkchild>:
{
  800073:	f3 0f 1e fb          	endbr32 
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	83 ec 1c             	sub    $0x1c,%esp
  80007f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800082:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  800085:	53                   	push   %ebx
  800086:	e8 30 07 00 00       	call   8007bb <strlen>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 f8 02             	cmp    $0x2,%eax
  800091:	7e 07                	jle    80009a <forkchild+0x27>
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	68 31 27 80 00       	push   $0x802731
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 e9 06 00 00       	call   80079d <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 3e 0e 00 00       	call   800efa <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 d3                	jne    800093 <forkchild+0x20>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 68 00 00 00       	call   800139 <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	eb bd                	jmp    800093 <forkchild+0x20>

008000d6 <umain>:

void
umain(int argc, char **argv)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000e0:	68 30 27 80 00       	push   $0x802730
  8000e5:	e8 49 ff ff ff       	call   800033 <forktree>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 1e 0b 00 00       	call   800c21 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800115:	85 db                	test   %ebx,%ebx
  800117:	7e 07                	jle    800120 <libmain+0x31>
		binaryname = argv[0];
  800119:	8b 06                	mov    (%esi),%eax
  80011b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
  800125:	e8 ac ff ff ff       	call   8000d6 <umain>

	// exit gracefully
	exit();
  80012a:	e8 0a 00 00 00       	call   800139 <exit>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800139:	f3 0f 1e fb          	endbr32 
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800143:	e8 37 11 00 00       	call   80127f <close_all>
	sys_env_destroy(0);
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	6a 00                	push   $0x0
  80014d:	e8 ab 0a 00 00       	call   800bfd <sys_env_destroy>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800157:	f3 0f 1e fb          	endbr32 
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	74 09                	je     800183 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 24 0a 00 00       	call   800bb8 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb db                	jmp    80017a <putch+0x23>

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	f3 0f 1e fb          	endbr32 
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	ff 75 0c             	pushl  0xc(%ebp)
  8001c3:	ff 75 08             	pushl  0x8(%ebp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	68 57 01 80 00       	push   $0x800157
  8001d2:	e8 20 01 00 00       	call   8002f7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	83 c4 08             	add    $0x8,%esp
  8001da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	e8 cc 09 00 00       	call   800bb8 <sys_cputs>

	return b.cnt;
}
  8001ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f4:	f3 0f 1e fb          	endbr32 
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 95 ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 d1                	mov    %edx,%ecx
  800221:	89 c2                	mov    %eax,%edx
  800223:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800226:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800229:	8b 45 10             	mov    0x10(%ebp),%eax
  80022c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800239:	39 c2                	cmp    %eax,%edx
  80023b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80023e:	72 3e                	jb     80027e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	83 eb 01             	sub    $0x1,%ebx
  800249:	53                   	push   %ebx
  80024a:	50                   	push   %eax
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 61 22 00 00       	call   8024c0 <__udivdi3>
  80025f:	83 c4 18             	add    $0x18,%esp
  800262:	52                   	push   %edx
  800263:	50                   	push   %eax
  800264:	89 f2                	mov    %esi,%edx
  800266:	89 f8                	mov    %edi,%eax
  800268:	e8 9f ff ff ff       	call   80020c <printnum>
  80026d:	83 c4 20             	add    $0x20,%esp
  800270:	eb 13                	jmp    800285 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	56                   	push   %esi
  800276:	ff 75 18             	pushl  0x18(%ebp)
  800279:	ff d7                	call   *%edi
  80027b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027e:	83 eb 01             	sub    $0x1,%ebx
  800281:	85 db                	test   %ebx,%ebx
  800283:	7f ed                	jg     800272 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	83 ec 04             	sub    $0x4,%esp
  80028c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028f:	ff 75 e0             	pushl  -0x20(%ebp)
  800292:	ff 75 dc             	pushl  -0x24(%ebp)
  800295:	ff 75 d8             	pushl  -0x28(%ebp)
  800298:	e8 33 23 00 00       	call   8025d0 <__umoddi3>
  80029d:	83 c4 14             	add    $0x14,%esp
  8002a0:	0f be 80 40 27 80 00 	movsbl 0x802740(%eax),%eax
  8002a7:	50                   	push   %eax
  8002a8:	ff d7                	call   *%edi
}
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b5:	f3 0f 1e fb          	endbr32 
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c8:	73 0a                	jae    8002d4 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	88 02                	mov    %al,(%edx)
}
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <printfmt>:
{
  8002d6:	f3 0f 1e fb          	endbr32 
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e3:	50                   	push   %eax
  8002e4:	ff 75 10             	pushl  0x10(%ebp)
  8002e7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ea:	ff 75 08             	pushl  0x8(%ebp)
  8002ed:	e8 05 00 00 00       	call   8002f7 <vprintfmt>
}
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <vprintfmt>:
{
  8002f7:	f3 0f 1e fb          	endbr32 
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	57                   	push   %edi
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
  800301:	83 ec 3c             	sub    $0x3c,%esp
  800304:	8b 75 08             	mov    0x8(%ebp),%esi
  800307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030d:	e9 8e 03 00 00       	jmp    8006a0 <vprintfmt+0x3a9>
		padc = ' ';
  800312:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800316:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80031d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800324:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80032b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8d 47 01             	lea    0x1(%edi),%eax
  800333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800336:	0f b6 17             	movzbl (%edi),%edx
  800339:	8d 42 dd             	lea    -0x23(%edx),%eax
  80033c:	3c 55                	cmp    $0x55,%al
  80033e:	0f 87 df 03 00 00    	ja     800723 <vprintfmt+0x42c>
  800344:	0f b6 c0             	movzbl %al,%eax
  800347:	3e ff 24 85 80 28 80 	notrack jmp *0x802880(,%eax,4)
  80034e:	00 
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800352:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800356:	eb d8                	jmp    800330 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80035f:	eb cf                	jmp    800330 <vprintfmt+0x39>
  800361:	0f b6 d2             	movzbl %dl,%edx
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800367:	b8 00 00 00 00       	mov    $0x0,%eax
  80036c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  80036f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800372:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800376:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800379:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80037c:	83 f9 09             	cmp    $0x9,%ecx
  80037f:	77 55                	ja     8003d6 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800381:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800384:	eb e9                	jmp    80036f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8b 00                	mov    (%eax),%eax
  80038b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8d 40 04             	lea    0x4(%eax),%eax
  800394:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80039a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039e:	79 90                	jns    800330 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ad:	eb 81                	jmp    800330 <vprintfmt+0x39>
  8003af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b9:	0f 49 d0             	cmovns %eax,%edx
  8003bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003c2:	e9 69 ff ff ff       	jmp    800330 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ca:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003d1:	e9 5a ff ff ff       	jmp    800330 <vprintfmt+0x39>
  8003d6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003dc:	eb bc                	jmp    80039a <vprintfmt+0xa3>
			lflag++;
  8003de:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e4:	e9 47 ff ff ff       	jmp    800330 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 78 04             	lea    0x4(%eax),%edi
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	53                   	push   %ebx
  8003f3:	ff 30                	pushl  (%eax)
  8003f5:	ff d6                	call   *%esi
			break;
  8003f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003fd:	e9 9b 02 00 00       	jmp    80069d <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 78 04             	lea    0x4(%eax),%edi
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	99                   	cltd   
  80040b:	31 d0                	xor    %edx,%eax
  80040d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040f:	83 f8 0f             	cmp    $0xf,%eax
  800412:	7f 23                	jg     800437 <vprintfmt+0x140>
  800414:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  80041b:	85 d2                	test   %edx,%edx
  80041d:	74 18                	je     800437 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80041f:	52                   	push   %edx
  800420:	68 e5 2b 80 00       	push   $0x802be5
  800425:	53                   	push   %ebx
  800426:	56                   	push   %esi
  800427:	e8 aa fe ff ff       	call   8002d6 <printfmt>
  80042c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800432:	e9 66 02 00 00       	jmp    80069d <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800437:	50                   	push   %eax
  800438:	68 58 27 80 00       	push   $0x802758
  80043d:	53                   	push   %ebx
  80043e:	56                   	push   %esi
  80043f:	e8 92 fe ff ff       	call   8002d6 <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800447:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80044a:	e9 4e 02 00 00       	jmp    80069d <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	83 c0 04             	add    $0x4,%eax
  800455:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80045d:	85 d2                	test   %edx,%edx
  80045f:	b8 51 27 80 00       	mov    $0x802751,%eax
  800464:	0f 45 c2             	cmovne %edx,%eax
  800467:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80046a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046e:	7e 06                	jle    800476 <vprintfmt+0x17f>
  800470:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800474:	75 0d                	jne    800483 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800479:	89 c7                	mov    %eax,%edi
  80047b:	03 45 e0             	add    -0x20(%ebp),%eax
  80047e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800481:	eb 55                	jmp    8004d8 <vprintfmt+0x1e1>
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	ff 75 cc             	pushl  -0x34(%ebp)
  80048c:	e8 46 03 00 00       	call   8007d7 <strnlen>
  800491:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800494:	29 c2                	sub    %eax,%edx
  800496:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80049e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	7e 11                	jle    8004ba <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	53                   	push   %ebx
  8004ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	eb eb                	jmp    8004a5 <vprintfmt+0x1ae>
  8004ba:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c4:	0f 49 c2             	cmovns %edx,%eax
  8004c7:	29 c2                	sub    %eax,%edx
  8004c9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004cc:	eb a8                	jmp    800476 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	52                   	push   %edx
  8004d3:	ff d6                	call   *%esi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004db:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dd:	83 c7 01             	add    $0x1,%edi
  8004e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e4:	0f be d0             	movsbl %al,%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	74 4b                	je     800536 <vprintfmt+0x23f>
  8004eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ef:	78 06                	js     8004f7 <vprintfmt+0x200>
  8004f1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f5:	78 1e                	js     800515 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8004f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fb:	74 d1                	je     8004ce <vprintfmt+0x1d7>
  8004fd:	0f be c0             	movsbl %al,%eax
  800500:	83 e8 20             	sub    $0x20,%eax
  800503:	83 f8 5e             	cmp    $0x5e,%eax
  800506:	76 c6                	jbe    8004ce <vprintfmt+0x1d7>
					putch('?', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	53                   	push   %ebx
  80050c:	6a 3f                	push   $0x3f
  80050e:	ff d6                	call   *%esi
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb c3                	jmp    8004d8 <vprintfmt+0x1e1>
  800515:	89 cf                	mov    %ecx,%edi
  800517:	eb 0e                	jmp    800527 <vprintfmt+0x230>
				putch(' ', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	6a 20                	push   $0x20
  80051f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800521:	83 ef 01             	sub    $0x1,%edi
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	85 ff                	test   %edi,%edi
  800529:	7f ee                	jg     800519 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80052b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80052e:	89 45 14             	mov    %eax,0x14(%ebp)
  800531:	e9 67 01 00 00       	jmp    80069d <vprintfmt+0x3a6>
  800536:	89 cf                	mov    %ecx,%edi
  800538:	eb ed                	jmp    800527 <vprintfmt+0x230>
	if (lflag >= 2)
  80053a:	83 f9 01             	cmp    $0x1,%ecx
  80053d:	7f 1b                	jg     80055a <vprintfmt+0x263>
	else if (lflag)
  80053f:	85 c9                	test   %ecx,%ecx
  800541:	74 63                	je     8005a6 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	99                   	cltd   
  80054c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 04             	lea    0x4(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
  800558:	eb 17                	jmp    800571 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 50 04             	mov    0x4(%eax),%edx
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 40 08             	lea    0x8(%eax),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800571:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800574:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800577:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	0f 89 ff 00 00 00    	jns    800683 <vprintfmt+0x38c>
				putch('-', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	53                   	push   %ebx
  800588:	6a 2d                	push   $0x2d
  80058a:	ff d6                	call   *%esi
				num = -(long long) num;
  80058c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800592:	f7 da                	neg    %edx
  800594:	83 d1 00             	adc    $0x0,%ecx
  800597:	f7 d9                	neg    %ecx
  800599:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a1:	e9 dd 00 00 00       	jmp    800683 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	99                   	cltd   
  8005af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 40 04             	lea    0x4(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bb:	eb b4                	jmp    800571 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005bd:	83 f9 01             	cmp    $0x1,%ecx
  8005c0:	7f 1e                	jg     8005e0 <vprintfmt+0x2e9>
	else if (lflag)
  8005c2:	85 c9                	test   %ecx,%ecx
  8005c4:	74 32                	je     8005f8 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005db:	e9 a3 00 00 00       	jmp    800683 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e8:	8d 40 08             	lea    0x8(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005f3:	e9 8b 00 00 00       	jmp    800683 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800608:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80060d:	eb 74                	jmp    800683 <vprintfmt+0x38c>
	if (lflag >= 2)
  80060f:	83 f9 01             	cmp    $0x1,%ecx
  800612:	7f 1b                	jg     80062f <vprintfmt+0x338>
	else if (lflag)
  800614:	85 c9                	test   %ecx,%ecx
  800616:	74 2c                	je     800644 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800628:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80062d:	eb 54                	jmp    800683 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	8b 48 04             	mov    0x4(%eax),%ecx
  800637:	8d 40 08             	lea    0x8(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800642:	eb 3f                	jmp    800683 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800654:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800659:	eb 28                	jmp    800683 <vprintfmt+0x38c>
			putch('0', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 30                	push   $0x30
  800661:	ff d6                	call   *%esi
			putch('x', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 78                	push   $0x78
  800669:	ff d6                	call   *%esi
			num = (unsigned long long)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 10                	mov    (%eax),%edx
  800670:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800675:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800683:	83 ec 0c             	sub    $0xc,%esp
  800686:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80068a:	57                   	push   %edi
  80068b:	ff 75 e0             	pushl  -0x20(%ebp)
  80068e:	50                   	push   %eax
  80068f:	51                   	push   %ecx
  800690:	52                   	push   %edx
  800691:	89 da                	mov    %ebx,%edx
  800693:	89 f0                	mov    %esi,%eax
  800695:	e8 72 fb ff ff       	call   80020c <printnum>
			break;
  80069a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80069d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006a0:	83 c7 01             	add    $0x1,%edi
  8006a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a7:	83 f8 25             	cmp    $0x25,%eax
  8006aa:	0f 84 62 fc ff ff    	je     800312 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	0f 84 8b 00 00 00    	je     800743 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	50                   	push   %eax
  8006bd:	ff d6                	call   *%esi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb dc                	jmp    8006a0 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006c4:	83 f9 01             	cmp    $0x1,%ecx
  8006c7:	7f 1b                	jg     8006e4 <vprintfmt+0x3ed>
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	74 2c                	je     8006f9 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006e2:	eb 9f                	jmp    800683 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ec:	8d 40 08             	lea    0x8(%eax),%eax
  8006ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006f7:	eb 8a                	jmp    800683 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 10                	mov    (%eax),%edx
  8006fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800709:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80070e:	e9 70 ff ff ff       	jmp    800683 <vprintfmt+0x38c>
			putch(ch, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 25                	push   $0x25
  800719:	ff d6                	call   *%esi
			break;
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	e9 7a ff ff ff       	jmp    80069d <vprintfmt+0x3a6>
			putch('%', putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	53                   	push   %ebx
  800727:	6a 25                	push   $0x25
  800729:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	89 f8                	mov    %edi,%eax
  800730:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800734:	74 05                	je     80073b <vprintfmt+0x444>
  800736:	83 e8 01             	sub    $0x1,%eax
  800739:	eb f5                	jmp    800730 <vprintfmt+0x439>
  80073b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073e:	e9 5a ff ff ff       	jmp    80069d <vprintfmt+0x3a6>
}
  800743:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	5f                   	pop    %edi
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074b:	f3 0f 1e fb          	endbr32 
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	83 ec 18             	sub    $0x18,%esp
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800762:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800765:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076c:	85 c0                	test   %eax,%eax
  80076e:	74 26                	je     800796 <vsnprintf+0x4b>
  800770:	85 d2                	test   %edx,%edx
  800772:	7e 22                	jle    800796 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800774:	ff 75 14             	pushl  0x14(%ebp)
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	68 b5 02 80 00       	push   $0x8002b5
  800783:	e8 6f fb ff ff       	call   8002f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800788:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800791:	83 c4 10             	add    $0x10,%esp
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    
		return -E_INVAL;
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079b:	eb f7                	jmp    800794 <vsnprintf+0x49>

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	f3 0f 1e fb          	endbr32 
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007aa:	50                   	push   %eax
  8007ab:	ff 75 10             	pushl  0x10(%ebp)
  8007ae:	ff 75 0c             	pushl  0xc(%ebp)
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 92 ff ff ff       	call   80074b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bb:	f3 0f 1e fb          	endbr32 
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	74 05                	je     8007d5 <strlen+0x1a>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
  8007d3:	eb f5                	jmp    8007ca <strlen+0xf>
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d7:	f3 0f 1e fb          	endbr32 
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e9:	39 d0                	cmp    %edx,%eax
  8007eb:	74 0d                	je     8007fa <strnlen+0x23>
  8007ed:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f1:	74 05                	je     8007f8 <strnlen+0x21>
		n++;
  8007f3:	83 c0 01             	add    $0x1,%eax
  8007f6:	eb f1                	jmp    8007e9 <strnlen+0x12>
  8007f8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007fa:	89 d0                	mov    %edx,%eax
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fe:	f3 0f 1e fb          	endbr32 
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800815:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	84 d2                	test   %dl,%dl
  80081d:	75 f2                	jne    800811 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80081f:	89 c8                	mov    %ecx,%eax
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800824:	f3 0f 1e fb          	endbr32 
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	83 ec 10             	sub    $0x10,%esp
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	53                   	push   %ebx
  800833:	e8 83 ff ff ff       	call   8007bb <strlen>
  800838:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	01 d8                	add    %ebx,%eax
  800840:	50                   	push   %eax
  800841:	e8 b8 ff ff ff       	call   8007fe <strcpy>
	return dst;
}
  800846:	89 d8                	mov    %ebx,%eax
  800848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	89 f3                	mov    %esi,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	89 f0                	mov    %esi,%eax
  800863:	39 d8                	cmp    %ebx,%eax
  800865:	74 11                	je     800878 <strncpy+0x2b>
		*dst++ = *src;
  800867:	83 c0 01             	add    $0x1,%eax
  80086a:	0f b6 0a             	movzbl (%edx),%ecx
  80086d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800870:	80 f9 01             	cmp    $0x1,%cl
  800873:	83 da ff             	sbb    $0xffffffff,%edx
  800876:	eb eb                	jmp    800863 <strncpy+0x16>
	}
	return ret;
}
  800878:	89 f0                	mov    %esi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	f3 0f 1e fb          	endbr32 
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 75 08             	mov    0x8(%ebp),%esi
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088d:	8b 55 10             	mov    0x10(%ebp),%edx
  800890:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	74 21                	je     8008b7 <strlcpy+0x39>
  800896:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80089a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80089c:	39 c2                	cmp    %eax,%edx
  80089e:	74 14                	je     8008b4 <strlcpy+0x36>
  8008a0:	0f b6 19             	movzbl (%ecx),%ebx
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	74 0b                	je     8008b2 <strlcpy+0x34>
			*dst++ = *src++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
  8008ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b0:	eb ea                	jmp    80089c <strlcpy+0x1e>
  8008b2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b7:	29 f0                	sub    %esi,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bd:	f3 0f 1e fb          	endbr32 
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ca:	0f b6 01             	movzbl (%ecx),%eax
  8008cd:	84 c0                	test   %al,%al
  8008cf:	74 0c                	je     8008dd <strcmp+0x20>
  8008d1:	3a 02                	cmp    (%edx),%al
  8008d3:	75 08                	jne    8008dd <strcmp+0x20>
		p++, q++;
  8008d5:	83 c1 01             	add    $0x1,%ecx
  8008d8:	83 c2 01             	add    $0x1,%edx
  8008db:	eb ed                	jmp    8008ca <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dd:	0f b6 c0             	movzbl %al,%eax
  8008e0:	0f b6 12             	movzbl (%edx),%edx
  8008e3:	29 d0                	sub    %edx,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e7:	f3 0f 1e fb          	endbr32 
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f5:	89 c3                	mov    %eax,%ebx
  8008f7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008fa:	eb 06                	jmp    800902 <strncmp+0x1b>
		n--, p++, q++;
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800902:	39 d8                	cmp    %ebx,%eax
  800904:	74 16                	je     80091c <strncmp+0x35>
  800906:	0f b6 08             	movzbl (%eax),%ecx
  800909:	84 c9                	test   %cl,%cl
  80090b:	74 04                	je     800911 <strncmp+0x2a>
  80090d:	3a 0a                	cmp    (%edx),%cl
  80090f:	74 eb                	je     8008fc <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800911:	0f b6 00             	movzbl (%eax),%eax
  800914:	0f b6 12             	movzbl (%edx),%edx
  800917:	29 d0                	sub    %edx,%eax
}
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    
		return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb f6                	jmp    800919 <strncmp+0x32>

00800923 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800923:	f3 0f 1e fb          	endbr32 
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800931:	0f b6 10             	movzbl (%eax),%edx
  800934:	84 d2                	test   %dl,%dl
  800936:	74 09                	je     800941 <strchr+0x1e>
		if (*s == c)
  800938:	38 ca                	cmp    %cl,%dl
  80093a:	74 0a                	je     800946 <strchr+0x23>
	for (; *s; s++)
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	eb f0                	jmp    800931 <strchr+0xe>
			return (char *) s;
	return 0;
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800948:	f3 0f 1e fb          	endbr32 
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800952:	6a 78                	push   $0x78
  800954:	ff 75 08             	pushl  0x8(%ebp)
  800957:	e8 c7 ff ff ff       	call   800923 <strchr>
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800967:	eb 0d                	jmp    800976 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800969:	c1 e0 04             	shl    $0x4,%eax
  80096c:	0f be d2             	movsbl %dl,%edx
  80096f:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800973:	83 c1 01             	add    $0x1,%ecx
  800976:	0f b6 11             	movzbl (%ecx),%edx
  800979:	84 d2                	test   %dl,%dl
  80097b:	74 11                	je     80098e <atox+0x46>
		if (*p>='a'){
  80097d:	80 fa 60             	cmp    $0x60,%dl
  800980:	7e e7                	jle    800969 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800982:	c1 e0 04             	shl    $0x4,%eax
  800985:	0f be d2             	movsbl %dl,%edx
  800988:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  80098c:	eb e5                	jmp    800973 <atox+0x2b>
	}

	return v;

}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800990:	f3 0f 1e fb          	endbr32 
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009a1:	38 ca                	cmp    %cl,%dl
  8009a3:	74 09                	je     8009ae <strfind+0x1e>
  8009a5:	84 d2                	test   %dl,%dl
  8009a7:	74 05                	je     8009ae <strfind+0x1e>
	for (; *s; s++)
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	eb f0                	jmp    80099e <strfind+0xe>
			break;
	return (char *) s;
}
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b0:	f3 0f 1e fb          	endbr32 
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c0:	85 c9                	test   %ecx,%ecx
  8009c2:	74 31                	je     8009f5 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c4:	89 f8                	mov    %edi,%eax
  8009c6:	09 c8                	or     %ecx,%eax
  8009c8:	a8 03                	test   $0x3,%al
  8009ca:	75 23                	jne    8009ef <memset+0x3f>
		c &= 0xFF;
  8009cc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d0:	89 d3                	mov    %edx,%ebx
  8009d2:	c1 e3 08             	shl    $0x8,%ebx
  8009d5:	89 d0                	mov    %edx,%eax
  8009d7:	c1 e0 18             	shl    $0x18,%eax
  8009da:	89 d6                	mov    %edx,%esi
  8009dc:	c1 e6 10             	shl    $0x10,%esi
  8009df:	09 f0                	or     %esi,%eax
  8009e1:	09 c2                	or     %eax,%edx
  8009e3:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e8:	89 d0                	mov    %edx,%eax
  8009ea:	fc                   	cld    
  8009eb:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ed:	eb 06                	jmp    8009f5 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f2:	fc                   	cld    
  8009f3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f5:	89 f8                	mov    %edi,%eax
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5f                   	pop    %edi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fc:	f3 0f 1e fb          	endbr32 
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a0e:	39 c6                	cmp    %eax,%esi
  800a10:	73 32                	jae    800a44 <memmove+0x48>
  800a12:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a15:	39 c2                	cmp    %eax,%edx
  800a17:	76 2b                	jbe    800a44 <memmove+0x48>
		s += n;
		d += n;
  800a19:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	89 fe                	mov    %edi,%esi
  800a1e:	09 ce                	or     %ecx,%esi
  800a20:	09 d6                	or     %edx,%esi
  800a22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a28:	75 0e                	jne    800a38 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2a:	83 ef 04             	sub    $0x4,%edi
  800a2d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a30:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a33:	fd                   	std    
  800a34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a36:	eb 09                	jmp    800a41 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a38:	83 ef 01             	sub    $0x1,%edi
  800a3b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a3e:	fd                   	std    
  800a3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a41:	fc                   	cld    
  800a42:	eb 1a                	jmp    800a5e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	89 c2                	mov    %eax,%edx
  800a46:	09 ca                	or     %ecx,%edx
  800a48:	09 f2                	or     %esi,%edx
  800a4a:	f6 c2 03             	test   $0x3,%dl
  800a4d:	75 0a                	jne    800a59 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	fc                   	cld    
  800a55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a57:	eb 05                	jmp    800a5e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a59:	89 c7                	mov    %eax,%edi
  800a5b:	fc                   	cld    
  800a5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5e:	5e                   	pop    %esi
  800a5f:	5f                   	pop    %edi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a62:	f3 0f 1e fb          	endbr32 
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a6c:	ff 75 10             	pushl  0x10(%ebp)
  800a6f:	ff 75 0c             	pushl  0xc(%ebp)
  800a72:	ff 75 08             	pushl  0x8(%ebp)
  800a75:	e8 82 ff ff ff       	call   8009fc <memmove>
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7c:	f3 0f 1e fb          	endbr32 
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8b:	89 c6                	mov    %eax,%esi
  800a8d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a90:	39 f0                	cmp    %esi,%eax
  800a92:	74 1c                	je     800ab0 <memcmp+0x34>
		if (*s1 != *s2)
  800a94:	0f b6 08             	movzbl (%eax),%ecx
  800a97:	0f b6 1a             	movzbl (%edx),%ebx
  800a9a:	38 d9                	cmp    %bl,%cl
  800a9c:	75 08                	jne    800aa6 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	83 c2 01             	add    $0x1,%edx
  800aa4:	eb ea                	jmp    800a90 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800aa6:	0f b6 c1             	movzbl %cl,%eax
  800aa9:	0f b6 db             	movzbl %bl,%ebx
  800aac:	29 d8                	sub    %ebx,%eax
  800aae:	eb 05                	jmp    800ab5 <memcmp+0x39>
	}

	return 0;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab9:	f3 0f 1e fb          	endbr32 
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac6:	89 c2                	mov    %eax,%edx
  800ac8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800acb:	39 d0                	cmp    %edx,%eax
  800acd:	73 09                	jae    800ad8 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800acf:	38 08                	cmp    %cl,(%eax)
  800ad1:	74 05                	je     800ad8 <memfind+0x1f>
	for (; s < ends; s++)
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	eb f3                	jmp    800acb <memfind+0x12>
			break;
	return (void *) s;
}
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ada:	f3 0f 1e fb          	endbr32 
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aea:	eb 03                	jmp    800aef <strtol+0x15>
		s++;
  800aec:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aef:	0f b6 01             	movzbl (%ecx),%eax
  800af2:	3c 20                	cmp    $0x20,%al
  800af4:	74 f6                	je     800aec <strtol+0x12>
  800af6:	3c 09                	cmp    $0x9,%al
  800af8:	74 f2                	je     800aec <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800afa:	3c 2b                	cmp    $0x2b,%al
  800afc:	74 2a                	je     800b28 <strtol+0x4e>
	int neg = 0;
  800afe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b03:	3c 2d                	cmp    $0x2d,%al
  800b05:	74 2b                	je     800b32 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0d:	75 0f                	jne    800b1e <strtol+0x44>
  800b0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b12:	74 28                	je     800b3c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b14:	85 db                	test   %ebx,%ebx
  800b16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1b:	0f 44 d8             	cmove  %eax,%ebx
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b23:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b26:	eb 46                	jmp    800b6e <strtol+0x94>
		s++;
  800b28:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b30:	eb d5                	jmp    800b07 <strtol+0x2d>
		s++, neg = 1;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	bf 01 00 00 00       	mov    $0x1,%edi
  800b3a:	eb cb                	jmp    800b07 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b40:	74 0e                	je     800b50 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b42:	85 db                	test   %ebx,%ebx
  800b44:	75 d8                	jne    800b1e <strtol+0x44>
		s++, base = 8;
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b4e:	eb ce                	jmp    800b1e <strtol+0x44>
		s += 2, base = 16;
  800b50:	83 c1 02             	add    $0x2,%ecx
  800b53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b58:	eb c4                	jmp    800b1e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b5a:	0f be d2             	movsbl %dl,%edx
  800b5d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b60:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b63:	7d 3a                	jge    800b9f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b65:	83 c1 01             	add    $0x1,%ecx
  800b68:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b6e:	0f b6 11             	movzbl (%ecx),%edx
  800b71:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b74:	89 f3                	mov    %esi,%ebx
  800b76:	80 fb 09             	cmp    $0x9,%bl
  800b79:	76 df                	jbe    800b5a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b7b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b7e:	89 f3                	mov    %esi,%ebx
  800b80:	80 fb 19             	cmp    $0x19,%bl
  800b83:	77 08                	ja     800b8d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	83 ea 57             	sub    $0x57,%edx
  800b8b:	eb d3                	jmp    800b60 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b8d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 19             	cmp    $0x19,%bl
  800b95:	77 08                	ja     800b9f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b97:	0f be d2             	movsbl %dl,%edx
  800b9a:	83 ea 37             	sub    $0x37,%edx
  800b9d:	eb c1                	jmp    800b60 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba3:	74 05                	je     800baa <strtol+0xd0>
		*endptr = (char *) s;
  800ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	f7 da                	neg    %edx
  800bae:	85 ff                	test   %edi,%edi
  800bb0:	0f 45 c2             	cmovne %edx,%eax
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb8:	f3 0f 1e fb          	endbr32 
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	89 c3                	mov    %eax,%ebx
  800bcf:	89 c7                	mov    %eax,%edi
  800bd1:	89 c6                	mov    %eax,%esi
  800bd3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_cgetc>:

int
sys_cgetc(void)
{
  800bda:	f3 0f 1e fb          	endbr32 
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfd:	f3 0f 1e fb          	endbr32 
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c14:	89 cb                	mov    %ecx,%ebx
  800c16:	89 cf                	mov    %ecx,%edi
  800c18:	89 ce                	mov    %ecx,%esi
  800c1a:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c21:	f3 0f 1e fb          	endbr32 
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 02 00 00 00       	mov    $0x2,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_yield>:

void
sys_yield(void)
{
  800c44:	f3 0f 1e fb          	endbr32 
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c53:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c58:	89 d1                	mov    %edx,%ecx
  800c5a:	89 d3                	mov    %edx,%ebx
  800c5c:	89 d7                	mov    %edx,%edi
  800c5e:	89 d6                	mov    %edx,%esi
  800c60:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c71:	be 00 00 00 00       	mov    $0x0,%esi
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c84:	89 f7                	mov    %esi,%edi
  800c86:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8d:	f3 0f 1e fb          	endbr32 
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cab:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb2:	f3 0f 1e fb          	endbr32 
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccc:	89 df                	mov    %ebx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfc:	f3 0f 1e fb          	endbr32 
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	b8 09 00 00 00       	mov    $0x9,%eax
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d21:	f3 0f 1e fb          	endbr32 
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d56:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5b:	be 00 00 00 00       	mov    $0x0,%esi
  800d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d63:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d66:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6d:	f3 0f 1e fb          	endbr32 
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d91:	f3 0f 1e fb          	endbr32 
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
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
  800dc9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800dd9:	f3 0f 1e fb          	endbr32 
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	b8 10 00 00 00       	mov    $0x10,%eax
  800df3:	89 df                	mov    %ebx,%edi
  800df5:	89 de                	mov    %ebx,%esi
  800df7:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800df9:	5b                   	pop    %ebx
  800dfa:	5e                   	pop    %esi
  800dfb:	5f                   	pop    %edi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	53                   	push   %ebx
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800e0c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800e0e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e12:	0f 84 9a 00 00 00    	je     800eb2 <pgfault+0xb4>
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	c1 e8 16             	shr    $0x16,%eax
  800e1d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e24:	a8 01                	test   $0x1,%al
  800e26:	0f 84 86 00 00 00    	je     800eb2 <pgfault+0xb4>
  800e2c:	89 d8                	mov    %ebx,%eax
  800e2e:	c1 e8 0c             	shr    $0xc,%eax
  800e31:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e38:	f6 c2 01             	test   $0x1,%dl
  800e3b:	74 75                	je     800eb2 <pgfault+0xb4>
  800e3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e44:	f6 c4 08             	test   $0x8,%ah
  800e47:	74 69                	je     800eb2 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	6a 07                	push   $0x7
  800e4e:	68 00 f0 7f 00       	push   $0x7ff000
  800e53:	6a 00                	push   $0x0
  800e55:	e8 0d fe ff ff       	call   800c67 <sys_page_alloc>
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	78 63                	js     800ec4 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e61:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	68 00 10 00 00       	push   $0x1000
  800e6f:	53                   	push   %ebx
  800e70:	68 00 f0 7f 00       	push   $0x7ff000
  800e75:	e8 e8 fb ff ff       	call   800a62 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800e7a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e81:	53                   	push   %ebx
  800e82:	6a 00                	push   $0x0
  800e84:	68 00 f0 7f 00       	push   $0x7ff000
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 fd fd ff ff       	call   800c8d <sys_page_map>
  800e90:	83 c4 20             	add    $0x20,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	78 3f                	js     800ed6 <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	68 00 f0 7f 00       	push   $0x7ff000
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 0c fe ff ff       	call   800cb2 <sys_page_unmap>
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	78 3b                	js     800ee8 <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800eb2:	53                   	push   %ebx
  800eb3:	68 40 2a 80 00       	push   $0x802a40
  800eb8:	6a 20                	push   $0x20
  800eba:	68 fe 2a 80 00       	push   $0x802afe
  800ebf:	e8 cf 13 00 00       	call   802293 <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800ec4:	50                   	push   %eax
  800ec5:	68 80 2a 80 00       	push   $0x802a80
  800eca:	6a 2c                	push   $0x2c
  800ecc:	68 fe 2a 80 00       	push   $0x802afe
  800ed1:	e8 bd 13 00 00       	call   802293 <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800ed6:	50                   	push   %eax
  800ed7:	68 ac 2a 80 00       	push   $0x802aac
  800edc:	6a 33                	push   $0x33
  800ede:	68 fe 2a 80 00       	push   $0x802afe
  800ee3:	e8 ab 13 00 00       	call   802293 <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800ee8:	50                   	push   %eax
  800ee9:	68 d4 2a 80 00       	push   $0x802ad4
  800eee:	6a 36                	push   $0x36
  800ef0:	68 fe 2a 80 00       	push   $0x802afe
  800ef5:	e8 99 13 00 00       	call   802293 <_panic>

00800efa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efa:	f3 0f 1e fb          	endbr32 
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800f07:	68 fe 0d 80 00       	push   $0x800dfe
  800f0c:	e8 cc 13 00 00       	call   8022dd <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f11:	b8 07 00 00 00       	mov    $0x7,%eax
  800f16:	cd 30                	int    $0x30
  800f18:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 29                	js     800f4b <fork+0x51>
  800f22:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f24:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  800f29:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f2d:	75 60                	jne    800f8f <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2f:	e8 ed fc ff ff       	call   800c21 <sys_getenvid>
  800f34:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f46:	e9 14 01 00 00       	jmp    80105f <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  800f4b:	50                   	push   %eax
  800f4c:	68 09 2b 80 00       	push   $0x802b09
  800f51:	68 90 00 00 00       	push   $0x90
  800f56:	68 fe 2a 80 00       	push   $0x802afe
  800f5b:	e8 33 13 00 00       	call   802293 <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  800f60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6f:	50                   	push   %eax
  800f70:	56                   	push   %esi
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	6a 00                	push   $0x0
  800f75:	e8 13 fd ff ff       	call   800c8d <sys_page_map>
  800f7a:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f7d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f83:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f89:	0f 84 95 00 00 00    	je     801024 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	c1 e8 16             	shr    $0x16,%eax
  800f94:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9b:	a8 01                	test   $0x1,%al
  800f9d:	74 de                	je     800f7d <fork+0x83>
  800f9f:	89 d8                	mov    %ebx,%eax
  800fa1:	c1 e8 0c             	shr    $0xc,%eax
  800fa4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fab:	f6 c2 01             	test   $0x1,%dl
  800fae:	74 cd                	je     800f7d <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  800fb0:	89 c6                	mov    %eax,%esi
  800fb2:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  800fb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbc:	f6 c6 04             	test   $0x4,%dh
  800fbf:	75 9f                	jne    800f60 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  800fc1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc8:	f6 c2 02             	test   $0x2,%dl
  800fcb:	75 0c                	jne    800fd9 <fork+0xdf>
  800fcd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd4:	f6 c4 08             	test   $0x8,%ah
  800fd7:	74 34                	je     80100d <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  800fd9:	83 ec 0c             	sub    $0xc,%esp
  800fdc:	68 05 08 00 00       	push   $0x805
  800fe1:	56                   	push   %esi
  800fe2:	57                   	push   %edi
  800fe3:	56                   	push   %esi
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 a2 fc ff ff       	call   800c8d <sys_page_map>
			if (r<0) return r;
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 8b                	js     800f7d <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	68 05 08 00 00       	push   $0x805
  800ffa:	56                   	push   %esi
  800ffb:	6a 00                	push   $0x0
  800ffd:	56                   	push   %esi
  800ffe:	6a 00                	push   $0x0
  801000:	e8 88 fc ff ff       	call   800c8d <sys_page_map>
  801005:	83 c4 20             	add    $0x20,%esp
  801008:	e9 70 ff ff ff       	jmp    800f7d <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	6a 05                	push   $0x5
  801012:	56                   	push   %esi
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	6a 00                	push   $0x0
  801017:	e8 71 fc ff ff       	call   800c8d <sys_page_map>
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	e9 59 ff ff ff       	jmp    800f7d <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  801024:	83 ec 04             	sub    $0x4,%esp
  801027:	6a 07                	push   $0x7
  801029:	68 00 f0 bf ee       	push   $0xeebff000
  80102e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801031:	56                   	push   %esi
  801032:	e8 30 fc ff ff       	call   800c67 <sys_page_alloc>
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 2b                	js     801069 <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	68 50 23 80 00       	push   $0x802350
  801046:	56                   	push   %esi
  801047:	e8 d5 fc ff ff       	call   800d21 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	6a 02                	push   $0x2
  801051:	56                   	push   %esi
  801052:	e8 80 fc ff ff       	call   800cd7 <sys_env_set_status>
  801057:	83 c4 10             	add    $0x10,%esp
		return r;
  80105a:	85 c0                	test   %eax,%eax
  80105c:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  80105f:	89 f8                	mov    %edi,%eax
  801061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    
		return r;
  801069:	89 c7                	mov    %eax,%edi
  80106b:	eb f2                	jmp    80105f <fork+0x165>

0080106d <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  80106d:	f3 0f 1e fb          	endbr32 
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801077:	68 25 2b 80 00       	push   $0x802b25
  80107c:	68 b2 00 00 00       	push   $0xb2
  801081:	68 fe 2a 80 00       	push   $0x802afe
  801086:	e8 08 12 00 00       	call   802293 <_panic>

0080108b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80108b:	f3 0f 1e fb          	endbr32 
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	05 00 00 00 30       	add    $0x30000000,%eax
  80109a:	c1 e8 0c             	shr    $0xc,%eax
}
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80109f:	f3 0f 1e fb          	endbr32 
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8010ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ba:	f3 0f 1e fb          	endbr32 
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c6:	89 c2                	mov    %eax,%edx
  8010c8:	c1 ea 16             	shr    $0x16,%edx
  8010cb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d2:	f6 c2 01             	test   $0x1,%dl
  8010d5:	74 2d                	je     801104 <fd_alloc+0x4a>
  8010d7:	89 c2                	mov    %eax,%edx
  8010d9:	c1 ea 0c             	shr    $0xc,%edx
  8010dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e3:	f6 c2 01             	test   $0x1,%dl
  8010e6:	74 1c                	je     801104 <fd_alloc+0x4a>
  8010e8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010ed:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f2:	75 d2                	jne    8010c6 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801102:	eb 0a                	jmp    80110e <fd_alloc+0x54>
			*fd_store = fd;
  801104:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801107:	89 01                	mov    %eax,(%ecx)
			return 0;
  801109:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801110:	f3 0f 1e fb          	endbr32 
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80111a:	83 f8 1f             	cmp    $0x1f,%eax
  80111d:	77 30                	ja     80114f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80111f:	c1 e0 0c             	shl    $0xc,%eax
  801122:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801127:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 24                	je     801156 <fd_lookup+0x46>
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 ea 0c             	shr    $0xc,%edx
  801137:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	74 1a                	je     80115d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801143:	8b 55 0c             	mov    0xc(%ebp),%edx
  801146:	89 02                	mov    %eax,(%edx)
	return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    
		return -E_INVAL;
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801154:	eb f7                	jmp    80114d <fd_lookup+0x3d>
		return -E_INVAL;
  801156:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115b:	eb f0                	jmp    80114d <fd_lookup+0x3d>
  80115d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801162:	eb e9                	jmp    80114d <fd_lookup+0x3d>

00801164 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801164:	f3 0f 1e fb          	endbr32 
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801171:	ba 00 00 00 00       	mov    $0x0,%edx
  801176:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  80117b:	39 08                	cmp    %ecx,(%eax)
  80117d:	74 38                	je     8011b7 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80117f:	83 c2 01             	add    $0x1,%edx
  801182:	8b 04 95 b8 2b 80 00 	mov    0x802bb8(,%edx,4),%eax
  801189:	85 c0                	test   %eax,%eax
  80118b:	75 ee                	jne    80117b <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80118d:	a1 08 40 80 00       	mov    0x804008,%eax
  801192:	8b 40 48             	mov    0x48(%eax),%eax
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	51                   	push   %ecx
  801199:	50                   	push   %eax
  80119a:	68 3c 2b 80 00       	push   $0x802b3c
  80119f:	e8 50 f0 ff ff       	call   8001f4 <cprintf>
	*dev = 0;
  8011a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    
			*dev = devtab[i];
  8011b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c1:	eb f2                	jmp    8011b5 <dev_lookup+0x51>

008011c3 <fd_close>:
{
  8011c3:	f3 0f 1e fb          	endbr32 
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 24             	sub    $0x24,%esp
  8011d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011d9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011da:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011e0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e3:	50                   	push   %eax
  8011e4:	e8 27 ff ff ff       	call   801110 <fd_lookup>
  8011e9:	89 c3                	mov    %eax,%ebx
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 05                	js     8011f7 <fd_close+0x34>
	    || fd != fd2)
  8011f2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011f5:	74 16                	je     80120d <fd_close+0x4a>
		return (must_exist ? r : 0);
  8011f7:	89 f8                	mov    %edi,%eax
  8011f9:	84 c0                	test   %al,%al
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801200:	0f 44 d8             	cmove  %eax,%ebx
}
  801203:	89 d8                	mov    %ebx,%eax
  801205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	ff 36                	pushl  (%esi)
  801216:	e8 49 ff ff ff       	call   801164 <dev_lookup>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 1a                	js     80123e <fd_close+0x7b>
		if (dev->dev_close)
  801224:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801227:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80122a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80122f:	85 c0                	test   %eax,%eax
  801231:	74 0b                	je     80123e <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	56                   	push   %esi
  801237:	ff d0                	call   *%eax
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	56                   	push   %esi
  801242:	6a 00                	push   $0x0
  801244:	e8 69 fa ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	eb b5                	jmp    801203 <fd_close+0x40>

0080124e <close>:

int
close(int fdnum)
{
  80124e:	f3 0f 1e fb          	endbr32 
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	ff 75 08             	pushl  0x8(%ebp)
  80125f:	e8 ac fe ff ff       	call   801110 <fd_lookup>
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	79 02                	jns    80126d <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    
		return fd_close(fd, 1);
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	6a 01                	push   $0x1
  801272:	ff 75 f4             	pushl  -0xc(%ebp)
  801275:	e8 49 ff ff ff       	call   8011c3 <fd_close>
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	eb ec                	jmp    80126b <close+0x1d>

0080127f <close_all>:

void
close_all(void)
{
  80127f:	f3 0f 1e fb          	endbr32 
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80128a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	53                   	push   %ebx
  801293:	e8 b6 ff ff ff       	call   80124e <close>
	for (i = 0; i < MAXFD; i++)
  801298:	83 c3 01             	add    $0x1,%ebx
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	83 fb 20             	cmp    $0x20,%ebx
  8012a1:	75 ec                	jne    80128f <close_all+0x10>
}
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a8:	f3 0f 1e fb          	endbr32 
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
  8012b2:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	ff 75 08             	pushl  0x8(%ebp)
  8012bc:	e8 4f fe ff ff       	call   801110 <fd_lookup>
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	0f 88 81 00 00 00    	js     80134f <dup+0xa7>
		return r;
	close(newfdnum);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	ff 75 0c             	pushl  0xc(%ebp)
  8012d4:	e8 75 ff ff ff       	call   80124e <close>

	newfd = INDEX2FD(newfdnum);
  8012d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012dc:	c1 e6 0c             	shl    $0xc,%esi
  8012df:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012e5:	83 c4 04             	add    $0x4,%esp
  8012e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012eb:	e8 af fd ff ff       	call   80109f <fd2data>
  8012f0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012f2:	89 34 24             	mov    %esi,(%esp)
  8012f5:	e8 a5 fd ff ff       	call   80109f <fd2data>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ff:	89 d8                	mov    %ebx,%eax
  801301:	c1 e8 16             	shr    $0x16,%eax
  801304:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130b:	a8 01                	test   $0x1,%al
  80130d:	74 11                	je     801320 <dup+0x78>
  80130f:	89 d8                	mov    %ebx,%eax
  801311:	c1 e8 0c             	shr    $0xc,%eax
  801314:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80131b:	f6 c2 01             	test   $0x1,%dl
  80131e:	75 39                	jne    801359 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801320:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801323:	89 d0                	mov    %edx,%eax
  801325:	c1 e8 0c             	shr    $0xc,%eax
  801328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80132f:	83 ec 0c             	sub    $0xc,%esp
  801332:	25 07 0e 00 00       	and    $0xe07,%eax
  801337:	50                   	push   %eax
  801338:	56                   	push   %esi
  801339:	6a 00                	push   $0x0
  80133b:	52                   	push   %edx
  80133c:	6a 00                	push   $0x0
  80133e:	e8 4a f9 ff ff       	call   800c8d <sys_page_map>
  801343:	89 c3                	mov    %eax,%ebx
  801345:	83 c4 20             	add    $0x20,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 31                	js     80137d <dup+0xd5>
		goto err;

	return newfdnum;
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80134f:	89 d8                	mov    %ebx,%eax
  801351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801359:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801360:	83 ec 0c             	sub    $0xc,%esp
  801363:	25 07 0e 00 00       	and    $0xe07,%eax
  801368:	50                   	push   %eax
  801369:	57                   	push   %edi
  80136a:	6a 00                	push   $0x0
  80136c:	53                   	push   %ebx
  80136d:	6a 00                	push   $0x0
  80136f:	e8 19 f9 ff ff       	call   800c8d <sys_page_map>
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 20             	add    $0x20,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	79 a3                	jns    801320 <dup+0x78>
	sys_page_unmap(0, newfd);
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	56                   	push   %esi
  801381:	6a 00                	push   $0x0
  801383:	e8 2a f9 ff ff       	call   800cb2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	57                   	push   %edi
  80138c:	6a 00                	push   $0x0
  80138e:	e8 1f f9 ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	eb b7                	jmp    80134f <dup+0xa7>

00801398 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801398:	f3 0f 1e fb          	endbr32 
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	53                   	push   %ebx
  8013a0:	83 ec 1c             	sub    $0x1c,%esp
  8013a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	53                   	push   %ebx
  8013ab:	e8 60 fd ff ff       	call   801110 <fd_lookup>
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 3f                	js     8013f6 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c1:	ff 30                	pushl  (%eax)
  8013c3:	e8 9c fd ff ff       	call   801164 <dev_lookup>
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 27                	js     8013f6 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d2:	8b 42 08             	mov    0x8(%edx),%eax
  8013d5:	83 e0 03             	and    $0x3,%eax
  8013d8:	83 f8 01             	cmp    $0x1,%eax
  8013db:	74 1e                	je     8013fb <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e0:	8b 40 08             	mov    0x8(%eax),%eax
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	74 35                	je     80141c <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013e7:	83 ec 04             	sub    $0x4,%esp
  8013ea:	ff 75 10             	pushl  0x10(%ebp)
  8013ed:	ff 75 0c             	pushl  0xc(%ebp)
  8013f0:	52                   	push   %edx
  8013f1:	ff d0                	call   *%eax
  8013f3:	83 c4 10             	add    $0x10,%esp
}
  8013f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013fb:	a1 08 40 80 00       	mov    0x804008,%eax
  801400:	8b 40 48             	mov    0x48(%eax),%eax
  801403:	83 ec 04             	sub    $0x4,%esp
  801406:	53                   	push   %ebx
  801407:	50                   	push   %eax
  801408:	68 7d 2b 80 00       	push   $0x802b7d
  80140d:	e8 e2 ed ff ff       	call   8001f4 <cprintf>
		return -E_INVAL;
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141a:	eb da                	jmp    8013f6 <read+0x5e>
		return -E_NOT_SUPP;
  80141c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801421:	eb d3                	jmp    8013f6 <read+0x5e>

00801423 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801423:	f3 0f 1e fb          	endbr32 
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	8b 7d 08             	mov    0x8(%ebp),%edi
  801433:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801436:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143b:	eb 02                	jmp    80143f <readn+0x1c>
  80143d:	01 c3                	add    %eax,%ebx
  80143f:	39 f3                	cmp    %esi,%ebx
  801441:	73 21                	jae    801464 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	89 f0                	mov    %esi,%eax
  801448:	29 d8                	sub    %ebx,%eax
  80144a:	50                   	push   %eax
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	03 45 0c             	add    0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	57                   	push   %edi
  801452:	e8 41 ff ff ff       	call   801398 <read>
		if (m < 0)
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 04                	js     801462 <readn+0x3f>
			return m;
		if (m == 0)
  80145e:	75 dd                	jne    80143d <readn+0x1a>
  801460:	eb 02                	jmp    801464 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801462:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801464:	89 d8                	mov    %ebx,%eax
  801466:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146e:	f3 0f 1e fb          	endbr32 
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	53                   	push   %ebx
  801476:	83 ec 1c             	sub    $0x1c,%esp
  801479:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	53                   	push   %ebx
  801481:	e8 8a fc ff ff       	call   801110 <fd_lookup>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 3a                	js     8014c7 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801497:	ff 30                	pushl  (%eax)
  801499:	e8 c6 fc ff ff       	call   801164 <dev_lookup>
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 22                	js     8014c7 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ac:	74 1e                	je     8014cc <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b4:	85 d2                	test   %edx,%edx
  8014b6:	74 35                	je     8014ed <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	ff 75 10             	pushl  0x10(%ebp)
  8014be:	ff 75 0c             	pushl  0xc(%ebp)
  8014c1:	50                   	push   %eax
  8014c2:	ff d2                	call   *%edx
  8014c4:	83 c4 10             	add    $0x10,%esp
}
  8014c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8014d1:	8b 40 48             	mov    0x48(%eax),%eax
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	53                   	push   %ebx
  8014d8:	50                   	push   %eax
  8014d9:	68 99 2b 80 00       	push   $0x802b99
  8014de:	e8 11 ed ff ff       	call   8001f4 <cprintf>
		return -E_INVAL;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014eb:	eb da                	jmp    8014c7 <write+0x59>
		return -E_NOT_SUPP;
  8014ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014f2:	eb d3                	jmp    8014c7 <write+0x59>

008014f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014f4:	f3 0f 1e fb          	endbr32 
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	ff 75 08             	pushl  0x8(%ebp)
  801505:	e8 06 fc ff ff       	call   801110 <fd_lookup>
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 0e                	js     80151f <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801511:	8b 55 0c             	mov    0xc(%ebp),%edx
  801514:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801517:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80151a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801521:	f3 0f 1e fb          	endbr32 
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	53                   	push   %ebx
  801529:	83 ec 1c             	sub    $0x1c,%esp
  80152c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	53                   	push   %ebx
  801534:	e8 d7 fb ff ff       	call   801110 <fd_lookup>
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 37                	js     801577 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	ff 30                	pushl  (%eax)
  80154c:	e8 13 fc ff ff       	call   801164 <dev_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 1f                	js     801577 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155f:	74 1b                	je     80157c <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801561:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801564:	8b 52 18             	mov    0x18(%edx),%edx
  801567:	85 d2                	test   %edx,%edx
  801569:	74 32                	je     80159d <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	ff 75 0c             	pushl  0xc(%ebp)
  801571:	50                   	push   %eax
  801572:	ff d2                	call   *%edx
  801574:	83 c4 10             	add    $0x10,%esp
}
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80157c:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801581:	8b 40 48             	mov    0x48(%eax),%eax
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	53                   	push   %ebx
  801588:	50                   	push   %eax
  801589:	68 5c 2b 80 00       	push   $0x802b5c
  80158e:	e8 61 ec ff ff       	call   8001f4 <cprintf>
		return -E_INVAL;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159b:	eb da                	jmp    801577 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80159d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a2:	eb d3                	jmp    801577 <ftruncate+0x56>

008015a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015a4:	f3 0f 1e fb          	endbr32 
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 1c             	sub    $0x1c,%esp
  8015af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	ff 75 08             	pushl  0x8(%ebp)
  8015b9:	e8 52 fb ff ff       	call   801110 <fd_lookup>
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 4b                	js     801610 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	ff 30                	pushl  (%eax)
  8015d1:	e8 8e fb ff ff       	call   801164 <dev_lookup>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 33                	js     801610 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8015dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015e4:	74 2f                	je     801615 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015e6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015e9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f0:	00 00 00 
	stat->st_isdir = 0;
  8015f3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015fa:	00 00 00 
	stat->st_dev = dev;
  8015fd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	53                   	push   %ebx
  801607:	ff 75 f0             	pushl  -0x10(%ebp)
  80160a:	ff 50 14             	call   *0x14(%eax)
  80160d:	83 c4 10             	add    $0x10,%esp
}
  801610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801613:	c9                   	leave  
  801614:	c3                   	ret    
		return -E_NOT_SUPP;
  801615:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161a:	eb f4                	jmp    801610 <fstat+0x6c>

0080161c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80161c:	f3 0f 1e fb          	endbr32 
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	6a 00                	push   $0x0
  80162a:	ff 75 08             	pushl  0x8(%ebp)
  80162d:	e8 01 02 00 00       	call   801833 <open>
  801632:	89 c3                	mov    %eax,%ebx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 1b                	js     801656 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	ff 75 0c             	pushl  0xc(%ebp)
  801641:	50                   	push   %eax
  801642:	e8 5d ff ff ff       	call   8015a4 <fstat>
  801647:	89 c6                	mov    %eax,%esi
	close(fd);
  801649:	89 1c 24             	mov    %ebx,(%esp)
  80164c:	e8 fd fb ff ff       	call   80124e <close>
	return r;
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	89 f3                	mov    %esi,%ebx
}
  801656:	89 d8                	mov    %ebx,%eax
  801658:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165b:	5b                   	pop    %ebx
  80165c:	5e                   	pop    %esi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    

0080165f <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	56                   	push   %esi
  801663:	53                   	push   %ebx
  801664:	89 c6                	mov    %eax,%esi
  801666:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801668:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80166f:	74 27                	je     801698 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801671:	6a 07                	push   $0x7
  801673:	68 00 50 80 00       	push   $0x805000
  801678:	56                   	push   %esi
  801679:	ff 35 00 40 80 00    	pushl  0x804000
  80167f:	e8 5d 0d 00 00       	call   8023e1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801684:	83 c4 0c             	add    $0xc,%esp
  801687:	6a 00                	push   $0x0
  801689:	53                   	push   %ebx
  80168a:	6a 00                	push   $0x0
  80168c:	e8 e3 0c 00 00       	call   802374 <ipc_recv>
}
  801691:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801698:	83 ec 0c             	sub    $0xc,%esp
  80169b:	6a 01                	push   $0x1
  80169d:	e8 97 0d 00 00       	call   802439 <ipc_find_env>
  8016a2:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	eb c5                	jmp    801671 <fsipc+0x12>

008016ac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016ac:	f3 0f 1e fb          	endbr32 
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ce:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d3:	e8 87 ff ff ff       	call   80165f <fsipc>
}
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <devfile_flush>:
{
  8016da:	f3 0f 1e fb          	endbr32 
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ea:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f9:	e8 61 ff ff ff       	call   80165f <fsipc>
}
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <devfile_stat>:
{
  801700:	f3 0f 1e fb          	endbr32 
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	53                   	push   %ebx
  801708:	83 ec 04             	sub    $0x4,%esp
  80170b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	8b 40 0c             	mov    0xc(%eax),%eax
  801714:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801719:	ba 00 00 00 00       	mov    $0x0,%edx
  80171e:	b8 05 00 00 00       	mov    $0x5,%eax
  801723:	e8 37 ff ff ff       	call   80165f <fsipc>
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 2c                	js     801758 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80172c:	83 ec 08             	sub    $0x8,%esp
  80172f:	68 00 50 80 00       	push   $0x805000
  801734:	53                   	push   %ebx
  801735:	e8 c4 f0 ff ff       	call   8007fe <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80173a:	a1 80 50 80 00       	mov    0x805080,%eax
  80173f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801745:	a1 84 50 80 00       	mov    0x805084,%eax
  80174a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <devfile_write>:
{
  80175d:	f3 0f 1e fb          	endbr32 
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 0c             	sub    $0xc,%esp
  801767:	8b 45 10             	mov    0x10(%ebp),%eax
  80176a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80176f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801774:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801777:	8b 55 08             	mov    0x8(%ebp),%edx
  80177a:	8b 52 0c             	mov    0xc(%edx),%edx
  80177d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801783:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801788:	50                   	push   %eax
  801789:	ff 75 0c             	pushl  0xc(%ebp)
  80178c:	68 08 50 80 00       	push   $0x805008
  801791:	e8 66 f2 ff ff       	call   8009fc <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 04 00 00 00       	mov    $0x4,%eax
  8017a0:	e8 ba fe ff ff       	call   80165f <fsipc>
}
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <devfile_read>:
{
  8017a7:	f3 0f 1e fb          	endbr32 
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
  8017b0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017be:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017ce:	e8 8c fe ff ff       	call   80165f <fsipc>
  8017d3:	89 c3                	mov    %eax,%ebx
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 1f                	js     8017f8 <devfile_read+0x51>
	assert(r <= n);
  8017d9:	39 f0                	cmp    %esi,%eax
  8017db:	77 24                	ja     801801 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8017dd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e2:	7f 36                	jg     80181a <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	50                   	push   %eax
  8017e8:	68 00 50 80 00       	push   $0x805000
  8017ed:	ff 75 0c             	pushl  0xc(%ebp)
  8017f0:	e8 07 f2 ff ff       	call   8009fc <memmove>
	return r;
  8017f5:	83 c4 10             	add    $0x10,%esp
}
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    
	assert(r <= n);
  801801:	68 cc 2b 80 00       	push   $0x802bcc
  801806:	68 d3 2b 80 00       	push   $0x802bd3
  80180b:	68 8c 00 00 00       	push   $0x8c
  801810:	68 e8 2b 80 00       	push   $0x802be8
  801815:	e8 79 0a 00 00       	call   802293 <_panic>
	assert(r <= PGSIZE);
  80181a:	68 f3 2b 80 00       	push   $0x802bf3
  80181f:	68 d3 2b 80 00       	push   $0x802bd3
  801824:	68 8d 00 00 00       	push   $0x8d
  801829:	68 e8 2b 80 00       	push   $0x802be8
  80182e:	e8 60 0a 00 00       	call   802293 <_panic>

00801833 <open>:
{
  801833:	f3 0f 1e fb          	endbr32 
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	83 ec 1c             	sub    $0x1c,%esp
  80183f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801842:	56                   	push   %esi
  801843:	e8 73 ef ff ff       	call   8007bb <strlen>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801850:	7f 6c                	jg     8018be <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801858:	50                   	push   %eax
  801859:	e8 5c f8 ff ff       	call   8010ba <fd_alloc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	78 3c                	js     8018a3 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	56                   	push   %esi
  80186b:	68 00 50 80 00       	push   $0x805000
  801870:	e8 89 ef ff ff       	call   8007fe <strcpy>
	fsipcbuf.open.req_omode = mode;
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80187d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801880:	b8 01 00 00 00       	mov    $0x1,%eax
  801885:	e8 d5 fd ff ff       	call   80165f <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 19                	js     8018ac <open+0x79>
	return fd2num(fd);
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	ff 75 f4             	pushl  -0xc(%ebp)
  801899:	e8 ed f7 ff ff       	call   80108b <fd2num>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
}
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    
		fd_close(fd, 0);
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	6a 00                	push   $0x0
  8018b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b4:	e8 0a f9 ff ff       	call   8011c3 <fd_close>
		return r;
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	eb e5                	jmp    8018a3 <open+0x70>
		return -E_BAD_PATH;
  8018be:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018c3:	eb de                	jmp    8018a3 <open+0x70>

008018c5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018c5:	f3 0f 1e fb          	endbr32 
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d9:	e8 81 fd ff ff       	call   80165f <fsipc>
}
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018e0:	f3 0f 1e fb          	endbr32 
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018ea:	68 5f 2c 80 00       	push   $0x802c5f
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	e8 07 ef ff ff       	call   8007fe <strcpy>
	return 0;
}
  8018f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fc:	c9                   	leave  
  8018fd:	c3                   	ret    

008018fe <devsock_close>:
{
  8018fe:	f3 0f 1e fb          	endbr32 
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 10             	sub    $0x10,%esp
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80190c:	53                   	push   %ebx
  80190d:	e8 64 0b 00 00       	call   802476 <pageref>
  801912:	89 c2                	mov    %eax,%edx
  801914:	83 c4 10             	add    $0x10,%esp
		return 0;
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80191c:	83 fa 01             	cmp    $0x1,%edx
  80191f:	74 05                	je     801926 <devsock_close+0x28>
}
  801921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801924:	c9                   	leave  
  801925:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	ff 73 0c             	pushl  0xc(%ebx)
  80192c:	e8 e3 02 00 00       	call   801c14 <nsipc_close>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	eb eb                	jmp    801921 <devsock_close+0x23>

00801936 <devsock_write>:
{
  801936:	f3 0f 1e fb          	endbr32 
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801940:	6a 00                	push   $0x0
  801942:	ff 75 10             	pushl  0x10(%ebp)
  801945:	ff 75 0c             	pushl  0xc(%ebp)
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	ff 70 0c             	pushl  0xc(%eax)
  80194e:	e8 b5 03 00 00       	call   801d08 <nsipc_send>
}
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <devsock_read>:
{
  801955:	f3 0f 1e fb          	endbr32 
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80195f:	6a 00                	push   $0x0
  801961:	ff 75 10             	pushl  0x10(%ebp)
  801964:	ff 75 0c             	pushl  0xc(%ebp)
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	ff 70 0c             	pushl  0xc(%eax)
  80196d:	e8 1f 03 00 00       	call   801c91 <nsipc_recv>
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <fd2sockid>:
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80197a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80197d:	52                   	push   %edx
  80197e:	50                   	push   %eax
  80197f:	e8 8c f7 ff ff       	call   801110 <fd_lookup>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	78 10                	js     80199b <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  80198b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198e:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801994:	39 08                	cmp    %ecx,(%eax)
  801996:	75 05                	jne    80199d <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801998:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    
		return -E_NOT_SUPP;
  80199d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a2:	eb f7                	jmp    80199b <fd2sockid+0x27>

008019a4 <alloc_sockfd>:
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 1c             	sub    $0x1c,%esp
  8019ac:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8019ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b1:	50                   	push   %eax
  8019b2:	e8 03 f7 ff ff       	call   8010ba <fd_alloc>
  8019b7:	89 c3                	mov    %eax,%ebx
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 43                	js     801a03 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019c0:	83 ec 04             	sub    $0x4,%esp
  8019c3:	68 07 04 00 00       	push   $0x407
  8019c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cb:	6a 00                	push   $0x0
  8019cd:	e8 95 f2 ff ff       	call   800c67 <sys_page_alloc>
  8019d2:	89 c3                	mov    %eax,%ebx
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 28                	js     801a03 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8019e4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019f0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	50                   	push   %eax
  8019f7:	e8 8f f6 ff ff       	call   80108b <fd2num>
  8019fc:	89 c3                	mov    %eax,%ebx
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	eb 0c                	jmp    801a0f <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	56                   	push   %esi
  801a07:	e8 08 02 00 00       	call   801c14 <nsipc_close>
		return r;
  801a0c:	83 c4 10             	add    $0x10,%esp
}
  801a0f:	89 d8                	mov    %ebx,%eax
  801a11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a14:	5b                   	pop    %ebx
  801a15:	5e                   	pop    %esi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <accept>:
{
  801a18:	f3 0f 1e fb          	endbr32 
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a22:	8b 45 08             	mov    0x8(%ebp),%eax
  801a25:	e8 4a ff ff ff       	call   801974 <fd2sockid>
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	78 1b                	js     801a49 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a2e:	83 ec 04             	sub    $0x4,%esp
  801a31:	ff 75 10             	pushl  0x10(%ebp)
  801a34:	ff 75 0c             	pushl  0xc(%ebp)
  801a37:	50                   	push   %eax
  801a38:	e8 22 01 00 00       	call   801b5f <nsipc_accept>
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 05                	js     801a49 <accept+0x31>
	return alloc_sockfd(r);
  801a44:	e8 5b ff ff ff       	call   8019a4 <alloc_sockfd>
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <bind>:
{
  801a4b:	f3 0f 1e fb          	endbr32 
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	e8 17 ff ff ff       	call   801974 <fd2sockid>
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 12                	js     801a73 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	ff 75 10             	pushl  0x10(%ebp)
  801a67:	ff 75 0c             	pushl  0xc(%ebp)
  801a6a:	50                   	push   %eax
  801a6b:	e8 45 01 00 00       	call   801bb5 <nsipc_bind>
  801a70:	83 c4 10             	add    $0x10,%esp
}
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <shutdown>:
{
  801a75:	f3 0f 1e fb          	endbr32 
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	e8 ed fe ff ff       	call   801974 <fd2sockid>
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 0f                	js     801a9a <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801a8b:	83 ec 08             	sub    $0x8,%esp
  801a8e:	ff 75 0c             	pushl  0xc(%ebp)
  801a91:	50                   	push   %eax
  801a92:	e8 57 01 00 00       	call   801bee <nsipc_shutdown>
  801a97:	83 c4 10             	add    $0x10,%esp
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <connect>:
{
  801a9c:	f3 0f 1e fb          	endbr32 
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	e8 c6 fe ff ff       	call   801974 <fd2sockid>
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 12                	js     801ac4 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801ab2:	83 ec 04             	sub    $0x4,%esp
  801ab5:	ff 75 10             	pushl  0x10(%ebp)
  801ab8:	ff 75 0c             	pushl  0xc(%ebp)
  801abb:	50                   	push   %eax
  801abc:	e8 71 01 00 00       	call   801c32 <nsipc_connect>
  801ac1:	83 c4 10             	add    $0x10,%esp
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <listen>:
{
  801ac6:	f3 0f 1e fb          	endbr32 
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad3:	e8 9c fe ff ff       	call   801974 <fd2sockid>
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 0f                	js     801aeb <listen+0x25>
	return nsipc_listen(r, backlog);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	ff 75 0c             	pushl  0xc(%ebp)
  801ae2:	50                   	push   %eax
  801ae3:	e8 83 01 00 00       	call   801c6b <nsipc_listen>
  801ae8:	83 c4 10             	add    $0x10,%esp
}
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <socket>:

int
socket(int domain, int type, int protocol)
{
  801aed:	f3 0f 1e fb          	endbr32 
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801af7:	ff 75 10             	pushl  0x10(%ebp)
  801afa:	ff 75 0c             	pushl  0xc(%ebp)
  801afd:	ff 75 08             	pushl  0x8(%ebp)
  801b00:	e8 65 02 00 00       	call   801d6a <nsipc_socket>
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	78 05                	js     801b11 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801b0c:	e8 93 fe ff ff       	call   8019a4 <alloc_sockfd>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	53                   	push   %ebx
  801b17:	83 ec 04             	sub    $0x4,%esp
  801b1a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b1c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b23:	74 26                	je     801b4b <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b25:	6a 07                	push   $0x7
  801b27:	68 00 60 80 00       	push   $0x806000
  801b2c:	53                   	push   %ebx
  801b2d:	ff 35 04 40 80 00    	pushl  0x804004
  801b33:	e8 a9 08 00 00       	call   8023e1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b38:	83 c4 0c             	add    $0xc,%esp
  801b3b:	6a 00                	push   $0x0
  801b3d:	6a 00                	push   $0x0
  801b3f:	6a 00                	push   $0x0
  801b41:	e8 2e 08 00 00       	call   802374 <ipc_recv>
}
  801b46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	6a 02                	push   $0x2
  801b50:	e8 e4 08 00 00       	call   802439 <ipc_find_env>
  801b55:	a3 04 40 80 00       	mov    %eax,0x804004
  801b5a:	83 c4 10             	add    $0x10,%esp
  801b5d:	eb c6                	jmp    801b25 <nsipc+0x12>

00801b5f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b5f:	f3 0f 1e fb          	endbr32 
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b73:	8b 06                	mov    (%esi),%eax
  801b75:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7f:	e8 8f ff ff ff       	call   801b13 <nsipc>
  801b84:	89 c3                	mov    %eax,%ebx
  801b86:	85 c0                	test   %eax,%eax
  801b88:	79 09                	jns    801b93 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801b8a:	89 d8                	mov    %ebx,%eax
  801b8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b93:	83 ec 04             	sub    $0x4,%esp
  801b96:	ff 35 10 60 80 00    	pushl  0x806010
  801b9c:	68 00 60 80 00       	push   $0x806000
  801ba1:	ff 75 0c             	pushl  0xc(%ebp)
  801ba4:	e8 53 ee ff ff       	call   8009fc <memmove>
		*addrlen = ret->ret_addrlen;
  801ba9:	a1 10 60 80 00       	mov    0x806010,%eax
  801bae:	89 06                	mov    %eax,(%esi)
  801bb0:	83 c4 10             	add    $0x10,%esp
	return r;
  801bb3:	eb d5                	jmp    801b8a <nsipc_accept+0x2b>

00801bb5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bb5:	f3 0f 1e fb          	endbr32 
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bcb:	53                   	push   %ebx
  801bcc:	ff 75 0c             	pushl  0xc(%ebp)
  801bcf:	68 04 60 80 00       	push   $0x806004
  801bd4:	e8 23 ee ff ff       	call   8009fc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bd9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bdf:	b8 02 00 00 00       	mov    $0x2,%eax
  801be4:	e8 2a ff ff ff       	call   801b13 <nsipc>
}
  801be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801bee:	f3 0f 1e fb          	endbr32 
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c03:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c08:	b8 03 00 00 00       	mov    $0x3,%eax
  801c0d:	e8 01 ff ff ff       	call   801b13 <nsipc>
}
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <nsipc_close>:

int
nsipc_close(int s)
{
  801c14:	f3 0f 1e fb          	endbr32 
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c26:	b8 04 00 00 00       	mov    $0x4,%eax
  801c2b:	e8 e3 fe ff ff       	call   801b13 <nsipc>
}
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    

00801c32 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c32:	f3 0f 1e fb          	endbr32 
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 08             	sub    $0x8,%esp
  801c3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c48:	53                   	push   %ebx
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	68 04 60 80 00       	push   $0x806004
  801c51:	e8 a6 ed ff ff       	call   8009fc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c56:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c5c:	b8 05 00 00 00       	mov    $0x5,%eax
  801c61:	e8 ad fe ff ff       	call   801b13 <nsipc>
}
  801c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c6b:	f3 0f 1e fb          	endbr32 
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c75:	8b 45 08             	mov    0x8(%ebp),%eax
  801c78:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c80:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c85:	b8 06 00 00 00       	mov    $0x6,%eax
  801c8a:	e8 84 fe ff ff       	call   801b13 <nsipc>
}
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c91:	f3 0f 1e fb          	endbr32 
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	56                   	push   %esi
  801c99:	53                   	push   %ebx
  801c9a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ca5:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cab:	8b 45 14             	mov    0x14(%ebp),%eax
  801cae:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cb3:	b8 07 00 00 00       	mov    $0x7,%eax
  801cb8:	e8 56 fe ff ff       	call   801b13 <nsipc>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 26                	js     801ce9 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801cc3:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801cc9:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801cce:	0f 4e c6             	cmovle %esi,%eax
  801cd1:	39 c3                	cmp    %eax,%ebx
  801cd3:	7f 1d                	jg     801cf2 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cd5:	83 ec 04             	sub    $0x4,%esp
  801cd8:	53                   	push   %ebx
  801cd9:	68 00 60 80 00       	push   $0x806000
  801cde:	ff 75 0c             	pushl  0xc(%ebp)
  801ce1:	e8 16 ed ff ff       	call   8009fc <memmove>
  801ce6:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ce9:	89 d8                	mov    %ebx,%eax
  801ceb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5e                   	pop    %esi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801cf2:	68 6b 2c 80 00       	push   $0x802c6b
  801cf7:	68 d3 2b 80 00       	push   $0x802bd3
  801cfc:	6a 62                	push   $0x62
  801cfe:	68 80 2c 80 00       	push   $0x802c80
  801d03:	e8 8b 05 00 00       	call   802293 <_panic>

00801d08 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d08:	f3 0f 1e fb          	endbr32 
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 04             	sub    $0x4,%esp
  801d13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d1e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d24:	7f 2e                	jg     801d54 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d26:	83 ec 04             	sub    $0x4,%esp
  801d29:	53                   	push   %ebx
  801d2a:	ff 75 0c             	pushl  0xc(%ebp)
  801d2d:	68 0c 60 80 00       	push   $0x80600c
  801d32:	e8 c5 ec ff ff       	call   8009fc <memmove>
	nsipcbuf.send.req_size = size;
  801d37:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d40:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d45:	b8 08 00 00 00       	mov    $0x8,%eax
  801d4a:	e8 c4 fd ff ff       	call   801b13 <nsipc>
}
  801d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    
	assert(size < 1600);
  801d54:	68 8c 2c 80 00       	push   $0x802c8c
  801d59:	68 d3 2b 80 00       	push   $0x802bd3
  801d5e:	6a 6d                	push   $0x6d
  801d60:	68 80 2c 80 00       	push   $0x802c80
  801d65:	e8 29 05 00 00       	call   802293 <_panic>

00801d6a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d6a:	f3 0f 1e fb          	endbr32 
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d74:	8b 45 08             	mov    0x8(%ebp),%eax
  801d77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d84:	8b 45 10             	mov    0x10(%ebp),%eax
  801d87:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d8c:	b8 09 00 00 00       	mov    $0x9,%eax
  801d91:	e8 7d fd ff ff       	call   801b13 <nsipc>
}
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d98:	f3 0f 1e fb          	endbr32 
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	ff 75 08             	pushl  0x8(%ebp)
  801daa:	e8 f0 f2 ff ff       	call   80109f <fd2data>
  801daf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801db1:	83 c4 08             	add    $0x8,%esp
  801db4:	68 98 2c 80 00       	push   $0x802c98
  801db9:	53                   	push   %ebx
  801dba:	e8 3f ea ff ff       	call   8007fe <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dbf:	8b 46 04             	mov    0x4(%esi),%eax
  801dc2:	2b 06                	sub    (%esi),%eax
  801dc4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801dd1:	00 00 00 
	stat->st_dev = &devpipe;
  801dd4:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801ddb:	30 80 00 
	return 0;
}
  801dde:	b8 00 00 00 00       	mov    $0x0,%eax
  801de3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    

00801dea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dea:	f3 0f 1e fb          	endbr32 
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	53                   	push   %ebx
  801df2:	83 ec 0c             	sub    $0xc,%esp
  801df5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801df8:	53                   	push   %ebx
  801df9:	6a 00                	push   $0x0
  801dfb:	e8 b2 ee ff ff       	call   800cb2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e00:	89 1c 24             	mov    %ebx,(%esp)
  801e03:	e8 97 f2 ff ff       	call   80109f <fd2data>
  801e08:	83 c4 08             	add    $0x8,%esp
  801e0b:	50                   	push   %eax
  801e0c:	6a 00                	push   $0x0
  801e0e:	e8 9f ee ff ff       	call   800cb2 <sys_page_unmap>
}
  801e13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <_pipeisclosed>:
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	57                   	push   %edi
  801e1c:	56                   	push   %esi
  801e1d:	53                   	push   %ebx
  801e1e:	83 ec 1c             	sub    $0x1c,%esp
  801e21:	89 c7                	mov    %eax,%edi
  801e23:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e25:	a1 08 40 80 00       	mov    0x804008,%eax
  801e2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	57                   	push   %edi
  801e31:	e8 40 06 00 00       	call   802476 <pageref>
  801e36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e39:	89 34 24             	mov    %esi,(%esp)
  801e3c:	e8 35 06 00 00       	call   802476 <pageref>
		nn = thisenv->env_runs;
  801e41:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e47:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	39 cb                	cmp    %ecx,%ebx
  801e4f:	74 1b                	je     801e6c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e51:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e54:	75 cf                	jne    801e25 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e56:	8b 42 58             	mov    0x58(%edx),%eax
  801e59:	6a 01                	push   $0x1
  801e5b:	50                   	push   %eax
  801e5c:	53                   	push   %ebx
  801e5d:	68 9f 2c 80 00       	push   $0x802c9f
  801e62:	e8 8d e3 ff ff       	call   8001f4 <cprintf>
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	eb b9                	jmp    801e25 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801e6c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e6f:	0f 94 c0             	sete   %al
  801e72:	0f b6 c0             	movzbl %al,%eax
}
  801e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    

00801e7d <devpipe_write>:
{
  801e7d:	f3 0f 1e fb          	endbr32 
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	57                   	push   %edi
  801e85:	56                   	push   %esi
  801e86:	53                   	push   %ebx
  801e87:	83 ec 28             	sub    $0x28,%esp
  801e8a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e8d:	56                   	push   %esi
  801e8e:	e8 0c f2 ff ff       	call   80109f <fd2data>
  801e93:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	bf 00 00 00 00       	mov    $0x0,%edi
  801e9d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ea0:	74 4f                	je     801ef1 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ea2:	8b 43 04             	mov    0x4(%ebx),%eax
  801ea5:	8b 0b                	mov    (%ebx),%ecx
  801ea7:	8d 51 20             	lea    0x20(%ecx),%edx
  801eaa:	39 d0                	cmp    %edx,%eax
  801eac:	72 14                	jb     801ec2 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801eae:	89 da                	mov    %ebx,%edx
  801eb0:	89 f0                	mov    %esi,%eax
  801eb2:	e8 61 ff ff ff       	call   801e18 <_pipeisclosed>
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	75 3b                	jne    801ef6 <devpipe_write+0x79>
			sys_yield();
  801ebb:	e8 84 ed ff ff       	call   800c44 <sys_yield>
  801ec0:	eb e0                	jmp    801ea2 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ec2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ec5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ec9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ecc:	89 c2                	mov    %eax,%edx
  801ece:	c1 fa 1f             	sar    $0x1f,%edx
  801ed1:	89 d1                	mov    %edx,%ecx
  801ed3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ed6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ed9:	83 e2 1f             	and    $0x1f,%edx
  801edc:	29 ca                	sub    %ecx,%edx
  801ede:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ee2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ee6:	83 c0 01             	add    $0x1,%eax
  801ee9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801eec:	83 c7 01             	add    $0x1,%edi
  801eef:	eb ac                	jmp    801e9d <devpipe_write+0x20>
	return i;
  801ef1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef4:	eb 05                	jmp    801efb <devpipe_write+0x7e>
				return 0;
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5f                   	pop    %edi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <devpipe_read>:
{
  801f03:	f3 0f 1e fb          	endbr32 
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	57                   	push   %edi
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 18             	sub    $0x18,%esp
  801f10:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f13:	57                   	push   %edi
  801f14:	e8 86 f1 ff ff       	call   80109f <fd2data>
  801f19:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	be 00 00 00 00       	mov    $0x0,%esi
  801f23:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f26:	75 14                	jne    801f3c <devpipe_read+0x39>
	return i;
  801f28:	8b 45 10             	mov    0x10(%ebp),%eax
  801f2b:	eb 02                	jmp    801f2f <devpipe_read+0x2c>
				return i;
  801f2d:	89 f0                	mov    %esi,%eax
}
  801f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    
			sys_yield();
  801f37:	e8 08 ed ff ff       	call   800c44 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f3c:	8b 03                	mov    (%ebx),%eax
  801f3e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f41:	75 18                	jne    801f5b <devpipe_read+0x58>
			if (i > 0)
  801f43:	85 f6                	test   %esi,%esi
  801f45:	75 e6                	jne    801f2d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801f47:	89 da                	mov    %ebx,%edx
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	e8 c8 fe ff ff       	call   801e18 <_pipeisclosed>
  801f50:	85 c0                	test   %eax,%eax
  801f52:	74 e3                	je     801f37 <devpipe_read+0x34>
				return 0;
  801f54:	b8 00 00 00 00       	mov    $0x0,%eax
  801f59:	eb d4                	jmp    801f2f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f5b:	99                   	cltd   
  801f5c:	c1 ea 1b             	shr    $0x1b,%edx
  801f5f:	01 d0                	add    %edx,%eax
  801f61:	83 e0 1f             	and    $0x1f,%eax
  801f64:	29 d0                	sub    %edx,%eax
  801f66:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f6e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f71:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f74:	83 c6 01             	add    $0x1,%esi
  801f77:	eb aa                	jmp    801f23 <devpipe_read+0x20>

00801f79 <pipe>:
{
  801f79:	f3 0f 1e fb          	endbr32 
  801f7d:	55                   	push   %ebp
  801f7e:	89 e5                	mov    %esp,%ebp
  801f80:	56                   	push   %esi
  801f81:	53                   	push   %ebx
  801f82:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f88:	50                   	push   %eax
  801f89:	e8 2c f1 ff ff       	call   8010ba <fd_alloc>
  801f8e:	89 c3                	mov    %eax,%ebx
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	85 c0                	test   %eax,%eax
  801f95:	0f 88 23 01 00 00    	js     8020be <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9b:	83 ec 04             	sub    $0x4,%esp
  801f9e:	68 07 04 00 00       	push   $0x407
  801fa3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa6:	6a 00                	push   $0x0
  801fa8:	e8 ba ec ff ff       	call   800c67 <sys_page_alloc>
  801fad:	89 c3                	mov    %eax,%ebx
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	0f 88 04 01 00 00    	js     8020be <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fc0:	50                   	push   %eax
  801fc1:	e8 f4 f0 ff ff       	call   8010ba <fd_alloc>
  801fc6:	89 c3                	mov    %eax,%ebx
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	0f 88 db 00 00 00    	js     8020ae <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd3:	83 ec 04             	sub    $0x4,%esp
  801fd6:	68 07 04 00 00       	push   $0x407
  801fdb:	ff 75 f0             	pushl  -0x10(%ebp)
  801fde:	6a 00                	push   $0x0
  801fe0:	e8 82 ec ff ff       	call   800c67 <sys_page_alloc>
  801fe5:	89 c3                	mov    %eax,%ebx
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	85 c0                	test   %eax,%eax
  801fec:	0f 88 bc 00 00 00    	js     8020ae <pipe+0x135>
	va = fd2data(fd0);
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ff8:	e8 a2 f0 ff ff       	call   80109f <fd2data>
  801ffd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fff:	83 c4 0c             	add    $0xc,%esp
  802002:	68 07 04 00 00       	push   $0x407
  802007:	50                   	push   %eax
  802008:	6a 00                	push   $0x0
  80200a:	e8 58 ec ff ff       	call   800c67 <sys_page_alloc>
  80200f:	89 c3                	mov    %eax,%ebx
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	85 c0                	test   %eax,%eax
  802016:	0f 88 82 00 00 00    	js     80209e <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201c:	83 ec 0c             	sub    $0xc,%esp
  80201f:	ff 75 f0             	pushl  -0x10(%ebp)
  802022:	e8 78 f0 ff ff       	call   80109f <fd2data>
  802027:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80202e:	50                   	push   %eax
  80202f:	6a 00                	push   $0x0
  802031:	56                   	push   %esi
  802032:	6a 00                	push   $0x0
  802034:	e8 54 ec ff ff       	call   800c8d <sys_page_map>
  802039:	89 c3                	mov    %eax,%ebx
  80203b:	83 c4 20             	add    $0x20,%esp
  80203e:	85 c0                	test   %eax,%eax
  802040:	78 4e                	js     802090 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802042:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802047:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80204a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80204c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80204f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802056:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802059:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80205b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802065:	83 ec 0c             	sub    $0xc,%esp
  802068:	ff 75 f4             	pushl  -0xc(%ebp)
  80206b:	e8 1b f0 ff ff       	call   80108b <fd2num>
  802070:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802073:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802075:	83 c4 04             	add    $0x4,%esp
  802078:	ff 75 f0             	pushl  -0x10(%ebp)
  80207b:	e8 0b f0 ff ff       	call   80108b <fd2num>
  802080:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802083:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	bb 00 00 00 00       	mov    $0x0,%ebx
  80208e:	eb 2e                	jmp    8020be <pipe+0x145>
	sys_page_unmap(0, va);
  802090:	83 ec 08             	sub    $0x8,%esp
  802093:	56                   	push   %esi
  802094:	6a 00                	push   $0x0
  802096:	e8 17 ec ff ff       	call   800cb2 <sys_page_unmap>
  80209b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80209e:	83 ec 08             	sub    $0x8,%esp
  8020a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020a4:	6a 00                	push   $0x0
  8020a6:	e8 07 ec ff ff       	call   800cb2 <sys_page_unmap>
  8020ab:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020ae:	83 ec 08             	sub    $0x8,%esp
  8020b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020b4:	6a 00                	push   $0x0
  8020b6:	e8 f7 eb ff ff       	call   800cb2 <sys_page_unmap>
  8020bb:	83 c4 10             	add    $0x10,%esp
}
  8020be:	89 d8                	mov    %ebx,%eax
  8020c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    

008020c7 <pipeisclosed>:
{
  8020c7:	f3 0f 1e fb          	endbr32 
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d4:	50                   	push   %eax
  8020d5:	ff 75 08             	pushl  0x8(%ebp)
  8020d8:	e8 33 f0 ff ff       	call   801110 <fd_lookup>
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 18                	js     8020fc <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8020e4:	83 ec 0c             	sub    $0xc,%esp
  8020e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ea:	e8 b0 ef ff ff       	call   80109f <fd2data>
  8020ef:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8020f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f4:	e8 1f fd ff ff       	call   801e18 <_pipeisclosed>
  8020f9:	83 c4 10             	add    $0x10,%esp
}
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    

008020fe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020fe:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802102:	b8 00 00 00 00       	mov    $0x0,%eax
  802107:	c3                   	ret    

00802108 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802108:	f3 0f 1e fb          	endbr32 
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802112:	68 b7 2c 80 00       	push   $0x802cb7
  802117:	ff 75 0c             	pushl  0xc(%ebp)
  80211a:	e8 df e6 ff ff       	call   8007fe <strcpy>
	return 0;
}
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <devcons_write>:
{
  802126:	f3 0f 1e fb          	endbr32 
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	57                   	push   %edi
  80212e:	56                   	push   %esi
  80212f:	53                   	push   %ebx
  802130:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802136:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80213b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802141:	3b 75 10             	cmp    0x10(%ebp),%esi
  802144:	73 31                	jae    802177 <devcons_write+0x51>
		m = n - tot;
  802146:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802149:	29 f3                	sub    %esi,%ebx
  80214b:	83 fb 7f             	cmp    $0x7f,%ebx
  80214e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802153:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802156:	83 ec 04             	sub    $0x4,%esp
  802159:	53                   	push   %ebx
  80215a:	89 f0                	mov    %esi,%eax
  80215c:	03 45 0c             	add    0xc(%ebp),%eax
  80215f:	50                   	push   %eax
  802160:	57                   	push   %edi
  802161:	e8 96 e8 ff ff       	call   8009fc <memmove>
		sys_cputs(buf, m);
  802166:	83 c4 08             	add    $0x8,%esp
  802169:	53                   	push   %ebx
  80216a:	57                   	push   %edi
  80216b:	e8 48 ea ff ff       	call   800bb8 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802170:	01 de                	add    %ebx,%esi
  802172:	83 c4 10             	add    $0x10,%esp
  802175:	eb ca                	jmp    802141 <devcons_write+0x1b>
}
  802177:	89 f0                	mov    %esi,%eax
  802179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5e                   	pop    %esi
  80217e:	5f                   	pop    %edi
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    

00802181 <devcons_read>:
{
  802181:	f3 0f 1e fb          	endbr32 
  802185:	55                   	push   %ebp
  802186:	89 e5                	mov    %esp,%ebp
  802188:	83 ec 08             	sub    $0x8,%esp
  80218b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802190:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802194:	74 21                	je     8021b7 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802196:	e8 3f ea ff ff       	call   800bda <sys_cgetc>
  80219b:	85 c0                	test   %eax,%eax
  80219d:	75 07                	jne    8021a6 <devcons_read+0x25>
		sys_yield();
  80219f:	e8 a0 ea ff ff       	call   800c44 <sys_yield>
  8021a4:	eb f0                	jmp    802196 <devcons_read+0x15>
	if (c < 0)
  8021a6:	78 0f                	js     8021b7 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8021a8:	83 f8 04             	cmp    $0x4,%eax
  8021ab:	74 0c                	je     8021b9 <devcons_read+0x38>
	*(char*)vbuf = c;
  8021ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021b0:	88 02                	mov    %al,(%edx)
	return 1;
  8021b2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021b7:	c9                   	leave  
  8021b8:	c3                   	ret    
		return 0;
  8021b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021be:	eb f7                	jmp    8021b7 <devcons_read+0x36>

008021c0 <cputchar>:
{
  8021c0:	f3 0f 1e fb          	endbr32 
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cd:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021d0:	6a 01                	push   $0x1
  8021d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d5:	50                   	push   %eax
  8021d6:	e8 dd e9 ff ff       	call   800bb8 <sys_cputs>
}
  8021db:	83 c4 10             	add    $0x10,%esp
  8021de:	c9                   	leave  
  8021df:	c3                   	ret    

008021e0 <getchar>:
{
  8021e0:	f3 0f 1e fb          	endbr32 
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8021ea:	6a 01                	push   $0x1
  8021ec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ef:	50                   	push   %eax
  8021f0:	6a 00                	push   $0x0
  8021f2:	e8 a1 f1 ff ff       	call   801398 <read>
	if (r < 0)
  8021f7:	83 c4 10             	add    $0x10,%esp
  8021fa:	85 c0                	test   %eax,%eax
  8021fc:	78 06                	js     802204 <getchar+0x24>
	if (r < 1)
  8021fe:	74 06                	je     802206 <getchar+0x26>
	return c;
  802200:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802204:	c9                   	leave  
  802205:	c3                   	ret    
		return -E_EOF;
  802206:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80220b:	eb f7                	jmp    802204 <getchar+0x24>

0080220d <iscons>:
{
  80220d:	f3 0f 1e fb          	endbr32 
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802217:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80221a:	50                   	push   %eax
  80221b:	ff 75 08             	pushl  0x8(%ebp)
  80221e:	e8 ed ee ff ff       	call   801110 <fd_lookup>
  802223:	83 c4 10             	add    $0x10,%esp
  802226:	85 c0                	test   %eax,%eax
  802228:	78 11                	js     80223b <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80222a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222d:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802233:	39 10                	cmp    %edx,(%eax)
  802235:	0f 94 c0             	sete   %al
  802238:	0f b6 c0             	movzbl %al,%eax
}
  80223b:	c9                   	leave  
  80223c:	c3                   	ret    

0080223d <opencons>:
{
  80223d:	f3 0f 1e fb          	endbr32 
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802247:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224a:	50                   	push   %eax
  80224b:	e8 6a ee ff ff       	call   8010ba <fd_alloc>
  802250:	83 c4 10             	add    $0x10,%esp
  802253:	85 c0                	test   %eax,%eax
  802255:	78 3a                	js     802291 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802257:	83 ec 04             	sub    $0x4,%esp
  80225a:	68 07 04 00 00       	push   $0x407
  80225f:	ff 75 f4             	pushl  -0xc(%ebp)
  802262:	6a 00                	push   $0x0
  802264:	e8 fe e9 ff ff       	call   800c67 <sys_page_alloc>
  802269:	83 c4 10             	add    $0x10,%esp
  80226c:	85 c0                	test   %eax,%eax
  80226e:	78 21                	js     802291 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802273:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802279:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80227b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802285:	83 ec 0c             	sub    $0xc,%esp
  802288:	50                   	push   %eax
  802289:	e8 fd ed ff ff       	call   80108b <fd2num>
  80228e:	83 c4 10             	add    $0x10,%esp
}
  802291:	c9                   	leave  
  802292:	c3                   	ret    

00802293 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802293:	f3 0f 1e fb          	endbr32 
  802297:	55                   	push   %ebp
  802298:	89 e5                	mov    %esp,%ebp
  80229a:	56                   	push   %esi
  80229b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80229c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80229f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022a5:	e8 77 e9 ff ff       	call   800c21 <sys_getenvid>
  8022aa:	83 ec 0c             	sub    $0xc,%esp
  8022ad:	ff 75 0c             	pushl  0xc(%ebp)
  8022b0:	ff 75 08             	pushl  0x8(%ebp)
  8022b3:	56                   	push   %esi
  8022b4:	50                   	push   %eax
  8022b5:	68 c4 2c 80 00       	push   $0x802cc4
  8022ba:	e8 35 df ff ff       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022bf:	83 c4 18             	add    $0x18,%esp
  8022c2:	53                   	push   %ebx
  8022c3:	ff 75 10             	pushl  0x10(%ebp)
  8022c6:	e8 d4 de ff ff       	call   80019f <vcprintf>
	cprintf("\n");
  8022cb:	c7 04 24 2f 27 80 00 	movl   $0x80272f,(%esp)
  8022d2:	e8 1d df ff ff       	call   8001f4 <cprintf>
  8022d7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022da:	cc                   	int3   
  8022db:	eb fd                	jmp    8022da <_panic+0x47>

008022dd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022dd:	f3 0f 1e fb          	endbr32 
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022e7:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022ee:	74 0a                	je     8022fa <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f3:	a3 00 70 80 00       	mov    %eax,0x807000

}
  8022f8:	c9                   	leave  
  8022f9:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8022fa:	83 ec 04             	sub    $0x4,%esp
  8022fd:	6a 07                	push   $0x7
  8022ff:	68 00 f0 bf ee       	push   $0xeebff000
  802304:	6a 00                	push   $0x0
  802306:	e8 5c e9 ff ff       	call   800c67 <sys_page_alloc>
  80230b:	83 c4 10             	add    $0x10,%esp
  80230e:	85 c0                	test   %eax,%eax
  802310:	78 2a                	js     80233c <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  802312:	83 ec 08             	sub    $0x8,%esp
  802315:	68 50 23 80 00       	push   $0x802350
  80231a:	6a 00                	push   $0x0
  80231c:	e8 00 ea ff ff       	call   800d21 <sys_env_set_pgfault_upcall>
  802321:	83 c4 10             	add    $0x10,%esp
  802324:	85 c0                	test   %eax,%eax
  802326:	79 c8                	jns    8022f0 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  802328:	83 ec 04             	sub    $0x4,%esp
  80232b:	68 14 2d 80 00       	push   $0x802d14
  802330:	6a 2c                	push   $0x2c
  802332:	68 4a 2d 80 00       	push   $0x802d4a
  802337:	e8 57 ff ff ff       	call   802293 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  80233c:	83 ec 04             	sub    $0x4,%esp
  80233f:	68 e8 2c 80 00       	push   $0x802ce8
  802344:	6a 22                	push   $0x22
  802346:	68 4a 2d 80 00       	push   $0x802d4a
  80234b:	e8 43 ff ff ff       	call   802293 <_panic>

00802350 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802350:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802351:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  802356:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802358:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  80235b:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  80235f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  802364:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  802368:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  80236a:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  80236d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  80236e:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802371:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802372:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  802373:	c3                   	ret    

00802374 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802374:	f3 0f 1e fb          	endbr32 
  802378:	55                   	push   %ebp
  802379:	89 e5                	mov    %esp,%ebp
  80237b:	56                   	push   %esi
  80237c:	53                   	push   %ebx
  80237d:	8b 75 08             	mov    0x8(%ebp),%esi
  802380:	8b 45 0c             	mov    0xc(%ebp),%eax
  802383:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  802386:	85 c0                	test   %eax,%eax
  802388:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80238d:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802390:	83 ec 0c             	sub    $0xc,%esp
  802393:	50                   	push   %eax
  802394:	e8 d4 e9 ff ff       	call   800d6d <sys_ipc_recv>
  802399:	83 c4 10             	add    $0x10,%esp
  80239c:	85 c0                	test   %eax,%eax
  80239e:	75 2b                	jne    8023cb <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  8023a0:	85 f6                	test   %esi,%esi
  8023a2:	74 0a                	je     8023ae <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  8023a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8023a9:	8b 40 74             	mov    0x74(%eax),%eax
  8023ac:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  8023ae:	85 db                	test   %ebx,%ebx
  8023b0:	74 0a                	je     8023bc <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  8023b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8023b7:	8b 40 78             	mov    0x78(%eax),%eax
  8023ba:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8023bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8023c1:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8023cb:	85 f6                	test   %esi,%esi
  8023cd:	74 06                	je     8023d5 <ipc_recv+0x61>
  8023cf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8023d5:	85 db                	test   %ebx,%ebx
  8023d7:	74 eb                	je     8023c4 <ipc_recv+0x50>
  8023d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023df:	eb e3                	jmp    8023c4 <ipc_recv+0x50>

008023e1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023e1:	f3 0f 1e fb          	endbr32 
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	57                   	push   %edi
  8023e9:	56                   	push   %esi
  8023ea:	53                   	push   %ebx
  8023eb:	83 ec 0c             	sub    $0xc,%esp
  8023ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8023f7:	85 db                	test   %ebx,%ebx
  8023f9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023fe:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802401:	ff 75 14             	pushl  0x14(%ebp)
  802404:	53                   	push   %ebx
  802405:	56                   	push   %esi
  802406:	57                   	push   %edi
  802407:	e8 3a e9 ff ff       	call   800d46 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802412:	75 07                	jne    80241b <ipc_send+0x3a>
			sys_yield();
  802414:	e8 2b e8 ff ff       	call   800c44 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  802419:	eb e6                	jmp    802401 <ipc_send+0x20>
		}
		else if (ret == 0)
  80241b:	85 c0                	test   %eax,%eax
  80241d:	75 08                	jne    802427 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80241f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802422:	5b                   	pop    %ebx
  802423:	5e                   	pop    %esi
  802424:	5f                   	pop    %edi
  802425:	5d                   	pop    %ebp
  802426:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  802427:	50                   	push   %eax
  802428:	68 58 2d 80 00       	push   $0x802d58
  80242d:	6a 48                	push   $0x48
  80242f:	68 66 2d 80 00       	push   $0x802d66
  802434:	e8 5a fe ff ff       	call   802293 <_panic>

00802439 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802439:	f3 0f 1e fb          	endbr32 
  80243d:	55                   	push   %ebp
  80243e:	89 e5                	mov    %esp,%ebp
  802440:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802443:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802448:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80244b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802451:	8b 52 50             	mov    0x50(%edx),%edx
  802454:	39 ca                	cmp    %ecx,%edx
  802456:	74 11                	je     802469 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802458:	83 c0 01             	add    $0x1,%eax
  80245b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802460:	75 e6                	jne    802448 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802462:	b8 00 00 00 00       	mov    $0x0,%eax
  802467:	eb 0b                	jmp    802474 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802469:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80246c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802471:	8b 40 48             	mov    0x48(%eax),%eax
}
  802474:	5d                   	pop    %ebp
  802475:	c3                   	ret    

00802476 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802476:	f3 0f 1e fb          	endbr32 
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802480:	89 c2                	mov    %eax,%edx
  802482:	c1 ea 16             	shr    $0x16,%edx
  802485:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80248c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802491:	f6 c1 01             	test   $0x1,%cl
  802494:	74 1c                	je     8024b2 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802496:	c1 e8 0c             	shr    $0xc,%eax
  802499:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024a0:	a8 01                	test   $0x1,%al
  8024a2:	74 0e                	je     8024b2 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024a4:	c1 e8 0c             	shr    $0xc,%eax
  8024a7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024ae:	ef 
  8024af:	0f b7 d2             	movzwl %dx,%edx
}
  8024b2:	89 d0                	mov    %edx,%eax
  8024b4:	5d                   	pop    %ebp
  8024b5:	c3                   	ret    
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	66 90                	xchg   %ax,%ax
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__udivdi3>:
  8024c0:	f3 0f 1e fb          	endbr32 
  8024c4:	55                   	push   %ebp
  8024c5:	57                   	push   %edi
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
  8024c8:	83 ec 1c             	sub    $0x1c,%esp
  8024cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8024cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024db:	85 d2                	test   %edx,%edx
  8024dd:	75 19                	jne    8024f8 <__udivdi3+0x38>
  8024df:	39 f3                	cmp    %esi,%ebx
  8024e1:	76 4d                	jbe    802530 <__udivdi3+0x70>
  8024e3:	31 ff                	xor    %edi,%edi
  8024e5:	89 e8                	mov    %ebp,%eax
  8024e7:	89 f2                	mov    %esi,%edx
  8024e9:	f7 f3                	div    %ebx
  8024eb:	89 fa                	mov    %edi,%edx
  8024ed:	83 c4 1c             	add    $0x1c,%esp
  8024f0:	5b                   	pop    %ebx
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
  8024f5:	8d 76 00             	lea    0x0(%esi),%esi
  8024f8:	39 f2                	cmp    %esi,%edx
  8024fa:	76 14                	jbe    802510 <__udivdi3+0x50>
  8024fc:	31 ff                	xor    %edi,%edi
  8024fe:	31 c0                	xor    %eax,%eax
  802500:	89 fa                	mov    %edi,%edx
  802502:	83 c4 1c             	add    $0x1c,%esp
  802505:	5b                   	pop    %ebx
  802506:	5e                   	pop    %esi
  802507:	5f                   	pop    %edi
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    
  80250a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802510:	0f bd fa             	bsr    %edx,%edi
  802513:	83 f7 1f             	xor    $0x1f,%edi
  802516:	75 48                	jne    802560 <__udivdi3+0xa0>
  802518:	39 f2                	cmp    %esi,%edx
  80251a:	72 06                	jb     802522 <__udivdi3+0x62>
  80251c:	31 c0                	xor    %eax,%eax
  80251e:	39 eb                	cmp    %ebp,%ebx
  802520:	77 de                	ja     802500 <__udivdi3+0x40>
  802522:	b8 01 00 00 00       	mov    $0x1,%eax
  802527:	eb d7                	jmp    802500 <__udivdi3+0x40>
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 d9                	mov    %ebx,%ecx
  802532:	85 db                	test   %ebx,%ebx
  802534:	75 0b                	jne    802541 <__udivdi3+0x81>
  802536:	b8 01 00 00 00       	mov    $0x1,%eax
  80253b:	31 d2                	xor    %edx,%edx
  80253d:	f7 f3                	div    %ebx
  80253f:	89 c1                	mov    %eax,%ecx
  802541:	31 d2                	xor    %edx,%edx
  802543:	89 f0                	mov    %esi,%eax
  802545:	f7 f1                	div    %ecx
  802547:	89 c6                	mov    %eax,%esi
  802549:	89 e8                	mov    %ebp,%eax
  80254b:	89 f7                	mov    %esi,%edi
  80254d:	f7 f1                	div    %ecx
  80254f:	89 fa                	mov    %edi,%edx
  802551:	83 c4 1c             	add    $0x1c,%esp
  802554:	5b                   	pop    %ebx
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	89 f9                	mov    %edi,%ecx
  802562:	b8 20 00 00 00       	mov    $0x20,%eax
  802567:	29 f8                	sub    %edi,%eax
  802569:	d3 e2                	shl    %cl,%edx
  80256b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80256f:	89 c1                	mov    %eax,%ecx
  802571:	89 da                	mov    %ebx,%edx
  802573:	d3 ea                	shr    %cl,%edx
  802575:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802579:	09 d1                	or     %edx,%ecx
  80257b:	89 f2                	mov    %esi,%edx
  80257d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802581:	89 f9                	mov    %edi,%ecx
  802583:	d3 e3                	shl    %cl,%ebx
  802585:	89 c1                	mov    %eax,%ecx
  802587:	d3 ea                	shr    %cl,%edx
  802589:	89 f9                	mov    %edi,%ecx
  80258b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80258f:	89 eb                	mov    %ebp,%ebx
  802591:	d3 e6                	shl    %cl,%esi
  802593:	89 c1                	mov    %eax,%ecx
  802595:	d3 eb                	shr    %cl,%ebx
  802597:	09 de                	or     %ebx,%esi
  802599:	89 f0                	mov    %esi,%eax
  80259b:	f7 74 24 08          	divl   0x8(%esp)
  80259f:	89 d6                	mov    %edx,%esi
  8025a1:	89 c3                	mov    %eax,%ebx
  8025a3:	f7 64 24 0c          	mull   0xc(%esp)
  8025a7:	39 d6                	cmp    %edx,%esi
  8025a9:	72 15                	jb     8025c0 <__udivdi3+0x100>
  8025ab:	89 f9                	mov    %edi,%ecx
  8025ad:	d3 e5                	shl    %cl,%ebp
  8025af:	39 c5                	cmp    %eax,%ebp
  8025b1:	73 04                	jae    8025b7 <__udivdi3+0xf7>
  8025b3:	39 d6                	cmp    %edx,%esi
  8025b5:	74 09                	je     8025c0 <__udivdi3+0x100>
  8025b7:	89 d8                	mov    %ebx,%eax
  8025b9:	31 ff                	xor    %edi,%edi
  8025bb:	e9 40 ff ff ff       	jmp    802500 <__udivdi3+0x40>
  8025c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025c3:	31 ff                	xor    %edi,%edi
  8025c5:	e9 36 ff ff ff       	jmp    802500 <__udivdi3+0x40>
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__umoddi3>:
  8025d0:	f3 0f 1e fb          	endbr32 
  8025d4:	55                   	push   %ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
  8025d8:	83 ec 1c             	sub    $0x1c,%esp
  8025db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025eb:	85 c0                	test   %eax,%eax
  8025ed:	75 19                	jne    802608 <__umoddi3+0x38>
  8025ef:	39 df                	cmp    %ebx,%edi
  8025f1:	76 5d                	jbe    802650 <__umoddi3+0x80>
  8025f3:	89 f0                	mov    %esi,%eax
  8025f5:	89 da                	mov    %ebx,%edx
  8025f7:	f7 f7                	div    %edi
  8025f9:	89 d0                	mov    %edx,%eax
  8025fb:	31 d2                	xor    %edx,%edx
  8025fd:	83 c4 1c             	add    $0x1c,%esp
  802600:	5b                   	pop    %ebx
  802601:	5e                   	pop    %esi
  802602:	5f                   	pop    %edi
  802603:	5d                   	pop    %ebp
  802604:	c3                   	ret    
  802605:	8d 76 00             	lea    0x0(%esi),%esi
  802608:	89 f2                	mov    %esi,%edx
  80260a:	39 d8                	cmp    %ebx,%eax
  80260c:	76 12                	jbe    802620 <__umoddi3+0x50>
  80260e:	89 f0                	mov    %esi,%eax
  802610:	89 da                	mov    %ebx,%edx
  802612:	83 c4 1c             	add    $0x1c,%esp
  802615:	5b                   	pop    %ebx
  802616:	5e                   	pop    %esi
  802617:	5f                   	pop    %edi
  802618:	5d                   	pop    %ebp
  802619:	c3                   	ret    
  80261a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802620:	0f bd e8             	bsr    %eax,%ebp
  802623:	83 f5 1f             	xor    $0x1f,%ebp
  802626:	75 50                	jne    802678 <__umoddi3+0xa8>
  802628:	39 d8                	cmp    %ebx,%eax
  80262a:	0f 82 e0 00 00 00    	jb     802710 <__umoddi3+0x140>
  802630:	89 d9                	mov    %ebx,%ecx
  802632:	39 f7                	cmp    %esi,%edi
  802634:	0f 86 d6 00 00 00    	jbe    802710 <__umoddi3+0x140>
  80263a:	89 d0                	mov    %edx,%eax
  80263c:	89 ca                	mov    %ecx,%edx
  80263e:	83 c4 1c             	add    $0x1c,%esp
  802641:	5b                   	pop    %ebx
  802642:	5e                   	pop    %esi
  802643:	5f                   	pop    %edi
  802644:	5d                   	pop    %ebp
  802645:	c3                   	ret    
  802646:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
  802650:	89 fd                	mov    %edi,%ebp
  802652:	85 ff                	test   %edi,%edi
  802654:	75 0b                	jne    802661 <__umoddi3+0x91>
  802656:	b8 01 00 00 00       	mov    $0x1,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	f7 f7                	div    %edi
  80265f:	89 c5                	mov    %eax,%ebp
  802661:	89 d8                	mov    %ebx,%eax
  802663:	31 d2                	xor    %edx,%edx
  802665:	f7 f5                	div    %ebp
  802667:	89 f0                	mov    %esi,%eax
  802669:	f7 f5                	div    %ebp
  80266b:	89 d0                	mov    %edx,%eax
  80266d:	31 d2                	xor    %edx,%edx
  80266f:	eb 8c                	jmp    8025fd <__umoddi3+0x2d>
  802671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802678:	89 e9                	mov    %ebp,%ecx
  80267a:	ba 20 00 00 00       	mov    $0x20,%edx
  80267f:	29 ea                	sub    %ebp,%edx
  802681:	d3 e0                	shl    %cl,%eax
  802683:	89 44 24 08          	mov    %eax,0x8(%esp)
  802687:	89 d1                	mov    %edx,%ecx
  802689:	89 f8                	mov    %edi,%eax
  80268b:	d3 e8                	shr    %cl,%eax
  80268d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802691:	89 54 24 04          	mov    %edx,0x4(%esp)
  802695:	8b 54 24 04          	mov    0x4(%esp),%edx
  802699:	09 c1                	or     %eax,%ecx
  80269b:	89 d8                	mov    %ebx,%eax
  80269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a1:	89 e9                	mov    %ebp,%ecx
  8026a3:	d3 e7                	shl    %cl,%edi
  8026a5:	89 d1                	mov    %edx,%ecx
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026af:	d3 e3                	shl    %cl,%ebx
  8026b1:	89 c7                	mov    %eax,%edi
  8026b3:	89 d1                	mov    %edx,%ecx
  8026b5:	89 f0                	mov    %esi,%eax
  8026b7:	d3 e8                	shr    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	89 fa                	mov    %edi,%edx
  8026bd:	d3 e6                	shl    %cl,%esi
  8026bf:	09 d8                	or     %ebx,%eax
  8026c1:	f7 74 24 08          	divl   0x8(%esp)
  8026c5:	89 d1                	mov    %edx,%ecx
  8026c7:	89 f3                	mov    %esi,%ebx
  8026c9:	f7 64 24 0c          	mull   0xc(%esp)
  8026cd:	89 c6                	mov    %eax,%esi
  8026cf:	89 d7                	mov    %edx,%edi
  8026d1:	39 d1                	cmp    %edx,%ecx
  8026d3:	72 06                	jb     8026db <__umoddi3+0x10b>
  8026d5:	75 10                	jne    8026e7 <__umoddi3+0x117>
  8026d7:	39 c3                	cmp    %eax,%ebx
  8026d9:	73 0c                	jae    8026e7 <__umoddi3+0x117>
  8026db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8026df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026e3:	89 d7                	mov    %edx,%edi
  8026e5:	89 c6                	mov    %eax,%esi
  8026e7:	89 ca                	mov    %ecx,%edx
  8026e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026ee:	29 f3                	sub    %esi,%ebx
  8026f0:	19 fa                	sbb    %edi,%edx
  8026f2:	89 d0                	mov    %edx,%eax
  8026f4:	d3 e0                	shl    %cl,%eax
  8026f6:	89 e9                	mov    %ebp,%ecx
  8026f8:	d3 eb                	shr    %cl,%ebx
  8026fa:	d3 ea                	shr    %cl,%edx
  8026fc:	09 d8                	or     %ebx,%eax
  8026fe:	83 c4 1c             	add    $0x1c,%esp
  802701:	5b                   	pop    %ebx
  802702:	5e                   	pop    %esi
  802703:	5f                   	pop    %edi
  802704:	5d                   	pop    %ebp
  802705:	c3                   	ret    
  802706:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80270d:	8d 76 00             	lea    0x0(%esi),%esi
  802710:	29 fe                	sub    %edi,%esi
  802712:	19 c3                	sbb    %eax,%ebx
  802714:	89 f2                	mov    %esi,%edx
  802716:	89 d9                	mov    %ebx,%ecx
  802718:	e9 1d ff ff ff       	jmp    80263a <__umoddi3+0x6a>
