
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 e8 00 00 00       	call   800119 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  80003d:	68 a0 26 80 00       	push   $0x8026a0
  800042:	e8 d7 01 00 00       	call   80021e <cprintf>
	exit();
  800047:	e8 17 01 00 00       	call   800163 <exit>
}
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:

void
umain(int argc, char **argv)
{
  800051:	f3 0f 1e fb          	endbr32 
  800055:	55                   	push   %ebp
  800056:	89 e5                	mov    %esp,%ebp
  800058:	57                   	push   %edi
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800061:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800067:	50                   	push   %eax
  800068:	ff 75 0c             	pushl  0xc(%ebp)
  80006b:	8d 45 08             	lea    0x8(%ebp),%eax
  80006e:	50                   	push   %eax
  80006f:	e8 b4 0d 00 00       	call   800e28 <argstart>
	while ((i = argnext(&args)) >= 0)
  800074:	83 c4 10             	add    $0x10,%esp
	int i, usefprint = 0;
  800077:	be 00 00 00 00       	mov    $0x0,%esi
	while ((i = argnext(&args)) >= 0)
  80007c:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
		if (i == '1')
			usefprint = 1;
  800082:	bf 01 00 00 00       	mov    $0x1,%edi
	while ((i = argnext(&args)) >= 0)
  800087:	83 ec 0c             	sub    $0xc,%esp
  80008a:	53                   	push   %ebx
  80008b:	e8 cc 0d 00 00       	call   800e5c <argnext>
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	85 c0                	test   %eax,%eax
  800095:	78 10                	js     8000a7 <umain+0x56>
		if (i == '1')
  800097:	83 f8 31             	cmp    $0x31,%eax
  80009a:	75 04                	jne    8000a0 <umain+0x4f>
			usefprint = 1;
  80009c:	89 fe                	mov    %edi,%esi
  80009e:	eb e7                	jmp    800087 <umain+0x36>
		else
			usage();
  8000a0:	e8 8e ff ff ff       	call   800033 <usage>
  8000a5:	eb e0                	jmp    800087 <umain+0x36>

	for (i = 0; i < 32; i++)
  8000a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fstat(i, &st) >= 0) {
  8000ac:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000b2:	eb 26                	jmp    8000da <umain+0x89>
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000ba:	ff 70 04             	pushl  0x4(%eax)
  8000bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c3:	57                   	push   %edi
  8000c4:	53                   	push   %ebx
  8000c5:	68 b4 26 80 00       	push   $0x8026b4
  8000ca:	e8 4f 01 00 00       	call   80021e <cprintf>
  8000cf:	83 c4 20             	add    $0x20,%esp
	for (i = 0; i < 32; i++)
  8000d2:	83 c3 01             	add    $0x1,%ebx
  8000d5:	83 fb 20             	cmp    $0x20,%ebx
  8000d8:	74 37                	je     800111 <umain+0xc0>
		if (fstat(i, &st) >= 0) {
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	57                   	push   %edi
  8000de:	53                   	push   %ebx
  8000df:	e8 bc 13 00 00       	call   8014a0 <fstat>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	78 e7                	js     8000d2 <umain+0x81>
			if (usefprint)
  8000eb:	85 f6                	test   %esi,%esi
  8000ed:	74 c5                	je     8000b4 <umain+0x63>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000f5:	ff 70 04             	pushl  0x4(%eax)
  8000f8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000fe:	57                   	push   %edi
  8000ff:	53                   	push   %ebx
  800100:	68 b4 26 80 00       	push   $0x8026b4
  800105:	6a 01                	push   $0x1
  800107:	e8 bf 17 00 00       	call   8018cb <fprintf>
  80010c:	83 c4 20             	add    $0x20,%esp
  80010f:	eb c1                	jmp    8000d2 <umain+0x81>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800119:	f3 0f 1e fb          	endbr32 
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
  800122:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800125:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800128:	e8 1e 0b 00 00       	call   800c4b <sys_getenvid>
  80012d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800132:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800135:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80013a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013f:	85 db                	test   %ebx,%ebx
  800141:	7e 07                	jle    80014a <libmain+0x31>
		binaryname = argv[0];
  800143:	8b 06                	mov    (%esi),%eax
  800145:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80014a:	83 ec 08             	sub    $0x8,%esp
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
  80014f:	e8 fd fe ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  800154:	e8 0a 00 00 00       	call   800163 <exit>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800163:	f3 0f 1e fb          	endbr32 
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  80016d:	e8 09 10 00 00       	call   80117b <close_all>
	sys_env_destroy(0);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	6a 00                	push   $0x0
  800177:	e8 ab 0a 00 00       	call   800c27 <sys_env_destroy>
}
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800181:	f3 0f 1e fb          	endbr32 
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	53                   	push   %ebx
  800189:	83 ec 04             	sub    $0x4,%esp
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018f:	8b 13                	mov    (%ebx),%edx
  800191:	8d 42 01             	lea    0x1(%edx),%eax
  800194:	89 03                	mov    %eax,(%ebx)
  800196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800199:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a2:	74 09                	je     8001ad <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ad:	83 ec 08             	sub    $0x8,%esp
  8001b0:	68 ff 00 00 00       	push   $0xff
  8001b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b8:	50                   	push   %eax
  8001b9:	e8 24 0a 00 00       	call   800be2 <sys_cputs>
		b->idx = 0;
  8001be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c4:	83 c4 10             	add    $0x10,%esp
  8001c7:	eb db                	jmp    8001a4 <putch+0x23>

008001c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c9:	f3 0f 1e fb          	endbr32 
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	pushl  0xc(%ebp)
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 81 01 80 00       	push   $0x800181
  8001fc:	e8 20 01 00 00       	call   800321 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 cc 09 00 00       	call   800be2 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	f3 0f 1e fb          	endbr32 
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800228:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022b:	50                   	push   %eax
  80022c:	ff 75 08             	pushl  0x8(%ebp)
  80022f:	e8 95 ff ff ff       	call   8001c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	57                   	push   %edi
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 1c             	sub    $0x1c,%esp
  80023f:	89 c7                	mov    %eax,%edi
  800241:	89 d6                	mov    %edx,%esi
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 d1                	mov    %edx,%ecx
  80024b:	89 c2                	mov    %eax,%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800253:	8b 45 10             	mov    0x10(%ebp),%eax
  800256:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800259:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800263:	39 c2                	cmp    %eax,%edx
  800265:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800268:	72 3e                	jb     8002a8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	83 eb 01             	sub    $0x1,%ebx
  800273:	53                   	push   %ebx
  800274:	50                   	push   %eax
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027b:	ff 75 e0             	pushl  -0x20(%ebp)
  80027e:	ff 75 dc             	pushl  -0x24(%ebp)
  800281:	ff 75 d8             	pushl  -0x28(%ebp)
  800284:	e8 b7 21 00 00       	call   802440 <__udivdi3>
  800289:	83 c4 18             	add    $0x18,%esp
  80028c:	52                   	push   %edx
  80028d:	50                   	push   %eax
  80028e:	89 f2                	mov    %esi,%edx
  800290:	89 f8                	mov    %edi,%eax
  800292:	e8 9f ff ff ff       	call   800236 <printnum>
  800297:	83 c4 20             	add    $0x20,%esp
  80029a:	eb 13                	jmp    8002af <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	56                   	push   %esi
  8002a0:	ff 75 18             	pushl  0x18(%ebp)
  8002a3:	ff d7                	call   *%edi
  8002a5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a8:	83 eb 01             	sub    $0x1,%ebx
  8002ab:	85 db                	test   %ebx,%ebx
  8002ad:	7f ed                	jg     80029c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	83 ec 04             	sub    $0x4,%esp
  8002b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c2:	e8 89 22 00 00       	call   802550 <__umoddi3>
  8002c7:	83 c4 14             	add    $0x14,%esp
  8002ca:	0f be 80 e6 26 80 00 	movsbl 0x8026e6(%eax),%eax
  8002d1:	50                   	push   %eax
  8002d2:	ff d7                	call   *%edi
}
  8002d4:	83 c4 10             	add    $0x10,%esp
  8002d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002df:	f3 0f 1e fb          	endbr32 
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f2:	73 0a                	jae    8002fe <sprintputch+0x1f>
		*b->buf++ = ch;
  8002f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fc:	88 02                	mov    %al,(%edx)
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <printfmt>:
{
  800300:	f3 0f 1e fb          	endbr32 
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030d:	50                   	push   %eax
  80030e:	ff 75 10             	pushl  0x10(%ebp)
  800311:	ff 75 0c             	pushl  0xc(%ebp)
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	e8 05 00 00 00       	call   800321 <vprintfmt>
}
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <vprintfmt>:
{
  800321:	f3 0f 1e fb          	endbr32 
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 3c             	sub    $0x3c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	e9 8e 03 00 00       	jmp    8006ca <vprintfmt+0x3a9>
		padc = ' ';
  80033c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800340:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800347:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80034e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8d 47 01             	lea    0x1(%edi),%eax
  80035d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800360:	0f b6 17             	movzbl (%edi),%edx
  800363:	8d 42 dd             	lea    -0x23(%edx),%eax
  800366:	3c 55                	cmp    $0x55,%al
  800368:	0f 87 df 03 00 00    	ja     80074d <vprintfmt+0x42c>
  80036e:	0f b6 c0             	movzbl %al,%eax
  800371:	3e ff 24 85 20 28 80 	notrack jmp *0x802820(,%eax,4)
  800378:	00 
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80037c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800380:	eb d8                	jmp    80035a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800385:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800389:	eb cf                	jmp    80035a <vprintfmt+0x39>
  80038b:	0f b6 d2             	movzbl %dl,%edx
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
  800396:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800399:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a6:	83 f9 09             	cmp    $0x9,%ecx
  8003a9:	77 55                	ja     800400 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  8003ae:	eb e9                	jmp    800399 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 40 04             	lea    0x4(%eax),%eax
  8003be:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c8:	79 90                	jns    80035a <vprintfmt+0x39>
				width = precision, precision = -1;
  8003ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d7:	eb 81                	jmp    80035a <vprintfmt+0x39>
  8003d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e3:	0f 49 d0             	cmovns %eax,%edx
  8003e6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ec:	e9 69 ff ff ff       	jmp    80035a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003fb:	e9 5a ff ff ff       	jmp    80035a <vprintfmt+0x39>
  800400:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800403:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800406:	eb bc                	jmp    8003c4 <vprintfmt+0xa3>
			lflag++;
  800408:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040e:	e9 47 ff ff ff       	jmp    80035a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 78 04             	lea    0x4(%eax),%edi
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	53                   	push   %ebx
  80041d:	ff 30                	pushl  (%eax)
  80041f:	ff d6                	call   *%esi
			break;
  800421:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800424:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800427:	e9 9b 02 00 00       	jmp    8006c7 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8d 78 04             	lea    0x4(%eax),%edi
  800432:	8b 00                	mov    (%eax),%eax
  800434:	99                   	cltd   
  800435:	31 d0                	xor    %edx,%eax
  800437:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800439:	83 f8 0f             	cmp    $0xf,%eax
  80043c:	7f 23                	jg     800461 <vprintfmt+0x140>
  80043e:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  800445:	85 d2                	test   %edx,%edx
  800447:	74 18                	je     800461 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800449:	52                   	push   %edx
  80044a:	68 89 2a 80 00       	push   $0x802a89
  80044f:	53                   	push   %ebx
  800450:	56                   	push   %esi
  800451:	e8 aa fe ff ff       	call   800300 <printfmt>
  800456:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800459:	89 7d 14             	mov    %edi,0x14(%ebp)
  80045c:	e9 66 02 00 00       	jmp    8006c7 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800461:	50                   	push   %eax
  800462:	68 fe 26 80 00       	push   $0x8026fe
  800467:	53                   	push   %ebx
  800468:	56                   	push   %esi
  800469:	e8 92 fe ff ff       	call   800300 <printfmt>
  80046e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800471:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800474:	e9 4e 02 00 00       	jmp    8006c7 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	83 c0 04             	add    $0x4,%eax
  80047f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800487:	85 d2                	test   %edx,%edx
  800489:	b8 f7 26 80 00       	mov    $0x8026f7,%eax
  80048e:	0f 45 c2             	cmovne %edx,%eax
  800491:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800494:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800498:	7e 06                	jle    8004a0 <vprintfmt+0x17f>
  80049a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80049e:	75 0d                	jne    8004ad <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a3:	89 c7                	mov    %eax,%edi
  8004a5:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ab:	eb 55                	jmp    800502 <vprintfmt+0x1e1>
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b3:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b6:	e8 46 03 00 00       	call   800801 <strnlen>
  8004bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004c8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	85 ff                	test   %edi,%edi
  8004d1:	7e 11                	jle    8004e4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	83 ef 01             	sub    $0x1,%edi
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb eb                	jmp    8004cf <vprintfmt+0x1ae>
  8004e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	0f 49 c2             	cmovns %edx,%eax
  8004f1:	29 c2                	sub    %eax,%edx
  8004f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f6:	eb a8                	jmp    8004a0 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	53                   	push   %ebx
  8004fc:	52                   	push   %edx
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800505:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800507:	83 c7 01             	add    $0x1,%edi
  80050a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050e:	0f be d0             	movsbl %al,%edx
  800511:	85 d2                	test   %edx,%edx
  800513:	74 4b                	je     800560 <vprintfmt+0x23f>
  800515:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800519:	78 06                	js     800521 <vprintfmt+0x200>
  80051b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051f:	78 1e                	js     80053f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  800521:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800525:	74 d1                	je     8004f8 <vprintfmt+0x1d7>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 c6                	jbe    8004f8 <vprintfmt+0x1d7>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	6a 3f                	push   $0x3f
  800538:	ff d6                	call   *%esi
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	eb c3                	jmp    800502 <vprintfmt+0x1e1>
  80053f:	89 cf                	mov    %ecx,%edi
  800541:	eb 0e                	jmp    800551 <vprintfmt+0x230>
				putch(' ', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	53                   	push   %ebx
  800547:	6a 20                	push   $0x20
  800549:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054b:	83 ef 01             	sub    $0x1,%edi
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 ff                	test   %edi,%edi
  800553:	7f ee                	jg     800543 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800555:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	e9 67 01 00 00       	jmp    8006c7 <vprintfmt+0x3a6>
  800560:	89 cf                	mov    %ecx,%edi
  800562:	eb ed                	jmp    800551 <vprintfmt+0x230>
	if (lflag >= 2)
  800564:	83 f9 01             	cmp    $0x1,%ecx
  800567:	7f 1b                	jg     800584 <vprintfmt+0x263>
	else if (lflag)
  800569:	85 c9                	test   %ecx,%ecx
  80056b:	74 63                	je     8005d0 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	99                   	cltd   
  800576:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	eb 17                	jmp    80059b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 50 04             	mov    0x4(%eax),%edx
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 08             	lea    0x8(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80059b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005a6:	85 c9                	test   %ecx,%ecx
  8005a8:	0f 89 ff 00 00 00    	jns    8006ad <vprintfmt+0x38c>
				putch('-', putdat);
  8005ae:	83 ec 08             	sub    $0x8,%esp
  8005b1:	53                   	push   %ebx
  8005b2:	6a 2d                	push   $0x2d
  8005b4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bc:	f7 da                	neg    %edx
  8005be:	83 d1 00             	adc    $0x0,%ecx
  8005c1:	f7 d9                	neg    %ecx
  8005c3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cb:	e9 dd 00 00 00       	jmp    8006ad <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	99                   	cltd   
  8005d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e5:	eb b4                	jmp    80059b <vprintfmt+0x27a>
	if (lflag >= 2)
  8005e7:	83 f9 01             	cmp    $0x1,%ecx
  8005ea:	7f 1e                	jg     80060a <vprintfmt+0x2e9>
	else if (lflag)
  8005ec:	85 c9                	test   %ecx,%ecx
  8005ee:	74 32                	je     800622 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8b 10                	mov    (%eax),%edx
  8005f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fa:	8d 40 04             	lea    0x4(%eax),%eax
  8005fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800600:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800605:	e9 a3 00 00 00       	jmp    8006ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8b 10                	mov    (%eax),%edx
  80060f:	8b 48 04             	mov    0x4(%eax),%ecx
  800612:	8d 40 08             	lea    0x8(%eax),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800618:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80061d:	e9 8b 00 00 00       	jmp    8006ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062c:	8d 40 04             	lea    0x4(%eax),%eax
  80062f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800637:	eb 74                	jmp    8006ad <vprintfmt+0x38c>
	if (lflag >= 2)
  800639:	83 f9 01             	cmp    $0x1,%ecx
  80063c:	7f 1b                	jg     800659 <vprintfmt+0x338>
	else if (lflag)
  80063e:	85 c9                	test   %ecx,%ecx
  800640:	74 2c                	je     80066e <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800652:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800657:	eb 54                	jmp    8006ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	8b 48 04             	mov    0x4(%eax),%ecx
  800661:	8d 40 08             	lea    0x8(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800667:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80066c:	eb 3f                	jmp    8006ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 10                	mov    (%eax),%edx
  800673:	b9 00 00 00 00       	mov    $0x0,%ecx
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800683:	eb 28                	jmp    8006ad <vprintfmt+0x38c>
			putch('0', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 30                	push   $0x30
  80068b:	ff d6                	call   *%esi
			putch('x', putdat);
  80068d:	83 c4 08             	add    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 78                	push   $0x78
  800693:	ff d6                	call   *%esi
			num = (unsigned long long)
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80069f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006ad:	83 ec 0c             	sub    $0xc,%esp
  8006b0:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006b4:	57                   	push   %edi
  8006b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b8:	50                   	push   %eax
  8006b9:	51                   	push   %ecx
  8006ba:	52                   	push   %edx
  8006bb:	89 da                	mov    %ebx,%edx
  8006bd:	89 f0                	mov    %esi,%eax
  8006bf:	e8 72 fb ff ff       	call   800236 <printnum>
			break;
  8006c4:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  8006ca:	83 c7 01             	add    $0x1,%edi
  8006cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d1:	83 f8 25             	cmp    $0x25,%eax
  8006d4:	0f 84 62 fc ff ff    	je     80033c <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	0f 84 8b 00 00 00    	je     80076d <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	50                   	push   %eax
  8006e7:	ff d6                	call   *%esi
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb dc                	jmp    8006ca <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006ee:	83 f9 01             	cmp    $0x1,%ecx
  8006f1:	7f 1b                	jg     80070e <vprintfmt+0x3ed>
	else if (lflag)
  8006f3:	85 c9                	test   %ecx,%ecx
  8006f5:	74 2c                	je     800723 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800701:	8d 40 04             	lea    0x4(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80070c:	eb 9f                	jmp    8006ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8b 10                	mov    (%eax),%edx
  800713:	8b 48 04             	mov    0x4(%eax),%ecx
  800716:	8d 40 08             	lea    0x8(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800721:	eb 8a                	jmp    8006ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8b 10                	mov    (%eax),%edx
  800728:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072d:	8d 40 04             	lea    0x4(%eax),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800733:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800738:	e9 70 ff ff ff       	jmp    8006ad <vprintfmt+0x38c>
			putch(ch, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	53                   	push   %ebx
  800741:	6a 25                	push   $0x25
  800743:	ff d6                	call   *%esi
			break;
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	e9 7a ff ff ff       	jmp    8006c7 <vprintfmt+0x3a6>
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	89 f8                	mov    %edi,%eax
  80075a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075e:	74 05                	je     800765 <vprintfmt+0x444>
  800760:	83 e8 01             	sub    $0x1,%eax
  800763:	eb f5                	jmp    80075a <vprintfmt+0x439>
  800765:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800768:	e9 5a ff ff ff       	jmp    8006c7 <vprintfmt+0x3a6>
}
  80076d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800770:	5b                   	pop    %ebx
  800771:	5e                   	pop    %esi
  800772:	5f                   	pop    %edi
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800775:	f3 0f 1e fb          	endbr32 
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	83 ec 18             	sub    $0x18,%esp
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800785:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800788:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800796:	85 c0                	test   %eax,%eax
  800798:	74 26                	je     8007c0 <vsnprintf+0x4b>
  80079a:	85 d2                	test   %edx,%edx
  80079c:	7e 22                	jle    8007c0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079e:	ff 75 14             	pushl  0x14(%ebp)
  8007a1:	ff 75 10             	pushl  0x10(%ebp)
  8007a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	68 df 02 80 00       	push   $0x8002df
  8007ad:	e8 6f fb ff ff       	call   800321 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bb:	83 c4 10             	add    $0x10,%esp
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    
		return -E_INVAL;
  8007c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c5:	eb f7                	jmp    8007be <vsnprintf+0x49>

008007c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c7:	f3 0f 1e fb          	endbr32 
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  8007d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d4:	50                   	push   %eax
  8007d5:	ff 75 10             	pushl  0x10(%ebp)
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	ff 75 08             	pushl  0x8(%ebp)
  8007de:	e8 92 ff ff ff       	call   800775 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e5:	f3 0f 1e fb          	endbr32 
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f8:	74 05                	je     8007ff <strlen+0x1a>
		n++;
  8007fa:	83 c0 01             	add    $0x1,%eax
  8007fd:	eb f5                	jmp    8007f4 <strlen+0xf>
	return n;
}
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800801:	f3 0f 1e fb          	endbr32 
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	39 d0                	cmp    %edx,%eax
  800815:	74 0d                	je     800824 <strnlen+0x23>
  800817:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081b:	74 05                	je     800822 <strnlen+0x21>
		n++;
  80081d:	83 c0 01             	add    $0x1,%eax
  800820:	eb f1                	jmp    800813 <strnlen+0x12>
  800822:	89 c2                	mov    %eax,%edx
	return n;
}
  800824:	89 d0                	mov    %edx,%eax
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800828:	f3 0f 1e fb          	endbr32 
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80083f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	84 d2                	test   %dl,%dl
  800847:	75 f2                	jne    80083b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800849:	89 c8                	mov    %ecx,%eax
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	83 ec 10             	sub    $0x10,%esp
  800859:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085c:	53                   	push   %ebx
  80085d:	e8 83 ff ff ff       	call   8007e5 <strlen>
  800862:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	01 d8                	add    %ebx,%eax
  80086a:	50                   	push   %eax
  80086b:	e8 b8 ff ff ff       	call   800828 <strcpy>
	return dst;
}
  800870:	89 d8                	mov    %ebx,%eax
  800872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800877:	f3 0f 1e fb          	endbr32 
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	8b 75 08             	mov    0x8(%ebp),%esi
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 f3                	mov    %esi,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	39 d8                	cmp    %ebx,%eax
  80088f:	74 11                	je     8008a2 <strncpy+0x2b>
		*dst++ = *src;
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	0f b6 0a             	movzbl (%edx),%ecx
  800897:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089a:	80 f9 01             	cmp    $0x1,%cl
  80089d:	83 da ff             	sbb    $0xffffffff,%edx
  8008a0:	eb eb                	jmp    80088d <strncpy+0x16>
	}
	return ret;
}
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a8:	f3 0f 1e fb          	endbr32 
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	56                   	push   %esi
  8008b0:	53                   	push   %ebx
  8008b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bc:	85 d2                	test   %edx,%edx
  8008be:	74 21                	je     8008e1 <strlcpy+0x39>
  8008c0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008c6:	39 c2                	cmp    %eax,%edx
  8008c8:	74 14                	je     8008de <strlcpy+0x36>
  8008ca:	0f b6 19             	movzbl (%ecx),%ebx
  8008cd:	84 db                	test   %bl,%bl
  8008cf:	74 0b                	je     8008dc <strlcpy+0x34>
			*dst++ = *src++;
  8008d1:	83 c1 01             	add    $0x1,%ecx
  8008d4:	83 c2 01             	add    $0x1,%edx
  8008d7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008da:	eb ea                	jmp    8008c6 <strlcpy+0x1e>
  8008dc:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008de:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e1:	29 f0                	sub    %esi,%eax
}
  8008e3:	5b                   	pop    %ebx
  8008e4:	5e                   	pop    %esi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e7:	f3 0f 1e fb          	endbr32 
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f4:	0f b6 01             	movzbl (%ecx),%eax
  8008f7:	84 c0                	test   %al,%al
  8008f9:	74 0c                	je     800907 <strcmp+0x20>
  8008fb:	3a 02                	cmp    (%edx),%al
  8008fd:	75 08                	jne    800907 <strcmp+0x20>
		p++, q++;
  8008ff:	83 c1 01             	add    $0x1,%ecx
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	eb ed                	jmp    8008f4 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 c0             	movzbl %al,%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800911:	f3 0f 1e fb          	endbr32 
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	53                   	push   %ebx
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	89 c3                	mov    %eax,%ebx
  800921:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800924:	eb 06                	jmp    80092c <strncmp+0x1b>
		n--, p++, q++;
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80092c:	39 d8                	cmp    %ebx,%eax
  80092e:	74 16                	je     800946 <strncmp+0x35>
  800930:	0f b6 08             	movzbl (%eax),%ecx
  800933:	84 c9                	test   %cl,%cl
  800935:	74 04                	je     80093b <strncmp+0x2a>
  800937:	3a 0a                	cmp    (%edx),%cl
  800939:	74 eb                	je     800926 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093b:	0f b6 00             	movzbl (%eax),%eax
  80093e:	0f b6 12             	movzbl (%edx),%edx
  800941:	29 d0                	sub    %edx,%eax
}
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    
		return 0;
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	eb f6                	jmp    800943 <strncmp+0x32>

0080094d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094d:	f3 0f 1e fb          	endbr32 
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095b:	0f b6 10             	movzbl (%eax),%edx
  80095e:	84 d2                	test   %dl,%dl
  800960:	74 09                	je     80096b <strchr+0x1e>
		if (*s == c)
  800962:	38 ca                	cmp    %cl,%dl
  800964:	74 0a                	je     800970 <strchr+0x23>
	for (; *s; s++)
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	eb f0                	jmp    80095b <strchr+0xe>
			return (char *) s;
	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  800972:	f3 0f 1e fb          	endbr32 
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  80097c:	6a 78                	push   $0x78
  80097e:	ff 75 08             	pushl  0x8(%ebp)
  800981:	e8 c7 ff ff ff       	call   80094d <strchr>
  800986:	83 c4 10             	add    $0x10,%esp
  800989:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  800991:	eb 0d                	jmp    8009a0 <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  800993:	c1 e0 04             	shl    $0x4,%eax
  800996:	0f be d2             	movsbl %dl,%edx
  800999:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  80099d:	83 c1 01             	add    $0x1,%ecx
  8009a0:	0f b6 11             	movzbl (%ecx),%edx
  8009a3:	84 d2                	test   %dl,%dl
  8009a5:	74 11                	je     8009b8 <atox+0x46>
		if (*p>='a'){
  8009a7:	80 fa 60             	cmp    $0x60,%dl
  8009aa:	7e e7                	jle    800993 <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  8009ac:	c1 e0 04             	shl    $0x4,%eax
  8009af:	0f be d2             	movsbl %dl,%edx
  8009b2:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  8009b6:	eb e5                	jmp    80099d <atox+0x2b>
	}

	return v;

}
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ba:	f3 0f 1e fb          	endbr32 
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 09                	je     8009d8 <strfind+0x1e>
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	74 05                	je     8009d8 <strfind+0x1e>
	for (; *s; s++)
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	eb f0                	jmp    8009c8 <strfind+0xe>
			break;
	return (char *) s;
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009da:	f3 0f 1e fb          	endbr32 
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 31                	je     800a1f <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	89 f8                	mov    %edi,%eax
  8009f0:	09 c8                	or     %ecx,%eax
  8009f2:	a8 03                	test   $0x3,%al
  8009f4:	75 23                	jne    800a19 <memset+0x3f>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d0                	mov    %edx,%eax
  800a01:	c1 e0 18             	shl    $0x18,%eax
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 10             	shl    $0x10,%esi
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
  800a0d:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	f3 0f 1e fb          	endbr32 
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a38:	39 c6                	cmp    %eax,%esi
  800a3a:	73 32                	jae    800a6e <memmove+0x48>
  800a3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3f:	39 c2                	cmp    %eax,%edx
  800a41:	76 2b                	jbe    800a6e <memmove+0x48>
		s += n;
		d += n;
  800a43:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	89 fe                	mov    %edi,%esi
  800a48:	09 ce                	or     %ecx,%esi
  800a4a:	09 d6                	or     %edx,%esi
  800a4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a52:	75 0e                	jne    800a62 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a54:	83 ef 04             	sub    $0x4,%edi
  800a57:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5d:	fd                   	std    
  800a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a60:	eb 09                	jmp    800a6b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a62:	83 ef 01             	sub    $0x1,%edi
  800a65:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a68:	fd                   	std    
  800a69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6b:	fc                   	cld    
  800a6c:	eb 1a                	jmp    800a88 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	89 c2                	mov    %eax,%edx
  800a70:	09 ca                	or     %ecx,%edx
  800a72:	09 f2                	or     %esi,%edx
  800a74:	f6 c2 03             	test   $0x3,%dl
  800a77:	75 0a                	jne    800a83 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	fc                   	cld    
  800a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a81:	eb 05                	jmp    800a88 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8c:	f3 0f 1e fb          	endbr32 
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a96:	ff 75 10             	pushl  0x10(%ebp)
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	ff 75 08             	pushl  0x8(%ebp)
  800a9f:	e8 82 ff ff ff       	call   800a26 <memmove>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa6:	f3 0f 1e fb          	endbr32 
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aba:	39 f0                	cmp    %esi,%eax
  800abc:	74 1c                	je     800ada <memcmp+0x34>
		if (*s1 != *s2)
  800abe:	0f b6 08             	movzbl (%eax),%ecx
  800ac1:	0f b6 1a             	movzbl (%edx),%ebx
  800ac4:	38 d9                	cmp    %bl,%cl
  800ac6:	75 08                	jne    800ad0 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ac8:	83 c0 01             	add    $0x1,%eax
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	eb ea                	jmp    800aba <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ad0:	0f b6 c1             	movzbl %cl,%eax
  800ad3:	0f b6 db             	movzbl %bl,%ebx
  800ad6:	29 d8                	sub    %ebx,%eax
  800ad8:	eb 05                	jmp    800adf <memcmp+0x39>
	}

	return 0;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae3:	f3 0f 1e fb          	endbr32 
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af5:	39 d0                	cmp    %edx,%eax
  800af7:	73 09                	jae    800b02 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af9:	38 08                	cmp    %cl,(%eax)
  800afb:	74 05                	je     800b02 <memfind+0x1f>
	for (; s < ends; s++)
  800afd:	83 c0 01             	add    $0x1,%eax
  800b00:	eb f3                	jmp    800af5 <memfind+0x12>
			break;
	return (void *) s;
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b04:	f3 0f 1e fb          	endbr32 
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b14:	eb 03                	jmp    800b19 <strtol+0x15>
		s++;
  800b16:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b19:	0f b6 01             	movzbl (%ecx),%eax
  800b1c:	3c 20                	cmp    $0x20,%al
  800b1e:	74 f6                	je     800b16 <strtol+0x12>
  800b20:	3c 09                	cmp    $0x9,%al
  800b22:	74 f2                	je     800b16 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b24:	3c 2b                	cmp    $0x2b,%al
  800b26:	74 2a                	je     800b52 <strtol+0x4e>
	int neg = 0;
  800b28:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b2d:	3c 2d                	cmp    $0x2d,%al
  800b2f:	74 2b                	je     800b5c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b31:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b37:	75 0f                	jne    800b48 <strtol+0x44>
  800b39:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3c:	74 28                	je     800b66 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3e:	85 db                	test   %ebx,%ebx
  800b40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b45:	0f 44 d8             	cmove  %eax,%ebx
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b50:	eb 46                	jmp    800b98 <strtol+0x94>
		s++;
  800b52:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5a:	eb d5                	jmp    800b31 <strtol+0x2d>
		s++, neg = 1;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b64:	eb cb                	jmp    800b31 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6a:	74 0e                	je     800b7a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b6c:	85 db                	test   %ebx,%ebx
  800b6e:	75 d8                	jne    800b48 <strtol+0x44>
		s++, base = 8;
  800b70:	83 c1 01             	add    $0x1,%ecx
  800b73:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b78:	eb ce                	jmp    800b48 <strtol+0x44>
		s += 2, base = 16;
  800b7a:	83 c1 02             	add    $0x2,%ecx
  800b7d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b82:	eb c4                	jmp    800b48 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b84:	0f be d2             	movsbl %dl,%edx
  800b87:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8d:	7d 3a                	jge    800bc9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b96:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 11             	movzbl (%ecx),%edx
  800b9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9e:	89 f3                	mov    %esi,%ebx
  800ba0:	80 fb 09             	cmp    $0x9,%bl
  800ba3:	76 df                	jbe    800b84 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ba5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba8:	89 f3                	mov    %esi,%ebx
  800baa:	80 fb 19             	cmp    $0x19,%bl
  800bad:	77 08                	ja     800bb7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800baf:	0f be d2             	movsbl %dl,%edx
  800bb2:	83 ea 57             	sub    $0x57,%edx
  800bb5:	eb d3                	jmp    800b8a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bb7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bba:	89 f3                	mov    %esi,%ebx
  800bbc:	80 fb 19             	cmp    $0x19,%bl
  800bbf:	77 08                	ja     800bc9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bc1:	0f be d2             	movsbl %dl,%edx
  800bc4:	83 ea 37             	sub    $0x37,%edx
  800bc7:	eb c1                	jmp    800b8a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcd:	74 05                	je     800bd4 <strtol+0xd0>
		*endptr = (char *) s;
  800bcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bd4:	89 c2                	mov    %eax,%edx
  800bd6:	f7 da                	neg    %edx
  800bd8:	85 ff                	test   %edi,%edi
  800bda:	0f 45 c2             	cmovne %edx,%eax
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be2:	f3 0f 1e fb          	endbr32 
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c04:	f3 0f 1e fb          	endbr32 
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 01 00 00 00       	mov    $0x1,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c27:	f3 0f 1e fb          	endbr32 
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3e:	89 cb                	mov    %ecx,%ebx
  800c40:	89 cf                	mov    %ecx,%edi
  800c42:	89 ce                	mov    %ecx,%esi
  800c44:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4b:	f3 0f 1e fb          	endbr32 
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c5f:	89 d1                	mov    %edx,%ecx
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 d7                	mov    %edx,%edi
  800c65:	89 d6                	mov    %edx,%esi
  800c67:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_yield>:

void
sys_yield(void)
{
  800c6e:	f3 0f 1e fb          	endbr32 
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c78:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c82:	89 d1                	mov    %edx,%ecx
  800c84:	89 d3                	mov    %edx,%ebx
  800c86:	89 d7                	mov    %edx,%edi
  800c88:	89 d6                	mov    %edx,%esi
  800c8a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c91:	f3 0f 1e fb          	endbr32 
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	b8 04 00 00 00       	mov    $0x4,%eax
  800cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cae:	89 f7                	mov    %esi,%edi
  800cb0:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb7:	f3 0f 1e fb          	endbr32 
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd2:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd5:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cdc:	f3 0f 1e fb          	endbr32 
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1b:	89 df                	mov    %ebx,%edi
  800d1d:	89 de                	mov    %ebx,%esi
  800d1f:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d26:	f3 0f 1e fb          	endbr32 
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4b:	f3 0f 1e fb          	endbr32 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d70:	f3 0f 1e fb          	endbr32 
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d85:	be 00 00 00 00       	mov    $0x0,%esi
  800d8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d90:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d97:	f3 0f 1e fb          	endbr32 
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dae:	89 cb                	mov    %ecx,%ebx
  800db0:	89 cf                	mov    %ecx,%edi
  800db2:	89 ce                	mov    %ecx,%esi
  800db4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dbb:	f3 0f 1e fb          	endbr32 
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dca:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 d3                	mov    %edx,%ebx
  800dd3:	89 d7                	mov    %edx,%edi
  800dd5:	89 d6                	mov    %edx,%esi
  800dd7:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800dde:	f3 0f 1e fb          	endbr32 
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800df8:	89 df                	mov    %ebx,%edi
  800dfa:	89 de                	mov    %ebx,%esi
  800dfc:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800e03:	f3 0f 1e fb          	endbr32 
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1d:	89 df                	mov    %ebx,%edi
  800e1f:	89 de                	mov    %ebx,%esi
  800e21:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e28:	f3 0f 1e fb          	endbr32 
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e38:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e3a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e3d:	83 3a 01             	cmpl   $0x1,(%edx)
  800e40:	7e 09                	jle    800e4b <argstart+0x23>
  800e42:	ba b1 26 80 00       	mov    $0x8026b1,%edx
  800e47:	85 c9                	test   %ecx,%ecx
  800e49:	75 05                	jne    800e50 <argstart+0x28>
  800e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e50:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e53:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <argnext>:

int
argnext(struct Argstate *args)
{
  800e5c:	f3 0f 1e fb          	endbr32 
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	53                   	push   %ebx
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e6a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e71:	8b 43 08             	mov    0x8(%ebx),%eax
  800e74:	85 c0                	test   %eax,%eax
  800e76:	74 74                	je     800eec <argnext+0x90>
		return -1;

	if (!*args->curarg) {
  800e78:	80 38 00             	cmpb   $0x0,(%eax)
  800e7b:	75 48                	jne    800ec5 <argnext+0x69>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e7d:	8b 0b                	mov    (%ebx),%ecx
  800e7f:	83 39 01             	cmpl   $0x1,(%ecx)
  800e82:	74 5a                	je     800ede <argnext+0x82>
		    || args->argv[1][0] != '-'
  800e84:	8b 53 04             	mov    0x4(%ebx),%edx
  800e87:	8b 42 04             	mov    0x4(%edx),%eax
  800e8a:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e8d:	75 4f                	jne    800ede <argnext+0x82>
		    || args->argv[1][1] == '\0')
  800e8f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e93:	74 49                	je     800ede <argnext+0x82>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e95:	83 c0 01             	add    $0x1,%eax
  800e98:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e9b:	83 ec 04             	sub    $0x4,%esp
  800e9e:	8b 01                	mov    (%ecx),%eax
  800ea0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ea7:	50                   	push   %eax
  800ea8:	8d 42 08             	lea    0x8(%edx),%eax
  800eab:	50                   	push   %eax
  800eac:	83 c2 04             	add    $0x4,%edx
  800eaf:	52                   	push   %edx
  800eb0:	e8 71 fb ff ff       	call   800a26 <memmove>
		(*args->argc)--;
  800eb5:	8b 03                	mov    (%ebx),%eax
  800eb7:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800eba:	8b 43 08             	mov    0x8(%ebx),%eax
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ec3:	74 13                	je     800ed8 <argnext+0x7c>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ec5:	8b 43 08             	mov    0x8(%ebx),%eax
  800ec8:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  800ecb:	83 c0 01             	add    $0x1,%eax
  800ece:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800ed1:	89 d0                	mov    %edx,%eax
  800ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ed8:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800edc:	75 e7                	jne    800ec5 <argnext+0x69>
	args->curarg = 0;
  800ede:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ee5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800eea:	eb e5                	jmp    800ed1 <argnext+0x75>
		return -1;
  800eec:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800ef1:	eb de                	jmp    800ed1 <argnext+0x75>

00800ef3 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800ef3:	f3 0f 1e fb          	endbr32 
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f01:	8b 43 08             	mov    0x8(%ebx),%eax
  800f04:	85 c0                	test   %eax,%eax
  800f06:	74 12                	je     800f1a <argnextvalue+0x27>
		return 0;
	if (*args->curarg) {
  800f08:	80 38 00             	cmpb   $0x0,(%eax)
  800f0b:	74 12                	je     800f1f <argnextvalue+0x2c>
		args->argvalue = args->curarg;
  800f0d:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f10:	c7 43 08 b1 26 80 00 	movl   $0x8026b1,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  800f17:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  800f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    
	} else if (*args->argc > 1) {
  800f1f:	8b 13                	mov    (%ebx),%edx
  800f21:	83 3a 01             	cmpl   $0x1,(%edx)
  800f24:	7f 10                	jg     800f36 <argnextvalue+0x43>
		args->argvalue = 0;
  800f26:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f2d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  800f34:	eb e1                	jmp    800f17 <argnextvalue+0x24>
		args->argvalue = args->argv[1];
  800f36:	8b 43 04             	mov    0x4(%ebx),%eax
  800f39:	8b 48 04             	mov    0x4(%eax),%ecx
  800f3c:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f3f:	83 ec 04             	sub    $0x4,%esp
  800f42:	8b 12                	mov    (%edx),%edx
  800f44:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f4b:	52                   	push   %edx
  800f4c:	8d 50 08             	lea    0x8(%eax),%edx
  800f4f:	52                   	push   %edx
  800f50:	83 c0 04             	add    $0x4,%eax
  800f53:	50                   	push   %eax
  800f54:	e8 cd fa ff ff       	call   800a26 <memmove>
		(*args->argc)--;
  800f59:	8b 03                	mov    (%ebx),%eax
  800f5b:	83 28 01             	subl   $0x1,(%eax)
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	eb b4                	jmp    800f17 <argnextvalue+0x24>

00800f63 <argvalue>:
{
  800f63:	f3 0f 1e fb          	endbr32 
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 08             	sub    $0x8,%esp
  800f6d:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f70:	8b 42 0c             	mov    0xc(%edx),%eax
  800f73:	85 c0                	test   %eax,%eax
  800f75:	74 02                	je     800f79 <argvalue+0x16>
}
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	52                   	push   %edx
  800f7d:	e8 71 ff ff ff       	call   800ef3 <argnextvalue>
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	eb f0                	jmp    800f77 <argvalue+0x14>

00800f87 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f87:	f3 0f 1e fb          	endbr32 
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	05 00 00 00 30       	add    $0x30000000,%eax
  800f96:	c1 e8 0c             	shr    $0xc,%eax
}
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f9b:	f3 0f 1e fb          	endbr32 
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa5:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800faa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800faf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fb6:	f3 0f 1e fb          	endbr32 
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fc2:	89 c2                	mov    %eax,%edx
  800fc4:	c1 ea 16             	shr    $0x16,%edx
  800fc7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fce:	f6 c2 01             	test   $0x1,%dl
  800fd1:	74 2d                	je     801000 <fd_alloc+0x4a>
  800fd3:	89 c2                	mov    %eax,%edx
  800fd5:	c1 ea 0c             	shr    $0xc,%edx
  800fd8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fdf:	f6 c2 01             	test   $0x1,%dl
  800fe2:	74 1c                	je     801000 <fd_alloc+0x4a>
  800fe4:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800fe9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fee:	75 d2                	jne    800fc2 <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800ff9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800ffe:	eb 0a                	jmp    80100a <fd_alloc+0x54>
			*fd_store = fd;
  801000:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801003:	89 01                	mov    %eax,(%ecx)
			return 0;
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80100c:	f3 0f 1e fb          	endbr32 
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801016:	83 f8 1f             	cmp    $0x1f,%eax
  801019:	77 30                	ja     80104b <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80101b:	c1 e0 0c             	shl    $0xc,%eax
  80101e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801023:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801029:	f6 c2 01             	test   $0x1,%dl
  80102c:	74 24                	je     801052 <fd_lookup+0x46>
  80102e:	89 c2                	mov    %eax,%edx
  801030:	c1 ea 0c             	shr    $0xc,%edx
  801033:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80103a:	f6 c2 01             	test   $0x1,%dl
  80103d:	74 1a                	je     801059 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80103f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801042:	89 02                	mov    %eax,(%edx)
	return 0;
  801044:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    
		return -E_INVAL;
  80104b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801050:	eb f7                	jmp    801049 <fd_lookup+0x3d>
		return -E_INVAL;
  801052:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801057:	eb f0                	jmp    801049 <fd_lookup+0x3d>
  801059:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80105e:	eb e9                	jmp    801049 <fd_lookup+0x3d>

00801060 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 08             	sub    $0x8,%esp
  80106a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  80106d:	ba 00 00 00 00       	mov    $0x0,%edx
  801072:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801077:	39 08                	cmp    %ecx,(%eax)
  801079:	74 38                	je     8010b3 <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  80107b:	83 c2 01             	add    $0x1,%edx
  80107e:	8b 04 95 5c 2a 80 00 	mov    0x802a5c(,%edx,4),%eax
  801085:	85 c0                	test   %eax,%eax
  801087:	75 ee                	jne    801077 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801089:	a1 08 40 80 00       	mov    0x804008,%eax
  80108e:	8b 40 48             	mov    0x48(%eax),%eax
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	51                   	push   %ecx
  801095:	50                   	push   %eax
  801096:	68 e0 29 80 00       	push   $0x8029e0
  80109b:	e8 7e f1 ff ff       	call   80021e <cprintf>
	*dev = 0;
  8010a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    
			*dev = devtab[i];
  8010b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bd:	eb f2                	jmp    8010b1 <dev_lookup+0x51>

008010bf <fd_close>:
{
  8010bf:	f3 0f 1e fb          	endbr32 
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	57                   	push   %edi
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 24             	sub    $0x24,%esp
  8010cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d5:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010df:	50                   	push   %eax
  8010e0:	e8 27 ff ff ff       	call   80100c <fd_lookup>
  8010e5:	89 c3                	mov    %eax,%ebx
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 05                	js     8010f3 <fd_close+0x34>
	    || fd != fd2)
  8010ee:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8010f1:	74 16                	je     801109 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8010f3:	89 f8                	mov    %edi,%eax
  8010f5:	84 c0                	test   %al,%al
  8010f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fc:	0f 44 d8             	cmove  %eax,%ebx
}
  8010ff:	89 d8                	mov    %ebx,%eax
  801101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	ff 36                	pushl  (%esi)
  801112:	e8 49 ff ff ff       	call   801060 <dev_lookup>
  801117:	89 c3                	mov    %eax,%ebx
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 1a                	js     80113a <fd_close+0x7b>
		if (dev->dev_close)
  801120:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801123:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801126:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80112b:	85 c0                	test   %eax,%eax
  80112d:	74 0b                	je     80113a <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	56                   	push   %esi
  801133:	ff d0                	call   *%eax
  801135:	89 c3                	mov    %eax,%ebx
  801137:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	56                   	push   %esi
  80113e:	6a 00                	push   $0x0
  801140:	e8 97 fb ff ff       	call   800cdc <sys_page_unmap>
	return r;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	eb b5                	jmp    8010ff <fd_close+0x40>

0080114a <close>:

int
close(int fdnum)
{
  80114a:	f3 0f 1e fb          	endbr32 
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801154:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801157:	50                   	push   %eax
  801158:	ff 75 08             	pushl  0x8(%ebp)
  80115b:	e8 ac fe ff ff       	call   80100c <fd_lookup>
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	79 02                	jns    801169 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801167:	c9                   	leave  
  801168:	c3                   	ret    
		return fd_close(fd, 1);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	6a 01                	push   $0x1
  80116e:	ff 75 f4             	pushl  -0xc(%ebp)
  801171:	e8 49 ff ff ff       	call   8010bf <fd_close>
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	eb ec                	jmp    801167 <close+0x1d>

0080117b <close_all>:

void
close_all(void)
{
  80117b:	f3 0f 1e fb          	endbr32 
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	53                   	push   %ebx
  801183:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801186:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	53                   	push   %ebx
  80118f:	e8 b6 ff ff ff       	call   80114a <close>
	for (i = 0; i < MAXFD; i++)
  801194:	83 c3 01             	add    $0x1,%ebx
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	83 fb 20             	cmp    $0x20,%ebx
  80119d:	75 ec                	jne    80118b <close_all+0x10>
}
  80119f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011a4:	f3 0f 1e fb          	endbr32 
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	ff 75 08             	pushl  0x8(%ebp)
  8011b8:	e8 4f fe ff ff       	call   80100c <fd_lookup>
  8011bd:	89 c3                	mov    %eax,%ebx
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	0f 88 81 00 00 00    	js     80124b <dup+0xa7>
		return r;
	close(newfdnum);
  8011ca:	83 ec 0c             	sub    $0xc,%esp
  8011cd:	ff 75 0c             	pushl  0xc(%ebp)
  8011d0:	e8 75 ff ff ff       	call   80114a <close>

	newfd = INDEX2FD(newfdnum);
  8011d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011d8:	c1 e6 0c             	shl    $0xc,%esi
  8011db:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8011e1:	83 c4 04             	add    $0x4,%esp
  8011e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e7:	e8 af fd ff ff       	call   800f9b <fd2data>
  8011ec:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011ee:	89 34 24             	mov    %esi,(%esp)
  8011f1:	e8 a5 fd ff ff       	call   800f9b <fd2data>
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	c1 e8 16             	shr    $0x16,%eax
  801200:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801207:	a8 01                	test   $0x1,%al
  801209:	74 11                	je     80121c <dup+0x78>
  80120b:	89 d8                	mov    %ebx,%eax
  80120d:	c1 e8 0c             	shr    $0xc,%eax
  801210:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801217:	f6 c2 01             	test   $0x1,%dl
  80121a:	75 39                	jne    801255 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80121c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80121f:	89 d0                	mov    %edx,%eax
  801221:	c1 e8 0c             	shr    $0xc,%eax
  801224:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80122b:	83 ec 0c             	sub    $0xc,%esp
  80122e:	25 07 0e 00 00       	and    $0xe07,%eax
  801233:	50                   	push   %eax
  801234:	56                   	push   %esi
  801235:	6a 00                	push   $0x0
  801237:	52                   	push   %edx
  801238:	6a 00                	push   $0x0
  80123a:	e8 78 fa ff ff       	call   800cb7 <sys_page_map>
  80123f:	89 c3                	mov    %eax,%ebx
  801241:	83 c4 20             	add    $0x20,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 31                	js     801279 <dup+0xd5>
		goto err;

	return newfdnum;
  801248:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80124b:	89 d8                	mov    %ebx,%eax
  80124d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801255:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	25 07 0e 00 00       	and    $0xe07,%eax
  801264:	50                   	push   %eax
  801265:	57                   	push   %edi
  801266:	6a 00                	push   $0x0
  801268:	53                   	push   %ebx
  801269:	6a 00                	push   $0x0
  80126b:	e8 47 fa ff ff       	call   800cb7 <sys_page_map>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 20             	add    $0x20,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	79 a3                	jns    80121c <dup+0x78>
	sys_page_unmap(0, newfd);
  801279:	83 ec 08             	sub    $0x8,%esp
  80127c:	56                   	push   %esi
  80127d:	6a 00                	push   $0x0
  80127f:	e8 58 fa ff ff       	call   800cdc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	57                   	push   %edi
  801288:	6a 00                	push   $0x0
  80128a:	e8 4d fa ff ff       	call   800cdc <sys_page_unmap>
	return r;
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	eb b7                	jmp    80124b <dup+0xa7>

00801294 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801294:	f3 0f 1e fb          	endbr32 
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	53                   	push   %ebx
  80129c:	83 ec 1c             	sub    $0x1c,%esp
  80129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a5:	50                   	push   %eax
  8012a6:	53                   	push   %ebx
  8012a7:	e8 60 fd ff ff       	call   80100c <fd_lookup>
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 3f                	js     8012f2 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b9:	50                   	push   %eax
  8012ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bd:	ff 30                	pushl  (%eax)
  8012bf:	e8 9c fd ff ff       	call   801060 <dev_lookup>
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	78 27                	js     8012f2 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ce:	8b 42 08             	mov    0x8(%edx),%eax
  8012d1:	83 e0 03             	and    $0x3,%eax
  8012d4:	83 f8 01             	cmp    $0x1,%eax
  8012d7:	74 1e                	je     8012f7 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8012d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012dc:	8b 40 08             	mov    0x8(%eax),%eax
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	74 35                	je     801318 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	ff 75 10             	pushl  0x10(%ebp)
  8012e9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ec:	52                   	push   %edx
  8012ed:	ff d0                	call   *%eax
  8012ef:	83 c4 10             	add    $0x10,%esp
}
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012f7:	a1 08 40 80 00       	mov    0x804008,%eax
  8012fc:	8b 40 48             	mov    0x48(%eax),%eax
  8012ff:	83 ec 04             	sub    $0x4,%esp
  801302:	53                   	push   %ebx
  801303:	50                   	push   %eax
  801304:	68 21 2a 80 00       	push   $0x802a21
  801309:	e8 10 ef ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801316:	eb da                	jmp    8012f2 <read+0x5e>
		return -E_NOT_SUPP;
  801318:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80131d:	eb d3                	jmp    8012f2 <read+0x5e>

0080131f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80131f:	f3 0f 1e fb          	endbr32 
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 0c             	sub    $0xc,%esp
  80132c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80132f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
  801337:	eb 02                	jmp    80133b <readn+0x1c>
  801339:	01 c3                	add    %eax,%ebx
  80133b:	39 f3                	cmp    %esi,%ebx
  80133d:	73 21                	jae    801360 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80133f:	83 ec 04             	sub    $0x4,%esp
  801342:	89 f0                	mov    %esi,%eax
  801344:	29 d8                	sub    %ebx,%eax
  801346:	50                   	push   %eax
  801347:	89 d8                	mov    %ebx,%eax
  801349:	03 45 0c             	add    0xc(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	57                   	push   %edi
  80134e:	e8 41 ff ff ff       	call   801294 <read>
		if (m < 0)
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 04                	js     80135e <readn+0x3f>
			return m;
		if (m == 0)
  80135a:	75 dd                	jne    801339 <readn+0x1a>
  80135c:	eb 02                	jmp    801360 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80135e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801360:	89 d8                	mov    %ebx,%eax
  801362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801365:	5b                   	pop    %ebx
  801366:	5e                   	pop    %esi
  801367:	5f                   	pop    %edi
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80136a:	f3 0f 1e fb          	endbr32 
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	53                   	push   %ebx
  801372:	83 ec 1c             	sub    $0x1c,%esp
  801375:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801378:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	53                   	push   %ebx
  80137d:	e8 8a fc ff ff       	call   80100c <fd_lookup>
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	85 c0                	test   %eax,%eax
  801387:	78 3a                	js     8013c3 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	ff 30                	pushl  (%eax)
  801395:	e8 c6 fc ff ff       	call   801060 <dev_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 22                	js     8013c3 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013a8:	74 1e                	je     8013c8 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8013b0:	85 d2                	test   %edx,%edx
  8013b2:	74 35                	je     8013e9 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	ff 75 10             	pushl  0x10(%ebp)
  8013ba:	ff 75 0c             	pushl  0xc(%ebp)
  8013bd:	50                   	push   %eax
  8013be:	ff d2                	call   *%edx
  8013c0:	83 c4 10             	add    $0x10,%esp
}
  8013c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8013cd:	8b 40 48             	mov    0x48(%eax),%eax
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	53                   	push   %ebx
  8013d4:	50                   	push   %eax
  8013d5:	68 3d 2a 80 00       	push   $0x802a3d
  8013da:	e8 3f ee ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e7:	eb da                	jmp    8013c3 <write+0x59>
		return -E_NOT_SUPP;
  8013e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ee:	eb d3                	jmp    8013c3 <write+0x59>

008013f0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013f0:	f3 0f 1e fb          	endbr32 
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	ff 75 08             	pushl  0x8(%ebp)
  801401:	e8 06 fc ff ff       	call   80100c <fd_lookup>
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 0e                	js     80141b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80140d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801413:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801416:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80141d:	f3 0f 1e fb          	endbr32 
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	53                   	push   %ebx
  801425:	83 ec 1c             	sub    $0x1c,%esp
  801428:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	53                   	push   %ebx
  801430:	e8 d7 fb ff ff       	call   80100c <fd_lookup>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 37                	js     801473 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801446:	ff 30                	pushl  (%eax)
  801448:	e8 13 fc ff ff       	call   801060 <dev_lookup>
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	78 1f                	js     801473 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801457:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80145b:	74 1b                	je     801478 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80145d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801460:	8b 52 18             	mov    0x18(%edx),%edx
  801463:	85 d2                	test   %edx,%edx
  801465:	74 32                	je     801499 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	ff 75 0c             	pushl  0xc(%ebp)
  80146d:	50                   	push   %eax
  80146e:	ff d2                	call   *%edx
  801470:	83 c4 10             	add    $0x10,%esp
}
  801473:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801476:	c9                   	leave  
  801477:	c3                   	ret    
			thisenv->env_id, fdnum);
  801478:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80147d:	8b 40 48             	mov    0x48(%eax),%eax
  801480:	83 ec 04             	sub    $0x4,%esp
  801483:	53                   	push   %ebx
  801484:	50                   	push   %eax
  801485:	68 00 2a 80 00       	push   $0x802a00
  80148a:	e8 8f ed ff ff       	call   80021e <cprintf>
		return -E_INVAL;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801497:	eb da                	jmp    801473 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801499:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80149e:	eb d3                	jmp    801473 <ftruncate+0x56>

008014a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014a0:	f3 0f 1e fb          	endbr32 
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 1c             	sub    $0x1c,%esp
  8014ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	ff 75 08             	pushl  0x8(%ebp)
  8014b5:	e8 52 fb ff ff       	call   80100c <fd_lookup>
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 4b                	js     80150c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cb:	ff 30                	pushl  (%eax)
  8014cd:	e8 8e fb ff ff       	call   801060 <dev_lookup>
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 33                	js     80150c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8014d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014e0:	74 2f                	je     801511 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014e2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014e5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014ec:	00 00 00 
	stat->st_isdir = 0;
  8014ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014f6:	00 00 00 
	stat->st_dev = dev;
  8014f9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	53                   	push   %ebx
  801503:	ff 75 f0             	pushl  -0x10(%ebp)
  801506:	ff 50 14             	call   *0x14(%eax)
  801509:	83 c4 10             	add    $0x10,%esp
}
  80150c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150f:	c9                   	leave  
  801510:	c3                   	ret    
		return -E_NOT_SUPP;
  801511:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801516:	eb f4                	jmp    80150c <fstat+0x6c>

00801518 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801518:	f3 0f 1e fb          	endbr32 
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	6a 00                	push   $0x0
  801526:	ff 75 08             	pushl  0x8(%ebp)
  801529:	e8 01 02 00 00       	call   80172f <open>
  80152e:	89 c3                	mov    %eax,%ebx
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	78 1b                	js     801552 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	ff 75 0c             	pushl  0xc(%ebp)
  80153d:	50                   	push   %eax
  80153e:	e8 5d ff ff ff       	call   8014a0 <fstat>
  801543:	89 c6                	mov    %eax,%esi
	close(fd);
  801545:	89 1c 24             	mov    %ebx,(%esp)
  801548:	e8 fd fb ff ff       	call   80114a <close>
	return r;
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	89 f3                	mov    %esi,%ebx
}
  801552:	89 d8                	mov    %ebx,%eax
  801554:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	56                   	push   %esi
  80155f:	53                   	push   %ebx
  801560:	89 c6                	mov    %eax,%esi
  801562:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801564:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80156b:	74 27                	je     801594 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80156d:	6a 07                	push   $0x7
  80156f:	68 00 50 80 00       	push   $0x805000
  801574:	56                   	push   %esi
  801575:	ff 35 00 40 80 00    	pushl  0x804000
  80157b:	e8 ea 0d 00 00       	call   80236a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801580:	83 c4 0c             	add    $0xc,%esp
  801583:	6a 00                	push   $0x0
  801585:	53                   	push   %ebx
  801586:	6a 00                	push   $0x0
  801588:	e8 70 0d 00 00       	call   8022fd <ipc_recv>
}
  80158d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801590:	5b                   	pop    %ebx
  801591:	5e                   	pop    %esi
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	6a 01                	push   $0x1
  801599:	e8 24 0e 00 00       	call   8023c2 <ipc_find_env>
  80159e:	a3 00 40 80 00       	mov    %eax,0x804000
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	eb c5                	jmp    80156d <fsipc+0x12>

008015a8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015a8:	f3 0f 1e fb          	endbr32 
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8015bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8015cf:	e8 87 ff ff ff       	call   80155b <fsipc>
}
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <devfile_flush>:
{
  8015d6:	f3 0f 1e fb          	endbr32 
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8015f5:	e8 61 ff ff ff       	call   80155b <fsipc>
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <devfile_stat>:
{
  8015fc:	f3 0f 1e fb          	endbr32 
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 04             	sub    $0x4,%esp
  801607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	8b 40 0c             	mov    0xc(%eax),%eax
  801610:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801615:	ba 00 00 00 00       	mov    $0x0,%edx
  80161a:	b8 05 00 00 00       	mov    $0x5,%eax
  80161f:	e8 37 ff ff ff       	call   80155b <fsipc>
  801624:	85 c0                	test   %eax,%eax
  801626:	78 2c                	js     801654 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	68 00 50 80 00       	push   $0x805000
  801630:	53                   	push   %ebx
  801631:	e8 f2 f1 ff ff       	call   800828 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801636:	a1 80 50 80 00       	mov    0x805080,%eax
  80163b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801641:	a1 84 50 80 00       	mov    0x805084,%eax
  801646:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <devfile_write>:
{
  801659:	f3 0f 1e fb          	endbr32 
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 0c             	sub    $0xc,%esp
  801663:	8b 45 10             	mov    0x10(%ebp),%eax
  801666:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80166b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801670:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801673:	8b 55 08             	mov    0x8(%ebp),%edx
  801676:	8b 52 0c             	mov    0xc(%edx),%edx
  801679:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80167f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801684:	50                   	push   %eax
  801685:	ff 75 0c             	pushl  0xc(%ebp)
  801688:	68 08 50 80 00       	push   $0x805008
  80168d:	e8 94 f3 ff ff       	call   800a26 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
  801697:	b8 04 00 00 00       	mov    $0x4,%eax
  80169c:	e8 ba fe ff ff       	call   80155b <fsipc>
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <devfile_read>:
{
  8016a3:	f3 0f 1e fb          	endbr32 
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016ba:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ca:	e8 8c fe ff ff       	call   80155b <fsipc>
  8016cf:	89 c3                	mov    %eax,%ebx
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 1f                	js     8016f4 <devfile_read+0x51>
	assert(r <= n);
  8016d5:	39 f0                	cmp    %esi,%eax
  8016d7:	77 24                	ja     8016fd <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8016d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016de:	7f 36                	jg     801716 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016e0:	83 ec 04             	sub    $0x4,%esp
  8016e3:	50                   	push   %eax
  8016e4:	68 00 50 80 00       	push   $0x805000
  8016e9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ec:	e8 35 f3 ff ff       	call   800a26 <memmove>
	return r;
  8016f1:	83 c4 10             	add    $0x10,%esp
}
  8016f4:	89 d8                	mov    %ebx,%eax
  8016f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    
	assert(r <= n);
  8016fd:	68 70 2a 80 00       	push   $0x802a70
  801702:	68 77 2a 80 00       	push   $0x802a77
  801707:	68 8c 00 00 00       	push   $0x8c
  80170c:	68 8c 2a 80 00       	push   $0x802a8c
  801711:	e8 9d 0b 00 00       	call   8022b3 <_panic>
	assert(r <= PGSIZE);
  801716:	68 97 2a 80 00       	push   $0x802a97
  80171b:	68 77 2a 80 00       	push   $0x802a77
  801720:	68 8d 00 00 00       	push   $0x8d
  801725:	68 8c 2a 80 00       	push   $0x802a8c
  80172a:	e8 84 0b 00 00       	call   8022b3 <_panic>

0080172f <open>:
{
  80172f:	f3 0f 1e fb          	endbr32 
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	83 ec 1c             	sub    $0x1c,%esp
  80173b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80173e:	56                   	push   %esi
  80173f:	e8 a1 f0 ff ff       	call   8007e5 <strlen>
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80174c:	7f 6c                	jg     8017ba <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801754:	50                   	push   %eax
  801755:	e8 5c f8 ff ff       	call   800fb6 <fd_alloc>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 3c                	js     80179f <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	56                   	push   %esi
  801767:	68 00 50 80 00       	push   $0x805000
  80176c:	e8 b7 f0 ff ff       	call   800828 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801771:	8b 45 0c             	mov    0xc(%ebp),%eax
  801774:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801779:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177c:	b8 01 00 00 00       	mov    $0x1,%eax
  801781:	e8 d5 fd ff ff       	call   80155b <fsipc>
  801786:	89 c3                	mov    %eax,%ebx
  801788:	83 c4 10             	add    $0x10,%esp
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 19                	js     8017a8 <open+0x79>
	return fd2num(fd);
  80178f:	83 ec 0c             	sub    $0xc,%esp
  801792:	ff 75 f4             	pushl  -0xc(%ebp)
  801795:	e8 ed f7 ff ff       	call   800f87 <fd2num>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	83 c4 10             	add    $0x10,%esp
}
  80179f:	89 d8                	mov    %ebx,%eax
  8017a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a4:	5b                   	pop    %ebx
  8017a5:	5e                   	pop    %esi
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    
		fd_close(fd, 0);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	6a 00                	push   $0x0
  8017ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b0:	e8 0a f9 ff ff       	call   8010bf <fd_close>
		return r;
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb e5                	jmp    80179f <open+0x70>
		return -E_BAD_PATH;
  8017ba:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8017bf:	eb de                	jmp    80179f <open+0x70>

008017c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017c1:	f3 0f 1e fb          	endbr32 
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8017d5:	e8 81 fd ff ff       	call   80155b <fsipc>
}
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    

008017dc <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8017dc:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017e0:	7f 01                	jg     8017e3 <writebuf+0x7>
  8017e2:	c3                   	ret    
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	53                   	push   %ebx
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017ec:	ff 70 04             	pushl  0x4(%eax)
  8017ef:	8d 40 10             	lea    0x10(%eax),%eax
  8017f2:	50                   	push   %eax
  8017f3:	ff 33                	pushl  (%ebx)
  8017f5:	e8 70 fb ff ff       	call   80136a <write>
		if (result > 0)
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	7e 03                	jle    801804 <writebuf+0x28>
			b->result += result;
  801801:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801804:	39 43 04             	cmp    %eax,0x4(%ebx)
  801807:	74 0d                	je     801816 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801809:	85 c0                	test   %eax,%eax
  80180b:	ba 00 00 00 00       	mov    $0x0,%edx
  801810:	0f 4f c2             	cmovg  %edx,%eax
  801813:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <putch>:

static void
putch(int ch, void *thunk)
{
  80181b:	f3 0f 1e fb          	endbr32 
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 04             	sub    $0x4,%esp
  801826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801829:	8b 53 04             	mov    0x4(%ebx),%edx
  80182c:	8d 42 01             	lea    0x1(%edx),%eax
  80182f:	89 43 04             	mov    %eax,0x4(%ebx)
  801832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801835:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801839:	3d 00 01 00 00       	cmp    $0x100,%eax
  80183e:	74 06                	je     801846 <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  801840:	83 c4 04             	add    $0x4,%esp
  801843:	5b                   	pop    %ebx
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    
		writebuf(b);
  801846:	89 d8                	mov    %ebx,%eax
  801848:	e8 8f ff ff ff       	call   8017dc <writebuf>
		b->idx = 0;
  80184d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  801854:	eb ea                	jmp    801840 <putch+0x25>

00801856 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801856:	f3 0f 1e fb          	endbr32 
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80186c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801873:	00 00 00 
	b.result = 0;
  801876:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80187d:	00 00 00 
	b.error = 1;
  801880:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801887:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80188a:	ff 75 10             	pushl  0x10(%ebp)
  80188d:	ff 75 0c             	pushl  0xc(%ebp)
  801890:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801896:	50                   	push   %eax
  801897:	68 1b 18 80 00       	push   $0x80181b
  80189c:	e8 80 ea ff ff       	call   800321 <vprintfmt>
	if (b.idx > 0)
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018ab:	7f 11                	jg     8018be <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8018ad:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    
		writebuf(&b);
  8018be:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018c4:	e8 13 ff ff ff       	call   8017dc <writebuf>
  8018c9:	eb e2                	jmp    8018ad <vfprintf+0x57>

008018cb <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018cb:	f3 0f 1e fb          	endbr32 
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018d5:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018d8:	50                   	push   %eax
  8018d9:	ff 75 0c             	pushl  0xc(%ebp)
  8018dc:	ff 75 08             	pushl  0x8(%ebp)
  8018df:	e8 72 ff ff ff       	call   801856 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <printf>:

int
printf(const char *fmt, ...)
{
  8018e6:	f3 0f 1e fb          	endbr32 
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018f3:	50                   	push   %eax
  8018f4:	ff 75 08             	pushl  0x8(%ebp)
  8018f7:	6a 01                	push   $0x1
  8018f9:	e8 58 ff ff ff       	call   801856 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801900:	f3 0f 1e fb          	endbr32 
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80190a:	68 03 2b 80 00       	push   $0x802b03
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	e8 11 ef ff ff       	call   800828 <strcpy>
	return 0;
}
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devsock_close>:
{
  80191e:	f3 0f 1e fb          	endbr32 
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	53                   	push   %ebx
  801926:	83 ec 10             	sub    $0x10,%esp
  801929:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80192c:	53                   	push   %ebx
  80192d:	e8 cd 0a 00 00       	call   8023ff <pageref>
  801932:	89 c2                	mov    %eax,%edx
  801934:	83 c4 10             	add    $0x10,%esp
		return 0;
  801937:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80193c:	83 fa 01             	cmp    $0x1,%edx
  80193f:	74 05                	je     801946 <devsock_close+0x28>
}
  801941:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801944:	c9                   	leave  
  801945:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff 73 0c             	pushl  0xc(%ebx)
  80194c:	e8 e3 02 00 00       	call   801c34 <nsipc_close>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	eb eb                	jmp    801941 <devsock_close+0x23>

00801956 <devsock_write>:
{
  801956:	f3 0f 1e fb          	endbr32 
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801960:	6a 00                	push   $0x0
  801962:	ff 75 10             	pushl  0x10(%ebp)
  801965:	ff 75 0c             	pushl  0xc(%ebp)
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	ff 70 0c             	pushl  0xc(%eax)
  80196e:	e8 b5 03 00 00       	call   801d28 <nsipc_send>
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <devsock_read>:
{
  801975:	f3 0f 1e fb          	endbr32 
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80197f:	6a 00                	push   $0x0
  801981:	ff 75 10             	pushl  0x10(%ebp)
  801984:	ff 75 0c             	pushl  0xc(%ebp)
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	ff 70 0c             	pushl  0xc(%eax)
  80198d:	e8 1f 03 00 00       	call   801cb1 <nsipc_recv>
}
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <fd2sockid>:
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80199a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80199d:	52                   	push   %edx
  80199e:	50                   	push   %eax
  80199f:	e8 68 f6 ff ff       	call   80100c <fd_lookup>
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 10                	js     8019bb <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ae:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  8019b4:	39 08                	cmp    %ecx,(%eax)
  8019b6:	75 05                	jne    8019bd <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8019b8:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    
		return -E_NOT_SUPP;
  8019bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c2:	eb f7                	jmp    8019bb <fd2sockid+0x27>

008019c4 <alloc_sockfd>:
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 1c             	sub    $0x1c,%esp
  8019cc:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8019ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d1:	50                   	push   %eax
  8019d2:	e8 df f5 ff ff       	call   800fb6 <fd_alloc>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 43                	js     801a23 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019e0:	83 ec 04             	sub    $0x4,%esp
  8019e3:	68 07 04 00 00       	push   $0x407
  8019e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019eb:	6a 00                	push   $0x0
  8019ed:	e8 9f f2 ff ff       	call   800c91 <sys_page_alloc>
  8019f2:	89 c3                	mov    %eax,%ebx
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 28                	js     801a23 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fe:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801a04:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a09:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a10:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	50                   	push   %eax
  801a17:	e8 6b f5 ff ff       	call   800f87 <fd2num>
  801a1c:	89 c3                	mov    %eax,%ebx
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	eb 0c                	jmp    801a2f <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	56                   	push   %esi
  801a27:	e8 08 02 00 00       	call   801c34 <nsipc_close>
		return r;
  801a2c:	83 c4 10             	add    $0x10,%esp
}
  801a2f:	89 d8                	mov    %ebx,%eax
  801a31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <accept>:
{
  801a38:	f3 0f 1e fb          	endbr32 
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	e8 4a ff ff ff       	call   801994 <fd2sockid>
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 1b                	js     801a69 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	ff 75 10             	pushl  0x10(%ebp)
  801a54:	ff 75 0c             	pushl  0xc(%ebp)
  801a57:	50                   	push   %eax
  801a58:	e8 22 01 00 00       	call   801b7f <nsipc_accept>
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 05                	js     801a69 <accept+0x31>
	return alloc_sockfd(r);
  801a64:	e8 5b ff ff ff       	call   8019c4 <alloc_sockfd>
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <bind>:
{
  801a6b:	f3 0f 1e fb          	endbr32 
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a75:	8b 45 08             	mov    0x8(%ebp),%eax
  801a78:	e8 17 ff ff ff       	call   801994 <fd2sockid>
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 12                	js     801a93 <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801a81:	83 ec 04             	sub    $0x4,%esp
  801a84:	ff 75 10             	pushl  0x10(%ebp)
  801a87:	ff 75 0c             	pushl  0xc(%ebp)
  801a8a:	50                   	push   %eax
  801a8b:	e8 45 01 00 00       	call   801bd5 <nsipc_bind>
  801a90:	83 c4 10             	add    $0x10,%esp
}
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <shutdown>:
{
  801a95:	f3 0f 1e fb          	endbr32 
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa2:	e8 ed fe ff ff       	call   801994 <fd2sockid>
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 0f                	js     801aba <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	ff 75 0c             	pushl  0xc(%ebp)
  801ab1:	50                   	push   %eax
  801ab2:	e8 57 01 00 00       	call   801c0e <nsipc_shutdown>
  801ab7:	83 c4 10             	add    $0x10,%esp
}
  801aba:	c9                   	leave  
  801abb:	c3                   	ret    

00801abc <connect>:
{
  801abc:	f3 0f 1e fb          	endbr32 
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	e8 c6 fe ff ff       	call   801994 <fd2sockid>
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 12                	js     801ae4 <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801ad2:	83 ec 04             	sub    $0x4,%esp
  801ad5:	ff 75 10             	pushl  0x10(%ebp)
  801ad8:	ff 75 0c             	pushl  0xc(%ebp)
  801adb:	50                   	push   %eax
  801adc:	e8 71 01 00 00       	call   801c52 <nsipc_connect>
  801ae1:	83 c4 10             	add    $0x10,%esp
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <listen>:
{
  801ae6:	f3 0f 1e fb          	endbr32 
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	e8 9c fe ff ff       	call   801994 <fd2sockid>
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 0f                	js     801b0b <listen+0x25>
	return nsipc_listen(r, backlog);
  801afc:	83 ec 08             	sub    $0x8,%esp
  801aff:	ff 75 0c             	pushl  0xc(%ebp)
  801b02:	50                   	push   %eax
  801b03:	e8 83 01 00 00       	call   801c8b <nsipc_listen>
  801b08:	83 c4 10             	add    $0x10,%esp
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <socket>:

int
socket(int domain, int type, int protocol)
{
  801b0d:	f3 0f 1e fb          	endbr32 
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b17:	ff 75 10             	pushl  0x10(%ebp)
  801b1a:	ff 75 0c             	pushl  0xc(%ebp)
  801b1d:	ff 75 08             	pushl  0x8(%ebp)
  801b20:	e8 65 02 00 00       	call   801d8a <nsipc_socket>
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 05                	js     801b31 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801b2c:	e8 93 fe ff ff       	call   8019c4 <alloc_sockfd>
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	53                   	push   %ebx
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b3c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b43:	74 26                	je     801b6b <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b45:	6a 07                	push   $0x7
  801b47:	68 00 60 80 00       	push   $0x806000
  801b4c:	53                   	push   %ebx
  801b4d:	ff 35 04 40 80 00    	pushl  0x804004
  801b53:	e8 12 08 00 00       	call   80236a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b58:	83 c4 0c             	add    $0xc,%esp
  801b5b:	6a 00                	push   $0x0
  801b5d:	6a 00                	push   $0x0
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 97 07 00 00       	call   8022fd <ipc_recv>
}
  801b66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	6a 02                	push   $0x2
  801b70:	e8 4d 08 00 00       	call   8023c2 <ipc_find_env>
  801b75:	a3 04 40 80 00       	mov    %eax,0x804004
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	eb c6                	jmp    801b45 <nsipc+0x12>

00801b7f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b7f:	f3 0f 1e fb          	endbr32 
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b93:	8b 06                	mov    (%esi),%eax
  801b95:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9f:	e8 8f ff ff ff       	call   801b33 <nsipc>
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	79 09                	jns    801bb3 <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801baa:	89 d8                	mov    %ebx,%eax
  801bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5e                   	pop    %esi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bb3:	83 ec 04             	sub    $0x4,%esp
  801bb6:	ff 35 10 60 80 00    	pushl  0x806010
  801bbc:	68 00 60 80 00       	push   $0x806000
  801bc1:	ff 75 0c             	pushl  0xc(%ebp)
  801bc4:	e8 5d ee ff ff       	call   800a26 <memmove>
		*addrlen = ret->ret_addrlen;
  801bc9:	a1 10 60 80 00       	mov    0x806010,%eax
  801bce:	89 06                	mov    %eax,(%esi)
  801bd0:	83 c4 10             	add    $0x10,%esp
	return r;
  801bd3:	eb d5                	jmp    801baa <nsipc_accept+0x2b>

00801bd5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bd5:	f3 0f 1e fb          	endbr32 
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 08             	sub    $0x8,%esp
  801be0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801beb:	53                   	push   %ebx
  801bec:	ff 75 0c             	pushl  0xc(%ebp)
  801bef:	68 04 60 80 00       	push   $0x806004
  801bf4:	e8 2d ee ff ff       	call   800a26 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bf9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bff:	b8 02 00 00 00       	mov    $0x2,%eax
  801c04:	e8 2a ff ff ff       	call   801b33 <nsipc>
}
  801c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    

00801c0e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c0e:	f3 0f 1e fb          	endbr32 
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c23:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c28:	b8 03 00 00 00       	mov    $0x3,%eax
  801c2d:	e8 01 ff ff ff       	call   801b33 <nsipc>
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <nsipc_close>:

int
nsipc_close(int s)
{
  801c34:	f3 0f 1e fb          	endbr32 
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c41:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c46:	b8 04 00 00 00       	mov    $0x4,%eax
  801c4b:	e8 e3 fe ff ff       	call   801b33 <nsipc>
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c52:	f3 0f 1e fb          	endbr32 
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	53                   	push   %ebx
  801c5a:	83 ec 08             	sub    $0x8,%esp
  801c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c68:	53                   	push   %ebx
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	68 04 60 80 00       	push   $0x806004
  801c71:	e8 b0 ed ff ff       	call   800a26 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c76:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c7c:	b8 05 00 00 00       	mov    $0x5,%eax
  801c81:	e8 ad fe ff ff       	call   801b33 <nsipc>
}
  801c86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c89:	c9                   	leave  
  801c8a:	c3                   	ret    

00801c8b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c8b:	f3 0f 1e fb          	endbr32 
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ca5:	b8 06 00 00 00       	mov    $0x6,%eax
  801caa:	e8 84 fe ff ff       	call   801b33 <nsipc>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cb1:	f3 0f 1e fb          	endbr32 
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	56                   	push   %esi
  801cb9:	53                   	push   %ebx
  801cba:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cc5:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ccb:	8b 45 14             	mov    0x14(%ebp),%eax
  801cce:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cd3:	b8 07 00 00 00       	mov    $0x7,%eax
  801cd8:	e8 56 fe ff ff       	call   801b33 <nsipc>
  801cdd:	89 c3                	mov    %eax,%ebx
  801cdf:	85 c0                	test   %eax,%eax
  801ce1:	78 26                	js     801d09 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801ce3:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801ce9:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801cee:	0f 4e c6             	cmovle %esi,%eax
  801cf1:	39 c3                	cmp    %eax,%ebx
  801cf3:	7f 1d                	jg     801d12 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cf5:	83 ec 04             	sub    $0x4,%esp
  801cf8:	53                   	push   %ebx
  801cf9:	68 00 60 80 00       	push   $0x806000
  801cfe:	ff 75 0c             	pushl  0xc(%ebp)
  801d01:	e8 20 ed ff ff       	call   800a26 <memmove>
  801d06:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d09:	89 d8                	mov    %ebx,%eax
  801d0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d12:	68 0f 2b 80 00       	push   $0x802b0f
  801d17:	68 77 2a 80 00       	push   $0x802a77
  801d1c:	6a 62                	push   $0x62
  801d1e:	68 24 2b 80 00       	push   $0x802b24
  801d23:	e8 8b 05 00 00       	call   8022b3 <_panic>

00801d28 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d28:	f3 0f 1e fb          	endbr32 
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 04             	sub    $0x4,%esp
  801d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d3e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d44:	7f 2e                	jg     801d74 <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	53                   	push   %ebx
  801d4a:	ff 75 0c             	pushl  0xc(%ebp)
  801d4d:	68 0c 60 80 00       	push   $0x80600c
  801d52:	e8 cf ec ff ff       	call   800a26 <memmove>
	nsipcbuf.send.req_size = size;
  801d57:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d5d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d60:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d65:	b8 08 00 00 00       	mov    $0x8,%eax
  801d6a:	e8 c4 fd ff ff       	call   801b33 <nsipc>
}
  801d6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    
	assert(size < 1600);
  801d74:	68 30 2b 80 00       	push   $0x802b30
  801d79:	68 77 2a 80 00       	push   $0x802a77
  801d7e:	6a 6d                	push   $0x6d
  801d80:	68 24 2b 80 00       	push   $0x802b24
  801d85:	e8 29 05 00 00       	call   8022b3 <_panic>

00801d8a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d8a:	f3 0f 1e fb          	endbr32 
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801da4:	8b 45 10             	mov    0x10(%ebp),%eax
  801da7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dac:	b8 09 00 00 00       	mov    $0x9,%eax
  801db1:	e8 7d fd ff ff       	call   801b33 <nsipc>
}
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801db8:	f3 0f 1e fb          	endbr32 
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dc4:	83 ec 0c             	sub    $0xc,%esp
  801dc7:	ff 75 08             	pushl  0x8(%ebp)
  801dca:	e8 cc f1 ff ff       	call   800f9b <fd2data>
  801dcf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dd1:	83 c4 08             	add    $0x8,%esp
  801dd4:	68 3c 2b 80 00       	push   $0x802b3c
  801dd9:	53                   	push   %ebx
  801dda:	e8 49 ea ff ff       	call   800828 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ddf:	8b 46 04             	mov    0x4(%esi),%eax
  801de2:	2b 06                	sub    (%esi),%eax
  801de4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801df1:	00 00 00 
	stat->st_dev = &devpipe;
  801df4:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801dfb:	30 80 00 
	return 0;
}
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801e03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e06:	5b                   	pop    %ebx
  801e07:	5e                   	pop    %esi
  801e08:	5d                   	pop    %ebp
  801e09:	c3                   	ret    

00801e0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e0a:	f3 0f 1e fb          	endbr32 
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	53                   	push   %ebx
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e18:	53                   	push   %ebx
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 bc ee ff ff       	call   800cdc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e20:	89 1c 24             	mov    %ebx,(%esp)
  801e23:	e8 73 f1 ff ff       	call   800f9b <fd2data>
  801e28:	83 c4 08             	add    $0x8,%esp
  801e2b:	50                   	push   %eax
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 a9 ee ff ff       	call   800cdc <sys_page_unmap>
}
  801e33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <_pipeisclosed>:
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	57                   	push   %edi
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	83 ec 1c             	sub    $0x1c,%esp
  801e41:	89 c7                	mov    %eax,%edi
  801e43:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e45:	a1 08 40 80 00       	mov    0x804008,%eax
  801e4a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	57                   	push   %edi
  801e51:	e8 a9 05 00 00       	call   8023ff <pageref>
  801e56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e59:	89 34 24             	mov    %esi,(%esp)
  801e5c:	e8 9e 05 00 00       	call   8023ff <pageref>
		nn = thisenv->env_runs;
  801e61:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e67:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	39 cb                	cmp    %ecx,%ebx
  801e6f:	74 1b                	je     801e8c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e71:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e74:	75 cf                	jne    801e45 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e76:	8b 42 58             	mov    0x58(%edx),%eax
  801e79:	6a 01                	push   $0x1
  801e7b:	50                   	push   %eax
  801e7c:	53                   	push   %ebx
  801e7d:	68 43 2b 80 00       	push   $0x802b43
  801e82:	e8 97 e3 ff ff       	call   80021e <cprintf>
  801e87:	83 c4 10             	add    $0x10,%esp
  801e8a:	eb b9                	jmp    801e45 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801e8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e8f:	0f 94 c0             	sete   %al
  801e92:	0f b6 c0             	movzbl %al,%eax
}
  801e95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <devpipe_write>:
{
  801e9d:	f3 0f 1e fb          	endbr32 
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	57                   	push   %edi
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
  801ea7:	83 ec 28             	sub    $0x28,%esp
  801eaa:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ead:	56                   	push   %esi
  801eae:	e8 e8 f0 ff ff       	call   800f9b <fd2data>
  801eb3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801ebd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ec0:	74 4f                	je     801f11 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ec2:	8b 43 04             	mov    0x4(%ebx),%eax
  801ec5:	8b 0b                	mov    (%ebx),%ecx
  801ec7:	8d 51 20             	lea    0x20(%ecx),%edx
  801eca:	39 d0                	cmp    %edx,%eax
  801ecc:	72 14                	jb     801ee2 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801ece:	89 da                	mov    %ebx,%edx
  801ed0:	89 f0                	mov    %esi,%eax
  801ed2:	e8 61 ff ff ff       	call   801e38 <_pipeisclosed>
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	75 3b                	jne    801f16 <devpipe_write+0x79>
			sys_yield();
  801edb:	e8 8e ed ff ff       	call   800c6e <sys_yield>
  801ee0:	eb e0                	jmp    801ec2 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ee5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ee9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801eec:	89 c2                	mov    %eax,%edx
  801eee:	c1 fa 1f             	sar    $0x1f,%edx
  801ef1:	89 d1                	mov    %edx,%ecx
  801ef3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ef6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ef9:	83 e2 1f             	and    $0x1f,%edx
  801efc:	29 ca                	sub    %ecx,%edx
  801efe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f06:	83 c0 01             	add    $0x1,%eax
  801f09:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f0c:	83 c7 01             	add    $0x1,%edi
  801f0f:	eb ac                	jmp    801ebd <devpipe_write+0x20>
	return i;
  801f11:	8b 45 10             	mov    0x10(%ebp),%eax
  801f14:	eb 05                	jmp    801f1b <devpipe_write+0x7e>
				return 0;
  801f16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5f                   	pop    %edi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <devpipe_read>:
{
  801f23:	f3 0f 1e fb          	endbr32 
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	57                   	push   %edi
  801f2b:	56                   	push   %esi
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 18             	sub    $0x18,%esp
  801f30:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f33:	57                   	push   %edi
  801f34:	e8 62 f0 ff ff       	call   800f9b <fd2data>
  801f39:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	be 00 00 00 00       	mov    $0x0,%esi
  801f43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f46:	75 14                	jne    801f5c <devpipe_read+0x39>
	return i;
  801f48:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4b:	eb 02                	jmp    801f4f <devpipe_read+0x2c>
				return i;
  801f4d:	89 f0                	mov    %esi,%eax
}
  801f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f52:	5b                   	pop    %ebx
  801f53:	5e                   	pop    %esi
  801f54:	5f                   	pop    %edi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    
			sys_yield();
  801f57:	e8 12 ed ff ff       	call   800c6e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f5c:	8b 03                	mov    (%ebx),%eax
  801f5e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f61:	75 18                	jne    801f7b <devpipe_read+0x58>
			if (i > 0)
  801f63:	85 f6                	test   %esi,%esi
  801f65:	75 e6                	jne    801f4d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801f67:	89 da                	mov    %ebx,%edx
  801f69:	89 f8                	mov    %edi,%eax
  801f6b:	e8 c8 fe ff ff       	call   801e38 <_pipeisclosed>
  801f70:	85 c0                	test   %eax,%eax
  801f72:	74 e3                	je     801f57 <devpipe_read+0x34>
				return 0;
  801f74:	b8 00 00 00 00       	mov    $0x0,%eax
  801f79:	eb d4                	jmp    801f4f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f7b:	99                   	cltd   
  801f7c:	c1 ea 1b             	shr    $0x1b,%edx
  801f7f:	01 d0                	add    %edx,%eax
  801f81:	83 e0 1f             	and    $0x1f,%eax
  801f84:	29 d0                	sub    %edx,%eax
  801f86:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f8e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f91:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f94:	83 c6 01             	add    $0x1,%esi
  801f97:	eb aa                	jmp    801f43 <devpipe_read+0x20>

00801f99 <pipe>:
{
  801f99:	f3 0f 1e fb          	endbr32 
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	56                   	push   %esi
  801fa1:	53                   	push   %ebx
  801fa2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa8:	50                   	push   %eax
  801fa9:	e8 08 f0 ff ff       	call   800fb6 <fd_alloc>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	0f 88 23 01 00 00    	js     8020de <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fbb:	83 ec 04             	sub    $0x4,%esp
  801fbe:	68 07 04 00 00       	push   $0x407
  801fc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 c4 ec ff ff       	call   800c91 <sys_page_alloc>
  801fcd:	89 c3                	mov    %eax,%ebx
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	0f 88 04 01 00 00    	js     8020de <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801fda:	83 ec 0c             	sub    $0xc,%esp
  801fdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fe0:	50                   	push   %eax
  801fe1:	e8 d0 ef ff ff       	call   800fb6 <fd_alloc>
  801fe6:	89 c3                	mov    %eax,%ebx
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	85 c0                	test   %eax,%eax
  801fed:	0f 88 db 00 00 00    	js     8020ce <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff3:	83 ec 04             	sub    $0x4,%esp
  801ff6:	68 07 04 00 00       	push   $0x407
  801ffb:	ff 75 f0             	pushl  -0x10(%ebp)
  801ffe:	6a 00                	push   $0x0
  802000:	e8 8c ec ff ff       	call   800c91 <sys_page_alloc>
  802005:	89 c3                	mov    %eax,%ebx
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	85 c0                	test   %eax,%eax
  80200c:	0f 88 bc 00 00 00    	js     8020ce <pipe+0x135>
	va = fd2data(fd0);
  802012:	83 ec 0c             	sub    $0xc,%esp
  802015:	ff 75 f4             	pushl  -0xc(%ebp)
  802018:	e8 7e ef ff ff       	call   800f9b <fd2data>
  80201d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201f:	83 c4 0c             	add    $0xc,%esp
  802022:	68 07 04 00 00       	push   $0x407
  802027:	50                   	push   %eax
  802028:	6a 00                	push   $0x0
  80202a:	e8 62 ec ff ff       	call   800c91 <sys_page_alloc>
  80202f:	89 c3                	mov    %eax,%ebx
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	0f 88 82 00 00 00    	js     8020be <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80203c:	83 ec 0c             	sub    $0xc,%esp
  80203f:	ff 75 f0             	pushl  -0x10(%ebp)
  802042:	e8 54 ef ff ff       	call   800f9b <fd2data>
  802047:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80204e:	50                   	push   %eax
  80204f:	6a 00                	push   $0x0
  802051:	56                   	push   %esi
  802052:	6a 00                	push   $0x0
  802054:	e8 5e ec ff ff       	call   800cb7 <sys_page_map>
  802059:	89 c3                	mov    %eax,%ebx
  80205b:	83 c4 20             	add    $0x20,%esp
  80205e:	85 c0                	test   %eax,%eax
  802060:	78 4e                	js     8020b0 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802062:	a1 7c 30 80 00       	mov    0x80307c,%eax
  802067:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80206a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80206c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80206f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802076:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802079:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80207b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80207e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802085:	83 ec 0c             	sub    $0xc,%esp
  802088:	ff 75 f4             	pushl  -0xc(%ebp)
  80208b:	e8 f7 ee ff ff       	call   800f87 <fd2num>
  802090:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802093:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802095:	83 c4 04             	add    $0x4,%esp
  802098:	ff 75 f0             	pushl  -0x10(%ebp)
  80209b:	e8 e7 ee ff ff       	call   800f87 <fd2num>
  8020a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020ae:	eb 2e                	jmp    8020de <pipe+0x145>
	sys_page_unmap(0, va);
  8020b0:	83 ec 08             	sub    $0x8,%esp
  8020b3:	56                   	push   %esi
  8020b4:	6a 00                	push   $0x0
  8020b6:	e8 21 ec ff ff       	call   800cdc <sys_page_unmap>
  8020bb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020be:	83 ec 08             	sub    $0x8,%esp
  8020c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c4:	6a 00                	push   $0x0
  8020c6:	e8 11 ec ff ff       	call   800cdc <sys_page_unmap>
  8020cb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020ce:	83 ec 08             	sub    $0x8,%esp
  8020d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 01 ec ff ff       	call   800cdc <sys_page_unmap>
  8020db:	83 c4 10             	add    $0x10,%esp
}
  8020de:	89 d8                	mov    %ebx,%eax
  8020e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    

008020e7 <pipeisclosed>:
{
  8020e7:	f3 0f 1e fb          	endbr32 
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f4:	50                   	push   %eax
  8020f5:	ff 75 08             	pushl  0x8(%ebp)
  8020f8:	e8 0f ef ff ff       	call   80100c <fd_lookup>
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	85 c0                	test   %eax,%eax
  802102:	78 18                	js     80211c <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802104:	83 ec 0c             	sub    $0xc,%esp
  802107:	ff 75 f4             	pushl  -0xc(%ebp)
  80210a:	e8 8c ee ff ff       	call   800f9b <fd2data>
  80210f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802114:	e8 1f fd ff ff       	call   801e38 <_pipeisclosed>
  802119:	83 c4 10             	add    $0x10,%esp
}
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80211e:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802122:	b8 00 00 00 00       	mov    $0x0,%eax
  802127:	c3                   	ret    

00802128 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802128:	f3 0f 1e fb          	endbr32 
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802132:	68 5b 2b 80 00       	push   $0x802b5b
  802137:	ff 75 0c             	pushl  0xc(%ebp)
  80213a:	e8 e9 e6 ff ff       	call   800828 <strcpy>
	return 0;
}
  80213f:	b8 00 00 00 00       	mov    $0x0,%eax
  802144:	c9                   	leave  
  802145:	c3                   	ret    

00802146 <devcons_write>:
{
  802146:	f3 0f 1e fb          	endbr32 
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	57                   	push   %edi
  80214e:	56                   	push   %esi
  80214f:	53                   	push   %ebx
  802150:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802156:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80215b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802161:	3b 75 10             	cmp    0x10(%ebp),%esi
  802164:	73 31                	jae    802197 <devcons_write+0x51>
		m = n - tot;
  802166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802169:	29 f3                	sub    %esi,%ebx
  80216b:	83 fb 7f             	cmp    $0x7f,%ebx
  80216e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802173:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802176:	83 ec 04             	sub    $0x4,%esp
  802179:	53                   	push   %ebx
  80217a:	89 f0                	mov    %esi,%eax
  80217c:	03 45 0c             	add    0xc(%ebp),%eax
  80217f:	50                   	push   %eax
  802180:	57                   	push   %edi
  802181:	e8 a0 e8 ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  802186:	83 c4 08             	add    $0x8,%esp
  802189:	53                   	push   %ebx
  80218a:	57                   	push   %edi
  80218b:	e8 52 ea ff ff       	call   800be2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802190:	01 de                	add    %ebx,%esi
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	eb ca                	jmp    802161 <devcons_write+0x1b>
}
  802197:	89 f0                	mov    %esi,%eax
  802199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219c:	5b                   	pop    %ebx
  80219d:	5e                   	pop    %esi
  80219e:	5f                   	pop    %edi
  80219f:	5d                   	pop    %ebp
  8021a0:	c3                   	ret    

008021a1 <devcons_read>:
{
  8021a1:	f3 0f 1e fb          	endbr32 
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 08             	sub    $0x8,%esp
  8021ab:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021b4:	74 21                	je     8021d7 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8021b6:	e8 49 ea ff ff       	call   800c04 <sys_cgetc>
  8021bb:	85 c0                	test   %eax,%eax
  8021bd:	75 07                	jne    8021c6 <devcons_read+0x25>
		sys_yield();
  8021bf:	e8 aa ea ff ff       	call   800c6e <sys_yield>
  8021c4:	eb f0                	jmp    8021b6 <devcons_read+0x15>
	if (c < 0)
  8021c6:	78 0f                	js     8021d7 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8021c8:	83 f8 04             	cmp    $0x4,%eax
  8021cb:	74 0c                	je     8021d9 <devcons_read+0x38>
	*(char*)vbuf = c;
  8021cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d0:	88 02                	mov    %al,(%edx)
	return 1;
  8021d2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021d7:	c9                   	leave  
  8021d8:	c3                   	ret    
		return 0;
  8021d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021de:	eb f7                	jmp    8021d7 <devcons_read+0x36>

008021e0 <cputchar>:
{
  8021e0:	f3 0f 1e fb          	endbr32 
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ed:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021f0:	6a 01                	push   $0x1
  8021f2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f5:	50                   	push   %eax
  8021f6:	e8 e7 e9 ff ff       	call   800be2 <sys_cputs>
}
  8021fb:	83 c4 10             	add    $0x10,%esp
  8021fe:	c9                   	leave  
  8021ff:	c3                   	ret    

00802200 <getchar>:
{
  802200:	f3 0f 1e fb          	endbr32 
  802204:	55                   	push   %ebp
  802205:	89 e5                	mov    %esp,%ebp
  802207:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80220a:	6a 01                	push   $0x1
  80220c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220f:	50                   	push   %eax
  802210:	6a 00                	push   $0x0
  802212:	e8 7d f0 ff ff       	call   801294 <read>
	if (r < 0)
  802217:	83 c4 10             	add    $0x10,%esp
  80221a:	85 c0                	test   %eax,%eax
  80221c:	78 06                	js     802224 <getchar+0x24>
	if (r < 1)
  80221e:	74 06                	je     802226 <getchar+0x26>
	return c;
  802220:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802224:	c9                   	leave  
  802225:	c3                   	ret    
		return -E_EOF;
  802226:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80222b:	eb f7                	jmp    802224 <getchar+0x24>

0080222d <iscons>:
{
  80222d:	f3 0f 1e fb          	endbr32 
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223a:	50                   	push   %eax
  80223b:	ff 75 08             	pushl  0x8(%ebp)
  80223e:	e8 c9 ed ff ff       	call   80100c <fd_lookup>
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	85 c0                	test   %eax,%eax
  802248:	78 11                	js     80225b <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80224a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224d:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802253:	39 10                	cmp    %edx,(%eax)
  802255:	0f 94 c0             	sete   %al
  802258:	0f b6 c0             	movzbl %al,%eax
}
  80225b:	c9                   	leave  
  80225c:	c3                   	ret    

0080225d <opencons>:
{
  80225d:	f3 0f 1e fb          	endbr32 
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226a:	50                   	push   %eax
  80226b:	e8 46 ed ff ff       	call   800fb6 <fd_alloc>
  802270:	83 c4 10             	add    $0x10,%esp
  802273:	85 c0                	test   %eax,%eax
  802275:	78 3a                	js     8022b1 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802277:	83 ec 04             	sub    $0x4,%esp
  80227a:	68 07 04 00 00       	push   $0x407
  80227f:	ff 75 f4             	pushl  -0xc(%ebp)
  802282:	6a 00                	push   $0x0
  802284:	e8 08 ea ff ff       	call   800c91 <sys_page_alloc>
  802289:	83 c4 10             	add    $0x10,%esp
  80228c:	85 c0                	test   %eax,%eax
  80228e:	78 21                	js     8022b1 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802290:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802293:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802299:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80229b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022a5:	83 ec 0c             	sub    $0xc,%esp
  8022a8:	50                   	push   %eax
  8022a9:	e8 d9 ec ff ff       	call   800f87 <fd2num>
  8022ae:	83 c4 10             	add    $0x10,%esp
}
  8022b1:	c9                   	leave  
  8022b2:	c3                   	ret    

008022b3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022b3:	f3 0f 1e fb          	endbr32 
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	56                   	push   %esi
  8022bb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022bf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022c5:	e8 81 e9 ff ff       	call   800c4b <sys_getenvid>
  8022ca:	83 ec 0c             	sub    $0xc,%esp
  8022cd:	ff 75 0c             	pushl  0xc(%ebp)
  8022d0:	ff 75 08             	pushl  0x8(%ebp)
  8022d3:	56                   	push   %esi
  8022d4:	50                   	push   %eax
  8022d5:	68 68 2b 80 00       	push   $0x802b68
  8022da:	e8 3f df ff ff       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022df:	83 c4 18             	add    $0x18,%esp
  8022e2:	53                   	push   %ebx
  8022e3:	ff 75 10             	pushl  0x10(%ebp)
  8022e6:	e8 de de ff ff       	call   8001c9 <vcprintf>
	cprintf("\n");
  8022eb:	c7 04 24 b0 26 80 00 	movl   $0x8026b0,(%esp)
  8022f2:	e8 27 df ff ff       	call   80021e <cprintf>
  8022f7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022fa:	cc                   	int3   
  8022fb:	eb fd                	jmp    8022fa <_panic+0x47>

008022fd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022fd:	f3 0f 1e fb          	endbr32 
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	56                   	push   %esi
  802305:	53                   	push   %ebx
  802306:	8b 75 08             	mov    0x8(%ebp),%esi
  802309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  80230f:	85 c0                	test   %eax,%eax
  802311:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802316:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  802319:	83 ec 0c             	sub    $0xc,%esp
  80231c:	50                   	push   %eax
  80231d:	e8 75 ea ff ff       	call   800d97 <sys_ipc_recv>
  802322:	83 c4 10             	add    $0x10,%esp
  802325:	85 c0                	test   %eax,%eax
  802327:	75 2b                	jne    802354 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  802329:	85 f6                	test   %esi,%esi
  80232b:	74 0a                	je     802337 <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  80232d:	a1 08 40 80 00       	mov    0x804008,%eax
  802332:	8b 40 74             	mov    0x74(%eax),%eax
  802335:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  802337:	85 db                	test   %ebx,%ebx
  802339:	74 0a                	je     802345 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80233b:	a1 08 40 80 00       	mov    0x804008,%eax
  802340:	8b 40 78             	mov    0x78(%eax),%eax
  802343:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  802345:	a1 08 40 80 00       	mov    0x804008,%eax
  80234a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80234d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  802354:	85 f6                	test   %esi,%esi
  802356:	74 06                	je     80235e <ipc_recv+0x61>
  802358:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  80235e:	85 db                	test   %ebx,%ebx
  802360:	74 eb                	je     80234d <ipc_recv+0x50>
  802362:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802368:	eb e3                	jmp    80234d <ipc_recv+0x50>

0080236a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80236a:	f3 0f 1e fb          	endbr32 
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
  802374:	83 ec 0c             	sub    $0xc,%esp
  802377:	8b 7d 08             	mov    0x8(%ebp),%edi
  80237a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80237d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  802380:	85 db                	test   %ebx,%ebx
  802382:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802387:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  80238a:	ff 75 14             	pushl  0x14(%ebp)
  80238d:	53                   	push   %ebx
  80238e:	56                   	push   %esi
  80238f:	57                   	push   %edi
  802390:	e8 db e9 ff ff       	call   800d70 <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  802395:	83 c4 10             	add    $0x10,%esp
  802398:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80239b:	75 07                	jne    8023a4 <ipc_send+0x3a>
			sys_yield();
  80239d:	e8 cc e8 ff ff       	call   800c6e <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8023a2:	eb e6                	jmp    80238a <ipc_send+0x20>
		}
		else if (ret == 0)
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	75 08                	jne    8023b0 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  8023a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ab:	5b                   	pop    %ebx
  8023ac:	5e                   	pop    %esi
  8023ad:	5f                   	pop    %edi
  8023ae:	5d                   	pop    %ebp
  8023af:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  8023b0:	50                   	push   %eax
  8023b1:	68 8b 2b 80 00       	push   $0x802b8b
  8023b6:	6a 48                	push   $0x48
  8023b8:	68 99 2b 80 00       	push   $0x802b99
  8023bd:	e8 f1 fe ff ff       	call   8022b3 <_panic>

008023c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023c2:	f3 0f 1e fb          	endbr32 
  8023c6:	55                   	push   %ebp
  8023c7:	89 e5                	mov    %esp,%ebp
  8023c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023d1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023d4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023da:	8b 52 50             	mov    0x50(%edx),%edx
  8023dd:	39 ca                	cmp    %ecx,%edx
  8023df:	74 11                	je     8023f2 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8023e1:	83 c0 01             	add    $0x1,%eax
  8023e4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023e9:	75 e6                	jne    8023d1 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8023eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8023f0:	eb 0b                	jmp    8023fd <ipc_find_env+0x3b>
			return envs[i].env_id;
  8023f2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023f5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023fa:	8b 40 48             	mov    0x48(%eax),%eax
}
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023ff:	f3 0f 1e fb          	endbr32 
  802403:	55                   	push   %ebp
  802404:	89 e5                	mov    %esp,%ebp
  802406:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802409:	89 c2                	mov    %eax,%edx
  80240b:	c1 ea 16             	shr    $0x16,%edx
  80240e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802415:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80241a:	f6 c1 01             	test   $0x1,%cl
  80241d:	74 1c                	je     80243b <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80241f:	c1 e8 0c             	shr    $0xc,%eax
  802422:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802429:	a8 01                	test   $0x1,%al
  80242b:	74 0e                	je     80243b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80242d:	c1 e8 0c             	shr    $0xc,%eax
  802430:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802437:	ef 
  802438:	0f b7 d2             	movzwl %dx,%edx
}
  80243b:	89 d0                	mov    %edx,%eax
  80243d:	5d                   	pop    %ebp
  80243e:	c3                   	ret    
  80243f:	90                   	nop

00802440 <__udivdi3>:
  802440:	f3 0f 1e fb          	endbr32 
  802444:	55                   	push   %ebp
  802445:	57                   	push   %edi
  802446:	56                   	push   %esi
  802447:	53                   	push   %ebx
  802448:	83 ec 1c             	sub    $0x1c,%esp
  80244b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80244f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802453:	8b 74 24 34          	mov    0x34(%esp),%esi
  802457:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80245b:	85 d2                	test   %edx,%edx
  80245d:	75 19                	jne    802478 <__udivdi3+0x38>
  80245f:	39 f3                	cmp    %esi,%ebx
  802461:	76 4d                	jbe    8024b0 <__udivdi3+0x70>
  802463:	31 ff                	xor    %edi,%edi
  802465:	89 e8                	mov    %ebp,%eax
  802467:	89 f2                	mov    %esi,%edx
  802469:	f7 f3                	div    %ebx
  80246b:	89 fa                	mov    %edi,%edx
  80246d:	83 c4 1c             	add    $0x1c,%esp
  802470:	5b                   	pop    %ebx
  802471:	5e                   	pop    %esi
  802472:	5f                   	pop    %edi
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    
  802475:	8d 76 00             	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	76 14                	jbe    802490 <__udivdi3+0x50>
  80247c:	31 ff                	xor    %edi,%edi
  80247e:	31 c0                	xor    %eax,%eax
  802480:	89 fa                	mov    %edi,%edx
  802482:	83 c4 1c             	add    $0x1c,%esp
  802485:	5b                   	pop    %ebx
  802486:	5e                   	pop    %esi
  802487:	5f                   	pop    %edi
  802488:	5d                   	pop    %ebp
  802489:	c3                   	ret    
  80248a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802490:	0f bd fa             	bsr    %edx,%edi
  802493:	83 f7 1f             	xor    $0x1f,%edi
  802496:	75 48                	jne    8024e0 <__udivdi3+0xa0>
  802498:	39 f2                	cmp    %esi,%edx
  80249a:	72 06                	jb     8024a2 <__udivdi3+0x62>
  80249c:	31 c0                	xor    %eax,%eax
  80249e:	39 eb                	cmp    %ebp,%ebx
  8024a0:	77 de                	ja     802480 <__udivdi3+0x40>
  8024a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a7:	eb d7                	jmp    802480 <__udivdi3+0x40>
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	89 d9                	mov    %ebx,%ecx
  8024b2:	85 db                	test   %ebx,%ebx
  8024b4:	75 0b                	jne    8024c1 <__udivdi3+0x81>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f3                	div    %ebx
  8024bf:	89 c1                	mov    %eax,%ecx
  8024c1:	31 d2                	xor    %edx,%edx
  8024c3:	89 f0                	mov    %esi,%eax
  8024c5:	f7 f1                	div    %ecx
  8024c7:	89 c6                	mov    %eax,%esi
  8024c9:	89 e8                	mov    %ebp,%eax
  8024cb:	89 f7                	mov    %esi,%edi
  8024cd:	f7 f1                	div    %ecx
  8024cf:	89 fa                	mov    %edi,%edx
  8024d1:	83 c4 1c             	add    $0x1c,%esp
  8024d4:	5b                   	pop    %ebx
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	89 f9                	mov    %edi,%ecx
  8024e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8024e7:	29 f8                	sub    %edi,%eax
  8024e9:	d3 e2                	shl    %cl,%edx
  8024eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024ef:	89 c1                	mov    %eax,%ecx
  8024f1:	89 da                	mov    %ebx,%edx
  8024f3:	d3 ea                	shr    %cl,%edx
  8024f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024f9:	09 d1                	or     %edx,%ecx
  8024fb:	89 f2                	mov    %esi,%edx
  8024fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802501:	89 f9                	mov    %edi,%ecx
  802503:	d3 e3                	shl    %cl,%ebx
  802505:	89 c1                	mov    %eax,%ecx
  802507:	d3 ea                	shr    %cl,%edx
  802509:	89 f9                	mov    %edi,%ecx
  80250b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80250f:	89 eb                	mov    %ebp,%ebx
  802511:	d3 e6                	shl    %cl,%esi
  802513:	89 c1                	mov    %eax,%ecx
  802515:	d3 eb                	shr    %cl,%ebx
  802517:	09 de                	or     %ebx,%esi
  802519:	89 f0                	mov    %esi,%eax
  80251b:	f7 74 24 08          	divl   0x8(%esp)
  80251f:	89 d6                	mov    %edx,%esi
  802521:	89 c3                	mov    %eax,%ebx
  802523:	f7 64 24 0c          	mull   0xc(%esp)
  802527:	39 d6                	cmp    %edx,%esi
  802529:	72 15                	jb     802540 <__udivdi3+0x100>
  80252b:	89 f9                	mov    %edi,%ecx
  80252d:	d3 e5                	shl    %cl,%ebp
  80252f:	39 c5                	cmp    %eax,%ebp
  802531:	73 04                	jae    802537 <__udivdi3+0xf7>
  802533:	39 d6                	cmp    %edx,%esi
  802535:	74 09                	je     802540 <__udivdi3+0x100>
  802537:	89 d8                	mov    %ebx,%eax
  802539:	31 ff                	xor    %edi,%edi
  80253b:	e9 40 ff ff ff       	jmp    802480 <__udivdi3+0x40>
  802540:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802543:	31 ff                	xor    %edi,%edi
  802545:	e9 36 ff ff ff       	jmp    802480 <__udivdi3+0x40>
  80254a:	66 90                	xchg   %ax,%ax
  80254c:	66 90                	xchg   %ax,%ax
  80254e:	66 90                	xchg   %ax,%ax

00802550 <__umoddi3>:
  802550:	f3 0f 1e fb          	endbr32 
  802554:	55                   	push   %ebp
  802555:	57                   	push   %edi
  802556:	56                   	push   %esi
  802557:	53                   	push   %ebx
  802558:	83 ec 1c             	sub    $0x1c,%esp
  80255b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80255f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802563:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802567:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80256b:	85 c0                	test   %eax,%eax
  80256d:	75 19                	jne    802588 <__umoddi3+0x38>
  80256f:	39 df                	cmp    %ebx,%edi
  802571:	76 5d                	jbe    8025d0 <__umoddi3+0x80>
  802573:	89 f0                	mov    %esi,%eax
  802575:	89 da                	mov    %ebx,%edx
  802577:	f7 f7                	div    %edi
  802579:	89 d0                	mov    %edx,%eax
  80257b:	31 d2                	xor    %edx,%edx
  80257d:	83 c4 1c             	add    $0x1c,%esp
  802580:	5b                   	pop    %ebx
  802581:	5e                   	pop    %esi
  802582:	5f                   	pop    %edi
  802583:	5d                   	pop    %ebp
  802584:	c3                   	ret    
  802585:	8d 76 00             	lea    0x0(%esi),%esi
  802588:	89 f2                	mov    %esi,%edx
  80258a:	39 d8                	cmp    %ebx,%eax
  80258c:	76 12                	jbe    8025a0 <__umoddi3+0x50>
  80258e:	89 f0                	mov    %esi,%eax
  802590:	89 da                	mov    %ebx,%edx
  802592:	83 c4 1c             	add    $0x1c,%esp
  802595:	5b                   	pop    %ebx
  802596:	5e                   	pop    %esi
  802597:	5f                   	pop    %edi
  802598:	5d                   	pop    %ebp
  802599:	c3                   	ret    
  80259a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a0:	0f bd e8             	bsr    %eax,%ebp
  8025a3:	83 f5 1f             	xor    $0x1f,%ebp
  8025a6:	75 50                	jne    8025f8 <__umoddi3+0xa8>
  8025a8:	39 d8                	cmp    %ebx,%eax
  8025aa:	0f 82 e0 00 00 00    	jb     802690 <__umoddi3+0x140>
  8025b0:	89 d9                	mov    %ebx,%ecx
  8025b2:	39 f7                	cmp    %esi,%edi
  8025b4:	0f 86 d6 00 00 00    	jbe    802690 <__umoddi3+0x140>
  8025ba:	89 d0                	mov    %edx,%eax
  8025bc:	89 ca                	mov    %ecx,%edx
  8025be:	83 c4 1c             	add    $0x1c,%esp
  8025c1:	5b                   	pop    %ebx
  8025c2:	5e                   	pop    %esi
  8025c3:	5f                   	pop    %edi
  8025c4:	5d                   	pop    %ebp
  8025c5:	c3                   	ret    
  8025c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025cd:	8d 76 00             	lea    0x0(%esi),%esi
  8025d0:	89 fd                	mov    %edi,%ebp
  8025d2:	85 ff                	test   %edi,%edi
  8025d4:	75 0b                	jne    8025e1 <__umoddi3+0x91>
  8025d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	f7 f7                	div    %edi
  8025df:	89 c5                	mov    %eax,%ebp
  8025e1:	89 d8                	mov    %ebx,%eax
  8025e3:	31 d2                	xor    %edx,%edx
  8025e5:	f7 f5                	div    %ebp
  8025e7:	89 f0                	mov    %esi,%eax
  8025e9:	f7 f5                	div    %ebp
  8025eb:	89 d0                	mov    %edx,%eax
  8025ed:	31 d2                	xor    %edx,%edx
  8025ef:	eb 8c                	jmp    80257d <__umoddi3+0x2d>
  8025f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8025ff:	29 ea                	sub    %ebp,%edx
  802601:	d3 e0                	shl    %cl,%eax
  802603:	89 44 24 08          	mov    %eax,0x8(%esp)
  802607:	89 d1                	mov    %edx,%ecx
  802609:	89 f8                	mov    %edi,%eax
  80260b:	d3 e8                	shr    %cl,%eax
  80260d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802611:	89 54 24 04          	mov    %edx,0x4(%esp)
  802615:	8b 54 24 04          	mov    0x4(%esp),%edx
  802619:	09 c1                	or     %eax,%ecx
  80261b:	89 d8                	mov    %ebx,%eax
  80261d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802621:	89 e9                	mov    %ebp,%ecx
  802623:	d3 e7                	shl    %cl,%edi
  802625:	89 d1                	mov    %edx,%ecx
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80262f:	d3 e3                	shl    %cl,%ebx
  802631:	89 c7                	mov    %eax,%edi
  802633:	89 d1                	mov    %edx,%ecx
  802635:	89 f0                	mov    %esi,%eax
  802637:	d3 e8                	shr    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	89 fa                	mov    %edi,%edx
  80263d:	d3 e6                	shl    %cl,%esi
  80263f:	09 d8                	or     %ebx,%eax
  802641:	f7 74 24 08          	divl   0x8(%esp)
  802645:	89 d1                	mov    %edx,%ecx
  802647:	89 f3                	mov    %esi,%ebx
  802649:	f7 64 24 0c          	mull   0xc(%esp)
  80264d:	89 c6                	mov    %eax,%esi
  80264f:	89 d7                	mov    %edx,%edi
  802651:	39 d1                	cmp    %edx,%ecx
  802653:	72 06                	jb     80265b <__umoddi3+0x10b>
  802655:	75 10                	jne    802667 <__umoddi3+0x117>
  802657:	39 c3                	cmp    %eax,%ebx
  802659:	73 0c                	jae    802667 <__umoddi3+0x117>
  80265b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80265f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802663:	89 d7                	mov    %edx,%edi
  802665:	89 c6                	mov    %eax,%esi
  802667:	89 ca                	mov    %ecx,%edx
  802669:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80266e:	29 f3                	sub    %esi,%ebx
  802670:	19 fa                	sbb    %edi,%edx
  802672:	89 d0                	mov    %edx,%eax
  802674:	d3 e0                	shl    %cl,%eax
  802676:	89 e9                	mov    %ebp,%ecx
  802678:	d3 eb                	shr    %cl,%ebx
  80267a:	d3 ea                	shr    %cl,%edx
  80267c:	09 d8                	or     %ebx,%eax
  80267e:	83 c4 1c             	add    $0x1c,%esp
  802681:	5b                   	pop    %ebx
  802682:	5e                   	pop    %esi
  802683:	5f                   	pop    %edi
  802684:	5d                   	pop    %ebp
  802685:	c3                   	ret    
  802686:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80268d:	8d 76 00             	lea    0x0(%esi),%esi
  802690:	29 fe                	sub    %edi,%esi
  802692:	19 c3                	sbb    %eax,%ebx
  802694:	89 f2                	mov    %esi,%edx
  802696:	89 d9                	mov    %ebx,%ecx
  802698:	e9 1d ff ff ff       	jmp    8025ba <__umoddi3+0x6a>
