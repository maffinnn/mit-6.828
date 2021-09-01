
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  800040:	e8 8a 0e 00 00       	call   800ecf <fork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 4f                	jne    80009b <umain+0x68>
		ipc_send(who, 0, 0, 0);
	}

	// child process
	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	6a 00                	push   $0x0
  800054:	6a 00                	push   $0x0
  800056:	56                   	push   %esi
  800057:	e8 04 10 00 00       	call   801060 <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 90 0b 00 00       	call   800bf6 <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 16 27 80 00       	push   $0x802716
  80006e:	e8 56 01 00 00       	call   8001c9 <cprintf>
		if (i == 10)
  800073:	83 c4 20             	add    $0x20,%esp
  800076:	83 fb 0a             	cmp    $0xa,%ebx
  800079:	74 18                	je     800093 <umain+0x60>
			return;
		i++;
  80007b:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007e:	6a 00                	push   $0x0
  800080:	6a 00                	push   $0x0
  800082:	53                   	push   %ebx
  800083:	ff 75 e4             	pushl  -0x1c(%ebp)
  800086:	e8 42 10 00 00       	call   8010cd <ipc_send>
		if (i == 10)
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 fb 0a             	cmp    $0xa,%ebx
  800091:	75 bc                	jne    80004f <umain+0x1c>
			return;
	}

}
  800093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5f                   	pop    %edi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
  80009b:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80009d:	e8 54 0b 00 00       	call   800bf6 <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 00 27 80 00       	push   $0x802700
  8000ac:	e8 18 01 00 00       	call   8001c9 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 0e 10 00 00       	call   8010cd <ipc_send>
  8000bf:	83 c4 20             	add    $0x20,%esp
  8000c2:	eb 88                	jmp    80004c <umain+0x19>

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d3:	e8 1e 0b 00 00       	call   800bf6 <sys_getenvid>
  8000d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e5:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ea:	85 db                	test   %ebx,%ebx
  8000ec:	7e 07                	jle    8000f5 <libmain+0x31>
		binaryname = argv[0];
  8000ee:	8b 06                	mov    (%esi),%eax
  8000f0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	e8 34 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ff:	e8 0a 00 00 00       	call   80010e <exit>
}
  800104:	83 c4 10             	add    $0x10,%esp
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010e:	f3 0f 1e fb          	endbr32 
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	83 ec 08             	sub    $0x8,%esp
	// cprintf("[%08x] called exit\n", thisenv->env_id);
	close_all();
  800118:	e8 39 12 00 00       	call   801356 <close_all>
	sys_env_destroy(0);
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	6a 00                	push   $0x0
  800122:	e8 ab 0a 00 00       	call   800bd2 <sys_env_destroy>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012c:	f3 0f 1e fb          	endbr32 
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	53                   	push   %ebx
  800134:	83 ec 04             	sub    $0x4,%esp
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013a:	8b 13                	mov    (%ebx),%edx
  80013c:	8d 42 01             	lea    0x1(%edx),%eax
  80013f:	89 03                	mov    %eax,(%ebx)
  800141:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800144:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800148:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014d:	74 09                	je     800158 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 24 0a 00 00       	call   800b8d <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	eb db                	jmp    80014f <putch+0x23>

00800174 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800174:	f3 0f 1e fb          	endbr32 
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800181:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800188:	00 00 00 
	b.cnt = 0;
  80018b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800192:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800195:	ff 75 0c             	pushl  0xc(%ebp)
  800198:	ff 75 08             	pushl  0x8(%ebp)
  80019b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a1:	50                   	push   %eax
  8001a2:	68 2c 01 80 00       	push   $0x80012c
  8001a7:	e8 20 01 00 00       	call   8002cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ac:	83 c4 08             	add    $0x8,%esp
  8001af:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bb:	50                   	push   %eax
  8001bc:	e8 cc 09 00 00       	call   800b8d <sys_cputs>

	return b.cnt;
}
  8001c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c9:	f3 0f 1e fb          	endbr32 
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d6:	50                   	push   %eax
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	e8 95 ff ff ff       	call   800174 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <printnum>:
// padc --pad char
// putdat --put digit at(??)
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 1c             	sub    $0x1c,%esp
  8001ea:	89 c7                	mov    %eax,%edi
  8001ec:	89 d6                	mov    %edx,%esi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f4:	89 d1                	mov    %edx,%ecx
  8001f6:	89 c2                	mov    %eax,%edx
  8001f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800201:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {// 非个位数 即least significant digit
  800204:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800207:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80020e:	39 c2                	cmp    %eax,%edx
  800210:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800213:	72 3e                	jb     800253 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	ff 75 18             	pushl  0x18(%ebp)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	53                   	push   %ebx
  80021f:	50                   	push   %eax
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 5c 22 00 00       	call   802490 <__udivdi3>
  800234:	83 c4 18             	add    $0x18,%esp
  800237:	52                   	push   %edx
  800238:	50                   	push   %eax
  800239:	89 f2                	mov    %esi,%edx
  80023b:	89 f8                	mov    %edi,%eax
  80023d:	e8 9f ff ff ff       	call   8001e1 <printnum>
  800242:	83 c4 20             	add    $0x20,%esp
  800245:	eb 13                	jmp    80025a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	ff 75 18             	pushl  0x18(%ebp)
  80024e:	ff d7                	call   *%edi
  800250:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800253:	83 eb 01             	sub    $0x1,%ebx
  800256:	85 db                	test   %ebx,%ebx
  800258:	7f ed                	jg     800247 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	56                   	push   %esi
  80025e:	83 ec 04             	sub    $0x4,%esp
  800261:	ff 75 e4             	pushl  -0x1c(%ebp)
  800264:	ff 75 e0             	pushl  -0x20(%ebp)
  800267:	ff 75 dc             	pushl  -0x24(%ebp)
  80026a:	ff 75 d8             	pushl  -0x28(%ebp)
  80026d:	e8 2e 23 00 00       	call   8025a0 <__umoddi3>
  800272:	83 c4 14             	add    $0x14,%esp
  800275:	0f be 80 33 27 80 00 	movsbl 0x802733(%eax),%eax
  80027c:	50                   	push   %eax
  80027d:	ff d7                	call   *%edi
}
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	f3 0f 1e fb          	endbr32 
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800294:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	3b 50 04             	cmp    0x4(%eax),%edx
  80029d:	73 0a                	jae    8002a9 <sprintputch+0x1f>
		*b->buf++ = ch;
  80029f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	88 02                	mov    %al,(%edx)
}
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <printfmt>:
{
  8002ab:	f3 0f 1e fb          	endbr32 
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b8:	50                   	push   %eax
  8002b9:	ff 75 10             	pushl  0x10(%ebp)
  8002bc:	ff 75 0c             	pushl  0xc(%ebp)
  8002bf:	ff 75 08             	pushl  0x8(%ebp)
  8002c2:	e8 05 00 00 00       	call   8002cc <vprintfmt>
}
  8002c7:	83 c4 10             	add    $0x10,%esp
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vprintfmt>:
{
  8002cc:	f3 0f 1e fb          	endbr32 
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 3c             	sub    $0x3c,%esp
  8002d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002df:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e2:	e9 8e 03 00 00       	jmp    800675 <vprintfmt+0x3a9>
		padc = ' ';
  8002e7:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002eb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800300:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8d 47 01             	lea    0x1(%edi),%eax
  800308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030b:	0f b6 17             	movzbl (%edi),%edx
  80030e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800311:	3c 55                	cmp    $0x55,%al
  800313:	0f 87 df 03 00 00    	ja     8006f8 <vprintfmt+0x42c>
  800319:	0f b6 c0             	movzbl %al,%eax
  80031c:	3e ff 24 85 80 28 80 	notrack jmp *0x802880(,%eax,4)
  800323:	00 
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800327:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80032b:	eb d8                	jmp    800305 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800334:	eb cf                	jmp    800305 <vprintfmt+0x39>
  800336:	0f b6 d2             	movzbl %dl,%edx
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80033c:	b8 00 00 00 00       	mov    $0x0,%eax
  800341:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800344:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800347:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80034e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800351:	83 f9 09             	cmp    $0x9,%ecx
  800354:	77 55                	ja     8003ab <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800356:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';// 支持超过10位的width
  800359:	eb e9                	jmp    800344 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8b 00                	mov    (%eax),%eax
  800360:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800363:	8b 45 14             	mov    0x14(%ebp),%eax
  800366:	8d 40 04             	lea    0x4(%eax),%eax
  800369:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800373:	79 90                	jns    800305 <vprintfmt+0x39>
				width = precision, precision = -1;
  800375:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800382:	eb 81                	jmp    800305 <vprintfmt+0x39>
  800384:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800387:	85 c0                	test   %eax,%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
  80038e:	0f 49 d0             	cmovns %eax,%edx
  800391:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800397:	e9 69 ff ff ff       	jmp    800305 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a6:	e9 5a ff ff ff       	jmp    800305 <vprintfmt+0x39>
  8003ab:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b1:	eb bc                	jmp    80036f <vprintfmt+0xa3>
			lflag++;
  8003b3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b9:	e9 47 ff ff ff       	jmp    800305 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 78 04             	lea    0x4(%eax),%edi
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	53                   	push   %ebx
  8003c8:	ff 30                	pushl  (%eax)
  8003ca:	ff d6                	call   *%esi
			break;
  8003cc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d2:	e9 9b 02 00 00       	jmp    800672 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 78 04             	lea    0x4(%eax),%edi
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	99                   	cltd   
  8003e0:	31 d0                	xor    %edx,%eax
  8003e2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e4:	83 f8 0f             	cmp    $0xf,%eax
  8003e7:	7f 23                	jg     80040c <vprintfmt+0x140>
  8003e9:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	74 18                	je     80040c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003f4:	52                   	push   %edx
  8003f5:	68 fd 2b 80 00       	push   $0x802bfd
  8003fa:	53                   	push   %ebx
  8003fb:	56                   	push   %esi
  8003fc:	e8 aa fe ff ff       	call   8002ab <printfmt>
  800401:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800404:	89 7d 14             	mov    %edi,0x14(%ebp)
  800407:	e9 66 02 00 00       	jmp    800672 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80040c:	50                   	push   %eax
  80040d:	68 4b 27 80 00       	push   $0x80274b
  800412:	53                   	push   %ebx
  800413:	56                   	push   %esi
  800414:	e8 92 fe ff ff       	call   8002ab <printfmt>
  800419:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041f:	e9 4e 02 00 00       	jmp    800672 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	83 c0 04             	add    $0x4,%eax
  80042a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800432:	85 d2                	test   %edx,%edx
  800434:	b8 44 27 80 00       	mov    $0x802744,%eax
  800439:	0f 45 c2             	cmovne %edx,%eax
  80043c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	7e 06                	jle    80044b <vprintfmt+0x17f>
  800445:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800449:	75 0d                	jne    800458 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044e:	89 c7                	mov    %eax,%edi
  800450:	03 45 e0             	add    -0x20(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	eb 55                	jmp    8004ad <vprintfmt+0x1e1>
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 d8             	pushl  -0x28(%ebp)
  80045e:	ff 75 cc             	pushl  -0x34(%ebp)
  800461:	e8 46 03 00 00       	call   8007ac <strnlen>
  800466:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800469:	29 c2                	sub    %eax,%edx
  80046b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800473:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800477:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	85 ff                	test   %edi,%edi
  80047c:	7e 11                	jle    80048f <vprintfmt+0x1c3>
					putch(padc, putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	53                   	push   %ebx
  800482:	ff 75 e0             	pushl  -0x20(%ebp)
  800485:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	83 ef 01             	sub    $0x1,%edi
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb eb                	jmp    80047a <vprintfmt+0x1ae>
  80048f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800492:	85 d2                	test   %edx,%edx
  800494:	b8 00 00 00 00       	mov    $0x0,%eax
  800499:	0f 49 c2             	cmovns %edx,%eax
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a1:	eb a8                	jmp    80044b <vprintfmt+0x17f>
					putch(ch, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	52                   	push   %edx
  8004a8:	ff d6                	call   *%esi
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b2:	83 c7 01             	add    $0x1,%edi
  8004b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b9:	0f be d0             	movsbl %al,%edx
  8004bc:	85 d2                	test   %edx,%edx
  8004be:	74 4b                	je     80050b <vprintfmt+0x23f>
  8004c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c4:	78 06                	js     8004cc <vprintfmt+0x200>
  8004c6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ca:	78 1e                	js     8004ea <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))// 非法处理
  8004cc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d0:	74 d1                	je     8004a3 <vprintfmt+0x1d7>
  8004d2:	0f be c0             	movsbl %al,%eax
  8004d5:	83 e8 20             	sub    $0x20,%eax
  8004d8:	83 f8 5e             	cmp    $0x5e,%eax
  8004db:	76 c6                	jbe    8004a3 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	6a 3f                	push   $0x3f
  8004e3:	ff d6                	call   *%esi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb c3                	jmp    8004ad <vprintfmt+0x1e1>
  8004ea:	89 cf                	mov    %ecx,%edi
  8004ec:	eb 0e                	jmp    8004fc <vprintfmt+0x230>
				putch(' ', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	53                   	push   %ebx
  8004f2:	6a 20                	push   $0x20
  8004f4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f6:	83 ef 01             	sub    $0x1,%edi
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	7f ee                	jg     8004ee <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800500:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800503:	89 45 14             	mov    %eax,0x14(%ebp)
  800506:	e9 67 01 00 00       	jmp    800672 <vprintfmt+0x3a6>
  80050b:	89 cf                	mov    %ecx,%edi
  80050d:	eb ed                	jmp    8004fc <vprintfmt+0x230>
	if (lflag >= 2)
  80050f:	83 f9 01             	cmp    $0x1,%ecx
  800512:	7f 1b                	jg     80052f <vprintfmt+0x263>
	else if (lflag)
  800514:	85 c9                	test   %ecx,%ecx
  800516:	74 63                	je     80057b <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800520:	99                   	cltd   
  800521:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 40 04             	lea    0x4(%eax),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	eb 17                	jmp    800546 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 50 04             	mov    0x4(%eax),%edx
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 40 08             	lea    0x8(%eax),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800546:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800549:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80054c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800551:	85 c9                	test   %ecx,%ecx
  800553:	0f 89 ff 00 00 00    	jns    800658 <vprintfmt+0x38c>
				putch('-', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 2d                	push   $0x2d
  80055f:	ff d6                	call   *%esi
				num = -(long long) num;
  800561:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800564:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800567:	f7 da                	neg    %edx
  800569:	83 d1 00             	adc    $0x0,%ecx
  80056c:	f7 d9                	neg    %ecx
  80056e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800571:	b8 0a 00 00 00       	mov    $0xa,%eax
  800576:	e9 dd 00 00 00       	jmp    800658 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800583:	99                   	cltd   
  800584:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	8d 40 04             	lea    0x4(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
  800590:	eb b4                	jmp    800546 <vprintfmt+0x27a>
	if (lflag >= 2)
  800592:	83 f9 01             	cmp    $0x1,%ecx
  800595:	7f 1e                	jg     8005b5 <vprintfmt+0x2e9>
	else if (lflag)
  800597:	85 c9                	test   %ecx,%ecx
  800599:	74 32                	je     8005cd <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a5:	8d 40 04             	lea    0x4(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005b0:	e9 a3 00 00 00       	jmp    800658 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bd:	8d 40 08             	lea    0x8(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005c8:	e9 8b 00 00 00       	jmp    800658 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005e2:	eb 74                	jmp    800658 <vprintfmt+0x38c>
	if (lflag >= 2)
  8005e4:	83 f9 01             	cmp    $0x1,%ecx
  8005e7:	7f 1b                	jg     800604 <vprintfmt+0x338>
	else if (lflag)
  8005e9:	85 c9                	test   %ecx,%ecx
  8005eb:	74 2c                	je     800619 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f7:	8d 40 04             	lea    0x4(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005fd:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800602:	eb 54                	jmp    800658 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	8b 48 04             	mov    0x4(%eax),%ecx
  80060c:	8d 40 08             	lea    0x8(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800612:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800617:	eb 3f                	jmp    800658 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800629:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80062e:	eb 28                	jmp    800658 <vprintfmt+0x38c>
			putch('0', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 30                	push   $0x30
  800636:	ff d6                	call   *%esi
			putch('x', putdat);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 78                	push   $0x78
  80063e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800653:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800658:	83 ec 0c             	sub    $0xc,%esp
  80065b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80065f:	57                   	push   %edi
  800660:	ff 75 e0             	pushl  -0x20(%ebp)
  800663:	50                   	push   %eax
  800664:	51                   	push   %ecx
  800665:	52                   	push   %edx
  800666:	89 da                	mov    %ebx,%edx
  800668:	89 f0                	mov    %esi,%eax
  80066a:	e8 72 fb ff ff       	call   8001e1 <printnum>
			break;
  80066f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {// 字符的一一比较
  800675:	83 c7 01             	add    $0x1,%edi
  800678:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80067c:	83 f8 25             	cmp    $0x25,%eax
  80067f:	0f 84 62 fc ff ff    	je     8002e7 <vprintfmt+0x1b>
			if (ch == '\0')// string读到末尾了 直接返回
  800685:	85 c0                	test   %eax,%eax
  800687:	0f 84 8b 00 00 00    	je     800718 <vprintfmt+0x44c>
			putch(ch, putdat);// 普通的要打印的字符串(既不是%escape seq也不是末尾) 直接调用putch()打印 不向下执行
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	50                   	push   %eax
  800692:	ff d6                	call   *%esi
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	eb dc                	jmp    800675 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800699:	83 f9 01             	cmp    $0x1,%ecx
  80069c:	7f 1b                	jg     8006b9 <vprintfmt+0x3ed>
	else if (lflag)
  80069e:	85 c9                	test   %ecx,%ecx
  8006a0:	74 2c                	je     8006ce <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ac:	8d 40 04             	lea    0x4(%eax),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006b7:	eb 9f                	jmp    800658 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c1:	8d 40 08             	lea    0x8(%eax),%eax
  8006c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006cc:	eb 8a                	jmp    800658 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006e3:	e9 70 ff ff ff       	jmp    800658 <vprintfmt+0x38c>
			putch(ch, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			break;
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	e9 7a ff ff ff       	jmp    800672 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	6a 25                	push   $0x25
  8006fe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)// fmt[-1] == *(fmt - 1)
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	89 f8                	mov    %edi,%eax
  800705:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800709:	74 05                	je     800710 <vprintfmt+0x444>
  80070b:	83 e8 01             	sub    $0x1,%eax
  80070e:	eb f5                	jmp    800705 <vprintfmt+0x439>
  800710:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800713:	e9 5a ff ff ff       	jmp    800672 <vprintfmt+0x3a6>
}
  800718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800720:	f3 0f 1e fb          	endbr32 
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 18             	sub    $0x18,%esp
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800730:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800733:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800737:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800741:	85 c0                	test   %eax,%eax
  800743:	74 26                	je     80076b <vsnprintf+0x4b>
  800745:	85 d2                	test   %edx,%edx
  800747:	7e 22                	jle    80076b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800749:	ff 75 14             	pushl  0x14(%ebp)
  80074c:	ff 75 10             	pushl  0x10(%ebp)
  80074f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800752:	50                   	push   %eax
  800753:	68 8a 02 80 00       	push   $0x80028a
  800758:	e8 6f fb ff ff       	call   8002cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800760:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800763:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800766:	83 c4 10             	add    $0x10,%esp
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    
		return -E_INVAL;
  80076b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800770:	eb f7                	jmp    800769 <vsnprintf+0x49>

00800772 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800772:	f3 0f 1e fb          	endbr32 
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;
	va_start(ap, fmt);
  80077c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077f:	50                   	push   %eax
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	ff 75 0c             	pushl  0xc(%ebp)
  800786:	ff 75 08             	pushl  0x8(%ebp)
  800789:	e8 92 ff ff ff       	call   800720 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	f3 0f 1e fb          	endbr32 
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
  80079f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a3:	74 05                	je     8007aa <strlen+0x1a>
		n++;
  8007a5:	83 c0 01             	add    $0x1,%eax
  8007a8:	eb f5                	jmp    80079f <strlen+0xf>
	return n;
}
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ac:	f3 0f 1e fb          	endbr32 
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007be:	39 d0                	cmp    %edx,%eax
  8007c0:	74 0d                	je     8007cf <strnlen+0x23>
  8007c2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c6:	74 05                	je     8007cd <strnlen+0x21>
		n++;
  8007c8:	83 c0 01             	add    $0x1,%eax
  8007cb:	eb f1                	jmp    8007be <strnlen+0x12>
  8007cd:	89 c2                	mov    %eax,%edx
	return n;
}
  8007cf:	89 d0                	mov    %edx,%eax
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d3:	f3 0f 1e fb          	endbr32 
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007ea:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ed:	83 c0 01             	add    $0x1,%eax
  8007f0:	84 d2                	test   %dl,%dl
  8007f2:	75 f2                	jne    8007e6 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007f4:	89 c8                	mov    %ecx,%eax
  8007f6:	5b                   	pop    %ebx
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f9:	f3 0f 1e fb          	endbr32 
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	83 ec 10             	sub    $0x10,%esp
  800804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800807:	53                   	push   %ebx
  800808:	e8 83 ff ff ff       	call   800790 <strlen>
  80080d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800810:	ff 75 0c             	pushl  0xc(%ebp)
  800813:	01 d8                	add    %ebx,%eax
  800815:	50                   	push   %eax
  800816:	e8 b8 ff ff ff       	call   8007d3 <strcpy>
	return dst;
}
  80081b:	89 d8                	mov    %ebx,%eax
  80081d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800822:	f3 0f 1e fb          	endbr32 
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	89 f3                	mov    %esi,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800836:	89 f0                	mov    %esi,%eax
  800838:	39 d8                	cmp    %ebx,%eax
  80083a:	74 11                	je     80084d <strncpy+0x2b>
		*dst++ = *src;
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	0f b6 0a             	movzbl (%edx),%ecx
  800842:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800845:	80 f9 01             	cmp    $0x1,%cl
  800848:	83 da ff             	sbb    $0xffffffff,%edx
  80084b:	eb eb                	jmp    800838 <strncpy+0x16>
	}
	return ret;
}
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800853:	f3 0f 1e fb          	endbr32 
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 75 08             	mov    0x8(%ebp),%esi
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	8b 55 10             	mov    0x10(%ebp),%edx
  800865:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800867:	85 d2                	test   %edx,%edx
  800869:	74 21                	je     80088c <strlcpy+0x39>
  80086b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800871:	39 c2                	cmp    %eax,%edx
  800873:	74 14                	je     800889 <strlcpy+0x36>
  800875:	0f b6 19             	movzbl (%ecx),%ebx
  800878:	84 db                	test   %bl,%bl
  80087a:	74 0b                	je     800887 <strlcpy+0x34>
			*dst++ = *src++;
  80087c:	83 c1 01             	add    $0x1,%ecx
  80087f:	83 c2 01             	add    $0x1,%edx
  800882:	88 5a ff             	mov    %bl,-0x1(%edx)
  800885:	eb ea                	jmp    800871 <strlcpy+0x1e>
  800887:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800889:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088c:	29 f0                	sub    %esi,%eax
}
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800892:	f3 0f 1e fb          	endbr32 
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089f:	0f b6 01             	movzbl (%ecx),%eax
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 0c                	je     8008b2 <strcmp+0x20>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	75 08                	jne    8008b2 <strcmp+0x20>
		p++, q++;
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	83 c2 01             	add    $0x1,%edx
  8008b0:	eb ed                	jmp    80089f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b2:	0f b6 c0             	movzbl %al,%eax
  8008b5:	0f b6 12             	movzbl (%edx),%edx
  8008b8:	29 d0                	sub    %edx,%eax
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bc:	f3 0f 1e fb          	endbr32 
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cf:	eb 06                	jmp    8008d7 <strncmp+0x1b>
		n--, p++, q++;
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d7:	39 d8                	cmp    %ebx,%eax
  8008d9:	74 16                	je     8008f1 <strncmp+0x35>
  8008db:	0f b6 08             	movzbl (%eax),%ecx
  8008de:	84 c9                	test   %cl,%cl
  8008e0:	74 04                	je     8008e6 <strncmp+0x2a>
  8008e2:	3a 0a                	cmp    (%edx),%cl
  8008e4:	74 eb                	je     8008d1 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 00             	movzbl (%eax),%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    
		return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb f6                	jmp    8008ee <strncmp+0x32>

008008f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f8:	f3 0f 1e fb          	endbr32 
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	0f b6 10             	movzbl (%eax),%edx
  800909:	84 d2                	test   %dl,%dl
  80090b:	74 09                	je     800916 <strchr+0x1e>
		if (*s == c)
  80090d:	38 ca                	cmp    %cl,%dl
  80090f:	74 0a                	je     80091b <strchr+0x23>
	for (; *s; s++)
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	eb f0                	jmp    800906 <strchr+0xe>
			return (char *) s;
	return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <atox>:

// Parse a string and turn it to hexidecimal value
uint32_t atox(const char* va)
{
  80091d:	f3 0f 1e fb          	endbr32 
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	83 ec 10             	sub    $0x10,%esp
	uint32_t v=0x0;
	char* p = strchr(va, 'x') + 1;
  800927:	6a 78                	push   $0x78
  800929:	ff 75 08             	pushl  0x8(%ebp)
  80092c:	e8 c7 ff ff ff       	call   8008f8 <strchr>
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	8d 48 01             	lea    0x1(%eax),%ecx
	uint32_t v=0x0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (; *p!='\0'; p++){
  80093c:	eb 0d                	jmp    80094b <atox+0x2e>
		if (*p>='a'){
			v = v*16 + *p - 'a' + 10;
		}
		else v = v*16 + *p -'0';
  80093e:	c1 e0 04             	shl    $0x4,%eax
  800941:	0f be d2             	movsbl %dl,%edx
  800944:	8d 44 10 d0          	lea    -0x30(%eax,%edx,1),%eax
	for (; *p!='\0'; p++){
  800948:	83 c1 01             	add    $0x1,%ecx
  80094b:	0f b6 11             	movzbl (%ecx),%edx
  80094e:	84 d2                	test   %dl,%dl
  800950:	74 11                	je     800963 <atox+0x46>
		if (*p>='a'){
  800952:	80 fa 60             	cmp    $0x60,%dl
  800955:	7e e7                	jle    80093e <atox+0x21>
			v = v*16 + *p - 'a' + 10;
  800957:	c1 e0 04             	shl    $0x4,%eax
  80095a:	0f be d2             	movsbl %dl,%edx
  80095d:	8d 44 10 a9          	lea    -0x57(%eax,%edx,1),%eax
  800961:	eb e5                	jmp    800948 <atox+0x2b>
	}

	return v;

}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800965:	f3 0f 1e fb          	endbr32 
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800973:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800976:	38 ca                	cmp    %cl,%dl
  800978:	74 09                	je     800983 <strfind+0x1e>
  80097a:	84 d2                	test   %dl,%dl
  80097c:	74 05                	je     800983 <strfind+0x1e>
	for (; *s; s++)
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	eb f0                	jmp    800973 <strfind+0xe>
			break;
	return (char *) s;
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800985:	f3 0f 1e fb          	endbr32 
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	57                   	push   %edi
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800995:	85 c9                	test   %ecx,%ecx
  800997:	74 31                	je     8009ca <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800999:	89 f8                	mov    %edi,%eax
  80099b:	09 c8                	or     %ecx,%eax
  80099d:	a8 03                	test   $0x3,%al
  80099f:	75 23                	jne    8009c4 <memset+0x3f>
		c &= 0xFF;
  8009a1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a5:	89 d3                	mov    %edx,%ebx
  8009a7:	c1 e3 08             	shl    $0x8,%ebx
  8009aa:	89 d0                	mov    %edx,%eax
  8009ac:	c1 e0 18             	shl    $0x18,%eax
  8009af:	89 d6                	mov    %edx,%esi
  8009b1:	c1 e6 10             	shl    $0x10,%esi
  8009b4:	09 f0                	or     %esi,%eax
  8009b6:	09 c2                	or     %eax,%edx
  8009b8:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009bd:	89 d0                	mov    %edx,%eax
  8009bf:	fc                   	cld    
  8009c0:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c2:	eb 06                	jmp    8009ca <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c7:	fc                   	cld    
  8009c8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ca:	89 f8                	mov    %edi,%eax
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d1:	f3 0f 1e fb          	endbr32 
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e3:	39 c6                	cmp    %eax,%esi
  8009e5:	73 32                	jae    800a19 <memmove+0x48>
  8009e7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ea:	39 c2                	cmp    %eax,%edx
  8009ec:	76 2b                	jbe    800a19 <memmove+0x48>
		s += n;
		d += n;
  8009ee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	89 fe                	mov    %edi,%esi
  8009f3:	09 ce                	or     %ecx,%esi
  8009f5:	09 d6                	or     %edx,%esi
  8009f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fd:	75 0e                	jne    800a0d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ff:	83 ef 04             	sub    $0x4,%edi
  800a02:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a05:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a08:	fd                   	std    
  800a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0b:	eb 09                	jmp    800a16 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a0d:	83 ef 01             	sub    $0x1,%edi
  800a10:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a13:	fd                   	std    
  800a14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a16:	fc                   	cld    
  800a17:	eb 1a                	jmp    800a33 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a19:	89 c2                	mov    %eax,%edx
  800a1b:	09 ca                	or     %ecx,%edx
  800a1d:	09 f2                	or     %esi,%edx
  800a1f:	f6 c2 03             	test   $0x3,%dl
  800a22:	75 0a                	jne    800a2e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a24:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a27:	89 c7                	mov    %eax,%edi
  800a29:	fc                   	cld    
  800a2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2c:	eb 05                	jmp    800a33 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	fc                   	cld    
  800a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a37:	f3 0f 1e fb          	endbr32 
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	ff 75 0c             	pushl  0xc(%ebp)
  800a47:	ff 75 08             	pushl  0x8(%ebp)
  800a4a:	e8 82 ff ff ff       	call   8009d1 <memmove>
}
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    

00800a51 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a51:	f3 0f 1e fb          	endbr32 
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a60:	89 c6                	mov    %eax,%esi
  800a62:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a65:	39 f0                	cmp    %esi,%eax
  800a67:	74 1c                	je     800a85 <memcmp+0x34>
		if (*s1 != *s2)
  800a69:	0f b6 08             	movzbl (%eax),%ecx
  800a6c:	0f b6 1a             	movzbl (%edx),%ebx
  800a6f:	38 d9                	cmp    %bl,%cl
  800a71:	75 08                	jne    800a7b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	83 c2 01             	add    $0x1,%edx
  800a79:	eb ea                	jmp    800a65 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a7b:	0f b6 c1             	movzbl %cl,%eax
  800a7e:	0f b6 db             	movzbl %bl,%ebx
  800a81:	29 d8                	sub    %ebx,%eax
  800a83:	eb 05                	jmp    800a8a <memcmp+0x39>
	}

	return 0;
  800a85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8e:	f3 0f 1e fb          	endbr32 
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9b:	89 c2                	mov    %eax,%edx
  800a9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa0:	39 d0                	cmp    %edx,%eax
  800aa2:	73 09                	jae    800aad <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa4:	38 08                	cmp    %cl,(%eax)
  800aa6:	74 05                	je     800aad <memfind+0x1f>
	for (; s < ends; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	eb f3                	jmp    800aa0 <memfind+0x12>
			break;
	return (void *) s;
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aaf:	f3 0f 1e fb          	endbr32 
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abf:	eb 03                	jmp    800ac4 <strtol+0x15>
		s++;
  800ac1:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac4:	0f b6 01             	movzbl (%ecx),%eax
  800ac7:	3c 20                	cmp    $0x20,%al
  800ac9:	74 f6                	je     800ac1 <strtol+0x12>
  800acb:	3c 09                	cmp    $0x9,%al
  800acd:	74 f2                	je     800ac1 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800acf:	3c 2b                	cmp    $0x2b,%al
  800ad1:	74 2a                	je     800afd <strtol+0x4e>
	int neg = 0;
  800ad3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad8:	3c 2d                	cmp    $0x2d,%al
  800ada:	74 2b                	je     800b07 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae2:	75 0f                	jne    800af3 <strtol+0x44>
  800ae4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae7:	74 28                	je     800b11 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af0:	0f 44 d8             	cmove  %eax,%ebx
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afb:	eb 46                	jmp    800b43 <strtol+0x94>
		s++;
  800afd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
  800b05:	eb d5                	jmp    800adc <strtol+0x2d>
		s++, neg = 1;
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b0f:	eb cb                	jmp    800adc <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b11:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b15:	74 0e                	je     800b25 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	75 d8                	jne    800af3 <strtol+0x44>
		s++, base = 8;
  800b1b:	83 c1 01             	add    $0x1,%ecx
  800b1e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b23:	eb ce                	jmp    800af3 <strtol+0x44>
		s += 2, base = 16;
  800b25:	83 c1 02             	add    $0x2,%ecx
  800b28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2d:	eb c4                	jmp    800af3 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b2f:	0f be d2             	movsbl %dl,%edx
  800b32:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b35:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b38:	7d 3a                	jge    800b74 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b3a:	83 c1 01             	add    $0x1,%ecx
  800b3d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b41:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b43:	0f b6 11             	movzbl (%ecx),%edx
  800b46:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 09             	cmp    $0x9,%bl
  800b4e:	76 df                	jbe    800b2f <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b50:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b53:	89 f3                	mov    %esi,%ebx
  800b55:	80 fb 19             	cmp    $0x19,%bl
  800b58:	77 08                	ja     800b62 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b5a:	0f be d2             	movsbl %dl,%edx
  800b5d:	83 ea 57             	sub    $0x57,%edx
  800b60:	eb d3                	jmp    800b35 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b62:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	80 fb 19             	cmp    $0x19,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6c:	0f be d2             	movsbl %dl,%edx
  800b6f:	83 ea 37             	sub    $0x37,%edx
  800b72:	eb c1                	jmp    800b35 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b78:	74 05                	je     800b7f <strtol+0xd0>
		*endptr = (char *) s;
  800b7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	f7 da                	neg    %edx
  800b83:	85 ff                	test   %edi,%edi
  800b85:	0f 45 c2             	cmovne %edx,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8d:	f3 0f 1e fb          	endbr32 
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	89 c3                	mov    %eax,%ebx
  800ba4:	89 c7                	mov    %eax,%edi
  800ba6:	89 c6                	mov    %eax,%esi
  800ba8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_cgetc>:

int
sys_cgetc(void)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc3:	89 d1                	mov    %edx,%ecx
  800bc5:	89 d3                	mov    %edx,%ebx
  800bc7:	89 d7                	mov    %edx,%edi
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd2:	f3 0f 1e fb          	endbr32 
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	b8 03 00 00 00       	mov    $0x3,%eax
  800be9:	89 cb                	mov    %ecx,%ebx
  800beb:	89 cf                	mov    %ecx,%edi
  800bed:	89 ce                	mov    %ecx,%esi
  800bef:	cd 30                	int    $0x30
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf6:	f3 0f 1e fb          	endbr32 
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_yield>:

void
sys_yield(void)
{
  800c19:	f3 0f 1e fb          	endbr32 
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c23:	ba 00 00 00 00       	mov    $0x0,%edx
  800c28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2d:	89 d1                	mov    %edx,%ecx
  800c2f:	89 d3                	mov    %edx,%ebx
  800c31:	89 d7                	mov    %edx,%edi
  800c33:	89 d6                	mov    %edx,%esi
  800c35:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3c:	f3 0f 1e fb          	endbr32 
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c46:	be 00 00 00 00       	mov    $0x0,%esi
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	b8 04 00 00 00       	mov    $0x4,%eax
  800c56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c59:	89 f7                	mov    %esi,%edi
  800c5b:	cd 30                	int    $0x30
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c62:	f3 0f 1e fb          	endbr32 
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c80:	cd 30                	int    $0x30
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c87:	f3 0f 1e fb          	endbr32 
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cac:	f3 0f 1e fb          	endbr32 
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc6:	89 df                	mov    %ebx,%edi
  800cc8:	89 de                	mov    %ebx,%esi
  800cca:	cd 30                	int    $0x30
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd1:	f3 0f 1e fb          	endbr32 
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ceb:	89 df                	mov    %ebx,%edi
  800ced:	89 de                	mov    %ebx,%esi
  800cef:	cd 30                	int    $0x30
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf6:	f3 0f 1e fb          	endbr32 
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1b:	f3 0f 1e fb          	endbr32 
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d30:	be 00 00 00 00       	mov    $0x0,%esi
  800d35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d42:	f3 0f 1e fb          	endbr32 
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d59:	89 cb                	mov    %ecx,%ebx
  800d5b:	89 cf                	mov    %ecx,%edi
  800d5d:	89 ce                	mov    %ecx,%esi
  800d5f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d66:	f3 0f 1e fb          	endbr32 
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7a:	89 d1                	mov    %edx,%ecx
  800d7c:	89 d3                	mov    %edx,%ebx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	89 d6                	mov    %edx,%esi
  800d82:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_netpacket_try_send>:

int 
sys_netpacket_try_send(void* buf, size_t len)
{
  800d89:	f3 0f 1e fb          	endbr32 
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_try_send, 1, (uint32_t)buf, len, 0, 0, 0);
}
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_netpacket_recv>:

int 
sys_netpacket_recv(void* buf, size_t buflen)
{
  800dae:	f3 0f 1e fb          	endbr32 
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc8:	89 df                	mov    %ebx,%edi
  800dca:	89 de                	mov    %ebx,%esi
  800dcc:	cd 30                	int    $0x30
	return syscall(SYS_netpacket_recv, 1, (uint32_t)buf, buflen, 0, 0, 0);
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <pgfault>:
// map in our own private writable copy.
//
extern int cnt;
static void
pgfault(struct UTrapframe *utf)
{
  800dd3:	f3 0f 1e fb          	endbr32 
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	53                   	push   %ebx
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("[%08x] called pgfault\n", sys_getenvid());
	void *addr = (void *) utf->utf_fault_va;
  800de1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err&FEC_WR)&&(uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_COW))){
  800de3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de7:	0f 84 9a 00 00 00    	je     800e87 <pgfault+0xb4>
  800ded:	89 d8                	mov    %ebx,%eax
  800def:	c1 e8 16             	shr    $0x16,%eax
  800df2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800df9:	a8 01                	test   $0x1,%al
  800dfb:	0f 84 86 00 00 00    	je     800e87 <pgfault+0xb4>
  800e01:	89 d8                	mov    %ebx,%eax
  800e03:	c1 e8 0c             	shr    $0xc,%eax
  800e06:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 75                	je     800e87 <pgfault+0xb4>
  800e12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e19:	f6 c4 08             	test   $0x8,%ah
  800e1c:	74 69                	je     800e87 <pgfault+0xb4>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// 在PFTEMP这里给一个物理地址的mapping 相当于store一个物理地址
	if((r = sys_page_alloc(0, (void*)PFTEMP, PTE_P|PTE_U|PTE_W))<0){
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	6a 07                	push   $0x7
  800e23:	68 00 f0 7f 00       	push   $0x7ff000
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 0d fe ff ff       	call   800c3c <sys_page_alloc>
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	78 63                	js     800e99 <pgfault+0xc6>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e36:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 先复制addr里的content
	memcpy((void*)PFTEMP, addr, PGSIZE);
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	68 00 10 00 00       	push   $0x1000
  800e44:	53                   	push   %ebx
  800e45:	68 00 f0 7f 00       	push   $0x7ff000
  800e4a:	e8 e8 fb ff ff       	call   800a37 <memcpy>
	// 在remap addr到PFTEMP位置 即addr与PFTEMP指向同一个物理内存
	if ((r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W))<0){
  800e4f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e56:	53                   	push   %ebx
  800e57:	6a 00                	push   $0x0
  800e59:	68 00 f0 7f 00       	push   $0x7ff000
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 fd fd ff ff       	call   800c62 <sys_page_map>
  800e65:	83 c4 20             	add    $0x20,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	78 3f                	js     800eab <pgfault+0xd8>
		panic("pgfault: sys_page_map failed due to %e\n", r);
	}
	if ((r = sys_page_unmap(0, (void*)PFTEMP))<0){
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	68 00 f0 7f 00       	push   $0x7ff000
  800e74:	6a 00                	push   $0x0
  800e76:	e8 0c fe ff ff       	call   800c87 <sys_page_unmap>
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	78 3b                	js     800ebd <pgfault+0xea>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
	}
	
	
}
  800e82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    
		panic("pgfault: page access at %08x is not a write to a copy-on-write\n", addr);
  800e87:	53                   	push   %ebx
  800e88:	68 40 2a 80 00       	push   $0x802a40
  800e8d:	6a 20                	push   $0x20
  800e8f:	68 fe 2a 80 00       	push   $0x802afe
  800e94:	e8 d1 14 00 00       	call   80236a <_panic>
		panic("pgfault: sys_page_alloc failed due to %e\n",r);
  800e99:	50                   	push   %eax
  800e9a:	68 80 2a 80 00       	push   $0x802a80
  800e9f:	6a 2c                	push   $0x2c
  800ea1:	68 fe 2a 80 00       	push   $0x802afe
  800ea6:	e8 bf 14 00 00       	call   80236a <_panic>
		panic("pgfault: sys_page_map failed due to %e\n", r);
  800eab:	50                   	push   %eax
  800eac:	68 ac 2a 80 00       	push   $0x802aac
  800eb1:	6a 33                	push   $0x33
  800eb3:	68 fe 2a 80 00       	push   $0x802afe
  800eb8:	e8 ad 14 00 00       	call   80236a <_panic>
		panic("pgfault: sys_page_unmap failed due to %e\n", r);
  800ebd:	50                   	push   %eax
  800ebe:	68 d4 2a 80 00       	push   $0x802ad4
  800ec3:	6a 36                	push   $0x36
  800ec5:	68 fe 2a 80 00       	push   $0x802afe
  800eca:	e8 9b 14 00 00       	call   80236a <_panic>

00800ecf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ecf:	f3 0f 1e fb          	endbr32 
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[%08x] called fork\n", sys_getenvid());
	int r; uintptr_t addr;
	set_pgfault_handler(pgfault);
  800edc:	68 d3 0d 80 00       	push   $0x800dd3
  800ee1:	e8 ce 14 00 00       	call   8023b4 <set_pgfault_handler>
*/
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee6:	b8 07 00 00 00       	mov    $0x7,%eax
  800eeb:	cd 30                	int    $0x30
  800eed:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid = sys_exofork();
		
	if (envid<0){
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	78 29                	js     800f20 <fork+0x51>
  800ef7:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	// duplicate parent address space
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid==0){
  800efe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f02:	75 60                	jne    800f64 <fork+0x95>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f04:	e8 ed fc ff ff       	call   800bf6 <sys_getenvid>
  800f09:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f0e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f11:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f16:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f1b:	e9 14 01 00 00       	jmp    801034 <fork+0x165>
		panic("fork: sys_exofork error %e\n", envid);
  800f20:	50                   	push   %eax
  800f21:	68 09 2b 80 00       	push   $0x802b09
  800f26:	68 90 00 00 00       	push   $0x90
  800f2b:	68 fe 2a 80 00       	push   $0x802afe
  800f30:	e8 35 14 00 00       	call   80236a <_panic>
		r = sys_page_map(0, addr, envid, addr, (uvpt[pn]&PTE_SYSCALL));
  800f35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3c:	83 ec 0c             	sub    $0xc,%esp
  800f3f:	25 07 0e 00 00       	and    $0xe07,%eax
  800f44:	50                   	push   %eax
  800f45:	56                   	push   %esi
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 13 fd ff ff       	call   800c62 <sys_page_map>
  800f4f:	83 c4 20             	add    $0x20,%esp
	for (addr = 0;addr<USTACKTOP; addr+=PGSIZE){
  800f52:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f58:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f5e:	0f 84 95 00 00 00    	je     800ff9 <fork+0x12a>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	c1 e8 16             	shr    $0x16,%eax
  800f69:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f70:	a8 01                	test   $0x1,%al
  800f72:	74 de                	je     800f52 <fork+0x83>
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	c1 e8 0c             	shr    $0xc,%eax
  800f79:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f80:	f6 c2 01             	test   $0x1,%dl
  800f83:	74 cd                	je     800f52 <fork+0x83>
	void* addr = (void*)(pn*PGSIZE);
  800f85:	89 c6                	mov    %eax,%esi
  800f87:	c1 e6 0c             	shl    $0xc,%esi
	if (uvpt[pn]&PTE_SHARE){
  800f8a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f91:	f6 c6 04             	test   $0x4,%dh
  800f94:	75 9f                	jne    800f35 <fork+0x66>
		if (uvpt[pn]&PTE_W||uvpt[pn]&PTE_COW){
  800f96:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9d:	f6 c2 02             	test   $0x2,%dl
  800fa0:	75 0c                	jne    800fae <fork+0xdf>
  800fa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa9:	f6 c4 08             	test   $0x8,%ah
  800fac:	74 34                	je     800fe2 <fork+0x113>
			r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P); // not writable
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	68 05 08 00 00       	push   $0x805
  800fb6:	56                   	push   %esi
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 a2 fc ff ff       	call   800c62 <sys_page_map>
			if (r<0) return r;
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 8b                	js     800f52 <fork+0x83>
			r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P); // not writable
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	68 05 08 00 00       	push   $0x805
  800fcf:	56                   	push   %esi
  800fd0:	6a 00                	push   $0x0
  800fd2:	56                   	push   %esi
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 88 fc ff ff       	call   800c62 <sys_page_map>
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	e9 70 ff ff ff       	jmp    800f52 <fork+0x83>
			if ((r=sys_page_map(0, addr, envid, addr, PTE_P|PTE_U)<0))// read only
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	6a 05                	push   $0x5
  800fe7:	56                   	push   %esi
  800fe8:	57                   	push   %edi
  800fe9:	56                   	push   %esi
  800fea:	6a 00                	push   $0x0
  800fec:	e8 71 fc ff ff       	call   800c62 <sys_page_map>
  800ff1:	83 c4 20             	add    $0x20,%esp
  800ff4:	e9 59 ff ff ff       	jmp    800f52 <fork+0x83>
			duppage(envid, PGNUM(addr));
		}
	}
	// allocate user exception stack
	// cprintf("alloc user expection stack\n");
	if ((r = sys_page_alloc(envid, (void*)(UXSTACKTOP-PGSIZE),PTE_P|PTE_W|PTE_U))<0)
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	6a 07                	push   $0x7
  800ffe:	68 00 f0 bf ee       	push   $0xeebff000
  801003:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801006:	56                   	push   %esi
  801007:	e8 30 fc ff ff       	call   800c3c <sys_page_alloc>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 2b                	js     80103e <fork+0x16f>
		return r;
	
	extern void* _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	68 27 24 80 00       	push   $0x802427
  80101b:	56                   	push   %esi
  80101c:	e8 d5 fc ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801021:	83 c4 08             	add    $0x8,%esp
  801024:	6a 02                	push   $0x2
  801026:	56                   	push   %esi
  801027:	e8 80 fc ff ff       	call   800cac <sys_env_set_status>
  80102c:	83 c4 10             	add    $0x10,%esp
		return r;
  80102f:	85 c0                	test   %eax,%eax
  801031:	0f 48 f8             	cmovs  %eax,%edi

	return envid;
	
}
  801034:	89 f8                	mov    %edi,%eax
  801036:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801039:	5b                   	pop    %ebx
  80103a:	5e                   	pop    %esi
  80103b:	5f                   	pop    %edi
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    
		return r;
  80103e:	89 c7                	mov    %eax,%edi
  801040:	eb f2                	jmp    801034 <fork+0x165>

00801042 <sfork>:

// Challenge(not sure yet)
int
sfork(void)
{
  801042:	f3 0f 1e fb          	endbr32 
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80104c:	68 25 2b 80 00       	push   $0x802b25
  801051:	68 b2 00 00 00       	push   $0xb2
  801056:	68 fe 2a 80 00       	push   $0x802afe
  80105b:	e8 0a 13 00 00       	call   80236a <_panic>

00801060 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	8b 75 08             	mov    0x8(%ebp),%esi
  80106c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	pg = (pg==NULL)?(void*)UTOP:pg;
  801072:	85 c0                	test   %eax,%eax
  801074:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801079:	0f 44 c2             	cmove  %edx,%eax
	
	if ((err = sys_ipc_recv(pg))==0){
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	50                   	push   %eax
  801080:	e8 bd fc ff ff       	call   800d42 <sys_ipc_recv>
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	75 2b                	jne    8010b7 <ipc_recv+0x57>
		// syscall succeeded 
		if (from_env_store)
  80108c:	85 f6                	test   %esi,%esi
  80108e:	74 0a                	je     80109a <ipc_recv+0x3a>
			*from_env_store = thisenv->env_ipc_from;
  801090:	a1 08 40 80 00       	mov    0x804008,%eax
  801095:	8b 40 74             	mov    0x74(%eax),%eax
  801098:	89 06                	mov    %eax,(%esi)
		if (perm_store)
  80109a:	85 db                	test   %ebx,%ebx
  80109c:	74 0a                	je     8010a8 <ipc_recv+0x48>
			*perm_store = thisenv->env_ipc_perm;
  80109e:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a3:	8b 40 78             	mov    0x78(%eax),%eax
  8010a6:	89 03                	mov    %eax,(%ebx)
	else{
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return err;
	}
	return thisenv->env_ipc_value;
  8010a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ad:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8010b7:	85 f6                	test   %esi,%esi
  8010b9:	74 06                	je     8010c1 <ipc_recv+0x61>
  8010bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8010c1:	85 db                	test   %ebx,%ebx
  8010c3:	74 eb                	je     8010b0 <ipc_recv+0x50>
  8010c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010cb:	eb e3                	jmp    8010b0 <ipc_recv+0x50>

008010cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010cd:	f3 0f 1e fb          	endbr32 
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	 * C99:It says "An integer constant expression with the value 0, 
	 * or such an expression cast to type void *,
	 * is called a null pointer constant." 
	 * It also says that a character literal is an integer constant expression.
	*/
	pg = (pg==NULL)? (void*)UTOP:pg;
  8010e3:	85 db                	test   %ebx,%ebx
  8010e5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010ea:	0f 44 d8             	cmove  %eax,%ebx
	while(1){
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  8010ed:	ff 75 14             	pushl  0x14(%ebp)
  8010f0:	53                   	push   %ebx
  8010f1:	56                   	push   %esi
  8010f2:	57                   	push   %edi
  8010f3:	e8 23 fc ff ff       	call   800d1b <sys_ipc_try_send>
		if (ret == -E_IPC_NOT_RECV){
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010fe:	75 07                	jne    801107 <ipc_send+0x3a>
			sys_yield();
  801100:	e8 14 fb ff ff       	call   800c19 <sys_yield>
		ret = sys_ipc_try_send(to_env, val, pg, perm);
  801105:	eb e6                	jmp    8010ed <ipc_send+0x20>
		}
		else if (ret == 0)
  801107:	85 c0                	test   %eax,%eax
  801109:	75 08                	jne    801113 <ipc_send+0x46>
			return; // succeeded
		else
			panic("ipc_send: %e\n", ret);
	}
		
}
  80110b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	5f                   	pop    %edi
  801111:	5d                   	pop    %ebp
  801112:	c3                   	ret    
			panic("ipc_send: %e\n", ret);
  801113:	50                   	push   %eax
  801114:	68 3b 2b 80 00       	push   $0x802b3b
  801119:	6a 48                	push   $0x48
  80111b:	68 49 2b 80 00       	push   $0x802b49
  801120:	e8 45 12 00 00       	call   80236a <_panic>

00801125 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801125:	f3 0f 1e fb          	endbr32 
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801134:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801137:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80113d:	8b 52 50             	mov    0x50(%edx),%edx
  801140:	39 ca                	cmp    %ecx,%edx
  801142:	74 11                	je     801155 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801144:	83 c0 01             	add    $0x1,%eax
  801147:	3d 00 04 00 00       	cmp    $0x400,%eax
  80114c:	75 e6                	jne    801134 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
  801153:	eb 0b                	jmp    801160 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801155:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801162:	f3 0f 1e fb          	endbr32 
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	05 00 00 00 30       	add    $0x30000000,%eax
  801171:	c1 e8 0c             	shr    $0xc,%eax
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801176:	f3 0f 1e fb          	endbr32 
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117d:	8b 45 08             	mov    0x8(%ebp),%eax
  801180:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801185:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80118a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801191:	f3 0f 1e fb          	endbr32 
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 ea 16             	shr    $0x16,%edx
  8011a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	74 2d                	je     8011db <fd_alloc+0x4a>
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	c1 ea 0c             	shr    $0xc,%edx
  8011b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ba:	f6 c2 01             	test   $0x1,%dl
  8011bd:	74 1c                	je     8011db <fd_alloc+0x4a>
  8011bf:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011c4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c9:	75 d2                	jne    80119d <fd_alloc+0xc>
			if (debug) 
				cprintf("[%08x] alloc fd %d\n", thisenv->env_id, i);
			return 0;
		}
	}
	*fd_store = 0;
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8011d4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8011d9:	eb 0a                	jmp    8011e5 <fd_alloc+0x54>
			*fd_store = fd;
  8011db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011e7:	f3 0f 1e fb          	endbr32 
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f1:	83 f8 1f             	cmp    $0x1f,%eax
  8011f4:	77 30                	ja     801226 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f6:	c1 e0 0c             	shl    $0xc,%eax
  8011f9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011fe:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	74 24                	je     80122d <fd_lookup+0x46>
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 0c             	shr    $0xc,%edx
  80120e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 1a                	je     801234 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121d:	89 02                	mov    %eax,(%edx)
	return 0;
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    
		return -E_INVAL;
  801226:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122b:	eb f7                	jmp    801224 <fd_lookup+0x3d>
		return -E_INVAL;
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb f0                	jmp    801224 <fd_lookup+0x3d>
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb e9                	jmp    801224 <fd_lookup+0x3d>

0080123b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123b:	f3 0f 1e fb          	endbr32 
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	83 ec 08             	sub    $0x8,%esp
  801245:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; devtab[i]; i++)
  801248:	ba 00 00 00 00       	mov    $0x0,%edx
  80124d:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801252:	39 08                	cmp    %ecx,(%eax)
  801254:	74 38                	je     80128e <dev_lookup+0x53>
	for (i = 0; devtab[i]; i++)
  801256:	83 c2 01             	add    $0x1,%edx
  801259:	8b 04 95 d0 2b 80 00 	mov    0x802bd0(,%edx,4),%eax
  801260:	85 c0                	test   %eax,%eax
  801262:	75 ee                	jne    801252 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801264:	a1 08 40 80 00       	mov    0x804008,%eax
  801269:	8b 40 48             	mov    0x48(%eax),%eax
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	51                   	push   %ecx
  801270:	50                   	push   %eax
  801271:	68 54 2b 80 00       	push   $0x802b54
  801276:	e8 4e ef ff ff       	call   8001c9 <cprintf>
	*dev = 0;
  80127b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    
			*dev = devtab[i];
  80128e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801291:	89 01                	mov    %eax,(%ecx)
			return 0;
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
  801298:	eb f2                	jmp    80128c <dev_lookup+0x51>

0080129a <fd_close>:
{
  80129a:	f3 0f 1e fb          	endbr32 
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 24             	sub    $0x24,%esp
  8012a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b0:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b7:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ba:	50                   	push   %eax
  8012bb:	e8 27 ff ff ff       	call   8011e7 <fd_lookup>
  8012c0:	89 c3                	mov    %eax,%ebx
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	78 05                	js     8012ce <fd_close+0x34>
	    || fd != fd2)
  8012c9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012cc:	74 16                	je     8012e4 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8012ce:	89 f8                	mov    %edi,%eax
  8012d0:	84 c0                	test   %al,%al
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d7:	0f 44 d8             	cmove  %eax,%ebx
}
  8012da:	89 d8                	mov    %ebx,%eax
  8012dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5e                   	pop    %esi
  8012e1:	5f                   	pop    %edi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	ff 36                	pushl  (%esi)
  8012ed:	e8 49 ff ff ff       	call   80123b <dev_lookup>
  8012f2:	89 c3                	mov    %eax,%ebx
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 1a                	js     801315 <fd_close+0x7b>
		if (dev->dev_close)
  8012fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012fe:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801301:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801306:	85 c0                	test   %eax,%eax
  801308:	74 0b                	je     801315 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	56                   	push   %esi
  80130e:	ff d0                	call   *%eax
  801310:	89 c3                	mov    %eax,%ebx
  801312:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	56                   	push   %esi
  801319:	6a 00                	push   $0x0
  80131b:	e8 67 f9 ff ff       	call   800c87 <sys_page_unmap>
	return r;
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	eb b5                	jmp    8012da <fd_close+0x40>

00801325 <close>:

int
close(int fdnum)
{
  801325:	f3 0f 1e fb          	endbr32 
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 75 08             	pushl  0x8(%ebp)
  801336:	e8 ac fe ff ff       	call   8011e7 <fd_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	79 02                	jns    801344 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801342:	c9                   	leave  
  801343:	c3                   	ret    
		return fd_close(fd, 1);
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	6a 01                	push   $0x1
  801349:	ff 75 f4             	pushl  -0xc(%ebp)
  80134c:	e8 49 ff ff ff       	call   80129a <fd_close>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	eb ec                	jmp    801342 <close+0x1d>

00801356 <close_all>:

void
close_all(void)
{
  801356:	f3 0f 1e fb          	endbr32 
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801361:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	53                   	push   %ebx
  80136a:	e8 b6 ff ff ff       	call   801325 <close>
	for (i = 0; i < MAXFD; i++)
  80136f:	83 c3 01             	add    $0x1,%ebx
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	83 fb 20             	cmp    $0x20,%ebx
  801378:	75 ec                	jne    801366 <close_all+0x10>
}
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137f:	f3 0f 1e fb          	endbr32 
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	57                   	push   %edi
  801387:	56                   	push   %esi
  801388:	53                   	push   %ebx
  801389:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	ff 75 08             	pushl  0x8(%ebp)
  801393:	e8 4f fe ff ff       	call   8011e7 <fd_lookup>
  801398:	89 c3                	mov    %eax,%ebx
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	0f 88 81 00 00 00    	js     801426 <dup+0xa7>
		return r;
	close(newfdnum);
  8013a5:	83 ec 0c             	sub    $0xc,%esp
  8013a8:	ff 75 0c             	pushl  0xc(%ebp)
  8013ab:	e8 75 ff ff ff       	call   801325 <close>

	newfd = INDEX2FD(newfdnum);
  8013b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b3:	c1 e6 0c             	shl    $0xc,%esi
  8013b6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013bc:	83 c4 04             	add    $0x4,%esp
  8013bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c2:	e8 af fd ff ff       	call   801176 <fd2data>
  8013c7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013c9:	89 34 24             	mov    %esi,(%esp)
  8013cc:	e8 a5 fd ff ff       	call   801176 <fd2data>
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d6:	89 d8                	mov    %ebx,%eax
  8013d8:	c1 e8 16             	shr    $0x16,%eax
  8013db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e2:	a8 01                	test   $0x1,%al
  8013e4:	74 11                	je     8013f7 <dup+0x78>
  8013e6:	89 d8                	mov    %ebx,%eax
  8013e8:	c1 e8 0c             	shr    $0xc,%eax
  8013eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f2:	f6 c2 01             	test   $0x1,%dl
  8013f5:	75 39                	jne    801430 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013fa:	89 d0                	mov    %edx,%eax
  8013fc:	c1 e8 0c             	shr    $0xc,%eax
  8013ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	25 07 0e 00 00       	and    $0xe07,%eax
  80140e:	50                   	push   %eax
  80140f:	56                   	push   %esi
  801410:	6a 00                	push   $0x0
  801412:	52                   	push   %edx
  801413:	6a 00                	push   $0x0
  801415:	e8 48 f8 ff ff       	call   800c62 <sys_page_map>
  80141a:	89 c3                	mov    %eax,%ebx
  80141c:	83 c4 20             	add    $0x20,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 31                	js     801454 <dup+0xd5>
		goto err;

	return newfdnum;
  801423:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801426:	89 d8                	mov    %ebx,%eax
  801428:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801430:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	25 07 0e 00 00       	and    $0xe07,%eax
  80143f:	50                   	push   %eax
  801440:	57                   	push   %edi
  801441:	6a 00                	push   $0x0
  801443:	53                   	push   %ebx
  801444:	6a 00                	push   $0x0
  801446:	e8 17 f8 ff ff       	call   800c62 <sys_page_map>
  80144b:	89 c3                	mov    %eax,%ebx
  80144d:	83 c4 20             	add    $0x20,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	79 a3                	jns    8013f7 <dup+0x78>
	sys_page_unmap(0, newfd);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	56                   	push   %esi
  801458:	6a 00                	push   $0x0
  80145a:	e8 28 f8 ff ff       	call   800c87 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145f:	83 c4 08             	add    $0x8,%esp
  801462:	57                   	push   %edi
  801463:	6a 00                	push   $0x0
  801465:	e8 1d f8 ff ff       	call   800c87 <sys_page_unmap>
	return r;
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	eb b7                	jmp    801426 <dup+0xa7>

0080146f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146f:	f3 0f 1e fb          	endbr32 
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 1c             	sub    $0x1c,%esp
  80147a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	53                   	push   %ebx
  801482:	e8 60 fd ff ff       	call   8011e7 <fd_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 3f                	js     8014cd <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801498:	ff 30                	pushl  (%eax)
  80149a:	e8 9c fd ff ff       	call   80123b <dev_lookup>
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 27                	js     8014cd <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a9:	8b 42 08             	mov    0x8(%edx),%eax
  8014ac:	83 e0 03             	and    $0x3,%eax
  8014af:	83 f8 01             	cmp    $0x1,%eax
  8014b2:	74 1e                	je     8014d2 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b7:	8b 40 08             	mov    0x8(%eax),%eax
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	74 35                	je     8014f3 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014be:	83 ec 04             	sub    $0x4,%esp
  8014c1:	ff 75 10             	pushl  0x10(%ebp)
  8014c4:	ff 75 0c             	pushl  0xc(%ebp)
  8014c7:	52                   	push   %edx
  8014c8:	ff d0                	call   *%eax
  8014ca:	83 c4 10             	add    $0x10,%esp
}
  8014cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8014d7:	8b 40 48             	mov    0x48(%eax),%eax
  8014da:	83 ec 04             	sub    $0x4,%esp
  8014dd:	53                   	push   %ebx
  8014de:	50                   	push   %eax
  8014df:	68 95 2b 80 00       	push   $0x802b95
  8014e4:	e8 e0 ec ff ff       	call   8001c9 <cprintf>
		return -E_INVAL;
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f1:	eb da                	jmp    8014cd <read+0x5e>
		return -E_NOT_SUPP;
  8014f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014f8:	eb d3                	jmp    8014cd <read+0x5e>

008014fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014fa:	f3 0f 1e fb          	endbr32 
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801512:	eb 02                	jmp    801516 <readn+0x1c>
  801514:	01 c3                	add    %eax,%ebx
  801516:	39 f3                	cmp    %esi,%ebx
  801518:	73 21                	jae    80153b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151a:	83 ec 04             	sub    $0x4,%esp
  80151d:	89 f0                	mov    %esi,%eax
  80151f:	29 d8                	sub    %ebx,%eax
  801521:	50                   	push   %eax
  801522:	89 d8                	mov    %ebx,%eax
  801524:	03 45 0c             	add    0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	57                   	push   %edi
  801529:	e8 41 ff ff ff       	call   80146f <read>
		if (m < 0)
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	78 04                	js     801539 <readn+0x3f>
			return m;
		if (m == 0)
  801535:	75 dd                	jne    801514 <readn+0x1a>
  801537:	eb 02                	jmp    80153b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801539:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801545:	f3 0f 1e fb          	endbr32 
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 1c             	sub    $0x1c,%esp
  801550:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801553:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	53                   	push   %ebx
  801558:	e8 8a fc ff ff       	call   8011e7 <fd_lookup>
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 3a                	js     80159e <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156e:	ff 30                	pushl  (%eax)
  801570:	e8 c6 fc ff ff       	call   80123b <dev_lookup>
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 22                	js     80159e <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801583:	74 1e                	je     8015a3 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801585:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801588:	8b 52 0c             	mov    0xc(%edx),%edx
  80158b:	85 d2                	test   %edx,%edx
  80158d:	74 35                	je     8015c4 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	ff 75 10             	pushl  0x10(%ebp)
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	50                   	push   %eax
  801599:	ff d2                	call   *%edx
  80159b:	83 c4 10             	add    $0x10,%esp
}
  80159e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a3:	a1 08 40 80 00       	mov    0x804008,%eax
  8015a8:	8b 40 48             	mov    0x48(%eax),%eax
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	53                   	push   %ebx
  8015af:	50                   	push   %eax
  8015b0:	68 b1 2b 80 00       	push   $0x802bb1
  8015b5:	e8 0f ec ff ff       	call   8001c9 <cprintf>
		return -E_INVAL;
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c2:	eb da                	jmp    80159e <write+0x59>
		return -E_NOT_SUPP;
  8015c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c9:	eb d3                	jmp    80159e <write+0x59>

008015cb <seek>:

int
seek(int fdnum, off_t offset)
{
  8015cb:	f3 0f 1e fb          	endbr32 
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 06 fc ff ff       	call   8011e7 <fd_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 0e                	js     8015f6 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f8:	f3 0f 1e fb          	endbr32 
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 1c             	sub    $0x1c,%esp
  801603:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801606:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	53                   	push   %ebx
  80160b:	e8 d7 fb ff ff       	call   8011e7 <fd_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 37                	js     80164e <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	ff 30                	pushl  (%eax)
  801623:	e8 13 fc ff ff       	call   80123b <dev_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 1f                	js     80164e <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801632:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801636:	74 1b                	je     801653 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801638:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163b:	8b 52 18             	mov    0x18(%edx),%edx
  80163e:	85 d2                	test   %edx,%edx
  801640:	74 32                	je     801674 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	50                   	push   %eax
  801649:	ff d2                	call   *%edx
  80164b:	83 c4 10             	add    $0x10,%esp
}
  80164e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801651:	c9                   	leave  
  801652:	c3                   	ret    
			thisenv->env_id, fdnum);
  801653:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801658:	8b 40 48             	mov    0x48(%eax),%eax
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	53                   	push   %ebx
  80165f:	50                   	push   %eax
  801660:	68 74 2b 80 00       	push   $0x802b74
  801665:	e8 5f eb ff ff       	call   8001c9 <cprintf>
		return -E_INVAL;
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801672:	eb da                	jmp    80164e <ftruncate+0x56>
		return -E_NOT_SUPP;
  801674:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801679:	eb d3                	jmp    80164e <ftruncate+0x56>

0080167b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80167b:	f3 0f 1e fb          	endbr32 
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	83 ec 1c             	sub    $0x1c,%esp
  801686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801689:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	ff 75 08             	pushl  0x8(%ebp)
  801690:	e8 52 fb ff ff       	call   8011e7 <fd_lookup>
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 4b                	js     8016e7 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a6:	ff 30                	pushl  (%eax)
  8016a8:	e8 8e fb ff ff       	call   80123b <dev_lookup>
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 33                	js     8016e7 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8016b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016bb:	74 2f                	je     8016ec <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c7:	00 00 00 
	stat->st_isdir = 0;
  8016ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d1:	00 00 00 
	stat->st_dev = dev;
  8016d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	53                   	push   %ebx
  8016de:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e1:	ff 50 14             	call   *0x14(%eax)
  8016e4:	83 c4 10             	add    $0x10,%esp
}
  8016e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    
		return -E_NOT_SUPP;
  8016ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f1:	eb f4                	jmp    8016e7 <fstat+0x6c>

008016f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f3:	f3 0f 1e fb          	endbr32 
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	6a 00                	push   $0x0
  801701:	ff 75 08             	pushl  0x8(%ebp)
  801704:	e8 01 02 00 00       	call   80190a <open>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 1b                	js     80172d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	ff 75 0c             	pushl  0xc(%ebp)
  801718:	50                   	push   %eax
  801719:	e8 5d ff ff ff       	call   80167b <fstat>
  80171e:	89 c6                	mov    %eax,%esi
	close(fd);
  801720:	89 1c 24             	mov    %ebx,(%esp)
  801723:	e8 fd fb ff ff       	call   801325 <close>
	return r;
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	89 f3                	mov    %esi,%ebx
}
  80172d:	89 d8                	mov    %ebx,%eax
  80172f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <fsipc>:
	"FSREQ_REMOVE",
	"FSREQ_SYNC",
};
static int
fsipc(unsigned type, void *dstva)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	56                   	push   %esi
  80173a:	53                   	push   %ebx
  80173b:	89 c6                	mov    %eax,%esi
  80173d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80173f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801746:	74 27                	je     80176f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %s %08x\n", thisenv->env_id, fsipctype[type-1], *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801748:	6a 07                	push   $0x7
  80174a:	68 00 50 80 00       	push   $0x805000
  80174f:	56                   	push   %esi
  801750:	ff 35 00 40 80 00    	pushl  0x804000
  801756:	e8 72 f9 ff ff       	call   8010cd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175b:	83 c4 0c             	add    $0xc,%esp
  80175e:	6a 00                	push   $0x0
  801760:	53                   	push   %ebx
  801761:	6a 00                	push   $0x0
  801763:	e8 f8 f8 ff ff       	call   801060 <ipc_recv>
}
  801768:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	6a 01                	push   $0x1
  801774:	e8 ac f9 ff ff       	call   801125 <ipc_find_env>
  801779:	a3 00 40 80 00       	mov    %eax,0x804000
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	eb c5                	jmp    801748 <fsipc+0x12>

00801783 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801783:	f3 0f 1e fb          	endbr32 
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	8b 40 0c             	mov    0xc(%eax),%eax
  801793:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801798:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8017aa:	e8 87 ff ff ff       	call   801736 <fsipc>
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <devfile_flush>:
{
  8017b1:	f3 0f 1e fb          	endbr32 
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d0:	e8 61 ff ff ff       	call   801736 <fsipc>
}
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <devfile_stat>:
{
  8017d7:	f3 0f 1e fb          	endbr32 
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	53                   	push   %ebx
  8017df:	83 ec 04             	sub    $0x4,%esp
  8017e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017eb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fa:	e8 37 ff ff ff       	call   801736 <fsipc>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 2c                	js     80182f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	68 00 50 80 00       	push   $0x805000
  80180b:	53                   	push   %ebx
  80180c:	e8 c2 ef ff ff       	call   8007d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801811:	a1 80 50 80 00       	mov    0x805080,%eax
  801816:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181c:	a1 84 50 80 00       	mov    0x805084,%eax
  801821:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devfile_write>:
{
  801834:	f3 0f 1e fb          	endbr32 
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	8b 45 10             	mov    0x10(%ebp),%eax
  801841:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801846:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80184b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80184e:	8b 55 08             	mov    0x8(%ebp),%edx
  801851:	8b 52 0c             	mov    0xc(%edx),%edx
  801854:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80185a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80185f:	50                   	push   %eax
  801860:	ff 75 0c             	pushl  0xc(%ebp)
  801863:	68 08 50 80 00       	push   $0x805008
  801868:	e8 64 f1 ff ff       	call   8009d1 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80186d:	ba 00 00 00 00       	mov    $0x0,%edx
  801872:	b8 04 00 00 00       	mov    $0x4,%eax
  801877:	e8 ba fe ff ff       	call   801736 <fsipc>
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devfile_read>:
{
  80187e:	f3 0f 1e fb          	endbr32 
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	8b 40 0c             	mov    0xc(%eax),%eax
  801890:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801895:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80189b:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a5:	e8 8c fe ff ff       	call   801736 <fsipc>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	78 1f                	js     8018cf <devfile_read+0x51>
	assert(r <= n);
  8018b0:	39 f0                	cmp    %esi,%eax
  8018b2:	77 24                	ja     8018d8 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8018b4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b9:	7f 36                	jg     8018f1 <devfile_read+0x73>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018bb:	83 ec 04             	sub    $0x4,%esp
  8018be:	50                   	push   %eax
  8018bf:	68 00 50 80 00       	push   $0x805000
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	e8 05 f1 ff ff       	call   8009d1 <memmove>
	return r;
  8018cc:	83 c4 10             	add    $0x10,%esp
}
  8018cf:	89 d8                	mov    %ebx,%eax
  8018d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d4:	5b                   	pop    %ebx
  8018d5:	5e                   	pop    %esi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    
	assert(r <= n);
  8018d8:	68 e4 2b 80 00       	push   $0x802be4
  8018dd:	68 eb 2b 80 00       	push   $0x802beb
  8018e2:	68 8c 00 00 00       	push   $0x8c
  8018e7:	68 00 2c 80 00       	push   $0x802c00
  8018ec:	e8 79 0a 00 00       	call   80236a <_panic>
	assert(r <= PGSIZE);
  8018f1:	68 0b 2c 80 00       	push   $0x802c0b
  8018f6:	68 eb 2b 80 00       	push   $0x802beb
  8018fb:	68 8d 00 00 00       	push   $0x8d
  801900:	68 00 2c 80 00       	push   $0x802c00
  801905:	e8 60 0a 00 00       	call   80236a <_panic>

0080190a <open>:
{
  80190a:	f3 0f 1e fb          	endbr32 
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	83 ec 1c             	sub    $0x1c,%esp
  801916:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801919:	56                   	push   %esi
  80191a:	e8 71 ee ff ff       	call   800790 <strlen>
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801927:	7f 6c                	jg     801995 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801929:	83 ec 0c             	sub    $0xc,%esp
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	e8 5c f8 ff ff       	call   801191 <fd_alloc>
  801935:	89 c3                	mov    %eax,%ebx
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 3c                	js     80197a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	56                   	push   %esi
  801942:	68 00 50 80 00       	push   $0x805000
  801947:	e8 87 ee ff ff       	call   8007d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80194c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801954:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801957:	b8 01 00 00 00       	mov    $0x1,%eax
  80195c:	e8 d5 fd ff ff       	call   801736 <fsipc>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	78 19                	js     801983 <open+0x79>
	return fd2num(fd);
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	ff 75 f4             	pushl  -0xc(%ebp)
  801970:	e8 ed f7 ff ff       	call   801162 <fd2num>
  801975:	89 c3                	mov    %eax,%ebx
  801977:	83 c4 10             	add    $0x10,%esp
}
  80197a:	89 d8                	mov    %ebx,%eax
  80197c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197f:	5b                   	pop    %ebx
  801980:	5e                   	pop    %esi
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    
		fd_close(fd, 0);
  801983:	83 ec 08             	sub    $0x8,%esp
  801986:	6a 00                	push   $0x0
  801988:	ff 75 f4             	pushl  -0xc(%ebp)
  80198b:	e8 0a f9 ff ff       	call   80129a <fd_close>
		return r;
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	eb e5                	jmp    80197a <open+0x70>
		return -E_BAD_PATH;
  801995:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80199a:	eb de                	jmp    80197a <open+0x70>

0080199c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199c:	f3 0f 1e fb          	endbr32 
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b0:	e8 81 fd ff ff       	call   801736 <fsipc>
}
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019b7:	f3 0f 1e fb          	endbr32 
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019c1:	68 77 2c 80 00       	push   $0x802c77
  8019c6:	ff 75 0c             	pushl  0xc(%ebp)
  8019c9:	e8 05 ee ff ff       	call   8007d3 <strcpy>
	return 0;
}
  8019ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <devsock_close>:
{
  8019d5:	f3 0f 1e fb          	endbr32 
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	53                   	push   %ebx
  8019dd:	83 ec 10             	sub    $0x10,%esp
  8019e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019e3:	53                   	push   %ebx
  8019e4:	e8 62 0a 00 00       	call   80244b <pageref>
  8019e9:	89 c2                	mov    %eax,%edx
  8019eb:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019f3:	83 fa 01             	cmp    $0x1,%edx
  8019f6:	74 05                	je     8019fd <devsock_close+0x28>
}
  8019f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	ff 73 0c             	pushl  0xc(%ebx)
  801a03:	e8 e3 02 00 00       	call   801ceb <nsipc_close>
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	eb eb                	jmp    8019f8 <devsock_close+0x23>

00801a0d <devsock_write>:
{
  801a0d:	f3 0f 1e fb          	endbr32 
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a17:	6a 00                	push   $0x0
  801a19:	ff 75 10             	pushl  0x10(%ebp)
  801a1c:	ff 75 0c             	pushl  0xc(%ebp)
  801a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a22:	ff 70 0c             	pushl  0xc(%eax)
  801a25:	e8 b5 03 00 00       	call   801ddf <nsipc_send>
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <devsock_read>:
{
  801a2c:	f3 0f 1e fb          	endbr32 
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a36:	6a 00                	push   $0x0
  801a38:	ff 75 10             	pushl  0x10(%ebp)
  801a3b:	ff 75 0c             	pushl  0xc(%ebp)
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	ff 70 0c             	pushl  0xc(%eax)
  801a44:	e8 1f 03 00 00       	call   801d68 <nsipc_recv>
}
  801a49:	c9                   	leave  
  801a4a:	c3                   	ret    

00801a4b <fd2sockid>:
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a51:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a54:	52                   	push   %edx
  801a55:	50                   	push   %eax
  801a56:	e8 8c f7 ff ff       	call   8011e7 <fd_lookup>
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 10                	js     801a72 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	8b 0d 60 30 80 00    	mov    0x803060,%ecx
  801a6b:	39 08                	cmp    %ecx,(%eax)
  801a6d:	75 05                	jne    801a74 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a6f:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    
		return -E_NOT_SUPP;
  801a74:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a79:	eb f7                	jmp    801a72 <fd2sockid+0x27>

00801a7b <alloc_sockfd>:
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 1c             	sub    $0x1c,%esp
  801a83:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a88:	50                   	push   %eax
  801a89:	e8 03 f7 ff ff       	call   801191 <fd_alloc>
  801a8e:	89 c3                	mov    %eax,%ebx
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 43                	js     801ada <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a97:	83 ec 04             	sub    $0x4,%esp
  801a9a:	68 07 04 00 00       	push   $0x407
  801a9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa2:	6a 00                	push   $0x0
  801aa4:	e8 93 f1 ff ff       	call   800c3c <sys_page_alloc>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 28                	js     801ada <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab5:	8b 15 60 30 80 00    	mov    0x803060,%edx
  801abb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ac7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	50                   	push   %eax
  801ace:	e8 8f f6 ff ff       	call   801162 <fd2num>
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	eb 0c                	jmp    801ae6 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	56                   	push   %esi
  801ade:	e8 08 02 00 00       	call   801ceb <nsipc_close>
		return r;
  801ae3:	83 c4 10             	add    $0x10,%esp
}
  801ae6:	89 d8                	mov    %ebx,%eax
  801ae8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <accept>:
{
  801aef:	f3 0f 1e fb          	endbr32 
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	e8 4a ff ff ff       	call   801a4b <fd2sockid>
  801b01:	85 c0                	test   %eax,%eax
  801b03:	78 1b                	js     801b20 <accept+0x31>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b05:	83 ec 04             	sub    $0x4,%esp
  801b08:	ff 75 10             	pushl  0x10(%ebp)
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	50                   	push   %eax
  801b0f:	e8 22 01 00 00       	call   801c36 <nsipc_accept>
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	85 c0                	test   %eax,%eax
  801b19:	78 05                	js     801b20 <accept+0x31>
	return alloc_sockfd(r);
  801b1b:	e8 5b ff ff ff       	call   801a7b <alloc_sockfd>
}
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <bind>:
{
  801b22:	f3 0f 1e fb          	endbr32 
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2f:	e8 17 ff ff ff       	call   801a4b <fd2sockid>
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 12                	js     801b4a <bind+0x28>
	return nsipc_bind(r, name, namelen);
  801b38:	83 ec 04             	sub    $0x4,%esp
  801b3b:	ff 75 10             	pushl  0x10(%ebp)
  801b3e:	ff 75 0c             	pushl  0xc(%ebp)
  801b41:	50                   	push   %eax
  801b42:	e8 45 01 00 00       	call   801c8c <nsipc_bind>
  801b47:	83 c4 10             	add    $0x10,%esp
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <shutdown>:
{
  801b4c:	f3 0f 1e fb          	endbr32 
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	e8 ed fe ff ff       	call   801a4b <fd2sockid>
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 0f                	js     801b71 <shutdown+0x25>
	return nsipc_shutdown(r, how);
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	ff 75 0c             	pushl  0xc(%ebp)
  801b68:	50                   	push   %eax
  801b69:	e8 57 01 00 00       	call   801cc5 <nsipc_shutdown>
  801b6e:	83 c4 10             	add    $0x10,%esp
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <connect>:
{
  801b73:	f3 0f 1e fb          	endbr32 
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b80:	e8 c6 fe ff ff       	call   801a4b <fd2sockid>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 12                	js     801b9b <connect+0x28>
	return nsipc_connect(r, name, namelen);
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	ff 75 10             	pushl  0x10(%ebp)
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	50                   	push   %eax
  801b93:	e8 71 01 00 00       	call   801d09 <nsipc_connect>
  801b98:	83 c4 10             	add    $0x10,%esp
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <listen>:
{
  801b9d:	f3 0f 1e fb          	endbr32 
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	e8 9c fe ff ff       	call   801a4b <fd2sockid>
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	78 0f                	js     801bc2 <listen+0x25>
	return nsipc_listen(r, backlog);
  801bb3:	83 ec 08             	sub    $0x8,%esp
  801bb6:	ff 75 0c             	pushl  0xc(%ebp)
  801bb9:	50                   	push   %eax
  801bba:	e8 83 01 00 00       	call   801d42 <nsipc_listen>
  801bbf:	83 c4 10             	add    $0x10,%esp
}
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <socket>:

int
socket(int domain, int type, int protocol)
{
  801bc4:	f3 0f 1e fb          	endbr32 
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bce:	ff 75 10             	pushl  0x10(%ebp)
  801bd1:	ff 75 0c             	pushl  0xc(%ebp)
  801bd4:	ff 75 08             	pushl  0x8(%ebp)
  801bd7:	e8 65 02 00 00       	call   801e41 <nsipc_socket>
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	78 05                	js     801be8 <socket+0x24>
		return r;
	return alloc_sockfd(r);
  801be3:	e8 93 fe ff ff       	call   801a7b <alloc_sockfd>
}
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	53                   	push   %ebx
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bf3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bfa:	74 26                	je     801c22 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bfc:	6a 07                	push   $0x7
  801bfe:	68 00 60 80 00       	push   $0x806000
  801c03:	53                   	push   %ebx
  801c04:	ff 35 04 40 80 00    	pushl  0x804004
  801c0a:	e8 be f4 ff ff       	call   8010cd <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c0f:	83 c4 0c             	add    $0xc,%esp
  801c12:	6a 00                	push   $0x0
  801c14:	6a 00                	push   $0x0
  801c16:	6a 00                	push   $0x0
  801c18:	e8 43 f4 ff ff       	call   801060 <ipc_recv>
}
  801c1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c22:	83 ec 0c             	sub    $0xc,%esp
  801c25:	6a 02                	push   $0x2
  801c27:	e8 f9 f4 ff ff       	call   801125 <ipc_find_env>
  801c2c:	a3 04 40 80 00       	mov    %eax,0x804004
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	eb c6                	jmp    801bfc <nsipc+0x12>

00801c36 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c36:	f3 0f 1e fb          	endbr32 
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	56                   	push   %esi
  801c3e:	53                   	push   %ebx
  801c3f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c4a:	8b 06                	mov    (%esi),%eax
  801c4c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	e8 8f ff ff ff       	call   801bea <nsipc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	79 09                	jns    801c6a <nsipc_accept+0x34>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c61:	89 d8                	mov    %ebx,%eax
  801c63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c66:	5b                   	pop    %ebx
  801c67:	5e                   	pop    %esi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	ff 35 10 60 80 00    	pushl  0x806010
  801c73:	68 00 60 80 00       	push   $0x806000
  801c78:	ff 75 0c             	pushl  0xc(%ebp)
  801c7b:	e8 51 ed ff ff       	call   8009d1 <memmove>
		*addrlen = ret->ret_addrlen;
  801c80:	a1 10 60 80 00       	mov    0x806010,%eax
  801c85:	89 06                	mov    %eax,(%esi)
  801c87:	83 c4 10             	add    $0x10,%esp
	return r;
  801c8a:	eb d5                	jmp    801c61 <nsipc_accept+0x2b>

00801c8c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c8c:	f3 0f 1e fb          	endbr32 
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	53                   	push   %ebx
  801c94:	83 ec 08             	sub    $0x8,%esp
  801c97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ca2:	53                   	push   %ebx
  801ca3:	ff 75 0c             	pushl  0xc(%ebp)
  801ca6:	68 04 60 80 00       	push   $0x806004
  801cab:	e8 21 ed ff ff       	call   8009d1 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cb0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cb6:	b8 02 00 00 00       	mov    $0x2,%eax
  801cbb:	e8 2a ff ff ff       	call   801bea <nsipc>
}
  801cc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cc5:	f3 0f 1e fb          	endbr32 
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cda:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cdf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce4:	e8 01 ff ff ff       	call   801bea <nsipc>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <nsipc_close>:

int
nsipc_close(int s)
{
  801ceb:	f3 0f 1e fb          	endbr32 
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cfd:	b8 04 00 00 00       	mov    $0x4,%eax
  801d02:	e8 e3 fe ff ff       	call   801bea <nsipc>
}
  801d07:	c9                   	leave  
  801d08:	c3                   	ret    

00801d09 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d09:	f3 0f 1e fb          	endbr32 
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	53                   	push   %ebx
  801d11:	83 ec 08             	sub    $0x8,%esp
  801d14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d17:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d1f:	53                   	push   %ebx
  801d20:	ff 75 0c             	pushl  0xc(%ebp)
  801d23:	68 04 60 80 00       	push   $0x806004
  801d28:	e8 a4 ec ff ff       	call   8009d1 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d2d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d33:	b8 05 00 00 00       	mov    $0x5,%eax
  801d38:	e8 ad fe ff ff       	call   801bea <nsipc>
}
  801d3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d42:	f3 0f 1e fb          	endbr32 
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d57:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d5c:	b8 06 00 00 00       	mov    $0x6,%eax
  801d61:	e8 84 fe ff ff       	call   801bea <nsipc>
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d68:	f3 0f 1e fb          	endbr32 
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	56                   	push   %esi
  801d70:	53                   	push   %ebx
  801d71:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d74:	8b 45 08             	mov    0x8(%ebp),%eax
  801d77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d7c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d82:	8b 45 14             	mov    0x14(%ebp),%eax
  801d85:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d8a:	b8 07 00 00 00       	mov    $0x7,%eax
  801d8f:	e8 56 fe ff ff       	call   801bea <nsipc>
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 26                	js     801dc0 <nsipc_recv+0x58>
		assert(r < 1600 && r <= len);
  801d9a:	81 fe 3f 06 00 00    	cmp    $0x63f,%esi
  801da0:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801da5:	0f 4e c6             	cmovle %esi,%eax
  801da8:	39 c3                	cmp    %eax,%ebx
  801daa:	7f 1d                	jg     801dc9 <nsipc_recv+0x61>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801dac:	83 ec 04             	sub    $0x4,%esp
  801daf:	53                   	push   %ebx
  801db0:	68 00 60 80 00       	push   $0x806000
  801db5:	ff 75 0c             	pushl  0xc(%ebp)
  801db8:	e8 14 ec ff ff       	call   8009d1 <memmove>
  801dbd:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dc0:	89 d8                	mov    %ebx,%eax
  801dc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5d                   	pop    %ebp
  801dc8:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801dc9:	68 83 2c 80 00       	push   $0x802c83
  801dce:	68 eb 2b 80 00       	push   $0x802beb
  801dd3:	6a 62                	push   $0x62
  801dd5:	68 98 2c 80 00       	push   $0x802c98
  801dda:	e8 8b 05 00 00       	call   80236a <_panic>

00801ddf <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ddf:	f3 0f 1e fb          	endbr32 
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	53                   	push   %ebx
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801df5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dfb:	7f 2e                	jg     801e2b <nsipc_send+0x4c>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dfd:	83 ec 04             	sub    $0x4,%esp
  801e00:	53                   	push   %ebx
  801e01:	ff 75 0c             	pushl  0xc(%ebp)
  801e04:	68 0c 60 80 00       	push   $0x80600c
  801e09:	e8 c3 eb ff ff       	call   8009d1 <memmove>
	nsipcbuf.send.req_size = size;
  801e0e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e14:	8b 45 14             	mov    0x14(%ebp),%eax
  801e17:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e1c:	b8 08 00 00 00       	mov    $0x8,%eax
  801e21:	e8 c4 fd ff ff       	call   801bea <nsipc>
}
  801e26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    
	assert(size < 1600);
  801e2b:	68 a4 2c 80 00       	push   $0x802ca4
  801e30:	68 eb 2b 80 00       	push   $0x802beb
  801e35:	6a 6d                	push   $0x6d
  801e37:	68 98 2c 80 00       	push   $0x802c98
  801e3c:	e8 29 05 00 00       	call   80236a <_panic>

00801e41 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e41:	f3 0f 1e fb          	endbr32 
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e56:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e63:	b8 09 00 00 00       	mov    $0x9,%eax
  801e68:	e8 7d fd ff ff       	call   801bea <nsipc>
}
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e6f:	f3 0f 1e fb          	endbr32 
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 08             	pushl  0x8(%ebp)
  801e81:	e8 f0 f2 ff ff       	call   801176 <fd2data>
  801e86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e88:	83 c4 08             	add    $0x8,%esp
  801e8b:	68 b0 2c 80 00       	push   $0x802cb0
  801e90:	53                   	push   %ebx
  801e91:	e8 3d e9 ff ff       	call   8007d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e96:	8b 46 04             	mov    0x4(%esi),%eax
  801e99:	2b 06                	sub    (%esi),%eax
  801e9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ea1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea8:	00 00 00 
	stat->st_dev = &devpipe;
  801eab:	c7 83 88 00 00 00 7c 	movl   $0x80307c,0x88(%ebx)
  801eb2:	30 80 00 
	return 0;
}
  801eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ec1:	f3 0f 1e fb          	endbr32 
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	53                   	push   %ebx
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ecf:	53                   	push   %ebx
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 b0 ed ff ff       	call   800c87 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed7:	89 1c 24             	mov    %ebx,(%esp)
  801eda:	e8 97 f2 ff ff       	call   801176 <fd2data>
  801edf:	83 c4 08             	add    $0x8,%esp
  801ee2:	50                   	push   %eax
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 9d ed ff ff       	call   800c87 <sys_page_unmap>
}
  801eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <_pipeisclosed>:
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	57                   	push   %edi
  801ef3:	56                   	push   %esi
  801ef4:	53                   	push   %ebx
  801ef5:	83 ec 1c             	sub    $0x1c,%esp
  801ef8:	89 c7                	mov    %eax,%edi
  801efa:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801efc:	a1 08 40 80 00       	mov    0x804008,%eax
  801f01:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	57                   	push   %edi
  801f08:	e8 3e 05 00 00       	call   80244b <pageref>
  801f0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f10:	89 34 24             	mov    %esi,(%esp)
  801f13:	e8 33 05 00 00       	call   80244b <pageref>
		nn = thisenv->env_runs;
  801f18:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f1e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	39 cb                	cmp    %ecx,%ebx
  801f26:	74 1b                	je     801f43 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f28:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f2b:	75 cf                	jne    801efc <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f2d:	8b 42 58             	mov    0x58(%edx),%eax
  801f30:	6a 01                	push   $0x1
  801f32:	50                   	push   %eax
  801f33:	53                   	push   %ebx
  801f34:	68 b7 2c 80 00       	push   $0x802cb7
  801f39:	e8 8b e2 ff ff       	call   8001c9 <cprintf>
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	eb b9                	jmp    801efc <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f43:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f46:	0f 94 c0             	sete   %al
  801f49:	0f b6 c0             	movzbl %al,%eax
}
  801f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <devpipe_write>:
{
  801f54:	f3 0f 1e fb          	endbr32 
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 28             	sub    $0x28,%esp
  801f61:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f64:	56                   	push   %esi
  801f65:	e8 0c f2 ff ff       	call   801176 <fd2data>
  801f6a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f74:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f77:	74 4f                	je     801fc8 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f79:	8b 43 04             	mov    0x4(%ebx),%eax
  801f7c:	8b 0b                	mov    (%ebx),%ecx
  801f7e:	8d 51 20             	lea    0x20(%ecx),%edx
  801f81:	39 d0                	cmp    %edx,%eax
  801f83:	72 14                	jb     801f99 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801f85:	89 da                	mov    %ebx,%edx
  801f87:	89 f0                	mov    %esi,%eax
  801f89:	e8 61 ff ff ff       	call   801eef <_pipeisclosed>
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	75 3b                	jne    801fcd <devpipe_write+0x79>
			sys_yield();
  801f92:	e8 82 ec ff ff       	call   800c19 <sys_yield>
  801f97:	eb e0                	jmp    801f79 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f9c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fa0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fa3:	89 c2                	mov    %eax,%edx
  801fa5:	c1 fa 1f             	sar    $0x1f,%edx
  801fa8:	89 d1                	mov    %edx,%ecx
  801faa:	c1 e9 1b             	shr    $0x1b,%ecx
  801fad:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fb0:	83 e2 1f             	and    $0x1f,%edx
  801fb3:	29 ca                	sub    %ecx,%edx
  801fb5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fbd:	83 c0 01             	add    $0x1,%eax
  801fc0:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fc3:	83 c7 01             	add    $0x1,%edi
  801fc6:	eb ac                	jmp    801f74 <devpipe_write+0x20>
	return i;
  801fc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcb:	eb 05                	jmp    801fd2 <devpipe_write+0x7e>
				return 0;
  801fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5f                   	pop    %edi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <devpipe_read>:
{
  801fda:	f3 0f 1e fb          	endbr32 
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 18             	sub    $0x18,%esp
  801fe7:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fea:	57                   	push   %edi
  801feb:	e8 86 f1 ff ff       	call   801176 <fd2data>
  801ff0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	be 00 00 00 00       	mov    $0x0,%esi
  801ffa:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ffd:	75 14                	jne    802013 <devpipe_read+0x39>
	return i;
  801fff:	8b 45 10             	mov    0x10(%ebp),%eax
  802002:	eb 02                	jmp    802006 <devpipe_read+0x2c>
				return i;
  802004:	89 f0                	mov    %esi,%eax
}
  802006:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802009:	5b                   	pop    %ebx
  80200a:	5e                   	pop    %esi
  80200b:	5f                   	pop    %edi
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    
			sys_yield();
  80200e:	e8 06 ec ff ff       	call   800c19 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802013:	8b 03                	mov    (%ebx),%eax
  802015:	3b 43 04             	cmp    0x4(%ebx),%eax
  802018:	75 18                	jne    802032 <devpipe_read+0x58>
			if (i > 0)
  80201a:	85 f6                	test   %esi,%esi
  80201c:	75 e6                	jne    802004 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80201e:	89 da                	mov    %ebx,%edx
  802020:	89 f8                	mov    %edi,%eax
  802022:	e8 c8 fe ff ff       	call   801eef <_pipeisclosed>
  802027:	85 c0                	test   %eax,%eax
  802029:	74 e3                	je     80200e <devpipe_read+0x34>
				return 0;
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
  802030:	eb d4                	jmp    802006 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802032:	99                   	cltd   
  802033:	c1 ea 1b             	shr    $0x1b,%edx
  802036:	01 d0                	add    %edx,%eax
  802038:	83 e0 1f             	and    $0x1f,%eax
  80203b:	29 d0                	sub    %edx,%eax
  80203d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802042:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802045:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802048:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80204b:	83 c6 01             	add    $0x1,%esi
  80204e:	eb aa                	jmp    801ffa <devpipe_read+0x20>

00802050 <pipe>:
{
  802050:	f3 0f 1e fb          	endbr32 
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	56                   	push   %esi
  802058:	53                   	push   %ebx
  802059:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80205c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80205f:	50                   	push   %eax
  802060:	e8 2c f1 ff ff       	call   801191 <fd_alloc>
  802065:	89 c3                	mov    %eax,%ebx
  802067:	83 c4 10             	add    $0x10,%esp
  80206a:	85 c0                	test   %eax,%eax
  80206c:	0f 88 23 01 00 00    	js     802195 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802072:	83 ec 04             	sub    $0x4,%esp
  802075:	68 07 04 00 00       	push   $0x407
  80207a:	ff 75 f4             	pushl  -0xc(%ebp)
  80207d:	6a 00                	push   $0x0
  80207f:	e8 b8 eb ff ff       	call   800c3c <sys_page_alloc>
  802084:	89 c3                	mov    %eax,%ebx
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	0f 88 04 01 00 00    	js     802195 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802091:	83 ec 0c             	sub    $0xc,%esp
  802094:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802097:	50                   	push   %eax
  802098:	e8 f4 f0 ff ff       	call   801191 <fd_alloc>
  80209d:	89 c3                	mov    %eax,%ebx
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	0f 88 db 00 00 00    	js     802185 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020aa:	83 ec 04             	sub    $0x4,%esp
  8020ad:	68 07 04 00 00       	push   $0x407
  8020b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b5:	6a 00                	push   $0x0
  8020b7:	e8 80 eb ff ff       	call   800c3c <sys_page_alloc>
  8020bc:	89 c3                	mov    %eax,%ebx
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	0f 88 bc 00 00 00    	js     802185 <pipe+0x135>
	va = fd2data(fd0);
  8020c9:	83 ec 0c             	sub    $0xc,%esp
  8020cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020cf:	e8 a2 f0 ff ff       	call   801176 <fd2data>
  8020d4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d6:	83 c4 0c             	add    $0xc,%esp
  8020d9:	68 07 04 00 00       	push   $0x407
  8020de:	50                   	push   %eax
  8020df:	6a 00                	push   $0x0
  8020e1:	e8 56 eb ff ff       	call   800c3c <sys_page_alloc>
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	0f 88 82 00 00 00    	js     802175 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f3:	83 ec 0c             	sub    $0xc,%esp
  8020f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f9:	e8 78 f0 ff ff       	call   801176 <fd2data>
  8020fe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802105:	50                   	push   %eax
  802106:	6a 00                	push   $0x0
  802108:	56                   	push   %esi
  802109:	6a 00                	push   $0x0
  80210b:	e8 52 eb ff ff       	call   800c62 <sys_page_map>
  802110:	89 c3                	mov    %eax,%ebx
  802112:	83 c4 20             	add    $0x20,%esp
  802115:	85 c0                	test   %eax,%eax
  802117:	78 4e                	js     802167 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802119:	a1 7c 30 80 00       	mov    0x80307c,%eax
  80211e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802121:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802123:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802126:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80212d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802130:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802135:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80213c:	83 ec 0c             	sub    $0xc,%esp
  80213f:	ff 75 f4             	pushl  -0xc(%ebp)
  802142:	e8 1b f0 ff ff       	call   801162 <fd2num>
  802147:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80214a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80214c:	83 c4 04             	add    $0x4,%esp
  80214f:	ff 75 f0             	pushl  -0x10(%ebp)
  802152:	e8 0b f0 ff ff       	call   801162 <fd2num>
  802157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80215a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	bb 00 00 00 00       	mov    $0x0,%ebx
  802165:	eb 2e                	jmp    802195 <pipe+0x145>
	sys_page_unmap(0, va);
  802167:	83 ec 08             	sub    $0x8,%esp
  80216a:	56                   	push   %esi
  80216b:	6a 00                	push   $0x0
  80216d:	e8 15 eb ff ff       	call   800c87 <sys_page_unmap>
  802172:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802175:	83 ec 08             	sub    $0x8,%esp
  802178:	ff 75 f0             	pushl  -0x10(%ebp)
  80217b:	6a 00                	push   $0x0
  80217d:	e8 05 eb ff ff       	call   800c87 <sys_page_unmap>
  802182:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802185:	83 ec 08             	sub    $0x8,%esp
  802188:	ff 75 f4             	pushl  -0xc(%ebp)
  80218b:	6a 00                	push   $0x0
  80218d:	e8 f5 ea ff ff       	call   800c87 <sys_page_unmap>
  802192:	83 c4 10             	add    $0x10,%esp
}
  802195:	89 d8                	mov    %ebx,%eax
  802197:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80219a:	5b                   	pop    %ebx
  80219b:	5e                   	pop    %esi
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    

0080219e <pipeisclosed>:
{
  80219e:	f3 0f 1e fb          	endbr32 
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ab:	50                   	push   %eax
  8021ac:	ff 75 08             	pushl  0x8(%ebp)
  8021af:	e8 33 f0 ff ff       	call   8011e7 <fd_lookup>
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	85 c0                	test   %eax,%eax
  8021b9:	78 18                	js     8021d3 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8021bb:	83 ec 0c             	sub    $0xc,%esp
  8021be:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c1:	e8 b0 ef ff ff       	call   801176 <fd2data>
  8021c6:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cb:	e8 1f fd ff ff       	call   801eef <_pipeisclosed>
  8021d0:	83 c4 10             	add    $0x10,%esp
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    

008021d5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021d5:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8021d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8021de:	c3                   	ret    

008021df <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021df:	f3 0f 1e fb          	endbr32 
  8021e3:	55                   	push   %ebp
  8021e4:	89 e5                	mov    %esp,%ebp
  8021e6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021e9:	68 cf 2c 80 00       	push   $0x802ccf
  8021ee:	ff 75 0c             	pushl  0xc(%ebp)
  8021f1:	e8 dd e5 ff ff       	call   8007d3 <strcpy>
	return 0;
}
  8021f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fb:	c9                   	leave  
  8021fc:	c3                   	ret    

008021fd <devcons_write>:
{
  8021fd:	f3 0f 1e fb          	endbr32 
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	57                   	push   %edi
  802205:	56                   	push   %esi
  802206:	53                   	push   %ebx
  802207:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80220d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802212:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802218:	3b 75 10             	cmp    0x10(%ebp),%esi
  80221b:	73 31                	jae    80224e <devcons_write+0x51>
		m = n - tot;
  80221d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802220:	29 f3                	sub    %esi,%ebx
  802222:	83 fb 7f             	cmp    $0x7f,%ebx
  802225:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80222a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80222d:	83 ec 04             	sub    $0x4,%esp
  802230:	53                   	push   %ebx
  802231:	89 f0                	mov    %esi,%eax
  802233:	03 45 0c             	add    0xc(%ebp),%eax
  802236:	50                   	push   %eax
  802237:	57                   	push   %edi
  802238:	e8 94 e7 ff ff       	call   8009d1 <memmove>
		sys_cputs(buf, m);
  80223d:	83 c4 08             	add    $0x8,%esp
  802240:	53                   	push   %ebx
  802241:	57                   	push   %edi
  802242:	e8 46 e9 ff ff       	call   800b8d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802247:	01 de                	add    %ebx,%esi
  802249:	83 c4 10             	add    $0x10,%esp
  80224c:	eb ca                	jmp    802218 <devcons_write+0x1b>
}
  80224e:	89 f0                	mov    %esi,%eax
  802250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    

00802258 <devcons_read>:
{
  802258:	f3 0f 1e fb          	endbr32 
  80225c:	55                   	push   %ebp
  80225d:	89 e5                	mov    %esp,%ebp
  80225f:	83 ec 08             	sub    $0x8,%esp
  802262:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802267:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80226b:	74 21                	je     80228e <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80226d:	e8 3d e9 ff ff       	call   800baf <sys_cgetc>
  802272:	85 c0                	test   %eax,%eax
  802274:	75 07                	jne    80227d <devcons_read+0x25>
		sys_yield();
  802276:	e8 9e e9 ff ff       	call   800c19 <sys_yield>
  80227b:	eb f0                	jmp    80226d <devcons_read+0x15>
	if (c < 0)
  80227d:	78 0f                	js     80228e <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80227f:	83 f8 04             	cmp    $0x4,%eax
  802282:	74 0c                	je     802290 <devcons_read+0x38>
	*(char*)vbuf = c;
  802284:	8b 55 0c             	mov    0xc(%ebp),%edx
  802287:	88 02                	mov    %al,(%edx)
	return 1;
  802289:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80228e:	c9                   	leave  
  80228f:	c3                   	ret    
		return 0;
  802290:	b8 00 00 00 00       	mov    $0x0,%eax
  802295:	eb f7                	jmp    80228e <devcons_read+0x36>

00802297 <cputchar>:
{
  802297:	f3 0f 1e fb          	endbr32 
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8022a7:	6a 01                	push   $0x1
  8022a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ac:	50                   	push   %eax
  8022ad:	e8 db e8 ff ff       	call   800b8d <sys_cputs>
}
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <getchar>:
{
  8022b7:	f3 0f 1e fb          	endbr32 
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8022c1:	6a 01                	push   $0x1
  8022c3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022c6:	50                   	push   %eax
  8022c7:	6a 00                	push   $0x0
  8022c9:	e8 a1 f1 ff ff       	call   80146f <read>
	if (r < 0)
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	78 06                	js     8022db <getchar+0x24>
	if (r < 1)
  8022d5:	74 06                	je     8022dd <getchar+0x26>
	return c;
  8022d7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8022db:	c9                   	leave  
  8022dc:	c3                   	ret    
		return -E_EOF;
  8022dd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8022e2:	eb f7                	jmp    8022db <getchar+0x24>

008022e4 <iscons>:
{
  8022e4:	f3 0f 1e fb          	endbr32 
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f1:	50                   	push   %eax
  8022f2:	ff 75 08             	pushl  0x8(%ebp)
  8022f5:	e8 ed ee ff ff       	call   8011e7 <fd_lookup>
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	85 c0                	test   %eax,%eax
  8022ff:	78 11                	js     802312 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802301:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802304:	8b 15 98 30 80 00    	mov    0x803098,%edx
  80230a:	39 10                	cmp    %edx,(%eax)
  80230c:	0f 94 c0             	sete   %al
  80230f:	0f b6 c0             	movzbl %al,%eax
}
  802312:	c9                   	leave  
  802313:	c3                   	ret    

00802314 <opencons>:
{
  802314:	f3 0f 1e fb          	endbr32 
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80231e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802321:	50                   	push   %eax
  802322:	e8 6a ee ff ff       	call   801191 <fd_alloc>
  802327:	83 c4 10             	add    $0x10,%esp
  80232a:	85 c0                	test   %eax,%eax
  80232c:	78 3a                	js     802368 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80232e:	83 ec 04             	sub    $0x4,%esp
  802331:	68 07 04 00 00       	push   $0x407
  802336:	ff 75 f4             	pushl  -0xc(%ebp)
  802339:	6a 00                	push   $0x0
  80233b:	e8 fc e8 ff ff       	call   800c3c <sys_page_alloc>
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	85 c0                	test   %eax,%eax
  802345:	78 21                	js     802368 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802347:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234a:	8b 15 98 30 80 00    	mov    0x803098,%edx
  802350:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80235c:	83 ec 0c             	sub    $0xc,%esp
  80235f:	50                   	push   %eax
  802360:	e8 fd ed ff ff       	call   801162 <fd2num>
  802365:	83 c4 10             	add    $0x10,%esp
}
  802368:	c9                   	leave  
  802369:	c3                   	ret    

0080236a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80236a:	f3 0f 1e fb          	endbr32 
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	56                   	push   %esi
  802372:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802373:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802376:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80237c:	e8 75 e8 ff ff       	call   800bf6 <sys_getenvid>
  802381:	83 ec 0c             	sub    $0xc,%esp
  802384:	ff 75 0c             	pushl  0xc(%ebp)
  802387:	ff 75 08             	pushl  0x8(%ebp)
  80238a:	56                   	push   %esi
  80238b:	50                   	push   %eax
  80238c:	68 dc 2c 80 00       	push   $0x802cdc
  802391:	e8 33 de ff ff       	call   8001c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802396:	83 c4 18             	add    $0x18,%esp
  802399:	53                   	push   %ebx
  80239a:	ff 75 10             	pushl  0x10(%ebp)
  80239d:	e8 d2 dd ff ff       	call   800174 <vcprintf>
	cprintf("\n");
  8023a2:	c7 04 24 c8 2c 80 00 	movl   $0x802cc8,(%esp)
  8023a9:	e8 1b de ff ff       	call   8001c9 <cprintf>
  8023ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023b1:	cc                   	int3   
  8023b2:	eb fd                	jmp    8023b1 <_panic+0x47>

008023b4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023b4:	f3 0f 1e fb          	endbr32 
  8023b8:	55                   	push   %ebp
  8023b9:	89 e5                	mov    %esp,%ebp
  8023bb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023be:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023c5:	74 0a                	je     8023d1 <set_pgfault_handler+0x1d>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
		}
		
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ca:	a3 00 70 80 00       	mov    %eax,0x807000

}
  8023cf:	c9                   	leave  
  8023d0:	c3                   	ret    
		if((r = sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P))<0){
  8023d1:	83 ec 04             	sub    $0x4,%esp
  8023d4:	6a 07                	push   $0x7
  8023d6:	68 00 f0 bf ee       	push   $0xeebff000
  8023db:	6a 00                	push   $0x0
  8023dd:	e8 5a e8 ff ff       	call   800c3c <sys_page_alloc>
  8023e2:	83 c4 10             	add    $0x10,%esp
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	78 2a                	js     802413 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall)<0){ 
  8023e9:	83 ec 08             	sub    $0x8,%esp
  8023ec:	68 27 24 80 00       	push   $0x802427
  8023f1:	6a 00                	push   $0x0
  8023f3:	e8 fe e8 ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>
  8023f8:	83 c4 10             	add    $0x10,%esp
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	79 c8                	jns    8023c7 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail\n");
  8023ff:	83 ec 04             	sub    $0x4,%esp
  802402:	68 2c 2d 80 00       	push   $0x802d2c
  802407:	6a 2c                	push   $0x2c
  802409:	68 62 2d 80 00       	push   $0x802d62
  80240e:	e8 57 ff ff ff       	call   80236a <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  802413:	83 ec 04             	sub    $0x4,%esp
  802416:	68 00 2d 80 00       	push   $0x802d00
  80241b:	6a 22                	push   $0x22
  80241d:	68 62 2d 80 00       	push   $0x802d62
  802422:	e8 43 ff ff ff       	call   80236a <_panic>

00802427 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802427:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802428:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax   			// 间接寻址
  80242d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80242f:	83 c4 04             	add    $0x4,%esp
	/* 
	 * return address 即trap time eip的值
	 * 我们要做的就是将trap time eip的值写入trap time esp所指向的上一个trapframe
	 * 其实就是在模拟stack调用过程
	*/
	movl 0x28(%esp), %eax;	// 获取trap time eip的值并存在%eax中
  802432:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp);  // trap-time esp = trap-time esp - 4
  802436:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %edx;    // 将trap time esp的地址放入当前esp中
  80243b:	8b 54 24 30          	mov    0x30(%esp),%edx
	movl %eax, (%edx);   // 将trap time eip的值写入trap time esp所指向的位置的地址 
  80243f:	89 02                	mov    %eax,(%edx)
	// 思考：为什么可以写入呢？
	// 此时return address就已经设置好了 最后ret时可以找到目标地址了
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp;  // remove掉utf_err和utf_fault_va	
  802441:	83 c4 08             	add    $0x8,%esp
	popal;			// pop掉general registers
  802444:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp; // remove掉trap time eip 因为我们已经设置好了
  802445:	83 c4 04             	add    $0x4,%esp
	popfl;		 // restore eflags
  802448:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl	%esp; // %esp获取到了trap time esp的值
  802449:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret;	// ret instruction 做了两件事
  80244a:	c3                   	ret    

0080244b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80244b:	f3 0f 1e fb          	endbr32 
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802455:	89 c2                	mov    %eax,%edx
  802457:	c1 ea 16             	shr    $0x16,%edx
  80245a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802461:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802466:	f6 c1 01             	test   $0x1,%cl
  802469:	74 1c                	je     802487 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80246b:	c1 e8 0c             	shr    $0xc,%eax
  80246e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802475:	a8 01                	test   $0x1,%al
  802477:	74 0e                	je     802487 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802479:	c1 e8 0c             	shr    $0xc,%eax
  80247c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802483:	ef 
  802484:	0f b7 d2             	movzwl %dx,%edx
}
  802487:	89 d0                	mov    %edx,%eax
  802489:	5d                   	pop    %ebp
  80248a:	c3                   	ret    
  80248b:	66 90                	xchg   %ax,%ax
  80248d:	66 90                	xchg   %ax,%ax
  80248f:	90                   	nop

00802490 <__udivdi3>:
  802490:	f3 0f 1e fb          	endbr32 
  802494:	55                   	push   %ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	83 ec 1c             	sub    $0x1c,%esp
  80249b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80249f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024ab:	85 d2                	test   %edx,%edx
  8024ad:	75 19                	jne    8024c8 <__udivdi3+0x38>
  8024af:	39 f3                	cmp    %esi,%ebx
  8024b1:	76 4d                	jbe    802500 <__udivdi3+0x70>
  8024b3:	31 ff                	xor    %edi,%edi
  8024b5:	89 e8                	mov    %ebp,%eax
  8024b7:	89 f2                	mov    %esi,%edx
  8024b9:	f7 f3                	div    %ebx
  8024bb:	89 fa                	mov    %edi,%edx
  8024bd:	83 c4 1c             	add    $0x1c,%esp
  8024c0:	5b                   	pop    %ebx
  8024c1:	5e                   	pop    %esi
  8024c2:	5f                   	pop    %edi
  8024c3:	5d                   	pop    %ebp
  8024c4:	c3                   	ret    
  8024c5:	8d 76 00             	lea    0x0(%esi),%esi
  8024c8:	39 f2                	cmp    %esi,%edx
  8024ca:	76 14                	jbe    8024e0 <__udivdi3+0x50>
  8024cc:	31 ff                	xor    %edi,%edi
  8024ce:	31 c0                	xor    %eax,%eax
  8024d0:	89 fa                	mov    %edi,%edx
  8024d2:	83 c4 1c             	add    $0x1c,%esp
  8024d5:	5b                   	pop    %ebx
  8024d6:	5e                   	pop    %esi
  8024d7:	5f                   	pop    %edi
  8024d8:	5d                   	pop    %ebp
  8024d9:	c3                   	ret    
  8024da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e0:	0f bd fa             	bsr    %edx,%edi
  8024e3:	83 f7 1f             	xor    $0x1f,%edi
  8024e6:	75 48                	jne    802530 <__udivdi3+0xa0>
  8024e8:	39 f2                	cmp    %esi,%edx
  8024ea:	72 06                	jb     8024f2 <__udivdi3+0x62>
  8024ec:	31 c0                	xor    %eax,%eax
  8024ee:	39 eb                	cmp    %ebp,%ebx
  8024f0:	77 de                	ja     8024d0 <__udivdi3+0x40>
  8024f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f7:	eb d7                	jmp    8024d0 <__udivdi3+0x40>
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d9                	mov    %ebx,%ecx
  802502:	85 db                	test   %ebx,%ebx
  802504:	75 0b                	jne    802511 <__udivdi3+0x81>
  802506:	b8 01 00 00 00       	mov    $0x1,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	f7 f3                	div    %ebx
  80250f:	89 c1                	mov    %eax,%ecx
  802511:	31 d2                	xor    %edx,%edx
  802513:	89 f0                	mov    %esi,%eax
  802515:	f7 f1                	div    %ecx
  802517:	89 c6                	mov    %eax,%esi
  802519:	89 e8                	mov    %ebp,%eax
  80251b:	89 f7                	mov    %esi,%edi
  80251d:	f7 f1                	div    %ecx
  80251f:	89 fa                	mov    %edi,%edx
  802521:	83 c4 1c             	add    $0x1c,%esp
  802524:	5b                   	pop    %ebx
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802530:	89 f9                	mov    %edi,%ecx
  802532:	b8 20 00 00 00       	mov    $0x20,%eax
  802537:	29 f8                	sub    %edi,%eax
  802539:	d3 e2                	shl    %cl,%edx
  80253b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80253f:	89 c1                	mov    %eax,%ecx
  802541:	89 da                	mov    %ebx,%edx
  802543:	d3 ea                	shr    %cl,%edx
  802545:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802549:	09 d1                	or     %edx,%ecx
  80254b:	89 f2                	mov    %esi,%edx
  80254d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802551:	89 f9                	mov    %edi,%ecx
  802553:	d3 e3                	shl    %cl,%ebx
  802555:	89 c1                	mov    %eax,%ecx
  802557:	d3 ea                	shr    %cl,%edx
  802559:	89 f9                	mov    %edi,%ecx
  80255b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80255f:	89 eb                	mov    %ebp,%ebx
  802561:	d3 e6                	shl    %cl,%esi
  802563:	89 c1                	mov    %eax,%ecx
  802565:	d3 eb                	shr    %cl,%ebx
  802567:	09 de                	or     %ebx,%esi
  802569:	89 f0                	mov    %esi,%eax
  80256b:	f7 74 24 08          	divl   0x8(%esp)
  80256f:	89 d6                	mov    %edx,%esi
  802571:	89 c3                	mov    %eax,%ebx
  802573:	f7 64 24 0c          	mull   0xc(%esp)
  802577:	39 d6                	cmp    %edx,%esi
  802579:	72 15                	jb     802590 <__udivdi3+0x100>
  80257b:	89 f9                	mov    %edi,%ecx
  80257d:	d3 e5                	shl    %cl,%ebp
  80257f:	39 c5                	cmp    %eax,%ebp
  802581:	73 04                	jae    802587 <__udivdi3+0xf7>
  802583:	39 d6                	cmp    %edx,%esi
  802585:	74 09                	je     802590 <__udivdi3+0x100>
  802587:	89 d8                	mov    %ebx,%eax
  802589:	31 ff                	xor    %edi,%edi
  80258b:	e9 40 ff ff ff       	jmp    8024d0 <__udivdi3+0x40>
  802590:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802593:	31 ff                	xor    %edi,%edi
  802595:	e9 36 ff ff ff       	jmp    8024d0 <__udivdi3+0x40>
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	f3 0f 1e fb          	endbr32 
  8025a4:	55                   	push   %ebp
  8025a5:	57                   	push   %edi
  8025a6:	56                   	push   %esi
  8025a7:	53                   	push   %ebx
  8025a8:	83 ec 1c             	sub    $0x1c,%esp
  8025ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8025b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025bb:	85 c0                	test   %eax,%eax
  8025bd:	75 19                	jne    8025d8 <__umoddi3+0x38>
  8025bf:	39 df                	cmp    %ebx,%edi
  8025c1:	76 5d                	jbe    802620 <__umoddi3+0x80>
  8025c3:	89 f0                	mov    %esi,%eax
  8025c5:	89 da                	mov    %ebx,%edx
  8025c7:	f7 f7                	div    %edi
  8025c9:	89 d0                	mov    %edx,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	83 c4 1c             	add    $0x1c,%esp
  8025d0:	5b                   	pop    %ebx
  8025d1:	5e                   	pop    %esi
  8025d2:	5f                   	pop    %edi
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    
  8025d5:	8d 76 00             	lea    0x0(%esi),%esi
  8025d8:	89 f2                	mov    %esi,%edx
  8025da:	39 d8                	cmp    %ebx,%eax
  8025dc:	76 12                	jbe    8025f0 <__umoddi3+0x50>
  8025de:	89 f0                	mov    %esi,%eax
  8025e0:	89 da                	mov    %ebx,%edx
  8025e2:	83 c4 1c             	add    $0x1c,%esp
  8025e5:	5b                   	pop    %ebx
  8025e6:	5e                   	pop    %esi
  8025e7:	5f                   	pop    %edi
  8025e8:	5d                   	pop    %ebp
  8025e9:	c3                   	ret    
  8025ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f0:	0f bd e8             	bsr    %eax,%ebp
  8025f3:	83 f5 1f             	xor    $0x1f,%ebp
  8025f6:	75 50                	jne    802648 <__umoddi3+0xa8>
  8025f8:	39 d8                	cmp    %ebx,%eax
  8025fa:	0f 82 e0 00 00 00    	jb     8026e0 <__umoddi3+0x140>
  802600:	89 d9                	mov    %ebx,%ecx
  802602:	39 f7                	cmp    %esi,%edi
  802604:	0f 86 d6 00 00 00    	jbe    8026e0 <__umoddi3+0x140>
  80260a:	89 d0                	mov    %edx,%eax
  80260c:	89 ca                	mov    %ecx,%edx
  80260e:	83 c4 1c             	add    $0x1c,%esp
  802611:	5b                   	pop    %ebx
  802612:	5e                   	pop    %esi
  802613:	5f                   	pop    %edi
  802614:	5d                   	pop    %ebp
  802615:	c3                   	ret    
  802616:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80261d:	8d 76 00             	lea    0x0(%esi),%esi
  802620:	89 fd                	mov    %edi,%ebp
  802622:	85 ff                	test   %edi,%edi
  802624:	75 0b                	jne    802631 <__umoddi3+0x91>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f7                	div    %edi
  80262f:	89 c5                	mov    %eax,%ebp
  802631:	89 d8                	mov    %ebx,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f5                	div    %ebp
  802637:	89 f0                	mov    %esi,%eax
  802639:	f7 f5                	div    %ebp
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	31 d2                	xor    %edx,%edx
  80263f:	eb 8c                	jmp    8025cd <__umoddi3+0x2d>
  802641:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802648:	89 e9                	mov    %ebp,%ecx
  80264a:	ba 20 00 00 00       	mov    $0x20,%edx
  80264f:	29 ea                	sub    %ebp,%edx
  802651:	d3 e0                	shl    %cl,%eax
  802653:	89 44 24 08          	mov    %eax,0x8(%esp)
  802657:	89 d1                	mov    %edx,%ecx
  802659:	89 f8                	mov    %edi,%eax
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802661:	89 54 24 04          	mov    %edx,0x4(%esp)
  802665:	8b 54 24 04          	mov    0x4(%esp),%edx
  802669:	09 c1                	or     %eax,%ecx
  80266b:	89 d8                	mov    %ebx,%eax
  80266d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802671:	89 e9                	mov    %ebp,%ecx
  802673:	d3 e7                	shl    %cl,%edi
  802675:	89 d1                	mov    %edx,%ecx
  802677:	d3 e8                	shr    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80267f:	d3 e3                	shl    %cl,%ebx
  802681:	89 c7                	mov    %eax,%edi
  802683:	89 d1                	mov    %edx,%ecx
  802685:	89 f0                	mov    %esi,%eax
  802687:	d3 e8                	shr    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	89 fa                	mov    %edi,%edx
  80268d:	d3 e6                	shl    %cl,%esi
  80268f:	09 d8                	or     %ebx,%eax
  802691:	f7 74 24 08          	divl   0x8(%esp)
  802695:	89 d1                	mov    %edx,%ecx
  802697:	89 f3                	mov    %esi,%ebx
  802699:	f7 64 24 0c          	mull   0xc(%esp)
  80269d:	89 c6                	mov    %eax,%esi
  80269f:	89 d7                	mov    %edx,%edi
  8026a1:	39 d1                	cmp    %edx,%ecx
  8026a3:	72 06                	jb     8026ab <__umoddi3+0x10b>
  8026a5:	75 10                	jne    8026b7 <__umoddi3+0x117>
  8026a7:	39 c3                	cmp    %eax,%ebx
  8026a9:	73 0c                	jae    8026b7 <__umoddi3+0x117>
  8026ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8026af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026b3:	89 d7                	mov    %edx,%edi
  8026b5:	89 c6                	mov    %eax,%esi
  8026b7:	89 ca                	mov    %ecx,%edx
  8026b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026be:	29 f3                	sub    %esi,%ebx
  8026c0:	19 fa                	sbb    %edi,%edx
  8026c2:	89 d0                	mov    %edx,%eax
  8026c4:	d3 e0                	shl    %cl,%eax
  8026c6:	89 e9                	mov    %ebp,%ecx
  8026c8:	d3 eb                	shr    %cl,%ebx
  8026ca:	d3 ea                	shr    %cl,%edx
  8026cc:	09 d8                	or     %ebx,%eax
  8026ce:	83 c4 1c             	add    $0x1c,%esp
  8026d1:	5b                   	pop    %ebx
  8026d2:	5e                   	pop    %esi
  8026d3:	5f                   	pop    %edi
  8026d4:	5d                   	pop    %ebp
  8026d5:	c3                   	ret    
  8026d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	29 fe                	sub    %edi,%esi
  8026e2:	19 c3                	sbb    %eax,%ebx
  8026e4:	89 f2                	mov    %esi,%edx
  8026e6:	89 d9                	mov    %ebx,%ecx
  8026e8:	e9 1d ff ff ff       	jmp    80260a <__umoddi3+0x6a>
